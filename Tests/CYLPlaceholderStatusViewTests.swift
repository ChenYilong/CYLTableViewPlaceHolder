//
//  CYLPlaceholderStatusViewTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The status bar ported from CYLChatKit (CYLPlaceholderStatusView), its network monitor and its display with a
//       placeholder. Swift since step 13 of docs/Swift-Migration.md (was CYLPlaceholderStatusViewTests.m).
//  [CN] 从 CYLChatKit 移植的状态条（CYLPlaceholderStatusView）、其网络监视器以及与占位图一起的显示方式。
//       自 docs/Swift-Migration.md 第 13 步起用 Swift 编写（原 CYLPlaceholderStatusViewTests.m）。
//

import XCTest
import UIKit
import ObjectiveC

/**
 * [EN] The key under which a hosted controller keeps its window alive. [CN] 托管的视图控制器保存其窗口所用的键。
 */
private var CYLHostedWindowKey: UInt8 = 0

/**
 * [EN] The monitor's update, called directly: tests cannot switch the device's network. The Swift method is private to
 *      the monitor, so it is called by its Objective-C selector, as the Objective-C test did through a category.
 * [CN] 直接调用监视器的更新：测试无法切换设备网络。该 Swift 方法是监视器的私有方法，因此与原 Objective-C 测试（通过分类）
 *      一样按 Objective-C 选择器调用。
 */
private func CYLSetNetworkStatus(_ monitor: CYLPlaceholderNetworkMonitor, _ status: CYLPlaceholderNetworkStatus,
                                 constrained: Bool, expensive: Bool) {
    typealias Setter = @convention(c) (AnyObject, Selector, Int, Bool, Bool) -> Void
    let selector = NSSelectorFromString("cyl_setStatus:constrained:expensive:")
    let implementation = unsafeBitCast(monitor.method(for: selector), to: Setter.self)
    implementation(monitor, selector, status.rawValue, constrained, expensive)
}

/**
 * [EN] Calls an Objective-C initializer that Swift cannot call (its `Any`-taking entry point is hidden from Swift) with
 *      `arguments` and an error pointer, keeping Objective-C's ownership: `+alloc` returns a retained object that the
 *      initializer consumes, and the initializer returns a retained object or nil.
 * [CN] 调用 Swift 无法调用的 Objective-C 初始化方法（其接受 `Any` 的入口对 Swift 隐藏），传入 `arguments` 与错误指针，并保持
 *      Objective-C 的所有权规则：`+alloc` 返回已持有的对象，初始化方法消耗它，并返回已持有的对象或 nil。
 */
private func CYLObjectiveCInit(_ cls: AnyClass, _ selectorName: String, _ arguments: [AnyObject?],
                               _ error: inout NSError?) -> AnyObject? {
    typealias Alloc = @convention(c) (AnyClass, Selector) -> Unmanaged<AnyObject>
    typealias Init1 = @convention(c) (Unmanaged<AnyObject>, Selector, AnyObject?,
                                      AutoreleasingUnsafeMutablePointer<NSError?>?) -> Unmanaged<AnyObject>?
    typealias Init2 = @convention(c) (Unmanaged<AnyObject>, Selector, AnyObject?, AnyObject?,
                                      AutoreleasingUnsafeMutablePointer<NSError?>?) -> Unmanaged<AnyObject>?
    let allocSelector = NSSelectorFromString("alloc")
    let alloc = unsafeBitCast(class_getMethodImplementation(object_getClass(cls), allocSelector), to: Alloc.self)
    let selector = NSSelectorFromString(selectorName)
    let initializer = class_getMethodImplementation(cls, selector)
    let allocated = alloc(cls, allocSelector)
    var thrown: NSError?
    let result: Unmanaged<AnyObject>?
    switch arguments.count {
    case 1: result = unsafeBitCast(initializer, to: Init1.self)(allocated, selector, arguments[0], &thrown)
    default: result = unsafeBitCast(initializer, to: Init2.self)(allocated, selector, arguments[0], arguments[1], &thrown)
    }
    error = thrown
    return result?.takeRetainedValue()
}

/**
 * [EN] Calls `-[UIViewController cyl_applyStatusConfiguration:error:]`, the `Any`-taking entry point hidden from Swift.
 * [CN] 调用对 Swift 隐藏、接受 `Any` 的 `-[UIViewController cyl_applyStatusConfiguration:error:]`。
 */
private func CYLApplyObjectiveCStatusConfiguration(_ controller: UIViewController, _ configuration: AnyObject,
                                                   _ error: inout NSError?) -> Bool {
    typealias Apply = @convention(c) (AnyObject, Selector, AnyObject, AutoreleasingUnsafeMutablePointer<NSError?>?) -> Bool
    let selector = NSSelectorFromString("cyl_applyStatusConfiguration:error:")
    var thrown: NSError?
    let applied = unsafeBitCast(controller.method(for: selector), to: Apply.self)(controller, selector, configuration, &thrown)
    error = thrown
    return applied
}

/**
 * [EN] Runs `body` and returns its value, or nil with the thrown error in `error` (the Objective-C `error:` pattern).
 * [CN] 运行 `body` 并返回其值；抛出错误时返回 nil，并把错误写入 `error`（Objective-C 的 `error:` 模式）。
 */
private func captureError<T>(_ error: inout NSError?, _ body: () throws -> T) -> T? {
    do {
        return try body()
    } catch let thrown as NSError {
        error = thrown
        return nil
    }
}

/**
 * [EN] The status bar ported from CYLChatKit (CYLPlaceholderStatusView), its network monitor and its display with a
 *      placeholder.
 * [CN] 从 CYLChatKit 移植的状态条（CYLPlaceholderStatusView）、其网络监视器以及与占位图一起的显示方式。
 */
final class CYLPlaceholderStatusViewTests: XCTestCase, CYLPlaceholderStatusViewDelegate {

    private var clicks = 0

    override func setUp() {
        super.setUp()
        CYLPlaceholderLocalization.language = "en"
        clicks = 0
    }

    override func tearDown() {
        CYLPlaceholderLocalization.language = nil
        super.tearDown()
    }

    func statusViewClicked(_ sender: Any) {
        XCTAssertTrue(sender is CYLPlaceholderStatusView)
        clicks += 1
    }

    private func windowHosting(_ view: UIView) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        view.frame = window.bounds
        window.addSubview(view)
        window.layoutIfNeeded()
        return window
    }

    func testTheNetworkBarKeepsChatKitsAPIAndDrawsTheIconBeforeTheTitle() {
        XCTAssertEqual(CYLPlaceholderStatusViewHight, 44, accuracy: 0.01)
        XCTAssertEqual(CYLPlaceholderStatusViewHeight, CYLPlaceholderStatusViewHight, accuracy: 0.01)
        let bar = CYLPlaceholderStatusView(frame: CGRect(x: 0, y: 0, width: 375, height: CYLPlaceholderStatusViewHight))
        XCTAssertEqual(bar.text, "Network unavailable, Check network")
        XCTAssertNotNil(bar.placeholderView.imageView.image, "the ChatKit icon is in the core bundle")
        XCTAssertEqual(bar.placeholderView.backgroundColor, UIColor.clear, "the red is the parent's")
        XCTAssertNotNil(bar.backgroundColor)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.addSubview(bar)
        bar.layoutIfNeeded()
        bar.placeholderView.layoutIfNeeded()
        let icon = bar.convert(bar.placeholderView.imageView.frame, from: bar.placeholderView.imageView.superview)
        let title = bar.convert(bar.placeholderView.textLabel.frame, from: bar.placeholderView.textLabel.superview)
        XCTAssertEqual(icon.width, 20, accuracy: 0.5, "drawn at 20 points, as ChatKit")
        XCTAssertLessThanOrEqual(icon.maxX, title.minX, "the title follows the icon")
        XCTAssertEqual(icon.midY, bar.bounds.midY, accuracy: 1)
        XCTAssertEqual(title.midY, bar.bounds.midY, accuracy: 1)
        XCTAssertLessThan(icon.minX, 40, "aligned to the leading edge")
        XCTAssertGreaterThanOrEqual(bar.intrinsicContentSize.height, CYLPlaceholderStatusViewHight)
    }

    func testTapsReachTheDelegateAndHandlerAndOnlyThenMakeAButton() {
        let bar = CYLPlaceholderStatusView(frame: .zero)
        XCTAssertFalse(bar.placeholderView.isTapInteractive, "nobody listens: plain text")
        bar.delegate = self
        XCTAssertTrue(bar.placeholderView.isTapInteractive)
        var handled = 0
        bar.tapHandler = { _ in handled += 1 }
        XCTAssertTrue(bar.placeholderView.performTap())
        XCTAssertEqual(clicks, 1)
        XCTAssertEqual(handled, 1)
        bar.text = "Reconnecting…"
        XCTAssertEqual(bar.placeholderView.textLabel.text, "Reconnecting…")
    }

    func testCustomAttributesKeepTheHorizontalLayoutAndRejectBadValues() {
        var error: NSError?
        let bar = captureError(&error) {
            try CYLPlaceholderStatusView(itemAttributes: [
                CYLPlaceholderItemTitle: "Offline mode",
                CYLPlaceholderItemBackgroundColor: UIColor.orange,
            ])
        }
        XCTAssertNotNil(bar, "\(String(describing: error))")
        XCTAssertEqual(bar?.backgroundColor, UIColor.orange)
        XCTAssertEqual(bar?.text, "Offline mode")
        XCTAssertNotNil(bar?.placeholderView.imageView.image, "the failure icon stays without a custom image")
        let diagonal: [String: Any] = [CYLPlaceholderItemTitle: "x", CYLPlaceholderItemContentAxis: "diagonal"]
        XCTAssertNil(captureError(&error) { try CYLPlaceholderView(itemAttributes: diagonal, imageBundle: nil) })
        XCTAssertNotNil(error)
    }

    private func hostedTableController() -> UITableViewController {
        let controller = UITableViewController(style: .plain)
        controller.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let navigation = UINavigationController(rootViewController: controller)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.rootViewController = navigation
        window.isHidden = false
        window.layoutIfNeeded()
        objc_setAssociatedObject(controller, &CYLHostedWindowKey, window, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return controller
    }

    private func spinMainQueue() {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
    }

    // [EN] Runs the main queue until the condition holds, up to 10 s: a fixed 0.1 s was too short on a busy CI runner
    //      (a697ce6: the placeholder was not in the empty table yet; the test took 10.8 s).
    // [CN] 运行主队列直到条件成立，最多 10 秒：CI 机器繁忙时固定 0.1 秒太短（a697ce6：占位视图尚未加入空列表，测试用时 10.8 秒）。
    private func spinMainQueue(until condition: () -> Bool) {
        let deadline = Date(timeIntervalSinceNow: 10)
        repeat {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        } while !condition() && deadline.timeIntervalSinceNow > 0
    }

    func testTheBarAndThePlaceholderAreIndependentAndChosenByOneParameter() {
        let controller = hostedTableController()
        XCTAssertEqual(controller.cyl_statusDisplay, .placeholder, "nothing changes by default")
        XCTAssertNil(controller.cyl_statusView.superview)
        XCTAssertEqual(controller.cyl_placeholderScrollView, controller.tableView, "a table view controller's own table")

        controller.cyl_statusDisplay = .all
        controller.view.layoutIfNeeded()
        let bar: CYLPlaceholderStatusView = controller.cyl_statusView
        XCTAssertEqual(bar.superview, controller.view, "added to the controller's view, as CYLChatKit does")
        XCTAssertGreaterThanOrEqual(controller.additionalSafeAreaInsets.top, CYLPlaceholderStatusViewHight,
                                    "the content starts below the bar")
        XCTAssertFalse(controller.tableView.cyl_placeholderHidden)
        XCTAssertEqual(bar.bounds.width, 375, accuracy: 0.5)

        controller.cyl_statusDisplay = .statusBar
        XCTAssertTrue(controller.tableView.cyl_placeholderHidden, "only the bar")
        XCTAssertNotNil(bar.superview)

        controller.cyl_statusDisplay = .placeholder
        XCTAssertNil(bar.superview, "only the placeholder")
        XCTAssertEqual(controller.additionalSafeAreaInsets.top, 0, accuracy: 0.01, "the safe area is restored")
        XCTAssertFalse(controller.tableView.cyl_placeholderHidden)

        let custom = try? CYLPlaceholderStatusView(itemAttributes: [CYLPlaceholderItemTitle: "Offline"])
        controller.cyl_statusDisplay = .all
        controller.cyl_statusView = custom
        XCTAssertEqual(custom?.superview, controller.view, "replaced in place")
        XCTAssertNil(bar.superview)
        controller.cyl_statusView = nil
        XCTAssertEqual(controller.cyl_statusView.text, "Network unavailable, Check network", "nil restores the network bar")
        controller.cyl_statusDisplay = []
        XCTAssertTrue(controller.tableView.cyl_placeholderHidden)
        XCTAssertNil(controller.cyl_statusView.superview)
    }

    func testAHiddenPlaceholderStaysAwayFromAnEmptyList() {
        let controller = hostedTableController()
        let table = controller.tableView!
        let placeholder = UIView()
        table.cyl_placeholderViewBlock { _ in placeholder }
        table.reloadData()
        spinMainQueue { placeholder.superview === table }
        XCTAssertEqual(placeholder.superview, table, "an empty list shows its placeholder")
        table.cyl_placeholderHidden = true
        spinMainQueue { placeholder.superview == nil }
        XCTAssertNil(placeholder.superview)
        table.cyl_placeholderHidden = false
        spinMainQueue { placeholder.superview === table }
        XCTAssertEqual(placeholder.superview, table)
        table.cyl_placeholderViewBlock(nil)
    }

    func testTheNetworkMonitorKeepsChatKitsStatusesAndAddsTheBarWhenOffline() {
        let monitor = CYLPlaceholderNetworkMonitor()
        XCTAssertEqual(monitor.networkStatus, .unknown)
        XCTAssertTrue(monitor.isReachable, "unknown is not offline, so no bar flashes at launch")
        XCTAssertEqual(CYLPlaceholderNetworkStatus.notReachable.rawValue, 0)
        XCTAssertEqual(CYLPlaceholderNetworkStatus.reachableViaWWAN.rawValue, 1)
        XCTAssertEqual(CYLPlaceholderNetworkStatus.reachableViaWiFi.rawValue, 2)
        var changes = 0
        monitor.setNetworkStatusChangeBlock { _ in changes += 1 }
        expectation(forNotification: CYLPlaceholderNetworkMonitor.statusDidChangeNotification, object: monitor, handler: nil)
        CYLSetNetworkStatus(monitor, .notReachable, constrained: false, expensive: false)
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(monitor.isReachable)
        XCTAssertEqual(changes, 1)
        CYLSetNetworkStatus(monitor, .notReachable, constrained: false, expensive: false)
        XCTAssertEqual(changes, 1, "the same status is not reported twice")
        XCTAssertEqual(CYLPlaceholderNetworkMonitor.name(for: .reachableViaWiFi), "Wi-Fi")

        let controller = hostedTableController()
        let shared = CYLPlaceholderNetworkMonitor.shared
        controller.cyl_showsStatusViewWhenOffline = true
        XCTAssertTrue(shared.isMonitoring)
        CYLSetNetworkStatus(shared, .notReachable, constrained: false, expensive: false)
        XCTAssertEqual(controller.cyl_statusView.superview, controller.view, "offline adds the bar")
        XCTAssertEqual(controller.cyl_statusDisplay, .placeholder, "the chosen display is kept")
        CYLSetNetworkStatus(shared, .reachableViaWiFi, constrained: false, expensive: false)
        XCTAssertEqual(controller.additionalSafeAreaInsets.top, 0, accuracy: 0.01, "back online removes it")
        controller.cyl_showsStatusViewWhenOffline = false
        shared.stopMonitoring()
        XCTAssertEqual(shared.networkStatus, .unknown)
    }

    func testConfigurationFilesChooseTheBarAndTheDisplay() {
        var error: NSError?
        let bar = captureError(&error) {
            try CYLPlaceholderStatusView(configuration: [
                "textKey": "CYLPlaceholderStatusNetworkUnavailable", "accessibilityIdentifier": "bar"])
        }
        XCTAssertEqual(bar?.text, "Network unavailable, Check network", "\(String(describing: error))")
        XCTAssertNil(captureError(&error) { try CYLPlaceholderStatusView(configuration: ["text": 7]) })

        let controller = hostedTableController()
        let statusOnly: [String: Any] = ["statusBar": ["text": "Server busy"], "display": "status"]
        XCTAssertNotNil(captureError(&error) { try controller.cyl_applyStatusConfiguration(statusOnly) },
                        "\(String(describing: error))")
        XCTAssertEqual(controller.cyl_statusView.text, "Server busy")
        XCTAssertTrue(controller.tableView.cyl_placeholderHidden)
        XCTAssertNotNil(captureError(&error) { try controller.cyl_applyStatusConfiguration(["statusBar": true]) })
        XCTAssertEqual(controller.cyl_statusDisplay, .all, "a bar without \"display\" shows with the placeholder")
        XCTAssertEqual(controller.cyl_statusView.text, "Network unavailable, Check network")
        XCTAssertNil(captureError(&error) { try controller.cyl_applyStatusConfiguration(["display": "banner"]) })
        XCTAssertEqual(controller.cyl_statusDisplay, .all, "an invalid file changes nothing")
        XCTAssertNil(captureError(&error) { try controller.cyl_applyStatusConfiguration(["statusBar": "red"]) })
        XCTAssertNotNil(captureError(&error) { try controller.cyl_applyStatusConfiguration([:]) })
        XCTAssertEqual(controller.cyl_statusDisplay, .placeholder)
    }

    func testConfigurationsThatAreNotDictionariesReturnTheConfigurationError() {
        // [EN] A configuration read from JSON is `id`: an array or a string returns nil / NO with the configuration error, as
        //      the Objective-C code did, instead of crashing in the Swift bridge (regression of the Swift port a3c02c1).
        //      Swift's typed API cannot pass them, so the Objective-C entry points (hidden from Swift) are called by
        //      their selectors; Tests/CYLObjectiveCAPISmokeTests.m calls them from Objective-C too.
        // [CN] 从 JSON 读取的配置是 `id`：数组或字符串返回 nil / NO 与配置错误，与原 Objective-C 代码一致，而不是在 Swift 桥接时崩溃
        //      （Swift 迁移 a3c02c1 的回归）。Swift 的类型化 API 无法传入它们，因此按选择器调用对 Swift 隐藏的 Objective-C 入口；
        //      Tests/CYLObjectiveCAPISmokeTests.m 也从 Objective-C 调用它们。
        let controller = hostedTableController()
        let configurations: [AnyObject] = [[["text": "Server busy"]] as NSArray, "statusBar" as NSString]
        for configuration in configurations {
            var error: NSError?
            XCTAssertNil(CYLObjectiveCInit(CYLPlaceholderStatusView.self, "initWithConfiguration:error:", [configuration], &error),
                         "\(configuration)")
            XCTAssertEqual(error?.domain, CYLPlaceholderConfigurationErrorDomain)
            XCTAssertEqual(error?.code, CYLPlaceholderConfigurationError.Code.statusView.rawValue)
            XCTAssertEqual(error?.localizedDescription, "The status bar configuration must be a dictionary.")

            error = nil
            XCTAssertNil(CYLObjectiveCInit(CYLPlaceholderStackView.self, "initWithConfiguration:actions:error:",
                                           [configuration, nil], &error), "\(configuration)")
            XCTAssertEqual(error?.domain, CYLPlaceholderConfigurationErrorDomain)
            XCTAssertEqual(error?.code, CYLPlaceholderConfigurationError.Code.stackView.rawValue)
            XCTAssertEqual(error?.localizedDescription, "The configuration must be a dictionary.")

            error = nil
            let display = controller.cyl_statusDisplay
            XCTAssertFalse(CYLApplyObjectiveCStatusConfiguration(controller, configuration, &error), "\(configuration)")
            XCTAssertEqual(error?.domain, CYLPlaceholderConfigurationErrorDomain)
            XCTAssertEqual(error?.code, CYLPlaceholderConfigurationError.Code.statusConfiguration.rawValue)
            XCTAssertEqual(error?.localizedDescription, "The configuration must be a dictionary.")
            XCTAssertEqual(controller.cyl_statusDisplay, display, "nothing changes")
        }
    }
}
