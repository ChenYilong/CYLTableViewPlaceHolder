//
//  CYLRefreshBackFooter.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-20 (docs/Swift-Migration.md, step 11), with the same Objective-C API
//      (`noMoreDataDisplayDuration`, `followsContentWhenNoMoreData`, `scrollsContentAfterLoading`, the second floor) and
//      the same behavior: the bottom inset given back after loading, a paging scroll view put back on a page (MJRefresh
//      #1430), "no more data" held for `noMoreDataDisplayDuration` or until the state changes (upstream #1585). The
//      private `happenOffsetY`, which `CYLRefreshDrawnFooter.swift` reached by selector, is the internal `happenOffsetY`.
//      The class factories (`+footerWithRefreshingBlock:`, `+footerWithRefreshingTarget:refreshingAction:`) are inherited
//      and still return the class they are sent to.
// [CN] 自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 11 步），Objective-C API（`noMoreDataDisplayDuration`、
//      `followsContentWhenNoMoreData`、`scrollsContentAfterLoading`、二楼）与行为均不变：加载结束后归还底部 inset，分页滚动视图回到整页
//      （MJRefresh #1430），“无更多数据”保持 `noMoreDataDisplayDuration` 秒或直到状态改变（upstream #1585）。私有的 `happenOffsetY`
//      （`CYLRefreshDrawnFooter.swift` 曾按选择器调用）现为 internal 的 `happenOffsetY`。类工厂方法（`+footerWithRefreshingBlock:`、
//      `+footerWithRefreshingTarget:refreshingAction:`）继承而来，仍返回接收消息的类。

import UIKit

/**
 * [EN] A footer that stays hidden below the content and loads more when the user pulls up past it and releases; the
 *      scroll view rebounds when loading ends. The base of the back footers, with the optional second floor.
 * [CN] 隐藏在内容下方的刷新尾，用户上拉越过它并松手时加载更多，加载结束后滚动视图回弹。各回弹刷新尾的基类，支持可选的二楼。
 */
@objc(CYLRefreshBackFooter)
open class CYLRefreshBackFooter: CYLRefreshFooter {

    // MARK: - Private state

    private var lastRefreshCount = 0
    private var lastBottomDelta: CGFloat = 0
    private var pagingRestingOffset: CGFloat = 0
    private var pagingRefreshOffset: CGFloat = 0
    // FIX: issue #1627 / #1507
    // [EN] Moves the offset when loading starts and ends in a scroll view that pins its section headers. An offset written
    //      inside a UIView animation animates the bounds, while the pinned header is placed once, at the final offset: it
    //      showed above the top (up to the footer's height) and slid back while the bounds animated. Written frame by
    //      frame, every frame lays out and pins the header again.
    // [CN] 在固定 section header 的滚动视图中，加载开始和结束时移动 offset。在 UIView 动画内写 offset 会动画 bounds，而固定的
    //      header 只按最终 offset 放置一次：它露出顶部之外（最多一个刷新尾高度），随 bounds 动画慢慢滑回。逐帧写入时，每一帧都重新布局并固定 header。
    private let offsetDriver = CYLRefreshOffsetDriver()

    private var holdingNoMoreData = false
    // [EN] Second floor state. [CN] 二楼状态。
    private var secondaryArmed = false
    private var secondaryClosePending = false
    private var secondaryClosing = false
    private var storedSecondaryOpen = false
    private var noMoreDataHoldToken: UInt = 0
    // [EN] Whether the current drag started with the list at the bottom edge (triggerMode). [CN] 当前拖动开始时列表是否在底部边缘（triggerMode）。
    private var dragStartedAtEdge = false
    private var storedSecondaryCloseTriggerOffset: CGFloat = 0
    private var storedSecondaryView: UIView?

    // MARK: - Public properties

    /**
     * Seconds the "no more data" text stays visible, with the footer held open, after a load that ends with
     * `endRefreshingWithNoMoreData`, before the scroll view rebounds (upstream #1585, case 2). Default 0: rebound at once, as
     * before. Starting another load, `resetNoMoreData` or removing the footer ends the hold at once. It does not apply when the
     * state is set without a load in progress, so the case "already no-more-data on entry; show the text for N seconds after a
     * pull-up" is not covered.
     */
    @objc open var noMoreDataDisplayDuration: TimeInterval = 0

    /**
     * [EN] Keeps the footer shown after the content while there is no more data, until the state changes
     *      (CYLRefreshLayout's `setEnableFooterFollowWhenNoMoreData`). Default NO.
     * [CN] 没有更多数据时让尾部一直显示在内容之后，直到状态改变（对应 CYLRefreshLayout 的
     *      `setEnableFooterFollowWhenNoMoreData`）。默认 NO。
     */
    @objc open var followsContentWhenNoMoreData = false

    /**
     * [EN] After loading more, leaves the new rows in the place the footer showed, so they come into view; NO keeps the
     *      old end of the content in place (CYLRefreshLayout's `setEnableScrollContentWhenLoaded`). Default YES.
     * [CN] 加载更多后，新数据留在尾部原来显示的位置，从而进入可见区域；NO 时保持原来内容末尾的位置（对应 CYLRefreshLayout 的
     *      `setEnableScrollContentWhenLoaded`）。默认 YES。
     */
    @objc open var scrollsContentAfterLoading = true

    /**
     * [EN] Pulling up at least this far (points) and releasing opens the footer's second floor below the list instead of
     *      loading; 0 (default) turns it off (flutter_easy_refresh's footer `secondaryTriggerOffset`).
     * [CN] 至少上拉这么远（点）后松手，会在列表下方打开刷新尾的二楼而不是加载；0（默认）关闭（对应 flutter_easy_refresh 刷新尾的
     *      `secondaryTriggerOffset`）。
     */
    @objc open var secondaryTriggerOffset: CGFloat = 0

    /**
     * [EN] Height of the open second floor (points); 0 (default) uses the scroll view's visible height.
     * [CN] 打开后二楼的高度（点）；0（默认）表示使用滚动视图的可见高度。
     */
    @objc open var secondaryDimension: CGFloat = 0

    /**
     * [EN] While open, pulling the content down this far (points) and releasing closes it. Default 80.
     * [CN] 打开时，把内容往下拉这么远（点）再松手即关闭。默认 80。
     */
    @objc open var secondaryCloseTriggerOffset: CGFloat {
        get { storedSecondaryCloseTriggerOffset > 0 ? storedSecondaryCloseTriggerOffset : 80 }
        set { storedSecondaryCloseTriggerOffset = newValue }
    }

    /**
     * [EN] The second floor's content, placed below the list across the whole floor (flutter_easy_refresh's
     *      `SecondaryBuilderFooter`). [CN] 二楼的内容视图，放在列表下方、铺满整个二楼（对应 flutter_easy_refresh 的 `SecondaryBuilderFooter`）。
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
     * [EN] Releasing a pull-up at least this fast (points per second) past the load trigger opens the second floor; 0
     *      (default) turns it off. [CN] 越过加载触发点后，以至少这个速度（点/秒）松手即打开二楼；0（默认）关闭。
     */
    @objc open var secondaryVelocity: CGFloat = 0

    // MARK: - Overrides of CYLRefreshComponent

    /**
     * [EN] Gives back a held bottom inset before leaving the scroll view, then places the footer.
     * [CN] 离开滚动视图前归还保持的底部 inset，然后放置刷新尾。
     */
    open override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            offsetDriver.stop()
            // Give back the held-open bottom inset while the scroll view is still known.
            endNoMoreDataHold()
        }
        super.willMove(toSuperview: newSuperview)

        scrollViewContentSizeDidChange(nil)
    }

    /**
     * [EN] Follows the pull-up: arms, loads on release, and the second floor. [CN] 跟随上拉：触发、松手加载以及二楼。
     */
    open override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentOffsetDidChange(change)

        // 如果正在刷新，直接返回
        if state == .refreshing { return }
        // The inset is held open while "no more data" stays visible; it is not the original inset.
        if holdingNoMoreData { return }
        // [EN] The second floor holds its own inset. [CN] 二楼占用了自己的 inset。
        if isSecondaryOpen || secondaryClosing {
            followOpenSecondary()
            return
        }

        guard let scrollView = scrollView else { return }
        scrollViewOriginalInset = scrollView.cylInset

        // 当前的contentOffset
        var currentOffsetY = scrollView.cylOffsetY
        // 尾部控件刚好出现的offsetY
        let happenOffsetY = self.happenOffsetY
        // 如果是向下滚动到看不见尾部控件，直接返回
        if currentOffsetY <= happenOffsetY { return }

        // [EN] dragRate scales the pull. [CN] dragRate 按比例缩放拉动距离。
        if state != .noMoreData {
            currentOffsetY = offset(forDragRate: currentOffsetY, happenOffset: happenOffsetY)
        }
        var pullingPercent = (currentOffsetY - happenOffsetY) / (cylH * triggerRate)

        let normal2pullingOffsetY = happenOffsetY + cylH * triggerRate
        // 如果已全部加载，仅设置pullingPercent，然后返回
        if state == .noMoreData {
            // [EN] loadsAfterNoMoreData: pulling past the trigger point loads again. [CN] loadsAfterNoMoreData：拉过触发点再次加载。
            if loadsAfterNoMoreData && scrollView.isDragging && currentOffsetY > normal2pullingOffsetY {
                resetNoMoreData()
            } else {
                self.pullingPercent = pullingPercent
                return
            }
        }

        // [EN] Second floor: arm past its trigger while dragging, open on release. [CN] 二楼：拖动中越过触发点即就绪，松手打开。
        if secondaryTriggerOffset > 0 && state != .noMoreData {
            let armed = scrollView.isDragging && currentOffsetY - happenOffsetY >= secondaryTriggerOffset
            if scrollView.isDragging && armed != secondaryArmed {
                secondaryArmed = armed
                reportPhaseChange()
            } else if !scrollView.isDragging && secondaryArmed {
                openSecondary()
                return
            }
        }

        if scrollView.isDragging {
            // [EN] maxPullDistance: hold the pull at the limit. [CN] maxPullDistance：把上拉停在上限。
            if maxPullDistance > 0 && currentOffsetY - happenOffsetY > maxPullDistance {
                currentOffsetY = happenOffsetY + maxPullDistance
                pullingPercent = maxPullDistance / (cylH * triggerRate)
                scrollView.contentOffset = CGPoint(x: scrollView.cylOffsetX, y: currentOffsetY)
            }
            self.pullingPercent = pullingPercent
            // 普通 和 即将刷新 的临界点

            let mayArm = triggerMode == .anywhere || dragStartedAtEdge
            if state == .idle && isRefreshEnabled && mayArm && canTrigger() && currentOffsetY > normal2pullingOffsetY {
                // 转为即将刷新状态
                state = .pulling
                if triggersWhenReached { beginRefreshing() }
            } else if state == .pulling && currentOffsetY <= normal2pullingOffsetY {
                // 转为普通状态
                state = .idle
            }
        } else if state == .pulling {
            // 即将刷新 && 手松开
            // 开始刷新
            beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }

    /**
     * [EN] Places the footer below the content (or below the visible area when the content is shorter).
     * [CN] 把刷新尾放在内容下方（内容较短时放在可见区域下方）。
     */
    open override func scrollViewContentSizeDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentSizeDidChange(change)
        placeSecondaryView()

        let size = (change?[NSKeyValueChangeKey.newKey.rawValue] as? NSValue)?.cgSizeValue ?? .zero
        var contentHeight = size.height == 0 ? (scrollView?.cylContentH ?? 0) : size.height
        // 内容的高度
        contentHeight += ignoredScrollViewContentInsetBottom
        // 表格的高度
        let scrollHeight = (scrollView?.cylH ?? 0) - scrollViewOriginalInset.top - scrollViewOriginalInset.bottom +
            ignoredScrollViewContentInsetBottom
        // 设置位置
        let y = max(contentHeight, scrollHeight) - insetStart
        if cylY != y {
            cylY = y
        }
    }

    /**
     * [EN] Opens the bottom inset while loading and gives it back afterwards (held for "no more data" when asked).
     * [CN] 加载时打开底部 inset，结束后归还（需要时为“无更多数据”保持）。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue

            // Leaving the held "no more data" state (reset, a new load) gives the bottom inset back first.
            if newValue != .noMoreData {
                endNoMoreDataHold()
            }

            // 根据状态来设置属性
            if newValue == .noMoreData || newValue == .idle {
                // 刷新完毕
                if oldState == .refreshing {
                    if newValue == .noMoreData && followsContentWhenNoMoreData {
                        // [EN] Held until the state changes (endNoMoreDataHold). [CN] 保持到状态改变（endNoMoreDataHold）。
                        holdingNoMoreData = true
                        noMoreDataHoldToken &+= 1
                    } else if newValue == .noMoreData && noMoreDataDisplayDuration > 0 {
                        holdNoMoreData(for: noMoreDataDisplayDuration)
                    } else {
                        restoreBottomInsetAfterRefresh()
                    }
                }

                let deltaH = heightForContentBreakView
                // 刚刷新完毕
                if oldState == .refreshing && deltaH > 0, let scrollView = scrollView,
                   scrollView.cylTotalDataCount() != lastRefreshCount {
                    scrollView.cylOffsetY = scrollView.cylOffsetY
                    // [EN] scrollsContentAfterLoading NO: the old end of the content stays at the bottom. [CN] 为 NO 时原来的内容末尾停在底部。
                    if !scrollsContentAfterLoading && scrollView.cylOffsetY > pagingRestingOffset {
                        scrollView.cylOffsetY = pagingRestingOffset
                        offsetDriver.retarget(to: pagingRestingOffset)
                    }
                }
            } else if newValue == .refreshing {
                // 记录刷新前的数量
                lastRefreshCount = scrollView?.cylTotalDataCount() ?? 0
                pagingRestingOffset = happenOffsetY

                if let scrollView = scrollView, pinsSectionHeaders(of: scrollView), fastAnimationDuration > 0 {
                    // FIX: issue #1627 / #1507: see offsetDriver.
                    let from = scrollView.cylOffsetY
                    var bottom = cylH + scrollViewOriginalInset.bottom
                    let deltaH = heightForContentBreakView
                    if deltaH < 0 {
                        bottom -= deltaH
                    }
                    lastBottomDelta = bottom - scrollView.cylInsetB
                    scrollView.cylInsetB = bottom
                    pagingRefreshOffset = happenOffsetY + cylH
                    scrollView.cylOffsetY = from
                    offsetDriver.move(scrollView, from: from, to: pagingRefreshOffset, duration: fastAnimationDuration) {
                        [weak self] in self?.executeRefreshingCallback()
                    }
                    return
                }
                UIView.animate(withDuration: fastAnimationDuration, animations: {
                    var bottom = self.cylH + self.scrollViewOriginalInset.bottom
                    let deltaH = self.heightForContentBreakView
                    // 如果内容高度小于view的高度
                    if deltaH < 0 {
                        bottom -= deltaH
                    }
                    self.lastBottomDelta = bottom - (self.scrollView?.cylInsetB ?? 0)
                    self.scrollView?.cylInsetB = bottom
                    self.pagingRefreshOffset = self.happenOffsetY + self.cylH
                    self.scrollView?.cylOffsetY = self.pagingRefreshOffset
                }, completion: { _ in
                    self.executeRefreshingCallback()
                })
            }
        }
    }

    // MARK: - 刷新结束：归还底部 inset

    // [EN] YES for a plain table and a flow layout that pins its section headers or footers.
    // [CN] plain 表格、以及固定 section header 或 footer 的 flow layout 为 YES。
    private func pinsSectionHeaders(of scrollView: UIScrollView) -> Bool {
        if let table = scrollView as? UITableView {
            return table.style == .plain
        }
        if let collection = scrollView as? UICollectionView,
           let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.sectionHeadersPinToVisibleBounds || layout.sectionFootersPinToVisibleBounds
        }
        return false
    }

    // [EN] YES when a paging scroll view rests between two pages, as UIKit's paging deceleration can leave it after the
    //      footer's refresh animation moved the offset (MJRefresh #1430: the page ended about 0.22 of a page off).
    // [CN] 分页滚动视图停在两页之间时为 YES；刷新尾的动画改动 offset 后，UIKit 的分页减速可能把它留在这种位置（MJRefresh #1430）。
    private var isBetweenPages: Bool {
        guard let scrollView = scrollView else { return false }
        let page = scrollView.cylH
        if page <= 0 { return false }
        let position = (scrollView.cylOffsetY + scrollView.cylInsetT) / page
        return abs(position - position.rounded()) > 0.001
    }

    // [EN] Moves a paging scroll view onto the nearest page inside its content. [CN] 把分页滚动视图移到内容范围内最近的一页。
    private func alignToNearestPage() {
        guard let scrollView = scrollView else { return }
        let page = scrollView.cylH
        if page <= 0 { return }
        let top = -scrollView.cylInsetT
        let maxOffset = max(top, scrollView.cylContentH - page + scrollView.cylInsetB)
        var aligned = top + ((scrollView.cylOffsetY - top) / page).rounded() * page
        aligned = min(max(aligned, top), maxOffset)
        if abs(aligned - scrollView.cylOffsetY) > 0.001 {
            scrollView.setContentOffset(CGPoint(x: scrollView.cylOffsetX, y: aligned), animated: false)
        }
    }

    private func restoreBottomInsetAfterRefresh() {
        // [EN] A paging scroll view goes back to the page it showed before the refresh when the offset is still the
        //      refresh's own, or when it rests between pages (#1430); a page the caller chose, a drag or a deceleration is
        //      left alone. [CN] 分页滚动视图在 offset 仍是刷新设置的值、或停在两页之间时（#1430）回到刷新前的页面；调用方选定的页面、
        //      拖动中或减速中不做处理。
        var restorePagingOffset = false
        if let scrollView = scrollView {
            restorePagingOffset = scrollView.isPagingEnabled && !scrollView.isDragging && !scrollView.isDecelerating &&
                (abs(scrollView.cylOffsetY - pagingRefreshOffset) < 0.001 || isBetweenPages)
        }
        if !restorePagingOffset, let scrollView = scrollView, pinsSectionHeaders(of: scrollView), slowAnimationDuration > 0 {
            // FIX: issue #1627 / #1507: see offsetDriver.
            let from = scrollView.cylOffsetY
            scrollView.cylInsetB -= lastBottomDelta
            let maxOffset = max(-scrollView.cylInsetT, scrollView.cylContentH - scrollView.cylH + scrollView.cylInsetB)
            scrollView.cylOffsetY = from
            UIView.animate(withDuration: slowAnimationDuration, delay: 0, options: reboundAnimationOptions, animations: {
                self.endRefreshingAnimationBeginAction?()
                if self.isAutomaticallyChangeAlpha { self.alpha = 0.0 }
            })
            offsetDriver.move(scrollView, from: from, to: min(from, maxOffset), duration: slowAnimationDuration) { [weak self] in
                guard let self = self else { return }
                self.pullingPercent = 0.0
                self.endRefreshingCompletionBlock?()
            }
            return
        }
        UIView.animate(withDuration: slowAnimationDuration, delay: 0, options: reboundAnimationOptions, animations: {
            self.endRefreshingAnimationBeginAction?()

            if let scrollView = self.scrollView {
                scrollView.cylInsetB -= self.lastBottomDelta
            }
            if restorePagingOffset {
                self.scrollView?.cylOffsetY = self.pagingRestingOffset
            }
            // 自动调整透明度
            if self.isAutomaticallyChangeAlpha { self.alpha = 0.0 }
        }, completion: { _ in
            self.pullingPercent = 0.0
            // [EN] Anything that moved it during the animation cannot leave it between pages.
            // [CN] 动画期间的其他改动也不会让它停在两页之间。
            if restorePagingOffset, let current = self.scrollView, current.isPagingEnabled, !current.isDragging,
               !current.isDecelerating {
                self.alignToNearestPage()
            }

            self.endRefreshingCompletionBlock?()
        })
    }

    // MARK: - 无更多数据：保持显示一段时间再回弹

    private func holdNoMoreData(for duration: TimeInterval) {
        holdingNoMoreData = true
        noMoreDataHoldToken &+= 1
        let token = noMoreDataHoldToken
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self, self.holdingNoMoreData, self.noMoreDataHoldToken == token else { return }
            self.holdingNoMoreData = false
            self.restoreBottomInsetAfterRefresh()
        }
    }

    private func endNoMoreDataHold() {
        if !holdingNoMoreData { return }
        holdingNoMoreData = false
        noMoreDataHoldToken &+= 1
        restoreBottomInsetAfterRefresh()
    }

    // MARK: - 获得scrollView的内容 超出 view 的高度

    private var heightForContentBreakView: CGFloat {
        guard let scrollView = scrollView else { return 0 }
        let h = scrollView.frame.size.height - scrollViewOriginalInset.bottom - scrollViewOriginalInset.top
        return scrollView.contentSize.height - h
    }

    // [EN] 刚好看到上拉刷新控件时的contentOffset.y: the offset where the footer starts to show (`CYLRefreshDrawnFooter` reads it).
    // [CN] 刚好看到上拉刷新控件时的contentOffset.y（`CYLRefreshDrawnFooter` 读取）。
    var happenOffsetY: CGFloat {
        let deltaH = heightForContentBreakView
        if deltaH > 0 {
            return deltaH - scrollViewOriginalInset.top
        } else {
            return -scrollViewOriginalInset.top
        }
    }

    // MARK: - Trigger mode

    private func recordDragStart() {
        guard let scrollView = scrollView, scrollView.panGestureRecognizer.state == .began else { return }
        dragStartedAtEdge = scrollView.cylOffsetY >= happenOffsetY - 0.5
    }

    /**
     * [EN] A fast release can open the second floor; a drag start records whether the list was at its bottom edge.
     * [CN] 快速松手可打开二楼；拖动开始时记录列表是否位于底部边缘。
     */
    open override func scrollViewPanStateDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewPanStateDidChange(change)
        if let scrollView = scrollView {
            let pan = scrollView.panGestureRecognizer
            if pan.state == .ended && secondaryVelocity > 0 && secondaryTriggerOffset > 0 && !isSecondaryOpen &&
                !isRefreshing && state != .noMoreData {
                // [EN] A fast release past the load trigger opens the second floor. [CN] 越过加载触发点后快速松手即打开二楼。
                let velocity = -pan.velocity(in: scrollView).y
                let pulled = scrollView.cylOffsetY - happenOffsetY
                if velocity >= secondaryVelocity && pulled >= cylH * triggerRate {
                    openSecondary()
                    return
                }
            }
        }
        recordDragStart()
    }

    // MARK: - Second floor

    private var secondaryHeight: CGFloat {
        if secondaryDimension > 0 { return secondaryDimension }
        let height = scrollView?.bounds.height ?? 0
        return max(cylH, height - scrollViewOriginalInset.top - scrollViewOriginalInset.bottom)
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

    // [EN] The floor's view sits right below the content, across the whole floor. [CN] 二楼视图紧贴内容下方，铺满整个二楼。
    private func placeSecondaryView() {
        guard let view = secondaryView, let scrollView = scrollView else { return }
        if view.superview !== scrollView { scrollView.insertSubview(view, belowSubview: self) }
        let top = max(scrollView.cylContentH,
                      scrollView.bounds.height - scrollViewOriginalInset.top - scrollViewOriginalInset.bottom)
        view.frame = CGRect(x: -scrollView.cylInsetL, y: top, width: scrollView.cylW, height: secondaryHeight)
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

    /**
     * [EN] Opens the second floor (flutter_easy_refresh's `openFooterSecondary`). [CN] 打开二楼（对应 flutter_easy_refresh 的 `openFooterSecondary`）。
     */
    @objc open func openSecondary() {
        if isSecondaryOpen || scrollView == nil || isRefreshing { return }
        secondaryArmed = false
        if state == .pulling { state = .idle }
        placeSecondaryView()
        storedSecondaryOpen = true
        reportPhaseChange()
        let height = secondaryHeight
        let bottom = scrollViewOriginalInset.bottom + height
        let target = happenOffsetY + height
        UIView.animate(withDuration: slowAnimationDuration, animations: {
            self.scrollView?.cylInsetB = bottom
            self.scrollView?.contentOffset = CGPoint(x: self.scrollView?.cylOffsetX ?? 0, y: target)
        }, completion: { _ in
            self.secondaryOpenedBlock?()
        })
    }

    /**
     * [EN] Closes the second floor (flutter_easy_refresh's `closeFooterSecondary`). [CN] 关闭二楼（对应 flutter_easy_refresh 的 `closeFooterSecondary`）。
     */
    @objc open func closeSecondary() {
        if !isSecondaryOpen || secondaryClosing { return }
        secondaryClosing = true
        secondaryClosePending = false
        reportPhaseChange()
        let bottom = scrollViewOriginalInset.bottom
        let target = max(happenOffsetY, -scrollViewOriginalInset.top)
        UIView.animate(withDuration: slowAnimationDuration, animations: {
            self.scrollView?.cylInsetB = bottom
            self.scrollView?.contentOffset = CGPoint(x: self.scrollView?.cylOffsetX ?? 0, y: target)
        }, completion: { _ in
            self.secondaryClosing = false
            self.storedSecondaryOpen = false
            self.pullingPercent = 0
            self.reportPhaseChange()
            self.updateAutoHideVisibility()
            self.secondaryClosedBlock?()
        })
    }

    // [EN] While open: pulling the content down past the close trigger and releasing closes the floor.
    // [CN] 打开时：把内容下拉超过关闭触发距离再松手，即关闭二楼。
    private func followOpenSecondary() {
        if secondaryClosing { return }
        let openOffsetY = happenOffsetY + secondaryHeight
        let pulled = openOffsetY - (scrollView?.cylOffsetY ?? 0)
        if scrollView?.isDragging == true {
            secondaryClosePending = pulled >= secondaryCloseTriggerOffset
        } else if secondaryClosePending {
            closeSecondary()
        }
    }
}

// FIX: issue #1627 / #1507
// [EN] Moves a scroll view's offset frame by frame (ease in, ease out), then runs the completion. A drag, a new move or
//      stop() ends it where it is and runs the completion then, as an interrupted UIView animation does.
// [CN] 逐帧移动滚动视图的 offset（缓入缓出），结束后执行 completion。拖动、新的移动或 stop() 让它停在当前位置并立即执行
//      completion，与被打断的 UIView 动画一致。
final class CYLRefreshOffsetDriver: NSObject {
    private weak var scrollView: UIScrollView?
    private var link: CADisplayLink?
    private var from: CGFloat = 0
    private var to: CGFloat = 0
    private var duration: TimeInterval = 0
    private var start: CFTimeInterval = 0
    private var completion: (() -> Void)?

    var isMoving: Bool { link != nil }

    func move(_ scrollView: UIScrollView, from: CGFloat, to: CGFloat, duration: TimeInterval,
              completion: @escaping () -> Void) {
        stop()
        self.scrollView = scrollView
        self.from = from
        self.to = to
        self.duration = duration
        self.completion = completion
        start = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    func stop() {
        link?.invalidate()
        link = nil
        let done = completion
        completion = nil
        done?()
    }

    // [EN] Moves on to another target from where it is now. [CN] 从当前位置改为移向另一个目标。
    func retarget(to target: CGFloat) {
        guard let scrollView = scrollView, isMoving else { return }
        from = scrollView.contentOffset.y
        to = target
        start = CACurrentMediaTime()
    }

    @objc private func step(_ link: CADisplayLink) {
        guard let scrollView = scrollView, !scrollView.isDragging else {
            stop()
            return
        }
        let t = min(1, (CACurrentMediaTime() - start) / duration)
        let eased = t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: from + (to - from) * CGFloat(eased))
        if t >= 1 {
            stop()
        }
    }
}
