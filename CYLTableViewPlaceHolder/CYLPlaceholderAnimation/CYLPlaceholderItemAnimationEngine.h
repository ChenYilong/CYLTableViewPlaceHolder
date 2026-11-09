//
//  CYLPlaceholderItemAnimationEngine.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimationEngine`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  Internal: implements Core's `CYLPlaceholderItemAnimationService` and
//  installs itself when the `CYLPlaceholderItemAnimation` subspec is linked.
//

#import <Foundation/Foundation.h>
#if __has_include("../CYLTableViewPlaceHolder/CYLPlaceholderItemAnimationService.h")
#import "../CYLTableViewPlaceHolder/CYLPlaceholderItemAnimationService.h"
#else
#import "CYLPlaceholderItemAnimationService.h"
#endif
#import "CYLPlaceholderItemAnimatorRegistry.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLPlaceholderItemAnimationEngine : NSObject <CYLPlaceholderItemAnimationService>
@property (nonatomic, strong, readonly) id<CYLPlaceholderItemAnimatorRegistering> registry;
- (instancetype)initWithRegistry:(id<CYLPlaceholderItemAnimatorRegistering>)registry NS_DESIGNATED_INITIALIZER;
/// Uses the shared registry.
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
