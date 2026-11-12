//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Component/UIVectorView.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import <UIKit/UIKit.h>

#import "CYLRefreshVectorImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshVectorView : UIView

@property (nonatomic, strong, nullable) CYLRefreshVectorImage *image;

- (void)parserPaths:(NSArray<NSString*>*) paths;
- (void)parserColors:(NSArray<UIColor*>*) colors;

@end

NS_ASSUME_NONNULL_END
