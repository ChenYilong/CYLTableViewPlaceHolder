//
//  CYLNoresultTableViewController.h
//  红人在哪儿
//
//  Created by CHENYI LONG on 14/12/24.
//  Copyright (c) 2014年 Roman Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYLNoresultTableViewController : UITableViewController

@property (strong, nonatomic) UIView *emptyOverlay;

- (void) reloadData;
- (void) checkEmpty;
- (void)emptyOverlayClicked:(id)sender;

@end

