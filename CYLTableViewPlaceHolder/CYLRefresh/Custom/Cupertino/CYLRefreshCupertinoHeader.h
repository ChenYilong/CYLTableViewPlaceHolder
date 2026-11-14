//
//  CYLRefreshCupertinoHeader.h
//  CYLRefresh
//
//  The iOS-style refresh header (flutter_easy_refresh's CupertinoHeader): a system activity indicator that appears and
//  turns with the pull and spins while refreshing.
//

#import "CYLRefreshHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The iOS-style header: a system activity indicator that fades and turns in while pulled and spins while
 *      refreshing, with no text (flutter_easy_refresh's `CupertinoHeader`). `colorAccent` colors the indicator.
 * [CN] iOS 风格的刷新头：系统菊花在下拉时淡入并转动，刷新时旋转，没有文字（对应 flutter_easy_refresh 的 `CupertinoHeader`）。
 *      `colorAccent` 为菊花着色。
 */
@interface CYLRefreshCupertinoHeader : CYLRefreshHeader
/*!
 * [EN] The activity indicator. [CN] 菊花视图。
 */
@property (strong, nonatomic, readonly) UIActivityIndicatorView *activityIndicator;
@end

NS_ASSUME_NONNULL_END
