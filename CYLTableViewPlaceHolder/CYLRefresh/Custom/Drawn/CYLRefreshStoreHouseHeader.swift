//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshStoreHouseHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API (`lineWidth`,
//      `enableReverseFlash`, `enableFadeAnimation`, `+newWithString:…`, `-initLinesWithString:…`,
//      `-initLinesWithArray:…`; the former NS_SWIFT_NAME spellings `init(string:…)` and `setLines(…)` are the Swift names)
//      and the same drawing, colors and timing. The 2026-11-19 leak fix is kept: the loading timer holds the header weakly
//      and is invalidated when the header goes away.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API（`lineWidth`、`enableReverseFlash`、
//      `enableFadeAnimation`、`+newWithString:…`、`-initLinesWithString:…`、`-initLinesWithArray:…`；原 NS_SWIFT_NAME 的
//      `init(string:…)` 与 `setLines(…)` 即 Swift 名称）以及绘制、颜色与时序均不变。保留 2026-11-19 的泄漏修复：加载定时器弱引用
//      刷新头，刷新头销毁时定时器失效。

import UIKit

/**
 * [EN] Text drawn as line segments that gather while pulling and flash while refreshing (after CRefreshLayout StoreHouse).
 * [CN] 由线段组成的文字，下拉时聚拢，刷新时闪烁（参考 CRefreshLayout StoreHouse）。
 */
@objc(CYLRefreshStoreHouseHeader)
open class CYLRefreshStoreHouseHeader: CYLRefreshDrawnHeader {

    // [EN] The Objective-C `float` macros (`0.4f`, `0.7f`, …). [CN] Objective-C 的 `float` 宏（`0.4f`、`0.7f` 等）。
    private static let darkAlpha = Float(0.4)
    private static let internalAnimationFactor = Float(0.7)
    private static let defaultScale = CGFloat(Float(1.0))
    private static let defaultPadding = CGFloat(Float(1.5))

    // [EN] The flash position, shared by every header as the Objective-C function-level `static` was.
    // [CN] 闪烁位置，与 Objective-C 中函数级的 `static` 一样由所有刷新头共用。
    private static var flashIndex = 0

    private var padding: CGFloat = 0
    private var linesRect: CGRect = .zero

    private var colorText: UIColor?

    private var timerLoading: Timer?
    private var animatorLoading: CYLRefreshValueAnimator?
    private var animatorFinishing: CYLRefreshValueAnimator?

    private var lines: [CYLRefreshStoreHouseLine] = []

    /**
     * [EN] Width of the line segments, in points. [CN] 线段宽度（点）。
     */
    @objc open var lineWidth: CGFloat = 0

    /**
     * [EN] Flashes the segments in reverse order while refreshing. [CN] 刷新时按相反顺序闪烁线段。
     */
    @objc open var enableReverseFlash = false

    private var storedEnableFadeAnimation = false

    /**
     * [EN] Fades the segments out when the refresh ends. [CN] 刷新结束时淡出线段。
     */
    @objc open var enableFadeAnimation: Bool {
        get { storedEnableFadeAnimation }
        set {
            storedEnableFadeAnimation = newValue
            finishDuration = (newValue ? 1 : 0) * 0.5
        }
    }

    deinit {
        timerLoading?.invalidate()
    }

    /**
     * [EN] A header that draws "store house". [CN] 绘制 “store house” 的刷新头。
     */
    @objc public convenience init() {
        self.init(frame: .zero)
        setLines(string: "store house")
    }

    /**
     * [EN] A header that draws `string` (letters, digits and common punctuation). [CN] 绘制 `string`（字母、数字与常用标点）的刷新头。
     */
    public required convenience init(string: String) {
        self.init(string: string, scale: Self.defaultScale)
    }

    /**
     * [EN] The same, with the text scaled by `scale`. [CN] 同上，文字按 `scale` 缩放。
     */
    public required convenience init(string: String, scale: CGFloat) {
        self.init()
        setLines(string: string, scale: scale)
    }

    /**
     * [EN] The same, with `padding` points between letters. [CN] 同上，字母之间间隔 `padding` 点。
     */
    public required convenience init(string: String, scale: CGFloat, padding: CGFloat) {
        self.init()
        setLines(string: string, scale: scale, padding: padding)
    }

    /**
     * [EN] Objective-C: `+newWithString:`. [CN] Objective-C：`+newWithString:`。
     */
    @objc(newWithString:)
    @available(swift, obsoleted: 1, message: "Use init(string:)")
    public class func objcNew(string: String) -> Self {
        self.init(string: string)
    }

    /**
     * [EN] Objective-C: `+newWithString:scale:`. [CN] Objective-C：`+newWithString:scale:`。
     */
    @objc(newWithString:scale:)
    @available(swift, obsoleted: 1, message: "Use init(string:scale:)")
    public class func objcNew(string: String, scale: CGFloat) -> Self {
        self.init(string: string, scale: scale)
    }

    /**
     * [EN] Objective-C: `+newWithString:scale:padding:`. [CN] Objective-C：`+newWithString:scale:padding:`。
     */
    @objc(newWithString:scale:padding:)
    @available(swift, obsoleted: 1, message: "Use init(string:scale:padding:)")
    public class func objcNew(string: String, scale: CGFloat, padding: CGFloat) -> Self {
        self.init(string: string, scale: scale, padding: padding)
    }

    /**
     * [EN] Replaces the drawn text with `string`. [CN] 把绘制的文字换成 `string`。
     */
    @objc(initLinesWithString:)
    open func setLines(string: String) {
        setLines(string: string, scale: Self.defaultScale)
    }

    /**
     * [EN] The same, with the text scaled by `scale`. [CN] 同上，文字按 `scale` 缩放。
     */
    @objc(initLinesWithString:scale:)
    open func setLines(string: String, scale: CGFloat) {
        setLines(string: string, scale: scale, padding: Self.defaultPadding)
    }

    /**
     * [EN] The same, with `padding` points between letters. [CN] 同上，字母之间间隔 `padding` 点。
     */
    @objc(initLinesWithString:scale:padding:)
    open func setLines(string: String, scale: CGFloat, padding: CGFloat) {
        lines = CYLRefreshStoreHousePath.linesFrom(string, scale: scale, space: 10)
        self.padding = padding
        updateLinesRect()
    }

    /**
     * [EN] Draws custom segments: `array` holds point strings like `@"{24, 0}"`, two per segment (start, end).
     * [CN] 绘制自定义线段：`array` 为 `@"{24, 0}"` 形式的点字符串，每两个组成一条线段（起点、终点）。
     */
    @objc(initLinesWithArray:)
    open func setLines(array: [String]) {
        setLines(array: array, padding: 0.5)
    }

    /**
     * [EN] The same, with `padding` points around the drawing. [CN] 同上，图形四周留出 `padding` 点。
     */
    @objc(initLinesWithArray:padding:)
    open func setLines(array: [String], padding: CGFloat) {
        lines = CYLRefreshStoreHousePath.linesFromArray(array)
        self.padding = padding
        updateLinesRect()
    }

    private func updateLinesRect() {
        var linesRect = CGRect.zero
        for line in lines {
            linesRect.size.width = max(linesRect.size.width, line.end.x)
            linesRect.size.width = max(linesRect.size.width, line.start.x)
            linesRect.size.height = max(linesRect.size.height, line.end.y)
            linesRect.size.height = max(linesRect.size.height, line.start.y)
        }
        let padding = self.padding > 5 ? self.padding : self.padding * linesRect.size.height

        linesRect.origin.y = padding
        linesRect.origin.x = width / 2 - linesRect.size.width / 2

        self.linesRect = linesRect
        height = padding * 2 + linesRect.size.height
    }

    /**
     * [EN] Sets the StoreHouse colors, line width, fade and padding.
     * [CN] 初始化参数：设置 StoreHouse 的颜色、线宽、淡出与留白。
     */
    open override func setUpComponent() {
        super.setUpComponent()

        isOpaque = false

        scrollMode = .stretch
        colorText = .white
        colorAccent = .white
        colorPrimary = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)

        lineWidth = 2

        enableFadeAnimation = true
        enableReverseFlash = false

        padding = Self.defaultPadding
    }

    /**
     * [EN] Gathers the segments with the pull. [CN] 随下拉聚拢线段。
     */
    open override func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        setNeedsDisplay()
        if status != .finishing {
            updateLines(progress: percent)
        }
    }

    /**
     * [EN] Starts dimming and flashing the segments. [CN] 开始让线段变暗并闪烁。
     */
    open override func onStartAnimationWhenRealeasing() {
        super.onStartAnimationWhenRealeasing()

        let animator = CYLRefreshValueAnimator.newWith(target: self, selector: #selector(onAnimationLoading(_:)))
        animatorLoading = animator
        animator.repeatCount = .infinity
        animator.start()

        // [EN] A block timer holding the header weakly: a target-action timer retains its target, and the run loop retains a
        //      repeating timer until it is invalidated, which happened only on the next tick after the refresh ended. A
        //      header torn down while refreshing (its controller closed) therefore stayed alive, ticking, for ever.
        // [CN] 用弱引用刷新头的 block 定时器：target-action 定时器强持有 target，run loop 又持有重复定时器直到它失效，而失效只发生在刷新结束后的
        //      下一次触发。刷新中被销毁的刷新头（控制器已关闭）因此永远不会释放，并一直触发。
        timerLoading?.invalidate()
        let timer = Timer(timeInterval: 0.075, repeats: true) { [weak self] aTimer in
            guard let self = self else {
                aTimer.invalidate()
                return
            }
            self.onAnimationTimer()
        }
        RunLoop.current.add(timer, forMode: .common)
        timerLoading = timer
    }

    /**
     * [EN] After a successful refresh, fades the segments out for three times `finishDuration`; returns `finishDuration`
     *      (0 after a failure).
     * [CN] 刷新成功后用 `finishDuration` 的三倍时长淡出线段；返回 `finishDuration`（失败时为 0）。
     */
    open override func onRefreshFinishing(_ success: Bool) -> CGFloat {
        if !success {
            return 0
        }
        let animator = CYLRefreshValueAnimator.newWith(target: self, selector: #selector(onAnimationFinishing(_:)))
        animatorFinishing = animator
        animator.setFrom(1, to: 0)
        animator.duration = finishDuration * 3
        animator.start()
        return CGFloat(finishDuration)
    }

    private func onAnimationTimer() {
        if isRefreshing {
            if Self.flashIndex < lines.count {
                let position: Int
                if enableReverseFlash {
                    Self.flashIndex += 1
                    position = lines.count - Self.flashIndex
                } else {
                    position = Self.flashIndex
                    Self.flashIndex += 1
                }
                lines[position].alpha = 1
            } else {
                Self.flashIndex += 1
                if Self.flashIndex - lines.count == 2 {
                    Self.flashIndex = 0
                }
            }
        } else {
            Self.flashIndex = 0
            timerLoading?.invalidate()
            timerLoading = nil
        }
    }

    @objc(onAnimationLoading:)
    private func onAnimationLoading(_ animator: CYLRefreshValueAnimator) {
        if isRefreshing {
            for line in lines where line.alpha > CGFloat(Self.darkAlpha) {
                line.alpha -= 0.01
            }
            setNeedsDisplay()
        } else {
            animator.stop()
        }
    }

    @objc(onAnimationFinishing:)
    private func onAnimationFinishing(_ animator: CYLRefreshValueAnimator) {
        if status == .finishing {
            updateLines(progress: animator.value)
            setNeedsDisplay()
        } else {
            animator.stop()
        }
    }

    /**
     * [EN] Keeps the text centered when the width changes. [CN] 宽度变化时保持文字居中。
     */
    open override var frame: CGRect {
        get { super.frame }
        set {
            if !lines.isEmpty && newValue.size.width != super.frame.size.width {
                linesRect.origin.x = newValue.size.width / 2 - linesRect.size.width / 2
            }
            super.frame = newValue
        }
    }

    /**
     * [EN] Draws the background and the segments. [CN] 绘制背景与线段。
     */
    open override func draw(_ rect: CGRect) {
        let width = self.width
        let height = dragOffset
        guard let context = UIGraphicsGetCurrentContext() else { return }

        colorPrimary?.setFill()
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        context.setLineWidth(lineWidth)
        context.translateBy(x: linesRect.origin.x, y: linesRect.origin.y)

        for line in lines {
            colorAccent?.withAlphaComponent(line.alpha).setStroke()
            context.saveGState()
            context.concatenate(line.transform)
            context.move(to: line.start)
            context.addLine(to: line.end)
            context.strokePath()
            context.restoreGState()
        }

        if height <= 0 {
            NSLog("%@.drawRect.height=%@ !", NSStringFromClass(type(of: self)), NSNumber(value: Double(height)))
        }
    }

    private func updateLines(progress: CGFloat) {
        let len = lines.count
        for i in 0..<len {
            let paddingStart = CGFloat((1 - Self.internalAnimationFactor) / Float(len) * Float(i))
            let paddingEnd = CGFloat(1 - Self.internalAnimationFactor) - paddingStart

            let line = lines[i]
            if progress == 1 || progress >= 1 - paddingEnd {
                line.alpha = isRefreshing ? line.alpha : CGFloat(Self.darkAlpha)
                line.transform = .identity
            } else if progress == 0 {
                // [EN] Fixed from CYLRefresh styles, which set `self.transform` here: the whole header moved sideways by the
                //      last segment's offset and stayed narrower than the screen. Each segment starts off-screen instead.
                // [CN] 修正 CYLRefresh styles 的错误：原代码在这里设置 `self.transform`，整个刷新头按最后一条线段的偏移横向移动，看起来比屏幕窄。
                //      现改为每条线段从屏幕外开始。
                line.transform = CGAffineTransform(translationX: line.offset * width, y: -expandHeight)
            } else if !isRefreshing {
                let realProgress: CGFloat
                if progress <= paddingStart {
                    realProgress = 0
                } else {
                    realProgress = min(1, (progress - paddingStart) / CGFloat(Self.internalAnimationFactor))
                }
                var transform = CGAffineTransform(translationX: line.offset * width * (1 - realProgress),
                                                  y: -expandHeight * (1 - realProgress))
                transform = transform.translatedBy(x: line.middle.x, y: line.middle.y)
                transform = transform.rotated(by: .pi * realProgress)
                transform = transform.scaledBy(x: realProgress, y: realProgress)
                transform = transform.translatedBy(x: -line.middle.x, y: -line.middle.y)
                line.transform = transform
                line.alpha = realProgress * CGFloat(Self.darkAlpha)
            }
        }
    }
}
