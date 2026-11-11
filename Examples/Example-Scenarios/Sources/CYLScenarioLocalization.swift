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
//  Resources follow the same split: the core's `CYLPlaceholderResourceURL(path)` (Swift:
//  `CYLPlaceholderResourceURLForPath(_:)`) reads only the core bundle; `CYLScenarioExampleResourceURL(_:)` below reads
//  only CYLScenarioExample.bundle (configuration files, the example's own animations).
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

/// The example's own resource bundle, CYLScenarioExample.bundle; nil, with a log, when it is missing.
func CYLScenarioExampleBundle() -> Bundle? {
    CYLScenarioLocalizationBundle.container
}

/// A file or folder of the example bundle by its path inside it, such as "Configurations" or
/// "Animations/CYLScenarioExampleMascot.riv"; nil when it does not exist.
func CYLScenarioExampleResourceURL(_ path: String) -> URL? {
    guard let bundle = CYLScenarioExampleBundle(), !path.hasPrefix("/"), !path.contains("..") else { return nil }
    let url = bundle.bundleURL.appendingPathComponent(path)
    return FileManager.default.fileExists(atPath: url.path) ? url : nil
}

/// Every key of CYLScenarioExample.strings, so code, keys and translations map in one place.
enum CYLScenarioL10n: String, CaseIterable {
    case tabScenarios = "CYLScenarioTabScenarios"
    case tabAnimations = "CYLScenarioTabAnimations"
    case tabFlows = "CYLScenarioSectionFlows"
    case tabFeed = "CYLScenarioTabFeed"
    case sectionReadme = "CYLScenarioSectionReadme"
    case sectionBusiness = "CYLScenarioSectionBusiness"
    case sectionPermissions = "CYLScenarioSectionPermissions"
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
    case feedbackChooseManually = "CYLScenarioFeedbackChooseManually"
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
    case sectionConfigurations = "CYLScenarioSectionConfigurations"
    case actionShowFile = "CYLScenarioActionShowFile"
    case formatActionTapped = "CYLScenarioFormatActionTapped"
    case interactionOn = "CYLScenarioInteractionOn"
    case interactionOff = "CYLScenarioInteractionOff"
    case configTapEachButton = "CYLScenarioConfigTapEachButton"
    case configHighlightDim = "CYLScenarioConfigHighlightDim"
    case configHighlightShrink = "CYLScenarioConfigHighlightShrink"
    case configHighlightNone = "CYLScenarioConfigHighlightNone"
    case configInteractionOff = "CYLScenarioConfigInteractionOff"
    case configPlaybackLoop = "CYLScenarioConfigPlaybackLoop"
    case configPlaybackOnce = "CYLScenarioConfigPlaybackOnce"
    case configPlaybackThree = "CYLScenarioConfigPlaybackThree"
    case refreshIcons = "CYLScenarioRefreshIcons"
    case sectionRefreshInit = "CYLScenarioSectionRefreshInit"
    case refreshByFilePath = "CYLScenarioRefreshByFilePath"
    case refreshByAttributes = "CYLScenarioRefreshByAttributes"
    case refreshByConfiguration = "CYLScenarioRefreshByConfiguration"
    case refreshByImages = "CYLScenarioRefreshByImages"
    case refreshByStates = "CYLScenarioRefreshByStates"
    case refreshBackFooter = "CYLScenarioRefreshBackFooter"
    case refreshGifNames = "CYLScenarioRefreshGifNames"
    case textRefreshHint = "CYLScenarioTextRefreshHint"
    case sectionStatusBar = "CYLScenarioSectionStatusBar"
    case titleStatusBar = "CYLScenarioTitleStatusBar"
    case statusModeBoth = "CYLScenarioStatusModeBoth"
    case statusModeBar = "CYLScenarioStatusModeBar"
    case statusModePlaceholder = "CYLScenarioStatusModePlaceholder"
    case statusModeList = "CYLScenarioStatusModeList"
    case feedbackReconnect = "CYLScenarioFeedbackReconnect"
    case actionCancel = "CYLScenarioActionCancel"
    case statusFollowNetwork = "CYLScenarioStatusFollowNetwork"
    case statusFollowingNetwork = "CYLScenarioStatusFollowingNetwork"
    case formatNetworkStatus = "CYLScenarioFormatNetworkStatus"
}

private enum CYLScenarioLocalizationBundle {
    static let table = "CYLScenarioExample"

    static let container: Bundle? = {
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
