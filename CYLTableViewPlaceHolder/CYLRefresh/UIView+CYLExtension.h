// 代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  UIView+Extension.h
//  CYLRefresh
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CYLExtension)
@property (assign, nonatomic) CGFloat cyl_x;
@property (assign, nonatomic) CGFloat cyl_y;
@property (assign, nonatomic) CGFloat cyl_w;
@property (assign, nonatomic) CGFloat cyl_h;
@property (assign, nonatomic) CGSize cyl_size;
@property (assign, nonatomic) CGPoint cyl_origin;
@end

NS_ASSUME_NONNULL_END
