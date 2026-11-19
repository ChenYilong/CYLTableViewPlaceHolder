//
//  CYLRefreshNormalTrailer.h
//  CYLRefresh
//
//  Created by kinarobin on 2020/5/3.
//  Copyright © 2020 小码哥. All rights reserved.
//

#import "CYLRefreshStateTrailer.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] The standard trailer: the state text with an arrow.
 * [CN] 标准 trailer：状态文字带箭头。
 */
@interface CYLRefreshNormalTrailer : CYLRefreshStateTrailer

/*!
 * [EN] The arrow beside the text (the bundle's `CYLRefreshTrailArrow` image, template-rendered so it takes the tint
 *      color), created on first access.
 * [CN] 文字旁边的箭头（bundle 中的 `CYLRefreshTrailArrow` 图片，按模板渲染从而使用
 *      tintColor），首次访问时创建。
 */
@property (weak, nonatomic, readonly) UIImageView *arrowView;

@end

NS_ASSUME_NONNULL_END
