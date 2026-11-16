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
 * [EN] The first icon of the components (the reserved component's image view when none shows one); the same as
 *      Android's `CYLPlaceholderStackView.imageView`.
 * [CN] 组件中的第一个图标（都没有图标时为保留组件的图片视图）；与 Android 的 `CYLPlaceholderStackView.imageView` 相同。
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;
/*!
 * [EN] The first title that is not a hint, a button or a separator (the reserved component's label when there is
 *      none); the same as Android's `titleLabel`.
 * [CN] 第一个不是提示、按钮或分隔符的标题（没有时为保留组件的标签）；与 Android 的 `titleLabel` 相同。
 */
@property (nonatomic, strong, readonly) UILabel *titleLabel;
/*!
 * [EN] The label of the first hint component (`hintComponentWithText:`), or nil; the same as Android's `hintLabel`.
 * [CN] 第一个提示组件（`hintComponentWithText:`）的标签，没有则为 nil；与 Android 的 `hintLabel` 相同。
 */
@property (nonatomic, strong, readonly, nullable) UILabel *hintLabel;
/*!
 * [EN] The first button component (`buttonComponentWithTitle:style:action:`), or nil; `performTap` taps it. The same
 *      as Android's `button`.
 * [CN] 第一个按钮组件（`buttonComponentWithTitle:style:action:`），没有则为 nil；`performTap` 可点击它。与 Android 的 `button` 相同。
 */
@property (nonatomic, strong, readonly, nullable) CYLPlaceholderView *button;
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
