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
 * [EN] The refresh styles a cross-platform host names by one lower camel case string, the same eight values as Android's
 *      `CYLRefreshStyle`: `classic`, `cupertino`, `material`, `bezierRadar`, `bezierCircle`, `delivery`, `phoenix`, `taurus`.
 *      `newHeader()` and `newFooter()` make the control of the style: the footer is the classic back footer for `classic`,
 *      the automatic `CYLRefreshCupertinoFooter` for `cupertino` and the drawn footer for the others; `bezierCircle` has
 *      no `CYLRefreshDrawnFooter` subclass, so its footer is the classic one.
 * [CN] 跨平台宿主用一个小驼峰字符串指定的刷新样式，八个值与 Android 的 `CYLRefreshStyle` 相同：`classic`、`cupertino`、
 *      `material`、`bezierRadar`、`bezierCircle`、`delivery`、`phoenix`、`taurus`。`newHeader()` 与 `newFooter()` 创建该样式的控件：
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
     * [EN] The lower camel case name of the style (the raw value). Android: `key`. [CN] 样式的小驼峰名称（原始值）。对应 Android 的 `key`。
     */
    public var key: String { rawValue }

    /**
     * [EN] A new header of this style. Android: `newHeader`. [CN] 该样式的新刷新头。对应 Android 的 `newHeader`。
     */
    public func newHeader() -> CYLRefreshHeader {
        switch self {
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
     * [EN] A new footer of this style. Android: `newFooter`. [CN] 该样式的新刷新尾。对应 Android 的 `newFooter`。
     */
    public func newFooter() -> CYLRefreshFooter {
        switch self {
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
     * [EN] A new header of the named style; `onUnknownStyle` gets the given name (nil when missing) when it is not one of
     *      `styleNames` and the classic header is made.
     * [CN] 指定样式的新刷新头；名称不在 `styleNames` 中（缺失时为 nil）时，`onUnknownStyle` 收到该名称，并创建经典刷新头。
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

    // [EN] The known style, or the fallback after reporting the unknown name. [CN] 已知样式；名称未知时先报告再返回回退样式。
    private static func resolve(_ style: String?, _ onUnknownStyle: ((String?) -> Void)?) -> CYLRefreshStyle {
        if let known = CYLRefreshStyle.fromKey(style) { return known }
        onUnknownStyle?(style)
        return .classic
    }
}
