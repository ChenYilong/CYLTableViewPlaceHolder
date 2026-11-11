# 场景化占位 / Scenario placeholders

<!-- bound-classes: CYLPlaceholderStackView, CYLPlaceholderScenario, CYLPlaceholderLocalization -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [结构](#结构--structure) | [Structure](#结构--structure) |
| [场景表](#场景表--scenario-table) | [Scenario table](#场景表--scenario-table) |
| [权限缺失与场景类别](#权限缺失与场景类别--missing-permissions-and-scenario-categories) | [Missing permissions and scenario categories](#权限缺失与场景类别--missing-permissions-and-scenario-categories) |
| [组件点击事件与交互开关](#组件点击事件与交互开关--component-tap-events-and-the-interaction-switch) | [Component tap events and the interaction switch](#组件点击事件与交互开关--component-tap-events-and-the-interaction-switch) |
| [动画播放策略](#动画播放策略--animation-playback) | [Animation playback](#动画播放策略--animation-playback) |
| [配置文件初始化](#配置文件初始化--configuration-files) | [Configuration files](#配置文件初始化--configuration-files) |
| [用法](#用法--usage) | [Usage](#用法--usage) |
| [Swift 写法](#swift-写法--swift-spellings) | [Swift spellings](#swift-写法--swift-spellings) |
| [本地化](#本地化--localization) | [Localization](#本地化--localization) |
| [无障碍与资源查找](#无障碍与资源查找--accessibility-and-resource-lookups) | [Accessibility and resource lookups](#无障碍与资源查找--accessibility-and-resource-lookups) |
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
| 共 35 个场景。README 的 43 张截图归纳为 15 个场景（14 种结构 + 截图 #20 的定位权限缺失），每张截图恰好对应一个场景（`Tests/CYLPlaceholderScenarioTests.m` 检查）；其余 20 个是常见业务场景，其中 8 个是权限缺失。35 个场景中 34 个使用内置动画（`TextOnly` 没有图标）。下表按枚举顺序排列。 | 35 scenarios in all. The README's 43 screenshots are distilled into 15 scenarios (14 structures plus the missing location permission of screenshot #20), each screenshot mapping to exactly one scenario (checked by `Tests/CYLPlaceholderScenarioTests.m`); the other 20 are common business cases, 8 of them missing permissions. 34 of the 35 scenarios use a built-in animation (`TextOnly` has no icon). The tables follow the enum order. |

| 场景（Objective-C / Swift） | 组件 | README 截图 |
| --- | --- | --- |
| `CYLPlaceholderScenarioNetworkUnavailable` / `.networkUnavailable` | 图标加标题 | 04, 05, 06, 25, 36 |
| `CYLPlaceholderScenarioNoContent` / `.noContent` | 空列表的图标加标题 | 07, 09, 10 |
| `CYLPlaceholderScenarioTapToReload` / `.tapToReload` | 图标加标题；点击任意处重试 | 13, 14, 15, 24, 26, 28, 31, 32, 37, 42, 43 |
| `CYLPlaceholderScenarioLoadFailedWithHint` / `.loadFailedWithHint` | 图标、标题加提示 | 21, 22, 27, 29 |
| `CYLPlaceholderScenarioTapToReconnect` / `.tapToReconnect` | 图标、标题加提示；点击任意处重试 | 08 |
| `CYLPlaceholderScenarioRetryButton` / `.retryButton` | 图标、标题加实心“重试”按钮（携程） | 01, 02, 11, 19 |
| `CYLPlaceholderScenarioRetryOutlinedButton` / `.retryOutlinedButton` | 图标、标题加描边“重试”按钮 | 33, 38, 39 |
| `CYLPlaceholderScenarioRetryWithHint` / `.retryWithHint` | 图标、标题、提示加描边“重新加载”按钮 | 16, 23, 40 |
| `CYLPlaceholderScenarioRetryOrContactSupport` / `.retryOrContactSupport` | 图标加标题、“重试”按钮、“或”分隔符、“联系客服”按钮：四个以上组件、两个动作（携程） | 03 |
| `CYLPlaceholderScenarioIllustrationRetry` / `.illustrationRetry` | 只有插图，下面是带背景图和圆角的胶囊形“点击重试”标题（什么值得买） | 18 |
| `CYLPlaceholderScenarioRefreshIcon` / `.refreshIcon` | 图标加标题，下面是可点击的刷新图标 | 12 |
| `CYLPlaceholderScenarioTitleAboveIllustration` / `.titleAboveIllustration` | 标题在插图上方；点击任意处重试 | 17 |
| `CYLPlaceholderScenarioTextOnly` / `.textOnly` | 只有标题和提示，没有图标；点击任意处重试 | 30, 41 |
| `CYLPlaceholderScenarioTapMeRetry` / `.tapMeRetry` | “点我”、箭头、实心“重新加载”按钮和离线云图标 | 34, 35 |
| `CYLPlaceholderScenarioLocationPermissionDenied` / `.locationPermissionDenied` | 定位权限缺失（不是网络失败）：定位图标、标题、提示、“去设置”和“手动选择地址” | 20 |
| `CYLPlaceholderScenarioNoSearchResults` / `.noSearchResults` | 图标、标题加提示 | — |
| `CYLPlaceholderScenarioEmptyCart` / `.emptyCart` | 图标、标题加“去逛逛”按钮 | — |
| `CYLPlaceholderScenarioNoOrders` / `.noOrders` | 图标、标题加“去逛逛”按钮 | — |
| `CYLPlaceholderScenarioNoFavorites` / `.noFavorites` | 图标、标题加提示 | — |
| `CYLPlaceholderScenarioNoMessages` / `.noMessages` | 图标加标题 | — |
| `CYLPlaceholderScenarioNoNotifications` / `.noNotifications` | 图标、标题加提示 | — |
| `CYLPlaceholderScenarioNoPermission` / `.noPermission` | 通用权限缺失：锁图标、标题、提示加“去设置”按钮 | — |
| `CYLPlaceholderScenarioCameraPermissionDenied` / `.cameraPermissionDenied` | 相机权限缺失：相机图标、标题、提示加“去设置” | — |
| `CYLPlaceholderScenarioPhotoLibraryPermissionDenied` / `.photoLibraryPermissionDenied` | 相册权限缺失：同上，相册图标 | — |
| `CYLPlaceholderScenarioMicrophonePermissionDenied` / `.microphonePermissionDenied` | 麦克风权限缺失：同上，麦克风图标 | — |
| `CYLPlaceholderScenarioContactsPermissionDenied` / `.contactsPermissionDenied` | 通讯录权限缺失：同上，联系人图标 | — |
| `CYLPlaceholderScenarioCalendarPermissionDenied` / `.calendarPermissionDenied` | 日历权限缺失：同上，日历图标 | — |
| `CYLPlaceholderScenarioBluetoothPermissionDenied` / `.bluetoothPermissionDenied` | 蓝牙权限缺失：同上，蓝牙图标 | — |
| `CYLPlaceholderScenarioNotificationPermissionDenied` / `.notificationPermissionDenied` | 通知权限缺失：同上，通知图标 | — |
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
| `CYLPlaceholderScenarioRetryButton` / `.retryButton` | Icon, title and a filled "Retry" button (Ctrip) | 01, 02, 11, 19 |
| `CYLPlaceholderScenarioRetryOutlinedButton` / `.retryOutlinedButton` | Icon, title and an outlined "Retry" button | 33, 38, 39 |
| `CYLPlaceholderScenarioRetryWithHint` / `.retryWithHint` | Icon, title, a hint and an outlined "Reload" button | 16, 23, 40 |
| `CYLPlaceholderScenarioRetryOrContactSupport` / `.retryOrContactSupport` | Icon and title, a "Retry" button, an "or" separator and a "Contact support" button: four or more components and two actions (Ctrip) | 03 |
| `CYLPlaceholderScenarioIllustrationRetry` / `.illustrationRetry` | An illustration only, then a capsule "Tap to retry" title with a background image and rounded corners (SMZDM) | 18 |
| `CYLPlaceholderScenarioRefreshIcon` / `.refreshIcon` | Icon and title, then a tappable refresh icon | 12 |
| `CYLPlaceholderScenarioTitleAboveIllustration` / `.titleAboveIllustration` | A title above an illustration; tapping anywhere retries | 17 |
| `CYLPlaceholderScenarioTextOnly` / `.textOnly` | A title and a hint, no icon; tapping anywhere retries | 30, 41 |
| `CYLPlaceholderScenarioTapMeRetry` / `.tapMeRetry` | "Tap me", an arrow, a filled "Reload" button and an offline cloud icon | 34, 35 |
| `CYLPlaceholderScenarioLocationPermissionDenied` / `.locationPermissionDenied` | Permission missing (not a network failure): location icon, title, a hint, "Open Settings" and "Choose an address manually" | 20 |
| `CYLPlaceholderScenarioNoSearchResults` / `.noSearchResults` | Icon, title and a hint | — |
| `CYLPlaceholderScenarioEmptyCart` / `.emptyCart` | Icon, title and a "Go shopping" button | — |
| `CYLPlaceholderScenarioNoOrders` / `.noOrders` | Icon, title and a "Go shopping" button | — |
| `CYLPlaceholderScenarioNoFavorites` / `.noFavorites` | Icon, title and a hint | — |
| `CYLPlaceholderScenarioNoMessages` / `.noMessages` | Icon and title | — |
| `CYLPlaceholderScenarioNoNotifications` / `.noNotifications` | Icon, title and a hint | — |
| `CYLPlaceholderScenarioNoPermission` / `.noPermission` | Permission missing, of no particular kind: lock icon, title, a hint and an "Open Settings" button | — |
| `CYLPlaceholderScenarioCameraPermissionDenied` / `.cameraPermissionDenied` | Camera permission missing: camera icon, title, a hint and "Open Settings" | — |
| `CYLPlaceholderScenarioPhotoLibraryPermissionDenied` / `.photoLibraryPermissionDenied` | Photo library: the same, with a photo icon | — |
| `CYLPlaceholderScenarioMicrophonePermissionDenied` / `.microphonePermissionDenied` | Microphone: the same, with a microphone icon | — |
| `CYLPlaceholderScenarioContactsPermissionDenied` / `.contactsPermissionDenied` | Contacts: the same, with a people icon | — |
| `CYLPlaceholderScenarioCalendarPermissionDenied` / `.calendarPermissionDenied` | Calendar: the same, with a calendar icon | — |
| `CYLPlaceholderScenarioBluetoothPermissionDenied` / `.bluetoothPermissionDenied` | Bluetooth: the same, with a Bluetooth icon | — |
| `CYLPlaceholderScenarioNotificationPermissionDenied` / `.notificationPermissionDenied` | Notifications: the same, with a bell icon | — |
| `CYLPlaceholderScenarioServerError` / `.serverError` | Icon, title, a hint and a "Retry" button | — |
| `CYLPlaceholderScenarioSyncFailed` / `.syncFailed` | Icon, title and a "Retry" button | — |
| `CYLPlaceholderScenarioLoading` / `.loading` | Loading animation and title | — |
| `CYLPlaceholderScenarioUploading` / `.uploading` | Uploading animation (GIF) and title | — |
| `CYLPlaceholderScenarioSuccess` / `.success` | Success animation, title and a "Done" button | — |

## 权限缺失与场景类别 / Missing permissions and scenario categories

| 中文 | English |
| --- | --- |
| 权限缺失不是网络失败：重试没有用，用户必须在“设置”中允许访问。README 截图 #20 就是反例：页面顶部写着“无法获取地址，请手动…”，正文却显示“网络连接异常”和“重新加载”。`CYLPlaceholderScenarioLocationPermissionDenied` 用定位图标、“无法获取您的位置”、说明“这不是网络问题”的提示、“去设置”按钮和“手动选择地址”按钮（动作 `CYLPlaceholderActionChooseManually`）代替它。 | A missing permission is not a network failure: retrying does not help, and the user has to allow access in Settings. README screenshot #20 gets this wrong: the top of the page says "can't get the address, please choose manually", yet the body shows "network error" and "Reload". `CYLPlaceholderScenarioLocationPermissionDenied` replaces it with a location icon, "Can't get your location", a hint saying it isn't a network problem, an "Open Settings" button and a "Choose an address manually" button (action `CYLPlaceholderActionChooseManually`). |
| 其余 7 种权限各有一个场景：相机、相册、麦克风、通讯录、日历、蓝牙、通知，每个都有自己的动画图标（useAnimations，MIT）、标题和提示，以及“去设置”按钮；`CYLPlaceholderScenarioNoPermission` 用于不属于这些类型的权限。 | Seven more permissions each have a scenario: camera, photo library, microphone, contacts, calendar, Bluetooth and notifications, each with its own animated icon (useAnimations, MIT), title and hint, and an "Open Settings" button; `CYLPlaceholderScenarioNoPermission` covers a permission of no particular kind. |
| `+categoryForScenario:` 返回场景类别：`LoadFailed`（网络或服务器失败）、`Empty`、`Permission`、`Progress`、`Success`。`+permissionForScenario:` 与 `+scenarioForPermission:` 在 `CYLPlaceholderPermission` 和场景之间转换，应用可以直接从系统授权状态选出场景。 | `+categoryForScenario:` returns a scenario's category: `LoadFailed` (network or server failure), `Empty`, `Permission`, `Progress` or `Success`. `+permissionForScenario:` and `+scenarioForPermission:` convert between `CYLPlaceholderPermission` and scenarios, so an app can pick the scenario straight from the system's authorization status. |

```swift
// [CN] 定位被拒绝时显示权限缺失场景，而不是网络失败场景
// [EN] When location is denied, show the missing-permission scenario, not a network failure
let status = CLLocationManager().authorizationStatus
let scenario: CYLPlaceholderScenario = (status == .denied || status == .restricted)
    ? CYLPlaceholderScenarioCatalog.scenario(for: .location)
    : .networkUnavailable
let placeholder = CYLPlaceholderStackView(scenario: scenario, actions: [
    .openSettings: { _, _ in UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) },
    .chooseManually: { [weak self] _, _ in self?.showAddressPicker() },
    .retry: { [weak self] _, _ in self?.reload() },
])
```

## 组件点击事件与交互开关 / Component tap events and the interaction switch

| 中文 | English |
| --- | --- |
| 点击事件封装在图标加标题组件 `CYLPlaceholderView` 内部，每个组件都有自己的接口：`tapHandler`（点击事件）、`tapInteractionEnabled`（是否允许交互，默认 YES）、`tapHighlightStyle`（按下样式：`Dim` 变暗（默认）、`Shrink` 缩小、`None` 无变化）、只读的 `tapHighlighted` 与 `tapInteractive`，以及 `performTap`。只有在允许交互且设置了点击事件时，组件才响应点击：按下时显示高亮，抬起时执行点击事件，并为 VoiceOver 加上按钮特征；关闭交互后，点击事件不执行，也不显示高亮，触摸照常传给下层视图。 | The tap event lives inside the icon-and-title component, `CYLPlaceholderView`, and every component has its own API: `tapHandler` (the tap event), `tapInteractionEnabled` (whether taps are handled, YES by default), `tapHighlightStyle` (the pressed look: `Dim` (the default), `Shrink` or `None`), the read-only `tapHighlighted` and `tapInteractive`, and `performTap`. A component responds only when interaction is enabled and a handler is set: it highlights while pressed, runs the handler when the finger lifts, and carries the button trait for VoiceOver. With interaction off, the handler does not run, nothing highlights, and touches pass through as before. |
| `CYLPlaceholderStackView` 在初始化时通过这个接口为每个带动作的组件设置点击事件（执行 `actions` 中对应的处理代码），不再自己添加手势。是否允许交互、按下样式也可以在组件上（`CYLPlaceholderComponent.interactionEnabled`、`tapHighlightStyle`）或 item 键（`CYLPlaceholderItemInteractionEnabled`、`CYLPlaceholderItemTapHighlightStyle`）中设置，创建之后还可以直接修改 `stack.componentViews[i].tapInteractionEnabled`。 | `CYLPlaceholderStackView` sets each component's tap event through this API when it is created (running the matching handler from `actions`) and no longer adds gesture recognizers of its own. Interaction and the pressed look can also be set on the component (`CYLPlaceholderComponent.interactionEnabled`, `tapHighlightStyle`) or with item keys (`CYLPlaceholderItemInteractionEnabled`, `CYLPlaceholderItemTapHighlightStyle`), and changed later through `stack.componentViews[i].tapInteractionEnabled`. |

## 动画播放策略 / Animation playback

| 中文 | English |
| --- | --- |
| `animationRepeatCount`（item 键 `CYLPlaceholderItemAnimationRepeatCount`，可写数字或 `"loop"`、`"once"`）决定每次开始播放时的播放次数：0 循环直到停止，N 播放 N 次。场景组件（`componentWithBundledAnimation:…` 创建的组件）默认循环；单独使用的 `CYLPlaceholderView` 默认仍播放一次，以保持原有行为。GIF、Lottie、PAG 支持所有次数；Rive 的具名动画支持 0 和 1，状态机按文件自身的设置播放。开启“减弱动态效果”时仍会停止动画。 | `animationRepeatCount` (item key `CYLPlaceholderItemAnimationRepeatCount`, a number or `"loop"` / `"once"`) sets how many times the animation plays each time it starts: 0 loops until stopped, N plays N times. Scenario components (those made by `componentWithBundledAnimation:…`) loop by default; a `CYLPlaceholderView` used on its own still plays once by default, so existing behavior is unchanged. GIF, Lottie and PAG support every count; a named Rive animation supports 0 and 1, and a state machine plays as its file defines. Reduce Motion still stops the animation. |
| `+[CYLPlaceholderScenarioCatalog animationFileNamesForScenario:]` 列出适合某个场景的全部内置动画（GIF、Lottie、PAG、Rive），第一个是场景默认使用的图标。除纯文字场景外，每个场景至少有一个动画；四种格式都有覆盖。 | `+[CYLPlaceholderScenarioCatalog animationFileNamesForScenario:]` lists every bundled animation that fits a scenario (GIF, Lottie, PAG, Rive), the scenario's default icon first. Every scenario except the text-only one has at least one animation, and all four formats are represented. |

## 配置文件初始化 / Configuration files

| 中文 | English |
| --- | --- |
| `initWithContentsOfURL:actions:error:`（`.json` 或 `.plist`）与 `initWithConfiguration:actions:error:`（字典）用配置创建占位视图，Swift 中为可抛出错误的 `init(contentsOf:actions:)`、`init(configuration:actions:)`。配置无效时返回 nil 并给出错误说明。点击事件的处理代码不能写在文件里，仍通过 `actions` 按动作名传入。 | `initWithContentsOfURL:actions:error:` (`.json` or `.plist`) and `initWithConfiguration:actions:error:` (a dictionary) create a placeholder from a configuration; in Swift they are the throwing `init(contentsOf:actions:)` and `init(configuration:actions:)`. An invalid configuration returns nil with an error that says why. Tap handlers cannot live in a file: they are still passed through `actions`, by action name. |
| 顶层键：`scenario`（场景名，如 `RetryOrContactSupport`、`retryOrContactSupport`，见 `+nameForScenario:`）；`components`（组件数组，替代场景的组件）；`overrides`（`{"index": n, …}`，修改场景中第 n 个组件）；`backgroundAction`（动作名，`""` 表示关闭）；`accessibilityIdentifier`。 | Top-level keys: `scenario` (a scenario name such as `RetryOrContactSupport` or `retryOrContactSupport`, see `+nameForScenario:`); `components` (an array of components, replacing the scenario's); `overrides` (`{"index": n, …}`, changing the scenario's n-th component); `backgroundAction` (an action name, `""` for none); `accessibilityIdentifier`. |
| 组件键：`type`（`icon`、`hint`、`button`、`separator`、`item`）；`title`/`text`，或用 `titleKey`/`textKey` 读取核心本地化文案；`animation`（内置动画文件名）；`style`（`CYLPlaceholderStyle` 名称如 `WifiOff`，或数字）；`size`（`[宽, 高]` 或一个数字）；`buttonStyle`（`filled`、`outlined`、`capsule`）；`action`（`retry`、`contactSupport`、`openSettings`、`goShopping`、`done`、`chooseManually` 或应用自定义的名称）；`interactionEnabled`；`highlightStyle`（`dim`、`shrink`、`none`）；`repeatCount`（`0`/`"loop"`、N、`"once"`）；`spacingBefore`；`accessibilityIdentifier`；`item` 类型的 `attributes` 是原始 item 属性，键使用序列化名称（如 `CYLTabBarItemTitleColor`、`CYLPlaceholderItemTitleCornerRadius`）。 | Component keys: `type` (`icon`, `hint`, `button`, `separator`, `item`); `title`/`text`, or `titleKey`/`textKey` for core localized text; `animation` (a bundled animation file name); `style` (a `CYLPlaceholderStyle` name such as `WifiOff`, or a number); `size` (`[width, height]` or one number); `buttonStyle` (`filled`, `outlined`, `capsule`); `action` (`retry`, `contactSupport`, `openSettings`, `goShopping`, `done`, `chooseManually`, or a name the app defines); `interactionEnabled`; `highlightStyle` (`dim`, `shrink`, `none`); `repeatCount` (`0`/`"loop"`, N, `"once"`); `spacingBefore`; `accessibilityIdentifier`; for the `item` type, `attributes` holds raw item attributes under their serialized names (such as `CYLTabBarItemTitleColor` or `CYLPlaceholderItemTitleCornerRadius`). |

```json
{
  "scenario": "RetryOrContactSupport",
  "overrides": [
    { "index": 0, "repeatCount": "loop" },
    { "index": 1, "highlightStyle": "shrink" },
    { "index": 3, "interactionEnabled": false }
  ]
}
```

```swift
// [CN] 从配置文件创建；点击事件按动作名传入
// [EN] From a configuration file; tap handlers are passed by action name
let url = Bundle.main.url(forResource: "ctrip-retry-or-contact-support", withExtension: "json")!
let placeholder = try CYLPlaceholderStackView(contentsOf: url, actions: [
    .retry: { [weak self] _, _ in self?.reload() },
    .contactSupport: { [weak self] _, _ in self?.showSupport() },
])
```

| 中文 | English |
| --- | --- |
| 聚合 Demo 的 `CYLScenarioExample.bundle/Configurations/` 中有 7 个配置文件，分别演示：场景加覆盖项（携程）、plist 中的胶囊按钮（什么值得买）、三种按下样式与关闭交互、三种播放策略、GIF/Lottie/PAG/Rive 四种格式、定位权限缺失场景、原始 item 属性。场景 Tab 的“配置文件初始化”分组逐个打开它们，可查看文件内容。文件中的示例自有文案用 `exampleTitleKey` 标注，由示例从自己的 bundle 读取后再交给核心，核心从不读取示例的 bundle。 | The aggregate demo's `CYLScenarioExample.bundle/Configurations/` holds 7 configuration files, showing: a scenario with overrides (Ctrip), a capsule button in a plist (SMZDM), the three pressed looks and interaction turned off, the three playback policies, the GIF/Lottie/PAG/Rive formats, the missing-location-permission scenario, and raw item attributes. The "Configuration files" section of the Scenarios tab opens each one and can show the file. The demo's own texts in a file are marked `exampleTitleKey`; the example reads them from its own bundle before handing the configuration to the core, which never reads the example's bundle. |

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
| `+categoryForScenario:` / `+permissionForScenario:` / `+scenarioForPermission:` | `category(for:)` / `permission(for:)` / `scenario(for:)` |
| `CYLPlaceholderScenarioCategoryPermission` / `CYLPlaceholderPermissionLocation` … | `.permission` / `.location` … |
| `CYLPlaceholderActionRetry` … | `.retry`, `.contactSupport`, `.openSettings`, `.goShopping`, `.done`, `.chooseManually` |
| `-initWithContentsOfURL:actions:error:` / `-initWithConfiguration:actions:error:` | `CYLPlaceholderStackView(contentsOf:actions:)` / `(configuration:actions:)` (throws) |
| `+componentWithDictionary:error:` | `CYLPlaceholderComponent(dictionary:)` (throws) |
| `+nameForScenario:` / `+scenarioNamed:` / `+actionNamed:` / `+animationFileNamesForScenario:` | `name(for:)` / `scenario(named:)` / `action(named:)` / `animationFileNames(for:)` |
| `CYLPlaceholderView.tapHandler` / `tapInteractionEnabled` / `tapHighlightStyle` / `-performTap` / `animationRepeatCount` | `tapHandler`, `isTapInteractionEnabled` (the property takes its getter's name in Swift; verified by the CI compiler), `tapHighlightStyle`, `performTap()`, `animationRepeatCount`; read-only `isTapInteractive`, `isTapHighlighted` |
| `CYLPlaceholderLocalizationLanguageDidChangeNotification` | `CYLPlaceholderLocalization.languageDidChangeNotification` |
| `+localizedStringForKey:fallback:` | `CYLPlaceholderLocalization.localizedString(forKey:fallback:)` |

## 本地化 / Localization

| 中文 | English |
| --- | --- |
| 场景的标题、提示、按钮和名称都在核心资源包的 `Localizable.strings` 中（en、zh-Hans、zh-Hant、ja、ko、ru、uk），通过核心层的查找宏 `CYLPlaceholderLocalizedString(key, fallback)` 读取。设置 `CYLPlaceholderLocalization.language` 可在运行时切换语言（`nil` 跟随系统，不支持的语言先回退到基础语言，再回退到英语）；已创建的视图不会自动更新，收到 `CYLPlaceholderLocalizationLanguageDidChangeNotification` 后重新创建即可。聚合 Demo 用同一个通知机制演示：切换语言后整个界面重建。 | Scenario titles, hints, buttons and names live in the core bundle's `Localizable.strings` (en, zh-Hans, zh-Hant, ja, ko, ru, uk) and are read through the core lookup macro `CYLPlaceholderLocalizedString(key, fallback)`. Set `CYLPlaceholderLocalization.language` to switch the language at run time (`nil` follows the system; an unsupported language falls back to its base language, then to English); views already created do not update, so recreate them after `CYLPlaceholderLocalizationLanguageDidChangeNotification`. The aggregate demo shows this: the whole interface is rebuilt after a language change. |

## 无障碍与资源查找 / Accessibility and resource lookups

| 中文 | English |
| --- | --- |
| 每个组件都是有意义的无障碍元素：带标题的组件朗读标题；带点击事件的组件是按钮（Voice Control 可直接说出标题点击，Switch Control 可选中），关闭交互后还带有“不可用”特征且不能被激活；分隔符只朗读文字（如“或”）；没有文字、标签和点击事件的图标或插图是装饰，对 VoiceOver 隐藏；“点击屏幕重新加载”场景的保留组件是按钮，只有图标时以动作名称命名。`CYLPlaceholderStackView` 把组件编为一组（`shouldGroupAccessibilityChildren`），自上而下朗读。运行时切换了核心语言时，组件设置 `accessibilityLanguage`，VoiceOver 用所选语言发音。开启“减弱动态效果”时动画停止，缩小样式只变暗。文字使用文本样式或 `UIFontMetrics` 缩放的字体，跟随动态字体。 | Every component is a meaningful accessibility element: one with a title reads it; one with a tap event is a button (Voice Control users say its title to tap it, Switch Control can select it), and with interaction off it also has the not-enabled trait and cannot be activated; a separator reads only its word ("or"); an icon or illustration without text, label or tap event is a decoration hidden from VoiceOver; the reserved component of a "tap the screen to reload" scenario is a button, named after its action when it has only an icon. `CYLPlaceholderStackView` groups its components (`shouldGroupAccessibilityChildren`) and reads them top to bottom. When the core language is changed at run time, components set `accessibilityLanguage` so VoiceOver pronounces the chosen language. With Reduce Motion on, animations stop and the shrink highlight only dims. Text uses text styles or `UIFontMetrics`-scaled fonts and follows Dynamic Type. |
| 资源与文案一样分层查找：核心层用 `CYLPlaceholderResourceBundle()` 与宏 `CYLPlaceholderResourceURL(path)`（Swift 调用函数 `CYLPlaceholderResourceURLForPath(_:)`），只读取 `CYLTableViewPlaceHolder.bundle`；示例层用自己的查找函数（如 `CYLScenarioExampleResourceURL(_:)`），只读取示例自己的 bundle。文案查找宏同样分为核心层的 `CYLPlaceholderLocalizedString` 与示例层的 `CYLScenarioLocalizedString`。 | Resources are looked up per layer, like strings: the core uses `CYLPlaceholderResourceBundle()` and the macro `CYLPlaceholderResourceURL(path)` (Swift calls the function `CYLPlaceholderResourceURLForPath(_:)`) and reads only `CYLTableViewPlaceHolder.bundle`; an example uses its own lookup (such as `CYLScenarioExampleResourceURL(_:)`) and reads only its own bundle. The string lookups are split the same way: the core's `CYLPlaceholderLocalizedString` and the example's `CYLScenarioLocalizedString`. |

## 已知限制 / Known limits

| 中文 | English |
| --- | --- |
| 组件是 `CYLPlaceholderView`，按钮由标题装饰键绘制，不是 `UIButton`：按下样式只有变暗、缩小和无三种，不支持 `UIButton.Configuration`，也没有禁用状态的外观（关闭交互只是不响应）。 | Components are `CYLPlaceholderView`s and buttons are drawn with the title chrome keys, not `UIButton`s: the pressed look is dim, shrink or none, `UIButton.Configuration` is not supported, and there is no disabled appearance (turning interaction off only stops responding). |
| 只收录内容本身表示占位状态的动画：加载、进度、空、无结果、无网络或请求失败、权限缺失、占位图提供的操作（重试、刷新、设置、联系客服）、完成。按文件实际显示的内容判断，不看文件名；吉祥物、场景、角色和控件演示（开关、评分、车辆）都已移除（`Mascot.riv`、`Settings.riv`、`NoContent.pag`、`NoResults.riv`、`NoReviews.riv`、`NoOrders.riv`），“暂无订单”改用包裹线条图标，README #34、#35 的吉祥物改为离线云图标。可再分发的小体积 GIF 很少，GIF 只有 `Uploading`、`NoFavorites` 两个；`CYLPlaceholderStyle` 的 56 种静态样式没有一一对应的动画。 | Only animations whose content means a placeholder state are bundled: loading, progress, empty, no results, no network or a failed request, a missing permission, an action the placeholder offers (retry, refresh, settings, contact support), done. Files are judged by what they show, not by their names; mascots, scenes, characters and widget demos (switches, ratings, vehicles) were removed (`Mascot.riv`, `Settings.riv`, `NoContent.pag`, `NoResults.riv`, `NoReviews.riv`, `NoOrders.riv`), "No orders" now uses a parcel line icon, and the mascot of README #34 and #35 became an offline cloud icon. Few small, redistributable GIFs exist, so there are only two, `Uploading` and `NoFavorites`; the 56 static `CYLPlaceholderStyle` images have no one-to-one animations. |
| 切换语言不会更新已创建的视图；需要重新创建。 | A language change does not update views already created; recreate them. |
| 占位视图不能滚动：在最大的辅助功能字体下，组件较多的场景可能超出屏幕。尚未支持从右到左的语言（核心只有 7 种从左到右的语言，布局居中，加入阿拉伯语等语言时需验证）。无障碍行为由单元测试检查标签与特征，尚未用 VoiceOver 在模拟器中实际走查。 | The placeholder does not scroll: at the largest accessibility text sizes, scenarios with many components may not fit the screen. Right-to-left languages are not supported yet (the core has 7 left-to-right languages and centered layout; verify when adding Arabic or similar). Accessibility is checked by unit tests of labels and traits and has not been walked through with VoiceOver on a simulator. |
| 日、韩、俄、乌克兰文译文未经母语者审校；动画的实际渲染（包括 Lottie 线条图标的 `**.Color` 着色）需在模拟器中人工查看，CI 只截取首页。 | The Japanese, Korean, Russian and Ukrainian translations have not been reviewed by native speakers; actual animation rendering (including the `**.Color` tint of the Lottie line icons) needs a manual look in the simulator, as CI only captures the first screen. |
