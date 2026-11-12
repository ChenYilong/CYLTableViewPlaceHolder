//
//  CYLRefreshStateHeader.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshStateHeader : CYLRefreshHeader
#pragma mark - 刷新时间相关
/*!
 * 利用这个block来决定显示的更新时间文字
 */
@property (copy, nonatomic, nullable) NSString *(^lastUpdatedTimeText)(NSDate * _Nullable lastUpdatedTime);
/*!
 * 显示上一次刷新时间的label
 */
@property (weak, nonatomic, readonly) UILabel *lastUpdatedTimeLabel;

#pragma mark - 状态相关
/*!
 * 文字距离圈圈、箭头的距离
 */
@property (assign, nonatomic) CGFloat labelLeftInset;
/*!
 * 显示刷新状态的label
 */
@property (weak, nonatomic, readonly) UILabel *stateLabel;
/*!
 * 设置state状态下的文字
 */
- (instancetype)setTitle:(NSString *)title forState:(CYLRefreshState)state;
/*!
 * [EN] Formats the last update time instead of the built-in, locale-aware format ("Last update: " stays in front).
 *      `lastUpdatedTimeText` still wins when set. [CN] 用它格式化上次更新时间，代替内置的按语言格式（前面保留 “最后更新：”）。
 *      设置了 `lastUpdatedTimeText` 时仍以它为准。
 */
@property (strong, nonatomic, nullable) NSDateFormatter *lastUpdatedTimeFormatter;
/*!
 * [EN] The text the time label shows now. [CN] 时间文字当前显示的内容。
 */
@property (copy, nonatomic, readonly, nullable) NSString *lastUpdatedTimeString;
/*!
 * [EN] Points between the state text and the time text; 0 (default) splits the height in halves as before.
 * [CN] 状态文字与时间文字之间的间距（点）；0（默认）表示照旧把高度一分为二。
 */
@property (assign, nonatomic) CGFloat titleTimeSpacing;
@end

@interface CYLRefreshStateHeader (ChainingGrammar)

- (instancetype)cyl_modifyLastUpdatedTimeText:(NSString * (^)(NSDate * _Nullable lastUpdatedTime))handler;

@end

NS_ASSUME_NONNULL_END
