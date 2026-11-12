//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  UIScrollView+CYLRefresh.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "UIScrollView+CYLRefresh.h"
#import "CYLRefreshHeader.h"
#import "CYLRefreshFooter.h"
#import "CYLRefreshTrailer.h"
#import <objc/runtime.h>

static const char CYLRefreshAutoHideHeaderKey = '\0';
static const char CYLRefreshAutoHideFooterKey = '\0';

@implementation UIScrollView (CYLRefresh)

#pragma mark - header
static const char CYLRefreshHeaderKey = '\0';
- (void)setCyl_header:(CYLRefreshHeader *)cyl_header
{
    if (cyl_header != self.cyl_header) {
        // 删除旧的，添加新的
        [self.cyl_header removeFromSuperview];

        if (cyl_header) {
            [self insertSubview:cyl_header atIndex:0];
        }
        // 存储新的
        objc_setAssociatedObject(self, &CYLRefreshHeaderKey,
                                 cyl_header, OBJC_ASSOCIATION_RETAIN);
        NSNumber *autoHide = objc_getAssociatedObject(self, &CYLRefreshAutoHideHeaderKey);
        if (autoHide && cyl_header) cyl_header.autoHideRefresh = autoHide.boolValue;
    }
}

- (CYLRefreshHeader *)cyl_header
{
    return objc_getAssociatedObject(self, &CYLRefreshHeaderKey);
}

#pragma mark - footer
static const char CYLRefreshFooterKey = '\0';
- (void)setCyl_footer:(CYLRefreshFooter *)cyl_footer
{
    if (cyl_footer != self.cyl_footer) {
        // 删除旧的，添加新的
        [self.cyl_footer removeFromSuperview];
        if (cyl_footer) {
            [self insertSubview:cyl_footer atIndex:0];
        }
        // 存储新的
        objc_setAssociatedObject(self, &CYLRefreshFooterKey,
                                 cyl_footer, OBJC_ASSOCIATION_RETAIN);
        NSNumber *autoHide = objc_getAssociatedObject(self, &CYLRefreshAutoHideFooterKey);
        if (autoHide && cyl_footer) cyl_footer.autoHideRefresh = autoHide.boolValue;
    }
}

- (CYLRefreshFooter *)cyl_footer
{
    return objc_getAssociatedObject(self, &CYLRefreshFooterKey);
}

#pragma mark - footer
static const char CYLRefreshTrailerKey = '\0';
- (void)setCyl_trailer:(CYLRefreshTrailer *)cyl_trailer {
    if (cyl_trailer != self.cyl_trailer) {
        // 删除旧的，添加新的
        [self.cyl_trailer removeFromSuperview];
        if (cyl_trailer) {
            [self insertSubview:cyl_trailer atIndex:0];
        }
        // 存储新的
        objc_setAssociatedObject(self, &CYLRefreshTrailerKey,
                                 cyl_trailer, OBJC_ASSOCIATION_RETAIN);
    }
}

- (CYLRefreshTrailer *)cyl_trailer {
    return objc_getAssociatedObject(self, &CYLRefreshTrailerKey);
}

#pragma mark - other
- (NSInteger)cyl_totalDataCount
{
    NSInteger totalCount = 0;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;

        for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;

        for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}

#pragma mark - Auto-hide

/// [EN] The default when nothing was set: on where the bars are transparent by default. [CN] 未设置时的默认值：栏默认透明的系统上开启。
static BOOL CYLRefreshDefaultAutoHide(void)
{
    if (@available(iOS 26.0, *)) return YES;
    return NO;
}

- (BOOL)cyl_autoHideRefreshHeader
{
    if (self.cyl_header) return self.cyl_header.autoHideRefresh;
    NSNumber *value = objc_getAssociatedObject(self, &CYLRefreshAutoHideHeaderKey);
    return value ? value.boolValue : CYLRefreshDefaultAutoHide();
}

- (void)setCyl_autoHideRefreshHeader:(BOOL)autoHide
{
    objc_setAssociatedObject(self, &CYLRefreshAutoHideHeaderKey, @(autoHide), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cyl_header.autoHideRefresh = autoHide;
}

- (BOOL)cyl_autoHideRefreshFooter
{
    if (self.cyl_footer) return self.cyl_footer.autoHideRefresh;
    NSNumber *value = objc_getAssociatedObject(self, &CYLRefreshAutoHideFooterKey);
    return value ? value.boolValue : CYLRefreshDefaultAutoHide();
}

- (void)setCyl_autoHideRefreshFooter:(BOOL)autoHide
{
    objc_setAssociatedObject(self, &CYLRefreshAutoHideFooterKey, @(autoHide), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.cyl_footer.autoHideRefresh = autoHide;
}

- (BOOL)cyl_autoHideRefresh
{
    return self.cyl_autoHideRefreshHeader && self.cyl_autoHideRefreshFooter;
}

- (void)setCyl_autoHideRefresh:(BOOL)autoHide
{
    self.cyl_autoHideRefreshHeader = autoHide;
    self.cyl_autoHideRefreshFooter = autoHide;
}

@end
