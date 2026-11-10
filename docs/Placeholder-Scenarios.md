# 场景化占位 / Scenario placeholders

<!-- bound-classes: CYLPlaceholderStackView, CYLPlaceholderScenario, CYLPlaceholderLocalization -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [结构](#结构--structure) | [Structure](#结构--structure) |
| [场景表](#场景表--scenario-table) | [Scenario table](#场景表--scenario-table) |
| [用法](#用法--usage) | [Usage](#用法--usage) |
| [Swift 写法](#swift-写法--swift-spellings) | [Swift spellings](#swift-写法--swift-spellings) |
| [本地化](#本地化--localization) | [Localization](#本地化--localization) |
| [已知限制](#已知限制--known-limits) | [Known limits](#已知限制--known-limits) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| `CYLPlaceholderStackView` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h) |
| `CYLPlaceholderScenario` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderScenario.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderScenario.h) |
| `CYLPlaceholderLocalization` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderLocalization.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderLocalization.h) |

<!-- docs-binding:end -->

## 结构 / Structure

| 中文 | English |
| --- | --- |
| `CYLPlaceholderStackView` 是一个视图，内部用竖向、居中的 `UIStackView` 堆叠组件。每个组件都是一个 `CYLPlaceholderView`（图标、标题或两者兼有），由 `CYLPlaceholderComponent` 描述：item 属性加一个可选的点击动作。第一个组件是保留组件（经典的图标加标题），一定存在；属性无效时回退为默认图标和标题。 | `CYLPlaceholderStackView` is a view that stacks components in a vertical, centered `UIStackView`. Each component is a `CYLPlaceholderView` (an icon, a title or both), described by a `CYLPlaceholderComponent`: item attributes plus an optional tap action. The first component is the reserved one (the classic icon and title) and always exists; invalid attributes fall back to the default icon and title. |
| 场景只是一份组件清单：`CYLPlaceholderScenarioCatalog` 根据 `CYLPlaceholderScenario` 返回组件、背景点击动作、本地化名称和对应的 README 截图编号。视图不知道任何具体场景，目录也不创建视图（高内聚、低耦合）；应用可以不用目录，直接传入自己的组件。 | A scenario is only a list of components: `CYLPlaceholderScenarioCatalog` returns, for a `CYLPlaceholderScenario`, its components, its background action, its localized name and the README screenshot numbers it reproduces. The view knows no particular scenario and the catalog creates no view (high cohesion, low coupling); an app can skip the catalog and pass its own components. |
| 动作是 `CYLPlaceholderAction`（可扩展的字符串枚举，内置 `Retry`、`ContactSupport`、`OpenSettings`、`GoShopping`、`Done`，应用可定义自己的值）。处理代码在初始化时通过 `actions` 传入，之后可以用 `setHandler:forAction:` 修改，在主线程执行；没有处理代码的动作什么都不做。可点击的组件带按钮特征，供 VoiceOver 使用；`backgroundAction` 让点击组件以外的区域也执行一个动作（“点击屏幕重新加载”）。 | An action is a `CYLPlaceholderAction` (an extensible string enum with `Retry`, `ContactSupport`, `OpenSettings`, `GoShopping` and `Done` built in; apps may define their own values). Handlers are passed at creation through `actions`, can be changed later with `setHandler:forAction:`, and run on the main thread; an action without a handler does nothing. Tappable components carry the button trait for VoiceOver; `backgroundAction` makes a tap outside the components perform an action too ("tap the screen to reload"). |

## 场景表 / Scenario table

| 中文 | English |
| --- | --- |
| 前 14 个场景归纳自 README 的 43 张截图，每张截图恰好对应一个场景（`Tests/CYLPlaceholderScenarioTests.m` 检查）；后 13 个是常见业务场景。27 个场景中 26 个使用内置动画（`TextOnly` 没有图标）。 | The first 14 scenarios are distilled from the README's 43 screenshots, each screenshot mapping to exactly one scenario (checked by `Tests/CYLPlaceholderScenarioTests.m`); the last 13 are common business cases. 26 of the 27 scenarios use a built-in animation (`TextOnly` has no icon). |

| 场景（Objective-C / Swift） | 组件 | README 截图 |
| --- | --- | --- |
| `CYLPlaceholderScenarioNetworkUnavailable` / `.networkUnavailable` | 图标加标题 | 04, 05, 06, 25, 36 |
| `CYLPlaceholderScenarioNoContent` / `.noContent` | 空列表的图标加标题 | 07, 09, 10 |
| `CYLPlaceholderScenarioTapToReload` / `.tapToReload` | 图标加标题；点击任意处重试 | 13, 14, 15, 24, 26, 28, 31, 32, 37, 42, 43 |
| `CYLPlaceholderScenarioLoadFailedWithHint` / `.loadFailedWithHint` | 图标、标题加提示 | 21, 22, 27, 29 |
| `CYLPlaceholderScenarioTapToReconnect` / `.tapToReconnect` | 图标、标题加提示；点击任意处重试 | 08 |
| `CYLPlaceholderScenarioRetryButton` / `.retryButton` | 图标、标题加实心“重试”按钮（携程） | 01, 02, 11, 19, 20 |
| `CYLPlaceholderScenarioRetryOutlinedButton` / `.retryOutlinedButton` | 图标、标题加描边“重试”按钮 | 33, 38, 39 |
| `CYLPlaceholderScenarioRetryWithHint` / `.retryWithHint` | 图标、标题、提示加描边“重新加载”按钮 | 16, 23, 40 |
| `CYLPlaceholderScenarioRetryOrContactSupport` / `.retryOrContactSupport` | 图标加标题、“重试”按钮、“或”分隔符、“联系客服”按钮：四个以上组件、两个动作（携程） | 03 |
| `CYLPlaceholderScenarioIllustrationRetry` / `.illustrationRetry` | 只有插图，下面是带背景图和圆角的胶囊形“点击重试”标题（什么值得买） | 18 |
| `CYLPlaceholderScenarioRefreshIcon` / `.refreshIcon` | 图标加标题，下面是可点击的刷新图标 | 12 |
| `CYLPlaceholderScenarioTitleAboveIllustration` / `.titleAboveIllustration` | 标题在插图上方；点击任意处重试 | 17 |
| `CYLPlaceholderScenarioTextOnly` / `.textOnly` | 只有标题和提示，没有图标；点击任意处重试 | 30, 41 |
| `CYLPlaceholderScenarioTapMeRetry` / `.tapMeRetry` | “点我”、箭头、实心“重新加载”按钮和吉祥物 | 34, 35 |
| `CYLPlaceholderScenarioNoSearchResults` / `.noSearchResults` | 图标、标题加提示 | — |
| `CYLPlaceholderScenarioEmptyCart` / `.emptyCart` | 图标、标题加“去逛逛”按钮 | — |
| `CYLPlaceholderScenarioNoOrders` / `.noOrders` | 图标、标题加“去逛逛”按钮 | — |
| `CYLPlaceholderScenarioNoFavorites` / `.noFavorites` | 图标、标题加提示 | — |
| `CYLPlaceholderScenarioNoMessages` / `.noMessages` | 图标加标题 | — |
| `CYLPlaceholderScenarioNoNotifications` / `.noNotifications` | 图标、标题加提示 | — |
| `CYLPlaceholderScenarioNoPermission` / `.noPermission` | 图标、标题、提示加“去设置”按钮 | — |
| `CYLPlaceholderScenarioLocationOff` / `.locationOff` | 图标、标题加“去设置”按钮 | — |
| `CYLPlaceholderScenarioServerError` / `.serverError` | 图标、标题、提示加“重试”按钮 | — |
| `CYLPlaceholderScenarioSyncFailed` / `.syncFailed` | 图标、标题加“重试”按钮 | — |
| `CYLPlaceholderScenarioLoading` / `.loading` | 加载动画加标题 | — |
| `CYLPlaceholderScenarioUploading` / `.uploading` | 上传动画（GIF）加标题 | — |
| `CYLPlaceholderScenarioSuccess` / `.success` | 成功动画、标题加“完成”按钮 | — |

| Scenario (Objective-C / Swift) | Components | README screenshots |
| --- | --- | --- |
| `CYLPlaceholderScenarioNetworkUnavailable` / `.networkUnavailable` | Icon and title | 04, 05, 06, 25, 36 |
| `CYLPlaceholderScenarioNoContent` / `.noContent` | Icon and title for an empty list | 07, 09, 10 |
| `CYLPlaceholderScenarioTapToReload` / `.tapToReload` | Icon and title; tapping anywhere retries | 13, 14, 15, 24, 26, 28, 31, 32, 37, 42, 43 |
| `CYLPlaceholderScenarioLoadFailedWithHint` / `.loadFailedWithHint` | Icon, title and a hint | 21, 22, 27, 29 |
| `CYLPlaceholderScenarioTapToReconnect` / `.tapToReconnect` | Icon, title and a hint; tapping anywhere retries | 08 |
| `CYLPlaceholderScenarioRetryButton` / `.retryButton` | Icon, title and a filled "Retry" button (Ctrip) | 01, 02, 11, 19, 20 |
| `CYLPlaceholderScenarioRetryOutlinedButton` / `.retryOutlinedButton` | Icon, title and an outlined "Retry" button | 33, 38, 39 |
| `CYLPlaceholderScenarioRetryWithHint` / `.retryWithHint` | Icon, title, a hint and an outlined "Reload" button | 16, 23, 40 |
| `CYLPlaceholderScenarioRetryOrContactSupport` / `.retryOrContactSupport` | Icon and title, a "Retry" button, an "or" separator and a "Contact support" button: four or more components and two actions (Ctrip) | 03 |
| `CYLPlaceholderScenarioIllustrationRetry` / `.illustrationRetry` | An illustration only, then a capsule "Tap to retry" title with a background image and rounded corners (SMZDM) | 18 |
| `CYLPlaceholderScenarioRefreshIcon` / `.refreshIcon` | Icon and title, then a tappable refresh icon | 12 |
| `CYLPlaceholderScenarioTitleAboveIllustration` / `.titleAboveIllustration` | A title above an illustration; tapping anywhere retries | 17 |
| `CYLPlaceholderScenarioTextOnly` / `.textOnly` | A title and a hint, no icon; tapping anywhere retries | 30, 41 |
| `CYLPlaceholderScenarioTapMeRetry` / `.tapMeRetry` | "Tap me", an arrow, a filled "Reload" button and a mascot | 34, 35 |
| `CYLPlaceholderScenarioNoSearchResults` / `.noSearchResults` | Icon, title and a hint | — |
| `CYLPlaceholderScenarioEmptyCart` / `.emptyCart` | Icon, title and a "Go shopping" button | — |
| `CYLPlaceholderScenarioNoOrders` / `.noOrders` | Icon, title and a "Go shopping" button | — |
| `CYLPlaceholderScenarioNoFavorites` / `.noFavorites` | Icon, title and a hint | — |
| `CYLPlaceholderScenarioNoMessages` / `.noMessages` | Icon and title | — |
| `CYLPlaceholderScenarioNoNotifications` / `.noNotifications` | Icon, title and a hint | — |
| `CYLPlaceholderScenarioNoPermission` / `.noPermission` | Icon, title, a hint and an "Open Settings" button | — |
| `CYLPlaceholderScenarioLocationOff` / `.locationOff` | Icon, title and an "Open Settings" button | — |
| `CYLPlaceholderScenarioServerError` / `.serverError` | Icon, title, a hint and a "Retry" button | — |
| `CYLPlaceholderScenarioSyncFailed` / `.syncFailed` | Icon, title and a "Retry" button | — |
| `CYLPlaceholderScenarioLoading` / `.loading` | Loading animation and title | — |
| `CYLPlaceholderScenarioUploading` / `.uploading` | Uploading animation (GIF) and title | — |
| `CYLPlaceholderScenarioSuccess` / `.success` | Success animation, title and a "Done" button | — |

## 用法 / Usage

```swift
// [CN] 场景：组件由核心层定义，点击事件在初始化时指定
// [EN] A scenario: the core defines the components; the tap handlers are given at creation
let placeholder = CYLPlaceholderStackView(scenario: .retryOrContactSupport, actions: [
    .retry: { [weak self] _, _ in self?.reload() },
    .contactSupport: { [weak self] _, _ in self?.showSupport() },
])

// [CN] 自己组合组件：插图、提示、胶囊按钮
// [EN] Custom components: an illustration, a hint and a capsule button
let custom = CYLPlaceholderStackView(components: [
    CYLPlaceholderComponent(bundledAnimation: "CYLPlaceholderNoInternet.json", fallbackStyle: .noInternet,
                            title: nil, size: CGSize(width: 120, height: 120), action: nil),
    CYLPlaceholderComponent.hint(text: "…"),
    CYLPlaceholderComponent.button(title: "…", style: .capsule, action: .retry),
], actions: [.retry: { _, _ in }])
custom.append(CYLPlaceholderComponent.separator(text: "…"))
custom.setHandler({ _, _ in }, for: .contactSupport)
```

## Swift 写法 / Swift spellings

| 中文 | English |
| --- | --- |
| 以下新声明都带有 `NS_SWIFT_NAME`，Swift 拼写由此确定；`Examples/Example-Scenarios` 使用了其中大部分，经 CI 编译后再写入 `docs/Swift-Guide.md` 的“已验证”表。 | The new declarations below carry `NS_SWIFT_NAME`, which fixes their Swift spellings; `Examples/Example-Scenarios` uses most of them, and they move into the "verified" table of `docs/Swift-Guide.md` once CI has compiled it. |

| Objective-C | Swift |
| --- | --- |
| `-initWithScenario:actions:` | `CYLPlaceholderStackView(scenario:actions:)` |
| `-initWithComponents:actions:` | `CYLPlaceholderStackView(components:actions:)` |
| `-appendComponent:` / `-appendComponentView:action:spacingBefore:` | `append(_:)` / `append(_:action:spacingBefore:)` |
| `-setHandler:forAction:` / `-componentViewForAction:` / `-performAction:` | `setHandler(_:for:)` / `componentView(for:)` / `performAction(_:)` |
| `+componentWithAttributes:action:` | `CYLPlaceholderComponent(attributes:action:)` |
| `+componentWithBundledAnimation:fallbackStyle:title:size:action:` | `CYLPlaceholderComponent(bundledAnimation:fallbackStyle:title:size:action:)` |
| `+hintComponentWithText:` / `+buttonComponentWithTitle:style:action:` / `+separatorComponentWithText:` | `hint(text:)` / `button(title:style:action:)` / `separator(text:)` |
| `+componentsForScenario:` / `+backgroundActionForScenario:` / `+localizedNameForScenario:` | `components(for:)` / `backgroundAction(for:)` / `localizedName(for:)` |
| `+readmeScreenshotNumbersForScenario:` / `+localizedTitleForAction:` | `readmeScreenshotNumbers(for:)` / `localizedTitle(for:)` |
| `CYLPlaceholderActionRetry` … | `.retry`, `.contactSupport`, `.openSettings`, `.goShopping`, `.done` |
| `CYLPlaceholderLocalizationLanguageDidChangeNotification` | `CYLPlaceholderLocalization.languageDidChangeNotification` |
| `+localizedStringForKey:fallback:` | `CYLPlaceholderLocalization.localizedString(forKey:fallback:)` |

## 本地化 / Localization

| 中文 | English |
| --- | --- |
| 场景的标题、提示、按钮和名称都在核心资源包的 `Localizable.strings` 中（en、zh-Hans、zh-Hant、ja、ko、ru、uk），通过核心层的查找宏 `CYLPlaceholderLocalizedString(key, fallback)` 读取。设置 `CYLPlaceholderLocalization.language` 可在运行时切换语言（`nil` 跟随系统，不支持的语言先回退到基础语言，再回退到英语）；已创建的视图不会自动更新，收到 `CYLPlaceholderLocalizationLanguageDidChangeNotification` 后重新创建即可。聚合 Demo 用同一个通知机制演示：切换语言后整个界面重建。 | Scenario titles, hints, buttons and names live in the core bundle's `Localizable.strings` (en, zh-Hans, zh-Hant, ja, ko, ru, uk) and are read through the core lookup macro `CYLPlaceholderLocalizedString(key, fallback)`. Set `CYLPlaceholderLocalization.language` to switch the language at run time (`nil` follows the system; an unsupported language falls back to its base language, then to English); views already created do not update, so recreate them after `CYLPlaceholderLocalizationLanguageDidChangeNotification`. The aggregate demo shows this: the whole interface is rebuilt after a language change. |

## 已知限制 / Known limits

| 中文 | English |
| --- | --- |
| 组件是 `CYLPlaceholderView`，按钮由标题装饰键绘制，不是 `UIButton`：没有按下高亮（点击时有一次透明度闪烁），不支持 `UIButton.Configuration`。 | Components are `CYLPlaceholderView`s and buttons are drawn with the title chrome keys, not `UIButton`s: there is no pressed highlight (a tap flashes the alpha once), and `UIButton.Configuration` is not supported. |
| 切换语言不会更新已创建的视图；需要重新创建。 | A language change does not update views already created; recreate them. |
| 日、韩、俄、乌克兰文译文未经母语者审校；动画的实际渲染（包括 Lottie 线条图标的 `**.Color` 着色）需在模拟器中人工查看，CI 只截取首页。 | The Japanese, Korean, Russian and Ukrainian translations have not been reviewed by native speakers; actual animation rendering (including the `**.Color` tint of the Lottie line icons) needs a manual look in the simulator, as CI only captures the first screen. |
