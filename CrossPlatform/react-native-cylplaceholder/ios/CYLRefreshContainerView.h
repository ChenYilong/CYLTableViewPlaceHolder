#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * [EN] The block type of the two events; it is `RCTDirectEventBlock` of React Native, spelled out so this view needs no React headers (the
 *      unit tests build it without a React Native runtime).
 * [CN] 两个事件的 block 类型，即 React Native 的 `RCTDirectEventBlock`，在此直接写出，使本视图不依赖 React 头文件（单元测试不需要 React Native 运行时）。
 */
typedef void (^CYLRefreshContainerEventBlock)(NSDictionary *body);

/**
 * [EN] The native container a React Native scroll view sits in: the first UIScrollView below it (the one inside `ScrollView`, `FlatList`,
 *      `SectionList`) gets a `CYLRefreshNormalHeader` as its `cyl_header` and, while `loadMoreEnabled`, a
 *      `CYLRefreshBackNormalFooter` as its `cyl_footer`. This is the iOS side of `CYLRefreshContainer`, with Android's
 *      `CYLRefreshContainerView` as the contract (docs/Refresh-Library-Parity.md, "Native bridge map"): the JS side passes `refreshing`,
 *      `enabled`, `loadMoreEnabled`, `loadingMore` and `noMoreData` as props and gets `onRefresh` when the user pulls the header and
 *      `onLoadMore` when the footer starts loading; a value JavaScript set does not call its own event back.
 * [CN] React Native 滚动视图所在的原生容器：其下第一个 UIScrollView（`ScrollView`、`FlatList`、`SectionList` 内的那个）以
 *      `CYLRefreshNormalHeader` 作为 `cyl_header`，`loadMoreEnabled` 为真时再以 `CYLRefreshBackNormalFooter` 作为 `cyl_footer`。
 *      这是 `CYLRefreshContainer` 的 iOS 一侧，以 Android 的 `CYLRefreshContainerView` 为约定：JS 以 `refreshing`、`enabled`、
 *      `loadMoreEnabled`、`loadingMore`、`noMoreData` 作为属性，用户下拉时收到 `onRefresh`，尾部开始加载时收到 `onLoadMore`；
 *      JS 自己设置的值不会回调对应的事件。
 */
@interface CYLRefreshContainerView : UIView

/** [EN] Called when the header starts refreshing from a pull (not when `refreshing` was set from JS). [CN] 下拉触发刷新时调用（JS 设置 `refreshing` 时不调用）。 */
@property (nonatomic, copy, nullable) CYLRefreshContainerEventBlock onRefresh;

/** [EN] Called when the footer starts loading from a pull (not when `loadingMore` was set from JS). [CN] 上拉触发加载时调用（JS 设置 `loadingMore` 时不调用）。 */
@property (nonatomic, copy, nullable) CYLRefreshContainerEventBlock onLoadMore;

/** [EN] Shows or hides the refreshing state (`RefreshControl.refreshing`). [CN] 显示或隐藏刷新状态。 */
@property (nonatomic, assign) BOOL refreshing;

/** [EN] Whether the pull down is on, default YES. [CN] 是否允许下拉，默认 YES。 */
@property (nonatomic, assign) BOOL enabled;

/** [EN] Whether the footer (load more) is on, default NO. [CN] 是否启用尾部（加载更多），默认 NO。 */
@property (nonatomic, assign) BOOL loadMoreEnabled;

/** [EN] Shows the footer's loading state, as `refreshing` does for the header. [CN] 显示尾部的加载状态，与头部的 `refreshing` 对应。 */
@property (nonatomic, assign) BOOL loadingMore;

/** [EN] Shows "no more data" in the footer; true while loading ends the load with it, false loads again. [CN] 尾部显示“没有更多数据”；加载中设为 true 即以此结束加载，false 则恢复可加载。 */
@property (nonatomic, assign) BOOL noMoreData;

/** [EN] A pull past the end loads again after "no more data" (`CYLRefreshFooter.loadsAfterNoMoreData`), default NO. iOS only: Android has no such prop yet. [CN] “没有更多数据”后拉过底部仍会再次加载，默认 NO。仅 iOS：Android 尚无此属性。 */
@property (nonatomic, assign) BOOL loadsAfterNoMoreData;

/** [EN] The header's look: `classic` (default), `cupertino`, `material`, `bezierRadar`, `bezierCircle`, `delivery`, `phoenix` or `taurus` (`CYLRefreshStyleFactory`); an unknown name is the classic one and is logged. iOS only. [CN] 头部外观，取值见上（`CYLRefreshStyleFactory`）；未知名称按经典样式处理并记录日志。仅 iOS。 */
@property (nonatomic, copy, nullable) NSString *headerStyle;

/** [EN] The footer's look, same names as `headerStyle`; `bezierCircle` has no drawn footer and shows the classic one. iOS only. [CN] 尾部外观，名称同 `headerStyle`；`bezierCircle` 没有手绘尾部，显示经典样式。仅 iOS。 */
@property (nonatomic, copy, nullable) NSString *footerStyle;

/** [EN] The scroll view the container found and attached the header and footer to, nil until React Native has added it. [CN] 容器找到并挂上头尾的滚动视图；React Native 添加之前为 nil。 */
@property (nonatomic, weak, readonly, nullable) UIScrollView *scrollView;

@end

NS_ASSUME_NONNULL_END
