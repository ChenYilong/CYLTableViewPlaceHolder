//
//  CYLRefreshCupertinoFooter.m
//  CYLRefresh
//

#import "CYLRefreshCupertinoFooter.h"
#import "NSBundle+CYLRefresh.h"
#import "CYLRefreshConst.h"
#import "UIView+CYLExtension.h"

@implementation CYLRefreshCupertinoFooter

- (void)prepare
{
    [super prepare];
    UIActivityIndicatorView *indicator;
    if (@available(iOS 13.0, *)) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    } else {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    indicator.hidesWhenStopped = YES;
    indicator.isAccessibilityElement = YES;
    indicator.accessibilityLabel = [NSBundle cyl_localizedStringForKey:CYLRefreshAutoFooterRefreshingText];
    [self addSubview:indicator];
    _activityIndicator = indicator;
}

- (void)placeSubviews
{
    [super placeSubviews];
    self.activityIndicator.center = CGPointMake(self.cyl_w * 0.5, self.cyl_h * 0.5);
}

- (void)setState:(CYLRefreshState)state
{
    CYLRefreshCheckState
    if (state == CYLRefreshStateRefreshing) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

@end
