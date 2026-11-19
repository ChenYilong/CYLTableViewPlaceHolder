//
//  CYLRefreshTrailer.swift
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-20 (docs/Swift-Migration.md, step 11), with the same Objective-C API (the factories
//      `+trailerWithRefreshingBlock:` / `+trailerWithRefreshingTarget:refreshingAction:`, which Swift spells as the
//      initializers `init(refreshingBlock:)` / `init(refreshingTarget:refreshingAction:)` as before,
//      `ignoredScrollViewContentInsetRight`, `automaticallyRefresh` with its `isAutomaticallyRefresh` getter,
//      `triggerAutomaticallyRefreshPercent`, `autoTriggerTimes`) and the same behavior: the horizontal pull and release,
//      the right inset while refreshing, the automatic trailer once per drag, the bounce settings given back on removal.
// [CN] 自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 11 步），Objective-C API（工厂方法 `+trailerWithRefreshingBlock:` /
//      `+trailerWithRefreshingTarget:refreshingAction:`，Swift 仍写作初始化方法 `init(refreshingBlock:)` / `init(refreshingTarget:refreshingAction:)`；
//      `ignoredScrollViewContentInsetRight`、getter 为 `isAutomaticallyRefresh` 的 `automaticallyRefresh`、`triggerAutomaticallyRefreshPercent`、
//      `autoTriggerTimes`）与行为均不变：横向拉动并松手、刷新时的右侧 inset、自动 trailer 每次拖动触发一次、移除时恢复回弹设置。

import UIKit

/**
 * [EN] The base class of the horizontal controls at the trailing end of the content: swiping past the end and
 *      releasing runs the refreshing callback (for example to open details); set one as a scroll view's
 *      `cyl_trailer`.
 * [CN] 位于内容末端的横向控件基类：越过末端滑动并松手时执行刷新回调（例如打开详情）；设为滚动视图的 `cyl_trailer` 使用。
 */
@objc(CYLRefreshTrailer)
open class CYLRefreshTrailer: CYLRefreshComponent {

    // MARK: - Private state

    private var lastRefreshCount = 0
    private var lastRightDelta: CGFloat = 0
    private var previousHorizontalBounce = false
    private var previousVerticalBounce = false
    private var refreshGeneration: UInt = 0
    // [EN] The current refresh was started automatically by a drag. [CN] 当前刷新由拖动自动触发。
    private var triggerByDrag = false
    private var leftTriggerTimes = 0
    private var storedAutomaticallyRefresh = false
    private var storedAutoTriggerTimes = 0

    // MARK: - Factories

    /**
     * [EN] Creates a trailer that calls `refreshingBlock` when it refreshes (Objective-C `+trailerWithRefreshingBlock:`).
     * [CN] 创建trailer，刷新时调用 `refreshingBlock`（Objective-C 的 `+trailerWithRefreshingBlock:`）。
     */
    public convenience init(refreshingBlock: @escaping CYLRefreshComponentAction) {
        self.init()
        self.refreshingBlock = refreshingBlock
    }

    /**
     * [EN] Creates a trailer that sends `action` to `target` when it refreshes (Objective-C
     *      `+trailerWithRefreshingTarget:refreshingAction:`).
     * [CN] 创建trailer，刷新时向 `target` 发送 `action`（Objective-C 的 `+trailerWithRefreshingTarget:refreshingAction:`）。
     */
    public convenience init(refreshingTarget target: Any, refreshingAction action: Selector) {
        self.init()
        setRefreshingTarget(target, refreshingAction: action)
    }

    /**
     * [EN] Objective-C: `+trailerWithRefreshingBlock:`; returns an instance of the class it is sent to.
     * [CN] Objective-C：`+trailerWithRefreshingBlock:`；返回接收消息的类的实例。
     */
    @objc(trailerWithRefreshingBlock:)
    @available(swift, obsoleted: 1, message: "Use init(refreshingBlock:)")
    open class func objcTrailer(refreshingBlock: @escaping CYLRefreshComponentAction) -> Self {
        let cmp = self.init()
        cmp.refreshingBlock = refreshingBlock
        return cmp
    }

    /**
     * [EN] Objective-C: `+trailerWithRefreshingTarget:refreshingAction:`; returns an instance of the class it is sent to.
     * [CN] Objective-C：`+trailerWithRefreshingTarget:refreshingAction:`；返回接收消息的类的实例。
     */
    @objc(trailerWithRefreshingTarget:refreshingAction:)
    @available(swift, obsoleted: 1, message: "Use init(refreshingTarget:refreshingAction:)")
    open class func objcTrailer(refreshingTarget target: Any, refreshingAction action: Selector) -> Self {
        let cmp = self.init()
        cmp.setRefreshingTarget(target, refreshingAction: action)
        return cmp
    }

    // MARK: - Public properties

    /**
     * [EN] How much of the scroll view's right content inset to ignore (points).
     * [CN] 忽略多少scrollView的contentInset的right。
     */
    @objc open var ignoredScrollViewContentInsetRight: CGFloat = 0

    /**
     * Whether scrolling to the end starts refreshing without a release (default NO, which keeps the pull-and-release behavior).
     * Only applies when the content is wider than the scroll view.
     */
    @objc(automaticallyRefresh)
    open var isAutomaticallyRefresh: Bool {
        @objc(isAutomaticallyRefresh) get { storedAutomaticallyRefresh }
        @objc(setAutomaticallyRefresh:) set { storedAutomaticallyRefresh = newValue }
    }

    /**
     * How much of the trailer must be visible before it refreshes automatically (default 1.0, fully visible).
     */
    @objc open var triggerAutomaticallyRefreshPercent: CGFloat = 0

    /**
     * Automatic refreshes allowed per drag (default 1); -1 means unlimited. Scrolling without a drag is not limited.
     */
    @objc open var autoTriggerTimes: Int {
        get { storedAutoTriggerTimes }
        set {
            storedAutoTriggerTimes = newValue
            leftTriggerTimes = newValue
        }
    }

    // MARK: - Overrides of CYLRefreshComponent

    /**
     * [EN] Sets the defaults: refreshes automatically (when turned on) once fully shown, once per drag.
     * [CN] 设置默认值：（开启时）完全出现后自动刷新，每次拖动一次。
     */
    open override func prepare() {
        super.prepare()

        triggerAutomaticallyRefreshPercent = 1.0
        autoTriggerTimes = 1
    }

    /**
     * [EN] Follows the horizontal pull: arms, refreshes on release or automatically. [CN] 跟随横向拉动：触发，松手或自动刷新。
     */
    open override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentOffsetDidChange(change)

        // 如果正在刷新，直接返回
        if state == .refreshing { return }

        guard let scrollView = scrollView else { return }
        scrollViewOriginalInset = scrollView.cyl_inset

        // 当前的contentOffset
        let currentOffsetX = scrollView.cyl_offsetX
        // 尾部控件刚好出现的offsetX
        let happenOffsetX = self.happenOffsetX
        // 如果是向右滚动到看不见右边控件，直接返回
        if currentOffsetX <= happenOffsetX { return }

        let pullingPercent = (currentOffsetX - happenOffsetX) / (cyl_w * triggerRate)

        // 如果已全部加载，仅设置pullingPercent，然后返回
        if state == .noMoreData {
            self.pullingPercent = pullingPercent
            return
        }

        if shouldAutomaticallyRefresh(change: change, pullingPercent: pullingPercent) {
            triggerByDrag = scrollView.isDragging
            beginRefreshing()
            return
        }

        if scrollView.isDragging {
            self.pullingPercent = pullingPercent
            // 普通 和 即将刷新 的临界点
            let normal2pullingOffsetX = happenOffsetX + cyl_w * triggerRate

            if state == .idle && currentOffsetX > normal2pullingOffsetX {
                state = .pulling
            } else if state == .pulling && currentOffsetX <= normal2pullingOffsetX {
                // 转为普通状态
                state = .idle
            }
        } else if state == .pulling {
            // 即将刷新 && 手松开; 开始刷新
            beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }

    private func shouldAutomaticallyRefresh(change: [AnyHashable: Any]?, pullingPercent: CGFloat) -> Bool {
        if !isAutomaticallyRefresh { return false }
        if state != .idle && state != .pulling { return false }
        // Content narrower than the view keeps the pull-and-release behavior.
        if widthForContentBreakView <= 0 { return false }
        if scrollView?.cyl_header?.isRefreshing == true || scrollView?.cyl_footer?.isRefreshing == true { return false }
        if pullingPercent < triggerAutomaticallyRefreshPercent { return false }

        // Only while moving toward the end, so bouncing back does not trigger again.
        if let oldValue = change?[NSKeyValueChangeKey.oldKey.rawValue] as? NSValue,
           let newValue = change?[NSKeyValueChangeKey.newKey.rawValue] as? NSValue,
           newValue.cgPointValue.x <= oldValue.cgPointValue.x { return false }

        if scrollView?.isDragging == true && leftTriggerTimes != -1 && leftTriggerTimes <= 0 { return false }
        return true
    }

    /**
     * [EN] A drag start resets the automatic refreshes allowed for the drag. [CN] 拖动开始时重置本次拖动允许的自动刷新次数。
     */
    open override func scrollViewPanStateDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewPanStateDidChange(change)

        if scrollView?.panGestureRecognizer.state == .began {
            leftTriggerTimes = autoTriggerTimes
        }
    }

    /**
     * [EN] Opens the right inset while refreshing and gives it back afterwards. [CN] 刷新时打开右侧 inset，结束后归还。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue
            if (newValue == .noMoreData || newValue == .idle) && triggerByDrag {
                if leftTriggerTimes != -1 {
                    leftTriggerTimes -= 1
                }
                triggerByDrag = false
            }
            // 根据状态来设置属性
            if newValue == .noMoreData || newValue == .idle {
                // 刷新完毕
                if oldState == .refreshing {
                    let generation = refreshGeneration
                    let completion = endRefreshingCompletionBlock
                    UIView.animate(withDuration: slowAnimationDuration, animations: {
                        self.endRefreshingAnimationBeginAction?()

                        if let scrollView = self.scrollView {
                            scrollView.cyl_insetR -= self.lastRightDelta
                        }
                        // 自动调整透明度
                        if self.isAutomaticallyChangeAlpha { self.alpha = 0.0 }
                    }, completion: { _ in
                        if self.refreshGeneration == generation && !self.isRefreshing {
                            self.pullingPercent = 0.0
                        }

                        completion?()
                    })
                }

                let deltaW = widthForContentBreakView
                // 刚刷新完毕
                if oldState == .refreshing && deltaW > 0, let scrollView = scrollView,
                   scrollView.cyl_totalDataCount() != lastRefreshCount {
                    scrollView.cyl_offsetX = scrollView.cyl_offsetX
                }
            } else if newValue == .refreshing {
                refreshGeneration &+= 1
                let generation = refreshGeneration
                // 记录刷新前的数量
                lastRefreshCount = scrollView?.cyl_totalDataCount() ?? 0

                UIView.animate(withDuration: fastAnimationDuration, animations: {
                    var right = self.cyl_w + self.scrollViewOriginalInset.right
                    let deltaW = self.widthForContentBreakView
                    // 如果内容宽度小于view的宽度
                    if deltaW < 0 {
                        right -= deltaW
                    }
                    self.lastRightDelta = right - (self.scrollView?.cyl_insetR ?? 0)
                    self.scrollView?.cyl_insetR = right

                    // 设置滚动位置
                    if let scrollView = self.scrollView {
                        var offset = scrollView.contentOffset
                        offset.x = self.happenOffsetX + self.cyl_w
                        scrollView.setContentOffset(offset, animated: false)
                    }
                }, completion: { _ in
                    if self.refreshGeneration == generation && self.state == .refreshing {
                        self.executeRefreshingCallback()
                    }
                })
            }
        }
    }

    /**
     * [EN] Places the trailer after the content (or after the visible area when the content is narrower).
     * [CN] 把 trailer 放在内容之后（内容较窄时放在可见区域之后）。
     */
    open override func scrollViewContentSizeDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentSizeDidChange(change)

        // 内容的宽度
        let contentWidth = (scrollView?.cyl_contentW ?? 0) + ignoredScrollViewContentInsetRight
        // 表格的宽度
        let scrollWidth = (scrollView?.cyl_w ?? 0) - scrollViewOriginalInset.left - scrollViewOriginalInset.right +
            ignoredScrollViewContentInsetRight
        // 设置位置和尺寸
        cyl_x = max(contentWidth, scrollWidth)
    }

    /**
     * [EN] The trailer is as tall as the scroll view and `CYLRefreshTrailWidth` wide.
     * [CN] trailer 与滚动视图等高，宽度为 `CYLRefreshTrailWidth`。
     */
    open override func placeSubviews() {
        super.placeSubviews()

        cyl_h = scrollView?.cyl_h ?? 0
        // 设置自己的宽度
        cyl_w = CYLRefreshTrailWidth
    }

    /**
     * [EN] Ends a refresh and gives the bounce settings back when leaving a scroll view; bounces horizontally in the new
     *      one. [CN] 离开滚动视图时结束刷新并恢复回弹设置；在新滚动视图中开启横向回弹。
     */
    open override func willMove(toSuperview newSuperview: UIView?) {
        if let oldScrollView = scrollView {
            if state == .refreshing {
                endRefreshing()
            } else if state == .willRefresh {
                super.state = .idle
            }
            if oldScrollView.alwaysBounceHorizontal {
                oldScrollView.alwaysBounceHorizontal = previousHorizontalBounce
            }
            if !oldScrollView.alwaysBounceVertical {
                oldScrollView.alwaysBounceVertical = previousVerticalBounce || oldScrollView.cyl_header != nil ||
                    oldScrollView.cyl_footer != nil
            }
        }

        let newScrollView = newSuperview as? UIScrollView
        if let newScrollView = newScrollView {
            previousHorizontalBounce = newScrollView.alwaysBounceHorizontal
            previousVerticalBounce = newScrollView.alwaysBounceVertical
        }
        super.willMove(toSuperview: newSuperview)

        if let newScrollView = newScrollView {
            // 设置支持水平弹簧效果
            newScrollView.alwaysBounceHorizontal = true
            newScrollView.alwaysBounceVertical = false
        }
    }

    // MARK: - Chaining

    /**
     * [EN] Sets the trailer as `scrollView.cyl_trailer` and returns it. [CN] 设为 `scrollView.cyl_trailer` 并返回自身。
     */
    open override func cyl_link(to scrollView: UIScrollView) -> Self {
        scrollView.cyl_trailer = self
        return self
    }

    // MARK: - 刚好看到上拉刷新控件时的contentOffset.x

    private var happenOffsetX: CGFloat {
        let deltaW = widthForContentBreakView
        if deltaW > 0 {
            return deltaW - scrollViewOriginalInset.left
        } else {
            return -scrollViewOriginalInset.left
        }
    }

    // MARK: - 获得scrollView的内容 超出 view 的宽度

    private var widthForContentBreakView: CGFloat {
        guard let scrollView = scrollView else { return 0 }
        let w = scrollView.frame.size.width - scrollViewOriginalInset.right - scrollViewOriginalInset.left
        return scrollView.contentSize.width - w
    }

    /**
     * [EN] A trailer opens sideways: its open size is its width. [CN] trailer 横向展开：展开尺寸是它的宽度。
     */
    open override var expandHeight: CGFloat {
        cyl_w
    }
}
