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

@implementation CYLRefreshTaurusFooter
+ (Class)styleClass { return CYLRefreshTaurusHeader.class; }
@end
