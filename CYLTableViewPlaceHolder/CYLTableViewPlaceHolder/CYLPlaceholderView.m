#import "CYLPlaceholderView.h"
#import "CYLPlaceholderLocalization.h"
#import "CYLPlaceholderItemAnimationService.h"

static NSArray<NSString *> *CYLPlaceholderAppearanceKeys(void);
static BOOL CYLPlaceholderSameValue(id a, id b);
#import <math.h>
#import <ImageIO/ImageIO.h>

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

// [EN] CYLPlaceholderResourceBundle() is the core resource lookup, declared in CYLPlaceholderLocalization.h.
// [CN] CYLPlaceholderResourceBundle() 是核心层的资源查找函数，声明在 CYLPlaceholderLocalization.h 中。

static NSString *const CYLPlaceholderAnimationsDirectory = @"Animations";

static NSError *CYLPlaceholderConfigurationError(NSString *description) {
    return [NSError errorWithDomain:@"CYLPlaceholderConfigurationError" code:1
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

@interface CYLPlaceholderItemImageView : UIImageView
@end

@implementation CYLPlaceholderItemImageView
- (void)setImage:(UIImage *)image {
    [super setImage:image];
    [self.superview.superview setNeedsLayout];
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self.superview.superview setNeedsLayout];
}
@end

@interface CYLPlaceholderItemLabel : UILabel
@end

@implementation CYLPlaceholderItemLabel
- (void)setText:(NSString *)text {
    [super setText:text];
    [self.superview.superview setNeedsLayout];
}
- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self.superview.superview setNeedsLayout];
}
- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self.superview.superview setNeedsLayout];
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self.superview.superview setNeedsLayout];
}
@end

// UI adapted from CYLFlatDesignTabBarButton, CYLTabBarController (MIT).
// Copyright (c) 2026 CYLTabBarController, https://github.com/ChenYilong/CYLTabBarController.
@interface CYLPlaceholderItemView : UIView
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic) UIOffset itemTitleOffset;
/// Used when the item has no title offset of its own (the FlatDesign `_appearanceTitlePositionAdjustment`).
@property (nonatomic) UIOffset appearanceTitleOffset;
@property (nonatomic) UIOffset itemImageOffset;
@property (nonatomic) UIEdgeInsets itemImageInsets;
@property (nonatomic, strong) UIView *animationView;
@property (nonatomic) CGSize animationSize;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic) CGPoint badgeCenterOffset;
// Title chrome (CYLPlaceholderItemTitle... keys); nil background view means a plain title.
@property (nonatomic, strong) UIImageView *titleBackgroundView;
@property (nonatomic) UIEdgeInsets titleContentInsets;
@property (nonatomic) CGFloat titleMinimumWidth;
/// [EN] YES: the icon at the leading edge, the title after it (`CYLPlaceholderItemContentAxis`). [CN] YES：横向排列。
@property (nonatomic) BOOL horizontal;
@property (nonatomic) CGFloat titleCornerRadius;
@property (nonatomic, strong) UIColor *titleBorderColor;
@property (nonatomic) CGFloat titleBorderWidth;
@end

@implementation CYLPlaceholderItemView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[CYLPlaceholderItemImageView alloc] init];
        _imageView.clipsToBounds = NO;
        [self addSubview:_imageView];

        _titleLabel = [[CYLPlaceholderItemLabel alloc] init];
        _titleLabel.clipsToBounds = NO;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectIsEmpty(self.bounds)) return;

    self.animationView.hidden = self.imageView.image != nil && self.imageView.hidden;
    BOOL isShowImageView = (self.imageView.image != nil && !self.imageView.hidden) ||
        (self.animationView != nil && !self.animationView.hidden);
    BOOL isShowTitleLabel = self.titleLabel.text.length > 0 && !self.titleLabel.hidden;
    if (self.animationView && !self.animationView.hidden) {
        self.imageView.frame = (CGRect){CGPointZero, self.animationSize};
    } else if (isShowImageView) {
        [self.imageView sizeToFit];
    }

    if (self.horizontal) {
        [self cyl_layoutHorizontallyShowingImage:isShowImageView title:isShowTitleLabel];
        [self cyl_layoutBadgeAnchoredToImage:isShowImageView];
        return;
    }

    // [EN] Title chrome (background, border, padding) applies only to a shown title; with zero insets the layout is
    // the same as without chrome.
    // [CN] 标题装饰（背景、边框、内边距）只作用于显示中的标题；内边距为零时布局与没有装饰时相同。
    UIEdgeInsets titleInsets = isShowTitleLabel ? self.titleContentInsets : UIEdgeInsetsZero;
    CGFloat titleAreaWidth = MAX(0, CGRectGetWidth(self.bounds) - titleInsets.left - titleInsets.right);
    NSString *title = isShowTitleLabel ? self.titleLabel.text : @"height";
    CGSize titleSize = [title boundingRectWithSize:CGSizeMake(titleAreaWidth, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: self.titleLabel.font}
                                           context:nil].size;
    CGFloat titleLabelWidth = MIN(titleAreaWidth, ceil(titleSize.width));
    CGFloat titleLabelHeight = ceil(titleSize.height);
    CGFloat titleLabelX = (CGRectGetWidth(self.bounds) - titleLabelWidth) / 2;
    CGFloat titleLabelY = CGRectGetHeight(self.bounds) - titleLabelHeight - 2 - titleInsets.bottom;
    if (!isShowImageView) {
        titleLabelY = titleInsets.top +
            (CGRectGetHeight(self.bounds) - titleInsets.top - titleInsets.bottom - titleLabelHeight) / 2;
    }
    // The item's own offset wins, else the appearance's, as in CYLFlatDesignTabBarButton.
    UIOffset titleOffset = UIOffsetEqualToOffset(self.itemTitleOffset, UIOffsetZero) ? self.appearanceTitleOffset : self.itemTitleOffset;
    titleLabelX += titleOffset.horizontal;
    titleLabelY += titleOffset.vertical;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelWidth, titleLabelHeight);
    if (self.titleBackgroundView) {
        self.titleBackgroundView.hidden = !isShowTitleLabel;
        if (isShowTitleLabel) {
            CGFloat chromeWidth = MIN(CGRectGetWidth(self.bounds),
                                      MAX(titleLabelWidth + titleInsets.left + titleInsets.right, self.titleMinimumWidth));
            CGRect chrome = CGRectMake(CGRectGetMidX(self.titleLabel.frame) - chromeWidth / 2,
                                       CGRectGetMinY(self.titleLabel.frame) - titleInsets.top,
                                       chromeWidth, titleLabelHeight + titleInsets.top + titleInsets.bottom);
            self.titleBackgroundView.frame = chrome;
            self.titleBackgroundView.layer.cornerRadius = MIN(MAX(0, self.titleCornerRadius), CGRectGetHeight(chrome) / 2);
            self.titleBackgroundView.layer.borderWidth = self.titleBorderWidth;
            UIColor *borderColor = self.titleBorderColor;
            if (@available(iOS 13.0, *)) {
                borderColor = [borderColor resolvedColorWithTraitCollection:self.traitCollection];
            }
            self.titleBackgroundView.layer.borderColor = borderColor.CGColor;
            [self insertSubview:self.titleBackgroundView belowSubview:self.titleLabel];
        }
    }

    if (isShowImageView) {
        CGFloat imageViewWidth = CGRectGetWidth(self.imageView.frame);
        CGFloat imageViewHeight = CGRectGetHeight(self.imageView.frame);
        CGFloat imageViewX = (CGRectGetWidth(self.bounds) - imageViewWidth) / 2;
        CGFloat imageViewY = (CGRectGetMinY(self.titleLabel.frame) - titleInsets.top - imageViewHeight) / 2;
        if (!isShowTitleLabel) imageViewY = (CGRectGetHeight(self.bounds) - imageViewHeight) / 2;
        imageViewX += self.itemImageOffset.horizontal;
        imageViewY += self.itemImageOffset.vertical;
        self.imageView.frame = CGRectMake(imageViewX, imageViewY,
            MAX(0, imageViewWidth - self.itemImageInsets.left - self.itemImageInsets.right),
            MAX(0, imageViewHeight - self.itemImageInsets.top - self.itemImageInsets.bottom));
        self.animationView.frame = self.imageView.frame;
    } else {
        self.imageView.frame = CGRectZero;
    }
    [self cyl_layoutBadgeAnchoredToImage:isShowImageView];
}

/// [EN] The icon at the leading edge, then the title; both centered vertically. [CN] 图标在前缘，标题在后，二者垂直居中。
- (void)cyl_layoutHorizontallyShowingImage:(BOOL)showImage title:(BOOL)showTitle {
    CGFloat width = CGRectGetWidth(self.bounds), height = CGRectGetHeight(self.bounds);
    CGSize imageSize = CGSizeZero;
    if (showImage) {
        imageSize = CGSizeMake(MAX(0, CGRectGetWidth(self.imageView.frame) - self.itemImageInsets.left - self.itemImageInsets.right),
                               MAX(0, CGRectGetHeight(self.imageView.frame) - self.itemImageInsets.top - self.itemImageInsets.bottom));
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
    UIOffset titleOffset = UIOffsetEqualToOffset(self.itemTitleOffset, UIOffsetZero) ? self.appearanceTitleOffset : self.itemTitleOffset;
    titleFrame = CGRectOffset(titleFrame, titleOffset.horizontal, titleOffset.vertical);
    self.imageView.frame = showImage ? imageFrame : CGRectZero;
    self.animationView.frame = self.imageView.frame;
    self.titleLabel.textAlignment = NSTextAlignmentNatural;
    self.titleLabel.frame = showTitle ? titleFrame : CGRectZero;
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
        [self bringSubviewToFront:self.badgeLabel];
    }
}
@end

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

static id<CYLPlaceholderItemAnimationService> CYLPlaceholderItemAnimationCurrentService;

void CYLPlaceholderItemAnimationSetService(id<CYLPlaceholderItemAnimationService> service) {
    @synchronized ([CYLPlaceholderBadgeAppearance class]) {
        CYLPlaceholderItemAnimationCurrentService = service;
    }
}

id<CYLPlaceholderItemAnimationService> CYLPlaceholderItemAnimationGetService(void) {
    @synchronized ([CYLPlaceholderBadgeAppearance class]) {
        return CYLPlaceholderItemAnimationCurrentService;
    }
}

@interface CYLPlaceholderView ()
@property (nonatomic, copy, readwrite) NSDictionary<NSString *, id> *itemAttributes;
@property (nonatomic, strong) CYLPlaceholderItemView *itemView;
@property (nonatomic, copy) NSArray<UIImage *> *gifFrames;
@property (nonatomic, copy) NSArray<NSNumber *> *gifDelays;
@property (nonatomic, strong) UIView<CYLPlaceholderAnimationPlayer> *backendView;
@property (nonatomic, strong) NSBundle *animationImageBundle;
@property (nonatomic) BOOL animationStopped;
@property (nonatomic) BOOL animationShowsLastFrame;
@property (nonatomic, strong) NSNumber *animationSeekProgress;
@property (nonatomic, strong) NSNumber *animationSpeed;
@property (nonatomic, readwrite, getter=isTapHighlighted) BOOL tapHighlighted;
/// Whether the tap API added the button trait, and the not-enabled trait, so it removes only what it added.
@property (nonatomic) BOOL tapAddedButtonTrait;
@property (nonatomic) BOOL tapAddedNotEnabledTrait;
@property (nonatomic, strong) UIImage *selectedImage;
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

@implementation CYLPlaceholderView

static NSMutableDictionary<NSString *, CYLPlaceholderAnimationFactory> *CYLPlaceholderAnimationFactories(void) {
    static NSMutableDictionary<NSString *, CYLPlaceholderAnimationFactory> *factories;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ factories = [NSMutableDictionary dictionary]; });
    return factories;
}

+ (BOOL)registerAnimationFactory:(CYLPlaceholderAnimationFactory)factory forFileExtension:(NSString *)fileExtension {
    NSCharacterSet *invalid = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    if (![fileExtension isKindOfClass:NSString.class] || !fileExtension.length ||
        [fileExtension rangeOfCharacterFromSet:invalid].location != NSNotFound ||
        [fileExtension.lowercaseString isEqualToString:@"gif"]) {
        NSLog(@"CYLTableViewPlaceHolder: invalid or reserved animation extension.");
        return NO;
    }
    NSMutableDictionary *factories = CYLPlaceholderAnimationFactories();
    @synchronized (factories) {
        if (factory) factories[fileExtension.lowercaseString] = [factory copy];
        else [factories removeObjectForKey:fileExtension.lowercaseString];
    }
    return YES;
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
    for (NSString *key in @[CYLPlaceholderItemAnimationColors, CYLPlaceholderItemAnimationDarkColors,
                             CYLPlaceholderItemLottieDarkColors, CYLPlaceholderItemRiveDarkColors]) {
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
            self.itemView.titleBackgroundView = chrome;
            [self.itemView insertSubview:chrome belowSubview:self.textLabel];
            self.itemView.titleBorderColor = colors[CYLPlaceholderItemTitleBorderColor];
            self.itemView.titleBorderWidth = titleChromeNumbers[0];
            self.itemView.titleCornerRadius = titleChromeNumbers[1];
            self.itemView.titleMinimumWidth = titleChromeNumbers[2];
            self.itemView.titleContentInsets = titleContentInsets;
        }
        _animationImageBundle = imageBundle;
        _selectedImage = selectedImage;
        _selectedTitle = [selectedTitle copy];
        _selectedTitleColor = colors[CYLPlaceholderItemSelectedTitleColor];
        _selectedIconColor = colors[CYLPlaceholderItemSelectedIconColor];
        _selectedBackgroundColor = colors[CYLPlaceholderItemSelectedBackgroundColor];
        _selectedTitleFont = selectedFont;
        self.itemView.itemTitleOffset = titleOffset;
        self.itemView.itemImageOffset = imageOffset;
        self.itemView.itemImageInsets = insets;
        self.itemView.horizontal = horizontal;
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
    if (_selected == selected) return;
    if (selected) {
        self.normalImage = self.imageView.image;
        self.normalTitle = self.textLabel.text;
        self.normalTitleColor = self.textLabel.textColor;
        self.normalIconColor = self.imageView.tintColor;
        self.normalBackgroundColor = self.backgroundColor;
        self.normalTitleFont = self.textLabel.font;
        self.normalImageHidden = self.imageView.hidden;
        self.normalTitleHidden = self.textLabel.hidden;
        self.normalHasSelectedTrait = (self.accessibilityTraits & UIAccessibilityTraitSelected) != 0;
        if (self.selectedImage) {
            self.imageView.image = self.selectedImage;
            self.imageView.hidden = NO;
        }
        if (self.selectedTitle) {
            self.textLabel.text = self.selectedTitle;
            self.textLabel.hidden = NO;
        }
        // Explicit selected values, then the selected appearance defaults, then the normal values.
        _selected = YES;
        for (NSString *key in CYLPlaceholderAppearanceKeys()) {
            id value = [self cyl_desiredAppearanceValueForKey:key];
            [self cyl_setAppearanceTargetValue:value forKey:key];
            self.appearanceAppliedValues[key] = value ?: NSNull.null;
        }
        self.accessibilityTraits |= UIAccessibilityTraitSelected;
    } else {
        self.imageView.image = self.normalImage;
        self.imageView.hidden = self.normalImageHidden;
        self.textLabel.text = self.normalTitle;
        self.textLabel.hidden = self.normalTitleHidden;
        self.textLabel.textColor = self.normalTitleColor;
        self.imageView.tintColor = self.normalIconColor;
        self.backgroundColor = self.normalBackgroundColor;
        self.textLabel.font = self.normalTitleFont;
        _selected = NO;
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
    _selected = selected;
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
        self.selectionIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.itemView insertSubview:self.selectionIndicatorView atIndex:0];
    }
    UIImage *image = indicatorImage;
    if (indicatorTintColor && image.renderingMode != UIImageRenderingModeAlwaysOriginal) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.selectionIndicatorView.image = image;
    self.selectionIndicatorView.tintColor = indicatorTintColor;
    self.selectionIndicatorView.contentMode = UIEdgeInsetsEqualToEdgeInsets(image.capInsets, UIEdgeInsetsZero) ?
        UIViewContentModeCenter : UIViewContentModeScaleToFill;
    self.selectionIndicatorView.frame = self.itemView.bounds;
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
    _badgeValue = [badgeValue copy];

    // State changes are synchronous; only the pop below is animated.
    self.badgeLabel.text = badgeValue;
    self.badgeLabel.hidden = badgeValue == nil;
    if (badgeValue) {
        [self cyl_applyBadgeAppearance];
        if (self.badgeLabel.superview != self.itemView) [self.itemView addSubview:self.badgeLabel];
    } else {
        [self.badgeLabel.layer removeAllAnimations];
        self.badgeLabel.transform = CGAffineTransformIdentity;
        self.badgeLabel.alpha = 1;
        [self.badgeLabel removeFromSuperview];
    }
    // One announcement, no duplicates: when the placeholder is itself an accessibility element, the badge joins its
    // value and the badge label is hidden from VoiceOver; otherwise the badge label is read on its own.
    BOOL placeholderIsAccessibilityElement = self.isAccessibilityElement;
    self.badgeLabel.isAccessibilityElement = !placeholderIsAccessibilityElement;
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
    [self.itemView setNeedsLayout];
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
    self.itemView.badgeCenterOffset = badgeCenterOffset;
    [self.itemView setNeedsLayout];
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
        [self.itemView setNeedsLayout];
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
    self.itemView.appearanceTitleOffset = adjustment;
    [self.itemView setNeedsLayout];
}
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultSelectionIndicatorImage, UIImage *, _defaultSelectionIndicatorImage)
CYL_PLACEHOLDER_APPEARANCE_SETTER(setDefaultSelectionIndicatorTintColor, UIColor *, _defaultSelectionIndicatorTintColor)
#undef CYL_PLACEHOLDER_APPEARANCE_SETTER

- (void)cyl_configureAnimations {
    [self.backendView stop];
    [self.itemView.animationView.layer removeAnimationForKey:@"CYLPlaceholderGIF"];
    [self.itemView.animationView removeFromSuperview];
    self.backendView = nil;
    self.itemView.animationView = nil;
    self.gifFrames = nil;
    self.gifDelays = nil;
    self.imageView.layer.hidden = NO;
    NSMutableDictionary *attributes = [self.itemAttributes mutableCopy];
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        NSArray *pairs = @[
            @[CYLPlaceholderItemGIFURL, CYLPlaceholderItemGIFFilePath, CYLPlaceholderItemGIFDarkURL, CYLPlaceholderItemGIFDarkFilePath],
            @[CYLPlaceholderItemLottieURL, CYLPlaceholderItemLottieFilePath, CYLPlaceholderItemLottieDarkURL, CYLPlaceholderItemLottieDarkFilePath],
            @[CYLPlaceholderItemPAGURL, CYLPlaceholderItemPAGFilePath, CYLPlaceholderItemPAGDarkURL, CYLPlaceholderItemPAGDarkFilePath],
            @[CYLPlaceholderItemRiveURL, CYLPlaceholderItemRiveFilePath, CYLPlaceholderItemRiveDarkURL, CYLPlaceholderItemRiveDarkFilePath],
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
    [self cyl_configureGIFWithAttributes:attributes imageBundle:self.animationImageBundle];
    if (!self.itemView.animationView) {
        [self cyl_configureBackendWithAttributes:attributes imageBundle:self.animationImageBundle];
    } else if (attributes[CYLPlaceholderItemAnimationColors] ||
               (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark &&
                attributes[CYLPlaceholderItemAnimationDarkColors])) {
        NSLog(@"CYLTableViewPlaceHolder: GIF color overrides are not supported.");
    }
    [self setNeedsLayout];
}

/// The item's content (image or animation, gap, title with its chrome) measured for a width, shared by the layout and
/// the intrinsic content size so the two cannot disagree.
- (CGSize)cyl_itemSizeForWidth:(CGFloat)width {
    BOOL showAnimation = self.itemView.animationView && (!self.imageView.image || !self.imageView.hidden);
    BOOL hasImage = (self.imageView.image != nil && !self.imageView.hidden) || showAnimation;
    BOOL hasTitle = self.textLabel.text.length > 0 && !self.textLabel.hidden;
    UIEdgeInsets insets = hasTitle ? self.itemView.titleContentInsets : UIEdgeInsetsZero;
    CGFloat textWidth = MAX(0, width - insets.left - insets.right);
    CGSize titleSize = hasTitle ? [self.textLabel.text boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX)
        options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.textLabel.font} context:nil].size : CGSizeZero;
    CGSize imageSize = showAnimation ? self.itemView.animationSize :
        (hasImage ? self.imageView.image.size : CGSizeZero);
    if (self.itemView.horizontal) {
        UIEdgeInsets imageInsets = self.itemView.itemImageInsets;
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
        titleWidth = MAX(ceil(titleSize.width) + insets.left + insets.right, self.itemView.titleMinimumWidth);
    }
    return CGSizeMake(MAX(imageSize.width, titleWidth), height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectIsEmpty(self.bounds)) return;
    CGFloat width = MAX(0, CGRectGetWidth(self.bounds) - 32);
    CGFloat itemHeight = [self cyl_itemSizeForWidth:width].height;
    self.itemView.frame = CGRectMake((CGRectGetWidth(self.bounds) - width) / 2,
        (CGRectGetHeight(self.bounds) - itemHeight) / 2, width, itemHeight);
    [self.itemView setNeedsLayout];
}

- (CGSize)intrinsicContentSize {
    if (!self.reportsContentSize) return [super intrinsicContentSize];
    CGFloat maxWidth = self.preferredMaxLayoutWidth > 0 ? self.preferredMaxLayoutWidth : CGRectGetWidth(UIScreen.mainScreen.bounds);
    CGSize size = [self cyl_itemSizeForWidth:MAX(0, maxWidth - 32)];
    if (size.height <= 0) return CGSizeZero;
    return CGSizeMake(MIN(maxWidth, ceil(size.width) + 32), ceil(size.height));
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

// GIF frame timing adapted from CYLGIFTabBarItemAnimator, CYLTabBarController (MIT).
- (void)cyl_configureGIFWithAttributes:(NSDictionary *)attributes imageBundle:(NSBundle *)imageBundle {
    id value = attributes[CYLPlaceholderItemGIFURL] ?: attributes[CYLPlaceholderItemGIFFilePath];
    if (!value) {
        id generic = attributes[CYLPlaceholderItemAnimationURL] ?: attributes[CYLPlaceholderItemAnimationFilePath];
        NSString *extension = [generic isKindOfClass:NSURL.class] ? [generic pathExtension] :
            ([generic isKindOfClass:NSString.class] ? [generic pathExtension] : nil);
        if ([extension.lowercaseString isEqualToString:@"gif"]) value = generic;
    }
    if (!value) return;
    NSURL *url = nil;
    if ([value isKindOfClass:NSURL.class]) {
        url = value;
    } else if ([value isKindOfClass:NSString.class] && [value length] > 0) {
        NSString *path = value;
        if (![path isAbsolutePath]) {
            NSBundle *bundle = imageBundle ?: NSBundle.mainBundle;
            path = [bundle pathForResource:[path stringByDeletingPathExtension] ofType:path.pathExtension] ?: path;
        }
        url = [NSURL fileURLWithPath:path];
    }
    if (!url.isFileURL || ![url.pathExtension.lowercaseString isEqualToString:@"gif"]) {
        NSLog(@"CYLTableViewPlaceHolder: GIF animation requires a local .gif file.");
        return;
    }
    // With the GIF subspec, the registered GIF animator plays it, like the other engines.
    if ([CYLPlaceholderItemAnimationGetService() canAnimateFileAtURL:url]) return;
    NSNumber *fileSize = nil;
    NSError *fileError = nil;
    if (![url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&fileError]) {
        NSLog(@"CYLTableViewPlaceHolder: cannot read GIF metadata: %@.", fileError.localizedDescription);
        return;
    }
    if (fileSize.unsignedLongLongValue > 16 * 1024 * 1024) {
        NSLog(@"CYLTableViewPlaceHolder: GIF animation exceeds the 16 MB input limit.");
        return;
    }
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:NULL];
    if (data.length > 16 * 1024 * 1024) {
        NSLog(@"CYLTableViewPlaceHolder: GIF animation exceeds the 16 MB input limit.");
        return;
    }
    CGImageSourceRef source = data ? CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL) : NULL;
    if (!source || !CGImageSourceGetType(source) || !CFEqual(CGImageSourceGetType(source), CFSTR("com.compuserve.gif")) ||
        CGImageSourceGetCount(source) == 0 || CGImageSourceGetCount(source) > 500) {
        if (source) CFRelease(source);
        NSLog(@"CYLTableViewPlaceHolder: cannot decode GIF animation at %@.", url);
        return;
    }
    NSMutableArray<UIImage *> *frames = [NSMutableArray array];
    NSMutableArray<NSNumber *> *delays = [NSMutableArray array];
    uint64_t pixelBytes = 0;
    for (size_t i = 0; i < CGImageSourceGetCount(source); i++) {
        NSDictionary *properties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, i, NULL));
        uint64_t width = [properties[(__bridge NSString *)kCGImagePropertyPixelWidth] unsignedLongLongValue];
        uint64_t height = [properties[(__bridge NSString *)kCGImagePropertyPixelHeight] unsignedLongLongValue];
        if (width == 0 || height == 0 || width > 4096 || height > 4096 ||
            width * height * 4 > 64 * 1024 * 1024 - pixelBytes) {
            CFRelease(source);
            NSLog(@"CYLTableViewPlaceHolder: GIF frame dimensions exceed the memory limit or are invalid.");
            return;
        }
        NSDictionary *options = @{(__bridge NSString *)kCGImageSourceShouldCacheImmediately: @YES};
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, (__bridge CFDictionaryRef)options);
        if (!image) {
            CFRelease(source);
            NSLog(@"CYLTableViewPlaceHolder: GIF frame %zu could not be decoded.", i);
            return;
        }
        pixelBytes += width * height * 4;
        [frames addObject:[UIImage imageWithCGImage:image]];
        CGImageRelease(image);
        NSDictionary *gif = properties[(__bridge NSString *)kCGImagePropertyGIFDictionary];
        NSNumber *delay = gif[(__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime] ?:
            gif[(__bridge NSString *)kCGImagePropertyGIFDelayTime];
        double seconds = delay.doubleValue;
        [delays addObject:@(isfinite(seconds) && seconds >= 0.02 ? seconds : 0.1)];
    }
    CFRelease(source);
    if (frames.count == 0) {
        NSLog(@"CYLTableViewPlaceHolder: GIF animation contains no decodable frames.");
        return;
    }
    CGSize size = frames.firstObject.size;
    id sizeValue = attributes[CYLPlaceholderItemGIFSize] ?: attributes[CYLPlaceholderItemAnimationSize];
    double numbers[2] = {0};
    if ([sizeValue isKindOfClass:NSValue.class] && strcmp([sizeValue objCType], @encode(CGSize)) == 0) {
        size = [sizeValue CGSizeValue];
    } else if (sizeValue && CYLPlaceholderNumbers(sizeValue, @[@[@"width", @"w"], @[@"height", @"h"]], numbers)) {
        size = CGSizeMake(numbers[0], numbers[1]);
    } else if (sizeValue) {
        NSLog(@"CYLTableViewPlaceHolder: invalid GIF animation size.");
        return;
    }
    if (!isfinite(size.width) || !isfinite(size.height) || size.width <= 0 || size.height <= 0 || size.width > 1000 || size.height > 1000) {
        NSLog(@"CYLTableViewPlaceHolder: invalid GIF animation size.");
        return;
    }
    self.gifFrames = frames;
    self.gifDelays = delays;
    UIViewContentMode contentMode = CYLPlaceholderAnimationContentMode(attributes[CYLPlaceholderItemAnimationOptions]);
    UIImageView *view = [[UIImageView alloc] initWithImage:frames.firstObject];
    view.contentMode = contentMode;
    self.itemView.animationView = view;
    self.itemView.animationSize = size;
    self.imageView.layer.hidden = YES;
    [self.itemView insertSubview:view aboveSubview:self.imageView];
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
        // Rive options: artboard, stateMachine, active, trigger, input, triggerInput, animation, legacy, duration
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
                ![key isEqualToString:@"duration"]) {
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

- (void)cyl_configureBackendWithAttributes:(NSDictionary *)attributes imageBundle:(NSBundle *)imageBundle {
   NSArray *sources = @[
       @[CYLPlaceholderItemGIFURL, CYLPlaceholderItemGIFFilePath, CYLPlaceholderItemGIFSize],
       @[CYLPlaceholderItemLottieURL, CYLPlaceholderItemLottieFilePath, CYLPlaceholderItemLottieSize],
       @[CYLPlaceholderItemPAGURL, CYLPlaceholderItemPAGFilePath, CYLPlaceholderItemPAGSize],
       @[CYLPlaceholderItemRiveURL, CYLPlaceholderItemRiveFilePath, CYLPlaceholderItemRiveSize],
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
   if (!value) return;
   NSURL *url = nil;
   if ([value isKindOfClass:NSURL.class]) {
       url = value;
   } else if ([value isKindOfClass:NSString.class] && [value length]) {
       NSString *path = value;
       if ([path containsString:@"://"]) {
           url = [NSURL URLWithString:path];
       } else {
           if (![path isAbsolutePath]) {
               NSBundle *bundle = imageBundle ?: NSBundle.mainBundle;
               path = [bundle pathForResource:path.stringByDeletingPathExtension ofType:path.pathExtension] ?: path;
           }
           url = [NSURL fileURLWithPath:path];
       }
   }
   if (!url.isFileURL) {
       NSLog(@"CYLTableViewPlaceHolder: animation requires a local file.");
       return;
   }
   CGSize size = self.imageView.image ? self.imageView.image.size : CGSizeMake(80, 80);
   double numbers[2] = {0};
   if ([sizeValue isKindOfClass:NSValue.class] && strcmp([sizeValue objCType], @encode(CGSize)) == 0) {
       size = [sizeValue CGSizeValue];
   } else if (sizeValue && CYLPlaceholderNumbers(sizeValue, @[@[@"width", @"w"], @[@"height", @"h"]], numbers)) {
       size = CGSizeMake(numbers[0], numbers[1]);
   } else if (sizeValue) {
       NSLog(@"CYLTableViewPlaceHolder: invalid animation size.");
       return;
   }
   if (!isfinite(size.width) || !isfinite(size.height) || size.width <= 0 || size.height <= 0 ||
       size.width > 1000 || size.height > 1000) {
       NSLog(@"CYLTableViewPlaceHolder: invalid animation size.");
       return;
   }
   NSError *error = nil;
   id options = attributes[CYLPlaceholderItemAnimationOptions] ?: @{};
   if (![options isKindOfClass:NSDictionary.class]) {
       NSLog(@"CYLTableViewPlaceHolder: animation options must be a dictionary.");
       return;
   }
   // Validate animation options for the backend
   [self cyl_validateAnimationOptions:options forExtension:url.pathExtension.lowercaseString];
   NSMutableDictionary *factories = CYLPlaceholderAnimationFactories();
   CYLPlaceholderAnimationFactory factory;
   @synchronized (factories) {
       factory = [factories[url.pathExtension.lowercaseString] copy];
   }
   UIView<CYLPlaceholderAnimationPlayer> *view;
   UIViewContentMode contentMode = CYLPlaceholderAnimationContentMode(options);
   if (factory) {
       view = factory(url, size, contentMode, options, &error);
   } else {
       id<CYLPlaceholderItemAnimationService> service = CYLPlaceholderItemAnimationGetService();
       if (!service) {
           NSLog(@"CYLTableViewPlaceHolder: animation backend is not installed; showing the static image.");
           return;
       }
       view = [service animationViewWithFileURL:url size:size contentMode:contentMode
                                        options:options error:&error];
   }
   if (!view) {
       NSLog(@"CYLTableViewPlaceHolder: animation could not be loaded: %@.", error.localizedDescription ?: @"factory returned no view");
       return;
   }
   __weak typeof(self) weakSelf = self;
   __weak UIView<CYLPlaceholderAnimationPlayer> *weakView = view;
   view.errorHandler = ^(NSError *backendError) {
       NSLog(@"CYLTableViewPlaceHolder: animation failed: %@.", backendError.localizedDescription);
       CYLPlaceholderView *strongSelf = weakSelf;
       if (!strongSelf || strongSelf.backendView != weakView) return;
       [strongSelf.backendView removeFromSuperview];
       strongSelf.backendView = nil;
       strongSelf.itemView.animationView = nil;
       strongSelf.imageView.layer.hidden = NO;
       [strongSelf setNeedsLayout];
   };
   view.readyHandler = ^{
       CYLPlaceholderView *strongSelf = weakSelf;
       if (strongSelf.backendView == weakView && weakView) {
           strongSelf.imageView.layer.hidden = YES;
           if (strongSelf.animationStopped) [strongSelf cyl_updateAnimationPlayback];
       }
   };
   self.backendView = view;
   self.itemView.animationView = view;
   self.itemView.animationSize = size;
   self.imageView.layer.hidden = view.isReady;
   [self.itemView insertSubview:view aboveSubview:self.imageView];
   NSMutableDictionary<NSString *, UIColor *> *animationColors = [NSMutableDictionary dictionary];
   NSMutableArray *colorSources = [NSMutableArray array];
   if (attributes[CYLPlaceholderItemAnimationColors]) [colorSources addObject:attributes[CYLPlaceholderItemAnimationColors]];
   if (@available(iOS 13.0, *)) {
       if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
           if (attributes[CYLPlaceholderItemAnimationDarkColors]) [colorSources addObject:attributes[CYLPlaceholderItemAnimationDarkColors]];
           NSString *specificKey = [url.pathExtension.lowercaseString isEqualToString:@"json"] ? CYLPlaceholderItemLottieDarkColors :
               ([url.pathExtension.lowercaseString isEqualToString:@"riv"] ? CYLPlaceholderItemRiveDarkColors : nil);
           if (specificKey && attributes[specificKey]) [colorSources addObject:attributes[specificKey]];
       }
   }
   for (NSDictionary *source in colorSources) {
       [source enumerateKeysAndObjectsUsingBlock:^(NSString *path, id value, BOOL *stop) {
           UIColor *color = CYLPlaceholderColor(value);
           if (@available(iOS 13.0, *)) color = [color resolvedColorWithTraitCollection:self.traitCollection];
           animationColors[path] = color;
       }];
   }
   if (animationColors.count &&
       (![view respondsToSelector:@selector(setAnimationColors:)] || ![view setAnimationColors:animationColors])) {
       NSLog(@"CYLTableViewPlaceHolder: animation color overrides are not supported by this player.");
   }
   // The `animationSpeed` option is the per-item form of CYLTabBarController's `tabBarItemAnimationSpeed`;
   // a speed set later with -setPlaceholderAnimationSpeed: wins.
   id speedOption = options[@"animationSpeed"];
   if (speedOption && !self.animationSpeed) {
       double speed = [speedOption respondsToSelector:@selector(doubleValue)] ? [speedOption doubleValue] : NAN;
       if (!isfinite(speed) || speed <= 0 || ![view respondsToSelector:@selector(setAnimationSpeed:)] ||
           ![view setAnimationSpeed:speed]) {
           NSLog(@"CYLTableViewPlaceHolder: animationSpeed must be positive and supported by the player.");
       }
   }
   if (self.animationSpeed &&
       (![view respondsToSelector:@selector(setAnimationSpeed:)] ||
        ![view setAnimationSpeed:self.animationSpeed.doubleValue])) {
       NSLog(@"CYLTableViewPlaceHolder: the replacement animation does not support playback speed.");
   }
   [self cyl_applyAnimationRepeatCount];
}

/// Passes `animationRepeatCount` to the player; the built-in GIF decoder reads it when it plays.
- (void)cyl_applyAnimationRepeatCount {
    UIView<CYLPlaceholderAnimationPlayer> *view = self.backendView;
    if (!view) return;
    BOOL applied = [view respondsToSelector:@selector(setAnimationRepeatCount:)] &&
        [view setAnimationRepeatCount:self.animationRepeatCount];
    if (!applied && self.animationRepeatCount != 1) {
        NSLog(@"CYLTableViewPlaceHolder: this animation does not support a repeat count of %ld; it plays as its file "
              @"defines.", (long)self.animationRepeatCount);
    }
}

- (void)setAnimationRepeatCount:(NSInteger)animationRepeatCount {
    if (animationRepeatCount < 0 || _animationRepeatCount == animationRepeatCount) return;
    _animationRepeatCount = animationRepeatCount;
    [self cyl_applyAnimationRepeatCount];
    [self cyl_updateAnimationPlayback];
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
    [UIView animateWithDuration:highlighted ? 0.08 : 0.2 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        self.itemView.alpha = alpha;
        self.itemView.transform = transform;
    } completion:nil];
}

- (BOOL)cyl_touchIsInside:(NSSet<UITouch *> *)touches {
    // [EN] A little slop around the view, as UIButton allows. [CN] 与 UIButton 一样，允许在视图外有少许容差。
    CGPoint point = [touches.anyObject locationInView:self];
    return CGRectContainsPoint(CGRectInset(self.bounds, -24, -24), point);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isTapInteractive) { [super touchesBegan:touches withEvent:event]; return; }
    [self cyl_setTapHighlighted:YES];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isTapInteractive) { [super touchesMoved:touches withEvent:event]; return; }
    [self cyl_setTapHighlighted:[self cyl_touchIsInside:touches]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isTapInteractive) { [super touchesEnded:touches withEvent:event]; return; }
    BOOL inside = [self cyl_touchIsInside:touches];
    [self cyl_setTapHighlighted:NO];
    if (inside) [self performTap];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self cyl_setTapHighlighted:NO];
    if (!self.isTapInteractive) [super touchesCancelled:touches withEvent:event];
}

- (void)dealloc {
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

- (void)playPlaceholderAnimation {
    self.animationStopped = NO;
    self.animationShowsLastFrame = NO;
    self.animationSeekProgress = nil;
    [self cyl_updateAnimationPlayback];
}

- (void)stopPlaceholderAnimation {
    self.animationStopped = YES;
    self.animationShowsLastFrame = NO;
    self.animationSeekProgress = nil;
    [self cyl_updateAnimationPlayback];
}

- (void)showPlaceholderAnimationLastFrame {
    self.animationStopped = YES;
    self.animationShowsLastFrame = YES;
    self.animationSeekProgress = nil;
    [self cyl_updateAnimationPlayback];
}

- (BOOL)setPlaceholderAnimationProgress:(CGFloat)progress {
    if (!NSThread.isMainThread || !isfinite(progress) || progress < 0 || progress > 1 ||
        ![self.backendView respondsToSelector:@selector(setAnimationProgress:)]) return NO;
    if (![self.backendView setAnimationProgress:progress]) return NO;
    self.animationStopped = YES;
    self.animationShowsLastFrame = NO;
    self.animationSeekProgress = @(progress);
    return YES;
}

- (BOOL)setPlaceholderAnimationSpeed:(CGFloat)speed {
    if (!NSThread.isMainThread || !isfinite(speed) || speed <= 0 ||
        ![self.backendView respondsToSelector:@selector(setAnimationSpeed:)]) return NO;
    if (![self.backendView setAnimationSpeed:speed]) return NO;
    self.animationSpeed = @(speed);
    return YES;
}

- (void)cyl_updateAnimationPlayback {
    if (self.backendView) {
        if (self.animationShowsLastFrame) [self.backendView showLastFrame];
        else if (self.animationSeekProgress) {
            if (![self.backendView respondsToSelector:@selector(setAnimationProgress:)] ||
                ![self.backendView setAnimationProgress:self.animationSeekProgress.doubleValue]) {
                NSLog(@"CYLTableViewPlaceHolder: the replacement animation does not support seeking.");
            }
        }
        else if (!self.animationStopped && self.window && !self.hidden && !UIAccessibilityIsReduceMotionEnabled()) [self.backendView play];
        else [self.backendView stop];
        return;
    }
    UIImageView *view = (UIImageView *)self.itemView.animationView;
    if (!view) return;
    [view.layer removeAnimationForKey:@"CYLPlaceholderGIF"];
    view.image = self.animationShowsLastFrame ? self.gifFrames.lastObject : self.gifFrames.firstObject;
    if (self.animationStopped || !self.window || self.hidden || UIAccessibilityIsReduceMotionEnabled() || self.gifFrames.count < 2) return;
    double duration = [[self.gifDelays valueForKeyPath:@"@sum.self"] doubleValue];
    NSMutableArray *contents = [NSMutableArray array];
    NSMutableArray *times = [NSMutableArray array];
    double elapsed = 0;
    for (NSUInteger i = 0; i < self.gifFrames.count; i++) {
        [contents addObject:(__bridge id)self.gifFrames[i].CGImage];
        [times addObject:@(elapsed / duration)];
        elapsed += self.gifDelays[i].doubleValue;
    }
    [contents addObject:(__bridge id)self.gifFrames.lastObject.CGImage];
    [times addObject:@1];
    view.image = self.gifFrames.lastObject;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animation.calculationMode = kCAAnimationDiscrete;
    animation.values = contents;
    animation.keyTimes = times;
    animation.duration = duration;
    animation.repeatCount = self.animationRepeatCount == 0 ? HUGE_VALF : (float)self.animationRepeatCount;
    [view.layer addAnimation:animation forKey:@"CYLPlaceholderGIF"];
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
        _itemView = [[CYLPlaceholderItemView alloc] initWithFrame:CGRectZero];
        [self addSubview:_itemView];
        _tapInteractionEnabled = YES;
        _animationRepeatCount = 1;
        _imageView = _itemView.imageView;
        _imageView.image = [CYLPlaceholderView imageForStyle:CYLPlaceholderStyleEmpty];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _textLabel = _itemView.titleLabel;
        _textLabel.text = [CYLPlaceholderView localizedTextForMessage:CYLPlaceholderMessageEmpty];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = UIColor.grayColor;
        // A text-style font (17 points at the default size), so the title follows Dynamic Type.
        _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _textLabel.adjustsFontForContentSizeCategory = YES;
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
        _itemView.badgeLabel = _badgeLabel;
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
