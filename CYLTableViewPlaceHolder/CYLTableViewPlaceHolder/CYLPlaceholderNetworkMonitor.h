//
//  CYLPlaceholderNetworkMonitor.h
//  CYLTableViewPlaceHolder
//
//  [EN] Watches whether the device has a network path, so the network-failure placeholder and the status bar
//       (`CYLPlaceholderStatusView`) can follow it. Ported from the detection CYLChatKit's status bar depends on: the
//       reachability monitoring of AVIMWebSocketWrapper (LeanCloud, vendored in CYLChatKit's ChatKit-OC/Pods) through
//       LCNetworkReachabilityManager, an AFNetworkReachabilityManager variant: the same statuses (unknown, not
//       reachable, via WWAN, via Wi-Fi), a change block, start / stop monitoring and `reachable`.
//       Adapted to current systems: SCNetworkReachability is deprecated since iOS 17 and only says whether a packet
//       could leave the device, so this uses Network.framework's NWPathMonitor (iOS 12+, the library's minimum),
//       which also reports wired Ethernet, Low Data Mode (`constrained`, iOS 13+) and expensive paths (cellular or a
//       personal hotspot). An unknown status (before the first update) does not count as offline, so no bar flashes
//       at launch; ChatKit treated it as unreachable. As in Sentry's replacement of SCNetworkReachability
//       (getsentry/sentry-cocoa#5440): no host name is watched, so no DNS query is made on network changes; every start
//       creates a new monitor and stop cancels it; updates of a cancelled monitor are ignored. Use it from the main
//       thread: the status, the block and the notification change there.
//  [CN] 监测设备是否有可用的网络路径，供网络失败占位图与状态条（`CYLPlaceholderStatusView`）使用。移植自 CYLChatKit 状态条所依赖的检测：
//       AVIMWebSocketWrapper（LeanCloud，随 CYLChatKit 的 ChatKit-OC/Pods 提供）通过 LCNetworkReachabilityManager
//       （AFNetworkReachabilityManager 的变体）进行的可达性监测：相同的状态（未知、不可达、蜂窝、Wi-Fi）、状态变化回调、开始/停止监测与
//       `reachable`。适配新系统：SCNetworkReachability 自 iOS 17 起已废弃，且只表示数据包能否离开设备，因此改用 Network.framework 的
//       NWPathMonitor（iOS 12 起可用，即本库的最低版本），并报告有线以太网、低数据模式（`constrained`，iOS 13 起）与昂贵网络（蜂窝或个人热点）。
//       未知状态（首次更新之前）不算离线，避免启动时状态条闪现；ChatKit 曾把它当作不可达。与 Sentry 替换 SCNetworkReachability 的做法相同
//       （getsentry/sentry-cocoa#5440）：不监测主机名，网络变化时不发起 DNS 查询；每次启动新建监测器、停止时取消；忽略已取消监测器的更新。
//       请在主线程使用：状态、回调与通知都在主线程变化。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The network status; the first four values are AFNetworkReachabilityStatus's, as CYLChatKit used them.
 * [CN] 网络状态；前四个值与 CYLChatKit 使用的 AFNetworkReachabilityStatus 相同。
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderNetworkStatus) {
    /*! [EN] Not known yet (before the first update, or not monitoring). [CN] 尚未知道（首次更新之前，或未在监测）。 */
    CYLPlaceholderNetworkStatusUnknown = -1,
    /*! [EN] No usable path: offline, airplane mode, or a path that needs a connection first. [CN] 没有可用路径。 */
    CYLPlaceholderNetworkStatusNotReachable = 0,
    /*! [EN] Through cellular data. [CN] 通过蜂窝数据。 */
    CYLPlaceholderNetworkStatusReachableViaWWAN = 1,
    /*! [EN] Through Wi-Fi. [CN] 通过 Wi-Fi。 */
    CYLPlaceholderNetworkStatusReachableViaWiFi = 2,
    /*! [EN] Through wired Ethernet (an adapter, or a Mac running the app). [CN] 通过有线以太网。 */
    CYLPlaceholderNetworkStatusReachableViaWiredEthernet = 3,
    /*! [EN] Through another interface (a VPN, a loopback). [CN] 通过其他接口（如 VPN）。 */
    CYLPlaceholderNetworkStatusReachableViaOther = 4,
};

/*! [EN] Posted on the main queue when `networkStatus` changes; `object` is the monitor. [CN] 网络状态变化时在主队列发送。 */
FOUNDATION_EXPORT NSNotificationName const CYLPlaceholderNetworkStatusDidChangeNotification
    NS_SWIFT_NAME(CYLPlaceholderNetworkMonitor.statusDidChangeNotification);

/*! [EN] Runs on the main queue with the new status. [CN] 在主队列执行，参数为新状态。 */
typedef void (^CYLPlaceholderNetworkStatusBlock)(CYLPlaceholderNetworkStatus status);

@interface CYLPlaceholderNetworkMonitor : NSObject

/*!
 * [EN] The shared monitor, as `+[LCNetworkReachabilityManager manager]` gave CYLChatKit one; it starts on first use of
 *      `startMonitoring`. [CN] 共享的监测器，对应 CYLChatKit 中的 `+[LCNetworkReachabilityManager manager]`；调用 `startMonitoring` 后开始。
 */
@property (class, nonatomic, readonly) CYLPlaceholderNetworkMonitor *sharedMonitor NS_SWIFT_NAME(shared);

/*! [EN] The current status; `CYLPlaceholderNetworkStatusUnknown` before the first update. [CN] 当前状态；首次更新前为未知。 */
@property (nonatomic, readonly) CYLPlaceholderNetworkStatus networkStatus;
/*!
 * [EN] NO only when the status is `NotReachable`, as `-[AVIMWebSocketWrapper isReachable]`; an unknown status counts as
 *      reachable. [CN] 只有状态为不可达时为 NO，与 `-[AVIMWebSocketWrapper isReachable]` 相同；未知状态视为可达。
 */
@property (nonatomic, readonly, getter=isReachable) BOOL reachable;
/*! [EN] Low Data Mode is on for the path (iOS 13 and later; NO before). [CN] 当前路径开启了低数据模式（iOS 13 起）。 */
@property (nonatomic, readonly, getter=isConstrained) BOOL constrained;
/*! [EN] The path is expensive: cellular, or a personal hotspot. [CN] 当前路径费用较高：蜂窝或个人热点。 */
@property (nonatomic, readonly, getter=isExpensive) BOOL expensive;
/*! [EN] Whether it is monitoring. [CN] 是否正在监测。 */
@property (nonatomic, readonly, getter=isMonitoring) BOOL monitoring;

/*! [EN] Starts monitoring; the status arrives soon after on the main queue. [CN] 开始监测；状态随后在主队列到达。 */
- (void)startMonitoring;
/*! [EN] Stops monitoring; the status becomes unknown. [CN] 停止监测；状态变为未知。 */
- (void)stopMonitoring;
/*!
 * [EN] The block run on every change, as `-setReachabilityStatusChangeBlock:`; nil removes it. Notifications are posted
 *      too. [CN] 每次状态变化时执行的回调，对应 `-setReachabilityStatusChangeBlock:`；nil 表示移除。同时也会发送通知。
 */
- (void)setNetworkStatusChangeBlock:(nullable CYLPlaceholderNetworkStatusBlock)block
    NS_SWIFT_NAME(setNetworkStatusChangeBlock(_:));
/*! [EN] A short English name of a status, for logs. [CN] 状态的英文简称，用于日志。 */
+ (NSString *)nameForStatus:(CYLPlaceholderNetworkStatus)status NS_SWIFT_NAME(name(for:));

@end

NS_ASSUME_NONNULL_END
