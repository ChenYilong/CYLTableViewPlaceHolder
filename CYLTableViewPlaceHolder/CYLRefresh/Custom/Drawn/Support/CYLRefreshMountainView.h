//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Fly/MountainView.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import <UIKit/UIKit.h>

#define CYLREFRESH_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

#define CYLREFRESH_RATIO_Y(rect) (CGRectGetMaxY(rect) / 120.f)
#define CYLREFRESH_RATIO_X(rect) (CGRectGetMaxX(rect) / 240.f)

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshMountainView : UIView

@property (nonatomic, strong) UIColor *colorAccent;
@property (nonatomic, strong) UIColor *colorPrimary;

- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent;

@end

NS_ASSUME_NONNULL_END
