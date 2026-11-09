#import <XCTest/XCTest.h>
#import <ImageIO/ImageIO.h>
#import <CYLTableViewPlaceHolder/CYLPlaceholderView.h>
#import <CYLTableViewPlaceHolder/CYLPlaceholderAnimationView.h>
#import <CYLTableViewPlaceHolder/CYLPlaceholderItemAnimatorRegistry.h>
#import <CYLTableViewPlaceHolder/CYLPlaceholderItemAnimationFactory.h>
#import <CYLTableViewPlaceHolder/CYLPlaceholderItemViewAnimator.h>

/// A self-playing view for a custom animator registered through the short path.
@interface CYLTestPlayableView : UIView <CYLPlaceholderItemAnimationPlayableView, CYLPlaceholderItemAnimationViewProviding>
@property (nonatomic) NSInteger plays;
@property (nonatomic) NSInteger stops;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *options;
@end

@implementation CYLTestPlayableView
+ (UIView<CYLPlaceholderItemAnimationPlayableView> *)cyl_animationViewWithFileURL:(NSURL *)fileURL
                                                                          options:(NSDictionary<NSString *, NSString *> *)options
                                                                      contentMode:(UIViewContentMode)contentMode {
    CYLTestPlayableView *view = [[self alloc] initWithFrame:CGRectZero];
    view.options = options;
    view.contentMode = contentMode;
    return view;
}
- (void)cyl_playAnimationView { self.plays++; }
- (void)cyl_stopAnimationView { self.stops++; }
- (void)cyl_showAnimationViewLastFrame { self.stops++; }
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

- (void)testReferenceAnimatorsRegisterThemselves {
    NSArray<NSString *> *identifiers = [[CYLPlaceholderItemAnimatorRegistry animators] valueForKey:@"identifier"];
    for (NSString *identifier in @[@"GIF", @"PAG", @"Rive", @"Lottie"]) {
        XCTAssertTrue([identifiers containsObject:identifier], @"%@ is not registered", identifier);
    }
    // Lottie has the fallback priority, so it is looked up last.
    XCTAssertEqualObjects(identifiers.lastObject, @"Lottie");
    NSArray<NSString *> *extensions = [CYLPlaceholderItemAnimatorRegistry fileExtensions];
    for (NSString *extension in @[@"gif", @"pag", @"riv", @"json", @"lottie"]) {
        XCTAssertTrue([extensions containsObject:extension]);
    }
    XCTAssertEqualObjects([CYLPlaceholderItemAnimatorRegistry animatorForURL:[NSURL fileURLWithPath:@"/a.PAG"]].identifier, @"PAG");
    XCTAssertEqualObjects([CYLPlaceholderItemAnimatorRegistry animatorForURL:[NSURL fileURLWithPath:@"/a.json"]].identifier, @"Lottie");
    XCTAssertNil([CYLPlaceholderItemAnimatorRegistry animatorForURL:[NSURL fileURLWithPath:@"/a.txt"]]);
    XCTAssertEqualObjects([CYLPlaceholderItemAnimatorRegistry animatorForAttributes:@{CYLPlaceholderItemRiveURL: @"x.riv"}].identifier, @"Rive");
    XCTAssertEqualObjects([CYLPlaceholderItemAnimatorRegistry attributeKeyForGenericKey:CYLPlaceholderItemAnimationURL
                                                                           inAttributes:@{CYLPlaceholderItemPAGFilePath: @"x.pag"}],
                          CYLPlaceholderItemPAGURL);
}

- (void)testUnknownFormatIsUnsupportedAndInvalidOptionsAreRejected {
    NSError *error = nil;
    XCTAssertNil([[CYLPlaceholderAnimationView alloc] initWithFileURL:[NSURL fileURLWithPath:@"/missing.txt"]
        size:CGSizeMake(40, 40) contentMode:UIViewContentModeScaleAspectFit error:&error]);
    XCTAssertEqual(error.code, CYLPlaceholderAnimationErrorUnsupportedFormat);
    error = nil;
    XCTAssertNil([[CYLPlaceholderAnimationView alloc] initWithFileURL:[NSURL fileURLWithPath:@"/missing.riv"]
        size:CGSizeMake(40, 40) contentMode:UIViewContentModeScaleAspectFit options:@{@"duration": @"90"} error:&error]);
    XCTAssertEqual(error.code, CYLPlaceholderAnimationErrorInvalidOptions);
    error = nil;
    XCTAssertNil([[CYLPlaceholderAnimationView alloc] initWithFileURL:[NSURL fileURLWithPath:@"/missing.riv"]
        size:CGSizeMake(40, 40) contentMode:UIViewContentModeScaleAspectFit options:@{@"artboard": @[]} error:&error]);
    XCTAssertEqual(error.code, CYLPlaceholderAnimationErrorInvalidOptions);
    error = nil;
    XCTAssertNil([[CYLPlaceholderAnimationView alloc] initWithFileURL:[NSURL fileURLWithPath:@"/missing.json"]
        size:CGSizeMake(40, 40) contentMode:UIViewContentModeScaleAspectFit error:&error]);
    XCTAssertEqual(error.code, CYLPlaceholderAnimationErrorAssetLoadFailed);
}

- (void)testGIFPlaysOnceThroughTheRegisteredAnimator {
    NSURL *url = [self gifURL];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemGIFURL: url, CYLPlaceholderItemGIFSize: @[@40, @30],
        CYLPlaceholderItemAnimationOptions: @{@"contentMode": @"center"}
    } imageBundle:nil error:&error];
    XCTAssertNotNil(placeholder);
    CYLPlaceholderAnimationView *backend = [placeholder valueForKey:@"backendView"];
    XCTAssertTrue([backend isKindOfClass:CYLPlaceholderAnimationView.class]);
    XCTAssertEqual(backend.backend, CYLPlaceholderAnimationBackendGIF);
    XCTAssertEqualObjects(backend.animatorIdentifier, @"GIF");
    UIImageView *gif = (UIImageView *)backend.animationView;
    XCTAssertEqual(gif.contentMode, UIViewContentModeCenter);
    XCTAssertEqualWithAccuracy(CGRectGetWidth(backend.bounds), 40, 0.01);
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    if (!UIAccessibilityIsReduceMotionEnabled()) {
        CAKeyframeAnimation *animation = (CAKeyframeAnimation *)[gif.layer animationForKey:@"CYLGIFPlaceholderItemPlayAnimation"];
        XCTAssertNotNil(animation);
        XCTAssertEqualWithAccuracy(animation.duration, 0.4, 0.02);
        XCTAssertEqual(animation.values.count, animation.keyTimes.count);
    }
    [placeholder showPlaceholderAnimationLastFrame];
    XCTAssertNil([gif.layer animationForKey:@"CYLGIFPlaceholderItemPlayAnimation"]);
    [placeholder stopPlaceholderAnimation];
    XCTAssertNil([gif.layer animationForKey:@"CYLGIFPlaceholderItemPlayAnimation"]);
    XCTAssertFalse([placeholder setPlaceholderAnimationProgress:0.5]); // GIF has no seeking
    [placeholder removeFromSuperview];
    [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
}

- (void)testCustomViewAnimatorReceivesOptionsAndPlays {
    CYLPlaceholderItemViewAnimator *animator = [[CYLPlaceholderItemViewAnimator alloc] initWithIdentifier:@"CYLTest"
        fileExtensions:@[@"CYLTEST"] attributeKeys:nil viewProvider:[CYLTestPlayableView class]];
    [CYLPlaceholderItemAnimatorRegistry registerAnimator:animator];
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"custom.cyltest"]];
    NSError *error = nil;
    CYLPlaceholderView *placeholder = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemAnimationURL: url,
        CYLPlaceholderItemAnimationOptions: @{@"name": @"a b&c", @"count": @2}
    } imageBundle:nil error:&error];
    CYLPlaceholderAnimationView *backend = [placeholder valueForKey:@"backendView"];
    XCTAssertEqual(backend.backend, CYLPlaceholderAnimationBackendCustom);
    CYLTestPlayableView *view = (CYLTestPlayableView *)backend.animationView;
    XCTAssertEqualObjects(view.options, (@{@"name": @"a b&c", @"count": @"2"}));
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [window addSubview:placeholder];
    if (!UIAccessibilityIsReduceMotionEnabled()) XCTAssertEqual(view.plays, 1);
    [placeholder removeFromSuperview];
    XCTAssertGreaterThan(view.stops, 0);
    XCTAssertFalse([placeholder setPlaceholderAnimationSpeed:2]);
    [CYLPlaceholderItemAnimatorRegistry unregisterAnimatorWithIdentifier:@"CYLTest"];
    XCTAssertNil([CYLPlaceholderItemAnimatorRegistry animatorWithIdentifier:@"CYLTest"]);
}

@end
