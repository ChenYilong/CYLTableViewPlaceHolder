//
//  UITableView+KLTableViewPlaceholder.m
//  KLTableViewAndCollectionViewPlaceholder
//
//  Created by 柯磊 on 2017/2/24.
//  Copyright © 2017年 https://github.com/klaus01 All rights reserved.
//

#import "UITableView+KLTableViewPlaceholder.h"
#import "KLUtility.h"
#import <objc/runtime.h>

@implementation UITableView (KLTableViewPlaceholder)

+ (void)load {
    swizzleMethod(self, @selector(beginUpdates), @selector(kl_beginUpdates));
    swizzleMethod(self, @selector(endUpdates), @selector(kl_endUpdates));
    swizzleMethod(self, @selector(reloadData), @selector(kl_reloadData));
    swizzleMethod(self, @selector(insertSections:withRowAnimation:), @selector(kl_insertSections:withRowAnimation:));
    swizzleMethod(self, @selector(deleteSections:withRowAnimation:), @selector(kl_deleteSections:withRowAnimation:));
    swizzleMethod(self, @selector(reloadSections:withRowAnimation:), @selector(kl_reloadSections:withRowAnimation:));
    swizzleMethod(self, @selector(insertRowsAtIndexPaths:withRowAnimation:), @selector(kl_insertRowsAtIndexPaths:withRowAnimation:));
    swizzleMethod(self, @selector(deleteRowsAtIndexPaths:withRowAnimation:), @selector(kl_deleteRowsAtIndexPaths:withRowAnimation:));
}

#pragma mark - public methods

- (void)kl_placeholderViewBlock:(KLTableViewPlaceholderViewBlock _Nullable)placeholderViewBlock {
    [self kl_placeholderViewBlock:placeholderViewBlock backToNormalBlock:nil];
}

- (void)kl_placeholderViewBlock:(KLTableViewPlaceholderViewBlock _Nullable)placeholderViewBlock
              backToNormalBlock:(KLTableViewBackToNormalBlock _Nullable)backToNormalBlock {
    self.kl_placeholderViewBlock = placeholderViewBlock;
    self.kl_backToNormalBlock = backToNormalBlock;
}

#pragma mark - property methods

- (KLTableViewPlaceholderViewBlock)kl_placeholderViewBlock {
    return objc_getAssociatedObject(self, @selector(kl_placeholderViewBlock));
}

- (void)setKl_placeholderViewBlock:(KLTableViewPlaceholderViewBlock)kl_placeholderViewBlock {
    objc_setAssociatedObject(self, @selector(kl_placeholderViewBlock), kl_placeholderViewBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (kl_placeholderViewBlock == nil) {
        [self kl_removePlaceholderView];
    }
}

- (KLTableViewBackToNormalBlock)kl_backToNormalBlock {
    return objc_getAssociatedObject(self, @selector(kl_backToNormalBlock));
}

- (void)setKl_backToNormalBlock:(KLTableViewBackToNormalBlock)kl_backToNormalBlock {
    objc_setAssociatedObject(self, @selector(kl_backToNormalBlock), kl_backToNormalBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIView *)kl_placeholderView {
    return objc_getAssociatedObject(self, @selector(kl_placeholderView));
}

- (void)setKl_placeholderView:(UIView *)kl_placeholderView {
    objc_setAssociatedObject(self, @selector(kl_placeholderView), kl_placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)kl_updateCount {
    NSNumber *number = objc_getAssociatedObject(self, @selector(kl_updateCount));
    return number ? number.integerValue : 0;
}

- (void)setKl_updateCount:(NSInteger)kl_updateCount {
    objc_setAssociatedObject(self, @selector(kl_updateCount), @(kl_updateCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - private methods

- (void)kl_removePlaceholderView {
    if (self.kl_placeholderView) {
        [self.kl_placeholderView removeFromSuperview];
        self.kl_placeholderView = nil;
        self.kl_backToNormalBlock ? self.kl_backToNormalBlock(self) : nil;
    }
}

- (void)kl_checkEmpty {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.kl_updateCount > 0 || self.kl_placeholderViewBlock == nil) {
            return;
        }
        
        BOOL isEmpty = YES;
        
        id<UITableViewDataSource> dataSource = self.dataSource;
        NSInteger sections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:self];
        }
        
        for (NSInteger i = 0; i < sections; i++) {
            NSInteger rows = [dataSource tableView:self numberOfRowsInSection:i];
            if (rows) {
                isEmpty = NO;
                break;
            }
        }
        
        if (isEmpty) {
            UIView *placeholderView = self.kl_placeholderViewBlock ? self.kl_placeholderViewBlock(self) : nil;
            if (self.kl_placeholderView != placeholderView) {
                [self.kl_placeholderView removeFromSuperview];
                self.kl_placeholderView = placeholderView;
                if (placeholderView) {
                    placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
                    [self addSubview:placeholderView];
                    NSDictionary *views = @{@"view": placeholderView, @"superview": self};
                    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view(==superview)]|" options:0 metrics:nil views:views]];
                    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view(==superview)]|" options:0 metrics:nil views:views]];
                }
            }
        } else {
            [self kl_removePlaceholderView];
        }
    });
}

#pragma mark - hook methods

- (void)kl_beginUpdates {
    [self kl_beginUpdates];
    self.kl_updateCount++;
}

- (void)kl_endUpdates {
    [self kl_endUpdates];
    NSInteger updateCount = self.kl_updateCount - 1;
    if (updateCount <= 0) {
        self.kl_updateCount = 0;
        [self kl_checkEmpty];
    }
}

- (void)kl_reloadData {
    [self kl_reloadData];
    [self kl_checkEmpty];
}

- (void)kl_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self kl_insertSections:sections withRowAnimation:animation];
    [self kl_checkEmpty];
}

- (void)kl_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self kl_deleteSections:sections withRowAnimation:animation];
    [self kl_checkEmpty];
}

- (void)kl_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self kl_reloadSections:sections withRowAnimation:animation];
    [self kl_checkEmpty];
}

- (void)kl_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self kl_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self kl_checkEmpty];
}

- (void)kl_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self kl_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self kl_checkEmpty];
}

@end
