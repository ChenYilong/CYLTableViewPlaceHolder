//
//  CYLRefreshAutoFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshAutoFooter.h"
#import "NSBundle+CYLRefresh.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"
#import "UIScrollView+CYLRefresh.h"
#import "CYLRefreshHeader.h"
#import <float.h>
#import <math.h>

@interface CYLRefreshAutoFooter()
/** 一个新的拖拽 */
@property (nonatomic) BOOL triggerByDrag;
@property (nonatomic) NSInteger leftTriggerTimes;
@end

@implementation CYLRefreshAutoFooter

#pragma mark - 初始化
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    UIScrollView *oldScrollView = self.scrollView;
    if (oldScrollView && self.hidden == NO) {
        oldScrollView.cyl_insetB -= self.cyl_h;
    }
    [super willMoveToSuperview:newSuperview];

    if (self.scrollView) { // 新的父控件
        if (self.hidden == NO) {
            self.scrollView.cyl_insetB += self.cyl_h;
        }

        // 设置位置
        self.cyl_y = _scrollView.cyl_contentH + self.ignoredScrollViewContentInsetBottom;
    }
}

#pragma mark - 实现父类的方法
- (void)prepare
{
    [super prepare];

    // 默认底部控件100%出现时才会自动刷新
    self.triggerAutomaticallyRefreshPercent = 1.0;

    // 设置为默认状态
    self.automaticallyRefresh = YES;

    self.autoTriggerTimes = 1;
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];

    CGSize size = [change[NSKeyValueChangeNewKey] CGSizeValue];
    CGFloat contentHeight = size.height == 0 ? self.scrollView.cyl_contentH : size.height;
    // 设置位置
    CGFloat y = contentHeight + self.ignoredScrollViewContentInsetBottom;
    if (self.cyl_y != y) {
        self.cyl_y = y;
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];

    if (self.state != CYLRefreshStateIdle || !self.automaticallyRefresh || !self.refreshEnabled || self.cyl_y == 0 ||
        self.scrollView.cyl_header.isRefreshing) return;

    if (_scrollView.cyl_insetT + _scrollView.cyl_contentH > _scrollView.cyl_h) { // 内容超过一个屏幕
        // 这里的_scrollView.cyl_contentH替换掉self.cyl_y更为合理
        if (_scrollView.cyl_offsetY >= _scrollView.cyl_contentH - _scrollView.cyl_h + self.cyl_h * self.triggerAutomaticallyRefreshPercent + _scrollView.cyl_insetB - self.cyl_h) {
            // 防止手松开时连续调用
            CGPoint old = [change[@"old"] CGPointValue];
            CGPoint new = [change[@"new"] CGPointValue];
            if (new.y <= old.y) return;
            if (new.y <= -self.scrollView.cyl_insetT) return;

            if (_scrollView.isDragging) {
                self.triggerByDrag = YES;
            }
            // 当底部刷新控件完全出现时，才刷新
            [self beginRefreshing];
        }
    }
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];

    // [EN] loadsAfterNoMoreData: a pull at the end loads again. [CN] loadsAfterNoMoreData：在底部上拉时再次加载。
    if (self.state == CYLRefreshStateNoMoreData && self.loadsAfterNoMoreData &&
        _scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self resetNoMoreData];
    }
    if (self.state != CYLRefreshStateIdle || !self.refreshEnabled || self.scrollView.cyl_header.isRefreshing) return;

    UIGestureRecognizerState panState = _scrollView.panGestureRecognizer.state;

    switch (panState) {
        // 手松开
        case UIGestureRecognizerStateEnded: {
            if (_scrollView.cyl_insetT + _scrollView.cyl_contentH <= _scrollView.cyl_h) {  // 不够一个屏幕
                if (_scrollView.cyl_offsetY >= - _scrollView.cyl_insetT) { // 向上拽
                    self.triggerByDrag = YES;
                    [self beginRefreshing];
                }
            } else { // 超出一个屏幕
                CGFloat threshold = _scrollView.cyl_contentH + _scrollView.cyl_insetB - _scrollView.cyl_h;
                CGFloat offset = _scrollView.cyl_offsetY;
                CGFloat epsilon = sizeof(CGFloat) == sizeof(double) ? DBL_EPSILON : FLT_EPSILON;
                // Allow arithmetic rounding error without treating a visible gap as the bottom.
                CGFloat tolerance = 64 * epsilon * MAX(1, MAX(fabs(offset), fabs(threshold)));
                if (offset >= threshold - tolerance) {
                    self.triggerByDrag = YES;
                    [self beginRefreshing];
                }
            }
        }
            break;

        case UIGestureRecognizerStateBegan: {
            [self resetTriggerTimes];
        }
            break;

        default:
            break;
    }
}

- (BOOL)unlimitedTrigger {
    return self.leftTriggerTimes == -1;
}

- (void)beginRefreshing
{
    if (self.triggerByDrag && self.leftTriggerTimes <= 0 && !self.unlimitedTrigger) {
        return;
    }

    [super beginRefreshing];
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

    if (state == CYLRefreshStateRefreshing) {
        [self executeRefreshingCallback];
    } else if (state == CYLRefreshStateNoMoreData || state == CYLRefreshStateIdle) {
        if (self.triggerByDrag) {
            if (!self.unlimitedTrigger) {
                self.leftTriggerTimes -= 1;
            }
            self.triggerByDrag = NO;
        }

        if (CYLRefreshStateRefreshing == oldState) {
            if (self.scrollView.pagingEnabled) {
                [UIView animateWithDuration:self.slowAnimationDuration animations:^{
                    if (!self.scrollView.isDragging && !self.scrollView.isDecelerating) {
                        CGPoint offset = self.scrollView.contentOffset;
                        CGFloat bottomInset = self.scrollView.cyl_insetB - (self.hidden ? 0 : self.cyl_h);
                        CGFloat maximumOffset = MAX(-self.scrollView.cyl_insetT,
                                                    self.scrollView.cyl_contentH + bottomInset - self.scrollView.cyl_h);
                        if (offset.y > maximumOffset) {
                            offset.y = maximumOffset;
                            self.scrollView.contentOffset = offset;
                        }
                    }

                    if (self.endRefreshingAnimationBeginAction) {
                        self.endRefreshingAnimationBeginAction();
                    }
                } completion:^(BOOL finished) {
                    if (self.endRefreshingCompletionBlock) {
                        self.endRefreshingCompletionBlock();
                    }
                }];
                return;
            }

            if (self.endRefreshingCompletionBlock) {
                self.endRefreshingCompletionBlock();
            }
        }
    }
}

- (void)resetTriggerTimes {
    self.leftTriggerTimes = self.autoTriggerTimes;
}

- (void)setHidden:(BOOL)hidden
{
    BOOL lastHidden = self.isHidden;

    [super setHidden:hidden];

    if (!lastHidden && hidden) {
        self.state = CYLRefreshStateIdle;

        self.scrollView.cyl_insetB -= self.cyl_h;
    } else if (lastHidden && !hidden) {
        self.scrollView.cyl_insetB += self.cyl_h;

        // 设置位置
        self.cyl_y = _scrollView.cyl_contentH + self.ignoredScrollViewContentInsetBottom;
    }
}

- (void)setAutoTriggerTimes:(NSInteger)autoTriggerTimes {
    _autoTriggerTimes = autoTriggerTimes;
    self.leftTriggerTimes = autoTriggerTimes;
}
@end
