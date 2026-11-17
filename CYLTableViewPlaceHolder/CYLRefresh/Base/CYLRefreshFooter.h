//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/5.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  上拉刷新控件

#import "CYLRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshFooter : CYLRefreshComponent
/*!
 * 创建footer
 */
+ (instancetype)footerWithRefreshingBlock:(CYLRefreshComponentAction)refreshingBlock;
/*!
 * 创建footer
 */
+ (instancetype)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

/*!
 * 提示没有更多的数据
 */
- (void)endRefreshingWithNoMoreData;
- (void)noticeNoMoreData CYLRefreshDeprecated("使用endRefreshingWithNoMoreData");

/*!
 * 重置没有更多的数据（消除没有更多数据的状态）
 */
- (void)resetNoMoreData;
/*!
 * [EN] YES while the footer shows that all data is loaded (`CYLRefreshStateNoMoreData`).
 * [CN] 加载尾显示已全部加载（`CYLRefreshStateNoMoreData`）时为 YES。
 */
@property (nonatomic, readonly, getter=isNoMoreData) BOOL noMoreData;
/*!
 * [EN] Pulling past the end loads again after "no more data": the footer resets and refreshes
 *      (flutter_easy_refresh's `canLoadAfterNoMore`). Default NO.
 * [CN] “无更多数据”后拉过底部仍会再次加载：加载尾重置并开始刷新（对应 flutter_easy_refresh 的 `canLoadAfterNoMore`）。默认 NO。
 */
@property (nonatomic) BOOL loadsAfterNoMoreData;

/*!
 * 忽略多少scrollView的contentInset的bottom
 */
@property (assign, nonatomic) CGFloat ignoredScrollViewContentInsetBottom;

/*!
 * 自动根据有无数据来显示和隐藏（有数据就显示，没有数据隐藏。默认是NO）
 */
@property (assign, nonatomic, getter=isAutomaticallyHidden) BOOL automaticallyHidden CYLRefreshDeprecated("已废弃此属性，开发者请自行控制footer的显示和隐藏");
@end

/*!
 * [EN] The image shown beside the text in the no-more-data state, kept once for both normal footers
 *      (`CYLRefreshAutoNormalFooter` / `CYLRefreshBackNormalFooter`, whose `noMoreDataImage` uses it).
 * [CN] 无更多数据状态时显示在文字旁的图片，为两种 Normal 尾部统一实现（`CYLRefreshAutoNormalFooter` / `CYLRefreshBackNormalFooter` 的
 *      `noMoreDataImage` 使用它）。
 */
@interface CYLRefreshFooter (CYLRefreshNoMoreDataImage)
/*!
 * [EN] Shows `image` only in the no-more-data state (nil hides it); call when the image or the state changes.
 * [CN] 仅在无更多数据状态时显示 `image`（nil 表示隐藏）；图片或状态变化时调用。
 */
- (void)cyl_updateNoMoreDataImage:(nullable UIImage *)image NS_SWIFT_NAME(cyl_updateNoMoreDataImage(_:));
/*!
 * [EN] Places the image left of `label`'s text (`inset` apart), at `size` or, when zero, the image's own size; call
 *      from `placeSubviews`. [CN] 把图片放在 `label` 文字左侧（间距 `inset`），尺寸为 `size`，为零时使用图片自身尺寸；在 `placeSubviews` 中调用。
 */
- (void)cyl_placeNoMoreDataImageBesideLabel:(nullable UILabel *)label inset:(CGFloat)inset size:(CGSize)size
    NS_SWIFT_NAME(cyl_placeNoMoreDataImage(besideLabel:inset:size:));
@end


NS_ASSUME_NONNULL_END
