//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Vector/ValueAnimator.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, CYLRefreshAnimatorInterpolator) {
    AnimatorInterpolatorLinear,
    AnimatorInterpolatorAccelerate,
    AnimatorInterpolatorDecelerate,
    AnimatorInterpolatorAccelerateDecelerate,
    AnimatorInterpolatorBounce,
};
typedef NS_ENUM(NSUInteger, CYLRefreshAnimatorRepeatMode) {
    AnimatorRepeatModeRestart,
    AnimatorRepeatModeReverse,
};

@class CYLRefreshValueAnimator;
@protocol CYLRefreshValueAnimatorDelegate <NSObject>

@optional
- (void) onAnimationStart:(CYLRefreshValueAnimator*) animator;
- (void) onAnimationRepeat:(CYLRefreshValueAnimator*) animator;
- (void) onAnimationEnd:(CYLRefreshValueAnimator*) animator;

@end

typedef CGFloat(^CYLRefreshAnimatorInterpolatorBlock)(CGFloat);

@interface CYLRefreshValueAnimator : NSObject

+ (CYLRefreshValueAnimator*)newWithFrom:(CGFloat) from to:(CGFloat) to;
+ (CYLRefreshValueAnimator*)newWithTarget:(id) target selector:(SEL) action;

- (void)setTarget:(id)target selector:(SEL)action;
- (void)setFrom:(CGFloat) from to:(CGFloat) to;                 //设置开始结束
- (void)setFromToPoints:(NSArray<NSNumber*>*) points;           //设置多断点

@property (nonatomic, assign) CGFloat fromValue;
@property (nonatomic, assign) CGFloat toValue;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) CGFloat repeatCount;              //INFINITY 表示无限
@property (nonatomic, assign) CFTimeInterval beginTime;
@property (nonatomic, assign) CFTimeInterval duration;          //动画持续时间（秒）
@property (nonatomic, assign) CYLRefreshAnimatorRepeatMode repeatMode;
@property (nonatomic, assign) CYLRefreshAnimatorInterpolator interpolator;

@property (nonatomic, weak) id<CYLRefreshValueAnimatorDelegate> delegate;
@property (nonatomic, copy) CYLRefreshAnimatorInterpolatorBlock interpolatorBlock;

@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, readonly) CGFloat value;
@property (nonatomic, readonly) CGFloat percent;

- (void) start;
- (void) stop;

@end

NS_ASSUME_NONNULL_END
