//
//  CYLRivePlaceholderItemAnimator.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLRiveTabBarItemAnimator`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  Rive animations (`RiveRuntime` 6.29+): `pod 'CYLTableViewPlaceHolder/Rive'`.
//  Rive takes the short path: its Swift views (`RiveSwift/`) adopt the playable
//  view protocols, and this class only registers a ready-made
//  `CYLPlaceholderItemViewAnimator` for ".riv" files.
//

#import <Foundation/Foundation.h>
#if __has_include("../CYLPlaceholderItemViewAnimator.h")
#import "../CYLPlaceholderItemViewAnimator.h"
#else
#import "CYLPlaceholderItemViewAnimator.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/*! Rive option names, carried in `CYLPlaceholderItemAnimationOptions`. */
typedef NSString *CYLPlaceholderAnimationOption NS_TYPED_EXTENSIBLE_ENUM;
FOUNDATION_EXTERN CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveArtboard;
FOUNDATION_EXTERN CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveStateMachine;
FOUNDATION_EXTERN CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveActiveProperty;
FOUNDATION_EXTERN CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveActiveDuration;
FOUNDATION_EXTERN CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveTriggerProperty;
FOUNDATION_EXTERN CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveColor;
FOUNDATION_EXTERN CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveInput;
FOUNDATION_EXTERN CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveTriggerInput;
FOUNDATION_EXTERN CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveAnimation;
FOUNDATION_EXTERN CYLPlaceholderAnimationOption const CYLPlaceholderAnimationOptionRiveLegacyRuntime;

@interface CYLRivePlaceholderItemAnimator : NSObject
@property (class, nonatomic, readonly) CYLPlaceholderItemViewAnimator *animator;
@end

NS_ASSUME_NONNULL_END
