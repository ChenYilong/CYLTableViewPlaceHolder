//
//  NSBundle+CYLRefresh.swift
//  CYLRefresh
//
//  Created by MJ Lee on 16/6/13.
//  Copyright © 2016年 小码哥. All rights reserved.
//

// [EN] The resource and string lookups of the refresh controls, in Swift since 2026-11-19 (docs/Swift-Migration.md,
//      step 6) with the same Objective-C selectors and Swift spellings. The texts follow
//      `CYLRefreshConfig.default.languageCode` (else the preferred language, else English); the caches are cleared when
//      it changes.
// [CN] 刷新控件的资源与文案查找，自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 6 步），Objective-C 选择器与 Swift 写法不变。
//      文案语言跟随 `CYLRefreshConfig.default.languageCode`（否则首选语言，再否则英文）；语言改变时清除缓存。

import UIKit

// [EN] The lookup caches, read and written on the main thread like the Objective-C statics they replace.
// [CN] 查找缓存，与其替代的 Objective-C 静态变量一样在主线程读写。
private enum CYLRefreshBundleCache {
    // [EN] The refresh component's strings table inside CYLTableViewPlaceHolder.bundle; the placeholder uses Localizable.
    // [CN] CYLTableViewPlaceHolder.bundle 中刷新组件的字符串表；占位图使用 Localizable。
    static let stringsTable = "CYLRefresh"
    static var defaultI18nBundle: Bundle?
    static var systemI18nBundle: Bundle?
    static var arrowImage: UIImage?
    static var trailArrowImage: UIImage?
}

extension Bundle {

    /**
     * [EN] The library's single resource bundle, CYLTableViewPlaceHolder.bundle. It holds the refresh images and the
     *      refresh strings (`<language>.lproj/CYLRefresh.strings`) next to the placeholder's resources; CYLRefresh.bundle
     *      no longer exists. nil, with a log, when the app does not ship it.
     * [CN] 库唯一的资源包 CYLTableViewPlaceHolder.bundle，与占位图资源一起存放刷新图片与刷新文案
     *      （`<language>.lproj/CYLRefresh.strings`）；CYLRefresh.bundle 已不存在。应用未包含它时为 nil（并输出日志）。
     */
    @objc(cyl_refreshBundle)
    public dynamic class func cyl_refresh() -> Bundle! {
        // [EN] The one lookup of CYLTableViewPlaceHolder.bundle, shared with the placeholder (CYLPlaceholderResourceBundle).
        // [CN] 与占位图共用对 CYLTableViewPlaceHolder.bundle 的唯一查找（CYLPlaceholderResourceBundle）。
        CYLPlaceholderResourceBundle()
    }

    /**
     * [EN] The header and footer arrow, `CYLRefreshArrow@2x.png` of the library bundle, template-rendered and cached
     *      after the first call.
     * [CN] 刷新头与刷新尾的箭头：库 bundle 中的 `CYLRefreshArrow@2x.png`，按模板渲染，首次调用后缓存。
     */
    @objc public dynamic class func cyl_arrowImage() -> UIImage! {
        if CYLRefreshBundleCache.arrowImage == nil {
            CYLRefreshBundleCache.arrowImage = templateImage(named: "CYLRefreshArrow@2x")
        }
        return CYLRefreshBundleCache.arrowImage
    }

    /**
     * [EN] The trailer arrow, `CYLRefreshTrailArrow@2x.png` of the library bundle, template-rendered and cached after the
     *      first call.
     * [CN] trailer 的箭头：库 bundle 中的 `CYLRefreshTrailArrow@2x.png`，按模板渲染，首次调用后缓存。
     */
    @objc public dynamic class func cyl_trailArrowImage() -> UIImage! {
        if CYLRefreshBundleCache.trailArrowImage == nil {
            CYLRefreshBundleCache.trailArrowImage = templateImage(named: "CYLRefreshTrailArrow@2x")
        }
        return CYLRefreshBundleCache.trailArrowImage
    }

    // [EN] A PNG of the library bundle, template-rendered; nil when the bundle or the file is missing.
    // [CN] 库 bundle 中的 PNG，按模板渲染；bundle 或文件缺失时为 nil。
    private class func templateImage(named name: String) -> UIImage? {
        // [EN] Through the method, as `[self cyl_refreshBundle]` did, so a replaced implementation is used.
        // [CN] 与 `[self cyl_refreshBundle]` 一样通过该方法读取，替换后的实现也会生效。
        guard let path = cyl_refresh()?.path(forResource: name, ofType: "png") else { return nil }
        return UIImage(contentsOfFile: path)?.withRenderingMode(.alwaysTemplate)
    }

    /**
     * [EN] `cyl_localizedStringForKey:value:` with no fallback value.
     * [CN] 不带回退值的 `cyl_localizedStringForKey:value:`。
     */
    @objc(cyl_localizedStringForKey:)
    public dynamic class func cyl_localizedString(forKey key: String) -> String {
        cyl_localizedString(forKey: key, value: nil)
    }

    /**
     * [EN] The refresh text of `key`: looked up in the library's `CYLRefresh.strings` in the language of
     *      `CYLRefreshConfig.default.languageCode` (else the preferred language, else English), then in the app's
     *      table `i18nFilename` of `i18nBundle` (or the main bundle), which wins when it has the key; `value` is returned
     *      when neither has it.
     * [CN] `key` 对应的刷新文案：先在库的 `CYLRefresh.strings` 中按 `CYLRefreshConfig.default.languageCode`（否则首选语言，
     *      再否则英文）查找，再在应用 `i18nBundle`（或 main bundle）的 `i18nFilename` 表中查找，后者有该键时优先；都没有时返回
     *      `value`。
     */
    @objc(cyl_localizedStringForKey:value:)
    public dynamic class func cyl_localizedString(forKey key: String, value: String?) -> String {
        let config = CYLRefreshConfig.default
        let table = config.i18nFilename

        // 如果没有缓存, 则走初始化逻辑
        if CYLRefreshBundleCache.defaultI18nBundle == nil {
            // [EN] The configured language, else the preferred one. [CN] 配置的语言，否则为首选语言。
            let language = config.languageCode ?? NSLocale.preferredLanguages.first
            // 首先优先使用公共配置中的 i18nBundle, 如果为空则使用 mainBundle
            let bundle = config.i18nBundle ?? Bundle.main
            // 按语言选取语言包; 检查语言包, 如果没有查找到, 则默认使用 mainBundle
            let i18nFolderPath = bundle.path(forResource: language, ofType: "lproj")
            CYLRefreshBundleCache.defaultI18nBundle = i18nFolderPath.flatMap { Bundle(path: $0) } ?? Bundle.main

            // 获取 CYLRefresh 自有的语言包
            if CYLRefreshBundleCache.systemI18nBundle == nil {
                CYLRefreshBundleCache.systemI18nBundle = cyl_defaultI18nBundle(language: language)
            }
        }
        var value = value
        // 首先在 CYLRefresh 内置语言文件（统一资源包中的 CYLRefresh.strings）中寻找
        if let systemBundle = CYLRefreshBundleCache.systemI18nBundle {
            value = systemBundle.localizedString(forKey: key, value: value, table: CYLRefreshBundleCache.stringsTable)
        }
        // 然后在 MainBundle 对应语言文件中寻找
        let defaultBundle = CYLRefreshBundleCache.defaultI18nBundle ?? Bundle.main
        return defaultBundle.localizedString(forKey: key, value: value, table: table)
    }

    // [EN] The library's `.lproj` for a language: en, zh-Hans, zh-Hant (zh-Hant, zh-HK, zh-TW), ja, ko, ru, uk, else en.
    // [CN] 某语言对应的库内 `.lproj`：en、zh-Hans、zh-Hant（zh-Hant、zh-HK、zh-TW）、ja、ko、ru、uk，其他为 en。
    private class func cyl_defaultI18nBundle(language: String?) -> Bundle? {
        let language = language ?? ""
        let folder: String
        if language.hasPrefix("en") {
            folder = "en"
        } else if language.hasPrefix("zh") {
            folder = language.contains("Hans") ? "zh-Hans" : "zh-Hant"
        } else if language.hasPrefix("ja") {
            folder = "ja"
        } else if language.hasPrefix("ko") {
            folder = "ko"
        } else if language.hasPrefix("ru") {
            folder = "ru"
        } else if language.hasPrefix("uk") {
            folder = "uk"
        } else {
            folder = "en"
        }
        // 从统一资源包 CYLTableViewPlaceHolder.bundle 中查找资源
        guard let path = Bundle.cyl_refresh()?.path(forResource: folder, ofType: "lproj") else { return nil }
        return Bundle(path: path)
    }

    // [EN] Clears the language bundles; `CYLRefreshConfig.languageCode` calls it when the language changes.
    // [CN] 清除语言包缓存；`CYLRefreshConfig.languageCode` 在语言改变时调用。
    static func cyl_resetLanguageResourceCache() {
        CYLRefreshBundleCache.defaultI18nBundle = nil
        CYLRefreshBundleCache.systemI18nBundle = nil
    }
}
