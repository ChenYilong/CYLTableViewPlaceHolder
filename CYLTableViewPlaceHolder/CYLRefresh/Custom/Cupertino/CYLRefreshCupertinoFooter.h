//
//  CYLRefreshCupertinoFooter.h
//  CYLRefresh
//
//  The iOS-style load-more footer (flutter_easy_refresh's CupertinoFooter): a system activity indicator while loading.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshCupertinoFooter.swift` (docs/Swift-Migration.md, step 9), with the same
//       Objective-C API (`activityIndicator`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshCupertinoFooter.swift`，docs/Swift-Migration.md 第 9 步），
//       Objective-C API 不变（`activityIndicator`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshAutoFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The iOS-style footer: an automatic footer that shows a system activity indicator (`activityIndicator`) while
 *      loading and nothing otherwise (flutter_easy_refresh's `CupertinoFooter`). `colorAccent` colors the indicator.
 *      The class is Swift (`CYLRefreshCupertinoFooter.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] iOS 风格的加载尾：自动加载尾，加载时显示系统菊花（`activityIndicator`），其他时候不显示内容（对应 flutter_easy_refresh 的
 *      `CupertinoFooter`）。`colorAccent` 为菊花着色。
 *      该类用 Swift 编写（`CYLRefreshCupertinoFooter.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshCupertinoFooter;

NS_ASSUME_NONNULL_END
