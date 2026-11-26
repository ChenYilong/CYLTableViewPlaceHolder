//
//  CYLRefreshRiveFinishTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The finish rule of the `rive` style (docs/Refresh-Library-Parity.md, "The rive style: creation parameters", `riveFinishTimeout`):
//       when the refresh ends the style's finish part starts at once and the header keeps its refreshing height until the animation
//       reports its end or the timeout passes, then it retracts. RiveRuntime is not part of this test target, so a drawn header that
//       behaves as `CYLRefreshRiveHeader` does (it holds for `onRefreshFinishing:` and calls `finishAnimationDidEnd()` when
//       Rive stops) stands in for it; the parameter is read by the real `CYLRefreshRiveOptions`.
//  [CN] `rive` 样式的结束规则（`riveFinishTimeout`）：刷新结束时样式的结束部分立即开始，刷新头保持刷新时的高度，直到动画报告结束或超时，
//       然后收回。测试目标不含 RiveRuntime，所以用行为与 `CYLRefreshRiveHeader` 相同的绘制刷新头代替（按 `onRefreshFinishing:` 停留，
//       Rive 停止时调用 `finishAnimationDidEnd()`）；参数由真实的 `CYLRefreshRiveOptions` 读取。
//

import XCTest
import UIKit

/// A drawn header that plays an end part like the Rive header. [CN] 像 Rive 刷新头一样播放结束部分的绘制刷新头。
final class FakeFinishingHeader: CYLRefreshDrawnHeader {
    var timeout: CGFloat = 1.5
    var finishTriggers = 0

    override func onRefreshFinished(_ success: Bool) {
        super.onRefreshFinished(success)
        finishTriggers += 1
    }

    override func onRefreshFinishing(_ success: Bool) -> CGFloat { timeout }
}

final class CYLRefreshRiveFinishTests: XCTestCase {

    private var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 600))
        window.isHidden = false
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
        super.tearDown()
    }

    private func spin(_ seconds: TimeInterval = 0.4) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
    }

    @discardableResult
    private func spin(until condition: () -> Bool, timeout: TimeInterval) -> Bool {
        let deadline = Date(timeIntervalSinceNow: timeout)
        while !condition() && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
        return condition()
    }

    private func refreshing(timeout: CGFloat) -> (CYLRefreshDrivenLayout, FakeFinishingHeader) {
        let layout = CYLRefreshDrivenLayout(frame: window.bounds)
        window.addSubview(layout)
        let header = FakeFinishingHeader(refreshingBlock: {})
        header.timeout = timeout
        layout.header = header
        layout.layoutIfNeeded()
        spin(0.1)
        let h = header.expandHeight
        layout.drive(offset: h + 5, dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(header.phase, .refreshing)
        return (layout, header)
    }

    // MARK: - The parameter

    func testTheFinishTimeoutDefaultsToOneAndAHalfSecondsAndTakesOnlyPositiveNumbers() {
        func timeout(_ extra: [String: Any]) -> TimeInterval {
            var values: [String: Any] = ["riveFile": "Bow"]
            extra.forEach { values[$0.key] = $0.value }
            return CYLRefreshRiveOptions(dictionary: values)!.finishTimeout
        }
        XCTAssertEqual(CYLRefreshRiveOptions.defaultFinishTimeout, 1.5)
        XCTAssertEqual(timeout([:]), 1.5)
        XCTAssertEqual(timeout(["riveFinishTimeout": 2.25]), 2.25)
        XCTAssertEqual(timeout(["riveFinishTimeout": 0]), 1.5, "0 means the default")
        XCTAssertEqual(timeout(["riveFinishTimeout": -1]), 1.5)
        XCTAssertEqual(timeout(["riveFinishTimeout": "2"]), 1.5, "a string is not a number")
    }

    // MARK: - The hold

    func testTheFinishPartStartsAtOnceAndTheHeaderStaysOpenUntilTheTimeout() {
        let (layout, header) = refreshing(timeout: 0.6)
        let open = header.expandHeight
        header.endRefreshing()
        XCTAssertEqual(header.finishTriggers, 1, "the finish part starts at the end of the refresh")
        XCTAssertEqual(header.phase, .finishing)
        XCTAssertTrue(header.isRefreshing, "the header is not retracting yet")
        spin(0.3)
        XCTAssertEqual(header.phase, .finishing, "still held 0.3 s after the end")
        XCTAssertEqual(header.expandHeight, open)
        XCTAssertTrue(spin(until: { header.state == .idle }, timeout: 3), "retracts once the timeout passed")
        layout.removeFromSuperview()
    }

    func testTheHeaderRetractsAtOnceWhenTheAnimationReportsItsEnd() {
        let (layout, header) = refreshing(timeout: 5)
        header.endRefreshing()
        XCTAssertEqual(header.phase, .finishing)
        spin(0.2)
        XCTAssertEqual(header.phase, .finishing)
        header.finishAnimationDidEnd()
        XCTAssertNotEqual(header.phase, .finishing)
        XCTAssertTrue(spin(until: { header.state == .idle }, timeout: 3), "retracts without waiting for the 5 s timeout")
        layout.removeFromSuperview()
    }

    func testAnEarlyEndDoesNotEndTheNextRefreshWhenTheOldTimerFires() {
        let (layout, header) = refreshing(timeout: 0.5)
        header.endRefreshing()
        header.finishAnimationDidEnd()
        XCTAssertTrue(spin(until: { header.state == .idle }, timeout: 3))
        let h = header.expandHeight
        layout.drive(offset: h + 5, dragging: true)
        layout.release()
        spin(0.1)
        XCTAssertEqual(header.phase, .refreshing)
        spin(0.7)
        XCTAssertEqual(header.phase, .refreshing, "the first hold's timer must not end the second refresh")
        header.finishAnimationDidEnd()
        XCTAssertNotEqual(header.phase, .finishing, "no hold is running while refreshing: ending it does nothing")
        XCTAssertTrue(header.isRefreshing)
        layout.removeFromSuperview()
    }

    func testTheEndOfTheAnimationWhenNoHoldRunsDoesNothing() {
        let (layout, header) = refreshing(timeout: 1)
        header.finishAnimationDidEnd()
        XCTAssertEqual(header.phase, .refreshing)
        layout.removeFromSuperview()
    }

    func testADrawnFooterHoldsForItsStyleAndRetractsWhenTheStyleReportsItsEnd() {
        let layout = CYLRefreshDrivenLayout(frame: window.bounds)
        window.addSubview(layout)
        let style = FakeFinishingHeader(refreshingBlock: {})
        style.timeout = 5
        let footer = CYLRefreshDrawnFooter(style: style)
        layout.footer = footer
        layout.layoutIfNeeded()
        spin(0.1)
        let h = footer.expandHeight
        layout.drive(offset: -(h + 5), dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(footer.phase, .refreshing)
        footer.endRefreshing()
        XCTAssertEqual(style.finishTriggers, 1)
        XCTAssertEqual(footer.phase, .finishing)
        spin(0.3)
        XCTAssertEqual(footer.phase, .finishing, "held for the style's time")
        style.finishAnimationDidEnd()
        XCTAssertTrue(spin(until: { footer.state == .idle }, timeout: 3), "the style's end releases the footer's hold")
        layout.removeFromSuperview()
    }
}
