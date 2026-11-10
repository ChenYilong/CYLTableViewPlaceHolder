//
//  CYLPlaceholderScenario.m
//  CYLTableViewPlaceHolder
//

#import "CYLPlaceholderScenario.h"
#import "CYLPlaceholderLocalization.h"

CYLPlaceholderAction const CYLPlaceholderActionRetry = @"CYLPlaceholderActionRetry";
CYLPlaceholderAction const CYLPlaceholderActionContactSupport = @"CYLPlaceholderActionContactSupport";
CYLPlaceholderAction const CYLPlaceholderActionOpenSettings = @"CYLPlaceholderActionOpenSettings";
CYLPlaceholderAction const CYLPlaceholderActionGoShopping = @"CYLPlaceholderActionGoShopping";
CYLPlaceholderAction const CYLPlaceholderActionDone = @"CYLPlaceholderActionDone";

#pragma mark - Look

static UIColor *CYLScenarioAccentColor(void) {
    if (@available(iOS 13.0, *)) return UIColor.systemBlueColor;
    return [UIColor colorWithRed:0 green:122.0 / 255 blue:1 alpha:1];
}

static UIColor *CYLScenarioSecondaryTextColor(void) {
    if (@available(iOS 13.0, *)) return UIColor.secondaryLabelColor;
    return UIColor.grayColor;
}

static UIColor *CYLScenarioLineIconColor(void) {
    // [EN] A middle gray reads on light and dark backgrounds; Lottie takes the color once, when it is set.
    // [CN] 中灰色在浅色和深色背景上都清晰；Lottie 在设置时读取一次颜色。
    return [UIColor colorWithWhite:0.6 alpha:1];
}

static UIFont *CYLScenarioFont(UIFontTextStyle style, CGFloat size, UIFontWeight weight) {
    return [[UIFontMetrics metricsForTextStyle:style] scaledFontForFont:[UIFont systemFontOfSize:size weight:weight]];
}

/// The capsule button's background image: a red-to-orange gradient, drawn once.
static UIImage *CYLScenarioCapsuleBackgroundImage(void) {
    static UIImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(160, 44);
        UIColor *start = [UIColor colorWithRed:1 green:0.45 blue:0.35 alpha:1];
        UIColor *end = [UIColor colorWithRed:0.92 green:0.2 blue:0.27 alpha:1];
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
        image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
            NSArray *colors = @[(__bridge id)start.CGColor, (__bridge id)end.CGColor];
            CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
            CGContextDrawLinearGradient(context.CGContext, gradient, CGPointZero, CGPointMake(size.width, 0), 0);
            CGGradientRelease(gradient);
            CGColorSpaceRelease(space);
        }];
    });
    return image;
}

#pragma mark - Bundled animations

/// Options some bundled Rive files need to play (the same as the aggregate demo used before).
static NSDictionary<NSString *, NSString *> *CYLScenarioAnimationOptions(NSString *fileName) {
    static NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *options;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *legacy = @{@"legacy": @"1"};
        options = @{
            @"CYLPlaceholderLoading.riv": legacy,
            @"CYLPlaceholderPullToRefresh.riv": legacy,
            @"CYLPlaceholderNoOrders.riv": legacy,
            @"CYLPlaceholderNoReviews.riv": legacy,
            @"CYLPlaceholderSuccess.riv": @{@"stateMachine": @"State Machine 1"},
        };
    });
    return options[fileName];
}

/// The black line icons from useAnimations (NOTICE.animations), tinted so they read on any background.
static BOOL CYLScenarioIsLineIcon(NSString *fileName) {
    static NSSet<NSString *> *names;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = [NSSet setWithArray:@[
            @"CYLPlaceholderNoInternet.json", @"CYLPlaceholderLoadFailed.json", @"CYLPlaceholderServerError.json",
            @"CYLPlaceholderRefresh.json", @"CYLPlaceholderNoResults.json", @"CYLPlaceholderNoPermission.json",
            @"CYLPlaceholderContactSupport.json", @"CYLPlaceholderNoMessages.json",
            @"CYLPlaceholderNoNotifications.json", @"CYLPlaceholderSad.json", @"CYLPlaceholderCloudOff.json",
            @"CYLPlaceholderTapHint.json", @"CYLPlaceholderSettings.json"]];
    });
    return [names containsObject:fileName];
}

#pragma mark - Component

@interface CYLPlaceholderComponent ()
@property (nonatomic, copy, readwrite) NSDictionary<NSString *, id> *attributes;
@property (nonatomic, copy, readwrite, nullable) CYLPlaceholderAction action;
@end

@implementation CYLPlaceholderComponent

+ (instancetype)componentWithAttributes:(NSDictionary<NSString *, id> *)attributes action:(CYLPlaceholderAction)action {
    CYLPlaceholderComponent *component = [[self alloc] cyl_init];
    component.attributes = attributes ?: @{};
    component.action = action;
    component.spacingBefore = 16;
    return component;
}

- (instancetype)cyl_init {
    return [super init];
}

- (id)copyWithZone:(NSZone *)zone {
    CYLPlaceholderComponent *copy = [[self.class allocWithZone:zone] cyl_init];
    copy.attributes = self.attributes;
    copy.action = self.action;
    copy.imageBundle = self.imageBundle;
    copy.spacingBefore = self.spacingBefore;
    return copy;
}

+ (instancetype)componentWithBundledAnimation:(NSString *)fileName
                                fallbackStyle:(CYLPlaceholderStyle)fallbackStyle
                                        title:(NSString *)title
                                         size:(CGSize)size
                                       action:(CYLPlaceholderAction)action {
    NSMutableDictionary<NSString *, id> *attributes = [NSMutableDictionary dictionary];
    attributes[CYLPlaceholderItemStyle] = @(fallbackStyle);
    NSString *path = fileName ? [CYLPlaceholderView pathForBundledAnimation:fileName] : nil;
    if (path) {
        attributes[CYLPlaceholderItemAnimationFilePath] = path;
        attributes[CYLPlaceholderItemAnimationSize] = @[@(size.width), @(size.height)];
        NSDictionary *options = CYLScenarioAnimationOptions(fileName);
        if (options) attributes[CYLPlaceholderItemAnimationOptions] = options;
        if (CYLScenarioIsLineIcon(fileName)) {
            attributes[CYLPlaceholderItemAnimationColors] = @{@"**.Color": CYLScenarioLineIconColor()};
        }
    } else if (fileName) {
        NSLog(@"CYLTableViewPlaceHolder: bundled animation %@ not found; showing the static style.", fileName);
    }
    if (title.length) {
        attributes[CYLPlaceholderItemTitle] = title;
    } else if (action) {
        // [EN] An icon-only button still needs a spoken name.
        // [CN] 只有图标的按钮也需要可朗读的名称。
        NSString *name = [CYLPlaceholderScenarioCatalog localizedTitleForAction:action];
        if (name) attributes[CYLPlaceholderItemAccessibilityLabel] = name;
    }
    return [self componentWithAttributes:attributes action:action];
}

+ (instancetype)hintComponentWithText:(NSString *)text {
    CYLPlaceholderComponent *component = [self componentWithAttributes:@{
        CYLPlaceholderItemTitle: text ?: @"",
        CYLPlaceholderItemTitleColor: CYLScenarioSecondaryTextColor(),
        CYLPlaceholderItemTitleFont: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote],
    } action:nil];
    component.spacingBefore = 4;
    return component;
}

+ (instancetype)buttonComponentWithTitle:(NSString *)title
                                   style:(CYLPlaceholderButtonStyle)style
                                  action:(CYLPlaceholderAction)action {
    NSMutableDictionary<NSString *, id> *attributes = [NSMutableDictionary dictionary];
    attributes[CYLPlaceholderItemTitle] = title ?: @"";
    attributes[CYLPlaceholderItemTitleFont] = CYLScenarioFont(UIFontTextStyleBody, 16, UIFontWeightSemibold);
    switch (style) {
        case CYLPlaceholderButtonStyleOutlined:
            attributes[CYLPlaceholderItemTitleColor] = CYLScenarioAccentColor();
            attributes[CYLPlaceholderItemTitleBorderColor] = CYLScenarioAccentColor();
            attributes[CYLPlaceholderItemTitleBorderWidth] = @1;
            attributes[CYLPlaceholderItemTitleCornerRadius] = @6;
            attributes[CYLPlaceholderItemTitleContentInsets] = @[@8, @22, @8, @22];
            attributes[CYLPlaceholderItemTitleMinimumWidth] = @128;
            break;
        case CYLPlaceholderButtonStyleCapsule:
            attributes[CYLPlaceholderItemTitleColor] = UIColor.whiteColor;
            attributes[CYLPlaceholderItemTitleBackgroundImage] = CYLScenarioCapsuleBackgroundImage();
            attributes[CYLPlaceholderItemTitleCornerRadius] = @999;
            attributes[CYLPlaceholderItemTitleContentInsets] = @[@10, @30, @10, @30];
            attributes[CYLPlaceholderItemTitleMinimumWidth] = @140;
            break;
        case CYLPlaceholderButtonStyleFilled:
        default:
            attributes[CYLPlaceholderItemTitleColor] = UIColor.whiteColor;
            attributes[CYLPlaceholderItemTitleBackgroundColor] = CYLScenarioAccentColor();
            attributes[CYLPlaceholderItemTitleCornerRadius] = @6;
            attributes[CYLPlaceholderItemTitleContentInsets] = @[@11, @24, @11, @24];
            attributes[CYLPlaceholderItemTitleMinimumWidth] = @200;
            break;
    }
    CYLPlaceholderComponent *component = [self componentWithAttributes:attributes action:action];
    component.spacingBefore = 20;
    return component;
}

+ (instancetype)separatorComponentWithText:(NSString *)text {
    CYLPlaceholderComponent *component = [self componentWithAttributes:@{
        CYLPlaceholderItemTitle: [NSString stringWithFormat:@"———   %@   ———", text ?: @""],
        CYLPlaceholderItemTitleColor: CYLScenarioSecondaryTextColor(),
        CYLPlaceholderItemTitleFont: [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote],
    } action:nil];
    component.spacingBefore = 14;
    return component;
}

@end

#pragma mark - Catalog

/// The core lookup for scenario texts.
static NSString *CYLScenarioText(NSString *key, NSString *fallback) {
    return CYLPlaceholderLocalizedString(key, fallback);
}

static CYLPlaceholderComponent *CYLScenarioIcon(NSString *fileName, CYLPlaceholderStyle style, NSString *title,
                                                CGFloat side) {
    return [CYLPlaceholderComponent componentWithBundledAnimation:fileName fallbackStyle:style title:title
                                                             size:CGSizeMake(side, side) action:nil];
}

static CYLPlaceholderComponent *CYLScenarioButton(CYLPlaceholderAction action, CYLPlaceholderButtonStyle style) {
    return [CYLPlaceholderComponent buttonComponentWithTitle:[CYLPlaceholderScenarioCatalog localizedTitleForAction:action]
                                                       style:style action:action];
}

static CYLPlaceholderComponent *CYLScenarioHint(NSString *key, NSString *fallback) {
    return [CYLPlaceholderComponent hintComponentWithText:CYLScenarioText(key, fallback)];
}

/// Line icons are drawn smaller than illustrations.
static const CGFloat CYLScenarioIconSide = 96;
static const CGFloat CYLScenarioIllustrationSide = 160;

@implementation CYLPlaceholderScenarioCatalog

+ (NSArray<NSNumber *> *)allScenarios {
    NSMutableArray<NSNumber *> *scenarios = [NSMutableArray arrayWithCapacity:CYLPlaceholderScenarioCount];
    for (NSInteger scenario = 0; scenario < CYLPlaceholderScenarioCount; scenario++) [scenarios addObject:@(scenario)];
    return scenarios;
}

+ (NSString *)localizedTitleForAction:(CYLPlaceholderAction)action {
    static NSDictionary<CYLPlaceholderAction, NSArray<NSString *> *> *texts;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        texts = @{
            CYLPlaceholderActionRetry: @[@"CYLPlaceholderActionRetryTitle", @"Retry"],
            CYLPlaceholderActionContactSupport: @[@"CYLPlaceholderActionContactSupportTitle", @"Contact support"],
            CYLPlaceholderActionOpenSettings: @[@"CYLPlaceholderActionOpenSettingsTitle", @"Open Settings"],
            CYLPlaceholderActionGoShopping: @[@"CYLPlaceholderActionGoShoppingTitle", @"Go shopping"],
            CYLPlaceholderActionDone: @[@"CYLPlaceholderActionDoneTitle", @"Done"],
        };
    });
    NSArray<NSString *> *text = action ? texts[action] : nil;
    return text ? CYLScenarioText(text[0], text[1]) : nil;
}

+ (NSString *)localizedNameForScenario:(CYLPlaceholderScenario)scenario {
    static NSArray<NSArray<NSString *> *> *names;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @[
            @[@"CYLPlaceholderScenarioNetworkUnavailableName", @"Network unavailable"],
            @[@"CYLPlaceholderScenarioNoContentName", @"No content"],
            @[@"CYLPlaceholderScenarioTapToReloadName", @"Tap to reload"],
            @[@"CYLPlaceholderScenarioLoadFailedWithHintName", @"Load failed with a hint"],
            @[@"CYLPlaceholderScenarioTapToReconnectName", @"Tap to reconnect"],
            @[@"CYLPlaceholderScenarioRetryButtonName", @"Retry button"],
            @[@"CYLPlaceholderScenarioRetryOutlinedButtonName", @"Outlined retry button"],
            @[@"CYLPlaceholderScenarioRetryWithHintName", @"Hint and reload button"],
            @[@"CYLPlaceholderScenarioRetryOrContactSupportName", @"Retry or contact support"],
            @[@"CYLPlaceholderScenarioIllustrationRetryName", @"Illustration and capsule button"],
            @[@"CYLPlaceholderScenarioRefreshIconName", @"Refresh icon"],
            @[@"CYLPlaceholderScenarioTitleAboveIllustrationName", @"Title above the illustration"],
            @[@"CYLPlaceholderScenarioTextOnlyName", @"Text only"],
            @[@"CYLPlaceholderScenarioTapMeRetryName", @"Tap me and reload"],
            @[@"CYLPlaceholderScenarioNoSearchResultsName", @"No search results"],
            @[@"CYLPlaceholderScenarioEmptyCartName", @"Empty cart"],
            @[@"CYLPlaceholderScenarioNoOrdersName", @"No orders"],
            @[@"CYLPlaceholderScenarioNoFavoritesName", @"No favorites"],
            @[@"CYLPlaceholderScenarioNoMessagesName", @"No messages"],
            @[@"CYLPlaceholderScenarioNoNotificationsName", @"No notifications"],
            @[@"CYLPlaceholderScenarioNoPermissionName", @"No permission"],
            @[@"CYLPlaceholderScenarioLocationOffName", @"Location off"],
            @[@"CYLPlaceholderScenarioServerErrorName", @"Server error"],
            @[@"CYLPlaceholderScenarioSyncFailedName", @"Sync failed"],
            @[@"CYLPlaceholderScenarioLoadingName", @"Loading"],
            @[@"CYLPlaceholderScenarioUploadingName", @"Uploading"],
            @[@"CYLPlaceholderScenarioSuccessName", @"Success"],
        ];
    });
    if (scenario < 0 || scenario >= (NSInteger)names.count) return @"";
    return CYLScenarioText(names[scenario][0], names[scenario][1]);
}

+ (NSArray<NSNumber *> *)readmeScreenshotNumbersForScenario:(CYLPlaceholderScenario)scenario {
    switch (scenario) {
        case CYLPlaceholderScenarioNetworkUnavailable: return @[@4, @5, @6, @25, @36];
        case CYLPlaceholderScenarioNoContent: return @[@7, @9, @10];
        case CYLPlaceholderScenarioTapToReload: return @[@13, @14, @15, @24, @26, @28, @31, @32, @37, @42, @43];
        case CYLPlaceholderScenarioLoadFailedWithHint: return @[@21, @22, @27, @29];
        case CYLPlaceholderScenarioTapToReconnect: return @[@8];
        case CYLPlaceholderScenarioRetryButton: return @[@1, @2, @11, @19, @20];
        case CYLPlaceholderScenarioRetryOutlinedButton: return @[@33, @38, @39];
        case CYLPlaceholderScenarioRetryWithHint: return @[@16, @23, @40];
        case CYLPlaceholderScenarioRetryOrContactSupport: return @[@3];
        case CYLPlaceholderScenarioIllustrationRetry: return @[@18];
        case CYLPlaceholderScenarioRefreshIcon: return @[@12];
        case CYLPlaceholderScenarioTitleAboveIllustration: return @[@17];
        case CYLPlaceholderScenarioTextOnly: return @[@30, @41];
        case CYLPlaceholderScenarioTapMeRetry: return @[@34, @35];
        default: return @[];
    }
}

+ (CYLPlaceholderAction)backgroundActionForScenario:(CYLPlaceholderScenario)scenario {
    switch (scenario) {
        case CYLPlaceholderScenarioTapToReload:
        case CYLPlaceholderScenarioTapToReconnect:
        case CYLPlaceholderScenarioTitleAboveIllustration:
        case CYLPlaceholderScenarioTextOnly:
            return CYLPlaceholderActionRetry;
        default:
            return nil;
    }
}

+ (NSArray<CYLPlaceholderComponent *> *)componentsForScenario:(CYLPlaceholderScenario)scenario {
    const CGFloat icon = CYLScenarioIconSide;
    const CGFloat art = CYLScenarioIllustrationSide;
    switch (scenario) {
        case CYLPlaceholderScenarioNetworkUnavailable:
            return @[CYLScenarioIcon(@"CYLPlaceholderNoInternet.json", CYLPlaceholderStyleWifiOff,
                CYLScenarioText(@"CYLPlaceholderScenarioNetworkUnavailableTitle",
                                @"The network seems slow. Check your connection and try again."), icon)];
        case CYLPlaceholderScenarioNoContent:
            return @[CYLScenarioIcon(@"CYLPlaceholderEmpty.json", CYLPlaceholderStyleEmpty,
                CYLScenarioText(@"CYLPlaceholderScenarioNoContentTitle", @"Nothing here yet"), art)];
        case CYLPlaceholderScenarioTapToReload:
            return @[CYLScenarioIcon(@"CYLPlaceholderRefresh.json", CYLPlaceholderStyleRefresh,
                CYLScenarioText(@"CYLPlaceholderScenarioTapToReloadTitle",
                                @"Network unavailable. Tap the screen to reload."), icon)];
        case CYLPlaceholderScenarioLoadFailedWithHint:
            return @[CYLScenarioIcon(@"CYLPlaceholderLoadFailed.json", CYLPlaceholderStyleErrorOutline,
                         CYLScenarioText(@"CYLPlaceholderScenarioLoadFailedWithHintTitle", @"Couldn't load the data"), icon),
                     CYLScenarioHint(@"CYLPlaceholderScenarioLoadFailedWithHintHint",
                                     @"Check your network, then pull down to refresh")];
        case CYLPlaceholderScenarioTapToReconnect:
            return @[CYLScenarioIcon(@"CYLPlaceholderNoInternet.json", CYLPlaceholderStyleSignalWifiOff,
                         CYLScenarioText(@"CYLPlaceholderScenarioTapToReconnectTitle", @"Not connected to the internet"), icon),
                     CYLScenarioHint(@"CYLPlaceholderScenarioTapToReconnectHint",
                                     @"Check your device's connection, then tap the screen to reconnect")];
        case CYLPlaceholderScenarioRetryButton:
            return @[CYLScenarioIcon(@"CYLPlaceholderSad.json", CYLPlaceholderStyleNoInternet,
                         CYLScenarioText(@"CYLPlaceholderScenarioRetryButtonTitle",
                                         @"The network is slow. Please try again."), icon),
                     CYLScenarioButton(CYLPlaceholderActionRetry, CYLPlaceholderButtonStyleFilled)];
        case CYLPlaceholderScenarioRetryOutlinedButton:
            return @[CYLScenarioIcon(@"CYLPlaceholderLoadFailed.json", CYLPlaceholderStyleReportProblem,
                         CYLScenarioText(@"CYLPlaceholderScenarioRetryOutlinedButtonTitle", @"Something went wrong"), icon),
                     CYLScenarioButton(CYLPlaceholderActionRetry, CYLPlaceholderButtonStyleOutlined)];
        case CYLPlaceholderScenarioRetryWithHint: {
            CYLPlaceholderComponent *reload = [CYLPlaceholderComponent
                buttonComponentWithTitle:CYLScenarioText(@"CYLPlaceholderScenarioReloadTitle", @"Reload")
                                   style:CYLPlaceholderButtonStyleOutlined action:CYLPlaceholderActionRetry];
            return @[CYLScenarioIcon(@"CYLPlaceholderNoInternet.json", CYLPlaceholderStyleWifiOff,
                         CYLScenarioText(@"CYLPlaceholderScenarioRetryWithHintTitle",
                                         @"Your network isn't working well"), icon),
                     CYLScenarioHint(@"CYLPlaceholderScenarioRetryWithHintHint", @"Check whether your phone is online"),
                     reload];
        }
        case CYLPlaceholderScenarioRetryOrContactSupport: {
            CYLPlaceholderComponent *separator = [CYLPlaceholderComponent separatorComponentWithText:
                CYLScenarioText(@"CYLPlaceholderScenarioOrSeparator", @"or")];
            CYLPlaceholderComponent *support = CYLScenarioButton(CYLPlaceholderActionContactSupport,
                                                                 CYLPlaceholderButtonStyleOutlined);
            support.spacingBefore = 14;
            return @[CYLScenarioIcon(@"CYLPlaceholderServerError.json", CYLPlaceholderStyleCloudOff,
                         CYLScenarioText(@"CYLPlaceholderScenarioRetryOrContactSupportTitle",
                                         @"Loading failed. Please try again later."), icon),
                     CYLScenarioButton(CYLPlaceholderActionRetry, CYLPlaceholderButtonStyleFilled),
                     separator, support];
        }
        case CYLPlaceholderScenarioIllustrationRetry: {
            CYLPlaceholderComponent *retry = [CYLPlaceholderComponent
                buttonComponentWithTitle:CYLScenarioText(@"CYLPlaceholderScenarioTapToRetryTitle", @"Tap to retry")
                                   style:CYLPlaceholderButtonStyleCapsule action:CYLPlaceholderActionRetry];
            return @[CYLScenarioIcon(@"CYLPlaceholderCloudOff.json", CYLPlaceholderStyleCloudOff, nil, art), retry];
        }
        case CYLPlaceholderScenarioRefreshIcon: {
            CYLPlaceholderComponent *refresh = [CYLPlaceholderComponent
                componentWithBundledAnimation:@"CYLPlaceholderRefresh.json" fallbackStyle:CYLPlaceholderStyleRefresh
                                        title:nil size:CGSizeMake(44, 44) action:CYLPlaceholderActionRetry];
            refresh.spacingBefore = 28;
            return @[CYLScenarioIcon(@"CYLPlaceholderSad.json", CYLPlaceholderStyleHelp,
                         CYLScenarioText(@"CYLPlaceholderScenarioRefreshIconTitle", @"Network unavailable"), icon),
                     refresh];
        }
        case CYLPlaceholderScenarioTitleAboveIllustration: {
            CYLPlaceholderComponent *title = [CYLPlaceholderComponent componentWithAttributes:@{
                CYLPlaceholderItemTitle: CYLScenarioText(@"CYLPlaceholderScenarioTitleAboveIllustrationTitle",
                                                         @"Loading failed. Tap to refresh!")
            } action:nil];
            return @[title, CYLScenarioIcon(@"CYLPlaceholderPullHint.pag", CYLPlaceholderStyleRefresh, nil, art)];
        }
        case CYLPlaceholderScenarioTextOnly: {
            CYLPlaceholderComponent *title = [CYLPlaceholderComponent componentWithAttributes:@{
                CYLPlaceholderItemTitle: CYLScenarioText(@"CYLPlaceholderScenarioTextOnlyTitle", @"Connection failed"),
                CYLPlaceholderItemTitleFont: CYLScenarioFont(UIFontTextStyleTitle3, 20, UIFontWeightRegular),
            } action:nil];
            return @[title, CYLScenarioHint(@"CYLPlaceholderScenarioTextOnlyHint", @"Tap to reload")];
        }
        case CYLPlaceholderScenarioTapMeRetry: {
            CYLPlaceholderComponent *tapMe = [CYLPlaceholderComponent componentWithAttributes:@{
                CYLPlaceholderItemTitle: CYLScenarioText(@"CYLPlaceholderScenarioTapMeTitle", @"Tap me"),
                CYLPlaceholderItemTitleColor: CYLScenarioAccentColor(),
            } action:nil];
            CYLPlaceholderComponent *arrow = CYLScenarioIcon(@"CYLPlaceholderTapHint.json", CYLPlaceholderStyleInfo,
                                                             nil, 36);
            arrow.spacingBefore = 4;
            CYLPlaceholderComponent *reload = [CYLPlaceholderComponent
                buttonComponentWithTitle:CYLScenarioText(@"CYLPlaceholderScenarioReloadNowTitle", @"Reload now…")
                                   style:CYLPlaceholderButtonStyleFilled action:CYLPlaceholderActionRetry];
            reload.spacingBefore = 4;
            CYLPlaceholderComponent *mascot = CYLScenarioIcon(@"CYLPlaceholderNoReviews.riv", CYLPlaceholderStyleFavorite,
                                                              nil, 120);
            mascot.spacingBefore = 4;
            return @[tapMe, arrow, reload, mascot];
        }
        case CYLPlaceholderScenarioNoSearchResults:
            return @[CYLScenarioIcon(@"CYLPlaceholderNoResults.json", CYLPlaceholderStyleSearchOff,
                         CYLScenarioText(@"CYLPlaceholderScenarioNoSearchResultsTitle", @"No matching results"), icon),
                     CYLScenarioHint(@"CYLPlaceholderScenarioNoSearchResultsHint", @"Try different keywords")];
        case CYLPlaceholderScenarioEmptyCart:
            return @[CYLScenarioIcon(@"CYLPlaceholderEmptyCart.json", CYLPlaceholderStyleEmptyCart,
                         CYLScenarioText(@"CYLPlaceholderScenarioEmptyCartTitle", @"Your cart is empty"), art),
                     CYLScenarioButton(CYLPlaceholderActionGoShopping, CYLPlaceholderButtonStyleOutlined)];
        case CYLPlaceholderScenarioNoOrders:
            return @[CYLScenarioIcon(@"CYLPlaceholderNoOrders.riv", CYLPlaceholderStyleArchive,
                         CYLScenarioText(@"CYLPlaceholderScenarioNoOrdersTitle", @"No orders yet"), art),
                     CYLScenarioButton(CYLPlaceholderActionGoShopping, CYLPlaceholderButtonStyleFilled)];
        case CYLPlaceholderScenarioNoFavorites:
            return @[CYLScenarioIcon(@"CYLPlaceholderNoFavorites.pag", CYLPlaceholderStyleFavorite,
                         CYLScenarioText(@"CYLPlaceholderScenarioNoFavoritesTitle", @"No favorites yet"), art),
                     CYLScenarioHint(@"CYLPlaceholderScenarioNoFavoritesHint", @"Save what you like and find it here")];
        case CYLPlaceholderScenarioNoMessages:
            return @[CYLScenarioIcon(@"CYLPlaceholderNoMessages.json", CYLPlaceholderStyleInbox,
                         CYLScenarioText(@"CYLPlaceholderScenarioNoMessagesTitle", @"No messages"), icon)];
        case CYLPlaceholderScenarioNoNotifications:
            return @[CYLScenarioIcon(@"CYLPlaceholderNoNotifications.json", CYLPlaceholderStyleNotificationsOff,
                         CYLScenarioText(@"CYLPlaceholderScenarioNoNotificationsTitle", @"No notifications"), icon),
                     CYLScenarioHint(@"CYLPlaceholderScenarioNoNotificationsHint",
                                     @"We'll let you know when something arrives")];
        case CYLPlaceholderScenarioNoPermission:
            return @[CYLScenarioIcon(@"CYLPlaceholderNoPermission.json", CYLPlaceholderStyleLocked,
                         CYLScenarioText(@"CYLPlaceholderScenarioNoPermissionTitle", @"Permission required"), icon),
                     CYLScenarioHint(@"CYLPlaceholderScenarioNoPermissionHint", @"Allow access in Settings to continue"),
                     CYLScenarioButton(CYLPlaceholderActionOpenSettings, CYLPlaceholderButtonStyleFilled)];
        case CYLPlaceholderScenarioLocationOff:
            return @[CYLScenarioIcon(@"CYLPlaceholderLocation.json", CYLPlaceholderStyleLocationOff,
                         CYLScenarioText(@"CYLPlaceholderScenarioLocationOffTitle", @"Location services are off"), art),
                     CYLScenarioButton(CYLPlaceholderActionOpenSettings, CYLPlaceholderButtonStyleOutlined)];
        case CYLPlaceholderScenarioServerError:
            return @[CYLScenarioIcon(@"CYLPlaceholderServerError.json", CYLPlaceholderStyleCloudOff,
                         CYLScenarioText(@"CYLPlaceholderScenarioServerErrorTitle", @"The server is taking a break"), icon),
                     CYLScenarioHint(@"CYLPlaceholderScenarioServerErrorHint", @"Please try again later"),
                     CYLScenarioButton(CYLPlaceholderActionRetry, CYLPlaceholderButtonStyleFilled)];
        case CYLPlaceholderScenarioSyncFailed:
            return @[CYLScenarioIcon(@"CYLPlaceholderCloudOff.json", CYLPlaceholderStyleSyncProblem,
                         CYLScenarioText(@"CYLPlaceholderScenarioSyncFailedTitle", @"Sync failed"), icon),
                     CYLScenarioButton(CYLPlaceholderActionRetry, CYLPlaceholderButtonStyleOutlined)];
        case CYLPlaceholderScenarioLoading:
            return @[CYLScenarioIcon(@"CYLPlaceholderLoading.json", CYLPlaceholderStyleHourglass,
                CYLScenarioText(@"CYLPlaceholderScenarioLoadingTitle", @"Loading…"), art)];
        case CYLPlaceholderScenarioUploading:
            return @[CYLScenarioIcon(@"CYLPlaceholderUploading.gif", CYLPlaceholderStyleUploadOff,
                CYLScenarioText(@"CYLPlaceholderScenarioUploadingTitle", @"Uploading…"), art)];
        case CYLPlaceholderScenarioSuccess:
            return @[CYLScenarioIcon(@"CYLPlaceholderSuccess.riv", CYLPlaceholderStyleInfo,
                         CYLScenarioText(@"CYLPlaceholderScenarioSuccessTitle", @"Submitted"), art),
                     CYLScenarioButton(CYLPlaceholderActionDone, CYLPlaceholderButtonStyleFilled)];
        case CYLPlaceholderScenarioCount:
        default:
            return @[];
    }
}

@end
