//
//  CYLRefreshDrawnHeader+CYLStatusList.h
//  CYLRefresh
//
//  [EN] The variadic `-inStatus:` of `CYLRefreshDrawnHeader` (Swift since 2026-11-19, docs/Swift-Migration.md, step 9):
//       a variadic method cannot be `@objc` in Swift, so it stays an Objective-C category (rule 6), implemented in
//       `CYLRefreshDrawnHeaderSupport.m`. The umbrella header `CYLTableViewPlaceHolder.h` imports this header right after
//       the generated Swift header, which declares the class; import the umbrella header instead of this one. Swift
//       uses `isIn(statuses:)`.
//  [CN] `CYLRefreshDrawnHeader`（自 2026-11-19 起用 Swift 编写，docs/Swift-Migration.md 第 9 步）的可变参数方法 `-inStatus:`：可变参数
//       方法在 Swift 中不能标为 `@objc`，因此保留为 Objective-C 分类（第 6 条），实现在 `CYLRefreshDrawnHeaderSupport.m`。总头文件
//       `CYLTableViewPlaceHolder.h` 在生成的 Swift 头文件（其中声明该类）之后导入本头文件；请导入总头文件而不是本文件。Swift 使用
//       `isIn(statuses:)`。
//

#import "CYLRefreshDrawnHeader.h"
// [EN] The class comes from the generated Swift header, which the umbrella header imports (a header imported directly
//      gets it through the umbrella header; the umbrella header's own import of this file is then skipped).
// [CN] 该类来自生成的 Swift 头文件，由总头文件导入（直接导入本头文件时经由总头文件得到它；总头文件对本文件的导入随后被跳过）。
#import "CYLTableViewPlaceHolder.h"

// [EN] Only for Objective-C, once the generated Swift header exists (Swift sees `isIn(statuses:)`).
// [CN] 只供 Objective-C 使用，且生成的 Swift 头文件存在时才声明（Swift 使用 `isIn(statuses:)`）。
#if !defined(__swift__) && (__has_include(<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>) || __has_include("CYLTableViewPlaceHolder-Swift.h"))

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The variadic status check of the drawn headers, for Objective-C. [CN] 手绘刷新头的可变参数状态判断，供 Objective-C 使用。
 */
@interface CYLRefreshDrawnHeader (CYLStatusList)

/*!
 * [EN] YES when `status` is one of the listed phases; the list ends with 0. [CN] `status` 为所列阶段之一时为 YES；列表以 0 结尾。
 */
- (BOOL)inStatus:(CYLRefreshPhase)status, ... NS_SWIFT_UNAVAILABLE("Use isIn(statuses:)");

@end

NS_ASSUME_NONNULL_END

#endif
