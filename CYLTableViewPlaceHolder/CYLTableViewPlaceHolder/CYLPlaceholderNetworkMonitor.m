//
//  CYLPlaceholderNetworkMonitor.m
//  CYLTableViewPlaceHolder
//
//  [EN] The detection logic follows -[AVIMWebSocketWrapper startNotifyReachability] / -isReachable (AVOSCloudIM,
//       "Created by Qihe Bian on 12/4/14. Copyright (c) 2014 LeanCloud Inc.", vendored in CYLChatKit, commit b730b8d,
//       ChatKit-OC/Pods/AVOSCloudIM/AVOS/AVOSCloudIM/WebSocket/AVIMWebSocketWrapper.m) and the statuses of
//       AFNetworkReachabilityManager (AFNetworking, MIT). The SCNetworkReachability calls are replaced by NWPathMonitor.
//  [CN] 检测逻辑参照 AVIMWebSocketWrapper 的 startNotifyReachability / isReachable（LeanCloud，随 CYLChatKit 提供）与
//       AFNetworkReachabilityManager 的状态（AFNetworking，MIT）；SCNetworkReachability 调用改为 NWPathMonitor。
//

#import "CYLPlaceholderNetworkMonitor.h"
#import <Network/Network.h>

NSNotificationName const CYLPlaceholderNetworkStatusDidChangeNotification = @"CYLPlaceholderNetworkStatusDidChangeNotification";

/*
 * [EN] Lessons from Sentry's move off SCNetworkReachability (getsentry/sentry-cocoa#5440, fixed by #6019 in
 *      Sources/Swift/Networking/SentryReachability.swift, MIT):
 *      - No host name: SCNetworkReachabilityCreateWithName made the system look the host up (DNS queries on every
 *        network change, even with telemetry off). NWPathMonitor watches the device's path and sends nothing.
 *      - A started monitor keeps running, even without a strong reference, until it is cancelled; and a cancelled one
 *        cannot be started again. So every start creates a new monitor, and stop and dealloc cancel it.
 *      - A cancelled monitor can still deliver an update that was already queued: an update counts only when it comes
 *        from the current monitor.
 *      - Cancelling a monitor from inside its own update handler, on its own queue, wedges that queue: the monitor
 *        runs on a private serial queue, and the status, the block and the notification move to the main queue, so a
 *        caller that stops monitoring from the change block does it outside the handler.
 *      - No path reported yet is not "offline": the status stays unknown until the first update.
 * [CN] 借鉴 Sentry 放弃 SCNetworkReachability 的经验（getsentry/sentry-cocoa#5440，由 #6019 修复，MIT）：不使用主机名（按主机名创建
 *      会在每次网络变化时发起 DNS 查询）；已启动的监测器在取消前一直运行，取消后不能重新启动，因此每次启动都新建监测器，停止与释放时取消；
 *      已取消的监测器仍可能送达排队中的更新，只接受当前监测器的更新；在监测器自己的回调中取消会卡住其队列，因此监测器运行在私有串行队列上，
 *      状态、回调与通知转到主队列；尚未报告路径不等于离线。
 */

/// [EN] AFNetworking's status mapping, on NWPath. [CN] AFNetworking 的状态映射，基于 NWPath。
static CYLPlaceholderNetworkStatus CYLPlaceholderNetworkStatusForPath(nw_path_t path) {
    // [EN] "Requires connection" (a VPN on demand, a captive network) cannot carry data yet: not reachable.
    // [CN] “需要连接”（按需 VPN、需要登录的网络）暂时无法传输数据：视为不可达。
    if (nw_path_get_status(path) != nw_path_status_satisfied) return CYLPlaceholderNetworkStatusNotReachable;
    if (nw_path_uses_interface_type(path, nw_interface_type_wifi)) return CYLPlaceholderNetworkStatusReachableViaWiFi;
    if (nw_path_uses_interface_type(path, nw_interface_type_cellular)) return CYLPlaceholderNetworkStatusReachableViaWWAN;
    if (nw_path_uses_interface_type(path, nw_interface_type_wired)) return CYLPlaceholderNetworkStatusReachableViaWiredEthernet;
    // [EN] A VPN or another interface; Sentry reports these as Wi-Fi, here they keep their own value.
    // [CN] VPN 或其他接口；Sentry 将其报告为 Wi-Fi，这里保留单独的值。
    return CYLPlaceholderNetworkStatusReachableViaOther;
}

@interface CYLPlaceholderNetworkMonitor ()
@property (nonatomic, readwrite) CYLPlaceholderNetworkStatus networkStatus;
@property (nonatomic, readwrite, getter=isConstrained) BOOL constrained;
@property (nonatomic, readwrite, getter=isExpensive) BOOL expensive;
@property (nonatomic, strong) nw_path_monitor_t pathMonitor;
@property (nonatomic, strong) dispatch_queue_t monitorQueue;
@property (nonatomic, copy) CYLPlaceholderNetworkStatusBlock changeBlock;
/// [EN] Counts the monitors started, so an update from an earlier one is recognized. [CN] 启动次数，用于识别旧监测器的更新。
@property (nonatomic) NSUInteger generation;
@end

@implementation CYLPlaceholderNetworkMonitor

+ (CYLPlaceholderNetworkMonitor *)sharedMonitor {
    static CYLPlaceholderNetworkMonitor *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[CYLPlaceholderNetworkMonitor alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _networkStatus = CYLPlaceholderNetworkStatusUnknown;
        _monitorQueue = dispatch_queue_create("com.chenyilong.CYLTableViewPlaceHolder.network",
            dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0));
    }
    return self;
}

- (void)dealloc {
    // [EN] A started monitor outlives its last reference until it is cancelled. [CN] 已启动的监测器在取消前不会随引用释放而停止。
    if (_pathMonitor) nw_path_monitor_cancel(_pathMonitor);
}

- (BOOL)isReachable {
    return self.networkStatus != CYLPlaceholderNetworkStatusNotReachable;
}

- (BOOL)isMonitoring {
    return self.pathMonitor != nil;
}

- (void)setNetworkStatusChangeBlock:(CYLPlaceholderNetworkStatusBlock)block {
    self.changeBlock = block;
}

- (void)startMonitoring {
    NSAssert(NSThread.isMainThread, @"Start monitoring on the main thread.");
    if (self.pathMonitor) return;
    // [EN] A new monitor every time: a cancelled one cannot be restarted. [CN] 每次新建：已取消的监测器不能重新启动。
    nw_path_monitor_t monitor = nw_path_monitor_create();
    __weak typeof(self) weakSelf = self;
    NSUInteger generation = ++self.generation;
    nw_path_monitor_set_queue(monitor, self.monitorQueue);
    nw_path_monitor_set_update_handler(monitor, ^(nw_path_t path) {
        // [EN] Read the path here, on the monitor's queue; apply it on the main queue, outside this handler.
        // [CN] 在监测器队列上读取路径；在主队列、本回调之外应用。
        CYLPlaceholderNetworkStatus status = CYLPlaceholderNetworkStatusForPath(path);
        BOOL constrained = NO;
        if (@available(iOS 13.0, *)) constrained = nw_path_is_constrained(path);
        BOOL expensive = nw_path_is_expensive(path);
        dispatch_async(dispatch_get_main_queue(), ^{
            CYLPlaceholderNetworkMonitor *strongSelf = weakSelf;
            // [EN] Ignore an update a cancelled monitor had queued. [CN] 忽略已取消的监测器排队中的更新。
            if (!strongSelf.pathMonitor || strongSelf.generation != generation) return;
            [strongSelf cyl_setStatus:status constrained:constrained expensive:expensive];
        });
    });
    self.pathMonitor = monitor;
    nw_path_monitor_start(monitor);
}

- (void)stopMonitoring {
    NSAssert(NSThread.isMainThread, @"Stop monitoring on the main thread.");
    if (!self.pathMonitor) return;
    nw_path_monitor_t monitor = self.pathMonitor;
    self.pathMonitor = nil;
    nw_path_monitor_cancel(monitor);
    [self cyl_setStatus:CYLPlaceholderNetworkStatusUnknown constrained:NO expensive:NO];
}

/// [EN] Applies an update on the main queue; reports only real changes. [CN] 在主队列应用更新；只报告真正的变化。
- (void)cyl_setStatus:(CYLPlaceholderNetworkStatus)status constrained:(BOOL)constrained expensive:(BOOL)expensive {
    BOOL statusChanged = status != self.networkStatus;
    BOOL costChanged = constrained != self.constrained || expensive != self.expensive;
    self.constrained = constrained;
    self.expensive = expensive;
    self.networkStatus = status;
    if (statusChanged && self.changeBlock) self.changeBlock(status);
    // [EN] Low Data Mode and expensive paths change without the status; observers hear those too.
    // [CN] 低数据模式与昂贵网络可能在状态不变时变化；观察者同样会收到。
    if (statusChanged || costChanged) {
        [NSNotificationCenter.defaultCenter postNotificationName:CYLPlaceholderNetworkStatusDidChangeNotification object:self];
    }
}

+ (NSString *)nameForStatus:(CYLPlaceholderNetworkStatus)status {
    switch (status) {
        case CYLPlaceholderNetworkStatusUnknown: return @"unknown";
        case CYLPlaceholderNetworkStatusNotReachable: return @"not reachable";
        case CYLPlaceholderNetworkStatusReachableViaWWAN: return @"cellular";
        case CYLPlaceholderNetworkStatusReachableViaWiFi: return @"Wi-Fi";
        case CYLPlaceholderNetworkStatusReachableViaWiredEthernet: return @"wired Ethernet";
        case CYLPlaceholderNetworkStatusReachableViaOther: return @"other";
    }
    return @"unknown";
}

@end
