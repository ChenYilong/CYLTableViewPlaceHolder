//
//  NSBundle+CYLRefresh.h
//  CYLRefresh
//
//  Created by MJ Lee on 16/6/13.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// [EN] Implemented in Swift since 2026-11-19 (`NSBundle+CYLRefresh.swift`, the same selectors; docs/Swift-Migration.md, step 6). This
//      declaration is for Objective-C callers only: Swift reads the Swift extension itself (`__swift__` is defined while
//      Swift imports the header), so the two never meet.
// [CN] 自 2026-11-19 起用 Swift 实现（`NSBundle+CYLRefresh.swift`，选择器不变；docs/Swift-Migration.md 第 6 步）。这里的声明只供 Objective-C
//      调用方使用：Swift 直接读取 Swift 扩展（Swift 导入头文件时定义了 `__swift__`），两者不会冲突。
#ifndef __swift__
/*!
 * [EN] Resource and string lookups of the refresh controls.
 * [CN] 刷新控件的资源与文案查找。
 */
@interface NSBundle (CYLRefresh)
/*!
 * The library's single resource bundle, CYLTableViewPlaceHolder.bundle. It holds the refresh images and the
 * refresh strings (`<language>.lproj/CYLRefresh.strings`) next to the placeholder's resources; CYLRefresh.bundle
 * no longer exists.
 */
+ (instancetype)cyl_refreshBundle;
/*!
 * [EN] The header and footer arrow, `CYLRefreshArrow@2x.png` of the library bundle, template-rendered and cached
 *      after the first call.
 * [CN] 刷新头与刷新尾的箭头：库 bundle 中的 `CYLRefreshArrow@2x.png`，按模板渲染，首次调用后缓存。
 */
+ (UIImage *)cyl_arrowImage;
/*!
 * [EN] The trailer arrow, `CYLRefreshTrailArrow@2x.png` of the library bundle, template-rendered and cached after the
 *      first call.
 * [CN] trailer 的箭头：库 bundle 中的 `CYLRefreshTrailArrow@2x.png`，按模板渲染，首次调用后缓存。
 */
+ (UIImage *)cyl_trailArrowImage;
/*!
 * [EN] The refresh text of `key`: looked up in the library's `CYLRefresh.strings` in the language of
 *      `CYLRefreshConfig.defaultConfig.languageCode` (else the preferred language, else English), then in the app's
 *      table `i18nFilename` of `i18nBundle` (or the main bundle), which wins when it has the key; `value` is returned
 *      when neither has it.
 * [CN] `key` 对应的刷新文案：先在库的 `CYLRefresh.strings` 中按
 *      `CYLRefreshConfig.defaultConfig.languageCode`（否则首选语言，再否则英文）查找，再在应用
 *      `i18nBundle`（或 main bundle）的 `i18nFilename` 表中查找，后者有该键时优先；都没有时返回
 *      `value`。
 */
+ (NSString *)cyl_localizedStringForKey:(NSString *)key value:(nullable NSString *)value;
/*!
 * [EN] `cyl_localizedStringForKey:value:` with no fallback value.
 * [CN] 不带回退值的 `cyl_localizedStringForKey:value:`。
 */
+ (NSString *)cyl_localizedStringForKey:(NSString *)key;
@end
#endif

NS_ASSUME_NONNULL_END
