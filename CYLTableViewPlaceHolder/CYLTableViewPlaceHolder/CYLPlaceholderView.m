#import "CYLPlaceholderView.h"
#import "CYLPlaceholderLocalization.h"
#import <objc/runtime.h>

// [EN] CYLPlaceholderView is a subclass of CYLTabBarController's `CYLAnimatedItemView` (integration guide:
//      https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md).
//      The base class owns the icon (`imageView`), the title (`titleLabel`), the animation view and its player, the
//      display priority (the animation when it can play, else the static `image`, else the component's placeholder),
//      the failure fallbacks and the loading state of URL files. This class adds what a placeholder needs on top: the
//      item attributes, its own layout (margins, offsets, title chrome, the horizontal arrangement), the badge, the
//      selection indicator, the appearance layers, the tap handler and the playback policy (visibility, Reduce Motion,
//      repeat count). Animations play only through the engine (`CYL_ANIMATION_ENGINE_AVAILABLE`, evaluated by the base
//      class's header): always 1 in the framework target, Carthage and the XCFramework; 0 only with the CocoaPods Core
//      subspec alone, where the view shows static images and every engine call below is compiled out.
// [CN] CYLPlaceholderView 继承自 CYLTabBarController 的 `CYLAnimatedItemView`（接入文档见上面的链接）。基类负责图标（`imageView`）、标题
//      （`titleLabel`）、动画视图及其播放器、显示优先级（能播放时显示动画，否则显示静态 `image`，再否则显示组件的占位图）、失败回退以及 URL 文件的
//      加载状态。本类在其上加入占位图需要的部分：item 属性、自己的布局（边距、偏移、标题装饰、横向排列）、角标、选中指示、外观层级、点击事件与播放策略
//      （可见性、减弱动态效果、重复次数）。动画只通过引擎播放（`CYL_ANIMATION_ENGINE_AVAILABLE`，由基类头文件判断）：framework target、Carthage 与
//      XCFramework 中始终为 1；只有单独使用 CocoaPods Core 子库时为 0，此时只显示静态图片，下面所有引擎相关代码都不参与编译。

static NSArray<NSString *> *CYLPlaceholderAppearanceKeys(void);
static BOOL CYLPlaceholderSameValue(id a, id b);
#import <math.h>

#if CYL_ANIMATION_ENGINE_AVAILABLE
// [EN] The base class handles the engine's load and failure reports; it declares the protocol in its implementation
//      file, so this declaration lets the subclass call `super`.
// [CN] 基类处理引擎的加载与失败通知，但只在其实现文件中声明该协议；此声明让子类可以调用 `super`。
@interface CYLAnimatedItemView (CYLPlaceholderAnimationFailureHandling) <CYLTabBarItemAnimationFailureHandling>
@end
#endif


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
NSString *const CYLPlaceholderItemTitleBackgroundImage = @"CYLPlaceholderItemTitleBackgroundImage";
NSString *const CYLPlaceholderItemTitleBackgroundColor = @"CYLPlaceholderItemTitleBackgroundColor";
NSString *const CYLPlaceholderItemTitleBorderColor = @"CYLPlaceholderItemTitleBorderColor";
NSString *const CYLPlaceholderItemTitleBorderWidth = @"CYLPlaceholderItemTitleBorderWidth";
NSString *const CYLPlaceholderItemTitleCornerRadius = @"CYLPlaceholderItemTitleCornerRadius";
NSString *const CYLPlaceholderItemTitleContentInsets = @"CYLPlaceholderItemTitleContentInsets";
NSString *const CYLPlaceholderItemTitleMinimumWidth = @"CYLPlaceholderItemTitleMinimumWidth";
NSString *const CYLPlaceholderItemContentAxis = @"CYLPlaceholderItemContentAxis";
/// [EN] The gap between the icon and the title of a horizontal item. [CN] 横向排列时图标与标题的间距。
static const CGFloat CYLPlaceholderHorizontalSpacing = 5;
NSString *const CYLPlaceholderItemInteractionEnabled = @"CYLPlaceholderItemInteractionEnabled";
NSString *const CYLPlaceholderItemTapHighlightStyle = @"CYLPlaceholderItemTapHighlightStyle";
NSString *const CYLPlaceholderItemAnimationRepeatCount = @"CYLPlaceholderItemAnimationRepeatCount";
NSString *const CYLPlaceholderItemImages = @"CYLPlaceholderItemImages";
NSString *const CYLPlaceholderItemAnimationDuration = @"CYLPlaceholderItemAnimationDuration";
NSErrorDomain const CYLPlaceholderConfigurationErrorDomain = @"CYLPlaceholderConfigurationError";

// [EN] CYLPlaceholderResourceBundle() is the core resource lookup, declared in CYLPlaceholderLocalization.h.
// [CN] CYLPlaceholderResourceBundle() 是核心层的资源查找函数，声明在 CYLPlaceholderLocalization.h 中。

static NSString *const CYLPlaceholderAnimationsDirectory = @"Animations";

static NSError *CYLPlaceholderConfigurationError(NSString *description) {
    return [NSError errorWithDomain:CYLPlaceholderConfigurationErrorDomain code:CYLPlaceholderConfigurationErrorItemAttributes
                          userInfo:@{NSLocalizedDescriptionKey: description}];
}

static UIImage *CYLPlaceholderConfiguredImage(id value, NSBundle *imageBundle) {
    if ([value isKindOfClass:UIImage.class]) return value;
    if (![value isKindOfClass:NSString.class]) return nil;
    if ([value hasPrefix:@"system:"]) {
        if (@available(iOS 13.0, *)) return [UIImage systemImageNamed:[value substringFromIndex:7]];
        return nil;
    }
    NSBundle *bundle = imageBundle ?: CYLPlaceholderResourceBundle();
    return bundle ? [UIImage imageNamed:value inBundle:bundle compatibleWithTraitCollection:nil] : nil;
}

static UIImage *CYLPlaceholderAppearanceImage(UIImage *light, UIImage *dark) {
    if (!light || !dark) return light ?: dark;
    if (@available(iOS 13.0, *)) {
        UITraitCollection *lightStyle = [UITraitCollection traitCollectionWithTraitsFromCollections:@[
            [UITraitCollection traitCollectionWithDisplayScale:light.scale],
            [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]
        ]];
        UITraitCollection *darkStyle = [UITraitCollection traitCollectionWithTraitsFromCollections:@[
            [UITraitCollection traitCollectionWithDisplayScale:dark.scale],
            [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]
        ]];
        UIImage *lightVariant = [light.imageAsset imageWithTraitCollection:lightStyle] ?: light;
        UIImage *darkVariant = [dark.imageAsset imageWithTraitCollection:darkStyle] ?: dark;
        if (lightVariant.CGImage) {
            lightVariant = [[UIImage imageWithCGImage:lightVariant.CGImage scale:lightVariant.scale
                                           orientation:lightVariant.imageOrientation] imageWithRenderingMode:light.renderingMode];
        }
        if (darkVariant.CGImage) {
            darkVariant = [[UIImage imageWithCGImage:darkVariant.CGImage scale:darkVariant.scale
                                          orientation:darkVariant.imageOrientation] imageWithRenderingMode:dark.renderingMode];
        }
        UIImageAsset *asset = [UIImageAsset new];
        UITraitCollection *lightTraits = [UITraitCollection traitCollectionWithDisplayScale:lightVariant.scale];
        [asset registerImage:lightVariant withTraitCollection:lightTraits];
        [asset registerImage:darkVariant withTraitCollection:darkStyle];
        return [asset imageWithTraitCollection:UITraitCollection.currentTraitCollection];
    }
    return light;
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
    UIFont *font = (name.length && !weight) ? [UIFont fontWithName:name size:size] :
        [UIFont systemFontOfSize:size weight:weight.doubleValue];
    // Configured sizes are the default-text-size values; they scale with Dynamic Type.
    return font ? [[UIFontMetrics defaultMetrics] scaledFontForFont:font] : nil;
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
    double numbers[2] = {0};
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
    double numbers[4] = {0};
    if (!CYLPlaceholderNumbers(value, @[@[@"top"], @[@"left"], @[@"bottom"], @[@"right"]], numbers)) return NO;
    *insets = UIEdgeInsetsMake(numbers[0], numbers[1], numbers[2], numbers[3]);
    return YES;
}

// The `contentMode` animation option, as a number or a UIViewContentMode case name; aspect fit by default.
static UIViewContentMode CYLPlaceholderAnimationContentMode(id options) {
    UIViewContentMode contentMode = UIViewContentModeScaleAspectFit;
    id contentModeValue = [options isKindOfClass:NSDictionary.class] ? options[@"contentMode"] : nil;
    if ([contentModeValue isKindOfClass:NSNumber.class]) {
        NSInteger value = [contentModeValue integerValue];
        if (value >= UIViewContentModeScaleToFill && value <= UIViewContentModeBottomRight &&
            value != UIViewContentModeRedraw) contentMode = value;
    } else if ([contentModeValue isKindOfClass:NSString.class]) {
        NSDictionary<NSString *, NSNumber *> *names = @{
            @"scaleToFill": @(UIViewContentModeScaleToFill), @"scaleAspectFit": @(UIViewContentModeScaleAspectFit),
            @"scaleAspectFill": @(UIViewContentModeScaleAspectFill), @"center": @(UIViewContentModeCenter),
            @"top": @(UIViewContentModeTop), @"bottom": @(UIViewContentModeBottom),
            @"left": @(UIViewContentModeLeft), @"right": @(UIViewContentModeRight),
            @"topLeft": @(UIViewContentModeTopLeft), @"topRight": @(UIViewContentModeTopRight),
            @"bottomLeft": @(UIViewContentModeBottomLeft), @"bottomRight": @(UIViewContentModeBottomRight)
        };
        NSNumber *mode = names[contentModeValue];
        if (mode) contentMode = mode.integerValue;
        else NSLog(@"CYLTableViewPlaceHolder: unknown animation contentMode '%@'.", contentModeValue);
    }
    return contentMode;
}


#pragma mark - The base class's subviews

@interface CYLPlaceholderView (CYLPlaceholderSubviews)
- (void)cyl_imageViewDidSetImage:(UIImage *)image;
@end

// [EN] The base class creates `imageView` and `titleLabel` as a plain UIImageView and UILabel. CYLPlaceholderView
//      changes their class to these subclasses, which add no storage (so the change is safe): a value an app sets on
//      them directly lays the placeholder out again, as before, and a static image set on `imageView` becomes the base
//      class's `image`, which decides what the icon shows.
// [CN] 基类把 `imageView` 与 `titleLabel` 创建为普通的 UIImageView 与 UILabel。CYLPlaceholderView 将它们的类改为下面的子类（不增加存储，
//      因此修改是安全的）：应用直接设置的值会让占位图重新布局（与以前相同），设置到 `imageView` 的静态图片会成为基类的 `image`，由基类决定图标显示什么。
@interface CYLPlaceholderItemImageView : UIImageView
@end

@implementation CYLPlaceholderItemImageView
- (void)setImage:(UIImage *)image {
    [super setImage:image];
    UIView *owner = self.superview;
    if ([owner isKindOfClass:CYLPlaceholderView.class]) [(CYLPlaceholderView *)owner cyl_imageViewDidSetImage:image];
    [owner setNeedsLayout];
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self.superview setNeedsLayout];
}
@end

@interface CYLPlaceholderItemLabel : UILabel
@end

@implementation CYLPlaceholderItemLabel
- (void)setText:(NSString *)text {
    [super setText:text];
    [self.superview setNeedsLayout];
}
- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self.superview setNeedsLayout];
}
- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self.superview setNeedsLayout];
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self.superview setNeedsLayout];
}
@end

/// [EN] `fileURL` with the animation `options` in its fragment, in the format of CYLTabBarController's
///      `CYLTabBarAnimationURLWithOptions()` ("name=value&…", sorted, percent-encoded), which its animators read (the
///      Rive artboard, state machine…). `contentMode` and `animationSpeed` are applied by the view, not written.
/// [CN] 把动画 `options` 写入 `fileURL` 的 fragment，格式与 CYLTabBarController 的 `CYLTabBarAnimationURLWithOptions()` 相同（「名称=值&…」，
///      排序并百分号编码），由其 animator 读取（Rive 画板、状态机等）。`contentMode` 与 `animationSpeed` 由视图应用，不写入。
static NSURL *CYLPlaceholderAnimationURLWithOptions(NSURL *fileURL, NSDictionary *options) {
    if (!fileURL || ![options isKindOfClass:NSDictionary.class] || options.count == 0) return fileURL;
    NSMutableCharacterSet *allowed = [NSCharacterSet.URLQueryAllowedCharacterSet mutableCopy];
    [allowed removeCharactersInString:@"&=+#?"];
    NSMutableArray<NSString *> *items = [NSMutableArray array];
    NSArray *names = [[options.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id name, NSDictionary *bindings) {
        return [name isKindOfClass:NSString.class];
    }]] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *name in names) {
        if ([name isEqualToString:@"contentMode"] || [name isEqualToString:@"animationSpeed"]) continue;
        id value = options[name];
        NSString *text = [value isKindOfClass:NSString.class] ? value :
            ([value isKindOfClass:NSNumber.class] ? [value stringValue] : nil);
        NSString *encodedName = [name stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        NSString *encodedValue = [text stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        if (encodedName.length && encodedValue.length) [items addObject:[NSString stringWithFormat:@"%@=%@", encodedName, encodedValue]];
    }
    if (items.count == 0) return fileURL;
    NSURLComponents *components = [NSURLComponents componentsWithURL:fileURL resolvingAgainstBaseURL:YES];
    components.percentEncodedFragment = [items componentsJoinedByString:@"&"];
    return components.URL ?: fileURL;
}

#if CYL_ANIMATION_ENGINE_AVAILABLE

#pragma mark - Factories registered with +registerAnimationFactory:forFileExtension:

/// [EN] The options in `URL`'s fragment, as `CYLPlaceholderAnimationURLWithOptions()` writes them. [CN] `URL` fragment 中的选项。
static NSDictionary<NSString *, NSString *> *CYLPlaceholderAnimationOptionsFromURL(NSURL *URL) {
    NSString *fragment = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:YES].percentEncodedFragment;
    NSMutableDictionary<NSString *, NSString *> *options = [NSMutableDictionary dictionary];
    for (NSString *item in [fragment componentsSeparatedByString:@"&"]) {
        NSRange separator = [item rangeOfString:@"="];
        if (separator.location == NSNotFound || separator.location == 0) continue;
        NSString *name = [[item substringToIndex:separator.location] stringByRemovingPercentEncoding];
        NSString *value = [[item substringFromIndex:NSMaxRange(separator)] stringByRemovingPercentEncoding];
        if (name.length && value.length) options[name] = value;
    }
    return [options copy];
}

/// [EN] `URL` without its fragment: the animation file itself. [CN] 去掉 fragment 的 `URL`，即动画文件本身。
static NSURL *CYLPlaceholderAnimationFileURL(NSURL *URL) {
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:YES];
    components.fragment = nil;
    return components.URL ?: URL;
}

/// [EN] Plays a factory's `CYLPlaceholderAnimationPlayer` view through the engine's player protocol. It answers only
///      for what the view supports, so the base class sees the same features as before.
/// [CN] 通过引擎的播放器协议播放工厂创建的 `CYLPlaceholderAnimationPlayer` 视图；只对视图支持的功能作出响应，因此基类看到的功能与以前相同。
@interface CYLPlaceholderFactoryAnimationPlayer : CYLTabBarItemAnimationBasePlayer <CYLTabBarItemAnimationPlayer>
@end

@implementation CYLPlaceholderFactoryAnimationPlayer {
    CGFloat _progress;
    CGFloat _speed;
    BOOL _loops;
}

- (UIView<CYLPlaceholderAnimationPlayer> *)playerView {
    UIView *view = self.animationView;
    return [view conformsToProtocol:@protocol(CYLPlaceholderAnimationPlayer)] ? (UIView<CYLPlaceholderAnimationPlayer> *)view : nil;
}

- (BOOL)respondsToSelector:(SEL)selector {
    UIView<CYLPlaceholderAnimationPlayer> *view = self.playerView;
    if (selector == @selector(progress) || selector == @selector(setProgress:)) {
        return [view respondsToSelector:@selector(setAnimationProgress:)];
    }
    if (selector == @selector(animationSpeed) || selector == @selector(setAnimationSpeed:)) {
        return [view respondsToSelector:@selector(setAnimationSpeed:)];
    }
    if (selector == @selector(loops) || selector == @selector(setLoops:)) {
        return [view respondsToSelector:@selector(setAnimationRepeatCount:)];
    }
    if (selector == @selector(applyColors:traitCollection:)) {
        return [view respondsToSelector:@selector(setAnimationColors:)];
    }
    return [super respondsToSelector:selector];
}

- (void)play {
    [self.playerView play];
}

- (void)stop {
    [self.playerView stop];
}

- (void)showLastFrame {
    [self.playerView showLastFrame];
    _progress = 1;
}

- (CGFloat)progress {
    return _progress;
}

- (void)setProgress:(CGFloat)progress {
    UIView<CYLPlaceholderAnimationPlayer> *view = self.playerView;
    if ([view respondsToSelector:@selector(setAnimationProgress:)] && [view setAnimationProgress:progress]) _progress = progress;
}

- (CGFloat)animationSpeed {
    return _speed > 0 ? _speed : 1;
}

- (void)setAnimationSpeed:(CGFloat)animationSpeed {
    UIView<CYLPlaceholderAnimationPlayer> *view = self.playerView;
    if ([view respondsToSelector:@selector(setAnimationSpeed:)] && [view setAnimationSpeed:animationSpeed]) _speed = animationSpeed;
}

- (BOOL)loops {
    return _loops;
}

- (void)setLoops:(BOOL)loops {
    UIView<CYLPlaceholderAnimationPlayer> *view = self.playerView;
    if ([view respondsToSelector:@selector(setAnimationRepeatCount:)] && [view setAnimationRepeatCount:loops ? 0 : 1]) _loops = loops;
}

- (void)applyColors:(NSDictionary<NSString *, UIColor *> *)colors traitCollection:(UITraitCollection *)traitCollection {
    UIView<CYLPlaceholderAnimationPlayer> *view = self.playerView;
    if (colors && [view respondsToSelector:@selector(setAnimationColors:)] && ![view setAnimationColors:colors]) {
        NSLog(@"CYLTableViewPlaceHolder: animation color overrides are not supported by this player.");
    }
}

@end

/// [EN] A factory as an animator of the engine's registry, ahead of the built-in animators for its extension.
/// [CN] 作为引擎注册表中 animator 的工厂，对其扩展名优先于内置 animator。
@interface CYLPlaceholderFactoryAnimator : NSObject <CYLTabBarItemAnimator>
+ (NSString *)identifierForFileExtension:(NSString *)fileExtension;
- (instancetype)initWithFileExtension:(NSString *)fileExtension factory:(CYLPlaceholderAnimationFactory)factory;
@end

@implementation CYLPlaceholderFactoryAnimator {
    NSString *_identifier;
    NSArray<NSString *> *_fileExtensions;
    CYLPlaceholderAnimationFactory _factory;
}

+ (NSString *)identifierForFileExtension:(NSString *)fileExtension {
    return [@"CYLPlaceholderFactory." stringByAppendingString:fileExtension.lowercaseString];
}

- (instancetype)initWithFileExtension:(NSString *)fileExtension factory:(CYLPlaceholderAnimationFactory)factory {
    if (self = [super init]) {
        _identifier = [[self class] identifierForFileExtension:fileExtension];
        _fileExtensions = @[fileExtension.lowercaseString];
        _factory = [factory copy];
    }
    return self;
}

- (NSString *)identifier {
    return _identifier;
}

- (NSArray<NSString *> *)fileExtensions {
    return _fileExtensions;
}

- (CYLTabBarItemAnimatorPriority)priority {
    return 1000;
}

- (BOOL)canAnimateFileAtURL:(NSURL *)URL {
    return [_fileExtensions containsObject:URL.pathExtension.lowercaseString];
}

- (UIView *)animationViewWithURL:(NSURL *)URL size:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    NSError *error = nil;
    UIView<CYLPlaceholderAnimationPlayer> *view = _factory(CYLPlaceholderAnimationFileURL(URL), size, contentMode,
                                                           CYLPlaceholderAnimationOptionsFromURL(URL), &error);
    if (![view conformsToProtocol:@protocol(CYLPlaceholderAnimationPlayer)]) {
        NSLog(@"CYLTableViewPlaceHolder: animation could not be loaded: %@.", error.localizedDescription ?: @"factory returned no view");
        return nil;
    }
    // [EN] A late failure or the end of loading goes back through the engine to the base class, which shows the static
    //      image (or the placeholder) until the animation is ready and again after it fails.
    // [CN] 迟到的失败或加载完成经由引擎通知基类：动画就绪前以及失败后，基类显示静态图片（或占位图）。
    __weak UIView *weakView = view;
    view.errorHandler = ^(NSError *backendError) {
        NSLog(@"CYLTableViewPlaceHolder: animation failed: %@.", backendError.localizedDescription);
        UIView *strongView = weakView;
        if (strongView) CYLTabBarItemAnimationReportFailure(strongView, backendError);
    };
    view.readyHandler = ^{
        UIView *strongView = weakView;
        if (strongView) CYLTabBarItemAnimationReportLoaded(strongView);
    };
    if (!view.isReady) CYLTabBarItemAnimationMarkLoading(view);
    return view;
}

- (id<CYLTabBarItemAnimationPlayer>)playerForAnimationView:(UIView *)view {
    if (![view conformsToProtocol:@protocol(CYLPlaceholderAnimationPlayer)]) return nil;
    return [[CYLPlaceholderFactoryAnimationPlayer alloc] initWithAnimationView:view];
}

@end

#endif


@implementation CYLPlaceholderBadgeAppearance

+ (instancetype)sharedAppearance {
    static CYLPlaceholderBadgeAppearance *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[CYLPlaceholderBadgeAppearance alloc] init];
        // Apple's high-contrast system red (#D70015): white text on it is about 5.4:1, above WCAG AA's 4.5:1
        // for small text (pure red is 4.0:1 and fails the accessibility audit).
        shared.backgroundColor = [UIColor colorWithRed:0xD7 / 255.0 green:0x00 / 255.0 blue:0x15 / 255.0 alpha:1];
        shared.textColor = UIColor.whiteColor;
        // A bold caption 1 text-style font (12 points at the default text size), so badges follow Dynamic Type.
        // Not caption 2: Apple's accessibility audit reports caption 2 as only partially scaling.
        UIFontDescriptor *caption = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption1];
        caption = [caption fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] ?: caption;
        shared.font = [UIFont fontWithDescriptor:caption size:0];
        shared.cornerRadius = 0; // 0 means auto (height/2)
        shared.contentInsets = UIEdgeInsetsMake(4, 4, 4, 4); // CYLBadgeView: 8 points wider and taller than the text
        shared.animationDuration = 0.2;
        shared.animatesChanges = YES;
    });
    return shared;
}

@end

@interface CYLPlaceholderView ()
@property (nonatomic, copy, readwrite) NSDictionary<NSString *, id> *itemAttributes;
// [EN] Holds the badge label one level below the control, as the old inner item view did: a direct subview of the
//      accessibility element was still exposed to UI automation beside it. Same frame as the view, no touches.
// [CN] 让角标标签位于控件下一层，与原来的内部条目视图相同：作为无障碍元素的直接子视图时，它仍会与元素并列暴露给 UI 自动化。与视图同大小，不响应触摸。
@property (nonatomic, strong) UIView *badgeContainerView;
// [EN] Layout values from the item attributes (adapted from CYLFlatDesignTabBarButton). [CN] 来自 item 属性的布局值。
@property (nonatomic) UIOffset itemTitleOffset;
@property (nonatomic) UIOffset itemImageOffset;
@property (nonatomic) UIEdgeInsets itemImageInsets;
/// [EN] The size the animation is laid out at (`CYLPlaceholderItemAnimationSize`). [CN] 动画的布局尺寸。
@property (nonatomic) CGSize itemAnimationSize;
/// [EN] YES: the icon at the leading edge, the title after it (`CYLPlaceholderItemContentAxis`). [CN] YES：横向排列。
@property (nonatomic) BOOL horizontal;
/// [EN] Where the content was laid out last (the old inner item view's frame). [CN] 内容最近一次布局的位置。
@property (nonatomic) CGRect itemFrame;
// Title chrome (CYLPlaceholderItemTitle... keys); nil background view means a plain title.
@property (nonatomic, strong) UIImageView *titleBackgroundView;
@property (nonatomic) UIEdgeInsets titleContentInsets;
@property (nonatomic) CGFloat titleMinimumWidth;
@property (nonatomic) CGFloat titleCornerRadius;
@property (nonatomic, strong) UIColor *titleBorderColor;
@property (nonatomic) CGFloat titleBorderWidth;
@property (nonatomic, strong) NSBundle *animationImageBundle;
@property (nonatomic) BOOL animationStopped;
@property (nonatomic) BOOL animationShowsLastFrame;
@property (nonatomic, strong) NSNumber *animationSeekProgress;
/// [EN] The speed set with -setPlaceholderAnimationSpeed:, and the `animationSpeed` option. [CN] 显式设置的速度与选项中的速度。
@property (nonatomic, strong) NSNumber *explicitAnimationSpeed;
@property (nonatomic, strong) NSNumber *optionAnimationSpeed;
@property (nonatomic) UIViewContentMode animationContentMode;
@property (nonatomic, copy) NSDictionary<NSString *, UIColor *> *animationColors;
/// [EN] Replays a player N - 1 more times for a repeat count N > 1. [CN] 重复次数 N > 1 时再重播 N - 1 次。
@property (nonatomic, strong) NSTimer *repeatTimer;
@property (nonatomic) NSInteger remainingRepeats;
/// [EN] YES while a static image set on `imageView` is copied to the base class's `image`. [CN] 正在把静态图片同步给基类。
@property (nonatomic) BOOL syncingImage;
/// [EN] The subviews' alpha before the pressed highlight. [CN] 按下高亮前各子视图的 alpha。
@property (nonatomic, strong) NSMapTable<UIView *, NSNumber *> *highlightAlphas;
@property (nonatomic, readwrite, getter=isTapHighlighted) BOOL tapHighlighted;
/// Whether the tap API added the button trait, and the not-enabled trait, so it removes only what it added.
@property (nonatomic) BOOL tapAddedButtonTrait;
@property (nonatomic) BOOL tapAddedNotEnabledTrait;
@property (nonatomic, copy) NSString *selectedTitle;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIColor *selectedIconColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, strong) UIFont *selectedTitleFont;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, copy) NSString *normalTitle;
@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIColor *normalIconColor;
@property (nonatomic, strong) UIColor *normalBackgroundColor;
@property (nonatomic, strong) UIFont *normalTitleFont;
@property (nonatomic) BOOL normalImageHidden;
@property (nonatomic) BOOL normalTitleHidden;
@property (nonatomic) BOOL normalHasSelectedTrait;
@property (nonatomic, copy) NSString *accessibilityValueBeforeBadge;
@property (nonatomic, copy) NSString *appliedBadgeAccessibilityValue;
@property (nonatomic, strong) UIImageView *selectionIndicatorView;
// Appearance layers (see -cyl_applyAppearance), keyed by titleColor / iconColor / backgroundColor / titleFont.
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *appearanceBaselineValues;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *appearanceExplicitValues;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *appearanceAppliedValues;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *appearanceNormalValues;
// The shared badge appearance values last applied; a label value that differs was set by the caller and is kept.
@property (nonatomic, strong) UIFont *appliedBadgeFont;
@property (nonatomic, strong) UIColor *appliedBadgeTextColor;
@property (nonatomic, strong) UIColor *appliedBadgeBackgroundColor;

@end

/// A highlight style from a number or its name ("dim", "shrink", "none").
static BOOL CYLPlaceholderTapHighlightStyleFromValue(id value, NSInteger *style) {
    if ([value isKindOfClass:NSString.class]) {
        NSArray<NSString *> *names = @[@"dim", @"shrink", @"none"];
        NSUInteger index = [names indexOfObject:[value lowercaseString]];
        if (index == NSNotFound) return NO;
        *style = (NSInteger)index;
        return YES;
    }
    if (![value isKindOfClass:NSNumber.class]) return NO;
    double number = [value doubleValue];
    if (!isfinite(number) || number != floor(number) || number < (double)CYLPlaceholderTapHighlightStyleDim ||
        number > (double)CYLPlaceholderTapHighlightStyleNone) return NO;
    *style = (NSInteger)number;
    return YES;
}

/// A repeat count from a number (0 loops) or "loop" / "once".
static BOOL CYLPlaceholderRepeatCountFromValue(id value, NSInteger *count) {
    if ([value isKindOfClass:NSString.class]) {
        NSString *name = [value lowercaseString];
        if ([name isEqualToString:@"loop"]) { *count = 0; return YES; }
        if ([name isEqualToString:@"once"]) { *count = 1; return YES; }
        return NO;
    }
    if (![value isKindOfClass:NSNumber.class]) return NO;
    double number = [value doubleValue];
    if (!isfinite(number) || number != floor(number) || number < 0 || number > 10000) return NO;
    *count = (NSInteger)number;
    return YES;
}

// [EN] System image setting in this file is CYLPlaceholderView's own implementation (its image view, selection
//      indicator and title chrome); every other part of the project sets images through it.
// [CN] 本文件中的系统图片设置是 CYLPlaceholderView 自身的实现（图片视图、选中指示与标题底图）；项目其他部分都通过它设置图片。
@implementation CYLPlaceholderView

// [EN] Declared again in the header for the documentation; the base classes implement them.
// [CN] 为了文档在头文件中再次声明，由父类实现。
@dynamic imageView;
@dynamic selected;

- (UILabel *)textLabel {
    return self.titleLabel;
}

- (NSString *)title {
    // [EN] The base class's title is the label's text, which this class (and apps) set directly.
    // [CN] 基类的标题即标签文字，本类（以及应用）会直接设置它。
    return self.titleLabel.text;
}

+ (BOOL)registerAnimationFactory:(CYLPlaceholderAnimationFactory)factory forFileExtension:(NSString *)fileExtension {
    NSCharacterSet *invalid = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    if (![fileExtension isKindOfClass:NSString.class] || !fileExtension.length ||
        [fileExtension rangeOfCharacterFromSet:invalid].location != NSNotFound) {
        NSLog(@"CYLTableViewPlaceHolder: invalid animation extension.");
        return NO;
    }
#if CYL_ANIMATION_ENGINE_AVAILABLE
    if (factory) {
        [CYLTabBarItemAnimatorRegistry registerAnimator:[[CYLPlaceholderFactoryAnimator alloc] initWithFileExtension:fileExtension
                                                                                                             factory:factory]];
    } else {
        [CYLTabBarItemAnimatorRegistry unregisterAnimatorWithIdentifier:[CYLPlaceholderFactoryAnimator identifierForFileExtension:fileExtension]];
    }
    return YES;
#else
    NSLog(@"CYLTableViewPlaceHolder: animation factories need the animation engine; add an animation subspec.");
    return NO;
#endif
}

#pragma mark - Static image 静态图片

- (void)cyl_imageViewDidSetImage:(UIImage *)image {
    // [EN] The base class shows `image`, `selectedImage` or its placeholder in `imageView`; any other image was set by
    //      this class or the app, and becomes the base class's static image, so the base class keeps showing it.
    // [CN] 基类在 `imageView` 中显示 `image`、`selectedImage` 或占位图；其他图片由本类或应用设置，成为基类的静态图片，基类会继续显示它。
    if (self.syncingImage || image == self.image) return;
    if (image && (image == self.selectedImage || image == self.placeholderImage)) return;
    self.syncingImage = YES;
    [self cyl_preservingIconVisibility:^{
        self.image = image;
    }];
    self.syncingImage = NO;
}

/// [EN] YES while a ready animation covers the static image (the base class hides `imageView` then).
/// [CN] 就绪的动画覆盖静态图片时为 YES（此时基类隐藏 `imageView`）。
- (BOOL)cyl_animationCoversImage {
#if CYL_ANIMATION_ENGINE_AVAILABLE
    return self.animationView != nil && !CYLTabBarItemAnimationIsLoading(self.animationView);
#else
    return NO;
#endif
}

/// [EN] Runs `changes` (which let the base class update the icon) and keeps an icon the caller hid hidden: the base
///      class shows `imageView` whenever no animation covers it.
/// [CN] 执行 `changes`（其中基类会更新图标），并保持调用方隐藏的图标仍然隐藏：没有动画覆盖时基类总是显示 `imageView`。
- (void)cyl_preservingIconVisibility:(void (^)(void))changes {
    BOOL hiddenByCaller = self.imageView.hidden && self.imageView.image != nil && ![self cyl_animationCoversImage];
    changes();
    if (hiddenByCaller && ![self cyl_animationCoversImage] && !self.imageView.hidden) self.imageView.hidden = YES;
}

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
    id frames = attributes[CYLPlaceholderItemImages];
    if (frames && !attributes[CYLPlaceholderItemImage]) {
        // [EN] Image frames (Android's IMAGES and DURATION) become one animated image; Reduce Motion keeps the first.
        // [CN] 图片帧（Android 的 IMAGES 与 DURATION）合成为一张动图；“减弱动态效果”时只保留第一帧。
        id duration = attributes[CYLPlaceholderItemAnimationDuration];
        BOOL images = [frames isKindOfClass:NSArray.class] && [frames count] > 0;
        for (id frame in images ? frames : @[]) images = images && [frame isKindOfClass:UIImage.class];
        if (!images || (duration && (![duration isKindOfClass:NSNumber.class] || !isfinite([duration doubleValue]) ||
                                     [duration doubleValue] < 0))) {
            if (error) *error = CYLPlaceholderConfigurationError(@"Item images must be a non-empty array of images, "
                                                                 @"with a non-negative duration.");
            return nil;
        }
        NSArray<UIImage *> *list = frames;
        NSTimeInterval seconds = [duration doubleValue] > 0 ? [duration doubleValue] : list.count * 0.1;
        UIImage *image = (list.count == 1 || UIAccessibilityIsReduceMotionEnabled()) ? list.firstObject :
            [UIImage animatedImageWithImages:list duration:seconds];
        NSMutableDictionary<NSString *, id> *expanded = [attributes mutableCopy];
        expanded[CYLPlaceholderItemImage] = image ?: list.firstObject;
        attributes = expanded;
    }
    id title = attributes[CYLPlaceholderItemTitle];
    id imageValue = attributes[CYLPlaceholderItemImage];
    id style = attributes[CYLPlaceholderItemStyle];
    id message = attributes[CYLPlaceholderItemMessage];
    for (NSString *key in @[CYLPlaceholderItemStyle, CYLPlaceholderItemMessage]) {
        id value = attributes[key];
        NSInteger count = [key isEqualToString:CYLPlaceholderItemStyle] ? (NSInteger)CYLPlaceholderStyleCount : (NSInteger)CYLPlaceholderMessageCount;
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
    for (NSString *key in @[CYLPlaceholderItemTitleColor, CYLPlaceholderItemIconColor, CYLPlaceholderItemBackgroundColor,
                             CYLPlaceholderItemSelectedTitleColor, CYLPlaceholderItemSelectedIconColor,
                             CYLPlaceholderItemSelectedBackgroundColor, CYLPlaceholderItemTitleBackgroundColor,
                             CYLPlaceholderItemTitleBorderColor]) {
        if (attributes[key]) {
            UIColor *color = CYLPlaceholderColor(attributes[key]);
            if (!color) {
                if (error) *error = CYLPlaceholderConfigurationError([NSString stringWithFormat:@"Invalid color for %@.", key]);
                return nil;
            }
            colors[key] = color;
        }
    }
#pragma clang diagnostic push
// [EN] Reading a type key is fine without its engine (CYL_LOTTIE_REQUIRED and its siblings warn the app, not this file).
// [CN] 没有对应引擎时读取类型 key 也无妨（CYL_LOTTIE_REQUIRED 等只提醒应用，不针对本文件）。
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    for (NSString *key in @[CYLPlaceholderItemAnimationColors, CYLPlaceholderItemAnimationDarkColors,
                             CYLPlaceholderItemLottieDarkColors, CYLPlaceholderItemRiveDarkColors]) {
#pragma clang diagnostic pop
        id values = attributes[key];
        if (!values) continue;
        if (![values isKindOfClass:NSDictionary.class]) {
            if (error) *error = CYLPlaceholderConfigurationError([NSString stringWithFormat:@"Invalid animation colors for %@.", key]);
            return nil;
        }
        for (id path in values) {
            if (![path isKindOfClass:NSString.class] || ![path length] || !CYLPlaceholderColor(values[path])) {
                if (error) *error = CYLPlaceholderConfigurationError([NSString stringWithFormat:@"Invalid animation color entry for %@.", key]);
                return nil;
            }
        }
    }
    UIFont *font = attributes[CYLPlaceholderItemTitleFont] ? CYLPlaceholderFont(attributes[CYLPlaceholderItemTitleFont]) : nil;
    if (attributes[CYLPlaceholderItemTitleFont] && !font) {
        if (error) *error = CYLPlaceholderConfigurationError(@"Invalid title font.");
        return nil;
    }
    UIFont *selectedFont = attributes[CYLPlaceholderItemSelectedTitleFont] ?
        CYLPlaceholderFont(attributes[CYLPlaceholderItemSelectedTitleFont]) : nil;
    if (attributes[CYLPlaceholderItemSelectedTitleFont] && !selectedFont) {
        if (error) *error = CYLPlaceholderConfigurationError(@"Invalid selected title font.");
        return nil;
    }
    id selectedTitle = attributes[CYLPlaceholderItemSelectedTitle];
    if (selectedTitle && ![selectedTitle isKindOfClass:NSString.class]) {
        if (error) *error = CYLPlaceholderConfigurationError(@"The selected title must be a string.");
        return nil;
    }
    id selectedImageValue = attributes[CYLPlaceholderItemSelectedImage];
    UIImage *selectedImage = selectedImageValue ? CYLPlaceholderConfiguredImage(selectedImageValue, imageBundle) : nil;
    if (selectedImageValue && !selectedImage) {
        if (error) *error = CYLPlaceholderConfigurationError(@"The selected image could not be loaded.");
        return nil;
    }
    id darkImageValue = attributes[CYLPlaceholderItemDarkImage];
    id selectedDarkImageValue = attributes[CYLPlaceholderItemSelectedDarkImage];
    UIImage *darkImage = darkImageValue ? CYLPlaceholderConfiguredImage(darkImageValue, imageBundle) : nil;
    UIImage *selectedDarkImage = selectedDarkImageValue ? CYLPlaceholderConfiguredImage(selectedDarkImageValue, imageBundle) : nil;
    if ((darkImageValue && !darkImage) || (selectedDarkImageValue && !selectedDarkImage)) {
        if (error) *error = CYLPlaceholderConfigurationError(@"A dark image could not be loaded.");
        return nil;
    }
    image = CYLPlaceholderAppearanceImage(image, darkImage);
    selectedImage = CYLPlaceholderAppearanceImage(selectedImage, selectedDarkImage);
    for (NSString *key in @[CYLPlaceholderItemAccessibilityIdentifier, CYLPlaceholderItemAccessibilityLabel, CYLPlaceholderItemAccessibilityHint]) {
        if (attributes[key] && ![attributes[key] isKindOfClass:NSString.class]) {
            if (error) *error = CYLPlaceholderConfigurationError([NSString stringWithFormat:@"Invalid accessibility value for %@.", key]);
            return nil;
        }
    }
    id titleBackgroundImageValue = attributes[CYLPlaceholderItemTitleBackgroundImage];
    UIImage *titleBackgroundImage = titleBackgroundImageValue ?
        CYLPlaceholderConfiguredImage(titleBackgroundImageValue, imageBundle) : nil;
    if (titleBackgroundImageValue && !titleBackgroundImage) {
        if (error) *error = CYLPlaceholderConfigurationError(@"The title background image could not be loaded.");
        return nil;
    }
    CGFloat titleChromeNumbers[3] = {0, 0, 0};
    NSArray<NSString *> *titleChromeNumberKeys = @[CYLPlaceholderItemTitleBorderWidth, CYLPlaceholderItemTitleCornerRadius,
                                                   CYLPlaceholderItemTitleMinimumWidth];
    for (NSUInteger index = 0; index < titleChromeNumberKeys.count; index++) {
        id value = attributes[titleChromeNumberKeys[index]];
        if (!value) continue;
        if (![value isKindOfClass:NSNumber.class] || !isfinite([value doubleValue]) ||
            [value doubleValue] < 0 || [value doubleValue] > 1000) {
            if (error) *error = CYLPlaceholderConfigurationError([NSString stringWithFormat:@"Invalid value for %@.",
                                                                  titleChromeNumberKeys[index]]);
            return nil;
        }
        titleChromeNumbers[index] = [value doubleValue];
    }
    UIEdgeInsets titleContentInsets = UIEdgeInsetsZero;
    id titleInsetsValue = attributes[CYLPlaceholderItemTitleContentInsets];
    if (titleInsetsValue && (!CYLPlaceholderInsets(titleInsetsValue, &titleContentInsets) ||
        titleContentInsets.top < 0 || titleContentInsets.left < 0 ||
        titleContentInsets.bottom < 0 || titleContentInsets.right < 0)) {
        if (error) *error = CYLPlaceholderConfigurationError(@"Invalid title content insets.");
        return nil;
    }
    BOOL hasTitleChrome = titleBackgroundImage || colors[CYLPlaceholderItemTitleBackgroundColor] ||
        colors[CYLPlaceholderItemTitleBorderColor] || titleChromeNumbers[0] > 0 || titleChromeNumbers[1] > 0 ||
        titleChromeNumbers[2] > 0 || !UIEdgeInsetsEqualToEdgeInsets(titleContentInsets, UIEdgeInsetsZero);
    id interactionValue = attributes[CYLPlaceholderItemInteractionEnabled];
    if (interactionValue && ![interactionValue isKindOfClass:NSNumber.class]) {
        if (error) *error = CYLPlaceholderConfigurationError(@"Interaction enabled must be a boolean.");
        return nil;
    }
    NSInteger highlightStyle = CYLPlaceholderTapHighlightStyleDim;
    id highlightValue = attributes[CYLPlaceholderItemTapHighlightStyle];
    if (highlightValue && !CYLPlaceholderTapHighlightStyleFromValue(highlightValue, &highlightStyle)) {
        if (error) *error = CYLPlaceholderConfigurationError(@"The tap highlight style must be dim, shrink or none.");
        return nil;
    }
    BOOL horizontal = NO;
    id axisValue = attributes[CYLPlaceholderItemContentAxis];
    if ([axisValue isKindOfClass:NSString.class] &&
        ([axisValue isEqualToString:@"horizontal"] || [axisValue isEqualToString:@"vertical"])) {
        horizontal = [axisValue isEqualToString:@"horizontal"];
    } else if ([axisValue isKindOfClass:NSNumber.class] &&
               ([axisValue integerValue] == UILayoutConstraintAxisHorizontal ||
                [axisValue integerValue] == UILayoutConstraintAxisVertical)) {
        horizontal = [axisValue integerValue] == UILayoutConstraintAxisHorizontal;
    } else if (axisValue) {
        if (error) *error = CYLPlaceholderConfigurationError(@"The content axis must be \"horizontal\" or \"vertical\".");
        return nil;
    }
    NSInteger repeatCount = 1;
    id repeatValue = attributes[CYLPlaceholderItemAnimationRepeatCount];
    if (repeatValue && !CYLPlaceholderRepeatCountFromValue(repeatValue, &repeatCount)) {
        if (error) *error = CYLPlaceholderConfigurationError(@"The animation repeat count must be 0 (loop) or more, \"loop\" or \"once\".");
        return nil;
    }
    self = [self initWithImage:image text:title];
    if (self) {
        _itemAttributes = [attributes copy];
        _tapInteractionEnabled = interactionValue ? [interactionValue boolValue] : YES;
        _tapHighlightStyle = highlightStyle;
        _animationRepeatCount = repeatCount;
        if (hasTitleChrome) {
            UIImageView *chrome = [[UIImageView alloc] initWithImage:titleBackgroundImage];
            chrome.contentMode = UIViewContentModeScaleToFill;
            chrome.backgroundColor = colors[CYLPlaceholderItemTitleBackgroundColor];
            chrome.clipsToBounds = YES;
            chrome.isAccessibilityElement = NO;
            self.titleBackgroundView = chrome;
            [self insertSubview:chrome belowSubview:self.textLabel];
            self.titleBorderColor = colors[CYLPlaceholderItemTitleBorderColor];
            self.titleBorderWidth = titleChromeNumbers[0];
            self.titleCornerRadius = titleChromeNumbers[1];
            self.titleMinimumWidth = titleChromeNumbers[2];
            self.titleContentInsets = titleContentInsets;
        }
        _animationImageBundle = imageBundle;
        // [EN] The base class shows it while selected. [CN] 选中时由基类显示。
        self.selectedImage = selectedImage;
        _selectedTitle = [selectedTitle copy];
        _selectedTitleColor = colors[CYLPlaceholderItemSelectedTitleColor];
        _selectedIconColor = colors[CYLPlaceholderItemSelectedIconColor];
        _selectedBackgroundColor = colors[CYLPlaceholderItemSelectedBackgroundColor];
        _selectedTitleFont = selectedFont;
        self.itemTitleOffset = titleOffset;
        self.itemImageOffset = imageOffset;
        self.itemImageInsets = insets;
        self.horizontal = horizontal;
        self.axis = horizontal ? CYLAnimatedItemAxisHorizontal : CYLAnimatedItemAxisVertical;
        if (horizontal) self.textLabel.textAlignment = NSTextAlignmentNatural;
        if (colors[CYLPlaceholderItemTitleColor]) self.textLabel.textColor = colors[CYLPlaceholderItemTitleColor];
        if (colors[CYLPlaceholderItemIconColor]) self.imageView.tintColor = colors[CYLPlaceholderItemIconColor];
        if (colors[CYLPlaceholderItemBackgroundColor]) self.backgroundColor = colors[CYLPlaceholderItemBackgroundColor];
        if (font) self.textLabel.font = font;
        NSDictionary<NSString *, id> *explicitValues = @{
            @"titleColor": colors[CYLPlaceholderItemTitleColor] ?: NSNull.null,
            @"iconColor": colors[CYLPlaceholderItemIconColor] ?: NSNull.null,
            @"backgroundColor": colors[CYLPlaceholderItemBackgroundColor] ?: NSNull.null,
            @"titleFont": font ?: NSNull.null
        };
        [explicitValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
            if (value == NSNull.null) return;
            self.appearanceExplicitValues[key] = value;
            self.appearanceAppliedValues[key] = value;
            self.appearanceNormalValues[key] = value;
        }];
        self.accessibilityIdentifier = attributes[CYLPlaceholderItemAccessibilityIdentifier];
        // Determine if the placeholder should be an accessibility element.
        // It should be an element if it has explicit accessibility attributes or
        // if it has meaningful content (image or text) and no explicit accessibility
        // label is provided by the container.
        BOOL hasExplicitAccessibility = attributes[CYLPlaceholderItemAccessibilityLabel] || attributes[CYLPlaceholderItemAccessibilityHint];
        BOOL hasContent = (image != nil) || ([title isKindOfClass:NSString.class] && [(NSString *)title length] > 0);
        if (hasExplicitAccessibility || hasContent) {
            self.isAccessibilityElement = YES;
            self.accessibilityLabel = attributes[CYLPlaceholderItemAccessibilityLabel] ?: title;
            self.accessibilityHint = attributes[CYLPlaceholderItemAccessibilityHint];
        }
        // Ensure subviews (imageView, textLabel) are not separate accessibility elements
        // when the placeholder itself is an accessibility element
        self.imageView.isAccessibilityElement = NO;
        self.textLabel.isAccessibilityElement = NO;
        [self cyl_configureAnimations];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(cyl_reduceMotionChanged:)
            name:UIAccessibilityReduceMotionStatusDidChangeNotification object:nil];
        [self setNeedsLayout];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (self.isSelected == selected) return;
    if (selected) {
        self.normalImage = self.imageView.image;
        self.normalTitle = self.textLabel.text;
        self.normalTitleColor = self.textLabel.textColor;
        self.normalIconColor = self.imageView.tintColor;
        self.normalBackgroundColor = self.backgroundColor;
        self.normalTitleFont = self.textLabel.font;
        self.normalImageHidden = self.imageView.hidden && ![self cyl_animationCoversImage];
        self.normalTitleHidden = self.textLabel.hidden;
        self.normalHasSelectedTrait = (self.accessibilityTraits & UIAccessibilityTraitSelected) != 0;
        // [EN] The base class shows `selectedImage` (the configured selected image) when there is one.
        // [CN] 有选中图片（配置的 `selectedImage`）时由基类显示。
        [super setSelected:YES];
        self.imageView.hidden = [self cyl_animationCoversImage] || (!self.selectedImage && self.normalImageHidden);
        if (self.selectedTitle) {
            self.textLabel.text = self.selectedTitle;
            self.textLabel.hidden = NO;
        }
        // Explicit selected values, then the selected appearance defaults, then the normal values.
        for (NSString *key in CYLPlaceholderAppearanceKeys()) {
            id value = [self cyl_desiredAppearanceValueForKey:key];
            [self cyl_setAppearanceTargetValue:value forKey:key];
            self.appearanceAppliedValues[key] = value ?: NSNull.null;
        }
        self.accessibilityTraits |= UIAccessibilityTraitSelected;
    } else {
        [super setSelected:NO];
        self.imageView.image = self.normalImage;
        self.imageView.hidden = self.normalImageHidden || [self cyl_animationCoversImage];
        self.textLabel.text = self.normalTitle;
        self.textLabel.hidden = self.normalTitleHidden;
        self.textLabel.textColor = self.normalTitleColor;
        self.imageView.tintColor = self.normalIconColor;
        self.backgroundColor = self.normalBackgroundColor;
        self.textLabel.font = self.normalTitleFont;
        for (NSString *key in CYLPlaceholderAppearanceKeys()) {
            id restored = [self cyl_appearanceTargetValueForKey:key] ?: NSNull.null;
            id normal = self.appearanceNormalValues[key];
            // Owned again only when the restored value is the one the appearance layers produced.
            if (CYLPlaceholderSameValue(restored, normal) ||
                ([key isEqualToString:@"iconColor"] && normal == NSNull.null && CYLPlaceholderSameValue(restored, self.tintColor))) {
                self.appearanceAppliedValues[key] = normal;
                if (normal == NSNull.null) [self cyl_setAppearanceTargetValue:nil forKey:key];
            } else {
                self.appearanceAppliedValues[key] = @"CYLPlaceholderCustomized";
            }
        }
        [self cyl_applyAppearance];
        if (!self.normalHasSelectedTrait) self.accessibilityTraits &= ~UIAccessibilityTraitSelected;
    }
    [self cyl_updateSelectionIndicator];
    [self setNeedsLayout];
}

- (void)setSelectionIndicatorImage:(UIImage *)image {
    _selectionIndicatorImage = image;
    [self cyl_updateSelectionIndicator];
}

- (void)setSelectionIndicatorTintColor:(UIColor *)color {
    _selectionIndicatorTintColor = color;
    [self cyl_updateSelectionIndicator];
}

- (void)cyl_updateSelectionIndicator {
    // Use explicit selection indicator image, then appearance proxy default
    UIImage *indicatorImage = self.selectionIndicatorImage ?: self.defaultSelectionIndicatorImage;
    UIColor *indicatorTintColor = self.selectionIndicatorTintColor ?: self.defaultSelectionIndicatorTintColor;

    if (!self.selected || !indicatorImage) {
        [self.selectionIndicatorView removeFromSuperview];
        self.selectionIndicatorView = nil;
        return;
    }
    if (!self.selectionIndicatorView) {
        self.selectionIndicatorView = [UIImageView new];
        self.selectionIndicatorView.userInteractionEnabled = NO;
        self.selectionIndicatorView.isAccessibilityElement = NO;
        [self insertSubview:self.selectionIndicatorView atIndex:0];
    }
    UIImage *image = indicatorImage;
    if (indicatorTintColor && image.renderingMode != UIImageRenderingModeAlwaysOriginal) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.selectionIndicatorView.image = image;
    self.selectionIndicatorView.tintColor = indicatorTintColor;
    self.selectionIndicatorView.contentMode = UIEdgeInsetsEqualToEdgeInsets(image.capInsets, UIEdgeInsetsZero) ?
        UIViewContentModeCenter : UIViewContentModeScaleToFill;
    self.selectionIndicatorView.frame = self.itemFrame;
}

// Applies `CYLPlaceholderBadgeAppearance` like CYLTabBarController's `_updateBadgeAppearance`: a value still equal to
// the one applied before follows the shared appearance; one the caller changed on `badgeLabel` is left alone.
- (void)cyl_applyBadgeAppearance {
    CYLPlaceholderBadgeAppearance *appearance = [CYLPlaceholderBadgeAppearance sharedAppearance];
    UILabel *label = self.badgeLabel;
    if (appearance.font && [label.font isEqual:self.appliedBadgeFont] && ![label.font isEqual:appearance.font]) {
        label.font = appearance.font;
    }
    if (appearance.textColor && [label.textColor isEqual:self.appliedBadgeTextColor] && ![label.textColor isEqual:appearance.textColor]) {
        label.textColor = appearance.textColor;
    }
    if (appearance.backgroundColor && (label.backgroundColor == self.appliedBadgeBackgroundColor ||
        [label.backgroundColor isEqual:self.appliedBadgeBackgroundColor]) && ![label.backgroundColor isEqual:appearance.backgroundColor]) {
        label.backgroundColor = appearance.backgroundColor;
    }
    if ([label.font isEqual:appearance.font]) self.appliedBadgeFont = label.font;
    if ([label.textColor isEqual:appearance.textColor]) self.appliedBadgeTextColor = label.textColor;
    if ([label.backgroundColor isEqual:appearance.backgroundColor]) self.appliedBadgeBackgroundColor = label.backgroundColor;
}

- (void)setBadgeValue:(NSString *)badgeValue {
    if (_badgeValue == badgeValue || [_badgeValue isEqualToString:badgeValue]) return;
    if (badgeValue && ![badgeValue isKindOfClass:NSString.class]) {
        NSLog(@"CYLTableViewPlaceHolder: badge value must be a string.");
        return;
    }
    CYLPlaceholderBadgeAppearance *appearance = [CYLPlaceholderBadgeAppearance sharedAppearance];
    BOOL animate = appearance.animatesChanges && appearance.animationDuration > 0 && badgeValue != nil &&
        self.window != nil && !UIAccessibilityIsReduceMotionEnabled();
    if (!_badgeValue && badgeValue) {
        self.accessibilityValueBeforeBadge = self.accessibilityValue;
    } else if (_badgeValue && self.appliedBadgeAccessibilityValue &&
               ![self.accessibilityValue isEqualToString:self.appliedBadgeAccessibilityValue]) {
        // The caller replaced the value while the badge was shown: keep theirs.
        self.accessibilityValueBeforeBadge = self.accessibilityValue;
    }
    BOOL showsChange = (_badgeValue == nil) != (badgeValue == nil);
    _badgeValue = [badgeValue copy];

    // State changes are synchronous; only the pop below is animated.
    self.badgeLabel.text = badgeValue;
    self.badgeLabel.hidden = badgeValue == nil;
    if (badgeValue) {
        [self cyl_applyBadgeAppearance];
        if (!self.badgeContainerView) {
            UIView *container = [[UIView alloc] initWithFrame:self.bounds];
            container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            container.userInteractionEnabled = NO;
            container.isAccessibilityElement = NO;
            self.badgeContainerView = container;
        }
        if (self.badgeContainerView.superview != self) [self addSubview:self.badgeContainerView];
        if (self.badgeLabel.superview != self.badgeContainerView) [self.badgeContainerView addSubview:self.badgeLabel];
    } else {
        [self.badgeLabel.layer removeAllAnimations];
        self.badgeLabel.transform = CGAffineTransformIdentity;
        self.badgeLabel.alpha = 1;
        [self.badgeLabel removeFromSuperview];
        [self.badgeContainerView removeFromSuperview];
    }
    // One announcement, no duplicates: when the placeholder is itself an accessibility element, the badge joins its
    // value and the badge label is hidden from VoiceOver; otherwise the badge label is read on its own.
    BOOL placeholderIsAccessibilityElement = self.isAccessibilityElement;
    self.badgeLabel.isAccessibilityElement = !placeholderIsAccessibilityElement;
    // [EN] Now a direct subview of the control (the old inner item view is gone): hide it from the accessibility tree too,
    //      or it is still exposed beside the element.
    // [CN] 现在它直接是控件的子视图（原来的内部条目视图已删除）：同时从无障碍树中隐藏，否则仍会与元素并列出现。
    self.badgeLabel.accessibilityElementsHidden = placeholderIsAccessibilityElement;
    self.badgeContainerView.accessibilityElementsHidden = placeholderIsAccessibilityElement;
    if (badgeValue) {
        NSString *description = badgeValue.length ? badgeValue :
            CYLPlaceholderLocalizedString(@"CYLPlaceholderBadgeNewContent", @"New content");
        self.badgeLabel.accessibilityLabel = description;
        NSString *baseValue = self.accessibilityValueBeforeBadge;
        NSString *value = (placeholderIsAccessibilityElement && baseValue.length) ?
            [NSString stringWithFormat:@"%@, %@", baseValue, description] : description;
        self.accessibilityValue = value;
        self.appliedBadgeAccessibilityValue = value;
    } else {
        if (self.appliedBadgeAccessibilityValue &&
            [self.accessibilityValue isEqualToString:self.appliedBadgeAccessibilityValue]) {
            self.accessibilityValue = self.accessibilityValueBeforeBadge;
        }
        self.appliedBadgeAccessibilityValue = nil;
        self.accessibilityValueBeforeBadge = nil;
    }
    [self setNeedsLayout];
    if (showsChange) {
        // [EN] A badge that appears or disappears changes the accessibility tree: tell assistive technologies, or a
        //      cached tree (inside a semantic-group container, for example) keeps reading the old badge.
        //      nil keeps VoiceOver's focus where it is.
        // [CN] 角标出现或消失会改变无障碍树：通知辅助技术，否则缓存的树（例如语义分组容器中）会继续朗读旧角标。
        //      参数为 nil，VoiceOver 焦点保持不动。
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    }
    if (animate) {
        self.badgeLabel.transform = CGAffineTransformMakeScale(0.6, 0.6);
        self.badgeLabel.alpha = 0.5;
        [UIView animateWithDuration:appearance.animationDuration delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            self.badgeLabel.transform = CGAffineTransformIdentity;
            self.badgeLabel.alpha = 1;
        } completion:nil];
    }
}

- (void)setBadgeCenterOffset:(CGPoint)badgeCenterOffset {
    if (!isfinite(badgeCenterOffset.x) || !isfinite(badgeCenterOffset.y)) {
        NSLog(@"CYLTableViewPlaceHolder: badge offset must be finite.");
        return;
    }
    _badgeCenterOffset = badgeCenterOffset;
    [self setNeedsLayout];
}

- (BOOL)showBadgeWithStyle:(CYLPlaceholderBadgeStyle)style value:(NSString *)value {
    switch (style) {
        case CYLPlaceholderBadgeStyleNone:
            self.badgeValue = nil;
            return YES;
        case CYLPlaceholderBadgeStyleDot:
            self.badgeValue = @"";
            return YES;
        case CYLPlaceholderBadgeStyleText:
            if ([value isKindOfClass:NSString.class] && value.length) {
                self.badgeValue = value;
                return YES;
            }
            break;
        case CYLPlaceholderBadgeStyleNumber: {
            if (![value isKindOfClass:NSString.class] || !value.length) break;
            NSScanner *scanner = [NSScanner scannerWithString:value];
            scanner.charactersToBeSkipped = nil;
            long long number;
            if (![scanner scanLongLong:&number] || !scanner.isAtEnd) break;
            self.badgeValue = number <= 0 ? nil : (number > 99 ? @"99+" : [NSString stringWithFormat:@"%lld", number]);
            return YES;
        }
        default:
            break;
    }
    NSLog(@"CYLTableViewPlaceHolder: invalid badge style or value.");
    return NO;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // A text-size change can arrive as a trait change only (no notification): re-measure title and badge.
    if (![self.traitCollection.preferredContentSizeCategory isEqualToString:previousTraitCollection.preferredContentSizeCategory]) {
        [self setNeedsLayout];
    }
    if (self.itemAttributes && previousTraitCollection &&
        self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle) {
        [self cyl_configureAnimations];
        [self cyl_updateAnimationPlayback];
    }
    // Update selection indicator for trait changes when selected
    if (self.selected && (self.selectionIndicatorImage || self.defaultSelectionIndicatorImage)) {
        [self cyl_updateSelectionIndicator];
    }
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    // Like the FlatDesign button: an icon without an explicit or appearance color follows the tint color.
    [self cyl_applyAppearance];
}

#pragma mark - Appearance layers

static NSArray<NSString *> *CYLPlaceholderAppearanceKeys(void) {
    return @[@"titleColor", @"iconColor", @"backgroundColor", @"titleFont"];
}

static BOOL CYLPlaceholderSameValue(id a, id b) {
    if (a == NSNull.null) a = nil;
    if (b == NSNull.null) b = nil;
    return a == b || [a isEqual:b];
}

static id CYLPlaceholderNilIfNull(id value) {
    return value == NSNull.null ? nil : value;
}

- (id)cyl_appearanceTargetValueForKey:(NSString *)key {
    if ([key isEqualToString:@"titleColor"]) return self.textLabel.textColor;
    if ([key isEqualToString:@"iconColor"]) return self.imageView.tintColor;
    if ([key isEqualToString:@"backgroundColor"]) return self.backgroundColor;
    return self.textLabel.font;
}

- (void)cyl_setAppearanceTargetValue:(id)value forKey:(NSString *)key {
    value = CYLPlaceholderNilIfNull(value);
    if ([key isEqualToString:@"titleColor"]) self.textLabel.textColor = value;
    else if ([key isEqualToString:@"iconColor"]) self.imageView.tintColor = value;
    else if ([key isEqualToString:@"backgroundColor"]) self.backgroundColor = value;
    else if (value) self.textLabel.font = value;
}

/// YES when the value is still the one the appearance layers set (or the inherited tint for the icon).
- (BOOL)cyl_ownsAppearanceValue:(id)current forKey:(NSString *)key {
    id applied = self.appearanceAppliedValues[key];
    if ([key isEqualToString:@"iconColor"] && applied == NSNull.null) {
        return CYLPlaceholderSameValue(current, self.tintColor);
    }
    return CYLPlaceholderSameValue(current, applied);
}

/// Normal: explicit item value, appearance default, built-in value (the icon follows the tint color).
- (id)cyl_normalAppearanceValueForKey:(NSString *)key {
    id explicitValue = self.appearanceExplicitValues[key];
    if (explicitValue) return explicitValue;
    NSDictionary<NSString *, id> *defaults = @{
        @"titleColor": self.defaultTitleColor ?: NSNull.null, @"iconColor": self.defaultIconColor ?: NSNull.null,
        @"backgroundColor": self.defaultBackgroundColor ?: NSNull.null, @"titleFont": self.defaultTitleFont ?: NSNull.null
    };
    id defaultValue = CYLPlaceholderNilIfNull(defaults[key]);
    if (defaultValue) return defaultValue;
    return CYLPlaceholderNilIfNull(self.appearanceBaselineValues[key]);
}

/// Selected: explicit selected value, selected appearance default, the normal value.
- (id)cyl_desiredAppearanceValueForKey:(NSString *)key {
    if (!self.selected) return [self cyl_normalAppearanceValueForKey:key];
    NSDictionary<NSString *, id> *selectedValues = @{
        @"titleColor": self.selectedTitleColor ?: self.defaultSelectedTitleColor ?: NSNull.null,
        @"iconColor": self.selectedIconColor ?: self.defaultSelectedIconColor ?: NSNull.null,
        @"backgroundColor": self.selectedBackgroundColor ?: self.defaultSelectedBackgroundColor ?: NSNull.null,
        @"titleFont": self.selectedTitleFont ?: self.defaultSelectedTitleFont ?: NSNull.null
    };
    id value = CYLPlaceholderNilIfNull(selectedValues[key]);
    if (value) return value;
    NSDictionary<NSString *, id> *snapshot = @{
        @"titleColor": self.normalTitleColor ?: NSNull.null, @"iconColor": self.normalIconColor ?: NSNull.null,
        @"backgroundColor": self.normalBackgroundColor ?: NSNull.null, @"titleFont": self.normalTitleFont ?: NSNull.null
    };
    return CYLPlaceholderNilIfNull(snapshot[key]);
}

/// Re-applies the layers to every value the library still owns: one the caller set directly is left alone.
- (void)cyl_applyAppearance {
    if (!self.appearanceAppliedValues) return;
    for (NSString *key in CYLPlaceholderAppearanceKeys()) {
        id normal = [self cyl_normalAppearanceValueForKey:key];
        if (self.selected) {
            // Keep the normal snapshot current, so deselecting shows the latest appearance.
            NSDictionary<NSString *, NSString *> *snapshotKeys = @{
                @"titleColor": @"normalTitleColor", @"iconColor": @"normalIconColor",
                @"backgroundColor": @"normalBackgroundColor", @"titleFont": @"normalTitleFont"
            };
            id snapshot = [self valueForKey:snapshotKeys[key]];
            if (CYLPlaceholderSameValue(snapshot, self.appearanceNormalValues[key]) && (normal || ![key isEqualToString:@"titleFont"])) {
                [self setValue:normal forKey:snapshotKeys[key]];
                self.appearanceNormalValues[key] = normal ?: NSNull.null;
            }
        }
        id current = [self cyl_appearanceTargetValueForKey:key];
        if (![self cyl_ownsAppearanceValue:current forKey:key]) continue;
        id desired = [self cyl_desiredAppearanceValueForKey:key];
        if ([key isEqualToString:@"titleFont"] && !desired) continue;
        if (!CYLPlaceholderSameValue(current, desired)) [self cyl_setAppearanceTargetValue:desired forKey:key];
        self.appearanceAppliedValues[key] = desired ?: NSNull.null;
        if (!self.selected) self.appearanceNormalValues[key] = desired ?: NSNull.null;
    }
    [self cyl_updateSelectionIndicator];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self cyl_applyAppearance];
}

#define CYL_PLACEHOLDER_APPEARANCE_SETTER(Setter, Type, ivar) \
- (void)Setter:(Type)value { ivar = value; [self cyl_applyAppearance]; }
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultTitleColor, UIColor *, _defaultTitleColor)
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultIconColor, UIColor *, _defaultIconColor)
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultBackgroundColor, UIColor *, _defaultBackgroundColor)
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultTitleFont, UIFont *, _defaultTitleFont)
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultSelectedTitleColor, UIColor *, _defaultSelectedTitleColor)
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultSelectedIconColor, UIColor *, _defaultSelectedIconColor)
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultSelectedBackgroundColor, UIColor *, _defaultSelectedBackgroundColor)
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultSelectedTitleFont, UIFont *, _defaultSelectedTitleFont)
- (void)setDefaultTitlePositionAdjustment:(UIOffset)adjustment {
    if (!isfinite(adjustment.horizontal) || !isfinite(adjustment.vertical)) {
        NSLog(@"CYLTableViewPlaceHolder: title position adjustment must be finite.");
        return;
    }
    _defaultTitlePositionAdjustment = adjustment;
    [self setNeedsLayout];
}
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultSelectionIndicatorImage, UIImage *, _defaultSelectionIndicatorImage)
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultSelectionIndicatorTintColor, UIColor *, _defaultSelectionIndicatorTintColor)
#undef CYL_PLACEHOLDER_APPEARANCE_SETTER

#pragma mark - Animation file 动画文件

- (BOOL)setAnimationFile:(NSString *)path {
    if (![path isKindOfClass:NSString.class] || path.length == 0) return NO;
    NSString *resolved = path.isAbsolutePath ? path : ([CYLPlaceholderView pathForBundledAnimation:path] ?: path);
    if (![NSFileManager.defaultManager fileExistsAtPath:resolved]) return NO;
    NSDictionary<NSString *, id> *previous = self.itemAttributes ?: @{};
    NSMutableDictionary<NSString *, id> *attributes = [previous mutableCopy];
#pragma clang diagnostic push
// [EN] Reading a type key is fine without its engine (CYL_LOTTIE_REQUIRED and its siblings warn the app, not this file).
// [CN] 没有对应引擎时读取类型 key 也无妨（CYL_LOTTIE_REQUIRED 等只提醒应用，不针对本文件）。
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    for (NSString *key in @[CYLPlaceholderItemAnimationURL, CYLPlaceholderItemGIFFilePath, CYLPlaceholderItemGIFURL,
                            CYLPlaceholderItemLottieFilePath, CYLPlaceholderItemLottieURL, CYLPlaceholderItemPAGFilePath,
                            CYLPlaceholderItemPAGURL, CYLPlaceholderItemRiveFilePath, CYLPlaceholderItemRiveURL]) {
#pragma clang diagnostic pop
        [attributes removeObjectForKey:key];
    }
    attributes[CYLPlaceholderItemAnimationFilePath] = resolved;
    if (!attributes[CYLPlaceholderItemAnimationSize]) attributes[CYLPlaceholderItemAnimationSize] = @[@64, @64];
    self.itemAttributes = attributes;
    [self cyl_configureAnimations];
    if (!self.animationView) {
        // [EN] No animator plays it (always the case without the engine): keep the icon, as Android does.
        // [CN] 没有动画器可播放（没有引擎时总是如此）：保留图标，与 Android 相同。
        self.itemAttributes = previous;
        [self cyl_configureAnimations];
        return NO;
    }
    [self setNeedsLayout];
    return YES;
}

/// [EN] The animation file of the item attributes (the engine-specific keys first, then the generic ones), with its
///      size and options; nil when there is none or it is invalid.
/// [CN] item 属性中的动画文件（先看各引擎专用的 key，再看通用 key）及其尺寸与选项；没有或无效时返回 nil。
- (NSURL *)cyl_animationURLFromAttributes:(NSDictionary *)attributes size:(CGSize *)outSize options:(NSDictionary **)outOptions {
#pragma clang diagnostic push
// [EN] Reading a type key is fine without its engine (CYL_LOTTIE_REQUIRED and its siblings warn the app, not this file).
// [CN] 没有对应引擎时读取类型 key 也无妨（CYL_LOTTIE_REQUIRED 等只提醒应用，不针对本文件）。
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSArray *sources = @[
        @[CYLPlaceholderItemGIFURL, CYLPlaceholderItemGIFFilePath, CYLPlaceholderItemGIFSize],
        @[CYLPlaceholderItemLottieURL, CYLPlaceholderItemLottieFilePath, CYLPlaceholderItemLottieSize],
        @[CYLPlaceholderItemPAGURL, CYLPlaceholderItemPAGFilePath, CYLPlaceholderItemPAGSize],
        @[CYLPlaceholderItemRiveURL, CYLPlaceholderItemRiveFilePath, CYLPlaceholderItemRiveSize],
#pragma clang diagnostic pop
        @[CYLPlaceholderItemAnimationURL, CYLPlaceholderItemAnimationFilePath, CYLPlaceholderItemAnimationSize]
    ];
    id value = nil, sizeValue = nil;
    for (NSArray *keys in sources) {
        value = attributes[keys[0]] ?: attributes[keys[1]];
        if (value) {
            sizeValue = attributes[keys[2]] ?: attributes[CYLPlaceholderItemAnimationSize];
            break;
        }
    }
    if (!value) return nil;
    NSURL *url = nil;
    if ([value isKindOfClass:NSURL.class]) {
        url = value;
    } else if ([value isKindOfClass:NSString.class] && [value length]) {
        NSString *path = value;
        if ([path containsString:@"://"]) {
            url = [NSURL URLWithString:path];
        } else {
            if (![path isAbsolutePath]) {
                NSBundle *bundle = self.animationImageBundle ?: NSBundle.mainBundle;
                path = [bundle pathForResource:path.stringByDeletingPathExtension ofType:path.pathExtension] ?: path;
            }
            url = [NSURL fileURLWithPath:path];
        }
    }
    if (!url) {
        NSLog(@"CYLTableViewPlaceHolder: invalid animation file.");
        return nil;
    }
    // [EN] Without a configured size: the static image's size, else 80 x 80. [CN] 未配置尺寸时：静态图片的尺寸，否则为 80 x 80。
    CGSize size = self.image ? self.image.size : CGSizeMake(80, 80);
    double numbers[2] = {0};
    if ([sizeValue isKindOfClass:NSValue.class] && strcmp([sizeValue objCType], @encode(CGSize)) == 0) {
        size = [sizeValue CGSizeValue];
    } else if (sizeValue && CYLPlaceholderNumbers(sizeValue, @[@[@"width", @"w"], @[@"height", @"h"]], numbers)) {
        size = CGSizeMake(numbers[0], numbers[1]);
    } else if (sizeValue) {
        NSLog(@"CYLTableViewPlaceHolder: invalid animation size.");
        return nil;
    }
    if (!isfinite(size.width) || !isfinite(size.height) || size.width <= 0 || size.height <= 0 ||
        size.width > 1000 || size.height > 1000) {
        NSLog(@"CYLTableViewPlaceHolder: invalid animation size.");
        return nil;
    }
    id options = attributes[CYLPlaceholderItemAnimationOptions] ?: @{};
    if (![options isKindOfClass:NSDictionary.class]) {
        NSLog(@"CYLTableViewPlaceHolder: animation options must be a dictionary.");
        return nil;
    }
    [self cyl_validateAnimationOptions:options forExtension:url.pathExtension.lowercaseString];
    *outSize = size;
    *outOptions = options;
    return CYLPlaceholderAnimationURLWithOptions(url, options);
}

/// [EN] Color overrides for the current appearance: `CYLPlaceholderItemAnimationColors`, plus the dark colors in Dark
///      Mode. [CN] 当前外观下的颜色覆盖：`CYLPlaceholderItemAnimationColors`，深色模式下再加上深色颜色。
- (NSDictionary<NSString *, UIColor *> *)cyl_animationColorsForAttributes:(NSDictionary *)attributes URL:(NSURL *)url {
    NSMutableDictionary<NSString *, UIColor *> *animationColors = [NSMutableDictionary dictionary];
    NSMutableArray *colorSources = [NSMutableArray array];
    if (attributes[CYLPlaceholderItemAnimationColors]) [colorSources addObject:attributes[CYLPlaceholderItemAnimationColors]];
    if (@available(iOS 13.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            if (attributes[CYLPlaceholderItemAnimationDarkColors]) [colorSources addObject:attributes[CYLPlaceholderItemAnimationDarkColors]];
            NSString *extension = url.pathExtension.lowercaseString;
#pragma clang diagnostic push
// [EN] Reading a type key is fine without its engine (CYL_LOTTIE_REQUIRED and its siblings warn the app, not this file).
// [CN] 没有对应引擎时读取类型 key 也无妨（CYL_LOTTIE_REQUIRED 等只提醒应用，不针对本文件）。
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            NSString *specificKey = [extension isEqualToString:@"json"] ? CYLPlaceholderItemLottieDarkColors :
                ([extension isEqualToString:@"riv"] ? CYLPlaceholderItemRiveDarkColors : nil);
#pragma clang diagnostic pop
            if (specificKey && attributes[specificKey]) [colorSources addObject:attributes[specificKey]];
        }
    }
    for (NSDictionary *source in colorSources) {
        if (![source isKindOfClass:NSDictionary.class]) continue;
        [source enumerateKeysAndObjectsUsingBlock:^(NSString *path, id value, BOOL *stop) {
            UIColor *color = CYLPlaceholderColor(value);
            if (@available(iOS 13.0, *)) color = [color resolvedColorWithTraitCollection:self.traitCollection];
            if ([path isKindOfClass:NSString.class] && color) animationColors[path] = color;
        }];
    }
    return animationColors;
}

- (void)cyl_configureAnimations {
    NSMutableDictionary *attributes = [self.itemAttributes mutableCopy] ?: [NSMutableDictionary dictionary];
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
#pragma clang diagnostic push
// [EN] Reading a type key is fine without its engine (CYL_LOTTIE_REQUIRED and its siblings warn the app, not this file).
// [CN] 没有对应引擎时读取类型 key 也无妨（CYL_LOTTIE_REQUIRED 等只提醒应用，不针对本文件）。
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSArray *pairs = @[
            @[CYLPlaceholderItemGIFURL, CYLPlaceholderItemGIFFilePath, CYLPlaceholderItemGIFDarkURL, CYLPlaceholderItemGIFDarkFilePath],
            @[CYLPlaceholderItemLottieURL, CYLPlaceholderItemLottieFilePath, CYLPlaceholderItemLottieDarkURL, CYLPlaceholderItemLottieDarkFilePath],
            @[CYLPlaceholderItemPAGURL, CYLPlaceholderItemPAGFilePath, CYLPlaceholderItemPAGDarkURL, CYLPlaceholderItemPAGDarkFilePath],
            @[CYLPlaceholderItemRiveURL, CYLPlaceholderItemRiveFilePath, CYLPlaceholderItemRiveDarkURL, CYLPlaceholderItemRiveDarkFilePath],
#pragma clang diagnostic pop
            @[CYLPlaceholderItemAnimationURL, CYLPlaceholderItemAnimationFilePath, CYLPlaceholderItemAnimationDarkURL, CYLPlaceholderItemAnimationDarkFilePath]
        ];
        for (NSArray *keys in pairs) {
            id darkURL = attributes[keys[2]];
            id darkPath = attributes[keys[3]];
            if (darkURL || darkPath) {
                [attributes removeObjectForKey:keys[0]];
                [attributes removeObjectForKey:keys[1]];
                if (darkURL) attributes[keys[0]] = darkURL;
                else attributes[keys[1]] = darkPath;
            }
        }
    }
    CGSize size = CGSizeZero;
    NSDictionary *options = nil;
    NSURL *url = [self cyl_animationURLFromAttributes:attributes size:&size options:&options];
    self.animationContentMode = CYLPlaceholderAnimationContentMode(options);
    self.animationColors = url ? [self cyl_animationColorsForAttributes:attributes URL:url] : nil;
    // [EN] The `animationSpeed` option is the per-item form of CYLTabBarController's `tabBarItemAnimationSpeed`; a speed
    //      set later with -setPlaceholderAnimationSpeed: wins.
    // [CN] `animationSpeed` 选项是 CYLTabBarController `tabBarItemAnimationSpeed` 的单项形式；之后用 -setPlaceholderAnimationSpeed: 设置的速度优先。
    id speedOption = options[@"animationSpeed"];
    double speed = [speedOption respondsToSelector:@selector(doubleValue)] ? [speedOption doubleValue] : NAN;
    BOOL validSpeed = speedOption && isfinite(speed) && speed > 0;
    if (speedOption && !validSpeed) NSLog(@"CYLTableViewPlaceHolder: animationSpeed must be positive.");
    self.optionAnimationSpeed = validSpeed ? @(speed) : nil;
    self.animationSpeed = (self.explicitAnimationSpeed ?: self.optionAnimationSpeed ?: @1).doubleValue;
    self.animationLoops = self.animationRepeatCount == 0;
    self.itemAnimationSize = url ? size : CGSizeZero;
    [self cyl_preservingIconVisibility:^{
        // [EN] Clear first, so the new size applies and the file is always loaded again (a trait change, a new file).
        // [CN] 先清空，使新尺寸生效并总是重新加载文件（外观变化、新文件）。
        self.animationURL = nil;
        if (url) {
            self.iconSize = size;
            self.animationURL = url;
        }
    }];
    [self setNeedsLayout];
}

- (void)reloadAnimation {
    [self cyl_stopRepeatTimer];
    [self cyl_preservingIconVisibility:^{
        [super reloadAnimation];
    }];
    [self cyl_configureAnimationPlayer];
    [self cyl_updateAnimationPlayback];
}

/// [EN] Applies what the base class does not: the content mode and the color overrides of the item attributes.
/// [CN] 应用基类不处理的部分：item 属性中的缩放方式与颜色覆盖。
- (void)cyl_configureAnimationPlayer {
#if CYL_ANIMATION_ENGINE_AVAILABLE
    UIView *view = self.animationView;
    id<CYLTabBarItemAnimationPlayer> player = self.animationPlayer;
    if (!view || !player) return;
    view.contentMode = self.animationContentMode;
    if (self.animationColors.count) {
        if ([player respondsToSelector:@selector(applyColors:traitCollection:)]) {
            [player applyColors:self.animationColors traitCollection:self.traitCollection];
        } else {
            NSLog(@"CYLTableViewPlaceHolder: animation color overrides are not supported by this player.");
        }
    }
    if ((self.explicitAnimationSpeed || self.optionAnimationSpeed) && ![player respondsToSelector:@selector(setAnimationSpeed:)]) {
        NSLog(@"CYLTableViewPlaceHolder: this animation does not support a playback speed.");
    }
    if (self.animationRepeatCount != 1 && ![player respondsToSelector:@selector(setLoops:)] &&
        ![player respondsToSelector:@selector(progress)]) {
        NSLog(@"CYLTableViewPlaceHolder: this animation does not support a repeat count of %ld; it plays as its file "
              @"defines.", (long)self.animationRepeatCount);
    }
#endif
}

#if CYL_ANIMATION_ENGINE_AVAILABLE
- (void)cylAnimationViewDidLoad:(UIView *)animationView {
    [super cylAnimationViewDidLoad:animationView];
    if (animationView == self.animationView) [self cyl_updateAnimationPlayback];
}

- (void)cylAnimationViewDidFail:(UIView *)animationView error:(NSError *)error {
    if (animationView == self.animationView) [self cyl_stopRepeatTimer];
    [self cyl_preservingIconVisibility:^{
        [super cylAnimationViewDidFail:animationView error:error];
    }];
    [self setNeedsLayout];
}
#endif

#pragma mark - Measuring and layout 测量与布局

/// [EN] The size an animation is laid out at. [CN] 动画的布局尺寸。
- (CGSize)cyl_animationBoxSize {
    if (self.itemAnimationSize.width > 0 && self.itemAnimationSize.height > 0) return self.itemAnimationSize;
    if (self.iconSize.width > 0 && self.iconSize.height > 0) return self.iconSize;
    return CGSizeMake(24, 24);
}

/// [EN] YES when the item attributes configure an animation file: its size is then the icon's, whatever shows in it (the
///      animation, or the static image or placeholder standing in for it, aspect fit), so the layout is the same with or
///      without an animation engine.
/// [CN] item 属性配置了动画文件时为 YES：此时图标尺寸即动画尺寸，无论其中显示的是动画，还是代替它的静态图片或占位图（等比缩放），因此有无动画引擎布局都相同。
- (BOOL)cyl_reservesAnimationBox {
    return self.itemAnimationSize.width > 0 && self.itemAnimationSize.height > 0;
}

/// [EN] YES when the animation view shows: it is hidden only with a static image the caller hid.
/// [CN] 动画视图是否显示：只有在调用方隐藏了静态图片时才隐藏。
- (BOOL)cyl_showsAnimationView {
    return self.animationView != nil &&
        (!self.imageView.image || !self.imageView.hidden || [self cyl_animationCoversImage]);
}

/// [EN] The title offset: the item's own, else the appearance's, as in CYLFlatDesignTabBarButton.
/// [CN] 标题偏移：优先使用 item 自己的，否则使用外观的，与 CYLFlatDesignTabBarButton 相同。
- (UIOffset)cyl_titleOffset {
    return UIOffsetEqualToOffset(self.itemTitleOffset, UIOffsetZero) ? self.defaultTitlePositionAdjustment : self.itemTitleOffset;
}

/// The item's content (image or animation, gap, title with its chrome) measured for a width, shared by the layout and
/// the intrinsic content size so the two cannot disagree.
- (CGSize)cyl_itemSizeForWidth:(CGFloat)width {
    BOOL showAnimation = [self cyl_showsAnimationView];
    BOOL hasImage = (self.imageView.image != nil && !self.imageView.hidden) || showAnimation;
    BOOL hasTitle = self.textLabel.text.length > 0 && !self.textLabel.hidden;
    UIEdgeInsets insets = hasTitle ? self.titleContentInsets : UIEdgeInsetsZero;
    CGFloat textWidth = MAX(0, width - insets.left - insets.right);
    CGSize titleSize = hasTitle ? [self.textLabel.text boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX)
        options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.textLabel.font} context:nil].size : CGSizeZero;
    CGSize imageSize = (showAnimation || (hasImage && [self cyl_reservesAnimationBox])) ? [self cyl_animationBoxSize] :
        (hasImage ? self.imageView.image.size : CGSizeZero);
    if (self.horizontal) {
        UIEdgeInsets imageInsets = self.itemImageInsets;
        CGSize icon = hasImage ? CGSizeMake(MAX(0, imageSize.width - imageInsets.left - imageInsets.right),
                                            MAX(0, imageSize.height - imageInsets.top - imageInsets.bottom)) : CGSizeZero;
        CGFloat gap = hasImage && hasTitle ? CYLPlaceholderHorizontalSpacing : 0;
        CGSize text = hasTitle ? [self.textLabel.text boundingRectWithSize:CGSizeMake(MAX(0, width - icon.width - gap), CGFLOAT_MAX)
            options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.textLabel.font} context:nil].size : CGSizeZero;
        return CGSizeMake(icon.width + gap + ceil(text.width), MAX(icon.height, ceil(text.height)));
    }
    CGFloat height = imageSize.height + (hasImage && hasTitle ? 24 : 0) + ceil(titleSize.height) + (hasImage && hasTitle ? 2 : 0);
    CGFloat titleWidth = 0;
    if (hasTitle) {
        height += insets.top + insets.bottom;
        titleWidth = MAX(ceil(titleSize.width) + insets.left + insets.right, self.titleMinimumWidth);
    }
    return CGSizeMake(MAX(imageSize.width, titleWidth), height);
}

/*!
 * [EN] The margin used for a bounds width: `contentMargin`, reduced when the view is too narrow for the content plus
 *      both margins. A refresh icon of 30 points left a zero-width item before, so its animation kept its first frame,
 *      starting at the icon's center, and covered the text beside it.
 * [CN] 某个宽度下实际使用的边距：`contentMargin`，视图放不下内容加两侧边距时缩小。之前 30 点的刷新图标会得到零宽度的 item，动画停留在
 *      初始 frame（从图标中心开始），盖住旁边的文字。
 */
- (CGFloat)cyl_marginForWidth:(CGFloat)width {
    CGFloat margin = MAX(0, self.contentMargin);
    // [EN] Text wraps to the space inside the margins; only content that cannot shrink (an image or animation) wider
    //      than that space takes margin away. [CN] 文字在边距内换行；只有无法缩小且超出该空间的内容（图片或动画）才会占用边距。
    CGFloat content = ceil([self cyl_itemSizeForWidth:MAX(0, width - 2 * margin)].width);
    if (content <= width - 2 * margin) return margin;
    return MAX(0, (width - content) / 2);
}

- (void)setContentMargin:(CGFloat)contentMargin {
    if (_contentMargin == contentMargin) return;
    _contentMargin = contentMargin;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (CGSize)contentSizeThatFits:(CGSize)size {
    return [self cyl_itemSizeForWidth:MAX(0, size.width)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    // [EN] UIView's behavior, as before: the view keeps its size; `reportsContentSize` reports the content instead.
    // [CN] 与以前一样采用 UIView 的行为：视图保持自身尺寸；需要内容尺寸时使用 `reportsContentSize`。
    return self.bounds.size;
}

- (CGSize)intrinsicContentSize {
    if (!self.reportsContentSize) return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
    CGFloat maxWidth = self.preferredMaxLayoutWidth > 0 ? self.preferredMaxLayoutWidth : CGRectGetWidth(UIScreen.mainScreen.bounds);
    CGFloat margin = MAX(0, self.contentMargin);
    CGSize size = [self cyl_itemSizeForWidth:MAX(0, maxWidth - 2 * margin)];
    if (size.height <= 0) return CGSizeZero;
    return CGSizeMake(MIN(maxWidth, ceil(size.width) + 2 * margin), ceil(size.height));
}

- (void)setReportsContentSize:(BOOL)reportsContentSize {
    _reportsContentSize = reportsContentSize;
    [self invalidateIntrinsicContentSize];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    if (_preferredMaxLayoutWidth == preferredMaxLayoutWidth) return;
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    [self invalidateIntrinsicContentSize];
}

- (void)layoutContentInRect:(CGRect)rect {
    if (CGRectIsEmpty(rect)) return;
    CGFloat width = MAX(0, CGRectGetWidth(rect) - 2 * [self cyl_marginForWidth:CGRectGetWidth(rect)]);
    CGFloat itemHeight = [self cyl_itemSizeForWidth:width].height;
    CGRect item = CGRectMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect) - width) / 2,
                             CGRectGetMinY(rect) + (CGRectGetHeight(rect) - itemHeight) / 2, width, itemHeight);
    self.itemFrame = item;
    self.selectionIndicatorView.frame = item;
    if (CGRectIsEmpty(item)) return;
    [self cyl_layoutItemInRect:item];
}

// UI adapted from CYLFlatDesignTabBarButton, CYLTabBarController (MIT).
// Copyright (c) 2026 CYLTabBarController, https://github.com/ChenYilong/CYLTabBarController.
- (void)cyl_layoutItemInRect:(CGRect)item {
    UIImageView *imageView = self.imageView;
    UILabel *titleLabel = self.titleLabel;
    UIView *animationView = self.animationView;
    // [EN] The base class hides the image view under a ready animation, which is the same flag as a caller hiding the
    //      icon, so the layout must not read it as "no icon" and hide the animation too.
    // [CN] 基类会在就绪的动画下隐藏图片视图，这与调用方隐藏图标是同一个属性，因此布局不能把它当作“没有图标”而把动画也隐藏。
    BOOL imageHiddenByCaller = imageView.hidden && ![self cyl_animationCoversImage];
    animationView.hidden = imageView.image != nil && imageHiddenByCaller;
    BOOL isShowImageView = (imageView.image != nil && !imageView.hidden) || (animationView != nil && !animationView.hidden);
    BOOL isShowTitleLabel = titleLabel.text.length > 0 && !titleLabel.hidden;
    CGSize box = CGSizeZero;
    if ((animationView && !animationView.hidden) || (isShowImageView && [self cyl_reservesAnimationBox])) {
        box = [self cyl_animationBoxSize];
    } else if (isShowImageView) {
        box = imageView.image.size;
    }

    if (self.horizontal) {
        [self cyl_layoutHorizontallyInRect:item iconBox:box showingImage:isShowImageView title:isShowTitleLabel];
        [self cyl_layoutBadgeAnchoredToImage:isShowImageView];
        return;
    }

    CGFloat itemWidth = CGRectGetWidth(item), itemHeight = CGRectGetHeight(item);
    // [EN] Title chrome (background, border, padding) applies only to a shown title; with zero insets the layout is
    // the same as without chrome.
    // [CN] 标题装饰（背景、边框、内边距）只作用于显示中的标题；内边距为零时布局与没有装饰时相同。
    UIEdgeInsets titleInsets = isShowTitleLabel ? self.titleContentInsets : UIEdgeInsetsZero;
    CGFloat titleAreaWidth = MAX(0, itemWidth - titleInsets.left - titleInsets.right);
    NSString *title = isShowTitleLabel ? titleLabel.text : @"height";
    CGSize titleSize = [title boundingRectWithSize:CGSizeMake(titleAreaWidth, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: titleLabel.font}
                                           context:nil].size;
    CGFloat titleLabelWidth = MIN(titleAreaWidth, ceil(titleSize.width));
    CGFloat titleLabelHeight = ceil(titleSize.height);
    CGFloat titleLabelX = (itemWidth - titleLabelWidth) / 2;
    CGFloat titleLabelY = itemHeight - titleLabelHeight - 2 - titleInsets.bottom;
    if (!isShowImageView) {
        titleLabelY = titleInsets.top + (itemHeight - titleInsets.top - titleInsets.bottom - titleLabelHeight) / 2;
    }
    UIOffset titleOffset = [self cyl_titleOffset];
    titleLabelX += titleOffset.horizontal;
    titleLabelY += titleOffset.vertical;
    titleLabel.frame = CGRectMake(CGRectGetMinX(item) + titleLabelX, CGRectGetMinY(item) + titleLabelY,
                                  titleLabelWidth, titleLabelHeight);
    if (self.titleBackgroundView) {
        self.titleBackgroundView.hidden = !isShowTitleLabel;
        if (isShowTitleLabel) {
            CGFloat chromeWidth = MIN(itemWidth, MAX(titleLabelWidth + titleInsets.left + titleInsets.right, self.titleMinimumWidth));
            CGRect chrome = CGRectMake(CGRectGetMidX(titleLabel.frame) - chromeWidth / 2,
                                       CGRectGetMinY(titleLabel.frame) - titleInsets.top,
                                       chromeWidth, titleLabelHeight + titleInsets.top + titleInsets.bottom);
            self.titleBackgroundView.frame = chrome;
            self.titleBackgroundView.layer.cornerRadius = MIN(MAX(0, self.titleCornerRadius), CGRectGetHeight(chrome) / 2);
            self.titleBackgroundView.layer.borderWidth = self.titleBorderWidth;
            UIColor *borderColor = self.titleBorderColor;
            if (@available(iOS 13.0, *)) {
                borderColor = [borderColor resolvedColorWithTraitCollection:self.traitCollection];
            }
            self.titleBackgroundView.layer.borderColor = borderColor.CGColor;
            [self insertSubview:self.titleBackgroundView belowSubview:titleLabel];
        }
    }

    if (isShowImageView) {
        CGFloat imageViewX = (itemWidth - box.width) / 2;
        CGFloat imageViewY = (CGRectGetMinY(titleLabel.frame) - CGRectGetMinY(item) - titleInsets.top - box.height) / 2;
        if (!isShowTitleLabel) imageViewY = (itemHeight - box.height) / 2;
        imageViewX += self.itemImageOffset.horizontal;
        imageViewY += self.itemImageOffset.vertical;
        imageView.frame = CGRectMake(CGRectGetMinX(item) + imageViewX, CGRectGetMinY(item) + imageViewY,
            MAX(0, box.width - self.itemImageInsets.left - self.itemImageInsets.right),
            MAX(0, box.height - self.itemImageInsets.top - self.itemImageInsets.bottom));
        animationView.frame = imageView.frame;
    } else {
        imageView.frame = (CGRect){item.origin, CGSizeZero};
    }
    [self cyl_layoutBadgeAnchoredToImage:isShowImageView];
}

/// [EN] The icon at the leading edge, then the title; both centered vertically. [CN] 图标在前缘，标题在后，二者垂直居中。
- (void)cyl_layoutHorizontallyInRect:(CGRect)item iconBox:(CGSize)box showingImage:(BOOL)showImage title:(BOOL)showTitle {
    CGFloat width = CGRectGetWidth(item), height = CGRectGetHeight(item);
    CGSize imageSize = CGSizeZero;
    if (showImage) {
        imageSize = CGSizeMake(MAX(0, box.width - self.itemImageInsets.left - self.itemImageInsets.right),
                               MAX(0, box.height - self.itemImageInsets.top - self.itemImageInsets.bottom));
    }
    CGFloat titleX = showImage ? imageSize.width + CYLPlaceholderHorizontalSpacing : 0;
    CGFloat titleWidth = MAX(0, width - titleX);
    CGFloat titleHeight = 0;
    if (showTitle) {
        titleHeight = ceil([self.titleLabel.text boundingRectWithSize:CGSizeMake(titleWidth, CGFLOAT_MAX)
            options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.titleLabel.font}
            context:nil].size.height);
    }
    BOOL rightToLeft = self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
    CGRect imageFrame = CGRectMake(0, (height - imageSize.height) / 2, imageSize.width, imageSize.height);
    CGRect titleFrame = CGRectMake(titleX, (height - titleHeight) / 2, titleWidth, titleHeight);
    if (rightToLeft) {
        imageFrame.origin.x = width - CGRectGetMaxX(imageFrame);
        titleFrame.origin.x = width - CGRectGetMaxX(titleFrame);
    }
    imageFrame = CGRectOffset(imageFrame, self.itemImageOffset.horizontal, self.itemImageOffset.vertical);
    UIOffset titleOffset = [self cyl_titleOffset];
    titleFrame = CGRectOffset(titleFrame, titleOffset.horizontal, titleOffset.vertical);
    imageFrame = CGRectOffset(imageFrame, CGRectGetMinX(item), CGRectGetMinY(item));
    titleFrame = CGRectOffset(titleFrame, CGRectGetMinX(item), CGRectGetMinY(item));
    self.imageView.frame = showImage ? imageFrame : (CGRect){item.origin, CGSizeZero};
    self.animationView.frame = self.imageView.frame;
    self.titleLabel.textAlignment = NSTextAlignmentNatural;
    self.titleLabel.frame = showTitle ? titleFrame : (CGRect){item.origin, CGSizeZero};
    self.titleBackgroundView.hidden = YES;
}

- (void)cyl_layoutBadgeAnchoredToImage:(BOOL)isShowImageView {
    // Badge dimensions and top-right placement follow CYLBadgeView (MIT).
    if (self.badgeLabel && !self.badgeLabel.hidden) {
        CYLPlaceholderBadgeAppearance *appearance = [CYLPlaceholderBadgeAppearance sharedAppearance];
        UIEdgeInsets insets = appearance.contentInsets;
        BOOL dot = self.badgeLabel.text.length == 0;
        CGSize size = dot ? CGSizeMake(8, 8) : [self.badgeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        if (!dot) {
            size.height = ceil(size.height) + insets.top + insets.bottom;
            size.width = MAX(size.height, ceil(size.width) + insets.left + insets.right);
        }
        CGRect anchor = isShowImageView ? self.imageView.frame : self.titleLabel.frame;
        self.badgeLabel.bounds = (CGRect){CGPointZero, size};
        self.badgeLabel.center = CGPointMake(CGRectGetMaxX(anchor) + 2 + self.badgeCenterOffset.x,
                                              CGRectGetMinY(anchor) + self.badgeCenterOffset.y);
        self.badgeLabel.layer.cornerRadius = appearance.cornerRadius > 0 ? MIN(appearance.cornerRadius, size.height / 2) : size.height / 2;
        self.badgeContainerView.frame = self.bounds;
        [self bringSubviewToFront:self.badgeContainerView];
    }
}

// Validates animation options for a given file extension/backend.
// Returns YES if options are valid, NO otherwise. Logs warnings for unsupported options.
- (BOOL)cyl_validateAnimationOptions:(NSDictionary *)options forExtension:(NSString *)extension {
    if (!options || options.count == 0) return YES;
    BOOL isValid = YES;
    if ([extension isEqualToString:@"json"]) {
        // Lottie options: loopMode, animationSpeed, etc.
        for (NSString *key in options) {
            if (![key isEqualToString:@"animationSpeed"] &&
                ![key isEqualToString:@"contentMode"]) {
                NSLog(@"CYLTableViewPlaceHolder: Lottie animation option '%@' is not supported.", key);
                isValid = NO;
            }
        }
    } else if ([extension isEqualToString:@"pag"]) {
        // PAG options: loopMode, etc.
        for (NSString *key in options) {
            if (![key isEqualToString:@"contentMode"]) {
                NSLog(@"CYLTableViewPlaceHolder: PAG animation option '%@' is not supported.", key);
                isValid = NO;
            }
        }
    } else if ([extension isEqualToString:@"riv"]) {
        // Rive options: artboard, stateMachine, active, trigger, input, triggerInput, animation, legacy, duration, color,
        // numberInput, values (CYLAnimatedItem's CYLTabBarAnimationOptionRive* keys).
        for (NSString *key in options) {
            if (![key isEqualToString:@"artboard"] &&
                ![key isEqualToString:@"stateMachine"] &&
                ![key isEqualToString:@"active"] &&
                ![key isEqualToString:@"trigger"] &&
                ![key isEqualToString:@"input"] &&
                ![key isEqualToString:@"triggerInput"] &&
                ![key isEqualToString:@"animation"] &&
                ![key isEqualToString:@"legacy"] &&
                ![key isEqualToString:@"color"] &&
                ![key isEqualToString:@"duration"] &&
                ![key isEqualToString:@"numberInput"] &&
                ![key isEqualToString:@"values"]) {
                NSLog(@"CYLTableViewPlaceHolder: Rive animation option '%@' is not supported.", key);
                isValid = NO;
            }
        }
    } else if ([extension isEqualToString:@"gif"]) {
        // GIF options: contentMode
        for (NSString *key in options) {
            if (![key isEqualToString:@"contentMode"]) {
                NSLog(@"CYLTableViewPlaceHolder: GIF animation option '%@' is not supported.", key);
                isValid = NO;
            }
        }
    } else {
        // Custom factory - accept all options
    }
    return isValid;
}

#pragma mark - Playback 播放

- (void)setAnimationRepeatCount:(NSInteger)animationRepeatCount {
    if (animationRepeatCount < 0 || _animationRepeatCount == animationRepeatCount) return;
    _animationRepeatCount = animationRepeatCount;
    self.animationLoops = animationRepeatCount == 0;
    [self cyl_updateAnimationPlayback];
}

- (void)playPlaceholderAnimation {
    [self cyl_leaveSeekMode];
    self.animationStopped = NO;
    self.animationShowsLastFrame = NO;
    [self cyl_updateAnimationPlayback];
}

- (void)stopPlaceholderAnimation {
    [self cyl_leaveSeekMode];
    self.animationStopped = YES;
    self.animationShowsLastFrame = NO;
    [self cyl_updateAnimationPlayback];
}

- (void)showPlaceholderAnimationLastFrame {
    [self cyl_leaveSeekMode];
    self.animationStopped = YES;
    self.animationShowsLastFrame = YES;
    [self cyl_updateAnimationPlayback];
}

- (void)cyl_leaveSeekMode {
    if (!self.animationSeekProgress) return;
    self.animationSeekProgress = nil;
    self.animationRestingProgress = 0;
}

// [EN] The base class's playback methods follow the placeholder's policy too (visibility, Reduce Motion, repeat
//      count), so both spellings behave the same.
// [CN] 基类的播放方法同样遵循占位图的播放策略（可见性、减弱动态效果、重复次数），两种写法行为一致。
- (void)playAnimation {
    [self playPlaceholderAnimation];
}

- (void)restartAnimation {
    // [EN] Every engine player plays from progress 0. [CN] 引擎的播放器都从进度 0 开始播放。
    [self playPlaceholderAnimation];
}

- (void)stopAnimation {
    [self stopPlaceholderAnimation];
}

- (void)showAnimationLastFrame {
    [self showPlaceholderAnimationLastFrame];
}

- (BOOL)setPlaceholderAnimationProgress:(CGFloat)progress {
    if (!NSThread.isMainThread || !isfinite(progress) || progress < 0 || progress > 1) return NO;
#if CYL_ANIMATION_ENGINE_AVAILABLE
    if (![self.animationPlayer respondsToSelector:@selector(setProgress:)]) return NO;
    self.animationStopped = YES;
    self.animationShowsLastFrame = NO;
    self.animationSeekProgress = @(progress);
    [self cyl_updateAnimationPlayback];
    return YES;
#else
    return NO;
#endif
}

- (BOOL)setPlaceholderAnimationSpeed:(CGFloat)speed {
    if (!NSThread.isMainThread || !isfinite(speed) || speed <= 0) return NO;
#if CYL_ANIMATION_ENGINE_AVAILABLE
    if (![self.animationPlayer respondsToSelector:@selector(setAnimationSpeed:)]) return NO;
    self.explicitAnimationSpeed = @(speed);
    self.animationSpeed = speed;
    return YES;
#else
    return NO;
#endif
}

/// [EN] Plays while the view is on screen, visible, not stopped and Reduce Motion is off; otherwise shows the resting
///      frame, the last frame or the seek position. The base class plays.
/// [CN] 视图在屏幕上、可见、未停止且未开启“减弱动态效果”时播放；否则显示静止帧、最后一帧或定位的位置。由基类播放。
- (void)cyl_updateAnimationPlayback {
#if CYL_ANIMATION_ENGINE_AVAILABLE
    [self cyl_stopRepeatTimer];
    if (!self.animationPlayer) return;
    if (self.animationShowsLastFrame) {
        [super showAnimationLastFrame];
    } else if (self.animationSeekProgress) {
        self.animationRestingProgress = self.animationSeekProgress.doubleValue;
        [super stopAnimation];
    } else if (!self.animationStopped && self.window && !self.hidden && !UIAccessibilityIsReduceMotionEnabled()) {
        [super playAnimation];
        [self cyl_startRepeatTimerIfNeeded];
    } else {
        [super stopAnimation];
    }
#endif
}

/// [EN] A repeat count N > 1: the player plays once and is replayed N - 1 times when it reaches the end (it must
///      report its progress, as Lottie and PAG do). 0 is `animationLoops`, handled by the base class.
/// [CN] 重复次数 N > 1：播放器播放一次，播放到末尾时再重播 N - 1 次（播放器需要提供进度，如 Lottie 与 PAG）。0 即 `animationLoops`，由基类处理。
- (void)cyl_startRepeatTimerIfNeeded {
#if CYL_ANIMATION_ENGINE_AVAILABLE
    if (self.animationRepeatCount <= 1 || ![self.animationPlayer respondsToSelector:@selector(progress)]) return;
    self.remainingRepeats = self.animationRepeatCount - 1;
    __weak typeof(self) weakSelf = self;
    self.repeatTimer = [NSTimer timerWithTimeInterval:0.05 repeats:YES block:^(NSTimer *timer) {
        CYLPlaceholderView *strongSelf = weakSelf;
        id<CYLTabBarItemAnimationPlayer> player = strongSelf.animationPlayer;
        if (!strongSelf || !player || strongSelf.remainingRepeats <= 0) {
            [timer invalidate];
            return;
        }
        if (player.progress >= 0.999) {
            strongSelf.remainingRepeats -= 1;
            [player play];
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.repeatTimer forMode:NSRunLoopCommonModes];
#endif
}

- (void)cyl_stopRepeatTimer {
    [self.repeatTimer invalidate];
    self.repeatTimer = nil;
}

#pragma mark - Tap

- (BOOL)isTapInteractive {
    return self.tapInteractionEnabled && self.tapHandler != nil;
}

- (void)setTapHandler:(CYLPlaceholderTapHandler)tapHandler {
    _tapHandler = [tapHandler copy];
    [self cyl_updateTapAccessibility];
}

- (void)setTapInteractionEnabled:(BOOL)tapInteractionEnabled {
    _tapInteractionEnabled = tapInteractionEnabled;
    if (!tapInteractionEnabled) [self cyl_setTapHighlighted:NO];
    [self cyl_updateTapAccessibility];
}

/// A placeholder with a tap event is a button for VoiceOver, Voice Control and Switch Control; with interaction
/// turned off it is a dimmed ("not enabled") button, as a disabled UIButton. Without a tap event the traits it added
/// are removed again.
- (void)cyl_updateTapAccessibility {
    UIAccessibilityTraits traits = self.accessibilityTraits;
    if (self.tapHandler) {
        if (!(traits & UIAccessibilityTraitButton)) {
            traits |= UIAccessibilityTraitButton;
            self.tapAddedButtonTrait = YES;
        }
        if (!self.tapInteractionEnabled && !(traits & UIAccessibilityTraitNotEnabled)) {
            traits |= UIAccessibilityTraitNotEnabled;
            self.tapAddedNotEnabledTrait = YES;
        } else if (self.tapInteractionEnabled && self.tapAddedNotEnabledTrait) {
            traits &= ~UIAccessibilityTraitNotEnabled;
            self.tapAddedNotEnabledTrait = NO;
        }
        self.isAccessibilityElement = YES;
        self.accessibilityElementsHidden = NO;
    } else {
        if (self.tapAddedButtonTrait) traits &= ~UIAccessibilityTraitButton;
        if (self.tapAddedNotEnabledTrait) traits &= ~UIAccessibilityTraitNotEnabled;
        self.tapAddedButtonTrait = NO;
        self.tapAddedNotEnabledTrait = NO;
    }
    self.accessibilityTraits = traits;
}

- (BOOL)performTap {
    if (!self.isTapInteractive) return NO;
    self.tapHandler(self);
    return YES;
}

- (BOOL)accessibilityActivate {
    return [self performTap] || [super accessibilityActivate];
}

/// [EN] The base class's accessibility (a button with the title) does not apply: a placeholder is a decoration, an
///      element when it has content or a label, and a button only with a tap event.
/// [CN] 不使用基类的无障碍设置（带标题的按钮）：占位图是装饰；有内容或标签时是元素；只有设置点击事件时才是按钮。
- (void)updateItemAccessibility {
    [self cyl_updateTapAccessibility];
}

/// [EN] `UIControlEventTouchUpInside` (sent by the base class's tracking or by the touches below) runs the tap event.
/// [CN] `UIControlEventTouchUpInside`（由基类的跟踪或下面的触摸处理发送）执行点击事件。
- (void)cyl_handleTouchUpInside {
    [self performTap];
}

/// [EN] YES when the control handles touches: a tap event, or the base class's delegate or drag. Otherwise touches pass
///      through, as they did before the placeholder became a control.
/// [CN] 控件是否处理触摸：有点击事件，或设置了基类的代理或拖拽。否则触摸穿透，与占位图成为控件之前相同。
- (BOOL)cyl_handlesTouches {
    return self.isTapInteractive || self.delegate != nil || self.isDragEnabled;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    return (hit == self && ![self cyl_handlesTouches]) ? nil : hit;
}

- (void)cyl_setTapHighlighted:(BOOL)highlighted {
    if (highlighted && self.tapHighlightStyle == CYLPlaceholderTapHighlightStyleNone) highlighted = NO;
    if (self.tapHighlighted == highlighted) return;
    self.tapHighlighted = highlighted;
    // [EN] Only the content changes, so an alpha or transform the app set on the view itself is kept.
    // [CN] 只改变内容视图，保留应用对本视图设置的 alpha 或 transform。
    // [EN] Reduce Motion: the shrink style only dims. [CN] 开启“减弱动态效果”时，缩小样式只变暗。
    BOOL shrink = self.tapHighlightStyle == CYLPlaceholderTapHighlightStyleShrink && !UIAccessibilityIsReduceMotionEnabled();
    CGFloat alpha = highlighted ? (shrink ? 0.8 : 0.5) : 1;
    CGAffineTransform transform = highlighted && shrink ? CGAffineTransformMakeScale(0.96, 0.96) : CGAffineTransformIdentity;
    // [EN] The content is the subviews: the transform scales them around the center (the content is centered), and
    //      each keeps the alpha it had before the press.
    // [CN] 内容即子视图：变换以中心缩放它们（内容居中），各子视图保留按下前的 alpha。
    if (highlighted && !self.highlightAlphas) {
        self.highlightAlphas = [NSMapTable weakToStrongObjectsMapTable];
        for (UIView *view in self.subviews) [self.highlightAlphas setObject:@(view.alpha) forKey:view];
    }
    NSMapTable<UIView *, NSNumber *> *alphas = self.highlightAlphas;
    [UIView animateWithDuration:highlighted ? 0.08 : 0.2 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        self.layer.sublayerTransform = CATransform3DMakeAffineTransform(transform);
        for (UIView *view in alphas.keyEnumerator) {
            view.alpha = [alphas objectForKey:view].doubleValue * alpha;
        }
    } completion:nil];
    if (!highlighted) self.highlightAlphas = nil;
}

- (BOOL)cyl_touchIsInside:(NSSet<UITouch *> *)touches {
    // [EN] A little slop around the view, as UIButton allows. [CN] 与 UIButton 一样，允许在视图外有少许容差。
    CGPoint point = [touches.anyObject locationInView:self];
    return CGRectContainsPoint(CGRectInset(self.bounds, -24, -24), point);
}

// [EN] A tap-interactive placeholder tracks its own touches (highlight, slop) and sends
//      `UIControlEventTouchUpInside`, so the base class's delegate hears the tap as well. Without a tap event the base
//      class (UIControl) tracks them when it has a delegate or a drag; otherwise they go up the responder chain as
//      before.
// [CN] 可点击的占位图自己跟踪触摸（高亮、容差）并发送 `UIControlEventTouchUpInside`，基类的代理也会收到点击。没有点击事件时，若有代理或拖拽则由基类
//      （UIControl）跟踪；否则与以前一样沿响应链传递。
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isTapInteractive) {
        if ([self cyl_handlesTouches]) [super touchesBegan:touches withEvent:event];
        else [self.nextResponder touchesBegan:touches withEvent:event];
        return;
    }
    [self cyl_setTapHighlighted:YES];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isTapInteractive) {
        if ([self cyl_handlesTouches]) [super touchesMoved:touches withEvent:event];
        else [self.nextResponder touchesMoved:touches withEvent:event];
        return;
    }
    [self cyl_setTapHighlighted:[self cyl_touchIsInside:touches]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isTapInteractive) {
        if ([self cyl_handlesTouches]) [super touchesEnded:touches withEvent:event];
        else [self.nextResponder touchesEnded:touches withEvent:event];
        return;
    }
    BOOL inside = [self cyl_touchIsInside:touches];
    [self cyl_setTapHighlighted:NO];
    if (inside) [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self cyl_setTapHighlighted:NO];
    if (self.isTapInteractive) return;
    if ([self cyl_handlesTouches]) [super touchesCancelled:touches withEvent:event];
    else [self.nextResponder touchesCancelled:touches withEvent:event];
}

- (void)dealloc {
    [_repeatTimer invalidate];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)cyl_contentSizeCategoryChanged:(NSNotification *)notification {
    [self setNeedsLayout];
}

- (void)cyl_reduceMotionChanged:(NSNotification *)notification {
    [self cyl_updateAnimationPlayback];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self cyl_updateAnimationPlayback];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self cyl_updateAnimationPlayback];
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
    return CYLPlaceholderLocalizedString(keys[message], fallbacks[message]);
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
        // [EN] See CYLPlaceholderItemImageView: relayout and the static image follow values set on the subviews.
        // [CN] 见 CYLPlaceholderItemImageView：子视图上设置的值会触发重新布局并同步静态图片。
        if ([self.imageView isMemberOfClass:UIImageView.class]) object_setClass(self.imageView, CYLPlaceholderItemImageView.class);
        if ([self.titleLabel isMemberOfClass:UILabel.class]) object_setClass(self.titleLabel, CYLPlaceholderItemLabel.class);
        // [EN] The base class makes every item a button for VoiceOver with the identifier "CYLAnimatedItemView" and its
        //      label hidden. A placeholder is not an element by default, its label reads on its own, and a tap event
        //      makes it a button (cyl_updateTapAccessibility), as before.
        // [CN] 基类把每个条目都设为带 "CYLAnimatedItemView" 标识的 VoiceOver 按钮并隐藏标签。占位图默认不是无障碍元素，标签单独朗读，设置点击事件后
        //      才是按钮（cyl_updateTapAccessibility），与以前相同。
        self.isAccessibilityElement = NO;
        self.accessibilityTraits = UIAccessibilityTraitNone;
        self.accessibilityIdentifier = nil;
        self.imageView.accessibilityElementsHidden = NO;
        self.titleLabel.isAccessibilityElement = YES;
        self.axis = CYLAnimatedItemAxisVertical;
        [self addTarget:self action:@selector(cyl_handleTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        _tapInteractionEnabled = YES;
        _animationRepeatCount = 1;
        _contentMargin = 16;
        self.imageView.clipsToBounds = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleEmpty];
        UILabel *textLabel = self.titleLabel;
        textLabel.clipsToBounds = NO;
        textLabel.text = [CYLPlaceholderView localizedTextForMessage:CYLPlaceholderMessageEmpty];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.numberOfLines = 0;
        textLabel.textColor = UIColor.grayColor;
        // A text-style font (17 points at the default size), so the title follows Dynamic Type.
        textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        textLabel.adjustsFontForContentSizeCategory = YES;
        // The built-in values are the bottom appearance layer; values set directly on the labels later win.
        _appearanceBaselineValues = [NSMutableDictionary dictionary];
        _appearanceExplicitValues = [NSMutableDictionary dictionary];
        _appearanceAppliedValues = [NSMutableDictionary dictionary];
        _appearanceNormalValues = [NSMutableDictionary dictionary];
        for (NSString *key in CYLPlaceholderAppearanceKeys()) {
            // The icon inherits the tint color unless a color is configured.
            id value = [key isEqualToString:@"iconColor"] ? NSNull.null : ([self cyl_appearanceTargetValueForKey:key] ?: NSNull.null);
            _appearanceBaselineValues[key] = value;
            _appearanceAppliedValues[key] = value;
            _appearanceNormalValues[key] = value;
        }
        // A plain label: badge changes lay the item out explicitly, so the label must not invalidate layout itself.
        _badgeLabel = [UILabel new];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        // Apply shared badge appearance
        CYLPlaceholderBadgeAppearance *badgeAppearance = [CYLPlaceholderBadgeAppearance sharedAppearance];
        _badgeLabel.font = badgeAppearance.font;
        _badgeLabel.adjustsFontForContentSizeCategory = YES;
        _badgeLabel.textColor = badgeAppearance.textColor;
        _badgeLabel.backgroundColor = badgeAppearance.backgroundColor;
        _appliedBadgeFont = _badgeLabel.font;
        _appliedBadgeTextColor = _badgeLabel.textColor;
        _appliedBadgeBackgroundColor = _badgeLabel.backgroundColor;
        _badgeLabel.clipsToBounds = YES;
        _badgeLabel.hidden = YES;
        _badgeLabel.isAccessibilityElement = YES;
        _itemAttributes = @{};
        // Observe dynamic type changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cyl_contentSizeCategoryChanged:)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
    }
    return self;
}

+ (NSArray<NSString *> *)bundledAnimationFileNames {
    NSBundle *bundle = CYLPlaceholderResourceBundle();
    NSString *directory = [bundle.resourcePath stringByAppendingPathComponent:CYLPlaceholderAnimationsDirectory];
    NSSet<NSString *> *extensions = [NSSet setWithObjects:@"json", @"lottie", @"pag", @"riv", @"gif", nil];
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    for (NSString *name in [NSFileManager.defaultManager contentsOfDirectoryAtPath:directory error:NULL]) {
        if ([extensions containsObject:name.pathExtension.lowercaseString]) [names addObject:name];
    }
    return [names sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSString *)pathForBundledAnimation:(NSString *)fileName {
    if (fileName.length == 0 || fileName.lastPathComponent.length != fileName.length) return nil;
    NSString *path = [CYLPlaceholderResourceBundle() pathForResource:fileName ofType:nil
                                                          inDirectory:CYLPlaceholderAnimationsDirectory];
    return [NSFileManager.defaultManager fileExistsAtPath:path] ? path : nil;
}

@end
