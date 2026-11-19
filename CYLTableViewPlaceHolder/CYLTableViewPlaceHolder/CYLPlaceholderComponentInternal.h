//
//  CYLPlaceholderComponentInternal.h
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  [EN] Internal, not API: the two private members of `CYLPlaceholderComponent` (implemented in
//       `CYLPlaceholderScenario.m`, unchanged, still Objective-C) that `CYLPlaceholderStackView.swift` uses. This header
//       only lets the module's Swift files see them, so it is part of the module (the umbrella header imports it).
//       `NS_REFINED_FOR_SWIFT` gives them a `__` prefix in Swift, which hides them from code completion. Apps do not call
//       them.
//  [CN] 内部声明，不是 API：`CYLPlaceholderComponent` 的两个私有成员（实现在 `CYLPlaceholderScenario.m` 中，保持 Objective-C 且行为
//       不变），供 `CYLPlaceholderStackView.swift` 使用。本头文件只为让模块内的 Swift 文件看到它们，因此属于模块（总头文件导入它）。
//       `NS_REFINED_FOR_SWIFT` 使其在 Swift 中带 `__` 前缀，不出现在代码补全中。应用不应调用。
//

#import <Foundation/Foundation.h>
#import "CYLPlaceholderScenario.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The private members of a component that the stack view reads. [CN] 组件视图堆叠读取的组件私有成员。
 */
@interface CYLPlaceholderComponent (CYLStackInternal)

/*!
 * [EN] The factory that made the component: "item", "hint", "button" or "separator" (for the stack view's `hintLabel`,
 *      `titleLabel` and `button`, as Android's component kinds).
 * [CN] 创建该组件的工厂方法："item"、"hint"、"button" 或 "separator"（供组件视图堆叠的 `hintLabel`、`titleLabel` 与 `button` 使用，
 *      同 Android 的组件种类）。
 */
- (nullable NSString *)cyl_kind NS_REFINED_FOR_SWIFT;

/*!
 * [EN] Applies the shared component fields ("action", "interactionEnabled", "highlightStyle", "repeatCount", …), as a
 *      configuration's "overrides" do; NO, with `error`, when a value is invalid.
 * [CN] 应用组件的通用字段（"action"、"interactionEnabled"、"highlightStyle"、"repeatCount" 等），与配置中的 "overrides" 相同；值无效时
 *      返回 NO 并设置 `error`。
 */
- (BOOL)cyl_applyConfiguration:(NSDictionary<NSString *, id> *)dictionary
                         error:(NSError * _Nullable * _Nullable)error NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
