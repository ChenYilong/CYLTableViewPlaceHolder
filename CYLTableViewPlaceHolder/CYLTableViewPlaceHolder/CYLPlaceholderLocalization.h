//
//  CYLPlaceholderLocalization.h
//  CYLTableViewPlaceHolder
//
//  [EN] The core layer's localization: every placeholder text, scenario title and component title is read from
//  `CYLTableViewPlaceHolder.bundle/<language>.lproj/Localizable.strings` through `CYLPlaceholderLocalizedString`,
//  the core lookup macro (instructions.md, "Lookup macros"). An app can switch the language at run time.
//  [CN] 核心层的国际化：占位文案、场景标题和组件标题都通过核心查找宏 `CYLPlaceholderLocalizedString` 读取
//  `CYLTableViewPlaceHolder.bundle/<语言>.lproj/Localizable.strings`；应用可在运行时切换语言。
//
//  [EN] Swift since 2026-11-19: the class is in `CYLPlaceholderLocalization.swift`. What Swift cannot declare stays here
//       in Objective-C, made Swift-compatible (docs/Swift-Migration.md, rule 6), and is defined in
//       `CYLPlaceholderLocalizationSupport.m`: the notification constant (a FOUNDATION_EXPORT symbol, `NS_SWIFT_NAME`),
//       the C functions with C linkage (callable from Swift) and the two function-like macros.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLPlaceholderLocalization.swift`）。Swift 无法声明的部分保留在 Objective-C 中并兼容 Swift
//       （docs/Swift-Migration.md 第 6 条），定义在 `CYLPlaceholderLocalizationSupport.m`：通知常量（FOUNDATION_EXPORT 符号，带
//       `NS_SWIFT_NAME`）、C 链接的 C 函数（Swift 可直接调用）以及两个函数式宏。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Language selection for the core bundle's tables. The class is Swift since 2026-11-19
 *      (`CYLPlaceholderLocalization.swift`) with the same Objective-C API: `supportedLanguages`, `language`,
 *      `effectiveLanguage` and `+localizedStringForKey:fallback:`. Objective-C code that messages it imports the umbrella
 *      header `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 核心 bundle 字符串表的语言选择。该类自 2026-11-19 起用 Swift 编写（`CYLPlaceholderLocalization.swift`），Objective-C API 不变。
 *      需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLPlaceholderLocalization;

/*!
 * Posted on the main thread after `CYLPlaceholderLocalization.language` changes.
 * Swift: `CYLPlaceholderLocalization.languageDidChangeNotification`.
 */
FOUNDATION_EXPORT NSNotificationName const CYLPlaceholderLocalizationLanguageDidChangeNotification
    NS_SWIFT_NAME(CYLPlaceholderLocalization.languageDidChangeNotification);

/*!
 * The function the core lookup macro expands to. Swift, which cannot call function-like macros, calls it
 * (`CYLPlaceholderLocalizedStringForKey(key, fallback)`) or `CYLPlaceholderLocalization.localizedString(forKey:fallback:)`.
 */
FOUNDATION_EXPORT NSString *CYLPlaceholderLocalizedStringForKey(NSString *key, NSString * _Nullable fallback);

NS_ASSUME_NONNULL_END

/*!
 * The core layer's lookup macro: reads only the core bundle. Examples define their own macro or function.
 */
#define CYLPlaceholderLocalizedString(key, fallback) CYLPlaceholderLocalizedStringForKey((key), (fallback))

NS_ASSUME_NONNULL_BEGIN
/*!
 * The core resource bundle, CYLTableViewPlaceHolder.bundle (placeholder icons and animations, the refresh arrows, the
 * core strings); nil, with a log, when the app does not ship it. Examples read their own bundles, never this one.
 */
FOUNDATION_EXPORT NSBundle * _Nullable CYLPlaceholderResourceBundle(void);
/*!
 * A file in the core bundle by its path inside it, such as "Animations/CYLPlaceholderLoading.json"; nil when it is
 * missing or the path leaves the bundle. Swift calls it directly; Objective-C uses the macro below.
 */
FOUNDATION_EXPORT NSURL * _Nullable CYLPlaceholderResourceURLForPath(NSString *path);
NS_ASSUME_NONNULL_END

/*!
 * The core layer's resource macro: a file of the core bundle only.
 */
#define CYLPlaceholderResourceURL(path) CYLPlaceholderResourceURLForPath((path))
