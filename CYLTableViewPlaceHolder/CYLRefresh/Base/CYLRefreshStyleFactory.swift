//
//  CYLRefreshStyleFactory.swift
//  CYLRefresh
//

// [EN] Makes a refresh header or footer from a style name, for the hosts that choose the look from outside (the Flutter
//      plugin's creation parameter `style`, the React Native container's `headerStyle` / `footerStyle`; docs/Refresh-Library-Parity.md,
//      native bridge map, row 6). iOS-only API: Android has no such factory (its Flutter view ignores the key for now).
// [CN] 按样式名创建刷新头或刷新尾，供从外部选择外观的宿主使用（Flutter 插件的创建参数 `style`、React Native 容器的
//      `headerStyle` / `footerStyle`；docs/Refresh-Library-Parity.md，原生桥接表第 6 行）。仅 iOS 的 API：Android 没有这个工厂
//      （其 Flutter 视图暂时忽略该键）。

import UIKit

/**
 * [EN] The refresh styles a cross-platform host names by one lower camel case string, the same nine values as Android's
 *      `CYLRefreshStyle`: `classic`, `cupertino`, `material`, `bezierRadar`, `bezierCircle`, `delivery`, `phoenix`, `taurus`, `rive`.
 *      `rive` is drawn by a Rive file named by the creation parameters of `CYLRefreshRiveOptions` and needs the
 *      `CYLTableViewPlaceHolder/Rive` subspec; without the subspec, the file or its parameters it is the classic style (one log line
 *      through the host's `onFallback`). `newHeader()` and `newFooter()` make the control of the style: the footer is the classic back footer for `classic`,
 *      the automatic `CYLRefreshCupertinoFooter` for `cupertino` and the drawn footer for the others; `bezierCircle` has
 *      no `CYLRefreshDrawnFooter` subclass, so its footer is the classic one.
 * [CN] 跨平台宿主用一个小驼峰字符串指定的刷新样式，九个值与 Android 的 `CYLRefreshStyle` 相同：`classic`、`cupertino`、
 *      `material`、`bezierRadar`、`bezierCircle`、`delivery`、`phoenix`、`taurus`、`rive`。`rive` 由 `CYLRefreshRiveOptions` 创建参数指定的
 *      Rive 文件绘制，需要 `CYLTableViewPlaceHolder/Rive` 子库；没有子库、文件或参数时为经典样式（通过宿主的 `onFallback` 记一行日志）。
 *      `newHeader()` 与 `newFooter()` 创建该样式的控件：
 *      `classic` 的刷新尾是经典回弹刷新尾，`cupertino` 是自动加载的 `CYLRefreshCupertinoFooter`，其余为手绘刷新尾；
 *      `bezierCircle` 没有 `CYLRefreshDrawnFooter` 子类，刷新尾使用经典样式。
 */
public enum CYLRefreshStyle: String, CaseIterable {
    /**
     * [EN] The classic arrow, title and time. [CN] 经典的箭头、标题与时间。
     */
    case classic
    /**
     * [EN] The iOS activity indicator. [CN] iOS 菊花。
     */
    case cupertino
    /**
     * [EN] The Material circular indicator. [CN] Material 圆形指示器。
     */
    case material
    /**
     * [EN] The drawn Bezier radar. [CN] 手绘 Bezier 雷达。
     */
    case bezierRadar
    /**
     * [EN] The drawn Bezier circle. [CN] 手绘 Bezier 圆。
     */
    case bezierCircle
    /**
     * [EN] The drawn delivery truck. [CN] 手绘送货卡车。
     */
    case delivery
    /**
     * [EN] The drawn phoenix. [CN] 手绘凤凰。
     */
    case phoenix
    /**
     * [EN] The drawn taurus. [CN] 手绘金牛。
     */
    case taurus
    /**
     * [EN] A Rive file driven by named state machine inputs (`CYLRefreshRiveOptions`); the classic style when it cannot be made.
     * [CN] 由命名状态机输入驱动的 Rive 文件（`CYLRefreshRiveOptions`）；无法创建时为经典样式。
     */
    case rive

    /**
     * [EN] The lower camel case name of the style (the raw value). Android: `key`. [CN] 样式的小驼峰名称（原始值）。对应 Android 的 `key`。
     */
    public var key: String { rawValue }

    /**
     * [EN] A new header of this style; `riveOptions` (the `rive...` creation parameters) is read by `rive` only, which makes the classic
     *      header without a usable one. Android: `newHeader`.
     * [CN] 该样式的新刷新头；`riveOptions`（`rive...` 创建参数）只有 `rive` 会读取，没有可用参数时得到经典刷新头。对应 Android 的 `newHeader`。
     */
    public func newHeader(riveOptions: [String: Any]? = nil) -> CYLRefreshHeader {
        switch self {
        case .rive: return CYLRefreshStyleFactory.riveHeader(options: riveOptions, onFallback: nil) ?? CYLRefreshNormalHeader(refreshingBlock: {})
        case .classic: return CYLRefreshNormalHeader(refreshingBlock: {})
        case .cupertino: return CYLRefreshCupertinoHeader(refreshingBlock: {})
        case .material: return CYLRefreshMaterialHeader(refreshingBlock: {})
        case .bezierRadar: return CYLRefreshBezierRadarHeader(refreshingBlock: {})
        case .bezierCircle: return CYLRefreshBezierCircleHeader(refreshingBlock: {})
        case .delivery: return CYLRefreshDeliveryHeader(refreshingBlock: {})
        case .phoenix: return CYLRefreshPhoenixHeader(refreshingBlock: {})
        case .taurus: return CYLRefreshTaurusHeader(refreshingBlock: {})
        }
    }

    /**
     * [EN] A new footer of this style; `riveOptions` as for `newHeader(riveOptions:)`. Android: `newFooter`.
     * [CN] 该样式的新刷新尾；`riveOptions` 同 `newHeader(riveOptions:)`。对应 Android 的 `newFooter`。
     */
    public func newFooter(riveOptions: [String: Any]? = nil) -> CYLRefreshFooter {
        switch self {
        case .rive: return CYLRefreshStyleFactory.riveFooter(options: riveOptions, onFallback: nil) ?? CYLRefreshBackNormalFooter(refreshingBlock: {})
        case .classic, .bezierCircle: return CYLRefreshBackNormalFooter(refreshingBlock: {})
        case .cupertino: return CYLRefreshCupertinoFooter(refreshingBlock: {})
        case .material: return CYLRefreshMaterialFooter(refreshingBlock: {})
        case .bezierRadar: return CYLRefreshBezierRadarFooter(refreshingBlock: {})
        case .delivery: return CYLRefreshDeliveryFooter(refreshingBlock: {})
        case .phoenix: return CYLRefreshPhoenixFooter(refreshingBlock: {})
        case .taurus: return CYLRefreshTaurusFooter(refreshingBlock: {})
        }
    }

    /**
     * [EN] The style named `key`, or nil for a missing or unknown name (the caller falls back to `classic` and reports it).
     *      Android: `fromKey`.
     * [CN] 名称为 `key` 的样式；名称缺失或未知时为 nil（调用方退回 `classic` 并报告）。对应 Android 的 `fromKey`。
     */
    public static func fromKey(_ key: Any?) -> CYLRefreshStyle? {
        guard let key = key as? String else { return nil }
        return CYLRefreshStyle(rawValue: key)
    }
}

/**
 * [EN] The Objective-C face of `CYLRefreshStyle`, for hosts written in Objective-C (the React Native container): a style
 *      name to a header or footer. A missing or unknown name makes the classic one and is reported through the
 *      `onUnknownStyle` block, never a crash.
 * [CN] `CYLRefreshStyle` 的 Objective-C 入口，供 Objective-C 宿主（React Native 容器）使用：样式名到刷新头或刷新尾。
 *      缺失或未知的名称得到经典样式，并通过 `onUnknownStyle` 报告，不会崩溃。
 */
@objc(CYLRefreshStyleFactory)
public final class CYLRefreshStyleFactory: NSObject {

    /**
     * [EN] The style used for a missing or unknown name. [CN] 名称缺失或未知时使用的样式。
     */
    @objc public static let fallbackStyle = CYLRefreshStyle.classic.key

    /**
     * [EN] Every style name, in the order of the Dart API. [CN] 所有样式名，顺序与 Dart API 相同。
     */
    @objc public static let styleNames = CYLRefreshStyle.allCases.map { $0.key }

    /**
     * [EN] The class of the `CYLTableViewPlaceHolder/Rive` subspec that draws the `rive` style, found by name at run time so the core
     *      links no Rive runtime; nil when the subspec is not installed. A test may set it. Not visible to Objective-C.
     * [CN] 绘制 `rive` 样式的 `CYLTableViewPlaceHolder/Rive` 子库中的类，运行时按名称查找，所以核心不链接 Rive 运行时；没有安装子库时为 nil。
     *      测试可以设置它。Objective-C 不可见。
     */
    public static var riveBuilder: CYLRefreshRiveBuilding.Type? = NSClassFromString("CYLRefreshRiveBuilder") as? CYLRefreshRiveBuilding.Type

    /**
     * [EN] A new header of the named style; `onUnknownStyle` gets the given name (nil when missing) when it is not one of
     *      `styleNames` and the classic header is made. A `rive` header needs options: use `header(style:options:onFallback:)`.
     * [CN] 指定样式的新刷新头；名称不在 `styleNames` 中（缺失时为 nil）时，`onUnknownStyle` 收到该名称，并创建经典刷新头。`rive`
     *      刷新头需要选项：请用 `header(style:options:onFallback:)`。
     */
    @objc(headerWithStyle:onUnknownStyle:)
    public static func header(style: String?, onUnknownStyle: ((String?) -> Void)? = nil) -> CYLRefreshHeader {
        resolve(style, onUnknownStyle).newHeader()
    }

    /**
     * [EN] A new footer of the named style; `onUnknownStyle` as for `header(style:onUnknownStyle:)`.
     * [CN] 指定样式的新刷新尾；`onUnknownStyle` 同 `header(style:onUnknownStyle:)`。
     */
    @objc(footerWithStyle:onUnknownStyle:)
    public static func footer(style: String?, onUnknownStyle: ((String?) -> Void)? = nil) -> CYLRefreshFooter {
        resolve(style, onUnknownStyle).newFooter()
    }

    /**
     * [EN] A new header of the named style with the `rive...` creation parameters in `options`. `onFallback` gets one reason line
     *      (an unknown name, or why `rive` could not be made: no `riveFile`, the Rive subspec missing, the file not found or unreadable)
     *      whenever the classic header is made instead.
     * [CN] 指定样式的新刷新头，`options` 为 `rive...` 创建参数。退回经典刷新头时，`onFallback` 收到一行原因（名称未知，或 `rive` 无法创建的原因：
     *      没有 `riveFile`、没有 Rive 子库、文件找不到或无法读取）。
     */
    @objc(headerWithStyle:options:onFallback:)
    public static func header(style: String?, options: [String: Any]?, onFallback: ((String) -> Void)?) -> CYLRefreshHeader {
        guard let known = CYLRefreshStyle.fromKey(style) else {
            onFallback?("unknown refresh style \(style ?? "(missing)")")
            return CYLRefreshStyle.classic.newHeader()
        }
        if known == .rive { return riveHeader(options: options, onFallback: onFallback) ?? CYLRefreshStyle.classic.newHeader() }
        return known.newHeader()
    }

    /**
     * [EN] A new footer of the named style with the `rive...` creation parameters in `options`; `onFallback` as for
     *      `header(style:options:onFallback:)`.
     * [CN] 指定样式的新刷新尾，`options` 为 `rive...` 创建参数；`onFallback` 同 `header(style:options:onFallback:)`。
     */
    @objc(footerWithStyle:options:onFallback:)
    public static func footer(style: String?, options: [String: Any]?, onFallback: ((String) -> Void)?) -> CYLRefreshFooter {
        guard let known = CYLRefreshStyle.fromKey(style) else {
            onFallback?("unknown refresh style \(style ?? "(missing)")")
            return CYLRefreshStyle.classic.newFooter()
        }
        if known == .rive { return riveFooter(options: options, onFallback: onFallback) ?? CYLRefreshStyle.classic.newFooter() }
        return known.newFooter()
    }

    // [EN] The Rive header, or nil after reporting why not. [CN] Rive 刷新头；不能创建时先报告原因再返回 nil。
    fileprivate static func riveHeader(options: [String: Any]?, onFallback: ((String) -> Void)?) -> CYLRefreshHeader? {
        guard let (builder, parsed) = riveParts(options, onFallback) else { return nil }
        if let header = builder.riveHeader(options: parsed) { return header }
        reportMissingRiveFile(parsed.file)
        onFallback?("rive file \(parsed.file) not found or unreadable")
        return nil
    }

    // [EN] The Rive footer, or nil after reporting why not. [CN] Rive 刷新尾；不能创建时先报告原因再返回 nil。
    fileprivate static func riveFooter(options: [String: Any]?, onFallback: ((String) -> Void)?) -> CYLRefreshFooter? {
        guard let (builder, parsed) = riveParts(options, onFallback) else { return nil }
        if let footer = builder.riveFooter(options: parsed) { return footer }
        reportMissingRiveFile(parsed.file)
        onFallback?("rive file \(parsed.file) not found or unreadable")
        return nil
    }

    // [EN] Names the Rive file to the red status bar's reporter when the file is the reason for the classic fallback (a missing
    //      runtime is not reported: the static fallback is intended). [CN] Rive 文件是退回经典样式的原因时，把文件名报告给红条。
    private static func reportMissingRiveFile(_ file: String) {
        let exists = FileManager.default.fileExists(atPath: file)
        guard !exists || !FileManager.default.isReadableFile(atPath: file) else { return }
        CYLPlaceholderResourceReporter.shared.report(resource: file, reason: exists ? "unreadable" : "file not found", source: nil)
    }

    private static func riveParts(_ options: [String: Any]?, _ onFallback: ((String) -> Void)?) -> (CYLRefreshRiveBuilding.Type, CYLRefreshRiveOptions)? {
        guard let parsed = CYLRefreshRiveOptions(dictionary: options) else {
            // [EN] Without options the style is only a name (the old entry points): classic, nothing to report. [CN] 没有选项时样式只是个名字（旧入口）：经典样式，无需报告。
            if options != nil { onFallback?("rive needs the creation parameter riveFile") }
            return nil
        }
        guard let builder = riveBuilder else {
            onFallback?("rive runtime not linked (add the CYLTableViewPlaceHolder/Rive subspec)")
            return nil
        }
        return (builder, parsed)
    }

    // [EN] The known style, or the fallback after reporting the unknown name. [CN] 已知样式；名称未知时先报告再返回回退样式。
    private static func resolve(_ style: String?, _ onUnknownStyle: ((String?) -> Void)?) -> CYLRefreshStyle {
        if let known = CYLRefreshStyle.fromKey(style) { return known }
        onUnknownStyle?(style)
        return .classic
    }
}
