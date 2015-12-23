//
//  UITableViewController+CYLEmptyReloader.m
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 (http://weibo.com/luohanchenyilong/) on 15/12/23.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//  For tableView

#import "UITableView+CYLTableViewPlaceHolder.h"
#import "CYLTableViewPlaceHolderDelegate.h"

#import <objc/runtime.h>

@interface UITableView ()

@property (nonatomic, assign) BOOL scrollWasEnabled;
@property (nonatomic, strong) UIView *placeHolderView;

@end

@implementation UITableView (CYLTableViewPlaceHolder)

- (BOOL)scrollWasEnabled {
    return objc_getAssociatedObject(self, @selector(scrollWasEnabled));
}

- (void)setScrollWasEnabled:(BOOL)scrollWasEnabled {
    NSNumber *scrollWasEnabledObject = [NSNumber numberWithBool:scrollWasEnabled];
    objc_setAssociatedObject(self, @selector(scrollWasEnabled), scrollWasEnabledObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)placeHolderView {
    return objc_getAssociatedObject(self, @selector(placeHolderView));
}

- (void)setPlaceHolderView:(UIView *)placeHolderView {
    objc_setAssociatedObject(self, @selector(placeHolderView), placeHolderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cyl_reloadData
{
    [self reloadData];
    [self cyl_checkEmpty];
}

- (void)cyl_checkEmpty
{
    BOOL isEmpty = YES;
    
    id<UITableViewDataSource> src = self.dataSource;
    NSInteger sections = 1;
    if ([src respondsToSelector: @selector(numberOfSectionsInTableView:)])
        sections = [src numberOfSectionsInTableView: self];
    for (int i =0; i<sections; ++i) {
        NSInteger rows = [src tableView:self numberOfRowsInSection:i];
        if (rows)
            isEmpty = NO;
    }
    
    if (!isEmpty != !self.placeHolderView) {
        if (isEmpty)
        {
            self.scrollWasEnabled = self.scrollEnabled;
            self.scrollEnabled = NO;
            if ([self respondsToSelector:@selector(makePlceHolederView)]) {
                self.placeHolderView = [self performSelector:@selector(makePlceHolederView)];
            } else if ( [self.delegate respondsToSelector:@selector(makePlceHolederView)]) {
                self.placeHolderView = [self.delegate performSelector:@selector(makePlceHolederView)];
            } else  {
                NSString *selectorName = NSStringFromSelector(_cmd);
                NSString *reason = [NSString stringWithFormat:@"You must implement makePlceHolederView method in your custom tableView or its delegate class if you want to use %@",selectorName];
                @throw [NSException exceptionWithName:NSGenericException
                                               reason:reason
                                             userInfo:nil];
            }
            self.placeHolderView.frame = ({
                CGRect frame = self.placeHolderView.frame;
                frame.origin.x = 0;
                frame.origin.y = 0;
                frame.size.width = self.frame.size.width;
                frame.size.height = self.frame.size.height;
                frame;
            });
            [self addSubview:self.placeHolderView];
        } else {
            self.scrollEnabled = self.scrollWasEnabled;
            [self.placeHolderView removeFromSuperview];
            [[self.placeHolderView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
            self.placeHolderView = nil;
        }
    } else if (isEmpty) {
        // Make sure it is still above all siblings.
        [self.placeHolderView removeFromSuperview];
        [[self.placeHolderView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [self addSubview:self.placeHolderView];
    }
}

@end
