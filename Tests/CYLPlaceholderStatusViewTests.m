#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "CYLPlaceholderStatusView.h"
#import "CYLPlaceholderNetworkMonitor.h"
#import "UIViewController+CYLPlaceholderStatus.h"
#import "UITableView+CYLPlaceholder.h"
#import "CYLPlaceholderLocalization.h"
// CYLPlaceholderView is Swift: its interface comes with the umbrella header (the generated Swift header).
#import "CYLTableViewPlaceHolder.h"

/// The monitor's update, called directly: tests cannot switch the device's network.
@interface CYLPlaceholderNetworkMonitor (CYLTesting)
- (void)cyl_setStatus:(CYLPlaceholderNetworkStatus)status constrained:(BOOL)constrained expensive:(BOOL)expensive;
@end

/// The status bar ported from CYLChatKit (CYLPlaceholderStatusView), its network monitor and its display with a placeholder.
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
    // A dictionary literal's commas would split the XCTest macro's arguments, so it is a local.
    NSDictionary *diagonal = @{CYLPlaceholderItemTitle: @"x", CYLPlaceholderItemContentAxis: @"diagonal"};
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:diagonal imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
}

- (UITableViewController *)hostedTableController {
    UITableViewController *controller = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [controller.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    window.rootViewController = navigation;
    window.hidden = NO;
    [window layoutIfNeeded];
    objc_setAssociatedObject(controller, @selector(hostedTableController), window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return controller;
}

- (void)spinMainQueue {
    [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
}

// [EN] Runs the main queue until the condition holds, up to 10 s: a fixed 0.1 s was too short on a busy CI runner
//      (a697ce6: the placeholder was not in the empty table yet; the test took 10.8 s).
// [CN] 运行主队列直到条件成立，最多 10 秒：CI 机器繁忙时固定 0.1 秒太短（a697ce6：占位视图尚未加入空列表，测试用时 10.8 秒）。
- (void)spinMainQueueUntil:(BOOL (^)(void))condition {
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:10];
    do {
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
    } while (!condition() && deadline.timeIntervalSinceNow > 0);
}

- (void)testTheBarAndThePlaceholderAreIndependentAndChosenByOneParameter {
    UITableViewController *controller = [self hostedTableController];
    XCTAssertEqual(controller.cyl_statusDisplay, CYLPlaceholderStatusDisplayPlaceholder, @"nothing changes by default");
    XCTAssertNil(controller.cyl_statusView.superview);
    XCTAssertEqual(controller.cyl_placeholderScrollView, controller.tableView, @"a table view controller's own table");

    controller.cyl_statusDisplay = CYLPlaceholderStatusDisplayAll;
    [controller.view layoutIfNeeded];
    CYLPlaceholderStatusView *bar = controller.cyl_statusView;
    XCTAssertEqual(bar.superview, controller.view, @"added to the controller's view, as CYLChatKit does");
    XCTAssertGreaterThanOrEqual(controller.additionalSafeAreaInsets.top, CYLPlaceholderStatusViewHight,
                                @"the content starts below the bar");
    XCTAssertFalse(controller.tableView.cyl_placeholderHidden);
    XCTAssertEqualWithAccuracy(CGRectGetWidth(bar.bounds), 375, 0.5);

    controller.cyl_statusDisplay = CYLPlaceholderStatusDisplayStatusBar;
    XCTAssertTrue(controller.tableView.cyl_placeholderHidden, @"only the bar");
    XCTAssertNotNil(bar.superview);

    controller.cyl_statusDisplay = CYLPlaceholderStatusDisplayPlaceholder;
    XCTAssertNil(bar.superview, @"only the placeholder");
    XCTAssertEqualWithAccuracy(controller.additionalSafeAreaInsets.top, 0, 0.01, @"the safe area is restored");
    XCTAssertFalse(controller.tableView.cyl_placeholderHidden);

    CYLPlaceholderStatusView *custom = [[CYLPlaceholderStatusView alloc] initWithItemAttributes:@{CYLPlaceholderItemTitle: @"Offline"}
                                                                                         error:NULL];
    controller.cyl_statusDisplay = CYLPlaceholderStatusDisplayAll;
    controller.cyl_statusView = custom;
    XCTAssertEqual(custom.superview, controller.view, @"replaced in place");
    XCTAssertNil(bar.superview);
    controller.cyl_statusView = nil;
    XCTAssertEqualObjects(controller.cyl_statusView.text, @"Network unavailable, Check network", @"nil restores the network bar");
    controller.cyl_statusDisplay = CYLPlaceholderStatusDisplayNone;
    XCTAssertTrue(controller.tableView.cyl_placeholderHidden);
    XCTAssertNil(controller.cyl_statusView.superview);
}

- (void)testAHiddenPlaceholderStaysAwayFromAnEmptyList {
    UITableViewController *controller = [self hostedTableController];
    UITableView *table = controller.tableView;
    UIView *placeholder = [[UIView alloc] init];
    [table cyl_placeholderViewBlock:^UIView *(UITableView *tableView) { return placeholder; }];
    [table reloadData];
    [self spinMainQueueUntil:^BOOL { return placeholder.superview == table; }];
    XCTAssertEqual(placeholder.superview, table, @"an empty list shows its placeholder");
    table.cyl_placeholderHidden = YES;
    [self spinMainQueueUntil:^BOOL { return placeholder.superview == nil; }];
    XCTAssertNil(placeholder.superview);
    table.cyl_placeholderHidden = NO;
    [self spinMainQueueUntil:^BOOL { return placeholder.superview == table; }];
    XCTAssertEqual(placeholder.superview, table);
    [table cyl_placeholderViewBlock:nil];
}

- (void)testTheNetworkMonitorKeepsChatKitsStatusesAndAddsTheBarWhenOffline {
    CYLPlaceholderNetworkMonitor *monitor = [[CYLPlaceholderNetworkMonitor alloc] init];
    XCTAssertEqual(monitor.networkStatus, CYLPlaceholderNetworkStatusUnknown);
    XCTAssertTrue(monitor.isReachable, @"unknown is not offline, so no bar flashes at launch");
    XCTAssertEqual(CYLPlaceholderNetworkStatusNotReachable, 0);
    XCTAssertEqual(CYLPlaceholderNetworkStatusReachableViaWWAN, 1);
    XCTAssertEqual(CYLPlaceholderNetworkStatusReachableViaWiFi, 2);
    __block NSInteger changes = 0;
    [monitor setNetworkStatusChangeBlock:^(CYLPlaceholderNetworkStatus status) { changes++; }];
    [self expectationForNotification:CYLPlaceholderNetworkStatusDidChangeNotification object:monitor handler:nil];
    [monitor cyl_setStatus:CYLPlaceholderNetworkStatusNotReachable constrained:NO expensive:NO];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertFalse(monitor.isReachable);
    XCTAssertEqual(changes, 1);
    [monitor cyl_setStatus:CYLPlaceholderNetworkStatusNotReachable constrained:NO expensive:NO];
    XCTAssertEqual(changes, 1, @"the same status is not reported twice");
    XCTAssertEqualObjects([CYLPlaceholderNetworkMonitor nameForStatus:CYLPlaceholderNetworkStatusReachableViaWiFi], @"Wi-Fi");

    UITableViewController *controller = [self hostedTableController];
    CYLPlaceholderNetworkMonitor *shared = CYLPlaceholderNetworkMonitor.sharedMonitor;
    controller.cyl_showsStatusViewWhenOffline = YES;
    XCTAssertTrue(shared.isMonitoring);
    [shared cyl_setStatus:CYLPlaceholderNetworkStatusNotReachable constrained:NO expensive:NO];
    XCTAssertEqual(controller.cyl_statusView.superview, controller.view, @"offline adds the bar");
    XCTAssertEqual(controller.cyl_statusDisplay, CYLPlaceholderStatusDisplayPlaceholder, @"the chosen display is kept");
    [shared cyl_setStatus:CYLPlaceholderNetworkStatusReachableViaWiFi constrained:NO expensive:NO];
    XCTAssertEqualWithAccuracy(controller.additionalSafeAreaInsets.top, 0, 0.01, @"back online removes it");
    controller.cyl_showsStatusViewWhenOffline = NO;
    [shared stopMonitoring];
    XCTAssertEqual(shared.networkStatus, CYLPlaceholderNetworkStatusUnknown);
}

- (void)testConfigurationFilesChooseTheBarAndTheDisplay {
    NSError *error = nil;
    CYLPlaceholderStatusView *bar = [[CYLPlaceholderStatusView alloc] initWithConfiguration:@{
        @"textKey": @"CYLPlaceholderStatusNetworkUnavailable", @"accessibilityIdentifier": @"bar"} error:&error];
    XCTAssertEqualObjects(bar.text, @"Network unavailable, Check network", @"%@", error);
    XCTAssertNil([[CYLPlaceholderStatusView alloc] initWithConfiguration:@{@"text": @7} error:&error]);

    UITableViewController *controller = [self hostedTableController];
    NSDictionary *statusOnly = @{@"statusBar": @{@"text": @"Server busy"}, @"display": @"status"};
    XCTAssertTrue([controller cyl_applyStatusConfiguration:statusOnly error:&error], @"%@", error);
    XCTAssertEqualObjects(controller.cyl_statusView.text, @"Server busy");
    XCTAssertTrue(controller.tableView.cyl_placeholderHidden);
    XCTAssertTrue([controller cyl_applyStatusConfiguration:@{@"statusBar": @YES} error:&error]);
    XCTAssertEqual(controller.cyl_statusDisplay, CYLPlaceholderStatusDisplayAll, @"a bar without \"display\" shows with the placeholder");
    XCTAssertEqualObjects(controller.cyl_statusView.text, @"Network unavailable, Check network");
    XCTAssertFalse([controller cyl_applyStatusConfiguration:@{@"display": @"banner"} error:&error]);
    XCTAssertEqual(controller.cyl_statusDisplay, CYLPlaceholderStatusDisplayAll, @"an invalid file changes nothing");
    XCTAssertFalse([controller cyl_applyStatusConfiguration:@{@"statusBar": @"red"} error:&error]);
    XCTAssertTrue([controller cyl_applyStatusConfiguration:@{} error:&error]);
    XCTAssertEqual(controller.cyl_statusDisplay, CYLPlaceholderStatusDisplayPlaceholder);
}

- (void)testConfigurationsThatAreNotDictionariesReturnTheConfigurationError {
    // [EN] A configuration read from JSON is `id`: an array or a string returns nil / NO with the configuration error, as
    //      the Objective-C code did, instead of crashing in the Swift bridge (regression of the Swift port a3c02c1).
    // [CN] 从 JSON 读取的配置是 `id`：数组或字符串返回 nil / NO 与配置错误，与原 Objective-C 代码一致，而不是在 Swift 桥接时崩溃
    //      （Swift 迁移 a3c02c1 的回归）。
    UITableViewController *controller = [self hostedTableController];
    for (id configuration in @[@[@{@"text": @"Server busy"}], @"statusBar"]) {
        NSError *error = nil;
        XCTAssertNil([[CYLPlaceholderStatusView alloc] initWithConfiguration:configuration error:&error], @"%@", configuration);
        XCTAssertEqualObjects(error.domain, CYLPlaceholderConfigurationErrorDomain);
        XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorStatusView);
        XCTAssertEqualObjects(error.localizedDescription, @"The status bar configuration must be a dictionary.");

        error = nil;
        XCTAssertNil([[CYLPlaceholderStackView alloc] initWithConfiguration:configuration actions:nil error:&error],
                     @"%@", configuration);
        XCTAssertEqualObjects(error.domain, CYLPlaceholderConfigurationErrorDomain);
        XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorStackView);
        XCTAssertEqualObjects(error.localizedDescription, @"The configuration must be a dictionary.");

        error = nil;
        CYLPlaceholderStatusDisplay display = controller.cyl_statusDisplay;
        XCTAssertFalse([controller cyl_applyStatusConfiguration:configuration error:&error], @"%@", configuration);
        XCTAssertEqualObjects(error.domain, CYLPlaceholderConfigurationErrorDomain);
        XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorStatusConfiguration);
        XCTAssertEqualObjects(error.localizedDescription, @"The configuration must be a dictionary.");
        XCTAssertEqual(controller.cyl_statusDisplay, display, @"nothing changes");
    }
}

@end
