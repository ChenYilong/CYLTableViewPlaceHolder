//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshPhoenixHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

//
//  CYLRefreshPhoenixHeader.m
//  Refresh
//
//  Created by Teeyun on 2020/9/15.
//  Copyright © 2020 Teeyun. All rights reserved.
//

#import "CYLRefreshPhoenixHeader.h"

#import "CYLRefreshValueAnimator.h"
#import "CYLRefreshVectorImage.h"

#define PATH_TWON_1 @"M2,415a35 35,0,0,1,50 -40a50 50,0,0,1,40 -40a40 40,0,0,1,72 -18a30,30,0,0,1,26,-3a30,30,0,0,1,38,-15a40,40,0,0,1,75,-6a40,40,0,0,1,40,20a30,30,0,0,1,20,5a40,40,0,0,1,55,0a30,30,0,0,1,12,-2a35,35,0,0,1,67,5a50,50,0,0,1,50,20L1400,300a40,40,0,0,1,45,20a20,20,0,0,1,15,2a30,30,0,0,1,50,-2a20,20,0,0,1,20,-7a30,30,0,0,1,40,-17a40,40,0,0,1,75,5a30,30,0,0,1,40,15a20,20,0,0,1,22,3a40,40,0,0,1,72,15a55,55,0,0,1,40,45a32,32,0,0,1,50,35"
#define PATH_TWON_2 @"M2,415a35 35,0,0,1,50 -30a50 50,0,0,1,40 -40a40 40,0,0,1,72 -18a30,30,0,0,1,26,-3a30,30,0,0,1,38,-15a40,40,0,0,1,75,-6a40,40,0,0,1,40,20a30,30,0,0,1,20,5a40,40,0,0,1,55,0a30,30,0,0,1,12,-2a35,35,0,0,1,67,5a50,50,0,0,1,50,20L1400,307a40,40,0,0,1,45,20a20,20,0,0,1,15,2a30,30,0,0,1,50,-2a20,20,0,0,1,20,-7a30,30,0,0,1,40,-17a40,40,0,0,1,75,5a30,30,0,0,1,40,15a20,20,0,0,1,22,3a40,40,0,0,1,72,15a55,55,0,0,1,40,45a32,32,0,0,1,50,28"
#define PATH_TWON_3 @"M2,415a35 35,0,0,1,50 -20a50 50,0,0,1,40 -40a40 40,0,0,1,72 -18a30,30,0,0,1,26,-3a30,30,0,0,1,38,-15a40,40,0,0,1,75,-6a40,40,0,0,1,40,20a30,30,0,0,1,20,5a40,40,0,0,1,55,0a30,30,0,0,1,12,-2a35,35,0,0,1,67,5a50,50,0,0,1,50,20L1400,317a40,40,0,0,1,45,20a20,20,0,0,1,15,2a30,30,0,0,1,50,-2a20,20,0,0,1,20,-7a30,30,0,0,1,40,-17a40,40,0,0,1,75,5a30,30,0,0,1,40,15a20,20,0,0,1,22,3a40,40,0,0,1,72,15a55,55,0,0,1,40,45a32,32,0,0,1,50,18"

#define PATH_TWON_4 @"M 520,270h250v-30h110v170h-360zM1285,240l55,-50l60,50v170h-115z"
#define PATH_TWON_5 @"M515,265h250v-30h120v180h-370M525,275v130h240v-130zM525,290h240v10h-240zM775,245v160h100v-160zM590,300h3v50h-3zM605,335h55v3h-55zM675,335h10v3h-10zM700,335h50v3h-50zM525,385h80v3h-80zM630,385h135v3h-135zM605,370h3v35h-3zM625,370h3v35h-3zM545,270h2v20h-2zM565,270h2v20h-2zM585,270h2v20h-2zM605,270h2v20h-2zM625,270h2v20h-2zM645,270h2v20h-2zM665,270h2v20h-2zM685,270h2v20h-2zM705,270h2v20h-2zM725,270h2v20h-2zM745,270h2v20h-2zM770,270h110v2h-110zM770,280h110v2h-110zM805,240h2v40h-2zM840,240h2v40h-2zM785,240h2v30h-2zM795,240h2v30h-2zM815,240h2v30h-2zM827,240h2v30h-2zM851,240h2v30h-2zM862,240h2v30h-2zM795,290h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM837,290h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM795,340h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM837,340h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM1280,240l60,-55l65,55v175h-125zM1300,235h85l-45,-38zM1290,245v160h105v-160zM1290,270h105v3h-105zM1290,280h105v3h-105zM1310,305h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM1355,305h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM1355,350h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM1305,350h30v60h-30m5,-55v60h20v-60m-15,20h3v3h-3m-5,10h20v3h-20m0,5h20v3h-20z"

#define PATH_TWON_6 @"M495,375q4,-30 30,-30h238v30"
#define PATH_TWON_7 @"M500,370q3,-14 17,-17h245v17"

#define PATH_TWON_8 @"M1045,205h100v-65h120v65h25v210h-245z"
#define PATH_TWON_9 @"M1045,205h100v-65h120v65h25v210h-245zM1055,215v190h225v-190zM1155,150v55h100v-55zM1055,232h225v8h-225zM1055,375h225v10h-225zM1055,260h225v4h-225zM1055,285h225v4h-225zM1055,310h225v4h-225zM1055,332h225v4h-225zM1055,355h225v4h-225zM1075,225h4v150h-4zM1100,225h4v150h-4zM1125,225h4v150h-4zM1150,225h4v150h-4zM1175,225h4v150h-4zM1200,225h4v150h-4zM1225,225h4v150h-4zM1250,225h4v150h-4zM1180,195a 25 25 ,0,0,1, 50 0v10h-50m10,0h30v-10a15 15,0,0,0 -30,0zM1150,160h105v5h-105z"

#define PATH_TWON_A @"M875,40h180v375h-180zM915,0h105v50h-105z"
#define PATH_TWON_B @"M925,5h10v35h-10zM940,5h10v35h-10zM955,5h10v35h-10zM970,5h10v35h-10zM985,5h10v35h-10zM1000,5h10v35h-10zM885,50h160v355h-160z"
#define PATH_TWON_C @"M900,70h5v320h-5zM1025,70h5v320h-5zM915,75h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,75h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,75h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,110h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,110h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,110h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,145h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,145h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,145h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,180h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,180h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,180h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,215h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,215h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,215h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,250h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,250h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,250h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,285h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,285h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,285h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,320h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,320h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,320h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,355h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,355h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,355h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15z"

#define PATH_SKY_1 @"M0,0L1600,0L1600,1040L0,1040z"
#define PATH_SKY_2 @"M437 373C395 373 366 405 361 433C341 433 317 449 313 472C292 469 255 478 255 520L0 520L0 524C0 524 174 524 261 524C259 486 289 474 318 479C321 458 337 440 365 438C374 405 399 378 441 378C476 378 513 405 517 448C553 450 567 475 570 497C581 501 587 509 588 524C637 523 735 524 735 524L735 520L593 520C592 509 589 500 575 493C572 470 555 445 522 444C517 402 478 372 442 373C440 373 439 373 437 373zM1208 392L1208 401L1241 401L1241 392L1208 392zM1280 392L1280 400L1428 400L1428 392L1280 392zM1118 475C1097 475 1077 485 1063 509C1041 491 1012 508 1012 535C988 547 988 576 988 576L852 576L852 580L992 580C992 580 991 550 1016 538C1015 511 1046 496 1065 518C1098 451 1178 484 1178 538C1207 553 1204 580 1204 580L1600 580L1600 576L1208 576C1208 576 1208 545 1184 535C1182 499 1150 474 1118 475zM184 608L184 612L328 612L328 608L184 608zM904 636L904 640L1016 640L1016 636L904 636zM1200 651L1200 656L1352 656L1352 651L1200 651zM412 656L412 664L564 664L564 656L412 656z"

#define PATH_SUN_1 @"M75 125a50 50 0 0 1 100 0a50 50 0 0 1 -100 0zM10 130a5 5 0 0 1 0 -10h40a5 5 0 0 1 0 10zM200 130a5 5 0 0 1 0 -10h40a5 5 0 0 1 0 10zM120 10a5 5 0 0 1 10 0v40a5 5 0 0 1 -10 0zM120 200a5 5 0 0 1 10 0v40a5 5 0 0 1 -10 0zM23 72A5 5 0 0 1 28 63L63 84A5 5 0 0 1 58 92zM187 167A5 5 0 0 1 192 158L227 178A5 5 0 0 1 222 187zM63 28A5 5 0 0 1 72 23L92 58A5 5 0 0 1 83 63zM158 193A5 5 0 0 1 167 188L187 222A5 5 0 0 1 178 227zM72 227A5 5 0 0 1 63 222L83 187A5 5 0 0 1 92 193zM167 63A5 5 0 0 1 158 58L178 23A5 5 0 0 1 187 28zM28 187A5 5 0 0 1 23 178L58 158A5 5 0 0 1 63 167zM193 92A5 5 0 0 1 187 83L222 63A5 5 0 0 1 227 72z"
#define PATH_SUN_2 @"M85,125 a40,40,0,0,1,80,0 a40,40,0,0,1,-80,0"


#define ANIMATION_DURATION 1000
#define SUN_INITIAL_ROTATE_GROWTH 1.2

@interface CYLRefreshPhoenixHeader ()

@property (nonatomic, strong) CYLRefreshValueAnimator *animatorRefreshing;
@property (nonatomic, strong) CYLRefreshVectorImage *imageSun;
@property (nonatomic, strong) CYLRefreshVectorImage *imageSky;
@property (nonatomic, strong) CYLRefreshVectorImage *imageTown;

@property (nonatomic, assign) CGFloat rotate;
@property (nonatomic, assign) CGFloat sunSize;

@end

@implementation CYLRefreshPhoenixHeader

#pragma mark - Init

/**
 * 初始化参数
 */
- (void)setUpComponent {
    [super setUpComponent];

    self.height = 100;
    self.sunSize = 40;
    
    CYLRefreshVectorImage* imageTown = [CYLRefreshVectorImage new];
    [imageTown parserPaths:@[
        PATH_TWON_1,PATH_TWON_2,PATH_TWON_3,PATH_TWON_4,
        PATH_TWON_5,PATH_TWON_6,PATH_TWON_7,PATH_TWON_8,
        PATH_TWON_9,PATH_TWON_A,PATH_TWON_B,PATH_TWON_C
    ]];
    [imageTown parserColors:@[
        [UIColor colorWithRed:0x67/255.0 green:0x98/255.0 blue:0x93/255.0 alpha:1],
        [UIColor colorWithRed:0x98/255.0 green:0xd2/255.0 blue:0xd0/255.0 alpha:1],
        [UIColor colorWithRed:0x69/255.0 green:0xb3/255.0 blue:0xaf/255.0 alpha:1],
        [UIColor colorWithRed:0xf2/255.0 green:0xeb/255.0 blue:0xe0/255.0 alpha:1],
        [UIColor colorWithRed:0x84/255.0 green:0x70/255.0 blue:0x79/255.0 alpha:1],
        [UIColor colorWithRed:0x36/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:1],
        [UIColor colorWithRed:0xb6/255.0 green:0x56/255.0 blue:0x49/255.0 alpha:1],
        [UIColor colorWithRed:0xaf/255.0 green:0xa6/255.0 blue:0x8b/255.0 alpha:1],
        [UIColor colorWithRed:0x43/255.0 green:0x43/255.0 blue:0x43/255.0 alpha:1],
        [UIColor colorWithRed:0x2b/255.0 green:0x42/255.0 blue:0x47/255.0 alpha:1],
        [UIColor colorWithRed:0x85/255.0 green:0xac/255.0 blue:0xbe/255.0 alpha:1],
        [UIColor colorWithRed:0x00/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:1],
    ]];

    CYLRefreshVectorImage* imageSky = [CYLRefreshVectorImage new];
    [imageSky parserPaths:@[PATH_SKY_1,PATH_SKY_2]];
    [imageSky parserColors:@[
        [UIColor colorWithRed:0x38/255.0 green:0xad/255.0 blue:0xc1/255.0 alpha:0xff/255.0],
        [UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0xff/255.0 alpha:0x88/255.0],
    ]];

    CYLRefreshVectorImage* imageSun = [CYLRefreshVectorImage new];
    [imageSun setSize:CGSizeMake(_sunSize, _sunSize)];
    [imageSun parserPaths:@[PATH_SUN_1,PATH_SUN_2]];
    [imageSun parserColors:@[
        [UIColor colorWithRed:0xfe/255.0 green:0xf9/255.0 blue:0xe8/255.0 alpha:1],
        [UIColor colorWithRed:0xf3/255.0 green:0xe5/255.0 blue:0x9c/255.0 alpha:1],
    ]];
    
    self.imageSky = imageSky;
    self.imageSun = imageSun;
    self.imageTown = imageTown;
    self.colorAccent = [UIColor whiteColor];
    self.colorPrimary = [UIColor colorWithRed:0x38/255.0 green:0xad/255.0 blue:0xc1/255.0 alpha:1];
    self.scrollMode = CYLRefreshScrollModeStretch;
}

- (void)setColorPrimary:(UIColor *)colorPrimary {
    [super setColorPrimary:colorPrimary];
    [self.imageSky parserColors:@[
        colorPrimary,
        [UIColor colorWithRed:0xf3/255.0 green:0xe5/255.0 blue:0x9c/255.0 alpha:1],
    ]];
}

#pragma mark - Override

- (void)scrollView:(UIScrollView *)scrollView attached:(BOOL)attach {
    [super scrollView:scrollView attached:attach];
    
    CGFloat width = scrollView.frame.size.width;
    [self.imageSky setSize:CGSizeMake(width, width*_imageSky.size.height/_imageSky.size.width)];
    [self.imageTown setSize:CGSizeMake(width, width*_imageTown.size.height/_imageTown.size.width)];
}

- (void)scrollView:(UIScrollView *)scrollView didScroll:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL) isDragging {
    [super scrollView:scrollView didScroll:offset percent:percent drag:isDragging];
    [self setRotate:percent];
    [self setNeedsDisplay];
}


//- (void)scrollView:(UIScrollView *)scrollView didChange:(CYLRefreshPhase)old status:(CYLRefreshPhase)status {
- (void)onStatus:(CYLRefreshPhase)old changed:(CYLRefreshPhase)status {
//    [super scrollView:scrollView didChange:old status:status];
    [super onStatus:old changed:status];
    
    if (old == CYLRefreshPhaseRefreshing) {
        [self.animatorRefreshing stop];
//        self.animatorFinish = [CYLRefreshValueAnimator newWithTarget:self selector:@selector(animatorRunning:)];
//        self.animatorFinish.duration = self.finishDuration;
//        self.animatorFinish.repeatMode = AnimatorRepeatModeReverse;
//        self.animatorFinish.interpolator = AnimatorInterpolatorAccelerateDecelerate;
//        [self.animatorFinish start];
    } else if (status == CYLRefreshPhaseRefreshing) {
        self.animatorRefreshing = [CYLRefreshValueAnimator newWithTarget:self selector:@selector(animatorRunning:)];
        self.animatorRefreshing.repeatCount = INFINITY;
        self.animatorRefreshing.duration = ANIMATION_DURATION / 1000.0;
        self.animatorRefreshing.repeatMode = AnimatorRepeatModeRestart;
        self.animatorRefreshing.interpolator = AnimatorInterpolatorLinear;
        [self.animatorRefreshing start];
    }
}

- (void)animatorRunning:(CYLRefreshValueAnimator*) animator {
    if (animator == self.animatorRefreshing) {
        self.rotate = animator.value;
        [self setNeedsDisplay];
    }
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

    [self drawSky:context w:width h:height p:percent];
    [self drawSun:context w:width h:height p:percent];
    [self drawTown:context w:width h:height p:percent];
    
    if (height <= 0) {
        NSLog(@"%@.drawRect.height=%@ !", self.class, @(height));
    }
}

- (void)drawSky:(CGContextRef) context w:(CGFloat) width h:(CGFloat) height p:(CGFloat) percent {
    
    CYLRefreshVectorImage* imageSky = self.imageSky;

    CGFloat bWidth = imageSky.size.width;
    CGFloat bHeight = imageSky.size.height;
    CGFloat scale = width / bWidth;
    CGFloat offsetX = 0;
    CGFloat offsetY = height / 2 - bHeight / 2;
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, offsetX, offsetY);
    CGContextScaleCTM(context, scale, scale);
    
    [imageSky renderInContext:context];
    
    CGContextRestoreGState(context);
}
- (void)drawSun:(CGContextRef) context w:(CGFloat) width h:(CGFloat) height p:(CGFloat) percent {
    
    CGFloat expandHeight = self.expandHeight;
    CYLRefreshVectorImage* imageSun = self.imageSun;


    CGFloat mSunLeftOffset = 0.3 * width;
    CGFloat mSunTopOffset = (expandHeight * 0.1);

    CGFloat sunRadius = _sunSize / 2.0;
    CGFloat offsetX = mSunLeftOffset + sunRadius;
    CGFloat offsetY = mSunTopOffset + (expandHeight / 2) * (1.0 - MIN(percent, 1)); // Move the sun up

    CGFloat bWidth = imageSun.size.width;
    CGFloat scale = _sunSize / bWidth;

    if (percent > 1) {
        scale = MAX(scale * (1.0 - 0.5 * (percent - 1)), 0.45);
    }

    CGFloat rotate = _rotate * 360;
    if (_animatorRefreshing.isRunning) {
        rotate *= -1;
    } else {
        rotate *= SUN_INITIAL_ROTATE_GROWTH;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, offsetX, offsetY);
    CGContextScaleCTM(context, scale, scale);

    CGContextTranslateCTM(context, sunRadius, sunRadius);
    CGContextRotateCTM(context, rotate * 3.1415926 / 180);
    CGContextTranslateCTM(context, -sunRadius, -sunRadius);
    
    [imageSun renderInContext:context];
    
    CGContextRestoreGState(context);
}
- (void)drawTown:(CGContextRef) context w:(CGFloat) width h:(CGFloat) height p:(CGFloat) percent {
    
    CGFloat expandHeight = self.expandHeight;
    CYLRefreshVectorImage* imageTwon = self.imageTown;

    CGFloat bWidth = imageTwon.size.width;
    CGFloat bHeight = imageTwon.size.height;
    CGFloat scale = width / bWidth;
    CGFloat amplification = (0.3 * MAX(percent - 1, 0) + 1);
    CGFloat offsetX = width / 2 - (int) (width * amplification) / 2;
    CGFloat offsetY = expandHeight * 0.1 * percent;
    
    scale = amplification * scale;

    if (offsetY + bHeight * scale < height) {
        offsetY = height - bHeight * scale;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, offsetX, offsetY);
    CGContextScaleCTM(context, scale, scale);
    
    [imageTwon renderInContext:context];
    
    CGContextRestoreGState(context);
}


@end
