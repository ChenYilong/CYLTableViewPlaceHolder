//
//  CYLPAGPlaceholderItemAnimator.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLPAGTabBarItemAnimator`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//
//  PAG animations (Tencent libpag): `pod 'CYLTableViewPlaceHolder/PAG'` or
//  `pod 'CYLTableViewPlaceHolder/PAGEnterprise'` (choose one).
//

#import <Foundation/Foundation.h>
#if __has_include("../CYLPlaceholderItemAnimator.h")
#import "../CYLPlaceholderItemAnimator.h"
#else
#import "CYLPlaceholderItemAnimator.h"
#endif

#if __has_include(<libpag/PAGView.h>)
#define CYL_PLACEHOLDER_PAG_AVAILABLE 1
#else
#define CYL_PLACEHOLDER_PAG_AVAILABLE 0
#endif

#if CYL_PLACEHOLDER_PAG_AVAILABLE

NS_ASSUME_NONNULL_BEGIN

/*! Registers itself for ".pag" files when linked. */
@interface CYLPAGPlaceholderItemAnimator : NSObject <CYLPlaceholderItemAnimator>
@end

NS_ASSUME_NONNULL_END

#endif
