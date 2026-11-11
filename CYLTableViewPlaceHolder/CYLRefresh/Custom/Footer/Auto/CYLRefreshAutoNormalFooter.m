//
//  CYLRefreshAutoNormalFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshAutoNormalFooter.h"
#import "CYLRefreshIconView.h"
#import "NSBundle+CYLRefresh.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"
#import "UIScrollView+CYLRefresh.h"

@interface CYLRefreshAutoNormalFooter()
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

    if (self.loadingView.constraints.count) return;

    // 圈圈
    CGFloat loadingCenterX = self.cyl_w * 0.5;
    if (!self.isRefreshingTitleHidden) {
        loadingCenterX -= self.stateLabel.cyl_textWidth * 0.5 + self.labelLeftInset;
    }
    CGFloat loadingCenterY = self.cyl_h * 0.5;
    self.loadingView.center = CGPointMake(loadingCenterX, loadingCenterY);

    // [EN] An icon animation takes the spinner's place and, like it, shows only while loading.
    // [CN] 图标动画替换菊花，并与菊花一样只在加载时显示。
    CGPoint iconCenter = self.isRefreshingTitleHidden ? self.loadingView.center :
        [self cyl_iconCenterReplacingCenter:self.loadingView.center replacedWidth:CGRectGetWidth(self.loadingView.bounds)];
    [self cyl_placeIconViewAtCenter:iconCenter visible:self.state == CYLRefreshStateRefreshing
                     replacingViews:@[self.loadingView]];
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

    // 根据状态做事情
    if (state == CYLRefreshStateNoMoreData || state == CYLRefreshStateIdle) {
        [self.loadingView stopAnimating];
    } else if (state == CYLRefreshStateRefreshing) {
        [self.loadingView startAnimating];
    }
    [self cyl_updateIconViewVisible:state == CYLRefreshStateRefreshing replacingViews:@[self.loadingView]];
}

@end
