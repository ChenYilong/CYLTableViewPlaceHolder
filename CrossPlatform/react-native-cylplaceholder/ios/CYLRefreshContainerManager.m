#import <React/RCTViewManager.h>
#import "CYLRefreshContainerView.h"

/** [EN] The React Native view manager of `CYLRefreshContainerView` ("CYLRefreshContainer"). [CN] `CYLRefreshContainerView` 的 View Manager。 */
@interface CYLRefreshContainerManager : RCTViewManager
@end

@implementation CYLRefreshContainerManager

RCT_EXPORT_MODULE(CYLRefreshContainer)

- (UIView *)view {
    return [CYLRefreshContainerView new];
}

RCT_EXPORT_VIEW_PROPERTY(refreshing, BOOL)
RCT_EXPORT_VIEW_PROPERTY(enabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onRefresh, RCTDirectEventBlock)

@end
