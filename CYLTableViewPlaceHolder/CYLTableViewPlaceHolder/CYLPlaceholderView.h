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

/*!
 * [EN] The bundled icon of a placeholder. Each value selects one image of the library's resource bundle, named
 *      "CYLPlaceholder" followed by the value's name (see `+imageNameForStyle:`), loaded by `+imageForStyle:` and used
 *      by `CYLPlaceholderItemStyle` when no `CYLPlaceholderItemImage` is given. Apart from `CYLPlaceholderStyleEmpty`,
 *      the icons are Material Design icons returned as template images, so they are drawn in the icon color (tint
 *      color).
 * [CN] 占位图的内置图标。每个值对应本库资源包中的一张图片，名称为 "CYLPlaceholder" 加该值的名字（见
 *      `+imageNameForStyle:`），由 `+imageForStyle:` 加载，在没有 `CYLPlaceholderItemImage` 时供
 *      `CYLPlaceholderItemStyle` 使用。除 `CYLPlaceholderStyleEmpty` 外均为 Material Design 图标，以模板图片返回，因此
 *      按图标颜色（tint color）绘制。
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderStyle) {
    /*!
     * [EN] The icon of a gray empty tray with lines above it ("CYLPlaceholderEmpty"), the general "nothing here yet"
     *      illustration; the only style drawn in its own colors instead of the tint color, and the image a new view
     *      shows.
     * [CN] 图标为上方带横线的灰色空托盘（"CYLPlaceholderEmpty"），通用的“暂无内容”插图；唯一按自身颜色而非 tint color
     *      绘制的样式，也是新建视图默认显示的图片。
     */
    CYLPlaceholderStyleEmpty,
    /*!
     * [EN] The icon of a struck-through magnifying glass ("CYLPlaceholderNoResults", the same image as
     *      `CYLPlaceholderStyleSearchOff`), for a search without results.
     * [CN] 图标为带斜线的放大镜（"CYLPlaceholderNoResults"，与 `CYLPlaceholderStyleSearchOff` 为同一张图），用于搜索无
     *      结果。
     */
    CYLPlaceholderStyleNoResults,
    /*!
     * [EN] The icon of an exclamation mark in an outlined circle ("CYLPlaceholderError", the same image as
     *      `CYLPlaceholderStyleErrorOutline`), for a general error.
     * [CN] 图标为空心圆中的感叹号（"CYLPlaceholderError"，与 `CYLPlaceholderStyleErrorOutline` 为同一张图），用于一般错
     *      误。
     */
    CYLPlaceholderStyleError,
    /*!
     * [EN] The icon of a struck-through Wi-Fi symbol (Material wifi_off), for Wi-Fi that is off or unavailable.
     * [CN] 图标为带斜线的 Wi-Fi 图标（Material wifi_off），用于 Wi-Fi 关闭或不可用。
     */
    CYLPlaceholderStyleWifiOff,
    /*!
     * [EN] The icon of a struck-through Wi-Fi signal fan (Material signal_wifi_off), for no Wi-Fi signal.
     * [CN] 图标为带斜线的 Wi-Fi 信号扇形（Material signal_wifi_off），用于没有 Wi-Fi 信号。
     */
    CYLPlaceholderStyleSignalWifiOff,
    /*!
     * [EN] The icon of a full Wi-Fi signal with an exclamation mark (Material signal_wifi_connected_no_internet_4), for
     *      a connected network without internet access.
     * [CN] 图标为带感叹号的满格 Wi-Fi 信号（Material signal_wifi_connected_no_internet_4），用于已连接网络但无法访问互
     *      联网。
     */
    CYLPlaceholderStyleNoInternet,
    /*!
     * [EN] The icon of a struck-through cloud (Material cloud_off), for an online service or cloud content that cannot
     *      be reached.
     * [CN] 图标为带斜线的云（Material cloud_off），用于无法连接在线服务或云端内容。
     */
    CYLPlaceholderStyleCloudOff,
    /*!
     * [EN] The icon of circular sync arrows with an exclamation mark (Material sync_problem), for a failed sync.
     * [CN] 图标为带感叹号的环形同步箭头（Material sync_problem），用于同步失败。
     */
    CYLPlaceholderStyleSyncProblem,
    /*!
     * [EN] The icon of struck-through sync arrows (Material sync_disabled), for sync that is turned off.
     * [CN] 图标为带斜线的同步箭头（Material sync_disabled），用于同步已关闭。
     */
    CYLPlaceholderStyleSyncDisabled,
    /*!
     * [EN] The icon of a cellular signal triangle with a padlock (Material network_locked), for a locked or restricted
     *      network.
     * [CN] 图标为带锁的蜂窝信号三角（Material network_locked），用于网络被锁定或受限。
     */
    CYLPlaceholderStyleNetworkLocked,
    /*!
     * [EN] The icon of a struck-through Bluetooth symbol (Material bluetooth_disabled), for Bluetooth that is off.
     * [CN] 图标为带斜线的蓝牙图标（Material bluetooth_disabled），用于蓝牙已关闭。
     */
    CYLPlaceholderStyleBluetoothDisabled,
    /*!
     * [EN] The icon of a struck-through location pin (Material location_off), for location services that are off.
     * [CN] 图标为带斜线的定位图钉（Material location_off），用于定位服务已关闭。
     */
    CYLPlaceholderStyleLocationOff,
    /*!
     * [EN] The icon of a struck-through globe (Material public_off), for public or internet content that is
     *      unavailable.
     * [CN] 图标为带斜线的地球（Material public_off），用于公开内容或互联网内容不可用。
     */
    CYLPlaceholderStylePublicOff,
    /*!
     * [EN] The icon of an exclamation mark in an outlined circle (Material error_outline), the same image as
     *      `CYLPlaceholderStyleError`.
     * [CN] 图标为空心圆中的感叹号（Material error_outline），与 `CYLPlaceholderStyleError` 为同一张图。
     */
    CYLPlaceholderStyleErrorOutline,
    /*!
     * [EN] The icon of an exclamation mark in a filled triangle (Material warning), for a warning.
     * [CN] 图标为实心三角中的感叹号（Material warning），用于警告。
     */
    CYLPlaceholderStyleWarning,
    /*!
     * [EN] The icon of an exclamation mark in a filled triangle (Material report_problem), the same image as
     *      `CYLPlaceholderStyleWarning`, for a problem to report.
     * [CN] 图标为实心三角中的感叹号（Material report_problem），与 `CYLPlaceholderStyleWarning` 为同一张图，用于需要反
     *      馈的问题。
     */
    CYLPlaceholderStyleReportProblem,
    /*!
     * [EN] The icon of a circle with a diagonal bar (Material block), for blocked or forbidden content.
     * [CN] 图标为带斜杠的圆（Material block），用于被屏蔽或禁止访问的内容。
     */
    CYLPlaceholderStyleBlocked,
    /*!
     * [EN] The icon of a question mark in an outlined circle (Material help_outline), for help or an unknown state.
     * [CN] 图标为空心圆中的问号（Material help_outline），用于帮助或未知状态。
     */
    CYLPlaceholderStyleHelp,
    /*!
     * [EN] The icon of an empty hourglass (Material hourglass_empty), for waiting or content that is not available yet.
     * [CN] 图标为空沙漏（Material hourglass_empty），用于等待或内容暂未就绪。
     */
    CYLPlaceholderStyleHourglass,
    /*!
     * [EN] The icon of an outlined padlock (Material lock_outline), for locked or protected content.
     * [CN] 图标为空心挂锁（Material lock_outline），用于已锁定或受保护的内容。
     */
    CYLPlaceholderStyleLocked,
    /*!
     * [EN] The icon of a struck-through eye (Material visibility_off), for hidden content.
     * [CN] 图标为带斜线的眼睛（Material visibility_off），用于被隐藏的内容。
     */
    CYLPlaceholderStyleVisibilityOff,
    /*!
     * [EN] The icon of a struck-through magnifying glass (Material search_off), the same image as
     *      `CYLPlaceholderStyleNoResults`, for search that is unavailable or finds nothing.
     * [CN] 图标为带斜线的放大镜（Material search_off），与 `CYLPlaceholderStyleNoResults` 为同一张图，用于搜索不可用或
     *      无结果。
     */
    CYLPlaceholderStyleSearchOff,
    /*!
     * [EN] The icon of a struck-through folder (Material folder_off), for a folder that is unavailable.
     * [CN] 图标为带斜线的文件夹（Material folder_off），用于文件夹不可用。
     */
    CYLPlaceholderStyleFolderOff,
    /*!
     * [EN] The icon of an open outlined folder (Material folder_open), for an empty folder.
     * [CN] 图标为打开的空心文件夹（Material folder_open），用于空文件夹。
     */
    CYLPlaceholderStyleFolderOpen,
    /*!
     * [EN] The icon of a struck-through download arrow (Material file_download_off), for downloads that are
     *      unavailable.
     * [CN] 图标为带斜线的下载箭头（Material file_download_off），用于下载不可用。
     */
    CYLPlaceholderStyleDownloadOff,
    /*!
     * [EN] The icon of a struck-through upload arrow (Material file_upload_off), for uploads that are unavailable.
     * [CN] 图标为带斜线的上传箭头（Material file_upload_off），用于上传不可用。
     */
    CYLPlaceholderStyleUploadOff,
    /*!
     * [EN] The icon of an inbox tray (Material inbox), for an empty inbox.
     * [CN] 图标为收件箱托盘（Material inbox），用于空收件箱。
     */
    CYLPlaceholderStyleInbox,
    /*!
     * [EN] The icon of a torn picture (Material broken_image), for an image that failed to load.
     * [CN] 图标为撕裂的图片（Material broken_image），用于图片加载失败。
     */
    CYLPlaceholderStyleBrokenImage,
    /*!
     * [EN] The icon of a struck-through picture (Material image_not_supported), for an image that is unsupported or
     *      unavailable.
     * [CN] 图标为带斜线的图片（Material image_not_supported），用于图片不受支持或不可用。
     */
    CYLPlaceholderStyleImageUnavailable,
    /*!
     * [EN] The icon of a stack of photos (Material photo_library), for an empty album or photo library.
     * [CN] 图标为叠放的照片（Material photo_library），用于空相册或照片库。
     */
    CYLPlaceholderStylePhotoLibrary,
    /*!
     * [EN] The icon of a struck-through musical note (Material music_off), for no music or audio.
     * [CN] 图标为带斜线的音符（Material music_off），用于没有音乐或音频。
     */
    CYLPlaceholderStyleMusicOff,
    /*!
     * [EN] The icon of a struck-through video camera (Material videocam_off), for no video or a camera that is off.
     * [CN] 图标为带斜线的摄像机（Material videocam_off），用于没有视频或摄像头已关闭。
     */
    CYLPlaceholderStyleVideoOff,
    /*!
     * [EN] The icon of a struck-through person (Material person_off), for a user who is unavailable or no account.
     * [CN] 图标为带斜线的人像（Material person_off），用于用户不可用或没有账号。
     */
    CYLPlaceholderStylePersonOff,
    /*!
     * [EN] The icon of a struck-through group of people (Material group_off), for no contacts, members or groups.
     * [CN] 图标为带斜线的人群（Material group_off），用于没有联系人、成员或群组。
     */
    CYLPlaceholderStyleGroupOff,
    /*!
     * [EN] The icon of a calendar page with a cross (Material event_busy), for no available date or a busy event.
     * [CN] 图标为带叉号的日历页（Material event_busy），用于没有可选日期或日程冲突。
     */
    CYLPlaceholderStyleEventBusy,
    /*!
     * [EN] The icon of a struck-through shopping cart (Material remove_shopping_cart), for an empty cart.
     * [CN] 图标为带斜线的购物车（Material remove_shopping_cart），用于购物车为空。
     */
    CYLPlaceholderStyleEmptyCart,
    /*!
     * [EN] The icon of an outlined heart (Material favorite_border), for no favorites yet.
     * [CN] 图标为空心爱心（Material favorite_border），用于暂无收藏。
     */
    CYLPlaceholderStyleFavorite,
    /*!
     * [EN] The icon of a battery with an exclamation mark (Material battery_alert), for a low battery.
     * [CN] 图标为带感叹号的电池（Material battery_alert），用于电量不足。
     */
    CYLPlaceholderStyleBatteryAlert,
    /*!
     * [EN] The icon of a phone with a question mark (Material device_unknown), for an unknown or unsupported device.
     * [CN] 图标为带问号的手机（Material device_unknown），用于未知或不受支持的设备。
     */
    CYLPlaceholderStyleUnknownDevice,
    /*!
     * [EN] The icon of a struck-through phone handset (Material phone_disabled), for calls that are unavailable.
     * [CN] 图标为带斜线的电话听筒（Material phone_disabled），用于无法通话。
     */
    CYLPlaceholderStylePhoneDisabled,
    /*!
     * [EN] The icon of a location pin with a cross (Material wrong_location), for a wrong or unsupported location.
     * [CN] 图标为带叉号的定位图钉（Material wrong_location），用于位置错误或不在服务范围。
     */
    CYLPlaceholderStyleWrongLocation,
    /*!
     * [EN] The icon of an archive box (Material archive), for archived content.
     * [CN] 图标为归档盒（Material archive），用于已归档的内容。
     */
    CYLPlaceholderStyleArchive,
    /*!
     * [EN] The icon of an "i" in an outlined circle (Material info_outline), for information.
     * [CN] 图标为空心圆中的 "i"（Material info_outline），用于提示信息。
     */
    CYLPlaceholderStyleInfo,
    /*!
     * [EN] The icon of a circular refresh arrow (Material refresh), for content to reload.
     * [CN] 图标为环形刷新箭头（Material refresh），用于需要重新加载的内容。
     */
    CYLPlaceholderStyleRefresh,
    /*!
     * [EN] The icon of an outlined trash can (Material delete_outline), for deleted content or an empty trash.
     * [CN] 图标为空心垃圾桶（Material delete_outline），用于已删除的内容或空回收站。
     */
    CYLPlaceholderStyleDelete,
    /*!
     * [EN] The icon of a magnifying glass (Material search), for a search that has not started yet.
     * [CN] 图标为放大镜（Material search），用于尚未开始的搜索。
     */
    CYLPlaceholderStyleSearch,
    /*!
     * [EN] The icon of an outlined envelope (Material mail_outline), for no mail or messages.
     * [CN] 图标为空心信封（Material mail_outline），用于没有邮件或消息。
     */
    CYLPlaceholderStyleMail,
    /*!
     * [EN] The icon of a picture (Material image), for no images.
     * [CN] 图标为图片（Material image），用于没有图片。
     */
    CYLPlaceholderStyleImage,
    /*!
     * [EN] The icon of an outlined cloud (Material cloud_queue), for cloud content.
     * [CN] 图标为空心云（Material cloud_queue），用于云端内容。
     */
    CYLPlaceholderStyleCloud,
    /*!
     * [EN] The icon of a struck-through bell (Material notifications_off), for notifications that are off or none.
     * [CN] 图标为带斜线的铃铛（Material notifications_off），用于通知已关闭或没有通知。
     */
    CYLPlaceholderStyleNotificationsOff,
    /*!
     * [EN] The icon of a clock with a circular arrow (Material history), for no history yet.
     * [CN] 图标为带环形箭头的时钟（Material history），用于暂无历史记录。
     */
    CYLPlaceholderStyleHistory,
    /*!
     * [EN] The number of styles (51), not a style: valid styles are 0 to this value minus 1, and `+imageNameForStyle:`
     *      returns nil for it and logs an error.
     * [CN] 样式的数量（51），本身不是样式：有效样式为 0 到该值减 1，`+imageNameForStyle:` 对它返回 nil 并输出错误日志。
     */
    CYLPlaceholderStyleCount
};

/*!
 * [EN] The bundled text of a placeholder. Each value selects one string of the library's resource bundle, returned by
 *      `+localizedTextForMessage:` in the app's current language with an English fallback, and used as the title for
 *      `CYLPlaceholderItemMessage` when no `CYLPlaceholderItemTitle` is given.
 * [CN] 占位图的内置文字。每个值对应本库资源包中的一条字符串，由 `+localizedTextForMessage:` 按应用当前语言返回（缺失时
 *      回退到英文），在没有 `CYLPlaceholderItemTitle` 时作为 `CYLPlaceholderItemMessage` 的标题。
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderMessage) {
    /*!
     * [EN] The text "Nothing here yet" in English (key "CYLPlaceholderEmptyText"); the text a new view shows.
     * [CN] 文字，简体中文为“暂无内容”（key "CYLPlaceholderEmptyText"，英文 "Nothing here yet"）；新建视图默认显示的文字
     *      。
     */
    CYLPlaceholderMessageEmpty,
    /*!
     * [EN] The text "No results found" in English (key "CYLPlaceholderNoResultsText").
     * [CN] 文字，简体中文为“没有找到结果”（key "CYLPlaceholderNoResultsText"，英文 "No results found"）。
     */
    CYLPlaceholderMessageNoResults,
    /*!
     * [EN] The text "No internet connection" in English (key "CYLPlaceholderNoInternetText").
     * [CN] 文字，简体中文为“网络连接不可用”（key "CYLPlaceholderNoInternetText"，英文 "No internet connection"）。
     */
    CYLPlaceholderMessageNoInternet,
    /*!
     * [EN] The text "Server unavailable" in English (key "CYLPlaceholderServerUnavailableText").
     * [CN] 文字，简体中文为“服务器暂不可用”（key "CYLPlaceholderServerUnavailableText"，英文 "Server unavailable"）。
     */
    CYLPlaceholderMessageServerUnavailable,
    /*!
     * [EN] The text "Something went wrong" in English (key "CYLPlaceholderErrorText").
     * [CN] 文字，简体中文为“出了点问题”（key "CYLPlaceholderErrorText"，英文 "Something went wrong"）。
     */
    CYLPlaceholderMessageError,
    /*!
     * [EN] The text "Loading" in English (key "CYLPlaceholderLoadingText").
     * [CN] 文字，简体中文为“加载中”（key "CYLPlaceholderLoadingText"，英文 "Loading"）。
     */
    CYLPlaceholderMessageLoading,
    /*!
     * [EN] The text "Access unavailable" in English (key "CYLPlaceholderNoPermissionText").
     * [CN] 文字，简体中文为“暂无访问权限”（key "CYLPlaceholderNoPermissionText"，英文 "Access unavailable"）。
     */
    CYLPlaceholderMessageNoPermission,
    /*!
     * [EN] The text "Your cart is empty" in English (key "CYLPlaceholderEmptyCartText").
     * [CN] 文字，简体中文为“购物车是空的”（key "CYLPlaceholderEmptyCartText"，英文 "Your cart is empty"）。
     */
    CYLPlaceholderMessageEmptyCart,
    /*!
     * [EN] The text "No notifications" in English (key "CYLPlaceholderNoNotificationsText").
     * [CN] 文字，简体中文为“暂无通知”（key "CYLPlaceholderNoNotificationsText"，英文 "No notifications"）。
     */
    CYLPlaceholderMessageNoNotifications,
    /*!
     * [EN] The number of messages (9), not a message: valid messages are 0 to this value minus 1, and
     *      `+localizedTextForMessage:` returns nil for it and logs an error.
     * [CN] 文字的数量（9），本身不是文字：有效值为 0 到该值减 1，`+localizedTextForMessage:` 对它返回 nil 并输出错误日
     *      志。
     */
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

/*!
 * [EN] The kind of badge `-showBadgeWithStyle:value:` shows. The badge sits at the top-right corner of the icon (of the
 *      title when the icon is hidden), moved by `badgeCenterOffset`, and is drawn with `CYLPlaceholderBadgeAppearance`.
 * [CN] `-showBadgeWithStyle:value:` 显示的角标种类。角标位于图标右上角（图标隐藏时位于标题右上角），可用
 *      `badgeCenterOffset` 偏移，按 `CYLPlaceholderBadgeAppearance` 绘制。
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderBadgeStyle) {
    /*!
     * [EN] No badge: hides the badge (`badgeValue` becomes nil); the value is ignored.
     * [CN] 无角标：隐藏角标（`badgeValue` 置为 nil），忽略传入的值。
     */
    CYLPlaceholderBadgeStyleNone,
    /*!
     * [EN] A dot of 8 x 8 points without text (`badgeValue` becomes an empty string); the value is ignored.
     * [CN] 8 x 8 点、不带文字的圆点（`badgeValue` 置为空字符串），忽略传入的值。
     */
    CYLPlaceholderBadgeStyleDot,
    /*!
     * [EN] A count: the value must be a string holding a whole number. Numbers above 99 show as "99+", and 0 or a
     *      negative number hides the badge; any other value is refused (the method returns NO).
     * [CN] 数字：传入的值必须是表示整数的字符串。大于 99 显示为 "99+"，0 或负数隐藏角标；其他值被拒绝（方法返回 NO）。
     */
    CYLPlaceholderBadgeStyleNumber,
    /*!
     * [EN] A text: shows the value as it is; an empty or nil value is refused (the method returns NO).
     * [CN] 文字：原样显示传入的值；空字符串或 nil 被拒绝（方法返回 NO）。
     */
    CYLPlaceholderBadgeStyleText
};

/*!
 * Badge appearance configuration for shared/customizable badge styling.
 * Use with UIAppearance proxy for global defaults.
 */
@interface CYLPlaceholderBadgeAppearance : NSObject
/*!
 * [EN] The badge's fill color. The shared appearance uses Apple's high-contrast system red #D70015 (white text on it
 *      reaches about 5.4:1); nil keeps the badge label's current color.
 * [CN] 角标的填充色。共享外观默认为 Apple 高对比度系统红 #D70015（白字对比度约 5.4:1）；nil 时保留角标标签当前的颜色。
 */
@property (nonatomic, strong, nullable) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
/*!
 * [EN] The color of the badge text. The shared appearance uses white; nil keeps the badge label's current color.
 * [CN] 角标文字的颜色。共享外观默认为白色；nil 时保留角标标签当前的颜色。
 */
@property (nonatomic, strong, nullable) UIColor *textColor UI_APPEARANCE_SELECTOR;
/*!
 * [EN] The font of the badge text. The shared appearance uses the bold Caption 1 text style (12 points at the default
 *      text size), which follows Dynamic Type; nil keeps the badge label's current font.
 * [CN] 角标文字的字体。共享外观默认为粗体 Caption 1 文字样式（默认字号下为 12 点），跟随动态字体；nil 时保留角标标签当
 *      前的字体。
 */
@property (nonatomic, strong, nullable) UIFont *font UI_APPEARANCE_SELECTOR;
/*!
 * [EN] The corner radius of the badge, in points. 0 (the default) rounds it into a capsule or, for a dot, a circle
 *      (half its height); a positive value is capped at half the height.
 * [CN] 角标的圆角半径，单位为点。0（默认）表示圆角为高度的一半（胶囊形，圆点则为圆形）；正值最多取高度的一半。
 */
@property (nonatomic) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
/*!
 * [EN] The padding between the text and the edge of a text or number badge, in points; the shared appearance uses 4 on
 *      every side. The badge is never narrower than it is tall. Not used by a dot.
 * [CN] 文字或数字角标中文字与边缘的间距，单位为点；共享外观默认四边各 4 点。角标宽度不小于高度。圆点不使用该值。
 */
@property (nonatomic) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;
/*!
 * Animation duration for badge show/hide. Default 0.2s.
 */
@property (nonatomic) CGFloat animationDuration UI_APPEARANCE_SELECTOR;
/*!
 * Whether to animate badge changes. Default YES.
 */
@property (nonatomic) BOOL animatesChanges UI_APPEARANCE_SELECTOR;
/*!
 * [EN] The one instance every CYLPlaceholderView reads when it shows or lays out a badge, created on first use with the
 *      defaults listed on each property. Change its properties to restyle badges app-wide; a value the caller set
 *      directly on a view's `badgeLabel` is kept.
 * [CN] 所有 CYLPlaceholderView 显示或布局角标时读取的唯一实例，首次使用时以各属性注释中的默认值创建。修改其属性即可统一
 *      调整全应用的角标样式；调用方直接在某个视图的 `badgeLabel` 上设置的值会被保留。
 */
+ (instancetype)sharedAppearance;
@end

/*!
 * Item keys use CYLTabBarController's serialized names without exporting its symbols.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitle;
/*!
 * [EN] The icon: a UIImage, an image name in the image bundle (nil: the library's bundle) or "system:" plus an SF
 *      Symbol name (iOS 13 and later). Takes precedence over `CYLPlaceholderItemStyle`; an image that cannot be loaded
 *      makes the initializer fail with an error.
 * [CN] 图标：UIImage、图片包中的图片名（为 nil 时使用本库的资源包），或 "system:" 加 SF Symbol 名称（iOS 13 及以上）。
 *      优先于 `CYLPlaceholderItemStyle`；图片无法加载时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImage;
/*!
 * [EN] Insets that shrink the icon inside its box, in points: an NSValue holding UIEdgeInsets, an array [top, left,
 *      bottom, right] or a dictionary with "top", "left", "bottom" and "right" (each at most 1000 either way). Absent
 *      means no insets. An invalid value makes the initializer fail with an error.
 * [CN] 在图标区域内缩小图标的内边距，单位为点：包含 UIEdgeInsets 的 NSValue、数组 [top, left, bottom, right]，或含
 *      "top"、"left"、"bottom"、"right" 的字典（各边绝对值不超过 1000）。缺省时无内边距。值无效时初始化方法失败并返回错
 *      误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImageInsets;
/*!
 * [EN] An offset that moves the icon, in points: an NSValue holding a UIOffset, an array [horizontal, vertical] or a
 *      dictionary with "horizontal"/"x" and "vertical"/"y" (each at most 1000 either way). Absent means no offset. An
 *      invalid value makes the initializer fail with an error.
 * [CN] 移动图标的偏移量，单位为点：包含 UIOffset 的 NSValue、数组 [horizontal, vertical]，或含 "horizontal"/"x" 与
 *      "vertical"/"y" 的字典（各分量绝对值不超过 1000）。缺省时不偏移。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImagePositionAdjustment;
/*!
 * [EN] An offset that moves the title, in points: an NSValue holding a UIOffset, an array [horizontal, vertical] or a
 *      dictionary with "horizontal"/"x" and "vertical"/"y" (each at most 1000 either way). Absent means the view's
 *      `defaultTitlePositionAdjustment`. An invalid value makes the initializer fail with an error.
 * [CN] 移动标题的偏移量，单位为点：包含 UIOffset 的 NSValue、数组 [horizontal, vertical]，或含 "horizontal"/"x" 与
 *      "vertical"/"y" 的字典（各分量绝对值不超过 1000）。缺省时使用视图的 `defaultTitlePositionAdjustment`。值无效时初
 *      始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitlePositionAdjustment;
/*!
 * Optional preset indices. Explicit title and image take precedence.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemStyle;
/*!
 * [EN] A bundled text: a CYLPlaceholderMessage number, whose localized text (`+localizedTextForMessage:`) becomes the
 *      title when `CYLPlaceholderItemTitle` is absent. A number outside the enum makes the initializer fail.
 * [CN] 内置文字：CYLPlaceholderMessage 数值，没有 `CYLPlaceholderItemTitle` 时以其本地化文字（
 *      `+localizedTextForMessage:`）作为标题。超出枚举范围的数值会使初始化方法失败。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemMessage;
/*!
 * [EN] An animation file shown instead of the icon, for any engine (chosen by the file extension): a URL, or a string
 *      that is a URL (with "://") or a file path (a relative path is looked up in the image bundle, else the main
 *      bundle). The engine-specific URL and file path keys take precedence. It plays only when an animation engine is
 *      in the build; until it is ready, and if it fails, the static image shows.
 * [CN] 代替图标显示的动画文件，适用于任意引擎（按文件扩展名选择）：URL，或字符串形式的 URL（含 "://"）或文件路径（相对
 *      路径在图片包中查找，否则在 main bundle 中查找）。各引擎专用的 URL 与文件路径 key 优先。只有工程中包含动画引擎时
 *      才会播放；就绪前以及失败后显示静态图片。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationURL;
/*!
 * [EN] The animation file as a path (a relative path is looked up in the image bundle, else the main bundle), used when
 *      `CYLPlaceholderItemAnimationURL` is absent; see `+pathForBundledAnimation:` for the bundled animations.
 * [CN] 以路径给出的动画文件（相对路径在图片包中查找，否则在 main bundle 中查找），在没有
 *      `CYLPlaceholderItemAnimationURL` 时使用；内置动画的路径见 `+pathForBundledAnimation:`。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationFilePath;
/*!
 * [EN] The size the animation is laid out at: an NSValue holding a CGSize, an array [width, height] or a dictionary
 *      with "width"/"w" and "height"/"h", each above 0 and at most 1000 points. Also the fallback of the
 *      engine-specific size keys. Absent means the static image's size, else 80 x 80 points; an invalid size shows no
 *      animation.
 * [CN] 动画的布局尺寸：包含 CGSize 的 NSValue、数组 [width, height]，或含 "width"/"w" 与 "height"/"h" 的字典，各边大于
 *      0 且不超过 1000 点。也是各引擎专用尺寸 key 的回退值。缺省时为静态图片的尺寸，否则为 80 x 80 点；尺寸无效时不显示
 *      动画。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationSize;
/*!
 * [EN] The title color: a UIColor or a hex string "#RGB", "#RRGGBB" or "#RRGGBBAA". Absent keeps the default gray. An
 *      invalid value makes the initializer fail with an error.
 * [CN] 标题颜色：UIColor 或十六进制字符串 "#RGB"、"#RRGGBB"、"#RRGGBBAA"。缺省时保持默认灰色。值无效时初始化方法失败并
 *      返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleColor;
/*!
 * [EN] The tint color of the icon (bundled style icons and other template images): a UIColor or a hex string "#RGB",
 *      "#RRGGBB" or "#RRGGBBAA". Absent means the view's inherited tint color. An invalid value makes the initializer
 *      fail with an error.
 * [CN] 图标的 tint color（内置样式图标及其他模板图片）：UIColor 或十六进制字符串 "#RGB"、"#RRGGBB"、"#RRGGBBAA"。缺省时
 *      使用视图继承的 tint color。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemIconColor;
/*!
 * [EN] The background color of the whole view: a UIColor or a hex string "#RGB", "#RRGGBB" or "#RRGGBBAA". An invalid
 *      value makes the initializer fail with an error.
 * [CN] 整个视图的背景色：UIColor 或十六进制字符串 "#RGB"、"#RRGGBB"、"#RRGGBBAA"。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemBackgroundColor;
/*!
 * [EN] The title font: a UIFont; a number (the system font size); a string "17", "bold:17" (a weight from ultralight to
 *      black) or "FontName:17"; or a dictionary with "size" and optional "name" or "weight". Sizes from 1 to 200 points
 *      at the default text size, scaled for Dynamic Type. Absent keeps the Body text style. An invalid value makes the
 *      initializer fail with an error.
 * [CN] 标题字体：UIFont；数字（系统字体字号）；字符串 "17"、"bold:17"（字重 ultralight 到 black）或 "FontName:17"；或含
 *      "size" 及可选 "name"、"weight" 的字典。字号为默认文字大小下的 1 到 200 点，随动态字体缩放。缺省时保持 Body 文字
 *      样式。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleFont;
/*!
 * [EN] A string set as the view's `accessibilityIdentifier`, for UI tests.
 * [CN] 设为视图 `accessibilityIdentifier` 的字符串，供 UI 测试使用。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAccessibilityIdentifier;
/*!
 * [EN] A string VoiceOver reads instead of the title; it makes the view one accessibility element. A value that is not
 *      a string makes the initializer fail.
 * [CN] VoiceOver 代替标题朗读的字符串；设置后视图成为一个无障碍元素。值不是字符串时初始化方法失败。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAccessibilityLabel;
/*!
 * [EN] A string VoiceOver reads as the hint; it makes the view one accessibility element. A value that is not a string
 *      makes the initializer fail.
 * [CN] VoiceOver 作为提示朗读的字符串；设置后视图成为一个无障碍元素。值不是字符串时初始化方法失败。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAccessibilityHint;
/*!
 * Selected appearance keys are used when the placeholder's selected property is set.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedImage;
/*!
 * Dark static image variants follow the view's appearance on iOS 13 and later.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemDarkImage;
/*!
 * [EN] The selected icon in Dark Mode (iOS 13 and later): a UIImage, an image name in the image bundle (nil: the
 *      library's bundle) or "system:" plus an SF Symbol name (iOS 13 and later); combined with
 *      `CYLPlaceholderItemSelectedImage` into one image that follows the appearance.
 * [CN] 深色模式下的选中图标（iOS 13 及以上）：UIImage、图片包中的图片名（为 nil 时使用本库的资源包），或 "system:" 加
 *      SF Symbol 名称（iOS 13 及以上）；与 `CYLPlaceholderItemSelectedImage` 合成一张随外观切换的图片。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedDarkImage;
/*!
 * Remote-image and navigation keys are reserved for compatibility.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImageURL;
/*!
 * [EN] Reserved for compatibility with CYLTabBarController's item dictionaries (there: the selected icon's remote image
 *      URL): stored in `itemAttributes` but not read by CYLPlaceholderView.
 * [CN] 为兼容 CYLTabBarController 的条目字典而保留（在那里表示选中图标的远程图片 URL）：保存在 `itemAttributes` 中，
 *      CYLPlaceholderView 不读取。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedImageURL;
/*!
 * [EN] Reserved for compatibility with CYLTabBarController's item dictionaries (there: the size of a remote icon
 *      image): stored in `itemAttributes` but not read by CYLPlaceholderView.
 * [CN] 为兼容 CYLTabBarController 的条目字典而保留（在那里表示远程图标图片的尺寸）：保存在 `itemAttributes` 中，
 *      CYLPlaceholderView 不读取。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemImageURLSize;
/*!
 * [EN] Reserved for compatibility with CYLTabBarController's item dictionaries (there: an item identifier): stored in
 *      `itemAttributes` but not read by CYLPlaceholderView.
 * [CN] 为兼容 CYLTabBarController 的条目字典而保留（在那里表示条目标识）：保存在 `itemAttributes` 中，
 *      CYLPlaceholderView 不读取。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemIdentifier;
/*!
 * [EN] Reserved for compatibility with CYLTabBarController's item dictionaries (there: the identifier of a page to
 *      open): stored in `itemAttributes` but not read by CYLPlaceholderView.
 * [CN] 为兼容 CYLTabBarController 的条目字典而保留（在那里表示要打开的页面标识）：保存在 `itemAttributes` 中，
 *      CYLPlaceholderView 不读取。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPageIdentifier;
/*!
 * [EN] Reserved for compatibility with CYLTabBarController's item dictionaries (there: the parameters of a page to
 *      open): stored in `itemAttributes` but not read by CYLPlaceholderView.
 * [CN] 为兼容 CYLTabBarController 的条目字典而保留（在那里表示要打开的页面参数）：保存在 `itemAttributes` 中，
 *      CYLPlaceholderView 不读取。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPageParameters;
/*!
 * [EN] Reserved for compatibility with CYLTabBarController's item dictionaries (there: the platforms an item is shown
 *      on): stored in `itemAttributes` but not read by CYLPlaceholderView.
 * [CN] 为兼容 CYLTabBarController 的条目字典而保留（在那里表示条目显示的平台）：保存在 `itemAttributes` 中，
 *      CYLPlaceholderView 不读取。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPlatforms;
/*!
 * [EN] Reserved for compatibility with CYLTabBarController's item dictionaries (there: the minimum app version an item
 *      is shown in): stored in `itemAttributes` but not read by CYLPlaceholderView.
 * [CN] 为兼容 CYLTabBarController 的条目字典而保留（在那里表示显示条目的最低应用版本）：保存在 `itemAttributes` 中，
 *      CYLPlaceholderView 不读取。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemMinimumAppVersion;
/*!
 * [EN] A string shown as the title while the view is selected. A value that is not a string makes the initializer fail.
 * [CN] 视图选中时显示的标题字符串。值不是字符串时初始化方法失败。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedTitle;
/*!
 * [EN] The title color while the view is selected: a UIColor or a hex string "#RGB", "#RRGGBB" or "#RRGGBBAA". An
 *      invalid value makes the initializer fail with an error.
 * [CN] 视图选中时的标题颜色：UIColor 或十六进制字符串 "#RGB"、"#RRGGBB"、"#RRGGBBAA"。值无效时初始化方法失败并返回错误
 *      。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedTitleColor;
/*!
 * [EN] The icon tint color while the view is selected: a UIColor or a hex string "#RGB", "#RRGGBB" or "#RRGGBBAA". An
 *      invalid value makes the initializer fail with an error.
 * [CN] 视图选中时图标的 tint color：UIColor 或十六进制字符串 "#RGB"、"#RRGGBB"、"#RRGGBBAA"。值无效时初始化方法失败并返
 *      回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedIconColor;
/*!
 * [EN] The background color of the view while it is selected: a UIColor or a hex string "#RGB", "#RRGGBB" or
 *      "#RRGGBBAA". An invalid value makes the initializer fail with an error.
 * [CN] 视图选中时的背景色：UIColor 或十六进制字符串 "#RGB"、"#RRGGBB"、"#RRGGBBAA"。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedBackgroundColor;
/*!
 * [EN] The title font while the view is selected, in the formats of `CYLPlaceholderItemTitleFont`. An invalid value
 *      makes the initializer fail with an error.
 * [CN] 视图选中时的标题字体，格式同 `CYLPlaceholderItemTitleFont`。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemSelectedTitleFont;
/*!
 * Local animation sources, sizes, and Lottie color overrides are supported.
 * Other backend-specific options are retained for compatibility; see the README.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationDarkURL;
/*!
 * [EN] The animation file path used in Dark Mode instead of `CYLPlaceholderItemAnimationURL` and
 *      `CYLPlaceholderItemAnimationFilePath`; `CYLPlaceholderItemAnimationDarkURL` takes precedence over it.
 * [CN] 深色模式下代替 `CYLPlaceholderItemAnimationURL` 与 `CYLPlaceholderItemAnimationFilePath` 的动画文件路径；
 *      `CYLPlaceholderItemAnimationDarkURL` 优先于它。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationDarkFilePath;
/*!
 * [EN] Color overrides for the animation: a dictionary from a non-empty keypath string to a color (a UIColor or a hex
 *      string "#RGB", "#RRGGBB" or "#RRGGBBAA"), applied when the player supports color overrides (otherwise logged).
 *      An invalid value makes the initializer fail with an error.
 * [CN] 动画的颜色覆盖：从非空 keypath 字符串到颜色（UIColor 或十六进制字符串 "#RGB"、"#RRGGBB"、"#RRGGBBAA"）的字典，播
 *      放器支持颜色覆盖时生效（否则输出日志）。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationColors;
/*!
 * [EN] Color overrides added on top of `CYLPlaceholderItemAnimationColors` in Dark Mode, in the same format. An invalid
 *      value makes the initializer fail with an error.
 * [CN] 深色模式下叠加在 `CYLPlaceholderItemAnimationColors` 之上的颜色覆盖，格式相同。值无效时初始化方法失败并返回错误
 *      。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationDarkColors;
/*!
 * [EN] Per-file playback options, a dictionary handed to the player: "contentMode" (a UIViewContentMode number or case
 *      name such as "scaleAspectFill"; aspect fit by default), "animationSpeed" (a positive number) and engine options
 *      such as Rive's "artboard" or "stateMachine". Options the engine does not support are logged; a value that is not
 *      a dictionary shows no animation.
 * [CN] 按文件的播放选项，传给播放器的字典："contentMode"（UIViewContentMode 数值或名称，如 "scaleAspectFill"；默认
 *      aspect fit）、"animationSpeed"（正数）以及引擎选项，如 Rive 的 "artboard"、"stateMachine"。引擎不支持的选项会输
 *      出日志；值不是字典时不显示动画。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemAnimationOptions;
/*!
 * [EN] The Lottie file (.json) shown instead of the icon: a URL, or a string that is a URL (with "://") or a file path
 *      (a relative path is looked up in the image bundle, else the main bundle); takes precedence over the Lottie file
 *      path key. The engine-specific sources are checked in the order GIF, Lottie, PAG, Rive, then the generic keys. It
 *      needs the Lottie engine in the build.
 * [CN] 代替图标显示的 Lottie 文件（.json）：URL，或字符串形式的 URL（含 "://"）或文件路径（相对路径在图片包中查找，否则
 *      在 main bundle 中查找）；优先于 Lottie 文件路径 key。各引擎专用来源的检查顺序为 GIF、Lottie、PAG、Rive，然后才是
 *      通用 key。需要工程中包含 Lottie 引擎。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieURL CYL_LOTTIE_REQUIRED;
/*!
 * [EN] The Lottie file (.json) as a path, used when the Lottie URL key is absent; a relative path is looked up in the
 *      image bundle, else the main bundle. It needs the Lottie engine in the build.
 * [CN] 以路径给出的 Lottie 文件（.json），在没有 Lottie URL key 时使用；相对路径在图片包中查找，否则在 main bundle 中查
 *      找。需要工程中包含 Lottie 引擎。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieFilePath CYL_LOTTIE_REQUIRED;
/*!
 * [EN] The size of the Lottie animation: an NSValue holding a CGSize, an array [width, height] or a dictionary with
 *      "width"/"w" and "height"/"h", each above 0 and at most 1000 points. Absent means
 *      `CYLPlaceholderItemAnimationSize`.
 * [CN] Lottie 动画的尺寸：包含 CGSize 的 NSValue、数组 [width, height]，或含 "width"/"w" 与 "height"/"h" 的字典，各边大
 *      于 0 且不超过 1000 点。缺省时使用 `CYLPlaceholderItemAnimationSize`。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieSize CYL_LOTTIE_REQUIRED;
/*!
 * [EN] The Lottie file used in Dark Mode instead of the Lottie URL and file path keys, in the same formats; it takes
 *      precedence over the Lottie dark file path.
 * [CN] 深色模式下代替 Lottie URL 与文件路径 key 的 Lottie 文件，格式相同；优先于 Lottie 深色文件路径。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieDarkURL CYL_LOTTIE_REQUIRED;
/*!
 * [EN] The Lottie file path used in Dark Mode instead of the Lottie URL and file path keys, when the Lottie dark URL is
 *      absent.
 * [CN] 深色模式下代替 Lottie URL 与文件路径 key 的 Lottie 文件路径，在没有 Lottie 深色 URL 时使用。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieDarkFilePath CYL_LOTTIE_REQUIRED;
/*!
 * [EN] Color overrides added in Dark Mode to a Lottie file (.json), after `CYLPlaceholderItemAnimationDarkColors`, in
 *      the format of `CYLPlaceholderItemAnimationColors`. An invalid value makes the initializer fail with an error.
 * [CN] 深色模式下对 Lottie 文件（.json）追加的颜色覆盖，位于 `CYLPlaceholderItemAnimationDarkColors` 之后，格式同
 *      `CYLPlaceholderItemAnimationColors`。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieDarkColors CYL_LOTTIE_REQUIRED;
/*!
 * [EN] Reserved for compatibility with CYLTabBarController's item dictionaries (there: whether a Lottie icon keeps
 *      looping while its tab is not selected): stored in `itemAttributes` but not read by CYLPlaceholderView; use
 *      `CYLPlaceholderItemAnimationRepeatCount` instead.
 * [CN] 为兼容 CYLTabBarController 的条目字典而保留（在那里表示 Tab 未选中时 Lottie 图标是否继续循环）：保存在
 *      `itemAttributes` 中，CYLPlaceholderView 不读取；请改用 `CYLPlaceholderItemAnimationRepeatCount`。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemLottieLoopsWhenUnselected CYL_LOTTIE_REQUIRED;
/*!
 * [EN] The PAG file (.pag) shown instead of the icon: a URL, or a string that is a URL (with "://") or a file path (a
 *      relative path is looked up in the image bundle, else the main bundle); takes precedence over the PAG file path
 *      key. The engine-specific sources are checked in the order GIF, Lottie, PAG, Rive, then the generic keys. It
 *      needs the PAG engine in the build.
 * [CN] 代替图标显示的 PAG 文件（.pag）：URL，或字符串形式的 URL（含 "://"）或文件路径（相对路径在图片包中查找，否则在
 *      main bundle 中查找）；优先于 PAG 文件路径 key。各引擎专用来源的检查顺序为 GIF、Lottie、PAG、Rive，然后才是通用
 *      key。需要工程中包含 PAG 引擎。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGURL CYL_PAG_REQUIRED;
/*!
 * [EN] The PAG file (.pag) as a path, used when the PAG URL key is absent; a relative path is looked up in the image
 *      bundle, else the main bundle. It needs the PAG engine in the build.
 * [CN] 以路径给出的 PAG 文件（.pag），在没有 PAG URL key 时使用；相对路径在图片包中查找，否则在 main bundle 中查找。需
 *      要工程中包含 PAG 引擎。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGFilePath CYL_PAG_REQUIRED;
/*!
 * [EN] The size of the PAG animation: an NSValue holding a CGSize, an array [width, height] or a dictionary with
 *      "width"/"w" and "height"/"h", each above 0 and at most 1000 points. Absent means
 *      `CYLPlaceholderItemAnimationSize`.
 * [CN] PAG 动画的尺寸：包含 CGSize 的 NSValue、数组 [width, height]，或含 "width"/"w" 与 "height"/"h" 的字典，各边大于
 *      0 且不超过 1000 点。缺省时使用 `CYLPlaceholderItemAnimationSize`。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGSize CYL_PAG_REQUIRED;
/*!
 * [EN] The PAG file used in Dark Mode instead of the PAG URL and file path keys, in the same formats; it takes
 *      precedence over the PAG dark file path.
 * [CN] 深色模式下代替 PAG URL 与文件路径 key 的 PAG 文件，格式相同；优先于 PAG 深色文件路径。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGDarkURL CYL_PAG_REQUIRED;
/*!
 * [EN] The PAG file path used in Dark Mode instead of the PAG URL and file path keys, when the PAG dark URL is absent.
 * [CN] 深色模式下代替 PAG URL 与文件路径 key 的 PAG 文件路径，在没有 PAG 深色 URL 时使用。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemPAGDarkFilePath CYL_PAG_REQUIRED;
/*!
 * [EN] The Rive file (.riv) shown instead of the icon: a URL, or a string that is a URL (with "://") or a file path (a
 *      relative path is looked up in the image bundle, else the main bundle); takes precedence over the Rive file path
 *      key. The engine-specific sources are checked in the order GIF, Lottie, PAG, Rive, then the generic keys. It
 *      needs the Rive engine in the build.
 * [CN] 代替图标显示的 Rive 文件（.riv）：URL，或字符串形式的 URL（含 "://"）或文件路径（相对路径在图片包中查找，否则在
 *      main bundle 中查找）；优先于 Rive 文件路径 key。各引擎专用来源的检查顺序为 GIF、Lottie、PAG、Rive，然后才是通用
 *      key。需要工程中包含 Rive 引擎。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveURL CYL_RIVE_REQUIRED;
/*!
 * [EN] The Rive file (.riv) as a path, used when the Rive URL key is absent; a relative path is looked up in the image
 *      bundle, else the main bundle. It needs the Rive engine in the build.
 * [CN] 以路径给出的 Rive 文件（.riv），在没有 Rive URL key 时使用；相对路径在图片包中查找，否则在 main bundle 中查找。
 *      需要工程中包含 Rive 引擎。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveFilePath CYL_RIVE_REQUIRED;
/*!
 * [EN] The size of the Rive animation: an NSValue holding a CGSize, an array [width, height] or a dictionary with
 *      "width"/"w" and "height"/"h", each above 0 and at most 1000 points. Absent means
 *      `CYLPlaceholderItemAnimationSize`.
 * [CN] Rive 动画的尺寸：包含 CGSize 的 NSValue、数组 [width, height]，或含 "width"/"w" 与 "height"/"h" 的字典，各边大于
 *      0 且不超过 1000 点。缺省时使用 `CYLPlaceholderItemAnimationSize`。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveSize CYL_RIVE_REQUIRED;
/*!
 * [EN] The Rive file used in Dark Mode instead of the Rive URL and file path keys, in the same formats; it takes
 *      precedence over the Rive dark file path.
 * [CN] 深色模式下代替 Rive URL 与文件路径 key 的 Rive 文件，格式相同；优先于 Rive 深色文件路径。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveDarkURL CYL_RIVE_REQUIRED;
/*!
 * [EN] The Rive file path used in Dark Mode instead of the Rive URL and file path keys, when the Rive dark URL is
 *      absent.
 * [CN] 深色模式下代替 Rive URL 与文件路径 key 的 Rive 文件路径，在没有 Rive 深色 URL 时使用。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveDarkFilePath CYL_RIVE_REQUIRED;
/*!
 * [EN] Color overrides added in Dark Mode to a Rive file (.riv), after `CYLPlaceholderItemAnimationDarkColors`, in the
 *      format of `CYLPlaceholderItemAnimationColors`. An invalid value makes the initializer fail with an error.
 * [CN] 深色模式下对 Rive 文件（.riv）追加的颜色覆盖，位于 `CYLPlaceholderItemAnimationDarkColors` 之后，格式同
 *      `CYLPlaceholderItemAnimationColors`。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemRiveDarkColors CYL_RIVE_REQUIRED;
/*!
 * [EN] The GIF file (.gif) shown instead of the icon: a URL, or a string that is a URL (with "://") or a file path (a
 *      relative path is looked up in the image bundle, else the main bundle); takes precedence over the GIF file path
 *      key. The engine-specific sources are checked in the order GIF, Lottie, PAG, Rive, then the generic keys. It
 *      needs the GIF engine in the build.
 * [CN] 代替图标显示的 GIF 文件（.gif）：URL，或字符串形式的 URL（含 "://"）或文件路径（相对路径在图片包中查找，否则在
 *      main bundle 中查找）；优先于 GIF 文件路径 key。各引擎专用来源的检查顺序为 GIF、Lottie、PAG、Rive，然后才是通用
 *      key。需要工程中包含 GIF 引擎。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFURL CYL_GIF_REQUIRED;
/*!
 * [EN] The GIF file (.gif) as a path, used when the GIF URL key is absent; a relative path is looked up in the image
 *      bundle, else the main bundle. It needs the GIF engine in the build.
 * [CN] 以路径给出的 GIF 文件（.gif），在没有 GIF URL key 时使用；相对路径在图片包中查找，否则在 main bundle 中查找。需
 *      要工程中包含 GIF 引擎。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFFilePath CYL_GIF_REQUIRED;
/*!
 * [EN] The size of the GIF animation: an NSValue holding a CGSize, an array [width, height] or a dictionary with
 *      "width"/"w" and "height"/"h", each above 0 and at most 1000 points. Absent means
 *      `CYLPlaceholderItemAnimationSize`.
 * [CN] GIF 动画的尺寸：包含 CGSize 的 NSValue、数组 [width, height]，或含 "width"/"w" 与 "height"/"h" 的字典，各边大于
 *      0 且不超过 1000 点。缺省时使用 `CYLPlaceholderItemAnimationSize`。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFSize CYL_GIF_REQUIRED;
/*!
 * [EN] The GIF file used in Dark Mode instead of the GIF URL and file path keys, in the same formats; it takes
 *      precedence over the GIF dark file path.
 * [CN] 深色模式下代替 GIF URL 与文件路径 key 的 GIF 文件，格式相同；优先于 GIF 深色文件路径。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFDarkURL CYL_GIF_REQUIRED;
/*!
 * [EN] The GIF file path used in Dark Mode instead of the GIF URL and file path keys, when the GIF dark URL is absent.
 * [CN] 深色模式下代替 GIF URL 与文件路径 key 的 GIF 文件路径，在没有 GIF 深色 URL 时使用。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemGIFDarkFilePath CYL_GIF_REQUIRED;
/*!
 * Title chrome, for components that read as buttons (see CYLPlaceholderStackView): an image (UIImage or name, drawn
 * stretched; give it cap insets for a resizable look) or color behind the title, a border, a corner radius (clamped to
 * half the height, so a large value draws a capsule), padding around the text (insets: array, dictionary or NSValue)
 * and a minimum width (points). Without these keys the title stays plain text and the layout is unchanged.
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleBackgroundImage;
/*!
 * [EN] The color behind the title (title chrome): a UIColor or a hex string "#RGB", "#RRGGBB" or "#RRGGBBAA". An
 *      invalid value makes the initializer fail with an error.
 * [CN] 标题背后的颜色（标题装饰）：UIColor 或十六进制字符串 "#RGB"、"#RRGGBB"、"#RRGGBBAA"。值无效时初始化方法失败并返
 *      回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleBackgroundColor;
/*!
 * [EN] The border color of the title chrome: a UIColor or a hex string "#RGB", "#RRGGBB" or "#RRGGBBAA". An invalid
 *      value makes the initializer fail with an error.
 * [CN] 标题装饰的边框颜色：UIColor 或十六进制字符串 "#RGB"、"#RRGGBB"、"#RRGGBBAA"。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleBorderColor;
/*!
 * [EN] The border width of the title chrome, in points: a number from 0 to 1000. An invalid value makes the initializer
 *      fail with an error.
 * [CN] 标题装饰的边框宽度，单位为点：0 到 1000 的数字。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleBorderWidth;
/*!
 * [EN] The corner radius of the title chrome, in points: a number from 0 to 1000, clamped to half the chrome's height
 *      (a large value draws a capsule). An invalid value makes the initializer fail with an error.
 * [CN] 标题装饰的圆角半径，单位为点：0 到 1000 的数字，最多取装饰高度的一半（取大值即为胶囊形）。值无效时初始化方法失败
 *      并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleCornerRadius;
/*!
 * [EN] The padding between the title text and the edge of its chrome, in points: an NSValue holding UIEdgeInsets, an
 *      array [top, left, bottom, right] or a dictionary with "top", "left", "bottom" and "right", none negative. An
 *      invalid value makes the initializer fail with an error.
 * [CN] 标题文字与装饰边缘的间距，单位为点：包含 UIEdgeInsets 的 NSValue、数组 [top, left, bottom, right]，或含 "top"、
 *      "left"、"bottom"、"right" 的字典，各边不能为负。值无效时初始化方法失败并返回错误。
 */
FOUNDATION_EXPORT NSString *const CYLPlaceholderItemTitleContentInsets;
/*!
 * [EN] The minimum width of the title chrome, in points: a number from 0 to 1000. An invalid value makes the
 *      initializer fail with an error.
 * [CN] 标题装饰的最小宽度，单位为点：0 到 1000 的数字。值无效时初始化方法失败并返回错误。
 */
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
/*!
 * [EN] YES when the animation is loaded and can play. A view that is not ready when the factory returns it shows the
 *      static image until it calls `readyHandler`.
 * [CN] 动画已加载、可以播放时为 YES。工厂返回时尚未就绪的视图，在调用 `readyHandler` 之前显示静态图片。
 */
@property (nonatomic, readonly, getter=isReady) BOOL ready;
/*!
 * [EN] Set by CYLPlaceholderView after the factory returns the view; call it on the main thread when loading or
 *      playback fails later. The error is logged and the static image shows again.
 * [CN] 工厂返回视图后由 CYLPlaceholderView 设置；之后加载或播放失败时在主线程调用它。错误会被记录，并重新显示静态图片。
 */
@property (nonatomic, copy, nullable) void (^errorHandler)(NSError *error);
/*!
 * [EN] Set by CYLPlaceholderView after the factory returns the view; call it on the main thread when a view that was
 *      not ready finishes loading, so the animation replaces the static image.
 * [CN] 工厂返回视图后由 CYLPlaceholderView 设置；尚未就绪的视图加载完成时在主线程调用它，使动画代替静态图片显示。
 */
@property (nonatomic, copy, nullable) void (^readyHandler)(void);
/*!
 * [EN] Starts playback.
 * [CN] 开始播放。
 */
- (void)play;
/*!
 * [EN] Stops playback.
 * [CN] 停止播放。
 */
- (void)stop;
/*!
 * [EN] Shows the animation's last frame without playing it (CYLPlaceholderView's `showPlaceholderAnimationLastFrame`).
 * [CN] 不播放动画，直接显示最后一帧（对应 CYLPlaceholderView 的 `showPlaceholderAnimationLastFrame`）。
 */
- (void)showLastFrame;
@optional
/*!
 * [EN] Moves the animation to `progress`, from 0 (the first frame) to 1 (the last frame). Return NO when unsupported;
 *      without it, progress cannot be set.
 * [CN] 把动画定位到 `progress`，0 为第一帧，1 为最后一帧。不支持时返回 NO；未实现时无法设置进度。
 */
- (BOOL)setAnimationProgress:(CGFloat)progress;
/*!
 * [EN] Sets the playback speed, a multiplier where 1 is the file's own speed. Return NO when unsupported; without it, a
 *      speed set on the view is logged as unsupported.
 * [CN] 设置播放速度，倍数，1 为文件本身的速度。不支持时返回 NO；未实现时，在视图上设置的速度会被记录为不支持。
 */
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

/*!
 * [EN] Creates the view that plays one animation file of an extension registered with
 *      `+registerAnimationFactory:forFileExtension:`. It receives the file URL (without the options), the size in
 *      points, the content mode and the `CYLPlaceholderItemAnimationOptions` entries (values as strings), and returns a
 *      view that conforms to CYLPlaceholderAnimationPlayer, or nil with an error (logged; the static image shows).
 * [CN] 创建播放某个文件的视图，该文件的扩展名通过 `+registerAnimationFactory:forFileExtension:` 注册。参数为文件 URL（
 *      不含选项）、尺寸（点）、缩放方式以及 `CYLPlaceholderItemAnimationOptions` 中的条目（值为字符串）；返回遵循
 *      CYLPlaceholderAnimationPlayer 的视图，或返回 nil 并给出错误（会被记录，并显示静态图片）。
 */
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
