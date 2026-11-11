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

/*! 刷新控件的状态 */
typedef NS_ENUM(NSInteger, CYLRefreshState) {
    /*! 普通闲置状态 */
    CYLRefreshStateIdle = 1,
    /*! 松开就可以进行刷新的状态 */
    CYLRefreshStatePulling,
    /*! 正在刷新中的状态 */
    CYLRefreshStateRefreshing,
    /*! 即将刷新的状态 */
    CYLRefreshStateWillRefresh,
    /*! 所有数据加载完毕，没有更多的数据了 */
    CYLRefreshStateNoMoreData
};

/*! 进入刷新状态的回调 */
typedef void (^CYLRefreshComponentRefreshingBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");
/*! 开始刷新后的回调(进入刷新状态后的回调) */
typedef void (^CYLRefreshComponentBeginRefreshingCompletionBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");
/*! 结束刷新后的回调 */
typedef void (^CYLRefreshComponentEndRefreshingCompletionBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");

/*! 刷新用到的回调类型 */
typedef void (^CYLRefreshComponentAction)(void);

/*! 刷新控件的基类 */
@interface CYLRefreshComponent : UIView
{
    /*! 记录scrollView刚开始的inset */
    UIEdgeInsets _scrollViewOriginalInset;
    /*! 父控件 */
    __weak UIScrollView *_scrollView;
}

#pragma mark - 刷新动画时间控制
/*! 快速动画时间(一般用在刷新开始的回弹动画), 默认 0.25 */
@property (nonatomic) NSTimeInterval fastAnimationDuration;
/*! 慢速动画时间(一般用在刷新结束后的回弹动画), 默认 0.4*/
@property (nonatomic) NSTimeInterval slowAnimationDuration;
/*! 关闭全部默认动画效果, 可以简单粗暴地解决 CollectionView 的回弹动画 bug */
- (instancetype)setAnimationDisabled;

#pragma mark - 刷新回调
/*! 正在刷新的回调 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction refreshingBlock;
/*! 设置回调对象和回调方法 */
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action;

/*! 回调对象 */
@property (weak, nonatomic) id refreshingTarget;
/*! 回调方法 */
@property (assign, nonatomic) SEL refreshingAction;
/*! 触发回调（交给子类去调用） */
- (void)executeRefreshingCallback;

#pragma mark - 刷新状态控制
/*! 进入刷新状态 */
- (void)beginRefreshing;
- (void)beginRefreshingWithCompletionBlock:(void (^)(void))completionBlock
    NS_SWIFT_NAME(beginRefreshing(completionBlock:));
/*! 开始刷新后的回调(进入刷新状态后的回调) */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction beginRefreshingCompletionBlock;
/*! 带动画的结束刷新的回调 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction endRefreshingAnimateCompletionBlock CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `endRefreshingAnimationBeginAction` instead");
@property (copy, nonatomic, nullable) CYLRefreshComponentAction endRefreshingAnimationBeginAction;
/*! 结束刷新的回调 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction endRefreshingCompletionBlock;
/*! 结束刷新状态 */
- (void)endRefreshing;
- (void)endRefreshingWithCompletionBlock:(void (^)(void))completionBlock
    NS_SWIFT_NAME(endRefreshing(completionBlock:));
/*! 是否正在刷新 */
@property (assign, nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

/*! Mutual exclusion with the other refresh components of the same scroll view (header, footer, trailer). Default NO:
 they run independently, except that a header refresh already holds back the automatic footer. YES: while another
 component is refreshing, this one does not start; the pull is dropped and `blockedByOtherRefreshBlock` runs.
 Set it on both components for a two-way exclusion. */
@property (assign, nonatomic, getter=isExclusiveWithOtherRefresh) BOOL exclusiveWithOtherRefresh;
/*! Runs on the main thread each time a start was held back by `exclusiveWithOtherRefresh`, for example to show
 "refreshing, please wait". */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction blockedByOtherRefreshBlock;

/*! 刷新状态 一般交给子类内部实现 */
@property (assign, nonatomic) CYLRefreshState state;

#pragma mark - 交给子类去访问
/*! 记录scrollView刚开始的inset */
@property (assign, nonatomic, readonly) UIEdgeInsets scrollViewOriginalInset;
/*! 父控件 */
@property (weak, nonatomic, readonly) UIScrollView *scrollView;

/*! 当在 CollectionView 中使用 CollectionViewLayout 中的 flipsHorizontallyInOppositeLayoutDirection 时, 会反向 View 内容. 这里列出的 view 会被自动反向回来. */
@property (nonatomic, readonly) NSArray<UIView *> *flipsHorizontallyInOppositeLayoutDirectionViews;

/*!
 * 当在 CollectionView 中使用 CollectionViewLayout 中的 flipsHorizontallyInOppositeLayoutDirection 时, 会反向 View 内容. 这里列出的 view 会被自动反向回来. 默认为空
 * - Attention: 增量内容, 不会覆盖 CYLRefresh 中的 flipsHorizontallyInOppositeLayoutDirectionViews
 */
@property (nonatomic, readonly) NSArray<UIView *> *additionalFlipsViews;

#pragma mark - 交给子类们去实现
/*! 初始化 */
- (void)prepare NS_REQUIRES_SUPER;
/*! 摆放子控件frame */
- (void)placeSubviews NS_REQUIRES_SUPER;
/*! 当scrollView的contentOffset发生改变的时候调用 */
- (void)scrollViewContentOffsetDidChange:(nullable NSDictionary *)change NS_REQUIRES_SUPER;
/*! 当scrollView的contentSize发生改变的时候调用 */
- (void)scrollViewContentSizeDidChange:(nullable NSDictionary *)change NS_REQUIRES_SUPER;
/*! 当scrollView的拖拽状态发生改变的时候调用 */
- (void)scrollViewPanStateDidChange:(nullable NSDictionary *)change NS_REQUIRES_SUPER;

/*! 多语言配置 language 发生变化时调用

 `CYLRefreshConfig.defaultConfig.language` 发生改变时调用.

 ⚠️ 父类会调用 `placeSubviews` 方法, 请勿在 placeSubviews 中调用本方法, 造成死循环. 子类在需要重新布局时, 在配置完修改后, 最后再调用 super 方法, 否则可能导致配置修改后, 定位先于修改执行.
 */
- (void)i18nDidChange NS_REQUIRES_SUPER;

#pragma mark - Icon animation / 图标动画
/*!
 * [EN] The icon drawn by the library's icon component (CYLRefreshIconView): GIF, Lottie, PAG or Rive. Created when an
 *      icon animation is first set; the arrow, spinner or GIF view of the control is then hidden and the icon takes its
 *      place, with the same layout. It plays by a fixed policy (pulling plays, refreshing loops, ending stops; see
 *      CYLRefreshIconView.h). Without an icon animation the control is unchanged.
 * [CN] 由本库图标组件（CYLRefreshIconView）绘制的图标：GIF、Lottie、PAG 或 Rive。首次设置图标动画时创建；控件原有的箭头、菊花
 *      或 GIF 视图随之隐藏，图标按相同的布局放在原位置，并按固定策略播放（拖动播放、刷新中循环、结束停止，见 CYLRefreshIconView.h）。
 *      不设置图标动画时控件保持不变。
 */
@property (strong, nonatomic, readonly) CYLRefreshIconView *iconView;
/*! [EN] YES once any icon animation is set. [CN] 设置了任意图标动画后为 YES。 */
@property (nonatomic, readonly) BOOL usesIconView;
/*!
 * [EN] The icon for a state, as CYLPlaceholderView item attributes (`CYLPlaceholderItemAnimationFilePath`,
 *      `CYLPlaceholderItemAnimationSize`, `CYLPlaceholderItemAnimationOptions`, `CYLPlaceholderItemAnimationColors`…);
 *      nil removes it. A state without attributes uses the idle state's, so one call sets the icon for every state.
 * [CN] 某个状态的图标，使用 CYLPlaceholderView 的 item 属性；nil 表示移除。没有属性的状态使用空闲状态的属性，因此调用一次即可设置所有状态的图标。
 */
- (instancetype)setIconAnimationAttributes:(nullable NSDictionary<NSString *, id> *)attributes
                                  forState:(CYLRefreshState)state
    NS_SWIFT_NAME(setIconAnimation(attributes:for:));
/*! [EN] An animation file (.gif, .json Lottie, .pag, .riv) at `size` for a state. [CN] 某个状态使用 `size` 大小的动画文件。 */
- (instancetype)setIconAnimationFilePath:(NSString *)filePath size:(CGSize)size forState:(CYLRefreshState)state
    NS_SWIFT_NAME(setIconAnimation(filePath:size:for:));
/*!
 * [EN] An animation of the core bundle (`+[CYLPlaceholderView bundledAnimationFileNames]`, such as
 *      "CYLPlaceholderLoading.json") at `size` for a state, with the options it needs.
 * [CN] 某个状态使用核心 bundle 中 `size` 大小的内置动画（如 "CYLPlaceholderLoading.json"），并带上它需要的选项。
 */
- (instancetype)setBundledIconAnimation:(NSString *)fileName size:(CGSize)size forState:(CYLRefreshState)state
    NS_SWIFT_NAME(setIconAnimation(bundled:size:for:));
/*!
 * [EN] The animations of the core bundle meant for a refresh icon, sorted: the `CYLRefresh*` files (pull arrows,
 *      spinners, loading more, done; GIF, Lottie and Rive) and the placeholder animations that also suit a refresh
 *      control (CYLPlaceholderRefresh.json, CYLPlaceholderLoading.pag, CYLPlaceholderPullHint.pag,
 *      CYLPlaceholderPullToRefresh.riv…). Each name can be passed to `-setBundledIconAnimation:size:forState:`.
 * [CN] 核心 bundle 中适合作为刷新图标的动画（已排序）：`CYLRefresh*` 文件（下拉箭头、加载圈、加载更多、完成；GIF、Lottie、Rive），
 *      以及同样适合刷新控件的占位动画（如 CYLPlaceholderRefresh.json、CYLPlaceholderLoading.pag）。每个名称都可传给
 *      `-setBundledIconAnimation:size:forState:`。
 */
@property (class, nonatomic, readonly) NSArray<NSString *> *bundledIconAnimationFileNames;

#pragma mark - 其他
/*! 拉拽的百分比(交给子类重写) */
@property (assign, nonatomic) CGFloat pullingPercent;
/*! 根据拖拽比例自动切换透明度 */
@property (assign, nonatomic, getter=isAutoChangeAlpha) BOOL autoChangeAlpha CYLRefreshDeprecated("请使用automaticallyChangeAlpha属性");
/*! 根据拖拽比例自动切换透明度 */
@property (assign, nonatomic, getter=isAutomaticallyChangeAlpha) BOOL automaticallyChangeAlpha;
@end

@interface UILabel(CYLRefresh)
+ (instancetype)cyl_label;
- (CGFloat)cyl_textWidth;
@end

@interface CYLRefreshComponent (ChainingGrammar)

#pragma mark - <<< 为 Swift 扩展链式语法 >>> -
/*! 自动变化透明度 */
- (instancetype)cyl_autoChangeTransparency:(BOOL)isAutoChange;
/*! 刷新开始后立即调用的回调 */
- (instancetype)cyl_afterBeginningAction:(CYLRefreshComponentAction)action;
/*! 刷新动画开始后立即调用的回调 */
- (instancetype)cyl_endingAnimationBeginningAction:(CYLRefreshComponentAction)action;
/*! 刷新结束后立即调用的回调 */
- (instancetype)cyl_afterEndingAction:(CYLRefreshComponentAction)action;


/*!
 * 需要子类必须实现
 * @param scrollView 赋值给的 ScrollView 的 Header/Footer/Trailer
 */
- (instancetype)cyl_linkTo:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
