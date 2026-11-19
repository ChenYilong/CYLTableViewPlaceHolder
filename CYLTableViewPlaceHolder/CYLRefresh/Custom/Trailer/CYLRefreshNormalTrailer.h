//
//  CYLRefreshNormalTrailer.h
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshNormalTrailer.swift` (docs/Swift-Migration.md, step 9), with the same
//       Objective-C API (`arrowView`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshNormalTrailer.swift`，docs/Swift-Migration.md 第 9 步），
//       Objective-C API 不变（`arrowView`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshStateTrailer.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The standard trailer: the state text with an arrow (`arrowView`, the bundle's `CYLRefreshTrailArrow` image).
 *      The class is Swift (`CYLRefreshNormalTrailer.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 标准 trailer：状态文字带箭头（`arrowView`，bundle 中的 `CYLRefreshTrailArrow` 图片）。
 *      该类用 Swift 编写（`CYLRefreshNormalTrailer.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshNormalTrailer;

NS_ASSUME_NONNULL_END
