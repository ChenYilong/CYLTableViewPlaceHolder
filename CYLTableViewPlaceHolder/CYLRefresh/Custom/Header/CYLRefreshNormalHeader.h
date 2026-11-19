//
//  CYLRefreshNormalHeader.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshStateHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The standard header: the state and last-updated texts with an arrow that turns when releasing will refresh,
 *      and a spinner while refreshing.
 * [CN] 标准刷新头：状态文字与最后更新时间，带有松手即刷新时会转向的箭头，刷新时显示菊花。
 */
@interface CYLRefreshNormalHeader : CYLRefreshStateHeader
/*!
 * [EN] The arrow beside the texts (the bundle's `CYLRefreshArrow` image, template-rendered so it takes the tint
 *      color), created on first access.
 * [CN] 文字旁边的箭头（bundle 中的 `CYLRefreshArrow` 图片，按模板渲染从而使用 tintColor），首次访问时创建。
 */
@property (weak, nonatomic, readonly) UIImageView *arrowView;
/*!
 * [EN] Size of the icon (the arrow); CGSizeZero (default) uses the image's own size
 *      (flutter_easy_refresh's `iconDimension`). [CN] 图标（箭头）的尺寸；CGSizeZero（默认）表示使用图片自身尺寸
 *      （对应 flutter_easy_refresh 的 `iconDimension`）。
 */
@property (assign, nonatomic) CGSize iconSize;
/*!
 * [EN] The spinner shown while refreshing, created on first access and hidden when stopped; style it here.
 * [CN] 刷新时显示的菊花，首次访问时创建，停止时隐藏；可在此设置样式。
 */
@property (weak, nonatomic, readonly) UIActivityIndicatorView *loadingView;


/*!
 * 菊花的样式
 */
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle CYLRefreshDeprecated("first deprecated in 3.2.2 - Use `loadingView` property");
@end

NS_ASSUME_NONNULL_END
