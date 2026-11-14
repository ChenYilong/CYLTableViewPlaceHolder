//
//  CYLRefreshBackFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshFooter.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshBackFooter : CYLRefreshFooter

/*!
 * Seconds the "no more data" text stays visible, with the footer held open, after a load that ends with
 * `endRefreshingWithNoMoreData`, before the scroll view rebounds (upstream #1585, case 2). Default 0: rebound at once, as
 * before. Starting another load, `resetNoMoreData` or removing the footer ends the hold at once. It does not apply when the
 * state is set without a load in progress, so the case "already no-more-data on entry; show the text for N seconds after a
 * pull-up" is not covered.
 */
@property (nonatomic) NSTimeInterval noMoreDataDisplayDuration;

/*!
 * [EN] Pulling up at least this far (points) and releasing opens the footer's second floor below the list instead of
 *      loading; 0 (default) turns it off (flutter_easy_refresh's footer `secondaryTriggerOffset`).
 * [CN] 至少上拉这么远（点）后松手，会在列表下方打开刷新尾的二楼而不是加载；0（默认）关闭（对应 flutter_easy_refresh 刷新尾的
 *      `secondaryTriggerOffset`）。
 */
@property (nonatomic) CGFloat secondaryTriggerOffset;
/*!
 * [EN] Height of the open second floor (points); 0 (default) uses the scroll view's visible height.
 * [CN] 打开后二楼的高度（点）；0（默认）表示使用滚动视图的可见高度。
 */
@property (nonatomic) CGFloat secondaryDimension;
/*!
 * [EN] While open, pulling the content down this far (points) and releasing closes it. Default 80.
 * [CN] 打开时，把内容往下拉这么远（点）再松手即关闭。默认 80。
 */
@property (nonatomic) CGFloat secondaryCloseTriggerOffset;
/*!
 * [EN] The second floor's content, placed below the list across the whole floor (flutter_easy_refresh's
 *      `SecondaryBuilderFooter`). [CN] 二楼的内容视图，放在列表下方、铺满整个二楼（对应 flutter_easy_refresh 的 `SecondaryBuilderFooter`）。
 */
@property (strong, nonatomic, nullable) UIView *secondaryView;
/*!
 * [EN] YES while the second floor is open. [CN] 二楼打开时为 YES。
 */
@property (nonatomic, readonly, getter=isSecondaryOpen) BOOL secondaryOpen;
/*!
 * [EN] Called when the second floor has opened. [CN] 二楼打开后调用。
 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction secondaryOpenedBlock;
/*!
 * [EN] Called when the second floor has closed. [CN] 二楼关闭后调用。
 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction secondaryClosedBlock;
/*!
 * [EN] Opens the second floor (flutter_easy_refresh's `openFooterSecondary`). [CN] 打开二楼（对应 flutter_easy_refresh 的 `openFooterSecondary`）。
 */
/*!
 * [EN] Releasing a pull-up at least this fast (points per second) past the load trigger opens the second floor; 0
 *      (default) turns it off. [CN] 越过加载触发点后，以至少这个速度（点/秒）松手即打开二楼；0（默认）关闭。
 */
@property (nonatomic) CGFloat secondaryVelocity;
- (void)openSecondary;
/*!
 * [EN] Closes the second floor (flutter_easy_refresh's `closeFooterSecondary`). [CN] 关闭二楼（对应 flutter_easy_refresh 的 `closeFooterSecondary`）。
 */
- (void)closeSecondary;

@end

NS_ASSUME_NONNULL_END
