//
//  CYLRefreshHeader.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  下拉刷新控件:负责监控用户下拉的状态
//

// [EN] Swift since 2026-11-20 (docs/Swift-Migration.md, step 11), with the same Objective-C API (the factories
//      `+headerWithRefreshingBlock:` / `+headerWithRefreshingTarget:refreshingAction:`, which Swift spells as the
//      initializers `init(refreshingBlock:)` / `init(refreshingTarget:refreshingAction:)` as before, `lastUpdatedTimeKey`,
//      `lastUpdatedTime`, `ignoredScrollViewContentInsetTop`, `isCollectionViewAnimationBug`, `setExpandHeight:`, the
//      refreshing inset, the scroll modes and the second floor) and the same behavior: the inset written by someone else
//      during a refresh becomes the new baseline (issue MJRefresh#1628), a footer's or trailer's own side-inset write is
//      not taken for a new top inset (issue MJRefresh#1483), rotation during a refresh rebuilds the original top from the
//      header's own delta (MJRefresh PR #1444). The root `CYLRefreshComponent` (Swift since step 12) keeps the KVO of the
//      scroll view; its internal members (`reportPhaseChange()`, `offset(forDragRate:happenOffset:)`, ...) are
//      called directly.
// [CN] 自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 11 步），Objective-C API（工厂方法 `+headerWithRefreshingBlock:` /
//      `+headerWithRefreshingTarget:refreshingAction:`，Swift 仍写作初始化方法 `init(refreshingBlock:)` / `init(refreshingTarget:refreshingAction:)`；
//      `lastUpdatedTimeKey`、`lastUpdatedTime`、`ignoredScrollViewContentInsetTop`、`isCollectionViewAnimationBug`、`setExpandHeight:`、刷新 inset、
//      滚动模式与二楼）和行为均不变：刷新期间其他代码写入的 inset 成为新的基准（issue MJRefresh#1628），刷新尾或 trailer 写入自己那一侧的 inset
//      不会被当作新的顶部 inset（issue MJRefresh#1483），刷新期间旋转时用刷新头自己的差值重建原始 top（MJRefresh PR #1444）。滚动视图的 KVO
//      仍由根类 `CYLRefreshComponent`（自第 12 步起用 Swift 编写）负责；直接调用其 internal 成员。

import UIKit

// [EN] The identities of the two bounds animations of `isCollectionViewAnimationBug` (private; the Objective-C globals of
//      the same names were never declared in a header).
// [CN] `isCollectionViewAnimationBug` 两个 bounds 动画的标识（私有；同名的 Objective-C 全局常量从未在头文件中声明）。
private let refreshHeaderRefreshing2IdleBoundsKey = "CYLRefreshHeaderRefreshing2IdleBounds"
private let refreshHeaderRefreshingBoundsKey = "CYLRefreshHeaderRefreshingBounds"

// [EN] The delegate of those animations. It holds the header strongly, as the animation held the header when the header
//      was its own delegate, so the callback always comes and removes the animation (`removedOnCompletion` is NO).
// [CN] 这些动画的代理。它强持有刷新头（刷新头自己作为代理时动画也持有它），保证回调总会到达并移除动画（`removedOnCompletion` 为 NO）。
private final class CYLRefreshHeaderAnimationDelegate: NSObject, CAAnimationDelegate {

    let header: CYLRefreshHeader

    init(header: CYLRefreshHeader) {
        self.header = header
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        header.boundsAnimationDidStop(anim)
    }
}

/**
 * [EN] The base class of the pull-down refresh controls: it watches the pull above the content and refreshes on
 *      release; set one as a scroll view's `cylHeader`.
 * [CN] 下拉刷新控件的基类：监视内容上方的下拉，松手时刷新；设为滚动视图的 `cylHeader` 使用。
 */
@objc(CYLRefreshHeader)
open class CYLRefreshHeader: CYLRefreshComponent {

    // MARK: - Private state

    private var insetTDelta: CGFloat = 0
    private var updatingRefreshInset = false
    // [EN] YES while the header retracts after a refresh. [CN] 刷新结束后刷新头收回期间为 YES。
    private var retracting = false
    // [EN] The open height kept while `scrollMode` changes the frame. [CN] `scrollMode` 改变 frame 时保留的展开高度。
    private var storedExpandHeight: CGFloat = 0
    // [EN] YES while this refresh added the header height to the top inset. [CN] 本次刷新把刷新头高度加到顶部 inset 期间为 YES。
    private var addedRefreshingInset = false
    // [EN] Whether the current drag started with the list at the top edge (triggerMode). [CN] 当前拖动开始时列表是否在顶部边缘（triggerMode）。
    private var dragStartedAtEdge = false
    // [EN] Second floor: pulled past the trigger while dragging. [CN] 二楼：拖动中已拉过触发点。
    private var secondaryArmed = false
    // [EN] Second floor: pushed up far enough to close on release. [CN] 二楼：已上推足够距离，松手即关闭。
    private var secondaryClosePending = false
    // [EN] Second floor: the closing animation runs. [CN] 二楼：关闭动画进行中。
    private var secondaryClosing = false
    private var storedSecondaryOpen = false
    private var storedIgnoredScrollViewContentInsetTop: CGFloat = 0
    private var storedSecondaryView: UIView?

    // MARK: - Factories

    /**
     * [EN] Creates a header that calls `refreshingBlock` when it refreshes (Objective-C `+headerWithRefreshingBlock:`).
     * [CN] 创建header，刷新时调用 `refreshingBlock`（Objective-C 的 `+headerWithRefreshingBlock:`）。
     */
    public convenience init(refreshingBlock: @escaping CYLRefreshComponentAction) {
        self.init()
        self.refreshingBlock = refreshingBlock
    }

    /**
     * [EN] Creates a header that sends `action` to `target` when it refreshes (Objective-C
     *      `+headerWithRefreshingTarget:refreshingAction:`).
     * [CN] 创建header，刷新时向 `target` 发送 `action`（Objective-C 的 `+headerWithRefreshingTarget:refreshingAction:`）。
     */
    public convenience init(refreshingTarget target: Any, refreshingAction action: Selector) {
        self.init()
        setRefreshingTarget(target, refreshingAction: action)
    }

    /**
     * [EN] Objective-C: `+headerWithRefreshingBlock:`; returns an instance of the class it is sent to.
     * [CN] Objective-C：`+headerWithRefreshingBlock:`；返回接收消息的类的实例。
     */
    @objc(headerWithRefreshingBlock:)
    @available(swift, obsoleted: 1, message: "Use init(refreshingBlock:)")
    open class func objcHeader(refreshingBlock: @escaping CYLRefreshComponentAction) -> Self {
        let cmp = self.init()
        cmp.refreshingBlock = refreshingBlock
        return cmp
    }

    /**
     * [EN] Objective-C: `+headerWithRefreshingTarget:refreshingAction:`; returns an instance of the class it is sent to.
     * [CN] Objective-C：`+headerWithRefreshingTarget:refreshingAction:`；返回接收消息的类的实例。
     */
    @objc(headerWithRefreshingTarget:refreshingAction:)
    @available(swift, obsoleted: 1, message: "Use init(refreshingTarget:refreshingAction:)")
    open class func objcHeader(refreshingTarget target: Any, refreshingAction action: Selector) -> Self {
        let cmp = self.init()
        cmp.setRefreshingTarget(target, refreshingAction: action)
        return cmp
    }

    // MARK: - Public properties

    /**
     * [EN] The `UserDefaults` key under which the time of the last successful refresh is stored.
     * [CN] 这个key用来存储上一次下拉刷新成功的时间。
     */
    @objc open var lastUpdatedTimeKey: String = CYLRefreshHeaderLastUpdatedTimeKey

    /**
     * [EN] When the last refresh succeeded, stored under `lastUpdatedTimeKey`. Setting it stores the date (nil removes it)
     *      and updates the time label of state headers.
     * [CN] 上一次刷新成功的时间，保存在 `lastUpdatedTimeKey` 下。设置后保存该日期（nil 表示删除），并更新带文字刷新头的时间文字。
     */
    @objc open var lastUpdatedTime: Date? {
        get { UserDefaults.standard.object(forKey: lastUpdatedTimeKey) as? Date }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date, forKey: lastUpdatedTimeKey)
            } else {
                UserDefaults.standard.removeObject(forKey: lastUpdatedTimeKey)
            }
            // [EN] Re-setting the key makes state headers redraw the time. [CN] 重新设置 key，带文字的刷新头会重新显示时间。
            let key = lastUpdatedTimeKey
            lastUpdatedTimeKey = key
        }
    }

    /**
     * [EN] How much of the scroll view's top content inset to ignore (points).
     * [CN] 忽略多少scrollView的contentInset的top。
     */
    @objc open var ignoredScrollViewContentInsetTop: CGFloat {
        get { storedIgnoredScrollViewContentInsetTop }
        set {
            storedIgnoredScrollViewContentInsetTop = newValue
            cylY = -cylH - newValue
        }
    }

    /**
     * [EN] Off by default; turn it on when a collection view animates wrongly at the start or end of a refresh (the
     *      refreshing inset then moves with bounds animations).
     * [CN] 默认是关闭状态, 如果遇到 CollectionView 的动画异常问题可以尝试打开。
     */
    @objc open var isCollectionViewAnimationBug = false

    /**
     * [EN] Whether refreshing adds the header's height to the top inset, pushing the content down. Default YES; NO (and
     *      `CYLRefreshScrollModeFront`) keeps the content where it is, for headers that are always open or float in front.
     * [CN] 刷新时是否把刷新头高度加到顶部 inset、把内容往下推。默认 YES；NO（以及 `CYLRefreshScrollModeFront`）让内容保持不动，
     *      适用于常态展开或浮在内容前面的刷新头。
     */
    @objc open var addsRefreshingInset = true

    /**
     * [EN] After a successful refresh, resets the footer's "no more data" (flutter_easy_refresh's `resetAfterRefresh`).
     *      Default NO. [CN] 刷新成功后重置加载尾的“无更多数据”（对应 flutter_easy_refresh 的 `resetAfterRefresh`）。默认 NO。
     */
    @objc open var resetsFooterAfterRefresh = false

    /**
     * [EN] In `CYLRefreshScrollModeBehind`, shows only the part of the header the content has revealed
     *      (CYLRefreshLayout's `setEnableClipHeaderWhenFixedBehind`). Default NO.
     * [CN] 在 `CYLRefreshScrollModeBehind` 下只显示内容已露出的部分（对应 CYLRefreshLayout 的
     *      `setEnableClipHeaderWhenFixedBehind`）。默认 NO。
     */
    @objc open var clipsWhenBehind = false

    // MARK: - Second floor (flutter_easy_refresh's secondary)

    /**
     * [EN] Pulling at least this far (points) and releasing opens the second floor instead of refreshing; 0 (default)
     *      turns the second floor off (flutter_easy_refresh's `secondaryTriggerOffset`).
     * [CN] 至少拉动这么远（点）后松手，会打开二楼而不是刷新；0（默认）关闭二楼（对应 flutter_easy_refresh 的 `secondaryTriggerOffset`）。
     */
    @objc open var secondaryTriggerOffset: CGFloat = 0

    /**
     * [EN] Height of the open second floor (points); 0 (default) uses the scroll view's visible height
     *      (flutter_easy_refresh's `secondaryDimension`).
     * [CN] 打开后二楼的高度（点）；0（默认）表示使用滚动视图的可见高度（对应 flutter_easy_refresh 的 `secondaryDimension`）。
     */
    @objc open var secondaryDimension: CGFloat = 0

    /**
     * [EN] While the second floor is open, pushing the content up this far (points) and releasing closes it. Default 80
     *      (flutter_easy_refresh's `secondaryCloseTriggerOffset`).
     * [CN] 二楼打开时，把内容往上推这么远（点）再松手即关闭。默认 80（对应 flutter_easy_refresh 的 `secondaryCloseTriggerOffset`）。
     */
    @objc open var secondaryCloseTriggerOffset: CGFloat = 80

    /**
     * [EN] Releasing a pull at least this fast (points per second) opens the second floor once the pull is past the refresh
     *      trigger, even short of `secondaryTriggerOffset`; 0 (default) turns it off (flutter_easy_refresh's
     *      `secondaryVelocity`). [CN] 拉过刷新触发点后，以至少这个速度（点/秒）松手即打开二楼，即使未达到 `secondaryTriggerOffset`；
     *      0（默认）关闭（对应 flutter_easy_refresh 的 `secondaryVelocity`）。
     */
    @objc open var secondaryVelocity: CGFloat = 0

    /**
     * [EN] The second floor's content, placed above the list across the whole second floor and revealed by the pull
     *      (flutter_easy_refresh's `SecondaryBuilderHeader`). [CN] 二楼的内容视图，放在列表上方、铺满整个二楼，随下拉露出
     *      （对应 flutter_easy_refresh 的 `SecondaryBuilderHeader`）。
     */
    @objc open var secondaryView: UIView? {
        get { storedSecondaryView }
        set {
            if storedSecondaryView !== newValue { storedSecondaryView?.removeFromSuperview() }
            storedSecondaryView = newValue
            placeSecondaryView()
        }
    }

    /**
     * [EN] YES while the second floor is open. [CN] 二楼打开时为 YES。
     */
    @objc(secondaryOpen)
    open var isSecondaryOpen: Bool {
        @objc(isSecondaryOpen) get { storedSecondaryOpen }
    }

    /**
     * [EN] Called when the second floor has opened. [CN] 二楼打开后调用。
     */
    @objc open var secondaryOpenedBlock: CYLRefreshComponentAction?

    /**
     * [EN] Called when the second floor has closed. [CN] 二楼关闭后调用。
     */
    @objc open var secondaryClosedBlock: CYLRefreshComponentAction?

    /**
     * [EN] Asked before the second floor opens (by a pull or by `openSecondary`); return NO to keep it closed
     *      (CYLRefreshLayout's `OnTwoLevelListener.onTwoLevel`). nil (default) always opens.
     * [CN] 二楼打开前（拉动或 `openSecondary`）询问；返回 NO 保持关闭（对应 CYLRefreshLayout 的 `OnTwoLevelListener.onTwoLevel`）。
     *      nil（默认）总是打开。
     */
    @objc open var secondaryShouldOpenBlock: ((CYLRefreshHeader) -> Bool)?

    /**
     * [EN] Seconds the second floor takes to open and to close; 0 (default) uses `slowAnimationDuration`
     *      (CYLRefreshLayout's `RefreshKernel.requestFloorDuration`).
     * [CN] 二楼打开与关闭的秒数；0（默认）使用 `slowAnimationDuration`（对应 CYLRefreshLayout 的 `RefreshKernel.requestFloorDuration`）。
     */
    @objc open var secondaryAnimationDuration: TimeInterval = 0

    // MARK: - Overrides of CYLRefreshComponent

    /**
     * [EN] Sets the time key and the height, and turns the refreshing inset on. [CN] 设置时间 key 与高度，并开启刷新 inset。
     */
    open override func prepare() {
        super.prepare()

        // 设置key
        lastUpdatedTimeKey = CYLRefreshHeaderLastUpdatedTimeKey

        // 设置高度
        cylH = CYLRefreshHeaderHeight

        // [EN] `addsRefreshingInset` (YES) and `secondaryCloseTriggerOffset` (80) start at their defaults, as the
        //      Objective-C code wrote the ivars here. [CN] `addsRefreshingInset`（YES）与 `secondaryCloseTriggerOffset`（80）以默认值开始，
        //      与 Objective-C 代码在此直接写入实例变量相同。
        updateAutoHideVisibility()
    }

    /**
     * [EN] Also applies `autoHideRefresh` again. [CN] 同时重新应用 `autoHideRefresh`。
     */
    open override var pullingPercent: CGFloat {
        get { super.pullingPercent }
        set {
            super.pullingPercent = newValue
            updateAutoHideVisibility()
        }
    }

    // [EN] Idle and fully retracted: the content's top edge is at or above the header's bottom edge.
    // [CN] 空闲且完全收回：内容顶边位于刷新头底边或其上方。
    private var isIdleAndRetracted: Bool {
        if state != .idle || retracting { return false }
        guard let scrollView = scrollView else { return true }
        return scrollView.cylOffsetY >= -scrollViewOriginalInset.top - 0.5
    }

    /**
     * [EN] YES while idle and fully retracted. [CN] 空闲且完全收回时为 YES。
     */
    open override func isReadyToAutoHide() -> Bool {
        isIdleAndRetracted
    }

    /**
     * [EN] Places the header above the content. [CN] 把刷新头放到内容上方。
     */
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if scrollView != nil {
            cylY = -cylH - ignoredScrollViewContentInsetTop
        }
    }

    /**
     * [EN] Places the header above the content for its height and `scrollMode`. [CN] 按高度与 `scrollMode` 把刷新头放到内容上方。
     */
    open override func placeSubviews() {
        super.placeSubviews()

        // 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
        cylY = -cylH - ignoredScrollViewContentInsetTop + insetStart
        applyScrollMode()
    }

    // MARK: - Second floor

    private var secondaryHeight: CGFloat {
        if secondaryDimension > 0 { return secondaryDimension }
        let height = scrollView?.bounds.height ?? 0
        return max(expandHeight, height - scrollViewOriginalInset.top - scrollViewOriginalInset.bottom)
    }

    /**
     * [EN] The second floor's phases before the inherited ones. [CN] 二楼的阶段优先于继承的阶段。
     */
    open override var phase: CYLRefreshPhase {
        if secondaryClosing { return .secondaryClosing }
        if isSecondaryOpen { return .secondaryOpen }
        if secondaryArmed { return .secondaryArmed }
        return super.phase
    }

    // [EN] The second floor's view sits above the content, across the whole second floor, behind the header.
    // [CN] 二楼视图放在内容上方、铺满整个二楼，位于刷新头后面。
    private func placeSecondaryView() {
        guard let view = secondaryView, let scrollView = scrollView else { return }
        if view.superview !== scrollView { scrollView.insertSubview(view, belowSubview: self) }
        let height = secondaryHeight
        view.frame = CGRect(x: -scrollView.cylInsetL, y: -height - ignoredScrollViewContentInsetTop,
                            width: scrollView.cylW, height: height)
    }

    /**
     * [EN] Places the second floor's view. [CN] 放置二楼视图。
     */
    open override func didAttach(to scrollView: UIScrollView) {
        super.didAttach(to: scrollView)
        placeSecondaryView()
    }

    /**
     * [EN] Removes the second floor's view. [CN] 移除二楼视图。
     */
    open override func willDetach(from scrollView: UIScrollView) {
        secondaryView?.removeFromSuperview()
        super.willDetach(from: scrollView)
    }

    // [EN] The second floor's open / close duration (secondaryAnimationDuration, else slowAnimationDuration).
    // [CN] 二楼打开 / 关闭的时长（secondaryAnimationDuration，否则 slowAnimationDuration）。
    private var secondaryDuration: TimeInterval {
        secondaryAnimationDuration > 0 ? secondaryAnimationDuration : slowAnimationDuration
    }

    /**
     * [EN] Opens the second floor (flutter_easy_refresh's `openHeaderSecondary`). [CN] 打开二楼（对应 flutter_easy_refresh 的 `openHeaderSecondary`）。
     */
    @objc open func openSecondary() {
        if isSecondaryOpen || scrollView == nil || isRefreshing { return }
        if let shouldOpen = secondaryShouldOpenBlock, !shouldOpen(self) {
            // [EN] Vetoed: drop the armed pull, the header stays as it is. [CN] 被拒绝：放弃已触发的拉动，刷新头保持原样。
            secondaryArmed = false
            return
        }
        secondaryArmed = false
        if state == .pulling { state = .idle }
        placeSecondaryView()
        storedSecondaryOpen = true
        // [EN] The open floor comes in front of the header, as flutter_easy_refresh's secondary page does; the header's
        //      text would otherwise show over the floor. [CN] 打开的二楼移到刷新头前面（与 flutter_easy_refresh 的二楼页面相同），
        //      否则刷新头的文字会显示在二楼上。
        if let view = secondaryView { scrollView?.insertSubview(view, aboveSubview: self) }
        reportPhaseChange()
        let top = scrollViewOriginalInset.top + secondaryHeight
        UIView.animate(withDuration: secondaryDuration, animations: {
            self.setRefreshingInsetTop(top)
            self.scrollView?.contentOffset = CGPoint(x: self.scrollView?.cylOffsetX ?? 0, y: -top)
        }, completion: { _ in
            self.secondaryOpenedBlock?()
        })
    }

    /**
     * [EN] Closes the second floor (flutter_easy_refresh's `closeHeaderSecondary`). [CN] 关闭二楼（对应 flutter_easy_refresh 的 `closeHeaderSecondary`）。
     */
    @objc open func closeSecondary() {
        if !isSecondaryOpen || secondaryClosing { return }
        secondaryClosing = true
        secondaryClosePending = false
        reportPhaseChange()
        let top = scrollViewOriginalInset.top
        UIView.animate(withDuration: secondaryDuration, animations: {
            self.setRefreshingInsetTop(top)
            self.scrollView?.contentOffset = CGPoint(x: self.scrollView?.cylOffsetX ?? 0, y: -top)
        }, completion: { _ in
            self.secondaryClosing = false
            self.storedSecondaryOpen = false
            self.pullingPercent = 0
            // [EN] Closed: back behind the header, revealed by the next pull. [CN] 关闭后回到刷新头后面，由下次下拉露出。
            if let view = self.secondaryView { self.scrollView?.insertSubview(view, belowSubview: self) }
            self.reportPhaseChange()
            self.updateAutoHideVisibility()
            self.secondaryClosedBlock?()
        })
    }

    // [EN] While open: pushing the content up past the close trigger and releasing closes the second floor.
    // [CN] 打开时：把内容上推超过关闭触发距离再松手，即关闭二楼。
    private func followOpenSecondary() {
        if secondaryClosing { return }
        let openOffsetY = -(scrollViewOriginalInset.top + secondaryHeight)
        let pushed = (scrollView?.cylOffsetY ?? 0) - openOffsetY
        if scrollView?.isDragging == true {
            secondaryClosePending = pushed >= secondaryCloseTriggerOffset
        } else if secondaryClosePending {
            closeSecondary()
        }
    }

    // MARK: - Trigger mode

    /**
     * [EN] A fast release can open the second floor; a drag start records whether the list was at its top edge.
     * [CN] 快速松手可打开二楼；拖动开始时记录列表是否位于顶部边缘。
     */
    open override func scrollViewPanStateDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewPanStateDidChange(change)
        guard let scrollView = scrollView else { return }
        let pan = scrollView.panGestureRecognizer
        if pan.state == .ended && secondaryVelocity > 0 && secondaryTriggerOffset > 0 && !isSecondaryOpen && !isRefreshing {
            // [EN] A fast release past the refresh trigger opens the second floor. [CN] 越过刷新触发点后快速松手即打开二楼。
            let velocity = pan.velocity(in: scrollView).y
            let pulled = -(scrollView.cylOffsetY + scrollViewOriginalInset.top)
            if velocity >= secondaryVelocity && pulled >= expandHeight * triggerRate {
                openSecondary()
                return
            }
        }
        if pan.state == .began {
            // [EN] At the top edge: the content's top is at (or below) the header's bottom. [CN] 位于顶部边缘：内容顶部在刷新头底边或其下方。
            dragStartedAtEdge = scrollView.cylOffsetY <= -scrollViewOriginalInset.top + 0.5
        }
    }

    // MARK: - Scroll mode

    // [EN] Refreshing pushes the content down only when the header adds its inset and does not float in front.
    // [CN] 只有刷新头会加 inset 且不是前置时，刷新才会把内容往下推。
    private var movesContentWhileRefreshing: Bool {
        addsRefreshingInset && scrollMode != .front
    }

    /**
     * [EN] The open height: the one set by `setExpandHeight:` outside the move mode, else the frame height.
     * [CN] 展开高度：非移动模式下为 `setExpandHeight:` 设置的值，否则为 frame 高度。
     */
    open override var expandHeight: CGFloat {
        storedExpandHeight > 0 ? storedExpandHeight : cylH
    }

    /**
     * [EN] Sets the open height (`expandHeight`). In `CYLRefreshScrollModeStretch` the frame follows the pull, so only the
     *      open height changes; in the other modes the frame height changes too.
     * [CN] 设置展开高度（`expandHeight`）。拉伸模式下 frame 跟随下拉，只改变展开高度；其他模式同时改变 frame 高度。
     */
    @objc(setExpandHeight:)
    open func setExpandHeight(_ expandHeight: CGFloat) {
        let expandHeight = max(0, expandHeight)
        if scrollMode == .move {
            storedExpandHeight = 0
            cylH = expandHeight
        } else {
            storedExpandHeight = max(expandHeight, 1)
            if scrollMode == .front { cylH = expandHeight }
        }
        applyScrollMode()
    }

    /**
     * [EN] Keeps the open height across the modes and places the header for the new mode.
     * [CN] 在各模式之间保留展开高度，并按新模式放置刷新头。
     */
    open override var scrollMode: CYLRefreshScrollMode {
        get { super.scrollMode }
        set {
            if newValue != .move && storedExpandHeight <= 0 {
                storedExpandHeight = cylH
            }
            super.scrollMode = newValue
            if newValue == .move && storedExpandHeight > 0 {
                let height = storedExpandHeight
                storedExpandHeight = 0
                cylH = height
                cylY = -height - ignoredScrollViewContentInsetTop
                layer.zPosition = 0
            }
            applyScrollMode()
        }
    }

    // [EN] Places the header for `scrollMode`: stretched over the whole pulled distance, or in front at the visible top.
    // [CN] 按 `scrollMode` 放置刷新头：拉伸铺满整个下拉距离，或位于可见区域顶部的内容前面。
    private func applyScrollMode() {
        guard scrollMode != .move, let scrollView = scrollView else { return }
        let height = expandHeight
        let offsetY = scrollView.cylOffsetY
        let visibleTop = offsetY + scrollViewOriginalInset.top
        let pulled = max(0, -visibleTop)
        if scrollMode == .stretch {
            // [EN] Stretch, as in CYLRefresh styles: the header is exactly the pulled area, from 0 when idle.
            // [CN] 拉伸（与 CYLRefresh styles 相同）：刷新头正好是被拉出的区域，空闲时高度为 0。
            if abs(cylH - pulled) > 0.25 { cylH = pulled }
            cylY = -pulled - ignoredScrollViewContentInsetTop
        } else if scrollMode == .behind {
            // [EN] Behind: pinned at the visible top behind the content, revealed as the content moves down.
            // [CN] 后置：固定在可见区域顶部、位于内容后面，内容下移时露出。
            if abs(cylH - height) > 0.25 { cylH = height }
            cylY = min(visibleTop, -height) + insetStart
            layer.zPosition = -1
            // [EN] clipsWhenBehind: only the revealed part shows. [CN] clipsWhenBehind：只显示露出的部分。
            if clipsWhenBehind {
                let mask = layer.mask ?? CALayer()
                mask.backgroundColor = UIColor.black.cgColor
                mask.frame = CGRect(x: 0, y: 0, width: cylW, height: min(pulled, height))
                layer.mask = mask
            } else if layer.mask != nil && !clipsWhenBehind {
                layer.mask = nil
            }
            if let superview = superview, superview.subviews.first !== self { superview.sendSubviewToBack(self) }
        } else {
            // [EN] Front, as in CYLRefresh styles: pinned at the top of the visible area, in front of the content, which
            //      never moves for it (no refreshing inset). [CN] 前置（与 CYLRefresh styles 相同）：固定在可见区域顶部、位于内容前面，
            //      内容不会为它移动（不加刷新 inset）。
            if abs(cylH - height) > 0.25 { cylH = height }
            cylY = visibleTop + insetStart
            layer.zPosition = 1
            if let superview = superview, superview.subviews.last !== self { superview.bringSubviewToFront(self) }
        }
    }

    // [EN] Writes the top inset as the header's own write (`updatingRefreshInset`), reset even when a `contentInset`
    //      observer throws an Objective-C exception (the guard is `@try` / `@finally` in `UIScrollView+CYLExtensionSupport.m`).
    // [CN] 以刷新头自己的写入（`updatingRefreshInset`）写入顶部 inset；即使 `contentInset` 的观察者抛出 Objective-C 异常也会复位
    //      （保护是 `UIScrollView+CYLExtensionSupport.m` 中的 `@try` / `@finally`）。
    private func setRefreshingInsetTop(_ insetTop: CGFloat) {
        guard !updatingRefreshInset, let scrollView = scrollView else { return }

        updatingRefreshInset = true
        UIScrollView.cylRefreshPerform({
            scrollView.cylInsetT = insetTop
        }, cleanup: { [weak self] in
            self?.updatingRefreshInset = false
        })
    }

    private func resetInset() {
        if updatingRefreshInset { return }
        // [EN] The iOS 10 check of the Objective-C code (no reset without a window) is gone: the library needs iOS 15.
        // [CN] Objective-C 代码中针对 iOS 10 的检查（没有 window 时不重置）已删除：库最低支持 iOS 15。
        guard let scrollView = scrollView else { return }

        // FIX: MJRefresh PR #1444 (device rotation)
        // [EN] insetTDelta (original top - current top) is what the header added, and stays right when the system part of
        //      the inset changes (a rotation changes the bars and the safe area, both sides move together). The saved
        //      original top does not: rebuild it from the current top, or the header works from the old system inset and
        //      leaves the difference behind as a gap when the refresh ends.
        // [CN] insetTDelta（原始 top - 当前 top）是刷新头增加的量，系统部分的 inset 变化时（旋转会改变栏与安全区，两边一起变）它仍然正确；
        //      保存的原始 top 则不会。用当前 top 重新得出它，否则刷新头会按旧的系统 inset 计算，并在刷新结束后留下差值作为空隙。
        var original = scrollViewOriginalInset
        original.top = scrollView.cylInsetT + insetTDelta
        scrollViewOriginalInset = original

        // sectionheader停留解决
        var insetT = -scrollView.cylOffsetY > original.top ? -scrollView.cylOffsetY : original.top
        insetT = insetT > expandHeight + original.top ? expandHeight + original.top : insetT
        // 避免 CollectionView 在使用根据 Autolayout 和 内容自动伸缩 Cell, 刷新时导致的 Layout 异常渲染问题
        if abs(scrollView.cylInsetT - insetT) > CGFloat(Float.ulpOfOne) {
            setRefreshingInsetTop(insetT)
        }
        insetTDelta = scrollViewOriginalInset.top - scrollView.cylInsetT
    }

    /**
     * [EN] Follows the pull: arms, refreshes on release, keeps the refreshing inset, the second floor and the scroll mode.
     * [CN] 跟随下拉：触发、松手刷新，维持刷新 inset、二楼与滚动模式。
     */
    open override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        updateAutoHideVisibility()
        applyScrollMode()

        // 在刷新的refreshing状态
        if state == .refreshing {
            if addedRefreshingInset && scrollMode != .front { resetInset() }
            return
        }

        // [EN] The second floor holds its own inset; it is not the original inset. [CN] 二楼占用了自己的 inset，不是原始 inset。
        if isSecondaryOpen || secondaryClosing {
            followOpenSecondary()
            return
        }

        guard let scrollView = scrollView else { return }

        // 跳转到下一个控制器时，contentInset可能会变
        scrollViewOriginalInset = scrollView.cylInset

        // 当前的contentOffset
        var offsetY = scrollView.cylOffsetY
        // 头部控件刚好出现的offsetY
        let happenOffsetY = -scrollViewOriginalInset.top

        // 如果是向上滚动到看不见头部控件，直接返回
        // >= -> >
        if offsetY > happenOffsetY { return }
        // [EN] dragRate scales the pull. [CN] dragRate 按比例缩放拉动距离。
        offsetY = offset(forDragRate: offsetY, happenOffset: happenOffsetY)

        // 普通 和 即将刷新 的临界点
        let triggerDistance = expandHeight * triggerRate
        let normal2pullingOffsetY = happenOffsetY - triggerDistance
        var pullingPercent = (happenOffsetY - offsetY) / triggerDistance

        // [EN] Second floor: arm past its trigger while dragging, open on release. [CN] 二楼：拖动中越过触发点即就绪，松手打开。
        if secondaryTriggerOffset > 0 {
            let armed = scrollView.isDragging && happenOffsetY - offsetY >= secondaryTriggerOffset
            if scrollView.isDragging && armed != secondaryArmed {
                secondaryArmed = armed
                reportPhaseChange()
            } else if !scrollView.isDragging && secondaryArmed {
                openSecondary()
                return
            }
        }

        // 如果正在拖拽
        if scrollView.isDragging {
            // [EN] maxPullDistance: hold the pull at the limit. [CN] maxPullDistance：把下拉停在上限。
            if maxPullDistance > 0 && happenOffsetY - offsetY > maxPullDistance {
                offsetY = happenOffsetY - maxPullDistance
                pullingPercent = maxPullDistance / triggerDistance
                scrollView.contentOffset = CGPoint(x: scrollView.cylOffsetX, y: offsetY)
            }
            self.pullingPercent = pullingPercent
            let mayArm = triggerMode == .anywhere || dragStartedAtEdge
            if state == .idle && isRefreshEnabled && mayArm && canTrigger() && offsetY < normal2pullingOffsetY {
                // 转为即将刷新状态
                state = .pulling
                // [EN] triggersWhenReached: refresh now, without waiting for the release. [CN] triggersWhenReached：立即刷新，不等松手。
                if triggersWhenReached { beginRefreshing() }
            } else if state == .pulling && offsetY >= normal2pullingOffsetY {
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

    // FIX: issue MJRefresh#1628
    // [EN] Someone else wrote the content inset during a refresh (SwiftUI's ScrollView resets its inset and offset when its
    //      data changes; an app may set a new inset). The written top becomes the new original inset, the refreshing inset
    //      is added on top of it again, and a list resting at its top edge moves back to show the header. Writes of the
    //      header itself (`updatingRefreshInset`) and refreshes that add no inset (front scroll mode) are left alone.
    // [CN] 刷新期间有其他代码写入了 contentInset（SwiftUI 的 ScrollView 在数据变化时会重置 inset 和 offset；应用也可能设置新的 inset）。
    //      写入的 top 作为新的原始 inset，在其上重新加上刷新 inset；停在顶部边缘的列表移回到能看到刷新头的位置。刷新头自己的写入
    //      （`updatingRefreshInset`）和不增加 inset 的刷新（前置滚动模式）不受影响。
    /**
     * [EN] Takes an inset written by someone else during a refresh as the new baseline (issue MJRefresh#1628).
     * [CN] 刷新期间把其他代码写入的 inset 作为新的基准（issue MJRefresh#1628）。
     */
    open override func scrollViewContentInsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentInsetDidChange(change)
        guard !updatingRefreshInset, state == .refreshing, addedRefreshingInset, movesContentWhileRefreshing,
              let scrollView = scrollView else { return }
        // FIX: issue MJRefresh#1483
        // [EN] A footer or trailer that starts or ends loading writes its own side (cylInsetB / L / R). Taking that write
        //      for a new original top made the refreshing top the "original" and added the header's height again, so each
        //      refresh during a footer load left the content one header height lower.
        // [CN] 刷新尾或 trailer 开始或结束加载时写入自己那一侧（cylInsetB / L / R）。把这次写入当作新的原始 top，会把刷新中的 top 当作
        //      “原始值”并再次加上刷新头高度，于是每次在刷新尾加载期间刷新，内容都下移一个刷新头高度。
        if UIScrollView.cylIsWritingSideInset { return }
        let originalTop = scrollView.cylInsetT
        let refreshingTop = originalTop + expandHeight
        var original = scrollViewOriginalInset
        original.top = originalTop
        scrollViewOriginalInset = original
        let epsilon = CGFloat(Float.ulpOfOne)
        let restingAtTop = !scrollView.isTracking && !scrollView.isDecelerating &&
            scrollView.cylOffsetY <= -originalTop + epsilon
        setRefreshingInsetTop(refreshingTop)
        insetTDelta = originalTop - scrollView.cylInsetT
        if restingAtTop && scrollView.cylOffsetY > -refreshingTop + epsilon {
            scrollView.setContentOffset(CGPoint(x: scrollView.cylOffsetX, y: -refreshingTop), animated: false)
        }
    }

    /**
     * [EN] Adds the refreshing inset when refreshing starts and gives it back when it ends.
     * [CN] 开始刷新时加上刷新 inset，结束时归还。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue

            // 根据状态做事情
            if newValue == .idle {
                if oldState != .refreshing {
                    updateAutoHideVisibility()
                    return
                }

                headerEndingAction()
            } else if newValue == .refreshing {
                headerRefreshingAction()
            }
            updateAutoHideVisibility()
        }
    }

    private func headerEndingAction() {
        // [EN] resetsFooterAfterRefresh: a successful refresh lets the footer load again. [CN] 刷新成功后加载尾可再次加载。
        if resetsFooterAfterRefresh && lastRefreshSucceeded, let footer = scrollView?.cylFooter, footer.isNoMoreData {
            footer.resetNoMoreData()
        }
        // 保存刷新时间
        UserDefaults.standard.set(Date(), forKey: lastUpdatedTimeKey)
        UserDefaults.standard.synchronize()
        retracting = true
        let addedInset = addedRefreshingInset
        addedRefreshingInset = false
        if !addedInset {
            // [EN] Front added no inset, so there is nothing to restore. [CN] 前置没有加 inset，无需恢复。
            retracting = false
            pullingPercent = 0.0
            endRefreshingCompletionBlock?()
            return
        }

        // 默认使用 UIViewAnimation 动画
        if !isCollectionViewAnimationBug {
            // 恢复inset和offset
            UIView.animate(withDuration: slowAnimationDuration, delay: 0, options: reboundAnimationOptions, animations: {
                self.setRefreshingInsetTop((self.scrollView?.cylInsetT ?? 0) + self.insetTDelta)

                self.endRefreshingAnimationBeginAction?()
                // 自动调整透明度
                if self.isAutomaticallyChangeAlpha { self.alpha = 0.0 }
            }, completion: { _ in
                self.retracting = false
                self.pullingPercent = 0.0

                self.endRefreshingCompletionBlock?()
            })

            return
        }

        /*
         这个解决方法的思路出自 https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/844
         修改了用+ [UIView animateWithDuration: animations:]实现的修改contentInset的动画
         fix issue#225 https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/225
         另一种解法 pull#737 https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/737

         同时, 处理了 Refreshing 中的动画替换.
         */

        // 由于修改 Inset 会导致 self.pullingPercent 联动设置 self.alpha, 故提前获取 alpha 值, 后续用于还原 alpha 动画
        let viewAlpha = alpha

        setRefreshingInsetTop((scrollView?.cylInsetT ?? 0) + insetTDelta)
        // 禁用交互, 如果不禁用可能会引起渲染问题.
        scrollView?.isUserInteractionEnabled = false

        //CAAnimation keyPath 不支持 contentInset 用Bounds的动画代替
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        boundsAnimation.fromValue = NSValue(cgRect: (scrollView?.bounds ?? .zero).offsetBy(dx: 0, dy: insetTDelta))
        boundsAnimation.duration = slowAnimationDuration
        //在delegate里移除
        boundsAnimation.isRemovedOnCompletion = false
        boundsAnimation.fillMode = .both
        boundsAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        boundsAnimation.delegate = CYLRefreshHeaderAnimationDelegate(header: self)
        boundsAnimation.setValue(refreshHeaderRefreshing2IdleBoundsKey, forKey: "identity")

        scrollView?.layer.add(boundsAnimation, forKey: refreshHeaderRefreshing2IdleBoundsKey)

        endRefreshingAnimationBeginAction?()
        // 自动调整透明度的动画
        if isAutomaticallyChangeAlpha {
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = NSNumber(value: Double(viewAlpha))
            opacityAnimation.toValue = NSNumber(value: 0.0)
            opacityAnimation.duration = slowAnimationDuration
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(opacityAnimation, forKey: "CYLRefreshHeaderRefreshing2IdleOpacity")

            // 由于修改了 inset 导致, pullingPercent 被设置值, alpha 已经被提前修改为 0 了. 所以这里不用置 0, 但为了代码的严谨性, 不依赖其他的特殊实现方式, 这里还是置 0.
            alpha = 0
        }
    }

    private func headerRefreshingAction() {
        insetTDelta = 0
        if !movesContentWhileRefreshing {
            // [EN] Front: the content stays where it is. [CN] 前置：内容保持不动。
            addedRefreshingInset = false
            executeRefreshingCallback()
            return
        }
        addedRefreshingInset = true
        // 默认使用 UIViewAnimation 动画
        if !isCollectionViewAnimationBug {
            UIView.animate(withDuration: fastAnimationDuration, animations: {
                // [EN] Without a scroll view the Objective-C check passed too (nil's state is not "cancelled").
                // [CN] 没有滚动视图时 Objective-C 的检查同样通过（nil 的状态不是“已取消”）。
                if self.scrollView?.panGestureRecognizer.state != .cancelled {
                    let top = self.scrollViewOriginalInset.top + self.expandHeight
                    // [EN] From the original top, not the current one: resetInset may already have moved the inset while
                    //      the pull was released, and a delta measured from there is wrong by that much.
                    // [CN] 以原始 top 计算，而不是当前 top：松手时 resetInset 可能已移动过 inset，从那里量出的差值会差出同样的量。
                    self.insetTDelta = self.scrollViewOriginalInset.top - top
                    // 增加滚动区域top
                    self.setRefreshingInsetTop(top)
                    // 设置滚动位置
                    if let scrollView = self.scrollView {
                        var offset = scrollView.contentOffset
                        offset.y = -top
                        scrollView.setContentOffset(offset, animated: false)
                    }
                }
            }, completion: { _ in
                self.executeRefreshingCallback()
            })
            return
        }

        if scrollView?.panGestureRecognizer.state != .cancelled {
            let top = scrollViewOriginalInset.top + expandHeight
            // 禁用交互, 如果不禁用可能会引起渲染问题.
            scrollView?.isUserInteractionEnabled = false

            // CAAnimation keyPath不支持 contentOffset 用Bounds的动画代替
            let boundsAnimation = CABasicAnimation(keyPath: "bounds")
            let fromBounds = scrollView?.bounds ?? .zero
            var bounds = fromBounds
            bounds.origin.y = -top
            boundsAnimation.fromValue = NSValue(cgRect: fromBounds)
            boundsAnimation.toValue = NSValue(cgRect: bounds)
            boundsAnimation.duration = fastAnimationDuration
            //在delegate里移除
            boundsAnimation.isRemovedOnCompletion = false
            boundsAnimation.fillMode = .both
            boundsAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            boundsAnimation.delegate = CYLRefreshHeaderAnimationDelegate(header: self)
            boundsAnimation.setValue(refreshHeaderRefreshingBoundsKey, forKey: "identity")
            scrollView?.layer.add(boundsAnimation, forKey: refreshHeaderRefreshingBoundsKey)
        } else {
            executeRefreshingCallback()
        }
    }

    // MARK: - Chaining

    /**
     * [EN] Sets the header as `scrollView.cylHeader` and returns it. [CN] 设为 `scrollView.cylHeader` 并返回自身。
     */
    open override func link(to scrollView: UIScrollView) -> Self {
        scrollView.cylHeader = self
        return self
    }

    // MARK: - CAAnimationDelegate (through CYLRefreshHeaderAnimationDelegate)

    fileprivate func boundsAnimationDidStop(_ anim: CAAnimation) {
        let identity = anim.value(forKey: "identity") as? String
        if identity == refreshHeaderRefreshing2IdleBoundsKey {
            retracting = false
            pullingPercent = 0.0
            scrollView?.isUserInteractionEnabled = true
            endRefreshingCompletionBlock?()
        } else if identity == refreshHeaderRefreshingBoundsKey {
            // 避免出现 end 先于 Refreshing 状态
            if state != .idle {
                let top = scrollViewOriginalInset.top + expandHeight
                // [EN] From the original top (see headerRefreshingAction). [CN] 以原始 top 计算（见 headerRefreshingAction）。
                insetTDelta = scrollViewOriginalInset.top - top
                setRefreshingInsetTop(top)
                // 设置最终滚动位置
                if let scrollView = scrollView {
                    var offset = scrollView.contentOffset
                    offset.y = -top
                    scrollView.setContentOffset(offset, animated: false)
                }
            }
            scrollView?.isUserInteractionEnabled = true
            executeRefreshingCallback()
        }

        if scrollView?.layer.animation(forKey: refreshHeaderRefreshing2IdleBoundsKey) != nil {
            scrollView?.layer.removeAnimation(forKey: refreshHeaderRefreshing2IdleBoundsKey)
        }

        if scrollView?.layer.animation(forKey: refreshHeaderRefreshingBoundsKey) != nil {
            scrollView?.layer.removeAnimation(forKey: refreshHeaderRefreshingBoundsKey)
        }
    }
}
