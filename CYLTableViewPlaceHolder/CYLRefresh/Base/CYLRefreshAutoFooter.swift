//
//  CYLRefreshAutoFooter.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

// [EN] Swift since 2026-11-20 (docs/Swift-Migration.md, step 11), with the same Objective-C API (`automaticallyRefresh`
//      with its `isAutomaticallyRefresh` getter, `triggerAutomaticallyRefreshPercent`, `autoTriggerTimes`,
//      `loadsWhenContentNotFull`) and the same behavior: the automatic load when the footer scrolls into view, the trigger
//      count per drag, the bottom inset kept while shown, and the paging alignment after a load (issue MJRefresh#1610). The
//      private `-beginRefreshingWithoutValidation`, which `CYLRefreshAutoStateFooter` reached by selector, is the
//      internal `beginRefreshingWithoutValidation()`. The class factories (`+footerWithRefreshingBlock:`,
//      `+footerWithRefreshingTarget:refreshingAction:`) are inherited and still return the class they are sent to.
// [CN] 自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 11 步），Objective-C API（getter 为 `isAutomaticallyRefresh` 的
//      `automaticallyRefresh`、`triggerAutomaticallyRefreshPercent`、`autoTriggerTimes`、`loadsWhenContentNotFull`）与行为均不变：滚动到可见时
//      自动加载、每次拖动的触发次数、显示时保留底部 inset、加载后分页对齐（issue MJRefresh#1610）。私有的 `-beginRefreshingWithoutValidation`
//      （`CYLRefreshAutoStateFooter` 曾按选择器调用）现为 internal 的 `beginRefreshingWithoutValidation()`。类工厂方法
//      （`+footerWithRefreshingBlock:`、`+footerWithRefreshingTarget:refreshingAction:`）继承而来，仍返回接收消息的类。

import UIKit

/**
 * [EN] A footer that sits right after the content and loads more by itself when it scrolls into view (see
 *      `automaticallyRefresh` and `triggerAutomaticallyRefreshPercent`), or when tapped; the base of the automatic
 *      footers.
 * [CN] 紧跟在内容之后的刷新尾，滚动到可见时自动加载更多（见 `automaticallyRefresh` 与
 *      `triggerAutomaticallyRefreshPercent`），也可点击加载；各自动刷新尾的基类。
 */
@objc(CYLRefreshAutoFooter)
open class CYLRefreshAutoFooter: CYLRefreshFooter {

    // MARK: - Private state

    // [EN] 一个新的拖拽: the current load was started by a drag. [CN] 一个新的拖拽：当前加载由拖动触发。
    private var triggerByDrag = false
    private var leftTriggerTimes = 0
    private var storedAutomaticallyRefresh = false
    private var storedAutoTriggerTimes = 0

    // MARK: - Public properties

    /**
     * [EN] Whether the footer loads by itself when it scrolls into view (default YES).
     * [CN] 是否自动刷新(默认为YES)。
     */
    @objc(automaticallyRefresh)
    open var isAutomaticallyRefresh: Bool {
        @objc(isAutomaticallyRefresh) get { storedAutomaticallyRefresh }
        @objc(setAutomaticallyRefresh:) set { storedAutomaticallyRefresh = newValue }
    }

    /**
     * [EN] How much of the footer must show before it loads by itself (default 1.0, the whole footer).
     * [CN] 当底部控件出现多少时就自动刷新(默认为1.0，也就是底部控件完全出现时，才会自动刷新)。
     */
    @objc open var triggerAutomaticallyRefreshPercent: CGFloat = 0

    /**
     * [EN] Automatic loads allowed per drag (default 1; only while dragging); -1 means unlimited.
     * [CN] 自动触发次数, 默认为 1, 仅在拖拽 ScrollView 时才生效; 如果为 -1, 则为无限触发。
     */
    @objc open var autoTriggerTimes: Int {
        get { storedAutoTriggerTimes }
        set {
            storedAutoTriggerTimes = newValue
            leftTriggerTimes = newValue
        }
    }

    /**
     * [EN] Loads more on a pull-up release when the content does not fill the scroll view; NO waits for content that
     *      fills it (CYLRefreshLayout's `setEnableLoadMoreWhenContentNotFull`). Default YES.
     * [CN] 内容不满一屏时，上拉松手也加载更多；NO 时等内容填满后才加载（对应 CYLRefreshLayout 的
     *      `setEnableLoadMoreWhenContentNotFull`）。默认 YES。
     */
    @objc open var loadsWhenContentNotFull = false

    // MARK: - Overrides of CYLRefreshComponent

    /**
     * [EN] Moves the footer's bottom inset from the old scroll view to the new one and places the footer after the
     *      content. [CN] 把刷新尾的底部 inset 从旧滚动视图移到新滚动视图，并把刷新尾放在内容之后。
     */
    open override func willMove(toSuperview newSuperview: UIView?) {
        if let oldScrollView = scrollView, !isHidden {
            oldScrollView.cylInsetB -= cylH
        }
        super.willMove(toSuperview: newSuperview)

        // 新的父控件
        if let scrollView = scrollView {
            if !isHidden {
                scrollView.cylInsetB += cylH
            }

            // 设置位置
            cylY = scrollView.cylContentH + ignoredScrollViewContentInsetBottom
        }
    }

    /**
     * [EN] Sets the defaults: loads by itself once fully shown, once per drag, also with short content.
     * [CN] 设置默认值：完全出现时自动加载，每次拖动一次，内容不满一屏时也加载。
     */
    open override func prepare() {
        super.prepare()

        // 默认底部控件100%出现时才会自动刷新
        triggerAutomaticallyRefreshPercent = 1.0
        loadsWhenContentNotFull = true

        // 设置为默认状态
        isAutomaticallyRefresh = true

        autoTriggerTimes = 1
    }

    /**
     * [EN] Keeps the footer right after the content. [CN] 让刷新尾紧跟在内容之后。
     */
    open override func scrollViewContentSizeDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentSizeDidChange(change)

        let size = (change?[NSKeyValueChangeKey.newKey.rawValue] as? NSValue)?.cgSizeValue ?? .zero
        let contentHeight = size.height == 0 ? (scrollView?.cylContentH ?? 0) : size.height
        // 设置位置
        let y = contentHeight + ignoredScrollViewContentInsetBottom
        if cylY != y {
            cylY = y
        }
    }

    /**
     * [EN] Loads by itself when the footer has scrolled into view (`triggerAutomaticallyRefreshPercent`).
     * [CN] 刷新尾滚动到可见时自动加载（`triggerAutomaticallyRefreshPercent`）。
     */
    open override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentOffsetDidChange(change)

        if state != .idle || !isAutomaticallyRefresh || !isRefreshEnabled || cylY == 0 ||
            scrollView?.cylHeader?.isRefreshing == true { return }
        guard let scrollView = scrollView else { return }

        // 内容超过一个屏幕
        if scrollView.cylInsetT + scrollView.cylContentH > scrollView.cylH {
            // 这里的_scrollView.cylContentH替换掉self.cylY更为合理
            if canTrigger() &&
                scrollView.cylOffsetY >= scrollView.cylContentH - scrollView.cylH + cylH * triggerAutomaticallyRefreshPercent +
                scrollView.cylInsetB - cylH {
                // 防止手松开时连续调用
                let old = (change?["old"] as? NSValue)?.cgPointValue ?? .zero
                let new = (change?["new"] as? NSValue)?.cgPointValue ?? .zero
                if new.y <= old.y { return }
                if new.y <= -scrollView.cylInsetT { return }

                if scrollView.isDragging {
                    triggerByDrag = true
                }
                // 当底部刷新控件完全出现时，才刷新
                beginRefreshing()
            }
        }
    }

    /**
     * [EN] Loads on a release at the end of the content; a drag start resets the trigger count.
     * [CN] 在内容末端松手时加载；拖动开始时重置触发次数。
     */
    open override func scrollViewPanStateDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewPanStateDidChange(change)

        let panState = scrollView?.panGestureRecognizer.state
        // [EN] loadsAfterNoMoreData: a pull at the end loads again. [CN] loadsAfterNoMoreData：在底部上拉时再次加载。
        if state == .noMoreData && loadsAfterNoMoreData && panState == .ended {
            resetNoMoreData()
        }
        if state != .idle || !isRefreshEnabled || scrollView?.cylHeader?.isRefreshing == true || !canTrigger() { return }
        guard let scrollView = scrollView else { return }

        switch scrollView.panGestureRecognizer.state {
        // 手松开
        case .ended:
            // 不够一个屏幕
            if scrollView.cylInsetT + scrollView.cylContentH <= scrollView.cylH {
                // 向上拽
                if loadsWhenContentNotFull && scrollView.cylOffsetY >= -scrollView.cylInsetT {
                    triggerByDrag = true
                    beginRefreshing()
                }
            } else {
                // 超出一个屏幕
                let threshold = scrollView.cylContentH + scrollView.cylInsetB - scrollView.cylH
                let offset = scrollView.cylOffsetY
                let epsilon = CGFloat.ulpOfOne
                // Allow arithmetic rounding error without treating a visible gap as the bottom.
                let tolerance = 64 * epsilon * max(1, max(abs(offset), abs(threshold)))
                if offset >= threshold - tolerance {
                    triggerByDrag = true
                    beginRefreshing()
                }
            }

        case .began:
            resetTriggerTimes()

        default:
            break
        }
    }

    // [EN] The driven mode (`CYLRefreshDrivenLayout`): a new drag resets the trigger count, as a pan `.began` does.
    // [CN] 驱动模式（`CYLRefreshDrivenLayout`）：新的拖动重置触发次数，与手势 `.began` 相同。
    func drivenDragBegan() {
        resetTriggerTimes()
    }

    // [EN] The driven mode: the finger lifted after a pull at the end of the host's content, which is the footer being in
    //      view, so it loads as a release at the end does (the driven scroll view has no content of its own, so the
    //      content-not-full test does not apply).
    // [CN] 驱动模式：宿主内容末端被上拉后手指抬起，即刷新尾已可见，按末端松手加载（驱动的滚动视图自身没有内容，故不适用内容不满一屏的判断）。
    func drivenReleased() {
        if state != .idle || !isRefreshEnabled || scrollView?.cylHeader?.isRefreshing == true || !canTrigger() { return }
        triggerByDrag = true
        beginRefreshing()
    }

    private var unlimitedTrigger: Bool {
        leftTriggerTimes == -1
    }

    /**
     * [EN] Does nothing when a drag started the load and this drag's automatic loads are used up.
     * [CN] 由拖动触发且本次拖动的自动加载次数已用完时不做任何事。
     */
    open override func beginRefreshing() {
        if triggerByDrag && leftTriggerTimes <= 0 && !unlimitedTrigger {
            return
        }

        super.beginRefreshing()
    }

    // [EN] Begins refreshing through CYLRefreshFooter's `-beginRefreshing`, past this class's trigger-count check: the tap
    //      on `CYLRefreshAutoStateFooter`'s idle text.
    // [CN] 经由 CYLRefreshFooter 的 `-beginRefreshing` 开始刷新，跳过本类的触发次数检查：供 `CYLRefreshAutoStateFooter` 点击闲置文字时调用。
    func beginRefreshingWithoutValidation() {
        super.beginRefreshing()
    }

    /**
     * [EN] Loads when refreshing starts; after a load, counts the trigger and puts a paging scroll view on a page.
     * [CN] 开始刷新时加载；加载结束后计入触发次数，并让分页滚动视图停在整页。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue

            if newValue == .refreshing {
                executeRefreshingCallback()
            } else if newValue == .noMoreData || newValue == .idle {
                if triggerByDrag {
                    if !unlimitedTrigger {
                        leftTriggerTimes -= 1
                    }
                    triggerByDrag = false
                }

                if oldState == .refreshing {
                    if scrollView?.isPagingEnabled == true {
                        UIView.animate(withDuration: slowAnimationDuration, animations: {
                            self.alignPageAfterLoading()

                            self.endRefreshingAnimationBeginAction?()
                        }, completion: { _ in
                            self.endRefreshingCompletionBlock?()
                        })
                        return
                    }

                    endRefreshingCompletionBlock?()
                }
            }
        }
    }

    // [EN] Inside the end-of-load animation of a paging scroll view. [CN] 在分页滚动视图加载结束的动画中调用。
    private func alignPageAfterLoading() {
        guard let scrollView = scrollView, !scrollView.isDragging, !scrollView.isDecelerating else { return }
        var offset = scrollView.contentOffset
        let bottomInset = scrollView.cylInsetB - (isHidden ? 0 : cylH)
        let maximumOffset = max(-scrollView.cylInsetT, scrollView.cylContentH + bottomInset - scrollView.cylH)
        // FIX: issue MJRefresh#1610 (page alignment)
        // [EN] The load started with the footer's space showing past the last page, so the offset
        //      sits between two page boundaries; once new pages arrived it is no longer out of range,
        //      and paging would leave the page shifted by the footer's height. Rest on the nearest
        //      place paging itself can stop at: a page boundary within range, or the end of the content
        //      (which a caller's own bottom inset may put between two boundaries).
        // [CN] 加载开始时最后一页之后露出了刷新尾的空间，offset 位于两个分页边界之间；有新页加入后它不再越界，
        //      分页会让该页错开刷新尾的高度。停到分页本身能停下的最近位置：范围内的分页边界，或内容末端（调用方自己的
        //      底部 inset 可能使其位于两个边界之间）。
        let top = scrollView.cylInsetT
        var target = maximumOffset
        let pageHeight = scrollView.bounds.height
        if pageHeight > 0 {
            let boundary = ((offset.y + top) / pageHeight).rounded() * pageHeight - top
            if boundary <= maximumOffset && abs(boundary - offset.y) < abs(target - offset.y) {
                target = boundary
            }
        }
        offset.y = max(-top, target)
        if abs(offset.y - scrollView.contentOffset.y) > 0.5 {
            scrollView.contentOffset = offset
        }
    }

    private func resetTriggerTimes() {
        leftTriggerTimes = autoTriggerTimes
    }

    /**
     * [EN] Hiding gives the footer's bottom inset back (and ends a load); showing takes it again.
     * [CN] 隐藏时归还刷新尾的底部 inset（并结束加载）；显示时重新占用。
     */
    open override var isHidden: Bool {
        get { super.isHidden }
        set {
            let lastHidden = isHidden

            super.isHidden = newValue

            if !lastHidden && newValue {
                state = .idle

                scrollView?.cylInsetB -= cylH
            } else if lastHidden && !newValue {
                scrollView?.cylInsetB += cylH

                // 设置位置
                cylY = (scrollView?.cylContentH ?? 0) + ignoredScrollViewContentInsetBottom
            }
        }
    }
}
