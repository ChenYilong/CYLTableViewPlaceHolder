//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  StoreHouse/StoreHouseLine.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

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
