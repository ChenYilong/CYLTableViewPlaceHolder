// 代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  UIView+Extension.h
//  CYLRefresh
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] Shorthand accessors for the parts of a view's frame, used by the refresh controls.
 * [CN] 刷新控件使用的视图 frame 各部分的便捷访问方法。
 */
@interface UIView (CYLExtension)
/*!
 * [EN] `frame.origin.x`, readable and writable on its own.
 * [CN] `frame.origin.x`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_x;
/*!
 * [EN] `frame.origin.y`, readable and writable on its own.
 * [CN] `frame.origin.y`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_y;
/*!
 * [EN] `frame.size.width`, readable and writable on its own.
 * [CN] `frame.size.width`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_w;
/*!
 * [EN] `frame.size.height`, readable and writable on its own.
 * [CN] `frame.size.height`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_h;
/*!
 * [EN] `frame.size`, readable and writable on its own.
 * [CN] `frame.size`，可单独读写。
 */
@property (assign, nonatomic) CGSize cyl_size;
/*!
 * [EN] `frame.origin`, readable and writable on its own.
 * [CN] `frame.origin`，可单独读写。
 */
@property (assign, nonatomic) CGPoint cyl_origin;
@end

NS_ASSUME_NONNULL_END
