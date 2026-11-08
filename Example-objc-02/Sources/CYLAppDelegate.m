#import "CYLAppDelegate.h"
#import "CYLCollectionViewController.h"
#import "CYLPagingViewController.h"

@implementation CYLAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *controller = [NSProcessInfo.processInfo.arguments containsObject:@"-paging"]
        ? [CYLPagingViewController new] : [CYLCollectionViewController new];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.window makeKeyAndVisible];
    return YES;
}
@end
