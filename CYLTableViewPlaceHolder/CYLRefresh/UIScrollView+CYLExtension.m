//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  UIScrollView+Extension.m
//  CYLRefresh
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import "UIScrollView+CYLExtension.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"

@interface CYLScrollMetrics : NSObject
@property (nonatomic) CGPoint previousOffset;
@property (nonatomic) CGFloat distance;
@property (nonatomic) CYLScrollDirection direction;
@end

@implementation CYLScrollMetrics
@end

@implementation UIScrollView (CYLExtension)

static BOOL respondsToAdjustedContentInset_;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        respondsToAdjustedContentInset_ = [self instancesRespondToSelector:@selector(adjustedContentInset)];
    });
}

- (UIEdgeInsets)cyl_inset
{
#ifdef __IPHONE_11_0
    if (respondsToAdjustedContentInset_) {
        return self.adjustedContentInset;
    }
#endif
    return self.contentInset;
}

- (void)setCyl_insetT:(CGFloat)cyl_insetT
{
    UIEdgeInsets inset = self.contentInset;
    inset.top = cyl_insetT;
#ifdef __IPHONE_11_0
    if (respondsToAdjustedContentInset_) {
        inset.top -= (self.adjustedContentInset.top - self.contentInset.top);
    }
#endif
    self.contentInset = inset;
}

- (CGFloat)cyl_insetT
{
    return self.cyl_inset.top;
}

- (void)setCyl_insetB:(CGFloat)cyl_insetB
{
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = cyl_insetB;
#ifdef __IPHONE_11_0
    if (respondsToAdjustedContentInset_) {
        inset.bottom -= (self.adjustedContentInset.bottom - self.contentInset.bottom);
    }
#endif
    self.contentInset = inset;
}

- (CGFloat)cyl_insetB
{
    return self.cyl_inset.bottom;
}

- (void)setCyl_insetL:(CGFloat)cyl_insetL
{
    UIEdgeInsets inset = self.contentInset;
    inset.left = cyl_insetL;
#ifdef __IPHONE_11_0
    if (respondsToAdjustedContentInset_) {
        inset.left -= (self.adjustedContentInset.left - self.contentInset.left);
    }
#endif
    self.contentInset = inset;
}

- (CGFloat)cyl_insetL
{
    return self.cyl_inset.left;
}

- (void)setCyl_insetR:(CGFloat)cyl_insetR
{
    UIEdgeInsets inset = self.contentInset;
    inset.right = cyl_insetR;
#ifdef __IPHONE_11_0
    if (respondsToAdjustedContentInset_) {
        inset.right -= (self.adjustedContentInset.right - self.contentInset.right);
    }
#endif
    self.contentInset = inset;
}

- (CGFloat)cyl_insetR
{
    return self.cyl_inset.right;
}

- (void)setCyl_offsetX:(CGFloat)cyl_offsetX
{
    CGPoint offset = self.contentOffset;
    offset.x = cyl_offsetX;
    self.contentOffset = offset;
}

- (CGFloat)cyl_offsetX
{
    return self.contentOffset.x;
}

- (void)setCyl_offsetY:(CGFloat)cyl_offsetY
{
    CGPoint offset = self.contentOffset;
    offset.y = cyl_offsetY;
    self.contentOffset = offset;
}

- (CGFloat)cyl_offsetY
{
    return self.contentOffset.y;
}

- (void)setCyl_contentW:(CGFloat)cyl_contentW
{
    CGSize size = self.contentSize;
    size.width = cyl_contentW;
    self.contentSize = size;
}

- (CGFloat)cyl_contentW
{
    return self.contentSize.width;
}

- (void)setCyl_contentH:(CGFloat)cyl_contentH
{
    CGSize size = self.contentSize;
    size.height = cyl_contentH;
    self.contentSize = size;
}

- (CGFloat)cyl_contentH
{
    return self.contentSize.height;
}

- (void)cyl_updateScrollMetrics
{
    CYLScrollMetrics *metrics = objc_getAssociatedObject(self, @selector(cyl_updateScrollMetrics));
    CGPoint offset = self.contentOffset;
    if (!metrics) {
        metrics = [CYLScrollMetrics new];
        objc_setAssociatedObject(self, @selector(cyl_updateScrollMetrics), metrics, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        CGFloat dx = offset.x - metrics.previousOffset.x;
        CGFloat dy = offset.y - metrics.previousOffset.y;
        if (fabs(dy) >= fabs(dx)) {
            metrics.distance = dy;
            metrics.direction = dy > 0 ? CYLScrollDirectionDown : (dy < 0 ? CYLScrollDirectionUp : CYLScrollDirectionNone);
        } else {
            metrics.distance = dx;
            metrics.direction = dx > 0 ? CYLScrollDirectionRight : CYLScrollDirectionLeft;
        }
    }
    metrics.previousOffset = offset;
}

- (CGFloat)cyl_scrollDistance
{
    CYLScrollMetrics *metrics = objc_getAssociatedObject(self, @selector(cyl_updateScrollMetrics));
    return metrics.distance;
}

- (CYLScrollDirection)cyl_scrollDirection
{
    CYLScrollMetrics *metrics = objc_getAssociatedObject(self, @selector(cyl_updateScrollMetrics));
    return metrics.direction;
}
@end
#pragma clang diagnostic pop
