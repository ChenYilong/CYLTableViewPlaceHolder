#import <XCTest/XCTest.h>
#import "CYLPlaceholderStackView.h"
#import "CYLPlaceholderLocalization.h"

/// The stack view's tap handlers, called directly: a hostless test bundle has no UIApplication to send actions.
@interface CYLPlaceholderStackView (CYLScenarioTesting)
- (void)cyl_componentTapped:(UITapGestureRecognizer *)recognizer;
- (void)cyl_backgroundTapped:(UITapGestureRecognizer *)recognizer;
@end

/// Scenarios (CYLPlaceholderScenario), the stack of components (CYLPlaceholderStackView), the title chrome of
/// CYLPlaceholderView, and the core localization with its run-time language.
@interface CYLPlaceholderScenarioTests : XCTestCase
@end

@implementation CYLPlaceholderScenarioTests

- (void)setUp {
    [super setUp];
    CYLPlaceholderLocalization.language = @"en";
}

- (void)tearDown {
    CYLPlaceholderLocalization.language = nil;
    [super tearDown];
}

- (UIWindow *)windowHosting:(UIView *)view {
    UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    view.frame = window.bounds;
    [window addSubview:view];
    [window layoutIfNeeded];
    return window;
}

- (void)tap:(CYLPlaceholderView *)view inStack:(CYLPlaceholderStackView *)stack {
    UITapGestureRecognizer *tap = nil;
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        if ([recognizer isKindOfClass:UITapGestureRecognizer.class]) tap = (UITapGestureRecognizer *)recognizer;
    }
    XCTAssertNotNil(tap, @"a tappable component has a tap recognizer");
    // The recognizer's action, as UIKit calls it.
    [stack cyl_componentTapped:tap];
}

#pragma mark - Scenarios

- (void)testEveryScenarioBuildsAllItsComponentsWithTheReservedOneFirst {
    XCTAssertEqual(CYLPlaceholderScenarioCatalog.allScenarios.count, (NSUInteger)CYLPlaceholderScenarioCount);
    for (NSNumber *value in CYLPlaceholderScenarioCatalog.allScenarios) {
        CYLPlaceholderScenario scenario = value.integerValue;
        NSArray<CYLPlaceholderComponent *> *components = [CYLPlaceholderScenarioCatalog componentsForScenario:scenario];
        XCTAssertGreaterThan(components.count, 0u, @"scenario %ld", (long)scenario);
        CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithScenario:scenario actions:nil];
        // Every component's attributes are valid: none is dropped.
        XCTAssertEqual(stack.componentViews.count, components.count, @"scenario %ld", (long)scenario);
        XCTAssertEqual(stack.stackView.arrangedSubviews.count, components.count);
        XCTAssertEqual(stack.placeholderView, stack.componentViews.firstObject);
        XCTAssertEqual(stack.scenario, scenario);
        XCTAssertTrue([CYLPlaceholderScenarioCatalog localizedNameForScenario:scenario].length > 0);
        for (CYLPlaceholderView *component in stack.componentViews) {
            XCTAssertTrue(component.reportsContentSize, @"the stack sizes its components by their content");
        }
    }
}

- (void)testEveryReadmeScreenshotMapsToExactlyOneScenario {
    NSMutableArray<NSNumber *> *numbers = [NSMutableArray array];
    for (NSNumber *value in CYLPlaceholderScenarioCatalog.allScenarios) {
        [numbers addObjectsFromArray:[CYLPlaceholderScenarioCatalog readmeScreenshotNumbersForScenario:value.integerValue]];
    }
    XCTAssertEqual(numbers.count, 43u, @"README has 43 scenario screenshots");
    XCTAssertEqual([NSSet setWithArray:numbers].count, 43u, @"no screenshot is mapped twice");
    for (NSInteger number = 1; number <= 43; number++) XCTAssertTrue([numbers containsObject:@(number)], @"#%ld", (long)number);
}

- (void)testMostScenariosUseAnAnimatedIcon {
    NSUInteger animated = 0;
    for (NSNumber *value in CYLPlaceholderScenarioCatalog.allScenarios) {
        for (CYLPlaceholderComponent *component in [CYLPlaceholderScenarioCatalog componentsForScenario:value.integerValue]) {
            if (component.attributes[CYLPlaceholderItemAnimationFilePath]) { animated++; break; }
        }
    }
    // Only the text-only scenario (README #30, #41) has no icon at all.
    XCTAssertGreaterThan((double)animated / CYLPlaceholderScenarioCount, 0.9);
}

- (void)testRetryOrContactSupportStacksFourComponentsWithTwoActions {
    __block NSMutableArray<CYLPlaceholderAction> *performed = [NSMutableArray array];
    CYLPlaceholderActionHandler record = ^(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action) {
        [performed addObject:action];
    };
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc]
        initWithScenario:CYLPlaceholderScenarioRetryOrContactSupport
                 actions:@{CYLPlaceholderActionRetry: record, CYLPlaceholderActionContactSupport: record}];
    UIWindow *window = [self windowHosting:stack];
    XCTAssertEqual(stack.componentViews.count, 4u);
    XCTAssertEqualObjects(stack.componentViews[1].textLabel.text, @"Retry");
    XCTAssertTrue([stack.componentViews[2].textLabel.text containsString:@"or"]);
    XCTAssertEqualObjects(stack.componentViews[3].textLabel.text, @"Contact support");
    XCTAssertEqual([stack componentViewForAction:CYLPlaceholderActionRetry], stack.componentViews[1]);
    XCTAssertEqual([stack componentViewForAction:CYLPlaceholderActionContactSupport], stack.componentViews[3]);
    XCTAssertTrue(stack.componentViews[1].accessibilityTraits & UIAccessibilityTraitButton);
    XCTAssertFalse(stack.componentViews[2].accessibilityTraits & UIAccessibilityTraitButton, @"the separator is not tappable");
    [self tap:stack.componentViews[1] inStack:stack];
    [self tap:stack.componentViews[3] inStack:stack];
    XCTAssertEqualObjects(performed, (@[CYLPlaceholderActionRetry, CYLPlaceholderActionContactSupport]));
    // Components are laid out top to bottom.
    for (NSUInteger index = 1; index < stack.componentViews.count; index++) {
        XCTAssertGreaterThanOrEqual(CGRectGetMinY(stack.componentViews[index].frame),
                                    CGRectGetMaxY(stack.componentViews[index - 1].frame) - 0.5);
    }
    window.hidden = YES;
}

- (void)testIllustrationRetryShowsAnIconThenACapsuleTitleWithABackgroundImage {
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithScenario:CYLPlaceholderScenarioIllustrationRetry
                                                                              actions:nil];
    UIWindow *window = [self windowHosting:stack];
    XCTAssertEqual(stack.componentViews.count, 2u);
    XCTAssertTrue(stack.placeholderView.textLabel.hidden, @"the first component shows only the icon");
    CYLPlaceholderView *button = stack.componentViews[1];
    XCTAssertEqualObjects(button.textLabel.text, @"Tap to retry");
    XCTAssertTrue([button.itemAttributes[CYLPlaceholderItemTitleBackgroundImage] isKindOfClass:UIImage.class]);
    XCTAssertGreaterThan([button.itemAttributes[CYLPlaceholderItemTitleCornerRadius] doubleValue], 100);
    // The padding around the title makes the button taller than its text.
    XCTAssertGreaterThanOrEqual(CGRectGetHeight(button.bounds), CGRectGetHeight(button.textLabel.bounds) + 20 - 0.5);
    XCTAssertFalse([stack performAction:CYLPlaceholderActionRetry], @"no handler was given");
    window.hidden = YES;
}

- (void)testTapAnywhereScenariosHaveABackgroundAction {
    __block NSUInteger retries = 0;
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithScenario:CYLPlaceholderScenarioTapToReload
        actions:@{CYLPlaceholderActionRetry: ^(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action) {
            retries++;
        }}];
    XCTAssertEqualObjects(stack.backgroundAction, CYLPlaceholderActionRetry);
    [stack cyl_backgroundTapped:nil];
    XCTAssertEqual(retries, 1u);
    XCTAssertTrue(stack.placeholderView.accessibilityTraits & UIAccessibilityTraitButton);
    stack.backgroundAction = nil;
    XCTAssertFalse(stack.placeholderView.accessibilityTraits & UIAccessibilityTraitButton);
    XCTAssertNil([CYLPlaceholderScenarioCatalog backgroundActionForScenario:CYLPlaceholderScenarioRetryButton]);
}

- (void)testCustomComponentsAndHandlersCanBeAddedLater {
    CYLPlaceholderComponent *reserved = [CYLPlaceholderComponent componentWithBundledAnimation:@"CYLPlaceholderNoInternet.json"
        fallbackStyle:CYLPlaceholderStyleWifiOff title:@"Offline" size:CGSizeMake(80, 80) action:nil];
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithComponents:@[reserved] actions:nil];
    XCTAssertEqual(stack.scenario, CYLPlaceholderScenarioCount);
    XCTAssertEqualObjects(stack.placeholderView.textLabel.text, @"Offline");
    CYLPlaceholderAction share = @"Share";
    CYLPlaceholderView *button = [stack appendComponent:[CYLPlaceholderComponent buttonComponentWithTitle:@"Share"
        style:CYLPlaceholderButtonStyleOutlined action:share]];
    XCTAssertNotNil(button);
    XCTAssertEqual(stack.componentViews.count, 2u);
    __block BOOL shared = NO;
    [stack setHandler:^(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action) { shared = YES; } forAction:share];
    [self tap:button inStack:stack];
    XCTAssertTrue(shared);
    XCTAssertNil([stack appendComponent:[CYLPlaceholderComponent componentWithAttributes:@{CYLPlaceholderItemTitleBorderWidth: @(-1)}
                                                                                 action:nil]],
                 @"invalid attributes are rejected");
    XCTAssertEqual(stack.componentViews.count, 2u);
    // An empty list still gives the reserved component.
    CYLPlaceholderStackView *empty = [[CYLPlaceholderStackView alloc] initWithComponents:@[] actions:nil];
    XCTAssertNotNil(empty.placeholderView);
    XCTAssertEqual(empty.componentViews.count, 1u);
}

#pragma mark - Title chrome and content size

- (void)testContentSizeIsOptInAndIncludesTheTitlePadding {
    CYLPlaceholderView *plain = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleEmpty message:CYLPlaceholderMessageEmpty];
    XCTAssertEqual(plain.intrinsicContentSize.height, UIViewNoIntrinsicMetric, @"off by default: the view fills its frame");
    UIFont *font = [UIFont systemFontOfSize:17];
    NSError *error = nil;
    CYLPlaceholderView *button = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemTitle: @"Retry", CYLPlaceholderItemTitleFont: font,
        CYLPlaceholderItemTitleBackgroundColor: @"#007AFF", CYLPlaceholderItemTitleCornerRadius: @6,
        CYLPlaceholderItemTitleContentInsets: @[@10, @20, @10, @20],
    } imageBundle:nil error:&error];
    XCTAssertNotNil(button, @"%@", error);
    button.reportsContentSize = YES;
    CGFloat lineHeight = ceil([@"Retry" boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX)
        options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size.height);
    XCTAssertEqualWithAccuracy(button.intrinsicContentSize.height, lineHeight + 20, 0.5);
    button.frame = CGRectMake(0, 0, 300, button.intrinsicContentSize.height);
    [button layoutIfNeeded];
    [button.subviews.firstObject layoutIfNeeded];
    // The title sits inside its padding.
    XCTAssertEqualWithAccuracy(CGRectGetMinY([button convertRect:button.textLabel.bounds fromView:button.textLabel]), 10, 0.5);
}

- (void)testInvalidTitleChromeIsRejected {
    for (NSDictionary *attributes in @[
        @{CYLPlaceholderItemTitle: @"A", CYLPlaceholderItemTitleBorderWidth: @"thick"},
        @{CYLPlaceholderItemTitle: @"A", CYLPlaceholderItemTitleCornerRadius: @(-2)},
        @{CYLPlaceholderItemTitle: @"A", CYLPlaceholderItemTitleContentInsets: @[@-1, @0, @0, @0]},
        @{CYLPlaceholderItemTitle: @"A", CYLPlaceholderItemTitleBorderColor: @"blue"},
        @{CYLPlaceholderItemTitle: @"A", CYLPlaceholderItemTitleBackgroundImage: @"NoSuchImage"},
    ]) {
        NSError *error = nil;
        XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:attributes imageBundle:nil error:&error], @"%@", attributes);
        XCTAssertNotNil(error);
    }
}

#pragma mark - Localization

- (void)testRunTimeLanguageChangesCoreTexts {
    XCTAssertEqualObjects(CYLPlaceholderLocalization.effectiveLanguage, @"en");
    [self expectationForNotification:CYLPlaceholderLocalizationLanguageDidChangeNotification object:nil handler:nil];
    CYLPlaceholderLocalization.language = @"zh-Hans";
    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertEqualObjects([CYLPlaceholderView localizedTextForMessage:CYLPlaceholderMessageEmpty], @"暂无内容");
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithScenario:CYLPlaceholderScenarioRetryButton
                                                                              actions:nil];
    XCTAssertEqualObjects(stack.placeholderView.textLabel.text, @"网络不给力，请再试试吧。");
    XCTAssertEqualObjects(stack.componentViews[1].textLabel.text, @"重试");
    CYLPlaceholderLocalization.language = @"ja";
    XCTAssertEqualObjects(CYLPlaceholderLocalizedString(@"CYLPlaceholderScenarioRetryButtonTitle", nil),
                          @"ネットワークが不安定です。もう一度お試しください。");
    XCTAssertEqualObjects(CYLPlaceholderLocalizedStringForKey(@"NoSuchKey", @"fallback"), @"fallback");
    XCTAssertEqualObjects(CYLPlaceholderLocalizedStringForKey(@"NoSuchKey", nil), @"NoSuchKey");
}

- (void)testUnsupportedLanguagesFallBack {
    NSDictionary<NSString *, NSString *> *expected = @{@"zh-HK": @"zh-Hant", @"zh-Hant-TW": @"zh-Hant", @"zh-CN": @"zh-Hans",
                                                       @"ja-JP": @"ja", @"ko_KR": @"ko", @"pt-BR": @"en", @"uk": @"uk"};
    [expected enumerateKeysAndObjectsUsingBlock:^(NSString *requested, NSString *effective, BOOL *stop) {
        CYLPlaceholderLocalization.language = requested;
        XCTAssertEqualObjects(CYLPlaceholderLocalization.effectiveLanguage, effective, @"%@", requested);
    }];
    CYLPlaceholderLocalization.language = nil;
    XCTAssertTrue([CYLPlaceholderLocalization.supportedLanguages containsObject:CYLPlaceholderLocalization.effectiveLanguage]);
}

- (void)testPermissionScenariosAreTheirOwnCategoryAndOfferSettings {
    // [EN] A missing permission is not a network failure: its own category, an icon of its own, "Open Settings".
    // [CN] 权限缺失不是网络失败：有自己的类别和图标，并提供“去设置”。
    XCTAssertEqual([CYLPlaceholderScenarioCatalog categoryForScenario:CYLPlaceholderScenarioRetryButton],
                   CYLPlaceholderScenarioCategoryLoadFailed);
    XCTAssertEqual([CYLPlaceholderScenarioCatalog categoryForScenario:CYLPlaceholderScenarioNoContent],
                   CYLPlaceholderScenarioCategoryEmpty);
    XCTAssertEqual([CYLPlaceholderScenarioCatalog scenarioForPermission:CYLPlaceholderPermissionNone],
                   CYLPlaceholderScenarioNoPermission);
    NSMutableSet<NSString *> *icons = [NSMutableSet set];
    NSInteger permissions = 0;
    for (NSInteger permission = CYLPlaceholderPermissionLocation; permission <= CYLPlaceholderPermissionNotifications;
         permission++) {
        CYLPlaceholderScenario scenario = [CYLPlaceholderScenarioCatalog scenarioForPermission:permission];
        XCTAssertNotEqual(scenario, CYLPlaceholderScenarioNoPermission, @"%ld", (long)permission);
        XCTAssertEqual([CYLPlaceholderScenarioCatalog permissionForScenario:scenario], permission);
        XCTAssertEqual([CYLPlaceholderScenarioCatalog categoryForScenario:scenario], CYLPlaceholderScenarioCategoryPermission);
        NSArray<CYLPlaceholderComponent *> *components = [CYLPlaceholderScenarioCatalog componentsForScenario:scenario];
        XCTAssertGreaterThanOrEqual(components.count, 3u);
        NSString *path = components.firstObject.attributes[CYLPlaceholderItemAnimationFilePath];
        XCTAssertTrue([path.lastPathComponent hasSuffix:@"Permission.json"], @"%@", path);
        if (path) [icons addObject:path.lastPathComponent];
        XCTAssertGreaterThan([components.firstObject.attributes[CYLPlaceholderItemTitle] length], 0u);
        XCTAssertGreaterThan([components[1].attributes[CYLPlaceholderItemTitle] length], 0u);
        XCTAssertEqualObjects(components[2].action, CYLPlaceholderActionOpenSettings);
        permissions++;
    }
    XCTAssertEqual(permissions, 8);
    XCTAssertEqual(icons.count, 8u, @"every permission has its own icon: %@", icons);
    // [EN] README #20: location also offers to choose an address by hand.
    // [CN] README #20：定位还提供手动选择地址。
    NSArray<CYLPlaceholderComponent *> *location =
        [CYLPlaceholderScenarioCatalog componentsForScenario:CYLPlaceholderScenarioLocationPermissionDenied];
    XCTAssertEqualObjects(location.lastObject.action, CYLPlaceholderActionChooseManually);
    XCTAssertEqualObjects([CYLPlaceholderScenarioCatalog readmeScreenshotNumbersForScenario:
                              CYLPlaceholderScenarioLocationPermissionDenied], @[@20]);
}

- (void)testEveryScenarioIsTranslated {
    NSMutableArray<NSString *> *english = [NSMutableArray array];
    for (NSNumber *value in CYLPlaceholderScenarioCatalog.allScenarios) {
        for (CYLPlaceholderComponent *component in [CYLPlaceholderScenarioCatalog componentsForScenario:value.integerValue]) {
            [english addObject:component.attributes[CYLPlaceholderItemTitle] ?: @""];
        }
        [english addObject:[CYLPlaceholderScenarioCatalog localizedNameForScenario:value.integerValue]];
    }
    for (NSString *language in @[@"zh-Hans", @"zh-Hant", @"ja", @"ko", @"ru", @"uk"]) {
        CYLPlaceholderLocalization.language = language;
        NSUInteger index = 0;
        for (NSNumber *value in CYLPlaceholderScenarioCatalog.allScenarios) {
            for (CYLPlaceholderComponent *component in [CYLPlaceholderScenarioCatalog componentsForScenario:value.integerValue]) {
                NSString *text = component.attributes[CYLPlaceholderItemTitle] ?: @"";
                if (text.length) XCTAssertNotEqualObjects(text, english[index], @"%@ in %@", english[index], language);
                index++;
            }
            XCTAssertNotEqualObjects([CYLPlaceholderScenarioCatalog localizedNameForScenario:value.integerValue],
                                     english[index], @"%@ in %@", english[index], language);
            index++;
        }
    }
}

@end
