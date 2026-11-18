//
//  Third-party refresh code (MIT, see LICENSE.refresh-third-party.txt), ported from Vector/VectorImage.h (commit 9319448)
//  into CYLRefresh; identifiers renamed with the CYLRefresh prefix.

#import <Foundation/Foundation.h>

#import "CYLRefreshVectorElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshVectorImage : NSObject

@property (nonatomic, readonly) NSArray<CYLRefreshVectorElement*> *elements;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGRect viewport;
@property (nonatomic, assign) CGFloat opacity;

- (void)addElement:(CYLRefreshVectorElement*) element;

- (void)parserPaths:(NSArray<NSString*>*) paths;
- (void)parserColors:(NSArray<UIColor*>*) colors;

- (void)scaleToFitInside:(CGSize) maxSize;
- (void)renderInContext:(CGContextRef) context;

- (void)setGeometricWidth:(CGFloat) width;
- (void)setGeometricHeight:(CGFloat) height;

- (void)moveTo:(CGPoint) pt;

@end

NS_ASSUME_NONNULL_END
