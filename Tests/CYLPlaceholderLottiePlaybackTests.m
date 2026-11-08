#import <XCTest/XCTest.h>
#import <CYLTableViewPlaceHolder/CYLPlaceholderView.h>

@interface CYLPlaceholderLottiePlaybackTests : XCTestCase
@end

@implementation CYLPlaceholderLottiePlaybackTests

- (void)testLottieColorOverridesFollowAppearance {
    NSString *json = @"{\"v\":\"5.7.4\",\"fr\":30,\"ip\":0,\"op\":30,\"w\":80,\"h\":80,\"nm\":\"Test\","
        "\"ddd\":0,\"assets\":[],\"layers\":[{\"ddd\":0,\"ind\":1,\"ty\":4,\"nm\":\"Shape\","
        "\"ks\":{\"o\":{\"a\":0,\"k\":100},\"r\":{\"a\":0,\"k\":0},\"p\":{\"a\":0,\"k\":[40,40,0]},"
        "\"a\":{\"a\":0,\"k\":[0,0,0]},\"s\":{\"a\":0,\"k\":[100,100,100]}},"
        "\"shapes\":[{\"ty\":\"el\",\"nm\":\"Ellipse\",\"p\":{\"a\":0,\"k\":[0,0]},\"s\":{\"a\":0,\"k\":[40,40]}},"
        "{\"ty\":\"fl\",\"nm\":\"Fill\",\"c\":{\"a\":0,\"k\":[1,0,0,1]},\"o\":{\"a\":0,\"k\":100},\"r\":1}],"
        "\"ip\":0,\"op\":30,\"st\":0,\"bm\":0}]}";
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:
        [NSString stringWithFormat:@"CYLColors-%@.json", NSUUID.UUID.UUIDString]]];
    NSError *error = nil;
    XCTAssertTrue([json writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error]);
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemLottieURL: url,
        CYLPlaceholderItemAnimationColors: @{@"Shape.Fill.Color": UIColor.greenColor},
        CYLPlaceholderItemLottieDarkColors: @{@"Shape.Fill.Color": UIColor.blueColor}
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    placeholder.frame = window.bounds;
    [window addSubview:placeholder];
    [placeholder layoutIfNeeded];
    UIView *lottie = [[placeholder valueForKey:@"backendView"] subviews].firstObject;
    [lottie layoutIfNeeded];
    UIColor *light = [lottie valueForKey:@"cyl_appliedColors"][@"Shape.Fill.Color"];
    XCTAssertNotNil(light);
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    XCTAssertTrue([light getRed:&red green:&green blue:&blue alpha:&alpha]);
    XCTAssertEqualWithAccuracy(green, 1, 0.02);
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        UIView *newLottie = [[placeholder valueForKey:@"backendView"] subviews].firstObject;
        [placeholder layoutIfNeeded];
        [newLottie layoutIfNeeded];
        UIColor *color = [newLottie valueForKey:@"cyl_appliedColors"][@"Shape.Fill.Color"];
        CGFloat r, g, b, a;
        return [color getRed:&r green:&g blue:&b alpha:&a] && b > 0.98;
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];
    [placeholder removeFromSuperview];
    XCTAssertTrue([[NSFileManager defaultManager] removeItemAtURL:url error:&error]);
}

- (void)testDarkAnimationFailureAndLightRecovery {
    NSString *json = @"{\"v\":\"5.7.4\",\"fr\":30,\"ip\":0,\"op\":30,\"w\":80,\"h\":80,\"nm\":\"Test\",\"ddd\":0,\"assets\":[],\"layers\":[]}";
    NSString *prefix = [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
    NSURL *light = [NSURL fileURLWithPath:[prefix stringByAppendingString:@"-light.json"]];
    NSURL *dark = [NSURL fileURLWithPath:[prefix stringByAppendingString:@"-dark.json"]];
    NSError *error = nil;
    XCTAssertTrue([json writeToURL:light atomically:YES encoding:NSUTF8StringEncoding error:&error]);
    XCTAssertTrue([@"invalid" writeToURL:dark atomically:YES encoding:NSUTF8StringEncoding error:&error]);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(20, 20)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [UIColor.blueColor setFill];
        UIRectFill(CGRectMake(0, 0, 20, 20));
    }];
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemLottieURL: light, CYLPlaceholderItemLottieDarkURL: dark,
        CYLPlaceholderItemImage: image
    } imageBundle:nil error:&error];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    [window addSubview:placeholder];
    XCTAssertNotNil([placeholder valueForKey:@"backendView"]);
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return [placeholder valueForKey:@"backendView"] == nil;
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];
    XCTAssertNil([placeholder valueForKey:@"backendView"]);
    XCTAssertFalse(placeholder.imageView.layer.hidden);
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return [placeholder valueForKey:@"backendView"] != nil;
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];
    XCTAssertNotNil([placeholder valueForKey:@"backendView"]);
    XCTAssertTrue(placeholder.imageView.layer.hidden);
    [placeholder removeFromSuperview];
    XCTAssertTrue([[NSFileManager defaultManager] removeItemAtURL:light error:&error]);
    XCTAssertTrue([[NSFileManager defaultManager] removeItemAtURL:dark error:&error]);
}

- (void)testLocalLottieLoadsAndPlaysInPlaceholder {
    NSString *json = @"{\"v\":\"5.7.4\",\"fr\":30,\"ip\":0,\"op\":30,\"w\":80,\"h\":80,"
        "\"nm\":\"Test\",\"ddd\":0,\"assets\":[],\"layers\":[{\"ddd\":0,\"ind\":1,"
        "\"ty\":1,\"nm\":\"Solid\",\"sw\":40,\"sh\":40,\"sc\":\"#ff0000\","
        "\"ks\":{\"o\":{\"a\":0,\"k\":100},\"r\":{\"a\":0,\"k\":0},"
        "\"p\":{\"a\":1,\"k\":[{\"t\":0,\"s\":[20,40,0],\"e\":[60,40,0],"
        "\"i\":{\"x\":[0.667],\"y\":[1]},\"o\":{\"x\":[0.333],\"y\":[0]}},"
        "{\"t\":30,\"s\":[60,40,0]}]},\"a\":{\"a\":0,\"k\":[20,20,0]},"
        "\"s\":{\"a\":0,\"k\":[100,100,100]}},\"ip\":0,\"op\":30,\"st\":0,\"bm\":0}]}";
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:
        [NSString stringWithFormat:@"CYLPlaceholder-%@.json", NSUUID.UUID.UUIDString]]];
    NSError *error = nil;
    XCTAssertTrue([json writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error]);
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemLottieURL: url, CYLPlaceholderItemLottieSize: @[@80, @80],
        CYLPlaceholderItemTitle: @"Offline"
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    XCTAssertNil(error);
    UIView *backend = [placeholder valueForKey:@"backendView"];
    XCTAssertNotNil(backend, @"The optional adapter must be linked and decode the Lottie JSON");
    XCTAssertTrue(placeholder.imageView.layer.hidden);

    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    placeholder.frame = window.bounds;
    [window addSubview:placeholder];
    [placeholder layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetWidth(backend.frame), 80, 0.1);
    if (!UIAccessibilityIsReduceMotionEnabled()) {
        XCTAssertTrue([[backend valueForKey:@"playing"] boolValue]);
        UIView *lottie = backend.subviews.firstObject;
        XCTAssertTrue([[lottie valueForKey:@"cyl_isAnimationPlaying"] boolValue]);
        XCTestExpectation *elapsed = [self expectationWithDescription:@"Lottie advances"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{ [elapsed fulfill]; });
        [self waitForExpectations:@[elapsed] timeout:3];
        XCTAssertGreaterThan([[lottie valueForKey:@"cyl_realtimeAnimationProgress"] doubleValue], 0);
        [placeholder stopPlaceholderAnimation];
        XCTAssertFalse([[lottie valueForKey:@"cyl_isAnimationPlaying"] boolValue]);
        [placeholder showPlaceholderAnimationLastFrame];
        XCTAssertEqualWithAccuracy([[lottie valueForKey:@"cyl_realtimeAnimationProgress"] doubleValue], 1, 0.01);
        XCTAssertTrue([placeholder setPlaceholderAnimationProgress:0.5]);
        XCTAssertEqualWithAccuracy([[lottie valueForKey:@"cyl_realtimeAnimationProgress"] doubleValue], 0.5, 0.01);
        [placeholder removeFromSuperview];
        [window addSubview:placeholder];
        XCTAssertEqualWithAccuracy([[lottie valueForKey:@"cyl_realtimeAnimationProgress"] doubleValue], 0.5, 0.01);
        XCTAssertFalse([placeholder setPlaceholderAnimationProgress:1.5]);
        XCTAssertTrue([placeholder setPlaceholderAnimationSpeed:2]);
        XCTAssertEqualWithAccuracy([[lottie valueForKey:@"cyl_animationSpeed"] doubleValue], 2, 0.01);
        XCTAssertFalse([placeholder setPlaceholderAnimationSpeed:0]);
        [placeholder playPlaceholderAnimation];
        XCTAssertTrue([[lottie valueForKey:@"cyl_isAnimationPlaying"] boolValue]);
    }
    [placeholder removeFromSuperview];
    XCTAssertFalse([[backend valueForKey:@"playing"] boolValue]);
    XCTAssertTrue([[NSFileManager defaultManager] removeItemAtURL:url error:&error]);
}

@end
