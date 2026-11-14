//
//  CYLRefreshBackNormalFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshBackNormalFooter.h"
#import "NSBundle+CYLRefresh.h"
#import "UIView+CYLExtension.h"

@interface CYLRefreshBackNormalFooter()
{
    __unsafe_unretained UIImageView *_arrowView;
}
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) UIImageView *cyl_noMoreDataImageView;
@end

@implementation CYLRefreshBackNormalFooter
#pragma mark - 懒加载子控件
- (UIImageView *)arrowView
{
    if (!_arrowView) {
        // [EN] System image view: MJRefresh's original arrow, kept unchanged by the owner's decision (the arrow controls keep
        //      MJRefresh's arrow logic and rotation), so CYLPlaceholderView is not used here.
        // [CN] 系统图片视图：MJRefresh 原有的箭头，按维护者决定保持原样（箭头控件保留 MJRefresh 的箭头逻辑与旋转），因此这里不使用 CYLPlaceholderView。
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[NSBundle cyl_arrowImage]];
        [self addSubview:_arrowView = arrowView];
    }
    return _arrowView;
}


- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:_activityIndicatorViewStyle];
        loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    _activityIndicatorViewStyle = activityIndicatorViewStyle;

    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    [self setNeedsLayout];
}
#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        _activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
        return;
    }
#endif

    _activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}

- (void)placeSubviews
{
    [super placeSubviews];
    [self cyl_placeNoMoreDataImage];

    // 箭头的中心点
    CGFloat arrowCenterX = self.cyl_w * 0.5;
    if (!self.stateLabel.hidden) {
        arrowCenterX -= self.labelLeftInset + self.stateLabel.cyl_textWidth * 0.5;
    }
    CGFloat arrowCenterY = self.cyl_h * 0.5;
    CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);

    // 箭头
    if (self.arrowView.constraints.count == 0) {
        BOOL customSize = self.iconSize.width > 0 && self.iconSize.height > 0;
        self.arrowView.cyl_size = customSize ? self.iconSize : self.arrowView.image.size;
        self.arrowView.center = arrowCenter;
    }

    // 圈圈
    if (self.loadingView.constraints.count == 0) {
        self.loadingView.center = arrowCenter;
    }

    self.arrowView.tintColor = self.stateLabel.textColor;
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState
    [self cyl_updateNoMoreDataImage];

    // 根据状态做事情
    if (state == CYLRefreshStateIdle) {
        if (oldState == CYLRefreshStateRefreshing) {
            self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
            [UIView animateWithDuration:self.slowAnimationDuration animations:^{
                self.loadingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                // 防止动画结束后，状态已经不是CYLRefreshStateIdle
                if (self.state != CYLRefreshStateIdle) return;

                self.loadingView.alpha = 1.0;
                [self.loadingView stopAnimating];

                self.arrowView.hidden = NO;
            }];
        } else {
            self.arrowView.hidden = NO;
            [self.loadingView stopAnimating];
            [UIView animateWithDuration:self.fastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
            }];
        }
    } else if (state == CYLRefreshStatePulling) {
        self.arrowView.hidden = NO;
        [self.loadingView stopAnimating];
        [UIView animateWithDuration:self.fastAnimationDuration animations:^{
            self.arrowView.transform = CGAffineTransformIdentity;
        }];
    } else if (state == CYLRefreshStateRefreshing) {
        self.arrowView.hidden = YES;
        [self.loadingView startAnimating];
    } else if (state == CYLRefreshStateNoMoreData) {
        self.arrowView.hidden = YES;
        [self.loadingView stopAnimating];
    }
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return [super.flipsHorizontallyInOppositeLayoutDirectionViews arrayByAddingObjectsFromArray:@[
        self.arrowView
    ]];
}


#pragma mark - No more data image

- (void)setNoMoreDataImage:(UIImage *)noMoreDataImage
{
    _noMoreDataImage = noMoreDataImage;
    [self cyl_updateNoMoreDataImage];
}

/// [EN] Shows noMoreDataImage beside the text only in the no-more-data state. [CN] 仅在无更多数据状态时，在文字旁显示 noMoreDataImage。
- (void)cyl_updateNoMoreDataImage
{
    BOOL show = self.noMoreDataImage && self.state == CYLRefreshStateNoMoreData;
    if (show && !self.cyl_noMoreDataImageView) {
        // [EN] A system UIImageView, not CYLPlaceholderView: it sits beside stateLabel in place of the system
        //      arrow / spinner views of this classic footer and shows one small image with no title.
        // [CN] 用系统 UIImageView 而不是 CYLPlaceholderView：它代替经典刷新尾的系统箭头 / 菊花，放在 stateLabel 旁边，只显示一张小图、没有标题。
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.isAccessibilityElement = NO;
        [self addSubview:imageView];
        self.cyl_noMoreDataImageView = imageView;
    }
    self.cyl_noMoreDataImageView.image = self.noMoreDataImage;
    self.cyl_noMoreDataImageView.hidden = !show;
    [self setNeedsLayout];
}

- (void)cyl_placeNoMoreDataImage
{
    UIImageView *imageView = self.cyl_noMoreDataImageView;
    if (!imageView || imageView.hidden) return;
    CGSize size = (self.iconSize.width > 0 && self.iconSize.height > 0) ? self.iconSize : imageView.image.size;
    imageView.cyl_size = size;
    CGFloat centerX = self.cyl_w * 0.5;
    if (!self.stateLabel.hidden) centerX -= self.labelLeftInset + self.stateLabel.cyl_textWidth * 0.5;
    imageView.center = CGPointMake(centerX, self.cyl_h * 0.5);
}

- (void)setIconSize:(CGSize)iconSize
{
    _iconSize = iconSize;
    [self setNeedsLayout];
}

@end
