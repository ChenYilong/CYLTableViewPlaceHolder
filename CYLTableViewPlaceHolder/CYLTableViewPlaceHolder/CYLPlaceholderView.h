#import <UIKit/UIKit.h>

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

/*! How a tappable placeholder looks while it is pressed. */
typedef NS_ENUM(NSInteger, CYLPlaceholderTapHighlightStyle) {
    /*! The content dims to half opacity (the default). */
    CYLPlaceholderTapHighlightStyleDim,
    /*! The content shrinks slightly and dims a little. */
    CYLPlaceholderTapHighlightStyleShrink,
    /*! No visual change; the tap still runs the handler. */
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
/*! Animation duration for badge show/hide. Default 0.2s. */
@property (nonatomic) CGFloat animationDuration UI_APPEARANCE_SELECTOR;
/*! Whether to animate badge changes. Default YES. */
@property (nonatomic) BOOL animatesChanges UI_APPEARANCE_SELECTOR;
+ (instancetype)sharedAppearance;
@end

/*! Item keys use CYLTabBarController's serialized names without exporting its symbols. */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitle;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImage;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImageInsets;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImagePositionAdjustment;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitlePositionAdjustment;
/*! Optional preset indices. Explicit title and image take precedence. */
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
/*! Selected appearance keys are used when the placeholder's selected property is set. */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedImage;
/*! Dark static image variants follow the view's appearance on iOS 13 and later. */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemDarkImage;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedDarkImage;
/*! Remote-image and navigation keys are reserved for compatibility. */
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
/*! The pressed look (see `tapHighlightStyle`): a CYLPlaceholderTapHighlightStyle number or "dim", "shrink", "none". */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTapHighlightStyle;
/*!
 * Animation playback (see `animationRepeatCount`): a number, 0 loops until stopped, N plays N times; or the strings
 * "loop" and "once". Absent means once, as before.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationRepeatCount;

/*! Animation views supplied by custom factories must invoke handlers on the main thread. */
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
/*! 0 loops until stopped; N plays N times. Return NO when unsupported (the animation then plays once). */
- (BOOL)setAnimationRepeatCount:(NSInteger)repeatCount;
/*! Replace all keypath color overrides. Return NO when unsupported. */
- (BOOL)setAnimationColors:(NSDictionary<NSString *, UIColor *> *)colors;
@end

typedef UIView<CYLPlaceholderAnimationPlayer> * _Nullable (^CYLPlaceholderAnimationFactory)(
    NSURL *fileURL, CGSize size, UIViewContentMode contentMode,
    NSDictionary<NSString *, id> *options, NSError * _Nullable * _Nullable error);

/*! A reusable, localized empty-state view. Customize its image and label as needed. */
@interface CYLPlaceholderView : UIView
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *textLabel;
/*! A nil value hides the badge; an empty string displays a dot. */
@property (nonatomic, copy, nullable) NSString *badgeValue UI_APPEARANCE_SELECTOR;
/*!
 * Badge appearance can be customized directly. VoiceOver can read it separately
 * when the placeholder is not itself an accessibility element.
 */
@property (nonatomic, strong, readonly) UILabel *badgeLabel;
/*! Offset from the top-right of the image (or title when there is no image). */
@property (nonatomic) CGPoint badgeCenterOffset UI_APPEARANCE_SELECTOR;
/*!
 * Number badges use a maximum of 99; nonpositive numbers hide the badge.
 * Text badges require a nonempty string. Returns NO on invalid input.
 */
- (BOOL)showBadgeWithStyle:(CYLPlaceholderBadgeStyle)style value:(nullable NSString *)value
    NS_SWIFT_NAME(showBadge(with:value:));
/*! Enables the configured selected image, title, font and colors. Defaults to NO. */
@property (nonatomic, getter=isSelected) BOOL selected;
/*! Drawn behind the selected item. Resizable images fill the item; others are centered. */
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
/*! Title offset used when the item has no `CYLPlaceholderItemTitlePositionAdjustment` of its own. */
@property (nonatomic) UIOffset defaultTitlePositionAdjustment UI_APPEARANCE_SELECTOR;

/*! Default appearance values for selected state. Can be customized via UIAppearance proxy. */
@property (nonatomic, strong, nullable) UIColor *defaultSelectedTitleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIColor *defaultSelectedIconColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIColor *defaultSelectedBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIFont *defaultSelectedTitleFont UI_APPEARANCE_SELECTOR;

/*! Default selection indicator appearance. */
@property (nonatomic, strong, nullable) UIImage *defaultSelectionIndicatorImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, nullable) UIColor *defaultSelectionIndicatorTintColor UI_APPEARANCE_SELECTOR;

/*!
 * Original item attributes. Local GIF animations play once when the view enters a window.
 * Optional Lottie, PAG and Rive backends require their corresponding CocoaPods subspec.
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

/*! Runs when the placeholder is tapped. Called on the main thread. */
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
/*! The pressed look; defaults to Dim, or to `CYLPlaceholderItemTapHighlightStyle`. */
@property (nonatomic) CYLPlaceholderTapHighlightStyle tapHighlightStyle;
/*! YES while a finger is down on a tappable placeholder. */
@property (nonatomic, readonly, getter=isTapHighlighted) BOOL tapHighlighted;
/*! YES when a tap would run the handler: interaction is enabled and a handler is set. */
@property (nonatomic, readonly, getter=isTapInteractive) BOOL tapInteractive;
/*! Runs the handler as a tap would; NO when the placeholder is not tap-interactive. */
- (BOOL)performTap;
/*!
 * How many times the animation plays each time it starts: 0 loops until stopped, N plays N times. Defaults to 1, or
 * to `CYLPlaceholderItemAnimationRepeatCount`. GIF, Lottie and PAG support every value; Rive supports 0 and 1 for a
 * named animation, while a state machine follows the file. Reduce Motion still stops the animation.
 */
@property (nonatomic) NSInteger animationRepeatCount;

/*!
 * Registers or removes a factory for a local file extension, without a leading dot.
 * Extensions are case-insensitive. GIF remains reserved for the built-in decoder.
 * Existing views keep their current player until their configuration is reloaded.
 */
+ (BOOL)registerAnimationFactory:(nullable CYLPlaceholderAnimationFactory)factory
                forFileExtension:(NSString *)fileExtension;
/*! Replay the configured animation when visible. Honors Reduce Motion. */
- (void)playPlaceholderAnimation;
/*! Stop playback and show the resting frame until explicitly replayed. */
- (void)stopPlaceholderAnimation;
/*! Stop and show the last frame when supported; Rive returns to its resting state. */
- (void)showPlaceholderAnimationLastFrame;
/*! Stops and seeks when supported. Returns NO for invalid values or unsupported players. */
- (BOOL)setPlaceholderAnimationProgress:(CGFloat)progress;
/*! Sets a positive finite playback speed when supported. Returns NO otherwise. */
- (BOOL)setPlaceholderAnimationSpeed:(CGFloat)speed;
/*!
 * Creates a FlatDesign-style item from CYLTabBarController-compatible item keys.
 * Images may be UIImage objects or names in imageBundle (nil uses the placeholder bundle).
 */
- (nullable instancetype)initWithItemAttributes:(NSDictionary<NSString *, id> *)attributes
                                   imageBundle:(nullable NSBundle *)imageBundle
                                         error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(init(itemAttributes:imageBundle:));
/*! Reads one item dictionary from a local property list. */
- (nullable instancetype)initWithItemContentsOfURL:(NSURL *)url
                                      imageBundle:(nullable NSBundle *)imageBundle
                                            error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(init(itemContentsOf:imageBundle:));

/*! Uses independently selectable bundled art and localized text. */
- (instancetype)initWithStyle:(CYLPlaceholderStyle)style message:(CYLPlaceholderMessage)message;
/*! A custom string replaces the localized message; nil hides the label. */
- (instancetype)initWithStyle:(CYLPlaceholderStyle)style text:(nullable NSString *)text;
/*! Custom image and text; nil hides the corresponding content. */
- (instancetype)initWithImage:(nullable UIImage *)image text:(nullable NSString *)text;
/*! Images are loaded from the library's offline bundle. Invalid styles return nil and log an error. */
+ (nullable UIImage *)imageForStyle:(CYLPlaceholderStyle)style;
/*! The corresponding bundle image name, without the scale suffix or extension. */
+ (nullable NSString *)imageNameForStyle:(CYLPlaceholderStyle)style;
/*! Uses the current app language, with an English fallback. */
+ (nullable NSString *)localizedTextForMessage:(CYLPlaceholderMessage)message;
/*!
 * File names of the ready-made animations in the library's resource bundle (`Animations/`), sorted:
 * Lottie (.json), PAG (.pag), Rive (.riv) and GIF (.gif) files named after their scenario, such as
 * "CYLPlaceholderLoading.json" or "CYLPlaceholderEmptyCart.json". Sources and licenses: NOTICE.animations.
 */
+ (NSArray<NSString *> *)bundledAnimationFileNames;
/*!
 * Full path of a bundled animation, for CYLPlaceholderItemAnimationFilePath and the engine-specific file
 * path keys; nil when there is no such file. Lottie, PAG and Rive playback needs the matching subspec.
 */
+ (nullable NSString *)pathForBundledAnimation:(NSString *)fileName NS_SWIFT_NAME(path(forBundledAnimation:));
@end

NS_ASSUME_NONNULL_END
