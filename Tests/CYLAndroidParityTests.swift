//
//  CYLAndroidParityTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] The iOS APIs added for parity with the Android core (docs/iOS-API-Map.md); each test mirrors the Android unit
//       test named in its comment. Swift since step 13 of docs/Swift-Migration.md (was CYLAndroidParityTests.m).
//  [CN] 为与 Android 核心对齐而新增的 iOS API（docs/iOS-API-Map.md）；每个测试对应注释中所列的 Android 单元测试。
//       自 docs/Swift-Migration.md 第 13 步起用 Swift 编写（原 CYLAndroidParityTests.m）。
//

import XCTest
import UIKit

#if CYL_ANIMATION_ENGINE_AVAILABLE
/**
 * [EN] The view and player of the test animator below; the player does nothing, the test only checks that a view is
 *      made. [CN] 下面测试 animator 的视图与播放器；播放器不做任何事，本测试只检查视图是否创建。
 */
private final class CYLParityGIFView: UIView {}

private final class CYLParityGIFPlayer: CYLTabBarItemAnimationBasePlayer, CYLTabBarItemAnimationPlayer {
    func play() {}
    func stop() {}
    func showLastFrame() {}
}

/**
 * [EN] A GIF animator for the engine, as the GIF subspec registers one. [CN] 引擎的 GIF animator，与 GIF 子库注册的相同。
 */
private final class CYLParityGIFAnimator: NSObject, CYLTabBarItemAnimator {
    var identifier: String { "CYLParityGIF" }
    var priority: CYLTabBarItemAnimatorPriority { CYLTabBarItemAnimatorPriority(rawValue: 2000) }
    func canAnimateFile(at url: URL) -> Bool { url.pathExtension.lowercased() == "gif" }
    func animationView(with url: URL, size: CGSize, contentMode: UIView.ContentMode) -> UIView? {
        CYLParityGIFView(frame: CGRect(origin: .zero, size: size))
    }
    func player(forAnimationView view: UIView) -> CYLTabBarItemAnimationPlayer? {
        view is CYLParityGIFView ? CYLParityGIFPlayer(animationView: view) : nil
    }
}
#endif

/**
 * [EN] A table data source whose row count the test sets. [CN] 由测试设置行数的表格数据源。
 */
private final class CYLParityRows: NSObject, UITableViewDataSource {
    var rows = 0
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
}

/**
 * [EN] The iOS APIs added for parity with the Android core (docs/iOS-API-Map.md); each test mirrors the Android unit
 *      test named in its comment.
 * [CN] 为与 Android 核心对齐而新增的 iOS API；每个测试对应注释中所列的 Android 单元测试。
 */
final class CYLAndroidParityTests: XCTestCase {

    private var window: UIWindow?

    override func setUp() {
        super.setUp()
        CYLPlaceholderLocalization.language = "en"
    }

    override func tearDown() {
        window?.isHidden = true
        window = nil
        CYLPlaceholderLocalization.language = nil
        super.tearDown()
    }

    /**
     * [EN] Runs the main run loop until `condition` holds or 10 seconds pass; the placeholder updates on the next turn.
     * [CN] 运行主 run loop，直到 `condition` 成立或经过 10 秒；占位图在下一轮更新。
     */
    private func waitFor(_ condition: () -> Bool) -> Bool {
        let deadline = Date(timeIntervalSinceNow: 10)
        while !condition() && deadline.timeIntervalSinceNow > 0 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        }
        return condition()
    }

    /**
     * [EN] Android: CYLTableViewPlaceHolderTest (`RecyclerView.cyl_placeholderView`).
     * [CN] Android：CYLTableViewPlaceHolderTest（`RecyclerView.cyl_placeholderView`）。
     */
    func testTheListReportsThePlaceholderItShows() {
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), style: .plain)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let rows = CYLParityRows()
        table.dataSource = rows
        let window = UIWindow(frame: table.frame)
        self.window = window
        window.addSubview(table)
        window.isHidden = false
        XCTAssertNil(table.cyl_placeholderView, "no placeholder before the block API is used")

        let placeholder = UIView()
        table.cyl_placeholderViewBlock { _ in placeholder }
        table.reloadData()
        XCTAssertTrue(waitFor { table.cyl_placeholderView === placeholder }, "an empty list reports the placeholder it shows")

        rows.rows = 3
        table.reloadData()
        XCTAssertTrue(waitFor { table.cyl_placeholderView == nil }, "data came: the placeholder goes")
        table.cyl_placeholderViewBlock(nil)
    }

    /**
     * [EN] Android: CYLPlaceholderStackViewTest (`hintLabel`, `button`, `imageView`, `titleLabel`).
     * [CN] Android：CYLPlaceholderStackViewTest（`hintLabel`、`button`、`imageView`、`titleLabel`）。
     */
    func testTheStackViewNamesItsFirstHintButtonIconAndTitle() {
        let results = CYLPlaceholderStackView(scenario: .noSearchResults, actions: nil)
        XCTAssertEqual(results.hintLabel?.text, "Try different keywords")
        XCTAssertNil(results.button, "no button in this scenario")
        XCTAssertEqual(results.titleLabel.text, "No matching results")
        XCTAssertEqual(results.imageView, results.placeholderView.imageView)

        var tapped = 0
        let handler: CYLPlaceholderActionHandler = { _, _ in tapped += 1 }
        let cart = CYLPlaceholderStackView(scenario: .emptyCart, actions: [.goShopping: handler])
        XCTAssertNil(cart.hintLabel)
        XCTAssertEqual(cart.button?.textLabel.text, "Go shopping")
        XCTAssertTrue(cart.button?.performTap() ?? false)
        XCTAssertEqual(tapped, 1, "the button runs its action")
    }

    /**
     * [EN] Android: `CYLPlaceholderComponent.text(title, sizeSp, color)`.
     * [CN] Android：`CYLPlaceholderComponent.text(title, sizeSp, color)`。
     */
    func testATextComponentHasItsOwnSizeAndColor() {
        let text = CYLPlaceholderComponent.text("Hello", fontSize: 22, color: .red)
        XCTAssertEqual(text.attributes[CYLPlaceholderItemTitle] as? String, "Hello")
        XCTAssertEqual(text.attributes[CYLPlaceholderItemTitleColor] as? UIColor, UIColor.red)
        let font = text.attributes[CYLPlaceholderItemTitleFont] as? UIFont
        XCTAssertGreaterThanOrEqual(font?.pointSize ?? 0, 22 - 0.01, "at least the size asked (Dynamic Type may enlarge it)")
        let plain = CYLPlaceholderComponent.text("Plain", fontSize: 0, color: nil)
        XCTAssertNil(plain.attributes[CYLPlaceholderItemTitleFont], "0 keeps the default look")
        XCTAssertNil(plain.attributes[CYLPlaceholderItemTitleColor])
        let stack = CYLPlaceholderStackView(components: [text], actions: nil)
        XCTAssertEqual(stack.titleLabel.text, "Hello")
    }

    /**
     * [EN] Android: CYLPlaceholderViewTest (`setAnimationFile`).
     * [CN] Android：CYLPlaceholderViewTest（`setAnimationFile`）。
     */
    func testAnAnimationFileReplacesTheIconOnlyWhenItPlays() {
        let view = CYLPlaceholderView(style: .empty, text: "Empty")
        XCTAssertFalse(view.setAnimationFile("Missing.json"), "a missing file keeps the icon")
        XCTAssertNil(view.itemAttributes[CYLPlaceholderItemAnimationFilePath])
        #if CYL_ANIMATION_ENGINE_AVAILABLE
        // [EN] Animations play through CYLTabBarController's engine: with no animator for GIF (the test build has the engine
        //      and no animation library) the icon is kept; with one registered, the file replaces it.
        // [CN] 动画通过 CYLTabBarController 的引擎播放：没有 GIF 的 animator 时（测试工程有引擎、没有动画库）保留图标；注册之后文件代替图标。
        XCTAssertFalse(view.setAnimationFile("CYLRefreshArrows.gif"))
        XCTAssertNil(view.itemAttributes[CYLPlaceholderItemAnimationFilePath])
        let animator = CYLParityGIFAnimator()
        CYLTabBarItemAnimatorRegistry.registerAnimator(animator)
        XCTAssertTrue(view.setAnimationFile("CYLRefreshArrows.gif"))
        XCTAssertEqual(((view.itemAttributes[CYLPlaceholderItemAnimationFilePath] as? String) as NSString?)?.lastPathComponent,
                       "CYLRefreshArrows.gif")
        XCTAssertNotNil(view.animationView)
        CYLTabBarItemAnimatorRegistry.unregisterAnimator(withIdentifier: animator.identifier)
        #else
        XCTAssertFalse(view.setAnimationFile("CYLRefreshArrows.gif"), "no engine: nothing plays")
        #endif
    }

    /**
     * [EN] Android: CYLPlaceholderConfigurationTest (`CYLPlaceholderConfigurationError`).
     * [CN] Android：CYLPlaceholderConfigurationTest（`CYLPlaceholderConfigurationError`）。
     */
    func testARefusedConfigurationNamesItsDomainAndKind() {
        var error: NSError?
        let badItem: [String: Any] = [CYLPlaceholderItemTitle: 42]
        XCTAssertNil(captureError(&error) { try CYLPlaceholderView(itemAttributes: badItem, imageBundle: nil) })
        XCTAssertEqual(error?.domain, CYLPlaceholderConfigurationErrorDomain)
        XCTAssertEqual(error?.code, CYLPlaceholderConfigurationError.Code.itemAttributes.rawValue)

        error = nil
        let badStack: [String: Any] = ["scenario": "Nope"]
        XCTAssertNil(captureError(&error) { try CYLPlaceholderStackView(configuration: badStack, actions: nil) })
        XCTAssertEqual(error?.domain, CYLPlaceholderConfigurationErrorDomain)
        XCTAssertEqual(error?.code, CYLPlaceholderConfigurationError.Code.stackView.rawValue)
    }

    /**
     * [EN] Android: `CYLRefreshIconView.IMAGES` and `DURATION`.
     * [CN] Android：`CYLRefreshIconView.IMAGES` 与 `DURATION`。
     */
    func testImageFramesBecomeOneAnimatedIcon() {
        let first = CYLPlaceholderView.image(for: .refresh)!
        let second = CYLPlaceholderView.image(for: .empty)!
        let frames = [first, second]
        let attributes: [String: Any] = [CYLPlaceholderItemImages: frames, CYLPlaceholderItemAnimationDuration: 0.4]
        var error: NSError?
        let view = captureError(&error) { try CYLPlaceholderView(itemAttributes: attributes, imageBundle: nil) }
        XCTAssertNotNil(view, "\(String(describing: error))")
        let icon = view?.imageView.image
        XCTAssertNotNil(icon)
        if !UIAccessibility.isReduceMotionEnabled {
            XCTAssertEqual(icon?.images?.count, 2, "the frames play in a loop")
            XCTAssertEqual(icon?.duration ?? 0, 0.4, accuracy: 0.001)
        }
        let bad: [String: Any] = [CYLPlaceholderItemImages: ["not an image"]]
        XCTAssertNil(captureError(&error) { try CYLPlaceholderView(itemAttributes: bad, imageBundle: nil) })
        XCTAssertEqual(error?.code, CYLPlaceholderConfigurationError.Code.itemAttributes.rawValue)
    }

    /**
     * [EN] Android: `CYLRefreshFlyHeader.mountainView`, `flyView`, `floatView`.
     * [CN] Android：`CYLRefreshFlyHeader.mountainView`、`flyView`、`floatView`。
     */
    func testThePaperPlaneHeaderShowsItsSceneViews() {
        let header = CYLRefreshFlyHeader(refreshingBlock: {})
        XCTAssertNotNil(header.mountainView)
        XCTAssertNotNil(header.flyView)
        XCTAssertNotNil(header.floatView)
        XCTAssertEqual(header.flyView.superview, header)
        XCTAssertEqual(header.floatView.superview, header)
    }
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
