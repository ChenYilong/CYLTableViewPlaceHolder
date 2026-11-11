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

#import <UIKit/UIKit.h>
#import "CYLPlaceholderView.h"

NS_ASSUME_NONNULL_BEGIN

/// Scenarios, grouped as the README's screenshots (structure first) and common business cases.
typedef NS_ENUM(NSInteger, CYLPlaceholderScenario) {
    /// Icon and title. README #04, #05, #06, #25, #36.
    CYLPlaceholderScenarioNetworkUnavailable,
    /// Icon and title for an empty list. README #07, #09, #10.
    CYLPlaceholderScenarioNoContent,
    /// Icon and title; tapping anywhere retries. README #13, #14, #15, #24, #26, #28, #31, #32, #37, #42, #43.
    CYLPlaceholderScenarioTapToReload,
    /// Icon, title and a hint. README #21, #22, #27, #29.
    CYLPlaceholderScenarioLoadFailedWithHint,
    /// Icon, title and a hint; tapping anywhere retries. README #08.
    CYLPlaceholderScenarioTapToReconnect,
    /// Icon, title and a filled "Retry" button (Ctrip). README #01, #02, #11, #19.
    CYLPlaceholderScenarioRetryButton,
    /// Icon, title and an outlined "Retry" button. README #33, #38, #39.
    CYLPlaceholderScenarioRetryOutlinedButton,
    /// Icon, title, a hint and an outlined "Reload" button. README #16, #23, #40.
    CYLPlaceholderScenarioRetryWithHint,
    /// Icon and title, a "Retry" button, an "or" separator and a "Contact support" button: four or more components
    /// and two actions (Ctrip). README #03.
    CYLPlaceholderScenarioRetryOrContactSupport,
    /// An illustration only, then a capsule "Tap to retry" title with a background image and rounded corners
    /// (SMZDM). README #18.
    CYLPlaceholderScenarioIllustrationRetry,
    /// Icon and title, then a tappable refresh icon. README #12.
    CYLPlaceholderScenarioRefreshIcon,
    /// A title above an illustration; tapping anywhere retries. README #17.
    CYLPlaceholderScenarioTitleAboveIllustration,
    /// A title and a hint, no icon; tapping anywhere retries. README #30, #41.
    CYLPlaceholderScenarioTextOnly,
    /// "Tap me", an arrow, a filled "Reload" button and a mascot. README #34, #35.
    CYLPlaceholderScenarioTapMeRetry,
    /// Permission missing, not a network failure: the app may not use the location, so nearby content cannot load.
    /// Location icon, title, a hint, an "Open Settings" button and "Choose address manually". README #20, which shows
    /// "Can't get the address, please choose manually" above a misleading "network error".
    CYLPlaceholderScenarioLocationPermissionDenied,
    /// Icon, title and a hint.
    CYLPlaceholderScenarioNoSearchResults,
    /// Icon, title and a "Go shopping" button.
    CYLPlaceholderScenarioEmptyCart,
    /// Icon, title and a "Go shopping" button.
    CYLPlaceholderScenarioNoOrders,
    /// Icon, title and a hint.
    CYLPlaceholderScenarioNoFavorites,
    /// Icon and title.
    CYLPlaceholderScenarioNoMessages,
    /// Icon, title and a hint.
    CYLPlaceholderScenarioNoNotifications,
    /// Permission missing, of no particular kind: lock icon, title, a hint and an "Open Settings" button.
    CYLPlaceholderScenarioNoPermission,
    /// Permission missing: camera. Icon, title, a hint and an "Open Settings" button, as every permission scenario.
    CYLPlaceholderScenarioCameraPermissionDenied,
    /// Permission missing: photo library.
    CYLPlaceholderScenarioPhotoLibraryPermissionDenied,
    /// Permission missing: microphone.
    CYLPlaceholderScenarioMicrophonePermissionDenied,
    /// Permission missing: contacts.
    CYLPlaceholderScenarioContactsPermissionDenied,
    /// Permission missing: calendar.
    CYLPlaceholderScenarioCalendarPermissionDenied,
    /// Permission missing: Bluetooth.
    CYLPlaceholderScenarioBluetoothPermissionDenied,
    /// Permission missing: notifications.
    CYLPlaceholderScenarioNotificationPermissionDenied,
    /// Icon, title, a hint and a "Retry" button.
    CYLPlaceholderScenarioServerError,
    /// Icon, title and a "Retry" button.
    CYLPlaceholderScenarioSyncFailed,
    /// Loading animation and title.
    CYLPlaceholderScenarioLoading,
    /// Uploading animation (GIF) and title.
    CYLPlaceholderScenarioUploading,
    /// Success animation, title and a "Done" button.
    CYLPlaceholderScenarioSuccess,
    CYLPlaceholderScenarioCount
};

/// What kind of problem a scenario shows, so an app can tell, for example, a missing permission from a network failure.
typedef NS_ENUM(NSInteger, CYLPlaceholderScenarioCategory) {
    /// The request failed: offline, slow network or server error. Retrying may help.
    CYLPlaceholderScenarioCategoryLoadFailed,
    /// Loaded, with nothing to show.
    CYLPlaceholderScenarioCategoryEmpty,
    /// The app may not access what it needs; retrying does not help until the user allows it in Settings.
    CYLPlaceholderScenarioCategoryPermission,
    /// Work in progress: loading, uploading.
    CYLPlaceholderScenarioCategoryProgress,
    /// A finished task.
    CYLPlaceholderScenarioCategorySuccess,
};

/// The system permission a permission scenario is about.
typedef NS_ENUM(NSInteger, CYLPlaceholderPermission) {
    /// Not a permission scenario, or a permission of no particular kind (CYLPlaceholderScenarioNoPermission).
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

/// What a tap on a component asks the app to do. Apps may define their own values.
typedef NSString *CYLPlaceholderAction NS_TYPED_EXTENSIBLE_ENUM;
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionRetry;
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionContactSupport;
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionOpenSettings;
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionGoShopping;
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionDone;
/// Go on without the permission by entering the value by hand, such as choosing an address instead of locating.
FOUNDATION_EXPORT CYLPlaceholderAction const CYLPlaceholderActionChooseManually;

/// How a button-like component draws its title.
typedef NS_ENUM(NSInteger, CYLPlaceholderButtonStyle) {
    /// White title on a filled, rounded background (Ctrip "Retry").
    CYLPlaceholderButtonStyleFilled,
    /// Colored title inside a rounded border.
    CYLPlaceholderButtonStyleOutlined,
    /// White title on a gradient background image with capsule corners (SMZDM "Tap to retry").
    CYLPlaceholderButtonStyleCapsule
};

/// One component of a placeholder: the item attributes of a CYLPlaceholderView (an icon, a title or both, see
/// `initWithItemAttributes:imageBundle:error:`) and the action a tap on it performs.
@interface CYLPlaceholderComponent : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *attributes;
/// nil: the component is not tappable.
@property (nonatomic, copy, readonly, nullable) CYLPlaceholderAction action;
/// Images named in `attributes` are looked up here; nil uses the library's bundle.
@property (nonatomic, strong, nullable) NSBundle *imageBundle;
/// Space above the component, from the one before it. Ignored for the first component.
@property (nonatomic) CGFloat spacingBefore;

+ (instancetype)componentWithAttributes:(NSDictionary<NSString *, id> *)attributes
                                 action:(nullable CYLPlaceholderAction)action
    NS_SWIFT_NAME(init(attributes:action:));
/// An icon (a bundled animation, see `+[CYLPlaceholderView bundledAnimationFileNames]`, with a static style shown
/// before it plays or when its engine is not installed) and an optional title.
+ (instancetype)componentWithBundledAnimation:(nullable NSString *)fileName
                                fallbackStyle:(CYLPlaceholderStyle)fallbackStyle
                                        title:(nullable NSString *)title
                                         size:(CGSize)size
                                       action:(nullable CYLPlaceholderAction)action
    NS_SWIFT_NAME(init(bundledAnimation:fallbackStyle:title:size:action:));
/// A secondary line of text under the title.
+ (instancetype)hintComponentWithText:(NSString *)text NS_SWIFT_NAME(hint(text:));
/// A title drawn as a button.
+ (instancetype)buttonComponentWithTitle:(NSString *)title
                                   style:(CYLPlaceholderButtonStyle)style
                                  action:(CYLPlaceholderAction)action NS_SWIFT_NAME(button(title:style:action:));
/// A title showing a separator, such as "——  or  ——".
+ (instancetype)separatorComponentWithText:(NSString *)text NS_SWIFT_NAME(separator(text:));

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/// The definition of every scenario. Texts are read in `CYLPlaceholderLocalization.effectiveLanguage` when called.
@interface CYLPlaceholderScenarioCatalog : NSObject

/// Every scenario, in declaration order, as NSNumber values of CYLPlaceholderScenario.
@property (class, nonatomic, copy, readonly) NSArray<NSNumber *> *allScenarios;
/// The components of a scenario, the reserved icon-and-title component first; empty for an invalid value.
+ (NSArray<CYLPlaceholderComponent *> *)componentsForScenario:(CYLPlaceholderScenario)scenario
    NS_SWIFT_NAME(components(for:));
/// The action of a tap anywhere outside a tappable component ("tap the screen to reload"), or nil.
+ (nullable CYLPlaceholderAction)backgroundActionForScenario:(CYLPlaceholderScenario)scenario
    NS_SWIFT_NAME(backgroundAction(for:));
/// A short localized name for lists.
+ (NSString *)localizedNameForScenario:(CYLPlaceholderScenario)scenario NS_SWIFT_NAME(localizedName(for:));
/// The README screenshot numbers (`assets/cyl-placeholder-scenario-NN-*.jpg`) the scenario reproduces; empty for
/// the business cases.
+ (NSArray<NSNumber *> *)readmeScreenshotNumbersForScenario:(CYLPlaceholderScenario)scenario
    NS_SWIFT_NAME(readmeScreenshotNumbers(for:));
/// The kind of problem a scenario shows.
+ (CYLPlaceholderScenarioCategory)categoryForScenario:(CYLPlaceholderScenario)scenario NS_SWIFT_NAME(category(for:));
/// The permission a scenario is about; CYLPlaceholderPermissionNone for other scenarios and for NoPermission.
+ (CYLPlaceholderPermission)permissionForScenario:(CYLPlaceholderScenario)scenario NS_SWIFT_NAME(permission(for:));
/// The scenario for a missing permission: CYLPlaceholderScenarioNoPermission for CYLPlaceholderPermissionNone.
+ (CYLPlaceholderScenario)scenarioForPermission:(CYLPlaceholderPermission)permission NS_SWIFT_NAME(scenario(for:));
/// The localized title of an action, such as "Retry"; nil for an action the library does not define.
+ (nullable NSString *)localizedTitleForAction:(CYLPlaceholderAction)action NS_SWIFT_NAME(localizedTitle(for:));

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
