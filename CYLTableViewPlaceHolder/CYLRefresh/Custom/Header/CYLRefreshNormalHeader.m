//
//  CYLRefreshNormalHeader.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshNormalHeader.h"
#import "NSBundle+CYLRefresh.h"
#import "UIScrollView+CYLRefresh.h"
#import "UIView+CYLExtension.h"

@interface CYLRefreshNormalHeader()
{
    __unsafe_unretained UIImageView *_arrowView;
}
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation CYLRefreshNormalHeader
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

#pragma mark - 公共方法
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
        CGFloat stateWidth = self.stateLabel.cyl_textWidth;
        CGFloat timeWidth = 0.0;
        if (!self.lastUpdatedTimeLabel.hidden) {
            timeWidth = self.lastUpdatedTimeLabel.cyl_textWidth;
        }
        CGFloat textWidth = MAX(stateWidth, timeWidth);
        // [EN] iconOnTrailingSide (default NO) puts the arrow after the text. [CN] iconOnTrailingSide（默认 NO）把箭头放到文字后面。
        if (self.iconOnTrailingSide) {
            arrowCenterX += textWidth / 2 + self.labelLeftInset;
        } else {
            arrowCenterX -= textWidth / 2 + self.labelLeftInset;
        }
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

    // 根据状态做事情
    if (state == CYLRefreshStateIdle) {
        if (oldState == CYLRefreshStateRefreshing) {
            self.arrowView.transform = CGAffineTransformIdentity;

            [UIView animateWithDuration:self.slowAnimationDuration animations:^{
                self.loadingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                if (self.state != CYLRefreshStateIdle) return;

                self.loadingView.alpha = 1.0;
                [self.loadingView stopAnimating];
                self.arrowView.hidden = NO;
            }];
        } else {
            [self.loadingView stopAnimating];
            self.arrowView.hidden = NO;
            [UIView animateWithDuration:self.fastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        }
    } else if (state == CYLRefreshStatePulling) {
        [self.loadingView stopAnimating];
        self.arrowView.hidden = NO;
        [UIView animateWithDuration:self.fastAnimationDuration animations:^{
            self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
        }];
    } else if (state == CYLRefreshStateRefreshing) {
        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        [self.loadingView startAnimating];
        self.arrowView.hidden = YES;
    }
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return [super.flipsHorizontallyInOppositeLayoutDirectionViews arrayByAddingObjectsFromArray:@[
        self.arrowView
    ]];
}
- (void)setIconSize:(CGSize)iconSize
{
    _iconSize = iconSize;
    [self setNeedsLayout];
}

@end
