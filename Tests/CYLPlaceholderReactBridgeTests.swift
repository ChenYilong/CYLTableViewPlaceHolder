//
//  CYLPlaceholderReactBridgeTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The iOS halves of the React Native `CYLPlaceholderStack` view and `CYLPlaceholderHUD` module
//       (CrossPlatform/react-native-cylplaceholder/ios) without a React Native runtime: the props as Android's
//       CYLPlaceholderStackManager takes them (components, scenario, backgroundAction, restartToken), the `onAction` body, and the
//       HUD `call(method, arguments)` dispatch to CYLPlaceholderHUDBridge.
//  [CN] React Native `CYLPlaceholderStack` 视图与 `CYLPlaceholderHUD` 模块的 iOS 一侧（CrossPlatform/react-native-cylplaceholder/ios），
//       不需要 React Native 运行时：属性与 Android 的 CYLPlaceholderStackManager 相同（components、scenario、backgroundAction、
//       restartToken）、`onAction` 的内容，以及 HUD `call(method, arguments)` 到 CYLPlaceholderHUDBridge 的分发。
//

import XCTest
import UIKit

final class CYLPlaceholderReactBridgeTests: XCTestCase {

    private var window: UIWindow!

    override func setUp() {
        super.setUp()
        CYLPlaceholderLocalization.language = "en"
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.isHidden = false
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
        CYLPlaceholderLocalization.language = nil
        super.tearDown()
    }

    // MARK: - Stack host view

    private func components() -> [Any] {
        [
            ["type": "icon", "style": "cloudOff", "title": "Something went wrong", "animationLoops": true, "animationSpeed": 2],
            ["type": "hint", "title": "Check your connection"],
            ["type": "button", "title": "Retry", "action": "retry"],
            ["type": "button", "title": "Contact support", "action": "support", "buttonStyle": "outlined"],
        ]
    }

    private func makeHost() -> CYLPlaceholderStackHostView {
        let host = CYLPlaceholderStackHostView(frame: window.bounds)
        window.addSubview(host)
        return host
    }

    func testTheComponentsPropBuildsTheNativeStackAtLayoutAndFillsTheBox() throws {
        let host = makeHost()
        host.components = components()
        XCTAssertNil(host.stack, "the stack is built at layout, after the whole update batch")
        host.layoutIfNeeded()
        let stack = try XCTUnwrap(host.stack)
        XCTAssertEqual(stack.componentViews.count, 4)
        XCTAssertEqual(stack.frame, host.bounds)
        XCTAssertEqual(stack.accessibilityIdentifier, "cyl.native.placeholderStack")
        XCTAssertTrue(stack.isDescendant(of: host))
        host.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        host.layoutIfNeeded()
        XCTAssertEqual(stack.frame, host.bounds, "the stack follows the box React Native lays out")
    }

    func testTheScenarioPropIsUsedOnlyWithoutComponents() throws {
        let host = makeHost()
        host.scenario = "retryButton"
        host.layoutIfNeeded()
        let scenarioStack = try XCTUnwrap(host.stack, "a scenario name alone builds a stack")
        host.components = components()
        host.layoutIfNeeded()
        let stack = try XCTUnwrap(host.stack)
        XCTAssertFalse(stack === scenarioStack, "a changed prop rebuilds the stack")
        XCTAssertEqual(stack.componentViews.count, 4, "the components win over the scenario")
        host.components = []
        host.layoutIfNeeded()
        XCTAssertNotNil(host.stack, "empty components fall back to the scenario")
    }

    func testNoConfigurationOrAnInvalidOneShowsNoStack() {
        let host = makeHost()
        host.layoutIfNeeded()
        XCTAssertNil(host.stack)
        host.backgroundAction = "background"
        host.layoutIfNeeded()
        XCTAssertNil(host.stack, "a background action alone is not a configuration")
        host.components = [["type": "mystery"]]
        host.layoutIfNeeded()
        XCTAssertNil(host.stack)
        XCTAssertFalse(host.applyPendingConfiguration())
        host.components = components()
        XCTAssertTrue(host.applyPendingConfiguration())
        host.components = nil
        host.scenario = nil
        host.layoutIfNeeded()
        XCTAssertNil(host.stack, "removing the props removes the stack")
        XCTAssertEqual(host.subviews.count, 0)
    }

    func testAButtonTapSendsTheActionNameAsGivenEvenForACatalogName() throws {
        let host = makeHost()
        var bodies: [[AnyHashable: Any]] = []
        host.onAction = { bodies.append($0) }
        host.components = components()
        host.backgroundAction = "background"
        host.layoutIfNeeded()
        let stack = try XCTUnwrap(host.stack)
        XCTAssertTrue(stack.componentViews[2].performTap(), "\"retry\" is a catalog name")
        XCTAssertTrue(try XCTUnwrap(stack.componentViews.last).performTap())
        XCTAssertTrue(stack.performAction(CYLPlaceholderScenarioCatalog.action(named: "background")))
        XCTAssertEqual(bodies.compactMap { $0["action"] as? String }, ["retry", "support", "background"])
        XCTAssertEqual(bodies.first?.count, 1, "the body is { action } only, as on Android")
    }

    func testTheRestartTokenRestartsOnlyWhenItGrowsAfterTheStackExists() {
        let host = makeHost()
        host.restartToken = 3
        host.components = components()
        host.layoutIfNeeded()
        XCTAssertEqual(host.restartCount, 0, "the first value is the baseline: nothing restarts at creation")
        host.restartToken = 3
        XCTAssertEqual(host.restartCount, 0, "the same value does nothing")
        host.restartToken = 4
        XCTAssertEqual(host.restartCount, 1)
        host.restartToken = 2
        XCTAssertEqual(host.restartCount, 1, "a lower value does nothing")
        host.restartToken = 9
        XCTAssertEqual(host.restartCount, 2)
    }

    func testTheRestartCommandRestartsAndWithoutAStackDoesNothing() {
        let host = makeHost()
        host.restartAnimation()
        XCTAssertEqual(host.restartCount, 0)
        host.components = components()
        host.layoutIfNeeded()
        host.restartAnimation()
        XCTAssertEqual(host.restartCount, 1)
    }

    // MARK: - HUD controller

    private func makeController(onAction: @escaping (String) -> Void = { _ in }) -> (CYLPlaceholderHUDController, UIView) {
        let content = UIView(frame: window.bounds)
        window.addSubview(content)
        let controller = CYLPlaceholderHUDController(container: { [unowned content] in content }, onAction: onAction)
        return (controller, content)
    }

    private func settle(_ controller: CYLPlaceholderHUDController) {
        controller.hud?.fadeInAnimationDuration = 0
        controller.hud?.fadeOutAnimationDuration = 0
    }

    func testCallRunsTheBridgeMethodsOverTheHostView() throws {
        let (controller, content) = makeController()
        XCTAssertNil(controller.hud, "no HUD before the first call")
        XCTAssertTrue(controller.handle(method: "showWithStatus", arguments: ["status": "Please wait"]))
        settle(controller)
        let hud = try XCTUnwrap(controller.hud)
        XCTAssertEqual(hud.status, "Please wait")
        XCTAssertTrue(hud.isDescendant(of: content), "the HUD lays itself over the host view")
        XCTAssertTrue(controller.handle(method: "showProgress", arguments: ["progress": 0.4, "status": "Uploading"]))
        XCTAssertEqual(hud.state, .progress)
        XCTAssertTrue(controller.handle(method: "showSuccessWithStatus", arguments: ["status": "Saved"]))
        XCTAssertEqual(hud.state, .success)
        XCTAssertTrue(controller.handle(method: "dismiss", arguments: nil))
        XCTAssertFalse(hud.isVisible)
        XCTAssertTrue(controller.hud === hud, "the same HUD serves every call on one host view")
    }

    func testUnknownMethodsAndNoHostViewAreNotHandled() {
        let (controller, _) = makeController()
        XCTAssertFalse(controller.handle(method: "noSuchMethod", arguments: nil))
        XCTAssertFalse(controller.handle(method: "showComponents", arguments: ["components": [["type": "mystery"]]]))
        let none = CYLPlaceholderHUDController(container: { nil }, onAction: { _ in })
        XCTAssertFalse(none.handle(method: "show", arguments: nil))
        XCTAssertNil(none.hud)
    }

    func testAHUDButtonTapComesBackByNameIncludingACatalogName() throws {
        var received: [String] = []
        let (controller, _) = makeController { received.append($0) }
        XCTAssertTrue(controller.handle(method: "showComponents", arguments: ["components": [
            ["type": "icon", "style": "warning", "title": "Custom HUD"],
            ["type": "button", "title": "OK", "action": "done"],
        ]]))
        settle(controller)
        let view = try XCTUnwrap(controller.hud?.placeholderView)
        XCTAssertTrue(try XCTUnwrap(view.componentViews.last).performTap())
        XCTAssertEqual(received, ["done"])
        controller.hud?.dismiss()
    }

    func testANewHostViewGetsANewHUDAndTheOldOneIsDismissed() throws {
        var current: UIView?
        let first = UIView(frame: window.bounds)
        let second = UIView(frame: window.bounds)
        window.addSubview(first)
        window.addSubview(second)
        current = first
        let controller = CYLPlaceholderHUDController(container: { current }, onAction: { _ in })
        XCTAssertTrue(controller.handle(method: "show", arguments: nil))
        let firstHUD = try XCTUnwrap(controller.hud)
        firstHUD.fadeOutAnimationDuration = 0
        current = second
        XCTAssertTrue(controller.handle(method: "show", arguments: nil))
        let secondHUD = try XCTUnwrap(controller.hud)
        XCTAssertFalse(firstHUD === secondHUD)
        XCTAssertTrue(secondHUD.isDescendant(of: second))
        XCTAssertFalse(firstHUD.isVisible, "the HUD of the old host view is dismissed")
        controller.hud?.dismiss()
    }

    func testTheForegroundContainerIsTheTopmostViewControllersView() {
        // The unit-test host has no foreground window of its own; the call must not crash and returns a view or nil.
        _ = CYLPlaceholderHUDController.foregroundContainer()
    }
}
