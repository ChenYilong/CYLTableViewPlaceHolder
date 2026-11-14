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

/// [EN] CYLRefreshComponent's private callback helpers. [CN] CYLRefreshComponent 私有的回调辅助方法。
@interface CYLRefreshComponent (CYLStartHeaderCallbacks)
- (BOOL)cyl_hasCallbacks;
- (void)cyl_copyTargetActionsFrom:(CYLRefreshComponent *)other;
@end

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

#pragma mark - Start header

- (void)cyl_beginRefreshingWithStartHeader:(CYLRefreshHeader *)startHeader
{
    CYLRefreshHeader *regular = self.cyl_header;
    if (!startHeader || startHeader == regular) {
        [regular beginRefreshing];
        return;
    }
    // [EN] Without callbacks of its own, the start header uses the regular header's.
    // [CN] 起始刷新头没有自己的回调时，使用常规刷新头的回调。
    // [EN] Target-actions of -addTarget:action: (the attach:target:action: family) count and are copied too.
    // [CN] -addTarget:action:（attach:target:action: 系列）的 target-action 也计入并复制。
    if (![startHeader cyl_hasCallbacks] && regular) {
        [startHeader cyl_copyTargetActionsFrom:regular];
        startHeader.refreshingBlock = regular.refreshingBlock;
        [startHeader setRefreshingTarget:regular.refreshingTarget refreshingAction:regular.refreshingAction];
        CYLRefreshComponentHandler handler = regular.refreshingHandler;
        if (handler) {
            __weak CYLRefreshHeader *weakRegular = regular;
            // [EN] The regular header's handler gets the regular header. [CN] 常规刷新头的 handler 收到的是常规刷新头。
            startHeader.refreshingHandler = ^(CYLRefreshComponent *component) { if (weakRegular) handler(weakRegular); };
        }
    }
    // [EN] A phase observer, not endRefreshingCompletionBlock, so a caller's endRefreshingWithCompletionBlock: cannot
    //      replace it. After the refresh, wait for the retract animation, then put the regular header back.
    // [CN] 使用阶段观察者而非 endRefreshingCompletionBlock，调用方的 endRefreshingWithCompletionBlock: 不会覆盖它。刷新结束后等待收回动画，
    //      再换回常规刷新头。
    __weak typeof(self) weakSelf = self;
    __block id token = nil;
    __block BOOL refreshed = NO;
    token = [startHeader addPhaseObserver:^(CYLRefreshComponent *component, CYLRefreshPhase oldPhase, CYLRefreshPhase phase) {
        if (phase == CYLRefreshPhaseRefreshing || phase == CYLRefreshPhaseWillRefresh) refreshed = YES;
        if (!refreshed || phase != CYLRefreshPhaseIdle) return;
        [component removePhaseObserver:token];
        NSTimeInterval delay = component.slowAnimationDuration + 0.05;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (self && self.cyl_header == (CYLRefreshHeader *)component) self.cyl_header = regular;
        });
    }];
    self.cyl_header = startHeader;
    [startHeader beginRefreshing];
}

@end
