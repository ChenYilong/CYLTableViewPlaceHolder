//
//  CYLPlaceholderResourceReporterTests.swift
//  CYLTableViewPlaceHolder tests
//
//  A missing animation resource is named in the red status bar: the reporter (dedup, short names, clearing), the localized
//  text in every language, the hook in CYLPlaceholderView, and the bar of a view controller (offline text first).
//

import XCTest
import UIKit
import ObjectiveC

private var CYLHostedWindowKey: UInt8 = 0

private func CYLSetNetworkStatus(_ monitor: CYLPlaceholderNetworkMonitor, _ status: CYLPlaceholderNetworkStatus) {
    typealias Setter = @convention(c) (AnyObject, Selector, Int, Bool, Bool) -> Void
    let selector = NSSelectorFromString("cyl_setStatus:constrained:expensive:")
    let implementation = unsafeBitCast(monitor.method(for: selector), to: Setter.self)
    implementation(monitor, selector, status.rawValue, false, false)
}

final class CYLPlaceholderResourceReporterTests: XCTestCase {

    private let reporter = CYLPlaceholderResourceReporter.shared

    override func setUp() {
        super.setUp()
        CYLPlaceholderLocalization.language = "en"
        reporter.reset()
        reporter.onResourceMissing = nil
    }

    override func tearDown() {
        reporter.reset()
        reporter.onResourceMissing = nil
        CYLPlaceholderLocalization.language = nil
        super.tearDown()
    }

    func testAResourceIsReportedOnceAndNamedByItsLastPathSegment() {
        var calls = [String]()
        reporter.onResourceMissing = { resource, reason in calls.append("\(resource)|\(reason)") }
        XCTAssertEqual(CYLPlaceholderResourceReporter.shortName(of: "asset:Folder/home.pag"), "home.pag")
        XCTAssertEqual(CYLPlaceholderResourceReporter.shortName(of: "/var/x/Folder/bow.riv"), "bow.riv")
        XCTAssertEqual(CYLPlaceholderResourceReporter.shortName(of: "bow.riv"), "bow.riv")
        XCTAssertTrue(reporter.report(resource: "asset:Folder/home.pag", reason: "file not found", source: nil))
        XCTAssertFalse(reporter.report(resource: "/other/Folder/home.pag", reason: "file not found", source: nil),
                       "the core and the engine dedupe to one entry")
        XCTAssertEqual(calls, ["home.pag|file not found"])
        XCTAssertEqual(reporter.missingResourceNames, ["home.pag"])
    }

    func testAResolvedResourceIsClearedAndReportedAgainIfItGoesMissingAgain() {
        reporter.report(resource: "a.pag", reason: "file not found", source: nil)
        reporter.resolve(resource: "dir/a.pag", source: nil)
        XCTAssertEqual(reporter.missingResourceNames, [])
        XCTAssertNil(reporter.text(visibleIn: nil))
        XCTAssertTrue(reporter.report(resource: "a.pag", reason: "unreadable", source: nil))
        reporter.reset()
        XCTAssertEqual(reporter.missingResourceNames, [])
    }

    func testTheTextIsLocalizedAndSeveralResourcesReadFirstPlusMore() {
        reporter.report(resource: "a.pag", reason: "file not found", source: nil)
        XCTAssertEqual(reporter.text(visibleIn: nil), "Missing resource: a.pag (file not found)")
        reporter.report(resource: "b.riv", reason: "unreadable", source: nil)
        reporter.report(resource: "c.json", reason: "file not found", source: nil)
        XCTAssertEqual(reporter.text(visibleIn: nil), "Missing resources: a.pag +2 more")
        CYLPlaceholderLocalization.language = "zh-Hans"
        XCTAssertEqual(reporter.text(visibleIn: nil), "缺少资源：a.pag，另有 2 项")
        reporter.resolve(resource: "b.riv", source: nil)
        reporter.resolve(resource: "c.json", source: nil)
        XCTAssertEqual(reporter.text(visibleIn: nil), "缺少资源：a.pag（file not found）")
    }

    func testEveryLanguageHasBothKeysWithTheirPlaceholders() {
        for language in CYLPlaceholderLocalization.supportedLanguages {
            CYLPlaceholderLocalization.language = language
            let one = CYLPlaceholderLocalizedStringForKey("CYLPlaceholderResourceMissing", "?")
            let many = CYLPlaceholderLocalizedStringForKey("CYLPlaceholderResourcesMissing", "?")
            XCTAssertNotEqual(one, "?", language)
            XCTAssertNotEqual(many, "?", language)
            XCTAssertEqual(one.components(separatedBy: "%@").count - 1, 2, "\(language): resource and reason")
            XCTAssertTrue(many.contains("%1$@") && many.contains("%2$ld"), "\(language): first resource and the count")
        }
    }

    func testAPlaceholderViewReportsAMissingFileAndClearsItWhenItLoadsOrGoesAway() throws {
        var heard = [String]()
        var view: CYLPlaceholderView? = try CYLPlaceholderView(
            itemAttributes: [CYLPlaceholderItemTitle: "x",
                             CYLPlaceholderItemAnimationFilePath: "/nonexistent/Folder/gone.pag"], imageBundle: nil)
        view?.onResourceMissing = { resource, reason in heard.append("\(resource)|\(reason)") }
        XCTAssertEqual(reporter.missingResourceNames, ["gone.pag"])
        XCTAssertEqual(reporter.text(visibleIn: nil), "Missing resource: gone.pag (file not found)")
        XCTAssertEqual(view?.setAnimationFile("/nonexistent/Folder/other.riv"), false)
        XCTAssertEqual(reporter.missingResourceNames, ["other.riv"], "the old resource is cleared, the new one named")
        XCTAssertEqual(heard, ["other.riv|file not found"])
        let bundled = try XCTUnwrap(CYLPlaceholderView.path(forBundledAnimation: "CYLPlaceholderLoading.json"))
        if view?.setAnimationFile(bundled) == true {
            XCTAssertEqual(reporter.missingResourceNames, [], "a later load clears the entry")
        }
        view = nil
        XCTAssertEqual(reporter.missingResourceNames, [], "the page's views are gone, so the entry is")
    }

    func testSetAnimationFileReportsTheNameAsGiven() throws {
        let view = try CYLPlaceholderView(itemAttributes: [CYLPlaceholderItemTitle: "x"], imageBundle: nil)
        XCTAssertFalse(view.setAnimationFile("/nonexistent/Folder/missing.pag"))
        XCTAssertEqual(reporter.text(visibleIn: nil), "Missing resource: missing.pag (file not found)")
    }

    private func hostedTableController() -> UITableViewController {
        let controller = UITableViewController(style: .plain)
        let navigation = UINavigationController(rootViewController: controller)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.rootViewController = navigation
        window.isHidden = false
        window.layoutIfNeeded()
        objc_setAssociatedObject(controller, &CYLHostedWindowKey, window, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return controller
    }

    func testThePageShowsTheRedBarAndTheOfflineTextWins() {
        let controller = hostedTableController()
        XCTAssertNil(controller.cyl_statusView.superview, "off by default")
        controller.cyl_showsMissingResources = true
        XCTAssertNil(controller.cyl_statusView.superview, "nothing is missing")
        reporter.report(resource: "Folder/a.pag", reason: "file not found", source: nil)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.cyl_statusView.superview, controller.view)
        XCTAssertEqual(controller.cyl_statusView.text, "Missing resource: a.pag (file not found)")
        XCTAssertGreaterThanOrEqual(controller.additionalSafeAreaInsets.top, CYLPlaceholderStatusViewHight)

        let shared = CYLPlaceholderNetworkMonitor.shared
        controller.cyl_showsStatusViewWhenOffline = true
        CYLSetNetworkStatus(shared, .notReachable)
        XCTAssertEqual(controller.cyl_statusView.text, "Network unavailable, Check network", "offline wins")
        CYLSetNetworkStatus(shared, .reachableViaWiFi)
        XCTAssertEqual(controller.cyl_statusView.text, "Missing resource: a.pag (file not found)",
                       "the resource text returns with the network")
        reporter.resolve(resource: "a.pag", source: nil)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.6))
        XCTAssertNil(controller.cyl_statusView.superview, "cleared when the resource loads")
        XCTAssertEqual(controller.additionalSafeAreaInsets.top, 0, accuracy: 0.01)
        XCTAssertEqual(controller.cyl_statusView.text, "Network unavailable, Check network", "the bar's own text is back")
        controller.cyl_showsStatusViewWhenOffline = false
        shared.stopMonitoring()
    }

    func testAnotherPagesViewsDoNotShowOnThisPage() throws {
        let controller = hostedTableController()
        controller.cyl_showsMissingResources = true
        let other = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.addSubview(other)
        reporter.report(resource: "elsewhere.pag", reason: "file not found", source: other)
        XCTAssertNil(controller.cyl_statusView.superview)
        let mine = UIView()
        controller.view.addSubview(mine)
        reporter.report(resource: "mine.pag", reason: "unreadable", source: mine)
        XCTAssertEqual(controller.cyl_statusView.text, "Missing resource: mine.pag (unreadable)")
    }
}
