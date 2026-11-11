//
//  CYLPlaceholderItemAnimationPlayableView.h
//  CYLTableViewPlaceHolder
//
//  Adapted from CYLTabBarController (`CYLTabBarItemAnimation/`, branch
//  feat/cross-platform-components), MIT License,
//  Copyright © 2026 https://github.com/ChenYilong . All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*! [EN] Main actor in Swift: views are used on the main thread. [CN] 在 Swift 中属于主 actor：视图只在主线程使用。 */
#ifndef NS_SWIFT_UI_ACTOR
#define NS_SWIFT_UI_ACTOR
#endif

/*!
 * [EN] The short path for adding an animation library: a view that plays itself. A library whose view can play, stop
 *      and show its last frame adopts this protocol and `CYLPlaceholderItemAnimationViewProviding`, and registers a
 *      `CYLPlaceholderItemViewAnimator`; it needs no animator or player class of its own (Rive does this). A library whose
 *      own view cannot adopt the protocol writes an animator and a player instead (`CYLPlaceholderItemAnimator`, as PAG and
 *      Lottie do). The methods keep a `cyl_` prefix in Objective-C and get camelCase names in Swift.
 * [CN] 新增动画库的简便方式：自己会播放的视图。如果动画库的视图能够播放、停止并显示最后一帧，只需遵守本协议与
 *      `CYLPlaceholderItemAnimationViewProviding`，并注册一个 `CYLPlaceholderItemViewAnimator`，不需要编写自己的 animator 或播放器类（Rive 即是如此）。
 *      视图无法遵守本协议的动画库，则编写 animator 与播放器（`CYLPlaceholderItemAnimator`，PAG 与 Lottie 即是如此）。方法在 Objective-C 中保留
 *      `cyl_` 前缀，在 Swift 中使用驼峰命名。
 */
NS_SWIFT_UI_ACTOR
@protocol CYLPlaceholderItemAnimationPlayableView <NSObject>

/*! [EN] Plays once, from the start. [CN] 从头播放一次。 */
- (void)cyl_playAnimationView NS_SWIFT_NAME(playAnimation());

/*! [EN] Shows the end state without playing (the tab selected at launch, #389). [CN] 不播放，直接显示结束状态（启动时选中的 Tab，#389）。 */
- (void)cyl_showAnimationViewLastFrame NS_SWIFT_NAME(showAnimationLastFrame());

/*! [EN] Stops, back to the start. [CN] 停止并回到起始状态。 */
- (void)cyl_stopAnimationView NS_SWIFT_NAME(stopAnimation());

@optional

/*!
 * [EN] Colors for Dark Mode (`CYLTabBarAnimationDarkColors`, already resolved for the trait collection): a library path
 *      -> color; nil restores the light colors. Called only when the state changes.
 * [CN] 深色模式的颜色（`CYLTabBarAnimationDarkColors`，已按 trait collection 解析）：动画库中的路径 -> 颜色；nil 恢复浅色颜色。仅在状态变化时调用。
 */
- (void)cyl_applyAnimationViewColors:(nullable NSDictionary<NSString *, UIColor *> *)colors NS_SWIFT_NAME(applyAnimationColors(_:));

/*! Placeholder addition: NO while an asynchronous load (Rive) is in progress. Views without it are ready at once. */
/*!
 * [EN] How many times `cyl_playAnimationView` plays: 0 loops until stopped, 1 plays once. NO when unsupported.
 * [CN] `cyl_playAnimationView` 播放的次数：0 表示循环直到停止，1 表示播放一次。不支持时返回 NO。
 */
- (BOOL)cyl_setAnimationViewRepeatCount:(NSInteger)repeatCount NS_SWIFT_NAME(setAnimationRepeatCount(_:));

@property (nonatomic, readonly) BOOL cyl_isAnimationViewReady NS_SWIFT_NAME(isAnimationReady);
/*! Placeholder addition: called on the main thread when an asynchronous load finishes. */
@property (nonatomic, copy, nullable) void (^cyl_animationViewReadyHandler)(void) NS_SWIFT_NAME(animationReadyHandler);
/*! Placeholder addition: called on the main thread when an asynchronous load fails, so the host can fall back. */
@property (nonatomic, copy, nullable) void (^cyl_animationViewErrorHandler)(NSError *error) NS_SWIFT_NAME(animationErrorHandler);

@end

/*!
 * [EN] The abstract factory of playable views, used by `CYLPlaceholderItemViewAnimator`.
 * [CN] 可播放视图的抽象工厂，由 `CYLPlaceholderItemViewAnimator` 使用。
 */
NS_SWIFT_UI_ACTOR
@protocol CYLPlaceholderItemAnimationViewProviding <NSObject>

/*!
 * [EN] A view for the animation file `fileURL`, with the `options` of the tab's URL (`CYLTabBarAnimationURLWithOptions()`),
 *      scaled like `contentMode`; nil when it cannot be made. The animator sets its frame.
 * [CN] 为动画文件 `fileURL` 创建的视图，带有 Tab URL 中的 `options`（`CYLTabBarAnimationURLWithOptions()`），按 `contentMode` 缩放；无法创建时返回
 *      nil。由 animator 设置其 frame。
 */
+ (nullable UIView<CYLPlaceholderItemAnimationPlayableView> *)cyl_animationViewWithFileURL:(NSURL *)fileURL
                                                                             options:(NSDictionary<NSString *, NSString *> *)options
                                                                         contentMode:(UIViewContentMode)contentMode
    NS_SWIFT_NAME(makeAnimationView(fileURL:options:contentMode:));

@end

NS_ASSUME_NONNULL_END
