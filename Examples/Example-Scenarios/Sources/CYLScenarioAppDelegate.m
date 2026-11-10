//
//  CYLScenarioAppDelegate.m
//  Example-Scenarios
//

#import "CYLScenarioAppDelegate.h"
#import "CYLScenarioPlusButton.h"
#import "CYLScenarioTabBarController.h"

/// UIScene lifecycle: iOS 26 apps built with a current SDK must adopt it, or UIKit stops at launch.
@interface CYLScenarioSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation CYLScenarioSceneDelegate
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:UIWindowScene.class]) return;
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window.backgroundColor = UIColor.systemBackgroundColor;
    // As in CYLTabBarController's demo: register the plus button before creating the tab bar controller.
    [CYLScenarioPlusButton registerPlusButton];
    self.window.rootViewController = [[CYLScenarioTabBarController alloc] initForDemo];
    [self.window makeKeyAndVisible];
}
@end

@implementation CYLScenarioAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                              options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                                                         sessionRole:connectingSceneSession.role];
    configuration.delegateClass = CYLScenarioSceneDelegate.class;
    return configuration;
}
@end
