//
//  CYLRefreshRiveRetractTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The retract rules of the `rive` style (docs/Refresh-Library-Parity.md, "Rive drawn-height table", the end black): which styles keep their art
//       while the header retracts after a refresh, and when the retracting header counts as out of view. RiveRuntime is not part of this test target,
//       so the pure helper `CYLRefreshRiveRetract` is tested, not the Rive view.
//  [CN] `rive` 样式的收回规则：哪些样式在刷新后刷新头收回期间保持画面，以及收回中的刷新头何时算离开视野。测试目标不含 RiveRuntime，
//       所以测试的是纯辅助函数 `CYLRefreshRiveRetract`，而不是 Rive 视图。
//

import XCTest

final class CYLRefreshRiveRetractTests: XCTestCase {

    func testOnlyAScrubbedPullAnimationKeepsItsArt() {
        XCTAssertTrue(CYLRefreshRiveRetract.keepsArt(pullAnimation: "Pull", idleAnimation: nil))
        XCTAssertFalse(CYLRefreshRiveRetract.keepsArt(pullAnimation: "Pull", idleAnimation: "Idle"))
        XCTAssertFalse(CYLRefreshRiveRetract.keepsArt(pullAnimation: nil, idleAnimation: nil))
        XCTAssertFalse(CYLRefreshRiveRetract.keepsArt(pullAnimation: nil, idleAnimation: "Idle"))
    }

    func testThePresentedHeightKeepsTheHeaderInViewWhileTheModelIsAlreadyZero() {
        XCTAssertFalse(CYLRefreshRiveRetract.isOutOfView(modelHeight: 0, shownHeight: 120, elapsed: 0.1, limit: 3))
        XCTAssertFalse(CYLRefreshRiveRetract.isOutOfView(modelHeight: 200, shownHeight: 0, elapsed: 0.1, limit: 3))
    }

    func testOutOfViewWhenBothHeightsAreUnderHalfAPoint() {
        XCTAssertTrue(CYLRefreshRiveRetract.isOutOfView(modelHeight: 0, shownHeight: 0.4, elapsed: 0.5, limit: 3))
        XCTAssertTrue(CYLRefreshRiveRetract.isOutOfView(modelHeight: -0, shownHeight: 0, elapsed: 0, limit: 3))
        XCTAssertFalse(CYLRefreshRiveRetract.isOutOfView(modelHeight: 0, shownHeight: 0.5, elapsed: 0.5, limit: 3))
    }

    func testTheLimitEndsTheWaitWhateverTheHeights() {
        XCTAssertTrue(CYLRefreshRiveRetract.isOutOfView(modelHeight: 200, shownHeight: 200, elapsed: 3.01, limit: 3))
        XCTAssertFalse(CYLRefreshRiveRetract.isOutOfView(modelHeight: 200, shownHeight: 200, elapsed: 3, limit: 3))
    }
}
