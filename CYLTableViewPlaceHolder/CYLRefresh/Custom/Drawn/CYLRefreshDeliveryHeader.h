//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshDeliveryHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshDeliveryHeader.swift` (docs/Swift-Migration.md, step 8), with the
//       same Objective-C API. Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which
//       brings the generated Swift header; this header keeps the forward declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshDeliveryHeader.swift`，docs/Swift-Migration.md 第 8 步），Objective-C API 不变。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//

#import "CYLRefreshDrawnHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A parcel on an umbrella drifting over a town; it is delivered while refreshing (after "Refresh your
 *      delivery"). The class is Swift (`CYLRefreshDeliveryHeader.swift`); Objective-C
 *      code that messages it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the generated Swift
 *      header.
 * [CN] 撑着伞的包裹飘过城市，刷新时送出（参考 “Refresh your delivery”）。该类用 Swift 编写（`CYLRefreshDeliveryHeader.swift`）；需要调用它的 Objective-C 代码请导入总头文件
 *      `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshDeliveryHeader;

NS_ASSUME_NONNULL_END
