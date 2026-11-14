# 顶部状态红条 / Status bar (red bar)

<!-- bound-classes: CYLPlaceholderStatusView, CYLPlaceholderStackView -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [来源](#来源--source) | [Source](#来源--source) |
| [接口](#接口--api) | [API](#接口--api) |
| [与占位图组合](#与占位图组合--combined-with-the-placeholder) | [Combined with the placeholder](#与占位图组合--combined-with-the-placeholder) |
| [网络检测](#网络检测--network-detection) | [Network detection](#网络检测--network-detection) |
| [演示](#演示--demo) | [Demo](#演示--demo) |
| [限制](#限制--limits) | [Limits](#限制--limits) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| `CYLPlaceholderStatusView` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStatusView.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStatusView.h) |
| `CYLPlaceholderStackView` | [`CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h`](../CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLPlaceholderStackView.h) |

<!-- docs-binding:end -->

## 来源 / Source

| 中文 | English |
| --- | --- |
| `CYLPlaceholderStatusView` 移植自 [CYLChatKit](https://github.com/ChenYilong/CYLChatKit)（commit `b730b8d`）的 `ChatKit/Class/View/LCCKStatusView`：聊天页顶部红色背景的“当前网络不可用，请检查你的网络设置”。仓库许可证为 MIT（Copyright (c) 2016 LeanCloud），原文件头的作者与版权信息保留在 `.m` 中，许可证全文随资源包提供（`CYLTableViewPlaceHolder.bundle/LICENSE.CYLChatKit`）。图标 `CYLPlaceholderStatusFail@2x/@3x.png` 是 ChatKit 的 `MessageBubble.bundle/MessageSendFail`，未修改（SHA-256：`678d93c0…b0831a`、`d5f1c487…c95c53`）。 | `CYLPlaceholderStatusView` is ported from `ChatKit/Class/View/LCCKStatusView` of [CYLChatKit](https://github.com/ChenYilong/CYLChatKit) (commit `b730b8d`): the red bar "Network unavailable, Check network" at the top of a chat. The repository is MIT licensed (Copyright (c) 2016 LeanCloud); the original file header with its author and copyright stays in the `.m` file, and the license text ships in the resource bundle (`CYLTableViewPlaceHolder.bundle/LICENSE.CYLChatKit`). The icon `CYLPlaceholderStatusFail@2x/@3x.png` is ChatKit's `MessageBubble.bundle/MessageSendFail`, unmodified (SHA-256 `678d93c0…b0831a`, `d5f1c487…c95c53`). |

## 接口 / API

| CYLChatKit | CYLTableViewPlaceHolder | Swift |
| --- | --- | --- |
| `LCCKStatusView` | `CYLPlaceholderStatusView` | `CYLPlaceholderStatusView` |
| `-initWithFrame:`（网络提示 / network message） | `-initWithFrame:` | `init(frame:)` |
| `LCCKStatusViewDelegate` / `-statusViewClicked:` | `CYLPlaceholderStatusViewDelegate` / `-statusViewClicked:` | `statusViewClicked(_:)` |
| `delegate` | `delegate` | `delegate` |
| `LCCKStatusViewHight`（44） | `CYLPlaceholderStatusViewHight`, `CYLPlaceholderStatusViewHeight` | 同名 / same |
| — | `-initWithItemAttributes:error:`, `networkUnavailableItemAttributes`, `placeholderView`, `text`, `tapHandler` | `init(itemAttributes:)`（throws）, … |

| 中文 | English |
| --- | --- |
| 接口保持 ChatKit 的形状，改用本库前缀，避免与同时集成 CYLChatKit 的应用产生重复符号。内部不再用 `UIImageView` 加 `UILabel`：红色背景是 `CYLPlaceholderStatusView` 本身（父视图），图标与文字是铺满它的子视图——本库的图标加标题组件 `CYLPlaceholderView`，通过新的 item 键 `CYLPlaceholderItemContentAxis` = `"horizontal"` 横向排列（图标在前缘、文字在后、垂直居中，右到左语言自动镜像）。图标按 ChatKit 的 20 点绘制（28 点图片加 4 点 `CYLPlaceholderItemImageInsets`），间距 5 点，字号 15 并随动态字体缩放；文字变高时状态条随之变高（`intrinsicContentSize` 至少 44）。 | The API keeps ChatKit's shape under this library's prefix, so an app that also uses CYLChatKit gets no duplicate symbols. Inside, the `UIImageView` and `UILabel` are gone: the red background is `CYLPlaceholderStatusView` itself (the parent), and the icon and text are its subview filling it — the library's icon-and-title component `CYLPlaceholderView`, laid out horizontally through the new item key `CYLPlaceholderItemContentAxis` = `"horizontal"` (the icon at the leading edge, the text after it, both centered vertically, mirrored for right-to-left languages). The icon is drawn at ChatKit's 20 points (the 28-point image with 4-point `CYLPlaceholderItemImageInsets`), 5 points from the text, which is 15 points and follows Dynamic Type; taller text makes the bar taller (`intrinsicContentSize`, at least 44). |
| 颜色：背景沿用 ChatKit 的 rgb(255, 199, 199)；文字由 ChatKit 的灰色（对比度约 3:1）改为 #555555（约 4.9:1，满足 WCAG AA）。深色模式下为暗红背景与浅粉文字。 | Colors: the background keeps ChatKit's rgb(255, 199, 199); the text changes from ChatKit's gray (about 3:1) to #555555 (about 4.9:1, WCAG AA). Dark Mode uses a dark red background with light pink text. |
| 文案：核心文案表新增 `CYLPlaceholderStatusNetworkUnavailable`（7 种语言，中文取自 ChatKit），只增不改。 | Text: the core string table gains `CYLPlaceholderStatusNetworkUnavailable` (7 languages, the Chinese from ChatKit), an additive change. |
| 无障碍：没有代理也没有 `tapHandler` 时，状态条对 VoiceOver 是普通文字；有其一时是按钮，可设置 `placeholderView.accessibilityHint` 说明点击结果。 | Accessibility: with neither a delegate nor a `tapHandler`, VoiceOver reads the bar as text; with one, it is a button, and `placeholderView.accessibilityHint` can say what a tap does. |

## 与占位图组合 / Combined with the placeholder

| 中文 | English |
| --- | --- |
| 红条与占位图是两个独立的组件，不放进 `CYLPlaceholderStackView`（与 UIStackView 无关）。红条按 CYLChatKit 的方式加在当前视图控制器的 view 上：位于顶端、导航栏正下方（底边固定在安全区域顶部，`zPosition` 高于列表内容），显示期间控制器的 `additionalSafeAreaInsets.top` 增加红条高度，使内容从红条下方开始；动态字体变大时红条与安全区域一起变高。占位图仍由 table / collection view 的 `cyl_placeholderViewBlock` 放置。二者的组合由一个参数决定：`UIViewController.cyl_statusDisplay`。 | The bar and the placeholder are two independent components; the bar is not put into `CYLPlaceholderStackView` (nothing to do with UIStackView). As in CYLChatKit, the bar is added to the current view controller's view: at the top, right below the navigation bar (its bottom edge on the safe area's top, its `zPosition` above the list's content), and while it shows the controller's `additionalSafeAreaInsets.top` grows by its height so the content starts below it; with a larger Dynamic Type size the bar and the safe area grow together. The placeholder stays where the table or collection view's `cyl_placeholderViewBlock` puts it. One parameter chooses the combination: `UIViewController.cyl_statusDisplay`. |

| 显示 / Shows | `cyl_statusDisplay` | 配置文件 `display` / Configuration file `display` |
| --- | --- | --- |
| 红条 + 占位图 / bar and placeholder | `.all` | `"statusAndPlaceholder"`（有 `statusBar` 时的默认 / the default with `statusBar`） |
| 只显示红条 / bar only | `.statusBar` | `"status"` |
| 只显示占位图 / placeholder only | `.placeholder`（默认 / default） | `"placeholder"` |
| 都不显示 / neither | `[]` | `"none"` |

```swift
// [CN] 红条 + 占位图 / [EN] the bar and the placeholder
tableView.cyl_placeholderViewBlock({ _ in CYLPlaceholderStackView(scenario: .networkUnavailable, actions: nil) })
cyl_statusView.delegate = self            // [CN] 与 CYLChatKit 相同 / [EN] as in CYLChatKit
cyl_setStatusDisplay(.all, animated: true)
// [CN] 只显示红条 / [EN] only the bar
cyl_statusDisplay = .statusBar
// [CN] 断网时自动显示红条 / [EN] the bar while offline
cyl_showsStatusViewWhenOffline = true
// [CN] 配置文件 / [EN] a configuration file
try cyl_applyStatusConfiguration(contentsOf: url)
```

```json
{
  "statusBar": { "textKey": "CYLPlaceholderStatusNetworkUnavailable" },
  "display": "statusAndPlaceholder",
  "showsWhenOffline": true
}
```

| 中文 | English |
| --- | --- |
| 其他接口：`cyl_statusView`（默认网络提示条，可赋值自定义状态条，赋 nil 恢复）、`cyl_placeholderScrollView`（受控的列表，默认是控制器的 view，如 UITableViewController）、`UIScrollView.cyl_placeholderHidden`（列表为空也不显示占位图，由 `cyl_statusDisplay` 设置，只作用于 block 接口）。`"statusBar"` 可以是 `true`、`"networkUnavailable"` 或字典（`-[CYLPlaceholderStatusView initWithConfiguration:error:]`：`text`、`textKey`、`image`、`titleColor`、`backgroundColor`、`accessibilityIdentifier`）。配置无效时返回错误且不做任何修改。 | Also: `cyl_statusView` (the network bar by default; assign your own, nil restores it), `cyl_placeholderScrollView` (the list it controls; by default the controller's view, as in a UITableViewController), `UIScrollView.cyl_placeholderHidden` (no placeholder even for an empty list; set by `cyl_statusDisplay`; block API only). `"statusBar"` is `true`, `"networkUnavailable"` or a dictionary (`-[CYLPlaceholderStatusView initWithConfiguration:error:]`: `text`, `textKey`, `image`, `titleColor`, `backgroundColor`, `accessibilityIdentifier`). An invalid configuration returns an error and changes nothing. |

## 网络检测 / Network detection

| 中文 | English |
| --- | --- |
| CYLChatKit 的红条跟随 IM 客户端的连接状态，而连接状态依赖 LeanCloud SDK 中 `AVIMWebSocketWrapper` 的可达性监测（`LCNetworkReachabilityManager`，AFNetworkReachabilityManager 的变体，基于 `SCNetworkReachability`）。`CYLPlaceholderNetworkMonitor` 移植这段逻辑，用于高内聚网络失败场景：相同的状态值（未知 -1、不可达 0、蜂窝 1、Wi-Fi 2）、状态变化回调 `setNetworkStatusChangeBlock:`、`startMonitoring` / `stopMonitoring`、`reachable`（只有不可达时为 NO），并发送 `CYLPlaceholderNetworkStatusDidChangeNotification`。 | CYLChatKit's bar follows the IM client's connection, which depends on the reachability monitoring of LeanCloud's `AVIMWebSocketWrapper` (`LCNetworkReachabilityManager`, an AFNetworkReachabilityManager variant on `SCNetworkReachability`). `CYLPlaceholderNetworkMonitor` ports that logic so the network-failure scenario is self-contained: the same status values (unknown -1, not reachable 0, cellular 1, Wi-Fi 2), the change block `setNetworkStatusChangeBlock:`, `startMonitoring` / `stopMonitoring`, `reachable` (NO only when not reachable), and `CYLPlaceholderNetworkStatusDidChangeNotification`. |
| 适配新系统：`SCNetworkReachability` 自 iOS 17 起废弃，且只表示数据包能否离开设备；改用 Network.framework 的 `NWPathMonitor`（iOS 12 起，即本库最低版本，podspec 增加 `Network` framework）。新增有线以太网（`ReachableViaWiredEthernet`）与其他接口（`ReachableViaOther`，如 VPN）、低数据模式 `constrained`（iOS 13 起）与昂贵网络 `expensive`；“需要连接”（按需 VPN、需登录的网络）视为不可达；回调在主队列。未知状态不算离线，避免启动时红条闪现（ChatKit 把未知当作不可达）。 | Adapted to current systems: `SCNetworkReachability` is deprecated since iOS 17 and only says whether a packet could leave the device; this uses Network.framework's `NWPathMonitor` (iOS 12+, the library's minimum; the podspec adds the `Network` framework). New: wired Ethernet (`ReachableViaWiredEthernet`) and other interfaces (`ReachableViaOther`, such as a VPN), Low Data Mode `constrained` (iOS 13+) and `expensive` paths; "requires connection" (VPN on demand, a captive network) counts as not reachable; callbacks run on the main queue. An unknown status is not offline, so no bar flashes at launch (ChatKit treated unknown as unreachable). |
| 参照 Sentry 的 [getsentry/sentry-cocoa#5440](https://github.com/getsentry/sentry-cocoa/issues/5440)（由 #6019 改用 `NWPathMonitor`）：按主机名创建的 `SCNetworkReachability` 会在每次网络变化时发起 DNS 查询（即使关闭了遥测），因此这里不监测主机，只监测设备的网络路径；已启动的 `NWPathMonitor` 在取消前一直运行（即使没有强引用），取消后不能重新启动，所以每次 `startMonitoring` 新建监测器，`stopMonitoring` 与释放时取消；已取消的监测器可能仍送达排队中的更新，用启动序号忽略它们；在监测器自己的回调中取消会卡住其队列，所以监测器运行在私有串行队列（utility QoS），状态、回调与通知转到主队列。低数据模式或昂贵网络变化而状态不变时也会发送通知（回调只在状态变化时执行）。 | Following Sentry's [getsentry/sentry-cocoa#5440](https://github.com/getsentry/sentry-cocoa/issues/5440) (moved to `NWPathMonitor` by #6019): an `SCNetworkReachability` created with a host name makes a DNS query on every network change (even with telemetry off), so no host is watched here, only the device's network path; a started `NWPathMonitor` keeps running until it is cancelled (even without a strong reference) and cannot be restarted once cancelled, so every `startMonitoring` creates a new monitor and `stopMonitoring` and dealloc cancel it; a cancelled monitor can still deliver a queued update, which a start counter ignores; cancelling a monitor inside its own update handler wedges its queue, so the monitor runs on a private serial queue (utility QoS) and the status, the block and the notification move to the main queue. A change of Low Data Mode or of an expensive path without a status change posts the notification too (the block runs on status changes only). |
| 限制：有可用路径不代表服务器可达（例如需要登录的 Wi-Fi 在登录前可能仍是 satisfied）；请求失败时仍应由应用显示网络失败占位图。 | Limit: a usable path does not mean the server is reachable (a captive Wi-Fi may report satisfied before login); a failed request should still show the network-failure placeholder. |

## 演示 / Demo

| 中文 | English |
| --- | --- |
| Example-Scenarios 的“交互流程 → 状态条 → 网络状态条”（`CYLStatusBarViewController`，UITableViewController）：底部切换红条 + 占位图、只显示红条、只显示占位图、红条 + 列表；“网络”打开 `cyl_showsStatusViewWhenOffline`（可用飞行模式验证）；“文件”应用 `CYLScenarioExample.bundle/StatusBar/` 中的三个配置文件。 | Example-Scenarios, "Flows → Status bar → Network status bar" (`CYLStatusBarViewController`, a UITableViewController): the toolbar switches between bar and placeholder, bar only, placeholder only, and bar over a list; "Network" turns on `cyl_showsStatusViewWhenOffline` (try airplane mode); "File" applies the three configuration files in `CYLScenarioExample.bundle/StatusBar/`. |

## 限制 / Limits

| 中文 | English |
| --- | --- |
| 未验证：本机无法编译或运行，等待 CI；横向布局、红条在导航栏下方的位置（尤其控制器的 view 本身是 table 时，红条约束在 frame 布局参考与安全区域上）、深色模式、右到左与动态字体需要在模拟器中查看；网络切换需要在真机或模拟器中手动验证。`cyl_placeholderHidden` 只作用于 block 接口（`cyl_placeholderViewBlock`），不作用于旧的代理接口。横向排列时不绘制标题装饰（背景、边框）。 | Not verified: nothing could be compiled or run here, so CI comes first; the horizontal layout, the bar's place below the navigation bar (especially when the controller's view is the table itself, where the bar is pinned to the frame layout guide and the safe area), Dark Mode, right-to-left and Dynamic Type need a look in the simulator; network changes need a manual check on a device or simulator. `cyl_placeholderHidden` only affects the block API (`cyl_placeholderViewBlock`), not the older delegate API. A horizontal item draws no title chrome (background, border). |
