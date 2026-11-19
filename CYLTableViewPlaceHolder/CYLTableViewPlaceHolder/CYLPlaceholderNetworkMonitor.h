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
//  [EN] Swift since 2026-11-19: the class is in `CYLPlaceholderNetworkMonitor.swift`. The status enum (used by other
//       Objective-C headers), the notification constant (a FOUNDATION_EXPORT symbol, defined in
//       `CYLPlaceholderNetworkMonitorSupport.m`) and the block type stay here in Objective-C, made Swift-compatible
//       (docs/Swift-Migration.md, rule 6).
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLPlaceholderNetworkMonitor.swift`）。状态枚举（其他 Objective-C 头文件会用到）、通知常量
//       （FOUNDATION_EXPORT 符号，定义在 `CYLPlaceholderNetworkMonitorSupport.m`）与回调类型保留在 Objective-C 中并兼容 Swift
//       （docs/Swift-Migration.md 第 6 条）。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The network status; the first four values are AFNetworkReachabilityStatus's, as CYLChatKit used them.
 * [CN] 网络状态；前四个值与 CYLChatKit 使用的 AFNetworkReachabilityStatus 相同。
 */
typedef NS_ENUM(NSInteger, CYLPlaceholderNetworkStatus) {
    /*!
     * [EN] Not known yet (before the first update, or not monitoring). [CN] 尚未知道（首次更新之前，或未在监测）。
     */
    CYLPlaceholderNetworkStatusUnknown = -1,
    /*!
     * [EN] No usable path: offline, airplane mode, or a path that needs a connection first. [CN] 没有可用路径。
     */
    CYLPlaceholderNetworkStatusNotReachable = 0,
    /*!
     * [EN] Through cellular data. [CN] 通过蜂窝数据。
     */
    CYLPlaceholderNetworkStatusReachableViaWWAN = 1,
    /*!
     * [EN] Through Wi-Fi. [CN] 通过 Wi-Fi。
     */
    CYLPlaceholderNetworkStatusReachableViaWiFi = 2,
    /*!
     * [EN] Through wired Ethernet (an adapter, or a Mac running the app). [CN] 通过有线以太网。
     */
    CYLPlaceholderNetworkStatusReachableViaWiredEthernet = 3,
    /*!
     * [EN] Through another interface (a VPN, a loopback). [CN] 通过其他接口（如 VPN）。
     */
    CYLPlaceholderNetworkStatusReachableViaOther = 4,
};

/*!
 * [EN] Posted on the main queue when `networkStatus` changes; `object` is the monitor. [CN] 网络状态变化时在主队列发送。
 */
FOUNDATION_EXPORT NSNotificationName const CYLPlaceholderNetworkStatusDidChangeNotification
    NS_SWIFT_NAME(CYLPlaceholderNetworkMonitor.statusDidChangeNotification);

/*!
 * [EN] Runs on the main queue with the new status. [CN] 在主队列执行，参数为新状态。
 */
typedef void (^CYLPlaceholderNetworkStatusBlock)(CYLPlaceholderNetworkStatus status);

/*!
 * [EN] The monitor. The class is Swift since 2026-11-19 (`CYLPlaceholderNetworkMonitor.swift`) with the same Objective-C
 *      API: `sharedMonitor` (Swift `shared`), `networkStatus`, `reachable` / `isReachable`, `constrained`, `expensive`,
 *      `monitoring`, `-startMonitoring`, `-stopMonitoring`, `-setNetworkStatusChangeBlock:` and `+nameForStatus:`
 *      (Swift `name(for:)`). Objective-C code that messages it imports the umbrella header `CYLTableViewPlaceHolder.h`,
 *      which brings the generated Swift header.
 * [CN] 监测器。该类自 2026-11-19 起用 Swift 编写（`CYLPlaceholderNetworkMonitor.swift`），Objective-C API 不变。需要调用它的
 *      Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLPlaceholderNetworkMonitor;

NS_ASSUME_NONNULL_END
