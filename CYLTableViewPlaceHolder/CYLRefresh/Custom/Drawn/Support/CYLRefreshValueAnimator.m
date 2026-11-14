//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Vector/ValueAnimator.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshValueAnimator.h"

@interface CYLRefreshValueAnimator ()

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

@property (nonatomic, assign) BOOL reversed;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) CFTimeInterval timeStart;
@property (nonatomic, assign) CFTimeInterval timeOffset;

@property (nonatomic, copy) NSArray<NSNumber*> *points;

@end

@implementation CYLRefreshValueAnimator

+ (CYLRefreshValueAnimator *)newWithFrom:(CGFloat)from to:(CGFloat)to {
    CYLRefreshValueAnimator* this = [self new];
    if (this) {
        [this setFrom:from to:to];
    }
    return this;
}

+ (CYLRefreshValueAnimator *)newWithTarget:(id)target selector:(SEL)action {
    CYLRefreshValueAnimator* this = [self new];
    if (this) {
        [this setTarget:target selector:action];
    }
    return this;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)dealloc
{
    [self stop];
}

- (void)setTarget:(id)target selector:(SEL)action {
    self.target = target;
    self.action = action;
}

- (void)setFrom:(CGFloat)from to:(CGFloat)to {
    self.toValue = to;
    self.fromValue = from;
    
    if (!self.isRunning) {
        self.value = from;
    }
}

- (void)setFromToPoints:(NSArray<NSNumber *> *)points {
    self.points = points;
    
    if (!self.isRunning && points.count > 0) {
        self.value = points[0].floatValue;
    }
}

- (void)initialize {
    self.speed = 1;
    self.duration = 1;
    self.repeatCount = 1;
    self.fromValue = 0;
    self.toValue = 1;
    self.beginTime = 0;
}

- (BOOL)isRunning {
    return self.link != nil;
}

- (void)startInternal {
    self.timeOffset = 0;
    self.reversed = false;
    self.timeStart = CACurrentMediaTime();
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(step:)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onAnimationStart:)]) {
        [self.delegate onAnimationStart:self];
    }
}

- (void)start {
    if (!self.link) {
        if (self.beginTime > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_beginTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startInternal];
            });
        } else {
            [self startInternal];
        }
    }
}

- (void)stop {
    if (self.link) {
        [self.link invalidate];
        self.link = nil;
    }
}

- (CGFloat)valueFromPoints:(NSArray<NSNumber*>*) points time:(CGFloat)time reverse:(BOOL) reversed {
    NSEnumerator<NSNumber*> *enumer = nil;
    if (reversed) {
        enumer = [points reverseObjectEnumerator];
    } else {
        enumer = [points objectEnumerator];
    }
    
    for (NSUInteger count = points.count,i = 0; i < count - 1 && count > 1; i++) {
        CGFloat from = [[enumer nextObject] floatValue];
        CGFloat start = 1.0 * i / count;
        CGFloat end = 1.0 * (i + 1) / count;
        if (time >= start && time < end) {
            CGFloat to = [[enumer nextObject] floatValue];
            time = (time - start) / (end - start);
            return from + (to - from) * time;
        }
    }
    
    return [points[0] floatValue];
}

- (CGFloat)percent {
    return [self interpolation:self.timeOffset / self.duration];
}

- (void)step:(CADisplayLink*) link {
    CFTimeInterval thisStep = CACurrentMediaTime();
    CFTimeInterval stepDuration = thisStep - self.timeStart;
    //update time offset
    self.timeOffset = MIN(stepDuration, self.duration);
    //get normalized time offset (in range 0 - 1)
    CGFloat time = [self interpolation:self.timeOffset / self.duration];
    
    
    if (self.points.count) {
        self.value = [self valueFromPoints:self.points time:time reverse:self.reversed];
    } else {
        CGFloat from = self.reversed ? self.toValue : self.fromValue;
        CGFloat to = self.reversed ? self.fromValue : self.toValue;
        self.value = from + (to - from) * time;
    }
    
    
    if (self.target) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action withObject:self];
        #pragma clang diagnostic pop
    }
    
    if (self.timeOffset >= self.duration) {
        if (self.repeatCount != INFINITY) {
            self.repeatCount = self.repeatCount - 1;
        }
        if (self.repeatCount <= 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onAnimationEnd:)]) {
                [self.delegate onAnimationEnd:self];
            }
            [self stop];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onAnimationRepeat:)]) {
                [self.delegate onAnimationRepeat:self];
            }
            if (self.repeatMode == AnimatorRepeatModeReverse) {
                self.reversed = !self.reversed;
            } else {
                self.value = self.fromValue;
            }
        }
        self.timeStart = thisStep;
    }
}

- (CGFloat) interpolation:(CGFloat) value {
    if (self.interpolatorBlock) {
        return _interpolatorBlock(value);
    }
    if (_interpolator == AnimatorInterpolatorAccelerateDecelerate) {
        return cos((value + 1)*3.1415926) / 2 + 0.5;
    } else if (_interpolator == AnimatorInterpolatorAccelerate) {
        return value * value;
    } else if (_interpolator == AnimatorInterpolatorDecelerate) {
        return (1.0 - (1.0 - value) * (1.0 - value));
    } else if (_interpolator == AnimatorInterpolatorBounce) {
#define bounce(v) (v)*(v)*8
        value *= 1.1226f;
        if (value < 0.3535f) return bounce(value);
        else if (value < 0.7408f) return bounce(value - 0.54719f) + 0.7f;
        else if (value < 0.9644f) return bounce(value - 0.8526f) + 0.9f;
        else return bounce(value - 1.0435f) + 0.95f;
    }
    return value;
}

@end
