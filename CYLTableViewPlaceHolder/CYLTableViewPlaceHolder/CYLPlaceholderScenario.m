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
CYLPlaceholderAction const CYLPlaceholderActionChooseManually = @"CYLPlaceholderActionChooseManually";

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

#pragma mark - Configuration values

static NSError *CYLScenarioConfigurationError(NSString *description) {
    return [NSError errorWithDomain:@"CYLPlaceholderConfigurationError" code:2
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

static NSString *CYLScenarioString(id value) {
    return [value isKindOfClass:NSString.class] ? value : nil;
}

/// A text from a configuration: the core localization of `keyName` when given, else the literal `literalName`.
static NSString *CYLScenarioConfiguredText(NSDictionary *dictionary, NSString *literalName, NSString *keyName) {
    NSString *literal = CYLScenarioString(dictionary[literalName]);
    NSString *key = CYLScenarioString(dictionary[keyName]);
    if (key.length) return CYLPlaceholderLocalizedString(key, literal);
    return literal;
}

/// A style from a number or a name such as "WifiOff" or "CYLPlaceholderWifiOff" (any case).
static BOOL CYLScenarioStyleFromValue(id value, CYLPlaceholderStyle *style) {
    if ([value isKindOfClass:NSNumber.class]) {
        NSInteger number = [value integerValue];
        if (number < 0 || number >= CYLPlaceholderStyleCount || [value doubleValue] != number) return NO;
        *style = number;
        return YES;
    }
    NSString *name = CYLScenarioString(value).lowercaseString;
    if (!name.length) return NO;
    if (![name hasPrefix:@"cylplaceholder"]) name = [@"cylplaceholder" stringByAppendingString:name];
    for (NSInteger candidate = 0; candidate < CYLPlaceholderStyleCount; candidate++) {
        if ([[CYLPlaceholderView imageNameForStyle:candidate].lowercaseString isEqualToString:name]) {
            *style = candidate;
            return YES;
        }
    }
    return NO;
}

static BOOL CYLScenarioSizeFromValue(id value, CGSize *size) {
    double width = 0, height = 0;
    if ([value isKindOfClass:NSNumber.class]) {
        width = height = [value doubleValue];
    } else if ([value isKindOfClass:NSArray.class] && [value count] == 2 &&
               [[value firstObject] isKindOfClass:NSNumber.class] && [[value lastObject] isKindOfClass:NSNumber.class]) {
        width = [[value firstObject] doubleValue];
        height = [[value lastObject] doubleValue];
    } else {
        return NO;
    }
    if (!isfinite(width) || !isfinite(height) || width <= 0 || height <= 0 || width > 1000 || height > 1000) return NO;
    *size = CGSizeMake(width, height);
    return YES;
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
            @"CYLPlaceholderNoResults.riv": legacy,
            @"CYLPlaceholderSettings.riv": legacy,
            @"CYLPlaceholderMascot.riv": legacy,
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
            @"CYLPlaceholderTapHint.json", @"CYLPlaceholderSettings.json",
            @"CYLPlaceholderLocationPermission.json", @"CYLPlaceholderCameraPermission.json",
            @"CYLPlaceholderPhotoLibraryPermission.json", @"CYLPlaceholderMicrophonePermission.json",
            @"CYLPlaceholderContactsPermission.json", @"CYLPlaceholderCalendarPermission.json",
            @"CYLPlaceholderBluetoothPermission.json", @"CYLPlaceholderNotificationPermission.json"]];
    });
    return [names containsObject:fileName];
}

#pragma mark - Component

static NSString *CYLScenarioText(NSString *key, NSString *fallback);
/// Line icons are drawn smaller than illustrations.
static const CGFloat CYLScenarioIconSide = 96;
static const CGFloat CYLScenarioIllustrationSide = 160;

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

- (void)cyl_setAttribute:(id)value forKey:(NSString *)key {
    NSMutableDictionary<NSString *, id> *attributes = [self.attributes mutableCopy];
    attributes[key] = value;
    self.attributes = attributes;
}

- (BOOL)interactionEnabled {
    id value = self.attributes[CYLPlaceholderItemInteractionEnabled];
    return [value isKindOfClass:NSNumber.class] ? [value boolValue] : YES;
}

- (void)setInteractionEnabled:(BOOL)interactionEnabled {
    [self cyl_setAttribute:@(interactionEnabled) forKey:CYLPlaceholderItemInteractionEnabled];
}

- (CYLPlaceholderTapHighlightStyle)tapHighlightStyle {
    id value = self.attributes[CYLPlaceholderItemTapHighlightStyle];
    if ([value isKindOfClass:NSString.class]) {
        NSUInteger index = [@[@"dim", @"shrink", @"none"] indexOfObject:[value lowercaseString]];
        return index == NSNotFound ? CYLPlaceholderTapHighlightStyleDim : (CYLPlaceholderTapHighlightStyle)index;
    }
    return [value isKindOfClass:NSNumber.class] ? [value integerValue] : CYLPlaceholderTapHighlightStyleDim;
}

- (void)setTapHighlightStyle:(CYLPlaceholderTapHighlightStyle)tapHighlightStyle {
    [self cyl_setAttribute:@(tapHighlightStyle) forKey:CYLPlaceholderItemTapHighlightStyle];
}

- (NSInteger)animationRepeatCount {
    id value = self.attributes[CYLPlaceholderItemAnimationRepeatCount];
    if ([value isKindOfClass:NSString.class]) return [[value lowercaseString] isEqualToString:@"loop"] ? 0 : 1;
    return [value isKindOfClass:NSNumber.class] ? [value integerValue] : 1;
}

- (void)setAnimationRepeatCount:(NSInteger)animationRepeatCount {
    [self cyl_setAttribute:@(MAX(0, animationRepeatCount)) forKey:CYLPlaceholderItemAnimationRepeatCount];
}

+ (instancetype)componentWithDictionary:(NSDictionary<NSString *, id> *)dictionary error:(NSError **)error {
    if (![dictionary isKindOfClass:NSDictionary.class]) {
        if (error) *error = CYLScenarioConfigurationError(@"A component must be a dictionary.");
        return nil;
    }
    NSString *type = CYLScenarioString(dictionary[@"type"]) ?: @"icon";
    NSString *title = CYLScenarioConfiguredText(dictionary, @"title", @"titleKey") ?:
        CYLScenarioConfiguredText(dictionary, @"text", @"textKey");
    CYLPlaceholderAction action = nil;
    if (dictionary[@"action"]) {
        NSString *name = CYLScenarioString(dictionary[@"action"]);
        if (!name.length) {
            if (error) *error = CYLScenarioConfigurationError(@"A component action must be a non-empty string.");
            return nil;
        }
        action = [CYLPlaceholderScenarioCatalog actionNamed:name];
    }
    CYLPlaceholderComponent *component = nil;
    if ([type isEqualToString:@"icon"]) {
        CYLPlaceholderStyle style = CYLPlaceholderStyleEmpty;
        if (dictionary[@"style"] && !CYLScenarioStyleFromValue(dictionary[@"style"], &style)) {
            if (error) *error = CYLScenarioConfigurationError(@"Unknown placeholder style.");
            return nil;
        }
        CGSize size = CGSizeMake(CYLScenarioIconSide, CYLScenarioIconSide);
        if (dictionary[@"size"] && !CYLScenarioSizeFromValue(dictionary[@"size"], &size)) {
            if (error) *error = CYLScenarioConfigurationError(@"A component size must be [width, height] or a number.");
            return nil;
        }
        NSString *animation = CYLScenarioString(dictionary[@"animation"]);
        if (animation && ![CYLPlaceholderView pathForBundledAnimation:animation]) {
            if (error) *error = CYLScenarioConfigurationError([NSString stringWithFormat:
                @"Bundled animation %@ was not found.", animation]);
            return nil;
        }
        component = [self componentWithBundledAnimation:animation fallbackStyle:style title:title size:size action:action];
    } else if ([type isEqualToString:@"hint"]) {
        component = [self hintComponentWithText:title ?: @""];
    } else if ([type isEqualToString:@"button"]) {
        NSInteger buttonStyle = CYLPlaceholderButtonStyleFilled;
        id styleValue = dictionary[@"buttonStyle"];
        if (styleValue) {
            NSUInteger index = [styleValue isKindOfClass:NSString.class] ?
                [@[@"filled", @"outlined", @"capsule"] indexOfObject:[styleValue lowercaseString]] : NSNotFound;
            if (index == NSNotFound) {
                if (error) *error = CYLScenarioConfigurationError(@"A button style must be filled, outlined or capsule.");
                return nil;
            }
            buttonStyle = (NSInteger)index;
        }
        if (!action) {
            if (error) *error = CYLScenarioConfigurationError(@"A button needs an action.");
            return nil;
        }
        component = [self buttonComponentWithTitle:title ?: ([CYLPlaceholderScenarioCatalog localizedTitleForAction:action] ?: @"")
                                             style:buttonStyle action:action];
    } else if ([type isEqualToString:@"separator"]) {
        component = [self separatorComponentWithText:title ?: CYLScenarioText(@"CYLPlaceholderScenarioOrSeparator", @"or")];
    } else if ([type isEqualToString:@"item"]) {
        id attributes = dictionary[@"attributes"];
        if (![attributes isKindOfClass:NSDictionary.class]) {
            if (error) *error = CYLScenarioConfigurationError(@"An item component needs an \"attributes\" dictionary.");
            return nil;
        }
        NSMutableDictionary *resolved = [attributes mutableCopy];
        if (title) resolved[CYLPlaceholderItemTitle] = title;
        component = [self componentWithAttributes:resolved action:action];
    } else {
        if (error) *error = CYLScenarioConfigurationError([NSString stringWithFormat:@"Unknown component type %@.", type]);
        return nil;
    }
    if (![component cyl_applyConfiguration:dictionary error:error]) return nil;
    return component;
}

/// The fields every component accepts, also used for a scenario's "overrides".
- (BOOL)cyl_applyConfiguration:(NSDictionary<NSString *, id> *)dictionary error:(NSError **)error {
    id interaction = dictionary[@"interactionEnabled"];
    if (interaction) {
        if (![interaction isKindOfClass:NSNumber.class]) {
            if (error) *error = CYLScenarioConfigurationError(@"interactionEnabled must be a boolean.");
            return NO;
        }
        self.interactionEnabled = [interaction boolValue];
    }
    id highlight = dictionary[@"highlightStyle"];
    if (highlight) {
        NSUInteger index = [highlight isKindOfClass:NSString.class] ?
            [@[@"dim", @"shrink", @"none"] indexOfObject:[highlight lowercaseString]] : NSNotFound;
        if (index == NSNotFound) {
            if (error) *error = CYLScenarioConfigurationError(@"highlightStyle must be dim, shrink or none.");
            return NO;
        }
        self.tapHighlightStyle = (CYLPlaceholderTapHighlightStyle)index;
    }
    id repeat = dictionary[@"repeatCount"];
    if (repeat) {
        NSInteger count = -1;
        if ([repeat isKindOfClass:NSString.class]) {
            NSString *name = [repeat lowercaseString];
            count = [name isEqualToString:@"loop"] ? 0 : ([name isEqualToString:@"once"] ? 1 : -1);
        } else if ([repeat isKindOfClass:NSNumber.class] && [repeat doubleValue] == floor([repeat doubleValue])) {
            count = [repeat integerValue];
        }
        if (count < 0 || count > 10000) {
            if (error) *error = CYLScenarioConfigurationError(@"repeatCount must be 0 (loop) or more, \"loop\" or \"once\".");
            return NO;
        }
        self.animationRepeatCount = count;
    }
    id spacing = dictionary[@"spacingBefore"];
    if (spacing) {
        if (![spacing isKindOfClass:NSNumber.class] || !isfinite([spacing doubleValue]) || [spacing doubleValue] < 0) {
            if (error) *error = CYLScenarioConfigurationError(@"spacingBefore must be a number of points.");
            return NO;
        }
        self.spacingBefore = [spacing doubleValue];
    }
    id identifier = dictionary[@"accessibilityIdentifier"];
    if (identifier) {
        if (![identifier isKindOfClass:NSString.class]) {
            if (error) *error = CYLScenarioConfigurationError(@"accessibilityIdentifier must be a string.");
            return NO;
        }
        [self cyl_setAttribute:identifier forKey:CYLPlaceholderItemAccessibilityIdentifier];
    }
    if (dictionary[@"action"] && dictionary[@"type"] == nil) {
        NSString *name = CYLScenarioString(dictionary[@"action"]);
        self.action = name.length ? [CYLPlaceholderScenarioCatalog actionNamed:name] : nil;
    }
    return YES;
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
        // [EN] Scenario icons loop by default; set `animationRepeatCount` to change it.
        // [CN] 场景图标默认循环播放；可通过 `animationRepeatCount` 修改。
        attributes[CYLPlaceholderItemAnimationRepeatCount] = @0;
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

/// Each scenario's name key and English fallback, in declaration order.
static NSArray<NSArray<NSString *> *> *CYLScenarioNameEntries(void) {
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
            @[@"CYLPlaceholderScenarioLocationPermissionDeniedName", @"Location permission denied"],
            @[@"CYLPlaceholderScenarioNoSearchResultsName", @"No search results"],
            @[@"CYLPlaceholderScenarioEmptyCartName", @"Empty cart"],
            @[@"CYLPlaceholderScenarioNoOrdersName", @"No orders"],
            @[@"CYLPlaceholderScenarioNoFavoritesName", @"No favorites"],
            @[@"CYLPlaceholderScenarioNoMessagesName", @"No messages"],
            @[@"CYLPlaceholderScenarioNoNotificationsName", @"No notifications"],
            @[@"CYLPlaceholderScenarioNoPermissionName", @"No permission"],
            @[@"CYLPlaceholderScenarioCameraPermissionDeniedName", @"Camera permission denied"],
            @[@"CYLPlaceholderScenarioPhotoLibraryPermissionDeniedName", @"Photo permission denied"],
            @[@"CYLPlaceholderScenarioMicrophonePermissionDeniedName", @"Microphone permission denied"],
            @[@"CYLPlaceholderScenarioContactsPermissionDeniedName", @"Contacts permission denied"],
            @[@"CYLPlaceholderScenarioCalendarPermissionDeniedName", @"Calendar permission denied"],
            @[@"CYLPlaceholderScenarioBluetoothPermissionDeniedName", @"Bluetooth permission denied"],
            @[@"CYLPlaceholderScenarioNotificationPermissionDeniedName", @"Notification permission denied"],
            @[@"CYLPlaceholderScenarioServerErrorName", @"Server error"],
            @[@"CYLPlaceholderScenarioSyncFailedName", @"Sync failed"],
            @[@"CYLPlaceholderScenarioLoadingName", @"Loading"],
            @[@"CYLPlaceholderScenarioUploadingName", @"Uploading"],
            @[@"CYLPlaceholderScenarioSuccessName", @"Success"],
        ];
    });
    return names;
}

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
            CYLPlaceholderActionChooseManually: @[@"CYLPlaceholderActionChooseManuallyTitle", @"Choose manually"],
        };
    });
    NSArray<NSString *> *text = action ? texts[action] : nil;
    return text ? CYLScenarioText(text[0], text[1]) : nil;
}

+ (NSString *)localizedNameForScenario:(CYLPlaceholderScenario)scenario {
    NSArray<NSArray<NSString *> *> *names = CYLScenarioNameEntries();
    if (scenario < 0 || scenario >= (NSInteger)names.count) return @"";
    return CYLScenarioText(names[scenario][0], names[scenario][1]);
}

+ (NSString *)nameForScenario:(CYLPlaceholderScenario)scenario {
    NSArray<NSArray<NSString *> *> *names = CYLScenarioNameEntries();
    if (scenario < 0 || scenario >= (NSInteger)names.count) return @"";
    // [EN] "CYLPlaceholderScenarioRetryButtonName" -> "RetryButton". [CN] 去掉前缀与 "Name" 后缀。
    NSString *key = names[scenario][0];
    NSString *prefix = @"CYLPlaceholderScenario";
    return [key substringWithRange:NSMakeRange(prefix.length, key.length - prefix.length - 4)];
}

+ (CYLPlaceholderScenario)scenarioNamed:(NSString *)name {
    if (![name isKindOfClass:NSString.class] || !name.length) return CYLPlaceholderScenarioCount;
    NSString *lowercase = name.lowercaseString;
    if ([lowercase hasPrefix:@"cylplaceholderscenario"]) lowercase = [lowercase substringFromIndex:22];
    for (NSInteger scenario = 0; scenario < CYLPlaceholderScenarioCount; scenario++) {
        if ([[self nameForScenario:scenario].lowercaseString isEqualToString:lowercase]) return scenario;
    }
    return CYLPlaceholderScenarioCount;
}

+ (CYLPlaceholderAction)actionNamed:(NSString *)name {
    NSDictionary<NSString *, CYLPlaceholderAction> *actions = @{
        @"retry": CYLPlaceholderActionRetry,
        @"contactsupport": CYLPlaceholderActionContactSupport,
        @"opensettings": CYLPlaceholderActionOpenSettings,
        @"goshopping": CYLPlaceholderActionGoShopping,
        @"done": CYLPlaceholderActionDone,
        @"choosemanually": CYLPlaceholderActionChooseManually,
    };
    NSString *lowercase = name.lowercaseString;
    if ([lowercase hasPrefix:@"cylplaceholderaction"]) lowercase = [lowercase substringFromIndex:20];
    return actions[lowercase] ?: name;
}

+ (NSArray<NSNumber *> *)readmeScreenshotNumbersForScenario:(CYLPlaceholderScenario)scenario {
    switch (scenario) {
        case CYLPlaceholderScenarioNetworkUnavailable: return @[@4, @5, @6, @25, @36];
        case CYLPlaceholderScenarioNoContent: return @[@7, @9, @10];
        case CYLPlaceholderScenarioTapToReload: return @[@13, @14, @15, @24, @26, @28, @31, @32, @37, @42, @43];
        case CYLPlaceholderScenarioLoadFailedWithHint: return @[@21, @22, @27, @29];
        case CYLPlaceholderScenarioTapToReconnect: return @[@8];
        case CYLPlaceholderScenarioRetryButton: return @[@1, @2, @11, @19];
        case CYLPlaceholderScenarioLocationPermissionDenied: return @[@20];
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

+ (NSArray<NSString *> *)animationFileNamesForScenario:(CYLPlaceholderScenario)scenario {
    // [EN] The scenario's own icon first (the one `componentsForScenario:` uses), then other formats that fit.
    // [CN] 第一个是场景自己的图标（`componentsForScenario:` 使用的），其后是其他格式中合适的动画。
    static NSDictionary<NSNumber *, NSArray<NSString *> *> *variants;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        variants = @{
            @(CYLPlaceholderScenarioNoContent): @[@"CYLPlaceholderNoContent.pag", @"CYLPlaceholderNoDrafts.json"],
            @(CYLPlaceholderScenarioTapToReload): @[@"CYLPlaceholderPullToRefresh.riv"],
            @(CYLPlaceholderScenarioRetryOrContactSupport): @[@"CYLPlaceholderContactSupport.json"],
            @(CYLPlaceholderScenarioRefreshIcon): @[@"CYLPlaceholderRefresh.json", @"CYLPlaceholderPullToRefresh.riv"],
            @(CYLPlaceholderScenarioTitleAboveIllustration): @[@"CYLPlaceholderPullToRefresh.riv"],
            @(CYLPlaceholderScenarioTapMeRetry): @[@"CYLPlaceholderMascot.riv", @"CYLPlaceholderTapHint.json"],
            @(CYLPlaceholderScenarioLocationPermissionDenied): @[@"CYLPlaceholderLocation.json"],
            @(CYLPlaceholderScenarioNoSearchResults): @[@"CYLPlaceholderNoResults.riv"],
            @(CYLPlaceholderScenarioNoFavorites): @[@"CYLPlaceholderNoFavorites.gif", @"CYLPlaceholderNoFavorites.json"],
            @(CYLPlaceholderScenarioNoPermission): @[@"CYLPlaceholderSettings.riv", @"CYLPlaceholderSettings.json"],
            @(CYLPlaceholderScenarioSyncFailed): @[@"CYLPlaceholderLoadingInfinity.json"],
            @(CYLPlaceholderScenarioLoading): @[@"CYLPlaceholderLoading.pag", @"CYLPlaceholderLoading.riv",
                                                @"CYLPlaceholderLoadingInfinity.json", @"CYLPlaceholderProgress.pag"],
            @(CYLPlaceholderScenarioUploading): @[@"CYLPlaceholderProgress.pag"],
            @(CYLPlaceholderScenarioSuccess): @[@"CYLPlaceholderSuccess.json", @"CYLPlaceholderCelebrate.json"],
        };
    });
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    for (CYLPlaceholderComponent *component in [self componentsForScenario:scenario]) {
        NSString *path = component.attributes[CYLPlaceholderItemAnimationFilePath];
        if (path && ![names containsObject:path.lastPathComponent]) [names addObject:path.lastPathComponent];
    }
    for (NSString *name in variants[@(scenario)]) {
        if (![names containsObject:name] && [CYLPlaceholderView pathForBundledAnimation:name]) [names addObject:name];
    }
    return names;
}

+ (CYLPlaceholderScenarioCategory)categoryForScenario:(CYLPlaceholderScenario)scenario {
    if (scenario == CYLPlaceholderScenarioNoPermission || [self permissionForScenario:scenario] != CYLPlaceholderPermissionNone) {
        return CYLPlaceholderScenarioCategoryPermission;
    }
    switch (scenario) {
        case CYLPlaceholderScenarioNoContent:
        case CYLPlaceholderScenarioNoSearchResults:
        case CYLPlaceholderScenarioEmptyCart:
        case CYLPlaceholderScenarioNoOrders:
        case CYLPlaceholderScenarioNoFavorites:
        case CYLPlaceholderScenarioNoMessages:
        case CYLPlaceholderScenarioNoNotifications:
            return CYLPlaceholderScenarioCategoryEmpty;
        case CYLPlaceholderScenarioLoading:
        case CYLPlaceholderScenarioUploading:
            return CYLPlaceholderScenarioCategoryProgress;
        case CYLPlaceholderScenarioSuccess:
            return CYLPlaceholderScenarioCategorySuccess;
        default:
            return CYLPlaceholderScenarioCategoryLoadFailed;
    }
}

/// Every permission scenario, indexed by CYLPlaceholderPermission (None maps to the generic NoPermission).
static const CYLPlaceholderScenario CYLScenarioPermissionScenarios[] = {
    CYLPlaceholderScenarioNoPermission,
    CYLPlaceholderScenarioLocationPermissionDenied,
    CYLPlaceholderScenarioCameraPermissionDenied,
    CYLPlaceholderScenarioPhotoLibraryPermissionDenied,
    CYLPlaceholderScenarioMicrophonePermissionDenied,
    CYLPlaceholderScenarioContactsPermissionDenied,
    CYLPlaceholderScenarioCalendarPermissionDenied,
    CYLPlaceholderScenarioBluetoothPermissionDenied,
    CYLPlaceholderScenarioNotificationPermissionDenied,
};
static const NSInteger CYLScenarioPermissionCount =
    (NSInteger)(sizeof(CYLScenarioPermissionScenarios) / sizeof(CYLScenarioPermissionScenarios[0]));

+ (CYLPlaceholderPermission)permissionForScenario:(CYLPlaceholderScenario)scenario {
    for (NSInteger permission = CYLPlaceholderPermissionLocation; permission < CYLScenarioPermissionCount; permission++) {
        if (CYLScenarioPermissionScenarios[permission] == scenario) return (CYLPlaceholderPermission)permission;
    }
    return CYLPlaceholderPermissionNone;
}

+ (CYLPlaceholderScenario)scenarioForPermission:(CYLPlaceholderPermission)permission {
    if (permission < 0 || permission >= CYLScenarioPermissionCount) return CYLPlaceholderScenarioNoPermission;
    return CYLScenarioPermissionScenarios[permission];
}

/// A permission scenario: the permission's icon and title, a hint saying what is missing and that it is not a
/// network problem, then "Open Settings".
static NSArray<CYLPlaceholderComponent *> *CYLScenarioPermissionComponents(NSString *name, NSString *fileName,
                                                                         CYLPlaceholderStyle style,
                                                                         NSString *title, NSString *hint) {
    NSString *prefix = [NSString stringWithFormat:@"CYLPlaceholderScenario%@PermissionDenied", name];
    return @[CYLScenarioIcon(fileName, style, CYLScenarioText([prefix stringByAppendingString:@"Title"], title),
                             CYLScenarioIconSide),
             CYLScenarioHint([prefix stringByAppendingString:@"Hint"], hint),
             CYLScenarioButton(CYLPlaceholderActionOpenSettings, CYLPlaceholderButtonStyleFilled)];
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
        case CYLPlaceholderScenarioLocationPermissionDenied: {
            // [EN] README #20: the address could not be found, so the user may also pick one by hand.
            // [CN] README #20：无法获取地址，因此也可以手动选择地址。
            NSMutableArray<CYLPlaceholderComponent *> *components = [CYLScenarioPermissionComponents(
                @"Location", @"CYLPlaceholderLocationPermission.json", CYLPlaceholderStyleLocationOff,
                @"Can't get your location",
                @"Location access is off, so nearby content can't load. This isn't a network problem: allow location "
                @"access in Settings.") mutableCopy];
            CYLPlaceholderComponent *manual = [CYLPlaceholderComponent
                buttonComponentWithTitle:CYLScenarioText(@"CYLPlaceholderScenarioChooseAddressTitle",
                                                         @"Choose an address manually")
                                   style:CYLPlaceholderButtonStyleOutlined action:CYLPlaceholderActionChooseManually];
            manual.spacingBefore = 12;
            [components addObject:manual];
            return components;
        }
        case CYLPlaceholderScenarioCameraPermissionDenied:
            return CYLScenarioPermissionComponents(@"Camera", @"CYLPlaceholderCameraPermission.json",
                CYLPlaceholderStyleVideoOff, @"Camera access is off",
                @"Allow camera access in Settings to scan codes or take photos.");
        case CYLPlaceholderScenarioPhotoLibraryPermissionDenied:
            return CYLScenarioPermissionComponents(@"PhotoLibrary", @"CYLPlaceholderPhotoLibraryPermission.json",
                CYLPlaceholderStylePhotoLibrary, @"Photo access is off",
                @"Allow photo access in Settings to choose pictures.");
        case CYLPlaceholderScenarioMicrophonePermissionDenied:
            return CYLScenarioPermissionComponents(@"Microphone", @"CYLPlaceholderMicrophonePermission.json",
                CYLPlaceholderStyleMusicOff, @"Microphone access is off",
                @"Allow microphone access in Settings to record or make voice calls.");
        case CYLPlaceholderScenarioContactsPermissionDenied:
            return CYLScenarioPermissionComponents(@"Contacts", @"CYLPlaceholderContactsPermission.json",
                CYLPlaceholderStyleGroupOff, @"Contacts access is off",
                @"Allow contacts access in Settings to find your friends.");
        case CYLPlaceholderScenarioCalendarPermissionDenied:
            return CYLScenarioPermissionComponents(@"Calendar", @"CYLPlaceholderCalendarPermission.json",
                CYLPlaceholderStyleEventBusy, @"Calendar access is off",
                @"Allow calendar access in Settings to add events and reminders.");
        case CYLPlaceholderScenarioBluetoothPermissionDenied:
            return CYLScenarioPermissionComponents(@"Bluetooth", @"CYLPlaceholderBluetoothPermission.json",
                CYLPlaceholderStyleBluetoothDisabled, @"Bluetooth access is off",
                @"Allow Bluetooth in Settings to connect to nearby devices.");
        case CYLPlaceholderScenarioNotificationPermissionDenied:
            return CYLScenarioPermissionComponents(@"Notification", @"CYLPlaceholderNotificationPermission.json",
                CYLPlaceholderStyleNotificationsOff, @"Notifications are off",
                @"Turn on notifications in Settings to get messages in time.");
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
