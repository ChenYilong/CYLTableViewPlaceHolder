//
//  CYLRefreshConfig.h
//
//  Created by Frank on 2018/11/27.
//  Copyright © 2018 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshConfig.swift` (docs/Swift-Migration.md, step 6), with the same
//       Objective-C API (`+defaultConfig`, Swift `default`; `languageCode`, `i18nFilename`, `i18nBundle`,
//       `defaultHeaderCreator`, `defaultFooterCreator`, `defaultInitializer`; `-init` and `+new` unavailable).
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshConfig.swift`，docs/Swift-Migration.md 第 6 步），Objective-C API 不变
//       （`+defaultConfig`，Swift 中为 `default`；`languageCode`、`i18nFilename`、`i18nBundle`、`defaultHeaderCreator`、
//       `defaultFooterCreator`、`defaultInitializer`；`-init` 与 `+new` 不可用）。

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The shared settings of every refresh control (language, strings table and bundle, default controls), read
 *      through `defaultConfig`. The class is Swift (`CYLRefreshConfig.swift`); Objective-C code that messages it imports
 *      the umbrella header `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 所有刷新控件共用的设置（语言、字符串表与 bundle、默认控件），通过 `defaultConfig` 读取。该类用 Swift 编写
 *      （`CYLRefreshConfig.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshConfig;

NS_ASSUME_NONNULL_END
