//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshBezierRadarHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshBezierRadarHeader.h"

#import "CYLRefreshValueAnimator.h"

@interface CYLRefreshBezierRadarHeader ()<CYLRefreshValueAnimatorDelegate>

@property (nonatomic, assign) BOOL wavePulling;
@property (nonatomic, assign) NSInteger waveTop;
@property (nonatomic, assign) NSInteger waveHeight;

@property (nonatomic, assign) CGFloat dotAlpha;
@property (nonatomic, assign) CGFloat dotFraction;
@property (nonatomic, assign) CGFloat dotRadius;
@property (nonatomic, assign) CGFloat rippleRadius;

@property (nonatomic, assign) NSInteger radarAngle;

@property (nonatomic, assign) CGFloat radarRadius;
@property (nonatomic, assign) CGFloat radarCircle;
@property (nonatomic, assign) CGFloat radarScale;

@property (nonatomic, assign) CGRect radarRect;

@property (nonatomic, strong) CYLRefreshValueAnimator *animatorWave;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorDotAlpha;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorRadarScale;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorRadarAnimator;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorRippleRadius;

@end

@implementation CYLRefreshBezierRadarHeader

/**
 * 初始化参数
 */
- (void)setUpComponent {
    [super setUpComponent];
    
    self.dotRadius = (7);
    self.radarRadius = (20);
    self.radarCircle = (7);
    
    self.height = 100;
    self.finishDuration = 0.3;
    
    self.opaque = FALSE;
    self.scrollMode = CYLRefreshScrollModeStretch;
    self.colorAccent = [UIColor whiteColor];
    self.colorPrimary = [UIColor colorWithRed:0x11/255.0 green:0x99/255.0 blue:0xff/255.0 alpha:1];
}

#pragma -mark Override

- (void)scrollView:(UIScrollView *)scrollView didScroll:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging {
    [super scrollView: scrollView didScroll:offset percent:percent drag:isDragging];
    if (isDragging || self.wavePulling) {
        self.wavePulling = true;
        self.waveTop = MIN(self.expandHeight, offset);
        self.waveHeight = (1.9f * MAX(0, offset - self.expandHeight));
        self.dotFraction = percent;
        
        [self setNeedsDisplay];
    }
}

//- (void)scrollView:(UIScrollView *)scrollView didChange:(CYLRefreshPhase)old status:(CYLRefreshPhase)status {
- (void)onStatus:(CYLRefreshPhase)old changed:(CYLRefreshPhase)status {
//    [super scrollView:scrollView didChange:old status:status];
    [super onStatus:old changed:status];
    if (status == CYLRefreshPhaseReleasing) {
        self.wavePulling = FALSE;
        self.waveTop = self.expandHeight;
        //隐藏球动画
        CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator new];
        [animator setTarget:self selector:@selector(onAnimation:)];
        [animator setInterpolator:AnimatorInterpolatorDecelerate];
        [animator setDuration:self.durationNormal];
        [animator setDelegate:self];
        [animator setFromValue:1];
        [animator setToValue:0];
        [animator start];
        [self setAnimatorDotAlpha:animator];
        //贝塞尔弹性动画
        CYLRefreshValueAnimator *animatorWave = [CYLRefreshValueAnimator new];
        [animatorWave setTarget:self selector:@selector(onAnimation:)];
        [animatorWave setFromToPoints:@[
            @(_waveHeight), @(0),
            @(_waveHeight * -0.5), @(0),
            @(_waveHeight * -0.2), @(0),
        ]];
        [animatorWave setDuration:self.durationNormal*3.6];
        [animatorWave setInterpolator:AnimatorInterpolatorDecelerate];
        [animatorWave setDelegate:self];
        [animatorWave start];
        [self setAnimatorWave:animatorWave];
    } else if (old == CYLRefreshPhaseRefreshing) {
        CGFloat width = self.width;
        CGFloat height = self.dragOffset;
        CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator newWithTarget:self selector:@selector(onAnimation:)];
        [animator setFromValue:self.radarRadius];
        [animator setToValue:sqrt(width * width + height * height)];
        [animator setDuration:self.finishDuration];
        [animator setDelegate:self];
        [animator setInterpolator:AnimatorInterpolatorAccelerate];
        [animator start];
        [self setAnimatorRippleRadius:animator];
    } else if (status == CYLRefreshPhasePullToRefresh || status == CYLRefreshPhaseIdle) {
        self.dotAlpha = 1;
        self.radarScale = 0;
        self.rippleRadius = 0;
    }
}

#pragma -mark CYLRefreshValueAnimator
/**
 * 动画执行
 */
- (void)onAnimation:(CYLRefreshValueAnimator*) animator {
    if (animator == self.animatorDotAlpha) {
        self.dotAlpha = animator.value;
        [self setNeedsDisplay];
    } else if (animator == self.animatorRadarScale) {
        self.radarScale = animator.value;
        [self setNeedsDisplay];
    } else if (animator == self.animatorRadarAnimator) {
        self.radarAngle = animator.value;
        [self setNeedsDisplay];
    } else if (animator == self.animatorWave) {
        if (_wavePulling) {
            [animator stop];
            [self setAnimatorWave:nil];
            return;
        }
        self.waveHeight = animator.value;
        [self setNeedsDisplay];
    } else if (animator == self.animatorRippleRadius) {
        self.rippleRadius = animator.value;
        [self setNeedsDisplay];
    }
}

/**
 * 动画结束
 */
- (void)onAnimationEnd:(CYLRefreshValueAnimator *)animator {
    if (animator == self.animatorDotAlpha) {
        self.animatorDotAlpha = nil;
        CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator newWithTarget:self selector:@selector(onAnimation:)];
        [animator setInterpolator:AnimatorInterpolatorDecelerate];
        [animator setDuration:self.durationNormal];
        [animator setDelegate:self];
        [animator setFromValue:0];
        [animator setToValue:1];
        [animator start];
        [self setAnimatorRadarScale:animator];
    } else if (animator == self.animatorRadarScale) {
        self.animatorRadarScale = nil;
        CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator newWithTarget:self selector:@selector(onAnimation:)];
        [animator setInterpolator:AnimatorInterpolatorAccelerateDecelerate];
        [animator setDuration:self.durationNormal*3];
        [animator setFromValue:0];
        [animator setToValue:360];
        [animator setRepeatMode:AnimatorRepeatModeRestart];
        [animator setRepeatCount:INFINITY];
        [animator start];
        [self setAnimatorRadarAnimator:animator];
    } else if (animator == self.animatorWave) {
        self.animatorWave = nil;
    } else if (animator == self.animatorRippleRadius) {
        self.animatorRippleRadius = nil;
    }
}


#pragma mark - Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    const CGFloat width = self.width;
    const CGFloat height = self.dragOffset;
    const CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawWave:context w:width h:height];
    [self drawDot:context w:width h:height];
    [self drawRadar:context w:width h:height];
    [self drawRipple:context w:width h:height];
    
    if (height <= 0) {
        NSLog(@"%@.drawRect.height=%@ !", self.class, @(height));
    }
}
/**
 * 绘制下拉时的 多个点
 */
- (void)drawDot:(CGContextRef) context w:(CGFloat)width h:(CGFloat)height {
    if (_dotAlpha > 0) {
        NSUInteger num = 7;
        CGFloat x = height;
        //y1 = t*(w/n)-(t>1)*((t-1)*(w/n)/t)
        CGFloat wide = (1.0 * width / num) * _dotFraction -((_dotFraction >1)?((_dotFraction -1)*(1.0 * width / num)/ _dotFraction):0);
        //y2 = x - (t>1)*((t-1)*x/t);
        CGFloat high = height - ((_dotFraction > 1) ? ((_dotFraction - 1) * height / 2 / _dotFraction) : 0);
        for (int i = 0 ; i < num; i++) {
            //y3 = (x + 1) - (n + 1)/2; 居中 index 变量：0 1 2 3 4 结果： -2 -1 0 1 2
            CGFloat index = 1.0 + i - (1.0 + num) / 2;
            //y4 = m * ( 1 - 2 * abs(y3) / n); 横向 alpha 差
            CGFloat alphaX = 255 * (1 - (2 * (ABS(index) / num)));
            //y5 = y4 * (1-1/((x/800+1)^15));竖直 alpha 差
            CGFloat alphaY = _dotAlpha * alphaX * (1.0 - 1.0 / pow((x / 800 + 1), 15));
            //mPaint.setAlpha((int) (_dotAlpha * alpha * (1.0 - 1.0 / pow((x / 800 + 1), 15))));
            [[self.colorAccent colorWithAlphaComponent:alphaY/255.0] setFill];
            //y6 = mDotRadius*(1-1/(x/10+1));半径
            CGFloat radius = _dotRadius * (1 - 1 / ((x / 10 + 1)));

            CGContextBeginPath(context);
            CGContextAddArc(context, width / 2 - radius / 2 + wide * index, high / 2, radius , 0, 2*M_PI, 0);
            CGContextFillPath(context);
        }
    }
}

- (void)drawRadar:(CGContextRef) context w:(CGFloat)width h:(CGFloat)height {
    if (self.status == CYLRefreshPhaseReleasing || self.status == CYLRefreshPhaseRefreshing) {
        CGFloat radius = _radarRadius * _radarScale;
        CGFloat circle = _radarCircle * _radarScale;
        
        [self.colorAccent setFill];
        [self.colorAccent setStroke];
        CGContextSetLineWidth(context, 3.0);//线的宽度

        CGContextAddArc(context, width / 2, height / 2, radius, 0, 2*M_PI, 0);
        CGContextFillPath(context);

        CGContextAddArc(context, width / 2, height / 2, radius + circle, 0, 2*M_PI, 0);
        CGContextDrawPath(context, kCGPathStroke); //绘制路
        
        [[self.colorPrimary colorWithAlphaComponent:0.33] setFill];
        [[self.colorPrimary colorWithAlphaComponent:0.33] setStroke];
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, width / 2, height / 2);
        CGContextAddArc(context, width / 2, height / 2, radius , 3*M_PI/2, _radarAngle*M_PI/180, 0);
        CGContextFillPath(context);
        

        CGContextBeginPath(context);
        CGContextAddArc(context, width / 2, height / 2, radius + circle, 3*M_PI/2, _radarAngle*M_PI/180, 0);
        CGContextDrawPath(context, kCGPathStroke); //绘制路
        
    }
}

/**
 * 绘制刷新完成 白色扩散动画
 */
- (void)drawRipple:(CGContextRef) context w:(CGFloat)width h:(CGFloat)height {
    if (_rippleRadius > 0) {
        [self.colorAccent setFill];
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, width / 2, height / 2);
        CGContextAddArc(context, width / 2, height / 2, _rippleRadius , 0, 2*M_PI, 0);
        CGContextFillPath(context);
    }
}
/**
 * 绘制背景波形
 */
- (void)drawWave:(CGContextRef) context w:(CGFloat)width h:(CGFloat)height {
    
    //重置画笔
    [self.colorPrimary setFill];

    //绘制贝塞尔曲线
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, _waveTop);
    CGContextAddQuadCurveToPoint(context, width / 2, _waveTop + _waveHeight, width, _waveTop);
    CGContextAddLineToPoint(context, width, 0);
    CGContextClosePath(context);
    
    CGContextFillPath(context);
}

@end
