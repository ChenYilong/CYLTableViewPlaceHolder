//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshComponent.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshComponent.h"
// [EN] The generated Swift interface of CYLPlaceholderView (Swift since 2026-11-19). [CN] CYLPlaceholderView 的 Swift 接口。
#import "CYLTableViewPlaceHolder.h"
#import "CYLRefreshHeader.h"
#import "CYLRefreshFooter.h"
#import "CYLRefreshTrailer.h"
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
/// [EN] Target-actions added with -addTarget:action:. [CN] -addTarget:action: 添加的 target-action。
@property (strong, nonatomic) NSMutableArray<NSArray *> *cyl_targetActions;
/// [EN] YES while the control holds after the refresh ends (finishDuration). [CN] 刷新结束后停留期间为 YES。
@property (assign, nonatomic) BOOL cyl_finishing;
/// [EN] The phase last reported to -phaseDidChangeFrom:to:. [CN] 上次通知 -phaseDidChangeFrom:to: 的阶段。
@property (assign, nonatomic) CYLRefreshPhase cyl_reportedPhase;
/// [EN] Observers added with -addPhaseObserver:, by token. [CN] -addPhaseObserver: 添加的观察者，按标识保存。
@property (strong, nonatomic) NSMutableDictionary<NSUUID *, id> *cyl_phaseObservers;
/// [EN] Observers added with -addScrollObserver:, by token. [CN] -addScrollObserver: 添加的观察者，按标识保存。
@property (strong, nonatomic) NSMutableDictionary<NSUUID *, id> *cyl_scrollObservers;
/// [EN] YES while -beginRefreshingAnimationOnly holds the callbacks back. [CN] -beginRefreshingAnimationOnly 不调用回调期间为 YES。
@property (assign, nonatomic) BOOL cyl_skipsCallbacks;
/// [EN] YES once CYLRefreshConfig.defaultInitializer ran for this control. [CN] 已为本控件运行 defaultInitializer 后为 YES。
@property (assign, nonatomic) BOOL cyl_initialized;
/// [EN] The content offset when the current drag began (dragRate). [CN] 当前拖动开始时的内容偏移（dragRate）。
@property (assign, nonatomic) CGFloat cyl_dragStartOffsetY;
/// [EN] YES while this control turned the scroll view's touches off. [CN] 本控件关闭了滚动视图的触摸期间为 YES。
@property (assign, nonatomic) BOOL cyl_disabledContent;
@property (assign, nonatomic, readwrite, getter=isAutoRefresh) BOOL autoRefresh;
/// [EN] The empty mask that hides the control (`autoHideRefresh`). [CN] 隐藏控件（`autoHideRefresh`）的空遮罩。
@property (strong, nonatomic) CALayer *cyl_autoHideMask;
/// [EN] The text of each state (CYLRefreshStateTitles). [CN] 各状态的文字（CYLRefreshStateTitles）。
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSString *> *cyl_stateTitleTable;
/// [EN] The image sequence of each state (`-cyl_setAnimationImages:duration:forState:`). [CN] 各状态的图片序列。
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<UIImage *> *> *cyl_animationImageTable;
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
- (void)cyl_placeIconViewWithTitle:(NSString *)title labels:(NSArray<UILabel *> *)labels visible:(BOOL)visible
                    replacingViews:(NSArray<UIView *> *)views
{
    if (!self.cyl_usesIconView) return;
    CYLRefreshIconView *iconView = self.cyl_iconView;
    UILabel *font = labels.firstObject;
    iconView.titleFont = font.font;
    iconView.titleColor = font.textColor;
    iconView.title = visible ? title : nil;
    // [EN] The labels' text is inside the icon's CYLPlaceholderView: fade them out (keeping `hidden`, the caller's
    //      setting) while it shows, and back when it does not.
    // [CN] 文字已在图标的 CYLPlaceholderView 中：显示时淡出这些文字（保留调用方设置的 `hidden`），不显示时恢复。
    for (UILabel *label in labels) {
        label.alpha = visible ? 0 : 1;
        label.accessibilityElementsHidden = visible;
    }
    // [EN] VoiceOver reads the text from the one view that shows it. [CN] VoiceOver 从显示文字的那个视图读取文字。
    BOOL speaks = visible && title.length > 0;
    iconView.accessibilityElementsHidden = !speaks;
    iconView.isAccessibilityElement = speaks;
    iconView.accessibilityLabel = speaks ? title : nil;
    iconView.accessibilityTraits = speaks ? UIAccessibilityTraitUpdatesFrequently : UIAccessibilityTraitNone;
    CGSize size = iconView.fittingSize;
    iconView.bounds = CGRectMake(0, 0, MIN(size.width, CGRectGetWidth(self.bounds)), size.height);
    iconView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self cyl_updateIconViewVisible:visible replacingViews:views];
}

- (void)cyl_setIconImages:(NSArray<UIImage *> *)images duration:(NSTimeInterval)duration forState:(CYLRefreshState)state
{
    UIImage *first = images.firstObject;
    if (![first isKindOfClass:UIImage.class]) return;
    if (state != CYLRefreshStateIdle && ![self.cyl_iconView animationAttributesForState:CYLRefreshStateIdle]) {
        [self.cyl_iconView setAnimationAttributes:@{CYLPlaceholderItemImage: first} forState:CYLRefreshStateIdle];
    }
    // [EN] The idle state shows one frame (chosen by the pull); the other states hand the sequence to CYLPlaceholderView,
    //      which plays every kind of animation (and keeps the first frame with Reduce Motion).
    // [CN] 空闲状态只显示一帧（由下拉进度选择）；其他状态把图片序列交给 CYLPlaceholderView，它负责播放所有类型的动效（“减弱动态效果”时保留第一帧）。
    NSDictionary<NSString *, id> *attributes = state == CYLRefreshStateIdle || images.count == 1
        ? @{CYLPlaceholderItemImage: first}
        : @{CYLPlaceholderItemImages: images, CYLPlaceholderItemAnimationDuration: @(duration > 0 ? duration : images.count * 0.1)};
    [self cyl_setIconAnimationAttributes:attributes forState:state];
}

- (void)cyl_setAnimationImages:(NSArray<UIImage *> *)images duration:(NSTimeInterval)duration forState:(CYLRefreshState)state
{
    if (images == nil) return;
    if (!self.cyl_animationImageTable) self.cyl_animationImageTable = [NSMutableDictionary dictionary];
    self.cyl_animationImageTable[@(state)] = images;
    // [EN] The control grows to the tallest image, as in MJRefresh. [CN] 控件高度随最高的图片增大，与 MJRefresh 相同。
    UIImage *image = images.firstObject;
    if ([image isKindOfClass:UIImage.class] && image.size.height > self.cyl_h) {
        self.cyl_h = image.size.height;
    }
    [self cyl_setIconImages:images duration:duration forState:state];
}

- (NSArray<UIImage *> *)cyl_animationImagesForState:(CYLRefreshState)state
{
    return self.cyl_animationImageTable[@(state)];
}

- (void)cyl_showIdleAnimationFrame
{
    [self cyl_showIconImageFrameOf:[self cyl_animationImagesForState:CYLRefreshStateIdle] pullingPercent:self.pullingPercent];
}

- (void)cyl_setIconAnimationFilePath:(NSString *)filePath size:(CGSize)size forState:(CYLRefreshState)state
{
    NSDictionary<NSString *, id> *attributes = [CYLRefreshIconView attributesForAnimationFilePath:filePath size:size];
    if (attributes) [self cyl_setIconAnimationAttributes:attributes forState:state];
}

- (void)cyl_setBundledIconAnimation:(NSString *)fileName size:(CGSize)size forState:(CYLRefreshState)state
{
    NSDictionary<NSString *, id> *attributes = [CYLRefreshIconView attributesForBundledAnimation:fileName size:size];
    if (attributes) [self cyl_setIconAnimationAttributes:attributes forState:state];
}

#pragma mark - State titles (CYLRefreshStateTitles)

- (void)cyl_setStateTitle:(NSString *)title forState:(CYLRefreshState)state
{
    if (title == nil) return;
    if (!self.cyl_stateTitleTable) self.cyl_stateTitleTable = [NSMutableDictionary dictionary];
    self.cyl_stateTitleTable[@(state)] = title;
}

- (NSString *)cyl_stateTitleForState:(CYLRefreshState)state
{
    return self.cyl_stateTitleTable[@(state)];
}

- (void)cyl_showIconImageFrameOf:(NSArray<UIImage *> *)images pullingPercent:(CGFloat)pullingPercent
{
    if (self.state != CYLRefreshStateIdle || images.count == 0 || !_iconView) return;
    CGFloat percent = isfinite(pullingPercent) ? MAX(0, pullingPercent) : 0;
    NSUInteger index = MIN((NSUInteger)(images.count * percent), images.count - 1);
    // [EN] The frame goes straight into CYLPlaceholderView's own image view: rebuilding the view from attributes on every
    //      pull step would restart it many times a second. [CN] 帧直接写入 CYLPlaceholderView 自己的图片视图：每次下拉都用属性
    //      重建视图，每秒会重建很多次。
    _iconView.placeholderView.imageView.image = images[index];
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // [EN] On where the bars are transparent by default (set before prepare, which subclasses lay out in).
        // [CN] 在栏默认透明的系统上开启（在 prepare 之前设置，子类会在 prepare 中布局）。
        if (@available(iOS 26.0, *)) {
            _autoHideRefresh = YES;
        }
        // 准备工作
        [self prepare];

        // 默认是普通状态
        self.state = CYLRefreshStateIdle;
        self.fastAnimationDuration = 0.25;
        self.slowAnimationDuration = 0.4;
        _triggerRate = 1;
        _refreshEnabled = YES;
        _cyl_reportedPhase = CYLRefreshPhaseIdle;
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
    [self cyl_applyThemeColors];

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
    if (_scrollView && newSuperview != _scrollView) [self willDetachFromScrollView:_scrollView];
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

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (_scrollView && self.superview == _scrollView) {
        // [EN] The app-wide setup runs once per control (CYLRefreshConfig.defaultInitializer).
        // [CN] 应用级设置每个控件只运行一次（CYLRefreshConfig.defaultInitializer）。
        if (!self.cyl_initialized && CYLRefreshConfig.defaultConfig.defaultInitializer) {
            self.cyl_initialized = YES;
            CYLRefreshConfig.defaultConfig.defaultInitializer(self);
        }
        [self didAttachToScrollView:_scrollView];
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
    [self.scrollView addObserver:self forKeyPath:CYLRefreshKeyPathContentInset options:options context:nil];
    self.observedScrollView = self.scrollView;
    self.pan = self.scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:CYLRefreshKeyPathPanState options:options context:nil];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(i18nDidChange) name:CYLRefreshDidChangeLanguageNotification object:CYLRefreshConfig.defaultConfig];
}

- (void)removeObservers
{
    [self.observedScrollView removeObserver:self forKeyPath:CYLRefreshKeyPathContentOffset];
    [self.observedScrollView removeObserver:self forKeyPath:CYLRefreshKeyPathContentSize];
    [self.observedScrollView removeObserver:self forKeyPath:CYLRefreshKeyPathContentInset];
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
    if ([keyPath isEqualToString:CYLRefreshKeyPathContentInset]) {
        [self scrollViewContentInsetDidChange:change];
        return;
    }

    // 看不见
    if (self.hidden && !self.notifiesWhenHidden) return;
    if ([keyPath isEqualToString:CYLRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
        [self didScrollWithOffset:self.dragOffset percent:self.pullingPercent dragging:self.scrollView.isDragging];
        for (void (^observer)(CYLRefreshComponent *, CGFloat, CGFloat, BOOL) in self.cyl_scrollObservers.allValues) {
            observer(self, self.dragOffset, self.pullingPercent, self.scrollView.isDragging);
        }
        [self cyl_followPull];
        [self cyl_reportPhase];
    } else if ([keyPath isEqualToString:CYLRefreshKeyPathPanState]) {
        if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            self.cyl_dragStartOffsetY = self.scrollView.contentOffset.y;
        }
        [self scrollViewPanStateDidChange:change];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{}
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{}
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{}
- (void)scrollViewContentInsetDidChange:(NSDictionary *)change{}

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
    [self cyl_updateContentTouchesForState:state];
    if (state == CYLRefreshStateIdle || state == CYLRefreshStateNoMoreData) {
        if (self.autoRefresh) {
            self.autoRefresh = NO;
            [self autoRefreshDidChange:NO];
        }
        self.cyl_skipsCallbacks = NO;
    }
    // [EN] The icon follows every state change of every subclass (CYLRefreshCheckState calls super).
    // [CN] 图标随所有子类的每次状态变化更新（CYLRefreshCheckState 会调用 super）。
    [_iconView updateForState:state];
    [self cyl_reportPhase];

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
    // [EN] Started in code unless a pull armed the control or a scroll reached it. [CN] 除非由拉动触发或滚动到达，否则视为代码开始。
    UIScrollView *scrollView = self.scrollView;
    UIGestureRecognizerState pan = scrollView.panGestureRecognizer.state;
    BOOL byUser = self.state == CYLRefreshStatePulling || scrollView.isDragging || scrollView.isDecelerating ||
        pan == UIGestureRecognizerStateBegan || pan == UIGestureRecognizerStateChanged || pan == UIGestureRecognizerStateEnded;
    if (!byUser && !self.isRefreshing && !self.autoRefresh) {
        self.autoRefresh = YES;
        [self autoRefreshDidChange:YES];
    }
    [UIView animateWithDuration:self.fastAnimationDuration animations:^{
        self.alpha = 1.0;
    }];
    self.pullingPercent = 1.0;
    // 只要正在刷新，就完全显示
    if (self.window) {
        if (self.autoRefresh && !self.isRefreshing && [self openForAutoRefreshWithDuration:self.fastAnimationDuration]) {
            // [EN] autoOpen: the control animates itself, the inset snaps. [CN] autoOpen：控件自己做动画，inset 直接到位。
            NSTimeInterval saved = self.fastAnimationDuration;
            self.fastAnimationDuration = 0;
            self.state = CYLRefreshStateRefreshing;
            self.fastAnimationDuration = saved;
            return;
        }
        self.state = CYLRefreshStateRefreshing;
    } else {
        // 预防正在刷新中时，调用本方法使得header inset回置失败
        if (self.state != CYLRefreshStateRefreshing) {
            self.state = CYLRefreshStateWillRefresh;
        }
    }
}

- (void)beginRefreshingWithDuration:(NSTimeInterval)duration overOffset:(CGFloat)overOffset force:(BOOL)force
{
    NSTimeInterval savedDuration = self.fastAnimationDuration;
    BOOL savedExclusive = self.exclusiveWithOtherRefresh;
    if (duration > 0) self.fastAnimationDuration = duration;
    if (force) self.exclusiveWithOtherRefresh = NO;
    [self beginRefreshing];
    self.exclusiveWithOtherRefresh = savedExclusive;
    NSTimeInterval move = self.fastAnimationDuration;
    self.fastAnimationDuration = savedDuration;
    if (overOffset <= 0 || !self.scrollView || !self.window) return;
    // [EN] Overshoot past the refreshing position and spring back, as a real pull ends. [CN] 越过刷新位置再回弹，像真实拉动的结尾。
    BOOL down = [self isKindOfClass:CYLRefreshHeader.class];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(move * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        UIScrollView *scrollView = self.scrollView;
        if (!scrollView || !self.isRefreshing) return;
        CGPoint rest = scrollView.contentOffset;
        CGPoint over = CGPointMake(rest.x, rest.y + (down ? -overOffset : overOffset));
        [UIView animateWithDuration:0.15 animations:^{
            scrollView.contentOffset = over;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0
                             animations:^{ scrollView.contentOffset = rest; } completion:nil];
        }];
    });
}

- (void)beginRefreshingWithCompletionBlock:(void (^)(void))completionBlock
{
    self.beginRefreshingCompletionBlock = completionBlock;

    [self beginRefreshing];
}

#pragma mark 结束刷新状态
- (void)endRefreshing
{
    [self endRefreshingWithSuccess:YES];
}

- (void)endRefreshingWithSuccess:(BOOL)success
{
    if (!NSThread.isMainThread) {
        CYLRefreshDispatchAsyncOnMainQueue([self endRefreshingWithSuccess:success];)
        return;
    }
    if (self.cyl_finishing) return;
    if (!self.isRefreshing) {
        self.state = CYLRefreshStateIdle;
        return;
    }
    _lastRefreshSucceeded = success;
    [self refreshDidFinishWithSuccess:success];
    NSTimeInterval duration = [self finishingDurationWithSuccess:success];
    if (duration <= 0 || !isfinite(duration)) {
        self.state = CYLRefreshStateIdle;
        return;
    }
    // [EN] Hold open for `duration`, showing the result, then retract. [CN] 停留 `duration` 显示结果，然后收回。
    self.cyl_finishing = YES;
    [self cyl_reportPhase];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        self.cyl_finishing = NO;
        if (self.isRefreshing) self.state = CYLRefreshStateIdle;
        [self cyl_reportPhase];
    });
}

- (void)refreshDidFinishWithSuccess:(BOOL)success {}

- (NSTimeInterval)finishingDurationWithSuccess:(BOOL)success
{
    return self.finishDuration;
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
    [self cyl_reportPhase];

    if (self.isRefreshing) return;

    if (self.isAutomaticallyChangeAlpha) {
        self.alpha = pullingPercent;
    }
}

#pragma mark - 内部方法
- (void)executeRefreshingCallback
{
    if (self.cyl_skipsCallbacks) return;
    if (self.refreshingBlock) {
        self.refreshingBlock();
    }
    if (self.refreshingHandler) {
        self.refreshingHandler(self);
    }
    for (NSArray *pair in [self.cyl_targetActions copy]) {
        id target = [pair.firstObject nonretainedObjectValue];
        SEL action = NSSelectorFromString(pair.lastObject);
        if ([target respondsToSelector:action]) CYLRefreshMsgSend(CYLRefreshMsgTarget(target), action, self);
    }
    if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
        CYLRefreshMsgSend(CYLRefreshMsgTarget(self.refreshingTarget), self.refreshingAction, self);
    }
    if (self.beginRefreshingCompletionBlock) {
        self.beginRefreshingCompletionBlock();
    }
}

#pragma mark - SmartRefreshControl-style API

+ (instancetype)attach:(UIScrollView *)scrollView
{
    CYLRefreshComponent *component = [[self alloc] init];
    [component attach:scrollView];
    return component;
}

+ (instancetype)attach:(UIScrollView *)scrollView target:(id)target action:(SEL)action
{
    CYLRefreshComponent *component = [self attach:scrollView];
    [component addTarget:target action:action];
    return component;
}

- (void)attach:(UIScrollView *)scrollView
{
    if ([self isKindOfClass:CYLRefreshHeader.class]) {
        scrollView.cyl_header = (CYLRefreshHeader *)self;
    } else if ([self isKindOfClass:CYLRefreshFooter.class]) {
        scrollView.cyl_footer = (CYLRefreshFooter *)self;
    } else if ([self isKindOfClass:CYLRefreshTrailer.class]) {
        scrollView.cyl_trailer = (CYLRefreshTrailer *)self;
    } else {
        [scrollView addSubview:self];
    }
}

/// [EN] Private (used by -[UIScrollView cyl_beginRefreshingWithStartHeader:]): whether any callback is set, the
///      target-actions of -addTarget:action: included. [CN] 私有（供 -[UIScrollView cyl_beginRefreshingWithStartHeader:] 使用）：
///      是否设置了任何回调，包括 -addTarget:action: 的 target-action。
- (BOOL)cyl_hasCallbacks
{
    return self.refreshingBlock || self.refreshingHandler || self.refreshingTarget || self.cyl_targetActions.count > 0;
}

/// [EN] Private: adds `other`'s target-actions of -addTarget:action: to this component. [CN] 私有：把 `other` 通过
///      -addTarget:action: 添加的 target-action 加到本控件。
- (void)cyl_copyTargetActionsFrom:(CYLRefreshComponent *)other
{
    for (NSArray *pair in other.cyl_targetActions) {
        id target = [pair.firstObject nonretainedObjectValue];
        if (target) [self addTarget:target action:NSSelectorFromString(pair.lastObject)];
    }
}

- (void)addTarget:(id)target action:(SEL)action
{
    if (!target || !action) return;
    if (!self.cyl_targetActions) self.cyl_targetActions = [NSMutableArray array];
    [self.cyl_targetActions addObject:@[[NSValue valueWithNonretainedObject:target], NSStringFromSelector(action)]];
}

- (void)removeTarget:(id)target action:(SEL)action
{
    NSString *name = action ? NSStringFromSelector(action) : nil;
    NSIndexSet *matches = [self.cyl_targetActions indexesOfObjectsPassingTest:^BOOL(NSArray *pair, NSUInteger idx, BOOL *stop) {
        return [pair.firstObject nonretainedObjectValue] == target && (!name || [pair.lastObject isEqualToString:name]);
    }];
    [self.cyl_targetActions removeObjectsAtIndexes:matches];
}

- (BOOL)isAttached
{
    return self.scrollView != nil;
}

- (void)setTriggerRate:(CGFloat)triggerRate
{
    _triggerRate = (isfinite(triggerRate) && triggerRate > 0) ? triggerRate : 1;
}

- (BOOL)isExpanded
{
    return self.isRefreshing;
}

- (CGFloat)expandHeight
{
    return self.cyl_h;
}

- (CGFloat)dragOffset
{
    return self.pullingPercent * self.expandHeight * self.triggerRate;
}

- (CYLRefreshPhase)phase
{
    if (self.state == CYLRefreshStateNoMoreData) return CYLRefreshPhaseNoMoreData;
    if (self.cyl_finishing) return CYLRefreshPhaseFinishing;
    switch (self.state) {
        case CYLRefreshStateRefreshing: return CYLRefreshPhaseRefreshing;
        case CYLRefreshStateWillRefresh: return CYLRefreshPhaseWillRefresh;
        case CYLRefreshStatePulling:
            return self.scrollView.isDragging ? CYLRefreshPhaseReleaseToRefresh : CYLRefreshPhaseReleasing;
        default:
            return (self.pullingPercent > 0 && self.scrollView.isDragging) ? CYLRefreshPhasePullToRefresh : CYLRefreshPhaseIdle;
    }
}

- (BOOL)isInAnyPhase:(NSArray<NSNumber *> *)phases
{
    return [phases containsObject:@(self.phase)];
}

- (BOOL)isInPhases:(CYLRefreshPhase)phase, ...
{
    if (phase == 0) return NO;
    CYLRefreshPhase current = self.phase;
    if (phase == current) return YES;
    // [EN] Enum arguments are promoted to int in a variadic call; the list ends with 0.
    // [CN] 可变参数中的枚举会提升为 int；列表以 0 结尾。
    va_list args;
    va_start(args, phase);
    BOOL found = NO;
    for (int next = va_arg(args, int); next != 0; next = va_arg(args, int)) {
        if (next == (int)current) { found = YES; break; }
    }
    va_end(args);
    return found;
}

- (void)cyl_reportPhase
{
    CYLRefreshPhase phase = self.phase;
    if (phase == self.cyl_reportedPhase) return;
    CYLRefreshPhase old = self.cyl_reportedPhase;
    self.cyl_reportedPhase = phase;
    if (self.hapticFeedback && phase == CYLRefreshPhaseReleaseToRefresh) {
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [generator impactOccurred];
    }
    [self phaseDidChangeFrom:old to:phase];
    for (void (^observer)(CYLRefreshComponent *, CYLRefreshPhase, CYLRefreshPhase) in self.cyl_phaseObservers.allValues) {
        observer(self, old, phase);
    }
}

- (id)addPhaseObserver:(void (^)(__kindof CYLRefreshComponent *, CYLRefreshPhase, CYLRefreshPhase))observer
{
    NSUUID *token = [NSUUID UUID];
    if (!observer) return token;
    if (!self.cyl_phaseObservers) self.cyl_phaseObservers = [NSMutableDictionary dictionary];
    self.cyl_phaseObservers[token] = [observer copy];
    return token;
}

- (void)removePhaseObserver:(id)token
{
    if ([token isKindOfClass:NSUUID.class]) [self.cyl_phaseObservers removeObjectForKey:token];
}

#pragma mark - SmartRefreshLayout parity: starting and ending in code, observing, deciding

- (void)beginRefreshingAfterDelay:(NSTimeInterval)delay
{
    if (delay <= 0) {
        [self beginRefreshing];
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf beginRefreshing];
    });
}

- (void)beginRefreshingAnimationOnly
{
    if (self.isRefreshing) return;
    self.cyl_skipsCallbacks = YES;
    [self beginRefreshing];
    // [EN] Held back by another refresh: nothing started, so the next start calls back again.
    // [CN] 被其他刷新挡住时没有开始，下次开始仍调用回调。
    if (!self.isRefreshing) self.cyl_skipsCallbacks = NO;
}

- (void)endRefreshingAfterDelay:(NSTimeInterval)delay success:(BOOL)success
{
    if (delay <= 0) {
        [self endRefreshingWithSuccess:success];
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf endRefreshingWithSuccess:success];
    });
}

- (id)addScrollObserver:(void (^)(__kindof CYLRefreshComponent *, CGFloat, CGFloat, BOOL))observer
{
    NSUUID *token = [NSUUID UUID];
    if (!observer) return token;
    if (!self.cyl_scrollObservers) self.cyl_scrollObservers = [NSMutableDictionary dictionary];
    self.cyl_scrollObservers[token] = [observer copy];
    return token;
}

- (void)removeScrollObserver:(id)token
{
    if ([token isKindOfClass:NSUUID.class]) [self.cyl_scrollObservers removeObjectForKey:token];
}

- (BOOL)canTrigger
{
    return self.canTriggerBlock ? self.canTriggerBlock(self) : YES;
}

- (void)setDisablesContentWhileRefreshing:(BOOL)disablesContentWhileRefreshing
{
    _disablesContentWhileRefreshing = disablesContentWhileRefreshing;
    [self cyl_updateContentTouchesForState:self.state];
}

/// [EN] Turns the scroll view's touches off while refreshing (disablesContentWhileRefreshing) and back on after.
/// [CN] 刷新期间关闭滚动视图的触摸（disablesContentWhileRefreshing），结束后恢复。
- (void)cyl_updateContentTouchesForState:(CYLRefreshState)state
{
    BOOL busy = state == CYLRefreshStateRefreshing || state == CYLRefreshStateWillRefresh;
    UIScrollView *scrollView = self.scrollView;
    if (self.disablesContentWhileRefreshing && busy && !self.cyl_disabledContent && scrollView) {
        self.cyl_disabledContent = YES;
        scrollView.userInteractionEnabled = NO;
    } else if (self.cyl_disabledContent && (!busy || !self.disablesContentWhileRefreshing)) {
        self.cyl_disabledContent = NO;
        scrollView.userInteractionEnabled = YES;
    }
}

- (void)autoRefreshDidChange:(BOOL)autoRefresh {}

- (void)didDragHorizontallyWithOffset:(CGFloat)offset percent:(CGFloat)percent {}

- (BOOL)openForAutoRefreshWithDuration:(NSTimeInterval)duration
{
    return NO;
}

/// [EN] YES for controls at the bottom (footers); headers and trailers pull from the other side.
/// [CN] 位于底部的控件（尾部）为 YES；刷新头与尾随控件从另一侧拉开。
- (BOOL)cyl_pullsUp
{
    return [self isKindOfClass:CYLRefreshFooter.class];
}

/// [EN] On every move: the horizontal drag hook, the pinned view and the translation view.
/// [CN] 每次移动时：横向拖动钩子、固定视图与跟随视图。
- (void)cyl_followPull
{
    UIScrollView *scrollView = self.scrollView;
    // [EN] The distance pulled past the edge, from the geometry (pullingPercent is not reset once scrolled away).
    // [CN] 越过边缘的拉动距离，按几何位置计算（滚走后 pullingPercent 不会重置）。
    BOOL up = [self cyl_pullsUp];
    CGFloat pulled = up ?
        MAX(0, scrollView.cyl_offsetY + scrollView.cyl_h - MAX(scrollView.cyl_contentH, scrollView.cyl_h - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom) - self.scrollViewOriginalInset.bottom) :
        MAX(0, -(scrollView.cyl_offsetY + self.scrollViewOriginalInset.top));
    CGFloat sign = up ? 1 : -1;
    if (self.supportsHorizontalDrag && scrollView.isDragging && self.pullingPercent > 0) {
        CGFloat dx = [scrollView.panGestureRecognizer translationInView:scrollView].x;
        [self didDragHorizontallyWithOffset:dx percent:self.pullingPercent];
    }
    UIView *pinned = self.pinnedView;
    if (pinned) pinned.transform = CGAffineTransformMakeTranslation(0, sign * pulled);
    UIView *translation = self.translationView;
    if (translation) translation.transform = CGAffineTransformMakeTranslation(0, -sign * pulled);
}

/// [EN] dragRate: the pulled distance as the finger's distance times dragRate, from the offset where the drag began.
///      Returns the offset to use, or `offsetY` when dragRate is off or the control is not being pulled.
/// [CN] dragRate：拉开距离为手指移动距离乘以 dragRate，从拖动开始时的偏移算起。返回要使用的偏移；dragRate 关闭或未在拉动时返回 `offsetY`。
- (CGFloat)cyl_offsetForDragRate:(CGFloat)offsetY happenOffset:(CGFloat)happenOffsetY
{
    UIScrollView *scrollView = self.scrollView;
    if (self.dragRate <= 0 || self.dragRate >= 1 || !scrollView.isDragging) return offsetY;
    UIPanGestureRecognizer *pan = scrollView.panGestureRecognizer;
    CGFloat moved = [pan translationInView:scrollView].y;
    BOOL up = [self cyl_pullsUp];
    // [EN] Where the content would be with no rubber band; past the edge, scaled by dragRate.
    // [CN] 没有回弹时内容所在的位置；越过边缘的部分乘以 dragRate。
    CGFloat natural = self.cyl_dragStartOffsetY - moved;
    CGFloat over = up ? natural - happenOffsetY : happenOffsetY - natural;
    if (over <= 0) return offsetY;
    CGFloat target = up ? happenOffsetY + over * self.dragRate : happenOffsetY - over * self.dragRate;
    if (fabs(target - offsetY) > 0.5) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, target);
    }
    return target;
}

- (void)setColorAccent:(UIColor *)colorAccent
{
    _colorAccent = colorAccent;
    [self setNeedsLayout];
}

- (void)setColorPrimary:(UIColor *)colorPrimary
{
    _colorPrimary = colorPrimary;
    self.backgroundColor = colorPrimary ?: UIColor.clearColor;
}

/// [EN] Applies `colorAccent` to every label, image view and spinner inside the control.
/// [CN] 把 `colorAccent` 应用到控件内的所有文字、图片视图与菊花。
- (void)cyl_applyThemeColors
{
    UIColor *accent = self.colorAccent;
    if (!accent) return;
    NSMutableArray<UIView *> *views = [NSMutableArray arrayWithArray:self.subviews];
    while (views.count) {
        UIView *view = views.lastObject;
        [views removeLastObject];
        if ([view isKindOfClass:UILabel.class]) {
            ((UILabel *)view).textColor = accent;
        } else if ([view isKindOfClass:UIActivityIndicatorView.class]) {
            ((UIActivityIndicatorView *)view).color = accent;
        } else {
            view.tintColor = accent;
            [views addObjectsFromArray:view.subviews];
        }
    }
}

#pragma mark - Auto-hide

- (void)setAutoHideRefresh:(BOOL)autoHideRefresh
{
    _autoHideRefresh = autoHideRefresh;
    [self updateAutoHideVisibility];
}

- (BOOL)isReadyToAutoHide
{
    return NO;
}

- (void)updateAutoHideVisibility
{
    BOOL hide = self.autoHideRefresh && [self isReadyToAutoHide];
    BOOL hidden = self.cyl_autoHideMask && self.layer.mask == self.cyl_autoHideMask;
    if (hide == hidden) return;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (hide) {
        if (!self.cyl_autoHideMask) self.cyl_autoHideMask = [CALayer layer];
        self.layer.mask = self.cyl_autoHideMask;
    } else {
        self.layer.mask = nil;
    }
    [CATransaction commit];
    // [EN] What is not shown is not read either. [CN] 不显示的内容也不让 VoiceOver 读取。
    self.accessibilityElementsHidden = hide;
}

- (void)didAttachToScrollView:(UIScrollView *)scrollView {}
- (void)willDetachFromScrollView:(UIScrollView *)scrollView {}
- (void)didScrollWithOffset:(CGFloat)offset percent:(CGFloat)percent dragging:(BOOL)dragging {}
- (void)phaseDidChangeFrom:(CYLRefreshPhase)oldPhase to:(CYLRefreshPhase)phase {}

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
