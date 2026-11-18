//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshWaveSwipeHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

#import "CYLRefreshDrawnHeader.h"


NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A wave pulled down from the top, with a spinner in its drop (after WaveSwipeRefreshLayout); floats in front of the content.
 * [CN] 从顶部拉下的波浪，水滴中带加载圈（参考 WaveSwipeRefreshLayout）；浮在内容前面。
 */
@interface CYLRefreshWaveSwipeHeader : CYLRefreshDrawnHeader
/*!
 * [EN] The blur radius of the wave's and the drop's shadow, in points; default 1.5 (Android WaveView's
 *      `setShadow(radius, color)`). [CN] 波浪与水滴阴影的模糊半径（点）；默认 1.5（对应 Android WaveView 的 `setShadow(radius, color)`）。
 */
@property (nonatomic) CGFloat waveShadowRadius;
/*!
 * [EN] The color of the wave's and the drop's shadow; default black at 30% (Android WaveView's `setShadow(radius, color)`).
 * [CN] 波浪与水滴阴影的颜色；默认 30% 的黑色（对应 Android WaveView 的 `setShadow(radius, color)`）。
 */
@property (strong, nonatomic) UIColor *waveShadowColor;
@end

NS_ASSUME_NONNULL_END
