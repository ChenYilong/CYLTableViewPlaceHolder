//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Fly/MountainView.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshMountainView.h"

#define ARGB(argb)[UIColor colorWithRed:((float)((argb&0xFF0000)>> 16))/ 255.0 green:((float)((argb&0x00FF00)>> 8))/ 255.0 blue: ((float)(argb&0x0000FF))/ 255.0 alpha:((float)((argb&0xFF000000)>>24))/ 255.0]

#define TREE_WIDTH  30
#define TREE_HEIGHT 60

@interface CYLRefreshMountainView ()

@property (nonatomic, strong) UIColor *colorBackground;
@property (nonatomic, strong) UIColor *colorMount1;
@property (nonatomic, strong) UIColor *colorMount2;
@property (nonatomic, strong) UIColor *colorMount3;
@property (nonatomic, strong) UIColor *colorTree1Brink;
@property (nonatomic, strong) UIColor *colorTree1Branch;
@property (nonatomic, strong) UIColor *colorTree2Brink;
@property (nonatomic, strong) UIColor *colorTree2Branch;
@property (nonatomic, strong) UIColor *colorTree3Brink;
@property (nonatomic, strong) UIColor *colorTree3Branch;

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, strong) UIBezierPath *treePathBrink;
@property (nonatomic, strong) UIBezierPath *treePathBranch;

@end

@implementation CYLRefreshMountainView

#pragma mark - lifecycle

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setColorPrimary:(UIColor *)color {
    _colorPrimary = color;
    
    [self setBackgroundColor:color];
    [self setColorMount1:[self mix:color c2:ARGB(0x99ffffff)]];
    [self setColorMount2:[self mix:color c2:ARGB(0x993C929C)]];
    [self setColorMount3:[self mix:color c2:ARGB(0xCC3E5F73)]];
    
    [self setColorTree1Branch:[self mix:color c2:ARGB(0x551F7177)]];
    [self setColorTree1Brink:[self mix:color c2:ARGB(0xCC0C3E48)]];
    [self setColorTree2Branch:[self mix:color c2:ARGB(0x5534888F)]];
    [self setColorTree2Brink:[self mix:color c2:ARGB(0xCC1B6169)]];
    [self setColorTree3Branch:[self mix:color c2:ARGB(0x5557B1AE)]];
    [self setColorTree3Brink:[self mix:color c2:ARGB(0xCC62A4AD)]];
    
}

- (UIColor *)mix:(UIColor*)color1 c2:(UIColor *)color2
{
    const CGFloat * components1 = CGColorGetComponents(color1.CGColor);
    const CGFloat * components2 = CGColorGetComponents(color2.CGColor);
    const CGFloat ratio = components2[3];
    
    CGFloat r = components1[0]*(1-ratio) + components2[0]*ratio;
    CGFloat g = components1[1]*(1-ratio) + components2[1]*ratio;
    CGFloat b = components1[2]*(1-ratio) + components2[2]*ratio;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawMountain:context width:width height:height];
}

- (void)drawMountain:(CGContextRef) context width:(CGFloat)width height:(CGFloat)height {
    CGFloat y = 0;
    [self.colorMount1 setFill];
    CGContextMoveToPoint(context, 0, y = height - width*4/29 - _offset*0.6);
    CGContextAddLineToPoint(context, width*6/29, y -= width*4/29);
    CGContextAddLineToPoint(context, width*17/29, y += width*4.5/29);
    CGContextAddLineToPoint(context, width*27/29, y -= width*5.5/29);
    CGContextAddLineToPoint(context, width, y += width*2/29);
    CGContextAddLineToPoint(context, width, height);
    CGContextAddLineToPoint(context, 0, height);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, width*6.5/29, height - width*5/29 - _offset*0.4);
    CGContextScaleCTM(context, -0.7, -0.7);
    [self drawTree:context];
    CGContextRestoreGState(context);
    
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, width*4.5/29, height - width*4.5/29 - _offset*0.4);
    CGContextScaleCTM(context, -0.5, -0.5);
    [self drawTree:context];
    CGContextRestoreGState(context);
    
    [self.colorMount2 setFill];
    CGContextMoveToPoint(context, 0, y = height - width*3/29 - _offset*0.4);
    CGContextAddLineToPoint(context, width*7/29, y -= width*3/29);
    CGContextAddLineToPoint(context, width*18/29, y += width*4.5/29);
    CGContextAddLineToPoint(context, width*26/29, y -= width*4.5/29);
    CGContextAddLineToPoint(context, width, y += width*2/29);
    CGContextAddLineToPoint(context, width, height);
    CGContextAddLineToPoint(context, 0, height);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, width*16/29, height - width*3/29 - _offset*0.2);
    CGContextScaleCTM(context, 0.85, -0.85);
    [self drawTree:context];
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, width*19/29, height - width*3/29 - _offset*0.2);
    CGContextScaleCTM(context, 1, -1);
    [self drawTree:context];
    CGContextRestoreGState(context);
    
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, width*22/29, height - width*3/29 - _offset*0.2);
    CGContextScaleCTM(context, 0.7, -0.7);
    [self drawTree:context];
    CGContextRestoreGState(context);
    
    [self.colorMount3 setFill];
    CGContextMoveToPoint(context, 0, y = height - width*2/29 - _offset*0.2);
    CGContextAddCurveToPoint(context, width*3.5/29, y - width*1/29, width*21/29, y - width*3/29, width, y - width*1/29);
    CGContextAddLineToPoint(context, width, height);
    CGContextAddLineToPoint(context, 0, height);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
}

- (void)drawTree:(CGContextRef)context {
    CGContextSetLineWidth(context, 6);
    
    CGContextTranslateCTM(context, 0, TREE_HEIGHT / 2);
    [self.colorTree1Branch setFill];
    [self.treePathBranch fill];
    [self.colorTree1Brink setStroke];
    [self.treePathBranch stroke];

    CGContextTranslateCTM(context, 0, -TREE_HEIGHT / 2);
    [self.colorTree1Brink setFill];
    [self.treePathBrink fill];
}

- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent {
    [self setOffset: offset];
    [self updateTreePath: percent];
}

- (void)updateTreePath:(CGFloat)percent {
    CGFloat brinkSize = TREE_WIDTH * 0.05;
    CGFloat branchSize = TREE_WIDTH * 0.2;
    UIBezierPath* pathBrink = [UIBezierPath new];
    UIBezierPath* pathBranch = [UIBezierPath new];
    
    CGFloat offset = percent * TREE_WIDTH * 0.3;
    NSMutableArray<NSValue*> *array = [NSMutableArray array];
    
    CGFloat topBranch = TREE_HEIGHT * 0.6;
    [pathBranch moveToPoint:CGPointMake(offset, topBranch)];
    for (CGFloat y = topBranch; y > 0; y -= 0.1) {
        CGFloat p = y / topBranch;
        CGFloat xx = 1 - pow(1 - p, 0.5);
        CGFloat x = xx * offset;
        CGFloat xs = branchSize * (1 - p * p);
        [pathBranch addLineToPoint:CGPointMake(x - xs, y)];
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x + xs, y)]];
    }
    [pathBranch addLineToPoint:CGPointMake(-branchSize, 0)];
    [pathBranch addCurveToPoint:CGPointMake(branchSize, 0)
                 controlPoint1:CGPointMake(-branchSize, -branchSize*1.5)
                 controlPoint2:CGPointMake(branchSize, -branchSize*1.5)];
    for (int i = 0; i < array.count; i++) {
        [pathBranch addLineToPoint:[array[array.count-i-1] CGPointValue]];
    }
    [array removeAllObjects];
    
    [pathBranch applyTransform:CGAffineTransformMakeTranslation(offset * 0.3, 0)];
    
    
    CGFloat topBrink = TREE_HEIGHT * 0.7;
    [pathBrink moveToPoint:CGPointMake(offset, topBrink)];
    for (CGFloat y = topBrink; y > 0; y -= 0.1) {
        CGFloat p = (y / topBrink) * 0.7;
        CGFloat xx = 1 - pow(1 - p, 0.5);
        CGFloat x = xx * offset;
        CGFloat xs = brinkSize;
        if (p > 0.7 / 2) {
            xs = brinkSize * (0.7 - p) / 0.35;
        }
        [pathBrink addLineToPoint:CGPointMake(x - xs, y)];
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x + xs, y)]];
    }
    [pathBrink addLineToPoint:CGPointMake(-brinkSize, 0)];
    [pathBrink addLineToPoint:CGPointMake(brinkSize, 0)];
    for (int i = 0; i < array.count; i++) {
        [pathBrink addLineToPoint:[array[array.count-i-1] CGPointValue]];
    }
    
    
    [self setTreePathBrink:pathBrink];
    [self setTreePathBranch:pathBranch];
}

@end
