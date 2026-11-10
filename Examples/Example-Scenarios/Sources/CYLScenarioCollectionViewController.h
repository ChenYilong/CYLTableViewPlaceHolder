//
//  CYLScenarioCollectionViewController.h
//  Example-Scenarios
//

#import <UIKit/UIKit.h>
#import "CYLScenario.h"

NS_ASSUME_NONNULL_BEGIN

/// A photo grid that starts empty: the block API shows the placeholder for UICollectionView too (issue #11).
@interface CYLScenarioCollectionViewController : UICollectionViewController
- (instancetype)initWithScenario:(CYLScenario *)scenario NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
