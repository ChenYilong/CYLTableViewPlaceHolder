//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshOriginalHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API (`enableAutoRefresh`) and the
//      same drawing, colors and timing.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API（`enableAutoRefresh`）以及绘制、颜色与
//      时序均不变。

import UIKit

/**
 * [EN] The original iOS 6 pull-to-refresh: a drop that stretches while pulling, snaps and turns into a spinner.
 * [CN] iOS 6 原始的下拉刷新：下拉时被拉长的水滴，断开后变为菊花。
 */
@objc(CYLRefreshOriginalHeader)
open class CYLRefreshOriginalHeader: CYLRefreshDrawnHeader {

    private static let minTopPadding: CGFloat = 9
    private static let maxTopPadding: CGFloat = 5
    private static let minTopRadius: CGFloat = 12.5
    private static let maxTopRadius: CGFloat = 16
    private static let minBottomRadius: CGFloat = 3
    private static let maxBottomRadius: CGFloat = 16
    private static let minBottomPadding: CGFloat = 4
    private static let maxBottomPadding: CGFloat = 6
    private static let minArrowSize: CGFloat = 2
    private static let maxArrowSize: CGFloat = 3
    private static let minArrowRadius: CGFloat = 5
    private static let maxArrowRadius: CGFloat = 7
    private static let maxDistance: CGFloat = 53

    private static func lerp(_ a: CGFloat, _ b: CGFloat, _ p: CGFloat) -> CGFloat {
        a + (b - a) * p
    }

    private var shapeLayer: CAShapeLayer?
    private var arrowLayer: CAShapeLayer?
    private var highlightLayer: CAShapeLayer?

    private var activity: UIActivityIndicatorView?

    private var originTop: CGPoint = .zero
    private var originBottom: CGPoint = .zero
    private var lastOffset: CGFloat = 0

    /**
     * [EN] YES (default): the drop snaps and refreshing starts as soon as it is fully stretched, without waiting for the
     *      release. NO: the stretch slows down instead and refreshing starts on release.
     * [CN] YES（默认）：水滴被完全拉长时立即断开并开始刷新，不等待松手。NO：改为越拉越慢，松手时开始刷新。
     */
    @objc open var enableAutoRefresh = true

    /**
     * [EN] Builds the drop, arrow and highlight layers and the spinner, and sets the Original colors.
     * [CN] 初始化参数：创建水滴、箭头、高光图层与菊花，并设置 Original 的颜色。
     */
    open override func setUpComponent() {
        super.setUpComponent()

        isOpaque = false
        height = Self.maxTopRadius * 4

        enableAutoRefresh = true
        scrollMode = .stretch
        colorAccent = .white
        colorPrimary = UIColor(red: 155.0 / 255.0, green: 162.0 / 255.0, blue: 172.0 / 255.0, alpha: 1.0)

        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = colorPrimary?.cgColor
        shapeLayer.strokeColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
        shapeLayer.lineWidth = 0.5
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOffset = CGSize(width: 0, height: 1)
        shapeLayer.shadowOpacity = 0.4
        shapeLayer.shadowRadius = 0.5
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
        shapeLayer.addSublayer(highlightLayer)
        self.highlightLayer = highlightLayer

        // [EN] Style 2 (`UIActivityIndicatorViewStyleGray`), as the Objective-C code passed it.
        // [CN] 样式 2（`UIActivityIndicatorViewStyleGray`），与 Objective-C 代码传入的值相同。
        let activity = UIActivityIndicatorView(style: UIActivityIndicatorView.Style(rawValue: 2) ?? .medium)
        activity.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        activity.tintColor = colorPrimary

        addSubview(activity)
        self.activity = activity
    }

    /**
     * [EN] Fills the arrow with the accent color. [CN] 用强调色填充箭头。
     */
    open override var colorAccent: UIColor? {
        get { super.colorAccent }
        set {
            super.colorAccent = newValue
            arrowLayer?.fillColor = newValue?.cgColor
        }
    }

    /**
     * [EN] Tints the spinner and fills the drop with the primary color. [CN] 用主色为菊花着色并填充水滴。
     */
    open override var colorPrimary: UIColor? {
        get { super.colorPrimary }
        set {
            super.colorPrimary = newValue
            activity?.tintColor = newValue
            shapeLayer?.fillColor = newValue?.cgColor
        }
    }

    private func buildArrowShape(_ currentTopRadius: CGFloat, percentage: CGFloat, topOrigin: CGPoint) {
        // Add the arrow shape
        let currentArrowSize = Self.lerp(Self.minArrowSize, Self.maxArrowSize, percentage)
        let currentArrowRadius = Self.lerp(Self.minArrowRadius, Self.maxArrowRadius, percentage)
        let arrowBigRadius = currentArrowRadius + (currentArrowSize / 2)
        let arrowSmallRadius = currentArrowRadius - (currentArrowSize / 2)
        let arrowPath = CGMutablePath()
        arrowPath.addArc(center: topOrigin, radius: arrowBigRadius, startAngle: 0, endAngle: 3 * (.pi / 2), clockwise: false)
        arrowPath.addLine(to: CGPoint(x: topOrigin.x, y: topOrigin.y - arrowBigRadius - currentArrowSize))
        arrowPath.addLine(to: CGPoint(x: topOrigin.x + (2 * currentArrowSize), y: topOrigin.y - arrowBigRadius + (currentArrowSize / 2)))
        arrowPath.addLine(to: CGPoint(x: topOrigin.x, y: topOrigin.y - arrowBigRadius + (2 * currentArrowSize)))
        arrowPath.addLine(to: CGPoint(x: topOrigin.x, y: topOrigin.y - arrowBigRadius + currentArrowSize))
        arrowPath.addArc(center: topOrigin, radius: arrowSmallRadius, startAngle: 3 * (.pi / 2), endAngle: 0, clockwise: true)
        arrowPath.closeSubpath()
        arrowLayer?.path = arrowPath
        arrowLayer?.fillRule = .evenOdd

        // Add the highlight shape
        let highlightPath = CGMutablePath()
        highlightPath.addArc(center: topOrigin, radius: currentTopRadius, startAngle: 0, endAngle: .pi, clockwise: true)
        highlightPath.addArc(center: CGPoint(x: topOrigin.x, y: topOrigin.y + 1.25), radius: currentTopRadius,
                             startAngle: .pi, endAngle: 0, clockwise: false)

        highlightLayer?.path = highlightPath
        highlightLayer?.fillRule = .nonZero
    }

    private func buildSemiCircle(_ bottomOrigin: CGPoint, currentBottomRadius: CGFloat, currentTopRadius: CGFloat, topOrigin: CGPoint) {
        let path = CGMutablePath()

        // Top semicircle
        path.addArc(center: topOrigin, radius: currentTopRadius, startAngle: 0, endAngle: .pi, clockwise: true)

        // Left curve
        let leftCp1 = CGPoint(x: Self.lerp(topOrigin.x - currentTopRadius, bottomOrigin.x - currentBottomRadius, 0.1),
                              y: Self.lerp(topOrigin.y, bottomOrigin.y, 0.2))
        let leftCp2 = CGPoint(x: Self.lerp(topOrigin.x - currentTopRadius, bottomOrigin.x - currentBottomRadius, 0.9),
                              y: Self.lerp(topOrigin.y, bottomOrigin.y, 0.2))
        let leftDestination = CGPoint(x: bottomOrigin.x - currentBottomRadius, y: bottomOrigin.y)

        path.addCurve(to: leftDestination, control1: leftCp1, control2: leftCp2)

        // Bottom semicircle
        path.addArc(center: bottomOrigin, radius: currentBottomRadius, startAngle: .pi, endAngle: 0, clockwise: true)

        // Right curve
        let rightCp2 = CGPoint(x: Self.lerp(topOrigin.x + currentTopRadius, bottomOrigin.x + currentBottomRadius, 0.1),
                               y: Self.lerp(topOrigin.y, bottomOrigin.y, 0.2))
        let rightCp1 = CGPoint(x: Self.lerp(topOrigin.x + currentTopRadius, bottomOrigin.x + currentBottomRadius, 0.9),
                               y: Self.lerp(topOrigin.y, bottomOrigin.y, 0.2))
        let rightDestination = CGPoint(x: topOrigin.x + currentTopRadius, y: topOrigin.y)

        path.addCurve(to: rightDestination, control1: rightCp1, control2: rightCp2)
        path.closeSubpath()

        shapeLayer?.path = path
        shapeLayer?.shadowPath = path
    }

    // MARK: - Override

    /**
     * [EN] Centers the spinner in the open area. [CN] 把菊花放在展开区域的中心。
     */
    open override func scrollView(_ scrollView: UIScrollView, attached attach: Bool) {
        super.scrollView(scrollView, attached: attach)
        activity?.center = CGPoint(x: width / 2, y: expandHeight / 2)
    }

    /**
     * [EN] Stretches the drop with the pull; with `enableAutoRefresh` a fully stretched drop starts refreshing.
     * [CN] 随下拉拉长水滴；开启 `enableAutoRefresh` 时，水滴完全拉长即开始刷新。
     */
    open override func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        if status == .refreshing || status == .releasing || status == .finishing {
            lastOffset = offset
            return
        }

        let verticalShift = max(0, offset - (Self.maxTopRadius + Self.maxBottomRadius + Self.maxTopPadding + Self.maxBottomPadding))
        var distance = min(Self.maxDistance, abs(verticalShift))
        var percentage = 1 - (distance / Self.maxDistance)

        if !enableAutoRefresh {
            // 公式 y = M(1-200^(-x/H))
            // 能够达到的最大值
            let m = Self.maxDistance * 1.5
            // 接近最大值的点
            let h = Self.maxDistance * 8
            let x = abs(verticalShift)
            let y = m * (1 - pow(100, -x / h))
            distance = y
            percentage = 1 - (distance / m)
        }

        let currentTopPadding = Self.lerp(Self.minTopPadding, Self.maxTopPadding, percentage)
        let currentTopRadius = Self.lerp(Self.minTopRadius, Self.maxTopRadius, percentage)
        let currentBottomRadius = Self.lerp(Self.minBottomRadius, Self.maxBottomRadius, percentage)
        let currentBottomPadding = Self.lerp(Self.minBottomPadding, Self.maxBottomPadding, percentage)

        let width = self.width, height = self.height

        var bottomOrigin = CGPoint(x: floor(width / 2), y: height - currentBottomPadding - currentBottomRadius)
        var topOrigin = CGPoint.zero
        if distance == 0 {
            topOrigin = CGPoint(x: floor(width / 2), y: bottomOrigin.y)
        } else {
            topOrigin = CGPoint(x: floor(width / 2), y: height - offset + currentTopPadding + currentTopRadius)
            bottomOrigin = CGPoint(x: floor(width / 2), y: topOrigin.y + distance)

            if enableAutoRefresh {
                if percentage == 0 && offset > lastOffset {
                    lastOffset = offset
                    beginRefresh()
                    return
                }
            }
        }

        originTop = topOrigin
        originBottom = bottomOrigin

        buildSemiCircle(bottomOrigin, currentBottomRadius: currentBottomRadius, currentTopRadius: currentTopRadius, topOrigin: topOrigin)

        buildArrowShape(currentTopRadius, percentage: percentage, topOrigin: topOrigin)

        lastOffset = offset
    }

    /**
     * [EN] The drop snaps and fades; the spinner starts 0.15 s later.
     * [CN] 水滴断开并淡出；0.15 秒后菊花开始转动。
     */
    open override func onStartAnimationWhenRealeasing() {
        // Start the shape disappearance animation
        let topOrigin = originTop

        let function = CAMediaTimingFunction(name: .easeOut)

        let radius = Self.lerp(Self.minBottomRadius, Self.maxBottomRadius, 0.2)
        let pathMorph = CABasicAnimation(keyPath: "path")
        pathMorph.duration = 0.15
        pathMorph.fillMode = .forwards
        pathMorph.isRemovedOnCompletion = false
        pathMorph.timingFunction = function
        let toPath = CGMutablePath()
        toPath.addArc(center: topOrigin, radius: radius, startAngle: 0, endAngle: .pi, clockwise: true)
        toPath.addCurve(to: CGPoint(x: topOrigin.x - radius, y: topOrigin.y),
                        control1: CGPoint(x: topOrigin.x - radius, y: topOrigin.y),
                        control2: CGPoint(x: topOrigin.x - radius, y: topOrigin.y))
        toPath.addArc(center: topOrigin, radius: radius, startAngle: .pi, endAngle: 0, clockwise: true)
        toPath.addCurve(to: CGPoint(x: topOrigin.x + radius, y: topOrigin.y),
                        control1: CGPoint(x: topOrigin.x + radius, y: topOrigin.y),
                        control2: CGPoint(x: topOrigin.x + radius, y: topOrigin.y + 0.1))
        toPath.closeSubpath()
        pathMorph.toValue = toPath
        shapeLayer?.add(pathMorph, forKey: nil)
        let shadowPathMorph = CABasicAnimation(keyPath: "shadowPath")
        shadowPathMorph.duration = 0.15
        shadowPathMorph.fillMode = .forwards
        shadowPathMorph.isRemovedOnCompletion = false
        shadowPathMorph.toValue = toPath
        shadowPathMorph.timingFunction = function
        shapeLayer?.add(shadowPathMorph, forKey: nil)
        let shapeAlphaAnimation = CABasicAnimation(keyPath: "opacity")
        shapeAlphaAnimation.duration = 0.1
        shapeAlphaAnimation.beginTime = CACurrentMediaTime() + 0.1
        shapeAlphaAnimation.toValue = NSNumber(value: Float(0))
        shapeAlphaAnimation.fillMode = .forwards
        shapeAlphaAnimation.isRemovedOnCompletion = false
        shapeAlphaAnimation.timingFunction = function
        shapeLayer?.add(shapeAlphaAnimation, forKey: nil)
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.duration = 0.1
        alphaAnimation.toValue = NSNumber(value: Float(0))
        alphaAnimation.fillMode = .forwards
        alphaAnimation.isRemovedOnCompletion = false
        alphaAnimation.timingFunction = function
        arrowLayer?.add(alphaAnimation, forKey: nil)
        highlightLayer?.add(alphaAnimation, forKey: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.activity?.startAnimating()
        }
    }

    /**
     * [EN] Stops the spinner and clears the drop. [CN] 停止菊花并清除水滴。
     */
    open override func onRefreshFinished(_ success: Bool) {
        activity?.stopAnimating()

        shapeLayer?.removeAllAnimations()
        shapeLayer?.path = nil
        shapeLayer?.shadowPath = nil
        arrowLayer?.removeAllAnimations()
        arrowLayer?.path = nil
        highlightLayer?.removeAllAnimations()
        highlightLayer?.path = nil
    }

    /**
     * [EN] Draws nothing: the drop is made of layers (kept, as the Objective-C class implemented `drawRect:`).
     * [CN] 不绘制任何内容：水滴由图层组成（保留该方法，与实现了 `drawRect:` 的 Objective-C 类相同）。
     */
    open override func draw(_ rect: CGRect) {
    }
}
