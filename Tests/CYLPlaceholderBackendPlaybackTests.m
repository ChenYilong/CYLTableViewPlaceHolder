#import <XCTest/XCTest.h>
#import <libpag/PAGView.h>
#import <CYLTableViewPlaceHolder/CYLPlaceholderView.h>

@interface UIView (CYLPlaceholderRiveProbes)
- (void)cyl_readBoolean:(NSString *)path completion:(void (^)(NSNumber *))completion;
- (void)cyl_readColor:(NSString *)path completion:(void (^)(UIColor *))completion;
- (void)cyl_observeTrigger:(NSString *)path onFire:(void (^)(void))onFire;
@end

/// Upper bound for asynchronous loads: CI simulators can compile Metal shaders for seconds before the first Rive or PAG frame.
static const NSTimeInterval CYLTestTimeout = 30;
/// The first data-bound Rive load also compiles Metal shaders: on CI's paravirtualized GPU that took about 45 s
/// (run 42845968876: the "Metal Compiler" log line came just after a 30 s wait expired; the next test loaded in 7 s).
static const NSTimeInterval CYLRiveFirstLoadTimeout = 120;

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
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
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
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
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
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
    [placeholder removeFromSuperview];
}

/// Loads data_binding_test.riv (rive-ios tests, MIT) and waits until the Rive view has its view model instance.
- (UIView *)bindingRiveViewInPlaceholder:(CYLPlaceholderView **)placeholderOut window:(UIWindow *)window
                                 options:(NSDictionary *)options extra:(NSDictionary *)extra {
    NSMutableDictionary *attributes = [@{
        CYLPlaceholderItemRiveURL: [self fixture:@"data_binding_test" extension:@"riv"],
        CYLPlaceholderItemRiveSize: @[@80, @80], CYLPlaceholderItemAnimationOptions: options
    } mutableCopy];
    [attributes addEntriesFromDictionary:extra ?: @{}];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:attributes imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder, @"%@", error);
    UIView *backend = [placeholder valueForKey:@"backendView"];
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return [[backend valueForKey:@"ready"] boolValue];
    }] evaluatedWithObject:backend handler:nil];
    [self waitForExpectationsWithTimeout:CYLRiveFirstLoadTimeout handler:nil];
    *placeholderOut = placeholder;
    (void)window;
    return backend.subviews.firstObject;
}

- (NSNumber *)readBoolean:(NSString *)path from:(UIView *)rive {
    __block NSNumber *result = nil;
    XCTestExpectation *read = [self expectationWithDescription:path];
    [(id)rive cyl_readBoolean:path completion:^(NSNumber *value) { result = value; [read fulfill]; }];
    [self waitForExpectations:@[read] timeout:CYLTestTimeout];
    return result;
}

- (UIColor *)readColor:(NSString *)path from:(UIView *)rive {
    __block UIColor *result = nil;
    XCTestExpectation *read = [self expectationWithDescription:path];
    [(id)rive cyl_readColor:path completion:^(UIColor *value) { result = value; [read fulfill]; }];
    [self waitForExpectations:@[read] timeout:CYLTestTimeout];
    return result;
}

- (void)testRiveDataBindingBooleanFollowsPlayback {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    CYLPlaceholderView *placeholder = nil;
    UIView *rive = [self bindingRiveViewInPlaceholder:&placeholder window:window
                                              options:@{@"active": @"Boolean", @"duration": @"0"} extra:nil];
    XCTAssertEqualObjects([self readBoolean:@"Boolean" from:rive], @NO);
    [window addSubview:placeholder]; // entering a window plays
    [placeholder playPlaceholderAnimation];
    XCTAssertEqualObjects([self readBoolean:@"Boolean" from:rive], @YES);
    XCTAssertFalse([[rive valueForKey:@"cyl_isPaused"] boolValue]);
    [placeholder stopPlaceholderAnimation];
    XCTAssertEqualObjects([self readBoolean:@"Boolean" from:rive], @NO);
    XCTAssertTrue([[rive valueForKey:@"cyl_isPaused"] boolValue]);
    [placeholder removeFromSuperview];
}

- (void)testRiveDataBindingTriggerFiresOnPlay {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    CYLPlaceholderView *placeholder = nil;
    UIView *rive = [self bindingRiveViewInPlaceholder:&placeholder window:window
                                              options:@{@"trigger": @"Trigger Red"} extra:nil];
    __block NSInteger fires = 0;
    [(id)rive cyl_observeTrigger:@"Trigger Red" onFire:^{ fires++; }];
    [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    [window addSubview:placeholder];
    [placeholder playPlaceholderAnimation];
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return fires >= 1;
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
    [placeholder removeFromSuperview];
}

- (void)testRiveDataBindingColorOverrideAndRestore {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    CYLPlaceholderView *placeholder = nil;
    UIView *rive = [self bindingRiveViewInPlaceholder:&placeholder window:window options:@{}
        extra:@{CYLPlaceholderItemRiveDarkColors: @{@"Color": UIColor.blueColor}}];
    UIColor *original = [self readColor:@"Color" from:rive];
    XCTAssertNotNil(original);
    [window addSubview:placeholder];
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    // The dark swap rebuilds the backend; wait for the new Rive view to apply blue.
    __block UIView *darkRive = nil;
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        UIView *backend = [placeholder valueForKey:@"backendView"];
        darkRive = backend.subviews.firstObject;
        return darkRive != rive && [[backend valueForKey:@"ready"] boolValue];
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
    UIColor *dark = [self readColor:@"Color" from:darkRive];
    CGFloat r = 0, g = 0, b = 0, a = 0;
    XCTAssertTrue([dark getRed:&r green:&g blue:&b alpha:&a]);
    XCTAssertEqualWithAccuracy(b, 1, 0.01);
    XCTAssertEqualWithAccuracy(r, 0, 0.01);
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    __block UIView *lightRive = nil;
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        UIView *backend = [placeholder valueForKey:@"backendView"];
        lightRive = backend.subviews.firstObject;
        return lightRive != darkRive && [[backend valueForKey:@"ready"] boolValue];
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
    XCTAssertEqualObjects([self readColor:@"Color" from:lightRive], original);
    [placeholder removeFromSuperview];
}

@end


