//
//  CYLRefreshTrailer.m
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "CYLRefreshTrailer.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLRefresh.h"
#import "UIScrollView+CYLExtension.h"
#import "CYLRefreshHeader.h"
#import "CYLRefreshFooter.h"

@interface CYLRefreshTrailer()
@property (assign, nonatomic) NSInteger lastRefreshCount;
@property (assign, nonatomic) CGFloat lastRightDelta;
@property (assign, nonatomic) BOOL previousHorizontalBounce;
@property (assign, nonatomic) BOOL previousVerticalBounce;
@property (assign, nonatomic) NSUInteger refreshGeneration;
/** The current refresh was started automatically by a drag. */
@property (assign, nonatomic) BOOL triggerByDrag;
@property (assign, nonatomic) NSInteger leftTriggerTimes;
@end

@implementation CYLRefreshTrailer

#pragma mark - 构造方法
+ (instancetype)trailerWithRefreshingBlock:(CYLRefreshComponentAction)refreshingBlock {
    CYLRefreshTrailer *cmp = [[self alloc] init];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}

+ (instancetype)trailerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    CYLRefreshTrailer *cmp = [[self alloc] init];
    [cmp setRefreshingTarget:target refreshingAction:action];
    return cmp;
}

- (void)prepare {
    [super prepare];

    self.triggerAutomaticallyRefreshPercent = 1.0;
    self.autoTriggerTimes = 1;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];

    // 如果正在刷新，直接返回
    if (self.state == CYLRefreshStateRefreshing) return;

    _scrollViewOriginalInset = self.scrollView.cyl_inset;

    // 当前的contentOffset
    CGFloat currentOffsetX = self.scrollView.cyl_offsetX;
    // 尾部控件刚好出现的offsetX
    CGFloat happenOffsetX = [self happenOffsetX];
    // 如果是向右滚动到看不见右边控件，直接返回
    if (currentOffsetX <= happenOffsetX) return;

    CGFloat pullingPercent = (currentOffsetX - happenOffsetX) / (self.cyl_w * self.triggerRate);

    // 如果已全部加载，仅设置pullingPercent，然后返回
    if (self.state == CYLRefreshStateNoMoreData) {
        self.pullingPercent = pullingPercent;
        return;
    }

    if ([self shouldAutomaticallyRefreshWithChange:change pullingPercent:pullingPercent]) {
        self.triggerByDrag = self.scrollView.isDragging;
        [self beginRefreshing];
        return;
    }

    if (self.scrollView.isDragging) {
        self.pullingPercent = pullingPercent;
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetX = happenOffsetX + self.cyl_w * self.triggerRate;

        if (self.state == CYLRefreshStateIdle && currentOffsetX > normal2pullingOffsetX) {
            self.state = CYLRefreshStatePulling;
        } else if (self.state == CYLRefreshStatePulling && currentOffsetX <= normal2pullingOffsetX) {
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

- (BOOL)shouldAutomaticallyRefreshWithChange:(NSDictionary *)change pullingPercent:(CGFloat)pullingPercent {
    if (!self.automaticallyRefresh) return NO;
    if (self.state != CYLRefreshStateIdle && self.state != CYLRefreshStatePulling) return NO;
    // Content narrower than the view keeps the pull-and-release behavior.
    if ([self widthForContentBreakView] <= 0) return NO;
    if (self.scrollView.cyl_header.isRefreshing || self.scrollView.cyl_footer.isRefreshing) return NO;
    if (pullingPercent < self.triggerAutomaticallyRefreshPercent) return NO;

    // Only while moving toward the end, so bouncing back does not trigger again.
    id oldValue = change[NSKeyValueChangeOldKey];
    id newValue = change[NSKeyValueChangeNewKey];
    if ([oldValue isKindOfClass:NSValue.class] && [newValue isKindOfClass:NSValue.class] &&
        [newValue CGPointValue].x <= [oldValue CGPointValue].x) return NO;

    if (self.scrollView.isDragging && self.leftTriggerTimes != -1 && self.leftTriggerTimes <= 0) return NO;
    return YES;
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change {
    [super scrollViewPanStateDidChange:change];

    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.leftTriggerTimes = self.autoTriggerTimes;
    }
}

- (void)setAutoTriggerTimes:(NSInteger)autoTriggerTimes {
    _autoTriggerTimes = autoTriggerTimes;
    self.leftTriggerTimes = autoTriggerTimes;
}

- (void)setState:(CYLRefreshState)state {
    CYLRefreshCheckState
    if ((state == CYLRefreshStateNoMoreData || state == CYLRefreshStateIdle) && self.triggerByDrag) {
        if (self.leftTriggerTimes != -1) {
            self.leftTriggerTimes -= 1;
        }
        self.triggerByDrag = NO;
    }
    // 根据状态来设置属性
    if (state == CYLRefreshStateNoMoreData || state == CYLRefreshStateIdle) {
        // 刷新完毕
        if (CYLRefreshStateRefreshing == oldState) {
            NSUInteger generation = self.refreshGeneration;
            CYLRefreshComponentAction completion = self.endRefreshingCompletionBlock;
            [UIView animateWithDuration:self.slowAnimationDuration animations:^{
                if (self.endRefreshingAnimationBeginAction) {
                    self.endRefreshingAnimationBeginAction();
                }

                self.scrollView.cyl_insetR -= self.lastRightDelta;
                // 自动调整透明度
                if (self.isAutomaticallyChangeAlpha) self.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (self.refreshGeneration == generation && !self.isRefreshing) {
                    self.pullingPercent = 0.0;
                }

                if (completion) {
                    completion();
                }
            }];
        }

        CGFloat deltaW = [self widthForContentBreakView];
        // 刚刷新完毕
        if (CYLRefreshStateRefreshing == oldState && deltaW > 0 && self.scrollView.cyl_totalDataCount != self.lastRefreshCount) {
            self.scrollView.cyl_offsetX = self.scrollView.cyl_offsetX;
        }
    } else if (state == CYLRefreshStateRefreshing) {
        NSUInteger generation = ++self.refreshGeneration;
        // 记录刷新前的数量
        self.lastRefreshCount = self.scrollView.cyl_totalDataCount;

        [UIView animateWithDuration:self.fastAnimationDuration animations:^{
            CGFloat right = self.cyl_w + self.scrollViewOriginalInset.right;
            CGFloat deltaW = [self widthForContentBreakView];
            if (deltaW < 0) { // 如果内容宽度小于view的宽度
                right -= deltaW;
            }
            self.lastRightDelta = right - self.scrollView.cyl_insetR;
            self.scrollView.cyl_insetR = right;

            // 设置滚动位置
            CGPoint offset = self.scrollView.contentOffset;
            offset.x = [self happenOffsetX] + self.cyl_w;
            [self.scrollView setContentOffset:offset animated:NO];
        } completion:^(BOOL finished) {
            if (self.refreshGeneration == generation && self.state == CYLRefreshStateRefreshing) {
                [self executeRefreshingCallback];
            }
        }];
    }
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {
    [super scrollViewContentSizeDidChange:change];

    // 内容的宽度
    CGFloat contentWidth = self.scrollView.cyl_contentW + self.ignoredScrollViewContentInsetRight;
    // 表格的宽度
    CGFloat scrollWidth = self.scrollView.cyl_w - self.scrollViewOriginalInset.left - self.scrollViewOriginalInset.right + self.ignoredScrollViewContentInsetRight;
    // 设置位置和尺寸
    self.cyl_x = MAX(contentWidth, scrollWidth);
}

- (void)placeSubviews {
    [super placeSubviews];

    self.cyl_h = _scrollView.cyl_h;
    // 设置自己的宽度
    self.cyl_w = CYLRefreshTrailWidth;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    UIScrollView *oldScrollView = self.scrollView;
    if (oldScrollView) {
        if (self.state == CYLRefreshStateRefreshing) {
            [self endRefreshing];
        } else if (self.state == CYLRefreshStateWillRefresh) {
            [super setState:CYLRefreshStateIdle];
        }
        if (oldScrollView.alwaysBounceHorizontal) {
            oldScrollView.alwaysBounceHorizontal = self.previousHorizontalBounce;
        }
        if (!oldScrollView.alwaysBounceVertical) {
            oldScrollView.alwaysBounceVertical = self.previousVerticalBounce || oldScrollView.cyl_header != nil || oldScrollView.cyl_footer != nil;
        }
    }

    UIScrollView *newScrollView = [newSuperview isKindOfClass:UIScrollView.class] ? (UIScrollView *)newSuperview : nil;
    if (newScrollView) {
        self.previousHorizontalBounce = newScrollView.alwaysBounceHorizontal;
        self.previousVerticalBounce = newScrollView.alwaysBounceVertical;
    }
    [super willMoveToSuperview:newSuperview];

    if (newScrollView) {
        // 设置支持水平弹簧效果
        newScrollView.alwaysBounceHorizontal = YES;
        newScrollView.alwaysBounceVertical = NO;
    }
}

#pragma mark . 链式语法部分 .

- (instancetype)cyl_linkTo:(UIScrollView *)scrollView {
    scrollView.cyl_trailer = self;
    return self;
}

#pragma mark - 刚好看到上拉刷新控件时的contentOffset.x
- (CGFloat)happenOffsetX {
    CGFloat deltaW = [self widthForContentBreakView];
    if (deltaW > 0) {
        return deltaW - self.scrollViewOriginalInset.left;
    } else {
        return - self.scrollViewOriginalInset.left;
    }
}

#pragma mark 获得scrollView的内容 超出 view 的宽度
- (CGFloat)widthForContentBreakView {
    CGFloat w = self.scrollView.frame.size.width - self.scrollViewOriginalInset.right - self.scrollViewOriginalInset.left;
    return self.scrollView.contentSize.width - w;
}

/// [EN] A trailer opens sideways: its open size is its width. [CN] trailer 横向展开：展开尺寸是它的宽度。
- (CGFloat)expandHeight
{
    return self.cyl_w;
}

@end
