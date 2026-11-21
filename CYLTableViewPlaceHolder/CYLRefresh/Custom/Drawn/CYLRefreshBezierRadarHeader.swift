//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshBezierRadarHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 9), with the same Objective-C API and the same drawing,
//      colors and timing (the Objective-C `NSInteger` truncations and `float` literals of the math are kept).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 9 步），Objective-C API 以及绘制、颜色与时序均不变（保留
//      Objective-C 计算中的 `NSInteger` 截断与 `float` 字面量）。

import UIKit

/**
 * [EN] A bezier wave that turns into a radar scan while refreshing (after "Pull To Refresh" on Dribbble).
 * [CN] 贝塞尔波浪，刷新时变为雷达扫描（参考 Dribbble 作品 “Pull To Refresh”）。
 */
@objc(CYLRefreshBezierRadarHeader)
open class CYLRefreshBezierRadarHeader: CYLRefreshDrawnHeader, CYLRefreshValueAnimatorDelegate {

    // [EN] `1.9f` promoted to double, as the Objective-C expression computed it. [CN] 提升为 double 的 `1.9f`，与 Objective-C 表达式相同。
    private static let onePointNineF = CGFloat(Float(1.9))

    private var wavePulling = false
    // [EN] `NSInteger` in Objective-C: every value stored here is truncated. [CN] Objective-C 中为 `NSInteger`：存入的值都会截断。
    private var waveTop = 0
    private var waveHeight = 0

    private var dotAlpha: CGFloat = 0
    private var dotFraction: CGFloat = 0
    private var dotRadius: CGFloat = 0
    private var rippleRadius: CGFloat = 0

    private var radarAngle = 0

    private var radarRadius: CGFloat = 0
    private var radarCircle: CGFloat = 0
    private var radarScale: CGFloat = 0

    private var animatorWave: CYLRefreshValueAnimator?
    private var animatorDotAlpha: CYLRefreshValueAnimator?
    private var animatorRadarScale: CYLRefreshValueAnimator?
    private var animatorRadarAnimator: CYLRefreshValueAnimator?
    private var animatorRippleRadius: CYLRefreshValueAnimator?

    // [EN] `(NSInteger)value` without the trap of a non-finite or huge value (0 then). [CN] 即 `(NSInteger)value`，非有限值或过大的值不陷入崩溃（得 0）。
    private static func truncated(_ value: CGFloat) -> Int {
        value.isFinite && abs(value) < 9.0e15 ? Int(value) : 0
    }

    /**
     * [EN] Sets the BezierRadar size, finish duration, stretch mode and colors.
     * [CN] 初始化参数：设置 BezierRadar 的尺寸、结束时长、拉伸模式与颜色。
     */
    open override func setUpComponent() {
        super.setUpComponent()

        dotRadius = 7
        radarRadius = 20
        radarCircle = 7

        height = 100
        finishDuration = 0.3

        isOpaque = false
        scrollMode = .stretch
        colorAccent = .white
        colorPrimary = UIColor(red: 0x11 / 255.0, green: 0x99 / 255.0, blue: 0xff / 255.0, alpha: 1)
    }

    // MARK: - Override

    /**
     * [EN] Pulls the wave and the dots down with the drag. [CN] 随拖动拉下波浪与圆点。
     */
    open override func scrollView(_ scrollView: UIScrollView, didScroll offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        super.scrollView(scrollView, didScroll: offset, percent: percent, drag: isDragging)
        if isDragging || wavePulling {
            wavePulling = true
            waveTop = Self.truncated(min(expandHeight, offset))
            waveHeight = Self.truncated(Self.onePointNineF * max(0, offset - expandHeight))
            dotFraction = percent

            setNeedsDisplay()
        }
    }

    /**
     * [EN] Releasing: the dots fade and the wave springs; after refreshing, the ripple spreads.
     * [CN] 释放中：圆点淡出、波浪回弹；刷新后扩散波纹。
     */
    open override func onStatus(_ oldStatus: CYLRefreshPhase, changed status: CYLRefreshPhase) {
        super.onStatus(oldStatus, changed: status)
        if status == .releasing {
            wavePulling = false
            waveTop = Self.truncated(expandHeight)
            // 隐藏球动画
            let animator = CYLRefreshValueAnimator()
            animator.setTarget(self, selector: #selector(onAnimation(_:)))
            animator.interpolator = .decelerate
            animator.duration = durationNormal
            animator.delegate = self
            animator.fromValue = 1
            animator.toValue = 0
            animator.start()
            animatorDotAlpha = animator
            // 贝塞尔弹性动画
            let animatorWave = CYLRefreshValueAnimator()
            animatorWave.setTarget(self, selector: #selector(onAnimation(_:)))
            animatorWave.setFromToPoints([
                NSNumber(value: waveHeight), NSNumber(value: 0),
                NSNumber(value: Double(waveHeight) * -0.5), NSNumber(value: 0),
                NSNumber(value: Double(waveHeight) * -0.2), NSNumber(value: 0),
            ])
            animatorWave.duration = durationNormal * 3.6
            animatorWave.interpolator = .decelerate
            animatorWave.delegate = self
            animatorWave.start()
            self.animatorWave = animatorWave
        } else if oldStatus == .refreshing {
            let width = self.width
            let height = dragOffset
            let animator = CYLRefreshValueAnimator.newWith(target: self, selector: #selector(onAnimation(_:)))
            animator.fromValue = radarRadius
            animator.toValue = sqrt(width * width + height * height)
            animator.duration = finishDuration
            animator.delegate = self
            animator.interpolator = .accelerate
            animator.start()
            animatorRippleRadius = animator
        } else if status == .pullToRefresh || status == .idle {
            dotAlpha = 1
            radarScale = 0
            rippleRadius = 0
        }
    }

    // MARK: - CYLRefreshValueAnimator

    // 动画执行
    @objc(onAnimation:)
    private func onAnimation(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorDotAlpha {
            dotAlpha = animator.value
            setNeedsDisplay()
        } else if animator === animatorRadarScale {
            radarScale = animator.value
            setNeedsDisplay()
        } else if animator === animatorRadarAnimator {
            radarAngle = Self.truncated(animator.value)
            setNeedsDisplay()
        } else if animator === animatorWave {
            if wavePulling {
                animator.stop()
                animatorWave = nil
                return
            }
            waveHeight = Self.truncated(animator.value)
            setNeedsDisplay()
        } else if animator === animatorRippleRadius {
            rippleRadius = animator.value
            setNeedsDisplay()
        }
    }

    /**
     * [EN] Chains the dot fade, the radar scale and the endless radar scan; releases the animator that ended.
     * [CN] 动画结束：依次衔接圆点淡出、雷达放大与无限雷达扫描；释放结束的动画器。
     */
    open func onAnimationEnd(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorDotAlpha {
            animatorDotAlpha = nil
            let next = CYLRefreshValueAnimator.newWith(target: self, selector: #selector(onAnimation(_:)))
            next.interpolator = .decelerate
            next.duration = durationNormal
            next.delegate = self
            next.fromValue = 0
            next.toValue = 1
            next.start()
            animatorRadarScale = next
        } else if animator === animatorRadarScale {
            animatorRadarScale = nil
            let next = CYLRefreshValueAnimator.newWith(target: self, selector: #selector(onAnimation(_:)))
            next.interpolator = .accelerateDecelerate
            next.duration = durationNormal * 3
            next.fromValue = 0
            next.toValue = 360
            next.repeatMode = .restart
            next.repeatCount = .infinity
            next.start()
            animatorRadarAnimator = next
        } else if animator === animatorWave {
            animatorWave = nil
        } else if animator === animatorRippleRadius {
            animatorRippleRadius = nil
        }
    }

    // MARK: - Draw

    /**
     * [EN] Draws the wave, the dots, the radar and the ripple. [CN] 绘制波浪、圆点、雷达与波纹。
     */
    open override func draw(_ rect: CGRect) {
        let width = self.width
        let height = dragOffset
        guard let context = UIGraphicsGetCurrentContext() else { return }

        drawWave(context, w: width, h: height)
        drawDot(context, w: width, h: height)
        drawRadar(context, w: width, h: height)
        drawRipple(context, w: width, h: height)

        if height <= 0 {
            NSLog("%@.drawRect.height=%@ !", NSStringFromClass(type(of: self)), NSNumber(value: Double(height)))
        }
    }

    // 绘制下拉时的 多个点
    private func drawDot(_ context: CGContext, w width: CGFloat, h height: CGFloat) {
        guard dotAlpha > 0 else { return }
        let num = 7
        let count = CGFloat(num)
        let x = height
        // y1 = t*(w/n)-(t>1)*((t-1)*(w/n)/t)
        let wide = (1.0 * width / count) * dotFraction - (dotFraction > 1 ? (dotFraction - 1) * (1.0 * width / count) / dotFraction : 0)
        // y2 = x - (t>1)*((t-1)*x/t);
        let high = height - (dotFraction > 1 ? (dotFraction - 1) * height / 2 / dotFraction : 0)
        for i in 0..<num {
            // y3 = (x + 1) - (n + 1)/2; 居中 index 变量：0 1 2 3 4 结果： -2 -1 0 1 2
            let index = 1.0 + CGFloat(i) - (1.0 + count) / 2
            // y4 = m * ( 1 - 2 * abs(y3) / n); 横向 alpha 差
            let alphaX = 255 * (1 - (2 * (abs(index) / count)))
            // y5 = y4 * (1-1/((x/800+1)^15));竖直 alpha 差
            let alphaY = dotAlpha * alphaX * (1.0 - 1.0 / pow(x / 800 + 1, 15))
            colorAccent?.withAlphaComponent(alphaY / 255.0).setFill()
            // y6 = mDotRadius*(1-1/(x/10+1));半径
            let radius = dotRadius * (1 - 1 / (x / 10 + 1))

            context.beginPath()
            context.addArc(center: CGPoint(x: width / 2 - radius / 2 + wide * index, y: high / 2), radius: radius,
                           startAngle: 0, endAngle: 2 * .pi, clockwise: false)
            context.fillPath()
        }
    }

    private func drawRadar(_ context: CGContext, w width: CGFloat, h height: CGFloat) {
        guard status == .releasing || status == .refreshing else { return }
        let radius = radarRadius * radarScale
        let circle = radarCircle * radarScale
        let center = CGPoint(x: width / 2, y: height / 2)
        let sweepEnd = CGFloat(radarAngle) * .pi / 180

        colorAccent?.setFill()
        colorAccent?.setStroke()
        // 线的宽度
        context.setLineWidth(3.0)

        context.addArc(center: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        context.fillPath()

        context.addArc(center: center, radius: radius + circle, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        // 绘制路
        context.drawPath(using: .stroke)

        colorPrimary?.withAlphaComponent(0.33).setFill()
        colorPrimary?.withAlphaComponent(0.33).setStroke()

        context.beginPath()
        context.move(to: center)
        context.addArc(center: center, radius: radius, startAngle: 3 * .pi / 2, endAngle: sweepEnd, clockwise: false)
        context.fillPath()

        context.beginPath()
        context.addArc(center: center, radius: radius + circle, startAngle: 3 * .pi / 2, endAngle: sweepEnd, clockwise: false)
        // 绘制路
        context.drawPath(using: .stroke)
    }

    // 绘制刷新完成 白色扩散动画
    private func drawRipple(_ context: CGContext, w width: CGFloat, h height: CGFloat) {
        guard rippleRadius > 0 else { return }
        let center = CGPoint(x: width / 2, y: height / 2)
        colorAccent?.setFill()
        context.beginPath()
        context.move(to: center)
        context.addArc(center: center, radius: rippleRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        context.fillPath()
    }

    // 绘制背景波形
    private func drawWave(_ context: CGContext, w width: CGFloat, h height: CGFloat) {
        // 重置画笔
        colorPrimary?.setFill()

        // 绘制贝塞尔曲线
        let top = CGFloat(waveTop)
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: 0, y: top))
        context.addQuadCurve(to: CGPoint(x: width, y: top), control: CGPoint(x: width / 2, y: top + CGFloat(waveHeight)))
        context.addLine(to: CGPoint(x: width, y: 0))
        context.closePath()

        context.fillPath()
    }
}
