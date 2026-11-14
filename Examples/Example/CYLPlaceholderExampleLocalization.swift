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

    static func string(for key: String) -> String {
        let english = languageBundle("en")?.localizedString(forKey: key, value: key, table: table) ?? key
        let preferred = languageBundle(CYLPlaceholderLocalization.effectiveLanguage)
        return preferred?.localizedString(forKey: key, value: english, table: table) ?? english
    }
}
