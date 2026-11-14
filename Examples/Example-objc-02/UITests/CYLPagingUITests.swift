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
