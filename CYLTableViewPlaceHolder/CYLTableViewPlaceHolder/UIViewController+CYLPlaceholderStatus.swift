//
//  UIViewController+CYLPlaceholderStatus.swift
//  CYLTableViewPlaceHolder
//
//  [EN] CYLChatKit adds its bar to the controller's view (`[self.view addSubview:self.clientStatusView]`) and hides it
//       while the IM client is connected (-[LCCKConversationViewController updateStatusView]). This does the same
//       through one presenter per controller: the bar sits on the safe area's top edge, the safe area grows by its
//       height while it shows, and the placeholder is switched on or off through `cyl_placeholderHidden`.
//       Swift since 2026-11-19 with the same Objective-C API; the `CYLPlaceholderStatusDisplay` options stay in
//       `UIViewController+CYLPlaceholderStatus.h`, and the `UIScrollView (CYLPlaceholderVisibility)` category is in
//       `UIScrollView+CYLPlaceholder.swift`.
//  [CN] CYLChatKit 把状态条加到控制器的 view 上，并在 IM 客户端连接时隐藏它。这里每个控制器用一个 presenter 完成同样的事：状态条位于安全
//       区域的顶边，显示时安全区域增加其高度，占位图通过 `cyl_placeholderHidden` 打开或关闭。自 2026-11-19 起用 Swift 编写，
//       Objective-C API 不变；`CYLPlaceholderStatusDisplay` 选项保留在 `UIViewController+CYLPlaceholderStatus.h` 中，
//       `UIScrollView (CYLPlaceholderVisibility)` 分类在 `UIScrollView+CYLPlaceholder.swift` 中。
//

import UIKit

// [EN] Above the cells and the placeholder of a table that is the controller's view. [CN] 位于列表单元格与占位图之上。
private let CYLPlaceholderStatusZPosition: CGFloat = 1000

private var CYLPlaceholderStatusPresenterKey: UInt8 = 0

private func CYLStatusPresentationError(_ description: String) -> NSError {
    NSError(domain: CYLPlaceholderConfigurationErrorDomain,
            code: CYLPlaceholderConfigurationError.Code.statusConfiguration.rawValue,
            userInfo: [NSLocalizedDescriptionKey: description])
}

// [EN] One per view controller: shows the bar and switches the placeholder. [CN] 每个视图控制器一个：显示状态条并切换占位图。
private final class CYLPlaceholderStatusPresenter: NSObject {

    weak var viewController: UIViewController?
    weak var scrollView: UIScrollView?
    var display: CYLPlaceholderStatusDisplay = .placeholder
    // [EN] The height added to `additionalSafeAreaInsets.top`, removed when the bar hides. [CN] 加到安全区域上的高度。
    private var addedInset: CGFloat = 0
    private var constraints: [NSLayoutConstraint]?
    private var networkObserver: NSObjectProtocol?
    private var contentSizeObserver: NSObjectProtocol?
    private var storedStatusView: CYLPlaceholderStatusView?

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
        // [EN] A taller Dynamic Type size makes the bar taller; keep the safe area in step.
        // [CN] 动态字体变大时状态条变高；保持安全区域同步。
        contentSizeObserver = NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            DispatchQueue.main.async { self?.updateInset() }
        }
    }

    deinit {
        if let observer = networkObserver { NotificationCenter.default.removeObserver(observer) }
        if let observer = contentSizeObserver { NotificationCenter.default.removeObserver(observer) }
    }

    var statusView: CYLPlaceholderStatusView? {
        get {
            if storedStatusView == nil { storedStatusView = CYLPlaceholderStatusView(frame: .zero) }
            return storedStatusView
        }
        set {
            if storedStatusView === newValue { return }
            let showing = storedStatusView?.superview != nil
            detachBar()
            storedStatusView = newValue
            if showing { apply(animated: false) }
        }
    }

    // [EN] `scrollView`, else the controller's view when it scrolls. [CN] `scrollView`，否则为可滚动的控制器 view。
    var placeholderScrollView: UIScrollView? {
        if let scrollView = scrollView { return scrollView }
        guard let viewController = viewController, viewController.isViewLoaded else { return nil }
        return viewController.view as? UIScrollView
    }

    // MARK: - Display

    private var effectiveDisplay: CYLPlaceholderStatusDisplay {
        var display = self.display
        if showsWhenOffline {
            if CYLPlaceholderNetworkMonitor.shared.networkStatus == .notReachable {
                display.insert(.statusBar)
            } else {
                display.remove(.statusBar)
            }
        }
        return display
    }

    func apply(animated: Bool) {
        let display = effectiveDisplay
        placeholderScrollView?.cyl_placeholderHidden = !display.contains(.placeholder)
        let showBar = display.contains(.statusBar) && (viewController?.isViewLoaded ?? false)
        if showBar {
            attachBar()
            if let bar = statusView {
                if animated && bar.alpha < 1 {
                    UIView.animate(withDuration: 0.25) { bar.alpha = 1 }
                } else {
                    bar.alpha = 1
                }
            }
        } else if let bar = statusView, bar.superview != nil {
            if animated {
                removeInset()
                UIView.animate(withDuration: 0.25, animations: { bar.alpha = 0 }, completion: { _ in
                    if !self.effectiveDisplay.contains(.statusBar) { self.detachBar() }
                })
            } else {
                detachBar()
            }
        }
        // [EN] VoiceOver hears the bar when it appears. [CN] 状态条出现时告知 VoiceOver。
        if showBar && UIAccessibility.isVoiceOverRunning, let text = statusView?.text, !text.isEmpty {
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }

    // MARK: - The bar in the view

    private func attachBar() {
        guard let host = viewController?.view, let bar = statusView else { return }
        if bar.superview !== host {
            detachBar()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.alpha = 0
            bar.layer.zPosition = CYLPlaceholderStatusZPosition
            host.addSubview(bar)
            // [EN] A scroll view's edges belong to its content; its frame guide does not scroll.
            // [CN] 滚动视图的边对应其内容；frame 布局参考不随滚动移动。
            var leading = host.leadingAnchor
            var trailing = host.trailingAnchor
            if let scrollView = host as? UIScrollView {
                leading = scrollView.frameLayoutGuide.leadingAnchor
                trailing = scrollView.frameLayoutGuide.trailingAnchor
            }
            let constraints = [
                bar.leadingAnchor.constraint(equalTo: leading),
                bar.trailingAnchor.constraint(equalTo: trailing),
                // [EN] Right below the navigation bar: the safe area starts under the bar while it shows.
                // [CN] 紧贴导航栏下方：显示期间安全区域从状态条下方开始。
                bar.bottomAnchor.constraint(equalTo: host.safeAreaLayoutGuide.topAnchor),
            ]
            self.constraints = constraints
            NSLayoutConstraint.activate(constraints)
        }
        host.bringSubviewToFront(bar)
        updateInset()
    }

    private func detachBar() {
        removeInset()
        if let constraints = constraints { NSLayoutConstraint.deactivate(constraints) }
        constraints = nil
        storedStatusView?.removeFromSuperview()
    }

    // [EN] The safe area grows by the bar's current height. [CN] 安全区域增加状态条当前的高度。
    private func updateInset() {
        guard let viewController = viewController, let bar = storedStatusView, bar.superview != nil else { return }
        let height = ceil(bar.intrinsicContentSize.height)
        if height == addedInset { return }
        var insets = viewController.additionalSafeAreaInsets
        insets.top += height - addedInset
        addedInset = height
        viewController.additionalSafeAreaInsets = insets
    }

    private func removeInset() {
        guard let viewController = viewController, addedInset != 0 else { return }
        var insets = viewController.additionalSafeAreaInsets
        insets.top = max(0, insets.top - addedInset)
        addedInset = 0
        viewController.additionalSafeAreaInsets = insets
    }

    // MARK: - Network

    var showsWhenOffline = false {
        didSet {
            if oldValue == showsWhenOffline { return }
            if showsWhenOffline {
                let monitor = CYLPlaceholderNetworkMonitor.shared
                monitor.startMonitoring()
                networkObserver = NotificationCenter.default.addObserver(
                    forName: CYLPlaceholderNetworkMonitor.statusDidChangeNotification, object: monitor, queue: .main) { [weak self] _ in
                    self?.apply(animated: true)
                }
            } else if let observer = networkObserver {
                NotificationCenter.default.removeObserver(observer)
                networkObserver = nil
            }
            apply(animated: false)
        }
    }
}

/**
 * [EN] The status bar and the placeholder as two independent components of a view controller (see
 *      `UIViewController+CYLPlaceholderStatus.h`).
 * [CN] 把状态条与占位图作为视图控制器中两个独立的组件显示（见 `UIViewController+CYLPlaceholderStatus.h`）。
 */
extension UIViewController {

    private var cyl_statusPresenter: CYLPlaceholderStatusPresenter {
        if let presenter = objc_getAssociatedObject(self, &CYLPlaceholderStatusPresenterKey) as? CYLPlaceholderStatusPresenter {
            return presenter
        }
        let presenter = CYLPlaceholderStatusPresenter(viewController: self)
        objc_setAssociatedObject(self, &CYLPlaceholderStatusPresenterKey, presenter, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return presenter
    }

    /**
     * [EN] The bar: the network bar (`CYLPlaceholderStatusView(frame:)`) until another is assigned; nil restores it.
     *      Assigning while the bar shows replaces it in place. [CN] 状态条：在赋值其他状态条之前为网络提示条；赋值 nil 恢复默认。
     *      显示中赋值会原地替换。
     */
    @objc public var cyl_statusView: CYLPlaceholderStatusView! {
        get { cyl_statusPresenter.statusView }
        set { cyl_statusPresenter.statusView = newValue }
    }

    /**
     * [EN] The table or collection view whose placeholder `cyl_statusDisplay` shows or hides; by default the controller's
     *      view when it is a scroll view (a UITableViewController). [CN] 由 `cyl_statusDisplay` 控制占位图显示的列表；默认是控制器的
     *      view（如果它是滚动视图，如 UITableViewController）。
     */
    @objc public var cyl_placeholderScrollView: UIScrollView? {
        get { cyl_statusPresenter.placeholderScrollView }
        set {
            let presenter = cyl_statusPresenter
            if presenter.scrollView !== newValue { presenter.placeholderScrollView?.cyl_placeholderHidden = false }
            presenter.scrollView = newValue
            presenter.apply(animated: false)
        }
    }

    /**
     * [EN] What shows; `.placeholder` by default, so nothing changes until it is set. With the bar, the controller's
     *      `additionalSafeAreaInsets.top` grows by the bar's height; the bar grows with Dynamic Type.
     * [CN] 显示的内容；默认 `.placeholder`，设置之前一切不变。显示状态条时，控制器的 `additionalSafeAreaInsets.top` 增加状态条的高度；
     *      状态条随动态字体变高。
     */
    @objc public var cyl_statusDisplay: CYLPlaceholderStatusDisplay {
        get { cyl_statusPresenter.display }
        set { cyl_setStatusDisplay(newValue, animated: false) }
    }

    /**
     * [EN] Sets `cyl_statusDisplay`, fading the bar in or out when `animated` (no movement, so it suits Reduce Motion).
     * [CN] 设置 `cyl_statusDisplay`；`animated` 为 YES 时状态条淡入淡出（不移动，适合“减弱动态效果”）。
     */
    @objc(cyl_setStatusDisplay:animated:)
    public func cyl_setStatusDisplay(_ display: CYLPlaceholderStatusDisplay, animated: Bool) {
        assert(Thread.isMainThread, "Set the status display on the main thread.")
        let presenter = cyl_statusPresenter
        presenter.display = display
        presenter.apply(animated: animated)
    }

    /**
     * [EN] YES: starts the shared network monitor and adds the bar while the network is not reachable, removing it when it
     *      comes back (the placeholder option is kept as it is). NO (the default) leaves the bar to `cyl_statusDisplay`.
     * [CN] YES：启动共享的网络监测，网络不可达时添加状态条，恢复后移除（占位图选项保持不变）。NO（默认）由 `cyl_statusDisplay` 决定。
     */
    @objc public var cyl_showsStatusViewWhenOffline: Bool {
        get { cyl_statusPresenter.showsWhenOffline }
        set { cyl_statusPresenter.showsWhenOffline = newValue }
    }

    /**
     * [EN] The same as `cyl_applyStatusConfiguration(_:)`, from a local ".json" or ".plist" file.
     * [CN] 同 `cyl_applyStatusConfiguration(_:)`，读取本地 ".json" 或 ".plist" 文件。
     */
    @objc(cyl_applyStatusConfigurationWithContentsOfURL:error:)
    public func cyl_applyStatusConfiguration(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        let object: Any = url.pathExtension.lowercased() == "plist" ?
            try PropertyListSerialization.propertyList(from: data, options: [], format: nil) :
            try JSONSerialization.jsonObject(with: data, options: [])
        guard let configuration = object as? [String: Any] else {
            throw CYLStatusPresentationError("The configuration must be a dictionary.")
        }
        try cyl_applyStatusConfiguration(configuration)
    }

    /**
     * [EN] Applies a configuration dictionary: "statusBar" (true or "networkUnavailable" for the network bar, or a
     *      dictionary for `CYLPlaceholderStatusView(configuration:)`), "display" ("statusAndPlaceholder", "status",
     *      "placeholder" or "none"; without it, "statusAndPlaceholder" when "statusBar" is given, else "placeholder") and
     *      "showsWhenOffline" (a boolean). Throws, with nothing changed, when a value is invalid.
     * [CN] 应用配置字典："statusBar"、"display"（缺省时有 "statusBar" 则为 "statusAndPlaceholder"，否则为 "placeholder"）与
     *      "showsWhenOffline"（布尔值）。值无效时抛出错误，不做任何修改。
     */
    @nonobjc
    public func cyl_applyStatusConfiguration(_ configuration: [String: Any]) throws {
        let barValue = configuration["statusBar"]
        var bar: CYLPlaceholderStatusView?
        if let dictionary = barValue as? [String: Any] {
            bar = try CYLPlaceholderStatusView(configuration: dictionary)
        } else if let barValue = barValue, !(barValue is NSNumber || (barValue as? String) == "networkUnavailable") {
            throw CYLStatusPresentationError("\"statusBar\" must be true, \"networkUnavailable\" or a dictionary.")
        }
        let displays: [String: CYLPlaceholderStatusDisplay] = [
            "statusAndPlaceholder": .all, "status": .statusBar, "placeholder": .placeholder, "none": [],
        ]
        let wantsBar = barValue != nil && !((barValue as? NSNumber).map { !$0.boolValue } ?? false)
        let display: CYLPlaceholderStatusDisplay?
        if let displayValue = configuration["display"] {
            display = (displayValue as? String).flatMap { displays[$0] }
        } else {
            display = wantsBar ? .all : .placeholder
        }
        guard let resolvedDisplay = display else {
            throw CYLStatusPresentationError("\"display\" must be \"statusAndPlaceholder\", \"status\", \"placeholder\" or \"none\".")
        }
        let offline = configuration["showsWhenOffline"]
        if let offline = offline, !(offline is NSNumber) {
            throw CYLStatusPresentationError("\"showsWhenOffline\" must be a boolean.")
        }
        if let bar = bar {
            cyl_statusView = bar
        } else if wantsBar {
            // [EN] Back to the network bar. [CN] 恢复为网络提示条。
            cyl_statusView = nil
        }
        if let offline = offline as? NSNumber { cyl_showsStatusViewWhenOffline = offline.boolValue }
        cyl_statusDisplay = resolvedDisplay
    }

    /**
     * [EN] Objective-C: `-cyl_applyStatusConfiguration:error:`. It takes any object, as the Objective-C method did, so that
     *      a configuration that is not a dictionary returns the configuration error instead of failing in the Swift bridge.
     * [CN] Objective-C：`-cyl_applyStatusConfiguration:error:`。与原 Objective-C 方法一样接受任意对象，配置不是字典时返回配置错误，
     *      而不是在 Swift 桥接时崩溃。
     */
    @objc(cyl_applyStatusConfiguration:error:)
    @available(swift, obsoleted: 1, message: "Use cyl_applyStatusConfiguration(_:)")
    public func cyl_applyStatusConfiguration(objcConfiguration configuration: Any) throws {
        guard let dictionary = configuration as? [String: Any] else {
            throw CYLStatusPresentationError("The configuration must be a dictionary.")
        }
        try cyl_applyStatusConfiguration(dictionary)
    }
}
