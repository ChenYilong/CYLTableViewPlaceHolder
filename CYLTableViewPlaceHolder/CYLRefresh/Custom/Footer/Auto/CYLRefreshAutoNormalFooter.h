//
//  CYLRefreshAutoNormalFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshAutoNormalFooter.swift` (docs/Swift-Migration.md, step 9), with the same
//       Objective-C API (`loadingView`, `noMoreDataImage`, the deprecated `activityIndicatorViewStyle`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshAutoNormalFooter.swift`，docs/Swift-Migration.md 第 9 步），
//       Objective-C API 不变（`loadingView`、`noMoreDataImage`、已废弃的 `activityIndicatorViewStyle`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshAutoStateFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The standard automatic footer: the state text with a spinner while loading (`loadingView`), and
 *      `noMoreDataImage` beside the text while there is no more data.
 *      The class is Swift (`CYLRefreshAutoNormalFooter.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 标准自动刷新尾：状态文字，加载时显示菊花（`loadingView`），没有更多数据时在文字旁显示 `noMoreDataImage`。
 *      该类用 Swift 编写（`CYLRefreshAutoNormalFooter.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshAutoNormalFooter;

NS_ASSUME_NONNULL_END
