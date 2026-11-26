#import "CYLRefreshContainerView.h"
#if __has_include(<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>)
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>
#else
#import "CYLTableViewPlaceHolder.h"
#endif

@implementation CYLRefreshContainerView {
    CYLRefreshHeader *_header;
    CYLRefreshFooter *_footer;
    // The refresh JavaScript asked for runs its refreshing block too; that block must not call the event back. The flag holds
    // until JavaScript ends the refresh, and a block that runs after the end (true then false within the 0.25 s inset
    // animation) is dropped because the control is no longer in CYLRefreshPhaseRefreshing (CYLRefreshShouldReport).
    BOOL _refreshAskedByJS;
    BOOL _loadAskedByJS;
    // The floor opened or closed because JavaScript set `secondaryOpen`: the matching event is not sent.
    BOOL _openAskedByJS;
    BOOL _closeAskedByJS;
    // The same for the footer's floor.
    BOOL _footerOpenAskedByJS;
    BOOL _footerCloseAskedByJS;
    // The child view with the floor's nativeID, once React Native has added it.
    UIView *_floorView;
    UIView *_footerFloorView;
    // The footer has no floor to give (an auto footer): said once, not on every style change.
    BOOL _footerFloorReported;
}

+ (NSString *)secondaryViewNativeID {
    return @"cyl.refresh.secondary";
}

+ (NSString *)footerSecondaryViewNativeID {
    return @"cyl.refresh.secondary.footer";
}

// React Native sets `nativeID` on its views (UIView+React); the container has no React import, so it is read by name, with the
// accessibilityIdentifier as the other place a host may put it.
static BOOL CYLHasNativeID(UIView *view, NSString *name) {
    if ([view respondsToSelector:NSSelectorFromString(@"nativeID")]) {
        id value = [view valueForKey:@"nativeID"];
        if ([value isKindOfClass:NSString.class] && [value isEqualToString:name]) return YES;
    }
    return [view.accessibilityIdentifier isEqualToString:name];
}

// A view that is the content of either floor.
static BOOL CYLIsFloorView(UIView *view) {
    return CYLHasNativeID(view, CYLRefreshContainerView.secondaryViewNativeID) ||
           CYLHasNativeID(view, CYLRefreshContainerView.footerSecondaryViewNativeID);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _enabled = YES;
        _secondaryCloseTriggerOffset = 80;
        _footerSecondaryCloseTriggerOffset = 80;
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
// [EN] Whether a refreshing block reports its event: not for a refresh JavaScript asked for, and not for a block that runs after
//      the refresh already ended (JavaScript set the value back within the begin's 0.25 s inset animation; the control is then
//      idle or finishing, not refreshing).
// [CN] 刷新块是否回调事件：JavaScript 要求的刷新不回调；刷新已结束后才运行的刷新块也不回调（JavaScript 在开始的 0.25 秒 inset 动画内
//      把值改回，此时控件处于空闲或结束停留，而不是刷新中）。
static BOOL CYLRefreshShouldReport(CYLRefreshComponent *component, BOOL askedByJS) {
    return !askedByJS && component.phase == CYLRefreshPhaseRefreshing;
}

- (CYLRefreshHeader *)makeHeader {
    __weak __typeof(self) weakSelf = self;
    NSString *styleName = _headerStyle;
    CYLRefreshHeader *header = [CYLRefreshStyleFactory headerWithStyle:styleName options:_headerRive onFallback:^(NSString *reason) {
        // A missing style is the classic one without a report.
        if (!styleName) return;
        NSLog(@"CYLRefreshContainer: headerStyle: %@, using classic", reason);
    }];
    __weak CYLRefreshHeader *weakHeader = header;
    header.refreshingBlock = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (!CYLRefreshShouldReport(weakHeader, strongSelf->_refreshAskedByJS)) return;
        if (strongSelf.onRefresh) strongSelf.onRefresh(@{});
    };
    header.secondaryOpenedBlock = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (strongSelf->_openAskedByJS) { strongSelf->_openAskedByJS = NO; return; }
        if (strongSelf.onSecondaryOpen) strongSelf.onSecondaryOpen(@{@"edge": @"header"});
    };
    header.secondaryClosedBlock = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (strongSelf->_closeAskedByJS) { strongSelf->_closeAskedByJS = NO; return; }
        if (strongSelf.onSecondaryClose) strongSelf.onSecondaryClose(@{@"edge": @"header"});
    };
    return header;
}

- (CYLRefreshFooter *)makeFooter {
    __weak __typeof(self) weakSelf = self;
    NSString *styleName = _footerStyle;
    CYLRefreshFooter *footer = [CYLRefreshStyleFactory footerWithStyle:styleName options:_footerRive onFallback:^(NSString *reason) {
        if (!styleName) return;
        NSLog(@"CYLRefreshContainer: footerStyle: %@, using classic", reason);
    }];
    footer.loadsAfterNoMoreData = _loadsAfterNoMoreData;
    __weak CYLRefreshFooter *weakFooter = footer;
    footer.refreshingBlock = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (!CYLRefreshShouldReport(weakFooter, strongSelf->_loadAskedByJS)) return;
        if (strongSelf.onLoadMore) strongSelf.onLoadMore(@{});
    };
    // [EN] The second floor is `CYLRefreshBackFooter`'s API: the drawn, state and normal back footers have it, the auto footer does not. The events
    //      carry `edge: "footer"`; a floor JavaScript asked for does not call them.
    // [CN] 二楼是 `CYLRefreshBackFooter` 的 API：手绘、状态与普通回弹尾部有，自动尾部没有。事件带 `edge: "footer"`；JavaScript 要求的二楼不回调。
    if ([footer isKindOfClass:CYLRefreshBackFooter.class]) {
        CYLRefreshBackFooter *backFooter = (CYLRefreshBackFooter *)footer;
        backFooter.secondaryOpenedBlock = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (strongSelf->_footerOpenAskedByJS) { strongSelf->_footerOpenAskedByJS = NO; return; }
            if (strongSelf.onSecondaryOpen) strongSelf.onSecondaryOpen(@{@"edge": @"footer"});
        };
        backFooter.secondaryClosedBlock = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (strongSelf->_footerCloseAskedByJS) { strongSelf->_footerCloseAskedByJS = NO; return; }
            if (strongSelf.onSecondaryClose) strongSelf.onSecondaryClose(@{@"edge": @"footer"});
        };
    }
    return footer;
}

// The footer as a back footer, nil for an auto footer (no second floor there).
- (CYLRefreshBackFooter *)backFooter {
    return [_footer isKindOfClass:CYLRefreshBackFooter.class] ? (CYLRefreshBackFooter *)_footer : nil;
}

- (UIView *)floorViewIn:(UIView *)view withNativeID:(NSString *)name {
    for (UIView *child in view.subviews) {
        if (CYLHasNativeID(child, name)) return child;
        UIView *found = [self floorViewIn:child withNativeID:name];
        if (found) return found;
    }
    return nil;
}

// The floor's own content may hold a scroll view: it is skipped.
- (UIScrollView *)firstScrollViewIn:(UIView *)view {
    for (UIView *child in view.subviews) {
        if (CYLIsFloorView(child)) continue;
        if ([child isKindOfClass:UIScrollView.class]) return (UIScrollView *)child;
        UIScrollView *found = [self firstScrollViewIn:child];
        if (found) return found;
    }
    return nil;
}

// React Native adds the scroll view after creating this view, so it is looked for on every layout until found (and again when it left).
- (void)layoutSubviews {
    [super layoutSubviews];
    [self attachFloorView];
    if (_scrollView && [_scrollView isDescendantOfView:self]) return;
    UIScrollView *scrollView = [self firstScrollViewIn:self];
    if (scrollView == _scrollView) return;
    _scrollView.cyl_header = nil;
    _scrollView.cyl_footer = nil;
    _scrollView = scrollView;
    [self applyState];
}

// The floor's content arrives as a child like the scroll view does; it becomes the header's `secondaryView` once found.
- (void)attachFloorView {
    if (!_floorView || ![_floorView isDescendantOfView:self]) {
        _floorView = [self floorViewIn:self withNativeID:CYLRefreshContainerView.secondaryViewNativeID];
        _header.secondaryView = _floorView;
    }
    if (!_footerFloorView || ![_footerFloorView isDescendantOfView:self]) {
        _footerFloorView = [self floorViewIn:self withNativeID:CYLRefreshContainerView.footerSecondaryViewNativeID];
        [self backFooter].secondaryView = _footerFloorView;
    }
}

- (void)applySecondary {
    _header.secondaryTriggerOffset = MAX(0, _secondaryTriggerOffset);
    _header.secondaryDimension = MAX(0, _secondaryDimension);
    _header.secondaryCloseTriggerOffset = _secondaryCloseTriggerOffset > 0 ? _secondaryCloseTriggerOffset : 80;
    _header.secondaryView = _floorView;
}

// The footer's floor fields; applied again whenever the footer is made again (a style change), as the blocks are.
- (void)applyFooterSecondary {
    CYLRefreshBackFooter *footer = [self backFooter];
    if (!footer) {
        if (_footerSecondaryTriggerOffset > 0 && !_footerFloorReported) {
            _footerFloorReported = YES;
            NSLog(@"CYLRefreshContainer: footerSecondaryTriggerOffset: the footer style has no second floor (an auto footer), ignored");
        }
        return;
    }
    footer.secondaryTriggerOffset = MAX(0, _footerSecondaryTriggerOffset);
    footer.secondaryDimension = MAX(0, _footerSecondaryDimension);
    footer.secondaryCloseTriggerOffset = _footerSecondaryCloseTriggerOffset > 0 ? _footerSecondaryCloseTriggerOffset : 80;
    footer.secondaryView = _footerFloorView;
}

- (void)applyFooterSecondaryOpen {
    CYLRefreshBackFooter *footer = [self backFooter];
    if (!_loadMoreEnabled || !_scrollView || !footer || _footerSecondaryOpen == footer.secondaryOpen) return;
    if (_footerSecondaryOpen) {
        _footerOpenAskedByJS = YES;
        [footer openSecondary];
        // Refused (loading, no scroll view): no opened block will come.
        if (!footer.secondaryOpen) _footerOpenAskedByJS = NO;
    } else {
        _footerCloseAskedByJS = YES;
        [footer closeSecondary];
        if (!footer.secondaryOpen) _footerCloseAskedByJS = NO;
    }
}

- (void)applySecondaryOpen {
    if (!_enabled || !_scrollView || _secondaryOpen == _header.secondaryOpen) return;
    if (_secondaryOpen) {
        _openAskedByJS = YES;
        [_header openSecondary];
        // Refused (refreshing, vetoed): no opened block will come.
        if (!_header.secondaryOpen) _openAskedByJS = NO;
    } else {
        _closeAskedByJS = YES;
        [_header closeSecondary];
        if (!_header.secondaryOpen) _closeAskedByJS = NO;
    }
}

- (void)applyState {
    UIScrollView *scrollView = _scrollView;
    if (!scrollView) return;
    scrollView.cyl_header = _enabled ? _header : nil;
    [self applySecondary];
    [self applySecondaryOpen];
    scrollView.cyl_footer = _loadMoreEnabled ? _footer : nil;
    _footer.loadsAfterNoMoreData = _loadsAfterNoMoreData;
    [self applyFooterSecondary];
    if (_enabled) [self applyRefreshing];
    if (_loadMoreEnabled) [self applyLoading];
    [self applyFooterSecondaryOpen];
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

// [EN] The `rive...` parameters of the `rive` style: only a header or footer of that style is made again. [CN] `rive` 样式的 `rive...` 参数：只有该样式的刷新头或刷新尾才会重新创建。
- (void)setHeaderRive:(NSDictionary *)headerRive {
    if ((headerRive == _headerRive) || [headerRive isEqualToDictionary:_headerRive]) return;
    _headerRive = [headerRive copy];
    if (![_headerStyle isEqualToString:@"rive"]) return;
    if (_scrollView.cyl_header == _header) _scrollView.cyl_header = nil;
    _header = [self makeHeader];
    [self applyState];
}

- (void)setFooterRive:(NSDictionary *)footerRive {
    if ((footerRive == _footerRive) || [footerRive isEqualToDictionary:_footerRive]) return;
    _footerRive = [footerRive copy];
    if (![_footerStyle isEqualToString:@"rive"]) return;
    if (_scrollView.cyl_footer == _footer) _scrollView.cyl_footer = nil;
    _footer = [self makeFooter];
    [self applyState];
}

- (void)setSecondaryTriggerOffset:(CGFloat)secondaryTriggerOffset {
    _secondaryTriggerOffset = secondaryTriggerOffset;
    [self applySecondary];
}

- (void)setSecondaryDimension:(CGFloat)secondaryDimension {
    _secondaryDimension = secondaryDimension;
    [self applySecondary];
}

- (void)setSecondaryCloseTriggerOffset:(CGFloat)secondaryCloseTriggerOffset {
    _secondaryCloseTriggerOffset = secondaryCloseTriggerOffset;
    [self applySecondary];
}

- (void)setSecondaryOpen:(BOOL)secondaryOpen {
    _secondaryOpen = secondaryOpen;
    [self applySecondaryOpen];
}

- (void)setFooterSecondaryTriggerOffset:(CGFloat)footerSecondaryTriggerOffset {
    _footerSecondaryTriggerOffset = footerSecondaryTriggerOffset;
    [self applyFooterSecondary];
}

- (void)setFooterSecondaryDimension:(CGFloat)footerSecondaryDimension {
    _footerSecondaryDimension = footerSecondaryDimension;
    [self applyFooterSecondary];
}

- (void)setFooterSecondaryCloseTriggerOffset:(CGFloat)footerSecondaryCloseTriggerOffset {
    _footerSecondaryCloseTriggerOffset = footerSecondaryCloseTriggerOffset;
    [self applyFooterSecondary];
}

- (void)setFooterSecondaryOpen:(BOOL)footerSecondaryOpen {
    _footerSecondaryOpen = footerSecondaryOpen;
    [self applyFooterSecondaryOpen];
}

- (void)setLoadsAfterNoMoreData:(BOOL)loadsAfterNoMoreData {
    _loadsAfterNoMoreData = loadsAfterNoMoreData;
    _footer.loadsAfterNoMoreData = loadsAfterNoMoreData;
}

@end
