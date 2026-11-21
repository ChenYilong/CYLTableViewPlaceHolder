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
//  [EN] Swift since 2026-11-19: the class is in `CYLPlaceholderStackView.swift`. The action handler block type stays here
//       in Objective-C, made Swift-compatible (docs/Swift-Migration.md, rule 6).
//  [CN] 自 2026-11-19 起该类用 Swift 编写（`CYLPlaceholderStackView.swift`）。动作处理的 block 类型保留在 Objective-C 中并兼容 Swift
//       （docs/Swift-Migration.md 第 6 条）。
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

/*!
 * [EN] The stack view. The class is Swift since 2026-11-19 (`CYLPlaceholderStackView.swift`) with the same Objective-C
 *      API: `stackView`, `placeholderView`, `componentViews`, `imageView`, `titleLabel`, `hintLabel`, `button`,
 *      `scenario`, `backgroundAction`, `-initWithScenario:actions:` (Swift `init(scenario:actions:)`),
 *      `-initWithComponents:actions:` (designated, Swift `init(components:actions:)`),
 *      `-initWithConfiguration:actions:error:` (Swift `init(configuration:actions:)`, errors in
 *      `CYLPlaceholderConfigurationErrorDomain` with `CYLPlaceholderConfigurationErrorStackView`),
 *      `-initWithContentsOfURL:actions:error:` (Swift `init(contentsOf:actions:)`), `-appendComponent:` (Swift
 *      `append(_:)`), `-appendComponentView:action:spacingBefore:` (Swift `append(_:action:spacingBefore:)`),
 *      `-setHandler:forAction:` (Swift `setHandler(_:for:)`), `-componentViewForAction:` (Swift `componentView(for:)`)
 *      and `-performAction:` (Swift `performAction(_:)`); `-initWithFrame:` and `-initWithCoder:` are unavailable.
 *      Objective-C code that messages it imports the umbrella header `CYLTableViewPlaceHolder.h`, which brings the
 *      generated Swift header.
 * [CN] 组件视图堆叠。该类自 2026-11-19 起用 Swift 编写（`CYLPlaceholderStackView.swift`），Objective-C API 不变（含 Swift 名称与配置错误码）。
 *      需要调用它的 Objective-C 代码请导入总头文件 `CYLTableViewPlaceHolder.h`（其中导入生成的 Swift 头文件）。
 */
@class CYLPlaceholderStackView;

NS_ASSUME_NONNULL_END
