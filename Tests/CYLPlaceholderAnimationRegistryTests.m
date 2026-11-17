#import <XCTest/XCTest.h>
#import <ImageIO/ImageIO.h>
#import <CYLTableViewPlaceHolder/CYLPlaceholderView.h>

// [EN] CYLPlaceholderView plays every animation through CYLTabBarController's animation engine: the animators that
//      the GIF, Lottie, PAG and Rive subspecs bring register with `CYLTabBarItemAnimatorRegistry`, and an app's own
//      animator registers the same way.
// [CN] CYLPlaceholderView 通过 CYLTabBarController 的动画引擎播放所有动画：GIF、Lottie、PAG、Rive 子库带入的 animator 注册到
//      `CYLTabBarItemAnimatorRegistry`，应用自己的 animator 也以同样方式注册。

/// [EN] The view of the custom animator below. [CN] 下面自定义 animator 的视图。
@interface CYLRegistryTestView : UIView
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *options;
@end
@implementation CYLRegistryTestView
@end

/// [EN] Counts what the placeholder asks of the player. [CN] 记录占位图对播放器的调用。
@interface CYLRegistryTestPlayer : CYLTabBarItemAnimationBasePlayer <CYLTabBarItemAnimationPlayer>
@property (nonatomic) NSInteger plays;
@property (nonatomic) NSInteger stops;
@end
@implementation CYLRegistryTestPlayer
- (void)play { self.plays++; }
- (void)stop { self.stops++; }
- (void)showLastFrame { self.stops++; }
@end

/// [EN] An app's own animator for ".cyltest" files; it reads the options from the URL's fragment, as the engine's
///      animators do. [CN] 应用自己的 ".cyltest" animator；与引擎的 animator 一样从 URL 的 fragment 中读取选项。
@interface CYLRegistryTestAnimator : NSObject <CYLTabBarItemAnimator>
@property (nonatomic, strong) CYLRegistryTestPlayer *player;
@end
@implementation CYLRegistryTestAnimator
- (NSString *)identifier { return @"CYLTest"; }
- (NSArray<NSString *> *)fileExtensions { return @[@"cyltest"]; }
- (BOOL)canAnimateFileAtURL:(NSURL *)URL { return [URL.pathExtension.lowercaseString isEqualToString:@"cyltest"]; }
- (UIView *)animationViewWithURL:(NSURL *)URL size:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    CYLRegistryTestView *view = [[CYLRegistryTestView alloc] initWithFrame:(CGRect){CGPointZero, size}];
    NSMutableDictionary<NSString *, NSString *> *options = [NSMutableDictionary dictionary];
    NSString *fragment = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:YES].percentEncodedFragment;
    for (NSString *item in [fragment componentsSeparatedByString:@"&"]) {
        NSArray<NSString *> *pair = [item componentsSeparatedByString:@"="];
        if (pair.count == 2) options[pair[0].stringByRemovingPercentEncoding] = pair[1].stringByRemovingPercentEncoding;
    }
    view.options = options;
    return view;
}
- (id<CYLTabBarItemAnimationPlayer>)playerForAnimationView:(UIView *)view {
    if (![view isKindOfClass:CYLRegistryTestView.class]) return nil;
    self.player = [[CYLRegistryTestPlayer alloc] initWithAnimationView:view];
    return self.player;
}
@end

@interface CYLPlaceholderAnimationRegistryTests : XCTestCase
@end

@implementation CYLPlaceholderAnimationRegistryTests

- (NSURL *)gifURL {
    NSMutableData *data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data,
        CFSTR("com.compuserve.gif"), 2, NULL);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(20, 20)];
    for (UIColor *color in @[UIColor.redColor, UIColor.blueColor]) {
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [color setFill];
            UIRectFill(CGRectMake(0, 0, 20, 20));
        }];
        NSDictionary *properties = @{(__bridge NSString *)kCGImagePropertyGIFDictionary:
            @{(__bridge NSString *)kCGImagePropertyGIFDelayTime: @0.2}};
        CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)properties);
    }
    XCTAssertTrue(CGImageDestinationFinalize(destination));
    CFRelease(destination);
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:
        [NSString stringWithFormat:@"CYLRegistry-%@.gif", NSUUID.UUID.UUIDString]]];
    XCTAssertTrue([data writeToURL:url atomically:YES]);
    return url;
}

- (void)testTheSubspecsAnimatorsRegisterThemselves {
    NSArray<NSString *> *identifiers = [[CYLTabBarItemAnimatorRegistry animators] valueForKey:@"identifier"];
    for (NSString *identifier in @[@"GIF", @"PAG", @"Rive", @"Lottie"]) {
        XCTAssertTrue([identifiers containsObject:identifier], @"%@ is not registered", identifier);
    }
    // Lottie has the fallback priority, so it is looked up last.
    XCTAssertEqualObjects(identifiers.lastObject, @"Lottie");
    NSArray<NSString *> *extensions = [CYLTabBarItemAnimatorRegistry fileExtensions];
    for (NSString *extension in @[@"gif", @"pag", @"riv", @"json"]) {
        XCTAssertTrue([extensions containsObject:extension], @"%@", extension);
    }
    XCTAssertEqualObjects([CYLTabBarItemAnimatorRegistry animatorForURL:[NSURL fileURLWithPath:@"/a.PAG"]].identifier, @"PAG");
    XCTAssertEqualObjects([CYLTabBarItemAnimatorRegistry animatorForURL:[NSURL fileURLWithPath:@"/a.json"]].identifier, @"Lottie");
    XCTAssertNil([CYLTabBarItemAnimatorRegistry animatorForURL:[NSURL fileURLWithPath:@"/a.txt"]]);
}

- (void)testAnUnknownOrMissingFileKeepsTheStaticImage {
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleNoInternet];
    NSString *unknown = [NSTemporaryDirectory() stringByAppendingPathComponent:@"CYLRegistry-unknown.txt"];
    [@"text" writeToFile:unknown atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    for (NSString *path in @[unknown, @"/missing/animation.json", @"/missing/animation.riv"]) {
        NSError *error = nil;
        CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
            CYLPlaceholderItemAnimationFilePath: path, CYLPlaceholderItemImage: image
        } imageBundle:nil error:&error];
        XCTAssertNotNil(placeholder, @"%@", error);
        XCTAssertNil(placeholder.animationView, @"%@", path);
        XCTAssertEqual(placeholder.imageView.image, image, @"%@", path);
        XCTAssertFalse(placeholder.imageView.hidden, @"%@", path);
    }
    [[NSFileManager defaultManager] removeItemAtPath:unknown error:NULL];
}

- (void)testGIFPlaysThroughTheGIFAnimator {
    NSURL *url = [self gifURL];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemGIFURL: url, CYLPlaceholderItemGIFSize: @[@40, @30],
        CYLPlaceholderItemAnimationOptions: @{@"contentMode": @"center"}
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    XCTAssertEqualObjects([CYLTabBarItemAnimatorRegistry animatorForURL:url].identifier, @"GIF");
    UIView *gif = placeholder.animationView;
    XCTAssertNotNil(gif, @"the GIF subspec plays GIF files");
    XCTAssertEqual(gif.contentMode, UIViewContentModeCenter);
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    placeholder.frame = window.bounds;
    [window addSubview:placeholder];
    [placeholder layoutIfNeeded];
    XCTAssertEqualWithAccuracy(CGRectGetWidth(gif.frame), 40, 0.01);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(gif.frame), 30, 0.01);
    [placeholder showPlaceholderAnimationLastFrame];
    [placeholder stopPlaceholderAnimation];
    [placeholder playPlaceholderAnimation];
    [placeholder removeFromSuperview];
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
}

- (void)testACustomAnimatorReceivesOptionsAndPlays {
    CYLRegistryTestAnimator *animator = [CYLRegistryTestAnimator new];
    [CYLTabBarItemAnimatorRegistry registerAnimator:animator];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"custom.cyltest"];
    [@"custom" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemAnimationURL: [NSURL fileURLWithPath:path],
        CYLPlaceholderItemAnimationOptions: @{@"name": @"a b&c", @"count": @2}
    } imageBundle:nil error:&error];
    CYLRegistryTestView *view = (CYLRegistryTestView *)placeholder.animationView;
    XCTAssertTrue([view isKindOfClass:CYLRegistryTestView.class]);
    XCTAssertEqualObjects(view.options, (@{@"name": @"a b&c", @"count": @"2"}));
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    if (!UIAccessibilityIsReduceMotionEnabled()) XCTAssertGreaterThan(animator.player.plays, 0);
    NSInteger stops = animator.player.stops;
    [placeholder removeFromSuperview];
    XCTAssertGreaterThan(animator.player.stops, stops, @"off screen: stopped");
    XCTAssertFalse([placeholder setPlaceholderAnimationSpeed:2], @"the player has no speed");
    [CYLTabBarItemAnimatorRegistry unregisterAnimatorWithIdentifier:@"CYLTest"];
    XCTAssertNil([CYLTabBarItemAnimatorRegistry animatorWithIdentifier:@"CYLTest"]);
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

@end
