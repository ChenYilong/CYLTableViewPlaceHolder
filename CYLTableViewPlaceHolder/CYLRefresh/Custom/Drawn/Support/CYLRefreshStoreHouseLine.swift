//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from StoreHouse/StoreHouseLine.m
//  (commit 9319448) into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API. Public only so the
//      module's Objective-C files can read it (an internal helper of the drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变。设为 public 只是为了让模块内的
//      Objective-C 文件读取（绘制样式的内部辅助类，不是 API）。

import UIKit

/**
 * [EN] One stroke of the StoreHouse text: its end points, middle, alpha, random offset, index and transform.
 * [CN] StoreHouse 文字中的一笔：两个端点、中点、透明度、随机偏移、序号与变换。
 */
@objc(CYLRefreshStoreHouseLine)
public final class CYLRefreshStoreHouseLine: NSObject {

    /**
     * [EN] The start point.
     * [CN] 起点。
     */
    @objc public var start: CGPoint = .zero

    /**
     * [EN] The end point.
     * [CN] 终点。
     */
    @objc public var end: CGPoint = .zero

    /**
     * [EN] The middle of the stroke.
     * [CN] 线段的中点。
     */
    @objc public var middle: CGPoint = .zero

    /**
     * [EN] The stroke's alpha.
     * [CN] 线段的透明度。
     */
    @objc public var alpha: CGFloat = 0

    /**
     * [EN] A random offset between -1 and 1 that scatters the stroke while it flies in.
     * [CN] -1 到 1 之间的随机偏移，使线段飞入时分散。
     */
    @objc public var offset: CGFloat = 0

    /**
     * [EN] The stroke's position in the text.
     * [CN] 线段在文字中的序号。
     */
    @objc public var index: Int = 0

    /**
     * [EN] The stroke's transform. Default identity.
     * [CN] 线段的变换。默认单位变换。
     */
    @objc public var transform: CGAffineTransform = .identity
}
