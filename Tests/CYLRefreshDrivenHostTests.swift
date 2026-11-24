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

    // MARK: - style and the slot (row 6, the row-4 clip)

    func testTheStyleParameterChoosesTheLook() {
        XCTAssertEqual(CYLRefreshDrivenHost.Params(["style": "phoenix"]).style, "phoenix")
        XCTAssertNil(CYLRefreshDrivenHost.Params(["style": 3]).style)
        XCTAssertTrue(host(["style": "phoenix"]).component is CYLRefreshPhoenixHeader)
        XCTAssertTrue(host(["style": "taurus", "footer": true]).component is CYLRefreshTaurusFooter)
        XCTAssertTrue(host(["style": "cupertino"]).component is CYLRefreshCupertinoHeader)
    }

    func testAMissingOrUnknownStyleIsTheClassicOneAndNeverCrashes() {
        XCTAssertTrue(host(nil).component is CYLRefreshNormalHeader)
        XCTAssertTrue(host(["style": "rainbow"]).component is CYLRefreshNormalHeader)
        XCTAssertTrue(host(["style": "rainbow", "footer": true]).component is CYLRefreshBackNormalFooter)
        XCTAssertTrue(host(["style": 7]).component is CYLRefreshNormalHeader)
    }

    private func slotHost(_ params: [String: Any]?, height: CGFloat = 60) -> CYLRefreshDrivenHost {
        let host = CYLRefreshDrivenHost(frame: CGRect(x: 0, y: 0, width: 320, height: height), params: params) { _, _ in }
        window.addSubview(host.container)
        host.container.layoutIfNeeded()
        spin(0.1)
        return host
    }

    func testTheHeaderTakesTheOpenHeightOfItsViewAndIsAnchoredAtTheBottomOfTheSlot() {
        for style in ["classic", "phoenix"] {
            let host = slotHost(["style": style, "expandHeight": 90], height: 90)
            XCTAssertEqual(host.component.expandHeight, 90, accuracy: 0.5, style)
            XCTAssertEqual(host.layout.frame.height, 0, accuracy: 0.5, "\(style): nothing is shown at rest")
            drive(host, 20)
            XCTAssertEqual(host.layout.frame.height, 20, accuracy: 0.5, style)
            XCTAssertEqual(host.layout.frame.maxY, 90, accuracy: 0.5, "\(style): the slot is the bottom of the view")
            drive(host, 95)
            XCTAssertEqual(host.layout.frame.minY, -5, accuracy: 0.5, style)
            XCTAssertEqual(host.component.phase, .releaseToRefresh, "\(style): armed at the view's height")
        }
    }

    func testTheFooterSlotIsTheTopOfTheView() {
        let host = slotHost(["footer": true, "expandHeight": 60], height: 60)
        XCTAssertEqual(host.component.expandHeight, 60, accuracy: 0.5)
        drive(host, -20)
        XCTAssertEqual(host.layout.frame.minY, 0, accuracy: 0.5)
        XCTAssertEqual(host.layout.frame.height, 20, accuracy: 0.5)
        drive(host, 0, dragging: false)
        XCTAssertEqual(host.handle(method: "finishRefresh", arguments: ["noMoreData": true]), .success)
        XCTAssertEqual(host.layout.frame.height, 60, accuracy: 0.5, "no more data keeps the label's room")
    }

    func testAMidPullClassicHeaderDrawsInTheSlot() {
        let host = slotHost(["expandHeight": 60], height: 60)
        drive(host, 25)
        host.container.layoutIfNeeded()
        let label = host.layout.header.flatMap { header in header.subviews.compactMap { $0 as? UILabel }.first }
        XCTAssertNotNil(label)
        let inSlot = label.map { host.container.convert($0.bounds, from: $0) }
        XCTAssertNotNil(inSlot)
        let slot = CGRect(x: 0, y: 35, width: 320, height: 25)
        XCTAssertTrue(inSlot.map { $0.intersects(slot) } ?? false, "the title is inside the 25 points Dart shows: \(String(describing: inSlot))")
    }

    func testARefreshingClassicHeaderShowsItsTitleInTheHeldSlot() {
        let host = slotHost(["expandHeight": 60], height: 60)
        drive(host, 300)
        XCTAssertEqual(host.handle(method: "release", arguments: nil), .success)
        spin(0.8)
        XCTAssertEqual(host.layout.frame.height, 60, accuracy: 0.5, "the held slot is the open height, not the overpull")
        XCTAssertTrue(host.component.isRefreshing)
        host.container.layoutIfNeeded()
        let labels = host.component.subviews.compactMap { $0 as? UILabel }.filter { ($0.text ?? "").count > 0 }
        let report = labels.map { "\($0.text ?? "") hidden=\($0.isHidden) alpha=\($0.alpha) frame=\(host.container.convert($0.bounds, from: $0))" }
        XCTAssertFalse(labels.isEmpty, "a title label exists")
        let shown = labels.contains { !$0.isHidden && $0.alpha > 0.5 && host.container.bounds.intersects(host.container.convert($0.bounds, from: $0)) }
        XCTAssertTrue(shown, "layout=\(host.layout.frame) header=\(host.component.frame) alpha=\(host.component.alpha) labels=\(report)")
    }

    /// Non-transparent pixels of the container's render. [CN] 容器渲染结果中不透明的像素数。
    private func drawnPixels(_ view: UIView) -> Int {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: view.bounds.size, format: format).image { view.layer.render(in: $0.cgContext) }
        guard let cg = image.cgImage, let data = cg.dataProvider?.data, let bytes = CFDataGetBytePtr(data) else { return 0 }
        let step = cg.bitsPerPixel / 8
        var count = 0
        for index in stride(from: 0, to: CFDataGetLength(data) - 3, by: step) where bytes[index + 3] > 0 { count += 1 }
        return count
    }

    func testEveryStyleDrawsMidPullAndWhileRefreshingInTheHeldSlot() {
        for style in CYLRefreshStyle.allCases {
            let host = slotHost(["style": style.key, "expandHeight": 100], height: 100)
            drive(host, 50)
            host.container.layoutIfNeeded()
            host.component.layer.displayIfNeeded()
            XCTAssertGreaterThan(drawnPixels(host.container), 0, "\(style.key) draws mid-pull")
            drive(host, 300)
            XCTAssertEqual(host.handle(method: "release", arguments: nil), .success)
            spin(0.8)
            host.container.layoutIfNeeded()
            XCTAssertTrue(host.component.isRefreshing, style.key)
            XCTAssertEqual(host.layout.frame.height, 100, accuracy: 0.5, "\(style.key): the held slot")
            XCTAssertGreaterThan(drawnPixels(host.container), 0, "\(style.key) draws while refreshing: layout=\(host.layout.frame) header=\(host.component.frame) alpha=\(host.component.alpha) hidden=\(host.component.isHidden) mask=\(String(describing: host.component.layer.mask))")
            host.container.removeFromSuperview()
        }
    }

    func testAFrontHeaderDrawsInItsOpenHeightViewAtALargePull() {
        // [EN] Dart slides the Material view (front mode, one open height tall) down itself; a deep pull must not draw it above the clip.
        // [CN] Dart 自己下移 Material 视图（前置模式，高度为一个展开高度）；深度下拉不能把它画到裁剪区之上。
        let host = slotHost(["style": "material"], height: 80)
        for pull: CGFloat in [50, 120, 200, 300] {
            drive(host, pull)
            host.container.layoutIfNeeded()
            host.component.layer.displayIfNeeded()
            XCTAssertGreaterThan(drawnPixels(host.container), 0, "material draws at a pull of \(pull): layout=\(host.layout.frame)")
        }
        host.container.removeFromSuperview()
    }

    func testAStretchedViewThatChangesHeightWithThePullKeepsTheIndicatorVisibleWhileRefreshing() {
        // [EN] Dart sizes the drawn styles' view to the pull, with no expandHeight parameter: the view's height is never the open height.
        // [CN] Dart 把手绘样式的视图高度设为下拉量，且不带 expandHeight 参数：视图高度不是展开高度。
        for style in ["bezierRadar", "phoenix", "classic"] {
            let host = slotHost(["style": style], height: 40)
            let open = host.component.expandHeight
            drive(host, 40)
            host.container.frame.size.height = 300
            drive(host, 300)
            XCTAssertEqual(host.handle(method: "release", arguments: nil), .success)
            spin(0.8)
            host.container.frame.size.height = open
            host.container.layoutIfNeeded()
            XCTAssertTrue(host.component.isRefreshing, style)
            XCTAssertEqual(host.component.expandHeight, open, accuracy: 0.5, "\(style): the view's height never becomes the open height")
            XCTAssertEqual(host.layout.frame.height, open, accuracy: 0.5, "\(style): the held slot")
            XCTAssertGreaterThan(drawnPixels(host.container), 0, "\(style) draws while refreshing")
            host.container.removeFromSuperview()
        }
    }

    // MARK: - The header is laid out at its own height in the slot at every pull (2026-11-24, the owner's "stretch is clipped")

    /// The header's frame in the container's coordinates. [CN] 刷新头在容器坐标系中的 frame。
    private func headerInSlot(_ host: CYLRefreshDrivenHost) -> CGRect {
        host.container.layoutIfNeeded()
        return host.container.convert(host.component.bounds, from: host.component)
    }

    func testAMoveHeaderKeepsItsOwnHeightInTheSlotAtEveryPull() {
        for style in ["classic", "cupertino"] {
            let host = slotHost(["style": style, "expandHeight": 60], height: 60)
            for factor: CGFloat in [0.5, 1, 2, 3] {
                drive(host, 60 * factor)
                let header = headerInSlot(host)
                XCTAssertEqual(header.height, 60, accuracy: 0.5, "\(style) at \(factor)x: intrinsic height")
                XCTAssertEqual(header.maxY, 60, accuracy: 0.5, "\(style) at \(factor)x: anchored at the slot edge: \(header)")
                XCTAssertGreaterThanOrEqual(header.minY, -0.5, "\(style) at \(factor)x: not above the view")
            }
            host.container.removeFromSuperview()
        }
    }

    func testABehindHeaderStaysWholeInTheSlotAtEveryPull() {
        let host = slotHost(["expandHeight": 60], height: 60)
        (host.component as! CYLRefreshHeader).scrollMode = .behind
        for factor: CGFloat in [0.5, 1, 2, 3] {
            drive(host, 60 * factor)
            let header = headerInSlot(host)
            XCTAssertEqual(header.minY, 0, accuracy: 0.5, "behind at \(factor)x: at the top of the view, not lifted off it: \(header)")
            XCTAssertEqual(header.height, 60, accuracy: 0.5, "behind at \(factor)x: intrinsic height")
            XCTAssertLessThanOrEqual(host.layout.frame.minY, 0.5, "behind at \(factor)x: the layout covers the header: \(host.layout.frame)")
            XCTAssertGreaterThanOrEqual(host.layout.frame.maxY, 59.5, "behind at \(factor)x: the layout covers the header: \(host.layout.frame)")
        }
        host.container.removeFromSuperview()
    }

    func testAFrontHeaderIsWholeAndItsDrawingBelowItsFrameIsNotClipped() {
        let host = slotHost(["style": "material"], height: 80)
        XCTAssertEqual((host.component as! CYLRefreshHeader).scrollMode, .front)
        for factor: CGFloat in [0.5, 1, 2, 3] {
            drive(host, 80 * factor)
            let header = headerInSlot(host)
            XCTAssertEqual(header.minY, 0, accuracy: 0.5, "front at \(factor)x: \(header)")
            XCTAssertEqual(header.height, host.component.expandHeight, accuracy: 0.5, "front at \(factor)x: intrinsic height")
            XCTAssertGreaterThanOrEqual(host.layout.frame.height, header.height - 0.5, "front at \(factor)x: the layout is never shorter than the header")
            XCTAssertFalse(host.container.clipsToBounds, "front at \(factor)x: the circle drops below the header's frame at a deep pull and must not be cut at the view's edge")
        }
        host.container.removeFromSuperview()
    }

    func testAStretchedHeaderIsAsTallAsTheViewAtEveryPull() {
        for style in ["bezierCircle", "phoenix"] {
            let host = slotHost(["style": style], height: 40)
            for pull: CGFloat in [40, 100, 200, 300] {
                host.container.frame.size.height = pull
                drive(host, pull)
                let header = headerInSlot(host)
                XCTAssertEqual(header.minY, 0, accuracy: 0.5, "\(style) at \(pull): \(header)")
                XCTAssertEqual(header.height, pull, accuracy: 0.5, "\(style) at \(pull): fills the view")
            }
            host.container.removeFromSuperview()
        }
    }

    func testTheScrollModeParameterIsAppliedAndABehindHeaderIsPinned() {
        XCTAssertEqual(CYLRefreshDrivenHost.Params(["scrollMode": "behind"]).scrollMode, .behind)
        XCTAssertNil(CYLRefreshDrivenHost.Params(["scrollMode": "sideways"]).scrollMode)
        XCTAssertEqual((slotHost(["scrollMode": "stretch"]).component as! CYLRefreshHeader).scrollMode, .stretch)
        let behind = slotHost(["scrollMode": "behind"])
        drive(behind, 30)
        XCTAssertEqual((behind.component as! CYLRefreshHeader).scrollMode, .front, "pinned like a front header")
    }
}
