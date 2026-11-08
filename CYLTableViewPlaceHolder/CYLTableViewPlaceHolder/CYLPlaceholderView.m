#import "CYLPlaceholderView.h"
#import <math.h>

NSString *const CYLPlaceholderItemTitle = @"CYLTabBarItemTitle";
NSString *const CYLPlaceholderItemImage = @"CYLTabBarItemImage";
NSString *const CYLPlaceholderItemImageInsets = @"CYLTabBarItemImageInsets";
NSString *const CYLPlaceholderItemImagePositionAdjustment = @"CYLTabBarItemImagePositionAdjustment";
NSString *const CYLPlaceholderItemTitlePositionAdjustment = @"CYLTabBarItemTitlePositionAdjustment";
NSString *const CYLPlaceholderItemStyle = @"CYLPlaceholderItemStyle";
NSString *const CYLPlaceholderItemMessage = @"CYLPlaceholderItemMessage";
NSString *const CYLPlaceholderItemAnimationURL = @"CYLTabBarAnimationURL";
NSString *const CYLPlaceholderItemAnimationFilePath = @"CYLTabBarAnimationFilePath";
NSString *const CYLPlaceholderItemAnimationSize = @"CYLTabBarAnimationSize";
NSString *const CYLPlaceholderItemSelectedImage = @"CYLTabBarItemSelectedImage";
NSString *const CYLPlaceholderItemDarkImage = @"CYLTabBarItemDarkImage";
NSString *const CYLPlaceholderItemSelectedDarkImage = @"CYLTabBarItemSelectedDarkImage";
NSString *const CYLPlaceholderItemImageURL = @"CYLTabBarItemImageURL";
NSString *const CYLPlaceholderItemSelectedImageURL = @"CYLTabBarItemSelectedImageURL";
NSString *const CYLPlaceholderItemImageURLSize = @"CYLTabBarItemImageURLSize";
NSString *const CYLPlaceholderItemIdentifier = @"CYLTabBarItemIdentifier";
NSString *const CYLPlaceholderItemPageIdentifier = @"CYLTabBarItemPageIdentifier";
NSString *const CYLPlaceholderItemPageParameters = @"CYLTabBarItemPageParameters";
NSString *const CYLPlaceholderItemPlatforms = @"CYLTabBarItemPlatforms";
NSString *const CYLPlaceholderItemMinimumAppVersion = @"CYLTabBarItemMinimumAppVersion";
NSString *const CYLPlaceholderItemSelectedTitle = @"CYLTabBarItemSelectedTitle";
NSString *const CYLPlaceholderItemTitleColor = @"CYLTabBarItemTitleColor";
NSString *const CYLPlaceholderItemSelectedTitleColor = @"CYLTabBarItemSelectedTitleColor";
NSString *const CYLPlaceholderItemIconColor = @"CYLTabBarItemIconColor";
NSString *const CYLPlaceholderItemSelectedIconColor = @"CYLTabBarItemSelectedIconColor";
NSString *const CYLPlaceholderItemBackgroundColor = @"CYLTabBarItemBackgroundColor";
NSString *const CYLPlaceholderItemSelectedBackgroundColor = @"CYLTabBarItemSelectedBackgroundColor";
NSString *const CYLPlaceholderItemTitleFont = @"CYLTabBarItemTitleFont";
NSString *const CYLPlaceholderItemSelectedTitleFont = @"CYLTabBarItemSelectedTitleFont";
NSString *const CYLPlaceholderItemAccessibilityIdentifier = @"CYLTabBarItemAccessibilityIdentifier";
NSString *const CYLPlaceholderItemAccessibilityLabel = @"CYLTabBarItemAccessibilityLabel";
NSString *const CYLPlaceholderItemAccessibilityHint = @"CYLTabBarItemAccessibilityHint";
NSString *const CYLPlaceholderItemAnimationDarkURL = @"CYLTabBarAnimationDarkURL";
NSString *const CYLPlaceholderItemAnimationDarkFilePath = @"CYLTabBarAnimationDarkFilePath";
NSString *const CYLPlaceholderItemAnimationColors = @"CYLTabBarAnimationColors";
NSString *const CYLPlaceholderItemAnimationDarkColors = @"CYLTabBarAnimationDarkColors";
NSString *const CYLPlaceholderItemAnimationOptions = @"CYLTabBarAnimationOptions";
NSString *const CYLPlaceholderItemLottieURL = @"CYLTabBarLottieURL";
NSString *const CYLPlaceholderItemLottieFilePath = @"CYLTabBarLottieFilePath";
NSString *const CYLPlaceholderItemLottieSize = @"CYLTabBarLottieSize";
NSString *const CYLPlaceholderItemLottieDarkURL = @"CYLTabBarLottieDarkURL";
NSString *const CYLPlaceholderItemLottieDarkFilePath = @"CYLTabBarLottieDarkFilePath";
NSString *const CYLPlaceholderItemLottieDarkColors = @"CYLTabBarLottieDarkColors";
NSString *const CYLPlaceholderItemLottieLoopsWhenUnselected = @"CYLTabBarLottieLoopsWhenUnselected";
NSString *const CYLPlaceholderItemPAGURL = @"CYLTabBarPAGURL";
NSString *const CYLPlaceholderItemPAGFilePath = @"CYLTabBarPAGFilePath";
NSString *const CYLPlaceholderItemPAGSize = @"CYLTabBarPAGSize";
NSString *const CYLPlaceholderItemPAGDarkURL = @"CYLTabBarPAGDarkURL";
NSString *const CYLPlaceholderItemPAGDarkFilePath = @"CYLTabBarPAGDarkFilePath";
NSString *const CYLPlaceholderItemRiveURL = @"CYLTabBarRiveURL";
NSString *const CYLPlaceholderItemRiveFilePath = @"CYLTabBarRiveFilePath";
NSString *const CYLPlaceholderItemRiveSize = @"CYLTabBarRiveSize";
NSString *const CYLPlaceholderItemRiveDarkURL = @"CYLTabBarRiveDarkURL";
NSString *const CYLPlaceholderItemRiveDarkFilePath = @"CYLTabBarRiveDarkFilePath";
NSString *const CYLPlaceholderItemRiveDarkColors = @"CYLTabBarRiveDarkColors";
NSString *const CYLPlaceholderItemGIFURL = @"CYLTabBarGIFURL";
NSString *const CYLPlaceholderItemGIFFilePath = @"CYLTabBarGIFFilePath";
NSString *const CYLPlaceholderItemGIFSize = @"CYLTabBarGIFSize";
NSString *const CYLPlaceholderItemGIFDarkURL = @"CYLTabBarGIFDarkURL";
NSString *const CYLPlaceholderItemGIFDarkFilePath = @"CYLTabBarGIFDarkFilePath";

static NSBundle *CYLPlaceholderResourceBundle(void) {
    NSBundle *container = [NSBundle bundleForClass:CYLPlaceholderView.class];
    NSURL *url = [container URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    if (!url) url = [NSBundle.mainBundle URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
    NSBundle *bundle = url ? [NSBundle bundleWithURL:url] : nil;
    if (!bundle) NSLog(@"CYLTableViewPlaceHolder: placeholder resource bundle not found.");
    return bundle;
}

static NSError *CYLPlaceholderConfigurationError(NSString *description) {
    return [NSError errorWithDomain:@"CYLPlaceholderConfigurationError" code:1
                          userInfo:@{NSLocalizedDescriptionKey: description}];
}

static UIColor *CYLPlaceholderColor(id value) {
    if ([value isKindOfClass:UIColor.class]) return value;
    if (![value isKindOfClass:NSString.class] || ![value hasPrefix:@"#"]) return nil;
    NSString *hex = [value substringFromIndex:1];
    if (hex.length == 3) {
        hex = [NSString stringWithFormat:@"%C%C%C%C%C%C", [hex characterAtIndex:0], [hex characterAtIndex:0],
               [hex characterAtIndex:1], [hex characterAtIndex:1], [hex characterAtIndex:2], [hex characterAtIndex:2]];
    }
    if (hex.length != 6 && hex.length != 8) return nil;
    NSCharacterSet *invalid = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"].invertedSet;
    if ([hex rangeOfCharacterFromSet:invalid].location != NSNotFound) return nil;
    unsigned long long number = 0;
    if (![[NSScanner scannerWithString:hex] scanHexLongLong:&number]) return nil;
    if (hex.length == 6) number = (number << 8) | 0xff;
    return [UIColor colorWithRed:((number >> 24) & 0xff) / 255.0
                           green:((number >> 16) & 0xff) / 255.0
                            blue:((number >> 8) & 0xff) / 255.0
                           alpha:(number & 0xff) / 255.0];
}

static UIFont *CYLPlaceholderFont(id value) {
    if ([value isKindOfClass:UIFont.class]) return value;
    NSString *name = nil, *weightName = nil;
    double size = 0;
    if ([value isKindOfClass:NSNumber.class]) {
        size = [value doubleValue];
    } else if ([value isKindOfClass:NSString.class]) {
        NSString *text = [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        NSRange colon = [text rangeOfString:@":" options:NSBackwardsSearch];
        NSString *sizeText = colon.location == NSNotFound ? text : [text substringFromIndex:NSMaxRange(colon)];
        NSScanner *scanner = [NSScanner scannerWithString:sizeText];
        if (![scanner scanDouble:&size] || !scanner.isAtEnd) return nil;
        if (colon.location != NSNotFound) name = [text substringToIndex:colon.location];
    } else if ([value isKindOfClass:NSDictionary.class]) {
        id sizeValue = value[@"size"];
        if (![sizeValue isKindOfClass:NSNumber.class]) return nil;
        size = [sizeValue doubleValue];
        if (value[@"name"] && ![value[@"name"] isKindOfClass:NSString.class]) return nil;
        if (value[@"weight"] && ![value[@"weight"] isKindOfClass:NSString.class]) return nil;
        name = value[@"name"];
        weightName = value[@"weight"];
    } else return nil;
    if (!isfinite(size) || size < 1 || size > 200) return nil;
    NSDictionary *weights = @{@"ultralight": @(UIFontWeightUltraLight), @"thin": @(UIFontWeightThin),
        @"light": @(UIFontWeightLight), @"regular": @(UIFontWeightRegular), @"medium": @(UIFontWeightMedium),
        @"semibold": @(UIFontWeightSemibold), @"bold": @(UIFontWeightBold), @"heavy": @(UIFontWeightHeavy),
        @"black": @(UIFontWeightBlack)};
    NSNumber *weight = weights[(weightName ?: name ?: @"regular").lowercaseString];
    if (weightName && !weight) return nil;
    if (name.length && !weight) return [UIFont fontWithName:name size:size];
    return [UIFont systemFontOfSize:size weight:weight.doubleValue];
}

static BOOL CYLPlaceholderNumbers(id value, NSArray<NSArray<NSString *> *> *keys, double *numbers) {
    if (![value isKindOfClass:NSArray.class] && ![value isKindOfClass:NSDictionary.class]) return NO;
    if ([value isKindOfClass:NSArray.class] && [value count] != keys.count) return NO;
    for (NSUInteger i = 0; i < keys.count; i++) {
        id number = nil;
        if ([value isKindOfClass:NSArray.class]) {
            number = value[i];
        } else {
            for (NSString *key in keys[i]) {
                if (value[key]) { number = value[key]; break; }
            }
        }
        if (![number isKindOfClass:NSNumber.class]) return NO;
        numbers[i] = [number doubleValue];
        if (!isfinite(numbers[i]) || fabs(numbers[i]) > 1000) return NO;
    }
    return YES;
}

static BOOL CYLPlaceholderOffset(id value, UIOffset *offset) {
    if ([value isKindOfClass:NSValue.class] && strcmp([value objCType], @encode(UIOffset)) == 0) {
        *offset = [value UIOffsetValue];
        return isfinite(offset->horizontal) && isfinite(offset->vertical) &&
            fabs(offset->horizontal) <= 1000 && fabs(offset->vertical) <= 1000;
    }
    double numbers[2];
    if (!CYLPlaceholderNumbers(value, @[@[@"horizontal", @"x"], @[@"vertical", @"y"]], numbers)) return NO;
    *offset = UIOffsetMake(numbers[0], numbers[1]);
    return YES;
}

static BOOL CYLPlaceholderInsets(id value, UIEdgeInsets *insets) {
    if ([value isKindOfClass:NSValue.class] && strcmp([value objCType], @encode(UIEdgeInsets)) == 0) {
        *insets = [value UIEdgeInsetsValue];
        return isfinite(insets->top) && isfinite(insets->left) && isfinite(insets->bottom) &&
            isfinite(insets->right) && fabs(insets->top) <= 1000 && fabs(insets->left) <= 1000 &&
            fabs(insets->bottom) <= 1000 && fabs(insets->right) <= 1000;
    }
    double numbers[4];
    if (!CYLPlaceholderNumbers(value, @[@[@"top"], @[@"left"], @[@"bottom"], @[@"right"]], numbers)) return NO;
    *insets = UIEdgeInsetsMake(numbers[0], numbers[1], numbers[2], numbers[3]);
    return YES;
}

@interface CYLPlaceholderView ()
@property (nonatomic, copy, readwrite) NSDictionary<NSString *, id> *itemAttributes;
@property (nonatomic, strong) UIStackView *contentStack;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *imageSizeConstraints;
@property (nonatomic) BOOL usesItemLayout;
@property (nonatomic) UIOffset itemTitleOffset;
@property (nonatomic) UIOffset itemImageOffset;
@property (nonatomic) UIEdgeInsets itemImageInsets;
@end

@implementation CYLPlaceholderView

- (instancetype)initWithItemContentsOfURL:(NSURL *)url imageBundle:(NSBundle *)imageBundle error:(NSError **)error {
    if (!url.isFileURL) {
        if (error) *error = CYLPlaceholderConfigurationError(@"The configuration URL must be a local file.");
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:error];
    if (!data) return nil;
    id attributes = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:error];
    if (!attributes) return nil;
    return [self initWithItemAttributes:attributes imageBundle:imageBundle error:error];
}

- (instancetype)initWithItemAttributes:(NSDictionary<NSString *,id> *)attributes
                          imageBundle:(NSBundle *)imageBundle error:(NSError **)error {
    if (![attributes isKindOfClass:NSDictionary.class]) {
        if (error) *error = CYLPlaceholderConfigurationError(@"The item configuration must be a dictionary.");
        return nil;
    }
    for (id key in attributes) {
        if (![key isKindOfClass:NSString.class]) {
            if (error) *error = CYLPlaceholderConfigurationError(@"Item configuration keys must be strings.");
            return nil;
        }
    }
    id title = attributes[CYLPlaceholderItemTitle];
    id imageValue = attributes[CYLPlaceholderItemImage];
    id style = attributes[CYLPlaceholderItemStyle];
    id message = attributes[CYLPlaceholderItemMessage];
    for (NSString *key in @[CYLPlaceholderItemStyle, CYLPlaceholderItemMessage]) {
        id value = attributes[key];
        NSInteger count = [key isEqualToString:CYLPlaceholderItemStyle] ? CYLPlaceholderStyleCount : CYLPlaceholderMessageCount;
        if (value && (![value isKindOfClass:NSNumber.class] ||
            !isfinite([value doubleValue]) || [value doubleValue] != floor([value doubleValue]) ||
            [value doubleValue] < 0 || [value doubleValue] >= count)) {
            if (error) *error = CYLPlaceholderConfigurationError(@"Invalid placeholder style or message index.");
            return nil;
        }
    }
    if ((title && ![title isKindOfClass:NSString.class]) ||
        (imageValue && ![imageValue isKindOfClass:NSString.class] && ![imageValue isKindOfClass:UIImage.class])) {
        if (error) *error = CYLPlaceholderConfigurationError(@"The item title must be a string and image must be an image or image name.");
        return nil;
    }
    if (!title && message) title = [CYLPlaceholderView localizedTextForMessage:[message integerValue]];
    UIImage *image = nil;
    if ([imageValue isKindOfClass:UIImage.class]) {
        image = imageValue;
    } else if (imageValue) {
        if ([imageValue hasPrefix:@"system:"]) {
            if (@available(iOS 13.0, *)) image = [UIImage systemImageNamed:[imageValue substringFromIndex:7]];
        } else {
            NSBundle *bundle = imageBundle ?: CYLPlaceholderResourceBundle();
            if (!bundle) {
                if (error) *error = CYLPlaceholderConfigurationError(@"The placeholder resource bundle was not found.");
                return nil;
            }
            image = [UIImage imageNamed:imageValue inBundle:bundle compatibleWithTraitCollection:nil];
        }
        if (!image) {
            if (error) *error = CYLPlaceholderConfigurationError([NSString stringWithFormat:@"Image '%@' was not found in the selected bundle.", imageValue]);
            return nil;
        }
    } else if (style) {
        image = [CYLPlaceholderView imageForStyle:[style integerValue]];
        if (!image) {
            if (error) *error = CYLPlaceholderConfigurationError(@"The selected placeholder style could not be loaded.");
            return nil;
        }
    }
    UIOffset titleOffset = UIOffsetZero, imageOffset = UIOffsetZero;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    id titleValue = attributes[CYLPlaceholderItemTitlePositionAdjustment];
    id imageOffsetValue = attributes[CYLPlaceholderItemImagePositionAdjustment];
    id insetValue = attributes[CYLPlaceholderItemImageInsets];
    if ((titleValue && !CYLPlaceholderOffset(titleValue, &titleOffset)) ||
        (imageOffsetValue && !CYLPlaceholderOffset(imageOffsetValue, &imageOffset)) ||
        (insetValue && !CYLPlaceholderInsets(insetValue, &insets))) {
        if (error) *error = CYLPlaceholderConfigurationError(@"Invalid item offset or image insets.");
        return nil;
    }
    NSMutableDictionary *colors = [NSMutableDictionary dictionary];
    for (NSString *key in @[CYLPlaceholderItemTitleColor, CYLPlaceholderItemIconColor, CYLPlaceholderItemBackgroundColor]) {
        if (attributes[key]) {
            UIColor *color = CYLPlaceholderColor(attributes[key]);
            if (!color) {
                if (error) *error = CYLPlaceholderConfigurationError([NSString stringWithFormat:@"Invalid color for %@.", key]);
                return nil;
            }
            colors[key] = color;
        }
    }
    UIFont *font = attributes[CYLPlaceholderItemTitleFont] ? CYLPlaceholderFont(attributes[CYLPlaceholderItemTitleFont]) : nil;
    if (attributes[CYLPlaceholderItemTitleFont] && !font) {
        if (error) *error = CYLPlaceholderConfigurationError(@"Invalid title font.");
        return nil;
    }
    for (NSString *key in @[CYLPlaceholderItemAccessibilityIdentifier, CYLPlaceholderItemAccessibilityLabel, CYLPlaceholderItemAccessibilityHint]) {
        if (attributes[key] && ![attributes[key] isKindOfClass:NSString.class]) {
            if (error) *error = CYLPlaceholderConfigurationError([NSString stringWithFormat:@"Invalid accessibility value for %@.", key]);
            return nil;
        }
    }
    self = [self initWithImage:image text:title];
    if (self) {
        _itemAttributes = [attributes copy];
        _usesItemLayout = YES;
        _itemTitleOffset = titleOffset;
        _itemImageOffset = imageOffset;
        _itemImageInsets = insets;
        if (colors[CYLPlaceholderItemTitleColor]) self.textLabel.textColor = colors[CYLPlaceholderItemTitleColor];
        if (colors[CYLPlaceholderItemIconColor]) self.imageView.tintColor = colors[CYLPlaceholderItemIconColor];
        if (colors[CYLPlaceholderItemBackgroundColor]) self.backgroundColor = colors[CYLPlaceholderItemBackgroundColor];
        if (font) self.textLabel.font = font;
        self.accessibilityIdentifier = attributes[CYLPlaceholderItemAccessibilityIdentifier];
        if (attributes[CYLPlaceholderItemAccessibilityLabel] || attributes[CYLPlaceholderItemAccessibilityHint]) {
            self.isAccessibilityElement = YES;
            self.accessibilityLabel = attributes[CYLPlaceholderItemAccessibilityLabel] ?: title;
            self.accessibilityHint = attributes[CYLPlaceholderItemAccessibilityHint];
        }
        [NSLayoutConstraint deactivateConstraints:self.imageSizeConstraints];
        [self.contentStack removeArrangedSubview:self.imageView];
        [self.contentStack removeArrangedSubview:self.textLabel];
        [self.imageView removeFromSuperview];
        [self.textLabel removeFromSuperview];
        [self.contentStack removeFromSuperview];
        [self addSubview:self.imageView];
        [self addSubview:self.textLabel];
        self.imageView.translatesAutoresizingMaskIntoConstraints = YES;
        self.textLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [self setNeedsLayout];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.usesItemLayout || CGRectIsEmpty(self.bounds)) return;
    BOOL hasImage = self.imageView.image != nil && !self.imageView.hidden;
    BOOL hasTitle = self.textLabel.text.length > 0 && !self.textLabel.hidden;
    CGFloat width = MAX(0, CGRectGetWidth(self.bounds) - 32);
    CGSize titleSize = hasTitle ? [self.textLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)] : CGSizeZero;
    titleSize.width = MIN(width, ceil(titleSize.width));
    titleSize.height = ceil(titleSize.height);
    CGFloat imageWidth = hasImage ? 80 : 0;
    CGFloat imageHeight = hasImage ? 80 : 0;
    CGFloat itemHeight = imageHeight + (hasImage && hasTitle ? 12 : 0) + titleSize.height + (hasImage && hasTitle ? 2 : 0);
    CGFloat itemTop = (CGRectGetHeight(self.bounds) - itemHeight) / 2;
    CGFloat titleY = itemTop + itemHeight - titleSize.height - (hasImage && hasTitle ? 2 : 0);
    self.textLabel.frame = hasTitle ? CGRectMake((CGRectGetWidth(self.bounds) - titleSize.width) / 2 + self.itemTitleOffset.horizontal,
        titleY + self.itemTitleOffset.vertical, titleSize.width, titleSize.height) : CGRectZero;
    // Adapted from CYLFlatDesignTabBarButton in CYLTabBarController (MIT license).
    CGFloat imageY = hasTitle ? itemTop + (CGRectGetMinY(self.textLabel.frame) - itemTop - imageHeight) / 2 : itemTop;
    self.imageView.frame = hasImage ? CGRectMake((CGRectGetWidth(self.bounds) - imageWidth) / 2 + self.itemImageOffset.horizontal,
        imageY + self.itemImageOffset.vertical, MAX(0, imageWidth - self.itemImageInsets.left - self.itemImageInsets.right),
        MAX(0, imageHeight - self.itemImageInsets.top - self.itemImageInsets.bottom)) : CGRectZero;
}

+ (NSString *)imageNameForStyle:(CYLPlaceholderStyle)style {
    static NSArray<NSString *> *names;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @[
            @"Empty", @"NoResults", @"Error", @"WifiOff", @"SignalWifiOff", @"NoInternet",
            @"CloudOff", @"SyncProblem", @"SyncDisabled", @"NetworkLocked", @"BluetoothDisabled",
            @"LocationOff", @"PublicOff", @"ErrorOutline", @"Warning", @"ReportProblem", @"Blocked",
            @"Help", @"Hourglass", @"Locked", @"VisibilityOff", @"SearchOff", @"FolderOff",
            @"FolderOpen", @"DownloadOff", @"UploadOff", @"Inbox", @"BrokenImage", @"ImageUnavailable",
            @"PhotoLibrary", @"MusicOff", @"VideoOff", @"PersonOff", @"GroupOff", @"EventBusy",
            @"EmptyCart", @"Favorite", @"BatteryAlert", @"UnknownDevice", @"PhoneDisabled",
            @"WrongLocation", @"Archive", @"Info", @"Refresh", @"Delete", @"Search", @"Mail",
            @"Image", @"Cloud", @"NotificationsOff", @"History"
        ];
    });
    if (style < 0 || style >= names.count) {
        NSLog(@"CYLTableViewPlaceHolder: invalid placeholder style %ld.", (long)style);
        return nil;
    }
    return [@"CYLPlaceholder" stringByAppendingString:names[style]];
}

+ (UIImage *)imageForStyle:(CYLPlaceholderStyle)style {
    NSString *name = [self imageNameForStyle:style];
    if (!name) return nil;
    NSBundle *bundle = CYLPlaceholderResourceBundle();
    if (!bundle) return nil;
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    if (!image) {
        NSLog(@"CYLTableViewPlaceHolder: missing placeholder image %@.", name);
        return nil;
    }
    return style == CYLPlaceholderStyleEmpty ? image : [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (NSString *)localizedTextForMessage:(CYLPlaceholderMessage)message {
    static NSArray<NSString *> *keys;
    static NSArray<NSString *> *fallbacks;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[@"CYLPlaceholderEmptyText", @"CYLPlaceholderNoResultsText", @"CYLPlaceholderNoInternetText",
                 @"CYLPlaceholderServerUnavailableText", @"CYLPlaceholderErrorText", @"CYLPlaceholderLoadingText",
                 @"CYLPlaceholderNoPermissionText", @"CYLPlaceholderEmptyCartText", @"CYLPlaceholderNoNotificationsText"];
        fallbacks = @[@"Nothing here yet", @"No results found", @"No internet connection",
                      @"Server unavailable", @"Something went wrong", @"Loading",
                      @"Access unavailable", @"Your cart is empty", @"No notifications"];
    });
    if (message < 0 || message >= keys.count) {
        NSLog(@"CYLTableViewPlaceHolder: invalid placeholder message %ld.", (long)message);
        return nil;
    }
    NSBundle *bundle = CYLPlaceholderResourceBundle();
    if (!bundle) return fallbacks[message];
    NSArray<NSString *> *languages = @[@"en", @"zh-Hans", @"zh-Hant", @"ja"];
    NSString *language = [NSBundle preferredLocalizationsFromArray:languages
                                                    forPreferences:NSLocale.preferredLanguages].firstObject;
    NSString *path = [bundle pathForResource:language ofType:@"lproj"];
    NSBundle *localizedBundle = path ? [NSBundle bundleWithPath:path] : nil;
    if (!localizedBundle) {
        NSLog(@"CYLTableViewPlaceHolder: localization %@ is missing.", language);
        return fallbacks[message];
    }
    return [localizedBundle localizedStringForKey:keys[message] value:fallbacks[message] table:nil];
}

- (instancetype)initWithStyle:(CYLPlaceholderStyle)style message:(CYLPlaceholderMessage)message {
    return [self initWithImage:[CYLPlaceholderView imageForStyle:style]
                         text:[CYLPlaceholderView localizedTextForMessage:message]];
}

- (instancetype)initWithStyle:(CYLPlaceholderStyle)style text:(NSString *)text {
    return [self initWithImage:[CYLPlaceholderView imageForStyle:style] text:text];
}

- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.imageView.image = image;
        self.imageView.hidden = image == nil;
        self.textLabel.text = text;
        self.textLabel.hidden = text == nil;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:[CYLPlaceholderView imageForStyle:CYLPlaceholderStyleEmpty]];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.tintColor = UIColor.grayColor;
        _textLabel = [UILabel new];
        _textLabel.text = [CYLPlaceholderView localizedTextForMessage:CYLPlaceholderMessageEmpty];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = UIColor.grayColor;
        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[_imageView, _textLabel]];
        _contentStack = stack;
        _itemAttributes = @{};
        stack.axis = UILayoutConstraintAxisVertical;
        stack.spacing = 12;
        stack.alignment = UIStackViewAlignmentCenter;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:stack];
        NSLayoutConstraint *imageHeight = [_imageView.heightAnchor constraintEqualToConstant:80];
        imageHeight.priority = UILayoutPriorityDefaultHigh;
        NSLayoutConstraint *imageWidth = [_imageView.widthAnchor constraintEqualToConstant:80];
        _imageSizeConstraints = @[imageWidth, imageHeight];
        [NSLayoutConstraint activateConstraints:@[
            [stack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [stack.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [stack.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:16],
            [stack.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-16],
            imageWidth,
            imageHeight
        ]];
    }
    return self;
}

@end
