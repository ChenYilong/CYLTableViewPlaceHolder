//
//  CYLScenarioLanguage.swift
//  Example-Scenarios
//
//  The language button at the top of the entry page, modeled on CYLTabBarController's Objective-C demo (a language
//  choice, then the window rebuilds its root with `cyl_setRootViewControllerProvider`). The choice sets the core
//  language (`CYLPlaceholderLocalization.language`: scenario titles, hints and buttons), the refresh controls'
//  language (`CYLRefreshConfig.default.languageCode`) and CYLTabBarController's (`CYLSetLocalizationLanguage`), whose
//  notification rebuilds the root.
//

import UIKit
import CYLTabBarController
import CYLTableViewPlaceHolder

enum CYLScenarioLanguage {

    /// Each language in its own name (language names are not translated).
    static func nativeName(of language: String) -> String {
        let names = [
            "en": "🇺🇸 English",
            "zh-Hans": "🇨🇳 简体中文",
            "zh-Hant": "🇭🇰 繁體中文",
            "ja": "🇯🇵 日本語",
            "ko": "🇰🇷 한국어",
            "ru": "🇷🇺 Русский",
            "uk": "🇺🇦 Українська",
        ]
        return names[language] ?? language
    }

    /// A bar button showing 🌐 and the current language; its menu lists every core language and "Follow system".
    static func barButtonItem() -> UIBarButtonItem {
        let current = CYLPlaceholderLocalization.language
        var actions = CYLPlaceholderLocalization.supportedLanguages.map { language in
            UIAction(title: nativeName(of: language), state: current == language ? .on : .off) { _ in
                select(language)
            }
        }
        actions.append(UIAction(title: CYLScenarioLocalizedString(.followSystem), image: UIImage(systemName: "gear"),
                                state: current == nil ? .on : .off) { _ in
            select(nil)
        })
        let menu = UIMenu(title: CYLScenarioLocalizedString(.language), children: actions)
        let title = "🌐 " + nativeName(of: CYLPlaceholderLocalization.effectiveLanguage)
        let item = UIBarButtonItem(title: title, image: nil, primaryAction: nil, menu: menu)
        item.accessibilityIdentifier = "languageButton"
        item.accessibilityLabel = CYLScenarioLocalizedString(.language)
        item.accessibilityValue = nativeName(of: CYLPlaceholderLocalization.effectiveLanguage)
        return item
    }

    /// nil follows the system.
    static func select(_ language: String?) {
        CYLPlaceholderLocalization.language = language
        CYLRefreshConfig.default.languageCode = language
        // Posts CYLLocalizationLanguageDidChangeNotification: the window rebuilds its root (CYLScenarioSceneDelegate).
        CYLSetLocalizationLanguage(language)
    }
}
