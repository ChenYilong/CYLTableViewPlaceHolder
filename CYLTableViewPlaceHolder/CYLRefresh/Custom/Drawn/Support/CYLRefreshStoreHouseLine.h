//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  StoreHouse/StoreHouseLine.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshStoreHouseLine : NSObject

@property (nonatomic, assign) CGPoint start;
@property (nonatomic, assign) CGPoint end;
@property (nonatomic, assign) CGPoint middle;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGAffineTransform transform;

@end

NS_ASSUME_NONNULL_END
