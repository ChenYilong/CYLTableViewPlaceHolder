#import <UIKit/UIKit.h>
// [EN] CYLPlaceholderView subclasses the shared animated icon + title control `CYLAnimatedItemView`: CocoaPods pod
//      `CYLAnimatedItem` (module `CYLAnimatedItem`, from the CYLTabBarController repository); the Carthage framework
//      of CYLTabBarController compiles it into module `CYLTabBarController`. Guide:
//      https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md
// [CN] CYLPlaceholderView 继承自共用的动效 icon + title 控件 `CYLAnimatedItemView`：CocoaPods 为 `CYLAnimatedItem` pod
//      （模块 `CYLAnimatedItem`，位于 CYLTabBarController 仓库）；CYLTabBarController 的 Carthage framework 把它编译进
//      `CYLTabBarController` 模块。接入文档见上面的链接。
#if __has_include(<CYLAnimatedItem/CYLAnimatedItemView.h>)
#import <CYLAnimatedItem/CYLAnimatedItemView.h>
#elif __has_include(<CYLTabBarController/CYLAnimatedItemView.h>)
#import <CYLTabBarController/CYLAnimatedItemView.h>
#else
#import "CYLAnimatedItemView.h"
#endif

// [EN] Per-type guards from CYLAnimatedItemMacros.h (CYLAnimatedItem/Core): a type's keys compile without its engine and
//      only warn (the item then shows its static image, and debug builds log the pod to add). Defined empty when an
//      older CYLAnimatedItem does not provide them.
// [CN] 来自 CYLAnimatedItemMacros.h（CYLAnimatedItem/Core）的各类型开关：没有对应引擎时，该类型的 key 仍能编译，只产生警告（条目显示静态
//      图片，debug 构建输出需要加入的 pod）。旧版 CYLAnimatedItem 未提供时定义为空。
#ifndef CYL_LOTTIE_REQUIRED
#define CYL_LOTTIE_REQUIRED
#endif
#ifndef CYL_PAG_REQUIRED
#define CYL_PAG_REQUIRED
#endif
#ifndef CYL_RIVE_REQUIRED
#define CYL_RIVE_REQUIRED
#endif
#ifndef CYL_GIF_REQUIRED
#define CYL_GIF_REQUIRED
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLPlaceholderStyle) {
    CYLPlaceholderStyleEmpty,
    CYLPlaceholderStyleNoResults,
    CYLPlaceholderStyleError,
    CYLPlaceholderStyleWifiOff,
    CYLPlaceholderStyleSignalWifiOff,
    CYLPlaceholderStyleNoInternet,
    CYLPlaceholderStyleCloudOff,
    CYLPlaceholderStyleSyncProblem,
    CYLPlaceholderStyleSyncDisabled,
    CYLPlaceholderStyleNetworkLocked,
    CYLPlaceholderStyleBluetoothDisabled,
    CYLPlaceholderStyleLocationOff,
    CYLPlaceholderStylePublicOff,
    CYLPlaceholderStyleErrorOutline,
    CYLPlaceholderStyleWarning,
    CYLPlaceholderStyleReportProblem,
    CYLPlaceholderStyleBlocked,
    CYLPlaceholderStyleHelp,
    CYLPlaceholderStyleHourglass,
    CYLPlaceholderStyleLocked,
    CYLPlaceholderStyleVisibilityOff,
    CYLPlaceholderStyleSearchOff,
    CYLPlaceholderStyleFolderOff,
    CYLPlaceholderStyleFolderOpen,
    CYLPlaceholderStyleDownloadOff,
    CYLPlaceholderStyleUploadOff,
    CYLPlaceholderStyleInbox,
    CYLPlaceholderStyleBrokenImage,
    CYLPlaceholderStyleImageUnavailable,
    CYLPlaceholderStylePhotoLibrary,
    CYLPlaceholderStyleMusicOff,
    CYLPlaceholderStyleVideoOff,
    CYLPlaceholderStylePersonOff,
    CYLPlaceholderStyleGroupOff,
    CYLPlaceholderStyleEventBusy,
    CYLPlaceholderStyleEmptyCart,
    CYLPlaceholderStyleFavorite,
    CYLPlaceholderStyleBatteryAlert,
    CYLPlaceholderStyleUnknownDevice,
    CYLPlaceholderStylePhoneDisabled,
    CYLPlaceholderStyleWrongLocation,
    CYLPlaceholderStyleArchive,
    CYLPlaceholderStyleInfo,
    CYLPlaceholderStyleRefresh,
    CYLPlaceholderStyleDelete,
    CYLPlaceholderStyleSearch,
    CYLPlaceholderStyleMail,
    CYLPlaceholderStyleImage,
    CYLPlaceholderStyleCloud,
    CYLPlaceholderStyleNotificationsOff,
    CYLPlaceholderStyleHistory,
    CYLPlaceholderStyleCount
};

typedef NS_ENUM(NSInteger, CYLPlaceholderMessage) {
    CYLPlaceholderMessageEmpty,
    CYLPlaceholderMessageNoResults,
    CYLPlaceholderMessageNoInternet,
    CYLPlaceholderMessageServerUnavailable,
    CYLPlaceholderMessageError,
    CYLPlaceholderMessageLoading,
    CYLPlaceholderMessageNoPermission,
    CYLPlaceholderMessageEmptyCart,
    CYLPlaceholderMessageNoNotifications,
    CYLPlaceholderMessageCount
};

/*!
 * How a tappable placeholder looks while it is pressed.
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderTapHighlightStyle) {
    /*!
     * The content dims to half opacity (the default).
     */
    CYLPlaceholderTapHighlightStyleDim,
    /*!
     * The content shrinks slightly and dims a little.
     */
    CYLPlaceholderTapHighlightStyleShrink,
    /*!
     * No visual change; the tap still runs the handler.
     */
    CYLPlaceholderTapHighlightStyleNone,
};

typedef NS_ENUM(NSInteger, CYLPlaceholderBadgeStyle) {
    CYLPlaceholderBadgeStyleNone,
    CYLPlaceholderBadgeStyleDot,
    CYLPlaceholderBadgeStyleNumber,
    CYLPlaceholderBadgeStyleText
};

/*!
 * Badge appearance configuration for shared/customizable badge styling.
 * Use with UIAppearance proxy for global defaults.
 */
@interface CYLPlaceholderBadgeAppearance : NSObject
@property (nonatomic, strong, nullable) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIFont *font UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;
/*!
 * Animation duration for badge show/hide. Default 0.2s.
 */
@property (nonatomic) CGFloat animationDuration UI_APPEARANCE_SELECTOR;
/*!
 * Whether to animate badge changes. Default YES.
 */
@property (nonatomic) BOOL animatesChanges UI_APPEARANCE_SELECTOR;
+ (instancetype)sharedAppearance;
@end

/*!
 * Item keys use CYLTabBarController's serialized names without exporting its symbols.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitle;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImage;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImageInsets;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImagePositionAdjustment;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitlePositionAdjustment;
/*!
 * Optional preset indices. Explicit title and image take precedence.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemStyle;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemMessage;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationFilePath;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationSize;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleColor;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemIconColor;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemBackgroundColor;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleFont;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAccessibilityIdentifier;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAccessibilityLabel;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAccessibilityHint;
/*!
 * Selected appearance keys are used when the placeholder's selected property is set.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedImage;
/*!
 * Dark static image variants follow the view's appearance on iOS 13 and later.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemDarkImage;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedDarkImage;
/*!
 * Remote-image and navigation keys are reserved for compatibility.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImageURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedImageURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImageURLSize;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemIdentifier;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPageIdentifier;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPageParameters;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPlatforms;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemMinimumAppVersion;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedTitle;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedTitleColor;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedIconColor;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedBackgroundColor;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedTitleFont;
/*!
 * Local animation sources, sizes, and Lottie color overrides are supported.
 * Other backend-specific options are retained for compatibility; see the README.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationDarkURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationDarkFilePath;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationColors;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationDarkColors;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationOptions;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieURL CYL_LOTTIE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieFilePath CYL_LOTTIE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieSize CYL_LOTTIE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieDarkURL CYL_LOTTIE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieDarkFilePath CYL_LOTTIE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieDarkColors CYL_LOTTIE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieLoopsWhenUnselected CYL_LOTTIE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGURL CYL_PAG_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGFilePath CYL_PAG_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGSize CYL_PAG_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGDarkURL CYL_PAG_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGDarkFilePath CYL_PAG_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveURL CYL_RIVE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveFilePath CYL_RIVE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveSize CYL_RIVE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveDarkURL CYL_RIVE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveDarkFilePath CYL_RIVE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveDarkColors CYL_RIVE_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFURL CYL_GIF_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFFilePath CYL_GIF_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFSize CYL_GIF_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFDarkURL CYL_GIF_REQUIRED;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFDarkFilePath CYL_GIF_REQUIRED;
/*!
 * Title chrome, for components that read as buttons (see CYLPlaceholderStackView): an image (UIImage or name, drawn
 * stretched; give it cap insets for a resizable look) or color behind the title, a border, a corner radius (clamped to
 * half the height, so a large value draws a capsule), padding around the text (insets: array, dictionary or NSValue)
 * and a minimum width (points). Without these keys the title stays plain text and the layout is unchanged.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleBackgroundImage;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleBackgroundColor;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleBorderColor;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleBorderWidth;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleCornerRadius;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleContentInsets;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleMinimumWidth;
/*!
 * [EN] How the icon and the title are arranged: "vertical" (the default, the icon above the centered title, as before)
 *      or "horizontal" (the icon at the leading edge and the title after it, both centered vertically and aligned to
 *      the leading edge, mirrored for right-to-left languages), or a `UILayoutConstraintAxis` number. A horizontal item
 *      suits a one-line bar such as `CYLPlaceholderStatusView`.
 * [CN] 图标与标题的排列方式："vertical"（默认，图标在居中的标题上方，与以前相同）或 "horizontal"（图标在前缘，标题在其后，二者垂直居中并
 *      靠前缘对齐，右到左语言自动镜像），也可以是 `UILayoutConstraintAxis` 数值。横向排列适合单行提示条，如 `CYLPlaceholderStatusView`。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemContentAxis;
/*!
 * Tap interaction (see `tapInteractionEnabled`): a boolean; NO turns off both the tap handler and the highlight.
 * Absent means YES.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemInteractionEnabled;
/*!
 * The pressed look (see `tapHighlightStyle`): a CYLPlaceholderTapHighlightStyle number or "dim", "shrink", "none".
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTapHighlightStyle;
/*!
 * Animation playback (see `animationRepeatCount`): a number, 0 loops until stopped, N plays N times; or the strings
 * "loop" and "once". Absent means once, as before.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationRepeatCount;
/*!
 * [EN] Image frames played in a loop as the icon: an array of UIImage, used when `CYLPlaceholderItemImage` is absent
 *      (with Reduce Motion only the first frame shows). The same key as Android's `CYLRefreshIconView.IMAGES`.
 * [CN] 循环播放的图标帧：UIImage 数组，在没有 `CYLPlaceholderItemImage` 时使用（开启“减弱动态效果”时只显示第一帧）。与 Android 的
 *      `CYLRefreshIconView.IMAGES` 为同一个 key。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImages;
/*!
 * [EN] The total duration of `CYLPlaceholderItemImages`, in seconds (a number); absent means 0.1 seconds per frame. The
 *      same key as Android's `CYLRefreshIconView.DURATION`.
 * [CN] `CYLPlaceholderItemImages` 的总时长，单位秒（数字）；缺省时每帧 0.1 秒。与 Android 的 `CYLRefreshIconView.DURATION` 为同一个 key。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationDuration;
/*!
 * [EN] The error domain of a refused configuration (item attributes, a component, a stack view, a status bar or a
 *      status configuration); Swift sees it as `CYLPlaceholderConfigurationError`, the name of Android's exception.
 * [CN] 配置被拒绝时的错误域（item 属性、组件、组件栈、状态条或状态配置）；Swift 中为 `CYLPlaceholderConfigurationError`，与 Android 的异常同名。
 */
FOUNDATION_EXPORT NSErrorDomain const CYLPlaceholderConfigurationErrorDomain;
/*!
 * [EN] Which configuration was refused. [CN] 被拒绝的配置种类。
 */
typedef NS_ERROR_ENUM(CYLPlaceholderConfigurationErrorDomain, CYLPlaceholderConfigurationErrorCode) {
    /*!
     * [EN] Item attributes (`CYLPlaceholderView`). [CN] item 属性（`CYLPlaceholderView`）。
     */
    CYLPlaceholderConfigurationErrorItemAttributes = 1,
    /*!
     * [EN] A component (`CYLPlaceholderComponent`). [CN] 组件（`CYLPlaceholderComponent`）。
     */
    CYLPlaceholderConfigurationErrorComponent = 2,
    /*!
     * [EN] A stack view (`CYLPlaceholderStackView`). [CN] 组件栈（`CYLPlaceholderStackView`）。
     */
    CYLPlaceholderConfigurationErrorStackView = 3,
    /*!
     * [EN] A status bar (`CYLPlaceholderStatusView`). [CN] 状态条（`CYLPlaceholderStatusView`）。
     */
    CYLPlaceholderConfigurationErrorStatusView = 4,
    /*!
     * [EN] A status configuration (`cyl_applyStatusConfiguration:error:`). [CN] 状态配置（`cyl_applyStatusConfiguration:error:`）。
     */
    CYLPlaceholderConfigurationErrorStatusConfiguration = 5,
};

/*!
 * [EN] A view made by a factory registered with `+registerAnimationFactory:forFileExtension:`. It must invoke its
 *      handlers on the main thread. CYLPlaceholderView plays it through CYLTabBarController's animation engine, which
 *      is needed for any animation to play.
 * [CN] 由 `+registerAnimationFactory:forFileExtension:` 注册的工厂创建的视图，必须在主线程调用其回调。CYLPlaceholderView 通过
 *      CYLTabBarController 的动画引擎播放它，播放任何动画都需要该引擎。
 */
@protocol CYLPlaceholderAnimationPlayer <NSObject>
@property (nonatomic, readonly, getter=isReady) BOOL ready;
@property (nonatomic, copy, nullable) void (^errorHandler)(NSError *error);
@property (nonatomic, copy, nullable) void (^readyHandler)(void);
- (void)play;
- (void)stop;
- (void)showLastFrame;
@optional
- (BOOL)setAnimationProgress:(CGFloat)progress;
- (BOOL)setAnimationSpeed:(CGFloat)speed;
/*!
 * 0 loops until stopped; N plays N times. Return NO when unsupported (the animation then plays once).
 */
- (BOOL)setAnimationRepeatCount:(NSInteger)repeatCount;
/*!
 * Replace all keypath color overrides. Return NO when unsupported.
 */
- (BOOL)setAnimationColors:(NSDictionary<NSString *, UIColor *> *)colors;
@end

typedef UIView<CYLPlaceholderAnimationPlayer> * _Nullable (^CYLPlaceholderAnimationFactory)(
    NSURL *fileURL, CGSize size, UIViewContentMode contentMode,
    NSDictionary<NSString *, id> *options, NSError * _Nullable * _Nullable error);

/*!
 * [EN] The class itself is Swift since 2026-11-19 (`CYLPlaceholderView.swift`): CYLTabBarController's `CYLAnimatedItemView`
 *      became Swift, and Objective-C cannot subclass a Swift class. Its Objective-C API is unchanged (class name,
 *      selectors, properties). This header keeps what Swift cannot declare for Objective-C (the `CYLPlaceholderItem*` keys,
 *      the enums, the error domain, the animation player protocol, the factory block and the badge appearance) and
 *      forward-declares the class. Objective-C code that messages the view imports the umbrella header
 *      `CYLTableViewPlaceHolder.h` (or `@import CYLTableViewPlaceHolder;`), which brings the generated Swift interface.
 * [CN] 该类自 2026-11-19 起用 Swift 编写（`CYLPlaceholderView.swift`）：CYLTabBarController 的 `CYLAnimatedItemView` 改为 Swift，而
 *      Objective-C 不能继承 Swift 类。其 Objective-C API 不变（类名、selector、属性）。本头文件保留 Swift 无法为 Objective-C 声明的部分
 *      （`CYLPlaceholderItem*` key、枚举、错误域、动画播放器协议、工厂 block 与角标外观），并前向声明该类。需要调用该视图的 Objective-C 代码导入
 *      伞头文件 `CYLTableViewPlaceHolder.h`（或 `@import CYLTableViewPlaceHolder;`），从而获得生成的 Swift 接口。
 */
@class CYLPlaceholderView;

#ifndef __swift__
/*!
 * [EN] Runs when the placeholder is tapped. Called on the main thread. Swift sees the property as
 *      `((CYLPlaceholderView) -> Void)?`.
 * [CN] 点击占位图时执行，在主线程调用。Swift 中该属性的类型为 `((CYLPlaceholderView) -> Void)?`。
 */
typedef void (^CYLPlaceholderTapHandler)(CYLPlaceholderView *placeholderView);
#endif

NS_ASSUME_NONNULL_END
