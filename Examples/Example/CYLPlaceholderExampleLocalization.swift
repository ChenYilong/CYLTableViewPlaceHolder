//
//  CYLPlaceholderExampleLocalization.swift
//  CYLTableViewPlaceHolder (main example app)
//
//  [EN] The example layer's lookup "macro". Swift has no function-like macros, so the example's lookup is this
//  function; the core layer's is `CYLPlaceholderLocalizedString` (Objective-C). The two layers read different bundles:
//
//  - core:    CYLTableViewPlaceHolder.bundle/<language>.lproj/Localizable.strings (placeholder messages)
//  - example: CYLPlaceholderExample.bundle/<language>.lproj/CYLPlaceholderExample.strings (demo screens and buttons)
//
//  Both follow `CYLPlaceholderLocalization.effectiveLanguage`. Resources follow the same split:
//  `CYLPlaceholderExampleResourceURL(_:)` below reads only CYLPlaceholderExample.bundle (the property-list item demo).
//  [CN] 示例层的查找“宏”。Swift 不能使用函数式宏，因此示例层用本函数查找；核心层使用 `CYLPlaceholderLocalizedString`。
//  两层读取不同的 bundle，并都跟随 `CYLPlaceholderLocalization.effectiveLanguage`。资源查找同样分层。
//

import Foundation
import UIKit
import CYLTableViewPlaceHolder

/// The example table's text in the language the core uses, else English, else the key.
func CYLPlaceholderExampleLocalizedString(_ key: CYLPlaceholderExampleL10n) -> String {
    CYLPlaceholderExampleLocalizationBundle.string(for: key.rawValue)
}

/// A format string of the example table (`%ld`, `%@`), filled with `arguments` in the current locale.
func CYLPlaceholderExampleLocalizedFormat(_ key: CYLPlaceholderExampleL10n, _ arguments: CVarArg...) -> String {
    String(format: CYLPlaceholderExampleLocalizedString(key), locale: Locale.current, arguments: arguments)
}

/// The example's own resource bundle, CYLPlaceholderExample.bundle; nil, with a log, when it is missing.
func CYLPlaceholderExampleBundle() -> Bundle? {
    CYLPlaceholderExampleLocalizationBundle.container
}

/// A file of the example bundle by its path inside it, such as "CYLPlaceholderItemDemo.plist"; nil when it does not
/// exist or the path leaves the bundle.
func CYLPlaceholderExampleResourceURL(_ path: String) -> URL? {
    guard let bundle = CYLPlaceholderExampleBundle(), !path.hasPrefix("/"), !path.contains("..") else { return nil }
    let url = bundle.bundleURL.appendingPathComponent(path)
    return FileManager.default.fileExists(atPath: url.path) ? url : nil
}

/// Every key of CYLPlaceholderExample.strings, so code, keys and translations map in one place.
enum CYLPlaceholderExampleL10n: String, CaseIterable {
    // Main screen (refresh and the two custom placeholders, issues #2, #3, #6)
    case actionAuto = "CYLPlaceholderExampleActionAuto"
    case formatRandomData = "CYLPlaceholderExampleFormatRandomData"
    case netReloaderMessage = "CYLPlaceholderExampleNetReloaderMessage"
    case netReloaderReload = "CYLPlaceholderExampleNetReloaderReload"
    case weChatEmptyMessage = "CYLPlaceholderExampleWeChatEmptyMessage"
    // Automatic placeholder screen (issue #11)
    case titleAutomatic = "CYLPlaceholderExampleTitleAutomatic"
    case modeLabel = "CYLPlaceholderExampleModeLabel"
    case modeTable = "CYLPlaceholderExampleModeTable"
    case modeCollection = "CYLPlaceholderExampleModeCollection"
    case actionStyles = "CYLPlaceholderExampleActionStyles"
    case actionClear = "CYLPlaceholderExampleActionClear"
    case actionDisable = "CYLPlaceholderExampleActionDisable"
    case actionEnable = "CYLPlaceholderExampleActionEnable"
    case formatItem = "CYLPlaceholderExampleFormatItem"
    // Styles, FlatDesign items and badges
    case titleStyles = "CYLPlaceholderExampleTitleStyles"
    case styleCustomImage = "CYLPlaceholderExampleStyleCustomImage"
    case styleFlatDesignCode = "CYLPlaceholderExampleStyleFlatDesignCode"
    case styleFlatDesignPlist = "CYLPlaceholderExampleStyleFlatDesignPlist"
    case styleBadgeDot = "CYLPlaceholderExampleStyleBadgeDot"
    case styleBadgeNumber = "CYLPlaceholderExampleStyleBadgeNumber"
    case styleBadgeText = "CYLPlaceholderExampleStyleBadgeText"
    case badgeNew = "CYLPlaceholderExampleBadgeNew"
    case titleBadgePreview = "CYLPlaceholderExampleTitleBadgePreview"
    case titleFlatDesignItem = "CYLPlaceholderExampleTitleFlatDesignItem"
    case titleConfigurationError = "CYLPlaceholderExampleTitleConfigurationError"
    case formatMissingFile = "CYLPlaceholderExampleFormatMissingFile"
    case actionOK = "CYLPlaceholderExampleActionOK"
    // Messages and previews
    case titleChooseMessage = "CYLPlaceholderExampleTitleChooseMessage"
    case customText = "CYLPlaceholderExampleCustomText"
    case customTextPlaceholder = "CYLPlaceholderExampleCustomTextPlaceholder"
    case actionCancel = "CYLPlaceholderExampleActionCancel"
    case actionPreview = "CYLPlaceholderExampleActionPreview"
}

private enum CYLPlaceholderExampleLocalizationBundle {
    static let table = "CYLPlaceholderExample"

    static let container: Bundle? = {
        guard let url = Bundle.main.url(forResource: table, withExtension: "bundle") else {
            NSLog("CYLTableViewPlaceHolder example: %@.bundle is missing from the app.", table)
            return nil
        }
        return Bundle(url: url)
    }()

    private static func languageBundle(_ language: String) -> Bundle? {
        container?.path(forResource: language, ofType: "lproj").flatMap(Bundle.init(path:))
    }

    /// Every entry of one language's table, read from that `.lproj` alone; empty when it is missing.
    static func tableEntries(language: String) -> [String: String] {
        guard let path = languageBundle(language)?.path(forResource: table, ofType: "strings") else { return [:] }
        return NSDictionary(contentsOfFile: path) as? [String: String] ?? [:]
    }

    static func string(for key: String) -> String {
        let english = languageBundle("en")?.localizedString(forKey: key, value: key, table: table) ?? key
        let preferred = languageBundle(CYLPlaceholderLocalization.effectiveLanguage)
        return preferred?.localizedString(forKey: key, value: english, table: table) ?? english
    }
}

// MARK: - Localization self-check

/// Checks this example's lookup in every core language, from inside the app (the bundle is the app's):
/// for each language of `CYLPlaceholderLocalization.supportedLanguages` it sets the core language, checks that
/// `CYLPlaceholderLocalization.effectiveLanguage` follows, and that every `CYLPlaceholderExampleL10n` key resolves through
/// `CYLPlaceholderExampleLocalizedString` to that language's own table value, read straight from its `.lproj` (so a key missing
/// in one language, or a lookup that ignores the language switch, is reported). An unknown language must fall back to
/// English. The core language is restored afterwards. Returns the number of lookups and the problems found.
func CYLPlaceholderExampleLocalizationSelfCheck() -> (lookups: Int, problems: [String]) {
    let saved = CYLPlaceholderLocalization.language
    defer { CYLPlaceholderLocalization.language = saved }
    var problems: [String] = []
    var lookups = 0
    let languages = CYLPlaceholderLocalization.supportedLanguages
    for language in languages + ["xx"] {
        CYLPlaceholderLocalization.language = language
        let expected = languages.contains(language) ? language : "en"
        if CYLPlaceholderLocalization.effectiveLanguage != expected {
            problems.append("\(language): effectiveLanguage is \(CYLPlaceholderLocalization.effectiveLanguage), not \(expected)")
            continue
        }
        let table = CYLPlaceholderExampleLocalizationBundle.tableEntries(language: expected)
        if table.isEmpty {
            problems.append("\(expected).lproj/\(CYLPlaceholderExampleLocalizationBundle.table).strings is missing or empty")
            continue
        }
        for key in CYLPlaceholderExampleL10n.allCases {
            lookups += 1
            let value = CYLPlaceholderExampleLocalizedString(key)
            guard let translation = table[key.rawValue] else {
                problems.append("\(expected): no value for \(key.rawValue)")
                continue
            }
            if value != translation || value == key.rawValue {
                problems.append("\(language): \(key.rawValue) resolved to \"\(value)\", the table has \"\(translation)\"")
            }
        }
    }
    return (lookups, problems)
}

/// Shown instead of the demo when the app starts with `-localizationCheck`: runs
/// `CYLPlaceholderExampleLocalizationSelfCheck()`, prints `CYL_LOCALIZATION_CHECK PASS <lookups>` (or `FAIL` and each problem) for
/// `xcrun simctl launch --console`, shows the result in a label (accessibility identifier `CYLLocalizationCheckResult`)
/// for UI tests, and with `-exitAfterLocalizationCheck` exits with status 0 or 1 once printed.
final class CYLPlaceholderExampleLocalizationCheckViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let result = CYLPlaceholderExampleLocalizationSelfCheck()
        let passed = result.problems.isEmpty && result.lookups > 0
        let summary = "CYL_LOCALIZATION_CHECK \(passed ? "PASS" : "FAIL") \(result.lookups)"
        print(([summary] + result.problems).joined(separator: "\n"))
        fflush(stdout)
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ([summary] + result.problems.prefix(20)).joined(separator: "\n")
        label.accessibilityIdentifier = "CYLLocalizationCheckResult"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        if ProcessInfo.processInfo.arguments.contains("-exitAfterLocalizationCheck") {
            exit(passed ? 0 : 1)
        }
    }
}
