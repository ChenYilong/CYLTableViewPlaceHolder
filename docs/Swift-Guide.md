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

Each row appears in a Swift example that the `Demo` CI jobs compile (`Examples/Example-SwiftUI/`,
`Examples/Example-objc-01/`).

| Objective-C | Swift |
| --- | --- |
| `+[CYLRefreshNormalHeader headerWithRefreshingBlock:]` | `CYLRefreshNormalHeader { … }` |
| `+[CYLRefreshBackNormalFooter footerWithRefreshingBlock:]` | `CYLRefreshBackNormalFooter { … }` |
| `+[CYLRefreshAutoNormalFooter footerWithRefreshingBlock:]` | `CYLRefreshAutoNormalFooter { … }` |
| `UIScrollView.cyl_header`, `.cyl_footer` | `scrollView.cyl_header`, `scrollView.cyl_footer` (optional) |
| `-beginRefreshing`, `-endRefreshing` | `beginRefreshing()`, `endRefreshing()` |
| Swift extension in `Example-SwiftUI` | `Color(cyl_hexString:)` (prefix kept on a system type) |

Add a row only after Swift code that uses it has compiled in CI. Other APIs (placeholders, item attributes,
newer refresh options such as `exclusiveWithOtherRefresh`) have no Swift call site yet and are not listed.

## Protocol methods that contain underscores

`CYLPlaceholderItemAnimationPlayableView` declares `cyl_playAnimationView` and similar methods with
`NS_SWIFT_NAME(playAnimation())`. They were introduced in the same unreleased change, so naming them once is
correct. A method that has already shipped is not renamed and does not get `NS_SWIFT_NAME`; it gets an
underscore-free sibling (see the rule in `instructions.md`).

## Open items

Tracked in `docs/issue-progress.md` under "Swift examples and a Swift-friendly core": migrating the Objective-C
examples, and auditing the public headers (nullability coverage, `NS_SWIFT_NAME`, underscored protocol methods).
