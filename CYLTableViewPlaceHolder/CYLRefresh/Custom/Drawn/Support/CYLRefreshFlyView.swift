//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Fly/FlyView.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API (`colorAccent`). Public
//      only so the module's Objective-C files can read it (an internal helper of the drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变（`colorAccent`）。设为 public 只是为了让
//      模块内的 Objective-C 文件读取（绘制样式的内部辅助类，不是 API）。

import UIKit

/**
 * [EN] The paper plane of the Fly header, a vector image filled with `colorAccent`; 30 x 30 points when created with
 *      a zero frame.
 * [CN] Fly 刷新头中的纸飞机，用 `colorAccent` 填充的矢量图；以零 frame 创建时为 30 x 30 点。
 */
@objc(CYLRefreshFlyView)
open class CYLRefreshFlyView: UIView {

    private var storedImage: CYLRefreshVectorImage?

    // [EN] Setting the image parses the plane into it and scales it to the frame, as the Objective-C setter did.
    // [CN] 设置矢量图时把纸飞机解析进去并缩放到 frame，与 Objective-C 的 setter 相同。
    private var image: CYLRefreshVectorImage? {
        get { storedImage }
        set {
            storedImage = newValue
            newValue?.parserColors([.white])
            newValue?.parserPaths(["M2.01,21L23,12 2.01,3 2,10l15,2 -15,2z"])
            if frame.size.height > 0 && frame.size.width > 0 {
                newValue?.scaleToFitInside(frame.size)
            }
        }
    }

    private var storedColorAccent: UIColor?

    /**
     * [EN] The plane's color; nil until it is set.
     * [CN] 纸飞机的颜色；设置之前为 nil。
     */
    @objc public var colorAccent: UIColor! {
        get { storedColorAccent }
        set {
            storedColorAccent = newValue
            image?.parserColors([newValue])
        }
    }

    /**
     * [EN] A transparent plane view; a zero frame becomes 30 x 30 points.
     * [CN] 透明的纸飞机视图；零 frame 会变为 30 x 30 点。
     */
    public override init(frame: CGRect) {
        super.init(frame: frame == .zero ? CGRect(x: 0, y: 0, width: 30, height: 30) : frame)
        isOpaque = false
        image = CYLRefreshVectorImage()
    }

    /**
     * [EN] A plane view from a storyboard or nib, without an image (as the Objective-C class, which only set it up in
     *      `initWithFrame:`).
     * [CN] 从 storyboard 或 nib 创建的纸飞机视图，没有矢量图（与只在 `initWithFrame:` 中设置的 Objective-C 类相同）。
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /**
     * [EN] Scales the plane to the new frame.
     * [CN] 把纸飞机缩放到新的 frame。
     */
    open override var frame: CGRect {
        get { super.frame }
        set {
            super.frame = newValue
            storedImage?.scaleToFitInside(frame.size)
        }
    }

    /**
     * [EN] Draws the plane.
     * [CN] 绘制纸飞机。
     */
    open override func draw(_ rect: CGRect) {
        image?.render(in: UIGraphicsGetCurrentContext())
    }
}
