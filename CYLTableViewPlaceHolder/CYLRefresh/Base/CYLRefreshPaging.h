//
//  CYLRefreshPaging.h
//  CYLRefresh
//
//  Pagination on top of a refresh header and footer, the counterpart of flutter_easy_refresh's easy_paging
//  (EasyPaging / EasyPagingState, https://github.com/xuelongqy/flutter_easy_refresh, MIT): refresh replaces the items,
//  load appends the next page, a page and its items are committed only after success (a failed load retries the same
//  page), and "no more data" comes from the total first, otherwise from the page count.
//

#import <UIKit/UIKit.h>

@class CYLRefreshHeader, CYLRefreshFooter;

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Reports one page: its items, the total item count or the total page count (NSNotFound when unknown), or an
 *      error. A request that reports an error changes nothing. [CN] 报告一页：本页条目、总条目数或总页数（未知时为
 *      NSNotFound），或错误。报告错误的请求不改变任何状态。
 */
typedef void (^CYLRefreshPagingCompletion)(NSArray *_Nullable items, NSInteger total, NSInteger totalPage, NSError *_Nullable error);

/*!
 * [EN] Requests page `page`; call `completion` exactly once, on any queue. [CN] 请求第 `page` 页；`completion` 必须且只能调用一次，可在任意队列。
 */
typedef void (^CYLRefreshPagingLoader)(NSInteger page, CYLRefreshPagingCompletion completion);

/*!
 * [EN] Pagination driven by a header (refresh: the first page replaces the items) and a footer (load: the next page is
 *      appended). It ends the controls with success or failure, reports no more data and resets the footer after a
 *      successful refresh. The scroll view's placeholder shows when `isEmpty`.
 * [CN] 由刷新头（刷新：第一页替换条目）和刷新尾（加载：追加下一页）驱动的分页。它以成功或失败结束控件、报告没有更多数据，并在刷新成功后
 *      重置刷新尾。`isEmpty` 时显示滚动视图的占位图。
 */
@interface CYLRefreshPaging : NSObject

/*!
 * [EN] Pagination with `header` and `footer` (either may be nil) and the page loader; the controls' callbacks are
 *      replaced by the paging's. [CN] 使用 `header` 与 `footer`（均可为 nil）和分页加载器的分页；控件的回调会被分页的回调替换。
 */
- (instancetype)initWithHeader:(nullable CYLRefreshHeader *)header
                        footer:(nullable CYLRefreshFooter *)footer
                        loader:(CYLRefreshPagingLoader)loader NS_DESIGNATED_INITIALIZER;
/*!
 * [EN] Use `initWithHeader:footer:loader:`. [CN] 请使用 `initWithHeader:footer:loader:`。
 */
- (instancetype)init NS_UNAVAILABLE;

/*!
 * [EN] The refresh header. [CN] 刷新头。
 */
@property (weak, nonatomic, readonly, nullable) CYLRefreshHeader *header;
/*!
 * [EN] The load-more footer. [CN] 加载更多的刷新尾。
 */
@property (weak, nonatomic, readonly, nullable) CYLRefreshFooter *footer;
/*!
 * [EN] Number of the first page. Default 1. [CN] 第一页的页码。默认 1。
 */
@property (nonatomic) NSInteger firstPage;
/*!
 * [EN] All items loaded so far; nil before the first successful request. [CN] 已加载的全部条目；首次请求成功前为 nil。
 */
@property (copy, nonatomic, readonly, nullable) NSArray *items;
/*!
 * [EN] Number of items (`count`). [CN] 条目数（对应 `count`）。
 */
@property (nonatomic, readonly) NSInteger count;
/*!
 * [EN] The last page loaded successfully; NSNotFound before the first. [CN] 最后一次成功加载的页码；首次之前为 NSNotFound。
 */
@property (nonatomic, readonly) NSInteger page;
/*!
 * [EN] Total item count from the last successful request; NSNotFound when unknown. [CN] 上次成功请求报告的总条目数；未知时为 NSNotFound。
 */
@property (nonatomic, readonly) NSInteger total;
/*!
 * [EN] Total page count from the last successful request; NSNotFound when unknown. [CN] 上次成功请求报告的总页数；未知时为 NSNotFound。
 */
@property (nonatomic, readonly) NSInteger totalPage;
/*!
 * [EN] YES after a successful request that left no items (easy_paging's `isEmpty`). [CN] 成功请求后没有任何条目时为 YES（对应 easy_paging 的 `isEmpty`）。
 */
@property (nonatomic, readonly) BOOL isEmpty;
/*!
 * [EN] YES when every item is loaded: `count >= total`, else `page >= totalPage`; NO when neither is known
 *      (easy_paging's `isNoMore`). [CN] 全部条目已加载时为 YES：`count >= total`，否则 `page >= totalPage`；两者都未知时为 NO
 *      （对应 easy_paging 的 `isNoMore`）。
 */
@property (nonatomic, readonly) BOOL isNoMore;
/*!
 * [EN] Resets the footer's no-more-data state after a successful refresh (easy_paging's `resetAfterRefresh`). Default
 *      YES. [CN] 刷新成功后重置刷新尾的“没有更多数据”状态（对应 easy_paging 的 `resetAfterRefresh`）。默认 YES。
 */
@property (nonatomic) BOOL resetsFooterAfterRefresh;
/*!
 * [EN] Called on the main queue after the items changed; reload the list here. [CN] 条目变化后在主队列调用；在这里刷新列表。
 */
@property (copy, nonatomic, nullable) void (^itemsDidChange)(CYLRefreshPaging *paging);

/*!
 * [EN] Starts a refresh through the header (easy_paging's `refreshOnStart`), or requests the first page directly when
 *      there is no header. [CN] 通过刷新头开始刷新（对应 easy_paging 的 `refreshOnStart`）；没有刷新头时直接请求第一页。
 */
- (void)start;
/*!
 * [EN] Requests the first page; on success it replaces the items. [CN] 请求第一页；成功时替换条目。
 */
- (void)refresh;
/*!
 * [EN] Requests the page after `page`; on success it appends the items. [CN] 请求 `page` 的下一页；成功时追加条目。
 */
- (void)loadMore;

@end

NS_ASSUME_NONNULL_END
