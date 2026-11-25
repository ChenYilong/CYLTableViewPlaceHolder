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
     * [EN] Longest time in seconds the header stays open after the refresh ends so that the end of the animation (`finishTrigger`
     *      or the `loadingNumber` finished value) can play; it retracts earlier when the animation stops. Ignored when the style has
     *      neither. Default 1.5. [CN] 刷新结束后为让动画的结束部分（`finishTrigger` 或 `loadingNumber` 的结束值）播放完，刷新头最长保持展开的秒数；
     *      动画停止时会提前收回。两者都没有时忽略。默认 1.5。
     */
    @objc public var finishTimeout: TimeInterval = 1.5
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
     * [EN] Per-file table of [pullInput, drawnFraction] pairs sorted by input: the share of the header height the file draws at that input
     *      (the rest, at the bottom, is black). Linear between pairs, the first fraction below the first pair, the last above the last. The Rive view is
     *      moved down so that this share touches the bottom of the header (the black below the art falls outside; the slack shows above it); empty (default) means no change. [CN] 按文件的 [pullInput, drawnFraction] 数对表（按输入排序）：
     *      文件在该输入下画出的刷新头高度比例（其余部分，在底部，为黑色）。数对之间线性插值，低于第一对取第一个比例，高于最后一对取最后一个比例。
     *      Rive 视图下移，使该比例贴着刷新头底边（艺术图下方的黑色落在刷新头之外，空余显示在其上方）；为空（默认）表示不变。
     */
    @objc public var drawnTable: [[Double]] = []
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
    // [EN] YES when the end of a refresh has a part of the animation to wait for. [CN] 刷新结束时是否有动画的结束部分需要等待。
    var playsFinish: Bool { finishTrigger != nil || loadingNumber != nil }

    // [EN] The share of the header height that is drawn at `input`; 1 without a table. [CN] `input` 处已绘制的刷新头高度比例；没有表时为 1。
    func drawnFraction(forInput input: Double) -> Double {
        CYLRefreshRiveDrawnTable.fraction(forInput: input, table: drawnTable)
    }

    func pullValue(offset: CGFloat) -> Double {
        let trigger = Double(max(1, triggerOffset))
        let start = trigger * min(max(pullInputStart, 0), 0.99)
        let progress = min(max((Double(offset) - start) / (trigger - start), 0), 1)
        if progress == 0 { return 0 }
        return pullInputMinimum + progress * (pullInputMaximum - pullInputMinimum)
    }
}

// [EN] A view model that tells when Rive paused or stopped (the state machine settled, a one-shot animation ended) after calling
//      its own handling, which keeps the view model's play state right. [CN] 在 Rive 暂停或停止（状态机稳定、单次动画结束）时通知的
//      ViewModel；先执行自身的处理，以保持 ViewModel 的播放状态正确。
@available(*, deprecated, message: "Uses Rive's legacy API.")
private final class CYLRiveStopReportingViewModel: RiveViewModel {
    var onStop: (() -> Void)?

    override func player(pausedWithModel riveModel: RiveModel?) {
        super.player(pausedWithModel: riveModel)
        onStop?()
    }

    override func player(stoppedWithModel riveModel: RiveModel?) {
        super.player(stoppedWithModel: riveModel)
        onStop?()
    }
}

/**
 * [EN] A refresh header drawn by a Rive file (flutter_easy_refresh's Rive styles). It grows with the pull and keeps
 *      the art laid out in at least `minimumHeight`. Requires iOS 14 (RiveRuntime).
 * [CN] 由 Rive 文件绘制的刷新头（对应 flutter_easy_refresh 的 Rive 样式）。随下拉变高，并让动画至少按 `minimumHeight` 布局。需要
 *      iOS 14（RiveRuntime）。
 */
@available(*, deprecated, message: "Uses Rive's legacy API: the style packages' files have state machine inputs and linear animations, not view models.")
@objc(CYLRefreshRiveHeader)
public final class CYLRefreshRiveHeader: CYLRefreshDrawnHeader {
    /**
     * [EN] The style this header was made with. [CN] 创建此刷新头所用的样式。
     */
    @objc public private(set) var riveStyle: CYLRefreshRiveStyle?
    private var viewModel: CYLRiveStopReportingViewModel?
    private var riveView: RiveView?
    private var loadingTimer: Timer?
    private var loadingStart: Date?
    private var rivePlaysRefresh = false
    // [EN] The pull input last set, for the drawn-height placement. [CN] 最近一次设置的下拉输入，供已绘制高度的裁剪使用。
    private var currentInput: Double = 0
    private let drawnMask = CALayer()
    // [EN] YES from the finish trigger until the animation stops or the hold ends. [CN] 从触发结束触发器到动画停止或停留结束期间为 YES。
    private var awaitsFinishEnd = false
    // [EN] The poll that ends the post-refresh retract (see `beginRetract`); nil when the header is not retracting. [CN] 结束刷新后收回阶段的轮询（见 `beginRetract`）；未收回时为 nil。
    private var retractTimer: Timer?

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
        let viewModel: CYLRiveStopReportingViewModel
        if style.stateMachineName != nil {
            viewModel = CYLRiveStopReportingViewModel(model, stateMachineName: style.stateMachineName, fit: fit, alignment: .center,
                                      autoPlay: true, artboardName: style.artboardName)
        } else {
            viewModel = CYLRiveStopReportingViewModel(model, animationName: style.idleAnimation ?? style.pullAnimation, fit: fit,
                                      alignment: .center, autoPlay: style.idleAnimation != nil, artboardName: style.artboardName)
        }
        self.viewModel = viewModel
        viewModel.onStop = { [weak self] in self?.finishAnimationStopped() }
        let view = viewModel.createRiveView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        insertSubview(view, at: 0)
        riveView = view
        setNeedsLayout()
    }

    override public func placeSubviews() {
        super.placeSubviews()
        placeRiveView()
    }

    // [EN] Lays the Rive view out bottom-aligned in at least minimumHeight, so the art sits against the content while it grows.
    //      With a `drawnTable` the view is also moved down by the part of the header the file does not draw at the current input
    //      (`CYLRefreshRiveDrawnTable.slack`): the drawn art touches the first row, the slack shows above it, and the black the file
    //      draws below its art falls outside the header (`clipsToBounds`), and a mask hides the slack above the art. The list's own slot is not changed, so the finish hold is
    //      as before. Runs on every layout and input change, so it follows the pull, the hold and the retract.
    // [CN] 至少按 minimumHeight 布局并底部对齐，变高时动画贴着内容。有 `drawnTable` 时，Rive 视图还会下移文件在当前输入下没有画出的那部分
    //      刷新头高度（`CYLRefreshRiveDrawnTable.slack`）：画出的内容贴着第一行，空余在其上方，文件在内容下方画的黑色落在刷新头之外
    //      （`clipsToBounds`），遮罩隐藏艺术图上方的空余。列表自己的占位不变，所以结束停留与之前相同。每次布局与输入变化都会执行，因此随下拉、停留与收回变化。
    private func placeRiveView() {
        // [EN] The art keeps its place while the header retracts (`beginRetract`). [CN] 刷新头收回期间，画面保持原位（见 `beginRetract`）。
        guard let style = riveStyle, let riveView = riveView, retractTimer == nil else { return }
        let minimum = style.minimumHeight > 0 ? style.minimumHeight : style.triggerOffset
        let height = max(bounds.height, minimum)
        guard !style.drawnTable.isEmpty else {
            riveView.layer.mask = nil
            riveView.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
            return
        }
        // [EN] While pulling or retracting (not refreshing) the input also follows the header's own height (stretch mode: the pulled distance), and the
        //      smaller drawn fraction wins: a fast retract changes the height a frame before the input that was sent reaches the file, and the
        //      stale larger fraction showed 5 to 6 rows of black at the bottom of the art in 3 frames. [CN] 下拉或收回（非刷新中）时，输入也按刷新头自身高度
        //      （拉伸模式下即下拉距离）计算，取较小的已绘制比例：快速收回时高度比已发送的输入早一帧变化，过时的较大比例曾在 3 帧中让艺术图底部露出 5 到 6 行黑色。
        var fraction = style.drawnFraction(forInput: currentInput)
        if style.pullInput != nil && !rivePlaysRefresh {
            fraction = min(fraction, style.drawnFraction(forInput: style.pullValue(offset: bounds.height)))
        }
        let slack = CYLRefreshRiveDrawnTable.slack(headerHeight: bounds.height, fraction: fraction)
        riveView.frame = CGRect(x: 0, y: bounds.height - height + slack, width: bounds.width, height: height)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        drawnMask.backgroundColor = UIColor.black.cgColor
        // [EN] Keeps the top `visible` points of the header's share of the view (the file's art); the black below it is cut, and the view
        //      was moved down by `slack`, so the art ends at the bottom of the header and the slack above it stays empty.
        // [CN] 保留 Rive 视图中刷新头那一段的顶部 `visible` 点（文件画出的部分），其下的黑色被裁掉；视图已下移 `slack`，所以内容止于刷新头底边，其上的空余保持为空。
        drawnMask.frame = CGRect(x: 0, y: height - bounds.height, width: bounds.width, height: bounds.height - slack)
        riveView.layer.mask = drawnMask
        CATransaction.commit()
    }

    // MARK: - Pull

    override public func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        super.onScrolling(withOffset: offset, percent: percent, drag: isDragging)
        // [EN] A new drag during the retract ends the freeze at once, so the pull starts from the file's first state. [CN] 收回期间开始新的拖动时立即结束冻结，使下拉从文件的初始状态开始。
        if retractTimer != nil && isDragging && offset > 0.5 { endRetract() }
        guard let style = riveStyle, let viewModel = viewModel, !rivePlaysRefresh else { return }
        if let input = style.pullInput {
            let value = style.pullValue(offset: offset)
            viewModel.setInput(input, value: value)
            currentInput = value
        }
        placeRiveView()
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
            if retractTimer != nil { endRetract() }
            guard !rivePlaysRefresh else { break }
            rivePlaysRefresh = true
            if let input = style.pullInput {
                let value = style.pullInputRefreshingValue >= 0 ? style.pullInputRefreshingValue : style.pullInputMaximum
                viewModel.setInput(input, value: value)
                currentInput = value
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
            // [EN] The end of the animation plays while the header is held open (`onRefreshFinishing:`). [CN] 刷新头被保持展开（`onRefreshFinishing:`）期间播放动画的结束部分。
            awaitsFinishEnd = style.playsFinish
            if let input = style.loadingNumber { viewModel.setInput(input, value: style.loadingNumberFinished) }
            if let trigger = style.finishTrigger { viewModel.triggerInput(trigger) }
        case .idle:
            awaitsFinishEnd = false
            guard rivePlaysRefresh else { break }
            if CYLRefreshRiveRetract.keepsArt(pullAnimation: style.pullAnimation, idleAnimation: style.idleAnimation) {
                beginRetract()
            } else {
                rivePlaysRefresh = false
                reset()
            }
        default:
            break
        }
    }

    // MARK: - The end of the refresh

    /**
     * [EN] How long the header stays open after the refresh ends: `finishTimeout` when the style has an end part to play, else
     *      `finishDuration`. [CN] 刷新结束后刷新头保持展开的时间：样式有结束部分要播放时为 `finishTimeout`，否则为 `finishDuration`。
     */
    override public func onRefreshFinishing(_ success: Bool) -> CGFloat {
        guard awaitsFinishEnd, let style = riveStyle else { return super.onRefreshFinishing(success) }
        return CGFloat(max(style.finishTimeout, finishDuration))
    }

    // [EN] The state machine settled or the animation stopped after the finish trigger: the end part has played, retract now.
    // [CN] 结束触发器之后状态机已稳定或动画已停止：结束部分已播放完，立即收回。
    private func finishAnimationStopped() {
        guard awaitsFinishEnd else { return }
        awaitsFinishEnd = false
        cyl_finishAnimationDidEnd()
    }

    // [EN] After a refresh the header retracts while it is still on screen. Going back to the file's first state at once (`reset()`, the pull
    //      input 0, the pull animation at 0) drew pure black over the whole header for the retract (Halloween's Pull at time 0 and Bow's state
    //      machine at input 0 are black), and in a host that holds the slot (Flutter) before the retract. So the art stays as it is until the
    //      header is out of view, then `reset()` runs; a new drag or release ends the wait at once. Only for a style whose art is a pull animation scrubbed
    //      by the offset (Halloween); the state-machine styles keep their reset at once (their art is empty or hidden by the table at input 0). [CN] 刷新结束后，刷新头收回时仍在屏幕上。
    //      若立刻回到文件的初始状态（`reset()`、下拉输入 0、Pull 动画 0），整个刷新头在收回期间会是纯黑（Halloween 的 Pull 在 0 秒、Bow 的状态机在输入 0
    //      都是黑色），在先停留槽位再收回的宿主（Flutter）中则在收回之前就是黑色。所以画面保持原样直到刷新头离开视野，再执行 `reset()`；新的拖动或松手立即结束等待。
    private func beginRetract() {
        retractTimer?.invalidate()
        let started = Date()
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let outOfView = CYLRefreshRiveRetract.isOutOfView(modelHeight: self.bounds.height, shownHeight: self.layer.presentation()?.bounds.height ?? 0,
                                                              elapsed: Date().timeIntervalSince(started), limit: 3)
            if outOfView || self.window == nil { self.endRetract() }
        }
        RunLoop.main.add(timer, forMode: .common)
        retractTimer = timer
    }

    private func endRetract() {
        retractTimer?.invalidate()
        retractTimer = nil
        guard rivePlaysRefresh else { return }
        rivePlaysRefresh = false
        reset()
        placeRiveView()
    }

    // [EN] Back to the file's first state, as flutter_easy_refresh recreates the controller. [CN] 回到文件的初始状态，与 flutter_easy_refresh 重建控制器相同。
    private func reset() {
        guard let style = riveStyle, let viewModel = viewModel else { return }
        stopLoadingNumber()
        viewModel.reset()
        if let input = style.loadingBoolean { viewModel.setInput(input, value: false) }
        if let input = style.pullInput { viewModel.setInput(input, value: 0.0) }
        currentInput = 0
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
        retractTimer?.invalidate()
    }
}
#endif
