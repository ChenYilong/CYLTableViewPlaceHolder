//
//  CYLRefreshDrivenHostTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The Flutter-free core of the Flutter iOS refresh view (CrossPlatform/flutter_cylplaceholder/ios/Classes/
//       CYLRefreshDrivenHost.swift): creation parameters, the channel contract of Android's CYLRefreshPlatformView (drive,
//       release, finishRefresh, noMoreData), and the events it sends back.
//  [CN] Flutter iOS 刷新视图中不依赖 Flutter 的部分：创建参数、与 Android CYLRefreshPlatformView 相同的通道约定
//       （drive、release、finishRefresh、noMoreData）以及回传的事件。
//

import XCTest
import UIKit

final class CYLRefreshDrivenHostTests: XCTestCase {

    private var window: UIWindow!
    private var events: [(name: String, arguments: [String: Any]?)] = []

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 600))
        window.isHidden = false
        events = []
    }

    private func spin(_ seconds: TimeInterval = 0.5) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
    }

    private func host(_ params: [String: Any]?) -> CYLRefreshDrivenHost {
        let host = CYLRefreshDrivenHost(frame: window.bounds, params: params) { [unowned self] name, arguments in
            events.append((name, arguments))
        }
        window.addSubview(host.layout)
        host.layout.layoutIfNeeded()
        spin(0.1)
        return host
    }

    private func drive(_ host: CYLRefreshDrivenHost, _ offset: Double, dragging: Bool = true) {
        XCTAssertEqual(host.handle(method: "drive", arguments: ["offset": offset, "dragging": dragging, "startedAtEdge": true]), .success)
    }

    func testCreationParametersChooseTheHeaderOrTheFooter() {
        XCTAssertEqual(CYLRefreshDrivenHost.Params(nil), CYLRefreshDrivenHost.Params(["footer": false]))
        XCTAssertEqual(CYLRefreshDrivenHost.Params(["footer": "yes"]).footer, false, "only a boolean true counts, as on Android")
        let header = host(nil)
        XCTAssertTrue(header.component is CYLRefreshNormalHeader)
        XCTAssertNotNil(header.layout.header)
        XCTAssertNil(header.layout.footer)
        let footer = host(["footer": true, "loadsAfterNoMoreData": true])
        XCTAssertTrue(footer.component is CYLRefreshBackNormalFooter)
        XCTAssertNotNil(footer.layout.footer)
        XCTAssertEqual(footer.layout.footer?.loadsAfterNoMoreData, true, "loadsAfterNoMoreData reached the footer")
        XCTAssertFalse((host(["footer": true]).component as! CYLRefreshFooter).loadsAfterNoMoreData)
    }

    func testTheFooterSitsBelowTheVisibleAreaAndFollowsAResize() {
        let host = host(["footer": true])
        let footer = host.component
        XCTAssertEqual(footer.frame.minY, host.layout.bounds.height, accuracy: 0.5)
        host.layout.frame = CGRect(x: 0, y: 0, width: 320, height: 90)
        host.layout.layoutIfNeeded()
        XCTAssertEqual(footer.frame.minY, 90, accuracy: 0.5, "the footer follows the slot the host resizes")
    }

    func testNoMoreDataIsScrolledIntoViewAndAPullStillMovesPastIt() {
        let host = host(["footer": true])
        let footer = host.component as! CYLRefreshFooter
        _ = host.handle(method: "noMoreData", arguments: ["value": true])
        host.layout.layoutIfNeeded()
        let scrollView = host.layout.subviews.compactMap { $0 as? UIScrollView }.first!
        XCTAssertEqual(scrollView.contentOffset.y, footer.frame.height, accuracy: 0.5, "the label is inside the visible area at rest")
        drive(host, -(footer.frame.height + 30))
        XCTAssertEqual(scrollView.contentOffset.y, footer.frame.height + 30, accuracy: 0.5)
        _ = host.handle(method: "noMoreData", arguments: ["value": false])
        drive(host, 0, dragging: false)
        XCTAssertEqual(scrollView.contentOffset.y, 0, accuracy: 0.5)
    }

    func testPhaseNamesAreTheAndroidLowerCamelNames() {
        XCTAssertEqual(CYLRefreshDrivenHost.name(of: .idle), "idle")
        XCTAssertEqual(CYLRefreshDrivenHost.name(of: .pullToRefresh), "pullToRefresh")
        XCTAssertEqual(CYLRefreshDrivenHost.name(of: .releaseToRefresh), "releaseToRefresh")
        XCTAssertEqual(CYLRefreshDrivenHost.name(of: .releasing), "releasing")
        XCTAssertEqual(CYLRefreshDrivenHost.name(of: .refreshing), "refreshing")
        XCTAssertEqual(CYLRefreshDrivenHost.name(of: .finishing), "finishing")
        XCTAssertEqual(CYLRefreshDrivenHost.name(of: .noMoreData), "noMoreData")
    }

    func testDrivingTheHeaderReportsPhasesAndReleaseReportsRefreshingOnce() {
        let host = host(nil)
        let h = host.component.expandHeight
        drive(host, h / 3)
        drive(host, h + 5)
        XCTAssertEqual(events.compactMap { $0.arguments?["phase"] as? String }, ["pullToRefresh", "releaseToRefresh"])
        XCTAssertEqual(events.first?.name, "onPhase")
        XCTAssertEqual(events.first?.arguments?["oldPhase"] as? String, "idle")
        XCTAssertEqual(host.handle(method: "release", arguments: nil), .success)
        spin()
        XCTAssertEqual(host.component.phase, .refreshing)
        XCTAssertEqual(events.filter { $0.name == "onRefreshing" }.count, 1)
        events = []
        XCTAssertEqual(host.handle(method: "finishRefresh", arguments: ["success": true]), .success)
        spin(1.5)
        XCTAssertEqual(events.compactMap { $0.arguments?["phase"] as? String }.last, "idle", "the header retracts and reports idle")
        XCTAssertEqual(host.component.phase, .idle)
    }

    func testAShortPullIsCanceledAndFinishRefreshWithFailureIsRecorded() {
        let host = host(nil)
        drive(host, host.component.expandHeight / 4)
        XCTAssertEqual(host.handle(method: "release", arguments: nil), .success)
        spin()
        XCTAssertEqual(host.component.phase, .idle)
        drive(host, host.component.expandHeight + 5)
        _ = host.handle(method: "release", arguments: nil)
        spin()
        _ = host.handle(method: "finishRefresh", arguments: ["success": false])
        XCTAssertFalse(host.component.lastRefreshSucceeded)
        spin(1.5)
    }

    func testTheFooterIsPulledWithANegativeOffsetAndEndsWithNoMoreData() {
        let host = host(["footer": true])
        let footer = host.component as! CYLRefreshFooter
        drive(host, -(host.component.expandHeight + 10))
        XCTAssertEqual(host.component.phase, .releaseToRefresh)
        XCTAssertEqual(host.handle(method: "release", arguments: nil), .success)
        spin()
        XCTAssertEqual(host.component.phase, .refreshing)
        XCTAssertEqual(events.filter { $0.name == "onRefreshing" }.count, 1)
        XCTAssertEqual(host.handle(method: "finishRefresh", arguments: ["success": true, "noMoreData": true]), .success)
        spin(1.5)
        XCTAssertTrue(footer.isNoMoreData)
        XCTAssertEqual(host.handle(method: "noMoreData", arguments: ["value": false]), .success)
        XCTAssertFalse(footer.isNoMoreData)
        XCTAssertEqual(host.handle(method: "noMoreData", arguments: ["value": true]), .success)
        XCTAssertTrue(footer.isNoMoreData)
    }

    func testAFooterPulledAfterNoMoreDataStaysUnarmedUnlessLoadsAfterNoMoreData() {
        let stays = host(["footer": true])
        _ = stays.handle(method: "noMoreData", arguments: ["value": true])
        drive(stays, -(stays.component.expandHeight + 10))
        _ = stays.handle(method: "release", arguments: nil)
        spin()
        XCTAssertFalse(stays.component.isRefreshing)
        XCTAssertTrue((stays.component as! CYLRefreshFooter).isNoMoreData)
        events = []
        let loads = host(["footer": true, "loadsAfterNoMoreData": true])
        _ = loads.handle(method: "noMoreData", arguments: ["value": true])
        drive(loads, -(loads.component.expandHeight + 10))
        _ = loads.handle(method: "release", arguments: nil)
        spin()
        XCTAssertTrue(loads.component.isRefreshing)
        XCTAssertFalse((loads.component as! CYLRefreshFooter).isNoMoreData)
    }

    func testBadCallsAnswerWithErrorsOrNotImplemented() {
        let header = host(nil)
        XCTAssertEqual(header.handle(method: "drive", arguments: ["dragging": true]), .error(code: "bad_arguments", message: "drive needs an offset."))
        XCTAssertEqual(header.handle(method: "drive", arguments: nil), .error(code: "bad_arguments", message: "drive needs an offset."))
        XCTAssertEqual(header.handle(method: "noMoreData", arguments: ["value": true]), .error(code: "not_a_footer", message: "noMoreData needs a footer view."))
        XCTAssertEqual(header.handle(method: "nope", arguments: nil), .notImplemented)
    }
}
