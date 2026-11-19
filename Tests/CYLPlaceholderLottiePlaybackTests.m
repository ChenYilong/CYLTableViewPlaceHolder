#import <XCTest/XCTest.h>
// CYLPlaceholderView is Swift: the umbrella header brings its generated interface.
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

// [EN] Lottie plays through CYLTabBarController's animation engine and its Lottie animator (the LottieSwift subspec brings
//      `CYLAnimatedItem/LottieSwift`); the animation view is its `CYLCompatibleLOTAnimationView`, read
//      here through key-value coding only.
// [CN] Lottie 通过 CYLTabBarController 的动画引擎及其 Lottie animator 播放（LottieSwift 子库带入
//      `CYLAnimatedItem/LottieSwift`）；动画视图是其 `CYLCompatibleLOTAnimationView`，这里只通过 KVC 读取。

static UIColor *CYLRenderedCenterColor(UIView *view) {
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
    format.scale = 1;
    UIImage *image = [[[UIGraphicsImageRenderer alloc] initWithSize:view.bounds.size format:format]
        imageWithActions:^(UIGraphicsImageRendererContext *context) {
        // Lottie's Core Animation renderer animates its layers, so draw what is on screen.
        [CATransaction flush];
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
        CALayer *layer = view.layer.presentationLayer ?: view.layer;
        [layer renderInContext:context.CGContext];
    }];
    unsigned char pixel[4] = {0};
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, space, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(-floor(image.size.width / 2), -floor(image.size.height / 2),
                                           image.size.width, image.size.height), image.CGImage);
    CGContextRelease(context);
    CGColorSpaceRelease(space);
    return [UIColor colorWithRed:pixel[0] / 255.0 green:pixel[1] / 255.0 blue:pixel[2] / 255.0 alpha:pixel[3] / 255.0];
}

/// Upper bound for asynchronous loads and fallbacks: loaded CI simulators can take seconds per main-queue turn.
static const NSTimeInterval CYLTestTimeout = 30;

static NSURL *CYLWriteLottie(NSString *json, NSString *name) {
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:
        [NSString stringWithFormat:@"%@-%@.json", name, NSUUID.UUID.UUIDString]]];
    [json writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    return url;
}

static NSString *const CYLEmptyLottie = @"{\"v\":\"5.7.4\",\"fr\":30,\"ip\":0,\"op\":30,\"w\":80,\"h\":80,\"nm\":\"Test\","
    "\"ddd\":0,\"assets\":[],\"layers\":[]}";

@interface CYLPlaceholderLottiePlaybackTests : XCTestCase
@end

@implementation CYLPlaceholderLottiePlaybackTests

- (void)testTheLottieAnimatorIsRegistered {
    // [EN] A real Lottie document: since upstream PR #814 the Lottie animator takes only files it can play, so a missing
    //      "/a.json" has no animator.
    // [CN] 真实的 Lottie 文档：自上游 PR #814 起，Lottie animator 只接收它能播放的文件，缺失的 "/a.json" 没有 animator。
    NSString *lottie = [CYLPlaceholderView pathForBundledAnimation:@"CYLPlaceholderLoading.json"];
    XCTAssertNotNil(lottie);
    XCTAssertEqualObjects([CYLTabBarItemAnimatorRegistry animatorForURL:[NSURL fileURLWithPath:lottie]].identifier, @"Lottie");
    XCTAssertNil([CYLTabBarItemAnimatorRegistry animatorForURL:[NSURL fileURLWithPath:@"/a.json"]]);
}

- (void)testLottieColorOverridesFollowAppearance {
    NSString *json = @"{\"v\":\"5.7.4\",\"fr\":30,\"ip\":0,\"op\":30,\"w\":80,\"h\":80,\"nm\":\"Test\","
        "\"ddd\":0,\"assets\":[],\"layers\":[{\"ddd\":0,\"ind\":1,\"ty\":4,\"nm\":\"Shape\","
        "\"ks\":{\"o\":{\"a\":0,\"k\":100},\"r\":{\"a\":0,\"k\":0},\"p\":{\"a\":0,\"k\":[40,40,0]},"
        "\"a\":{\"a\":0,\"k\":[0,0,0]},\"s\":{\"a\":0,\"k\":[100,100,100]}},"
        "\"shapes\":[{\"ty\":\"el\",\"nm\":\"Ellipse\",\"p\":{\"a\":0,\"k\":[0,0]},\"s\":{\"a\":0,\"k\":[40,40]}},"
        "{\"ty\":\"fl\",\"nm\":\"Fill\",\"c\":{\"a\":0,\"k\":[1,0,0,1]},\"o\":{\"a\":0,\"k\":100},\"r\":1}],"
        "\"ip\":0,\"op\":30,\"st\":0,\"bm\":0}]}";
    NSURL *url = CYLWriteLottie(json, @"CYLColors");
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemLottieURL: url, CYLPlaceholderItemLottieSize: @[@80, @80],
        CYLPlaceholderItemAnimationColors: @{@"Shape.Fill.Color": UIColor.greenColor},
        CYLPlaceholderItemLottieDarkColors: @{@"Shape.Fill.Color": UIColor.blueColor}
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    placeholder.frame = window.bounds;
    [window addSubview:placeholder];
    window.hidden = NO;
    [placeholder layoutIfNeeded];
    UIView *lottie = placeholder.animationView;
    XCTAssertNotNil(lottie, @"the Lottie animator must be linked and decode the JSON");
    // The override is drawn: the ellipse at the center renders green, not its own red.
    [placeholder stopPlaceholderAnimation];
    [lottie layoutIfNeeded];
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    UIColor *drawn = CYLRenderedCenterColor(lottie);
    XCTAssertTrue([drawn getRed:&red green:&green blue:&blue alpha:&alpha]);
    XCTAssertGreaterThan(green, 0.8, @"rendered %@", drawn);
    XCTAssertLessThan(red, 0.2, @"rendered %@", drawn);
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    // [EN] The appearance change loads the file again with the dark colors. [CN] 外观变化后以深色颜色重新加载文件。
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return placeholder.animationView != nil && placeholder.animationView != lottie;
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
    UIView *darkLottie = placeholder.animationView;
    [placeholder stopPlaceholderAnimation];
    [placeholder layoutIfNeeded];
    [darkLottie layoutIfNeeded];
    UIColor *darkDrawn = CYLRenderedCenterColor(darkLottie);
    XCTAssertTrue([darkDrawn getRed:&red green:&green blue:&blue alpha:&alpha]);
    XCTAssertGreaterThan(blue, 0.8, @"rendered %@", darkDrawn);
    window.hidden = YES;
    [placeholder removeFromSuperview];
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
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
    NSURL *url = CYLWriteLottie(json, @"CYLPlaceholder");
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemLottieURL: url, CYLPlaceholderItemLottieSize: @[@80, @80],
        CYLPlaceholderItemTitle: @"Offline"
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    XCTAssertNil(error);
    UIView *lottie = placeholder.animationView;
    XCTAssertNotNil(lottie, @"the Lottie animator must be linked and decode the JSON");
    XCTAssertTrue(placeholder.isAnimationReady);
    XCTAssertTrue(placeholder.imageView.layer.hidden, @"the animation covers the static image");

    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    placeholder.frame = window.bounds;
    [window addSubview:placeholder];
    [placeholder layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetWidth(lottie.frame), 80, 0.1);
    if (!UIAccessibilityIsReduceMotionEnabled()) {
        XCTAssertTrue([[lottie valueForKey:@"isAnimationPlaying"] boolValue]);
        XCTestExpectation *elapsed = [self expectationWithDescription:@"Lottie advances"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{ [elapsed fulfill]; });
        [self waitForExpectations:@[elapsed] timeout:15];
        XCTAssertGreaterThan([[lottie valueForKey:@"realtimeAnimationProgress"] doubleValue], 0);
        [placeholder stopPlaceholderAnimation];
        XCTAssertFalse([[lottie valueForKey:@"isAnimationPlaying"] boolValue]);
        [placeholder showPlaceholderAnimationLastFrame];
        XCTAssertEqualWithAccuracy([[lottie valueForKey:@"realtimeAnimationProgress"] doubleValue], 1, 0.01);
        XCTAssertTrue([placeholder setPlaceholderAnimationProgress:0.5]);
        XCTAssertEqualWithAccuracy([[lottie valueForKey:@"realtimeAnimationProgress"] doubleValue], 0.5, 0.01);
        [placeholder removeFromSuperview];
        [window addSubview:placeholder];
        XCTAssertEqualWithAccuracy([[lottie valueForKey:@"realtimeAnimationProgress"] doubleValue], 0.5, 0.01);
        XCTAssertFalse([placeholder setPlaceholderAnimationProgress:1.5]);
        XCTAssertTrue([placeholder setPlaceholderAnimationSpeed:2]);
        XCTAssertEqualWithAccuracy([[lottie valueForKey:@"animationSpeed"] doubleValue], 2, 0.01);
        XCTAssertFalse([placeholder setPlaceholderAnimationSpeed:0]);
        [placeholder playPlaceholderAnimation];
        XCTAssertTrue([[lottie valueForKey:@"isAnimationPlaying"] boolValue]);
        // A one-shot animation that finished replays from progress 0 (the examples' "Play all" with the loop off).
        // Polled at speed 1, not sampled once after a fixed wait: a slow runner can deliver a single late sample after
        // the replay already ended on its last frame (seen: 0.99999 at speed 2). Without a replay the progress stays at 1.
        placeholder.animationRepeatCount = 1;
        XCTAssertTrue([placeholder setPlaceholderAnimationSpeed:1]);
        [placeholder showPlaceholderAnimationLastFrame];
        XCTAssertEqualWithAccuracy([[lottie valueForKey:@"realtimeAnimationProgress"] doubleValue], 1, 0.01);
        [placeholder playPlaceholderAnimation];
        XCTAssertTrue([[lottie valueForKey:@"isAnimationPlaying"] boolValue]);
        double lowestProgress = [[lottie valueForKey:@"realtimeAnimationProgress"] doubleValue];
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:3];
        while (lowestProgress >= 0.9 && deadline.timeIntervalSinceNow > 0) {
            [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
            lowestProgress = MIN(lowestProgress, [[lottie valueForKey:@"realtimeAnimationProgress"] doubleValue]);
        }
        XCTAssertLessThan(lowestProgress, 0.9,
                          @"the 1 s animation restarted at 0, it did not stay on its last frame");
    }
    [placeholder removeFromSuperview];
    XCTAssertFalse([[lottie valueForKey:@"isAnimationPlaying"] boolValue]);
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
}

- (void)testOptionsAndStateSurviveDarkModeReplacement {
    NSString *prefix = [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
    NSURL *light = [NSURL fileURLWithPath:[prefix stringByAppendingString:@"-light.json"]];
    NSURL *dark = [NSURL fileURLWithPath:[prefix stringByAppendingString:@"-dark.json"]];
    NSError *error = nil;
    XCTAssertTrue([CYLEmptyLottie writeToURL:light atomically:YES encoding:NSUTF8StringEncoding error:&error]);
    XCTAssertTrue([CYLEmptyLottie writeToURL:dark atomically:YES encoding:NSUTF8StringEncoding error:&error]);
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemLottieURL: light, CYLPlaceholderItemLottieDarkURL: dark,
        CYLPlaceholderItemAnimationOptions: @{@"animationSpeed": @3, @"contentMode": @"scaleAspectFill"}
    } imageBundle:nil error:&error];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    [window addSubview:placeholder];
    UIView *lottie = placeholder.animationView;
    XCTAssertNotNil(lottie);
    XCTAssertEqualWithAccuracy([[lottie valueForKey:@"animationSpeed"] doubleValue], 3, 0.01);
    XCTAssertEqual(lottie.contentMode, UIViewContentModeScaleAspectFill);
    XCTAssertTrue([placeholder setPlaceholderAnimationSpeed:2]);
    XCTAssertTrue([placeholder setPlaceholderAnimationProgress:0.5]);
    window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return placeholder.animationView != nil && placeholder.animationView != lottie;
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
    UIView *replacement = placeholder.animationView;
    XCTAssertEqualWithAccuracy([[replacement valueForKey:@"animationSpeed"] doubleValue], 2, 0.01);
    XCTAssertEqualWithAccuracy([[replacement valueForKey:@"realtimeAnimationProgress"] doubleValue], 0.5, 0.01);
    XCTAssertEqual(replacement.contentMode, UIViewContentModeScaleAspectFill);
    [placeholder removeFromSuperview];
    [[NSFileManager defaultManager] removeItemAtURL:light error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:dark error:NULL];
}

@end
