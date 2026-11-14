//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Vector/VectorImage.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import "CYLRefreshVectorImage.h"
#import "CYLRefreshVectorPathElement.h"

@interface CYLRefreshVectorImage ()

@property (nonatomic, strong) NSMutableArray<CYLRefreshVectorElement*> *elements;

@end

@implementation CYLRefreshVectorImage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.size = CGSizeZero;
        self.frame = CGRectZero;
        self.viewport = CGRectZero;
        self.elements = [NSMutableArray array];
    }
    return self;
}

- (CGSize)size {
    if (self.elements.count > 0 && CGRectEqualToRect(_frame, CGRectZero)) {
        return self.viewport.size;
    }
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setOpacity:(CGFloat)opacity {
    _opacity = opacity;
    
    if (_elements) {
        for (CYLRefreshVectorElement* element in _elements) {
            element.opacity = opacity;
        }
    }
}

- (void)addElement:(CYLRefreshVectorElement *)element {
    [_elements addObject:element];
    self.viewport = CGRectUnion(self.viewport, element.viewport);
}

- (void)parserPaths:(NSArray<NSString *> *)paths {
    _viewport = CGRectZero;
    [_elements removeAllObjects];
    for (NSString* path in paths) {
        [self addElement:[CYLRefreshVectorPathElement newWith:path]];
    }
}

- (void)parserColors:(NSArray<UIColor *> *)colors {
    if (_elements.count == colors.count) {
        for (int i = 0; i < colors.count; i++) {
            _elements[i].fill = colors[i];
        }
    } else if (_elements.count != colors.count && colors.count > 0) {
        UIColor* color = colors[0];
        for (int i = 0; i < _elements.count; i++) {
            if (i < colors.count) {
                color = colors[i];
            }
            _elements[i].fill = color;
        }
    }
}

- (void)renderInContext:(CGContextRef)context {
    if (!CGRectEqualToRect(self.viewport, CGRectZero)) {
        
        CGPoint point = self.frame.origin;
        CGPoint start = self.viewport.origin;
        CGSize sizeCanvas = self.size;
        CGSize sizeImage = self.viewport.size;
        CGFloat scaleX = sizeCanvas.width / sizeImage.width;
        CGFloat scaleY = sizeCanvas.height / sizeImage.height;
        
        CGContextSaveGState(context);
        
        CGContextTranslateCTM(context, point.x , point.y);
        CGContextTranslateCTM(context, -scaleX*start.x , -scaleY*start.y);
        CGContextScaleCTM(context, scaleX, scaleY);
        
        for (CYLRefreshVectorElement* element in self.elements) {
            [element.layer renderInContext:context];
        }
        
        CGContextRestoreGState(context);
    }
}

-(void) scaleToFitInside:(CGSize) maxSize
{
    if (CGSizeEqualToSize(CGSizeZero, self.size) || CGSizeEqualToSize(CGSizeZero, maxSize)) {
        self.size = maxSize;
        return;
    }
    
    float wScale = maxSize.width / self.size.width;
    float hScale = maxSize.height / self.size.height;
    
    float smallestScaleUp = MIN( wScale, hScale );
    
//    if( smallestScaleUp < 1.0f )
//        smallestScaleUp = MAX( wScale, hScale ); // instead of scaling-up the smallest, scale-down the largest
    
    self.size = CGSizeApplyAffineTransform( self.size, CGAffineTransformMakeScale( smallestScaleUp, smallestScaleUp));
}

- (void)setGeometricWidth:(CGFloat) width {
    CGSize size = self.size;
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        [self setSize:CGSizeMake(width, size.height * width / size.width)];
    }
}

- (void)setGeometricHeight:(CGFloat) height {
    CGSize size = self.size;
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        [self setSize:CGSizeMake(size.width * height / size.height, height)];
    }
}

- (void)moveTo:(CGPoint)pt {
    CGSize size = self.size;
    self.frame = CGRectMake(pt.x, pt.y, size.width, size.height);
}

@end
