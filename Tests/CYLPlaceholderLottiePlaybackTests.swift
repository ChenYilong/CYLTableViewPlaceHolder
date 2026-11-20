//
//  CYLPlaceholderLottiePlaybackTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] Lottie plays through CYLTabBarController's animation engine and its Lottie animator (the LottieSwift subspec brings
//       `CYLAnimatedItem/LottieSwift`); the animation view is its `CYLCompatibleLOTAnimationView`, read
//       here through key-value coding only.
//  [CN] Lottie 通过 CYLTabBarController 的动画引擎及其 Lottie animator 播放（LottieSwift 子库带入
//       `CYLAnimatedItem/LottieSwift`）；动画视图是其 `CYLCompatibleLOTAnimationView`，这里只通过 KVC 读取。
//

import CYLAnimatedItem
import CYLTableViewPlaceHolder
import UIKit
import XCTest

private func CYLRenderedCenterColor(_ view: UIView) -> UIColor {
    let format = UIGraphicsImageRendererFormat.preferred()
    format.scale = 1
    let image = UIGraphicsImageRenderer(size: view.bounds.size, format: format).image { context in
        // Lottie's Core Animation renderer animates its layers, so draw what is on screen.
        CATransaction.flush()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.3))
        let layer = view.layer.presentation() ?? view.layer
        layer.render(in: context.cgContext)
    }
    var pixel: [UInt8] = [0, 0, 0, 0]
    let space = CGColorSpaceCreateDeviceRGB()
    pixel.withUnsafeMutableBytes { buffer in
        let context = CGContext(data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                                space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let cgImage = image.cgImage {
            context?.draw(cgImage, in: CGRect(x: -floor(image.size.width / 2), y: -floor(image.size.height / 2),
                                              width: image.size.width, height: image.size.height))
        }
    }
    return UIColor(red: CGFloat(pixel[0]) / 255, green: CGFloat(pixel[1]) / 255, blue: CGFloat(pixel[2]) / 255,
                   alpha: CGFloat(pixel[3]) / 255)
}

/**
 * Upper bound for asynchronous loads and fallbacks: loaded CI simulators can take seconds per main-queue turn.
 */
private let CYLTestTimeout: TimeInterval = 30

/// [EN] Spins the main run loop until `condition` holds or `timeout` passes, and returns whether it held. Used instead of
///      a fixed delay or an NSPredicate expectation: on a loaded CI runner the display link can tick late, and an
///      NSPredicate expectation was seen evaluating its predicate only once. [CN] 旋转主 run loop，直到 `condition`
///      成立或超时，并返回是否成立；用来代替固定延时或 NSPredicate 期望（后者在 CI 上只计算过一次谓词）。
private func CYLSpinUntil(timeout: TimeInterval, _ condition: () -> Bool) -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while !condition() {
        if Date() >= deadline { return false }
        RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.02))
    }
    return true
}

private func CYLWriteLottie(_ json: String, _ name: String) -> URL {
    let url = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString).appendingPathComponent("\(name)-\(UUID().uuidString).json"))
    try? json.write(to: url, atomically: true, encoding: .utf8)
    return url
}

private let CYLEmptyLottie = "{\"v\":\"5.7.4\",\"fr\":30,\"ip\":0,\"op\":30,\"w\":80,\"h\":80,\"nm\":\"Test\","
    + "\"ddd\":0,\"assets\":[],\"layers\":[]}"

/**
 * Reads a number the Lottie view exposes through key-value coding.
 */
private func CYLDouble(_ view: UIView?, _ key: String) -> Double {
    (view?.value(forKey: key) as? NSNumber)?.doubleValue ?? .nan
}

/**
 * Reads a flag the Lottie view exposes through key-value coding.
 */
private func CYLBool(_ view: UIView?, _ key: String) -> Bool {
    (view?.value(forKey: key) as? NSNumber)?.boolValue ?? false
}

final class CYLPlaceholderLottiePlaybackTests: XCTestCase {

    func testTheLottieAnimatorIsRegistered() {
        // [EN] A real Lottie document: since upstream PR #814 the Lottie animator takes only files it can play, so a missing
        //      "/a.json" has no animator.
        // [CN] 真实的 Lottie 文档：自上游 PR #814 起，Lottie animator 只接收它能播放的文件，缺失的 "/a.json" 没有 animator。
        let lottie = CYLPlaceholderView.path(forBundledAnimation: "CYLPlaceholderLoading.json")
        XCTAssertNotNil(lottie)
        XCTAssertEqual(CYLTabBarItemAnimatorRegistry.animator(for: URL(fileURLWithPath: lottie ?? ""))?.identifier, "Lottie")
        XCTAssertNil(CYLTabBarItemAnimatorRegistry.animator(for: URL(fileURLWithPath: "/a.json")))
    }

    func testLottieColorOverridesFollowAppearance() throws {
        let json = "{\"v\":\"5.7.4\",\"fr\":30,\"ip\":0,\"op\":30,\"w\":80,\"h\":80,\"nm\":\"Test\","
            + "\"ddd\":0,\"assets\":[],\"layers\":[{\"ddd\":0,\"ind\":1,\"ty\":4,\"nm\":\"Shape\","
            + "\"ks\":{\"o\":{\"a\":0,\"k\":100},\"r\":{\"a\":0,\"k\":0},\"p\":{\"a\":0,\"k\":[40,40,0]},"
            + "\"a\":{\"a\":0,\"k\":[0,0,0]},\"s\":{\"a\":0,\"k\":[100,100,100]}},"
            + "\"shapes\":[{\"ty\":\"el\",\"nm\":\"Ellipse\",\"p\":{\"a\":0,\"k\":[0,0]},\"s\":{\"a\":0,\"k\":[40,40]}},"
            + "{\"ty\":\"fl\",\"nm\":\"Fill\",\"c\":{\"a\":0,\"k\":[1,0,0,1]},\"o\":{\"a\":0,\"k\":100},\"r\":1}],"
            + "\"ip\":0,\"op\":30,\"st\":0,\"bm\":0}]}"
        let url = CYLWriteLottie(json, "CYLColors")
        let created = try? CYLPlaceholderView(itemAttributes: [
            CYLPlaceholderItemLottieURL: url, CYLPlaceholderItemLottieSize: [80, 80],
            CYLPlaceholderItemAnimationColors: ["Shape.Fill.Color": UIColor.green],
            CYLPlaceholderItemLottieDarkColors: ["Shape.Fill.Color": UIColor.blue]
        ], imageBundle: nil)
        XCTAssertNotNil(created)
        let placeholder = try XCTUnwrap(created)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.overrideUserInterfaceStyle = .light
        placeholder.frame = window.bounds
        window.addSubview(placeholder)
        window.isHidden = false
        placeholder.layoutIfNeeded()
        let lottie = placeholder.animationView
        XCTAssertNotNil(lottie, "the Lottie animator must be linked and decode the JSON")
        // The override is drawn: the ellipse at the center renders green, not its own red.
        placeholder.stopPlaceholderAnimation()
        lottie?.layoutIfNeeded()
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        let drawn = CYLRenderedCenterColor(try XCTUnwrap(lottie))
        XCTAssertTrue(drawn.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        XCTAssertGreaterThan(green, 0.8, "rendered \(drawn)")
        XCTAssertLessThan(red, 0.2, "rendered \(drawn)")
        window.overrideUserInterfaceStyle = .dark
        // [EN] The appearance change loads the file again with the dark colors. [CN] 外观变化后以深色颜色重新加载文件。
        expectation(for: NSPredicate { _, _ in
            placeholder.animationView != nil && placeholder.animationView !== lottie
        }, evaluatedWith: placeholder, handler: nil)
        waitForExpectations(timeout: CYLTestTimeout, handler: nil)
        let darkLottie = try XCTUnwrap(placeholder.animationView)
        placeholder.stopPlaceholderAnimation()
        placeholder.layoutIfNeeded()
        darkLottie.layoutIfNeeded()
        let darkDrawn = CYLRenderedCenterColor(darkLottie)
        XCTAssertTrue(darkDrawn.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        XCTAssertGreaterThan(blue, 0.8, "rendered \(darkDrawn)")
        window.isHidden = true
        placeholder.removeFromSuperview()
        try? FileManager.default.removeItem(at: url)
    }

    func testLocalLottieLoadsAndPlaysInPlaceholder() throws {
        let json = "{\"v\":\"5.7.4\",\"fr\":30,\"ip\":0,\"op\":30,\"w\":80,\"h\":80,"
            + "\"nm\":\"Test\",\"ddd\":0,\"assets\":[],\"layers\":[{\"ddd\":0,\"ind\":1,"
            + "\"ty\":1,\"nm\":\"Solid\",\"sw\":40,\"sh\":40,\"sc\":\"#ff0000\","
            + "\"ks\":{\"o\":{\"a\":0,\"k\":100},\"r\":{\"a\":0,\"k\":0},"
            + "\"p\":{\"a\":1,\"k\":[{\"t\":0,\"s\":[20,40,0],\"e\":[60,40,0],"
            + "\"i\":{\"x\":[0.667],\"y\":[1]},\"o\":{\"x\":[0.333],\"y\":[0]}},"
            + "{\"t\":30,\"s\":[60,40,0]}]},\"a\":{\"a\":0,\"k\":[20,20,0]},"
            + "\"s\":{\"a\":0,\"k\":[100,100,100]}},\"ip\":0,\"op\":30,\"st\":0,\"bm\":0}]}"
        let url = CYLWriteLottie(json, "CYLPlaceholder")
        var error: Error?
        var created: CYLPlaceholderView?
        do {
            created = try CYLPlaceholderView(itemAttributes: [
                CYLPlaceholderItemLottieURL: url, CYLPlaceholderItemLottieSize: [80, 80],
                CYLPlaceholderItemTitle: "Offline"
            ], imageBundle: nil)
        } catch let failure {
            error = failure
        }
        XCTAssertNotNil(created)
        XCTAssertNil(error)
        let placeholder = try XCTUnwrap(created)
        let lottie = placeholder.animationView
        XCTAssertNotNil(lottie, "the Lottie animator must be linked and decode the JSON")
        XCTAssertTrue(placeholder.isAnimationReady)
        XCTAssertTrue(placeholder.imageView.layer.isHidden, "the animation covers the static image")

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        placeholder.frame = window.bounds
        window.addSubview(placeholder)
        placeholder.layoutIfNeeded()
        XCTAssertEqual(lottie?.frame.width ?? 0, 80, accuracy: 0.1)
        if !UIAccessibility.isReduceMotionEnabled {
            XCTAssertTrue(CYLBool(lottie, "isAnimationPlaying"))
            // [EN] Poll for the first moved frame, not a fixed delay: a loaded CI runner can tick late (2026-11-20, SVGA).
            // [CN] 轮询第一帧的移动，而不是固定延时：负载高的 CI 会晚到（2026-11-20，SVGA 测试）。
            _ = CYLSpinUntil(timeout: 60) { CYLDouble(lottie, "realtimeAnimationProgress") > 0 }
            XCTAssertGreaterThan(CYLDouble(lottie, "realtimeAnimationProgress"), 0)
            placeholder.stopPlaceholderAnimation()
            XCTAssertFalse(CYLBool(lottie, "isAnimationPlaying"))
            placeholder.showPlaceholderAnimationLastFrame()
            XCTAssertEqual(CYLDouble(lottie, "realtimeAnimationProgress"), 1, accuracy: 0.01)
            XCTAssertTrue(placeholder.setPlaceholderAnimationProgress(0.5))
            XCTAssertEqual(CYLDouble(lottie, "realtimeAnimationProgress"), 0.5, accuracy: 0.01)
            placeholder.removeFromSuperview()
            window.addSubview(placeholder)
            XCTAssertEqual(CYLDouble(lottie, "realtimeAnimationProgress"), 0.5, accuracy: 0.01)
            XCTAssertFalse(placeholder.setPlaceholderAnimationProgress(1.5))
            XCTAssertTrue(placeholder.setPlaceholderAnimationSpeed(2))
            XCTAssertEqual(CYLDouble(lottie, "animationSpeed"), 2, accuracy: 0.01)
            XCTAssertFalse(placeholder.setPlaceholderAnimationSpeed(0))
            placeholder.playPlaceholderAnimation()
            XCTAssertTrue(CYLBool(lottie, "isAnimationPlaying"))
            // A one-shot animation that finished replays from progress 0 (the examples' "Play all" with the loop off).
            // Polled at speed 1, not sampled once after a fixed wait: a slow runner can deliver a single late sample after
            // the replay already ended on its last frame (seen: 0.99999 at speed 2). Without a replay the progress stays at 1.
            placeholder.animationRepeatCount = 1
            XCTAssertTrue(placeholder.setPlaceholderAnimationSpeed(1))
            placeholder.showPlaceholderAnimationLastFrame()
            XCTAssertEqual(CYLDouble(lottie, "realtimeAnimationProgress"), 1, accuracy: 0.01)
            placeholder.playPlaceholderAnimation()
            XCTAssertTrue(CYLBool(lottie, "isAnimationPlaying"))
            var lowestProgress = CYLDouble(lottie, "realtimeAnimationProgress")
            let deadline = Date(timeIntervalSinceNow: 3)
            while lowestProgress >= 0.9 && deadline.timeIntervalSinceNow > 0 {
                RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
                lowestProgress = min(lowestProgress, CYLDouble(lottie, "realtimeAnimationProgress"))
            }
            XCTAssertLessThan(lowestProgress, 0.9, "the 1 s animation restarted at 0, it did not stay on its last frame")
        }
        placeholder.removeFromSuperview()
        XCTAssertFalse(CYLBool(lottie, "isAnimationPlaying"))
        try? FileManager.default.removeItem(at: url)
    }

    func testOptionsAndStateSurviveDarkModeReplacement() throws {
        let prefix = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
        let light = URL(fileURLWithPath: prefix + "-light.json")
        let dark = URL(fileURLWithPath: prefix + "-dark.json")
        XCTAssertNoThrow(try CYLEmptyLottie.write(to: light, atomically: true, encoding: .utf8))
        XCTAssertNoThrow(try CYLEmptyLottie.write(to: dark, atomically: true, encoding: .utf8))
        let placeholder = try XCTUnwrap(try? CYLPlaceholderView(itemAttributes: [
            CYLPlaceholderItemLottieURL: light, CYLPlaceholderItemLottieDarkURL: dark,
            CYLPlaceholderItemAnimationOptions: ["animationSpeed": 3, "contentMode": "scaleAspectFill"]
        ], imageBundle: nil))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.overrideUserInterfaceStyle = .light
        window.addSubview(placeholder)
        let lottie = placeholder.animationView
        XCTAssertNotNil(lottie)
        XCTAssertEqual(CYLDouble(lottie, "animationSpeed"), 3, accuracy: 0.01)
        XCTAssertEqual(lottie?.contentMode, .scaleAspectFill)
        XCTAssertTrue(placeholder.setPlaceholderAnimationSpeed(2))
        XCTAssertTrue(placeholder.setPlaceholderAnimationProgress(0.5))
        window.overrideUserInterfaceStyle = .dark
        expectation(for: NSPredicate { _, _ in
            placeholder.animationView != nil && placeholder.animationView !== lottie
        }, evaluatedWith: placeholder, handler: nil)
        waitForExpectations(timeout: CYLTestTimeout, handler: nil)
        let replacement = placeholder.animationView
        XCTAssertEqual(CYLDouble(replacement, "animationSpeed"), 2, accuracy: 0.01)
        XCTAssertEqual(CYLDouble(replacement, "realtimeAnimationProgress"), 0.5, accuracy: 0.01)
        XCTAssertEqual(replacement?.contentMode, .scaleAspectFill)
        placeholder.removeFromSuperview()
        try? FileManager.default.removeItem(at: light)
        try? FileManager.default.removeItem(at: dark)
    }
}
