//
//  CYLPlaceholderItemAnimationPlayer.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimation/`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * Plays one animation view. Mirrors `CYLTabBarItemAnimationPlayer`.
 * Call on the main thread.
 */
@protocol CYLPlaceholderItemAnimationPlayer <NSObject>
@property (nonatomic, weak, readonly, nullable) UIView *animationView;
/// Plays once from the first frame.
- (void)play;
/// Stops and shows the last frame (state-machine engines show their resting state).
- (void)showLastFrame;
/// Stops and shows the first frame.
- (void)stop;
@optional
/// 0...1. Players without seeking do not implement it.
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat animationSpeed;
/// How many times `-play` plays the animation: 0 loops until stopped, 1 plays once. NO when unsupported.
- (BOOL)setAnimationRepeatCount:(NSInteger)repeatCount;
/// Applies dark-only colors in Dark Mode and restores them in Light Mode.
- (void)applyDarkColors:(NSDictionary<NSString *, UIColor *> *)darkColors traitCollection:(UITraitCollection *)traitCollection;
/// Replaces every color override; nil or empty restores the animation's own colors.
- (void)applyColors:(nullable NSDictionary<NSString *, UIColor *> *)colors traitCollection:(UITraitCollection *)traitCollection;
@end

/// Holds the animation view weakly; players subclass it.
@interface CYLPlaceholderItemAnimationBasePlayer : NSObject
- (instancetype)initWithAnimationView:(UIView *)animationView NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic, weak, readonly, nullable) UIView *animationView;
@end

NS_ASSUME_NONNULL_END
