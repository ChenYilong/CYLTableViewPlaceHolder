//
//  CYLPlaceholderVisibleArea.h
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  [EN] Internal, not API: the C functions of `UIScrollView+CYLPlaceholder.m` (the automatic placeholder and the visible
//       area above the keyboard) that the legacy delegate API (`UITableView+CYLTableViewPlaceHolder.swift`) calls. They
//       stay in Objective-C with C linkage, unchanged; this header only lets the module's Swift files see them, so it is
//       part of the module (the umbrella header imports it). `NS_REFINED_FOR_SWIFT` gives them a `__` prefix in Swift,
//       which hides them from code completion. Apps do not call them.
//  [CN] 内部声明，不是 API：`UIScrollView+CYLPlaceholder.m` 中的 C 函数（自动占位图与键盘上方的可见区域），供旧的委托接口
//       （`UITableView+CYLTableViewPlaceHolder.swift`）调用。它们保持 C 链接、留在 Objective-C 中且行为不变；本头文件只为让模块内的 Swift
//       文件看到它们，因此属于模块（总头文件导入它）。`NS_REFINED_FOR_SWIFT` 使其在 Swift 中带 `__` 前缀，不出现在代码补全中。应用不应调用。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Whether the scroll view uses the automatic placeholder (`cyl_placeholderProvider` and friends).
 * [CN] 滚动视图是否使用自动占位图（`cyl_placeholderProvider` 等）。
 */
FOUNDATION_EXPORT BOOL CYLAutomaticPlaceholderEnabled(UIScrollView *scrollView) NS_REFINED_FOR_SWIFT;

/*!
 * [EN] Brings the placeholder to the front, then keeps refresh controls above it (issue #8).
 * [CN] 把占位图移到最前，再让刷新控件位于其上（issue #8）。
 */
FOUNDATION_EXPORT void CYLBringPlaceholderToFront(UIScrollView *scrollView, UIView *placeholder) NS_REFINED_FOR_SWIFT;

/*!
 * [EN] How much of the scroll view a placeholder leaves free: at the bottom, the part the keyboard covers.
 * [CN] 占位图在滚动视图中留出的距离：底部为键盘遮住的部分。
 */
FOUNDATION_EXPORT UIEdgeInsets CYLPlaceholderVisibleInsets(UIScrollView *scrollView) NS_REFINED_FOR_SWIFT;

/*!
 * [EN] Starts tracking the keyboard's frame once (also started in +load of the UITableView category).
 * [CN] 开始跟踪键盘 frame，只执行一次（UITableView 分类的 +load 中也会启动）。
 */
FOUNDATION_EXPORT void CYLPlaceholderStartTrackingKeyboard(void) NS_REFINED_FOR_SWIFT;

/*!
 * [EN] Posted after the keyboard's frame changes, so shown placeholders frame themselves above it again.
 * [CN] 键盘 frame 变化后发出，已显示的占位图据此重新放在键盘上方。
 */
FOUNDATION_EXPORT NSNotificationName const CYLPlaceholderVisibleAreaDidChangeNotification NS_REFINED_FOR_SWIFT;

NS_ASSUME_NONNULL_END
