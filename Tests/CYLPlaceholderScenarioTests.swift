//
//  CYLPlaceholderScenarioTests.swift
//  CYLTableViewPlaceHolder tests
//
//  [EN] Scenarios (CYLPlaceholderScenario), the stack of components (CYLPlaceholderStackView), the title chrome of
//       CYLPlaceholderView, and the core localization with its run-time language. Swift since step 13 of
//       docs/Swift-Migration.md (was CYLPlaceholderScenarioTests.m).
//  [CN] 场景（CYLPlaceholderScenario）、组件堆叠（CYLPlaceholderStackView）、CYLPlaceholderView 的标题外观，以及核心本地化与运行时语言。
//       自 docs/Swift-Migration.md 第 13 步起用 Swift 编写（原 CYLPlaceholderScenarioTests.m）。
//

import XCTest
import UIKit

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
 * [EN] Calls `+[CYLPlaceholderComponent componentWithDictionary:error:]`, which takes `id` and is hidden from Swift (Swift
 *      has the typed `init(dictionary:)`), so a value that is not a dictionary can be passed as from Objective-C.
 * [CN] 调用接受 `id`、对 Swift 隐藏的 `+[CYLPlaceholderComponent componentWithDictionary:error:]`（Swift 使用类型化的
 *      `init(dictionary:)`），从而像 Objective-C 一样传入不是字典的值。
 */
private func CYLObjectiveCComponent(_ configuration: AnyObject, _ error: inout NSError?) -> CYLPlaceholderComponent? {
    typealias Factory = @convention(c) (AnyClass, Selector, AnyObject,
                                        AutoreleasingUnsafeMutablePointer<NSError?>?) -> CYLPlaceholderComponent?
    let selector = NSSelectorFromString("componentWithDictionary:error:")
    let factory = unsafeBitCast(class_getMethodImplementation(object_getClass(CYLPlaceholderComponent.self), selector),
                                to: Factory.self)
    var thrown: NSError?
    let component = factory(CYLPlaceholderComponent.self, selector, configuration, &thrown)
    error = thrown
    return component
}

/**
 * [EN] The last path component of an attribute that holds a path. [CN] 保存路径的属性的最后一个路径部分。
 */
private func CYLFileName(_ value: Any?) -> String? {
    ((value as? String) as NSString?)?.lastPathComponent
}

/**
 * [EN] Scenarios (CYLPlaceholderScenario), the stack of components (CYLPlaceholderStackView), the title chrome of
 *      CYLPlaceholderView, and the core localization with its run-time language.
 * [CN] 场景、组件堆叠、CYLPlaceholderView 的标题外观，以及核心本地化与运行时语言。
 */
final class CYLPlaceholderScenarioTests: XCTestCase {

    override func setUp() {
        super.setUp()
        CYLPlaceholderLocalization.language = "en"
    }

    override func tearDown() {
        CYLPlaceholderLocalization.language = nil
        super.tearDown()
    }

    private func windowHosting(_ view: UIView) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        view.frame = window.bounds
        window.addSubview(view)
        window.layoutIfNeeded()
        return window
    }

    private func tap(_ view: CYLPlaceholderView, inStack stack: CYLPlaceholderStackView) {
        XCTAssertTrue(view.isTapInteractive, "a tappable component has its own tap event")
        // [EN] The component's own tap, as a finished touch runs it. [CN] 组件自己的点击，与完成的触摸执行的一样。
        XCTAssertTrue(view.performTap())
    }

    private var allScenarios: [CYLPlaceholderScenario] {
        CYLPlaceholderScenarioCatalog.allScenarios.map { CYLPlaceholderScenario(rawValue: $0.intValue)! }
    }

    // MARK: - Scenarios

    func testEveryScenarioBuildsAllItsComponentsWithTheReservedOneFirst() {
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.allScenarios.count, CYLPlaceholderScenario.count.rawValue)
        for scenario in allScenarios {
            let components = CYLPlaceholderScenarioCatalog.components(for: scenario)
            XCTAssertGreaterThan(components.count, 0, "scenario \(scenario.rawValue)")
            let stack = CYLPlaceholderStackView(scenario: scenario, actions: nil)
            // [EN] Every component's attributes are valid: none is dropped. [CN] 每个组件的属性都有效：没有被丢弃的。
            XCTAssertEqual(stack.componentViews.count, components.count, "scenario \(scenario.rawValue)")
            XCTAssertEqual(stack.stackView.arrangedSubviews.count, components.count)
            XCTAssertEqual(stack.placeholderView, stack.componentViews.first)
            XCTAssertEqual(stack.scenario, scenario)
            XCTAssertTrue(CYLPlaceholderScenarioCatalog.localizedName(for: scenario).count > 0)
            for component in stack.componentViews {
                XCTAssertTrue(component.reportsContentSize, "the stack sizes its components by their content")
            }
        }
    }

    func testEveryReadmeScreenshotMapsToExactlyOneScenario() {
        var numbers = [NSNumber]()
        for scenario in allScenarios {
            numbers.append(contentsOf: CYLPlaceholderScenarioCatalog.readmeScreenshotNumbers(for: scenario))
        }
        XCTAssertEqual(numbers.count, 43, "README has 43 scenario screenshots")
        XCTAssertEqual(Set(numbers).count, 43, "no screenshot is mapped twice")
        for number in 1...43 { XCTAssertTrue(numbers.contains(NSNumber(value: number)), "#\(number)") }
    }

    func testSuccessScenarioStillImageIsTheCheckMark() {
        let icon = CYLPlaceholderScenarioCatalog.components(for: .success)[0]
        let image = icon.attributes[CYLPlaceholderItemImage] as? UIImage
        XCTAssertNotNil(image, "the Success icon has the bundled check mark as its still image")
        XCTAssertEqual(image?.renderingMode, .alwaysTemplate, "tinted like the styles")
        XCTAssertNotEqual(image?.pngData(), CYLPlaceholderView.image(for: .info)?.pngData(), "not the Info icon")
        XCTAssertEqual((icon.attributes[CYLPlaceholderItemStyle] as? NSNumber)?.intValue,
                       CYLPlaceholderStyle.info.rawValue, "Info stays the fallback style")
    }

    func testMostScenariosUseAnAnimatedIcon() {
        var animated = 0
        for scenario in allScenarios {
            for component in CYLPlaceholderScenarioCatalog.components(for: scenario)
            where component.attributes[CYLPlaceholderItemAnimationFilePath] != nil {
                animated += 1
                break
            }
        }
        // [EN] Only the text-only scenario (README #30, #41) has no icon at all.
        // [CN] 只有纯文字场景（README #30、#41）完全没有图标。
        XCTAssertGreaterThan(Double(animated) / Double(CYLPlaceholderScenario.count.rawValue), 0.9)
    }

    func testRetryOrContactSupportStacksFourComponentsWithTwoActions() {
        var performed = [CYLPlaceholderAction]()
        let record: CYLPlaceholderActionHandler = { _, action in
            performed.append(action)
        }
        let stack = CYLPlaceholderStackView(scenario: .retryOrContactSupport,
                                            actions: [.retry: record, .contactSupport: record])
        let window = windowHosting(stack)
        XCTAssertEqual(stack.componentViews.count, 4)
        XCTAssertEqual(stack.componentViews[1].textLabel.text, "Retry")
        XCTAssertTrue(stack.componentViews[2].textLabel.text?.contains("or") ?? false)
        XCTAssertEqual(stack.componentViews[3].textLabel.text, "Contact support")
        XCTAssertEqual(stack.componentView(for: .retry), stack.componentViews[1])
        XCTAssertEqual(stack.componentView(for: .contactSupport), stack.componentViews[3])
        XCTAssertTrue(stack.componentViews[1].accessibilityTraits.contains(.button))
        XCTAssertFalse(stack.componentViews[2].accessibilityTraits.contains(.button), "the separator is not tappable")
        tap(stack.componentViews[1], inStack: stack)
        tap(stack.componentViews[3], inStack: stack)
        XCTAssertEqual(performed, [.retry, .contactSupport])
        // [EN] Components are laid out top to bottom. [CN] 组件从上到下排列。
        for index in 1..<stack.componentViews.count {
            XCTAssertGreaterThanOrEqual(stack.componentViews[index].frame.minY,
                                        stack.componentViews[index - 1].frame.maxY - 0.5)
        }
        window.isHidden = true
    }

    func testIllustrationRetryShowsAnIconThenACapsuleTitleWithABackgroundImage() {
        let stack = CYLPlaceholderStackView(scenario: .illustrationRetry, actions: nil)
        let window = windowHosting(stack)
        XCTAssertEqual(stack.componentViews.count, 2)
        XCTAssertTrue(stack.placeholderView.textLabel.isHidden, "the first component shows only the icon")
        let button = stack.componentViews[1]
        XCTAssertEqual(button.textLabel.text, "Tap to retry")
        XCTAssertTrue(button.itemAttributes[CYLPlaceholderItemTitleBackgroundImage] is UIImage)
        XCTAssertGreaterThan((button.itemAttributes[CYLPlaceholderItemTitleCornerRadius] as? NSNumber)?.doubleValue ?? 0, 100)
        // [EN] The padding around the title makes the button taller than its text.
        // [CN] 标题周围的内边距让按钮比文字更高。
        XCTAssertGreaterThanOrEqual(button.bounds.height, button.textLabel.bounds.height + 20 - 0.5)
        XCTAssertFalse(stack.performAction(.retry), "no handler was given")
        window.isHidden = true
    }

    func testTapAnywhereScenariosHaveABackgroundAction() {
        var retries = 0
        let stack = CYLPlaceholderStackView(scenario: .tapToReload, actions: [.retry: { _, _ in
            retries += 1
        }])
        XCTAssertEqual(stack.backgroundAction, .retry)
        // [EN] The inner CYLAnimatedItemStackView runs the background tap; VoiceOver activation performs the same action.
        // [CN] 内部的 CYLAnimatedItemStackView 执行背景点击；VoiceOver 激活执行同一动作。
        let itemStack = stack.stackView.superview
        var recognizes = false
        for recognizer in itemStack?.gestureRecognizers ?? [] {
            recognizes = recognizes || (recognizer is UITapGestureRecognizer && recognizer.isEnabled)
        }
        XCTAssertTrue(recognizes, "the background tap is recognized by the inner stack")
        XCTAssertTrue(stack.accessibilityActivate())
        XCTAssertEqual(retries, 1)
        XCTAssertTrue(stack.placeholderView.accessibilityTraits.contains(.button))
        stack.backgroundAction = nil
        XCTAssertFalse(stack.placeholderView.accessibilityTraits.contains(.button))
        XCTAssertNil(CYLPlaceholderScenarioCatalog.backgroundAction(for: .retryButton))
    }

    func testCustomComponentsAndHandlersCanBeAddedLater() {
        let reserved = CYLPlaceholderComponent(bundledAnimation: "CYLPlaceholderNoInternet.json", fallbackStyle: .wifiOff,
                                               title: "Offline", size: CGSize(width: 80, height: 80), action: nil)
        let stack = CYLPlaceholderStackView(components: [reserved], actions: nil)
        XCTAssertEqual(stack.scenario, .count)
        XCTAssertEqual(stack.placeholderView.textLabel.text, "Offline")
        let share = CYLPlaceholderAction(rawValue: "Share")
        let button = stack.append(CYLPlaceholderComponent.button(title: "Share", style: .outlined, action: share))
        XCTAssertNotNil(button)
        XCTAssertEqual(stack.componentViews.count, 2)
        var shared = false
        stack.setHandler({ _, _ in shared = true }, for: share)
        if let button = button { tap(button, inStack: stack) }
        XCTAssertTrue(shared)
        XCTAssertNil(stack.append(CYLPlaceholderComponent(attributes: [CYLPlaceholderItemTitleBorderWidth: -1], action: nil)),
                     "invalid attributes are rejected")
        XCTAssertEqual(stack.componentViews.count, 2)
        // [EN] An empty list still gives the reserved component. [CN] 空列表仍然得到保留组件。
        let empty = CYLPlaceholderStackView(components: [], actions: nil)
        XCTAssertNotNil(empty.placeholderView)
        XCTAssertEqual(empty.componentViews.count, 1)
    }

    // MARK: - Title chrome and content size

    func testContentSizeIsOptInAndIncludesTheTitlePadding() {
        let plain = CYLPlaceholderView(style: .empty, message: .empty)
        XCTAssertEqual(plain.intrinsicContentSize.height, UIView.noIntrinsicMetric, "off by default: the view fills its frame")
        let font = UIFont.systemFont(ofSize: 17)
        var error: NSError?
        let button = captureError(&error) {
            try CYLPlaceholderView(itemAttributes: [
                CYLPlaceholderItemTitle: "Retry", CYLPlaceholderItemTitleFont: font,
                CYLPlaceholderItemTitleBackgroundColor: "#007AFF", CYLPlaceholderItemTitleCornerRadius: 6,
                CYLPlaceholderItemTitleContentInsets: [10, 20, 10, 20],
            ], imageBundle: nil)
        }
        XCTAssertNotNil(button, "\(String(describing: error))")
        guard let button = button else { return }
        button.reportsContentSize = true
        let lineHeight = ceil(("Retry" as NSString).boundingRect(with: CGSize(width: 300, height: CGFloat.greatestFiniteMagnitude),
                                                                 options: .usesLineFragmentOrigin, attributes: [.font: font],
                                                                 context: nil).size.height)
        XCTAssertEqual(button.intrinsicContentSize.height, lineHeight + 20, accuracy: 0.5)
        button.frame = CGRect(x: 0, y: 0, width: 300, height: button.intrinsicContentSize.height)
        button.layoutIfNeeded()
        button.subviews.first?.layoutIfNeeded()
        // [EN] The title sits inside its padding. [CN] 标题位于内边距之内。
        XCTAssertEqual(button.convert(button.textLabel.bounds, from: button.textLabel).minY, 10, accuracy: 0.5)
    }

    func testInvalidTitleChromeIsRejected() {
        let invalid: [[String: Any]] = [
            [CYLPlaceholderItemTitle: "A", CYLPlaceholderItemTitleBorderWidth: "thick"],
            [CYLPlaceholderItemTitle: "A", CYLPlaceholderItemTitleCornerRadius: -2],
            [CYLPlaceholderItemTitle: "A", CYLPlaceholderItemTitleContentInsets: [-1, 0, 0, 0]],
            [CYLPlaceholderItemTitle: "A", CYLPlaceholderItemTitleBorderColor: "blue"],
            [CYLPlaceholderItemTitle: "A", CYLPlaceholderItemTitleBackgroundImage: "NoSuchImage"],
        ]
        for attributes in invalid {
            var error: NSError?
            XCTAssertNil(captureError(&error) { try CYLPlaceholderView(itemAttributes: attributes, imageBundle: nil) },
                         "\(attributes)")
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Localization

    func testRunTimeLanguageChangesCoreTexts() {
        XCTAssertEqual(CYLPlaceholderLocalization.effectiveLanguage, "en")
        expectation(forNotification: CYLPlaceholderLocalization.languageDidChangeNotification, object: nil, handler: nil)
        CYLPlaceholderLocalization.language = "zh-Hans"
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(CYLPlaceholderView.localizedText(for: .empty), "暂无内容")
        let stack = CYLPlaceholderStackView(scenario: .retryButton, actions: nil)
        XCTAssertEqual(stack.placeholderView.textLabel.text, "网络不给力，请再试试吧。")
        XCTAssertEqual(stack.componentViews[1].textLabel.text, "重试")
        CYLPlaceholderLocalization.language = "ja"
        // [EN] `CYLPlaceholderLocalizedString(key, fallback)` is an Objective-C macro for this function (the smoke test
        //      calls the macro). [CN] `CYLPlaceholderLocalizedString(key, fallback)` 是该函数的 Objective-C 宏（冒烟测试调用该宏）。
        XCTAssertEqual(CYLPlaceholderLocalizedStringForKey("CYLPlaceholderScenarioRetryButtonTitle", nil),
                       "ネットワークが不安定です。もう一度お試しください。")
        XCTAssertEqual(CYLPlaceholderLocalizedStringForKey("NoSuchKey", "fallback"), "fallback")
        XCTAssertEqual(CYLPlaceholderLocalizedStringForKey("NoSuchKey", nil), "NoSuchKey")
    }

    func testUnsupportedLanguagesFallBack() {
        let expected = ["zh-HK": "zh-Hant", "zh-Hant-TW": "zh-Hant", "zh-CN": "zh-Hans",
                        "ja-JP": "ja", "ko_KR": "ko", "pt-BR": "en", "uk": "uk"]
        for (requested, effective) in expected {
            CYLPlaceholderLocalization.language = requested
            XCTAssertEqual(CYLPlaceholderLocalization.effectiveLanguage, effective, requested)
        }
        CYLPlaceholderLocalization.language = nil
        XCTAssertTrue(CYLPlaceholderLocalization.supportedLanguages.contains(CYLPlaceholderLocalization.effectiveLanguage))
    }

    func testPermissionScenariosAreTheirOwnCategoryAndOfferSettings() {
        // [EN] A missing permission is not a network failure: its own category, an icon of its own, "Open Settings".
        // [CN] 权限缺失不是网络失败：有自己的类别和图标，并提供“去设置”。
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.category(for: .retryButton), .loadFailed)
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.category(for: .noContent), .empty)
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.scenario(for: CYLPlaceholderPermission.none), .noPermission)
        var icons = Set<String>()
        var permissions = 0
        for rawPermission in CYLPlaceholderPermission.location.rawValue...CYLPlaceholderPermission.notifications.rawValue {
            let permission = CYLPlaceholderPermission(rawValue: rawPermission)!
            let scenario = CYLPlaceholderScenarioCatalog.scenario(for: permission)
            XCTAssertNotEqual(scenario, .noPermission, "\(rawPermission)")
            XCTAssertEqual(CYLPlaceholderScenarioCatalog.permission(for: scenario), permission)
            XCTAssertEqual(CYLPlaceholderScenarioCatalog.category(for: scenario), .permission)
            let components = CYLPlaceholderScenarioCatalog.components(for: scenario)
            XCTAssertGreaterThanOrEqual(components.count, 3)
            let path = components.first?.attributes[CYLPlaceholderItemAnimationFilePath] as? String
            XCTAssertTrue(CYLFileName(path)?.hasSuffix("Permission.json") ?? false, "\(String(describing: path))")
            if let name = CYLFileName(path) { icons.insert(name) }
            XCTAssertGreaterThan((components.first?.attributes[CYLPlaceholderItemTitle] as? String)?.count ?? 0, 0)
            XCTAssertGreaterThan((components[1].attributes[CYLPlaceholderItemTitle] as? String)?.count ?? 0, 0)
            XCTAssertEqual(components[2].action, .openSettings)
            permissions += 1
        }
        XCTAssertEqual(permissions, 8)
        XCTAssertEqual(icons.count, 8, "every permission has its own icon: \(icons)")
        // [EN] README #20: location also offers to choose an address by hand.
        // [CN] README #20：定位还提供手动选择地址。
        let location = CYLPlaceholderScenarioCatalog.components(for: .locationPermissionDenied)
        XCTAssertEqual(location.last?.action, .chooseManually)
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.readmeScreenshotNumbers(for: .locationPermissionDenied), [20])
    }

    // MARK: - Tap interaction, playback and configuration files

    func testEachComponentOwnsItsTapEventAndInteractionSwitch() {
        var taps = 0
        let view = CYLPlaceholderView(style: .empty, text: "Tap")
        XCTAssertTrue(view.isTapInteractionEnabled, "enabled by default")
        XCTAssertFalse(view.isTapInteractive, "no handler yet")
        XCTAssertFalse(view.performTap())
        view.tapHandler = { _ in taps += 1 }
        XCTAssertTrue(view.isTapInteractive)
        XCTAssertTrue(view.accessibilityTraits.contains(.button))
        // [EN] A touch down highlights; lifting it outside the slop does not tap. [CN] 按下高亮；在容差外抬起不触发点击。
        view.touchesBegan([], with: nil)
        XCTAssertTrue(view.isTapHighlighted)
        view.touchesCancelled([], with: nil)
        XCTAssertFalse(view.isTapHighlighted)
        XCTAssertTrue(view.performTap())
        XCTAssertEqual(taps, 1)
        // [EN] Interaction off: no handler and no highlight. [CN] 关闭交互：不执行点击事件，也没有高亮。
        view.isTapInteractionEnabled = false
        XCTAssertFalse(view.performTap())
        view.touchesBegan([], with: nil)
        XCTAssertFalse(view.isTapHighlighted)
        // [EN] A disabled button for VoiceOver, as a disabled UIButton. [CN] 对 VoiceOver 而言是禁用的按钮，与禁用的 UIButton 相同。
        XCTAssertTrue(view.accessibilityTraits.contains(.button))
        XCTAssertTrue(view.accessibilityTraits.contains(.notEnabled))
        XCTAssertFalse(view.accessibilityActivate(), "VoiceOver cannot activate it either")
        XCTAssertEqual(taps, 1)
        // [EN] Style None: the tap runs without a highlight. [CN] 无高亮样式：点击照常执行，但不高亮。
        view.isTapInteractionEnabled = true
        XCTAssertFalse(view.accessibilityTraits.contains(.notEnabled))
        view.tapHighlightStyle = .none
        view.touchesBegan([], with: nil)
        XCTAssertFalse(view.isTapHighlighted)
        view.touchesCancelled([], with: nil)
        // [EN] The same switches as item keys. [CN] 同样的开关也可以用 item 键设置。
        let configured = try? CYLPlaceholderView(itemAttributes: [
            CYLPlaceholderItemTitle: "Off", CYLPlaceholderItemInteractionEnabled: false,
            CYLPlaceholderItemTapHighlightStyle: "shrink", CYLPlaceholderItemAnimationRepeatCount: "loop",
        ], imageBundle: nil)
        XCTAssertFalse(configured?.isTapInteractionEnabled ?? true)
        XCTAssertEqual(configured?.tapHighlightStyle, .shrink)
        XCTAssertEqual(configured?.animationRepeatCount, 0)
        var error: NSError?
        XCTAssertNil(captureError(&error) {
            try CYLPlaceholderView(itemAttributes: [CYLPlaceholderItemTapHighlightStyle: "glow"], imageBundle: nil)
        })
        XCTAssertNotNil(error)
        XCTAssertNil(try? CYLPlaceholderView(itemAttributes: [CYLPlaceholderItemAnimationRepeatCount: -1], imageBundle: nil))
    }

    func testDisabledComponentKeepsItsActionButDoesNotRunIt() {
        var retries = 0
        let button = CYLPlaceholderComponent.button(title: "Retry", style: .filled, action: .retry)
        button.interactionEnabled = false
        let stack = CYLPlaceholderStackView(components: [CYLPlaceholderComponent.hint(text: "Offline"), button],
                                            actions: [.retry: { _, _ in
                                                retries += 1
                                            }])
        let view = stack.componentView(for: .retry)
        XCTAssertNotNil(view?.tapHandler, "the stack view sets the component's tap event at init")
        XCTAssertFalse(view?.isTapInteractive ?? true)
        XCTAssertFalse(view?.performTap() ?? true)
        view?.isTapInteractionEnabled = true
        XCTAssertTrue(view?.performTap() ?? false)
        XCTAssertEqual(retries, 1)
    }

    func testScenarioIconsPlayOnceByDefaultAndSpinnersLoop() {
        let spinnerWords = ["Loading", "Spinner", "Progress", "Throbber", "Activity", "Ring",
                            "Dots", "Cycle", "Arc", "Clockwise", "Uploading", "Infinity"]
        var once = 0
        for value in CYLPlaceholderScenarioCatalog.allScenarios {
            let scenario = CYLPlaceholderScenario(rawValue: value.intValue)!
            for component in CYLPlaceholderScenarioCatalog.components(for: scenario) {
                guard let file = CYLFileName(component.attributes[CYLPlaceholderItemAnimationFilePath]) else { continue }
                var spinner = false
                for word in spinnerWords { spinner = spinner || file.contains(word) }
                XCTAssertEqual(component.animationRepeatCount, spinner ? 0 : 1, "scenario \(value), \(file)")
                if !spinner { once += 1 }
            }
        }
        XCTAssertGreaterThan(once, 0, "most scenario icons play once")
        let stack = CYLPlaceholderStackView(scenario: .loading, actions: nil)
        XCTAssertEqual(stack.placeholderView.animationRepeatCount, 0)
        stack.placeholderView.animationRepeatCount = 2
        XCTAssertEqual(stack.placeholderView.animationRepeatCount, 2)
        XCTAssertEqual(CYLPlaceholderComponent.hint(text: "x").animationRepeatCount, 1)
    }

    func testEveryScenarioListsBundledAnimationsInEveryFormat() {
        var formats = Set<String>()
        for value in CYLPlaceholderScenarioCatalog.allScenarios {
            let scenario = CYLPlaceholderScenario(rawValue: value.intValue)!
            let names = CYLPlaceholderScenarioCatalog.animationFileNames(for: scenario)
            if scenario == .textOnly {
                XCTAssertEqual(names.count, 0, "the text-only scenario has no icon")
                continue
            }
            XCTAssertGreaterThan(names.count, 0, "scenario \(value)")
            for name in names {
                XCTAssertNotNil(CYLPlaceholderView.path(forBundledAnimation: name), name)
                formats.insert((name as NSString).pathExtension)
            }
        }
        XCTAssertEqual(formats, ["json", "pag", "riv", "gif"])
    }

    func testScenarioNamesRoundTrip() {
        for scenario in allScenarios {
            let name = CYLPlaceholderScenarioCatalog.name(for: scenario)
            XCTAssertGreaterThan(name.count, 0)
            XCTAssertEqual(CYLPlaceholderScenarioCatalog.scenario(named: name), scenario)
            let swift = name.prefix(1).lowercased() + name.dropFirst()
            XCTAssertEqual(CYLPlaceholderScenarioCatalog.scenario(named: swift), scenario)
            XCTAssertEqual(CYLPlaceholderScenarioCatalog.scenario(named: "CYLPlaceholderScenario" + name), scenario)
        }
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.scenario(named: "Nope"), .count)
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.action(named: "contactSupport"), .contactSupport)
        XCTAssertEqual(CYLPlaceholderScenarioCatalog.action(named: "share"), CYLPlaceholderAction(rawValue: "share"))
    }

    func testConfigurationBuildsComponentsWithEveryOption() {
        var performed = [CYLPlaceholderAction]()
        let record: CYLPlaceholderActionHandler = { _, action in
            performed.append(action)
        }
        let configuration: [String: Any] = [
            "backgroundAction": "",
            "components": [
                ["type": "icon", "animation": "CYLPlaceholderNoInternet.json", "style": "WifiOff",
                 "titleKey": "CYLPlaceholderScenarioRetryButtonTitle", "size": [80, 80], "repeatCount": "once"],
                ["type": "hint", "text": "Literal hint"],
                ["type": "button", "action": "retry", "buttonStyle": "filled", "highlightStyle": "shrink"],
                ["type": "separator"],
                ["type": "button", "action": "contactSupport", "buttonStyle": "outlined", "interactionEnabled": false],
                ["type": "item", "attributes": [CYLPlaceholderItemTitle: "Raw item"], "action": "share",
                 "accessibilityIdentifier": "rawItem", "spacingBefore": 30],
            ] as [[String: Any]],
        ]
        var error: NSError?
        let stack = captureError(&error) {
            try CYLPlaceholderStackView(configuration: configuration,
                                        actions: [.retry: record, .contactSupport: record,
                                                  CYLPlaceholderAction(rawValue: "share"): record])
        }
        XCTAssertNotNil(stack, "\(String(describing: error))")
        guard let stack = stack else { return }
        XCTAssertEqual(stack.componentViews.count, 6)
        XCTAssertEqual(stack.placeholderView.textLabel.text, "The network is slow. Please try again.",
                       "titleKey reads the core localization")
        XCTAssertEqual(stack.placeholderView.animationRepeatCount, 1)
        XCTAssertEqual(stack.componentViews[1].textLabel.text, "Literal hint")
        XCTAssertEqual(stack.componentViews[2].textLabel.text, "Retry", "a button without a title uses its action's")
        XCTAssertEqual(stack.componentViews[2].tapHighlightStyle, .shrink)
        XCTAssertFalse(stack.componentViews[4].isTapInteractive)
        XCTAssertEqual(stack.componentViews[5].accessibilityIdentifier, "rawItem")
        XCTAssertNil(stack.backgroundAction)
        tap(stack.componentViews[2], inStack: stack)
        XCTAssertFalse(stack.componentViews[4].performTap())
        tap(stack.componentViews[5], inStack: stack)
        XCTAssertEqual(performed, [.retry, CYLPlaceholderAction(rawValue: "share")])
    }

    func testConfigurationStartsFromAScenarioWithOverridesAndReadsFiles() {
        let configuration: [String: Any] = [
            "scenario": "retryOrContactSupport",
            "overrides": [["index": 3, "interactionEnabled": false], ["index": 0, "repeatCount": 2]],
        ]
        let stack = try? CYLPlaceholderStackView(configuration: configuration, actions: nil)
        XCTAssertEqual(stack?.scenario, .retryOrContactSupport)
        XCTAssertEqual(stack?.componentViews.count, 4)
        XCTAssertFalse(stack?.componentViews[3].isTapInteractionEnabled ?? true)
        XCTAssertEqual(stack?.placeholderView.animationRepeatCount, 2)
        // [EN] The catalog's components are copied, not changed. [CN] 目录中的组件被复制，而不是被修改。
        XCTAssertTrue(CYLPlaceholderScenarioCatalog.components(for: .retryOrContactSupport)[3].interactionEnabled)
        let directory = NSTemporaryDirectory()
        let json = URL(fileURLWithPath: (directory as NSString).appendingPathComponent("CYLScenarioConfig.json"))
        try? JSONSerialization.data(withJSONObject: ["scenario": "TapToReload"], options: []).write(to: json, options: .atomic)
        let fromJSON = try? CYLPlaceholderStackView(contentsOf: json, actions: nil)
        XCTAssertEqual(fromJSON?.scenario, .tapToReload)
        XCTAssertEqual(fromJSON?.backgroundAction, .retry, "the scenario's background action")
        let plist = URL(fileURLWithPath: (directory as NSString).appendingPathComponent("CYLScenarioConfig.plist"))
        (["components": [["type": "hint", "text": "plist"]]] as NSDictionary).write(to: plist, atomically: true)
        let fromPlist = try? CYLPlaceholderStackView(contentsOf: plist, actions: nil)
        XCTAssertEqual(fromPlist?.placeholderView.textLabel.text, "plist")
        let invalidConfigurations: [[String: Any]] = [
            [:], ["scenario": "Nope"], ["components": [] as [Any]],
            ["components": [["type": "button"]]],
            ["components": [["type": "icon", "animation": "Missing.json"]]],
            ["scenario": "TextOnly", "overrides": [["index": 9]]],
            ["components": [["type": "hint", "highlightStyle": "glow"]]],
        ]
        for invalid in invalidConfigurations {
            var error: NSError?
            XCTAssertNil(captureError(&error) { try CYLPlaceholderStackView(configuration: invalid, actions: nil) }, "\(invalid)")
            XCTAssertNotNil(error, "\(invalid)")
        }
    }

    func testComponentDictionariesAreCheckedAndComponentsCopy() {
        // [EN] `+componentWithDictionary:error:` takes `id` (a configuration read from JSON): anything but a dictionary returns
        //      nil and the component error, as the Objective-C implementation did (CYLPlaceholderComponent is Swift since
        //      2026-11-19). Swift's `init(dictionary:)` takes only dictionaries, so the Objective-C entry point is called by
        //      its selector (the smoke test calls it from Objective-C too). A copy keeps the attributes, action, spacing,
        //      bundle and the kind the stack view reads.
        // [CN] `+componentWithDictionary:error:` 接受 `id`（从 JSON 读取的配置）：不是字典时返回 nil 与组件错误，与原 Objective-C 实现一致
        //      （CYLPlaceholderComponent 自 2026-11-19 起用 Swift 编写）。Swift 的 `init(dictionary:)` 只接受字典，因此按选择器调用
        //      Objective-C 入口（冒烟测试也从 Objective-C 调用）。副本保留属性、动作、间距、bundle 以及堆叠视图读取的种类。
        let configurations: [AnyObject] = [[["type": "hint"]] as NSArray, "hint" as NSString]
        for configuration in configurations {
            var error: NSError?
            XCTAssertNil(CYLObjectiveCComponent(configuration, &error), "\(configuration)")
            XCTAssertEqual(error?.domain, CYLPlaceholderConfigurationErrorDomain)
            XCTAssertEqual(error?.code, CYLPlaceholderConfigurationError.Code.component.rawValue)
            XCTAssertEqual(error?.localizedDescription, "A component must be a dictionary.")
        }
        var error: NSError?
        XCTAssertNil(captureError(&error) { try CYLPlaceholderComponent(dictionary: ["type": "banner"]) })
        XCTAssertEqual(error?.localizedDescription, "Unknown component type banner.")
        let missingAnimation: [String: Any] = ["type": "icon", "animation": "Missing.json"]
        XCTAssertNil(captureError(&error) { try CYLPlaceholderComponent(dictionary: missingAnimation) })
        XCTAssertEqual(error?.localizedDescription, "Bundled animation Missing.json was not found.")

        let button = captureError(&error) {
            try CYLPlaceholderComponent(dictionary: [
                "type": "button", "action": "retry", "spacingBefore": 30, "repeatCount": "loop"])
        }
        XCTAssertEqual(button?.action, .retry, "\(String(describing: error))")
        XCTAssertEqual(button?.attributes[CYLPlaceholderItemTitle] as? String,
                       CYLPlaceholderScenarioCatalog.localizedTitle(for: .retry))
        XCTAssertEqual(button?.animationRepeatCount, 0)
        guard let button = button else { return }
        button.imageBundle = Bundle(for: type(of: self))
        let copy = button.copy() as! CYLPlaceholderComponent
        XCTAssertFalse(copy === button)
        XCTAssertEqual(copy.attributes as NSDictionary, button.attributes as NSDictionary)
        XCTAssertEqual(copy.action, button.action)
        XCTAssertEqual(copy.imageBundle, button.imageBundle)
        XCTAssertEqual(copy.spacingBefore, 30, accuracy: 0.001)
        let stack = CYLPlaceholderStackView(components: [
            CYLPlaceholderComponent(attributes: [CYLPlaceholderItemTitle: "Title"], action: nil), copy], actions: nil)
        XCTAssertNotNil(stack.button, "the copy is still a button")
    }

    // MARK: - Layout

    func testComponentsAreCenteredWithTheirTitlesVisible() {
        // [EN] The Animations detail page: one component with an icon and a title in a phone-sized stack view.
        // [CN] 动效详情页：手机尺寸的堆叠视图中一个带图标和标题的组件。
        let stack = CYLPlaceholderStackView(components: [
            CYLPlaceholderComponent(bundledAnimation: "CYLPlaceholderSuccess.json", fallbackStyle: .image, title: "Success",
                                    size: CGSize(width: 180, height: 180), action: nil)], actions: nil)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        stack.frame = window.bounds
        window.addSubview(stack)
        stack.setNeedsLayout()
        stack.layoutIfNeeded()
        let component = stack.placeholderView
        let frame = component.convert(component.bounds, to: stack)
        XCTAssertGreaterThanOrEqual(frame.width, 180, "the component is at least as wide as its icon")
        XCTAssertEqual(frame.midX, 201, accuracy: 1, "centered horizontally")
        let title = component.textLabel.convert(component.textLabel.bounds, to: stack)
        XCTAssertFalse(component.textLabel.isHidden)
        XCTAssertGreaterThan(title.height, 0, "the title has room")
        XCTAssertTrue(frame.insetBy(dx: -1, dy: -1).contains(title), "the title is inside the component")
        stack.removeFromSuperview()
    }

    // MARK: - Accessibility and resources

    func testComponentsSpeakTextAndControlsAndHideDecorations() {
        CYLPlaceholderLocalization.language = "ja"
        let stack = CYLPlaceholderStackView(scenario: .illustrationRetry, actions: [.retry: { _, _ in }])
        XCTAssertTrue(stack.shouldGroupAccessibilityChildren)
        // [EN] The illustration has no text or action: decorative. [CN] 插图没有文字也没有动作：装饰性内容。
        XCTAssertFalse(stack.placeholderView.isAccessibilityElement)
        XCTAssertTrue(stack.placeholderView.accessibilityElementsHidden)
        let button = stack.componentViews[1]
        XCTAssertTrue(button.isAccessibilityElement)
        XCTAssertTrue(button.accessibilityTraits.contains(.button))
        XCTAssertGreaterThan(button.accessibilityLabel?.count ?? 0, 0)
        XCTAssertEqual(button.accessibilityLanguage, "ja", "VoiceOver pronounces the chosen language")
        // [EN] The separator reads only its word. [CN] 分隔符只朗读文字。
        CYLPlaceholderLocalization.language = "en"
        let support = CYLPlaceholderStackView(scenario: .retryOrContactSupport, actions: nil)
        XCTAssertEqual(support.componentViews[2].accessibilityLabel, "or")
        // [EN] A tap-anywhere scenario's reserved component is a button even without a title.
        // [CN] “点击屏幕重试”场景的保留组件即使没有标题也是按钮。
        let reload = CYLPlaceholderStackView(components: [
            CYLPlaceholderComponent(bundledAnimation: "CYLPlaceholderRefresh.json", fallbackStyle: .refresh, title: nil,
                                    size: CGSize(width: 64, height: 64), action: nil)], actions: nil)
        XCTAssertTrue(reload.placeholderView.accessibilityElementsHidden)
        reload.backgroundAction = .retry
        XCTAssertFalse(reload.placeholderView.accessibilityElementsHidden)
        XCTAssertEqual(reload.placeholderView.accessibilityLabel, "Retry")
        XCTAssertTrue(reload.placeholderView.accessibilityTraits.contains(.button))
    }

    func testCoreResourceLookupReadsOnlyTheCoreBundle() {
        let bundle = CYLPlaceholderResourceBundle()
        XCTAssertNotNil(bundle)
        XCTAssertEqual(bundle?.bundleURL.lastPathComponent, "CYLTableViewPlaceHolder.bundle")
        // [EN] `CYLPlaceholderResourceURL(path)` is an Objective-C macro for this function (the smoke test calls the macro).
        // [CN] `CYLPlaceholderResourceURL(path)` 是该函数的 Objective-C 宏（冒烟测试调用该宏）。
        let animation = CYLPlaceholderResourceURLForPath("Animations/CYLPlaceholderLoading.json")
        XCTAssertNotNil(animation)
        XCTAssertEqual(animation?.path, CYLPlaceholderView.path(forBundledAnimation: "CYLPlaceholderLoading.json"))
        XCTAssertNotNil(CYLPlaceholderResourceURLForPath("en.lproj/Localizable.strings"))
        XCTAssertNil(CYLPlaceholderResourceURLForPath("Animations/Missing.json"))
        XCTAssertNil(CYLPlaceholderResourceURLForPath("../Info.plist"), "a path may not leave the bundle")
        XCTAssertNil(CYLPlaceholderResourceURLForPath("CYLPlaceholderItemDemo.plist"), "example data is not in the core bundle")
    }

    func testEveryScenarioIsTranslated() {
        var english = [String]()
        for scenario in allScenarios {
            for component in CYLPlaceholderScenarioCatalog.components(for: scenario) {
                english.append(component.attributes[CYLPlaceholderItemTitle] as? String ?? "")
            }
            english.append(CYLPlaceholderScenarioCatalog.localizedName(for: scenario))
        }
        for language in ["zh-Hans", "zh-Hant", "ja", "ko", "ru", "uk"] {
            CYLPlaceholderLocalization.language = language
            var index = 0
            for scenario in allScenarios {
                for component in CYLPlaceholderScenarioCatalog.components(for: scenario) {
                    let text = component.attributes[CYLPlaceholderItemTitle] as? String ?? ""
                    if !text.isEmpty { XCTAssertNotEqual(text, english[index], "\(english[index]) in \(language)") }
                    index += 1
                }
                XCTAssertNotEqual(CYLPlaceholderScenarioCatalog.localizedName(for: scenario), english[index],
                                  "\(english[index]) in \(language)")
                index += 1
            }
        }
    }
}
