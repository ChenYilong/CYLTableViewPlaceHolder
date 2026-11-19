//
//  CYLRefreshPaging.h
//  CYLRefresh
//
//  Pagination on top of a refresh header and footer, the counterpart of flutter_easy_refresh's easy_paging
//  (EasyPaging / EasyPagingState, https://github.com/xuelongqy/flutter_easy_refresh, MIT): refresh replaces the items,
//  load appends the next page, a page and its items are committed only after success (a failed load retries the same
//  page), and "no more data" comes from the total first, otherwise from the page count.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshPaging.swift` (docs/Swift-Migration.md, step 7), with the same
//       Objective-C API (`-initWithHeader:footer:loader:`, Swift `init(header:footer:loader:)`; `-init` unavailable; the
//       properties, `-start`, `-refresh`, `-loadMore`). The block types stay here.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshPaging.swift`，docs/Swift-Migration.md 第 7 步），Objective-C API 不变
//       （`-initWithHeader:footer:loader:`，Swift 中为 `init(header:footer:loader:)`；`-init` 不可用；各属性、`-start`、`-refresh`、`-loadMore`）。
//       块类型保留在这里。
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
 *      appended). The class is Swift (`CYLRefreshPaging.swift`); Objective-C code that messages it imports the umbrella
 *      header `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 由刷新头（刷新：第一页替换条目）和刷新尾（加载：追加下一页）驱动的分页。该类用 Swift 编写（`CYLRefreshPaging.swift`）；需要调用它的
 *      Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshPaging;

NS_ASSUME_NONNULL_END
