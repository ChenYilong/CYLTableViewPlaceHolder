//
//  CYLRefreshRiveFinishLatchTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The gate between Rive's paused / stopped report and the end of the finish hold (`CYLRefreshRiveFinishLatch`, used by
//       `CYLRefreshRiveHeader`; docs/Refresh-Library-Parity.md, "The rive style: creation parameters", `riveFinishTimeout`):
//       a report before the finish is ignored, the first one during the finish ends the hold early and only once, the end of the
//       hold disarms the gate, and a hold that ended early (or by its timer) never ends the next refresh, whose own finish arms
//       the gate again. RiveRuntime is not part of this test target, so a drawn header wired to the gate exactly as the Rive
//       header is (armed in `onStatus(.finishing)`, disarmed in `.idle`, the report calls `cyl_finishAnimationDidEnd()`) stands in
//       for it. Not covered here: Rive's own callback (`CYLRiveStopReportingViewModel.player(pausedWithModel:)` /
//       `player(stoppedWithModel:)`) reaching `onStop`, which needs RiveRuntime.
//  [CN] Rive 的暂停 / 停止报告与结束停留之间的开关（`CYLRefreshRiveFinishLatch`，由 `CYLRefreshRiveHeader` 使用）：结束之前的报告被忽略，
//       结束期间的第一个报告让停留提前结束且只有一次，停留结束时开关关闭，提前结束（或由定时器结束）的停留不会结束下一次刷新，
//       下一次刷新的结束会重新启动开关。测试目标不含 RiveRuntime，所以用与 Rive 刷新头接线方式相同的绘制刷新头代替
//       （`onStatus(.finishing)` 启动、`.idle` 关闭，报告调用 `cyl_finishAnimationDidEnd()`）。这里没有覆盖：Rive 自己的回调
//       （`CYLRiveStopReportingViewModel.player(pausedWithModel:)` / `player(stoppedWithModel:)`）到达 `onStop`，那需要 RiveRuntime。
//

import XCTest
import UIKit

/// A drawn header wired to `CYLRefreshRiveFinishLatch` as the Rive header is. [CN] 与 Rive 刷新头相同方式接入开关的绘制刷新头。
final class LatchedFinishingHeader: CYLRefreshDrawnHeader {
    var timeout: CGFloat = 5
    var playsFinish = true
    private var latch = CYLRefreshRiveFinishLatch()

    override func onStatus(_ oldStatus: CYLRefreshPhase, changed status: CYLRefreshPhase) {
        super.onStatus(oldStatus, changed: status)
        switch status {
        case .finishing: latch.arm(playsFinish: playsFinish)
        case .idle: latch.disarm()
        default: break
        }
    }

    override func onRefreshFinishing(_ success: Bool) -> CGFloat {
        latch.isArmed ? timeout : super.onRefreshFinishing(success)
    }

    /// What `CYLRiveStopReportingViewModel.onStop` triggers. [CN] `CYLRiveStopReportingViewModel.onStop` 触发的内容。
    func riveStopped() {
        guard latch.consumeStop() else { return }
        cyl_finishAnimationDidEnd()
    }

    var isArmed: Bool { latch.isArmed }
}

final class CYLRefreshRiveFinishLatchTests: XCTestCase {

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

    private func spin(_ seconds: TimeInterval = 0.3) {
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

    private func pullAndRelease(_ layout: CYLRefreshDrivenLayout, _ header: LatchedFinishingHeader) {
        let h = header.expandHeight
        layout.drive(offset: h + 5, dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(header.phase, .refreshing)
    }

    private func refreshing(timeout: CGFloat, playsFinish: Bool = true) -> (CYLRefreshDrivenLayout, LatchedFinishingHeader) {
        let layout = CYLRefreshDrivenLayout(frame: window.bounds)
        window.addSubview(layout)
        let header = LatchedFinishingHeader(refreshingBlock: {})
        header.timeout = timeout
        header.playsFinish = playsFinish
        layout.header = header
        layout.layoutIfNeeded()
        spin(0.1)
        pullAndRelease(layout, header)
        return (layout, header)
    }

    // MARK: - The gate alone

    func testAReportBeforeTheFinishIsIgnored() {
        var latch = CYLRefreshRiveFinishLatch()
        XCTAssertFalse(latch.isArmed)
        XCTAssertFalse(latch.consumeStop(), "the pull, the loading loop: a stop does not end anything")
    }

    func testTheFirstReportAfterTheFinishEndsTheHoldAndOnlyOnce() {
        var latch = CYLRefreshRiveFinishLatch()
        latch.arm(playsFinish: true)
        XCTAssertTrue(latch.isArmed)
        XCTAssertTrue(latch.consumeStop())
        XCTAssertFalse(latch.isArmed)
        XCTAssertFalse(latch.consumeStop(), "Rive reports paused and then stopped: the second one is ignored")
    }

    func testAStyleWithoutAFinishPartNeverArms() {
        var latch = CYLRefreshRiveFinishLatch()
        latch.arm(playsFinish: false)
        XCTAssertFalse(latch.isArmed)
        XCTAssertFalse(latch.consumeStop())
    }

    func testDisarmingDropsAReportThatIsStillComing() {
        var latch = CYLRefreshRiveFinishLatch()
        latch.arm(playsFinish: true)
        latch.disarm()
        XCTAssertFalse(latch.consumeStop())
    }

    func testTheNextFinishArmsTheGateAgain() {
        var latch = CYLRefreshRiveFinishLatch()
        latch.arm(playsFinish: true)
        XCTAssertTrue(latch.consumeStop())
        latch.arm(playsFinish: true)
        XCTAssertTrue(latch.consumeStop())
    }

    // MARK: - In a header

    func testAReportWhileRefreshingDoesNotEndTheRefresh() {
        let (layout, header) = refreshing(timeout: 5)
        XCTAssertFalse(header.isArmed)
        header.riveStopped()
        XCTAssertEqual(header.phase, .refreshing)
        XCTAssertTrue(header.isRefreshing)
        layout.removeFromSuperview()
    }

    func testTheReportEndsTheFinishHoldEarlyAndASecondReportDoesNothing() {
        let (layout, header) = refreshing(timeout: 5)
        header.endRefreshing()
        XCTAssertEqual(header.phase, .finishing)
        XCTAssertTrue(header.isArmed, "the finish trigger arms the gate before the hold's time is asked")
        spin(0.2)
        XCTAssertEqual(header.phase, .finishing, "held while Rive plays the end part")
        header.riveStopped()
        XCTAssertNotEqual(header.phase, .finishing)
        XCTAssertFalse(header.isArmed)
        XCTAssertTrue(spin(until: { header.state == .idle }, timeout: 3), "retracts without waiting for the 5 s timeout")
        header.riveStopped()
        XCTAssertEqual(header.state, .idle, "the late second report changes nothing")
        layout.removeFromSuperview()
    }

    func testAStyleWithoutAFinishPartHoldsForItsFinishDurationWhateverIsReported() {
        let (layout, header) = refreshing(timeout: 5, playsFinish: false)
        header.finishDuration = 1
        header.endRefreshing()
        XCTAssertEqual(header.phase, .finishing)
        XCTAssertFalse(header.isArmed)
        header.riveStopped()
        XCTAssertEqual(header.phase, .finishing, "no finish part: a stop is not the end of one")
        layout.removeFromSuperview()
    }

    func testAHoldEndedEarlyByTheReportDoesNotEndTheNextRefresh() {
        let (layout, header) = refreshing(timeout: 0.6)
        header.endRefreshing()
        spin(0.1)
        header.riveStopped()
        XCTAssertTrue(spin(until: { header.state == .idle }, timeout: 3))
        pullAndRelease(layout, header)
        spin(0.8)
        XCTAssertEqual(header.phase, .refreshing, "the first hold's timer (0.6 s) must not end the second refresh")
        header.riveStopped()
        XCTAssertEqual(header.phase, .refreshing, "a stale report while refreshing is ignored")
        header.endRefreshing()
        XCTAssertEqual(header.phase, .finishing)
        XCTAssertTrue(header.isArmed, "the second refresh's own finish arms the gate again")
        header.riveStopped()
        XCTAssertNotEqual(header.phase, .finishing, "and its report ends its hold early")
        XCTAssertTrue(spin(until: { header.state == .idle }, timeout: 3))
        layout.removeFromSuperview()
    }

    func testAHoldEndedByItsTimerDisarmsTheGateSoALateReportIsIgnored() {
        let (layout, header) = refreshing(timeout: 0.3)
        header.endRefreshing()
        XCTAssertTrue(spin(until: { header.state == .idle }, timeout: 3), "the timer ends the hold")
        XCTAssertFalse(header.isArmed)
        pullAndRelease(layout, header)
        header.riveStopped()
        XCTAssertEqual(header.phase, .refreshing, "a report that comes after the timer does not end the next refresh")
        layout.removeFromSuperview()
    }
}
