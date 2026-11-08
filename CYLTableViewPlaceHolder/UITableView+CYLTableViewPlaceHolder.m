//
//  UITableViewController+CYLEmptyReloader.m
//  CYLNoResultTableViewController
//
//  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 15/12/23.
//  Copyright © 2015年 https://github.com/ChenYilong . All rights reserved.
//

#import "UITableView+CYLTableViewPlaceHolder.h"
#import "CYLTableViewPlaceHolderDelegate.h"

#import <objc/runtime.h>

@interface UITableView ()

@property (nonatomic, assign) BOOL scrollWasEnabled;
@property (nonatomic, strong) UIView *placeHolderView;

@end

@implementation UITableView (CYLTableViewPlaceHolder)

- (BOOL)scrollWasEnabled {
    NSNumber *scrollWasEnabledObject = objc_getAssociatedObject(self, @selector(scrollWasEnabled));
    return [scrollWasEnabledObject boolValue];
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

- (void)cyl_reloadData {
    [self reloadData];
    [self cyl_checkEmpty];
}

- (void)cyl_checkEmpty {
    BOOL isEmpty = YES;

    id<UITableViewDataSource> src = self.dataSource;
    NSInteger sections = 1;
    if ([src respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sections = [src numberOfSectionsInTableView:self];
    }
    for (NSInteger i = 0; i < sections; ++i) {
        NSInteger rows = [src tableView:self numberOfRowsInSection:i];
        if (rows > 0) {
            isEmpty = NO;
            break;
        }
    }

    if (!isEmpty) {
        if (self.placeHolderView) {
            self.scrollEnabled = self.scrollWasEnabled;
            [self.placeHolderView removeFromSuperview];
            self.placeHolderView = nil;
        }
        return;
    }

    id<CYLTableViewPlaceHolderDelegate> provider = nil;
    if ([self respondsToSelector:@selector(makePlaceHolderView)]) {
        provider = (id<CYLTableViewPlaceHolderDelegate>)self;
    } else if ([self.delegate respondsToSelector:@selector(makePlaceHolderView)]) {
        provider = (id<CYLTableViewPlaceHolderDelegate>)self.delegate;
    } else if ([src respondsToSelector:@selector(makePlaceHolderView)]) {
        provider = (id<CYLTableViewPlaceHolderDelegate>)src;
    }

    UIView *view = [provider makePlaceHolderView];
    if (!view) {
        NSLog(@"CYLTableViewPlaceHolder: makePlaceHolderView must return a view when the table is empty.");
        if (self.placeHolderView) {
            self.scrollEnabled = self.scrollWasEnabled;
            [self.placeHolderView removeFromSuperview];
            self.placeHolderView = nil;
        }
        return;
    }

    if (!self.placeHolderView) {
        self.scrollWasEnabled = self.scrollEnabled;
        id<CYLTableViewPlaceHolderDelegate> scrollProvider = nil;
        if ([self respondsToSelector:@selector(enableScrollWhenPlaceHolderViewShowing)]) {
            scrollProvider = (id<CYLTableViewPlaceHolderDelegate>)self;
        } else if ([self.delegate respondsToSelector:@selector(enableScrollWhenPlaceHolderViewShowing)]) {
            scrollProvider = (id<CYLTableViewPlaceHolderDelegate>)self.delegate;
        } else if ([src respondsToSelector:@selector(enableScrollWhenPlaceHolderViewShowing)]) {
            scrollProvider = (id<CYLTableViewPlaceHolderDelegate>)src;
        }
        self.scrollEnabled = scrollProvider ? [scrollProvider enableScrollWhenPlaceHolderViewShowing] : NO;
    } else if (self.placeHolderView != view) {
        [self.placeHolderView removeFromSuperview];
    }
    self.placeHolderView = view;
    if ([provider respondsToSelector:@selector(frameForPlaceHolderViewInTableView:)]) {
        view.frame = [provider frameForPlaceHolderViewInTableView:self];
    } else {
        view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    if (view.superview != self) {
        [self addSubview:view];
    }
    [self bringSubviewToFront:view];
}
@end
