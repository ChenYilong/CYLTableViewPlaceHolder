//
//  CYLPlaceholderBackendPlaybackTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] PAG and Rive play through CYLTabBarController's animation engine and the animators its `CYLAnimatedItemPAG` and
//       `CYLAnimatedItemRive` subspecs register (brought by this pod's PAG and Rive subspecs). The animators themselves are
//       tested in CYLTabBarController; these tests check what CYLPlaceholderView adds: loading, the playback policy,
//       seeking and the static image as the fallback. The PAG view is read by class name and key-value coding
//       (`-getProgress`, `-isPlaying`, `-repeatCount`), so the file needs no libpag module: the PAGEnterprise umbrella
//       header of libpag-enterprise 4.4.x-4.5.98 imports a missing header and cannot be imported as a module.
//  [CN] PAG 与 Rive 通过 CYLTabBarController 的动画引擎，以及其 `CYLAnimatedItemPAG`、`CYLAnimatedItemRive` 子库注册的 animator 播放（由本 pod
//       的 PAG、Rive 子库带入）。animator 本身在 CYLTabBarController 中测试；这里检查 CYLPlaceholderView 增加的部分：加载、播放策略、定位以及作为回退的静态图片。
//       PAG 视图通过类名与 KVC（`-getProgress`、`-isPlaying`、`-repeatCount`）读取，因此本文件不需要 libpag 模块：libpag-enterprise
//       4.4.x-4.5.98 的 PAGEnterprise 伞头文件引用了不存在的头文件，无法作为模块导入。
//

import CYLAnimatedItem
import CYLTableViewPlaceHolder
import UIKit
import XCTest

/**
 * Upper bound for asynchronous loads: CI simulators can compile Metal shaders for seconds before the first Rive or PAG frame.
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

/**
 * Reads a number through key-value coding (for `progress`, key-value coding calls the PAG view's `-getProgress`).
 */
private func CYLDouble(_ object: NSObject?, _ key: String) -> Double {
    (object?.value(forKey: key) as? NSNumber)?.doubleValue ?? .nan
}

final class CYLPlaceholderBackendPlaybackTests: XCTestCase {

    private func fallbackImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20))
        return renderer.image { _ in
            UIColor.blue.setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: 20, height: 20))
        }
    }

    private func fixture(_ name: String, extension fileExtension: String) -> URL? {
        let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: fileExtension)
        XCTAssertNotNil(url)
        return url
    }

    func testPAGLoadsAndAdvances() throws {
        let url = try XCTUnwrap(fixture("tab_home", extension: "pag"))
        let placeholder = try XCTUnwrap(try? CYLPlaceholderView(itemAttributes: [
            CYLPlaceholderItemPAGURL: url, CYLPlaceholderItemPAGSize: [80, 80]
        ], imageBundle: nil))
        let pag = placeholder.animationView
        let pagClass: AnyClass? = NSClassFromString("PAGView")
        XCTAssertTrue(pagClass != nil && pag?.isKind(of: pagClass!) == true, "the PAG animator plays the file")
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(placeholder)
        if !UIAccessibility.isReduceMotionEnabled {
            // [EN] Poll for the first moved frame, not a fixed delay: a loaded CI runner can tick late (2026-11-20, SVGA).
            // [CN] 轮询第一帧的移动，而不是固定延时：负载高的 CI 会晚到（2026-11-20，SVGA 测试）。
            _ = CYLSpinUntil(timeout: 60) { CYLDouble(pag, "progress") > 0 }
            XCTAssertGreaterThan(CYLDouble(pag, "progress"), 0)
            placeholder.stopPlaceholderAnimation()
            XCTAssertEqual(CYLDouble(pag, "progress"), 0, accuracy: 0.01)
            placeholder.showPlaceholderAnimationLastFrame()
            XCTAssertEqual(CYLDouble(pag, "progress"), 1, accuracy: 0.01)
            XCTAssertTrue(placeholder.setPlaceholderAnimationProgress(0.5))
            let seekFrame = CYLDouble(pag, "progress")
            XCTAssertEqual(seekFrame, 0.5, accuracy: 0.02)
            placeholder.removeFromSuperview()
            window.addSubview(placeholder)
            XCTAssertEqual(CYLDouble(pag, "progress"), seekFrame, accuracy: 0.001)
            XCTAssertFalse(placeholder.setPlaceholderAnimationSpeed(2), "PAG has no playback speed")
            placeholder.playPlaceholderAnimation()
            XCTAssertTrue((pag?.value(forKey: "playing") as? NSNumber)?.boolValue ?? false)
        }
        placeholder.animationRepeatCount = 0
        XCTAssertEqual((pag?.value(forKey: "repeatCount") as? NSNumber)?.intValue, 0, "0 loops")
        placeholder.animationRepeatCount = 1
        XCTAssertEqual((pag?.value(forKey: "repeatCount") as? NSNumber)?.intValue, 1)
        placeholder.removeFromSuperview()
        XCTAssertFalse((pag?.value(forKey: "playing") as? NSNumber)?.boolValue ?? true)
    }

    func testSVGASeeksLoopsAndChangesSpeed() throws {
        let url = try XCTUnwrap(fixture("tab_list", extension: "svga"))
        let placeholder = try XCTUnwrap(try? CYLPlaceholderView(itemAttributes: [
            CYLPlaceholderItemAnimationFilePath: url.path, CYLPlaceholderItemAnimationSize: [80, 80]
        ], imageBundle: nil))
        XCTAssertNotNil(placeholder.animationView, "the SVGA animator plays the file")
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(placeholder)
        // [EN] SVGAParser parses asynchronously. [CN] SVGAParser 异步解析。
        expectation(for: NSPredicate { _, _ in placeholder.isAnimationReady }, evaluatedWith: placeholder, handler: nil)
        waitForExpectations(timeout: CYLTestTimeout, handler: nil)
        // [EN] Seek (the pull scrubs a scene), speed (the examples' slider), loop (refreshing). [CN] 定位、倍速、循环。
        XCTAssertTrue(placeholder.setPlaceholderAnimationProgress(0.5), "the SVGA view seeks (CYLTabBarController 28a9609d)")
        XCTAssertTrue(placeholder.setPlaceholderAnimationProgress(0))
        XCTAssertTrue(placeholder.setPlaceholderAnimationSpeed(2), "the SVGA view changes its rate")
        placeholder.animationRepeatCount = 0
        XCTAssertTrue(placeholder.animationLoops)
        if !UIAccessibility.isReduceMotionEnabled {
            placeholder.playPlaceholderAnimation()
            // [EN] Poll for the first moved frame instead of waiting a fixed 0.3 s: on a loaded CI runner the display link
            //      can tick late (the run of 2026-11-20 saw progress 0.0 after 0.3 s). The bound is generous; the wait
            //      ends as soon as the frame moves. [CN] 轮询第一帧的移动，而不是固定等 0.3 秒：负载高的 CI 上 display link
            //      会晚到（2026-11-20 的运行中 0.3 秒后进度仍为 0）。上限宽松，帧一动就结束。
            _ = CYLSpinUntil(timeout: 60) {
                CYLDouble(placeholder.value(forKey: "animationPlayer") as? NSObject, "progress") > 0
            }
            let player = placeholder.value(forKey: "animationPlayer") as? NSObject
            XCTAssertGreaterThan(CYLDouble(player, "progress"), 0, "playing moves the frame")
        }
        placeholder.removeFromSuperview()
    }

    func testRiveLoadsAndCoversTheStaticImage() throws {
        let url = try XCTUnwrap(fixture("icons", extension: "riv"))
        let image = fallbackImage()
        let placeholder = try XCTUnwrap(try? CYLPlaceholderView(itemAttributes: [
            CYLPlaceholderItemRiveURL: url, CYLPlaceholderItemRiveSize: [80, 80],
            CYLPlaceholderItemImage: image,
            CYLPlaceholderItemAnimationOptions: ["artboard": "CHAT", "stateMachine": "CHAT_Interactivity"]
        ], imageBundle: nil))
        XCTAssertNotNil(placeholder.animationView, "the Rive animator plays the file")
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(placeholder)
        expectation(for: NSPredicate { _, _ in
            placeholder.animationView != nil && placeholder.imageView.layer.isHidden
        }, evaluatedWith: placeholder, handler: nil)
        // [EN] Four times the usual timeout: the first Rive render compiles its Metal shaders, which took over 30 s on a slow
        //      runner (Animation dynamic PAG, 22a2b1b: shader warnings from 10:51:48 to 10:52:20, timeout at 10:52:23).
        // [CN] 超时为通常的四倍：首次渲染 Rive 时会编译 Metal 着色器，在慢速 runner 上超过 30 秒（Animation dynamic PAG，22a2b1b）。
        waitForExpectations(timeout: CYLTestTimeout * 4, handler: nil)
        placeholder.stopPlaceholderAnimation()
        placeholder.playPlaceholderAnimation()
        placeholder.removeFromSuperview()
    }

    func testInvalidRiveRestoresStaticImage() throws {
        let url = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString)
            .appendingPathComponent("CYLInvalid-\(UUID().uuidString).riv"))
        XCTAssertNoThrow(try Data("invalid rive".utf8).write(to: url))
        let image = fallbackImage()
        let placeholder = try XCTUnwrap(try? CYLPlaceholderView(itemAttributes: [
            CYLPlaceholderItemRiveURL: url, CYLPlaceholderItemImage: image
        ], imageBundle: nil))
        // [EN] A corrupted file: the animator reports the failure, the base class drops the animation and shows the image.
        // [CN] 损坏的文件：animator 报告失败，基类移除动画并显示图片。
        expectation(for: NSPredicate { _, _ in placeholder.animationView == nil }, evaluatedWith: placeholder, handler: nil)
        waitForExpectations(timeout: CYLTestTimeout, handler: nil)
        XCTAssertFalse(placeholder.imageView.layer.isHidden)
        XCTAssertEqual(placeholder.imageView.image, image)
        try? FileManager.default.removeItem(at: url)
    }
}
