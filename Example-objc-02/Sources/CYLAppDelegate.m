#import "CYLAppDelegate.h"
#import "CYLCollectionViewController.h"

@implementation CYLAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[CYLCollectionViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}
@end
