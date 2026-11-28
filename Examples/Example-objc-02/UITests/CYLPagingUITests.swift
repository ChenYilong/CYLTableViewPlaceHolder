import XCTest

final class CYLPagingUITests: XCTestCase {
    @MainActor
    func testRestoredPageStaysVisibleAndNextSwipeDoesNotReturnToFirstPage() {
        let app = XCUIApplication()
        app.launchArguments.append("-paging")
        app.launch()
        let table = app.tables["pagingTable"]
        XCTAssertTrue(table.waitForExistence(timeout: 10))
        app.buttons["Refresh"].tap()
        XCTAssertTrue(app.navigationBars["Refresh completed"].waitForExistence(timeout: 8))
        let restored = app.cells["page-2"]
        XCTAssertTrue(restored.waitForExistence(timeout: 5))
        XCTAssertTrue(restored.isHittable)
        table.swipeUp()
        let next = app.cells["page-3"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        XCTAssertTrue(next.isHittable)
        XCTAssertFalse(app.cells["page-0"].isHittable)
    }

    @MainActor
    func testAppendingPageRestoresPreviousPageAfterFooterRefresh() {
        let app = XCUIApplication()
        app.launchArguments.append("-paging")
        app.launch()
        let table = app.tables["pagingTable"]
        XCTAssertTrue(table.waitForExistence(timeout: 10))
        app.buttons["Last page"].tap()
        let page = app.cells["page-7"]
        XCTAssertTrue(page.waitForExistence(timeout: 5))
        let initialY = page.frame.minY
        log("1-last-page", table, page)
        let bottom = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
        let top = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15))
        bottom.press(forDuration: 0.1, thenDragTo: top)
        XCTAssertTrue(app.navigationBars["Load completed"].waitForExistence(timeout: 8))
        sleep(2)
        log("2-after-footer-load", table, page)
        XCTAssertTrue(page.isHittable)
        XCTAssertEqual(page.frame.minY, initialY, accuracy: 2)
        table.swipeUp()
        XCTAssertTrue(app.cells["page-8"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.cells["page-8"].isHittable)
    }

    // MJRefresh #1610: the automatic footer starts loading when a real swipe (with deceleration) reaches the end of the
    // last page; the load adds a page. When it ends, the table rests on a page boundary (the last page or the new one),
    // and the next swipe shows the new page aligned.
    @MainActor
    func testAutoFooterLoadAfterSwipeKeepsPagesAligned() {
        let app = launchAutoFooterPaging(extra: [])
        let table = app.tables["pagingTable"]
        app.buttons["Last page"].tap()
        XCTAssertTrue(app.cells["page-7"].waitForExistence(timeout: 5))
        swipeUpUntilLoadCompletes(app: app, table: table)
        sleep(2)
        log("1610-1-after-auto-load", table, app.cells["page-7"])
        assertAlignedPage(app: app, table: table, among: 6...8, step: "after the load")
        table.swipeUp()
        let next = app.cells["page-8"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        sleep(2)
        waitForTop(of: next, toMatch: table)
        XCTAssertTrue(next.isHittable)
        XCTAssertEqual(next.frame.minY, table.frame.minY, accuracy: 2, "the new page is aligned")
    }

    // MJRefresh #1610: the load returns no new page (the data does not change); the table goes back to the last page,
    // aligned, instead of keeping the footer's space or resetting the offset.
    @MainActor
    func testAutoFooterLoadWithoutNewDataReturnsToTheLastPage() {
        let app = launchAutoFooterPaging(extra: ["-pagingNoGrowth"])
        let table = app.tables["pagingTable"]
        app.buttons["Last page"].tap()
        let last = app.cells["page-7"]
        XCTAssertTrue(last.waitForExistence(timeout: 5))
        swipeUpUntilLoadCompletes(app: app, table: table)
        sleep(2)
        // The table may still be settling back after the footer ends (seen on CI: still 44 pt, the footer's height,
        // off after the 2 s sleep): wait for the resting position before asserting it.
        waitForTop(of: last, toMatch: table)
        log("1610-2-no-new-data", table, last)
        XCTAssertTrue(last.isHittable)
        XCTAssertEqual(last.frame.minY, table.frame.minY, accuracy: 2, "the last page is aligned")
        XCTAssertFalse(app.cells["page-8"].exists)
    }

    // MJRefresh #1610: the user swipes back while the load is still running, so the load ends during the deceleration;
    // the footer must not move the table, and paging leaves it on a page boundary.
    @MainActor
    func testAutoFooterLoadEndingDuringDecelerationKeepsPagesAligned() {
        let app = launchAutoFooterPaging(extra: [])
        let table = app.tables["pagingTable"]
        app.buttons["Last page"].tap()
        XCTAssertTrue(app.cells["page-7"].waitForExistence(timeout: 5))
        table.swipeUp()
        table.swipeDown(velocity: .slow)
        XCTAssertTrue(app.navigationBars["Load completed"].waitForExistence(timeout: 8))
        sleep(2)
        log("1610-3-ended-while-decelerating", table, app.cells["page-6"])
        assertAlignedPage(app: app, table: table, among: 5...8, step: "after a load that ended while decelerating")
    }

    @MainActor
    private func launchAutoFooterPaging(extra: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-paging", "-pagingAutoFooter"] + extra
        app.launch()
        XCTAssertTrue(app.tables["pagingTable"].waitForExistence(timeout: 10))
        return app
    }

    /// Swipes up on the last page until the automatic footer's load completes. On a slow CI runner a synthesized swipe
    /// sometimes ends before the footer's trigger (seen on CI: no load, the last page simply snaps back), so one more
    /// swipe is allowed before the test fails.
    @MainActor
    private func swipeUpUntilLoadCompletes(app: XCUIApplication, table: XCUIElement) {
        let completed = app.navigationBars["Load completed"]
        table.swipeUp()
        if completed.waitForExistence(timeout: 8) {
            return
        }
        table.swipeUp()
        XCTAssertTrue(completed.waitForExistence(timeout: 8), "the automatic footer loaded after a swipe on the last page")
    }

    /// Waits up to `timeout` seconds for `element` to start at `table`'s top edge (2 pt accuracy); the caller asserts.
    @MainActor
    private func waitForTop(of element: XCUIElement, toMatch table: XCUIElement, timeout: TimeInterval = 8) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if element.exists && abs(element.frame.minY - table.frame.minY) <= 2 {
                return
            }
            usleep(250_000)
        }
    }

    /// One of the pages in `range` starts exactly at the table's top edge (paging alignment).
    @MainActor
    private func assertAlignedPage(app: XCUIApplication, table: XCUIElement, among range: ClosedRange<Int>, step: String) {
        let tops = range.compactMap { index -> (Int, CGFloat)? in
            let cell = app.cells["page-\(index)"]
            return cell.exists ? (index, cell.frame.minY - table.frame.minY) : nil
        }
        print("CYLPAGING \(step): page offsets from the table top \(tops)")
        XCTAssertTrue(tops.contains { abs($0.1) <= 2 }, "\(step): no page is aligned to the table top: \(tops)")
    }

    /// Prints the table and page frames and saves a screenshot (see scripts/ci-build-example.sh), to locate #1430's offset.
    private func log(_ step: String, _ table: XCUIElement, _ page: XCUIElement) {
        print("CYLPAGING \(step) table=\(table.frame) page-7=\(page.exists ? page.frame : .zero) hittable=\(page.exists && page.isHittable)")
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = step
        attachment.lifetime = .keepAlways
        add(attachment)
        guard let directory = ProcessInfo.processInfo.environment["CYL_SCREENSHOT_DIR"], !directory.isEmpty else { return }
        let url = URL(fileURLWithPath: directory).appendingPathComponent("ExampleObjC02-paging-\(step).png")
        try? screenshot.pngRepresentation.write(to: url)
    }
}
