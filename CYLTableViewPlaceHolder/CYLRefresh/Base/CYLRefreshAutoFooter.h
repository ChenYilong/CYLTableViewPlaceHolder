//
//  CYLRefreshAutoFooter.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CYLRefreshFooter.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A footer that sits right after the content and loads more by itself when it scrolls into view (see
 *      `automaticallyRefresh` and `triggerAutomaticallyRefreshPercent`), or when tapped; the base of the automatic
 *      footers.
 * [CN] 紧跟在内容之后的刷新尾，滚动到可见时自动加载更多（见 `automaticallyRefresh` 与
 *      `triggerAutomaticallyRefreshPercent`），也可点击加载；各自动刷新尾的基类。
 */
@interface CYLRefreshAutoFooter : CYLRefreshFooter
/*!
 * 是否自动刷新(默认为YES)
 */
@property (assign, nonatomic, getter=isAutomaticallyRefresh) BOOL automaticallyRefresh;

/*!
 * 当底部控件出现多少时就自动刷新(默认为1.0，也就是底部控件完全出现时，才会自动刷新)
 */
@property (assign, nonatomic) CGFloat triggerAutomaticallyRefreshPercent;

/*!
 * 自动触发次数, 默认为 1, 仅在拖拽 ScrollView 时才生效,
 *
 * 如果为 -1, 则为无限触发
 */
@property (nonatomic) NSInteger autoTriggerTimes;
/*!
 * [EN] Loads more on a pull-up release when the content does not fill the scroll view; NO waits for content that
 *      fills it (CYLRefreshLayout's `setEnableLoadMoreWhenContentNotFull`). Default YES.
 * [CN] 内容不满一屏时，上拉松手也加载更多；NO 时等内容填满后才加载（对应 CYLRefreshLayout 的
 *      `setEnableLoadMoreWhenContentNotFull`）。默认 YES。
 */
@property (nonatomic) BOOL loadsWhenContentNotFull;
@end

NS_ASSUME_NONNULL_END
