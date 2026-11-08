#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef UIView * _Nullable (^CYLCollectionPlaceholderViewBlock)(UICollectionView *collectionView);
typedef void (^CYLCollectionPlaceholderNormalBlock)(UICollectionView *collectionView);

@interface UICollectionView (CYLPlaceholder)

/// Pass nil to disable automatic placeholder handling and restore the normal state.
/// The blocks should not retain the collection view or its owner strongly.
- (void)cyl_placeholderViewBlock:(nullable CYLCollectionPlaceholderViewBlock)placeholderViewBlock;
- (void)cyl_placeholderViewBlock:(nullable CYLCollectionPlaceholderViewBlock)placeholderViewBlock
               backToNormalBlock:(nullable CYLCollectionPlaceholderNormalBlock)backToNormalBlock;

@end

NS_ASSUME_NONNULL_END
