//
//  CYLPlaceholderItemAnimator.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimation/`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLPlaceholderItemAnimationPlayer.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * Lookup order of animators: higher first; equal priorities keep their registration order.
 */
typedef NSInteger CYLPlaceholderItemAnimatorPriority NS_TYPED_EXTENSIBLE_ENUM;
/*!
 * An animator that recognizes its own files (the default).
 */
static const CYLPlaceholderItemAnimatorPriority CYLPlaceholderItemAnimatorPriorityDefault = 0;
/*!
 * Looked up after every other animator (Lottie).
 */
static const CYLPlaceholderItemAnimatorPriority CYLPlaceholderItemAnimatorPriorityFallback = -1000;

/*!
 * Which files an animation library plays, and how it is looked up.
 */
@protocol CYLPlaceholderItemAnimationFileMatching <NSObject>
/*!
 * Unique; registering the same identifier again replaces the animator.
 */
@property (nonatomic, copy, readonly) NSString *identifier;
- (BOOL)canAnimateFileAtURL:(NSURL *)URL;
@optional
@property (nonatomic, readonly) CYLPlaceholderItemAnimatorPriority priority;
/*!
 * Lowercase extensions without a dot.
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> *fileExtensions;
/*!
 * Generic `CYLTabBarAnimation…` key -> this library's key (e.g. `CYLTabBarLottieURL`).
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *attributeKeys;
@end

/*!
 * The views an animation library makes, and a player for each.
 */
@protocol CYLPlaceholderItemAnimationViewFactory <NSObject>
/*!
 * Returns nil when the file cannot be loaded. The URL fragment may carry options (`#artboard=Main&duration=1`).
 */
- (nullable UIView *)animationViewWithURL:(NSURL *)URL size:(CGSize)size contentMode:(UIViewContentMode)contentMode;
/*!
 * Returns nil for a view this library did not make.
 */
- (nullable id<CYLPlaceholderItemAnimationPlayer>)playerForAnimationView:(UIView *)view;
@end

/*!
 * An animation library. Register it with `CYLPlaceholderItemAnimatorRegistry`, typically in `+load`.
 */
@protocol CYLPlaceholderItemAnimator <CYLPlaceholderItemAnimationFileMatching, CYLPlaceholderItemAnimationViewFactory>
@end

NS_ASSUME_NONNULL_END
