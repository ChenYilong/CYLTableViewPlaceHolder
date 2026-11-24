#import <React/RCTConvert.h>
#import <React/RCTViewManager.h>
#import "CYLRefreshContainerView.h"

/**
 * [EN] The React Native view manager of `CYLRefreshContainerView` ("CYLRefreshContainer"): props `refreshing`, `enabled`, `loadingMore`,
 *      `noMoreData`, `loadMoreEnabled` and `loadsAfterNoMoreData`, the direct events `onRefresh` and `onLoadMore`; the same names as
 *      Android's `CYLRefreshContainerManager` (which has no commands: JavaScript sets the props).
 * [CN] `CYLRefreshContainerView` 的 React Native View Manager（“CYLRefreshContainer”）：属性 `refreshing`、`enabled`、`loadingMore`、
 *      `noMoreData`、`loadMoreEnabled`、`loadsAfterNoMoreData`，直接事件 `onRefresh`、`onLoadMore`；名称与 Android 的
 *      `CYLRefreshContainerManager` 相同（它没有命令：由 JavaScript 设置属性）。
 */
@interface CYLRefreshContainerManager : RCTViewManager
@end

@implementation CYLRefreshContainerManager

RCT_EXPORT_MODULE(CYLRefreshContainer)

- (UIView *)view {
    return [CYLRefreshContainerView new];
}

RCT_EXPORT_VIEW_PROPERTY(refreshing, BOOL)
RCT_EXPORT_VIEW_PROPERTY(loadMoreEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(loadingMore, BOOL)
RCT_EXPORT_VIEW_PROPERTY(noMoreData, BOOL)
RCT_EXPORT_VIEW_PROPERTY(loadsAfterNoMoreData, BOOL)
RCT_EXPORT_VIEW_PROPERTY(headerStyle, NSString)
RCT_EXPORT_VIEW_PROPERTY(footerStyle, NSString)
RCT_EXPORT_VIEW_PROPERTY(onRefresh, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoadMore, RCTDirectEventBlock)

// `enabled` is on unless JavaScript says otherwise (an unset prop arrives as nil), as Android's `defaultBoolean = true`.
RCT_CUSTOM_VIEW_PROPERTY(enabled, BOOL, CYLRefreshContainerView) {
    view.enabled = json ? [RCTConvert BOOL:json] : YES;
}

@end
