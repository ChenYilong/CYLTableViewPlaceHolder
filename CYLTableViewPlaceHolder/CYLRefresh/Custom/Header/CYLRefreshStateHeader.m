//
//  CYLRefreshStateHeader.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshStateHeader.h"
#import "CYLRefreshConst.h"
#import "NSBundle+CYLRefresh.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"
#import "CYLRefreshConfig.h"

@interface CYLRefreshStateHeader()
{
    /** 显示上一次刷新时间的label */
    __unsafe_unretained UILabel *_lastUpdatedTimeLabel;
    /** 显示刷新状态的label */
    __unsafe_unretained UILabel *_stateLabel;
}
/** 所有状态对应的文字 */
@property (strong, nonatomic) NSMutableDictionary *stateTitles;
@end

@implementation CYLRefreshStateHeader
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

- (UILabel *)lastUpdatedTimeLabel
{
    if (!_lastUpdatedTimeLabel) {
        [self addSubview:_lastUpdatedTimeLabel = [UILabel cyl_label]];
    }
    return _lastUpdatedTimeLabel;
}

- (void)setLastUpdatedTimeText:(NSString * _Nonnull (^)(NSDate * _Nullable))lastUpdatedTimeText{
    _lastUpdatedTimeText = lastUpdatedTimeText;
    // 重新设置key（重新显示时间）
    self.lastUpdatedTimeKey = self.lastUpdatedTimeKey;
}

#pragma mark - 公共方法
- (instancetype)setTitle:(NSString *)title forState:(CYLRefreshState)state
{
    if (title == nil) return self;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
    return self;
}

#pragma mark key的处理
- (void)setLastUpdatedTimeKey:(NSString *)lastUpdatedTimeKey
{
    [super setLastUpdatedTimeKey:lastUpdatedTimeKey];

    // 如果label隐藏了，就不用再处理
    if (self.lastUpdatedTimeLabel.hidden) return;

    NSDate *lastUpdatedTime = [[NSUserDefaults standardUserDefaults] objectForKey:lastUpdatedTimeKey];

    // 如果有block
    if (self.lastUpdatedTimeText) {
        self.lastUpdatedTimeLabel.text = self.lastUpdatedTimeText(lastUpdatedTime);
        return;
    }

    if (self.lastUpdatedTimeFormatter) {
        NSString *time = lastUpdatedTime ? [self.lastUpdatedTimeFormatter stringFromDate:lastUpdatedTime]
                                         : [NSBundle cyl_localizedStringForKey:CYLRefreshHeaderNoneLastDateText];
        self.lastUpdatedTimeLabel.text = [NSString stringWithFormat:@"%@%@",
                                          [NSBundle cyl_localizedStringForKey:CYLRefreshHeaderLastTimeText], time ?: @""];
        return;
    }

    if (lastUpdatedTime) {
        // 1.判断今天、今年（比较完整日期，而不只是“日”）
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        BOOL isToday = [calendar isDateInToday:lastUpdatedTime];
        BOOL isThisYear = [calendar component:NSCalendarUnitYear fromDate:lastUpdatedTime] ==
                          [calendar component:NSCalendarUnitYear fromDate:[NSDate date]];

        // 2.按语言格式化日期：顺序、分隔符和 12/24 小时制随 locale 变化（j 为该 locale 偏好的小时格式）
        NSString *language = CYLRefreshConfig.defaultConfig.languageCode;
        NSLocale *locale = language ? [NSLocale localeWithLocaleIdentifier:language] : NSLocale.currentLocale;
        NSString *formatTemplate = isToday ? @"jmm" : (isThisYear ? @"MMddjmm" : @"yyyyMMddjmm");
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.calendar = calendar;
        formatter.locale = locale;
        formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:formatTemplate options:0 locale:locale];
        NSString *time = [formatter stringFromDate:lastUpdatedTime];
        if (isToday) time = [@" " stringByAppendingString:time];

        // 3.显示日期
        self.lastUpdatedTimeLabel.text = [NSString stringWithFormat:@"%@%@%@",
                                          [NSBundle cyl_localizedStringForKey:CYLRefreshHeaderLastTimeText],
                                          isToday ? [NSBundle cyl_localizedStringForKey:CYLRefreshHeaderDateTodayText] : @"",
                                          time];
    } else {
        self.lastUpdatedTimeLabel.text = [NSString stringWithFormat:@"%@%@",
                                          [NSBundle cyl_localizedStringForKey:CYLRefreshHeaderLastTimeText],
                                          [NSBundle cyl_localizedStringForKey:CYLRefreshHeaderNoneLastDateText]];
    }
}


- (void)textConfiguration {
    // 初始化文字
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshHeaderIdleText] forState:CYLRefreshStateIdle];
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshHeaderPullingText] forState:CYLRefreshStatePulling];
    [self setTitle:[NSBundle cyl_localizedStringForKey:CYLRefreshHeaderRefreshingText] forState:CYLRefreshStateRefreshing];
    self.lastUpdatedTimeKey = CYLRefreshHeaderLastUpdatedTimeKey;
}

#pragma mark - 覆盖父类的方法
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

    if (self.stateLabel.hidden) return;

    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;

    if (self.lastUpdatedTimeLabel.hidden) {
        // 状态
        if (noConstrainsOnStatusLabel) self.stateLabel.frame = self.bounds;
    } else {
        CGFloat stateLabelH = self.cyl_h * 0.5;
        CGFloat stateLabelY = 0;
        if (self.titleTimeSpacing > 0) {
            // [EN] Both lines centered as a block, `titleTimeSpacing` apart. [CN] 两行作为一个整体居中，间距 `titleTimeSpacing`。
            CGFloat stateH = ceil(self.stateLabel.font.lineHeight), timeH = ceil(self.lastUpdatedTimeLabel.font.lineHeight);
            stateLabelY = MAX(0, (self.cyl_h - stateH - self.titleTimeSpacing - timeH) * 0.5);
            stateLabelH = stateH;
        }
        // 状态
        if (noConstrainsOnStatusLabel) {
            self.stateLabel.cyl_x = 0;
            self.stateLabel.cyl_y = stateLabelY;
            self.stateLabel.cyl_w = self.cyl_w;
            self.stateLabel.cyl_h = stateLabelH;
        }

        // 更新时间
        if (self.lastUpdatedTimeLabel.constraints.count == 0) {
            self.lastUpdatedTimeLabel.cyl_x = 0;
            self.lastUpdatedTimeLabel.cyl_y = self.titleTimeSpacing > 0 ? stateLabelY + stateLabelH + self.titleTimeSpacing : stateLabelH;
            self.lastUpdatedTimeLabel.cyl_w = self.cyl_w;
            self.lastUpdatedTimeLabel.cyl_h = self.titleTimeSpacing > 0 ? ceil(self.lastUpdatedTimeLabel.font.lineHeight)
                                                                      : self.cyl_h - self.lastUpdatedTimeLabel.cyl_y;
        }
    }
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

    // 设置状态文字
    self.stateLabel.text = self.stateTitles[@(state)];

    // 重新设置key（重新显示时间）
    self.lastUpdatedTimeKey = self.lastUpdatedTimeKey;
}

- (NSArray<UIView *> *)flipsHorizontallyInOppositeLayoutDirectionViews {
    return @[
        self.stateLabel, self.lastUpdatedTimeLabel
    ];
}
@end

#pragma mark - <<< 为 Swift 扩展链式语法 >>> -
@implementation CYLRefreshStateHeader (ChainingGrammar)

- (instancetype)cyl_modifyLastUpdatedTimeText:(NSString * _Nonnull (^)(NSDate * _Nullable))handler {
    self.lastUpdatedTimeText = handler;
    return self;
}

#pragma mark - Finish result

- (void)setLastUpdatedTimeFormatter:(NSDateFormatter *)lastUpdatedTimeFormatter
{
    _lastUpdatedTimeFormatter = lastUpdatedTimeFormatter;
    self.lastUpdatedTimeKey = self.lastUpdatedTimeKey;
}

- (NSString *)lastUpdatedTimeString
{
    return self.lastUpdatedTimeLabel.text;
}

- (void)setTitleTimeSpacing:(CGFloat)titleTimeSpacing
{
    _titleTimeSpacing = MAX(0, titleTimeSpacing);
    [self setNeedsLayout];
}

/// [EN] While the control holds after the refresh (`finishDuration`), the state text shows the result.
/// [CN] 刷新结束后停留期间（`finishDuration`），状态文字显示结果。
- (void)refreshDidFinishWithSuccess:(BOOL)success
{
    [super refreshDidFinishWithSuccess:success];
    if ([self finishingDurationWithSuccess:success] <= 0) return;
    self.stateLabel.text = [NSBundle cyl_localizedStringForKey:success ? CYLRefreshHeaderFinishedText : CYLRefreshHeaderFailedText];
    [self setNeedsLayout];
}

@end
