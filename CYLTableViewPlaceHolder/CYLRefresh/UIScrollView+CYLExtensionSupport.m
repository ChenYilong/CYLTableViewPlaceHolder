//
//  UIScrollView+CYLExtensionSupport.m
//  CYLRefresh
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The Objective-C half of `UIScrollView (CYLExtension)` (Swift since 2026-11-19, `UIScrollView+CYLExtension.swift`),
//      what Swift cannot express (docs/Swift-Migration.md, rule 6): `+load` (Swift has none), which hands Swift the writer
//      of the bottom, left and right insets, the reader of its depth (the Swift `CYLRefreshHeader` reads it through
//      `UIScrollView.cyl_isWritingSideInset`) and the `@try` / `@finally` guard of the header's own top-inset writes.
//      The writer keeps the depth right with `@try` / `@finally` when a `contentInset` observer throws an Objective-C
//      exception (Swift cannot catch one).
// [CN] `UIScrollView (CYLExtension)` 的 Objective-C 部分（自 2026-11-19 起用 Swift 编写，见 `UIScrollView+CYLExtension.swift`），即 Swift
//      无法表达的部分（docs/Swift-Migration.md 第 6 条）：`+load`（Swift 没有），它把下、左、右 inset 的写入函数、其嵌套深度的读取函数
//      （Swift 的 `CYLRefreshHeader` 通过 `UIScrollView.cyl_isWritingSideInset` 读取）以及刷新头写入顶部 inset 时的 `@try` / `@finally`
//      保护交给 Swift。写入函数用 `@try` / `@finally` 保证 `contentInset` 的观察者抛出 Objective-C 异常时深度仍然正确（Swift 无法捕获这种异常）。

#import <UIKit/UIKit.h>

// [EN] Depth of writes through cyl_insetB / cyl_insetL / cyl_insetR, which change one side and never the top (main
//      thread only, as UIKit). The header reads it to tell a footer's or trailer's write from a new top inset.
// [CN] 通过 cyl_insetB / cyl_insetL / cyl_insetR 写入的嵌套深度；这些写入只改变一侧、从不改变 top（与 UIKit 一样只在主线程）。
//      刷新头据此区分刷新尾或 trailer 的写入与新的顶部 inset。
static NSInteger CYLRefreshSideInsetWriteDepth = 0;

// [EN] Implemented in Swift (`UIScrollView+CYLExtension.swift`, internal); declared here only so `+load` can call it.
// [CN] 用 Swift 实现（`UIScrollView+CYLExtension.swift`，internal）；这里声明只为让 `+load` 调用。
@interface UIScrollView (CYLExtensionInstallation)
+ (void)cyl_installSideInsetWriter:(void (^)(UIScrollView *scrollView, UIEdgeInsets inset))writer
                            reader:(BOOL (^)(void))reader
                    exceptionGuard:(void (^)(dispatch_block_t body, dispatch_block_t cleanup))exceptionGuard;
@end

@interface UIScrollView (CYLExtensionLoad)
@end

@implementation UIScrollView (CYLExtensionLoad)

+ (void)load {
    [UIScrollView cyl_installSideInsetWriter:^(UIScrollView *scrollView, UIEdgeInsets inset) {
        CYLRefreshSideInsetWriteDepth += 1;
        @try {
            scrollView.contentInset = inset;
        } @finally {
            CYLRefreshSideInsetWriteDepth -= 1;
        }
    } reader:^BOOL {
        return CYLRefreshSideInsetWriteDepth > 0;
    } exceptionGuard:^(dispatch_block_t body, dispatch_block_t cleanup) {
        // [EN] The header's own top-inset writes (`updatingRefreshInset` is reset even when an observer throws).
        // [CN] 刷新头自己写入顶部 inset（即使观察者抛出异常，`updatingRefreshInset` 也会复位）。
        @try {
            body();
        } @finally {
            cleanup();
        }
    }];
}

@end
