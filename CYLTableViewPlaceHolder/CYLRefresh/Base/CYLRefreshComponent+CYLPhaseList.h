//
//  CYLRefreshComponent+CYLPhaseList.h
//  CYLRefresh
//
//  [EN] The variadic `-isInPhases:` of `CYLRefreshComponent` (Swift since 2026-11-20, docs/Swift-Migration.md, step 12):
//       a variadic method cannot be `@objc` in Swift, so it stays an Objective-C category (rule 6), implemented in
//       `CYLRefreshComponentSupport.m`. The umbrella header `CYLTableViewPlaceHolder.h` imports this header right after
//       the generated Swift header, which declares the class; import the umbrella header instead of this one. Swift
//       uses `isIn(phases:)`.
//  [CN] `CYLRefreshComponent`（自 2026-11-20 起用 Swift 编写，docs/Swift-Migration.md 第 12 步）的可变参数方法 `-isInPhases:`：可变参数
//       方法在 Swift 中不能标为 `@objc`，因此保留为 Objective-C 分类（第 6 条），实现在 `CYLRefreshComponentSupport.m`。总头文件
//       `CYLTableViewPlaceHolder.h` 在生成的 Swift 头文件（其中声明该类）之后导入本头文件；请导入总头文件而不是本文件。Swift 使用
//       `isIn(phases:)`。
//

#import "CYLRefreshComponent.h"
// [EN] The class comes from the generated Swift header, which the umbrella header imports (a header imported directly
//      gets it through the umbrella header; the umbrella header's own import of this file is then skipped).
// [CN] 该类来自生成的 Swift 头文件，由总头文件导入（直接导入本头文件时经由总头文件得到它；总头文件对本文件的导入随后被跳过）。
#import "CYLTableViewPlaceHolder.h"

// [EN] Only for Objective-C, once the generated Swift header exists (Swift sees `isIn(phases:)`).
// [CN] 只供 Objective-C 使用，且生成的 Swift 头文件存在时才声明（Swift 使用 `isIn(phases:)`）。
#if !defined(__swift__) && (__has_include(<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>) || __has_include("CYLTableViewPlaceHolder-Swift.h"))

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The variadic phase check of the refresh controls, for Objective-C. [CN] 刷新控件的可变参数阶段判断，供 Objective-C 使用。
 */
@interface CYLRefreshComponent (CYLPhaseList)

/*!
 * [EN] The same as `isInAnyPhase:` with a list of phases ending in 0, like the CYLRefresh styles' `inStatus:`.
 * [CN] 与 `isInAnyPhase:` 相同，参数为以 0 结尾的阶段列表，与 CYLRefresh styles 的 `inStatus:` 相同。
 */
- (BOOL)isInPhases:(CYLRefreshPhase)phase, ... NS_SWIFT_UNAVAILABLE("Use isIn(phases:)");

@end

NS_ASSUME_NONNULL_END

#endif
