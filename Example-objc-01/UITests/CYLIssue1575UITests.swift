import XCTest

final class CYLIssue1575UITests: XCTestCase {
    @MainActor
    func testSceneDelegateCollectionRefreshCompletes() {
        let app = XCUIApplication()
        app.launch()
        let collection = app.collectionViews["issue1575Collection"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10))
        let start = collection.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let end = collection.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0.1, thenDragTo: end)
        XCTAssertTrue(app.navigationBars["Refreshing"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Finished"].waitForExistence(timeout: 8))
    }
}
