//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshBezierCircleHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshBezierCircleHeader.h"

#import "CYLRefreshValueAnimator.h"

#define TARGET_DEGREE 270

@interface CYLRefreshBezierCircleHeader ()<CYLRefreshValueAnimatorDelegate>

@property (nonatomic, assign) CGFloat springRatio;
@property (nonatomic, assign) CGFloat finishRatio;
@property (nonatomic, assign) CGFloat waveHeight;

@property (nonatomic, assign) CGFloat bollY;
@property (nonatomic, assign) CGFloat bollRadius;
@property (nonatomic, assign) CGFloat strokeWidth;

@property (nonatomic, assign) CGFloat animatorSpeed;
@property (nonatomic, assign) CGFloat animatorHeight;
@property (nonatomic, assign) CGFloat animatorSpringRatio;
@property (nonatomic, assign) CGFloat animatorSpringBollY;

//0 还没开始弹起 1 向上弹起 2 在弹起的最高点停住
@property (nonatomic, assign) NSInteger animatorStatus;

@property (nonatomic, assign) BOOL showOuter;
@property (nonatomic, assign) BOOL showBoll;
@property (nonatomic, assign) BOOL showBollTail;
@property (nonatomic, assign) BOOL outerIsStart;
@property (nonatomic, assign) BOOL wavePulling;

@property (nonatomic, assign) NSInteger refreshStop;
@property (nonatomic, assign) NSInteger refreshStart;
@property (nonatomic, assign) NSInteger refreshSwipe;

@property (nonatomic, strong) CYLRefreshValueAnimator *animatorRebound;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorRefreshing;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorFinish;

@end

@implementation CYLRefreshBezierCircleHeader

/**
 * 初始化参数
 */
- (void)setUpComponent {
    [super setUpComponent];
    
    self.refreshStop = 90;
    self.refreshStart = 90;
    self.outerIsStart = TRUE;
    self.strokeWidth = 2;
    
    self.height = 100;
    self.finishDuration = 0.8;
    
    self.opaque = FALSE;
    self.scrollMode = CYLRefreshScrollModeStretch;
    self.colorAccent = [UIColor whiteColor];
    self.colorPrimary = [UIColor colorWithRed:0x11/255.0 green:0x99/255.0 blue:0xff/255.0 alpha:1];
}

#pragma -mark Override

- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging {
    if (isDragging || self.wavePulling || self.status == CYLRefreshPhaseFinishing) {
        self.wavePulling = true;
        self.waveHeight = (0.8f * MAX(0, offset - self.expandHeight));
        [self setNeedsDisplay];
    }
}

- (void)onStartAnimationWhenRealeasing {
    self.wavePulling = FALSE;
    self.bollRadius = self.expandHeight / 6;
    //动画参数初始化
    self.animatorSpeed = 0;
    self.animatorStatus = 0;
    self.animatorSpringRatio = 0;
    self.animatorHeight = MIN(self.waveHeight * 0.8f, self.expandHeight / 2);
    
    //如果是手动调用 beginRefresh 直接指向刷新动画，不要回弹动画
    if (self.dragOffset == 0) {
        [self setShowBoll:TRUE];
        [self startAnimatorRefreshing];
        [self setBollY:self.expandHeight / 2];
        return;
    }
    
    //贝塞尔弹性动画
    CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator new];
    [animator setTarget:self selector:@selector(onAnimation:)];
    [animator setFromToPoints:@[
        @(_waveHeight), @(0),
        @(_animatorHeight * -1.0), @(0),
        @(_animatorHeight * -0.4), @(0),
    ]];
    [animator setDelegate:self];
    [animator setDuration:self.durationNormal*4];
    [animator setInterpolator:AnimatorInterpolatorDecelerate];
    [animator start];
    [self setAnimatorRebound:animator];
}

- (void)onRefreshFinished:(BOOL)success {
    self.showBoll = FALSE;
    self.showOuter = FALSE;
    
    [self.animatorRefreshing stop];
    
    //贝塞尔弹性动画
    CYLRefreshValueAnimator *animator = [CYLRefreshValueAnimator new];
    [animator setTarget:self selector:@selector(onAnimation:)];
    [animator setFromValue:0];
    [animator setToValue:1];
    [animator setDelegate:self];
    [animator setDuration:self.durationNormal*3];
    [animator setInterpolator:AnimatorInterpolatorAccelerate];
    [animator start];
    [self setAnimatorFinish:animator];
}


#pragma -mark CYLRefreshValueAnimator
/**
 * 动画执行
 */
- (void)onAnimation:(CYLRefreshValueAnimator*) animator {
    if (animator == self.animatorRebound) {
        CGFloat curValue = animator.value;
        CGFloat _headHeight = self.expandHeight;
        if (_animatorStatus == 0 && curValue <= 0) {
            _animatorStatus = 1;
            _animatorSpeed = ABS(curValue - _waveHeight);
        }
        if (_animatorStatus == 1) {
            _animatorSpringRatio = -curValue / _animatorHeight;
            if (_animatorSpringRatio >= _springRatio) {
                _springRatio = _animatorSpringRatio;
                _bollY = _headHeight + curValue;
                _animatorSpeed = ABS(curValue - _waveHeight);
            } else {
                _animatorStatus = 2;
                _springRatio = 0;
                _showBoll = true;
                _showBollTail = true;
                _animatorSpringBollY = _bollY;
            }
        }
        if (_animatorStatus == 2) {
            if (_bollY > _headHeight / 2) {
                _bollY = MAX(_headHeight / 2, _bollY - _animatorSpeed);
                float bally = animator.percent * (_headHeight / 2 - _animatorSpringBollY) + _animatorSpringBollY;
                if (_bollY > bally) {
                    _bollY = bally;
                }
            }
        }
        if (_showBollTail && curValue < _waveHeight) {
            [self startAnimatorRefreshing];
        }
        if (!_wavePulling) {
            _waveHeight = curValue;
            [self setNeedsDisplay];
        }
    } else if (animator == self.animatorFinish) {
        self.finishRatio = animator.value;
        [self setNeedsDisplay];
    } else if (animator == self.animatorRefreshing) {
        _refreshStart += _outerIsStart ? 3 : 10;
        _refreshStop += _outerIsStart ? 10 : 3;
        _refreshStart = _refreshStart % 360;
        _refreshStop = _refreshStop % 360;
        
        _refreshSwipe = _refreshStop - _refreshStart;
        _refreshSwipe = _refreshSwipe < 0 ? _refreshSwipe + 360 : _refreshSwipe;
        
        if (_refreshSwipe >= TARGET_DEGREE) {
            _outerIsStart = FALSE;
        } else if (_refreshSwipe <= 10) {
            _outerIsStart = TRUE;
        }
        [self setNeedsDisplay];
    }
}

/**
 * 动画结束
 */
- (void)onAnimationEnd:(CYLRefreshValueAnimator *)animator {
    if (animator == self.animatorRebound) {
        self.animatorRebound = nil;
    } else if (animator == self.animatorFinish) {
        self.finishRatio = 0;
        self.animatorFinish = nil;
    } else if (animator == self.animatorRefreshing) {
        self.animatorRefreshing = nil;
    }
}

- (void)startAnimatorRefreshing {
    _showOuter = true;
    _showBollTail = false;
    _outerIsStart = true;
    _refreshStart = 90;
    _refreshStop = 90;
    
    CYLRefreshValueAnimator* animator = [CYLRefreshValueAnimator new];
    [animator setTarget:self selector:@selector(onAnimation:)];
    [animator setDelegate:self];
    [animator setRepeatCount:INFINITY];
    [animator start];
    [self setAnimatorRefreshing:animator];
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
    [self drawSpringUp:context w:width];
    [self drawBoll:context w:width];
    [self drawOuter:context w:width];
    [self drawFinish:context w:width];
    
    if (height <= 0) {
        NSLog(@"%@.drawRect.height=%@ !", self.class, @(height));
    }
}

/**
 * 绘制完成动画
 */
- (void)drawFinish:(CGContextRef) context w:(CGFloat)width {
    if (_finishRatio > 0) {
        CGFloat headHeight = self.expandHeight;
        UIColor *beforeColor = self.colorAccent;
        CGFloat ratio1 = 0.3;
        CGFloat ratio2 = 0.7;
        
        if (_finishRatio < ratio1) {
            [beforeColor setFill];
            
            CGContextBeginPath(context);
            CGContextAddArc(context, width / 2, _bollY, _bollRadius, 0, 2*M_PI, 0);
            CGContextFillPath(context);
            
            CGFloat outerR = (_bollRadius + _strokeWidth * 2 * (1+_finishRatio / ratio1));
            
            
            UIColor *afterColor = [beforeColor colorWithAlphaComponent:1 - _finishRatio / ratio1];
            [afterColor setStroke];

            CGContextSetLineWidth(context, _strokeWidth);//线的宽度
            CGContextBeginPath(context);
            CGContextAddArc(context, width / 2, _bollY, outerR , 0, 2*M_PI, 0);
            CGContextDrawPath(context, kCGPathStroke);
        }
        
        [beforeColor setFill];

        if (_finishRatio >= ratio1 && _finishRatio < ratio2) {
            float fraction = (_finishRatio - 0.3f) / (ratio2 - ratio1);
            _bollY = (int) (headHeight / 2 + (headHeight - headHeight / 2) * fraction);
            
            CGContextBeginPath(context);
            CGContextAddArc(context, width / 2, _bollY, _bollRadius , 0, 2*M_PI, 0);
            CGContextFillPath(context);
            
            if (_bollY >= headHeight - _bollRadius * 1.5) {
                _showBollTail = true;

                [self drawBollTail:context w: width  f: fraction];
            }
            _showBollTail = false;
        }

        if (_finishRatio >= ratio2 && _finishRatio <= 1) {
            float fraction = (_finishRatio - ratio2) / (1 - ratio2);
            int leftX = (int) (width / 2.f - _bollRadius - 2 * _bollRadius * fraction);
            
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, leftX, headHeight);
            CGContextAddQuadCurveToPoint(context, width / 2, headHeight - _bollRadius * (1 - fraction), width - leftX, headHeight);
            CGContextFillPath(context);
        }
    }
}
/**
 * 绘制小球外圈
 */
- (void)drawOuter:(CGContextRef) context w:(CGFloat)width {
    if (_showOuter) {
        const CGFloat stroke = _strokeWidth;
        const CGFloat outerR = _bollRadius + stroke * 2;
        
        const NSInteger start = _refreshStart;
        const NSInteger stop = _refreshStop;

        [self.colorAccent setStroke];
        
        CGContextSetLineWidth(context, stroke);//线的宽度
        CGContextBeginPath(context);
        CGContextAddArc(context, width / 2, _bollY, outerR , start*M_PI/180, stop*M_PI/180, 0);
        CGContextDrawPath(context, kCGPathStroke);
    }
}
/**
 * 绘制小球向上弹起
 */
- (void)drawSpringUp:(CGContextRef) context w:(CGFloat)width {
    if (_springRatio > 0) {
        [self.colorAccent setFill];
        
        float leftX = (width / 2.f - 4 * _bollRadius + _springRatio * 3 * _bollRadius);
        if (_springRatio < 0.9) {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, leftX, _bollY);
            CGContextAddQuadCurveToPoint(context, width / 2, _bollY - _bollRadius * _springRatio * 2, width - leftX, _bollY);
            CGContextClosePath(context);
            CGContextFillPath(context);
        } else {
            CGContextBeginPath(context);
            CGContextAddArc(context, width / 2, _bollY, _bollRadius, 0, 2*M_PI, 0);
            CGContextFillPath(context);
        }
    }
}

/**
 * 绘制正常小球
 */
- (void)drawBoll:(CGContextRef) context w:(CGFloat)width {
    if (_showBoll) {
        [self.colorAccent setFill];
        
        CGContextBeginPath(context);
        CGContextAddArc(context, width / 2, _bollY, _bollRadius, 0, 2*M_PI, 0);
        CGContextFillPath(context);

        CGFloat height = self.expandHeight;
        [self drawBollTail:context w: width  f: (height + _waveHeight) / height];
    }
}

/**
 * 绘制小球尾巴
 */
- (void)drawBollTail:(CGContextRef) context w:(CGFloat)width f:(CGFloat) fraction {
    if (_showBollTail) {
        const CGFloat bottom = self.expandHeight + _waveHeight;
        const CGFloat startY = _bollY + _bollRadius * fraction / 2;
        const CGFloat startX = width / 2.f + sqrtf(_bollRadius * _bollRadius * (1 - fraction * fraction / 4));
        const CGFloat bezier1x = (width / 2.f + (_bollRadius * 3 / 4) * (1 - fraction));
        const CGFloat bezier2x = bezier1x + _bollRadius;

        [self.colorAccent setFill];
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, startX, startY);
        CGContextAddQuadCurveToPoint(context, bezier1x, bottom, bezier2x, bottom);
        CGContextAddLineToPoint(context, width - bezier2x, bottom);
        CGContextAddQuadCurveToPoint(context, width- bezier1x, bottom, width - startX, startY);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}
/**
 * 绘制背景波形
 */
- (void)drawWave:(CGContextRef) context w:(CGFloat)width h:(CGFloat)height {
    //重置画笔
    [self.colorPrimary setFill];

    CGFloat expandHeight = self.expandHeight;
    CGFloat baseHeight = MIN(expandHeight, height);
    if (_waveHeight != 0 && _finishRatio == 0) {
        //绘制贝塞尔曲线
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, width, 0);
        CGContextAddLineToPoint(context, width, baseHeight);
        CGContextAddQuadCurveToPoint(context, width / 2, baseHeight + _waveHeight * 2, 0, baseHeight);
        CGContextClosePath(context);
        CGContextFillPath(context);
    } else {
        CGContextFillRect(context, CGRectMake(0, 0, width, baseHeight));
    }
}

@end
