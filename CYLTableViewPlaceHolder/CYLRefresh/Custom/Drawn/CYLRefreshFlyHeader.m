//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshFlyHeader.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshFlyHeader.h"

#import "CYLRefreshFlyView.h"
#import "CYLRefreshMountainView.h"

#define FLOAT_VIEW_SIZE 50
#define RGB(rgb)[UIColor colorWithRed:((float)((rgb&0xFF0000)>> 16))/ 255.0 green:((float)((rgb&0x00FF00)>> 8))/ 255.0 blue: ((float)(rgb&0x0000FF))/ 255.0 alpha:1]

@interface CYLRefreshFlyHeader ()<CAAnimationDelegate>

/// [EN] The permanent top inset this header added. [CN] 本刷新头加上的常驻顶部 inset。
@property (nonatomic, assign) CGFloat cyl_addedInset;
/// [EN] The fixed open height; the frame grows past it with the pull. [CN] 固定的展开高度；frame 随下拉超过它。
@property (nonatomic, assign) CGFloat cyl_openHeight;
@property (nonatomic, strong) UIView *floatView;
@property (nonatomic, strong) CYLRefreshFlyView *flyView;
@property (nonatomic, strong) CYLRefreshMountainView *mountainView;

@end

@implementation CYLRefreshFlyHeader

- (CGFloat)expandHeight {
    return self.cyl_openHeight > 0 ? self.cyl_openHeight : 150;
}

- (void)setUpComponent {
    [self setCyl_openHeight:150];
    [self setHeight:150];
    [self setMountain:[CYLRefreshMountainView new]];
    [self setFloatView:[UIView new]];
    [self setFlyView:[CYLRefreshFlyView new]];
    // [EN] Always open: the scene stays above the list, so refreshing does not push the content further.
    // [CN] 常态展开：场景一直显示在列表上方，因此刷新时不再把内容往下推。
    [self setAddsRefreshingInset:NO];
    [super setUpComponent];
    
    [self setTriggerRate:0.5];
    [self setColorPrimary:RGB(0x33aaff)];
    [self setColorAccent:UIColor.whiteColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.mountainView setFrame:self.bounds];
    [self.floatView setCenter:CGPointMake(FLOAT_VIEW_SIZE*3/4, self.frame.size.height)];
    if (!self.isRefreshing) {
        [self.flyView setCenter:CGPointMake(FLOAT_VIEW_SIZE*3/4, self.frame.size.height)];
    }
}

- (void)setFlyView:(CYLRefreshFlyView *)flyView {
    _flyView = flyView;
    [self addSubview:flyView];
}

- (void)setFloatView:(UIView *)floatView {
    _floatView = floatView;
    [floatView setFrame:CGRectMake(0, 0, FLOAT_VIEW_SIZE, FLOAT_VIEW_SIZE)];
    [floatView.layer setCornerRadius:FLOAT_VIEW_SIZE/2];
    [self addSubview:floatView];
}

- (void)setMountain:(CYLRefreshMountainView *)mountainView {
    _mountainView = mountainView;
    [self addSubview:mountainView];
}

/**
 * 颜色绑定
 */
- (void)setColorPrimary:(UIColor *)colorPrimary {
    [super setColorPrimary:colorPrimary];
    [self.floatView setBackgroundColor:colorPrimary];
    [self.mountainView setColorPrimary:colorPrimary];
}

/**
 * 颜色绑定
 */
- (void)setColorAccent:(UIColor *)colorAccent {
    [super setColorAccent:colorAccent];
    [self.flyView setColorAccent:colorAccent];
}

/**
 * [EN] Always open: attaching adds the open height to the top inset once, detaching removes it.
 * [CN] 常态展开：挂上时把展开高度加到顶部 inset 一次，离开时移除。
 */
- (void)scrollView:(UIScrollView *)scrollView attached:(BOOL)attach {
    [super scrollView:scrollView attached:attach];
    if (attach && self.cyl_addedInset <= 0) {
        self.cyl_addedInset = self.expandHeight;
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top += self.cyl_addedInset;
        scrollView.contentInset = inset;
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - self.cyl_addedInset);
    } else if (!attach && self.cyl_addedInset > 0) {
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top -= self.cyl_addedInset;
        scrollView.contentInset = inset;
        self.cyl_addedInset = 0;
    }
}

/**
 * [EN] The scene fills the open area plus the pull. [CN] 场景铺满展开区域加上下拉距离。
 */
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    CGFloat height = self.expandHeight + self.dragOffset;
    if (fabs(self.frame.size.height - height) > 0.25 || fabs(self.frame.origin.y + height) > 0.25) {
        self.frame = CGRectMake(self.frame.origin.x, -height - self.ignoredScrollViewContentInsetTop, self.frame.size.width, height);
    }
}

- (void)placeSubviews {
    [super placeSubviews];
    CGFloat height = self.expandHeight + self.dragOffset;
    self.frame = CGRectMake(self.frame.origin.x, -height - self.ignoredScrollViewContentInsetTop, self.frame.size.width, height);
}

/**
 * 下拉时候，根据偏移量改变 背景高度，和纸飞机角度
 */
- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging {
    [self.mountainView onScrollingWithOffset:offset percent:percent];
    if (!self.isRefreshing) {
        percent = offset / self.expandHeight;
        [self.flyView setTransform:CGAffineTransformMakeRotation(-percent*3.1415926/4)];
    }
}

/**
 * 用户松手，执行飞机飞出动画
 */
- (void)onStartAnimationWhenRealeasing {
    
    self.flyView.transform = CGAffineTransformIdentity;
    
    CGPoint end = CGPointMake(self.width + FLOAT_VIEW_SIZE / 2, FLOAT_VIEW_SIZE / 4);
    UIBezierPath* path = UIBezierPath.bezierPath;
    [path moveToPoint: CGPointMake(FLOAT_VIEW_SIZE*3/4, self.expandHeight + self.dragOffset)];
    [path addQuadCurveToPoint:end controlPoint:CGPointMake(0, 0)];
    
    CAKeyframeAnimation *aniFly = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    aniFly.path = path.CGPath;
    aniFly.calculationMode = kCAAnimationPaced;
    aniFly.rotationMode = kCAAnimationRotateAuto;
    
    CABasicAnimation *aniScale = [CABasicAnimation animationWithKeyPath:@"transform"];
    aniScale.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    aniScale.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.2, 1)];
    
    CAAnimationGroup *aniGroup = [[CAAnimationGroup alloc] init];
    aniGroup.animations = @[aniScale, aniFly];
    aniGroup.duration = 1.5f;
    aniGroup.fillMode = kCAFillModeForwards;
    aniGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.flyView.layer addAnimation:aniGroup forKey:@"fly"];
    [self.flyView setCenter:end];
}

/**
 * 用户关闭刷新，执行飞机飞回动画
 */
- (void)finishRefreshWithSuccess:(BOOL)success {
    [super finishRefreshWithSuccess:success];
    
    CGSize size = self.frame.size;
    
    CGPoint p1 = CGPointMake(-FLOAT_VIEW_SIZE, size.height - FLOAT_VIEW_SIZE);
    CGPoint p2 = CGPointMake(-FLOAT_VIEW_SIZE, size.height);
    CGPoint end = CGPointMake(FLOAT_VIEW_SIZE*3/4, self.frame.size.height);
    UIBezierPath* path = UIBezierPath.bezierPath;
    [path moveToPoint: self.flyView.center];
    [path addQuadCurveToPoint:p1 controlPoint:CGPointMake(size.width, size.height - FLOAT_VIEW_SIZE)];
    [path addQuadCurveToPoint:end controlPoint: p2];
    
    CAKeyframeAnimation *aniFly = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    aniFly.path = path.CGPath;
    aniFly.calculationMode = kCAAnimationPaced;
    aniFly.rotationMode = kCAAnimationRotateAuto;
    
    CABasicAnimation *aniScale = [CABasicAnimation animationWithKeyPath:@"transform"];
    aniScale.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.2, 1)];
    aniScale.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    CAAnimationGroup *aniGroup = [[CAAnimationGroup alloc] init];
    aniGroup.animations = @[aniScale, aniFly];
    aniGroup.duration = 1.5f;
    aniGroup.delegate = self;
    aniGroup.fillMode = kCAFillModeForwards;
    aniGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.flyView.layer addAnimation:aniGroup forKey:@"back"];
}

/**
 * 关闭刷新，纸飞机飞回动画结束，需要通知父类处理
 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [self.flyView setCenter:CGPointMake(FLOAT_VIEW_SIZE*3/4, self.frame.size.height)];
    }
}


//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    if (!self.attached) {
//        [self adjustInset:self.scrollView expand:TRUE];
//        [self setAttached:TRUE];
//    }
//}


@end
