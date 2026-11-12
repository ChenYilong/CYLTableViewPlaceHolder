//
//  CYLRefreshNormalHeader.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshStateHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshNormalHeader : CYLRefreshStateHeader
@property (weak, nonatomic, readonly) UIImageView *arrowView;
/*!
 * [EN] Size of the icon (the arrow); CGSizeZero (default) uses the image's own size
 *      (flutter_easy_refresh's `iconDimension`). [CN] 图标（箭头）的尺寸；CGSizeZero（默认）表示使用图片自身尺寸
 *      （对应 flutter_easy_refresh 的 `iconDimension`）。
 */
@property (assign, nonatomic) CGSize iconSize;
@property (weak, nonatomic, readonly) UIActivityIndicatorView *loadingView;


/*!
 * 菊花的样式
 */
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle CYLRefreshDeprecated("first deprecated in 3.2.2 - Use `loadingView` property");
@end

NS_ASSUME_NONNULL_END
