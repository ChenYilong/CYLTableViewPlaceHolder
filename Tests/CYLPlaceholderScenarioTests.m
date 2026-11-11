#import <XCTest/XCTest.h>
#import "CYLPlaceholderStackView.h"
#import "CYLPlaceholderLocalization.h"

/// The stack view's background tap handler, called directly: a hostless test bundle has no UIApplication.
@interface CYLPlaceholderStackView (CYLScenarioTesting)
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
    XCTAssertTrue(view.isTapInteractive, @"a tappable component has its own tap event");
    // The component's own tap, as a finished touch runs it.
    XCTAssertTrue([view performTap]);
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

#pragma mark - Tap interaction, playback and configuration files

- (void)testEachComponentOwnsItsTapEventAndInteractionSwitch {
    __block NSUInteger taps = 0;
    CYLPlaceholderView *view = [[CYLPlaceholderView alloc] initWithStyle:CYLPlaceholderStyleEmpty text:@"Tap"];
    XCTAssertTrue(view.tapInteractionEnabled, @"enabled by default");
    XCTAssertFalse(view.isTapInteractive, @"no handler yet");
    XCTAssertFalse([view performTap]);
    view.tapHandler = ^(CYLPlaceholderView *placeholderView) { taps++; };
    XCTAssertTrue(view.isTapInteractive);
    XCTAssertTrue(view.accessibilityTraits & UIAccessibilityTraitButton);
    // [EN] A touch down highlights; lifting it outside the slop does not tap. [CN] 按下高亮；在容差外抬起不触发点击。
    [view touchesBegan:[NSSet set] withEvent:nil];
    XCTAssertTrue(view.isTapHighlighted);
    [view touchesCancelled:[NSSet set] withEvent:nil];
    XCTAssertFalse(view.isTapHighlighted);
    XCTAssertTrue([view performTap]);
    XCTAssertEqual(taps, 1u);
    // [EN] Interaction off: no handler and no highlight. [CN] 关闭交互：不执行点击事件，也没有高亮。
    view.tapInteractionEnabled = NO;
    XCTAssertFalse([view performTap]);
    [view touchesBegan:[NSSet set] withEvent:nil];
    XCTAssertFalse(view.isTapHighlighted);
    // [EN] A disabled button for VoiceOver, as a disabled UIButton. [CN] 对 VoiceOver 而言是禁用的按钮，与禁用的 UIButton 相同。
    XCTAssertTrue(view.accessibilityTraits & UIAccessibilityTraitButton);
    XCTAssertTrue(view.accessibilityTraits & UIAccessibilityTraitNotEnabled);
    XCTAssertFalse([view accessibilityActivate], @"VoiceOver cannot activate it either");
    XCTAssertEqual(taps, 1u);
    // [EN] Style None: the tap runs without a highlight. [CN] 无高亮样式：点击照常执行，但不高亮。
    view.tapInteractionEnabled = YES;
    XCTAssertFalse(view.accessibilityTraits & UIAccessibilityTraitNotEnabled);
    view.tapHighlightStyle = CYLPlaceholderTapHighlightStyleNone;
    [view touchesBegan:[NSSet set] withEvent:nil];
    XCTAssertFalse(view.isTapHighlighted);
    [view touchesCancelled:[NSSet set] withEvent:nil];
    // [EN] The same switches as item keys. [CN] 同样的开关也可以用 item 键设置。
    CYLPlaceholderView *configured = [[CYLPlaceholderView alloc] initWithItemAttributes:@{
        CYLPlaceholderItemTitle: @"Off", CYLPlaceholderItemInteractionEnabled: @NO,
        CYLPlaceholderItemTapHighlightStyle: @"shrink", CYLPlaceholderItemAnimationRepeatCount: @"loop",
    } imageBundle:nil error:NULL];
    XCTAssertFalse(configured.tapInteractionEnabled);
    XCTAssertEqual(configured.tapHighlightStyle, CYLPlaceholderTapHighlightStyleShrink);
    XCTAssertEqual(configured.animationRepeatCount, 0);
    NSError *error = nil;
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemTapHighlightStyle: @"glow"}
                                                       imageBundle:nil error:&error]);
    XCTAssertNotNil(error);
    XCTAssertNil([[CYLPlaceholderView alloc] initWithItemAttributes:@{CYLPlaceholderItemAnimationRepeatCount: @(-1)}
                                                       imageBundle:nil error:NULL]);
}

- (void)testDisabledComponentKeepsItsActionButDoesNotRunIt {
    __block NSUInteger retries = 0;
    CYLPlaceholderComponent *button = [CYLPlaceholderComponent buttonComponentWithTitle:@"Retry"
        style:CYLPlaceholderButtonStyleFilled action:CYLPlaceholderActionRetry];
    button.interactionEnabled = NO;
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithComponents:@[
        [CYLPlaceholderComponent hintComponentWithText:@"Offline"], button]
        actions:@{CYLPlaceholderActionRetry: ^(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action) {
            retries++;
        }}];
    CYLPlaceholderView *view = [stack componentViewForAction:CYLPlaceholderActionRetry];
    XCTAssertNotNil(view.tapHandler, @"the stack view sets the component's tap event at init");
    XCTAssertFalse(view.isTapInteractive);
    XCTAssertFalse([view performTap]);
    view.tapInteractionEnabled = YES;
    XCTAssertTrue([view performTap]);
    XCTAssertEqual(retries, 1u);
}

- (void)testScenarioIconsLoopByDefault {
    for (NSNumber *value in CYLPlaceholderScenarioCatalog.allScenarios) {
        for (CYLPlaceholderComponent *component in [CYLPlaceholderScenarioCatalog componentsForScenario:value.integerValue]) {
            if (!component.attributes[CYLPlaceholderItemAnimationFilePath]) continue;
            XCTAssertEqual(component.animationRepeatCount, 0, @"scenario %@", value);
        }
    }
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithScenario:CYLPlaceholderScenarioLoading actions:nil];
    XCTAssertEqual(stack.placeholderView.animationRepeatCount, 0);
    stack.placeholderView.animationRepeatCount = 2;
    XCTAssertEqual(stack.placeholderView.animationRepeatCount, 2);
    XCTAssertEqual([CYLPlaceholderComponent hintComponentWithText:@"x"].animationRepeatCount, 1);
}

- (void)testEveryScenarioListsBundledAnimationsInEveryFormat {
    NSMutableSet<NSString *> *formats = [NSMutableSet set];
    for (NSNumber *value in CYLPlaceholderScenarioCatalog.allScenarios) {
        NSArray<NSString *> *names = [CYLPlaceholderScenarioCatalog animationFileNamesForScenario:value.integerValue];
        if (value.integerValue == CYLPlaceholderScenarioTextOnly) {
            XCTAssertEqual(names.count, 0u, @"the text-only scenario has no icon");
            continue;
        }
        XCTAssertGreaterThan(names.count, 0u, @"scenario %@", value);
        for (NSString *name in names) {
            XCTAssertNotNil([CYLPlaceholderView pathForBundledAnimation:name], @"%@", name);
            [formats addObject:name.pathExtension];
        }
    }
    XCTAssertEqualObjects(formats, ([NSSet setWithObjects:@"json", @"pag", @"riv", @"gif", nil]));
}

- (void)testScenarioNamesRoundTrip {
    for (NSNumber *value in CYLPlaceholderScenarioCatalog.allScenarios) {
        NSString *name = [CYLPlaceholderScenarioCatalog nameForScenario:value.integerValue];
        XCTAssertGreaterThan(name.length, 0u);
        XCTAssertEqual([CYLPlaceholderScenarioCatalog scenarioNamed:name], value.integerValue);
        NSString *swift = [[name substringToIndex:1].lowercaseString stringByAppendingString:[name substringFromIndex:1]];
        XCTAssertEqual([CYLPlaceholderScenarioCatalog scenarioNamed:swift], value.integerValue);
        XCTAssertEqual([CYLPlaceholderScenarioCatalog scenarioNamed:[@"CYLPlaceholderScenario" stringByAppendingString:name]],
                       value.integerValue);
    }
    XCTAssertEqual([CYLPlaceholderScenarioCatalog scenarioNamed:@"Nope"], CYLPlaceholderScenarioCount);
    XCTAssertEqualObjects([CYLPlaceholderScenarioCatalog actionNamed:@"contactSupport"], CYLPlaceholderActionContactSupport);
    XCTAssertEqualObjects([CYLPlaceholderScenarioCatalog actionNamed:@"share"], @"share");
}

- (void)testConfigurationBuildsComponentsWithEveryOption {
    __block NSMutableArray<CYLPlaceholderAction> *performed = [NSMutableArray array];
    CYLPlaceholderActionHandler record = ^(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action) {
        [performed addObject:action];
    };
    NSDictionary *configuration = @{
        @"backgroundAction": @"",
        @"components": @[
            @{@"type": @"icon", @"animation": @"CYLPlaceholderNoInternet.json", @"style": @"WifiOff",
              @"titleKey": @"CYLPlaceholderScenarioRetryButtonTitle", @"size": @[@80, @80], @"repeatCount": @"once"},
            @{@"type": @"hint", @"text": @"Literal hint"},
            @{@"type": @"button", @"action": @"retry", @"buttonStyle": @"filled", @"highlightStyle": @"shrink"},
            @{@"type": @"separator"},
            @{@"type": @"button", @"action": @"contactSupport", @"buttonStyle": @"outlined", @"interactionEnabled": @NO},
            @{@"type": @"item", @"attributes": @{CYLPlaceholderItemTitle: @"Raw item"}, @"action": @"share",
              @"accessibilityIdentifier": @"rawItem", @"spacingBefore": @30},
        ],
    };
    NSError *error = nil;
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithConfiguration:configuration
        actions:@{CYLPlaceholderActionRetry: record, CYLPlaceholderActionContactSupport: record, @"share": record}
          error:&error];
    XCTAssertNotNil(stack, @"%@", error);
    XCTAssertEqual(stack.componentViews.count, 6u);
    XCTAssertEqualObjects(stack.placeholderView.textLabel.text, @"The network is slow. Please try again.",
                          @"titleKey reads the core localization");
    XCTAssertEqual(stack.placeholderView.animationRepeatCount, 1);
    XCTAssertEqualObjects(stack.componentViews[1].textLabel.text, @"Literal hint");
    XCTAssertEqualObjects(stack.componentViews[2].textLabel.text, @"Retry", @"a button without a title uses its action's");
    XCTAssertEqual(stack.componentViews[2].tapHighlightStyle, CYLPlaceholderTapHighlightStyleShrink);
    XCTAssertFalse(stack.componentViews[4].isTapInteractive);
    XCTAssertEqualObjects(stack.componentViews[5].accessibilityIdentifier, @"rawItem");
    XCTAssertNil(stack.backgroundAction);
    [self tap:stack.componentViews[2] inStack:stack];
    XCTAssertFalse([stack.componentViews[4] performTap]);
    [self tap:stack.componentViews[5] inStack:stack];
    XCTAssertEqualObjects(performed, (@[CYLPlaceholderActionRetry, @"share"]));
}

- (void)testConfigurationStartsFromAScenarioWithOverridesAndReadsFiles {
    NSDictionary *configuration = @{
        @"scenario": @"retryOrContactSupport",
        @"overrides": @[@{@"index": @3, @"interactionEnabled": @NO}, @{@"index": @0, @"repeatCount": @2}],
    };
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc] initWithConfiguration:configuration actions:nil error:NULL];
    XCTAssertEqual(stack.scenario, CYLPlaceholderScenarioRetryOrContactSupport);
    XCTAssertEqual(stack.componentViews.count, 4u);
    XCTAssertFalse(stack.componentViews[3].tapInteractionEnabled);
    XCTAssertEqual(stack.placeholderView.animationRepeatCount, 2);
    // [EN] The catalog's components are copied, not changed. [CN] 目录中的组件被复制，而不是被修改。
    XCTAssertTrue([CYLPlaceholderScenarioCatalog componentsForScenario:CYLPlaceholderScenarioRetryOrContactSupport][3].interactionEnabled);
    NSString *directory = NSTemporaryDirectory();
    NSURL *json = [NSURL fileURLWithPath:[directory stringByAppendingPathComponent:@"CYLScenarioConfig.json"]];
    [[NSJSONSerialization dataWithJSONObject:@{@"scenario": @"TapToReload"} options:0 error:NULL] writeToURL:json atomically:YES];
    CYLPlaceholderStackView *fromJSON = [[CYLPlaceholderStackView alloc] initWithContentsOfURL:json actions:nil error:NULL];
    XCTAssertEqual(fromJSON.scenario, CYLPlaceholderScenarioTapToReload);
    XCTAssertEqualObjects(fromJSON.backgroundAction, CYLPlaceholderActionRetry, @"the scenario's background action");
    NSURL *plist = [NSURL fileURLWithPath:[directory stringByAppendingPathComponent:@"CYLScenarioConfig.plist"]];
    [@{@"components": @[@{@"type": @"hint", @"text": @"plist"}]} writeToURL:plist atomically:YES];
    CYLPlaceholderStackView *fromPlist = [[CYLPlaceholderStackView alloc] initWithContentsOfURL:plist actions:nil error:NULL];
    XCTAssertEqualObjects(fromPlist.placeholderView.textLabel.text, @"plist");
    for (NSDictionary *invalid in @[@{}, @{@"scenario": @"Nope"}, @{@"components": @[]},
                                    @{@"components": @[@{@"type": @"button"}]},
                                    @{@"components": @[@{@"type": @"icon", @"animation": @"Missing.json"}]},
                                    @{@"scenario": @"TextOnly", @"overrides": @[@{@"index": @9}]},
                                    @{@"components": @[@{@"type": @"hint", @"highlightStyle": @"glow"}]}]) {
        NSError *error = nil;
        XCTAssertNil([[CYLPlaceholderStackView alloc] initWithConfiguration:invalid actions:nil error:&error], @"%@", invalid);
        XCTAssertNotNil(error, @"%@", invalid);
    }
}

#pragma mark - Accessibility and resources

- (void)testComponentsSpeakTextAndControlsAndHideDecorations {
    CYLPlaceholderLocalization.language = @"ja";
    CYLPlaceholderStackView *stack = [[CYLPlaceholderStackView alloc]
        initWithScenario:CYLPlaceholderScenarioIllustrationRetry
                 actions:@{CYLPlaceholderActionRetry: ^(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action) {}}];
    XCTAssertTrue(stack.shouldGroupAccessibilityChildren);
    // [EN] The illustration has no text or action: decorative. [CN] 插图没有文字也没有动作：装饰性内容。
    XCTAssertFalse(stack.placeholderView.isAccessibilityElement);
    XCTAssertTrue(stack.placeholderView.accessibilityElementsHidden);
    CYLPlaceholderView *button = stack.componentViews[1];
    XCTAssertTrue(button.isAccessibilityElement);
    XCTAssertTrue(button.accessibilityTraits & UIAccessibilityTraitButton);
    XCTAssertGreaterThan(button.accessibilityLabel.length, 0u);
    XCTAssertEqualObjects(button.accessibilityLanguage, @"ja", @"VoiceOver pronounces the chosen language");
    // [EN] The separator reads only its word. [CN] 分隔符只朗读文字。
    CYLPlaceholderLocalization.language = @"en";
    CYLPlaceholderStackView *support = [[CYLPlaceholderStackView alloc]
        initWithScenario:CYLPlaceholderScenarioRetryOrContactSupport actions:nil];
    XCTAssertEqualObjects(support.componentViews[2].accessibilityLabel, @"or");
    // [EN] A tap-anywhere scenario's reserved component is a button even without a title.
    // [CN] “点击屏幕重试”场景的保留组件即使没有标题也是按钮。
    CYLPlaceholderStackView *reload = [[CYLPlaceholderStackView alloc] initWithComponents:@[
        [CYLPlaceholderComponent componentWithBundledAnimation:@"CYLPlaceholderRefresh.json"
            fallbackStyle:CYLPlaceholderStyleRefresh title:nil size:CGSizeMake(64, 64) action:nil]] actions:nil];
    XCTAssertTrue(reload.placeholderView.accessibilityElementsHidden);
    reload.backgroundAction = CYLPlaceholderActionRetry;
    XCTAssertFalse(reload.placeholderView.accessibilityElementsHidden);
    XCTAssertEqualObjects(reload.placeholderView.accessibilityLabel, @"Retry");
    XCTAssertTrue(reload.placeholderView.accessibilityTraits & UIAccessibilityTraitButton);
}

- (void)testCoreResourceLookupReadsOnlyTheCoreBundle {
    NSBundle *bundle = CYLPlaceholderResourceBundle();
    XCTAssertNotNil(bundle);
    XCTAssertEqualObjects(bundle.bundleURL.lastPathComponent, @"CYLTableViewPlaceHolder.bundle");
    NSURL *animation = CYLPlaceholderResourceURL(@"Animations/CYLPlaceholderLoading.json");
    XCTAssertNotNil(animation);
    XCTAssertEqualObjects(animation.path, [CYLPlaceholderView pathForBundledAnimation:@"CYLPlaceholderLoading.json"]);
    XCTAssertNotNil(CYLPlaceholderResourceURL(@"en.lproj/Localizable.strings"));
    XCTAssertNil(CYLPlaceholderResourceURL(@"Animations/Missing.json"));
    XCTAssertNil(CYLPlaceholderResourceURL(@"../Info.plist"), @"a path may not leave the bundle");
    XCTAssertNil(CYLPlaceholderResourceURL(@"CYLPlaceholderItemDemo.plist"), @"example data is not in the core bundle");
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
