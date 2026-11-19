//
//  CYLRefreshBackNormalFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshBackStateFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The standard back footer: the state text with an arrow that turns when releasing will load, and a spinner
 *      while loading.
 * [CN] 标准回弹刷新尾：状态文字，带有松手即加载时会转向的箭头，加载时显示菊花。
 */
@interface CYLRefreshBackNormalFooter : CYLRefreshBackStateFooter
/*!
 * [EN] The arrow beside the text (the bundle's `CYLRefreshArrow` image, template-rendered so it takes the tint
 *      color), created on first access.
 * [CN] 文字旁边的箭头（bundle 中的 `CYLRefreshArrow` 图片，按模板渲染从而使用 tintColor），首次访问时创建。
 */
@property (weak, nonatomic, readonly) UIImageView *arrowView;
/*!
 * [EN] The spinner shown while loading, created on first access and hidden when stopped; style it here.
 * [CN] 加载时显示的菊花，首次访问时创建，停止时隐藏；可在此设置样式。
 */
@property (weak, nonatomic, readonly) UIActivityIndicatorView *loadingView;
/*!
 * [EN] Shown beside the text while there is no more data (flutter_easy_refresh's `ClassicFooter.noMoreIcon`).
 * [CN] 没有更多数据时显示在文字旁边（对应 flutter_easy_refresh 的 `ClassicFooter.noMoreIcon`）。
 */
@property (strong, nonatomic, nullable) UIImage *noMoreDataImage;
/*!
 * [EN] Size of the icon (the arrow and noMoreDataImage); CGSizeZero (default) uses the image's own size
 *      (flutter_easy_refresh's `iconDimension`). [CN] 图标（箭头与 noMoreDataImage）的尺寸；CGSizeZero（默认）表示使用图片自身尺寸
 *      （对应 flutter_easy_refresh 的 `iconDimension`）。
 */
@property (assign, nonatomic) CGSize iconSize;

/*!
 * 菊花的样式
 */
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle CYLRefreshDeprecated("first deprecated in 3.2.2 - Use `loadingView` property");
@end

NS_ASSUME_NONNULL_END
