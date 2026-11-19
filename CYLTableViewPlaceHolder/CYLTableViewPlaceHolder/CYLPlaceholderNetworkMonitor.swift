//
//  CYLPlaceholderNetworkMonitor.swift
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The detection logic follows -[AVIMWebSocketWrapper startNotifyReachability] / -isReachable (AVOSCloudIM,
//      "Created by Qihe Bian on 12/4/14. Copyright (c) 2014 LeanCloud Inc.", vendored in CYLChatKit, commit b730b8d,
//      ChatKit-OC/Pods/AVOSCloudIM/AVOS/AVOSCloudIM/WebSocket/AVIMWebSocketWrapper.m) and the statuses of
//      AFNetworkReachabilityManager (AFNetworking, MIT). The SCNetworkReachability calls are replaced by NWPathMonitor.
//      Swift since 2026-11-19 with the same Objective-C API; the status enum, the notification constant and the block
//      type stay in `CYLPlaceholderNetworkMonitor.h` / `CYLPlaceholderNetworkMonitorSupport.m`.
// [CN] 检测逻辑参照 AVIMWebSocketWrapper 的 startNotifyReachability / isReachable（LeanCloud，随 CYLChatKit 提供）与
//      AFNetworkReachabilityManager 的状态（AFNetworking，MIT）；SCNetworkReachability 调用改为 NWPathMonitor。自 2026-11-19 起用 Swift
//      编写，Objective-C API 不变；状态枚举、通知常量与回调类型保留在 `CYLPlaceholderNetworkMonitor.h` /
//      `CYLPlaceholderNetworkMonitorSupport.m` 中。
//
// [EN] Lessons from Sentry's move off SCNetworkReachability (getsentry/sentry-cocoa#5440, fixed by #6019 in
//      Sources/Swift/Networking/SentryReachability.swift, MIT):
//      - No host name: SCNetworkReachabilityCreateWithName made the system look the host up (DNS queries on every
//        network change, even with telemetry off). NWPathMonitor watches the device's path and sends nothing.
//      - A started monitor keeps running, even without a strong reference, until it is cancelled; and a cancelled one
//        cannot be started again. So every start creates a new monitor, and stop and deinit cancel it.
//      - A cancelled monitor can still deliver an update that was already queued: an update counts only when it comes
//        from the current monitor.
//      - Cancelling a monitor from inside its own update handler, on its own queue, wedges that queue: the monitor
//        runs on a private serial queue, and the status, the block and the notification move to the main queue, so a
//        caller that stops monitoring from the change block does it outside the handler.
//      - No path reported yet is not "offline": the status stays unknown until the first update.
// [CN] 借鉴 Sentry 放弃 SCNetworkReachability 的经验（getsentry/sentry-cocoa#5440，由 #6019 修复，MIT）：不使用主机名（按主机名创建
//      会在每次网络变化时发起 DNS 查询）；已启动的监测器在取消前一直运行，取消后不能重新启动，因此每次启动都新建监测器，停止与释放时取消；
//      已取消的监测器仍可能送达排队中的更新，只接受当前监测器的更新；在监测器自己的回调中取消会卡住其队列，因此监测器运行在私有串行队列上，
//      状态、回调与通知转到主队列；尚未报告路径不等于离线。

import Foundation
import Network

/**
 * [EN] Watches whether the device has a network path (see `CYLPlaceholderNetworkMonitor.h`). Use it from the main thread.
 * [CN] 监测设备是否有可用的网络路径（见 `CYLPlaceholderNetworkMonitor.h`）。请在主线程使用。
 */
@objc(CYLPlaceholderNetworkMonitor)
open class CYLPlaceholderNetworkMonitor: NSObject {

    /**
     * [EN] The shared monitor, as `+[LCNetworkReachabilityManager manager]` gave CYLChatKit one; it starts on first use of
     *      `startMonitoring`. [CN] 共享的监测器，对应 CYLChatKit 中的 `+[LCNetworkReachabilityManager manager]`；调用 `startMonitoring` 后开始。
     */
    @objc(sharedMonitor) public static let shared = CYLPlaceholderNetworkMonitor()

    /**
     * [EN] The current status; `CYLPlaceholderNetworkStatusUnknown` before the first update. [CN] 当前状态；首次更新前为未知。
     */
    @objc public private(set) dynamic var networkStatus: CYLPlaceholderNetworkStatus = .unknown

    /**
     * [EN] NO only when the status is `NotReachable`, as `-[AVIMWebSocketWrapper isReachable]`; an unknown status counts as
     *      reachable. [CN] 只有状态为不可达时为 NO，与 `-[AVIMWebSocketWrapper isReachable]` 相同；未知状态视为可达。
     */
    @objc(reachable) public var isReachable: Bool {
        @objc(isReachable) get { networkStatus != .notReachable }
    }

    /**
     * [EN] Low Data Mode is on for the path (iOS 13 and later; NO before). [CN] 当前路径开启了低数据模式（iOS 13 起）。
     */
    @objc(constrained) public var isConstrained: Bool {
        @objc(isConstrained) get { storedConstrained }
    }

    /**
     * [EN] The path is expensive: cellular, or a personal hotspot. [CN] 当前路径费用较高：蜂窝或个人热点。
     */
    @objc(expensive) public var isExpensive: Bool {
        @objc(isExpensive) get { storedExpensive }
    }

    /**
     * [EN] Whether it is monitoring. [CN] 是否正在监测。
     */
    @objc(monitoring) public var isMonitoring: Bool {
        @objc(isMonitoring) get { pathMonitor != nil }
    }

    private var storedConstrained = false
    private var storedExpensive = false
    private var pathMonitor: NWPathMonitor?
    private let monitorQueue = DispatchQueue(label: "com.chenyilong.CYLTableViewPlaceHolder.network", qos: .utility)
    private var changeBlock: CYLPlaceholderNetworkStatusBlock?
    // [EN] Counts the monitors started, so an update from an earlier one is recognized. [CN] 启动次数，用于识别旧监测器的更新。
    private var generation: UInt = 0

    /**
     * [EN] A monitor that is not monitoring yet; most callers use `shared`. [CN] 尚未开始监测的监测器；多数调用方使用 `shared`。
     */
    public override init() {
        super.init()
    }

    deinit {
        // [EN] A started monitor outlives its last reference until it is cancelled. [CN] 已启动的监测器在取消前不会随引用释放而停止。
        pathMonitor?.cancel()
    }

    /**
     * [EN] Starts monitoring; the status arrives soon after on the main queue. [CN] 开始监测；状态随后在主队列到达。
     */
    @objc open func startMonitoring() {
        assert(Thread.isMainThread, "Start monitoring on the main thread.")
        if pathMonitor != nil { return }
        // [EN] A new monitor every time: a cancelled one cannot be restarted. [CN] 每次新建：已取消的监测器不能重新启动。
        let monitor = NWPathMonitor()
        generation &+= 1
        let generation = self.generation
        monitor.pathUpdateHandler = { [weak self] path in
            // [EN] Read the path here, on the monitor's queue; apply it on the main queue, outside this handler.
            // [CN] 在监测器队列上读取路径；在主队列、本回调之外应用。
            let status = CYLPlaceholderNetworkMonitor.status(for: path)
            var constrained = false
            if #available(iOS 13.0, *) { constrained = path.isConstrained }
            let expensive = path.isExpensive
            DispatchQueue.main.async { [weak self] in
                // [EN] Ignore an update a cancelled monitor had queued. [CN] 忽略已取消的监测器排队中的更新。
                guard let self = self, self.pathMonitor != nil, self.generation == generation else { return }
                self.cyl_setStatus(status, constrained: constrained, expensive: expensive)
            }
        }
        pathMonitor = monitor
        monitor.start(queue: monitorQueue)
    }

    /**
     * [EN] Stops monitoring; the status becomes unknown. [CN] 停止监测；状态变为未知。
     */
    @objc open func stopMonitoring() {
        assert(Thread.isMainThread, "Stop monitoring on the main thread.")
        guard let monitor = pathMonitor else { return }
        pathMonitor = nil
        monitor.cancel()
        cyl_setStatus(.unknown, constrained: false, expensive: false)
    }

    /**
     * [EN] The block run on every change, as `-setReachabilityStatusChangeBlock:`; nil removes it. Notifications are posted
     *      too. [CN] 每次状态变化时执行的回调，对应 `-setReachabilityStatusChangeBlock:`；nil 表示移除。同时也会发送通知。
     */
    @objc(setNetworkStatusChangeBlock:)
    open func setNetworkStatusChangeBlock(_ block: CYLPlaceholderNetworkStatusBlock?) {
        changeBlock = block
    }

    /**
     * [EN] A short English name of a status, for logs. [CN] 状态的英文简称，用于日志。
     */
    @objc(nameForStatus:)
    public static func name(for status: CYLPlaceholderNetworkStatus) -> String {
        switch status {
        case .unknown: return "unknown"
        case .notReachable: return "not reachable"
        case .reachableViaWWAN: return "cellular"
        case .reachableViaWiFi: return "Wi-Fi"
        case .reachableViaWiredEthernet: return "wired Ethernet"
        case .reachableViaOther: return "other"
        @unknown default: return "unknown"
        }
    }

    // [EN] AFNetworking's status mapping, on NWPath. [CN] AFNetworking 的状态映射，基于 NWPath。
    private static func status(for path: NWPath) -> CYLPlaceholderNetworkStatus {
        // [EN] "Requires connection" (a VPN on demand, a captive network) cannot carry data yet: not reachable.
        // [CN] “需要连接”（按需 VPN、需要登录的网络）暂时无法传输数据：视为不可达。
        if path.status != .satisfied { return .notReachable }
        if path.usesInterfaceType(.wifi) { return .reachableViaWiFi }
        if path.usesInterfaceType(.cellular) { return .reachableViaWWAN }
        if path.usesInterfaceType(.wiredEthernet) { return .reachableViaWiredEthernet }
        // [EN] A VPN or another interface; Sentry reports these as Wi-Fi, here they keep their own value.
        // [CN] VPN 或其他接口；Sentry 将其报告为 Wi-Fi，这里保留单独的值。
        return .reachableViaOther
    }

    // [EN] Applies an update on the main queue; reports only real changes. The tests call it by its selector.
    // [CN] 在主队列应用更新；只报告真正的变化。测试通过其选择器直接调用。
    @objc(cyl_setStatus:constrained:expensive:)
    private func cyl_setStatus(_ status: CYLPlaceholderNetworkStatus, constrained: Bool, expensive: Bool) {
        let statusChanged = status != networkStatus
        let costChanged = constrained != storedConstrained || expensive != storedExpensive
        // [EN] Key-value observers see every update, as with the Objective-C property setters.
        // [CN] 与 Objective-C 属性的 setter 相同，键值观察者能收到每次更新。
        willChangeValue(forKey: "constrained")
        storedConstrained = constrained
        didChangeValue(forKey: "constrained")
        willChangeValue(forKey: "expensive")
        storedExpensive = expensive
        didChangeValue(forKey: "expensive")
        networkStatus = status
        if statusChanged, let changeBlock = changeBlock { changeBlock(status) }
        // [EN] Low Data Mode and expensive paths change without the status; observers hear those too.
        // [CN] 低数据模式与昂贵网络可能在状态不变时变化；观察者同样会收到。
        if statusChanged || costChanged {
            NotificationCenter.default.post(name: CYLPlaceholderNetworkMonitor.statusDidChangeNotification, object: self)
        }
    }
}
