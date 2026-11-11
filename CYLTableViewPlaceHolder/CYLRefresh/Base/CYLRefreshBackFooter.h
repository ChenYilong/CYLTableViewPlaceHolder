//
//  CYLRefreshBackFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshFooter.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshBackFooter : CYLRefreshFooter

/*!
 * Seconds the "no more data" text stays visible, with the footer held open, after a load that ends with
 * `endRefreshingWithNoMoreData`, before the scroll view rebounds (upstream #1585, case 2). Default 0: rebound at once, as
 * before. Starting another load, `resetNoMoreData` or removing the footer ends the hold at once. It does not apply when the
 * state is set without a load in progress, so the case "already no-more-data on entry; show the text for N seconds after a
 * pull-up" is not covered.
 */
@property (nonatomic) NSTimeInterval noMoreDataDisplayDuration;

@end

NS_ASSUME_NONNULL_END
