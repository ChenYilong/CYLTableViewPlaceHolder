//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshComponent.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshComponent.h"
#import "CYLRefreshConst.h"
#import "CYLRefreshConfig.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"
#import "UIScrollView+CYLRefresh.h"
#import "NSBundle+CYLRefresh.h"
#import "CYLRefreshIconView.h"
#import "CYLPlaceholderView.h"

@interface CYLRefreshComponent() {
    /// [EN] The icon behind `cyl_iconView`, created on first use. [CN] `cyl_iconView` 的存储，首次使用时创建。
    CYLRefreshIconView *_iconView;
}
@property (strong, nonatomic) UIPanGestureRecognizer *pan;
@property (weak, nonatomic) UIScrollView *observedScrollView;
@end

@implementation CYLRefreshComponent

#pragma mark - Icon animation (plumbing for CYLRefreshIconAnimating)

- (CYLRefreshIconView *)cyl_iconView
{
    if (!_iconView) {
        CYLRefreshIconView *iconView = [[CYLRefreshIconView alloc] initWithFrame:CGRectZero];
        [iconView updateForState:self.state];
        [self addSubview:iconView];
        _iconView = iconView;
    }
    return _iconView;
}

- (BOOL)cyl_usesIconView
{
    return _iconView.hasAnimations;
}

- (void)cyl_setIconAnimationAttributes:(NSDictionary<NSString *, id> *)attributes forState:(CYLRefreshState)state
{
    if (!attributes && !_iconView) return;
    [self.cyl_iconView setAnimationAttributes:attributes forState:state];
    [self setNeedsLayout];
}

/// [EN] For subclasses: places the icon at `center` with its size and hides the views it replaces.
/// [CN] 供子类调用：把图标以其尺寸放在 `center`，并隐藏它所替换的视图。
- (void)cyl_placeIconViewAtCenter:(CGPoint)center visible:(BOOL)visible replacingViews:(NSArray<UIView *> *)views
{
    if (!self.cyl_usesIconView) return;
    CGSize size = self.cyl_iconView.iconSize;
    self.cyl_iconView.bounds = CGRectMake(0, 0, size.width, size.height);
    self.cyl_iconView.center = center;
    [self cyl_updateIconViewVisible:visible replacingViews:views];
}

- (void)cyl_updateIconViewVisible:(BOOL)visible replacingViews:(NSArray<UIView *> *)views
{
    if (!self.cyl_usesIconView) return;
    self.cyl_iconView.hidden = !visible;
    for (UIView *view in views) {
        if ([view isKindOfClass:UIActivityIndicatorView.class]) [(UIActivityIndicatorView *)view stopAnimating];
        view.hidden = YES;
    }
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 准备工作
        [self prepare];

        // 默认是普通状态
        self.state = CYLRefreshStateIdle;
        self.fastAnimationDuration = 0.25;
        self.slowAnimationDuration = 0.4;
    }
    return self;
}

- (void)prepare
{
    // 基本属性
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews
{
    [self placeSubviews];

    [super layoutSubviews];

    cyl_cguard([self.scrollView isKindOfClass:UICollectionView.class]) else { return; }

    UICollectionView *collectionView = (UICollectionView *)self.scrollView;
    cyl_cguard(collectionView.collectionViewLayout.flipsHorizontallyInOppositeLayoutDirection) else { return; }

    CGAffineTransform flipTransform = CGAffineTransformMakeScale(-1, 1);
    for (UIView *view in self.flipsHorizontallyInOppositeLayoutDirectionViews) {
        view.transform = flipTransform;
    }
    for (UIView *view in self.additionalFlipsViews) {
        view.transform = flipTransform;
    }
}

- (void)placeSubviews{}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];

    // 旧的父控件移除监听
    [self removeObservers];
    _scrollView = nil;

    if ([newSuperview isKindOfClass:[UIScrollView class]]) { // 新的父控件
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;

        // 设置宽度
        self.cyl_w = _scrollView.cyl_w;
        // 设置位置
        self.cyl_x = -_scrollView.cyl_insetL;

        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        // 记录UIScrollView最开始的contentInset
        _scrollViewOriginalInset = _scrollView.cyl_inset;

        // 添加监听
        [self addObservers];
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];

    if (!self.window || self.state != CYLRefreshStateWillRefresh) return;

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self.window || self.state != CYLRefreshStateWillRefresh) return;
        [self layoutIfNeeded];
        if (self.window && self.state == CYLRefreshStateWillRefresh) {
            self.state = CYLRefreshStateRefreshing;
        }
    });
}

#pragma mark - KVO监听
- (void)addObservers
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:CYLRefreshKeyPathContentOffset options:options context:nil];
    [self.scrollView addObserver:self forKeyPath:CYLRefreshKeyPathContentSize options:options context:nil];
    self.observedScrollView = self.scrollView;
    self.pan = self.scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:CYLRefreshKeyPathPanState options:options context:nil];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(i18nDidChange) name:CYLRefreshDidChangeLanguageNotification object:CYLRefreshConfig.defaultConfig];
}

- (void)removeObservers
{
    [self.observedScrollView removeObserver:self forKeyPath:CYLRefreshKeyPathContentOffset];
    [self.observedScrollView removeObserver:self forKeyPath:CYLRefreshKeyPathContentSize];
    self.observedScrollView = nil;
    [self.pan removeObserver:self forKeyPath:CYLRefreshKeyPathPanState];
    self.pan = nil;
    [NSNotificationCenter.defaultCenter removeObserver:self name:CYLRefreshDidChangeLanguageNotification object:CYLRefreshConfig.defaultConfig];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;

    // 这个就算看不见也需要处理
    if ([keyPath isEqualToString:CYLRefreshKeyPathContentSize]) {
        [self scrollViewContentSizeDidChange:change];
    }

    // 看不见
    if (self.hidden) return;
    if ([keyPath isEqualToString:CYLRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    } else if ([keyPath isEqualToString:CYLRefreshKeyPathPanState]) {
        [self scrollViewPanStateDidChange:change];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{}
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{}
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{}

- (void)i18nDidChange {
    [self placeSubviews];
}

#pragma mark - 公共方法
#pragma mark 设置回调对象和回调方法
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    self.refreshingTarget = target;
    self.refreshingAction = action;
}

- (void)setState:(CYLRefreshState)state
{
    _state = state;
    // [EN] The icon follows every state change of every subclass (CYLRefreshCheckState calls super).
    // [CN] 图标随所有子类的每次状态变化更新（CYLRefreshCheckState 会调用 super）。
    [_iconView updateForState:state];

    // 加入主队列的目的是等setState:方法调用完毕、设置完文字后再去布局子控件
    CYLRefreshDispatchAsyncOnMainQueue([self setNeedsLayout];)
}

#pragma mark 与其他刷新控件互斥
- (BOOL)cyl_otherComponentIsRefreshing
{
    UIScrollView *scrollView = self.scrollView;
    NSMutableArray<CYLRefreshComponent *> *others = [NSMutableArray array];
    if (scrollView.cyl_header) [others addObject:scrollView.cyl_header];
    if (scrollView.cyl_footer) [others addObject:scrollView.cyl_footer];
    if (scrollView.cyl_trailer) [others addObject:scrollView.cyl_trailer];
    for (CYLRefreshComponent *other in others) {
        if (other != self && other.isRefreshing) return YES;
    }
    return NO;
}

/// Returns YES, after dropping the pull and telling the caller, when this start must wait for another component.
- (BOOL)cyl_holdsBackStartForOtherRefresh
{
    if (!self.exclusiveWithOtherRefresh || self.isRefreshing || ![self cyl_otherComponentIsRefreshing]) return NO;
    if (self.state == CYLRefreshStatePulling) {
        self.state = CYLRefreshStateIdle;
    }
    if (self.blockedByOtherRefreshBlock) {
        self.blockedByOtherRefreshBlock();
    }
    return YES;
}

#pragma mark 进入刷新状态
- (void)beginRefreshing
{
    if ([self cyl_holdsBackStartForOtherRefresh]) return;
    [UIView animateWithDuration:self.fastAnimationDuration animations:^{
        self.alpha = 1.0;
    }];
    self.pullingPercent = 1.0;
    // 只要正在刷新，就完全显示
    if (self.window) {
        self.state = CYLRefreshStateRefreshing;
    } else {
        // 预防正在刷新中时，调用本方法使得header inset回置失败
        if (self.state != CYLRefreshStateRefreshing) {
            self.state = CYLRefreshStateWillRefresh;
        }
    }
}

- (void)beginRefreshingWithCompletionBlock:(void (^)(void))completionBlock
{
    self.beginRefreshingCompletionBlock = completionBlock;

    [self beginRefreshing];
}

#pragma mark 结束刷新状态
- (void)endRefreshing
{
    if (NSThread.isMainThread) {
        self.state = CYLRefreshStateIdle;
    } else {
        CYLRefreshDispatchAsyncOnMainQueue(self.state = CYLRefreshStateIdle;)
    }
}

- (void)endRefreshingWithCompletionBlock:(void (^)(void))completionBlock
{
    self.endRefreshingCompletionBlock = completionBlock;

    [self endRefreshing];
}

#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
    return self.state == CYLRefreshStateRefreshing || self.state == CYLRefreshStateWillRefresh;
}

#pragma mark 自动切换透明度
- (void)setAutoChangeAlpha:(BOOL)autoChangeAlpha
{
    self.automaticallyChangeAlpha = autoChangeAlpha;
}

- (BOOL)isAutoChangeAlpha
{
    return self.isAutomaticallyChangeAlpha;
}

- (void)setAutomaticallyChangeAlpha:(BOOL)automaticallyChangeAlpha
{
    _automaticallyChangeAlpha = automaticallyChangeAlpha;

    if (self.isRefreshing) return;

    if (automaticallyChangeAlpha) {
        self.alpha = self.pullingPercent;
    } else {
        self.alpha = 1.0;
    }
}

#pragma mark 根据拖拽进度设置透明度
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    _pullingPercent = pullingPercent;
    [_iconView updateForPullingPercent:pullingPercent];

    if (self.isRefreshing) return;

    if (self.isAutomaticallyChangeAlpha) {
        self.alpha = pullingPercent;
    }
}

#pragma mark - 内部方法
- (void)executeRefreshingCallback
{
    if (self.refreshingBlock) {
        self.refreshingBlock();
    }
    if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
        CYLRefreshMsgSend(CYLRefreshMsgTarget(self.refreshingTarget), self.refreshingAction, self);
    }
    if (self.beginRefreshingCompletionBlock) {
        self.beginRefreshingCompletionBlock();
    }
}

#pragma mark - 刷新动画时间控制
- (instancetype)setAnimationDisabled {
    self.fastAnimationDuration = 0;
    self.slowAnimationDuration = 0;

    return self;
}

#pragma mark - <<< Deprecation compatible function >>> -
- (void)setEndRefreshingAnimateCompletionBlock:(CYLRefreshComponentEndRefreshingCompletionBlock)endRefreshingAnimateCompletionBlock {
    _endRefreshingAnimationBeginAction = endRefreshingAnimateCompletionBlock;
}
@end

@implementation UILabel(CYLRefresh)
+ (instancetype)cyl_label
{
    UILabel *label = [[self alloc] init];
    label.font = CYLRefreshLabelFont;
    label.textColor = CYLRefreshLabelTextColor;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (CGFloat)cyl_textWidth {
    CGFloat stringWidth = 0;
    CGSize size = CGSizeMake(MAXFLOAT, MAXFLOAT);

    if (self.attributedText) {
        if (self.attributedText.length == 0) { return 0; }
        stringWidth = [self.attributedText boundingRectWithSize:size
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil].size.width;
    } else {
        if (self.text.length == 0) { return 0; }
        NSAssert(self.font != nil, @"请检查 cyl_label's `font` 是否设置正确");
        stringWidth = [self.text boundingRectWithSize:size
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:self.font}
                                              context:nil].size.width;
    }
    return stringWidth;
}
@end


#pragma mark - <<< 为 Swift 扩展链式语法 >>> -
@implementation CYLRefreshComponent (ChainingGrammar)

- (instancetype)cyl_autoChangeTransparency:(BOOL)isAutoChange {
    self.automaticallyChangeAlpha = isAutoChange;
    return self;
}
- (instancetype)cyl_afterBeginningAction:(CYLRefreshComponentAction)action {
    self.beginRefreshingCompletionBlock = action;
    return self;
}
- (instancetype)cyl_endingAnimationBeginningAction:(CYLRefreshComponentAction)action {
    self.endRefreshingAnimationBeginAction = action;
    return self;
}
- (instancetype)cyl_afterEndingAction:(CYLRefreshComponentAction)action {
    self.endRefreshingCompletionBlock = action;
    return self;
}

- (instancetype)cyl_linkTo:(UIScrollView *)scrollView {
    return self;
}

@end
