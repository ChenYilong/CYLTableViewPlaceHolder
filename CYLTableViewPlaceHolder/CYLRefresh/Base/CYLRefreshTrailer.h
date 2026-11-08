//
//  CYLRefreshTrailer.h
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "CYLRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshTrailer : CYLRefreshComponent

/** 创建trailer*/
+ (instancetype)trailerWithRefreshingBlock:(CYLRefreshComponentAction)refreshingBlock;
/** 创建trailer */
+ (instancetype)trailerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

/** 忽略多少scrollView的contentInset的right */
@property (assign, nonatomic) CGFloat ignoredScrollViewContentInsetRight;


@end

NS_ASSUME_NONNULL_END
