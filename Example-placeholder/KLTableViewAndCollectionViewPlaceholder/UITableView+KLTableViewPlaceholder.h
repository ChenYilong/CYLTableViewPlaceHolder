//
//  UITableView+KLTableViewPlaceholder.h
//  KLTableViewAndCollectionViewPlaceholder
//
//  Created by 柯磊 on 2017/2/24.
//  Copyright © 2017年 https://github.com/klaus01 All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIView * __nullable (^KLTableViewPlaceholderViewBlock)(UITableView * __nonnull tableView);
typedef void (^KLTableViewBackToNormalBlock)(UITableView * __nonnull tableView);

@interface UITableView (KLTableViewPlaceholder)

/**
 Call the placeholderViewBlock when the data is empty.
 
 placeholderViewBlock = nil is disabled, otherwise the null data display placeholder function is enabled.
 
 @param placeholderViewBlock Called when a placeholder needs to be displayed, returns a view.
 */
- (void)kl_placeholderViewBlock:(KLTableViewPlaceholderViewBlock __nullable)placeholderViewBlock;

/**
 Called placeholderViewBlock when the data is empty, and backToNormalBlock when the data is not empty.
 
 placeholderViewBlock = nil is disabled, otherwise the null data display placeholder function is enabled.
 
 @param placeholderViewBlock Called when a placeholder needs to be displayed, returns a view.
 @param backToNormalBlock Called when there is data
 */
- (void)kl_placeholderViewBlock:(KLTableViewPlaceholderViewBlock __nullable)placeholderViewBlock
              backToNormalBlock:(KLTableViewBackToNormalBlock __nullable)backToNormalBlock;

@end
