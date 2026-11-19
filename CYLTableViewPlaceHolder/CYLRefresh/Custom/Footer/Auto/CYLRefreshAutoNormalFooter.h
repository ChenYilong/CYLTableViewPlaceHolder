//
//  CYLRefreshAutoNormalFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshAutoStateFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The standard automatic footer: the state text with a spinner while loading.
 * [CN] 标准自动刷新尾：状态文字，加载时显示菊花。
 */
@interface CYLRefreshAutoNormalFooter : CYLRefreshAutoStateFooter
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
 * 菊花的样式
 */
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle CYLRefreshDeprecated("first deprecated in 3.2.2 - Use `loadingView` property");
@end


NS_ASSUME_NONNULL_END
