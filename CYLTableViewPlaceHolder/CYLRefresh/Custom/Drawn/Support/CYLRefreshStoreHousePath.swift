//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from StoreHouse/StoreHousePath.m
//  (commit 9319448) into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API (`+linesFromArray:`,
//      `+linesFrom:scale:space:`, `+arrayAkta`, `+arrayStoreHouse`) and the same glyphs: the letter and digit tables that
//      `+initialize` built are built once, on first use, as a lazy static; the original maps '-' twice, the second time
//      to the dot's stroke (its '.' entry used the '-' key), and that is kept. Public only so the module's Objective-C
//      files can read it (an internal helper of the drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API（`+linesFromArray:`、`+linesFrom:scale:space:`、
//      `+arrayAkta`、`+arrayStoreHouse`）与字形均不变：原先由 `+initialize` 构建的字母与数字表改为首次使用时构建一次的惰性静态值；原实现给 '-'
//      映射了两次，第二次映射为点的笔画（其 '.' 条目用了 '-' 的 key），这一点保持不变。设为 public 只是为了让模块内的 Objective-C 文件读取
//      （绘制样式的内部辅助类，不是 API）。

import UIKit

/**
 * [EN] The strokes of the StoreHouse text: a line font for A-Z (also a-z), 0-9, space and '-', and two logos.
 * [CN] StoreHouse 文字的笔画：A-Z（也用于 a-z）、0-9、空格与 '-' 的线条字体，以及两个标志。
 */
@objc(CYLRefreshStoreHousePath)
public final class CYLRefreshStoreHousePath: NSObject {

    // [EN] The letters A-Z, in a 47 x 72 box. [CN] 字母 A-Z，位于 47 x 72 的框内。
    private static let letters: [[String]] = [
        // A
        [
            "{24,  0}", "{1, 22}",
            "{1,  22}", "{1, 72}",
            "{24,  0}", "{47, 22}",
            "{47, 22}", "{47, 72}",
            "{1,  48}", "{47, 48}",
        ],
        // B
        [
            "{0,  0 }", "{0, 72}",
            "{0,  0 }", "{37, 0}",
            "{37, 0 }", "{47, 11}",
            "{47, 11}", "{47, 26}",
            "{47, 26}", "{38, 36}",
            "{38, 36}", "{0, 36}",
            "{38, 36}", "{47, 46}",
            "{47, 46}", "{47, 61}",
            "{47, 61}", "{38, 71}",
            "{37, 72}", "{0, 72}",
        ],
        // C
        [
            "{47, 0}", "{ 0, 0}",
            "{0,  0}", "{ 0, 72}",
            "{0, 72}", "{47, 72}",
        ],
        // D
        [
            "{0,   0}", "{0,  72}",
            "{0,   0}", "{24,  0}",
            "{24,  0}", "{47, 22}",
            "{47, 22}", "{47, 48}",
            "{47, 48}", "{23, 72}",
            "{23, 72}", "{0,  72}",
        ],
        // E
        [
            "{0,  0}", "{ 0, 72}",
            "{0,  0}", "{47,  0}",
            "{0, 36}", "{37, 36}",
            "{0, 72}", "{47, 72}",
        ],
        // F
        [
            "{0,  0}", "{ 0, 72}",
            "{0,  0}", "{47,  0}",
            "{0, 36}", "{37, 36}",
        ],
        // G
        [
            "{47, 23}", "{47,  0}",
            "{47,  0}", "{ 0,  0}",
            "{0,   0}", "{ 0, 72}",
            "{0,  72}", "{47, 72}",
            "{47, 72}", "{47, 48}",
            "{47, 48}", "{24, 48}",
        ],
        // H
        [
            "{0,  0}", "{0,  72}",
            "{0, 36}", "{47, 36}",
            "{47, 0}", "{47, 72}",
        ],
        // I
        [
            "{0,  0}", "{47,  0}",
            "{24, 0}", "{24, 72}",
            "{0, 72}", "{47, 72}",
        ],
        // J
        [
            "{47,  0}", "{47, 72}",
            "{47, 72}", "{24, 72}",
            "{24, 72}", "{ 0, 48}",
        ],
        // K
        [
            "{0,  0}", "{ 0, 72}",
            "{47, 0}", "{ 3, 33}",
            "{3, 38}", "{47, 72}",
        ],
        // L
        [
            "{0,  0}", "{ 0, 72}",
            "{0, 72}", "{47, 72}",
        ],
        // M
        [
            "{0,   0}", "{ 0, 72}",
            "{0,   0}", "{24, 23}",
            "{24, 23}", "{47,  0}",
            "{47,  0}", "{47, 72}",
        ],
        // N
        [
            "{0,  0}", "{ 0, 72}",
            "{0,  0}", "{47, 72}",
            "{47,72}", "{47,  0}",
        ],
        // O
        [
            "{0,  0}", "{ 0,72}",
            "{0, 72}", "{47,72}",
            "{47,72}", "{47, 0}",
            "{47, 0}", "{ 0, 0}",
        ],
        // P
        [
            "{0,  0}", "{ 0, 72}",
            "{0,  0}", "{47,  0}",
            "{47, 0}", "{47, 36}",
            "{47,36}", "{ 0, 36}",
        ],
        // Q
        [
            "{0,   0}", "{ 0, 72}",
            "{0,  72}", "{23, 72}",
            "{23, 72}", "{47, 48}",
            "{47, 48}", "{47,  0}",
            "{47,  0}", "{ 0,  0}",
            "{24, 28}", "{47, 71}",
        ],
        // R
        [
            "{0,  0}", "{ 0, 72}",
            "{0,  0}", "{47,  0}",
            "{47, 0}", "{47, 36}",
            "{47,36}", "{ 0, 36}",
            "{0, 37}", "{47, 72}",
        ],
        // S
        [
            "{47,  0}", "{ 0,  0}",
            "{0,   0}", "{ 0, 36}",
            "{0,  36}", "{47, 36}",
            "{47, 36}", "{47, 72}",
            "{47, 72}", "{ 0, 72}",
        ],
        // T
        [
            "{0, 0}", "{47,  0}",
            "{24,0}", "{24, 72}",
        ],
        // U
        [
            "{0,   0}", "{ 0, 72}",
            "{0,  72}", "{47, 72}",
            "{47, 72}", "{47,  0}",
        ],
        // V
        [
            "{0,   0}", "{24, 72}",
            "{24, 72}", "{47,  0}",
        ],
        // W
        [
            "{0,   0}", "{ 0, 72}",
            "{0,  72}", "{24, 49}",
            "{24, 49}", "{47, 72}",
            "{47, 72}", "{47,  0}",
        ],
        // X
        [
            "{0,  0}", "{47, 72}",
            "{47, 0}", "{ 0, 72}",
        ],
        // Y
        [
            "{0,   0}", "{24, 23}",
            "{47,  0}", "{24, 23}",
            "{24, 23}", "{24, 72}",
        ],
        // Z
        [
            "{0,  0}", "{47,  0}",
            "{47, 0}", "{ 0, 72}",
            "{0, 72}", "{47, 72}",
        ],
    ]

    // [EN] The digits 0-9. [CN] 数字 0-9。
    private static let numbers: [[String]] = [
        // 0
        [
            "{0,  0}", "{ 0, 72}",
            "{0, 72}", "{47, 72}",
            "{47,72}", "{47,  0}",
            "{47, 0}", "{ 0,  0}",
        ],
        // 1
        [
            "{24, 0}", "{24, 72}",
        ],
        // 2
        [
            "{0,  0}", "{47,  0}",
            "{47, 0}", "{47, 36}",
            "{47,36}", "{ 0, 36}",
            "{0, 36}", "{ 0, 72}",
            "{0, 72}", "{47, 72}",
        ],
        // 3
        [
            "{0,   0}", "{47,  0}",
            "{47,  0}", "{47, 36}",
            "{47, 36}", "{ 0, 36}",
            "{47, 36}", "{47, 72}",
            "{47, 72}", "{ 0, 72}",
        ],
        // 4
        [
            "{0,   0}", "{ 0, 36}",
            "{0,  36}", "{47, 36}",
            "{47,  0}", "{47, 72}",
        ],
        // 5
        [
            "{0,   0}", "{ 0, 36}",
            "{0,  36}", "{47, 36}",
            "{47, 36}", "{47, 72}",
            "{47, 72}", "{ 0, 72}",
            "{0,   0}", "{47,  0}",
        ],
        // 6
        [
            "{0,   0}", "{ 0, 72}",
            "{0,  72}", "{47, 72}",
            "{47, 72}", "{47, 36}",
            "{47, 36}", "{ 0, 36}",
        ],
        // 7
        [
            "{0,  0}", "{47,  0}",
            "{47, 0}", "{47, 72}",
        ],
        // 8
        [
            "{0,  0}", "{0,  72}",
            "{0, 72}", "{47, 72}",
            "{47,72}", "{47,  0}",
            "{47, 0}", "{0,   0}",
            "{0, 36}", "{47, 36}",
        ],
        // 9
        [
            "{47, 0}", "{ 0,  0}",
            "{0,  0}", "{ 0, 36}",
            "{0, 36}", "{47, 36}",
            "{47, 0}", "{47, 72}",
        ],
    ]

    // [EN] The strokes of each UTF-16 code unit. [CN] 每个 UTF-16 码元的笔画。
    private static let codeMap: [Int: [CYLRefreshStoreHouseLine]] = {
        var dictionary = [Int: [CYLRefreshStoreHouseLine]]()
        let letterLines = letters.map { linesFromArray($0) }
        let numberLines = numbers.map { linesFromArray($0) }
        // A - Z
        for (i, lines) in letterLines.enumerated() {
            dictionary[i + Int(UInt8(ascii: "A"))] = lines
        }
        // a - z
        for (i, lines) in letterLines.enumerated() {
            dictionary[i + Int(UInt8(ascii: "a"))] = lines
        }
        // 0 - 9
        for (i, lines) in numberLines.enumerated() {
            dictionary[i + Int(UInt8(ascii: "0"))] = lines
        }
        // blank
        dictionary[Int(UInt8(ascii: " "))] = []
        // -
        dictionary[Int(UInt8(ascii: "-"))] = linesFromArray(["{0, 36}", "{47, 36}"])
        // . (the original used the '-' key here, so '-' draws the dot's stroke)
        dictionary[Int(UInt8(ascii: "-"))] = linesFromArray(["{24, 60}", "{24, 72}"])
        return dictionary
    }()

    /**
     * [EN] The strokes of a list of points (`CGPointFromString` strings), two per stroke, with random offsets.
     * [CN] 由点列表（`CGPointFromString` 字符串，每两个点一笔）生成的笔画，带随机偏移。
     */
    @objc(linesFromArray:)
    public class func linesFromArray(_ array: [String]) -> [CYLRefreshStoreHouseLine] {
        var items = [CYLRefreshStoreHouseLine]()
        var i = 0
        while i * 2 + 1 < array.count {
            let startPoint = NSCoder.cgPoint(for: array[i * 2])
            let endPoint = NSCoder.cgPoint(for: array[i * 2 + 1])
            let item = CYLRefreshStoreHouseLine()
            item.index = items.count
            item.start = startPoint
            item.end = endPoint
            item.middle = CGPoint(x: (item.start.x + item.end.x) / 2, y: (item.start.y + item.end.y) / 2)
            item.offset = CGFloat(Int(arc4random() % 200) - 100) / 100.0
            items.append(item)
            i += 1
        }
        return items
    }

    /**
     * [EN] The strokes of `str` in the line font, scaled by `scale` / 4, `space` points between the 57-point glyphs;
     *      characters without strokes leave a gap.
     * [CN] 用线条字体生成 `str` 的笔画，按 `scale` / 4 缩放，57 点宽的字形之间相隔 `space` 点；没有笔画的字符留出空位。
     */
    @objc(linesFrom:scale:space:)
    public class func linesFrom(_ str: String, scale: CGFloat, space: Int) -> [CYLRefreshStoreHouseLine] {
        let scale = scale * 0.25
        var offsetX: CGFloat = 0
        var items = [CYLRefreshStoreHouseLine]()
        let text = str as NSString
        for i in 0..<text.length {
            let ch = Int(text.character(at: i))
            if let points = codeMap[ch] {
                for p in points {
                    let item = CYLRefreshStoreHouseLine()
                    item.index = items.count
                    item.start = CGPoint(x: (offsetX + p.start.x) * scale, y: p.start.y * scale)
                    item.end = CGPoint(x: (offsetX + p.end.x) * scale, y: p.end.y * scale)
                    item.middle = CGPoint(x: (item.start.x + item.end.x) / 2, y: (item.start.y + item.end.y) / 2)
                    item.offset = CGFloat(Int(arc4random() % 200) - 100) / 100.0
                    items.append(item)
                }
            }
            offsetX += CGFloat(57 + space)
        }
        return items
    }

    /**
     * [EN] The points of the Akta logo.
     * [CN] Akta 标志的点。
     */
    @objc public class func arrayAkta() -> [String] {
        return [
            "{22,0}",
            "{0,30}",
            "{22,0}",
            "{30,0}",
            "{30,0}",
            "{52,30}",
            "{0,30}",
            "{26,30}",
            "{60,0}",
            "{60,15}",
            "{60,15}",
            "{60,30}",
            "{60,15}",
            "{85,15}",
            "{85,15}",
            "{108,0}",
            "{85,15}",
            "{108,30}",
            "{117,0}",
            "{147,0}",
            "{147,0}",
            "{177,0}",
            "{147,0}",
            "{147,32}",
            "{198,0}",
            "{176,30}",
            "{198,0}",
            "{206,0}",
            "{206,0}",
            "{228,30}",
            "{176,30}",
            "{202,30}",
        ]
    }

    /**
     * [EN] The points of the StoreHouse logo.
     * [CN] StoreHouse 标志的点。
     */
    @objc public class func arrayStoreHouse() -> [String] {
        return [
            "{0,35}",
            "{12,42}",
            "{12,42}",
            "{24,35}",
            "{24,35}",
            "{12,28}",
            "{0,35}",
            "{12,28}",
            "{0,21}",
            "{12,28}",
            "{12,28}",
            "{24,21}",
            "{24,35}",
            "{24,21}",
            "{24,21}",
            "{12,14}",
            "{0,21}",
            "{12,14}",
            "{0,21}",
            "{0,7}",
            "{12,14}",
            "{0,7}",
            "{12,14}",
            "{24,7}",
            "{24,7}",
            "{12,0}",
            "{0,7}",
            "{12,0}",
        ]
    }
}
