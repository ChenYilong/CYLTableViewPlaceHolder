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
//  [EN] Swift since 2026-11-19: the class is in `CYLPlaceholderHUD.swift`. The notification names and the userInfo key
//       (FOUNDATION_EXPORT symbols, defined in `CYLPlaceholderHUDSupport.m`), the enums and the dismiss completion block
//       type stay here in Objective-C, made Swift-compatible (docs/Swift-Migration.md, rule 6).
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLPlaceholderHUD.swift`）。通知名与 userInfo 的 key（FOUNDATION_EXPORT 符号，定义在
//       `CYLPlaceholderHUDSupport.m`）、枚举与关闭完成 block 类型保留在 Objective-C 中并兼容 Swift（docs/Swift-Migration.md 第 6 条）。
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
 * [EN] A HUD whose content is a placeholder stack view. The class is Swift since 2026-11-19 (`CYLPlaceholderHUD.swift`)
 *      with the same Objective-C API: the shared HUD `+sharedHUD` (Swift `shared`), `-initWithContainerView:`
 *      (designated; `-init` is the same as `initWithContainerView:nil`; `-initWithFrame:` and `-initWithCoder:` are
 *      unavailable); the content (`contentView`, `placeholderView`, `hudView`, `actions`, `state`, `status`, `progress`,
 *      `visible` / `isVisible`, `activityCount`); the customization (`containerView`, `style`, `maskType`, the
 *      null_resettable `foregroundColor`, `hudBackgroundColor`, `backgroundLayerColor`, `font`,
 *      `loadingAnimationFileName`, `successImage`, `errorImage` and `infoImage`, `cornerRadius`, `minimumSize`,
 *      `animationSize`, `offsetFromCenter`, `progressAnimationFileName`, `successAnimationFileName`,
 *      `graceTimeInterval`, `minimumDismissTimeInterval`, `maximumDismissTimeInterval`, `fadeInAnimationDuration`,
 *      `fadeOutAnimationDuration`, `hapticsEnabled` / `isHapticsEnabled`); showing (`-show`, `-showWithStatus:` (Swift
 *      `show(status:)`), `-showProgress:` and `-showProgress:status:` (Swift `show(progress:status:)`), `-setStatus:`,
 *      `-showInfoWithStatus:`, `-showSuccessWithStatus:`, `-showErrorWithStatus:` (Swift `showInfo(status:)`, ...),
 *      `-showImage:status:` (Swift `show(image:status:)`), `-showComponents:actions:` and `-showScenario:actions:`
 *      (Swift `show(components:actions:)`, `show(scenario:actions:)`)); dismissing (`-popActivity`, `-dismiss`,
 *      `-dismissWithCompletion:`, `-dismissWithDelay:`, `-dismissWithDelay:completion:` (Swift
 *      `dismiss(withDelay:completion:)`), `-displayDurationForString:` (Swift `displayDuration(for:)`)); and the
 *      SVProgressHUD-style class methods of the same names, which message the shared HUD. Every method runs on the
 *      main thread; calls from another thread are moved there. Objective-C code that messages it imports the umbrella
 *      header `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 内容为占位图组件栈的 HUD。该类自 2026-11-19 起用 Swift 编写（`CYLPlaceholderHUD.swift`），Objective-C API 不变（含选择器、
 *      Swift 名称与同名类方法）。所有方法在主线程执行；其他线程的调用会转到主线程。需要调用它的 Objective-C 代码请导入总头文件
 *      `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLPlaceholderHUD;

NS_ASSUME_NONNULL_END
