//
//  CYLRefreshAutoStateFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/6/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshAutoFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] An automatic footer that shows a localized text for each state (`setTitle:forState:`).
 * [CN] 按状态显示本地化文字（`setTitle:forState:`）的自动刷新尾。
 */
@interface CYLRefreshAutoStateFooter : CYLRefreshAutoFooter
/*!
 * 文字距离圈圈、箭头的距离
 */
@property (assign, nonatomic) CGFloat labelLeftInset;
/*!
 * 显示刷新状态的label
 */
@property (weak, nonatomic, readonly) UILabel *stateLabel;

/*!
 * 设置state状态下的文字
 */
- (instancetype)setTitle:(NSString *)title forState:(CYLRefreshState)state;
/*!
 * [EN] The text shown in `state`, or nil (the same getter as `CYLRefreshBackStateFooter`).
 * [CN] `state` 显示的文字，或 nil（与 `CYLRefreshBackStateFooter` 相同的读取方法）。
 */
- (nullable NSString *)titleForState:(CYLRefreshState)state;

/*!
 * 隐藏刷新状态的文字
 */
@property (assign, nonatomic, getter=isRefreshingTitleHidden) BOOL refreshingTitleHidden;
@end

NS_ASSUME_NONNULL_END
