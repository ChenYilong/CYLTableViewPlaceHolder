//
//  CYLPlaceholderHUDSupport.m
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The Objective-C half of CYLPlaceholderHUD (the class is Swift since 2026-11-19, `CYLPlaceholderHUD.swift`): the
//      notification names and the userInfo key, FOUNDATION_EXPORT symbols that keep their names and values (Swift cannot
//      define a C symbol).
// [CN] CYLPlaceholderHUD 的 Objective-C 部分（该类自 2026-11-19 起用 Swift 编写，见 `CYLPlaceholderHUD.swift`）：通知名与
//      userInfo 的 key，FOUNDATION_EXPORT 符号保持原有名称与取值（Swift 无法定义 C 符号）。

#import "CYLPlaceholderHUD.h"

NSNotificationName const CYLPlaceholderHUDWillAppearNotification = @"CYLPlaceholderHUDWillAppearNotification";
NSNotificationName const CYLPlaceholderHUDDidAppearNotification = @"CYLPlaceholderHUDDidAppearNotification";
NSNotificationName const CYLPlaceholderHUDWillDisappearNotification = @"CYLPlaceholderHUDWillDisappearNotification";
NSNotificationName const CYLPlaceholderHUDDidDisappearNotification = @"CYLPlaceholderHUDDidDisappearNotification";
NSNotificationName const CYLPlaceholderHUDDidReceiveTouchEventNotification =
    @"CYLPlaceholderHUDDidReceiveTouchEventNotification";
NSNotificationName const CYLPlaceholderHUDDidTouchDownInsideNotification =
    @"CYLPlaceholderHUDDidTouchDownInsideNotification";
NSString *const CYLPlaceholderHUDStatusUserInfoKey = @"CYLPlaceholderHUDStatusUserInfoKey";
