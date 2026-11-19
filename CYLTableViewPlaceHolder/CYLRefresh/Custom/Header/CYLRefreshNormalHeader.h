//
//  CYLRefreshNormalHeader.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshNormalHeader.swift` (docs/Swift-Migration.md, step 9), with the same
//       Objective-C API (`arrowView`, `iconSize`, `loadingView`, the deprecated `activityIndicatorViewStyle`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshNormalHeader.swift`，docs/Swift-Migration.md 第 9 步），
//       Objective-C API 不变（`arrowView`、`iconSize`、`loadingView`、已废弃的 `activityIndicatorViewStyle`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshStateHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The standard header: the state and last-updated texts with an arrow that turns when releasing will refresh,
 *      and a spinner while refreshing (`arrowView`, `iconSize`, `loadingView`).
 *      The class is Swift (`CYLRefreshNormalHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 标准刷新头：状态文字与最后更新时间，带有松手即刷新时会转向的箭头，刷新时显示菊花（`arrowView`、`iconSize`、`loadingView`）。
 *      该类用 Swift 编写（`CYLRefreshNormalHeader.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshNormalHeader;

NS_ASSUME_NONNULL_END
