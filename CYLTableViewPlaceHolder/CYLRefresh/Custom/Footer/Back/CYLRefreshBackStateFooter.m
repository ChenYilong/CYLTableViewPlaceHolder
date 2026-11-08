//
//  CYLRefreshBackStateFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/6/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshBackStateFooter.h"
#import "NSBundle+CYLRefresh.h"

@interface CYLRefreshBackStateFooter()
{
    /** 显示刷新状态的label */
    __unsafe_unretained UILabel *_stateLabel;
}
/** 所有状态对应的文字 */
@property (strong, nonatomic) NSMutableDictionary *stateTitles;
@end

@implementation CYLRefreshBackStateFooter
#pragma mark - 懒加载
- (NSMutableDictionary *)stateTitles
{
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

- (UILabel *)stateLabel
{
    if (!_stateLabel) {
        [self addSubview:_stateLabel = [UILabel cyl_label]];
    }
    return _stateLabel;
}

#pragma mark - 公共方法
- (instancetype)setTitle:(NSString *)title forState:(CYLRefreshState)state
{
    if (title == nil) return self;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
    return self;
}

- (NSString *)titleForState:(CYLRefreshState)state {
  return self.stateTitles[@(state)];
}

- (void)textConfiguration {
    // 初始化文字
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshBackFooterIdleText] forState:CYLRefreshStateIdle];
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshBackFooterPullingText] forState:CYLRefreshStatePulling];
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshBackFooterRefreshingText] forState:CYLRefreshStateRefreshing];
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshBackFooterNoMoreDataText] forState:CYLRefreshStateNoMoreData];
}

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];

    // 初始化间距
    self.labelLeftInset = CYLRefreshLabelLeftInset;
    [self textConfiguration];
}

- (void)i18nDidChange {
    [self textConfiguration];

    [super i18nDidChange];
}

- (void)placeSubviews
{
    [super placeSubviews];

    if (self.stateLabel.constraints.count) return;

    // 状态标签
    self.stateLabel.frame = self.bounds;
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

    // 设置状态文字
    self.stateLabel.text = self.stateTitles[@(state)];
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return @[
        self.stateLabel
    ];
}
@end
