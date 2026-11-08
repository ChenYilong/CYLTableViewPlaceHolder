import XCTest

final class CYLExampleSwiftUIUITests: XCTestCase {
    @MainActor
    func testOriginalConfigurationLosesRefreshAfterDataUpdate() {
        let app = XCUIApplication()
        app.launchArguments.append("-reproduce-1628")
        app.launch()
        let button = app.buttons["Start refresh"]
        XCTAssertTrue(button.waitForExistence(timeout: 10))
        button.tap()
        XCTAssertTrue(app.staticTexts["Lost refresh"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testRefreshSurvivesSwiftUIDataUpdate() {
        let app = XCUIApplication()
        app.launch()
        let button = app.buttons["Start refresh"]
        XCTAssertTrue(button.waitForExistence(timeout: 10))
        button.tap()
        XCTAssertTrue(app.staticTexts["Refreshing"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Finished"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testPullGestureSurvivesSwiftUIDataUpdate() {
        let app = XCUIApplication()
        app.launch()
        let list = app.scrollViews["songList"]
        XCTAssertTrue(list.waitForExistence(timeout: 10))
        let start = list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let end = list.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
        start.press(forDuration: 0.1, thenDragTo: end)
        XCTAssertTrue(app.staticTexts["Refreshing"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Finished"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testRepresentedFooterSurvivesRepeatedNavigationTeardown() {
        let app = XCUIApplication()
        app.launch()
        let open = app.buttons["Open footer lifecycle"]
        XCTAssertTrue(open.waitForExistence(timeout: 10))
        for _ in 0..<5 {
            open.tap()
            let back = app.navigationBars.buttons.element(boundBy: 0)
            XCTAssertTrue(back.waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["Footer lifecycle"].waitForExistence(timeout: 5))
            back.tap()
            XCTAssertTrue(open.waitForExistence(timeout: 5))
        }
    }
}
