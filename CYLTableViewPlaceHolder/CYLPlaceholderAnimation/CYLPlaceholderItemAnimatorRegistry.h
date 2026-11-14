//
//  CYLPlaceholderItemAnimatorRegistry.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimation/`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYLPlaceholderItemAnimator.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * The registry interface, so a factory can be given another registry (tests).
 */
@protocol CYLPlaceholderItemAnimatorRegistering <NSObject>
- (void)registerAnimator:(id<CYLPlaceholderItemAnimator>)animator;
- (void)unregisterAnimatorWithIdentifier:(NSString *)identifier;
/*!
 * Sorted by priority, then registration order.
 */
- (NSArray<id<CYLPlaceholderItemAnimator>> *)animators;
- (nullable id<CYLPlaceholderItemAnimator>)animatorWithIdentifier:(NSString *)identifier;
/*!
 * A bound animator first, then the first animator that can animate the URL.
 */
- (nullable id<CYLPlaceholderItemAnimator>)animatorForURL:(nullable NSURL *)URL;
/*!
 * The first animator whose library-specific keys have a value.
 */
- (nullable id<CYLPlaceholderItemAnimator>)animatorForAttributes:(nullable NSDictionary *)attributes;
- (nullable NSString *)attributeKeyForGenericKey:(NSString *)genericKey inAttributes:(nullable NSDictionary *)attributes;
/*!
 * Plays URL with animator whatever its extension; nil removes the binding.
 */
- (void)bindURL:(NSURL *)URL toAnimator:(nullable id<CYLPlaceholderItemAnimator>)animator;
- (NSArray<NSString *> *)attributeKeysForGenericKey:(NSString *)genericKey;
- (NSArray<NSString *> *)fileExtensions;
@end

/*!
 * Thread-safe. Class methods use the shared registry.
 */
@interface CYLPlaceholderItemAnimatorRegistry : NSObject <CYLPlaceholderItemAnimatorRegistering>
+ (instancetype)sharedRegistry;
+ (void)registerAnimator:(id<CYLPlaceholderItemAnimator>)animator;
+ (void)unregisterAnimatorWithIdentifier:(NSString *)identifier;
+ (NSArray<id<CYLPlaceholderItemAnimator>> *)animators;
+ (nullable id<CYLPlaceholderItemAnimator>)animatorWithIdentifier:(NSString *)identifier;
+ (nullable id<CYLPlaceholderItemAnimator>)animatorForURL:(nullable NSURL *)URL;
+ (nullable id<CYLPlaceholderItemAnimator>)animatorForAttributes:(nullable NSDictionary *)attributes;
+ (nullable NSString *)attributeKeyForGenericKey:(NSString *)genericKey inAttributes:(nullable NSDictionary *)attributes;
+ (void)bindURL:(NSURL *)URL toAnimator:(nullable id<CYLPlaceholderItemAnimator>)animator;
+ (NSArray<NSString *> *)attributeKeysForGenericKey:(NSString *)genericKey;
+ (NSArray<NSString *> *)fileExtensions;
@end

NS_ASSUME_NONNULL_END
