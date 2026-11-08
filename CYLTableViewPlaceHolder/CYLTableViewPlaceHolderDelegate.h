//
//  CYLTableViewPlaceHolderDelegate.h
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 15/12/23.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CYLTableViewPlaceHolderDelegate <NSObject>

@required
/*!
 @brief  make an empty overlay view when the tableView is empty
 @return an empty overlay view
 */
- (UIView *)makePlaceHolderView;

@optional
/*!
 @brief enable tableView scroll when place holder view is showing, it is disabled by default.
 @return YES to enable scrolling, or NO to disable it.
 */
- (BOOL)enableScrollWhenPlaceHolderViewShowing;

/*!
 @brief Customize the placeholder frame in the table view's coordinate system.
 @discussion Return a frame below a table header or above a refresh footer when
 those views must remain visible. By default the placeholder fills the table.
 */
- (CGRect)frameForPlaceHolderViewInTableView:(UITableView *)tableView;

@end