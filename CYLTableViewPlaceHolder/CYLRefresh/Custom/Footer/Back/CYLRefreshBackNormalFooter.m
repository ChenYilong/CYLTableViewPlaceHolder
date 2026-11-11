//
//  CYLRefreshBackNormalFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshBackNormalFooter.h"
#import "CYLRefreshIconView.h"
#import "NSBundle+CYLRefresh.h"
#import "UIView+CYLExtension.h"

@interface CYLRefreshBackNormalFooter()
{
    __unsafe_unretained UIImageView *_arrowView;
}
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation CYLRefreshBackNormalFooter
#pragma mark - 懒加载子控件
- (UIImageView *)arrowView
{
    if (!_arrowView) {
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

    // 箭头的中心点
    CGFloat arrowCenterX = self.cyl_w * 0.5;
    if (!self.stateLabel.hidden) {
        arrowCenterX -= self.labelLeftInset + self.stateLabel.cyl_textWidth * 0.5;
    }
    CGFloat arrowCenterY = self.cyl_h * 0.5;
    CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);

    // 箭头
    if (self.arrowView.constraints.count == 0) {
        self.arrowView.cyl_size = self.arrowView.image.size;
        self.arrowView.center = arrowCenter;
    }

    // 圈圈
    if (self.loadingView.constraints.count == 0) {
        self.loadingView.center = arrowCenter;
    }

    self.arrowView.tintColor = self.stateLabel.textColor;

    // [EN] An icon animation takes the arrow's and spinner's place; hidden with them when there is no more data.
    // [CN] 图标动画替换箭头与菊花；没有更多数据时与它们一样隐藏。
    CGPoint iconCenter = self.stateLabel.hidden ? arrowCenter : [self cyl_iconCenterReplacingCenter:arrowCenter
        replacedWidth:MAX(self.arrowView.image.size.width, CGRectGetWidth(self.loadingView.bounds))];
    [self cyl_placeIconViewAtCenter:iconCenter visible:self.state != CYLRefreshStateNoMoreData
                     replacingViews:@[self.arrowView, self.loadingView]];
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

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

                self.arrowView.hidden = self.usesIconView;
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
    [self cyl_updateIconViewVisible:state != CYLRefreshStateNoMoreData replacingViews:@[self.arrowView, self.loadingView]];
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return [super.flipsHorizontallyInOppositeLayoutDirectionViews arrayByAddingObjectsFromArray:@[
        self.arrowView
    ]];
}

@end
