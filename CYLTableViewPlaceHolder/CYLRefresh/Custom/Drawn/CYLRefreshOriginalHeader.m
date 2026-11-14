//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshOriginalHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshOriginalHeader.h"

#define kTotalViewHeight    400
#define kOpenedViewHeight   44
#define kMinTopPadding      9
#define kMaxTopPadding      5
#define kMinTopRadius       12.5
#define kMaxTopRadius       16
#define kMinBottomRadius    3
#define kMaxBottomRadius    16
#define kMinBottomPadding   4
#define kMaxBottomPadding   6
#define kMinArrowSize       2
#define kMaxArrowSize       3
#define kMinArrowRadius     5
#define kMaxArrowRadius     7
#define kMaxDistance        53

static inline CGFloat lerp(CGFloat a, CGFloat b, CGFloat p)
{
    return a + (b - a) * p;
}

@interface CYLRefreshOriginalHeader ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *arrowLayer;
@property (nonatomic, strong) CAShapeLayer *highlightLayer;

@property (nonatomic, strong) UIActivityIndicatorView *activity;

@property (nonatomic, assign) CGPoint originTop;
@property (nonatomic, assign) CGPoint originBottom;
@property (nonatomic, assign) CGFloat lastOffset;

@end

@implementation CYLRefreshOriginalHeader

/**
 * 初始化参数
 */
- (void)setUpComponent {
    [super setUpComponent];

    self.opaque = FALSE;
    self.height = kMaxTopRadius * 4;
    
    self.enableAutoRefresh = TRUE;
    self.scrollMode = CYLRefreshScrollModeStretch;
    self.colorAccent = [UIColor whiteColor];
    self.colorPrimary = [UIColor colorWithRed:155.0 / 255.0 green:162.0 / 255.0 blue:172.0 / 255.0 alpha:1.0];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [self.colorPrimary CGColor];
    shapeLayer.strokeColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor];
    shapeLayer.lineWidth = 0.5;
    shapeLayer.shadowColor = [[UIColor blackColor] CGColor];
    shapeLayer.shadowOffset = CGSizeMake(0, 1);
    shapeLayer.shadowOpacity = 0.4;
    shapeLayer.shadowRadius = 0.5;
    [self.layer addSublayer:shapeLayer];
    [self setShapeLayer:shapeLayer];

    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.strokeColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor];
    arrowLayer.lineWidth = 0.5;
    arrowLayer.fillColor = [self.colorAccent CGColor];
    [self.shapeLayer addSublayer:arrowLayer];
    [self setArrowLayer:arrowLayer];

    CAShapeLayer *highlightLayer = [CAShapeLayer layer];
    highlightLayer.fillColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.2] CGColor];
    [self.shapeLayer addSublayer:highlightLayer];
    [self setHighlightLayer:highlightLayer];
    
    
    UIViewAutoresizing mark = 0;
    mark |= UIViewAutoresizingFlexibleLeftMargin;
    mark |= UIViewAutoresizingFlexibleRightMargin;
    UIActivityIndicatorView *activity = [UIActivityIndicatorView alloc];
    activity = [activity initWithActivityIndicatorStyle:2];
    [activity setAutoresizingMask:mark];
    [activity setTintColor:self.colorPrimary];
    
    [self addSubview:activity];
    [self setActivity:activity];
}

- (void)setColorAccent:(UIColor *)colorAccent {
    [super setColorAccent:colorAccent];
    [self.arrowLayer setFillColor:[colorAccent CGColor]];
}

- (void)setColorPrimary:(UIColor *)colorPrimary {
    [super setColorPrimary:colorPrimary];
    [self.activity setTintColor:colorPrimary];
    [self.shapeLayer setFillColor:[colorPrimary CGColor]];
}

- (void)buildArrowShape:(CGFloat)currentTopRadius percentage:(CGFloat)percentage topOrigin:(const CGPoint *)topOrigin {
    // Add the arrow shape
    CGFloat currentArrowSize = lerp(kMinArrowSize, kMaxArrowSize, percentage);
    CGFloat currentArrowRadius = lerp(kMinArrowRadius, kMaxArrowRadius, percentage);
    CGFloat arrowBigRadius = currentArrowRadius + (currentArrowSize / 2);
    CGFloat arrowSmallRadius = currentArrowRadius - (currentArrowSize / 2);
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    CGPathAddArc(arrowPath, NULL, topOrigin->x, topOrigin->y, arrowBigRadius, 0, 3 * M_PI_2, NO);
    CGPathAddLineToPoint(arrowPath, NULL, topOrigin->x, topOrigin->y - arrowBigRadius - currentArrowSize);
    CGPathAddLineToPoint(arrowPath, NULL, topOrigin->x + (2 * currentArrowSize), topOrigin->y - arrowBigRadius + (currentArrowSize / 2));
    CGPathAddLineToPoint(arrowPath, NULL, topOrigin->x, topOrigin->y - arrowBigRadius + (2 * currentArrowSize));
    CGPathAddLineToPoint(arrowPath, NULL, topOrigin->x, topOrigin->y - arrowBigRadius + currentArrowSize);
    CGPathAddArc(arrowPath, NULL, topOrigin->x, topOrigin->y, arrowSmallRadius, 3 * M_PI_2, 0, YES);
    CGPathCloseSubpath(arrowPath);
    _arrowLayer.path = arrowPath;
    [_arrowLayer setFillRule:kCAFillRuleEvenOdd];
    CGPathRelease(arrowPath);

    // Add the highlight shape
    CGMutablePathRef highlightPath = CGPathCreateMutable();
    CGPathAddArc(highlightPath, NULL, topOrigin->x, topOrigin->y, currentTopRadius, 0, M_PI, YES);
    CGPathAddArc(highlightPath, NULL, topOrigin->x, topOrigin->y + 1.25, currentTopRadius, M_PI, 0, NO);
    
    _highlightLayer.path = highlightPath;
    [_highlightLayer setFillRule:kCAFillRuleNonZero];
    CGPathRelease(highlightPath);
}

- (void)buildSemiCircle:(const CGPoint *)bottomOrigin currentBottomRadius:(CGFloat)currentBottomRadius currentTopRadius:(CGFloat)currentTopRadius topOrigin:(const CGPoint *)topOrigin {
    CGMutablePathRef path = CGPathCreateMutable();

    //Top semicircle
    CGPathAddArc(path, NULL, topOrigin->x, topOrigin->y, currentTopRadius, 0, M_PI, YES);

    //Left curve
    CGPoint leftCp1 = CGPointMake(lerp((topOrigin->x - currentTopRadius), (bottomOrigin->x - currentBottomRadius), 0.1), lerp(topOrigin->y, bottomOrigin->y, 0.2));
    CGPoint leftCp2 = CGPointMake(lerp((topOrigin->x - currentTopRadius), (bottomOrigin->x - currentBottomRadius), 0.9), lerp(topOrigin->y, bottomOrigin->y, 0.2));
    CGPoint leftDestination = CGPointMake(bottomOrigin->x - currentBottomRadius, bottomOrigin->y);

    CGPathAddCurveToPoint(path, NULL, leftCp1.x, leftCp1.y, leftCp2.x, leftCp2.y, leftDestination.x, leftDestination.y);

    //Bottom semicircle
    CGPathAddArc(path, NULL, bottomOrigin->x, bottomOrigin->y, currentBottomRadius, M_PI, 0, YES);

    //Right curve
    CGPoint rightCp2 = CGPointMake(lerp((topOrigin->x + currentTopRadius), (bottomOrigin->x + currentBottomRadius), 0.1), lerp(topOrigin->y, bottomOrigin->y, 0.2));
    CGPoint rightCp1 = CGPointMake(lerp((topOrigin->x + currentTopRadius), (bottomOrigin->x + currentBottomRadius), 0.9), lerp(topOrigin->y, bottomOrigin->y, 0.2));
    CGPoint rightDestination = CGPointMake(topOrigin->x + currentTopRadius, topOrigin->y);

    CGPathAddCurveToPoint(path, NULL, rightCp1.x, rightCp1.y, rightCp2.x, rightCp2.y, rightDestination.x, rightDestination.y);
    CGPathCloseSubpath(path);

    _shapeLayer.path = path;
    _shapeLayer.shadowPath = path;

    CGPathRelease(path);
}

#pragma -mark Override

- (void)scrollView:(UIScrollView *)scrollView attached:(BOOL)attach {
    [super scrollView:scrollView attached:attach];
    [self.activity setCenter:CGPointMake(self.width/2, self.expandHeight/2)];
}

- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging {

    if (self.status == CYLRefreshPhaseRefreshing
        || self.status == CYLRefreshPhaseReleasing
        || self.status == CYLRefreshPhaseFinishing) {
        [self setLastOffset:offset];
        return;
    }

    CGFloat verticalShift = MAX(0, offset - (kMaxTopRadius + kMaxBottomRadius + kMaxTopPadding + kMaxBottomPadding));
    CGFloat distance = MIN(kMaxDistance, fabs(verticalShift));
    CGFloat percentage = 1 - (distance / kMaxDistance);
    
    if (!self.enableAutoRefresh) {
        // 公式 y = M(1-200^(-x/H))
        CGFloat M = kMaxDistance * 1.5;   //能够达到的最大值
        CGFloat H = kMaxDistance * 8;     //接近最大值的点
        CGFloat x = fabs(verticalShift);
        CGFloat y = M * (1 - pow(100, - x / H));
        distance = y;
        percentage = 1 - (distance / M);
//        NSLog(@"distance=%@, x = %@ y = %@ H = %@", @(distance), @(x), @(y), @(H));
    }
    

    CGFloat currentTopPadding = lerp(kMinTopPadding, kMaxTopPadding, percentage);
    CGFloat currentTopRadius = lerp(kMinTopRadius, kMaxTopRadius, percentage);
    CGFloat currentBottomRadius = lerp(kMinBottomRadius, kMaxBottomRadius, percentage);
    CGFloat currentBottomPadding =  lerp(kMinBottomPadding, kMaxBottomPadding, percentage);

    CGFloat width = self.width, height = self.height;

    CGPoint bottomOrigin = CGPointMake(floor(width / 2), height - currentBottomPadding -currentBottomRadius);
    CGPoint topOrigin = CGPointZero;
    if (distance == 0) {
        topOrigin = CGPointMake(floor(width / 2), bottomOrigin.y);
    } else {
        topOrigin = CGPointMake(floor(width / 2), height - offset + currentTopPadding + currentTopRadius);
        bottomOrigin = CGPointMake(floor(width / 2), topOrigin.y + distance);
        
        if (self.enableAutoRefresh) {
            if (percentage == 0 && offset > self.lastOffset) {
                [self setLastOffset:offset];
//                bottomOrigin.y -= (fabs(verticalShift) - kMaxDistance);
//                triggered = YES;
                [self beginRefresh];
                return;
            }
        }
    }

    [self setOriginTop:topOrigin];
    [self setOriginBottom:bottomOrigin];

    [self buildSemiCircle:&bottomOrigin currentBottomRadius:currentBottomRadius currentTopRadius:currentTopRadius topOrigin:&topOrigin];

    [self buildArrowShape:currentTopRadius percentage:percentage topOrigin:&topOrigin];

    [self setLastOffset:offset];
}

- (void)onStartAnimationWhenRealeasing {
    // Start the shape disappearance animation
    CGPoint topOrigin = self.originTop;

    id function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CGFloat radius = lerp(kMinBottomRadius, kMaxBottomRadius, 0.2);
    CABasicAnimation *pathMorph = [CABasicAnimation animationWithKeyPath:@"path"];
    pathMorph.duration = 0.15;
    pathMorph.fillMode = kCAFillModeForwards;
    pathMorph.removedOnCompletion = NO;
    pathMorph.timingFunction = function;
    CGMutablePathRef toPath = CGPathCreateMutable();
    CGPathAddArc(toPath, NULL, topOrigin.x, topOrigin.y, radius, 0, M_PI, YES);
    CGPathAddCurveToPoint(toPath, NULL, topOrigin.x - radius, topOrigin.y, topOrigin.x - radius, topOrigin.y, topOrigin.x - radius, topOrigin.y);
    CGPathAddArc(toPath, NULL, topOrigin.x, topOrigin.y, radius, M_PI, 0, YES);
    CGPathAddCurveToPoint(toPath, NULL, topOrigin.x + radius, topOrigin.y, topOrigin.x + radius, topOrigin.y+0.1, topOrigin.x + radius, topOrigin.y);
    CGPathCloseSubpath(toPath);
    pathMorph.toValue = (__bridge id)toPath;
    [self.shapeLayer addAnimation:pathMorph forKey:nil];
    CABasicAnimation *shadowPathMorph = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    shadowPathMorph.duration = 0.15;
    shadowPathMorph.fillMode = kCAFillModeForwards;
    shadowPathMorph.removedOnCompletion = NO;
    shadowPathMorph.toValue = (__bridge id)toPath;
    shadowPathMorph.timingFunction = function;
    [self.shapeLayer addAnimation:shadowPathMorph forKey:nil];
    CGPathRelease(toPath);
    CABasicAnimation *shapeAlphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    shapeAlphaAnimation.duration = 0.1;
    shapeAlphaAnimation.beginTime = CACurrentMediaTime() + 0.1;
    shapeAlphaAnimation.toValue = [NSNumber numberWithFloat:0];
    shapeAlphaAnimation.fillMode = kCAFillModeForwards;
    shapeAlphaAnimation.removedOnCompletion = NO;
    shapeAlphaAnimation.timingFunction = function;
    [self.shapeLayer addAnimation:shapeAlphaAnimation forKey:nil];
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.duration = 0.1;
    alphaAnimation.toValue = [NSNumber numberWithFloat:0];
    alphaAnimation.fillMode = kCAFillModeForwards;
    alphaAnimation.removedOnCompletion = NO;
    alphaAnimation.timingFunction = function;
    [self.arrowLayer addAnimation:alphaAnimation forKey:nil];
    [self.highlightLayer addAnimation:alphaAnimation forKey:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.activity startAnimating];
    });
}

- (void)onRefreshFinished:(BOOL)success {
    [self.activity stopAnimating];
    
    [self.shapeLayer removeAllAnimations];
    [self.shapeLayer setPath:nil];
    [self.shapeLayer setShadowPath:nil];
    [self.arrowLayer removeAllAnimations];
    [self.arrowLayer setPath:nil];
    [self.highlightLayer removeAllAnimations];
    [self.highlightLayer setPath:nil];
    // We need to use the scrollView somehow in the end block,
    // or it'll get released in the animation block.
}

- (void)beginRefresh {
    [super beginRefresh];
//    if (self.status != CYLRefreshPhaseRefreshing && self.scrollView) {
//        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        alphaAnimation.duration = 0.0001;
//        alphaAnimation.toValue = [NSNumber numberWithFloat:0];
//        alphaAnimation.fillMode = kCAFillModeForwards;
//        alphaAnimation.removedOnCompletion = NO;
//        [_shapeLayer addAnimation:alphaAnimation forKey:nil];
//        [_arrowLayer addAnimation:alphaAnimation forKey:nil];
//        [_highlightLayer addAnimation:alphaAnimation forKey:nil];
//
//        _activity.alpha = 1;
//        _activity.layer.transform = CATransform3DMakeScale(1, 1, 1);

//        [self adjustInset:self.scrollView expand:true];
//    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}


@end
