//
//  CYLRefreshBackFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshBackFooter.h"
#import <objc/runtime.h>
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
/// [EN] Second floor state. [CN] 二楼状态。
@property (assign, nonatomic) BOOL cyl_secondaryArmed;
@property (assign, nonatomic) BOOL cyl_secondaryClosePending;
@property (assign, nonatomic) BOOL cyl_secondaryClosing;
@property (assign, nonatomic, readwrite, getter=isSecondaryOpen) BOOL secondaryOpen;
@property (assign, nonatomic) NSUInteger noMoreDataHoldToken;
@end

@interface CYLRefreshComponent (CYLPhaseReportingFooter)
- (void)cyl_reportPhase;
@end

@interface CYLRefreshBackFooter (CYLTriggerMode)
/// [EN] Whether the current drag started with the list at the bottom edge (triggerMode). [CN] 当前拖动开始时列表是否在底部边缘（triggerMode）。
@property (assign, nonatomic) BOOL cyl_dragStartedAtEdge;
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
    // [EN] The second floor holds its own inset. [CN] 二楼占用了自己的 inset。
    if (self.secondaryOpen || self.cyl_secondaryClosing) {
        [self cyl_followOpenSecondary];
        return;
    }

    _scrollViewOriginalInset = self.scrollView.cyl_inset;

    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.cyl_offsetY;
    // 尾部控件刚好出现的offsetY
    CGFloat happenOffsetY = [self happenOffsetY];
    // 如果是向下滚动到看不见尾部控件，直接返回
    if (currentOffsetY <= happenOffsetY) return;

    CGFloat pullingPercent = (currentOffsetY - happenOffsetY) / (self.cyl_h * self.triggerRate);

    CGFloat normal2pullingOffsetY = happenOffsetY + self.cyl_h * self.triggerRate;
    // 如果已全部加载，仅设置pullingPercent，然后返回
    if (self.state == CYLRefreshStateNoMoreData) {
        // [EN] loadsAfterNoMoreData: pulling past the trigger point loads again. [CN] loadsAfterNoMoreData：拉过触发点再次加载。
        if (self.loadsAfterNoMoreData && self.scrollView.isDragging && currentOffsetY > normal2pullingOffsetY) {
            [self resetNoMoreData];
        } else {
            self.pullingPercent = pullingPercent;
            return;
        }
    }

    // [EN] Second floor: arm past its trigger while dragging, open on release. [CN] 二楼：拖动中越过触发点即就绪，松手打开。
    if (self.secondaryTriggerOffset > 0 && self.state != CYLRefreshStateNoMoreData) {
        BOOL armed = self.scrollView.isDragging && currentOffsetY - happenOffsetY >= self.secondaryTriggerOffset;
        if (self.scrollView.isDragging && armed != self.cyl_secondaryArmed) {
            self.cyl_secondaryArmed = armed;
            [self cyl_reportPhase];
        } else if (!self.scrollView.isDragging && self.cyl_secondaryArmed) {
            [self openSecondary];
            return;
        }
    }

    if (self.scrollView.isDragging) {
        // [EN] maxPullDistance: hold the pull at the limit. [CN] maxPullDistance：把上拉停在上限。
        if (self.maxPullDistance > 0 && currentOffsetY - happenOffsetY > self.maxPullDistance) {
            currentOffsetY = happenOffsetY + self.maxPullDistance;
            pullingPercent = self.maxPullDistance / (self.cyl_h * self.triggerRate);
            self.scrollView.contentOffset = CGPointMake(self.scrollView.cyl_offsetX, currentOffsetY);
        }
        self.pullingPercent = pullingPercent;
        // 普通 和 即将刷新 的临界点

        BOOL mayArm = self.triggerMode == CYLRefreshTriggerModeAnywhere || self.cyl_dragStartedAtEdge;
        if (self.state == CYLRefreshStateIdle && self.refreshEnabled && mayArm && currentOffsetY > normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = CYLRefreshStatePulling;
            if (self.triggersWhenReached) [self beginRefreshing];
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
    [self cyl_placeSecondaryView];

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
/*!
 * [EN] YES when a paging scroll view rests between two pages, as UIKit's paging deceleration can leave it after the
 *      footer's refresh animation moved the offset (MJRefresh #1430: the page ended about 0.22 of a page off).
 * [CN] 分页滚动视图停在两页之间时为 YES；刷新尾的动画改动 offset 后，UIKit 的分页减速可能把它留在这种位置（MJRefresh #1430）。
 */
- (BOOL)cyl_isBetweenPages
{
    UIScrollView *scrollView = self.scrollView;
    CGFloat page = scrollView.cyl_h;
    if (page <= 0) return NO;
    CGFloat position = (scrollView.cyl_offsetY + scrollView.cyl_insetT) / page;
    return fabs(position - round(position)) > 0.001;
}

/*!
 * [EN] Moves a paging scroll view onto the nearest page inside its content. [CN] 把分页滚动视图移到内容范围内最近的一页。
 */
- (void)cyl_alignToNearestPage
{
    UIScrollView *scrollView = self.scrollView;
    CGFloat page = scrollView.cyl_h;
    if (page <= 0) return;
    CGFloat top = -scrollView.cyl_insetT;
    CGFloat maxOffset = MAX(top, scrollView.cyl_contentH - page + scrollView.cyl_insetB);
    CGFloat aligned = top + round((scrollView.cyl_offsetY - top) / page) * page;
    aligned = MIN(MAX(aligned, top), maxOffset);
    if (fabs(aligned - scrollView.cyl_offsetY) > 0.001) {
        [scrollView setContentOffset:CGPointMake(scrollView.cyl_offsetX, aligned) animated:NO];
    }
}

- (void)cyl_restoreBottomInsetAfterRefresh
{
    UIScrollView *scrollView = self.scrollView;
    // [EN] A paging scroll view goes back to the page it showed before the refresh when the offset is still the
    //      refresh's own, or when it rests between pages (#1430); a page the caller chose, a drag or a deceleration is
    //      left alone. [CN] 分页滚动视图在 offset 仍是刷新设置的值、或停在两页之间时（#1430）回到刷新前的页面；调用方选定的页面、
    //      拖动中或减速中不做处理。
    BOOL restorePagingOffset = scrollView.pagingEnabled && !scrollView.isDragging && !scrollView.isDecelerating &&
        (fabs(scrollView.cyl_offsetY - self.pagingRefreshOffset) < 0.001 || [self cyl_isBetweenPages]);
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
        // [EN] Anything that moved it during the animation cannot leave it between pages.
        // [CN] 动画期间的其他改动也不会让它停在两页之间。
        UIScrollView *current = self.scrollView;
        if (restorePagingOffset && current.pagingEnabled && !current.isDragging && !current.isDecelerating) {
            [self cyl_alignToNearestPage];
        }

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
#pragma mark - Trigger mode

- (void)setCyl_dragStartedAtEdge:(BOOL)value
{
    objc_setAssociatedObject(self, @selector(cyl_dragStartedAtEdge), @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)cyl_dragStartedAtEdge
{
    return [objc_getAssociatedObject(self, @selector(cyl_dragStartedAtEdge)) boolValue];
}

- (void)cyl_recordDragStart
{
    if (self.scrollView.panGestureRecognizer.state != UIGestureRecognizerStateBegan) return;
    self.cyl_dragStartedAtEdge = self.scrollView.cyl_offsetY >= [self happenOffsetY] - 0.5;
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    UIPanGestureRecognizer *pan = self.scrollView.panGestureRecognizer;
    if (pan.state == UIGestureRecognizerStateEnded && self.secondaryVelocity > 0 && self.secondaryTriggerOffset > 0 &&
        !self.secondaryOpen && !self.isRefreshing && self.state != CYLRefreshStateNoMoreData) {
        // [EN] A fast release past the load trigger opens the second floor. [CN] 越过加载触发点后快速松手即打开二楼。
        CGFloat velocity = -[pan velocityInView:self.scrollView].y;
        CGFloat pulled = self.scrollView.cyl_offsetY - [self happenOffsetY];
        if (velocity >= self.secondaryVelocity && pulled >= self.cyl_h * self.triggerRate) {
            [self openSecondary];
            return;
        }
    }
    [self cyl_recordDragStart];
}

#pragma mark - Second floor

- (CGFloat)secondaryCloseTriggerOffset
{
    return _secondaryCloseTriggerOffset > 0 ? _secondaryCloseTriggerOffset : 80;
}

- (CGFloat)cyl_secondaryHeight
{
    if (self.secondaryDimension > 0) return self.secondaryDimension;
    return MAX(self.cyl_h, CGRectGetHeight(self.scrollView.bounds) - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom);
}

- (CYLRefreshPhase)phase
{
    if (self.cyl_secondaryClosing) return CYLRefreshPhaseSecondaryClosing;
    if (self.secondaryOpen) return CYLRefreshPhaseSecondaryOpen;
    if (self.cyl_secondaryArmed) return CYLRefreshPhaseSecondaryArmed;
    return [super phase];
}

- (void)setSecondaryView:(UIView *)secondaryView
{
    if (_secondaryView != secondaryView) [_secondaryView removeFromSuperview];
    _secondaryView = secondaryView;
    [self cyl_placeSecondaryView];
}

/// [EN] The floor's view sits right below the content, across the whole floor. [CN] 二楼视图紧贴内容下方，铺满整个二楼。
- (void)cyl_placeSecondaryView
{
    UIView *view = self.secondaryView;
    UIScrollView *scrollView = self.scrollView;
    if (!view || !scrollView) return;
    if (view.superview != scrollView) [scrollView insertSubview:view belowSubview:self];
    CGFloat top = MAX(scrollView.cyl_contentH, CGRectGetHeight(scrollView.bounds) - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom);
    view.frame = CGRectMake(-scrollView.cyl_insetL, top, scrollView.cyl_w, [self cyl_secondaryHeight]);
}

- (void)didAttachToScrollView:(UIScrollView *)scrollView
{
    [super didAttachToScrollView:scrollView];
    [self cyl_placeSecondaryView];
}

- (void)willDetachFromScrollView:(UIScrollView *)scrollView
{
    [self.secondaryView removeFromSuperview];
    [super willDetachFromScrollView:scrollView];
}

- (void)openSecondary
{
    if (self.secondaryOpen || !self.scrollView || self.isRefreshing) return;
    self.cyl_secondaryArmed = NO;
    if (self.state == CYLRefreshStatePulling) self.state = CYLRefreshStateIdle;
    [self cyl_placeSecondaryView];
    self.secondaryOpen = YES;
    [self cyl_reportPhase];
    CGFloat height = [self cyl_secondaryHeight];
    CGFloat bottom = self.scrollViewOriginalInset.bottom + height;
    CGFloat target = [self happenOffsetY] + height;
    [UIView animateWithDuration:self.slowAnimationDuration animations:^{
        self.scrollView.cyl_insetB = bottom;
        self.scrollView.contentOffset = CGPointMake(self.scrollView.cyl_offsetX, target);
    } completion:^(BOOL finished) {
        if (self.secondaryOpenedBlock) self.secondaryOpenedBlock();
    }];
}

- (void)closeSecondary
{
    if (!self.secondaryOpen || self.cyl_secondaryClosing) return;
    self.cyl_secondaryClosing = YES;
    self.cyl_secondaryClosePending = NO;
    [self cyl_reportPhase];
    CGFloat bottom = self.scrollViewOriginalInset.bottom;
    CGFloat target = MAX([self happenOffsetY], -self.scrollViewOriginalInset.top);
    [UIView animateWithDuration:self.slowAnimationDuration animations:^{
        self.scrollView.cyl_insetB = bottom;
        self.scrollView.contentOffset = CGPointMake(self.scrollView.cyl_offsetX, target);
    } completion:^(BOOL finished) {
        self.cyl_secondaryClosing = NO;
        self.secondaryOpen = NO;
        self.pullingPercent = 0;
        [self cyl_reportPhase];
        [self updateAutoHideVisibility];
        if (self.secondaryClosedBlock) self.secondaryClosedBlock();
    }];
}

/// [EN] While open: pulling the content down past the close trigger and releasing closes the floor.
/// [CN] 打开时：把内容下拉超过关闭触发距离再松手，即关闭二楼。
- (void)cyl_followOpenSecondary
{
    if (self.cyl_secondaryClosing) return;
    CGFloat openOffsetY = [self happenOffsetY] + [self cyl_secondaryHeight];
    CGFloat pulled = openOffsetY - self.scrollView.cyl_offsetY;
    if (self.scrollView.isDragging) {
        self.cyl_secondaryClosePending = pulled >= self.secondaryCloseTriggerOffset;
    } else if (self.cyl_secondaryClosePending) {
        [self closeSecondary];
    }
}

@end
