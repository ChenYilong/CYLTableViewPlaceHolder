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

NS_ASSUME_NONNULL_BEGIN

@class CYLPlaceholderStackView;

/*!
 * Runs on the main thread when a component's action is performed.
 */
typedef void (^CYLPlaceholderActionHandler)(CYLPlaceholderStackView *placeholder, CYLPlaceholderAction action);

@interface CYLPlaceholderStackView : UIView

/*!
 * The vertical stack holding the components: centered, sized by its components.
 */
@property (nonatomic, strong, readonly) UIStackView *stackView;
/*!
 * The reserved first component: the icon and title.
 */
@property (nonatomic, strong, readonly) CYLPlaceholderView *placeholderView;
/*!
 * Every component, the reserved one first.
 */
@property (nonatomic, copy, readonly) NSArray<CYLPlaceholderView *> *componentViews;
/*!
 * The scenario the view was created from; CYLPlaceholderScenarioCount when it was created from components.
 */
@property (nonatomic, readonly) CYLPlaceholderScenario scenario;
/*!
 * The action of a tap anywhere outside a tappable component; nil turns that off. Set from the scenario.
 */
@property (nonatomic, copy, nullable) CYLPlaceholderAction backgroundAction;

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
 * component fields "action", "interactionEnabled", "highlightStyle", "repeatCount", "spacingBefore"), and
 * "backgroundAction" (an action name, or "" for none). Handlers come from `actions`, keyed by action.
 */
- (nullable instancetype)initWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                       actions:(nullable NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions
                                         error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(init(configuration:actions:));
/*!
 * The configuration in a local ".json" or ".plist" file.
 */
- (nullable instancetype)initWithContentsOfURL:(NSURL *)url
                                       actions:(nullable NSDictionary<CYLPlaceholderAction, CYLPlaceholderActionHandler> *)actions
                                         error:(NSError * _Nullable * _Nullable)error
    NS_SWIFT_NAME(init(contentsOf:actions:));
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/*!
 * Appends a component under the last one and returns its view; nil, with a log, when its attributes are invalid.
 */
- (nullable CYLPlaceholderView *)appendComponent:(CYLPlaceholderComponent *)component NS_SWIFT_NAME(append(_:));
/*!
 * Appends a view the app made itself; a tap on it performs `action` when that is not nil.
 */
- (void)appendComponentView:(CYLPlaceholderView *)view
                     action:(nullable CYLPlaceholderAction)action
              spacingBefore:(CGFloat)spacingBefore NS_SWIFT_NAME(append(_:action:spacingBefore:));
/*!
 * Sets or, with nil, removes the handler of an action.
 */
- (void)setHandler:(nullable CYLPlaceholderActionHandler)handler forAction:(CYLPlaceholderAction)action NS_SWIFT_NAME(setHandler(_:for:));
/*!
 * The first component whose tap performs `action`.
 */
- (nullable CYLPlaceholderView *)componentViewForAction:(CYLPlaceholderAction)action NS_SWIFT_NAME(componentView(for:));
/*!
 * Runs the handler of `action`; NO when it has none.
 */
- (BOOL)performAction:(CYLPlaceholderAction)action NS_SWIFT_NAME(performAction(_:));

@end

NS_ASSUME_NONNULL_END
