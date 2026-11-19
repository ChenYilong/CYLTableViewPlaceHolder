import XCTest

/// MJRefresh PR #1444: a plain table with floating section headers (`-sections`, 8 s loads).
final class CYLSectionsUITests: XCTestCase {
    override func tearDown() {
        XCUIDevice.shared.orientation = .portrait
        super.tearDown()
    }

    // While the header refreshes, the content is dragged up: the section header that floats must pin where the content
    // starts (right below the navigation bar), not the refresh header's height lower; still so after the refresh ends.
    @MainActor
    func testFloatingSectionHeaderPinsBelowTheBarWhileRefreshing() {
        let app = launchSections()
        let table = app.tables["sectionsTable"]
        let section = app.staticTexts["section-0"]
        XCTAssertTrue(section.waitForExistence(timeout: 5))
        let restTop = section.frame.minY
        let lower = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let upper = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        app.buttons["Refresh"].tap()
        XCTAssertTrue(app.navigationBars["Header refreshing"].waitForExistence(timeout: 5))
        lower.press(forDuration: 0.1, thenDragTo: upper)
        sleep(1)
        XCTAssertTrue(app.navigationBars["Header refreshing"].exists, "the drag happens during the refresh")
        saveScreenshot("1444-1-pinned-while-refreshing")
        assertPinnedSectionHeader(app: app, restTop: restTop, step: "while refreshing")
        XCTAssertTrue(app.navigationBars["Header completed 1"].waitForExistence(timeout: 15))
        sleep(1)
        assertPinnedSectionHeader(app: app, restTop: restTop, step: "after the refresh")
    }

    // A rotation during the refresh changes the bars' height and the safe area, and the user drags the content
    // (resetting the header's inset) while refreshing: after the refresh, the content rests in landscape where it rests
    // without a refresh, and back in portrait exactly where it was at launch, with no gap left above it.
    @MainActor
    func testRotationDuringRefreshLeavesNoGapAboveTheContent() {
        let app = launchSections()
        let table = app.tables["sectionsTable"]
        let section = app.staticTexts["section-0"]
        XCTAssertTrue(section.waitForExistence(timeout: 5))
        let initialY = section.frame.minY
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(2)
        let landscapeY = section.frame.minY
        XCTAssertNotEqual(landscapeY, initialY, "the rotation changes the top inset")
        XCUIDevice.shared.orientation = .portrait
        sleep(2)
        XCTAssertEqual(section.frame.minY, initialY, accuracy: 2, "portrait again before the refresh")
        app.buttons["Refresh"].tap()
        XCTAssertTrue(app.navigationBars["Header refreshing"].waitForExistence(timeout: 5))
        XCUIDevice.shared.orientation = .landscapeLeft
        let lower = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
        let upper = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4))
        upper.press(forDuration: 0.1, thenDragTo: lower)
        XCTAssertTrue(app.navigationBars["Header refreshing"].exists, "the rotation and the drag happen during the refresh")
        saveScreenshot("1444-2-landscape-refreshing")
        XCTAssertTrue(app.navigationBars["Header completed 1"].waitForExistence(timeout: 15))
        sleep(2)
        saveScreenshot("1444-3-landscape-after-refresh")
        XCTAssertEqual(section.frame.minY, landscapeY, accuracy: 2, "landscape: the content rests where it does without a refresh")
        XCUIDevice.shared.orientation = .portrait
        sleep(2)
        saveScreenshot("1444-4-portrait-after-refresh")
        XCTAssertEqual(section.frame.minY, initialY, accuracy: 2, "portrait: back at the launch position")
    }

    @MainActor
    private func launchSections() -> XCUIApplication {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments = ["-sections"]
        app.launch()
        XCTAssertTrue(app.tables["sectionsTable"].waitForExistence(timeout: 10))
        return app
    }

    /// Once the content is scrolled up, the topmost section header pins at the content's top edge (section 0's resting
    /// top, `restTop`) or, while the next header pushes it away, up to one header height above it; never lower. With
    /// the refreshing inset left in place it would pin the refresh header's height (54 pt) lower.
    @MainActor
    private func assertPinnedSectionHeader(app: XCUIApplication, restTop: CGFloat, step: String) {
        let tops = (0..<10).compactMap { index -> CGFloat? in
            let header = app.staticTexts["section-\(index)"]
            return header.exists ? header.frame.minY : nil
        }
        print("CYLSECTIONS \(step): rest top \(restTop), section header tops \(tops)")
        XCTAssertGreaterThan(tops.count, 1, "\(step): the content is scrolled so that the next header shows")
        guard let pinned = tops.filter({ $0 >= restTop - 40 }).min() else {
            return XCTFail("\(step): no section header near the top: \(tops)")
        }
        XCTAssertLessThanOrEqual(pinned, restTop + 1, "\(step): the floating section header pins at the content's top edge")
        XCTAssertGreaterThanOrEqual(pinned, restTop - 33, "\(step): pinned header within one header height")
        // `isHittable` raises "Failed to determine hittability" once the cell is fully off screen (no activation
        // point), so check the frame: the first row is gone or lies above the content's top edge.
        let firstRow = app.cells["row-0-0"]
        XCTAssertTrue(!firstRow.exists || firstRow.frame.maxY <= restTop + 1, "\(step): the content is scrolled up")
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
