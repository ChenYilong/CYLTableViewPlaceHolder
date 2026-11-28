//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  UIScrollView+Extension.h
//  CYLRefresh
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The direction of the last change of `contentOffset` that `cyl_updateScrollMetrics` sampled.
 * [CN] `cyl_updateScrollMetrics` 采样到的最近一次 `contentOffset` 变化的方向。
 */
typedef NS_ENUM(NSInteger, CYLScrollDirection) {
    /*!
     * [EN] No sample yet, or no vertical change in the last one.
     * [CN] 尚无采样，或最近一次没有纵向变化。
     */
    CYLScrollDirectionNone,
    /*!
     * [EN] `contentOffset.y` decreased (the content moved down, toward its top).
     * [CN] `contentOffset.y` 变小（内容向下移动，朝向顶部）。
     */
    CYLScrollDirectionUp,
    /*!
     * [EN] `contentOffset.y` increased (the content moved up, toward its end).
     * [CN] `contentOffset.y` 变大（内容向上移动，朝向末尾）。
     */
    CYLScrollDirectionDown,
    /*!
     * [EN] `contentOffset.x` decreased, the horizontal change being the larger one.
     * [CN] `contentOffset.x` 变小，且横向变化更大。
     */
    CYLScrollDirectionLeft,
    /*!
     * [EN] `contentOffset.x` increased, the horizontal change being the larger one.
     * [CN] `contentOffset.x` 变大，且横向变化更大。
     */
    CYLScrollDirectionRight,
};

// [EN] Implemented in Swift since 2026-11-19 (`UIScrollView+CYLExtension.swift`, the same selectors; docs/Swift-Migration.md, step 6). This
//      declaration is for Objective-C callers only: Swift reads the Swift extension itself (`__swift__` is defined while
//      Swift imports the header), so the two never meet.
// [CN] 自 2026-11-19 起用 Swift 实现（`UIScrollView+CYLExtension.swift`，选择器不变；docs/Swift-Migration.md 第 6 步）。这里的声明只供 Objective-C
//      调用方使用：Swift 直接读取 Swift 扩展（Swift 导入头文件时定义了 `__swift__`），两者不会冲突。
#ifndef __swift__
/*!
 * [EN] Shorthand accessors for the scroll view's insets, offset and content size, used by the refresh controls.
 * [CN] 刷新控件使用的滚动视图 inset、偏移与内容尺寸的便捷访问方法。
 */
@interface UIScrollView (CYLExtension)
/*!
 * [EN] The effective content inset: `adjustedContentInset` (iOS 11 and later), else `contentInset`.
 * [CN] 实际生效的内容 inset：iOS 11 及以后为 `adjustedContentInset`，否则为 `contentInset`。
 */
@property (readonly, nonatomic) UIEdgeInsets cyl_inset;

/*!
 * [EN] The top of `cyl_inset`; setting it changes `contentInset.top` so that the effective top inset becomes the
 *      value.
 * [CN] `cyl_inset` 的上边距；设置时修改 `contentInset.top`，使实际生效的上边距等于该值。
 */
@property (assign, nonatomic) CGFloat cyl_insetT;
/*!
 * [EN] The bottom of `cyl_inset`; setting it changes `contentInset.bottom` so that the effective bottom inset becomes
 *      the value.
 * [CN] `cyl_inset` 的下边距；设置时修改 `contentInset.bottom`，使实际生效的下边距等于该值。
 */
@property (assign, nonatomic) CGFloat cyl_insetB;
/*!
 * [EN] The left of `cyl_inset`; setting it changes `contentInset.left` so that the effective left inset becomes the
 *      value.
 * [CN] `cyl_inset` 的左边距；设置时修改 `contentInset.left`，使实际生效的左边距等于该值。
 */
@property (assign, nonatomic) CGFloat cyl_insetL;
/*!
 * [EN] The right of `cyl_inset`; setting it changes `contentInset.right` so that the effective right inset becomes
 *      the value.
 * [CN] `cyl_inset` 的右边距；设置时修改 `contentInset.right`，使实际生效的右边距等于该值。
 */
@property (assign, nonatomic) CGFloat cyl_insetR;

/*!
 * [EN] `contentOffset.x`, readable and writable on its own.
 * [CN] `contentOffset.x`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_offsetX;
/*!
 * [EN] `contentOffset.y`, readable and writable on its own.
 * [CN] `contentOffset.y`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_offsetY;

/*!
 * [EN] `contentSize.width`, readable and writable on its own.
 * [CN] `contentSize.width`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_contentW;
/*!
 * [EN] `contentSize.height`, readable and writable on its own.
 * [CN] `contentSize.height`，可单独读写。
 */
@property (assign, nonatomic) CGFloat cyl_contentH;

/*!
 * Call once before scrolling, then once per scroll event, to sample contentOffset.
 * The first sample has zero distance and no direction. Subsequent samples report
 * the signed change along the dominant axis, in points, until the next sample.
 */
- (void)cyl_updateScrollMetrics;
/*!
 * [EN] The signed change of the last `cyl_updateScrollMetrics` sample along its larger axis, in points; 0 before the
 *      second sample.
 * [CN] 最近一次 `cyl_updateScrollMetrics` 采样在变化较大的轴上的有符号变化量（点）；第二次采样前为 0。
 */
@property (readonly, nonatomic) CGFloat cyl_scrollDistance;
/*!
 * [EN] The direction of the last `cyl_updateScrollMetrics` sample; `CYLScrollDirectionNone` before the second sample.
 * [CN] 最近一次 `cyl_updateScrollMetrics` 采样的方向；第二次采样前为 `CYLScrollDirectionNone`。
 */
@property (readonly, nonatomic) CYLScrollDirection cyl_scrollDirection;
@end
#endif

NS_ASSUME_NONNULL_END
