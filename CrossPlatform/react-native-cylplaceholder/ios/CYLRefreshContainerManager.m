#import <React/RCTConvert.h>
#import <React/RCTViewManager.h>
#import "CYLRefreshContainerView.h"

/**
 * [EN] The React Native view manager of `CYLRefreshContainerView` ("CYLRefreshContainer"): props `refreshing`, `enabled`, `loadingMore`,
 *      `noMoreData`, `loadMoreEnabled` and `loadsAfterNoMoreData`, the second floor's `secondaryTriggerOffset`, `secondaryDimension`, `secondaryCloseTriggerOffset`, `secondaryOpen` and the events `onSecondaryOpen`, `onSecondaryClose`, the direct events `onRefresh` and `onLoadMore`; the same names as
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
RCT_EXPORT_VIEW_PROPERTY(headerRive, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(footerRive, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(secondaryTriggerOffset, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(secondaryDimension, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(secondaryOpen, BOOL)
RCT_EXPORT_VIEW_PROPERTY(footerSecondaryTriggerOffset, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(footerSecondaryDimension, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(footerSecondaryOpen, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onSecondaryOpen, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSecondaryClose, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onRefresh, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoadMore, RCTDirectEventBlock)

// The close trigger is 80 unless JavaScript says otherwise (an unset prop arrives as nil).
RCT_CUSTOM_VIEW_PROPERTY(secondaryCloseTriggerOffset, CGFloat, CYLRefreshContainerView) {
    view.secondaryCloseTriggerOffset = json ? [RCTConvert CGFloat:json] : 80;
}

// The same for the footer floor's close trigger.
RCT_CUSTOM_VIEW_PROPERTY(footerSecondaryCloseTriggerOffset, CGFloat, CYLRefreshContainerView) {
    view.footerSecondaryCloseTriggerOffset = json ? [RCTConvert CGFloat:json] : 80;
}

// `enabled` is on unless JavaScript says otherwise (an unset prop arrives as nil), as Android's `defaultBoolean = true`.
RCT_CUSTOM_VIEW_PROPERTY(enabled, BOOL, CYLRefreshContainerView) {
    view.enabled = json ? [RCTConvert BOOL:json] : YES;
}

@end
