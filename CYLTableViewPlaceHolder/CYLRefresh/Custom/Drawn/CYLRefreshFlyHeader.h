//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshFlyHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshFlyHeader.swift` (docs/Swift-Migration.md, step 8), with the
//       same Objective-C API (`mountainView`, `flyView`, `floatView`). Objective-C code that uses it imports the umbrella
//       header `CYLTableViewPlaceHolder.h`, which brings the generated Swift header; this header keeps the forward
//       declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshFlyHeader.swift`，docs/Swift-Migration.md 第 8 步），Objective-C API 不变
//       （`mountainView`、`flyView`、`floatView`）。使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的
//       Swift 头文件）；本头文件保留前向声明。
//

#import "CYLRefreshDrawnHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A paper plane over mountains that flies off while refreshing (after FlyRefresh). The class is Swift
 *      (`CYLRefreshFlyHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 山上的纸飞机，刷新时飞走（参考 FlyRefresh）。该类用 Swift 编写（`CYLRefreshFlyHeader.swift`）；需要调用它的 Objective-C 代码请导入
 *      总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshFlyHeader;

NS_ASSUME_NONNULL_END
