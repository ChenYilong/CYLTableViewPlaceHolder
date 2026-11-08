//
//  CYLRefreshBackStateFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/6/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshBackFooter.h"

NS_ASSUME_NONNULL_BEGIN

@interface CYLRefreshBackStateFooter : CYLRefreshBackFooter
/** 文字距离圈圈、箭头的距离 */
@property (assign, nonatomic) CGFloat labelLeftInset;
/** 显示刷新状态的label */
@property (weak, nonatomic, readonly) UILabel *stateLabel;
/** 设置state状态下的文字 */
- (instancetype)setTitle:(NSString *)title forState:(CYLRefreshState)state;

/** 获取state状态下的title */
- (NSString *)titleForState:(CYLRefreshState)state;
@end

NS_ASSUME_NONNULL_END
