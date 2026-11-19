//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshGameHitBlockHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshGameHitBlockHeader.swift` (docs/Swift-Migration.md, step 8), with the
//       same Objective-C API. Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`,
//       which brings the generated Swift header; this header keeps the forward declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshGameHitBlockHeader.swift`，docs/Swift-Migration.md 第 8 步），Objective-C API 不变。
//       使用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//

#import "CYLRefreshGameHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A brick-breaker game played while refreshing (after FunGameRefresh HitBlock); drag to move the paddle.
 *      The class is Swift (`CYLRefreshGameHitBlockHeader.swift`); Objective-C code that messages it imports
 *      the umbrella header `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] 刷新时玩的打砖块游戏（参考 FunGameRefresh HitBlock），拖动来移动挡板。
 *      该类用 Swift 编写（`CYLRefreshGameHitBlockHeader.swift`）；需要调用它的 Objective-C 代码请导入总头文件
 *      `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshGameHitBlockHeader;

NS_ASSUME_NONNULL_END
