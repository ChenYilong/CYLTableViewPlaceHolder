import Flutter
import UIKit
import CYLTableViewPlaceHolder

/**
 * [EN] The iOS half of flutter_cylplaceholder, the counterpart of the Android `FlutterCylplaceholderPlugin`: it registers the
 *      platform view factories of the native `CYLPlaceholderView` and `CYLPlaceholderStackView` and the method channel
 *      `flutter_cylplaceholder/hud` that drives the native `CYLPlaceholderHUD`, with the same channel names, method names and
 *      argument keys as Android. The native component is reached only through `CYLPlaceholderBridge` and `CYLPlaceholderHUDBridge`.
 * [CN] flutter_cylplaceholder 的 iOS 一半，对应 Android 的 `FlutterCylplaceholderPlugin`：注册原生 `CYLPlaceholderView` 与
 *      `CYLPlaceholderStackView` 的 platform view 工厂，以及驱动原生 `CYLPlaceholderHUD` 的方法通道 `flutter_cylplaceholder/hud`；
 *      通道名、方法名与参数键均与 Android 相同。原生组件只通过 `CYLPlaceholderBridge` 与 `CYLPlaceholderHUDBridge` 访问。
 */
public final class FlutterCylplaceholderPlugin: NSObject, FlutterPlugin {
    static let hudChannelName = "flutter_cylplaceholder/hud"

    private let channel: FlutterMethodChannel
    private var hud: CYLPlaceholderHUDBridge?

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        registrar.register(CYLPlaceholderPlatformViewFactory(messenger: messenger), withId: CYLPlaceholderPlatformViewFactory.viewType)
        registrar.register(CYLPlaceholderStackPlatformViewFactory(messenger: messenger), withId: CYLPlaceholderStackPlatformViewFactory.viewType)
        registrar.register(CYLRefreshPlatformViewFactory(messenger: messenger), withId: CYLRefreshPlatformViewFactory.viewType)
        let channel = FlutterMethodChannel(name: hudChannelName, binaryMessenger: messenger)
        let plugin = FlutterCylplaceholderPlugin(channel: channel)
        registrar.addMethodCallDelegate(plugin, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let bridge = hudBridge() else {
            return result(FlutterError(code: "no_view", message: "The HUD needs a foreground window.", details: nil))
        }
        if bridge.handle(method: call.method, arguments: call.arguments as? [String: Any]) {
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    // [EN] The HUD lays itself over the root view of the foreground window, the Flutter view's host.
    // [CN] HUD 覆盖在前台窗口的根视图（Flutter 视图的宿主）之上。
    private func hudBridge() -> CYLPlaceholderHUDBridge? {
        if let hud = hud { return hud }
        guard let container = Self.foregroundRootView() else { return nil }
        let bridge = CYLPlaceholderHUDBridge(container: container) { [weak self] action in
            self?.channel.invokeMethod("onAction", arguments: action)
        }
        hud = bridge
        return bridge
    }

    private static func foregroundRootView() -> UIView? {
        let windows = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.windows }.flatMap { $0 }
        let window = windows.first(where: { $0.isKeyWindow }) ?? windows.first
        return window?.rootViewController?.view
    }
}
