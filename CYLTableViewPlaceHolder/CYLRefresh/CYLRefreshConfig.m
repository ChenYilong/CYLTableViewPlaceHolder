//
//  CYLRefreshConfig.m
//
//  Created by Frank on 2018/11/27.
//  Copyright © 2018 小码哥. All rights reserved.
//

#import "CYLRefreshConfig.h"
#import "CYLRefreshConst.h"
#import "NSBundle+CYLRefresh.h"

@interface CYLRefreshConfig (Bundle)

+ (void)cyl_resetLanguageResourceCache;

@end

@implementation CYLRefreshConfig

static CYLRefreshConfig *cyl_RefreshConfig = nil;

+ (instancetype)defaultConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cyl_RefreshConfig = [[self alloc] init];
    });
    return cyl_RefreshConfig;
}

- (void)setLanguageCode:(NSString *)languageCode {
    if ([languageCode isEqualToString:_languageCode]) {
        return;
    }

    _languageCode = languageCode;
    // 重置语言资源
    [CYLRefreshConfig cyl_resetLanguageResourceCache];
    [NSNotificationCenter.defaultCenter
     postNotificationName:CYLRefreshDidChangeLanguageNotification object:self];
}

@end
