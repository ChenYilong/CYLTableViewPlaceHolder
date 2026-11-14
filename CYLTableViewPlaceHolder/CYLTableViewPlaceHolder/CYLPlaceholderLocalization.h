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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * Language selection for the core bundle's tables.
 */
@interface CYLPlaceholderLocalization : NSObject

/*!
 * The languages the core tables provide: en, zh-Hans, zh-Hant, ja, ko, ru, uk.
 */
@property (class, nonatomic, copy, readonly) NSArray<NSString *> *supportedLanguages;

/*!
 * The language used for core texts. nil (the default) follows the app's preferred languages. A language that is
 * not supported falls back to its base language when that is supported (for example "zh-HK" to "zh-Hant", "ja-JP"
 * to "ja"), else to English. Views read texts when they are created; recreate them after a change.
 */
@property (class, nonatomic, copy, nullable) NSString *language;

/*!
 * The supported language actually in use.
 */
@property (class, nonatomic, copy, readonly) NSString *effectiveLanguage;

/*!
 * The text for a key of the core `Localizable.strings` in `effectiveLanguage`; the fallback (or the key) when the
 * bundle, the language or the key is missing.
 */
+ (NSString *)localizedStringForKey:(NSString *)key fallback:(nullable NSString *)fallback
    NS_SWIFT_NAME(localizedString(forKey:fallback:));

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

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
