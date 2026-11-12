//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  UIScrollView+CYLRefresh.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  给ScrollView增加下拉刷新、上拉刷新、 左滑刷新的功能

#import <UIKit/UIKit.h>
#import "CYLRefreshConst.h"

@class CYLRefreshHeader, CYLRefreshFooter, CYLRefreshTrailer;

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (CYLRefresh)
/*!
 * 下拉刷新控件
 */
@property (strong, nonatomic, nullable) CYLRefreshHeader *cyl_header;
/*!
 * 上拉刷新控件
 */
@property (strong, nonatomic, nullable) CYLRefreshFooter *cyl_footer;

/*!
 * 左滑刷新控件
 */
@property (strong, nonatomic, nullable) CYLRefreshTrailer *cyl_trailer;

/*!
 * [EN] `autoHideRefresh` for the header and the footer at once: setting it sets both; reading it is YES when both hide.
 *      A value set before a control is attached is applied when it is attached.
 * [CN] 同时设置刷新头与刷新尾的 `autoHideRefresh`：设置时两者一起设置；读取时两者都会隐藏才为 YES。在控件挂上之前设置的值会在挂上时生效。
 */
@property (assign, nonatomic) BOOL cyl_autoHideRefresh;
/*!
 * [EN] `autoHideRefresh` of the header alone (also applied to a header attached later).
 * [CN] 仅刷新头的 `autoHideRefresh`（之后挂上的刷新头同样生效）。
 */
@property (assign, nonatomic) BOOL cyl_autoHideRefreshHeader;
/*!
 * [EN] `autoHideRefresh` of the footer alone (also applied to a footer attached later).
 * [CN] 仅刷新尾的 `autoHideRefresh`（之后挂上的刷新尾同样生效）。
 */
@property (assign, nonatomic) BOOL cyl_autoHideRefreshFooter;

#pragma mark - other
- (NSInteger)cyl_totalDataCount;

@end

NS_ASSUME_NONNULL_END
