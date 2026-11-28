//
//  CYLObjC02Localization.swift
//  Example-objc-02
//
//  The example layer's lookup "macro" (Swift has no function-like macros). It reads only
//  CYLObjC02Example.bundle/<language>.lproj/CYLObjC02Example.strings; the refresh controls' own text
//  ("Pull down to refresh") comes from the core bundle through the core lookup. Both follow
//  `CYLPlaceholderLocalization.effectiveLanguage`. The UI tests run in English and match the English values.
//

import Foundation
import UIKit
import CYLTableViewPlaceHolder

/// The example table's text in the language the core uses, else English, else the key.
func CYLObjC02LocalizedString(_ key: CYLObjC02L10n) -> String {
    CYLObjC02LocalizationBundle.string(for: key.rawValue)
}

/// A format string of the example table, filled with `arguments`.
func CYLObjC02LocalizedFormat(_ key: CYLObjC02L10n, _ arguments: CVarArg...) -> String {
    String(format: CYLObjC02LocalizedString(key), arguments: arguments)
}

/// Every key of CYLObjC02Example.strings, so code, keys and translations map in one place.
enum CYLObjC02L10n: String, CaseIterable {
    case titleCollection = "CYLObjC02TitleCollection"
    case titleHeaderRefreshing = "CYLObjC02TitleHeaderRefreshing"
    case formatHeaderCompleted = "CYLObjC02FormatHeaderCompleted"
    case titleFooterRefreshing = "CYLObjC02TitleFooterRefreshing"
    case titleFooterCompleted = "CYLObjC02TitleFooterCompleted"
    case formatItem = "CYLObjC02FormatItem"
    case titlePaging = "CYLObjC02TitlePaging"
    case titleRefreshCompleted = "CYLObjC02TitleRefreshCompleted"
    case titleLoadCompleted = "CYLObjC02TitleLoadCompleted"
    case actionRefresh = "CYLObjC02ActionRefresh"
    case actionLastPage = "CYLObjC02ActionLastPage"
    case hintRefresh = "CYLObjC02HintRefresh"
    case hintLastPage = "CYLObjC02HintLastPage"
    case formatPage = "CYLObjC02FormatPage"
    case titleSections = "CYLObjC02TitleSections"
    case formatSection = "CYLObjC02FormatSection"
    case hintRefreshSections = "CYLObjC02HintRefreshSections"
}

private enum CYLObjC02LocalizationBundle {
    static let table = "CYLObjC02Example"

    static let container: Bundle? = {
        guard let url = Bundle.main.url(forResource: table, withExtension: "bundle") else {
            NSLog("Example-objc-02: %@.bundle is missing from the app.", table)
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
/// `CYLPlaceholderLocalization.effectiveLanguage` follows, and that every `CYLObjC02L10n` key resolves through
/// `CYLObjC02LocalizedString` to that language's own table value, read straight from its `.lproj` (so a key missing
/// in one language, or a lookup that ignores the language switch, is reported). An unknown language must fall back to
/// English. The core language is restored afterwards. Returns the number of lookups and the problems found.
func CYLObjC02LocalizationSelfCheck() -> (lookups: Int, problems: [String]) {
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
        let table = CYLObjC02LocalizationBundle.tableEntries(language: expected)
        if table.isEmpty {
            problems.append("\(expected).lproj/\(CYLObjC02LocalizationBundle.table).strings is missing or empty")
            continue
        }
        for key in CYLObjC02L10n.allCases {
            lookups += 1
            let value = CYLObjC02LocalizedString(key)
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
/// `CYLObjC02LocalizationSelfCheck()`, prints `CYL_LOCALIZATION_CHECK PASS <lookups>` (or `FAIL` and each problem) for
/// `xcrun simctl launch --console`, shows the result in a label (accessibility identifier `CYLLocalizationCheckResult`)
/// for UI tests, and with `-exitAfterLocalizationCheck` exits with status 0 or 1 once printed.
final class CYLObjC02LocalizationCheckViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let result = CYLObjC02LocalizationSelfCheck()
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
