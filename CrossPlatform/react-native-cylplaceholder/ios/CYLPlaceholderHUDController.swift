import UIKit
#if canImport(React)
import CYLTableViewPlaceHolder
#endif

/**
 * [EN] Drives one `CYLPlaceholderHUDBridge` over a host view, from method names and argument dictionaries, the way the React
 *      Native module "CYLPlaceholderHUD" receives them (Android's `CYLPlaceholderHUDController`). Kept apart from the module so
 *      the unit tests cover it without a React Native runtime. The HUD is rebuilt when the host view changes (another window
 *      or a presented view controller), and the old one is dismissed.
 * [CN] 以方法名与参数字典驱动宿主视图上的一个 `CYLPlaceholderHUDBridge`，与 React Native 模块 “CYLPlaceholderHUD” 的接收方式一致
 *      （对应 Android 的 `CYLPlaceholderHUDController`）。与模块分开，使单元测试无需 React Native 运行时。宿主视图变化
 *      （另一个窗口或被呈现的视图控制器）时重建 HUD，并关闭旧的。
 */
@objc(CYLPlaceholderHUDController)
public final class CYLPlaceholderHUDController: NSObject {
    private let container: () -> UIView?
    private let onAction: (String) -> Void
    private var bridge: CYLPlaceholderHUDBridge?
    private weak var bridgeContainer: UIView?

    /**
     * [EN] A controller whose HUD lays itself over the view `container` returns now; `onAction` receives the name of every
     *      tapped HUD button.
     * [CN] HUD 覆盖在 `container` 当下返回的视图上；`onAction` 接收每个被点按的 HUD 按钮动作名。
     */
    public init(container: @escaping () -> UIView?, onAction: @escaping (String) -> Void) {
        self.container = container
        self.onAction = onAction
    }

    /**
     * [EN] The HUD that is driven now, nil before the first call.
     * [CN] 当前被驱动的 HUD；第一次调用之前为 nil。
     */
    public var hud: CYLPlaceholderHUD? { bridge?.hud }

    /**
     * [EN] Runs `method` on the HUD of the current host view (a new HUD when the view changed). False when there is no host view
     *      or the method or its arguments are not known (the names of `CYLPlaceholderHUDBridge.handle(method:arguments:)`).
     * [CN] 在当前宿主视图的 HUD 上运行 `method`（视图变化时使用新的 HUD）。没有宿主视图，或方法、参数未知时返回 false
     *      （方法名见 `CYLPlaceholderHUDBridge.handle(method:arguments:)`）。
     */
    @discardableResult
    public func handle(method: String, arguments: [String: Any]?) -> Bool {
        guard let host = container() else { return false }
        if bridge == nil || bridgeContainer !== host {
            bridge?.hud.dismiss()
            bridge = CYLPlaceholderHUDBridge(container: host, onAction: onAction)
            bridgeContainer = host
        }
        return bridge?.handle(method: method, arguments: arguments) ?? false
    }

    /**
     * [EN] The view the HUD covers in an app: the topmost presented view controller's view of the foreground window's root view
     *      controller (the key window of the active scene, else the first window), nil when there is no window yet.
     * [CN] 应用中 HUD 所覆盖的视图：前台窗口根视图控制器上最顶层被呈现的视图控制器的视图（活动场景的主窗口，否则第一个窗口）；
     *      还没有窗口时为 nil。
     */
    public static func foregroundContainer() -> UIView? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let windows = (scenes.filter { $0.activationState == .foregroundActive } + scenes).flatMap { $0.windows }
        guard let window = windows.first(where: { $0.isKeyWindow }) ?? windows.first else { return nil }
        var controller = window.rootViewController
        while let presented = controller?.presentedViewController, !presented.isBeingDismissed { controller = presented }
        return controller?.view
    }
}
