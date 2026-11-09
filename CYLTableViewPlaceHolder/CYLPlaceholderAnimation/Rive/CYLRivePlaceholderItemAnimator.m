//
//  CYLRivePlaceholderItemAnimator.m
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLRiveTabBarItemAnimator`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLRivePlaceholderItemAnimator.h"
#if __has_include("../CYLPlaceholderItemAnimatorRegistry.h")
#import "../CYLPlaceholderItemAnimatorRegistry.h"
#else
#import "CYLPlaceholderItemAnimatorRegistry.h"
#endif
#if __has_include("../../CYLTableViewPlaceHolder/CYLPlaceholderView.h")
#import "../../CYLTableViewPlaceHolder/CYLPlaceholderView.h"
#else
#import "CYLPlaceholderView.h"
#endif

#if __has_include(<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>)
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder-Swift.h>
#define CYL_PLACEHOLDER_RIVE_SWIFT_VIEWS_AVAILABLE 1
#elif __has_include("CYLTableViewPlaceHolder-Swift.h")
#import "CYLTableViewPlaceHolder-Swift.h"
#define CYL_PLACEHOLDER_RIVE_SWIFT_VIEWS_AVAILABLE 1
#endif

CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveArtboard = @"artboard";
CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveStateMachine = @"stateMachine";
CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveActiveProperty = @"active";
CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveActiveDuration = @"duration";
CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveTriggerProperty = @"trigger";
CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveColor = @"color";
CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveInput = @"input";
CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveTriggerInput = @"triggerInput";
CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveAnimation = @"animation";
CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveLegacyRuntime = @"legacy";

@implementation CYLRivePlaceholderItemAnimator

/// The composition root: injects the legacy renderer into the current one.
static Class<CYLPlaceholderItemAnimationViewProviding> CYLRivePlaceholderItemAnimationViewProvider(void) {
#if defined(CYL_PLACEHOLDER_RIVE_SWIFT_VIEWS_AVAILABLE)
    if (@available(iOS 14.0, *)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CYLPlaceholderRiveItemAnimationView.legacyViewProvider = [CYLPlaceholderRiveLegacyItemAnimationView class];
#pragma clang diagnostic pop
        return [CYLPlaceholderRiveItemAnimationView class];
    }
#endif
    return nil;
}

+ (CYLPlaceholderItemViewAnimator *)animator {
    static CYLPlaceholderItemViewAnimator *animator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animator = [[CYLPlaceholderItemViewAnimator alloc] initWithIdentifier:@"Rive"
                                                               fileExtensions:@[ @"riv" ]
                                                                attributeKeys:@{
            CYLPlaceholderItemAnimationURL : CYLPlaceholderItemRiveURL,
            CYLPlaceholderItemAnimationFilePath : CYLPlaceholderItemRiveFilePath,
            CYLPlaceholderItemAnimationSize : CYLPlaceholderItemRiveSize,
            CYLPlaceholderItemAnimationDarkURL : CYLPlaceholderItemRiveDarkURL,
            CYLPlaceholderItemAnimationDarkFilePath : CYLPlaceholderItemRiveDarkFilePath,
            CYLPlaceholderItemAnimationDarkColors : CYLPlaceholderItemRiveDarkColors,
        }
                                                                 viewProvider:CYLRivePlaceholderItemAnimationViewProvider()];
    });
    return animator;
}

+ (void)load {
    [CYLPlaceholderItemAnimatorRegistry registerAnimator:self.animator];
}

@end
