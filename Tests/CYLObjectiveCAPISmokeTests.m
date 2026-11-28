//
//  CYLObjectiveCAPISmokeTests.m
//  CYLTableViewPlaceHolder tests
//
//  [EN] The one Objective-C test file (owner's decision, 2026-11-20, docs/Swift-Migration.md step 13): every other test
//       is Swift, so this file proves that Objective-C callers still compile against the public API and that it works
//       from Objective-C: each public class through its Objective-C initializers and factories, the categories, the
//       CYLRefresh factories, the variadic shims, the exported constants, the error domain and codes, the dictionary
//       entry points given a wrong type, and the checks only Objective-C can make (exceptions, `id` arguments).
//  [CN] 唯一的 Objective-C 测试文件（所有者 2026-11-20 的决定，docs/Swift-Migration.md 第 13 步）：其余测试都是 Swift，本文件证明
//       Objective-C 调用方仍能针对公开 API 编译并正常使用：各公开类的 Objective-C 初始化方法与工厂方法、分类、CYLRefresh 工厂方法、
//       可变参数兼容方法、导出常量、错误域与错误码、传入错误类型的字典入口，以及只有 Objective-C 能做的检查（异常、`id` 参数）。
//

#import <XCTest/XCTest.h>
#import "CYLTableViewPlaceHolder.h"

/// [EN] A legacy `cyl_reloadData` data source with no rows. [CN] 没有行的旧版 `cyl_reloadData` 数据源。
@interface CYLSmokeRows : NSObject <UITableViewDataSource, UICollectionViewDataSource, CYLTableViewPlaceHolderDelegate>
@property (nonatomic, strong) UIView *legacyView;
@end

@implementation CYLSmokeRows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 0; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { return [UITableViewCell new]; }
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return 0; }
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath { return [UICollectionViewCell new]; }
- (UIView *)makePlaceHolderView { return self.legacyView = [[UIView alloc] init]; }
- (BOOL)enableScrollWhenPlaceHolderViewShowing { return YES; }
@end

@interface CYLObjectiveCAPISmokeTests : XCTestCase
@end

@implementation CYLObjectiveCAPISmokeTests

/// [EN] Runs the main run loop until `condition` holds or 5 s pass. [CN] 运行主 run loop，直到条件成立或 5 秒后。
- (BOOL)waitFor:(BOOL (^)(void))condition {
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:5];
    while (!condition() && deadline.timeIntervalSinceNow > 0) {
        [NSRunLoop.mainRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.02]];
    }
    return condition();
}

- (void)testPlaceholderClassesFromObjectiveC {
    NSError *error = nil;
    CYLPlaceholderView *item = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemTitle: @"Empty", CYLPlaceholderItemStyle: @(CYLPlaceholderStyleInbox)
    } imageBundle:nil error:&error];
    XCTAssertNotNil(item, @"%@", error);
    XCTAssertEqualObjects(item.textLabel.text, @"Empty");
    UIImage *image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleNoInternet];
    CYLPlaceholderView *plain = [[CYLPlaceholderView alloc] initWithImage:image text:@"Offline"];
    XCTAssertEqual(plain.imageView.image, image);
    XCTAssertNotNil([[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleEmpty text:@"None"]);
    XCTAssertNotNil([CYLPlaceholderView pathForBundledAnimation:@"CYLPlaceholderLoading.json"]);
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemTitleColor: @"red"} imageBundle:nil error:&error]);
    XCTAssertEqualObjects(error.domain, CYLPlaceholderConfigurationErrorDomain);
    XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorItemAttributes);

    __block NSUInteger retries = 0;
    CYLPlaceholderStackView *scenario = [[CYLPlaceholderStackView alloc] initWithScenario:CYLPlaceholderScenarioServerError
        actions:@{CYLPlaceholderActionRetry: ^(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action) { retries++; }}];
    [scenario performAction:CYLPlaceholderActionRetry];
    XCTAssertEqual(retries, 1u);
    NSArray<CYLPlaceholderComponent *> *components = @[
        [CYLPlaceholderComponent componentWithBundledAnimation:@"CYLPlaceholderLoading.json" fallbackStyle:CYLPlaceholderStyleEmpty
                                                         title:@"Loading" size:CGSizeMake(80, 80) action:nil],
        [CYLPlaceholderComponent componentWithAttributes:@{CYLPlaceholderItemTitle: @"Title"} action:CYLPlaceholderActionDone],
        [CYLPlaceholderComponent hintComponentWithText:@"Hint"], [CYLPlaceholderComponent separatorComponentWithText:@"or"],
        [CYLPlaceholderComponent textComponentWithText:@"Text" fontSize:15 color:UIColor.grayColor],
        [CYLPlaceholderComponent buttonComponentWithTitle:@"Retry" style:CYLPlaceholderButtonStyleFilled action:CYLPlaceholderActionRetry],
    ];
    XCTAssertEqual([[CYLPlaceholderStackView alloc] initWithComponents:components actions:nil].componentViews.count, 6u);
    CYLPlaceholderStackView *configured = [[CYLPlaceholderStackView alloc] initWithConfiguration:@{
        @"components": @[@{@"type": @"hint", @"text": @"Configured"}]} actions:nil error:&error];
    XCTAssertNotNil(configured, @"%@", error);
    NSURL *missing = [NSURL fileURLWithPath:@"/missing/placeholder.plist"];
    XCTAssertNil([[CYLPlaceholderStackView alloc] initWithContentsOfURL:missing actions:nil error:&error]);
    XCTAssertNotNil(error);

    XCTAssertGreaterThan(CYLPlaceholderScenarioCatalog.allScenarios.count, 0u);
    XCTAssertEqualObjects([CYLPlaceholderScenarioCatalog nameForScenario:CYLPlaceholderScenarioHUD], @"HUD");
    XCTAssertEqual([CYLPlaceholderScenarioCatalog scenarioNamed:@"HUD"], CYLPlaceholderScenarioHUD);
    XCTAssertGreaterThan([CYLPlaceholderScenarioCatalog componentsForScenario:CYLPlaceholderScenarioHUD].count, 0u);

    CYLPlaceholderStatusView *status = [[CYLPlaceholderStatusView alloc] initWithConfiguration:@{@"text": @"Server busy"} error:&error];
    XCTAssertEqualObjects(status.text, @"Server busy", @"%@", error);
    XCTAssertNotNil([[CYLPlaceholderStatusView alloc] initWithItemAttributes:CYLPlaceholderStatusView.networkUnavailableItemAttributes error:&error]);
    XCTAssertEqual(CYLPlaceholderStatusViewHeight, CYLPlaceholderStatusViewHight);
}

/// [EN] An `id` argument of the wrong type returns the configuration error (checked only from Objective-C).
/// [CN] 类型错误的 `id` 参数返回配置错误（只能在 Objective-C 中检查）。
- (void)testDictionaryEntryPointsRejectOtherTypes {
    UIViewController *controller = [UIViewController new];
    for (id configuration in @[@[@{@"text": @"Server busy"}], @"statusBar"]) {
        NSError *error = nil;
        XCTAssertNil([[CYLPlaceholderStatusView alloc] initWithConfiguration:configuration error:&error]);
        XCTAssertEqualObjects(error.domain, CYLPlaceholderConfigurationErrorDomain);
        XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorStatusView);
        XCTAssertEqualObjects(error.localizedDescription, @"The status bar configuration must be a dictionary.");
        error = nil;
        XCTAssertNil([[CYLPlaceholderStackView alloc] initWithConfiguration:configuration actions:nil error:&error]);
        XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorStackView);
        XCTAssertEqualObjects(error.localizedDescription, @"The configuration must be a dictionary.");
        error = nil;
        CYLPlaceholderStatusDisplay display = controller.cyl_statusDisplay;
        XCTAssertFalse([controller cyl_applyStatusConfiguration:configuration error:&error]);
        XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorStatusConfiguration);
        XCTAssertEqualObjects(error.localizedDescription, @"The configuration must be a dictionary.");
        XCTAssertEqual(controller.cyl_statusDisplay, display);
    }
    for (id configuration in @[@[@{@"type": @"hint"}], @"hint"]) {
        NSError *error = nil;
        XCTAssertNil([CYLPlaceholderComponent componentWithDictionary:configuration error:&error]);
        XCTAssertEqual(error.code, CYLPlaceholderConfigurationErrorComponent);
        XCTAssertEqualObjects(error.localizedDescription, @"A component must be a dictionary.");
    }
    NSError *error = nil;
    UITableViewController *tableController = [UITableViewController new];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.rootViewController = tableController;
    window.hidden = NO;
    NSDictionary *statusOnly = @{@"statusBar": @{@"text": @"Server busy"}, @"display": @"status"};
    XCTAssertTrue([tableController cyl_applyStatusConfiguration:statusOnly error:&error], @"%@", error);
    XCTAssertEqualObjects(tableController.cyl_statusView.text, @"Server busy");
    XCTAssertEqual(tableController.cyl_statusDisplay, CYLPlaceholderStatusDisplayStatusBar);
    window.hidden = YES;
}

- (void)testCategoriesHUDLocalizationAndMonitor {
    CYLSmokeRows *rows = [CYLSmokeRows new];
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UITableView *table = [[UITableView alloc] initWithFrame:window.bounds];
    table.dataSource = rows;
    [window addSubview:table];
    UIView *automatic = [UIView new];
    [table cyl_placeholderViewBlock:^UIView *(UITableView *tableView) { return automatic; }];
    [table reloadData];
    XCTAssertTrue([self waitFor:^BOOL { return table.cyl_placeholderView == automatic; }]);
    [table cyl_placeholderViewBlock:nil];
    UITableView *legacy = [[UITableView alloc] initWithFrame:window.bounds];
    legacy.dataSource = rows;
    [window addSubview:legacy];
    [legacy cyl_reloadData];
    XCTAssertTrue([self waitFor:^BOOL { return rows.legacyView.superview != nil; }]);
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:window.bounds
                                                      collectionViewLayout:[UICollectionViewFlowLayout new]];
    collection.dataSource = rows;
    [window addSubview:collection];
    UIView *collectionPlaceholder = [UIView new];
    [collection cyl_placeholderViewBlock:^UIView *(UICollectionView *view) { return collectionPlaceholder; }];
    [collection reloadData];
    XCTAssertTrue([self waitFor:^BOOL { return collection.cyl_placeholderView == collectionPlaceholder; }]);

    UIView *container = [[UIView alloc] initWithFrame:window.bounds];
    [window addSubview:container];
    CYLPlaceholderHUD *hud = [[CYLPlaceholderHUD alloc] initWithContainerView:container];
    hud.fadeInAnimationDuration = 0;
    hud.fadeOutAnimationDuration = 0;
    [hud showWithStatus:@"Loading"];
    XCTAssertTrue(hud.isVisible);
    XCTAssertEqual(hud.state, CYLPlaceholderHUDStateLoading);
    [hud dismiss];
    XCTAssertGreaterThan([CYLPlaceholderHUD displayDurationForString:@"Saved"], 0);
    XCTAssertNotNil(CYLPlaceholderHUD.sharedHUD);
    XCTAssertFalse(CYLPlaceholderHUD.isVisible);
    XCTAssertNotNil(CYLPlaceholderHUDWillAppearNotification);
    XCTAssertNotNil(CYLPlaceholderHUDDidAppearNotification);
    XCTAssertNotNil(CYLPlaceholderHUDWillDisappearNotification);
    XCTAssertNotNil(CYLPlaceholderHUDDidDisappearNotification);
    XCTAssertNotNil(CYLPlaceholderHUDDidReceiveTouchEventNotification);
    XCTAssertNotNil(CYLPlaceholderHUDDidTouchDownInsideNotification);
    XCTAssertNotNil(CYLPlaceholderHUDStatusUserInfoKey);

    CYLPlaceholderLocalization.language = @"ja";
    XCTAssertEqualObjects(CYLPlaceholderLocalizedString(@"CYLPlaceholderScenarioRetryButtonTitle", nil),
                          @"ネットワークが不安定です。もう一度お試しください。");
    XCTAssertEqualObjects([CYLPlaceholderLocalization localizedStringForKey:@"CYLMissingKey" fallback:@"Fallback"], @"Fallback");
    CYLPlaceholderLocalization.language = nil;
    XCTAssertNotNil(CYLPlaceholderResourceBundle());
    XCTAssertNotNil(CYLPlaceholderResourceURL(@"Animations/CYLPlaceholderLoading.json"));
    XCTAssertNotNil(CYLPlaceholderLocalizationLanguageDidChangeNotification);
    XCTAssertGreaterThan(CYLPlaceholderLocalization.supportedLanguages.count, 0u);

    CYLPlaceholderNetworkMonitor *monitor = CYLPlaceholderNetworkMonitor.sharedMonitor;
    XCTAssertNotNil([CYLPlaceholderNetworkMonitor nameForStatus:CYLPlaceholderNetworkStatusReachableViaWiFi]);
    XCTAssertNotNil(CYLPlaceholderNetworkStatusDidChangeNotification);
    (void)monitor.isReachable;

    UIViewController *controller = [UIViewController new];
    controller.cyl_statusDisplay = CYLPlaceholderStatusDisplayAll;
    XCTAssertEqual(controller.cyl_statusDisplay, CYLPlaceholderStatusDisplayAll);
    XCTAssertTrue([CYLPlaceholderActionRetry isKindOfClass:NSString.class]);
    for (CYLPlaceholderAction action in @[CYLPlaceholderActionRetry, CYLPlaceholderActionContactSupport, CYLPlaceholderActionOpenSettings,
                                          CYLPlaceholderActionGoShopping, CYLPlaceholderActionDone, CYLPlaceholderActionChooseManually]) {
        XCTAssertGreaterThan(action.length, 0u);
    }
}

- (void)testEveryRefreshFactoryAndShimFromObjectiveC {
    id target = self;
    SEL action = @selector(description);
    NSArray<CYLRefreshComponent *> *controls = @[
        [CYLRefreshNormalHeader headerWithRefreshingBlock:^{}], [CYLRefreshStateHeader headerWithRefreshingTarget:target refreshingAction:action],
        [CYLRefreshAnimationHeader headerWithRefreshingBlock:^{}], [CYLRefreshGifHeader headerWithRefreshingBlock:^{}],
        [CYLRefreshCupertinoHeader headerWithRefreshingBlock:^{}], [CYLRefreshDropBoxHeader headerWithRefreshingBlock:^{}],
        [CYLRefreshBezierRadarHeader headerWithRefreshingTarget:target refreshingAction:action],
        [CYLRefreshAutoNormalFooter footerWithRefreshingBlock:^{}], [CYLRefreshAutoStateFooter footerWithRefreshingTarget:target refreshingAction:action],
        [CYLRefreshAutoAnimationFooter footerWithRefreshingBlock:^{}], [CYLRefreshAutoGifFooter footerWithRefreshingBlock:^{}],
        [CYLRefreshBackNormalFooter footerWithRefreshingBlock:^{}], [CYLRefreshBackStateFooter footerWithRefreshingBlock:^{}],
        [CYLRefreshBackAnimationFooter footerWithRefreshingBlock:^{}], [CYLRefreshBackGifFooter footerWithRefreshingTarget:target refreshingAction:action],
        [CYLRefreshBallPulseFooter footerWithRefreshingBlock:^{}], [CYLRefreshCupertinoFooter footerWithRefreshingBlock:^{}],
        [CYLRefreshDeliveryFooter footerWithRefreshingBlock:^{}],
        [CYLRefreshNormalTrailer trailerWithRefreshingBlock:^{}], [CYLRefreshStateTrailer trailerWithRefreshingTarget:target refreshingAction:action],
    ];
    for (CYLRefreshComponent *control in controls) XCTAssertEqual(control.state, CYLRefreshStateIdle, @"%@", control.class);

    CYLRefreshNormalHeader *header = (CYLRefreshNormalHeader *)controls[0];
    [header setTitle:@"Pull" forState:CYLRefreshStatePulling];
    XCTAssertEqualObjects([header titleForState:CYLRefreshStatePulling], @"Pull");
    XCTAssertTrue(([header isInPhases:CYLRefreshPhaseFinishing, header.phase, 0]), @"the variadic phase list");
    XCTAssertFalse([header isInPhases:0]);
    CYLRefreshDropBoxHeader *drawn = (CYLRefreshDropBoxHeader *)controls[5];
    XCTAssertTrue(([drawn inStatus:CYLRefreshPhaseFinishing, drawn.status, 0]), @"the variadic status list");
    CYLRefreshAnimationHeader *animated = (CYLRefreshAnimationHeader *)controls[2];
    NSString *gif = [CYLPlaceholderView pathForBundledAnimation:@"CYLRefreshActivity.gif"];
    XCTAssertNotNil(gif);
    XCTAssertEqual([animated setIconAnimationFilePath:gif size:CGSizeMake(24, 24) forState:CYLRefreshStateRefreshing], animated);
    XCTAssertTrue(animated.cyl_usesIconView);
    UIImage *frame = [[[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(10, 10)] imageWithActions:^(UIGraphicsImageRendererContext *c) {}];
    [(CYLRefreshGifHeader *)controls[3] setImages:@[frame, frame] forState:CYLRefreshStateRefreshing];
    XCTAssertNotNil(((CYLRefreshGifHeader *)controls[3]).gifView);

    XCTAssertNotNil(CYLRefreshConfig.defaultConfig);
    XCTAssertGreaterThan(CYLRefreshHeaderHeight, 0);
    XCTAssertGreaterThan(CYLRefreshFooterHeight, 0);
    XCTAssertGreaterThan(CYLRefreshTrailWidth, 0);
    XCTAssertEqualObjects(CYLRefreshKeyPathContentOffset, @"contentOffset");
    XCTAssertNotNil(CYLRefreshHeaderIdleText);
    XCTAssertNotNil(CYLRefreshDidChangeLanguageNotification);
    XCTAssertNoThrow(XCTAssertEqualObjects([NSBundle cyl_localizedStringForKey:@"CYLMissingRefreshKey" value:@"Fallback"], @"Fallback"));

    // [EN] Begin and end with completion blocks, attached to a table in a window. [CN] 在窗口中的表格上带完成回调开始与结束刷新。
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    window.hidden = NO;
    UITableView *table = [[UITableView alloc] initWithFrame:window.bounds];
    [window addSubview:table];
    table.cyl_header = header;
    __block BOOL began = NO, ended = NO;
    [header beginRefreshingWithCompletionBlock:^{ began = YES; }];
    XCTAssertTrue([self waitFor:^BOOL { return began; }]);
    XCTAssertTrue(header.isRefreshing);
    [header endRefreshingWithCompletionBlock:^{ ended = YES; }];
    XCTAssertTrue([self waitFor:^BOOL { return ended && header.state == CYLRefreshStateIdle; }]);

    // [EN] Objective-C exceptions (KVO "not registered as an observer") when a control moves between views.
    // [CN] 控件在视图间移动时不抛出 Objective-C 异常（KVO "not registered as an observer"）。
    CYLRefreshComponent *component = [CYLRefreshComponent new];
    UIView *container = [UIView new];
    XCTAssertNoThrow([container addSubview:component]);
    XCTAssertNoThrow([table addSubview:component]);
    XCTAssertEqual(component.scrollView, table);
    XCTAssertNoThrow([container addSubview:component]);
    XCTAssertNil(component.scrollView);
    XCTAssertNoThrow([table addSubview:component]);
    XCTAssertNoThrow([component removeFromSuperview]);
    XCTAssertNoThrow([table removeFromSuperview]);
    window.hidden = YES;
}

@end
