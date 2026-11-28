//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshPhoenixHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshPhoenixHeader.swift` (docs/Swift-Migration.md, step 8), with the
//       same Objective-C API. Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which
//       brings the generated Swift header; this header keeps the forward declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshPhoenixHeader.swift`，docs/Swift-Migration.md 第 8 步），Objective-C API 不变。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//

#import "CYLRefreshDrawnHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A sun rising over a town (after Yalantis Phoenix). The class is Swift (`CYLRefreshPhoenixHeader.swift`); Objective-C
 *      code that messages it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the generated Swift
 *      header.
 * [CN] 城市上空升起的太阳（参考 Yalantis Phoenix）。该类用 Swift 编写（`CYLRefreshPhoenixHeader.swift`）；需要调用它的 Objective-C 代码请导入总头文件
 *      `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshPhoenixHeader;

NS_ASSUME_NONNULL_END
