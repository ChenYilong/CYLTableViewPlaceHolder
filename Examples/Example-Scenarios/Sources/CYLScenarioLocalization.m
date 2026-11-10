//
//  CYLScenarioLocalization.m
//  Example-Scenarios
//

#import "CYLScenarioLocalization.h"

static NSString *const CYLScenarioStringsTable = @"CYLScenarioExample";

/// The `.lproj` bundles for the app's language and for English. The language is chosen explicitly, as the core bundle
/// does: iOS only offers a sub-bundle's localizations that the main bundle also declares.
static void CYLScenarioLanguageBundles(NSBundle **preferred, NSBundle **english) {
    static NSBundle *preferredBundle = nil;
    static NSBundle *englishBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSBundle.mainBundle URLForResource:CYLScenarioStringsTable withExtension:@"bundle"];
        NSBundle *container = url ? [NSBundle bundleWithURL:url] : nil;
        NSArray<NSString *> *languages = @[@"en", @"zh-Hans", @"zh-Hant", @"ja", @"ko", @"ru", @"uk"];
        NSString *language = [NSBundle preferredLocalizationsFromArray:languages
                                                        forPreferences:NSLocale.preferredLanguages].firstObject ?: @"en";
        NSString *path = [container pathForResource:language ofType:@"lproj"];
        NSString *englishPath = [container pathForResource:@"en" ofType:@"lproj"];
        preferredBundle = path ? [NSBundle bundleWithPath:path] : nil;
        englishBundle = englishPath ? [NSBundle bundleWithPath:englishPath] : nil;
        if (!container) NSLog(@"Example-Scenarios: %@.bundle is missing from the app.", CYLScenarioStringsTable);
    });
    *preferred = preferredBundle;
    *english = englishBundle;
}

NSString *CYLScenarioLocalizedStringForKey(NSString *key) {
    NSBundle *preferred = nil;
    NSBundle *english = nil;
    CYLScenarioLanguageBundles(&preferred, &english);
    NSString *fallback = [english localizedStringForKey:key value:key table:CYLScenarioStringsTable] ?: key;
    return [preferred localizedStringForKey:key value:fallback table:CYLScenarioStringsTable] ?: fallback;
}
