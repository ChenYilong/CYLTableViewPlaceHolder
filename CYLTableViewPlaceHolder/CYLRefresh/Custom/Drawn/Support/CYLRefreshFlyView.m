//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Fly/FlyView.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshFlyView.h"
#import "CYLRefreshVectorImage.h"

@interface CYLRefreshFlyView ()

@property (nonatomic, strong) CYLRefreshVectorImage *image;

@end

@implementation CYLRefreshFlyView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (CGRectEqualToRect(CGRectZero, frame)) {
        frame = CGRectMake(0, 0, 30, 30);
    }
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:FALSE];
        [self setImage:[CYLRefreshVectorImage new]];
    }
    return self;
}

- (void)setImage:(CYLRefreshVectorImage *)image {
    _image = image;
    [image parserColors:@[UIColor.whiteColor]];
    [image parserPaths:@[@"M2.01,21L23,12 2.01,3 2,10l15,2 -15,2z"]];
    if (self.frame.size.height > 0 && self.frame.size.width > 0) {
        [image scaleToFitInside:self.frame.size];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (_image) {
        [_image scaleToFitInside:self.frame.size];
    }
}

- (void)setColorAccent:(UIColor *)colorAccent {
    _colorAccent = colorAccent;
    [self.image parserColors:@[colorAccent]];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self.image renderInContext:UIGraphicsGetCurrentContext()];
}

@end
