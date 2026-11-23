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
import UIKit
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
    case sectionHUD = "CYLScenarioSectionHUD"
    case titleHUD = "CYLScenarioTitleHUD"
    case hudSectionShow = "CYLScenarioHUDSectionShow"
    case hudSectionLook = "CYLScenarioHUDSectionLook"
    case hudSectionLifecycle = "CYLScenarioHUDSectionLifecycle"
    case hudShow = "CYLScenarioHUDShow"
    case hudShowStatus = "CYLScenarioHUDShowStatus"
    case hudShowProgress = "CYLScenarioHUDShowProgress"
    case hudShowSuccess = "CYLScenarioHUDShowSuccess"
    case hudShowError = "CYLScenarioHUDShowError"
    case hudShowInfo = "CYLScenarioHUDShowInfo"
    case hudShowImage = "CYLScenarioHUDShowImage"
    case hudShowComponents = "CYLScenarioHUDShowComponents"
    case hudShowScenario = "CYLScenarioHUDShowScenario"
    case hudPopActivity = "CYLScenarioHUDPopActivity"
    case hudDismiss = "CYLScenarioHUDDismiss"
    case hudStyle = "CYLScenarioHUDStyle"
    case hudMask = "CYLScenarioHUDMask"
    case hudAnimation = "CYLScenarioHUDAnimation"
    case hudHaptics = "CYLScenarioHUDHaptics"
    case hudLifecycle = "CYLScenarioHUDLifecycle"
    case hudStatusLoading = "CYLScenarioHUDStatusLoading"
    case hudStatusDownloading = "CYLScenarioHUDStatusDownloading"
    case hudStatusSaved = "CYLScenarioHUDStatusSaved"
    case hudStatusFailed = "CYLScenarioHUDStatusFailed"
    case hudStatusInfo = "CYLScenarioHUDStatusInfo"
    case hudStatusImage = "CYLScenarioHUDStatusImage"
    case hudCancel = "CYLScenarioHUDCancel"
    case hudCancelled = "CYLScenarioHUDCancelled"
    case hudStyleAutomatic = "CYLScenarioHUDStyleAutomatic"
    case hudStyleLight = "CYLScenarioHUDStyleLight"
    case hudStyleDark = "CYLScenarioHUDStyleDark"
    case hudStyleCustom = "CYLScenarioHUDStyleCustom"
    case hudMaskNone = "CYLScenarioHUDMaskNone"
    case hudMaskClear = "CYLScenarioHUDMaskClear"
    case hudMaskBlack = "CYLScenarioHUDMaskBlack"
    case hudMaskGradient = "CYLScenarioHUDMaskGradient"
    case hudLifecycleRow = "CYLScenarioHUDLifecycleRow"
    case tabRefresh = "CYLScenarioTabRefresh"
    case mjSectionHeader = "CYLScenarioMJSectionHeader"
    case mjSectionFooter = "CYLScenarioMJSectionFooter"
    case mjSectionCollection = "CYLScenarioMJSectionCollection"
    case mjSectionWeb = "CYLScenarioMJSectionWeb"
    case mjSectionI18n = "CYLScenarioMJSectionI18n"
    case mjSectionAnimations = "CYLScenarioMJSectionAnimations"
    case mjDefault = "CYLScenarioMJDefault"
    case mjAnimatedImages = "CYLScenarioMJAnimatedImages"
    case mjHideTime = "CYLScenarioMJHideTime"
    case mjHideStateAndTime = "CYLScenarioMJHideStateAndTime"
    case mjCustomText = "CYLScenarioMJCustomText"
    case mjCustomControl = "CYLScenarioMJCustomControl"
    case mjHideRefreshingText = "CYLScenarioMJHideRefreshingText"
    case mjAllLoaded = "CYLScenarioMJAllLoaded"
    case mjNoAutoLoading = "CYLScenarioMJNoAutoLoading"
    case mjHideAfterLoading = "CYLScenarioMJHideAfterLoading"
    case mjAutoBack01 = "CYLScenarioMJAutoBack01"
    case mjAutoBack02 = "CYLScenarioMJAutoBack02"
    case mjCustomAutoControl = "CYLScenarioMJCustomAutoControl"
    case mjCustomBackControl = "CYLScenarioMJCustomBackControl"
    case mjPullUpAndDown = "CYLScenarioMJPullUpAndDown"
    case mjPinHeader = "CYLScenarioMJPinHeader"
    case mjPullLeft = "CYLScenarioMJPullLeft"
    case mjWebPullOld = "CYLScenarioMJWebPullOld"
    case mjWebPull = "CYLScenarioMJWebPull"
    case mjLanguages = "CYLScenarioMJLanguages"
    case mjI18nBuiltIn = "CYLScenarioMJI18nBuiltIn"
    case mjI18nCustom = "CYLScenarioMJI18nCustom"
    case mjLanguageChanged = "CYLScenarioMJLanguageChanged"
    case mjOK = "CYLScenarioMJOK"
    case mjGifIcon = "CYLScenarioMJGifIcon"
    case mjLottieStates = "CYLScenarioMJLottieStates"
    case mjPagRing = "CYLScenarioMJPagRing"
    case mjRiveIcon = "CYLScenarioMJRiveIcon"
    case mjSVGAIcon = "CYLScenarioMJSVGAIcon"
    case mjGifFrames = "CYLScenarioMJGifFrames"
    case mjMixedEngines = "CYLScenarioMJMixedEngines"
    case mjCollectionIcons = "CYLScenarioMJCollectionIcons"
    case refreshStyleSection = "CYLScenarioRefreshStyleSection"
    case refreshStyleClassics = "CYLScenarioRefreshStyleClassics"
    case refreshStyleClassicsFooter = "CYLScenarioRefreshStyleClassicsFooter"
    case refreshStyleBezierRadarFooter = "CYLScenarioRefreshStyleBezierRadarFooter"
    case refreshStyleMaterialFooter = "CYLScenarioRefreshStyleMaterialFooter"
    case refreshStyleDeliveryFooter = "CYLScenarioRefreshStyleDeliveryFooter"
    case refreshStylePhoenixFooter = "CYLScenarioRefreshStylePhoenixFooter"
    case refreshStyleTaurusFooter = "CYLScenarioRefreshStyleTaurusFooter"
    case refreshStyleRiveBow = "CYLScenarioRefreshStyleRiveBow"
    case refreshStyleRiveBubbles = "CYLScenarioRefreshStyleRiveBubbles"
    case refreshStyleRiveHalloween = "CYLScenarioRefreshStyleRiveHalloween"
    case refreshStyleRiveSkating = "CYLScenarioRefreshStyleRiveSkating"
    case refreshStyleRiveSpace = "CYLScenarioRefreshStyleRiveSpace"
    case refreshStyleRiveSquats = "CYLScenarioRefreshStyleRiveSquats"
    case refreshStyleRiveSpaceFooter = "CYLScenarioRefreshStyleRiveSpaceFooter"
    case refreshStyleSVGABow = "CYLScenarioRefreshStyleSVGABow"
    case refreshStyleSVGABubbles = "CYLScenarioRefreshStyleSVGABubbles"
    case refreshStyleSVGAHalloween = "CYLScenarioRefreshStyleSVGAHalloween"
    case refreshStyleSVGASkating = "CYLScenarioRefreshStyleSVGASkating"
    case refreshStyleSVGASpace = "CYLScenarioRefreshStyleSVGASpace"
    case refreshStyleSVGASquats = "CYLScenarioRefreshStyleSVGASquats"
    case refreshStyleSVGASpaceFooter = "CYLScenarioRefreshStyleSVGASpaceFooter"
    case easySection = "CYLScenarioEasySection"
    case easyCupertino = "CYLScenarioEasyCupertino"
    case easySecondary = "CYLScenarioEasySecondary"
    case easyTriggerMode = "CYLScenarioEasyTriggerMode"
    case easyRefreshOnStart = "CYLScenarioEasyRefreshOnStart"
    case easyPaging = "CYLScenarioEasyPaging"
    case easyScrollMode = "CYLScenarioEasyScrollMode"
    case easyScrollMove = "CYLScenarioEasyScrollMove"
    case easyScrollStretch = "CYLScenarioEasyScrollStretch"
    case easyScrollFront = "CYLScenarioEasyScrollFront"
    case easyScrollBehind = "CYLScenarioEasyScrollBehind"
    case easyScrollSelected = "CYLScenarioEasyScrollSelected"
    case easyListener = "CYLScenarioEasyListener"
    case easyChat = "CYLScenarioEasyChat"
    case easyUserProfile = "CYLScenarioEasyUserProfile"
    case easySecondFloor = "CYLScenarioEasySecondFloor"
    case easyCloseSecondFloor = "CYLScenarioEasyCloseSecondFloor"
    case easyPullProgress = "CYLScenarioEasyPullProgress"
    case easyMessageRow = "CYLScenarioEasyMessageRow"
    case easyProfileBanner = "CYLScenarioEasyProfileBanner"
    case easyRefreshCount = "CYLScenarioEasyRefreshCount"
    case easyLoadCount = "CYLScenarioEasyLoadCount"
    case easyHeaderOnEdge = "CYLScenarioEasyHeaderOnEdge"
    case easyHeaderAnywhere = "CYLScenarioEasyHeaderAnywhere"
    case easyFooterOnEdge = "CYLScenarioEasyFooterOnEdge"
    case easyFooterAnywhere = "CYLScenarioEasyFooterAnywhere"
    case refreshStyleThemeDefault = "CYLScenarioRefreshStyleThemeDefault"
    case refreshStyleThemeOrange = "CYLScenarioRefreshStyleThemeOrange"
    case refreshStyleThemeRed = "CYLScenarioRefreshStyleThemeRed"
    case refreshStyleThemeGreen = "CYLScenarioRefreshStyleThemeGreen"
    case refreshStyleThemeBlue = "CYLScenarioRefreshStyleThemeBlue"
    case refreshStyleTapToRestore = "CYLScenarioRefreshStyleTapToRestore"
    case refreshStyleTapToSwitch = "CYLScenarioRefreshStyleTapToSwitch"
    case refreshStyleTestData = "CYLScenarioRefreshStyleTestData"
    case refreshStyleTestDataRow = "CYLScenarioRefreshStyleTestDataRow"
    case refreshStyleDelivery = "CYLScenarioRefreshStyleDelivery"
    case refreshStyleDropBox = "CYLScenarioRefreshStyleDropBox"
    case refreshStylePhoenix = "CYLScenarioRefreshStylePhoenix"
    case refreshStyleTaurus = "CYLScenarioRefreshStyleTaurus"
    case refreshStyleBezierRadar = "CYLScenarioRefreshStyleBezierRadar"
    case refreshStyleBezierCircle = "CYLScenarioRefreshStyleBezierCircle"
    case refreshStyleStoreHouse = "CYLScenarioRefreshStyleStoreHouse"
    case refreshStyleWaveSwipe = "CYLScenarioRefreshStyleWaveSwipe"
    case refreshStyleOriginal = "CYLScenarioRefreshStyleOriginal"
    case refreshStyleMaterial = "CYLScenarioRefreshStyleMaterial"
    case refreshStyleGameHitBlock = "CYLScenarioRefreshStyleGameHitBlock"
    case refreshStyleGameBattleCity = "CYLScenarioRefreshStyleGameBattleCity"
    case refreshStyleFly = "CYLScenarioRefreshStyleFly"
    case mjRandomData = "CYLScenarioMJRandomData"
    case mjPush = "CYLScenarioMJPush"
    case mjModal = "CYLScenarioMJModal"
    case mjTestTitle = "CYLScenarioMJTestTitle"
    case mjClose = "CYLScenarioMJClose"
    case mjResumeLoading = "CYLScenarioMJResumeLoading"
    case mjDIYPullDown = "CYLScenarioMJDIYPullDown"
    case mjDIYRelease = "CYLScenarioMJDIYRelease"
    case mjDIYLoading = "CYLScenarioMJDIYLoading"
    case mjDIYPullUp = "CYLScenarioMJDIYPullUp"
    case mjDIYNoMore = "CYLScenarioMJDIYNoMore"
    case mjCustomIdle = "CYLScenarioMJCustomIdle"
    case mjCustomPulling = "CYLScenarioMJCustomPulling"
    case mjCustomLoading = "CYLScenarioMJCustomLoading"
    case mjFooterIdle = "CYLScenarioMJFooterIdle"
    case mjFooterLoading = "CYLScenarioMJFooterLoading"
    case mjFooterNoMore = "CYLScenarioMJFooterNoMore"
    case mjWebWarning = "CYLScenarioMJWebWarning"
    case mjWebBack = "CYLScenarioMJWebBack"
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
    case playbackPlayAll = "CYLScenarioPlaybackPlayAll"
    case playbackSpeed = "CYLScenarioPlaybackSpeed"
    case playbackLoop = "CYLScenarioPlaybackLoop"
    case riveRoomsTitle = "CYLScenarioRiveRoomsTitle"
    case riveRoomsPlaceholder = "CYLScenarioRiveRoomsPlaceholder"
    case riveRoomsValue = "CYLScenarioRiveRoomsValue"
    case riveRoomsPicker = "CYLScenarioRiveRoomsPicker"
    case riveRoomsSlider = "CYLScenarioRiveRoomsSlider"
    case riveRoomsLoop = "CYLScenarioRiveRoomsLoop"
    case riveRoomsHint = "CYLScenarioRiveRoomsHint"
    case actionClear = "CYLScenarioActionClear"
    case actionAdd = "CYLScenarioActionAdd"
    case actionSources = "CYLScenarioActionSources"
    case engineRegistered = "CYLScenarioEngineRegistered"
    case engineMissing = "CYLScenarioEngineMissing"
    case actionEngines = "CYLScenarioActionEngines"
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
    case sectionRefreshArrow = "CYLScenarioSectionRefreshArrow"
    case refreshArrowAuto = "CYLScenarioRefreshArrowAuto"
    case refreshArrowBack = "CYLScenarioRefreshArrowBack"
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
/// `CYLPlaceholderLocalization.effectiveLanguage` follows, and that every `CYLScenarioL10n` key resolves through
/// `CYLScenarioLocalizedString` to that language's own table value, read straight from its `.lproj` (so a key missing
/// in one language, or a lookup that ignores the language switch, is reported). An unknown language must fall back to
/// English. The core language is restored afterwards. Returns the number of lookups and the problems found.
func CYLScenarioLocalizationSelfCheck() -> (lookups: Int, problems: [String]) {
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
        let table = CYLScenarioLocalizationBundle.tableEntries(language: expected)
        if table.isEmpty {
            problems.append("\(expected).lproj/\(CYLScenarioLocalizationBundle.table).strings is missing or empty")
            continue
        }
        for key in CYLScenarioL10n.allCases {
            lookups += 1
            let value = CYLScenarioLocalizedString(key)
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
/// `CYLScenarioLocalizationSelfCheck()`, prints `CYL_LOCALIZATION_CHECK PASS <lookups>` (or `FAIL` and each problem) for
/// `xcrun simctl launch --console`, shows the result in a label (accessibility identifier `CYLLocalizationCheckResult`)
/// for UI tests, and with `-exitAfterLocalizationCheck` exits with status 0 or 1 once printed.
final class CYLScenarioLocalizationCheckViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let result = CYLScenarioLocalizationSelfCheck()
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
