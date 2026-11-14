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
    [self cyl_placeStateLabelAtCenterX:self.cyl_w * 0.5];
}

#pragma mark - Vertical text

/// [EN] Text that reads well stacked upright: only CJK characters, punctuation and spaces.
/// [CN] 适合逐字竖排的文字：只含中日韩文字、标点与空格。
- (BOOL)cyl_stacksUpright:(NSString *)text
{
    if (!text.length) return YES;
    NSString *pattern = @"^[\\p{Han}\\p{Hiragana}\\p{Katakana}\\p{Hangul}\\p{P}\\p{Z}\\x{30FC}]+$";
    return [text rangeOfString:pattern options:NSRegularExpressionSearch].location != NSNotFound;
}

/// [EN] YES when the collection view flips this control (see `layoutSubviews` of CYLRefreshComponent).
/// [CN] collection view 会翻转本控件时为 YES（见 CYLRefreshComponent 的 `layoutSubviews`）。
- (BOOL)cyl_flipsHorizontally
{
    if (![self.scrollView isKindOfClass:UICollectionView.class]) return NO;
    return ((UICollectionView *)self.scrollView).collectionViewLayout.flipsHorizontallyInOppositeLayoutDirection;
}

- (CGFloat)cyl_placeStateLabelAtCenterX:(CGFloat)centerX
{
    UILabel *label = self.stateLabel;
    if (label.constraints.count) return CGRectGetWidth(label.frame);
    label.transform = CGAffineTransformIdentity;
    CGFloat height = self.cyl_h;
    CGFloat column = ceil(label.font.pointSize);
    CGPoint center = CGPointMake(centerX, height * 0.5);
    CGAffineTransform flip = [self cyl_flipsHorizontally] ? CGAffineTransformMakeScale(-1, 1) : CGAffineTransformIdentity;
    // [EN] Upright: one character per line in a column as wide as one character, as in MJRefresh.
    // [CN] 正立：宽度为一个字的竖列，每行一个字，与 MJRefresh 相同。
    CGSize upright = [label sizeThatFits:CGSizeMake(column, CGFLOAT_MAX)];
    if ([self cyl_stacksUpright:label.text] && upright.height <= height) {
        label.bounds = CGRectMake(0, 0, column, height);
        label.center = center;
        label.transform = flip;
        return column;
    }
    // [EN] Rotated: the text runs along the control's height and wraps to more lines when it is longer.
    // [CN] 旋转：文字沿控件高度排列，更长时换行。
    CGFloat length = MAX(height - 8, column);
    CGSize size = [label sizeThatFits:CGSizeMake(length, CGFLOAT_MAX)];
    label.bounds = CGRectMake(0, 0, length, ceil(size.height));
    label.center = center;
    label.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI_2), flip);
    return ceil(size.height);
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    // [EN] The state label is flipped together with its rotation in `-cyl_placeStateLabelAtCenterX:`; flipping it here
    //      would drop the rotation. [CN] 状态文字的翻转与旋转一起在 `-cyl_placeStateLabelAtCenterX:` 中设置；在这里翻转会丢掉旋转。
    return @[];
}

@end
