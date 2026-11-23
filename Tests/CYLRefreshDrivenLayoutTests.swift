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

    // MARK: - Footer (ports of the footer cases of Android's CYLRefreshDrivenLayoutTest, commit b87c5c20)

    private func drivenFooter(_ footer: CYLRefreshFooter) -> CYLRefreshDrivenLayout {
        let layout = CYLRefreshDrivenLayout(frame: window.bounds)
        window.addSubview(layout)
        layout.footer = footer
        layout.layoutIfNeeded()
        spin(0.1)
        return layout
    }

    func testANegativeOffsetPullsTheFooterThroughPullToRefreshToReleaseToRefresh() {
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
        let layout = drivenFooter(footer)
        let h = footer.expandHeight
        var phases = [CYLRefreshPhase]()
        footer.addPhaseObserver { _, _, new in phases.append(new) }
        layout.drive(offset: -(h / 3), dragging: true)
        XCTAssertEqual(footer.phase, .pullToRefresh)
        XCTAssertEqual(footer.state, .idle)
        layout.drive(offset: -(h + 5), dragging: true)
        XCTAssertEqual(footer.phase, .releaseToRefresh)
        XCTAssertEqual(footer.state, .pulling)
        layout.drive(offset: 0, dragging: true)
        XCTAssertEqual(footer.phase, .idle)
        XCTAssertEqual(phases, [.pullToRefresh, .releaseToRefresh, .idle])
        XCTAssertEqual(layout.footer, footer)
        XCTAssertNil(layout.header)
    }

    func testReleasingAnArmedFooterLoadsOnceAndAShortPullIsCanceled() {
        var calls = 0
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: { calls += 1 })
        footer.finishDuration = 0.01
        let layout = drivenFooter(footer)
        layout.drive(offset: -(footer.expandHeight / 2), dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(footer.phase, .idle)
        XCTAssertFalse(footer.isRefreshing)
        XCTAssertEqual(calls, 0)
        layout.drive(offset: -(footer.expandHeight + 5), dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(footer.phase, .refreshing)
        XCTAssertTrue(footer.isRefreshing)
        XCTAssertEqual(calls, 1)
        footer.endRefreshing()
        spin(1.5)
        XCTAssertEqual(footer.phase, .idle)
        XCTAssertEqual(calls, 1)
    }

    func testAnAutoFooterLoadsOnReleaseAtTheBottomAndNotOnAHeaderPull() {
        var calls = 0
        let footer = CYLRefreshAutoNormalFooter(refreshingBlock: { calls += 1 })
        let layout = drivenFooter(footer)
        layout.drive(offset: 10, dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(calls, 0, "a pull at the top must not load")
        layout.drive(offset: 0, dragging: false)
        layout.drive(offset: -8, dragging: true)
        layout.release()
        spin()
        XCTAssertTrue(footer.isRefreshing)
        XCTAssertEqual(calls, 1)
        footer.endRefreshing()
        spin(1.5)
        XCTAssertFalse(footer.isRefreshing)
    }

    func testAnAutoFooterLoadsOncePerDragAndAgainAfterANewDrag() {
        var calls = 0
        let footer = CYLRefreshAutoNormalFooter(refreshingBlock: { calls += 1 })
        let layout = drivenFooter(footer)
        layout.drive(offset: -8, dragging: true)
        layout.release()
        spin()
        footer.endRefreshing()
        spin(1.5)
        XCTAssertEqual(calls, 1)
        // [EN] The trigger count of the drag is used up: a release with no new drag does not load. [CN] 本次拖动的触发次数已用完：没有新拖动的抬起不再加载。
        layout.release()
        spin()
        XCTAssertEqual(calls, 1)
        layout.drive(offset: 0, dragging: false)
        layout.drive(offset: -8, dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(calls, 2)
    }

    func testAnAutoFooterWithRefreshDisabledNeverLoads() {
        var calls = 0
        let footer = CYLRefreshAutoNormalFooter(refreshingBlock: { calls += 1 })
        footer.isRefreshEnabled = false
        let layout = drivenFooter(footer)
        layout.drive(offset: -8, dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(calls, 0)
    }

    func testEndRefreshingWithNoMoreDataStopsLoadingUntilResetNoMoreData() {
        var calls = 0
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: { calls += 1 })
        footer.finishDuration = 0.01
        let layout = drivenFooter(footer)
        layout.drive(offset: -(footer.expandHeight + 5), dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(calls, 1)
        footer.endRefreshingWithNoMoreData()
        spin()
        XCTAssertTrue(footer.isNoMoreData)
        XCTAssertEqual(footer.state, .noMoreData)
        layout.drive(offset: -(footer.expandHeight + 5), dragging: true)
        layout.release()
        spin()
        XCTAssertFalse(footer.isRefreshing)
        XCTAssertEqual(calls, 1, "no more data: a pull must not load")
        footer.resetNoMoreData()
        XCTAssertFalse(footer.isNoMoreData)
    }

    func testLoadsAfterNoMoreDataLetsAPullLoadAgainAndClearsTheFlag() {
        var calls = 0
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: { calls += 1 })
        footer.loadsAfterNoMoreData = true
        let layout = drivenFooter(footer)
        footer.endRefreshingWithNoMoreData()
        spin()
        XCTAssertTrue(footer.isNoMoreData)
        layout.drive(offset: -(footer.expandHeight + 5), dragging: true)
        XCTAssertFalse(footer.isNoMoreData)
        XCTAssertEqual(footer.phase, .releaseToRefresh)
        layout.release()
        spin()
        XCTAssertTrue(footer.isRefreshing)
        XCTAssertEqual(calls, 1)
    }

    func testAnAutoFooterWithLoadsAfterNoMoreDataLoadsAgainOnRelease() {
        var calls = 0
        let footer = CYLRefreshAutoNormalFooter(refreshingBlock: { calls += 1 })
        footer.loadsAfterNoMoreData = true
        let layout = drivenFooter(footer)
        footer.endRefreshingWithNoMoreData()
        spin()
        layout.drive(offset: -8, dragging: true)
        layout.release()
        spin()
        XCTAssertFalse(footer.isNoMoreData)
        XCTAssertEqual(calls, 1)
    }

    func testAFooterOnEdgeIgnoresAPullThatDidNotStartAtTheEdge() {
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
        footer.triggerMode = .onEdge
        let layout = drivenFooter(footer)
        layout.drive(offset: -(footer.expandHeight + 20), dragging: true, startedAtEdge: false)
        XCTAssertEqual(footer.state, .idle)
        XCTAssertNotEqual(footer.phase, .releaseToRefresh)
        layout.drive(offset: 0, dragging: false)
        layout.drive(offset: -(footer.expandHeight + 20), dragging: true, startedAtEdge: true)
        XCTAssertEqual(footer.phase, .releaseToRefresh)
    }

    func testHeaderAndFooterTogetherEachFollowTheirOwnSideOfTheOffset() {
        var headerCalls = 0
        var footerCalls = 0
        let header = CYLRefreshHeader(refreshingBlock: { headerCalls += 1 })
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: { footerCalls += 1 })
        footer.finishDuration = 0.01
        let layout = CYLRefreshDrivenLayout(frame: window.bounds)
        window.addSubview(layout)
        layout.header = header
        layout.footer = footer
        layout.layoutIfNeeded()
        spin(0.1)
        layout.drive(offset: header.expandHeight + 5, dragging: true)
        XCTAssertEqual(header.phase, .releaseToRefresh)
        XCTAssertEqual(footer.phase, .idle)
        layout.release()
        spin()
        XCTAssertTrue(header.isRefreshing)
        XCTAssertFalse(footer.isRefreshing)
        XCTAssertEqual(headerCalls, 1)
        header.endRefreshing(success: true)
        spin(1.5)
        XCTAssertEqual(header.phase, .idle)
        layout.drive(offset: 0, dragging: false)
        layout.drive(offset: -(footer.expandHeight + 5), dragging: true)
        XCTAssertEqual(footer.phase, .releaseToRefresh)
        XCTAssertEqual(header.phase, .idle)
        layout.release()
        spin()
        XCTAssertTrue(footer.isRefreshing)
        XCTAssertFalse(header.isRefreshing)
        XCTAssertEqual(footerCalls, 1)
        XCTAssertEqual(headerCalls, 1)
    }

    func testAHeaderAloneIgnoresANegativeOffset() {
        var calls = 0
        let (layout, header) = driven(CYLRefreshHeader(refreshingBlock: { calls += 1 }))
        layout.drive(offset: -(header.expandHeight + 20), dragging: true)
        layout.release()
        spin()
        XCTAssertEqual(header.phase, .idle)
        XCTAssertEqual(calls, 0)
    }
}
