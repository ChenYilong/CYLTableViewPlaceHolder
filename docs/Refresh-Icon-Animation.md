# 刷新控件的动画图标 / Animated icons for the refresh controls

<!-- bound-classes: CYLRefreshIconView, CYLRefreshComponent -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [概述](#概述--overview) | [Overview](#概述--overview) |
| [接口](#接口--api) | [API](#接口--api) |
| [播放策略](#播放策略--playback-policy) | [Playback policy](#播放策略--playback-policy) |
| [布局](#布局--layout) | [Layout](#布局--layout) |
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
| 布局保持 CYLRefresh 原有策略：普通刷新头与返回式刷新尾放在箭头的中心（文字左侧），自动刷新尾放在菊花的位置，GIF 刷新头、尾放在 GIF 视图绘制图片的位置（居中，或靠右紧挨文字），trailer 放在箭头的位置且文字仍按箭头显示时布局。图标的尺寸取自当前状态属性中的 `CYLPlaceholderItemAnimationSize`（默认 30 × 30）。显示时机也与被替换的视图一致：返回式刷新尾在没有更多数据时隐藏，自动刷新尾只在加载时显示。图标对 VoiceOver 隐藏，由状态文字说明当前状态。 | Layout keeps CYLRefresh's own strategy: normal headers and back footers center the icon where the arrow was (left of the text), auto footers where the spinner was, GIF headers and footers where the GIF view draws its images (centered, or right-aligned next to the text), and trailers where the arrow was, with the text still laid out as if the arrow showed. The icon's size comes from `CYLPlaceholderItemAnimationSize` of the current state's attributes (30 × 30 by default). It also shows when the replaced view would: back footers hide it when there is no more data, auto footers show it only while loading. The icon is hidden from VoiceOver; the state label tells the state. |

## 演示与限制 / Demo and limits

| 中文 | English |
| --- | --- |
| `Examples/Example-Scenarios` 的“动态”Tab 使用 Lottie 下拉图标、PAG 刷新图标和 Lottie 加载尾；“交互流程 → 下拉刷新与上拉加载”使用 Rive 下拉图标和 GIF 加载尾。单元测试见 `Tests/CYLRefreshIconTests.m`。 | The Feed tab of `Examples/Example-Scenarios` uses a Lottie pull icon, a PAG refreshing icon and a Lottie loading footer; "Flows → Refresh controls" uses a Rive pull icon and a GIF loading footer. Unit tests are in `Tests/CYLRefreshIconTests.m`. |
| 未验证：本机无法编译或运行，等待 CI；各引擎在刷新控件中的实际播放效果（尤其是 Rive 状态机文件与拖动定位）需要在模拟器中人工查看。箭头的旋转动画不适用于图标动画（图标由动画本身表达状态）。 | Not verified: nothing could be compiled or run here, so CI comes first; how each engine actually plays inside a refresh control (especially Rive state-machine files and scrubbing while pulling) needs a look in the simulator. The arrow's rotation does not apply to icon animations: the animation itself shows the state. |
