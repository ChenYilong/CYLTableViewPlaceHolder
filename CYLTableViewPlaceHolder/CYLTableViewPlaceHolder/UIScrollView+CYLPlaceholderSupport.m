//
//  UIScrollView+CYLPlaceholderSupport.m
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The Objective-C half of the automatic placeholder (Swift since 2026-11-19, `UIScrollView+CYLPlaceholder.swift`),
//      what Swift cannot express (docs/Swift-Migration.md, rule 6): `+load` (Swift has none), which calls the one Swift
//      entry point, and the `@try` / `@finally` it hands over, so the batch depth stays right when a batch update throws
//      an Objective-C exception (Swift cannot catch one).
// [CN] 自动占位图的 Objective-C 部分（自 2026-11-19 起用 Swift 编写，见 `UIScrollView+CYLPlaceholder.swift`），即 Swift 无法表达的部分
//      （docs/Swift-Migration.md 第 6 条）：`+load`（Swift 没有），它调用唯一的 Swift 入口，并传入 `@try` / `@finally`，使批量更新抛出
//      Objective-C 异常时批量深度仍然正确（Swift 无法捕获这种异常）。

#import <UIKit/UIKit.h>

// [EN] Implemented in Swift (`UIScrollView+CYLPlaceholder.swift`, internal); declared here only so `+load` can call it.
// [CN] 用 Swift 实现（`UIScrollView+CYLPlaceholder.swift`，internal）；这里声明只为让 `+load` 调用。
@interface UIScrollView (CYLPlaceholderInstallation)
+ (void)cyl_ph_installAutomaticPlaceholderWithExceptionGuard:(void (^)(dispatch_block_t body, dispatch_block_t cleanup))exceptionGuard;
@end

@interface UIScrollView (CYLPlaceholderLoad)
@end

@implementation UIScrollView (CYLPlaceholderLoad)

+ (void)load {
    // [EN] Swizzles UITableView and UICollectionView once and tracks the keyboard from launch: a placeholder that first
    //      appears while the keyboard is already up (a search with no results) must know where it is.
    // [CN] 只交换一次 UITableView 与 UICollectionView 的方法，并从启动起跟踪键盘：在键盘已显示时才首次出现的占位图（无结果的搜索）也要知道键盘位置。
    [UIScrollView cyl_ph_installAutomaticPlaceholderWithExceptionGuard:^(dispatch_block_t body, dispatch_block_t cleanup) {
        @try {
            body();
        } @finally {
            cleanup();
        }
    }];
}

@end
