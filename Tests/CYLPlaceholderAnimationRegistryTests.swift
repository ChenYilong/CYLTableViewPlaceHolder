//
//  CYLPlaceholderAnimationRegistryTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] CYLPlaceholderView plays every animation through CYLTabBarController's animation engine: the animators that
//       the GIF, Lottie, PAG and Rive subspecs bring register with `CYLTabBarItemAnimatorRegistry`, and an app's own
//       animator registers the same way.
//  [CN] CYLPlaceholderView 通过 CYLTabBarController 的动画引擎播放所有动画：GIF、Lottie、PAG、Rive 子库带入的 animator 注册到
//       `CYLTabBarItemAnimatorRegistry`，应用自己的 animator 也以同样方式注册。
//

import CYLAnimatedItem
import CYLTableViewPlaceHolder
import ImageIO
import UIKit
import XCTest

/**
 * [EN] The view of the custom animator below. [CN] 下面自定义 animator 的视图。
 */
private final class CYLRegistryTestView: UIView {
    var options: [String: String] = [:]
}

/**
 * [EN] Counts what the placeholder asks of the player. [CN] 记录占位图对播放器的调用。
 */
private final class CYLRegistryTestPlayer: CYLTabBarItemAnimationBasePlayer, CYLTabBarItemAnimationPlayer {
    var plays = 0
    var stops = 0
    func play() { plays += 1 }
    func stop() { stops += 1 }
    func showLastFrame() { stops += 1 }
}

/**
 * [EN] An app's own animator for ".cyltest" files; it reads the options from the URL's fragment, as the engine's
 *      animators do. [CN] 应用自己的 ".cyltest" animator；与引擎的 animator 一样从 URL 的 fragment 中读取选项。
 */
private final class CYLRegistryTestAnimator: NSObject, CYLTabBarItemAnimator {
    var player: CYLRegistryTestPlayer?
    var identifier: String { "CYLTest" }
    var fileExtensions: [String] { ["cyltest"] }
    func canAnimateFile(at url: URL) -> Bool { url.pathExtension.lowercased() == "cyltest" }
    func animationView(with url: URL, size: CGSize, contentMode: UIView.ContentMode) -> UIView? {
        let view = CYLRegistryTestView(frame: CGRect(origin: .zero, size: size))
        var options = [String: String]()
        let fragment = URLComponents(url: url, resolvingAgainstBaseURL: true)?.percentEncodedFragment ?? ""
        for item in fragment.components(separatedBy: "&") {
            let pair = item.components(separatedBy: "=")
            if pair.count == 2, let key = pair[0].removingPercentEncoding { options[key] = pair[1].removingPercentEncoding }
        }
        view.options = options
        return view
    }
    func player(forAnimationView view: UIView) -> CYLTabBarItemAnimationPlayer? {
        guard view is CYLRegistryTestView else { return nil }
        let player = CYLRegistryTestPlayer(animationView: view)
        self.player = player
        return player
    }
}

final class CYLPlaceholderAnimationRegistryTests: XCTestCase {

    private func gifURL() -> URL {
        let data = NSMutableData()
        let destination = CGImageDestinationCreateWithData(data as CFMutableData, "com.compuserve.gif" as CFString, 2, nil)!
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20))
        for color in [UIColor.red, UIColor.blue] {
            let image = renderer.image { _ in
                color.setFill()
                UIRectFill(CGRect(x: 0, y: 0, width: 20, height: 20))
            }
            let properties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.2]]
            CGImageDestinationAddImage(destination, image.cgImage!, properties as CFDictionary)
        }
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        let url = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString)
            .appendingPathComponent("CYLRegistry-\(UUID().uuidString).gif"))
        XCTAssertTrue(data.write(to: url, atomically: true))
        return url
    }

    func testTheSubspecsAnimatorsRegisterThemselves() {
        let identifiers = CYLTabBarItemAnimatorRegistry.animators().map { $0.identifier }
        for identifier in ["GIF", "PAG", "Rive", "Lottie"] {
            XCTAssertTrue(identifiers.contains(identifier), "\(identifier) is not registered")
        }
        // Lottie has the fallback priority, so it is looked up last.
        XCTAssertEqual(identifiers.last, "Lottie")
        let extensions = CYLTabBarItemAnimatorRegistry.fileExtensions()
        for fileExtension in ["gif", "pag", "riv", "json"] {
            XCTAssertTrue(extensions.contains(fileExtension), fileExtension)
        }
        XCTAssertEqual(CYLTabBarItemAnimatorRegistry.animator(for: URL(fileURLWithPath: "/a.PAG"))?.identifier, "PAG")
        // [EN] A real Lottie document: the Lottie animator only takes files it can play (upstream PR #814).
        // [CN] 真实的 Lottie 文档：Lottie animator 只接收它能播放的文件（上游 PR #814）。
        let lottie = CYLPlaceholderView.path(forBundledAnimation: "CYLPlaceholderLoading.json")
        XCTAssertNotNil(lottie)
        XCTAssertEqual(CYLTabBarItemAnimatorRegistry.animator(for: URL(fileURLWithPath: lottie ?? ""))?.identifier, "Lottie")
        // [EN] Lottie is the fallback animator, but only for a Lottie document (CYLTabBarItemAnimationURLMayBeLottie, upstream
        //      PR #814): a missing or non-Lottie local file has no animator.
        // [CN] Lottie 是兜底 animator，但只接收 Lottie 文档（CYLTabBarItemAnimationURLMayBeLottie，上游 PR #814）：缺失或不是 Lottie 的本地
        //      文件没有 animator。
        XCTAssertNil(CYLTabBarItemAnimatorRegistry.animator(for: URL(fileURLWithPath: "/a.txt")))
    }

    func testTheRegistryReportsEachEngineOfThisBuild() {
        // [EN] Several engines at once (upstream "multi-engine management"): each subspec registered itself (SVGA too since
        //      the animation tests add the SVGA subspec, 2026-11-19), nothing is missing and nothing conflicts.
        // [CN] 同时引入多个引擎（上游“多动效引擎管理”）：每个子库已自行注册（2026-11-19 起动画测试也引入 SVGA 子库），没有缺失，也没有冲突。
        for identifier in ["GIF", "PAG", "Rive", "Lottie", "SVGA"] {
            XCTAssertTrue(CYLTabBarItemAnimatorRegistry.isAnimatorRegistered(withIdentifier: identifier), identifier)
            XCTAssertTrue(CYLTabBarItemAnimatorRegistry.registeredIdentifiers().contains(identifier), identifier)
        }
        XCTAssertEqual(CYLTabBarItemAnimatorRegistry.missingKnownIdentifiers().count, 0,
                       "\(CYLTabBarItemAnimatorRegistry.missingKnownIdentifiers())")
        XCTAssertEqual(CYLTabBarItemAnimatorRegistry.conflictDescriptions().count, 0,
                       "\(CYLTabBarItemAnimatorRegistry.conflictDescriptions())")
        let report = CYLTabBarItemAnimatorRegistry.registrationReport()
        for identifier in ["GIF", "PAG", "Rive", "Lottie", "SVGA"] {
            XCTAssertTrue(report.contains(identifier), "\(identifier) not in \(report)")
        }
    }

    func testAnUnknownOrMissingFileKeepsTheStaticImage() {
        let image = CYLPlaceholderView.image(for: .noInternet)
        // [EN] A text file, a broken JSON file and missing files: none plays, the static image stays (display priority; the Lottie
        //      fallback takes only Lottie documents since upstream PR #814).
        // [CN] 文本文件、损坏的 JSON 文件与缺失的文件：都无法播放，保留静态图片（显示优先级；自上游 PR #814 起 Lottie 兜底只接收 Lottie 文档）。
        let unknown = (NSTemporaryDirectory() as NSString).appendingPathComponent("CYLRegistry-unknown.txt")
        try? "text".write(toFile: unknown, atomically: true, encoding: .utf8)
        let broken = (NSTemporaryDirectory() as NSString).appendingPathComponent("CYLRegistry-broken.json")
        try? "{\"not\": \"lottie\"".write(toFile: broken, atomically: true, encoding: .utf8)
        for path in [unknown, broken, "/missing/animation.json", "/missing/animation.riv", "/missing/animation.pag"] {
            var attributes: [String: Any] = [CYLPlaceholderItemAnimationFilePath: path]
            attributes[CYLPlaceholderItemImage] = image
            let placeholder: CYLPlaceholderView?
            do {
                placeholder = try CYLPlaceholderView(itemAttributes: attributes, imageBundle: nil)
            } catch {
                placeholder = nil
                XCTFail("\(error)")
            }
            XCTAssertNotNil(placeholder)
            XCTAssertNil(placeholder?.animationView, path)
            XCTAssertEqual(placeholder?.imageView.image, image, path)
            XCTAssertFalse(placeholder?.imageView.isHidden ?? true, path)
        }
        try? FileManager.default.removeItem(atPath: unknown)
        try? FileManager.default.removeItem(atPath: broken)
    }

    func testGIFPlaysThroughTheGIFAnimator() throws {
        let url = gifURL()
        let placeholder = try? CYLPlaceholderView(itemAttributes: [
            CYLPlaceholderItemGIFURL: url, CYLPlaceholderItemGIFSize: [40, 30],
            CYLPlaceholderItemAnimationOptions: ["contentMode": "center"]
        ], imageBundle: nil)
        XCTAssertNotNil(placeholder)
        let view = try XCTUnwrap(placeholder)
        XCTAssertEqual(CYLTabBarItemAnimatorRegistry.animator(for: url)?.identifier, "GIF")
        let gif = view.animationView
        XCTAssertNotNil(gif, "the GIF subspec plays GIF files")
        XCTAssertEqual(gif?.contentMode, .center)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        view.frame = window.bounds
        window.addSubview(view)
        view.layoutIfNeeded()
        XCTAssertEqual(gif?.frame.width ?? 0, 40, accuracy: 0.01)
        XCTAssertEqual(gif?.frame.height ?? 0, 30, accuracy: 0.01)
        view.showPlaceholderAnimationLastFrame()
        view.stopPlaceholderAnimation()
        view.playPlaceholderAnimation()
        view.removeFromSuperview()
        try? FileManager.default.removeItem(at: url)
    }

    func testACustomAnimatorReceivesOptionsAndPlays() {
        let animator = CYLRegistryTestAnimator()
        CYLTabBarItemAnimatorRegistry.registerAnimator(animator)
        let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("custom.cyltest")
        try? "custom".write(toFile: path, atomically: true, encoding: .utf8)
        let placeholder = try? CYLPlaceholderView(itemAttributes: [
            CYLPlaceholderItemAnimationURL: URL(fileURLWithPath: path),
            CYLPlaceholderItemAnimationOptions: ["name": "a b&c", "count": 2]
        ], imageBundle: nil)
        let view = placeholder?.animationView as? CYLRegistryTestView
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.options, ["name": "a b&c", "count": "2"])
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        if let placeholder { window.addSubview(placeholder) }
        if !UIAccessibility.isReduceMotionEnabled { XCTAssertGreaterThan(animator.player?.plays ?? 0, 0) }
        let stops = animator.player?.stops ?? 0
        placeholder?.removeFromSuperview()
        XCTAssertGreaterThan(animator.player?.stops ?? 0, stops, "off screen: stopped")
        XCTAssertFalse(placeholder?.setPlaceholderAnimationSpeed(2) ?? true, "the player has no speed")
        CYLTabBarItemAnimatorRegistry.unregisterAnimator(withIdentifier: "CYLTest")
        XCTAssertNil(CYLTabBarItemAnimatorRegistry.animator(withIdentifier: "CYLTest"))
        try? FileManager.default.removeItem(atPath: path)
    }
}
