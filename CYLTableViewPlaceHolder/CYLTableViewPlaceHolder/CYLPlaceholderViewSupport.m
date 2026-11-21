//
//  CYLPlaceholderViewSupport.m
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The Objective-C half of CYLPlaceholderView (the class is Swift since 2026-11-19, `CYLPlaceholderView.swift`): the
//      item keys and the error domain (FOUNDATION_EXPORT constants keep their symbols and values) and the badge appearance.
// [CN] CYLPlaceholderView 的 Objective-C 部分（该类自 2026-11-19 起用 Swift 编写，见 `CYLPlaceholderView.swift`）：item key 与错误域
//      （FOUNDATION_EXPORT 常量保持原有符号与取值）以及角标外观。

#import "CYLPlaceholderView.h"

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
NSString *const CYLPlaceholderItemInteractionEnabled = @"CYLPlaceholderItemInteractionEnabled";
NSString *const CYLPlaceholderItemTapHighlightStyle = @"CYLPlaceholderItemTapHighlightStyle";
NSString *const CYLPlaceholderItemAnimationRepeatCount = @"CYLPlaceholderItemAnimationRepeatCount";
NSString *const CYLPlaceholderItemImages = @"CYLPlaceholderItemImages";
NSString *const CYLPlaceholderItemAnimationDuration = @"CYLPlaceholderItemAnimationDuration";
NSErrorDomain const CYLPlaceholderConfigurationErrorDomain = @"CYLPlaceholderConfigurationError";

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
