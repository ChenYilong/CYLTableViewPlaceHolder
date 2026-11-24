//
//  CYLRefreshRiveDrawnTableTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The drawn-height table of the `rive` style (docs/Refresh-Library-Parity.md, "Rive drawn-height table", `riveDrawnTable`): linear
//       interpolation, the ends of the range, an empty table, malformed pairs and the option parsing. RiveRuntime is not part of this
//       test target, so the pure helper `CYLRefreshRiveDrawnTable` is tested, not the clip of the Rive view.
//  [CN] `rive` 样式的已绘制高度表（`riveDrawnTable`）：线性插值、范围两端、空表、格式错误的数对与选项解析。测试目标不含 RiveRuntime，
//       所以测试的是纯辅助函数 `CYLRefreshRiveDrawnTable`，而不是 Rive 视图的裁剪。
//

import XCTest

final class CYLRefreshRiveDrawnTableTests: XCTestCase {

    private let bow: [[Double]] = [[30, 0], [31.8, 0.14], [35.9, 0.43], [39.8, 0.66], [43.6, 0.82], [47.3, 0.94], [50, 1]]

    private func fraction(_ input: Double, _ table: [[Double]]? = nil) -> Double {
        CYLRefreshRiveDrawnTable.fraction(forInput: input, table: table ?? bow)
    }

    func testPairsAreReturnedExactly() {
        for pair in bow { XCTAssertEqual(fraction(pair[0]), pair[1], accuracy: 1e-9) }
    }

    func testInterpolationIsLinearBetweenPairs() {
        XCTAssertEqual(fraction(30.9), 0.07, accuracy: 1e-9)
        XCTAssertEqual(fraction(37.85), 0.545, accuracy: 1e-9)
        XCTAssertEqual(fraction(48.65), 0.97, accuracy: 1e-9)
    }

    func testBelowTheFirstPairIsTheFirstFractionAndAboveTheLastIsTheLast() {
        XCTAssertEqual(fraction(0), 0)
        XCTAssertEqual(fraction(10), 0)
        XCTAssertEqual(fraction(50.0001), 1)
        XCTAssertEqual(fraction(100), 1)
        XCTAssertEqual(fraction(5, [[20, 0.3], [40, 0.9]]), 0.3)
        XCTAssertEqual(fraction(60, [[20, 0.3], [40, 0.9]]), 0.9)
    }

    func testAnEmptyTableDoesNotClip() {
        XCTAssertEqual(fraction(0, []), 1)
        XCTAssertEqual(fraction(42, []), 1)
    }

    func testASinglePairIsConstant() {
        XCTAssertEqual(fraction(0, [[30, 0.5]]), 0.5)
        XCTAssertEqual(fraction(90, [[30, 0.5]]), 0.5)
    }

    func testTwoPairsWithTheSameInputDoNotDivideByZero() {
        let table: [[Double]] = [[30, 0], [30, 1]]
        XCTAssertEqual(fraction(29, table), 0)
        XCTAssertEqual(fraction(30, table), 0)
        XCTAssertEqual(fraction(31, table), 1)
    }

    func testParseSortsByInputAndClampsFractions() {
        let result = CYLRefreshRiveDrawnTable.parse([[40, 2.0], [10, -1], [20, 0.5]])
        XCTAssertEqual(result.pairs, [[10, 0], [20, 0.5], [40, 1]])
        XCTAssertNil(result.reason)
    }

    func testParseDropsMalformedPairsAndSaysSo() {
        let result = CYLRefreshRiveDrawnTable.parse([[30, 0], [1], "x", [1, 2, 3], ["a", 1], [Double.nan, 1], [50, 1]])
        XCTAssertEqual(result.pairs, [[30, 0], [50, 1]])
        XCTAssertEqual(result.reason, "5 malformed pairs dropped")
        XCTAssertEqual(CYLRefreshRiveDrawnTable.parse([[30, 0], [1]]).reason, "1 malformed pair dropped")
    }

    func testParseIgnoresAWholeValueThatIsNotUsable() {
        XCTAssertEqual(CYLRefreshRiveDrawnTable.parse(nil).pairs.count, 0)
        XCTAssertNil(CYLRefreshRiveDrawnTable.parse(nil).reason)
        XCTAssertEqual(CYLRefreshRiveDrawnTable.parse("30").reason, "not an array")
        XCTAssertEqual(CYLRefreshRiveDrawnTable.parse([Any]()).reason, "empty")
        XCTAssertEqual(CYLRefreshRiveDrawnTable.parse([[1], "x"]).reason, "no valid pair")
        XCTAssertTrue(CYLRefreshRiveDrawnTable.parse([[1], "x"]).pairs.isEmpty)
    }

    func testTheOptionsReadRiveDrawnTable() {
        let options = CYLRefreshRiveOptions(dictionary: ["riveFile": "Bow", "riveDrawnTable": [[50, 1], [30, 0], [9]]])
        XCTAssertEqual(options?.drawnTable.pairs, [[30, 0], [50, 1]])
        XCTAssertEqual(options?.drawnTable.reason, "1 malformed pair dropped")
        let plain = CYLRefreshRiveOptions(dictionary: ["riveFile": "Bow"])
        XCTAssertEqual(plain?.drawnTable.pairs.count, 0)
        XCTAssertNil(plain?.drawnTable.reason)
    }

    func testSlackIsTheUndrawnPartOfTheHeader() {
        XCTAssertEqual(CYLRefreshRiveDrawnTable.slack(headerHeight: 200, fraction: 1), 0, accuracy: 0.0001)
        XCTAssertEqual(CYLRefreshRiveDrawnTable.slack(headerHeight: 200, fraction: 0.25), 150, accuracy: 0.0001)
        XCTAssertEqual(CYLRefreshRiveDrawnTable.slack(headerHeight: 80, fraction: 0), 80, accuracy: 0.0001)
    }

    func testSlackClampsAndIgnoresBadInput() {
        XCTAssertEqual(CYLRefreshRiveDrawnTable.slack(headerHeight: 100, fraction: 2), 0, accuracy: 0.0001)
        XCTAssertEqual(CYLRefreshRiveDrawnTable.slack(headerHeight: 100, fraction: -1), 100, accuracy: 0.0001)
        XCTAssertEqual(CYLRefreshRiveDrawnTable.slack(headerHeight: 100, fraction: .nan), 0, accuracy: 0.0001)
        XCTAssertEqual(CYLRefreshRiveDrawnTable.slack(headerHeight: -5, fraction: 0.5), 0, accuracy: 0.0001)
        XCTAssertEqual(CYLRefreshRiveDrawnTable.slack(headerHeight: .infinity, fraction: 0.5), 0, accuracy: 0.0001)
    }

    func testSlackIsContinuousWhereTheFractionReachesOne() {
        let table: [[Double]] = [[30, 0], [50, 1]]
        let below = CYLRefreshRiveDrawnTable.slack(headerHeight: 180, fraction: CYLRefreshRiveDrawnTable.fraction(forInput: 49.9, table: table))
        let at = CYLRefreshRiveDrawnTable.slack(headerHeight: 180, fraction: CYLRefreshRiveDrawnTable.fraction(forInput: 50, table: table))
        XCTAssertEqual(at, 0, accuracy: 0.0001)
        XCTAssertLessThan(below, 1)
    }
}
