//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/ValueAnimator.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.
//
//  [EN] Swift since 2026-11-19: the class, the `CYLRefreshValueAnimatorDelegate` protocol and the
//       `CYLRefreshAnimatorInterpolator` / `CYLRefreshAnimatorRepeatMode` enums (with their Objective-C case names
//       `AnimatorInterpolatorLinear`, ...) are in `CYLRefreshValueAnimator.swift` (docs/Swift-Migration.md, step 7), with
//       the same Objective-C API. Objective-C code that uses them imports the umbrella header `CYLTableViewPlaceHolder.h`,
//       which brings the generated Swift header; this header keeps the forward declarations and the block typedef.
//  [CN] 自 2026-11-19 起，该类、`CYLRefreshValueAnimatorDelegate` 协议与 `CYLRefreshAnimatorInterpolator` /
//       `CYLRefreshAnimatorRepeatMode` 枚举（Objective-C case 名 `AnimatorInterpolatorLinear` 等不变）用 Swift 编写
//       （`CYLRefreshValueAnimator.swift`，docs/Swift-Migration.md 第 7 步），Objective-C API 不变。使用它们的 Objective-C 代码请导入总头文件
//       `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）；本头文件保留前向声明与块类型。

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYLRefreshValueAnimator;
@protocol CYLRefreshValueAnimatorDelegate;

/*!
 * [EN] A custom easing curve: takes the linear progress (0 to 1) and returns the eased one.
 * [CN] 自定义缓动曲线：输入线性进度（0 到 1），返回缓动后的进度。
 */
typedef CGFloat(^CYLRefreshAnimatorInterpolatorBlock)(CGFloat);

NS_ASSUME_NONNULL_END
