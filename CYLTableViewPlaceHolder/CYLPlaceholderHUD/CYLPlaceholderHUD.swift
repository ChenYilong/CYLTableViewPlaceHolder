//
//  CYLPlaceholderHUD.swift
//  CYLTableViewPlaceHolder
//
//  [EN] The API follows SVProgressHUD (MIT, https://github.com/SVProgressHUD/SVProgressHUD); the implementation is
//       this project's own and draws its content with CYLPlaceholderStackView. Swift since 2026-11-19 with the same
//       Objective-C API (see `CYLPlaceholderHUD.h`); the notification names, the userInfo key, the enums and the
//       dismiss completion block type stay in the header (constants in `CYLPlaceholderHUDSupport.m`).
//  [CN] 接口参考 SVProgressHUD（MIT）；实现为本项目自有，内容由 CYLPlaceholderStackView 绘制。自 2026-11-19 起用 Swift 编写，
//       Objective-C API 不变（见 `CYLPlaceholderHUD.h`）；通知名、userInfo 的 key、枚举与关闭完成 block 类型保留在头文件中
//       （常量在 `CYLPlaceholderHUDSupport.m`）。
//

import UIKit

// [EN] The widest the box gets. [CN] 方框的最大宽度。
private let CYLPlaceholderHUDMaximumWidth: CGFloat = 260
// [EN] The margin the stack view keeps around its components (CYLPlaceholderStackMargin).
// [CN] 组件栈在组件四周保留的边距（CYLPlaceholderStackMargin）。
private let CYLPlaceholderHUDStackMargin: CGFloat = 16

// [EN] `CYLPlaceholderActionHandler` as the Objective-C block it is (Swift imports the typedef as a closure).
// [CN] `CYLPlaceholderActionHandler` 的 Objective-C block 形式（Swift 把该 typedef 导入为闭包）。
private typealias CYLPlaceholderHUDActionBlock = @convention(block) (CYLPlaceholderStackView, CYLPlaceholderAction) -> Void

// [EN] Runs `block` on the main thread, now when already there. [CN] 在主线程执行 `block`；已在主线程时立即执行。
private func CYLPlaceholderHUDOnMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}

/**
 * [EN] A HUD whose content is a placeholder stack view. Use the shared HUD through the class methods (as with
 *      SVProgressHUD), or create one for a view with `init(containerView:)`. Every method runs on the main thread;
 *      calls from another thread are moved there. Objective-C code imports the umbrella header.
 * [CN] 内容为占位图组件栈的 HUD。可通过类方法使用共享 HUD（与 SVProgressHUD 相同），也可用 `init(containerView:)` 为某个视图
 *      创建。所有方法在主线程执行；其他线程的调用会转到主线程。Objective-C 代码请导入总头文件。
 */
@objc(CYLPlaceholderHUD)
open class CYLPlaceholderHUD: UIView {

    /**
     * [EN] The HUD the class methods use. [CN] 类方法使用的共享 HUD。
     */
    @objc(sharedHUD) public static let shared = CYLPlaceholderHUD(containerView: nil)

    // [EN] The box of a loading, progress or result state: one CYLPlaceholderView, no stack view.
    // [CN] 加载、进度与结果状态的方框：一个 CYLPlaceholderView，没有组件栈。
    private var iconView: CYLPlaceholderView?
    private let gradientLayer = CAGradientLayer()
    private var storedStatus: String?
    private var storedForegroundColor: UIColor?
    private var storedHUDBackgroundColor: UIColor?
    private var storedBackgroundLayerColor: UIColor?
    private var storedFont: UIFont?
    private var storedLoadingAnimationFileName: String?
    private var storedSuccessImage: UIImage?
    private var storedErrorImage: UIImage?
    private var storedInfoImage: UIImage?
    private var storedStyle = CYLPlaceholderHUDStyle.automatic
    private var storedMaskType = CYLPlaceholderHUDMaskType.none
    private var storedCornerRadius: CGFloat = 14
    private var storedHapticsEnabled = false
    // [EN] Bumped by every show and dismiss, so a delayed show or dismiss knows whether it is still current.
    // [CN] 每次显示与关闭都会递增，延迟的显示或关闭据此判断自己是否仍然有效。
    private var generation = 0
    // [EN] YES once the box is on screen (after the grace time). [CN] 方框已上屏（宽限时间之后）时为 YES。
    private var presented = false
    // [EN] YES while a show is waiting for its grace time. [CN] 显示正在等待宽限时间时为 YES。
    private var pendingShow = false
    // [EN] YES while the box is being measured and laid out: measuring lays out the content, which must not lay out the
    //      HUD again. [CN] 测量与布局方框期间为 YES：测量会布局内容，而内容不能再次布局 HUD。
    private var layingOutBox = false

    // MARK: - Creating

    /**
     * [EN] A HUD shown over `containerView`; nil shows it over the app's key window. `init()` is the same as
     *      `init(containerView: nil)`. [CN] 显示在 `containerView` 上的 HUD；nil 时显示在应用的 key window 上。`init()` 等同于
     *      `init(containerView: nil)`。
     */
    @objc(initWithContainerView:)
    public init(containerView: UIView?) {
        super.init(frame: .zero)
        self.containerView = containerView
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        alpha = 0

        gradientLayer.type = .radial
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor(white: 0, alpha: 0).cgColor, UIColor(white: 0, alpha: 0.6).cgColor]
        gradientLayer.isHidden = true
        layer.addSublayer(gradientLayer)

        // [EN] The box only positions the content: the background belongs to the CYLPlaceholderView (one icon and
        //      title) or to the stack view of CYLPlaceholderViews, so icon and background cannot drift apart.
        // [CN] 方框只负责定位：背景属于 CYLPlaceholderView（一个图标与标题）或由 CYLPlaceholderView 组成的组件栈，
        //      图标与背景不会错位。
        hudView.accessibilityIdentifier = "CYLPlaceholderHUD"
        addSubview(hudView)
    }

    /**
     * [EN] Not available: use `init(containerView:)`. [CN] 不可用：请使用 `init(containerView:)`。
     */
    @available(*, unavailable)
    public override convenience init(frame: CGRect) {
        // [EN] Also reached by `-init` (UIView's `-init` calls `-initWithFrame:`). [CN] `-init` 也会走到这里（UIView 的 `-init` 调用 `-initWithFrame:`）。
        self.init(containerView: nil)
    }

    /**
     * [EN] Not available: use `init(containerView:)`. [CN] 不可用：请使用 `init(containerView:)`。
     */
    @available(*, unavailable)
    public required convenience init?(coder: NSCoder) {
        self.init(containerView: nil)
    }

    // MARK: - Content

    /**
     * [EN] The packaged icon and title in the box, rebuilt for every new state; nil while hidden. In a loading, progress
     *      or result state it is the box itself (background, corner radius and size), with no stack view around it; while
     *      components are shown it is the first component of `placeholderView`.
     * [CN] 方框中的图标与标题（已封装的 CYLPlaceholderView），每次切换状态时重建；隐藏时为 nil。加载、进度与结果状态中它就是
     *      方框本身（背景、圆角、尺寸），外面没有组件栈；显示组件时为 `placeholderView` 的第一个组件。
     */
    @objc public var contentView: CYLPlaceholderView? {
        iconView ?? placeholderView?.placeholderView
    }

    /**
     * [EN] The stack view of `show(components:actions:)` and `show(scenario:actions:)`, whose elements are all
     *      CYLPlaceholderViews; nil in the other states, which need no stack view. Its handlers and `performAction(_:)` work
     *      as on any placeholder.
     * [CN] `show(components:actions:)` 与 `show(scenario:actions:)` 的组件栈，其中元素都是 CYLPlaceholderView；其他状态不需要组件栈，
     *      为 nil。其处理与 `performAction(_:)` 与普通占位图相同。
     */
    @objc public private(set) var placeholderView: CYLPlaceholderStackView?

    /**
     * [EN] The box. [CN] 方框视图。
     */
    @objc public let hudView = UIView(frame: .zero)

    /**
     * [EN] Handlers for the actions of the components the HUD shows (for example a "Cancel" button added through
     *      `show(components:actions:)`); applied to every state.
     * [CN] HUD 所显示组件的动作处理（例如通过 `show(components:actions:)` 添加的“取消”按钮）；对所有状态生效。
     */
    @nonobjc public var actions: [CYLPlaceholderAction: CYLPlaceholderActionHandler]?

    /**
     * [EN] Objective-C: `actions`, an `NSDictionary` of actions to blocks. Swift cannot represent a dictionary of blocks in
     *      an Objective-C signature, so each block is converted here.
     * [CN] Objective-C：`actions`，动作到 block 的 `NSDictionary`。Swift 无法在 Objective-C 签名中表示 block 字典，因此在这里逐个
     *      转换 block。
     */
    @objc(actions)
    @available(swift, obsoleted: 1, message: "Use actions")
    public var objcActions: NSDictionary? {
        get { CYLPlaceholderHUD.dictionary(from: actions) }
        set { actions = CYLPlaceholderStackView.handlers(from: newValue) }
    }

    /**
     * [EN] What shows now. [CN] 当前显示的内容。
     */
    @objc public private(set) var state = CYLPlaceholderHUDState.hidden

    /**
     * [EN] The status text, nil for none. `setStatus(_:)` changes it on the HUD that shows.
     * [CN] 状态文字，无则为 nil。`setStatus(_:)` 修改正在显示的 HUD 的文字。
     */
    @objc public var status: String? { storedStatus }

    /**
     * [EN] The progress of the Progress state, from 0 to 1. [CN] Progress 状态的进度，0 到 1。
     */
    @objc public private(set) var progress: CGFloat = 0

    /**
     * [EN] YES while the HUD shows or is about to show. [CN] 显示中或即将显示时为 YES。
     */
    @objc(visible) public var isVisible: Bool {
        @objc(isVisible) get { presented || pendingShow }
    }

    /**
     * [EN] How many `show` calls `popActivity()` has not balanced yet. [CN] 尚未被 `popActivity()` 抵消的 `show` 次数。
     */
    @objc public private(set) var activityCount = 0

    // MARK: - Customization

    /**
     * [EN] The view the HUD covers; nil uses the app's key window (set it in an app extension). [CN] HUD 覆盖的视图；
     *      nil 使用应用的 key window（App Extension 中请设置）。
     */
    @objc public weak var containerView: UIView?

    /**
     * [EN] The look of the box (Automatic by default). [CN] 方框外观（默认 Automatic）。
     */
    @objc public var style: CYLPlaceholderHUDStyle {
        get { storedStyle }
        set {
            storedStyle = newValue
            applyAppearance()
        }
    }

    /**
     * [EN] The mask around the box (None by default). [CN] 方框周围的遮罩（默认 None）。
     */
    @objc public var maskType: CYLPlaceholderHUDMaskType {
        get { storedMaskType }
        set {
            storedMaskType = newValue
            applyAppearance()
        }
    }

    /**
     * [EN] The content color of the Custom style; setting it selects the Custom style; nil resets it to black.
     * [CN] Custom 样式的内容颜色；设置后切换到 Custom 样式；设为 nil 恢复为黑色。
     */
    @objc public var foregroundColor: UIColor! {
        get { storedForegroundColor ?? .black }
        set {
            storedForegroundColor = newValue
            if newValue != nil { style = .custom }
            applyAppearance()
        }
    }

    /**
     * [EN] The box color of the Custom style; setting it selects the Custom style; nil resets it to white.
     * [CN] Custom 样式的方框颜色；设置后切换到 Custom 样式；设为 nil 恢复为白色。
     */
    @objc public var hudBackgroundColor: UIColor! {
        get { storedHUDBackgroundColor ?? .white }
        set {
            storedHUDBackgroundColor = newValue
            if newValue != nil { style = .custom }
            applyAppearance()
        }
    }

    /**
     * [EN] The mask color of the Custom mask type (black at 40% by default; nil resets it).
     * [CN] Custom 遮罩的颜色（默认 40% 黑色；设为 nil 恢复默认）。
     */
    @objc public var backgroundLayerColor: UIColor! {
        get { storedBackgroundLayerColor ?? UIColor(white: 0, alpha: 0.4) }
        set { storedBackgroundLayerColor = newValue }
    }

    /**
     * [EN] The status font (the scaled subheadline by default, so it follows Dynamic Type; nil resets it).
     * [CN] 状态文字字体（默认随动态字体缩放的 subheadline；设为 nil 恢复默认）。
     */
    @objc public var font: UIFont! {
        get { storedFont ?? UIFont.preferredFont(forTextStyle: .subheadline) }
        set { storedFont = newValue }
    }

    /**
     * [EN] The corner radius of the box (14 by default). [CN] 方框圆角（默认 14）。
     */
    @objc public var cornerRadius: CGFloat {
        get { storedCornerRadius }
        set {
            storedCornerRadius = newValue
            applyAppearance()
        }
    }

    /**
     * [EN] The smallest size of the box (100 x 100 by default). [CN] 方框的最小尺寸（默认 100 x 100）。
     */
    @objc public var minimumSize = CGSize(width: 100, height: 100)

    /**
     * [EN] The size of the icon or animation (40 x 40 by default). [CN] 图标或动画的尺寸（默认 40 x 40）。
     */
    @objc public var animationSize = CGSize(width: 40, height: 40)

    /**
     * [EN] The offset of the box from the container's center. [CN] 方框相对容器中心的偏移。
     */
    @objc public var offsetFromCenter = UIOffset.zero

    /**
     * [EN] The bundled animation of the Loading state, looping ("CYLRefreshActivity.gif" by default, played by the GIF
     *      subspec; without an animation engine the hourglass image shows; any name of
     *      `CYLPlaceholderView.bundledAnimationFileNames`; nil or "" resets it).
     * [CN] Loading 状态循环播放的内置动画（默认 "CYLRefreshActivity.gif"，由 GIF 子库播放；没有动画引擎时显示沙漏图片；可为任意
     *      内置动画名；设为 nil 或 "" 恢复默认）。
     */
    @objc public var loadingAnimationFileName: String! {
        get {
            if let name = storedLoadingAnimationFileName, !name.isEmpty { return name }
            return "CYLRefreshActivity.gif"
        }
        set { storedLoadingAnimationFileName = newValue }
    }

    /**
     * [EN] A bundled animation scrubbed to the progress in the Progress state. nil by default: the icon keeps looping
     *      `loadingAnimationFileName` and the title shows the percentage. The HUD only uses the icon and title component.
     * [CN] Progress 状态中按进度定位的内置动画。默认 nil：图标循环播放 `loadingAnimationFileName`，标题显示百分比。
     *      HUD 只使用图标与标题组件。
     */
    @objc public var progressAnimationFileName: String?

    /**
     * [EN] The bundled animation of the Success state, played once ("CYLRefreshDoneCircle.json" by default; without
     *      the Lottie engine `successImage` shows). [CN] Success 状态播放一次的内置动画（默认 "CYLRefreshDoneCircle.json"；
     *      没有 Lottie 引擎时显示 `successImage`）。
     */
    @objc public var successAnimationFileName: String? = "CYLRefreshDoneCircle.json"

    /**
     * [EN] The image of the Success state (a checkmark by default; nil resets it). [CN] Success 状态的图片（默认对勾；设为 nil 恢复默认）。
     */
    @objc public var successImage: UIImage! {
        get { storedSuccessImage ?? symbol("checkmark", fallback: .info) }
        set { storedSuccessImage = newValue }
    }

    /**
     * [EN] The image of the Error state (a cross by default; nil resets it). [CN] Error 状态的图片（默认叉号；设为 nil 恢复默认）。
     */
    @objc public var errorImage: UIImage! {
        get { storedErrorImage ?? symbol("xmark", fallback: .error) }
        set { storedErrorImage = newValue }
    }

    /**
     * [EN] The image of the Info state (an exclamation mark by default; nil resets it). [CN] Info 状态的图片（默认感叹号；设为 nil
     *      恢复默认）。
     */
    @objc public var infoImage: UIImage! {
        get { storedInfoImage ?? symbol("exclamationmark", fallback: .info) }
        set { storedInfoImage = newValue }
    }

    /**
     * [EN] How long a `show` waits before the HUD appears, so a quick task shows nothing (0 by default). [CN] `show`
     *      后等待多久才显示，使很快完成的任务不显示 HUD（默认 0）。
     */
    @objc public var graceTimeInterval: TimeInterval = 0

    /**
     * [EN] The shortest time success, error, info and image HUDs stay (5 seconds by default). [CN] 成功、错误、提示与图片 HUD
     *      的最短停留时间（默认 5 秒）。
     */
    @objc public var minimumDismissTimeInterval: TimeInterval = 5

    /**
     * [EN] The longest time they stay (no limit by default). [CN] 最长停留时间（默认不限）。
     */
    @objc public var maximumDismissTimeInterval = TimeInterval(CGFloat.greatestFiniteMagnitude)

    /**
     * [EN] The fade-in duration (0.15 seconds by default). [CN] 淡入时长（默认 0.15 秒）。
     */
    @objc public var fadeInAnimationDuration: TimeInterval = 0.15

    /**
     * [EN] The fade-out duration (0.15 seconds by default). [CN] 淡出时长（默认 0.15 秒）。
     */
    @objc public var fadeOutAnimationDuration: TimeInterval = 0.15

    /**
     * [EN] YES plays notification haptics for success, info (warning) and error (NO by default). [CN] YES 时成功、提示（警告）
     *      与错误播放通知触感（默认 NO）。
     */
    @objc(hapticsEnabled) public var isHapticsEnabled: Bool {
        @objc(isHapticsEnabled) get { storedHapticsEnabled }
        @objc(setHapticsEnabled:) set { storedHapticsEnabled = newValue }
    }

    // [EN] An SF Symbol, else the style's image, as a template. [CN] SF Symbol，否则使用样式图片，均为模板图。
    private func symbol(_ name: String, fallback style: CYLPlaceholderStyle) -> UIImage {
        let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
        if let image = UIImage(systemName: name, withConfiguration: configuration) {
            return image.withRenderingMode(.alwaysTemplate)
        }
        return CYLPlaceholderView.image(for: style)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    }

    // MARK: - Showing

    /**
     * [EN] The looping loading animation without a status. [CN] 不带文字的循环加载动画。
     */
    @objc public func show() {
        show(status: nil)
    }

    /**
     * [EN] The looping loading animation with a status. [CN] 带文字的循环加载动画。
     */
    @objc(showWithStatus:)
    public func show(status: String?) {
        show(progress: -1, status: status)
    }

    /**
     * [EN] A progress from 0 to 1; a negative value shows the loading animation. [CN] 0 到 1 的进度；负数显示加载动画。
     */
    @objc(showProgress:)
    public func show(progress: CGFloat) {
        show(progress: progress, status: nil)
    }

    /**
     * [EN] A progress with a status. [CN] 带文字的进度。
     */
    @objc(showProgress:status:)
    public func show(progress: CGFloat, status: String?) {
        CYLPlaceholderHUDOnMain {
            let determinate = progress >= 0 && !progress.isNaN
            // [EN] Every indeterminate show counts as an activity for `popActivity`; progress updates do not.
            // [CN] 每次不确定进度的显示都计为一次活动（供 `popActivity` 抵消）；进度更新不计数。
            if !determinate || self.activityCount == 0 { self.activityCount += 1 }
            let state: CYLPlaceholderHUDState = determinate ? .progress : .loading
            if self.contentView != nil && self.state == state && self.isVisible {
                // [EN] The same kind of HUD: update in place so the animation does not restart.
                // [CN] 同一种 HUD：原地更新，动画不会重启。
                self.progress = determinate ? min(max(progress, 0), 1) : 0
                self.updateProgress()
                self.setStatus(status)
                return
            }
            self.progress = determinate ? min(max(progress, 0), 1) : 0
            // [EN] Progress scrubs `progressAnimationFileName` when set; otherwise the loading animation keeps looping and
            //      the title carries the percentage. Only the icon and title component is used, no extra view.
            // [CN] 设置了 `progressAnimationFileName` 时按进度定位该动画；否则循环播放加载动画，由标题显示百分比。
            //      只使用图标与标题组件，不添加其他视图。
            var file = self.loadingAnimationFileName
            if determinate, let progressFile = self.progressAnimationFileName, !progressFile.isEmpty { file = progressFile }
            let component = self.iconComponent(animation: file, image: nil, style: .hourglass,
                                               status: self.title(for: status, determinate: determinate), repeatCount: 0)
            self.present([component], state: state, status: status, dismissAfter: 0)
        }
    }

    /**
     * [EN] Changes the status of the HUD that shows, keeping its animation. [CN] 修改正在显示的 HUD 的文字，动画不重启。
     */
    @objc(setStatus:)
    public func setStatus(_ status: String?) {
        CYLPlaceholderHUDOnMain {
            self.storedStatus = status
            guard let view = self.contentView else { return }
            let title = self.title(for: status, determinate: self.state == .progress)
            view.textLabel.text = title
            view.textLabel.isHidden = (title ?? "").isEmpty
            view.accessibilityLabel = status
            view.invalidateIntrinsicContentSize()
            self.layoutBox()
            if let status = status, !status.isEmpty { UIAccessibility.post(notification: .layoutChanged, argument: view) }
        }
    }

    /**
     * [EN] The info image and a status, dismissed after `displayDuration(for:)`. [CN] 提示图片与文字，
     *      在 `displayDuration(for:)` 之后关闭。
     */
    @objc(showInfoWithStatus:)
    public func showInfo(status: String?) {
        showResult(.info, image: infoImage, status: status)
    }

    /**
     * [EN] The success animation and a status, dismissed after `displayDuration(for:)`. [CN] 成功动画与文字，
     *      在 `displayDuration(for:)` 之后关闭。
     */
    @objc(showSuccessWithStatus:)
    public func showSuccess(status: String?) {
        showResult(.success, image: successImage, status: status)
    }

    /**
     * [EN] The error image and a status, dismissed after `displayDuration(for:)`. [CN] 错误图片与文字，
     *      在 `displayDuration(for:)` 之后关闭。
     */
    @objc(showErrorWithStatus:)
    public func showError(status: String?) {
        showResult(.error, image: errorImage, status: status)
    }

    /**
     * [EN] An image and a status, dismissed after `displayDuration(for:)`. [CN] 图片与文字，
     *      在 `displayDuration(for:)` 之后关闭。
     */
    @objc(showImage:status:)
    public func show(image: UIImage, status: String?) {
        showResult(.image, image: image, status: status)
    }

    private func showResult(_ state: CYLPlaceholderHUDState, image: UIImage?, status: String?) {
        CYLPlaceholderHUDOnMain {
            // [EN] A result ends every activity, as in SVProgressHUD. [CN] 结果会结束所有活动，与 SVProgressHUD 相同。
            self.activityCount = 0
            let file = state == .success ? self.successAnimationFileName : nil
            let component = self.iconComponent(animation: file, image: image, style: .info, status: status, repeatCount: 1)
            self.present([component], state: state, status: status, dismissAfter: self.displayDuration(for: status))
            self.playHaptics(for: state)
        }
    }

    /**
     * [EN] Any components in the box (icons, titles, hints, buttons), with handlers for their actions; it stays until
     *      dismissed. [CN] 在方框中显示任意组件（图标、标题、提示、按钮）及其动作处理；直到关闭才消失。
     */
    @nonobjc
    public func show(components: [CYLPlaceholderComponent], actions: [CYLPlaceholderAction: CYLPlaceholderActionHandler]?) {
        CYLPlaceholderHUDOnMain {
            self.activityCount += 1
            var merged = self.actions ?? [:]
            merged.merge(actions ?? [:]) { _, new in new }
            self.present(components, state: .custom, status: nil, dismissAfter: 0, actions: merged)
        }
    }

    /**
     * [EN] A scenario's components in the box (for example `CYLPlaceholderScenario.hud` or `.uploading`); it stays until
     *      dismissed. [CN] 在方框中显示某个场景的组件（例如 `CYLPlaceholderScenario.hud`、`.uploading`）；直到关闭才消失。
     */
    @nonobjc
    public func show(scenario: CYLPlaceholderScenario, actions: [CYLPlaceholderAction: CYLPlaceholderActionHandler]?) {
        show(components: CYLPlaceholderScenarioCatalog.components(for: scenario), actions: actions)
    }

    /**
     * [EN] Objective-C: `-showComponents:actions:`, the actions an `NSDictionary` of actions to blocks.
     * [CN] Objective-C：`-showComponents:actions:`，actions 是动作到 block 的 `NSDictionary`。
     */
    @objc(showComponents:actions:)
    @available(swift, obsoleted: 1, message: "Use show(components:actions:)")
    public func objcShow(components: [CYLPlaceholderComponent], actions: NSDictionary?) {
        show(components: components, actions: CYLPlaceholderStackView.handlers(from: actions))
    }

    /**
     * [EN] Objective-C: `-showScenario:actions:`. [CN] Objective-C：`-showScenario:actions:`。
     */
    @objc(showScenario:actions:)
    @available(swift, obsoleted: 1, message: "Use show(scenario:actions:)")
    public func objcShow(scenario: CYLPlaceholderScenario, actions: NSDictionary?) {
        show(scenario: scenario, actions: CYLPlaceholderStackView.handlers(from: actions))
    }

    // [EN] The Swift handlers as an Objective-C dictionary of blocks. [CN] 把 Swift 处理转换为 Objective-C 的 block 字典。
    private static func dictionary(from handlers: [CYLPlaceholderAction: CYLPlaceholderActionHandler]?) -> NSDictionary? {
        guard let handlers = handlers else { return nil }
        let dictionary = NSMutableDictionary(capacity: handlers.count)
        for (action, handler) in handlers {
            let block: CYLPlaceholderHUDActionBlock = { placeholder, action in handler(placeholder, action) }
            dictionary[action.rawValue] = unsafeBitCast(block, to: AnyObject.self)
        }
        return dictionary.copy() as? NSDictionary
    }

    // MARK: - Building the content

    // [EN] An icon component: a bundled animation (when given and present), else `image`, else `style`, with the status.
    //      The HUD sets the repeat count itself: 0 (loop) for loading and progress, 1 for results.
    // [CN] 图标组件：内置动画（给出且存在时），否则 `image`，否则 `style`，并带上状态文字。重复次数由 HUD 自己设置：加载与进度为 0（循环），
    //      结果为 1。
    private func iconComponent(animation fileName: String?, image: UIImage?, style: CYLPlaceholderStyle, status: String?,
                               repeatCount: Int) -> CYLPlaceholderComponent {
        var file: String?
        if let fileName = fileName, !fileName.isEmpty, CYLPlaceholderView.path(forBundledAnimation: fileName) != nil {
            file = fileName
        }
        let base = CYLPlaceholderComponent(bundledAnimation: file, fallbackStyle: style, title: status,
                                           size: animationSize, action: nil)
        var attributes = base.attributes
        if let image = image, file == nil {
            attributes[CYLPlaceholderItemImage] = image
            attributes.removeValue(forKey: CYLPlaceholderItemStyle)
        }
        if (status ?? "").isEmpty { attributes.removeValue(forKey: CYLPlaceholderItemTitle) }
        attributes[CYLPlaceholderItemTitleFont] = font
        attributes[CYLPlaceholderItemTitleColor] = contentColor()
        attributes[CYLPlaceholderItemIconColor] = contentColor()
        attributes[CYLPlaceholderItemAnimationRepeatCount] = NSNumber(value: repeatCount)
        let component = CYLPlaceholderComponent(attributes: attributes, action: nil)
        component.animationRepeatCount = repeatCount
        component.interactionEnabled = false
        return component
    }

    private func present(_ components: [CYLPlaceholderComponent], state: CYLPlaceholderHUDState, status: String?,
                         dismissAfter delay: TimeInterval) {
        present(components, state: state, status: status, dismissAfter: delay, actions: actions)
    }

    private func present(_ components: [CYLPlaceholderComponent], state: CYLPlaceholderHUDState, status: String?,
                         dismissAfter delay: TimeInterval,
                         actions: [CYLPlaceholderAction: CYLPlaceholderActionHandler]?) {
        generation += 1
        let generation = self.generation
        self.state = state
        storedStatus = status

        placeholderView?.removeFromSuperview()
        iconView?.removeFromSuperview()
        placeholderView = nil
        iconView = nil
        if state == .custom {
            // [EN] Several components with tap actions: a stack view of CYLPlaceholderViews.
            // [CN] 多个带点击动作的组件：由 CYLPlaceholderView 组成的组件栈。
            let placeholder = CYLPlaceholderStackView(components: components, actions: actions)
            placeholder.backgroundAction = nil
            placeholder.accessibilityIdentifier = "CYLPlaceholderHUDContent"
            placeholderView = placeholder
            hudView.addSubview(placeholder)
        } else {
            // [EN] One icon and title: the CYLPlaceholderView is the box itself, with no stack view around it.
            // [CN] 一个图标与标题：CYLPlaceholderView 就是方框本身，外面没有组件栈。
            let component = components.first
            let view: CYLPlaceholderView
            do {
                view = try CYLPlaceholderView(itemAttributes: component?.attributes ?? [:], imageBundle: component?.imageBundle)
            } catch {
                NSLog("CYLTableViewPlaceHolder: HUD content not shown: %@", error.localizedDescription)
                view = CYLPlaceholderView(frame: .zero)
            }
            view.reportsContentSize = true
            view.contentMargin = CYLPlaceholderHUDStackMargin
            // [EN] An absent component messaged in Objective-C gave 0. [CN] Objective-C 中向 nil 组件发消息得到 0。
            view.animationRepeatCount = component?.animationRepeatCount ?? 0
            view.isAccessibilityElement = true
            view.accessibilityLabel = status
            view.accessibilityIdentifier = "CYLPlaceholderHUDContent"
            iconView = view
            hudView.addSubview(view)
        }
        applyAppearance()
        updateProgress()

        guard let container = container() else {
            NSLog("CYLTableViewPlaceHolder: CYLPlaceholderHUD has no container view; set containerView.")
            return
        }
        if superview !== container {
            removeFromSuperview()
            container.addSubview(self)
        }
        container.bringSubviewToFront(self)
        frame = container.bounds
        layoutBox()

        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                if let self = self, self.generation == generation { self.dismissAnimated(completion: nil) }
            }
        }
        if presented {
            // [EN] Shown again, possibly while fading out: back to fully visible. [CN] 再次显示（可能正在淡出）：恢复完全可见。
            UIView.animate(withDuration: fadeInAnimationDuration, delay: 0,
                           options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                self.alpha = 1
            }, completion: nil)
            announce()
            return
        }
        if graceTimeInterval > 0 && !pendingShow {
            pendingShow = true
            isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + graceTimeInterval) { [weak self] in
                guard let hud = self, hud.pendingShow else { return }
                hud.pendingShow = false
                hud.isHidden = false
                hud.fadeIn()
            }
            return
        }
        if !pendingShow { fadeIn() }
    }

    private func fadeIn() {
        presented = true
        let userInfo = statusUserInfo()
        NotificationCenter.default.post(name: .CYLPlaceholderHUDWillAppear, object: self, userInfo: userInfo)
        let reduceMotion = UIAccessibility.isReduceMotionEnabled
        hudView.transform = reduceMotion ? .identity : CGAffineTransform(scaleX: 1.1, y: 1.1)
        let animations = {
            self.alpha = 1
            self.hudView.transform = .identity
        }
        let completion = { (_: Bool) in
            NotificationCenter.default.post(name: .CYLPlaceholderHUDDidAppear, object: self, userInfo: userInfo)
            self.announce()
        }
        if fadeInAnimationDuration > 0 {
            UIView.animate(withDuration: fadeInAnimationDuration, delay: 0,
                           options: [.allowUserInteraction, .beginFromCurrentState], animations: animations,
                           completion: completion)
        } else {
            animations()
            completion(true)
        }
    }

    private func announce() {
        if let status = status, !status.isEmpty { UIAccessibility.post(notification: .announcement, argument: status) }
        UIAccessibility.post(notification: .layoutChanged, argument: contentView)
    }

    private func statusUserInfo() -> [AnyHashable: Any] {
        if let status = status, !status.isEmpty { return [CYLPlaceholderHUDStatusUserInfoKey: status] }
        return [:]
    }

    private func container() -> UIView? {
        if let containerView = containerView { return containerView }
        // [EN] Looked up at run time so the library also links in app extensions, where a container must be set.
        // [CN] 运行时查找，使本库在 App Extension 中也能链接；在扩展中必须设置容器视图。
        guard let applicationType = NSClassFromString("UIApplication") else { return nil }
        let applicationClass = applicationType as AnyObject
        guard applicationClass.responds(to: NSSelectorFromString("sharedApplication")),
              let application = applicationClass.value(forKey: "sharedApplication") as? UIApplication else { return nil }
        for scene in application.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            if scene.activationState != .foregroundActive && scene.activationState != .foregroundInactive { continue }
            if let key = windowScene.windows.first(where: { $0.isKeyWindow }) { return key }
            if let first = windowScene.windows.first { return first }
        }
        // [EN] No foreground scene yet; read through key-value coding, as `windows` is deprecated since iOS 15.
        // [CN] 还没有前台 scene；`windows` 自 iOS 15 起已废弃，因此通过 KVC 读取。
        let windows = application.value(forKey: "windows") as? [UIWindow] ?? []
        if let key = windows.first(where: { $0.isKeyWindow }) { return key }
        return windows.first
    }

    // MARK: - Progress

    // [EN] The title: the status, followed in the Progress state by the percentage when no animation is scrubbed.
    // [CN] 标题：状态文字；在 Progress 状态且没有按进度定位的动画时，后面加上百分比。
    private func title(for status: String?, determinate: Bool) -> String? {
        if !determinate || !(progressAnimationFileName ?? "").isEmpty { return status }
        let percent = NumberFormatter.localizedString(from: NSNumber(value: Double(progress)), number: .percent)
        if let status = status, !status.isEmpty { return "\(status) \(percent)" }
        return percent
    }

    private func updateProgress() {
        if state != .progress { return }
        let view = contentView
        if !(progressAnimationFileName ?? "").isEmpty {
            view?.stopPlaceholderAnimation()
            _ = view?.setPlaceholderAnimationProgress(progress)
        }
        let percent = NumberFormatter.localizedString(from: NSNumber(value: Double(progress)), number: .percent)
        view?.accessibilityValue = percent
        setNeedsLayout()
    }

    // MARK: - Dismissing

    /**
     * [EN] Balances one `show`: the HUD is dismissed when every `show` is balanced. [CN] 抵消一次 `show`：所有 `show`
     *      都被抵消后关闭 HUD。
     */
    @objc public func popActivity() {
        CYLPlaceholderHUDOnMain {
            if self.activityCount > 0 { self.activityCount -= 1 }
            if self.activityCount == 0 { self.dismissAnimated(completion: nil) }
        }
    }

    /**
     * [EN] Dismisses now. [CN] 立即关闭。
     */
    @objc public func dismiss() {
        dismiss(withDelay: 0, completion: nil)
    }

    /**
     * [EN] Dismisses now and runs `completion` afterwards. [CN] 立即关闭，完成后调用 `completion`。
     */
    @objc(dismissWithCompletion:)
    public func dismiss(completion: CYLPlaceholderHUDDismissCompletion?) {
        dismiss(withDelay: 0, completion: completion)
    }

    /**
     * [EN] Dismisses after `delay` seconds. [CN] `delay` 秒后关闭。
     */
    @objc(dismissWithDelay:)
    public func dismiss(withDelay delay: TimeInterval) {
        dismiss(withDelay: delay, completion: nil)
    }

    /**
     * [EN] Dismisses after `delay` seconds and runs `completion` afterwards. [CN] `delay` 秒后关闭，完成后调用 `completion`。
     */
    @objc(dismissWithDelay:completion:)
    public func dismiss(withDelay delay: TimeInterval, completion: CYLPlaceholderHUDDismissCompletion?) {
        CYLPlaceholderHUDOnMain {
            if delay <= 0 {
                self.dismissAnimated(completion: completion)
                return
            }
            self.scheduleDismiss(after: delay, completion: completion)
        }
    }

    // [EN] A delayed dismissal, skipped (only `completion` runs) when the HUD was shown or dismissed meanwhile.
    // [CN] 延迟关闭；期间 HUD 再次显示或已关闭时跳过（只调用 `completion`）。
    private func scheduleDismiss(after delay: TimeInterval, completion: CYLPlaceholderHUDDismissCompletion?) {
        let generation = self.generation
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            if let hud = self, hud.generation == generation {
                hud.dismissAnimated(completion: completion)
            } else {
                completion?()
            }
        }
    }

    private func dismissAnimated(completion: CYLPlaceholderHUDDismissCompletion?) {
        activityCount = 0
        generation += 1
        let generation = self.generation
        if pendingShow {
            // [EN] Dismissed within the grace time: nothing was shown, so nothing is announced.
            // [CN] 在宽限时间内关闭：未曾显示，因此不发送通知。
            pendingShow = false
            tearDown()
            completion?()
            return
        }
        if !presented {
            completion?()
            return
        }
        let userInfo = statusUserInfo()
        NotificationCenter.default.post(name: .CYLPlaceholderHUDWillDisappear, object: self, userInfo: userInfo)
        let finish = { (_: Bool) in
            // [EN] Shown again meanwhile. [CN] 期间再次显示。
            if self.generation != generation { return }
            self.tearDown()
            NotificationCenter.default.post(name: .CYLPlaceholderHUDDidDisappear, object: self, userInfo: userInfo)
            UIAccessibility.post(notification: .screenChanged, argument: nil)
            completion?()
        }
        if fadeOutAnimationDuration > 0 {
            UIView.animate(withDuration: fadeOutAnimationDuration, delay: 0,
                           options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                self.alpha = 0
            }, completion: finish)
        } else {
            alpha = 0
            finish(true)
        }
    }

    private func tearDown() {
        presented = false
        isHidden = false
        alpha = 0
        state = .hidden
        storedStatus = nil
        progress = 0
        placeholderView?.removeFromSuperview()
        iconView?.removeFromSuperview()
        placeholderView = nil
        iconView = nil
        removeFromSuperview()
    }

    /**
     * [EN] How long a status stays: 0.06 seconds per character plus 0.5, within the minimum and maximum dismiss
     *      intervals. [CN] 文字的停留时间：每个字符 0.06 秒再加 0.5 秒，限制在最短与最长停留时间之间。
     */
    @objc(displayDurationForString:)
    public func displayDuration(for string: String?) -> TimeInterval {
        // [EN] `length` counts UTF-16 units, as the Objective-C version did. [CN] `length` 按 UTF-16 单元计数，与 Objective-C 版本相同。
        let duration = TimeInterval((string as NSString?)?.length ?? 0) * 0.06 + 0.5
        return min(max(duration, minimumDismissTimeInterval), maximumDismissTimeInterval)
    }

    // MARK: - Appearance and layout

    private func contentColor() -> UIColor {
        switch style {
        case .light: return .black
        case .dark: return .white
        case .custom: return foregroundColor
        default:
            return .label
        }
    }

    // [EN] The view that draws the box: the CYLPlaceholderView of an icon state, else the stack view of components.
    // [CN] 绘制方框的视图：图标状态下为 CYLPlaceholderView，否则为组件栈。
    private var boxView: UIView? {
        iconView ?? placeholderView
    }

    private func boxColor() -> UIColor {
        let solid = UIAccessibility.isReduceTransparencyEnabled
        switch style {
        case .light:
            return UIColor(white: 1, alpha: solid ? 1 : 0.94)
        case .dark:
            return UIColor(white: solid ? 0.1 : 0, alpha: solid ? 1 : 0.8)
        case .custom:
            return hudBackgroundColor
        default:
            return solid ? .secondarySystemBackground : UIColor.secondarySystemBackground.withAlphaComponent(0.94)
        }
    }

    private func applyAppearance() {
        if let box = boxView {
            box.backgroundColor = boxColor()
            box.layer.cornerRadius = cornerRadius
            box.clipsToBounds = true
        }
        for component in placeholderView?.componentViews ?? [] {
            component.backgroundColor = .clear
        }
        hudView.backgroundColor = .clear

        switch maskType {
        case .black:
            backgroundColor = UIColor(white: 0, alpha: 0.4)
        case .custom:
            backgroundColor = backgroundLayerColor
        default:
            backgroundColor = .clear
        }
        gradientLayer.isHidden = maskType != .gradient
        // [EN] A mask that blocks touches also keeps VoiceOver inside the box. [CN] 阻止触摸的遮罩同时把 VoiceOver 限制在方框内。
        accessibilityViewIsModal = maskType != .none
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutBox()
    }

    private func layoutBox() {
        // [EN] `layoutIfNeeded` on the content can lay out this view again; a nested call returns at once.
        // [CN] 对内容调用 `layoutIfNeeded` 可能再次布局本视图；嵌套调用直接返回。
        if layingOutBox { return }
        layingOutBox = true
        measureAndPlaceBox()
        layingOutBox = false
    }

    private func measureAndPlaceBox() {
        gradientLayer.frame = bounds
        guard let box = boxView else { return }
        let maxWidth = min(CYLPlaceholderHUDMaximumWidth, max(bounds.size.width - 32, minimumSize.width))
        var content: CGSize
        if let iconView = iconView {
            // [EN] The CYLPlaceholderView measures itself; its content margin is the box's side padding.
            // [CN] CYLPlaceholderView 自行测量；其内容边距就是方框左右的留白。
            iconView.preferredMaxLayoutWidth = maxWidth
            let size = iconView.intrinsicContentSize
            content = CGSize(width: ceil(size.width) - 2 * CYLPlaceholderHUDStackMargin, height: ceil(size.height))
        } else if let placeholderView = placeholderView {
            placeholderView.frame = CGRect(x: 0, y: 0, width: maxWidth, height: 1000)
            placeholderView.layoutIfNeeded()
            content = placeholderView.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        } else {
            content = .zero
        }
        let width = min(maxWidth, max(minimumSize.width, ceil(content.width) + 2 * CYLPlaceholderHUDStackMargin))
        let height = max(minimumSize.height, ceil(content.height) + 2 * CYLPlaceholderHUDStackMargin)
        let center = CGPoint(x: bounds.midX + offsetFromCenter.horizontal, y: bounds.midY + offsetFromCenter.vertical)
        hudView.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        hudView.center = center
        box.frame = hudView.bounds
        box.layoutIfNeeded()
    }

    // MARK: - Touches and haptics

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || alpha < 0.01 { return nil }
        let hit = super.hitTest(point, with: event)
        let insideBox = hudView.point(inside: convert(point, to: hudView), with: event)
        // [EN] A nil event counts as a touch, as messaging nil gave UIEventTypeTouches (0) in Objective-C.
        // [CN] nil 事件视为触摸：Objective-C 中向 nil 发消息得到 UIEventTypeTouches（0）。
        let isTouch = (event?.type ?? .touches) == .touches
        if insideBox {
            if isTouch {
                NotificationCenter.default.post(name: .CYLPlaceholderHUDDidTouchDownInside, object: event)
            }
            return hit
        }
        if isTouch {
            NotificationCenter.default.post(name: .CYLPlaceholderHUDDidReceiveTouchEvent, object: event)
        }
        // [EN] Without a mask, touches outside the box reach the views behind. [CN] 无遮罩时，方框外的触摸传给后面的视图。
        return maskType == .none ? nil : self
    }

    private func playHaptics(for state: CYLPlaceholderHUDState) {
        if !isHapticsEnabled { return }
        let type: UINotificationFeedbackGenerator.FeedbackType
        switch state {
        case .success: type = .success
        case .info: type = .warning
        case .error: type = .error
        default: return
        }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    // MARK: - Shared HUD (SVProgressHUD-style class methods)

    /**
     * [EN] `shared.show()`. [CN] 即 `shared.show()`。
     */
    @objc public class func show() { shared.show() }

    /**
     * [EN] `shared.show(status:)`. [CN] 即 `shared.show(status:)`。
     */
    @objc(showWithStatus:)
    public class func show(status: String?) { shared.show(status: status) }

    /**
     * [EN] `shared.show(progress:)`. [CN] 即 `shared.show(progress:)`。
     */
    @objc(showProgress:)
    public class func show(progress: CGFloat) { shared.show(progress: progress) }

    /**
     * [EN] `shared.show(progress:status:)`. [CN] 即 `shared.show(progress:status:)`。
     */
    @objc(showProgress:status:)
    public class func show(progress: CGFloat, status: String?) { shared.show(progress: progress, status: status) }

    /**
     * [EN] `shared.setStatus(_:)`. [CN] 即 `shared.setStatus(_:)`。
     */
    @objc(setStatus:)
    public class func setStatus(_ status: String?) { shared.setStatus(status) }

    /**
     * [EN] `shared.showInfo(status:)`. [CN] 即 `shared.showInfo(status:)`。
     */
    @objc(showInfoWithStatus:)
    public class func showInfo(status: String?) { shared.showInfo(status: status) }

    /**
     * [EN] `shared.showSuccess(status:)`. [CN] 即 `shared.showSuccess(status:)`。
     */
    @objc(showSuccessWithStatus:)
    public class func showSuccess(status: String?) { shared.showSuccess(status: status) }

    /**
     * [EN] `shared.showError(status:)`. [CN] 即 `shared.showError(status:)`。
     */
    @objc(showErrorWithStatus:)
    public class func showError(status: String?) { shared.showError(status: status) }

    /**
     * [EN] `shared.show(image:status:)`. [CN] 即 `shared.show(image:status:)`。
     */
    @objc(showImage:status:)
    public class func show(image: UIImage, status: String?) { shared.show(image: image, status: status) }

    /**
     * [EN] `shared.popActivity()`. [CN] 即 `shared.popActivity()`。
     */
    @objc public class func popActivity() { shared.popActivity() }

    /**
     * [EN] `shared.dismiss()`. [CN] 即 `shared.dismiss()`。
     */
    @objc public class func dismiss() { shared.dismiss() }

    /**
     * [EN] `shared.dismiss(completion:)`. [CN] 即 `shared.dismiss(completion:)`。
     */
    @objc(dismissWithCompletion:)
    public class func dismiss(completion: CYLPlaceholderHUDDismissCompletion?) { shared.dismiss(completion: completion) }

    /**
     * [EN] `shared.dismiss(withDelay:)`. [CN] 即 `shared.dismiss(withDelay:)`。
     */
    @objc(dismissWithDelay:)
    public class func dismiss(withDelay delay: TimeInterval) { shared.dismiss(withDelay: delay) }

    /**
     * [EN] `shared.dismiss(withDelay:completion:)`. [CN] 即 `shared.dismiss(withDelay:completion:)`。
     */
    @objc(dismissWithDelay:completion:)
    public class func dismiss(withDelay delay: TimeInterval, completion: CYLPlaceholderHUDDismissCompletion?) {
        shared.dismiss(withDelay: delay, completion: completion)
    }

    /**
     * [EN] `shared.isVisible`. [CN] 即 `shared.isVisible`。
     */
    @objc(isVisible)
    public class func isVisible() -> Bool { shared.isVisible }

    /**
     * [EN] `shared.displayDuration(for:)`. [CN] 即 `shared.displayDuration(for:)`。
     */
    @objc(displayDurationForString:)
    public class func displayDuration(for string: String?) -> TimeInterval { shared.displayDuration(for: string) }
}
