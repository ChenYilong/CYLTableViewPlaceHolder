//
//  UIScrollView+CYLRefresh.swift
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  给ScrollView增加下拉刷新、上拉刷新、 左滑刷新的功能
//

// [EN] The refresh controls of a scroll view (`cyl_header`, `cyl_footer`, `cyl_trailer`, auto-hide, the start header,
//      the layout-style finish calls, the default controls and `cyl_totalDataCount`), in Swift since 2026-11-19
//      (docs/Swift-Migration.md, step 6) with the same Objective-C selectors and Swift spellings.
// [CN] 滚动视图的刷新控件（`cyl_header`、`cyl_footer`、`cyl_trailer`、自动隐藏、起始刷新头、布局风格的结束方法、默认控件与
//      `cyl_totalDataCount`），自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 6 步），Objective-C 选择器与 Swift 写法不变。

import UIKit
import ObjectiveC

// [EN] The associated-object keys: stable addresses for the process's lifetime. [CN] 关联对象的 key：进程内地址固定。
private enum CYLRefreshKey {
    static let header = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let footer = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let trailer = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let autoHideHeader = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    static let autoHideFooter = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
}

extension UIScrollView {

    // MARK: - Controls

    /**
     * [EN] The pull-down refresh control; setting it removes the old one and inserts the new one at index 0.
     * [CN] 下拉刷新控件；设置时移除旧控件，并把新控件插入到第 0 个子视图位置。
     */
    @objc public dynamic var cyl_header: CYLRefreshHeader? {
        get { objc_getAssociatedObject(self, CYLRefreshKey.header) as? CYLRefreshHeader }
        set {
            guard newValue !== cyl_header else { return }
            // 删除旧的，添加新的
            cyl_header?.removeFromSuperview()
            if let header = newValue {
                insertSubview(header, at: 0)
            }
            // 存储新的
            objc_setAssociatedObject(self, CYLRefreshKey.header, newValue, .OBJC_ASSOCIATION_RETAIN)
            if let header = newValue, let autoHide = objc_getAssociatedObject(self, CYLRefreshKey.autoHideHeader) as? NSNumber {
                header.autoHideRefresh = autoHide.boolValue
            }
        }
    }

    /**
     * [EN] The pull-up refresh control; setting it removes the old one and inserts the new one at index 0.
     * [CN] 上拉刷新控件；设置时移除旧控件，并把新控件插入到第 0 个子视图位置。
     */
    @objc public dynamic var cyl_footer: CYLRefreshFooter? {
        get { objc_getAssociatedObject(self, CYLRefreshKey.footer) as? CYLRefreshFooter }
        set {
            guard newValue !== cyl_footer else { return }
            // 删除旧的，添加新的
            cyl_footer?.removeFromSuperview()
            if let footer = newValue {
                insertSubview(footer, at: 0)
            }
            // 存储新的
            objc_setAssociatedObject(self, CYLRefreshKey.footer, newValue, .OBJC_ASSOCIATION_RETAIN)
            if let footer = newValue, let autoHide = objc_getAssociatedObject(self, CYLRefreshKey.autoHideFooter) as? NSNumber {
                footer.autoHideRefresh = autoHide.boolValue
            }
        }
    }

    /**
     * [EN] The swipe-left refresh control; setting it removes the old one and inserts the new one at index 0.
     * [CN] 左滑刷新控件；设置时移除旧控件，并把新控件插入到第 0 个子视图位置。
     */
    @objc public dynamic var cyl_trailer: CYLRefreshTrailer? {
        get { objc_getAssociatedObject(self, CYLRefreshKey.trailer) as? CYLRefreshTrailer }
        set {
            guard newValue !== cyl_trailer else { return }
            // 删除旧的，添加新的
            cyl_trailer?.removeFromSuperview()
            if let trailer = newValue {
                insertSubview(trailer, at: 0)
            }
            // 存储新的
            objc_setAssociatedObject(self, CYLRefreshKey.trailer, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    // MARK: - Other

    /**
     * [EN] The number of rows of a table view, or items of a collection view, over all sections; 0 for any other scroll
     *      view.
     * [CN] 表格视图所有 section 的行数之和，或集合视图所有 section 的 item 数之和；其他滚动视图为 0。
     */
    @objc public dynamic func cyl_totalDataCount() -> Int {
        var totalCount = 0
        if let tableView = self as? UITableView {
            for section in 0..<max(tableView.numberOfSections, 0) {
                totalCount += tableView.numberOfRows(inSection: section)
            }
        } else if let collectionView = self as? UICollectionView {
            for section in 0..<max(collectionView.numberOfSections, 0) {
                totalCount += collectionView.numberOfItems(inSection: section)
            }
        }
        return totalCount
    }

    // MARK: - Auto-hide

    // [EN] The default when nothing was set: on where the bars are transparent by default.
    // [CN] 未设置时的默认值：栏默认透明的系统上开启。
    private static var cyl_defaultAutoHide: Bool {
        if #available(iOS 26.0, *) { return true }
        return false
    }

    /**
     * [EN] `autoHideRefresh` of the header alone (also applied to a header attached later).
     * [CN] 仅刷新头的 `autoHideRefresh`（之后挂上的刷新头同样生效）。
     */
    @objc public dynamic var cyl_autoHideRefreshHeader: Bool {
        get {
            if let header = cyl_header { return header.autoHideRefresh }
            let value = objc_getAssociatedObject(self, CYLRefreshKey.autoHideHeader) as? NSNumber
            return value?.boolValue ?? UIScrollView.cyl_defaultAutoHide
        }
        set {
            objc_setAssociatedObject(self, CYLRefreshKey.autoHideHeader, NSNumber(value: newValue),
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            cyl_header?.autoHideRefresh = newValue
        }
    }

    /**
     * [EN] `autoHideRefresh` of the footer alone (also applied to a footer attached later).
     * [CN] 仅刷新尾的 `autoHideRefresh`（之后挂上的刷新尾同样生效）。
     */
    @objc public dynamic var cyl_autoHideRefreshFooter: Bool {
        get {
            if let footer = cyl_footer { return footer.autoHideRefresh }
            let value = objc_getAssociatedObject(self, CYLRefreshKey.autoHideFooter) as? NSNumber
            return value?.boolValue ?? UIScrollView.cyl_defaultAutoHide
        }
        set {
            objc_setAssociatedObject(self, CYLRefreshKey.autoHideFooter, NSNumber(value: newValue),
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            cyl_footer?.autoHideRefresh = newValue
        }
    }

    /**
     * [EN] `autoHideRefresh` for the header and the footer at once: setting it sets both; reading it is YES when both hide.
     *      A value set before a control is attached is applied when it is attached.
     * [CN] 同时设置刷新头与刷新尾的 `autoHideRefresh`：设置时两者一起设置；读取时两者都会隐藏才为 YES。在控件挂上之前设置的值会在挂上时生效。
     */
    @objc public dynamic var cyl_autoHideRefresh: Bool {
        get { cyl_autoHideRefreshHeader && cyl_autoHideRefreshFooter }
        set {
            cyl_autoHideRefreshHeader = newValue
            cyl_autoHideRefreshFooter = newValue
        }
    }

    // MARK: - Finishing (CYLRefreshLayout)

    /**
     * [EN] Ends the header's refresh after `delay` seconds with `success`, and sets the footer's no-more-data state:
     *      YES shows no more data, NO resets it (CYLRefreshLayout's `finishRefresh(delayed, success, noMoreData)`; to
     *      leave the footer as it is, call the header's `endRefreshingAfterDelay:success:`).
     * [CN] `delay` 秒后以 `success` 结束刷新头的刷新，并设置尾部的“没有更多数据”：YES 显示没有更多，NO 重置（对应 CYLRefreshLayout 的
     *      `finishRefresh(delayed, success, noMoreData)`；不改尾部时调用刷新头的 `endRefreshingAfterDelay:success:`）。
     */
    @objc(cyl_endRefreshingAfterDelay:success:noMoreData:)
    public dynamic func cyl_endRefreshing(afterDelay delay: TimeInterval, success: Bool, noMoreData: Bool) {
        cyl_header?.endRefreshing(afterDelay: delay, success: success)
        guard let footer = cyl_footer else { return }
        // [EN] Weak, as in cyl_endLoadingMoreAfterDelay: a pending delay does not keep a torn-down footer alive.
        // [CN] 弱引用，与 cyl_endLoadingMoreAfterDelay 相同：等待中的延迟不会让已销毁的刷新尾继续存活。
        let apply: () -> Void = { [weak footer] in
            if noMoreData {
                footer?.endRefreshingWithNoMoreData()
            } else if let footer = footer, footer.isNoMoreData {
                footer.resetNoMoreData()
            }
        }
        if delay <= 0 {
            apply()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: apply)
        }
    }

    /**
     * [EN] Ends the footer's load more after `delay` seconds with `success`; `noMoreData` YES then shows no more data
     *      (CYLRefreshLayout's `finishLoadMore(delayed, success, noMoreData)`).
     * [CN] `delay` 秒后以 `success` 结束尾部的加载；`noMoreData` 为 YES 时随后显示没有更多数据（对应 CYLRefreshLayout 的
     *      `finishLoadMore(delayed, success, noMoreData)`）。
     */
    @objc(cyl_endLoadingMoreAfterDelay:success:noMoreData:)
    public dynamic func cyl_endLoadingMore(afterDelay delay: TimeInterval, success: Bool, noMoreData: Bool) {
        guard let footer = cyl_footer else { return }
        if !noMoreData {
            footer.endRefreshing(afterDelay: delay, success: success)
            return
        }
        let apply: () -> Void = { [weak footer] in
            footer?.endRefreshingWithNoMoreData()
        }
        if delay <= 0 {
            apply()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: apply)
        }
    }

    /**
     * [EN] Sets `cyl_header` and `cyl_footer`, where nil, from `CYLRefreshConfig.defaultConfig`'s
     *      `defaultHeaderCreator` / `defaultFooterCreator` (CYLRefreshLayout's default header and footer of every layout).
     * [CN] 在 `cyl_header`、`cyl_footer` 为 nil 时，用 `CYLRefreshConfig.defaultConfig` 的 `defaultHeaderCreator` /
     *      `defaultFooterCreator` 创建（对应 CYLRefreshLayout 为每个布局提供的默认刷新头与尾部）。
     */
    @objc public dynamic func cyl_installDefaultRefreshControls() {
        let config = CYLRefreshConfig.default
        if cyl_header == nil, let creator = config.defaultHeaderCreator {
            cyl_header = creator(self)
        }
        if cyl_footer == nil, let creator = config.defaultFooterCreator {
            cyl_footer = creator(self)
        }
    }

    // MARK: - Start header

    /**
     * [EN] Refreshes once with `startHeader` in place of `cyl_header`, then puts `cyl_header` back when that refresh ends
     *      (flutter_easy_refresh's `refreshOnStart` with `refreshOnStartHeader`). `startHeader` uses its own refreshing
     *      callbacks, or the regular header's when it has none.
     * [CN] 用 `startHeader` 代替 `cyl_header` 刷新一次，刷新结束后换回 `cyl_header`（对应 flutter_easy_refresh 的 `refreshOnStart` 与
     *      `refreshOnStartHeader`）。`startHeader` 使用自己的刷新回调；没有时使用常规刷新头的回调。
     */
    @objc(cyl_beginRefreshingWithStartHeader:)
    public dynamic func cyl_beginRefreshing(startHeader: CYLRefreshHeader?) {
        let regular = cyl_header
        // [EN] Optional, as the Objective-C method checked: nil (or the regular header) refreshes the regular header.
        // [CN] 可选，与 Objective-C 方法的检查一致：nil（或常规刷新头本身）时刷新常规刷新头。
        guard let startHeader = startHeader, startHeader !== regular else {
            regular?.beginRefreshing()
            return
        }
        // [EN] Without callbacks of its own, the start header uses the regular header's.
        // [CN] 起始刷新头没有自己的回调时，使用常规刷新头的回调。
        // [EN] Target-actions of -addTarget:action: (the attach:target:action: family) count and are copied too.
        // [CN] -addTarget:action:（attach:target:action: 系列）的 target-action 也计入并复制。
        if let regular = regular, !startHeader.hasCallbacks {
            startHeader.copyTargetActions(from: regular)
            startHeader.refreshingBlock = regular.refreshingBlock
            // [EN] Without a target there is nothing to call (the start header has none, having no callbacks).
            // [CN] 没有 target 时无可调用（起始刷新头没有回调，因而也没有 target）。
            if let target = regular.refreshingTarget {
                startHeader.setRefreshingTarget(target, refreshingAction: regular.refreshingAction)
            }
            if let handler = regular.refreshingHandler {
                // [EN] The regular header's handler gets the regular header. [CN] 常规刷新头的 handler 收到的是常规刷新头。
                startHeader.refreshingHandler = { [weak regular] _ in
                    if let regular = regular { handler(regular) }
                }
            }
        }
        // [EN] A phase observer, not endRefreshingCompletionBlock, so a caller's endRefreshingWithCompletionBlock: cannot
        //      replace it. After the refresh, wait for the retract animation, then put the regular header back.
        // [CN] 使用阶段观察者而非 endRefreshingCompletionBlock，调用方的 endRefreshingWithCompletionBlock: 不会覆盖它。刷新结束后等待收回动画，
        //      再换回常规刷新头。
        var token: Any?
        var refreshed = false
        token = startHeader.addPhaseObserver { [weak self] component, _, phase in
            if phase == .refreshing || phase == .willRefresh { refreshed = true }
            guard refreshed, phase == .idle else { return }
            if let token = token { component.removePhaseObserver(token) }
            let delay = component.slowAnimationDuration + 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self, self.cyl_header === component else { return }
                self.cyl_header = regular
            }
        }
        cyl_header = startHeader
        startHeader.beginRefreshing()
    }
}
