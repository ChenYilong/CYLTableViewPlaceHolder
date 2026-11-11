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
 * 上一次下拉刷新成功的时间
 */
@property (strong, nonatomic, readonly, nullable) NSDate *lastUpdatedTime;

/*!
 * 忽略多少scrollView的contentInset的top
 */
@property (assign, nonatomic) CGFloat ignoredScrollViewContentInsetTop;

/*!
 * 默认是关闭状态, 如果遇到 CollectionView 的动画异常问题可以尝试打开
 */
@property (nonatomic) BOOL isCollectionViewAnimationBug;

/*!
 * [EN] Shows the header only while an action is under way (pulling it down, refreshing, retracting after the refresh)
 *      and hides it again when the refresh ends, once it is idle and fully retracted. On by default on systems whose
 *      navigation bar is transparent by default (iOS 26 and later, the glass bar): there a retracted header sits right
 *      under the bar and shows through over the title. Off by default on earlier systems; set YES to use it there.
 *      The header is masked out, so its `hidden` and `alpha` (and `automaticallyChangeAlpha`) stay as the caller set
 *      them. NO keeps MJRefresh's behavior, where the retracted header stays visible.
 * [CN] 只在有动作进行时显示刷新头（下拉、刷新中、刷新结束后的收回），刷新结束、空闲且完全收回后自动隐藏。在导航栏默认透明的系统上默认开启
 *      （iOS 26 及以后的玻璃导航栏）：收回的刷新头正好位于导航栏下方，会透过导航栏显示在标题上。更早的系统默认关闭，需要时手动设为 YES。
 *      隐藏通过遮罩实现，`hidden`、`alpha`（及 `automaticallyChangeAlpha`）保持调用方的设置。NO 保持 MJRefresh 的行为：收回后的刷新头保持可见。
 */
@property (nonatomic) BOOL autoHideRefresh;
@end

NS_ASSUME_NONNULL_END
