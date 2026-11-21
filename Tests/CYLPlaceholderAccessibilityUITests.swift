//
//  CYLPlaceholderAccessibilityUITests.swift
//  CYLTableViewPlaceHolder accessibility tests
//
//  Reads the accessibility tree that VoiceOver reads, in the host app from `Tests/AccessibilityHost`.
//

import XCTest

/**
 * Upper bound for the accessibility tree to catch up: on loaded CI runners one element query can take ~9 s.
 */
private let CYLTestTimeout: TimeInterval = 30

final class CYLPlaceholderAccessibilityUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func waitForElement(_ element: XCUIElement, selected: Bool) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "selected == %@", NSNumber(value: selected)),
                                                    object: element)
        return XCTWaiter.wait(for: [expectation], timeout: CYLTestTimeout) == .completed
    }

    func testPlaceholderElementAnnouncesBadgeOnce() {
        let element = element("element")
        XCTAssertTrue(element.waitForExistence(timeout: CYLTestTimeout))
        XCTAssertEqual(element.label, "Inbox")
        XCTAssertEqual(element.value as? String, "Synced, 3")
        XCTAssertFalse(element.isSelected)
        // The badge label is not a second VoiceOver stop.
        XCTAssertFalse(self.element("elementBadge").exists)

        // Wait for the accessibility tree to report the new state; on loaded CI runners it can
        // lag behind the tap, as the badge-clearing check below already allows for.
        self.element("toggle").tap()
        XCTAssertTrue(waitForElement(element, selected: true))
        self.element("toggle").tap()
        XCTAssertTrue(waitForElement(element, selected: false))

        self.element("clear").tap()
        let cleared = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "Synced"), object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [cleared], timeout: CYLTestTimeout), .completed)
    }

    func testBadgeInAccessibleContainerIsReadOnItsOwn() {
        let badge = element("groupBadge")
        XCTAssertTrue(badge.waitForExistence(timeout: CYLTestTimeout))
        XCTAssertEqual(badge.label, "New")
        XCTAssertTrue(element("groupTitle").exists)
        element("clear").tap()
        // The accessibility tree refreshes asynchronously after the badge view is removed.
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == NO"), object: element("groupBadge"))
        XCTAssertEqual(XCTWaiter.wait(for: [gone], timeout: CYLTestTimeout), .completed)
    }

    func testAccessibilityAudit() {
        XCTAssertTrue(element("element").waitForExistence(timeout: CYLTestTimeout))
        auditCurrentApp()
    }

    /**
     * The same audit with one part of the host at a time, so an issue names its view.
     */
    func testAccessibilityAuditPerPart() {
        continueAfterFailure = true
        for part in ["element", "group", "buttons"] {
            app.terminate()
            app.launchArguments = ["-CYLShow", part]
            app.launch()
            NSLog("CYLAccessibilityAudit: part %@", part)
            auditCurrentApp()
        }
    }

    private func auditCurrentApp() {
        guard #available(iOS 17.0, *) else { return }
        // Every reported issue fails. An audit that errors out without reporting any issue (seen on CI as
        // com.apple.xcode.xctest.accessibilityAudit -56 right after a relaunch) is a tool failure: retry it.
        for attempt in 1...3 {
            var issues = 0
            do {
                try app.performAccessibilityAudit(for: .all) { issue in
                    issues += 1
                    NSLog("CYLAccessibilityAudit: %@ | %@ | %@", issue.compactDescription, issue.detailedDescription,
                          String(describing: issue.element))
                    return false
                }
                return
            } catch {
                if issues > 0 || attempt == 3 {
                    XCTFail("Accessibility audit failed (\(issues) issues): \(error)")
                    return
                }
                NSLog("CYLAccessibilityAudit: audit error without issues, retrying (%@)", String(describing: error))
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 2))
            }
        }
    }
}
