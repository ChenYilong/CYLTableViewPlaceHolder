#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Returns the placeholder view to show while the collection view is empty, or nil to show none; called on the
 *      main queue after each reload or update that leaves it empty.
 * [CN] 返回集合视图为空时显示的占位视图，返回 nil 则不显示；每次刷新或更新后视图为空时在主队列调用。
 */
typedef UIView * _Nullable (^CYLCollectionPlaceholderViewBlock)(UICollectionView *collectionView);
/*!
 * [EN] Called when the placeholder is removed because the collection view has content again (or the placeholder is
 *      turned off), to restore the normal state.
 * [CN] 集合视图重新有内容（或关闭占位图）、占位图被移除时调用，用于恢复正常状态。
 */
typedef void (^CYLCollectionPlaceholderNormalBlock)(UICollectionView *collectionView);

// [EN] Implemented in Swift since 2026-11-19 (`UIScrollView+CYLPlaceholder.swift`, the same selectors). This declaration is
//      for Objective-C callers only: Swift reads the Swift extension itself (`__swift__` is defined while Swift imports
//      the header), so the two never meet. The block types above stay here for both.
// [CN] 自 2026-11-19 起用 Swift 实现（`UIScrollView+CYLPlaceholder.swift`，选择器不变）。这里的声明只供 Objective-C 调用方使用：Swift 直接
//      读取 Swift 扩展（Swift 导入头文件时定义了 `__swift__`），两者不会冲突。上面的 block 类型保留在这里，两者共用。
#ifndef __swift__
/*!
 * [EN] The automatic placeholder: once a block is set, the collection view shows its view whenever a reload or update
 *      leaves it with no items, and removes it when content comes back; no `cyl_reloadData` call is needed.
 * [CN] 自动占位图：设置 block 后，每当刷新或更新使集合视图没有item时显示其视图，有内容后移除；不需要调用 `cyl_reloadData`。
 */
@interface UICollectionView (CYLPlaceholder)

/*!
 * Pass nil to disable automatic placeholder handling and restore the normal state.
 * The blocks should not retain the collection view or its owner strongly.
 */
- (void)cyl_placeholderViewBlock:(nullable CYLCollectionPlaceholderViewBlock)placeholderViewBlock;
/*!
 * [EN] Like `cyl_placeholderViewBlock:`, and also sets the block called when the placeholder is
 *      removed (the collection view has content again); nil for both turns the automatic placeholder
 *      off.
 * [CN] 与 `cyl_placeholderViewBlock:` 相同，并设置占位图被移除（集合视图重新有内容）时调用的
 *      block；两者都为 nil 时关闭自动占位图。
 */
- (void)cyl_placeholderViewBlock:(nullable CYLCollectionPlaceholderViewBlock)placeholderViewBlock
               backToNormalBlock:(nullable CYLCollectionPlaceholderNormalBlock)backToNormalBlock;

@end
#endif

NS_ASSUME_NONNULL_END
