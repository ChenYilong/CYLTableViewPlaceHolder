//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/Utilities.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API
//      (`+newLayerForElement:withPath:`). Public only so the module's Objective-C files can read it (an internal helper
//      of the drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变（`+newLayerForElement:withPath:`）。设为
//      public 只是为了让模块内的 Objective-C 文件读取（绘制样式的内部辅助类，不是 API）。

import UIKit

/**
 * [EN] Makes the layers of vector elements.
 * [CN] 生成矢量元素的图层。
 */
@objc(CYLRefreshVectorUtilities)
public final class CYLRefreshVectorUtilities: NSObject {

    // [EN] The layer key the identifier is stored under. [CN] 存放标识的图层 key。
    private static let elementIdentifierKey = "SVGElementIdentifier"

    /**
     * [EN] A shape layer that draws `path` with the element's stroke, fill and opacity, framed to the path's bounds plus
     *      half the stroke width.
     * [CN] 用元素的描边、填充与不透明度绘制 `path` 的形状图层，frame 为路径边界向外扩展半个描边宽度。
     */
    @objc(newLayerForElement:withPath:)
    public class func newLayer(for element: CYLRefreshVectorElement, withPath path: CGPath?) -> CALayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = element.identifier
        shapeLayer.setValue(element.identifier, forKey: elementIdentifierKey)

        let strokeWidth = element.strokeWidth
        // [EN] CGPathGetBoundingBox (control points included); a missing path has the null rectangle, as NULL did.
        // [CN] CGPathGetBoundingBox（包含控制点）；没有路径时为空矩形，与 NULL 相同。
        let pathRect = (path?.boundingBox ?? .null).insetBy(dx: -strokeWidth / 2.0, dy: -strokeWidth / 2.0)
        shapeLayer.path = path
        shapeLayer.frame = pathRect

        // [EN] The original's stroke and fill layers are the same shape layer, so its combined-layer branch never ran.
        // [CN] 原实现的描边图层与填充图层是同一个形状图层，因此其组合图层分支从未执行。
        if strokeWidth > 0, let stroke = element.stroke {
            let fakeSize = CGSize(width: strokeWidth, height: strokeWidth)
            shapeLayer.lineWidth = hypot(fakeSize.width, fakeSize.height) / CGFloat(2.0.squareRoot())
            shapeLayer.strokeColor = stroke.cgColor
        } else if element.stroke != nil {
            // This is how you tell Apple that the stroke is disabled; a strokewidth of 0 will NOT achieve this
            shapeLayer.strokeColor = nil
            // MUST set this explicitly, or Apple assumes 1.0
            shapeLayer.lineWidth = 0.0
        } else {
            // default value from SVG spec
            shapeLayer.lineWidth = 1.0
        }
        shapeLayer.fillColor = element.fill.cgColor
        shapeLayer.opacity = Float(element.opacity)
        return shapeLayer
    }
}
