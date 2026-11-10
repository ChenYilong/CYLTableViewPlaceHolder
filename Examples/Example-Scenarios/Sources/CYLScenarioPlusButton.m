//
//  CYLScenarioPlusButton.m
//  Example-Scenarios
//

#import "CYLScenarioPlusButton.h"
#import "CYLPublishViewController.h"

@implementation CYLScenarioPlusButton

#pragma mark - CYLPlusButtonSubclassing

+ (id)plusButton {
    CYLScenarioPlusButton *button = [[self alloc] init];
    UIImageSymbolConfiguration *configuration =
        [UIImageSymbolConfiguration configurationWithPointSize:38 weight:UIImageSymbolWeightBold];
    [button setImage:[UIImage systemImageNamed:@"plus.circle.fill" withConfiguration:configuration]
            forState:UIControlStateNormal];
    button.tintColor = UIColor.systemTealColor;
    button.frame = CGRectMake(0, 0, 56, 56);
    button.accessibilityLabel = @"发布 · Publish";
    button.accessibilityIdentifier = @"plusButton";
    [button addTarget:button action:@selector(publish) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

/// Raises the button a little above the tab bar's center.
+ (CGFloat)constantOfPlusButtonCenterYOffsetForTabBarHeight:(CGFloat)tabBarHeight {
    return -6;
}

#pragma mark - Action

- (void)publish {
    UIViewController *presenter = self.window.rootViewController;
    while (presenter.presentedViewController) presenter = presenter.presentedViewController;
    UINavigationController *navigation = [[UINavigationController alloc]
        initWithRootViewController:[CYLPublishViewController new]];
    [presenter presentViewController:navigation animated:YES completion:nil];
}

@end
