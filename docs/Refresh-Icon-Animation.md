# 刷新控件的动画图标 / Animated icons for the refresh controls

<!-- bound-classes: CYLRefreshIconView, CYLRefreshComponent -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [概述](#概述--overview) | [Overview](#概述--overview) |
| [接口](#接口--api) | [API](#接口--api) |
| [播放策略](#播放策略--playback-policy) | [Playback policy](#播放策略--playback-policy) |
| [布局](#布局--layout) | [Layout](#布局--layout) |
| [内置刷新动画](#内置刷新动画--bundled-refresh-animations) | [Bundled refresh animations](#内置刷新动画--bundled-refresh-animations) |
| [演示与限制](#演示与限制--demo-and-limits) | [Demo and limits](#演示与限制--demo-and-limits) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| `CYLRefreshIconView` | [`CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshIconView.h`](../CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshIconView.h) |
| `CYLRefreshComponent` | [`CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshComponent.h`](../CYLTableViewPlaceHolder/CYLRefresh/Base/CYLRefreshComponent.h) |

<!-- docs-binding:end -->

## 概述 / Overview

| 中文 | English |
| --- | --- |
| CYLRefresh 的刷新头、尾和 trailer 可以用本库的图标组件（`CYLRefreshIconView`，内部是 `CYLPlaceholderView`）显示图标：静态图片，或 GIF、Lottie、PAG、Rive 动画（Lottie、PAG、Rive 需要对应的子规格，GIF 由 Core 播放）。原有接口和图标策略不变：箭头 `arrowView`、菊花 `loadingView`、`gifView` 与 `setImages:forState:` 照常可用；只有设置了图标动画时，图标才替换它们，放在相同的位置并遵循相同的显示时机。 | CYLRefresh's headers, footers and trailers can show their icon with the library's icon component (`CYLRefreshIconView`, built on `CYLPlaceholderView`): a static image, or a GIF, Lottie, PAG or Rive animation (Lottie, PAG and Rive need their subspec; Core plays GIF). The existing API and icon strategy are unchanged: `arrowView`, `loadingView`, `gifView` and `setImages:forState:` work as before; only when an icon animation is set does the icon replace them, in the same place and following the same show/hide timing. |

## 接口 / API

| 中文 | English |
| --- | --- |
| 在 `CYLRefreshComponent` 上（所有刷新头、尾、trailer 都可用）：`-setIconAnimationAttributes:forState:` 接受 `CYLPlaceholderView` 的 item 属性（动画文件、尺寸、选项、颜色等）；`-setIconAnimationFilePath:size:forState:` 接受任意本地动画文件；`-setBundledIconAnimation:size:forState:` 使用核心 bundle 中的内置动画并自动带上所需选项。没有单独设置的状态使用空闲状态的图标，所以调用一次即可；也可以为下拉、刷新中等状态分别设置不同的图标。`iconView` 返回图标组件，`usesIconView` 表示是否已设置图标动画。 | On `CYLRefreshComponent` (every header, footer and trailer): `-setIconAnimationAttributes:forState:` takes `CYLPlaceholderView` item attributes (animation file, size, options, colors…); `-setIconAnimationFilePath:size:forState:` takes any local animation file; `-setBundledIconAnimation:size:forState:` uses a bundled animation of the core and adds the options it needs. A state without its own icon uses the idle state's, so one call is enough; pulling, refreshing and other states can also each have their own icon. `iconView` returns the icon component, and `usesIconView` says whether an icon animation is set. |

```swift
// [CN] 下拉时显示 Lottie 箭头，刷新中显示 PAG 菊花；布局与文字仍由 CYLRefresh 决定
// [EN] A Lottie arrow while pulling, a PAG spinner while refreshing; layout and texts stay CYLRefresh's own
let header = CYLRefreshNormalHeader { [weak self] in self?.reload() }
header.setIconAnimation(bundled: "CYLPlaceholderRefresh.json", size: CGSize(width: 28, height: 28), for: .idle)
header.setIconAnimation(bundled: "CYLPlaceholderLoading.pag", size: CGSize(width: 36, height: 36), for: .refreshing)
tableView.cyl_header = header

let footer = CYLRefreshAutoNormalFooter { [weak self] in self?.loadMore() }
footer.setIconAnimation(filePath: gifPath, size: CGSize(width: 32, height: 32), for: .refreshing)
tableView.cyl_footer = footer
```

## 播放策略 / Playback policy

| 中文 | English |
| --- | --- |
| 播放策略固定在图标组件内部，随控件状态自动切换：空闲且未拖动时停在静止帧；空闲且正在拖动时，可定位的动画（Lottie、PAG）跟随下拉百分比，其他动画开始播放（`scrubsWhilePulling` 设为 NO 时总是播放）；松开即可刷新、刷新中和即将刷新时循环播放；刷新结束回到空闲时停止；没有更多数据时停止。属性中写了 `CYLPlaceholderItemAnimationRepeatCount` 时保持该播放次数。“减弱动态效果”开启时动画不播放。 | The playback policy lives in the icon component and follows the control's state: idle and not pulled, it rests on its first frame; idle and being pulled, an animation that can seek (Lottie, PAG) follows the pulling percent and others start playing (always play when `scrubsWhilePulling` is NO); pulling (release to refresh), refreshing and will-refresh loop it; returning to idle when loading ends stops it; no more data stops it. A `CYLPlaceholderItemAnimationRepeatCount` in the attributes keeps its count. With Reduce Motion on, animations do not play. |

## 布局 / Layout

| 中文 | English |
| --- | --- |
| 布局保持 CYLRefresh 原有策略：普通刷新头与返回式刷新尾放在箭头的位置（文字左侧），自动刷新尾放在菊花的位置，GIF 刷新头、尾放在 GIF 视图绘制图片的位置（居中，或靠右紧挨文字），trailer 放在箭头的位置。比箭头（约 15 点）或菊花更宽的图标保持它们原有的与文字的间距：CYLRefresh 的 `labelLeftInset` 是文字到箭头**中心**的距离，图标因此向远离文字的方向移动多出宽度的一半（`cyl_iconCenterReplacingCenter:replacedWidth:`）；trailer 的文字随图标多出的宽度右移。图标的尺寸取自当前状态属性中的 `CYLPlaceholderItemAnimationSize`（默认 30 × 30）。显示时机也与被替换的视图一致：返回式刷新尾在没有更多数据时隐藏，自动刷新尾只在加载时显示。图标对 VoiceOver 隐藏，由状态文字说明当前状态。 | Layout keeps CYLRefresh's own strategy: normal headers and back footers put the icon where the arrow was (left of the text), auto footers where the spinner was, GIF headers and footers where the GIF view draws its images (centered, or right-aligned next to the text), and trailers where the arrow was. An icon wider than the arrow (about 15 points) or the spinner keeps their gap to the text: CYLRefresh's `labelLeftInset` runs from the text to the arrow's **center**, so the icon moves away from the text by half the extra width (`cyl_iconCenterReplacingCenter:replacedWidth:`); a trailer's text moves over by the icon's extra width. The icon's size comes from `CYLPlaceholderItemAnimationSize` of the current state's attributes (30 × 30 by default). It also shows when the replaced view would: back footers hide it when there is no more data, auto footers show it only while loading. The icon is hidden from VoiceOver; the state label tells the state. |

### 图标与文字重叠的原因 / Why icons overlapped the text

| 中文 | English |
| --- | --- |
| 2026-11-11 修复：图标盖住 “Last update…” 文字有两层原因。主要原因在图标组件：`CYLPlaceholderView` 原为全屏占位图设计，两侧固定保留 16 点边距，内容在 `宽度 - 32` 内布局；放进约 30 点的图标后 item 宽度为 0，item 视图的 `layoutSubviews` 遇到空 frame 直接返回，动画保持初始 frame——从图标中心开始向右延伸，于是盖住文字。组件自带的边距在小 frame 中反而吞掉了空间。修复：`CYLPlaceholderView` 新增 `contentMargin`（默认 16，原有布局不变），视图放不下“无法缩小的内容 + 两侧边距”时先放弃边距；`CYLRefreshIconView` 把它设为 0。次要原因是 `labelLeftInset` 以箭头中心计量，适合 15 点箭头，30–48 点的图标放在同一中心时与文字只剩 1–10 点，现在图标保持箭头原有的边缘间距（见上）。测试：`testIconsNeverOverlapTheTextAndDrawInsideTheirFrame`、`testAPlaceholderGivesUpItsMarginsOnlyWhenTooNarrow`。 | Fixed 2026-11-11: icons covered "Last update…" for two reasons. The main one was in the icon component: `CYLPlaceholderView` was built as a full-screen placeholder and keeps a fixed 16-point margin on each side, laying its content out in `width - 32`; inside an icon of about 30 points the item got a width of 0, the item view's `layoutSubviews` returned early on the empty frame, and the animation kept its first frame, starting at the icon's center and running to the right over the text. The component's own margins swallowed the small frame instead of protecting it. Fix: `CYLPlaceholderView` gains `contentMargin` (16 by default, so other layouts are unchanged) and gives up the margins first when the view cannot fit content that cannot shrink plus both margins; `CYLRefreshIconView` sets it to 0. The second reason is that `labelLeftInset` is measured to the arrow's center, which suits a 15-point arrow but leaves a 30–48-point icon at the same center only 1–10 points from the text; the icon now keeps the arrow's edge gap (see above). Tests: `testIconsNeverOverlapTheTextAndDrawInsideTheirFrame`, `testAPlaceholderGivesUpItsMarginsOnlyWhenTooNarrow`. |

## 内置刷新动画 / Bundled refresh animations

| 中文 | English |
| --- | --- |
| 核心资源包 `CYLTableViewPlaceHolder.bundle/Animations/` 中以 `CYLRefresh` 开头的文件是为刷新控件准备的图标动画，均未修改，来源、commit、许可证与 SHA-256 记录在 `NOTICE.animations`。`CYLRefreshComponent.bundledIconAnimationFileNames`（Swift 同名类属性）按名称排序列出它们，以及内容同样表示刷新状态的占位动画；每个名称都可以直接传给 `setBundledIconAnimation:size:forState:`（Swift `setIconAnimation(bundled:size:for:)`），内置 Rive 文件需要的选项和线条图标的着色会自动带上。 | The files starting with `CYLRefresh` in the core bundle's `CYLTableViewPlaceHolder.bundle/Animations/` are icon animations made for refresh controls, all unmodified; their source, commit, license and SHA-256 are in `NOTICE.animations`. `CYLRefreshComponent.bundledIconAnimationFileNames` (the same class property in Swift) lists them sorted by name together with the placeholder animations whose content also shows a refresh state; each name can be passed to `setBundledIconAnimation:size:forState:` (Swift `setIconAnimation(bundled:size:for:)`), which adds the options a bundled Rive file needs and the tint of the line icons. |

| 文件 / File | 内容 / Content | 来源 / Source |
| --- | --- | --- |
| `CYLRefreshArrows.gif` | 旋转的刷新箭头 / turning refresh arrows | Kingfisher (MIT) |
| `CYLRefreshDots.json`, `CYLRefreshDotsPulse.json` | 跳动的圆点 / bouncing dots | lottie-ios (Apache-2.0) |
| `CYLRefreshStepLoader.json`, `CYLRefreshGradientSpinner.json` | 步进加载、渐变加载圈 / step loader, gradient spinner | lottie-ios (Apache-2.0) |
| `CYLRefreshSpinner.json`, `CYLRefreshSpinnerDots.json`, `CYLRefreshSpinnerRing.json` | 线条加载圈 / line spinners | useAnimations (MIT) |
| `CYLRefreshPullArrow.json`, `CYLRefreshLoadMore.json` | 下拉箭头、加载更多 / pull arrow, load more | useAnimations (MIT) |
| `CYLRefreshCycle.json`, `CYLRefreshDone.json` | 循环箭头、完成对勾 / cycle arrows, done check | useAnimations (MIT) |
| `CYLRefreshCheck.riv` | 填充的圆环（`animation: Loading`），状态机触发 `Check`/`Error` / a filling circle (`animation: Loading`); its state machine fires `Check` / `Error` | CYLTabBarController (MIT) |
| `CYLPlaceholderRefresh.json`, `CYLPlaceholderLoading.json`, `CYLPlaceholderLoadingInfinity.json`, `CYLPlaceholderLoading.pag`, `CYLPlaceholderPullHint.pag`, `CYLPlaceholderLoading.riv`, `CYLPlaceholderPullToRefresh.riv` | 同样适合刷新控件的占位动画 / placeholder animations that also suit a refresh control | 见 / see `NOTICE.animations` |

| 中文 | English |
| --- | --- |
| PAG：libpag 仓库中唯一有刷新含义的文件 `refreshing.pag` 已作为 `CYLPlaceholderLoading.pag` 提供，没有重复加入；其余 PAG 文件是场景或特效演示，不符合内置资源规则。 | PAG: the only file with a refresh meaning in the libpag repository, `refreshing.pag`, already ships as `CYLPlaceholderLoading.pag` and is not added twice; the other PAG files are scenes or effect demos, which the bundled-resource rule excludes. |

```swift
// [CN] 按内置文件名 / [EN] by bundled file name
header.setIconAnimation(bundled: "CYLRefreshPullArrow.json", size: CGSize(width: 28, height: 28), for: .idle)
header.setIconAnimation(bundled: "CYLRefreshArrows.gif", size: CGSize(width: 32, height: 32), for: .refreshing)
// [CN] 按文件路径 / [EN] by file path
footer.setIconAnimation(filePath: path, size: CGSize(width: 32, height: 32), for: .refreshing)
// [CN] 按 item 属性：Rive 状态机与触发输入 / [EN] by item attributes: a Rive state machine and its trigger input
header.setIconAnimation(attributes: [
    CYLPlaceholderItemAnimationFilePath: CYLPlaceholderView.path(forBundledAnimation: "CYLRefreshCheck.riv")!,
    CYLPlaceholderItemAnimationSize: [36, 36],
    CYLPlaceholderItemAnimationOptions: ["stateMachine": "State Machine 1", "triggerInput": "Check"],
], for: .refreshing)
```

| 中文 | English |
| --- | --- |
| 配置文件：示例的 `CYLScenarioExample.bundle/RefreshIcons/refresh-icons.json` 为 `header`、`footer` 的每个状态（`idle`、`pulling`、`refreshing`、`willRefresh`、`noMoreData`）写出 `file`、`size` 与可选的 `options`，由示例中的 `CYLRefreshIconConfiguration` 读取并调用上面的接口；这是示例层的格式，不是核心 API。 | Configuration file: the example's `CYLScenarioExample.bundle/RefreshIcons/refresh-icons.json` gives, for each state (`idle`, `pulling`, `refreshing`, `willRefresh`, `noMoreData`) of `header` and `footer`, a `file`, a `size` and optional `options`; the example's `CYLRefreshIconConfiguration` reads it and calls the API above. The format belongs to the example, not to the core API. |

## 演示与限制 / Demo and limits

| 中文 | English |
| --- | --- |
| `Examples/Example-Scenarios` 的“动态”Tab 使用 Lottie 下拉图标、PAG 刷新图标和 Lottie 加载尾；“交互流程 → 下拉刷新与上拉加载”使用 Rive 下拉图标和 GIF 加载尾；“动态”Tab 右上角的“刷新图标”页（`CYLRefreshIconListViewController`）按引擎分组列出 `bundledIconAnimationFileNames` 中的每一个文件，每个文件一个页面（刷新头与加载尾都使用该文件，右上角按钮可直接开始刷新），另有按文件路径、item 属性和配置文件设置的三个页面。单元测试见 `Tests/CYLRefreshIconTests.m`。 | The Feed tab of `Examples/Example-Scenarios` uses a Lottie pull icon, a PAG refreshing icon and a Lottie loading footer; "Flows → Refresh controls" uses a Rive pull icon and a GIF loading footer; the "Refresh icons" page at the top right of the Feed tab (`CYLRefreshIconListViewController`) lists every file of `bundledIconAnimationFileNames` grouped by engine, one page per file (header and footer both use it; the top-right button starts refreshing), plus three pages that set icons by file path, item attributes and a configuration file. Unit tests are in `Tests/CYLRefreshIconTests.m`. |
| 未验证：本机无法编译或运行，等待 CI；各引擎在刷新控件中的实际播放效果（尤其是 Rive 状态机文件与拖动定位）需要在模拟器中人工查看。箭头的旋转动画不适用于图标动画（图标由动画本身表达状态）。 | Not verified: nothing could be compiled or run here, so CI comes first; how each engine actually plays inside a refresh control (especially Rive state-machine files and scrubbing while pulling) needs a look in the simulator. The arrow's rotation does not apply to icon animations: the animation itself shows the state. |
