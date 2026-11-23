import Flutter
import UIKit
import CYLTableViewPlaceHolder

/**
 * [EN] Creates the platform view of the native `CYLPlaceholderStackView`. The creation parameters are the configuration
 *      dictionary of `docs/Placeholder-Scenarios.md` ("components", optional "backgroundAction"), which
 *      `CYLPlaceholderBridge.stackView` reads.
 * [CN] 创建原生 `CYLPlaceholderStackView` 的 platform view。创建参数为 `docs/Placeholder-Scenarios.md` 的配置字典
 *      （"components"，可选 "backgroundAction"），由 `CYLPlaceholderBridge.stackView` 读取。
 */
final class CYLPlaceholderStackPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    /// The view type the Dart side asks for.
    static let viewType = "flutter_cylplaceholder/CYLPlaceholderStackView"

    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        CYLPlaceholderStackPlatformView(frame: frame, viewId: viewId, messenger: messenger, params: args as? [String: Any] ?? [:])
    }
}

/**
 * [EN] One native placeholder stack in a Flutter widget. The channel `flutter_cylplaceholder/CYLPlaceholderStackView/<id>`
 *      carries "update" from Dart (a name and a value, applied by `CYLPlaceholderBridge.updateStackView`) and "onAction" back
 *      (the name of the tapped button or background action). The container has the accessibility identifier
 *      `cyl.native.placeholderStack`.
 * [CN] Flutter 控件里的一个原生占位堆叠视图。通道 `flutter_cylplaceholder/CYLPlaceholderStackView/<id>` 承载来自 Dart 的 "update"
 *      （名称与值，由 `CYLPlaceholderBridge.updateStackView` 应用）与回传的 "onAction"（被点按的按钮或背景动作名）。
 *      容器的 accessibilityIdentifier 为 `cyl.native.placeholderStack`。
 */
final class CYLPlaceholderStackPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private let stack: CYLPlaceholderStackView?

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, params: [String: Any]) {
        let channel = FlutterMethodChannel(name: "\(CYLPlaceholderStackPlatformViewFactory.viewType)/\(viewId)", binaryMessenger: messenger)
        self.channel = channel
        container = UIView(frame: frame)
        stack = CYLPlaceholderBridge.stackView(configuration: params) { action in
            channel.invokeMethod("onAction", arguments: action)
        }
        super.init()
        container.accessibilityIdentifier = "cyl.native.placeholderStack"
        if let view = stack {
            view.frame = container.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            container.addSubview(view)
        }
        channel.setMethodCallHandler { [weak self] call, result in self?.handle(call, result: result) }
    }

    func view() -> UIView { container }

    private func handle(_ call: FlutterMethodCall, result: FlutterResult) {
        guard call.method == "update" else { return result(FlutterMethodNotImplemented) }
        guard let view = stack else {
            return result(FlutterError(code: "no_view", message: "The configuration map was not valid.", details: nil))
        }
        guard let arguments = call.arguments as? [String: Any], let name = arguments["name"] as? String else {
            return result(FlutterError(code: "bad_arguments", message: "update needs a name.", details: nil))
        }
        if CYLPlaceholderBridge.updateStackView(view, name: name, value: arguments["value"]) {
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    deinit {
        channel.setMethodCallHandler(nil)
    }
}
