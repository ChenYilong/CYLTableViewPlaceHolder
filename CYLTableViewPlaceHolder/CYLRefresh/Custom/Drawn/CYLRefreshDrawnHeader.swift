//
//  CYLRefreshDrawnHeader.swift
//  CYLRefresh
//
//  The CYLRefresh styles' subclass API on top of CYLRefresh's phases. The status order and the hook timing follow
//  the CYLRefresh styles' UIRefreshHeader (third-party refresh code, MIT, see LICENSE.refresh-third-party.txt).
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 9), with the same Objective-C API (class name, selectors,
//      the former `NS_SWIFT_NAME` spellings as the Swift names, the overridable hooks `open`). The variadic
//      `-inStatus:` cannot be `@objc` in Swift: it stays an Objective-C category (`CYLRefreshDrawnHeader+CYLStatusList.h`,
//      `CYLRefreshDrawnHeaderSupport.m`), and Swift uses `isIn(statuses:)`. The driven mode that `CYLRefreshDrawnFooter`
//      uses is internal.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 9 步），Objective-C API 不变（类名、选择器、原 `NS_SWIFT_NAME`
//      写法作为 Swift 名称、可重写的钩子为 `open`）。可变参数的 `-inStatus:` 在 Swift 中不能标为 `@objc`：它保留为 Objective-C 分类
//      （`CYLRefreshDrawnHeader+CYLStatusList.h`、`CYLRefreshDrawnHeaderSupport.m`），Swift 使用 `isIn(statuses:)`。
//      `CYLRefreshDrawnFooter` 使用的被驱动模式为 internal。

import UIKit

/**
 * [EN] A header whose look is drawn in code (Core Graphics, layers or SpriteKit). Subclasses override the
 *      style-named hooks below; the base maps CYLRefresh's phases onto them in the CYLRefresh styles' order
 *      (pull, release, releasing, refreshing, finish, idle).
 * [CN] 用代码绘制外观（Core Graphics、图层或 SpriteKit）的刷新头。子类重写下面以 CYLRefresh styles 命名的钩子；基类按
 *      CYLRefresh styles 的顺序（下拉、松开、释放中、刷新中、结束、空闲）把 CYLRefresh 的阶段映射到这些钩子上。
 */
@objc(CYLRefreshDrawnHeader)
open class CYLRefreshDrawnHeader: CYLRefreshHeader {

    private var storedStatus: CYLRefreshPhase = .idle
    // [EN] The offset last passed to the scroll hooks. [CN] 上次传给滚动钩子的偏移。
    private var lastOffset: CGFloat = -1
    // [EN] YES after a style turned user interaction off: touches pass through. [CN] 样式关闭用户交互后为 YES：触摸穿透。
    private var passesTouches = false
    // [EN] Driven by a CYLRefreshDrawnFooter: the values below replace the scroll view's.
    // [CN] 由 CYLRefreshDrawnFooter 驱动：下列值代替滚动视图的值。
    private var driven = false
    // [EN] The footer that hosts this header (its hold is the one that matters when driven). [CN] 内嵌此刷新头的刷新尾（被驱动时起作用的停留属于它）。
    private weak var drivenHost: CYLRefreshComponent?
    private var drivenOffset: CGFloat = 0
    private var drivenSuccess = false
    private var drivenFrame: CGRect = .zero
    // [EN] The driving footer's scroll view, passed to the scroll hooks (the header itself is not in a scroll view).
    // [CN] 驱动它的刷新尾所在的滚动视图，传给滚动钩子（刷新头本身不在滚动视图中）。
    private weak var drivenScrollView: UIScrollView?

    /**
     * [EN] Duration of the styles' short animations, in seconds. Default 0.1. [CN] 样式短动画的时长（秒），默认 0.1。
     */
    @objc open var durationFast: TimeInterval = 0.1

    /**
     * [EN] Duration of the styles' normal animations, in seconds. Default 0.25. [CN] 样式普通动画的时长（秒），默认 0.25。
     */
    @objc open var durationNormal: TimeInterval = 0.25

    /**
     * [EN] Sets the defaults and calls `setUpComponent`. [CN] 设置默认值并调用 `setUpComponent`。
     */
    open override func prepare() {
        super.prepare()
        storedStatus = .idle
        durationFast = 0.1
        durationNormal = 0.25
        lastOffset = -1
        colorAccent = .darkGray
        setUpComponent()
    }

    /**
     * [EN] Set-up hook, called once from `prepare`; subclasses call super. [CN] 初始化钩子，由 `prepare` 调用一次；子类需调用 super。
     */
    @objc open func setUpComponent() {}

    // MARK: - Touches

    /**
     * [EN] Styles turn user interaction off so touches reach the list (the CYLRefresh styles' Material, WaveSwipe), but
     *      CYLRefresh, like MJRefresh, stops following the scroll view when it is off. It stays on and touches pass
     *      through instead. [CN] 样式关闭用户交互是为了让触摸到达列表（CYLRefresh styles 的 Material、WaveSwipe），但
     *      CYLRefresh 与 MJRefresh 一样，在交互关闭时停止跟随滚动视图。因此保持开启，改为让触摸穿透。
     */
    open override var isUserInteractionEnabled: Bool {
        get { super.isUserInteractionEnabled }
        set {
            passesTouches = !newValue
            super.isUserInteractionEnabled = true
        }
    }

    /**
     * [EN] Passes touches through after a style turned user interaction off. [CN] 样式关闭用户交互后让触摸穿透。
     */
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        passesTouches ? nil : super.hitTest(point, with: event)
    }

    // MARK: - Colors

    /**
     * [EN] In CYLRefresh styles `colorPrimary` is a color the styles draw with, not the view's background: the
     *      background stays clear, or a style's drawing (Material's spinner, WaveSwipe's wave) is covered by a solid
     *      rectangle. [CN] CYLRefresh styles 中 `colorPrimary` 是样式绘制时使用的颜色，不是视图背景：保持背景透明，否则样式的
     *      绘制（Material 的圆圈、WaveSwipe 的波浪）会被纯色矩形盖住。
     */
    open override var colorPrimary: UIColor? {
        get { super.colorPrimary }
        set {
            super.colorPrimary = newValue
            backgroundColor = .clear
        }
    }

    // MARK: - Size

    /**
     * [EN] The frame width. [CN] frame 宽度。
     */
    @objc open var width: CGFloat {
        get { cylW }
        set { cylW = newValue }
    }

    /**
     * [EN] The open height; setting it calls `setExpandHeight:`. Reading it returns the frame height, which follows the
     *      pull in stretch mode. [CN] 展开高度；设置时调用 `setExpandHeight:`。读取时返回 frame 高度，拉伸模式下随下拉变化。
     */
    @objc open var height: CGFloat {
        get { cylH }
        set { setExpandHeight(newValue) }
    }

    /**
     * [EN] Points pulled below the content's top, the open height included while refreshing.
     * [CN] 被拉出内容顶部的点数，刷新中包含展开高度。
     */
    open override var dragOffset: CGFloat {
        if driven { return drivenOffset }
        guard let scrollView = scrollView else { return 0 }
        return max(0, -(scrollView.cylOffsetY + scrollViewOriginalInset.top))
    }

    /**
     * [EN] `dragOffset` / (`expandHeight` × `triggerRate`). [CN] `dragOffset` / (`expandHeight` × `triggerRate`)。
     */
    @objc open var dragPercent: CGFloat {
        dragOffset / max(1, expandHeight * triggerRate)
    }

    /**
     * [EN] Whether the last refresh succeeded (`lastRefreshSucceeded`). [CN] 上一次刷新是否成功（`lastRefreshSucceeded`）。
     */
    @objc open var isSuccess: Bool {
        driven ? drivenSuccess : lastRefreshSucceeded
    }

    /**
     * [EN] A driven header refreshes while its status is refreshing. [CN] 被驱动的刷新头在状态为刷新中时处于刷新。
     */
    open override var isRefreshing: Bool {
        if driven { return status == .refreshing }
        return super.isRefreshing
    }

    // MARK: - Status

    /**
     * [EN] The phase as CYLRefresh styles reports it: `CYLRefreshPhaseReleasing` is always passed through before
     *      refreshing, and `CYLRefreshPhaseFinishing` after it. [CN] 按 CYLRefresh styles 的方式报告的阶段：刷新前一定经过
     *      `CYLRefreshPhaseReleasing`，刷新后一定经过 `CYLRefreshPhaseFinishing`。
     */
    @objc open private(set) var status: CYLRefreshPhase {
        get { storedStatus }
        set {
            let old = storedStatus
            if old == newValue { return }
            storedStatus = newValue
            if scrollView != nil || driven { onStatus(old, changed: newValue) }
        }
    }

    /**
     * [EN] YES when `status` is one of `statuses` (the Swift form of the Objective-C `-inStatus:`, whose list ends
     *      with 0). [CN] `status` 为 `statuses` 之一时为 YES（Objective-C `-inStatus:` 的 Swift 写法，后者的列表以 0 结尾）。
     */
    public func isIn(statuses: [CYLRefreshPhase]) -> Bool {
        statuses.contains(status)
    }

    /**
     * [EN] `status` changed. [CN] `status` 变化。
     */
    @objc(onStatus:changed:)
    open func onStatus(_ oldStatus: CYLRefreshPhase, changed status: CYLRefreshPhase) {
        // [EN] As in CYLRefresh styles, the start hooks run on the next main-queue turn.
        // [CN] 与 CYLRefresh styles 相同，开始钩子在下一次主队列循环中执行。
        if status == .releasing {
            DispatchQueue.main.async { self.onStartAnimationWhenRealeasing() }
        } else if status == .refreshing {
            DispatchQueue.main.async { self.onStartAnimationWhenRefreshing() }
        }
    }

    /**
     * [EN] Maps CYLRefresh's phases onto the styles' status order. [CN] 把 CYLRefresh 的阶段映射为样式的状态顺序。
     */
    open override func phaseDidChange(from oldPhase: CYLRefreshPhase, to phase: CYLRefreshPhase) {
        super.phaseDidChange(from: oldPhase, to: phase)
        switch phase {
        case .refreshing:
            // [EN] CYLRefresh may go straight to refreshing; CYLRefresh styles always passes through releasing.
            // [CN] CYLRefresh 可能直接进入刷新中；CYLRefresh styles 一定先经过释放中。
            if status != .releasing { status = .releasing }
            status = .refreshing
        case .idle:
            // [EN] After a refresh, stay in finish until the header has retracted. [CN] 刷新后保持结束状态，直到刷新头收回。
            if status == .refreshing { status = .finishing }
            if status != .finishing || dragOffset <= 0.5 { status = .idle }
        default:
            status = phase
        }
    }

    // MARK: - Scrolling

    /**
     * [EN] Leaves finish once retracted and calls the scroll hooks when the offset changed.
     * [CN] 收回后离开结束状态，并在偏移变化时调用滚动钩子。
     */
    open override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        let offset = dragOffset
        if status == .finishing && state == .idle && offset <= 0.5 {
            status = .idle
        }
        if offset == lastOffset { return }
        lastOffset = offset
        guard let scrollView = scrollView else { return }
        self.scrollView(scrollView, didScroll: offset, percent: dragPercent, drag: scrollView.isDragging)
    }

    /**
     * [EN] Every scroll, with `dragOffset`, `dragPercent` and whether the user drags; calls `onScrollingWithOffset:…`.
     * [CN] 每次滚动时调用，参数为 `dragOffset`、`dragPercent` 与是否在拖动；会调用 `onScrollingWithOffset:…`。
     */
    @objc(scrollView:didScroll:percent:drag:)
    open func scrollView(_ scrollView: UIScrollView, didScroll offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        onScrolling(withOffset: offset, percent: percent, drag: isDragging)
    }

    /**
     * [EN] Every scroll; draw the pull here. [CN] 每次滚动时调用；在这里绘制下拉过程。
     */
    @objc(onScrollingWithOffset:percent:drag:)
    open func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {}

    /**
     * [EN] The user released past the trigger point (or `beginRefreshing` was called). [CN] 用户越过触发点松手（或调用了 `beginRefreshing`）。
     */
    @objc open func onStartAnimationWhenRealeasing() {}

    /**
     * [EN] The refresh started. [CN] 刷新开始。
     */
    @objc open func onStartAnimationWhenRefreshing() {}

    /**
     * [EN] The refresh ended with `success`. [CN] 刷新以 `success` 结束。
     */
    @objc(onRefreshFinished:)
    open func onRefreshFinished(_ success: Bool) {}

    /**
     * [EN] Seconds to stay open after the refresh ends; `finishDuration` by default. [CN] 刷新结束后停留的秒数；默认为 `finishDuration`。
     */
    @objc(onRefreshFinishing:)
    open func onRefreshFinishing(_ success: Bool) -> CGFloat {
        CGFloat(finishDuration)
    }

    // MARK: - Attaching

    /**
     * [EN] Calls `scrollView:attached:` with YES. [CN] 以 YES 调用 `scrollView:attached:`。
     */
    open override func didAttach(to scrollView: UIScrollView) {
        super.didAttach(to: scrollView)
        self.scrollView(scrollView, attached: true)
    }

    /**
     * [EN] Calls `scrollView:attached:` with NO. [CN] 以 NO 调用 `scrollView:attached:`。
     */
    open override func willDetach(from scrollView: UIScrollView) {
        self.scrollView(scrollView, attached: false)
        super.willDetach(from: scrollView)
    }

    /**
     * [EN] The header was attached to or detached from `scrollView`. [CN] 刷新头挂到或离开 `scrollView`。
     */
    @objc(scrollView:attached:)
    open func scrollView(_ scrollView: UIScrollView, attached attach: Bool) {}

    // MARK: - Refreshing

    /**
     * [EN] `beginRefreshing`, under the CYLRefresh styles' name. [CN] 即 `beginRefreshing`（CYLRefresh styles 的名字）。
     */
    @objc open func beginRefresh() {
        beginRefreshing()
    }

    /**
     * [EN] `endRefreshing`, under the CYLRefresh styles' name. [CN] 即 `endRefreshing`（CYLRefresh styles 的名字）。
     */
    @objc open func finishRefresh() {
        finishRefresh(withSuccess: true)
    }

    /**
     * [EN] Routes every end through the CYLRefresh styles' name, so styles that override it see every refresh end.
     * [CN] 所有结束都经过 CYLRefresh styles 的方法名，重写它的样式能收到每一次结束。
     */
    open override func endRefreshing(success: Bool) {
        finishRefresh(withSuccess: success)
    }

    /**
     * [EN] `endRefreshingWithSuccess:`, under the CYLRefresh styles' name. [CN] 即 `endRefreshingWithSuccess:`（CYLRefresh styles 的名字）。
     */
    @objc(finishRefreshWithSuccess:)
    open func finishRefresh(withSuccess success: Bool) {
        super.endRefreshing(success: success)
    }

    /**
     * [EN] Moves to finish and calls `onRefreshFinished:`. [CN] 进入结束状态并调用 `onRefreshFinished:`。
     */
    open override func refreshDidFinish(withSuccess success: Bool) {
        super.refreshDidFinish(withSuccess: success)
        status = .finishing
        onRefreshFinished(success)
    }

    /**
     * [EN] Asks `onRefreshFinishing:`. [CN] 询问 `onRefreshFinishing:`。
     */
    open override func finishingDuration(withSuccess success: Bool) -> TimeInterval {
        TimeInterval(onRefreshFinishing(success))
    }

    // MARK: - Driven by a footer

    /**
     * [EN] The header's layout moves it above its superview; a driven header keeps the frame its footer gave it.
     * [CN] 刷新头的布局会把它移到父视图上方；被驱动时保持刷新尾给它的 frame。
     */
    open override func placeSubviews() {
        super.placeSubviews()
        if driven && frame != drivenFrame { frame = drivenFrame }
    }

    // [EN] Called once by CYLRefreshDrawnFooter when it hosts the header. [CN] CYLRefreshDrawnFooter 内嵌刷新头时调用一次。
    func beginDriven(host: CYLRefreshComponent? = nil) {
        drivenHost = host
        driven = true
        autoHideRefresh = false
        isUserInteractionEnabled = false
    }

    func driveFrame(_ frame: CGRect) {
        drivenFrame = frame
        if self.frame != frame { self.frame = frame }
    }

    func driveOffset(_ offset: CGFloat, drag isDragging: Bool, in scrollView: UIScrollView?) {
        if offset == drivenOffset && offset == lastOffset { return }
        drivenOffset = offset
        lastOffset = offset
        if let scrollView = scrollView { drivenScrollView = scrollView }
        if let scrollView = self.scrollView ?? drivenScrollView {
            self.scrollView(scrollView, didScroll: offset, percent: dragPercent, drag: isDragging)
        }
        setNeedsDisplay()
    }

    // [EN] The style's end animation reached its end: retract now instead of when `onRefreshFinishing:` runs out (that time is only
    //      the longest hold). [CN] 样式的结束动画已播放完毕：立即收回，而不是等 `onRefreshFinishing:` 的时间用完（该时间只是最长停留）。
    func finishAnimationDidEnd() {
        (drivenHost ?? self).endFinishingHold()
    }

    func driveStatus(_ status: CYLRefreshPhase) {
        self.status = status
        setNeedsDisplay()
    }

    func driveFinished(_ success: Bool) {
        drivenSuccess = success
        status = .finishing
        onRefreshFinished(success)
    }
}
