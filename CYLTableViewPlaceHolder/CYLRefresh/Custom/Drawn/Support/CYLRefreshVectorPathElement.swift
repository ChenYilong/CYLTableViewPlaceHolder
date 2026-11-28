//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/PathElement.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7), with the same Objective-C API (`+newWith:`,
//      `pathForShape`), converted with its superclass `CYLRefreshVectorElement`. Public only so the module's Objective-C
//      files can read it (an internal helper of the drawn styles, not API).
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步），Objective-C API 不变（`+newWith:`、`pathForShape`），与其父类
//      `CYLRefreshVectorElement` 一起转换。设为 public 只是为了让模块内的 Objective-C 文件读取（绘制样式的内部辅助类，不是 API）。

import UIKit

/**
 * [EN] A vector element drawn from SVG path data (`M`, `L`, `H`, `V`, `C`, `S`, `Q`, `T`, `A`, `Z` and their relative
 *      forms).
 * [CN] 由 SVG 路径数据（`M`、`L`、`H`、`V`、`C`、`S`、`Q`、`T`、`A`、`Z` 及其相对形式）绘制的矢量元素。
 */
@objc(CYLRefreshVectorPathElement)
open class CYLRefreshVectorPathElement: CYLRefreshVectorElement {

    /**
     * [EN] A new element parsed from the SVG path data `data`.
     * [CN] 由 SVG 路径数据 `data` 解析出的新元素。
     */
    @objc(newWith:)
    public class func newWith(_ data: String) -> CYLRefreshVectorPathElement {
        let element = self.init()
        element.parseData(data)
        return element
    }

    /**
     * [EN] A new element with no path; `newWith:` parses one.
     * [CN] 没有路径的新元素；`newWith:` 会解析路径。
     */
    public required override init() {
        super.init()
    }

    /**
     * [EN] The parsed path; nil before `newWith:` parses one.
     * [CN] 解析出的路径；`newWith:` 解析之前为 nil。
     */
    @objc public private(set) var pathForShape: CGPath?

    private func parseData(_ data: String) {
        let path = CGMutablePath()
        let dataScanner = Scanner(string: data)
        var lastCurve = CYLRefreshVectorPathsParser.startingCurve()
        let knownCommands = CharacterSet(charactersIn: "MmLlCcVvHhAaSsQqTtZz")
        var foundCmd: Bool
        repeat {
            var command = dataScanner.cylScanCharacters(from: knownCommands)
            foundCmd = command != nil
            if let scanned = command, (scanned as NSString).length > 1 {
                // Take only one char (it can happen that multiple commands are consecutive, as "ZM" - so we only want to get the "Z")
                let tooManyChars = (scanned as NSString).length - 1
                command = (scanned as NSString).substring(to: 1)
                dataScanner.cylMoveBack(tooManyChars)
            }
            if let command = command {
                if command == "z" || command == "Z" {
                    lastCurve = CYLRefreshVectorPathsParser.readCloseCommand(Scanner(string: command), path: path,
                                                                            relativeTo: lastCurve.p)
                } else if let cmdArgs = dataScanner.cylScanUpToCharacters(from: knownCommands) {
                    let cmdScanner = Scanner(string: command + cmdArgs)
                    let parser = CYLRefreshVectorPathsParser.self
                    switch command {
                    case "m":
                        lastCurve = parser.readMovetoDrawToCmdGroups(cmdScanner, path: path, relativeTo: lastCurve.p, isRelative: true)
                    case "M":
                        lastCurve = parser.readMovetoDrawToCmdGroups(cmdScanner, path: path, relativeTo: .zero, isRelative: false)
                    case "l":
                        lastCurve = parser.readLineToCmd(cmdScanner, path: path, relativeTo: lastCurve.p, isRelative: true)
                    case "L":
                        lastCurve = parser.readLineToCmd(cmdScanner, path: path, relativeTo: .zero, isRelative: false)
                    case "v":
                        lastCurve = parser.readVerticalLineToCmd(cmdScanner, path: path, relativeTo: lastCurve.p)
                    case "V":
                        lastCurve = parser.readVerticalLineToCmd(cmdScanner, path: path, relativeTo: .zero)
                    case "h":
                        lastCurve = parser.readHorizontalLineToCmd(cmdScanner, path: path, relativeTo: lastCurve.p)
                    case "H":
                        lastCurve = parser.readHorizontalLineToCmd(cmdScanner, path: path, relativeTo: .zero)
                    case "c":
                        lastCurve = parser.readCurveToCmd(cmdScanner, path: path, relativeTo: lastCurve.p, isRelative: true)
                    case "C":
                        lastCurve = parser.readCurveToCmd(cmdScanner, path: path, relativeTo: .zero, isRelative: false)
                    case "s":
                        lastCurve = parser.readSmoothCurveToCmd(cmdScanner, path: path, relativeTo: lastCurve.p,
                                                                withPrevCurve: lastCurve, isRelative: true)
                    case "S":
                        lastCurve = parser.readSmoothCurveToCmd(cmdScanner, path: path, relativeTo: .zero,
                                                                withPrevCurve: lastCurve, isRelative: false)
                    case "q":
                        lastCurve = parser.readQuadraticCurveToCmd(cmdScanner, path: path, relativeTo: lastCurve.p, isRelative: true)
                    case "Q":
                        lastCurve = parser.readQuadraticCurveToCmd(cmdScanner, path: path, relativeTo: .zero, isRelative: false)
                    case "t":
                        lastCurve = parser.readSmoothQuadraticCurveToCmd(cmdScanner, path: path, relativeTo: lastCurve.p,
                                                                         withPrevCurve: lastCurve)
                    case "T":
                        lastCurve = parser.readSmoothQuadraticCurveToCmd(cmdScanner, path: path, relativeTo: .zero,
                                                                         withPrevCurve: lastCurve)
                    case "a":
                        lastCurve = parser.readEllipticalArcArguments(cmdScanner, path: path, relativeTo: lastCurve.p, isRelative: true)
                    case "A":
                        lastCurve = parser.readEllipticalArcArguments(cmdScanner, path: path, relativeTo: .zero, isRelative: false)
                    default:
                        // unsupported command
                        break
                    }
                }
            }
        } while foundCmd

        pathForShape = path
        viewport = path.boundingBox
        changed = true
    }

    /**
     * [EN] A shape layer for the parsed path (`CYLRefreshVectorUtilities`).
     * [CN] 解析出的路径对应的形状图层（`CYLRefreshVectorUtilities`）。
     */
    open override func newLayer() -> CALayer? {
        assert(pathForShape != nil, "Requested a CALayer for SVG shape that never initialized its own .pathForShapeInRelativeCoords property. Shape class = \(type(of: self)). Shape instance = \(self)")
        return CYLRefreshVectorUtilities.newLayer(for: self, withPath: pathForShape)
    }
}
