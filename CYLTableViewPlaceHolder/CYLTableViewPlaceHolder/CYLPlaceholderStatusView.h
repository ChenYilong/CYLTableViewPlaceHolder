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
//       A view controller shows it, independently of the placeholder, through `cyl_statusDisplay` (UIViewController+CYLPlaceholderStatus.h).
//  [CN] 红色背景的单行状态提示条，如“当前网络不可用，请检查你的网络设置”。移植自 CYLChatKit 的 LCCKStatusView（MIT，许可证见资源包中的
//       LICENSE.CYLChatKit）：保留相同的接口并改用本库前缀（代理及其 `statusViewClicked:`、44 点高度、`-initWithFrame:` 显示网络提示），
//       图标与文字改由本库的图标加标题组件 CYLPlaceholderView 横向排列绘制（`CYLPlaceholderItemContentAxis`）。红色背景是本视图，
//       组件是它的子视图。视图控制器通过 `cyl_statusDisplay`（UIViewController+CYLPlaceholderStatus.h）显示它，与占位图相互独立。
//
//  [EN] Swift since 2026-11-19: the class is in `CYLPlaceholderStatusView.swift`. The delegate protocol, the height
//       constants (FOUNDATION_EXPORT symbols, defined in `CYLPlaceholderStatusViewSupport.m`) and the block type stay here
//       in Objective-C, made Swift-compatible (docs/Swift-Migration.md, rule 6).
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLPlaceholderStatusView.swift`）。代理协议、高度常量（FOUNDATION_EXPORT 符号，定义在
//       `CYLPlaceholderStatusViewSupport.m`）与回调类型保留在 Objective-C 中并兼容 Swift（docs/Swift-Migration.md 第 6 条）。
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
/*!
 * [EN] The bar was tapped; `sender` is the status view. [CN] 状态条被点击；`sender` 是状态视图。
 */
- (void)statusViewClicked:(id)sender;

@end

/*!
 * [EN] The bar's height, 44 points, under CYLChatKit's spelling (`LCCKStatusViewHight`). Larger Dynamic Type sizes make
 *      the bar taller (`intrinsicContentSize`). [CN] 状态条高度 44 点，沿用 CYLChatKit 的拼写（`LCCKStatusViewHight`）。
 *      较大的动态字体会让状态条变高（`intrinsicContentSize`）。
 */
FOUNDATION_EXPORT const CGFloat CYLPlaceholderStatusViewHight;
/*!
 * [EN] The same height, correctly spelled. [CN] 同一高度，正确拼写。
 */
FOUNDATION_EXPORT const CGFloat CYLPlaceholderStatusViewHeight;

/*!
 * [EN] Runs on the main thread when the bar is tapped. [CN] 状态条被点击时在主线程执行。
 */
typedef void (^CYLPlaceholderStatusViewTapHandler)(CYLPlaceholderStatusView *statusView);

/*!
 * [EN] The status bar. The class is Swift since 2026-11-19 (`CYLPlaceholderStatusView.swift`) with the same Objective-C
 *      API: `delegate`, `-initWithFrame:` (the network bar), `-initWithItemAttributes:error:` (Swift
 *      `init(itemAttributes:)`), `+networkUnavailableItemAttributes`, `-initWithConfiguration:error:` (Swift
 *      `init(configuration:)`), `placeholderView`, `text` and `tapHandler`; `-initWithCoder:` is unavailable. Objective-C
 *      code that messages it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the generated Swift
 *      header.
 * [CN] 状态条。该类自 2026-11-19 起用 Swift 编写（`CYLPlaceholderStatusView.swift`），Objective-C API 不变。需要调用它的 Objective-C
 *      代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLPlaceholderStatusView;

NS_ASSUME_NONNULL_END
