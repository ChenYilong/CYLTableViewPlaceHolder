//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/PathElement.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "CYLRefreshVectorElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshVectorPathElement : CYLRefreshVectorElement

+ (instancetype) newWith:(NSString*) data;

@property (nonatomic, readonly) CGPathRef pathForShape;

@end

NS_ASSUME_NONNULL_END
