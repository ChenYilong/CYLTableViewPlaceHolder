//
//  UICollectionViewLayout+CYLRefresh.h
//
//  该类是用来解决 Footer 在底端加载完成后, 仍停留在原处的 bug.
//  此问题出现在 iOS 14 及以下系统上.
//  Reference: https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/1552
//
//  Created by jiasong on 2021/11/15.
//  Copyright © 2021 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

// [EN] Implemented in Swift since 2026-11-19 (`UICollectionViewLayout+CYLRefresh.swift`; `+load` in
//      `UICollectionViewLayout+CYLRefreshSupport.m`). The category declares no API.
// [CN] 自 2026-11-19 起用 Swift 实现（`UICollectionViewLayout+CYLRefresh.swift`；`+load` 在
//      `UICollectionViewLayout+CYLRefreshSupport.m`）。该分类不声明 API。

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Keeps a collection view's footer in place after batch updates: when `finalizeCollectionViewUpdates` changes
 *      the content size, the footer is told at once, without animation (installed by method swizzling at load time;
 *      no API).
 * [CN] 批量更新后让集合视图的刷新尾保持正确位置：`finalizeCollectionViewUpdates`
 *      改变内容尺寸时立即无动画地通知刷新尾（在加载时通过方法交换安装；没有 API）。
 */
@interface UICollectionViewLayout (CYLRefresh)

@end

NS_ASSUME_NONNULL_END
