# Using CYLTableViewPlaceHolder from Swift

The library is Objective-C. This page records how it is called from Swift and the rules for keeping it
Swift-friendly (the rules themselves are in `instructions.md`, "Swift examples and a Swift-friendly core").
It mirrors CYLTabBarController's
[`docs/Swift-Guide.md`](https://github.com/ChenYilong/CYLTabBarController/blob/master/docs/Swift-Guide.md),
whose "Objective-C → Swift 命名对照" section is the model for the naming pattern below.

## Setup

Import the module: `import CYLTableViewPlaceHolder`. The example Podfiles use `use_frameworks!`, so no bridging
header is needed. Open the `.xcworkspace`, not the `.xcodeproj`.

## Naming pattern

| Objective-C | Swift |
| --- | --- |
| `With…`, `For…`, `At…`, `Of…` in a selector | argument label |
| enum value `CYLXxxStyleFoo` | `.foo` (type prefix dropped) |
| notification name with a `Notification` suffix | name without the suffix |
| factory `+xWithY:` | initializer `init(y:)` or a `static` member |
| category member `cyl_name` | stays `cyl_name` (the prefix is kept) |

## Spellings verified by Swift code in this repository

Each row appears in a Swift example that the `Demo` CI jobs compile (`Examples/Example`, `Examples/Example-Scenarios`,
`Examples/Example-SwiftUI`, `Examples/Example-objc-01`, `Examples/Example-objc-02`). The placeholder, scenario, refresh
icon and status bar rows were confirmed by run 42958376976 (commit 44e16c4), where all five demos compiled.

| Objective-C | Swift |
| --- | --- |
| `+[CYLRefreshNormalHeader headerWithRefreshingBlock:]` | `CYLRefreshNormalHeader { … }` |
| `+[CYLRefreshBackNormalFooter footerWithRefreshingBlock:]` | `CYLRefreshBackNormalFooter { … }` |
| `+[CYLRefreshAutoNormalFooter footerWithRefreshingBlock:]` | `CYLRefreshAutoNormalFooter { … }` |
| `UIScrollView.cyl_header`, `.cyl_footer` | `scrollView.cyl_header`, `scrollView.cyl_footer` (optional) |
| `-beginRefreshing`, `-endRefreshing` | `beginRefreshing()`, `endRefreshing()` |
| Swift extension in `Example-SwiftUI` | `Color(cyl_hexString:)` (prefix kept on a system type) |
| `-[CYLPlaceholderView initWithStyle:message:]`, `…Style:text:`, `…Image:text:` | `CYLPlaceholderView(style:message:)`, `(style:text:)`, `(image:text:)` |
| `-initWithItemAttributes:imageBundle:error:`, `-initWithItemContentsOfURL:imageBundle:error:` | `try CYLPlaceholderView(itemAttributes:imageBundle:)`, `try CYLPlaceholderView(itemContentsOf:imageBundle:)` |
| `-showBadgeWithStyle:value:` | `showBadge(with:value:)` |
| `+imageNameForStyle:`, `+imageForStyle:`, `+localizedTextForMessage:` | `CYLPlaceholderView.imageName(for:)`, `.image(for:)`, `.localizedText(for:)` |
| `+bundledAnimationFileNames`, `+pathForBundledAnimation:` | `CYLPlaceholderView.bundledAnimationFileNames()`, `.path(forBundledAnimation:)` |
| `-playPlaceholderAnimation` | `placeholderView.playPlaceholderAnimation()` |
| `tapInteractionEnabled` (`getter=isTapInteractionEnabled`) | `isTapInteractionEnabled` |
| `-[UITableView cyl_reloadData]`, `-cyl_placeholderViewBlock:` | `tableView.cyl_reloadData()`, `cyl_placeholderViewBlock({ … })` (parentheses, not a trailing closure) |
| `CYLTableViewPlaceHolderDelegate -makePlaceHolderView` | `@objc(makePlaceHolderView) func makePlaceHolderView() -> UIView` |
| `-[CYLPlaceholderStackView initWithScenario:actions:]`, `…Components:actions:` | `CYLPlaceholderStackView(scenario:actions:)`, `(components:actions:)` |
| `-initWithConfiguration:actions:error:`, `-initWithContentsOfURL:actions:error:` | `try CYLPlaceholderStackView(configuration:actions:)`, `try CYLPlaceholderStackView(contentsOf:actions:)` |
| `-appendComponent:` | `append(_:)` |
| `+[CYLPlaceholderComponent componentWithBundledAnimation:fallbackStyle:title:size:action:]`, `+hintComponentWithText:` | `CYLPlaceholderComponent(bundledAnimation:fallbackStyle:title:size:action:)`, `CYLPlaceholderComponent.hint(text:)` |
| `CYLPlaceholderScenarioCatalog` class methods | `CYLPlaceholderScenarioCatalog.allScenarios`, `.localizedName(for:)`, `.localizedTitle(for:)`, `.components(for:)`, `.category(for:)`, `.permission(for:)` |
| `CYLPlaceholderLocalization.language` | `CYLPlaceholderLocalization.language` (`String?`), `.effectiveLanguage` |
| `UIViewController.cyl_statusView` (`null_resettable`) | `cyl_statusView` (`CYLPlaceholderStatusView!`) |
| `cyl_statusDisplay`, `-cyl_setStatusDisplay:animated:` | `cyl_statusDisplay`, `cyl_setStatusDisplay(_:animated:)`; options `.all`, `.statusBar`, `.placeholder` |
| `cyl_showsStatusViewWhenOffline` | `cyl_showsStatusViewWhenOffline` |
| `-cyl_applyStatusConfigurationWithContentsOfURL:error:` | `try cyl_applyStatusConfiguration(contentsOf:)` |
| `CYLPlaceholderStatusViewDelegate -statusViewClicked:` | `@objc(statusViewClicked:) func statusViewClicked(_ sender: Any)` |
| `+[CYLPlaceholderNetworkMonitor sharedMonitor]`, `+nameForStatus:` | `CYLPlaceholderNetworkMonitor.shared`, `.name(for:)` |

Add a row only after Swift code that uses it has compiled in CI. APIs without a Swift call site yet (for example
`exclusiveWithOtherRefresh`, `setHandler(_:for:)`, `performAction(_:)`, `componentView(for:)`,
`CYLPlaceholderStatusView(frame:)` and `init(itemAttributes:)` of the status bar) are not listed. The refresh icon
spellings moved to `CYLRefreshIconAnimating` on the animation header and footers (`CYLRefreshAnimationHeader` and friends; the MJRefresh `Gif` names are subclasses) (`setIconAnimation(bundled:size:for:)`,
`setIconAnimation(filePath:size:for:)`, `setIconAnimation(attributes:for:)`,
`CYLRefreshAnimationHeader.bundledIconAnimationFileNames`); they return to the table once CI compiles them there.

## Protocol methods that contain underscores

`CYLPlaceholderItemAnimationPlayableView` declares `cyl_playAnimationView` and similar methods with
`NS_SWIFT_NAME(playAnimation())`. They were introduced in the same unreleased change, so naming them once is
correct. A method that has already shipped is not renamed and does not get `NS_SWIFT_NAME`; it gets an
underscore-free sibling (see the rule in `instructions.md`).

## Open items

Tracked in `docs/issue-progress.md` under "Swift examples and a Swift-friendly core": migrating the Objective-C
examples, and auditing the public headers (nullability coverage, `NS_SWIFT_NAME`, underscored protocol methods).
