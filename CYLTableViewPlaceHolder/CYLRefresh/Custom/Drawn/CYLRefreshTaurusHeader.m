//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshTaurusHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshTaurusHeader.h"

#import "CYLRefreshValueAnimator.h"
#import "CYLRefreshVectorImage.h"

#define PATH_AIRPLANE @"m23 81c0 0 0 -1 0 -1 0 -0.5 0 -1 1.5 -1 2 -1 2.6 -2 2 -2.5 -0.5 -1 -2 -1 -11.6 -2.5 -5 -1 -10 -1 -11 -1.5l-1 0 1 -1c1 -1 1 -1 2 -1 0.6 0 6 0 13 1 6 0 12 1 12.6 0.6l1 0 -1 -2C30 67 16 42 15 40.6l-0.5 -1 4 -1c2 -0.6 4 -1 4 -1 0 0 6 4 13 8.5 14.6 10 17 11 20 12 4.6 2 6 1.6 13 -0.6 13 -5 25 -9 26 -9 0.6 0 3.6 1 -24 -14L51 23 47 16 43 10 43.6 9c1 -1 1 -1 1 -0.5 0 0 4 3 7.5 6 4 3 7 6 7.5 6 0 0 13.6 3 29.5 6 16 3 32 6 35 7l6 1 3 -1c41.6 -14.6 68 -23 85 -28 15 -4 24 -5 32 -2.5 7 2 10 5 8 8 -1.6 2.5 -4.6 4.6 -10.6 7.5 -6 3 -10 4 -25 9 -8 2.6 -16.6 6 -39 14 -67 25 -88 31 -121.6 36 -14.5 2 -24 3 -34 3 -5 0 -5.5 0 -6 -0.5z"

#define PATH_CLOUD_1  @"M552 1A65 65 0 0 0 504 22A51 51 0 0 0 492 20A51 51 0 0 0 442 71A51 51 0 0 0 492 121A51 51 0 0 0 511 118A65 65 0 0 0 517 122L586 122A65 65 0 0 0 600 111A60 60 0 0 0 608 122L696 122A60 60 0 0 0 712 82A60 60 0 0 0 652 22A60 60 0 0 0 611 39A65 65 0 0 0 552 1zM246 2A55 55 0 0 0 195 37A47 47 0 0 0 168 28A47 47 0 0 0 121 75A47 47 0 0 0 168 121A47 47 0 0 0 209 97A55 55 0 0 0 246 111A55 55 0 0 0 269 107A39 39 0 0 0 281 122L328 122A39 39 0 0 0 343 91A39 39 0 0 0 304 52A39 39 0 0 0 301 52A55 55 0 0 0 246 2z"

#define PATH_CLOUD_2  @"m507 31a53 53 0 0 0 -53 53 53 53 0 0 0 16 38h75a53 53 0 0 0 2 -2 28 28 0 0 0 1 2h213a97 97 0 0 0 -87 -54.8 97 97 0 0 0 -73 34 28 28 0 0 0 -27 -19 28 28 0 0 0 -13 3 53 53 0 0 0 0 -1 53 53 0 0 0 -53 -53zM206 32a54 54 0 0 0 -50 34 74.9 74.9 0 0 0 -47 -17 74.9 74.9 0 0 0 -74 61 31 31 0 0 0 -10 -2 31 31 0 0 0 -26 14L301 122a38 38 0 0 0 0 -4 38 38 0 0 0 -38 -38 38 38 0 0 0 -4 0 54 54 0 0 0 -54 -49z"

#define PATH_CLOUD_3  @"m424 37a53 53 0 0 0 -41 19 53 53 0 0 0 -1 2 63 63 0 0 0 -5 0 63 63 0 0 0 -61 50 63 63 0 0 0 -1 4 16 16 0 0 0 -10 -4 16 16 0 0 0 -8 2 21 21 0 0 0 -18 -11 21 21 0 0 0 -19 13 22 22 0 0 0 -7 -1 22 22 0 0 0 -19 11L523 122a44 44 0 0 0 -43 -37 44 44 0 0 0 -3 0 53 53 0 0 0 -53 -48zM129 38a50 50 0 0 0 -50 50 50 50 0 0 0 2 15 15 16 0 0 0 -6 2 15 16 0 0 0 -1 1 17 16 0 0 0 -12 -5 17 16 0 0 0 -16 14 20 16 0 0 0 -15 7L224 122a43 43 0 0 0 1 -10 43 43 0 0 0 -43 -43 43 43 0 0 0 -7 1 50 50 0 0 0 -47 -32zM632 83a64 64 0 0 0 -45 18 27 27 0 0 0 -11 -2 27 27 0 0 0 -23 13 17 17 0 0 0 -7 -1 17 17 0 0 0 -16 12h160a64 64 0 0 0 -59 -39z"

#define SCALE_START_PERCENT 0.5
#define ANIMATION_DURATION  1000

#define SIDE_CLOUDS_INITIAL_SCALE   0.6
#define SIDE_CLOUDS_FINAL_SCALE 1

#define CENTER_CLOUDS_INITIAL_SCALE 0.8
#define CENTER_CLOUDS_FINAL_SCALE   1

// Multiply with this animation interpolator time
#define LOADING_ANIMATION_COEFFICIENT   80
#define SLOW_DOWN_ANIMATION_COEFFICIENT 6

// Amount of lines when is going lading animation
#define WIND_SET_AMOUNT 10
#define Y_SIDE_CLOUDS_SLOW_DOWN_COF 4
#define X_SIDE_CLOUDS_SLOW_DOWN_COF 2
#define MIN_WIND_LINE_WIDTH 50
#define MAX_WIND_LINE_WIDTH 300
#define MIN_WIND_X_OFFSET   1000
#define MAX_WIND_X_OFFSET   2000
#define RANDOM_Y_COEFFICIENT    5

typedef NS_ENUM(NSInteger, AnimationPart) {
    AnimationPartFirst,
    AnimationPartSecond,
    AnimationPartThird,
    AnimationPartFourth
};

@interface CYLRefreshTaurusHeader ()

@property (nonatomic, strong) CYLRefreshValueAnimator *animatorFinish;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorRefreshing;
@property (nonatomic, strong) CYLRefreshVectorImage *imageCloud;
@property (nonatomic, strong) CYLRefreshVectorImage *imageAirplane;

@property (nonatomic, assign) CGFloat lastAnimationTime;
@property (nonatomic, assign) CGFloat loadingAnimationTime;
@property (nonatomic, assign) CGFloat finishAnimationTime;
@property (nonatomic, assign) CGFloat windLineWidth;

@property (nonatomic, assign) BOOL newWindSet;
@property (nonatomic, assign) BOOL inverseDirection;

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, NSNumber*> *winds;

@end

@implementation CYLRefreshTaurusHeader

#pragma mark - Init

/**
 * 初始化参数
 */
- (void)setUpComponent {
    [super setUpComponent];
    
    CYLRefreshVectorImage* imageCloud = [CYLRefreshVectorImage new];
    [imageCloud setSize:CGSizeMake(260, 45)];
    [imageCloud parserPaths:@[PATH_CLOUD_1,PATH_CLOUD_2,PATH_CLOUD_3]];
    [imageCloud parserColors:@[
        [UIColor colorWithRed:0xc7/255.0 green:0xdc/255.0 blue:0xf1/255.0 alpha:0xaa/255.0],
        [UIColor colorWithRed:0xe8/255.0 green:0xf3/255.0 blue:0xfd/255.0 alpha:0xdd/255.0],
        [UIColor colorWithRed:0xfd/255.0 green:0xfd/255.0 blue:0xfd/255.0 alpha:0xff/255.0],
    ]];
    
    CYLRefreshVectorImage* imageAirplane = [CYLRefreshVectorImage new];
    [imageAirplane setSize:CGSizeMake(65, 20)];
    [imageAirplane parserPaths:@[PATH_AIRPLANE]];
    [imageAirplane parserColors:@[[UIColor whiteColor]]];
        
    self.height = 100;
    self.colorAccent = [UIColor whiteColor];
    self.colorPrimary = [UIColor colorWithRed:0x11/255.0 green:0x99/255.0 blue:0xff/255.0 alpha:1];
    self.imageCloud = imageCloud;
    self.imageAirplane = imageAirplane;
    self.scrollMode = CYLRefreshScrollModeStretch;
    
    self.finishDuration = 0.3;
    self.winds = [NSMutableDictionary dictionary];
}

#pragma mark - Override

- (void)scrollView:(UIScrollView *)scrollView didScroll:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL) isDragging {
    [super scrollView:scrollView didScroll:offset percent:percent drag:isDragging];
    [self setNeedsDisplay];
}

//- (void)scrollView:(UIScrollView *)scrollView didChange:(CYLRefreshPhase)old status:(CYLRefreshPhase)status {
- (void)onStatus:(CYLRefreshPhase)old changed:(CYLRefreshPhase)status {
//    [super scrollView:scrollView didChange:old status:status];
    [super onStatus:old changed:status];
    
    if (old == CYLRefreshPhaseRefreshing) {
        self.animatorFinish = [CYLRefreshValueAnimator newWithTarget:self selector:@selector(animatorRunning:)];
        self.animatorFinish.duration = self.finishDuration;
        self.animatorFinish.repeatMode = AnimatorRepeatModeReverse;
        self.animatorFinish.interpolator = AnimatorInterpolatorAccelerateDecelerate;
        [self.animatorFinish start];
    } else if (status == CYLRefreshPhaseRefreshing) {
        [self setLoadingAnimationTime:0];
        self.animatorRefreshing = [CYLRefreshValueAnimator newWithTarget:self selector:@selector(animatorRunning:)];
        self.animatorRefreshing.repeatCount = INFINITY;
        self.animatorRefreshing.duration = ANIMATION_DURATION / 1000.0;
        self.animatorRefreshing.repeatMode = AnimatorRepeatModeReverse;
        self.animatorRefreshing.interpolator = AnimatorInterpolatorAccelerateDecelerate;
        [self.animatorRefreshing start];
    }
}

- (void)animatorRunning:(CYLRefreshValueAnimator*) animator {
    if (animator == self.animatorRefreshing) {
        self.loadingAnimationTime = LOADING_ANIMATION_COEFFICIENT * (animator.value / SLOW_DOWN_ANIMATION_COEFFICIENT);
        [self setNeedsDisplay];
    } else if (animator == self.animatorFinish) {
        self.finishAnimationTime = animator.value;
        if (animator.value >= 0.95) {
            [self.animatorRefreshing stop];
        }
        [self setNeedsDisplay];
    }
}
/**
 * We need a special value for different part of animation
 *
 * @param part - needed part
 * @return - value for needed part
 */
- (CGFloat) getAnimationPartValue:(AnimationPart) part
{
    switch (part) {
        case AnimationPartFirst:
            return _loadingAnimationTime;
        case AnimationPartSecond:
        return - _loadingAnimationTime;
        case AnimationPartThird:
        return _loadingAnimationTime - [self getAnimationTimePart:AnimationPartSecond];
        case AnimationPartFourth:
        return [self getAnimationTimePart:AnimationPartThird] - (_loadingAnimationTime - [self getAnimationTimePart:AnimationPartFourth]);
    }
    return 0;
}

/**
 * Get part of animation duration * * @param part - needed part of time * @return - interval of time
 */
- (NSInteger)getAnimationTimePart:(AnimationPart) part {
    switch (part) {
        case AnimationPartSecond:
            return LOADING_ANIMATION_COEFFICIENT / 2;
        case AnimationPartThird:
            return 3 * [self getAnimationTimePart:AnimationPartFourth];
        case AnimationPartFourth:
            return LOADING_ANIMATION_COEFFICIENT / 4;
        default:
            return 0;
    }
}

/**
  * On drawing we should check current part ofanimation
  *
  * @param part - needed part of animation
  * @return - return true if current part
  **/
- (BOOL)checkCurrentAnimationPart:(AnimationPart) part {
    switch (part) {
        case AnimationPartFirst:
            return _loadingAnimationTime < [self getAnimationTimePart:AnimationPartFourth];
        case AnimationPartSecond:
        case AnimationPartThird:
        return _loadingAnimationTime < [self getAnimationTimePart:part];
        case AnimationPartFourth:
        return _loadingAnimationTime > [self getAnimationTimePart:AnimationPartThird];
    }
    return FALSE;
}

#pragma mark - Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    const CGFloat width = self.width;
    const CGFloat height = self.dragOffset;
    const CGFloat percent = self.dragPercent;
    const CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.colorPrimary setFill];
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    [self drawWinds:context w:width h:height p:percent];
    [self drawAirplane:context w:width h:height p:percent];
    [self drawCloudSide:context w:width h:height p:percent];
    [self drawCloudCenter:context w:width h:height p:percent];
    
    if (height <= 0) {
        NSLog(@"%@.drawRect.height=%@ !", self.class, @(height));
    }
}

- (NSInteger) random:(NSInteger) min max:(NSInteger)max {
    return min + arc4random() % (max - min + 1);
}

- (void)drawWinds:(CGContextRef) context w:(CGFloat) width h:(CGFloat) height p:(CGFloat) percent {
    if (self.status == CYLRefreshPhaseRefreshing) {
        height = MAX(height, self.expandHeight);
        
        // Set up new set of wind
        while (self.winds.count < WIND_SET_AMOUNT) {
            CGFloat y = height / (RANDOM_Y_COEFFICIENT * [self random:1 max:100] / 100.0);
            CGFloat x = [self random:MIN_WIND_X_OFFSET max:MAX_WIND_X_OFFSET];
            
            // We want that interval will be greater than fifth part of draggable distance
            if (self.winds.count > 1) {
                y = 0;
                while (y == 0) {
                    CGFloat tmp = height / (RANDOM_Y_COEFFICIENT * [self random:1 max:100] / 100.0);
                    for (NSNumber *key in self.winds) {
                        // We want that interval will be greater than fifth part of draggable distance
                        if (ABS([key floatValue] - tmp) > height / RANDOM_Y_COEFFICIENT) {
                            y = tmp;
                        } else {
                            y = 0;
                            break;
                        }
                    }
                }
            }
            self.winds[@(y)] = @(x);
            [self drawWind:context y:y x:x w:width];
        }
        
        // Draw current set of wind
        //noinspection ConstantConditions
        if (self.winds.count >= WIND_SET_AMOUNT) {
            for (NSNumber *key in self.winds) {
                [self drawWind:context y:[key floatValue] x:self.winds[key].floatValue w:width];
            }
        }
        
        // We should to create new set of winds
        if (_inverseDirection && _newWindSet) {
            [self.winds removeAllObjects];
            _newWindSet = FALSE;
            _windLineWidth = [self random:MIN_WIND_LINE_WIDTH max:MAX_WIND_LINE_WIDTH];
        }
        
        // needed for checking direction
        _lastAnimationTime = _loadingAnimationTime;
    }
}

/**
 * Draw wind on loading animation
 *
 * @param context  - area where we will draw
 * @param y       - y position fot one of lines
 * @param xOffset - x offset for on of lines
 */
- (void)drawWind:(CGContextRef) context y:(CGFloat) y x:(CGFloat) xOffset w:(CGFloat) width {
    /**
     We should multiply current animation time with this coefficient for taking all screen width in time
     Removing slowing of animation with dividing on {@LINK #SLOW_DOWN_ANIMATION_COEFFICIENT}
     And we should don't forget about distance that should "fly" line that depend on screen of device and x offset
     */
    CGFloat cof = (width + xOffset) / (1.0 * LOADING_ANIMATION_COEFFICIENT / SLOW_DOWN_ANIMATION_COEFFICIENT);
    CGFloat time = _loadingAnimationTime;
    
    // HORRIBLE HACK FOR REVERS ANIMATION THAT SHOULD WORK LIKE RESTART ANIMATION
    if (_lastAnimationTime - _loadingAnimationTime > 0) {
        _inverseDirection = TRUE;
        // take time from 0 to end of animation time
        time = (1.0 * LOADING_ANIMATION_COEFFICIENT / SLOW_DOWN_ANIMATION_COEFFICIENT) - _loadingAnimationTime;
    } else {
        _newWindSet = TRUE;
        _inverseDirection = FALSE;
    }
    // Taking current x position of drawing wind
    // For fully disappearing of line we should subtract wind line width
    CGFloat x = (width - (time * cof)) + xOffset - _windLineWidth;
    CGFloat xEnd = x + _windLineWidth;

    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, 3.0);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.25f].CGColor);
    
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, xEnd, y);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

- (void)drawAirplane:(CGContextRef) context w:(CGFloat) width h:(CGFloat) height p:(CGFloat) percent {
    
    CGFloat rotateAngle = 0;
    CGFloat dragPercent = percent;
    CGFloat expandHeight = self.expandHeight;
    CYLRefreshVectorImage* airplane = self.imageAirplane;
    
    if (dragPercent > 1.0) {
        rotateAngle = 20 * (1.0 - pow(100, -(dragPercent - 1) / 2));
        dragPercent = 1.0;
    }
    
    CGFloat offsetX = ((width * dragPercent) / 2) - airplane.size.width / 2.0;
    CGFloat offsetY = expandHeight * (1 - dragPercent / 2) - airplane.size.height / 2.0;
    
    if (self.status == CYLRefreshPhaseFinishing) {
        offsetY -= (expandHeight / 2 + airplane.size.height / 2) * _finishAnimationTime;
        offsetX += (width + airplane.size.width - offsetX) * _finishAnimationTime;
    }
    
    if (_animatorRefreshing.isRunning) {
        if ([self checkCurrentAnimationPart: AnimationPartFirst]) {
            offsetY -= [self getAnimationPartValue:AnimationPartFirst];
        } else if ([self checkCurrentAnimationPart: AnimationPartSecond]) {
            offsetY -= [self getAnimationPartValue:AnimationPartSecond];
        } else if ([self checkCurrentAnimationPart: AnimationPartThird]) {
            offsetY += [self getAnimationPartValue:AnimationPartThird];
        } else if ([self checkCurrentAnimationPart: AnimationPartFourth]) {
            offsetY += [self getAnimationPartValue:AnimationPartFourth];
        }
    }

    CGContextSaveGState(context);
    CGContextTranslateCTM(context, offsetX, offsetY);
    
    if (rotateAngle > 0) {
        CGContextTranslateCTM(context, airplane.size.width/2, airplane.size.height/2);
        CGContextRotateCTM(context, rotateAngle * 3.1415926 / 180);
        CGContextTranslateCTM(context, -airplane.size.width/2, -airplane.size.height/2);
    }
    
    [airplane renderInContext:context];
    
    CGContextRestoreGState(context);
}

- (void)drawCloudSide:(CGContextRef) context w:(CGFloat) width h:(CGFloat) height p:(CGFloat) percent {
    
    CYLRefreshVectorImage *cloudLeft = self.imageCloud;
    CYLRefreshVectorImage *cloudRight = self.imageCloud;
    
    CGFloat expandHeight = self.expandHeight;
    CGFloat dragPercent = MIN(1, ABS(percent));
    
    CGFloat scale;
    CGFloat scalePercentDelta = dragPercent - SCALE_START_PERCENT;
    if (scalePercentDelta > 0) {
        CGFloat scalePercent = scalePercentDelta / (1.0f - SCALE_START_PERCENT);
        scale = SIDE_CLOUDS_INITIAL_SCALE + (SIDE_CLOUDS_FINAL_SCALE - SIDE_CLOUDS_INITIAL_SCALE) * scalePercent;
    } else {
        scale = SIDE_CLOUDS_INITIAL_SCALE;
    }

    // Current y position of clouds
    CGFloat dragYOffset = expandHeight * (1.0f - dragPercent);

    // Position where clouds fully visible on screen and we should drag them with content of listView

    CGFloat offsetLeftX = 0 - cloudLeft.size.width / 2;
    CGFloat offsetLeftY = (dragYOffset);

    CGFloat offsetRightX = width - cloudRight.size.width / 2;
    CGFloat offsetRightY = (dragYOffset);

    // Magic with animation on loading process
    if (_animatorRefreshing.isRunning) {
        if ([self checkCurrentAnimationPart: AnimationPartFirst]) {
            offsetLeftX -= 2 * [self getAnimationPartValue:AnimationPartFirst] / Y_SIDE_CLOUDS_SLOW_DOWN_COF;
            offsetRightX +=  [self getAnimationPartValue:AnimationPartFirst] / X_SIDE_CLOUDS_SLOW_DOWN_COF;
        } else if ([self checkCurrentAnimationPart: AnimationPartSecond]) {
            offsetLeftX -= 2 * [self getAnimationPartValue:AnimationPartSecond] / Y_SIDE_CLOUDS_SLOW_DOWN_COF;
            offsetRightX +=  [self getAnimationPartValue:AnimationPartSecond] / X_SIDE_CLOUDS_SLOW_DOWN_COF;
        } else if ([self checkCurrentAnimationPart: AnimationPartThird]) {
            offsetLeftX -= [self getAnimationPartValue:AnimationPartThird] / Y_SIDE_CLOUDS_SLOW_DOWN_COF;
            offsetRightX += 2 * [self getAnimationPartValue:AnimationPartThird] / X_SIDE_CLOUDS_SLOW_DOWN_COF;
        } else if ([self checkCurrentAnimationPart: AnimationPartFourth]) {
            offsetLeftX -= [self getAnimationPartValue:AnimationPartFourth] / Y_SIDE_CLOUDS_SLOW_DOWN_COF;
            offsetRightX += 2 * [self getAnimationPartValue:AnimationPartFourth] / X_SIDE_CLOUDS_SLOW_DOWN_COF;
        }
    }

    if (offsetLeftY + scale * cloudLeft.size.height < height + 2) {
        offsetLeftY = height + 2 - scale * cloudLeft.size.height;
    }
    if (offsetRightY + scale * cloudRight.size.height < height + 2) {
        offsetRightY = height + 2 - scale * cloudRight.size.height;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, offsetLeftX, offsetLeftY);
    
    CGContextTranslateCTM(context, cloudLeft.size.width * 3 / 4, cloudLeft.size.height);
    CGContextScaleCTM(context, scale, scale);
    CGContextTranslateCTM(context, -cloudLeft.size.width * 3 / 4, -cloudLeft.size.height);

    [cloudLeft setOpacity:100.0/255];
    [cloudLeft renderInContext:context];
    [cloudLeft setOpacity:1];
    
    CGContextRestoreGState(context);
    
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, offsetRightX, offsetRightY);
    
    CGContextTranslateCTM(context, 0, cloudRight.size.height);
    CGContextScaleCTM(context, scale, scale);
    CGContextTranslateCTM(context, 0, -cloudRight.size.height);

    [cloudRight setOpacity:100.0/255];
    [cloudRight renderInContext:context];
    [cloudRight setOpacity:1];
    
    CGContextRestoreGState(context);
}

- (void)drawCloudCenter:(CGContextRef) context w:(CGFloat) width h:(CGFloat) height p:(CGFloat) percent {

    CYLRefreshVectorImage *cloud = self.imageCloud;
    CGFloat expandHeight = self.expandHeight;
    
    CGFloat scale;
    CGFloat overDragPercent = 0;
    CGFloat dragPercent = MIN(1, ABS(percent));
    BOOL overDrag = FALSE;
    
    if (percent > 1.0f) {
        overDrag = TRUE;
        // Here we want know about how mach percent of over drag we done
        overDragPercent = ABS(1.0f - percent);
    }
    
    CGFloat scalePercentDelta = dragPercent - SCALE_START_PERCENT;
    if (scalePercentDelta > 0) {
        CGFloat scalePercent = scalePercentDelta / (1.0f - SCALE_START_PERCENT);
        scale = CENTER_CLOUDS_INITIAL_SCALE + (CENTER_CLOUDS_FINAL_SCALE - CENTER_CLOUDS_INITIAL_SCALE) * scalePercent;
    } else {
        scale = CENTER_CLOUDS_INITIAL_SCALE;
    }
    
    BOOL parallax = FALSE;
    CGFloat parallaxPercent = 0;
    CGFloat dragYOffset = expandHeight * dragPercent;
    // Position when should start parallax scrolling
    NSInteger startParallaxHeight = expandHeight - cloud.size.height / 2;

    if (dragYOffset > startParallaxHeight) {
        parallax = TRUE;
        parallaxPercent = dragYOffset - startParallaxHeight;
    }
    
    CGFloat offsetX = (width / 2) - cloud.size.width / 2;
    CGFloat offsetY = dragYOffset - cloud.size.height / 2 - (parallax ? parallaxPercent : 0);

    CGFloat sx = overDrag ? scale + overDragPercent / 4 : scale;
    CGFloat sy = sx;//overDrag ? scale + overDragPercent / 2 : scale;
    
    if (_animatorRefreshing.isRunning && !overDrag) {
        if ([self checkCurrentAnimationPart: AnimationPartFirst]) {
            sx = scale - [self getAnimationPartValue:AnimationPartFirst] / LOADING_ANIMATION_COEFFICIENT / 8;
        } else if ([self checkCurrentAnimationPart: AnimationPartSecond]) {
            sx = scale - [self getAnimationPartValue:AnimationPartSecond] / LOADING_ANIMATION_COEFFICIENT / 8;
        } else if ([self checkCurrentAnimationPart: AnimationPartThird]) {
            sx = scale + [self getAnimationPartValue:AnimationPartThird] / LOADING_ANIMATION_COEFFICIENT / 6;
        } else if ([self checkCurrentAnimationPart: AnimationPartFourth]) {
            sx = scale + [self getAnimationPartValue:AnimationPartFourth] / LOADING_ANIMATION_COEFFICIENT / 6;
        }
        sy = sx;
    }

    if (offsetY + sy * cloud.size.height < height + 2) {
        offsetY = height + 2 - sy * cloud.size.height;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, offsetX, offsetY);
    
    CGContextTranslateCTM(context, cloud.size.width / 2, 0);
    CGContextScaleCTM(context, sx, sy);
    CGContextTranslateCTM(context, -cloud.size.width / 2, 0);

    [cloud renderInContext:context];
    
    CGContextRestoreGState(context);
}

@end
