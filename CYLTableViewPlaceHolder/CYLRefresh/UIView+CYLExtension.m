//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  UIView+Extension.m
//  CYLRefresh
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "UIView+CYLExtension.h"

@implementation UIView (CYLExtension)
- (void)setCyl_x:(CGFloat)cyl_x
{
    CGRect frame = self.frame;
    frame.origin.x = cyl_x;
    self.frame = frame;
}

- (CGFloat)cyl_x
{
    return self.frame.origin.x;
}

- (void)setCyl_y:(CGFloat)cyl_y
{
    CGRect frame = self.frame;
    frame.origin.y = cyl_y;
    self.frame = frame;
}

- (CGFloat)cyl_y
{
    return self.frame.origin.y;
}

- (void)setCyl_w:(CGFloat)cyl_w
{
    CGRect frame = self.frame;
    frame.size.width = cyl_w;
    self.frame = frame;
}

- (CGFloat)cyl_w
{
    return self.frame.size.width;
}

- (void)setCyl_h:(CGFloat)cyl_h
{
    CGRect frame = self.frame;
    frame.size.height = cyl_h;
    self.frame = frame;
}

- (CGFloat)cyl_h
{
    return self.frame.size.height;
}

- (void)setCyl_size:(CGSize)cyl_size
{
    CGRect frame = self.frame;
    frame.size = cyl_size;
    self.frame = frame;
}

- (CGSize)cyl_size
{
    return self.frame.size;
}

- (void)setCyl_origin:(CGPoint)cyl_origin
{
    CGRect frame = self.frame;
    frame.origin = cyl_origin;
    self.frame = frame;
}

- (CGPoint)cyl_origin
{
    return self.frame.origin;
}
@end
