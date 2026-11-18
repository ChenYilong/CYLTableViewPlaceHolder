#import <XCTest/XCTest.h>
#import <libpag/PAGView.h>
#import <CYLTableViewPlaceHolder/CYLPlaceholderView.h>

// [EN] PAG and Rive play through CYLTabBarController's animation engine and the animators its `CYLAnimatedItemPAG` and
//      `CYLAnimatedItemRive` subspecs register (brought by this pod's PAG and Rive subspecs). The animators themselves are
//      tested in CYLTabBarController; these tests check what CYLPlaceholderView adds: loading, the playback policy,
//      seeking and the static image as the fallback.
// [CN] PAG 与 Rive 通过 CYLTabBarController 的动画引擎，以及其 `CYLAnimatedItemPAG`、`CYLAnimatedItemRive` 子库注册的 animator 播放（由本 pod
//      的 PAG、Rive 子库带入）。animator 本身在 CYLTabBarController 中测试；这里检查 CYLPlaceholderView 增加的部分：加载、播放策略、定位以及作为回退的静态图片。

/// Upper bound for asynchronous loads: CI simulators can compile Metal shaders for seconds before the first Rive or PAG frame.
static const NSTimeInterval CYLTestTimeout = 30;

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
    PAGView *pag = (PAGView *)placeholder.animationView;
    XCTAssertTrue([pag isKindOfClass:PAGView.class], @"the PAG animator plays the file");
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    if (!UIAccessibilityIsReduceMotionEnabled()) {
        XCTestExpectation *elapsed = [self expectationWithDescription:@"PAG advances"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{ [elapsed fulfill]; });
        [self waitForExpectations:@[elapsed] timeout:15];
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
        XCTAssertFalse([placeholder setPlaceholderAnimationSpeed:2], @"PAG has no playback speed");
        [placeholder playPlaceholderAnimation];
        XCTAssertTrue([pag isPlaying]);
    }
    placeholder.animationRepeatCount = 0;
    XCTAssertEqual([pag repeatCount], 0, @"0 loops");
    placeholder.animationRepeatCount = 1;
    XCTAssertEqual([pag repeatCount], 1);
    [placeholder removeFromSuperview];
    XCTAssertFalse([pag isPlaying]);
}

- (void)testRiveLoadsAndCoversTheStaticImage {
    NSURL *url = [self fixture:@"icons" extension:@"riv"];
    NSError *error = nil;
    UIImage *image = [self fallbackImage];
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemRiveURL: url, CYLPlaceholderItemRiveSize: @[@80, @80],
        CYLPlaceholderItemImage: image,
        CYLPlaceholderItemAnimationOptions: @{@"artboard": @"CHAT", @"stateMachine": @"CHAT_Interactivity"}
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder.animationView, @"the Rive animator plays the file");
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return placeholder.animationView != nil && placeholder.imageView.layer.hidden;
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
    [placeholder stopPlaceholderAnimation];
    [placeholder playPlaceholderAnimation];
    [placeholder removeFromSuperview];
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
    // [EN] A corrupted file: the animator reports the failure, the base class drops the animation and shows the image.
    // [CN] 损坏的文件：animator 报告失败，基类移除动画并显示图片。
    [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return placeholder.animationView == nil;
    }] evaluatedWithObject:placeholder handler:nil];
    [self waitForExpectationsWithTimeout:CYLTestTimeout handler:nil];
    XCTAssertFalse(placeholder.imageView.layer.hidden);
    XCTAssertEqual(placeholder.imageView.image, image);
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
}

@end
