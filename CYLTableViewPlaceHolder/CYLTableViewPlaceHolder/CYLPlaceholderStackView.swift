//
//  CYLPlaceholderStackView.swift
//  CYLTableViewPlaceHolder
//
//  [EN] Swift since 2026-11-19 with the same Objective-C API (see `CYLPlaceholderStackView.h`); the action handler block
//       type stays in the header. It reads the internal members `kind` and `applyConfiguration(_:)` of
//       `CYLPlaceholderComponent` (`CYLPlaceholderScenario.swift`).
//  [CN] 自 2026-11-19 起用 Swift 编写，Objective-C API 不变（见 `CYLPlaceholderStackView.h`）；动作处理的 block 类型保留在头文件中。它读取
//       `CYLPlaceholderComponent` 的内部成员 `kind` 与 `applyConfiguration(_:)`（`CYLPlaceholderScenario.swift`）。
//

import UIKit
// [EN] The CYLAnimatedItem pod and framework; an older Carthage build compiled the component into CYLTabBarController.
// [CN] CYLAnimatedItem pod 与 framework；较早的 Carthage 构建把该组件编译进 CYLTabBarController。
#if canImport(CYLAnimatedItem)
import CYLAnimatedItem
#elseif canImport(CYLTabBarController)
import CYLTabBarController
#endif

// [EN] Side margin between the view and its components. [CN] 视图与组件之间的两侧边距。
private let CYLPlaceholderStackMargin: CGFloat = 16

// [EN] `CYLPlaceholderActionHandler` as the Objective-C block it is (Swift imports the typedef as a closure).
// [CN] `CYLPlaceholderActionHandler` 的 Objective-C block 形式（Swift 把该 typedef 导入为闭包）。
private typealias CYLPlaceholderActionBlock = @convention(block) (CYLPlaceholderStackView, CYLPlaceholderAction) -> Void

private func CYLStackConfigurationError(_ description: String) -> NSError {
    NSError(domain: CYLPlaceholderConfigurationErrorDomain,
            code: CYLPlaceholderConfigurationError.Code.stackView.rawValue,
            userInfo: [NSLocalizedDescriptionKey: description])
}

/**
 * [EN] An empty-state view that stacks icon-and-title components (CYLPlaceholderView) vertically (see
 *      `CYLPlaceholderStackView.h`). The first component is reserved: the classic icon and title. Taps on components
 *      perform actions whose handlers are given when the view is created. Objective-C code imports the umbrella header.
 * [CN] 竖向堆叠图标加标题组件（CYLPlaceholderView）的空状态视图（见 `CYLPlaceholderStackView.h`）。第一个组件是保留组件，即经典的图标加
 *      标题。点击组件会执行动作，动作的处理在创建时指定。Objective-C 代码请导入总头文件。
 */
@objc(CYLPlaceholderStackView)
open class CYLPlaceholderStackView: UIView {

    // [EN] CYLTabBarController's CYLAnimatedItemStackView (CYLPlaceholderItemStackView), every element a CYLAnimatedItemView
    //      (each component is a CYLPlaceholderView): it lays the components out (centered vertical stack, side margins,
    //      spacing before each component, titles wrapped to the width), groups them for VoiceOver, and runs the background
    //      action, passing through every component whose own tap would not run. Item taps stay with the components
    //      (`tapHandler`, `tapInteractionEnabled`; `dispatchesItemTaps` is NO).
    // [CN] CYLTabBarController 的 CYLAnimatedItemStackView（CYLPlaceholderItemStackView），每个元素都是 CYLAnimatedItemView（每个组件是
    //      CYLPlaceholderView）：负责组件布局（居中的竖直堆叠、两侧边距、组件前的间距、标题按宽度换行）、为 VoiceOver 分组，并执行背景动作，
    //      穿过所有自己的点击不会执行的组件。条目点击仍由组件自己处理（`tapHandler`、`tapInteractionEnabled`；`dispatchesItemTaps` 为 NO）。
    private let itemStack = CYLPlaceholderItemStackView(frame: .zero)
    private var componentViewList = [CYLPlaceholderView]()
    // [EN] Parallel to `componentViewList`: each component's action, or nil. [CN] 与 `componentViewList` 对应：每个组件的动作或 nil。
    private var componentActions = [CYLPlaceholderAction?]()
    // [EN] Each component view's kind ("item", "hint", "button", "separator"), for `hintLabel` and `button`.
    // [CN] 每个组件视图的种类，供 `hintLabel` 与 `button` 使用。
    private var componentKinds: NSMapTable<CYLPlaceholderView, NSString>?
    private var handlers = [CYLPlaceholderAction: CYLPlaceholderActionHandler]()

    /**
     * [EN] The scenario the view was created from; `CYLPlaceholderScenarioCount` when it was created from components.
     * [CN] 创建视图所用的场景；由组件创建时为 `CYLPlaceholderScenarioCount`。
     */
    @objc public private(set) var scenario: CYLPlaceholderScenario = .count

    // MARK: - Creating

    /**
     * [EN] Custom components; the first is the reserved one (a default icon and title when the array is empty or the
     *      first component's attributes are invalid).
     * [CN] 自定义组件；第一个是保留组件（数组为空或第一个组件的属性无效时为默认的图标和标题）。
     */
    @nonobjc
    public init(components: [CYLPlaceholderComponent], actions: [CYLPlaceholderAction: CYLPlaceholderActionHandler]?) {
        super.init(frame: .zero)
        handlers = actions ?? [:]
        itemStack.contentMargin = CYLPlaceholderStackMargin
        itemStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(itemStack)
        NSLayoutConstraint.activate([
            itemStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            itemStack.topAnchor.constraint(equalTo: topAnchor),
            itemStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        // [EN] VoiceOver reads the components together, top to bottom, before what is behind the placeholder.
        // [CN] VoiceOver 自上而下连续朗读这些组件，再朗读占位视图后面的内容。
        shouldGroupAccessibilityChildren = true

        for component in components {
            let view = append(component)
            if view == nil && componentViewList.isEmpty {
                // [EN] The reserved component must exist: fall back to the default icon and title.
                // [CN] 保留组件必须存在：回退为默认的图标和标题。
                append(CYLPlaceholderView(frame: .zero), action: nil, spacingBefore: 0)
            }
        }
        if componentViewList.isEmpty {
            append(CYLPlaceholderView(frame: .zero), action: nil, spacingBefore: 0)
        }
    }

    /**
     * [EN] The scenario's components, with handlers for its actions (for example `CYLPlaceholderActionRetry` and
     *      `CYLPlaceholderActionContactSupport`). An action without a handler does nothing.
     * [CN] 场景的组件，以及其动作的处理（例如 `CYLPlaceholderActionRetry` 与 `CYLPlaceholderActionContactSupport`）。没有处理的动作什么也不做。
     */
    @nonobjc
    public convenience init(scenario: CYLPlaceholderScenario, actions: [CYLPlaceholderAction: CYLPlaceholderActionHandler]?) {
        self.init(components: CYLPlaceholderScenarioCatalog.components(for: scenario), actions: actions)
        self.scenario = scenario
        backgroundAction = CYLPlaceholderScenarioCatalog.backgroundAction(for: scenario)
        accessibilityIdentifier = "CYLPlaceholderScenario\(scenario.rawValue)"
    }

    /**
     * [EN] A placeholder from a configuration dictionary (JSON or property list), as described in
     *      docs/Placeholder-Scenarios.md: "scenario", "components", "overrides" and "backgroundAction" (an action name, or
     *      "" for none). Handlers come from `actions`, keyed by action. Throws when the configuration is invalid.
     * [CN] 根据配置字典（JSON 或属性列表）创建占位视图，见 docs/Placeholder-Scenarios.md："scenario"、"components"、"overrides" 与
     *      "backgroundAction"（动作名，"" 表示无）。处理来自 `actions`，以动作为键。配置无效时抛出错误。
     */
    @nonobjc
    public convenience init(configuration: [String: Any], actions: [CYLPlaceholderAction: CYLPlaceholderActionHandler]?) throws {
        var scenario = CYLPlaceholderScenario.count
        if let scenarioName = configuration["scenario"] {
            if let name = scenarioName as? String { scenario = CYLPlaceholderScenarioCatalog.scenario(named: name) }
            if scenario == .count { throw CYLStackConfigurationError("Unknown scenario \(scenarioName).") }
        }
        var components = [CYLPlaceholderComponent]()
        if let componentList = configuration["components"] {
            guard let list = componentList as? [Any], !list.isEmpty else {
                throw CYLStackConfigurationError("\"components\" must be a non-empty array.")
            }
            for item in list {
                guard let dictionary = item as? [String: Any] else {
                    // [EN] The error `+componentWithDictionary:error:` gives for anything but a dictionary.
                    // [CN] 与 `+componentWithDictionary:error:` 对非字典给出的错误相同。
                    throw NSError(domain: CYLPlaceholderConfigurationErrorDomain,
                                  code: CYLPlaceholderConfigurationError.Code.component.rawValue,
                                  userInfo: [NSLocalizedDescriptionKey: "A component must be a dictionary."])
                }
                components.append(try CYLPlaceholderComponent(dictionary: dictionary))
            }
        } else if scenario != .count {
            for component in CYLPlaceholderScenarioCatalog.components(for: scenario) {
                components.append(component.copy() as! CYLPlaceholderComponent)
            }
        } else {
            throw CYLStackConfigurationError("The configuration needs a \"scenario\" or \"components\".")
        }
        let overrides = configuration["overrides"]
        if let overrides = overrides, !(overrides is [Any]) {
            throw CYLStackConfigurationError("\"overrides\" must be an array.")
        }
        for override in (overrides as? [Any]) ?? [] {
            let fields = override as? [String: Any]
            guard let index = (fields?["index"] as? NSNumber)?.intValue, var fields = fields,
                  index >= 0, index < components.count else {
                throw CYLStackConfigurationError("Each override needs the \"index\" of an existing component.")
            }
            fields.removeValue(forKey: "index")
            try components[index].applyConfiguration(fields)
        }
        let background = configuration["backgroundAction"]
        if let background = background, !(background is String) {
            throw CYLStackConfigurationError("\"backgroundAction\" must be an action name.")
        }
        self.init(components: components, actions: actions)
        self.scenario = scenario
        if let background = background as? String {
            backgroundAction = background.isEmpty ? nil : CYLPlaceholderScenarioCatalog.action(named: background)
        } else if scenario != .count {
            backgroundAction = CYLPlaceholderScenarioCatalog.backgroundAction(for: scenario)
        }
        if let identifier = configuration["accessibilityIdentifier"] as? String { accessibilityIdentifier = identifier }
    }

    /**
     * [EN] The configuration in a local ".json" or ".plist" file. [CN] 本地 ".json" 或 ".plist" 文件中的配置。
     */
    @nonobjc
    public convenience init(contentsOf url: URL, actions: [CYLPlaceholderAction: CYLPlaceholderActionHandler]?) throws {
        guard url.isFileURL else { throw CYLStackConfigurationError("The configuration URL must be a local file.") }
        let data = try Data(contentsOf: url)
        let object: Any = url.pathExtension.lowercased() == "json" ?
            try JSONSerialization.jsonObject(with: data, options: []) :
            try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        guard let configuration = object as? [String: Any] else {
            throw CYLStackConfigurationError("The configuration must be a dictionary.")
        }
        try self.init(configuration: configuration, actions: actions)
    }

    // MARK: - Creating from Objective-C

    /**
     * [EN] Objective-C: `-initWithComponents:actions:`, the actions an `NSDictionary` of actions to blocks. Swift cannot
     *      represent a dictionary of blocks in an Objective-C signature, so each block is converted here.
     * [CN] Objective-C：`-initWithComponents:actions:`，actions 是动作到 block 的 `NSDictionary`。Swift 无法在 Objective-C 签名中表示
     *      block 字典，因此在这里逐个转换 block。
     */
    @objc(initWithComponents:actions:)
    @available(swift, obsoleted: 1, message: "Use init(components:actions:)")
    public convenience init(objcComponents components: [CYLPlaceholderComponent], actions: NSDictionary?) {
        self.init(components: components, actions: CYLPlaceholderStackView.handlers(from: actions))
    }

    /**
     * [EN] Objective-C: `-initWithScenario:actions:`. [CN] Objective-C：`-initWithScenario:actions:`。
     */
    @objc(initWithScenario:actions:)
    @available(swift, obsoleted: 1, message: "Use init(scenario:actions:)")
    public convenience init(objcScenario scenario: CYLPlaceholderScenario, actions: NSDictionary?) {
        self.init(scenario: scenario, actions: CYLPlaceholderStackView.handlers(from: actions))
    }

    /**
     * [EN] Objective-C: `-initWithConfiguration:actions:error:`. [CN] Objective-C：`-initWithConfiguration:actions:error:`。
     */
    @objc(initWithConfiguration:actions:error:)
    @available(swift, obsoleted: 1, message: "Use init(configuration:actions:)")
    public convenience init(objcConfiguration configuration: Any, actions: NSDictionary?) throws {
        // [EN] Any object, as the Objective-C initializer took: anything but a dictionary is a configuration error, not a
        //      crash in the Swift bridge. [CN] 与原 Objective-C 初始化方法一样接受任意对象：不是字典时返回配置错误，而不是在 Swift 桥接时崩溃。
        guard let dictionary = configuration as? [String: Any] else {
            throw CYLStackConfigurationError("The configuration must be a dictionary.")
        }
        try self.init(configuration: dictionary, actions: CYLPlaceholderStackView.handlers(from: actions))
    }

    /**
     * [EN] Objective-C: `-initWithContentsOfURL:actions:error:`. [CN] Objective-C：`-initWithContentsOfURL:actions:error:`。
     */
    @objc(initWithContentsOfURL:actions:error:)
    @available(swift, obsoleted: 1, message: "Use init(contentsOf:actions:)")
    public convenience init(objcContentsOf url: URL, actions: NSDictionary?) throws {
        try self.init(contentsOf: url, actions: CYLPlaceholderStackView.handlers(from: actions))
    }

    // [EN] The blocks of an Objective-C actions dictionary, keyed by action (also used by CYLPlaceholderHUD).
    // [CN] Objective-C 动作字典中的 block，以动作为键（CYLPlaceholderHUD 也使用）。
    static func handlers(from actions: NSDictionary?) -> [CYLPlaceholderAction: CYLPlaceholderActionHandler]? {
        guard let actions = actions else { return nil }
        var handlers = [CYLPlaceholderAction: CYLPlaceholderActionHandler]()
        for (key, value) in actions {
            guard let action = key as? String else { continue }
            // [EN] The value is an Objective-C block: read it as one, then use it as a Swift closure.
            // [CN] 值是 Objective-C block：先按 block 读取，再作为 Swift 闭包使用。
            let block = unsafeBitCast(value as AnyObject, to: CYLPlaceholderActionBlock.self)
            handlers[CYLPlaceholderAction(rawValue: action)] = { placeholder, action in block(placeholder, action) }
        }
        return handlers
    }

    /**
     * [EN] Not available: use `init(components:actions:)`. [CN] 不可用：请使用 `init(components:actions:)`。
     */
    @available(*, unavailable)
    public override convenience init(frame: CGRect) {
        self.init(components: [], actions: nil)
    }

    /**
     * [EN] Not available: the view is made in code. [CN] 不可用：只在代码中创建。
     */
    @available(*, unavailable)
    public required convenience init?(coder: NSCoder) {
        self.init(components: [], actions: nil)
    }

    // MARK: - Components

    /**
     * [EN] The vertical stack holding the components: centered, sized by its components.
     * [CN] 容纳组件的竖直堆叠视图：居中，大小由组件决定。
     */
    @objc open var stackView: UIStackView { itemStack.stackView }

    /**
     * [EN] The reserved first component: the icon and title. [CN] 保留的第一个组件：图标和标题。
     */
    @objc open var placeholderView: CYLPlaceholderView { componentViewList[0] }

    /**
     * [EN] Every component, the reserved one first. [CN] 全部组件，保留组件在最前。
     */
    @objc open var componentViews: [CYLPlaceholderView] { componentViewList }

    /**
     * [EN] Plays every component's animation again from progress 0 (the examples' "Play all"), as each component's
     *      `restartAnimation()` does.
     * [CN] 让每个组件的动画从进度 0 重新播放（示例中的“全部播放”），与各组件的 `restartAnimation()` 相同。
     */
    @objc open func restartAnimation() {
        componentViewList.forEach { $0.restartAnimation() }
    }

    /**
     * [EN] The first icon of the components (the reserved component's image view when none shows one); the same as
     *      Android's `CYLPlaceholderStackView.imageView`.
     * [CN] 组件中的第一个图标（都没有图标时为保留组件的图片视图）；与 Android 的 `CYLPlaceholderStackView.imageView` 相同。
     */
    @objc open var imageView: UIImageView {
        for view in componentViewList where view.imageView.image != nil && !view.imageView.isHidden {
            return view.imageView
        }
        return placeholderView.imageView
    }

    /**
     * [EN] The first title that is not a hint, a button or a separator (the reserved component's label when there is
     *      none); the same as Android's `titleLabel`.
     * [CN] 第一个不是提示、按钮或分隔符的标题（没有时为保留组件的标签）；与 Android 的 `titleLabel` 相同。
     */
    @objc open var titleLabel: UILabel {
        for view in componentViewList where kind(of: view) == "item" && !(view.textLabel.text ?? "").isEmpty {
            return view.textLabel
        }
        return placeholderView.textLabel
    }

    /**
     * [EN] The label of the first hint component (`hintComponentWithText:`), or nil; the same as Android's `hintLabel`.
     * [CN] 第一个提示组件（`hintComponentWithText:`）的标签，没有则为 nil；与 Android 的 `hintLabel` 相同。
     */
    @objc open var hintLabel: UILabel? {
        componentViewList.first { kind(of: $0) == "hint" }?.textLabel
    }

    /**
     * [EN] The first button component (`buttonComponentWithTitle:style:action:`), or nil; `performTap` taps it. The same
     *      as Android's `button`.
     * [CN] 第一个按钮组件（`buttonComponentWithTitle:style:action:`），没有则为 nil；`performTap` 可点击它。与 Android 的 `button` 相同。
     */
    @objc open var button: CYLPlaceholderView? {
        componentViewList.first { kind(of: $0) == "button" }
    }

    /**
     * [EN] Appends a component under the last one and returns its view; nil, with a log, when its attributes are invalid.
     * [CN] 在最后一个组件下追加组件并返回其视图；属性无效时返回 nil 并打印日志。
     */
    @objc(appendComponent:)
    @discardableResult
    open func append(_ component: CYLPlaceholderComponent) -> CYLPlaceholderView? {
        let view: CYLPlaceholderView
        do {
            view = try CYLPlaceholderView(itemAttributes: component.attributes, imageBundle: component.imageBundle)
        } catch {
            NSLog("CYLTableViewPlaceHolder: component not added: %@", error.localizedDescription)
            return nil
        }
        append(view, action: component.action, spacingBefore: component.spacingBefore)
        let kinds = componentKinds ?? NSMapTable.weakToStrongObjects()
        componentKinds = kinds
        kinds.setObject(component.kind as NSString, forKey: view)
        return view
    }

    private func kind(of view: CYLPlaceholderView) -> String {
        (componentKinds?.object(forKey: view) as String?) ?? "item"
    }

    /**
     * [EN] Appends a view the app made itself; a tap on it performs `action` when that is not nil.
     * [CN] 追加应用自己创建的视图；`action` 不为 nil 时点击它会执行该动作。
     */
    @objc(appendComponentView:action:spacingBefore:)
    open func append(_ view: CYLPlaceholderView, action: CYLPlaceholderAction?, spacingBefore: CGFloat) {
        if componentViewList.contains(where: { $0 === view }) { return }
        view.reportsContentSize = true
        view.preferredMaxLayoutWidth = componentMaxWidth
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.setContentHuggingPriority(.required, for: .vertical)
        itemStack.append(view, action: action?.rawValue, spacingBefore: spacingBefore)
        componentViewList.append(view)
        componentActions.append(action)
        if let action = action {
            // [EN] The component's own tap event performs the action; whether it runs, and whether the tap highlights,
            //      is the component's `tapInteractionEnabled` (`CYLPlaceholderItemInteractionEnabled`).
            // [CN] 由组件自己的点击事件执行动作；是否执行、点击是否高亮，取决于组件的 `tapInteractionEnabled`
            //      （`CYLPlaceholderItemInteractionEnabled`）。
            view.tapHandler = { [weak self] _ in
                self?.performAction(action)
            }
        }
        updateAccessibility(of: view)
    }

    // [EN] Decorative components (an icon or illustration with no title, label or tap event) are hidden from VoiceOver,
    //      so it reads only text and controls; every component speaks the language the core texts use.
    // [CN] 装饰性组件（没有标题、无障碍标签或点击事件的图标、插图）对 VoiceOver 隐藏，只朗读文字与控件；所有组件都使用核心文案的语言朗读。
    private func updateAccessibility(of view: CYLPlaceholderView) {
        if CYLPlaceholderLocalization.language != nil {
            view.accessibilityLanguage = CYLPlaceholderLocalization.effectiveLanguage
        }
        let speaks = !(view.textLabel.text ?? "").isEmpty && !view.textLabel.isHidden
        let labeled = !(view.accessibilityLabel ?? "").isEmpty || speaks
        let actsOnBackground = view === componentViewList.first && backgroundAction != nil
        if view.tapHandler == nil && !labeled && !actsOnBackground {
            view.isAccessibilityElement = false
            view.accessibilityElementsHidden = true
        }
    }

    /**
     * [EN] The first component whose tap performs `action`. [CN] 第一个点击会执行 `action` 的组件。
     */
    @objc(componentViewForAction:)
    open func componentView(for action: CYLPlaceholderAction) -> CYLPlaceholderView? {
        guard let index = componentActions.firstIndex(where: { $0 == action }) else { return nil }
        return componentViewList[index]
    }

    // MARK: - Actions

    /**
     * [EN] Sets or, with nil, removes the handler of an action. [CN] 设置动作的处理；传 nil 时移除。
     */
    @objc(setHandler:forAction:)
    open func setHandler(_ handler: CYLPlaceholderActionHandler?, for action: CYLPlaceholderAction) {
        handlers[action] = handler
    }

    /**
     * [EN] Runs the handler of `action`; NO when it has none. [CN] 执行 `action` 的处理；没有处理时返回 NO。
     */
    @objc(performAction:)
    @discardableResult
    open func performAction(_ action: CYLPlaceholderAction) -> Bool {
        guard let handler = handlers[action] else { return false }
        handler(self, action)
        return true
    }

    /**
     * [EN] The action of a tap anywhere outside a tappable component; nil turns that off. Set from the scenario.
     * [CN] 点击可点击组件以外任意位置时执行的动作；nil 表示关闭。由场景设置。
     */
    @objc open var backgroundAction: CYLPlaceholderAction? {
        get { storedBackgroundAction }
        // [EN] A computed property: a stored one's observers would not run when the initializers set it.
        // [CN] 计算属性：存储属性的观察者在初始化方法中赋值时不会执行。
        set {
            storedBackgroundAction = newValue
            applyBackgroundAction()
        }
    }

    private var storedBackgroundAction: CYLPlaceholderAction?

    private func applyBackgroundAction() {
        // [EN] The inner stack runs the background tap (passing through components whose own tap would not run) and keeps
        //      the reserved component a button; its handler performs this view's handler for the action.
        // [CN] 内部堆叠视图执行背景点击（穿过自己的点击不会执行的组件）并让保留组件保持按钮角色；其处理调用本视图对该动作的处理。
        itemStack.backgroundAction = backgroundAction?.rawValue
        if let action = backgroundAction {
            itemStack.setHandler({ [weak self] _, name in
                self?.performAction(CYLPlaceholderAction(rawValue: name))
            }, for: action.rawValue)
        }
        // [EN] VoiceOver users reach the background action through the reserved component.
        // [CN] VoiceOver 用户通过保留组件触发背景点击动作。
        guard let reserved = componentViewList.first, !reserved.isTapInteractive else { return }
        if let action = backgroundAction {
            reserved.isAccessibilityElement = true
            reserved.accessibilityElementsHidden = false
            reserved.accessibilityTraits.insert(.button)
            // [EN] An icon-only reserved component is named after the action. [CN] 只有图标的保留组件以动作名称命名。
            if (reserved.accessibilityLabel ?? "").isEmpty {
                reserved.accessibilityLabel = CYLPlaceholderScenarioCatalog.localizedTitle(for: action)
            }
        } else {
            reserved.accessibilityTraits.remove(.button)
            updateAccessibility(of: reserved)
        }
    }

    open override func accessibilityActivate() -> Bool {
        guard let action = backgroundAction else { return false }
        return performAction(action)
    }

    // MARK: - Layout

    private var componentMaxWidth: CGFloat {
        let width = bounds.width
        return width > 0 ? max(0, width - 2 * CYLPlaceholderStackMargin) : 0
    }

    open override func layoutSubviews() {
        let maxWidth = componentMaxWidth
        for view in componentViewList {
            view.preferredMaxLayoutWidth = maxWidth
        }
        super.layoutSubviews()
    }
}
