//
//  CYLPlaceholderLocalization.swift
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The core layer's language selection, in Swift since 2026-11-19 with the same Objective-C API (class name,
//      selectors, Swift spellings). The notification constant, the C functions (`CYLPlaceholderLocalizedStringForKey`,
//      `CYLPlaceholderResourceBundle`, `CYLPlaceholderResourceURLForPath`) and the lookup macros stay in
//      `CYLPlaceholderLocalization.h` / `CYLPlaceholderLocalizationSupport.m`: Swift cannot declare a C symbol or a macro.
// [CN] 核心层的语言选择，自 2026-11-19 起用 Swift 编写，Objective-C API（类名、选择器、Swift 写法）不变。通知常量、C 函数
//      （`CYLPlaceholderLocalizedStringForKey`、`CYLPlaceholderResourceBundle`、`CYLPlaceholderResourceURLForPath`）与查找宏保留在
//      `CYLPlaceholderLocalization.h` / `CYLPlaceholderLocalizationSupport.m` 中：Swift 无法声明 C 符号或宏。

import Foundation

/**
 * [EN] Language selection for the core bundle's tables. [CN] 核心 bundle 字符串表的语言选择。
 */
@objc(CYLPlaceholderLocalization)
public final class CYLPlaceholderLocalization: NSObject {

    // [EN] The override `language` stores, guarded like the Objective-C `@synchronized`. [CN] `language` 的覆盖值，加锁保护。
    private static var storedLanguage: String?
    private static let lock = NSLock()

    /**
     * The languages the core tables provide: en, zh-Hans, zh-Hant, ja, ko, ru, uk.
     */
    @objc public static var supportedLanguages: [String] {
        // [EN] Same languages as the refresh table; both tables live in CYLTableViewPlaceHolder.bundle.
        // [CN] 与刷新组件的字符串表语言一致，两张表都在 CYLTableViewPlaceHolder.bundle 中。
        ["en", "zh-Hans", "zh-Hant", "ja", "ko", "ru", "uk"]
    }

    /**
     * The language used for core texts. nil (the default) follows the app's preferred languages. A language that is
     * not supported falls back to its base language when that is supported (for example "zh-HK" to "zh-Hant", "ja-JP"
     * to "ja"), else to English. Views read texts when they are created; recreate them after a change.
     */
    @objc public static var language: String? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return storedLanguage
        }
        set {
            let value = (newValue?.isEmpty ?? true) ? nil : newValue
            lock.lock()
            if value == storedLanguage {
                lock.unlock()
                return
            }
            storedLanguage = value
            lock.unlock()
            let post = {
                NotificationCenter.default.post(name: CYLPlaceholderLocalization.languageDidChangeNotification, object: nil)
            }
            if Thread.isMainThread {
                post()
            } else {
                DispatchQueue.main.async(execute: post)
            }
        }
    }

    /**
     * The supported language actually in use.
     */
    @objc public static var effectiveLanguage: String {
        if let requested = language {
            return supportedLanguage(forIdentifier: requested) ?? "en"
        }
        return Bundle.preferredLocalizations(from: supportedLanguages, forPreferences: Locale.preferredLanguages).first
            ?? "en"
    }

    /**
     * The text for a key of the core `Localizable.strings` in `effectiveLanguage`; the fallback (or the key) when the
     * bundle, the language or the key is missing.
     */
    @objc(localizedStringForKey:fallback:)
    public static func localizedString(forKey key: String, fallback: String?) -> String {
        let defaultValue = fallback ?? key
        guard let bundle = CYLPlaceholderResourceBundle() else {
            NSLog("CYLTableViewPlaceHolder: placeholder resource bundle not found.")
            return defaultValue
        }
        let language = effectiveLanguage
        guard let path = bundle.path(forResource: language, ofType: "lproj"),
              let localizedBundle = Bundle(path: path) else {
            NSLog("CYLTableViewPlaceHolder: localization %@ is missing.", language)
            return defaultValue
        }
        return localizedBundle.localizedString(forKey: key, value: defaultValue, table: nil)
    }

    // [EN] Not instantiable, as `NS_UNAVAILABLE` made it in Objective-C. [CN] 不可实例化，与 Objective-C 中的 `NS_UNAVAILABLE` 相同。
    private override init() {
        super.init()
    }

    // [EN] A supported language for a requested identifier: itself, its script variant for Chinese, or its base language.
    // [CN] 请求的语言标识对应的受支持语言：其本身、中文的书写变体，或其基础语言。
    private static func supportedLanguage(forIdentifier identifier: String) -> String? {
        let supported = supportedLanguages
        if let match = supported.first(where: { $0.caseInsensitiveCompare(identifier) == .orderedSame }) {
            return match
        }
        let lower = identifier.lowercased()
        if lower.hasPrefix("zh") {
            let traditional = lower.contains("hant") || lower.hasSuffix("-tw") || lower.hasSuffix("-hk") ||
                lower.hasSuffix("-mo")
            return traditional ? "zh-Hant" : "zh-Hans"
        }
        let base = lower.components(separatedBy: CharacterSet(charactersIn: "-_")).first ?? lower
        return supported.first(where: { $0.caseInsensitiveCompare(base) == .orderedSame })
    }
}
