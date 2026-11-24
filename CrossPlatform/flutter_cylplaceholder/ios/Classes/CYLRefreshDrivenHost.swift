import UIKit
// [EN] The plugin imports the library as a module; the unit tests compile this file into the library's own module (there is no
//      Flutter there), where the import would be circular.
// [CN] 插件把库当作模块导入；单元测试把本文件直接编译进库自己的模块（那里没有 Flutter），此时导入会循环。
#if canImport(Flutter)
import CYLTableViewPlaceHolder
#endif

/**
 * [EN] What a call on the refresh view's channel came to: done, a channel error, or a method this view does not have.
 * [CN] 刷新视图通道上一次调用的结果：完成、通道错误，或本视图没有的方法。
 */
enum CYLRefreshHostResult: Equatable {
    case success
    case error(code: String, message: String)
    case notImplemented
}

/**
 * [EN] The Flutter-free core of the native refresh view, the iOS counterpart of Android's `CYLRefreshPlatformView`: a
 *      `CYLRefreshDrivenLayout` with a `CYLRefreshNormalHeader`, or, when the creation parameters say `footer: true`, a
 *      `CYLRefreshBackNormalFooter` (with `loadsAfterNoMoreData` when asked). Dart feeds the pull through `handle(method:arguments:)`
 *      with the Android contract: "drive" (`offset` in logical pixels, which are points here, negative for a footer, `dragging`,
 *      `startedAtEdge`), "release", "finishRefresh" (`success`; a footer's `noMoreData: true` ends the load and shows "no more
 *      data") and, footer only, "noMoreData" (`value`). The view reports back through `onEvent`: "onPhase" (`phase` and
 *      `oldPhase`, the lower camel case names of `CYLRefreshPhase`) and "onRefreshing". The Flutter view class only forwards
 *      the channel to this type, so the behavior is testable without Flutter (`Tests/CYLRefreshDrivenHostTests.swift`).
 * [CN] 原生刷新视图中不依赖 Flutter 的部分，对应 Android 的 `CYLRefreshPlatformView`：`CYLRefreshDrivenLayout` 挂 `CYLRefreshNormalHeader`，
 *      创建参数为 `footer: true` 时挂 `CYLRefreshBackNormalFooter`（按需带 `loadsAfterNoMoreData`）。Dart 通过
 *      `handle(method:arguments:)` 按 Android 的约定输入拉动：“drive”、“release”、“finishRefresh”、“noMoreData”；视图经 `onEvent`
 *      回报“onPhase”与“onRefreshing”。Flutter 视图类只把通道转发给本类型，所以无需 Flutter 即可测试。
 */
final class CYLRefreshDrivenHost {
    /// The creation parameters of the view. [CN] 视图的创建参数。
    struct Params: Equatable {
        var footer = false
        var loadsAfterNoMoreData = false

        init(_ dictionary: [String: Any]?) {
            footer = dictionary?["footer"] as? Bool == true
            loadsAfterNoMoreData = dictionary?["loadsAfterNoMoreData"] as? Bool == true
        }
    }

    let params: Params
    let layout: CYLRefreshDrivenLayout
    /// The header, or in footer mode the footer, the view hosts. [CN] 视图承载的刷新头（刷新尾模式下为刷新尾）。
    let component: CYLRefreshComponent

    private let onEvent: (String, [String: Any]?) -> Void
    private var phaseObserver: Any?

    init(frame: CGRect, params: [String: Any]?, onEvent: @escaping (String, [String: Any]?) -> Void) {
        self.params = Params(params)
        self.onEvent = onEvent
        layout = CYLRefreshDrivenLayout(frame: frame)
        layout.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if self.params.footer {
            let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
            footer.loadsAfterNoMoreData = self.params.loadsAfterNoMoreData
            layout.footer = footer
            component = footer
        } else {
            let header = CYLRefreshNormalHeader(refreshingBlock: {})
            layout.header = header
            component = header
        }
        phaseObserver = component.addPhaseObserver { [weak self] _, old, new in
            self?.onEvent("onPhase", ["phase": Self.name(of: new), "oldPhase": Self.name(of: old)])
        }
        component.refreshingHandler = { [weak self] _ in self?.onEvent("onRefreshing", nil) }
    }

    /// The lower camel case name of a phase, as Android sends it. [CN] 阶段的小驼峰名称，与 Android 发送的相同。
    static func name(of phase: CYLRefreshPhase) -> String {
        switch phase {
        case .idle: return "idle"
        case .pullToRefresh: return "pullToRefresh"
        case .releaseToRefresh: return "releaseToRefresh"
        case .willRefresh: return "willRefresh"
        case .releasing: return "releasing"
        case .refreshing: return "refreshing"
        case .finishing: return "finishing"
        case .noMoreData: return "noMoreData"
        case .secondaryArmed: return "secondaryArmed"
        case .secondaryOpen: return "secondaryOpen"
        case .secondaryClosing: return "secondaryClosing"
        @unknown default: return "phase\(phase.rawValue)"
        }
    }

    /// Applies one call of the channel. [CN] 处理通道上的一次调用。
    func handle(method: String, arguments: [String: Any]?) -> CYLRefreshHostResult {
        let footer = component as? CYLRefreshFooter
        switch method {
        case "drive":
            guard let offset = (arguments?["offset"] as? NSNumber)?.doubleValue, offset.isFinite else {
                return .error(code: "bad_arguments", message: "drive needs an offset.")
            }
            layout.drive(offset: CGFloat(offset), dragging: arguments?["dragging"] as? Bool == true, startedAtEdge: arguments?["startedAtEdge"] as? Bool != false)
        case "release":
            layout.release()
        case "finishRefresh":
            if let footer = footer, arguments?["noMoreData"] as? Bool == true {
                footer.endRefreshingWithNoMoreData()
            } else {
                component.endRefreshing(success: arguments?["success"] as? Bool != false)
            }
        case "noMoreData":
            guard let footer = footer else { return .error(code: "not_a_footer", message: "noMoreData needs a footer view.") }
            if arguments?["value"] as? Bool == true { footer.noticeNoMoreData() } else { footer.resetNoMoreData() }
        default:
            return .notImplemented
        }
        return .success
    }
}
