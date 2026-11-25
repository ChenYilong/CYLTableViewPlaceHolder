//
//  CYLRefreshDrivenStylesTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] Every refresh style under `CYLRefreshDrivenLayout`: row 6 of the native bridge map (docs/Refresh-Library-Parity.md).
//       The drawn headers and footers read the layout's private scroll view through the same KVO as under a finger, so each
//       one runs a whole refresh fed by `drive(offset:dragging:startedAtEdge:)` and `release()`, follows the offset and draws.
//  [CN] `CYLRefreshDrivenLayout` 下的每种刷新样式：原生桥接表第 6 行（docs/Refresh-Library-Parity.md）。手绘刷新头与刷新尾通过与手指
//       下拉相同的 KVO 读取布局内的私有滚动视图，因此每种样式都由 `drive(offset:dragging:startedAtEdge:)` 与 `release()` 输入、
//       完成一次完整刷新、跟随偏移并绘制。
//

import XCTest
import UIKit

final class CYLRefreshDrivenStylesTests: XCTestCase {

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

    /// The number of pixels of `view` a render leaves not fully transparent. [CN] 渲染后 `view` 中不完全透明的像素数。
    private func drawnPixels(_ view: UIView) -> Int {
        let size = view.bounds.size
        guard size.width > 0, size.height > 0 else { return 0 }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            view.layer.render(in: context.cgContext)
        }
        guard let cg = image.cgImage, let data = cg.dataProvider?.data, let bytes = CFDataGetBytePtr(data) else { return 0 }
        let bytesPerPixel = cg.bitsPerPixel / 8
        var count = 0
        for index in stride(from: 0, to: CFDataGetLength(data) - 3, by: bytesPerPixel) where bytes[index + 3] > 0 { count += 1 }
        return count
    }

    private typealias Style = (name: String, make: () -> CYLRefreshHeader)

    private var headerStyles: [Style] {
        [("classic", { CYLRefreshNormalHeader(refreshingBlock: {}) }),
         ("cupertino", { CYLRefreshCupertinoHeader(refreshingBlock: {}) }),
         ("material", { CYLRefreshMaterialHeader(refreshingBlock: {}) }),
         ("bezierRadar", { CYLRefreshBezierRadarHeader(refreshingBlock: {}) }),
         ("bezierCircle", { CYLRefreshBezierCircleHeader(refreshingBlock: {}) }),
         ("delivery", { CYLRefreshDeliveryHeader(refreshingBlock: {}) }),
         ("phoenix", { CYLRefreshPhoenixHeader(refreshingBlock: {}) }),
         ("taurus", { CYLRefreshTaurusHeader(refreshingBlock: {}) })]
    }

    func testEveryHeaderStyleRunsAFullRefreshUnderTheDrivenLayout() {
        for style in headerStyles {
            let layout = CYLRefreshDrivenLayout(frame: window.bounds)
            window.addSubview(layout)
            var calls = 0
            let header = style.make()
            header.refreshingBlock = { calls += 1 }
            layout.header = header
            layout.layoutIfNeeded()
            spin(0.1)
            let h = header.expandHeight
            XCTAssertGreaterThan(h, 0, style.name)
            var phases = [CYLRefreshPhase]()
            header.addPhaseObserver { _, _, new in phases.append(new) }

            layout.drive(offset: h / 3, dragging: true)
            XCTAssertEqual(header.phase, .pullToRefresh, style.name)
            let early = header.pullingPercent
            XCTAssertEqual(early, 1.0 / 3 / header.triggerRate, accuracy: 0.05, style.name)
            layout.drive(offset: h * 2 / 3, dragging: true)
            XCTAssertGreaterThan(header.pullingPercent, early, "\(style.name): the percent follows the offset")
            XCTAssertEqual(header.dragOffset, h * 2 / 3, accuracy: 1, style.name)
            layout.drive(offset: h + 5, dragging: true)
            XCTAssertEqual(header.phase, .releaseToRefresh, style.name)
            XCTAssertEqual(header.state, .pulling, style.name)
            header.layoutIfNeeded()
            header.layer.displayIfNeeded()
            XCTAssertGreaterThan(drawnPixels(header), 0, "\(style.name) draws while pulled")

            layout.release()
            // The refreshing block runs in the completion of the 0.25 s inset animation, so wait for the call itself.
            XCTAssertTrue(spin(until: { calls == 1 }, timeout: 8), "\(style.name) calls the refreshing block")
            XCTAssertEqual(header.phase, .refreshing, style.name)
            XCTAssertEqual(calls, 1, style.name)
            XCTAssertGreaterThan(drawnPixels(header), 0, "\(style.name) draws while refreshing")
            header.endRefreshing()
            XCTAssertTrue(spin(until: { header.state == .idle }, timeout: 8), "\(style.name) ends idle")
            XCTAssertEqual(phases.first, .pullToRefresh, style.name)
            XCTAssertTrue(phases.contains(.releaseToRefresh) && phases.contains(.refreshing), "\(style.name): \(phases)")
            layout.removeFromSuperview()
        }
    }

    private typealias FooterStyle = (name: String, make: () -> CYLRefreshFooter)

    private var footerStyles: [FooterStyle] {
        [("classic", { CYLRefreshBackNormalFooter(refreshingBlock: {}) }),
         ("material", { CYLRefreshMaterialFooter(refreshingBlock: {}) }),
         ("bezierRadar", { CYLRefreshBezierRadarFooter(refreshingBlock: {}) }),
         ("delivery", { CYLRefreshDeliveryFooter(refreshingBlock: {}) }),
         ("phoenix", { CYLRefreshPhoenixFooter(refreshingBlock: {}) }),
         ("taurus", { CYLRefreshTaurusFooter(refreshingBlock: {}) })]
    }

    func testEveryDrawnFooterStyleRunsAFullLoadUnderTheDrivenLayout() {
        for style in footerStyles {
            let layout = CYLRefreshDrivenLayout(frame: window.bounds)
            window.addSubview(layout)
            var calls = 0
            let footer = style.make()
            footer.refreshingBlock = { calls += 1 }
            layout.footer = footer
            layout.layoutIfNeeded()
            spin(0.1)
            let h = footer.expandHeight
            XCTAssertGreaterThan(h, 0, style.name)

            layout.drive(offset: -(h / 3), dragging: true)
            XCTAssertEqual(footer.phase, .pullToRefresh, style.name)
            let early = footer.pullingPercent
            layout.drive(offset: -(h * 2 / 3), dragging: true)
            XCTAssertGreaterThan(footer.pullingPercent, early, "\(style.name): the percent follows the offset")
            layout.drive(offset: -(h + 5), dragging: true)
            XCTAssertEqual(footer.phase, .releaseToRefresh, style.name)
            footer.layoutIfNeeded()
            XCTAssertGreaterThan(drawnPixels(footer), 0, "\(style.name) draws while pulled")

            layout.release()
            // The refreshing block runs in the completion of the 0.25 s inset animation, so wait for the call itself.
            XCTAssertTrue(spin(until: { calls == 1 }, timeout: 8), "\(style.name) calls the refreshing block")
            XCTAssertEqual(footer.phase, .refreshing, style.name)
            XCTAssertEqual(calls, 1, style.name)
            XCTAssertGreaterThan(drawnPixels(footer), 0, "\(style.name) draws while loading")
            footer.endRefreshing()
            XCTAssertTrue(spin(until: { footer.state == .idle }, timeout: 8), "\(style.name) ends idle")
            layout.removeFromSuperview()
        }
    }

    func testTheCupertinoFooterLoadsOnReleaseAtTheBottom() {
        let layout = CYLRefreshDrivenLayout(frame: window.bounds)
        window.addSubview(layout)
        var calls = 0
        let footer = CYLRefreshCupertinoFooter(refreshingBlock: { calls += 1 })
        layout.footer = footer
        layout.layoutIfNeeded()
        spin(0.1)
        layout.drive(offset: -8, dragging: true)
        layout.release()
        XCTAssertTrue(spin(until: { calls == 1 }, timeout: 8), "the footer calls the refreshing block")
        XCTAssertTrue(footer.isRefreshing)
        XCTAssertEqual(calls, 1)
        footer.endRefreshing()
        XCTAssertTrue(spin(until: { !footer.isRefreshing }, timeout: 8))
    }
}
