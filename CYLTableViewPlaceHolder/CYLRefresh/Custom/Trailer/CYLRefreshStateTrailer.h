//
//  CYLRefreshStateTrailer.h
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "CYLRefreshTrailer.h"

NS_ASSUME_NONNULL_BEGIN


@interface CYLRefreshStateTrailer : CYLRefreshTrailer

#pragma mark - 状态相关
/*!
 * 显示刷新状态的label
 */
@property (weak, nonatomic, readonly) UILabel *stateLabel;
/*!
 * 设置state状态下的文字
 */
- (instancetype)setTitle:(NSString *)title forState:(CYLRefreshState)state;
/*!
 * [EN] Lays the state label out as a vertical column centered at `centerX`, so the whole text stays readable in every
 *      language: CJK text stands upright one character per line (as in MJRefresh) when it fits the height; any other
 *      text (English, Russian, …) or CJK text that does not fit is rotated 90° clockwise to read top to bottom, and
 *      wraps to more lines instead of being cut off. Returns the column's width. Does nothing to a label with
 *      constraints. Subclasses call it from `placeSubviews`.
 * [CN] 把状态文字排成以 `centerX` 为中心的竖列，使任何语言的文字都能完整、可读地显示：中日韩文字放得下时逐字竖排、保持正立（与
 *      MJRefresh 相同）；其他文字（英文、俄文等）或放不下的中日韩文字顺时针旋转 90°，从上往下读，过长时换行而不是截断。返回竖列宽度。
 *      带约束的 label 不处理。子类在 `placeSubviews` 中调用。
 */
- (CGFloat)cyl_placeStateLabelAtCenterX:(CGFloat)centerX NS_SWIFT_NAME(cyl_placeStateLabel(centerX:));

@end

NS_ASSUME_NONNULL_END
