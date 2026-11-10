//
//  CYLScenarioLocalization.swift
//  Example-Scenarios
//
//  The example layer's lookup "macro". Swift has no function-like macros, so the example's lookup is this function;
//  the core layer's is `CYLPlaceholderLocalizedString` (Objective-C), read here through
//  `CYLPlaceholderLocalization.localizedString(forKey:fallback:)`. The two layers read different bundles:
//
//  - core:    CYLTableViewPlaceHolder.bundle/<language>.lproj/Localizable.strings (scenario titles, hints, buttons)
//  - example: CYLScenarioExample.bundle/<language>.lproj/CYLScenarioExample.strings (tabs, sections, demo text)
//
//  Both follow `CYLPlaceholderLocalization.effectiveLanguage`, so the language button switches both at once.
//

import Foundation
import CYLTableViewPlaceHolder

/// The example table's text in the language the core uses, else English, else the key.
func CYLScenarioLocalizedString(_ key: CYLScenarioL10n) -> String {
    CYLScenarioLocalizationBundle.string(for: key.rawValue)
}

/// A format string of the example table, filled with `arguments`.
func CYLScenarioLocalizedFormat(_ key: CYLScenarioL10n, _ arguments: CVarArg...) -> String {
    String(format: CYLScenarioLocalizedString(key), arguments: arguments)
}

/// Every key of CYLScenarioExample.strings, so code, keys and translations map in one place.
enum CYLScenarioL10n: String, CaseIterable {
    case tabScenarios = "CYLScenarioTabScenarios"
    case tabAnimations = "CYLScenarioTabAnimations"
    case tabFlows = "CYLScenarioSectionFlows"
    case tabFeed = "CYLScenarioTabFeed"
    case sectionReadme = "CYLScenarioSectionReadme"
    case sectionBusiness = "CYLScenarioSectionBusiness"
    case formatReadmeNumbers = "CYLScenarioFormatReadmeNumbers"
    case formatComponents = "CYLScenarioFormatComponents"
    case language = "CYLScenarioLanguage"
    case followSystem = "CYLScenarioFollowSystem"
    case titleSwitchStates = "CYLScenarioTitleSwitchStates"
    case titleKeepTableHeader = "CYLScenarioTitleKeepTableHeader"
    case titleKeepSectionHeaders = "CYLScenarioTitleKeepSectionHeaders"
    case titleRefreshControls = "CYLScenarioTitleRefreshControls"
    case titleScrollable = "CYLScenarioTitleScrollable"
    case titleCollection = "CYLScenarioTitleCollection"
    case actionReplay = "CYLScenarioActionReplay"
    case actionClear = "CYLScenarioActionClear"
    case actionAdd = "CYLScenarioActionAdd"
    case actionSources = "CYLScenarioActionSources"
    case actionPublish = "CYLScenarioActionPublish"
    case feedbackRetry = "CYLScenarioFeedbackRetry"
    case feedbackGoShopping = "CYLScenarioFeedbackGoShopping"
    case supportTitle = "CYLScenarioSupportTitle"
    case supportText = "CYLScenarioSupportText"
    case textNoAnimations = "CYLScenarioTextNoAnimations"
    case textNoticeMissing = "CYLScenarioTextNoticeMissing"
    case textFeedHint = "CYLScenarioTextFeedHint"
    case formatItem = "CYLScenarioFormatItem"
    case formatPost = "CYLScenarioFormatPost"
    case searchPlaceholder = "CYLScenarioSearchPlaceholder"
    case sectionPinned = "CYLScenarioSectionPinned"
    case sectionAll = "CYLScenarioSectionAll"
    case stateEmpty = "CYLScenarioStateEmpty"
    case stateFailed = "CYLScenarioStateFailed"
    case stateOffline = "CYLScenarioStateOffline"
    case stateData = "CYLScenarioStateData"
}

private enum CYLScenarioLocalizationBundle {
    static let table = "CYLScenarioExample"

    private static let container: Bundle? = {
        guard let url = Bundle.main.url(forResource: table, withExtension: "bundle") else {
            NSLog("Example-Scenarios: %@.bundle is missing from the app.", table)
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
