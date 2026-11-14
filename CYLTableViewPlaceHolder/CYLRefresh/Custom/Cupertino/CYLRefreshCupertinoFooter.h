//
//  CYLRefreshCupertinoFooter.h
//  CYLRefresh
//
//  The iOS-style load-more footer (flutter_easy_refresh's CupertinoFooter): a system activity indicator while loading.
//

#import "CYLRefreshAutoFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The iOS-style footer: an automatic footer that shows a system activity indicator while loading and nothing
 *      otherwise (flutter_easy_refresh's `CupertinoFooter`). `colorAccent` colors the indicator.
 * [CN] iOS 风格的加载尾：自动加载尾，加载时显示系统菊花，其他时候不显示内容（对应 flutter_easy_refresh 的 `CupertinoFooter`）。
 *      `colorAccent` 为菊花着色。
 */
@interface CYLRefreshCupertinoFooter : CYLRefreshAutoFooter
/*!
 * [EN] The activity indicator. [CN] 菊花视图。
 */
@property (strong, nonatomic, readonly) UIActivityIndicatorView *activityIndicator;
@end

NS_ASSUME_NONNULL_END
