//  代码地址: https://github.com/ChenYilong/CYLTableViewPlaceHolder
//  CYLRefreshComponent.h
//  CYLRefresh
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//  刷新控件的基类
//
//  [EN] Swift since 2026-11-20: the class is in `CYLRefreshComponent.swift` (docs/Swift-Migration.md, step 12), with the
//       same Objective-C API (selectors, `is…` getters, the overridable hooks) and its former categories
//       `CYLRefreshIconLayout`, `CYLRefreshStateTitles` and `ChainingGrammar`. This header keeps what Swift cannot declare
//       for Objective-C (rule 6): the enums, the block types, the forward declaration and the `UILabel (CYLRefresh)`
//       declarations for Objective-C; the variadic `-isInPhases:` is in `CYLRefreshComponent+CYLPhaseList.h`.
//       Objective-C code that uses the class imports the umbrella header `CYLTableViewPlaceHolder.h`.
//  [CN] 自 2026-11-20 起该类用 Swift 编写（`CYLRefreshComponent.swift`，docs/Swift-Migration.md 第 12 步），Objective-C API 不变（选择器、
//       `is…` getter、可重写的钩子），原分类 `CYLRefreshIconLayout`、`CYLRefreshStateTitles` 与 `ChainingGrammar` 一并迁移。本头文件保留
//       Swift 无法为 Objective-C 声明的部分（第 6 条）：枚举、block 类型、前向声明以及供 Objective-C 使用的 `UILabel (CYLRefresh)` 声明；
//       可变参数的 `-isInPhases:` 在 `CYLRefreshComponent+CYLPhaseList.h` 中。使用该类的 Objective-C 代码请导入总头文件
//       `CYLTableViewPlaceHolder.h`。

#import <UIKit/UIKit.h>
#import "CYLRefreshConst.h"

@class CYLRefreshIconView;
@class CYLRefreshComponent;

NS_ASSUME_NONNULL_BEGIN

/*!
 * 刷新控件的状态
 */
typedef NS_ENUM(NSInteger, CYLRefreshState) {
    /*!
     * 普通闲置状态
     */
    CYLRefreshStateIdle = 1,
    /*!
     * 松开就可以进行刷新的状态
     */
    CYLRefreshStatePulling,
    /*!
     * 正在刷新中的状态
     */
    CYLRefreshStateRefreshing,
    /*!
     * 即将刷新的状态
     */
    CYLRefreshStateWillRefresh,
    /*!
     * 所有数据加载完毕，没有更多的数据了
     */
    CYLRefreshStateNoMoreData
};

/*!
 * [EN] How the header moves while it is pulled (the CYLRefresh styles' `UI…ScrollMode`).
 * [CN] 下拉时刷新头的移动方式（对应 CYLRefresh styles 的 `UI…ScrollMode`）。
 */
typedef NS_ENUM(NSInteger, CYLRefreshScrollMode) {
    /*!
     * [EN] The header moves with the content (default, MJRefresh's behavior). [CN] 刷新头随内容移动（默认，MJRefresh 的行为）。
     */
    CYLRefreshScrollModeMove = 0,
    /*!
     * [EN] The header stretches to fill the whole pulled distance. [CN] 刷新头拉伸，铺满整个下拉距离。
     */
    CYLRefreshScrollModeStretch,
    /*!
     * [EN] The header slides in at the top of the visible area, in front of the content. [CN] 刷新头从可见区域顶部滑入，位于内容前面。
     */
    CYLRefreshScrollModeFront,
    /*!
     * [EN] The header stays pinned behind the content at the visible top and is revealed as the content moves down
     *      (flutter_easy_refresh's `IndicatorPosition.behind`). [CN] 刷新头固定在可见区域顶部、位于内容后面，内容下移时露出
     *      （对应 flutter_easy_refresh 的 `IndicatorPosition.behind`）。
     */
    CYLRefreshScrollModeBehind,
};

/*!
 * [EN] When a pull may arm the control (flutter_easy_refresh's `IndicatorTriggerMode`).
 * [CN] 拉动何时可以触发控件（对应 flutter_easy_refresh 的 `IndicatorTriggerMode`）。
 */
typedef NS_ENUM(NSInteger, CYLRefreshTriggerMode) {
    /*!
     * [EN] Any pull past the trigger point, also one that started in the middle of the list (default, MJRefresh's
     *      behavior). [CN] 任何越过触发点的拉动都可以，包括从列表中间开始的拉动（默认，MJRefresh 的行为）。
     */
    CYLRefreshTriggerModeAnywhere = 0,
    /*!
     * [EN] Only a drag that started with the list already at the edge. [CN] 只有开始拖动时列表已在边缘的拖动才可以。
     */
    CYLRefreshTriggerModeOnEdge,
};

/*!
 * [EN] The detailed phase of a refresh control: `state` plus whether the user is still dragging and the finishing hold
 *      (the CYLRefresh styles' `UIRefreshStatus` / `UI…FooterStatus`).
 * [CN] 刷新控件的细分阶段：`state` 加上是否仍在拖动以及结束停留（对应 CYLRefresh styles 的 `UIRefreshStatus` / `UI…FooterStatus`）。
 */
typedef NS_ENUM(NSInteger, CYLRefreshPhase) {
    /*!
     * [EN] Idle, not pulled. [CN] 空闲，未拉动。
     */
    CYLRefreshPhaseIdle = 1,
    /*!
     * [EN] Pulled, not far enough to refresh yet. [CN] 已拉动，但还不够远，松手不会刷新。
     */
    CYLRefreshPhasePullToRefresh,
    /*!
     * [EN] Pulled far enough; releasing starts the refresh. [CN] 已拉够距离，松手即刷新。
     */
    CYLRefreshPhaseReleaseToRefresh,
    /*!
     * [EN] `beginRefreshing` was called before the control was on screen. [CN] 控件上屏前调用了 `beginRefreshing`。
     */
    CYLRefreshPhaseWillRefresh,
    /*!
     * [EN] Released past the trigger point, moving to the refreshing position. [CN] 已越过触发点松手，正移动到刷新位置。
     */
    CYLRefreshPhaseReleasing,
    /*!
     * [EN] Refreshing or loading. [CN] 正在刷新或加载。
     */
    CYLRefreshPhaseRefreshing,
    /*!
     * [EN] Finished, holding for `finishDuration` before retracting. [CN] 已结束，收回前停留 `finishDuration`。
     */
    CYLRefreshPhaseFinishing,
    /*!
     * [EN] A footer showing that all data is loaded. [CN] 加载尾显示已全部加载。
     */
    CYLRefreshPhaseNoMoreData,
    /*!
     * [EN] Pulled past `secondaryTriggerOffset`: releasing opens the second floor. [CN] 已拉过 `secondaryTriggerOffset`：松手打开二楼。
     */
    CYLRefreshPhaseSecondaryArmed,
    /*!
     * [EN] The second floor is open. [CN] 二楼已打开。
     */
    CYLRefreshPhaseSecondaryOpen,
    /*!
     * [EN] The second floor is closing. [CN] 二楼正在关闭。
     */
    CYLRefreshPhaseSecondaryClosing,
};

/*!
 * [EN] A refreshing callback that receives the control (the CYLRefresh styles' `RefreshBlock`).
 * [CN] 带控件参数的刷新回调（对应 CYLRefresh styles 的 `RefreshBlock`）。
 */
typedef void (^CYLRefreshComponentHandler)(__kindof CYLRefreshComponent *component);

/*!
 * 进入刷新状态的回调
 */
typedef void (^CYLRefreshComponentRefreshingBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");
/*!
 * 开始刷新后的回调(进入刷新状态后的回调)
 */
typedef void (^CYLRefreshComponentBeginRefreshingCompletionBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");
/*!
 * 结束刷新后的回调
 */
typedef void (^CYLRefreshComponentEndRefreshingCompletionBlock)(void) CYLRefreshDeprecated("first deprecated in 3.3.0 - Use `CYLRefreshComponentAction` instead");

/*!
 * 刷新用到的回调类型
 */
typedef void (^CYLRefreshComponentAction)(void);

/*!
 * [EN] The base class of the refresh controls (headers, footers, trailers): it observes its scroll view and runs the
 *      refresh state machine. The class is Swift (`CYLRefreshComponent.swift`, with its icon layout, state titles and
 *      chaining setters); Objective-C code that messages it imports the umbrella header `CYLTableViewPlaceHolder.h`,
 *      which brings the generated Swift header and the variadic `-isInPhases:` (`CYLRefreshComponent+CYLPhaseList.h`).
 *      Objective-C cannot subclass a Swift class: subclasses are written in Swift.
 * [CN] 刷新控件的基类（刷新头、加载尾、trailer）：监听所在的滚动视图并运行刷新状态机。该类用 Swift 编写（`CYLRefreshComponent.swift`，
 *      含图标布局、状态文字与链式设置方法）；需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的
 *      Swift 头文件与可变参数的 `-isInPhases:`，见 `CYLRefreshComponent+CYLPhaseList.h`）。Objective-C 不能继承 Swift 类：子类请用 Swift 编写。
 */
@class CYLRefreshComponent;

// [EN] Implemented in Swift (`CYLRefreshComponent.swift`); declared here for Objective-C only, as the generated Swift
//      header declares it too (Swift sees its own extension).
// [CN] 用 Swift 实现（`CYLRefreshComponent.swift`）；这里只为 Objective-C 声明，生成的 Swift 头文件也声明了它（Swift 使用自己的扩展）。
#ifndef __swift__
/*!
 * [EN] Label helpers of the refresh controls.
 * [CN] 刷新控件使用的 UILabel 辅助方法。
 */
@interface UILabel(CYLRefresh)
/*!
 * [EN] A label styled as the refresh controls' texts: `CYLRefreshLabelFont`, `CYLRefreshLabelTextColor`, centered,
 *      clear background, flexible width.
 * [CN] 按刷新控件文字样式创建的
 *      label：`CYLRefreshLabelFont`、`CYLRefreshLabelTextColor`、居中、透明背景、宽度自适应。
 */
+ (instancetype)cyl_label;
/*!
 * [EN] The width the label's text (or attributed text) needs on one line, in points; 0 when it is empty.
 * [CN] label 的文字（或富文本）单行显示所需的宽度（点）；为空时为 0。
 */
- (CGFloat)cyl_textWidth;
@end
#endif

NS_ASSUME_NONNULL_END
