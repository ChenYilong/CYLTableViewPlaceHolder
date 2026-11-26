//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/PathsParser.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  References:
//  http://www.w3.org/TR/2011/REC-SVG11-20110816/paths.html#PathDataBNF
//  http://www.w3.org/TR/2011/REC-SVG11-20110816/shapes.html#PointsBNF
//

// [EN] Swift since 2026-11-19 (docs/Swift-Migration.md, step 7). Internal: its only caller is
//      `CYLRefreshVectorPathElement` (Swift), and its API passes a C struct (`CYLRefreshCurve`) and a mutable path, which
//      the Objective-C header declared; both are Swift types now and `CYLRefreshVectorPathsParser.h` is gone. The parsing
//      is the same: the same grammar, the same `CGPath` commands and the same reflected control points. The two debug
//      switches of the header (`CYLREFRESH_VERBOSE_PARSE_SVG`, `CYLREFRESH_DEBUG_PATH_CREATION`) were 0 and only guarded
//      logging that was never compiled in.
// [CN] 自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 7 步）。internal：唯一调用方是 `CYLRefreshVectorPathElement`（Swift），
//      其 API 传递 C 结构体（`CYLRefreshCurve`）与可变路径，这些原先由 Objective-C 头文件声明；现在都是 Swift 类型，
//      `CYLRefreshVectorPathsParser.h` 已删除。解析逻辑不变：相同的语法、相同的 `CGPath` 命令与相同的反射控制点。头文件中的两个调试开关
//      （`CYLREFRESH_VERBOSE_PARSE_SVG`、`CYLREFRESH_DEBUG_PATH_CREATION`）原为 0，只控制从未编译进来的日志。

import UIKit

// MARK: - The NSScanner calls of the Objective-C parser

// [EN] The parser calls the same `NSScanner` methods as the Objective-C parser did (`scanCharactersFromSet:intoString:`,
//      `scanUpToCharactersFromSet:intoString:`, `scanString:intoString:`, `scanDouble:`, `scanLocation`) on every iOS
//      version, so it reads numbers and commands exactly as before. They are called through the runtime: their Swift
//      spellings are deprecated from iOS 13 (the library supports iOS 12), and the iOS 13 replacements are other
//      implementations; the HUD reads `windows` through key-value coding for the same reason.
// [CN] 解析器在所有 iOS 版本上调用与 Objective-C 解析器相同的 `NSScanner` 方法（`scanCharactersFromSet:intoString:`、
//      `scanUpToCharactersFromSet:intoString:`、`scanString:intoString:`、`scanDouble:`、`scanLocation`），因此读取数字与命令的方式与之前
//      完全相同。它们通过运行时调用：其 Swift 写法自 iOS 13 起弃用（本库支持 iOS 12），而 iOS 13 的替代方法是另一套实现；HUD 出于同样原因
//      通过键值编码读取 `windows`。
extension Scanner {

    private typealias CYLScanSetIMP = @convention(c) (Scanner, Selector, NSCharacterSet,
                                                      AutoreleasingUnsafeMutablePointer<NSString?>?) -> ObjCBool
    private typealias CYLScanStringIMP = @convention(c) (Scanner, Selector, NSString,
                                                         AutoreleasingUnsafeMutablePointer<NSString?>?) -> ObjCBool
    private typealias CYLScanDoubleIMP = @convention(c) (Scanner, Selector, UnsafeMutablePointer<Double>?) -> ObjCBool

    private func cylScan(_ name: String, set: CharacterSet) -> String? {
        let selector = NSSelectorFromString(name)
        let function = unsafeBitCast(method(for: selector), to: CYLScanSetIMP.self)
        var result: NSString?
        return function(self, selector, set as NSCharacterSet, &result).boolValue ? result as String? : nil
    }

    // [EN] `-scanCharactersFromSet:intoString:`. [CN] `-scanCharactersFromSet:intoString:`。
    func cylScanCharacters(from set: CharacterSet) -> String? {
        cylScan("scanCharactersFromSet:intoString:", set: set)
    }

    // [EN] `-scanUpToCharactersFromSet:intoString:`. [CN] `-scanUpToCharactersFromSet:intoString:`。
    func cylScanUpToCharacters(from set: CharacterSet) -> String? {
        cylScan("scanUpToCharactersFromSet:intoString:", set: set)
    }

    // [EN] `-scanString:intoString:` without the result. [CN] 不取结果的 `-scanString:intoString:`。
    @discardableResult
    func cylScanString(_ string: String) -> Bool {
        let selector = NSSelectorFromString("scanString:intoString:")
        let function = unsafeBitCast(method(for: selector), to: CYLScanStringIMP.self)
        return function(self, selector, string as NSString, nil).boolValue
    }

    // [EN] `-scanDouble:` (CGFloat is double on every supported device). [CN] `-scanDouble:`（所有支持的设备上 CGFloat 都是 double）。
    func cylScanDouble() -> Double? {
        let selector = NSSelectorFromString("scanDouble:")
        let function = unsafeBitCast(method(for: selector), to: CYLScanDoubleIMP.self)
        var value: Double = 0
        return function(self, selector, &value).boolValue ? value : nil
    }

    // [EN] `scanLocation -= count`, through key-value coding. [CN] 通过键值编码执行 `scanLocation -= count`。
    func cylMoveBack(_ count: Int) {
        if let location = value(forKey: "scanLocation") as? Int {
            setValue(location - count, forKey: "scanLocation")
        }
    }
}

// MARK: - Curves

// [EN] The kind of the last segment, for the reflected control point of the smooth commands (S, T).
// [CN] 上一段的类型，用于平滑命令（S、T）的反射控制点。
enum CYLRefreshCurveType {
    case point
    case cubic
    case quadratic
}

// [EN] The last segment of a path: its type, its two control points and its end point.
// [CN] 路径的上一段：类型、两个控制点与终点。
struct CYLRefreshCurve {
    var type: CYLRefreshCurveType
    var c1: CGPoint
    var c2: CGPoint
    var p: CGPoint

    static func point(_ p: CGPoint) -> CYLRefreshCurve {
        CYLRefreshCurve(type: .point, c1: p, c2: p, p: p)
    }

    var reflectedControlPoint: CGPoint {
        CGPoint(x: p.x + (p.x - c2.x), y: p.y + (p.y - c2.y))
    }
}

// MARK: - Parser

// [EN] Reads SVG path data into a `CGMutablePath`, one command at a time.
// [CN] 逐条命令把 SVG 路径数据读入 `CGMutablePath`。
enum CYLRefreshVectorPathsParser {

    // wsp: (#x20 | #x9 | #xD | #xA)
    private static let whitespace = CharacterSet(charactersIn: "\u{20}\u{9}\u{D}\u{A}")

    static func startingCurve() -> CYLRefreshCurve {
        .point(.zero)
    }

    static func readWhitespace(_ scanner: Scanner) {
        // [EN] The original drains an autorelease pool here: Apple's scanCharactersFromSet makes many temporary objects.
        // [CN] 原实现在这里使用自动释放池：Apple 的 scanCharactersFromSet 会产生大量临时对象。
        autoreleasepool {
            _ = scanner.cylScanCharacters(from: whitespace)
        }
    }

    static func readCommaAndWhitespace(_ scanner: Scanner) {
        readWhitespace(scanner)
        scanner.cylScanString(",")
        readWhitespace(scanner)
    }

    // moveto-drawto-command-groups:
    //   moveto-drawto-command-group | moveto-drawto-command-group wsp* moveto-drawto-command-groups
    static func readMovetoDrawToCmdGroups(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                          isRelative: Bool) -> CYLRefreshCurve {
        var lastCurve = readMovetoDrawto(scanner, path: path, relativeTo: origin, isRelative: isRelative)
        readWhitespace(scanner)
        while !scanner.isAtEnd {
            readWhitespace(scanner)
            // FIXME: wasn't originally, but maybe should be: origin = isRelative ? lastCoord : origin;
            lastCurve = readMovetoDrawto(scanner, path: path, relativeTo: origin, isRelative: isRelative)
        }
        return lastCurve
    }

    // moveto-drawto-command-group: moveto wsp* drawto-commands?
    static func readMovetoDrawto(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                 isRelative: Bool) -> CYLRefreshCurve {
        let lastCurve = readMoveto(scanner, path: path, relativeTo: origin, isRelative: isRelative)
        readWhitespace(scanner)
        return lastCurve
    }

    // moveto: ( "M" | "m" ) wsp* moveto-argument-sequence
    static func readMoveto(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                           isRelative: Bool) -> CYLRefreshCurve {
        guard scanner.cylScanCharacters(from: CharacterSet(charactersIn: "Mm")) != nil else {
            assertionFailure("failed to scan move to command")
            return .point(origin)
        }
        readWhitespace(scanner)
        return readMovetoArgumentSequence(scanner, path: path, relativeTo: origin, isRelative: isRelative)
    }

    // moveto-argument-sequence: coordinate-pair | coordinate-pair comma-wsp? lineto-argument-sequence
    static func readMovetoArgumentSequence(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                           isRelative: Bool) -> CYLRefreshCurve {
        var coord = readCoordinatePair(scanner)
        coord.x += origin.x
        coord.y += origin.y
        path.move(to: coord)
        readCommaAndWhitespace(scanner)
        if scanner.isAtEnd {
            return .point(coord)
        }
        return readLinetoArgumentSequence(scanner, path: path, relativeTo: isRelative ? coord : origin, isRelative: isRelative)
    }

    // coordinate-pair: coordinate comma-wsp? coordinate
    static func readCoordinatePair(_ scanner: Scanner) -> CGPoint {
        var p = CGPoint.zero
        p.x = readCoordinate(scanner)
        readCommaAndWhitespace(scanner)
        p.y = readCoordinate(scanner)
        return p
    }

    static func readCoordinate(_ scanner: Scanner) -> CGFloat {
        guard let value = scanner.cylScanDouble() else {
            assertionFailure("invalid coord")
            return 0
        }
        return CGFloat(value)
    }

    // lineto: ( "L" | "l" ) wsp* lineto-argument-sequence
    static func readLineToCmd(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                              isRelative: Bool) -> CYLRefreshCurve {
        guard scanner.cylScanCharacters(from: CharacterSet(charactersIn: "Ll")) != nil else {
            assertionFailure("failed to scan line to command")
            return .point(origin)
        }
        readWhitespace(scanner)
        return readLinetoArgumentSequence(scanner, path: path, relativeTo: origin, isRelative: isRelative)
    }

    // lineto-argument-sequence: coordinate-pair | coordinate-pair comma-wsp? lineto-argument-sequence
    static func readLinetoArgumentSequence(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                           isRelative: Bool) -> CYLRefreshCurve {
        var origin = origin
        var p = readCoordinatePair(scanner)
        var coord = CGPoint(x: p.x + origin.x, y: p.y + origin.y)
        path.addLine(to: coord)
        readCommaAndWhitespace(scanner)
        while !scanner.isAtEnd {
            origin = isRelative ? coord : origin
            p = readCoordinatePair(scanner)
            coord = CGPoint(x: p.x + origin.x, y: p.y + origin.y)
            path.addLine(to: coord)
            readCommaAndWhitespace(scanner)
        }
        return .point(coord)
    }

    // quadratic-bezier-curveto: ( "Q" | "q" ) wsp* quadratic-bezier-curveto-argument-sequence
    static func readQuadraticCurveToCmd(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                        isRelative: Bool) -> CYLRefreshCurve {
        guard scanner.cylScanCharacters(from: CharacterSet(charactersIn: "Qq")) != nil else {
            assertionFailure("failed to scan quadratic curve to command")
            return .point(origin)
        }
        readWhitespace(scanner)
        return readQuadraticCurvetoArgumentSequence(scanner, path: path, relativeTo: origin, isRelative: isRelative)
    }

    // quadratic-bezier-curveto-argument-sequence:
    //   quadratic-bezier-curveto-argument | quadratic-bezier-curveto-argument comma-wsp? quadratic-bezier-curveto-argument-sequence
    static func readQuadraticCurvetoArgumentSequence(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                                     isRelative: Bool) -> CYLRefreshCurve {
        var curve = readQuadraticCurvetoArgument(scanner, path: path, relativeTo: origin)
        while !scanner.isAtEnd {
            curve = readQuadraticCurvetoArgument(scanner, path: path, relativeTo: isRelative ? curve.p : origin)
        }
        return curve
    }

    // quadratic-bezier-curveto-argument: coordinate-pair comma-wsp? coordinate-pair
    static func readQuadraticCurvetoArgument(_ scanner: Scanner, path: CGMutablePath,
                                             relativeTo origin: CGPoint) -> CYLRefreshCurve {
        var c1 = readCoordinatePair(scanner)
        c1.x += origin.x
        c1.y += origin.y
        readCommaAndWhitespace(scanner)
        var p = readCoordinatePair(scanner)
        p.x += origin.x
        p.y += origin.y
        readCommaAndWhitespace(scanner)
        path.addQuadCurve(to: p, control: c1)
        return CYLRefreshCurve(type: .quadratic, c1: c1, c2: c1, p: p)
    }

    // smooth-quadratic-bezier-curveto: ( "T" | "t" ) wsp* smooth-quadratic-bezier-curveto-argument-sequence
    static func readSmoothQuadraticCurveToCmd(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                              withPrevCurve prevCurve: CYLRefreshCurve) -> CYLRefreshCurve {
        guard scanner.cylScanCharacters(from: CharacterSet(charactersIn: "Tt")) != nil else {
            assertionFailure("failed to scan smooth quadratic curve to command")
            return prevCurve
        }
        readWhitespace(scanner)
        return readSmoothQuadraticCurvetoArgumentSequence(scanner, path: path, relativeTo: origin, withPrevCurve: prevCurve)
    }

    // smooth-quadratic-bezier-curveto-argument-sequence:
    //   smooth-quadratic-bezier-curveto-argument
    //   | smooth-quadratic-bezier-curveto-argument comma-wsp? smooth-quadratic-bezier-curveto-argument-sequence
    static func readSmoothQuadraticCurvetoArgumentSequence(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                                           withPrevCurve prevCurve: CYLRefreshCurve) -> CYLRefreshCurve {
        var curve = readSmoothQuadraticCurvetoArgument(scanner, path: path, relativeTo: origin, withPrevCurve: prevCurve)
        if !scanner.isAtEnd {
            curve = readSmoothQuadraticCurvetoArgumentSequence(scanner, path: path, relativeTo: curve.p, withPrevCurve: curve)
        }
        return curve
    }

    // smooth-quadratic-bezier-curveto-argument: coordinate-pair comma-wsp? coordinate-pair
    static func readSmoothQuadraticCurvetoArgument(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                                   withPrevCurve prevCurve: CYLRefreshCurve) -> CYLRefreshCurve {
        let c2 = prevCurve.type == .quadratic ? prevCurve.reflectedControlPoint : prevCurve.p
        // this coordinate is never used, but c2 is better/safer than CGPointZero
        let c1 = c2
        var p = readCoordinatePair(scanner)
        p.x += origin.x
        p.y += origin.y
        readCommaAndWhitespace(scanner)
        path.addQuadCurve(to: p, control: c2)
        return CYLRefreshCurve(type: .quadratic, c1: c1, c2: c2, p: p)
    }

    // curveto: ( "C" | "c" ) wsp* curveto-argument-sequence
    static func readCurveToCmd(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                               isRelative: Bool) -> CYLRefreshCurve {
        guard scanner.cylScanCharacters(from: CharacterSet(charactersIn: "Cc")) != nil else {
            assertionFailure("failed to scan curve to command")
            return .point(origin)
        }
        readWhitespace(scanner)
        return readCurvetoArgumentSequence(scanner, path: path, relativeTo: origin, isRelative: isRelative)
    }

    // curveto-argument-sequence: curveto-argument | curveto-argument comma-wsp? curveto-argument-sequence
    static func readCurvetoArgumentSequence(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                            isRelative: Bool) -> CYLRefreshCurve {
        var curve = readCurvetoArgument(scanner, path: path, relativeTo: origin)
        while !scanner.isAtEnd {
            let newOrigin = isRelative ? curve.p : origin
            curve = readCurvetoArgument(scanner, path: path, relativeTo: newOrigin)
        }
        return curve
    }

    // curveto-argument: coordinate-pair comma-wsp? coordinate-pair comma-wsp? coordinate-pair
    static func readCurvetoArgument(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint) -> CYLRefreshCurve {
        var c1 = readCoordinatePair(scanner)
        c1.x += origin.x
        c1.y += origin.y
        readCommaAndWhitespace(scanner)
        var c2 = readCoordinatePair(scanner)
        c2.x += origin.x
        c2.y += origin.y
        readCommaAndWhitespace(scanner)
        var p = readCoordinatePair(scanner)
        p.x += origin.x
        p.y += origin.y
        readCommaAndWhitespace(scanner)
        path.addCurve(to: p, control1: c1, control2: c2)
        return CYLRefreshCurve(type: .cubic, c1: c1, c2: c2, p: p)
    }

    // smooth-curveto: ( "S" | "s" ) wsp* smooth-curveto-argument-sequence
    static func readSmoothCurveToCmd(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                     withPrevCurve prevCurve: CYLRefreshCurve, isRelative: Bool) -> CYLRefreshCurve {
        let ok = scanner.cylScanCharacters(from: CharacterSet(charactersIn: "Ss")) != nil
        assert(ok, "failed to scan smooth curve to command")
        if !ok { return prevCurve }
        readWhitespace(scanner)
        return readSmoothCurvetoArgumentSequence(scanner, path: path, relativeTo: origin, withPrevCurve: prevCurve,
                                                 isRelative: isRelative)
    }

    // smooth-curveto-argument-sequence:
    //   smooth-curveto-argument | smooth-curveto-argument comma-wsp? smooth-curveto-argument-sequence
    static func readSmoothCurvetoArgumentSequence(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                                  withPrevCurve prevCurve: CYLRefreshCurve,
                                                  isRelative: Bool) -> CYLRefreshCurve {
        var curve = readSmoothCurvetoArgument(scanner, path: path, relativeTo: origin, withPrevCurve: prevCurve)
        if !scanner.isAtEnd {
            let newOrigin = isRelative ? curve.p : origin
            curve = readSmoothCurvetoArgumentSequence(scanner, path: path, relativeTo: newOrigin, withPrevCurve: curve,
                                                      isRelative: isRelative)
        }
        return curve
    }

    // smooth-curveto-argument: coordinate-pair comma-wsp? coordinate-pair
    static func readSmoothCurvetoArgument(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                          withPrevCurve prevCurve: CYLRefreshCurve) -> CYLRefreshCurve {
        let c1 = prevCurve.type == .cubic ? prevCurve.reflectedControlPoint : prevCurve.p
        readCommaAndWhitespace(scanner)
        var c2 = readCoordinatePair(scanner)
        c2.x += origin.x
        c2.y += origin.y
        readCommaAndWhitespace(scanner)
        var p = readCoordinatePair(scanner)
        p.x += origin.x
        p.y += origin.y
        path.addCurve(to: p, control1: c1, control2: c2)
        return CYLRefreshCurve(type: .cubic, c1: c1, c2: c2, p: p)
    }

    // vertical-lineto-argument-sequence: coordinate | coordinate comma-wsp? vertical-lineto-argument-sequence
    static func readVerticalLinetoArgumentSequence(_ scanner: Scanner, path: CGMutablePath,
                                                   relativeTo origin: CGPoint) -> CYLRefreshCurve {
        let yValue = readCoordinate(scanner)
        let vertCoord = CGPoint(x: origin.x, y: origin.y + yValue)
        let currentPoint = path.currentPoint
        let coord = CGPoint(x: currentPoint.x, y: currentPoint.y + (vertCoord.y - currentPoint.y))
        path.addLine(to: coord)
        return .point(coord)
    }

    // vertical-lineto: ( "V" | "v" ) wsp* vertical-lineto-argument-sequence
    static func readVerticalLineToCmd(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint) -> CYLRefreshCurve {
        let ok = scanner.cylScanCharacters(from: CharacterSet(charactersIn: "Vv")) != nil
        assert(ok, "failed to scan vertical line to command")
        if !ok { return .point(origin) }
        readWhitespace(scanner)
        return readVerticalLinetoArgumentSequence(scanner, path: path, relativeTo: origin)
    }

    // horizontal-lineto-argument-sequence: coordinate | coordinate comma-wsp? horizontal-lineto-argument-sequence
    static func readHorizontalLinetoArgumentSequence(_ scanner: Scanner, path: CGMutablePath,
                                                     relativeTo origin: CGPoint) -> CYLRefreshCurve {
        let xValue = readCoordinate(scanner)
        let horizCoord = CGPoint(x: origin.x + xValue, y: origin.y)
        let currentPoint = path.currentPoint
        let coord = CGPoint(x: currentPoint.x + (horizCoord.x - currentPoint.x), y: currentPoint.y)
        path.addLine(to: coord)
        return .point(coord)
    }

    // horizontal-lineto: ( "H" | "h" ) wsp* horizontal-lineto-argument-sequence
    static func readHorizontalLineToCmd(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint) -> CYLRefreshCurve {
        guard scanner.cylScanCharacters(from: CharacterSet(charactersIn: "Hh")) != nil else {
            assertionFailure("failed to scan horizontal line to command")
            return .point(origin)
        }
        readWhitespace(scanner)
        return readHorizontalLinetoArgumentSequence(scanner, path: path, relativeTo: origin)
    }

    static func readCloseCommand(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint) -> CYLRefreshCurve {
        guard scanner.cylScanCharacters(from: CharacterSet(charactersIn: "Zz")) != nil else {
            assertionFailure("failed to scan close command")
            return .point(origin)
        }
        path.closeSubpath()
        return .point(path.currentPoint)
    }

    static func readEllipticalArcArguments(_ scanner: Scanner, path: CGMutablePath, relativeTo origin: CGPoint,
                                           isRelative: Bool) -> CYLRefreshCurve {
        let ok = scanner.cylScanCharacters(from: CharacterSet(charactersIn: "Aa")) != nil
        assert(ok, "failed to scan arc to command")
        if !ok { return .point(origin) }
        var endPoint = readEllipticalArcArgumentsSequence(scanner, path: path, relativeTo: origin)
        while !scanner.isAtEnd {
            let newOrigin = isRelative ? endPoint : origin
            endPoint = readEllipticalArcArgumentsSequence(scanner, path: path, relativeTo: newOrigin)
        }
        return .point(endPoint)
    }

    // [EN] The center of the ellipse from the two points and the angle, as in
    //      http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes.
    // [CN] 由两点与角度求椭圆中心，算法见上面的链接。
    static func readEllipticalArcArgumentsSequence(_ scanner: Scanner, path: CGMutablePath,
                                                   relativeTo origin: CGPoint) -> CGPoint {
        readCommaAndWhitespace(scanner)
        let currentPt = path.currentPoint
        let x1 = currentPt.x
        let y1 = currentPt.y

        let radii = readCoordinatePair(scanner)
        var rx = abs(radii.x)
        var ry = abs(radii.y)
        readCommaAndWhitespace(scanner)

        var phi = readCoordinate(scanner)
        phi *= .pi / 180.0
        phi = CGFloat(fmod(Double(phi), 2 * Double.pi))
        readCommaAndWhitespace(scanner)

        let flags = readCoordinatePair(scanner)
        let largeArcFlag = flags.x != 0.0
        let sweepFlag = flags.y != 0.0
        readCommaAndWhitespace(scanner)

        let endPoint = readCoordinatePair(scanner)
        // end parsing

        let x2 = origin.x + endPoint.x
        let y2 = origin.y + endPoint.y

        if rx == 0 || ry == 0 {
            path.addLine(to: CGPoint(x: x2, y: y2))
            return CGPoint(x: x2, y: y2)
        }
        let cosPhi = cos(phi)
        let sinPhi = sin(phi)

        let x1p = cosPhi * (x1 - x2) / 2.0 + sinPhi * (y1 - y2) / 2.0
        let y1p = -sinPhi * (x1 - x2) / 2.0 + cosPhi * (y1 - y2) / 2.0

        let lhs: CGFloat
        do {
            var rx2 = rx * rx
            var ry2 = ry * ry
            let xp2 = x1p * x1p
            let yp2 = y1p * y1p
            let delta = xp2 / rx2 + yp2 / ry2
            if delta > 1.0 {
                rx *= sqrt(delta)
                ry *= sqrt(delta)
                rx2 = rx * rx
                ry2 = ry * ry
            }
            let sign: CGFloat = (largeArcFlag == sweepFlag) ? -1 : 1
            var numerator = rx2 * ry2 - rx2 * yp2 - ry2 * xp2
            let denom = rx2 * yp2 + ry2 * xp2
            numerator = max(0, numerator)
            lhs = denom == 0 ? 0 : sign * sqrt(numerator / denom)
        }

        let cxp = lhs * (rx * y1p) / ry
        let cyp = lhs * -((ry * x1p) / rx)

        let cx = cosPhi * cxp + -sinPhi * cyp + (x1 + x2) / 2.0
        let cy = cxp * sinPhi + cyp * cosPhi + (y1 + y2) / 2.0

        // transform our ellipse into the unit circle
        var tr = CGAffineTransform(scaleX: 1.0 / rx, y: 1.0 / ry)
        tr = tr.rotated(by: -phi)
        tr = tr.translatedBy(x: -cx, y: -cy)

        let arcPt1 = CGPoint(x: x1, y: y1).applying(tr)
        let arcPt2 = CGPoint(x: x2, y: y2).applying(tr)

        let startAngle = atan2(arcPt1.y, arcPt1.x)
        let endAngle = atan2(arcPt2.y, arcPt2.x)

        var angleDelta = endAngle - startAngle
        if sweepFlag {
            if angleDelta < 0 {
                angleDelta += 2.0 * .pi
            }
        } else if angleDelta > 0 {
            angleDelta -= 2 * .pi
        }
        // construct the inverse transform
        var trInv = CGAffineTransform(translationX: cx, y: cy)
        trInv = trInv.rotated(by: phi)
        trInv = trInv.scaledBy(x: rx, y: ry)

        // add a inversely transformed circular arc to the current path
        path.addRelativeArc(center: .zero, radius: 1.0, startAngle: startAngle, delta: angleDelta, transform: trInv)

        return CGPoint(x: x2, y: y2)
    }
}
