import XCTest

/// The example layer's localization: the app checks its own table from inside (`-localizationCheck`, see
/// `CYLObjC02LocalizationSelfCheck()` in CYLObjC02Localization.swift). For every language the core supports, every
/// `CYLObjC02L10n` key must resolve through `CYLObjC02LocalizedString` to that language's value once
/// `CYLPlaceholderLocalization.language` is switched, and an unknown language must fall back to English.
final class CYLLocalizationUITests: XCTestCase {
    @MainActor
    func testEveryExampleKeyResolvesInEveryCoreLanguage() {
        let app = XCUIApplication()
        app.launchArguments.append("-localizationCheck")
        app.launch()
        let result = app.staticTexts["CYLLocalizationCheckResult"]
        XCTAssertTrue(result.waitForExistence(timeout: 10))
        let label = result.label
        XCTAssertTrue(label.hasPrefix("CYL_LOCALIZATION_CHECK PASS "), label)
        let lookups = Int(label.split(separator: "\n")[0].split(separator: " ").last ?? "") ?? 0
        // [EN] 7 core languages plus one unknown language, every key each time. [CN] 7 种核心语言加一种未知语言，每次检查所有键。
        XCTAssertGreaterThan(lookups, 0, label)
        XCTAssertEqual(lookups % 8, 0, label)
    }
}
