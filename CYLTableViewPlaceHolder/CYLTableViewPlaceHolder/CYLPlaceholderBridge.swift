import UIKit

/*
 * [EN] The map-driven entry points the Flutter and React Native iOS halves call, with the same names and keys as the Android
 *      `com.cyl.placeholder.bridge` (docs/Refresh-Library-Parity.md, "Native bridge map"). A host passes plain dictionaries and
 *      strings; the views and the HUD are the real ones of this module, so there is no second implementation behind the bridges.
 * [CN] Flutter 与 React Native 的 iOS 一侧调用的、以字典驱动的入口，名称与键和 Android 的 `com.cyl.placeholder.bridge` 相同
 *      （docs/Refresh-Library-Parity.md「Native bridge map」）。宿主只传普通字典和字符串；视图与 HUD 就是本模块的真实实现。
 */

/**
 * [EN] Builds and updates the placeholder views of a bridge from the item and configuration dictionaries.
 * [CN] 由条目与配置字典创建并更新桥接用的占位视图。
 */
public enum CYLPlaceholderBridge {
    /**
     * [EN] A placeholder view from an item dictionary (the `CYLPlaceholderItem*` keys of `docs/Placeholder-Scenarios.md`), or nil
     *      when it is invalid. The optional keys "animationLoops" (a boolean) and "animationSpeed" (a number above 0) are applied too.
     * [CN] 由条目字典（`docs/Placeholder-Scenarios.md` 的 `CYLPlaceholderItem*` 键）创建占位视图，字典无效时为 nil；
     *      可选键 "animationLoops"（布尔）与 "animationSpeed"（大于 0 的数）也会生效。
     */
    public static func placeholderView(params: [String: Any]) -> CYLPlaceholderView? {
        var attributes = params
        attributes["animationLoops"] = nil
        attributes["animationSpeed"] = nil
        guard let view = try? CYLPlaceholderView(itemAttributes: attributes, imageBundle: nil) else { return nil }
        if let loops = params["animationLoops"] as? Bool { view.animationLoops = loops }
        if let speed = params["animationSpeed"] as? NSNumber, speed.doubleValue.isFinite, speed.doubleValue > 0 {
            view.animationSpeed = CGFloat(speed.doubleValue)
        }
        return view
    }

    /**
     * [EN] Applies one live update to a placeholder view: "animationLoops" (a boolean), "animationSpeed" (a number above 0) or
     *      "restartAnimation" (any value, plays again from the start). Returns whether the name and the value were understood.
     * [CN] 对占位视图做一次实时更新："animationLoops"（布尔）、"animationSpeed"（大于 0 的数）或 "restartAnimation"
     *      （任意值，从头重播）。返回名称与值是否被理解。
     */
    @discardableResult
    public static func updatePlaceholderView(_ view: CYLPlaceholderView, name: String, value: Any?) -> Bool {
        switch name {
        case "animationLoops":
            guard let loops = value as? Bool else { return false }
            view.animationLoops = loops
            return true
        case "animationSpeed":
            guard let speed = value as? NSNumber, speed.doubleValue.isFinite, speed.doubleValue > 0 else { return false }
            view.animationSpeed = CGFloat(speed.doubleValue)
            return true
        case "restartAnimation":
            view.restartAnimation()
            return true
        default:
            return false
        }
    }

    /**
     * [EN] A placeholder stack from a configuration dictionary (the "scenario" or "components" of
     *      `docs/Placeholder-Scenarios.md`, whose components may carry "animationLoops" and "animationSpeed"), or nil when it is
     *      invalid. `onAction` receives the name of every button action that is tapped.
     * [CN] 由配置字典（`docs/Placeholder-Scenarios.md` 的 "scenario" 或 "components"，组件可带 "animationLoops" 与
     *      "animationSpeed"）创建占位堆叠视图，无效时为 nil；`onAction` 接收每个被点按的按钮动作名。
     */
    public static func stackView(configuration: [String: Any], onAction: @escaping (String) -> Void) -> CYLPlaceholderStackView? {
        try? CYLPlaceholderStackView(configuration: configuration, actions: actionHandlers(configuration, onAction))
    }

    /**
     * [EN] Applies one live update to a stack: "restartAnimation" plays every animation again from the start. Returns whether
     *      the name was understood.
     * [CN] 对堆叠视图做一次实时更新："restartAnimation" 让所有动画从头重播。返回名称是否被理解。
     */
    @discardableResult
    public static func updateStackView(_ view: CYLPlaceholderStackView, name: String, value: Any?) -> Bool {
        guard name == "restartAnimation" else { return false }
        view.restartAnimation()
        return true
    }

    // [EN] One handler per action name the configuration uses. [CN] 配置用到的每个动作名一个处理器。
    static func actionHandlers(_ configuration: [String: Any], _ onAction: @escaping (String) -> Void)
        -> [CYLPlaceholderAction: CYLPlaceholderActionHandler] {
        var names = Set<String>()
        for entry in (configuration["components"] as? [Any]) ?? [] {
            if let name = (entry as? [String: Any])?["action"] as? String, !name.isEmpty { names.insert(name) }
        }
        if let name = configuration["backgroundAction"] as? String, !name.isEmpty { names.insert(name) }
        var handlers: [CYLPlaceholderAction: CYLPlaceholderActionHandler] = [:]
        for name in names { handlers[CYLPlaceholderAction(rawValue: name)] = { _, _ in onAction(name) } }
        return handlers
    }
}

/**
 * [EN] Drives a `CYLPlaceholderHUD` from method names and argument dictionaries, the way a method channel or a React Native
 *      module delivers them. The HUD lays itself over `container`, the host's content view.
 * [CN] 以方法名与参数字典驱动 `CYLPlaceholderHUD`，与方法通道或 React Native 模块的传递方式一致；HUD 覆盖在宿主内容视图 `container` 上。
 */
public final class CYLPlaceholderHUDBridge {
    /**
     * [EN] The HUD that is driven.
     * [CN] 被驱动的 HUD。
     */
    public let hud: CYLPlaceholderHUD
    private let onAction: (String) -> Void

    /**
     * [EN] A bridge whose HUD lays itself over `container`; `onAction` receives the name of every button action that is tapped.
     * [CN] HUD 覆盖在 `container` 上的桥接；`onAction` 接收每个被点按的按钮动作名。
     */
    public init(container: UIView, onAction: @escaping (String) -> Void = { _ in }) {
        hud = CYLPlaceholderHUD(containerView: container)
        self.onAction = onAction
    }

    /**
     * [EN] Runs `method` with `arguments`: "show", "showWithStatus" ("status"), "showProgress" ("progress", "status"),
     *      "setStatus", "showInfoWithStatus", "showSuccessWithStatus", "showErrorWithStatus" ("status"), "showComponents"
     *      ("components": the component dictionaries of the configuration), "popActivity", "dismiss" and "dismissWithDelay"
     *      ("delay" in seconds). Returns whether the method is known.
     * [CN] 以 `arguments` 运行 `method`，方法名与参数同上；方法已知时返回 true。
     */
    @discardableResult
    public func handle(method: String, arguments: [String: Any]?) -> Bool {
        let status = arguments?["status"] as? String
        switch method {
        case "show": hud.show()
        case "showWithStatus": hud.show(status: status)
        case "showProgress":
            let progress = (arguments?["progress"] as? NSNumber)?.doubleValue ?? 0
            hud.show(progress: CGFloat(min(max(progress, 0), 1)), status: status)
        case "setStatus": hud.setStatus(status)
        case "showInfoWithStatus": hud.showInfo(status: status)
        case "showSuccessWithStatus": hud.showSuccess(status: status)
        case "showErrorWithStatus": hud.showError(status: status)
        case "showComponents":
            guard let entries = arguments?["components"] as? [Any] else { return false }
            var components: [CYLPlaceholderComponent] = []
            for entry in entries {
                guard let dictionary = entry as? [String: Any], let component = try? CYLPlaceholderComponent(dictionary: dictionary) else {
                    return false
                }
                components.append(component)
            }
            hud.show(components: components, actions: CYLPlaceholderBridge.actionHandlers(["components": entries], onAction))
        case "popActivity": hud.popActivity()
        case "dismiss": hud.dismiss()
        case "dismissWithDelay": hud.dismiss(withDelay: (arguments?["delay"] as? NSNumber)?.doubleValue ?? 0)
        default: return false
        }
        return true
    }
}
