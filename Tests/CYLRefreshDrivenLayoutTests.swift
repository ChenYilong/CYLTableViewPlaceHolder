//
//  CYLRefreshDrivenLayoutTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The driven mode (CYLRefreshDrivenLayout): ports of Android's CYLRefreshDrivenLayoutTest, with the pull fed from
//       outside instead of touches.
//  [CN] 驱动模式（CYLRefreshDrivenLayout）：移植自 Android 的 CYLRefreshDrivenLayoutTest，下拉由外部输入而不是触摸。
//

import XCTest
import UIKit

final class CYLRefreshDrivenLayoutTests: XCTestCase {

    private var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 600))
        window.isHidden = false
    }

    private func spin(_ seconds: TimeInterval = 0.5) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
    }

    private func driven(_ header: CYLRefreshHeader = CYLRefreshHeader(refreshingBlock: {})) -> (CYLRefreshDrivenLayout, CYLRefreshHeader) {
        let layout = CYLRefreshDrivenLayout(frame: window.bounds)
        window.addSubview(layout)
        layout.header = header
        layout.layoutIfNeeded()
        spin(0.1)
        return (layout, header)
    }

    func testPullingWalksIdleToPullToRefreshToReleaseToRefreshAndReportsThePercent() {
        let (layout, header) = driven()
        let h = header.expandHeight
        var phases = [CYLRefreshPhase]()
        header.addPhaseObserver { _, _, new in phases.append(new) }
        layout.drive(offset: h / 3, dragging: true)
        XCTAssertEqual(header.phase, .pullToRefresh)
        XCTAssertEqual(header.state, .idle)
        XCTAssertEqual(header.pullingPercent, 1.0 / 3 / header.triggerRate, accuracy: 0.05)
        layout.drive(offset: h + 5, dragging: true)
        XCTAssertEqual(header.phase, .releaseToRefresh)
        XCTAssertEqual(header.state, .pulling)
        layout.drive(offset: 0, dragging: true)
        XCTAssertEqual(header.phase, .idle)
        XCTAssertEqual(phases, [.pullToRefresh, .releaseToRefresh, .idle])
    }

    func testReleaseStartsRefreshingOnceAndEndRefreshingRecordsTheResult() {
        var calls = 0
        let (layout, header) = driven(CYLRefreshHeader(refreshingBlock: { calls += 1 }))
        layout.drive(offset: header.expandHeight + 5, dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(header.phase, .refreshing)
        XCTAssertTrue(header.isRefreshing)
        XCTAssertEqual(calls, 1)
        header.endRefreshing(success: false)
        XCTAssertFalse(header.lastRefreshSucceeded)
        spin(1.5)
        XCTAssertEqual(header.phase, .idle)
    }

    func testAShortPullIsCanceledOnRelease() {
        let (layout, header) = driven()
        layout.drive(offset: header.expandHeight / 4, dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(header.phase, .idle)
        XCTAssertFalse(header.isRefreshing)
    }

    func testRefreshEnabledFalseNeverArms() {
        let (layout, header) = driven()
        header.isRefreshEnabled = false
        layout.drive(offset: header.expandHeight + 20, dragging: true)
        // [EN] A disabled header never arms: its state stays idle (the phase reports the pull, as under a finger).
        // [CN] 关闭的刷新头永远不会就绪：状态保持 idle（阶段仍报告下拉，与手指下拉时相同）。
        XCTAssertEqual(header.state, .idle)
        XCTAssertNotEqual(header.phase, .releaseToRefresh)
        layout.release()
        spin()
        XCTAssertFalse(header.isRefreshing)
    }

    func testOnEdgeIgnoresAPullThatDidNotStartAtTheEdge() {
        let (layout, header) = driven()
        header.triggerMode = .onEdge
        layout.drive(offset: header.expandHeight + 20, dragging: true, startedAtEdge: false)
        XCTAssertEqual(header.state, .idle)
        XCTAssertNotEqual(header.phase, .releaseToRefresh)
        layout.drive(offset: 0, dragging: false)
        layout.drive(offset: header.expandHeight + 20, dragging: true, startedAtEdge: true)
        XCTAssertEqual(header.phase, .releaseToRefresh)
    }

    func testTriggersWhenReachedRefreshesWithoutARelease() {
        let (layout, header) = driven()
        header.triggersWhenReached = true
        layout.drive(offset: header.expandHeight + 5, dragging: true)
        spin()
        XCTAssertTrue(header.isRefreshing)
    }

    func testPhaseObserversCanBeRemoved() {
        let (layout, header) = driven()
        var count = 0
        let token = header.addPhaseObserver { _, _, _ in count += 1 }
        layout.drive(offset: 10, dragging: true)
        header.removePhaseObserver(token)
        layout.drive(offset: 0, dragging: true)
        XCTAssertEqual(count, 1)
    }
}
