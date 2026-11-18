//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Component/UIVectorView.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

#import <UIKit/UIKit.h>

#import "CYLRefreshVectorImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshVectorView : UIView

@property (nonatomic, strong, nullable) CYLRefreshVectorImage *image;

- (void)parserPaths:(NSArray<NSString*>*) paths;
- (void)parserColors:(NSArray<UIColor*>*) colors;

@end

NS_ASSUME_NONNULL_END
