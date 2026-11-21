//
//  CYLRefreshPaging.swift
//  CYLRefresh
//
//  The request rules follow flutter_easy_refresh's easy_paging (https://github.com/xuelongqy/flutter_easy_refresh, MIT).
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API: the class name,
//      `-initWithHeader:footer:loader:` (Swift `init(header:footer:loader:)`; `-init` unavailable), the properties and
//      their getters (`isEmpty`, `isNoMore`), `-start`, `-refresh`, `-loadMore`. The block types `CYLRefreshPagingLoader`
//      and `CYLRefreshPagingCompletion` stay in `CYLRefreshPaging.h`.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变：类名、`-initWithHeader:footer:loader:`
//      （Swift 中为 `init(header:footer:loader:)`；`-init` 不可用）、各属性及其 getter（`isEmpty`、`isNoMore`）、`-start`、`-refresh`、
//      `-loadMore`。块类型 `CYLRefreshPagingLoader` 与 `CYLRefreshPagingCompletion` 保留在 `CYLRefreshPaging.h`。

import UIKit

/**
 * [EN] Pagination driven by a header (refresh: the first page replaces the items) and a footer (load: the next page is
 *      appended). It ends the controls with success or failure, reports no more data and resets the footer after a
 *      successful refresh. The scroll view's placeholder shows when `isEmpty`.
 * [CN] 由刷新头（刷新：第一页替换条目）和刷新尾（加载：追加下一页）驱动的分页。它以成功或失败结束控件、报告没有更多数据，并在刷新成功后
 *      重置刷新尾。`isEmpty` 时显示滚动视图的占位图。
 */
@objc(CYLRefreshPaging)
public final class CYLRefreshPaging: NSObject {

    private let loader: CYLRefreshPagingLoader
    // [EN] Increases with every refresh, so a load that started before it is ignored.
    // [CN] 每次刷新递增，刷新前开始的加载结果会被忽略。
    private var generation: UInt = 0

    /**
     * [EN] The refresh header.
     * [CN] 刷新头。
     */
    @objc public private(set) weak var header: CYLRefreshHeader?

    /**
     * [EN] The load-more footer.
     * [CN] 加载更多的刷新尾。
     */
    @objc public private(set) weak var footer: CYLRefreshFooter?

    /**
     * [EN] Number of the first page. Default 1.
     * [CN] 第一页的页码。默认 1。
     */
    @objc public var firstPage: Int = 1

    /**
     * [EN] All items loaded so far; nil before the first successful request.
     * [CN] 已加载的全部条目；首次请求成功前为 nil。
     */
    @objc public private(set) var items: [Any]?

    /**
     * [EN] Number of items (`count`).
     * [CN] 条目数（对应 `count`）。
     */
    @objc public var count: Int { items?.count ?? 0 }

    /**
     * [EN] The last page loaded successfully; NSNotFound before the first.
     * [CN] 最后一次成功加载的页码；首次之前为 NSNotFound。
     */
    @objc public private(set) var page: Int = NSNotFound

    /**
     * [EN] Total item count from the last successful request; NSNotFound when unknown.
     * [CN] 上次成功请求报告的总条目数；未知时为 NSNotFound。
     */
    @objc public private(set) var total: Int = NSNotFound

    /**
     * [EN] Total page count from the last successful request; NSNotFound when unknown.
     * [CN] 上次成功请求报告的总页数；未知时为 NSNotFound。
     */
    @objc public private(set) var totalPage: Int = NSNotFound

    /**
     * [EN] YES after a successful request that left no items (easy_paging's `isEmpty`).
     * [CN] 成功请求后没有任何条目时为 YES（对应 easy_paging 的 `isEmpty`）。
     */
    @objc public var isEmpty: Bool {
        if let items = items { return items.isEmpty }
        return false
    }

    /**
     * [EN] YES when every item is loaded: `count >= total`, else `page >= totalPage`; NO when neither is known
     *      (easy_paging's `isNoMore`).
     * [CN] 全部条目已加载时为 YES：`count >= total`，否则 `page >= totalPage`；两者都未知时为 NO（对应 easy_paging 的 `isNoMore`）。
     */
    @objc public var isNoMore: Bool {
        if items == nil { return false }
        if total != NSNotFound { return count >= total }
        if page != NSNotFound && totalPage != NSNotFound { return page >= totalPage }
        return false
    }

    /**
     * [EN] Resets the footer's no-more-data state after a successful refresh (easy_paging's `resetAfterRefresh`). Default
     *      YES.
     * [CN] 刷新成功后重置刷新尾的“没有更多数据”状态（对应 easy_paging 的 `resetAfterRefresh`）。默认 YES。
     */
    @objc public var resetsFooterAfterRefresh = true

    /**
     * [EN] Called on the main queue after the items changed; reload the list here.
     * [CN] 条目变化后在主队列调用；在这里刷新列表。
     */
    @objc public var itemsDidChange: ((CYLRefreshPaging) -> Void)?

    /**
     * [EN] Pagination with `header` and `footer` (either may be nil) and the page loader; the controls' callbacks are
     *      replaced by the paging's.
     * [CN] 使用 `header` 与 `footer`（均可为 nil）和分页加载器的分页；控件的回调会被分页的回调替换。
     */
    @objc(initWithHeader:footer:loader:)
    public init(header: CYLRefreshHeader?, footer: CYLRefreshFooter?, loader: @escaping CYLRefreshPagingLoader) {
        self.header = header
        self.footer = footer
        self.loader = loader
        super.init()
        header?.refreshingBlock = { [weak self] in self?.refresh() }
        footer?.refreshingBlock = { [weak self] in self?.loadMore() }
    }

    /**
     * [EN] Starts a refresh through the header (easy_paging's `refreshOnStart`), or requests the first page directly when
     *      there is no header.
     * [CN] 通过刷新头开始刷新（对应 easy_paging 的 `refreshOnStart`）；没有刷新头时直接请求第一页。
     */
    @objc public func start() {
        if let header = header {
            header.beginRefreshing()
        } else {
            refresh()
        }
    }

    /**
     * [EN] Requests the first page; on success it replaces the items.
     * [CN] 请求第一页；成功时替换条目。
     */
    @objc public func refresh() {
        generation += 1
        let generation = self.generation
        let page = firstPage
        loader(page) { [weak self] items, total, totalPage, error in
            CYLRefreshPaging.onMain(self) { paging in
                guard generation == paging.generation else { return }
                if error != nil {
                    // [EN] A failed refresh keeps the items and the footer as they were. [CN] 刷新失败时保持条目与刷新尾不变。
                    paging.header?.endRefreshing(success: false)
                    return
                }
                paging.items = items ?? []
                paging.page = page
                paging.total = total
                paging.totalPage = totalPage
                paging.itemsChanged()
                paging.header?.endRefreshing(success: true)
                if paging.resetsFooterAfterRefresh, let footer = paging.footer, footer.state == .noMoreData {
                    footer.resetNoMoreData()
                }
                paging.updateFooter()
            }
        }
    }

    /**
     * [EN] Requests the page after `page`; on success it appends the items.
     * [CN] 请求 `page` 的下一页；成功时追加条目。
     */
    @objc public func loadMore() {
        let generation = self.generation
        let page = self.page == NSNotFound ? firstPage : self.page + 1
        loader(page) { [weak self] items, total, totalPage, error in
            CYLRefreshPaging.onMain(self) { paging in
                if generation != paging.generation {
                    // [EN] A refresh replaced the items meanwhile: drop this page. [CN] 期间刷新已替换条目：丢弃这一页。
                    if let footer = paging.footer, footer.isRefreshing { footer.endRefreshing() }
                    return
                }
                if error != nil {
                    // [EN] Not committed: the next load asks for the same page again. [CN] 不提交：下次加载会再次请求同一页。
                    paging.footer?.endRefreshing(success: false)
                    return
                }
                paging.items = (paging.items ?? []) + (items ?? [])
                paging.page = page
                paging.total = total
                paging.totalPage = totalPage
                paging.itemsChanged()
                if paging.isNoMore {
                    paging.footer?.endRefreshingWithNoMoreData()
                } else {
                    paging.footer?.endRefreshing(success: true)
                }
            }
        }
    }

    // [EN] After a refresh: report no more data, or keep the footer ready. [CN] 刷新之后：报告没有更多数据，或保持刷新尾可用。
    private func updateFooter() {
        if isNoMore, let footer = footer, footer.state != .noMoreData {
            footer.endRefreshingWithNoMoreData()
        }
    }

    private func itemsChanged() {
        itemsDidChange?(self)
    }

    // [EN] Runs `block` with the paging on the main queue (now when already there); nothing once the paging is gone.
    // [CN] 在主队列上以分页对象执行 `block`（已在主队列时立即执行）；分页对象释放后不执行。
    private static func onMain(_ paging: CYLRefreshPaging?, _ block: @escaping (CYLRefreshPaging) -> Void) {
        guard let paging = paging else { return }
        if Thread.isMainThread {
            block(paging)
        } else {
            DispatchQueue.main.async { [weak paging] in
                guard let paging = paging else { return }
                block(paging)
            }
        }
    }
}
