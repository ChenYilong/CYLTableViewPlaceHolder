//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshWaveSwipeHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API (`waveShadowRadius`,
//      `waveShadowColor`) and the same drawing, colors and timing. The Objective-C float literals (the Bezier point
//      tables, the wave bounds, durations, the fast-out-slow-in table) keep their float precision.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API（`waveShadowRadius`、`waveShadowColor`）
//      以及绘制、颜色与时序均不变。Objective-C 的 float 字面量（贝塞尔点表、波浪界限、时长、快出慢入表）保持 float 精度。

import UIKit

// [EN] Keeps a float literal's precision, as the Objective-C `0.1655f` stored in a CGFloat.
// [CN] 保持 float 字面量的精度，与 Objective-C 中存入 CGFloat 的 `0.1655f` 相同。
private func f(_ value: Float) -> CGFloat { CGFloat(value) }

// [EN] The Bezier points of the wave; the left two anchors are mirrored on the right.
// [CN] 波浪的贝塞尔曲线坐标；左侧两个锚点镜像到右侧。
// [EN] Each group of three: two handles, then an anchor. [CN] 每三个一组：两个控制柄，然后一个锚点。
private let beginPoints: [[CGFloat]] = [
    // 1
    [f(0.1655), 0],
    [f(0.4188), f(-0.0109)],
    [f(0.4606), f(-0.0049)],
    // 2
    [f(0.4893), 0],
    [f(0.4893), 0],
    [f(0.5), 0],
]
private let appearPoints: [[CGFloat]] = [
    // 1
    [f(0.1655), 0],
    [f(0.5237), f(0.0553)],
    [f(0.4557), f(0.0936)],
    // 2
    [f(0.3908), f(0.1302)],
    [f(0.4303), f(0.2173)],
    [f(0.5), f(0.2173)],
]
private let expandPoints: [[CGFloat]] = [
    // 1
    [f(0.1655), 0],
    [f(0.5909), f(0.0000)],
    [f(0.4557), f(0.1642)],
    // 2
    [f(0.3941), f(0.2061)],
    [f(0.4303), f(0.2889)],
    [f(0.5), f(0.2889)],
]

private let fastOutSlowValues: [Float] = [
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
 * [EN] A wave pulled down from the top, with a spinner in its drop (after WaveSwipeRefreshLayout); floats in front of the
 *      content.
 * [CN] 从顶部拉下的波浪，水滴中带加载圈（参考 WaveSwipeRefreshLayout）；浮在内容前面。
 */
@objc(CYLRefreshWaveSwipeHeader)
open class CYLRefreshWaveSwipeHeader: CYLRefreshDrawnHeader, CYLRefreshValueAnimatorDelegate {

    private static let circleSize: CGFloat = 40
    private static let maxArrowSize: CGFloat = 2
    private static let maxArrowRadius: CGFloat = 8
    private static let maxProgressArc = f(0.8)
    // [EN] The largest rotation before the drop (MAX_PROGRESS_ANGLE). [CN] 落下前旋转的最大角度值（MAX_PROGRESS_ANGLE）。
    private static let maxProgressRotationRate = f(0.8)
    private static let numPoints = 5
    private static let fullRotation: CGFloat = 1080
    private static let animationDuration = CFTimeInterval(Float(1.332))
    private static let endTrimStartDelayOffset: CGFloat = 0.5
    private static let startTrimDurationOffset: CGFloat = 0.5
    private static let waveFirst = f(0.1)
    private static let waveSecond = CGFloat(Float(0.16) + Float(0.1))
    private static let dropCircleAnimatorDuration = CFTimeInterval(Float(0.5))
    private static let dropVertexAnimationDuration = CFTimeInterval(Float(0.5))
    private static let dropBounceAnimatorDuration = CFTimeInterval(Float(0.5))
    // [EN] How long the wave wobbles. [CN] 波浪摆动的时长。
    private static let waveAnimatorDuration: CFTimeInterval = 1
    // [EN] The wave's highest point. [CN] 波浪的最大高度。
    private static let maxWaveHeight = f(0.2)

    private var waveLayer: CAShapeLayer?
    private var shapeLayer: CAShapeLayer?
    private var arrowLayer: CAShapeLayer?

    private var origin: CGPoint = .zero

    private var animatorDroping: CYLRefreshValueAnimator?
    private var animatorFinishing: CYLRefreshValueAnimator?
    private var animatorRefreshing: CYLRefreshValueAnimator?

    private var aniStartTrim: CGFloat = 0
    private var aniEndTrim: CGFloat = 0
    private var aniRotation: CGFloat = 0
    private var aniArrowScale: CGFloat = 0
    private var aniBeginStartTrim: CGFloat = 0
    private var aniBeginEndTrim: CGFloat = 0
    private var aniBeginRotation: CGFloat = 0

    private var aniRotationCount = 0

    private var dropBounceBlock: ((CGFloat) -> CGFloat)?

    private var lastFirstBounds: CGFloat = 0
    // [EN] The drop's radius. [CN] 圆的半径。
    private var dropCircleRadius: CGFloat = 0
    // [EN] The largest height the drop falls to. [CN] 圆落下的最大高度。
    private var maxDropHeight: CGFloat = 0
    // [EN] The vertex of the triangle that follows the falling drop. [CN] 跟随落下的圆的三角形顶点的动画器。
    private var animatorDropVertex: CYLRefreshValueAnimator?
    // [EN] The landed drop stretching sideways. [CN] 落下的圆横向伸展的动画器。
    private var animatorDropBounceVertical: CYLRefreshValueAnimator?
    // [EN] The landed drop stretching up and down. [CN] 落下的圆纵向伸展的动画器。
    private var animatorDropBounceHorizontal: CYLRefreshValueAnimator?
    // [EN] The falling drop's center. [CN] 落下的圆的圆心坐标动画器。
    private var animatorDropCircle: CYLRefreshValueAnimator?
    // [EN] The wave coming back. [CN] 返回的波浪的动画器。
    private var animatorWaveReverse: CYLRefreshValueAnimator?

    /**
     * [EN] The blur radius of the wave's and the drop's shadow, in points; default 1.5 (Android WaveView's
     *      `setShadow(radius, color)`). [CN] 波浪与水滴阴影的模糊半径（点）；默认 1.5（对应 Android WaveView 的 `setShadow(radius, color)`）。
     */
    @objc open var waveShadowRadius: CGFloat {
        get { waveLayer?.shadowRadius ?? 1.5 }
        set {
            waveLayer?.shadowRadius = newValue
            shapeLayer?.shadowRadius = newValue
        }
    }

    /**
     * [EN] The color of the wave's and the drop's shadow; default black at 30% (Android WaveView's `setShadow(radius, color)`).
     * [CN] 波浪与水滴阴影的颜色；默认 30% 的黑色（对应 Android WaveView 的 `setShadow(radius, color)`）。
     */
    @objc open var waveShadowColor: UIColor {
        get {
            guard let layer = waveLayer, let shadowColor = layer.shadowColor else {
                return UIColor.black.withAlphaComponent(0.3)
            }
            return UIColor(cgColor: shadowColor).withAlphaComponent(CGFloat(layer.shadowOpacity))
        }
        set {
            let alpha = newValue.cgColor.alpha
            let opaque = newValue.withAlphaComponent(1)
            for layer in [waveLayer, shapeLayer].compactMap({ $0 }) {
                layer.shadowColor = opaque.cgColor
                layer.shadowOpacity = Float(alpha)
            }
        }
    }

    /**
     * [EN] Sets the WaveSwipe size, colors, layers (wave, drop, arrow, highlight) and the drop's bounce curve.
     * [CN] 初始化参数：WaveSwipe 的尺寸、颜色、图层（波浪、水滴、箭头、高光）与水滴的弹跳曲线。
     */
    open override func setUpComponent() {
        super.setUpComponent()

        isOpaque = false
        height = Self.circleSize * 3
        finishDuration = 0.2

        scrollMode = .front
        colorAccent = UIColor.white
        colorPrimary = UIColor.systemBlue
        isUserInteractionEnabled = false

        let waveLayer = CAShapeLayer()
        waveLayer.fillColor = colorPrimary?.cgColor
        waveLayer.shadowColor = UIColor.black.cgColor
        waveLayer.shadowOffset = CGSize(width: 0, height: 1)
        waveLayer.shadowOpacity = 0.3
        waveLayer.shadowRadius = 1.5
        waveLayer.fillRule = .evenOdd
        layer.addSublayer(waveLayer)
        self.waveLayer = waveLayer

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

        // [EN] The original left out `+ kMaxArrowSize / 2`. [CN] 原代码去掉了 `+ kMaxArrowSize / 2`。
        dropCircleRadius = Self.maxArrowRadius

        dropBounceBlock = { v in
            // y = -19 * (x - 0.125)^2 + 1.3     (0 <= x < 0.25)
            // y = -6.5 * (x - 0.625)^2 + 1.1    (0.5 <= x < 0.75)
            // y = 0                             (0.25 <= x < 0.5 || 0.75 <= x <=1)
            if v < 0.25 {
                return f(-38.4) * ((v - 0.125) * (v - 0.125)) + f(0.6)
            } else if v >= 0.5 && v < 0.75 {
                return f(-19.2) * ((v - 0.625) * (v - 0.625)) + f(0.3)
            } else {
                return 0
            }
        }
    }

    /**
     * [EN] Colors the arrow. [CN] 为箭头着色。
     */
    open override var colorAccent: UIColor? {
        get { super.colorAccent }
        set {
            super.colorAccent = newValue
            arrowLayer?.fillColor = newValue?.cgColor
        }
    }

    /**
     * [EN] Colors the wave and the drop. [CN] 为波浪与水滴着色。
     */
    open override var colorPrimary: UIColor? {
        get { super.colorPrimary }
        set {
            super.colorPrimary = newValue
            shapeLayer?.fillColor = newValue?.cgColor
            waveLayer?.fillColor = newValue?.cgColor
        }
    }

    private func buildArrow(_ origin: CGPoint, p percent: CGFloat, b begin: CGFloat, e end: CGFloat, r rotate: CGFloat,
                            s scale: CGFloat) {
        let arrowPath = CGMutablePath()
        buildArrowPath(arrowPath, origin: origin, p: percent, b: begin, e: end, r: rotate, s: scale)
        arrowLayer?.path = arrowPath
    }

    // [EN] origin: the circle's center; percent: the pull percent; begin / end: the arrow's start and end angle (0...1 is
    //      0...360); rotate: the arrow's rotation (0...1 is 0...360); scale: the arrow head's scale (not drawn under 0.3).
    // [CN] origin 圆心点；percent 下拉百分比；begin / end 箭头开始、结束角度（0～1 代表 0～360）；rotate 箭头旋转角度
    //      （0～1 代表 0～360）；scale 箭头缩放比例（小于 0.3 时不绘制箭头）。
    private func buildArrowPath(_ path: CGMutablePath, origin: CGPoint, p percent: CGFloat, b begin: CGFloat, e end: CGFloat,
                                r rotate: CGFloat, s scale: CGFloat) {
        guard percent > 0 else { return }
        // Add the arrow shape
        let arrowSize = Self.maxArrowSize
        let arrowRadius = Self.maxArrowRadius
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

    private func setWavePath(_ path: CGPath) {
        waveLayer?.path = path
        waveLayer?.shadowPath = path
    }

    // [EN] The wave that swells while pulled, before the drop is drawn. [CN] 开始绘制圆之前、下拉时膨胀的波浪部分。
    private func wavePhase(_ width: CGFloat, first move1: CGFloat) {
        let path = CGMutablePath()
        let b = beginPoints
        if move1 > 0.008 {
            path.move(to: CGPoint(x: 0, y: 0))
            // left half
            path.addCurve(to: CGPoint(x: width * b[2][0], y: width * (b[2][1] + move1)),
                          control1: CGPoint(x: width * b[0][0], y: b[0][1]),
                          control2: CGPoint(x: width * b[1][0], y: width * (b[1][1] + move1)))
            path.addCurve(to: CGPoint(x: width * b[5][0], y: width * (b[5][1] + move1)),
                          control1: CGPoint(x: width * b[3][0], y: width * (b[3][1] + move1)),
                          control2: CGPoint(x: width * b[4][0], y: width * (b[4][1] + move1)))
            // right half
            path.addCurve(to: CGPoint(x: width - width * b[2][0], y: width * (b[2][1] + move1)),
                          control1: CGPoint(x: width - width * b[4][0], y: width * (b[4][1] + move1)),
                          control2: CGPoint(x: width - width * b[3][0], y: width * (b[3][1] + move1)))
            path.addCurve(to: CGPoint(x: width, y: 0),
                          control1: CGPoint(x: width - width * b[1][0], y: width * (b[1][1] + move1)),
                          control2: CGPoint(x: width - width * b[0][0], y: b[0][1]))
        }
        setWavePath(path)
    }

    // [EN] The wave with the drop appearing. [CN] 带出现中的圆的波浪。
    private func wavePhase(_ width: CGFloat, first move1: CGFloat, second move2: CGFloat) {
        let path = CGMutablePath()
        let b = beginPoints, a = appearPoints
        path.move(to: CGPoint(x: 0, y: 0))

        // left half
        path.addCurve(to: CGPoint(x: width * max(b[2][0] - move2, a[2][0]), y: width * max(b[2][1] + move1 - move2, a[2][1])),
                      control1: CGPoint(x: width * a[0][0], y: width * a[0][1]),
                      control2: CGPoint(x: width * min(b[1][0] + move2, a[1][0]), y: width * max(b[1][1] + move1 - move2, a[1][1])))
        path.addCurve(to: CGPoint(x: width * a[5][0], y: width * min(b[0][1] + move1 + move2, a[5][1])),
                      control1: CGPoint(x: width * max(b[3][0] - move2, a[3][0]), y: width * min(b[3][1] + move1 + move2, a[3][1])),
                      control2: CGPoint(x: width * max(b[4][0] - move2, a[4][0]), y: width * min(b[4][1] + move1 + move2, a[4][1])))
        // right half
        path.addCurve(to: CGPoint(x: width - width * max(b[2][0] - move2, a[2][0]),
                                  y: width * max(b[2][1] + move1 - move2, a[2][1])),
                      control1: CGPoint(x: width - width * max(b[4][0] - move2, a[4][0]),
                                        y: width * min(b[4][1] + move1 + move2, a[4][1])),
                      control2: CGPoint(x: width - width * max(b[3][0] - move2, a[3][0]),
                                        y: width * min(b[3][1] + move1 + move2, a[3][1])))
        path.addCurve(to: CGPoint(x: width, y: 0),
                      control1: CGPoint(x: width - width * min(b[1][0] + move2, a[1][0]),
                                        y: width * max(b[1][1] + move1 - move2, a[1][1])),
                      control2: CGPoint(x: width - width * a[0][0], y: width * a[0][1]))

        origin = CGPoint(x: origin.x, y: width * min(b[3][1] + move1 + move2, a[3][1]) + dropCircleRadius)
        setWavePath(path)
    }

    // [EN] The wave expanding around the drop. [CN] 圆周围展开的波浪。
    private func wavePhase(_ width: CGFloat, first move1: CGFloat, second move2: CGFloat, final move3: CGFloat) {
        let path = CGMutablePath()
        let b = beginPoints, a = appearPoints, e = expandPoints
        path.move(to: CGPoint(x: 0, y: 0))

        // left half
        path.addCurve(to: CGPoint(x: width * max(b[2][0] - move2, e[2][0]),
                                  y: width * min(max(b[2][1] + move1 - move2, a[2][1]) + move3, e[2][1])),
                      control1: CGPoint(x: width * e[0][0], y: width * e[0][1]),
                      control2: CGPoint(x: width * min(min(b[1][0] + move2, a[1][0]) + move3, e[1][0]),
                                        y: width * max(max(b[1][1] + move1 - move2, a[1][1]) - move3, e[1][1])))
        path.addCurve(to: CGPoint(x: width * e[5][0], y: width * min(min(b[0][1] + move1 + move2, a[5][1]) + move3, e[5][1])),
                      control1: CGPoint(x: width * min(max(b[3][0] - move2, a[3][0]) + move3, e[3][0]),
                                        y: width * min(min(b[3][1] + move1 + move2, a[3][1]) + move3, e[3][1])),
                      control2: CGPoint(x: width * max(b[4][0] - move2, e[4][0]),
                                        y: width * min(min(b[4][1] + move1 + move2, a[4][1]) + move3, e[4][1])))
        // right half
        path.addCurve(to: CGPoint(x: width - width * max(b[2][0] - move2, e[2][0]),
                                  y: width * min(max(b[2][1] + move1 - move2, a[2][1]) + move3, e[2][1])),
                      control1: CGPoint(x: width - width * max(b[4][0] - move2, e[4][0]),
                                        y: width * min(min(b[4][1] + move1 + move2, a[4][1]) + move3, e[4][1])),
                      control2: CGPoint(x: width - width * min(max(b[3][0] - move2, a[3][0]) + move3, e[3][0]),
                                        y: width * min(min(b[3][1] + move1 + move2, a[3][1]) + move3, e[3][1])))
        path.addCurve(to: CGPoint(x: width, y: 0),
                      control1: CGPoint(x: width - width * min(min(b[1][0] + move2, a[1][0]) + move3, e[1][0]),
                                        y: width * max(max(b[1][1] + move1 - move2, a[1][1]) - move3, e[1][1])),
                      control2: CGPoint(x: width - width * e[0][0], y: width * e[0][1]))

        origin = CGPoint(x: origin.x,
                         y: width * min(min(b[3][1] + move1 + move2, a[3][1]) + move3, e[3][1]) + dropCircleRadius)
        setWavePath(path)
    }

    // MARK: - Override

    /**
     * [EN] Remembers the drop's largest height (the header width).
     * [CN] 记录圆落下的最大高度（刷新头宽度）。
     */
    open override func scrollView(_ scrollView: UIScrollView, attached attach: Bool) {
        super.scrollView(scrollView, attached: attach)
        maxDropHeight = width
    }

    /**
     * [EN] While dragging, the wave swells and the drop with its arrow appears; on release, the wave goes back.
     * [CN] 拖动时波浪膨胀，带箭头的水滴出现；松开后波浪返回。
     */
    open override func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        if status == .refreshing || status == .releasing || status == .finishing {
            return
        }

        if isDragging {
            let width = self.width

            let seed = offset / width
            let firstBounds = seed * (5 - 2 * seed) / 3.5
            let secondBounds = firstBounds - Self.waveFirst
            let finalBounds = (firstBounds - Self.waveSecond) / 5

            if firstBounds < Self.waveFirst {
                // draw a wave and not draw a circle
                wavePhase(width, first: firstBounds)
            } else if firstBounds < Self.waveSecond {
                // draw a circle with a wave
                wavePhase(width, first: firstBounds, second: secondBounds)
            } else {
                // draw a circle with expanding a wave
                wavePhase(width, first: firstBounds, second: secondBounds, final: finalBounds)
            }

            let origin = CGPoint(x: floor(width / 2), y: self.origin.y)

            let dragPercent = min(1, percent)
            let adjustedPercent = max(dragPercent - 0.4, 0) * 5 / 3

            // 0f...2f
            let tensionSlingshotPercent: CGFloat = (percent > 3) ? 2 : (percent > 1) ? percent - 1 : 0
            let tensionPercent = (4 - tensionSlingshotPercent) * tensionSlingshotPercent / 8

            if percent < 1 {
                aniStartTrim = 0
                aniArrowScale = min(1, adjustedPercent)
                aniEndTrim = min(adjustedPercent * f(0.8), Self.maxProgressRotationRate)
            }

            let rotation = (-0.25 + f(0.4) * adjustedPercent + tensionPercent * 2) * 0.5

            self.origin = origin
            aniRotation = rotation
            lastFirstBounds = firstBounds
            buildArrow(origin, p: percent, b: aniStartTrim, e: aniEndTrim, r: rotation, s: aniArrowScale)
        } else if lastFirstBounds > 0 {
            startAnimationWaveReverse(lastFirstBounds)
            aniRotation = 0
            aniEndTrim = 0
            aniStartTrim = 0
            aniArrowScale = 0
            lastFirstBounds = 0
        }
    }

    /**
     * [EN] The user released: the drop falls and the wave goes back.
     * [CN] 用户松手：水滴落下，波浪返回。
     */
    open override func onStartAnimationWhenRealeasing() {
        if dragOffset == 0 {
            // [EN] beginRefresh called by code: place the drop's starting point. [CN] 手动调用 beginRefresh 时定位小球的原始落点。
            origin = CGPoint(x: floor(width / 2), y: width * 500 / 1440)
        }

        lastFirstBounds = 0
        startAnimationDroping()
        startAnimationWaveReverse(f(0.1))
    }

    /**
     * [EN] The refresh started: the arc in the drop spins.
     * [CN] 刷新开始：水滴中的圆弧旋转。
     */
    open override func onStartAnimationWhenRefreshing() {
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
     * [EN] The refresh ended: the animations stop and the drop shrinks away.
     * [CN] 刷新结束：动画停止，水滴缩小消失。
     */
    open override func onRefreshFinished(_ success: Bool) {
        animatorFinishing?.stop()
        animatorRefreshing?.stop()

        let origin = self.origin
        let toPath = CGMutablePath()
        toPath.addRect(CGRect(x: origin.x - 1, y: origin.y - 1, width: 2, height: 2))
        let function = CAMediaTimingFunction(name: .easeOut)

        let pathMorph = CABasicAnimation(keyPath: "path")
        pathMorph.duration = finishDuration
        pathMorph.fillMode = .forwards
        pathMorph.isRemovedOnCompletion = true
        pathMorph.toValue = toPath
        pathMorph.fromValue = shapeLayer?.path
        pathMorph.timingFunction = function
        shapeLayer?.add(pathMorph, forKey: nil)

        let shadowPathMorph = CABasicAnimation(keyPath: "shadowPath")
        shadowPathMorph.duration = finishDuration
        shadowPathMorph.fillMode = .forwards
        shadowPathMorph.isRemovedOnCompletion = true
        shadowPathMorph.toValue = toPath
        shadowPathMorph.fromValue = shapeLayer?.shadowPath
        shadowPathMorph.timingFunction = function
        shapeLayer?.add(shadowPathMorph, forKey: nil)

        arrowLayer?.path = nil
        shapeLayer?.path = nil
        shapeLayer?.shadowPath = nil
    }

    // MARK: - Animation

    // [EN] Unused, kept from the original port. [CN] 未使用，保留自原始移植代码。
    private func resetAnimator() {
        animatorDropVertex = CYLRefreshValueAnimator.newWith(from: 0, to: 0)
        animatorDropBounceVertical = CYLRefreshValueAnimator.newWith(from: 0, to: 0)
        animatorDropBounceHorizontal = CYLRefreshValueAnimator.newWith(from: 0, to: 0)
        animatorDropCircle = CYLRefreshValueAnimator.newWith(from: -1000, to: -1000)
    }

    // [EN] h: the height the wave starts at. [CN] h：波浪开始的高度。
    private func startAnimationWaveReverse(_ start: CGFloat) {
        let width = self.width
        let h = min(start, Self.maxWaveHeight) * width

        let animator = CYLRefreshValueAnimator.newWith(from: h, to: 0)
        animator.duration = Self.waveAnimatorDuration
        animator.delegate = self
        animator.setTarget(self, selector: #selector(onAnimationWaveReverse(_:)))
        animator.interpolator = .bounce
        animator.start()
        animatorWaveReverse = animator

        arrowLayer?.path = nil
    }

    private func startAnimationDroping() {
        maxDropHeight = width

        var animator = CYLRefreshValueAnimator()
        animator.duration = CFTimeInterval(Float(0.5) + Float(0.5) * Float(1.25))
        animator.delegate = self
        animator.setTarget(self, selector: #selector(onAnimationDroping(_:)))
        animator.start()
        animatorDroping = animator

        animator = CYLRefreshValueAnimator()
        animator.setFrom(width * 500 / 1440, to: maxDropHeight)
        animator.duration = Self.dropCircleAnimatorDuration
        animator.setTarget(self, selector: #selector(onAnimationDroping(_:)))
        animator.interpolator = .accelerateDecelerate
        animator.start()
        animatorDropCircle = animator

        animator = CYLRefreshValueAnimator()
        animator.setFrom(origin.y, to: 0)
        animator.duration = Self.dropVertexAnimationDuration
        animator.interpolator = .decelerate
        animator.start()
        animatorDropVertex = animator

        animator = CYLRefreshValueAnimator()
        animator.setFrom(0, to: 1)
        animator.duration = Self.dropBounceAnimatorDuration
        animator.beginTime = Self.dropVertexAnimationDuration
        animator.interpolatorBlock = dropBounceBlock
        animator.start()
        animatorDropBounceVertical = animator

        animator = CYLRefreshValueAnimator()
        animator.setFrom(0, to: 1)
        animator.duration = Self.dropBounceAnimatorDuration
        animator.beginTime = CFTimeInterval(Float(0.5) + Float(0.5) * Float(0.25))
        animator.interpolatorBlock = dropBounceBlock
        animator.start()
        animatorDropBounceHorizontal = animator
    }

    @objc private func onAnimationWaveReverse(_ animator: CYLRefreshValueAnimator) {
        if scrollView?.isDragging == true && (status != .refreshing && status != .releasing) {
            // [EN] Dragging interrupts the animation. [CN] 拖拽可以打断动画。
            animator.stop()
            return
        }

        let width = self.width
        let h = animator.value

        let path = CGMutablePath()
        if h > 0.008 {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: width * f(0.333), y: h * 0.5), control: CGPoint(x: width * 0.25, y: 0))
            path.addQuadCurve(to: CGPoint(x: width * f(0.666), y: h * 0.5), control: CGPoint(x: width * 0.50, y: h * f(1.4)))
            path.addQuadCurve(to: CGPoint(x: width, y: 0), control: CGPoint(x: width * 0.75, y: 0))
        }
        setWavePath(path)
    }

    @objc private func onAnimationDroping(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorDropCircle {
            origin = CGPoint(x: origin.x, y: animator.value)
        } else if animator === animatorDroping {
            let circleCenterY = origin.y
            let circleCenterX = origin.x

            // [EN] Messaging a nil animator gave 0 in Objective-C. [CN] Objective-C 中向 nil 动画器发消息得到 0。
            let vertical = animatorDropBounceVertical?.value ?? 0
            let horizontal = animatorDropBounceHorizontal?.value ?? 0
            let vertex = animatorDropVertex?.value ?? 0
            let dropCircleRadius = self.dropCircleRadius * 3

            let pathDropTangent = CGMutablePath()

            if vertex > 0 {
                let arcos = acos(dropCircleRadius / (dropCircleRadius + vertex))
                let start = .pi + (.pi / 2 - arcos)
                let close = arcos - .pi / 2
                pathDropTangent.move(to: CGPoint(x: circleCenterX, y: circleCenterY - dropCircleRadius - vertex))
                pathDropTangent.addArc(center: CGPoint(x: circleCenterX, y: circleCenterY), radius: dropCircleRadius,
                                       startAngle: start, endAngle: close, clockwise: true)
            } else {
                var dropRect = CGRect.zero
                dropRect.size.width = 2 * dropCircleRadius * (1 + vertical)
                dropRect.size.height = 2 * dropCircleRadius * (1 + horizontal)
                dropRect.origin.x = circleCenterX - dropRect.size.width / 2
                dropRect.origin.y = circleCenterY - dropRect.size.height / 2
                pathDropTangent.addEllipse(in: dropRect)
            }

            shapeLayer?.path = pathDropTangent
            shapeLayer?.shadowPath = pathDropTangent
        }
    }

    /**
     * [EN] An animator ended: forgets it; after the finishing shrink, the refreshing spin starts while still refreshing.
     * [CN] 动画器结束：释放它；结束收缩后，若仍在刷新则开始刷新旋转。
     */
    public func onAnimationEnd(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorRefreshing {
            animatorRefreshing = nil
        } else if animator === animatorWaveReverse {
            animatorWaveReverse = nil
        } else if animator === animatorDropCircle {
            animatorDropCircle = nil
        } else if animator === animatorDroping {
            animatorDroping = nil
        } else if animator === animatorFinishing {
            animatorFinishing = nil
            if isRefreshing {
                storeOriginals()
                aniStartTrim = aniEndTrim
                startAnimatorRefreshing()
            }
        }
    }

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
     * [EN] A round of the refreshing spin ended: next rotation.
     * [CN] 刷新旋转完成一轮：下一圈旋转。
     */
    public func onAnimationRepeat(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorRefreshing {
            storeOriginals()
            aniStartTrim = aniEndTrim
            aniRotationCount = (aniRotationCount + 1) % Self.numPoints
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
        (Self.maxArrowSize / (2 * .pi * Self.maxArrowRadius)) * .pi / 180
    }

    // [EN] The fast-out-slow-in interpolator. [CN] 加速器（快出慢入）。
    private func getFastOutSlowValue(_ input: CGFloat) -> CGFloat {
        if input >= 1.0 {
            return 1.0
        }
        // FIX: issue MJRefresh#1615
        // [EN] NaN (a pull over a header of height 0) is neither >= 1 nor <= 0, and Int(NaN) traps; it counts as 0.
        // [CN] NaN（拉动高度为 0 的刷新头）既不 >= 1 也不 <= 0，而 Int(NaN) 会崩溃；按 0 处理。
        if !(input > 0.0) {
            return 0.0
        }
        let values = fastOutSlowValues
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

    /**
     * [EN] Draws nothing; kept as in Objective-C (the layers draw the wave).
     * [CN] 不绘制任何内容；与 Objective-C 相同保留（波浪由图层绘制）。
     */
    open override func draw(_ rect: CGRect) {
        // Drawing code
    }
}
