//
//  CYLRefreshDrawnFooter.swift
//  CYLRefresh
//
//  flutter_easy_refresh's drawn footers (https://github.com/xuelongqy/flutter_easy_refresh, MIT), built on the
//  headers ported from third-party refresh code (MIT, see LICENSE.refresh-third-party.txt).
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API (`+styleClass`,
//      `-initWithStyle:`, `style`, the five drawn footers, `CYLRefreshBallPulseFooter` with `normalColor` /
//      `animatingColor`). The hosted header (`CYLRefreshDrawnHeader`) and the base classes (`CYLRefreshBackStateFooter`,
//      `CYLRefreshBackFooter`, `CYLRefreshAutoFooter`) are still Objective-C: their private members that the footers call
//      (the header's driven mode, `-happenOffsetY`) are reached by selector, as `UIScrollView+CYLRefresh.swift` does.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API 不变（`+styleClass`、`-initWithStyle:`、
//      `style`、五个手绘刷新尾、带 `normalColor` / `animatingColor` 的 `CYLRefreshBallPulseFooter`）。内嵌的刷新头
//      （`CYLRefreshDrawnHeader`）与基类（`CYLRefreshBackStateFooter`、`CYLRefreshBackFooter`、`CYLRefreshAutoFooter`）仍是
//      Objective-C：刷新尾调用的私有成员（刷新头的被驱动模式、`-happenOffsetY`）按选择器调用，与 `UIScrollView+CYLRefresh.swift` 相同。

import UIKit

// [EN] CYLRefreshDrawnHeader's private driven mode (`CYLRefreshDrawnHeader.m`), called by selector while the header is
//      Objective-C. [CN] CYLRefreshDrawnHeader 私有的被驱动模式（`CYLRefreshDrawnHeader.m`），在刷新头仍是 Objective-C 时按选择器调用。
private extension CYLRefreshDrawnHeader {

    func cyl_beginDrivenByFooter() {
        let selector = NSSelectorFromString("cyl_beginDriven")
        guard responds(to: selector) else { return }
        typealias Function = @convention(c) (AnyObject, Selector) -> Void
        unsafeBitCast(method(for: selector), to: Function.self)(self, selector)
    }

    func cyl_driveFrameByFooter(_ frame: CGRect) {
        let selector = NSSelectorFromString("cyl_driveFrame:")
        guard responds(to: selector) else { return }
        typealias Function = @convention(c) (AnyObject, Selector, CGRect) -> Void
        unsafeBitCast(method(for: selector), to: Function.self)(self, selector, frame)
    }

    func cyl_driveOffsetByFooter(_ offset: CGFloat, drag isDragging: Bool) {
        let selector = NSSelectorFromString("cyl_driveOffset:drag:")
        guard responds(to: selector) else { return }
        typealias Function = @convention(c) (AnyObject, Selector, CGFloat, ObjCBool) -> Void
        unsafeBitCast(method(for: selector), to: Function.self)(self, selector, offset, ObjCBool(isDragging))
    }

    func cyl_driveStatusByFooter(_ status: CYLRefreshPhase) {
        let selector = NSSelectorFromString("cyl_driveStatus:")
        guard responds(to: selector) else { return }
        typealias Function = @convention(c) (AnyObject, Selector, CYLRefreshPhase) -> Void
        unsafeBitCast(method(for: selector), to: Function.self)(self, selector, status)
    }

    func cyl_driveFinishedByFooter(_ success: Bool) {
        let selector = NSSelectorFromString("cyl_driveFinished:")
        guard responds(to: selector) else { return }
        typealias Function = @convention(c) (AnyObject, Selector, ObjCBool) -> Void
        unsafeBitCast(method(for: selector), to: Function.self)(self, selector, ObjCBool(success))
    }
}

// [EN] CYLRefreshBackFooter's private offset where the footer starts to show (`CYLRefreshBackFooter.m`).
// [CN] CYLRefreshBackFooter 私有的刷新尾开始出现的偏移（`CYLRefreshBackFooter.m`）。
private extension CYLRefreshBackFooter {

    var cyl_happenOffsetYForDrawnFooter: CGFloat {
        let selector = NSSelectorFromString("happenOffsetY")
        guard responds(to: selector) else { return 0 }
        typealias Function = @convention(c) (AnyObject, Selector) -> CGFloat
        return unsafeBitCast(method(for: selector), to: Function.self)(self, selector)
    }
}

/**
 * [EN] A pull-up footer drawn by a hosted drawn header (`style`): the header gets the distance pulled past the content,
 *      the progress and the CYLRefresh styles' status order, and draws in the revealed area under the content. Only
 *      the "no more data" text is shown as a label (from `CYLRefresh.strings`).
 * [CN] 由内嵌的手绘刷新头（`style`）绘制的上拉刷新尾：刷新头收到拉出内容底部的距离、进度和 CYLRefresh styles 顺序的状态，在内容
 *      下方露出的区域里绘制。只有“没有更多数据”以文字标签显示（来自 `CYLRefresh.strings`）。
 */
@objc(CYLRefreshDrawnFooter)
open class CYLRefreshDrawnFooter: CYLRefreshBackStateFooter {

    /**
     * [EN] The drawn header class a subclass hosts; nil in the base class. [CN] 子类内嵌的手绘刷新头类；基类为 nil。
     */
    @objc open class var styleClass: AnyClass? { nil }

    /**
     * [EN] The hosted drawn header; set its colors and options here or through the footer's `colorAccent` /
     *      `colorPrimary`. [CN] 内嵌的手绘刷新头；可直接设置它的颜色与选项，或通过刷新尾的 `colorAccent` / `colorPrimary` 设置。
     */
    @objc public private(set) var style: CYLRefreshDrawnHeader?

    /**
     * [EN] A footer drawn by `style`; the footer takes the style's open height. [CN] 由 `style` 绘制的刷新尾；刷新尾使用该样式的展开高度。
     */
    @objc(initWithStyle:)
    public convenience init(style: CYLRefreshDrawnHeader) {
        self.init(frame: .zero)
        installStyle(style)
    }

    /**
     * [EN] Hosts a new instance of `styleClass`, if any. [CN] 如有 `styleClass`，内嵌它的一个新实例。
     */
    open override func prepare() {
        super.prepare()
        if let styleClass = type(of: self).styleClass as? NSObject.Type,
           let style = styleClass.init() as? CYLRefreshDrawnHeader {
            installStyle(style)
        }
    }

    private func installStyle(_ style: CYLRefreshDrawnHeader) {
        self.style?.removeFromSuperview()
        self.style = style
        style.cyl_beginDrivenByFooter()
        insertSubview(style, at: 0)
        cyl_h = style.expandHeight
        stateLabel?.isHidden = state != .noMoreData
        setNeedsLayout()
    }

    // MARK: - Colors

    /**
     * [EN] Also colors the hosted style. [CN] 同时为内嵌样式着色。
     */
    open override var colorAccent: UIColor? {
        get { super.colorAccent }
        set {
            super.colorAccent = newValue
            style?.colorAccent = newValue
        }
    }

    /**
     * [EN] Also colors the hosted style; the footer's background stays clear. [CN] 同时为内嵌样式着色；刷新尾背景保持透明。
     */
    open override var colorPrimary: UIColor? {
        get { super.colorPrimary }
        set {
            super.colorPrimary = newValue
            style?.colorPrimary = newValue
            backgroundColor = .clear
        }
    }

    // MARK: - Pull

    // [EN] Points pulled past the content's bottom, the open height included while loading. [CN] 拉出内容底部的点数，加载中包含展开高度。
    private var pulled: CGFloat {
        guard let scrollView = scrollView else { return 0 }
        return max(0, scrollView.cyl_offsetY - cyl_happenOffsetYForDrawnFooter)
    }

    // [EN] Stretch styles fill the revealed area; the others keep their open height. [CN] 拉伸类样式铺满露出区域；其他样式保持展开高度。
    private func layoutStyle() {
        guard let style = style else { return }
        var height = style.expandHeight
        if style.scrollMode == .stretch { height = max(height, pulled) }
        style.cyl_driveFrameByFooter(CGRect(x: 0, y: 0, width: cyl_w, height: height))
    }

    /**
     * [EN] Lays the style out in the footer. [CN] 在刷新尾中布局样式。
     */
    open override func placeSubviews() {
        super.placeSubviews()
        layoutStyle()
    }

    /**
     * [EN] Passes the pull to the style. [CN] 把上拉距离传给样式。
     */
    open override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        guard let style = style, state != .noMoreData else { return }
        let pulled = self.pulled
        if style.status == .finishing && state == .idle && pulled <= 0.5 {
            style.cyl_driveStatusByFooter(.idle)
        }
        layoutStyle()
        style.cyl_driveOffsetByFooter(pulled, drag: scrollView?.isDragging ?? false)
    }

    /**
     * [EN] Tells the style it is attached. [CN] 告诉样式已挂上。
     */
    open override func didAttach(to scrollView: UIScrollView) {
        super.didAttach(to: scrollView)
        style?.scrollView(scrollView, attached: true)
    }

    /**
     * [EN] Tells the style it is detached. [CN] 告诉样式即将离开。
     */
    open override func willDetach(from scrollView: UIScrollView) {
        style?.scrollView(scrollView, attached: false)
        super.willDetach(from: scrollView)
    }

    // MARK: - Status

    /**
     * [EN] Shows the label only for "no more data", and hides the style then. [CN] 仅在“没有更多数据”时显示文字，并隐藏样式。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            super.state = newValue
            let noMoreData = newValue == .noMoreData
            stateLabel?.isHidden = !noMoreData
            style?.isHidden = noMoreData
        }
    }

    /**
     * [EN] The same order as CYLRefreshDrawnHeader: releasing before refreshing, finish until retracted.
     * [CN] 与 CYLRefreshDrawnHeader 相同的顺序：刷新前先经过释放中，结束状态保持到收回。
     */
    open override func phaseDidChange(from oldPhase: CYLRefreshPhase, to phase: CYLRefreshPhase) {
        super.phaseDidChange(from: oldPhase, to: phase)
        guard let style = style else { return }
        switch phase {
        case .refreshing:
            if style.status != .releasing { style.cyl_driveStatusByFooter(.releasing) }
            style.cyl_driveStatusByFooter(.refreshing)
        case .idle:
            if style.status == .refreshing { style.cyl_driveStatusByFooter(.finishing) }
            if style.status != .finishing || pulled <= 0.5 { style.cyl_driveStatusByFooter(.idle) }
        case .noMoreData:
            style.cyl_driveStatusByFooter(.idle)
        default:
            style.cyl_driveStatusByFooter(phase)
        }
    }

    /**
     * [EN] Tells the style the refresh finished. [CN] 告诉样式刷新已结束。
     */
    open override func refreshDidFinish(withSuccess success: Bool) {
        super.refreshDidFinish(withSuccess: success)
        style?.cyl_driveFinishedByFooter(success)
    }

    /**
     * [EN] The style's finishing time, else the footer's. [CN] 样式的结束停留时间，否则为刷新尾的。
     */
    open override func finishingDuration(withSuccess success: Bool) -> TimeInterval {
        guard let style = style else { return super.finishingDuration(withSuccess: success) }
        return TimeInterval(style.onRefreshFinishing(success))
    }
}

/**
 * [EN] flutter_easy_refresh's `BezierFooter`, drawn by CYLRefreshBezierRadarHeader. [CN] flutter_easy_refresh 的 `BezierFooter`，由 CYLRefreshBezierRadarHeader 绘制。
 */
@objc(CYLRefreshBezierRadarFooter)
open class CYLRefreshBezierRadarFooter: CYLRefreshDrawnFooter {
    /**
     * [EN] CYLRefreshBezierRadarHeader. [CN] CYLRefreshBezierRadarHeader。
     */
    open override class var styleClass: AnyClass? { CYLRefreshBezierRadarHeader.self }
}

/**
 * [EN] flutter_easy_refresh's `MaterialFooter`, drawn by CYLRefreshMaterialHeader. [CN] flutter_easy_refresh 的 `MaterialFooter`，由 CYLRefreshMaterialHeader 绘制。
 */
@objc(CYLRefreshMaterialFooter)
open class CYLRefreshMaterialFooter: CYLRefreshDrawnFooter {
    /**
     * [EN] CYLRefreshMaterialHeader. [CN] CYLRefreshMaterialHeader。
     */
    open override class var styleClass: AnyClass? { CYLRefreshMaterialHeader.self }
}

/**
 * [EN] flutter_easy_refresh's `DeliveryFooter`, drawn by CYLRefreshDeliveryHeader. [CN] flutter_easy_refresh 的 `DeliveryFooter`，由 CYLRefreshDeliveryHeader 绘制。
 */
@objc(CYLRefreshDeliveryFooter)
open class CYLRefreshDeliveryFooter: CYLRefreshDrawnFooter {
    /**
     * [EN] CYLRefreshDeliveryHeader. [CN] CYLRefreshDeliveryHeader。
     */
    open override class var styleClass: AnyClass? { CYLRefreshDeliveryHeader.self }
}

/**
 * [EN] flutter_easy_refresh's `PhoenixFooter`, drawn by CYLRefreshPhoenixHeader. [CN] flutter_easy_refresh 的 `PhoenixFooter`，由 CYLRefreshPhoenixHeader 绘制。
 */
@objc(CYLRefreshPhoenixFooter)
open class CYLRefreshPhoenixFooter: CYLRefreshDrawnFooter {
    /**
     * [EN] CYLRefreshPhoenixHeader. [CN] CYLRefreshPhoenixHeader。
     */
    open override class var styleClass: AnyClass? { CYLRefreshPhoenixHeader.self }
}

/**
 * [EN] flutter_easy_refresh's `TaurusFooter`, drawn by CYLRefreshTaurusHeader. [CN] flutter_easy_refresh 的 `TaurusFooter`，由 CYLRefreshTaurusHeader 绘制。
 */
@objc(CYLRefreshTaurusFooter)
open class CYLRefreshTaurusFooter: CYLRefreshDrawnFooter {
    /**
     * [EN] CYLRefreshTaurusHeader. [CN] CYLRefreshTaurusHeader。
     */
    open override class var styleClass: AnyClass? { CYLRefreshTaurusHeader.self }
}

// [EN] Forwards display-link ticks without retaining the footer. [CN] 转发 display link 回调，不强持有刷新尾。
private final class CYLRefreshBallPulseTicker: NSObject {

    weak var target: CYLRefreshBallPulseFooter?

    @objc func tick(_ link: CADisplayLink) {
        target?.tick()
    }
}

/**
 * [EN] Three balls that pulse in turn while loading more; an auto footer (Android CYLRefreshLayout's
 *      `BallPulseFooter`). [CN] 加载更多时依次跳动的三个小球；自动加载尾部（对应 Android CYLRefreshLayout 的 `BallPulseFooter`）。
 */
@objc(CYLRefreshBallPulseFooter)
open class CYLRefreshBallPulseFooter: CYLRefreshAutoFooter {

    private var balls: [CAShapeLayer] = []
    private var link: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var storedNormalColor = UIColor(red: 0xee / 255.0, green: 0xee / 255.0, blue: 0xee / 255.0, alpha: 1)
    private var storedAnimatingColor = UIColor(red: 0xe7 / 255.0, green: 0x59 / 255.0, blue: 0x46 / 255.0, alpha: 1)

    /**
     * [EN] The balls' color while idle; default #EEEEEE (`setNormalColor`). [CN] 空闲时小球的颜色；默认 #EEEEEE（`setNormalColor`）。
     */
    @objc open var normalColor: UIColor {
        get { storedNormalColor }
        set {
            storedNormalColor = newValue
            if state != .refreshing { fillBalls(newValue) }
        }
    }

    /**
     * [EN] The balls' color while loading; default #E75946 (`setAnimatingColor`). [CN] 加载时小球的颜色；默认 #E75946（`setAnimatingColor`）。
     */
    @objc open var animatingColor: UIColor {
        get { storedAnimatingColor }
        set {
            storedAnimatingColor = newValue
            if state == .refreshing { fillBalls(newValue) }
        }
    }

    /**
     * [EN] A 60-point footer with three balls. [CN] 60 点高、带三个小球的刷新尾。
     */
    open override func prepare() {
        super.prepare()
        cyl_h = 60
        var balls: [CAShapeLayer] = []
        for _ in 0..<3 {
            let ball = CAShapeLayer()
            ball.fillColor = storedNormalColor.cgColor
            layer.addSublayer(ball)
            balls.append(ball)
        }
        self.balls = balls
        isAccessibilityElement = true
    }

    /**
     * [EN] As BallPulseFooter.dispatchDraw: three balls with 4-point gaps, centered.
     * [CN] 与 BallPulseFooter.dispatchDraw 相同：间隔 4 点的三个小球，居中。
     */
    open override func placeSubviews() {
        super.placeSubviews()
        let spacing: CGFloat = 4
        let radius = (min(cyl_w, cyl_h) - spacing * 2) / 6
        let x = cyl_w / 2 - (radius * 2 + spacing)
        for (i, ball) in balls.enumerated() {
            ball.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
            ball.position = CGPoint(x: x + CGFloat(i) * (radius * 2 + spacing), y: cyl_h / 2)
            ball.path = UIBezierPath(ovalIn: ball.bounds).cgPath
        }
    }

    private func fillBalls(_ color: UIColor) {
        for ball in balls { ball.fillColor = color.cgColor }
    }

    /**
     * [EN] Pulses while loading, hides the balls without more data. [CN] 加载时跳动，没有更多数据时隐藏小球。
     */
    open override var state: CYLRefreshState {
        get { super.state }
        set {
            // [EN] CYLRefreshCheckState. [CN] 即 CYLRefreshCheckState。
            let oldState = state
            if newValue == oldState { return }
            super.state = newValue
            let loading = newValue == .refreshing
            for ball in balls { ball.isHidden = newValue == .noMoreData }
            fillBalls(loading ? animatingColor : normalColor)
            accessibilityLabel = loading ? Bundle.cyl_localizedString(forKey: CYLRefreshAutoFooterRefreshingText) : nil
            if loading {
                startPulsing()
            } else {
                stopPulsing()
            }
        }
    }

    private func startPulsing() {
        if link != nil { return }
        startTime = CACurrentMediaTime()
        let ticker = CYLRefreshBallPulseTicker()
        ticker.target = self
        let link = CADisplayLink(target: ticker, selector: #selector(CYLRefreshBallPulseTicker.tick(_:)))
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    private func stopPulsing() {
        link?.invalidate()
        link = nil
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for ball in balls { ball.transform = CATransform3DIdentity }
        CATransaction.commit()
    }

    // [EN] One frame: each ball scales on a 0.75 s accelerate-decelerate cycle, 0.12 s after the previous one (as Android).
    // [CN] 一帧：每个小球按 0.75 秒的先加速后减速周期缩放，比前一个晚 0.12 秒（与 Android 相同）。
    fileprivate func tick() {
        let now = CACurrentMediaTime()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for (i, ball) in balls.enumerated() {
            let time = now - startTime - 0.12 * Double(i + 1)
            let linear: CGFloat = time > 0 ? CGFloat(fmod(time, 0.75) / 0.75) : 0
            let percent = cos((linear + 1) * .pi) / 2 + 0.5
            let scale = percent < 0.5 ? 1 - percent * 2 * 0.7 : percent * 2 * 0.7 - 0.4
            ball.transform = CATransform3DMakeScale(scale, scale, 1)
        }
        CATransaction.commit()
    }

    /**
     * [EN] Stops pulsing off screen and resumes while loading on screen. [CN] 离开屏幕时停止跳动，回到屏幕且在加载时继续。
     */
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            stopPulsing()
        } else if state == .refreshing {
            startPulsing()
        }
    }

    deinit {
        link?.invalidate()
    }
}
