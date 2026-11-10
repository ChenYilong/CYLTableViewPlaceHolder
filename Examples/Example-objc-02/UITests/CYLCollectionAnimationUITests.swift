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

    // Reported with #1523: after scrolling to the end and loading more (nothing new arrives), the header must return to
    // where it was at launch, laid out from the navigation bar's origin like the content, not lower.
    @MainActor
    func testHeaderReturnsAfterFooterLoad() {
        headerReturnsAfterFooterLoad(arguments: [], name: "footer")
    }

    @MainActor
    func testHeaderReturnsAfterFooterLoadWithNoMoreData() {
        headerReturnsAfterFooterLoad(arguments: ["-noMoreData"], name: "nomoredata")
    }

    @MainActor
    private func headerReturnsAfterFooterLoad(arguments: [String], name: String) {
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        let collection = app.collectionViews["issue1523Collection"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10))
        let first = app.cells["item-0"]
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        sleep(1)
        let initialFirstY = first.frame.minY
        let header = app.staticTexts["Pull down to refresh"]
        let initialHeaderY: CGFloat? = header.exists ? header.frame.minY : nil
        saveScreenshot("\(name)-1-launch")
        assertRestingLayout(app: app, collection: collection, first: first, header: header, step: "launch")

        let top = collection.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15))
        let bottom = collection.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        for _ in 0..<4 {
            collection.swipeUp()
        }
        bottom.press(forDuration: 0.1, thenDragTo: top)
        XCTAssertTrue(app.navigationBars["Footer completed"].waitForExistence(timeout: 8))
        sleep(2)
        saveScreenshot("\(name)-2-after-footer")

        // Tapping the status bar scrolls to the top without pulling the header.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01)).tap()
        sleep(2)
        saveScreenshot("\(name)-3-back-at-top")
        XCTAssertTrue(app.navigationBars["Footer completed"].exists, "scrolling back must not start a header refresh")
        XCTAssertEqual(first.frame.minY, initialFirstY, accuracy: 2, "the content returns to its launch position")
        if let initialHeaderY {
            XCTAssertTrue(header.exists)
            XCTAssertEqual(header.frame.minY, initialHeaderY, accuracy: 2, "the header returns to its launch position")
        }
        assertRestingLayout(app: app, collection: collection, first: first, header: header, step: "back at top")
    }

    /// The resting layout the issue reporter expects, in absolute terms (not only "same as launch"): the content is
    /// laid out from the navigation bar's origin, so the first item sits just below the bar (bar bottom + the 20 pt
    /// section inset), and the idle header stays behind the bar instead of showing below it.
    @MainActor
    private func assertRestingLayout(app: XCUIApplication, collection: XCUIElement, first: XCUIElement,
                                     header: XCUIElement, step: String) {
        let bar = app.navigationBars.firstMatch
        XCTAssertTrue(bar.exists, "\(step): navigation bar")
        XCTAssertLessThanOrEqual(collection.frame.minY, bar.frame.minY,
                                 "\(step): the collection view shares the navigation bar's y origin, not below it")
        XCTAssertEqual(first.frame.minY, bar.frame.maxY + 20, accuracy: 2,
                       "\(step): the first item sits right below the navigation bar")
        if header.exists {
            XCTAssertLessThanOrEqual(header.frame.maxY, bar.frame.maxY + 1,
                                     "\(step): the idle header must not show below the navigation bar")
        }
    }


    /// Saves a screenshot to CYL_SCREENSHOT_DIR (set by scripts/ci-build-example.sh through TEST_RUNNER_) and attaches it.
    private func saveScreenshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        guard let directory = ProcessInfo.processInfo.environment["CYL_SCREENSHOT_DIR"], !directory.isEmpty else {
            return
        }
        let url = URL(fileURLWithPath: directory).appendingPathComponent("ExampleObjC02-\(name).png")
        try? screenshot.pngRepresentation.write(to: url)
    }
}
