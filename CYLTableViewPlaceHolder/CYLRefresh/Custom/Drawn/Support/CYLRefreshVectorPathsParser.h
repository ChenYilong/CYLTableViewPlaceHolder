//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Vector/PathsParser.h) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Partially spammy; not as spammy as CYLREFRESH_DEBUG_PATH_CREATION
 */
#define CYLREFRESH_VERBOSE_PARSE_SVG 0

/*! Very useful for debugging the parser - this will output one line of logging
 * for every CGPath command that's actually done; you can then compare these lines
 * to the input source file, and manually check what's being sent to the renderer
 * versus what was expected
 *
 * this is MORE SPAMMY than CYLREFRESH_VERBOSE_PARSE_SVG
 */
#define CYLREFRESH_DEBUG_PATH_CREATION 0

typedef NS_ENUM(NSUInteger, CYLRefreshCurveType) {
    CurveTypePoint,
    CurveTypeCubic,
    CurveTypeQuadratic,
};

typedef struct CYLRefreshCurve
{
    CYLRefreshCurveType type;
    CGPoint c1;
    CGPoint c2;
    CGPoint p;
} CYLRefreshCurve;

@interface CYLRefreshVectorPathsParser : NSObject

+ (CYLRefreshCurve) startingCurve;

+ (CYLRefreshCurve) readMovetoDrawToCmdGroups:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readMovetoDrawto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readMoveto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readMovetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;

+ (CYLRefreshCurve) readLineToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readVerticalLineToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
+ (CYLRefreshCurve) readVerticalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
+ (CYLRefreshCurve) readHorizontalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
+ (CYLRefreshCurve) readHorizontalLineToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;

+ (CYLRefreshCurve) readQuadraticCurveToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readQuadraticCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readQuadraticCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
+ (CYLRefreshCurve) readSmoothQuadraticCurveToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve;
+ (CYLRefreshCurve) readSmoothQuadraticCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve;
+ (CYLRefreshCurve) readSmoothQuadraticCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve;

+ (CYLRefreshCurve) readCurveToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;
+ (CYLRefreshCurve) readSmoothCurveToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readSmoothCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve isRelative:(BOOL) isRelative;
+ (CYLRefreshCurve) readSmoothCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve;

+ (CYLRefreshCurve) readEllipticalArcArguments:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative;

+ (CYLRefreshCurve) readCloseCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin;

@end

NS_ASSUME_NONNULL_END
