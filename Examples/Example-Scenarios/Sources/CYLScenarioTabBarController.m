//
//  CYLScenarioTabBarController.m
//  Example-Scenarios
//

#import "CYLScenarioTabBarController.h"
#import "CYLScenario.h"
#import "CYLScenarioListViewController.h"
#import "CYLFeedViewController.h"
#import "CYLResourcesViewController.h"
#import "CYLScenarioLocalization.h"

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
                           title:CYLScenarioLocalizedString(CYLScenarioL10nTabScenarios)],
        [self navigationWithRoot:[[CYLScenarioListViewController alloc] initWithSections:[CYLScenario animationSections]]
                           title:CYLScenarioLocalizedString(CYLScenarioL10nTabAnimations)],
        [self navigationWithRoot:[CYLFeedViewController new] title:CYLScenarioLocalizedString(CYLScenarioL10nTabFeed)],
        [self navigationWithRoot:[CYLResourcesViewController new] title:CYLScenarioLocalizedString(CYLScenarioL10nTabResources)],
    ];
}

+ (NSArray<NSDictionary *> *)demoTabBarItemsAttributes {
    // SF Symbols as UIImage objects; CYLTabBarItemImage accepts names or images.
    NSArray *items = @[
        @[CYLScenarioLocalizedString(CYLScenarioL10nTabScenarios), @"rectangle.stack", @"rectangle.stack.fill"],
        @[CYLScenarioLocalizedString(CYLScenarioL10nTabAnimations), @"sparkles", @"sparkles"],
        @[CYLScenarioLocalizedString(CYLScenarioL10nTabFeed), @"bubble.left.and.bubble.right", @"bubble.left.and.bubble.right.fill"],
        @[CYLScenarioLocalizedString(CYLScenarioL10nTabResources), @"shippingbox", @"shippingbox.fill"],
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
