//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  UIScrollView+CYLRefresh.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  给ScrollView增加下拉刷新、上拉刷新、 左滑刷新的功能

#import <UIKit/UIKit.h>
#import "CYLRefreshConst.h"

@class CYLRefreshHeader, CYLRefreshFooter, CYLRefreshTrailer;

NS_ASSUME_NONNULL_BEGIN

// [EN] Implemented in Swift since 2026-11-19 (`UIScrollView+CYLRefresh.swift`, the same selectors; docs/Swift-Migration.md, step 6). This
//      declaration is for Objective-C callers only: Swift reads the Swift extension itself (`__swift__` is defined while
//      Swift imports the header), so the two never meet.
// [CN] 自 2026-11-19 起用 Swift 实现（`UIScrollView+CYLRefresh.swift`，选择器不变；docs/Swift-Migration.md 第 6 步）。这里的声明只供 Objective-C
//      调用方使用：Swift 直接读取 Swift 扩展（Swift 导入头文件时定义了 `__swift__`），两者不会冲突。
#ifndef __swift__
/*!
 * [EN] The refresh controls of a scroll view: header, footer and trailer, and their settings.
 * [CN] 滚动视图的刷新控件：刷新头、刷新尾、trailer 及其设置。
 */
@interface UIScrollView (CYLRefresh)
/*!
 * 下拉刷新控件
 */
@property (strong, nonatomic, nullable) CYLRefreshHeader *cyl_header;
/*!
 * 上拉刷新控件
 */
@property (strong, nonatomic, nullable) CYLRefreshFooter *cyl_footer;

/*!
 * 左滑刷新控件
 */
@property (strong, nonatomic, nullable) CYLRefreshTrailer *cyl_trailer;

/*!
 * [EN] `autoHideRefresh` for the header and the footer at once: setting it sets both; reading it is YES when both hide.
 *      A value set before a control is attached is applied when it is attached.
 * [CN] 同时设置刷新头与刷新尾的 `autoHideRefresh`：设置时两者一起设置；读取时两者都会隐藏才为 YES。在控件挂上之前设置的值会在挂上时生效。
 */
@property (assign, nonatomic) BOOL cyl_autoHideRefresh;
/*!
 * [EN] `autoHideRefresh` of the header alone (also applied to a header attached later).
 * [CN] 仅刷新头的 `autoHideRefresh`（之后挂上的刷新头同样生效）。
 */
@property (assign, nonatomic) BOOL cyl_autoHideRefreshHeader;
/*!
 * [EN] `autoHideRefresh` of the footer alone (also applied to a footer attached later).
 * [CN] 仅刷新尾的 `autoHideRefresh`（之后挂上的刷新尾同样生效）。
 */
@property (assign, nonatomic) BOOL cyl_autoHideRefreshFooter;

/*!
 * [EN] Refreshes once with `startHeader` in place of `cyl_header`, then puts `cyl_header` back when that refresh ends
 *      (flutter_easy_refresh's `refreshOnStart` with `refreshOnStartHeader`). `startHeader` uses its own refreshing
 *      callbacks, or the regular header's when it has none.
 * [CN] 用 `startHeader` 代替 `cyl_header` 刷新一次，刷新结束后换回 `cyl_header`（对应 flutter_easy_refresh 的 `refreshOnStart` 与
 *      `refreshOnStartHeader`）。`startHeader` 使用自己的刷新回调；没有时使用常规刷新头的回调。
 */
- (void)cyl_beginRefreshingWithStartHeader:(CYLRefreshHeader *)startHeader NS_SWIFT_NAME(cyl_beginRefreshing(startHeader:));

/*!
 * [EN] Ends the header's refresh after `delay` seconds with `success`, and sets the footer's no-more-data state:
 *      YES shows no more data, NO resets it (CYLRefreshLayout's `finishRefresh(delayed, success, noMoreData)`; to
 *      leave the footer as it is, call the header's `endRefreshingAfterDelay:success:`).
 * [CN] `delay` 秒后以 `success` 结束刷新头的刷新，并设置尾部的“没有更多数据”：YES 显示没有更多，NO 重置（对应 CYLRefreshLayout 的
 *      `finishRefresh(delayed, success, noMoreData)`；不改尾部时调用刷新头的 `endRefreshingAfterDelay:success:`）。
 */
- (void)cyl_endRefreshingAfterDelay:(NSTimeInterval)delay success:(BOOL)success noMoreData:(BOOL)noMoreData
    NS_SWIFT_NAME(cyl_endRefreshing(afterDelay:success:noMoreData:));
/*!
 * [EN] Ends the footer's load more after `delay` seconds with `success`; `noMoreData` YES then shows no more data
 *      (CYLRefreshLayout's `finishLoadMore(delayed, success, noMoreData)`).
 * [CN] `delay` 秒后以 `success` 结束尾部的加载；`noMoreData` 为 YES 时随后显示没有更多数据（对应 CYLRefreshLayout 的
 *      `finishLoadMore(delayed, success, noMoreData)`）。
 */
- (void)cyl_endLoadingMoreAfterDelay:(NSTimeInterval)delay success:(BOOL)success noMoreData:(BOOL)noMoreData
    NS_SWIFT_NAME(cyl_endLoadingMore(afterDelay:success:noMoreData:));
/*!
 * [EN] Sets `cyl_header` and `cyl_footer`, where nil, from `CYLRefreshConfig.defaultConfig`'s
 *      `defaultHeaderCreator` / `defaultFooterCreator` (CYLRefreshLayout's default header and footer of every layout).
 * [CN] 在 `cyl_header`、`cyl_footer` 为 nil 时，用 `CYLRefreshConfig.defaultConfig` 的 `defaultHeaderCreator` /
 *      `defaultFooterCreator` 创建（对应 CYLRefreshLayout 为每个布局提供的默认刷新头与尾部）。
 */
- (void)cyl_installDefaultRefreshControls;

#pragma mark - other
/*!
 * [EN] The number of rows of a table view, or items of a collection view, over all sections; 0 for any other scroll
 *      view.
 * [CN] 表格视图所有 section 的行数之和，或集合视图所有 section 的 item 数之和；其他滚动视图为 0。
 */
- (NSInteger)cyl_totalDataCount;

@end
#endif

NS_ASSUME_NONNULL_END
