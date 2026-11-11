# 顶部状态红条 / Status bar (red bar)

<!-- bound-classes: CYLPlaceholderStatusView, CYLPlaceholderStackView -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [来源](#来源--source) | [Source](#来源--source) |
| [接口](#接口--api) | [API](#接口--api) |
| [与占位图组合](#与占位图组合--combined-with-the-placeholder) | [Combined with the placeholder](#与占位图组合--combined-with-the-placeholder) |
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

| 显示 / Shows | 代码 / Code | 配置文件 / Configuration file |
| --- | --- | --- |
| 红条 + 占位图 / bar and placeholder | `placeholder.statusView = CYLPlaceholderStatusView(frame: .zero)` | `"statusBar": true`（或 / or `"display": "statusAndPlaceholder"`） |
| 只显示红条 / bar only | `CYLPlaceholderStackView(statusView:)`，或 / or `componentsHidden = true` | `"display": "status"` |
| 只显示占位图 / placeholder only | `statusView = nil`（默认 / default） | 不写 `statusBar`，或 / omit `statusBar`, or `"display": "placeholder"` |
| 有数据时的红条 / bar over a list | `tableView.tableHeaderView = CYLPlaceholderStatusView(frame:)`（与 ChatKit 相同 / as in ChatKit） | — |

```swift
// [CN] 红条 + 占位图 / [EN] the bar and the placeholder
let placeholder = CYLPlaceholderStackView(scenario: .networkUnavailable, actions: [.retry: { _, _ in reload() }])
let bar = CYLPlaceholderStatusView(frame: .zero)
bar.delegate = self                       // [CN] 与 CYLChatKit 相同 / [EN] as in CYLChatKit
placeholder.statusView = bar
// [CN] 只显示红条 / [EN] only the bar
let barOnly = CYLPlaceholderStackView(statusView: CYLPlaceholderStatusView(frame: .zero))
```

```json
{
  "scenario": "NetworkUnavailable",
  "statusBar": { "textKey": "CYLPlaceholderStatusNetworkUnavailable", "action": "retry" },
  "display": "statusAndPlaceholder"
}
```

| 中文 | English |
| --- | --- |
| `statusView` 固定在顶部并铺满宽度，组件在其下方的区域居中；不设置时布局与以前相同。`"statusBar"` 可以是 `true`、`"networkUnavailable"` 或字典：`text`、`textKey`（核心文案 key）、`image`（核心 bundle 中的图片名或 `"system:<SF Symbol>"`）、`titleColor`、`backgroundColor`（颜色字符串）、`accessibilityIdentifier`、`action`（点击时执行的动作名）。示例：Example-Scenarios 的“交互流程 → 状态条 → 网络状态条”（`CYLStatusBarViewController`），底部切换四种显示方式，“文件”打开 `Configurations/status-bar-and-placeholder.json` 与 `status-bar-only.json`。 | `statusView` is pinned to the top across the full width, and the components center in the space below it; without it the layout is unchanged. `"statusBar"` is `true`, `"networkUnavailable"` or a dictionary: `text`, `textKey` (a core string key), `image` (an image name in the core bundle or `"system:<SF Symbol>"`), `titleColor`, `backgroundColor` (color strings), `accessibilityIdentifier`, `action` (the action name a tap runs). Demo: Example-Scenarios, "Flows → Status bar → Network status bar" (`CYLStatusBarViewController`), whose toolbar switches between the four ways, and "File" opens `Configurations/status-bar-and-placeholder.json` and `status-bar-only.json`. |

## 限制 / Limits

| 中文 | English |
| --- | --- |
| 未验证：本机无法编译或运行，等待 CI；横向布局、红条高度、深色模式与右到左镜像的实际画面需要在模拟器中查看。红条作为 table 的占位图时，位置取决于占位图的 frame（在导航栏下方由 table 的内容边距决定）；有数据时的红条用 `tableHeaderView`，会随列表滚动（ChatKit 的聊天页则把它加在控制器的 view 上）。横向排列时不绘制标题装饰（背景、边框）。 | Not verified: nothing could be compiled or run here, so CI comes first; the horizontal layout, the bar's height, Dark Mode and right-to-left mirroring need a look in the simulator. As a table placeholder, the bar sits where the placeholder's frame starts (below the navigation bar through the table's content inset); over a list it is the `tableHeaderView` and scrolls with it (ChatKit's chat page adds it to the controller's view instead). A horizontal item draws no title chrome (background, border). |
