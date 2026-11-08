//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshComponent.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  刷新控件的基类

#import <UIKit/UIKit.h>
#import "CYLRefreshConst.h"

NS_ASSUME_NONNULL_BEGIN

/** 刷新控件的状态 */
typedef NS_ENUM(NSInteger, CYLRefreshState) {
    /** 普通闲置状态 */
    CYLRefreshStateIdle = 1,
    /** 松开就可以进行刷新的状态 */
    CYLRefreshStatePulling,
    /** 正在刷新中的状态 */
    CYLRefreshStateRefreshing,
    /** 即将刷新的状态 */
    CYLRefreshStateWillRefresh,
    /** 所有数据加载完毕，没有更多的数据了 */
    CYLRefreshStateNoMoreData
};

/** 进入刷新状态的回调 */
typedef void (^CYLRefreshComponentRefreshingBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");
/** 开始刷新后的回调(进入刷新状态后的回调) */
typedef void (^CYLRefreshComponentBeginRefreshingCompletionBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");
/** 结束刷新后的回调 */
typedef void (^CYLRefreshComponentEndRefreshingCompletionBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");

/** 刷新用到的回调类型 */
typedef void (^CYLRefreshComponentAction)(void);

/** 刷新控件的基类 */
@interface CYLRefreshComponent : UIView
{
    /** 记录scrollView刚开始的inset */
    UIEdgeInsets _scrollViewOriginalInset;
    /** 父控件 */
    __weak UIScrollView *_scrollView;
}

#pragma mark - 刷新动画时间控制
/** 快速动画时间(一般用在刷新开始的回弹动画), 默认 0.25 */
@property (nonatomic) NSTimeInterval fastAnimationDuration;
/** 慢速动画时间(一般用在刷新结束后的回弹动画), 默认 0.4*/
@property (nonatomic) NSTimeInterval slowAnimationDuration;
/** 关闭全部默认动画效果, 可以简单粗暴地解决 CollectionView 的回弹动画 bug */
- (instancetype)setAnimationDisabled;

#pragma mark - 刷新回调
/** 正在刷新的回调 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction refreshingBlock;
/** 设置回调对象和回调方法 */
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action;

/** 回调对象 */
@property (weak, nonatomic) id refreshingTarget;
/** 回调方法 */
@property (assign, nonatomic) SEL refreshingAction;
/** 触发回调（交给子类去调用） */
- (void)executeRefreshingCallback;

#pragma mark - 刷新状态控制
/** 进入刷新状态 */
- (void)beginRefreshing;
- (void)beginRefreshingWithCompletionBlock:(void (^)(void))completionBlock;
/** 开始刷新后的回调(进入刷新状态后的回调) */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction beginRefreshingCompletionBlock;
/** 带动画的结束刷新的回调 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction endRefreshingAnimateCompletionBlock CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `endRefreshingAnimationBeginAction` instead");
@property (copy, nonatomic, nullable) CYLRefreshComponentAction endRefreshingAnimationBeginAction;
/** 结束刷新的回调 */
@property (copy, nonatomic, nullable) CYLRefreshComponentAction endRefreshingCompletionBlock;
/** 结束刷新状态 */
- (void)endRefreshing;
- (void)endRefreshingWithCompletionBlock:(void (^)(void))completionBlock;
/** 是否正在刷新 */
@property (assign, nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

/** 刷新状态 一般交给子类内部实现 */
@property (assign, nonatomic) CYLRefreshState state;

#pragma mark - 交给子类去访问
/** 记录scrollView刚开始的inset */
@property (assign, nonatomic, readonly) UIEdgeInsets scrollViewOriginalInset;
/** 父控件 */
@property (weak, nonatomic, readonly) UIScrollView *scrollView;

/// 当在 CollectionView 中使用 CollectionViewLayout 中的 flipsHorizontallyInOppositeLayoutDirection 时, 会反向 View 内容. 这里列出的 view 会被自动反向回来.
@property (nonatomic, readonly) NSArray<UIView *> *flipsHorizontallyInOppositeLayoutDirectionViews;

/// 当在 CollectionView 中使用 CollectionViewLayout 中的 flipsHorizontallyInOppositeLayoutDirection 时, 会反向 View 内容. 这里列出的 view 会被自动反向回来. 默认为空
/// - Attention: 增量内容, 不会覆盖 CYLRefresh 中的 flipsHorizontallyInOppositeLayoutDirectionViews
@property (nonatomic, readonly) NSArray<UIView *> *additionalFlipsViews;

#pragma mark - 交给子类们去实现
/** 初始化 */
- (void)prepare NS_REQUIRES_SUPER;
/** 摆放子控件frame */
- (void)placeSubviews NS_REQUIRES_SUPER;
/** 当scrollView的contentOffset发生改变的时候调用 */
- (void)scrollViewContentOffsetDidChange:(nullable NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的contentSize发生改变的时候调用 */
- (void)scrollViewContentSizeDidChange:(nullable NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的拖拽状态发生改变的时候调用 */
- (void)scrollViewPanStateDidChange:(nullable NSDictionary *)change NS_REQUIRES_SUPER;

/** 多语言配置 language 发生变化时调用

 `CYLRefreshConfig.defaultConfig.language` 发生改变时调用.

 ⚠️ 父类会调用 `placeSubviews` 方法, 请勿在 placeSubviews 中调用本方法, 造成死循环. 子类在需要重新布局时, 在配置完修改后, 最后再调用 super 方法, 否则可能导致配置修改后, 定位先于修改执行.
 */
- (void)i18nDidChange NS_REQUIRES_SUPER;

#pragma mark - 其他
/** 拉拽的百分比(交给子类重写) */
@property (assign, nonatomic) CGFloat pullingPercent;
/** 根据拖拽比例自动切换透明度 */
@property (assign, nonatomic, getter=isAutoChangeAlpha) BOOL autoChangeAlpha CYLRefreshDeprecated("请使用automaticallyChangeAlpha属性");
/** 根据拖拽比例自动切换透明度 */
@property (assign, nonatomic, getter=isAutomaticallyChangeAlpha) BOOL automaticallyChangeAlpha;
@end

@interface UILabel(CYLRefresh)
+ (instancetype)cyl_label;
- (CGFloat)cyl_textWidth;
@end

@interface CYLRefreshComponent (ChainingGrammar)

#pragma mark - <<< 为 Swift 扩展链式语法 >>> -
/// 自动变化透明度
- (instancetype)cyl_autoChangeTransparency:(BOOL)isAutoChange;
/// 刷新开始后立即调用的回调
- (instancetype)cyl_afterBeginningAction:(CYLRefreshComponentAction)action;
/// 刷新动画开始后立即调用的回调
- (instancetype)cyl_endingAnimationBeginningAction:(CYLRefreshComponentAction)action;
/// 刷新结束后立即调用的回调
- (instancetype)cyl_afterEndingAction:(CYLRefreshComponentAction)action;


/// 需要子类必须实现
/// @param scrollView 赋值给的 ScrollView 的 Header/Footer/Trailer
- (instancetype)cyl_linkTo:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
