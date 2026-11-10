//
//  CYLScenarioDetailViewController.h
//  Example-Scenarios
//

#import <UIKit/UIKit.h>
#import "CYLScenario.h"

NS_ASSUME_NONNULL_BEGIN

/// Shows one scenario in an empty table view, driven by the scenario's flow.
@interface CYLScenarioDetailViewController : UITableViewController
- (instancetype)initWithScenario:(CYLScenario *)scenario NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
