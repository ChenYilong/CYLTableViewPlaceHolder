//
//  CYLRefreshBackFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshBackFooter.h"
#import "NSBundle+CYLRefresh.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"
#import "UIScrollView+CYLRefresh.h"

@interface CYLRefreshBackFooter()
@property (assign, nonatomic) NSInteger lastRefreshCount;
@property (assign, nonatomic) CGFloat lastBottomDelta;
@property (assign, nonatomic) CGFloat pagingRestingOffset;
@property (assign, nonatomic) CGFloat pagingRefreshOffset;
@property (assign, nonatomic) BOOL holdingNoMoreData;
@property (assign, nonatomic) NSUInteger noMoreDataHoldToken;
@end

@implementation CYLRefreshBackFooter

#pragma mark - 初始化
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        // Give back the held-open bottom inset while the scroll view is still known.
        [self cyl_endNoMoreDataHold];
    }
    [super willMoveToSuperview:newSuperview];

    [self scrollViewContentSizeDidChange:nil];
}

#pragma mark - 实现父类的方法
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];

    // 如果正在刷新，直接返回
    if (self.state == CYLRefreshStateRefreshing) return;
    // The inset is held open while "no more data" stays visible; it is not the original inset.
    if (self.holdingNoMoreData) return;

    _scrollViewOriginalInset = self.scrollView.cyl_inset;

    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.cyl_offsetY;
    // 尾部控件刚好出现的offsetY
    CGFloat happenOffsetY = [self happenOffsetY];
    // 如果是向下滚动到看不见尾部控件，直接返回
    if (currentOffsetY <= happenOffsetY) return;

    CGFloat pullingPercent = (currentOffsetY - happenOffsetY) / self.cyl_h;

    // 如果已全部加载，仅设置pullingPercent，然后返回
    if (self.state == CYLRefreshStateNoMoreData) {
        self.pullingPercent = pullingPercent;
        return;
    }

    if (self.scrollView.isDragging) {
        self.pullingPercent = pullingPercent;
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY + self.cyl_h;

        if (self.state == CYLRefreshStateIdle && currentOffsetY > normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = CYLRefreshStatePulling;
        } else if (self.state == CYLRefreshStatePulling && currentOffsetY <= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = CYLRefreshStateIdle;
        }
    } else if (self.state == CYLRefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        [self beginRefreshing];
    } else if (pullingPercent < 1) {
        self.pullingPercent = pullingPercent;
    }
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];

    CGSize size = [change[NSKeyValueChangeNewKey] CGSizeValue];
    CGFloat contentHeight = size.height == 0 ? self.scrollView.cyl_contentH : size.height;
    // 内容的高度
    contentHeight += self.ignoredScrollViewContentInsetBottom;
    // 表格的高度
    CGFloat scrollHeight = self.scrollView.cyl_h - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom + self.ignoredScrollViewContentInsetBottom;
    // 设置位置
    CGFloat y = MAX(contentHeight, scrollHeight);
    if (self.cyl_y != y) {
        self.cyl_y = y;
    }
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

    // Leaving the held "no more data" state (reset, a new load) gives the bottom inset back first.
    if (state != CYLRefreshStateNoMoreData) {
        [self cyl_endNoMoreDataHold];
    }

    // 根据状态来设置属性
    if (state == CYLRefreshStateNoMoreData || state == CYLRefreshStateIdle) {
        // 刷新完毕
        if (CYLRefreshStateRefreshing == oldState) {
            if (state == CYLRefreshStateNoMoreData && self.noMoreDataDisplayDuration > 0) {
                [self cyl_holdNoMoreDataForDuration:self.noMoreDataDisplayDuration];
            } else {
                [self cyl_restoreBottomInsetAfterRefresh];
            }
        }

        CGFloat deltaH = [self heightForContentBreakView];
        // 刚刷新完毕
        if (CYLRefreshStateRefreshing == oldState && deltaH > 0 && self.scrollView.cyl_totalDataCount != self.lastRefreshCount) {
            self.scrollView.cyl_offsetY = self.scrollView.cyl_offsetY;
        }
    } else if (state == CYLRefreshStateRefreshing) {
        // 记录刷新前的数量
        self.lastRefreshCount = self.scrollView.cyl_totalDataCount;
        self.pagingRestingOffset = [self happenOffsetY];

        [UIView animateWithDuration:self.fastAnimationDuration animations:^{
            CGFloat bottom = self.cyl_h + self.scrollViewOriginalInset.bottom;
            CGFloat deltaH = [self heightForContentBreakView];
            if (deltaH < 0) { // 如果内容高度小于view的高度
                bottom -= deltaH;
            }
            self.lastBottomDelta = bottom - self.scrollView.cyl_insetB;
            self.scrollView.cyl_insetB = bottom;
            self.pagingRefreshOffset = [self happenOffsetY] + self.cyl_h;
            self.scrollView.cyl_offsetY = self.pagingRefreshOffset;
        } completion:^(BOOL finished) {
            [self executeRefreshingCallback];
        }];
    }
}
#pragma mark - 私有方法
#pragma mark 刷新结束：归还底部 inset
- (void)cyl_restoreBottomInsetAfterRefresh
{
    BOOL restorePagingOffset = self.scrollView.pagingEnabled &&
        !self.scrollView.isDragging && !self.scrollView.isDecelerating &&
        fabs(self.scrollView.cyl_offsetY - self.pagingRefreshOffset) < 0.001;
    [UIView animateWithDuration:self.slowAnimationDuration animations:^{
        if (self.endRefreshingAnimationBeginAction) {
            self.endRefreshingAnimationBeginAction();
        }

        self.scrollView.cyl_insetB -= self.lastBottomDelta;
        if (restorePagingOffset) {
            self.scrollView.cyl_offsetY = self.pagingRestingOffset;
        }
        // 自动调整透明度
        if (self.isAutomaticallyChangeAlpha) self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.pullingPercent = 0.0;

        if (self.endRefreshingCompletionBlock) {
            self.endRefreshingCompletionBlock();
        }
    }];
}

#pragma mark 无更多数据：保持显示一段时间再回弹
- (void)cyl_holdNoMoreDataForDuration:(NSTimeInterval)duration
{
    self.holdingNoMoreData = YES;
    NSUInteger token = ++self.noMoreDataHoldToken;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CYLRefreshBackFooter *strongSelf = weakSelf;
        if (!strongSelf || !strongSelf.holdingNoMoreData || strongSelf.noMoreDataHoldToken != token) return;
        strongSelf.holdingNoMoreData = NO;
        [strongSelf cyl_restoreBottomInsetAfterRefresh];
    });
}

- (void)cyl_endNoMoreDataHold
{
    if (!self.holdingNoMoreData) return;
    self.holdingNoMoreData = NO;
    self.noMoreDataHoldToken += 1;
    [self cyl_restoreBottomInsetAfterRefresh];
}

#pragma mark 获得scrollView的内容 超出 view 的高度
- (CGFloat)heightForContentBreakView
{
    CGFloat h = self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top;
    return self.scrollView.contentSize.height - h;
}

#pragma mark 刚好看到上拉刷新控件时的contentOffset.y
- (CGFloat)happenOffsetY
{
    CGFloat deltaH = [self heightForContentBreakView];
    if (deltaH > 0) {
        return deltaH - self.scrollViewOriginalInset.top;
    } else {
        return - self.scrollViewOriginalInset.top;
    }
}
@end
