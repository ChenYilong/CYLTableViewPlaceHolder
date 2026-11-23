import Flutter
import UIKit
import CYLTableViewPlaceHolder

/**
 * [EN] Creates the platform view of the native `CYLPlaceholderView`. The creation parameters are the item dictionary with the
 *      `CYLPlaceholderItem*` keys plus "animationLoops" and "animationSpeed" (and the Flutter-only flag "tappable").
 * [CN] 创建原生 `CYLPlaceholderView` 的 platform view。创建参数为带 `CYLPlaceholderItem*` 键的条目字典，外加 "animationLoops"、
 *      "animationSpeed"（以及仅 Flutter 使用的 "tappable"）。
 */
final class CYLPlaceholderPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    /// The view type the Dart side asks for.
    static let viewType = "flutter_cylplaceholder/CYLPlaceholderView"

    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        CYLPlaceholderPlatformView(frame: frame, viewId: viewId, messenger: messenger, params: args as? [String: Any] ?? [:])
    }
}

/**
 * [EN] One native placeholder in a Flutter widget. The channel `flutter_cylplaceholder/CYLPlaceholderView/<id>` carries "update"
 *      from Dart (a name and a value, applied by `CYLPlaceholderBridge.updatePlaceholderView`) and "onTap" back. The view
 *      has the accessibility identifier `cyl.native.placeholder`, so a UI dump tells this view from the Dart fallback.
 * [CN] Flutter 控件里的一个原生占位视图。通道 `flutter_cylplaceholder/CYLPlaceholderView/<id>` 承载来自 Dart 的 "update"
 *      （名称与值，由 `CYLPlaceholderBridge.updatePlaceholderView` 应用）以及回传的 "onTap"。容器的 accessibilityIdentifier 为
 *      `cyl.native.placeholder`，便于在界面树里区分原生视图与 Dart 回退。
 */
final class CYLPlaceholderPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private let placeholder: CYLPlaceholderView?

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, params: [String: Any]) {
        channel = FlutterMethodChannel(name: "\(CYLPlaceholderPlatformViewFactory.viewType)/\(viewId)", binaryMessenger: messenger)
        container = UIView(frame: frame)
        var item = params
        item["tappable"] = nil
        // [EN] The native view carries the identifier of its container, so a UI dump tells it from the Dart fallback.
        // [CN] 原生视图带有容器的标识符，便于在界面树里区分原生视图与 Dart 回退。
        if item["CYLPlaceholderItemAccessibilityIdentifier"] == nil { item["CYLPlaceholderItemAccessibilityIdentifier"] = "cyl.native.placeholder" }
        placeholder = CYLPlaceholderBridge.placeholderView(params: item)
        super.init()
        if let view = placeholder {
            view.frame = container.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            container.addSubview(view)
            if params["tappable"] as? Bool == true {
                container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
            }
        }
        channel.setMethodCallHandler { [weak self] call, result in self?.handle(call, result: result) }
    }

    func view() -> UIView { container }

    @objc private func tapped() {
        channel.invokeMethod("onTap", arguments: nil)
    }

    private func handle(_ call: FlutterMethodCall, result: FlutterResult) {
        guard call.method == "update" else { return result(FlutterMethodNotImplemented) }
        guard let view = placeholder else {
            return result(FlutterError(code: "no_view", message: "The item map was not valid.", details: nil))
        }
        guard let arguments = call.arguments as? [String: Any], let name = arguments["name"] as? String else {
            return result(FlutterError(code: "bad_arguments", message: "update needs a name.", details: nil))
        }
        if CYLPlaceholderBridge.updatePlaceholderView(view, name: name, value: arguments["value"]) {
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    deinit {
        channel.setMethodCallHandler(nil)
    }
}
