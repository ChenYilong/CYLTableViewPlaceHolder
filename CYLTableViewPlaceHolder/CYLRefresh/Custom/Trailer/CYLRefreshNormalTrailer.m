//
//  CYLRefreshNormalTrailer.m
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "CYLRefreshNormalTrailer.h"
#import "CYLRefreshIconView.h"
#import "NSBundle+CYLRefresh.h"
#import "UIView+CYLExtension.h"

@interface CYLRefreshNormalTrailer() {
    __unsafe_unretained UIImageView *_arrowView;
}
@end

@implementation CYLRefreshNormalTrailer
#pragma mark - 懒加载子控件
- (UIImageView *)arrowView {
    if (!_arrowView) {
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[NSBundle cyl_trailArrowImage]];
        [self addSubview:_arrowView = arrowView];
    }
    return _arrowView;
}

- (void)placeSubviews {
    [super placeSubviews];

    CGSize arrowSize = self.arrowView.image.size;
    // [EN] An icon wider than the arrow takes its place at the same 5-point inset, and the text moves over by the extra
    //      width, so the two never overlap. [CN] 比箭头宽的图标以相同的 5 点边距替换箭头，文字随多出的宽度右移，二者不会重叠。
    CGFloat iconExtraWidth = self.usesIconView ? MAX(0, self.iconView.iconSize.width - arrowSize.width) : 0;
    // 箭头的中心点
    CGPoint selfCenter = CGPointMake(self.cyl_w * 0.5, self.cyl_h * 0.5);
    CGPoint arrowCenter = CGPointMake(arrowSize.width * 0.5 + 5, self.cyl_h * 0.5);
    BOOL stateHidden = self.stateLabel.isHidden;

    if (self.arrowView.constraints.count == 0) {
        self.arrowView.cyl_size = self.arrowView.image.size;
        self.arrowView.center = stateHidden ?  selfCenter : arrowCenter ;
    }
    self.arrowView.tintColor = self.stateLabel.textColor;
    // [EN] An icon animation takes the arrow's place; the label moves over by the icon's extra width.
    // [CN] 图标动画替换箭头；文字随图标多出的宽度右移。
    CGPoint iconCenter = (stateHidden || self.arrowView.constraints.count) ? self.arrowView.center :
        CGPointMake(arrowSize.width * 0.5 + 5 + iconExtraWidth * 0.5, self.cyl_h * 0.5);
    [self cyl_placeIconViewAtCenter:iconCenter visible:YES replacingViews:@[self.arrowView]];

    if (stateHidden) return;

    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;
    CGFloat stateLabelW = ceil(self.stateLabel.font.pointSize);
    // 状态
    if (noConstrainsOnStatusLabel) {
        BOOL arrowHidden = self.arrowView.isHidden && !self.usesIconView;
        CGFloat stateCenterX = (self.cyl_w + arrowSize.width + iconExtraWidth) * 0.5;
        self.stateLabel.center = arrowHidden ? selfCenter : CGPointMake(stateCenterX, self.cyl_h * 0.5);
        self.stateLabel.cyl_size = CGSizeMake(stateLabelW, self.cyl_h) ;
    }
}

- (void)setState:(CYLRefreshState)state {
    CYLRefreshCheckState
    // 根据状态做事情
    if (state == CYLRefreshStateIdle) {
        if (oldState == CYLRefreshStateRefreshing) {
            [UIView animateWithDuration:self.fastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
            } completion:^(BOOL finished) {
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        } else {
            [UIView animateWithDuration:self.fastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        }
    } else if (state == CYLRefreshStatePulling) {
        [UIView animateWithDuration:self.fastAnimationDuration animations:^{
            self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return [super.flipsHorizontallyInOppositeLayoutDirectionViews arrayByAddingObjectsFromArray:@[
        self.arrowView
    ]];
}

@end
