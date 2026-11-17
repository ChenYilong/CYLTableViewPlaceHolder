#import <UIKit/UIKit.h>
// [EN] CYLPlaceholderView subclasses CYLTabBarController's shared animated icon + title control, `CYLAnimatedItemView`
//      (subspec `CYLTabBarController/CYLAnimatedItem`; guide:
//      https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md).
// [CN] CYLPlaceholderView 继承自 CYLTabBarController 共用的动效 icon + title 控件 `CYLAnimatedItemView`
//      （子库 `CYLTabBarController/CYLAnimatedItem`；接入文档见上面的链接）。
#if __has_include(<CYLTabBarController/CYLAnimatedItemView.h>)
#import <CYLTabBarController/CYLAnimatedItemView.h>
#else
#import "CYLAnimatedItemView.h"
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
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieFilePath;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieSize;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieDarkURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieDarkFilePath;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieDarkColors;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieLoopsWhenUnselected;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGFilePath;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGSize;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGDarkURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGDarkFilePath;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveFilePath;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveSize;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveDarkURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveDarkFilePath;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveDarkColors;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFFilePath;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFSize;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFDarkURL;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFDarkFilePath;
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
 * [EN] A reusable, localized empty-state view: the packaged animated icon + title view of this library. It is a
 *      `CYLAnimatedItemView` (`axis` vertical by default): the icon plays any file of CYLTabBarController's animation
 *      engine when an animation subspec adds the engine, and shows its static image otherwise; the display priority,
 *      the failure fallbacks and the loading state of URL files are the base class's. Customize its image and label as
 *      needed.
 * [CN] 可复用、已本地化的空状态视图，即本库封装好的动效 icon + title 视图。它是一个 `CYLAnimatedItemView`（默认 `axis` 为纵向）：加入动画子库
 *      带入引擎后，图标可播放 CYLTabBarController 动画引擎支持的任意文件，否则显示静态图片；显示优先级、失败回退与 URL 文件的加载状态由基类处理。
 *      图片与文字可按需定制。
 */
@interface CYLPlaceholderView : CYLAnimatedItemView
/*!
 * [EN] The icon's image view (the base class's `imageView`). [CN] 图标的图片视图（基类的 `imageView`）。
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;
/*!
 * [EN] The title label: the base class's `titleLabel`. [CN] 标题标签，即基类的 `titleLabel`。
 */
@property (nonatomic, strong, readonly) UILabel *textLabel;
/*!
 * A nil value hides the badge; an empty string displays a dot.
 */
@property (nonatomic, copy, nullable) NSString *badgeValue UI_APPEARANCE_SELECTOR;
/*!
 * Badge appearance can be customized directly. VoiceOver can read it separately
 * when the placeholder is not itself an accessibility element.
 */
@property (nonatomic, strong, readonly) UILabel *badgeLabel;
/*!
 * Offset from the top-right of the image (or title when there is no image).
 */
@property (nonatomic) CGPoint badgeCenterOffset UI_APPEARANCE_SELECTOR;
/*!
 * Number badges use a maximum of 99; nonpositive numbers hide the badge.
 * Text badges require a nonempty string. Returns NO on invalid input.
 */
- (BOOL)showBadgeWithStyle:(CYLPlaceholderBadgeStyle)style value:(nullable NSString *)value
    NS_SWIFT_NAME(showBadge(with:value:));
/*!
 * Enables the configured selected image, title, font and colors. Defaults to NO.
 */
@property (nonatomic, getter=isSelected) BOOL selected;
/*!
 * Drawn behind the selected item. Resizable images fill the item; others are centered.
 */
@property (nonatomic, strong, nullable) UIImage *selectionIndicatorImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIColor *selectionIndicatorTintColor UI_APPEARANCE_SELECTOR;

/*!
 * Appearance layers, as in CYLFlatDesignTabBarButton: explicit item attributes win, then these
 * values (directly or through the UIAppearance proxy, applied live), then the built-in values.
 * A value set directly on `textLabel` or `imageView` is never overwritten. Without an icon color
 * the icon follows `tintColor`.
 * Default appearance values for normal state.
 */
@property (nonatomic, strong, nullable) UIColor *defaultTitleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIColor *defaultIconColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIColor *defaultBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIFont *defaultTitleFont UI_APPEARANCE_SELECTOR;
/*!
 * Title offset used when the item has no `CYLPlaceholderItemTitlePositionAdjustment` of its own.
 */
@property (nonatomic) UIOffset defaultTitlePositionAdjustment UI_APPEARANCE_SELECTOR;

/*!
 * Default appearance values for selected state. Can be customized via UIAppearance proxy.
 */
@property (nonatomic, strong, nullable) UIColor *defaultSelectedTitleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIColor *defaultSelectedIconColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIColor *defaultSelectedBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIFont *defaultSelectedTitleFont UI_APPEARANCE_SELECTOR;

/*!
 * Default selection indicator appearance.
 */
@property (nonatomic, strong, nullable) UIImage *defaultSelectionIndicatorImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIColor *defaultSelectionIndicatorTintColor UI_APPEARANCE_SELECTOR;

/*!
 * [EN] Original item attributes. An animation file (GIF, Lottie, PAG, Rive, SVGA…) plays when the view enters a window,
 *      through CYLTabBarController's animation engine and the animator of its type: add the matching subspec of this
 *      pod (or CYLTabBarController's `CYLAnimatedItem<Type>`). The Core subspec alone has no engine and shows the
 *      static image. The icon keeps the animation's size (`CYLPlaceholderItemAnimationSize`) whatever stands in for it.
 * [CN] 原始 item 属性。动画文件（GIF、Lottie、PAG、Rive、SVGA……）在视图进入窗口时，通过 CYLTabBarController 的动画引擎及对应类型的
 *      animator 播放：需加入本 pod 对应的子库（或 CYLTabBarController 的 `CYLAnimatedItem<Type>`）。只有 Core 子库时没有引擎，显示静态图片。
 *      无论用什么代替动画，图标都保持动画尺寸（`CYLPlaceholderItemAnimationSize`）。
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *itemAttributes;
/*!
 * NO (the default): the view fills the frame it is given and centers its content, as before. YES: it also reports its
 * content size as `intrinsicContentSize`, so a UIStackView or Auto Layout can size it. CYLPlaceholderStackView sets it
 * on its components.
 */
@property (nonatomic) BOOL reportsContentSize;
/*!
 * The widest the content may be when `reportsContentSize` is YES, padding included; 0 uses the screen width. Long
 * titles wrap within it.
 */
@property (nonatomic) CGFloat preferredMaxLayoutWidth;
/*!
 * [EN] The space kept between each side of the view and its content: 16 points by default, as a full-screen
 *      placeholder needs. A view narrower than its content plus both margins gives up the margins first, so the content
 *      stays centered and laid out instead of collapsing to zero width. A compact use, such as the icon of a refresh
 *      control (CYLRefreshIconView), sets 0.
 * [CN] 视图两侧与内容之间保留的距离：默认 16 点，适合全屏占位图。视图窄于内容加两侧边距时先放弃边距，内容保持居中并正常布局，而不会被压缩为
 *      零宽度。紧凑场景（如刷新控件的图标 CYLRefreshIconView）设为 0。
 */
@property (nonatomic) CGFloat contentMargin;

/*!
 * Runs when the placeholder is tapped. Called on the main thread.
 */
typedef void (^CYLPlaceholderTapHandler)(CYLPlaceholderView *placeholderView);

/*!
 * The placeholder's own tap event: runs only while `tapInteractionEnabled` is YES. Setting it makes the view
 * respond to taps (with the highlight of `tapHighlightStyle` and the button trait for VoiceOver); nil removes it.
 */
@property (nonatomic, copy, nullable) CYLPlaceholderTapHandler tapHandler;
/*!
 * Whether taps are handled. NO: the handler does not run and the pressed highlight does not show, and touches pass
 * through as before. Defaults to YES, or to `CYLPlaceholderItemInteractionEnabled`.
 */
@property (nonatomic, getter=isTapInteractionEnabled) BOOL tapInteractionEnabled;
/*!
 * The pressed look; defaults to Dim, or to `CYLPlaceholderItemTapHighlightStyle`.
 */
@property (nonatomic) CYLPlaceholderTapHighlightStyle tapHighlightStyle;
/*!
 * YES while a finger is down on a tappable placeholder.
 */
@property (nonatomic, readonly, getter=isTapHighlighted) BOOL tapHighlighted;
/*!
 * YES when a tap would run the handler: interaction is enabled and a handler is set.
 */
@property (nonatomic, readonly, getter=isTapInteractive) BOOL tapInteractive;
/*!
 * Runs the handler as a tap would; NO when the placeholder is not tap-interactive.
 */
- (BOOL)performTap;
/*!
 * How many times the animation plays each time it starts: 0 loops until stopped (`animationLoops`), N plays N times.
 * Defaults to 1, or to `CYLPlaceholderItemAnimationRepeatCount`. Players that loop or report their progress (Lottie,
 * PAG) support every value; others (GIF, Rive, SVGA) play as their file defines. Reduce Motion still stops the
 * animation.
 */
@property (nonatomic) NSInteger animationRepeatCount;

/*!
 * [EN] Registers or removes a factory for a file extension, without a leading dot, as an animator of
 *      CYLTabBarController's shared `CYLTabBarItemAnimatorRegistry` that wins over the built-in animators for that
 *      extension. Extensions are case-insensitive. Existing views keep their current player until their configuration
 *      is reloaded. Returns NO for an invalid extension, or when the build has no animation engine (CocoaPods Core
 *      alone).
 * [CN] 为某个文件扩展名（不带点）注册或移除工厂：作为 CYLTabBarController 共享 `CYLTabBarItemAnimatorRegistry` 中的 animator，对该扩展名优先于
 *      内置 animator。扩展名不区分大小写。已有视图在重新加载配置前保持当前播放器。扩展名无效或工程中没有动画引擎（只有 CocoaPods Core）时返回 NO。
 */
+ (BOOL)registerAnimationFactory:(nullable CYLPlaceholderAnimationFactory)factory
                forFileExtension:(NSString *)fileExtension;
/*!
 * [EN] Shows the animation file at `path` (a full path, or the name of a bundled animation) instead of the icon, at
 *      the icon's animation size (`CYLPlaceholderItemAnimationSize`, else 64 x 64 points), through the animator
 *      registered for its extension. NO, with the icon kept, when the file is missing or no animator plays it (always
 *      without an animation engine). The same
 *      as Android's `CYLPlaceholderView.setAnimationFile(path)`.
 * [CN] 用 `path` 处的动画文件（完整路径或内置动画名）代替图标显示，尺寸为图标的动画尺寸（`CYLPlaceholderItemAnimationSize`，否则为
 *      64 x 64 点），由该扩展名注册的动画器播放。文件不存在或没有动画器可播放时（没有动画引擎时总是如此）返回 NO，图标保持不变。与 Android 的
 *      `CYLPlaceholderView.setAnimationFile(path)` 相同。
 */
- (BOOL)setAnimationFile:(NSString *)path NS_SWIFT_NAME(setAnimationFile(_:));
/*!
 * Replay the configured animation when visible (`playAnimation` of the base class does the same). Honors Reduce
 * Motion.
 */
- (void)playPlaceholderAnimation;
/*!
 * Stop playback and show the resting frame until explicitly replayed (also `stopAnimation`).
 */
- (void)stopPlaceholderAnimation;
/*!
 * Stop and show the last frame when supported (also `showAnimationLastFrame`).
 */
- (void)showPlaceholderAnimationLastFrame;
/*!
 * Stops and seeks when supported. Returns NO for invalid values or unsupported players.
 */
- (BOOL)setPlaceholderAnimationProgress:(CGFloat)progress;
/*!
 * Sets a positive finite playback speed when supported. Returns NO otherwise.
 */
- (BOOL)setPlaceholderAnimationSpeed:(CGFloat)speed;
/*!
 * Creates a FlatDesign-style item from CYLTabBarController-compatible item keys.
 * Images may be UIImage objects or names in imageBundle (nil uses the placeholder bundle).
 */
- (nullable instancetype)initWithItemAttributes:(NSDictionary<NSString *, id> *)attributes
                                   imageBundle:(nullable NSBundle *)imageBundle
                                         error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(init(itemAttributes:imageBundle:));
/*!
 * Reads one item dictionary from a local property list.
 */
- (nullable instancetype)initWithItemContentsOfURL:(NSURL *)url
                                      imageBundle:(nullable NSBundle *)imageBundle
                                            error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(init(itemContentsOf:imageBundle:));

/*!
 * Uses independently selectable bundled art and localized text.
 */
- (instancetype)initWithStyle:(CYLPlaceholderStyle)style message:(CYLPlaceholderMessage)message;
/*!
 * A custom string replaces the localized message; nil hides the label.
 */
- (instancetype)initWithStyle:(CYLPlaceholderStyle)style text:(nullable NSString *)text;
/*!
 * Custom image and text; nil hides the corresponding content.
 */
- (instancetype)initWithImage:(nullable UIImage *)image text:(nullable NSString *)text;
/*!
 * Images are loaded from the library's offline bundle. Invalid styles return nil and log an error.
 */
+ (nullable UIImage *)imageForStyle:(CYLPlaceholderStyle)style;
/*!
 * The corresponding bundle image name, without the scale suffix or extension.
 */
+ (nullable NSString *)imageNameForStyle:(CYLPlaceholderStyle)style;
/*!
 * Uses the current app language, with an English fallback.
 */
+ (nullable NSString *)localizedTextForMessage:(CYLPlaceholderMessage)message;
/*!
 * File names of the ready-made animations in the library's resource bundle (`Animations/`), sorted:
 * Lottie (.json), PAG (.pag), Rive (.riv) and GIF (.gif) files named after their scenario, such as
 * "CYLPlaceholderLoading.json" or "CYLPlaceholderEmptyCart.json". Sources and licenses: NOTICE.animations.
 */
+ (NSArray<NSString *> *)bundledAnimationFileNames;
/*!
 * Full path of a bundled animation, for CYLPlaceholderItemAnimationFilePath and the engine-specific file
 * path keys; nil when there is no such file. Playback needs the matching animation subspec (the engine).
 */
+ (nullable NSString *)pathForBundledAnimation:(NSString *)fileName NS_SWIFT_NAME(path(forBundledAnimation:));
@end

NS_ASSUME_NONNULL_END
