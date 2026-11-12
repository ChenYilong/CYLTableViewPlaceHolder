//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Vector/PathElement.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "CYLRefreshVectorElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshVectorPathElement : CYLRefreshVectorElement

+ (instancetype) newWith:(NSString*) data;

@property (nonatomic, readonly) CGPathRef pathForShape;

@end

NS_ASSUME_NONNULL_END
