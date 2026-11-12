//
//  CYLRefreshDrawnHeader.m
//  CYLRefresh
//
//  SmartRefreshControl's subclass API on top of CYLRefresh's phases. The status order and the hook timing follow
//  SmartRefreshControl's UIRefreshHeader (https://github.com/scwang90/SmartRefreshControl, MIT).
//

#import "CYLRefreshDrawnHeader.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"

@interface CYLRefreshDrawnHeader ()
@property (nonatomic, readwrite) CYLRefreshPhase status;
/// [EN] The offset last passed to the scroll hooks. [CN] 上次传给滚动钩子的偏移。
@property (nonatomic) CGFloat cyl_lastOffset;
/// [EN] YES after a style turned user interaction off: touches pass through. [CN] 样式关闭用户交互后为 YES：触摸穿透。
@property (nonatomic) BOOL cyl_passesTouches;
@end

@implementation CYLRefreshDrawnHeader

- (void)prepare
{
    [super prepare];
    _status = CYLRefreshPhaseIdle;
    _durationFast = 0.1;
    _durationNormal = 0.25;
    _cyl_lastOffset = -1;
    self.colorAccent = UIColor.darkGrayColor;
    [self setUpComponent];
}

- (void)setUpComponent {}

#pragma mark - Touches

/// [EN] Styles turn user interaction off so touches reach the list (SmartRefreshControl's Material, WaveSwipe), but
///      CYLRefresh, like MJRefresh, stops following the scroll view when it is off. Keep it on and let touches pass
///      through instead. [CN] 样式关闭用户交互是为了让触摸到达列表（SmartRefreshControl 的 Material、WaveSwipe），但 CYLRefresh 与
///      MJRefresh 一样，在交互关闭时停止跟随滚动视图。因此保持开启，改为让触摸穿透。
- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    self.cyl_passesTouches = !userInteractionEnabled;
    [super setUserInteractionEnabled:YES];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return self.cyl_passesTouches ? nil : [super hitTest:point withEvent:event];
}

#pragma mark - Colors

/// [EN] In SmartRefreshControl `colorPrimary` is a color the styles draw with, not the view's background: keep the
///      background clear, or a style's drawing (Material's spinner, WaveSwipe's wave) is covered by a solid rectangle.
/// [CN] SmartRefreshControl 中 `colorPrimary` 是样式绘制时使用的颜色，不是视图背景：保持背景透明，否则样式的绘制（Material 的圆圈、
///      WaveSwipe 的波浪）会被纯色矩形盖住。
- (void)setColorPrimary:(UIColor *)colorPrimary
{
    [super setColorPrimary:colorPrimary];
    self.backgroundColor = UIColor.clearColor;
}

#pragma mark - Size

- (CGFloat)width
{
    return self.cyl_w;
}

- (void)setWidth:(CGFloat)width
{
    self.cyl_w = width;
}

- (CGFloat)height
{
    return self.cyl_h;
}

- (void)setHeight:(CGFloat)height
{
    [self setExpandHeight:height];
}

- (CGFloat)dragOffset
{
    if (!self.scrollView) return 0;
    return MAX(0, -(self.scrollView.cyl_offsetY + self.scrollViewOriginalInset.top));
}

- (CGFloat)dragPercent
{
    return self.dragOffset / MAX(1, self.expandHeight * self.triggerRate);
}

- (BOOL)isSuccess
{
    return self.lastRefreshSucceeded;
}

#pragma mark - Status

- (void)setStatus:(CYLRefreshPhase)status
{
    CYLRefreshPhase old = _status;
    if (old == status) return;
    _status = status;
    if (self.scrollView) [self onStatus:old changed:status];
}

- (void)onStatus:(CYLRefreshPhase)oldStatus changed:(CYLRefreshPhase)status
{
    // [EN] As in SmartRefreshControl, the start hooks run on the next main-queue turn.
    // [CN] 与 SmartRefreshControl 相同，开始钩子在下一次主队列循环中执行。
    if (status == CYLRefreshPhaseReleasing) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self onStartAnimationWhenRealeasing]; });
    } else if (status == CYLRefreshPhaseRefreshing) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self onStartAnimationWhenRefreshing]; });
    }
}

- (void)phaseDidChangeFrom:(CYLRefreshPhase)oldPhase to:(CYLRefreshPhase)phase
{
    [super phaseDidChangeFrom:oldPhase to:phase];
    switch (phase) {
        case CYLRefreshPhaseRefreshing:
            // [EN] CYLRefresh may go straight to refreshing; SmartRefreshControl always passes through releasing.
            // [CN] CYLRefresh 可能直接进入刷新中；SmartRefreshControl 一定先经过释放中。
            if (self.status != CYLRefreshPhaseReleasing) self.status = CYLRefreshPhaseReleasing;
            self.status = CYLRefreshPhaseRefreshing;
            break;
        case CYLRefreshPhaseIdle:
            // [EN] After a refresh, stay in finish until the header has retracted. [CN] 刷新后保持结束状态，直到刷新头收回。
            if (self.status == CYLRefreshPhaseRefreshing) self.status = CYLRefreshPhaseFinishing;
            if (self.status != CYLRefreshPhaseFinishing || self.dragOffset <= 0.5) self.status = CYLRefreshPhaseIdle;
            break;
        default:
            self.status = phase;
            break;
    }
}

- (BOOL)inStatus:(CYLRefreshPhase)status, ...
{
    if (status == 0) return NO;
    if (status == self.status) return YES;
    va_list args;
    va_start(args, status);
    BOOL found = NO;
    for (int next = va_arg(args, int); next != 0; next = va_arg(args, int)) {
        if (next == (int)self.status) { found = YES; break; }
    }
    va_end(args);
    return found;
}

#pragma mark - Scrolling

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    CGFloat offset = self.dragOffset;
    if (self.status == CYLRefreshPhaseFinishing && self.state == CYLRefreshStateIdle && offset <= 0.5) {
        self.status = CYLRefreshPhaseIdle;
    }
    if (offset == self.cyl_lastOffset) return;
    self.cyl_lastOffset = offset;
    [self scrollView:self.scrollView didScroll:offset percent:self.dragPercent drag:self.scrollView.isDragging];
}

- (void)scrollView:(UIScrollView *)scrollView didScroll:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging
{
    [self onScrollingWithOffset:offset percent:percent drag:isDragging];
}

- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging {}
- (void)onStartAnimationWhenRealeasing {}
- (void)onStartAnimationWhenRefreshing {}
- (void)onRefreshFinished:(BOOL)success {}

- (CGFloat)onRefreshFinishing:(BOOL)success
{
    return self.finishDuration;
}

#pragma mark - Attaching

- (void)didAttachToScrollView:(UIScrollView *)scrollView
{
    [super didAttachToScrollView:scrollView];
    [self scrollView:scrollView attached:YES];
}

- (void)willDetachFromScrollView:(UIScrollView *)scrollView
{
    [self scrollView:scrollView attached:NO];
    [super willDetachFromScrollView:scrollView];
}

- (void)scrollView:(UIScrollView *)scrollView attached:(BOOL)attach {}

#pragma mark - Refreshing

- (void)beginRefresh
{
    [self beginRefreshing];
}

- (void)finishRefresh
{
    [self finishRefreshWithSuccess:YES];
}

- (void)endRefreshingWithSuccess:(BOOL)success
{
    // [EN] Route every end through the SmartRefreshControl name, so styles that override it see every refresh end.
    // [CN] 所有结束都经过 SmartRefreshControl 的方法名，重写它的样式能收到每一次结束。
    [self finishRefreshWithSuccess:success];
}

- (void)finishRefreshWithSuccess:(BOOL)success
{
    [super endRefreshingWithSuccess:success];
}

- (void)refreshDidFinishWithSuccess:(BOOL)success
{
    [super refreshDidFinishWithSuccess:success];
    self.status = CYLRefreshPhaseFinishing;
    [self onRefreshFinished:success];
}

- (NSTimeInterval)finishingDurationWithSuccess:(BOOL)success
{
    return [self onRefreshFinishing:success];
}

@end
