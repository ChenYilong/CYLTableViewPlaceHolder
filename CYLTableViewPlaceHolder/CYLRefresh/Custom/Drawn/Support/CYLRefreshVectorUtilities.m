//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Vector/Utilities.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import <UIKit/UIKit.h>
#import "CYLRefreshVectorUtilities.h"
#import "CYLRefreshVectorElement.h"

#define kElementIdentifier @"SVGElementIdentifier"

@implementation CYLRefreshVectorUtilities


+(CALayer *) newLayerForElement:(CYLRefreshVectorElement*) element withPath:(CGPathRef) path
{
    CAShapeLayer* _shapeLayer = [CAShapeLayer layer];
    
    _shapeLayer.name = element.identifier;
    [_shapeLayer setValue:element.identifier forKey:kElementIdentifier];
    
    CGFloat strokeWidth = element.strokeWidth;
    
    CGRect pathRect = CGRectInset(CGPathGetBoundingBox(path), -strokeWidth/2., -strokeWidth/2.);
    
    _shapeLayer.path = path; //CGPathRelease(finalPath);
    _shapeLayer.frame = pathRect;
    
    CGRect localRect =  CGRectMake(0, 0, CGRectGetWidth(pathRect), CGRectGetHeight(pathRect));

    //DEBUG ONLY: CGRect shapeLayerFrame = _shapeLayer.frame;
    CAShapeLayer* strokeLayer = _shapeLayer;
    CAShapeLayer* fillLayer = _shapeLayer;
    
    if( strokeWidth > 0 && element.stroke != nil )
    {
        CGSize fakeSize = CGSizeMake( strokeWidth, strokeWidth );
        strokeLayer.lineWidth = hypot(fakeSize.width, fakeSize.height)/M_SQRT2;
        strokeLayer.strokeColor = element.stroke.CGColor;
    }
    else
    {
        if( element.stroke != nil )
        {
            strokeLayer.strokeColor = nil; // This is how you tell Apple that the stroke is disabled; a strokewidth of 0 will NOT achieve this
            strokeLayer.lineWidth = 0.0f; // MUST set this explicitly, or Apple assumes 1.0
        }
        else
        {
            strokeLayer.lineWidth = 1.0f; // default value from SVG spec
        }
    }
    
    //CGFloat alpha = 1;
    //[element.fill getRed:nil green:nil blue:nil alpha:&alpha];
    
    fillLayer.fillColor = element.fill.CGColor;
    fillLayer.opacity = element.opacity;//*alpha;

    if (strokeLayer == fillLayer)
    {
        return strokeLayer;
    }
    
    CALayer* combined = [CALayer layer];
    combined.frame = strokeLayer.frame;
    strokeLayer.frame = localRect;
    if ([strokeLayer isKindOfClass:[CAShapeLayer class]])
        strokeLayer.fillColor = nil;
    fillLayer.frame = localRect;
    [combined addSublayer:fillLayer];
    [combined addSublayer:strokeLayer];
    return combined;
}

@end
