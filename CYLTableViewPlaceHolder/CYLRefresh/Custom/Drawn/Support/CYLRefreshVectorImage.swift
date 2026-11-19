//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/VectorImage.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API (`elements`, `size`,
//      `frame`, `viewport`, `opacity`, `-parserPaths:`, `-parserColors:`, `-scaleToFitInside:`, `-renderInContext:`, ...).
//      The drawn styles (Objective-C) get it from the generated Swift header through the umbrella header. Public only so
//      the module's Objective-C files can read it (an internal helper of the drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变（`elements`、`size`、`frame`、`viewport`、
//      `opacity`、`-parserPaths:`、`-parserColors:`、`-scaleToFitInside:`、`-renderInContext:` 等）。绘制样式（Objective-C）通过总头文件中的
//      生成 Swift 头文件获得它。设为 public 只是为了让模块内的 Objective-C 文件读取（绘制样式的内部辅助类，不是 API）。

import UIKit

/**
 * [EN] A vector image made of SVG path elements, drawn into a Core Graphics context at `frame`, scaled from `viewport`
 *      (the union of the elements' bounds).
 * [CN] 由 SVG 路径元素组成的矢量图，按 `viewport`（各元素边界的并集）缩放后绘制到 Core Graphics 上下文的 `frame` 处。
 */
@objc(CYLRefreshVectorImage)
public final class CYLRefreshVectorImage: NSObject {

    /**
     * [EN] The elements, in drawing order.
     * [CN] 元素，按绘制顺序排列。
     */
    @objc public private(set) var elements: [CYLRefreshVectorElement] = []

    /**
     * [EN] Where the image is drawn; zero (the default) draws it at the viewport's size.
     * [CN] 图像的绘制位置；为零（默认）时按 viewport 的尺寸绘制。
     */
    @objc public var frame: CGRect = .zero

    /**
     * [EN] The union of the elements' bounds.
     * [CN] 各元素边界的并集。
     */
    @objc public var viewport: CGRect = .zero

    /**
     * [EN] The drawn size: the viewport's size while `frame` is zero and there are elements, else the frame's size.
     *      Setting it sets the frame's size.
     * [CN] 绘制尺寸：`frame` 为零且有元素时为 viewport 的尺寸，否则为 frame 的尺寸。设置时修改 frame 的尺寸。
     */
    @objc public var size: CGSize {
        get {
            if !elements.isEmpty && frame == .zero {
                return viewport.size
            }
            return frame.size
        }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }

    /**
     * [EN] Setting it sets the opacity of every element. Default 0 (the elements keep their own opacity until it is set).
     * [CN] 设置时修改每个元素的不透明度。默认 0（设置之前元素保持自己的不透明度）。
     */
    @objc public var opacity: CGFloat = 0 {
        didSet {
            for element in elements {
                element.opacity = opacity
            }
        }
    }

    /**
     * [EN] Adds an element and grows the viewport to include it.
     * [CN] 添加一个元素，并扩大 viewport 以包含它。
     */
    @objc(addElement:)
    public func addElement(_ element: CYLRefreshVectorElement) {
        elements.append(element)
        viewport = viewport.union(element.viewport)
    }

    /**
     * [EN] Replaces the elements with one path element per SVG path string.
     * [CN] 把元素替换为每个 SVG 路径字符串对应的一个路径元素。
     */
    @objc(parserPaths:)
    public func parserPaths(_ paths: [String]) {
        viewport = .zero
        elements.removeAll()
        for path in paths {
            addElement(CYLRefreshVectorPathElement.newWith(path))
        }
    }

    /**
     * [EN] Fills the elements: one color per element when the counts match, else the colors in order and the last one
     *      for the rest.
     * [CN] 填充元素：数量一致时每个元素一种颜色，否则按顺序使用这些颜色，其余元素使用最后一种。
     */
    @objc(parserColors:)
    public func parserColors(_ colors: [UIColor]) {
        if elements.count == colors.count {
            for i in 0..<colors.count {
                elements[i].fill = colors[i]
            }
        } else if !colors.isEmpty {
            var color = colors[0]
            for i in 0..<elements.count {
                if i < colors.count {
                    color = colors[i]
                }
                elements[i].fill = color
            }
        }
    }

    /**
     * [EN] Draws the elements' layers into `context`, scaled from the viewport to `size` at `frame.origin`.
     * [CN] 把各元素的图层绘制到 `context` 中，从 viewport 缩放到 `size`，位置为 `frame.origin`。
     */
    @objc(renderInContext:)
    public func render(in context: CGContext?) {
        guard viewport != .zero, let context = context else { return }
        let point = frame.origin
        let start = viewport.origin
        let sizeCanvas = size
        let sizeImage = viewport.size
        let scaleX = sizeCanvas.width / sizeImage.width
        let scaleY = sizeCanvas.height / sizeImage.height

        context.saveGState()
        context.translateBy(x: point.x, y: point.y)
        context.translateBy(x: -scaleX * start.x, y: -scaleY * start.y)
        context.scaleBy(x: scaleX, y: scaleY)
        for element in elements {
            element.layer?.render(in: context)
        }
        context.restoreGState()
    }

    /**
     * [EN] Scales the size up or down to fit inside `maxSize`, keeping the aspect ratio; takes `maxSize` when either size
     *      is zero.
     * [CN] 保持宽高比，把尺寸放大或缩小到恰好放入 `maxSize`；任一尺寸为零时直接使用 `maxSize`。
     */
    @objc(scaleToFitInside:)
    public func scaleToFitInside(_ maxSize: CGSize) {
        if size == .zero || maxSize == .zero {
            size = maxSize
            return
        }
        // [EN] `float`, as the Objective-C code computed the scales. [CN] 与 Objective-C 代码一样用 `float` 计算缩放比例。
        let wScale = Float(maxSize.width / size.width)
        let hScale = Float(maxSize.height / size.height)
        let smallestScaleUp = CGFloat(min(wScale, hScale))
        size = size.applying(CGAffineTransform(scaleX: smallestScaleUp, y: smallestScaleUp))
    }

    /**
     * [EN] Sets the width and the height that keeps the aspect ratio; does nothing while the size is zero.
     * [CN] 设置宽度，并按宽高比设置高度；尺寸为零时不做任何事。
     */
    @objc(setGeometricWidth:)
    public func setGeometricWidth(_ width: CGFloat) {
        let size = self.size
        if size != .zero {
            self.size = CGSize(width: width, height: size.height * width / size.width)
        }
    }

    /**
     * [EN] Sets the height and the width that keeps the aspect ratio; does nothing while the size is zero.
     * [CN] 设置高度，并按宽高比设置宽度；尺寸为零时不做任何事。
     */
    @objc(setGeometricHeight:)
    public func setGeometricHeight(_ height: CGFloat) {
        let size = self.size
        if size != .zero {
            self.size = CGSize(width: size.width * height / size.height, height: height)
        }
    }

    /**
     * [EN] Moves the frame's origin to `pt`, keeping the current size.
     * [CN] 把 frame 的原点移到 `pt`，保持当前尺寸。
     */
    @objc(moveTo:)
    public func move(to pt: CGPoint) {
        let size = self.size
        frame = CGRect(x: pt.x, y: pt.y, width: size.width, height: size.height)
    }
}
