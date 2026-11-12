//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshDeliveryHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshDeliveryHeader.h"

#import "CYLRefreshValueAnimator.h"
#import "CYLRefreshVectorImage.h"

#define PATH_UMBRELLA_1 @"M113.91,328.86 L119.02,331.02 134.86,359.02 133.99,359.02ZM2.18,144.52c-3.67,-76.84 49.96,-122.23 96.3,-134.98 6.03,0.21 7.57,0.59 13.23,3.9 0.19,1.7 0.25,2.17 -0.41,3.98 -47.88,37.64 -55.13,79.65 -68.07,137.22C37.56,194.8 16.18,191.4 2.18,144.52Z"
#define PATH_UMBRELLA_2 @"m133.99,359.02 l-0.71,-26.66 2.6,0.26 -1.02,26.4zM119.02,331.02c-3.39,-0.99 -8.53,-3.03 -8.72,-6.61 0,-0.81 -2.02,-3.63 -4.49,-6.27C88.05,299.71 7.29,218.46 2.18,144.52c17.67,43.57 33.35,45.33 41.05,10.12 0.13,-70.78 33.78,-125.48 68.07,-137.22 2.34,3.33 4.11,4.81 8.14,7.8 -22.02,65.69 -23.25,84.11 -24.14,150.23 -8.68,29.57 -37.44,32.81 -52.07,-20.81 14.12,64.06 31.66,101.57 60.64,147.13 6.2,8.38 14.74,18.4 15.15,29.25zM98.48,9.54c4.59,-1.5 17.8,-4.6 33.87,-5.07 0.95,0.95 1.38,1.91 1.14,2.91 -8.81,1.34 -16.36,3.1 -21.78,6.06 -2.53,-1.27 -7.82,-3.26 -13.23,-3.9z"
#define PATH_UMBRELLA_3 @"m119.02,331.02c-1.29,-7.57 -4.22,-12.31 -6.54,-15.79 -36.86,-54.89 -63.48,-98.79 -69.25,-160.59 19.89,45.9 41.27,48.65 52.07,20.81 -1.95,-52.55 -8.04,-91.2 24.14,-150.23 10.47,-0.28 16.85,0.17 30.66,-0.34 40.19,60.54 24.92,135.95 22.16,149.57 -13.9,53.18 -66.91,34.12 -76.96,1 11.54,50.55 20.28,89.27 30,135.97 4.12,10.03 5.37,10.37 5.06,21.35 -2.82,-0.22 -8.22,-1.01 -11.35,-1.75z"
#define PATH_UMBRELLA_4 @"m172.27,174.45c4.91,-51.6 -1.8,-105.99 -22.16,-149.57 2.51,-3.42 3.25,-4.36 6.59,-6.04 47.91,22.5 77.5,62.66 68.9,139.94 -16.53,49.7 -45.39,52.78 -53.33,15.68zM154.36,13.39c-6.65,-2.73 -11.65,-4.27 -20.87,-6.01 -0.25,-1.02 -0.71,-2.21 -1.14,-2.91 16.31,-0.22 27.58,2.29 37.27,4.82 -5.49,0.42 -11.39,1.87 -15.26,4.11z"
#define PATH_UMBRELLA_5 @"m133.99,359.02 l14.98,-28.13 2.24,-0.75 -16.34,28.88zM141.15,332.65c0.01,-11.71 2.3,-14.29 4.13,-21.52 11.82,-46.68 16.09,-77.45 26.98,-136.68 12.18,38.55 37.7,23.31 53.33,-15.68 -4.01,53.72 -43.68,121.28 -68.8,155.25 -6.17,9.5 -8.27,16.22 -5.59,16.12 -3.69,1.47 -6.24,2.05 -10.05,2.51z"
#define PATH_UMBRELLA_6 @"m225.59,158.77c1.61,-52.44 -22.26,-117.1 -68.9,-139.94 -1.48,-2.24 -1.63,-2.16 -2.34,-5.44 3.7,-3.42 9.42,-4.82 15.26,-4.11 48.59,9.81 103.07,66.75 96.62,132.26 -9.7,45.68 -35.45,51.78 -40.64,17.24z"
#define PATH_UMBRELLA_7 @"m156.48,313.99c32.9,-59.38 53.82,-87.19 69.12,-155.22 12.23,38.4 28.73,22.32 40.64,-17.24 -2.11,50.59 -43.12,112.84 -99.62,171.38 -4.57,4.73 -8.31,9.42 -8.31,10.4 -0,2.28 -3.52,5.43 -7.1,6.82 -4.65,0.73 2.08,-12.86 5.27,-16.15z"
#define PATH_UMBRELLA_8 @"M130.37,332.77C129.51,321.51 128.56,320.77 125.3,311.42 113.97,281.37 101.34,222.24 95.3,175.45c16.48,38.98 60.02,33.39 76.96,-1 -5.91,58.92 -10.85,88.45 -27.42,138.74 -1.67,6.75 -2.67,11.63 -3.7,19.46 -2.94,0.45 -6.48,0.45 -10.78,0.12zM119.44,25.22c-3.52,-1.25 -6.98,-3.72 -8.14,-7.8 -0.44,-1.53 -0.24,-2.79 0.41,-3.98 2.48,-4.55 14.53,-6.26 21.78,-6.06 5.29,0.15 14.87,0.72 20.87,6.01 1.82,1.61 2.74,3.95 2.34,5.44 -0.76,2.83 -4.21,5.19 -6.59,6.04 -7.49,2.68 -22.62,3.2 -30.66,0.34z"

#define PATH_BOX_1 @"M0,17.5 L3.1,29.8 2.9,76.4 47.5,93 92.8,76.2V29.9L94.9,18.1 47.4,0.5Z"
#define PATH_BOX_2 @"M3.1,29.8 L47.8,46.4 47.5,93 2.9,76.4ZM0,17.5 L47.9,35.4 47.8,46.4 0.2,28.8Z"
#define PATH_BOX_3 @"m56.5,17.8c0,2.1 -3.8,3.8 -8.5,3.8 -4.7,0 -8.5,-1.7 -8.5,-3.8 0,-2.1 3.8,-3.8 8.5,-3.8 4.7,0 8.5,1.7 8.5,3.8zM3.1,29.8 L3.1,34.7l44.7,16.9 0,-5.1z"
#define PATH_BOX_4 @"M47.9,35.4 L47.5,93 92.8,76.2V29.9l2.2,-0.8 0,-10.9z"
#define PATH_BOX_5 @"M82.6,80 L92.8,62.4 92.8,76.2ZM47.6,79.8 L59.8,88.4 47.5,93ZM47.8,46.4 L92.8,29.9 92.8,34.2 47.8,51.6Z"

#define PATH_CLOUD @[@"M63,0.1A22.6,22.4 0,0 0,42.1 14.2,17.3 17.3,0 0,0 30.9,10.2 17.3,17.3 0,0 0,13.7 25.8,8.8 8.8,0 0,0 8.7,24.2 8.8,8.8 0,0 0,0 32h99a7.9,7.9 0,0 0,0 -0.6,7.9 7.9,0 0,0 -7.9,-7.9 7.9,7.9 0,0 0,-5.8 2.6,22.6 22.4,0 0,0 0.3,-3.6A22.6,22.4 0,0 0,63 0.1Z"]

@interface CYLRefreshDeliveryHeader ()

@property (nonatomic, strong) CYLRefreshValueAnimator *animator;

@property (nonatomic, strong) CYLRefreshVectorImage *imageBox;
@property (nonatomic, strong) CYLRefreshVectorImage *imageCloud;
@property (nonatomic, strong) CYLRefreshVectorImage *imageUmbrella;

@property (nonatomic, assign) CGFloat cloud1x;
@property (nonatomic, assign) CGFloat cloud2x;
@property (nonatomic, assign) CGFloat cloud3x;
@property (nonatomic, assign) CGFloat appreciation;

@end

@implementation CYLRefreshDeliveryHeader

/**
 * 初始化参数
 */
- (void)setUpComponent {
    [super setUpComponent];
    
    CYLRefreshVectorImage* imageUmbrella = [CYLRefreshVectorImage new];
    [imageUmbrella parserPaths:@[
        PATH_UMBRELLA_1,PATH_UMBRELLA_2,PATH_UMBRELLA_3,PATH_UMBRELLA_4,
        PATH_UMBRELLA_5,PATH_UMBRELLA_6,PATH_UMBRELLA_7,PATH_UMBRELLA_8,
    ]];
    [imageUmbrella parserColors:@[
        [UIColor colorWithRed:0x92/255.0 green:0xdf/255.0 blue:0xeb/255.0 alpha:1],
        [UIColor colorWithRed:0x6d/255.0 green:0xd0/255.0 blue:0xe9/255.0 alpha:1],
        [UIColor colorWithRed:0x4f/255.0 green:0xc3/255.0 blue:0xe7/255.0 alpha:1],
        [UIColor colorWithRed:0x2f/255.0 green:0xb6/255.0 blue:0xe6/255.0 alpha:1],
        [UIColor colorWithRed:0x25/255.0 green:0xa9/255.0 blue:0xde/255.0 alpha:1],
        [UIColor colorWithRed:0x11/255.0 green:0xab/255.0 blue:0xe4/255.0 alpha:1],
        [UIColor colorWithRed:0x0e/255.0 green:0x9b/255.0 blue:0xd8/255.0 alpha:1],
        [UIColor colorWithRed:0x40/255.0 green:0xb7/255.0 blue:0xe1/255.0 alpha:1],
    ]];
    [imageUmbrella setGeometricWidth:200];
    
    CYLRefreshVectorImage* imageBox = [CYLRefreshVectorImage new];
    [imageBox parserPaths:@[
        PATH_BOX_1,PATH_BOX_2,PATH_BOX_3,PATH_BOX_4,PATH_BOX_5,
    ]];
    [imageBox parserColors:@[
        [UIColor colorWithRed:0xf8/255.0 green:0xb1/255.0 blue:0x47/255.0 alpha:1],
        [UIColor colorWithRed:0xf2/255.0 green:0x97/255.0 blue:0x3c/255.0 alpha:1],
        [UIColor colorWithRed:0xed/255.0 green:0x80/255.0 blue:0x30/255.0 alpha:1],
        [UIColor colorWithRed:0xfe/255.0 green:0xc0/255.0 blue:0x51/255.0 alpha:1],
        [UIColor colorWithRed:0xf7/255.0 green:0xad/255.0 blue:0x49/255.0 alpha:1],
    ]];
    [imageBox setGeometricWidth:50];

    CYLRefreshVectorImage* imageCloud = [CYLRefreshVectorImage new];
    [imageCloud parserPaths:PATH_CLOUD];
    [imageCloud parserColors:@[[UIColor whiteColor]]];
    [imageCloud setGeometricHeight:20];
    
    self.imageBox = imageBox;
    self.imageCloud = imageCloud;
    self.imageUmbrella = imageUmbrella;
    
    self.height = 150;
    self.triggerRate = 0.7;
    self.colorAccent =  [UIColor colorWithRed:0x6e/255.0 green:0xa9/255.0 blue:0xff/255.0 alpha:1];
    self.colorPrimary = [UIColor colorWithRed:0xf5/255.0 green:0xf5/255.0 blue:0xf5/255.0 alpha:1];
    self.scrollMode = CYLRefreshScrollModeStretch;
}

- (void)onAnimation:(CYLRefreshValueAnimator*) animator {
    if (self.status == CYLRefreshPhaseFinishing || self.status == CYLRefreshPhaseRefreshing) {
        [self calculateFrame:self.width];
    } else {
        [animator stop];
    }
}

- (void)calculateFrame:(CGFloat) width {
    CGFloat cloudWidth = _imageCloud.size.width;

    _cloud1x += 7;
    _cloud2x += 4;
    _cloud3x += 9;
    
    if (_cloud1x > width + cloudWidth) {
        _cloud1x = -cloudWidth;
    }
    if (_cloud2x > width + cloudWidth) {
        _cloud2x = -cloudWidth;
    }
    if (_cloud3x > width + cloudWidth) {
        _cloud3x = -cloudWidth;
    }
    _appreciation += 0.08;
    
    [self setNeedsDisplay];
}

#pragma mark - Override

- (void)scrollView:(UIScrollView *)scrollView didScroll:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL) isDragging {
    [super scrollView:scrollView didScroll:offset percent:percent drag:isDragging];

    if (self.status != CYLRefreshPhaseRefreshing) {
        [self.imageBox setOpacity:MAX(0.1, 1 - MAX(0, percent - 1))];
    }
    [self setNeedsDisplay];
}

//- (void)scrollView:(UIScrollView *)scrollView didChange:(CYLRefreshPhase)old status:(CYLRefreshPhase)status {
- (void)onStatus:(CYLRefreshPhase)old changed:(CYLRefreshPhase)status {
//    [super scrollView:scrollView didChange:old status:status];
    [super onStatus:old changed:status];
    if (status == CYLRefreshPhaseRefreshing) {
        [self.imageBox setOpacity:1];
        self.animator = [CYLRefreshValueAnimator newWithTarget:self selector:@selector(onAnimation:)];
        self.animator.repeatCount = INFINITY;
        self.animator.duration = 10.0;
        self.animator.repeatMode = AnimatorRepeatModeReverse;
        [self.animator start];
    } else if (status == CYLRefreshPhaseIdle) {
        _appreciation = 0;
        _cloud1x = _cloud2x = _cloud3x = -_imageCloud.size.width;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    const CGFloat width = self.width;
    const CGFloat height = self.dragOffset;
    const CGContextRef context = UIGraphicsGetCurrentContext();
    const CGFloat shake = (self.expandHeight / 13 * cos(_appreciation));
    
    [self.colorPrimary setFill];
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    [self drawCloud:context width:width];
    [self drawBox:context w:width h:height s:shake];
    [self drawUmbrella:context w:width h:height s:shake];
    
    if (height <= 0) {
        NSLog(@"%@.drawRect.height=%@ !", self.class, @(height));
    }
}

- (void)drawBox:(CGContextRef) context w:(CGFloat)width h:(CGFloat)height s:(CGFloat) shake {
    CGFloat widthBox = _imageBox.size.width;
    CGFloat heightBox = _imageBox.size.height;
    CGFloat heightExpand = self.expandHeight;
    CGFloat centerY = height - heightExpand / 2 + shake;
    CGFloat centerYBox = centerY + (heightExpand / 2 - heightBox) - MIN(heightExpand / 2 - heightBox, _appreciation * 100);
    [_imageBox moveTo:CGPointMake(width / 2 - widthBox / 2, centerYBox - heightBox / 4)];
    [_imageBox renderInContext:context];
}


- (void)drawUmbrella:(CGContextRef) context w:(CGFloat)width h:(CGFloat)height s:(CGFloat) shake {
    if (self.status == CYLRefreshPhaseRefreshing || self.status == CYLRefreshPhaseFinishing) {
        CGFloat expandHeight = self.expandHeight;
        CGFloat umbrellaHeight = _imageUmbrella.size.height;
        CGFloat umbrellaWidth = _imageUmbrella.size.width;
        CGFloat centerY = height - expandHeight / 2 + shake;
        CGFloat centerYUmbrella = centerY - expandHeight + MIN(expandHeight, (_appreciation * 100));
        [_imageUmbrella moveTo:CGPointMake(width / 2 - umbrellaWidth / 2, centerYUmbrella - umbrellaHeight)];
        [_imageUmbrella renderInContext:context];
    }
}

- (void)drawCloud:(CGContextRef) context width:(CGFloat)width {
    if (self.status == CYLRefreshPhaseRefreshing || self.status == CYLRefreshPhaseFinishing) {
        CGFloat height = self.expandHeight;
        CGFloat heightUmbrella = self.expandHeight;
    
        [_imageCloud moveTo:CGPointMake(_cloud1x, height / 3)];
        [_imageCloud renderInContext:context];
        [_imageCloud moveTo:CGPointMake(_cloud2x, height / 2)];
        [_imageCloud renderInContext:context];
        [_imageCloud moveTo:CGPointMake(_cloud3x, height * 2 / 3)];
        [_imageCloud renderInContext:context];
        
        
        CGContextTranslateCTM(context, width / 2, height / 2 - heightUmbrella);
        CGContextRotateCTM(context, sin(_appreciation) * 3.141592 * 5 / 180);
        CGContextTranslateCTM(context, -width / 2, heightUmbrella - height / 2);
    }
}

@end
