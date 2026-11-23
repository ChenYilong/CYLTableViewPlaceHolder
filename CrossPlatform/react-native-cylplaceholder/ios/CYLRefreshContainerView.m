#import "CYLRefreshContainerView.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>

@implementation CYLRefreshContainerView {
    __weak UIScrollView *_scrollView;
    CYLRefreshNormalHeader *_header;
    BOOL _askedByJS;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _enabled = YES;
    }
    return self;
}

- (UIScrollView *)firstScrollViewIn:(UIView *)view {
    for (UIView *child in view.subviews) {
        if ([child isKindOfClass:UIScrollView.class]) return (UIScrollView *)child;
        UIScrollView *found = [self firstScrollViewIn:child];
        if (found) return found;
    }
    return nil;
}

// React Native adds the scroll view after creating this view, so it is looked for on every layout until found.
- (void)layoutSubviews {
    [super layoutSubviews];
    UIScrollView *scrollView = [self firstScrollViewIn:self];
    if (scrollView == _scrollView) return;
    _scrollView.cyl_header = nil;
    _scrollView = scrollView;
    if (!scrollView) return;
    __weak __typeof(self) weakSelf = self;
    _header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        // The refresh JavaScript asked for runs its refreshing block too; it must not call onRefresh back.
        if (strongSelf->_askedByJS) { strongSelf->_askedByJS = NO; return; }
        if (strongSelf.onRefresh) strongSelf.onRefresh(@{});
    }];
    scrollView.cyl_header = _header;
    _header.hidden = !_enabled;
    if (_refreshing) [self setRefreshing:YES];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    _header.hidden = !enabled;
}

- (void)setRefreshing:(BOOL)refreshing {
    _refreshing = refreshing;
    if (!_header || refreshing == _header.isRefreshing) return;
    if (refreshing) {
        _askedByJS = YES;
        [_header beginRefreshing];
    } else {
        _askedByJS = NO;
        [_header endRefreshing];
    }
}

@end
