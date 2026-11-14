//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Vector/Element.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

//#import <Foundation/Foundation.h>
//#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshVectorElement : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) UIColor *stroke;
@property (nonatomic, strong) UIColor *fill;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, assign) CGFloat strokeOpacity;
@property (nonatomic, assign) CGRect viewport;

@property (nonatomic, assign) BOOL changed;
@property (nonatomic, strong) CALayer *layer;

- (CALayer *)newLayer;

@end

NS_ASSUME_NONNULL_END
