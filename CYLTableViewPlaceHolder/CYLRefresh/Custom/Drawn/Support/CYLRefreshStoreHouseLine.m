//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from StoreHouse/StoreHouseLine.m (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

#import "CYLRefreshStoreHouseLine.h"

@implementation CYLRefreshStoreHouseLine

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transform = CGAffineTransformIdentity;
    }
    return self;
}

@end
