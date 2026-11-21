# 在 Swift 中使用 CYLTableViewPlaceHolder / Using CYLTableViewPlaceHolder from Swift

<!-- bound-classes: CYLPlaceholderView, CYLPlaceholderStackView, CYLPlaceholderHUD, CYLPlaceholderStatusView, CYLPlaceholderNetworkMonitor, CYLPlaceholderLocalization, CYLRefreshNormalHeader, CYLRefreshAnimationHeader -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [配置](#配置--setup) | [Setup](#配置--setup) |
| [命名模式](#命名模式--naming-pattern) | [Naming pattern](#命名模式--naming-pattern) |
| [已由本仓库 Swift 代码验证的写法](#已由本仓库-swift-代码验证的写法--spellings-verified-by-swift-code-in-this-repository) | [Spellings verified by Swift code in this repository](#已由本仓库-swift-代码验证的写法--spellings-verified-by-swift-code-in-this-repository) |
| [含下划线的协议方法](#含下划线的协议方法--protocol-methods-that-contain-underscores) | [Protocol methods that contain underscores](#含下划线的协议方法--protocol-methods-that-contain-underscores) |
| [未完成事项](#未完成事项--open-items) | [Open items](#未完成事项--open-items) |
| [示例跟随核心（作者，2026-11-13）](#示例跟随核心作者2026-11-13--examples-follow-the-core-owner-2026-11-13) | [Examples follow the core (owner, 2026-11-13)](#示例跟随核心作者2026-11-13--examples-follow-the-core-owner-2026-11-13) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| `CYLPlaceholderView` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderView.h) |
| `CYLPlaceholderStackView` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h) |
| `CYLPlaceholderHUD` | [`CYLTableViewPlaceHolder/CYLPlaceholderHUD/CYLPlaceholderHUD.h`](../CYLTableViewPlaceHolder/CYLPlaceholderHUD/CYLPlaceholderHUD.h) |
| `CYLPlaceholderStatusView` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStatusView.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStatusView.h) |
| `CYLPlaceholderNetworkMonitor` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderNetworkMonitor.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderNetworkMonitor.h) |
| `CYLPlaceholderLocalization` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderLocalization.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderLocalization.h) |
| `CYLRefreshNormalHeader` | [`CYLTableViewPlaceHolder/CYLRefresh/Custom/Header/CYLRefreshNormalHeader.h`](../CYLTableViewPlaceHolder/CYLRefresh/Custom/Header/CYLRefreshNormalHeader.h) |
| `CYLRefreshAnimationHeader` | [`CYLTableViewPlaceHolder/CYLRefresh/Custom/Header/CYLRefreshAnimationHeader.h`](../CYLTableViewPlaceHolder/CYLRefresh/Custom/Header/CYLRefreshAnimationHeader.h) |

<!-- docs-binding:end -->

| 中文 | English |
| --- | --- |
| 本库是 Objective-C 编写的。本页记录如何从 Swift 调用它，以及保持它对 Swift 友好的规则（规则本身在 `instructions.md` 的 “Swift examples and a Swift-friendly core”）。它对应 CYLTabBarController 的 [`docs/Swift-Guide.md`](https://github.com/ChenYilong/CYLTabBarController/blob/master/docs/Swift-Guide.md)，其中 “Objective-C → Swift 命名对照” 一节是下面命名模式的范本。 | The library is Objective-C. This page records how it is called from Swift and the rules for keeping it Swift-friendly (the rules themselves are in `instructions.md`, "Swift examples and a Swift-friendly core"). It mirrors CYLTabBarController's [`docs/Swift-Guide.md`](https://github.com/ChenYilong/CYLTabBarController/blob/master/docs/Swift-Guide.md), whose "Objective-C → Swift 命名对照" section is the model for the naming pattern below. |

## 配置 / Setup

| 中文 | English |
| --- | --- |
| 导入模块：`import CYLTableViewPlaceHolder`。示例的 Podfile 使用 `use_frameworks!`，因此不需要桥接头文件。打开 `.xcworkspace`，而不是 `.xcodeproj`。 | Import the module: `import CYLTableViewPlaceHolder`. The example Podfiles use `use_frameworks!`, so no bridging header is needed. Open the `.xcworkspace`, not the `.xcodeproj`. |

## 命名模式 / Naming pattern

| Objective-C | Swift |
| --- | --- |
| 选择器中的 `With…`、`For…`、`At…`、`Of…` / `With…`, `For…`, `At…`, `Of…` in a selector | 参数标签 / argument label |
| 枚举值 `CYLXxxStyleFoo` / enum value `CYLXxxStyleFoo` | `.foo`（去掉类型前缀 / type prefix dropped） |
| 带 `Notification` 后缀的通知名 / notification name with a `Notification` suffix | 去掉后缀的名字 / name without the suffix |
| 工厂方法 `+xWithY:` / factory `+xWithY:` | 初始化方法 `init(y:)` 或 `static` 成员 / initializer `init(y:)` or a `static` member |
| 分类成员 `cyl_name` / category member `cyl_name` | 仍为 `cyl_name`（保留前缀）/ stays `cyl_name` (the prefix is kept) |

## 已由本仓库 Swift 代码验证的写法 / Spellings verified by Swift code in this repository

| 中文 | English |
| --- | --- |
| 每一行都出现在 `Demo` CI 任务编译的 Swift 示例中（`Examples/Example`、`Examples/Example-Scenarios`、`Examples/Example-SwiftUI`、`Examples/Example-objc-01`、`Examples/Example-objc-02`）。占位图、场景、刷新图标和状态栏这几行由运行 42958376976（提交 44e16c4）确认，那次五个示例全部编译通过。 | Each row appears in a Swift example that the `Demo` CI jobs compile (`Examples/Example`, `Examples/Example-Scenarios`, `Examples/Example-SwiftUI`, `Examples/Example-objc-01`, `Examples/Example-objc-02`). The placeholder, scenario, refresh icon and status bar rows were confirmed by run 42958376976 (commit 44e16c4), where all five demos compiled. |

| Objective-C | Swift |
| --- | --- |
| `+[CYLRefreshNormalHeader headerWithRefreshingBlock:]` | `CYLRefreshNormalHeader { … }` |
| `+[CYLRefreshBackNormalFooter footerWithRefreshingBlock:]` | `CYLRefreshBackNormalFooter { … }` |
| `+[CYLRefreshAutoNormalFooter footerWithRefreshingBlock:]` | `CYLRefreshAutoNormalFooter { … }` |
| `UIScrollView.cyl_header`, `.cyl_footer` | `scrollView.cyl_header`, `scrollView.cyl_footer`（可选 / optional） |
| `-beginRefreshing`, `-endRefreshing` | `beginRefreshing()`, `endRefreshing()` |
| `Example-SwiftUI` 中的 Swift 扩展 / Swift extension in `Example-SwiftUI` | `Color(cyl_hexString:)`（系统类型上保留前缀 / prefix kept on a system type） |
| `-[CYLPlaceholderView initWithStyle:message:]`, `…Style:text:`, `…Image:text:` | `CYLPlaceholderView(style:message:)`, `(style:text:)`, `(image:text:)` |
| `-initWithItemAttributes:imageBundle:error:`, `-initWithItemContentsOfURL:imageBundle:error:` | `try CYLPlaceholderView(itemAttributes:imageBundle:)`, `try CYLPlaceholderView(itemContentsOf:imageBundle:)` |
| `-showBadgeWithStyle:value:` | `showBadge(with:value:)` |
| `+imageNameForStyle:`, `+imageForStyle:`, `+localizedTextForMessage:` | `CYLPlaceholderView.imageName(for:)`, `.image(for:)`, `.localizedText(for:)` |
| `+bundledAnimationFileNames`, `+pathForBundledAnimation:` | `CYLPlaceholderView.bundledAnimationFileNames()`, `.path(forBundledAnimation:)` |
| `-playPlaceholderAnimation` | `placeholderView.playPlaceholderAnimation()` |
| `tapInteractionEnabled` (`getter=isTapInteractionEnabled`) | `isTapInteractionEnabled` |
| `-[UITableView cyl_reloadData]`, `-cyl_placeholderViewBlock:` | `tableView.cyl_reloadData()`, `cyl_placeholderViewBlock({ … })`（用圆括号，不用尾随闭包 / parentheses, not a trailing closure） |
| `CYLTableViewPlaceHolderDelegate -makePlaceHolderView` | `@objc(makePlaceHolderView) func makePlaceHolderView() -> UIView` |
| `-[CYLPlaceholderStackView initWithScenario:actions:]`, `…Components:actions:` | `CYLPlaceholderStackView(scenario:actions:)`, `(components:actions:)` |
| `-initWithConfiguration:actions:error:`, `-initWithContentsOfURL:actions:error:` | `try CYLPlaceholderStackView(configuration:actions:)`, `try CYLPlaceholderStackView(contentsOf:actions:)` |
| `-appendComponent:` | `append(_:)` |
| `+[CYLPlaceholderComponent componentWithBundledAnimation:fallbackStyle:title:size:action:]`, `+hintComponentWithText:` | `CYLPlaceholderComponent(bundledAnimation:fallbackStyle:title:size:action:)`, `CYLPlaceholderComponent.hint(text:)` |
| `CYLPlaceholderScenarioCatalog` 类方法 / `CYLPlaceholderScenarioCatalog` class methods | `CYLPlaceholderScenarioCatalog.allScenarios`, `.localizedName(for:)`, `.localizedTitle(for:)`, `.components(for:)`, `.category(for:)`, `.permission(for:)` |
| `CYLPlaceholderLocalization.language` | `CYLPlaceholderLocalization.language` (`String?`), `.effectiveLanguage` |
| `UIViewController.cyl_statusView` (`null_resettable`) | `cyl_statusView` (`CYLPlaceholderStatusView!`) |
| `cyl_statusDisplay`, `-cyl_setStatusDisplay:animated:` | `cyl_statusDisplay`, `cyl_setStatusDisplay(_:animated:)`；选项 / options `.all`, `.statusBar`, `.placeholder` |
| `cyl_showsStatusViewWhenOffline` | `cyl_showsStatusViewWhenOffline` |
| `-cyl_applyStatusConfigurationWithContentsOfURL:error:` | `try cyl_applyStatusConfiguration(contentsOf:)` |
| `CYLPlaceholderStatusViewDelegate -statusViewClicked:` | `@objc(statusViewClicked:) func statusViewClicked(_ sender: Any)` |
| `+[CYLPlaceholderNetworkMonitor sharedMonitor]`, `+nameForStatus:` | `CYLPlaceholderNetworkMonitor.shared`, `.name(for:)` |

| 中文 | English |
| --- | --- |
| 只有在使用某个写法的 Swift 代码已在 CI 中编译通过后才添加一行。尚无 Swift 调用点的 API（例如 `exclusiveWithOtherRefresh`、`setHandler(_:for:)`、`performAction(_:)`、`componentView(for:)`、`CYLPlaceholderStatusView(frame:)` 以及状态栏的 `init(itemAttributes:)`）不列出。刷新图标的写法已移到动画刷新头和刷新尾上的 `CYLRefreshIconAnimating`（`CYLRefreshAnimationHeader` 等；MJRefresh 的 `Gif` 名称是其子类）（`setIconAnimation(bundled:size:for:)`、`setIconAnimation(filePath:size:for:)`、`setIconAnimation(attributes:for:)`、`CYLRefreshAnimationHeader.bundledIconAnimationFileNames`）；一旦 CI 在那里编译它们，就回到表中。 | Add a row only after Swift code that uses it has compiled in CI. APIs without a Swift call site yet (for example `exclusiveWithOtherRefresh`, `setHandler(_:for:)`, `performAction(_:)`, `componentView(for:)`, `CYLPlaceholderStatusView(frame:)` and `init(itemAttributes:)` of the status bar) are not listed. The refresh icon spellings moved to `CYLRefreshIconAnimating` on the animation header and footers (`CYLRefreshAnimationHeader` and friends; the MJRefresh `Gif` names are subclasses) (`setIconAnimation(bundled:size:for:)`, `setIconAnimation(filePath:size:for:)`, `setIconAnimation(attributes:for:)`, `CYLRefreshAnimationHeader.bundledIconAnimationFileNames`); they return to the table once CI compiles them there. |
| `Examples/Example-Scenarios` 中的 MJRefresh 示例移植（“Refresh” 标签页）新增了以下写法，同样等待 CI：`cyl_link(to:)` 和 `cyl_autoChangeTransparency(_:)`（`-cyl_linkTo:` 与 `-cyl_autoChangeTransparency:` 上新增的 `NS_SWIFT_NAME`）、`CYLRefreshConfig.default`（`defaultConfig` 上的 `NS_SWIFT_NAME(default)`）、`init(refreshingTarget:refreshingAction:)`、`setTitle(_:for:)`、`setRefreshingTarget(_:refreshingAction:)`、`setAnimationDisabled()`、`isAutomaticallyChangeAlpha`、`isAutomaticallyRefresh`、`isRefreshingTitleHidden`、`isCollectionViewAnimationBug`、`autoTriggerTimes`、`ignoredScrollViewContentInsetBottom`、`cyl_trailer`，以及重写 `prepare()`、`placeSubviews()` 并用 `didSet` 观察 `state` / `pullingPercent` 的子类。 | The MJRefresh example port in `Examples/Example-Scenarios` (the "Refresh" tab) adds these spellings, also pending CI: `cyl_link(to:)` and `cyl_autoChangeTransparency(_:)` (new `NS_SWIFT_NAME` on `-cyl_linkTo:` and `-cyl_autoChangeTransparency:`), `CYLRefreshConfig.default` (`NS_SWIFT_NAME(default)` on `defaultConfig`), `init(refreshingTarget:refreshingAction:)`, `setTitle(_:for:)`, `setRefreshingTarget(_:refreshingAction:)`, `setAnimationDisabled()`, `isAutomaticallyChangeAlpha`, `isAutomaticallyRefresh`, `isRefreshingTitleHidden`, `isCollectionViewAnimationBug`, `autoTriggerTimes`, `ignoredScrollViewContentInsetBottom`, `cyl_trailer`, and subclasses that override `prepare()`, `placeSubviews()` and observe `state` / `pullingPercent` with `didSet`. |

## 含下划线的协议方法 / Protocol methods that contain underscores

| 中文 | English |
| --- | --- |
| `CYLPlaceholderItemAnimationPlayableView` 声明了 `cyl_playAnimationView` 等方法，并带有 `NS_SWIFT_NAME(playAnimation())`。它们是在同一个尚未发布的改动中引入的，所以一次性为其命名是正确的。已经发布的方法不改名，也不加 `NS_SWIFT_NAME`；而是增加一个不含下划线的同级方法（见 `instructions.md` 中的规则）。 | `CYLPlaceholderItemAnimationPlayableView` declares `cyl_playAnimationView` and similar methods with `NS_SWIFT_NAME(playAnimation())`. They were introduced in the same unreleased change, so naming them once is correct. A method that has already shipped is not renamed and does not get `NS_SWIFT_NAME`; it gets an underscore-free sibling (see the rule in `instructions.md`). |

## 未完成事项 / Open items

| 中文 | English |
| --- | --- |
| 在 `docs/issue-progress.md` 的 “Swift examples and a Swift-friendly core” 下跟踪：迁移 Objective-C 示例，以及审查公开头文件（可空性覆盖、`NS_SWIFT_NAME`、带下划线的协议方法）。 | Tracked in `docs/issue-progress.md` under "Swift examples and a Swift-friendly core": migrating the Objective-C examples, and auditing the public headers (nullability coverage, `NS_SWIFT_NAME`, underscored protocol methods). |
| HUD（`CYLPlaceholderHUD`，`docs/Placeholder-HUD.md`）新增了以下写法，等待 CI：`CYLPlaceholderHUD.shared`、`CYLPlaceholderHUD(containerView:)`、`show()`、`show(status:)`、`show(progress:status:)`、`setStatus(_:)`、`showSuccess(status:)`、`showError(status:)`、`showInfo(status:)`、`show(image:status:)`、`show(components:actions:)`、`show(scenario:actions:)`、`popActivity()`、`dismiss(withDelay:)`、`isHapticsEnabled`、场景 `.hud`，以及 `CYLPlaceholderScenarioCatalog.animationFileNames(for:)` / `components(for:)`。 | The HUD (`CYLPlaceholderHUD`, `docs/Placeholder-HUD.md`) adds these spellings, pending CI: `CYLPlaceholderHUD.shared`, `CYLPlaceholderHUD(containerView:)`, `show()`, `show(status:)`, `show(progress:status:)`, `setStatus(_:)`, `showSuccess(status:)`, `showError(status:)`, `showInfo(status:)`, `show(image:status:)`, `show(components:actions:)`, `show(scenario:actions:)`, `popActivity()`, `dismiss(withDelay:)`, `isHapticsEnabled`, the scenario `.hud`, and `CYLPlaceholderScenarioCatalog.animationFileNames(for:)` / `components(for:)`. |

## 示例跟随核心（作者，2026-11-13） / Examples follow the core (owner, 2026-11-13)

| 中文 | English |
| --- | --- |
| 上面的写法是核心按 Swift 编码规范作出的选择。当核心的 Swift API 改变时（`docs/Swift-Migration.md` 中的 Swift 迁移，或任何重构），示例在同一个改动中更新为新写法；绝不为了示例的旧调用点而在核心中保留旧写法、别名或垫片。见 `instructions.md` 的 “Examples have the lowest weight”。 | The spellings above are the core's choice under the Swift coding standard. When the core's Swift API changes (the Swift migration in `docs/Swift-Migration.md`, or any refactor), the examples are updated to the new spelling in the same change; an example's old call site never keeps an old spelling, alias or shim in the core. See `instructions.md`, "Examples have the lowest weight". |
| 更多 Swift 写法：`tableView.cyl_placeholderView`、`placeholder.setAnimationFile(_:)`、`stack.imageView`、`stack.titleLabel`、`stack.hintLabel`、`stack.button`、`CYLPlaceholderComponent.text(_:fontSize:color:)`、`CYLPlaceholderConfigurationError`（`CYLPlaceholderConfigurationErrorDomain` 的 NS_ERROR_ENUM）、`CYLPlaceholderItemImages`、`CYLPlaceholderItemAnimationDuration`，以及 `CYLRefreshFlyHeader.mountainView` / `flyView` / `floatView`。 | More Swift spellings: `tableView.cyl_placeholderView`, `placeholder.setAnimationFile(_:)`, `stack.imageView`, `stack.titleLabel`, `stack.hintLabel`, `stack.button`, `CYLPlaceholderComponent.text(_:fontSize:color:)`, `CYLPlaceholderConfigurationError` (the NS_ERROR_ENUM of `CYLPlaceholderConfigurationErrorDomain`), `CYLPlaceholderItemImages`, `CYLPlaceholderItemAnimationDuration`, and `CYLRefreshFlyHeader.mountainView` / `flyView` / `floatView`. |
| CYLRefresh 共享的状态与图片 API 在 Swift 中写作：`CYLRefreshStateHeader`、`CYLRefreshAutoStateFooter` 和 `CYLRefreshStateTrailer` 上的 `header.title(for: .pulling)`（与 `CYLRefreshBackStateFooter` 相同）、`control.cyl_setStateTitle(_:for:)` / `control.cyl_stateTitle(for:)`、`control.cyl_setAnimationImages(_:duration:for:)` / `control.cyl_animationImages(for:)`、`control.cyl_setIconAnimation(filePath:size:for:)`、`control.cyl_setBundledIconAnimation(_:size:for:)`，以及 `footer.cyl_updateNoMoreDataImage(_:)` / `footer.cyl_placeNoMoreDataImage(besideLabel:inset:size:)`。 | CYLRefresh's shared state and image API is spelled in Swift as: `header.title(for: .pulling)` on `CYLRefreshStateHeader`, `CYLRefreshAutoStateFooter` and `CYLRefreshStateTrailer` (as on `CYLRefreshBackStateFooter`), `control.cyl_setStateTitle(_:for:)` / `control.cyl_stateTitle(for:)`, `control.cyl_setAnimationImages(_:duration:for:)` / `control.cyl_animationImages(for:)`, `control.cyl_setIconAnimation(filePath:size:for:)`, `control.cyl_setBundledIconAnimation(_:size:for:)`, and `footer.cyl_updateNoMoreDataImage(_:)` / `footer.cyl_placeNoMoreDataImage(besideLabel:inset:size:)`. |
