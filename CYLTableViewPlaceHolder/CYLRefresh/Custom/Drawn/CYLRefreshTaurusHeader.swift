//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshTaurusHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API and the same drawing,
//      colors and timing.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API 以及绘制、颜色与时序均不变。

import UIKit

/**
 * [EN] An airplane flying through clouds (after Yalantis Taurus).
 * [CN] 穿过云层的飞机（参考 Yalantis Taurus）。
 */
@objc(CYLRefreshTaurusHeader)
open class CYLRefreshTaurusHeader: CYLRefreshDrawnHeader {

    private static let pathAirplane = "m23 81c0 0 0 -1 0 -1 0 -0.5 0 -1 1.5 -1 2 -1 2.6 -2 2 -2.5 -0.5 -1 -2 -1 -11.6 -2.5 -5 -1 -10 -1 -11 -1.5l-1 0 1 -1c1 -1 1 -1 2 -1 0.6 0 6 0 13 1 6 0 12 1 12.6 0.6l1 0 -1 -2C30 67 16 42 15 40.6l-0.5 -1 4 -1c2 -0.6 4 -1 4 -1 0 0 6 4 13 8.5 14.6 10 17 11 20 12 4.6 2 6 1.6 13 -0.6 13 -5 25 -9 26 -9 0.6 0 3.6 1 -24 -14L51 23 47 16 43 10 43.6 9c1 -1 1 -1 1 -0.5 0 0 4 3 7.5 6 4 3 7 6 7.5 6 0 0 13.6 3 29.5 6 16 3 32 6 35 7l6 1 3 -1c41.6 -14.6 68 -23 85 -28 15 -4 24 -5 32 -2.5 7 2 10 5 8 8 -1.6 2.5 -4.6 4.6 -10.6 7.5 -6 3 -10 4 -25 9 -8 2.6 -16.6 6 -39 14 -67 25 -88 31 -121.6 36 -14.5 2 -24 3 -34 3 -5 0 -5.5 0 -6 -0.5z"
    private static let pathCloud1 = "M552 1A65 65 0 0 0 504 22A51 51 0 0 0 492 20A51 51 0 0 0 442 71A51 51 0 0 0 492 121A51 51 0 0 0 511 118A65 65 0 0 0 517 122L586 122A65 65 0 0 0 600 111A60 60 0 0 0 608 122L696 122A60 60 0 0 0 712 82A60 60 0 0 0 652 22A60 60 0 0 0 611 39A65 65 0 0 0 552 1zM246 2A55 55 0 0 0 195 37A47 47 0 0 0 168 28A47 47 0 0 0 121 75A47 47 0 0 0 168 121A47 47 0 0 0 209 97A55 55 0 0 0 246 111A55 55 0 0 0 269 107A39 39 0 0 0 281 122L328 122A39 39 0 0 0 343 91A39 39 0 0 0 304 52A39 39 0 0 0 301 52A55 55 0 0 0 246 2z"
    private static let pathCloud2 = "m507 31a53 53 0 0 0 -53 53 53 53 0 0 0 16 38h75a53 53 0 0 0 2 -2 28 28 0 0 0 1 2h213a97 97 0 0 0 -87 -54.8 97 97 0 0 0 -73 34 28 28 0 0 0 -27 -19 28 28 0 0 0 -13 3 53 53 0 0 0 0 -1 53 53 0 0 0 -53 -53zM206 32a54 54 0 0 0 -50 34 74.9 74.9 0 0 0 -47 -17 74.9 74.9 0 0 0 -74 61 31 31 0 0 0 -10 -2 31 31 0 0 0 -26 14L301 122a38 38 0 0 0 0 -4 38 38 0 0 0 -38 -38 38 38 0 0 0 -4 0 54 54 0 0 0 -54 -49z"
    private static let pathCloud3 = "m424 37a53 53 0 0 0 -41 19 53 53 0 0 0 -1 2 63 63 0 0 0 -5 0 63 63 0 0 0 -61 50 63 63 0 0 0 -1 4 16 16 0 0 0 -10 -4 16 16 0 0 0 -8 2 21 21 0 0 0 -18 -11 21 21 0 0 0 -19 13 22 22 0 0 0 -7 -1 22 22 0 0 0 -19 11L523 122a44 44 0 0 0 -43 -37 44 44 0 0 0 -3 0 53 53 0 0 0 -53 -48zM129 38a50 50 0 0 0 -50 50 50 50 0 0 0 2 15 15 16 0 0 0 -6 2 15 16 0 0 0 -1 1 17 16 0 0 0 -12 -5 17 16 0 0 0 -16 14 20 16 0 0 0 -15 7L224 122a43 43 0 0 0 1 -10 43 43 0 0 0 -43 -43 43 43 0 0 0 -7 1 50 50 0 0 0 -47 -32zM632 83a64 64 0 0 0 -45 18 27 27 0 0 0 -11 -2 27 27 0 0 0 -23 13 17 17 0 0 0 -7 -1 17 17 0 0 0 -16 12h160a64 64 0 0 0 -59 -39z"

    private static let scaleStartPercent: CGFloat = 0.5
    private static let animationDuration: CGFloat = 1000

    private static let sideCloudsInitialScale: CGFloat = 0.6
    private static let sideCloudsFinalScale: CGFloat = 1

    private static let centerCloudsInitialScale: CGFloat = 0.8
    private static let centerCloudsFinalScale: CGFloat = 1

    // Multiply with this animation interpolator time
    private static let loadingAnimationCoefficient = 80
    private static let slowDownAnimationCoefficient = 6

    // Amount of lines when is going lading animation
    private static let windSetAmount = 10
    private static let ySideCloudsSlowDownCof: CGFloat = 4
    private static let xSideCloudsSlowDownCof: CGFloat = 2
    private static let minWindLineWidth = 50
    private static let maxWindLineWidth = 300
    private static let minWindXOffset = 1000
    private static let maxWindXOffset = 2000
    private static let randomYCoefficient: CGFloat = 5

    private enum AnimationPart {
        case first
        case second
        case third
        case fourth
    }

    private var animatorFinish: CYLRefreshValueAnimator?
    private var animatorRefreshing: CYLRefreshValueAnimator?
    // [EN] Empty until `setUpComponent` (an empty image has a zero size and draws nothing, as nil did in Objective-C).
    // [CN] 在 `setUpComponent` 之前为空（空矢量图尺寸为零、不绘制，与 Objective-C 中的 nil 相同）。
    private var imageCloud = CYLRefreshVectorImage()
    private var imageAirplane = CYLRefreshVectorImage()

    private var lastAnimationTime: CGFloat = 0
    private var loadingAnimationTime: CGFloat = 0
    private var finishAnimationTime: CGFloat = 0
    private var windLineWidth: CGFloat = 0

    private var newWindSet = false
    private var inverseDirection = false

    // [EN] y → x offset of each wind line; an NSMutableDictionary keyed by NSNumber, as in Objective-C (same order).
    // [CN] 每条风线的 y → x 偏移；与 Objective-C 一样使用以 NSNumber 为键的 NSMutableDictionary（遍历顺序相同）。
    private var winds = NSMutableDictionary()

    // MARK: - Init

    /**
     * [EN] Builds the clouds and the airplane, and sets the Taurus colors, the stretch mode and the finish duration.
     * [CN] 创建云与飞机，并设置 Taurus 的颜色、拉伸模式与结束时长。
     */
    open override func setUpComponent() {
        super.setUpComponent()

        let imageCloud = CYLRefreshVectorImage()
        imageCloud.size = CGSize(width: 260, height: 45)
        imageCloud.parserPaths([Self.pathCloud1, Self.pathCloud2, Self.pathCloud3])
        imageCloud.parserColors([
            UIColor(red: 0xc7 / 255.0, green: 0xdc / 255.0, blue: 0xf1 / 255.0, alpha: 0xaa / 255.0),
            UIColor(red: 0xe8 / 255.0, green: 0xf3 / 255.0, blue: 0xfd / 255.0, alpha: 0xdd / 255.0),
            UIColor(red: 0xfd / 255.0, green: 0xfd / 255.0, blue: 0xfd / 255.0, alpha: 0xff / 255.0),
        ])

        let imageAirplane = CYLRefreshVectorImage()
        imageAirplane.size = CGSize(width: 65, height: 20)
        imageAirplane.parserPaths([Self.pathAirplane])
        imageAirplane.parserColors([UIColor.white])

        height = 100
        colorAccent = .white
        colorPrimary = UIColor(red: 0x11 / 255.0, green: 0x99 / 255.0, blue: 0xff / 255.0, alpha: 1)
        self.imageCloud = imageCloud
        self.imageAirplane = imageAirplane
        scrollMode = .stretch

        finishDuration = 0.3
        winds = NSMutableDictionary()
    }

    // MARK: - Override

    /**
     * [EN] Redraws with the pull. [CN] 随下拉重绘。
     */
    open override func scrollView(_ scrollView: UIScrollView, didScroll offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        super.scrollView(scrollView, didScroll: offset, percent: percent, drag: isDragging)
        setNeedsDisplay()
    }

    /**
     * [EN] Starts the flight while refreshing and the fly-away after it.
     * [CN] 刷新时开始飞行动画，刷新后开始飞离动画。
     */
    open override func onStatus(_ oldStatus: CYLRefreshPhase, changed status: CYLRefreshPhase) {
        super.onStatus(oldStatus, changed: status)

        if oldStatus == .refreshing {
            let animator = CYLRefreshValueAnimator.newWith(target: self, selector: #selector(animatorRunning(_:)))
            animatorFinish = animator
            animator.duration = finishDuration
            animator.repeatMode = .reverse
            animator.interpolator = .accelerateDecelerate
            animator.start()
        } else if status == .refreshing {
            loadingAnimationTime = 0
            let animator = CYLRefreshValueAnimator.newWith(target: self, selector: #selector(animatorRunning(_:)))
            animatorRefreshing = animator
            animator.repeatCount = .infinity
            animator.duration = CFTimeInterval(Self.animationDuration / 1000.0)
            animator.repeatMode = .reverse
            animator.interpolator = .accelerateDecelerate
            animator.start()
        }
    }

    // [EN] Every frame of both animators (selector `animatorRunning:`). [CN] 两个动画器的每一帧（选择器 `animatorRunning:`）。
    @objc(animatorRunning:)
    private func animatorRunning(_ animator: CYLRefreshValueAnimator) {
        if animator === animatorRefreshing {
            loadingAnimationTime = CGFloat(Self.loadingAnimationCoefficient) *
                (animator.value / CGFloat(Self.slowDownAnimationCoefficient))
            setNeedsDisplay()
        } else if animator === animatorFinish {
            finishAnimationTime = animator.value
            if animator.value >= 0.95 {
                animatorRefreshing?.stop()
            }
            setNeedsDisplay()
        }
    }

    // We need a special value for different part of animation
    private func animationPartValue(_ part: AnimationPart) -> CGFloat {
        switch part {
        case .first:
            return loadingAnimationTime
        case .second:
            return -loadingAnimationTime
        case .third:
            return loadingAnimationTime - CGFloat(animationTimePart(.second))
        case .fourth:
            return CGFloat(animationTimePart(.third)) - (loadingAnimationTime - CGFloat(animationTimePart(.fourth)))
        }
    }

    // Get part of animation duration
    private func animationTimePart(_ part: AnimationPart) -> Int {
        switch part {
        case .second:
            return Self.loadingAnimationCoefficient / 2
        case .third:
            return 3 * animationTimePart(.fourth)
        case .fourth:
            return Self.loadingAnimationCoefficient / 4
        default:
            return 0
        }
    }

    // On drawing we should check current part of animation
    private func checkCurrentAnimationPart(_ part: AnimationPart) -> Bool {
        switch part {
        case .first:
            return loadingAnimationTime < CGFloat(animationTimePart(.fourth))
        case .second, .third:
            return loadingAnimationTime < CGFloat(animationTimePart(part))
        case .fourth:
            return loadingAnimationTime > CGFloat(animationTimePart(.third))
        }
    }

    // MARK: - Draw

    /**
     * [EN] Draws the background, the wind, the airplane and the clouds.
     * [CN] 绘制背景、风、飞机与云。
     */
    open override func draw(_ rect: CGRect) {
        let width = self.width
        let height = dragOffset
        let percent = dragPercent
        let context = UIGraphicsGetCurrentContext()

        colorPrimary?.setFill()
        context?.fill(CGRect(x: 0, y: 0, width: width, height: height))

        drawWinds(context, width: width, height: height, percent: percent)
        drawAirplane(context, width: width, height: height, percent: percent)
        drawCloudSide(context, width: width, height: height, percent: percent)
        drawCloudCenter(context, width: width, height: height, percent: percent)

        if height <= 0 {
            NSLog("%@.drawRect.height=%@ !", NSStringFromClass(type(of: self)), NSNumber(value: Double(height)))
        }
    }

    private func random(_ min: Int, max: Int) -> Int {
        min + Int(arc4random()) % (max - min + 1)
    }

    private func drawWinds(_ context: CGContext?, width: CGFloat, height: CGFloat, percent: CGFloat) {
        guard status == .refreshing else { return }
        let height = max(height, expandHeight)

        // Set up new set of wind
        while winds.count < Self.windSetAmount {
            var y = height / (Self.randomYCoefficient * CGFloat(random(1, max: 100)) / 100.0)
            let x = CGFloat(random(Self.minWindXOffset, max: Self.maxWindXOffset))

            // We want that interval will be greater than fifth part of draggable distance
            if winds.count > 1 {
                y = 0
                while y == 0 {
                    let tmp = height / (Self.randomYCoefficient * CGFloat(random(1, max: 100)) / 100.0)
                    for case let key as NSNumber in winds.allKeys {
                        // We want that interval will be greater than fifth part of draggable distance
                        if abs(CGFloat(key.floatValue) - tmp) > height / Self.randomYCoefficient {
                            y = tmp
                        } else {
                            y = 0
                            break
                        }
                    }
                }
            }
            winds[NSNumber(value: Double(y))] = NSNumber(value: Double(x))
            drawWind(context, y: y, x: x, width: width)
        }

        // Draw current set of wind
        if winds.count >= Self.windSetAmount {
            for case let key as NSNumber in winds.allKeys {
                let x = (winds[key] as? NSNumber)?.floatValue ?? 0
                drawWind(context, y: CGFloat(key.floatValue), x: CGFloat(x), width: width)
            }
        }

        // We should to create new set of winds
        if inverseDirection && newWindSet {
            winds.removeAllObjects()
            newWindSet = false
            windLineWidth = CGFloat(random(Self.minWindLineWidth, max: Self.maxWindLineWidth))
        }

        // needed for checking direction
        lastAnimationTime = loadingAnimationTime
    }

    // Draw wind on loading animation: `y` is the line's y position, `xOffset` its x offset.
    private func drawWind(_ context: CGContext?, y: CGFloat, x xOffset: CGFloat, width: CGFloat) {
        // We should multiply current animation time with this coefficient for taking all screen width in time.
        // Removing slowing of animation with dividing on SLOW_DOWN_ANIMATION_COEFFICIENT.
        // And we should don't forget about distance that should "fly" line that depend on screen of device and x offset.
        let timeSpan = 1.0 * CGFloat(Self.loadingAnimationCoefficient) / CGFloat(Self.slowDownAnimationCoefficient)
        let cof = (width + xOffset) / timeSpan
        var time = loadingAnimationTime

        // HORRIBLE HACK FOR REVERS ANIMATION THAT SHOULD WORK LIKE RESTART ANIMATION
        if lastAnimationTime - loadingAnimationTime > 0 {
            inverseDirection = true
            // take time from 0 to end of animation time
            time = timeSpan - loadingAnimationTime
        } else {
            newWindSet = true
            inverseDirection = false
        }
        // Taking current x position of drawing wind
        // For fully disappearing of line we should subtract wind line width
        let x = (width - (time * cof)) + xOffset - windLineWidth
        let xEnd = x + windLineWidth

        context?.saveGState()

        context?.setLineWidth(3.0)
        context?.setStrokeColor(UIColor(white: 1, alpha: CGFloat(Float(0.25))).cgColor)

        context?.move(to: CGPoint(x: x, y: y))
        context?.addLine(to: CGPoint(x: xEnd, y: y))
        context?.strokePath()

        context?.restoreGState()
    }

    private func drawAirplane(_ context: CGContext?, width: CGFloat, height: CGFloat, percent: CGFloat) {
        var rotateAngle: CGFloat = 0
        var dragPercent = percent
        let expandHeight = self.expandHeight
        let airplane = imageAirplane

        if dragPercent > 1.0 {
            rotateAngle = 20 * (1.0 - pow(100, -(dragPercent - 1) / 2))
            dragPercent = 1.0
        }

        var offsetX = ((width * dragPercent) / 2) - airplane.size.width / 2.0
        var offsetY = expandHeight * (1 - dragPercent / 2) - airplane.size.height / 2.0

        if status == .finishing {
            offsetY -= (expandHeight / 2 + airplane.size.height / 2) * finishAnimationTime
            offsetX += (width + airplane.size.width - offsetX) * finishAnimationTime
        }

        if animatorRefreshing?.isRunning == true {
            if checkCurrentAnimationPart(.first) {
                offsetY -= animationPartValue(.first)
            } else if checkCurrentAnimationPart(.second) {
                offsetY -= animationPartValue(.second)
            } else if checkCurrentAnimationPart(.third) {
                offsetY += animationPartValue(.third)
            } else if checkCurrentAnimationPart(.fourth) {
                offsetY += animationPartValue(.fourth)
            }
        }

        context?.saveGState()
        context?.translateBy(x: offsetX, y: offsetY)

        if rotateAngle > 0 {
            context?.translateBy(x: airplane.size.width / 2, y: airplane.size.height / 2)
            context?.rotate(by: rotateAngle * 3.1415926 / 180)
            context?.translateBy(x: -airplane.size.width / 2, y: -airplane.size.height / 2)
        }

        airplane.render(in: context)

        context?.restoreGState()
    }

    private func drawCloudSide(_ context: CGContext?, width: CGFloat, height: CGFloat, percent: CGFloat) {
        let cloudLeft = imageCloud
        let cloudRight = imageCloud

        let expandHeight = self.expandHeight
        let dragPercent = min(1, abs(percent))

        let scale: CGFloat
        let scalePercentDelta = dragPercent - Self.scaleStartPercent
        if scalePercentDelta > 0 {
            let scalePercent = scalePercentDelta / (CGFloat(Float(1.0)) - Self.scaleStartPercent)
            scale = Self.sideCloudsInitialScale + (Self.sideCloudsFinalScale - Self.sideCloudsInitialScale) * scalePercent
        } else {
            scale = Self.sideCloudsInitialScale
        }

        // Current y position of clouds
        let dragYOffset = expandHeight * (1.0 - dragPercent)

        // Position where clouds fully visible on screen and we should drag them with content of listView
        var offsetLeftX = 0 - cloudLeft.size.width / 2
        var offsetLeftY = dragYOffset

        var offsetRightX = width - cloudRight.size.width / 2
        var offsetRightY = dragYOffset

        // Magic with animation on loading process
        if animatorRefreshing?.isRunning == true {
            if checkCurrentAnimationPart(.first) {
                offsetLeftX -= 2 * animationPartValue(.first) / Self.ySideCloudsSlowDownCof
                offsetRightX += animationPartValue(.first) / Self.xSideCloudsSlowDownCof
            } else if checkCurrentAnimationPart(.second) {
                offsetLeftX -= 2 * animationPartValue(.second) / Self.ySideCloudsSlowDownCof
                offsetRightX += animationPartValue(.second) / Self.xSideCloudsSlowDownCof
            } else if checkCurrentAnimationPart(.third) {
                offsetLeftX -= animationPartValue(.third) / Self.ySideCloudsSlowDownCof
                offsetRightX += 2 * animationPartValue(.third) / Self.xSideCloudsSlowDownCof
            } else if checkCurrentAnimationPart(.fourth) {
                offsetLeftX -= animationPartValue(.fourth) / Self.ySideCloudsSlowDownCof
                offsetRightX += 2 * animationPartValue(.fourth) / Self.xSideCloudsSlowDownCof
            }
        }

        if offsetLeftY + scale * cloudLeft.size.height < height + 2 {
            offsetLeftY = height + 2 - scale * cloudLeft.size.height
        }
        if offsetRightY + scale * cloudRight.size.height < height + 2 {
            offsetRightY = height + 2 - scale * cloudRight.size.height
        }

        context?.saveGState()
        context?.translateBy(x: offsetLeftX, y: offsetLeftY)

        context?.translateBy(x: cloudLeft.size.width * 3 / 4, y: cloudLeft.size.height)
        context?.scaleBy(x: scale, y: scale)
        context?.translateBy(x: -cloudLeft.size.width * 3 / 4, y: -cloudLeft.size.height)

        cloudLeft.opacity = 100.0 / 255
        cloudLeft.render(in: context)
        cloudLeft.opacity = 1

        context?.restoreGState()

        context?.saveGState()
        context?.translateBy(x: offsetRightX, y: offsetRightY)

        context?.translateBy(x: 0, y: cloudRight.size.height)
        context?.scaleBy(x: scale, y: scale)
        context?.translateBy(x: 0, y: -cloudRight.size.height)

        cloudRight.opacity = 100.0 / 255
        cloudRight.render(in: context)
        cloudRight.opacity = 1

        context?.restoreGState()
    }

    private func drawCloudCenter(_ context: CGContext?, width: CGFloat, height: CGFloat, percent: CGFloat) {
        let cloud = imageCloud
        let expandHeight = self.expandHeight

        let scale: CGFloat
        var overDragPercent: CGFloat = 0
        let dragPercent = min(1, abs(percent))
        var overDrag = false

        if percent > CGFloat(Float(1.0)) {
            overDrag = true
            // Here we want know about how mach percent of over drag we done
            overDragPercent = abs(CGFloat(Float(1.0)) - percent)
        }

        let scalePercentDelta = dragPercent - Self.scaleStartPercent
        if scalePercentDelta > 0 {
            let scalePercent = scalePercentDelta / (CGFloat(Float(1.0)) - Self.scaleStartPercent)
            scale = Self.centerCloudsInitialScale + (Self.centerCloudsFinalScale - Self.centerCloudsInitialScale) * scalePercent
        } else {
            scale = Self.centerCloudsInitialScale
        }

        var parallax = false
        var parallaxPercent: CGFloat = 0
        let dragYOffset = expandHeight * dragPercent
        // Position when should start parallax scrolling (an NSInteger in Objective-C: truncated)
        let startValue = expandHeight - cloud.size.height / 2
        let startParallaxHeight = CGFloat(startValue.isFinite && abs(startValue) < 9.0e15 ? Int(startValue) : 0)

        if dragYOffset > startParallaxHeight {
            parallax = true
            parallaxPercent = dragYOffset - startParallaxHeight
        }

        let offsetX = (width / 2) - cloud.size.width / 2
        var offsetY = dragYOffset - cloud.size.height / 2 - (parallax ? parallaxPercent : 0)

        var sx = overDrag ? scale + overDragPercent / 4 : scale
        var sy = sx

        let coefficient = CGFloat(Self.loadingAnimationCoefficient)
        if animatorRefreshing?.isRunning == true && !overDrag {
            if checkCurrentAnimationPart(.first) {
                sx = scale - animationPartValue(.first) / coefficient / 8
            } else if checkCurrentAnimationPart(.second) {
                sx = scale - animationPartValue(.second) / coefficient / 8
            } else if checkCurrentAnimationPart(.third) {
                sx = scale + animationPartValue(.third) / coefficient / 6
            } else if checkCurrentAnimationPart(.fourth) {
                sx = scale + animationPartValue(.fourth) / coefficient / 6
            }
            sy = sx
        }

        if offsetY + sy * cloud.size.height < height + 2 {
            offsetY = height + 2 - sy * cloud.size.height
        }

        context?.saveGState()
        context?.translateBy(x: offsetX, y: offsetY)

        context?.translateBy(x: cloud.size.width / 2, y: 0)
        context?.scaleBy(x: sx, y: sy)
        context?.translateBy(x: -cloud.size.width / 2, y: 0)

        cloud.render(in: context)

        context?.restoreGState()
    }
}
