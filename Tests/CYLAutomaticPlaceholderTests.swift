//
//  CYLAutomaticPlaceholderTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The automatic placeholder of tables and collection views, and CYLPlaceholderView's configuration, appearance,
//       badge, selection and animation. Swift since docs/Swift-Migration.md, step 13; compiled into the library's
//       module, so it reads internal members (`itemFrame`, `selectionIndicatorView`) directly.
//  [CN] 表格与集合视图的自动占位图，以及 CYLPlaceholderView 的配置、外观、角标、选中与动画。自 docs/Swift-Migration.md 第 13 步起用
//       Swift 编写；编译进库的模块，因此直接读取内部成员（`itemFrame`、`selectionIndicatorView`）。
//

import XCTest
import UIKit
#if canImport(CYLAnimatedItem)
import CYLAnimatedItem
#elseif canImport(CYLTabBarController)
import CYLTabBarController
#endif

/**
 * [EN] A local file for an animator: the base class makes no animation view for a missing or empty local file.
 * [CN] 供 animator 使用的本地文件：本地文件不存在或为空时，基类不会创建动画视图。
 */
private func temporaryAnimationFile(_ pathExtension: String) -> String {
    let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("CYLPlaceholder-\(UUID().uuidString).\(pathExtension)")
    try? Data("animation".utf8).write(to: URL(fileURLWithPath: path), options: .atomic)
    return path
}

/**
 * [EN] `initWithItemAttributes:imageBundle:error:` as the Objective-C tests read it: the view or nil, and the error.
 * [CN] 以 Objective-C 测试的方式调用 `initWithItemAttributes:imageBundle:error:`：返回视图或 nil，以及错误。
 */
private func makePlaceholder(_ attributes: [AnyHashable: Any], imageBundle: Bundle? = nil) -> (view: CYLPlaceholderView?, error: Error?) {
    do {
        return (try CYLPlaceholderView(itemAttributes: attributes, imageBundle: imageBundle), nil)
    } catch {
        return (nil, error)
    }
}

/**
 * [EN] `initWithItemContentsOfURL:imageBundle:error:`: the view or nil, and the error.
 * [CN] `initWithItemContentsOfURL:imageBundle:error:`：返回视图或 nil，以及错误。
 */
private func makePlaceholder(contentsOf url: URL, imageBundle: Bundle? = nil) -> (view: CYLPlaceholderView?, error: Error?) {
    do {
        return (try CYLPlaceholderView(itemContentsOf: url, imageBundle: imageBundle), nil)
    } catch {
        return (nil, error)
    }
}

/**
 * [EN] A solid image of `size` (default scale). [CN] 指定尺寸的纯色图片（默认 scale）。
 */
private func solidImage(_ color: UIColor?, _ size: CGSize) -> UIImage {
    UIGraphicsImageRenderer(size: size).image { _ in
        color?.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
    }
}

#if CYL_ANIMATION_ENGINE_AVAILABLE
/**
 * [EN] The view of the test animator. [CN] 测试 animator 的视图。
 */
private final class TestEngineView: UIView {}

/**
 * [EN] A player of CYLTabBarController's animation engine that counts what the placeholder asks.
 * [CN] CYLTabBarController 动画引擎的播放器，记录占位图的调用。
 */
private final class TestEnginePlayer: CYLTabBarItemAnimationBasePlayer, CYLTabBarItemAnimationPlayer {
    var plays = 0
    var stops = 0
    var lastFrames = 0
    @objc var progress: CGFloat = 0
    @objc var animationSpeed: CGFloat = 0
    @objc var loops = false
    func play() { plays += 1; progress = 0 }
    func stop() { stops += 1 }
    func showLastFrame() { lastFrames += 1; progress = 1 }
}

/**
 * [EN] An animator registered with `CYLTabBarItemAnimatorRegistry`, as an animation subspec registers its own.
 * [CN] 注册到 `CYLTabBarItemAnimatorRegistry` 的 animator，与动画子库注册自己的 animator 相同。
 */
private final class TestEngineAnimator: NSObject, CYLTabBarItemAnimator {
    var identifier = ""
    var fileExtensions: [String] = []
    var priority = CYLTabBarItemAnimatorPriority(rawValue: 0)
    var lastSize = CGSize.zero
    var lastPlayer: TestEnginePlayer?
    func canAnimateFile(at URL: URL) -> Bool {
        fileExtensions.contains(URL.pathExtension.lowercased())
    }
    func animationView(with URL: URL, size: CGSize, contentMode: UIView.ContentMode) -> UIView? {
        lastSize = size
        return TestEngineView(frame: CGRect(origin: .zero, size: size))
    }
    func player(forAnimationView view: UIView) -> CYLTabBarItemAnimationPlayer? {
        guard view is TestEngineView else { return nil }
        lastPlayer = TestEnginePlayer(animationView: view)
        return lastPlayer
    }
}
#endif

/**
 * [EN] Scopes appearance-proxy values to these tests. [CN] 将外观代理的值限定在这些测试中。
 */
private final class AppearanceTestContainer: UIView {}

/**
 * [EN] A registered factory's player that counts what the placeholder asks. [CN] 已注册工厂的播放器，记录占位图的调用。
 */
private final class TestAnimationPlayer: UIView, CYLPlaceholderAnimationPlayer {
    var isReady = false
    var errorHandler: ((Error) -> Void)?
    var readyHandler: (() -> Void)?
    var plays = 0
    var stops = 0
    var lastFrames = 0
    var colors: [String: UIColor]?
    func play() { plays += 1 }
    func stop() { stops += 1 }
    func showLastFrame() { lastFrames += 1 }
    func setAnimationColors(_ colors: [String: UIColor]) -> Bool { self.colors = colors; return true }
}

/**
 * [EN] The data source of the tests: `count` rows or items in one section, and the legacy placeholder view.
 * [CN] 测试的数据源：一个分区中 `count` 行或项，以及旧接口的占位视图。
 */
private class AutomaticTestSource: NSObject, UITableViewDataSource, UICollectionViewDataSource, CYLTableViewPlaceHolderDelegate {
    var count = 0
    var legacyView: UIView?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell(style: .default, reuseIdentifier: nil)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
    // [EN] Only `cylReloadData` asks, and only the test that sets `legacyView` calls it.
    // [CN] 只有 `cylReloadData` 会调用，且只有设置了 `legacyView` 的测试调用它。
    func makePlaceHolderView() -> UIView { legacyView ?? UIView() }
}

/**
 * [EN] `sections` sections; only the last one has `count` rows or items. [CN] `sections` 个分区；只有最后一个有 `count` 行或项。
 */
private final class MultipleAutomaticTestSource: AutomaticTestSource {
    var sections = 0
    func numberOfSections(in tableView: UITableView) -> Int { sections }
    func numberOfSections(in collectionView: UICollectionView) -> Int { sections }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == sections - 1 ? count : 0
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == sections - 1 ? count : 0
    }
}

private func pixelColor(_ image: UIImage, _ point: CGPoint) -> UIColor {
    var pixel: [UInt8] = [0, 0, 0, 0]
    let space = CGColorSpaceCreateDeviceRGB()
    pixel.withUnsafeMutableBytes { buffer in
        guard let context = CGContext(data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                                      space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let cgImage = image.cgImage else { return }
        let scale = image.scale
        context.draw(cgImage, in: CGRect(x: -point.x * scale, y: -(image.size.height - point.y) * scale + 1,
                                         width: image.size.width * scale, height: image.size.height * scale))
    }
    return UIColor(red: CGFloat(pixel[0]) / 255.0, green: CGFloat(pixel[1]) / 255.0, blue: CGFloat(pixel[2]) / 255.0,
                   alpha: CGFloat(pixel[3]) / 255.0)
}

private func colorIsClose(_ color: UIColor, _ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> Bool {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    return color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) &&
        abs(red - r) < 0.1 && abs(green - g) < 0.1 && abs(blue - b) < 0.1
}

final class CYLAutomaticPlaceholderTests: XCTestCase {

    func testConfiguredSelectedAppearanceRestoresLiveNormalValues() throws {
        let normal = solidImage(.blue, CGSize(width: 20, height: 20))
        let selected = solidImage(.red, CGSize(width: 20, height: 20))
        var result = makePlaceholder([
            CYLPlaceholderItemImage: normal,
            CYLPlaceholderItemTitle: "Normal",
            CYLPlaceholderItemSelectedImage: selected,
            CYLPlaceholderItemSelectedTitle: "Selected",
            CYLPlaceholderItemSelectedTitleColor: UIColor.red,
            CYLPlaceholderItemSelectedIconColor: UIColor.blue,
            CYLPlaceholderItemSelectedBackgroundColor: UIColor.yellow,
            CYLPlaceholderItemSelectedTitleFont: 22
        ])
        XCTAssertNotNil(result.view)
        let placeholder = try XCTUnwrap(result.view)
        placeholder.textLabel.text = "Changed"
        let originalColor = placeholder.textLabel.textColor
        let originalFont = placeholder.textLabel.font
        placeholder.isSelected = true
        XCTAssertIdentical(placeholder.imageView.image, selected)
        XCTAssertEqual(placeholder.textLabel.text, "Selected")
        XCTAssertEqual(placeholder.textLabel.textColor, UIColor.red)
        XCTAssertEqual(placeholder.imageView.tintColor, UIColor.blue)
        XCTAssertEqual(placeholder.backgroundColor, UIColor.yellow)
        XCTAssertEqual(placeholder.textLabel.font.pointSize, 22, accuracy: 0.01)
        XCTAssertTrue(placeholder.accessibilityTraits.contains(.selected))
        placeholder.isSelected = false
        XCTAssertIdentical(placeholder.imageView.image, normal)
        XCTAssertEqual(placeholder.textLabel.text, "Changed")
        XCTAssertEqual(placeholder.textLabel.textColor, originalColor)
        XCTAssertEqual(placeholder.textLabel.font, originalFont)
        XCTAssertFalse(placeholder.accessibilityTraits.contains(.selected))
        result = makePlaceholder([CYLPlaceholderItemSelectedTitleColor: "not-a-color"])
        XCTAssertNil(result.view)
        XCTAssertNotNil(result.error)
    }

    func testSelectedAppearancePreservesEmptyAndHiddenNormalContent() throws {
        let result = makePlaceholder([CYLPlaceholderItemSelectedTitle: "Selected"])
        XCTAssertNotNil(result.view)
        XCTAssertNil(result.error)
        let placeholder = try XCTUnwrap(result.view)
        placeholder.imageView.image = nil
        placeholder.imageView.isHidden = true
        placeholder.textLabel.text = nil
        placeholder.textLabel.isHidden = true
        placeholder.backgroundColor = nil
        placeholder.accessibilityTraits.formUnion([.selected, .button])
        for _ in 0..<2 {
            placeholder.isSelected = true
            XCTAssertEqual(placeholder.textLabel.text, "Selected")
            XCTAssertFalse(placeholder.textLabel.isHidden)
            placeholder.isSelected = true
            placeholder.isSelected = false
            XCTAssertNil(placeholder.imageView.image)
            XCTAssertTrue(placeholder.imageView.isHidden)
            XCTAssertNil(placeholder.textLabel.text)
            XCTAssertTrue(placeholder.textLabel.isHidden)
            XCTAssertNil(placeholder.backgroundColor)
            XCTAssertTrue(placeholder.accessibilityTraits.contains(.selected))
            XCTAssertTrue(placeholder.accessibilityTraits.contains(.button))
        }
    }

    func testConfiguredImagesResolveForLightDarkAndSelection() throws {
        let image = { (color: UIColor) in solidImage(color, CGSize(width: 12, height: 12)) }
        let light = image(.red), dark = image(.blue)
        let selected = image(.green), selectedDark = image(.yellow)
        var result = makePlaceholder([
            CYLPlaceholderItemImage: light, CYLPlaceholderItemDarkImage: dark,
            CYLPlaceholderItemSelectedImage: selected, CYLPlaceholderItemSelectedDarkImage: selectedDark
        ])
        XCTAssertNotNil(result.view)
        XCTAssertNil(result.error)
        let placeholder = try XCTUnwrap(result.view)
        let lightTraits = UITraitCollection(traitsFrom: [
            UITraitCollection(displayScale: light.scale), UITraitCollection(userInterfaceStyle: .light)])
        let darkTraits = UITraitCollection(traitsFrom: [
            UITraitCollection(displayScale: dark.scale), UITraitCollection(userInterfaceStyle: .dark)])
        let resolved = { (traits: UITraitCollection) in placeholder.imageView.image?.imageAsset?.image(with: traits).cgImage }
        XCTAssertIdentical(resolved(lightTraits), light.cgImage)
        XCTAssertIdentical(resolved(darkTraits), dark.cgImage)
        placeholder.isSelected = true
        XCTAssertIdentical(resolved(lightTraits), selected.cgImage)
        XCTAssertIdentical(resolved(darkTraits), selectedDark.cgImage)
        placeholder.isSelected = false
        XCTAssertIdentical(resolved(darkTraits), dark.cgImage)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.overrideUserInterfaceStyle = .light
        window.addSubview(placeholder)
        XCTAssertEqual(placeholder.imageView.traitCollection.userInterfaceStyle, .light)
        XCTAssertIdentical(resolved(placeholder.imageView.traitCollection), light.cgImage)
        window.overrideUserInterfaceStyle = .dark
        expectation(for: NSPredicate { _, _ in
            placeholder.imageView.traitCollection.userInterfaceStyle == .dark
        }, evaluatedWith: placeholder, handler: nil)
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertIdentical(resolved(placeholder.imageView.traitCollection), dark.cgImage)
        placeholder.isSelected = true
        XCTAssertIdentical(resolved(placeholder.imageView.traitCollection), selectedDark.cgImage)
        placeholder.removeFromSuperview()
        result = makePlaceholder([CYLPlaceholderItemDarkImage: 42])
        XCTAssertNil(result.view)
        XCTAssertNotNil(result.error)
    }

    func testBadgeDotTextLayoutAndAccessibility() {
        let image = CYLPlaceholderView.image(for: .empty)
        let placeholder = CYLPlaceholderView(image: image, text: "Empty")
        placeholder.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        placeholder.accessibilityValue = "Existing"
        placeholder.badgeCenterOffset = CGPoint(x: 3, y: 5)
        placeholder.badgeValue = ""
        placeholder.layoutIfNeeded()
        placeholder.imageView.superview?.layoutIfNeeded()
        XCTAssertFalse(placeholder.badgeLabel.isHidden)
        XCTAssertEqual(placeholder.badgeLabel.bounds.size.width, 8, accuracy: 0.01)
        XCTAssertEqual(placeholder.badgeLabel.center.x, placeholder.imageView.frame.maxX + 5, accuracy: 0.01)
        XCTAssertEqual(placeholder.badgeLabel.center.y, placeholder.imageView.frame.minY + 5, accuracy: 0.01)
        XCTAssertGreaterThan(placeholder.accessibilityValue?.count ?? 0, 0)
        XCTAssertEqual(placeholder.badgeLabel.accessibilityLabel, placeholder.accessibilityValue)
        XCTAssertTrue(placeholder.badgeLabel.isAccessibilityElement)
        placeholder.badgeValue = "123"
        placeholder.imageView.superview?.layoutIfNeeded()
        XCTAssertGreaterThan(placeholder.badgeLabel.bounds.size.width, 8)
        XCTAssertEqual(placeholder.accessibilityValue, "123")
        placeholder.badgeValue = nil
        XCTAssertTrue(placeholder.badgeLabel.isHidden)
        XCTAssertEqual(placeholder.accessibilityValue, "Existing")
        placeholder.badgeValue = "New"
        placeholder.accessibilityValue = "Custom"
        placeholder.badgeValue = "Updated"
        placeholder.badgeValue = nil
        XCTAssertEqual(placeholder.accessibilityValue, "Custom")
        placeholder.badgeCenterOffset = CGPoint(x: CGFloat.nan, y: 1)
        XCTAssertEqual(placeholder.badgeCenterOffset.x, 3, accuracy: 0.01)
        XCTAssertTrue(placeholder.showBadge(with: .dot, value: nil))
        XCTAssertEqual(placeholder.badgeValue, "")
        XCTAssertTrue(placeholder.showBadge(with: .number, value: "105"))
        XCTAssertEqual(placeholder.badgeValue, "99+")
        XCTAssertFalse(placeholder.showBadge(with: .number, value: "3x"))
        XCTAssertEqual(placeholder.badgeValue, "99+")
        XCTAssertTrue(placeholder.showBadge(with: .text, value: "New"))
        XCTAssertEqual(placeholder.badgeValue, "New")
        XCTAssertTrue(placeholder.showBadge(with: .number, value: "0"))
        XCTAssertNil(placeholder.badgeValue)
        XCTAssertFalse(placeholder.showBadge(with: .text, value: ""))
        XCTAssertTrue(placeholder.showBadge(with: .none, value: nil))
    }

    func testSelectionIndicatorFollowsStateAndItemBounds() throws {
        let image = try XCTUnwrap(CYLPlaceholderView.image(for: .empty))
        let placeholder = CYLPlaceholderView(image: image, text: "Empty")
        placeholder.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        placeholder.selectionIndicatorImage = image
        placeholder.selectionIndicatorTintColor = .blue
        let item = try XCTUnwrap(placeholder.imageView.superview)
        XCTAssertEqual(item.subviews.count, 2)
        placeholder.isSelected = true
        placeholder.layoutIfNeeded()
        let indicator = try XCTUnwrap(item.subviews.first as? UIImageView)
        XCTAssertNotIdentical(indicator, placeholder.imageView)
        XCTAssertEqual(indicator.image?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(indicator.tintColor, UIColor.blue)
        XCTAssertEqual(indicator.contentMode, .center)
        XCTAssertTrue(indicator.frame.equalTo(placeholder.itemFrame))
        placeholder.frame = CGRect(x: 0, y: 0, width: 480, height: 320)
        placeholder.layoutIfNeeded()
        XCTAssertTrue(indicator.frame.equalTo(placeholder.itemFrame))
        placeholder.selectionIndicatorImage = image.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        XCTAssertEqual(indicator.contentMode, .scaleToFill)
        placeholder.selectionIndicatorImage = image.withRenderingMode(.alwaysOriginal)
        XCTAssertEqual(indicator.image?.renderingMode, .alwaysOriginal)
        placeholder.isSelected = false
        XCTAssertNil(indicator.superview)
        XCTAssertEqual(item.subviews.count, 2)
    }

    func testRegisteredAnimationFactoryLifecycleAndFailure() throws {
        var player: TestAnimationPlayer?
        var calls = 0
        XCTAssertTrue(CYLPlaceholderView.registerAnimationFactory({ url, size, _, options, _ in
            calls += 1
            XCTAssertEqual(url.pathExtension.lowercased(), "cyltest")
            XCTAssertNil((url as NSURL).fragment, "the factory gets the file; the options come separately")
            XCTAssertEqual(size.width, 40, accuracy: 0.01)
            XCTAssertEqual(options["setting"] as? String, "value")
            let made = TestAnimationPlayer()
            player = made
            return made
        }, forFileExtension: "CYLTEST"))
        XCTAssertTrue(CYLPlaceholderView.registerAnimationFactory(nil, forFileExtension: "gif"), "no extension is reserved")
        XCTAssertFalse(CYLPlaceholderView.registerAnimationFactory(nil, forFileExtension: ".cyltest"))
        let image = try XCTUnwrap(CYLPlaceholderView.image(for: .noInternet))
        let path = temporaryAnimationFile("cyltest")
        let attributes: [AnyHashable: Any] = [
            CYLPlaceholderItemAnimationFilePath: path,
            CYLPlaceholderItemAnimationSize: [40, 30],
            CYLPlaceholderItemAnimationOptions: ["setting": "value"],
            CYLPlaceholderItemImage: image
        ]
        let result = makePlaceholder(attributes)
        XCTAssertNotNil(result.view)
        let placeholder = try XCTUnwrap(result.view)
        XCTAssertEqual(calls, 1)
        XCTAssertIdentical(placeholder.animationView, player, "the factory's view plays through the engine")
        XCTAssertFalse(placeholder.imageView.layer.isHidden, "not ready yet: the static image shows")
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(placeholder)
        let made = try XCTUnwrap(player)
        if !UIAccessibility.isReduceMotionEnabled { XCTAssertEqual(made.plays, 1) }
        made.isReady = true
        try XCTUnwrap(made.readyHandler)()
        drainUpdates()
        XCTAssertTrue(placeholder.imageView.layer.isHidden, "ready: the animation covers the static image")
        placeholder.showPlaceholderAnimationLastFrame()
        XCTAssertEqual(made.lastFrames, 1)
        placeholder.stopPlaceholderAnimation()
        XCTAssertGreaterThan(made.stops, 0)
        try XCTUnwrap(made.errorHandler)(NSError(domain: "CYLTest", code: 1, userInfo: nil))
        drainUpdates()
        XCTAssertFalse(placeholder.imageView.layer.isHidden, "a failure shows the static image again")
        XCTAssertIdentical(placeholder.imageView.image, image)
        XCTAssertNil(made.superview)
        var invalidSize = attributes
        invalidSize[CYLPlaceholderItemAnimationSize] = [0, 30]
        _ = makePlaceholder(invalidSize)
        XCTAssertEqual(calls, 1)
        XCTAssertTrue(CYLPlaceholderView.registerAnimationFactory(nil, forFileExtension: "cyltest"))
        try? FileManager.default.removeItem(atPath: path)
    }

    func testRegisteredAnimationReceivesResolvedAppearanceColors() throws {
        var player: TestAnimationPlayer?
        XCTAssertTrue(CYLPlaceholderView.registerAnimationFactory({ _, _, _, _, _ in
            let made = TestAnimationPlayer()
            made.isReady = true
            player = made
            return made
        }, forFileExtension: "cylcolors"))
        let path = temporaryAnimationFile("cylcolors")
        let attributes: [AnyHashable: Any] = [
            CYLPlaceholderItemAnimationFilePath: path,
            CYLPlaceholderItemAnimationColors: ["Shape.Color": "#ff0000", "Other": UIColor.green],
            CYLPlaceholderItemAnimationDarkColors: ["Shape.Color": "#0000ff"]
        ]
        var result = makePlaceholder(attributes)
        XCTAssertNotNil(result.view)
        let placeholder = try XCTUnwrap(result.view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.overrideUserInterfaceStyle = .light
        window.addSubview(placeholder)
        XCTAssertEqual(player?.colors?["Shape.Color"], UIColor.red)
        XCTAssertEqual(player?.colors?["Other"], UIColor.green)
        window.overrideUserInterfaceStyle = .dark
        expectation(for: NSPredicate { _, _ in
            player?.colors?["Shape.Color"]?.isEqual(UIColor.blue) ?? false
        }, evaluatedWith: placeholder, handler: nil)
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertEqual(player?.colors?["Other"], UIColor.green)
        result = makePlaceholder([CYLPlaceholderItemAnimationColors: ["Shape.Color": "invalid"]])
        XCTAssertNil(result.view)
        XCTAssertNotNil(result.error)
        placeholder.removeFromSuperview()
        XCTAssertTrue(CYLPlaceholderView.registerAnimationFactory(nil, forFileExtension: "cylcolors"))
        try? FileManager.default.removeItem(atPath: path)
    }

    private func drainUpdates() {
        let done = expectation(description: "placeholder update")
        DispatchQueue.main.async { done.fulfill() }
        wait(for: [done], timeout: 15)
    }

    func testAutomaticPlaceholderStaysAboveTheKeyboard() {
        let source = AutomaticTestSource()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let table = UITableView(frame: window.bounds)
        window.addSubview(table)
        table.dataSource = source
        let placeholder = UIView()
        table.cylPlaceholderViewBlock { _ in placeholder }
        table.reloadData()
        drainUpdates()
        table.layoutIfNeeded()
        XCTAssertEqual(placeholder.frame.height, 480, accuracy: 0.1, "no keyboard: the whole table")
        let keyboard = window.convert(CGRect(x: 0, y: 280, width: 320, height: 200), to: window.screen.coordinateSpace)
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil,
                                        userInfo: [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: keyboard)])
        table.layoutIfNeeded()
        XCTAssertEqual(placeholder.frame.height, 280, accuracy: 0.1, "above the keyboard (CYLSearchViewController's report)")
        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: nil)
        table.layoutIfNeeded()
        XCTAssertEqual(placeholder.frame.height, 480, accuracy: 0.1, "the keyboard hides: the whole table again")
        table.cylPlaceholderViewBlock(nil)
    }

    func testTableReloadInsertDeleteAndCancellation() {
        let source = AutomaticTestSource()
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        table.dataSource = source
        let placeholder = UIView()
        var restores = 0
        table.cylPlaceholderViewBlock({ view in
            view.isScrollEnabled = false
            return placeholder
        }, backToNormalBlock: { view in
            restores += 1
            view.isScrollEnabled = true
        })
        table.reloadData()
        drainUpdates()
        XCTAssertIdentical(placeholder.superview, table)
        XCTAssertFalse(table.isScrollEnabled)
        table.layoutIfNeeded()
        XCTAssertEqual(placeholder.frame.width, 320, accuracy: 0.1)
        table.frame = CGRect(x: 0, y: 0, width: 480, height: 320)
        table.layoutIfNeeded()
        XCTAssertEqual(placeholder.frame.width, 480, accuracy: 0.1)
        source.count = 1
        table.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        drainUpdates()
        XCTAssertNil(placeholder.superview)
        XCTAssertEqual(restores, 1)
        XCTAssertTrue(table.isScrollEnabled)
        source.count = 0
        table.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        drainUpdates()
        XCTAssertIdentical(placeholder.superview, table)
        table.cylPlaceholderViewBlock(nil)
        XCTAssertNil(placeholder.superview)
        XCTAssertEqual(restores, 2)
        table.reloadData()
        drainUpdates()
        XCTAssertNil(placeholder.superview)
    }

    func testCollectionBatchUpdatesAndCancellation() {
        let source = AutomaticTestSource()
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480),
                                          collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.dataSource = source
        let placeholder = UIView()
        var restores = 0
        collection.cylPlaceholderViewBlock({ _ in placeholder }, backToNormalBlock: { _ in restores += 1 })
        collection.reloadData()
        drainUpdates()
        XCTAssertIdentical(placeholder.superview, collection)
        collection.performBatchUpdates({
            source.count = 1
            collection.insertItems(at: [IndexPath(item: 0, section: 0)])
        }, completion: nil)
        drainUpdates()
        XCTAssertNil(placeholder.superview)
        XCTAssertEqual(restores, 1)
        collection.performBatchUpdates({
            source.count = 0
            collection.deleteItems(at: [IndexPath(item: 0, section: 0)])
        }, completion: nil)
        drainUpdates()
        XCTAssertIdentical(placeholder.superview, collection)
        collection.cylPlaceholderViewBlock(nil)
        XCTAssertEqual(restores, 2)
    }

    func testLegacyAndAutomaticPlaceholderDoNotOverlap() {
        let source = AutomaticTestSource()
        source.legacyView = UIView()
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        table.dataSource = source
        table.cylReloadData()
        XCTAssertIdentical(source.legacyView?.superview, table)
        let view = UIView()
        table.cylPlaceholderViewBlock { _ in view }
        table.cylReloadData()
        drainUpdates()
        XCTAssertNil(source.legacyView?.superview)
        XCTAssertIdentical(view.superview, table)
        table.cylPlaceholderViewBlock(nil)
        table.cylReloadData()
        XCTAssertIdentical(source.legacyView?.superview, table)
    }

    func testCancelledPendingUpdateDoesNotCallBlock() {
        let source = AutomaticTestSource()
        let table = UITableView()
        table.dataSource = source
        var calls = 0
        table.cylPlaceholderViewBlock { _ in calls += 1; return UIView() }
        table.cylPlaceholderViewBlock(nil)
        drainUpdates()
        XCTAssertEqual(calls, 0)
    }

    func testRestoreCanReplaceConfigurationDuringCancellation() {
        let source = AutomaticTestSource()
        let table = UITableView()
        table.dataSource = source
        let first = UIView()
        let replacement = UIView()
        table.cylPlaceholderViewBlock({ _ in first }, backToNormalBlock: { view in
            view.cylPlaceholderViewBlock { _ in replacement }
        })
        drainUpdates()
        XCTAssertIdentical(first.superview, table)
        table.cylPlaceholderViewBlock(nil)
        drainUpdates()
        XCTAssertNil(first.superview)
        XCTAssertIdentical(replacement.superview, table)
        table.cylPlaceholderViewBlock(nil)
    }

    func testDefaultPlaceholderLoadsResources() {
        let placeholder = CYLPlaceholderView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        XCTAssertNotNil(placeholder.imageView.image)
        XCTAssertTrue((placeholder.textLabel.text?.count ?? 0) > 0)
    }

    func testConfiguredPlaceholderLayoutAndValidation() throws {
        let image = solidImage(.red, CGSize(width: 80, height: 80))
        let base: [AnyHashable: Any] = ["CYLTabBarItemImage": image, "CYLTabBarItemTitle": "Example",
                                        "CYLTabBarAnimationURL": "future-animation.json"]
        var result = makePlaceholder(base)
        XCTAssertNotNil(result.view)
        XCTAssertNil(result.error)
        let plain = try XCTUnwrap(result.view)
        XCTAssertEqual(plain.itemAttributes["CYLTabBarAnimationURL"] as? String, "future-animation.json")
        var adjusted = base
        adjusted["CYLTabBarItemTitlePositionAdjustment"] = [4, 6]
        adjusted["CYLTabBarItemImagePositionAdjustment"] = ["x": 8, "y": 10]
        adjusted["CYLTabBarItemImageInsets"] = [1, 2, 3, 4]
        let view = try XCTUnwrap(makePlaceholder(adjusted).view)
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        plain.frame = view.frame
        plain.layoutIfNeeded()
        view.layoutIfNeeded()
        XCTAssertEqual(view.textLabel.frame.minX - plain.textLabel.frame.minX, 4, accuracy: 0.01)
        XCTAssertEqual(view.textLabel.frame.minY - plain.textLabel.frame.minY, 6, accuracy: 0.01)
        XCTAssertEqual(view.imageView.frame.minX - plain.imageView.frame.minX, 8, accuracy: 0.01)
        XCTAssertEqual(view.imageView.frame.minY - plain.imageView.frame.minY, 13, accuracy: 0.01)
        XCTAssertEqual(view.imageView.frame.size.width, 74, accuracy: 0.01)
        XCTAssertEqual(view.imageView.frame.size.height, 76, accuracy: 0.01)
        adjusted["CYLTabBarItemImagePositionAdjustment"] = ["bad", 0]
        result = makePlaceholder(adjusted)
        XCTAssertNil(result.view)
        XCTAssertNotNil(result.error)
        result = makePlaceholder(contentsOf: try XCTUnwrap(URL(string: "https://example.com/item.plist")))
        XCTAssertNil(result.view)
        XCTAssertNotNil(result.error)
    }

    func testPlaceholderViewIsTheSharedAnimatedItemView() throws {
        let view = CYLPlaceholderView(style: .empty, message: .empty)
        XCTAssertTrue((view as AnyObject) is CYLAnimatedItemView, "CYLPlaceholderView subclasses CYLAnimatedItemView")
        XCTAssertIdentical(view.textLabel, view.titleLabel)
        XCTAssertEqual(view.axis, .vertical)
        XCTAssertIdentical(view.image, view.imageView.image, "the static image is the base class's image")
        XCTAssertEqual(view.title, view.textLabel.text)
        // [EN] The placeholder's accessibility, not the base class's button. [CN] 使用占位图的无障碍设置，而不是基类的按钮。
        XCTAssertFalse(view.isAccessibilityElement, "a decoration until it has a label or a tap event")
        XCTAssertFalse(view.accessibilityTraits.contains(.button))
        XCTAssertNil(view.accessibilityIdentifier)
        XCTAssertTrue(view.textLabel.isAccessibilityElement, "the text reads on its own")
        view.tapHandler = { _ in }
        XCTAssertTrue(view.isAccessibilityElement)
        XCTAssertTrue(view.accessibilityTraits.contains(.button))
        // [EN] An image set on `imageView` becomes the static image, so the base class keeps it through state changes.
        // [CN] 设置到 `imageView` 的图片成为静态图片，基类在状态变化时保留它。
        let other = try XCTUnwrap(CYLPlaceholderView.image(for: .error))
        view.imageView.image = other
        XCTAssertIdentical(view.image, other)
        view.isSelected = true
        view.isSelected = false
        XCTAssertIdentical(view.imageView.image, other)
        XCTAssertFalse(view.imageView.isHidden)
        // [EN] The display priority of the base class: an animation that cannot play shows the static image, else the
        //      component's placeholder. [CN] 基类的显示优先级：无法播放的动画显示静态图片，没有时显示组件的占位图。
        view.animationURL = URL(fileURLWithPath: "/missing/animation.json")
        XCTAssertIdentical(view.imageView.image, other)
        let bare = CYLPlaceholderView(image: nil, text: "Text")
        bare.animationURL = URL(fileURLWithPath: "/missing/animation.json")
        XCTAssertIdentical(bare.imageView.image, bare.placeholderImage)
        XCTAssertNil(bare.animationView)
    }

    #if CYL_ANIMATION_ENGINE_AVAILABLE
    func testAnAnimationFilePlaysThroughTheEngineAndFollowsThePlaybackPolicy() throws {
        let animator = TestEngineAnimator()
        animator.identifier = "CYLTestGIF"
        animator.fileExtensions = ["gif"]
        animator.priority = CYLTabBarItemAnimatorPriority(rawValue: 2000)
        // [EN] The class method `+registerAnimator:` forwards to the shared registry; Swift sees only the instance method.
        // [CN] 类方法 `+registerAnimator:` 转发给共享注册表；Swift 只能看到实例方法。
        CYLTabBarItemAnimatorRegistry.shared().register(animator)
        let path = CYLPlaceholderView.path(forBundledAnimation: "CYLRefreshArrows.gif")
        XCTAssertNotNil(path)
        var result = makePlaceholder([
            CYLPlaceholderItemGIFFilePath: path as Any, CYLPlaceholderItemGIFSize: [40, 30],
            CYLPlaceholderItemTitle: "Offline"
        ])
        XCTAssertNotNil(result.view)
        let placeholder = try XCTUnwrap(result.view)
        XCTAssertTrue(animator.lastSize.equalTo(CGSize(width: 40, height: 30)), NSCoder.string(for: animator.lastSize))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        placeholder.frame = window.bounds
        window.addSubview(placeholder)
        placeholder.layoutIfNeeded()
        let animationView = placeholder.animationView
        XCTAssertTrue(animationView is TestEngineView)
        XCTAssertIdentical(animationView?.superview, placeholder)
        XCTAssertEqual(animationView?.frame.width ?? 0, 40, accuracy: 0.01)
        XCTAssertEqual(animationView?.frame.height ?? 0, 30, accuracy: 0.01)
        XCTAssertTrue(placeholder.imageView.isHidden, "the animation covers the static image")
        let player = try XCTUnwrap(placeholder.animationPlayer as? TestEnginePlayer)
        XCTAssertIdentical(player, animator.lastPlayer)
        if !UIAccessibility.isReduceMotionEnabled {
            var plays = player.plays
            XCTAssertGreaterThan(plays, 0, "plays once on screen")
            var stops = player.stops
            placeholder.isHidden = true
            XCTAssertGreaterThan(player.stops, stops, "hidden: stopped")
            placeholder.isHidden = false
            XCTAssertGreaterThan(player.plays, plays, "shown again: plays")
            stops = player.stops
            placeholder.stopPlaceholderAnimation()
            XCTAssertGreaterThan(player.stops, stops)
            placeholder.showPlaceholderAnimationLastFrame()
            XCTAssertEqual(player.lastFrames, 1)
            plays = player.plays
            placeholder.removeFromSuperview()
            window.addSubview(placeholder)
            XCTAssertEqual(player.plays, plays, "a stopped animation stays stopped")
            placeholder.playPlaceholderAnimation()
            XCTAssertEqual(player.plays, plays + 1)
            // [EN] The base class's spelling follows the same policy. [CN] 基类的写法遵循同样的策略。
            stops = player.stops
            placeholder.stopAnimation()
            XCTAssertGreaterThan(player.stops, stops)
            placeholder.playAnimation()
            XCTAssertEqual(player.plays, plays + 2)
        }
        XCTAssertTrue(placeholder.setPlaceholderAnimationSpeed(2))
        XCTAssertEqual(player.animationSpeed, 2, accuracy: 0.001)
        placeholder.animationRepeatCount = 0
        XCTAssertTrue(player.loops, "0 loops")
        placeholder.animationRepeatCount = 1
        XCTAssertFalse(player.loops)
        XCTAssertTrue(placeholder.setPlaceholderAnimationProgress(0.5))
        XCTAssertEqual(player.progress, 0.5, accuracy: 0.001)
        placeholder.removeFromSuperview()
        CYLTabBarItemAnimatorRegistry.shared().unregisterAnimator(withIdentifier: "CYLTestGIF")
        // [EN] Without an animator for the file the static image shows. [CN] 没有该文件的 animator 时显示静态图片。
        result = makePlaceholder([
            CYLPlaceholderItemGIFFilePath: path as Any, CYLPlaceholderItemStyle: CYLPlaceholderStyle.refresh.rawValue
        ])
        let fallback = try XCTUnwrap(result.view)
        XCTAssertNil(fallback.animationView)
        XCTAssertNotNil(fallback.imageView.image)
        XCTAssertFalse(fallback.imageView.isHidden)
        XCTAssertFalse(fallback.setAnimationFile("CYLRefreshArrows.gif"), "no animator plays it")
    }
    #endif

    func testUnavailableAnimationBackendPreservesStaticImage() throws {
        let image = try XCTUnwrap(CYLPlaceholderView.image(for: .noInternet))
        for key in [CYLPlaceholderItemLottieFilePath, CYLPlaceholderItemPAGFilePath,
                    CYLPlaceholderItemRiveFilePath, CYLPlaceholderItemAnimationFilePath] {
            let pathExtension = key == CYLPlaceholderItemPAGFilePath ? "pag" :
                (key == CYLPlaceholderItemRiveFilePath ? "riv" : "json")
            let path = (NSTemporaryDirectory() as NSString).appendingPathComponent(
                "missing-placeholder-animation.\(pathExtension)")
            let result = makePlaceholder([
                key: path, CYLPlaceholderItemImage: image, CYLPlaceholderItemAnimationSize: [40, 30]
            ])
            XCTAssertNotNil(result.view)
            XCTAssertNil(result.error)
            let placeholder = try XCTUnwrap(result.view)
            XCTAssertIdentical(placeholder.imageView.image, image)
            XCTAssertFalse(placeholder.imageView.layer.isHidden)
            XCTAssertEqual(placeholder.imageView.superview?.subviews.count, 2)
        }
    }

    func testGIFFailureKeepsStaticImage() throws {
        let image = try XCTUnwrap(CYLPlaceholderView.image(for: .noInternet))
        let result = makePlaceholder([
            CYLPlaceholderItemGIFURL: try XCTUnwrap(URL(string: "https://example.com/image.gif")),
            CYLPlaceholderItemImage: image,
            CYLPlaceholderItemTitle: "Offline"
        ])
        XCTAssertNotNil(result.view)
        let placeholder = try XCTUnwrap(result.view)
        XCTAssertIdentical(placeholder.imageView.image, image)
        XCTAssertFalse(placeholder.imageView.layer.isHidden)
        XCTAssertEqual(placeholder.imageView.superview?.subviews.count, 2)
    }

    func testFlatDesignItemUsesSourceGeometryAndUpdates() {
        let image = solidImage(.blue, CGSize(width: 40, height: 30))
        let view = CYLPlaceholderView(image: image, text: "Offline")
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        view.layoutIfNeeded()
        // [EN] The icon and the title are the base class's subviews, laid out in the item frame.
        // [CN] 图标与标题是基类的子视图，在 item 区域中布局。
        XCTAssertIdentical(view.imageView.superview, view)
        XCTAssertIdentical(view.textLabel.superview, view)
        var item = view.itemFrame
        XCTAssertEqual(view.imageView.frame.width, 40, accuracy: 0.01)
        XCTAssertEqual(view.imageView.frame.height, 30, accuracy: 0.01)
        XCTAssertEqual(view.imageView.frame.minY - item.minY,
                       (view.textLabel.frame.minY - item.minY - 30) / 2, accuracy: 0.01)
        XCTAssertEqual(view.textLabel.frame.maxY, item.maxY - 2, accuracy: 0.01)
        XCTAssertEqual(item.midY, view.bounds.midY, accuracy: 0.01)
        XCTAssertEqual(view.imageView.frame.midX, item.midX, accuracy: 0.01)

        view.textLabel.isHidden = true
        view.layoutIfNeeded()
        item = view.itemFrame
        XCTAssertEqual(view.imageView.frame.midY, item.midY, accuracy: 0.01)
        view.textLabel.isHidden = false
        view.imageView.isHidden = true
        view.layoutIfNeeded()
        item = view.itemFrame
        XCTAssertEqual(view.textLabel.frame.midY, item.midY, accuracy: 0.01)
        view.imageView.isHidden = false
        view.textLabel.text = "A longer message that should wrap in a narrow placeholder"
        view.frame = CGRect(x: 0, y: 0, width: 160, height: 300)
        view.layoutIfNeeded()
        XCTAssertLessThanOrEqual(view.textLabel.frame.width, 128)
        XCTAssertGreaterThan(view.textLabel.frame.height, view.textLabel.font.lineHeight)
        XCTAssertEqual(view.itemFrame.midY, 150, accuracy: 0.01)
        view.textLabel.text = "Short"
        view.textLabel.font = UIFont.systemFont(ofSize: 24)
        view.imageView.image = solidImage(nil, CGSize(width: 60, height: 50))
        view.layoutIfNeeded()
        XCTAssertEqual(view.imageView.frame.width, 60, accuracy: 0.01)
        XCTAssertEqual(view.imageView.frame.height, 50, accuracy: 0.01)
        XCTAssertGreaterThan(view.textLabel.frame.height, 20)
        XCTAssertEqual(view.itemFrame.midY, 150, accuracy: 0.01)
    }

    func testConfiguredPlaceholderPropertyListAndPresets() throws {
        // [EN] The same item as the main example's CYLPlaceholderExample.bundle/CYLPlaceholderItemDemo.plist; the core
        //      bundle holds only placeholder resources, so the test writes its own copy.
        // [CN] 与主示例 CYLPlaceholderExample.bundle/CYLPlaceholderItemDemo.plist 相同；核心 bundle 只放占位资源，因此测试自己写一份。
        let item: NSDictionary = [
            "CYLPlaceholderItemStyle": 5, "CYLPlaceholderItemMessage": 2,
            "CYLTabBarItemImagePositionAdjustment": ["horizontal": 8, "vertical": -6],
            "CYLTabBarItemTitlePositionAdjustment": [0, 6],
            "CYLTabBarAnimationFilePath": "reserved-animation.json"
        ]
        let url = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString).appendingPathComponent("CYLPlaceholderItemDemo.plist"))
        XCTAssertTrue(item.write(to: url, atomically: true))
        var result = makePlaceholder(contentsOf: url)
        XCTAssertNotNil(result.view)
        XCTAssertNil(result.error)
        var view = try XCTUnwrap(result.view)
        XCTAssertNotNil(view.imageView.image)
        XCTAssertEqual(view.textLabel.text, CYLPlaceholderView.localizedText(for: .noInternet))
        XCTAssertEqual(view.itemAttributes[CYLPlaceholderItemAnimationFilePath] as? String, "reserved-animation.json")
        let custom = UIImage()
        view = try XCTUnwrap(makePlaceholder([
            CYLPlaceholderItemStyle: CYLPlaceholderStyle.warning.rawValue,
            CYLPlaceholderItemMessage: CYLPlaceholderMessage.error.rawValue,
            CYLPlaceholderItemImage: custom,
            CYLPlaceholderItemTitle: "Custom"
        ]).view)
        XCTAssertIdentical(view.imageView.image, custom)
        XCTAssertEqual(view.textLabel.text, "Custom")
        result = makePlaceholder([CYLPlaceholderItemStyle: -1])
        XCTAssertNil(result.view)
        XCTAssertNotNil(result.error)
        result = makePlaceholder([CYLPlaceholderItemMessage: NSNull()])
        XCTAssertNil(result.view)
        XCTAssertNotNil(result.error)
        result = makePlaceholder([CYLPlaceholderItemImage: "missing-image"], imageBundle: CYLPlaceholderResourceBundle())
        XCTAssertNil(result.view)
        XCTAssertNotNil(result.error)
    }

    func testConfiguredPlaceholderAppearance() throws {
        var result = makePlaceholder([
            CYLPlaceholderItemStyle: CYLPlaceholderStyle.warning.rawValue,
            CYLPlaceholderItemTitle: "Example",
            CYLPlaceholderItemTitleColor: "#123",
            CYLPlaceholderItemIconColor: UIColor.red,
            CYLPlaceholderItemBackgroundColor: "#44556680",
            CYLPlaceholderItemTitleFont: "bold:18",
            CYLPlaceholderItemAccessibilityLabel: "Offline",
            CYLPlaceholderItemAccessibilityHint: "Try again later"
        ])
        XCTAssertNotNil(result.view)
        XCTAssertNil(result.error)
        let view = try XCTUnwrap(result.view)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        XCTAssertTrue(view.textLabel.textColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        XCTAssertEqual(red, 0x11 / 255.0, accuracy: 0.001)
        XCTAssertEqual(green, 0x22 / 255.0, accuracy: 0.001)
        XCTAssertEqual(blue, 0x33 / 255.0, accuracy: 0.001)
        XCTAssertEqual(view.imageView.tintColor, UIColor.red)
        XCTAssertEqual(view.textLabel.font.pointSize, 18, accuracy: 0.001)
        XCTAssertEqual(view.accessibilityLabel, "Offline")
        XCTAssertEqual(view.accessibilityHint, "Try again later")
        XCTAssertTrue(view.isAccessibilityElement)
        result = makePlaceholder([CYLPlaceholderItemTitleColor: "#ZZZ"])
        XCTAssertNil(result.view)
        XCTAssertNotNil(result.error)
        result = makePlaceholder([CYLPlaceholderItemTitleFont: "bold:-1"])
        XCTAssertNil(result.view)
        XCTAssertNotNil(result.error)
        result = makePlaceholder([CYLPlaceholderItemImage: "system:house"])
        XCTAssertNotNil(result.view?.imageView.image)
    }

    func testAdditionalPlaceholderImagesLoadFromResourceBundle() throws {
        let container = Bundle(for: CYLPlaceholderView.self)
        var url = container.url(forResource: "CYLTableViewPlaceHolder", withExtension: "bundle")
        if url == nil { url = Bundle.main.url(forResource: "CYLTableViewPlaceHolder", withExtension: "bundle") }
        XCTAssertNotNil(url)
        let bundle = try XCTUnwrap(url.flatMap { Bundle(url: $0) })
        for name in ["CYLPlaceholderNoResults", "CYLPlaceholderNoInternet",
                     "CYLPlaceholderError", "CYLPlaceholderWarning", "CYLPlaceholderInbox"] {
            XCTAssertNotNil(UIImage(named: name, in: bundle, compatibleWith: nil), name)
        }
        XCTAssertNotNil(bundle.url(forResource: "LICENSE", withExtension: "material-design-icons"))
        XCTAssertNotNil(bundle.url(forResource: "NOTICE", withExtension: "material-design-icons"))
    }

    func testEveryPlaceholderStyleAndMessage() throws {
        var names = Set<String>()
        for i in 0..<CYLPlaceholderStyle.count.rawValue {
            let style = try XCTUnwrap(CYLPlaceholderStyle(rawValue: i))
            let name = CYLPlaceholderView.imageName(for: style)
            XCTAssertNotNil(name, "Missing style name \(i)")
            XCTAssertFalse(names.contains(name ?? ""), "Duplicate style \(name ?? "")")
            if let name = name { names.insert(name) }
            XCTAssertNotNil(CYLPlaceholderView.image(for: style), "Missing image \(name ?? "")")
        }
        for i in 0..<CYLPlaceholderMessage.count.rawValue {
            let message = try XCTUnwrap(CYLPlaceholderMessage(rawValue: i))
            XCTAssertTrue((CYLPlaceholderView.localizedText(for: message)?.count ?? 0) > 0)
        }
        var view = CYLPlaceholderView(style: .noInternet, message: .serverUnavailable)
        XCTAssertNotNil(view.imageView.image)
        XCTAssertEqual(view.textLabel.text, CYLPlaceholderView.localizedText(for: .serverUnavailable))
        let custom = UIImage()
        view = CYLPlaceholderView(image: custom, text: "Custom message")
        XCTAssertIdentical(view.imageView.image, custom)
        XCTAssertEqual(view.textLabel.text, "Custom message")
        view = CYLPlaceholderView(style: .warning, text: nil)
        XCTAssertTrue(view.textLabel.isHidden)
        XCTAssertNotNil(view.imageView.image)
        view = CYLPlaceholderView(image: nil, text: "Text only")
        XCTAssertTrue(view.imageView.isHidden)
    }

    func testBundledAnimationsAreListedValidAndAttributed() {
        let names = CYLPlaceholderView.bundledAnimationFileNames()
        XCTAssertEqual(names.count, 62, "\(names)")
        let magic = ["pag": "PAG", "riv": "RIVE", "gif": "GIF8"]
        var notice: String?
        for name in names {
            let path = CYLPlaceholderView.path(forBundledAnimation: name)
            XCTAssertNotNil(path, name)
            let data = path.flatMap { FileManager.default.contents(atPath: $0) }
            XCTAssertGreaterThan(data?.count ?? 0, 64, name)
            let pathExtension = (name as NSString).pathExtension
            if pathExtension == "json" {
                let json = data.flatMap { try? JSONSerialization.jsonObject(with: $0) } as? [String: Any]
                XCTAssertNotNil(json?["layers"], "\(name) is not a Lottie animation")
            } else {
                let prefix = magic[pathExtension]
                XCTAssertNotNil(prefix, "Unexpected file \(name)")
                if let prefix = prefix {
                    let head = (data ?? Data()).prefix(prefix.count)
                    XCTAssertEqual(String(data: head, encoding: .ascii), prefix, name)
                }
            }
            if notice == nil, let path = path {
                let noticePath = ((path as NSString).deletingLastPathComponent as NSString).appendingPathComponent("NOTICE.animations")
                notice = try? String(contentsOfFile: noticePath, encoding: .utf8)
            }
            XCTAssertTrue(notice?.contains(name) ?? false, "\(name) has no attribution in NOTICE.animations")
        }
        for scenario in ["CYLPlaceholderLoading.json", "CYLPlaceholderLoading.pag", "CYLPlaceholderLoading.riv",
                         "CYLPlaceholderUploading.gif", "CYLPlaceholderEmptyCart.json"] {
            XCTAssertTrue(names.contains(scenario), scenario)
        }
        XCTAssertNil(CYLPlaceholderView.path(forBundledAnimation: "Missing.json"))
        XCTAssertNil(CYLPlaceholderView.path(forBundledAnimation: "../Animations/CYLPlaceholderLoading.json"))
        XCTAssertNil(CYLPlaceholderView.path(forBundledAnimation: ""))
    }

    func testPlaceholderLocalizationsHaveAllMessageKeys() {
        let container = Bundle(for: CYLPlaceholderView.self)
        var url = container.url(forResource: "CYLTableViewPlaceHolder", withExtension: "bundle")
        if url == nil { url = Bundle.main.url(forResource: "CYLTableViewPlaceHolder", withExtension: "bundle") }
        let bundle = url.flatMap { Bundle(url: $0) }
        let keys = ["CYLPlaceholderEmptyText", "CYLPlaceholderNoResultsText",
                    "CYLPlaceholderNoInternetText", "CYLPlaceholderServerUnavailableText", "CYLPlaceholderErrorText",
                    "CYLPlaceholderLoadingText", "CYLPlaceholderNoPermissionText", "CYLPlaceholderEmptyCartText",
                    "CYLPlaceholderNoNotificationsText", "CYLPlaceholderBadgeNewContent"]
        for language in ["en", "zh-Hans", "zh-Hant", "ja", "ko", "ru", "uk"] {
            let path = bundle?.path(forResource: language, ofType: "lproj")
            XCTAssertNotNil(path, "Missing localization \(language)")
            guard let languagePath = path, let languageBundle = Bundle(path: languagePath) else { continue }
            for key in keys {
                let text = languageBundle.localizedString(forKey: key, value: nil, table: nil)
                XCTAssertNotEqual(text, key, "Missing \(key) in \(language)")
                XCTAssertTrue(text.count > 0)
            }
        }
    }

    func testTableBatchAndSectionUpdatesAcrossMultipleSections() {
        let source = MultipleAutomaticTestSource()
        source.sections = 2
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        table.dataSource = source
        let view = UIView()
        table.cylPlaceholderViewBlock { _ in view }
        table.reloadData()
        drainUpdates()
        XCTAssertIdentical(view.superview, table)
        table.beginUpdates()
        source.count = 1
        table.insertRows(at: [IndexPath(row: 0, section: 1)], with: .none)
        table.endUpdates()
        drainUpdates()
        XCTAssertNil(view.superview)
        let batchExecuted = expectation(description: "table batch executed")
        table.performBatchUpdates({
            source.sections = 1
            source.count = 0
            table.deleteSections(IndexSet(integer: 1), with: .none)
            batchExecuted.fulfill()
        }, completion: nil)
        wait(for: [batchExecuted], timeout: 15)
        drainUpdates()
        XCTAssertIdentical(view.superview, table)
        table.cylPlaceholderViewBlock(nil)
    }

    func testAutomaticPlaceholderStaysBelowRefreshControls() throws {
        let source = MultipleAutomaticTestSource()
        source.sections = 1
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480),
                                          collectionViewLayout: UICollectionViewFlowLayout())
        collection.dataSource = source
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.cylHeader = CYLRefreshNormalHeader(refreshingBlock: {})
        collection.cylFooter = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        let view = UIView()
        collection.cylPlaceholderViewBlock { _ in view }
        collection.reloadData()
        drainUpdates()
        let subviews = collection.subviews
        let placeholderIndex = subviews.firstIndex(of: view)
        XCTAssertNotNil(placeholderIndex)
        let index = try XCTUnwrap(placeholderIndex)
        XCTAssertGreaterThan(subviews.firstIndex { $0 === collection.cylFooter } ?? NSNotFound, index)
        XCTAssertGreaterThan(subviews.firstIndex { $0 === collection.cylHeader } ?? NSNotFound, index)
        collection.cylPlaceholderViewBlock(nil)
    }

    // [EN] An empty list has nothing more to load: its footer and trailer hide while the placeholder shows (the header
    //      stays, issue #8) and show again with the data; a footer the app hid itself stays hidden.
    // [CN] 空列表没有更多可加载：占位图显示期间刷新尾与 trailer 隐藏（刷新头保留，issue #8），数据恢复后重新显示；应用自己隐藏的刷新尾保持隐藏。
    func testLoadMoreControlsHideWhileThePlaceholderShows() {
        let source = AutomaticTestSource()
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        table.dataSource = source
        let header = CYLRefreshNormalHeader(refreshingBlock: {})
        let footer = CYLRefreshAutoNormalFooter(refreshingBlock: {})
        let trailer = CYLRefreshNormalTrailer(refreshingBlock: {})
        table.cylHeader = header
        table.cylFooter = footer
        table.cylTrailer = trailer
        let view = UIView()
        table.cylPlaceholderViewBlock { _ in view }
        table.reloadData()
        drainUpdates()
        XCTAssertIdentical(view.superview, table)
        XCTAssertTrue(footer.isHidden, "no load-more footer over an empty list")
        XCTAssertTrue(trailer.isHidden, "no load-more trailer over an empty list")
        XCTAssertFalse(header.isHidden, "pull to refresh stays on an empty list")

        source.count = 3
        table.reloadData()
        drainUpdates()
        XCTAssertNil(view.superview)
        XCTAssertFalse(footer.isHidden, "the footer returns with the data")
        XCTAssertFalse(trailer.isHidden)

        footer.isHidden = true
        source.count = 0
        table.reloadData()
        drainUpdates()
        source.count = 3
        table.reloadData()
        drainUpdates()
        XCTAssertTrue(footer.isHidden, "a footer the app hid stays hidden")
        table.cylPlaceholderViewBlock(nil)
    }

    func testLegacyPlaceholderHidesTheFooterToo() {
        let source = AutomaticTestSource()
        source.legacyView = UIView()
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        table.dataSource = source
        let footer = CYLRefreshBackNormalFooter(refreshingBlock: {})
        table.cylFooter = footer
        table.cylReloadData()
        XCTAssertIdentical(source.legacyView?.superview, table)
        XCTAssertTrue(footer.isHidden)
        source.count = 2
        table.cylReloadData()
        XCTAssertNil(source.legacyView?.superview)
        XCTAssertFalse(footer.isHidden)
    }

    func testCollectionSectionsAndFrameLayoutWithOffset() {
        let source = MultipleAutomaticTestSource()
        source.sections = 2
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480),
                                          collectionViewLayout: UICollectionViewFlowLayout())
        collection.dataSource = source
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        let view = UIView()
        collection.cylPlaceholderViewBlock { _ in view }
        collection.reloadData()
        drainUpdates()
        collection.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        collection.contentOffset = CGPoint(x: 0, y: -20)
        collection.layoutIfNeeded()
        XCTAssertNotEqual(collection.contentOffset.y, 0, accuracy: 0.1)
        XCTAssertEqual(view.frame.origin.y, collection.contentOffset.y, accuracy: 0.1)
        source.count = 1
        collection.reloadSections(IndexSet(integer: 1))
        drainUpdates()
        XCTAssertNil(view.superview)
        source.count = 0
        collection.reloadSections(IndexSet(integer: 1))
        drainUpdates()
        XCTAssertIdentical(view.superview, collection)
        collection.cylPlaceholderViewBlock(nil)
    }

    func testAppearanceDefaultsApplyLiveAndKeepExplicitValues() throws {
        let image = CYLPlaceholderView.image(for: .empty)
        let placeholder = CYLPlaceholderView(image: image, text: "Empty")
        XCTAssertEqual(placeholder.textLabel.textColor, UIColor.gray)
        XCTAssertEqual(placeholder.imageView.tintColor, placeholder.tintColor)
        placeholder.defaultTitleColor = .red
        placeholder.defaultIconColor = .green
        placeholder.defaultTitleFont = UIFont.systemFont(ofSize: 21)
        XCTAssertEqual(placeholder.textLabel.textColor, UIColor.red)
        XCTAssertEqual(placeholder.imageView.tintColor, UIColor.green)
        XCTAssertEqual(placeholder.textLabel.font.pointSize, 21, accuracy: 0.01)
        placeholder.defaultIconColor = nil
        XCTAssertEqual(placeholder.imageView.tintColor, placeholder.tintColor)
        // Selected defaults sit above the normal values and below explicit selected values.
        placeholder.defaultSelectedTitleColor = .blue
        placeholder.isSelected = true
        XCTAssertEqual(placeholder.textLabel.textColor, UIColor.blue)
        placeholder.defaultTitleColor = .orange
        XCTAssertEqual(placeholder.textLabel.textColor, UIColor.blue)
        placeholder.isSelected = false
        XCTAssertEqual(placeholder.textLabel.textColor, UIColor.orange)
        // A value set directly on the label wins over later appearance changes.
        placeholder.textLabel.textColor = .purple
        placeholder.defaultTitleColor = .brown
        XCTAssertEqual(placeholder.textLabel.textColor, UIColor.purple)
        // An explicit item color wins over the appearance default.
        let configured = try XCTUnwrap(makePlaceholder([
            CYLPlaceholderItemTitle: "Item", CYLPlaceholderItemTitleColor: UIColor.cyan,
            CYLPlaceholderItemSelectedTitleColor: UIColor.magenta
        ]).view)
        configured.defaultTitleColor = .red
        configured.defaultSelectedTitleColor = .yellow
        XCTAssertEqual(configured.textLabel.textColor, UIColor.cyan)
        configured.isSelected = true
        XCTAssertEqual(configured.textLabel.textColor, UIColor.magenta)
        configured.isSelected = false
        XCTAssertEqual(configured.textLabel.textColor, UIColor.cyan)
    }

    func testAppearanceProxyAndTintFollowTheHierarchy() {
        let proxyColor = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
        CYLPlaceholderView.appearance(whenContainedInInstancesOf: [AppearanceTestContainer.self]).defaultTitleColor = proxyColor
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let container = AppearanceTestContainer(frame: window.bounds)
        window.addSubview(container)
        window.isHidden = false
        let placeholder = CYLPlaceholderView(image: nil, text: "Proxy")
        placeholder.frame = container.bounds
        container.addSubview(placeholder)
        placeholder.layoutIfNeeded()
        XCTAssertEqual(placeholder.textLabel.textColor, proxyColor)
        window.tintColor = .orange
        XCTAssertEqual(placeholder.imageView.tintColor, UIColor.orange)
        let titleFrame = placeholder.textLabel.frame
        placeholder.defaultTitlePositionAdjustment = UIOffset(horizontal: 3, vertical: -4)
        placeholder.layoutIfNeeded()
        XCTAssertEqual(placeholder.textLabel.frame.minX - titleFrame.minX, 3, accuracy: 0.01)
        XCTAssertEqual(placeholder.textLabel.frame.minY - titleFrame.minY, -4, accuracy: 0.01)
        placeholder.defaultTitlePositionAdjustment = .zero
        let indicator = solidImage(nil, CGSize(width: 4, height: 4))
        placeholder.defaultSelectionIndicatorImage = indicator
        XCTAssertNil(placeholder.selectionIndicatorView)
        placeholder.isSelected = true
        let indicatorView = placeholder.selectionIndicatorView
        XCTAssertNotNil(indicatorView)
        placeholder.isSelected = false
        XCTAssertNil(placeholder.selectionIndicatorView)
        window.isHidden = true
    }

    func testBadgeSharedAppearanceAndSingleAnnouncement() throws {
        let shared = CYLPlaceholderBadgeAppearance.shared()
        let savedText = shared.textColor
        let savedFont = shared.font
        shared.textColor = .red
        shared.font = UIFont.boldSystemFont(ofSize: 15)
        let placeholder = CYLPlaceholderView(image: nil, text: "Inbox")
        placeholder.badgeValue = "3"
        XCTAssertEqual(placeholder.badgeLabel.textColor, UIColor.red)
        XCTAssertEqual(placeholder.badgeLabel.font.pointSize, 15, accuracy: 0.01)
        placeholder.badgeLabel.textColor = .green // customized directly
        shared.textColor = .blue
        shared.font = UIFont.boldSystemFont(ofSize: 11)
        placeholder.badgeValue = "4"
        XCTAssertEqual(placeholder.badgeLabel.textColor, UIColor.green)
        XCTAssertEqual(placeholder.badgeLabel.font.pointSize, 11, accuracy: 0.01)
        shared.textColor = savedText
        shared.font = savedFont

        // A placeholder that is itself an accessibility element announces the badge in its own value only.
        let element = try XCTUnwrap(makePlaceholder([CYLPlaceholderItemTitle: "Inbox"]).view)
        XCTAssertTrue(element.isAccessibilityElement)
        element.accessibilityValue = "Synced"
        element.badgeValue = "2"
        XCTAssertEqual(element.accessibilityValue, "Synced, 2")
        XCTAssertFalse(element.badgeLabel.isAccessibilityElement)
        element.badgeValue = nil
        XCTAssertEqual(element.accessibilityValue, "Synced")

        // Badge state changes are synchronous even when the change is animated.
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.addSubview(element)
        element.badgeValue = "5"
        element.badgeValue = "6"
        XCTAssertEqual(element.badgeLabel.text, "6")
        XCTAssertFalse(element.badgeLabel.isHidden)
        element.badgeValue = nil
        XCTAssertTrue(element.badgeLabel.isHidden)
        XCTAssertTrue(element.badgeLabel.transform.isIdentity)
    }

    func testRenderedItemShowsSelectedImageAndIndicator() throws {
        let solid = { (color: UIColor, size: CGSize) -> UIImage in
            let format = UIGraphicsImageRendererFormat.preferred()
            format.scale = 1
            return UIGraphicsImageRenderer(size: size, format: format).image { _ in
                color.setFill()
                UIRectFill(CGRect(origin: .zero, size: size))
            }
        }
        let placeholder = try XCTUnwrap(makePlaceholder([
            CYLPlaceholderItemImage: solid(.blue, CGSize(width: 40, height: 30)).withRenderingMode(.alwaysOriginal),
            CYLPlaceholderItemSelectedImage: solid(.green, CGSize(width: 40, height: 30)).withRenderingMode(.alwaysOriginal),
            CYLPlaceholderItemTitle: "Rendered", CYLPlaceholderItemBackgroundColor: UIColor.white
        ]).view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        placeholder.frame = window.bounds
        window.addSubview(placeholder)
        window.isHidden = false
        placeholder.layoutIfNeeded()
        let render = { () -> UIImage in
            placeholder.layoutIfNeeded()
            let format = UIGraphicsImageRendererFormat.preferred()
            format.scale = 1
            return UIGraphicsImageRenderer(size: placeholder.bounds.size, format: format).image { context in
                placeholder.layer.render(in: context.cgContext)
            }
        }
        let imageCenter = placeholder.convert(CGPoint(x: placeholder.imageView.bounds.midX, y: placeholder.imageView.bounds.midY),
                                              from: placeholder.imageView)
        XCTAssertTrue(colorIsClose(pixelColor(render(), imageCenter), 0, 0, 1))
        placeholder.selectionIndicatorImage = solid(.red, CGSize(width: 4, height: 4))
            .resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        placeholder.isSelected = true
        let selected = render()
        XCTAssertTrue(colorIsClose(pixelColor(selected, imageCenter), 0, 1, 0))
        let item = placeholder.itemFrame
        XCTAssertTrue(colorIsClose(pixelColor(selected, CGPoint(x: item.minX + 2, y: item.minY + 2)), 1, 0, 0))
        placeholder.isSelected = false
        let normal = render()
        XCTAssertTrue(colorIsClose(pixelColor(normal, imageCenter), 0, 0, 1))
        XCTAssertTrue(colorIsClose(pixelColor(normal, CGPoint(x: item.minX + 2, y: item.minY + 2)), 1, 1, 1))
        window.isHidden = true
    }

    func testBadgeAndTitleFollowAccessibilityTextSizes() {
        let parent = UIViewController()
        let child = UIViewController()
        parent.addChild(child)
        parent.view.addSubview(child.view)
        child.didMove(toParent: parent)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = parent
        window.isHidden = false
        child.view.frame = parent.view.bounds
        let placeholder = CYLPlaceholderView(image: nil, text: "Nothing new")
        placeholder.frame = child.view.bounds
        child.view.addSubview(placeholder)
        _ = placeholder.showBadge(with: .text, value: "New")
        placeholder.layoutIfNeeded()
        placeholder.imageView.superview?.layoutIfNeeded()
        let smallBadge = placeholder.badgeLabel.font.pointSize, smallTitle = placeholder.textLabel.font.pointSize
        parent.setOverrideTraitCollection(UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
                                          forChild: child)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))
        placeholder.layoutIfNeeded()
        placeholder.imageView.superview?.layoutIfNeeded()
        let badge = placeholder.badgeLabel
        let needed = (badge.text ?? "").size(withAttributes: [.font: badge.font as Any])
        NSLog("CYLDynamicType badge %.1f->%.1f title %.1f->%.1f badgeBounds %@ needed %@ titleFrame %@",
              Double(smallBadge), Double(badge.font.pointSize), Double(smallTitle), Double(placeholder.textLabel.font.pointSize),
              NSCoder.string(for: badge.bounds), NSCoder.string(for: needed), NSCoder.string(for: placeholder.textLabel.frame))
        XCTAssertGreaterThan(badge.font.pointSize, smallBadge)
        XCTAssertGreaterThan(placeholder.textLabel.font.pointSize, smallTitle)
        XCTAssertGreaterThanOrEqual(badge.bounds.width, ceil(needed.width))
        XCTAssertGreaterThanOrEqual(badge.bounds.height, ceil(needed.height))
        window.isHidden = true
    }
}
