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

/// [EN] Shows noMoreDataImage beside the text only in the no-more-data state (one implementation in CYLRefreshFooter).
/// [CN] 仅在无更多数据状态时，在文字旁显示 noMoreDataImage（CYLRefreshFooter 中的统一实现）。
- (void)cyl_updateNoMoreDataImage
{
    [self cyl_updateNoMoreDataImage:self.noMoreDataImage];
}

- (void)cyl_placeNoMoreDataImage
{
    [self cyl_placeNoMoreDataImageBesideLabel:self.stateLabel inset:self.labelLeftInset size:CGSizeZero];
}

@end
