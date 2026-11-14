//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Vector/Utilities.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshVectorElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshVectorUtilities : NSObject

+ (CALayer *) newLayerForElement:(CYLRefreshVectorElement*) element withPath:(CGPathRef) path;

@end

NS_ASSUME_NONNULL_END
