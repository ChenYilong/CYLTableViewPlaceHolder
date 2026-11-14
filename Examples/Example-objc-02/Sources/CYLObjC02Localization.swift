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

    static func string(for key: String) -> String {
        let english = languageBundle("en")?.localizedString(forKey: key, value: key, table: table) ?? key
        let preferred = languageBundle(CYLPlaceholderLocalization.effectiveLanguage)
        return preferred?.localizedString(forKey: key, value: english, table: table) ?? english
    }
}
