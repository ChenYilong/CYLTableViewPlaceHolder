//
//  UITableViewController+CYLTableViewPlaceHolder.h
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 15/12/23.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//
//  [EN] The category is Swift since 2026-11-19 (`UITableView+CYLTableViewPlaceHolder.swift`, the same selector). This
//       declaration is for Objective-C callers only: Swift reads the Swift extension itself (`__swift__` is defined while
//       Swift imports the header), so the two never meet.
//  [CN] 该分类自 2026-11-19 起用 Swift 编写（`UITableView+CYLTableViewPlaceHolder.swift`，选择器不变）。这里的声明只供 Objective-C 调用方
//       使用：Swift 直接读取 Swift 扩展（Swift 导入头文件时定义了 `__swift__`），两者不会冲突。
//

#import <UIKit/UIKit.h>

#ifndef __swift__
/*!
 * [EN] The legacy placeholder API, `cyl_reloadData` with `CYLTableViewPlaceHolderDelegate`; declared for Objective-C
 *      callers only, implemented in Swift.
 * [CN] 旧的占位图接口：`cyl_reloadData` 与 `CYLTableViewPlaceHolderDelegate`；只为
 *      Objective-C 调用方声明，用 Swift 实现。
 */
@interface UITableView (CYLTableViewPlaceHolder)

/*!
 * @brief just use this method to replace `reloadData` ,and it can help you to add or remove place holder view automatically
 * @attention this method has already reload the tableView,so do not reload tableView any more.
 */
- (void)cyl_reloadData;

@end
#endif
