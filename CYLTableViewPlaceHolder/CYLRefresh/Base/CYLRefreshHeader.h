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
 * [EN] Hides the header while it is idle and fully retracted (not pulled, not refreshing, not retracting). Default YES.
 *      Since iOS 26 the navigation bar is transparent glass, and a retracted header sits right under it, showing
 *      through over the title. The header is masked out, so its `hidden` and `alpha` (and `automaticallyChangeAlpha`)
 *      stay as the caller set them. Set NO for MJRefresh's behavior, where the retracted header stays visible.
 * [CN] 空闲且完全收回（未下拉、未刷新、未在收回动画中）时隐藏刷新头，默认 YES。iOS 26 起导航栏是透明的玻璃效果，收回的刷新头正好位于
 *      导航栏下方，会透过导航栏显示在标题上。隐藏通过遮罩实现，`hidden`、`alpha`（及 `automaticallyChangeAlpha`）保持调用方的设置。
 *      设为 NO 恢复 MJRefresh 的行为：收回后的刷新头保持可见。
 */
@property (nonatomic) BOOL hidesWhenIdle;
@end

NS_ASSUME_NONNULL_END
