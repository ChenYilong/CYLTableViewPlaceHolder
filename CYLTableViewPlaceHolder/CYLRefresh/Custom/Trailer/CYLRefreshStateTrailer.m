//
//  CYLRefreshStateTrailer.m
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "CYLRefreshStateTrailer.h"
#import "NSBundle+CYLRefresh.h"
#import "UIView+CYLExtension.h"

@interface CYLRefreshStateTrailer() {
    /** 显示刷新状态的label */
    __unsafe_unretained UILabel *_stateLabel;
}
/** 所有状态对应的文字 */
@property (strong, nonatomic) NSMutableDictionary *stateTitles;
@end

@implementation CYLRefreshStateTrailer
#pragma mark - 懒加载
- (NSMutableDictionary *)stateTitles {
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        UILabel *stateLabel = [UILabel cyl_label];
        stateLabel.numberOfLines = 0;
        [self addSubview:_stateLabel = stateLabel];
    }
    return _stateLabel;
}

#pragma mark - 公共方法
- (instancetype)setTitle:(NSString *)title forState:(CYLRefreshState)state {
    if (title == nil) return self;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
    return self;
}

- (void)textConfiguration {
    // 初始化文字
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshTrailerIdleText] forState:CYLRefreshStateIdle];
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshTrailerPullingText] forState:CYLRefreshStatePulling];
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshTrailerPullingText] forState:CYLRefreshStateRefreshing];
}

#pragma mark - 覆盖父类的方法
- (void)prepare {
    [super prepare];

    [self textConfiguration];
}

- (void)i18nDidChange {
    [self textConfiguration];

    [super i18nDidChange];
}

- (void)setState:(CYLRefreshState)state {
    CYLRefreshCheckState
    // 设置状态文字
    self.stateLabel.text = self.stateTitles[@(state)];
}

- (void)placeSubviews {
    [super placeSubviews];

    if (self.stateLabel.hidden) return;

    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;
    CGFloat stateLabelW = ceil(self.stateLabel.font.pointSize);
    // 状态
    if (noConstrainsOnStatusLabel) {
        self.stateLabel.center = CGPointMake(self.cyl_w * 0.5, self.cyl_h * 0.5);
        self.stateLabel.cyl_size = CGSizeMake(stateLabelW, self.cyl_h) ;
    }
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return @[
        self.stateLabel
    ];
}

@end
