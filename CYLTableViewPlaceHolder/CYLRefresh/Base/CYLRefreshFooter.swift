//
//  CYLRefreshFooter.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/5.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  上拉刷新控件
//

// [EN] Swift since 2026-11-20 (docs/Swift-Migration.md, step 11), with the same Objective-C API (the factories
//      `+footerWithRefreshingBlock:` / `+footerWithRefreshingTarget:refreshingAction:`, which Swift spells as the
//      initializers `init(refreshingBlock:)` / `init(refreshingTarget:refreshingAction:)` as before,
//      `endRefreshingWithNoMoreData`, the deprecated `noticeNoMoreData`, `resetNoMoreData`, `noMoreData` with its
//      `isNoMoreData` getter, `loadsAfterNoMoreData`, `ignoredScrollViewContentInsetBottom`, the deprecated
//      `automaticallyHidden`, and the `CYLRefreshNoMoreDataImage` methods `cyl_updateNoMoreDataImage:` /
//      `cyl_placeNoMoreDataImageBesideLabel:inset:size:`) and the same auto-hide below the bottom bars.
// [CN] 自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 11 步），Objective-C API（工厂方法 `+footerWithRefreshingBlock:` /
//      `+footerWithRefreshingTarget:refreshingAction:`，Swift 仍写作初始化方法 `init(refreshingBlock:)` / `init(refreshingTarget:refreshingAction:)`；
//      `endRefreshingWithNoMoreData`、已废弃的 `noticeNoMoreData`、`resetNoMoreData`、getter 为 `isNoMoreData` 的 `noMoreData`、
//      `loadsAfterNoMoreData`、`ignoredScrollViewContentInsetBottom`、已废弃的 `automaticallyHidden`，以及 `CYLRefreshNoMoreDataImage` 的
//      `cyl_updateNoMoreDataImage:` / `cyl_placeNoMoreDataImageBesideLabel:inset:size:`）与底部栏下方的自动隐藏均不变。

import UIKit

/**
 * [EN] The base class of the pull-up (load more) controls; set one as a scroll view's `cylFooter`.
 * [CN] 上拉加载更多控件的基类；设为滚动视图的 `cylFooter` 使用。
 */
@objc(CYLRefreshFooter)
open class CYLRefreshFooter: CYLRefreshComponent {

    // [EN] The view of `cyl_updateNoMoreDataImage:`. [CN] `cyl_updateNoMoreDataImage:` 的视图。
    fileprivate weak var noMoreDataImageView: UIImageView?
    private var storedAutomaticallyHidden = false

    // MARK: - Factories

    /**
     * [EN] Creates a footer that calls `refreshingBlock` when it loads (Objective-C `+footerWithRefreshingBlock:`).
     * [CN] 创建footer，加载时调用 `refreshingBlock`（Objective-C 的 `+footerWithRefreshingBlock:`）。
     */
    public convenience init(refreshingBlock: @escaping CYLRefreshComponentAction) {
        self.init()
        self.refreshingBlock = refreshingBlock
    }

    /**
     * [EN] Creates a footer that sends `action` to `target` when it loads (Objective-C
     *      `+footerWithRefreshingTarget:refreshingAction:`).
     * [CN] 创建footer，加载时向 `target` 发送 `action`（Objective-C 的 `+footerWithRefreshingTarget:refreshingAction:`）。
     */
    public convenience init(refreshingTarget target: Any, refreshingAction action: Selector) {
        self.init()
        setRefreshingTarget(target, refreshingAction: action)
    }

    /**
     * [EN] Objective-C: `+footerWithRefreshingBlock:`; returns an instance of the class it is sent to.
     * [CN] Objective-C：`+footerWithRefreshingBlock:`；返回接收消息的类的实例。
     */
    @objc(footerWithRefreshingBlock:)
    @available(swift, obsoleted: 1, message: "Use init(refreshingBlock:)")
    open class func objcFooter(refreshingBlock: @escaping CYLRefreshComponentAction) -> Self {
        let cmp = self.init()
        cmp.refreshingBlock = refreshingBlock
        return cmp
    }

    /**
     * [EN] Objective-C: `+footerWithRefreshingTarget:refreshingAction:`; returns an instance of the class it is sent to.
     * [CN] Objective-C：`+footerWithRefreshingTarget:refreshingAction:`；返回接收消息的类的实例。
     */
    @objc(footerWithRefreshingTarget:refreshingAction:)
    @available(swift, obsoleted: 1, message: "Use init(refreshingTarget:refreshingAction:)")
    open class func objcFooter(refreshingTarget target: Any, refreshingAction action: Selector) -> Self {
        let cmp = self.init()
        cmp.setRefreshingTarget(target, refreshingAction: action)
        return cmp
    }

    // MARK: - Public API

    /**
     * [EN] Shows that all data is loaded (`CYLRefreshStateNoMoreData`); from another thread it switches on the main queue.
     * [CN] 提示没有更多的数据；在其他线程调用时切换到主队列执行。
     */
    @objc open func endRefreshingWithNoMoreData() {
        if Thread.isMainThread {
            state = .noMoreData
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.state = .noMoreData
            }
        }
    }

    /**
     * [EN] Deprecated: does the same as `endRefreshingWithNoMoreData`; use that instead.
     * [CN] 已废弃：与 `endRefreshingWithNoMoreData` 作用相同，请改用它。
     */
    @available(*, deprecated, message: "使用endRefreshingWithNoMoreData")
    @objc open func noticeNoMoreData() {
        endRefreshingWithNoMoreData()
    }

    /**
     * [EN] Leaves the no-more-data state (back to idle); from another thread it switches on the main queue.
     * [CN] 重置没有更多的数据（消除没有更多数据的状态）；在其他线程调用时切换到主队列执行。
     */
    @objc open func resetNoMoreData() {
        if Thread.isMainThread {
            state = .idle
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.state = .idle
            }
        }
    }

    /**
     * [EN] YES while the footer shows that all data is loaded (`CYLRefreshStateNoMoreData`).
     * [CN] 加载尾显示已全部加载（`CYLRefreshStateNoMoreData`）时为 YES。
     */
    @objc(noMoreData)
    open var isNoMoreData: Bool {
        @objc(isNoMoreData) get { state == .noMoreData }
    }

    /**
     * [EN] Pulling past the end loads again after "no more data": the footer resets and refreshes
     *      (flutter_easy_refresh's `canLoadAfterNoMore`). Default NO.
     * [CN] “无更多数据”后拉过底部仍会再次加载：加载尾重置并开始刷新（对应 flutter_easy_refresh 的 `canLoadAfterNoMore`）。默认 NO。
     */
    @objc open var loadsAfterNoMoreData = false

    /**
     * [EN] How much of the scroll view's bottom content inset to ignore (points).
     * [CN] 忽略多少scrollView的contentInset的bottom。
     */
    @objc open var ignoredScrollViewContentInsetBottom: CGFloat = 0

    /**
     * [EN] Deprecated and without effect: show and hide the footer yourself. Default NO.
     * [CN] 自动根据有无数据来显示和隐藏（有数据就显示，没有数据隐藏。默认是NO）；已废弃，请自行控制footer的显示和隐藏。
     */
    @available(*, deprecated, message: "已废弃此属性，开发者请自行控制footer的显示和隐藏")
    @objc(automaticallyHidden)
    open var isAutomaticallyHidden: Bool {
        @objc(isAutomaticallyHidden) get { storedAutomaticallyHidden }
        @objc(setAutomaticallyHidden:) set { storedAutomaticallyHidden = newValue }
    }

    // MARK: - Overrides of CYLRefreshComponent

    /**
     * [EN] Sets the footer's height. [CN] 设置自己的高度。
     */
    open override func prepare() {
        super.prepare()

        // 设置自己的高度
        cylH = CYLRefreshFooterHeight
    }

    /**
     * [EN] Sets the footer as `scrollView.cylFooter` and returns it. [CN] 设为 `scrollView.cylFooter` 并返回自身。
     */
    open override func link(to scrollView: UIScrollView) -> Self {
        scrollView.cylFooter = self
        return self
    }

    // MARK: - Auto-hide

    /**
     * [EN] Idle (or showing "no more data") and wholly below the bottom bars' edge, where a glass tab bar would show it.
     * [CN] 空闲（或显示“无更多数据”）且完全位于底部栏边缘之下，即玻璃 tab bar 会透出它的位置。
     */
    open override func isReadyToAutoHide() -> Bool {
        if state != .idle && state != .noMoreData { return false }
        guard let scrollView = scrollView else { return true }
        let visibleBottom = scrollView.cylOffsetY + scrollView.bounds.height - scrollViewOriginalInset.bottom
        return frame.minY >= visibleBottom - 0.5
    }

    /**
     * [EN] Also applies `autoHideRefresh` again. [CN] 同时重新应用 `autoHideRefresh`。
     */
    open override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        updateAutoHideVisibility()
    }

    /**
     * [EN] Also applies `autoHideRefresh` again. [CN] 同时重新应用 `autoHideRefresh`。
     */
    open override func scrollViewContentSizeDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentSizeDidChange(change)
        updateAutoHideVisibility()
    }

    /**
     * [EN] Also applies `autoHideRefresh` again. [CN] 同时重新应用 `autoHideRefresh`。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            super.state = newValue
            updateAutoHideVisibility()
        }
    }

    /**
     * [EN] Also applies `autoHideRefresh` again. [CN] 同时重新应用 `autoHideRefresh`。
     */
    open override func placeSubviews() {
        super.placeSubviews()
        updateAutoHideVisibility()
    }
}

/**
 * [EN] The image shown beside the text in the no-more-data state, kept once for both normal footers
 *      (`CYLRefreshAutoNormalFooter` / `CYLRefreshBackNormalFooter`, whose `noMoreDataImage` uses it).
 * [CN] 无更多数据状态时显示在文字旁的图片，为两种 Normal 尾部统一实现（`CYLRefreshAutoNormalFooter` / `CYLRefreshBackNormalFooter` 的
 *      `noMoreDataImage` 使用它）。
 */
extension CYLRefreshFooter {

    /**
     * [EN] Shows `image` only in the no-more-data state (nil hides it); call when the image or the state changes.
     * [CN] 仅在无更多数据状态时显示 `image`（nil 表示隐藏）；图片或状态变化时调用。
     */
    @objc(cyl_updateNoMoreDataImage:)
    public func updateNoMoreDataImage(_ image: UIImage?) {
        let show = image != nil && state == .noMoreData
        if show && noMoreDataImageView == nil {
            // [EN] A system UIImageView, not CYLPlaceholderView: it sits beside stateLabel in place of the system
            //      arrow / spinner views of the classic footers and shows one small image with no title.
            // [CN] 用系统 UIImageView 而不是 CYLPlaceholderView：它代替经典刷新尾的系统箭头 / 菊花，放在 stateLabel 旁边，只显示一张小图、没有标题。
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.isAccessibilityElement = false
            addSubview(imageView)
            noMoreDataImageView = imageView
        }
        noMoreDataImageView?.image = image
        noMoreDataImageView?.isHidden = !show
        setNeedsLayout()
    }

    /**
     * [EN] Places the image left of `label`'s text (`inset` apart), at `size` or, when zero, the image's own size; call
     *      from `placeSubviews`. [CN] 把图片放在 `label` 文字左侧（间距 `inset`），尺寸为 `size`，为零时使用图片自身尺寸；在 `placeSubviews` 中调用。
     */
    @objc(cyl_placeNoMoreDataImageBesideLabel:inset:size:)
    public func placeNoMoreDataImage(besideLabel label: UILabel?, inset: CGFloat, size: CGSize) {
        guard let imageView = noMoreDataImageView, !imageView.isHidden else { return }
        imageView.cylSize = (size.width > 0 && size.height > 0) ? size : (imageView.image?.size ?? .zero)
        var centerX = cylW * 0.5
        if let label = label, !label.isHidden { centerX -= inset + label.cylTextWidth() * 0.5 }
        imageView.center = CGPoint(x: centerX, y: cylH * 0.5)
    }
}
