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
 * [EN] Turns a style name into a header or footer. The names are the lower camel case styles the Dart API exposes:
 *      `classic`, `cupertino`, `material`, `bezierRadar`, `bezierCircle`, `delivery`, `phoenix`, `taurus`. A missing or
 *      unknown name makes the classic one and is reported through the `onUnknownStyle` block, never a crash. Footers use the
 *      drawn footers (`CYLRefreshDrawnFooter`) for the drawn styles; `bezierCircle` has no drawn footer and falls back to
 *      the classic footer without a report.
 * [CN] 把样式名变成刷新头或刷新尾。名称是 Dart API 暴露的小驼峰样式：`classic`、`cupertino`、`material`、`bezierRadar`、
 *      `bezierCircle`、`delivery`、`phoenix`、`taurus`。缺失或未知的名称得到经典样式，并通过 `onUnknownStyle` 报告，不会崩溃。
 *      手绘样式的刷新尾使用 `CYLRefreshDrawnFooter`；`bezierCircle` 没有手绘刷新尾，退回经典刷新尾且不报告。
 */
@objc(CYLRefreshStyleFactory)
public final class CYLRefreshStyleFactory: NSObject {

    /**
     * [EN] The style used for a missing or unknown name. [CN] 名称缺失或未知时使用的样式。
     */
    @objc public static let fallbackStyle = "classic"

    /**
     * [EN] Every style name, in the order of the Dart API. [CN] 所有样式名，顺序与 Dart API 相同。
     */
    @objc public static let styleNames = ["classic", "cupertino", "material", "bezierRadar", "bezierCircle", "delivery", "phoenix", "taurus"]

    /**
     * [EN] A new header of the named style; `onUnknownStyle` gets the given name (nil when missing) when it is not one of
     *      `styleNames` and the classic header is made.
     * [CN] 指定样式的新刷新头；名称不在 `styleNames` 中（缺失时为 nil）时，`onUnknownStyle` 收到该名称，并创建经典刷新头。
     */
    @objc(headerWithStyle:onUnknownStyle:)
    public static func header(style: String?, onUnknownStyle: ((String?) -> Void)? = nil) -> CYLRefreshHeader {
        switch resolve(style, onUnknownStyle) {
        case "cupertino": return CYLRefreshCupertinoHeader(refreshingBlock: {})
        case "material": return CYLRefreshMaterialHeader(refreshingBlock: {})
        case "bezierRadar": return CYLRefreshBezierRadarHeader(refreshingBlock: {})
        case "bezierCircle": return CYLRefreshBezierCircleHeader(refreshingBlock: {})
        case "delivery": return CYLRefreshDeliveryHeader(refreshingBlock: {})
        case "phoenix": return CYLRefreshPhoenixHeader(refreshingBlock: {})
        case "taurus": return CYLRefreshTaurusHeader(refreshingBlock: {})
        default: return CYLRefreshNormalHeader(refreshingBlock: {})
        }
    }

    /**
     * [EN] A new footer of the named style (the Cupertino footer is the automatic one; the drawn styles use the drawn
     *      footers); `onUnknownStyle` as for `header(style:onUnknownStyle:)`.
     * [CN] 指定样式的新刷新尾（Cupertino 为自动加载尾；手绘样式使用手绘刷新尾）；`onUnknownStyle` 同 `header(style:onUnknownStyle:)`。
     */
    @objc(footerWithStyle:onUnknownStyle:)
    public static func footer(style: String?, onUnknownStyle: ((String?) -> Void)? = nil) -> CYLRefreshFooter {
        switch resolve(style, onUnknownStyle) {
        case "cupertino": return CYLRefreshCupertinoFooter(refreshingBlock: {})
        case "material": return CYLRefreshMaterialFooter(refreshingBlock: {})
        case "bezierRadar": return CYLRefreshBezierRadarFooter(refreshingBlock: {})
        case "delivery": return CYLRefreshDeliveryFooter(refreshingBlock: {})
        case "phoenix": return CYLRefreshPhoenixFooter(refreshingBlock: {})
        case "taurus": return CYLRefreshTaurusFooter(refreshingBlock: {})
        default: return CYLRefreshBackNormalFooter(refreshingBlock: {})
        }
    }

    // [EN] The known name, or the fallback after reporting the unknown one. [CN] 已知名称；未知时先报告再返回回退样式。
    private static func resolve(_ style: String?, _ onUnknownStyle: ((String?) -> Void)?) -> String {
        if let style = style, styleNames.contains(style) { return style }
        onUnknownStyle?(style)
        return fallbackStyle
    }
}
