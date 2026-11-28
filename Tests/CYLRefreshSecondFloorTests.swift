//
//  CYLRefreshSecondFloorTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The second floor (row 7 of docs/Refresh-Library-Parity.md, "Row 7 and 8 native contract") on the three iOS surfaces that
//       carry it: `CYLRefreshDrivenLayout` (driven mode), the Flutter iOS host (`CYLRefreshDrivenHost`: creation parameters,
//       `openSecondary` / `closeSecondary`, `onSecondaryOpened` / `onSecondaryClosed`) and the React Native container
//       (`CYLRefreshContainerView`: `secondaryTriggerOffset`, `secondaryDimension`, `secondaryCloseTriggerOffset`,
//       `secondaryOpen`, `onSecondaryOpen` / `onSecondaryClose`, the child with the floor's nativeID). Written without a
//       compiler on 2026-11-24: the batch run is the first build.
//  [CN] 二楼（docs/Refresh-Library-Parity.md 第 7 行，“Row 7 and 8 native contract”）在 iOS 三个承载面上的行为：
//       `CYLRefreshDrivenLayout`（驱动模式）、Flutter iOS 宿主（`CYLRefreshDrivenHost`）、React Native 容器
//       （`CYLRefreshContainerView`）。2026-11-24 在没有编译器的情况下写成：批量运行是第一次构建。
//

import XCTest
import UIKit

final class CYLRefreshSecondFloorTests: XCTestCase {

    private var window: UIWindow!
    private var events: [(name: String, arguments: [String: Any]?)] = []
    private var secondaryOpenEvents = 0
    private var secondaryCloseEvents = 0

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 600))
        window.isHidden = false
        events = []
        secondaryOpenEvents = 0
        secondaryCloseEvents = 0
    }

    private func spin(_ seconds: TimeInterval = 0.3) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
    }

    // [EN] Polls for the end of an animation, as testSecondFloorOpensAndCloses does (a busy CI runner stretches animations).
    // [CN] 轮询动画结束，与 testSecondFloorOpensAndCloses 相同（繁忙的 CI 机器会拉长动画）。
    private func waitUntil(_ condition: () -> Bool) {
        let deadline = Date(timeIntervalSinceNow: 15)
        while !condition() && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
    }

    private func drivenScrollView(of layout: CYLRefreshDrivenLayout) -> UIScrollView? {
        layout.subviews.compactMap { $0 as? UIScrollView }.first
    }

    // MARK: - CYLRefreshDrivenLayout

    private func drivenHeader(trigger: CGFloat = 120, dimension: CGFloat = 200) -> (CYLRefreshDrivenLayout, CYLRefreshHeader) {
        let layout = CYLRefreshDrivenLayout(frame: window.bounds)
        window.addSubview(layout)
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        header.secondaryAnimationDuration = 0.05
        layout.header = header
        layout.configureSecondary(triggerOffset: trigger, dimension: dimension)
        layout.layoutIfNeeded()
        spin(0.1)
        return (layout, header)
    }

    func testAPullPastTheTriggerArmsAndAReleaseOpensTheFloorInsteadOfRefreshing() {
        let (layout, header) = drivenHeader()
        var opened = 0
        layout.secondaryOpenedBlock = { opened += 1 }
        var phases = [CYLRefreshPhase]()
        _ = header.addPhaseObserver { _, _, new in phases.append(new) }
        layout.drive(offset: 60, dragging: true)
        XCTAssertNotEqual(header.phase, .secondaryArmed, "short of the trigger")
        layout.drive(offset: 130, dragging: true)
        XCTAssertEqual(header.phase, .secondaryArmed)
        layout.release()
        XCTAssertTrue(layout.isSecondaryOpen)
        waitUntil { opened == 1 }
        XCTAssertEqual(opened, 1)
        XCTAssertFalse(header.isRefreshing, "the floor opened instead of a refresh")
        XCTAssertTrue(phases.contains(.secondaryArmed))
        XCTAssertTrue(phases.contains(.secondaryOpen))
    }

    func testTriggerOffsetZeroTurnsTheSecondFloorOff() {
        let (layout, header) = drivenHeader(trigger: 0)
        layout.drive(offset: 300, dragging: true)
        XCTAssertNotEqual(header.phase, .secondaryArmed)
        layout.release()
        XCTAssertFalse(layout.isSecondaryOpen)
    }

    func testOpenAndCloseSecondaryHoldTheContentByTheFloorsExtentAndReportBothBlocks() {
        let (layout, header) = drivenHeader(dimension: 200)
        var opened = 0, closed = 0
        layout.secondaryOpenedBlock = { opened += 1 }
        layout.secondaryClosedBlock = { closed += 1 }
        layout.openSecondary()
        layout.openSecondary()
        XCTAssertTrue(layout.isSecondaryOpen)
        XCTAssertEqual(header.phase, .secondaryOpen)
        waitUntil { opened == 1 }
        layout.drive(offset: 0, dragging: false)
        XCTAssertEqual(drivenScrollView(of: layout)?.contentOffset.y ?? 0, -200, accuracy: 1, "the open floor holds the content, whatever pull is fed")
        XCTAssertEqual(opened, 1, "a second openSecondary is a silent no-op")
        layout.closeSecondary()
        waitUntil { closed == 1 && !layout.isSecondaryOpen }
        XCTAssertFalse(layout.isSecondaryOpen)
        XCTAssertEqual(closed, 1)
        layout.closeSecondary()
        spin(0.2)
        XCTAssertEqual(closed, 1, "closing a closed floor is a silent no-op")
    }

    func testABackFooterOpensAndClosesItsFloorThroughTheLayout() {
        let layout = CYLRefreshDrivenLayout(frame: window.bounds)
        window.addSubview(layout)
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
        layout.footer = footer
        layout.configureSecondary(triggerOffset: 100, dimension: 200)
        layout.layoutIfNeeded()
        spin(0.1)
        XCTAssertEqual(footer.secondaryTriggerOffset, 100, accuracy: 0.01)
        XCTAssertEqual(footer.secondaryDimension, 200, accuracy: 0.01)
        var opened = 0, closed = 0
        layout.secondaryOpenedBlock = { opened += 1 }
        layout.secondaryClosedBlock = { closed += 1 }
        layout.openSecondary()
        XCTAssertTrue(layout.isSecondaryOpen)
        waitUntil { opened == 1 }
        layout.closeSecondary()
        waitUntil { closed == 1 && !layout.isSecondaryOpen }
        XCTAssertEqual(opened, 1)
        XCTAssertEqual(closed, 1)
    }

    // MARK: - Flutter iOS host

    private func host(_ params: [String: Any]?) -> CYLRefreshDrivenHost {
        let host = CYLRefreshDrivenHost(frame: window.bounds, params: params) { [unowned self] name, arguments in
            events.append((name, arguments))
        }
        window.addSubview(host.layout)
        host.layout.layoutIfNeeded()
        (host.component as? CYLRefreshHeader)?.secondaryAnimationDuration = 0.05
        spin(0.1)
        return host
    }

    private func names(_ name: String) -> Int { events.filter { $0.name == name }.count }

    func testHostReadsTheSecondFloorCreationParametersAndIgnoresBadValues() {
        let params = CYLRefreshDrivenHost.Params(["secondaryTriggerOffset": 120, "secondaryDimension": 300.5, "secondaryCloseTriggerOffset": 60])
        XCTAssertEqual(params.secondaryTriggerOffset, 120)
        XCTAssertEqual(params.secondaryDimension, 300.5)
        XCTAssertEqual(params.secondaryCloseTriggerOffset, 60)
        let bad = CYLRefreshDrivenHost.Params(["secondaryTriggerOffset": -5, "secondaryDimension": Double.nan, "secondaryCloseTriggerOffset": "60"])
        XCTAssertEqual(bad.secondaryTriggerOffset, 0)
        XCTAssertEqual(bad.secondaryDimension, 0)
        XCTAssertEqual(bad.secondaryCloseTriggerOffset, 0)
        let header = host(["secondaryTriggerOffset": 120, "secondaryDimension": 300, "secondaryCloseTriggerOffset": 60])
        XCTAssertEqual(header.layout.header?.secondaryTriggerOffset ?? 0, 120, accuracy: 0.01)
        XCTAssertEqual(header.layout.header?.secondaryDimension ?? 0, 300, accuracy: 0.01)
        XCTAssertEqual(header.layout.header?.secondaryCloseTriggerOffset ?? 0, 60, accuracy: 0.01)
        let plain = host(nil)
        XCTAssertEqual(plain.layout.header?.secondaryTriggerOffset ?? -1, 0, accuracy: 0.01, "no parameter, no second floor")
    }

    func testHostOpenSecondaryAndCloseSecondaryMirrorDartAndSendTheInformationalEvents() {
        let host = host(["secondaryTriggerOffset": 120])
        XCTAssertEqual(host.handle(method: "openSecondary", arguments: nil), .success)
        XCTAssertTrue(host.layout.isSecondaryOpen)
        waitUntil { names("onSecondaryOpened") == 1 }
        XCTAssertEqual(names("onSecondaryOpened"), 1)
        XCTAssertTrue(events.contains { $0.name == "onPhase" && $0.arguments?["phase"] as? String == "secondaryOpen" })
        XCTAssertEqual(host.handle(method: "openSecondary", arguments: nil), .success, "open on an open floor is a no-op, not an error")
        spin(0.2)
        XCTAssertEqual(names("onSecondaryOpened"), 1)
        XCTAssertEqual(host.handle(method: "closeSecondary", arguments: nil), .success)
        waitUntil { names("onSecondaryClosed") == 1 && !host.layout.isSecondaryOpen }
        XCTAssertEqual(names("onSecondaryClosed"), 1)
        XCTAssertFalse(host.layout.isSecondaryOpen)
        XCTAssertEqual(host.handle(method: "closeSecondary", arguments: nil), .success)
        spin(0.2)
        XCTAssertEqual(names("onSecondaryClosed"), 1, "close on a closed floor is a no-op")
    }

    func testHostAPullPastTheTriggerReportsSecondaryArmedAndTheReleaseOpensTheFloor() {
        let host = host(["secondaryTriggerOffset": 100])
        XCTAssertEqual(host.handle(method: "drive", arguments: ["offset": 110.0, "dragging": true, "startedAtEdge": true]), .success)
        XCTAssertTrue(events.contains { $0.name == "onPhase" && $0.arguments?["phase"] as? String == "secondaryArmed" })
        XCTAssertEqual(host.handle(method: "release", arguments: nil), .success)
        waitUntil { names("onSecondaryOpened") == 1 }
        XCTAssertEqual(names("onSecondaryOpened"), 1)
        XCTAssertEqual(names("onRefreshing"), 0, "the floor opened instead of a refresh")
    }

    func testHostWithoutAnyParameterNeverOpensTheFloorByAPull() {
        let host = host(nil)
        _ = host.handle(method: "drive", arguments: ["offset": 200.0, "dragging": true, "startedAtEdge": true])
        _ = host.handle(method: "release", arguments: nil)
        spin(0.3)
        XCTAssertFalse(host.layout.isSecondaryOpen)
        XCTAssertEqual(names("onSecondaryOpened"), 0)
    }

    // MARK: - React Native container

    private func container(floor: Bool = true) -> (CYLRefreshContainerView, UIScrollView, UIView?) {
        let container = CYLRefreshContainerView(frame: window.bounds)
        container.onSecondaryOpen = { [unowned self] _ in secondaryOpenEvents += 1 }
        container.onSecondaryClose = { [unowned self] _ in secondaryCloseEvents += 1 }
        window.addSubview(container)
        var floorView: UIView?
        if floor {
            let view = UIView(frame: container.bounds)
            view.accessibilityIdentifier = CYLRefreshContainerView.secondaryViewNativeID
            container.addSubview(view)
            floorView = view
        }
        let scrollView = UIScrollView(frame: container.bounds)
        scrollView.contentSize = CGSize(width: 320, height: 1200)
        let wrapper = UIView(frame: container.bounds)
        wrapper.addSubview(scrollView)
        container.addSubview(wrapper)
        container.layoutIfNeeded()
        spin(0.1)
        return (container, scrollView, floorView)
    }

    func testTheContainerTakesTheChildWithTheFloorsNativeIDAsTheHeadersSecondaryView() {
        let (container, scrollView, floor) = container()
        container.secondaryTriggerOffset = 140
        container.secondaryDimension = 260
        let header = scrollView.cylHeader as? CYLRefreshHeader
        XCTAssertTrue(container.scrollView === scrollView, "the floor's child is not taken for the scroll view")
        XCTAssertTrue(header?.secondaryView === floor)
        XCTAssertEqual(header?.secondaryTriggerOffset ?? 0, 140, accuracy: 0.01)
        XCTAssertEqual(header?.secondaryDimension ?? 0, 260, accuracy: 0.01)
        XCTAssertEqual(header?.secondaryCloseTriggerOffset ?? 0, 80, accuracy: 0.01, "default 80, also for 0 or less")
        container.secondaryCloseTriggerOffset = 50
        XCTAssertEqual(header?.secondaryCloseTriggerOffset ?? 0, 50, accuracy: 0.01)
        container.secondaryCloseTriggerOffset = 0
        XCTAssertEqual(header?.secondaryCloseTriggerOffset ?? 0, 80, accuracy: 0.01)
    }

    func testSecondaryOpenSetFromJavaScriptOpensAndClosesWithoutCallingTheEventsBack() {
        let (container, scrollView, _) = container()
        let header = scrollView.cylHeader as? CYLRefreshHeader
        header?.secondaryAnimationDuration = 0.05
        container.secondaryTriggerOffset = 140
        container.secondaryOpen = true
        XCTAssertTrue(header?.isSecondaryOpen == true)
        spin(0.4)
        XCTAssertEqual(secondaryOpenEvents, 0, "a value JavaScript set does not call onSecondaryOpen back")
        container.secondaryOpen = false
        waitUntil { header?.isSecondaryOpen == false }
        spin(0.2)
        XCTAssertFalse(header?.isSecondaryOpen == true)
        XCTAssertEqual(secondaryCloseEvents, 0, "nor onSecondaryClose")
    }

    // MARK: - Closing by a push (real scroll view, faked finger)

    private final class FingerPan: UIPanGestureRecognizer {
        var fakeState: UIGestureRecognizer.State = .possible
        override var state: UIGestureRecognizer.State {
            get { fakeState }
            set { fakeState = newValue }
        }
    }

    private final class FingerScrollView: UIScrollView {
        var fakeDragging = false
        let fakePan = FingerPan()
        override var isDragging: Bool { fakeDragging }
        override var panGestureRecognizer: UIPanGestureRecognizer { fakePan }
    }

    /// A push that ends with the finger still (no deceleration, so no further offset change) must still close the floor: the
    /// close was only checked on an offset change after the release, so a release at rest left it open (React Native example,
    /// axe swipe). [CN] 手指静止抬起（没有减速，也就没有后续偏移变化）的上推也必须关闭二楼：此前只在松手之后的偏移变化时检查，
    /// 静止松手就一直打开（React Native 示例，axe 滑动）。
    func testAPushPastTheCloseTriggerClosesTheFloorWhenTheFingerLiftsAtRest() {
        let scrollView = FingerScrollView(frame: window.bounds)
        scrollView.contentSize = CGSize(width: 320, height: 3000)
        window.addSubview(scrollView)
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        header.secondaryAnimationDuration = 0.05
        header.secondaryTriggerOffset = 120
        header.secondaryDimension = 300
        header.secondaryCloseTriggerOffset = 80
        var closed = 0
        header.secondaryClosedBlock = { closed += 1 }
        scrollView.cylHeader = header
        scrollView.layoutIfNeeded()
        header.openSecondary()
        waitUntil { header.isSecondaryOpen && abs(scrollView.contentOffset.y + 300) < 1 }
        XCTAssertTrue(header.isSecondaryOpen)
        scrollView.fakeDragging = true
        scrollView.contentOffset = CGPoint(x: 0, y: -300 + 150)
        spin(0.1)
        XCTAssertTrue(header.isSecondaryOpen, "still held by the finger")
        scrollView.fakeDragging = false
        scrollView.fakePan.fakeState = .ended
        header.scrollViewPanStateDidChange(nil)
        waitUntil { closed == 1 }
        XCTAssertEqual(closed, 1, "the floor closed on the lift")
        XCTAssertFalse(header.isSecondaryOpen)
    }

    func testAFloorOpenedByTheHeaderItselfSendsOnSecondaryOpenOnceAndOnSecondaryCloseOnce() {
        let (container, scrollView, _) = container()
        let header = scrollView.cylHeader as? CYLRefreshHeader
        header?.secondaryAnimationDuration = 0.05
        container.secondaryTriggerOffset = 140
        header?.openSecondary()
        waitUntil { self.secondaryOpenEvents == 1 }
        XCTAssertEqual(secondaryOpenEvents, 1)
        header?.closeSecondary()
        waitUntil { self.secondaryCloseEvents == 1 }
        XCTAssertEqual(secondaryCloseEvents, 1)
        spin(0.2)
        XCTAssertEqual(secondaryOpenEvents, 1)
        XCTAssertEqual(secondaryCloseEvents, 1)
    }

    func testSecondaryOpenSetBeforeTheScrollViewArrivesIsAppliedWhenItDoes() {
        let container = CYLRefreshContainerView(frame: window.bounds)
        window.addSubview(container)
        container.secondaryTriggerOffset = 140
        container.secondaryOpen = true
        let scrollView = UIScrollView(frame: container.bounds)
        scrollView.contentSize = CGSize(width: 320, height: 1200)
        container.addSubview(scrollView)
        container.layoutIfNeeded()
        spin(0.1)
        XCTAssertTrue((scrollView.cylHeader as? CYLRefreshHeader)?.isSecondaryOpen == true)
        XCTAssertEqual(secondaryOpenEvents, 0)
    }
}
