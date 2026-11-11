//
//  UIViewController+CYLPlaceholderStatus.h
//  CYLTableViewPlaceHolder
//
//  [EN] Shows the status bar (`CYLPlaceholderStatusView`) and the placeholder as two independent components of a view
//       controller, the way CYLChatKit shows its bar: the bar is added to the controller's view, at its top edge right
//       below the navigation bar (pinned to the safe area, above the content), and the placeholder stays where the
//       table or collection view puts it. One parameter, `cyl_statusDisplay`, chooses what shows: the bar and the
//       placeholder, only the bar, only the placeholder, or neither. `cyl_showsStatusViewWhenOffline` lets the network
//       monitor (`CYLPlaceholderNetworkMonitor`) add and remove the bar.
//  [CN] 把状态条（`CYLPlaceholderStatusView`）与占位图作为视图控制器中两个独立的组件显示，与 CYLChatKit 显示状态条的方式相同：状态条加在
//       控制器的 view 上，位于顶端、导航栏正下方（固定在安全区域顶部，盖在内容之上）；占位图仍由 table 或 collection view 放置。
//       一个参数 `cyl_statusDisplay` 决定显示什么：状态条加占位图、只显示状态条、只显示占位图或都不显示。`cyl_showsStatusViewWhenOffline`
//       让网络监测（`CYLPlaceholderNetworkMonitor`）自动添加和移除状态条。
//

#import <UIKit/UIKit.h>
#import "CYLPlaceholderStatusView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] What a view controller shows; combine the options. [CN] 视图控制器显示的内容；可以组合。
 */
typedef NS_OPTIONS(NSUInteger, CYLPlaceholderStatusDisplay) {
    /// [EN] Neither the bar nor the placeholder. [CN] 都不显示。
    CYLPlaceholderStatusDisplayNone = 0,
    /// [EN] The status bar at the top. [CN] 顶部状态条。
    CYLPlaceholderStatusDisplayStatusBar = 1 << 0,
    /// [EN] The placeholder of `cyl_placeholderScrollView` when it is empty (the default). [CN] 列表为空时的占位图（默认）。
    CYLPlaceholderStatusDisplayPlaceholder = 1 << 1,
    /// [EN] Both. [CN] 两者都显示。
    CYLPlaceholderStatusDisplayAll = CYLPlaceholderStatusDisplayStatusBar | CYLPlaceholderStatusDisplayPlaceholder,
};

@interface UIViewController (CYLPlaceholderStatus)

/*!
 * [EN] The bar: the network bar (`-[CYLPlaceholderStatusView initWithFrame:]`) until another is assigned; nil restores
 *      it. Assigning while the bar shows replaces it in place. [CN] 状态条：在赋值其他状态条之前为网络提示条；赋值 nil 恢复默认。
 *      显示中赋值会原地替换。
 */
@property (nonatomic, strong, null_resettable) CYLPlaceholderStatusView *cyl_statusView;
/*!
 * [EN] The table or collection view whose placeholder `cyl_statusDisplay` shows or hides; by default the controller's
 *      view when it is a scroll view (a UITableViewController). [CN] 由 `cyl_statusDisplay` 控制占位图显示的列表；默认是控制器的
 *      view（如果它是滚动视图，如 UITableViewController）。
 */
@property (nonatomic, weak, nullable) UIScrollView *cyl_placeholderScrollView;
/*!
 * [EN] What shows; `CYLPlaceholderStatusDisplayPlaceholder` by default, so nothing changes until it is set. With the
 *      bar, the controller's `additionalSafeAreaInsets.top` grows by the bar's height so the content (and a
 *      placeholder laid out in the safe area) starts below it; the bar grows with Dynamic Type.
 * [CN] 显示的内容；默认 `CYLPlaceholderStatusDisplayPlaceholder`，设置之前一切不变。显示状态条时，控制器的
 *      `additionalSafeAreaInsets.top` 增加状态条的高度，使内容（及按安全区域布局的占位图）从其下方开始；状态条随动态字体变高。
 */
@property (nonatomic) CYLPlaceholderStatusDisplay cyl_statusDisplay;
/*!
 * [EN] Sets `cyl_statusDisplay`, fading the bar in or out when `animated` (no movement, so it suits Reduce Motion).
 * [CN] 设置 `cyl_statusDisplay`；`animated` 为 YES 时状态条淡入淡出（不移动，适合“减弱动态效果”）。
 */
- (void)cyl_setStatusDisplay:(CYLPlaceholderStatusDisplay)display animated:(BOOL)animated
    NS_SWIFT_NAME(cyl_setStatusDisplay(_:animated:));
/*!
 * [EN] YES: starts the shared network monitor and adds the bar while the network is not reachable, removing it when it
 *      comes back (the placeholder option is kept as it is). NO (the default) leaves the bar to `cyl_statusDisplay`.
 * [CN] YES：启动共享的网络监测，网络不可达时添加状态条，恢复后移除（占位图选项保持不变）。NO（默认）由 `cyl_statusDisplay` 决定。
 */
@property (nonatomic) BOOL cyl_showsStatusViewWhenOffline;
/*!
 * [EN] Applies a configuration dictionary: "statusBar" (the bar: true or "networkUnavailable" for the network bar, or a
 *      dictionary for `-[CYLPlaceholderStatusView initWithConfiguration:error:]`), "display" ("statusAndPlaceholder",
 *      "status", "placeholder" or "none"; without it, "statusAndPlaceholder" when "statusBar" is given, else
 *      "placeholder") and "showsWhenOffline" (a boolean). NO, with `error` and nothing changed, when a value is
 *      invalid. [CN] 应用配置字典："statusBar"（状态条：true 或 "networkUnavailable" 表示网络提示条，或交给
 *      `-[CYLPlaceholderStatusView initWithConfiguration:error:]` 的字典）、"display"（"statusAndPlaceholder"、"status"、
 *      "placeholder" 或 "none"；缺省时有 "statusBar" 则为 "statusAndPlaceholder"，否则为 "placeholder"）与 "showsWhenOffline"（布尔值）。
 *      值无效时返回 NO 并设置 `error`，不做任何修改。
 */
- (BOOL)cyl_applyStatusConfiguration:(NSDictionary<NSString *, id> *)configuration
                               error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(cyl_applyStatusConfiguration(_:));
/// [EN] The same, from a local ".json" or ".plist" file. [CN] 同上，读取本地 ".json" 或 ".plist" 文件。
- (BOOL)cyl_applyStatusConfigurationWithContentsOfURL:(NSURL *)url
                                                error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(cyl_applyStatusConfiguration(contentsOf:));

@end

@interface UIScrollView (CYLPlaceholderVisibility)
/*!
 * [EN] YES keeps the placeholder from showing even when the list is empty; NO (the default) shows it as before.
 *      `cyl_statusDisplay` sets it. [CN] YES 时即使列表为空也不显示占位图；NO（默认）与以前相同。由 `cyl_statusDisplay` 设置。
 */
@property (nonatomic) BOOL cyl_placeholderHidden;
@end

NS_ASSUME_NONNULL_END
