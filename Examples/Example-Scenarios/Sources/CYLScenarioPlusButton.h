//
//  CYLScenarioPlusButton.h
//  Example-Scenarios
//

#import <CYLTabBarController/CYLTabBarController.h>

NS_ASSUME_NONNULL_BEGIN

/// The plus button in the middle of the tab bar, as in CYLTabBarController's Objective-C demo. Tapping it presents
/// the publish flow (CYLPublishViewController).
@interface CYLScenarioPlusButton : CYLPlusButton <CYLPlusButtonSubclassing>
@end

NS_ASSUME_NONNULL_END
