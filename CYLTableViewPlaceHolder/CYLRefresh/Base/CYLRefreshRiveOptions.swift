//
//  CYLRefreshRiveOptions.swift
//  CYLRefresh
//

// [EN] The creation parameters of the `rive` refresh style, the same keys on every platform (docs/Refresh-Library-Parity.md, "The
//      rive style: creation parameters"). Pure Foundation: it needs no Rive runtime, so a host can read and check the parameters
//      before the `CYLTableViewPlaceHolder/Rive` subspec (RiveRuntime) is asked to draw them.
// [CN] `rive` 刷新样式的创建参数，各平台的键相同（docs/Refresh-Library-Parity.md，“The rive style: creation parameters”）。只依赖
//      Foundation，不需要 Rive 运行时：宿主可以先读取、检查参数，再交给 `CYLTableViewPlaceHolder/Rive` 子库（RiveRuntime）绘制。

import Foundation

/**
 * [EN] The `rive` style's parameters read from a creation-parameter dictionary (a Flutter creation parameter map, or the object of
 *      React Native's `headerRive` / `footerRive`). `riveFile` is required; every other key is optional and an unset name is skipped by
 *      the header. Keys: `riveFile`, `riveArtboard`, `riveStateMachine`, `riveTriggerOffset`, `riveMinimumHeight`, `riveFitsWidth`, `riveFinishTimeout`,
 *      `rivePullInput`, `rivePullInputMinimum`, `rivePullInputMaximum`, `rivePullInputStart`, `rivePullInputRefreshingValue`,
 *      `riveReleaseTrigger`, `riveFinishTrigger`, `riveRestartTrigger`, `riveLoadingBoolean`, `riveLoadingNumber`,
 *      `riveLoadingNumberMaximum`, `riveLoadingNumberFinished`, `riveLoadingNumberDuration`, `rivePullAnimation`,
 *      `riveTriggerAnimation`, `riveLoadingAnimation`, `riveIdleAnimation`.
 * [CN] 从创建参数字典（Flutter 的创建参数 Map，或 React Native `headerRive` / `footerRive` 的对象）读取的 `rive` 样式参数。`riveFile`
 *      必填，其余键可选，未设置的名称会被刷新头跳过。键见上。
 */
@objc(CYLRefreshRiveOptions)
public final class CYLRefreshRiveOptions: NSObject {

    /**
     * [EN] The key of the required file name or path. [CN] 必填的文件名或路径的键。
     */
    @objc public static let fileKey = "riveFile"

    /**
     * [EN] Seconds a finish holds the header open at most when `riveFinishTimeout` is not set (1.5): the Rive runtimes do not report
     *      how long the end of a state machine takes. [CN] 未设置 `riveFinishTimeout` 时，结束最多让刷新头保持展开的秒数（1.5）：Rive
     *      运行时不会告知状态机结束部分的时长。
     */
    @objc public static let defaultFinishTimeout: TimeInterval = 1.5

    /**
     * [EN] `riveFinishTimeout` when it is a number above 0, else `defaultFinishTimeout`. [CN] `riveFinishTimeout` 为大于 0 的数字时取其值，否则为 `defaultFinishTimeout`。
     */
    @objc public var finishTimeout: TimeInterval {
        if let value = number("riveFinishTimeout"), value > 0 { return value }
        return Self.defaultFinishTimeout
    }

    /**
     * [EN] The pairs of `riveDrawnTable` that are valid (two finite numbers: pull input, drawn fraction 0...1), sorted by input, and why
     *      anything was dropped; empty pairs mean no clip. [CN] `riveDrawnTable` 中有效的数对（两个有限数字：下拉输入、已绘制比例 0...1），
     *      按输入排序，以及丢弃内容的原因；数对为空表示不裁剪。
     */
    public var drawnTable: (pairs: [[Double]], reason: String?) {
        CYLRefreshRiveDrawnTable.parse(values["riveDrawnTable"])
    }

    /**
     * [EN] The `riveFile` value: an absolute path, or a file name (with or without `.riv`) or relative path of an app or Flutter
     *      asset. [CN] `riveFile` 的值：绝对路径，或应用 / Flutter 资源的文件名（带不带 `.riv` 均可）或相对路径。
     */
    @objc public let file: String

    /**
     * [EN] Every `rive...` entry of the dictionary. [CN] 字典中所有以 `rive` 开头的项。
     */
    @objc public let values: [String: Any]

    /**
     * [EN] The options in `dictionary`; nil when it has no non-empty string `riveFile`. [CN] `dictionary` 中的选项；没有非空字符串
     *      `riveFile` 时为 nil。
     */
    @objc public init?(dictionary: [String: Any]?) {
        guard let dictionary = dictionary, let file = dictionary[Self.fileKey] as? String, !file.isEmpty else { return nil }
        self.file = file
        values = dictionary.filter { $0.key.hasPrefix("rive") }
        super.init()
    }

    /**
     * [EN] The string value of `key`; nil when missing, not a string or empty. [CN] `key` 的字符串值；缺失、不是字符串或为空时为 nil。
     */
    @objc public func string(_ key: String) -> String? {
        guard let value = values[key] as? String, !value.isEmpty else { return nil }
        return value
    }

    /**
     * [EN] The number value of `key`; nil when missing, not a number or not finite. [CN] `key` 的数字值；缺失、不是数字或不是有限值时为 nil。
     */
    public func number(_ key: String) -> Double? {
        guard let value = (values[key] as? NSNumber)?.doubleValue, value.isFinite else { return nil }
        return value
    }

    /**
     * [EN] The boolean value of `key`; only a boolean true counts. [CN] `key` 的布尔值；只有布尔 true 才算。
     */
    @objc public func bool(_ key: String) -> Bool {
        values[key] as? Bool == true
    }

    /**
     * [EN] The .riv file `riveFile` names: the absolute path if it exists, else the first match in `bundles` (default: the main bundle,
     *      a Flutter app's `App.framework`, then every loaded bundle and framework) under the bundle root and the folders `flutter_assets`, `flutter_assets/assets`,
     *      `flutter_assets/assets/animations` and `Animations`; nil when nothing is found.
     * [CN] `riveFile` 指向的 .riv 文件：绝对路径存在则取之，否则在 `bundles`（默认：主 bundle，然后是所有已加载的 bundle 与 framework）
     *      的根目录以及 `flutter_assets`、`flutter_assets/assets`、`flutter_assets/assets/animations`、`Animations` 文件夹中取第一个匹配；
     *      找不到时为 nil。
     */
    @objc public func resolvedFileURL(bundles: [Bundle]? = nil) -> URL? {
        if file.hasPrefix("/") {
            return FileManager.default.fileExists(atPath: file) ? URL(fileURLWithPath: file) : nil
        }
        let nsFile = file as NSString
        let name = nsFile.pathExtension == "riv" ? nsFile.deletingPathExtension : file
        let base = (name as NSString).lastPathComponent
        let folder = (name as NSString).deletingLastPathComponent
        let roots = ["", "flutter_assets", "flutter_assets/assets", "flutter_assets/assets/animations", "Animations"]
        // [EN] A Flutter app keeps its assets in the embedded App.framework, which may not be listed among the loaded frameworks. [CN] Flutter 应用的资源在内嵌的 App.framework 里，它可能不在已加载的 framework 列表中。
        let flutterApp = Bundle.main.privateFrameworksURL.flatMap { Bundle(url: $0.appendingPathComponent("App.framework")) }
        let searched = bundles ?? ([Bundle.main] + [flutterApp].compactMap { $0 } + Bundle.allBundles + Bundle.allFrameworks)
        for bundle in searched {
            for root in roots {
                let directory = [root, folder].filter { !$0.isEmpty }.joined(separator: "/")
                if let url = bundle.url(forResource: base, withExtension: "riv", subdirectory: directory.isEmpty ? nil : directory) {
                    return url
                }
            }
        }
        return nil
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CYLRefreshRiveOptions else { return false }
        return file == other.file && (values as NSDictionary).isEqual(to: other.values)
    }

    override public var hash: Int { file.hashValue }
}

/**
 * [EN] What the `CYLTableViewPlaceHolder/Rive` subspec provides to the core: a header or footer drawn by a Rive file, or nil when the
 *      file cannot be found or read. The core finds the class named `CYLRefreshRiveBuilder` at run time, so the core links no Rive
 *      runtime and the style falls back to classic when the subspec is not installed.
 * [CN] `CYLTableViewPlaceHolder/Rive` 子库提供给核心的能力：由 Rive 文件绘制的刷新头或刷新尾；文件找不到或无法读取时为 nil。核心在运行时按名称
 *      `CYLRefreshRiveBuilder` 查找该类，所以核心不链接 Rive 运行时，没有安装子库时该样式退回经典样式。
 */
@objc public protocol CYLRefreshRiveBuilding: NSObjectProtocol {
    /**
     * [EN] A header drawn by the file of `options`; nil when it cannot be read. [CN] 由 `options` 的文件绘制的刷新头；无法读取时为 nil。
     */
    @objc static func riveHeader(options: CYLRefreshRiveOptions) -> CYLRefreshHeader?
    /**
     * [EN] A footer drawn by the file of `options`; nil when it cannot be read. [CN] 由 `options` 的文件绘制的刷新尾；无法读取时为 nil。
     */
    @objc static func riveFooter(options: CYLRefreshRiveOptions) -> CYLRefreshFooter?
}

/**
 * [EN] The per-file table of the `rive` style (`riveDrawnTable`): the fraction of the header height that a Rive file draws at a pull
 *      input (below it the file draws black). Pure Foundation, so it is tested without the Rive runtime.
 * [CN] `rive` 样式按文件的表（`riveDrawnTable`）：Rive 文件在某个下拉输入下实际画出的刷新头高度比例（其下方文件画的是黑色）。
 *      纯 Foundation，所以不需要 Rive 运行时即可测试。
 */
enum CYLRefreshRiveDrawnTable {

    // [EN] The drawn fraction at `input`: linear between pairs, the first fraction below the first pair, the last above the last; 1 (no clip) for an empty table.
    // [CN] `input` 处的已绘制比例：数对之间线性插值，低于第一对取第一个比例，高于最后一对取最后一个比例；表为空时为 1（不裁剪）。
    static func fraction(forInput input: Double, table: [[Double]]) -> Double {
        guard let first = table.first, let last = table.last, first.count == 2, last.count == 2 else { return 1 }
        if !input.isFinite || input <= first[0] { return first[1] }
        if input >= last[0] { return last[1] }
        for index in 1..<table.count where input <= table[index][0] {
            let low = table[index - 1], high = table[index]
            let span = high[0] - low[0]
            if span <= 0 { return high[1] }
            return low[1] + (high[1] - low[1]) * (input - low[0]) / span
        }
        return last[1]
    }

    // [EN] The valid pairs of `value` sorted by input, and a reason when something was dropped or the whole value is ignored.
    // [CN] `value` 中有效的数对（按输入排序），以及有内容被丢弃或整个值被忽略时的原因。
    static func parse(_ value: Any?) -> (pairs: [[Double]], reason: String?) {
        guard let value = value else { return ([], nil) }
        guard let list = value as? [Any] else { return ([], "not an array") }
        var pairs = [[Double]]()
        var dropped = 0
        for item in list {
            guard let pair = item as? [Any], pair.count == 2,
                  let input = (pair[0] as? NSNumber)?.doubleValue, let drawn = (pair[1] as? NSNumber)?.doubleValue,
                  input.isFinite, drawn.isFinite else {
                dropped += 1
                continue
            }
            pairs.append([input, min(max(drawn, 0), 1)])
        }
        pairs.sort { $0[0] < $1[0] }
        if pairs.isEmpty { return ([], list.isEmpty ? "empty" : "no valid pair") }
        return (pairs, dropped > 0 ? "\(dropped) malformed pair\(dropped == 1 ? "" : "s") dropped" : nil)
    }
}
