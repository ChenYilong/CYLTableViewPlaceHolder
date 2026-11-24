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
        /// The look: a style name of `CYLRefreshStyleFactory`, nil when the key is missing or not a string. [CN] 外观：`CYLRefreshStyleFactory` 的样式名，键缺失或不是字符串时为 nil。
        var style: String?
        /// The open height Dart uses (its `expandHeight`), when it sends one: the indicator takes it. Optional, so the native
        /// default stays when a Dart version does not send it. [CN] Dart 使用的展开高度（其 `expandHeight`），Dart 发送时指示器采用；
        /// 可选，Dart 版本不发送时保持原生默认值。
        var expandHeight: CGFloat?
        /// How the header moves, when Dart sends it: "front", "behind" (pinned like front) or "stretch";
        /// anything else keeps the style's own mode. [CN] 刷新头的移动方式（Dart 发送时）："front"、"behind"（固定）或 "stretch"；
        /// 其他值保持样式自身的模式。
        var scrollMode: CYLRefreshScrollMode?

        init(_ dictionary: [String: Any]?) {
            footer = dictionary?["footer"] as? Bool == true
            style = dictionary?["style"] as? String
            if let height = (dictionary?["expandHeight"] as? NSNumber)?.doubleValue, height.isFinite, height > 0 { expandHeight = CGFloat(height) }
            switch dictionary?["scrollMode"] as? String {
            case "front": scrollMode = .front
            case "behind": scrollMode = .behind
            case "stretch": scrollMode = .stretch
            default: break
            }
            loadsAfterNoMoreData = dictionary?["loadsAfterNoMoreData"] as? Bool == true
        }
    }

    let params: Params
    /// The view the host puts into a platform view: it clips and shows the slot Dart gives it. [CN] 放进 platform view 的视图：负责裁剪，显示 Dart 给它的槽位。
    let container: UIView
    let layout: CYLRefreshDrivenLayout
    /// The header, or in footer mode the footer, the view hosts. [CN] 视图承载的刷新头（刷新尾模式下为刷新尾）。
    let component: CYLRefreshComponent

    private let onEvent: (String, [String: Any]?) -> Void
    private var phaseObserver: Any?
    private var lastOffset: CGFloat = 0
    private var lastDragging = false

    init(frame: CGRect, params: [String: Any]?, onEvent: @escaping (String, [String: Any]?) -> Void) {
        self.params = Params(params)
        self.onEvent = onEvent
        let container = CYLRefreshSlotContainerView(frame: frame)
        container.clipsToBounds = true
        self.container = container
        layout = CYLRefreshDrivenLayout(frame: CGRect(origin: .zero, size: frame.size))
        container.addSubview(layout)
        // The contract's fallback: a missing or unknown style is the classic one, reported once (a log line here; the channel is not
        // listening yet while the view is created, so an event would be lost).
        let unknownStyle: (String?) -> Void = { name in
            NSLog("CYLRefresh: unknown refresh style %@, using classic", name ?? "(missing)")
        }
        if self.params.footer {
            let footer = CYLRefreshStyleFactory.footer(style: self.params.style, onUnknownStyle: unknownStyle)
            footer.loadsAfterNoMoreData = self.params.loadsAfterNoMoreData
            layout.footer = footer
            component = footer
        } else {
            let header = CYLRefreshStyleFactory.header(style: self.params.style, onUnknownStyle: unknownStyle)
            if let mode = self.params.scrollMode { header.scrollMode = mode }
            layout.header = header
            component = header
        }
        container.onLayout = { [weak self] in self?.updateSlot() }
        phaseObserver = component.addPhaseObserver { [weak self] _, old, new in
            self?.updateSlot()
            self?.onEvent("onPhase", ["phase": Self.name(of: new), "oldPhase": Self.name(of: old)])
        }
        component.refreshingHandler = { [weak self] _ in self?.onEvent("onRefreshing", nil) }
        updateSlot()
    }

    /// Fits the indicator to the Dart slot. Dart shows the bottom (header) or top (footer) `pull` points of the native view; the
    /// view is either one open height tall (the classic indicator, in an `OverflowBox`) or as tall as the pull (the stretched
    /// drawn styles). In both cases the layout is sized to the pull and anchored at that edge of the view, so the indicator
    /// moves in the slot exactly as under a finger, instead of being shifted a second time by the scroll the pull makes inside a
    /// full-height layout (that second shift left the classic header blank or clipped until the pull passed half of it). The
    /// open height is the indicator's own, or Dart's when the creation parameters carry `expandHeight`; never the view's height,
    /// which for the stretched styles changes with every pull.
    /// [CN] 把指示器放进 Dart 的槽位。Dart 只显示原生视图的底部（刷新头）或顶部（刷新尾）`pull` 点；视图要么固定为一个展开高度
    /// （经典指示器，放在 `OverflowBox` 里），要么与下拉量等高（拉伸的手绘样式）。两种情况下布局高度都取下拉量并贴着视图的该边，
    /// 指示器在槽位里的移动与手指下拉时相同，不再被满高度布局内的滚动再移动一次（那次多余的移动让经典刷新头在拉过一半之前空白或被裁剪）。
    /// 展开高度取指示器自身的值，创建参数带 `expandHeight` 时取 Dart 的值；绝不取视图高度，拉伸样式的视图高度每次下拉都在变。
    private func updateSlot() {
        guard layout.superview === container else { return }
        let height = container.bounds.height
        guard height > 0 else { return }
        if let open = params.expandHeight, abs(component.expandHeight - open) > 0.5 {
            if let header = component as? CYLRefreshHeader { header.setExpandHeight(open) } else { component.cyl_h = open }
        }
        let open = component.expandHeight
        let held = component.isRefreshing || (component as? CYLRefreshFooter)?.isNoMoreData == true
        let pull = max(abs(lastOffset), held ? open : 0)
        // Where the header is inside the layout decides where the layout goes, so that the header lands on the slot edge at its
        // own height at every pull (never moved a second time by the scroll, never taller than the layout, never above the view):
        // - move and stretch: the header spans the layout's bottom `pull` points; the layout is anchored at the slot's bottom;
        // - front and behind (a behind header is pinned like a front one, see below): the header is `open` tall at the top of the
        //   layout whatever the pull, and Dart slides or covers the view itself; the layout is anchored at the top and is at least
        //   as tall as the header, and the container does not clip, so what a front header draws below its own frame (the
        //   Material circle, which drops up to about 1.5 open heights at a deep pull) stays visible as under a finger;
        // - footer: anchored at the top.
        // [CN] 刷新头在布局内的位置决定布局的位置，使刷新头在任何下拉量下都以自身高度落在槽位边缘（不被滚动再移动一次、不高于布局、
        //      不跑到视图之上）：
        // - 移动与拉伸：刷新头占布局底部 `pull` 点，布局贴着槽位底部；
        // - 前置与后置（后置刷新头按前置固定，见下）：无论下拉多少，刷新头都在布局顶部、高度为 `open`，视图的滑动或遮盖由 Dart
        //   自己完成；布局贴着顶部且不低于刷新头高度，容器不裁剪，前置刷新头画在自身 frame 之下的内容（Material 圆圈，深度下拉时最多下落
        //   约 1.5 个展开高度）像手指下拉时一样保持可见；
        // - 刷新尾：贴着顶部。
        // A behind header slides in with the content until the pull passes its height; Dart already covers the pinned view with the
        // content, so the host pins it like a front header. [CN] 后置刷新头在下拉超过其高度之前随内容滑入；Dart 已用内容遮盖固定的视图，宿主按前置刷新头固定它。
        if let header = component as? CYLRefreshHeader, header.scrollMode == .behind { header.scrollMode = .front }
        let mode = (component as? CYLRefreshHeader)?.scrollMode
        let pinned = mode == .front || mode == .behind
        let frame: CGRect
        if params.footer {
            frame = CGRect(x: 0, y: 0, width: container.bounds.width, height: pull)
        } else if pinned {
            frame = CGRect(x: 0, y: 0, width: container.bounds.width, height: pull > 0 ? max(pull, open) : 0)
        } else {
            frame = CGRect(x: 0, y: height - pull, width: container.bounds.width, height: pull)
        }
        container.clipsToBounds = !pinned
        if layout.frame != frame { layout.frame = frame }
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
            lastOffset = CGFloat(offset)
            lastDragging = arguments?["dragging"] as? Bool == true
            updateSlot()
            layout.drive(offset: lastOffset, dragging: lastDragging, startedAtEdge: arguments?["startedAtEdge"] as? Bool != false)
        case "release":
            layout.release()
            // A pull past the open height that starts a refresh settles at the open height (the header holds its inset, as under
            // a finger); a pull that is canceled settles at rest. Keep the last fed offset in step, or the layout stays sized
            // and scrolled for the overpull and the held indicator sits outside the slot.
            // [CN] 拉过展开高度并开始刷新的拉动，最终停在展开高度（刷新头保持其 inset，与手指下拉时相同）；被取消的拉动回到静止。
            // 让最近输入的偏移同步，否则布局仍按过度下拉定尺寸与滚动，被保持的指示器会落在槽位之外。
            let open = component.expandHeight
            lastOffset = component.isRefreshing ? (params.footer ? -open : open) : 0
            lastDragging = false
            layout.drive(offset: lastOffset, dragging: false, startedAtEdge: true)
            updateSlot()
        case "finishRefresh":
            if let footer = footer, arguments?["noMoreData"] as? Bool == true {
                footer.endRefreshingWithNoMoreData()
            } else {
                component.endRefreshing(success: arguments?["success"] as? Bool != false)
            }
            updateSlot()
        case "noMoreData":
            guard let footer = footer else { return .error(code: "not_a_footer", message: "noMoreData needs a footer view.") }
            if arguments?["value"] as? Bool == true { footer.noticeNoMoreData() } else { footer.resetNoMoreData() }
            // The footer shows "no more data" only in a scrolled layout: feed the last pull again so the layout scrolls to it.
            updateSlot()
            layout.drive(offset: lastOffset, dragging: lastDragging, startedAtEdge: true)
        default:
            return .notImplemented
        }
        return .success
    }
}

/// A container that reports its layout passes, so the host can refit the indicator when Flutter sizes the view. [CN] 报告布局的容器，Flutter 改变视图大小时宿主据此重新放置指示器。
private final class CYLRefreshSlotContainerView: UIView {
    var onLayout: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?()
    }
}
