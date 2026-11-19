//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshBezierCircleHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshBezierCircleHeader.swift` (docs/Swift-Migration.md, step 8), with the
//       same Objective-C API. Objective-C code that uses it imports the umbrella header
//       `CYLTableViewPlaceHolder.h`, which brings the generated Swift header; this header keeps the forward declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshBezierCircleHeader.swift`，docs/Swift-Migration.md 第 8 步），Objective-C API 不变。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//

#import "CYLRefreshDrawnHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A ball that drops out of a bezier wave and spins while refreshing (after "Pull Down To Refresh" on Dribbble). The class is Swift
 *      (`CYLRefreshBezierCircleHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 从贝塞尔波浪中落下的小球，刷新时旋转（参考 Dribbble 作品 “Pull Down To Refresh”）。该类用 Swift 编写（`CYLRefreshBezierCircleHeader.swift`）；需要调用它的 Objective-C 代码请导入
 *      总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshBezierCircleHeader;

NS_ASSUME_NONNULL_END
