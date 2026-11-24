import Flutter
import UIKit
import CYLTableViewPlaceHolder

/**
 * [EN] Creates the platform view of the native refresh header or footer: the creation parameters are the Android ones, `footer`
 *      and `loadsAfterNoMoreData` (see `CYLRefreshDrivenHost`).
 * [CN] 创建原生刷新头或刷新尾的 platform view：创建参数与 Android 相同，`footer` 与 `loadsAfterNoMoreData`（见 `CYLRefreshDrivenHost`）。
 */
final class CYLRefreshPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    /// The view type the Dart side asks for, the same as Android. [CN] Dart 端请求的视图类型，与 Android 相同。
    static let viewType = "flutter_cylplaceholder/CYLRefreshView"

    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        CYLRefreshPlatformView(frame: frame, viewId: viewId, messenger: messenger, params: args as? [String: Any])
    }
}

/**
 * [EN] One native refresh header or footer in a Flutter widget. The channel `flutter_cylplaceholder/CYLRefreshView/<id>` carries
 *      the Android contract (documented on `CYLRefreshDrivenHost`): "drive", "release", "finishRefresh" and "noMoreData" from
 *      Dart, "onPhase" and "onRefreshing" back. The container has the accessibility identifier `cyl.native.refresh`, so a UI
 *      dump tells this view from the Dart fallback.
 * [CN] Flutter 控件里的一个原生刷新头或刷新尾。通道 `flutter_cylplaceholder/CYLRefreshView/<id>` 承载与 Android 相同的约定（见
 *      `CYLRefreshDrivenHost`）：来自 Dart 的“drive”“release”“finishRefresh”“noMoreData”，回传“onPhase”“onRefreshing”。容器的
 *      accessibilityIdentifier 为 `cyl.native.refresh`，便于在界面树里区分原生视图与 Dart 回退。
 */
final class CYLRefreshPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private let host: CYLRefreshDrivenHost

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, params: [String: Any]?) {
        let channel = FlutterMethodChannel(name: "\(CYLRefreshPlatformViewFactory.viewType)/\(viewId)", binaryMessenger: messenger)
        self.channel = channel
        container = UIView(frame: frame)
        container.clipsToBounds = true
        container.isAccessibilityElement = false
        container.accessibilityIdentifier = "cyl.native.refresh"
        host = CYLRefreshDrivenHost(frame: container.bounds, params: params) { event, arguments in
            channel.invokeMethod(event, arguments: arguments)
        }
        super.init()
        container.addSubview(host.layout)
        channel.setMethodCallHandler { [weak self] call, result in
            guard let host = self?.host else { return result(nil) }
            switch host.handle(method: call.method, arguments: call.arguments as? [String: Any]) {
            case .success: result(nil)
            case .error(let code, let message): result(FlutterError(code: code, message: message, details: nil))
            case .notImplemented: result(FlutterMethodNotImplemented)
            }
        }
    }

    func view() -> UIView { container }

    deinit {
        channel.setMethodCallHandler(nil)
    }
}
