//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshMaterialHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API (`colorSchemeColors`,
//      `progressSize`; the `CYLRefreshMaterialSize` enum stays in `CYLRefreshMaterialHeader.h`) and the same drawing,
//      colors and timing. The Objective-C float literals (`0.8f`, `1.332f`, the fast-out-slow-in table) keep their float
//      precision. `shapeLayer` stays readable by key-value coding (the tests read it).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API（`colorSchemeColors`、`progressSize`；
//      `CYLRefreshMaterialSize` 枚举保留在 `CYLRefreshMaterialHeader.h`）以及绘制、颜色与时序均不变。Objective-C 的 float 字面量
//      （`0.8f`、`1.332f`、快出慢入表）保持 float 精度。`shapeLayer` 仍可通过键值编码读取（测试会读取）。

import UIKit

/**
 * [EN] The Material Design swipe-refresh spinner, floating in front of the content.
 * [CN] Material Design 的下拉刷新圆圈，浮在内容前面。
 */
@objc(CYLRefreshMaterialHeader)
open class CYLRefreshMaterialHeader: CYLRefreshDrawnHeader, CYLRefreshValueAnimatorDelegate {

    // [EN] The Objective-C macros; `f` keeps a float literal's precision. [CN] Objective-C 的宏；`f` 保持 float 字面量的精度。
    private static func f(_ value: Float) -> CGFloat { CGFloat(value) }
    private static let maxProgressAngle = f(0.8)
    private static let maxProgressArc = f(0.8)
    private static let numPoints = 5
    private static let fullRotation: CGFloat = 1080
    private static let animationDuration = CFTimeInterval(Float(1.332))
    private static let endTrimStartDelayOffset: CGFloat = 0.5
    private static let startTrimDurationOffset: CGFloat = 0.5

    private static let fastOutSlowValues: [Float] = [
        0.0, 1.0E-4, 2.0E-4, 5.0E-4, 9.0E-4, 0.0014, 0.002, 0.0027, 0.0036, 0.0046, 0.0058, 0.0071, 0.0085, 0.0101,
        0.0118, 0.0137, 0.0158, 0.018, 0.0205, 0.0231, 0.0259, 0.0289, 0.0321, 0.0355, 0.0391, 0.043, 0.0471, 0.0514,
        0.056, 0.0608, 0.066, 0.0714, 0.0771, 0.083, 0.0893, 0.0959, 0.1029, 0.1101, 0.1177, 0.1257, 0.1339, 0.1426,
        0.1516, 0.161, 0.1707, 0.1808, 0.1913, 0.2021, 0.2133, 0.2248, 0.2366, 0.2487, 0.2611, 0.2738, 0.2867, 0.2998,
        0.3131, 0.3265, 0.34, 0.3536, 0.3673, 0.381, 0.3946, 0.4082, 0.4217, 0.4352, 0.4485, 0.4616, 0.4746, 0.4874,
        0.5, 0.5124, 0.5246, 0.5365, 0.5482, 0.5597, 0.571, 0.582, 0.5928, 0.6033, 0.6136, 0.6237, 0.6335, 0.6431,
        0.6525, 0.6616, 0.6706, 0.6793, 0.6878, 0.6961, 0.7043, 0.7122, 0.7199, 0.7275, 0.7349, 0.7421, 0.7491,
        0.7559, 0.7626, 0.7692, 0.7756, 0.7818, 0.7879, 0.7938, 0.7996, 0.8053, 0.8108, 0.8162, 0.8215, 0.8266,
        0.8317, 0.8366, 0.8414, 0.8461, 0.8507, 0.8551, 0.8595, 0.8638, 0.8679, 0.872, 0.876, 0.8798, 0.8836, 0.8873,
        0.8909, 0.8945, 0.8979, 0.9013, 0.9046, 0.9078, 0.9109, 0.9139, 0.9169, 0.9198, 0.9227, 0.9254, 0.9281,
        0.9307, 0.9333, 0.9358, 0.9382, 0.9406, 0.9429, 0.9452, 0.9474, 0.9495, 0.9516, 0.9536, 0.9556, 0.9575,
        0.9594, 0.9612, 0.9629, 0.9646, 0.9663, 0.9679, 0.9695, 0.971, 0.9725, 0.9739, 0.9753, 0.9766, 0.9779, 0.9791,
        0.9803, 0.9815, 0.9826, 0.9837, 0.9848, 0.9858, 0.9867, 0.9877, 0.9885, 0.9894, 0.9902, 0.991, 0.9917, 0.9924,
        0.9931, 0.9937, 0.9944, 0.9949, 0.9955, 0.996, 0.9964, 0.9969, 0.9973, 0.9977, 0.998, 0.9984, 0.9986, 0.9989,
        0.9991, 0.9993, 0.9995, 0.9997, 0.9998, 0.9999, 0.9999, 1.0, 1.0
    ]

    /**
     * [EN] The spinner's circle; read by key-value coding (`shapeLayer`).
     * [CN] 加载圈的圆；可通过键值编码读取（`shapeLayer`）。
     */
    @objc private(set) var shapeLayer: CAShapeLayer?
    private var arrowLayer: CAShapeLayer?
    private var highlightLayer: CAShapeLayer?

    private var origin: CGPoint = .zero

    private var animatorRefreshing: CYLRefreshValueAnimator?
    private var animatorFinishing: CYLRefreshValueAnimator?

    private var aniColorIndex = 0
    private var aniRotationCount = 0

    private var aniStartTrim: CGFloat = 0
    private var aniEndTrim: CGFloat = 0
    private var aniRotation: CGFloat = 0
    private var aniArrowScale: CGFloat = 0
    private var aniBeginStartTrim: CGFloat = 0
    private var aniBeginEndTrim: CGFloat = 0
    private var aniBeginRotation: CGFloat = 0

    // [EN] An empty array is ignored, as the Objective-C setter did. [CN] 与 Objective-C 的 setter 相同，忽略空数组。
    private var storedSchemeColors: [UIColor] = []
    private var aniSchemeColors: [UIColor] {
        get { storedSchemeColors }
        set { if !newValue.isEmpty { storedSchemeColors = newValue } }
    }

    private var storedProgressSize: CYLRefreshMaterialSize = .default

    // [EN] The circle's diameter for progressSize. [CN] progressSize 对应的圆直径。
    private var circleSize: CGFloat {
        progressSize == .large ? 56 : 40
    }

    private var maxArrowSize: CGFloat { 2 * circleSize / 40.0 }
    private var maxArrowRadius: CGFloat { 8 * circleSize / 40.0 }

    /**
     * [EN] The spinner's size; changing it sets the header height to twice the circle (Android MaterialProgressDrawable's
     *      `updateSizes`). [CN] 加载圈的尺寸；修改后刷新头高度为圆直径的两倍（对应 Android MaterialProgressDrawable 的 `updateSizes`）。
     */
    @objc open var progressSize: CYLRefreshMaterialSize {
        get { storedProgressSize }
        set {
            if storedProgressSize == newValue { return }
            storedProgressSize = newValue
            height = circleSize * 2
            setNeedsLayout()
        }
    }

    /**
     * [EN] The colors the arc takes in turn while refreshing; an empty array is ignored (Android
     *      MaterialProgressDrawable's `setColorSchemeColors`). [CN] 刷新时圆弧依次使用的颜色；空数组被忽略（对应 Android
     *      MaterialProgressDrawable 的 `setColorSchemeColors`）。
     */
    @objc open var colorSchemeColors: [UIColor] {
        get { aniSchemeColors }
        set { aniSchemeColors = newValue }
    }

    /**
     * [EN] Sets the Material size, colors and layers (circle, arrow, highlight).
     * [CN] 初始化参数：Material 的尺寸、颜色与图层（圆、箭头、高光）。
     */
    open override func setUpComponent() {
        super.setUpComponent()

        isOpaque = false
        height = circleSize * 2
        finishDuration = 0.2

        super.scrollMode = .front
        super.colorAccent = UIColor.clear
        super.colorPrimary = UIColor.white
        super.isUserInteractionEnabled = false

        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = colorPrimary?.cgColor
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOffset = CGSize(width: 0, height: 1)
        shapeLayer.shadowOpacity = 0.3
        shapeLayer.shadowRadius = 1.5
        shapeLayer.fillRule = .evenOdd
        layer.addSublayer(shapeLayer)
        self.shapeLayer = shapeLayer

        let arrowLayer = CAShapeLayer()
        arrowLayer.strokeColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
        arrowLayer.lineWidth = 0.5
        arrowLayer.fillColor = colorAccent?.cgColor
        shapeLayer.addSublayer(arrowLayer)
        self.arrowLayer = arrowLayer

        let highlightLayer = CAShapeLayer()
        highlightLayer.fillColor = UIColor.white.withAlphaComponent(0.2).cgColor
        highlightLayer.fillRule = .nonZero
        shapeLayer.addSublayer(highlightLayer)
        self.highlightLayer = highlightLayer

        aniSchemeColors = [
            UIColor(red: 0x00 / 255.0, green: 0x99 / 255.0, blue: 0xcc / 255.0, alpha: 1),
            UIColor(red: 0xff / 255.0, green: 0x44 / 255.0, blue: 0x44 / 255.0, alpha: 1),
            UIColor(red: 0x66 / 255.0, green: 0x99 / 255.0, blue: 0x00 / 255.0, alpha: 1),
            UIColor(red: 0xaa / 255.0, green: 0x66 / 255.0, blue: 0xcc / 255.0, alpha: 1),
            UIColor(red: 0xff / 255.0, green: 0x88 / 255.0, blue: 0x00 / 255.0, alpha: 1),
        ]
        resetSchemeColor()
    }

    /**
     * [EN] Colors the arrow; the clear color means "use the scheme colors".
     * [CN] 为箭头着色；透明色表示“使用配色方案中的颜色”。
     */
    open override var colorAccent: UIColor? {
        get { super.colorAccent }
        set {
            super.colorAccent = newValue
            if newValue === UIColor.clear {
                aniColorIndex = 0
                arrowLayer?.fillColor = aniSchemeColors.first?.cgColor
            } else {
                arrowLayer?.fillColor = newValue?.cgColor
            }
        }
    }

    /**
     * [EN] Colors the circle. [CN] 为圆着色。
     */
    open override var colorPrimary: UIColor? {
        get { super.colorPrimary }
        set {
            super.colorPrimary = newValue
            shapeLayer?.fillColor = newValue?.cgColor
        }
    }

    private func buildArrow(_ origin: CGPoint, p percent: CGFloat, b begin: CGFloat, e end: CGFloat, r rotate: CGFloat,
                            s scale: CGFloat) {
        let arrowPath = CGMutablePath()
        buildArrowPath(arrowPath, origin: origin, p: percent, b: begin, e: end, r: rotate, s: scale)
        arrowLayer?.path = arrowPath
    }

    private func buildCircle(_ origin: CGPoint, radius: CGFloat) {
        let path = CGMutablePath()
        buildCirclePath(path, origin: origin, radius: radius)
        shapeLayer?.path = path
        shapeLayer?.shadowPath = path

        let highlightPath = CGMutablePath()
        buildHighlightPath(highlightPath, origin: origin, radius: radius)
        highlightLayer?.path = highlightPath
    }

    private func buildCirclePath(_ path: CGMutablePath, origin: CGPoint, radius: CGFloat) {
        path.addArc(center: origin, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        path.closeSubpath()
    }

    private func buildHighlightPath(_ path: CGMutablePath, origin: CGPoint, radius: CGFloat) {
        // Add the highlight shape
        path.addArc(center: origin, radius: radius, startAngle: 0, endAngle: .pi, clockwise: true)
        path.addArc(center: CGPoint(x: origin.x, y: origin.y + 1.25), radius: radius, startAngle: .pi, endAngle: 0,
                    clockwise: false)
    }

    // [EN] origin: the circle's center; percent: the pull percent; begin / end: the arrow's start and end angle (0...1 is
    //      0...360); rotate: the arrow's rotation (0...1 is 0...360); scale: the arrow head's scale (not drawn under 0.3).
    // [CN] origin 圆心点；percent 下拉百分比；begin / end 箭头开始、结束角度（0～1 代表 0～360）；rotate 箭头旋转角度
    //      （0～1 代表 0～360）；scale 箭头缩放比例（小于 0.3 时不绘制箭头）。
    private func buildArrowPath(_ path: CGMutablePath, origin: CGPoint, p percent: CGFloat, b begin: CGFloat, e end: CGFloat,
                                r rotate: CGFloat, s scale: CGFloat) {
        guard percent > 0 else { return }
        // Add the arrow shape
        let arrowSize = maxArrowSize
        let arrowRadius = maxArrowRadius
        let arrowBigRadius = arrowRadius + (arrowSize / 2)
        let arrowSmallRadius = arrowRadius - (arrowSize / 2)
        let angleEnd = max(begin, end)
        let angleStart = min(end, begin)
        let anglePercent = min(1, max(0, angleEnd - angleStart))
        let angleAdjust = ((1 - anglePercent) * 2 * .pi) - .pi / 2
        let rotateAdjust = angleEnd * 2 * .pi

        var tf = CGAffineTransform.identity
        tf = tf.translatedBy(x: origin.x, y: origin.y)
        tf = tf.rotated(by: rotateAdjust + rotate * 2 * .pi)
        tf = tf.translatedBy(x: -origin.x, y: -origin.y)
        path.addArc(center: origin, radius: arrowBigRadius, startAngle: angleAdjust, endAngle: 3 * .pi / 2, clockwise: false,
                    transform: tf)

        if scale > 0.3 {
            let centerX = origin.x
            let centerY = origin.y - arrowBigRadius + arrowSize / 2

            tf = tf.translatedBy(x: centerX, y: centerY)
            tf = tf.scaledBy(x: scale, y: scale)
            tf = tf.translatedBy(x: -centerX, y: -centerY)

            path.addLine(to: CGPoint(x: origin.x, y: origin.y - arrowBigRadius - arrowSize), transform: tf)
            path.addLine(to: CGPoint(x: origin.x + (2 * arrowSize), y: origin.y - arrowBigRadius + (arrowSize / 2)), transform: tf)
            path.addLine(to: CGPoint(x: origin.x, y: origin.y - arrowBigRadius + (2 * arrowSize)), transform: tf)
            path.addLine(to: CGPoint(x: origin.x, y: origin.y - arrowBigRadius + arrowSize), transform: tf)

            tf = tf.translatedBy(x: centerX, y: centerY)
            tf = tf.scaledBy(x: 1 / scale, y: 1 / scale)
            tf = tf.translatedBy(x: -centerX, y: -centerY)
        }

        path.addArc(center: origin, radius: arrowSmallRadius, startAngle: 3 * .pi / 2, endAngle: angleAdjust, clockwise: true,
                    transform: tf)
        path.closeSubpath()
    }

    // MARK: - Override

    /**
     * [EN] While pulling, the circle comes down (y = M(1 - 8^(-x/H))) and the arrow grows and turns.
     * [CN] 下拉时圆圈下移（y = M(1 - 8^(-x/H))），箭头变长并旋转。
     */
    open override func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        if status == .refreshing || status == .releasing || status == .finishing {
            return
        }

        var distance = max(0, (offset - circleSize) / 2)

        // 公式 y = M(1-8^(-x/H))；M 能够达到的最大值，H 接近最大值的点
        let M = circleSize * 3
        let H = circleSize * 6
        let x = distance
        let y = M * (1 - pow(8, -x / H))

        distance = y

        let radius = circleSize / 2
        let percentage = min(distance / circleSize, 1)

        let expandHeight = self.expandHeight
        let width = self.width, height = offset

        let origin: CGPoint
        if distance == 0 {
            origin = CGPoint(x: floor(width / 2), y: height - radius)
        } else {
            origin = CGPoint(x: floor(width / 2), y: radius + distance)
        }

        self.origin = origin
        buildCircle(origin, radius: radius)

        let extraOS = abs(offset) - expandHeight
        let tensionSlingshotPercent = max(0, min(extraOS, expandHeight * 2) / expandHeight)
        let tensionPercent = ((tensionSlingshotPercent / 4) - pow(tensionSlingshotPercent / 4, 2)) * 2
        let strokeEnd = min(Self.maxProgressAngle, percentage * Self.f(0.8))
        let arrowScale = min(1, percentage)
        let arrowRotation = (Self.f(0.4) * percentage + tensionPercent * 2) * 0.5

        aniStartTrim = 0
        aniEndTrim = strokeEnd
        aniArrowScale = arrowScale
        aniRotation = arrowRotation
        buildArrow(origin, p: percentage, b: 0, e: strokeEnd, r: arrowRotation, s: arrowScale)
    }

    private func morph(_ layer: CALayer?, keyPath: String, to toPath: CGPath, from fromPath: CGPath?,
                       duration: CFTimeInterval, function: CAMediaTimingFunction) {
        let morph = CABasicAnimation(keyPath: keyPath)
        morph.duration = duration
        morph.fillMode = .forwards
        morph.isRemovedOnCompletion = true
        morph.toValue = toPath
        morph.fromValue = fromPath
        morph.timingFunction = function
        layer?.add(morph, forKey: nil)
    }

    /**
     * [EN] The user released: the circle moves to the middle of the open area.
     * [CN] 用户松手：圆圈移到展开区域的中间。
     */
    open override func onStartAnimationWhenRealeasing() {
        // Start the shape disappearance animation
        let origin = CGPoint(x: width / 2, y: expandHeight / 2)

        let radius = circleSize / 2
        let toPath = CGMutablePath()
        buildCirclePath(toPath, origin: origin, radius: radius)

        let function = CAMediaTimingFunction(name: .easeOut)

        morph(shapeLayer, keyPath: "path", to: toPath, from: shapeLayer?.path, duration: 0.15, function: function)
        shapeLayer?.path = toPath

        morph(shapeLayer, keyPath: "shadowPath", to: toPath, from: shapeLayer?.shadowPath, duration: 0.15, function: function)
        shapeLayer?.shadowPath = toPath

        let arrowPath = CGMutablePath()
        buildArrowPath(arrowPath, origin: origin, p: 1, b: aniStartTrim, e: aniEndTrim, r: aniRotation, s: aniArrowScale)
        morph(arrowLayer, keyPath: "path", to: arrowPath, from: arrowLayer?.path, duration: 0.15, function: function)
        arrowLayer?.path = arrowPath

        let highlightPath = CGMutablePath()
        buildHighlightPath(highlightPath, origin: origin, radius: radius)
        morph(highlightLayer, keyPath: "path", to: highlightPath, from: highlightLayer?.path, duration: 0.15, function: function)
        highlightLayer?.path = highlightPath

        self.origin = origin
    }

    /**
     * [EN] The refresh started: the arc spins and changes color.
     * [CN] 刷新开始：圆弧旋转并变换颜色。
     */
    open override func onStartAnimationWhenRefreshing() {
        goToNextColor()
        aniRotationCount = 0
        if aniStartTrim != aniEndTrim {
            storeOriginals()
            startAnimatorFinishing()
        } else {
            resetOriginals()
            startAnimatorRefreshing()
        }
    }

    /**
     * [EN] The refresh ended: the animations stop and the circle shrinks away.
     * [CN] 刷新结束：动画停止，圆圈缩小消失。
     */
    open override func onRefreshFinished(_ success: Bool) {
        animatorFinishing?.stop()
        animatorRefreshing?.stop()

        resetOriginals()
        resetSchemeColor()

        let radius: CGFloat = 2
        let toPath = CGMutablePath()
        buildCirclePath(toPath, origin: origin, radius: radius)

        let function = CAMediaTimingFunction(name: .easeOut)
        morph(shapeLayer, keyPath: "path", to: toPath, from: shapeLayer?.path, duration: finishDuration, function: function)
        morph(shapeLayer, keyPath: "shadowPath", to: toPath, from: shapeLayer?.shadowPath, duration: finishDuration,
              function: function)

        arrowLayer?.path = nil
        shapeLayer?.path = nil
        shapeLayer?.shadowPath = nil
        highlightLayer?.path = nil
    }

    // MARK: - CYLRefreshValueAnimator

    // [EN] One frame of the refreshing spin. [CN] 刷新旋转动画的一帧。
    @objc private func onAnimationRefreshing(_ animator: CYLRefreshValueAnimator) {
        let interpolatedTime = animator.percent
        let startingTrim = aniBeginStartTrim
        let startingEndTrim = aniBeginEndTrim
        let startingRotation = aniBeginRotation
        let minProgressArc = getMinProgressArc()

        // Moving the start trim only occurs in the first 50% of a single ring animation
        if interpolatedTime <= Self.startTrimDurationOffset {
            // scale the interpolatedTime so that the full transformation from 0 - 1 takes place in the remaining time
            let scaledTime = interpolatedTime / (1.0 - Self.startTrimDurationOffset)
            let percent = getFastOutSlowValue(scaledTime)
            aniStartTrim = startingTrim + ((Self.maxProgressArc - minProgressArc) * percent)
        }

        // Moving the end trim starts after 50% of a single ring animation completes
        if interpolatedTime > Self.endTrimStartDelayOffset {
            // scale the interpolatedTime so that the full transformation from 0 - 1 takes place in the remaining time
            let minArc = Self.maxProgressArc - minProgressArc
            let scaledTime = (interpolatedTime - Self.startTrimDurationOffset) / (1.0 - Self.startTrimDurationOffset)
            let percent = getFastOutSlowValue(scaledTime)
            aniEndTrim = startingEndTrim + (minArc * percent)
        }

        aniRotation = startingRotation + (0.25 * interpolatedTime)

        // [EN] Integer division, as in Objective-C. [CN] 与 Objective-C 相同的整数除法。
        let groupRotation = ((Self.fullRotation / CGFloat(Self.numPoints)) * interpolatedTime)
            + (Self.fullRotation * CGFloat(aniRotationCount / Self.numPoints))

        let rotate = aniRotation + groupRotation / 360
        aniRotation = rotate
        let arrowPath = CGMutablePath()
        buildArrowPath(arrowPath, origin: origin, p: 1, b: aniStartTrim, e: aniEndTrim, r: rotate, s: 0)
        arrowLayer?.path = arrowPath
    }

    // [EN] One frame of the finishing shrink: shrink back down and complete a full rotation (0...1) before the next
    //      circle. [CN] 结束收缩动画的一帧：收缩并完成一整圈旋转（0...1）后再开始下一圈。
    @objc private func onAnimationFinishing(_ animator: CYLRefreshValueAnimator) {
        let interpolatedTime = animator.percent
        let minProgressArc = getMinProgressArc()
        let targetRotation = floor(aniBeginRotation / Self.maxProgressArc) + 1
        let startTrim = aniBeginStartTrim + (aniBeginEndTrim - minProgressArc - aniBeginStartTrim) * interpolatedTime
        let rotation = aniBeginRotation + ((targetRotation - aniBeginRotation) * interpolatedTime)

        aniStartTrim = startTrim
        aniEndTrim = aniBeginEndTrim
        aniRotation = rotation

        let arrowPath = CGMutablePath()
        buildArrowPath(arrowPath, origin: origin, p: 1, b: startTrim, e: aniBeginEndTrim, r: rotation, s: aniArrowScale)
        arrowLayer?.path = arrowPath
    }

    /**
     * [EN] A round of the refreshing spin ended: next color, next rotation.
     * [CN] 刷新旋转完成一轮：换下一个颜色、下一圈旋转。
     */
    public func onAnimationRepeat(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorRefreshing {
            goToNextColor()
            storeOriginals()
            aniStartTrim = aniEndTrim
            aniRotationCount = (aniRotationCount + 1) % Self.numPoints
        }
    }

    /**
     * [EN] An animator ended: after the finishing shrink, the refreshing spin starts while still refreshing.
     * [CN] 动画器结束：结束收缩后，若仍在刷新则开始刷新旋转。
     */
    public func onAnimationEnd(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorFinishing {
            animatorFinishing = nil
            if isRefreshing {
                goToNextColor()
                storeOriginals()
                aniStartTrim = aniEndTrim
                startAnimatorRefreshing()
            }
        } else if animator === animatorRefreshing {
            animatorRefreshing = nil
        }
    }

    private func startAnimatorRefreshing() {
        let animator = CYLRefreshValueAnimator()
        animator.setTarget(self, selector: #selector(onAnimationRefreshing(_:)))
        animator.delegate = self
        animator.duration = Self.animationDuration
        animator.repeatCount = .infinity
        animator.repeatMode = .restart
        animator.start()
        animatorRefreshing = animator
    }

    private func startAnimatorFinishing() {
        let animator = CYLRefreshValueAnimator()
        animator.setTarget(self, selector: #selector(onAnimationFinishing(_:)))
        animator.delegate = self
        animator.duration = CFTimeInterval(Float(1.332) / 2)
        animator.start()
        animatorFinishing = animator
    }

    private func getMinProgressArc() -> CGFloat {
        (maxArrowSize / (2 * .pi * maxArrowRadius)) * .pi / 180
    }

    // [EN] The fast-out-slow-in interpolator. [CN] 加速器（快出慢入）。
    private func getFastOutSlowValue(_ input: CGFloat) -> CGFloat {
        if input >= 1.0 {
            return 1.0
        }
        if input <= 0.0 {
            return 0.0
        }
        let values = Self.fastOutSlowValues
        let length = values.count
        let stepSize = CGFloat(Float(1.0) / Float(length - 1))
        let i = min(Int(CGFloat(length - 1) * input), length - 2)
        let paramFloat = (input - CGFloat(i) * stepSize) / stepSize
        return CGFloat(values[i]) + CGFloat(values[i + 1] - values[i]) * paramFloat
    }

    private func storeOriginals() {
        aniBeginEndTrim = aniEndTrim
        aniBeginStartTrim = aniStartTrim
        aniBeginRotation = aniRotation
    }

    private func resetOriginals() {
        aniEndTrim = 0
        aniStartTrim = 0
        aniRotation = 0
        storeOriginals()
    }

    private func goToNextColor() {
        if colorAccent === UIColor.clear {
            aniColorIndex = (aniColorIndex + 1) % aniSchemeColors.count
            arrowLayer?.fillColor = aniSchemeColors[aniColorIndex].cgColor
        }
    }

    private func resetSchemeColor() {
        aniColorIndex = 0
        if colorAccent === UIColor.clear {
            arrowLayer?.fillColor = aniSchemeColors.first?.cgColor
        } else {
            arrowLayer?.fillColor = colorAccent?.cgColor
        }
    }

    /**
     * [EN] Draws nothing; kept as in Objective-C (the layers draw the spinner).
     * [CN] 不绘制任何内容；与 Objective-C 相同保留（加载圈由图层绘制）。
     */
    open override func draw(_ rect: CGRect) {
        // Drawing code
    }
}
