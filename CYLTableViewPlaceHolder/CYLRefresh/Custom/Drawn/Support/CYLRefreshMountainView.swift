//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Fly/MountainView.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API (`colorAccent`,
//      `colorPrimary`, `-onScrollingWithOffset:percent:`); the macros of `CYLRefreshMountainView.h`
//      (`CYLREFRESH_SCREEN_WIDTH`, `CYLREFRESH_RATIO_X`, `CYLREFRESH_RATIO_Y`) stay there. Public only so the module's
//      Objective-C files can read it (an internal helper of the drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变（`colorAccent`、`colorPrimary`、
//      `-onScrollingWithOffset:percent:`）；`CYLRefreshMountainView.h` 中的宏（`CYLREFRESH_SCREEN_WIDTH`、`CYLREFRESH_RATIO_X`、
//      `CYLREFRESH_RATIO_Y`）保留在原处。设为 public 只是为了让模块内的 Objective-C 文件读取（绘制样式的内部辅助类，不是 API）。

import UIKit

/**
 * [EN] The landscape of the Fly header: three mountain ranges and trees that bend while the list is pulled, in shades
 *      mixed from `colorPrimary`.
 * [CN] Fly 刷新头中的风景：三层山脉与随下拉弯曲的树，颜色由 `colorPrimary` 混合而成。
 */
@objc(CYLRefreshMountainView)
open class CYLRefreshMountainView: UIView {

    private static let treeWidth: CGFloat = 30
    private static let treeHeight: CGFloat = 60

    private var colorMount1: UIColor?
    private var colorMount2: UIColor?
    private var colorMount3: UIColor?
    private var colorTree1Brink: UIColor?
    private var colorTree1Branch: UIColor?
    private var colorTree2Brink: UIColor?
    private var colorTree2Branch: UIColor?
    private var colorTree3Brink: UIColor?
    private var colorTree3Branch: UIColor?
    private var offset: CGFloat = 0
    private var treePathBrink: UIBezierPath?
    private var treePathBranch: UIBezierPath?

    /**
     * [EN] Kept from the original API; not used.
     * [CN] 沿用原 API；未使用。
     */
    @objc public var colorAccent: UIColor!

    private var storedColorPrimary: UIColor?

    /**
     * [EN] The base color: the background, and the mountains and trees mixed from it; nil until it is set.
     * [CN] 基础颜色：作为背景，山脉与树的颜色由它混合而成；设置之前为 nil。
     */
    @objc public var colorPrimary: UIColor! {
        get { storedColorPrimary }
        set {
            storedColorPrimary = newValue
            backgroundColor = newValue
            colorMount1 = mix(newValue, Self.argb(0x99ffffff))
            colorMount2 = mix(newValue, Self.argb(0x993C929C))
            colorMount3 = mix(newValue, Self.argb(0xCC3E5F73))
            colorTree1Branch = mix(newValue, Self.argb(0x551F7177))
            colorTree1Brink = mix(newValue, Self.argb(0xCC0C3E48))
            colorTree2Branch = mix(newValue, Self.argb(0x5534888F))
            colorTree2Brink = mix(newValue, Self.argb(0xCC1B6169))
            colorTree3Branch = mix(newValue, Self.argb(0x5557B1AE))
            colorTree3Brink = mix(newValue, Self.argb(0xCC62A4AD))
        }
    }

    /**
     * [EN] Redraws for the new frame.
     * [CN] 按新的 frame 重绘。
     */
    open override var frame: CGRect {
        get { super.frame }
        set {
            super.frame = newValue
            setNeedsDisplay()
        }
    }

    // [EN] The original's ARGB macro. [CN] 原实现的 ARGB 宏。
    private static func argb(_ argb: UInt32) -> UIColor {
        UIColor(red: CGFloat(Float((argb & 0xFF0000) >> 16)) / 255.0,
                green: CGFloat(Float((argb & 0x00FF00) >> 8)) / 255.0,
                blue: CGFloat(Float(argb & 0x0000FF)) / 255.0,
                alpha: CGFloat(Float((argb & 0xFF000000) >> 24)) / 255.0)
    }

    // [EN] The red, green, blue and alpha components the original read with `CGColorGetComponents`. A grayscale color has
    //      two components (white, alpha), past which the original read beyond the array; it is read as gray here.
    // [CN] 原实现用 `CGColorGetComponents` 读取的红、绿、蓝与透明度分量。灰度颜色只有两个分量（白、透明度），原实现会越界读取；这里按灰色读取。
    private static func components(of color: UIColor) -> [CGFloat] {
        let components = color.cgColor.components ?? []
        if components.count >= 4 { return components }
        if components.count == 2 { return [components[0], components[0], components[0], components[1]] }
        return components + Array(repeating: 0, count: 4 - components.count)
    }

    private func mix(_ color1: UIColor, _ color2: UIColor) -> UIColor {
        let components1 = Self.components(of: color1)
        let components2 = Self.components(of: color2)
        let ratio = components2[3]
        let r = components1[0] * (1 - ratio) + components2[0] * ratio
        let g = components1[1] * (1 - ratio) + components2[1] * ratio
        let b = components1[2] * (1 - ratio) + components2[2] * ratio
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    /**
     * [EN] Draws the mountains and trees.
     * [CN] 绘制山脉与树。
     */
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawMountain(context, width: rect.size.width, height: rect.size.height)
    }

    private func drawMountain(_ context: CGContext, width: CGFloat, height: CGFloat) {
        var y: CGFloat = 0
        colorMount1?.setFill()
        y = height - width * 4 / 29 - offset * 0.6
        context.move(to: CGPoint(x: 0, y: y))
        y -= width * 4 / 29
        context.addLine(to: CGPoint(x: width * 6 / 29, y: y))
        y += width * 4.5 / 29
        context.addLine(to: CGPoint(x: width * 17 / 29, y: y))
        y -= width * 5.5 / 29
        context.addLine(to: CGPoint(x: width * 27 / 29, y: y))
        y += width * 2 / 29
        context.addLine(to: CGPoint(x: width, y: y))
        context.addLine(to: CGPoint(x: width, y: height))
        context.addLine(to: CGPoint(x: 0, y: height))
        context.closePath()
        context.fillPath()

        context.saveGState()
        context.translateBy(x: width * 6.5 / 29, y: height - width * 5 / 29 - offset * 0.4)
        context.scaleBy(x: -0.7, y: -0.7)
        drawTree(context)
        context.restoreGState()

        context.saveGState()
        context.translateBy(x: width * 4.5 / 29, y: height - width * 4.5 / 29 - offset * 0.4)
        context.scaleBy(x: -0.5, y: -0.5)
        drawTree(context)
        context.restoreGState()

        colorMount2?.setFill()
        y = height - width * 3 / 29 - offset * 0.4
        context.move(to: CGPoint(x: 0, y: y))
        y -= width * 3 / 29
        context.addLine(to: CGPoint(x: width * 7 / 29, y: y))
        y += width * 4.5 / 29
        context.addLine(to: CGPoint(x: width * 18 / 29, y: y))
        y -= width * 4.5 / 29
        context.addLine(to: CGPoint(x: width * 26 / 29, y: y))
        y += width * 2 / 29
        context.addLine(to: CGPoint(x: width, y: y))
        context.addLine(to: CGPoint(x: width, y: height))
        context.addLine(to: CGPoint(x: 0, y: height))
        context.closePath()
        context.fillPath()

        context.saveGState()
        context.translateBy(x: width * 16 / 29, y: height - width * 3 / 29 - offset * 0.2)
        context.scaleBy(x: 0.85, y: -0.85)
        drawTree(context)
        context.restoreGState()

        context.saveGState()
        context.translateBy(x: width * 19 / 29, y: height - width * 3 / 29 - offset * 0.2)
        context.scaleBy(x: 1, y: -1)
        drawTree(context)
        context.restoreGState()

        context.saveGState()
        context.translateBy(x: width * 22 / 29, y: height - width * 3 / 29 - offset * 0.2)
        context.scaleBy(x: 0.7, y: -0.7)
        drawTree(context)
        context.restoreGState()

        colorMount3?.setFill()
        y = height - width * 2 / 29 - offset * 0.2
        context.move(to: CGPoint(x: 0, y: y))
        context.addCurve(to: CGPoint(x: width, y: y - width * 1 / 29),
                         control1: CGPoint(x: width * 3.5 / 29, y: y - width * 1 / 29),
                         control2: CGPoint(x: width * 21 / 29, y: y - width * 3 / 29))
        context.addLine(to: CGPoint(x: width, y: height))
        context.addLine(to: CGPoint(x: 0, y: height))
        context.closePath()
        context.fillPath()
    }

    private func drawTree(_ context: CGContext) {
        context.setLineWidth(6)

        // [EN] TREE_HEIGHT / 2 was integer division of 60. [CN] TREE_HEIGHT / 2 原为 60 的整数除法。
        context.translateBy(x: 0, y: 30)
        colorTree1Branch?.setFill()
        treePathBranch?.fill()
        colorTree1Brink?.setStroke()
        treePathBranch?.stroke()

        context.translateBy(x: 0, y: -30)
        colorTree1Brink?.setFill()
        treePathBrink?.fill()
    }

    /**
     * [EN] Follows the pull: `offset` lifts the mountains, `percent` bends the trees.
     * [CN] 跟随下拉：`offset` 抬升山脉，`percent` 使树弯曲。
     */
    @objc(onScrollingWithOffset:percent:)
    public func onScrolling(withOffset offset: CGFloat, percent: CGFloat) {
        self.offset = offset
        updateTreePath(percent)
    }

    private func updateTreePath(_ percent: CGFloat) {
        let treeWidth = Self.treeWidth
        let treeHeight = Self.treeHeight
        let brinkSize = treeWidth * 0.05
        let branchSize = treeWidth * 0.2
        let pathBrink = UIBezierPath()
        let pathBranch = UIBezierPath()

        let offset = percent * treeWidth * 0.3
        var array = [CGPoint]()

        let topBranch = treeHeight * 0.6
        pathBranch.move(to: CGPoint(x: offset, y: topBranch))
        var y = topBranch
        while y > 0 {
            let p = y / topBranch
            let xx = 1 - pow(1 - p, 0.5)
            let x = xx * offset
            let xs = branchSize * (1 - p * p)
            pathBranch.addLine(to: CGPoint(x: x - xs, y: y))
            array.append(CGPoint(x: x + xs, y: y))
            y -= 0.1
        }
        pathBranch.addLine(to: CGPoint(x: -branchSize, y: 0))
        pathBranch.addCurve(to: CGPoint(x: branchSize, y: 0),
                            controlPoint1: CGPoint(x: -branchSize, y: -branchSize * 1.5),
                            controlPoint2: CGPoint(x: branchSize, y: -branchSize * 1.5))
        for point in array.reversed() {
            pathBranch.addLine(to: point)
        }
        array.removeAll()

        pathBranch.apply(CGAffineTransform(translationX: offset * 0.3, y: 0))

        let topBrink = treeHeight * 0.7
        pathBrink.move(to: CGPoint(x: offset, y: topBrink))
        y = topBrink
        while y > 0 {
            let p = (y / topBrink) * 0.7
            let xx = 1 - pow(1 - p, 0.5)
            let x = xx * offset
            var xs = brinkSize
            if p > 0.7 / 2 {
                xs = brinkSize * (0.7 - p) / 0.35
            }
            pathBrink.addLine(to: CGPoint(x: x - xs, y: y))
            array.append(CGPoint(x: x + xs, y: y))
            y -= 0.1
        }
        pathBrink.addLine(to: CGPoint(x: -brinkSize, y: 0))
        pathBrink.addLine(to: CGPoint(x: brinkSize, y: 0))
        for point in array.reversed() {
            pathBrink.addLine(to: point)
        }

        treePathBrink = pathBrink
        treePathBranch = pathBranch
    }
}
