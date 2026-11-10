//
//  CYLPlaceholderLocalization.m
//  CYLTableViewPlaceHolder
//

#import "CYLPlaceholderLocalization.h"

NSNotificationName const CYLPlaceholderLocalizationLanguageDidChangeNotification =
    @"CYLPlaceholderLocalizationLanguageDidChangeNotification";

static NSString *CYLPlaceholderLocalizationOverride;

@implementation CYLPlaceholderLocalization

+ (NSArray<NSString *> *)supportedLanguages {
    // [EN] Same languages as the refresh table; both tables live in CYLTableViewPlaceHolder.bundle.
    // [CN] 与刷新组件的字符串表语言一致，两张表都在 CYLTableViewPlaceHolder.bundle 中。
    return @[@"en", @"zh-Hans", @"zh-Hant", @"ja", @"ko", @"ru", @"uk"];
}

+ (NSString *)language {
    @synchronized (self) {
        return CYLPlaceholderLocalizationOverride;
    }
}

+ (void)setLanguage:(NSString *)language {
    NSString *value = language.length > 0 ? [language copy] : nil;
    @synchronized (self) {
        if (value == CYLPlaceholderLocalizationOverride || [value isEqualToString:CYLPlaceholderLocalizationOverride]) return;
        CYLPlaceholderLocalizationOverride = value;
    }
    void (^post)(void) = ^{
        [NSNotificationCenter.defaultCenter postNotificationName:CYLPlaceholderLocalizationLanguageDidChangeNotification
                                                          object:nil];
    };
    if (NSThread.isMainThread) {
        post();
    } else {
        dispatch_async(dispatch_get_main_queue(), post);
    }
}

/// A supported language for a requested identifier: itself, its script variant for Chinese, or its base language.
+ (nullable NSString *)cyl_supportedLanguageForIdentifier:(NSString *)identifier {
    NSArray<NSString *> *supported = self.supportedLanguages;
    for (NSString *language in supported) {
        if ([language caseInsensitiveCompare:identifier] == NSOrderedSame) return language;
    }
    NSString *lower = identifier.lowercaseString;
    if ([lower hasPrefix:@"zh"]) {
        BOOL traditional = [lower containsString:@"hant"] || [lower hasSuffix:@"-tw"] || [lower hasSuffix:@"-hk"] ||
            [lower hasSuffix:@"-mo"];
        return traditional ? @"zh-Hant" : @"zh-Hans";
    }
    NSString *base = [[lower componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-_"]]
        firstObject];
    for (NSString *language in supported) {
        if ([language caseInsensitiveCompare:base] == NSOrderedSame) return language;
    }
    return nil;
}

+ (NSString *)effectiveLanguage {
    NSString *requested = self.language;
    if (requested) {
        return [self cyl_supportedLanguageForIdentifier:requested] ?: @"en";
    }
    return [NSBundle preferredLocalizationsFromArray:self.supportedLanguages
                                      forPreferences:NSLocale.preferredLanguages].firstObject ?: @"en";
}

+ (nullable NSBundle *)cyl_resourceBundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *container = [NSBundle bundleForClass:CYLPlaceholderLocalization.class];
        NSURL *url = [container URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
        if (!url) url = [NSBundle.mainBundle URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
        bundle = url ? [NSBundle bundleWithURL:url] : nil;
    });
    return bundle;
}

+ (NSString *)localizedStringForKey:(NSString *)key fallback:(NSString *)fallback {
    NSString *defaultValue = fallback ?: key;
    NSBundle *bundle = [self cyl_resourceBundle];
    if (!bundle) {
        NSLog(@"CYLTableViewPlaceHolder: placeholder resource bundle not found.");
        return defaultValue;
    }
    NSString *language = self.effectiveLanguage;
    NSString *path = [bundle pathForResource:language ofType:@"lproj"];
    NSBundle *localizedBundle = path ? [NSBundle bundleWithPath:path] : nil;
    if (!localizedBundle) {
        NSLog(@"CYLTableViewPlaceHolder: localization %@ is missing.", language);
        return defaultValue;
    }
    return [localizedBundle localizedStringForKey:key value:defaultValue table:nil];
}

@end

NSString *CYLPlaceholderLocalizedStringForKey(NSString *key, NSString *fallback) {
    return [CYLPlaceholderLocalization localizedStringForKey:key fallback:fallback];
}
