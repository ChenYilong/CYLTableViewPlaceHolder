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

@interface CYLPlaceholderNetworkMonitor ()
@property (nonatomic, readwrite) CYLPlaceholderNetworkStatus networkStatus;
@property (nonatomic, readwrite, getter=isConstrained) BOOL constrained;
@property (nonatomic, readwrite, getter=isExpensive) BOOL expensive;
@property (nonatomic, strong) nw_path_monitor_t pathMonitor;
@property (nonatomic, copy) CYLPlaceholderNetworkStatusBlock changeBlock;
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
    }
    return self;
}

- (void)dealloc {
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
    nw_path_monitor_t monitor = nw_path_monitor_create();
    __weak typeof(self) weakSelf = self;
    nw_path_monitor_set_queue(monitor, dispatch_get_main_queue());
    nw_path_monitor_set_update_handler(monitor, ^(nw_path_t path) {
        [weakSelf cyl_updateWithPath:path];
    });
    self.pathMonitor = monitor;
    nw_path_monitor_start(monitor);
}

- (void)stopMonitoring {
    NSAssert(NSThread.isMainThread, @"Stop monitoring on the main thread.");
    if (!self.pathMonitor) return;
    nw_path_monitor_cancel(self.pathMonitor);
    self.pathMonitor = nil;
    [self cyl_setStatus:CYLPlaceholderNetworkStatusUnknown constrained:NO expensive:NO];
}

/// [EN] AFNetworking's status mapping, on NWPath. [CN] AFNetworking 的状态映射，基于 NWPath。
- (void)cyl_updateWithPath:(nw_path_t)path {
    CYLPlaceholderNetworkStatus status = CYLPlaceholderNetworkStatusNotReachable;
    // [EN] "Requires connection" (a VPN on demand, a captive network) cannot carry data yet: not reachable.
    // [CN] “需要连接”（按需 VPN、需要登录的网络）暂时无法传输数据：视为不可达。
    if (nw_path_get_status(path) == nw_path_status_satisfied) {
        if (nw_path_uses_interface_type(path, nw_interface_type_wifi)) {
            status = CYLPlaceholderNetworkStatusReachableViaWiFi;
        } else if (nw_path_uses_interface_type(path, nw_interface_type_cellular)) {
            status = CYLPlaceholderNetworkStatusReachableViaWWAN;
        } else if (nw_path_uses_interface_type(path, nw_interface_type_wired)) {
            status = CYLPlaceholderNetworkStatusReachableViaWiredEthernet;
        } else {
            status = CYLPlaceholderNetworkStatusReachableViaOther;
        }
    }
    BOOL constrained = NO;
    if (@available(iOS 13.0, *)) constrained = nw_path_is_constrained(path);
    [self cyl_setStatus:status constrained:constrained expensive:nw_path_is_expensive(path)];
}

- (void)cyl_setStatus:(CYLPlaceholderNetworkStatus)status constrained:(BOOL)constrained expensive:(BOOL)expensive {
    self.constrained = constrained;
    self.expensive = expensive;
    if (status == self.networkStatus) return;
    self.networkStatus = status;
    if (self.changeBlock) self.changeBlock(status);
    [NSNotificationCenter.defaultCenter postNotificationName:CYLPlaceholderNetworkStatusDidChangeNotification object:self];
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
