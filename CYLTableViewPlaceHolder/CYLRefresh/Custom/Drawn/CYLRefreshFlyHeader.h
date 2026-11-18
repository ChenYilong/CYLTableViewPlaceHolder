//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshFlyHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

#import "CYLRefreshDrawnHeader.h"


NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A paper plane over mountains that flies off while refreshing (after FlyRefresh). Always open: the scene stays above the list and refreshing does not push the content.
 * [CN] 山上的纸飞机，刷新时飞走（参考 FlyRefresh）。常态展开：场景一直显示在列表上方，刷新时不推动内容。
 */
@interface CYLRefreshFlyHeader : CYLRefreshDrawnHeader

/*!
 * [EN] The mountains above the content, tinted with `colorPrimary`; the same as Android's `mountainView`.
 * [CN] 内容上方的山，使用 `colorPrimary` 着色；与 Android 的 `mountainView` 相同。
 */
@property (nonatomic, strong, readonly) UIView *mountainView;
/*!
 * [EN] The paper plane, tinted with `colorAccent`; the same as Android's `flyView`.
 * [CN] 纸飞机，使用 `colorAccent` 着色；与 Android 的 `flyView` 相同。
 */
@property (nonatomic, strong, readonly) UIView *flyView;
/*!
 * [EN] The round button under the plane, in the primary color; the same as Android's `floatView`.
 * [CN] 纸飞机下方的圆形按钮，使用主色；与 Android 的 `floatView` 相同。
 */
@property (nonatomic, strong, readonly) UIView *floatView;

@end

NS_ASSUME_NONNULL_END
