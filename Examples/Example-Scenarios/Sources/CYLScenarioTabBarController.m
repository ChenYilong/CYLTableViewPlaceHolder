//
//  CYLScenarioTabBarController.m
//  Example-Scenarios
//

#import "CYLScenarioTabBarController.h"
#import "CYLScenario.h"
#import "CYLScenarioListViewController.h"
#import "CYLFeedViewController.h"
#import "CYLResourcesViewController.h"

@implementation CYLScenarioTabBarController

- (instancetype)initForDemo {
    return [super initWithViewControllers:[[self class] demoViewControllers]
                    tabBarItemsAttributes:[[self class] demoTabBarItemsAttributes]
                              imageInsets:UIEdgeInsetsZero
                  titlePositionAdjustment:UIOffsetMake(0, -3)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor = UIColor.systemTealColor;
}

+ (UINavigationController *)navigationWithRoot:(UIViewController *)root title:(NSString *)title {
    root.title = title;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:root];
    navigation.navigationBar.prefersLargeTitles = YES;
    return navigation;
}

+ (NSArray<UIViewController *> *)demoViewControllers {
    return @[
        // The first tab: every scenario in a table; each row pushes its placeholder.
        [self navigationWithRoot:[[CYLScenarioListViewController alloc] initWithSections:[CYLScenario scenarioSections]]
                           title:@"场景 · Scenarios"],
        [self navigationWithRoot:[[CYLScenarioListViewController alloc] initWithSections:[CYLScenario animationSections]]
                           title:@"动画 · Animations"],
        [self navigationWithRoot:[CYLFeedViewController new] title:@"动态 · Feed"],
        [self navigationWithRoot:[CYLResourcesViewController new] title:@"资源 · Resources"],
    ];
}

+ (NSArray<NSDictionary *> *)demoTabBarItemsAttributes {
    // SF Symbols as UIImage objects; CYLTabBarItemImage accepts names or images.
    NSArray *items = @[
        @[@"场景", @"rectangle.stack", @"rectangle.stack.fill"],
        @[@"动画", @"sparkles", @"sparkles"],
        @[@"动态", @"bubble.left.and.bubble.right", @"bubble.left.and.bubble.right.fill"],
        @[@"资源", @"shippingbox", @"shippingbox.fill"],
    ];
    NSMutableArray<NSDictionary *> *attributes = [NSMutableArray array];
    for (NSArray *item in items) {
        [attributes addObject:@{
            CYLTabBarItemTitle: item[0],
            CYLTabBarItemImage: [UIImage systemImageNamed:item[1]],
            CYLTabBarItemSelectedImage: [UIImage systemImageNamed:item[2]],
        }];
    }
    return attributes;
}

@end
