//
//  CYLRefreshTrailer.h
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "CYLRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The base class of the horizontal controls at the trailing end of the content: swiping past the end and
 *      releasing runs the refreshing callback (for example to open details); set one as a scroll view's
 *      `cyl_trailer`.
 * [CN] 位于内容末端的横向控件基类：越过末端滑动并松手时执行刷新回调（例如打开详情）；设为滚动视图的 `cyl_trailer` 使用。
 */
@interface CYLRefreshTrailer : CYLRefreshComponent

/*!
 * 创建trailer
 */
+ (instancetype)trailerWithRefreshingBlock:(CYLRefreshComponentAction)refreshingBlock;
/*!
 * 创建trailer
 */
+ (instancetype)trailerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

/*!
 * 忽略多少scrollView的contentInset的right
 */
@property (assign, nonatomic) CGFloat ignoredScrollViewContentInsetRight;

/*!
 * Whether scrolling to the end starts refreshing without a release (default NO, which keeps the pull-and-release behavior).
 * Only applies when the content is wider than the scroll view.
 */
@property (assign, nonatomic, getter=isAutomaticallyRefresh) BOOL automaticallyRefresh;

/*!
 * How much of the trailer must be visible before it refreshes automatically (default 1.0, fully visible).
 */
@property (assign, nonatomic) CGFloat triggerAutomaticallyRefreshPercent;

/*!
 * Automatic refreshes allowed per drag (default 1); -1 means unlimited. Scrolling without a drag is not limited.
 */
@property (nonatomic) NSInteger autoTriggerTimes;


@end

NS_ASSUME_NONNULL_END
