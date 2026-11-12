//
//  CYLRefreshAutoNormalFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshAutoNormalFooter.h"
#import "NSBundle+CYLRefresh.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"
#import "UIScrollView+CYLRefresh.h"

@interface CYLRefreshAutoNormalFooter()
@property (weak, nonatomic) UIImageView *cyl_noMoreDataImageView;
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation CYLRefreshAutoNormalFooter
#pragma mark - 懒加载子控件
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

    if (self.loadingView.constraints.count) return;

    // 圈圈
    CGFloat loadingCenterX = self.cyl_w * 0.5;
    if (!self.isRefreshingTitleHidden) {
        loadingCenterX -= self.stateLabel.cyl_textWidth * 0.5 + self.labelLeftInset;
    }
    CGFloat loadingCenterY = self.cyl_h * 0.5;
    self.loadingView.center = CGPointMake(loadingCenterX, loadingCenterY);
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState
    [self cyl_updateNoMoreDataImage];

    // 根据状态做事情
    if (state == CYLRefreshStateNoMoreData || state == CYLRefreshStateIdle) {
        [self.loadingView stopAnimating];
    } else if (state == CYLRefreshStateRefreshing) {
        [self.loadingView startAnimating];
    }
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
    CGSize size = imageView.image.size;
    imageView.cyl_size = size;
    CGFloat centerX = self.cyl_w * 0.5;
    if (!self.stateLabel.hidden) centerX -= self.labelLeftInset + self.stateLabel.cyl_textWidth * 0.5;
    imageView.center = CGPointMake(centerX, self.cyl_h * 0.5);
}

@end
