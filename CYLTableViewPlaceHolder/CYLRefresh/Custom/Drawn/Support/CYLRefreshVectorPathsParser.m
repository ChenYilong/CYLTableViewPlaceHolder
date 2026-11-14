//
//  Ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, MIT, commit 9319448,
//  Vector/PathsParser.m) into CYLRefresh; identifiers renamed with the CYLRefresh prefix. See CYLRefresh/LICENSE.third-party.

/* references
 http://www.w3.org/TR/2011/REC-SVG11-20110816/paths.html#PathDataBNF
 http://www.w3.org/TR/2011/REC-SVG11-20110816/shapes.html#PointsBNF
 
 */

/*
 http://www.w3.org/TR/2011/REC-SVG11-20110816/paths.html#PathDataBNF
 svg-path:
 wsp* moveto-drawto-command-groups? wsp*
 moveto-drawto-command-groups:
 moveto-drawto-command-group
 | moveto-drawto-command-group wsp* moveto-drawto-command-groups
 moveto-drawto-command-group:
 moveto wsp* drawto-commands?
 drawto-commands:
 drawto-command
 | drawto-command wsp* drawto-commands
 drawto-command:
 closepath
 | lineto
 | horizontal-lineto
 | vertical-lineto
 | curveto
 | smooth-curveto
 | quadratic-bezier-curveto
 | smooth-quadratic-bezier-curveto
 | elliptical-arc
 moveto:
 ( "M" | "m" ) wsp* moveto-argument-sequence
 moveto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? lineto-argument-sequence
 closepath:
 ("Z" | "z")
 lineto:
 ( "L" | "l" ) wsp* lineto-argument-sequence
 lineto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? lineto-argument-sequence
 horizontal-lineto:
 ( "H" | "h" ) wsp* horizontal-lineto-argument-sequence
 horizontal-lineto-argument-sequence:
 coordinate
 | coordinate comma-wsp? horizontal-lineto-argument-sequence
 vertical-lineto:
 ( "V" | "v" ) wsp* vertical-lineto-argument-sequence
 vertical-lineto-argument-sequence:
 coordinate
 | coordinate comma-wsp? vertical-lineto-argument-sequence
 curveto:
 ( "C" | "c" ) wsp* curveto-argument-sequence
 curveto-argument-sequence:
 curveto-argument
 | curveto-argument comma-wsp? curveto-argument-sequence
 curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair comma-wsp? coordinate-pair
 smooth-curveto:
 ( "S" | "s" ) wsp* smooth-curveto-argument-sequence
 smooth-curveto-argument-sequence:
 smooth-curveto-argument
 | smooth-curveto-argument comma-wsp? smooth-curveto-argument-sequence
 smooth-curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair
 quadratic-bezier-curveto:
 ( "Q" | "q" ) wsp* quadratic-bezier-curveto-argument-sequence
 quadratic-bezier-curveto-argument-sequence:
 quadratic-bezier-curveto-argument
 | quadratic-bezier-curveto-argument comma-wsp?
 quadratic-bezier-curveto-argument-sequence
 quadratic-bezier-curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair
 smooth-quadratic-bezier-curveto:
 ( "T" | "t" ) wsp* smooth-quadratic-bezier-curveto-argument-sequence
 smooth-quadratic-bezier-curveto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? smooth-quadratic-bezier-curveto-argument-sequence
 elliptical-arc:
 ( "A" | "a" ) wsp* elliptical-arc-argument-sequence
 elliptical-arc-argument-sequence:
 elliptical-arc-argument
 | elliptical-arc-argument comma-wsp? elliptical-arc-argument-sequence
 elliptical-arc-argument:
 nonnegative-number comma-wsp? nonnegative-number comma-wsp?
 number comma-wsp flag comma-wsp? flag comma-wsp? coordinate-pair
 coordinate-pair:
 coordinate comma-wsp? coordinate
 coordinate:
 number
 nonnegative-number:
 integer-constant
 | floating-point-constant
 number:
 sign? integer-constant
 | sign? floating-point-constant
 flag:
 "0" | "1"
 comma-wsp:
 (wsp+ comma? wsp*) | (comma wsp*)
 comma:
 ","
 integer-constant:
 digit-sequence
 floating-point-constant:
 fractional-constant exponent?
 | digit-sequence exponent
 fractional-constant:
 digit-sequence? "." digit-sequence
 | digit-sequence "."
 exponent:
 ( "e" | "E" ) sign? digit-sequence
 sign:
 "+" | "-"
 digit-sequence:
 digit
 | digit digit-sequence
 digit:
 "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
 */

/*
 http://www.w3.org/TR/2011/REC-SVG11-20110816/shapes.html#PointsBNF
 
 list-of-points:
 wsp* coordinate-pairs? wsp*
 coordinate-pairs:
 coordinate-pair
 | coordinate-pair comma-wsp coordinate-pairs
 coordinate-pair:
 coordinate comma-wsp coordinate
 | coordinate negative-coordinate
 coordinate:
 number
 number:
 sign? integer-constant
 | sign? floating-point-constant
 negative-coordinate:
 "-" integer-constant
 | "-" floating-point-constant
 comma-wsp:
 (wsp+ comma? wsp*) | (comma wsp*)
 comma:
 ","
 integer-constant:
 digit-sequence
 floating-point-constant:
 fractional-constant exponent?
 | digit-sequence exponent
 fractional-constant:
 digit-sequence? "." digit-sequence
 | digit-sequence "."
 exponent:
 ( "e" | "E" ) sign? digit-sequence
 sign:
 "+" | "-"
 digit-sequence:
 digit
 | digit digit-sequence
 digit:
 "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
 */
#import "CYLRefreshVectorPathsParser.h"

static inline CYLRefreshCurve CurveMakePoint(CGPoint p)
{
    CYLRefreshCurve curve;
    curve.type = CurveTypePoint;
    
    curve.c1 = p;
    curve.c2 = p;
    curve.p = p;

    return curve;
}

static inline CGPoint CurveReflectedControlPoint(CYLRefreshCurve prevCurve)
{
    return CGPointMake(prevCurve.p.x+(prevCurve.p.x-prevCurve.c2.x), prevCurve.p.y+(prevCurve.p.y-prevCurve.c2.y));
}


@implementation CYLRefreshVectorPathsParser

+ (CYLRefreshCurve) startingCurve
{
    return CurveMakePoint(CGPointZero);
}


/**
 wsp:
 (#x20 | #x9 | #xD | #xA)
 */
+ (void) readWhitespace:(NSScanner*)scanner
{
    
    /** This log message can be called literally hundreds of thousands of times in a single parse, which defeats
     even Cocoa Lumberjack.
     
     Even in "verbose" debugging, that's too much!
     
     Hence: commented-out
    SVGKitLogVerbose(@"Apple's implementation of scanCharactersFromSet seems to generate large amounts of temporary objects and can cause a crash here by taking literally megabytes of RAM in temporary internal variables. This is surprising, but I can't see anythign we're doing wrong. Adding this autoreleasepool drops memory usage (inside Apple's methods!) massively, so it seems to be the right thing to do");
     */
    @autoreleasepool
    {
        static NSCharacterSet *sWhitespaceCharacterSet = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sWhitespaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%c%c%c%c", 0x20, 0x9, 0xD, 0xA]];
             // required, this is a non-ARC project.
        });
        
        [scanner scanCharactersFromSet:sWhitespaceCharacterSet
                        intoString:NULL];
    }
}

+ (void) readCommaAndWhitespace:(NSScanner*)scanner
{
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    static NSString* comma = @",";
    [scanner scanString:comma intoString:NULL];
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
}

/**
 moveto-drawto-command-groups:
 moveto-drawto-command-group
 | moveto-drawto-command-group wsp* moveto-drawto-command-groups
 */
+ (CYLRefreshCurve) readMovetoDrawToCmdGroups:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
#if CYLREFRESH_VERBOSE_PARSE_SVG
    SVGKitLogVerbose(@"Parsing command string: move-to, draw-to command");
#endif
    CYLRefreshCurve lastCurve = [CYLRefreshVectorPathsParser readMovetoDrawto:scanner path:path relativeTo:origin isRelative:isRelative];
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    
    while (![scanner isAtEnd])
    {
        [CYLRefreshVectorPathsParser readWhitespace:scanner];
        /** FIXME: wasn't originally, but maybe should be:
         
         origin = isRelative ? lastCoord : origin;
         */
        lastCurve = [CYLRefreshVectorPathsParser readMovetoDrawto:scanner path:path relativeTo:origin isRelative:isRelative];
    }
    
    return lastCurve;
}

/** moveto-drawto-command-group:
 moveto wsp* drawto-commands?
 */
+ (CYLRefreshCurve) readMovetoDrawto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CYLRefreshCurve lastCurve = [CYLRefreshVectorPathsParser readMoveto:scanner path:path relativeTo:origin isRelative:isRelative];
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    return lastCurve;
}

/**
 moveto:
 ( "M" | "m" ) wsp* moveto-argument-sequence
 */
+ (CYLRefreshCurve) readMoveto:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Mm"];
    if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
    {
        NSAssert(FALSE, @"failed to scan move to command");
        return CurveMakePoint(origin);
    }
    
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    
    return [CYLRefreshVectorPathsParser readMovetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
}

/** moveto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? lineto-argument-sequence
 */
+ (CYLRefreshCurve) readMovetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CGPoint coord = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    coord.x += origin.x;
    coord.y += origin.y;
    
    CGPathMoveToPoint(path, NULL, coord.x, coord.y);
#if CYLREFRESH_DEBUG_PATH_CREATION
    SVGKitLogWarn(@"[%@] PATH: MOVED to %2.2f, %2.2f", [CYLRefreshVectorPathsParser class], coord.x, coord.y );
#endif
    
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    if ([scanner isAtEnd]) {
        return CurveMakePoint(coord);
    } else {
        return [CYLRefreshVectorPathsParser readLinetoArgumentSequence:scanner path:path relativeTo:(isRelative)?coord:origin isRelative:isRelative];
    }
}

/**
 coordinate-pair:
 coordinate comma-wsp? coordinate
 */

+ (CGPoint) readCoordinatePair:(NSScanner*)scanner
{
    CGPoint p;
    [CYLRefreshVectorPathsParser readCoordinate:scanner intoFloat:&p.x];
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    [CYLRefreshVectorPathsParser readCoordinate:scanner intoFloat:&p.y];
    
    return p;
}

+ (void) readCoordinate:(NSScanner*)scanner intoFloat:(CGFloat*) floatPointer
{
#if CGFLOAT_IS_DOUBLE
    if( ![scanner scanDouble:floatPointer])
        NSAssert(FALSE, @"invalid coord");
#else
    if( ![scanner scanFloat:floatPointer])
        NSAssert(FALSE, @"invalid coord");
#endif
}

/**
 lineto:
 ( "L" | "l" ) wsp* lineto-argument-sequence
 */
+ (CYLRefreshCurve) readLineToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
#if CYLREFRESH_VERBOSE_PARSE_SVG
    SVGKitLogVerbose(@"Parsing command string: line-to command");
#endif
    
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Ll"];
    
    if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
    {
        NSAssert( FALSE, @"failed to scan line to command");
        return CurveMakePoint(origin);
    }
    
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    
    return [CYLRefreshVectorPathsParser readLinetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
}

/**
 lineto-argument-sequence:
 coordinate-pair
 | coordinate-pair comma-wsp? lineto-argument-sequence
 */
+ (CYLRefreshCurve) readLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CGPoint p = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    CGPoint coord = CGPointMake(p.x+origin.x, p.y+origin.y);
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if CYLREFRESH_DEBUG_PATH_CREATION
    SVGKitLogWarn(@"[%@] PATH: LINE to %2.2f, %2.2f", [CYLRefreshVectorPathsParser class], coord.x, coord.y );
#endif
    
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    while( ![scanner isAtEnd])
    {
        origin = (isRelative)?coord:origin;
        p = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
        coord = CGPointMake(p.x+origin.x, p.y+origin.y);
        CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if CYLREFRESH_DEBUG_PATH_CREATION
        SVGKitLogWarn(@"[%@] PATH: LINE to %2.2f, %2.2f", [CYLRefreshVectorPathsParser class], coord.x, coord.y );
#endif
        
        [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    }
    
    return CurveMakePoint(coord);
}

/**
 quadratic-bezier-curveto:
 ( "Q" | "q" ) wsp* quadratic-bezier-curveto-argument-sequence
 */
+ (CYLRefreshCurve) readQuadraticCurveToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
#if CYLREFRESH_VERBOSE_PARSE_SVG
    SVGKitLogVerbose(@"Parsing command string: quadratic-bezier-curve-to command");
#endif
    
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Qq"];
    
    if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
    {
        NSAssert( FALSE, @"failed to scan quadratic curve to command");
        return CurveMakePoint(origin);
    }
    
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    
    return [CYLRefreshVectorPathsParser readQuadraticCurvetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
}
/**
 quadratic-bezier-curveto-argument-sequence:
 quadratic-bezier-curveto-argument
 | quadratic-bezier-curveto-argument comma-wsp? quadratic-bezier-curveto-argument-sequence
 */
+ (CYLRefreshCurve) readQuadraticCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CYLRefreshCurve curve = [CYLRefreshVectorPathsParser readQuadraticCurvetoArgument:scanner path:path relativeTo:origin];
    
    while(![scanner isAtEnd])
    {
        curve = [CYLRefreshVectorPathsParser readQuadraticCurvetoArgument:scanner path:path relativeTo:(isRelative ? curve.p : origin)];
    }
    
    return curve;
}

/**
 quadratic-bezier-curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair
 */
+ (CYLRefreshCurve) readQuadraticCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CYLRefreshCurve curveResult;
    curveResult.type = CurveTypeQuadratic;
    
    curveResult.c1 = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    curveResult.c1.x += origin.x;
    curveResult.c1.y += origin.y;
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    curveResult.c2 = curveResult.c1;
    
    curveResult.p = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    curveResult.p.x += origin.x;
    curveResult.p.y += origin.y;
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    CGPathAddQuadCurveToPoint(path, NULL, curveResult.c1.x, curveResult.c1.y, curveResult.p.x, curveResult.p.y);
#if CYLREFRESH_DEBUG_PATH_CREATION
    SVGKitLogWarn(@"[%@] PATH: QUADRATIC CURVE to (%2.2f, %2.2f)..(%2.2f, %2.2f)", [CYLRefreshVectorPathsParser class], curveResult.c1.x, curveResult.c1.y, curveResult.p.x, curveResult.p.y);
#endif
    
    return curveResult;
}

/**
 smooth-quadratic-bezier-curveto:
 ( "T" | "t" ) wsp* smooth-quadratic-bezier-curveto-argument-sequence
 */
+ (CYLRefreshCurve) readSmoothQuadraticCurveToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve
{
#if CYLREFRESH_VERBOSE_PARSE_SVG
    SVGKitLogVerbose(@"Parsing command string: smooth-quadratic-bezier-curve-to command");
#endif
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Tt"];
    
    if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
    {
        NSAssert( FALSE, @"failed to scan smooth quadratic curve to command");
        return prevCurve;
    }
    
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    
    return [CYLRefreshVectorPathsParser readSmoothQuadraticCurvetoArgumentSequence:scanner path:path relativeTo:origin withPrevCurve:prevCurve];
}


/**
 smooth-quadratic-bezier-curveto-argument-sequence:
 smooth-quadratic-bezier-curveto-argument
 | smooth-quadratic-bezier-curveto-argument comma-wsp? smooth-quadratic-bezier-curveto-argument-sequence
 */
+ (CYLRefreshCurve) readSmoothQuadraticCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve
{
    CYLRefreshCurve curve = [CYLRefreshVectorPathsParser readSmoothQuadraticCurvetoArgument:scanner path:path relativeTo:origin withPrevCurve:prevCurve];
    
    if (![scanner isAtEnd]) {
        curve = [CYLRefreshVectorPathsParser readSmoothQuadraticCurvetoArgumentSequence:scanner path:path relativeTo:curve.p withPrevCurve:curve];
    }
    
    return curve;
}

/**
 smooth-quadratic-bezier-curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair
 */
+ (CYLRefreshCurve) readSmoothQuadraticCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve
{
    CYLRefreshCurve thisCurve;
    thisCurve.type = CurveTypeQuadratic;
    
    thisCurve.c2 = (prevCurve.type == thisCurve.type) ? CurveReflectedControlPoint(prevCurve) : prevCurve.p;
    
    thisCurve.c1 = thisCurve.c2;    // this coordinate is never used, but c2 is better/safer than CGPointZero
    
    thisCurve.p = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    thisCurve.p.x += origin.x;
    thisCurve.p.y += origin.y;
    
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    CGPathAddQuadCurveToPoint(path, NULL, thisCurve.c2.x, thisCurve.c2.y, thisCurve.p.x, thisCurve.p.y );
#if CYLREFRESH_DEBUG_PATH_CREATION
    SVGKitLogWarn(@"[%@] PATH: SMOOTH QUADRATIC CURVE to (%2.2f, %2.2f)..(%2.2f, %2.2f)", [CYLRefreshVectorPathsParser class], thisCurve.c1.x, thisCurve.c1.y, thisCurve.p.x, thisCurve.p.y );
#endif
    
    return thisCurve;
}

/**
 curveto:
 ( "C" | "c" ) wsp* curveto-argument-sequence
 */
+ (CYLRefreshCurve) readCurveToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
#if CYLREFRESH_VERBOSE_PARSE_SVG
    SVGKitLogVerbose(@"Parsing command string: curve-to command");
#endif
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Cc"];
    
    if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd])
    {
        NSAssert( FALSE, @"failed to scan curve to command");
        return CurveMakePoint(origin);
    }
    
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    
    return [CYLRefreshVectorPathsParser readCurvetoArgumentSequence:scanner path:path relativeTo:origin isRelative:isRelative];
}

/**
 curveto-argument-sequence:
 curveto-argument
 | curveto-argument comma-wsp? curveto-argument-sequence
 */
+ (CYLRefreshCurve) readCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    CYLRefreshCurve curve = [CYLRefreshVectorPathsParser readCurvetoArgument:scanner path:path relativeTo:origin];
    
    while( ![scanner isAtEnd])
    {
        CGPoint newOrigin = isRelative ? curve.p : origin;
        
        curve = [CYLRefreshVectorPathsParser readCurvetoArgument:scanner path:path relativeTo:newOrigin];
    }
    
    return curve;
}

/**
 curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair comma-wsp? coordinate-pair
 */
+ (CYLRefreshCurve) readCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    CYLRefreshCurve curveResult;
    curveResult.type = CurveTypeCubic;
    
    curveResult.c1 = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    curveResult.c1.x += origin.x; // avoid allocating a new struct, an allocation here could happen MILLIONS of times in a large parse!
    curveResult.c1.y += origin.y;
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    curveResult.c2 = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    curveResult.c2.x += origin.x; // avoid allocating a new struct, an allocation here could happen MILLIONS of times in a large parse!
    curveResult.c2.y += origin.y;
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    curveResult.p = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    curveResult.p.x += origin.x; // avoid allocating a new struct, an allocation here could happen MILLIONS of times in a large parse!
    curveResult.p.y += origin.y;
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    CGPathAddCurveToPoint(path, NULL, curveResult.c1.x, curveResult.c1.y, curveResult.c2.x, curveResult.c2.y, curveResult.p.x, curveResult.p.y);
#if CYLREFRESH_DEBUG_PATH_CREATION
    SVGKitLogWarn(@"[%@] PATH: CURVE to (%2.2f, %2.2f)..(%2.2f, %2.2f)..(%2.2f, %2.2f)", [CYLRefreshVectorPathsParser class], curveResult.c1.x, curveResult.c1.y, curveResult.c2.x, curveResult.c2.y, curveResult.p.x, curveResult.p.y);
#endif
    
    return curveResult;
}

/**
 smooth-curveto:
 ( "S" | "s" ) wsp* smooth-curveto-argument-sequence
 */
+ (CYLRefreshCurve) readSmoothCurveToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve isRelative:(BOOL) isRelative
{
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Ss"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan smooth curve to command");
    if (!ok) return prevCurve;
    
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    
    return [CYLRefreshVectorPathsParser readSmoothCurvetoArgumentSequence:scanner path:path relativeTo:origin withPrevCurve:prevCurve isRelative:isRelative];
}

/**
 smooth-curveto-argument-sequence:
 smooth-curveto-argument
 | smooth-curveto-argument comma-wsp? smooth-curveto-argument-sequence
 */
+ (CYLRefreshCurve) readSmoothCurvetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve isRelative:(BOOL) isRelative
{
    CYLRefreshCurve curve = [CYLRefreshVectorPathsParser readSmoothCurvetoArgument:scanner path:path relativeTo:origin withPrevCurve:prevCurve];
    
    if (![scanner isAtEnd]) {
        CGPoint newOrigin = isRelative ? curve.p : origin;
        curve = [CYLRefreshVectorPathsParser readSmoothCurvetoArgumentSequence:scanner path:path relativeTo:newOrigin withPrevCurve:curve isRelative: isRelative];
    }
    
    return curve;
}

/**
 smooth-curveto-argument:
 coordinate-pair comma-wsp? coordinate-pair
 */
+ (CYLRefreshCurve) readSmoothCurvetoArgument:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin withPrevCurve:(CYLRefreshCurve)prevCurve
{
    CYLRefreshCurve thisCurve;
    thisCurve.type = CurveTypeCubic;
    
    thisCurve.c1 = (prevCurve.type == thisCurve.type) ? CurveReflectedControlPoint(prevCurve) : prevCurve.p;
    
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    thisCurve.c2 = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    thisCurve.c2.x += origin.x;
    thisCurve.c2.y += origin.y;
    
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    thisCurve.p = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    thisCurve.p.x += origin.x;
    thisCurve.p.y += origin.y;
    
    CGPathAddCurveToPoint(path, NULL, thisCurve.c1.x, thisCurve.c1.y, thisCurve.c2.x, thisCurve.c2.y, thisCurve.p.x, thisCurve.p.y);
#if CYLREFRESH_DEBUG_PATH_CREATION
    SVGKitLogWarn(@"[%@] PATH: SMOOTH CURVE to (%2.2f, %2.2f)..(%2.2f, %2.2f)..(%2.2f, %2.2f)", [CYLRefreshVectorPathsParser class], thisCurve.c1.x, thisCurve.c1.y, thisCurve.c2.x, thisCurve.c2.y, thisCurve.p.x, thisCurve.p.y );
#endif
    
    return thisCurve;
}

/**
 vertical-lineto-argument-sequence:
 coordinate
 | coordinate comma-wsp? vertical-lineto-argument-sequence
 */
+ (CYLRefreshCurve) readVerticalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    // FIXME: reduce the allocations here; make one CGPoint and update it, not multiple
    CGFloat yValue;
    [CYLRefreshVectorPathsParser readCoordinate:scanner intoFloat:&yValue];
    CGPoint vertCoord = CGPointMake(origin.x, origin.y+yValue);
    CGPoint currentPoint = CGPathGetCurrentPoint(path);
    CGPoint coord = CGPointMake(currentPoint.x, currentPoint.y+(vertCoord.y-currentPoint.y));
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if CYLREFRESH_DEBUG_PATH_CREATION
    SVGKitLogWarn(@"[%@] PATH: VERTICAL LINE to (%2.2f, %2.2f)", [CYLRefreshVectorPathsParser class], coord.x, coord.y );
#endif
    return CurveMakePoint(coord);
}

/**
 vertical-lineto:
 ( "V" | "v" ) wsp* vertical-lineto-argument-sequence
 */
+ (CYLRefreshCurve) readVerticalLineToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
#if CYLREFRESH_VERBOSE_PARSE_SVG
    SVGKitLogVerbose(@"Parsing command string: vertical-line-to command");
#endif
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Vv"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:&cmd];
    
    NSAssert(ok, @"failed to scan vertical line to command");
    if (!ok) return CurveMakePoint(origin);
    
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    
    return [CYLRefreshVectorPathsParser readVerticalLinetoArgumentSequence:scanner path:path relativeTo:origin];
}

/**
 horizontal-lineto-argument-sequence:
 coordinate
 | coordinate comma-wsp? horizontal-lineto-argument-sequence
 */
+ (CYLRefreshCurve) readHorizontalLinetoArgumentSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    // FIXME: reduce the allocations here; make one CGPoint and update it, not multiple
    
    CGFloat xValue;
    [CYLRefreshVectorPathsParser readCoordinate:scanner intoFloat:&xValue];
    CGPoint horizCoord = CGPointMake(origin.x+xValue, origin.y);
    CGPoint currentPoint = CGPathGetCurrentPoint(path);
    CGPoint coord = CGPointMake(currentPoint.x+(horizCoord.x-currentPoint.x), currentPoint.y);
    CGPathAddLineToPoint(path, NULL, coord.x, coord.y);
#if CYLREFRESH_DEBUG_PATH_CREATION
    SVGKitLogWarn(@"[%@] PATH: HORIZONTAL LINE to (%2.2f, %2.2f)", [CYLRefreshVectorPathsParser class], coord.x, coord.y );
#endif
    return CurveMakePoint(coord);
}

/**
 horizontal-lineto:
 ( "H" | "h" ) wsp* horizontal-lineto-argument-sequence
 */
+ (CYLRefreshCurve) readHorizontalLineToCmd:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
#if CYLREFRESH_VERBOSE_PARSE_SVG
    SVGKitLogVerbose(@"Parsing command string: horizontal-line-to command");
#endif
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Hh"];
    
    if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
    {
        NSAssert( FALSE, @"failed to scan horizontal line to command");
        return CurveMakePoint(origin);
    }
    
    [CYLRefreshVectorPathsParser readWhitespace:scanner];
    
    return [CYLRefreshVectorPathsParser readHorizontalLinetoArgumentSequence:scanner path:path relativeTo:origin];
}

+ (CYLRefreshCurve) readCloseCommand:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
#if CYLREFRESH_VERBOSE_PARSE_SVG
    SVGKitLogVerbose(@"Parsing command string: close command");
#endif
    NSString* cmd = nil;
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Zz"];
    
    if( ! [scanner scanCharactersFromSet:cmdFormat intoString:&cmd] )
    {
        NSAssert( FALSE, @"failed to scan close command");
        return CurveMakePoint(origin);
    }
    
    CGPathCloseSubpath(path);
#if CYLREFRESH_DEBUG_PATH_CREATION
    SVGKitLogWarn(@"[%@] PATH: finished path", [CYLRefreshVectorPathsParser class] );
#endif

    return CurveMakePoint(CGPathGetCurrentPoint(path));
}

+ (CYLRefreshCurve) readEllipticalArcArguments:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin isRelative:(BOOL) isRelative
{
    NSCharacterSet* cmdFormat = [NSCharacterSet characterSetWithCharactersInString:@"Aa"];
    BOOL ok = [scanner scanCharactersFromSet:cmdFormat intoString:nil];
    
    NSAssert(ok, @"failed to scan arc to command");
    if (!ok) return CurveMakePoint(origin);
    
    CGPoint endPoint = [CYLRefreshVectorPathsParser readEllipticalArcArgumentsSequence:scanner path:path relativeTo:origin];
    
    while (![scanner isAtEnd]) {
        CGPoint newOrigin = isRelative ? endPoint : origin;
        endPoint = [CYLRefreshVectorPathsParser readEllipticalArcArgumentsSequence:scanner path:path relativeTo:newOrigin];
    }
    
    return CurveMakePoint(endPoint);
}

+ (CGPoint)readEllipticalArcArgumentsSequence:(NSScanner*)scanner path:(CGMutablePathRef)path relativeTo:(CGPoint)origin
{
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    // need to find the center point of the ellipse from the two points and an angle
    // see http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes for these calculations
    
    CGPoint currentPt = CGPathGetCurrentPoint(path);
    
    CGFloat x1 = currentPt.x;
    CGFloat y1 = currentPt.y;
    
    CGPoint radii = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    CGFloat rx = fabs(radii.x);
    CGFloat ry = fabs(radii.y);
    
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    CGFloat phi;
    
    [CYLRefreshVectorPathsParser readCoordinate:scanner intoFloat:&phi];
    
    phi *= M_PI/180.;
    
    phi = fmod(phi, 2 * M_PI);
    
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    CGPoint flags = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];
    
    BOOL largeArcFlag = flags.x != 0.;
    BOOL sweepFlag = flags.y != 0.;
    
    [CYLRefreshVectorPathsParser readCommaAndWhitespace:scanner];
    
    CGPoint endPoint = [CYLRefreshVectorPathsParser readCoordinatePair:scanner];

    // end parsing

    CGFloat x2 = origin.x + endPoint.x;
    CGFloat y2 = origin.y + endPoint.y;

    if (rx == 0 || ry == 0)
    {
        CGPathAddLineToPoint(path, NULL, x2, y2);
        return CGPointMake(x2, y2);
    }
    CGFloat cosPhi = cos(phi);
    CGFloat sinPhi = sin(phi);
    
    CGFloat    x1p = cosPhi * (x1-x2)/2. + sinPhi * (y1-y2)/2.;
    CGFloat    y1p = -sinPhi * (x1-x2)/2. + cosPhi * (y1-y2)/2.;
    
    CGFloat lhs;
    {
        CGFloat rx_2 = rx * rx;
        CGFloat ry_2 = ry * ry;
        CGFloat xp_2 = x1p * x1p;
        CGFloat yp_2 = y1p * y1p;

        CGFloat delta = xp_2/rx_2 + yp_2/ry_2;
        
        if (delta > 1.0)
        {
            rx *= sqrt(delta);
            ry *= sqrt(delta);
            rx_2 = rx * rx;
            ry_2 = ry * ry;
        }
        CGFloat sign = (largeArcFlag == sweepFlag) ? -1 : 1;
        CGFloat numerator = rx_2 * ry_2 - rx_2 * yp_2 - ry_2 * xp_2;
        CGFloat denom = rx_2 * yp_2 + ry_2 * xp_2;
        
        numerator = MAX(0, numerator);
        
        if (denom == 0) {
            lhs = 0;
         }else {
             lhs = sign * sqrt(numerator/denom);
         }
    }
    
    CGFloat cxp = lhs * (rx*y1p)/ry;
    CGFloat cyp = lhs * -((ry * x1p)/rx);
    
    CGFloat cx = cosPhi * cxp + -sinPhi * cyp + (x1+x2)/2.;
    CGFloat cy = cxp * sinPhi + cyp * cosPhi + (y1+y2)/2.;
    
    // transform our ellipse into the unit circle

    CGAffineTransform tr = CGAffineTransformMakeScale(1./rx, 1./ry);

    tr = CGAffineTransformRotate(tr, -phi);
    tr = CGAffineTransformTranslate(tr, -cx, -cy);
    
    CGPoint arcPt1 = CGPointApplyAffineTransform(CGPointMake(x1, y1), tr);
    CGPoint arcPt2 = CGPointApplyAffineTransform(CGPointMake(x2, y2), tr);
        
    CGFloat startAngle = atan2(arcPt1.y, arcPt1.x);
    CGFloat endAngle = atan2(arcPt2.y, arcPt2.x);
    
    CGFloat angleDelta = endAngle - startAngle;;
    
    if (sweepFlag)
    {
        if (angleDelta < 0)
            angleDelta += 2. * M_PI;
    }
    else
    {
        if (angleDelta > 0)
            angleDelta = angleDelta - 2 * M_PI;
    }
    // construct the inverse transform
    CGAffineTransform trInv = CGAffineTransformMakeTranslation( cx, cy);
    
    trInv = CGAffineTransformRotate(trInv, phi);
    trInv = CGAffineTransformScale(trInv, rx, ry);

    // add a inversely transformed circular arc to the current path
    CGPathAddRelativeArc( path, &trInv, 0, 0, 1., startAngle, angleDelta);
    
    return CGPointMake(x2, y2);
}

@end
