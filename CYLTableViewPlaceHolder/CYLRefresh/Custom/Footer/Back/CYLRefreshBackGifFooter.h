//
//  CYLRefreshBackGifFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshBackStateFooter.h"
#import "CYLRefreshIconView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Animated images (`setImages:forState:`), or an icon animation (GIF, Lottie, PAG or Rive) through
 *      `CYLRefreshIconAnimating`, which takes the GIF view's place with the same layout.
 * [CN] 动画图片（`setImages:forState:`），或通过 `CYLRefreshIconAnimating` 设置的图标动画（GIF、Lottie、PAG、Rive），后者以相同布局替换 GIF 视图。
 */
@interface CYLRefreshBackGifFooter : CYLRefreshBackStateFooter <CYLRefreshIconAnimating>
@property (weak, nonatomic, readonly) UIImageView *gifView;

/*!
 * 设置state状态下的动画图片images 动画持续时间duration
 */
- (instancetype)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(CYLRefreshState)state;
- (instancetype)setImages:(NSArray *)images forState:(CYLRefreshState)state;
@end

NS_ASSUME_NONNULL_END
