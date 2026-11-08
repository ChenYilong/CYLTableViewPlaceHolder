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

/// A reusable, localized empty-state view. Customize its image and label as needed.
@interface CYLPlaceholderView : UIView
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *textLabel;

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
