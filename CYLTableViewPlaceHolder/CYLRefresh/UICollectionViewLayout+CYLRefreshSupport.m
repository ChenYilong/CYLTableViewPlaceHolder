//
//  UICollectionViewLayout+CYLRefreshSupport.m
//  CYLRefresh
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The Objective-C half of `UICollectionViewLayout (CYLRefresh)` (Swift since 2026-11-19,
//      `UICollectionViewLayout+CYLRefresh.swift`), what Swift cannot express (docs/Swift-Migration.md, rule 6): `+load`
//      (Swift has none), which calls the one Swift entry point that exchanges `finalizeCollectionViewUpdates` once.
// [CN] `UICollectionViewLayout (CYLRefresh)` 的 Objective-C 部分（自 2026-11-19 起用 Swift 编写，见
//      `UICollectionViewLayout+CYLRefresh.swift`），即 Swift 无法表达的部分（docs/Swift-Migration.md 第 6 条）：`+load`（Swift 没有），
//      它调用唯一的 Swift 入口，只交换一次 `finalizeCollectionViewUpdates`。

#import <UIKit/UIKit.h>

// [EN] Implemented in Swift (`UICollectionViewLayout+CYLRefresh.swift`, internal); declared here only so `+load` can call
//      it. [CN] 用 Swift 实现（`UICollectionViewLayout+CYLRefresh.swift`，internal）；这里声明只为让 `+load` 调用。
@interface UICollectionViewLayout (CYLRefreshInstallation)
+ (void)cyl_installFooterUpdateFix;
@end

@interface UICollectionViewLayout (CYLRefreshLoad)
@end

@implementation UICollectionViewLayout (CYLRefreshLoad)

+ (void)load {
    [UICollectionViewLayout cyl_installFooterUpdateFix];
}

@end
