//
//  CYLRefreshAutoGifFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshAutoGifFooter.swift` (docs/Swift-Migration.md, step 9), with the same
//       Objective-C API (`gifView`, `setImages:duration:forState:`, `setImages:forState:`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshAutoGifFooter.swift`，docs/Swift-Migration.md 第 9 步），
//       Objective-C API 不变（`gifView`、`setImages:duration:forState:`、`setImages:forState:`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshAutoAnimationFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The MJRefresh name of `CYLRefreshAutoAnimationFooter`, kept for compatibility: `gifView` and `setImages:…` call the
 *      general methods. New code can use `CYLRefreshAutoAnimationFooter`.
 *      The class is Swift (`CYLRefreshAutoGifFooter.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] `CYLRefreshAutoAnimationFooter` 在 MJRefresh 中的名字，为兼容保留：`gifView` 与 `setImages:…` 调用通用方法。新代码可以使用
 *      `CYLRefreshAutoAnimationFooter`。
 *      该类用 Swift 编写（`CYLRefreshAutoGifFooter.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshAutoGifFooter;

NS_ASSUME_NONNULL_END
