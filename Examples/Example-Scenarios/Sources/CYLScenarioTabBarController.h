//
//  CYLScenarioTabBarController.h
//  Example-Scenarios
//

#import <CYLTabBarController/CYLTabBarController.h>

NS_ASSUME_NONNULL_BEGIN

/// The demo's root: four tabs around the plus button, as in CYLTabBarController's Objective-C demo
/// (MainTabBarController). Register CYLScenarioPlusButton before creating it.
@interface CYLScenarioTabBarController : CYLTabBarController
- (instancetype)initForDemo;
@end

NS_ASSUME_NONNULL_END
