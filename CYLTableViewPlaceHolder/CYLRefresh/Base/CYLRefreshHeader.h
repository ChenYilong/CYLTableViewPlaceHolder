//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshHeader.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  下拉刷新控件:负责监控用户下拉的状态

#import "CYLRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshHeader : CYLRefreshComponent
/*!
 * 创建header
 */
+ (instancetype)headerWithRefreshingBlock:(CYLRefreshComponentAction)refreshingBlock;
/*!
 * 创建header
 */
+ (instancetype)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

/*!
 * 这个key用来存储上一次下拉刷新成功的时间
 */
@property (copy, nonatomic) NSString *lastUpdatedTimeKey;
/*!
 * [EN] When the last refresh succeeded, stored under `lastUpdatedTimeKey`. Setting it stores the date (nil removes it)
 *      and updates the time label of state headers.
 * [CN] 上一次刷新成功的时间，保存在 `lastUpdatedTimeKey` 下。设置后保存该日期（nil 表示删除），并更新带文字刷新头的时间文字。
 */
@property (strong, nonatomic, nullable) NSDate *lastUpdatedTime;

/*!
 * 忽略多少scrollView的contentInset的top
 */
@property (assign, nonatomic) CGFloat ignoredScrollViewContentInsetTop;

/*!
 * 默认是关闭状态, 如果遇到 CollectionView 的动画异常问题可以尝试打开
 */
@property (nonatomic) BOOL isCollectionViewAnimationBug;

/*!
 * [EN] Sets the open height (`expandHeight`). In `CYLRefreshScrollModeStretch` the frame follows the pull, so only the
 *      open height changes; in the other modes the frame height changes too.
 * [CN] 设置展开高度（`expandHeight`）。拉伸模式下 frame 跟随下拉，只改变展开高度；其他模式同时改变 frame 高度。
 */
- (void)setExpandHeight:(CGFloat)expandHeight NS_SWIFT_NAME(setExpandHeight(_:));
/*!
 * [EN] Whether refreshing adds the header's height to the top inset, pushing the content down. Default YES; NO (and
 *      `CYLRefreshScrollModeFront`) keeps the content where it is, for headers that are always open or float in front.
 * [CN] 刷新时是否把刷新头高度加到顶部 inset、把内容往下推。默认 YES；NO（以及 `CYLRefreshScrollModeFront`）让内容保持不动，
 *      适用于常态展开或浮在内容前面的刷新头。
 */
@property (nonatomic) BOOL addsRefreshingInset;
/*!
 * [EN] After a successful refresh, resets the footer's "no more data" (flutter_easy_refresh's `resetAfterRefresh`).
 *      Default NO. [CN] 刷新成功后重置加载尾的“无更多数据”（对应 flutter_easy_refresh 的 `resetAfterRefresh`）。默认 NO。
 */
@property (nonatomic) BOOL resetsFooterAfterRefresh;
@end

NS_ASSUME_NONNULL_END
