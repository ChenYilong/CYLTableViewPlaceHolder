//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshStoreHouseHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshStoreHouseHeader.swift` (docs/Swift-Migration.md, step 8), with the
//       same Objective-C API (`lineWidth`, `enableReverseFlash`, `enableFadeAnimation`, `+newWithString:…`, `-initLinesWithString:…`,
//       `-initLinesWithArray:…`; Swift `init(string:…)`, `setLines(…)`). Objective-C code that uses it imports the umbrella header
//       `CYLTableViewPlaceHolder.h`, which brings the generated Swift header; this header keeps the forward declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshStoreHouseHeader.swift`，docs/Swift-Migration.md 第 8 步），Objective-C API 不变（`lineWidth`、`enableReverseFlash`、`enableFadeAnimation`、`+newWithString:…`、`-initLinesWithString:…`、
//       `-initLinesWithArray:…`；Swift 中为 `init(string:…)`、`setLines(…)`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//

#import "CYLRefreshDrawnHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Text drawn as line segments that gather while pulling and flash while refreshing (after CRefreshLayout StoreHouse). The class is Swift
 *      (`CYLRefreshStoreHouseHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 由线段组成的文字，下拉时聚拢，刷新时闪烁（参考 CRefreshLayout StoreHouse）。该类用 Swift 编写（`CYLRefreshStoreHouseHeader.swift`）；需要调用它的 Objective-C 代码请导入
 *      总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshStoreHouseHeader;

NS_ASSUME_NONNULL_END
