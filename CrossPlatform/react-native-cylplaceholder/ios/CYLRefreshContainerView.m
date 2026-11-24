#import "CYLRefreshContainerView.h"
#if __has_include(<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>)
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>
#else
#import "CYLTableViewPlaceHolder.h"
#endif

@implementation CYLRefreshContainerView {
    CYLRefreshHeader *_header;
    CYLRefreshFooter *_footer;
    // The refresh JavaScript asked for runs its refreshing block too; that block must not call the event back.
    BOOL _refreshAskedByJS;
    BOOL _loadAskedByJS;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _enabled = YES;
        // [EN] The header rests above the container and React Native lets children draw outside their parent: clip, as Android does.
        // [CN] 头部静止时在容器上方，而 React Native 允许子视图画到父视图外面：与 Android 一样裁剪。
        self.clipsToBounds = YES;
        _header = [self makeHeader];
        _footer = [self makeFooter];
    }
    return self;
}

// [EN] The header and footer of the chosen style (CYLRefreshStyleFactory; a missing style is the classic one without a report, an unknown one
//      is reported once with a log line). Their refreshing blocks call the events back unless JavaScript asked for the refresh.
// [CN] 所选样式的刷新头与刷新尾（CYLRefreshStyleFactory；未设置样式即经典样式且不报告，未知样式用一行日志报告一次）。
//      除非是 JavaScript 要求的刷新，它们的刷新块会回调事件。
- (CYLRefreshHeader *)makeHeader {
    __weak __typeof(self) weakSelf = self;
    CYLRefreshHeader *header = [CYLRefreshStyleFactory headerWithStyle:_headerStyle onUnknownStyle:^(NSString *name) {
        if (!name) return;
        NSLog(@"CYLRefreshContainer: unknown headerStyle %@, using classic", name);
    }];
    header.refreshingBlock = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (strongSelf->_refreshAskedByJS) { strongSelf->_refreshAskedByJS = NO; return; }
        if (strongSelf.onRefresh) strongSelf.onRefresh(@{});
    };
    return header;
}

- (CYLRefreshFooter *)makeFooter {
    __weak __typeof(self) weakSelf = self;
    CYLRefreshFooter *footer = [CYLRefreshStyleFactory footerWithStyle:_footerStyle onUnknownStyle:^(NSString *name) {
        if (!name) return;
        NSLog(@"CYLRefreshContainer: unknown footerStyle %@, using classic", name);
    }];
    footer.loadsAfterNoMoreData = _loadsAfterNoMoreData;
    footer.refreshingBlock = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (strongSelf->_loadAskedByJS) { strongSelf->_loadAskedByJS = NO; return; }
        if (strongSelf.onLoadMore) strongSelf.onLoadMore(@{});
    };
    return footer;
}

- (UIScrollView *)firstScrollViewIn:(UIView *)view {
    for (UIView *child in view.subviews) {
        if ([child isKindOfClass:UIScrollView.class]) return (UIScrollView *)child;
        UIScrollView *found = [self firstScrollViewIn:child];
        if (found) return found;
    }
    return nil;
}

// React Native adds the scroll view after creating this view, so it is looked for on every layout until found (and again when it left).
- (void)layoutSubviews {
    [super layoutSubviews];
    if (_scrollView && [_scrollView isDescendantOfView:self]) return;
    UIScrollView *scrollView = [self firstScrollViewIn:self];
    if (scrollView == _scrollView) return;
    _scrollView.cyl_header = nil;
    _scrollView.cyl_footer = nil;
    _scrollView = scrollView;
    [self applyState];
}

- (void)applyState {
    UIScrollView *scrollView = _scrollView;
    if (!scrollView) return;
    scrollView.cyl_header = _enabled ? _header : nil;
    scrollView.cyl_footer = _loadMoreEnabled ? _footer : nil;
    _footer.loadsAfterNoMoreData = _loadsAfterNoMoreData;
    if (_enabled) [self applyRefreshing];
    if (_loadMoreEnabled) [self applyLoading];
}

- (void)applyRefreshing {
    if (_refreshing == _header.isRefreshing) return;
    if (_refreshing) {
        _refreshAskedByJS = YES;
        [_header beginRefreshing];
    } else {
        _refreshAskedByJS = NO;
        [_header endRefreshing];
    }
}

- (void)applyLoading {
    if (_loadingMore != _footer.isRefreshing) {
        if (_loadingMore) {
            _loadAskedByJS = YES;
            [_footer beginRefreshing];
        } else {
            _loadAskedByJS = NO;
            [_footer endRefreshing];
        }
    }
    if (_noMoreData == _footer.isNoMoreData) return;
    if (!_noMoreData) [_footer resetNoMoreData];
    else [_footer endRefreshingWithNoMoreData];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self applyState];
}

- (void)setRefreshing:(BOOL)refreshing {
    _refreshing = refreshing;
    if (_enabled && _scrollView) [self applyRefreshing];
}

- (void)setLoadMoreEnabled:(BOOL)loadMoreEnabled {
    _loadMoreEnabled = loadMoreEnabled;
    [self applyState];
}

- (void)setLoadingMore:(BOOL)loadingMore {
    _loadingMore = loadingMore;
    if (_loadMoreEnabled && _scrollView) [self applyLoading];
}

- (void)setNoMoreData:(BOOL)noMoreData {
    _noMoreData = noMoreData;
    if (_loadMoreEnabled && _scrollView) [self applyLoading];
}

- (void)setHeaderStyle:(NSString *)headerStyle {
    if ((headerStyle == _headerStyle) || [headerStyle isEqualToString:_headerStyle]) return;
    _headerStyle = [headerStyle copy];
    if (_scrollView.cyl_header == _header) _scrollView.cyl_header = nil;
    _header = [self makeHeader];
    [self applyState];
}

- (void)setFooterStyle:(NSString *)footerStyle {
    if ((footerStyle == _footerStyle) || [footerStyle isEqualToString:_footerStyle]) return;
    _footerStyle = [footerStyle copy];
    if (_scrollView.cyl_footer == _footer) _scrollView.cyl_footer = nil;
    _footer = [self makeFooter];
    [self applyState];
}

- (void)setLoadsAfterNoMoreData:(BOOL)loadsAfterNoMoreData {
    _loadsAfterNoMoreData = loadsAfterNoMoreData;
    _footer.loadsAfterNoMoreData = loadsAfterNoMoreData;
}

@end
