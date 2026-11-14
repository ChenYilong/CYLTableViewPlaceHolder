//
//  CYLRefreshBackAnimationFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24 (as MJRefresh's MJRefreshBackGifFooter; renamed and generalized for CYLRefresh).
//  Copyright (c) 2015年 小码哥. All rights reserved.
//
//  [EN] The animated-image control of the MJRefresh documentation under a general name: per-state image sequences
//       (`setAnimationImages:forState:`), or an icon animation (GIF, Lottie, PAG or Rive) through
//       `CYLRefreshIconAnimating`. `CYLRefreshBackGifFooter` is kept as a subclass whose `gifView` and `setImages:…` call these methods.
//  [CN] MJRefresh 文档中“动画图片”控件的通用命名：按状态设置图片序列（`setAnimationImages:forState:`），或通过
//       `CYLRefreshIconAnimating` 设置图标动画（GIF、Lottie、PAG、Rive）。`CYLRefreshBackGifFooter` 作为子类保留，其 `gifView` 与 `setImages:…` 调用这里的方法。
//

#import "CYLRefreshBackStateFooter.h"
#import "CYLRefreshIconView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Animated images (`setAnimationImages:forState:`), or an icon animation (GIF, Lottie, PAG or Rive) through
 *      `CYLRefreshIconAnimating`, which takes the animation view's place with the same layout.
 * [CN] 动画图片（`setAnimationImages:forState:`），或通过 `CYLRefreshIconAnimating` 设置的图标动画（GIF、Lottie、PAG、Rive），后者以相同布局替换动画视图。
 */
@interface CYLRefreshBackAnimationFooter : CYLRefreshBackStateFooter <CYLRefreshIconAnimating>

/*!
 * [EN] The image view that plays the per-state images. [CN] 播放各状态动画图片的图片视图。
 */
@property (weak, nonatomic, readonly) UIImageView *animationView;

/*!
 * [EN] Sets the images of `state`, played in `duration` seconds; a single image is shown still. The control grows to
 *      the first image's height. [CN] 设置 `state` 状态的动画图片，在 `duration` 秒内播放一遍；只有一张时静止显示。控件高度随第一张图片增大。
 */
- (instancetype)setAnimationImages:(NSArray<UIImage *> *)images duration:(NSTimeInterval)duration forState:(CYLRefreshState)state;

/*!
 * [EN] The same, 0.1 seconds per image. [CN] 同上，每张图片 0.1 秒。
 */
- (instancetype)setAnimationImages:(NSArray<UIImage *> *)images forState:(CYLRefreshState)state;

@end

NS_ASSUME_NONNULL_END
