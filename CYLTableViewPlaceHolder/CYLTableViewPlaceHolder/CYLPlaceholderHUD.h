//
//  CYLPlaceholderHUD.h
//  CYLTableViewPlaceHolder
//
//  [EN] The HUD style of the placeholder: a small box over the screen that shows the progress of a task, modeled on
//       SVProgressHUD's API (https://github.com/SVProgressHUD/SVProgressHUD): show, show with a status, show a
//       progress, show success, error, info or an image, dismiss (now, after a delay, or when every `show` is balanced
//       by `popActivity`), styles, mask types, notifications and haptics. Its content is a CYLPlaceholderStackView, so
//       everything a placeholder offers works here too: components, a stack of them, tap actions with handlers,
//       bundled GIF, Lottie, PAG and Rive animations. Unlike a refresh icon, the loading animation loops by default.
//       The HUD covers the start of a page's life cycle (loading), as the placeholder covers the rest (failed, empty)
//       and CYLRefresh covers refreshing and loading more.
//  [CN] 占位图的 HUD 样式：盖在页面上的小方框，显示任务进度，接口参考 SVProgressHUD：显示、带文字显示、显示进度、显示成功
//       /错误/提示/图片、关闭（立即、延迟，或在每次 `show` 都被 `popActivity` 抵消后），样式、遮罩、通知与触感反馈。内容是
//       CYLPlaceholderStackView，因此占位图的所有能力都可使用：组件、组件堆叠、带处理的点击动作、内置 GIF/Lottie/PAG/Rive 动画。
//       与刷新图标不同，加载动画默认循环播放。HUD 覆盖页面生命周期的开始（加载中），占位图覆盖其余（失败、空），CYLRefresh
//       覆盖下拉刷新与加载更多。
//

#import <UIKit/UIKit.h>
#import "CYLPlaceholderStackView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Posted when the show animation starts; `userInfo[CYLPlaceholderHUDStatusUserInfoKey]` is the status, if any.
 * [CN] 显示动画开始时发送；`userInfo[CYLPlaceholderHUDStatusUserInfoKey]` 为状态文字（如有）。
 */
FOUNDATION_EXPORT NSNotificationName const CYLPlaceholderHUDWillAppearNotification;
/*!
 * [EN] Posted when the show animation ends. [CN] 显示动画结束时发送。
 */
FOUNDATION_EXPORT NSNotificationName const CYLPlaceholderHUDDidAppearNotification;
/*!
 * [EN] Posted when the dismiss animation starts. [CN] 关闭动画开始时发送。
 */
FOUNDATION_EXPORT NSNotificationName const CYLPlaceholderHUDWillDisappearNotification;
/*!
 * [EN] Posted when the dismiss animation ends. [CN] 关闭动画结束时发送。
 */
FOUNDATION_EXPORT NSNotificationName const CYLPlaceholderHUDDidDisappearNotification;
/*!
 * [EN] Posted when the mask outside the box is touched; the object is the UIEvent. [CN] 触摸方框外的遮罩时发送；object 为 UIEvent。
 */
FOUNDATION_EXPORT NSNotificationName const CYLPlaceholderHUDDidReceiveTouchEventNotification;
/*!
 * [EN] Posted when the box itself is touched down; the object is the UIEvent. [CN] 按下方框本身时发送；object 为 UIEvent。
 */
FOUNDATION_EXPORT NSNotificationName const CYLPlaceholderHUDDidTouchDownInsideNotification;
/*!
 * [EN] The `userInfo` key of the status string. [CN] `userInfo` 中状态文字的 key。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderHUDStatusUserInfoKey;

/*!
 * [EN] The look of the box. [CN] 方框的外观。
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderHUDStyle) {
    /*!
     * [EN] Follows the light or dark appearance (the default). [CN] 跟随浅色或深色外观（默认）。
     */
    CYLPlaceholderHUDStyleAutomatic,
    /*!
     * [EN] A light blurred box with dark content. [CN] 浅色模糊方框，深色内容。
     */
    CYLPlaceholderHUDStyleLight,
    /*!
     * [EN] A dark blurred box with light content. [CN] 深色模糊方框，浅色内容。
     */
    CYLPlaceholderHUDStyleDark,
    /*!
     * [EN] `foregroundColor` and `hudBackgroundColor`; setting either selects this style. [CN] 使用
     *      `foregroundColor` 与 `hudBackgroundColor`；设置任一项即切换到此样式。
     */
    CYLPlaceholderHUDStyleCustom,
};

/*!
 * [EN] What covers the screen around the box while it shows. [CN] 显示时方框周围的遮罩。
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderHUDMaskType) {
    /*!
     * [EN] No mask: touches outside the box reach the views behind (the default). [CN] 无遮罩：方框外的触摸传给后面的视图（默认）。
     */
    CYLPlaceholderHUDMaskTypeNone,
    /*!
     * [EN] A clear mask that blocks touches. [CN] 透明遮罩，阻止触摸。
     */
    CYLPlaceholderHUDMaskTypeClear,
    /*!
     * [EN] A dimming mask that blocks touches. [CN] 变暗的遮罩，阻止触摸。
     */
    CYLPlaceholderHUDMaskTypeBlack,
    /*!
     * [EN] A radial dimming gradient that blocks touches. [CN] 径向渐变变暗的遮罩，阻止触摸。
     */
    CYLPlaceholderHUDMaskTypeGradient,
    /*!
     * [EN] `backgroundLayerColor`, blocking touches. [CN] 使用 `backgroundLayerColor`，阻止触摸。
     */
    CYLPlaceholderHUDMaskTypeCustom,
};

/*!
 * [EN] What the HUD shows. [CN] HUD 当前显示的内容。
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderHUDState) {
    /*!
     * [EN] Not shown. [CN] 未显示。
     */
    CYLPlaceholderHUDStateHidden,
    /*!
     * [EN] An indeterminate task: the looping loading animation. [CN] 不确定进度的任务：循环播放的加载动画。
     */
    CYLPlaceholderHUDStateLoading,
    /*!
     * [EN] A task with a known progress. [CN] 已知进度的任务。
     */
    CYLPlaceholderHUDStateProgress,
    /*!
     * [EN] A finished task. [CN] 已完成的任务。
     */
    CYLPlaceholderHUDStateSuccess,
    /*!
     * [EN] A failed task. [CN] 失败的任务。
     */
    CYLPlaceholderHUDStateError,
    /*!
     * [EN] A piece of information. [CN] 一条提示信息。
     */
    CYLPlaceholderHUDStateInfo,
    /*!
     * [EN] An image of the app's choice. [CN] 应用指定的图片。
     */
    CYLPlaceholderHUDStateImage,
    /*!
     * [EN] Components of the app's choice (`showComponents:actions:`, `showScenario:actions:`). [CN] 应用指定的组件。
     */
    CYLPlaceholderHUDStateCustom,
};

/*!
 * [EN] Runs when a dismissal completes. [CN] 关闭完成时调用。
 */
typedef void (^CYLPlaceholderHUDDismissCompletion)(void);

/*!
 * [EN] A HUD whose content is a placeholder stack view. Use the shared HUD through the class methods (as with
 *      SVProgressHUD), or create one for a view with `initWithContainerView:`. Every method runs on the main thread;
 *      calls from another thread are moved there.
 * [CN] 内容为占位图组件栈的 HUD。可通过类方法使用共享 HUD（与 SVProgressHUD 相同），也可用 `initWithContainerView:` 为某个视图
 *      创建。所有方法在主线程执行；其他线程的调用会转到主线程。
 */
@interface CYLPlaceholderHUD : UIView

/*!
 * [EN] The HUD the class methods use. [CN] 类方法使用的共享 HUD。
 */
@property (class, nonatomic, strong, readonly) CYLPlaceholderHUD *sharedHUD NS_SWIFT_NAME(shared);

/*!
 * [EN] A HUD shown over `containerView`; nil shows it over the app's key window. [CN] 显示在 `containerView`
 *      上的 HUD；nil 时显示在应用的 key window 上。
 */
- (instancetype)initWithContainerView:(nullable UIView *)containerView NS_DESIGNATED_INITIALIZER;
/*!
 * [EN] The same as `initWithContainerView:nil`. [CN] 等同于 `initWithContainerView:nil`。
 */
- (instancetype)init;
/*!
 * [EN] Unavailable: use `initWithContainerView:`. [CN] 不可用：请使用 `initWithContainerView:`。
 */
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
/*!
 * [EN] Unavailable: use `initWithContainerView:`. [CN] 不可用：请使用 `initWithContainerView:`。
 */
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

#pragma mark - Content

/*!
 * [EN] The placeholder stack view inside the box, rebuilt for every new state; nil while hidden. Its components,
 *      handlers and `performAction:` work as on any placeholder. [CN] 方框内的占位图组件栈，每次切换状态时重建；隐藏时为 nil。
 *      其组件、处理与 `performAction:` 与普通占位图相同。
 */
@property (nonatomic, strong, readonly, nullable) CYLPlaceholderStackView *placeholderView;
/*!
 * [EN] The box. [CN] 方框视图。
 */
@property (nonatomic, strong, readonly) UIView *hudView;
/*!
 * [EN] Handlers for the actions of the components the HUD shows (for example a "Cancel" button added through
 *      `showComponents:actions:`); applied to every state. [CN] HUD 所显示组件的动作处理（例如通过 `showComponents:actions:`
 *      添加的“取消”按钮）；对所有状态生效。
 */
@property (nonatomic, copy, nullable) NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *actions;
/*!
 * [EN] What shows now. [CN] 当前显示的内容。
 */
@property (nonatomic, readonly) CYLPlaceholderHUDState state;
/*!
 * [EN] The status text, nil for none. [CN] 状态文字，无则为 nil。
 */
@property (nonatomic, copy, readonly, nullable) NSString *status;
/*!
 * [EN] The progress of the Progress state, from 0 to 1. [CN] Progress 状态的进度，0 到 1。
 */
@property (nonatomic, readonly) CGFloat progress;
/*!
 * [EN] YES while the HUD shows or is about to show. [CN] 显示中或即将显示时为 YES。
 */
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
/*!
 * [EN] How many `show` calls `popActivity` has not balanced yet. [CN] 尚未被 `popActivity` 抵消的 `show` 次数。
 */
@property (nonatomic, readonly) NSUInteger activityCount;

#pragma mark - Customization

/*!
 * [EN] The view the HUD covers; nil uses the app's key window (set it in an app extension). [CN] HUD 覆盖的视图；
 *      nil 使用应用的 key window（App Extension 中请设置）。
 */
@property (nonatomic, weak, nullable) UIView *containerView;
/*!
 * [EN] The look of the box (Automatic by default). [CN] 方框外观（默认 Automatic）。
 */
@property (nonatomic) CYLPlaceholderHUDStyle style;
/*!
 * [EN] The mask around the box (None by default). [CN] 方框周围的遮罩（默认 None）。
 */
@property (nonatomic) CYLPlaceholderHUDMaskType maskType;
/*!
 * [EN] The content color of the Custom style; setting it selects the Custom style. [CN] Custom 样式的内容颜色；设置后切换到 Custom 样式。
 */
@property (nonatomic, strong, null_resettable) UIColor *foregroundColor;
/*!
 * [EN] The box color of the Custom style; setting it selects the Custom style. [CN] Custom 样式的方框颜色；设置后切换到 Custom 样式。
 */
@property (nonatomic, strong, null_resettable) UIColor *hudBackgroundColor;
/*!
 * [EN] The mask color of the Custom mask type (black at 40% by default). [CN] Custom 遮罩的颜色（默认 40% 黑色）。
 */
@property (nonatomic, strong, null_resettable) UIColor *backgroundLayerColor;
/*!
 * [EN] The status font (the scaled subheadline by default, so it follows Dynamic Type). [CN] 状态文字字体（默认随动态字体缩放的 subheadline）。
 */
@property (nonatomic, strong, null_resettable) UIFont *font;
/*!
 * [EN] The corner radius of the box (14 by default). [CN] 方框圆角（默认 14）。
 */
@property (nonatomic) CGFloat cornerRadius;
/*!
 * [EN] The smallest size of the box (100 x 100 by default). [CN] 方框的最小尺寸（默认 100 x 100）。
 */
@property (nonatomic) CGSize minimumSize;
/*!
 * [EN] The size of the icon or animation (40 x 40 by default). [CN] 图标或动画的尺寸（默认 40 x 40）。
 */
@property (nonatomic) CGSize animationSize;
/*!
 * [EN] The offset of the box from the container's center. [CN] 方框相对容器中心的偏移。
 */
@property (nonatomic) UIOffset offsetFromCenter;
/*!
 * [EN] The bundled animation of the Loading state, looping ("CYLRefreshActivity.gif" by default, which Core plays;
 *      any name of `+[CYLPlaceholderView bundledAnimationFileNames]`). [CN] Loading 状态循环播放的内置动画（默认
 *      "CYLRefreshActivity.gif"，Core 即可播放；可为任意内置动画名）。
 */
@property (nonatomic, copy, null_resettable) NSString *loadingAnimationFileName;
/*!
 * [EN] A bundled animation scrubbed to the progress in the Progress state (nil by default: a drawn ring). The ring
 *      is used too when the animation's engine cannot seek. [CN] Progress 状态中按进度定位的内置动画（默认 nil：绘制的圆环）。
 *      动画引擎无法定位时也使用圆环。
 */
@property (nonatomic, copy, nullable) NSString *progressAnimationFileName;
/*!
 * [EN] The bundled animation of the Success state, played once ("CYLRefreshDoneCircle.json" by default; without
 *      the Lottie engine `successImage` shows). [CN] Success 状态播放一次的内置动画（默认 "CYLRefreshDoneCircle.json"；
 *      没有 Lottie 引擎时显示 `successImage`）。
 */
@property (nonatomic, copy, nullable) NSString *successAnimationFileName;
/*!
 * [EN] The image of the Success state. [CN] Success 状态的图片。
 */
@property (nonatomic, strong, null_resettable) UIImage *successImage;
/*!
 * [EN] The image of the Error state. [CN] Error 状态的图片。
 */
@property (nonatomic, strong, null_resettable) UIImage *errorImage;
/*!
 * [EN] The image of the Info state. [CN] Info 状态的图片。
 */
@property (nonatomic, strong, null_resettable) UIImage *infoImage;
/*!
 * [EN] How long a `show` waits before the HUD appears, so a quick task shows nothing (0 by default). [CN] `show`
 *      后等待多久才显示，使很快完成的任务不显示 HUD（默认 0）。
 */
@property (nonatomic) NSTimeInterval graceTimeInterval;
/*!
 * [EN] The shortest time success, error, info and image HUDs stay (5 seconds by default). [CN] 成功、错误、提示与图片 HUD
 *      的最短停留时间（默认 5 秒）。
 */
@property (nonatomic) NSTimeInterval minimumDismissTimeInterval;
/*!
 * [EN] The longest time they stay (no limit by default). [CN] 最长停留时间（默认不限）。
 */
@property (nonatomic) NSTimeInterval maximumDismissTimeInterval;
/*!
 * [EN] The fade-in duration (0.15 seconds by default). [CN] 淡入时长（默认 0.15 秒）。
 */
@property (nonatomic) NSTimeInterval fadeInAnimationDuration;
/*!
 * [EN] The fade-out duration (0.15 seconds by default). [CN] 淡出时长（默认 0.15 秒）。
 */
@property (nonatomic) NSTimeInterval fadeOutAnimationDuration;
/*!
 * [EN] YES plays notification haptics for success, info (warning) and error (NO by default). [CN] YES 时成功、提示（警告）
 *      与错误播放通知触感（默认 NO）。
 */
@property (nonatomic, getter=isHapticsEnabled) BOOL hapticsEnabled;

#pragma mark - Showing

/*!
 * [EN] The looping loading animation without a status. [CN] 不带文字的循环加载动画。
 */
- (void)show;
/*!
 * [EN] The looping loading animation with a status. [CN] 带文字的循环加载动画。
 */
- (void)showWithStatus:(nullable NSString *)status NS_SWIFT_NAME(show(status:));
/*!
 * [EN] A progress from 0 to 1; a negative value shows the loading animation. [CN] 0 到 1 的进度；负数显示加载动画。
 */
- (void)showProgress:(CGFloat)progress NS_SWIFT_NAME(show(progress:));
/*!
 * [EN] A progress with a status. [CN] 带文字的进度。
 */
- (void)showProgress:(CGFloat)progress status:(nullable NSString *)status NS_SWIFT_NAME(show(progress:status:));
/*!
 * [EN] Changes the status of the HUD that shows, keeping its animation. [CN] 修改正在显示的 HUD 的文字，动画不重启。
 */
- (void)setStatus:(nullable NSString *)status;
/*!
 * [EN] The info image and a status, dismissed after `displayDurationForString:`. [CN] 提示图片与文字，
 *      在 `displayDurationForString:` 之后关闭。
 */
- (void)showInfoWithStatus:(nullable NSString *)status NS_SWIFT_NAME(showInfo(status:));
/*!
 * [EN] The success animation and a status, dismissed after `displayDurationForString:`. [CN] 成功动画与文字，
 *      在 `displayDurationForString:` 之后关闭。
 */
- (void)showSuccessWithStatus:(nullable NSString *)status NS_SWIFT_NAME(showSuccess(status:));
/*!
 * [EN] The error image and a status, dismissed after `displayDurationForString:`. [CN] 错误图片与文字，
 *      在 `displayDurationForString:` 之后关闭。
 */
- (void)showErrorWithStatus:(nullable NSString *)status NS_SWIFT_NAME(showError(status:));
/*!
 * [EN] An image and a status, dismissed after `displayDurationForString:`. [CN] 图片与文字，
 *      在 `displayDurationForString:` 之后关闭。
 */
- (void)showImage:(UIImage *)image status:(nullable NSString *)status NS_SWIFT_NAME(show(image:status:));
/*!
 * [EN] Any components in the box (icons, titles, hints, buttons), with handlers for their actions; it stays until
 *      dismissed. [CN] 在方框中显示任意组件（图标、标题、提示、按钮）及其动作处理；直到关闭才消失。
 */
- (void)showComponents:(NSArray<CYLPlaceholderComponent *> *)components
               actions:(nullable NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions
    NS_SWIFT_NAME(show(components:actions:));
/*!
 * [EN] A scenario's components in the box (for example `CYLPlaceholderScenarioHUD` or
 *      `CYLPlaceholderScenarioUploading`); it stays until dismissed. [CN] 在方框中显示某个场景的组件（例如
 *      `CYLPlaceholderScenarioHUD`、`CYLPlaceholderScenarioUploading`）；直到关闭才消失。
 */
- (void)showScenario:(CYLPlaceholderScenario)scenario
             actions:(nullable NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions
    NS_SWIFT_NAME(show(scenario:actions:));

#pragma mark - Dismissing

/*!
 * [EN] Balances one `show`: the HUD is dismissed when every `show` is balanced. [CN] 抵消一次 `show`：所有 `show`
 *      都被抵消后关闭 HUD。
 */
- (void)popActivity;
/*!
 * [EN] Dismisses now. [CN] 立即关闭。
 */
- (void)dismiss;
/*!
 * [EN] Dismisses now and runs `completion` afterwards. [CN] 立即关闭，完成后调用 `completion`。
 */
- (void)dismissWithCompletion:(nullable CYLPlaceholderHUDDismissCompletion)completion
    NS_SWIFT_NAME(dismiss(completion:));
/*!
 * [EN] Dismisses after `delay` seconds. [CN] `delay` 秒后关闭。
 */
- (void)dismissWithDelay:(NSTimeInterval)delay NS_SWIFT_NAME(dismiss(withDelay:));
/*!
 * [EN] Dismisses after `delay` seconds and runs `completion` afterwards. [CN] `delay` 秒后关闭，完成后调用 `completion`。
 */
- (void)dismissWithDelay:(NSTimeInterval)delay completion:(nullable CYLPlaceholderHUDDismissCompletion)completion
    NS_SWIFT_NAME(dismiss(withDelay:completion:));
/*!
 * [EN] How long a status stays: 0.06 seconds per character plus 0.5, within the minimum and maximum dismiss
 *      intervals. [CN] 文字的停留时间：每个字符 0.06 秒再加 0.5 秒，限制在最短与最长停留时间之间。
 */
- (NSTimeInterval)displayDurationForString:(nullable NSString *)string NS_SWIFT_NAME(displayDuration(for:));

#pragma mark - Shared HUD (SVProgressHUD-style class methods)

/*!
 * [EN] `[sharedHUD show]`. [CN] 即 `[sharedHUD show]`。
 */
+ (void)show;
/*!
 * [EN] `[sharedHUD showWithStatus:]`. [CN] 即 `[sharedHUD showWithStatus:]`。
 */
+ (void)showWithStatus:(nullable NSString *)status NS_SWIFT_NAME(show(status:));
/*!
 * [EN] `[sharedHUD showProgress:]`. [CN] 即 `[sharedHUD showProgress:]`。
 */
+ (void)showProgress:(CGFloat)progress NS_SWIFT_NAME(show(progress:));
/*!
 * [EN] `[sharedHUD showProgress:status:]`. [CN] 即 `[sharedHUD showProgress:status:]`。
 */
+ (void)showProgress:(CGFloat)progress status:(nullable NSString *)status NS_SWIFT_NAME(show(progress:status:));
/*!
 * [EN] `[sharedHUD setStatus:]`. [CN] 即 `[sharedHUD setStatus:]`。
 */
+ (void)setStatus:(nullable NSString *)status;
/*!
 * [EN] `[sharedHUD showInfoWithStatus:]`. [CN] 即 `[sharedHUD showInfoWithStatus:]`。
 */
+ (void)showInfoWithStatus:(nullable NSString *)status NS_SWIFT_NAME(showInfo(status:));
/*!
 * [EN] `[sharedHUD showSuccessWithStatus:]`. [CN] 即 `[sharedHUD showSuccessWithStatus:]`。
 */
+ (void)showSuccessWithStatus:(nullable NSString *)status NS_SWIFT_NAME(showSuccess(status:));
/*!
 * [EN] `[sharedHUD showErrorWithStatus:]`. [CN] 即 `[sharedHUD showErrorWithStatus:]`。
 */
+ (void)showErrorWithStatus:(nullable NSString *)status NS_SWIFT_NAME(showError(status:));
/*!
 * [EN] `[sharedHUD showImage:status:]`. [CN] 即 `[sharedHUD showImage:status:]`。
 */
+ (void)showImage:(UIImage *)image status:(nullable NSString *)status NS_SWIFT_NAME(show(image:status:));
/*!
 * [EN] `[sharedHUD popActivity]`. [CN] 即 `[sharedHUD popActivity]`。
 */
+ (void)popActivity;
/*!
 * [EN] `[sharedHUD dismiss]`. [CN] 即 `[sharedHUD dismiss]`。
 */
+ (void)dismiss;
/*!
 * [EN] `[sharedHUD dismissWithCompletion:]`. [CN] 即 `[sharedHUD dismissWithCompletion:]`。
 */
+ (void)dismissWithCompletion:(nullable CYLPlaceholderHUDDismissCompletion)completion
    NS_SWIFT_NAME(dismiss(completion:));
/*!
 * [EN] `[sharedHUD dismissWithDelay:]`. [CN] 即 `[sharedHUD dismissWithDelay:]`。
 */
+ (void)dismissWithDelay:(NSTimeInterval)delay NS_SWIFT_NAME(dismiss(withDelay:));
/*!
 * [EN] `[sharedHUD dismissWithDelay:completion:]`. [CN] 即 `[sharedHUD dismissWithDelay:completion:]`。
 */
+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(nullable CYLPlaceholderHUDDismissCompletion)completion
    NS_SWIFT_NAME(dismiss(withDelay:completion:));
/*!
 * [EN] `sharedHUD.visible`. [CN] 即 `sharedHUD.visible`。
 */
+ (BOOL)isVisible;
/*!
 * [EN] `[sharedHUD displayDurationForString:]`. [CN] 即 `[sharedHUD displayDurationForString:]`。
 */
+ (NSTimeInterval)displayDurationForString:(nullable NSString *)string NS_SWIFT_NAME(displayDuration(for:));

@end

NS_ASSUME_NONNULL_END
