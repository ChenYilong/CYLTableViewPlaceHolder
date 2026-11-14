//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  StoreHouse/StoreHousePath.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshStoreHouseLine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshStoreHousePath : NSObject

+ (NSArray<CYLRefreshStoreHouseLine*>*)linesFromArray:(NSArray<NSString*>*)array;
+ (NSArray<CYLRefreshStoreHouseLine*>*)linesFrom:(NSString*) str scale:(CGFloat) scale space:(NSInteger) space;

+ (NSArray<NSString*>*) arrayAkta;
+ (NSArray<NSString*>*) arrayStoreHouse;

@end

NS_ASSUME_NONNULL_END
