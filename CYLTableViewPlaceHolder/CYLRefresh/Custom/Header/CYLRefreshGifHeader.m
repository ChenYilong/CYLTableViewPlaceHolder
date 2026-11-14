//
//  CYLRefreshGifHeader.m
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshGifHeader.h"

@implementation CYLRefreshGifHeader

// [EN] The MJRefresh names call the general methods of CYLRefreshAnimationHeader, so old code keeps working.
// [CN] MJRefresh 的方法名调用 CYLRefreshAnimationHeader 的通用方法，旧代码照常工作。

- (UIImageView *)gifView
{
    return self.animationView;
}

- (instancetype)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(CYLRefreshState)state
{
    return [self setAnimationImages:images duration:duration forState:state];
}

- (instancetype)setImages:(NSArray *)images forState:(CYLRefreshState)state
{
    return [self setAnimationImages:images forState:state];
}

@end
