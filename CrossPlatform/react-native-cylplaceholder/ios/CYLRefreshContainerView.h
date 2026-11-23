#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * [EN] The native container a React Native scroll view sits in: the first UIScrollView below it gets a CYLRefreshNormalHeader as its
 *      `cyl_header` (the iOS side of `CYLRefreshContainer`, docs/Refresh-Library-Parity.md, "Native bridge map"). The JS side passes
 *      `refreshing` and `enabled` as props and gets `onRefresh` when the user pulls.
 * [CN] React Native 滚动视图所在的原生容器：其下第一个 UIScrollView 以 CYLRefreshNormalHeader 作为 `cyl_header`
 *      （`CYLRefreshContainer` 的 iOS 一侧）。JS 以 `refreshing`、`enabled` 作为属性，用户下拉时收到 `onRefresh`。
 */
@interface CYLRefreshContainerView : UIView

/** [EN] Called when the header starts refreshing from a pull. [CN] 下拉触发刷新时调用。 */
@property (nonatomic, copy, nullable) RCTDirectEventBlock onRefresh;

/** [EN] Shows or hides the refreshing state (`RefreshControl.refreshing`). [CN] 显示或隐藏刷新状态。 */
@property (nonatomic, assign) BOOL refreshing;

/** [EN] Whether the pull is on, default YES. [CN] 是否允许下拉，默认 YES。 */
@property (nonatomic, assign) BOOL enabled;

@end

NS_ASSUME_NONNULL_END
