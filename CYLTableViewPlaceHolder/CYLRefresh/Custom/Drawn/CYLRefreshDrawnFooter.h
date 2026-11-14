//
//  CYLRefreshDrawnFooter.h
//  CYLRefresh
//
//  flutter_easy_refresh's BezierFooter, MaterialFooter, DeliveryFooter, PhoenixFooter and TaurusFooter
//  (https://github.com/xuelongqy/flutter_easy_refresh, MIT) reuse the drawing of the matching headers. Here a footer
//  hosts one drawn header and passes it the pull, the progress and the status, so every drawn style can load more.
//

#import "CYLRefreshBackStateFooter.h"
#import "CYLRefreshDrawnHeader.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [EN] A pull-up footer drawn by a hosted drawn header (`style`): the header gets the distance pulled past the content,
 *      the progress and SmartRefreshControl's status order, and draws in the revealed area under the content. Only
 *      the "no more data" text is shown as a label (from `CYLRefresh.strings`).
 * [CN] 由内嵌的手绘刷新头（`style`）绘制的上拉刷新尾：刷新头收到拉出内容底部的距离、进度和 SmartRefreshControl 顺序的状态，在内容
 *      下方露出的区域里绘制。只有“没有更多数据”以文字标签显示（来自 `CYLRefresh.strings`）。
 */
@interface CYLRefreshDrawnFooter : CYLRefreshBackStateFooter
/*!
 * [EN] The drawn header class a subclass hosts; nil in the base class. [CN] 子类内嵌的手绘刷新头类；基类为 nil。
 */
@property (class, nonatomic, readonly, nullable) Class styleClass;
/*!
 * [EN] A footer drawn by `style`; the footer takes the style's open height. [CN] 由 `style` 绘制的刷新尾；刷新尾使用该样式的展开高度。
 */
- (instancetype)initWithStyle:(CYLRefreshDrawnHeader *)style;
/*!
 * [EN] The hosted drawn header; set its colors and options here or through the footer's `colorAccent` /
 *      `colorPrimary`. [CN] 内嵌的手绘刷新头；可直接设置它的颜色与选项，或通过刷新尾的 `colorAccent` / `colorPrimary` 设置。
 */
@property (strong, nonatomic, readonly, nullable) CYLRefreshDrawnHeader *style;
@end

/*!
 * [EN] flutter_easy_refresh's `BezierFooter`, drawn by CYLRefreshBezierRadarHeader. [CN] flutter_easy_refresh 的 `BezierFooter`，由 CYLRefreshBezierRadarHeader 绘制。
 */
@interface CYLRefreshBezierRadarFooter : CYLRefreshDrawnFooter
@end

/*!
 * [EN] flutter_easy_refresh's `MaterialFooter`, drawn by CYLRefreshMaterialHeader. [CN] flutter_easy_refresh 的 `MaterialFooter`，由 CYLRefreshMaterialHeader 绘制。
 */
@interface CYLRefreshMaterialFooter : CYLRefreshDrawnFooter
@end

/*!
 * [EN] flutter_easy_refresh's `DeliveryFooter`, drawn by CYLRefreshDeliveryHeader. [CN] flutter_easy_refresh 的 `DeliveryFooter`，由 CYLRefreshDeliveryHeader 绘制。
 */
@interface CYLRefreshDeliveryFooter : CYLRefreshDrawnFooter
@end

/*!
 * [EN] flutter_easy_refresh's `PhoenixFooter`, drawn by CYLRefreshPhoenixHeader. [CN] flutter_easy_refresh 的 `PhoenixFooter`，由 CYLRefreshPhoenixHeader 绘制。
 */
@interface CYLRefreshPhoenixFooter : CYLRefreshDrawnFooter
@end

/*!
 * [EN] flutter_easy_refresh's `TaurusFooter`, drawn by CYLRefreshTaurusHeader. [CN] flutter_easy_refresh 的 `TaurusFooter`，由 CYLRefreshTaurusHeader 绘制。
 */
@interface CYLRefreshTaurusFooter : CYLRefreshDrawnFooter
@end

NS_ASSUME_NONNULL_END
