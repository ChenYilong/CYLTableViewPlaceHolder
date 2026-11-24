//
//  CYLRefreshRiveBuilder.swift
//  CYLTableViewPlaceHolder
//
//  [EN] The Rive half of the `rive` refresh style: turns the creation parameters of `CYLRefreshRiveOptions` into a
//       `CYLRefreshRiveStyle` and a `CYLRefreshRiveHeader`. The core finds this class by its name (`CYLRefreshStyleFactory.riveBuilder`),
//       so the core links no Rive runtime.
//  [CN] `rive` 刷新样式的 Rive 一半：把 `CYLRefreshRiveOptions` 的创建参数变成 `CYLRefreshRiveStyle` 与 `CYLRefreshRiveHeader`。
//       核心按名称找到本类（`CYLRefreshStyleFactory.riveBuilder`），所以核心不链接 Rive 运行时。
//

#if canImport(RiveRuntime)
import UIKit

/**
 * [EN] Makes the header or footer of the `rive` style (docs/Refresh-Library-Parity.md, "The rive style: creation parameters").
 * [CN] 创建 `rive` 样式的刷新头或刷新尾（docs/Refresh-Library-Parity.md，“The rive style: creation parameters”）。
 */
@available(*, deprecated, message: "Builds CYLRefreshRiveHeader, which uses Rive's legacy API.")
@objc(CYLRefreshRiveBuilder)
public final class CYLRefreshRiveBuilder: NSObject, CYLRefreshRiveBuilding {

    /**
     * [EN] The style the options describe, nil when the file cannot be found. [CN] 选项描述的样式；找不到文件时为 nil。
     */
    @objc public static func riveStyle(options: CYLRefreshRiveOptions) -> CYLRefreshRiveStyle? {
        guard let url = options.resolvedFileURL() else { return nil }
        let style = CYLRefreshRiveStyle(fileURL: url)
        style.artboardName = options.string("riveArtboard")
        style.stateMachineName = options.string("riveStateMachine")
        if let value = options.number("riveTriggerOffset"), value > 0 { style.triggerOffset = CGFloat(value) }
        if let value = options.number("riveMinimumHeight"), value > 0 { style.minimumHeight = CGFloat(value) }
        style.fitsWidth = options.bool("riveFitsWidth")
        style.pullInput = options.string("rivePullInput")
        if let value = options.number("rivePullInputMinimum") { style.pullInputMinimum = value }
        if let value = options.number("rivePullInputMaximum") { style.pullInputMaximum = value }
        if let value = options.number("rivePullInputStart") { style.pullInputStart = value }
        if let value = options.number("rivePullInputRefreshingValue") { style.pullInputRefreshingValue = value }
        style.releaseTrigger = options.string("riveReleaseTrigger")
        style.finishTrigger = options.string("riveFinishTrigger")
        style.restartTrigger = options.string("riveRestartTrigger")
        style.loadingBoolean = options.string("riveLoadingBoolean")
        style.loadingNumber = options.string("riveLoadingNumber")
        if let value = options.number("riveLoadingNumberMaximum") { style.loadingNumberMaximum = value }
        if let value = options.number("riveLoadingNumberFinished") { style.loadingNumberFinished = value }
        if let value = options.number("riveLoadingNumberDuration"), value > 0 { style.loadingNumberDuration = value }
        style.pullAnimation = options.string("rivePullAnimation")
        style.triggerAnimation = options.string("riveTriggerAnimation")
        style.loadingAnimation = options.string("riveLoadingAnimation")
        style.idleAnimation = options.string("riveIdleAnimation")
        return style
    }

    /**
     * [EN] A `CYLRefreshRiveHeader` of the options; nil when the file is missing or not a Rive file. [CN] 由选项创建的
     *      `CYLRefreshRiveHeader`；文件缺失或不是 Rive 文件时为 nil。
     */
    @objc public static func riveHeader(options: CYLRefreshRiveOptions) -> CYLRefreshHeader? {
        riveStyle(options: options).flatMap { CYLRefreshRiveHeader(style: $0) }
    }

    /**
     * [EN] A `CYLRefreshDrawnFooter` around that header; nil as for the header. [CN] 包着该刷新头的 `CYLRefreshDrawnFooter`；与刷新头一样可能为 nil。
     */
    @objc public static func riveFooter(options: CYLRefreshRiveOptions) -> CYLRefreshFooter? {
        guard let header = riveStyle(options: options).flatMap({ CYLRefreshRiveHeader(style: $0) }) else { return nil }
        return CYLRefreshDrawnFooter(style: header)
    }
}
#endif
