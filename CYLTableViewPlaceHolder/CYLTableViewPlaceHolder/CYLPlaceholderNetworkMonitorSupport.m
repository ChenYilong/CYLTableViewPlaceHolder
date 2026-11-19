//
//  CYLPlaceholderNetworkMonitorSupport.m
//  CYLTableViewPlaceHolder
//
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

// [EN] The Objective-C half of CYLPlaceholderNetworkMonitor (the class is Swift since 2026-11-19,
//      `CYLPlaceholderNetworkMonitor.swift`): the notification constant, a FOUNDATION_EXPORT symbol that keeps its name
//      and value (Swift cannot define a C symbol).
// [CN] CYLPlaceholderNetworkMonitor 的 Objective-C 部分（该类自 2026-11-19 起用 Swift 编写，见 `CYLPlaceholderNetworkMonitor.swift`）：
//      通知常量，FOUNDATION_EXPORT 符号保持原有名称与取值（Swift 无法定义 C 符号）。

#import "CYLPlaceholderNetworkMonitor.h"

NSNotificationName const CYLPlaceholderNetworkStatusDidChangeNotification = @"CYLPlaceholderNetworkStatusDidChangeNotification";
