//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Fly/MountainView.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class is in `CYLRefreshMountainView.swift` (docs/Swift-Migration.md, step 7), with the same
//       Objective-C API. The macros below stay Objective-C. Objective-C code that uses it imports the umbrella header `CYLTableViewPlaceHolder.h`, which
//       brings the generated Swift header; this header keeps the forward declaration.
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLRefreshMountainView.swift`，docs/Swift-Migration.md 第 7 步），Objective-C API 不变。下面的宏仍为 Objective-C。使用它的
//       Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明。

#import <UIKit/UIKit.h>

/*!
 * [EN] The width of the main screen.
 * [CN] 主屏幕的宽度。
 */
#define CYLREFRESH_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

/*!
 * [EN] The vertical ratio of `rect` to the original 120-point design.
 * [CN] `rect` 相对原设计 120 点高度的纵向比例。
 */
#define CYLREFRESH_RATIO_Y(rect) (CGRectGetMaxY(rect) / 120.f)
/*!
 * [EN] The horizontal ratio of `rect` to the original 240-point design.
 * [CN] `rect` 相对原设计 240 点宽度的横向比例。
 */
#define CYLREFRESH_RATIO_X(rect) (CGRectGetMaxX(rect) / 240.f)

@class CYLRefreshMountainView;
