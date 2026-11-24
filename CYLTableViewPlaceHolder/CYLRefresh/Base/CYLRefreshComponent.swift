//
//  CYLRefreshComponent.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  刷新控件的基类
//

// [EN] Swift since 2026-11-20 (docs/Swift-Migration.md, step 12), with the same Objective-C API: the class name, every
//      selector (properties with `is…` getters keep them), the Swift spellings Swift imported from the Objective-C header,
//      the overridable members `open` with the same selectors. It owns the KVO of the scroll view (`contentOffset`,
//      `contentSize`, `contentInset` and the pan gesture's `state`, registered with a private context on attach and
//      removed once on detach and in `deinit`), the state machine, the callbacks, the phases, the styles options, the
//      icon plumbing (`CYLRefreshIconLayout`), the state titles (`CYLRefreshStateTitles`) and the chaining setters. What
//      Swift cannot declare stays Objective-C (rule 6): the enums and block types in `CYLRefreshComponent.h`, and the
//      variadic `-isInPhases:` (`CYLRefreshComponent+CYLPhaseList.h`, `CYLRefreshComponentSupport.m`).
// [CN] 自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 12 步），Objective-C API 不变：类名、所有选择器（带 `is…` getter 的属性保持
//      不变）、Swift 从 Objective-C 头文件导入的写法、可重写成员为 `open` 且选择器不变。它负责滚动视图的 KVO（`contentOffset`、`contentSize`、
//      `contentInset` 与拖动手势的 `state`，挂上时以私有 context 注册，离开时与 `deinit` 中只移除一次）、状态机、回调、阶段、styles 选项、
//      图标（`CYLRefreshIconLayout`）、状态文字（`CYLRefreshStateTitles`）与链式设置方法。Swift 无法声明的部分保留为 Objective-C（第 6 条）：
//      `CYLRefreshComponent.h` 中的枚举与 block 类型，以及可变参数的 `-isInPhases:`（`CYLRefreshComponent+CYLPhaseList.h`、
//      `CYLRefreshComponentSupport.m`）。

import UIKit
import ObjectiveC

// [EN] The KVO context of the component's own observations: a stable address for the process's lifetime, so a change
//      registered by a subclass or a superclass is passed on instead of handled here.
// [CN] 本控件自己的 KVO context：进程内地址固定，子类或父类注册的变化会继续传递，不在这里处理。
private enum CYLRefreshComponentKVO {
    static let context = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)
}

// [EN] A target-action added with `-addTarget:action:`. The target is weak (the Objective-C code kept it unretained).
// [CN] `-addTarget:action:` 添加的 target-action。target 为弱引用（Objective-C 代码不持有它）。
private final class CYLRefreshTargetAction {

    weak var target: AnyObject?
    let action: Selector

    init(target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
}

// [EN] Sends `action` to `target` with `sender`, as `objc_msgSend` did (an action may take no argument or the control).
// [CN] 与 `objc_msgSend` 相同，把 `action` 连同 `sender` 发给 `target`（action 可以不带参数或带控件参数）。
private func CYLRefreshSend(_ action: Selector, to target: AnyObject, from sender: UIView) {
    guard let object = target as? NSObjectProtocol, object.responds(to: action),
          let targetClass = object_getClass(target) else { return }
    typealias Send = @convention(c) (AnyObject, Selector, UIView) -> Void
    unsafeBitCast(class_getMethodImplementation(targetClass, action), to: Send.self)(target, action, sender)
}

/**
 * [EN] The base class of the refresh controls (headers, footers, trailers): it observes its scroll view and runs the
 *      refresh state machine; subclasses lay themselves out and react to the state.
 * [CN] 刷新控件的基类（刷新头、加载尾、trailer）：监听所在的滚动视图并运行刷新状态机；子类负责布局并响应状态。
 */
@objc(CYLRefreshComponent)
open class CYLRefreshComponent: UIView {

    // MARK: - Private state

    // [EN] The scroll view the control is on (the protected `_scrollView` of the Objective-C class).
    // [CN] 控件所在的滚动视图（Objective-C 类中受保护的 `_scrollView`）。
    private weak var scrollViewStorage: UIScrollView?
    // [EN] The scroll view and pan gesture observed now; nil when nothing is registered (never removed twice).
    // [CN] 当前监听的滚动视图与拖动手势；未注册时为 nil（不会重复移除）。
    private weak var observedScrollView: UIScrollView?
    private var pan: UIPanGestureRecognizer?
    // [EN] The icon behind `cyl_iconView`, created on first use. [CN] `cyl_iconView` 的存储，首次使用时创建。
    fileprivate var iconViewStorage: CYLRefreshIconView?
    // [EN] Target-actions added with -addTarget:action:. [CN] -addTarget:action: 添加的 target-action。
    private var targetActions: [CYLRefreshTargetAction] = []
    // [EN] YES while the control holds after the refresh ends (finishDuration). [CN] 刷新结束后停留期间为 YES。
    private var finishing = false
    // [EN] Counts the holds, so a hold that ended early is not ended a second time by its timer. [CN] 对停留计数，提前结束的停留不会被其定时器再次结束。
    private var finishingGeneration = 0
    // [EN] The phase last reported to -phaseDidChangeFrom:to: (0 until the first report, as the Objective-C ivar).
    // [CN] 上次通知 -phaseDidChangeFrom:to: 的阶段（首次通知前为 0，与 Objective-C 实例变量相同）。
    private var reportedPhase = CYLRefreshPhase(rawValue: 0)!
    // [EN] Observers added with -addPhaseObserver: / -addScrollObserver:, by token. [CN] 按标识保存的阶段 / 滚动观察者。
    private var phaseObservers: [NSUUID: (CYLRefreshComponent, CYLRefreshPhase, CYLRefreshPhase) -> Void] = [:]
    private var scrollObservers: [NSUUID: (CYLRefreshComponent, CGFloat, CGFloat, Bool) -> Void] = [:]
    // [EN] YES while -beginRefreshingAnimationOnly holds the callbacks back. [CN] -beginRefreshingAnimationOnly 不调用回调期间为 YES。
    private var skipsCallbacks = false
    // [EN] YES once CYLRefreshConfig.defaultInitializer ran for this control. [CN] 已为本控件运行 defaultInitializer 后为 YES。
    private var initializedByConfig = false
    // [EN] The content offset when the current drag began (dragRate). [CN] 当前拖动开始时的内容偏移（dragRate）。
    private var dragStartOffsetY: CGFloat = 0
    // [EN] YES while this control turned the scroll view's touches off. [CN] 本控件关闭了滚动视图的触摸期间为 YES。
    private var disabledContent = false
    // [EN] The empty mask that hides the control (`autoHideRefresh`). [CN] 隐藏控件（`autoHideRefresh`）的空遮罩。
    private var autoHideMask: CALayer?
    // [EN] The text of each state (CYLRefreshStateTitles). [CN] 各状态的文字（CYLRefreshStateTitles）。
    fileprivate var stateTitleTable: [CYLRefreshState: String] = [:]
    // [EN] The image sequence of each state (`-cyl_setAnimationImages:duration:forState:`). [CN] 各状态的图片序列。
    fileprivate var animationImageTable: [CYLRefreshState: [UIImage]] = [:]

    // [EN] The storage of the properties whose setters have side effects; the initializer writes it as the Objective-C
    //      initializer wrote the ivars. [CN] 设置方法带副作用的属性的存储；初始化方法像 Objective-C 初始化方法写实例变量那样写入它。
    private var storedState = CYLRefreshState(rawValue: 0)!
    private var storedPullingPercent: CGFloat = 0
    private var storedAutomaticallyChangeAlpha = false
    private var storedAutoRefresh = false
    private var storedTriggerRate: CGFloat = 0
    private var storedRefreshEnabled = false
    private var storedAutoHideRefresh = false
    private var storedDisablesContentWhileRefreshing = false
    private var storedColorAccent: UIColor?
    private var storedColorPrimary: UIColor?
    private var storedRefreshingAction: Selector?
    private var storedLastRefreshSucceeded = false

    // MARK: - Initialization

    /**
     * [EN] Calls `prepare`, then starts idle with the default animation durations (0.25 s and 0.4 s).
     * [CN] 调用 `prepare`，然后以空闲状态和默认动画时长（0.25 秒与 0.4 秒）开始。
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        // [EN] On where the bars are transparent by default (set before prepare, which subclasses lay out in).
        // [CN] 在栏默认透明的系统上开启（在 prepare 之前设置，子类会在 prepare 中布局）。
        if #available(iOS 26.0, *) {
            storedAutoHideRefresh = true
        }
        // 准备工作
        prepare()

        // 默认是普通状态
        state = .idle
        fastAnimationDuration = 0.25
        slowAnimationDuration = 0.4
        storedTriggerRate = 1
        storedRefreshEnabled = true
        reportedPhase = .idle
    }

    /**
     * [EN] A control from a storyboard or nib (UIView's decoding; `prepare` is not called, as before).
     * [CN] 从 storyboard 或 nib 创建的控件（UIView 的解码；与之前相同，不调用 `prepare`）。
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        stopObservingScrollView()
    }

    // MARK: - 刷新动画时间控制

    /**
     * [EN] The duration of the quick animations (usually the bounce when a refresh starts); 0.25 s by default.
     * [CN] 快速动画时间(一般用在刷新开始的回弹动画), 默认 0.25
     */
    @objc open var fastAnimationDuration: TimeInterval = 0

    /**
     * [EN] The duration of the slow animations (usually the bounce after a refresh ends); 0.4 s by default.
     * [CN] 慢速动画时间(一般用在刷新结束后的回弹动画), 默认 0.4
     */
    @objc open var slowAnimationDuration: TimeInterval = 0

    /**
     * [EN] Turns every default animation off (sets both durations to 0); a simple fix for a collection view's bounce
     *      animation bug. Returns the control.
     * [CN] 关闭全部默认动画效果, 可以简单粗暴地解决 CollectionView 的回弹动画 bug
     */
    @objc(setAnimationDisabled)
    @discardableResult
    open func setAnimationDisabled() -> Self {
        fastAnimationDuration = 0
        slowAnimationDuration = 0
        return self
    }

    // MARK: - 刷新回调

    /**
     * [EN] Called when the control starts refreshing.
     * [CN] 正在刷新的回调
     */
    @objc open var refreshingBlock: CYLRefreshComponentAction?

    /**
     * [EN] Sets the object and the method called when the control refreshes.
     * [CN] 设置回调对象和回调方法
     */
    @objc(setRefreshingTarget:refreshingAction:)
    open func setRefreshingTarget(_ target: Any?, refreshingAction action: Selector) {
        refreshingTarget = target as AnyObject?
        refreshingAction = action
    }

    /**
     * [EN] The object that receives `refreshingAction` (weak).
     * [CN] 回调对象
     */
    @objc open weak var refreshingTarget: AnyObject?

    /**
     * [EN] The method sent to `refreshingTarget`; it may take no argument or the control.
     * [CN] 回调方法
     */
    @objc open var refreshingAction: Selector {
        // [EN] An unset action reads as NULL, as the Objective-C ivar did. [CN] 未设置时为 NULL，与 Objective-C 实例变量相同。
        get { storedRefreshingAction ?? unsafeBitCast(OpaquePointer?.none, to: Selector.self) }
        set { storedRefreshingAction = unsafeBitCast(newValue, to: OpaquePointer?.self) == nil ? nil : newValue }
    }

    /**
     * [EN] Calls the refreshing callbacks: the block, the handler, the target-actions, `refreshingTarget` and then
     *      `beginRefreshingCompletionBlock` (for subclasses to call).
     * [CN] 触发回调（交给子类去调用）
     */
    @objc open func executeRefreshingCallback() {
        if skipsCallbacks { return }
        if let block = refreshingBlock {
            block()
        }
        if let handler = refreshingHandler {
            handler(self)
        }
        for pair in targetActions {
            if let target = pair.target { CYLRefreshSend(pair.action, to: target, from: self) }
        }
        if let target = refreshingTarget, let action = storedRefreshingAction {
            CYLRefreshSend(action, to: target, from: self)
        }
        if let completion = beginRefreshingCompletionBlock {
            completion()
        }
    }

    // MARK: - 刷新状态控制

    /**
     * [EN] Starts refreshing (or waits for the window when the control is not on screen yet).
     * [CN] 进入刷新状态
     */
    @objc open func beginRefreshing() {
        if holdsBackStartForOtherRefresh() { return }
        // [EN] Started in code unless a pull armed the control or a scroll reached it. [CN] 除非由拉动触发或滚动到达，否则视为代码开始。
        let scrollView = self.scrollView
        let pan = scrollView?.panGestureRecognizer.state ?? .possible
        let byUser = state == .pulling || scrollView?.isDragging == true || scrollView?.isDecelerating == true ||
            pan == .began || pan == .changed || pan == .ended
        if !byUser && !isRefreshing && !storedAutoRefresh {
            storedAutoRefresh = true
            autoRefreshDidChange(true)
        }
        UIView.animate(withDuration: fastAnimationDuration) {
            self.alpha = 1.0
        }
        pullingPercent = 1.0
        // 只要正在刷新，就完全显示
        if window != nil {
            if storedAutoRefresh && !isRefreshing && openForAutoRefresh(withDuration: fastAnimationDuration) {
                // [EN] autoOpen: the control animates itself, the inset snaps. [CN] autoOpen：控件自己做动画，inset 直接到位。
                let saved = fastAnimationDuration
                fastAnimationDuration = 0
                state = .refreshing
                fastAnimationDuration = saved
                return
            }
            state = .refreshing
        } else {
            // 预防正在刷新中时，调用本方法使得header inset回置失败
            if state != .refreshing {
                state = .willRefresh
            }
        }
    }

    /**
     * [EN] Stores `completionBlock` as `beginRefreshingCompletionBlock`, then calls `beginRefreshing`; the block runs
     *      once the control has entered the refreshing state.
     * [CN] 把 `completionBlock` 存为 `beginRefreshingCompletionBlock` 后调用 `beginRefreshing`；控件进入刷新状态后调用该 block。
     */
    @objc(beginRefreshingWithCompletionBlock:)
    open func beginRefreshing(completionBlock: @escaping () -> Void) {
        beginRefreshingCompletionBlock = completionBlock
        beginRefreshing()
    }

    /**
     * [EN] Called after the control has entered the refreshing state.
     * [CN] 开始刷新后的回调(进入刷新状态后的回调)
     */
    @objc open var beginRefreshingCompletionBlock: CYLRefreshComponentAction?

    /**
     * [EN] Deprecated: sets `endRefreshingAnimationBeginAction`.
     * [CN] 带动画的结束刷新的回调（已废弃：设置 `endRefreshingAnimationBeginAction`）。
     */
    @available(*, deprecated, message: "first deprecated in 3.3.0 - Use `endRefreshingAnimationBeginAction` instead")
    @objc open var endRefreshingAnimateCompletionBlock: CYLRefreshComponentAction? {
        get { endRefreshingAnimationBeginAction }
        set { endRefreshingAnimationBeginAction = newValue }
    }

    /**
     * [EN] Called when the animation that ends a refresh begins (before `endRefreshingCompletionBlock`, which runs when
     *      it has finished); replaces the deprecated `endRefreshingAnimateCompletionBlock`.
     * [CN] 结束刷新的动画开始时调用（在动画结束时调用的 `endRefreshingCompletionBlock` 之前）；取代已废弃的
     *      `endRefreshingAnimateCompletionBlock`。
     */
    @objc open var endRefreshingAnimationBeginAction: CYLRefreshComponentAction?

    /**
     * [EN] Called when the refresh has ended.
     * [CN] 结束刷新的回调
     */
    @objc open var endRefreshingCompletionBlock: CYLRefreshComponentAction?

    /**
     * [EN] Ends refreshing (successfully).
     * [CN] 结束刷新状态
     */
    @objc open func endRefreshing() {
        endRefreshing(success: true)
    }

    /**
     * [EN] Stores `completionBlock` as `endRefreshingCompletionBlock`, then calls `endRefreshing`; the block runs when
     *      the end animation has finished.
     * [CN] 把 `completionBlock` 存为 `endRefreshingCompletionBlock` 后调用 `endRefreshing`；结束动画完成后调用该 block。
     */
    @objc(endRefreshingWithCompletionBlock:)
    open func endRefreshing(completionBlock: @escaping () -> Void) {
        endRefreshingCompletionBlock = completionBlock
        endRefreshing()
    }

    /**
     * [EN] YES while the control refreshes or is about to.
     * [CN] 是否正在刷新
     */
    @objc(refreshing)
    open var isRefreshing: Bool {
        @objc(isRefreshing) get { state == .refreshing || state == .willRefresh }
    }

    /**
     * [EN] Mutual exclusion with the other refresh components of the same scroll view (header, footer, trailer). Default
     *      NO: they run independently, except that a header refresh already holds back the automatic footer. YES: while
     *      another component is refreshing, this one does not start; the pull is dropped and `blockedByOtherRefreshBlock`
     *      runs. Set it on both components for a two-way exclusion.
     * [CN] 与同一滚动视图上的其他刷新控件（刷新头、加载尾、trailer）互斥。默认 NO：各自独立（刷新头刷新时仍会挡住自动加载尾）。
     *      YES：其他控件刷新期间本控件不开始，放弃本次拉动并调用 `blockedByOtherRefreshBlock`。两个控件都设置即双向互斥。
     */
    @objc(exclusiveWithOtherRefresh)
    open var isExclusiveWithOtherRefresh: Bool {
        @objc(isExclusiveWithOtherRefresh) get { storedExclusiveWithOtherRefresh }
        set { storedExclusiveWithOtherRefresh = newValue }
    }
    private var storedExclusiveWithOtherRefresh = false

    /**
     * [EN] Runs on the main thread each time a start was held back by `exclusiveWithOtherRefresh`, for example to show
     *      "refreshing, please wait".
     * [CN] 每次因 `exclusiveWithOtherRefresh` 被挡住时在主线程调用，例如提示“正在刷新，请稍候”。
     */
    @objc open var blockedByOtherRefreshBlock: CYLRefreshComponentAction?

    /**
     * [EN] The refresh state, usually set by the subclasses.
     * [CN] 刷新状态 一般交给子类内部实现
     */
    @objc open dynamic var state: CYLRefreshState {
        get { storedState }
        set {
            storedState = newValue
            updateContentTouches(for: newValue)
            if newValue == .idle || newValue == .noMoreData {
                if storedAutoRefresh {
                    storedAutoRefresh = false
                    autoRefreshDidChange(false)
                }
                skipsCallbacks = false
            }
            // [EN] The icon follows every state change of every subclass (CYLRefreshCheckState calls super).
            // [CN] 图标随所有子类的每次状态变化更新（CYLRefreshCheckState 会调用 super）。
            iconViewStorage?.update(for: newValue)
            reportPhaseChange()

            // 加入主队列的目的是等setState:方法调用完毕、设置完文字后再去布局子控件
            DispatchQueue.main.async { [weak self] in
                self?.setNeedsLayout()
            }
        }
    }

    // MARK: - 交给子类去访问

    /**
     * [EN] The scroll view's content inset when the control was attached (subclasses update it).
     * [CN] 记录scrollView刚开始的inset
     */
    @objc public internal(set) var scrollViewOriginalInset: UIEdgeInsets = .zero

    /**
     * [EN] The scroll view the control is on (weak).
     * [CN] 父控件
     */
    @objc open var scrollView: UIScrollView? {
        scrollViewStorage
    }

    /**
     * [EN] In a collection view whose layout flips horizontally in the opposite layout direction, these views are flipped
     *      back. Empty by default.
     * [CN] 当在 CollectionView 中使用 CollectionViewLayout 中的 flipsHorizontallyInOppositeLayoutDirection 时, 会反向 View 内容. 这里列出的 view 会被自动反向回来.
     */
    @objc open var flipsHorizontallyInOppositeLayoutDirectionViews: [UIView] {
        []
    }

    /**
     * [EN] Views flipped back in addition to `flipsHorizontallyInOppositeLayoutDirectionViews`. Empty by default.
     * [CN] 当在 CollectionView 中使用 CollectionViewLayout 中的 flipsHorizontallyInOppositeLayoutDirection 时, 会反向 View 内容. 这里列出的 view 会被自动反向回来. 默认为空
     */
    @objc open var additionalFlipsViews: [UIView] {
        []
    }

    // MARK: - 交给子类们去实现

    /**
     * [EN] Sets the control up (called once by the initializer); call super.
     * [CN] 初始化
     */
    @objc open func prepare() {
        // 基本属性
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear
    }

    /**
     * [EN] Lays the subviews out; call super.
     * [CN] 摆放子控件frame
     */
    @objc open func placeSubviews() {}

    /**
     * [EN] Called when the scroll view's `contentOffset` changes; call super.
     * [CN] 当scrollView的contentOffset发生改变的时候调用
     */
    @objc(scrollViewContentOffsetDidChange:)
    open func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {}

    /**
     * [EN] Called when the scroll view's `contentSize` changes; call super.
     * [CN] 当scrollView的contentSize发生改变的时候调用
     */
    @objc(scrollViewContentSizeDidChange:)
    open func scrollViewContentSizeDidChange(_ change: [AnyHashable: Any]?) {}

    /**
     * [EN] Called when the state of the scroll view's pan gesture changes; call super.
     * [CN] 当scrollView的拖拽状态发生改变的时候调用
     */
    @objc(scrollViewPanStateDidChange:)
    open func scrollViewPanStateDidChange(_ change: [AnyHashable: Any]?) {}

    /**
     * [EN] Called when `CYLRefreshConfig.defaultConfig`'s language changes; the base calls `placeSubviews` (do not call
     *      this from `placeSubviews`). Subclasses change their texts first and call super last.
     * [CN] 多语言配置 language 发生变化时调用。父类会调用 `placeSubviews` 方法, 请勿在 placeSubviews 中调用本方法, 造成死循环.
     *      子类在需要重新布局时, 在配置完修改后, 最后再调用 super 方法。
     */
    @objc open func i18nDidChange() {
        placeSubviews()
    }

    // MARK: - 其他

    /**
     * [EN] How far the control is pulled open, from 0 (subclasses override it).
     * [CN] 拉拽的百分比(交给子类重写)
     */
    @objc open dynamic var pullingPercent: CGFloat {
        get { storedPullingPercent }
        set {
            storedPullingPercent = newValue
            iconViewStorage?.update(pullingPercent: newValue)
            reportPhaseChange()

            if isRefreshing { return }

            if isAutomaticallyChangeAlpha {
                alpha = newValue
            }
        }
    }

    /**
     * [EN] Deprecated: `automaticallyChangeAlpha`.
     * [CN] 根据拖拽比例自动切换透明度（已废弃，请使用 `automaticallyChangeAlpha`）。
     */
    @available(*, deprecated, message: "请使用automaticallyChangeAlpha属性")
    @objc(autoChangeAlpha)
    open var isAutoChangeAlpha: Bool {
        @objc(isAutoChangeAlpha) get { isAutomaticallyChangeAlpha }
        set { isAutomaticallyChangeAlpha = newValue }
    }

    /**
     * [EN] Fades the control with the pull (`alpha` follows `pullingPercent` while not refreshing).
     * [CN] 根据拖拽比例自动切换透明度
     */
    @objc(automaticallyChangeAlpha)
    open var isAutomaticallyChangeAlpha: Bool {
        @objc(isAutomaticallyChangeAlpha) get { storedAutomaticallyChangeAlpha }
        set {
            storedAutomaticallyChangeAlpha = newValue

            if isRefreshing { return }

            if newValue {
                alpha = pullingPercent
            } else {
                alpha = 1.0
            }
        }
    }

    // MARK: - CYLRefresh styles API

    /**
     * [EN] Creates the control and attaches it to `scrollView` as its header, footer or trailer (by class).
     * [CN] 创建控件，并按类型作为 `scrollView` 的刷新头、加载尾或 trailer 挂上。
     */
    @objc(attach:)
    @discardableResult
    open class func attach(to scrollView: UIScrollView) -> Self {
        let component = self.init()
        component.attach(to: scrollView)
        return component
    }

    /**
     * [EN] Creates, attaches and adds a refreshing target in one call.
     * [CN] 一次完成创建、挂上并添加刷新回调对象。
     */
    @objc(attach:target:action:)
    @discardableResult
    open class func attach(to scrollView: UIScrollView, target: Any?, action: Selector) -> Self {
        let component = attach(to: scrollView)
        component.addTarget(target, action: action)
        return component
    }

    /**
     * [EN] Attaches this control to `scrollView` as its header, footer or trailer (by class).
     * [CN] 按类型把本控件作为 `scrollView` 的刷新头、加载尾或 trailer 挂上。
     */
    @objc(attach:)
    open func attach(to scrollView: UIScrollView) {
        if let header = self as? CYLRefreshHeader {
            scrollView.cyl_header = header
        } else if let footer = self as? CYLRefreshFooter {
            scrollView.cyl_footer = footer
        } else if let trailer = self as? CYLRefreshTrailer {
            scrollView.cyl_trailer = trailer
        } else {
            scrollView.addSubview(self)
        }
    }

    /**
     * [EN] Adds a target-action called on every refresh, besides `refreshingTarget` and the blocks; several can be
     *      added. `action` may take no argument or the control. A nil target or action is ignored.
     * [CN] 添加每次刷新都会调用的 target-action（`refreshingTarget` 与 block 之外，可添加多个）；`action` 可以不带参数或带控件参数。
     *      target 或 action 为 nil 时忽略。
     */
    @objc(addTarget:action:)
    open func addTarget(_ target: Any?, action: Selector?) {
        guard let target = target as AnyObject?, !(target is NSNull),
              let action = action, unsafeBitCast(action, to: OpaquePointer?.self) != nil else { return }
        targetActions.append(CYLRefreshTargetAction(target: target, action: action))
    }

    /**
     * [EN] Removes a target-action added with `addTarget:action:`; a nil action removes every action of `target`.
     * [CN] 移除 `addTarget:action:` 添加的 target-action；action 为 nil 时移除 `target` 的所有 action。
     */
    @objc(removeTarget:action:)
    open func removeTarget(_ target: Any?, action: Selector?) {
        guard let target = target as AnyObject?, !(target is NSNull) else { return }
        let action = action.flatMap { unsafeBitCast($0, to: OpaquePointer?.self) == nil ? nil : $0 }
        targetActions.removeAll { pair in
            pair.target === target && (action == nil || pair.action == action)
        }
    }

    /**
     * [EN] Called on every refresh with the control.
     * [CN] 每次刷新时调用，参数为控件本身。
     */
    @objc open var refreshingHandler: CYLRefreshComponentHandler?

    /**
     * [EN] YES while the control is on a scroll view.
     * [CN] 控件挂在滚动视图上时为 YES。
     */
    @objc(attached)
    open var isAttached: Bool {
        @objc(isAttached) get { scrollView != nil }
    }

    /**
     * [EN] How far to pull, as a multiple of `expandHeight`, before releasing refreshes. Default 1; a value that is not
     *      positive and finite sets 1.
     * [CN] 松手刷新所需的拉动距离，为 `expandHeight` 的倍数，默认 1；非正数或非有限值时设为 1。
     */
    @objc open var triggerRate: CGFloat {
        get { storedTriggerRate }
        set { storedTriggerRate = (newValue.isFinite && newValue > 0) ? newValue : 1 }
    }

    /**
     * [EN] Seconds the control stays open after the refresh ends, before retracting. Default 0.
     * [CN] 刷新结束后、收回前停留的秒数，默认 0。
     */
    @objc open var finishDuration: TimeInterval = 0

    /**
     * [EN] How the header moves while pulled (headers only). Default `CYLRefreshScrollModeMove`.
     * [CN] 下拉时刷新头的移动方式（仅刷新头），默认 `CYLRefreshScrollModeMove`。
     */
    @objc open var scrollMode: CYLRefreshScrollMode = .move

    /**
     * [EN] Foreground color: every label, image tint and spinner of the control. nil keeps each view's own color.
     * [CN] 前景色：控件中所有文字、图片着色与菊花。nil 保留各视图自己的颜色。
     */
    @objc open var colorAccent: UIColor? {
        get { storedColorAccent }
        set {
            storedColorAccent = newValue
            setNeedsLayout()
        }
    }

    /**
     * [EN] Background color of the control. nil keeps a clear background.
     * [CN] 控件背景色。nil 保持透明背景。
     */
    @objc open var colorPrimary: UIColor? {
        get { storedColorPrimary }
        set {
            storedColorPrimary = newValue
            backgroundColor = newValue ?? .clear
        }
    }

    /**
     * [EN] YES while the control holds its refreshing position (refreshing or about to).
     * [CN] 控件处于刷新位置（刷新中或即将刷新）时为 YES。
     */
    @objc(expanded)
    open var isExpanded: Bool {
        @objc(isExpanded) get { isRefreshing }
    }

    /**
     * [EN] The control's height when open; constant while `scrollMode` stretches the frame.
     * [CN] 控件展开时的高度；`scrollMode` 拉伸 frame 时保持不变。
     */
    @objc open var expandHeight: CGFloat {
        cyl_h
    }

    /**
     * [EN] Points pulled, `pullingPercent` × `expandHeight` × `triggerRate`.
     * [CN] 已拉动的点数，`pullingPercent` × `expandHeight` × `triggerRate`。
     */
    @objc open var dragOffset: CGFloat {
        pullingPercent * expandHeight * triggerRate
    }

    /**
     * [EN] The detailed phase.
     * [CN] 细分阶段。
     */
    @objc open var phase: CYLRefreshPhase {
        if state == .noMoreData { return .noMoreData }
        if finishing { return .finishing }
        switch state {
        case .refreshing:
            return .refreshing
        case .willRefresh:
            return .willRefresh
        case .pulling:
            return scrollView?.isDragging == true ? .releaseToRefresh : .releasing
        default:
            return (pullingPercent > 0 && scrollView?.isDragging == true) ? .pullToRefresh : .idle
        }
    }

    /**
     * [EN] YES when the control is in one of `phases` (NSNumber-wrapped `CYLRefreshPhase` values).
     * [CN] 控件处于 `phases`（以 NSNumber 包装的 `CYLRefreshPhase`）之一时为 YES。
     */
    @objc(isInAnyPhase:)
    open func isIn(phases: [NSNumber]) -> Bool {
        phases.contains(NSNumber(value: phase.rawValue))
    }

    /**
     * [EN] Ends the refresh and records whether it succeeded: the control can show it for `finishDuration`
     *      (`-refreshDidFinishWithSuccess:`), then retracts. `endRefreshing` is the same with YES. Hops to the main queue
     *      when called on another thread.
     * [CN] 结束刷新并记录是否成功：控件可在 `finishDuration` 内显示结果（`-refreshDidFinishWithSuccess:`），然后收回。`endRefreshing`
     *      相当于传 YES。在其他线程调用时切换到主队列。
     */
    @objc(endRefreshingWithSuccess:)
    open func endRefreshing(success: Bool) {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.endRefreshing(success: success)
            }
            return
        }
        if finishing { return }
        if !isRefreshing {
            state = .idle
            return
        }
        storedLastRefreshSucceeded = success
        refreshDidFinish(withSuccess: success)
        let duration = finishingDuration(withSuccess: success)
        if duration <= 0 || !duration.isFinite {
            state = .idle
            return
        }
        // [EN] Hold open for `duration`, showing the result, then retract. [CN] 停留 `duration` 显示结果，然后收回。
        finishing = true
        finishingGeneration += 1
        let generation = finishingGeneration
        reportPhaseChange()
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.endFinishingHold(generation: generation)
        }
    }

    private func endFinishingHold(generation: Int) {
        guard finishing, generation == finishingGeneration else { return }
        finishing = false
        if isRefreshing { state = .idle }
        reportPhaseChange()
    }

    // [EN] Ends the hold of `endRefreshing(success:)` now, as its timer would later: a control whose end animation reached its
    //      end (CYLRefreshRiveHeader) retracts at that moment. Does nothing when no hold is running.
    // [CN] 立即结束 `endRefreshing(success:)` 的停留（其定时器稍后也会这样做）：结束动画播放完毕的控件（CYLRefreshRiveHeader）在此刻收回。
    //      没有停留时什么也不做。
    func cyl_endFinishingHold() {
        endFinishingHold(generation: finishingGeneration)
    }

    /**
     * [EN] `beginRefreshing` with options (flutter_easy_refresh's `callRefresh` / `callLoad`): `duration` (seconds, 0
     *      keeps `fastAnimationDuration`) for moving to the refreshing position; `overOffset` (points) scrolls that much
     *      further and springs back, as a pull would; `force` starts even while another control of the scroll view is
     *      refreshing and `exclusiveWithOtherRefresh` would hold it back.
     * [CN] 带选项的 `beginRefreshing`（对应 flutter_easy_refresh 的 `callRefresh` / `callLoad`）：`duration`（秒，0 表示沿用
     *      `fastAnimationDuration`）为移到刷新位置的时长；`overOffset`（点）多滚动这么远再回弹，像真实拉动一样；`force` 即使同一滚动视图的
     *      其他控件正在刷新、`exclusiveWithOtherRefresh` 会阻止时也开始刷新。
     */
    @objc(beginRefreshingWithDuration:overOffset:force:)
    open func beginRefreshing(duration: TimeInterval, overOffset: CGFloat, force: Bool) {
        let savedDuration = fastAnimationDuration
        let savedExclusive = isExclusiveWithOtherRefresh
        if duration > 0 { fastAnimationDuration = duration }
        if force { isExclusiveWithOtherRefresh = false }
        beginRefreshing()
        isExclusiveWithOtherRefresh = savedExclusive
        let move = fastAnimationDuration
        fastAnimationDuration = savedDuration
        if overOffset <= 0 || scrollView == nil || window == nil { return }
        // [EN] Overshoot past the refreshing position and spring back, as a real pull ends. [CN] 越过刷新位置再回弹，像真实拉动的结尾。
        let down = self is CYLRefreshHeader
        DispatchQueue.main.asyncAfter(deadline: .now() + move) { [weak self] in
            guard let self = self, let scrollView = self.scrollView, self.isRefreshing else { return }
            let rest = scrollView.contentOffset
            let over = CGPoint(x: rest.x, y: rest.y + (down ? -overOffset : overOffset))
            UIView.animate(withDuration: 0.15, animations: {
                scrollView.contentOffset = over
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
                               options: [], animations: { scrollView.contentOffset = rest }, completion: nil)
            })
        }
    }

    /**
     * [EN] Whether the last refresh ended successfully.
     * [CN] 上一次刷新是否成功结束。
     */
    @objc open var lastRefreshSucceeded: Bool {
        storedLastRefreshSucceeded
    }

    // MARK: Auto-hide

    /**
     * [EN] Shows the control only while an action is under way (pulling, refreshing, retracting, loading) and hides it
     *      again afterwards: a header once it is idle and fully retracted, a footer once it is idle (or shows "no more
     *      data") and lies wholly below the bottom bars. On by default where the bars are transparent by default (iOS 26
     *      and later); off by default on earlier systems. The control is masked out, so its `hidden` and `alpha` stay as
     *      the caller set them.
     * [CN] 只在有动作进行时显示控件（下拉、刷新、收回、加载），之后自动隐藏：刷新头在空闲且完全收回后隐藏，刷新尾在空闲（或显示“无更多数据”）
     *      且完全位于底部栏下方时隐藏。在栏默认透明的系统上默认开启（iOS 26 及以后）；更早的系统默认关闭。隐藏通过遮罩实现，`hidden`、`alpha`
     *      保持调用方的设置。
     */
    @objc open var autoHideRefresh: Bool {
        get { storedAutoHideRefresh }
        set {
            storedAutoHideRefresh = newValue
            updateAutoHideVisibility()
        }
    }

    /**
     * [EN] Subclass hook: YES when the control may be hidden now (`autoHideRefresh`). Headers and footers override it;
     *      the base returns NO.
     * [CN] 子类钩子：控件此刻可以隐藏时返回 YES（`autoHideRefresh`）。刷新头与刷新尾重写它；基类返回 NO。
     */
    @objc open func isReadyToAutoHide() -> Bool {
        false
    }

    /**
     * [EN] Applies `autoHideRefresh` again; call it when something `isReadyToAutoHide` reads has changed.
     * [CN] 重新应用 `autoHideRefresh`；`isReadyToAutoHide` 依赖的条件变化时调用。
     */
    @objc open func updateAutoHideVisibility() {
        let hide = autoHideRefresh && isReadyToAutoHide()
        let hidden = autoHideMask != nil && layer.mask === autoHideMask
        if hide == hidden { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if hide {
            if autoHideMask == nil { autoHideMask = CALayer() }
            layer.mask = autoHideMask
        } else {
            layer.mask = nil
        }
        CATransaction.commit()
        // [EN] What is not shown is not read either. [CN] 不显示的内容也不让 VoiceOver 读取。
        accessibilityElementsHidden = hide
    }

    // MARK: flutter_easy_refresh-style options

    /**
     * [EN] NO turns the refresh off while keeping the bounce: pulling never arms the control (flutter_easy_refresh's
     *      `NotRefreshHeader` / `NotLoadFooter`). Default YES.
     * [CN] NO 关闭刷新但保留回弹：拉动永远不会触发（对应 flutter_easy_refresh 的 `NotRefreshHeader` / `NotLoadFooter`）。默认 YES。
     */
    @objc(refreshEnabled)
    open var isRefreshEnabled: Bool {
        @objc(isRefreshEnabled) get { storedRefreshEnabled }
        set { storedRefreshEnabled = newValue }
    }

    /**
     * [EN] Starts refreshing as soon as the pull reaches the trigger point, without waiting for the release
     *      (flutter_easy_refresh's `triggerWhenReach`). Default NO.
     * [CN] 拉到触发点时立即开始刷新，不等待松手（对应 flutter_easy_refresh 的 `triggerWhenReach`）。默认 NO。
     */
    @objc open var triggersWhenReached = false

    /**
     * [EN] When a pull may arm the control; default `CYLRefreshTriggerModeAnywhere` (flutter_easy_refresh's
     *      `IndicatorTriggerMode`). Headers and back footers.
     * [CN] 拉动何时可以触发控件；默认 `CYLRefreshTriggerModeAnywhere`（对应 flutter_easy_refresh 的 `IndicatorTriggerMode`）。适用于刷新头与返回式刷新尾。
     */
    @objc open var triggerMode: CYLRefreshTriggerMode = .anywhere

    /**
     * [EN] A light haptic tap when the pull crosses the trigger point (flutter_easy_refresh's `hapticFeedback`). Default NO.
     * [CN] 拉动越过触发点时轻触反馈（对应 flutter_easy_refresh 的 `hapticFeedback`）。默认 NO。
     */
    @objc open var hapticFeedback = false

    /**
     * [EN] The farthest the user can pull the control open, in points; 0 (default) means no limit
     *      (flutter_easy_refresh's `maxOverOffset`). Headers and back footers.
     * [CN] 用户最多能把控件拉开的距离（点）；0（默认）表示不限制（对应 flutter_easy_refresh 的 `maxOverOffset`）。适用于刷新头与返回式刷新尾。
     */
    @objc open var maxPullDistance: CGFloat = 0

    /**
     * [EN] Keeps following the scroll view while the control is hidden, so hooks and observers still run
     *      (flutter_easy_refresh's `notifyWhenInvisible`). Default NO.
     * [CN] 控件隐藏时仍跟随滚动视图，钩子和观察者照常执行（对应 flutter_easy_refresh 的 `notifyWhenInvisible`）。默认 NO。
     */
    @objc open var notifiesWhenHidden = false

    /**
     * [EN] Calls `observer` on every phase change, with the old and the new phase (flutter_easy_refresh's `listenable`).
     *      A plain `CYLRefreshHeader` draws nothing, so with an observer it is a listener header (`ListenerHeader`).
     *      Returns a token for `removePhaseObserver:` (a nil observer is not added).
     * [CN] 每次阶段变化时调用 `observer`，参数为旧阶段与新阶段（对应 flutter_easy_refresh 的 `listenable`）。普通的 `CYLRefreshHeader`
     *      不绘制任何内容，加上观察者就是监听刷新头（`ListenerHeader`）。返回用于 `removePhaseObserver:` 的标识（nil 不会被添加）。
     */
    @objc(addPhaseObserver:)
    @discardableResult
    open func addPhaseObserver(_ observer: ((CYLRefreshComponent, CYLRefreshPhase, CYLRefreshPhase) -> Void)?) -> Any {
        let token = NSUUID()
        if let observer = observer {
            phaseObservers[token] = observer
        }
        return token
    }

    /**
     * [EN] Removes an observer added with `addPhaseObserver:`.
     * [CN] 移除 `addPhaseObserver:` 添加的观察者。
     */
    @objc(removePhaseObserver:)
    open func removePhaseObserver(_ token: Any?) {
        if let token = token as? NSUUID { phaseObservers[token] = nil }
    }

    // MARK: Starting and ending in code (CYLRefreshLayout's autoRefresh / finishRefresh)

    /**
     * [EN] YES while the current refresh was started in code (`beginRefreshing` and its variants) rather than by a pull
     *      or a scroll; NO once it ends (CYLRefreshLayout's `isAutoRefresh`).
     * [CN] 当前刷新由代码开始（`beginRefreshing` 及其变体）而不是由拉动或滚动开始时为 YES；结束后为 NO（对应 CYLRefreshLayout 的
     *      `isAutoRefresh`）。
     */
    @objc(autoRefresh)
    open var isAutoRefresh: Bool {
        @objc(isAutoRefresh) get { storedAutoRefresh }
    }

    /**
     * [EN] Starts refreshing after `delay` seconds, as `beginRefreshing` does (CYLRefreshLayout's `autoRefresh(delayed)` /
     *      `autoLoadMore(delayed)`). The control is not retained for the delay.
     * [CN] `delay` 秒后开始刷新，与 `beginRefreshing` 相同（对应 CYLRefreshLayout 的 `autoRefresh(delayed)` /
     *      `autoLoadMore(delayed)`）。等待期间不持有控件。
     */
    @objc(beginRefreshingAfterDelay:)
    open func beginRefreshing(afterDelay delay: TimeInterval) {
        if delay <= 0 {
            beginRefreshing()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.beginRefreshing()
        }
    }

    /**
     * [EN] Shows the refreshing state without calling the refreshing callbacks (block, handler, target-actions); end it
     *      with `endRefreshing` (CYLRefreshLayout's `autoRefreshAnimationOnly` / `autoLoadMoreAnimationOnly`).
     * [CN] 显示刷新状态但不调用刷新回调（block、handler、target-action）；用 `endRefreshing` 结束（对应 CYLRefreshLayout 的
     *      `autoRefreshAnimationOnly` / `autoLoadMoreAnimationOnly`）。
     */
    @objc open func beginRefreshingAnimationOnly() {
        if isRefreshing { return }
        skipsCallbacks = true
        beginRefreshing()
        // [EN] Held back by another refresh: nothing started, so the next start calls back again.
        // [CN] 被其他刷新挡住时没有开始，下次开始仍调用回调。
        if !isRefreshing { skipsCallbacks = false }
    }

    /**
     * [EN] Ends refreshing after `delay` seconds with the result `success`, as `endRefreshingWithSuccess:` does
     *      (CYLRefreshLayout's `finishRefresh(delayed, success)` / `finishLoadMore(delayed, success)`). The control is not
     *      retained for the delay.
     * [CN] `delay` 秒后以结果 `success` 结束刷新，与 `endRefreshingWithSuccess:` 相同（对应 CYLRefreshLayout 的
     *      `finishRefresh(delayed, success)` / `finishLoadMore(delayed, success)`）。等待期间不持有控件。
     */
    @objc(endRefreshingAfterDelay:success:)
    open func endRefreshing(afterDelay delay: TimeInterval, success: Bool) {
        if delay <= 0 {
            endRefreshing(success: success)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.endRefreshing(success: success)
        }
    }

    // MARK: Observing and deciding (CYLRefreshLayout's OnMultiListener / ScrollBoundaryDecider)

    /**
     * [EN] Calls `observer` on every move of the control, with the pulled points, the percent and whether the user
     *      drags (CYLRefreshLayout's `OnMultiListener.onHeaderMoving` / `onFooterMoving`; the phase changes are
     *      `addPhaseObserver:`). Returns a token for `removeScrollObserver:` (a nil observer is not added).
     * [CN] 控件每次移动时调用 `observer`，参数为已拉动点数、百分比以及用户是否在拖动（对应 CYLRefreshLayout 的
     *      `OnMultiListener.onHeaderMoving` / `onFooterMoving`；阶段变化见 `addPhaseObserver:`）。返回用于 `removeScrollObserver:`
     *      的标识（nil 不会被添加）。
     */
    @objc(addScrollObserver:)
    @discardableResult
    open func addScrollObserver(_ observer: ((CYLRefreshComponent, CGFloat, CGFloat, Bool) -> Void)?) -> Any {
        let token = NSUUID()
        if let observer = observer {
            scrollObservers[token] = observer
        }
        return token
    }

    /**
     * [EN] Removes an observer added with `addScrollObserver:`.
     * [CN] 移除 `addScrollObserver:` 添加的观察者。
     */
    @objc(removeScrollObserver:)
    open func removeScrollObserver(_ token: Any?) {
        if let token = token as? NSUUID { scrollObservers[token] = nil }
    }

    /**
     * [EN] Decides whether a pull may arm the control now; nil (default) uses the built-in edge check
     *      (CYLRefreshLayout's `ScrollBoundaryDecider.canRefresh` / `canLoadMore`). Return NO, for example, while a nested
     *      horizontal list is being dragged.
     * [CN] 决定此刻拉动能否触发控件；nil（默认）使用内置的边缘判断（对应 CYLRefreshLayout 的 `ScrollBoundaryDecider.canRefresh` /
     *      `canLoadMore`）。例如嵌套的横向列表正在拖动时返回 NO。
     */
    @objc open var canTriggerBlock: ((CYLRefreshComponent) -> Bool)?

    /**
     * [EN] Whether a pull may arm the control now: `canTriggerBlock`'s answer, YES without one. Subclasses check it
     *      before arming.
     * [CN] 此刻拉动能否触发控件：`canTriggerBlock` 的结果，没有时为 YES。子类在触发前检查。
     */
    @objc open func canTrigger() -> Bool {
        if let block = canTriggerBlock { return block(self) }
        return true
    }

    /**
     * [EN] Ignores touches on the scroll view while this control refreshes (CYLRefreshLayout's
     *      `setDisableContentWhenRefresh` / `setDisableContentWhenLoading`). Default NO.
     * [CN] 本控件刷新期间忽略滚动视图上的触摸（对应 CYLRefreshLayout 的 `setDisableContentWhenRefresh` /
     *      `setDisableContentWhenLoading`）。默认 NO。
     */
    @objc open var disablesContentWhileRefreshing: Bool {
        get { storedDisablesContentWhileRefreshing }
        set {
            storedDisablesContentWhileRefreshing = newValue
            updateContentTouches(for: state)
        }
    }

    // MARK: Layout options (CYLRefreshLayout's RefreshLayout setters)

    /**
     * [EN] Pull distance per finger distance while pulling the control open, from 0 to 1; 0 (default) and 1 follow
     *      UIScrollView's own rubber band (CYLRefreshLayout's `setDragRate`). Headers and back footers.
     * [CN] 拉开控件时手指每移动一点控件拉开的距离，0 到 1；0（默认）与 1 使用 UIScrollView 自带的回弹（对应 CYLRefreshLayout 的
     *      `setDragRate`）。适用于刷新头与返回式刷新尾。
     */
    @objc open var dragRate: CGFloat = 0

    /**
     * [EN] The animation curve of the bounce back when a refresh ends; default 0 (`UIViewAnimationOptionCurveEaseInOut`)
     *      (CYLRefreshLayout's `setReboundInterpolator`). Headers and back footers.
     * [CN] 刷新结束后回弹的动画曲线；默认 0（`UIViewAnimationOptionCurveEaseInOut`）（对应 CYLRefreshLayout 的
     *      `setReboundInterpolator`）。适用于刷新头与返回式刷新尾。
     */
    @objc open var reboundAnimationOptions: UIView.AnimationOptions = []

    /**
     * [EN] Moves the control this many points into the content from its edge, for example below a translucent bar that
     *      covers the top (CYLRefreshLayout's `setHeaderInsetStart` / `setFooterInsetStart`). Default 0.
     * [CN] 把控件从边缘向内容内移动这么多点，例如放在遮住顶部的半透明栏下面（对应 CYLRefreshLayout 的 `setHeaderInsetStart` /
     *      `setFooterInsetStart`）。默认 0。
     */
    @objc open var insetStart: CGFloat = 0

    /**
     * [EN] A view inside the scroll view that stays where it is while the control is pulled, for example a pinned bar
     *      (CYLRefreshLayout's `setFixedHeaderViewId` / `setFixedFooterViewId`). Weak; nil (default) pins nothing.
     * [CN] 滚动视图内的一个视图，控件被拉开时保持不动，例如固定的栏（对应 CYLRefreshLayout 的 `setFixedHeaderViewId` /
     *      `setFixedFooterViewId`）。弱引用；nil（默认）不固定任何视图。
     */
    @objc open weak var pinnedView: UIView?

    /**
     * [EN] A view that moves with the control by the pulled distance, for example a background outside the scroll view
     *      (CYLRefreshLayout's `setHeaderTranslationViewId` / `setFooterTranslationViewId`). Weak; nil (default) moves
     *      nothing else.
     * [CN] 随控件移动拉开距离的视图，例如滚动视图外的背景（对应 CYLRefreshLayout 的 `setHeaderTranslationViewId` /
     *      `setFooterTranslationViewId`）。弱引用；nil（默认）不移动其他视图。
     */
    @objc open weak var translationView: UIView?

    /**
     * [EN] Calls `-didDragHorizontallyWithOffset:percent:` for sideways finger moves while the control is pulled
     *      (CYLRefreshLayout's `RefreshComponent.isSupportHorizontalDrag`). Default NO.
     * [CN] 控件被拉开时，手指横向移动会调用 `-didDragHorizontallyWithOffset:percent:`（对应 CYLRefreshLayout 的
     *      `RefreshComponent.isSupportHorizontalDrag`）。默认 NO。
     */
    @objc open var supportsHorizontalDrag = false

    // MARK: - Layout and attaching

    /**
     * [EN] Lays the subviews out (`placeSubviews`), applies `colorAccent` and flips the listed views back in a
     *      collection view whose layout flips horizontally.
     * [CN] 布局子控件（`placeSubviews`），应用 `colorAccent`，并在水平翻转布局的 collection view 中把列出的视图翻转回来。
     */
    open override func layoutSubviews() {
        placeSubviews()
        applyThemeColors()

        super.layoutSubviews()

        guard let collectionView = scrollView as? UICollectionView,
              collectionView.collectionViewLayout.flipsHorizontallyInOppositeLayoutDirection else { return }

        let flipTransform = CGAffineTransform(scaleX: -1, y: 1)
        for view in flipsHorizontallyInOppositeLayoutDirectionViews {
            view.transform = flipTransform
        }
        for view in additionalFlipsViews {
            view.transform = flipTransform
        }
    }

    /**
     * [EN] Detaches from the old scroll view (its observers removed) and attaches to a new one: width, position,
     *      vertical bounce, original inset and observers.
     * [CN] 离开旧的滚动视图（移除监听），挂到新的滚动视图：宽度、位置、垂直回弹、原始 inset 与监听。
     */
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        // 旧的父控件移除监听
        if let oldScrollView = scrollViewStorage, newSuperview !== oldScrollView {
            willDetach(from: oldScrollView)
        }
        removeObservers()
        scrollViewStorage = nil

        // 新的父控件
        if let newScrollView = newSuperview as? UIScrollView {
            // 记录UIScrollView
            scrollViewStorage = newScrollView

            // 设置宽度
            cyl_w = newScrollView.cyl_w
            // 设置位置
            cyl_x = -newScrollView.cyl_insetL

            // 设置永远支持垂直弹簧效果
            newScrollView.alwaysBounceVertical = true
            // 记录UIScrollView最开始的contentInset
            scrollViewOriginalInset = newScrollView.cyl_inset

            // 添加监听
            addObservers()
        }
    }

    /**
     * [EN] Runs `CYLRefreshConfig.defaultInitializer` once per control and calls `didAttachToScrollView:`.
     * [CN] 每个控件运行一次 `CYLRefreshConfig.defaultInitializer`，并调用 `didAttachToScrollView:`。
     */
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let scrollView = scrollViewStorage, superview === scrollView else { return }
        // [EN] The app-wide setup runs once per control (CYLRefreshConfig.defaultInitializer).
        // [CN] 应用级设置每个控件只运行一次（CYLRefreshConfig.defaultInitializer）。
        if !initializedByConfig, let initializer = CYLRefreshConfig.default.defaultInitializer {
            initializedByConfig = true
            initializer(self)
        }
        didAttach(to: scrollView)
    }

    /**
     * [EN] A refresh started before the control was on screen starts once it is in a window (on the next main-queue turn,
     *      without retaining the control).
     * [CN] 控件上屏前开始的刷新，在其进入窗口后开始（在下一次主队列循环中，不持有控件）。
     */
    open override func didMoveToWindow() {
        super.didMoveToWindow()

        if window == nil || state != .willRefresh { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.window != nil, self.state == .willRefresh else { return }
            self.layoutIfNeeded()
            if self.window != nil && self.state == .willRefresh {
                self.state = .refreshing
            }
        }
    }

    // MARK: - KVO监听

    /**
     * [EN] Starts observing the scroll view (content offset, size and inset, pan state) and the language change; called
     *      on attach. Override to observe more, and call super. Calling it again does not register twice.
     * [CN] 开始监听滚动视图（偏移、内容尺寸、inset、拖动手势）与语言变化；挂上时调用。可重写以增加监听，并调用 super。重复调用不会重复注册。
     */
    @objc open func addObservers() {
        stopObservingScrollView()
        if let scrollView = scrollView {
            let options: NSKeyValueObservingOptions = [.new, .old]
            let context = CYLRefreshComponentKVO.context
            scrollView.addObserver(self, forKeyPath: CYLRefreshKeyPathContentOffset, options: options, context: context)
            scrollView.addObserver(self, forKeyPath: CYLRefreshKeyPathContentSize, options: options, context: context)
            scrollView.addObserver(self, forKeyPath: CYLRefreshKeyPathContentInset, options: options, context: context)
            observedScrollView = scrollView
            let pan = scrollView.panGestureRecognizer
            pan.addObserver(self, forKeyPath: CYLRefreshKeyPathPanState, options: options, context: context)
            self.pan = pan
        }

        NotificationCenter.default.addObserver(self, selector: #selector(i18nDidChange),
                                               name: .CYLRefreshDidChangeLanguage, object: CYLRefreshConfig.default)
    }

    /**
     * [EN] Stops what `addObservers` started; called on detach. Removes only what is registered, so calling it again is
     *      harmless.
     * [CN] 停止 `addObservers` 开始的监听；离开时调用。只移除已注册的监听，重复调用无害。
     */
    @objc open func removeObservers() {
        stopObservingScrollView()
        NotificationCenter.default.removeObserver(self, name: .CYLRefreshDidChangeLanguage, object: CYLRefreshConfig.default)
    }

    // [EN] Removes the KVO registrations, each once: a scroll view already released (weak, nil) has dropped them itself.
    // [CN] 移除 KVO 注册，每个只移除一次：已释放的滚动视图（弱引用为 nil）已自行丢弃这些注册。
    private func stopObservingScrollView() {
        let context = CYLRefreshComponentKVO.context
        if let scrollView = observedScrollView {
            scrollView.removeObserver(self, forKeyPath: CYLRefreshKeyPathContentOffset, context: context)
            scrollView.removeObserver(self, forKeyPath: CYLRefreshKeyPathContentSize, context: context)
            scrollView.removeObserver(self, forKeyPath: CYLRefreshKeyPathContentInset, context: context)
        }
        observedScrollView = nil
        if let pan = pan {
            pan.removeObserver(self, forKeyPath: CYLRefreshKeyPathPanState, context: context)
        }
        pan = nil
    }

    /**
     * [EN] Dispatches the scroll view's changes to the hooks, the scroll observers and the phase report; changes
     *      registered by others go to super.
     * [CN] 把滚动视图的变化分发给钩子、滚动观察者与阶段通知；其他代码注册的变化交给父类。
     */
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                    change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == CYLRefreshComponentKVO.context else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        // 遇到这些情况就直接返回
        if !isUserInteractionEnabled { return }

        // [EN] The hooks get the change as the Objective-C dictionary (string keys "new", "old", ...).
        // [CN] 钩子收到的变化与 Objective-C 字典相同（字符串 key："new"、"old" 等）。
        var dictionary: [AnyHashable: Any]?
        if let change = change {
            var converted: [AnyHashable: Any] = [:]
            for (key, value) in change { converted[key.rawValue] = value }
            dictionary = converted
        }

        // 这个就算看不见也需要处理
        if keyPath == CYLRefreshKeyPathContentSize {
            scrollViewContentSizeDidChange(dictionary)
        }
        if keyPath == CYLRefreshKeyPathContentInset {
            scrollViewContentInsetDidChange(dictionary)
            return
        }

        // 看不见
        if isHidden && !notifiesWhenHidden { return }
        if keyPath == CYLRefreshKeyPathContentOffset {
            scrollViewContentOffsetDidChange(dictionary)
            let dragging = scrollView?.isDragging == true
            didScroll(withOffset: dragOffset, percent: pullingPercent, dragging: dragging)
            for observer in Array(scrollObservers.values) {
                observer(self, dragOffset, pullingPercent, scrollView?.isDragging == true)
            }
            followPull()
            reportPhaseChange()
        } else if keyPath == CYLRefreshKeyPathPanState {
            if let scrollView = scrollView, scrollView.panGestureRecognizer.state == .began {
                dragStartOffsetY = scrollView.contentOffset.y
            }
            scrollViewPanStateDidChange(dictionary)
        }
    }

    // MARK: Subclass hooks

    /**
     * [EN] Called after the control is attached to `scrollView`; call super.
     * [CN] 控件挂到 `scrollView` 后调用。
     */
    @objc(didAttachToScrollView:)
    open func didAttach(to scrollView: UIScrollView) {}

    /**
     * [EN] Called before the control leaves `scrollView`; call super.
     * [CN] 控件离开 `scrollView` 前调用。
     */
    @objc(willDetachFromScrollView:)
    open func willDetach(from scrollView: UIScrollView) {}

    /**
     * [EN] Called when the scroll view's `contentInset` changes; call super.
     * [CN] 滚动视图的 `contentInset` 变化时调用。
     */
    @objc(scrollViewContentInsetDidChange:)
    open func scrollViewContentInsetDidChange(_ change: [AnyHashable: Any]?) {}

    /**
     * [EN] Called on every scroll with the pulled points, the percent and whether the user drags.
     * [CN] 每次滚动时调用，参数为已拉动点数、百分比以及用户是否在拖动。
     */
    @objc(didScrollWithOffset:percent:dragging:)
    open func didScroll(withOffset offset: CGFloat, percent: CGFloat, dragging: Bool) {}

    /**
     * [EN] Called when `phase` changes.
     * [CN] `phase` 变化时调用。
     */
    @objc(phaseDidChangeFrom:to:)
    open func phaseDidChange(from oldPhase: CYLRefreshPhase, to phase: CYLRefreshPhase) {}

    /**
     * [EN] Called when the refresh ends, with its result; state controls show it here. Call super.
     * [CN] 刷新结束时调用并传入结果；带文字的控件在此显示结果。
     */
    @objc(refreshDidFinishWithSuccess:)
    open func refreshDidFinish(withSuccess success: Bool) {}

    /**
     * [EN] Seconds to stay open after the refresh ends; returns `finishDuration` by default.
     * [CN] 刷新结束后停留的秒数；默认返回 `finishDuration`。
     */
    @objc(finishingDurationWithSuccess:)
    open func finishingDuration(withSuccess success: Bool) -> TimeInterval {
        finishDuration
    }

    /**
     * [EN] Called with YES when a refresh started in code begins and with NO when it ends (CYLRefreshLayout's
     *      `RefreshComponent.onAutoRefresh`), so a control can tell it from a pull.
     * [CN] 由代码开始的刷新开始时以 YES 调用，结束时以 NO 调用（对应 CYLRefreshLayout 的 `RefreshComponent.onAutoRefresh`），
     *      控件据此区分自动刷新与拉动。
     */
    @objc(autoRefreshDidChange:)
    open func autoRefreshDidChange(_ autoRefresh: Bool) {}

    /**
     * [EN] With `supportsHorizontalDrag`, called on every sideways finger move while the control is pulled: `offset` is
     *      the horizontal move in points since the drag began, `percent` the control's `pullingPercent`
     *      (CYLRefreshLayout's `RefreshComponent.onHorizontalDrag`).
     * [CN] 开启 `supportsHorizontalDrag` 后，控件被拉开时手指每次横向移动都会调用：`offset` 为拖动开始后的横向移动点数，`percent`
     *      为控件的 `pullingPercent`（对应 CYLRefreshLayout 的 `RefreshComponent.onHorizontalDrag`）。
     */
    @objc(didDragHorizontallyWithOffset:percent:)
    open func didDragHorizontally(withOffset offset: CGFloat, percent: CGFloat) {}

    /**
     * [EN] Called when a refresh starts in code: return YES when the control opens itself with its own animation
     *      (lasting `duration`), so the scroll view takes its refreshing position without animating; NO (default) lets
     *      the control animate as usual (CYLRefreshLayout's `RefreshComponent.autoOpen`).
     * [CN] 由代码开始刷新时调用：控件用自己的动画（持续 `duration`）打开时返回 YES，滚动视图则不加动画直接到刷新位置；NO（默认）按通常方式
     *      动画（对应 CYLRefreshLayout 的 `RefreshComponent.autoOpen`）。
     */
    @objc(openForAutoRefreshWithDuration:)
    open func openForAutoRefresh(withDuration duration: TimeInterval) -> Bool {
        false
    }

    // MARK: - Internal (the subclasses in this module)

    // [EN] Reports a phase change to the hook, the observers and the haptic tap (the Objective-C `-cyl_reportPhase`).
    // [CN] 把阶段变化通知钩子、观察者并触发轻触反馈（即 Objective-C 的 `-cyl_reportPhase`）。
    func reportPhaseChange() {
        let phase = self.phase
        if phase == reportedPhase { return }
        let old = reportedPhase
        reportedPhase = phase
        if hapticFeedback && phase == .releaseToRefresh {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        phaseDidChange(from: old, to: phase)
        for observer in Array(phaseObservers.values) {
            observer(self, old, phase)
        }
    }

    // [EN] Whether any callback is set, the target-actions of -addTarget:action: included (the start header).
    // [CN] 是否设置了任何回调，包括 -addTarget:action: 的 target-action（起始刷新头使用）。
    var hasCallbacks: Bool {
        refreshingBlock != nil || refreshingHandler != nil || refreshingTarget != nil || !targetActions.isEmpty
    }

    // [EN] Adds `other`'s live target-actions of -addTarget:action: to this component (the start header).
    // [CN] 把 `other` 通过 -addTarget:action: 添加且仍存在的 target-action 加到本控件（起始刷新头使用）。
    func copyTargetActions(from other: CYLRefreshComponent) {
        for pair in other.targetActions {
            if let target = pair.target { addTarget(target, action: pair.action) }
        }
    }

    // [EN] dragRate: the pulled distance as the finger's distance times dragRate, from the offset where the drag began.
    //      Returns the offset to use, or `offsetY` when dragRate is off or the control is not being pulled.
    // [CN] dragRate：拉开距离为手指移动距离乘以 dragRate，从拖动开始时的偏移算起。返回要使用的偏移；dragRate 关闭或未在拉动时返回 `offsetY`。
    func offset(forDragRate offsetY: CGFloat, happenOffset happenOffsetY: CGFloat) -> CGFloat {
        guard let scrollView = scrollView, dragRate > 0, dragRate < 1, scrollView.isDragging else { return offsetY }
        let moved = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let up = pullsUp
        // [EN] Where the content would be with no rubber band; past the edge, scaled by dragRate.
        // [CN] 没有回弹时内容所在的位置；越过边缘的部分乘以 dragRate。
        let natural = dragStartOffsetY - moved
        let over = up ? natural - happenOffsetY : happenOffsetY - natural
        if over <= 0 { return offsetY }
        let target = up ? happenOffsetY + over * dragRate : happenOffsetY - over * dragRate
        if abs(target - offsetY) > 0.5 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: target)
        }
        return target
    }

    // MARK: - Private

    // [EN] YES for controls at the bottom (footers); headers and trailers pull from the other side.
    // [CN] 位于底部的控件（尾部）为 YES；刷新头与尾随控件从另一侧拉开。
    private var pullsUp: Bool {
        self is CYLRefreshFooter
    }

    // 与其他刷新控件互斥
    private func otherComponentIsRefreshing() -> Bool {
        guard let scrollView = scrollView else { return false }
        let others: [CYLRefreshComponent?] = [scrollView.cyl_header, scrollView.cyl_footer, scrollView.cyl_trailer]
        return others.contains { other in
            guard let other = other else { return false }
            return other !== self && other.isRefreshing
        }
    }

    // [EN] Returns YES, after dropping the pull and telling the caller, when this start must wait for another component.
    // [CN] 本次开始必须等待其他控件时，放弃拉动并通知调用方后返回 YES。
    private func holdsBackStartForOtherRefresh() -> Bool {
        if !isExclusiveWithOtherRefresh || isRefreshing || !otherComponentIsRefreshing() { return false }
        if state == .pulling {
            state = .idle
        }
        if let block = blockedByOtherRefreshBlock {
            block()
        }
        return true
    }

    // [EN] Turns the scroll view's touches off while refreshing (disablesContentWhileRefreshing) and back on after.
    // [CN] 刷新期间关闭滚动视图的触摸（disablesContentWhileRefreshing），结束后恢复。
    private func updateContentTouches(for state: CYLRefreshState) {
        let busy = state == .refreshing || state == .willRefresh
        let scrollView = self.scrollView
        if disablesContentWhileRefreshing && busy && !disabledContent && scrollView != nil {
            disabledContent = true
            scrollView?.isUserInteractionEnabled = false
        } else if disabledContent && (!busy || !disablesContentWhileRefreshing) {
            disabledContent = false
            scrollView?.isUserInteractionEnabled = true
        }
    }

    // [EN] On every move: the horizontal drag hook, the pinned view and the translation view.
    // [CN] 每次移动时：横向拖动钩子、固定视图与跟随视图。
    private func followPull() {
        guard let scrollView = scrollView else { return }
        // [EN] The distance pulled past the edge, from the geometry (pullingPercent is not reset once scrolled away).
        // [CN] 越过边缘的拉动距离，按几何位置计算（滚走后 pullingPercent 不会重置）。
        let up = pullsUp
        let inset = scrollViewOriginalInset
        let pulled = up
            ? max(0, scrollView.cyl_offsetY + scrollView.cyl_h
                - max(scrollView.cyl_contentH, scrollView.cyl_h - inset.top - inset.bottom) - inset.bottom)
            : max(0, -(scrollView.cyl_offsetY + inset.top))
        let sign: CGFloat = up ? 1 : -1
        if supportsHorizontalDrag && scrollView.isDragging && pullingPercent > 0 {
            let dx = scrollView.panGestureRecognizer.translation(in: scrollView).x
            didDragHorizontally(withOffset: dx, percent: pullingPercent)
        }
        if let pinned = pinnedView { pinned.transform = CGAffineTransform(translationX: 0, y: sign * pulled) }
        if let translation = translationView { translation.transform = CGAffineTransform(translationX: 0, y: -sign * pulled) }
    }

    // [EN] Applies `colorAccent` to every label, image view and spinner inside the control.
    // [CN] 把 `colorAccent` 应用到控件内的所有文字、图片视图与菊花。
    private func applyThemeColors() {
        guard let accent = colorAccent else { return }
        var views = subviews
        while let view = views.popLast() {
            if let label = view as? UILabel {
                label.textColor = accent
            } else if let indicator = view as? UIActivityIndicatorView {
                indicator.color = accent
            } else {
                view.tintColor = accent
                views.append(contentsOf: view.subviews)
            }
        }
    }
}

// MARK: - CYLRefreshIconLayout (plumbing for CYLRefreshIconAnimating)

extension CYLRefreshComponent {

    /**
     * [EN] The icon, created on first use and following the control's state.
     * [CN] 图标，首次使用时创建并跟随控件状态。
     */
    @objc open var cyl_iconView: CYLRefreshIconView {
        if let iconView = iconViewStorage { return iconView }
        let iconView = CYLRefreshIconView(frame: .zero)
        iconView.update(for: state)
        addSubview(iconView)
        iconViewStorage = iconView
        return iconView
    }

    /**
     * [EN] YES once any icon animation is set.
     * [CN] 设置了任意图标动画后为 YES。
     */
    @objc open var cyl_usesIconView: Bool {
        iconViewStorage?.hasAnimations ?? false
    }

    /**
     * [EN] Sets the icon for a state and lays the control out again; nil removes it.
     * [CN] 设置某个状态的图标并重新布局；nil 表示移除。
     */
    @objc(cyl_setIconAnimationAttributes:forState:)
    open func cyl_setIconAnimation(attributes: [String: Any]? = nil, for state: CYLRefreshState) {
        if attributes == nil && iconViewStorage == nil { return }
        cyl_iconView.setAnimationAttributes(attributes, for: state)
        setNeedsLayout()
    }

    /**
     * [EN] When an icon animation is set: places the icon at `center` with `iconView.iconSize`, shows it when `visible`
     *      and hides `views` (the animation view it replaces). Call at the end of `placeSubviews`. Does nothing otherwise.
     * [CN] 设置了图标动画时：把图标以 `iconView.iconSize` 放在 `center`，`visible` 为 YES 时显示，并隐藏被替换的 `views`（动画视图）。
     *      在 `placeSubviews` 末尾调用；未设置时不做任何事。
     */
    @objc(cyl_placeIconViewAtCenter:visible:replacingViews:)
    open func cyl_placeIconView(at center: CGPoint, visible: Bool, replacing views: [UIView]) {
        if !cyl_usesIconView { return }
        let size = cyl_iconView.iconSize
        cyl_iconView.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        cyl_iconView.center = center
        cyl_updateIconView(visible: visible, replacing: views)
    }

    /**
     * [EN] The same without moving the icon, for the end of `setState:`.
     * [CN] 同上但不移动图标，在 `setState:` 末尾调用。
     */
    @objc(cyl_updateIconViewVisible:replacingViews:)
    open func cyl_updateIconView(visible: Bool, replacing views: [UIView]) {
        if !cyl_usesIconView { return }
        cyl_iconView.isHidden = !visible
        for view in views {
            (view as? UIActivityIndicatorView)?.stopAnimating()
            view.isHidden = true
        }
    }

    /**
     * [EN] When an icon animation is set: shows the icon and `title` as one CYLPlaceholderView centered in the control,
     *      and fades out `labels` (the state and time labels whose text it carries) and hides `views` (the animation
     *      view). When not `visible`, the labels come back and the icon hides. Call at the end of `placeSubviews` and
     *      `setState:`.
     * [CN] 设置了图标动画时：把图标与 `title` 作为一个 CYLPlaceholderView 居中显示在控件中，淡出 `labels`（文字已由它显示的状态与时间
     *      文字），并隐藏 `views`（动画视图）。`visible` 为 NO 时恢复文字并隐藏图标。在 `placeSubviews` 与 `setState:` 末尾调用。
     */
    @objc(cyl_placeIconViewWithTitle:labels:visible:replacingViews:)
    open func cyl_placeIconView(title: String?, labels: [UILabel], visible: Bool, replacing views: [UIView]) {
        if !cyl_usesIconView { return }
        let iconView = cyl_iconView
        let font = labels.first
        iconView.titleFont = font?.font
        iconView.titleColor = font?.textColor
        iconView.title = visible ? title : nil
        // [EN] The labels' text is inside the icon's CYLPlaceholderView: fade them out (keeping `hidden`, the caller's
        //      setting) while it shows, and back when it does not.
        // [CN] 文字已在图标的 CYLPlaceholderView 中：显示时淡出这些文字（保留调用方设置的 `hidden`），不显示时恢复。
        for label in labels {
            label.alpha = visible ? 0 : 1
            label.accessibilityElementsHidden = visible
        }
        // [EN] VoiceOver reads the text from the one view that shows it. [CN] VoiceOver 从显示文字的那个视图读取文字。
        let speaks = visible && (title?.isEmpty == false)
        iconView.accessibilityElementsHidden = !speaks
        iconView.isAccessibilityElement = speaks
        iconView.accessibilityLabel = speaks ? title : nil
        iconView.accessibilityTraits = speaks ? .updatesFrequently : .none
        let size = iconView.fittingSize
        iconView.bounds = CGRect(x: 0, y: 0, width: min(size.width, bounds.width), height: size.height)
        iconView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        cyl_updateIconView(visible: visible, replacing: views)
    }

    /**
     * [EN] MJRefresh's image sequences (`setAnimationImages:` / `setImages:`) as the icon of a state, drawn by the icon's
     *      CYLPlaceholderView like any other icon: several images play as one animated image of `duration` seconds; the
     *      idle state shows one frame, chosen by `cyl_showIconImageFrameOf:pullingPercent:`. The idle state, when it has
     *      no icon yet, gets the first image as a still frame. With Reduce Motion on, the first image stays still.
     * [CN] MJRefresh 的图片序列（`setAnimationImages:` / `setImages:`）作为某个状态的图标，与其他图标一样由图标的 CYLPlaceholderView
     *      绘制：多张图片作为一张时长 `duration` 秒的动画图片播放；空闲状态只显示一帧，由 `cyl_showIconImageFrameOf:pullingPercent:`
     *      选择。空闲状态尚无图标时，以第一张图片作为静止帧。开启“减弱动态效果”时，第一张图片保持静止。
     */
    @objc(cyl_setIconImages:duration:forState:)
    open func cyl_setIconImages(_ images: [UIImage], duration: TimeInterval, for state: CYLRefreshState) {
        // [EN] Checked through NSArray: an Objective-C array may hold something else. [CN] 通过 NSArray 检查：Objective-C 数组可能含有其他对象。
        guard let first = (images as NSArray).firstObject as? UIImage else { return }
        if state != .idle && cyl_iconView.animationAttributes(for: .idle) == nil {
            cyl_iconView.setAnimationAttributes([CYLPlaceholderItemImage: first], for: .idle)
        }
        // [EN] The idle state shows one frame (chosen by the pull); the other states hand the sequence to
        //      CYLPlaceholderView, which plays every kind of animation (and keeps the first frame with Reduce Motion).
        // [CN] 空闲状态只显示一帧（由下拉进度选择）；其他状态把图片序列交给 CYLPlaceholderView，它负责播放所有类型的动效（“减弱动态效果”时保留第一帧）。
        let attributes: [String: Any] = state == .idle || images.count == 1
            ? [CYLPlaceholderItemImage: first]
            : [CYLPlaceholderItemImages: images,
               CYLPlaceholderItemAnimationDuration: NSNumber(value: duration > 0 ? duration : Double(images.count) * 0.1)]
        cyl_setIconAnimation(attributes: attributes, for: state)
    }

    /**
     * [EN] The one implementation of `setAnimationImages:duration:forState:` for the animation header and both
     *      animation footers: keeps the images of `state`, grows the control to the tallest image and shows them as the
     *      icon (`cyl_setIconImages:duration:forState:`). nil is ignored.
     * [CN] 动画刷新头与两种动画尾部的 `setAnimationImages:duration:forState:` 的唯一实现：保存 `state` 的图片，控件高度随最高的图片
     *      增大，并作为图标显示（`cyl_setIconImages:duration:forState:`）。nil 被忽略。
     */
    @objc(cyl_setAnimationImages:duration:forState:)
    open func cyl_setAnimationImages(_ images: [UIImage]?, duration: TimeInterval, for state: CYLRefreshState) {
        guard let images = images else { return }
        animationImageTable[state] = images
        // [EN] The control grows to the tallest image, as in MJRefresh. [CN] 控件高度随最高的图片增大，与 MJRefresh 相同。
        if let image = (images as NSArray).firstObject as? UIImage, image.size.height > cyl_h {
            cyl_h = image.size.height
        }
        cyl_setIconImages(images, duration: duration, for: state)
    }

    /**
     * [EN] The images set for `state` with `cyl_setAnimationImages:duration:forState:`, or nil.
     * [CN] 用 `cyl_setAnimationImages:duration:forState:` 为 `state` 设置的图片，或 nil。
     */
    @objc(cyl_animationImagesForState:)
    open func cyl_animationImages(for state: CYLRefreshState) -> [UIImage]? {
        animationImageTable[state]
    }

    /**
     * [EN] While idle, shows the idle images' frame for the current `pullingPercent`.
     * [CN] 空闲时显示空闲图片中与当前 `pullingPercent` 对应的帧。
     */
    @objc open func cyl_showIdleAnimationFrame() {
        cyl_showIconImageFrame(of: cyl_animationImages(for: .idle), pullingPercent: pullingPercent)
    }

    /**
     * [EN] The one implementation of `CYLRefreshIconAnimating`'s `setIconAnimationFilePath:size:forState:`.
     * [CN] `CYLRefreshIconAnimating` 的 `setIconAnimationFilePath:size:forState:` 的唯一实现。
     */
    @objc(cyl_setIconAnimationFilePath:size:forState:)
    open func cyl_setIconAnimation(filePath: String, size: CGSize, for state: CYLRefreshState) {
        if let attributes = CYLRefreshIconView.attributes(forAnimationFilePath: filePath, size: size) {
            cyl_setIconAnimation(attributes: attributes, for: state)
        }
    }

    /**
     * [EN] The one implementation of `CYLRefreshIconAnimating`'s `setBundledIconAnimation:size:forState:`.
     * [CN] `CYLRefreshIconAnimating` 的 `setBundledIconAnimation:size:forState:` 的唯一实现。
     */
    @objc(cyl_setBundledIconAnimation:size:forState:)
    open func cyl_setBundledIconAnimation(_ fileName: String, size: CGSize, for state: CYLRefreshState) {
        if let attributes = CYLRefreshIconView.attributes(forBundledAnimation: fileName, size: size) {
            cyl_setIconAnimation(attributes: attributes, for: state)
        }
    }

    /**
     * [EN] While idle, shows the frame of `images` that matches `pullingPercent`, as MJRefresh does while pulling.
     * [CN] 空闲时显示 `images` 中与 `pullingPercent` 对应的那一帧，与 MJRefresh 下拉时的做法相同。
     */
    @objc(cyl_showIconImageFrameOf:pullingPercent:)
    open func cyl_showIconImageFrame(of images: [UIImage]?, pullingPercent: CGFloat) {
        guard let images = images, state == .idle, !images.isEmpty, let iconView = iconViewStorage else { return }
        let percent = pullingPercent.isFinite ? max(0, pullingPercent) : 0
        let index = min(Int(CGFloat(images.count) * percent), images.count - 1)
        // [EN] The frame goes straight into CYLPlaceholderView's own image view: rebuilding the view from attributes on
        //      every pull step would restart it many times a second. [CN] 帧直接写入 CYLPlaceholderView 自己的图片视图：每次下拉都用
        //      属性重建视图，每秒会重建很多次。
        iconView.placeholderView?.imageView.image = (images as NSArray)[index] as? UIImage
    }
}

// MARK: - CYLRefreshStateTitles

extension CYLRefreshComponent {

    /**
     * [EN] Sets the text of `state`; nil is ignored, as in `setTitle:forState:`.
     * [CN] 设置 `state` 的文字；nil 被忽略，与 `setTitle:forState:` 相同。
     */
    @objc(cyl_setStateTitle:forState:)
    open func cyl_setStateTitle(_ title: String?, for state: CYLRefreshState) {
        guard let title = title else { return }
        stateTitleTable[state] = title
    }

    /**
     * [EN] The text of `state`, or nil.
     * [CN] `state` 的文字，或 nil。
     */
    @objc(cyl_stateTitleForState:)
    open func cyl_stateTitle(for state: CYLRefreshState) -> String? {
        stateTitleTable[state]
    }
}

// MARK: - ChainingGrammar (为 Swift 扩展链式语法)

extension CYLRefreshComponent {

    /**
     * [EN] Sets `automaticallyChangeAlpha` and returns the control.
     * [CN] 自动变化透明度
     */
    @objc(cyl_autoChangeTransparency:)
    @discardableResult
    open func cyl_autoChangeTransparency(_ isAutoChange: Bool) -> Self {
        isAutomaticallyChangeAlpha = isAutoChange
        return self
    }

    /**
     * [EN] Sets `beginRefreshingCompletionBlock` (called right after the refresh starts) and returns the control.
     * [CN] 刷新开始后立即调用的回调
     */
    @objc(cyl_afterBeginningAction:)
    @discardableResult
    open func cyl_(afterBeginningAction action: @escaping CYLRefreshComponentAction) -> Self {
        beginRefreshingCompletionBlock = action
        return self
    }

    /**
     * [EN] Sets `endRefreshingAnimationBeginAction` (called when the end animation begins) and returns the control.
     * [CN] 刷新动画开始后立即调用的回调
     */
    @objc(cyl_endingAnimationBeginningAction:)
    @discardableResult
    open func cyl_endingAnimationBeginningAction(_ action: @escaping CYLRefreshComponentAction) -> Self {
        endRefreshingAnimationBeginAction = action
        return self
    }

    /**
     * [EN] Sets `endRefreshingCompletionBlock` (called right after the refresh ends) and returns the control.
     * [CN] 刷新结束后立即调用的回调
     */
    @objc(cyl_afterEndingAction:)
    @discardableResult
    open func cyl_(afterEndingAction action: @escaping CYLRefreshComponentAction) -> Self {
        endRefreshingCompletionBlock = action
        return self
    }

    /**
     * [EN] Sets the control as `scrollView`'s header, footer or trailer; the base does nothing, the subclasses must
     *      implement it. Returns the control.
     * [CN] 需要子类必须实现：赋值给 ScrollView 的 Header/Footer/Trailer；基类不做任何事。返回控件本身。
     */
    @objc(cyl_linkTo:)
    @discardableResult
    open func cyl_link(to scrollView: UIScrollView) -> Self {
        self
    }
}

// MARK: - UILabel (CYLRefresh)

extension UILabel {

    /**
     * [EN] A label styled as the refresh controls' texts: `CYLRefreshLabelFont`, `CYLRefreshLabelTextColor`, centered,
     *      clear background, flexible width (Objective-C `+cyl_label`).
     * [CN] 按刷新控件文字样式创建的 label：`CYLRefreshLabelFont`、`CYLRefreshLabelTextColor`、居中、透明背景、宽度自适应
     *      （Objective-C 的 `+cyl_label`）。
     */
    @objc(cyl_label)
    open class func cyl_() -> Self {
        let label = self.init()
        // [EN] CYLRefreshLabelFont and CYLRefreshLabelTextColor (macros of CYLRefreshConst.h).
        // [CN] 即 CYLRefreshConst.h 的宏 CYLRefreshLabelFont 与 CYLRefreshLabelTextColor。
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor(red: 90 / 255.0, green: 90 / 255.0, blue: 90 / 255.0, alpha: 1.0)
        label.autoresizingMask = .flexibleWidth
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }

    /**
     * [EN] The width the label's text (or attributed text) needs on one line, in points; 0 when it is empty.
     * [CN] label 的文字（或富文本）单行显示所需的宽度（点）；为空时为 0。
     */
    @objc open func cyl_textWidth() -> CGFloat {
        let size = CGSize(width: CGFloat(Float.greatestFiniteMagnitude), height: CGFloat(Float.greatestFiniteMagnitude))
        if let attributedText = attributedText {
            if attributedText.length == 0 { return 0 }
            return attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size.width
        }
        guard let text = text, !text.isEmpty else { return 0 }
        assert(font != nil, "请检查 cyl_label's `font` 是否设置正确")
        return (text as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin,
                                               attributes: [.font: font as Any], context: nil).size.width
    }
}
