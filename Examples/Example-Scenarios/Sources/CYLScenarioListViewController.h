//
//  CYLScenarioListViewController.h
//  Example-Scenarios
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// A grouped list of scenarios; tapping a row pushes its placeholder page.
@interface CYLScenarioListViewController : UITableViewController
/// @param sections @{@"title": NSString, @"items": NSArray<CYLScenario *>}, as returned by CYLScenario.
- (instancetype)initWithSections:(NSArray<NSDictionary *> *)sections NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
