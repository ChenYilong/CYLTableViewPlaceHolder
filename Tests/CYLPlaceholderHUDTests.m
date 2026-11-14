#import <XCTest/XCTest.h>
#import "CYLPlaceholderHUD.h"
#import "CYLPlaceholderLocalization.h"

@interface CYLPlaceholderHUDTests : XCTestCase
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *container;
@end

@implementation CYLPlaceholderHUDTests

- (void)setUp {
    [super setUp];
    CYLPlaceholderLocalization.language = @"en";
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 390, 844)];
    self.container = [[UIView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:self.container];
    self.window.hidden = NO;
}

- (void)tearDown {
    self.window.hidden = YES;
    self.window = nil;
    CYLPlaceholderLocalization.language = nil;
    [super tearDown];
}

/// A HUD over the test container with no fades, so every change is immediate.
- (CYLPlaceholderHUD *)makeHUD {
    CYLPlaceholderHUD *hud = [[CYLPlaceholderHUD alloc] initWithContainerView:self.container];
    hud.fadeInAnimationDuration = 0;
    hud.fadeOutAnimationDuration = 0;
    return hud;
}

- (void)testTheHUDScenarioIsALoopingRefreshAnimationWithALoadingTitle {
    CYLPlaceholderScenario scenario = CYLPlaceholderScenarioHUD;
    XCTAssertEqual([CYLPlaceholderScenarioCatalog categoryForScenario:scenario], CYLPlaceholderScenarioCategoryProgress);
    XCTAssertEqualObjects([CYLPlaceholderScenarioCatalog nameForScenario:scenario], @"HUD");
    XCTAssertEqual([CYLPlaceholderScenarioCatalog scenarioNamed:@"HUD"], scenario);
    CYLPlaceholderComponent *icon = [CYLPlaceholderScenarioCatalog componentsForScenario:scenario].firstObject;
    NSString *file = [icon.attributes[CYLPlaceholderItemAnimationFilePath] lastPathComponent];
    XCTAssertTrue([file hasPrefix:@"CYLRefresh"], @"the HUD reuses the refresh animations: %@", file);
    XCTAssertEqual(icon.animationRepeatCount, 0, @"loops by default, unlike a refresh icon that follows the pull");
    XCTAssertEqualObjects(icon.attributes[CYLPlaceholderItemTitle], @"Loading…");
    NSArray<NSString *> *names = [CYLPlaceholderScenarioCatalog animationFileNamesForScenario:scenario];
    for (NSString *extension in @[@"gif", @"json", @"pag", @"riv"]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == %@", extension];
        NSUInteger count = [names filteredArrayUsingPredicate:predicate].count;
        XCTAssertGreaterThan(count, 0u, @"%@", extension);
    }
    // [EN] The same scenario works as a full-screen placeholder too. [CN] 同一场景也可作为全屏占位图使用。
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithScenario:scenario actions:nil];
    XCTAssertEqualObjects(stack.placeholderView.textLabel.text, @"Loading…");
}

- (void)testShowLoopsTheLoadingAnimationAndPopActivityBalancesEveryShow {
    CYLPlaceholderHUD *hud = [self makeHUD];
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateHidden);
    XCTAssertFalse(hud.isVisible);
    [hud showWithStatus:@"Loading"];
    XCTAssertTrue(hud.isVisible);
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateLoading);
    XCTAssertEqual(hud.superview, self.container);
    XCTAssertEqualObjects(hud.contentView.textLabel.text, @"Loading");
    NSString *file = [hud.contentView.itemAttributes[CYLPlaceholderItemAnimationFilePath] lastPathComponent];
    XCTAssertEqualObjects(file, @"CYLRefreshActivity.gif");
    XCTAssertEqual(hud.contentView.animationRepeatCount, 0);

    XCTAssertNil(hud.placeholderView, @"one icon and title need no stack view");
    XCTAssertEqual(hud.contentView.superview, hud.hudView, @"the CYLPlaceholderView is the box");
    CYLPlaceholderView *first = hud.contentView;
    [hud show];
    XCTAssertEqual(hud.activityCount, 2u);
    XCTAssertEqual(hud.contentView, first, @"the same state updates in place, so the animation keeps playing");
    [hud setStatus:@"Still loading"];
    XCTAssertEqualObjects(hud.contentView.textLabel.text, @"Still loading");
    XCTAssertEqualObjects(hud.status, @"Still loading");

    [hud popActivity];
    XCTAssertTrue(hud.isVisible, @"one show is not balanced yet");
    [hud popActivity];
    XCTAssertFalse(hud.isVisible);
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateHidden);
    XCTAssertNil(hud.superview);
    XCTAssertNil(hud.placeholderView);
    XCTAssertNil(hud.contentView);
}

- (void)testProgressIsClampedAndShownWithoutRestartingTheHUD {
    CYLPlaceholderHUD *hud = [self makeHUD];
    [hud showProgress:0.3 status:@"Downloading"];
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateProgress);
    XCTAssertEqualWithAccuracy(hud.progress, 0.3, 0.001);
    CYLPlaceholderView *first = hud.contentView;
    XCTAssertTrue([first.textLabel.text hasPrefix:@"Downloading"]);
    XCTAssertTrue([first.textLabel.text containsString:@"30"], @"the title carries the percentage");
    [hud showProgress:1.7];
    XCTAssertEqualWithAccuracy(hud.progress, 1, 0.001);
    XCTAssertEqual(hud.contentView, first);
    XCTAssertNotNil(hud.contentView.accessibilityValue, @"VoiceOver reads the percentage");
    [hud showProgress:-1];
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateLoading, @"a negative progress is indeterminate");
    [hud dismiss];
    XCTAssertFalse(hud.isVisible);
}

- (void)testResultsDismissThemselvesAfterTheDisplayDuration {
    CYLPlaceholderHUD *hud = [self makeHUD];
    XCTAssertEqualWithAccuracy([hud displayDurationForString:@"Done"], 5, 0.001, @"at least the minimum interval");
    hud.minimumDismissTimeInterval = 0;
    hud.maximumDismissTimeInterval = 0.3;
    XCTAssertEqualWithAccuracy([hud displayDurationForString:@"Done"], 0.3, 0.001, @"at most the maximum interval");
    hud.maximumDismissTimeInterval = 10;
    XCTAssertEqualWithAccuracy([hud displayDurationForString:@"Done"], 0.74, 0.001, @"0.06 per character plus 0.5");

    hud.maximumDismissTimeInterval = 0.1;
    [hud showSuccessWithStatus:@"Saved"];
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateSuccess);
    XCTAssertEqual(hud.activityCount, 0u, @"a result ends every activity");
    XCTestExpectation *gone = [self expectationForPredicate:[NSPredicate predicateWithFormat:@"visible == NO"]
                                        evaluatedWithObject:hud handler:nil];
    [self waitForExpectations:@[gone] timeout:5];

    [hud showErrorWithStatus:@"Failed"];
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateError);
    XCTAssertNotNil(hud.contentView.imageView.image, @"the error image");
    [hud showInfoWithStatus:nil];
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateInfo);
    XCTAssertTrue(hud.contentView.textLabel.text.length == 0, @"no status, no text");
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleWarning];
    [hud showImage:image status:@"Careful"];
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateImage);
    [hud dismiss];
}

- (void)testNotificationsCarryTheStatusAndDismissRunsItsCompletion {
    CYLPlaceholderHUD *hud = [self makeHUD];
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    NSMutableArray *statuses = [NSMutableArray array];
    NSArray<NSString *> *observers = @[CYLPlaceholderHUDWillAppearNotification, CYLPlaceholderHUDDidAppearNotification,
                                       CYLPlaceholderHUDWillDisappearNotification, CYLPlaceholderHUDDidDisappearNotification];
    NSMutableArray *tokens = [NSMutableArray array];
    for (NSString *name in observers) {
        id token = [NSNotificationCenter.defaultCenter addObserverForName:name object:hud queue:nil
                                                               usingBlock:^(NSNotification *note) {
            [names addObject:note.name];
            [statuses addObject:note.userInfo[CYLPlaceholderHUDStatusUserInfoKey] ?: NSNull.null];
        }];
        [tokens addObject:token];
    }
    [hud showWithStatus:@"Syncing"];
    __block BOOL completed = NO;
    [hud dismissWithCompletion:^{
        completed = YES;
    }];
    for (id token in tokens) [NSNotificationCenter.defaultCenter removeObserver:token];
    XCTAssertTrue(completed);
    XCTAssertEqualObjects(names, observers);
    XCTAssertEqualObjects(statuses.firstObject, @"Syncing");
    XCTAssertEqualObjects(statuses.lastObject, @"Syncing");
}

- (void)testGraceTimeShowsNothingForAQuickTask {
    CYLPlaceholderHUD *hud = [self makeHUD];
    hud.graceTimeInterval = 10;
    __block NSUInteger appeared = 0;
    id token = [NSNotificationCenter.defaultCenter addObserverForName:CYLPlaceholderHUDWillAppearNotification
                                                               object:hud queue:nil
                                                           usingBlock:^(NSNotification *note) {
        appeared++;
    }];
    [hud show];
    XCTAssertTrue(hud.isVisible, @"about to show");
    XCTAssertTrue(hud.hidden, @"but not on screen during the grace time");
    [hud dismiss];
    [NSNotificationCenter.defaultCenter removeObserver:token];
    XCTAssertFalse(hud.isVisible);
    XCTAssertEqual(appeared, 0u);
}

- (void)testMasksBlockTouchesAndTheBoxIsLaidOutAtTheOffsetCenter {
    CYLPlaceholderHUD *hud = [self makeHUD];
    hud.offsetFromCenter = UIOffsetMake(0, 40);
    [hud showWithStatus:@"Loading"];
    [hud layoutIfNeeded];
    XCTAssertEqualWithAccuracy(hud.hudView.center.x, CGRectGetMidX(self.container.bounds), 0.5);
    XCTAssertEqualWithAccuracy(hud.hudView.center.y, CGRectGetMidY(self.container.bounds) + 40, 0.5);
    XCTAssertGreaterThanOrEqual(CGRectGetWidth(hud.hudView.bounds), hud.minimumSize.width);
    XCTAssertLessThanOrEqual(CGRectGetWidth(hud.hudView.bounds), 260);

    CGPoint corner = CGPointMake(5, 5);
    XCTAssertNil([hud hitTest:corner withEvent:nil], @"no mask: touches reach the views behind");
    XCTAssertFalse(hud.accessibilityViewIsModal);
    hud.maskType = CYLPlaceholderHUDMaskTypeBlack;
    XCTAssertEqual([hud hitTest:corner withEvent:nil], hud, @"a mask blocks touches");
    XCTAssertTrue(hud.accessibilityViewIsModal, @"and keeps VoiceOver in the box");
    hud.maskType = CYLPlaceholderHUDMaskTypeClear;
    XCTAssertEqual([hud hitTest:corner withEvent:nil], hud);
    [hud dismiss];
}

- (void)testCustomColorsSelectTheCustomStyle {
    CYLPlaceholderHUD *hud = [self makeHUD];
    hud.foregroundColor = UIColor.redColor;
    XCTAssertEqual(hud.style, CYLPlaceholderHUDStyleCustom);
    hud.hudBackgroundColor = UIColor.darkGrayColor;
    [hud showWithStatus:@"Loading"];
    XCTAssertEqualObjects(hud.contentView.textLabel.textColor, UIColor.redColor);
    CYLPlaceholderView *box = hud.contentView;
    XCTAssertEqualObjects(box.backgroundColor, UIColor.darkGrayColor,
                          @"the CYLPlaceholderView of an icon state is the box: icon and background are one view");
    XCTAssertEqualWithAccuracy(CGRectGetWidth([box convertRect:box.bounds toView:hud]), CGRectGetWidth(hud.hudView.bounds), 0.5);
    XCTAssertEqualWithAccuracy(CGRectGetMidY([box convertRect:box.bounds toView:hud]), hud.hudView.center.y, 0.5);
    XCTAssertEqualWithAccuracy(CGRectGetHeight([box convertRect:box.bounds toView:hud]), CGRectGetHeight(hud.hudView.bounds), 0.5);
    UIImageView *icon = box.imageView;
    XCTAssertEqualWithAccuracy(CGRectGetMidX([icon convertRect:icon.bounds toView:box]), CGRectGetMidX(box.bounds), 0.5,
                               @"the icon is centered in the box");
    hud.foregroundColor = nil;
    XCTAssertNotNil(hud.foregroundColor, @"null_resettable");
    [hud dismiss];
}

- (void)testComponentsInTheBoxKeepTheirTapActions {
    CYLPlaceholderHUD *hud = [self makeHUD];
    __block NSUInteger cancelled = 0;
    CYLPlaceholderComponent *cancel = [CYLPlaceholderComponent buttonComponentWithTitle:@"Cancel"
        style:CYLPlaceholderButtonStyleOutlined action:@"cancel"];
    NSMutableArray<CYLPlaceholderComponent *> *components =
        [[CYLPlaceholderScenarioCatalog componentsForScenario:CYLPlaceholderScenarioHUD] mutableCopy];
    [components addObject:cancel];
    CYLPlaceholderActionHandler handler = ^(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action) {
        cancelled++;
    };
    [hud showComponents:components actions:@{@"cancel": handler}];
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateCustom);
    XCTAssertEqual(hud.placeholderView.componentViews.count, 2u);
    XCTAssertEqual(hud.contentView, hud.placeholderView.placeholderView);
    XCTAssertTrue([hud.placeholderView performAction:@"cancel"]);
    XCTAssertEqual(cancelled, 1u);

    [hud showScenario:CYLPlaceholderScenarioUploading actions:nil];
    XCTAssertEqual(hud.placeholderView.componentViews.count, 1u);
    [hud dismiss];
    XCTAssertFalse(hud.isVisible);
}

- (void)testTheClassMethodsDriveTheSharedHUD {
    CYLPlaceholderHUD *shared = CYLPlaceholderHUD.sharedHUD;
    XCTAssertEqual(shared, CYLPlaceholderHUD.sharedHUD);
    shared.containerView = self.container;
    shared.fadeInAnimationDuration = 0;
    shared.fadeOutAnimationDuration = 0;
    [CYLPlaceholderHUD showWithStatus:@"Loading"];
    XCTAssertTrue(CYLPlaceholderHUD.isVisible);
    XCTAssertEqual(shared.superview, self.container);
    [CYLPlaceholderHUD dismiss];
    XCTAssertFalse(CYLPlaceholderHUD.isVisible);
    shared.containerView = nil;
}

@end
