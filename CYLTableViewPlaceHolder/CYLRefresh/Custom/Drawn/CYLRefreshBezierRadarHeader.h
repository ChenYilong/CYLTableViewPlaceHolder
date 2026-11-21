//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshBezierRadarHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshBezierRadarHeader.swift` (docs/Swift-Migration.md, step 9), with the
//       same Objective-C API. Objective-C code that uses it imports the umbrella header
//       `CYLTableViewPlaceHolder.h`, which brings the generated Swift header; this header keeps the forward declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshBezierRadarHeader.swift`，docs/Swift-Migration.md 第 9 步），Objective-C API 不变。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//

#import "CYLRefreshDrawnHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A bezier wave that turns into a radar scan while refreshing (after "Pull To Refresh" on Dribbble). The class is Swift
 *      (`CYLRefreshBezierRadarHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 贝塞尔波浪，刷新时变为雷达扫描（参考 Dribbble 作品 “Pull To Refresh”）。该类用 Swift 编写（`CYLRefreshBezierRadarHeader.swift`）；需要调用它的
 *      Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshBezierRadarHeader;

NS_ASSUME_NONNULL_END
