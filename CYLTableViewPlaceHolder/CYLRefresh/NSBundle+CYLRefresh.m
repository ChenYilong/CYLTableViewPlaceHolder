//
//  NSBundle+CYLRefresh.m
//  CYLRefresh
//
//  Created by MJ Lee on 16/6/13.
//  Copyright © 2016年 小码哥. All rights reserved.
//

#import "NSBundle+CYLRefresh.h"
#import "CYLRefreshComponent.h"
#import "CYLRefreshConfig.h"

/// The refresh component's strings table inside CYLTableViewPlaceHolder.bundle; the placeholder uses Localizable.
static NSString *const CYLRefreshStringsTable = @"CYLRefresh";

static NSBundle *cyl_defaultI18nBundle = nil;
static NSBundle *cyl_systemI18nBundle = nil;

@implementation NSBundle (CYLRefresh)
+ (instancetype)cyl_refreshBundle
{
    static NSBundle *refreshBundle = nil;
    if (refreshBundle == nil) {
#ifdef SWIFT_PACKAGE
        NSBundle *containnerBundle = SWIFTPM_MODULE_BUNDLE;
#else
        NSBundle *containnerBundle = [NSBundle bundleForClass:[CYLRefreshComponent class]];
#endif
        // Localizations and images live in the library's single resource bundle,
        // CYLTableViewPlaceHolder.bundle, next to the placeholder's resources.
        NSString *bundlePath = [containnerBundle pathForResource:@"CYLTableViewPlaceHolder" ofType:@"bundle"];
        if (!bundlePath) {
            bundlePath = [NSBundle.mainBundle pathForResource:@"CYLTableViewPlaceHolder" ofType:@"bundle"];
        }
        if (bundlePath) {
            refreshBundle = [NSBundle bundleWithPath:bundlePath];
        }
    }
    return refreshBundle;
}

+ (UIImage *)cyl_arrowImage
{
    static UIImage *arrowImage = nil;
    if (arrowImage == nil) {
        arrowImage = [[UIImage imageWithContentsOfFile:[[self cyl_refreshBundle] pathForResource:@"CYLRefreshArrow@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return arrowImage;
}

+ (UIImage *)cyl_trailArrowImage {
    static UIImage *arrowImage = nil;
    if (arrowImage == nil) {
        arrowImage = [[UIImage imageWithContentsOfFile:[[self cyl_refreshBundle] pathForResource:@"CYLRefreshTrailArrow@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return arrowImage;
}

+ (NSString *)cyl_localizedStringForKey:(NSString *)key
{
    return [self cyl_localizedStringForKey:key value:nil];
}

+ (NSString *)cyl_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    NSString *table = CYLRefreshConfig.defaultConfig.i18nFilename;

    // 如果没有缓存, 则走初始化逻辑
    if (cyl_defaultI18nBundle == nil) {
        NSString *language = CYLRefreshConfig.defaultConfig.languageCode;
        // 如果配置中没有配置语言
        if (!language) {
            language = [NSLocale preferredLanguages].firstObject;
        }
        NSBundle *bundle = CYLRefreshConfig.defaultConfig.i18nBundle;
        // 首先优先使用公共配置中的 i18nBundle, 如果为空则使用 mainBundle
        bundle = bundle ? bundle : NSBundle.mainBundle;
        // 按语言选取语言包
        NSString *i18nFolderPath = [bundle pathForResource:language ofType:@"lproj"];
        cyl_defaultI18nBundle = i18nFolderPath ? [NSBundle bundleWithPath:i18nFolderPath] : nil;
        // 检查语言包, 如果没有查找到, 则默认使用 mainBundle
        cyl_defaultI18nBundle = cyl_defaultI18nBundle ? cyl_defaultI18nBundle : NSBundle.mainBundle;

        // 获取 CYLRefresh 自有的语言包
        if (cyl_systemI18nBundle == nil) {
            cyl_systemI18nBundle = [self cyl_defaultI18nBundleWithLanguage:language];
        }
    }
    // 首先在 CYLRefresh 内置语言文件（统一资源包中的 CYLRefresh.strings）中寻找
    if (cyl_systemI18nBundle) {
        value = [cyl_systemI18nBundle localizedStringForKey:key value:value table:CYLRefreshStringsTable];
    }
    // 然后在 MainBundle 对应语言文件中寻找
    value = [cyl_defaultI18nBundle localizedStringForKey:key value:value table:table];
    return value;
}

+ (NSBundle *)cyl_defaultI18nBundleWithLanguage:(NSString *)language {
    if ([language hasPrefix:@"en"]) {
        language = @"en";
    } else if ([language hasPrefix:@"zh"]) {
        if ([language rangeOfString:@"Hans"].location != NSNotFound) {
            language = @"zh-Hans"; // 简体中文
        } else { // zh-Hant\zh-HK\zh-TW
            language = @"zh-Hant"; // 繁體中文
        }
    } else if ([language hasPrefix:@"ja"]) {
        language = @"ja";
    } else if ([language hasPrefix:@"ko"]) {
        language = @"ko";
    } else if ([language hasPrefix:@"ru"]) {
        language = @"ru";
    } else if ([language hasPrefix:@"uk"]) {
        language = @"uk";
    } else {
        language = @"en";
    }

    // 从统一资源包 CYLTableViewPlaceHolder.bundle 中查找资源
    NSString *path = [[NSBundle cyl_refreshBundle] pathForResource:language ofType:@"lproj"];
    return path ? [NSBundle bundleWithPath:path] : nil;
}
@end

@implementation CYLRefreshConfig (Bundle)

+ (void)cyl_resetLanguageResourceCache {
    cyl_defaultI18nBundle = nil;
    cyl_systemI18nBundle = nil;
}

@end
