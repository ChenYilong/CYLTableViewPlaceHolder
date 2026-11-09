#import <XCTest/XCTest.h>
#import <libpag/PAGView.h>
#import <CYLTableViewPlaceHolder/CYLPlaceholderView.h>

@interface CYLPlaceholderBackendPlaybackTests : XCTestCase
@end

@implementation CYLPlaceholderBackendPlaybackTests

- (UIImage *)fallbackImage {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(20, 20)];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [UIColor.blueColor setFill];
        UIRectFill(CGRectMake(0, 0, 20, 20));
    }];
}

- (NSURL *)fixture:(NSString *)name extension:(NSString *)extension {
    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:name withExtension:extension];
    XCTAssertNotNil(url);
    return url;
}

- (void)testPAGLoadsAndAdvances {
    NSURL *url = [self fixture:@"tab_home" extension:@"pag"];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemPAGURL: url, CYLPlaceholderItemPAGSize: @[@80, @80]
    } imageBundle:nil error:&error];
    UIView *backend = [placeholder valueForKey:@"backendView"];
    XCTAssertNotNil(backend);
    PAGView *pag = (PAGView *)backend.subviews.firstObject;
    XCTAssertTrue([pag isKindOfClass:PAGView.class]);
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    if (!UIAccessibilityIsReduceMotionEnabled()) {
        XCTestExpectation *elapsed = [self expectationWithDescription:@"PAG advances"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{ [elapsed fulfill]; });
        [self waitForExpectations:@[elapsed] timeout:3];
        XCTAssertGreaterThan([pag getProgress], 0);
        [placeholder stopPlaceholderAnimation];
        XCTAssertEqualWithAccuracy([pag getProgress], 0, 0.01);
        [placeholder showPlaceholderAnimationLastFrame];
        XCTAssertEqualWithAccuracy([pag getProgress], 1, 0.01);
        XCTAssertTrue([placeholder setPlaceholderAnimationProgress:0.5]);
        double seekFrame = [pag getProgress];
        XCTAssertEqualWithAccuracy(seekFrame, 0.5, 0.02);
        [placeholder removeFromSuperview];
        [window addSubview:placeholder];
        XCTAssertEqualWithAccuracy([pag getProgress], seekFrame, 0.001);
        XCTAssertFalse([placeholder setPlaceholderAnimationSpeed:2]);
        [placeholder playPlaceholderAnimation];
    }
    [placeholder removeFromSuperview];
    XCTAssertFalse([[backend valueForKey:@"playing"] boolValue]);
}

- (void)testRiveLoadsAndStopsOffscreen {
    NSURL *url = [self fixture:@"icons" extension:@"riv"];
    NSError *error = nil;
    UIImage *image = [self fallbackImage];
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemRiveURL: url, CYLPlaceholderItemRiveSize: @[@80, @80],
        CYLPlaceholderItemImage: image,
        CYLPlaceholderItemAnimationOptions: @{@"artboard": @"CHAT", @"stateMachine": @"CHAT_Interactivity"}
    } imageBundle:nil error:&error];
    UIView *backend = [placeholder valueForKey:@"backendView"];
    XCTAssertNotNil(backend);
    XCTAssertFalse(placeholder.imageView.layer.hidden);
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    NSPredicate *ready = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return [[backend valueForKey:@"ready"] boolValue];
    }];
    [self expectationForPredicate:ready evaluatedWithObject:backend handler:nil];
    [self waitForExpectationsWithTimeout:10 handler:nil];
    XCTAssertTrue(placeholder.imageView.layer.hidden);
    UIView *rive = backend.subviews.firstObject;
    if (!UIAccessibilityIsReduceMotionEnabled()) {
        XCTAssertFalse([[rive valueForKey:@"cyl_isPaused"] boolValue]);
    }
    [placeholder removeFromSuperview];
    XCTAssertTrue([[rive valueForKey:@"cyl_isPaused"] boolValue]);
}

- (void)testInvalidRiveRestoresStaticImage {
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:
        [NSString stringWithFormat:@"CYLInvalid-%@.riv", NSUUID.UUID.UUIDString]]];
    NSError *error = nil;
    XCTAssertTrue([[@"invalid rive" dataUsingEncoding:NSUTF8StringEncoding] writeToURL:url options:0 error:&error]);
    UIImage *image = [self fallbackImage];
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemRiveURL: url, CYLPlaceholderItemImage: image
    } imageBundle:nil error:&error];
    NSPredicate *failed = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return [placeholder valueForKey:@"backendView"] == nil;
    }];
    [self expectationForPredicate:failed evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:10 handler:nil];
    XCTAssertFalse(placeholder.imageView.layer.hidden);
    XCTAssertEqual(placeholder.imageView.image, image);
    XCTAssertTrue([[NSFileManager defaultManager] removeItemAtURL:url error:&error]);
}

- (void)testRiveLegacyInputPlaysAndStops {
    NSURL *url = [self fixture:@"icons" extension:@"riv"];
    UIImage *image = [self fallbackImage];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemRiveURL: url, CYLPlaceholderItemImage: image,
        CYLPlaceholderItemAnimationOptions: @{@"artboard": @"CHAT", @"stateMachine": @"CHAT_Interactivity",
                                               @"input": @"active", @"duration": @"0"}
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    UIView *backend = [placeholder valueForKey:@"backendView"];
    XCTAssertNotNil(backend);
    UIView *rive = backend.subviews.firstObject;
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    if (!UIAccessibilityIsReduceMotionEnabled()) {
        XCTAssertTrue([[rive valueForKey:@"cyl_inputActive"] boolValue]);
        XCTAssertTrue([[rive valueForKey:@"cyl_isPlaying"] boolValue]);
    }
    [placeholder removeFromSuperview];
    XCTAssertFalse([[rive valueForKey:@"cyl_inputActive"] boolValue]);
    XCTAssertFalse([[rive valueForKey:@"cyl_isPlaying"] boolValue]);
}

- (void)testRiveMissingLegacyInputPreservesFallback {
    NSURL *url = [self fixture:@"icons" extension:@"riv"];
    UIImage *image = [self fallbackImage];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemRiveURL: url, CYLPlaceholderItemImage: image,
        CYLPlaceholderItemAnimationOptions: @{@"artboard": @"CHAT", @"stateMachine": @"CHAT_Interactivity",
                                               @"input": @"missing-input"}
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    XCTAssertNil([placeholder valueForKey:@"backendView"]);
    XCTAssertFalse(placeholder.imageView.layer.hidden);
}

- (void)testRiveLegacyTriggerStartsAndPauses {
    NSURL *url = [self fixture:@"check" extension:@"riv"];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemRiveURL: url, CYLPlaceholderItemImage: [self fallbackImage],
        CYLPlaceholderItemAnimationOptions: @{@"stateMachine": @"State Machine 1", @"triggerInput": @"Check"}
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    UIView *backend = [placeholder valueForKey:@"backendView"];
    XCTAssertNotNil(backend);
    UIView *rive = backend.subviews.firstObject;
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    if (!UIAccessibilityIsReduceMotionEnabled()) XCTAssertTrue([[rive valueForKey:@"cyl_isPlaying"] boolValue]);
    [placeholder removeFromSuperview];
    XCTAssertFalse([[rive valueForKey:@"cyl_isPlaying"] boolValue]);
}

- (void)testRiveLegacyLinearAnimationStartsAndStops {
    NSURL *url = [self fixture:@"button" extension:@"riv"];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemRiveURL: url, CYLPlaceholderItemImage: [self fallbackImage],
        CYLPlaceholderItemAnimationOptions: @{@"animation": @"active"}
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    UIView *backend = [placeholder valueForKey:@"backendView"];
    XCTAssertNotNil(backend);
    UIView *rive = backend.subviews.firstObject;
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    if (!UIAccessibilityIsReduceMotionEnabled()) XCTAssertTrue([[rive valueForKey:@"cyl_isPlaying"] boolValue]);
    [placeholder stopPlaceholderAnimation];
    XCTAssertFalse([[rive valueForKey:@"cyl_isPlaying"] boolValue]);
    [placeholder removeFromSuperview];
}
- (void)testRiveColorOverridesFollowAppearance {
    NSURL *url = [self fixture:@"icons" extension:@"riv"];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemRiveURL: url, CYLPlaceholderItemRiveSize: @[@80, @80],
        CYLPlaceholderItemAnimationOptions: @{@"artboard": @"CHAT", @"stateMachine": @"CHAT_Interactivity"},
        CYLPlaceholderItemAnimationColors: @{@"color": UIColor.redColor},
        CYLPlaceholderItemRiveDarkColors: @{@"color": UIColor.blueColor}
    } imageBundle:nil error:&error];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    [window addSubview:placeholder];
    UIView *rive = [[placeholder valueForKey:@"backendView"] subviews].firstObject;
    UIColor *light = [rive valueForKey:@"cyl_requestedColors"][@"color"];
    CGFloat r = 0, g = 0, b = 0, a = 0;
    XCTAssertTrue([light getRed:&r green:&g blue:&b alpha:&a]);
    XCTAssertEqualWithAccuracy(r, 1, 0.02);
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        UIView *current = [[placeholder valueForKey:@"backendView"] subviews].firstObject;
        UIColor *color = [current valueForKey:@"cyl_requestedColors"][@"color"];
        CGFloat red, green, blue, alpha;
        return [color getRed:&red green:&green blue:&blue alpha:&alpha] && blue > 0.98;
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    [placeholder removeFromSuperview];
}

@end

