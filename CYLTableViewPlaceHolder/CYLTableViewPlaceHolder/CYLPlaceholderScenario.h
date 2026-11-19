//
//  CYLPlaceholderScenario.h
//  CYLTableViewPlaceHolder
//
//  [EN] Ready-made empty-state scenarios. A scenario is the list of components a CYLPlaceholderStackView stacks
//  vertically: the first one is the reserved icon-and-title component, the others are more icon-and-title
//  components (a hint, a button, a separator, an icon). Every text comes from the core localization.
//  The README screenshot each scenario reproduces is listed next to it (`assets/cyl-placeholder-scenario-NN-*.jpg`).
//  [CN] 现成的空状态场景。一个场景就是 CYLPlaceholderStackView 竖向堆叠的组件列表：第一个是保留的图标加标题组件，
//  其余是追加的图标加标题组件（提示、按钮、分隔符、图标）。所有文案来自核心层的国际化资源。
//
//  [EN] Swift since 2026-11-19: CYLPlaceholderComponent and CYLPlaceholderScenarioCatalog are in
//       `CYLPlaceholderScenario.swift`. The enums, the CYLPlaceholderAction type and its constants (FOUNDATION_EXPORT
//       symbols, defined in `CYLPlaceholderScenarioSupport.m`) stay here in Objective-C, made Swift-compatible
//       (docs/Swift-Migration.md, rule 6).
//  [CN] 自 2026-11-19 起 CYLPlaceholderComponent 与 CYLPlaceholderScenarioCatalog 用 Swift 编写（`CYLPlaceholderScenario.swift`）。枚举、
//       CYLPlaceholderAction 类型及其常量（FOUNDATION_EXPORT 符号，定义在 `CYLPlaceholderScenarioSupport.m`）保留在 Objective-C 中并兼容
//       Swift（docs/Swift-Migration.md 第 6 条）。
//

#import <UIKit/UIKit.h>
#import "CYLPlaceholderView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * Scenarios, grouped as the README's screenshots (structure first) and common business cases.
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderScenario) {
    /*!
     * Icon and title. README #04, #05, #06, #25, #36.
     */
    CYLPlaceholderScenarioNetworkUnavailable,
    /*!
     * Icon and title for an empty list. README #07, #09, #10.
     */
    CYLPlaceholderScenarioNoContent,
    /*!
     * Icon and title; tapping anywhere retries. README #13, #14, #15, #24, #26, #28, #31, #32, #37, #42, #43.
     */
    CYLPlaceholderScenarioTapToReload,
    /*!
     * Icon, title and a hint. README #21, #22, #27, #29.
     */
    CYLPlaceholderScenarioLoadFailedWithHint,
    /*!
     * Icon, title and a hint; tapping anywhere retries. README #08.
     */
    CYLPlaceholderScenarioTapToReconnect,
    /*!
     * Icon, title and a filled "Retry" button (Ctrip). README #01, #02, #11, #19.
     */
    CYLPlaceholderScenarioRetryButton,
    /*!
     * Icon, title and an outlined "Retry" button. README #33, #38, #39.
     */
    CYLPlaceholderScenarioRetryOutlinedButton,
    /*!
     * Icon, title, a hint and an outlined "Reload" button. README #16, #23, #40.
     */
    CYLPlaceholderScenarioRetryWithHint,
    /*!
     * Icon and title, a "Retry" button, an "or" separator and a "Contact support" button: four or more components
     * and two actions (Ctrip). README #03.
     */
    CYLPlaceholderScenarioRetryOrContactSupport,
    /*!
     * An illustration only, then a capsule "Tap to retry" title with a background image and rounded corners
     * (SMZDM). README #18.
     */
    CYLPlaceholderScenarioIllustrationRetry,
    /*!
     * Icon and title, then a tappable refresh icon. README #12.
     */
    CYLPlaceholderScenarioRefreshIcon,
    /*!
     * A title above an illustration; tapping anywhere retries. README #17.
     */
    CYLPlaceholderScenarioTitleAboveIllustration,
    /*!
     * A title and a hint, no icon; tapping anywhere retries. README #30, #41.
     */
    CYLPlaceholderScenarioTextOnly,
    /*!
     * "Tap me", an arrow, a filled "Reload" button and an offline cloud icon. README #34, #35.
     */
    CYLPlaceholderScenarioTapMeRetry,
    /*!
     * Permission missing, not a network failure: the app may not use the location, so nearby content cannot load.
     * Location icon, title, a hint, an "Open Settings" button and "Choose address manually". README #20, which shows
     * "Can't get the address, please choose manually" above a misleading "network error".
     */
    CYLPlaceholderScenarioLocationPermissionDenied,
    /*!
     * Icon, title and a hint.
     */
    CYLPlaceholderScenarioNoSearchResults,
    /*!
     * Icon, title and a "Go shopping" button.
     */
    CYLPlaceholderScenarioEmptyCart,
    /*!
     * Icon, title and a "Go shopping" button.
     */
    CYLPlaceholderScenarioNoOrders,
    /*!
     * Icon, title and a hint.
     */
    CYLPlaceholderScenarioNoFavorites,
    /*!
     * Icon and title.
     */
    CYLPlaceholderScenarioNoMessages,
    /*!
     * Icon, title and a hint.
     */
    CYLPlaceholderScenarioNoNotifications,
    /*!
     * Permission missing, of no particular kind: lock icon, title, a hint and an "Open Settings" button.
     */
    CYLPlaceholderScenarioNoPermission,
    /*!
     * Permission missing: camera. Icon, title, a hint and an "Open Settings" button, as every permission scenario.
     */
    CYLPlaceholderScenarioCameraPermissionDenied,
    /*!
     * Permission missing: photo library.
     */
    CYLPlaceholderScenarioPhotoLibraryPermissionDenied,
    /*!
     * Permission missing: microphone.
     */
    CYLPlaceholderScenarioMicrophonePermissionDenied,
    /*!
     * Permission missing: contacts.
     */
    CYLPlaceholderScenarioContactsPermissionDenied,
    /*!
     * Permission missing: calendar.
     */
    CYLPlaceholderScenarioCalendarPermissionDenied,
    /*!
     * Permission missing: Bluetooth.
     */
    CYLPlaceholderScenarioBluetoothPermissionDenied,
    /*!
     * Permission missing: notifications.
     */
    CYLPlaceholderScenarioNotificationPermissionDenied,
    /*!
     * Icon, title, a hint and a "Retry" button.
     */
    CYLPlaceholderScenarioServerError,
    /*!
     * Icon, title and a "Retry" button.
     */
    CYLPlaceholderScenarioSyncFailed,
    /*!
     * Loading animation and title.
     */
    CYLPlaceholderScenarioLoading,
    /*!
     * Uploading animation (GIF) and title.
     */
    CYLPlaceholderScenarioUploading,
    /*!
     * Success animation, title and a "Done" button.
     */
    CYLPlaceholderScenarioSuccess,
    /*!
     * [EN] The HUD style: a looping refresh animation and "Loading…", for a page that is loading. `CYLPlaceholderHUD`
     *      shows it in a box over the screen with SVProgressHUD's API (progress, success, error, dismiss).
     * [CN] HUD 样式：循环播放的刷新动画与“加载中…”，用于正在加载的页面。`CYLPlaceholderHUD` 以 SVProgressHUD 的接口把它显示在
     *      页面上方的方框中（进度、成功、错误、关闭）。
     */
    CYLPlaceholderScenarioHUD NS_SWIFT_NAME(hud),
    CYLPlaceholderScenarioCount
};

/*!
 * What kind of problem a scenario shows, so an app can tell, for example, a missing permission from a network failure.
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderScenarioCategory) {
    /*!
     * The request failed: offline, slow network or server error. Retrying may help.
     */
    CYLPlaceholderScenarioCategoryLoadFailed,
    /*!
     * Loaded, with nothing to show.
     */
    CYLPlaceholderScenarioCategoryEmpty,
    /*!
     * The app may not access what it needs; retrying does not help until the user allows it in Settings.
     */
    CYLPlaceholderScenarioCategoryPermission,
    /*!
     * Work in progress: loading, uploading.
     */
    CYLPlaceholderScenarioCategoryProgress,
    /*!
     * A finished task.
     */
    CYLPlaceholderScenarioCategorySuccess,
};

/*!
 * The system permission a permission scenario is about.
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderPermission) {
    /*!
     * Not a permission scenario, or a permission of no particular kind (CYLPlaceholderScenarioNoPermission).
     */
    CYLPlaceholderPermissionNone,
    CYLPlaceholderPermissionLocation,
    CYLPlaceholderPermissionCamera,
    CYLPlaceholderPermissionPhotoLibrary,
    CYLPlaceholderPermissionMicrophone,
    CYLPlaceholderPermissionContacts,
    CYLPlaceholderPermissionCalendar,
    CYLPlaceholderPermissionBluetooth,
    CYLPlaceholderPermissionNotifications,
};

/*!
 * What a tap on a component asks the app to do. Apps may define their own values.
 */
typedef NSString *CYLPlaceholderAction NS_TYPED_EXTENSIBLE_ENUM;
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionRetry;
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionContactSupport;
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionOpenSettings;
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionGoShopping;
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionDone;
/*!
 * Go on without the permission by entering the value by hand, such as choosing an address instead of locating.
 */
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionChooseManually;

/*!
 * How a button-like component draws its title.
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderButtonStyle) {
    /*!
     * White title on a filled, rounded background (Ctrip "Retry").
     */
    CYLPlaceholderButtonStyleFilled,
    /*!
     * Colored title inside a rounded border.
     */
    CYLPlaceholderButtonStyleOutlined,
    /*!
     * White title on a gradient background image with capsule corners (SMZDM "Tap to retry").
     */
    CYLPlaceholderButtonStyleCapsule
};

/*!
 * [EN] One component of a placeholder: the item attributes of a CYLPlaceholderView and the action a tap on it performs.
 *      The class is Swift since 2026-11-19 (`CYLPlaceholderScenario.swift`) with the same Objective-C API: `attributes`,
 *      `action`, `imageBundle`, `spacingBefore`, `interactionEnabled`, `tapHighlightStyle`, `animationRepeatCount`,
 *      `+componentWithAttributes:action:` (Swift `init(attributes:action:)`),
 *      `+componentWithBundledAnimation:fallbackStyle:title:size:action:` (Swift
 *      `init(bundledAnimation:fallbackStyle:title:size:action:)`), `+hintComponentWithText:` (Swift `hint(text:)`),
 *      `+textComponentWithText:fontSize:color:` (Swift `text(_:fontSize:color:)`), `+buttonComponentWithTitle:style:action:`
 *      (Swift `button(title:style:action:)`), `+separatorComponentWithText:` (Swift `separator(text:)`) and
 *      `+componentWithDictionary:error:` (Swift `init(dictionary:)`, errors in `CYLPlaceholderConfigurationErrorDomain`
 *      with `CYLPlaceholderConfigurationErrorComponent`); it conforms to NSCopying, and `-init` / `+new` are
 *      unavailable. Objective-C code that messages it imports the umbrella header `CYLTableViewPlaceHolder.h`, which
 *      brings the generated Swift header.
 * [CN] 占位图的一个组件：CYLPlaceholderView 的条目属性及点击它时执行的动作。该类自 2026-11-19 起用 Swift 编写
 *      （`CYLPlaceholderScenario.swift`），Objective-C API 不变（含 Swift 名称与配置错误码），遵循 NSCopying。需要调用它的 Objective-C
 *      代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLPlaceholderComponent;

/*!
 * [EN] The definition of every scenario. The class is Swift since 2026-11-19 (`CYLPlaceholderScenario.swift`) with the
 *      same Objective-C API: `allScenarios`, `+componentsForScenario:` (Swift `components(for:)`),
 *      `+backgroundActionForScenario:` (Swift `backgroundAction(for:)`), `+localizedNameForScenario:` (Swift
 *      `localizedName(for:)`), `+readmeScreenshotNumbersForScenario:` (Swift `readmeScreenshotNumbers(for:)`),
 *      `+animationFileNamesForScenario:` (Swift `animationFileNames(for:)`), `+categoryForScenario:` (Swift
 *      `category(for:)`), `+permissionForScenario:` (Swift `permission(for:)`), `+scenarioForPermission:` (Swift
 *      `scenario(for:)`), `+nameForScenario:` (Swift `name(for:)`), `+scenarioNamed:` (Swift `scenario(named:)`),
 *      `+actionNamed:` (Swift `action(named:)`) and `+localizedTitleForAction:` (Swift `localizedTitle(for:)`); `-init` and
 *      `+new` are unavailable.
 * [CN] 所有场景的定义。该类自 2026-11-19 起用 Swift 编写（`CYLPlaceholderScenario.swift`），Objective-C API 不变（含 Swift 名称）。
 */
@class CYLPlaceholderScenarioCatalog;

NS_ASSUME_NONNULL_END
