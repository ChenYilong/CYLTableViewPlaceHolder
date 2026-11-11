//
//  CYLPlaceholderHUD.m
//  CYLTableViewPlaceHolder
//
//  [EN] The API follows SVProgressHUD (MIT, https://github.com/SVProgressHUD/SVProgressHUD); the implementation is
//       this project's own and draws its content with CYLPlaceholderStackView.
//  [CN] 接口参考 SVProgressHUD（MIT）；实现为本项目自有，内容由 CYLPlaceholderStackView 绘制。
//

#import "CYLPlaceholderHUD.h"
#import "CYLPlaceholderLocalization.h"

NSNotificationName const CYLPlaceholderHUDWillAppearNotification = @"CYLPlaceholderHUDWillAppearNotification";
NSNotificationName const CYLPlaceholderHUDDidAppearNotification = @"CYLPlaceholderHUDDidAppearNotification";
NSNotificationName const CYLPlaceholderHUDWillDisappearNotification = @"CYLPlaceholderHUDWillDisappearNotification";
NSNotificationName const CYLPlaceholderHUDDidDisappearNotification = @"CYLPlaceholderHUDDidDisappearNotification";
NSNotificationName const CYLPlaceholderHUDDidReceiveTouchEventNotification =
    @"CYLPlaceholderHUDDidReceiveTouchEventNotification";
NSNotificationName const CYLPlaceholderHUDDidTouchDownInsideNotification =
    @"CYLPlaceholderHUDDidTouchDownInsideNotification";
NSString *const CYLPlaceholderHUDStatusUserInfoKey = @"CYLPlaceholderHUDStatusUserInfoKey";

/// The widest the box gets.
static const CGFloat CYLPlaceholderHUDMaximumWidth = 260;
/// The margin the stack view keeps around its components (CYLPlaceholderStackMargin).
static const CGFloat CYLPlaceholderHUDStackMargin = 16;

/// Runs `block` on the main thread, now when already there.
static void CYLPlaceholderHUDOnMain(dispatch_block_t block) {
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@interface CYLPlaceholderHUD ()
@property (nonatomic, strong, readwrite, nullable) CYLPlaceholderStackView *placeholderView;
@property (nonatomic, strong, readwrite) UIView *hudView;
/// The box of a loading, progress or result state: one CYLPlaceholderView, no stack view.
@property (nonatomic, strong, nullable) CYLPlaceholderView *iconView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, readwrite) CYLPlaceholderHUDState state;
/// [EN] Written through `_status`: the public `-setStatus:` is also this property's setter.
/// [CN] 通过 `_status` 写入：公开的 `-setStatus:` 同时是该属性的 setter。
@property (nonatomic, copy, readwrite, nullable) NSString *status;
@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) NSUInteger activityCount;
/// Bumped by every show and dismiss, so a delayed show or dismiss knows whether it is still current.
@property (nonatomic) NSUInteger generation;
/// YES once the box is on screen (after the grace time).
@property (nonatomic) BOOL presented;
/// YES while a show is waiting for its grace time.
@property (nonatomic) BOOL pendingShow;
/// YES while the box is being measured and laid out: measuring lays out the content, which must not lay out the
/// HUD again.
@property (nonatomic) BOOL layingOutBox;
@end

@implementation CYLPlaceholderHUD

@synthesize foregroundColor = _foregroundColor;
@synthesize hudBackgroundColor = _hudBackgroundColor;
@synthesize backgroundLayerColor = _backgroundLayerColor;
@synthesize font = _font;
@synthesize loadingAnimationFileName = _loadingAnimationFileName;
@synthesize successImage = _successImage;
@synthesize errorImage = _errorImage;
@synthesize infoImage = _infoImage;

+ (CYLPlaceholderHUD *)sharedHUD {
    static CYLPlaceholderHUD *hud;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[CYLPlaceholderHUD alloc] initWithContainerView:nil];
    });
    return hud;
}

- (instancetype)initWithContainerView:(UIView *)containerView {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _containerView = containerView;
        _style = CYLPlaceholderHUDStyleAutomatic;
        _maskType = CYLPlaceholderHUDMaskTypeNone;
        _cornerRadius = 14;
        _minimumSize = CGSizeMake(100, 100);
        _animationSize = CGSizeMake(40, 40);
        _successAnimationFileName = @"CYLRefreshDoneCircle.json";
        _minimumDismissTimeInterval = 5;
        _maximumDismissTimeInterval = CGFLOAT_MAX;
        _fadeInAnimationDuration = 0.15;
        _fadeOutAnimationDuration = 0.15;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.alpha = 0;

        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.type = kCAGradientLayerRadial;
        _gradientLayer.startPoint = CGPointMake(0.5, 0.5);
        _gradientLayer.endPoint = CGPointMake(1, 1);
        _gradientLayer.colors = @[(id)[UIColor colorWithWhite:0 alpha:0].CGColor,
                                  (id)[UIColor colorWithWhite:0 alpha:0.6].CGColor];
        _gradientLayer.hidden = YES;
        [self.layer addSublayer:_gradientLayer];

        // [EN] The box only positions the content: the background belongs to the CYLPlaceholderView (one icon and
        //      title) or to the stack view of CYLPlaceholderViews, so icon and background cannot drift apart.
        // [CN] 方框只负责定位：背景属于 CYLPlaceholderView（一个图标与标题）或由 CYLPlaceholderView 组成的组件栈，
        //      图标与背景不会错位。
        _hudView = [[UIView alloc] initWithFrame:CGRectZero];
        _hudView.accessibilityIdentifier = @"CYLPlaceholderHUD";
        [self addSubview:_hudView];
    }
    return self;
}

- (instancetype)init {
    return [self initWithContainerView:nil];
}

// [EN] Unavailable in the header; implemented so the superclass's designated initializers are covered.
// [CN] 头文件中标记为不可用；这里实现以覆盖父类的指定初始化方法。
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithContainerView:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithContainerView:nil];
}

#pragma mark - Defaults

- (UIColor *)foregroundColor {
    return _foregroundColor ?: UIColor.blackColor;
}

- (void)setForegroundColor:(UIColor *)foregroundColor {
    _foregroundColor = foregroundColor;
    if (foregroundColor) self.style = CYLPlaceholderHUDStyleCustom;
    [self cyl_applyAppearance];
}

- (UIColor *)hudBackgroundColor {
    return _hudBackgroundColor ?: UIColor.whiteColor;
}

- (void)setHudBackgroundColor:(UIColor *)hudBackgroundColor {
    _hudBackgroundColor = hudBackgroundColor;
    if (hudBackgroundColor) self.style = CYLPlaceholderHUDStyleCustom;
    [self cyl_applyAppearance];
}

- (UIColor *)backgroundLayerColor {
    return _backgroundLayerColor ?: [UIColor colorWithWhite:0 alpha:0.4];
}

- (UIFont *)font {
    return _font ?: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

- (NSString *)loadingAnimationFileName {
    return _loadingAnimationFileName.length ? _loadingAnimationFileName : @"CYLRefreshActivity.gif";
}

- (UIImage *)successImage {
    return _successImage ?: [self cyl_symbol:@"checkmark" fallback:CYLPlaceholderStyleInfo];
}

- (UIImage *)errorImage {
    return _errorImage ?: [self cyl_symbol:@"xmark" fallback:CYLPlaceholderStyleError];
}

- (UIImage *)infoImage {
    return _infoImage ?: [self cyl_symbol:@"exclamationmark" fallback:CYLPlaceholderStyleInfo];
}

- (UIImage *)cyl_symbol:(NSString *)name fallback:(CYLPlaceholderStyle)style {
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *configuration =
            [UIImageSymbolConfiguration configurationWithPointSize:28 weight:UIImageSymbolWeightSemibold];
        UIImage *image = [UIImage systemImageNamed:name withConfiguration:configuration];
        if (image) return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    UIImage *image = [[CYLPlaceholderView imageForStyle:style] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return image ?: [[UIImage alloc] init];
}

- (void)setStyle:(CYLPlaceholderHUDStyle)style {
    _style = style;
    [self cyl_applyAppearance];
}

- (void)setMaskType:(CYLPlaceholderHUDMaskType)maskType {
    _maskType = maskType;
    [self cyl_applyAppearance];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self cyl_applyAppearance];
}

- (BOOL)isVisible {
    return self.presented || self.pendingShow;
}

#pragma mark - Showing

- (void)show {
    [self showWithStatus:nil];
}

- (void)showWithStatus:(NSString *)status {
    [self showProgress:-1 status:status];
}

- (void)showProgress:(CGFloat)progress {
    [self showProgress:progress status:nil];
}

- (void)showProgress:(CGFloat)progress status:(NSString *)status {
    CYLPlaceholderHUDOnMain(^{
        BOOL determinate = progress >= 0 && !isnan(progress);
        // [EN] Every indeterminate show counts as an activity for `popActivity`; progress updates do not.
        // [CN] 每次不确定进度的显示都计为一次活动（供 `popActivity` 抵消）；进度更新不计数。
        if (!determinate || self.activityCount == 0) self.activityCount += 1;
        CYLPlaceholderHUDState state = determinate ? CYLPlaceholderHUDStateProgress : CYLPlaceholderHUDStateLoading;
        if (self.contentView && self.state == state && self.isVisible) {
            // [EN] The same kind of HUD: update in place so the animation does not restart.
            // [CN] 同一种 HUD：原地更新，动画不会重启。
            self.progress = determinate ? MIN(MAX(progress, 0), 1) : 0;
            [self cyl_updateProgress];
            [self setStatus:status];
            return;
        }
        self.progress = determinate ? MIN(MAX(progress, 0), 1) : 0;
        // [EN] Progress scrubs `progressAnimationFileName` when set; otherwise the loading animation keeps looping and
        //      the title carries the percentage. Only the icon and title component is used, no extra view.
        // [CN] 设置了 `progressAnimationFileName` 时按进度定位该动画；否则循环播放加载动画，由标题显示百分比。
        //      只使用图标与标题组件，不添加其他视图。
        NSString *file = determinate && self.progressAnimationFileName.length ? self.progressAnimationFileName
                                                                             : self.loadingAnimationFileName;
        NSArray *components = @[[self cyl_iconComponentWithAnimation:file image:nil style:CYLPlaceholderStyleHourglass
                                                              status:[self cyl_titleForStatus:status determinate:determinate]
                                                         repeatCount:0]];
        [self cyl_present:components state:state status:status dismissAfter:0];
    });
}

- (void)setStatus:(NSString *)status {
    CYLPlaceholderHUDOnMain(^{
        self->_status = [status copy];
        CYLPlaceholderView *view = self.contentView;
        if (!view) return;
        NSString *title = [self cyl_titleForStatus:status
                                      determinate:self.state == CYLPlaceholderHUDStateProgress];
        view.textLabel.text = title;
        view.textLabel.hidden = title.length == 0;
        view.accessibilityLabel = status;
        [view invalidateIntrinsicContentSize];
        [self cyl_layoutBox];
        if (status.length) UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, view);
    });
}

- (void)showInfoWithStatus:(NSString *)status {
    [self cyl_showResult:CYLPlaceholderHUDStateInfo image:self.infoImage status:status];
}

- (void)showSuccessWithStatus:(NSString *)status {
    [self cyl_showResult:CYLPlaceholderHUDStateSuccess image:self.successImage status:status];
}

- (void)showErrorWithStatus:(NSString *)status {
    [self cyl_showResult:CYLPlaceholderHUDStateError image:self.errorImage status:status];
}

- (void)showImage:(UIImage *)image status:(NSString *)status {
    [self cyl_showResult:CYLPlaceholderHUDStateImage image:image status:status];
}

- (void)cyl_showResult:(CYLPlaceholderHUDState)state image:(UIImage *)image status:(NSString *)status {
    CYLPlaceholderHUDOnMain(^{
        // [EN] A result ends every activity, as in SVProgressHUD. [CN] 结果会结束所有活动，与 SVProgressHUD 相同。
        self.activityCount = 0;
        NSString *file = state == CYLPlaceholderHUDStateSuccess ? self.successAnimationFileName : nil;
        NSArray *components = @[[self cyl_iconComponentWithAnimation:file image:image style:CYLPlaceholderStyleInfo
                                                              status:status repeatCount:1]];
        [self cyl_present:components state:state status:status dismissAfter:[self displayDurationForString:status]];
        [self cyl_playHapticsForState:state];
    });
}

- (void)showComponents:(NSArray<CYLPlaceholderComponent *> *)components
               actions:(NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions {
    CYLPlaceholderHUDOnMain(^{
        self.activityCount += 1;
        NSMutableDictionary *merged = [NSMutableDictionary dictionaryWithDictionary:self.actions ?: @{}];
        [merged addEntriesFromDictionary:actions ?: @{}];
        [self cyl_present:components state:CYLPlaceholderHUDStateCustom status:nil dismissAfter:0 actions:merged];
    });
}

- (void)showScenario:(CYLPlaceholderScenario)scenario
             actions:(NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions {
    [self showComponents:[CYLPlaceholderScenarioCatalog componentsForScenario:scenario] actions:actions];
}

#pragma mark - Building the content

/// An icon component: a bundled animation (when given and present), else `image`, else `style`, with the status.
- (CYLPlaceholderComponent *)cyl_iconComponentWithAnimation:(NSString *)fileName image:(UIImage *)image
                                                      style:(CYLPlaceholderStyle)style status:(NSString *)status
                                                repeatCount:(NSInteger)repeatCount {
    NSString *file = fileName.length && [CYLPlaceholderView pathForBundledAnimation:fileName] ? fileName : nil;
    CYLPlaceholderComponent *base = [CYLPlaceholderComponent componentWithBundledAnimation:file fallbackStyle:style
        title:status size:self.animationSize action:nil];
    NSMutableDictionary<NSString *, id> *attributes = [base.attributes mutableCopy];
    if (image && !file) {
        attributes[CYLPlaceholderItemImage] = image;
        [attributes removeObjectForKey:CYLPlaceholderItemStyle];
    }
    if (!status.length) [attributes removeObjectForKey:CYLPlaceholderItemTitle];
    attributes[CYLPlaceholderItemTitleFont] = self.font;
    attributes[CYLPlaceholderItemTitleColor] = [self cyl_contentColor];
    attributes[CYLPlaceholderItemIconColor] = [self cyl_contentColor];
    attributes[CYLPlaceholderItemAnimationRepeatCount] = @(repeatCount);
    CYLPlaceholderComponent *component = [CYLPlaceholderComponent componentWithAttributes:attributes action:nil];
    component.animationRepeatCount = repeatCount;
    component.interactionEnabled = NO;
    return component;
}

- (void)cyl_present:(NSArray<CYLPlaceholderComponent *> *)components state:(CYLPlaceholderHUDState)state
             status:(NSString *)status dismissAfter:(NSTimeInterval)delay {
    [self cyl_present:components state:state status:status dismissAfter:delay actions:self.actions];
}

- (void)cyl_present:(NSArray<CYLPlaceholderComponent *> *)components state:(CYLPlaceholderHUDState)state
             status:(NSString *)status dismissAfter:(NSTimeInterval)delay actions:(NSDictionary *)actions {
    self.generation += 1;
    NSUInteger generation = self.generation;
    self.state = state;
    self->_status = [status copy];

    [self.placeholderView removeFromSuperview];
    [self.iconView removeFromSuperview];
    self.placeholderView = nil;
    self.iconView = nil;
    if (state == CYLPlaceholderHUDStateCustom) {
        // [EN] Several components with tap actions: a stack view of CYLPlaceholderViews.
        // [CN] 多个带点击动作的组件：由 CYLPlaceholderView 组成的组件栈。
        CYLPlaceholderStackView *placeholder = [[CYLPlaceholderStackView alloc] initWithComponents:components
                                                                                          actions:actions];
        placeholder.backgroundAction = nil;
        placeholder.accessibilityIdentifier = @"CYLPlaceholderHUDContent";
        self.placeholderView = placeholder;
        [self.hudView addSubview:placeholder];
    } else {
        // [EN] One icon and title: the CYLPlaceholderView is the box itself, with no stack view around it.
        // [CN] 一个图标与标题：CYLPlaceholderView 就是方框本身，外面没有组件栈。
        CYLPlaceholderComponent *component = components.firstObject;
        NSError *error = nil;
        CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithItemAttributes:component.attributes
                                                                         imageBundle:component.imageBundle
                                                                               error:&error];
        if (!view) {
            NSLog(@"CYLTableViewPlaceHolder: HUD content not shown: %@", error.localizedDescription);
            view = [[CYLPlaceholderView alloc] initWithFrame:CGRectZero];
        }
        view.reportsContentSize = YES;
        view.contentMargin = CYLPlaceholderHUDStackMargin;
        view.animationRepeatCount = component.animationRepeatCount;
        view.isAccessibilityElement = YES;
        view.accessibilityLabel = status;
        view.accessibilityIdentifier = @"CYLPlaceholderHUDContent";
        self.iconView = view;
        [self.hudView addSubview:view];
    }
    [self cyl_applyAppearance];
    [self cyl_updateProgress];

    UIView *container = [self cyl_container];
    if (!container) {
        NSLog(@"CYLTableViewPlaceHolder: CYLPlaceholderHUD has no container view; set containerView.");
        return;
    }
    if (self.superview != container) {
        [self removeFromSuperview];
        [container addSubview:self];
    }
    [container bringSubviewToFront:self];
    self.frame = container.bounds;
    [self cyl_layoutBox];

    if (delay > 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.generation == generation) [weakSelf cyl_dismissAnimatedWithCompletion:nil];
        });
    }
    if (self.presented) {
        // [EN] Shown again, possibly while fading out: back to fully visible. [CN] 再次显示（可能正在淡出）：恢复完全可见。
        [UIView animateWithDuration:self.fadeInAnimationDuration delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            self.alpha = 1;
        } completion:nil];
        [self cyl_announce];
        return;
    }
    if (self.graceTimeInterval > 0 && !self.pendingShow) {
        self.pendingShow = YES;
        self.hidden = YES;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.graceTimeInterval * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            CYLPlaceholderHUD *hud = weakSelf;
            if (!hud.pendingShow) return;
            hud.pendingShow = NO;
            hud.hidden = NO;
            [hud cyl_fadeIn];
        });
        return;
    }
    if (!self.pendingShow) [self cyl_fadeIn];
}

- (void)cyl_fadeIn {
    self.presented = YES;
    NSDictionary *userInfo = [self cyl_userInfo];
    [NSNotificationCenter.defaultCenter postNotificationName:CYLPlaceholderHUDWillAppearNotification object:self
                                                    userInfo:userInfo];
    BOOL reduceMotion = UIAccessibilityIsReduceMotionEnabled();
    self.hudView.transform = reduceMotion ? CGAffineTransformIdentity : CGAffineTransformMakeScale(1.1, 1.1);
    void (^animations)(void) = ^{
        self.alpha = 1;
        self.hudView.transform = CGAffineTransformIdentity;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        [NSNotificationCenter.defaultCenter postNotificationName:CYLPlaceholderHUDDidAppearNotification object:self
                                                        userInfo:userInfo];
        [self cyl_announce];
    };
    if (self.fadeInAnimationDuration > 0) {
        [UIView animateWithDuration:self.fadeInAnimationDuration delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:animations completion:completion];
    } else {
        animations();
        completion(YES);
    }
}

- (void)cyl_announce {
    if (self.status.length) UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.status);
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.contentView);
}

- (NSDictionary *)cyl_userInfo {
    return self.status.length ? @{CYLPlaceholderHUDStatusUserInfoKey: self.status} : @{};
}

- (UIView *)cyl_container {
    if (self.containerView) return self.containerView;
    // [EN] Looked up at run time so the library also links in app extensions, where a container must be set.
    // [CN] 运行时查找，使本库在 App Extension 中也能链接；在扩展中必须设置容器视图。
    Class applicationClass = NSClassFromString(@"UIApplication");
    if (![applicationClass respondsToSelector:@selector(sharedApplication)]) return nil;
    UIApplication *application = [applicationClass valueForKey:@"sharedApplication"];
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in application.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            if (scene.activationState != UISceneActivationStateForegroundActive &&
                scene.activationState != UISceneActivationStateForegroundInactive) continue;
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow) return window;
            }
            UIWindow *first = ((UIWindowScene *)scene).windows.firstObject;
            if (first) return first;
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // [EN] iOS 12, before scenes. [CN] iOS 12（没有 scene）。
    for (UIWindow *window in application.windows) {
        if (window.isKeyWindow) return window;
    }
    return application.windows.firstObject;
#pragma clang diagnostic pop
}

#pragma mark - Progress

/// The title: the status, followed in the Progress state by the percentage when no animation is scrubbed.
- (NSString *)cyl_titleForStatus:(NSString *)status determinate:(BOOL)determinate {
    if (!determinate || self.progressAnimationFileName.length) return status;
    NSString *percent = [NSNumberFormatter localizedStringFromNumber:@(self.progress)
                                                         numberStyle:NSNumberFormatterPercentStyle];
    return status.length ? [NSString stringWithFormat:@"%@ %@", status, percent] : percent;
}

- (void)cyl_updateProgress {
    if (self.state != CYLPlaceholderHUDStateProgress) return;
    CYLPlaceholderView *view = self.contentView;
    if (self.progressAnimationFileName.length) {
        [view stopPlaceholderAnimation];
        [view setPlaceholderAnimationProgress:self.progress];
    }
    NSString *percent = [NSNumberFormatter localizedStringFromNumber:@(self.progress)
                                                         numberStyle:NSNumberFormatterPercentStyle];
    view.accessibilityValue = percent;
    [self setNeedsLayout];
}

#pragma mark - Dismissing

- (void)popActivity {
    CYLPlaceholderHUDOnMain(^{
        if (self.activityCount > 0) self.activityCount -= 1;
        if (self.activityCount == 0) [self cyl_dismissAnimatedWithCompletion:nil];
    });
}

- (void)dismiss {
    [self dismissWithDelay:0 completion:nil];
}

- (void)dismissWithCompletion:(CYLPlaceholderHUDDismissCompletion)completion {
    [self dismissWithDelay:0 completion:completion];
}

- (void)dismissWithDelay:(NSTimeInterval)delay {
    [self dismissWithDelay:delay completion:nil];
}

- (void)dismissWithDelay:(NSTimeInterval)delay completion:(CYLPlaceholderHUDDismissCompletion)completion {
    CYLPlaceholderHUDOnMain(^{
        if (delay <= 0) {
            [self cyl_dismissAnimatedWithCompletion:completion];
            return;
        }
        NSUInteger generation = self.generation;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CYLPlaceholderHUD *hud = weakSelf;
            if (hud.generation == generation) {
                [hud cyl_dismissAnimatedWithCompletion:completion];
            } else if (completion) {
                completion();
            }
        });
    });
}

- (void)cyl_dismissAnimatedWithCompletion:(CYLPlaceholderHUDDismissCompletion)completion {
    self.activityCount = 0;
    self.generation += 1;
    NSUInteger generation = self.generation;
    if (self.pendingShow) {
        // [EN] Dismissed within the grace time: nothing was shown, so nothing is announced.
        // [CN] 在宽限时间内关闭：未曾显示，因此不发送通知。
        self.pendingShow = NO;
        [self cyl_tearDown];
        if (completion) completion();
        return;
    }
    if (!self.presented) {
        if (completion) completion();
        return;
    }
    NSDictionary *userInfo = [self cyl_userInfo];
    [NSNotificationCenter.defaultCenter postNotificationName:CYLPlaceholderHUDWillDisappearNotification object:self
                                                    userInfo:userInfo];
    void (^finish)(BOOL) = ^(BOOL finished) {
        if (self.generation != generation) return;  // Shown again meanwhile.
        [self cyl_tearDown];
        [NSNotificationCenter.defaultCenter postNotificationName:CYLPlaceholderHUDDidDisappearNotification object:self
                                                        userInfo:userInfo];
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
        if (completion) completion();
    };
    if (self.fadeOutAnimationDuration > 0) {
        [UIView animateWithDuration:self.fadeOutAnimationDuration delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            self.alpha = 0;
        } completion:finish];
    } else {
        self.alpha = 0;
        finish(YES);
    }
}

- (void)cyl_tearDown {
    self.presented = NO;
    self.hidden = NO;
    self.alpha = 0;
    self.state = CYLPlaceholderHUDStateHidden;
    self->_status = nil;
    self.progress = 0;
    [self.placeholderView removeFromSuperview];
    [self.iconView removeFromSuperview];
    self.placeholderView = nil;
    self.iconView = nil;
    [self removeFromSuperview];
}

- (NSTimeInterval)displayDurationForString:(NSString *)string {
    NSTimeInterval duration = (NSTimeInterval)string.length * 0.06 + 0.5;
    return MIN(MAX(duration, self.minimumDismissTimeInterval), self.maximumDismissTimeInterval);
}

#pragma mark - Appearance and layout

- (UIColor *)cyl_contentColor {
    switch (self.style) {
        case CYLPlaceholderHUDStyleLight: return UIColor.blackColor;
        case CYLPlaceholderHUDStyleDark: return UIColor.whiteColor;
        case CYLPlaceholderHUDStyleCustom: return self.foregroundColor;
        case CYLPlaceholderHUDStyleAutomatic:
        default:
            if (@available(iOS 13.0, *)) return UIColor.labelColor;
            return UIColor.blackColor;
    }
}

- (CYLPlaceholderView *)contentView {
    return self.iconView ?: self.placeholderView.placeholderView;
}

/// The view that draws the box: the CYLPlaceholderView of an icon state, else the stack view of components.
- (UIView *)cyl_boxView {
    return self.iconView ?: self.placeholderView;
}

- (UIColor *)cyl_boxColor {
    BOOL solid = UIAccessibilityIsReduceTransparencyEnabled();
    switch (self.style) {
        case CYLPlaceholderHUDStyleLight:
            return [UIColor colorWithWhite:1 alpha:solid ? 1 : 0.94];
        case CYLPlaceholderHUDStyleDark:
            return [UIColor colorWithWhite:solid ? 0.1 : 0 alpha:solid ? 1 : 0.8];
        case CYLPlaceholderHUDStyleCustom:
            return self.hudBackgroundColor;
        case CYLPlaceholderHUDStyleAutomatic:
        default:
            if (@available(iOS 13.0, *)) {
                return solid ? UIColor.secondarySystemBackgroundColor
                             : [UIColor.secondarySystemBackgroundColor colorWithAlphaComponent:0.94];
            }
            return [UIColor colorWithWhite:0.96 alpha:solid ? 1 : 0.94];
    }
}

- (void)cyl_applyAppearance {
    UIView *box = [self cyl_boxView];
    box.backgroundColor = [self cyl_boxColor];
    box.layer.cornerRadius = self.cornerRadius;
    box.clipsToBounds = YES;
    for (CYLPlaceholderView *component in self.placeholderView.componentViews) {
        component.backgroundColor = UIColor.clearColor;
    }
    self.hudView.backgroundColor = UIColor.clearColor;

    switch (self.maskType) {
        case CYLPlaceholderHUDMaskTypeBlack:
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            break;
        case CYLPlaceholderHUDMaskTypeCustom:
            self.backgroundColor = self.backgroundLayerColor;
            break;
        default:
            self.backgroundColor = UIColor.clearColor;
            break;
    }
    self.gradientLayer.hidden = self.maskType != CYLPlaceholderHUDMaskTypeGradient;
    // [EN] A mask that blocks touches also keeps VoiceOver inside the box. [CN] 阻止触摸的遮罩同时把 VoiceOver 限制在方框内。
    self.accessibilityViewIsModal = self.maskType != CYLPlaceholderHUDMaskTypeNone;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self cyl_layoutBox];
}

- (void)cyl_layoutBox {
    // [EN] `layoutIfNeeded` on the content can lay out this view again; a nested call returns at once.
    // [CN] 对内容调用 `layoutIfNeeded` 可能再次布局本视图；嵌套调用直接返回。
    if (self.layingOutBox) return;
    self.layingOutBox = YES;
    [self cyl_measureAndPlaceBox];
    self.layingOutBox = NO;
}

- (void)cyl_measureAndPlaceBox {
    self.gradientLayer.frame = self.bounds;
    UIView *box = [self cyl_boxView];
    if (!box) return;
    CGFloat maxWidth = MIN(CYLPlaceholderHUDMaximumWidth, MAX(self.bounds.size.width - 32, self.minimumSize.width));
    CGSize content;
    if (self.iconView) {
        // [EN] The CYLPlaceholderView measures itself; its content margin is the box's side padding.
        // [CN] CYLPlaceholderView 自行测量；其内容边距就是方框左右的留白。
        self.iconView.preferredMaxLayoutWidth = maxWidth;
        CGSize size = self.iconView.intrinsicContentSize;
        content = CGSizeMake(ceil(size.width) - 2 * CYLPlaceholderHUDStackMargin, ceil(size.height));
    } else {
        self.placeholderView.frame = CGRectMake(0, 0, maxWidth, 1000);
        [self.placeholderView layoutIfNeeded];
        content = [self.placeholderView.stackView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    }
    CGFloat width = MIN(maxWidth, MAX(self.minimumSize.width, ceil(content.width) + 2 * CYLPlaceholderHUDStackMargin));
    CGFloat height = MAX(self.minimumSize.height, ceil(content.height) + 2 * CYLPlaceholderHUDStackMargin);
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds) + self.offsetFromCenter.horizontal,
                                 CGRectGetMidY(self.bounds) + self.offsetFromCenter.vertical);
    self.hudView.bounds = CGRectMake(0, 0, width, height);
    self.hudView.center = center;
    box.frame = self.hudView.bounds;
    [box layoutIfNeeded];
}

#pragma mark - Touches and haptics

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden || self.alpha < 0.01) return nil;
    UIView *hit = [super hitTest:point withEvent:event];
    BOOL insideBox = [self.hudView pointInside:[self convertPoint:point toView:self.hudView] withEvent:event];
    if (insideBox) {
        if (event.type == UIEventTypeTouches) {
            [NSNotificationCenter.defaultCenter postNotificationName:CYLPlaceholderHUDDidTouchDownInsideNotification
                                                              object:event];
        }
        return hit;
    }
    if (event.type == UIEventTypeTouches) {
        [NSNotificationCenter.defaultCenter postNotificationName:CYLPlaceholderHUDDidReceiveTouchEventNotification
                                                          object:event];
    }
    // [EN] Without a mask, touches outside the box reach the views behind. [CN] 无遮罩时，方框外的触摸传给后面的视图。
    return self.maskType == CYLPlaceholderHUDMaskTypeNone ? nil : self;
}

- (void)cyl_playHapticsForState:(CYLPlaceholderHUDState)state {
    if (!self.hapticsEnabled) return;
    UINotificationFeedbackType type;
    switch (state) {
        case CYLPlaceholderHUDStateSuccess: type = UINotificationFeedbackTypeSuccess; break;
        case CYLPlaceholderHUDStateInfo: type = UINotificationFeedbackTypeWarning; break;
        case CYLPlaceholderHUDStateError: type = UINotificationFeedbackTypeError; break;
        default: return;
    }
    UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
    [generator notificationOccurred:type];
}

#pragma mark - Shared HUD

+ (void)show { [self.sharedHUD show]; }
+ (void)showWithStatus:(NSString *)status { [self.sharedHUD showWithStatus:status]; }
+ (void)showProgress:(CGFloat)progress { [self.sharedHUD showProgress:progress]; }
+ (void)showProgress:(CGFloat)progress status:(NSString *)status { [self.sharedHUD showProgress:progress status:status]; }
+ (void)setStatus:(NSString *)status { [self.sharedHUD setStatus:status]; }
+ (void)showInfoWithStatus:(NSString *)status { [self.sharedHUD showInfoWithStatus:status]; }
+ (void)showSuccessWithStatus:(NSString *)status { [self.sharedHUD showSuccessWithStatus:status]; }
+ (void)showErrorWithStatus:(NSString *)status { [self.sharedHUD showErrorWithStatus:status]; }
+ (void)showImage:(UIImage *)image status:(NSString *)status { [self.sharedHUD showImage:image status:status]; }
+ (void)popActivity { [self.sharedHUD popActivity]; }
+ (void)dismiss { [self.sharedHUD dismiss]; }
+ (void)dismissWithCompletion:(CYLPlaceholderHUDDismissCompletion)completion {
    [self.sharedHUD dismissWithCompletion:completion];
}
+ (void)dismissWithDelay:(NSTimeInterval)delay { [self.sharedHUD dismissWithDelay:delay]; }
+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(CYLPlaceholderHUDDismissCompletion)completion {
    [self.sharedHUD dismissWithDelay:delay completion:completion];
}
+ (BOOL)isVisible { return self.sharedHUD.isVisible; }
+ (NSTimeInterval)displayDurationForString:(NSString *)string { return [self.sharedHUD displayDurationForString:string]; }

@end
