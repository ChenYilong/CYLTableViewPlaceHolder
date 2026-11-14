//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Vector/Element.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshVectorElement.h"

@implementation CYLRefreshVectorElement
@synthesize layer = _layer;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.strokeWidth = 0;
        self.fill = [UIColor whiteColor];
        self.opacity = 1;
    }
    return self;
}

- (void)setLayer:(CALayer *)layer {
    _layer = layer;
    _changed = FALSE;
}

- (void)setStroke:(UIColor *)stroke {
    _stroke = stroke;
    _changed = TRUE;
}

- (void)setFill:(UIColor *)fill {
    _fill = fill;
    _changed = TRUE;
}

- (void)setOpacity:(CGFloat)opacity {
    _opacity = opacity;
    _changed = TRUE;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    _strokeWidth = strokeWidth;
    _changed = TRUE;
}

- (CALayer *)layer {
    if (_changed) {
        return _layer = [self newLayer];
    }
    return _layer;
}

- (CALayer *)newLayer {
    return nil;
}

@end
