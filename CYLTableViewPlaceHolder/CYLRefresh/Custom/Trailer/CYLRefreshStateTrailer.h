//
//  CYLRefreshStateTrailer.h
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-20: the class is in `CYLRefreshStateTrailer.swift` (docs/Swift-Migration.md, step 10), with the same
//       Objective-C API (`stateLabel`, `setTitle:forState:`, `titleForState:`,
//       `cyl_placeStateLabelAtCenterX:`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-20 起该类用 Swift 编写（`CYLRefreshStateTrailer.swift`，docs/Swift-Migration.md 第 10 步），
//       Objective-C API 不变（`stateLabel`、`setTitle:forState:`、`titleForState:`、`cyl_placeStateLabelAtCenterX:`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshTrailer.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A trailer that shows a localized text for each state (`setTitle:forState:`), as a vertical column
 *      readable in every language (`cyl_placeStateLabelAtCenterX:`).
 *      The class is Swift (`CYLRefreshStateTrailer.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 按状态显示本地化文字（`setTitle:forState:`）的 trailer，文字排成任何语言都可读的竖列（`cyl_placeStateLabelAtCenterX:`）。
 *      该类用 Swift 编写（`CYLRefreshStateTrailer.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshStateTrailer;

NS_ASSUME_NONNULL_END
