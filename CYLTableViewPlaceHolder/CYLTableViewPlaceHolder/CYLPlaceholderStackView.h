//
//  CYLPlaceholderStackView.h
//  CYLTableViewPlaceHolder
//
//  [EN] An empty-state view that stacks icon-and-title components (CYLPlaceholderView) vertically in a UIStackView.
//  The first component is reserved: it is the classic icon and title. A scenario, or the app, appends more
//  components: a hint, a button, a separator, an icon. Taps on components perform actions whose handlers are given
//  when the view is created.
//  [CN] 用 UIStackView 竖向堆叠图标加标题组件（CYLPlaceholderView）的空状态视图。第一个组件是保留组件，即经典的
//  图标加标题；场景或应用可继续追加提示、按钮、分隔符、图标等组件。点击组件会执行动作，动作的处理在创建时指定。
//

#import <UIKit/UIKit.h>
#import "CYLPlaceholderView.h"
#import "CYLPlaceholderScenario.h"
#import "CYLPlaceholderStatusView.h"

NS_ASSUME_NONNULL_BEGIN

@class CYLPlaceholderStackView;

/// Runs on the main thread when a component's action is performed.
typedef void (^CYLPlaceholderActionHandler)(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action);

@interface CYLPlaceholderStackView : UIView

/// The vertical stack holding the components: centered, sized by its components.
@property (nonatomic, strong, readonly) UIStackView *stackView;
/// The reserved first component: the icon and title.
@property (nonatomic, strong, readonly) CYLPlaceholderView *placeholderView;
/// Every component, the reserved one first.
@property (nonatomic, copy, readonly) NSArray<CYLPlaceholderView *> *componentViews;
/// The scenario the view was created from; CYLPlaceholderScenarioCount when it was created from components.
@property (nonatomic, readonly) CYLPlaceholderScenario scenario;
/// The action of a tap anywhere outside a tappable component; nil turns that off. Set from the scenario.
@property (nonatomic, copy, nullable) CYLPlaceholderAction backgroundAction;
/*!
 * [EN] A status bar pinned to the top edge across the full width, such as the network bar of
 *      `CYLPlaceholderStatusView`; the components center in the space below it. nil (the default) removes it, and the
 *      layout is the same as before. With `componentsHidden` this gives three combinations: the bar and the
 *      placeholder, only the bar, only the placeholder.
 * [CN] 固定在顶部、铺满宽度的状态条，如 `CYLPlaceholderStatusView` 的网络提示条；组件在其下方的区域居中。nil（默认）表示移除，布局与以前相同。
 *      与 `componentsHidden` 组合可以得到三种显示方式：状态条加占位图、只显示状态条、只显示占位图。
 */
@property (nonatomic, strong, nullable) CYLPlaceholderStatusView *statusView;
/*!
 * [EN] YES hides every component (the icon, title, hints, buttons), so only the status bar shows; NO (the default)
 *      shows them. VoiceOver skips hidden components. [CN] YES 隐藏所有组件（图标、标题、提示、按钮），只显示状态条；NO（默认）显示。
 *      VoiceOver 会跳过隐藏的组件。
 */
@property (nonatomic) BOOL componentsHidden;

/*!
 * The scenario's components, with handlers for its actions (for example `CYLPlaceholderActionRetry` and
 * `CYLPlaceholderActionContactSupport`). An action without a handler does nothing.
 */
- (instancetype)initWithScenario:(CYLPlaceholderScenario)scenario
                         actions:(nullable NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions
    NS_SWIFT_NAME(init(scenario:actions:));
/*!
 * Custom components; the first is the reserved one (a default icon and title when the array is empty or the
 * first component's attributes are invalid).
 */
- (instancetype)initWithComponents:(NSArray<CYLPlaceholderComponent *> *)components
                           actions:(nullable NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions
    NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(components:actions:));
/*!
 * A placeholder from a configuration dictionary (JSON or property list), as described in
 * docs/Placeholder-Scenarios.md: "scenario" (a name, see `+[CYLPlaceholderScenarioCatalog scenarioNamed:]`),
 * "components" (component dictionaries, replacing the scenario's), "overrides" (dictionaries with an "index" and the
 * component fields "action", "interactionEnabled", "highlightStyle", "repeatCount", "spacingBefore"),
 * "backgroundAction" (an action name, or "" for none), "statusBar" (true or "networkUnavailable" for the network
 * bar, or a dictionary: "text", "textKey" a core string key, "image" an image name in the core bundle or "system:<SF Symbol>",
 * "titleColor", "backgroundColor", "accessibilityIdentifier", "action" an action name run on a tap) and "display"
 * ("placeholder", "status" or "statusAndPlaceholder"; "status" without "statusBar" shows the network bar).
 * Handlers come from `actions`, keyed by action.
 */
- (nullable instancetype)initWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                       actions:(nullable NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions
                                         error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(init(configuration:actions:));
/// The configuration in a local ".json" or ".plist" file.
- (nullable instancetype)initWithContentsOfURL:(NSURL *)url
                                       actions:(nullable NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions
                                         error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(init(contentsOf:actions:));
/*!
 * [EN] Only a status bar: no visible components (`componentsHidden` is YES). [CN] 只显示状态条：没有可见组件（`componentsHidden` 为 YES）。
 */
- (instancetype)initWithStatusView:(CYLPlaceholderStatusView *)statusView NS_SWIFT_NAME(init(statusView:));
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// Appends a component under the last one and returns its view; nil, with a log, when its attributes are invalid.
- (nullable CYLPlaceholderView *)appendComponent:(CYLPlaceholderComponent *)component NS_SWIFT_NAME(append(_:));
/// Appends a view the app made itself; a tap on it performs `action` when that is not nil.
- (void)appendComponentView:(CYLPlaceholderView *)view
                     action:(nullable CYLPlaceholderAction)action
              spacingBefore:(CGFloat)spacingBefore NS_SWIFT_NAME(append(_:action:spacingBefore:));
/// Sets or, with nil, removes the handler of an action.
- (void)setHandler:(nullable CYLPlaceholderActionHandler)handler forAction:(CYLPlaceholderAction)action NS_SWIFT_NAME(setHandler(_:for:));
/// The first component whose tap performs `action`.
- (nullable CYLPlaceholderView *)componentViewForAction:(CYLPlaceholderAction)action NS_SWIFT_NAME(componentView(for:));
/// Runs the handler of `action`; NO when it has none.
- (BOOL)performAction:(CYLPlaceholderAction)action NS_SWIFT_NAME(performAction(_:));

@end

NS_ASSUME_NONNULL_END
