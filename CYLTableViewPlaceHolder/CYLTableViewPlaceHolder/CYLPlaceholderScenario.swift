//
//  CYLPlaceholderScenario.swift
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  [EN] Ready-made empty-state scenarios, in Swift since 2026-11-19 with the same Objective-C API (see
//       `CYLPlaceholderScenario.h`): CYLPlaceholderComponent (one component of a CYLPlaceholderStackView) and
//       CYLPlaceholderScenarioCatalog (the components of every scenario). The enums, the CYLPlaceholderAction type and its
//       constants stay in the header and `CYLPlaceholderScenarioSupport.m`: Swift cannot declare a C symbol.
//  [CN] 现成的空状态场景，自 2026-11-19 起用 Swift 编写，Objective-C API 不变（见 `CYLPlaceholderScenario.h`）：CYLPlaceholderComponent
//       （CYLPlaceholderStackView 的一个组件）与 CYLPlaceholderScenarioCatalog（每个场景的组件）。枚举、CYLPlaceholderAction 类型及其常量
//       保留在头文件与 `CYLPlaceholderScenarioSupport.m` 中：Swift 无法声明 C 符号。
//

import UIKit

// MARK: - Look

private func CYLScenarioAccentColor() -> UIColor {
    return .systemBlue
}

private func CYLScenarioSecondaryTextColor() -> UIColor {
    return .secondaryLabel
}

private func CYLScenarioLineIconColor() -> UIColor {
    // [EN] A middle gray reads on light and dark backgrounds; Lottie takes the color once, when it is set.
    // [CN] 中灰色在浅色和深色背景上都清晰；Lottie 在设置时读取一次颜色。
    UIColor(white: 0.6, alpha: 1)
}

private func CYLScenarioFont(_ style: UIFont.TextStyle, _ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
    UIFontMetrics(forTextStyle: style).scaledFont(for: UIFont.systemFont(ofSize: size, weight: weight))
}

// [EN] The capsule button's background image: a red-to-orange gradient, drawn once.
// [CN] 胶囊按钮的背景图：红到橙的渐变，只绘制一次。
private let CYLScenarioCapsuleBackgroundImage: UIImage = {
    let size = CGSize(width: 160, height: 44)
    let start = UIColor(red: 1, green: 0.45, blue: 0.35, alpha: 1)
    let end = UIColor(red: 0.92, green: 0.2, blue: 0.27, alpha: 1)
    return UIGraphicsImageRenderer(size: size).image { context in
        let colors = [start.cgColor, end.cgColor] as CFArray
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil) else {
            return
        }
        context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: 0), options: [])
    }
}()

// MARK: - Configuration values

private func CYLScenarioConfigurationError(_ description: String) -> NSError {
    NSError(domain: CYLPlaceholderConfigurationErrorDomain,
            code: CYLPlaceholderConfigurationError.Code.component.rawValue,
            userInfo: [NSLocalizedDescriptionKey: description])
}

// [EN] The core lookup for scenario texts. [CN] 场景文案的核心查找。
private func CYLScenarioText(_ key: String, _ fallback: String?) -> String {
    CYLPlaceholderLocalizedStringForKey(key, fallback)
}

// [EN] A text from a configuration: the core localization of `keyName` when given, else the literal `literalName`.
// [CN] 配置中的文字：给出 `keyName` 时取其核心本地化文字，否则取字面值 `literalName`。
private func CYLScenarioConfiguredText(_ dictionary: [String: Any], _ literalName: String, _ keyName: String) -> String? {
    let literal = dictionary[literalName] as? String
    if let key = dictionary[keyName] as? String, !key.isEmpty { return CYLScenarioText(key, literal) }
    return literal
}

// [EN] A style from a number or a name such as "WifiOff" or "CYLPlaceholderWifiOff" (any case).
// [CN] 从数字或名称（如 "WifiOff"、"CYLPlaceholderWifiOff"，不区分大小写）得到样式。
private func CYLScenarioStyle(from value: Any) -> CYLPlaceholderStyle? {
    let count = CYLPlaceholderStyle.count.rawValue
    if let number = value as? NSNumber {
        let integer = number.intValue
        if integer < 0 || integer >= count || number.doubleValue != Double(integer) { return nil }
        return CYLPlaceholderStyle(rawValue: integer)
    }
    guard var name = (value as? String)?.lowercased(), !name.isEmpty else { return nil }
    if !name.hasPrefix("cylplaceholder") { name = "cylplaceholder" + name }
    for candidate in 0..<count {
        guard let style = CYLPlaceholderStyle(rawValue: candidate) else { continue }
        if CYLPlaceholderView.imageName(for: style)?.lowercased() == name { return style }
    }
    return nil
}

private func CYLScenarioSize(from value: Any) -> CGSize? {
    let width: Double
    let height: Double
    if let number = value as? NSNumber {
        width = number.doubleValue
        height = width
    } else if let list = value as? [Any], list.count == 2,
              let first = list.first as? NSNumber, let last = list.last as? NSNumber {
        width = first.doubleValue
        height = last.doubleValue
    } else {
        return nil
    }
    if !width.isFinite || !height.isFinite || width <= 0 || height <= 0 || width > 1000 || height > 1000 { return nil }
    return CGSize(width: width, height: height)
}

// [EN] The index of a value in `names` (any case), for the string options of a configuration; nil when it is not one.
// [CN] 配置中字符串选项的取值在 `names` 中的下标（不区分大小写）；不是其中之一时为 nil。
private func CYLScenarioIndex(of value: Any, in names: [String]) -> Int? {
    guard let name = value as? String else { return nil }
    return names.firstIndex(of: name.lowercased())
}

private let CYLScenarioHighlightStyleNames = ["dim", "shrink", "none"]

// MARK: - Bundled animations

// [EN] Options some bundled Rive files need to play (the same as the aggregate demo used before).
// [CN] 部分内置 Rive 文件播放所需的选项（与之前的汇总示例相同）。
private let CYLScenarioAnimationOptions: [String: [String: String]] = [
    "CYLPlaceholderLoading.riv": ["legacy": "1"],
    "CYLPlaceholderPullToRefresh.riv": ["legacy": "1"],
    "CYLPlaceholderSuccess.riv": ["stateMachine": "State Machine 1"],
    // [EN] The "refresh" artboard of rive-flutter's web_icons_pack.riv, playing its "active" (turning) animation.
    // [CN] rive-flutter web_icons_pack.riv 中的 "refresh" 画板，播放其 "active"（旋转）动画。
    "CYLRefreshIcon.riv": ["legacy": "1", "artboard": "refresh", "animation": "active"],
]

// [EN] Whether a bundled animation is a spinner (loading, progress, activity…), which loops by default so a loading
//      indicator never freezes; every other animation plays once and rests on its last frame. The same list as the
//      examples' `loopsByDefault` (iOS, Android, HarmonyOS).
// [CN] 内置动画是否为加载类动画（加载、进度、活动指示……）：默认循环，加载指示不会停住；其他动画默认播放一次并停在最后一帧。
//      与各端示例的 `loopsByDefault` 名单相同。
private func CYLScenarioAnimationLoopsByDefault(_ fileName: String) -> Bool {
    let words = ["Loading", "Spinner", "Progress", "Throbber", "Activity", "Ring", "Dots", "Cycle", "Arc", "Clockwise",
                 "Uploading", "Infinity"]
    return words.contains { fileName.contains($0) }
}

// [EN] The black line icons from useAnimations (NOTICE.animations), tinted so they read on any background.
// [CN] 来自 useAnimations 的黑色线条图标（NOTICE.animations），着色后在任何背景上都清晰。
private let CYLScenarioLineIcons: Set<String> = [
    "CYLPlaceholderNoInternet.json", "CYLPlaceholderLoadFailed.json", "CYLPlaceholderServerError.json",
    "CYLPlaceholderRefresh.json", "CYLPlaceholderNoResults.json", "CYLPlaceholderNoPermission.json",
    "CYLPlaceholderContactSupport.json", "CYLPlaceholderNoMessages.json",
    "CYLPlaceholderNoNotifications.json", "CYLPlaceholderSad.json", "CYLPlaceholderCloudOff.json",
    "CYLPlaceholderTapHint.json", "CYLPlaceholderSettings.json",
    "CYLPlaceholderLocationPermission.json", "CYLPlaceholderCameraPermission.json",
    "CYLPlaceholderPhotoLibraryPermission.json", "CYLPlaceholderMicrophonePermission.json",
    "CYLPlaceholderContactsPermission.json", "CYLPlaceholderCalendarPermission.json",
    "CYLPlaceholderBluetoothPermission.json", "CYLPlaceholderNotificationPermission.json",
    "CYLRefreshSpinnerRing.json", "CYLRefreshArc.json", "CYLRefreshClockwise.json",
    "CYLRefreshCounterClockwise.json", "CYLRefreshPullCircle.json", "CYLRefreshMoreDots.json",
    "CYLRefreshDoneCircle.json", "CYLRefreshPullArrow.json", "CYLRefreshLoadMore.json", "CYLRefreshCycle.json",
    "CYLRefreshDone.json", "CYLPlaceholderNoOrders.json",
]

// MARK: - Component

// [EN] Line icons are drawn smaller than illustrations. [CN] 线条图标比插图小。
private let CYLScenarioIconSide: CGFloat = 96
private let CYLScenarioIllustrationSide: CGFloat = 160

/**
 * [EN] One component of a placeholder: the item attributes of a CYLPlaceholderView (an icon, a title or both, see
 *      `CYLPlaceholderView(itemAttributes:imageBundle:)`) and the action a tap on it performs.
 * [CN] 占位图的一个组件：CYLPlaceholderView 的条目属性（图标、标题或两者，见 `CYLPlaceholderView(itemAttributes:imageBundle:)`）及点击它时
 *      执行的动作。
 */
@objc(CYLPlaceholderComponent)
open class CYLPlaceholderComponent: NSObject, NSCopying {

    // [EN] What a factory makes, before the component exists: a factory of a subclass then makes an instance of it.
    // [CN] 工厂方法在组件创建之前得到的内容：子类调用工厂方法时据此创建子类实例。
    private struct Parts {
        var attributes: [String: Any]
        var action: CYLPlaceholderAction?
        var spacingBefore: CGFloat = 16
        var kind = "item"
    }

    /**
     * [EN] The item attributes of the component's CYLPlaceholderView. [CN] 组件的 CYLPlaceholderView 的条目属性。
     */
    @objc public private(set) var attributes: [String: Any]

    /**
     * [EN] nil: the component is not tappable. [CN] nil 表示组件不可点击。
     */
    @objc public private(set) var action: CYLPlaceholderAction?

    /**
     * [EN] Images named in `attributes` are looked up here; nil uses the library's bundle.
     * [CN] `attributes` 中按名称引用的图片在这里查找；nil 使用本库的 bundle。
     */
    @objc public var imageBundle: Bundle?

    /**
     * [EN] Space above the component, from the one before it. Ignored for the first component.
     * [CN] 组件与上一个组件之间的间距。第一个组件忽略此值。
     */
    @objc public var spacingBefore: CGFloat

    /**
     * [EN] Whether the still image replaces the icon animation when a play-once animation ends
     *      (`CYLAnimatedItemView.showsImageWhenAnimationEnds`); off by default, so the last frame stays. For an animation
     *      whose last frame is empty: the Success scenario's icon turns it on, so its still image shows afterwards.
     * [CN] 播放一次的图标动画结束后，是否用静态图替换动画（`CYLAnimatedItemView.showsImageWhenAnimationEnds`）；默认关闭，停在最后一帧。
     *      用于最后一帧为空的动画：Success 场景的图标开启它，结束后显示静态图。
     */
    @objc public var showsImageWhenAnimationEnds = false

    // [EN] "item", "hint", "button" or "separator": which factory made it (CYLPlaceholderStackView reads it for its
    //      `hintLabel`, `titleLabel` and `button`, as Android's component kinds).
    // [CN] 由哪个工厂方法创建（CYLPlaceholderStackView 据此提供 `hintLabel`、`titleLabel` 与 `button`，同 Android 的组件种类）。
    var kind: String

    /**
     * [EN] A component with these item attributes; a tap performs `action` (nil: not tappable).
     * [CN] 使用这些条目属性的组件；点击时执行 `action`（nil 表示不可点击）。
     */
    @nonobjc
    public required init(attributes: [String: Any], action: CYLPlaceholderAction?) {
        self.attributes = attributes
        self.action = action
        spacingBefore = 16
        kind = "item"
        super.init()
    }

    // [EN] Takes the spacing and the kind a factory chose. [CN] 采用工厂方法选定的间距与种类。
    private func adopt(_ parts: Parts) -> Self {
        spacingBefore = parts.spacingBefore
        kind = parts.kind
        return self
    }

    /**
     * [EN] Objective-C: `+componentWithAttributes:action:`. [CN] Objective-C：`+componentWithAttributes:action:`。
     */
    @objc(componentWithAttributes:action:)
    @available(swift, obsoleted: 1, message: "Use init(attributes:action:)")
    public class func objcComponent(attributes: [String: Any], action: CYLPlaceholderAction?) -> Self {
        self.init(attributes: attributes, action: action)
    }

    /**
     * [EN] A copy with the same attributes, action, image bundle, spacing and kind.
     * [CN] 属性、动作、图片 bundle、间距与种类都相同的副本。
     */
    open func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(attributes: attributes, action: action)
        copy.imageBundle = imageBundle
        copy.spacingBefore = spacingBefore
        copy.kind = kind
        copy.showsImageWhenAnimationEnds = showsImageWhenAnimationEnds
        return copy
    }

    private func setAttribute(_ value: Any, forKey key: String) {
        attributes[key] = value
    }

    /**
     * [EN] Whether a tap performs `action` and highlights the component (`CYLPlaceholderItemInteractionEnabled` in
     *      `attributes`). Defaults to true. false keeps the component visible but inert, as a disabled button.
     * [CN] 点击是否执行 `action` 并高亮组件（`attributes` 中的 `CYLPlaceholderItemInteractionEnabled`）。默认 true。false 时组件可见但
     *      不响应，如同禁用的按钮。
     */
    @objc public var interactionEnabled: Bool {
        get { (attributes[CYLPlaceholderItemInteractionEnabled] as? NSNumber)?.boolValue ?? true }
        set { setAttribute(NSNumber(value: newValue), forKey: CYLPlaceholderItemInteractionEnabled) }
    }

    /**
     * [EN] The pressed look (`CYLPlaceholderItemTapHighlightStyle`). Defaults to Dim.
     * [CN] 按下时的效果（`CYLPlaceholderItemTapHighlightStyle`）。默认 Dim。
     */
    @objc public var tapHighlightStyle: CYLPlaceholderTapHighlightStyle {
        get {
            let value = attributes[CYLPlaceholderItemTapHighlightStyle]
            if let name = value as? String {
                let index = CYLScenarioIndex(of: name, in: CYLScenarioHighlightStyleNames)
                return index.flatMap { CYLPlaceholderTapHighlightStyle(rawValue: $0) } ?? .dim
            }
            if let number = value as? NSNumber { return CYLPlaceholderTapHighlightStyle(rawValue: number.intValue) ?? .dim }
            return .dim
        }
        set { setAttribute(NSNumber(value: newValue.rawValue), forKey: CYLPlaceholderItemTapHighlightStyle) }
    }

    /**
     * [EN] How many times the icon animation plays each time it starts (`CYLPlaceholderItemAnimationRepeatCount`): 0 loops.
     *      Defaults to 1 (play once and rest on the last frame); components made by
     *      `init(bundledAnimation:fallbackStyle:title:size:action:)` with a spinner (a file named Loading, Progress,
     *      Activity, Spinner, Uploading…) loop (0).
     * [CN] 每次开始时图标动画播放的次数（`CYLPlaceholderItemAnimationRepeatCount`）：0 表示循环。默认 1（播放一次并停在最后一帧）；
     *      `init(bundledAnimation:fallbackStyle:title:size:action:)` 用加载类文件（Loading、Progress、Activity、Spinner、Uploading 等）
     *      创建的组件循环播放（0）。
     */
    @objc public var animationRepeatCount: Int {
        get {
            let value = attributes[CYLPlaceholderItemAnimationRepeatCount]
            if let name = value as? String { return name.lowercased() == "loop" ? 0 : 1 }
            return (value as? NSNumber)?.intValue ?? 1
        }
        set { setAttribute(NSNumber(value: max(0, newValue)), forKey: CYLPlaceholderItemAnimationRepeatCount) }
    }

    /**
     * [EN] Whether the icon animation loops: the same as `animationRepeatCount` 0 (true) or 1 (false), the name
     *      CYLTabBarController's `CYLAnimatedItemView` uses.
     * [CN] 图标动画是否循环：等同于 `animationRepeatCount` 为 0（true）或 1（false），名称与 CYLTabBarController 的
     *      `CYLAnimatedItemView` 一致。
     */
    @objc public var animationLoops: Bool {
        get { animationRepeatCount == 0 }
        set { animationRepeatCount = newValue ? 0 : 1 }
    }

    /**
     * [EN] The icon animation's playback speed, 1 by default: the `animationSpeed` entry of the animation options
     *      (`CYLPlaceholderItemAnimationOptions`), which the item view applies. A value that is not a positive number is
     *      ignored.
     * [CN] 图标动画的播放速度，默认 1：动画选项（`CYLPlaceholderItemAnimationOptions`）中的 `animationSpeed` 项，由 item 视图应用。
     *      不是正数的值会被忽略。
     */
    @objc public var animationSpeed: CGFloat {
        get {
            let options = attributes[CYLPlaceholderItemAnimationOptions] as? NSDictionary
            let value = options?["animationSpeed"]
            let speed = (value as? NSNumber)?.doubleValue ?? (value as? NSString)?.doubleValue ?? .nan
            return speed.isFinite && speed > 0 ? CGFloat(speed) : 1
        }
        set {
            guard newValue.isFinite, newValue > 0 else { return }
            let options = (attributes[CYLPlaceholderItemAnimationOptions] as? NSDictionary)?.mutableCopy() as? NSMutableDictionary
                ?? NSMutableDictionary()
            options["animationSpeed"] = NSNumber(value: Double(newValue))
            setAttribute(options, forKey: CYLPlaceholderItemAnimationOptions)
        }
    }

    // MARK: Configuration

    /**
     * [EN] A component from a configuration dictionary (JSON or property list), as described in
     *      docs/Placeholder-Scenarios.md: "type" is "icon", "hint", "button", "separator" or "item" (raw item attributes);
     *      "title"/"text" with an optional core localization key "titleKey"/"textKey"; "animation" (a bundled file name),
     *      "style" (a CYLPlaceholderStyle name or number), "size", "buttonStyle" ("filled", "outlined", "capsule"),
     *      "action", "interactionEnabled", "highlightStyle" ("dim", "shrink", "none"), "repeatCount" (0 or "loop", N,
     *      "once"), "spacingBefore" and "accessibilityIdentifier". Throws for an invalid dictionary.
     * [CN] 根据配置字典（JSON 或属性列表）创建组件，见 docs/Placeholder-Scenarios.md。字典无效时抛出错误。
     */
    @nonobjc
    public convenience init(dictionary: [String: Any]) throws {
        let parts = try CYLPlaceholderComponent.dictionaryParts(dictionary)
        self.init(attributes: parts.attributes, action: parts.action)
        _ = adopt(parts)
        try applyConfiguration(dictionary)
    }

    /**
     * [EN] Objective-C: `+componentWithDictionary:error:`. It takes any object, as the Objective-C method did, so that
     *      a configuration that is not a dictionary returns the configuration error instead of failing in the Swift bridge.
     * [CN] Objective-C：`+componentWithDictionary:error:`。与原 Objective-C 方法一样接受任意对象，配置不是字典时返回配置错误，
     *      而不是在 Swift 桥接时崩溃。
     */
    @objc(componentWithDictionary:error:)
    @available(swift, obsoleted: 1, message: "Use init(dictionary:)")
    public class func objcComponent(dictionary: Any) throws -> Self {
        guard let dictionary = dictionary as? [String: Any] else {
            throw CYLScenarioConfigurationError("A component must be a dictionary.")
        }
        let parts = try dictionaryParts(dictionary)
        let component = self.init(attributes: parts.attributes, action: parts.action).adopt(parts)
        try component.applyConfiguration(dictionary)
        return component
    }

    // [EN] What `init(dictionary:)` makes, by "type". [CN] `init(dictionary:)` 按 "type" 创建的内容。
    private static func dictionaryParts(_ dictionary: [String: Any]) throws -> Parts {
        let type = (dictionary["type"] as? String) ?? "icon"
        let title = CYLScenarioConfiguredText(dictionary, "title", "titleKey") ??
            CYLScenarioConfiguredText(dictionary, "text", "textKey")
        var action: CYLPlaceholderAction?
        if dictionary["action"] != nil {
            guard let name = dictionary["action"] as? String, !name.isEmpty else {
                throw CYLScenarioConfigurationError("A component action must be a non-empty string.")
            }
            action = CYLPlaceholderScenarioCatalog.action(named: name)
        }
        let parts: Parts
        switch type {
        case "icon":
            var style = CYLPlaceholderStyle.empty
            if let value = dictionary["style"] {
                guard let parsed = CYLScenarioStyle(from: value) else {
                    throw CYLScenarioConfigurationError("Unknown placeholder style.")
                }
                style = parsed
            }
            var size = CGSize(width: CYLScenarioIconSide, height: CYLScenarioIconSide)
            if let value = dictionary["size"] {
                guard let parsed = CYLScenarioSize(from: value) else {
                    throw CYLScenarioConfigurationError("A component size must be [width, height] or a number.")
                }
                size = parsed
            }
            let animation = dictionary["animation"] as? String
            if let animation = animation, CYLPlaceholderView.path(forBundledAnimation: animation) == nil {
                throw CYLScenarioConfigurationError("Bundled animation \(animation) was not found.")
            }
            parts = CYLPlaceholderComponent.bundledAnimationParts(animation, fallbackStyle: style, title: title, size: size,
                                                                  action: action)
        case "hint":
            parts = CYLPlaceholderComponent.hintParts(title ?? "")
        case "button":
            var buttonStyle = CYLPlaceholderButtonStyle.filled
            if let value = dictionary["buttonStyle"] {
                guard let index = CYLScenarioIndex(of: value, in: ["filled", "outlined", "capsule"]),
                      let parsed = CYLPlaceholderButtonStyle(rawValue: index) else {
                    throw CYLScenarioConfigurationError("A button style must be filled, outlined or capsule.")
                }
                buttonStyle = parsed
            }
            guard let buttonAction = action else { throw CYLScenarioConfigurationError("A button needs an action.") }
            let buttonTitle = title ?? CYLPlaceholderScenarioCatalog.localizedTitle(for: buttonAction) ?? ""
            parts = CYLPlaceholderComponent.buttonParts(buttonTitle, style: buttonStyle, action: buttonAction)
        case "separator":
            parts = CYLPlaceholderComponent.separatorParts(title ?? CYLScenarioText("CYLPlaceholderScenarioOrSeparator", "or"))
        case "item":
            guard var resolved = dictionary["attributes"] as? [String: Any] else {
                throw CYLScenarioConfigurationError("An item component needs an \"attributes\" dictionary.")
            }
            if let title = title { resolved[CYLPlaceholderItemTitle] = title }
            parts = Parts(attributes: resolved, action: action)
        default:
            throw CYLScenarioConfigurationError("Unknown component type \(type).")
        }
        return parts
    }

    // [EN] The fields every component accepts, also used for a scenario's "overrides" (CYLPlaceholderStackView).
    // [CN] 每个组件都接受的字段，也用于场景的 "overrides"（CYLPlaceholderStackView）。
    func applyConfiguration(_ dictionary: [String: Any]) throws {
        if let interaction = dictionary["interactionEnabled"] {
            guard let number = interaction as? NSNumber else {
                throw CYLScenarioConfigurationError("interactionEnabled must be a boolean.")
            }
            interactionEnabled = number.boolValue
        }
        if let highlight = dictionary["highlightStyle"] {
            guard let index = CYLScenarioIndex(of: highlight, in: CYLScenarioHighlightStyleNames),
                  let style = CYLPlaceholderTapHighlightStyle(rawValue: index) else {
                throw CYLScenarioConfigurationError("highlightStyle must be dim, shrink or none.")
            }
            tapHighlightStyle = style
        }
        if let repeatValue = dictionary["repeatCount"] {
            var count = -1
            if let name = repeatValue as? String {
                let lowercase = name.lowercased()
                count = lowercase == "loop" ? 0 : (lowercase == "once" ? 1 : -1)
            } else if let number = repeatValue as? NSNumber, number.doubleValue == number.doubleValue.rounded(.down) {
                count = number.intValue
            }
            if count < 0 || count > 10000 {
                throw CYLScenarioConfigurationError("repeatCount must be 0 (loop) or more, \"loop\" or \"once\".")
            }
            animationRepeatCount = count
        }
        if let loops = dictionary["animationLoops"] {
            guard let number = loops as? NSNumber else {
                throw CYLScenarioConfigurationError("animationLoops must be a boolean.")
            }
            animationLoops = number.boolValue
        }
        if let speed = dictionary["animationSpeed"] {
            guard let number = speed as? NSNumber, number.doubleValue.isFinite, number.doubleValue > 0 else {
                throw CYLScenarioConfigurationError("animationSpeed must be a number above 0.")
            }
            animationSpeed = CGFloat(number.doubleValue)
        }
        if let spacing = dictionary["spacingBefore"] {
            guard let number = spacing as? NSNumber, number.doubleValue.isFinite, number.doubleValue >= 0 else {
                throw CYLScenarioConfigurationError("spacingBefore must be a number of points.")
            }
            spacingBefore = CGFloat(number.doubleValue)
        }
        if let identifier = dictionary["accessibilityIdentifier"] {
            guard let string = identifier as? String else {
                throw CYLScenarioConfigurationError("accessibilityIdentifier must be a string.")
            }
            setAttribute(string, forKey: CYLPlaceholderItemAccessibilityIdentifier)
        }
        if dictionary["action"] != nil && dictionary["type"] == nil {
            if let name = dictionary["action"] as? String, !name.isEmpty {
                action = CYLPlaceholderScenarioCatalog.action(named: name)
            } else {
                action = nil
            }
        }
    }

    // MARK: Factories

    /**
     * [EN] An icon (a bundled animation, see `CYLPlaceholderView.bundledAnimationFileNames`, with a static style shown
     *      before it plays or when its engine is not installed) and an optional title.
     * [CN] 一个图标（内置动画，见 `CYLPlaceholderView.bundledAnimationFileNames`；播放前或未安装动画引擎时显示静态样式）与可选的标题。
     */
    @nonobjc
    public convenience init(bundledAnimation fileName: String?, fallbackStyle: CYLPlaceholderStyle, title: String?,
                            size: CGSize, action: CYLPlaceholderAction?) {
        let parts = CYLPlaceholderComponent.bundledAnimationParts(fileName, fallbackStyle: fallbackStyle, title: title,
                                                                  size: size, action: action)
        self.init(attributes: parts.attributes, action: parts.action)
        _ = adopt(parts)
    }

    /**
     * [EN] Objective-C: `+componentWithBundledAnimation:fallbackStyle:title:size:action:`.
     * [CN] Objective-C：`+componentWithBundledAnimation:fallbackStyle:title:size:action:`。
     */
    @objc(componentWithBundledAnimation:fallbackStyle:title:size:action:)
    @available(swift, obsoleted: 1, message: "Use init(bundledAnimation:fallbackStyle:title:size:action:)")
    public class func objcComponent(bundledAnimation fileName: String?, fallbackStyle: CYLPlaceholderStyle,
                                    title: String?, size: CGSize, action: CYLPlaceholderAction?) -> Self {
        let parts = bundledAnimationParts(fileName, fallbackStyle: fallbackStyle, title: title, size: size, action: action)
        return self.init(attributes: parts.attributes, action: parts.action).adopt(parts)
    }

    private static func bundledAnimationParts(_ fileName: String?, fallbackStyle: CYLPlaceholderStyle, title: String?,
                                              size: CGSize, action: CYLPlaceholderAction?) -> Parts {
        var attributes = [String: Any]()
        attributes[CYLPlaceholderItemStyle] = NSNumber(value: fallbackStyle.rawValue)
        if let fileName = fileName, let path = CYLPlaceholderView.path(forBundledAnimation: fileName) {
            attributes[CYLPlaceholderItemAnimationFilePath] = path
            attributes[CYLPlaceholderItemAnimationSize] = [NSNumber(value: Double(size.width)),
                                                           NSNumber(value: Double(size.height))]
            // [EN] Played once by default (owner, 2026-11-19), spinners loop; set `animationRepeatCount` to change it.
            // [CN] 默认播放一次（2026-11-19 维护者决定），加载类动画循环；可通过 `animationRepeatCount` 修改。
            attributes[CYLPlaceholderItemAnimationRepeatCount] = NSNumber(value: CYLScenarioAnimationLoopsByDefault(fileName) ? 0 : 1)
            if let options = CYLScenarioAnimationOptions[fileName] { attributes[CYLPlaceholderItemAnimationOptions] = options }
            if CYLScenarioLineIcons.contains(fileName) {
                attributes[CYLPlaceholderItemAnimationColors] = ["**.Color": CYLScenarioLineIconColor()]
            }
        } else if let fileName = fileName {
            NSLog("CYLTableViewPlaceHolder: bundled animation %@ not found; showing the static style.", fileName)
        }
        if let title = title, !title.isEmpty {
            attributes[CYLPlaceholderItemTitle] = title
        } else if let action = action, let name = CYLPlaceholderScenarioCatalog.localizedTitle(for: action) {
            // [EN] An icon-only button still needs a spoken name. [CN] 只有图标的按钮也需要可朗读的名称。
            attributes[CYLPlaceholderItemAccessibilityLabel] = name
        }
        return Parts(attributes: attributes, action: action)
    }

    /**
     * [EN] A secondary line of text under the title. [CN] 标题下方的次要文字。
     */
    @objc(hintComponentWithText:)
    public class func hint(text: String) -> Self {
        let parts = hintParts(text)
        return self.init(attributes: parts.attributes, action: parts.action).adopt(parts)
    }

    private static func hintParts(_ text: String) -> Parts {
        Parts(attributes: [
            CYLPlaceholderItemTitle: text,
            CYLPlaceholderItemTitleColor: CYLScenarioSecondaryTextColor(),
            CYLPlaceholderItemTitleFont: UIFont.preferredFont(forTextStyle: .footnote),
        ], action: nil, spacingBefore: 4, kind: "hint")
    }

    /**
     * [EN] A text of its own, `fontSize` points large and `color` colored (0 and nil for the default title look); the same
     *      as Android's `CYLPlaceholderComponent.text(title, sizeSp, color)`. The size follows Dynamic Type.
     * [CN] 一段独立的文字，字号 `fontSize`、颜色 `color`（0 与 nil 表示默认标题样式）；与 Android 的
     *      `CYLPlaceholderComponent.text(title, sizeSp, color)` 相同。字号随动态字体缩放。
     */
    @objc(textComponentWithText:fontSize:color:)
    public class func text(_ text: String, fontSize: CGFloat, color: UIColor?) -> Self {
        var attributes: [String: Any] = [CYLPlaceholderItemTitle: text]
        if fontSize > 0 && fontSize.isFinite {
            // [EN] A point size that still follows Dynamic Type. [CN] 指定字号，仍随动态字体缩放。
            attributes[CYLPlaceholderItemTitleFont] = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: fontSize))
        }
        if let color = color { attributes[CYLPlaceholderItemTitleColor] = color }
        return self.init(attributes: attributes, action: nil)
    }

    /**
     * [EN] A title drawn as a button. [CN] 绘制成按钮的标题。
     */
    @objc(buttonComponentWithTitle:style:action:)
    public class func button(title: String, style: CYLPlaceholderButtonStyle, action: CYLPlaceholderAction) -> Self {
        let parts = buttonParts(title, style: style, action: action)
        return self.init(attributes: parts.attributes, action: parts.action).adopt(parts)
    }

    private static func buttonParts(_ title: String, style: CYLPlaceholderButtonStyle, action: CYLPlaceholderAction) -> Parts {
        var attributes = [String: Any]()
        attributes[CYLPlaceholderItemTitle] = title
        attributes[CYLPlaceholderItemTitleFont] = CYLScenarioFont(.body, 16, .semibold)
        switch style {
        case .outlined:
            attributes[CYLPlaceholderItemTitleColor] = CYLScenarioAccentColor()
            attributes[CYLPlaceholderItemTitleBorderColor] = CYLScenarioAccentColor()
            attributes[CYLPlaceholderItemTitleBorderWidth] = NSNumber(value: 1)
            attributes[CYLPlaceholderItemTitleCornerRadius] = NSNumber(value: 6)
            attributes[CYLPlaceholderItemTitleContentInsets] = [8, 22, 8, 22].map { NSNumber(value: $0) }
            attributes[CYLPlaceholderItemTitleMinimumWidth] = NSNumber(value: 128)
        case .capsule:
            attributes[CYLPlaceholderItemTitleColor] = UIColor.white
            attributes[CYLPlaceholderItemTitleBackgroundImage] = CYLScenarioCapsuleBackgroundImage
            attributes[CYLPlaceholderItemTitleCornerRadius] = NSNumber(value: 999)
            attributes[CYLPlaceholderItemTitleContentInsets] = [10, 30, 10, 30].map { NSNumber(value: $0) }
            attributes[CYLPlaceholderItemTitleMinimumWidth] = NSNumber(value: 140)
        default:
            attributes[CYLPlaceholderItemTitleColor] = UIColor.white
            attributes[CYLPlaceholderItemTitleBackgroundColor] = CYLScenarioAccentColor()
            attributes[CYLPlaceholderItemTitleCornerRadius] = NSNumber(value: 6)
            attributes[CYLPlaceholderItemTitleContentInsets] = [11, 24, 11, 24].map { NSNumber(value: $0) }
            attributes[CYLPlaceholderItemTitleMinimumWidth] = NSNumber(value: 200)
        }
        return Parts(attributes: attributes, action: action, spacingBefore: 20, kind: "button")
    }

    /**
     * [EN] A title showing a separator, such as "——  or  ——". [CN] 显示分隔符的标题，如 "——  或  ——"。
     */
    @objc(separatorComponentWithText:)
    public class func separator(text: String) -> Self {
        let parts = separatorParts(text)
        return self.init(attributes: parts.attributes, action: parts.action).adopt(parts)
    }

    private static func separatorParts(_ text: String) -> Parts {
        Parts(attributes: [
            CYLPlaceholderItemTitle: "———   \(text)   ———",
            // [EN] VoiceOver reads the word ("or"), not the dashes. [CN] VoiceOver 只朗读文字（如“或”），不朗读横线。
            CYLPlaceholderItemAccessibilityLabel: text,
            CYLPlaceholderItemTitleColor: CYLScenarioSecondaryTextColor(),
            CYLPlaceholderItemTitleFont: UIFont.preferredFont(forTextStyle: .footnote),
        ], action: nil, spacingBefore: 14, kind: "separator")
    }
}

// MARK: - Catalog

private func CYLScenarioIcon(_ fileName: String, _ style: CYLPlaceholderStyle, _ title: String?,
                             _ side: CGFloat) -> CYLPlaceholderComponent {
    CYLPlaceholderComponent(bundledAnimation: fileName, fallbackStyle: style, title: title,
                            size: CGSize(width: side, height: side), action: nil)
}

private func CYLScenarioButton(_ action: CYLPlaceholderAction, _ style: CYLPlaceholderButtonStyle) -> CYLPlaceholderComponent {
    CYLPlaceholderComponent.button(title: CYLPlaceholderScenarioCatalog.localizedTitle(for: action) ?? "", style: style,
                                   action: action)
}

private func CYLScenarioHint(_ key: String, _ fallback: String) -> CYLPlaceholderComponent {
    CYLPlaceholderComponent.hint(text: CYLScenarioText(key, fallback))
}

// [EN] Each scenario's name key and English fallback, in declaration order.
// [CN] 每个场景的名称键与英文默认值，按声明顺序。
private let CYLScenarioNameEntries: [(key: String, fallback: String)] = [
    ("CYLPlaceholderScenarioNetworkUnavailableName", "Network unavailable"),
    ("CYLPlaceholderScenarioNoContentName", "No content"),
    ("CYLPlaceholderScenarioTapToReloadName", "Tap to reload"),
    ("CYLPlaceholderScenarioLoadFailedWithHintName", "Load failed with a hint"),
    ("CYLPlaceholderScenarioTapToReconnectName", "Tap to reconnect"),
    ("CYLPlaceholderScenarioRetryButtonName", "Retry button"),
    ("CYLPlaceholderScenarioRetryOutlinedButtonName", "Outlined retry button"),
    ("CYLPlaceholderScenarioRetryWithHintName", "Hint and reload button"),
    ("CYLPlaceholderScenarioRetryOrContactSupportName", "Retry or contact support"),
    ("CYLPlaceholderScenarioIllustrationRetryName", "Illustration and capsule button"),
    ("CYLPlaceholderScenarioRefreshIconName", "Refresh icon"),
    ("CYLPlaceholderScenarioTitleAboveIllustrationName", "Title above the illustration"),
    ("CYLPlaceholderScenarioTextOnlyName", "Text only"),
    ("CYLPlaceholderScenarioTapMeRetryName", "Tap me and reload"),
    ("CYLPlaceholderScenarioLocationPermissionDeniedName", "Location permission denied"),
    ("CYLPlaceholderScenarioNoSearchResultsName", "No search results"),
    ("CYLPlaceholderScenarioEmptyCartName", "Empty cart"),
    ("CYLPlaceholderScenarioNoOrdersName", "No orders"),
    ("CYLPlaceholderScenarioNoFavoritesName", "No favorites"),
    ("CYLPlaceholderScenarioNoMessagesName", "No messages"),
    ("CYLPlaceholderScenarioNoNotificationsName", "No notifications"),
    ("CYLPlaceholderScenarioNoPermissionName", "No permission"),
    ("CYLPlaceholderScenarioCameraPermissionDeniedName", "Camera permission denied"),
    ("CYLPlaceholderScenarioPhotoLibraryPermissionDeniedName", "Photo permission denied"),
    ("CYLPlaceholderScenarioMicrophonePermissionDeniedName", "Microphone permission denied"),
    ("CYLPlaceholderScenarioContactsPermissionDeniedName", "Contacts permission denied"),
    ("CYLPlaceholderScenarioCalendarPermissionDeniedName", "Calendar permission denied"),
    ("CYLPlaceholderScenarioBluetoothPermissionDeniedName", "Bluetooth permission denied"),
    ("CYLPlaceholderScenarioNotificationPermissionDeniedName", "Notification permission denied"),
    ("CYLPlaceholderScenarioServerErrorName", "Server error"),
    ("CYLPlaceholderScenarioSyncFailedName", "Sync failed"),
    ("CYLPlaceholderScenarioLoadingName", "Loading"),
    ("CYLPlaceholderScenarioUploadingName", "Uploading"),
    ("CYLPlaceholderScenarioSuccessName", "Success"),
    ("CYLPlaceholderScenarioHUDName", "HUD"),
]

// [EN] Each action's title key and English fallback. [CN] 每个动作的标题键与英文默认值。
private let CYLScenarioActionTitles: [CYLPlaceholderAction: (key: String, fallback: String)] = [
    .retry: ("CYLPlaceholderActionRetryTitle", "Retry"),
    .contactSupport: ("CYLPlaceholderActionContactSupportTitle", "Contact support"),
    .openSettings: ("CYLPlaceholderActionOpenSettingsTitle", "Open Settings"),
    .goShopping: ("CYLPlaceholderActionGoShoppingTitle", "Go shopping"),
    .done: ("CYLPlaceholderActionDoneTitle", "Done"),
    .chooseManually: ("CYLPlaceholderActionChooseManuallyTitle", "Choose manually"),
]

// [EN] The other bundled animations that fit a scenario, after its own icon. [CN] 场景自身图标之外其他合适的内置动画。
private let CYLScenarioAnimationVariants: [CYLPlaceholderScenario: [String]] = [
    .noContent: ["CYLPlaceholderNoDrafts.json"],
    .tapToReload: ["CYLPlaceholderPullToRefresh.riv"],
    .retryOrContactSupport: ["CYLPlaceholderContactSupport.json"],
    .refreshIcon: ["CYLPlaceholderRefresh.json", "CYLPlaceholderPullToRefresh.riv"],
    .titleAboveIllustration: ["CYLPlaceholderPullToRefresh.riv"],
    .tapMeRetry: ["CYLPlaceholderNoInternet.json"],
    .locationPermissionDenied: ["CYLPlaceholderLocation.json"],
    .noFavorites: ["CYLPlaceholderNoFavorites.gif", "CYLPlaceholderNoFavorites.json"],
    .noPermission: ["CYLPlaceholderSettings.json"],
    .syncFailed: ["CYLPlaceholderLoadingInfinity.json"],
    .loading: ["CYLPlaceholderLoading.pag", "CYLPlaceholderLoading.riv", "CYLPlaceholderLoadingInfinity.json",
               "CYLPlaceholderProgress.pag"],
    .uploading: ["CYLPlaceholderProgress.pag"],
    .success: ["CYLPlaceholderSuccess.json", "CYLPlaceholderCelebrate.json"],
    // [EN] The refresh animations that suit a loading HUD, in every format. [CN] 适合加载 HUD 的刷新动画，覆盖所有格式。
    .hud: ["CYLRefreshMaterialSpinner.json", "CYLRefreshGradientSpinner.json", "CYLRefreshRing.gif",
           "CYLPlaceholderProgress.pag", "CYLRefreshIcon.riv"],
]

// [EN] Every permission scenario, indexed by CYLPlaceholderPermission (None maps to the generic NoPermission).
// [CN] 所有权限场景，以 CYLPlaceholderPermission 为下标（None 对应通用的 NoPermission）。
private let CYLScenarioPermissionScenarios: [CYLPlaceholderScenario] = [
    .noPermission,
    .locationPermissionDenied,
    .cameraPermissionDenied,
    .photoLibraryPermissionDenied,
    .microphonePermissionDenied,
    .contactsPermissionDenied,
    .calendarPermissionDenied,
    .bluetoothPermissionDenied,
    .notificationPermissionDenied,
]

// [EN] A permission scenario: the permission's icon and title, a hint saying what is missing and that it is not a
//      network problem, then "Open Settings".
// [CN] 权限场景：权限的图标与标题、说明缺少什么且不是网络问题的提示，然后是“打开设置”。
private func CYLScenarioPermissionComponents(_ name: String, _ fileName: String, _ style: CYLPlaceholderStyle,
                                             _ title: String, _ hint: String) -> [CYLPlaceholderComponent] {
    let prefix = "CYLPlaceholderScenario\(name)PermissionDenied"
    return [CYLScenarioIcon(fileName, style, CYLScenarioText(prefix + "Title", title), CYLScenarioIconSide),
            CYLScenarioHint(prefix + "Hint", hint),
            CYLScenarioButton(.openSettings, .filled)]
}

/**
 * [EN] The definition of every scenario. Texts are read in `CYLPlaceholderLocalization.effectiveLanguage` when called.
 * [CN] 所有场景的定义。文案在调用时按 `CYLPlaceholderLocalization.effectiveLanguage` 读取。
 */
@objc(CYLPlaceholderScenarioCatalog)
public final class CYLPlaceholderScenarioCatalog: NSObject {

    // [EN] Not created: every member is a class member. [CN] 不创建实例：所有成员都是类成员。
    private override init() {
        super.init()
    }

    /**
     * [EN] Every scenario, in declaration order, as NSNumber values of CYLPlaceholderScenario.
     * [CN] 按声明顺序排列的所有场景，以 CYLPlaceholderScenario 的 NSNumber 值表示。
     */
    @objc public class var allScenarios: [NSNumber] {
        (0..<CYLPlaceholderScenario.count.rawValue).map { NSNumber(value: $0) }
    }

    /**
     * [EN] The localized title of an action, such as "Retry"; nil for an action the library does not define.
     * [CN] 动作的本地化标题，如“重试”；本库未定义的动作返回 nil。
     */
    @objc(localizedTitleForAction:)
    public class func localizedTitle(for action: CYLPlaceholderAction) -> String? {
        guard let text = CYLScenarioActionTitles[action] else { return nil }
        return CYLScenarioText(text.key, text.fallback)
    }

    /**
     * [EN] A short localized name for lists. [CN] 用于列表的简短本地化名称。
     */
    @objc(localizedNameForScenario:)
    public class func localizedName(for scenario: CYLPlaceholderScenario) -> String {
        guard CYLScenarioNameEntries.indices.contains(scenario.rawValue) else { return "" }
        let entry = CYLScenarioNameEntries[scenario.rawValue]
        return CYLScenarioText(entry.key, entry.fallback)
    }

    /**
     * [EN] The scenario's name in configuration files, such as "RetryOrContactSupport".
     * [CN] 场景在配置文件中的名称，如 "RetryOrContactSupport"。
     */
    @objc(nameForScenario:)
    public class func name(for scenario: CYLPlaceholderScenario) -> String {
        guard CYLScenarioNameEntries.indices.contains(scenario.rawValue) else { return "" }
        // [EN] "CYLPlaceholderScenarioRetryButtonName" -> "RetryButton". [CN] 去掉前缀与 "Name" 后缀。
        let key = CYLScenarioNameEntries[scenario.rawValue].key
        return String(key.dropFirst("CYLPlaceholderScenario".count).dropLast(4))
    }

    /**
     * [EN] The scenario with this name ("RetryOrContactSupport", "retryOrContactSupport" or
     *      "CYLPlaceholderScenarioRetryOrContactSupport"); CYLPlaceholderScenarioCount when there is none.
     * [CN] 具有该名称的场景；没有时返回 CYLPlaceholderScenarioCount。
     */
    @objc(scenarioNamed:)
    public class func scenario(named name: String) -> CYLPlaceholderScenario {
        guard !name.isEmpty else { return .count }
        var lowercase = name.lowercased()
        if lowercase.hasPrefix("cylplaceholderscenario") { lowercase = String(lowercase.dropFirst(22)) }
        for rawValue in 0..<CYLPlaceholderScenario.count.rawValue {
            guard let scenario = CYLPlaceholderScenario(rawValue: rawValue) else { continue }
            if self.name(for: scenario).lowercased() == lowercase { return scenario }
        }
        return .count
    }

    /**
     * [EN] The action for a configuration name: "retry", "contactSupport", "openSettings", "goShopping", "done",
     *      "chooseManually", or the name itself for an action the app defines.
     * [CN] 配置名称对应的动作；应用自定义的动作返回名称本身。
     */
    @objc(actionNamed:)
    public class func action(named name: String) -> CYLPlaceholderAction {
        let actions: [String: CYLPlaceholderAction] = [
            "retry": .retry,
            "contactsupport": .contactSupport,
            "opensettings": .openSettings,
            "goshopping": .goShopping,
            "done": .done,
            "choosemanually": .chooseManually,
        ]
        var lowercase = name.lowercased()
        if lowercase.hasPrefix("cylplaceholderaction") { lowercase = String(lowercase.dropFirst(20)) }
        return actions[lowercase] ?? CYLPlaceholderAction(rawValue: name)
    }

    /**
     * [EN] The README screenshot numbers (`assets/cyl-placeholder-scenario-NN-*.jpg`) the scenario reproduces; empty for
     *      the business cases.
     * [CN] 场景复现的 README 截图编号；业务场景为空。
     */
    @objc(readmeScreenshotNumbersForScenario:)
    public class func readmeScreenshotNumbers(for scenario: CYLPlaceholderScenario) -> [NSNumber] {
        let numbers: [Int]
        switch scenario {
        case .networkUnavailable: numbers = [4, 5, 6, 25, 36]
        case .noContent: numbers = [7, 9, 10]
        case .tapToReload: numbers = [13, 14, 15, 24, 26, 28, 31, 32, 37, 42, 43]
        case .loadFailedWithHint: numbers = [21, 22, 27, 29]
        case .tapToReconnect: numbers = [8]
        case .retryButton: numbers = [1, 2, 11, 19]
        case .locationPermissionDenied: numbers = [20]
        case .retryOutlinedButton: numbers = [33, 38, 39]
        case .retryWithHint: numbers = [16, 23, 40]
        case .retryOrContactSupport: numbers = [3]
        case .illustrationRetry: numbers = [18]
        case .refreshIcon: numbers = [12]
        case .titleAboveIllustration: numbers = [17]
        case .textOnly: numbers = [30, 41]
        case .tapMeRetry: numbers = [34, 35]
        default: numbers = []
        }
        return numbers.map { NSNumber(value: $0) }
    }

    /**
     * [EN] The action of a tap anywhere outside a tappable component ("tap the screen to reload"), or nil.
     * [CN] 点击可点击组件之外任意位置时执行的动作（“点击屏幕重新加载”），或 nil。
     */
    @objc(backgroundActionForScenario:)
    public class func backgroundAction(for scenario: CYLPlaceholderScenario) -> CYLPlaceholderAction? {
        switch scenario {
        case .tapToReload, .tapToReconnect, .titleAboveIllustration, .textOnly:
            return .retry
        default:
            return nil
        }
    }

    /**
     * [EN] Every bundled animation that fits the scenario, in all formats (GIF, Lottie, PAG, Rive): the scenario's own icon
     *      first, then variants. Use one as a component's "animation" in a configuration, or with
     *      `CYLPlaceholderComponent(bundledAnimation:fallbackStyle:title:size:action:)`. Empty for a scenario without an icon.
     * [CN] 适合该场景的所有内置动画（GIF、Lottie、PAG、Rive）：场景自己的图标在前，其后是变体。没有图标的场景为空。
     */
    @objc(animationFileNamesForScenario:)
    public class func animationFileNames(for scenario: CYLPlaceholderScenario) -> [String] {
        // [EN] The scenario's own icon first (the one `components(for:)` uses), then other formats that fit.
        // [CN] 第一个是场景自己的图标（`components(for:)` 使用的），其后是其他格式中合适的动画。
        var names = [String]()
        for component in components(for: scenario) {
            guard let path = component.attributes[CYLPlaceholderItemAnimationFilePath] as? String else { continue }
            let name = (path as NSString).lastPathComponent
            if !names.contains(name) { names.append(name) }
        }
        for name in CYLScenarioAnimationVariants[scenario] ?? [] {
            if !names.contains(name) && CYLPlaceholderView.path(forBundledAnimation: name) != nil { names.append(name) }
        }
        return names
    }

    /**
     * [EN] The kind of problem a scenario shows. [CN] 场景所表示的问题类型。
     */
    @objc(categoryForScenario:)
    public class func category(for scenario: CYLPlaceholderScenario) -> CYLPlaceholderScenarioCategory {
        if scenario == .noPermission || permission(for: scenario) != .none { return .permission }
        switch scenario {
        case .noContent, .noSearchResults, .emptyCart, .noOrders, .noFavorites, .noMessages, .noNotifications:
            return .empty
        case .loading, .uploading, .hud:
            return .progress
        case .success:
            return .success
        default:
            return .loadFailed
        }
    }

    /**
     * [EN] The permission a scenario is about; CYLPlaceholderPermissionNone for other scenarios and for NoPermission.
     * [CN] 场景涉及的权限；其他场景与 NoPermission 返回 CYLPlaceholderPermissionNone。
     */
    @objc(permissionForScenario:)
    public class func permission(for scenario: CYLPlaceholderScenario) -> CYLPlaceholderPermission {
        for index in CYLPlaceholderPermission.location.rawValue..<CYLScenarioPermissionScenarios.count
            where CYLScenarioPermissionScenarios[index] == scenario {
            return CYLPlaceholderPermission(rawValue: index) ?? CYLPlaceholderPermission.none
        }
        return .none
    }

    /**
     * [EN] The scenario for a missing permission: CYLPlaceholderScenarioNoPermission for CYLPlaceholderPermissionNone.
     * [CN] 缺少某权限时的场景：CYLPlaceholderPermissionNone 对应 CYLPlaceholderScenarioNoPermission。
     */
    @objc(scenarioForPermission:)
    public class func scenario(for permission: CYLPlaceholderPermission) -> CYLPlaceholderScenario {
        guard CYLScenarioPermissionScenarios.indices.contains(permission.rawValue) else { return .noPermission }
        return CYLScenarioPermissionScenarios[permission.rawValue]
    }

    /**
     * [EN] The components of a scenario, the reserved icon-and-title component first; empty for an invalid value.
     * [CN] 场景的组件，保留的图标加标题组件在前；无效值返回空数组。
     */
    @objc(componentsForScenario:)
    public class func components(for scenario: CYLPlaceholderScenario) -> [CYLPlaceholderComponent] {
        let icon = CYLScenarioIconSide
        let art = CYLScenarioIllustrationSide
        switch scenario {
        case .networkUnavailable:
            return [CYLScenarioIcon("CYLPlaceholderNoInternet.json", .wifiOff,
                CYLScenarioText("CYLPlaceholderScenarioNetworkUnavailableTitle",
                                "The network seems slow. Check your connection and try again."), icon)]
        case .noContent:
            return [CYLScenarioIcon("CYLPlaceholderEmpty.json", .empty,
                CYLScenarioText("CYLPlaceholderScenarioNoContentTitle", "Nothing here yet"), art)]
        case .tapToReload:
            return [CYLScenarioIcon("CYLPlaceholderRefresh.json", .refresh,
                CYLScenarioText("CYLPlaceholderScenarioTapToReloadTitle",
                                "Network unavailable. Tap the screen to reload."), icon)]
        case .loadFailedWithHint:
            return [CYLScenarioIcon("CYLPlaceholderLoadFailed.json", .errorOutline,
                        CYLScenarioText("CYLPlaceholderScenarioLoadFailedWithHintTitle", "Couldn't load the data"), icon),
                    CYLScenarioHint("CYLPlaceholderScenarioLoadFailedWithHintHint",
                                    "Check your network, then pull down to refresh")]
        case .tapToReconnect:
            return [CYLScenarioIcon("CYLPlaceholderNoInternet.json", .signalWifiOff,
                        CYLScenarioText("CYLPlaceholderScenarioTapToReconnectTitle", "Not connected to the internet"), icon),
                    CYLScenarioHint("CYLPlaceholderScenarioTapToReconnectHint",
                                    "Check your device's connection, then tap the screen to reconnect")]
        case .retryButton:
            return [CYLScenarioIcon("CYLPlaceholderSad.json", .noInternet,
                        CYLScenarioText("CYLPlaceholderScenarioRetryButtonTitle",
                                        "The network is slow. Please try again."), icon),
                    CYLScenarioButton(.retry, .filled)]
        case .retryOutlinedButton:
            return [CYLScenarioIcon("CYLPlaceholderLoadFailed.json", .reportProblem,
                        CYLScenarioText("CYLPlaceholderScenarioRetryOutlinedButtonTitle", "Something went wrong"), icon),
                    CYLScenarioButton(.retry, .outlined)]
        case .retryWithHint:
            let reload = CYLPlaceholderComponent.button(title: CYLScenarioText("CYLPlaceholderScenarioReloadTitle", "Reload"),
                                                        style: .outlined, action: .retry)
            return [CYLScenarioIcon("CYLPlaceholderNoInternet.json", .wifiOff,
                        CYLScenarioText("CYLPlaceholderScenarioRetryWithHintTitle", "Your network isn't working well"),
                        icon),
                    CYLScenarioHint("CYLPlaceholderScenarioRetryWithHintHint", "Check whether your phone is online"),
                    reload]
        case .retryOrContactSupport:
            let separator = CYLPlaceholderComponent.separator(text: CYLScenarioText("CYLPlaceholderScenarioOrSeparator", "or"))
            let support = CYLScenarioButton(.contactSupport, .outlined)
            support.spacingBefore = 14
            return [CYLScenarioIcon("CYLPlaceholderServerError.json", .cloudOff,
                        CYLScenarioText("CYLPlaceholderScenarioRetryOrContactSupportTitle",
                                        "Loading failed. Please try again later."), icon),
                    CYLScenarioButton(.retry, .filled),
                    separator, support]
        case .illustrationRetry:
            let retry = CYLPlaceholderComponent.button(
                title: CYLScenarioText("CYLPlaceholderScenarioTapToRetryTitle", "Tap to retry"), style: .capsule,
                action: .retry)
            return [CYLScenarioIcon("CYLPlaceholderCloudOff.json", .cloudOff, nil, art), retry]
        case .refreshIcon:
            let refresh = CYLPlaceholderComponent(bundledAnimation: "CYLPlaceholderRefresh.json", fallbackStyle: .refresh,
                                                  title: nil, size: CGSize(width: 44, height: 44), action: .retry)
            refresh.spacingBefore = 28
            return [CYLScenarioIcon("CYLPlaceholderSad.json", .help,
                        CYLScenarioText("CYLPlaceholderScenarioRefreshIconTitle", "Network unavailable"), icon),
                    refresh]
        case .titleAboveIllustration:
            let title = CYLPlaceholderComponent(attributes: [
                CYLPlaceholderItemTitle: CYLScenarioText("CYLPlaceholderScenarioTitleAboveIllustrationTitle",
                                                         "Loading failed. Tap to refresh!"),
            ], action: nil)
            return [title, CYLScenarioIcon("CYLPlaceholderPullHint.pag", .refresh, nil, art)]
        case .textOnly:
            let title = CYLPlaceholderComponent(attributes: [
                CYLPlaceholderItemTitle: CYLScenarioText("CYLPlaceholderScenarioTextOnlyTitle", "Connection failed"),
                CYLPlaceholderItemTitleFont: CYLScenarioFont(.title3, 20, .regular),
            ], action: nil)
            return [title, CYLScenarioHint("CYLPlaceholderScenarioTextOnlyHint", "Tap to reload")]
        case .tapMeRetry:
            let tapMe = CYLPlaceholderComponent(attributes: [
                CYLPlaceholderItemTitle: CYLScenarioText("CYLPlaceholderScenarioTapMeTitle", "Tap me"),
                CYLPlaceholderItemTitleColor: CYLScenarioAccentColor(),
            ], action: nil)
            let arrow = CYLScenarioIcon("CYLPlaceholderTapHint.json", .info, nil, 36)
            arrow.spacingBefore = 4
            let reload = CYLPlaceholderComponent.button(
                title: CYLScenarioText("CYLPlaceholderScenarioReloadNowTitle", "Reload now…"), style: .filled,
                action: .retry)
            reload.spacingBefore = 4
            // [EN] README #34, #35 end with a decorative mascot; the offline cloud says what went wrong instead.
            // [CN] README #34、#35 末尾是装饰性的吉祥物；这里改用表示离线的云图标，说明出了什么问题。
            let offline = CYLScenarioIcon("CYLPlaceholderCloudOff.json", .cloudOff, nil, 96)
            offline.spacingBefore = 12
            return [tapMe, arrow, reload, offline]
        case .noSearchResults:
            return [CYLScenarioIcon("CYLPlaceholderNoResults.json", .searchOff,
                        CYLScenarioText("CYLPlaceholderScenarioNoSearchResultsTitle", "No matching results"), icon),
                    CYLScenarioHint("CYLPlaceholderScenarioNoSearchResultsHint", "Try different keywords")]
        case .emptyCart:
            return [CYLScenarioIcon("CYLPlaceholderEmptyCart.json", .emptyCart,
                        CYLScenarioText("CYLPlaceholderScenarioEmptyCartTitle", "Your cart is empty"), art),
                    CYLScenarioButton(.goShopping, .outlined)]
        case .noOrders:
            return [CYLScenarioIcon("CYLPlaceholderNoOrders.json", .archive,
                        CYLScenarioText("CYLPlaceholderScenarioNoOrdersTitle", "No orders yet"), icon),
                    CYLScenarioButton(.goShopping, .filled)]
        case .noFavorites:
            return [CYLScenarioIcon("CYLPlaceholderNoFavorites.pag", .favorite,
                        CYLScenarioText("CYLPlaceholderScenarioNoFavoritesTitle", "No favorites yet"), art),
                    CYLScenarioHint("CYLPlaceholderScenarioNoFavoritesHint", "Save what you like and find it here")]
        case .noMessages:
            return [CYLScenarioIcon("CYLPlaceholderNoMessages.json", .inbox,
                        CYLScenarioText("CYLPlaceholderScenarioNoMessagesTitle", "No messages"), icon)]
        case .noNotifications:
            return [CYLScenarioIcon("CYLPlaceholderNoNotifications.json", .notificationsOff,
                        CYLScenarioText("CYLPlaceholderScenarioNoNotificationsTitle", "No notifications"), icon),
                    CYLScenarioHint("CYLPlaceholderScenarioNoNotificationsHint",
                                    "We'll let you know when something arrives")]
        case .noPermission:
            return [CYLScenarioIcon("CYLPlaceholderNoPermission.json", .locked,
                        CYLScenarioText("CYLPlaceholderScenarioNoPermissionTitle", "Permission required"), icon),
                    CYLScenarioHint("CYLPlaceholderScenarioNoPermissionHint", "Allow access in Settings to continue"),
                    CYLScenarioButton(.openSettings, .filled)]
        case .locationPermissionDenied:
            // [EN] README #20: the address could not be found, so the user may also pick one by hand.
            // [CN] README #20：无法获取地址，因此也可以手动选择地址。
            var components = CYLScenarioPermissionComponents(
                "Location", "CYLPlaceholderLocationPermission.json", .locationOff, "Can't get your location",
                "Location access is off, so nearby content can't load. This isn't a network problem: allow location "
                    + "access in Settings.")
            let manual = CYLPlaceholderComponent.button(
                title: CYLScenarioText("CYLPlaceholderScenarioChooseAddressTitle", "Choose an address manually"),
                style: .outlined, action: .chooseManually)
            manual.spacingBefore = 12
            components.append(manual)
            return components
        case .cameraPermissionDenied:
            return CYLScenarioPermissionComponents("Camera", "CYLPlaceholderCameraPermission.json", .videoOff,
                "Camera access is off", "Allow camera access in Settings to scan codes or take photos.")
        case .photoLibraryPermissionDenied:
            return CYLScenarioPermissionComponents("PhotoLibrary", "CYLPlaceholderPhotoLibraryPermission.json",
                .photoLibrary, "Photo access is off", "Allow photo access in Settings to choose pictures.")
        case .microphonePermissionDenied:
            return CYLScenarioPermissionComponents("Microphone", "CYLPlaceholderMicrophonePermission.json", .musicOff,
                "Microphone access is off", "Allow microphone access in Settings to record or make voice calls.")
        case .contactsPermissionDenied:
            return CYLScenarioPermissionComponents("Contacts", "CYLPlaceholderContactsPermission.json", .groupOff,
                "Contacts access is off", "Allow contacts access in Settings to find your friends.")
        case .calendarPermissionDenied:
            return CYLScenarioPermissionComponents("Calendar", "CYLPlaceholderCalendarPermission.json", .eventBusy,
                "Calendar access is off", "Allow calendar access in Settings to add events and reminders.")
        case .bluetoothPermissionDenied:
            return CYLScenarioPermissionComponents("Bluetooth", "CYLPlaceholderBluetoothPermission.json",
                .bluetoothDisabled, "Bluetooth access is off", "Allow Bluetooth in Settings to connect to nearby devices.")
        case .notificationPermissionDenied:
            return CYLScenarioPermissionComponents("Notification", "CYLPlaceholderNotificationPermission.json",
                .notificationsOff, "Notifications are off", "Turn on notifications in Settings to get messages in time.")
        case .serverError:
            return [CYLScenarioIcon("CYLPlaceholderServerError.json", .cloudOff,
                        CYLScenarioText("CYLPlaceholderScenarioServerErrorTitle", "The server is taking a break"), icon),
                    CYLScenarioHint("CYLPlaceholderScenarioServerErrorHint", "Please try again later"),
                    CYLScenarioButton(.retry, .filled)]
        case .syncFailed:
            return [CYLScenarioIcon("CYLPlaceholderCloudOff.json", .syncProblem,
                        CYLScenarioText("CYLPlaceholderScenarioSyncFailedTitle", "Sync failed"), icon),
                    CYLScenarioButton(.retry, .outlined)]
        case .loading:
            return [CYLScenarioIcon("CYLPlaceholderLoading.json", .hourglass,
                CYLScenarioText("CYLPlaceholderScenarioLoadingTitle", "Loading…"), art)]
        case .uploading:
            return [CYLScenarioIcon("CYLPlaceholderUploading.gif", .uploadOff,
                CYLScenarioText("CYLPlaceholderScenarioUploadingTitle", "Uploading…"), art)]
        case .success:
            // [EN] The animation ends on an empty frame: the still image shows once it has played.
            // [CN] 动画结束在空白帧：播放完后显示静态图。
            let successIcon = CYLScenarioIcon("CYLPlaceholderSuccess.riv", .info,
                        CYLScenarioText("CYLPlaceholderScenarioSuccessTitle", "Submitted"), art)
            successIcon.showsImageWhenAnimationEnds = true
            return [successIcon, CYLScenarioButton(.done, .filled)]
        case .hud:
            // [EN] A refresh-bundle spinner (GIF, played by the GIF subspec's animator), looping like every spinner;
            //      without an animation engine the Hourglass style shows.
            // [CN] 刷新资源中的加载圈（GIF，由 GIF 子库的 animator 播放），与所有加载类动画一样循环播放；没有动画引擎时显示 Hourglass 样式。
            return [CYLScenarioIcon("CYLRefreshActivity.gif", .hourglass,
                CYLScenarioText("CYLPlaceholderScenarioHUDTitle", "Loading…"), 56)]
        default:
            return []
        }
    }
}
