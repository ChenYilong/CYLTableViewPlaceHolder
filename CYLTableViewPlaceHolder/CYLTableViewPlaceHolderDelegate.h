//
//  CYLTableViewPlaceHolderDelegate.h
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 (http://weibo.com/luohanchenyilong/) on 15/12/23.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//

@protocol CYLTableViewPlaceHolderDelegate <NSObject>

@required
/*!
 @brief  make an empty overlay view when the tableView is empty
 @return an empty overlay view
 */
- (UIView *)makePlaceHolderView;

@optional
/*!
 @brief  enable tableView scroll or not when place holder view is showing,it is disabled by default.
 @return enable tableView scroll or not
 */
- (BOOL)enableScrollWhenPlaceHolderViewShowing;

@end