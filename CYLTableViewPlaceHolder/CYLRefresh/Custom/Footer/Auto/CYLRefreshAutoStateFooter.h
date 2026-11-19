//
//  CYLRefreshAutoStateFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/6/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-20: the class is in `CYLRefreshAutoStateFooter.swift` (docs/Swift-Migration.md, step 10), with the same
//       Objective-C API (`stateLabel`, `labelLeftInset`, `setTitle:forState:`, `titleForState:`,
//       `refreshingTitleHidden`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-20 起该类用 Swift 编写（`CYLRefreshAutoStateFooter.swift`，docs/Swift-Migration.md 第 10 步），
//       Objective-C API 不变（`stateLabel`、`labelLeftInset`、`setTitle:forState:`、`titleForState:`、`refreshingTitleHidden`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshAutoFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] An automatic footer that shows a localized text for each state (`setTitle:forState:`); a tap on the
 *      idle text loads more.
 *      The class is Swift (`CYLRefreshAutoStateFooter.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 按状态显示本地化文字（`setTitle:forState:`）的自动刷新尾；点击闲置状态的文字即加载更多。
 *      该类用 Swift 编写（`CYLRefreshAutoStateFooter.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshAutoStateFooter;

NS_ASSUME_NONNULL_END
