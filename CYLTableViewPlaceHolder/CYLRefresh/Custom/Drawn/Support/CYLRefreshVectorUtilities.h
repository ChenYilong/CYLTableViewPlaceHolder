//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/Utilities.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

#import "CYLRefreshVectorElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshVectorUtilities : NSObject

+ (CALayer *) newLayerForElement:(CYLRefreshVectorElement*) element withPath:(CGPathRef) path;

@end

NS_ASSUME_NONNULL_END
