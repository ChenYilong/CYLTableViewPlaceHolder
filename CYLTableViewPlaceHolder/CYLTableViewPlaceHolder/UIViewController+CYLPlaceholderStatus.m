//
//  UIViewController+CYLPlaceholderStatus.m
//  CYLTableViewPlaceHolder
//
//  [EN] CYLChatKit adds its bar to the controller's view (`[self.view addSubview:self.clientStatusView]`) and hides it
//       while the IM client is connected (-[LCCKConversationViewController updateStatusView]). This does the same
//       through one presenter per controller: the bar sits on the safe area's top edge, the safe area grows by its
//       height while it shows, and the placeholder is switched on or off through `cyl_placeholderHidden`.
//  [CN] CYLChatKit 把状态条加到控制器的 view 上，并在 IM 客户端连接时隐藏它。这里每个控制器用一个 presenter 完成同样的事：状态条位于安全
//       区域的顶边，显示时安全区域增加其高度，占位图通过 `cyl_placeholderHidden` 打开或关闭。
//

#import "UIViewController+CYLPlaceholderStatus.h"
#import "CYLPlaceholderNetworkMonitor.h"
#import <objc/runtime.h>

/// [EN] Above the cells and the placeholder of a table that is the controller's view. [CN] 位于列表单元格与占位图之上。
static const CGFloat CYLPlaceholderStatusZPosition = 1000;

@interface CYLPlaceholderStatusPresenter : NSObject
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) CYLPlaceholderStatusView *statusView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) CYLPlaceholderStatusDisplay display;
@property (nonatomic) BOOL showsWhenOffline;
/// [EN] The height added to `additionalSafeAreaInsets.top`, removed when the bar hides. [CN] 加到安全区域上的高度。
@property (nonatomic) CGFloat addedInset;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *constraints;
@property (nonatomic, strong) id networkObserver;
@property (nonatomic, strong) id contentSizeObserver;
/// [EN] `scrollView`, else the controller's view when it scrolls. [CN] `scrollView`，否则为可滚动的控制器 view。
@property (nonatomic, readonly) UIScrollView *placeholderScrollView;
- (instancetype)initWithViewController:(UIViewController *)viewController;
- (void)applyAnimated:(BOOL)animated;
@end

@implementation CYLPlaceholderStatusPresenter

// [EN] Both accessors of `statusView` are custom, so its storage is named here. [CN] `statusView` 的存取方法都是自定义的，在此声明存储。
@synthesize statusView = _statusView;

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        _display = CYLPlaceholderStatusDisplayPlaceholder;
        __weak typeof(self) weakSelf = self;
        // [EN] A taller Dynamic Type size makes the bar taller; keep the safe area in step.
        // [CN] 动态字体变大时状态条变高；保持安全区域同步。
        _contentSizeObserver = [NSNotificationCenter.defaultCenter addObserverForName:UIContentSizeCategoryDidChangeNotification
            object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
                dispatch_async(dispatch_get_main_queue(), ^{ [weakSelf updateInset]; });
            }];
    }
    return self;
}

- (void)dealloc {
    if (_networkObserver) [NSNotificationCenter.defaultCenter removeObserver:_networkObserver];
    if (_contentSizeObserver) [NSNotificationCenter.defaultCenter removeObserver:_contentSizeObserver];
}

- (CYLPlaceholderStatusView *)statusView {
    if (!_statusView) _statusView = [[CYLPlaceholderStatusView alloc] initWithFrame:CGRectZero];
    return _statusView;
}

- (void)setStatusView:(CYLPlaceholderStatusView *)statusView {
    if (_statusView == statusView) return;
    BOOL showing = _statusView.superview != nil;
    [self detachBar];
    _statusView = statusView;
    if (showing) [self applyAnimated:NO];
}

- (UIScrollView *)placeholderScrollView {
    UIScrollView *scrollView = self.scrollView;
    if (scrollView) return scrollView;
    UIView *view = self.viewController.isViewLoaded ? self.viewController.view : nil;
    return [view isKindOfClass:UIScrollView.class] ? (UIScrollView *)view : nil;
}

#pragma mark - Display

- (CYLPlaceholderStatusDisplay)effectiveDisplay {
    CYLPlaceholderStatusDisplay display = self.display;
    if (self.showsWhenOffline) {
        CYLPlaceholderNetworkMonitor *monitor = CYLPlaceholderNetworkMonitor.sharedMonitor;
        if (monitor.networkStatus == CYLPlaceholderNetworkStatusNotReachable) {
            display |= CYLPlaceholderStatusDisplayStatusBar;
        } else {
            display &= ~CYLPlaceholderStatusDisplayStatusBar;
        }
    }
    return display;
}

- (void)applyAnimated:(BOOL)animated {
    CYLPlaceholderStatusDisplay display = [self effectiveDisplay];
    self.placeholderScrollView.cyl_placeholderHidden = !(display & CYLPlaceholderStatusDisplayPlaceholder);
    UIViewController *viewController = self.viewController;
    BOOL showBar = (display & CYLPlaceholderStatusDisplayStatusBar) && viewController.isViewLoaded;
    if (showBar) {
        [self attachBar];
        CYLPlaceholderStatusView *bar = self.statusView;
        if (animated && bar.alpha < 1) {
            [UIView animateWithDuration:0.25 animations:^{ bar.alpha = 1; }];
        } else {
            bar.alpha = 1;
        }
    } else if (self.statusView.superview) {
        CYLPlaceholderStatusView *bar = self.statusView;
        if (animated) {
            [self removeInset];
            [UIView animateWithDuration:0.25 animations:^{ bar.alpha = 0; } completion:^(BOOL finished) {
                if (!([self effectiveDisplay] & CYLPlaceholderStatusDisplayStatusBar)) [self detachBar];
            }];
        } else {
            [self detachBar];
        }
    }
    // [EN] VoiceOver hears the bar when it appears. [CN] 状态条出现时告知 VoiceOver。
    if (showBar && UIAccessibilityIsVoiceOverRunning() && self.statusView.text.length) {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.statusView.text);
    }
}

#pragma mark - The bar in the view

- (void)attachBar {
    UIViewController *viewController = self.viewController;
    UIView *host = viewController.view;
    CYLPlaceholderStatusView *bar = self.statusView;
    if (bar.superview != host) {
        [self detachBar];
        bar.translatesAutoresizingMaskIntoConstraints = NO;
        bar.alpha = 0;
        bar.layer.zPosition = CYLPlaceholderStatusZPosition;
        [host addSubview:bar];
        // [EN] A scroll view's edges belong to its content; its frame guide does not scroll.
        // [CN] 滚动视图的边对应其内容；frame 布局参考不随滚动移动。
        NSLayoutXAxisAnchor *leading = host.leadingAnchor, *trailing = host.trailingAnchor;
        if ([host isKindOfClass:UIScrollView.class]) {
            leading = ((UIScrollView *)host).frameLayoutGuide.leadingAnchor;
            trailing = ((UIScrollView *)host).frameLayoutGuide.trailingAnchor;
        }
        self.constraints = @[
            [bar.leadingAnchor constraintEqualToAnchor:leading],
            [bar.trailingAnchor constraintEqualToAnchor:trailing],
            // [EN] Right below the navigation bar: the safe area starts under the bar while it shows.
            // [CN] 紧贴导航栏下方：显示期间安全区域从状态条下方开始。
            [bar.bottomAnchor constraintEqualToAnchor:host.safeAreaLayoutGuide.topAnchor],
        ];
        [NSLayoutConstraint activateConstraints:self.constraints];
    }
    [host bringSubviewToFront:bar];
    [self updateInset];
}

- (void)detachBar {
    [self removeInset];
    if (self.constraints) [NSLayoutConstraint deactivateConstraints:self.constraints];
    self.constraints = nil;
    [_statusView removeFromSuperview];
}

/// [EN] The safe area grows by the bar's current height. [CN] 安全区域增加状态条当前的高度。
- (void)updateInset {
    UIViewController *viewController = self.viewController;
    if (!viewController || !_statusView.superview) return;
    CGFloat height = ceil(_statusView.intrinsicContentSize.height);
    if (height == self.addedInset) return;
    UIEdgeInsets insets = viewController.additionalSafeAreaInsets;
    insets.top += height - self.addedInset;
    self.addedInset = height;
    viewController.additionalSafeAreaInsets = insets;
}

- (void)removeInset {
    UIViewController *viewController = self.viewController;
    if (!viewController || self.addedInset == 0) return;
    UIEdgeInsets insets = viewController.additionalSafeAreaInsets;
    insets.top = MAX(0, insets.top - self.addedInset);
    self.addedInset = 0;
    viewController.additionalSafeAreaInsets = insets;
}

#pragma mark - Network

- (void)setShowsWhenOffline:(BOOL)showsWhenOffline {
    if (_showsWhenOffline == showsWhenOffline) return;
    _showsWhenOffline = showsWhenOffline;
    if (showsWhenOffline) {
        CYLPlaceholderNetworkMonitor *monitor = CYLPlaceholderNetworkMonitor.sharedMonitor;
        [monitor startMonitoring];
        __weak typeof(self) weakSelf = self;
        self.networkObserver = [NSNotificationCenter.defaultCenter addObserverForName:CYLPlaceholderNetworkStatusDidChangeNotification
            object:monitor queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
                [weakSelf applyAnimated:YES];
            }];
    } else if (self.networkObserver) {
        [NSNotificationCenter.defaultCenter removeObserver:self.networkObserver];
        self.networkObserver = nil;
    }
    [self applyAnimated:NO];
}

@end

static NSError *CYLStatusPresentationError(NSString *description) {
    return [NSError errorWithDomain:@"CYLPlaceholderConfigurationError" code:5
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

static const void *CYLPlaceholderStatusPresenterKey = &CYLPlaceholderStatusPresenterKey;

@implementation UIViewController (CYLPlaceholderStatus)

- (CYLPlaceholderStatusPresenter *)cyl_statusPresenter {
    CYLPlaceholderStatusPresenter *presenter = objc_getAssociatedObject(self, CYLPlaceholderStatusPresenterKey);
    if (!presenter) {
        presenter = [[CYLPlaceholderStatusPresenter alloc] initWithViewController:self];
        objc_setAssociatedObject(self, CYLPlaceholderStatusPresenterKey, presenter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return presenter;
}

- (CYLPlaceholderStatusView *)cyl_statusView {
    return self.cyl_statusPresenter.statusView;
}

- (void)setCyl_statusView:(CYLPlaceholderStatusView *)statusView {
    self.cyl_statusPresenter.statusView = statusView;
}

- (UIScrollView *)cyl_placeholderScrollView {
    return self.cyl_statusPresenter.placeholderScrollView;
}

- (void)setCyl_placeholderScrollView:(UIScrollView *)scrollView {
    CYLPlaceholderStatusPresenter *presenter = self.cyl_statusPresenter;
    if (presenter.scrollView != scrollView) presenter.placeholderScrollView.cyl_placeholderHidden = NO;
    presenter.scrollView = scrollView;
    [presenter applyAnimated:NO];
}

- (CYLPlaceholderStatusDisplay)cyl_statusDisplay {
    return self.cyl_statusPresenter.display;
}

- (void)setCyl_statusDisplay:(CYLPlaceholderStatusDisplay)display {
    [self cyl_setStatusDisplay:display animated:NO];
}

- (void)cyl_setStatusDisplay:(CYLPlaceholderStatusDisplay)display animated:(BOOL)animated {
    NSAssert(NSThread.isMainThread, @"Set the status display on the main thread.");
    CYLPlaceholderStatusPresenter *presenter = self.cyl_statusPresenter;
    presenter.display = display;
    [presenter applyAnimated:animated];
}

- (BOOL)cyl_applyStatusConfigurationWithContentsOfURL:(NSURL *)url error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:error];
    if (!data) return NO;
    id object = [url.pathExtension.lowercaseString isEqualToString:@"plist"] ?
        [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:error] :
        [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (!object) return NO;
    return [self cyl_applyStatusConfiguration:object error:error];
}

- (BOOL)cyl_applyStatusConfiguration:(NSDictionary<NSString *, id> *)configuration error:(NSError **)error {
    if (![configuration isKindOfClass:NSDictionary.class]) {
        if (error) *error = CYLStatusPresentationError(@"The configuration must be a dictionary.");
        return NO;
    }
    id barValue = configuration[@"statusBar"];
    CYLPlaceholderStatusView *bar = nil;
    if ([barValue isKindOfClass:NSDictionary.class]) {
        bar = [[CYLPlaceholderStatusView alloc] initWithConfiguration:barValue error:error];
        if (!bar) return NO;
    } else if (barValue && !(([barValue isKindOfClass:NSNumber.class]) ||
                             ([barValue isKindOfClass:NSString.class] && [barValue isEqualToString:@"networkUnavailable"]))) {
        if (error) *error = CYLStatusPresentationError(@"\"statusBar\" must be true, \"networkUnavailable\" or a dictionary.");
        return NO;
    }
    NSDictionary<NSString *, NSNumber *> *displays = @{
        @"statusAndPlaceholder": @(CYLPlaceholderStatusDisplayAll), @"status": @(CYLPlaceholderStatusDisplayStatusBar),
        @"placeholder": @(CYLPlaceholderStatusDisplayPlaceholder), @"none": @(CYLPlaceholderStatusDisplayNone),
    };
    id displayValue = configuration[@"display"];
    BOOL wantsBar = barValue && !([barValue isKindOfClass:NSNumber.class] && ![barValue boolValue]);
    NSNumber *display = displayValue ? ([displayValue isKindOfClass:NSString.class] ? displays[displayValue] : nil) :
        @(wantsBar ? CYLPlaceholderStatusDisplayAll : CYLPlaceholderStatusDisplayPlaceholder);
    if (!display) {
        if (error) *error = CYLStatusPresentationError(@"\"display\" must be \"statusAndPlaceholder\", \"status\", \"placeholder\" or \"none\".");
        return NO;
    }
    id offline = configuration[@"showsWhenOffline"];
    if (offline && ![offline isKindOfClass:NSNumber.class]) {
        if (error) *error = CYLStatusPresentationError(@"\"showsWhenOffline\" must be a boolean.");
        return NO;
    }
    if (bar) {
        self.cyl_statusView = bar;
    } else if (wantsBar) {
        self.cyl_statusView = nil; // [EN] Back to the network bar. [CN] 恢复为网络提示条。
    }
    if (offline) self.cyl_showsStatusViewWhenOffline = [offline boolValue];
    self.cyl_statusDisplay = display.unsignedIntegerValue;
    return YES;
}

- (BOOL)cyl_showsStatusViewWhenOffline {
    return self.cyl_statusPresenter.showsWhenOffline;
}

- (void)setCyl_showsStatusViewWhenOffline:(BOOL)showsStatusViewWhenOffline {
    self.cyl_statusPresenter.showsWhenOffline = showsStatusViewWhenOffline;
}

@end
