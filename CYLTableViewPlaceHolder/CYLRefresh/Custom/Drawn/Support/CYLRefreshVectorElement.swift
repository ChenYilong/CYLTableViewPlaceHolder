//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/Element.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API: `CYLRefreshVectorElement`,
//      converted with its subclass `CYLRefreshVectorPathElement` (Objective-C cannot subclass a Swift class).
//      Public only so the module's Objective-C files can read them (internal helpers of the drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变：`CYLRefreshVectorElement`，与其子类
//      `CYLRefreshVectorPathElement` 一起转换（Objective-C 不能继承 Swift 类）。设为 public 只是为了让模块内的 Objective-C 文件读取
//      （绘制样式的内部辅助类，不是 API）。

import UIKit

/**
 * [EN] One shape of a vector image: its colors, opacity, stroke width and bounds, and the layer that draws it, made
 *      again (`newLayer`) whenever a drawing attribute changed.
 * [CN] 矢量图中的一个图形：颜色、不透明度、描边宽度与边界，以及绘制它的图层；绘制属性改变后会重新生成（`newLayer`）。
 */
@objc(CYLRefreshVectorElement)
open class CYLRefreshVectorElement: NSObject {

    /**
     * [EN] The shape's identifier, written to its layer's name; nil by default.
     * [CN] 图形的标识，写入其图层的 name；默认 nil。
     */
    @objc public var identifier: String?

    /**
     * [EN] The stroke color; nil (the default) draws no stroke.
     * [CN] 描边颜色；nil（默认）不描边。
     */
    @objc public var stroke: UIColor? {
        didSet { changed = true }
    }

    /**
     * [EN] The fill color. Default white.
     * [CN] 填充颜色。默认白色。
     */
    @objc public var fill: UIColor = .white {
        didSet { changed = true }
    }

    /**
     * [EN] The opacity of the layer. Default 1.
     * [CN] 图层的不透明度。默认 1。
     */
    @objc public var opacity: CGFloat = 1 {
        didSet { changed = true }
    }

    /**
     * [EN] The stroke width. Default 0.
     * [CN] 描边宽度。默认 0。
     */
    @objc public var strokeWidth: CGFloat = 0 {
        didSet { changed = true }
    }

    /**
     * [EN] Kept from the original API; not used.
     * [CN] 沿用原 API；未使用。
     */
    @objc public var strokeOpacity: CGFloat = 0

    /**
     * [EN] The bounds of the shape in the image's coordinates.
     * [CN] 图形在图像坐标中的边界。
     */
    @objc public var viewport: CGRect = .zero

    /**
     * [EN] YES when a drawing attribute changed since the layer was set: reading `layer` then makes a new one.
     * [CN] 自设置图层以来绘制属性有变化时为 YES：此时读取 `layer` 会生成新图层。
     */
    @objc public var changed = false

    private var storedLayer: CALayer?

    /**
     * [EN] The layer that draws the shape: `newLayer` while `changed` (the original does not clear `changed` there, so a
     *      changed element makes a new layer on every read), else the layer set last. Setting it clears `changed`.
     * [CN] 绘制该图形的图层：`changed` 为 YES 时返回 `newLayer`（原实现在此不清除 `changed`，因此有变化的元素每次读取都会生成新图层），否则
     *      返回最后设置的图层。设置时清除 `changed`。
     */
    @objc public var layer: CALayer? {
        get {
            if changed {
                storedLayer = newLayer()
                return storedLayer
            }
            return storedLayer
        }
        set {
            storedLayer = newValue
            changed = false
        }
    }

    /**
     * [EN] A new element: white fill, opacity 1, no stroke.
     * [CN] 新元素：白色填充、不透明度 1、无描边。
     */
    public override init() {
        super.init()
        // [EN] The Objective-C initializer set the fill, opacity and stroke width through their setters, which mark the
        //      element changed. [CN] Objective-C 初始化方法通过 setter 设置填充、不透明度与描边宽度，这些 setter 会把元素标记为已改变。
        changed = true
    }

    /**
     * [EN] Makes the layer that draws the shape; nil here, subclasses make it.
     * [CN] 生成绘制该图形的图层；本类返回 nil，由子类生成。
     */
    @objc open func newLayer() -> CALayer? {
        return nil
    }
}
