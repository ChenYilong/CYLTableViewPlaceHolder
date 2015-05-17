//
//  CYLNoresultTableViewController.h
//
//  Created by https://github.com/ChenYilong on 14/12/24.
//  Copyright (c) 2015年 http://weibo.com/luohanchenyilong/ . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYLNoresultTableViewController : UITableViewController

@property (strong, nonatomic) UIView *emptyOverlay;

- (void) reloadData;
- (void) checkEmpty;
- (void)emptyOverlayClicked:(id)sender;

@end

