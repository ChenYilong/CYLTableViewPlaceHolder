//
//  CYLRefreshStyleFactoryTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] `CYLRefreshStyleFactory`: one case per style name for the header and the footer, and the unknown-name fallback.
//  [CN] `CYLRefreshStyleFactory`：每个样式名的刷新头与刷新尾各一个用例，以及未知名称的回退。
//

import XCTest
import UIKit

final class CYLRefreshStyleFactoryTests: XCTestCase {

    private func header(_ name: String?) -> (CYLRefreshHeader, [String?]) {
        var reported = [String?]()
        let header = CYLRefreshStyleFactory.header(style: name) { reported.append($0) }
        return (header, reported)
    }

    private func footer(_ name: String?) -> (CYLRefreshFooter, [String?]) {
        var reported = [String?]()
        let footer = CYLRefreshStyleFactory.footer(style: name) { reported.append($0) }
        return (footer, reported)
    }

    func testClassic() {
        XCTAssertTrue(header("classic").0 is CYLRefreshNormalHeader)
        XCTAssertTrue(footer("classic").0 is CYLRefreshBackNormalFooter)
        XCTAssertTrue(header("classic").1.isEmpty && footer("classic").1.isEmpty)
    }

    func testCupertino() {
        XCTAssertTrue(header("cupertino").0 is CYLRefreshCupertinoHeader)
        XCTAssertTrue(footer("cupertino").0 is CYLRefreshCupertinoFooter)
    }

    func testMaterial() {
        XCTAssertTrue(header("material").0 is CYLRefreshMaterialHeader)
        XCTAssertTrue(footer("material").0 is CYLRefreshMaterialFooter)
    }

    func testBezierRadar() {
        XCTAssertTrue(header("bezierRadar").0 is CYLRefreshBezierRadarHeader)
        XCTAssertTrue(footer("bezierRadar").0 is CYLRefreshBezierRadarFooter)
    }

    func testBezierCircleHasNoDrawnFooterAndFallsBackQuietly() {
        XCTAssertTrue(header("bezierCircle").0 is CYLRefreshBezierCircleHeader)
        let (footer, reported) = footer("bezierCircle")
        XCTAssertTrue(footer is CYLRefreshBackNormalFooter)
        XCTAssertTrue(reported.isEmpty)
    }

    func testDelivery() {
        XCTAssertTrue(header("delivery").0 is CYLRefreshDeliveryHeader)
        XCTAssertTrue(footer("delivery").0 is CYLRefreshDeliveryFooter)
    }

    func testPhoenix() {
        XCTAssertTrue(header("phoenix").0 is CYLRefreshPhoenixHeader)
        XCTAssertTrue(footer("phoenix").0 is CYLRefreshPhoenixFooter)
    }

    func testTaurus() {
        XCTAssertTrue(header("taurus").0 is CYLRefreshTaurusHeader)
        XCTAssertTrue(footer("taurus").0 is CYLRefreshTaurusFooter)
    }

    func testAnUnknownOrMissingNameMakesTheClassicOneAndIsReportedOnce() {
        for name in ["rainbow", "", "Classic", nil] {
            let (h, hReported) = header(name)
            XCTAssertTrue(h is CYLRefreshNormalHeader, "\(String(describing: name))")
            XCTAssertEqual(hReported.count, 1)
            XCTAssertEqual(hReported.first ?? "x", name)
            let (f, fReported) = footer(name)
            XCTAssertTrue(f is CYLRefreshBackNormalFooter, "\(String(describing: name))")
            XCTAssertEqual(fReported.count, 1)
        }
        // [EN] No report block: still no crash. [CN] 没有报告块：同样不崩溃。
        XCTAssertTrue(CYLRefreshStyleFactory.header(style: "rainbow") is CYLRefreshNormalHeader)
    }

    func testEveryListedNameIsKnown() {
        for name in CYLRefreshStyleFactory.styleNames {
            XCTAssertTrue(header(name).1.isEmpty, name)
            XCTAssertTrue(footer(name).1.isEmpty, name)
        }
        XCTAssertEqual(CYLRefreshStyleFactory.styleNames.count, 8)
    }

    func testTheEnumMirrorsAndroidsCYLRefreshStyle() {
        XCTAssertEqual(CYLRefreshStyle.allCases.map { $0.key },
                       ["classic", "cupertino", "material", "bezierRadar", "bezierCircle", "delivery", "phoenix", "taurus"])
        XCTAssertEqual(CYLRefreshStyle.fromKey("phoenix"), .phoenix)
        XCTAssertNil(CYLRefreshStyle.fromKey("rainbow"))
        XCTAssertNil(CYLRefreshStyle.fromKey(nil))
        XCTAssertNil(CYLRefreshStyle.fromKey(3))
        XCTAssertTrue(CYLRefreshStyle.taurus.newHeader() is CYLRefreshTaurusHeader)
        XCTAssertTrue(CYLRefreshStyle.taurus.newFooter() is CYLRefreshTaurusFooter)
    }
}
