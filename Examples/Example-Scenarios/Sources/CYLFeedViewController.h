//
//  CYLFeedViewController.h
//  Example-Scenarios
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// A feed as a real app loads it: an animated loading placeholder, then data; pulling to refresh fails into an
/// error placeholder with a retry button; loading more ends with "no more data".
@interface CYLFeedViewController : UITableViewController
@end

NS_ASSUME_NONNULL_END
