//
//  CYLRefreshRiveHeader.swift
//  CYLTableViewPlaceHolder
//
//  A refresh header drawn by a Rive file, the counterpart of flutter_easy_refresh's Rive style packages
//  (easy_refresh_bow, _bubbles, _halloween, _skating, _space, _squats; https://github.com/xuelongqy/flutter_easy_refresh,
//  MIT). The packages drive their files in two ways, both covered by CYLRefreshRiveStyle: state machine inputs (a pull
//  number, release / finish / restart triggers, a loading boolean or number) or linear animations (a pull animation
//  scrubbed by time, a trigger animation, a loading loop, an idle loop). The example passes each package's names; the
//  .riv files belong to the example, not to the core.
//  As a footer: CYLRefreshDrawnFooter(style: CYLRefreshRiveHeader(style: ...)).
//

#if canImport(RiveRuntime)
import UIKit
import RiveRuntime

/**
 * [EN] How a Rive file is driven by the pull, the refresh and its end. Every name is optional; unset ones are skipped.
 * [CN] Rive 文件如何随下拉、刷新与结束而变化。每个名称都是可选的；未设置的会被跳过。
 */
@objc(CYLRefreshRiveStyle)
public final class CYLRefreshRiveStyle: NSObject {
    /**
     * [EN] The local .riv file. [CN] 本地 .riv 文件。
     */
    @objc public let fileURL: URL
    /**
     * [EN] The artboard; nil uses the default artboard. [CN] 画板；nil 表示默认画板。
     */
    @objc public var artboardName: String?
    /**
     * [EN] The state machine that the inputs belong to. [CN] 输入所属的状态机。
     */
    @objc public var stateMachineName: String?
    /**
     * [EN] Pull distance (points) that counts as fully pulled; also the header's open height. Default 180.
     * [CN] 视为拉满的距离（点），也是刷新头的展开高度。默认 180。
     */
    @objc public var triggerOffset: CGFloat = 180
    /**
     * [EN] Smallest height the animation is laid out in while it grows with the pull; 0 uses `triggerOffset`.
     * [CN] 动画随下拉变高时的最小布局高度；0 表示使用 `triggerOffset`。
     */
    @objc public var minimumHeight: CGFloat = 0
    /**
     * [EN] YES fits the artboard to the width (Rive `fitWidth`); NO covers the area (Rive `cover`, default).
     * [CN] YES 按宽度适配画板（Rive `fitWidth`）；NO 铺满区域（Rive `cover`，默认）。
     */
    @objc public var fitsWidth = false
    /**
     * [EN] Number input set from the pull. [CN] 随下拉设置的数字输入。
     */
    @objc public var pullInput: String?
    /**
     * [EN] Value of `pullInput` just above no pull (flutter_easy_refresh bow: 10); no pull is always 0. Default 0.
     * [CN] 刚开始拉动时 `pullInput` 的值（flutter_easy_refresh bow 为 10）；未拉动时始终为 0。默认 0。
     */
    @objc public var pullInputMinimum: Double = 0
    /**
     * [EN] Value of `pullInput` when fully pulled. Default 100. [CN] 拉满时 `pullInput` 的值。默认 100。
     */
    @objc public var pullInputMaximum: Double = 100
    /**
     * [EN] Fraction of `triggerOffset` pulled before `pullInput` starts to rise (flutter_easy_refresh bubbles: 4/7).
     *      Default 0. [CN] `pullInput` 开始上升前需拉动的 `triggerOffset` 比例（flutter_easy_refresh bubbles 为 4/7）。默认 0。
     */
    @objc public var pullInputStart: Double = 0
    /**
     * [EN] Value of `pullInput` while refreshing; a negative value (default) keeps `pullInputMaximum`.
     * [CN] 刷新中 `pullInput` 的值；负值（默认）表示保持 `pullInputMaximum`。
     */
    @objc public var pullInputRefreshingValue: Double = -1
    /**
     * [EN] Trigger fired on release. [CN] 松手时触发的触发器。
     */
    @objc public var releaseTrigger: String?
    /**
     * [EN] Trigger fired when the refresh ends. [CN] 刷新结束时触发的触发器。
     */
    @objc public var finishTrigger: String?
    /**
     * [EN] Trigger fired before the next pull, after the file was reset. [CN] 文件重置后、下一次下拉前触发的触发器。
     */
    @objc public var restartTrigger: String?
    /**
     * [EN] Boolean input that is YES from the release until the header is idle again. [CN] 从松手到刷新头再次空闲期间为 YES 的布尔输入。
     */
    @objc public var loadingBoolean: String?
    /**
     * [EN] Number input that rises from 0 to `loadingNumberMaximum` over `loadingNumberDuration` while refreshing and
     *      is set to `loadingNumberFinished` at the end. [CN] 刷新中在 `loadingNumberDuration` 内从 0 升到
     *      `loadingNumberMaximum`、结束时设为 `loadingNumberFinished` 的数字输入。
     */
    @objc public var loadingNumber: String?
    /**
     * [EN] Top value of `loadingNumber` while refreshing. Default 99. [CN] 刷新中 `loadingNumber` 的最大值。默认 99。
     */
    @objc public var loadingNumberMaximum: Double = 99
    /**
     * [EN] Value of `loadingNumber` when the refresh ends. Default 100. [CN] 刷新结束时 `loadingNumber` 的值。默认 100。
     */
    @objc public var loadingNumberFinished: Double = 100
    /**
     * [EN] Seconds for `loadingNumber` to reach its top value. Default 2. [CN] `loadingNumber` 升到最大值所需的秒数。默认 2。
     */
    @objc public var loadingNumberDuration: TimeInterval = 2
    /**
     * [EN] Linear animation scrubbed by the pull: its time in seconds is the pulled fraction (0…1).
     * [CN] 随下拉拖动进度的线性动画：其时间（秒）等于拉动比例（0…1）。
     */
    @objc public var pullAnimation: String?
    /**
     * [EN] Linear animation played once on release, before `loadingAnimation`. [CN] 松手时播放一次、在 `loadingAnimation` 之前的线性动画。
     */
    @objc public var triggerAnimation: String?
    /**
     * [EN] Linear animation looped while refreshing. [CN] 刷新中循环播放的线性动画。
     */
    @objc public var loadingAnimation: String?
    /**
     * [EN] Linear animation looped while pulling and idle. [CN] 下拉与空闲时循环播放的线性动画。
     */
    @objc public var idleAnimation: String?

    /**
     * [EN] A style for the .riv file at `fileURL`. [CN] 使用 `fileURL` 处 .riv 文件的样式。
     */
    @objc public init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }

    /**
     * [EN] `pullInput` for a pull of `offset` points. [CN] 拉动 `offset` 点时 `pullInput` 的值。
     */
    func pullValue(offset: CGFloat) -> Double {
        let trigger = Double(max(1, triggerOffset))
        let start = trigger * min(max(pullInputStart, 0), 0.99)
        let progress = min(max((Double(offset) - start) / (trigger - start), 0), 1)
        if progress == 0 { return 0 }
        return pullInputMinimum + progress * (pullInputMaximum - pullInputMinimum)
    }
}

/**
 * [EN] A refresh header drawn by a Rive file (flutter_easy_refresh's Rive styles). It grows with the pull and keeps
 *      the art laid out in at least `minimumHeight`. Requires iOS 14 (RiveRuntime).
 * [CN] 由 Rive 文件绘制的刷新头（对应 flutter_easy_refresh 的 Rive 样式）。随下拉变高，并让动画至少按 `minimumHeight` 布局。需要
 *      iOS 14（RiveRuntime）。
 */
@available(iOS 14.0, *)
@available(*, deprecated, message: "Uses Rive's legacy API: the style packages' files have state machine inputs and linear animations, not view models.")
@objc(CYLRefreshRiveHeader)
public final class CYLRefreshRiveHeader: CYLRefreshDrawnHeader {
    /**
     * [EN] The style this header was made with. [CN] 创建此刷新头所用的样式。
     */
    @objc public private(set) var riveStyle: CYLRefreshRiveStyle?
    private var viewModel: RiveViewModel?
    private var riveView: RiveView?
    private var loadingTimer: Timer?
    private var loadingStart: Date?
    private var rivePlaysRefresh = false

    /**
     * [EN] A header drawn by `style`; nil when the file cannot be read. [CN] 由 `style` 绘制的刷新头；文件无法读取时为 nil。
     */
    @objc public convenience init?(style: CYLRefreshRiveStyle) {
        guard let data = try? Data(contentsOf: style.fileURL), let file = try? RiveFile(data: data, loadCdn: false) else {
            return nil
        }
        self.init(frame: .zero)
        install(style: style, file: file)
    }

    override public func setUpComponent() {
        super.setUpComponent()
        scrollMode = .stretch
        clipsToBounds = true
        // [EN] Decoration: the header's state is told by the refresh itself. [CN] 装饰：刷新状态由刷新本身表达。
        accessibilityElementsHidden = true
    }

    private func install(style: CYLRefreshRiveStyle, file: RiveFile) {
        riveStyle = style
        setExpandHeight(style.triggerOffset)
        let model = RiveModel(riveFile: file)
        let fit: RiveFit = style.fitsWidth ? .fitWidth : .cover
        let viewModel: RiveViewModel
        if style.stateMachineName != nil {
            viewModel = RiveViewModel(model, stateMachineName: style.stateMachineName, fit: fit, alignment: .center,
                                      autoPlay: true, artboardName: style.artboardName)
        } else {
            viewModel = RiveViewModel(model, animationName: style.idleAnimation ?? style.pullAnimation, fit: fit,
                                      alignment: .center, autoPlay: style.idleAnimation != nil, artboardName: style.artboardName)
        }
        self.viewModel = viewModel
        let view = viewModel.createRiveView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        insertSubview(view, at: 0)
        riveView = view
        setNeedsLayout()
    }

    override public func placeSubviews() {
        super.placeSubviews()
        guard let style = riveStyle, let riveView = riveView else { return }
        // [EN] Laid out bottom-aligned in at least minimumHeight, so the art sits against the content while it grows.
        // [CN] 至少按 minimumHeight 布局并底部对齐，变高时动画贴着内容。
        let minimum = style.minimumHeight > 0 ? style.minimumHeight : style.triggerOffset
        let height = max(bounds.height, minimum)
        riveView.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }

    // MARK: - Pull

    override public func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        super.onScrolling(withOffset: offset, percent: percent, drag: isDragging)
        guard let style = riveStyle, let viewModel = viewModel, !rivePlaysRefresh else { return }
        if let input = style.pullInput {
            viewModel.setInput(input, value: style.pullValue(offset: offset))
        }
        if let animation = style.pullAnimation, style.idleAnimation == nil {
            scrub(animation, to: Float(min(max(offset / max(1, style.triggerOffset), 0), 1)))
        }
    }

    // [EN] Shows `animation` at `time` seconds without playing it. [CN] 在 `time` 秒处显示 `animation`，不播放。
    private func scrub(_ animation: String, to time: Float) {
        guard let viewModel = viewModel else { return }
        if viewModel.riveModel?.animation?.name() != animation {
            try? viewModel.riveModel?.setAnimation(animation)
        }
        viewModel.pause()
        viewModel.riveModel?.animation?.setTime(time)
        riveView?.advance(delta: 0)
    }

    // MARK: - Status

    override public func onStatus(_ oldStatus: CYLRefreshPhase, changed status: CYLRefreshPhase) {
        super.onStatus(oldStatus, changed: status)
        guard let style = riveStyle, let viewModel = viewModel else { return }
        switch status {
        case .releasing:
            guard !rivePlaysRefresh else { break }
            rivePlaysRefresh = true
            if let input = style.pullInput {
                let value = style.pullInputRefreshingValue >= 0 ? style.pullInputRefreshingValue : style.pullInputMaximum
                viewModel.setInput(input, value: value)
            }
            if let trigger = style.releaseTrigger { viewModel.triggerInput(trigger) }
            if let input = style.loadingBoolean { viewModel.setInput(input, value: true) }
            if style.loadingNumber != nil { startLoadingNumber() }
            if let trigger = style.triggerAnimation {
                viewModel.play(animationName: trigger, loop: .oneShot)
                let duration = Double(viewModel.riveModel?.animation?.effectiveDurationInSeconds() ?? 0.5)
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                    guard let self = self, self.rivePlaysRefresh, let loading = style.loadingAnimation else { return }
                    self.viewModel?.play(animationName: loading, loop: .loop)
                }
            } else if let loading = style.loadingAnimation {
                viewModel.play(animationName: loading, loop: .loop)
            }
        case .finishing:
            stopLoadingNumber()
            if let input = style.loadingNumber { viewModel.setInput(input, value: style.loadingNumberFinished) }
            if let trigger = style.finishTrigger { viewModel.triggerInput(trigger) }
        case .idle:
            guard rivePlaysRefresh else { break }
            rivePlaysRefresh = false
            reset()
        default:
            break
        }
    }

    // [EN] Back to the file's first state, as flutter_easy_refresh recreates the controller. [CN] 回到文件的初始状态，与 flutter_easy_refresh 重建控制器相同。
    private func reset() {
        guard let style = riveStyle, let viewModel = viewModel else { return }
        stopLoadingNumber()
        viewModel.reset()
        if let input = style.loadingBoolean { viewModel.setInput(input, value: false) }
        if let input = style.pullInput { viewModel.setInput(input, value: 0.0) }
        if let input = style.loadingNumber { viewModel.setInput(input, value: 0.0) }
        if let trigger = style.restartTrigger { viewModel.triggerInput(trigger) }
        if let idle = style.idleAnimation {
            viewModel.play(animationName: idle, loop: .loop)
        } else if let pull = style.pullAnimation {
            scrub(pull, to: 0)
        } else {
            viewModel.play()
        }
    }

    private func startLoadingNumber() {
        stopLoadingNumber()
        loadingStart = Date()
        let timer = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self = self, let style = self.riveStyle, let input = style.loadingNumber, let start = self.loadingStart else { return }
            let fraction = min(Date().timeIntervalSince(start) / max(0.01, style.loadingNumberDuration), 1)
            self.viewModel?.setInput(input, value: fraction * style.loadingNumberMaximum)
        }
        RunLoop.main.add(timer, forMode: .common)
        loadingTimer = timer
    }

    private func stopLoadingNumber() {
        loadingTimer?.invalidate()
        loadingTimer = nil
    }

    deinit {
        loadingTimer?.invalidate()
    }
}
#endif
