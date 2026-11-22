//
//  UICollectionViewLayout+CYLRefresh.swift
//
//  该类是用来解决 Footer 在底端加载完成后, 仍停留在原处的 bug.
//  此问题出现在 iOS 14 及以下系统上.
//  Reference: https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/1552
//
//  Created by jiasong on 2021/11/15.
//  Copyright © 2021 小码哥. All rights reserved.
//

// [EN] Keeps a collection view's footer in place after batch updates, in Swift since 2026-11-19 (docs/Swift-Migration.md,
//      step 6). `+load` stays in `UICollectionViewLayout+CYLRefreshSupport.m` (Swift has none, rule 6) and calls
//      `cylInstallFooterUpdateFix()` below, which exchanges `finalizeCollectionViewUpdates` once, as
//      `CYLRefreshExchangeImplementations` did.
// [CN] 批量更新后让集合视图的刷新尾保持正确位置，自 2026-11-19 起用 Swift 编写（docs/Swift-Migration.md 第 6 步）。`+load` 保留在
//      `UICollectionViewLayout+CYLRefreshSupport.m`（Swift 没有，第 6 条），它调用下面的 `cylInstallFooterUpdateFix()`，与
//      `CYLRefreshExchangeImplementations` 一样只交换一次 `finalizeCollectionViewUpdates`。

import UIKit
import ObjectiveC

extension UICollectionViewLayout {

    // [EN] Exchanges the methods once (a `static let` runs its initializer once, as `dispatch_once` did).
    // [CN] 只交换一次（`static let` 的初始化只执行一次，与 `dispatch_once` 相同）。
    private static let cylFooterUpdateFixInstallation: Void = {
        let cls: AnyClass = UICollectionViewLayout.self
        let originalSelector = #selector(UICollectionViewLayout.finalizeCollectionViewUpdates)
        let newSelector = #selector(UICollectionViewLayout.cylFinalizeCollectionViewUpdates)
        guard let newMethod = class_getInstanceMethod(cls, newSelector) else { return }
        let originalMethod = class_getInstanceMethod(cls, originalSelector)
        if class_addMethod(cls, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)) {
            // [EN] The original was not implemented here: the replacement gets the original's implementation, or an empty
            //      one. [CN] 原方法不在本类中实现：替换方法获得原实现，没有时为空实现。
            let emptyBlock: @convention(block) (AnyObject) -> Void = { _ in }
            let implementation = originalMethod.map { method_getImplementation($0) }
                ?? imp_implementationWithBlock(emptyBlock)
            let typeEncoding = originalMethod.flatMap { method_getTypeEncoding($0) }
            if let typeEncoding = typeEncoding {
                class_replaceMethod(cls, newSelector, implementation, typeEncoding)
            } else {
                class_replaceMethod(cls, newSelector, implementation, "v@:")
            }
        } else if let originalMethod = originalMethod {
            method_exchangeImplementations(originalMethod, newMethod)
        }
    }()

    // [EN] The entry point of `+load` (`UICollectionViewLayout+CYLRefreshSupport.m`, which declares this selector).
    // [CN] `+load` 的入口（`UICollectionViewLayout+CYLRefreshSupport.m` 声明了该选择器）。
    @objc(cyl_installFooterUpdateFix)
    static func cylInstallFooterUpdateFix() {
        _ = cylFooterUpdateFixInstallation
    }

    // [EN] Runs the original (exchanged), then tells the footer about a new content size at once, without animation.
    // [CN] 先执行原方法（已交换），内容尺寸改变时立即无动画地通知刷新尾。
    @objc dynamic func cylFinalizeCollectionViewUpdates() {
        cylFinalizeCollectionViewUpdates()

        guard let collectionView = collectionView, let footer = collectionView.cylFooter else { return }
        let newSize = collectionViewContentSize
        let oldSize = collectionView.contentSize
        if newSize != oldSize {
            let changed: [AnyHashable: Any] = [
                NSKeyValueChangeKey.newKey: NSValue(cgSize: newSize),
                NSKeyValueChangeKey.oldKey: NSValue(cgSize: oldSize)
            ]
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            footer.scrollViewContentSizeDidChange(changed)
            CATransaction.commit()
        }
    }
}
