//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from StoreHouse/StoreHousePath.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

#import "CYLRefreshStoreHouseLine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshStoreHousePath : NSObject

+ (NSArray<CYLRefreshStoreHouseLine*>*)linesFromArray:(NSArray<NSString*>*)array;
+ (NSArray<CYLRefreshStoreHouseLine*>*)linesFrom:(NSString*) str scale:(CGFloat) scale space:(NSInteger) space;

+ (NSArray<NSString*>*) arrayAkta;
+ (NSArray<NSString*>*) arrayStoreHouse;

@end

NS_ASSUME_NONNULL_END
