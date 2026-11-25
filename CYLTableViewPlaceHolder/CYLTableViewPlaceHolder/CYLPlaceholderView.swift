//
//  CYLPlaceholderView.swift
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] CYLPlaceholderView is a subclass of CYLTabBarController's `CYLAnimatedItemView` (integration guide:
//      https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md).
//      The base class owns the icon (`imageView`), the title (`titleLabel`), the animation view and its player, the
//      display priority (the animation when it can play, else the static `image`, else the component's placeholder),
//      the failure fallbacks and the loading state of URL files. This class adds what a placeholder needs on top: the
//      item attributes, its own layout (margins, offsets, title chrome, the horizontal arrangement), the badge, the
//      selection indicator, the appearance layers, the tap handler and the playback policy (visibility, Reduce Motion,
//      repeat count). Written in Swift since 2026-11-19, when the base class became Swift (Objective-C cannot subclass
//      a Swift class), with the same Objective-C API; the item keys, the enums, the error domain and the badge
//      appearance stay in `CYLPlaceholderView.h` / `CYLPlaceholderViewSupport.m`. Animations play only through the
//      engine: the Swift condition `CYL_ANIMATION_ENGINE_AVAILABLE`, set by this pod's animation subspecs (and by the
//      framework target and the test runners, which always have the engine). Without it the view shows static images
//      and every engine call below is compiled out.
// [CN] CYLPlaceholderView 继承自 CYLTabBarController 的 `CYLAnimatedItemView`（接入文档见上面的链接）。基类负责图标（`imageView`）、标题
//      （`titleLabel`）、动画视图及其播放器、显示优先级（能播放时显示动画，否则显示静态 `image`，再否则显示组件的占位图）、失败回退以及 URL 文件的
//      加载状态。本类在其上加入占位图需要的部分：item 属性、自己的布局（边距、偏移、标题装饰、横向排列）、角标、选中指示、外观层级、点击事件与播放策略
//      （可见性、减弱动态效果、重复次数）。基类改为 Swift 后（Objective-C 不能继承 Swift 类），本类自 2026-11-19 起用 Swift 编写，Objective-C API
//      不变；item key、枚举、错误域与角标外观保留在 `CYLPlaceholderView.h` / `CYLPlaceholderViewSupport.m` 中。动画只通过引擎播放：Swift 条件
//      `CYL_ANIMATION_ENGINE_AVAILABLE` 由本 pod 的动画子库设置（framework target 与测试脚本始终带引擎，也会设置）。没有引擎时只显示静态图片，
//      下面所有引擎相关代码都不参与编译。

import UIKit
import ObjectiveC
// [EN] The CYLAnimatedItem pod and framework; an older Carthage build compiled the component into CYLTabBarController.
// [CN] CYLAnimatedItem pod 与 framework；较早的 Carthage 构建把该组件编译进 CYLTabBarController。
#if canImport(CYLAnimatedItem)
import CYLAnimatedItem
#elseif canImport(CYLTabBarController)
import CYLTabBarController
#endif

// MARK: - Helpers

// [EN] The gap between the icon and the title of a horizontal item. [CN] 横向排列时图标与标题的间距。
private let CYLPlaceholderHorizontalSpacing: CGFloat = 5
private let CYLPlaceholderAnimationsDirectory = "Animations"
// [EN] The appearance layers' keys. [CN] 外观层级的 key。
private let CYLPlaceholderAppearanceKeys = ["titleColor", "iconColor", "backgroundColor", "titleFont"]
// [EN] Marks a value the caller changed while selected. [CN] 标记选中期间被调用方修改的值。
private let CYLPlaceholderCustomizedMarker: NSString = "CYLPlaceholderCustomized"

// [EN] The animation type keys, by value: the same strings as the exported `CYLPlaceholderItem<Type>…` constants, which
//      carry a deprecation warning when their engine is not in the build (meant for apps, not for this file).
// [CN] 各动画类型的 key（按取值）：与导出的 `CYLPlaceholderItem<Type>…` 常量字符串相同；这些常量在对应引擎未参与构建时带有弃用警告（针对应用，
//      不针对本文件）。
private enum CYLPlaceholderTypeKey {
    static let lottieURL = "CYLTabBarLottieURL"
    static let lottieFilePath = "CYLTabBarLottieFilePath"
    static let lottieSize = "CYLTabBarLottieSize"
    static let lottieDarkURL = "CYLTabBarLottieDarkURL"
    static let lottieDarkFilePath = "CYLTabBarLottieDarkFilePath"
    static let lottieDarkColors = "CYLTabBarLottieDarkColors"
    static let pagURL = "CYLTabBarPAGURL"
    static let pagFilePath = "CYLTabBarPAGFilePath"
    static let pagSize = "CYLTabBarPAGSize"
    static let pagDarkURL = "CYLTabBarPAGDarkURL"
    static let pagDarkFilePath = "CYLTabBarPAGDarkFilePath"
    static let riveURL = "CYLTabBarRiveURL"
    static let riveFilePath = "CYLTabBarRiveFilePath"
    static let riveSize = "CYLTabBarRiveSize"
    static let riveDarkURL = "CYLTabBarRiveDarkURL"
    static let riveDarkFilePath = "CYLTabBarRiveDarkFilePath"
    static let riveDarkColors = "CYLTabBarRiveDarkColors"
    static let gifURL = "CYLTabBarGIFURL"
    static let gifFilePath = "CYLTabBarGIFFilePath"
    static let gifSize = "CYLTabBarGIFSize"
    static let gifDarkURL = "CYLTabBarGIFDarkURL"
    static let gifDarkFilePath = "CYLTabBarGIFDarkFilePath"
}

private func CYLPlaceholderConfigurationFailure(_ description: String) -> NSError {
    NSError(domain: CYLPlaceholderConfigurationErrorDomain,
            code: CYLPlaceholderConfigurationError.Code.itemAttributes.rawValue,
            userInfo: [NSLocalizedDescriptionKey: description])
}

private func CYLPlaceholderNilIfNull(_ value: Any?) -> Any? {
    guard let value = value else { return nil }
    return value is NSNull ? nil : value
}

private func CYLPlaceholderSameValue(_ a: Any?, _ b: Any?) -> Bool {
    let first = CYLPlaceholderNilIfNull(a) as? NSObject
    let second = CYLPlaceholderNilIfNull(b) as? NSObject
    guard let lhs = first else { return second == nil }
    return lhs === second || lhs.isEqual(second)
}

// [EN] Whether `value` is an NSValue holding the same C type as `sample` (`@encode` in Objective-C).
// [CN] `value` 是否为与 `sample` 同一 C 类型的 NSValue（Objective-C 中的 `@encode`）。
private func CYLPlaceholderValue(_ value: Any?, hasTypeOf sample: NSValue) -> NSValue? {
    guard let value = value as? NSValue, !(value is NSNumber) else { return nil }
    return strcmp(value.objCType, sample.objCType) == 0 ? value : nil
}

private func CYLPlaceholderScanDouble(_ text: String) -> Double? {
    let scanner = Scanner(string: text)
    guard let number = scanner.scanDouble(), scanner.isAtEnd else { return nil }
    return number
}

private func CYLPlaceholderScanInt64(_ text: String) -> Int64? {
    let scanner = Scanner(string: text)
    scanner.charactersToBeSkipped = nil
    guard let number = scanner.scanInt64(), scanner.isAtEnd else { return nil }
    return number
}

private func CYLPlaceholderScanHex(_ text: String) -> UInt64? {
    let scanner = Scanner(string: text)
    return scanner.scanUInt64(representation: .hexadecimal)
}

private func CYLPlaceholderConfiguredImage(_ value: Any?, _ imageBundle: Bundle?) -> UIImage? {
    if let image = value as? UIImage { return image }
    guard let name = value as? String else { return nil }
    if name.hasPrefix("system:") {
        return UIImage(systemName: String(name.dropFirst(7)))
    }
    guard let bundle = imageBundle ?? CYLPlaceholderResourceBundle() else { return nil }
    return UIImage(named: name, in: bundle, compatibleWith: nil)
}

private func CYLPlaceholderAppearanceImage(_ light: UIImage?, _ dark: UIImage?) -> UIImage? {
    guard let light = light, let dark = dark else { return light ?? dark }
    let lightStyle = UITraitCollection(traitsFrom: [UITraitCollection(displayScale: light.scale),
                                                    UITraitCollection(userInterfaceStyle: .light)])
    let darkStyle = UITraitCollection(traitsFrom: [UITraitCollection(displayScale: dark.scale),
                                                   UITraitCollection(userInterfaceStyle: .dark)])
    var lightVariant = light.imageAsset?.image(with: lightStyle) ?? light
    var darkVariant = dark.imageAsset?.image(with: darkStyle) ?? dark
    if let cgImage = lightVariant.cgImage {
        lightVariant = UIImage(cgImage: cgImage, scale: lightVariant.scale, orientation: lightVariant.imageOrientation)
            .withRenderingMode(light.renderingMode)
    }
    if let cgImage = darkVariant.cgImage {
        darkVariant = UIImage(cgImage: cgImage, scale: darkVariant.scale, orientation: darkVariant.imageOrientation)
            .withRenderingMode(dark.renderingMode)
    }
    let asset = UIImageAsset()
    asset.register(lightVariant, with: UITraitCollection(displayScale: lightVariant.scale))
    asset.register(darkVariant, with: darkStyle)
    return asset.image(with: UITraitCollection.current)
}

private func CYLPlaceholderColor(_ value: Any?) -> UIColor? {
    if let color = value as? UIColor { return color }
    guard let text = value as? String, text.hasPrefix("#") else { return nil }
    var hex = String(text.dropFirst())
    let units = Array(hex.utf16)
    if units.count == 3 {
        hex = String(utf16CodeUnits: [units[0], units[0], units[1], units[1], units[2], units[2]], count: 6)
    }
    let length = (hex as NSString).length
    if length != 6 && length != 8 { return nil }
    let invalid = CharacterSet(charactersIn: "0123456789abcdefABCDEF").inverted
    if (hex as NSString).rangeOfCharacter(from: invalid).location != NSNotFound { return nil }
    guard var number = CYLPlaceholderScanHex(hex) else { return nil }
    if length == 6 { number = (number << 8) | 0xff }
    return UIColor(red: CGFloat((number >> 24) & 0xff) / 255.0,
                   green: CGFloat((number >> 16) & 0xff) / 255.0,
                   blue: CGFloat((number >> 8) & 0xff) / 255.0,
                   alpha: CGFloat(number & 0xff) / 255.0)
}

private func CYLPlaceholderFont(_ value: Any?) -> UIFont? {
    if let font = value as? UIFont { return font }
    var name: String?
    var weightName: String?
    var size = 0.0
    if let number = value as? NSNumber {
        size = number.doubleValue
    } else if let string = value as? String {
        let text = string.trimmingCharacters(in: .whitespacesAndNewlines) as NSString
        let colon = text.range(of: ":", options: .backwards)
        let sizeText = colon.location == NSNotFound ? text as String : text.substring(from: NSMaxRange(colon))
        guard let scanned = CYLPlaceholderScanDouble(sizeText) else { return nil }
        size = scanned
        if colon.location != NSNotFound { name = text.substring(to: colon.location) }
    } else if let dictionary = value as? NSDictionary {
        guard let sizeValue = dictionary["size"] as? NSNumber else { return nil }
        size = sizeValue.doubleValue
        if dictionary["name"] != nil && !(dictionary["name"] is String) { return nil }
        if dictionary["weight"] != nil && !(dictionary["weight"] is String) { return nil }
        name = dictionary["name"] as? String
        weightName = dictionary["weight"] as? String
    } else {
        return nil
    }
    if !size.isFinite || size < 1 || size > 200 { return nil }
    let weights: [String: UIFont.Weight] = [
        "ultralight": .ultraLight, "thin": .thin, "light": .light, "regular": .regular, "medium": .medium,
        "semibold": .semibold, "bold": .bold, "heavy": .heavy, "black": .black
    ]
    let weight = weights[(weightName ?? name ?? "regular").lowercased()]
    if weightName != nil && weight == nil { return nil }
    let font: UIFont?
    if let name = name, !name.isEmpty, weight == nil {
        font = UIFont(name: name, size: CGFloat(size))
    } else {
        font = UIFont.systemFont(ofSize: CGFloat(size), weight: weight ?? UIFont.Weight(rawValue: 0))
    }
    // Configured sizes are the default-text-size values; they scale with Dynamic Type.
    guard let resolved = font else { return nil }
    return UIFontMetrics.default.scaledFont(for: resolved)
}

private func CYLPlaceholderNumbers(_ value: Any?, _ keys: [[String]]) -> [Double]? {
    var numbers = [Double]()
    if let array = value as? NSArray {
        guard array.count == keys.count else { return nil }
        for item in array {
            guard let number = item as? NSNumber else { return nil }
            numbers.append(number.doubleValue)
        }
    } else if let dictionary = value as? NSDictionary {
        for synonyms in keys {
            var found: Any?
            for key in synonyms where dictionary[key] != nil {
                found = dictionary[key]
                break
            }
            guard let number = found as? NSNumber else { return nil }
            numbers.append(number.doubleValue)
        }
    } else {
        return nil
    }
    for number in numbers where !number.isFinite || abs(number) > 1000 { return nil }
    return numbers
}

private func CYLPlaceholderOffset(_ value: Any?) -> UIOffset? {
    if let boxed = CYLPlaceholderValue(value, hasTypeOf: NSValue(uiOffset: .zero)) {
        let offset = boxed.uiOffsetValue
        guard offset.horizontal.isFinite, offset.vertical.isFinite,
              abs(offset.horizontal) <= 1000, abs(offset.vertical) <= 1000 else { return nil }
        return offset
    }
    guard let numbers = CYLPlaceholderNumbers(value, [["horizontal", "x"], ["vertical", "y"]]) else { return nil }
    return UIOffset(horizontal: CGFloat(numbers[0]), vertical: CGFloat(numbers[1]))
}

private func CYLPlaceholderInsets(_ value: Any?) -> UIEdgeInsets? {
    if let boxed = CYLPlaceholderValue(value, hasTypeOf: NSValue(uiEdgeInsets: .zero)) {
        let insets = boxed.uiEdgeInsetsValue
        let sides = [insets.top, insets.left, insets.bottom, insets.right]
        for side in sides where !side.isFinite || abs(side) > 1000 { return nil }
        return insets
    }
    guard let numbers = CYLPlaceholderNumbers(value, [["top"], ["left"], ["bottom"], ["right"]]) else { return nil }
    return UIEdgeInsets(top: CGFloat(numbers[0]), left: CGFloat(numbers[1]), bottom: CGFloat(numbers[2]), right: CGFloat(numbers[3]))
}

// The `contentMode` animation option, as a number or a UIViewContentMode case name; aspect fit by default.
private func CYLPlaceholderAnimationContentMode(_ options: NSDictionary?) -> UIView.ContentMode {
    var contentMode = UIView.ContentMode.scaleAspectFit
    let value = options?["contentMode"]
    if let number = value as? NSNumber {
        let raw = number.intValue
        if raw >= UIView.ContentMode.scaleToFill.rawValue && raw <= UIView.ContentMode.bottomRight.rawValue &&
            raw != UIView.ContentMode.redraw.rawValue, let mode = UIView.ContentMode(rawValue: raw) {
            contentMode = mode
        }
    } else if let name = value as? String {
        let names: [String: UIView.ContentMode] = [
            "scaleToFill": .scaleToFill, "scaleAspectFit": .scaleAspectFit, "scaleAspectFill": .scaleAspectFill,
            "center": .center, "top": .top, "bottom": .bottom, "left": .left, "right": .right,
            "topLeft": .topLeft, "topRight": .topRight, "bottomLeft": .bottomLeft, "bottomRight": .bottomRight
        ]
        if let mode = names[name] {
            contentMode = mode
        } else {
            NSLog("CYLTableViewPlaceHolder: unknown animation contentMode '%@'.", name)
        }
    }
    return contentMode
}

// [EN] `fileURL` with the animation `options` in its fragment, in the format of CYLTabBarController's
//      `CYLTabBarAnimationURLWithOptions()` ("name=value&…", sorted, percent-encoded), which its animators read (the
//      Rive artboard, state machine…). `contentMode` and `animationSpeed` are applied by the view, not written.
// [CN] 把动画 `options` 写入 `fileURL` 的 fragment，格式与 CYLTabBarController 的 `CYLTabBarAnimationURLWithOptions()` 相同（「名称=值&…」，
//      排序并百分号编码），由其 animator 读取（Rive 画板、状态机等）。`contentMode` 与 `animationSpeed` 由视图应用，不写入。
private func CYLPlaceholderAnimationURLWithOptions(_ fileURL: URL, _ options: NSDictionary) -> URL {
    if options.count == 0 { return fileURL }
    var allowed = CharacterSet.urlQueryAllowed
    allowed.remove(charactersIn: "&=+#?")
    let names = options.allKeys.compactMap { $0 as? String }.sorted { ($0 as NSString).compare($1) == .orderedAscending }
    var items = [String]()
    for name in names where name != "contentMode" && name != "animationSpeed" {
        let value = options[name]
        let text: String? = (value as? String) ?? (value as? NSNumber)?.stringValue
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: allowed), !encodedName.isEmpty,
              let encodedValue = text?.addingPercentEncoding(withAllowedCharacters: allowed), !encodedValue.isEmpty else { continue }
        items.append("\(encodedName)=\(encodedValue)")
    }
    if items.isEmpty { return fileURL }
    guard let components = NSURLComponents(url: fileURL, resolvingAgainstBaseURL: true) else { return fileURL }
    components.percentEncodedFragment = items.joined(separator: "&")
    return components.url ?? fileURL
}

// A highlight style from a number or its name ("dim", "shrink", "none").
private func CYLPlaceholderTapHighlightStyleFromValue(_ value: Any) -> CYLPlaceholderTapHighlightStyle? {
    if let name = value as? String {
        guard let index = ["dim", "shrink", "none"].firstIndex(of: name.lowercased()) else { return nil }
        return CYLPlaceholderTapHighlightStyle(rawValue: index)
    }
    guard let number = (value as? NSNumber)?.doubleValue else { return nil }
    if !number.isFinite || number != number.rounded(.down) ||
        number < Double(CYLPlaceholderTapHighlightStyle.dim.rawValue) ||
        number > Double(CYLPlaceholderTapHighlightStyle.none.rawValue) { return nil }
    return CYLPlaceholderTapHighlightStyle(rawValue: Int(number))
}

// A repeat count from a number (0 loops) or "loop" / "once".
private func CYLPlaceholderRepeatCountFromValue(_ value: Any) -> Int? {
    if let name = value as? String {
        switch name.lowercased() {
        case "loop": return 0
        case "once": return 1
        default: return nil
        }
    }
    guard let number = (value as? NSNumber)?.doubleValue else { return nil }
    if !number.isFinite || number != number.rounded(.down) || number < 0 || number > 10000 { return nil }
    return Int(number)
}

// MARK: - The base class's subviews

// [EN] The base class creates `imageView` and `titleLabel` as a plain UIImageView and UILabel. CYLPlaceholderView
//      changes their class to these subclasses, which add no storage (so the change is safe): a value an app sets on
//      them directly lays the placeholder out again, as before, and a static image set on `imageView` becomes the base
//      class's `image`, which decides what the icon shows.
// [CN] 基类把 `imageView` 与 `titleLabel` 创建为普通的 UIImageView 与 UILabel。CYLPlaceholderView 将它们的类改为下面的子类（不增加存储，
//      因此修改是安全的）：应用直接设置的值会让占位图重新布局（与以前相同），设置到 `imageView` 的静态图片会成为基类的 `image`，由基类决定图标显示什么。
@objc(CYLPlaceholderItemImageView)
final class CYLPlaceholderItemImageView: UIImageView {
    override var image: UIImage? {
        get { super.image }
        set {
            super.image = newValue
            let owner = superview
            (owner as? CYLPlaceholderView)?.cyl_imageViewDidSetImage(newValue)
            owner?.setNeedsLayout()
        }
    }

    override var isHidden: Bool {
        get { super.isHidden }
        set {
            super.isHidden = newValue
            superview?.setNeedsLayout()
        }
    }
}

@objc(CYLPlaceholderItemLabel)
final class CYLPlaceholderItemLabel: UILabel {
    override var text: String? {
        get { super.text }
        set {
            super.text = newValue
            superview?.setNeedsLayout()
        }
    }

    override var attributedText: NSAttributedString? {
        get { super.attributedText }
        set {
            super.attributedText = newValue
            superview?.setNeedsLayout()
        }
    }

    override var font: UIFont! {
        get { super.font }
        set {
            super.font = newValue
            superview?.setNeedsLayout()
        }
    }

    override var isHidden: Bool {
        get { super.isHidden }
        set {
            super.isHidden = newValue
            superview?.setNeedsLayout()
        }
    }
}

// [EN] `url` without its fragment: the animation file itself. [CN] 去掉 fragment 的 `url`，即动画文件本身。
private func CYLPlaceholderAnimationFileURL(_ url: URL) -> URL {
    guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else { return url }
    components.fragment = nil
    return components.url ?? url
}

#if CYL_ANIMATION_ENGINE_AVAILABLE

// MARK: - Factories registered with registerAnimationFactory(_:forFileExtension:)

// [EN] The options in `url`'s fragment, as `CYLPlaceholderAnimationURLWithOptions()` writes them. [CN] `url` fragment 中的选项。
private func CYLPlaceholderAnimationOptionsFromURL(_ url: URL) -> [String: Any] {
    let fragment = NSURLComponents(url: url, resolvingAgainstBaseURL: true)?.percentEncodedFragment ?? ""
    var options = [String: Any]()
    for item in fragment.components(separatedBy: "&") {
        let pair = item as NSString
        let separator = pair.range(of: "=")
        if separator.location == NSNotFound || separator.location == 0 { continue }
        guard let name = pair.substring(to: separator.location).removingPercentEncoding,
              let value = pair.substring(from: NSMaxRange(separator)).removingPercentEncoding,
              !name.isEmpty, !value.isEmpty else { continue }
        options[name] = value
    }
    return options
}

// [EN] Plays a factory's `CYLPlaceholderAnimationPlayer` view through the engine's player protocol. It answers only
//      for what the view supports, so the base class sees the same features as before.
// [CN] 通过引擎的播放器协议播放工厂创建的 `CYLPlaceholderAnimationPlayer` 视图；只对视图支持的功能作出响应，因此基类看到的功能与以前相同。
@objc(CYLPlaceholderFactoryAnimationPlayer)
final class CYLPlaceholderFactoryAnimationPlayer: CYLTabBarItemAnimationBasePlayer, CYLTabBarItemAnimationPlayer {
    private var storedProgress: CGFloat = 0
    private var storedSpeed: CGFloat = 0
    private var storedLoops = false

    private var playerView: (UIView & CYLPlaceholderAnimationPlayer)? {
        animationView as? (UIView & CYLPlaceholderAnimationPlayer)
    }

    override func responds(to selector: Selector!) -> Bool {
        let view = playerView
        switch selector {
        case #selector(getter: CYLTabBarItemAnimationPlayer.progress), #selector(setter: CYLTabBarItemAnimationPlayer.progress):
            return view?.responds(to: #selector(CYLPlaceholderAnimationPlayer.setAnimationProgress(_:))) ?? false
        case #selector(getter: CYLTabBarItemAnimationPlayer.animationSpeed),
             #selector(setter: CYLTabBarItemAnimationPlayer.animationSpeed):
            return view?.responds(to: #selector(CYLPlaceholderAnimationPlayer.setAnimationSpeed(_:))) ?? false
        case #selector(getter: CYLTabBarItemAnimationPlayer.loops), #selector(setter: CYLTabBarItemAnimationPlayer.loops):
            return view?.responds(to: #selector(CYLPlaceholderAnimationPlayer.setAnimationRepeatCount(_:))) ?? false
        case #selector(CYLTabBarItemAnimationPlayer.applyColors(_:traitCollection:)):
            return view?.responds(to: #selector(CYLPlaceholderAnimationPlayer.setAnimationColors(_:))) ?? false
        default:
            return super.responds(to: selector)
        }
    }

    func play() {
        playerView?.play()
    }

    func stop() {
        playerView?.stop()
    }

    func showLastFrame() {
        playerView?.showLastFrame()
        storedProgress = 1
    }

    var progress: CGFloat {
        get { storedProgress }
        set {
            if let view = playerView, view.setAnimationProgress?(newValue) == true { storedProgress = newValue }
        }
    }

    var animationSpeed: CGFloat {
        get { storedSpeed > 0 ? storedSpeed : 1 }
        set {
            if let view = playerView, view.setAnimationSpeed?(newValue) == true { storedSpeed = newValue }
        }
    }

    var loops: Bool {
        get { storedLoops }
        set {
            if let view = playerView, view.setAnimationRepeatCount?(newValue ? 0 : 1) == true { storedLoops = newValue }
        }
    }

    func applyColors(_ colors: [String: UIColor]?, traitCollection: UITraitCollection) {
        guard let colors = colors, let view = playerView,
              view.responds(to: #selector(CYLPlaceholderAnimationPlayer.setAnimationColors(_:))) else { return }
        if view.setAnimationColors?(colors) != true {
            NSLog("CYLTableViewPlaceHolder: animation color overrides are not supported by this player.")
        }
    }
}

// [EN] A factory as an animator of the engine's registry, ahead of the built-in animators for its extension.
// [CN] 作为引擎注册表中 animator 的工厂，对其扩展名优先于内置 animator。
@objc(CYLPlaceholderFactoryAnimator)
final class CYLPlaceholderFactoryAnimator: NSObject, CYLTabBarItemAnimator {
    let identifier: String
    let fileExtensions: [String]
    private let factory: CYLPlaceholderAnimationFactory

    static func identifier(forFileExtension fileExtension: String) -> String {
        "CYLPlaceholderFactory." + fileExtension.lowercased()
    }

    init(fileExtension: String, factory: @escaping CYLPlaceholderAnimationFactory) {
        identifier = CYLPlaceholderFactoryAnimator.identifier(forFileExtension: fileExtension)
        fileExtensions = [fileExtension.lowercased()]
        self.factory = factory
        super.init()
    }

    var priority: CYLTabBarItemAnimatorPriority { CYLTabBarItemAnimatorPriority(rawValue: 1000) }

    func canAnimateFile(at url: URL) -> Bool {
        fileExtensions.contains(url.pathExtension.lowercased())
    }

    func animationView(with url: URL, size: CGSize, contentMode: UIView.ContentMode) -> UIView? {
        var error: NSError?
        guard let view = factory(CYLPlaceholderAnimationFileURL(url), size, contentMode,
                                 CYLPlaceholderAnimationOptionsFromURL(url), &error) else {
            NSLog("CYLTableViewPlaceHolder: animation could not be loaded: %@.", error?.localizedDescription ?? "factory returned no view")
            return nil
        }
        // [EN] A late failure or the end of loading goes back through the engine to the base class, which shows the static
        //      image (or the placeholder) until the animation is ready and again after it fails.
        // [CN] 迟到的失败或加载完成经由引擎通知基类：动画就绪前以及失败后，基类显示静态图片（或占位图）。
        view.errorHandler = { [weak view] backendError in
            NSLog("CYLTableViewPlaceHolder: animation failed: %@.", backendError.localizedDescription)
            if let strongView = view { CYLTabBarItemAnimationReportFailure(strongView, backendError) }
        }
        view.readyHandler = { [weak view] in
            if let strongView = view { CYLTabBarItemAnimationReportLoaded(strongView) }
        }
        if !view.isReady { CYLTabBarItemAnimationMarkLoading(view) }
        return view
    }

    func player(forAnimationView view: UIView) -> CYLTabBarItemAnimationPlayer? {
        guard view is CYLPlaceholderAnimationPlayer else { return nil }
        return CYLPlaceholderFactoryAnimationPlayer(animationView: view)
    }
}

#endif

// MARK: - CYLPlaceholderView

/**
 * [EN] A reusable, localized empty-state view: the packaged animated icon + title view of this library. It is a
 *      `CYLAnimatedItemView` (`axis` vertical by default): the icon plays any file of CYLTabBarController's animation
 *      engine when an animation subspec adds the engine, and shows its static image otherwise; the display priority,
 *      the failure fallbacks and the loading state of URL files are the base class's. Customize its image and label as
 *      needed. Written in Swift (2026-11-19) with the same Objective-C API.
 * [CN] 可复用、已本地化的空状态视图，即本库封装好的动效 icon + title 视图。它是一个 `CYLAnimatedItemView`（默认 `axis` 为纵向）：加入动画子库
 *      带入引擎后，图标可播放 CYLTabBarController 动画引擎支持的任意文件，否则显示静态图片；显示优先级、失败回退与 URL 文件的加载状态由基类处理。
 *      图片与文字可按需定制。用 Swift 编写（2026-11-19），Objective-C API 不变。
 */
@objc(CYLPlaceholderView)
open class CYLPlaceholderView: CYLAnimatedItemView {

    // MARK: Public properties

    /**
     * [EN] The title label: the base class's `titleLabel`. [CN] 标题标签，即基类的 `titleLabel`。
     */
    @objc open var textLabel: UILabel { titleLabel }

    /**
     * Badge appearance can be customized directly. VoiceOver can read it separately
     * when the placeholder is not itself an accessibility element.
     */
    @objc public let badgeLabel = UILabel()

    /**
     * A nil value hides the badge; an empty string displays a dot.
     */
    @objc open dynamic var badgeValue: String? {
        get { storedBadgeValue }
        set { cyl_setBadgeValue(newValue) }
    }

    /**
     * Offset from the top-right of the image (or title when there is no image).
     */
    @objc open dynamic var badgeCenterOffset: CGPoint {
        get { storedBadgeCenterOffset }
        set {
            if !newValue.x.isFinite || !newValue.y.isFinite {
                NSLog("CYLTableViewPlaceHolder: badge offset must be finite.")
                return
            }
            storedBadgeCenterOffset = newValue
            setNeedsLayout()
        }
    }

    /**
     * Drawn behind the selected item. Resizable images fill the item; others are centered.
     */
    @objc open dynamic var selectionIndicatorImage: UIImage? {
        didSet { cyl_updateSelectionIndicator() }
    }

    /**
     * The tint of `selectionIndicatorImage`.
     */
    @objc open dynamic var selectionIndicatorTintColor: UIColor? {
        didSet { cyl_updateSelectionIndicator() }
    }

    /**
     * Appearance layers, as in CYLFlatDesignTabBarButton: explicit item attributes win, then these
     * values (directly or through the UIAppearance proxy, applied live), then the built-in values.
     * A value set directly on `textLabel` or `imageView` is never overwritten. Without an icon color
     * the icon follows `tintColor`. Default title color for the normal state.
     */
    @objc open dynamic var defaultTitleColor: UIColor? {
        didSet { cyl_applyAppearance() }
    }

    /**
     * Default icon color for the normal state.
     */
    @objc open dynamic var defaultIconColor: UIColor? {
        didSet { cyl_applyAppearance() }
    }

    /**
     * Default background color for the normal state.
     */
    @objc open dynamic var defaultBackgroundColor: UIColor? {
        didSet { cyl_applyAppearance() }
    }

    /**
     * Default title font for the normal state.
     */
    @objc open dynamic var defaultTitleFont: UIFont? {
        didSet { cyl_applyAppearance() }
    }

    /**
     * Title offset used when the item has no `CYLPlaceholderItemTitlePositionAdjustment` of its own.
     */
    @objc open dynamic var defaultTitlePositionAdjustment: UIOffset {
        get { storedDefaultTitlePositionAdjustment }
        set {
            if !newValue.horizontal.isFinite || !newValue.vertical.isFinite {
                NSLog("CYLTableViewPlaceHolder: title position adjustment must be finite.")
                return
            }
            storedDefaultTitlePositionAdjustment = newValue
            setNeedsLayout()
        }
    }

    /**
     * Default title color for the selected state. Can be customized via UIAppearance proxy.
     */
    @objc open dynamic var defaultSelectedTitleColor: UIColor? {
        didSet { cyl_applyAppearance() }
    }

    /**
     * Default icon color for the selected state.
     */
    @objc open dynamic var defaultSelectedIconColor: UIColor? {
        didSet { cyl_applyAppearance() }
    }

    /**
     * Default background color for the selected state.
     */
    @objc open dynamic var defaultSelectedBackgroundColor: UIColor? {
        didSet { cyl_applyAppearance() }
    }

    /**
     * Default title font for the selected state.
     */
    @objc open dynamic var defaultSelectedTitleFont: UIFont? {
        didSet { cyl_applyAppearance() }
    }

    /**
     * Default selection indicator image.
     */
    @objc open dynamic var defaultSelectionIndicatorImage: UIImage? {
        didSet { cyl_applyAppearance() }
    }

    /**
     * Default selection indicator tint color.
     */
    @objc open dynamic var defaultSelectionIndicatorTintColor: UIColor? {
        didSet { cyl_applyAppearance() }
    }

    /**
     * [EN] Original item attributes. An animation file (GIF, Lottie, PAG, Rive, SVGA…) plays when the view enters a window,
     *      through CYLTabBarController's animation engine and the animator of its type: add the matching subspec of this
     *      pod (or CYLTabBarController's `CYLAnimatedItem<Type>`). The Core subspec alone has no engine and shows the
     *      static image. The icon keeps the animation's size (`CYLPlaceholderItemAnimationSize`) whatever stands in for it.
     * [CN] 原始 item 属性。动画文件（GIF、Lottie、PAG、Rive、SVGA……）在视图进入窗口时，通过 CYLTabBarController 的动画引擎及对应类型的
     *      animator 播放：需加入本 pod 对应的子库（或 CYLTabBarController 的 `CYLAnimatedItem<Type>`）。只有 Core 子库时没有引擎，显示静态图片。
     *      无论用什么代替动画，图标都保持动画尺寸（`CYLPlaceholderItemAnimationSize`）。
     */
    @objc public private(set) var itemAttributes: [String: Any] = [:]

    // [EN] The short name this view reported as missing, if any. [CN] 本视图报告为缺失的资源短名（如有）。
    private var reportedResource: String?

    // [EN] `onResourceMissing(resource, reason)` is declared by `CYLAnimatedItemView` (CYLTabBarController d0aadcd7), which
    //      calls it for the item's own failures; this view also calls it for the missing file it reports to the red status
    //      bar (`CYLPlaceholderResourceReporter`, docs/Status-Bar.md), with the short name and `file not found` / `unreadable`.
    // [CN] `onResourceMissing(resource, reason)` 由 `CYLAnimatedItemView` 声明（CYLTabBarController d0aadcd7），引擎在条目自身失败时调用；
    //      本视图在向红色状态栏报告缺失文件时也调用它（短名与 `file not found` / `unreadable`）。

    /**
     * NO (the default): the view fills the frame it is given and centers its content, as before. YES: it also reports its
     * content size as `intrinsicContentSize`, so a UIStackView or Auto Layout can size it. CYLPlaceholderStackView sets it
     * on its components.
     */
    @objc open var reportsContentSize = false {
        didSet { invalidateIntrinsicContentSize() }
    }

    /**
     * The widest the content may be when `reportsContentSize` is YES, padding included; 0 uses the screen width. Long
     * titles wrap within it.
     */
    @objc open var preferredMaxLayoutWidth: CGFloat {
        get { storedPreferredMaxLayoutWidth }
        set {
            if storedPreferredMaxLayoutWidth == newValue { return }
            storedPreferredMaxLayoutWidth = newValue
            invalidateIntrinsicContentSize()
        }
    }

    /**
     * [EN] The space kept between each side of the view and its content: 16 points by default, as a full-screen
     *      placeholder needs. A view narrower than its content plus both margins gives up the margins first, so the content
     *      stays centered and laid out instead of collapsing to zero width. A compact use, such as the icon of a refresh
     *      control (CYLRefreshIconView), sets 0.
     * [CN] 视图两侧与内容之间保留的距离：默认 16 点，适合全屏占位图。视图窄于内容加两侧边距时先放弃边距，内容保持居中并正常布局，而不会被压缩为
     *      零宽度。紧凑场景（如刷新控件的图标 CYLRefreshIconView）设为 0。
     */
    @objc open var contentMargin: CGFloat {
        get { storedContentMargin }
        set {
            if storedContentMargin == newValue { return }
            storedContentMargin = newValue
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    /**
     * The placeholder's own tap event: runs only while `tapInteractionEnabled` is YES. Setting it makes the view
     * respond to taps (with the highlight of `tapHighlightStyle` and the button trait for VoiceOver); nil removes it.
     * Called on the main thread.
     */
    @objc open var tapHandler: ((CYLPlaceholderView) -> Void)? {
        didSet { cyl_updateTapAccessibility() }
    }

    /**
     * Whether taps are handled. NO: the handler does not run and the pressed highlight does not show, and touches pass
     * through as before. Defaults to YES, or to `CYLPlaceholderItemInteractionEnabled`.
     */
    @objc(tapInteractionEnabled) open var isTapInteractionEnabled: Bool {
        @objc(isTapInteractionEnabled) get { storedTapInteractionEnabled }
        set {
            storedTapInteractionEnabled = newValue
            if !newValue { cyl_setTapHighlighted(false) }
            cyl_updateTapAccessibility()
        }
    }

    /**
     * The pressed look; defaults to Dim, or to `CYLPlaceholderItemTapHighlightStyle`.
     */
    @objc open var tapHighlightStyle: CYLPlaceholderTapHighlightStyle = .dim

    /**
     * YES while a finger is down on a tappable placeholder.
     */
    @objc(tapHighlighted) open var isTapHighlighted: Bool {
        @objc(isTapHighlighted) get { storedTapHighlighted }
    }

    /**
     * YES when a tap would run the handler: interaction is enabled and a handler is set.
     */
    @objc(tapInteractive) open var isTapInteractive: Bool {
        @objc(isTapInteractive) get { isTapInteractionEnabled && tapHandler != nil }
    }

    // [EN] `showsImageWhenAnimationEnds` and `isShowingImageAfterAnimationEnd` are declared and handled by
    //      `CYLAnimatedItemView` itself (CYLTabBarController d0aadcd7); this view only passes the flag on.
    // [CN] `showsImageWhenAnimationEnds` 与 `isShowingImageAfterAnimationEnd` 由 `CYLAnimatedItemView` 自己声明并处理
    //      （CYLTabBarController d0aadcd7）；本视图只转发该开关。

    /**
     * How many times the animation plays each time it starts: 0 loops until stopped (`animationLoops`), N plays N times.
     * Defaults to 1, or to `CYLPlaceholderItemAnimationRepeatCount`. Players that loop or report their progress (Lottie,
     * PAG) support every value; others (GIF, Rive, SVGA) play as their file defines. Reduce Motion still stops the
     * animation.
     */
    @objc open var animationRepeatCount: Int {
        get { storedAnimationRepeatCount }
        set {
            if newValue < 0 || storedAnimationRepeatCount == newValue { return }
            storedAnimationRepeatCount = newValue
            super.animationLoops = newValue == 0
            cyl_updateAnimationPlayback()
        }
    }

    /**
     * [EN] Whether the animation loops. A value set directly is kept: it is the same as `animationRepeatCount` 0 (true) or
     *      1 (false), so a reload of the item's attributes does not undo it.
     * [CN] 动画是否循环。直接设置的值会被保留：等同于把 `animationRepeatCount` 设为 0（true）或 1（false），因此重新加载 item 属性不会撤销它。
     */
    open override var animationLoops: Bool {
        get { super.animationLoops }
        set {
            super.animationLoops = newValue
            // [EN] Only a change of kind (loop or not) writes the count; a count N > 1 stays. [CN] 只有类型变化（循环与否）才写入次数；N > 1 保持不变。
            if (storedAnimationRepeatCount == 0) != newValue {
                storedAnimationRepeatCount = newValue ? 0 : 1
                cyl_updateAnimationPlayback()
            }
        }
    }

    /**
     * [EN] The playback speed, 1 by default. A positive value set directly is kept, as with
     *      `setPlaceholderAnimationSpeed(_:)`, so a reload of the item's attributes does not undo it.
     * [CN] 播放速度，默认 1。直接设置的正数会被保留（与 `setPlaceholderAnimationSpeed(_:)` 相同），因此重新加载 item 属性不会撤销它。
     */
    open override var animationSpeed: CGFloat {
        get { super.animationSpeed }
        set {
            if newValue.isFinite && newValue > 0 { explicitAnimationSpeed = newValue }
            super.animationSpeed = newValue
        }
    }

    // MARK: Private state

    private var storedBadgeValue: String?
    private var storedBadgeCenterOffset = CGPoint.zero
    private var storedDefaultTitlePositionAdjustment = UIOffset.zero
    private var storedPreferredMaxLayoutWidth: CGFloat = 0
    private var storedContentMargin: CGFloat = 16
    private var storedTapInteractionEnabled = true
    private var storedTapHighlighted = false
    private var storedAnimationRepeatCount = 1

    // [EN] Holds the badge label one level below the control, as the old inner item view did: a direct subview of the
    //      accessibility element was still exposed to UI automation beside it. Same frame as the view, no touches.
    // [CN] 让角标标签位于控件下一层，与原来的内部条目视图相同：作为无障碍元素的直接子视图时，它仍会与元素并列暴露给 UI 自动化。与视图同大小，不响应触摸。
    private var badgeContainerView: UIView?
    // [EN] Layout values from the item attributes (adapted from CYLFlatDesignTabBarButton). [CN] 来自 item 属性的布局值。
    private var itemTitleOffset = UIOffset.zero
    private var itemImageOffset = UIOffset.zero
    private var itemImageInsets = UIEdgeInsets.zero
    // [EN] The size the animation is laid out at (`CYLPlaceholderItemAnimationSize`). [CN] 动画的布局尺寸。
    private var itemAnimationSize = CGSize.zero
    // [EN] YES: the icon at the leading edge, the title after it (`CYLPlaceholderItemContentAxis`). [CN] YES：横向排列。
    private var horizontal = false
    // [EN] Where the content was laid out last (the old inner item view's frame); read by the tests through KVC.
    // [CN] 内容最近一次布局的位置（原内部条目视图的 frame）；测试通过 KVC 读取。
    @objc private(set) var itemFrame = CGRect.zero
    // Title chrome (CYLPlaceholderItemTitle... keys); nil background view means a plain title.
    private var titleBackgroundView: UIImageView?
    private var titleContentInsets = UIEdgeInsets.zero
    private var titleMinimumWidth: CGFloat = 0
    private var titleCornerRadius: CGFloat = 0
    private var titleBorderColor: UIColor?
    private var titleBorderWidth: CGFloat = 0
    private var animationImageBundle: Bundle?
    private var animationStopped = false
    private var animationShowsLastFrame = false
    // [EN] Set by playPlaceholderAnimation(): the next play starts from progress 0 (also when the view becomes visible
    //      later), so a finished one-shot animation plays again.
    // [CN] 由 playPlaceholderAnimation() 设置：下一次播放从进度 0 开始（视图稍后才可见时也是），播放结束的单次动画因此能再次播放。
    private var animationRestartPending = false
    private var animationSeekProgress: CGFloat?
    // [EN] The speed set with setPlaceholderAnimationSpeed(_:), and the `animationSpeed` option. [CN] 显式设置的速度与选项中的速度。
    private var explicitAnimationSpeed: CGFloat?
    private var optionAnimationSpeed: CGFloat?
    private var animationContentMode = UIView.ContentMode.scaleAspectFit
    private var animationColors: [String: UIColor]?
    // [EN] Replays a player N - 1 more times for a repeat count N > 1. [CN] 重复次数 N > 1 时再重播 N - 1 次。
    private var repeatTimer: Timer?
    private var remainingRepeats = 0
    // [EN] YES while a static image set on `imageView` is copied to the base class's `image`. [CN] 正在把静态图片同步给基类。
    private var syncingImage = false
    // [EN] The subviews' alpha before the pressed highlight. [CN] 按下高亮前各子视图的 alpha。
    private var highlightAlphas: NSMapTable<UIView, NSNumber>?
    // Whether the tap API added the button trait, and the not-enabled trait, so it removes only what it added.
    private var tapAddedButtonTrait = false
    private var tapAddedNotEnabledTrait = false
    private var selectedTitle: String?
    private var selectedTitleColor: UIColor?
    private var selectedIconColor: UIColor?
    private var selectedBackgroundColor: UIColor?
    private var selectedTitleFont: UIFont?
    private var normalImage: UIImage?
    private var normalTitle: String?
    private var normalTitleColor: UIColor?
    private var normalIconColor: UIColor?
    private var normalBackgroundColor: UIColor?
    private var normalTitleFont: UIFont?
    private var normalImageHidden = false
    private var normalTitleHidden = false
    private var normalHasSelectedTrait = false
    private var accessibilityValueBeforeBadge: String?
    private var appliedBadgeAccessibilityValue: String?
    // [EN] Read by the tests through KVC. [CN] 测试通过 KVC 读取。
    @objc private(set) var selectionIndicatorView: UIImageView?
    // Appearance layers (see cyl_applyAppearance()), keyed by titleColor / iconColor / backgroundColor / titleFont.
    // nil until the view is set up, so a call during the base class's initializer does nothing.
    private var appearanceBaselineValues = [String: Any]()
    private var appearanceExplicitValues = [String: Any]()
    private var appearanceAppliedValues: [String: Any]?
    private var appearanceNormalValues = [String: Any]()
    // The shared badge appearance values last applied; a label value that differs was set by the caller and is kept.
    private var appliedBadgeFont: UIFont?
    private var appliedBadgeTextColor: UIColor?
    private var appliedBadgeBackgroundColor: UIColor?

    // MARK: Life cycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        cyl_placeholderSetUp()
    }

    /**
     * [EN] Creates the view from a storyboard or nib, set up like `init(frame:)`: the `CYLPlaceholderStyleEmpty` icon,
     *      the "Nothing here yet" text (localized) in gray Body text style, a vertical layout and a hidden badge.
     * [CN] 从 storyboard 或 nib 创建视图，设置与 `init(frame:)` 相同：`CYLPlaceholderStyleEmpty` 图标、灰色 Body 文字样式的“暂无内容”
     *      （已本地化）文字、纵向布局，角标隐藏。
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        cyl_placeholderSetUp()
    }

    /**
     * Custom image and text; nil hides the corresponding content.
     */
    @objc(initWithImage:text:)
    public convenience init(image: UIImage?, text: String?) {
        self.init(frame: .zero)
        imageView.image = image
        imageView.isHidden = image == nil
        textLabel.text = text
        textLabel.isHidden = text == nil
    }

    /**
     * Uses independently selectable bundled art and localized text.
     */
    @objc(initWithStyle:message:)
    public convenience init(style: CYLPlaceholderStyle, message: CYLPlaceholderMessage) {
        self.init(image: CYLPlaceholderView.image(for: style), text: CYLPlaceholderView.localizedText(for: message))
    }

    /**
     * A custom string replaces the localized message; nil hides the label.
     */
    @objc(initWithStyle:text:)
    public convenience init(style: CYLPlaceholderStyle, text: String?) {
        self.init(image: CYLPlaceholderView.image(for: style), text: text)
    }

    /**
     * Reads one item dictionary from a local property list.
     */
    @objc(initWithItemContentsOfURL:imageBundle:error:)
    public convenience init(itemContentsOf url: URL, imageBundle: Bundle?) throws {
        if !url.isFileURL { throw CYLPlaceholderConfigurationFailure("The configuration URL must be a local file.") }
        let data = try Data(contentsOf: url)
        let attributes = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        guard let dictionary = attributes as? [AnyHashable: Any] else {
            throw CYLPlaceholderConfigurationFailure("The item configuration must be a dictionary.")
        }
        try self.init(itemAttributes: dictionary, imageBundle: imageBundle)
    }

    /**
     * Creates a FlatDesign-style item from CYLTabBarController-compatible item keys.
     * Images may be UIImage objects or names in imageBundle (nil uses the placeholder bundle).
     */
    @objc(initWithItemAttributes:imageBundle:error:)
    public convenience init(itemAttributes rawAttributes: [AnyHashable: Any], imageBundle: Bundle?) throws {
        var attributes = [String: Any]()
        for (key, value) in rawAttributes {
            guard let name = key.base as? String else {
                throw CYLPlaceholderConfigurationFailure("Item configuration keys must be strings.")
            }
            attributes[name] = value
        }
        if let frames = attributes[CYLPlaceholderItemImages], attributes[CYLPlaceholderItemImage] == nil {
            // [EN] Image frames (Android's IMAGES and DURATION) become one animated image; Reduce Motion keeps the first.
            // [CN] 图片帧（Android 的 IMAGES 与 DURATION）合成为一张动图；“减弱动态效果”时只保留第一帧。
            let failure = CYLPlaceholderConfigurationFailure("Item images must be a non-empty array of images, with a non-negative duration.")
            let frameArray = frames as? NSArray
            let list = frameArray?.compactMap { $0 as? UIImage } ?? []
            guard let count = frameArray?.count, count > 0, list.count == count else { throw failure }
            var durationNumber = 0.0
            if let duration = attributes[CYLPlaceholderItemAnimationDuration] {
                guard let number = (duration as? NSNumber)?.doubleValue, number.isFinite, number >= 0 else { throw failure }
                durationNumber = number
            }
            let seconds = durationNumber > 0 ? durationNumber : Double(list.count) * 0.1
            let image = (list.count == 1 || UIAccessibility.isReduceMotionEnabled) ? list.first :
                UIImage.animatedImage(with: list, duration: seconds)
            attributes[CYLPlaceholderItemImage] = image ?? list.first
        }
        let titleValue = attributes[CYLPlaceholderItemTitle]
        let imageValue = attributes[CYLPlaceholderItemImage]
        let style = attributes[CYLPlaceholderItemStyle]
        let message = attributes[CYLPlaceholderItemMessage]
        for key in [CYLPlaceholderItemStyle, CYLPlaceholderItemMessage] {
            guard let value = attributes[key] else { continue }
            let count = key == CYLPlaceholderItemStyle ? CYLPlaceholderStyle.count.rawValue : CYLPlaceholderMessage.count.rawValue
            guard let number = (value as? NSNumber)?.doubleValue, number.isFinite, number == number.rounded(.down),
                  number >= 0, number < Double(count) else {
                throw CYLPlaceholderConfigurationFailure("Invalid placeholder style or message index.")
            }
        }
        if (titleValue != nil && !(titleValue is String)) ||
            (imageValue != nil && !(imageValue is String) && !(imageValue is UIImage)) {
            throw CYLPlaceholderConfigurationFailure("The item title must be a string and image must be an image or image name.")
        }
        var title = titleValue as? String
        if title == nil, let message = message as? NSNumber {
            title = CYLPlaceholderView.localizedText(for: CYLPlaceholderMessage(rawValue: message.intValue) ?? .empty)
        }
        var image: UIImage?
        if let configured = imageValue as? UIImage {
            image = configured
        } else if let name = imageValue as? String {
            if name.hasPrefix("system:") {
                image = UIImage(systemName: String(name.dropFirst(7)))
            } else {
                guard let bundle = imageBundle ?? CYLPlaceholderResourceBundle() else {
                    throw CYLPlaceholderConfigurationFailure("The placeholder resource bundle was not found.")
                }
                image = UIImage(named: name, in: bundle, compatibleWith: nil)
            }
            if image == nil {
                throw CYLPlaceholderConfigurationFailure("Image '\(name)' was not found in the selected bundle.")
            }
        } else if let style = style as? NSNumber {
            image = CYLPlaceholderStyle(rawValue: style.intValue).flatMap { CYLPlaceholderView.image(for: $0) }
            if image == nil {
                throw CYLPlaceholderConfigurationFailure("The selected placeholder style could not be loaded.")
            }
        }
        var titleOffset = UIOffset.zero
        var imageOffset = UIOffset.zero
        var insets = UIEdgeInsets.zero
        do {
            if let value = attributes[CYLPlaceholderItemTitlePositionAdjustment] {
                guard let offset = CYLPlaceholderOffset(value) else { throw CYLPlaceholderConfigurationFailure("") }
                titleOffset = offset
            }
            if let value = attributes[CYLPlaceholderItemImagePositionAdjustment] {
                guard let offset = CYLPlaceholderOffset(value) else { throw CYLPlaceholderConfigurationFailure("") }
                imageOffset = offset
            }
            if let value = attributes[CYLPlaceholderItemImageInsets] {
                guard let parsed = CYLPlaceholderInsets(value) else { throw CYLPlaceholderConfigurationFailure("") }
                insets = parsed
            }
        } catch {
            throw CYLPlaceholderConfigurationFailure("Invalid item offset or image insets.")
        }
        var colors = [String: UIColor]()
        for key in [CYLPlaceholderItemTitleColor, CYLPlaceholderItemIconColor, CYLPlaceholderItemBackgroundColor,
                    CYLPlaceholderItemSelectedTitleColor, CYLPlaceholderItemSelectedIconColor,
                    CYLPlaceholderItemSelectedBackgroundColor, CYLPlaceholderItemTitleBackgroundColor,
                    CYLPlaceholderItemTitleBorderColor] {
            guard let value = attributes[key] else { continue }
            guard let color = CYLPlaceholderColor(value) else {
                throw CYLPlaceholderConfigurationFailure("Invalid color for \(key).")
            }
            colors[key] = color
        }
        for key in [CYLPlaceholderItemAnimationColors, CYLPlaceholderItemAnimationDarkColors,
                    CYLPlaceholderTypeKey.lottieDarkColors, CYLPlaceholderTypeKey.riveDarkColors] {
            guard let values = attributes[key] else { continue }
            guard let dictionary = values as? NSDictionary else {
                throw CYLPlaceholderConfigurationFailure("Invalid animation colors for \(key).")
            }
            for (path, value) in dictionary {
                guard let name = path as? String, !name.isEmpty, CYLPlaceholderColor(value) != nil else {
                    throw CYLPlaceholderConfigurationFailure("Invalid animation color entry for \(key).")
                }
            }
        }
        let font = attributes[CYLPlaceholderItemTitleFont].flatMap { CYLPlaceholderFont($0) }
        if attributes[CYLPlaceholderItemTitleFont] != nil && font == nil {
            throw CYLPlaceholderConfigurationFailure("Invalid title font.")
        }
        let selectedFont = attributes[CYLPlaceholderItemSelectedTitleFont].flatMap { CYLPlaceholderFont($0) }
        if attributes[CYLPlaceholderItemSelectedTitleFont] != nil && selectedFont == nil {
            throw CYLPlaceholderConfigurationFailure("Invalid selected title font.")
        }
        let selectedTitleValue = attributes[CYLPlaceholderItemSelectedTitle]
        if selectedTitleValue != nil && !(selectedTitleValue is String) {
            throw CYLPlaceholderConfigurationFailure("The selected title must be a string.")
        }
        let selectedImageValue = attributes[CYLPlaceholderItemSelectedImage]
        var selectedImage = selectedImageValue.flatMap { CYLPlaceholderConfiguredImage($0, imageBundle) }
        if selectedImageValue != nil && selectedImage == nil {
            throw CYLPlaceholderConfigurationFailure("The selected image could not be loaded.")
        }
        let darkImageValue = attributes[CYLPlaceholderItemDarkImage]
        let selectedDarkImageValue = attributes[CYLPlaceholderItemSelectedDarkImage]
        let darkImage = darkImageValue.flatMap { CYLPlaceholderConfiguredImage($0, imageBundle) }
        let selectedDarkImage = selectedDarkImageValue.flatMap { CYLPlaceholderConfiguredImage($0, imageBundle) }
        if (darkImageValue != nil && darkImage == nil) || (selectedDarkImageValue != nil && selectedDarkImage == nil) {
            throw CYLPlaceholderConfigurationFailure("A dark image could not be loaded.")
        }
        image = CYLPlaceholderAppearanceImage(image, darkImage)
        selectedImage = CYLPlaceholderAppearanceImage(selectedImage, selectedDarkImage)
        for key in [CYLPlaceholderItemAccessibilityIdentifier, CYLPlaceholderItemAccessibilityLabel,
                    CYLPlaceholderItemAccessibilityHint] where attributes[key] != nil && !(attributes[key] is String) {
            throw CYLPlaceholderConfigurationFailure("Invalid accessibility value for \(key).")
        }
        let titleBackgroundImageValue = attributes[CYLPlaceholderItemTitleBackgroundImage]
        let titleBackgroundImage = titleBackgroundImageValue.flatMap { CYLPlaceholderConfiguredImage($0, imageBundle) }
        if titleBackgroundImageValue != nil && titleBackgroundImage == nil {
            throw CYLPlaceholderConfigurationFailure("The title background image could not be loaded.")
        }
        var titleChromeNumbers: [CGFloat] = [0, 0, 0]
        let titleChromeNumberKeys = [CYLPlaceholderItemTitleBorderWidth, CYLPlaceholderItemTitleCornerRadius,
                                     CYLPlaceholderItemTitleMinimumWidth]
        for (index, key) in titleChromeNumberKeys.enumerated() {
            guard let value = attributes[key] else { continue }
            guard let number = (value as? NSNumber)?.doubleValue, number.isFinite, number >= 0, number <= 1000 else {
                throw CYLPlaceholderConfigurationFailure("Invalid value for \(key).")
            }
            titleChromeNumbers[index] = CGFloat(number)
        }
        var titleContentInsets = UIEdgeInsets.zero
        if let value = attributes[CYLPlaceholderItemTitleContentInsets] {
            guard let parsed = CYLPlaceholderInsets(value), parsed.top >= 0, parsed.left >= 0, parsed.bottom >= 0,
                  parsed.right >= 0 else {
                throw CYLPlaceholderConfigurationFailure("Invalid title content insets.")
            }
            titleContentInsets = parsed
        }
        let hasTitleChrome = titleBackgroundImage != nil || colors[CYLPlaceholderItemTitleBackgroundColor] != nil ||
            colors[CYLPlaceholderItemTitleBorderColor] != nil || titleChromeNumbers[0] > 0 || titleChromeNumbers[1] > 0 ||
            titleChromeNumbers[2] > 0 || titleContentInsets != .zero
        let interactionValue = attributes[CYLPlaceholderItemInteractionEnabled]
        if interactionValue != nil && !(interactionValue is NSNumber) {
            throw CYLPlaceholderConfigurationFailure("Interaction enabled must be a boolean.")
        }
        var highlightStyle = CYLPlaceholderTapHighlightStyle.dim
        if let value = attributes[CYLPlaceholderItemTapHighlightStyle] {
            guard let parsed = CYLPlaceholderTapHighlightStyleFromValue(value) else {
                throw CYLPlaceholderConfigurationFailure("The tap highlight style must be dim, shrink or none.")
            }
            highlightStyle = parsed
        }
        var horizontal = false
        let axisValue = attributes[CYLPlaceholderItemContentAxis]
        if let name = axisValue as? String, name == "horizontal" || name == "vertical" {
            horizontal = name == "horizontal"
        } else if let number = axisValue as? NSNumber,
                  number.intValue == NSLayoutConstraint.Axis.horizontal.rawValue ||
                    number.intValue == NSLayoutConstraint.Axis.vertical.rawValue {
            horizontal = number.intValue == NSLayoutConstraint.Axis.horizontal.rawValue
        } else if axisValue != nil {
            throw CYLPlaceholderConfigurationFailure("The content axis must be \"horizontal\" or \"vertical\".")
        }
        var repeatCount = 1
        if let value = attributes[CYLPlaceholderItemAnimationRepeatCount] {
            guard let parsed = CYLPlaceholderRepeatCountFromValue(value) else {
                throw CYLPlaceholderConfigurationFailure("The animation repeat count must be 0 (loop) or more, \"loop\" or \"once\".")
            }
            repeatCount = parsed
        }
        self.init(image: image, text: title)
        itemAttributes = attributes
        storedTapInteractionEnabled = (interactionValue as? NSNumber)?.boolValue ?? true
        tapHighlightStyle = highlightStyle
        storedAnimationRepeatCount = repeatCount
        if hasTitleChrome {
            let chrome = UIImageView(image: titleBackgroundImage)
            chrome.contentMode = .scaleToFill
            chrome.backgroundColor = colors[CYLPlaceholderItemTitleBackgroundColor]
            chrome.clipsToBounds = true
            chrome.isAccessibilityElement = false
            titleBackgroundView = chrome
            insertSubview(chrome, belowSubview: textLabel)
            titleBorderColor = colors[CYLPlaceholderItemTitleBorderColor]
            titleBorderWidth = titleChromeNumbers[0]
            titleCornerRadius = titleChromeNumbers[1]
            titleMinimumWidth = titleChromeNumbers[2]
            self.titleContentInsets = titleContentInsets
        }
        animationImageBundle = imageBundle
        // [EN] The base class shows it while selected. [CN] 选中时由基类显示。
        self.selectedImage = selectedImage
        selectedTitle = selectedTitleValue as? String
        selectedTitleColor = colors[CYLPlaceholderItemSelectedTitleColor]
        selectedIconColor = colors[CYLPlaceholderItemSelectedIconColor]
        selectedBackgroundColor = colors[CYLPlaceholderItemSelectedBackgroundColor]
        selectedTitleFont = selectedFont
        itemTitleOffset = titleOffset
        itemImageOffset = imageOffset
        itemImageInsets = insets
        self.horizontal = horizontal
        axis = horizontal ? .horizontal : .vertical
        if horizontal { textLabel.textAlignment = .natural }
        if let color = colors[CYLPlaceholderItemTitleColor] { textLabel.textColor = color }
        if let color = colors[CYLPlaceholderItemIconColor] { cyl_setIconColor(color) }
        if let color = colors[CYLPlaceholderItemBackgroundColor] { backgroundColor = color }
        if let font = font { textLabel.font = font }
        let explicitValues: [String: Any?] = [
            "titleColor": colors[CYLPlaceholderItemTitleColor],
            "iconColor": colors[CYLPlaceholderItemIconColor],
            "backgroundColor": colors[CYLPlaceholderItemBackgroundColor],
            "titleFont": font
        ]
        for (key, value) in explicitValues {
            guard let value = value else { continue }
            appearanceExplicitValues[key] = value
            appearanceAppliedValues?[key] = value
            appearanceNormalValues[key] = value
        }
        accessibilityIdentifier = attributes[CYLPlaceholderItemAccessibilityIdentifier] as? String
        // Determine if the placeholder should be an accessibility element.
        // It should be an element if it has explicit accessibility attributes or
        // if it has meaningful content (image or text) and no explicit accessibility
        // label is provided by the container.
        let hasExplicitAccessibility = attributes[CYLPlaceholderItemAccessibilityLabel] != nil ||
            attributes[CYLPlaceholderItemAccessibilityHint] != nil
        let hasContent = image != nil || !(title ?? "").isEmpty
        if hasExplicitAccessibility || hasContent {
            isAccessibilityElement = true
            accessibilityLabel = (attributes[CYLPlaceholderItemAccessibilityLabel] as? String) ?? title
            accessibilityHint = attributes[CYLPlaceholderItemAccessibilityHint] as? String
        }
        // Ensure subviews (imageView, textLabel) are not separate accessibility elements
        // when the placeholder itself is an accessibility element
        imageView.isAccessibilityElement = false
        textLabel.isAccessibilityElement = false
        cyl_configureAnimations()
        NotificationCenter.default.addObserver(self, selector: #selector(cyl_reduceMotionChanged(_:)),
                                               name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
        setNeedsLayout()
    }

    deinit {
        CYLPlaceholderResourceReporter.shared.removeSource(self)
        repeatTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    private func cyl_placeholderSetUp() {
        // [EN] The icon follows `tintColor` until a color is set (see `cyl_setIconColor`). [CN] 设置颜色之前图标跟随 `tintColor`（见 `cyl_setIconColor`）。
        cyl_setIconColor(nil)
        // [EN] See CYLPlaceholderItemImageView: relayout and the static image follow values set on the subviews.
        // [CN] 见 CYLPlaceholderItemImageView：子视图上设置的值会触发重新布局并同步静态图片。
        if object_getClass(imageView) == UIImageView.self { object_setClass(imageView, CYLPlaceholderItemImageView.self) }
        if object_getClass(titleLabel) == UILabel.self { object_setClass(titleLabel, CYLPlaceholderItemLabel.self) }
        // [EN] The base class makes every item a button for VoiceOver with the identifier "CYLAnimatedItemView" and its
        //      label hidden. A placeholder is not an element by default, its label reads on its own, and a tap event
        //      makes it a button (cyl_updateTapAccessibility), as before.
        // [CN] 基类把每个条目都设为带 "CYLAnimatedItemView" 标识的 VoiceOver 按钮并隐藏标签。占位图默认不是无障碍元素，标签单独朗读，设置点击事件后
        //      才是按钮（cyl_updateTapAccessibility），与以前相同。
        isAccessibilityElement = false
        accessibilityTraits = .none
        accessibilityIdentifier = nil
        imageView.accessibilityElementsHidden = false
        titleLabel.isAccessibilityElement = true
        axis = .vertical
        addTarget(self, action: #selector(cyl_handleTouchUpInside), for: .touchUpInside)
        imageView.clipsToBounds = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = CYLPlaceholderView.image(for: .empty)
        let label = titleLabel
        label.clipsToBounds = false
        label.text = CYLPlaceholderView.localizedText(for: .empty)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .gray
        // A text-style font (17 points at the default size), so the title follows Dynamic Type.
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        // The built-in values are the bottom appearance layer; values set directly on the labels later win.
        var applied = [String: Any]()
        for key in CYLPlaceholderAppearanceKeys {
            // The icon inherits the tint color unless a color is configured.
            let value: Any = key == "iconColor" ? NSNull() : (cyl_appearanceTargetValue(for: key) ?? NSNull())
            appearanceBaselineValues[key] = value
            applied[key] = value
            appearanceNormalValues[key] = value
        }
        appearanceAppliedValues = applied
        // A plain label: badge changes lay the item out explicitly, so the label must not invalidate layout itself.
        badgeLabel.textAlignment = .center
        let badgeAppearance = CYLPlaceholderBadgeAppearance.shared()
        badgeLabel.font = badgeAppearance.font
        badgeLabel.adjustsFontForContentSizeCategory = true
        badgeLabel.textColor = badgeAppearance.textColor
        badgeLabel.backgroundColor = badgeAppearance.backgroundColor
        appliedBadgeFont = badgeLabel.font
        appliedBadgeTextColor = badgeLabel.textColor
        appliedBadgeBackgroundColor = badgeLabel.backgroundColor
        badgeLabel.clipsToBounds = true
        badgeLabel.isHidden = true
        badgeLabel.isAccessibilityElement = true
        itemAttributes = [:]
        // Observe dynamic type changes
        NotificationCenter.default.addObserver(self, selector: #selector(cyl_contentSizeCategoryChanged(_:)),
                                               name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    // MARK: Title

    /**
     * [EN] The base class's title is the label's text, which this class (and apps) set directly.
     * [CN] 基类的标题即标签文字，本类（以及应用）会直接设置它。
     */
    open override dynamic var title: String? {
        get { titleLabel.text }
        set { super.title = newValue }
    }

    // MARK: Animation factories

    /**
     * [EN] Registers or removes a factory for a file extension, without a leading dot, as an animator of
     *      CYLTabBarController's shared `CYLTabBarItemAnimatorRegistry` that wins over the built-in animators for that
     *      extension. Extensions are case-insensitive. Existing views keep their current player until their configuration
     *      is reloaded. Returns NO for an invalid extension, or when the build has no animation engine (CocoaPods Core
     *      alone).
     * [CN] 为某个文件扩展名（不带点）注册或移除工厂：作为 CYLTabBarController 共享 `CYLTabBarItemAnimatorRegistry` 中的 animator，对该扩展名优先于
     *      内置 animator。扩展名不区分大小写。已有视图在重新加载配置前保持当前播放器。扩展名无效或工程中没有动画引擎（只有 CocoaPods Core）时返回 NO。
     */
    @discardableResult
    @objc(registerAnimationFactory:forFileExtension:)
    open class func registerAnimationFactory(_ factory: CYLPlaceholderAnimationFactory?, forFileExtension fileExtension: String) -> Bool {
        let invalid = CharacterSet.alphanumerics.inverted
        if fileExtension.isEmpty || (fileExtension as NSString).rangeOfCharacter(from: invalid).location != NSNotFound {
            NSLog("CYLTableViewPlaceHolder: invalid animation extension.")
            return false
        }
        #if CYL_ANIMATION_ENGINE_AVAILABLE
        if let factory = factory {
            CYLTabBarItemAnimatorRegistry.registerAnimator(CYLPlaceholderFactoryAnimator(fileExtension: fileExtension, factory: factory))
        } else {
            CYLTabBarItemAnimatorRegistry.unregisterAnimator(withIdentifier: CYLPlaceholderFactoryAnimator.identifier(forFileExtension: fileExtension))
        }
        return true
        #else
        NSLog("CYLTableViewPlaceHolder: animation factories need the animation engine; add an animation subspec.")
        return false
        #endif
    }

    // MARK: Static image

    func cyl_imageViewDidSetImage(_ image: UIImage?) {
        // [EN] The base class shows `image`, `selectedImage` or its placeholder in `imageView`; any other image was set by
        //      this class or the app, and becomes the base class's static image, so the base class keeps showing it.
        // [CN] 基类在 `imageView` 中显示 `image`、`selectedImage` 或占位图；其他图片由本类或应用设置，成为基类的静态图片，基类会继续显示它。
        if syncingImage || image === self.image { return }
        if let image = image, image === selectedImage || image === placeholderImage { return }
        syncingImage = true
        cyl_preservingIconVisibility {
            self.image = image
        }
        syncingImage = false
    }

    // [EN] YES while a ready animation covers the static image (the base class hides `imageView` then).
    // [CN] 就绪的动画覆盖静态图片时为 YES（此时基类隐藏 `imageView`）。
    private var cyl_animationCoversImage: Bool {
        #if CYL_ANIMATION_ENGINE_AVAILABLE
        guard let view = animationView else { return false }
        return !CYLTabBarItemAnimationIsLoading(view)
        #else
        return false
        #endif
    }

    // [EN] Runs `changes` (which let the base class update the icon) and keeps an icon the caller hid hidden: the base
    //      class shows `imageView` whenever no animation covers it.
    // [CN] 执行 `changes`（其中基类会更新图标），并保持调用方隐藏的图标仍然隐藏：没有动画覆盖时基类总是显示 `imageView`。
    private func cyl_preservingIconVisibility(_ changes: () -> Void) {
        let hiddenByCaller = imageView.isHidden && imageView.image != nil && !cyl_animationCoversImage
        changes()
        if hiddenByCaller && !cyl_animationCoversImage && !imageView.isHidden { imageView.isHidden = true }
    }

    // MARK: Selection

    /**
     * Enables the configured selected image, title, font and colors. Defaults to NO.
     */
    open override var isSelected: Bool {
        get { super.isSelected }
        set { cyl_setSelected(newValue) }
    }

    private func cyl_setSelected(_ selected: Bool) {
        if super.isSelected == selected { return }
        if selected {
            normalImage = imageView.image
            normalTitle = textLabel.text
            normalTitleColor = textLabel.textColor
            normalIconColor = ownedIconColor
            normalBackgroundColor = backgroundColor
            normalTitleFont = textLabel.font
            normalImageHidden = imageView.isHidden && !cyl_animationCoversImage
            normalTitleHidden = textLabel.isHidden
            normalHasSelectedTrait = accessibilityTraits.contains(.selected)
            // [EN] The base class shows `selectedImage` (the configured selected image) when there is one.
            // [CN] 有选中图片（配置的 `selectedImage`）时由基类显示。
            super.isSelected = true
            imageView.isHidden = cyl_animationCoversImage || (selectedImage == nil && normalImageHidden)
            if let title = selectedTitle {
                textLabel.text = title
                textLabel.isHidden = false
            }
            // Explicit selected values, then the selected appearance defaults, then the normal values.
            for key in CYLPlaceholderAppearanceKeys {
                let value = cyl_desiredAppearanceValue(for: key)
                cyl_setAppearanceTargetValue(value, for: key)
                appearanceAppliedValues?[key] = value ?? NSNull()
            }
            accessibilityTraits.insert(.selected)
        } else {
            super.isSelected = false
            imageView.image = normalImage
            imageView.isHidden = normalImageHidden || cyl_animationCoversImage
            textLabel.text = normalTitle
            textLabel.isHidden = normalTitleHidden
            textLabel.textColor = normalTitleColor
            cyl_setIconColor(normalIconColor)
            backgroundColor = normalBackgroundColor
            textLabel.font = normalTitleFont
            for key in CYLPlaceholderAppearanceKeys {
                let restored: Any = cyl_appearanceTargetValue(for: key) ?? NSNull()
                let normal = appearanceNormalValues[key]
                // Owned again only when the restored value is the one the appearance layers produced.
                if CYLPlaceholderSameValue(restored, normal) ||
                    (key == "iconColor" && normal is NSNull && CYLPlaceholderSameValue(restored, tintColor)) {
                    appearanceAppliedValues?[key] = normal
                    if normal is NSNull { cyl_setAppearanceTargetValue(nil, for: key) }
                } else {
                    appearanceAppliedValues?[key] = CYLPlaceholderCustomizedMarker
                }
            }
            cyl_applyAppearance()
            if !normalHasSelectedTrait { accessibilityTraits.remove(.selected) }
        }
        cyl_updateSelectionIndicator()
        setNeedsLayout()
    }

    private func cyl_updateSelectionIndicator() {
        // Use explicit selection indicator image, then appearance proxy default
        let indicatorImage = selectionIndicatorImage ?? defaultSelectionIndicatorImage
        let indicatorTintColor = selectionIndicatorTintColor ?? defaultSelectionIndicatorTintColor
        guard isSelected, var image = indicatorImage else {
            selectionIndicatorView?.removeFromSuperview()
            selectionIndicatorView = nil
            return
        }
        let indicator: UIImageView
        if let existing = selectionIndicatorView {
            indicator = existing
        } else {
            indicator = UIImageView()
            indicator.isUserInteractionEnabled = false
            indicator.isAccessibilityElement = false
            insertSubview(indicator, at: 0)
            selectionIndicatorView = indicator
        }
        if indicatorTintColor != nil && image.renderingMode != .alwaysOriginal {
            image = image.withRenderingMode(.alwaysTemplate)
        }
        indicator.image = image
        indicator.tintColor = indicatorTintColor
        indicator.contentMode = image.capInsets == .zero ? .center : .scaleToFill
        indicator.frame = itemFrame
    }

    // MARK: Badge

    // Applies `CYLPlaceholderBadgeAppearance` like CYLTabBarController's `_updateBadgeAppearance`: a value still equal to
    // the one applied before follows the shared appearance; one the caller changed on `badgeLabel` is left alone.
    private func cyl_applyBadgeAppearance() {
        let appearance = CYLPlaceholderBadgeAppearance.shared()
        let label = badgeLabel
        if let font = appearance.font, label.font.isEqual(appliedBadgeFont), !label.font.isEqual(font) {
            label.font = font
        }
        if let color = appearance.textColor, label.textColor.isEqual(appliedBadgeTextColor), !label.textColor.isEqual(color) {
            label.textColor = color
        }
        if let color = appearance.backgroundColor,
           label.backgroundColor === appliedBadgeBackgroundColor || label.backgroundColor?.isEqual(appliedBadgeBackgroundColor) == true,
           label.backgroundColor?.isEqual(color) != true {
            label.backgroundColor = color
        }
        if label.font.isEqual(appearance.font) { appliedBadgeFont = label.font }
        if label.textColor.isEqual(appearance.textColor) { appliedBadgeTextColor = label.textColor }
        if label.backgroundColor?.isEqual(appearance.backgroundColor) == true { appliedBadgeBackgroundColor = label.backgroundColor }
    }

    private func cyl_setBadgeValue(_ badgeValue: String?) {
        if storedBadgeValue == badgeValue { return }
        let appearance = CYLPlaceholderBadgeAppearance.shared()
        let animate = appearance.animatesChanges && appearance.animationDuration > 0 && badgeValue != nil &&
            window != nil && !UIAccessibility.isReduceMotionEnabled
        if storedBadgeValue == nil && badgeValue != nil {
            accessibilityValueBeforeBadge = accessibilityValue
        } else if storedBadgeValue != nil, let applied = appliedBadgeAccessibilityValue, accessibilityValue != applied {
            // The caller replaced the value while the badge was shown: keep theirs.
            accessibilityValueBeforeBadge = accessibilityValue
        }
        let showsChange = (storedBadgeValue == nil) != (badgeValue == nil)
        storedBadgeValue = badgeValue

        // State changes are synchronous; only the pop below is animated.
        badgeLabel.text = badgeValue
        badgeLabel.isHidden = badgeValue == nil
        if badgeValue != nil {
            cyl_applyBadgeAppearance()
            let container: UIView
            if let existing = badgeContainerView {
                container = existing
            } else {
                container = UIView(frame: bounds)
                container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                container.isUserInteractionEnabled = false
                container.isAccessibilityElement = false
                badgeContainerView = container
            }
            if container.superview !== self { addSubview(container) }
            if badgeLabel.superview !== container { container.addSubview(badgeLabel) }
        } else {
            badgeLabel.layer.removeAllAnimations()
            badgeLabel.transform = .identity
            badgeLabel.alpha = 1
            badgeLabel.removeFromSuperview()
            badgeContainerView?.removeFromSuperview()
        }
        // One announcement, no duplicates: when the placeholder is itself an accessibility element, the badge joins its
        // value and the badge label is hidden from VoiceOver; otherwise the badge label is read on its own.
        let placeholderIsAccessibilityElement = isAccessibilityElement
        badgeLabel.isAccessibilityElement = !placeholderIsAccessibilityElement
        // [EN] Now a direct subview of the control (the old inner item view is gone): hide it from the accessibility tree too,
        //      or it is still exposed beside the element.
        // [CN] 现在它直接是控件的子视图（原来的内部条目视图已删除）：同时从无障碍树中隐藏，否则仍会与元素并列出现。
        badgeLabel.accessibilityElementsHidden = placeholderIsAccessibilityElement
        badgeContainerView?.accessibilityElementsHidden = placeholderIsAccessibilityElement
        if let badgeValue = badgeValue {
            let description = badgeValue.isEmpty ?
                CYLPlaceholderLocalizedStringForKey("CYLPlaceholderBadgeNewContent", "New content") : badgeValue
            badgeLabel.accessibilityLabel = description
            let baseValue = accessibilityValueBeforeBadge ?? ""
            let value = (placeholderIsAccessibilityElement && !baseValue.isEmpty) ? "\(baseValue), \(description)" : description
            accessibilityValue = value
            appliedBadgeAccessibilityValue = value
        } else {
            if let applied = appliedBadgeAccessibilityValue, accessibilityValue == applied {
                accessibilityValue = accessibilityValueBeforeBadge
            }
            appliedBadgeAccessibilityValue = nil
            accessibilityValueBeforeBadge = nil
        }
        setNeedsLayout()
        if showsChange {
            // [EN] A badge that appears or disappears changes the accessibility tree: tell assistive technologies, or a
            //      cached tree (inside a semantic-group container, for example) keeps reading the old badge.
            //      nil keeps VoiceOver's focus where it is.
            // [CN] 角标出现或消失会改变无障碍树：通知辅助技术，否则缓存的树（例如语义分组容器中）会继续朗读旧角标。
            //      参数为 nil，VoiceOver 焦点保持不动。
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
        if animate {
            badgeLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            badgeLabel.alpha = 0.5
            UIView.animate(withDuration: TimeInterval(appearance.animationDuration), delay: 0,
                           options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                self.badgeLabel.transform = .identity
                self.badgeLabel.alpha = 1
            }, completion: nil)
        }
    }

    /**
     * Number badges use a maximum of 99; nonpositive numbers hide the badge.
     * Text badges require a nonempty string. Returns NO on invalid input.
     */
    @discardableResult
    @objc(showBadgeWithStyle:value:)
    open func showBadge(with style: CYLPlaceholderBadgeStyle, value: String?) -> Bool {
        switch style {
        case .none:
            badgeValue = nil
            return true
        case .dot:
            badgeValue = ""
            return true
        case .text:
            if let value = value, !value.isEmpty {
                badgeValue = value
                return true
            }
        case .number:
            if let value = value, !value.isEmpty, let number = CYLPlaceholderScanInt64(value) {
                badgeValue = number <= 0 ? nil : (number > 99 ? "99+" : String(number))
                return true
            }
        @unknown default:
            break
        }
        NSLog("CYLTableViewPlaceHolder: invalid badge style or value.")
        return false
    }

    // MARK: Traits and tint

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // A text-size change can arrive as a trait change only (no notification): re-measure title and badge.
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            setNeedsLayout()
        }
        if let previous = previousTraitCollection, traitCollection.userInterfaceStyle != previous.userInterfaceStyle {
            cyl_configureAnimations()
            cyl_updateAnimationPlayback()
        }
        // Update selection indicator for trait changes when selected
        if isSelected && (selectionIndicatorImage != nil || defaultSelectionIndicatorImage != nil) {
            cyl_updateSelectionIndicator()
        }
    }

    open override func tintColorDidChange() {
        super.tintColorDidChange()
        // [EN] The engine keeps the tint it was given (`applyIconTintColor`); give it the new one. [CN] 引擎保留收到的 tint（`applyIconTintColor`），把新的交给它。
        if ownedIconColor == nil { applyIconTintColor(tintColor) }
        // Like the FlatDesign button: an icon without an explicit or appearance color follows the tint color.
        cyl_applyAppearance()
    }

    // MARK: Appearance layers

    private func cyl_appearanceTargetValue(for key: String) -> Any? {
        switch key {
        case "titleColor": return textLabel.textColor
        case "iconColor": return ownedIconColor
        case "backgroundColor": return backgroundColor
        default: return textLabel.font
        }
    }

    private func cyl_setAppearanceTargetValue(_ value: Any?, for key: String) {
        let value = CYLPlaceholderNilIfNull(value)
        switch key {
        case "titleColor": textLabel.textColor = value as? UIColor
        case "iconColor": cyl_setIconColor(value as? UIColor)
        case "backgroundColor": backgroundColor = value as? UIColor
        default:
            if let font = value as? UIFont { textLabel.font = font }
        }
    }

    // YES when the value is still the one the appearance layers set (or the inherited tint for the icon).
    private func cyl_ownsAppearanceValue(_ current: Any?, for key: String) -> Bool {
        let applied = appearanceAppliedValues?[key]
        if key == "iconColor" && applied is NSNull { return CYLPlaceholderNilIfNull(current) == nil }
        return CYLPlaceholderSameValue(current, applied)
    }

    // Normal: explicit item value, appearance default, built-in value (the icon follows the tint color).
    private func cyl_normalAppearanceValue(for key: String) -> Any? {
        if let explicitValue = appearanceExplicitValues[key] { return explicitValue }
        let defaultValue: Any?
        switch key {
        case "titleColor": defaultValue = defaultTitleColor
        case "iconColor": defaultValue = defaultIconColor
        case "backgroundColor": defaultValue = defaultBackgroundColor
        default: defaultValue = defaultTitleFont
        }
        if let value = defaultValue { return value }
        return CYLPlaceholderNilIfNull(appearanceBaselineValues[key])
    }

    // Selected: explicit selected value, selected appearance default, the normal value.
    private func cyl_desiredAppearanceValue(for key: String) -> Any? {
        if !isSelected { return cyl_normalAppearanceValue(for: key) }
        let selectedValue: Any?
        switch key {
        case "titleColor": selectedValue = selectedTitleColor ?? defaultSelectedTitleColor
        case "iconColor": selectedValue = selectedIconColor ?? defaultSelectedIconColor
        case "backgroundColor": selectedValue = selectedBackgroundColor ?? defaultSelectedBackgroundColor
        default: selectedValue = selectedTitleFont ?? defaultSelectedTitleFont
        }
        if let value = selectedValue { return value }
        return cyl_normalSnapshot(for: key)
    }

    private func cyl_normalSnapshot(for key: String) -> Any? {
        switch key {
        case "titleColor": return normalTitleColor
        case "iconColor": return normalIconColor
        case "backgroundColor": return normalBackgroundColor
        default: return normalTitleFont
        }
    }

    private func cyl_setNormalSnapshot(_ value: Any?, for key: String) {
        switch key {
        case "titleColor": normalTitleColor = value as? UIColor
        case "iconColor": normalIconColor = value as? UIColor
        case "backgroundColor": normalBackgroundColor = value as? UIColor
        default: normalTitleFont = value as? UIFont
        }
    }

    // Re-applies the layers to every value the library still owns: one the caller set directly is left alone.
    private func cyl_applyAppearance() {
        guard appearanceAppliedValues != nil else { return }
        for key in CYLPlaceholderAppearanceKeys {
            let normal = cyl_normalAppearanceValue(for: key)
            if isSelected {
                // Keep the normal snapshot current, so deselecting shows the latest appearance.
                let snapshot = cyl_normalSnapshot(for: key)
                if CYLPlaceholderSameValue(snapshot, appearanceNormalValues[key]) && (normal != nil || key != "titleFont") {
                    cyl_setNormalSnapshot(normal, for: key)
                    appearanceNormalValues[key] = normal ?? NSNull()
                }
            }
            let current = cyl_appearanceTargetValue(for: key)
            if !cyl_ownsAppearanceValue(current, for: key) { continue }
            let desired = cyl_desiredAppearanceValue(for: key)
            if key == "titleFont" && desired == nil { continue }
            if !CYLPlaceholderSameValue(current, desired) { cyl_setAppearanceTargetValue(desired, for: key) }
            appearanceAppliedValues?[key] = desired ?? NSNull()
            if !isSelected { appearanceNormalValues[key] = desired ?? NSNull() }
        }
        cyl_updateSelectionIndicator()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if reportedResource != nil { CYLPlaceholderResourceReporter.shared.sourceDidMove(self) }
        cyl_applyAppearance()
    }

    // MARK: Animation file

    /**
     * [EN] Shows the animation file at `path` (a full path, or the name of a bundled animation) instead of the icon, at
     *      the icon's animation size (`CYLPlaceholderItemAnimationSize`, else 64 x 64 points), through the animator
     *      registered for its extension. NO, with the icon kept, when the file is missing or no animator plays it (always
     *      without an animation engine). The same as Android's `CYLPlaceholderView.setAnimationFile(path)`.
     * [CN] 用 `path` 处的动画文件（完整路径或内置动画名）代替图标显示，尺寸为图标的动画尺寸（`CYLPlaceholderItemAnimationSize`，否则为
     *      64 x 64 点），由该扩展名注册的动画器播放。文件不存在或没有动画器可播放时（没有动画引擎时总是如此）返回 NO，图标保持不变。与 Android 的
     *      `CYLPlaceholderView.setAnimationFile(path)` 相同。
     */
    @discardableResult
    @objc(setAnimationFile:)
    open func setAnimationFile(_ path: String) -> Bool {
        if path.isEmpty { return false }
        let resolved = (path as NSString).isAbsolutePath ? path : (CYLPlaceholderView.path(forBundledAnimation: path) ?? path)
        if !FileManager.default.fileExists(atPath: resolved) {
            cyl_applyResourceReport((path, "file not found"))
            return false
        }
        let previous = itemAttributes
        var attributes = previous
        for key in [CYLPlaceholderItemAnimationURL, CYLPlaceholderTypeKey.gifFilePath, CYLPlaceholderTypeKey.gifURL,
                    CYLPlaceholderTypeKey.lottieFilePath, CYLPlaceholderTypeKey.lottieURL, CYLPlaceholderTypeKey.pagFilePath,
                    CYLPlaceholderTypeKey.pagURL, CYLPlaceholderTypeKey.riveFilePath, CYLPlaceholderTypeKey.riveURL] {
            attributes.removeValue(forKey: key)
        }
        attributes[CYLPlaceholderItemAnimationFilePath] = resolved
        if attributes[CYLPlaceholderItemAnimationSize] == nil { attributes[CYLPlaceholderItemAnimationSize] = [64, 64] }
        itemAttributes = attributes
        cyl_configureAnimations()
        if animationView == nil {
            // [EN] No animator plays it (always the case without the engine): keep the icon, as Android does.
            // [CN] 没有动画器可播放（没有引擎时总是如此）：保留图标，与 Android 相同。
            itemAttributes = previous
            cyl_configureAnimations()
            return false
        }
        setNeedsLayout()
        return true
    }

    // [EN] The animation file of the item attributes (the engine-specific keys first, then the generic ones), with its
    //      size and options; nil when there is none or it is invalid.
    // [CN] item 属性中的动画文件（先看各引擎专用的 key，再看通用 key）及其尺寸与选项；没有或无效时返回 nil。
    private func cyl_animationURL(from attributes: [String: Any]) -> (url: URL, size: CGSize, options: NSDictionary, resource: String)? {
        let sources = [
            [CYLPlaceholderTypeKey.gifURL, CYLPlaceholderTypeKey.gifFilePath, CYLPlaceholderTypeKey.gifSize],
            [CYLPlaceholderTypeKey.lottieURL, CYLPlaceholderTypeKey.lottieFilePath, CYLPlaceholderTypeKey.lottieSize],
            [CYLPlaceholderTypeKey.pagURL, CYLPlaceholderTypeKey.pagFilePath, CYLPlaceholderTypeKey.pagSize],
            [CYLPlaceholderTypeKey.riveURL, CYLPlaceholderTypeKey.riveFilePath, CYLPlaceholderTypeKey.riveSize],
            [CYLPlaceholderItemAnimationURL, CYLPlaceholderItemAnimationFilePath, CYLPlaceholderItemAnimationSize]
        ]
        var value: Any?
        var sizeValue: Any?
        for keys in sources {
            value = attributes[keys[0]] ?? attributes[keys[1]]
            if value != nil {
                sizeValue = attributes[keys[2]] ?? attributes[CYLPlaceholderItemAnimationSize]
                break
            }
        }
        guard let source = value else { return nil }
        var url: URL?
        if let configured = source as? URL {
            url = configured
        } else if var path = source as? String, !path.isEmpty {
            if path.contains("://") {
                url = URL(string: path)
            } else {
                if !(path as NSString).isAbsolutePath {
                    let bundle = animationImageBundle ?? Bundle.main
                    path = bundle.path(forResource: (path as NSString).deletingPathExtension,
                                       ofType: (path as NSString).pathExtension) ?? path
                }
                url = URL(fileURLWithPath: path)
            }
        }
        guard let fileURL = url else {
            NSLog("CYLTableViewPlaceHolder: invalid animation file.")
            return nil
        }
        // [EN] Without a configured size: the static image's size, else 80 x 80. [CN] 未配置尺寸时：静态图片的尺寸，否则为 80 x 80。
        var size = image?.size ?? CGSize(width: 80, height: 80)
        if let boxed = CYLPlaceholderValue(sizeValue, hasTypeOf: NSValue(cgSize: .zero)) {
            size = boxed.cgSizeValue
        } else if sizeValue != nil, let numbers = CYLPlaceholderNumbers(sizeValue, [["width", "w"], ["height", "h"]]) {
            size = CGSize(width: numbers[0], height: numbers[1])
        } else if sizeValue != nil {
            NSLog("CYLTableViewPlaceHolder: invalid animation size.")
            return nil
        }
        if !size.width.isFinite || !size.height.isFinite || size.width <= 0 || size.height <= 0 ||
            size.width > 1000 || size.height > 1000 {
            NSLog("CYLTableViewPlaceHolder: invalid animation size.")
            return nil
        }
        let optionsValue = attributes[CYLPlaceholderItemAnimationOptions] ?? NSDictionary()
        guard let options = optionsValue as? NSDictionary else {
            NSLog("CYLTableViewPlaceHolder: animation options must be a dictionary.")
            return nil
        }
        cyl_validateAnimationOptions(options, forExtension: fileURL.pathExtension.lowercased())
        let resource = (source as? String) ?? fileURL.absoluteString
        return (CYLPlaceholderAnimationURLWithOptions(fileURL, options), size, options, resource)
    }

    // [EN] Color overrides for the current appearance: `CYLPlaceholderItemAnimationColors`, plus the dark colors in Dark
    //      Mode. [CN] 当前外观下的颜色覆盖：`CYLPlaceholderItemAnimationColors`，深色模式下再加上深色颜色。
    private func cyl_animationColors(for attributes: [String: Any], url: URL) -> [String: UIColor] {
        var animationColors = [String: UIColor]()
        var colorSources = [Any]()
        if let colors = attributes[CYLPlaceholderItemAnimationColors] { colorSources.append(colors) }
        if traitCollection.userInterfaceStyle == .dark {
            if let colors = attributes[CYLPlaceholderItemAnimationDarkColors] { colorSources.append(colors) }
            let fileExtension = url.pathExtension.lowercased()
            let specificKey = fileExtension == "json" ? CYLPlaceholderTypeKey.lottieDarkColors :
                (fileExtension == "riv" ? CYLPlaceholderTypeKey.riveDarkColors : nil)
            if let key = specificKey, let colors = attributes[key] { colorSources.append(colors) }
        }
        for source in colorSources {
            guard let dictionary = source as? NSDictionary else { continue }
            for (path, value) in dictionary {
                var color = CYLPlaceholderColor(value)
                color = color?.resolvedColor(with: traitCollection)
                if let name = path as? String, let resolved = color { animationColors[name] = resolved }
            }
        }
        return animationColors
    }

    private func cyl_configureAnimations() {
        var attributes = itemAttributes
        if traitCollection.userInterfaceStyle == .dark {
            let pairs = [
                [CYLPlaceholderTypeKey.gifURL, CYLPlaceholderTypeKey.gifFilePath, CYLPlaceholderTypeKey.gifDarkURL,
                 CYLPlaceholderTypeKey.gifDarkFilePath],
                [CYLPlaceholderTypeKey.lottieURL, CYLPlaceholderTypeKey.lottieFilePath, CYLPlaceholderTypeKey.lottieDarkURL,
                 CYLPlaceholderTypeKey.lottieDarkFilePath],
                [CYLPlaceholderTypeKey.pagURL, CYLPlaceholderTypeKey.pagFilePath, CYLPlaceholderTypeKey.pagDarkURL,
                 CYLPlaceholderTypeKey.pagDarkFilePath],
                [CYLPlaceholderTypeKey.riveURL, CYLPlaceholderTypeKey.riveFilePath, CYLPlaceholderTypeKey.riveDarkURL,
                 CYLPlaceholderTypeKey.riveDarkFilePath],
                [CYLPlaceholderItemAnimationURL, CYLPlaceholderItemAnimationFilePath, CYLPlaceholderItemAnimationDarkURL,
                 CYLPlaceholderItemAnimationDarkFilePath]
            ]
            for keys in pairs {
                let darkURL = attributes[keys[2]]
                let darkPath = attributes[keys[3]]
                if darkURL != nil || darkPath != nil {
                    attributes.removeValue(forKey: keys[0])
                    attributes.removeValue(forKey: keys[1])
                    if let darkURL = darkURL {
                        attributes[keys[0]] = darkURL
                    } else {
                        attributes[keys[1]] = darkPath
                    }
                }
            }
        }
        let animation = cyl_animationURL(from: attributes)
        animationContentMode = CYLPlaceholderAnimationContentMode(animation?.options)
        animationColors = animation.map { cyl_animationColors(for: attributes, url: $0.url) }
        // [EN] The `animationSpeed` option is the per-item form of CYLTabBarController's `tabBarItemAnimationSpeed`; a speed
        //      set later with setPlaceholderAnimationSpeed(_:) wins.
        // [CN] `animationSpeed` 选项是 CYLTabBarController `tabBarItemAnimationSpeed` 的单项形式；之后用 setPlaceholderAnimationSpeed(_:) 设置的速度优先。
        let speedOption = animation?.options["animationSpeed"]
        let speed = (speedOption as? NSNumber)?.doubleValue ?? (speedOption as? NSString)?.doubleValue ?? .nan
        let validSpeed = speedOption != nil && speed.isFinite && speed > 0
        if speedOption != nil && !validSpeed { NSLog("CYLTableViewPlaceHolder: animationSpeed must be positive.") }
        optionAnimationSpeed = validSpeed ? CGFloat(speed) : nil
        super.animationSpeed = explicitAnimationSpeed ?? optionAnimationSpeed ?? 1
        super.animationLoops = animationRepeatCount == 0
        itemAnimationSize = animation?.size ?? .zero
        cyl_preservingIconVisibility {
            // [EN] Clear first, so the new size applies and the file is always loaded again (a trait change, a new file).
            // [CN] 先清空，使新尺寸生效并总是重新加载文件（外观变化、新文件）。
            self.animationURL = nil
            if let animation = animation {
                self.iconSize = animation.size
                self.animationURL = animation.url
            }
        }
        cyl_reportMissingResource(of: animation?.url, named: animation?.resource)
        setNeedsLayout()
    }

    // [EN] Names a missing or unreadable animation file to the reporter (the red status bar); the engine swallows that
    //      error. A resource that loads, changes or goes away clears its entry. Without the runtime a static image shows,
    //      which is intended, so that is not reported. [CN] 把缺失或不可读的动画文件报告给红色状态条（引擎会吞掉这个错误）；
    //      资源加载成功、更换或消失时清除其条目。没有运行时则显示静态图片（预期行为），不报告。
    private func cyl_reportMissingResource(of url: URL?, named resource: String?) {
        var missing: (name: String, reason: String)?
        if let url = url, let resource = resource {
            let file = CYLPlaceholderAnimationFileURL(url)
            if file.isFileURL {
                if !FileManager.default.fileExists(atPath: file.path) {
                    missing = (resource, "file not found")
                } else if !FileManager.default.isReadableFile(atPath: file.path) {
                    missing = (resource, "unreadable")
                }
            }
        }
        cyl_applyResourceReport(missing)
    }

    private func cyl_applyResourceReport(_ missing: (name: String, reason: String)?) {
        let reporter = CYLPlaceholderResourceReporter.shared
        let name = missing.map { CYLPlaceholderResourceReporter.shortName(of: $0.name) }
        if let old = reportedResource, old != name { reporter.resolve(resource: old, source: self) }
        let changed = reportedResource != name
        reportedResource = name
        guard let missing = missing, let shortName = name else { return }
        reporter.report(resource: missing.name, reason: missing.reason, source: self)
        if changed { onResourceMissing?(shortName, missing.reason) }
    }

    /**
     * [EN] Builds the animation view again, keeping an icon the caller hid hidden, then applies the item's content mode,
     *      colors and playback policy.
     * [CN] 重新创建动画视图（保持调用方隐藏的图标仍隐藏），再应用 item 的缩放方式、颜色与播放策略。
     */
    open override func reloadAnimation() {
        cyl_stopRepeatTimer()
        cyl_preservingIconVisibility {
            super.reloadAnimation()
        }
        cyl_configureAnimationPlayer()
        cyl_updateAnimationPlayback()
    }

    // [EN] Applies what the base class does not: the content mode and the color overrides of the item attributes.
    // [CN] 应用基类不处理的部分：item 属性中的缩放方式与颜色覆盖。
    private func cyl_configureAnimationPlayer() {
        #if CYL_ANIMATION_ENGINE_AVAILABLE
        guard let view = animationView, let player = animationPlayer else { return }
        view.contentMode = animationContentMode
        if let colors = animationColors, !colors.isEmpty {
            if player.responds(to: #selector(CYLTabBarItemAnimationPlayer.applyColors(_:traitCollection:))) {
                player.applyColors?(colors, traitCollection: traitCollection)
            } else {
                NSLog("CYLTableViewPlaceHolder: animation color overrides are not supported by this player.")
            }
        }
        if (explicitAnimationSpeed != nil || optionAnimationSpeed != nil) &&
            !player.responds(to: #selector(setter: CYLTabBarItemAnimationPlayer.animationSpeed)) {
            NSLog("CYLTableViewPlaceHolder: this animation does not support a playback speed.")
        }
        if animationRepeatCount != 1 && !player.responds(to: #selector(setter: CYLTabBarItemAnimationPlayer.loops)) &&
            !player.responds(to: #selector(getter: CYLTabBarItemAnimationPlayer.progress)) {
            NSLog("CYLTableViewPlaceHolder: this animation does not support a repeat count of %ld; it plays as its file defines.",
                  animationRepeatCount)
        }
        #endif
    }

    #if CYL_ANIMATION_ENGINE_AVAILABLE
    /**
     * [EN] The file of a loading animation arrived: the base class shows it, then the playback policy applies.
     * [CN] 加载中的动画拿到了文件：基类显示动画，然后应用播放策略。
     */
    open override func cylAnimationViewDidLoad(_ animationView: UIView) {
        super.cylAnimationViewDidLoad(animationView)
        if animationView === self.animationView { cyl_updateAnimationPlayback() }
    }

    /**
     * [EN] The animation failed: the base class drops it, keeping an icon the caller hid hidden.
     * [CN] 动画失败：基类移除动画，并保持调用方隐藏的图标仍隐藏。
     */
    open override func cylAnimationViewDidFail(_ animationView: UIView, error: Error?) {
        if animationView === self.animationView { cyl_stopRepeatTimer() }
        cyl_preservingIconVisibility {
            super.cylAnimationViewDidFail(animationView, error: error)
        }
        setNeedsLayout()
    }
    #endif

    // MARK: Measuring and layout

    // [EN] The size an animation is laid out at. [CN] 动画的布局尺寸。
    private var cyl_animationBoxSize: CGSize {
        if itemAnimationSize.width > 0 && itemAnimationSize.height > 0 { return itemAnimationSize }
        if iconSize.width > 0 && iconSize.height > 0 { return iconSize }
        return CGSize(width: 24, height: 24)
    }

    // [EN] YES when the item attributes configure an animation file: its size is then the icon's, whatever shows in it (the
    //      animation, or the static image or placeholder standing in for it, aspect fit), so the layout is the same with or
    //      without an animation engine.
    // [CN] item 属性配置了动画文件时为 YES：此时图标尺寸即动画尺寸，无论其中显示的是动画，还是代替它的静态图片或占位图（等比缩放），因此有无动画引擎布局都相同。
    private var cyl_reservesAnimationBox: Bool {
        itemAnimationSize.width > 0 && itemAnimationSize.height > 0
    }

    // [EN] YES when the animation view shows: it is hidden only with a static image the caller hid.
    // [CN] 动画视图是否显示：只有在调用方隐藏了静态图片时才隐藏。
    private var cyl_showsAnimationView: Bool {
        animationView != nil && (imageView.image == nil || !imageView.isHidden || cyl_animationCoversImage)
    }

    // [EN] The title offset: the item's own, else the appearance's, as in CYLFlatDesignTabBarButton.
    // [CN] 标题偏移：优先使用 item 自己的，否则使用外观的，与 CYLFlatDesignTabBarButton 相同。
    private var cyl_titleOffset: UIOffset {
        itemTitleOffset == .zero ? defaultTitlePositionAdjustment : itemTitleOffset
    }

    private func cyl_textSize(_ text: String, width: CGFloat, font: UIFont) -> CGSize {
        (text as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                        options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size
    }

    // The item's content (image or animation, gap, title with its chrome) measured for a width, shared by the layout and
    // the intrinsic content size so the two cannot disagree.
    private func cyl_itemSize(forWidth width: CGFloat) -> CGSize {
        let showAnimation = cyl_showsAnimationView
        let hasImage = (imageView.image != nil && !imageView.isHidden) || showAnimation
        let text = textLabel.text ?? ""
        let hasTitle = !text.isEmpty && !textLabel.isHidden
        let insets = hasTitle ? titleContentInsets : .zero
        let textWidth = max(0, width - insets.left - insets.right)
        let titleSize = hasTitle ? cyl_textSize(text, width: textWidth, font: textLabel.font) : .zero
        let imageSize = (showAnimation || (hasImage && cyl_reservesAnimationBox)) ? cyl_animationBoxSize :
            (hasImage ? (imageView.image?.size ?? .zero) : .zero)
        if horizontal {
            let imageInsets = itemImageInsets
            let icon = hasImage ? CGSize(width: max(0, imageSize.width - imageInsets.left - imageInsets.right),
                                         height: max(0, imageSize.height - imageInsets.top - imageInsets.bottom)) : .zero
            let gap = hasImage && hasTitle ? CYLPlaceholderHorizontalSpacing : 0
            let measured = hasTitle ? cyl_textSize(text, width: max(0, width - icon.width - gap), font: textLabel.font) : .zero
            return CGSize(width: icon.width + gap + ceil(measured.width), height: max(icon.height, ceil(measured.height)))
        }
        var height = imageSize.height + (hasImage && hasTitle ? 24 : 0) + ceil(titleSize.height) + (hasImage && hasTitle ? 2 : 0)
        var titleWidth: CGFloat = 0
        if hasTitle {
            height += insets.top + insets.bottom
            titleWidth = max(ceil(titleSize.width) + insets.left + insets.right, titleMinimumWidth)
        }
        return CGSize(width: max(imageSize.width, titleWidth), height: height)
    }

    // [EN] The margin used for a bounds width: `contentMargin`, reduced when the view is too narrow for the content plus
    //      both margins. A refresh icon of 30 points left a zero-width item before, so its animation kept its first frame,
    //      starting at the icon's center, and covered the text beside it.
    // [CN] 某个宽度下实际使用的边距：`contentMargin`，视图放不下内容加两侧边距时缩小。之前 30 点的刷新图标会得到零宽度的 item，动画停留在
    //      初始 frame（从图标中心开始），盖住旁边的文字。
    private func cyl_margin(forWidth width: CGFloat) -> CGFloat {
        let margin = max(0, contentMargin)
        // [EN] Text wraps to the space inside the margins; only content that cannot shrink (an image or animation) wider
        //      than that space takes margin away. [CN] 文字在边距内换行；只有无法缩小且超出该空间的内容（图片或动画）才会占用边距。
        let content = ceil(cyl_itemSize(forWidth: max(0, width - 2 * margin)).width)
        if content <= width - 2 * margin { return margin }
        return max(0, (width - content) / 2)
    }

    /**
     * [EN] The content's size for a width limit (the item with its title chrome). [CN] 给定宽度上限时内容的尺寸（含标题装饰）。
     */
    open override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        cyl_itemSize(forWidth: max(0, size.width))
    }

    /**
     * [EN] UIView's behavior, as before: the view keeps its size. With `reportsContentSize` it reports the content for
     *      the width limit instead (as `intrinsicContentSize` does), so a container that sizes its items with
     *      `sizeThatFits:` (CYLTabBarController's CYLAnimatedItemStackView, which lays out CYLPlaceholderStackView) gives
     *      the icon and the title their room.
     * [CN] 与以前一样采用 UIView 的行为：视图保持自身尺寸。`reportsContentSize` 为 YES 时改为报告该宽度上限下的内容尺寸（与
     *      `intrinsicContentSize` 相同），使用 `sizeThatFits:` 计算条目尺寸的容器（CYLTabBarController 的 CYLAnimatedItemStackView，
     *      CYLPlaceholderStackView 用它布局）因此能给图标和标题留出空间。
     */
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard reportsContentSize else { return bounds.size }
        let limit = size.width > 0 && size.width.isFinite ? size.width : 0
        return cyl_reportedContentSize(maxWidth: limit)
    }

    /**
     * [EN] No intrinsic size unless `reportsContentSize` is YES. [CN] 除非 `reportsContentSize` 为 YES，否则没有固有尺寸。
     */
    open override var intrinsicContentSize: CGSize {
        if !reportsContentSize { return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric) }
        return cyl_reportedContentSize(maxWidth: 0)
    }

    /**
     * [EN] The content with its margins within `maxWidth`; 0 uses `preferredMaxLayoutWidth`, else the screen width.
     * [CN] `maxWidth` 内带边距的内容尺寸；0 时使用 `preferredMaxLayoutWidth`，否则使用屏幕宽度。
     */
    private func cyl_reportedContentSize(maxWidth limit: CGFloat) -> CGSize {
        let maxWidth = limit > 0 ? limit : (preferredMaxLayoutWidth > 0 ? preferredMaxLayoutWidth : UIScreen.main.bounds.width)
        let margin = max(0, contentMargin)
        let size = cyl_itemSize(forWidth: max(0, maxWidth - 2 * margin))
        if size.height <= 0 { return .zero }
        return CGSize(width: min(maxWidth, ceil(size.width) + 2 * margin), height: ceil(size.height))
    }

    /**
     * [EN] Centers the item (the icon or animation, the title with its chrome, the badge) inside the margins.
     * [CN] 在边距内居中放置条目（图标或动画、带装饰的标题、角标）。
     */
    open override func layoutContent(in rect: CGRect) {
        if rect.isEmpty { return }
        let width = max(0, rect.width - 2 * cyl_margin(forWidth: rect.width))
        let itemHeight = cyl_itemSize(forWidth: width).height
        let item = CGRect(x: rect.minX + (rect.width - width) / 2, y: rect.minY + (rect.height - itemHeight) / 2,
                          width: width, height: itemHeight)
        itemFrame = item
        selectionIndicatorView?.frame = item
        if item.isEmpty { return }
        cyl_layoutItem(in: item)
    }

    // UI adapted from CYLFlatDesignTabBarButton, CYLTabBarController (MIT).
    // Copyright (c) 2026 CYLTabBarController, https://github.com/ChenYilong/CYLTabBarController.
    private func cyl_layoutItem(in item: CGRect) {
        let imageView = self.imageView
        let titleLabel = self.titleLabel
        let animationView = self.animationView
        // [EN] The base class hides the image view under a ready animation, which is the same flag as a caller hiding the
        //      icon, so the layout must not read it as "no icon" and hide the animation too.
        // [CN] 基类会在就绪的动画下隐藏图片视图，这与调用方隐藏图标是同一个属性，因此布局不能把它当作“没有图标”而把动画也隐藏。
        let imageHiddenByCaller = imageView.isHidden && !cyl_animationCoversImage
        animationView?.isHidden = imageView.image != nil && imageHiddenByCaller
        let animationShows = animationView.map { !$0.isHidden } ?? false
        let isShowImageView = (imageView.image != nil && !imageView.isHidden) || animationShows
        let isShowTitleLabel = !(titleLabel.text ?? "").isEmpty && !titleLabel.isHidden
        var box = CGSize.zero
        if animationShows || (isShowImageView && cyl_reservesAnimationBox) {
            box = cyl_animationBoxSize
        } else if isShowImageView {
            box = imageView.image?.size ?? .zero
        }

        if horizontal {
            cyl_layoutHorizontally(in: item, iconBox: box, showingImage: isShowImageView, title: isShowTitleLabel)
            cyl_layoutBadge(anchoredToImage: isShowImageView)
            return
        }

        let itemWidth = item.width
        let itemHeight = item.height
        // [EN] Title chrome (background, border, padding) applies only to a shown title; with zero insets the layout is
        // the same as without chrome.
        // [CN] 标题装饰（背景、边框、内边距）只作用于显示中的标题；内边距为零时布局与没有装饰时相同。
        let titleInsets = isShowTitleLabel ? titleContentInsets : .zero
        let titleAreaWidth = max(0, itemWidth - titleInsets.left - titleInsets.right)
        let title = isShowTitleLabel ? (titleLabel.text ?? "") : "height"
        let titleSize = cyl_textSize(title, width: titleAreaWidth, font: titleLabel.font)
        let titleLabelWidth = min(titleAreaWidth, ceil(titleSize.width))
        let titleLabelHeight = ceil(titleSize.height)
        var titleLabelX = (itemWidth - titleLabelWidth) / 2
        var titleLabelY = itemHeight - titleLabelHeight - 2 - titleInsets.bottom
        if !isShowImageView {
            titleLabelY = titleInsets.top + (itemHeight - titleInsets.top - titleInsets.bottom - titleLabelHeight) / 2
        }
        let titleOffset = cyl_titleOffset
        titleLabelX += titleOffset.horizontal
        titleLabelY += titleOffset.vertical
        titleLabel.frame = CGRect(x: item.minX + titleLabelX, y: item.minY + titleLabelY,
                                  width: titleLabelWidth, height: titleLabelHeight)
        if let chromeView = titleBackgroundView {
            chromeView.isHidden = !isShowTitleLabel
            if isShowTitleLabel {
                let chromeWidth = min(itemWidth, max(titleLabelWidth + titleInsets.left + titleInsets.right, titleMinimumWidth))
                let chrome = CGRect(x: titleLabel.frame.midX - chromeWidth / 2, y: titleLabel.frame.minY - titleInsets.top,
                                    width: chromeWidth, height: titleLabelHeight + titleInsets.top + titleInsets.bottom)
                chromeView.frame = chrome
                chromeView.layer.cornerRadius = min(max(0, titleCornerRadius), chrome.height / 2)
                chromeView.layer.borderWidth = titleBorderWidth
                var borderColor = titleBorderColor
                borderColor = borderColor?.resolvedColor(with: traitCollection)
                chromeView.layer.borderColor = borderColor?.cgColor
                insertSubview(chromeView, belowSubview: titleLabel)
            }
        }

        if isShowImageView {
            var imageViewX = (itemWidth - box.width) / 2
            var imageViewY = (titleLabel.frame.minY - item.minY - titleInsets.top - box.height) / 2
            if !isShowTitleLabel { imageViewY = (itemHeight - box.height) / 2 }
            imageViewX += itemImageOffset.horizontal
            imageViewY += itemImageOffset.vertical
            imageView.frame = CGRect(x: item.minX + imageViewX, y: item.minY + imageViewY,
                                     width: max(0, box.width - itemImageInsets.left - itemImageInsets.right),
                                     height: max(0, box.height - itemImageInsets.top - itemImageInsets.bottom))
            animationView?.frame = imageView.frame
        } else {
            imageView.frame = CGRect(origin: item.origin, size: .zero)
        }
        cyl_layoutBadge(anchoredToImage: isShowImageView)
    }

    // [EN] The icon at the leading edge, then the title; both centered vertically. [CN] 图标在前缘，标题在后，二者垂直居中。
    private func cyl_layoutHorizontally(in item: CGRect, iconBox box: CGSize, showingImage showImage: Bool, title showTitle: Bool) {
        let width = item.width
        let height = item.height
        var imageSize = CGSize.zero
        if showImage {
            imageSize = CGSize(width: max(0, box.width - itemImageInsets.left - itemImageInsets.right),
                               height: max(0, box.height - itemImageInsets.top - itemImageInsets.bottom))
        }
        let titleX = showImage ? imageSize.width + CYLPlaceholderHorizontalSpacing : 0
        let titleWidth = max(0, width - titleX)
        var titleHeight: CGFloat = 0
        if showTitle {
            titleHeight = ceil(cyl_textSize(titleLabel.text ?? "", width: titleWidth, font: titleLabel.font).height)
        }
        let rightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        var imageFrame = CGRect(x: 0, y: (height - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
        var titleFrame = CGRect(x: titleX, y: (height - titleHeight) / 2, width: titleWidth, height: titleHeight)
        if rightToLeft {
            imageFrame.origin.x = width - imageFrame.maxX
            titleFrame.origin.x = width - titleFrame.maxX
        }
        imageFrame = imageFrame.offsetBy(dx: itemImageOffset.horizontal, dy: itemImageOffset.vertical)
        let titleOffset = cyl_titleOffset
        titleFrame = titleFrame.offsetBy(dx: titleOffset.horizontal, dy: titleOffset.vertical)
        imageFrame = imageFrame.offsetBy(dx: item.minX, dy: item.minY)
        titleFrame = titleFrame.offsetBy(dx: item.minX, dy: item.minY)
        imageView.frame = showImage ? imageFrame : CGRect(origin: item.origin, size: .zero)
        animationView?.frame = imageView.frame
        titleLabel.textAlignment = .natural
        titleLabel.frame = showTitle ? titleFrame : CGRect(origin: item.origin, size: .zero)
        titleBackgroundView?.isHidden = true
    }

    private func cyl_layoutBadge(anchoredToImage isShowImageView: Bool) {
        // Badge dimensions and top-right placement follow CYLBadgeView (MIT).
        guard !badgeLabel.isHidden else { return }
        let appearance = CYLPlaceholderBadgeAppearance.shared()
        let insets = appearance.contentInsets
        let dot = (badgeLabel.text ?? "").isEmpty
        var size = dot ? CGSize(width: 8, height: 8) :
            badgeLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude))
        if !dot {
            size.height = ceil(size.height) + insets.top + insets.bottom
            size.width = max(size.height, ceil(size.width) + insets.left + insets.right)
        }
        let anchor = isShowImageView ? imageView.frame : titleLabel.frame
        badgeLabel.bounds = CGRect(origin: .zero, size: size)
        badgeLabel.center = CGPoint(x: anchor.maxX + 2 + badgeCenterOffset.x, y: anchor.minY + badgeCenterOffset.y)
        badgeLabel.layer.cornerRadius = appearance.cornerRadius > 0 ? min(appearance.cornerRadius, size.height / 2) : size.height / 2
        badgeContainerView?.frame = bounds
        if let container = badgeContainerView { bringSubviewToFront(container) }
    }

    // Validates animation options for a given file extension/backend.
    // Returns YES if options are valid, NO otherwise. Logs warnings for unsupported options.
    @discardableResult
    private func cyl_validateAnimationOptions(_ options: NSDictionary, forExtension fileExtension: String) -> Bool {
        if options.count == 0 { return true }
        let names = options.allKeys.map { "\($0)" }
        let supported: [String: (label: String, keys: Set<String>)] = [
            // Lottie options: loopMode, animationSpeed, etc.
            "json": ("Lottie", ["animationSpeed", "contentMode"]),
            // PAG options: loopMode, etc.
            "pag": ("PAG", ["contentMode"]),
            // Rive options: artboard, stateMachine, active, trigger, input, triggerInput, animation, legacy, duration, color,
            // numberInput, values (CYLAnimatedItem's CYLTabBarAnimationOptionRive* keys).
            "riv": ("Rive", ["artboard", "stateMachine", "active", "trigger", "input", "triggerInput", "animation", "legacy",
                             "color", "duration", "numberInput", "values"]),
            // GIF options: contentMode
            "gif": ("GIF", ["contentMode"])
        ]
        // Custom factory - accept all options
        guard let rule = supported[fileExtension] else { return true }
        var isValid = true
        for name in names where !rule.keys.contains(name) {
            NSLog("CYLTableViewPlaceHolder: %@ animation option '%@' is not supported.", rule.label, name)
            isValid = false
        }
        return isValid
    }

    // MARK: Playback

    /**
     * Replay the configured animation when visible (`playAnimation` of the base class does the same). Honors Reduce
     * Motion.
     */
    @objc open func playPlaceholderAnimation() {
        cyl_leaveSeekMode()
        cyl_showAnimationAgain()
        animationStopped = false
        animationShowsLastFrame = false
        animationRestartPending = true
        cyl_updateAnimationPlayback()
    }

    /**
     * Stop playback and show the resting frame until explicitly replayed (also `stopAnimation`).
     */
    @objc open func stopPlaceholderAnimation() {
        cyl_leaveSeekMode()
        cyl_showAnimationAgain()
        animationStopped = true
        animationShowsLastFrame = false
        cyl_updateAnimationPlayback()
    }

    /**
     * Stop and show the last frame when supported (also `showAnimationLastFrame`).
     */
    @objc open func showPlaceholderAnimationLastFrame() {
        cyl_leaveSeekMode()
        cyl_showAnimationAgain()
        animationStopped = true
        animationShowsLastFrame = true
        cyl_updateAnimationPlayback()
    }

    private var ownedIconColor: UIColor?

    /**
     * [EN] The engine tints a single-color animation in the icon color through the player's `applyColors` with `**.Color` (and removes it
     *      with nil), the same call that carries the item's color overrides (`CYLPlaceholderItemAnimationColors`), and the last call wins
     *      (since CYLTabBarController 3c6a4d2 the tint pass runs on every state, trait and tint change). So the overrides, which are the
     *      item's own explicit colors, are applied again after each pass this view can see.
     * [CN] 引擎通过播放器的 `applyColors`（`**.Color`；nil 表示移除）用图标颜色为单色动画着色，与承载条目颜色覆盖
     *      （`CYLPlaceholderItemAnimationColors`）的是同一个调用，且以最后一次为准（自 CYLTabBarController 3c6a4d2 起，每次状态、trait 与 tint
     *      变化都会执行着色）。所以作为条目自己显式颜色的覆盖，在本视图能看到的每次着色之后重新应用。
     */
    open override func applyIconTintColor(_ color: UIColor?) {
        super.applyIconTintColor(color)
        cyl_reapplyAnimationColors()
    }

    // [EN] The engine's pass on state, appearance, tint and trait changes and when the animation view loads. [CN] 引擎在状态、外观、tint、trait 变化以及动画视图加载时的执行入口。
    open override func applyItemAppearance() {
        super.applyItemAppearance()
        cyl_reapplyAnimationColors()
    }

    private func cyl_reapplyAnimationColors() {
        #if CYL_ANIMATION_ENGINE_AVAILABLE
        guard let colors = animationColors, !colors.isEmpty, let player = animationPlayer,
              player.responds(to: #selector(CYLTabBarItemAnimationPlayer.applyColors(_:traitCollection:))) else { return }
        player.applyColors?(colors, traitCollection: traitCollection)
        #endif
    }

    /**
     * [EN] Sets the icon color this view owns (nil: the icon follows `tintColor`). Since CYLTabBarController 3c6a4d2 the engine
     *      paints the icon with its own built-in color (`UIColor.label` when normal) on every state or trait change, so the color
     *      goes to the engine as the subclass level (`applyIconTintColor(_:)`), which the engine keeps applying.
     * [CN] 设置本视图拥有的图标颜色（nil：图标跟随 `tintColor`）。自 CYLTabBarController 3c6a4d2 起，引擎在每次状态或 trait 变化时用自己的
     *      内置颜色（普通状态为 `UIColor.label`）为图标着色，所以颜色以子类层（`applyIconTintColor(_:)`）交给引擎，由引擎持续应用。
     */
    private func cyl_setIconColor(_ color: UIColor?) {
        ownedIconColor = color
        applyIconTintColor(color ?? tintColor)
        if color == nil { imageView.tintColor = nil }
    }

    /**
     * [EN] Shows the animation again in place of the still image after its end. The engine's own helper is private; switching
     *      `showsImageWhenAnimationEnds` off and on again does the same through its public API.
     * [CN] 重新显示动画，替换结束后显示的静态图。引擎自己的方法是私有的；关闭再打开 `showsImageWhenAnimationEnds` 通过其公开接口达到同样效果。
     */
    private func cyl_showAnimationAgain() {
        guard isShowingImageAfterAnimationEnd else { return }
        showsImageWhenAnimationEnds = false
        showsImageWhenAnimationEnds = true
    }

    private func cyl_leaveSeekMode() {
        if animationSeekProgress == nil { return }
        animationSeekProgress = nil
        animationRestingProgress = 0
    }

    // [EN] The base class's playback methods follow the placeholder's policy too (visibility, Reduce Motion, repeat
    //      count), so both spellings behave the same.
    // [CN] 基类的播放方法同样遵循占位图的播放策略（可见性、减弱动态效果、重复次数），两种写法行为一致。

    /**
     * [EN] The same as `playPlaceholderAnimation()`. [CN] 与 `playPlaceholderAnimation()` 相同。
     */
    open override func playAnimation() {
        playPlaceholderAnimation()
    }

    /**
     * [EN] The same as `playPlaceholderAnimation()`: every engine player plays from progress 0.
     * [CN] 与 `playPlaceholderAnimation()` 相同：引擎的播放器都从进度 0 开始播放。
     */
    open override func restartAnimation() {
        playPlaceholderAnimation()
    }

    /**
     * [EN] The same as `stopPlaceholderAnimation()`. [CN] 与 `stopPlaceholderAnimation()` 相同。
     */
    open override func stopAnimation() {
        stopPlaceholderAnimation()
    }

    /**
     * [EN] The same as `showPlaceholderAnimationLastFrame()`. [CN] 与 `showPlaceholderAnimationLastFrame()` 相同。
     */
    open override func showAnimationLastFrame() {
        showPlaceholderAnimationLastFrame()
    }

    /**
     * Stops and seeks when supported. Returns NO for invalid values or unsupported players.
     */
    @discardableResult
    @objc(setPlaceholderAnimationProgress:)
    open func setPlaceholderAnimationProgress(_ progress: CGFloat) -> Bool {
        if !Thread.isMainThread || !progress.isFinite || progress < 0 || progress > 1 { return false }
        #if CYL_ANIMATION_ENGINE_AVAILABLE
        guard animationPlayer?.responds(to: #selector(setter: CYLTabBarItemAnimationPlayer.progress)) == true else { return false }
        animationStopped = true
        animationShowsLastFrame = false
        animationSeekProgress = progress
        cyl_updateAnimationPlayback()
        return true
        #else
        return false
        #endif
    }

    /**
     * Sets a positive finite playback speed when supported. Returns NO otherwise.
     */
    @discardableResult
    @objc(setPlaceholderAnimationSpeed:)
    open func setPlaceholderAnimationSpeed(_ speed: CGFloat) -> Bool {
        if !Thread.isMainThread || !speed.isFinite || speed <= 0 { return false }
        #if CYL_ANIMATION_ENGINE_AVAILABLE
        guard animationPlayer?.responds(to: #selector(setter: CYLTabBarItemAnimationPlayer.animationSpeed)) == true else { return false }
        explicitAnimationSpeed = speed
        animationSpeed = speed
        return true
        #else
        return false
        #endif
    }

    // [EN] Plays while the view is on screen, visible, not stopped and Reduce Motion is off; otherwise shows the resting
    //      frame, the last frame or the seek position. The base class plays.
    // [CN] 视图在屏幕上、可见、未停止且未开启“减弱动态效果”时播放；否则显示静止帧、最后一帧或定位的位置。由基类播放。
    private func cyl_updateAnimationPlayback() {
        #if CYL_ANIMATION_ENGINE_AVAILABLE
        cyl_stopRepeatTimer()
        guard let player = animationPlayer else { return }
        if animationShowsLastFrame {
            super.showAnimationLastFrame()
        } else if let progress = animationSeekProgress {
            animationRestingProgress = progress
            super.stopAnimation()
        } else if !animationStopped && window != nil && !isHidden && !UIAccessibility.isReduceMotionEnabled {
            // [EN] A replay starts from progress 0; any other update (visibility, repeat count) resumes.
            // [CN] 重播从进度 0 开始；其他更新（可见性、重复次数）继续播放。
            // [EN] Not `super.restartAnimation()`: it calls `self.playAnimation()`, which this class routes back here.
            // [CN] 不用 `super.restartAnimation()`：它调用 `self.playAnimation()`，本类又会转回这里。
            if animationRestartPending && player.responds(to: #selector(setter: CYLTabBarItemAnimationPlayer.progress)) {
                (player as? NSObject)?.setValue(CGFloat(0), forKey: "progress")
            }
            animationRestartPending = false
            super.playAnimation()
            cyl_startRepeatTimerIfNeeded()
        } else {
            super.stopAnimation()
        }
        #endif
    }

    // [EN] A repeat count N > 1: the player plays once and is replayed N - 1 times when it reaches the end (it must
    //      report its progress, as Lottie and PAG do). 0 is `animationLoops`, handled by the base class.
    // [CN] 重复次数 N > 1：播放器播放一次，播放到末尾时再重播 N - 1 次（播放器需要提供进度，如 Lottie 与 PAG）。0 即 `animationLoops`，由基类处理。
    private func cyl_startRepeatTimerIfNeeded() {
        #if CYL_ANIMATION_ENGINE_AVAILABLE
        guard animationRepeatCount > 1,
              animationPlayer?.responds(to: #selector(getter: CYLTabBarItemAnimationPlayer.progress)) == true else { return }
        remainingRepeats = animationRepeatCount - 1
        let timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.animationPlayer, self.remainingRepeats > 0 else {
                timer.invalidate()
                return
            }
            if (player.progress ?? 0) >= 0.999 {
                self.remainingRepeats -= 1
                player.play()
            }
        }
        repeatTimer = timer
        RunLoop.main.add(timer, forMode: .common)
        #endif
    }

    private func cyl_stopRepeatTimer() {
        repeatTimer?.invalidate()
        repeatTimer = nil
    }

    // MARK: Tap

    // A placeholder with a tap event is a button for VoiceOver, Voice Control and Switch Control; with interaction
    // turned off it is a dimmed ("not enabled") button, as a disabled UIButton. Without a tap event the traits it added
    // are removed again.
    private func cyl_updateTapAccessibility() {
        var traits = accessibilityTraits
        if tapHandler != nil {
            if !traits.contains(.button) {
                traits.insert(.button)
                tapAddedButtonTrait = true
            }
            if !isTapInteractionEnabled && !traits.contains(.notEnabled) {
                traits.insert(.notEnabled)
                tapAddedNotEnabledTrait = true
            } else if isTapInteractionEnabled && tapAddedNotEnabledTrait {
                traits.remove(.notEnabled)
                tapAddedNotEnabledTrait = false
            }
            isAccessibilityElement = true
            accessibilityElementsHidden = false
        } else {
            if tapAddedButtonTrait { traits.remove(.button) }
            if tapAddedNotEnabledTrait { traits.remove(.notEnabled) }
            tapAddedButtonTrait = false
            tapAddedNotEnabledTrait = false
        }
        accessibilityTraits = traits
    }

    /**
     * Runs the handler as a tap would; NO when the placeholder is not tap-interactive.
     */
    @discardableResult
    @objc open func performTap() -> Bool {
        guard isTapInteractive, let handler = tapHandler else { return false }
        handler(self)
        return true
    }

    open override func accessibilityActivate() -> Bool {
        performTap() || super.accessibilityActivate()
    }

    /**
     * [EN] The base class's accessibility (a button with the title) does not apply: a placeholder is a decoration, an
     *      element when it has content or a label, and a button only with a tap event.
     * [CN] 不使用基类的无障碍设置（带标题的按钮）：占位图是装饰；有内容或标签时是元素；只有设置点击事件时才是按钮。
     */
    open override func updateItemAccessibility() {
        cyl_updateTapAccessibility()
    }

    // [EN] `UIControlEventTouchUpInside` (sent by the base class's tracking or by the touches below) runs the tap event.
    // [CN] `UIControlEventTouchUpInside`（由基类的跟踪或下面的触摸处理发送）执行点击事件。
    @objc private func cyl_handleTouchUpInside() {
        performTap()
    }

    // [EN] YES when the control handles touches: a tap event, or the base class's delegate or drag. Otherwise touches pass
    //      through, as they did before the placeholder became a control.
    // [CN] 控件是否处理触摸：有点击事件，或设置了基类的代理或拖拽。否则触摸穿透，与占位图成为控件之前相同。
    private var cyl_handlesTouches: Bool {
        isTapInteractive || delegate != nil || isDragEnabled
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return (hit === self && !cyl_handlesTouches) ? nil : hit
    }

    private func cyl_setTapHighlighted(_ requested: Bool) {
        var highlighted = requested
        if highlighted && tapHighlightStyle == .none { highlighted = false }
        if storedTapHighlighted == highlighted { return }
        storedTapHighlighted = highlighted
        // [EN] Only the content changes, so an alpha or transform the app set on the view itself is kept.
        // [CN] 只改变内容视图，保留应用对本视图设置的 alpha 或 transform。
        // [EN] Reduce Motion: the shrink style only dims. [CN] 开启“减弱动态效果”时，缩小样式只变暗。
        let shrink = tapHighlightStyle == .shrink && !UIAccessibility.isReduceMotionEnabled
        let alpha: CGFloat = highlighted ? (shrink ? 0.8 : 0.5) : 1
        let transform = highlighted && shrink ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
        // [EN] The content is the subviews: the transform scales them around the center (the content is centered), and
        //      each keeps the alpha it had before the press.
        // [CN] 内容即子视图：变换以中心缩放它们（内容居中），各子视图保留按下前的 alpha。
        if highlighted && highlightAlphas == nil {
            let table = NSMapTable<UIView, NSNumber>.weakToStrongObjects()
            for view in subviews { table.setObject(NSNumber(value: Double(view.alpha)), forKey: view) }
            highlightAlphas = table
        }
        let alphas = highlightAlphas
        UIView.animate(withDuration: highlighted ? 0.08 : 0.2, delay: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            self.layer.sublayerTransform = CATransform3DMakeAffineTransform(transform)
            if let alphas = alphas, let views = alphas.keyEnumerator().allObjects as? [UIView] {
                for view in views {
                    view.alpha = CGFloat(alphas.object(forKey: view)?.doubleValue ?? 1) * alpha
                }
            }
        }, completion: nil)
        if !highlighted { highlightAlphas = nil }
    }

    private func cyl_touchIsInside(_ touches: Set<UITouch>) -> Bool {
        // [EN] A little slop around the view, as UIButton allows. [CN] 与 UIButton 一样，允许在视图外有少许容差。
        guard let point = touches.first?.location(in: self) else { return false }
        return bounds.insetBy(dx: -24, dy: -24).contains(point)
    }

    // [EN] A tap-interactive placeholder tracks its own touches (highlight, slop) and sends
    //      `UIControlEventTouchUpInside`, so the base class's delegate hears the tap as well. Without a tap event the base
    //      class (UIControl) tracks them when it has a delegate or a drag; otherwise they go up the responder chain as
    //      before.
    // [CN] 可点击的占位图自己跟踪触摸（高亮、容差）并发送 `UIControlEventTouchUpInside`，基类的代理也会收到点击。没有点击事件时，若有代理或拖拽则由基类
    //      （UIControl）跟踪；否则与以前一样沿响应链传递。
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTapInteractive {
            if cyl_handlesTouches {
                super.touchesBegan(touches, with: event)
            } else {
                next?.touchesBegan(touches, with: event)
            }
            return
        }
        cyl_setTapHighlighted(true)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTapInteractive {
            if cyl_handlesTouches {
                super.touchesMoved(touches, with: event)
            } else {
                next?.touchesMoved(touches, with: event)
            }
            return
        }
        cyl_setTapHighlighted(cyl_touchIsInside(touches))
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTapInteractive {
            if cyl_handlesTouches {
                super.touchesEnded(touches, with: event)
            } else {
                next?.touchesEnded(touches, with: event)
            }
            return
        }
        let inside = cyl_touchIsInside(touches)
        cyl_setTapHighlighted(false)
        if inside { sendActions(for: .touchUpInside) }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cyl_setTapHighlighted(false)
        if isTapInteractive { return }
        if cyl_handlesTouches {
            super.touchesCancelled(touches, with: event)
        } else {
            next?.touchesCancelled(touches, with: event)
        }
    }

    // MARK: Visibility

    @objc private func cyl_contentSizeCategoryChanged(_ notification: Notification) {
        setNeedsLayout()
    }

    @objc private func cyl_reduceMotionChanged(_ notification: Notification) {
        cyl_updateAnimationPlayback()
    }

    open override var isHidden: Bool {
        didSet { cyl_updateAnimationPlayback() }
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if reportedResource != nil { CYLPlaceholderResourceReporter.shared.sourceDidMove(self) }
        cyl_updateAnimationPlayback()
    }

    // MARK: Bundled art and text

    /**
     * The corresponding bundle image name, without the scale suffix or extension.
     */
    @objc(imageNameForStyle:)
    open class func imageName(for style: CYLPlaceholderStyle) -> String? {
        let names = [
            "Empty", "NoResults", "Error", "WifiOff", "SignalWifiOff", "NoInternet",
            "CloudOff", "SyncProblem", "SyncDisabled", "NetworkLocked", "BluetoothDisabled",
            "LocationOff", "PublicOff", "ErrorOutline", "Warning", "ReportProblem", "Blocked",
            "Help", "Hourglass", "Locked", "VisibilityOff", "SearchOff", "FolderOff",
            "FolderOpen", "DownloadOff", "UploadOff", "Inbox", "BrokenImage", "ImageUnavailable",
            "PhotoLibrary", "MusicOff", "VideoOff", "PersonOff", "GroupOff", "EventBusy",
            "EmptyCart", "Favorite", "BatteryAlert", "UnknownDevice", "PhoneDisabled",
            "WrongLocation", "Archive", "Info", "Refresh", "Delete", "Search", "Mail",
            "Image", "Cloud", "NotificationsOff", "History"
        ]
        let index = style.rawValue
        if index < 0 || index >= names.count {
            NSLog("CYLTableViewPlaceHolder: invalid placeholder style %ld.", index)
            return nil
        }
        return "CYLPlaceholder" + names[index]
    }

    /**
     * Images are loaded from the library's offline bundle. Invalid styles return nil and log an error.
     */
    @objc(imageForStyle:)
    open class func image(for style: CYLPlaceholderStyle) -> UIImage? {
        guard let name = imageName(for: style), let bundle = CYLPlaceholderResourceBundle() else { return nil }
        guard let image = UIImage(named: name, in: bundle, compatibleWith: nil) else {
            NSLog("CYLTableViewPlaceHolder: missing placeholder image %@.", name)
            return nil
        }
        return style == .empty ? image : image.withRenderingMode(.alwaysTemplate)
    }

    /**
     * Uses the current app language, with an English fallback.
     */
    @objc(localizedTextForMessage:)
    open class func localizedText(for message: CYLPlaceholderMessage) -> String? {
        let keys = ["CYLPlaceholderEmptyText", "CYLPlaceholderNoResultsText", "CYLPlaceholderNoInternetText",
                    "CYLPlaceholderServerUnavailableText", "CYLPlaceholderErrorText", "CYLPlaceholderLoadingText",
                    "CYLPlaceholderNoPermissionText", "CYLPlaceholderEmptyCartText", "CYLPlaceholderNoNotificationsText"]
        let fallbacks = ["Nothing here yet", "No results found", "No internet connection",
                         "Server unavailable", "Something went wrong", "Loading",
                         "Access unavailable", "Your cart is empty", "No notifications"]
        let index = message.rawValue
        if index < 0 || index >= keys.count {
            NSLog("CYLTableViewPlaceHolder: invalid placeholder message %ld.", index)
            return nil
        }
        return CYLPlaceholderLocalizedStringForKey(keys[index], fallbacks[index])
    }

    /**
     * File names of the ready-made animations in the library's resource bundle (`Animations/`), sorted:
     * Lottie (.json), PAG (.pag), Rive (.riv) and GIF (.gif) files named after their scenario, such as
     * "CYLPlaceholderLoading.json" or "CYLPlaceholderEmptyCart.json". Sources and licenses: NOTICE.animations.
     */
    @objc open class func bundledAnimationFileNames() -> [String] {
        guard let resourcePath = CYLPlaceholderResourceBundle()?.resourcePath else { return [] }
        let directory = (resourcePath as NSString).appendingPathComponent(CYLPlaceholderAnimationsDirectory)
        let extensions: Set<String> = ["json", "lottie", "pag", "riv", "gif"]
        let names = (try? FileManager.default.contentsOfDirectory(atPath: directory)) ?? []
        return names.filter { extensions.contains(($0 as NSString).pathExtension.lowercased()) }
            .sorted { ($0 as NSString).compare($1) == .orderedAscending }
    }

    /**
     * Full path of a bundled animation, for CYLPlaceholderItemAnimationFilePath and the engine-specific file
     * path keys; nil when there is no such file. Playback needs the matching animation subspec (the engine).
     */
    @objc(pathForBundledAnimation:)
    open class func path(forBundledAnimation fileName: String) -> String? {
        if fileName.isEmpty || (fileName as NSString).lastPathComponent != fileName { return nil }
        guard let path = CYLPlaceholderResourceBundle()?.path(forResource: fileName, ofType: nil,
                                                               inDirectory: CYLPlaceholderAnimationsDirectory) else { return nil }
        return FileManager.default.fileExists(atPath: path) ? path : nil
    }
}
