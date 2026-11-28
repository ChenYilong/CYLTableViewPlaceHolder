//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshOriginalHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshOriginalHeader.swift` (docs/Swift-Migration.md, step 8), with the
//       same Objective-C API (`enableAutoRefresh`). Objective-C code that uses it imports the umbrella header
//       `CYLTableViewPlaceHolder.h`, which brings the generated Swift header; this header keeps the forward declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshOriginalHeader.swift`，docs/Swift-Migration.md 第 8 步），Objective-C API 不变（`enableAutoRefresh`）。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//

#import "CYLRefreshDrawnHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The original iOS 6 pull-to-refresh: a drop that stretches while pulling, snaps and turns into a spinner. The class is Swift
 *      (`CYLRefreshOriginalHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] iOS 6 原始的下拉刷新：下拉时被拉长的水滴，断开后变为菊花。该类用 Swift 编写（`CYLRefreshOriginalHeader.swift`）；需要调用它的 Objective-C 代码请导入
 *      总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshOriginalHeader;

NS_ASSUME_NONNULL_END
