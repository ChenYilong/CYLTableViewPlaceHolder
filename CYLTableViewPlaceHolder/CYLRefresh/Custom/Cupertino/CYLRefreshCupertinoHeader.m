//
//  CYLRefreshCupertinoHeader.m
//  CYLRefresh
//

#import "CYLRefreshCupertinoHeader.h"
#import "NSBundle+CYLRefresh.h"
#import "CYLRefreshConst.h"
#import "UIView+CYLExtension.h"

@implementation CYLRefreshCupertinoHeader

- (void)prepare
{
    [super prepare];
    self.cyl_h = 60;
    UIActivityIndicatorView *indicator;
    if (@available(iOS 13.0, *)) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    } else {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    indicator.hidesWhenStopped = NO;
    indicator.alpha = 0;
    indicator.isAccessibilityElement = YES;
    [self addSubview:indicator];
    _activityIndicator = indicator;
}

- (void)placeSubviews
{
    [super placeSubviews];
    self.activityIndicator.center = CGPointMake(self.cyl_w * 0.5, self.cyl_h * 0.5);
}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    if (self.isRefreshing) return;
    // [EN] Fades in and turns with the pull, like the system refresh control. [CN] 随下拉淡入并转动，与系统刷新控件相同。
    CGFloat percent = MAX(0, MIN(1, pullingPercent));
    self.activityIndicator.alpha = percent;
    self.activityIndicator.transform = CGAffineTransformMakeRotation((CGFloat)M_PI * percent);
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState
    if (state == CYLRefreshStateRefreshing || state == CYLRefreshStateWillRefresh) {
        self.activityIndicator.alpha = 1;
        self.activityIndicator.transform = CGAffineTransformIdentity;
        [self.activityIndicator startAnimating];
        self.activityIndicator.accessibilityLabel = [NSBundle cyl_localizedStringForKey:CYLRefreshHeaderRefreshingText];
    } else {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.alpha = MAX(0, MIN(1, self.pullingPercent));
        self.activityIndicator.accessibilityLabel = [NSBundle cyl_localizedStringForKey:
            state == CYLRefreshStatePulling ? CYLRefreshHeaderPullingText : CYLRefreshHeaderIdleText];
    }
}

@end
