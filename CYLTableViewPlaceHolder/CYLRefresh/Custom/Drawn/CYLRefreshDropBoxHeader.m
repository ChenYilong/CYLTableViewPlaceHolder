//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshDropBoxHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshDropBoxHeader.h"

#import "CYLRefreshValueAnimator.h"
#import "CYLRefreshVectorImage.h"

#define PATH_IMAGE_MOIVE @[@"M3 2h18v20h-18z", @"m4 1c-1 0 -2 1 -2 2v18c0 1 1 2 2 2h16c1 0 2 -1 2 -2v-18c0 -1 -1 -2 -2 -2h-16zM3.5 3h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 3h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 6h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 6h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 9h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 9h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 12h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 12h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 15h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 15h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 18h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 18h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5z"]

#define PATH_IMAGE_FILE @[@"M49,16.5l-14,-14l-27,0l0,53l41,0z",@"m16,23.5h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1L16,21.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1z",@"m16,15.5h10c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1L16,13.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1z",@"M41,29.5L16,29.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1z",@"M41,37.5L16,37.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1z",@"M41,45.5L16,45.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1z",@"M49,16.5l-14,-14l0,14z"]

#define PATH_IMAGE_MUSIC @[@"M6,2.1L6,11.3C5.4,11.3 4.8,11.4 4.2,11.6C2.6,12.3 1.6,13.7 2.1,14.8C2.6,15.9 4.2,16.2 5.8,15.6C7.1,15.1 7.8,14.1 7.9,13.2L7.9,4.3L15,3L15,9.4C14.4,9.3 13.7,9.4 13,9.7C11.4,10.3 10.5,11.7 11,12.8C11.4,13.9 13.1,14.3 14.7,13.6C15.9,13.1 16.8,12.2 16.9,11.3L16.9,0L6,2.1L6,2.1Z"]

@interface BoxBody : NSObject

@property (nonatomic, assign) NSInteger boxCenterX;
@property (nonatomic, assign) NSInteger boxCenterY;
@property (nonatomic, assign) NSInteger boxBottom;
@property (nonatomic, assign) NSInteger boxTop;
@property (nonatomic, assign) NSInteger boxLeft;
@property (nonatomic, assign) NSInteger boxCenterTop;
@property (nonatomic, assign) NSInteger boxCenterBottom;
@property (nonatomic, assign) NSInteger boxRight;
@property (nonatomic, assign) NSInteger boxSideLength;

@end

@implementation BoxBody

-(BoxBody*) measure:(NSInteger) margin w:(NSInteger) width h: (NSInteger) height s: (NSInteger) sideLength {
    _boxSideLength = sideLength;
    _boxCenterX = width / 2;
    _boxBottom = height - margin;
    _boxTop = _boxBottom - 2 * sideLength;
    _boxLeft = _boxCenterX - (NSInteger) (sideLength * sin(3.1415926 / 3));
    _boxCenterTop = _boxTop + sideLength / 2;
    _boxCenterBottom = _boxBottom - sideLength / 2;
    _boxRight = width - _boxLeft;
    _boxCenterY = _boxBottom - sideLength;
    return self;
}

@end

@interface CYLRefreshDropBoxHeader ()<CYLRefreshValueAnimatorDelegate>

@property (nonatomic, strong) CYLRefreshValueAnimator *animatorRebound;
@property (nonatomic, strong) CYLRefreshValueAnimator *animatorDropOut;
@property (nonatomic, strong) CYLRefreshVectorImage *imageMoive;
@property (nonatomic, strong) CYLRefreshVectorImage *imageFile;
@property (nonatomic, strong) CYLRefreshVectorImage *imageMusic;

@property (nonatomic, strong) BoxBody *boxBody;
@property (nonatomic, assign) BOOL isDropOutOverFlow;
@property (nonatomic, assign) CGFloat percentRebound;
@property (nonatomic, assign) CGFloat percentDropOut;
@property (nonatomic, assign) CGFloat sideLength;
@property (nonatomic, assign) CGFloat imageSize;

@property (nonatomic, assign) BOOL finished;

@end

@implementation CYLRefreshDropBoxHeader

/**
 * 初始化参数
 */
- (void)setUpComponent {
    [super setUpComponent];
    
    self.height = 100;
    
    CYLRefreshVectorImage* imageMoive = [CYLRefreshVectorImage new];
    [imageMoive setSize:CGSizeMake(_imageSize, _imageSize)];
    [imageMoive parserPaths:PATH_IMAGE_MOIVE];
    [imageMoive parserColors:@[
        [UIColor colorWithRed:0xec/255.0 green:0xf0/255.0 blue:0xf1/255.0 alpha:1],
        [UIColor colorWithRed:0xfc/255.0 green:0x41/255.0 blue:0x08/255.0 alpha:1],
    ]];

    CYLRefreshVectorImage* imageFile = [CYLRefreshVectorImage new];
    [imageFile setSize:CGSizeMake(_imageSize, _imageSize)];
    [imageFile parserPaths:PATH_IMAGE_FILE];
    [imageFile parserColors:@[
        [UIColor colorWithRed:0xfe/255.0 green:0xd4/255.0 blue:0x69/255.0 alpha:1],
        [UIColor colorWithRed:0xd5/255.0 green:0xae/255.0 blue:0x57/255.0 alpha:1],
    ]];

    CYLRefreshVectorImage* imageMusic = [CYLRefreshVectorImage new];
    [imageMusic setSize:CGSizeMake(_imageSize, _imageSize)];
    [imageMusic parserPaths:PATH_IMAGE_MUSIC];
    [imageMusic parserColors:@[
        [UIColor colorWithRed:0x98/255.0 green:0xd7/255.0 blue:0x61/255.0 alpha:1],
    ]];
    
    CYLRefreshValueAnimator *animatorRebound = [CYLRefreshValueAnimator newWithTarget:self selector:@selector(onAnimation:)];
    [animatorRebound setInterpolator:AnimatorInterpolatorAccelerate];
    [animatorRebound setDuration:self.durationNormal];
    [animatorRebound setDelegate:self];
    
    CYLRefreshValueAnimator *animatorDropOut = [CYLRefreshValueAnimator newWithTarget:self selector:@selector(onAnimation:)];
    [animatorDropOut setInterpolator:AnimatorInterpolatorAccelerate];
    [animatorDropOut setDuration:self.durationNormal];
    [animatorDropOut setDelegate:self];
    
    self.imageMoive = imageMoive;
    self.imageFile = imageFile;
    self.imageMusic = imageMusic;
    self.animatorRebound = animatorRebound;
    self.animatorDropOut = animatorDropOut;
    self.boxBody = [BoxBody new];
    self.colorAccent =  [UIColor colorWithRed:0x6e/255.0 green:0xa9/255.0 blue:0xff/255.0 alpha:1];
    self.colorPrimary = [UIColor colorWithRed:0x28/255.0 green:0x36/255.0 blue:0x45/255.0 alpha:1];
    self.scrollMode = CYLRefreshScrollModeStretch;
    
}

- (void)setHeight:(CGFloat)height {
    [super setHeight:height];
    [self setImageSize:height / 5];
    [self setSideLength:height / 5];
}

- (void)finishRefreshWithSuccess:(BOOL)success {
    [self setFinished:TRUE];
    [super finishRefreshWithSuccess:success];
}

- (void)onAnimation:(CYLRefreshValueAnimator*) animator {
    if (self.finished) {
        NSLog(@"onAnimation:finished = TRUE");
    }
    if (self.status != CYLRefreshPhaseRefreshing) {
        [animator stop];//不是刷新状态时，停止定时器
        return;
    }
    if (self.finished) {
        NSLog(@"onAnimation:finished = TRUE!  RUN!!!");
    }
    if (animator == self.animatorRebound) {
        [self setPercentRebound:1 - 2 * ABS(animator.value - 0.5)];
        [self setNeedsDisplay];
    } else if (animator == self.animatorDropOut) {
        if (_percentDropOut < 1 || _percentDropOut >= 3) {
            _percentDropOut = animator.value;
        } else if (_percentDropOut < 2) {
            _percentDropOut = 1 + animator.value;
        } else if (_percentDropOut < 3) {
            _percentDropOut = 2 + animator.value;
            if (_percentDropOut == 3) {
                _isDropOutOverFlow = TRUE;
            }
        }
        [self setNeedsDisplay];
    }
}

- (void)onAnimationEnd:(CYLRefreshValueAnimator *)animator {
    if (animator == self.animatorRebound) {
        if (self.status == CYLRefreshPhaseRefreshing) {
            [self.animatorDropOut start];
        } else {
            self.percentDropOut = 0;
        }
    } else if (animator == self.animatorDropOut) {
        [self.animatorRebound start];
    }
}

#pragma mark - Override

- (void)scrollView:(UIScrollView *)scrollView didScroll:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL) isDragging {
    [super scrollView:scrollView didScroll:offset percent:percent drag:isDragging];

    if (!isDragging || self.status != CYLRefreshPhaseRefreshing) {
        [self setPercentRebound:MIN(1, MAX(0, (percent - 1) / 2))];
    }
    [self setNeedsDisplay];
}

//- (void)scrollView:(UIScrollView *)scrollView didChange:(CYLRefreshPhase)old status:(CYLRefreshPhase)status {
- (void)onStatus:(CYLRefreshPhase)old changed:(CYLRefreshPhase)status {
    if (status == CYLRefreshPhaseIdle) {
        [self setIsDropOutOverFlow:FALSE];
    } else if (status == CYLRefreshPhaseRefreshing) {
        [self setFinished:FALSE];
        [self.animatorDropOut start];
    } else if (status == CYLRefreshPhaseFinishing) {
        [self.animatorDropOut stop];
        [self.animatorRebound stop];
        [self setPercentDropOut:0];
    }
//    [super scrollView:scrollView didChange:old status:status];
    [super onStatus:old changed:status];
}

#pragma mark - Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    const CGFloat width = self.width;
    const CGFloat height = self.dragOffset;
    const CGFloat margin = self.sideLength / 2;
    const CGContextRef context = UIGraphicsGetCurrentContext();
    const BoxBody *box = [self.boxBody measure:margin w:width h:height s:margin*2];
    
    [self.colorPrimary setFill];
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    [self drawBoxBody:context box:box];
    [self drawBoxCoverPath:context box:box];
    [self drawImages:context box:box w:width];
    
    if (height <= 0) {
        NSLog(@"%@.drawRect.height=%@ !", self.class, @(height));
    }
}

- (void)drawBoxBody:(CGContextRef) context box:(const BoxBody*) box {
    [[self.colorAccent colorWithAlphaComponent:150.0/255] setFill];
    CGContextMoveToPoint(context, box.boxLeft, box.boxCenterBottom);
    CGContextAddLineToPoint(context, box.boxCenterX, box.boxBottom);
    CGContextAddLineToPoint(context, box.boxRight, box.boxCenterBottom);
    CGContextAddQuadCurveToPoint(context, box.boxRight + box.boxSideLength / 2 * _percentRebound, box.boxCenterY, box.boxRight, box.boxCenterTop);
    CGContextAddLineToPoint(context, box.boxCenterX, box.boxTop);
    CGContextAddLineToPoint(context, box.boxLeft, box.boxCenterTop);
    CGContextAddQuadCurveToPoint(context, box.boxLeft - box.boxSideLength / 2 * _percentRebound, box.boxCenterY, box.boxLeft, box.boxCenterBottom);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

- (void)drawBoxCoverPath:(CGContextRef) context box:(const BoxBody*) box {
    [self.colorAccent setFill];

    const NSInteger sideLength = (box.boxCenterX - box.boxLeft) * 4 / 5;
    const CGFloat offsetAngle = _percentRebound * (3.1415926 * 2 / 5);

    /*
     * 开始画左上的盖子
     */
    const CGFloat offsetLeftTopX = sideLength * (float) sin(3.1415926 / 3 - offsetAngle / 2);
    const CGFloat offsetLeftTopY = sideLength * (float) cos(3.1415926 / 3 - offsetAngle / 2);
    CGContextMoveToPoint(context, box.boxLeft, box.boxCenterTop);
    CGContextAddLineToPoint(context, box.boxCenterX, box.boxTop);
    CGContextAddLineToPoint(context, box.boxCenterX - offsetLeftTopX, box.boxTop - offsetLeftTopY);
    CGContextAddLineToPoint(context, box.boxLeft - offsetLeftTopX, box.boxCenterTop - offsetLeftTopY);
    CGContextClosePath(context);
    CGContextFillPath(context);

    /*
     * 开始画左下的盖子
     */
    const CGFloat offsetLeftBottomX = sideLength * (float) sin(3.1415926 / 3 + offsetAngle);
    const CGFloat offsetLeftBottomY = sideLength * (float) cos(3.1415926 / 3 + offsetAngle);
    CGContextMoveToPoint(context, box.boxLeft, box.boxCenterTop);
    CGContextAddLineToPoint(context, box.boxCenterX, (box.boxBottom + box.boxTop) / 2);
    CGContextAddLineToPoint(context, box.boxCenterX - offsetLeftBottomX, (box.boxBottom + box.boxTop) / 2 + offsetLeftBottomY);
    CGContextAddLineToPoint(context, box.boxLeft - offsetLeftBottomX, box.boxCenterTop + offsetLeftBottomY);
    CGContextClosePath(context);
    CGContextFillPath(context);

    /*
     * 开始画右上的盖子
     */
    const CGFloat offsetRightTopX = sideLength * (float) sin(3.1415926 / 3 - offsetAngle / 2);
    const CGFloat offsetRightTopY = sideLength * (float) cos(3.1415926 / 3 - offsetAngle / 2);
    CGContextMoveToPoint(context, box.boxRight, box.boxCenterTop);
    CGContextAddLineToPoint(context, box.boxCenterX, box.boxTop);
    CGContextAddLineToPoint(context, box.boxCenterX + offsetRightTopX, box.boxTop - offsetRightTopY);
    CGContextAddLineToPoint(context, box.boxRight + offsetRightTopX, box.boxCenterTop - offsetRightTopY);
    CGContextClosePath(context);
    CGContextFillPath(context);

    /*
     * 开始画右下的盖子
     */
    const CGFloat offsetRightBottomX = sideLength * (float) sin(3.1415926 / 3 + offsetAngle);
    const CGFloat offsetRightBottomY = sideLength * (float) cos(3.1415926 / 3 + offsetAngle);
    CGContextMoveToPoint(context, box.boxRight, box.boxCenterTop);
    CGContextAddLineToPoint(context, box.boxCenterX, (box.boxBottom + box.boxTop) / 2);
    CGContextAddLineToPoint(context, box.boxCenterX + offsetRightBottomX, (box.boxBottom + box.boxTop) / 2 + offsetRightBottomY);
    CGContextAddLineToPoint(context, box.boxRight + offsetRightBottomX, box.boxCenterTop + offsetRightBottomY);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

- (void)drawImages:(CGContextRef) context box:(const BoxBody*) box w:(CGFloat) width {
    if (_percentDropOut <= 0) {
        return;
    }

    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 0, box.boxCenterTop);
    CGPathAddLineToPoint(path, NULL, box.boxLeft, box.boxCenterTop);
    CGPathAddLineToPoint(path, NULL, box.boxCenterX, box.boxCenterY);
    CGPathAddLineToPoint(path, NULL, box.boxRight, box.boxCenterTop);
    CGPathAddLineToPoint(path, NULL, width, box.boxCenterTop);
    CGPathAddLineToPoint(path, NULL, width, 0);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGPathRelease(path);

    CGFloat percent1 = MIN(_percentDropOut, 1);
    CGRect frame1 = _imageMoive.frame;
    frame1.origin = CGPointMake(width / 2 - _imageSize / 2, ((box.boxCenterY - _imageSize / 2 + _imageSize) * percent1) - _imageSize);
    [_imageMoive setFrame:frame1];
    [_imageMoive renderInContext:context];

    CGFloat percent2 = MIN(MAX(_percentDropOut - 1, 0), 1);
    CGRect frame2 = _imageFile.frame;
    frame2.origin = CGPointMake(width / 2 - _imageSize / 2, ((box.boxCenterY - _imageSize / 2 + _imageSize) * percent2) - _imageSize);
    [_imageFile setFrame:frame2];
    [_imageFile renderInContext:context];

    CGFloat percent3 = MIN(MAX(_percentDropOut - 2, 0), 1);
    CGRect frame3 = _imageMusic.frame;
    frame3.origin = CGPointMake(width / 2 - _imageSize / 2, ((box.boxCenterY - _imageSize / 2 + _imageSize) * percent3) - _imageSize);
    [_imageMusic setFrame:frame3];
    [_imageMusic renderInContext:context];

    if (_isDropOutOverFlow) {
        frame1.origin = CGPointMake(width / 2 - _imageSize / 2, ((box.boxCenterY - _imageSize / 2)));
        [_imageMoive setFrame:frame1];
        [_imageMoive renderInContext:context];

        frame2.origin = CGPointMake(width / 2 - _imageSize / 2, ((box.boxCenterY - _imageSize / 2)));
        [_imageFile setFrame:frame2];
        [_imageFile renderInContext:context];

        frame3.origin = CGPointMake(width / 2 - _imageSize / 2, ((box.boxCenterY - _imageSize / 2)));
        [_imageMusic setFrame:frame3];
        [_imageMusic renderInContext:context];
    }
    CGContextRestoreGState(context);
}
@end
