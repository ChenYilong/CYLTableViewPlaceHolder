//
//  CYLRefreshCupertinoHeader.h
//  CYLRefresh
//
//  The iOS-style refresh header (flutter_easy_refresh's CupertinoHeader): a system activity indicator that appears and
//  turns with the pull and spins while refreshing.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshCupertinoHeader.swift` (docs/Swift-Migration.md, step 9), with the same
//       Objective-C API (`activityIndicator`).
//       Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration. Objective-C cannot subclass a Swift class:
//       subclasses are written in Swift.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshCupertinoHeader.swift`，docs/Swift-Migration.md 第 9 步），
//       Objective-C API 不变（`activityIndicator`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//       Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
//

#import "CYLRefreshHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The iOS-style header: a system activity indicator (`activityIndicator`) that fades and turns in while pulled and
 *      spins while refreshing, with no text (flutter_easy_refresh's `CupertinoHeader`). `colorAccent` colors the indicator.
 *      The class is Swift (`CYLRefreshCupertinoHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] iOS 风格的刷新头：系统菊花（`activityIndicator`）在下拉时淡入并转动，刷新时旋转，没有文字（对应 flutter_easy_refresh 的
 *      `CupertinoHeader`）。`colorAccent` 为菊花着色。
 *      该类用 Swift 编写（`CYLRefreshCupertinoHeader.swift`）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshCupertinoHeader;

NS_ASSUME_NONNULL_END
