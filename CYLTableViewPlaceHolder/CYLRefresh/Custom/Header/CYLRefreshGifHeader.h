//
//  CYLRefreshGifHeader.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshAnimationHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The MJRefresh name of `CYLRefreshAnimationHeader`, kept for compatibility: `gifView` and `setImages:…` call the general
 *      methods. New code can use `CYLRefreshAnimationHeader`. [CN] `CYLRefreshAnimationHeader` 在 MJRefresh 中的名字，为兼容保留：`gifView` 与
 *      `setImages:…` 调用通用方法。新代码可以使用 `CYLRefreshAnimationHeader`。
 */
@interface CYLRefreshGifHeader : CYLRefreshAnimationHeader

/*!
 * [EN] The same view as `animationView`. [CN] 与 `animationView` 是同一个视图。
 */
@property (weak, nonatomic, readonly) UIImageView *gifView;

/*!
 * [EN] Calls `-setAnimationImages:duration:forState:`. [CN] 调用 `-setAnimationImages:duration:forState:`。
 */
- (instancetype)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(CYLRefreshState)state;

/*!
 * [EN] Calls `-setAnimationImages:forState:`. [CN] 调用 `-setAnimationImages:forState:`。
 */
- (instancetype)setImages:(NSArray *)images forState:(CYLRefreshState)state;
@end

NS_ASSUME_NONNULL_END
