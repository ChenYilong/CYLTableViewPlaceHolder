//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshFooter.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/5.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshFooter.h"
#import "UIScrollView+CYLRefresh.h"
#import "UIView+CYLExtension.h"
#import "UIScrollView+CYLExtension.h"

@interface CYLRefreshFooter()

@end

@implementation CYLRefreshFooter
#pragma mark - 构造方法
+ (instancetype)footerWithRefreshingBlock:(CYLRefreshComponentAction)refreshingBlock
{
    CYLRefreshFooter *cmp = [[self alloc] init];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}
+ (instancetype)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    CYLRefreshFooter *cmp = [[self alloc] init];
    [cmp setRefreshingTarget:target refreshingAction:action];
    return cmp;
}

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];

    // 设置自己的高度
    self.cyl_h = CYLRefreshFooterHeight;

    // 默认不会自动隐藏
//    self.automaticallyHidden = NO;
}

#pragma mark . 链式语法部分 .

- (instancetype)cyl_linkTo:(UIScrollView *)scrollView {
    scrollView.cyl_footer = self;
    return self;
}

#pragma mark - 公共方法
- (void)endRefreshingWithNoMoreData
{
    if (NSThread.isMainThread) {
        self.state = CYLRefreshStateNoMoreData;
    } else {
        CYLRefreshDispatchAsyncOnMainQueue(self.state = CYLRefreshStateNoMoreData;)
    }
}

- (void)noticeNoMoreData
{
    [self endRefreshingWithNoMoreData];
}

- (void)resetNoMoreData
{
    if (NSThread.isMainThread) {
        self.state = CYLRefreshStateIdle;
    } else {
        CYLRefreshDispatchAsyncOnMainQueue(self.state = CYLRefreshStateIdle;)
    }
}

- (void)setAutomaticallyHidden:(BOOL)automaticallyHidden
{
    _automaticallyHidden = automaticallyHidden;
}
- (BOOL)isNoMoreData
{
    return self.state == CYLRefreshStateNoMoreData;
}

#pragma mark - Auto-hide

/// [EN] Idle (or showing "no more data") and wholly below the bottom bars' edge, where a glass tab bar would show it.
/// [CN] 空闲（或显示“无更多数据”）且完全位于底部栏边缘之下，即玻璃 tab bar 会透出它的位置。
- (BOOL)isReadyToAutoHide
{
    if (self.state != CYLRefreshStateIdle && self.state != CYLRefreshStateNoMoreData) return NO;
    UIScrollView *scrollView = self.scrollView;
    if (!scrollView) return YES;
    CGFloat visibleBottom = scrollView.cyl_offsetY + CGRectGetHeight(scrollView.bounds) - self.scrollViewOriginalInset.bottom;
    return CGRectGetMinY(self.frame) >= visibleBottom - 0.5;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    [self updateAutoHideVisibility];
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    [self updateAutoHideVisibility];
}

- (void)setState:(CYLRefreshState)state
{
    [super setState:state];
    [self updateAutoHideVisibility];
}

- (void)placeSubviews
{
    [super placeSubviews];
    [self updateAutoHideVisibility];
}

@end
