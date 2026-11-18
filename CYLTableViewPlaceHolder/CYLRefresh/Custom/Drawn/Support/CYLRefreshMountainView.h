//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Fly/MountainView.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

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
