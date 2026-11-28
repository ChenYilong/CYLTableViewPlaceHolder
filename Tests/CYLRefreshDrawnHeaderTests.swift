//
//  CYLRefreshDrawnHeaderTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The hand-drawn headers of the CYLRefresh styles (CYLRefresh/Custom/Drawn, third-party refresh code, MIT): each one
//       runs a whole refresh in a window and draws; the base reports the CYLRefresh styles' status order; inset handling
//       survives mode switches. Swift since 2026-11-20 (docs/Swift-Migration.md, step 13); the variadic `-inStatus:` is
//       checked from Objective-C in `Tests/CYLObjectiveCAPISmokeTests.m`.
//  [CN] CYLRefresh styles 的手绘刷新头（CYLRefresh/Custom/Drawn，第三方刷新代码，MIT）：每个都在窗口中完成一次刷新并绘制；基类按 CYLRefresh
//       styles 的顺序报告状态；切换模式后仍正确处理 inset。自 2026-11-20 起用 Swift 编写（docs/Swift-Migration.md 第 13 步）；可变参数的
//       `-inStatus:` 在 `Tests/CYLObjectiveCAPISmokeTests.m` 中从 Objective-C 检查。
//

import UIKit
import XCTest

// [EN] CYLStatusRecordingHeader (a CYLRefreshBezierRadarHeader that records every status) is in
//      Tests/CYLRefreshTestHeaders.swift.
// [CN] CYLStatusRecordingHeader（记录每个状态的 CYLRefreshBezierRadarHeader）位于 Tests/CYLRefreshTestHeaders.swift。

/**
 * [EN] A demo page that attaches a header of `style` and starts refreshing in viewDidLoad.
 * [CN] 在 viewDidLoad 中挂上 `style` 类型的刷新头并开始刷新的示例页面。
 */
private final class CYLDrawnDemoTableController: UITableViewController {
    var style: CYLRefreshHeader.Type = CYLRefreshNormalHeader.self
    var header: CYLRefreshHeader?

    override func viewDidLoad() {
        super.viewDidLoad()
        let header = style.init()
        self.header = header
        header.attach(to: tableView)
        header.beginRefreshing()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 20 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell(style: .default, reuseIdentifier: nil)
    }
}

/**
 * [EN] A scroll view that can claim a finger is down, so styles that draw only while dragging (BezierRadar) draw in a
 *      rendered pull. [CN] 可以声称手指按下的滚动视图，使只在拖动时绘制的样式（BezierRadar）在渲染的上拉中也绘制。
 */
private final class CYLDraggingScrollView: UIScrollView {
    var fakeDragging = false

    override var isDragging: Bool { fakeDragging || super.isDragging }
}

/**
 * [EN] The hand-drawn headers of the CYLRefresh styles. [CN] CYLRefresh styles 的手绘刷新头。
 */
final class CYLRefreshDrawnHeaderTests: XCTestCase {
    private var window: UIWindow!

    override func setUp() {
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.isHidden = false
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
    }

    private func scrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: window.bounds)
        scrollView.contentSize = CGSize(width: 375, height: 2000)
        window.addSubview(scrollView)
        return scrollView
    }

    private func spin(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
    }

    /**
     * [EN] Runs the main run loop until `condition` holds or `timeout` passes; a slow CI machine needs longer than a fixed
     *      wait. [CN] 运行主循环，直到 `condition` 成立或超过 `timeout`；CI 机器较慢时，固定时长的等待不够。
     */
    @discardableResult
    private func spin(until condition: () -> Bool, timeout: TimeInterval) -> Bool {
        let deadline = Date(timeIntervalSinceNow: timeout)
        while !condition() && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
        return condition()
    }

    private func render(_ view: UIView) {
        if view.bounds.isEmpty { return }
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image: UIImage? = renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
        XCTAssertNotNil(image)
    }

    /**
     * [EN] Core Animation drops a whole commit with a NaN in any layer, freezing the screen; report every such layer.
     * [CN] 任何图层出现 NaN 时 Core Animation 会丢弃整次提交、画面冻结；报告所有这样的图层。
     */
    private func collectInvalidLayers(_ layer: CALayer, path: String, into out: inout [String]) {
        let b = layer.bounds, p = layer.position, t = layer.transform
        var bad = !b.origin.x.isFinite || !b.origin.y.isFinite || !b.size.width.isFinite || !b.size.height.isFinite ||
            !p.x.isFinite || !p.y.isFinite || !layer.anchorPoint.x.isFinite || !layer.opacity.isFinite ||
            !t.m11.isFinite || !t.m22.isFinite || !t.m41.isFinite || !t.m42.isFinite ||
            !layer.cornerRadius.isFinite || !layer.shadowRadius.isFinite
        if let shape = layer as? CAShapeLayer {
            // [EN] An empty path's box is CGRectNull (infinite origin): not an error. [CN] 空路径的边界是 CGRectNull（原点无穷大）：不算错误。
            var box = shape.path?.boundingBoxOfPath ?? .zero
            if box.isNull { box = .zero }
            bad = bad || !box.origin.x.isFinite || !box.origin.y.isFinite || !box.size.width.isFinite ||
                !shape.lineWidth.isFinite || !shape.strokeEnd.isFinite || !shape.strokeStart.isFinite
        }
        if bad {
            out.append("\(path) \(type(of: layer)) bounds=\(NSCoder.string(for: b)) position=\(NSCoder.string(for: p))")
        }
        for (index, sub) in (layer.sublayers ?? []).enumerated() {
            collectInvalidLayers(sub, path: "\(path)/\(index)", into: &out)
        }
    }

    private var styles: [CYLRefreshDrawnHeader.Type] {
        [CYLRefreshBezierCircleHeader.self, CYLRefreshBezierRadarHeader.self, CYLRefreshDeliveryHeader.self,
         CYLRefreshDropBoxHeader.self, CYLRefreshFlyHeader.self, CYLRefreshGameBattleCityHeader.self,
         CYLRefreshGameHitBlockHeader.self, CYLRefreshMaterialHeader.self, CYLRefreshOriginalHeader.self,
         CYLRefreshPhoenixHeader.self, CYLRefreshStoreHouseHeader.self, CYLRefreshTaurusHeader.self,
         CYLRefreshWaveSwipeHeader.self]
    }

    func testEveryStyleRunsARefreshAndDraws() {
        for style in styles {
            let scrollView = self.scrollView()
            let before = scrollView.contentInset
            let header: CYLRefreshComponent = style.attach(to: scrollView)
            XCTAssertTrue(header is CYLRefreshDrawnHeader)
            XCTAssertTrue(scrollView.cylHeader === header)
            XCTAssertGreaterThan(header.expandHeight, 0, "\(style)")
            spin(0.05)
            var y: CGFloat = 0
            while y >= -220 {
                scrollView.contentOffset = CGPoint(x: 0, y: y - scrollView.cylInset.top)
                header.layoutIfNeeded()
                header.setNeedsDisplay()
                header.layer.displayIfNeeded()
                y -= 20
            }
            render(header)
            var invalid: [String] = []
            scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.cylInset.top)
            spin(0.1)
            collectInvalidLayers(header.layer, path: "idle", into: &invalid)
            scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.cylInset.top - 60)
            spin(0.1)
            collectInvalidLayers(header.layer, path: "pulled", into: &invalid)
            header.beginRefreshing()
            spin(0.4)
            collectInvalidLayers(header.layer, path: "refreshing", into: &invalid)
            XCTAssertEqual(invalid.count, 0, "\(style) has NaN layers: \(invalid)")
            XCTAssertTrue(header.isRefreshing, "\(style)")
            render(header)
            header.endRefreshing()
            spin(1.8)
            render(header)
            XCTAssertEqual(header.state, .idle, "\(style)")
            scrollView.cylHeader = nil
            XCTAssertEqual(scrollView.contentInset.top, before.top, accuracy: 0.5, "\(style) leaves the inset as it found it")
            scrollView.removeFromSuperview()
        }
    }

    func testTheBaseReportsTheStylesStatusOrder() {
        let scrollView = self.scrollView()
        let header = CYLStatusRecordingHeader.attach(to: scrollView)
        spin(0.05)
        header.beginRefreshing()
        spin(0.4)
        header.finishRefresh(withSuccess: false)
        XCTAssertFalse(header.isSuccess)
        spin(1.5)
        let expected: [CYLRefreshPhase] = [.releasing, .refreshing, .finishing, .idle]
        let statuses = (header.statuses as? [NSNumber] ?? []).map { $0.intValue }
        let tail = statuses.count >= 4 ? Array(statuses.suffix(4)) : statuses
        XCTAssertEqual(tail, expected.map { $0.rawValue }, "\(statuses)")
        // [EN] Swift's form of `-inStatus:` (the variadic Objective-C call is in CYLObjectiveCAPISmokeTests.m).
        // [CN] `-inStatus:` 的 Swift 写法（可变参数的 Objective-C 调用在 CYLObjectiveCAPISmokeTests.m 中）。
        XCTAssertTrue(header.isIn(statuses: [.refreshing, .idle]))
    }

    func testAModeSwitchDuringARefreshStillRestoresTheInset() {
        let scrollView = self.scrollView()
        let top = scrollView.cylInset.top
        let header = CYLRefreshNormalHeader.attach(to: scrollView)
        spin(0.05)
        header.beginRefreshing()
        spin(0.5)
        XCTAssertGreaterThan(scrollView.cylInset.top, top + 1, "refreshing pushed the content down")
        header.scrollMode = .front
        header.endRefreshing()
        spin(0.8)
        XCTAssertEqual(scrollView.cylInset.top, top, accuracy: 0.5, "the added inset is removed although the mode changed")

        header.scrollMode = .move
        header.addsRefreshingInset = false
        header.beginRefreshing()
        spin(0.5)
        XCTAssertEqual(scrollView.cylInset.top, top, accuracy: 0.5, "addsRefreshingInset NO keeps the content in place")
        header.endRefreshing()
        spin(0.5)
    }

    func testBeginRefreshingBeforeTheListIsOnScreenOpensTheHeader() {
        // [EN] The demo pages call beginRefreshing in viewDidLoad, before the list has a window.
        // [CN] 示例页面在 viewDidLoad 中调用 beginRefreshing，那时列表还没有 window。
        let styles: [CYLRefreshHeader.Type] = [CYLRefreshDeliveryHeader.self, CYLRefreshBezierRadarHeader.self, CYLRefreshNormalHeader.self]
        for style in styles {
            let scrollView = UIScrollView(frame: window.bounds)
            scrollView.contentSize = CGSize(width: 375, height: 2000)
            let top = scrollView.cylInset.top
            let header = style.init()
            header.attach(to: scrollView)
            header.beginRefreshing()
            window.addSubview(scrollView)
            spin(0.6)
            XCTAssertTrue(header.isRefreshing, "\(style)")
            XCTAssertGreaterThan(scrollView.cylInset.top, top + 1, "\(style) pushes the content down")
            header.endRefreshing()
            spin(0.6)
            scrollView.removeFromSuperview()
        }
    }

    func testADemoPageOpensRefreshingInANavigationController() {
        let styles: [CYLRefreshHeader.Type] = [CYLRefreshNormalHeader.self, CYLRefreshBezierRadarHeader.self]
        for style in styles {
            let nav = UINavigationController(rootViewController: UIViewController())
            window.rootViewController = nav
            spin(0.2)
            let page = CYLDrawnDemoTableController(style: .grouped)
            page.style = style
            nav.pushViewController(page, animated: false)
            spin(0.8)
            _ = page.tableView
            XCTAssertTrue(page.header?.isRefreshing ?? false, "\(style)")
            page.header?.endRefreshing()
            spin(0.6)
            window.rootViewController = nil
        }
    }

    func testFrontModeStylesDrawWhilePulled() {
        let styles: [CYLRefreshDrawnHeader.Type] = [CYLRefreshMaterialHeader.self, CYLRefreshWaveSwipeHeader.self]
        for style in styles {
            let scrollView = self.scrollView()
            scrollView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
            scrollView.contentOffset = CGPoint(x: 0, y: -100)
            let header = style.attach(to: scrollView)
            spin(0.1)
            scrollView.contentOffset = CGPoint(x: 0, y: -100 - 90)
            spin(0.1)
            // [EN] These styles turn user interaction off; the header must still follow the scroll view and show.
            // [CN] 这些样式关闭了用户交互；刷新头仍须跟随滚动视图并显示。
            XCTAssertNil(header.layer.mask, "\(style) shows while pulled")
            XCTAssertEqual(header.dragOffset, -(scrollView.contentOffset.y + scrollView.adjustedContentInset.top), accuracy: 0.5)
            XCTAssertEqual(header.frame.minY, scrollView.contentOffset.y + scrollView.adjustedContentInset.top, accuracy: 0.5,
                           "\(style) is pinned at the visible top (front mode)")
            XCTAssertNil(header.hitTest(CGPoint(x: 10, y: 10), with: nil), "\(style) lets touches through")
            if style == CYLRefreshMaterialHeader.self {
                let shape = header.value(forKey: "shapeLayer") as? CAShapeLayer
                XCTAssertTrue(shape?.path != nil && !(shape?.path?.boundingBox.isEmpty ?? true), "the spinner is drawn")
            }
            // [EN] After the refresh ends and the list is back at rest, the header hides again (autoHideRefresh).
            // [CN] 刷新结束、列表回到静止后，刷新头再次隐藏（autoHideRefresh）。
            header.autoHideRefresh = true
            header.beginRefreshing()
            spin(0.4)
            XCTAssertNil(header.layer.mask, "\(style) shows while refreshing")
            scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.adjustedContentInset.top)
            header.endRefreshing()
            spin(1.0)
            XCTAssertEqual(header.state, .idle)
            XCTAssertNotNil(header.layer.mask, "\(style) hides after the refresh")
            scrollView.removeFromSuperview()
        }
    }

    func testDrawnFootersLoadAndShowNoMoreData() {
        let classes: [CYLRefreshDrawnFooter.Type] = [CYLRefreshBezierRadarFooter.self, CYLRefreshMaterialFooter.self,
                                                     CYLRefreshDeliveryFooter.self, CYLRefreshPhoenixFooter.self,
                                                     CYLRefreshTaurusFooter.self]
        for cls in classes {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
            window.isHidden = false
            // [EN] A plain scroll view: a table view with no rows resets its content size. [CN] 用普通滚动视图：没有行的表格会重置内容尺寸。
            let tableView = UIScrollView(frame: window.bounds)
            tableView.contentSize = CGSize(width: 320, height: 1200)
            window.addSubview(tableView)
            let footer = cls.attach(to: tableView)
            var loads = 0
            footer.refreshingBlock = { loads += 1 }
            XCTAssertNotNil(footer.style, "\(cls)")
            XCTAssertTrue(footer.style?.superview === footer, "\(cls) hosts its style")
            XCTAssertGreaterThan(footer.cylH, 0, "\(cls) takes the style's height")
            XCTAssertNil(footer.style?.layer.mask, "\(cls): the hosted style is never auto-hidden")

            // Pull: the style follows the distance pulled past the content's bottom.
            let bottom = 1200 - 480 + tableView.adjustedContentInset.bottom
            tableView.contentOffset = CGPoint(x: 0, y: bottom + 30)
            XCTAssertEqual(footer.style?.dragOffset ?? 0, 30, accuracy: 1, "\(cls)")
            XCTAssertEqual(footer.style?.frame.minY ?? -1, 0, accuracy: 0.01, "\(cls) stays inside the footer")

            footer.beginRefreshing()
            spin(until: { loads > 0 }, timeout: 15)
            XCTAssertEqual(loads, 1, "\(cls)")
            XCTAssertEqual(footer.style?.status, .refreshing, "\(cls)")
            XCTAssertTrue(footer.style?.isRefreshing ?? false, "\(cls)")
            XCTAssertTrue(footer.stateLabel?.isHidden ?? false, "\(cls): no text while loading")

            footer.endRefreshing()
            // [EN] The footer turns idle after its style's finishing delay; busy CI runners stretch that (a 5 s wait failed
            //      for CYLRefreshMaterialFooter on 5a8a601 while the test took 25 s), so wait up to 15 s.
            // [CN] footer 在样式的结束延时后回到空闲；CI 负载高时会变慢（5a8a601 上 5 秒等待失败，整个测试用时 25 秒），因此最多等 15 秒。
            let idle = spin(until: { footer.state == .idle }, timeout: 15)
            XCTAssertTrue(idle, "\(cls) still in state \(footer.state.rawValue) (style status \(footer.style?.status.rawValue ?? -1), finishing "
                          + String(format: "%.2f", footer.finishingDuration(withSuccess: true)) + " s) after endRefreshing")
            XCTAssertNotEqual(footer.style?.status, .refreshing, "\(cls)")

            footer.endRefreshingWithNoMoreData()
            XCTAssertFalse(footer.stateLabel?.isHidden ?? true, "\(cls): the no-more-data text shows")
            XCTAssertTrue(footer.style?.isHidden ?? false, "\(cls)")
            XCTAssertGreaterThan(footer.stateLabel?.text?.count ?? 0, 0, "\(cls)")
            window.isHidden = true
        }
    }

    /**
     * [EN] Renders each drawn footer pulled and loading into PNGs, only when CYL_SNAPSHOT_DIR is set (screenshots for
     *      docs; pass TEST_RUNNER_CYL_SNAPSHOT_DIR to xcodebuild). [CN] 仅在设置 CYL_SNAPSHOT_DIR 时，把每个手绘刷新尾在上拉与加载中的样子
     *      渲染为 PNG（用于文档截图；通过 xcodebuild 的 TEST_RUNNER_CYL_SNAPSHOT_DIR 传入）。
     */
    func testDrawnFooterSnapshots() {
        guard let dir = ProcessInfo.processInfo.environment["CYL_SNAPSHOT_DIR"], !dir.isEmpty else { return }
        let styles: [String: CYLRefreshDrawnFooter.Type] = ["BezierRadar": CYLRefreshBezierRadarFooter.self,
                                                            "Material": CYLRefreshMaterialFooter.self,
                                                            "Delivery": CYLRefreshDeliveryFooter.self,
                                                            "Phoenix": CYLRefreshPhoenixFooter.self,
                                                            "Taurus": CYLRefreshTaurusFooter.self]
        for (name, style) in styles {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 360))
            window.backgroundColor = .white
            window.isHidden = false
            let scrollView = CYLDraggingScrollView(frame: window.bounds)
            scrollView.backgroundColor = .white
            scrollView.contentSize = CGSize(width: 402, height: 600)
            for row in 0..<12 {
                let label = UILabel(frame: CGRect(x: 20, y: CGFloat(row) * 50, width: 362, height: 50))
                label.text = "Row \(row + 1)"
                scrollView.addSubview(label)
            }
            window.addSubview(scrollView)
            let footer = style.attach(to: scrollView)
            let bottom: CGFloat = 600 - 360
            for moment in ["pull", "loading"] {
                if moment == "pull" {
                    scrollView.fakeDragging = true
                    scrollView.contentOffset = CGPoint(x: 0, y: bottom + footer.cylH * 0.8)
                } else {
                    scrollView.fakeDragging = false
                    footer.beginRefreshing()
                }
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.8))
                window.layoutIfNeeded()
                let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
                let image = renderer.image { context in
                    window.layer.render(in: context.cgContext)
                }
                let path = (dir as NSString).appendingPathComponent("\(name)-\(moment).png")
                XCTAssertTrue((image.pngData() as NSData?)?.write(toFile: path, atomically: true) ?? false, path)
            }
            footer.endRefreshing()
            window.isHidden = true
        }
    }

    func testDrawnFooterOffsetWhileLoadingWithInsets() {
        for contentHeight in [300.0, 1200.0] as [CGFloat] {
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
            window.isHidden = false
            let scrollView = CYLDraggingScrollView(frame: window.bounds)
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.contentInset = UIEdgeInsets(top: 116, left: 0, bottom: 83, right: 0)
            scrollView.contentSize = CGSize(width: 402, height: contentHeight)
            window.addSubview(scrollView)
            let footer = CYLRefreshPhoenixFooter.attach(to: scrollView)
            scrollView.contentOffset = CGPoint(x: 0, y: -116)
            // A real release: drag past the trigger, then let go.
            let maxOffset = max(-116, contentHeight + 83 - 874)
            scrollView.fakeDragging = true
            scrollView.contentOffset = CGPoint(x: 0, y: maxOffset + footer.cylH * 1.3)
            scrollView.fakeDragging = false
            scrollView.contentOffset = CGPoint(x: 0, y: maxOffset + footer.cylH * 1.25)
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.8))
            NSLog("CYLDEBUG content=%@ state=%ld offset=%.1f insetB=%.1f drag=%.1f styleH=%.1f footerH=%.1f",
                  NSNumber(value: Double(contentHeight)), footer.state.rawValue, Double(scrollView.contentOffset.y),
                  Double(scrollView.contentInset.bottom), Double(footer.style?.dragOffset ?? 0), Double(footer.style?.cylH ?? 0),
                  Double(footer.cylH))
            XCTAssertEqual(footer.state, .refreshing, "content \(contentHeight)")
            XCTAssertGreaterThan(footer.style?.dragOffset ?? 0, footer.cylH * 0.5, "content \(contentHeight): the style still sees the open footer")
            footer.endRefreshing()
            window.isHidden = true
        }
    }

    // MARK: - Android parity options (docs/iOS-API-Map.md)

    func testMaterialColorsAndSize() {
        let header = CYLRefreshMaterialHeader()
        XCTAssertEqual(header.progressSize, .default)
        let defaultHeight = header.cylH
        header.progressSize = .large
        XCTAssertGreaterThan(header.cylH, defaultHeight, "LARGE is a bigger circle")
        let colors: [UIColor] = [.red, .green]
        header.colorSchemeColors = colors
        XCTAssertEqual(header.colorSchemeColors, colors)
        header.colorSchemeColors = []
        XCTAssertEqual(header.colorSchemeColors, colors, "an empty list is ignored")
    }

    func testWaveSwipeShadow() {
        let header = CYLRefreshWaveSwipeHeader()
        XCTAssertEqual(header.waveShadowRadius, 1.5, accuracy: 0.001)
        header.waveShadowRadius = 4
        header.waveShadowColor = UIColor.blue.withAlphaComponent(0.5)
        XCTAssertEqual(header.waveShadowRadius, 4, accuracy: 0.001)
        XCTAssertEqual(header.waveShadowColor.cgColor.alpha, 0.5, accuracy: 0.01)
    }

    func testBallPulseFooterLoadsAndStops() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        scrollView.contentSize = CGSize(width: 320, height: 2000)
        let footer = CYLRefreshBallPulseFooter(refreshingBlock: {})
        scrollView.cylFooter = footer
        footer.animatingColor = .orange
        footer.state = .refreshing
        XCTAssertTrue(footer.isRefreshing)
        footer.state = .noMoreData
        XCTAssertEqual(footer.state, .noMoreData)
        footer.state = .idle
    }
}
