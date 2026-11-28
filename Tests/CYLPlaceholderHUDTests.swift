//
//  CYLPlaceholderHUDTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] CYLPlaceholderHUD: states, activity count, progress, display durations, notifications, grace time, masks,
//       colors, components and the shared HUD. Swift since step 13 of docs/Swift-Migration.md (was
//       CYLPlaceholderHUDTests.m).
//  [CN] CYLPlaceholderHUD：状态、活动计数、进度、显示时长、通知、宽限时间、遮罩、颜色、组件与共享 HUD。
//       自 docs/Swift-Migration.md 第 13 步起用 Swift 编写（原 CYLPlaceholderHUDTests.m）。
//

import XCTest
import UIKit

final class CYLPlaceholderHUDTests: XCTestCase {

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

    /**
     * [EN] A HUD over the test container with no fades, so every change is immediate.
     * [CN] 覆盖测试容器、没有淡入淡出的 HUD，因此每个变化都是即时的。
     */
    private func makeHUD() -> CYLPlaceholderHUD {
        let hud = CYLPlaceholderHUD(containerView: container)
        hud.fadeInAnimationDuration = 0
        hud.fadeOutAnimationDuration = 0
        return hud
    }

    func testTheHUDScenarioIsALoopingRefreshAnimationWithALoadingTitle() {
        let scenario = CYLPlaceholderScenario.hud
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.category(for: scenario), .progress)
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.name(for: scenario), "HUD")
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.scenario(named: "HUD"), scenario)
        let icon = CYLPlaceholderScenarioCatalog.components(for: scenario).first
        let file = ((icon?.attributes[CYLPlaceholderItemAnimationFilePath] as? String) as NSString?)?.lastPathComponent
        XCTAssertTrue(file?.hasPrefix("CYLRefresh") ?? false, "the HUD reuses the refresh animations: \(String(describing: file))")
        XCTAssertEqual(icon?.animationRepeatCount, 0, "loops by default, unlike a refresh icon that follows the pull")
        XCTAssertEqual(icon?.attributes[CYLPlaceholderItemTitle] as? String, "Loading…")
        let names = CYLPlaceholderScenarioCatalog.animationFileNames(for: scenario)
        for fileExtension in ["gif", "json", "pag", "riv"] {
            let count = names.filter { ($0 as NSString).pathExtension == fileExtension }.count
            XCTAssertGreaterThan(count, 0, fileExtension)
        }
        // [EN] The same scenario works as a full-screen placeholder too. [CN] 同一场景也可作为全屏占位图使用。
        let stack = CYLPlaceholderStackView(scenario: scenario, actions: nil)
        XCTAssertEqual(stack.placeholderView.textLabel.text, "Loading…")
    }

    func testShowLoopsTheLoadingAnimationAndPopActivityBalancesEveryShow() {
        let hud = makeHUD()
        XCTAssertEqual(hud.state, .hidden)
        XCTAssertFalse(hud.isVisible)
        hud.show(status: "Loading")
        XCTAssertTrue(hud.isVisible)
        XCTAssertEqual(hud.state, .loading)
        XCTAssertEqual(hud.superview, container)
        XCTAssertEqual(hud.contentView?.textLabel.text, "Loading")
        let file = ((hud.contentView?.itemAttributes[CYLPlaceholderItemAnimationFilePath] as? String) as NSString?)?.lastPathComponent
        XCTAssertEqual(file, "CYLRefreshActivity.gif")
        XCTAssertEqual(hud.contentView?.animationRepeatCount, 0)

        XCTAssertNil(hud.placeholderView, "one icon and title need no stack view")
        XCTAssertEqual(hud.contentView?.superview, hud.hudView, "the CYLPlaceholderView is the box")
        let first = hud.contentView
        hud.show()
        XCTAssertEqual(hud.activityCount, 2)
        XCTAssertEqual(hud.contentView, first, "the same state updates in place, so the animation keeps playing")
        hud.setStatus("Still loading")
        XCTAssertEqual(hud.contentView?.textLabel.text, "Still loading")
        XCTAssertEqual(hud.status, "Still loading")

        hud.popActivity()
        XCTAssertTrue(hud.isVisible, "one show is not balanced yet")
        hud.popActivity()
        XCTAssertFalse(hud.isVisible)
        XCTAssertEqual(hud.state, .hidden)
        XCTAssertNil(hud.superview)
        XCTAssertNil(hud.placeholderView)
        XCTAssertNil(hud.contentView)
    }

    func testProgressIsClampedAndShownWithoutRestartingTheHUD() {
        let hud = makeHUD()
        hud.show(progress: 0.3, status: "Downloading")
        XCTAssertEqual(hud.state, .progress)
        XCTAssertEqual(hud.progress, 0.3, accuracy: 0.001)
        let first = hud.contentView
        XCTAssertTrue(first?.textLabel.text?.hasPrefix("Downloading") ?? false)
        XCTAssertTrue(first?.textLabel.text?.contains("30") ?? false, "the title carries the percentage")
        hud.show(progress: 1.7)
        XCTAssertEqual(hud.progress, 1, accuracy: 0.001)
        XCTAssertEqual(hud.contentView, first)
        XCTAssertNotNil(hud.contentView?.accessibilityValue, "VoiceOver reads the percentage")
        hud.show(progress: -1)
        XCTAssertEqual(hud.state, .loading, "a negative progress is indeterminate")
        hud.dismiss()
        XCTAssertFalse(hud.isVisible)
    }

    func testResultsDismissThemselvesAfterTheDisplayDuration() {
        let hud = makeHUD()
        XCTAssertEqual(hud.displayDuration(for: "Done"), 5, accuracy: 0.001, "at least the minimum interval")
        hud.minimumDismissTimeInterval = 0
        hud.maximumDismissTimeInterval = 0.3
        XCTAssertEqual(hud.displayDuration(for: "Done"), 0.3, accuracy: 0.001, "at most the maximum interval")
        hud.maximumDismissTimeInterval = 10
        XCTAssertEqual(hud.displayDuration(for: "Done"), 0.74, accuracy: 0.001, "0.06 per character plus 0.5")

        hud.maximumDismissTimeInterval = 0.1
        hud.showSuccess(status: "Saved")
        XCTAssertEqual(hud.state, .success)
        XCTAssertEqual(hud.activityCount, 0, "a result ends every activity")
        let gone = expectation(for: NSPredicate(format: "visible == NO"), evaluatedWith: hud, handler: nil)
        wait(for: [gone], timeout: 15)

        hud.showError(status: "Failed")
        XCTAssertEqual(hud.state, .error)
        XCTAssertNotNil(hud.contentView?.imageView.image, "the error image")
        hud.showInfo(status: nil)
        XCTAssertEqual(hud.state, .info)
        XCTAssertTrue((hud.contentView?.textLabel.text ?? "").isEmpty, "no status, no text")
        let image = CYLPlaceholderView.image(for: .warning)!
        hud.show(image: image, status: "Careful")
        XCTAssertEqual(hud.state, .image)
        hud.dismiss()
    }

    func testNotificationsCarryTheStatusAndDismissRunsItsCompletion() {
        let hud = makeHUD()
        var names = [NSNotification.Name]()
        var statuses = [Any]()
        let observers: [NSNotification.Name] = [.CYLPlaceholderHUDWillAppear, .CYLPlaceholderHUDDidAppear,
                                                .CYLPlaceholderHUDWillDisappear, .CYLPlaceholderHUDDidDisappear]
        var tokens = [NSObjectProtocol]()
        for name in observers {
            let token = NotificationCenter.default.addObserver(forName: name, object: hud, queue: nil) { note in
                names.append(note.name)
                statuses.append(note.userInfo?[CYLPlaceholderHUDStatusUserInfoKey] ?? NSNull())
            }
            tokens.append(token)
        }
        hud.show(status: "Syncing")
        var completed = false
        hud.dismiss {
            completed = true
        }
        for token in tokens { NotificationCenter.default.removeObserver(token) }
        XCTAssertTrue(completed)
        XCTAssertEqual(names, observers)
        XCTAssertEqual(statuses.first as? String, "Syncing")
        XCTAssertEqual(statuses.last as? String, "Syncing")
    }

    func testGraceTimeShowsNothingForAQuickTask() {
        let hud = makeHUD()
        hud.graceTimeInterval = 10
        var appeared = 0
        let token = NotificationCenter.default.addObserver(forName: .CYLPlaceholderHUDWillAppear, object: hud,
                                                           queue: nil) { _ in
            appeared += 1
        }
        hud.show()
        XCTAssertTrue(hud.isVisible, "about to show")
        XCTAssertTrue(hud.isHidden, "but not on screen during the grace time")
        hud.dismiss()
        NotificationCenter.default.removeObserver(token)
        XCTAssertFalse(hud.isVisible)
        XCTAssertEqual(appeared, 0)
    }

    func testMasksBlockTouchesAndTheBoxIsLaidOutAtTheOffsetCenter() {
        let hud = makeHUD()
        hud.offsetFromCenter = UIOffset(horizontal: 0, vertical: 40)
        hud.show(status: "Loading")
        hud.layoutIfNeeded()
        XCTAssertEqual(hud.hudView.center.x, container.bounds.midX, accuracy: 0.5)
        XCTAssertEqual(hud.hudView.center.y, container.bounds.midY + 40, accuracy: 0.5)
        XCTAssertGreaterThanOrEqual(hud.hudView.bounds.width, hud.minimumSize.width)
        XCTAssertLessThanOrEqual(hud.hudView.bounds.width, 260)

        let corner = CGPoint(x: 5, y: 5)
        XCTAssertNil(hud.hitTest(corner, with: nil), "no mask: touches reach the views behind")
        XCTAssertFalse(hud.accessibilityViewIsModal)
        hud.maskType = .black
        XCTAssertEqual(hud.hitTest(corner, with: nil), hud, "a mask blocks touches")
        XCTAssertTrue(hud.accessibilityViewIsModal, "and keeps VoiceOver in the box")
        hud.maskType = .clear
        XCTAssertEqual(hud.hitTest(corner, with: nil), hud)
        hud.dismiss()
    }

    func testCustomColorsSelectTheCustomStyle() {
        let hud = makeHUD()
        hud.foregroundColor = .red
        XCTAssertEqual(hud.style, .custom)
        hud.hudBackgroundColor = .darkGray
        hud.show(status: "Loading")
        XCTAssertEqual(hud.contentView?.textLabel.textColor, UIColor.red)
        let box = hud.contentView!
        XCTAssertEqual(box.backgroundColor, UIColor.darkGray,
                       "the CYLPlaceholderView of an icon state is the box: icon and background are one view")
        XCTAssertEqual(box.convert(box.bounds, to: hud).width, hud.hudView.bounds.width, accuracy: 0.5)
        XCTAssertEqual(box.convert(box.bounds, to: hud).midY, hud.hudView.center.y, accuracy: 0.5)
        XCTAssertEqual(box.convert(box.bounds, to: hud).height, hud.hudView.bounds.height, accuracy: 0.5)
        let icon = box.imageView
        XCTAssertEqual(icon.convert(icon.bounds, to: box).midX, box.bounds.midX, accuracy: 0.5,
                       "the icon is centered in the box")
        hud.foregroundColor = nil
        XCTAssertNotNil(hud.foregroundColor, "null_resettable")
        hud.dismiss()
    }

    func testComponentsInTheBoxKeepTheirTapActions() {
        let hud = makeHUD()
        var cancelled = 0
        let cancelAction = CYLPlaceholderAction(rawValue: "cancel")
        let cancel = CYLPlaceholderComponent.button(title: "Cancel", style: .outlined, action: cancelAction)
        var components = CYLPlaceholderScenarioCatalog.components(for: .hud)
        components.append(cancel)
        let handler: CYLPlaceholderActionHandler = { _, _ in
            cancelled += 1
        }
        hud.show(components: components, actions: [cancelAction: handler])
        XCTAssertEqual(hud.state, .custom)
        XCTAssertEqual(hud.placeholderView?.componentViews.count, 2)
        XCTAssertEqual(hud.contentView, hud.placeholderView?.placeholderView)
        XCTAssertTrue(hud.placeholderView?.performAction(cancelAction) ?? false)
        XCTAssertEqual(cancelled, 1)

        hud.show(scenario: .uploading, actions: nil)
        XCTAssertEqual(hud.placeholderView?.componentViews.count, 1)
        hud.dismiss()
        XCTAssertFalse(hud.isVisible)
    }

    func testTheClassMethodsDriveTheSharedHUD() {
        let shared = CYLPlaceholderHUD.shared
        XCTAssertEqual(shared, CYLPlaceholderHUD.shared)
        shared.containerView = container
        shared.fadeInAnimationDuration = 0
        shared.fadeOutAnimationDuration = 0
        CYLPlaceholderHUD.show(status: "Loading")
        XCTAssertTrue(CYLPlaceholderHUD.isVisible())
        XCTAssertEqual(shared.superview, container)
        CYLPlaceholderHUD.dismiss()
        XCTAssertFalse(CYLPlaceholderHUD.isVisible())
        shared.containerView = nil
    }

    func testTheSuccessHUDShowsTheCheckmarkNotTheInfoGlyphWhileTheAnimationFileIsSet() {
        let hud = makeHUD()
        XCTAssertNotNil(CYLPlaceholderView.path(forBundledAnimation: hud.successAnimationFileName ?? ""), "the default success animation is bundled")
        func png(_ image: UIImage?) -> Data? { image?.withRenderingMode(.alwaysOriginal).pngData() }
        hud.showSuccess(status: nil)
        let success = png(hud.contentView?.imageView.image)
        XCTAssertNotNil(success)
        XCTAssertEqual(success, png(hud.successImage), "the static picture under the success animation is the checkmark")
        XCTAssertNotEqual(success, png(hud.infoImage), "not the info glyph")
        hud.showInfo(status: nil)
        XCTAssertEqual(png(hud.contentView?.imageView.image), png(hud.infoImage))
        XCTAssertNotEqual(png(hud.contentView?.imageView.image), png(hud.successImage))
        hud.dismiss()
    }
}
