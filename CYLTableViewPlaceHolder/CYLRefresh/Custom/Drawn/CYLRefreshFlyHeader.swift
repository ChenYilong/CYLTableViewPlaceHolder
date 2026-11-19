//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshFlyHeader.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 8), with the same Objective-C API (`mountainView`, `flyView`,
//      `floatView`) and the same drawing, colors and timing.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 8 步），Objective-C API（`mountainView`、`flyView`、`floatView`）
//      以及绘制、颜色与时序均不变。

import UIKit

/**
 * [EN] A paper plane over mountains that flies off while refreshing (after FlyRefresh). Always open: the scene stays
 *      above the list and refreshing does not push the content.
 * [CN] 山上的纸飞机，刷新时飞走（参考 FlyRefresh）。常态展开：场景一直显示在列表上方，刷新时不推动内容。
 */
@objc(CYLRefreshFlyHeader)
open class CYLRefreshFlyHeader: CYLRefreshDrawnHeader, CAAnimationDelegate {

    private static let floatViewSize: CGFloat = 50

    // [EN] The permanent top inset this header added. [CN] 本刷新头加上的常驻顶部 inset。
    private var addedInset: CGFloat = 0
    // [EN] The fixed open height; the frame grows past it with the pull. [CN] 固定的展开高度；frame 随下拉超过它。
    private var openHeight: CGFloat = 0
    private let mountain = CYLRefreshMountainView()
    private let plane = CYLRefreshFlyView()
    private let roundButton = UIView()

    /**
     * [EN] The mountains above the content, tinted with `colorPrimary`; the same as Android's `mountainView`.
     * [CN] 内容上方的山，使用 `colorPrimary` 着色；与 Android 的 `mountainView` 相同。
     */
    @objc public var mountainView: UIView { mountain }

    /**
     * [EN] The paper plane, tinted with `colorAccent`; the same as Android's `flyView`.
     * [CN] 纸飞机，使用 `colorAccent` 着色；与 Android 的 `flyView` 相同。
     */
    @objc public var flyView: UIView { plane }

    /**
     * [EN] The round button under the plane, in the primary color; the same as Android's `floatView`.
     * [CN] 纸飞机下方的圆形按钮，使用主色；与 Android 的 `floatView` 相同。
     */
    @objc public var floatView: UIView { roundButton }

    /**
     * [EN] The fixed open height, 150 points by default.
     * [CN] 固定的展开高度，默认 150 点。
     */
    open override var expandHeight: CGFloat {
        openHeight > 0 ? openHeight : 150
    }

    /**
     * [EN] Adds the mountains, the round button and the plane, and sets the Fly colors.
     * [CN] 加入山、圆形按钮与纸飞机，并设置 Fly 的颜色。
     */
    open override func setUpComponent() {
        openHeight = 150
        height = 150
        addSubview(mountain)
        let size = Self.floatViewSize
        roundButton.frame = CGRect(x: 0, y: 0, width: size, height: size)
        roundButton.layer.cornerRadius = size / 2
        addSubview(roundButton)
        addSubview(plane)
        // [EN] Always open: the scene stays above the list, so refreshing does not push the content further.
        // [CN] 常态展开：场景一直显示在列表上方，因此刷新时不再把内容往下推。
        addsRefreshingInset = false
        super.setUpComponent()

        triggerRate = 0.5
        colorPrimary = Self.color(rgb: 0x33aaff)
        colorAccent = .white
    }

    private static func color(rgb: Int) -> UIColor {
        UIColor(red: CGFloat(Float((rgb & 0xFF0000) >> 16)) / 255.0,
                green: CGFloat(Float((rgb & 0x00FF00) >> 8)) / 255.0,
                blue: CGFloat(Float(rgb & 0x0000FF)) / 255.0, alpha: 1)
    }

    /**
     * [EN] Lays out the mountains, the round button and, while not refreshing, the plane.
     * [CN] 布局山、圆形按钮，以及不在刷新时的纸飞机。
     */
    open override func layoutSubviews() {
        super.layoutSubviews()
        let size = Self.floatViewSize
        mountain.frame = bounds
        roundButton.center = CGPoint(x: size * 3 / 4, y: frame.size.height)
        if !isRefreshing {
            plane.center = CGPoint(x: size * 3 / 4, y: frame.size.height)
        }
    }

    /**
     * [EN] Colors the round button and the mountains. [CN] 为圆形按钮与山着色。
     */
    open override var colorPrimary: UIColor? {
        get { super.colorPrimary }
        set {
            super.colorPrimary = newValue
            roundButton.backgroundColor = newValue
            mountain.colorPrimary = newValue
        }
    }

    /**
     * [EN] Colors the plane. [CN] 为纸飞机着色。
     */
    open override var colorAccent: UIColor? {
        get { super.colorAccent }
        set {
            super.colorAccent = newValue
            plane.colorAccent = newValue
        }
    }

    /**
     * [EN] Always open: attaching adds the open height to the top inset once, detaching removes it.
     * [CN] 常态展开：挂上时把展开高度加到顶部 inset 一次，离开时移除。
     */
    open override func scrollView(_ scrollView: UIScrollView, attached attach: Bool) {
        super.scrollView(scrollView, attached: attach)
        if attach && addedInset <= 0 {
            addedInset = expandHeight
            var inset = scrollView.contentInset
            inset.top += addedInset
            scrollView.contentInset = inset
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y - addedInset)
        } else if !attach && addedInset > 0 {
            var inset = scrollView.contentInset
            inset.top -= addedInset
            scrollView.contentInset = inset
            addedInset = 0
        }
    }

    /**
     * [EN] The scene fills the open area plus the pull. [CN] 场景铺满展开区域加上下拉距离。
     */
    open override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        let height = expandHeight + dragOffset
        if abs(frame.size.height - height) > 0.25 || abs(frame.origin.y + height) > 0.25 {
            frame = CGRect(x: frame.origin.x, y: -height - ignoredScrollViewContentInsetTop, width: frame.size.width, height: height)
        }
    }

    /**
     * [EN] Places the scene above the content, as tall as the open area plus the pull.
     * [CN] 把场景放在内容上方，高度为展开区域加上下拉距离。
     */
    open override func placeSubviews() {
        super.placeSubviews()
        let height = expandHeight + dragOffset
        frame = CGRect(x: frame.origin.x, y: -height - ignoredScrollViewContentInsetTop, width: frame.size.width, height: height)
    }

    /**
     * [EN] While pulling, grows the mountains and tilts the plane with the offset.
     * [CN] 下拉时根据偏移量改变背景高度和纸飞机角度。
     */
    open override func onScrolling(withOffset offset: CGFloat, percent: CGFloat, drag isDragging: Bool) {
        mountain.onScrolling(withOffset: offset, percent: percent)
        if !isRefreshing {
            let percent = offset / expandHeight
            plane.transform = CGAffineTransform(rotationAngle: -percent * 3.1415926 / 4)
        }
    }

    /**
     * [EN] The user released: the plane flies off. [CN] 用户松手，执行飞机飞出动画。
     */
    open override func onStartAnimationWhenRealeasing() {
        let size = Self.floatViewSize
        plane.transform = .identity

        let end = CGPoint(x: width + size / 2, y: size / 4)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size * 3 / 4, y: expandHeight + dragOffset))
        path.addQuadCurve(to: end, controlPoint: CGPoint(x: 0, y: 0))

        let aniFly = CAKeyframeAnimation(keyPath: "position")
        aniFly.path = path.cgPath
        aniFly.calculationMode = .paced
        aniFly.rotationMode = .rotateAuto

        let aniScale = CABasicAnimation(keyPath: "transform")
        aniScale.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        aniScale.toValue = NSValue(caTransform3D: CATransform3DMakeScale(0.5, 0.2, 1))

        let aniGroup = CAAnimationGroup()
        aniGroup.animations = [aniScale, aniFly]
        aniGroup.duration = 1.5
        aniGroup.fillMode = .forwards
        aniGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)

        plane.layer.add(aniGroup, forKey: "fly")
        plane.center = end
    }

    /**
     * [EN] The refresh ends: the plane flies back. [CN] 用户关闭刷新，执行飞机飞回动画。
     */
    open override func finishRefresh(withSuccess success: Bool) {
        super.finishRefresh(withSuccess: success)
        let floatSize = Self.floatViewSize
        let size = frame.size

        let p1 = CGPoint(x: -floatSize, y: size.height - floatSize)
        let p2 = CGPoint(x: -floatSize, y: size.height)
        let end = CGPoint(x: floatSize * 3 / 4, y: frame.size.height)
        let path = UIBezierPath()
        path.move(to: plane.center)
        path.addQuadCurve(to: p1, controlPoint: CGPoint(x: size.width, y: size.height - floatSize))
        path.addQuadCurve(to: end, controlPoint: p2)

        let aniFly = CAKeyframeAnimation(keyPath: "position")
        aniFly.path = path.cgPath
        aniFly.calculationMode = .paced
        aniFly.rotationMode = .rotateAuto

        let aniScale = CABasicAnimation(keyPath: "transform")
        aniScale.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(0.5, 0.2, 1))
        aniScale.toValue = NSValue(caTransform3D: CATransform3DIdentity)

        let aniGroup = CAAnimationGroup()
        aniGroup.animations = [aniScale, aniFly]
        aniGroup.duration = 1.5
        aniGroup.delegate = self
        aniGroup.fillMode = .forwards
        aniGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)

        plane.layer.add(aniGroup, forKey: "back")
    }

    /**
     * [EN] The plane is back: put it on the round button. [CN] 纸飞机飞回动画结束，放回圆形按钮上。
     */
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            plane.center = CGPoint(x: Self.floatViewSize * 3 / 4, y: frame.size.height)
        }
    }
}
