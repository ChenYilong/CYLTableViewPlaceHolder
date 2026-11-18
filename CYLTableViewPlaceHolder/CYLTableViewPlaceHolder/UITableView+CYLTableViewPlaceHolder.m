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

extern BOOL CYLAutomaticPlaceholderEnabled(UIScrollView *scrollView);
extern void CYLBringPlaceholderToFront(UIScrollView *scrollView, UIView *placeholder);
extern UIEdgeInsets CYLPlaceholderVisibleInsets(UIScrollView *scrollView);
extern void CYLPlaceholderStartTrackingKeyboard(void);
extern NSNotificationName const CYLPlaceholderVisibleAreaDidChangeNotification;

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

- (void)cyl_framePlaceholderInVisibleArea:(UIView *)view {
    UIEdgeInsets insets = CYLPlaceholderVisibleInsets(self);
    CGFloat fullHeight = self.bounds.size.height;
    CGFloat height = fullHeight;
    if (insets.bottom > 0) {
        // [EN] With the keyboard up the placeholder must end at the keyboard: in content coordinates y = 0 is below the
        //      top bar (`adjustedContentInset.top`), so that height comes off too. Without the keyboard it keeps the
        //      table's full height, as before.
        // [CN] 键盘显示时占位图必须止于键盘：内容坐标中 y = 0 在顶部栏（`adjustedContentInset.top`）下方，因此也要减去这段高度。
        //      没有键盘时保持表格的完整高度，与之前相同。
        height -= MAX(0, self.adjustedContentInset.top) + insets.bottom;
    }
    // [EN] At least a third of the table stays for the placeholder. [CN] 至少给占位图留下表格三分之一的高度。
    view.frame = CGRectMake(0, 0, self.bounds.size.width, MAX(fullHeight / 3, height));
}

static const void *CYLVisibleAreaObserverKey = &CYLVisibleAreaObserverKey;

- (void)cyl_observeVisibleArea {
    if (objc_getAssociatedObject(self, CYLVisibleAreaObserverKey)) return;
    CYLPlaceholderStartTrackingKeyboard();
    __weak typeof(self) weakSelf = self;
    id token = [NSNotificationCenter.defaultCenter addObserverForName:CYLPlaceholderVisibleAreaDidChangeNotification
        object:nil queue:nil usingBlock:^(NSNotification *note) {
        UITableView *table = weakSelf;
        UIView *view = table.placeHolderView;
        if (!view || view.superview != table) return;
        [table cyl_framePlaceholderInVisibleArea:view];
    }];
    objc_setAssociatedObject(self, CYLVisibleAreaObserverKey, token, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cyl_reloadData {
    [self reloadData];
    if (!CYLAutomaticPlaceholderEnabled(self)) [self cyl_checkEmpty];
}

- (void)cyl_removeLegacyPlaceholder {
    if (!self.placeHolderView) return;
    self.scrollEnabled = self.scrollWasEnabled;
    [self.placeHolderView removeFromSuperview];
    self.placeHolderView = nil;
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
        // Lay out first so header and section rects include final geometry, such as
        // iOS 15 section header padding, when the provider reads them (issue #16).
        [self layoutIfNeeded];
        view.frame = [provider frameForPlaceHolderViewInTableView:self];
    } else {
        // [EN] The table's size, minus the part the keyboard covers; it follows the keyboard while shown (no custom frame
        //      from the provider).
        // [CN] 表格的尺寸减去键盘遮住的部分；显示期间跟随键盘（提供者未给出自定义 frame 时）。
        [self cyl_framePlaceholderInVisibleArea:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self cyl_observeVisibleArea];
    }
    if (view.superview != self) {
        [self addSubview:view];
    }
    CYLBringPlaceholderToFront(self, view);
}
@end
