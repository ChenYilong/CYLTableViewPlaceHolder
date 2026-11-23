//
//  CYLPlaceholderBridgeTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] CYLPlaceholderBridge and CYLPlaceholderHUDBridge, the dictionary entry points the Flutter and React Native iOS halves
//       call (hand-off #10 of docs/Refresh-Library-Parity.md): the item and configuration keys, the live updates and every HUD
//       method name, with the same names and keys as the Android bridge.
//  [CN] CYLPlaceholderBridge 与 CYLPlaceholderHUDBridge：Flutter 与 React Native 的 iOS 一侧调用的字典入口（
//       docs/Refresh-Library-Parity.md 交接 #10）：条目与配置的键、实时更新以及每个 HUD 方法名，名称与键均与 Android 桥接相同。
//

import XCTest
import UIKit

final class CYLPlaceholderBridgeTests: XCTestCase {

    private var window: UIWindow!
    private var container: UIView!

    override func setUp() {
        super.setUp()
        CYLPlaceholderLocalization.language = "en"
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        container = UIView(frame: window.bounds)
        window.addSubview(container)
        window.isHidden = false
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
        CYLPlaceholderLocalization.language = nil
        super.tearDown()
    }

    // MARK: - Placeholder view

    func testAnItemDictionaryMakesAPlaceholderViewWithItsTitleAndStyle() throws {
        let view = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [
            CYLPlaceholderItemTitle: "Offline", CYLPlaceholderItemStyle: CYLPlaceholderStyle.wifiOff.rawValue
        ]))
        XCTAssertEqual(view.textLabel.text, "Offline")
        XCTAssertNotNil(view.imageView.image, "the style gives the built-in icon")
    }

    func testAStyleGivenByNameIsTheSameAsTheNumber() throws {
        let byName = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [CYLPlaceholderItemStyle: "wifiOff"]))
        let byNumber = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [CYLPlaceholderItemStyle: CYLPlaceholderStyle.wifiOff.rawValue]))
        XCTAssertEqual(byName.itemAttributes[CYLPlaceholderItemStyle] as? Int, byNumber.itemAttributes[CYLPlaceholderItemStyle] as? Int)
        XCTAssertNotNil(byName.imageView.image)
        XCTAssertNil(CYLPlaceholderBridge.placeholderView(params: [CYLPlaceholderItemStyle: "noSuchStyle"]), "an unknown name is invalid")
    }

    func testAMessageThatIsTextBecomesTheTitleOrASecondLine() throws {
        let only = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [CYLPlaceholderItemMessage: "Tap to retry"]))
        XCTAssertEqual(only.textLabel.text, "Tap to retry")
        let both = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [
            CYLPlaceholderItemTitle: "Load failed", CYLPlaceholderItemMessage: "Tap to retry"
        ]))
        XCTAssertEqual(both.textLabel.text, "Load failed\nTap to retry")
    }

    func testAnAssetAnimationNameResolvesToTheBundledFile() throws {
        let view = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [
            CYLPlaceholderItemTitle: "Failed", CYLPlaceholderItemAnimationFilePath: "asset:CYLPlaceholderLoadFailed.json"
        ]))
        let path = try XCTUnwrap(view.itemAttributes[CYLPlaceholderItemAnimationFilePath] as? String)
        XCTAssertTrue(path.hasSuffix("CYLPlaceholderLoadFailed.json"), path)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
        // A bare file name in the URL key is the same file, not a URL.
        let byURLKey = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [
            CYLPlaceholderItemAnimationURL: "CYLPlaceholderLoadFailed.json"
        ]))
        XCTAssertNil(byURLKey.itemAttributes[CYLPlaceholderItemAnimationURL])
        XCTAssertTrue((byURLKey.itemAttributes[CYLPlaceholderItemAnimationFilePath] as? String)?.hasSuffix("CYLPlaceholderLoadFailed.json") ?? false)
    }

    func testAnInvalidItemDictionaryMakesNoView() {
        XCTAssertNil(CYLPlaceholderBridge.placeholderView(params: [CYLPlaceholderItemTitle: 42]))
        XCTAssertNil(CYLPlaceholderBridge.placeholderView(params: [CYLPlaceholderItemStyle: 9999]))
    }

    func testTheLoopAndSpeedKeysApplyAtCreationAndAreNotItemKeys() throws {
        let view = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [
            CYLPlaceholderItemTitle: "Hi", "animationLoops": true, "animationSpeed": 2.5
        ]))
        XCTAssertTrue(view.animationLoops)
        XCTAssertEqual(view.animationSpeed, 2.5, accuracy: 0.001)
        XCTAssertNil(view.itemAttributes["animationLoops"], "the keys are applied, not stored as item attributes")
        XCTAssertNil(view.itemAttributes["animationSpeed"])
        let defaults = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [CYLPlaceholderItemTitle: "Hi"]))
        XCTAssertFalse(defaults.animationLoops)
        XCTAssertEqual(defaults.animationSpeed, 1, accuracy: 0.001)
        // A speed that is not above 0 is ignored.
        let bad = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [CYLPlaceholderItemTitle: "Hi", "animationSpeed": 0]))
        XCTAssertEqual(bad.animationSpeed, 1, accuracy: 0.001)
    }

    func testLiveUpdatesChangeLoopsAndSpeedAndRestart() throws {
        let view = try XCTUnwrap(CYLPlaceholderBridge.placeholderView(params: [CYLPlaceholderItemTitle: "Hi"]))
        XCTAssertTrue(CYLPlaceholderBridge.updatePlaceholderView(view, name: "animationLoops", value: true))
        XCTAssertTrue(view.animationLoops)
        XCTAssertTrue(CYLPlaceholderBridge.updatePlaceholderView(view, name: "animationLoops", value: false))
        XCTAssertFalse(view.animationLoops)
        XCTAssertTrue(CYLPlaceholderBridge.updatePlaceholderView(view, name: "animationSpeed", value: 3))
        XCTAssertEqual(view.animationSpeed, 3, accuracy: 0.001)
        XCTAssertTrue(CYLPlaceholderBridge.updatePlaceholderView(view, name: "restartAnimation", value: 7))
        XCTAssertFalse(CYLPlaceholderBridge.updatePlaceholderView(view, name: "animationLoops", value: "yes"), "a wrong type is not understood")
        XCTAssertFalse(CYLPlaceholderBridge.updatePlaceholderView(view, name: "animationSpeed", value: -1))
        XCTAssertFalse(CYLPlaceholderBridge.updatePlaceholderView(view, name: "animationSpeed", value: nil))
        XCTAssertFalse(CYLPlaceholderBridge.updatePlaceholderView(view, name: "noSuchName", value: 1))
        XCTAssertEqual(view.animationSpeed, 3, accuracy: 0.001, "a refused update changes nothing")
    }

    // MARK: - Placeholder stack

    private func components() -> [[String: Any]] {
        [
            ["type": "icon", "style": "cloudOff", "title": "Offline", "animation": "CYLPlaceholderLoadFailed.json", "animationLoops": true, "animationSpeed": 2],
            ["type": "hint", "title": "Try again"],
            ["type": "button", "title": "Retry", "action": "component-2"],
        ]
    }

    func testAConfigurationMakesAStackWhoseComponentsCarryLoopsAndSpeed() throws {
        let stack = try XCTUnwrap(CYLPlaceholderBridge.stackView(configuration: ["components": components()]) { _ in })
        XCTAssertEqual(stack.componentViews.count, 3)
        XCTAssertEqual(stack.placeholderView.textLabel.text, "Offline")
        XCTAssertTrue(stack.placeholderView.animationLoops, "the component key animationLoops is applied")
        XCTAssertEqual(stack.placeholderView.animationSpeed, 2, accuracy: 0.001, "the component key animationSpeed is applied")
        let component = try CYLPlaceholderComponent(dictionary: components()[0])
        XCTAssertTrue(component.animationLoops)
        XCTAssertEqual(component.animationSpeed, 2, accuracy: 0.001)
    }

    func testAnInvalidConfigurationMakesNoStack() {
        XCTAssertNil(CYLPlaceholderBridge.stackView(configuration: ["components": [["type": "mystery"]]]) { _ in })
        XCTAssertNil(CYLPlaceholderBridge.stackView(configuration: ["components": [["type": "icon", "animationSpeed": 0]]]) { _ in })
        XCTAssertNil(CYLPlaceholderBridge.stackView(configuration: ["components": [["type": "icon", "animationLoops": "yes"]]]) { _ in })
    }

    func testAButtonActionComesBackByName() throws {
        var received: [String] = []
        let stack = try XCTUnwrap(CYLPlaceholderBridge.stackView(configuration: ["components": components()]) { received.append($0) })
        let button = try XCTUnwrap(stack.componentViews.last)
        XCTAssertTrue(button.performTap())
        XCTAssertEqual(received, ["component-2"])
    }

    func testTheBackgroundActionComesBackByName() throws {
        var received: [String] = []
        var configuration: [String: Any] = ["components": components()]
        configuration["backgroundAction"] = "background"
        let handlers = CYLPlaceholderBridge.actionHandlers(configuration) { received.append($0) }
        XCTAssertEqual(Set(handlers.keys.map(\.rawValue)), ["component-2", "background"])
        let stack = try XCTUnwrap(CYLPlaceholderBridge.stackView(configuration: configuration) { received.append($0) })
        XCTAssertTrue(stack.performAction(CYLPlaceholderAction(rawValue: "background")))
        XCTAssertEqual(received, ["background"])
    }

    func testTheStackUpdateRestartsOnlyByThatName() throws {
        let stack = try XCTUnwrap(CYLPlaceholderBridge.stackView(configuration: ["components": components()]) { _ in })
        XCTAssertTrue(CYLPlaceholderBridge.updateStackView(stack, name: "restartAnimation", value: 1))
        XCTAssertFalse(CYLPlaceholderBridge.updateStackView(stack, name: "animationSpeed", value: 2))
    }

    // MARK: - HUD

    private func makeBridge(_ actions: @escaping (String) -> Void = { _ in }) -> CYLPlaceholderHUDBridge {
        let bridge = CYLPlaceholderHUDBridge(container: container, onAction: actions)
        bridge.hud.fadeInAnimationDuration = 0
        bridge.hud.fadeOutAnimationDuration = 0
        return bridge
    }

    func testTheHUDShowsAndDismissesByMethodName() {
        let bridge = makeBridge()
        XCTAssertTrue(bridge.handle(method: "show", arguments: nil))
        XCTAssertEqual(bridge.hud.state, .loading)
        XCTAssertTrue(bridge.handle(method: "showWithStatus", arguments: ["status": "Please wait"]))
        XCTAssertEqual(bridge.hud.status, "Please wait")
        XCTAssertTrue(bridge.handle(method: "setStatus", arguments: ["status": "Almost"]))
        XCTAssertEqual(bridge.hud.status, "Almost")
        XCTAssertTrue(bridge.handle(method: "popActivity", arguments: nil))
        XCTAssertTrue(bridge.handle(method: "dismiss", arguments: nil))
        XCTAssertFalse(bridge.hud.isVisible)
    }

    func testTheProgressIsClampedToZeroAndOne() {
        let bridge = makeBridge()
        XCTAssertTrue(bridge.handle(method: "showProgress", arguments: ["progress": 0.4, "status": "Uploading"]))
        XCTAssertEqual(bridge.hud.state, .progress)
        XCTAssertEqual(bridge.hud.progress, 0.4, accuracy: 0.001)
        XCTAssertEqual(bridge.hud.status, "Uploading")
        XCTAssertTrue(bridge.handle(method: "showProgress", arguments: ["progress": 7]))
        XCTAssertEqual(bridge.hud.progress, 1, accuracy: 0.001)
        XCTAssertTrue(bridge.handle(method: "showProgress", arguments: ["progress": -3]))
        XCTAssertEqual(bridge.hud.progress, 0, accuracy: 0.001)
        bridge.hud.dismiss()
    }

    func testTheTimedMessagesSetTheirState() {
        let bridge = makeBridge()
        XCTAssertTrue(bridge.handle(method: "showInfoWithStatus", arguments: ["status": "Info"]))
        XCTAssertEqual(bridge.hud.state, .info)
        XCTAssertTrue(bridge.handle(method: "showSuccessWithStatus", arguments: ["status": "Done"]))
        XCTAssertEqual(bridge.hud.state, .success)
        XCTAssertEqual(bridge.hud.status, "Done")
        XCTAssertTrue(bridge.handle(method: "showErrorWithStatus", arguments: ["status": "Oops"]))
        XCTAssertEqual(bridge.hud.state, .error)
        bridge.hud.dismiss()
    }

    func testDismissWithDelayKeepsTheHUDUntilTheDelayPasses() {
        let bridge = makeBridge()
        bridge.handle(method: "show", arguments: nil)
        XCTAssertTrue(bridge.handle(method: "dismissWithDelay", arguments: ["delay": 0.2]))
        XCTAssertTrue(bridge.hud.isVisible, "still showing right after the call")
        let gone = expectation(for: NSPredicate { _, _ in !bridge.hud.isVisible }, evaluatedWith: bridge.hud, handler: nil)
        wait(for: [gone], timeout: 5)
    }

    func testShowComponentsBuildsTheBoxAndAButtonTapComesBackByName() {
        var received: [String] = []
        let bridge = makeBridge { received.append($0) }
        XCTAssertTrue(bridge.handle(method: "showComponents", arguments: ["components": components()]))
        XCTAssertEqual(bridge.hud.state, .custom)
        XCTAssertEqual(bridge.hud.placeholderView?.componentViews.count, 3)
        XCTAssertTrue(bridge.hud.placeholderView?.performAction(CYLPlaceholderAction(rawValue: "component-2")) ?? false)
        XCTAssertEqual(received, ["component-2"])
        bridge.hud.dismiss()
    }

    func testAnUnknownMethodOrAnInvalidComponentListIsNotHandled() {
        let bridge = makeBridge()
        XCTAssertFalse(bridge.handle(method: "noSuchMethod", arguments: nil))
        XCTAssertFalse(bridge.handle(method: "showComponents", arguments: nil), "no components key")
        XCTAssertFalse(bridge.handle(method: "showComponents", arguments: ["components": [["type": "mystery"]]]))
        XCTAssertFalse(bridge.hud.isVisible, "an invalid list shows nothing")
    }
}
