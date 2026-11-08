import XCTest

final class CYLCollectionAnimationUITests: XCTestCase {
    @MainActor
    func testHeaderAndFooterRefreshComplete() {
        let app = XCUIApplication()
        app.launch()
        let collection = app.collectionViews["issue1523Collection"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10))
        let top = collection.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15))
        let bottom = collection.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        top.press(forDuration: 0.1, thenDragTo: bottom)
        XCTAssertTrue(app.navigationBars["Header completed 1"].waitForExistence(timeout: 8))
        for _ in 0..<4 {
            collection.swipeUp()
        }
        bottom.press(forDuration: 0.1, thenDragTo: top)
        XCTAssertTrue(app.navigationBars["Footer completed"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testRepeatedHeaderRefreshKeepsFirstItemPosition() {
        let app = XCUIApplication()
        app.launch()
        let collection = app.collectionViews["issue1523Collection"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10))
        let first = app.cells["item-0"]
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        let initialY = first.frame.minY
        let top = collection.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15))
        let bottom = collection.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        for index in 1...4 {
            top.press(forDuration: 0.1, thenDragTo: bottom)
            XCTAssertTrue(app.navigationBars["Header completed \(index)"].waitForExistence(timeout: 8))
            sleep(1)
            XCTAssertTrue(first.exists)
            XCTAssertEqual(first.frame.minY, initialY, accuracy: 2)
        }
    }
}
