//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshMaterialHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshMaterialHeader.h"

#import "CYLRefreshValueAnimator.h"

#define kCircleSize 40

#define kMaxArrowSize       2
#define kMaxArrowRadius     8

#define MAX_PROGRESS_ANGLE  0.8f
#define MAX_PROGRESS_ARC    0.8f

#define NUM_POINTS                  5
#define FULL_ROTATION               1080.0f
#define ANIMATION_DURATION          1.332f
#define COLOR_START_DELAY_OFFSET    0.75f
#define END_TRIM_START_DELAY_OFFSET 0.5f
#define START_TRIM_DURATION_OFFSET  0.5f


#define FAST_OUT_SLOW_VALUES @(0.0F), @(1.0E-4F), @(2.0E-4F), @(5.0E-4F), @(9.0E-4F), @(0.0014F), @(0.002F), @(0.0027F), @(0.0036F), @(0.0046F), @(0.0058F), @(0.0071F), @(0.0085F), @(0.0101F), @(0.0118F), @(0.0137F), @(0.0158F), @(0.018F), @(0.0205F), @(0.0231F), @(0.0259F), @(0.0289F), @(0.0321F), @(0.0355F), @(0.0391F), @(0.043F), @(0.0471F), @(0.0514F), @(0.056F), @(0.0608F), @(0.066F), @(0.0714F), @(0.0771F), @(0.083F), @(0.0893F), @(0.0959F), @(0.1029F), @(0.1101F), @(0.1177F), @(0.1257F), @(0.1339F), @(0.1426F), @(0.1516F), @(0.161F), @(0.1707F), @(0.1808F), @(0.1913F), @(0.2021F), @(0.2133F), @(0.2248F), @(0.2366F), @(0.2487F), @(0.2611F), @(0.2738F), @(0.2867F), @(0.2998F), @(0.3131F), @(0.3265F), @(0.34F), @(0.3536F), @(0.3673F), @(0.381F), @(0.3946F), @(0.4082F), @(0.4217F), @(0.4352F), @(0.4485F), @(0.4616F), @(0.4746F), @(0.4874F), @(0.5F), @(0.5124F), @(0.5246F), @(0.5365F), @(0.5482F), @(0.5597F), @(0.571F), @(0.582F), @(0.5928F), @(0.6033F), @(0.6136F), @(0.6237F), @(0.6335F), @(0.6431F), @(0.6525F), @(0.6616F), @(0.6706F), @(0.6793F), @(0.6878F), @(0.6961F), @(0.7043F), @(0.7122F), @(0.7199F), @(0.7275F), @(0.7349F), @(0.7421F), @(0.7491F), @(0.7559F), @(0.7626F), @(0.7692F), @(0.7756F), @(0.7818F), @(0.7879F), @(0.7938F), @(0.7996F), @(0.8053F), @(0.8108F), @(0.8162F), @(0.8215F), @(0.8266F), @(0.8317F), @(0.8366F), @(0.8414F), @(0.8461F), @(0.8507F), @(0.8551F), @(0.8595F), @(0.8638F), @(0.8679F), @(0.872F), @(0.876F), @(0.8798F), @(0.8836F), @(0.8873F), @(0.8909F), @(0.8945F), @(0.8979F), @(0.9013F), @(0.9046F), @(0.9078F), @(0.9109F), @(0.9139F), @(0.9169F), @(0.9198F), @(0.9227F), @(0.9254F), @(0.9281F), @(0.9307F), @(0.9333F), @(0.9358F), @(0.9382F), @(0.9406F), @(0.9429F), @(0.9452F), @(0.9474F), @(0.9495F), @(0.9516F), @(0.9536F), @(0.9556F), @(0.9575F), @(0.9594F), @(0.9612F), @(0.9629F), @(0.9646F), @(0.9663F), @(0.9679F), @(0.9695F), @(0.971F), @(0.9725F), @(0.9739F), @(0.9753F), @(0.9766F), @(0.9779F), @(0.9791F), @(0.9803F), @(0.9815F), @(0.9826F), @(0.9837F), @(0.9848F), @(0.9858F), @(0.9867F), @(0.9877F), @(0.9885F), @(0.9894F), @(0.9902F), @(0.991F), @(0.9917F), @(0.9924F), @(0.9931F), @(0.9937F), @(0.9944F), @(0.9949F), @(0.9955F), @(0.996F), @(0.9964F), @(0.9969F), @(0.9973F), @(0.9977F), @(0.998F), @(0.9984F), @(0.9986F), @(0.9989F), @(0.9991F), @(0.9993F), @(0.9995F), @(0.9997F), @(0.9998F), @(0.9999F), @(0.9999F), @(1.0F), @(1.0F)
  
@interface CYLRefreshMaterialHeader ()<CYLRefreshValueAnimatorDelegate>

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *arrowLayer;
@property (nonatomic, strong) CAShapeLayer *highlightLayer;

@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, strong) CYLRefreshValueAnimator *animatorRefreshing;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorFinishing;

@property (nonatomic, assign) NSInteger aniColorIndex;
@property (nonatomic, assign) NSInteger aniRotationCount;

@property (nonatomic, assign) CGFloat aniStartTrim;
@property (nonatomic, assign) CGFloat aniEndTrim;
@property (nonatomic, assign) CGFloat aniRotation;
@property (nonatomic, assign) CGFloat aniArrowScale;
@property (nonatomic, assign) CGFloat aniBeginStartTrim;
@property (nonatomic, assign) CGFloat aniBeginEndTrim;
@property (nonatomic, assign) CGFloat aniBeginRotation;

@property (nonatomic, copy) NSArray<UIColor*> *aniSchemeColors;
@property (nonatomic, copy) NSArray<NSNumber*> *aniFastOutSlowValues;

@end

@implementation CYLRefreshMaterialHeader

/**
 * 初始化参数
 */
- (void)setUpComponent {
    [super setUpComponent];

    self.opaque = FALSE;
    self.height = kCircleSize * 2;
    self.finishDuration = 0.2;
    
    super.scrollMode = CYLRefreshScrollModeFront;
    super.colorAccent = [UIColor clearColor];
    super.colorPrimary = [UIColor whiteColor];
    super.userInteractionEnabled = FALSE;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [self.colorPrimary CGColor];
    shapeLayer.shadowColor = [[UIColor blackColor] CGColor];
    shapeLayer.shadowOffset = CGSizeMake(0, 1);
    shapeLayer.shadowOpacity = 0.3;
    shapeLayer.shadowRadius = 1.5;
    [shapeLayer setFillRule:kCAFillRuleEvenOdd];
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
    [highlightLayer setFillRule:kCAFillRuleNonZero];
    [self.shapeLayer addSublayer:highlightLayer];
    [self setHighlightLayer:highlightLayer];
    
    self.aniFastOutSlowValues = @[FAST_OUT_SLOW_VALUES];
    self.aniSchemeColors = @[
        [UIColor colorWithRed:0x00/255.0 green:0x99/255.0 blue:0xcc/255.0 alpha:1],
        [UIColor colorWithRed:0xff/255.0 green:0x44/255.0 blue:0x44/255.0 alpha:1],
        [UIColor colorWithRed:0x66/255.0 green:0x99/255.0 blue:0x00/255.0 alpha:1],
        [UIColor colorWithRed:0xaa/255.0 green:0x66/255.0 blue:0xcc/255.0 alpha:1],
        [UIColor colorWithRed:0xff/255.0 green:0x88/255.0 blue:0x00/255.0 alpha:1],
    ];
    [self resetSchemeColor];
}

- (void)setColorAccent:(UIColor *)colorAccent {
    [super setColorAccent:colorAccent];
    if (colorAccent == UIColor.clearColor) {
        [self setAniColorIndex:0];
        [self.arrowLayer setFillColor:_aniSchemeColors[0].CGColor];
    } else {
        [self.arrowLayer setFillColor:[colorAccent CGColor]];
    }
}

- (void)setColorPrimary:(UIColor *)colorPrimary {
    [super setColorPrimary:colorPrimary];
    [self.shapeLayer setFillColor:[colorPrimary CGColor]];
}

- (void)setAniSchemeColors:(NSArray<UIColor *> *)aniSchemeColors {
    if (aniSchemeColors.count) {
        _aniSchemeColors = aniSchemeColors;
    }
}

- (void)buildArrow:(const CGPoint *)origin p:(CGFloat)percent b:(CGFloat) begin e:(CGFloat) end r:(CGFloat) rotate s:(CGFloat) scale{
    
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    
    [self buildArrowPath:arrowPath origin:origin p:percent b:begin e:end r:rotate s:scale];
    
    _arrowLayer.path = arrowPath;
    CGPathRelease(arrowPath);
}

- (void)buildCircle:(const CGPoint *)origin radius:(CGFloat)radius {
    CGMutablePathRef path = CGPathCreateMutable();

    [self buildCirclePath:path origin:origin radius:radius];

    _shapeLayer.path = path;
    _shapeLayer.shadowPath = path;

    CGPathRelease(path);
    
    CGMutablePathRef highlightPath = CGPathCreateMutable();
    
    [self buildHighlightPath:highlightPath origin:origin radius:radius];
    
    _highlightLayer.path = highlightPath;
    CGPathRelease(highlightPath);
}

- (void)buildCirclePath:(CGMutablePathRef) path origin:(const CGPoint *)origin radius:(CGFloat)radius {
    CGPathAddArc(path, NULL, origin->x, origin->y, radius, 0, 2*M_PI, YES);
    CGPathCloseSubpath(path);
}

- (void)buildHighlightPath:(CGMutablePathRef) path origin:(const CGPoint *)origin radius:(CGFloat)radius {
    // Add the highlight shape
    CGPathAddArc(path, NULL, origin->x, origin->y, radius, 0, M_PI, YES);
    CGPathAddArc(path, NULL, origin->x, origin->y + 1.25, radius, M_PI, 0, NO);
}

/**
 * @param origin 圆心点
 * @param percent 下拉百分比
 * @param begin 箭头开始角度 0～1 代表 0～360
 * @param end 箭头结束角度 0～1 代表 0～360
 * @param rotate 箭头旋转角度 0～1 代表 0～360
 * @param scale 箭头缩放比例 （小于 0.3 时不绘制箭头）
 */
- (void)buildArrowPath:(CGMutablePathRef) path origin:(const CGPoint *)origin p:(CGFloat)percent b:(CGFloat) begin e:(CGFloat) end r:(CGFloat) rotate s:(CGFloat) scale {
    
    if (percent > 0) {
        // Add the arrow shape
        CGFloat arrowSize = kMaxArrowSize;
        CGFloat arrowRadius = kMaxArrowRadius;
        CGFloat arrowBigRadius = arrowRadius + (arrowSize / 2);
        CGFloat arrowSmallRadius = arrowRadius - (arrowSize / 2);
        CGFloat angleEnd = MAX(begin, end);
        CGFloat angleStart = MIN(end, begin);
        CGFloat anglePercent = MIN(1, MAX(0, angleEnd - angleStart));
        CGFloat angleAdjust = ((1 - anglePercent) * 2 * M_PI) - M_PI_2;
        CGFloat rotateAdjust = angleEnd*2*M_PI;
        
        CGAffineTransform tf = CGAffineTransformIdentity;
        tf = CGAffineTransformTranslate(tf, origin->x, origin->y);
        tf = CGAffineTransformRotate(tf, rotateAdjust + rotate * 2 * M_PI);
        tf = CGAffineTransformTranslate(tf, -origin->x, -origin->y);
        CGPathAddArc(path, &tf, origin->x, origin->y, arrowBigRadius, angleAdjust, 3 * M_PI_2, NO);
        
        if (scale > 0.3) {
            CGFloat centerX = origin->x;
            CGFloat centerY = origin->y - arrowBigRadius +  arrowSize / 2;
            
            tf = CGAffineTransformTranslate(tf, centerX, centerY);
            tf = CGAffineTransformScale(tf, scale, scale);
            tf = CGAffineTransformTranslate(tf, -centerX, -centerY);
            
            CGPathAddLineToPoint(path, &tf, origin->x, origin->y - arrowBigRadius - arrowSize);
            CGPathAddLineToPoint(path, &tf, origin->x + (2 * arrowSize), origin->y - arrowBigRadius + (arrowSize / 2));
            CGPathAddLineToPoint(path, &tf, origin->x, origin->y - arrowBigRadius + (2 * arrowSize));
            CGPathAddLineToPoint(path, &tf, origin->x, origin->y - arrowBigRadius + arrowSize);
            
            tf = CGAffineTransformTranslate(tf, centerX, centerY);
            tf = CGAffineTransformScale(tf, 1.f / scale, 1.f / scale);
            tf = CGAffineTransformTranslate(tf, -centerX, -centerY);
        }
        
        CGPathAddArc(path, &tf, origin->x, origin->y, arrowSmallRadius, 3 * M_PI_2, angleAdjust, YES);
        CGPathCloseSubpath(path);
    }
}
#pragma -mark Override

- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging {

    if (self.status == CYLRefreshPhaseRefreshing
        || self.status == CYLRefreshPhaseReleasing
        || self.status == CYLRefreshPhaseFinishing) {
        return;
    }

    CGFloat distance = MAX(0, (offset - kCircleSize) / 2);
    
    // 公式 y = M(1-8^(-x/H))
    CGFloat M = kCircleSize * 3;      //能够达到的最大值
    CGFloat H = kCircleSize * 6;      //接近最大值的点
    CGFloat x = distance;
    CGFloat y = M * (1 - pow(8, - x / H));
    
    distance = y;

    CGFloat radius = kCircleSize / 2;
    CGFloat percentage = MIN(distance / kCircleSize, 1);

    CGFloat expandHeight = self.expandHeight;
    CGFloat width = self.width, height = offset;

    CGPoint origin = CGPointZero;
    if (distance == 0) {
        origin = CGPointMake(floor(width / 2), height - radius);
    } else {
        origin = CGPointMake(floor(width / 2), radius + distance);
    }
    
    [self setOrigin:origin];
    [self buildCircle:&origin radius:radius];
    
    CGFloat extraOS = ABS(offset) - expandHeight;
    CGFloat tensionSlingshotPercent = MAX(0, MIN(extraOS, expandHeight * 2) / expandHeight);
    CGFloat tensionPercent = ((tensionSlingshotPercent / 4) - pow((tensionSlingshotPercent / 4), 2)) * 2.f;
    CGFloat strokeEnd = MIN(MAX_PROGRESS_ANGLE, percentage * .8f);
    CGFloat arrowScale = MIN(1, percentage);
    CGFloat arrowRotation = (.4f * percentage + tensionPercent * 2) * .5f;
    
    [self setAniStartTrim:0];
    [self setAniEndTrim:strokeEnd];
    [self setAniArrowScale:arrowScale];
    [self setAniRotation:arrowRotation];
    [self buildArrow:&origin p:percentage b:0 e:strokeEnd r:arrowRotation s:arrowScale];
}

- (void)onStartAnimationWhenRealeasing {
    // Start the shape disappearance animation
    CGPoint origin = CGPointMake(self.width/2, self.expandHeight/2);

    CGFloat radius = kCircleSize / 2;
    CGMutablePathRef toPath = CGPathCreateMutable();
    [self buildCirclePath:toPath origin:&origin radius:radius];
    
    id function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *pathMorph = [CABasicAnimation animationWithKeyPath:@"path"];
    pathMorph.duration = 0.15;
    pathMorph.fillMode = kCAFillModeForwards;
    pathMorph.removedOnCompletion = YES;
    pathMorph.toValue = (__bridge id)toPath;
    pathMorph.fromValue = (__bridge id)self.shapeLayer.path;
    pathMorph.timingFunction = function;
    [self.shapeLayer addAnimation:pathMorph forKey:nil];
    [self.shapeLayer setPath:toPath];
    
    CABasicAnimation *shadowPathMorph = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    shadowPathMorph.duration = 0.15;
    shadowPathMorph.fillMode = kCAFillModeForwards;
    shadowPathMorph.removedOnCompletion = YES;
    shadowPathMorph.toValue = (__bridge id)toPath;
    shadowPathMorph.fromValue = (__bridge id)self.shapeLayer.shadowPath;
    shadowPathMorph.timingFunction = function;
    [self.shapeLayer addAnimation:shadowPathMorph forKey:nil];
    [self.shapeLayer setShadowPath:toPath];
    CGPathRelease(toPath);
    
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    [self buildArrowPath:arrowPath origin:&origin p:1 b:_aniStartTrim e:_aniEndTrim r:_aniRotation s:_aniArrowScale];
    CABasicAnimation *arrowPathMorph = [CABasicAnimation animationWithKeyPath:@"path"];
    arrowPathMorph.duration = 0.15;
    arrowPathMorph.fillMode = kCAFillModeForwards;
    arrowPathMorph.removedOnCompletion = YES;
    arrowPathMorph.toValue = (__bridge id)arrowPath;
    arrowPathMorph.fromValue = (__bridge id)self.arrowLayer.path;
    arrowPathMorph.timingFunction = function;
    [self.arrowLayer addAnimation:arrowPathMorph forKey:nil];
    [self.arrowLayer setPath:arrowPath];
    CGPathRelease(arrowPath);
    
    CGMutablePathRef highlightPath = CGPathCreateMutable();
    [self buildHighlightPath:highlightPath origin:&origin radius:radius];
    CABasicAnimation *highlightMorph = [CABasicAnimation animationWithKeyPath:@"path"];
    highlightMorph.duration = 0.15;
    highlightMorph.fillMode = kCAFillModeForwards;
    highlightMorph.removedOnCompletion = YES;
    highlightMorph.toValue = (__bridge id)highlightPath;
    highlightMorph.fromValue = (__bridge id)self.highlightLayer.path;
    highlightMorph.timingFunction = function;
    [self.highlightLayer addAnimation:highlightMorph forKey:nil];
    [self.highlightLayer setPath:highlightPath];
    CGPathRelease(highlightPath);
    
    [self setOrigin:origin];
}

- (void)onStartAnimationWhenRefreshing {
    [self goToNextColor];
    [self setAniRotationCount:0];
    if (_aniStartTrim != _aniEndTrim) {
        [self storeOriginals];
        [self startAnimatorFinishing];
    } else {
        [self resetOriginals];
        [self startAnimatorRefreshing];
    }
}

- (void)onRefreshFinished:(BOOL)success {
    if (self.animatorFinishing) {
        [self.animatorFinishing stop];
    }
    if (self.animatorRefreshing) {
        [self.animatorRefreshing stop];
    }
    
    [self resetOriginals];
    [self resetSchemeColor];
    
    CGFloat radius = 2;
    CGPoint origin = self.origin;
    CGMutablePathRef toPath = CGPathCreateMutable();
    [self buildCirclePath:toPath origin:&origin radius:radius];
    
    id function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *pathMorph = [CABasicAnimation animationWithKeyPath:@"path"];
    pathMorph.duration = self.finishDuration;
    pathMorph.fillMode = kCAFillModeForwards;
    pathMorph.removedOnCompletion = YES;
    pathMorph.toValue = (__bridge id)toPath;
    pathMorph.fromValue = (__bridge id)self.shapeLayer.path;
    pathMorph.timingFunction = function;
    [self.shapeLayer addAnimation:pathMorph forKey:nil];
    
    CABasicAnimation *shadowPathMorph = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    shadowPathMorph.duration = self.finishDuration;
    shadowPathMorph.fillMode = kCAFillModeForwards;
    shadowPathMorph.removedOnCompletion = YES;
    shadowPathMorph.toValue = (__bridge id)toPath;
    shadowPathMorph.fromValue = (__bridge id)self.shapeLayer.shadowPath;
    shadowPathMorph.timingFunction = function;
    [self.shapeLayer addAnimation:shadowPathMorph forKey:nil];
    CGPathRelease(toPath);

    [self.arrowLayer setPath:nil];
    [self.shapeLayer setPath:nil];
    [self.shapeLayer setShadowPath:nil];
    [self.highlightLayer setPath:nil];
}


#pragma -mark CYLRefreshValueAnimator

/**
 * 动画执行
 */
- (void)onAnimationRefreshing:(CYLRefreshValueAnimator*) animator {
    const CGFloat interpolatedTime = animator.percent;
    const CGFloat startingTrim = _aniBeginStartTrim;
    const CGFloat startingEndTrim = _aniBeginEndTrim;
    const CGFloat startingRotation = _aniBeginRotation;
    const CGFloat minProgressArc = [self getMinProgressArc];

//    updateRingColor(interpolatedTime, ring);

    // Moving the start trim only occurs in the first 50% of a
    // single ring animation
    if (interpolatedTime <= START_TRIM_DURATION_OFFSET) {
        // scale the interpolatedTime so that the full
        // transformation from 0 - 1 takes place in the
        // remaining time
        const CGFloat scaledTime = (interpolatedTime)
                / (1.0f - START_TRIM_DURATION_OFFSET);
        const CGFloat percent = [self getFastOutSlowValue:scaledTime];
        _aniStartTrim = (startingTrim + ((MAX_PROGRESS_ARC - minProgressArc) * percent));
    }

    // Moving the end trim starts after 50% of a single ring
    // animation completes
    if (interpolatedTime > END_TRIM_START_DELAY_OFFSET) {
        // scale the interpolatedTime so that the full
        // transformation from 0 - 1 takes place in the
        // remaining time
        const CGFloat minArc = MAX_PROGRESS_ARC - minProgressArc;
        const CGFloat scaledTime = (interpolatedTime - START_TRIM_DURATION_OFFSET)
                / (1.0f - START_TRIM_DURATION_OFFSET);
        const CGFloat percent = [self getFastOutSlowValue:scaledTime];
        _aniEndTrim = (startingEndTrim + (minArc * percent));
    }
    
    _aniRotation = startingRotation + (0.25f * interpolatedTime);
    
    CGFloat groupRotation = ((FULL_ROTATION / NUM_POINTS) * interpolatedTime) + (FULL_ROTATION * (_aniRotationCount / NUM_POINTS));
    
    CGPoint origin = self.origin;
    CGFloat rotate = _aniRotation + groupRotation / 360;
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    [self buildArrowPath:arrowPath origin:&origin p:1 b:_aniStartTrim e:_aniEndTrim r:_aniRotation=rotate s:0];
    [self.arrowLayer setPath:arrowPath];
    CGPathRelease(arrowPath);
}

/**
 * 动画执行
 */
- (void)onAnimationFinishing:(CYLRefreshValueAnimator*) animator {
    // shrink back down and complete a full rotation before
    // starting other circles
    // Rotation goes between [0..1].
    
    const CGFloat interpolatedTime = animator.percent;
    const CGFloat minProgressArc = [self getMinProgressArc];
    const CGFloat targetRotation = floor(_aniBeginRotation / MAX_PROGRESS_ARC) + 1.f;
    const CGFloat startTrim = _aniBeginStartTrim + (_aniBeginEndTrim - minProgressArc - _aniBeginStartTrim) * interpolatedTime;
    const CGFloat rotation = _aniBeginRotation + ((targetRotation - _aniBeginRotation) * interpolatedTime);
    
    [self setAniStartTrim:startTrim];
    [self setAniEndTrim:_aniBeginEndTrim];
    [self setAniRotation:rotation];

    CGPoint origin = self.origin;
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    [self buildArrowPath:arrowPath origin:&origin p:1 b:startTrim e:_aniBeginEndTrim r:rotation s:_aniArrowScale];
    [self.arrowLayer setPath:arrowPath];
    CGPathRelease(arrowPath);
}

- (void)onAnimationRepeat:(CYLRefreshValueAnimator *)animator {
    if (animator == self.animatorRefreshing) {
        [self goToNextColor];
        [self storeOriginals];
        [self setAniStartTrim:_aniEndTrim];
        [self setAniRotationCount:(_aniRotationCount + 1) % NUM_POINTS];
    }
}

- (void)onAnimationEnd:(nonnull CYLRefreshValueAnimator *)animator {
    if (animator == self.animatorFinishing) {
        [self setAnimatorFinishing:nil];
        if (self.isRefreshing) {
            [self goToNextColor];
            [self storeOriginals];
            [self setAniStartTrim:_aniEndTrim];
            [self startAnimatorRefreshing];
        }
    } else if (animator == self.animatorRefreshing) {
        [self setAnimatorRefreshing:nil];
    }
}

- (void)startAnimatorRefreshing {
    CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator new];
    [animator setTarget:self selector:@selector(onAnimationRefreshing:)];
    [animator setDelegate:self];
    [animator setDuration:ANIMATION_DURATION];
    [animator setRepeatCount:INFINITY];
    [animator setRepeatMode:AnimatorRepeatModeRestart];
    [animator start];
    [self setAnimatorRefreshing:animator];
}

- (void)startAnimatorFinishing {
    CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator new];
    [animator setTarget:self selector:@selector(onAnimationFinishing:)];
    [animator setDelegate:self];
    [animator setDuration:ANIMATION_DURATION/2];
    [animator start];
    [self setAnimatorFinishing:animator];
}

- (CGFloat)getMinProgressArc {
    return (kMaxArrowSize / (2 * M_PI * kMaxArrowRadius)) * M_PI / 180;
}

/**
 * 加速器（快出慢入）
 */
- (CGFloat)getFastOutSlowValue:(CGFloat) paramFloat {
    if (paramFloat >= 1.0F) {
        return 1.0F;
    }
    if (paramFloat <= 0.0F) {
        return 0.0F;
    }
    NSArray<NSNumber*>* values = self.aniFastOutSlowValues;
    NSUInteger length = values.count;
    CGFloat stepSize = (1.0F / (length - 1));
    NSInteger i = MIN((NSInteger)((length - 1) * paramFloat), length - 2);
    paramFloat = (paramFloat - i * stepSize) / stepSize;
    return values[i].floatValue + (values[(i + 1)].floatValue - values[i].floatValue) * paramFloat;
}

- (void)storeOriginals{
    _aniBeginEndTrim = _aniEndTrim;
    _aniBeginStartTrim = _aniStartTrim;
    _aniBeginRotation = _aniRotation;
}

- (void)resetOriginals{
    _aniEndTrim = 0;
    _aniStartTrim = 0;
    _aniRotation = 0;
    [self storeOriginals];
}

- (void)goToNextColor {
    if (self.colorAccent == UIColor.clearColor) {
        [self setAniColorIndex:(_aniColorIndex + 1) % _aniSchemeColors.count];
        [self.arrowLayer setFillColor:_aniSchemeColors[_aniColorIndex].CGColor];
    }
}

- (void)resetSchemeColor {
    [self setAniColorIndex:0];
    if (self.colorAccent == UIColor.clearColor) {
        [self.arrowLayer setFillColor:_aniSchemeColors[0].CGColor];
    } else {
        [self.arrowLayer setFillColor:self.colorAccent.CGColor];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}



@end
