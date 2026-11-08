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

/// Item keys use CYLTabBarController's serialized names without exporting its symbols.
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitle;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImage;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImageInsets;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImagePositionAdjustment;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitlePositionAdjustment;
/// Optional preset indices. Explicit title and image take precedence.
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
/// The following keys are reserved for future compatibility and are not rendered.
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedImage;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemDarkImage;
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedDarkImage;
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

/// A reusable, localized empty-state view. Customize its image and label as needed.
@interface CYLPlaceholderView : UIView
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *textLabel;

/// Original item attributes, including reserved animation keys. Animations are not played.
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *itemAttributes;
/// Creates a static FlatDesign-style item from CYLTabBarController-compatible item keys.
/// Images may be UIImage objects or names in imageBundle (nil uses the placeholder bundle).
- (nullable instancetype)initWithItemAttributes:(NSDictionary<NSString *, id> *)attributes
                                   imageBundle:(nullable NSBundle *)imageBundle
                                         error:(NSError * _Nullable * _Nullable)error;
/// Reads one item dictionary from a local property list.
- (nullable instancetype)initWithItemContentsOfURL:(NSURL *)url
                                      imageBundle:(nullable NSBundle *)imageBundle
                                            error:(NSError * _Nullable * _Nullable)error;

/// Uses independently selectable bundled art and localized text.
- (instancetype)initWithStyle:(CYLPlaceholderStyle)style message:(CYLPlaceholderMessage)message;
/// A custom string replaces the localized message; nil hides the label.
- (instancetype)initWithStyle:(CYLPlaceholderStyle)style text:(nullable NSString *)text;
/// Custom image and text; nil hides the corresponding content.
- (instancetype)initWithImage:(nullable UIImage *)image text:(nullable NSString *)text;
/// Images are loaded from the library's offline bundle. Invalid styles return nil and log an error.
+ (nullable UIImage *)imageForStyle:(CYLPlaceholderStyle)style;
/// The corresponding bundle image name, without the scale suffix or extension.
+ (nullable NSString *)imageNameForStyle:(CYLPlaceholderStyle)style;
/// Uses the current app language, with an English fallback.
+ (nullable NSString *)localizedTextForMessage:(CYLPlaceholderMessage)message;
@end

NS_ASSUME_NONNULL_END
