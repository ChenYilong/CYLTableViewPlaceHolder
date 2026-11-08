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

NSString * const CYLRefreshHeaderRefreshing2IdleBoundsKey = @"CYLRefreshHeaderRefreshing2IdleBounds";
NSString * const CYLRefreshHeaderRefreshingBoundsKey = @"CYLRefreshHeaderRefreshingBounds";

@interface CYLRefreshHeader() <CAAnimationDelegate>
@property (assign, nonatomic) CGFloat insetTDelta;
@end

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
}

- (void)placeSubviews
{
    [super placeSubviews];

    // 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
    self.cyl_y = - self.cyl_h - self.ignoredScrollViewContentInsetTop;
}

- (void)resetInset {
    if (@available(iOS 11.0, *)) {
    } else {
        // 如果 iOS 10 及以下系统在刷新时, push 新的 VC, 等待刷新完成后回来, 会导致顶部 Insets.top 异常, 不能 resetInset, 检查一下这种特殊情况
        if (!self.window) { return; }
    }

    // sectionheader停留解决
    CGFloat insetT = - self.scrollView.cyl_offsetY > _scrollViewOriginalInset.top ? - self.scrollView.cyl_offsetY : _scrollViewOriginalInset.top;
    insetT = insetT > self.cyl_h + _scrollViewOriginalInset.top ? self.cyl_h + _scrollViewOriginalInset.top : insetT;
    self.insetTDelta = _scrollViewOriginalInset.top - insetT;
    // 避免 CollectionView 在使用根据 Autolayout 和 内容自动伸缩 Cell, 刷新时导致的 Layout 异常渲染问题
    if (fabs(self.scrollView.cyl_insetT - insetT) > FLT_EPSILON) {
        self.scrollView.cyl_insetT = insetT;
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];

    // 在刷新的refreshing状态
    if (self.state == CYLRefreshStateRefreshing) {
        [self resetInset];
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

    // 普通 和 即将刷新 的临界点
    CGFloat normal2pullingOffsetY = happenOffsetY - self.cyl_h;
    CGFloat pullingPercent = (happenOffsetY - offsetY) / self.cyl_h;

    if (self.scrollView.isDragging) { // 如果正在拖拽
        self.pullingPercent = pullingPercent;
        if (self.state == CYLRefreshStateIdle && offsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = CYLRefreshStatePulling;
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

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState

    // 根据状态做事情
    if (state == CYLRefreshStateIdle) {
        if (oldState != CYLRefreshStateRefreshing) return;

        [self headerEndingAction];
    } else if (state == CYLRefreshStateRefreshing) {
        [self headerRefreshingAction];
    }
}

- (void)headerEndingAction {
    // 保存刷新时间
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:self.lastUpdatedTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // 默认使用 UIViewAnimation 动画
    if (!self.isCollectionViewAnimationBug) {
        // 恢复inset和offset
        [UIView animateWithDuration:self.slowAnimationDuration animations:^{
            self.scrollView.cyl_insetT += self.insetTDelta;

            if (self.endRefreshingAnimationBeginAction) {
                self.endRefreshingAnimationBeginAction();
            }
            // 自动调整透明度
            if (self.isAutomaticallyChangeAlpha) self.alpha = 0.0;
        } completion:^(BOOL finished) {
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

    self.scrollView.cyl_insetT += self.insetTDelta;
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
    // 默认使用 UIViewAnimation 动画
    if (!self.isCollectionViewAnimationBug) {
        [UIView animateWithDuration:self.fastAnimationDuration animations:^{
            if (self.scrollView.panGestureRecognizer.state != UIGestureRecognizerStateCancelled) {
                CGFloat top = self.scrollViewOriginalInset.top + self.cyl_h;
                // 增加滚动区域top
                self.scrollView.cyl_insetT = top;
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
        CGFloat top = self.scrollViewOriginalInset.top + self.cyl_h;
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
        self.pullingPercent = 0.0;
        self.scrollView.userInteractionEnabled = YES;
        if (self.endRefreshingCompletionBlock) {
            self.endRefreshingCompletionBlock();
        }
    } else if ([identity isEqualToString:CYLRefreshHeaderRefreshingBoundsKey]) {
        // 避免出现 end 先于 Refreshing 状态
        if (self.state != CYLRefreshStateIdle) {
            CGFloat top = self.scrollViewOriginalInset.top + self.cyl_h;
            self.scrollView.cyl_insetT = top;
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
- (NSDate *)lastUpdatedTime
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:self.lastUpdatedTimeKey];
}

- (void)setIgnoredScrollViewContentInsetTop:(CGFloat)ignoredScrollViewContentInsetTop {
    _ignoredScrollViewContentInsetTop = ignoredScrollViewContentInsetTop;

    self.cyl_y = - self.cyl_h - _ignoredScrollViewContentInsetTop;
}

@end
