//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshMaterialHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

#import "CYLRefreshDrawnHeader.h"


NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The Material spinner's size (Android MaterialProgressDrawable's `DEFAULT` and `LARGE`).
 * [CN] Material 加载圈的尺寸（对应 Android MaterialProgressDrawable 的 `DEFAULT` 与 `LARGE`）。
 */
typedef NS_ENUM(NSInteger, CYLRefreshMaterialSize) {
    /*!
     * [EN] A 40-point circle (default). [CN] 40 点的圆（默认）。
     */
    CYLRefreshMaterialSizeDefault = 0,
    /*!
     * [EN] A 56-point circle. [CN] 56 点的圆。
     */
    CYLRefreshMaterialSizeLarge = 1,
};

/*!
 * [EN] The Material Design swipe-refresh spinner, floating in front of the content.
 * [CN] Material Design 的下拉刷新圆圈，浮在内容前面。
 */
@interface CYLRefreshMaterialHeader : CYLRefreshDrawnHeader
/*!
 * [EN] The colors the arc takes in turn while refreshing; an empty array is ignored (Android
 *      MaterialProgressDrawable's `setColorSchemeColors`). [CN] 刷新时圆弧依次使用的颜色；空数组被忽略（对应 Android
 *      MaterialProgressDrawable 的 `setColorSchemeColors`）。
 */
@property (copy, nonatomic) NSArray<UIColor *> *colorSchemeColors;
/*!
 * [EN] The spinner's size; changing it sets the header height to twice the circle (Android MaterialProgressDrawable's
 *      `updateSizes`). [CN] 加载圈的尺寸；修改后刷新头高度为圆直径的两倍（对应 Android MaterialProgressDrawable 的 `updateSizes`）。
 */
@property (nonatomic) CYLRefreshMaterialSize progressSize;
@end

NS_ASSUME_NONNULL_END
