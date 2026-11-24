import React
import UIKit

/**
 * [EN] The React Native native module "CYLPlaceholderHUD" (declared in `CYLPlaceholderReactBridge.m`): `call(method, arguments)`
 *      runs a `CYLPlaceholderHUDBridge` method on the main thread over the foreground window's topmost view controller; a tapped
 *      button of `showComponents` comes back as the event "CYLPlaceholderHUDAction" (the action name). Same module name, method
 *      and event as Android's `CYLPlaceholderHUDModule`.
 * [CN] React Native 原生模块 “CYLPlaceholderHUD”（声明在 `CYLPlaceholderReactBridge.m`）：`call(method, arguments)` 在主线程、
 *      前台窗口最顶层视图控制器之上运行 `CYLPlaceholderHUDBridge` 的方法；`showComponents` 的按钮被点按后以事件
 *      “CYLPlaceholderHUDAction”（动作名）回传。模块名、方法与事件均与 Android 的 `CYLPlaceholderHUDModule` 相同。
 */
@objc(CYLPlaceholderHUDModule)
final class CYLPlaceholderHUDModule: RCTEventEmitter {
    /// The event of a tapped HUD button.
    static let actionEvent = "CYLPlaceholderHUDAction"

    // The controller is created and used on the main thread only. The action closure holds the module weakly: no retain cycle.
    private lazy var controller = CYLPlaceholderHUDController(container: CYLPlaceholderHUDController.foregroundContainer) { [weak self] name in
        self?.sendEvent(withName: CYLPlaceholderHUDModule.actionEvent, body: name)
    }

    override static func requiresMainQueueSetup() -> Bool { false }

    override func supportedEvents() -> [String]! {
        [CYLPlaceholderHUDModule.actionEvent]
    }

    // [EN] Runs a HUD method by name; the TypeScript wrapper `CYLPlaceholderHUD` is the typed API over it. [CN] 按名称运行 HUD 方法；TypeScript 封装 `CYLPlaceholderHUD` 是其上的带类型 API。
    @objc(call:arguments:)
    func call(_ method: String, arguments: [String: Any]?) {
        DispatchQueue.main.async { [weak self] in
            self?.controller.handle(method: method, arguments: arguments)
        }
    }
}
