//
//  CYLLottiePlaceholderItemAnimator.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLLottieTabBarItemAnimator`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  Lottie animations through the Swift bridge (`LottieSwift/`, lottie-ios 4.5.1+):
//  `pod 'CYLTableViewPlaceHolder/LottieSwift'` (`Lottie` is an alias). Lottie
//  2.x (Objective-C) is intentionally not supported.
//

#import <Foundation/Foundation.h>
#if __has_include("../CYLPlaceholderItemAnimator.h")
#import "../CYLPlaceholderItemAnimator.h"
#else
#import "CYLPlaceholderItemAnimator.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/*! Registers itself when linked; looked up last (fallback priority), for ".json" and ".lottie" files. */
@interface CYLLottiePlaceholderItemAnimator : NSObject <CYLPlaceholderItemAnimator>
@end

NS_ASSUME_NONNULL_END
