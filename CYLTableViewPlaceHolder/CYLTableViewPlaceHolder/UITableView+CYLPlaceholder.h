#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef UIView * _Nullable (^CYLTablePlaceholderViewBlock)(UITableView *tableView);
typedef void (^CYLTablePlaceholderNormalBlock)(UITableView *tableView);

@interface UITableView (CYLPlaceholder)

/*!
 * Pass nil to disable automatic placeholder handling and restore the normal state.
 * The blocks should not retain the table view or its owner strongly.
 */
- (void)cyl_placeholderViewBlock:(nullable CYLTablePlaceholderViewBlock)placeholderViewBlock;
- (void)cyl_placeholderViewBlock:(nullable CYLTablePlaceholderViewBlock)placeholderViewBlock
               backToNormalBlock:(nullable CYLTablePlaceholderNormalBlock)backToNormalBlock;

@end

NS_ASSUME_NONNULL_END
