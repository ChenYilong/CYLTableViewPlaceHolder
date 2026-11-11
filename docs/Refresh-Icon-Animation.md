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
| [Rive 刷新图标的背景](#rive-刷新图标的背景--background-of-the-rive-refresh-icon) | [Background of the Rive refresh icon](#rive-刷新图标的背景--background-of-the-rive-refresh-icon) |

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
| 图标组件替换的是 MJRefresh 文档中的“动画图片”：`CYLRefreshAnimationHeader`、`CYLRefreshBackAnimationFooter`、`CYLRefreshAutoAnimationFooter`（MJRefreshGifHeader 等的通用名称，`setAnimationImages:forState:`；`CYLRefreshAnimationHeader`、`CYLRefreshBackAnimationFooter`、`CYLRefreshAutoAnimationFooter` 保留为子类，其 `gifView`、`setImages:…` 调用通用方法，旧代码不变）。它们采用 `CYLRefreshIconAnimating`，可以用本库的图标组件（`CYLRefreshIconView`，内部是 `CYLPlaceholderView`）代替动画图片：静态图片，或 GIF、Lottie、PAG、Rive 动画（Lottie、PAG、Rive 需要对应的子规格，GIF 由 Core 播放）。图标放在 动画视图绘制图片的位置，沿用其布局与显示时机；不设置图标动画时 `animationView` 与 `setAnimationImages:forState:` 照常工作。箭头样式的默认控件（`CYLRefreshNormalHeader`、`CYLRefreshBackNormalFooter`、`CYLRefreshAutoNormalFooter`、`CYLRefreshNormalTrailer`）保持 MJRefresh 原有的箭头与菊花，没有图标接口。 | The icon component replaces what the MJRefresh documentation calls the animated images: `CYLRefreshAnimationHeader`, `CYLRefreshBackAnimationFooter` and `CYLRefreshAutoAnimationFooter` (general names of MJRefreshGifHeader and friends, `setAnimationImages:forState:`; `CYLRefreshAnimationHeader`, `CYLRefreshBackAnimationFooter` and `CYLRefreshAutoAnimationFooter` stay as subclasses whose `gifView` and `setImages:…` call the general methods, so old code is unchanged). They adopt `CYLRefreshIconAnimating` and can draw the library's icon component (`CYLRefreshIconView`, built on `CYLPlaceholderView`) instead of the images: a static image, or a GIF, Lottie, PAG or Rive animation (Lottie, PAG and Rive need their subspec; Core plays GIF). The icon sits where the animation view draws its images, with its layout and show/hide timing; without an icon animation `animationView` and `setAnimationImages:forState:` work as before. The default arrow controls (`CYLRefreshNormalHeader`, `CYLRefreshBackNormalFooter`, `CYLRefreshAutoNormalFooter`, `CYLRefreshNormalTrailer`) keep MJRefresh's arrow and spinner and have no icon API. |

## 接口 / API

| 中文 | English |
| --- | --- |
| 在 `CYLRefreshIconAnimating`（三个“动画图片”控件采用，与 `setAnimationImages:forState:` 并列）上：`-setIconAnimationAttributes:forState:` 接受 `CYLPlaceholderView` 的 item 属性（动画文件、尺寸、选项、颜色等）；`-setIconAnimationFilePath:size:forState:` 接受任意本地动画文件；`-setBundledIconAnimation:size:forState:` 使用核心 bundle 中的内置动画并自动带上所需选项；类属性 `bundledIconAnimationFileNames` 列出适合刷新图标的内置动画。没有单独设置的状态使用空闲状态的图标，所以调用一次即可；也可以为下拉、刷新中等状态分别设置不同的图标。`iconView` 返回图标组件，`usesIconView` 表示是否已设置图标动画。自定义子类可以使用 `CYLRefreshComponent (CYLRefreshIconLayout)` 中的 `cyl_` 方法实现同样的替换。 | On `CYLRefreshIconAnimating` (adopted by the three animated-image controls, next to `setAnimationImages:forState:`): `-setIconAnimationAttributes:forState:` takes `CYLPlaceholderView` item attributes (animation file, size, options, colors…); `-setIconAnimationFilePath:size:forState:` takes any local animation file; `-setBundledIconAnimation:size:forState:` uses a bundled animation of the core and adds the options it needs; the class property `bundledIconAnimationFileNames` lists the bundled animations meant for a refresh icon. A state without its own icon uses the idle state's, so one call is enough; pulling, refreshing and other states can also each have their own icon. `iconView` returns the icon component, and `usesIconView` says whether an icon animation is set. Custom subclasses can do the same replacement with the `cyl_` methods of `CYLRefreshComponent (CYLRefreshIconLayout)`. |

```swift
// [CN] 下拉时显示 Lottie 箭头，刷新中显示 PAG 圆环；布局与文字仍由 CYLRefresh 决定
// [EN] A Lottie arrow while pulling, a PAG ring while refreshing; layout and texts stay CYLRefresh's own
let header = CYLRefreshAnimationHeader { [weak self] in self?.reload() }
header.setIconAnimation(bundled: "CYLPlaceholderRefresh.json", size: CGSize(width: 28, height: 28), for: .idle)
header.setIconAnimation(bundled: "CYLPlaceholderProgress.pag", size: CGSize(width: 32, height: 32), for: .refreshing)
tableView.cyl_header = header

let footer = CYLRefreshAutoAnimationFooter { [weak self] in self?.loadMore() }
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
| 2026-11-12 更正：图标与文字合为一个 `CYLPlaceholderView`。按用户要求，GIF 类控件（`CYLRefreshAnimationHeader` 与两个动画 footer，MJRefresh 的 GIF header 系列，不是箭头样式）设置图标动画后，把可见的状态文字与“最后更新”文字作为标题放进图标所在的同一个 `CYLPlaceholderView`（横向排列：图标在前，文字在后，垂直居中），整体在控件中居中；原文字标签淡出（保留调用方的 `hidden` 设置），VoiceOver 从该视图读取文字。图标与文字由同一个视图布局，不再分别计算位置，因此不会错位。文字变化时原地更新，动画不中断。`setAnimationImages:` 图片序列仍按 MJRefresh 原样由 GIF 视图绘制。下面一行描述的是此前的布局。 | 2026-11-12 correction: icon and text are one `CYLPlaceholderView`. As the user asked, once an icon animation is set the GIF-type controls (`CYLRefreshAnimationHeader` and the two animation footers, MJRefresh's GIF header family, not the arrow style) put the visible state text and the "last updated" text as the title into the same `CYLPlaceholderView` as the icon (horizontal: icon first, text after it, both centered vertically) and center that one view in the control; the labels fade out (keeping the caller's `hidden`) and VoiceOver reads the text from that view. Icon and text are laid out by one view instead of two separately computed positions, so they cannot drift apart. A new text updates in place without restarting the animation. `setAnimationImages:` sequences are still drawn by the GIF view, as in MJRefresh. The next row describes the earlier layout. |
| 布局沿用 GIF 视图：GIF 视图铺满控件的高度，图片垂直居中；没有文字时水平居中，有文字时靠右、与文字保持 `labelLeftInset`（GIF 控件为 20 点）的距离。图标放在同一位置：垂直方向在控件高度的中点，水平方向居中或右边缘与 GIF 视图的右边缘对齐，因此不存在横向或纵向的错位。图标的尺寸取自当前状态属性中的 `CYLPlaceholderItemAnimationSize`（默认 30 × 30），图标组件铺满图标的 frame。显示时机与 GIF 视图一致：返回式 GIF 刷新尾在没有更多数据时隐藏，自动 GIF 刷新尾只在加载时显示。图标对 VoiceOver 隐藏，由状态文字说明当前状态。 | Layout follows the GIF view: it spans the control's height with its images centered vertically; without text they are centered horizontally, with text they are right-aligned, `labelLeftInset` (20 points for the GIF controls) away from it. The icon goes in the same place: vertically at the middle of the control's height, horizontally centered or with its right edge on the GIF view's right edge, so there is no horizontal or vertical offset. Its size comes from `CYLPlaceholderItemAnimationSize` of the current state's attributes (30 × 30 by default), and the icon component fills the icon's frame. It shows when the GIF view would: back GIF footers hide it when there is no more data, auto GIF footers show it only while loading. The icon is hidden from VoiceOver; the state label tells the state. |

### 图标与文字重叠的原因 / Why icons overlapped the text

| 中文 | English |
| --- | --- |
| 2026-11-11 更正：图标最初替换了普通控件的箭头与菊花，箭头按“文字到箭头中心”的距离布局，换成更宽、更高的图标后出现横向重叠与纵向不居中。按用户要求，箭头控件已还原为 MJRefresh 原样，图标改为替换“动画图片”（GIF 视图），其布局天然以控件高度居中并靠右紧挨文字。下表记录的组件边距问题仍然成立并已修复（`contentMargin`）。 | Correction 2026-11-11: the icon first replaced the arrow and spinner of the default controls, which lay the arrow out by its center's distance to the text, so wider and taller icons overlapped horizontally and sat off-center vertically. As the user asked, the arrow controls are back to MJRefresh's own, and the icon now replaces the animated images (the GIF view), whose layout centers in the control's height and right-aligns next to the text. The component margin problem below still applies and stays fixed (`contentMargin`). |

| 中文 | English |
| --- | --- |
| 2026-11-11 修复：图标盖住 “Last update…” 文字有两层原因。主要原因在图标组件：`CYLPlaceholderView` 原为全屏占位图设计，两侧固定保留 16 点边距，内容在 `宽度 - 32` 内布局；放进约 30 点的图标后 item 宽度为 0，item 视图的 `layoutSubviews` 遇到空 frame 直接返回，动画保持初始 frame——从图标中心开始向右延伸，于是盖住文字。组件自带的边距在小 frame 中反而吞掉了空间。修复：`CYLPlaceholderView` 新增 `contentMargin`（默认 16，原有布局不变），视图放不下“无法缩小的内容 + 两侧边距”时先放弃边距；`CYLRefreshIconView` 把它设为 0。次要原因是 `labelLeftInset` 以箭头中心计量，适合 15 点箭头，30–48 点的图标放在同一中心时与文字只剩 1–10 点，现在图标保持箭头原有的边缘间距（见上）。测试：`testIconsNeverOverlapTheTextAndDrawInsideTheirFrame`、`testAPlaceholderGivesUpItsMarginsOnlyWhenTooNarrow`。 | Fixed 2026-11-11: icons covered "Last update…" for two reasons. The main one was in the icon component: `CYLPlaceholderView` was built as a full-screen placeholder and keeps a fixed 16-point margin on each side, laying its content out in `width - 32`; inside an icon of about 30 points the item got a width of 0, the item view's `layoutSubviews` returned early on the empty frame, and the animation kept its first frame, starting at the icon's center and running to the right over the text. The component's own margins swallowed the small frame instead of protecting it. Fix: `CYLPlaceholderView` gains `contentMargin` (16 by default, so other layouts are unchanged) and gives up the margins first when the view cannot fit content that cannot shrink plus both margins; `CYLRefreshIconView` sets it to 0. The second reason is that `labelLeftInset` is measured to the arrow's center, which suits a 15-point arrow but leaves a 30–48-point icon at the same center only 1–10 points from the text; the icon now keeps the arrow's edge gap (see above). Tests: `testIconsNeverOverlapTheTextAndDrawInsideTheirFrame`, `testAPlaceholderGivesUpItsMarginsOnlyWhenTooNarrow`. |

## 内置刷新动画 / Bundled refresh animations

| 中文 | English |
| --- | --- |
| 核心资源包 `CYLTableViewPlaceHolder.bundle/Animations/` 中以 `CYLRefresh` 开头的文件是为刷新控件准备的图标动画，均未修改，来源、commit、许可证与 SHA-256 记录在 `NOTICE.animations`。`CYLRefreshAnimationHeader.bundledIconAnimationFileNames`（`CYLRefreshIconAnimating` 的类属性，Swift 同名）按名称排序列出它们，以及内容同样表示刷新状态的占位动画；每个名称都可以直接传给 `setBundledIconAnimation:size:forState:`（Swift `setIconAnimation(bundled:size:for:)`），内置 Rive 文件需要的选项和线条图标的着色会自动带上。 | The files starting with `CYLRefresh` in the core bundle's `CYLTableViewPlaceHolder.bundle/Animations/` are icon animations made for refresh controls, all unmodified; their source, commit, license and SHA-256 are in `NOTICE.animations`. `CYLRefreshAnimationHeader.bundledIconAnimationFileNames` (a class property of `CYLRefreshIconAnimating`, the same in Swift) lists them sorted by name together with the placeholder animations whose content also shows a refresh state; each name can be passed to `setBundledIconAnimation:size:forState:` (Swift `setIconAnimation(bundled:size:for:)`), which adds the options a bundled Rive file needs and the tint of the line icons. |

| 文件 / File | 内容 / Content | 来源 / Source |
| --- | --- | --- |
| `CYLRefreshArrows.gif` | 旋转的刷新箭头 / turning refresh arrows | Kingfisher (MIT) |
| `CYLRefreshRing.gif`, `CYLRefreshActivity.gif`, `CYLRefreshPetals.gif`, `CYLRefreshThrobber.gif` | 渐变圆环、灰色辐条、橙色花瓣、小号辐条加载圈 / gradient ring, grey spokes, orange petals and small spoke spinners | lightbox2, blueimp Gallery, colorbox, jstree (MIT) |
| `CYLRefreshPullArrow.json`, `CYLRefreshPullCircle.json` | 下拉箭头、圆圈中的下拉箭头 / pull arrow, pull arrow in a circle | useAnimations (MIT) |
| `CYLRefreshCycle.json`, `CYLRefreshClockwise.json`, `CYLRefreshCounterClockwise.json` | 循环、顺时针、逆时针刷新箭头 / cycle, clockwise and counter-clockwise refresh arrows | useAnimations (MIT) |
| `CYLRefreshSpinnerRing.json`, `CYLRefreshArc.json` | 辐条加载圈、弧形加载圈 / spoke spinner, arc spinner | useAnimations (MIT) |
| `CYLRefreshGradientSpinner.json`, `CYLRefreshDots.json`, `CYLRefreshDotsPulse.json` | 渐变加载圈、跳动的圆点 / gradient spinner, bouncing dots | lottie-ios (Apache-2.0) |
| `CYLRefreshMaterialSpinner.json`, `CYLRefreshDonePop.json` | Material 弧形加载圈、弹出的完成对勾 / Material arc spinner, popping done check | lottie-android (Apache-2.0) |
| `CYLRefreshLoadMore.json`, `CYLRefreshMoreDots.json` | 加载更多的箭头与圆点 / load-more chevrons and dots | useAnimations (MIT) |
| `CYLRefreshDone.json`, `CYLRefreshDoneCircle.json` | 完成对勾、圆圈中的对勾 / done check, check in a circle | useAnimations (MIT) |
| `CYLRefreshIcon.riv` | 刷新图标画板 `refresh`：`idle` 静止，`active` 旋转；背景透明（2026-11-12 起，原文件的灰色 `BG` 圆角矩形填充改为透明，见下方说明）/ the `refresh` artboard: `idle` rests, `active` turns; transparent background (since 2026-11-12 the grey `BG` rounded rectangle of the original file is transparent, see the note below) | rive-flutter (MIT) |
| `CYLPlaceholderRefresh.json`, `CYLPlaceholderProgress.pag` | 同样表示刷新的两个占位动画：旋转箭头、随进度填满的圆环 / the two placeholder animations that also mean refresh: turning arrows, a ring that fills with progress | useAnimations (MIT), libpag (Apache-2.0) |

| 中文 | English |
| --- | --- |
| 2026-11-11 清理：只保留内容表示刷新状态的文件。删除了 `CYLRefreshSpinner.json`（方块网格）、`CYLRefreshSpinnerDots.json`（单个圆点）、`CYLRefreshStepLoader.json`（彩色台阶）与 `CYLRefreshCheck.riv`（默认显示红色叉号）；`CYLPlaceholderLoading.pag`（紫色播放箭头）、`CYLPlaceholderPullHint.pag`（手势）、`CYLPlaceholderLoading.riv`（深色方块）、`CYLPlaceholderPullToRefresh.riv`（墓地场景）与 `CYLPlaceholderLoadingInfinity.json` 不再列入刷新图标（仍是占位动画）。新增 13 个刷新文件（见上表）。每个文件都逐帧渲染查看过。 | 2026-11-11 cleanup: only files whose content means a refresh state stay. Removed `CYLRefreshSpinner.json` (a block grid), `CYLRefreshSpinnerDots.json` (a single dot), `CYLRefreshStepLoader.json` (coloured steps) and `CYLRefreshCheck.riv` (a red cross by default); `CYLPlaceholderLoading.pag` (purple play arrows), `CYLPlaceholderPullHint.pag` (a hand), `CYLPlaceholderLoading.riv` (a dark tile), `CYLPlaceholderPullToRefresh.riv` (a graveyard scene) and `CYLPlaceholderLoadingInfinity.json` are no longer listed as refresh icons (they stay placeholder animations). Added 13 refresh files (table above). Every file was rendered frame by frame and looked at. |
| PAG：libpag 及其 iOS、Android、Web、文档、Flutter 仓库的全部历史中，只有 `refreshing.pag`（即 `CYLPlaceholderLoading.pag`，实际画面是播放箭头）与 `wstask_circle.pag`（即 `CYLPlaceholderProgress.pag`，进度圆环）名称与刷新有关；其余约 35 个文件是吉祥物、贴纸、表情、文字测试或标志。所以 PAG 刷新图标目前只有 `CYLPlaceholderProgress.pag`。 | PAG: in the whole history of libpag and its iOS, Android, Web, docs and Flutter repositories, only `refreshing.pag` (that is `CYLPlaceholderLoading.pag`, which actually shows play arrows) and `wstask_circle.pag` (that is `CYLPlaceholderProgress.pag`, a progress ring) have refresh-like names; the other ~35 files are mascots, stickers, emoji, text tests or logos. So the only PAG refresh icon for now is `CYLPlaceholderProgress.pag`. |

```swift
// [CN] 按内置文件名 / [EN] by bundled file name
header.setIconAnimation(bundled: "CYLRefreshPullArrow.json", size: CGSize(width: 28, height: 28), for: .idle)
header.setIconAnimation(bundled: "CYLRefreshArrows.gif", size: CGSize(width: 32, height: 32), for: .refreshing)
// [CN] 按文件路径 / [EN] by file path
footer.setIconAnimation(filePath: path, size: CGSize(width: 32, height: 32), for: .refreshing)
// [CN] 按 item 属性：Rive 画板与动画 / [EN] by item attributes: a Rive artboard and animation
header.setIconAnimation(attributes: [
    CYLPlaceholderItemAnimationFilePath: CYLPlaceholderView.path(forBundledAnimation: "CYLRefreshIcon.riv")!,
    CYLPlaceholderItemAnimationSize: [32, 32],
    CYLPlaceholderItemAnimationOptions: ["legacy": "1", "artboard": "refresh", "animation": "active"],
], for: .refreshing)
// [CN] 图片序列（MJRefresh 的“动画图片”），这里取自内置刷新 GIF 的帧 / [EN] an image sequence (MJRefresh's "animated images"), here the frames of a bundled refresh GIF
header.setAnimationImages(frames, duration: 0.6, for: .refreshing)
```

| 中文 | English |
| --- | --- |
| 配置文件：示例的 `CYLScenarioExample.bundle/RefreshIcons/refresh-icons.json` 为 `header`、`footer` 的每个状态（`idle`、`pulling`、`refreshing`、`willRefresh`、`noMoreData`）写出 `file`、`size` 与可选的 `options`，由示例中的 `CYLRefreshIconConfiguration` 读取并调用上面的接口；这是示例层的格式，不是核心 API。 | Configuration file: the example's `CYLScenarioExample.bundle/RefreshIcons/refresh-icons.json` gives, for each state (`idle`, `pulling`, `refreshing`, `willRefresh`, `noMoreData`) of `header` and `footer`, a `file`, a `size` and optional `options`; the example's `CYLRefreshIconConfiguration` reads it and calls the API above. The format belongs to the example, not to the core API. |

## 演示与限制 / Demo and limits

| 中文 | English |
| --- | --- |
| `Examples/Example-Scenarios` 只使用刷新资源：“动态”Tab 的刷新头下拉时显示 Lottie 下拉箭头、松开时显示顺时针刷新箭头、刷新中显示 PAG 进度圆环，加载尾显示 GIF 圆环；“交互流程 → 下拉刷新与上拉加载”保留默认箭头刷新头，加载尾显示 GIF 辐条加载圈。“动态”Tab 右上角的“刷新图标”页（`CYLRefreshIconListViewController`）按引擎分组第一组演示保持原样的默认箭头样式（`CYLRefreshNormalHeader` 搭配自动与返回式刷新尾：下拉时箭头翻转、刷新中菊花代替箭头），随后列出 `bundledIconAnimationFileNames` 中的每个文件（每个文件一个演示页），第二组演示动画图片控件的全部接口：按状态设置图片序列 `setAnimationImages(_:for:)` / `(_:duration:for:)`（帧取自内置刷新 GIF）、每个状态不同的内置图标、返回式刷新尾 `CYLRefreshBackAnimationFooter`、按文件路径、按 item 属性（Rive 画板与动画）、按配置文件，以及 MJRefresh 名称 `CYLRefreshGifHeader` / `CYLRefreshAutoGifFooter` 的 `setImages(_:for:)` 兼容写法。 | `Examples/Example-Scenarios` uses refresh resources only: the Feed tab header shows a Lottie pull arrow while pulling, clockwise refresh arrows when released and a PAG progress ring while refreshing, and its footer loads with a GIF ring; "Flows → Pull to refresh and load more" keeps the default arrow header and its footer loads with a GIF spoke spinner. The "Refresh icons" page (top right of the Feed tab, `CYLRefreshIconListViewController`) first shows the default arrow style, unchanged (`CYLRefreshNormalHeader` with the auto and back footers: the arrow flips while pulling and a spinner replaces it while refreshing), then lists every file of `bundledIconAnimationFileNames` grouped by engine (one demo page per file), and its second section shows every API of the animated-image controls: an image sequence per state with `setAnimationImages(_:for:)` / `(_:duration:for:)` (frames of bundled refresh GIFs), a different bundled icon per state, the back footer `CYLRefreshBackAnimationFooter`, by file path, by item attributes (a Rive artboard and animation), by configuration file, and the MJRefresh names `CYLRefreshGifHeader` / `CYLRefreshAutoGifFooter` with `setImages(_:for:)`. |
| 已验证（2026-11-12，本机 Xcode 27、iOS 27.2 模拟器，Example-Scenarios › 刷新）：example51–56 的刷新头与加载尾在刷新中状态下，图标和状态文字在同一个 `CYLPlaceholderView` 中整体居中（截图如下，从上到下：example51–56 的刷新头，然后是它们的加载尾）；144 个单元测试通过。example52 的 Lottie 加载圈第一帧几乎是空的。example55 使用 `setImages`：图片序列同样由图标的 `CYLPlaceholderView` 绘制（见下一行）。箭头的旋转动画不适用于图标动画（图标由动画本身表达状态）。 | Verified (2026-11-12, local Xcode 27, iOS 27.2 simulator, Example-Scenarios › Refresh): in the refreshing state, the headers and footers of example51–56 show the icon and the state text centered as one `CYLPlaceholderView` (screenshot below, top to bottom: the headers of example51–56, then their footers); 144 unit tests pass. The first frame of example52's Lottie spinner is almost empty. example55 uses `setImages`: its image sequence is drawn by the icon's `CYLPlaceholderView` too (next row). The arrow's rotation does not apply to icon animations: the animation itself shows the state. |
| 图片序列（2026-11-12）：`setAnimationImages:forState:` / `setImages:forState:` 的图片不再由 `animationView`（`gifView`）绘制，而是作为该状态的图标交给 `CYLPlaceholderView`（`CYLPlaceholderItemImage`），与状态文字合为一个整体居中，和 GIF/Lottie/PAG/Rive 图标走同一条路径（`-cyl_setIconImages:duration:forState:`）。多张图片作为一张动画图片（`+[UIImage animatedImageWithImages:duration:]`）播放；空闲状态显示静止帧，下拉时按 `pullingPercent` 选帧，与 MJRefresh 相同；空闲状态没有自己的图片时使用第一张图片；开启“减弱动态效果”时第一张图片保持静止。兼容性：`animationView` / `gifView` 仍然存在但隐藏，直接修改它（`contentMode`、约束、`image`）不再影响显示。 | Image sequences (2026-11-12): the images of `setAnimationImages:forState:` / `setImages:forState:` are no longer drawn by `animationView` (`gifView`); they become the state's icon in a `CYLPlaceholderView` (`CYLPlaceholderItemImage`), centered as one with the state text, on the same path as GIF, Lottie, PAG and Rive icons (`-cyl_setIconImages:duration:forState:`). Several images play as one animated image (`+[UIImage animatedImageWithImages:duration:]`); the idle state shows a still frame picked by `pullingPercent` while pulling, as in MJRefresh; an idle state without its own images uses the first image; with Reduce Motion on, the first image stays still. Compatibility: `animationView` / `gifView` still exist but are hidden, so changing them directly (`contentMode`, constraints, `image`) no longer affects what is shown. |

![刷新图标动画：example51–56 的刷新头与加载尾 / Refresh icon animations: the headers and footers of example51–56](assets/cyl-refresh-icon-animations.png)

## Rive 刷新图标的背景 / Background of the Rive refresh icon

| 中文 | English |
|:---|:---|
| **修复（2026-11-12）**：`CYLRefreshIcon.riv` 作为刷新图标时显示深灰色方块（CYLTabBarController 示例「消息」页）。原因在文件本身：rive-flutter 的 `web_icons_pack.riv` 每个画板都有名为 `BG` 的 408×408 圆角矩形，填充为 `#ff6f6e6e`；视图层（`RiveView` / `RiveUIView`）的背景已经是透明的，RiveRuntime 也没有隐藏某个形状的 API。修复：只把这 6 个 `BG` 填充颜色的 alpha 改为 0（文件中 6 个字节），其他内容不变；`NOTICE.animations` 记录修改与新旧 SHA-256。`AGENTS.md` 与 `instructions.md` 中「资源保持原样」的规则增加了这一例外（经维护者同意）：文件自带的背景填充可以改为透明，其他不改。验证：本地 macOS 27.3、Xcode 27.2，iOS 26.1 iPhone 17 Pro，CYLTabBarController 示例「消息」页刷新中，箭头在透明背景上旋转（下图）。其他 Rive 文件（如 `CYLPlaceholderLoading.riv` 的画板填充）同样自带背景，作为占位图时不受影响，未修改。 | **Fix (2026-11-12)**: `CYLRefreshIcon.riv` as a refresh icon showed a dark grey square (the Messages page of the CYLTabBarController example). The cause is the file itself: every artboard of rive-flutter's `web_icons_pack.riv` has a 408 × 408 rounded rectangle named `BG`, filled `#ff6f6e6e`; the views (`RiveView` / `RiveUIView`) already have a clear background, and RiveRuntime has no API to hide a shape. Fix: only the alpha of these 6 `BG` fill colors is set to 0 (6 bytes in the file), nothing else changes; `NOTICE.animations` records the change and the old and new SHA-256. The "keep resources unmodified" rule in `AGENTS.md` and `instructions.md` gets this exception (approved by the maintainer): a background fill baked into a file may be made transparent, nothing else. Verified locally on macOS 27.3 with Xcode 27.2, iOS 26.1 iPhone 17 Pro: on the CYLTabBarController example's Messages page, while refreshing, the arrow turns on a transparent background (picture below). Other Rive files (such as the artboard fill of `CYLPlaceholderLoading.riv`) have backgrounds too; as placeholders they are not affected and are left unmodified. |

![Rive refresh icon with a transparent background](assets/refresh-icon-rive-transparent-ios.png)

| 中文 | English |
| --- | --- |
| 已验证（2026-11-12，合并 `fix/rive-refresh-icon-background` 后，本机 Xcode 27、iOS 27.2 模拟器）：Example-Scenarios 从清空的 DerivedData 重新编译，App 内 `CYLRefreshIcon.riv` 的 SHA-256 为 `5d2f453c…401c3`（与修复后的文件一致）；“刷新 → example54”的刷新头（下拉后刷新中）与加载尾（点按加载中）都在透明背景上显示旋转箭头，没有深灰色方块（下图从上到下）。`scripts/animation-tests.sh static PAG` 的 19 个测试（含 10 个 Rive 测试）全部通过。 | Verified (2026-11-12, after merging `fix/rive-refresh-icon-background`, local Xcode 27, iOS 27.2 simulator): Example-Scenarios rebuilt from empty derived data, and the app's `CYLRefreshIcon.riv` has SHA-256 `5d2f453c…401c3` (the fixed file); on "Refresh → example54" the header (refreshing after a pull) and the footer (loading after a tap) both show the turning arrow on a transparent background, with no dark grey square (below, top to bottom). All 19 tests of `scripts/animation-tests.sh static PAG` pass, 10 of them Rive tests. |

![example54：Rive 刷新图标在透明背景上（刷新头、加载尾） / example54: the Rive refresh icon on a transparent background (header, footer)](assets/cyl-refresh-rive-transparent.png)
