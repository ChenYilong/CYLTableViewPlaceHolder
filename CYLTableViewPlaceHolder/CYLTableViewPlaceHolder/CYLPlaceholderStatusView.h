//
//  CYLPlaceholderStatusView.h
//  CYLTableViewPlaceHolder
//
//  [EN] A one-line status bar on a red background, such as "Network unavailable, Check network". Ported from
//       CYLChatKit's LCCKStatusView (https://github.com/ChenYilong/CYLChatKit, ChatKit/Class/View/LCCKStatusView.h,
//       MIT, LICENSE.CYLChatKit in the resource bundle): the same API under this library's prefix (the delegate and
//       its `statusViewClicked:`, the 44-point height, `-initWithFrame:` showing the network message), with the icon
//       and the text drawn by the library's icon-and-title component, CYLPlaceholderView, laid out horizontally
//       (`CYLPlaceholderItemContentAxis`). The red background is this view; the component is its subview.
//       Show it alone, or with a placeholder through `CYLPlaceholderStackView.statusView`.
//  [CN] 红色背景的单行状态提示条，如“当前网络不可用，请检查你的网络设置”。移植自 CYLChatKit 的 LCCKStatusView（MIT，许可证见资源包中的
//       LICENSE.CYLChatKit）：保留相同的接口并改用本库前缀（代理及其 `statusViewClicked:`、44 点高度、`-initWithFrame:` 显示网络提示），
//       图标与文字改由本库的图标加标题组件 CYLPlaceholderView 横向排列绘制（`CYLPlaceholderItemContentAxis`）。红色背景是本视图，
//       组件是它的子视图。可以单独显示，也可以通过 `CYLPlaceholderStackView.statusView` 与占位图一起显示。
//

#import <UIKit/UIKit.h>
#import "CYLPlaceholderView.h"

NS_ASSUME_NONNULL_BEGIN

@class CYLPlaceholderStatusView;

/*!
 * [EN] Receives taps on the status bar, as `LCCKStatusViewDelegate` (CYLChatKit reconnects there).
 * [CN] 接收状态条的点击，与 `LCCKStatusViewDelegate` 相同（CYLChatKit 在这里重新连接）。
 */
@protocol CYLPlaceholderStatusViewDelegate <NSObject>

@optional
/// [EN] The bar was tapped; `sender` is the status view. [CN] 状态条被点击；`sender` 是状态视图。
- (void)statusViewClicked:(id)sender;

@end

/*!
 * [EN] The bar's height, 44 points, under CYLChatKit's spelling (`LCCKStatusViewHight`). Larger Dynamic Type sizes make
 *      the bar taller (`intrinsicContentSize`). [CN] 状态条高度 44 点，沿用 CYLChatKit 的拼写（`LCCKStatusViewHight`）。
 *      较大的动态字体会让状态条变高（`intrinsicContentSize`）。
 */
FOUNDATION_EXPORT const CGFloat CYLPlaceholderStatusViewHight;
/// [EN] The same height, correctly spelled. [CN] 同一高度，正确拼写。
FOUNDATION_EXPORT const CGFloat CYLPlaceholderStatusViewHeight;

/// [EN] Runs on the main thread when the bar is tapped. [CN] 状态条被点击时在主线程执行。
typedef void (^CYLPlaceholderStatusViewTapHandler)(CYLPlaceholderStatusView *statusView);

@interface CYLPlaceholderStatusView : UIView

/// [EN] Told about taps, as in CYLChatKit. [CN] 接收点击，与 CYLChatKit 相同。
@property (nonatomic, weak, nullable) id<CYLPlaceholderStatusViewDelegate> delegate;

/*!
 * [EN] The network bar of CYLChatKit: the failure icon and the localized "Network unavailable, Check network"
 *      (`CYLPlaceholderStatusNetworkUnavailable` in the core strings). [CN] CYLChatKit 的网络提示条：失败图标与本地化的
 *      “当前网络不可用，请检查你的网络设置”（核心文案 `CYLPlaceholderStatusNetworkUnavailable`）。
 */
- (instancetype)initWithFrame:(CGRect)frame;
/*!
 * [EN] A bar with its own icon and title: CYLPlaceholderView item attributes (`CYLPlaceholderItemTitle`,
 *      `CYLPlaceholderItemImage`, `CYLPlaceholderItemTitleColor`, `CYLPlaceholderItemBackgroundColor` for the red…);
 *      missing keys take the network bar's values, and the layout is always horizontal. Nil when they are invalid.
 * [CN] 自定义图标与标题的状态条：CYLPlaceholderView 的 item 属性；缺少的键使用网络提示条的值，布局总是横向。属性无效时返回 nil。
 */
- (nullable instancetype)initWithItemAttributes:(NSDictionary<NSString *, id> *)attributes
                                          error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(init(itemAttributes:));
/*!
 * [EN] The item attributes of the network bar, to start a custom one from. [CN] 网络提示条的 item 属性，可在此基础上自定义。
 */
@property (class, nonatomic, readonly) NSDictionary<NSString *, id> *networkUnavailableItemAttributes;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// [EN] The icon and the title, laid out horizontally; a subview filling the bar. [CN] 横向排列的图标与标题；铺满状态条的子视图。
@property (nonatomic, strong, readonly) CYLPlaceholderView *placeholderView;
/// [EN] The title shown; setting it updates the bar. [CN] 显示的文字；设置后更新状态条。
@property (nonatomic, copy, nullable) NSString *text;
/*!
 * [EN] Runs on a tap, after the delegate. With neither a handler nor a delegate, the bar is plain text for VoiceOver;
 *      with one, it is a button. [CN] 点击时在代理之后执行。没有处理也没有代理时，状态条对 VoiceOver 是普通文字；有其一时是按钮。
 */
@property (nonatomic, copy, nullable) CYLPlaceholderStatusViewTapHandler tapHandler;

@end

NS_ASSUME_NONNULL_END
