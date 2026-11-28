//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Component/UIVectorView.m
//  (commit 9319448) into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API (`image`,
//      `-parserPaths:`, `-parserColors:`, `-setVectorImage:`). Public only so the module's Objective-C files can read it
//      (an internal helper of the drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变（`image`、`-parserPaths:`、
//      `-parserColors:`、`-setVectorImage:`）。设为 public 只是为了让模块内的 Objective-C 文件读取（绘制样式的内部辅助类，不是 API）。

import UIKit

/**
 * [EN] A view that draws a vector image centered in its bounds, scaled to fit its frame; the tint color fills every
 *      element.
 * [CN] 在自身范围内居中绘制矢量图的视图，矢量图按 frame 缩放；tint color 填充每个元素。
 */
@objc(CYLRefreshVectorView)
open class CYLRefreshVectorView: UIView {

    /**
     * [EN] The image drawn by the view; nil draws nothing.
     * [CN] 视图绘制的矢量图；nil 时不绘制。
     */
    @objc public var image: CYLRefreshVectorImage?

    /**
     * [EN] A clear view.
     * [CN] 背景透明的视图。
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    /**
     * [EN] A clear view from a storyboard or nib.
     * [CN] 从 storyboard 或 nib 创建的背景透明的视图。
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    /**
     * [EN] Parses SVG path strings into the image, creating it when needed.
     * [CN] 把 SVG 路径字符串解析到矢量图中，需要时创建矢量图。
     */
    @objc(parserPaths:)
    public func parserPaths(_ paths: [String]) {
        if image == nil {
            image = CYLRefreshVectorImage()
        }
        image?.parserPaths(paths)
    }

    /**
     * [EN] Fills the image's elements (`-[CYLRefreshVectorImage parserColors:]`).
     * [CN] 填充矢量图的元素（`-[CYLRefreshVectorImage parserColors:]`）。
     */
    @objc(parserColors:)
    public func parserColors(_ colors: [UIColor]) {
        image?.parserColors(colors)
    }

    /**
     * [EN] Scales the image to fit the new frame.
     * [CN] 把矢量图缩放到新的 frame。
     */
    open override var frame: CGRect {
        get { super.frame }
        set {
            super.frame = newValue
            image?.scaleToFitInside(newValue.size)
        }
    }

    /**
     * [EN] Fills every element of the image with the new tint color.
     * [CN] 用新的 tint color 填充矢量图的每个元素。
     */
    open override var tintColor: UIColor! {
        get { super.tintColor }
        set {
            super.tintColor = newValue
            if let image = image, let tintColor = newValue {
                image.parserColors(Array(repeating: tintColor, count: image.elements.count))
            }
        }
    }

    /**
     * [EN] Sets the image and scales it to the view's size when the view has one.
     * [CN] 设置矢量图；视图有尺寸时把它缩放到该尺寸。
     */
    @objc(setVectorImage:)
    public func setVectorImage(_ image: CYLRefreshVectorImage?) {
        self.image = image
        let size = frame.size
        if size != .zero {
            image?.scaleToFitInside(size)
        }
    }

    /**
     * [EN] Sizes the view to the image's viewport.
     * [CN] 把视图尺寸设为矢量图的 viewport 尺寸。
     */
    open override func sizeToFit() {
        if let image = image {
            var frame = self.frame
            frame.size = image.viewport.size
            self.frame = frame
        } else {
            super.sizeToFit()
        }
    }

    /**
     * [EN] The image's viewport size, scaled down to fit `size` when it is larger.
     * [CN] 矢量图的 viewport 尺寸；大于 `size` 时缩小到恰好放入。
     */
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let image = image else {
            return super.sizeThatFits(size)
        }
        let sizeImage = image.viewport.size
        if sizeImage.width > size.width || sizeImage.height > size.height {
            let old = image.size
            image.scaleToFitInside(size)
            let fitted = image.size
            image.size = old
            return fitted
        }
        return image.viewport.size
    }

    /**
     * [EN] Draws the image centered in the bounds.
     * [CN] 在范围内居中绘制矢量图。
     */
    open override func draw(_ rect: CGRect) {
        guard let image = image else {
            super.draw(rect)
            return
        }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        let sizeImage = image.size
        let sizeCanvas = bounds.size
        context.translateBy(x: sizeCanvas.width / 2 - sizeImage.width / 2, y: sizeCanvas.height / 2 - sizeImage.height / 2)
        image.render(in: context)
        context.restoreGState()
    }
}
