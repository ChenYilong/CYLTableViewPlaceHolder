//
//  CYLRefreshBackStateFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/6/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-20: the class is in `CYLRefreshBackStateFooter.swift` (docs/Swift-Migration.md, step 10), with the same
//       Objective-C API (`stateLabel`, `labelLeftInset`, `setTitle:forState:`, `titleForState:`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-20 起该类用 Swift 编写（`CYLRefreshBackStateFooter.swift`，docs/Swift-Migration.md 第 10 步），
//       Objective-C API 不变（`stateLabel`、`labelLeftInset`、`setTitle:forState:`、`titleForState:`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshBackFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A back footer that shows a localized text for each state (`setTitle:forState:`).
 *      The class is Swift (`CYLRefreshBackStateFooter.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 按状态显示本地化文字（`setTitle:forState:`）的回弹刷新尾。
 *      该类用 Swift 编写（`CYLRefreshBackStateFooter.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshBackStateFooter;

NS_ASSUME_NONNULL_END
