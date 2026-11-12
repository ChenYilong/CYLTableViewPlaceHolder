//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Header/UIRefreshOriginalHeader.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshDrawnHeader.h"


NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The original iOS 6 pull-to-refresh: a drop that stretches while pulling, snaps and turns into a spinner.
 * [CN] iOS 6 原始的下拉刷新：下拉时被拉长的水滴，断开后变为菊花。
 */
@interface CYLRefreshOriginalHeader : CYLRefreshDrawnHeader

/*!
 * [EN] YES (default): the drop snaps and refreshing starts as soon as it is fully stretched, without waiting for the
 *      release. NO: the stretch slows down instead and refreshing starts on release.
 * [CN] YES（默认）：水滴被完全拉长时立即断开并开始刷新，不等待松手。NO：改为越拉越慢，松手时开始刷新。
 */
@property (nonatomic, assign) BOOL enableAutoRefresh;

@end

NS_ASSUME_NONNULL_END
