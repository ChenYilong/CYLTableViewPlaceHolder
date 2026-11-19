//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshHeader.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshHeader.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"
#import "UIScrollView+CYLRefresh.h"
#import "CYLRefreshFooter.h"

NSString * const CYLRefreshHeaderRefreshing2IdleBoundsKey = @"CYLRefreshHeaderRefreshing2IdleBounds";
NSString * const CYLRefreshHeaderRefreshingBoundsKey = @"CYLRefreshHeaderRefreshingBounds";

/// [EN] The component's private phase reporting, called when the second floor changes. [CN] 组件私有的阶段通知，二楼变化时调用。
@interface CYLRefreshComponent (CYLPhaseReporting)
- (void)cyl_reportPhase;
@end

@interface CYLRefreshHeader() <CAAnimationDelegate>
@property (assign, nonatomic) CGFloat insetTDelta;
@property (assign, nonatomic) BOOL updatingRefreshInset;
/// [EN] YES while the header retracts after a refresh. [CN] 刷新结束后刷新头收回期间为 YES。
@property (assign, nonatomic) BOOL retracting;
/// [EN] The open height kept while `scrollMode` changes the frame. [CN] `scrollMode` 改变 frame 时保留的展开高度。
@property (assign, nonatomic) CGFloat cyl_storedExpandHeight;
/// [EN] YES while this refresh added the header height to the top inset. [CN] 本次刷新把刷新头高度加到顶部 inset 期间为 YES。
@property (assign, nonatomic) BOOL cyl_addedRefreshingInset;
/// [EN] Whether the current drag started with the list at the top edge (triggerMode). [CN] 当前拖动开始时列表是否在顶部边缘（triggerMode）。
@property (assign, nonatomic) BOOL cyl_dragStartedAtEdge;
/// [EN] Second floor: pulled past the trigger while dragging. [CN] 二楼：拖动中已拉过触发点。
@property (assign, nonatomic) BOOL cyl_secondaryArmed;
/// [EN] Second floor: pushed up far enough to close on release. [CN] 二楼：已上推足够距离，松手即关闭。
@property (assign, nonatomic) BOOL cyl_secondaryClosePending;
/// [EN] Second floor: the closing animation runs. [CN] 二楼：关闭动画进行中。
@property (assign, nonatomic) BOOL cyl_secondaryClosing;
@property (assign, nonatomic, readwrite, getter=isSecondaryOpen) BOOL secondaryOpen;
@end

/// [EN] CYLRefreshComponent's private dragRate helper. [CN] CYLRefreshComponent 私有的 dragRate 辅助方法。
@interface CYLRefreshComponent (CYLDragRate)
- (CGFloat)cyl_offsetForDragRate:(CGFloat)offsetY happenOffset:(CGFloat)happenOffsetY;
@end

/// [EN] YES while cyl_insetB / L / R write the inset (UIScrollView+CYLExtensionSupport.m). [CN] cyl_insetB / L / R 写入 inset 期间为 YES。
FOUNDATION_EXTERN BOOL CYLRefreshIsWritingSideInset(void);

@implementation CYLRefreshHeader
#pragma mark - 构造方法
+ (instancetype)headerWithRefreshingBlock:(CYLRefreshComponentAction)refreshingBlock
{
    CYLRefreshHeader *cmp = [[self alloc] init];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}
+ (instancetype)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    CYLRefreshHeader *cmp = [[self alloc] init];
    [cmp setRefreshingTarget:target refreshingAction:action];
    return cmp;
}

#pragma mark - 覆盖父类的方法
- (void)prepare
{
    [super prepare];

    // 设置key
    self.lastUpdatedTimeKey = CYLRefreshHeaderLastUpdatedTimeKey;

    // 设置高度
    self.cyl_h = CYLRefreshHeaderHeight;

    _addsRefreshingInset = YES;
    _secondaryCloseTriggerOffset = 80;
    [self updateAutoHideVisibility];
}

#pragma mark - Hidden while idle

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    [self updateAutoHideVisibility];
}

/// [EN] Idle and fully retracted: the content's top edge is at or above the header's bottom edge.
/// [CN] 空闲且完全收回：内容顶边位于刷新头底边或其上方。
- (BOOL)cyl_isIdleAndRetracted
{
    if (self.state != CYLRefreshStateIdle || self.retracting) return NO;
    if (!self.scrollView) return YES;
    return self.scrollView.cyl_offsetY >= -self.scrollViewOriginalInset.top - 0.5;
}

- (BOOL)isReadyToAutoHide
{
    return [self cyl_isIdleAndRetracted];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (self.scrollView) {
        self.cyl_y = -self.cyl_h - self.ignoredScrollViewContentInsetTop;
    }
}

- (void)placeSubviews
{
    [super placeSubviews];

    // 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
    self.cyl_y = - self.cyl_h - self.ignoredScrollViewContentInsetTop + self.insetStart;
    [self cyl_applyScrollMode];
}

#pragma mark - Second floor

- (CGFloat)cyl_secondaryHeight
{
    if (self.secondaryDimension > 0) return self.secondaryDimension;
    UIScrollView *scrollView = self.scrollView;
    return MAX(self.expandHeight, CGRectGetHeight(scrollView.bounds) - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom);
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

/// [EN] The second floor's view sits above the content, across the whole second floor, behind the header.
/// [CN] 二楼视图放在内容上方、铺满整个二楼，位于刷新头后面。
- (void)cyl_placeSecondaryView
{
    UIView *view = self.secondaryView;
    UIScrollView *scrollView = self.scrollView;
    if (!view || !scrollView) return;
    if (view.superview != scrollView) [scrollView insertSubview:view belowSubview:self];
    CGFloat height = [self cyl_secondaryHeight];
    view.frame = CGRectMake(-scrollView.cyl_insetL, -height - self.ignoredScrollViewContentInsetTop, scrollView.cyl_w, height);
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

/// [EN] The second floor's open / close duration (secondaryAnimationDuration, else slowAnimationDuration).
/// [CN] 二楼打开 / 关闭的时长（secondaryAnimationDuration，否则 slowAnimationDuration）。
- (NSTimeInterval)cyl_secondaryDuration
{
    return self.secondaryAnimationDuration > 0 ? self.secondaryAnimationDuration : self.slowAnimationDuration;
}

- (void)openSecondary
{
    if (self.secondaryOpen || !self.scrollView || self.isRefreshing) return;
    if (self.secondaryShouldOpenBlock && !self.secondaryShouldOpenBlock(self)) {
        // [EN] Vetoed: drop the armed pull, the header stays as it is. [CN] 被拒绝：放弃已触发的拉动，刷新头保持原样。
        self.cyl_secondaryArmed = NO;
        return;
    }
    self.cyl_secondaryArmed = NO;
    if (self.state == CYLRefreshStatePulling) self.state = CYLRefreshStateIdle;
    [self cyl_placeSecondaryView];
    self.secondaryOpen = YES;
    // [EN] The open floor comes in front of the header, as flutter_easy_refresh's secondary page does; the header's
    //      text would otherwise show over the floor. [CN] 打开的二楼移到刷新头前面（与 flutter_easy_refresh 的二楼页面相同），
    //      否则刷新头的文字会显示在二楼上。
    if (self.secondaryView) [self.scrollView insertSubview:self.secondaryView aboveSubview:self];
    [self cyl_reportPhase];
    CGFloat top = self.scrollViewOriginalInset.top + [self cyl_secondaryHeight];
    [UIView animateWithDuration:[self cyl_secondaryDuration] animations:^{
        [self setRefreshingInsetTop:top];
        self.scrollView.contentOffset = CGPointMake(self.scrollView.cyl_offsetX, -top);
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
    CGFloat top = self.scrollViewOriginalInset.top;
    [UIView animateWithDuration:[self cyl_secondaryDuration] animations:^{
        [self setRefreshingInsetTop:top];
        self.scrollView.contentOffset = CGPointMake(self.scrollView.cyl_offsetX, -top);
    } completion:^(BOOL finished) {
        self.cyl_secondaryClosing = NO;
        self.secondaryOpen = NO;
        self.pullingPercent = 0;
        // [EN] Closed: back behind the header, revealed by the next pull. [CN] 关闭后回到刷新头后面，由下次下拉露出。
        if (self.secondaryView) [self.scrollView insertSubview:self.secondaryView belowSubview:self];
        [self cyl_reportPhase];
        [self updateAutoHideVisibility];
        if (self.secondaryClosedBlock) self.secondaryClosedBlock();
    }];
}

/// [EN] While open: pushing the content up past the close trigger and releasing closes the second floor.
/// [CN] 打开时：把内容上推超过关闭触发距离再松手，即关闭二楼。
- (void)cyl_followOpenSecondary
{
    if (self.cyl_secondaryClosing) return;
    CGFloat openOffsetY = -(self.scrollViewOriginalInset.top + [self cyl_secondaryHeight]);
    CGFloat pushed = self.scrollView.cyl_offsetY - openOffsetY;
    if (self.scrollView.isDragging) {
        self.cyl_secondaryClosePending = pushed >= self.secondaryCloseTriggerOffset;
    } else if (self.cyl_secondaryClosePending) {
        [self closeSecondary];
    }
}

#pragma mark - Trigger mode

- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    UIGestureRecognizer *pan = self.scrollView.panGestureRecognizer;
    if (pan.state == UIGestureRecognizerStateEnded && self.secondaryVelocity > 0 && self.secondaryTriggerOffset > 0 &&
        !self.secondaryOpen && !self.isRefreshing) {
        // [EN] A fast release past the refresh trigger opens the second floor. [CN] 越过刷新触发点后快速松手即打开二楼。
        CGFloat velocity = [self.scrollView.panGestureRecognizer velocityInView:self.scrollView].y;
        CGFloat pulled = -(self.scrollView.cyl_offsetY + self.scrollViewOriginalInset.top);
        if (velocity >= self.secondaryVelocity && pulled >= self.expandHeight * self.triggerRate) {
            [self openSecondary];
            return;
        }
    }
    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // [EN] At the top edge: the content's top is at (or below) the header's bottom. [CN] 位于顶部边缘：内容顶部在刷新头底边或其下方。
        self.cyl_dragStartedAtEdge = self.scrollView.cyl_offsetY <= -self.scrollViewOriginalInset.top + 0.5;
    }
}

#pragma mark - Scroll mode

/// [EN] Refreshing pushes the content down only when the header adds its inset and does not float in front.
/// [CN] 只有刷新头会加 inset 且不是前置时，刷新才会把内容往下推。
- (BOOL)cyl_movesContentWhileRefreshing
{
    return self.addsRefreshingInset && self.scrollMode != CYLRefreshScrollModeFront;
}

- (CGFloat)expandHeight
{
    return self.cyl_storedExpandHeight > 0 ? self.cyl_storedExpandHeight : self.cyl_h;
}

- (void)setExpandHeight:(CGFloat)expandHeight
{
    expandHeight = MAX(0, expandHeight);
    if (self.scrollMode == CYLRefreshScrollModeMove) {
        self.cyl_storedExpandHeight = 0;
        self.cyl_h = expandHeight;
    } else {
        self.cyl_storedExpandHeight = MAX(expandHeight, 1);
        if (self.scrollMode == CYLRefreshScrollModeFront) self.cyl_h = expandHeight;
    }
    [self cyl_applyScrollMode];
}

- (void)setScrollMode:(CYLRefreshScrollMode)scrollMode
{
    if (scrollMode != CYLRefreshScrollModeMove && self.cyl_storedExpandHeight <= 0) {
        self.cyl_storedExpandHeight = self.cyl_h;
    }
    [super setScrollMode:scrollMode];
    if (scrollMode == CYLRefreshScrollModeMove && self.cyl_storedExpandHeight > 0) {
        CGFloat height = self.cyl_storedExpandHeight;
        self.cyl_storedExpandHeight = 0;
        self.cyl_h = height;
        self.cyl_y = -height - self.ignoredScrollViewContentInsetTop;
        self.layer.zPosition = 0;
    }
    [self cyl_applyScrollMode];
}

/// [EN] Places the header for `scrollMode`: stretched over the whole pulled distance, or in front at the visible top.
/// [CN] 按 `scrollMode` 放置刷新头：拉伸铺满整个下拉距离，或位于可见区域顶部的内容前面。
- (void)cyl_applyScrollMode
{
    if (self.scrollMode == CYLRefreshScrollModeMove || !self.scrollView) return;
    CGFloat height = self.expandHeight;
    CGFloat offsetY = self.scrollView.cyl_offsetY;
    CGFloat visibleTop = offsetY + self.scrollViewOriginalInset.top;
    CGFloat pulled = MAX(0, -visibleTop);
    if (self.scrollMode == CYLRefreshScrollModeStretch) {
        // [EN] Stretch, as in CYLRefresh styles: the header is exactly the pulled area, from 0 when idle.
        // [CN] 拉伸（与 CYLRefresh styles 相同）：刷新头正好是被拉出的区域，空闲时高度为 0。
        if (fabs(self.cyl_h - pulled) > 0.25) self.cyl_h = pulled;
        self.cyl_y = -pulled - self.ignoredScrollViewContentInsetTop;
    } else if (self.scrollMode == CYLRefreshScrollModeBehind) {
        // [EN] Behind: pinned at the visible top behind the content, revealed as the content moves down.
        // [CN] 后置：固定在可见区域顶部、位于内容后面，内容下移时露出。
        if (fabs(self.cyl_h - height) > 0.25) self.cyl_h = height;
        self.cyl_y = MIN(visibleTop, -height) + self.insetStart;
        self.layer.zPosition = -1;
        // [EN] clipsWhenBehind: only the revealed part shows. [CN] clipsWhenBehind：只显示露出的部分。
        if (self.clipsWhenBehind) {
            CALayer *mask = self.layer.mask ?: [CALayer layer];
            mask.backgroundColor = UIColor.blackColor.CGColor;
            mask.frame = CGRectMake(0, 0, self.cyl_w, MIN(pulled, height));
            self.layer.mask = mask;
        } else if (self.layer.mask && !self.clipsWhenBehind) {
            self.layer.mask = nil;
        }
        if (self.superview.subviews.firstObject != self) [self.superview sendSubviewToBack:self];
    } else {
        // [EN] Front, as in CYLRefresh styles: pinned at the top of the visible area, in front of the content, which
        //      never moves for it (no refreshing inset). [CN] 前置（与 CYLRefresh styles 相同）：固定在可见区域顶部、位于内容前面，
        //      内容不会为它移动（不加刷新 inset）。
        if (fabs(self.cyl_h - height) > 0.25) self.cyl_h = height;
        self.cyl_y = visibleTop + self.insetStart;
        self.layer.zPosition = 1;
        if (self.superview.subviews.lastObject != self) [self.superview bringSubviewToFront:self];
    }
}

- (void)setRefreshingInsetTop:(CGFloat)insetTop
{
    if (self.updatingRefreshInset || !self.scrollView) return;

    self.updatingRefreshInset = YES;
    @try {
        self.scrollView.cyl_insetT = insetTop;
    } @finally {
        self.updatingRefreshInset = NO;
    }
}

- (void)resetInset {
    if (self.updatingRefreshInset) return;
    if (@available(iOS 11.0, *)) {
    } else {
        // 如果 iOS 10 及以下系统在刷新时, push 新的 VC, 等待刷新完成后回来, 会导致顶部 Insets.top 异常, 不能 resetInset, 检查一下这种特殊情况
        if (!self.window) { return; }
    }

    // FIX: MJRefresh PR #1444 (device rotation)
    // [EN] insetTDelta (original top - current top) is what the header added, and stays right when the system part of
    //      the inset changes (a rotation changes the bars and the safe area, both sides move together). The saved
    //      original top does not: rebuild it from the current top, or the header works from the old system inset and
    //      leaves the difference behind as a gap when the refresh ends.
    // [CN] insetTDelta（原始 top - 当前 top）是刷新头增加的量，系统部分的 inset 变化时（旋转会改变栏与安全区，两边一起变）它仍然正确；
    //      保存的原始 top 则不会。用当前 top 重新得出它，否则刷新头会按旧的系统 inset 计算，并在刷新结束后留下差值作为空隙。
    UIEdgeInsets original = _scrollViewOriginalInset;
    original.top = self.scrollView.cyl_insetT + self.insetTDelta;
    _scrollViewOriginalInset = original;

    // sectionheader停留解决
    CGFloat insetT = - self.scrollView.cyl_offsetY > _scrollViewOriginalInset.top ? - self.scrollView.cyl_offsetY : _scrollViewOriginalInset.top;
    insetT = insetT > self.expandHeight + _scrollViewOriginalInset.top ? self.expandHeight + _scrollViewOriginalInset.top : insetT;
    // 避免 CollectionView 在使用根据 Autolayout 和 内容自动伸缩 Cell, 刷新时导致的 Layout 异常渲染问题
    if (fabs(self.scrollView.cyl_insetT - insetT) > FLT_EPSILON) {
        [self setRefreshingInsetTop:insetT];
    }
    self.insetTDelta = _scrollViewOriginalInset.top - self.scrollView.cyl_insetT;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    [self updateAutoHideVisibility];
    [self cyl_applyScrollMode];

    // 在刷新的refreshing状态
    if (self.state == CYLRefreshStateRefreshing) {
        if (self.cyl_addedRefreshingInset && self.scrollMode != CYLRefreshScrollModeFront) [self resetInset];
        return;
    }

    // [EN] The second floor holds its own inset; it is not the original inset. [CN] 二楼占用了自己的 inset，不是原始 inset。
    if (self.secondaryOpen || self.cyl_secondaryClosing) {
        [self cyl_followOpenSecondary];
        return;
    }

    // 跳转到下一个控制器时，contentInset可能会变
    _scrollViewOriginalInset = self.scrollView.cyl_inset;

    // 当前的contentOffset
    CGFloat offsetY = self.scrollView.cyl_offsetY;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;

    // 如果是向上滚动到看不见头部控件，直接返回
    // >= -> >
    if (offsetY > happenOffsetY) return;
    // [EN] dragRate scales the pull. [CN] dragRate 按比例缩放拉动距离。
    offsetY = [self cyl_offsetForDragRate:offsetY happenOffset:happenOffsetY];

    // 普通 和 即将刷新 的临界点
    CGFloat triggerDistance = self.expandHeight * self.triggerRate;
    CGFloat normal2pullingOffsetY = happenOffsetY - triggerDistance;
    CGFloat pullingPercent = (happenOffsetY - offsetY) / triggerDistance;

    // [EN] Second floor: arm past its trigger while dragging, open on release. [CN] 二楼：拖动中越过触发点即就绪，松手打开。
    if (self.secondaryTriggerOffset > 0) {
        BOOL armed = self.scrollView.isDragging && happenOffsetY - offsetY >= self.secondaryTriggerOffset;
        if (self.scrollView.isDragging && armed != self.cyl_secondaryArmed) {
            self.cyl_secondaryArmed = armed;
            [self cyl_reportPhase];
        } else if (!self.scrollView.isDragging && self.cyl_secondaryArmed) {
            [self openSecondary];
            return;
        }
    }

    if (self.scrollView.isDragging) { // 如果正在拖拽
        // [EN] maxPullDistance: hold the pull at the limit. [CN] maxPullDistance：把下拉停在上限。
        if (self.maxPullDistance > 0 && happenOffsetY - offsetY > self.maxPullDistance) {
            offsetY = happenOffsetY - self.maxPullDistance;
            pullingPercent = self.maxPullDistance / triggerDistance;
            self.scrollView.contentOffset = CGPointMake(self.scrollView.cyl_offsetX, offsetY);
        }
        self.pullingPercent = pullingPercent;
        BOOL mayArm = self.triggerMode == CYLRefreshTriggerModeAnywhere || self.cyl_dragStartedAtEdge;
        if (self.state == CYLRefreshStateIdle && self.refreshEnabled && mayArm && [self canTrigger] &&
            offsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = CYLRefreshStatePulling;
            // [EN] triggersWhenReached: refresh now, without waiting for the release. [CN] triggersWhenReached：立即刷新，不等松手。
            if (self.triggersWhenReached) [self beginRefreshing];
        } else if (self.state == CYLRefreshStatePulling && offsetY >= normal2pullingOffsetY) {
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

// FIX: issue MJRefresh#1628
// [EN] Someone else wrote the content inset during a refresh (SwiftUI's ScrollView resets its inset and offset when its
//      data changes; an app may set a new inset). The written top becomes the new original inset, the refreshing inset
//      is added on top of it again, and a list resting at its top edge moves back to show the header. Writes of the
//      header itself (`updatingRefreshInset`) and refreshes that add no inset (front scroll mode) are left alone.
// [CN] 刷新期间有其他代码写入了 contentInset（SwiftUI 的 ScrollView 在数据变化时会重置 inset 和 offset；应用也可能设置新的 inset）。
//      写入的 top 作为新的原始 inset，在其上重新加上刷新 inset；停在顶部边缘的列表移回到能看到刷新头的位置。刷新头自己的写入
//      （`updatingRefreshInset`）和不增加 inset 的刷新（前置滚动模式）不受影响。
- (void)scrollViewContentInsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentInsetDidChange:change];
    if (self.updatingRefreshInset || self.state != CYLRefreshStateRefreshing || !self.cyl_addedRefreshingInset ||
        ![self cyl_movesContentWhileRefreshing] || !self.scrollView) return;
    // FIX: issue MJRefresh#1483
    // [EN] A footer or trailer that starts or ends loading writes its own side (cyl_insetB / L / R). Taking that write
    //      for a new original top made the refreshing top the "original" and added the header's height again, so each
    //      refresh during a footer load left the content one header height lower.
    // [CN] 刷新尾或 trailer 开始或结束加载时写入自己那一侧（cyl_insetB / L / R）。把这次写入当作新的原始 top，会把刷新中的 top 当作
    //      “原始值”并再次加上刷新头高度，于是每次在刷新尾加载期间刷新，内容都下移一个刷新头高度。
    if (CYLRefreshIsWritingSideInset()) return;
    UIScrollView *scrollView = self.scrollView;
    CGFloat originalTop = scrollView.cyl_insetT;
    CGFloat refreshingTop = originalTop + self.expandHeight;
    UIEdgeInsets original = _scrollViewOriginalInset;
    original.top = originalTop;
    _scrollViewOriginalInset = original;
    BOOL restingAtTop = !scrollView.isTracking && !scrollView.isDecelerating &&
        scrollView.cyl_offsetY <= -originalTop + FLT_EPSILON;
    [self setRefreshingInsetTop:refreshingTop];
    self.insetTDelta = originalTop - scrollView.cyl_insetT;
    if (restingAtTop && scrollView.cyl_offsetY > -refreshingTop + FLT_EPSILON) {
        [scrollView setContentOffset:CGPointMake(scrollView.cyl_offsetX, -refreshingTop) animated:NO];
    }
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

    // 根据状态做事情
    if (state == CYLRefreshStateIdle) {
        if (oldState != CYLRefreshStateRefreshing) {
            [self updateAutoHideVisibility];
            return;
        }

        [self headerEndingAction];
    } else if (state == CYLRefreshStateRefreshing) {
        [self headerRefreshingAction];
    }
    [self updateAutoHideVisibility];
}

- (void)headerEndingAction {
    // [EN] resetsFooterAfterRefresh: a successful refresh lets the footer load again. [CN] 刷新成功后加载尾可再次加载。
    if (self.resetsFooterAfterRefresh && self.lastRefreshSucceeded && self.scrollView.cyl_footer.isNoMoreData) {
        [self.scrollView.cyl_footer resetNoMoreData];
    }
    // 保存刷新时间
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:self.lastUpdatedTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.retracting = YES;
    BOOL addedInset = self.cyl_addedRefreshingInset;
    self.cyl_addedRefreshingInset = NO;
    if (!addedInset) {
        // [EN] Front added no inset, so there is nothing to restore. [CN] 前置没有加 inset，无需恢复。
        self.retracting = NO;
        self.pullingPercent = 0.0;
        if (self.endRefreshingCompletionBlock) self.endRefreshingCompletionBlock();
        return;
    }

    // 默认使用 UIViewAnimation 动画
    if (!self.isCollectionViewAnimationBug) {
        // 恢复inset和offset
        [UIView animateWithDuration:self.slowAnimationDuration delay:0 options:self.reboundAnimationOptions animations:^{
            [self setRefreshingInsetTop:self.scrollView.cyl_insetT + self.insetTDelta];

            if (self.endRefreshingAnimationBeginAction) {
                self.endRefreshingAnimationBeginAction();
            }
            // 自动调整透明度
            if (self.isAutomaticallyChangeAlpha) self.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.retracting = NO;
            self.pullingPercent = 0.0;

            if (self.endRefreshingCompletionBlock) {
                self.endRefreshingCompletionBlock();
            }
        }];

        return;
    }

    /**
     这个解决方法的思路出自 https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/844
     修改了用+ [UIView animateWithDuration: animations:]实现的修改contentInset的动画
     fix issue#225 https://github.com/ChenYilong/CYLTableViewPlaceHolder/issues/225
     另一种解法 pull#737 https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/737

     同时, 处理了 Refreshing 中的动画替换.
    */

    // 由于修改 Inset 会导致 self.pullingPercent 联动设置 self.alpha, 故提前获取 alpha 值, 后续用于还原 alpha 动画
    CGFloat viewAlpha = self.alpha;

    [self setRefreshingInsetTop:self.scrollView.cyl_insetT + self.insetTDelta];
    // 禁用交互, 如果不禁用可能会引起渲染问题.
    self.scrollView.userInteractionEnabled = NO;

    //CAAnimation keyPath 不支持 contentInset 用Bounds的动画代替
    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithCGRect:CGRectOffset(self.scrollView.bounds, 0, self.insetTDelta)];
    boundsAnimation.duration = self.slowAnimationDuration;
    //在delegate里移除
    boundsAnimation.removedOnCompletion = NO;
    boundsAnimation.fillMode = kCAFillModeBoth;
    boundsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    boundsAnimation.delegate = self;
    [boundsAnimation setValue:CYLRefreshHeaderRefreshing2IdleBoundsKey forKey:@"identity"];

    [self.scrollView.layer addAnimation:boundsAnimation forKey:CYLRefreshHeaderRefreshing2IdleBoundsKey];

    if (self.endRefreshingAnimationBeginAction) {
        self.endRefreshingAnimationBeginAction();
    }
    // 自动调整透明度的动画
    if (self.isAutomaticallyChangeAlpha) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @(viewAlpha);
        opacityAnimation.toValue = @(0.0);
        opacityAnimation.duration = self.slowAnimationDuration;
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.layer addAnimation:opacityAnimation forKey:@"CYLRefreshHeaderRefreshing2IdleOpacity"];

        // 由于修改了 inset 导致, pullingPercent 被设置值, alpha 已经被提前修改为 0 了. 所以这里不用置 0, 但为了代码的严谨性, 不依赖其他的特殊实现方式, 这里还是置 0.
        self.alpha = 0;
    }
}

- (void)headerRefreshingAction {
    self.insetTDelta = 0;
    if (![self cyl_movesContentWhileRefreshing]) {
        // [EN] Front: the content stays where it is. [CN] 前置：内容保持不动。
        self.cyl_addedRefreshingInset = NO;
        [self executeRefreshingCallback];
        return;
    }
    self.cyl_addedRefreshingInset = YES;
    // 默认使用 UIViewAnimation 动画
    if (!self.isCollectionViewAnimationBug) {
        [UIView animateWithDuration:self.fastAnimationDuration animations:^{
            if (self.scrollView.panGestureRecognizer.state != UIGestureRecognizerStateCancelled) {
                CGFloat top = self.scrollViewOriginalInset.top + self.expandHeight;
                // [EN] From the original top, not the current one: resetInset may already have moved the inset while
                //      the pull was released, and a delta measured from there is wrong by that much.
                // [CN] 以原始 top 计算，而不是当前 top：松手时 resetInset 可能已移动过 inset，从那里量出的差值会差出同样的量。
                self.insetTDelta = self.scrollViewOriginalInset.top - top;
                // 增加滚动区域top
                [self setRefreshingInsetTop:top];
                // 设置滚动位置
                CGPoint offset = self.scrollView.contentOffset;
                offset.y = -top;
                [self.scrollView setContentOffset:offset animated:NO];
            }
        } completion:^(BOOL finished) {
            [self executeRefreshingCallback];
        }];
        return;
    }

    if (self.scrollView.panGestureRecognizer.state != UIGestureRecognizerStateCancelled) {
        CGFloat top = self.scrollViewOriginalInset.top + self.expandHeight;
        // 禁用交互, 如果不禁用可能会引起渲染问题.
        self.scrollView.userInteractionEnabled = NO;

        // CAAnimation keyPath不支持 contentOffset 用Bounds的动画代替
        CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        CGRect bounds = self.scrollView.bounds;
        bounds.origin.y = -top;
        boundsAnimation.fromValue = [NSValue valueWithCGRect:self.scrollView.bounds];
        boundsAnimation.toValue = [NSValue valueWithCGRect:bounds];
        boundsAnimation.duration = self.fastAnimationDuration;
        //在delegate里移除
        boundsAnimation.removedOnCompletion = NO;
        boundsAnimation.fillMode = kCAFillModeBoth;
        boundsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        boundsAnimation.delegate = self;
        [boundsAnimation setValue:CYLRefreshHeaderRefreshingBoundsKey forKey:@"identity"];
        [self.scrollView.layer addAnimation:boundsAnimation forKey:CYLRefreshHeaderRefreshingBoundsKey];
    } else {
        [self executeRefreshingCallback];
    }
}

#pragma mark . 链式语法部分 .

- (instancetype)cyl_linkTo:(UIScrollView *)scrollView {
    scrollView.cyl_header = self;
    return self;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *identity = [anim valueForKey:@"identity"];
    if ([identity isEqualToString:CYLRefreshHeaderRefreshing2IdleBoundsKey]) {
        self.retracting = NO;
        self.pullingPercent = 0.0;
        self.scrollView.userInteractionEnabled = YES;
        if (self.endRefreshingCompletionBlock) {
            self.endRefreshingCompletionBlock();
        }
    } else if ([identity isEqualToString:CYLRefreshHeaderRefreshingBoundsKey]) {
        // 避免出现 end 先于 Refreshing 状态
        if (self.state != CYLRefreshStateIdle) {
            CGFloat top = self.scrollViewOriginalInset.top + self.expandHeight;
            // [EN] From the original top (see headerRefreshingAction). [CN] 以原始 top 计算（见 headerRefreshingAction）。
            self.insetTDelta = self.scrollViewOriginalInset.top - top;
            [self setRefreshingInsetTop:top];
            // 设置最终滚动位置
            CGPoint offset = self.scrollView.contentOffset;
            offset.y = -top;
            [self.scrollView setContentOffset:offset animated:NO];
         }
        self.scrollView.userInteractionEnabled = YES;
        [self executeRefreshingCallback];
    }

    if ([self.scrollView.layer animationForKey:CYLRefreshHeaderRefreshing2IdleBoundsKey]) {
        [self.scrollView.layer removeAnimationForKey:CYLRefreshHeaderRefreshing2IdleBoundsKey];
    }

    if ([self.scrollView.layer animationForKey:CYLRefreshHeaderRefreshingBoundsKey]) {
        [self.scrollView.layer removeAnimationForKey:CYLRefreshHeaderRefreshingBoundsKey];
    }
}

#pragma mark - 公共方法
- (void)setLastUpdatedTime:(NSDate *)lastUpdatedTime
{
    if (lastUpdatedTime) {
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdatedTime forKey:self.lastUpdatedTimeKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.lastUpdatedTimeKey];
    }
    // [EN] Re-setting the key makes state headers redraw the time. [CN] 重新设置 key，带文字的刷新头会重新显示时间。
    self.lastUpdatedTimeKey = self.lastUpdatedTimeKey;
}

- (NSDate *)lastUpdatedTime
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:self.lastUpdatedTimeKey];
}

- (void)setIgnoredScrollViewContentInsetTop:(CGFloat)ignoredScrollViewContentInsetTop {
    _ignoredScrollViewContentInsetTop = ignoredScrollViewContentInsetTop;

    self.cyl_y = - self.cyl_h - _ignoredScrollViewContentInsetTop;
}

@end
