//
//  CYLPlaceholderLocalizationSupport.m
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The Objective-C half of CYLPlaceholderLocalization (the class is Swift since 2026-11-19,
//      `CYLPlaceholderLocalization.swift`): the notification constant (a FOUNDATION_EXPORT symbol keeps its name and
//      value) and the C functions with C linkage that Objective-C macros expand to and Swift calls directly.
// [CN] CYLPlaceholderLocalization 的 Objective-C 部分（该类自 2026-11-19 起用 Swift 编写，见 `CYLPlaceholderLocalization.swift`）：
//      通知常量（FOUNDATION_EXPORT 符号保持原有名称与取值），以及 Objective-C 宏展开所用、Swift 可直接调用的 C 链接函数。

#import "CYLPlaceholderLocalization.h"
// [EN] The Swift class comes with the umbrella header (the generated Swift header). [CN] Swift 类的接口来自总头文件（生成的 Swift 头文件）。
#import "CYLTableViewPlaceHolder.h"

NSNotificationName const CYLPlaceholderLocalizationLanguageDidChangeNotification =
    @"CYLPlaceholderLocalizationLanguageDidChangeNotification";

NSBundle *CYLPlaceholderResourceBundle(void) {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // [EN] Next to the library's code (a framework or the static library's host app), else in the main bundle.
        // [CN] 先在库代码所在的 bundle（framework 或静态库的宿主 App）中查找，找不到再查找 main bundle。
        NSBundle *container = [NSBundle bundleForClass:CYLPlaceholderLocalization.class];
        NSURL *url = [container URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
        if (!url) url = [NSBundle.mainBundle URLForResource:@"CYLTableViewPlaceHolder" withExtension:@"bundle"];
        bundle = url ? [NSBundle bundleWithURL:url] : nil;
        if (!bundle) NSLog(@"CYLTableViewPlaceHolder: placeholder resource bundle not found.");
    });
    return bundle;
}

NSURL *CYLPlaceholderResourceURLForPath(NSString *path) {
    if (![path isKindOfClass:NSString.class] || !path.length || [path hasPrefix:@"/"] ||
        [path.pathComponents containsObject:@".."]) return nil;
    NSBundle *bundle = CYLPlaceholderResourceBundle();
    if (!bundle) return nil;
    NSURL *url = [bundle.bundleURL URLByAppendingPathComponent:path];
    return [NSFileManager.defaultManager fileExistsAtPath:url.path] ? url : nil;
}

NSString *CYLPlaceholderLocalizedStringForKey(NSString *key, NSString *fallback) {
    return [CYLPlaceholderLocalization localizedStringForKey:key fallback:fallback];
}
