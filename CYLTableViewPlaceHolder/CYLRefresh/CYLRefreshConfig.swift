//
//  CYLRefreshConfig.swift
//
//  Created by Frank on 2018/11/27.
//  Copyright © 2018 小码哥. All rights reserved.
//

// [EN] The shared settings of the refresh controls, in Swift since 2026-11-19 (docs/Swift-Migration.md, step 6) with the
//      same Objective-C API: the class name, `+defaultConfig` (Swift `default`), the properties and their selectors.
//      Objective-C code that messages it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//      generated Swift header; `CYLRefreshConfig.h` keeps the forward declaration.
// [CN] 刷新控件的共享设置，自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 6 步），Objective-C API 不变：类名、
//      `+defaultConfig`（Swift 中为 `default`）、属性及其选择器。需要调用它的 Objective-C 代码请导入总头文件
//      `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；`CYLRefreshConfig.h` 保留前向声明。

import UIKit

/**
 * [EN] The shared settings of every refresh control (language, strings table and bundle, default controls), read
 *      through `defaultConfig`.
 * [CN] 所有刷新控件共用的设置（语言、字符串表与 bundle、默认控件），通过 `defaultConfig` 读取。
 */
@objc(CYLRefreshConfig)
public final class CYLRefreshConfig: NSObject {

    /**
     * [EN] The shared instance (Objective-C `defaultConfig`), created once.
     * [CN] 共享实例（Objective-C 中为 `defaultConfig`），只创建一次。
     */
    @objc(defaultConfig)
    public static let `default` = CYLRefreshConfig()

    // [EN] The storage of `languageCode`, written directly so the setter's side effects run only for callers.
    // [CN] `languageCode` 的存储；直接写入，使 setter 的副作用只在调用方设置时执行。
    private var storedLanguageCode: String?

    /**
     * [EN] The language of the refresh texts; nil (the default) follows the system language. Setting another value
     *      clears the cached language bundles and posts `CYLRefreshDidChangeLanguageNotification`.
     * [CN] 默认使用的语言版本, 默认为 nil, 将随系统的语言自动改变。设置为其他值时清除语言资源缓存并发出
     *      `CYLRefreshDidChangeLanguageNotification`。
     */
    @objc public var languageCode: String? {
        get { storedLanguageCode }
        set {
            // [EN] As `[languageCode isEqualToString:_languageCode]`: nil never equals, so setting nil always resets.
            // [CN] 与 `[languageCode isEqualToString:_languageCode]` 相同：nil 永不相等，因此设为 nil 总会重置。
            if let newValue = newValue, let old = storedLanguageCode, (newValue as NSString).isEqual(to: old) {
                return
            }
            storedLanguageCode = newValue
            // 重置语言资源
            Bundle.cyl_resetLanguageResourceCache()
            NotificationCenter.default.post(name: .CYLRefreshDidChangeLanguage, object: self)
        }
    }

    /**
     * [EN] The app's strings table name without `.strings`; nil (the default) means `Localizable.strings`.
     * [CN] 默认使用的语言资源文件名, 默认为 nil, 即默认的 Localizable.strings。文件名不包含后缀 .strings。
     */
    @objc public var i18nFilename: String?

    /**
     * [EN] A custom bundle for the app's strings table; nil (the default) uses the main bundle.
     * [CN] i18n 多语言资源加载自定义 Bundle。默认为 nil 采用内置逻辑；设置后将忽略内置逻辑的多语言模式，采用自定义的多语言 bundle。
     */
    @objc public var i18nBundle: Bundle?

    /**
     * [EN] Makes the header `-[UIScrollView cyl_installDefaultRefreshControls]` installs where a scroll view has none
     *      (CYLRefreshLayout's `setDefaultRefreshHeaderCreator`). Default nil.
     * [CN] 生成 `-[UIScrollView cyl_installDefaultRefreshControls]` 为没有刷新头的滚动视图安装的刷新头（对应 CYLRefreshLayout 的
     *      `setDefaultRefreshHeaderCreator`）。默认 nil。
     */
    @objc public var defaultHeaderCreator: ((UIScrollView) -> CYLRefreshHeader?)?

    /**
     * [EN] Makes the footer `-[UIScrollView cyl_installDefaultRefreshControls]` installs where a scroll view has none
     *      (CYLRefreshLayout's `setDefaultRefreshFooterCreator`). Default nil.
     * [CN] 生成 `-[UIScrollView cyl_installDefaultRefreshControls]` 为没有尾部的滚动视图安装的尾部（对应 CYLRefreshLayout 的
     *      `setDefaultRefreshFooterCreator`）。默认 nil。
     */
    @objc public var defaultFooterCreator: ((UIScrollView) -> CYLRefreshFooter?)?

    /**
     * [EN] Sets up every control once, when it is first attached to a scroll view, before its own
     *      `didAttachToScrollView:` (CYLRefreshLayout's `setDefaultRefreshInitializer`). Default nil.
     * [CN] 每个控件第一次挂到滚动视图时调用一次，在其 `didAttachToScrollView:` 之前（对应 CYLRefreshLayout 的
     *      `setDefaultRefreshInitializer`）。默认 nil。
     */
    @objc public var defaultInitializer: ((CYLRefreshComponent) -> Void)?

    // [EN] Unavailable to callers (Objective-C `init` / `new` are unavailable): use the shared `default`.
    // [CN] 调用方不可用（Objective-C 的 `init` / `new` 不可用）：请使用共享的 `default`。
    private override init() {
        super.init()
    }
}
