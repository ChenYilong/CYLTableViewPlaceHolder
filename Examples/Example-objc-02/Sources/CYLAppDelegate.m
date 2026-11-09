#import "CYLAppDelegate.h"
#import "CYLCollectionViewController.h"
#import "CYLPagingViewController.h"

/// UIScene lifecycle: iOS 26 apps built with a current SDK must adopt it, or UIKit stops at launch.
@interface CYLSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation CYLSceneDelegate
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:UIWindowScene.class]) return;
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    UIViewController *controller = [NSProcessInfo.processInfo.arguments containsObject:@"-paging"]
        ? [CYLPagingViewController new] : [CYLCollectionViewController new];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.window makeKeyAndVisible];
}
@end

@implementation CYLAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                              options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                                                         sessionRole:connectingSceneSession.role];
    configuration.delegateClass = CYLSceneDelegate.class;
    return configuration;
}
@end
