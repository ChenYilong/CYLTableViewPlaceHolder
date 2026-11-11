//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  UIScrollView+Extension.h
//  CYLRefresh
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLScrollDirection) {
    CYLScrollDirectionNone,
    CYLScrollDirectionUp,
    CYLScrollDirectionDown,
    CYLScrollDirectionLeft,
    CYLScrollDirectionRight,
};

@interface UIScrollView (CYLExtension)
@property (readonly, nonatomic) UIEdgeInsets cyl_inset;

@property (assign, nonatomic) CGFloat cyl_insetT;
@property (assign, nonatomic) CGFloat cyl_insetB;
@property (assign, nonatomic) CGFloat cyl_insetL;
@property (assign, nonatomic) CGFloat cyl_insetR;

@property (assign, nonatomic) CGFloat cyl_offsetX;
@property (assign, nonatomic) CGFloat cyl_offsetY;

@property (assign, nonatomic) CGFloat cyl_contentW;
@property (assign, nonatomic) CGFloat cyl_contentH;

/*! Call once before scrolling, then once per scroll event, to sample contentOffset.
 The first sample has zero distance and no direction. Subsequent samples report
 the signed change along the dominant axis, in points, until the next sample. */
- (void)cyl_updateScrollMetrics;
@property (readonly, nonatomic) CGFloat cyl_scrollDistance;
@property (readonly, nonatomic) CYLScrollDirection cyl_scrollDirection;
@end

NS_ASSUME_NONNULL_END
