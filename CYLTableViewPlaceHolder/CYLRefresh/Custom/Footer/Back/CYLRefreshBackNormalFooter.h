//
//  CYLRefreshBackNormalFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshBackNormalFooter.swift` (docs/Swift-Migration.md, step 9), with the same
//       Objective-C API (`arrowView`, `loadingView`, `noMoreDataImage`, `iconSize`, the deprecated
//       `activityIndicatorViewStyle`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshBackNormalFooter.swift`，docs/Swift-Migration.md 第 9 步），
//       Objective-C API 不变（`arrowView`、`loadingView`、`noMoreDataImage`、`iconSize`、已废弃的 `activityIndicatorViewStyle`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshBackStateFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The standard back footer: the state text with an arrow that turns when releasing will load, and a spinner
 *      while loading (`arrowView`, `loadingView`, `noMoreDataImage`, `iconSize`).
 *      The class is Swift (`CYLRefreshBackNormalFooter.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 标准回弹刷新尾：状态文字，带有松手即加载时会转向的箭头，加载时显示菊花（`arrowView`、`loadingView`、`noMoreDataImage`、`iconSize`）。
 *      该类用 Swift 编写（`CYLRefreshBackNormalFooter.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshBackNormalFooter;

NS_ASSUME_NONNULL_END
