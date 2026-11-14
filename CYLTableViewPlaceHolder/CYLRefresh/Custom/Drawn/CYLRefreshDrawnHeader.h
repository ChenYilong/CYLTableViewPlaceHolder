//
//  CYLRefreshDrawnHeader.h
//  CYLRefresh
//
//  The base of the hand-drawn headers ported from SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl,
//  MIT): it offers SmartRefreshControl's subclass API (`UIRefreshComponent` / `UIRefreshHeader`) on top of CYLRefresh's
//  phases, so each ported style keeps its original drawing code. See CYLRefresh/LICENSE.third-party.
//

#import "CYLRefreshHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A header whose look is drawn in code (Core Graphics, layers or SpriteKit). Subclasses override the
 *      SmartRefreshControl-named hooks below; the base maps CYLRefresh's phases onto them in SmartRefreshControl's order
 *      (pull, release, releasing, refreshing, finish, idle).
 * [CN] 用代码绘制外观（Core Graphics、图层或 SpriteKit）的刷新头。子类重写下面以 SmartRefreshControl 命名的钩子；基类按
 *      SmartRefreshControl 的顺序（下拉、松开、释放中、刷新中、结束、空闲）把 CYLRefresh 的阶段映射到这些钩子上。
 */
@interface CYLRefreshDrawnHeader : CYLRefreshHeader

/*!
 * [EN] The frame width. [CN] frame 宽度。
 */
@property (nonatomic) CGFloat width;
/*!
 * [EN] The open height; setting it calls `setExpandHeight:`. Reading it returns the frame height, which follows the
 *      pull in stretch mode. [CN] 展开高度；设置时调用 `setExpandHeight:`。读取时返回 frame 高度，拉伸模式下随下拉变化。
 */
@property (nonatomic) CGFloat height;
/*!
 * [EN] Duration of the styles' short animations, in seconds. Default 0.1. [CN] 样式短动画的时长（秒），默认 0.1。
 */
@property (nonatomic) NSTimeInterval durationFast;
/*!
 * [EN] Duration of the styles' normal animations, in seconds. Default 0.25. [CN] 样式普通动画的时长（秒），默认 0.25。
 */
@property (nonatomic) NSTimeInterval durationNormal;
/*!
 * [EN] The phase as SmartRefreshControl reports it: `CYLRefreshPhaseReleasing` is always passed through before
 *      refreshing, and `CYLRefreshPhaseFinishing` after it. [CN] 按 SmartRefreshControl 的方式报告的阶段：刷新前一定经过
 *      `CYLRefreshPhaseReleasing`，刷新后一定经过 `CYLRefreshPhaseFinishing`。
 */
@property (nonatomic, readonly) CYLRefreshPhase status;
/*!
 * [EN] Points pulled below the content's top, the open height included while refreshing.
 * [CN] 被拉出内容顶部的点数，刷新中包含展开高度。
 */
@property (nonatomic, readonly) CGFloat dragOffset;
/*!
 * [EN] `dragOffset` / (`expandHeight` × `triggerRate`). [CN] `dragOffset` / (`expandHeight` × `triggerRate`)。
 */
@property (nonatomic, readonly) CGFloat dragPercent;
/*!
 * [EN] Whether the last refresh succeeded (`lastRefreshSucceeded`). [CN] 上一次刷新是否成功（`lastRefreshSucceeded`）。
 */
@property (nonatomic, readonly) BOOL isSuccess;

/*!
 * [EN] Set-up hook, called once from `prepare`; subclasses call super. [CN] 初始化钩子，由 `prepare` 调用一次；子类需调用 super。
 */
- (void)setUpComponent NS_REQUIRES_SUPER;
/*!
 * [EN] `status` changed. [CN] `status` 变化。
 */
- (void)onStatus:(CYLRefreshPhase)oldStatus changed:(CYLRefreshPhase)status;
/*!
 * [EN] Every scroll, with `dragOffset`, `dragPercent` and whether the user drags; calls `onScrollingWithOffset:…`.
 * [CN] 每次滚动时调用，参数为 `dragOffset`、`dragPercent` 与是否在拖动；会调用 `onScrollingWithOffset:…`。
 */
- (void)scrollView:(UIScrollView *)scrollView didScroll:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging NS_SWIFT_NAME(scrollView(_:didScroll:percent:drag:));
/*!
 * [EN] Every scroll; draw the pull here. [CN] 每次滚动时调用；在这里绘制下拉过程。
 */
- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging;
/*!
 * [EN] The user released past the trigger point (or `beginRefreshing` was called). [CN] 用户越过触发点松手（或调用了 `beginRefreshing`）。
 */
- (void)onStartAnimationWhenRealeasing;
/*!
 * [EN] The refresh started. [CN] 刷新开始。
 */
- (void)onStartAnimationWhenRefreshing;
/*!
 * [EN] The refresh ended with `success`. [CN] 刷新以 `success` 结束。
 */
- (void)onRefreshFinished:(BOOL)success;
/*!
 * [EN] Seconds to stay open after the refresh ends; `finishDuration` by default. [CN] 刷新结束后停留的秒数；默认为 `finishDuration`。
 */
- (CGFloat)onRefreshFinishing:(BOOL)success;
/*!
 * [EN] The header was attached to or detached from `scrollView`. [CN] 刷新头挂到或离开 `scrollView`。
 */
- (void)scrollView:(UIScrollView *)scrollView attached:(BOOL)attach NS_SWIFT_NAME(scrollView(_:attached:));
/*!
 * [EN] `beginRefreshing`, under SmartRefreshControl's name. [CN] 即 `beginRefreshing`（SmartRefreshControl 的名字）。
 */
- (void)beginRefresh;
/*!
 * [EN] `endRefreshing`, under SmartRefreshControl's name. [CN] 即 `endRefreshing`（SmartRefreshControl 的名字）。
 */
- (void)finishRefresh;
/*!
 * [EN] `endRefreshingWithSuccess:`, under SmartRefreshControl's name. [CN] 即 `endRefreshingWithSuccess:`（SmartRefreshControl 的名字）。
 */
- (void)finishRefreshWithSuccess:(BOOL)success;
/*!
 * [EN] YES when `status` is one of the listed phases; the list ends with 0. [CN] `status` 为所列阶段之一时为 YES；列表以 0 结尾。
 */
- (BOOL)inStatus:(CYLRefreshPhase)status, ... NS_SWIFT_UNAVAILABLE("Compare status instead");

@end

NS_ASSUME_NONNULL_END
