//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshDropBoxHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API and the same drawing,
//      colors and timing (the box measures in integers as the Objective-C `BoxBody` did).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API 以及绘制、颜色与时序均不变（盒子与
//      Objective-C 的 `BoxBody` 一样按整数测量）。

import UIKit

// [EN] The box's corners, measured in integers (the Objective-C `BoxBody`'s NSInteger properties).
// [CN] 盒子的各个角点，按整数测量（即 Objective-C `BoxBody` 的 NSInteger 属性）。
private struct BoxBody {
    var boxCenterX = 0
    var boxCenterY = 0
    var boxBottom = 0
    var boxTop = 0
    var boxLeft = 0
    var boxCenterTop = 0
    var boxCenterBottom = 0
    var boxRight = 0
    var boxSideLength = 0

    mutating func measure(_ margin: Int, w width: Int, h height: Int, s sideLength: Int) -> BoxBody {
        boxSideLength = sideLength
        boxCenterX = width / 2
        boxBottom = height - margin
        boxTop = boxBottom - 2 * sideLength
        boxLeft = boxCenterX - Int(Double(sideLength) * sin(3.1415926 / 3))
        boxCenterTop = boxTop + sideLength / 2
        boxCenterBottom = boxBottom - sideLength / 2
        boxRight = width - boxLeft
        boxCenterY = boxBottom - sideLength
        return self
    }
}

private let pathImageMovie = ["M3 2h18v20h-18z", "m4 1c-1 0 -2 1 -2 2v18c0 1 1 2 2 2h16c1 0 2 -1 2 -2v-18c0 -1 -1 -2 -2 -2h-16zM3.5 3h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 3h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 6h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 6h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 9h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 9h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 12h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 12h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 15h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 15h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 18h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 18h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5z"]

private let pathImageFile = ["M49,16.5l-14,-14l-27,0l0,53l41,0z", "m16,23.5h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1L16,21.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1z", "m16,15.5h10c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1L16,13.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1z", "M41,29.5L16,29.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1z", "M41,37.5L16,37.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1z", "M41,45.5L16,45.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1z", "M49,16.5l-14,-14l0,14z"]

private let pathImageMusic = ["M6,2.1L6,11.3C5.4,11.3 4.8,11.4 4.2,11.6C2.6,12.3 1.6,13.7 2.1,14.8C2.6,15.9 4.2,16.2 5.8,15.6C7.1,15.1 7.8,14.1 7.9,13.2L7.9,4.3L15,3L15,9.4C14.4,9.3 13.7,9.4 13,9.7C11.4,10.3 10.5,11.7 11,12.8C11.4,13.9 13.1,14.3 14.7,13.6C15.9,13.1 16.8,12.2 16.9,11.3L16.9,0L6,2.1L6,2.1Z"]

/**
 * [EN] A box whose lid opens and drops files while refreshing.
 * [CN] 盒子打开盖子，刷新时掉出文件。
 */
@objc(CYLRefreshDropBoxHeader)
open class CYLRefreshDropBoxHeader: CYLRefreshDrawnHeader, CYLRefreshValueAnimatorDelegate {

    private var animatorRebound: CYLRefreshValueAnimator?
    private var animatorDropOut: CYLRefreshValueAnimator?
    private var imageMovie: CYLRefreshVectorImage?
    private var imageFile: CYLRefreshVectorImage?
    private var imageMusic: CYLRefreshVectorImage?

    private var boxBody = BoxBody()
    private var isDropOutOverFlow = false
    private var percentRebound: CGFloat = 0
    private var percentDropOut: CGFloat = 0
    private var sideLength: CGFloat = 0
    private var imageSize: CGFloat = 0

    private var finished = false

    private static func rgb(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
        UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
    }

    /**
     * [EN] Builds the three file images and the two animators, and sets the DropBox colors.
     * [CN] 初始化参数：创建三张文件图片与两个动画器，并设置 DropBox 的颜色。
     */
    open override func setUpComponent() {
        super.setUpComponent()

        height = 100

        let imageMovie = CYLRefreshVectorImage()
        imageMovie.size = CGSize(width: imageSize, height: imageSize)
        imageMovie.parserPaths(pathImageMovie)
        imageMovie.parserColors([Self.rgb(0xec, 0xf0, 0xf1), Self.rgb(0xfc, 0x41, 0x08)])

        let imageFile = CYLRefreshVectorImage()
        imageFile.size = CGSize(width: imageSize, height: imageSize)
        imageFile.parserPaths(pathImageFile)
        imageFile.parserColors([Self.rgb(0xfe, 0xd4, 0x69), Self.rgb(0xd5, 0xae, 0x57)])

        let imageMusic = CYLRefreshVectorImage()
        imageMusic.size = CGSize(width: imageSize, height: imageSize)
        imageMusic.parserPaths(pathImageMusic)
        imageMusic.parserColors([Self.rgb(0x98, 0xd7, 0x61)])

        let animatorRebound = CYLRefreshValueAnimator.newWith(target: self, selector: #selector(onAnimation(_:)))
        animatorRebound.interpolator = .accelerate
        animatorRebound.duration = durationNormal
        animatorRebound.delegate = self

        let animatorDropOut = CYLRefreshValueAnimator.newWith(target: self, selector: #selector(onAnimation(_:)))
        animatorDropOut.interpolator = .accelerate
        animatorDropOut.duration = durationNormal
        animatorDropOut.delegate = self

        self.imageMovie = imageMovie
        self.imageFile = imageFile
        self.imageMusic = imageMusic
        self.animatorRebound = animatorRebound
        self.animatorDropOut = animatorDropOut
        boxBody = BoxBody()
        colorAccent = Self.rgb(0x6e, 0xa9, 0xff)
        colorPrimary = Self.rgb(0x28, 0x36, 0x45)
        scrollMode = .stretch
    }

    /**
     * [EN] The open height; the images and the box side are a fifth of it.
     * [CN] 展开高度；图片与盒子边长为它的五分之一。
     */
    open override var height: CGFloat {
        get { super.height }
        set {
            super.height = newValue
            imageSize = newValue / 5
            sideLength = newValue / 5
        }
    }

    /**
     * [EN] Marks the refresh finished, then ends it. [CN] 标记刷新已结束，然后结束刷新。
     */
    open override func finishRefresh(withSuccess success: Bool) {
        finished = true
        super.finishRefresh(withSuccess: success)
    }

    @objc(onAnimation:)
    private func onAnimation(_ animator: CYLRefreshValueAnimator) {
        if finished {
            NSLog("onAnimation:finished = TRUE")
        }
        if status != .refreshing {
            // 不是刷新状态时，停止定时器
            animator.stop()
            return
        }
        if finished {
            NSLog("onAnimation:finished = TRUE!  RUN!!!")
        }
        if animator === animatorRebound {
            percentRebound = 1 - 2 * abs(animator.value - 0.5)
            setNeedsDisplay()
        } else if animator === animatorDropOut {
            if percentDropOut < 1 || percentDropOut >= 3 {
                percentDropOut = animator.value
            } else if percentDropOut < 2 {
                percentDropOut = 1 + animator.value
            } else if percentDropOut < 3 {
                percentDropOut = 2 + animator.value
                if percentDropOut == 3 {
                    isDropOutOverFlow = true
                }
            }
            setNeedsDisplay()
        }
    }

    /**
     * [EN] Chains the rebound and drop-out animations while refreshing.
     * [CN] 刷新时让回弹动画与掉落动画交替进行。
     */
    open func onAnimationEnd(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorRebound {
            if status == .refreshing {
                animatorDropOut?.start()
            } else {
                percentDropOut = 0
            }
        } else if animator === animatorDropOut {
            animatorRebound?.start()
        }
    }

    // MARK: - Override

    /**
     * [EN] Opens the lid with the pull. [CN] 随下拉打开盖子。
     */
    open override func scrollView(_ scrollView: UIScrollView, didScroll offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        super.scrollView(scrollView, didScroll: offset, percent: percent, drag: isDragging)
        if !isDragging || status != .refreshing {
            percentRebound = min(1, max(0, (percent - 1) / 2))
        }
        setNeedsDisplay()
    }

    /**
     * [EN] Starts dropping files while refreshing and stops when finishing.
     * [CN] 刷新时开始掉落文件，结束时停止。
     */
    open override func onStatus(_ oldStatus: CYLRefreshPhase, changed status: CYLRefreshPhase) {
        if status == .idle {
            isDropOutOverFlow = false
        } else if status == .refreshing {
            finished = false
            animatorDropOut?.start()
        } else if status == .finishing {
            animatorDropOut?.stop()
            animatorRebound?.stop()
            percentDropOut = 0
        }
        super.onStatus(oldStatus, changed: status)
    }

    // MARK: - Draw

    /**
     * [EN] Draws the background, the box, its lid and the dropping files.
     * [CN] 绘制背景、盒子、盖子与掉落的文件。
     */
    open override func draw(_ rect: CGRect) {
        let width = self.width
        let height = dragOffset
        let margin = sideLength / 2
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let box = boxBody.measure(Int(margin), w: Int(width), h: Int(height), s: Int(margin * 2))

        colorPrimary?.setFill()
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        drawBoxBody(context, box: box)
        drawBoxCoverPath(context, box: box)
        drawImages(context, box: box, w: width)

        if height <= 0 {
            NSLog("%@.drawRect.height=%@ !", NSStringFromClass(type(of: self)), NSNumber(value: Double(height)))
        }
    }

    private func drawBoxBody(_ context: CGContext, box: BoxBody) {
        colorAccent?.withAlphaComponent(150.0 / 255).setFill()
        context.move(to: CGPoint(x: box.boxLeft, y: box.boxCenterBottom))
        context.addLine(to: CGPoint(x: box.boxCenterX, y: box.boxBottom))
        context.addLine(to: CGPoint(x: box.boxRight, y: box.boxCenterBottom))
        context.addQuadCurve(to: CGPoint(x: box.boxRight, y: box.boxCenterTop),
                             control: CGPoint(x: CGFloat(box.boxRight) + CGFloat(box.boxSideLength / 2) * percentRebound,
                                              y: CGFloat(box.boxCenterY)))
        context.addLine(to: CGPoint(x: box.boxCenterX, y: box.boxTop))
        context.addLine(to: CGPoint(x: box.boxLeft, y: box.boxCenterTop))
        context.addQuadCurve(to: CGPoint(x: box.boxLeft, y: box.boxCenterBottom),
                             control: CGPoint(x: CGFloat(box.boxLeft) - CGFloat(box.boxSideLength / 2) * percentRebound,
                                              y: CGFloat(box.boxCenterY)))
        context.closePath()
        context.fillPath()
    }

    // [EN] `NSInteger * (float)sin(…)`: the product is a float, as in Objective-C. [CN] `NSInteger * (float)sin(…)`：乘积为 float，与 Objective-C 相同。
    private static func floatProduct(_ side: Int, _ value: Double) -> CGFloat {
        CGFloat(Float(side) * Float(value))
    }

    private func drawBoxCoverPath(_ context: CGContext, box: BoxBody) {
        colorAccent?.setFill()

        let sideLength = (box.boxCenterX - box.boxLeft) * 4 / 5
        let offsetAngle = percentRebound * (3.1415926 * 2 / 5)
        let centerTop = CGFloat(box.boxCenterTop)
        let middleY = CGFloat((box.boxBottom + box.boxTop) / 2)

        // 开始画左上的盖子
        let offsetLeftTopX = Self.floatProduct(sideLength, sin(3.1415926 / 3 - Double(offsetAngle) / 2))
        let offsetLeftTopY = Self.floatProduct(sideLength, cos(3.1415926 / 3 - Double(offsetAngle) / 2))
        context.move(to: CGPoint(x: box.boxLeft, y: box.boxCenterTop))
        context.addLine(to: CGPoint(x: box.boxCenterX, y: box.boxTop))
        context.addLine(to: CGPoint(x: CGFloat(box.boxCenterX) - offsetLeftTopX, y: CGFloat(box.boxTop) - offsetLeftTopY))
        context.addLine(to: CGPoint(x: CGFloat(box.boxLeft) - offsetLeftTopX, y: centerTop - offsetLeftTopY))
        context.closePath()
        context.fillPath()

        // 开始画左下的盖子
        let offsetLeftBottomX = Self.floatProduct(sideLength, sin(3.1415926 / 3 + Double(offsetAngle)))
        let offsetLeftBottomY = Self.floatProduct(sideLength, cos(3.1415926 / 3 + Double(offsetAngle)))
        context.move(to: CGPoint(x: box.boxLeft, y: box.boxCenterTop))
        context.addLine(to: CGPoint(x: CGFloat(box.boxCenterX), y: middleY))
        context.addLine(to: CGPoint(x: CGFloat(box.boxCenterX) - offsetLeftBottomX, y: middleY + offsetLeftBottomY))
        context.addLine(to: CGPoint(x: CGFloat(box.boxLeft) - offsetLeftBottomX, y: centerTop + offsetLeftBottomY))
        context.closePath()
        context.fillPath()

        // 开始画右上的盖子
        let offsetRightTopX = Self.floatProduct(sideLength, sin(3.1415926 / 3 - Double(offsetAngle) / 2))
        let offsetRightTopY = Self.floatProduct(sideLength, cos(3.1415926 / 3 - Double(offsetAngle) / 2))
        context.move(to: CGPoint(x: box.boxRight, y: box.boxCenterTop))
        context.addLine(to: CGPoint(x: box.boxCenterX, y: box.boxTop))
        context.addLine(to: CGPoint(x: CGFloat(box.boxCenterX) + offsetRightTopX, y: CGFloat(box.boxTop) - offsetRightTopY))
        context.addLine(to: CGPoint(x: CGFloat(box.boxRight) + offsetRightTopX, y: centerTop - offsetRightTopY))
        context.closePath()
        context.fillPath()

        // 开始画右下的盖子
        let offsetRightBottomX = Self.floatProduct(sideLength, sin(3.1415926 / 3 + Double(offsetAngle)))
        let offsetRightBottomY = Self.floatProduct(sideLength, cos(3.1415926 / 3 + Double(offsetAngle)))
        context.move(to: CGPoint(x: box.boxRight, y: box.boxCenterTop))
        context.addLine(to: CGPoint(x: CGFloat(box.boxCenterX), y: middleY))
        context.addLine(to: CGPoint(x: CGFloat(box.boxCenterX) + offsetRightBottomX, y: middleY + offsetRightBottomY))
        context.addLine(to: CGPoint(x: CGFloat(box.boxRight) + offsetRightBottomX, y: centerTop + offsetRightBottomY))
        context.closePath()
        context.fillPath()
    }

    private func drawImages(_ context: CGContext, box: BoxBody, w width: CGFloat) {
        if percentDropOut <= 0 {
            return
        }

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: box.boxCenterTop))
        path.addLine(to: CGPoint(x: box.boxLeft, y: box.boxCenterTop))
        path.addLine(to: CGPoint(x: box.boxCenterX, y: box.boxCenterY))
        path.addLine(to: CGPoint(x: box.boxRight, y: box.boxCenterTop))
        path.addLine(to: CGPoint(x: width, y: CGFloat(box.boxCenterTop)))
        path.addLine(to: CGPoint(x: width, y: 0))

        context.saveGState()
        context.addPath(path)
        context.clip()

        let centerY = CGFloat(box.boxCenterY)
        let percent1 = min(percentDropOut, 1)
        var frame1 = imageMovie?.frame ?? .zero
        frame1.origin = CGPoint(x: width / 2 - imageSize / 2, y: ((centerY - imageSize / 2 + imageSize) * percent1) - imageSize)
        imageMovie?.frame = frame1
        imageMovie?.render(in: context)

        let percent2 = min(max(percentDropOut - 1, 0), 1)
        var frame2 = imageFile?.frame ?? .zero
        frame2.origin = CGPoint(x: width / 2 - imageSize / 2, y: ((centerY - imageSize / 2 + imageSize) * percent2) - imageSize)
        imageFile?.frame = frame2
        imageFile?.render(in: context)

        let percent3 = min(max(percentDropOut - 2, 0), 1)
        var frame3 = imageMusic?.frame ?? .zero
        frame3.origin = CGPoint(x: width / 2 - imageSize / 2, y: ((centerY - imageSize / 2 + imageSize) * percent3) - imageSize)
        imageMusic?.frame = frame3
        imageMusic?.render(in: context)

        if isDropOutOverFlow {
            frame1.origin = CGPoint(x: width / 2 - imageSize / 2, y: centerY - imageSize / 2)
            imageMovie?.frame = frame1
            imageMovie?.render(in: context)

            frame2.origin = CGPoint(x: width / 2 - imageSize / 2, y: centerY - imageSize / 2)
            imageFile?.frame = frame2
            imageFile?.render(in: context)

            frame3.origin = CGPoint(x: width / 2 - imageSize / 2, y: centerY - imageSize / 2)
            imageMusic?.frame = frame3
            imageMusic?.render(in: context)
        }
        context.restoreGState()
    }
}
