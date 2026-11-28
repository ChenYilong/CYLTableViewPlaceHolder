//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshBezierCircleHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API and the same drawing,
//      colors and timing (the Objective-C `float` and `int` steps of the math are kept).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API 以及绘制、颜色与时序均不变（保留
//      Objective-C 计算中的 `float` 与 `int` 步骤）。

import UIKit

/**
 * [EN] A ball that drops out of a bezier wave and spins while refreshing (after "Pull Down To Refresh" on Dribbble).
 * [CN] 从贝塞尔波浪中落下的小球，刷新时旋转（参考 Dribbble 作品 “Pull Down To Refresh”）。
 */
@objc(CYLRefreshBezierCircleHeader)
open class CYLRefreshBezierCircleHeader: CYLRefreshDrawnHeader, CYLRefreshValueAnimatorDelegate {

    private static let targetDegree = 270
    // [EN] `0.8f` promoted to double, as the Objective-C expressions computed it. [CN] 提升为 double 的 `0.8f`，与 Objective-C 表达式相同。
    private static let pointEightF = CGFloat(Float(0.8))

    private var springRatio: CGFloat = 0
    private var finishRatio: CGFloat = 0
    private var waveHeight: CGFloat = 0

    private var bollY: CGFloat = 0
    private var bollRadius: CGFloat = 0
    private var strokeWidth: CGFloat = 0

    private var animatorSpeed: CGFloat = 0
    private var animatorHeight: CGFloat = 0
    private var animatorSpringRatio: CGFloat = 0
    private var animatorSpringBollY: CGFloat = 0

    // 0 还没开始弹起 1 向上弹起 2 在弹起的最高点停住
    private var animatorStatus = 0

    private var showOuter = false
    private var showBoll = false
    private var showBollTail = false
    private var outerIsStart = false
    private var wavePulling = false

    private var refreshStop = 0
    private var refreshStart = 0
    private var refreshSwipe = 0

    private var animatorRebound: CYLRefreshValueAnimator?
    private var animatorRefreshing: CYLRefreshValueAnimator?
    private var animatorFinish: CYLRefreshValueAnimator?

    /**
     * [EN] Sets the BezierCircle size, finish duration, stretch mode and colors.
     * [CN] 初始化参数：设置 BezierCircle 的尺寸、结束时长、拉伸模式与颜色。
     */
    open override func setUpComponent() {
        super.setUpComponent()

        refreshStop = 90
        refreshStart = 90
        outerIsStart = true
        strokeWidth = 2

        height = 100
        finishDuration = 0.8

        isOpaque = false
        scrollMode = .stretch
        colorAccent = .white
        colorPrimary = UIColor(red: 0x11 / 255.0, green: 0x99 / 255.0, blue: 0xff / 255.0, alpha: 1)
    }

    // MARK: - Override

    /**
     * [EN] Pulls the wave down with the drag. [CN] 随拖动拉下波浪。
     */
    open override func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        if isDragging || wavePulling || status == .finishing {
            wavePulling = true
            waveHeight = Self.pointEightF * max(0, offset - expandHeight)
            setNeedsDisplay()
        }
    }

    /**
     * [EN] The user released: the wave springs and the ball pops out.
     * [CN] 用户松手：波浪回弹，小球弹出。
     */
    open override func onStartAnimationWhenRealeasing() {
        wavePulling = false
        bollRadius = expandHeight / 6
        // 动画参数初始化
        animatorSpeed = 0
        animatorStatus = 0
        animatorSpringRatio = 0
        animatorHeight = min(waveHeight * Self.pointEightF, expandHeight / 2)

        // 如果是手动调用 beginRefresh 直接指向刷新动画，不要回弹动画
        if dragOffset == 0 {
            showBoll = true
            startAnimatorRefreshing()
            bollY = expandHeight / 2
            return
        }

        // 贝塞尔弹性动画
        let animator = CYLRefreshValueAnimator()
        animator.setTarget(self, selector: #selector(onAnimation(_:)))
        animator.setFromToPoints([
            NSNumber(value: Double(waveHeight)), NSNumber(value: 0),
            NSNumber(value: Double(animatorHeight * -1.0)), NSNumber(value: 0),
            NSNumber(value: Double(animatorHeight * -0.4)), NSNumber(value: 0),
        ])
        animator.delegate = self
        animator.duration = durationNormal * 4
        animator.interpolator = .decelerate
        animator.start()
        animatorRebound = animator
    }

    /**
     * [EN] The refresh ended: the ball falls back into the wave.
     * [CN] 刷新结束：小球落回波浪。
     */
    open override func onRefreshFinished(_ success: Bool) {
        showBoll = false
        showOuter = false

        animatorRefreshing?.stop()

        // 贝塞尔弹性动画
        let animator = CYLRefreshValueAnimator()
        animator.setTarget(self, selector: #selector(onAnimation(_:)))
        animator.fromValue = 0
        animator.toValue = 1
        animator.delegate = self
        animator.duration = durationNormal * 3
        animator.interpolator = .accelerate
        animator.start()
        animatorFinish = animator
    }

    // MARK: - CYLRefreshValueAnimator

    // 动画执行
    @objc(onAnimation:)
    private func onAnimation(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorRebound {
            let curValue = animator.value
            let headHeight = expandHeight
            if animatorStatus == 0 && curValue <= 0 {
                animatorStatus = 1
                animatorSpeed = abs(curValue - waveHeight)
            }
            if animatorStatus == 1 {
                animatorSpringRatio = -curValue / animatorHeight
                if animatorSpringRatio >= springRatio {
                    springRatio = animatorSpringRatio
                    bollY = headHeight + curValue
                    animatorSpeed = abs(curValue - waveHeight)
                } else {
                    animatorStatus = 2
                    springRatio = 0
                    showBoll = true
                    showBollTail = true
                    animatorSpringBollY = bollY
                }
            }
            if animatorStatus == 2 {
                if bollY > headHeight / 2 {
                    bollY = max(headHeight / 2, bollY - animatorSpeed)
                    let bally = CGFloat(Float(animator.percent * (headHeight / 2 - animatorSpringBollY) + animatorSpringBollY))
                    if bollY > bally {
                        bollY = bally
                    }
                }
            }
            if showBollTail && curValue < waveHeight {
                startAnimatorRefreshing()
            }
            if !wavePulling {
                waveHeight = curValue
                setNeedsDisplay()
            }
        } else if animator === animatorFinish {
            finishRatio = animator.value
            setNeedsDisplay()
        } else if animator === animatorRefreshing {
            refreshStart += outerIsStart ? 3 : 10
            refreshStop += outerIsStart ? 10 : 3
            refreshStart = refreshStart % 360
            refreshStop = refreshStop % 360

            refreshSwipe = refreshStop - refreshStart
            refreshSwipe = refreshSwipe < 0 ? refreshSwipe + 360 : refreshSwipe

            if refreshSwipe >= Self.targetDegree {
                outerIsStart = false
            } else if refreshSwipe <= 10 {
                outerIsStart = true
            }
            setNeedsDisplay()
        }
    }

    /**
     * [EN] Releases the animator that ended. [CN] 动画结束：释放结束的动画器。
     */
    open func onAnimationEnd(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorRebound {
            animatorRebound = nil
        } else if animator === animatorFinish {
            finishRatio = 0
            animatorFinish = nil
        } else if animator === animatorRefreshing {
            animatorRefreshing = nil
        }
    }

    private func startAnimatorRefreshing() {
        showOuter = true
        showBollTail = false
        outerIsStart = true
        refreshStart = 90
        refreshStop = 90

        let animator = CYLRefreshValueAnimator()
        animator.setTarget(self, selector: #selector(onAnimation(_:)))
        animator.delegate = self
        animator.repeatCount = .infinity
        animator.start()
        animatorRefreshing = animator
    }

    // MARK: - Draw

    /**
     * [EN] Draws the wave, the springing ball, the ball, its ring and the finish.
     * [CN] 绘制波浪、弹起的小球、小球、外圈与完成动画。
     */
    open override func draw(_ rect: CGRect) {
        let width = self.width
        let height = dragOffset
        guard let context = UIGraphicsGetCurrentContext() else { return }

        drawWave(context, w: width, h: height)
        drawSpringUp(context, w: width)
        drawBoll(context, w: width)
        drawOuter(context, w: width)
        drawFinish(context, w: width)

        if height <= 0 {
            NSLog("%@.drawRect.height=%@ !", NSStringFromClass(type(of: self)), NSNumber(value: Double(height)))
        }
    }

    // 绘制完成动画
    private func drawFinish(_ context: CGContext, w width: CGFloat) {
        guard finishRatio > 0 else { return }
        let headHeight = expandHeight
        let beforeColor = colorAccent
        let ratio1: CGFloat = 0.3
        let ratio2: CGFloat = 0.7

        if finishRatio < ratio1 {
            beforeColor?.setFill()

            context.beginPath()
            context.addArc(center: CGPoint(x: width / 2, y: bollY), radius: bollRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
            context.fillPath()

            let outerR = bollRadius + strokeWidth * 2 * (1 + finishRatio / ratio1)

            let afterColor = beforeColor?.withAlphaComponent(1 - finishRatio / ratio1)
            afterColor?.setStroke()

            // 线的宽度
            context.setLineWidth(strokeWidth)
            context.beginPath()
            context.addArc(center: CGPoint(x: width / 2, y: bollY), radius: outerR, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
            context.drawPath(using: .stroke)
        }

        beforeColor?.setFill()

        if finishRatio >= ratio1 && finishRatio < ratio2 {
            let fraction = Float((finishRatio - CGFloat(Float(0.3))) / (ratio2 - ratio1))
            bollY = CGFloat(Int32(headHeight / 2 + (headHeight - headHeight / 2) * CGFloat(fraction)))

            context.beginPath()
            context.addArc(center: CGPoint(x: width / 2, y: bollY), radius: bollRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
            context.fillPath()

            if bollY >= headHeight - bollRadius * 1.5 {
                showBollTail = true
                drawBollTail(context, w: width, f: CGFloat(fraction))
            }
            showBollTail = false
        }

        if finishRatio >= ratio2 && finishRatio <= 1 {
            let fraction = Float((finishRatio - ratio2) / (1 - ratio2))
            let leftX = CGFloat(Int32(width / 2.0 - bollRadius - 2 * bollRadius * CGFloat(fraction)))

            context.beginPath()
            context.move(to: CGPoint(x: leftX, y: headHeight))
            context.addQuadCurve(to: CGPoint(x: width - leftX, y: headHeight),
                                 control: CGPoint(x: width / 2, y: headHeight - bollRadius * (1 - CGFloat(fraction))))
            context.fillPath()
        }
    }

    // 绘制小球外圈
    private func drawOuter(_ context: CGContext, w width: CGFloat) {
        guard showOuter else { return }
        let stroke = strokeWidth
        let outerR = bollRadius + stroke * 2

        let start = refreshStart
        let stop = refreshStop

        colorAccent?.setStroke()

        // 线的宽度
        context.setLineWidth(stroke)
        context.beginPath()
        context.addArc(center: CGPoint(x: width / 2, y: bollY), radius: outerR,
                       startAngle: CGFloat(Double(start) * Double.pi / 180), endAngle: CGFloat(Double(stop) * Double.pi / 180),
                       clockwise: false)
        context.drawPath(using: .stroke)
    }

    // 绘制小球向上弹起
    private func drawSpringUp(_ context: CGContext, w width: CGFloat) {
        guard springRatio > 0 else { return }
        colorAccent?.setFill()

        let leftX = CGFloat(Float(width / 2.0 - 4 * bollRadius + springRatio * 3 * bollRadius))
        if springRatio < 0.9 {
            context.beginPath()
            context.move(to: CGPoint(x: leftX, y: bollY))
            context.addQuadCurve(to: CGPoint(x: width - leftX, y: bollY),
                                 control: CGPoint(x: width / 2, y: bollY - bollRadius * springRatio * 2))
            context.closePath()
            context.fillPath()
        } else {
            context.beginPath()
            context.addArc(center: CGPoint(x: width / 2, y: bollY), radius: bollRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
            context.fillPath()
        }
    }

    // 绘制正常小球
    private func drawBoll(_ context: CGContext, w width: CGFloat) {
        guard showBoll else { return }
        colorAccent?.setFill()

        context.beginPath()
        context.addArc(center: CGPoint(x: width / 2, y: bollY), radius: bollRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        context.fillPath()

        let height = expandHeight
        drawBollTail(context, w: width, f: (height + waveHeight) / height)
    }

    // 绘制小球尾巴
    private func drawBollTail(_ context: CGContext, w width: CGFloat, f fraction: CGFloat) {
        guard showBollTail else { return }
        let bottom = expandHeight + waveHeight
        let startY = bollY + bollRadius * fraction / 2
        let startX = width / 2.0 + CGFloat(sqrtf(Float(bollRadius * bollRadius * (1 - fraction * fraction / 4))))
        let bezier1x = width / 2.0 + (bollRadius * 3 / 4) * (1 - fraction)
        let bezier2x = bezier1x + bollRadius

        colorAccent?.setFill()

        context.beginPath()
        context.move(to: CGPoint(x: startX, y: startY))
        context.addQuadCurve(to: CGPoint(x: bezier2x, y: bottom), control: CGPoint(x: bezier1x, y: bottom))
        context.addLine(to: CGPoint(x: width - bezier2x, y: bottom))
        context.addQuadCurve(to: CGPoint(x: width - startX, y: startY), control: CGPoint(x: width - bezier1x, y: bottom))
        context.closePath()
        context.fillPath()
    }

    // 绘制背景波形
    private func drawWave(_ context: CGContext, w width: CGFloat, h height: CGFloat) {
        // 重置画笔
        colorPrimary?.setFill()

        let expandHeight = self.expandHeight
        let baseHeight = min(expandHeight, height)
        if waveHeight != 0 && finishRatio == 0 {
            // 绘制贝塞尔曲线
            context.beginPath()
            context.move(to: CGPoint(x: 0, y: 0))
            context.addLine(to: CGPoint(x: width, y: 0))
            context.addLine(to: CGPoint(x: width, y: baseHeight))
            context.addQuadCurve(to: CGPoint(x: 0, y: baseHeight), control: CGPoint(x: width / 2, y: baseHeight + waveHeight * 2))
            context.closePath()
            context.fillPath()
        } else {
            context.fill(CGRect(x: 0, y: 0, width: width, height: baseHeight))
        }
    }
}
