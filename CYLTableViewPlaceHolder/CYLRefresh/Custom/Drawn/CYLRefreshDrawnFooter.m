//
//  CYLRefreshDrawnFooter.m
//  CYLRefresh
//
//  flutter_easy_refresh's drawn footers (https://github.com/xuelongqy/flutter_easy_refresh, MIT), built on the
//  headers ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT).
//

#import "CYLRefreshDrawnFooter.h"
#import "CYLRefreshBezierRadarHeader.h"
#import "CYLRefreshMaterialHeader.h"
#import "CYLRefreshDeliveryHeader.h"
#import "CYLRefreshPhoenixHeader.h"
#import "CYLRefreshTaurusHeader.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"
#import "NSBundle+CYLRefresh.h"
#import "CYLRefreshConst.h"

/// [EN] CYLRefreshDrawnHeader's private driven mode. [CN] CYLRefreshDrawnHeader 私有的被驱动模式。
@interface CYLRefreshDrawnHeader (CYLDriven)
- (void)cyl_beginDriven;
- (void)cyl_driveFrame:(CGRect)frame;
- (void)cyl_driveOffset:(CGFloat)offset drag:(BOOL)isDragging;
- (void)cyl_driveStatus:(CYLRefreshPhase)status;
- (void)cyl_driveFinished:(BOOL)success;
@end

/// [EN] CYLRefreshBackFooter's private offset where the footer starts to show. [CN] CYLRefreshBackFooter 私有的刷新尾开始出现的偏移。
@interface CYLRefreshBackFooter (CYLDrawnFooter)
- (CGFloat)happenOffsetY;
@end

@interface CYLRefreshDrawnFooter ()
@property (strong, nonatomic, readwrite, nullable) CYLRefreshDrawnHeader *style;
@end

@implementation CYLRefreshDrawnFooter

+ (Class)styleClass
{
    return nil;
}

- (instancetype)initWithStyle:(CYLRefreshDrawnHeader *)style
{
    if (self = [super initWithFrame:CGRectZero]) {
        [self cyl_installStyle:style];
    }
    return self;
}

- (void)prepare
{
    [super prepare];
    Class styleClass = [self.class styleClass];
    if (styleClass) [self cyl_installStyle:[[styleClass alloc] init]];
}

- (void)cyl_installStyle:(CYLRefreshDrawnHeader *)style
{
    [self.style removeFromSuperview];
    self.style = style;
    [style cyl_beginDriven];
    [self insertSubview:style atIndex:0];
    self.cyl_h = style.expandHeight;
    self.stateLabel.hidden = self.state != CYLRefreshStateNoMoreData;
    [self setNeedsLayout];
}

#pragma mark - Colors

- (void)setColorAccent:(UIColor *)colorAccent
{
    [super setColorAccent:colorAccent];
    self.style.colorAccent = colorAccent;
}

- (void)setColorPrimary:(UIColor *)colorPrimary
{
    [super setColorPrimary:colorPrimary];
    self.style.colorPrimary = colorPrimary;
    self.backgroundColor = UIColor.clearColor;
}

#pragma mark - Pull

/// [EN] Points pulled past the content's bottom, the open height included while loading. [CN] 拉出内容底部的点数，加载中包含展开高度。
- (CGFloat)cyl_pulled
{
    if (!self.scrollView) return 0;
    return MAX(0, self.scrollView.cyl_offsetY - [self happenOffsetY]);
}

/// [EN] Stretch styles fill the revealed area; the others keep their open height. [CN] 拉伸类样式铺满露出区域；其他样式保持展开高度。
- (void)cyl_layoutStyle
{
    CYLRefreshDrawnHeader *style = self.style;
    if (!style) return;
    CGFloat height = style.expandHeight;
    if (style.scrollMode == CYLRefreshScrollModeStretch) height = MAX(height, [self cyl_pulled]);
    [style cyl_driveFrame:CGRectMake(0, 0, self.cyl_w, height)];
}

- (void)placeSubviews
{
    [super placeSubviews];
    [self cyl_layoutStyle];
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    CYLRefreshDrawnHeader *style = self.style;
    if (!style || self.state == CYLRefreshStateNoMoreData) return;
    CGFloat pulled = [self cyl_pulled];
    if (style.status == CYLRefreshPhaseFinishing && self.state == CYLRefreshStateIdle && pulled <= 0.5) {
        [style cyl_driveStatus:CYLRefreshPhaseIdle];
    }
    [self cyl_layoutStyle];
    [style cyl_driveOffset:pulled drag:self.scrollView.isDragging];
}

- (void)didAttachToScrollView:(UIScrollView *)scrollView
{
    [super didAttachToScrollView:scrollView];
    [self.style scrollView:scrollView attached:YES];
}

- (void)willDetachFromScrollView:(UIScrollView *)scrollView
{
    [self.style scrollView:scrollView attached:NO];
    [super willDetachFromScrollView:scrollView];
}

#pragma mark - Status

- (void)setState:(CYLRefreshState)state
{
    [super setState:state];
    BOOL noMoreData = state == CYLRefreshStateNoMoreData;
    self.stateLabel.hidden = !noMoreData;
    self.style.hidden = noMoreData;
}

/// [EN] The same order as CYLRefreshDrawnHeader: releasing before refreshing, finish until retracted.
/// [CN] 与 CYLRefreshDrawnHeader 相同的顺序：刷新前先经过释放中，结束状态保持到收回。
- (void)phaseDidChangeFrom:(CYLRefreshPhase)oldPhase to:(CYLRefreshPhase)phase
{
    [super phaseDidChangeFrom:oldPhase to:phase];
    CYLRefreshDrawnHeader *style = self.style;
    if (!style) return;
    switch (phase) {
        case CYLRefreshPhaseRefreshing:
            if (style.status != CYLRefreshPhaseReleasing) [style cyl_driveStatus:CYLRefreshPhaseReleasing];
            [style cyl_driveStatus:CYLRefreshPhaseRefreshing];
            break;
        case CYLRefreshPhaseIdle:
            if (style.status == CYLRefreshPhaseRefreshing) [style cyl_driveStatus:CYLRefreshPhaseFinishing];
            if (style.status != CYLRefreshPhaseFinishing || [self cyl_pulled] <= 0.5) [style cyl_driveStatus:CYLRefreshPhaseIdle];
            break;
        case CYLRefreshPhaseNoMoreData:
            [style cyl_driveStatus:CYLRefreshPhaseIdle];
            break;
        default:
            [style cyl_driveStatus:phase];
            break;
    }
}

- (void)refreshDidFinishWithSuccess:(BOOL)success
{
    [super refreshDidFinishWithSuccess:success];
    [self.style cyl_driveFinished:success];
}

- (NSTimeInterval)finishingDurationWithSuccess:(BOOL)success
{
    return self.style ? [self.style onRefreshFinishing:success] : [super finishingDurationWithSuccess:success];
}

@end

@implementation CYLRefreshBezierRadarFooter
+ (Class)styleClass { return CYLRefreshBezierRadarHeader.class; }
@end

@implementation CYLRefreshMaterialFooter
+ (Class)styleClass { return CYLRefreshMaterialHeader.class; }
@end

@implementation CYLRefreshDeliveryFooter
+ (Class)styleClass { return CYLRefreshDeliveryHeader.class; }
@end

@implementation CYLRefreshPhoenixFooter
+ (Class)styleClass { return CYLRefreshPhoenixHeader.class; }
@end

/// [EN] Forwards display-link ticks without retaining the footer. [CN] 转发 display link 回调，不强持有刷新尾。
@interface CYLRefreshBallPulseFooter (CYLTick)
- (void)cyl_tick;
@end

@interface CYLRefreshBallPulseTicker : NSObject
@property (weak, nonatomic) CYLRefreshBallPulseFooter *target;
@end

@implementation CYLRefreshBallPulseTicker
- (void)tick:(CADisplayLink *)link
{
    [self.target cyl_tick];
}
@end

@interface CYLRefreshBallPulseFooter ()
@property (strong, nonatomic) NSArray<CAShapeLayer *> *cyl_balls;
@property (strong, nonatomic) CADisplayLink *cyl_link;
@property (assign, nonatomic) CFTimeInterval cyl_startTime;
@end

@implementation CYLRefreshBallPulseFooter

- (void)prepare
{
    [super prepare];
    self.cyl_h = 60;
    _normalColor = [UIColor colorWithRed:0xee / 255.0 green:0xee / 255.0 blue:0xee / 255.0 alpha:1];
    _animatingColor = [UIColor colorWithRed:0xe7 / 255.0 green:0x59 / 255.0 blue:0x46 / 255.0 alpha:1];
    NSMutableArray<CAShapeLayer *> *balls = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        CAShapeLayer *ball = [CAShapeLayer layer];
        ball.fillColor = _normalColor.CGColor;
        [self.layer addSublayer:ball];
        [balls addObject:ball];
    }
    self.cyl_balls = balls;
    self.isAccessibilityElement = YES;
}

- (void)placeSubviews
{
    [super placeSubviews];
    // [EN] As BallPulseFooter.dispatchDraw: three balls with 4-point gaps, centered. [CN] 与 BallPulseFooter.dispatchDraw 相同：间隔 4 点的三个小球，居中。
    CGFloat spacing = 4;
    CGFloat radius = (MIN(self.cyl_w, self.cyl_h) - spacing * 2) / 6;
    CGFloat x = self.cyl_w / 2 - (radius * 2 + spacing);
    for (NSInteger i = 0; i < (NSInteger)self.cyl_balls.count; i++) {
        CAShapeLayer *ball = self.cyl_balls[i];
        ball.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
        ball.position = CGPointMake(x + i * (radius * 2 + spacing), self.cyl_h / 2);
        ball.path = [UIBezierPath bezierPathWithOvalInRect:ball.bounds].CGPath;
    }
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    if (self.state != CYLRefreshStateRefreshing) [self cyl_fillBalls:normalColor];
}

- (void)setAnimatingColor:(UIColor *)animatingColor
{
    _animatingColor = animatingColor;
    if (self.state == CYLRefreshStateRefreshing) [self cyl_fillBalls:animatingColor];
}

- (void)cyl_fillBalls:(UIColor *)color
{
    for (CAShapeLayer *ball in self.cyl_balls) ball.fillColor = color.CGColor;
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState
    BOOL loading = state == CYLRefreshStateRefreshing;
    for (CAShapeLayer *ball in self.cyl_balls) ball.hidden = state == CYLRefreshStateNoMoreData;
    [self cyl_fillBalls:loading ? self.animatingColor : self.normalColor];
    self.accessibilityLabel = loading ? [NSBundle cyl_localizedStringForKey:CYLRefreshAutoFooterRefreshingText] : nil;
    if (loading) {
        [self cyl_startPulsing];
    } else {
        [self cyl_stopPulsing];
    }
}

- (void)cyl_startPulsing
{
    if (self.cyl_link) return;
    self.cyl_startTime = CACurrentMediaTime();
    CYLRefreshBallPulseTicker *ticker = [CYLRefreshBallPulseTicker new];
    ticker.target = self;
    self.cyl_link = [CADisplayLink displayLinkWithTarget:ticker selector:@selector(tick:)];
    [self.cyl_link addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

- (void)cyl_stopPulsing
{
    [self.cyl_link invalidate];
    self.cyl_link = nil;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (CAShapeLayer *ball in self.cyl_balls) ball.transform = CATransform3DIdentity;
    [CATransaction commit];
}

/// [EN] One frame: each ball scales on a 0.75 s accelerate-decelerate cycle, 0.12 s after the previous one (as Android).
/// [CN] 一帧：每个小球按 0.75 秒的先加速后减速周期缩放，比前一个晚 0.12 秒（与 Android 相同）。
- (void)cyl_tick
{
    CFTimeInterval now = CACurrentMediaTime();
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (NSInteger i = 0; i < (NSInteger)self.cyl_balls.count; i++) {
        CFTimeInterval time = now - self.cyl_startTime - 0.12 * (i + 1);
        CGFloat linear = time > 0 ? fmod(time, 0.75) / 0.75 : 0;
        CGFloat percent = cos((linear + 1) * M_PI) / 2 + 0.5;
        CGFloat scale = percent < 0.5 ? 1 - percent * 2 * 0.7 : percent * 2 * 0.7 - 0.4;
        self.cyl_balls[i].transform = CATransform3DMakeScale(scale, scale, 1);
    }
    [CATransaction commit];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if (!newWindow) [self cyl_stopPulsing];
    else if (self.state == CYLRefreshStateRefreshing) [self cyl_startPulsing];
}

- (void)dealloc
{
    [_cyl_link invalidate];
}

@end

@implementation CYLRefreshTaurusFooter
+ (Class)styleClass { return CYLRefreshTaurusHeader.class; }
@end
