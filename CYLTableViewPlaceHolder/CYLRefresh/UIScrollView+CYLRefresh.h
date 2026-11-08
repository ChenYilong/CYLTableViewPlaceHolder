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
/** 下拉刷新控件 */
@property (strong, nonatomic, nullable) CYLRefreshHeader *cyl_header;
/** 上拉刷新控件 */
@property (strong, nonatomic, nullable) CYLRefreshFooter *cyl_footer;

/** 左滑刷新控件 */
@property (strong, nonatomic, nullable) CYLRefreshTrailer *cyl_trailer;

#pragma mark - other
- (NSInteger)cyl_totalDataCount;

@end

NS_ASSUME_NONNULL_END
