#import <XCTest/XCTest.h>
#import "CYLPlaceholderStackView.h"
#import "CYLPlaceholderStatusView.h"
#import "CYLPlaceholderLocalization.h"

/// The status bar ported from CYLChatKit (CYLPlaceholderStatusView) and its combinations with CYLPlaceholderStackView.
@interface CYLPlaceholderStatusViewTests : XCTestCase <CYLPlaceholderStatusViewDelegate>
@property (nonatomic) NSInteger clicks;
@end

@implementation CYLPlaceholderStatusViewTests

- (void)setUp {
    [super setUp];
    CYLPlaceholderLocalization.language = @"en";
    self.clicks = 0;
}

- (void)tearDown {
    CYLPlaceholderLocalization.language = nil;
    [super tearDown];
}

- (void)statusViewClicked:(id)sender {
    XCTAssertTrue([sender isKindOfClass:CYLPlaceholderStatusView.class]);
    self.clicks++;
}

- (UIWindow *)windowHosting:(UIView *)view {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    view.frame = window.bounds;
    [window addSubview:view];
    [window layoutIfNeeded];
    return window;
}

- (void)testTheNetworkBarKeepsChatKitsAPIAndDrawsTheIconBeforeTheTitle {
    XCTAssertEqualWithAccuracy(CYLPlaceholderStatusViewHight, 44, 0.01);
    XCTAssertEqualWithAccuracy(CYLPlaceholderStatusViewHeight, CYLPlaceholderStatusViewHight, 0.01);
    CYLPlaceholderStatusView *bar = [[CYLPlaceholderStatusView alloc] initWithFrame:CGRectMake(0, 0, 375, CYLPlaceholderStatusViewHight)];
    XCTAssertEqualObjects(bar.text, @"Network unavailable, Check network");
    XCTAssertNotNil(bar.placeholderView.imageView.image, @"the ChatKit icon is in the core bundle");
    XCTAssertEqualObjects(bar.placeholderView.backgroundColor, UIColor.clearColor, @"the red is the parent's");
    XCTAssertNotNil(bar.backgroundColor);
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    [window addSubview:bar];
    [bar layoutIfNeeded];
    [bar.placeholderView layoutIfNeeded];
    CGRect icon = [bar convertRect:bar.placeholderView.imageView.frame fromView:bar.placeholderView.imageView.superview];
    CGRect title = [bar convertRect:bar.placeholderView.textLabel.frame fromView:bar.placeholderView.textLabel.superview];
    XCTAssertEqualWithAccuracy(CGRectGetWidth(icon), 20, 0.5, @"drawn at 20 points, as ChatKit");
    XCTAssertLessThanOrEqual(CGRectGetMaxX(icon), CGRectGetMinX(title), @"the title follows the icon");
    XCTAssertEqualWithAccuracy(CGRectGetMidY(icon), CGRectGetMidY(bar.bounds), 1);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(title), CGRectGetMidY(bar.bounds), 1);
    XCTAssertLessThan(CGRectGetMinX(icon), 40, @"aligned to the leading edge");
    XCTAssertGreaterThanOrEqual(bar.intrinsicContentSize.height, CYLPlaceholderStatusViewHight);
}

- (void)testTapsReachTheDelegateAndHandlerAndOnlyThenMakeAButton {
    CYLPlaceholderStatusView *bar = [[CYLPlaceholderStatusView alloc] initWithFrame:CGRectZero];
    XCTAssertFalse(bar.placeholderView.isTapInteractive, @"nobody listens: plain text");
    bar.delegate = self;
    XCTAssertTrue(bar.placeholderView.isTapInteractive);
    __block NSInteger handled = 0;
    bar.tapHandler = ^(CYLPlaceholderStatusView *statusView) { handled++; };
    XCTAssertTrue([bar.placeholderView performTap]);
    XCTAssertEqual(self.clicks, 1);
    XCTAssertEqual(handled, 1);
    bar.text = @"Reconnecting…";
    XCTAssertEqualObjects(bar.placeholderView.textLabel.text, @"Reconnecting…");
}

- (void)testCustomAttributesKeepTheHorizontalLayoutAndRejectBadValues {
    NSError *error = nil;
    CYLPlaceholderStatusView *bar = [[CYLPlaceholderStatusView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemTitle: @"Offline mode",
        CYLPlaceholderItemBackgroundColor: UIColor.orangeColor,
    } error:&error];
    XCTAssertNotNil(bar, @"%@", error);
    XCTAssertEqualObjects(bar.backgroundColor, UIColor.orangeColor);
    XCTAssertEqualObjects(bar.text, @"Offline mode");
    XCTAssertNotNil(bar.placeholderView.imageView.image, @"the failure icon stays without a custom image");
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemTitle: @"x",
                                                                      CYLPlaceholderItemContentAxis: @"diagonal"}
                                                        imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
}

- (void)testTheStackShowsTheBarThePlaceholderOrBoth {
    CYLPlaceholderStackView *both = [[CYLPlaceholderStackView alloc] initWithScenario:CYLPlaceholderScenarioNetworkUnavailable actions:nil];
    both.statusView = [[CYLPlaceholderStatusView alloc] initWithFrame:CGRectZero];
    UIWindow *window = [self windowHosting:both];
    CGRect bar = both.statusView.frame;
    XCTAssertEqualWithAccuracy(CGRectGetMinY(bar), 0, 0.5, @"pinned to the top");
    XCTAssertEqualWithAccuracy(CGRectGetWidth(bar), 375, 0.5, @"full width");
    XCTAssertGreaterThanOrEqual(CGRectGetMinY(both.stackView.frame), CGRectGetMaxY(bar), @"the components sit below it");
    XCTAssertFalse(both.stackView.hidden);

    both.componentsHidden = YES;
    XCTAssertTrue(both.stackView.hidden, @"only the bar");
    XCTAssertEqualObjects(both.accessibilityElements, @[both.statusView]);
    both.statusView = nil;
    both.componentsHidden = NO;
    [window layoutIfNeeded];
    XCTAssertNil(both.statusView.superview, @"only the placeholder");
    XCTAssertNil(both.accessibilityElements);

    CYLPlaceholderStackView *statusOnly = [[CYLPlaceholderStackView alloc] initWithStatusView:[[CYLPlaceholderStatusView alloc] initWithFrame:CGRectZero]];
    XCTAssertTrue(statusOnly.componentsHidden);
    XCTAssertNotNil(statusOnly.statusView.superview);
    (void)window;
}

- (void)testConfigurationFilesChooseTheCombination {
    NSError *error = nil;
    CYLPlaceholderStackView *both = [[CYLPlaceholderStackView alloc] initWithConfiguration:@{
        @"scenario": @"NetworkUnavailable", @"statusBar": @YES} actions:nil error:&error];
    XCTAssertNotNil(both.statusView, @"%@", error);
    XCTAssertFalse(both.componentsHidden);

    CYLPlaceholderStackView *statusOnly = [[CYLPlaceholderStackView alloc] initWithConfiguration:@{@"display": @"status"}
                                                                                         actions:nil error:&error];
    XCTAssertEqualObjects(statusOnly.statusView.text, @"Network unavailable, Check network", @"%@", error);
    XCTAssertTrue(statusOnly.componentsHidden);

    CYLPlaceholderStackView *placeholderOnly = [[CYLPlaceholderStackView alloc] initWithConfiguration:@{
        @"scenario": @"NetworkUnavailable", @"statusBar": @YES, @"display": @"placeholder"} actions:nil error:&error];
    XCTAssertNil(placeholderOnly.statusView);

    __block NSInteger retries = 0;
    CYLPlaceholderStackView *custom = [[CYLPlaceholderStackView alloc] initWithConfiguration:@{
        @"scenario": @"NetworkUnavailable",
        @"statusBar": @{@"text": @"Server busy", @"action": @"retry", @"accessibilityIdentifier": @"busyBar"},
    } actions:@{CYLPlaceholderActionRetry: ^(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action) { retries++; }}
                                                                                       error:&error];
    XCTAssertEqualObjects(custom.statusView.text, @"Server busy", @"%@", error);
    XCTAssertTrue([custom.statusView.placeholderView performTap]);
    XCTAssertEqual(retries, 1, @"a tap on the bar runs its action");

    XCTAssertNil([[CYLPlaceholderStackView alloc] initWithConfiguration:@{@"display": @"banner"} actions:nil error:&error]);
    XCTAssertNil([[CYLPlaceholderStackView alloc] initWithConfiguration:@{@"statusBar": @42} actions:nil error:&error]);
    XCTAssertNil([[CYLPlaceholderStackView alloc] initWithConfiguration:@{@"statusBar": @{@"text": @7}} actions:nil error:&error]);
}

@end
