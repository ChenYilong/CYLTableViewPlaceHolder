//
//  CYLGIFPlaceholderItemAnimator.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLGIFTabBarItemAnimator`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  GIF placeholder animations that play once, like Lottie, PAG and Rive:
//  `pod 'CYLTableViewPlaceHolder/GIF'`. No third-party library: ImageIO decodes
//  it. Without this subspec, Core's built-in decoder still plays GIF files.
//

#import <Foundation/Foundation.h>
#if __has_include("../CYLPlaceholderItemViewAnimator.h")
#import "../CYLPlaceholderItemViewAnimator.h"
#else
#import "CYLPlaceholderItemViewAnimator.h"
#endif

#if __has_include(<ImageIO/ImageIO.h>)
#define CYL_PLACEHOLDER_GIF_AVAILABLE 1
#else
#define CYL_PLACEHOLDER_GIF_AVAILABLE 0
#endif

#if CYL_PLACEHOLDER_GIF_AVAILABLE

NS_ASSUME_NONNULL_BEGIN

/*! Registers a `CYLPlaceholderItemViewAnimator` for ".gif" files when linked. */
@interface CYLGIFPlaceholderItemAnimator : NSObject
@property (class, nonatomic, readonly) CYLPlaceholderItemViewAnimator *animator;
@end

NS_ASSUME_NONNULL_END

#endif
