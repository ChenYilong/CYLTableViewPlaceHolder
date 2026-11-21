//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Header/UIRefreshMaterialHeader.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshMaterialHeader.swift` (docs/Swift-Migration.md, step 8), with
//       the same Objective-C API (`colorSchemeColors`, `progressSize`). The `CYLRefreshMaterialSize` enum stays here.
//       Objective-C code that uses the class imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
//       generated Swift header; this header keeps the forward declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshMaterialHeader.swift`，docs/Swift-Migration.md 第 8 步），Objective-C API 不变
//       （`colorSchemeColors`、`progressSize`）。`CYLRefreshMaterialSize` 枚举保留在这里。使用该类的 Objective-C 代码请导入总头文件
//       `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。
//

#import "CYLRefreshDrawnHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The Material spinner's size (Android MaterialProgressDrawable's `DEFAULT` and `LARGE`).
 * [CN] Material 加载圈的尺寸（对应 Android MaterialProgressDrawable 的 `DEFAULT` 与 `LARGE`）。
 */
typedef NS_ENUM(NSInteger, CYLRefreshMaterialSize) {
    /*!
     * [EN] A 40-point circle (default). [CN] 40 点的圆（默认）。
     */
    CYLRefreshMaterialSizeDefault = 0,
    /*!
     * [EN] A 56-point circle. [CN] 56 点的圆。
     */
    CYLRefreshMaterialSizeLarge = 1,
};

/*!
 * [EN] The Material Design swipe-refresh spinner, floating in front of the content. The class is Swift
 *      (`CYLRefreshMaterialHeader.swift`); Objective-C code that messages it imports the umbrella header
 *      `CYLTableViewPlaceHolder.h`, which brings the generated Swift header.
 * [CN] Material Design 的下拉刷新圆圈，浮在内容前面。该类用 Swift 编写（`CYLRefreshMaterialHeader.swift`）；需要调用它的 Objective-C
 *      代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLRefreshMaterialHeader;

NS_ASSUME_NONNULL_END
