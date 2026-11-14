//
//  CYLRefreshAutoStateFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/6/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshAutoStateFooter.h"
#import "NSBundle+CYLRefresh.h"

@interface CYLRefreshAutoFooter (TapTriggerFix)

- (void)cyl_beginRefreshingWithoutValidation;
@end


@implementation CYLRefreshAutoFooter (TapTriggerFix)

- (void)cyl_beginRefreshingWithoutValidation {
    [super beginRefreshing];
}

@end

@interface CYLRefreshAutoStateFooter()
{
    /** 显示刷新状态的label */
    __unsafe_unretained UILabel *_stateLabel;
}
/** 所有状态对应的文字 */
@property (strong, nonatomic) NSMutableDictionary *stateTitles;
@end

@implementation CYLRefreshAutoStateFooter
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

#pragma mark - 私有方法
- (void)stateLabelClick
{
    if (self.state == CYLRefreshStateIdle) {
        [super cyl_beginRefreshingWithoutValidation];
    }
}

- (void)textConfiguration {
    // 初始化文字
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshAutoFooterIdleText] forState:CYLRefreshStateIdle];
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshAutoFooterRefreshingText] forState:CYLRefreshStateRefreshing];
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshAutoFooterNoMoreDataText] forState:CYLRefreshStateNoMoreData];
}

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];

    // 初始化间距
    self.labelLeftInset = CYLRefreshLabelLeftInset;

    [self textConfiguration];

    // 监听label
    self.stateLabel.userInteractionEnabled = YES;
    [self.stateLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stateLabelClick)]];
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

    if (self.isRefreshingTitleHidden && state == CYLRefreshStateRefreshing) {
        self.stateLabel.text = nil;
    } else {
        self.stateLabel.text = self.stateTitles[@(state)];
    }
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return @[
        self.stateLabel
    ];
}
/// [EN] While the footer holds after loading (`finishDuration`), the state text shows the result.
/// [CN] 加载结束后停留期间（`finishDuration`），状态文字显示结果。
- (void)refreshDidFinishWithSuccess:(BOOL)success
{
    [super refreshDidFinishWithSuccess:success];
    if ([self finishingDurationWithSuccess:success] <= 0) return;
    self.stateLabel.text = [NSBundle cyl_localizedStringForKey:success ? CYLRefreshFooterFinishedText : CYLRefreshFooterFailedText];
}

@end
