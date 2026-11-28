//
//  CYLRefreshStateHeader.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-20: the class is in `CYLRefreshStateHeader.swift` (docs/Swift-Migration.md, step 10), with the same
//       Objective-C API (`stateLabel`, `lastUpdatedTimeLabel`, `lastUpdatedTimeText`, `labelLeftInset`, `setTitle:forState:`,
//       `titleForState:`, `lastUpdatedTimeFormatter`, `titleTimeSpacing`, `succeededImage`, `failedImage`, `iconOnTrailingSide`,
//       `cyl_modifyLastUpdatedTimeText:`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-20 起该类用 Swift 编写（`CYLRefreshStateHeader.swift`，docs/Swift-Migration.md 第 10 步），
//       Objective-C API 不变（`stateLabel`、`lastUpdatedTimeLabel`、`lastUpdatedTimeText`、`labelLeftInset`、`setTitle:forState:`、`titleForState:`、
//       `lastUpdatedTimeFormatter`、`titleTimeSpacing`、`succeededImage`、`failedImage`、`iconOnTrailingSide`、`cyl_modifyLastUpdatedTimeText:`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A header that shows a localized text for each state and the time of the last refresh (`stateLabel`,
 *      `lastUpdatedTimeLabel`, `setTitle:forState:`).
 *      The class is Swift (`CYLRefreshStateHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 按状态显示本地化文字以及上次刷新时间的刷新头（`stateLabel`、`lastUpdatedTimeLabel`、`setTitle:forState:`）。
 *      该类用 Swift 编写（`CYLRefreshStateHeader.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshStateHeader;

NS_ASSUME_NONNULL_END
