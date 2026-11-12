//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshComponent.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  刷新控件的基类

#import <UIKit/UIKit.h>
#import "CYLRefreshConst.h"

@class CYLRefreshIconView;

NS_ASSUME_NONNULL_BEGIN

/*!
 * 刷新控件的状态
 */
typedef NS_ENUM(NSInteger, CYLRefreshState) {
    /*!
     * 普通闲置状态
     */
    CYLRefreshStateIdle = 1,
    /*!
     * 松开就可以进行刷新的状态
     */
    CYLRefreshStatePulling,
    /*!
     * 正在刷新中的状态
     */
    CYLRefreshStateRefreshing,
    /*!
     * 即将刷新的状态
     */
    CYLRefreshStateWillRefresh,
    /*!
     * 所有数据加载完毕，没有更多的数据了
     */
    CYLRefreshStateNoMoreData
};

@class CYLRefreshComponent;

/*!
 * [EN] How the header moves while it is pulled (SmartRefreshControl's `UISmartScrollMode`).
 * [CN] 下拉时刷新头的移动方式（对应 SmartRefreshControl 的 `UISmartScrollMode`）。
 */
typedef NS_ENUM(NSInteger, CYLRefreshScrollMode) {
    /*!
     * [EN] The header moves with the content (default, MJRefresh's behavior). [CN] 刷新头随内容移动（默认，MJRefresh 的行为）。
     */
    CYLRefreshScrollModeMove = 0,
    /*!
     * [EN] The header stretches to fill the whole pulled distance. [CN] 刷新头拉伸，铺满整个下拉距离。
     */
    CYLRefreshScrollModeStretch,
    /*!
     * [EN] The header slides in at the top of the visible area, in front of the content. [CN] 刷新头从可见区域顶部滑入，位于内容前面。
     */
    CYLRefreshScrollModeFront,
};

/*!
 * [EN] The detailed phase of a refresh control: `state` plus whether the user is still dragging and the finishing hold
 *      (SmartRefreshControl's `UIRefreshStatus` / `UISmartFooterStatus`).
 * [CN] 刷新控件的细分阶段：`state` 加上是否仍在拖动以及结束停留（对应 SmartRefreshControl 的 `UIRefreshStatus` / `UISmartFooterStatus`）。
 */
typedef NS_ENUM(NSInteger, CYLRefreshPhase) {
    /*!
     * [EN] Idle, not pulled. [CN] 空闲，未拉动。
     */
    CYLRefreshPhaseIdle = 1,
    /*!
     * [EN] Pulled, not far enough to refresh yet. [CN] 已拉动，但还不够远，松手不会刷新。
     */
    CYLRefreshPhasePullToRefresh,
    /*!
     * [EN] Pulled far enough; releasing starts the refresh. [CN] 已拉够距离，松手即刷新。
     */
    CYLRefreshPhaseReleaseToRefresh,
    /*!
     * [EN] `beginRefreshing` was called before the control was on screen. [CN] 控件上屏前调用了 `beginRefreshing`。
     */
    CYLRefreshPhaseWillRefresh,
    /*!
     * [EN] Released past the trigger point, moving to the refreshing position. [CN] 已越过触发点松手，正移动到刷新位置。
     */
    CYLRefreshPhaseReleasing,
    /*!
     * [EN] Refreshing or loading. [CN] 正在刷新或加载。
     */
    CYLRefreshPhaseRefreshing,
    /*!
     * [EN] Finished, holding for `finishDuration` before retracting. [CN] 已结束，收回前停留 `finishDuration`。
     */
    CYLRefreshPhaseFinishing,
    /*!
     * [EN] A footer showing that all data is loaded. [CN] 加载尾显示已全部加载。
     */
    CYLRefreshPhaseNoMoreData,
};

/*!
 * [EN] A refreshing callback that receives the control (SmartRefreshControl's `RefreshBlock`).
 * [CN] 带控件参数的刷新回调（对应 SmartRefreshControl 的 `RefreshBlock`）。
 */
typedef void (^CYLRefreshComponentHandler)(__kindof CYLRefreshComponent *component);

/*!
 * 进入刷新状态的回调
 */
typedef void (^CYLRefreshComponentRefreshingBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");
/*!
 * 开始刷新后的回调(进入刷新状态后的回调)
 */
typedef void (^CYLRefreshComponentBeginRefreshingCompletionBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");
/*!
 * 结束刷新后的回调
 */
typedef void (^CYLRefreshComponentEndRefreshingCompletionBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");

/*!
 * 刷新用到的回调类型
 */
typedef void (^CYLRefreshComponentAction)(void);

/*!
 * 刷新控件的基类
 */
@interface CYLRefreshComponent : UIView
{
    /*!
     * 记录scrollView刚开始的inset
     */
    UIEdgeInsets _scrollViewOriginalInset;
    /*!
     * 父控件
     */
    __weak UIScrollView *_scrollView;
}

#pragma mark - 刷新动画时间控制
/*!
 * 快速动画时间(一般用在刷新开始的回弹动画), 默认 0.25
 */
@property (nonatomic) NSTimeInterval fastAnimationDuration;
/*!
 * 慢速动画时间(一般用在刷新结束后的回弹动画), 默认 0.4
 */
@property (nonatomic) NSTimeInterval slowAnimationDuration;
/*!
 * 关闭全部默认动画效果, 可以简单粗暴地解决 CollectionView 的回弹动画 bug
 */
- (instancetype)setAnimationDisabled;

#pragma mark - 刷新回调
/*!
 * 正在刷新的回调
 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction refreshingBlock;
/*!
 * 设置回调对象和回调方法
 */
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action;

/*!
 * 回调对象
 */
@property (weak, nonatomic) id refreshingTarget;
/*!
 * 回调方法
 */
@property (assign, nonatomic) SEL refreshingAction;
/*!
 * 触发回调（交给子类去调用）
 */
- (void)executeRefreshingCallback;

#pragma mark - 刷新状态控制
/*!
 * 进入刷新状态
 */
- (void)beginRefreshing;
- (void)beginRefreshingWithCompletionBlock:(void (^)(void))completionBlock
    NS_SWIFT_NAME(beginRefreshing(completionBlock:));
/*!
 * 开始刷新后的回调(进入刷新状态后的回调)
 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction beginRefreshingCompletionBlock;
/*!
 * 带动画的结束刷新的回调
 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction endRefreshingAnimateCompletionBlock CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `endRefreshingAnimationBeginAction` instead");
@property (copy, nonatomic, nullable) CYLRefreshComponentAction endRefreshingAnimationBeginAction;
/*!
 * 结束刷新的回调
 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction endRefreshingCompletionBlock;
/*!
 * 结束刷新状态
 */
- (void)endRefreshing;
- (void)endRefreshingWithCompletionBlock:(void (^)(void))completionBlock
    NS_SWIFT_NAME(endRefreshing(completionBlock:));
/*!
 * 是否正在刷新
 */
@property (assign, nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

/*!
 * Mutual exclusion with the other refresh components of the same scroll view (header, footer, trailer). Default NO:
 * they run independently, except that a header refresh already holds back the automatic footer. YES: while another
 * component is refreshing, this one does not start; the pull is dropped and `blockedByOtherRefreshBlock` runs.
 * Set it on both components for a two-way exclusion.
 */
@property (assign, nonatomic, getter=isExclusiveWithOtherRefresh) BOOL exclusiveWithOtherRefresh;
/*!
 * Runs on the main thread each time a start was held back by `exclusiveWithOtherRefresh`, for example to show
 * "refreshing, please wait".
 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction blockedByOtherRefreshBlock;

/*!
 * 刷新状态 一般交给子类内部实现
 */
@property (assign, nonatomic) CYLRefreshState state;

#pragma mark - 交给子类去访问
/*!
 * 记录scrollView刚开始的inset
 */
@property (assign, nonatomic, readonly) UIEdgeInsets scrollViewOriginalInset;
/*!
 * 父控件
 */
@property (weak, nonatomic, readonly) UIScrollView *scrollView;

/*!
 * 当在 CollectionView 中使用 CollectionViewLayout 中的 flipsHorizontallyInOppositeLayoutDirection 时, 会反向 View 内容. 这里列出的 view 会被自动反向回来.
 */
@property (nonatomic, readonly) NSArray<UIView *> *flipsHorizontallyInOppositeLayoutDirectionViews;

/*!
 * 当在 CollectionView 中使用 CollectionViewLayout 中的 flipsHorizontallyInOppositeLayoutDirection 时, 会反向 View 内容. 这里列出的 view 会被自动反向回来. 默认为空
 * - Attention: 增量内容, 不会覆盖 CYLRefresh 中的 flipsHorizontallyInOppositeLayoutDirectionViews
 */
@property (nonatomic, readonly) NSArray<UIView *> *additionalFlipsViews;

#pragma mark - 交给子类们去实现
/*!
 * 初始化
 */
- (void)prepare NS_REQUIRES_SUPER;
/*!
 * 摆放子控件frame
 */
- (void)placeSubviews NS_REQUIRES_SUPER;
/*!
 * 当scrollView的contentOffset发生改变的时候调用
 */
- (void)scrollViewContentOffsetDidChange:(nullable NSDictionary *)change NS_REQUIRES_SUPER;
/*!
 * 当scrollView的contentSize发生改变的时候调用
 */
- (void)scrollViewContentSizeDidChange:(nullable NSDictionary *)change NS_REQUIRES_SUPER;
/*!
 * 当scrollView的拖拽状态发生改变的时候调用
 */
- (void)scrollViewPanStateDidChange:(nullable NSDictionary *)change NS_REQUIRES_SUPER;

/*!
 * 多语言配置 language 发生变化时调用
 *
 * `CYLRefreshConfig.defaultConfig.language` 发生改变时调用.
 *
 * ⚠️ 父类会调用 `placeSubviews` 方法, 请勿在 placeSubviews 中调用本方法, 造成死循环. 子类在需要重新布局时, 在配置完修改后, 最后再调用 super 方法, 否则可能导致配置修改后, 定位先于修改执行.
 */
- (void)i18nDidChange NS_REQUIRES_SUPER;

#pragma mark - 其他
/*!
 * 拉拽的百分比(交给子类重写)
 */
@property (assign, nonatomic) CGFloat pullingPercent;
/*!
 * 根据拖拽比例自动切换透明度
 */
@property (assign, nonatomic, getter=isAutoChangeAlpha) BOOL autoChangeAlpha CYLRefreshDeprecated("请使用automaticallyChangeAlpha属性");
/*!
 * 根据拖拽比例自动切换透明度
 */
@property (assign, nonatomic, getter=isAutomaticallyChangeAlpha) BOOL automaticallyChangeAlpha;

#pragma mark - SmartRefreshControl-style API

/*!
 * [EN] Creates the control and attaches it to `scrollView` as its header, footer or trailer (by class).
 * [CN] 创建控件，并按类型作为 `scrollView` 的刷新头、加载尾或 trailer 挂上。
 */
+ (instancetype)attach:(UIScrollView *)scrollView NS_SWIFT_NAME(attach(to:));
/*!
 * [EN] Creates, attaches and adds a refreshing target in one call. [CN] 一次完成创建、挂上并添加刷新回调对象。
 */
+ (instancetype)attach:(UIScrollView *)scrollView target:(id)target action:(SEL)action NS_SWIFT_NAME(attach(to:target:action:));
/*!
 * [EN] Attaches this control to `scrollView` as its header, footer or trailer (by class).
 * [CN] 按类型把本控件作为 `scrollView` 的刷新头、加载尾或 trailer 挂上。
 */
- (void)attach:(UIScrollView *)scrollView NS_SWIFT_NAME(attach(to:));
/*!
 * [EN] Adds a target-action called on every refresh, besides `refreshingTarget` and the blocks; several can be added.
 *      `action` may take no argument or the control. [CN] 添加每次刷新都会调用的 target-action（`refreshingTarget` 与 block 之外，可添加多个）；
 *      `action` 可以不带参数或带控件参数。
 */
- (void)addTarget:(id)target action:(SEL)action NS_SWIFT_NAME(addTarget(_:action:));
/*!
 * [EN] Removes a target-action added with `addTarget:action:`. [CN] 移除 `addTarget:action:` 添加的 target-action。
 */
- (void)removeTarget:(id)target action:(SEL)action NS_SWIFT_NAME(removeTarget(_:action:));
/*!
 * [EN] Called on every refresh with the control. [CN] 每次刷新时调用，参数为控件本身。
 */
@property (copy, nonatomic, nullable) CYLRefreshComponentHandler refreshingHandler;
/*!
 * [EN] YES while the control is on a scroll view. [CN] 控件挂在滚动视图上时为 YES。
 */
@property (nonatomic, readonly, getter=isAttached) BOOL attached;
/*!
 * [EN] How far to pull, as a multiple of `expandHeight`, before releasing refreshes. Default 1.
 * [CN] 松手刷新所需的拉动距离，为 `expandHeight` 的倍数，默认 1。
 */
@property (nonatomic) CGFloat triggerRate;
/*!
 * [EN] Seconds the control stays open after the refresh ends, before retracting. Default 0.
 * [CN] 刷新结束后、收回前停留的秒数，默认 0。
 */
@property (nonatomic) NSTimeInterval finishDuration;
/*!
 * [EN] How the header moves while pulled (headers only). Default `CYLRefreshScrollModeMove`.
 * [CN] 下拉时刷新头的移动方式（仅刷新头），默认 `CYLRefreshScrollModeMove`。
 */
@property (nonatomic) CYLRefreshScrollMode scrollMode;
/*!
 * [EN] Foreground color: every label, image tint and spinner of the control. nil keeps each view's own color.
 * [CN] 前景色：控件中所有文字、图片着色与菊花。nil 保留各视图自己的颜色。
 */
@property (strong, nonatomic, nullable) UIColor *colorAccent;
/*!
 * [EN] Background color of the control. nil keeps a clear background.
 * [CN] 控件背景色。nil 保持透明背景。
 */
@property (strong, nonatomic, nullable) UIColor *colorPrimary;
/*!
 * [EN] YES while the control holds its refreshing position (refreshing or about to). [CN] 控件处于刷新位置（刷新中或即将刷新）时为 YES。
 */
@property (nonatomic, readonly, getter=isExpanded) BOOL expanded;
/*!
 * [EN] The control's height when open; constant while `scrollMode` stretches the frame. [CN] 控件展开时的高度；`scrollMode` 拉伸 frame 时保持不变。
 */
@property (nonatomic, readonly) CGFloat expandHeight;
/*!
 * [EN] Points pulled, `pullingPercent` × `expandHeight` × `triggerRate`. [CN] 已拉动的点数，`pullingPercent` × `expandHeight` × `triggerRate`。
 */
@property (nonatomic, readonly) CGFloat dragOffset;
/*!
 * [EN] The detailed phase. [CN] 细分阶段。
 */
@property (nonatomic, readonly) CYLRefreshPhase phase;
/*!
 * [EN] YES when the control is in one of `phases` (NSNumber-wrapped `CYLRefreshPhase` values).
 * [CN] 控件处于 `phases`（以 NSNumber 包装的 `CYLRefreshPhase`）之一时为 YES。
 */
- (BOOL)isInAnyPhase:(NSArray<NSNumber *> *)phases NS_SWIFT_NAME(isIn(phases:));
/*!
 * [EN] The same with a list of phases ending in 0, like SmartRefreshControl's `inStatus:`.
 * [CN] 同上，参数为以 0 结尾的阶段列表，与 SmartRefreshControl 的 `inStatus:` 相同。
 */
- (BOOL)isInPhases:(CYLRefreshPhase)phase, ... NS_SWIFT_UNAVAILABLE("Use isIn(phases:)");
/*!
 * [EN] Ends the refresh and records whether it succeeded: the control can show it for `finishDuration`
 *      (`-refreshDidFinishWithSuccess:`), then retracts. `endRefreshing` is the same with YES.
 * [CN] 结束刷新并记录是否成功：控件可在 `finishDuration` 内显示结果（`-refreshDidFinishWithSuccess:`），然后收回。`endRefreshing` 相当于传 YES。
 */
- (void)endRefreshingWithSuccess:(BOOL)success NS_SWIFT_NAME(endRefreshing(success:));
/*!
 * [EN] Whether the last refresh ended successfully. [CN] 上一次刷新是否成功结束。
 */
@property (nonatomic, readonly) BOOL lastRefreshSucceeded;

#pragma mark Subclass hooks

/*!
 * [EN] Starts observing the scroll view (content offset, size and inset, pan state); called on attach. Override to
 *      observe more, and call super. [CN] 开始监听滚动视图（偏移、内容尺寸、inset、拖动手势）；挂上时调用。可重写以增加监听，并调用 super。
 */
- (void)addObservers NS_REQUIRES_SUPER;
/*!
 * [EN] Stops what `addObservers` started; called on detach. [CN] 停止 `addObservers` 开始的监听；离开时调用。
 */
- (void)removeObservers NS_REQUIRES_SUPER;

/*!
 * [EN] Called after the control is attached to `scrollView`. [CN] 控件挂到 `scrollView` 后调用。
 */
- (void)didAttachToScrollView:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
/*!
 * [EN] Called before the control leaves `scrollView`. [CN] 控件离开 `scrollView` 前调用。
 */
- (void)willDetachFromScrollView:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
/*!
 * [EN] Called when the scroll view's `contentInset` changes. [CN] 滚动视图的 `contentInset` 变化时调用。
 */
- (void)scrollViewContentInsetDidChange:(nullable NSDictionary *)change NS_REQUIRES_SUPER;
/*!
 * [EN] Called on every scroll with the pulled points, the percent and whether the user drags.
 * [CN] 每次滚动时调用，参数为已拉动点数、百分比以及用户是否在拖动。
 */
- (void)didScrollWithOffset:(CGFloat)offset percent:(CGFloat)percent dragging:(BOOL)dragging;
/*!
 * [EN] Called when `phase` changes. [CN] `phase` 变化时调用。
 */
- (void)phaseDidChangeFrom:(CYLRefreshPhase)oldPhase to:(CYLRefreshPhase)phase;
/*!
 * [EN] Called when the refresh ends, with its result; state controls show it here. [CN] 刷新结束时调用并传入结果；带文字的控件在此显示结果。
 */
- (void)refreshDidFinishWithSuccess:(BOOL)success NS_REQUIRES_SUPER;
/*!
 * [EN] Seconds to stay open after the refresh ends; returns `finishDuration` by default.
 * [CN] 刷新结束后停留的秒数；默认返回 `finishDuration`。
 */
- (NSTimeInterval)finishingDurationWithSuccess:(BOOL)success;
@end

@interface UILabel(CYLRefresh)
+ (instancetype)cyl_label;
- (CGFloat)cyl_textWidth;
@end

@interface CYLRefreshComponent (ChainingGrammar)

#pragma mark - <<< 为 Swift 扩展链式语法 >>> -
/*!
 * 自动变化透明度
 */
- (instancetype)cyl_autoChangeTransparency:(BOOL)isAutoChange NS_SWIFT_NAME(cyl_autoChangeTransparency(_:));
/*!
 * 刷新开始后立即调用的回调
 */
- (instancetype)cyl_afterBeginningAction:(CYLRefreshComponentAction)action;
/*!
 * 刷新动画开始后立即调用的回调
 */
- (instancetype)cyl_endingAnimationBeginningAction:(CYLRefreshComponentAction)action;
/*!
 * 刷新结束后立即调用的回调
 */
- (instancetype)cyl_afterEndingAction:(CYLRefreshComponentAction)action;


/*!
 * 需要子类必须实现
 * @param scrollView 赋值给的 ScrollView 的 Header/Footer/Trailer
 */
- (instancetype)cyl_linkTo:(UIScrollView *)scrollView NS_SWIFT_NAME(cyl_link(to:));

@end

NS_ASSUME_NONNULL_END
