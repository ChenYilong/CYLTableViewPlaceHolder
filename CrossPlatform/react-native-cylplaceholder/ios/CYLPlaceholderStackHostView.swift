import UIKit
// [EN] The pod imports the core as a module; the unit tests compile this file into the core's own module (there is no React
//      Native there), where the import would be circular.
// [CN] pod 以模块方式导入核心；单元测试把本文件编译进核心自己的模块（那里没有 React Native），此时导入会循环。
#if canImport(React)
import CYLTableViewPlaceHolder
#endif

/**
 * [EN] The host view of the native `CYLPlaceholderStackView` in React Native ("CYLPlaceholderStack"), the iOS side of Android's
 *      `CYLPlaceholderStackHostView`. It owns one stack, built through `CYLPlaceholderBridge.stackView` from the configuration
 *      dictionary (the `components` of `docs/Placeholder-Scenarios.md`, or a `scenario` name when there are none) and
 *      `backgroundAction`; `onAction` receives `["action": name]` for every tapped button or background action, the name as
 *      JavaScript gave it. It has no React import, so the unit tests build it without a React Native runtime.
 * [CN] React Native 中原生 `CYLPlaceholderStackView` 的宿主视图（“CYLPlaceholderStack”），Android `CYLPlaceholderStackHostView` 的
 *      iOS 一侧。它持有一个由 `CYLPlaceholderBridge.stackView` 创建的堆叠视图，配置来自 `components`（见
 *      `docs/Placeholder-Scenarios.md`；没有时用 `scenario` 名称）与 `backgroundAction`；每次按钮或背景动作被点按，`onAction`
 *      收到 `["action": name]`，name 即 JavaScript 给出的名称。本文件不导入 React，单元测试无需 React Native 运行时。
 */
@objc(CYLPlaceholderStackHostView)
public final class CYLPlaceholderStackHostView: UIView {
    /**
     * [EN] Called with `["action": name]` when a button, an icon or the background of the stack is tapped (`RCTDirectEventBlock`).
     * [CN] 点按堆叠视图的按钮、图标或背景时以 `["action": name]` 调用（即 `RCTDirectEventBlock`）。
     */
    @objc public var onAction: (([AnyHashable: Any]) -> Void)?

    /**
     * [EN] The component dictionaries (the `components` prop); the stack is rebuilt at the next layout.
     * [CN] 组件字典（`components` 属性）；堆叠视图在下一次布局时重建。
     */
    @objc public var components: [Any]? {
        didSet { markDirty() }
    }

    /**
     * [EN] The scenario name (the `scenario` prop), used when there are no components.
     * [CN] 场景名称（`scenario` 属性），没有组件时使用。
     */
    @objc public var scenario: String? {
        didSet { markDirty() }
    }

    /**
     * [EN] The action name of a tap on the background (the `backgroundAction` prop).
     * [CN] 点按背景的动作名（`backgroundAction` 属性）。
     */
    @objc public var backgroundAction: String? {
        didSet { markDirty() }
    }

    /**
     * [EN] The `restartToken` prop: a value above the last one plays every animation again from the start. The first value is
     *      the baseline (nothing restarts at creation, while no stack exists yet); a lower or equal value does nothing.
     * [CN] `restartToken` 属性：大于上一个值时，所有动画从头重播。第一个值只是基线（创建时还没有堆叠视图，不重播）；
     *      更小或相等的值什么也不做。
     */
    @objc public var restartToken: Int = 0 {
        didSet {
            if restartToken > oldValue && stack != nil { restartAnimation() }
        }
    }

    /**
     * [EN] The stack that is shown now, nil when the configuration was empty or invalid or has not been applied yet.
     * [CN] 当前显示的堆叠视图；配置为空、无效或尚未应用时为 nil。
     */
    @objc public private(set) var stack: CYLPlaceholderStackView?

    /**
     * [EN] How many times the animations were restarted (the command and the `restartToken` rule), for the tests and for logs.
     * [CN] 动画被重播的次数（命令与 `restartToken` 规则），供测试与日志使用。
     */
    @objc public private(set) var restartCount = 0

    private var dirty = false

    private func markDirty() {
        dirty = true
        setNeedsLayout()
    }

    /**
     * [EN] Plays every animation of the stack again from the start (the `restartAnimation` command).
     * [CN] 让堆叠视图的所有动画从头重播（`restartAnimation` 命令）。
     */
    @objc public func restartAnimation() {
        guard let stack = stack else { return }
        restartCount += 1
        CYLPlaceholderBridge.updateStackView(stack, name: "restartAnimation", value: nil)
    }

    /**
     * [EN] Rebuilds the stack when a configuration prop changed since the last call (layout calls it after each update batch).
     *      Returns whether a native stack is shown.
     * [CN] 自上次调用以来配置属性有变化时重建堆叠视图（布局在每批更新后调用）。返回是否显示原生堆叠视图。
     */
    @discardableResult
    @objc public func applyPendingConfiguration() -> Bool {
        if !dirty { return stack != nil }
        dirty = false
        stack?.removeFromSuperview()
        stack = nil
        var configuration: [String: Any] = [:]
        if let components = components, !components.isEmpty {
            configuration["components"] = components
        } else if let scenario = scenario, !scenario.isEmpty {
            configuration["scenario"] = scenario
        }
        if let action = backgroundAction, !action.isEmpty { configuration["backgroundAction"] = action }
        if configuration.isEmpty { return false }
        // [EN] The identifier tells the native stack from the TypeScript fallback in a UI dump (the Flutter plugin uses the same one).
        // [CN] 该标识符便于在界面树里区分原生堆叠视图与 TypeScript 回退（Flutter 插件使用同一个）。
        configuration["accessibilityIdentifier"] = "cyl.native.placeholderStack"
        guard let built = CYLPlaceholderBridge.stackView(configuration: configuration, onAction: { [weak self] name in
            self?.onAction?(["action": name])
        }) else { return false }
        built.frame = bounds
        built.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(built)
        stack = built
        return true
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        applyPendingConfiguration()
        stack?.frame = bounds
    }
}
