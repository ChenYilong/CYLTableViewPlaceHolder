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
        let bottom = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
        let top = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15))
        bottom.press(forDuration: 0.1, thenDragTo: top)
        XCTAssertTrue(app.navigationBars["Load completed"].waitForExistence(timeout: 8))
        XCTAssertTrue(page.isHittable)
        XCTAssertEqual(page.frame.minY, initialY, accuracy: 2)
        table.swipeUp()
        XCTAssertTrue(app.cells["page-8"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.cells["page-8"].isHittable)
    }
}
