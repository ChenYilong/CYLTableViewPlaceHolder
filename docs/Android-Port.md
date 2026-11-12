# Android 版本 / Android port

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [任务](#任务--tasks) | [Tasks](#任务--tasks) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

## 任务 / Tasks

### TODO：Android 端合并三个刷新库并对齐 iOS 接口 / TODO: An Android merge of three refresh libraries, aligned with the iOS API

| 中文 | English |
| --- | --- |
| 状态：进行中（2026-11-13 开始，分支 `feat/android-refresh-port`，来源分支 `feat/android-placeholder`：另一会话已在那里建好 `android/` Gradle 工程与 `placeholder` 模块（PR #27），本任务的模块加在同一工程里，避免两个根工程冲突）。 | Status: in progress (started 2026-11-13, branch `feat/android-refresh-port`, source branch `feat/android-placeholder`: another session already set up the `android/` Gradle project with the `placeholder` module there (PR #27); this task's modules join the same project, so there are not two conflicting root projects). |
| 进度 2026-11-13：①来源项目盘点（下表）；②下一步按 “Translating or porting another project” 先处理 open PR（合并进待翻译的源码），再建 open issue 表，issue 达到 60 分后开始翻译；③翻译顺序按规模从小到大：SVPullToRefresh → android-Ultra-Pull-To-Refresh → SmartRefreshLayout，最后合并到 `android/merged`。 | Progress 2026-11-13: (1) the source projects inventoried (table below); (2) next, per "Translating or porting another project": the open pull requests first (merged into the source to translate), then the open-issue tables, and translation starts once the issues reach 60; (3) translation from the smallest: SVPullToRefresh → android-Ultra-Pull-To-Refresh → SmartRefreshLayout, then the merge into `android/merged`. |
| 用户原始提示词：“将下面的任务，找一个合适的文档，标注关键词TODO：注意本任务仅仅修改android代码，不要改iOS代码。在本项目中新建文件夹命名为 android ，下面的代码 每一个仓库 创建一个文件夹，并创建第四个文件夹命名为merged     <https://github.com/scwang90/SmartRefreshLayout>    <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh>   同样要求处理 <https://github.com/samvermette/SVPullToRefresh> 第二步骤：分别将这三个项目在各自文件夹中做代码转录，全部翻译为kotlin语言。第三步骤：将以上几个文件夹里的kotlin代码合并为一个项目，保留所有api接口，并将example合并为一个。使用CYLTabBarController 的android端tabbar 作为展示的功能划分，采用gradle或者maven指向CYLTabBarController 最新提交，找到gradle或者maven使用commit引用的方式集成，如果不行就采用本地路径引用。一个example一个tabbaritem区分。第四步骤：在docs在合适的文档或创建文档，列出iOS端所有的公开api，第二列 ，列出找到的在该merged文件夹下所有的公开api的对应项。第五步，将缺失merged文件夹缺失的API对齐。在该表格未对齐的地方标注TODO如果iOS端和android能完全对齐所有api就是满分，merged文件夹每次新增一个api就在该文档中打分，一直达到满分。第六步骤：将iOS端的example全部移植到merged文件夹，注意是翻译，不要改iOS代码。使用上面提到的表格中android的api实现。并截图更新文档，readme 在android章节。” | The user's original prompt (Chinese, verbatim on the left), summarized: record this task as a TODO in a fitting document. Change only Android code, never iOS code. Create an `android` folder in this project with one folder per repository below plus a fourth folder named `merged`: SmartRefreshLayout, android-Ultra-Pull-To-Refresh and SVPullToRefresh. Step 2: transcribe each project in its own folder, all translated to Kotlin. Step 3: merge the Kotlin code of those folders into one project, keeping every API, and merge the examples into one; use CYLTabBarController's Android tab bar to divide the demos, depend on CYLTabBarController's latest commit through Gradle or Maven by commit reference, or by local path if that fails; one example per tab item. Step 4: in docs, list every public iOS API, and in a second column the matching public API found in `merged`. Step 5: add the API `merged` lacks; mark unaligned rows TODO; full alignment is full marks; score in that document after every API added to `merged`, until full marks. Step 6: port every iOS example to `merged` by translation (without changing iOS code), using the Android API from the table; take screenshots and update the docs and the README's Android section. |
| 要求：①只改 Android 代码，不改 iOS 代码；②新建 `android/`，下分 `SmartRefreshLayout/`、`android-Ultra-Pull-To-Refresh/`、`SVPullToRefresh/` 与 `merged/` 四个文件夹；③三个项目分别转写为 Kotlin（SVPullToRefresh 原为 iOS Objective-C，同样转写为 Kotlin）；④合并为一个 Kotlin 项目，保留全部 API，示例合并为一个，用 CYLTabBarController 的 Android 端 tab bar 分区，每个示例一个 tab；⑤依赖 CYLTabBarController 最新提交：优先 Gradle/Maven 的 commit 引用（如 JitPack），不行就用本地路径；⑥docs 中列出 iOS 全部公开 API 与 `merged` 中的对应项，未对齐处标 TODO，每新增一个 API 更新评分，直到满分；⑦把 iOS 端全部示例翻译移植到 `merged`，使用表中的 Android API；⑧截图，更新文档与 README 的 Android 章节。 | Requirements: (1) change only Android code, never iOS code; (2) create `android/` with four folders: `SmartRefreshLayout/`, `android-Ultra-Pull-To-Refresh/`, `SVPullToRefresh/` and `merged/`; (3) transcribe each project to Kotlin (SVPullToRefresh is iOS Objective-C and is transcribed to Kotlin too); (4) merge into one Kotlin project keeping every API, with one merged example divided by CYLTabBarController's Android tab bar, one tab per example; (5) depend on CYLTabBarController's latest commit: a Gradle/Maven commit reference first (JitPack, for example), else a local path; (6) in docs, list every public iOS API with its `merged` counterpart, mark unaligned rows TODO, and update the score after every added API until full marks; (7) port every iOS example to `merged` by translation, using the Android API from the table; (8) take screenshots and update the docs and the README's Android section. |
| 上下文：本仓库目前只有 iOS（Objective-C 核心、Swift 示例）。CYLTabBarController 仓库在本机 vault 的 `CYLTabBarController/`，其 `CrossPlatform/` 中有 Android 相关内容（JDK/Flutter 路径见 memory “CYLTabBarController cross-platform components”），Android 端 tab bar 的具体模块名与 commit 引用方式待开工时核实。三个上游项目的许可证、提交号与规模待开工时记录。iOS 公开 API 的来源是 `CYLTableViewPlaceHolder/` 下的公开头文件（含 CYLRefresh）；同时进行的 `docs/Refresh-Library-Parity.md` 任务会继续增加 iOS API，表格需以开工时的头文件为准。 | Context: this repository is iOS only today (Objective-C core, Swift examples). The CYLTabBarController repository is in this vault at `CYLTabBarController/`; its `CrossPlatform/` holds Android-related work (JDK and Flutter paths in the memory "CYLTabBarController cross-platform components"); the Android tab bar's module name and how to reference a commit are to be checked when work starts. The three upstream projects' licenses, commits and sizes are to be recorded then. The iOS public API comes from the public headers under `CYLTableViewPlaceHolder/` (CYLRefresh included); the parallel task in `docs/Refresh-Library-Parity.md` keeps adding iOS API, so the table follows the headers as they are when work starts. |

| 来源项目 / Source | 许可证 / License | 提交 / Commit | 规模 / Size | open PR | open issue |
| --- | --- | --- | --- | --- | --- |
| <https://github.com/samvermette/SVPullToRefresh>（iOS，Objective-C） | MIT | `a5f9dfe`（2013-09-26） | 库约 44 KB、10 个源文件 / library about 44 KB, 10 source files | 43 | 103 |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh>（Java） | MIT | `46fdc86`（2016-05-04） | 库约 128 KB、示例约 109 KB / library about 128 KB, demo about 109 KB | 23 | 151 |
| <https://github.com/scwang90/SmartRefreshLayout>（Java） | Apache-2.0 | `224db48`（2024-11-26） | 库约 720 KB（kernel 276 KB、header 256 KB 等）、示例约 329 KB / library about 720 KB (kernel 276 KB, headers 256 KB, …), demo about 329 KB | 5 | 337 |

### SVPullToRefresh → Kotlin（`android/SVPullToRefresh`，2026-11-13）

| 中文 | English |
| --- | --- |
| 第一步已完成：模块 `:SVPullToRefresh`（包 `com.cyl.svpulltorefresh`，保留原库类名与 MIT 许可证 `LICENSE.txt`），文案七种语言；Robolectric 测试 11 个全部通过（`SVPullToRefreshLayoutTest`，在 `/tmp` 镜像里用 JDK 17 运行，因为 exFAT 卷上的 `._*` 文件会让 Gradle 失败）。iOS 的 UIScrollView 分类在 Android 上没有可扩展的滚动视图，改为包住一个滚动视图的容器；RecyclerView、NestedScrollView 通过嵌套滚动传递拖动，其他视图通过触摸拦截。剩余：#195 可继承的刷新视图、横向加载更多与 inset 的测试、示例与模拟器截图、PR 与 issue 表的逐行状态。 | Step one done: module `:SVPullToRefresh` (package `com.cyl.svpulltorefresh`, the source's class names and its MIT `LICENSE.txt`), texts in seven languages; 11 Robolectric tests pass (`SVPullToRefreshLayoutTest`, run in a `/tmp` mirror with JDK 17, since `._*` files on the exFAT volume break Gradle). Android has no scroll view to extend with a category, so the UIScrollView categories become a container around one scrolling view; RecyclerView and NestedScrollView drag through nested scrolling, other views through touch interception. Left: #195 subclassable refresh view, tests for horizontal infinite scrolling and the insets, the demo and emulator screenshots, and per-row statuses in the pull request and issue tables. |

| iOS（SVPullToRefresh） | Kotlin |
| --- | --- |
| `UIScrollView (SVPullToRefresh)` | `SVPullToRefreshLayout`（包住一个滚动视图的容器 / a container around one scrolling view） |
| `addPullToRefreshWithActionHandler:` / `…position:` | `addPullToRefresh(position = TOP) { }`；顶部与底部可同时存在 / top and bottom together (#158) |
| `triggerPullToRefresh` | `triggerPullToRefresh(position = TOP)` |
| `pullToRefreshView` / `showsPullToRefresh` | `pullToRefreshView`、`pullToRefreshView(position)` / `showsPullToRefresh` |
| `SVPullToRefreshPosition` / `SVPullToRefreshState` | `SVPullToRefreshPosition` / `SVPullToRefreshState`（enum class） |
| `SVPullToRefreshView`：`arrowColor` / `textColor` / `titleLabel` / `subtitleLabel` / `activityIndicatorViewColor` / `state` / `position` | 同名属性 / the same names |
| `setTitle:forState:` / `setSubtitle:forState:` / `setCustomView:forState:` | `setTitle` / `setSubtitle` / `setCustomView(view, state)`；`ALL` 设置全部状态 / `ALL` sets every state |
| `startAnimating` / `stopAnimating` | `startAnimating()` / `stopAnimating()` |
| `activityIndicatorViewStyle` | 不适用：Android 的 ProgressBar 没有这种样式枚举，颜色用 `activityIndicatorViewColor` / not applicable: Android's ProgressBar has no such style enum; color through `activityIndicatorViewColor` |
| `dateLabel` / `lastUpdatedDate` / `dateFormatter` / `triggerRefresh`（已弃用 / deprecated） | 不移植：原库已弃用，日期用 `setSubtitle` / not ported: deprecated in the source; show a date with `setSubtitle` |
| `UIScrollView (SVInfiniteScrolling)` | `SVPullToRefreshLayout`：`addInfiniteScrolling(direction) { }`、`triggerInfiniteScrolling()`、`infiniteScrollingView`、`showsInfiniteScrolling` |
| `SVInfiniteScrollingView`：`state` / `enabled` / `setCustomView:forState:` / `startAnimating` / `stopAnimating` | `state` / `isInfiniteScrollingEnabled` / `setCustomView` / `startAnimating()` / `stopAnimating()` |
| 来自 PR 的新增 / added from pull requests | `customArrowView`（#107/#190）、`customViewKeepsOwnHeight`（#148）、`infiniteScrollingThreshold`（#154）、`SVPullToRefreshViewListener`（#159/#175/#223）、`contentInsetTop` / `contentInsetBottom`（#173/#177/#297/#300）、`pullThresholdFactor`（#269）、`SVInfiniteScrollingDirection`（#146/#180/#203） |

### SVPullToRefresh open PR（43 个，2026-11-13） / SVPullToRefresh open pull requests (43, 2026-11-13)

| 中文 | English |
| --- | --- |
| SVPullToRefresh 是 iOS 库，转写成 Android Kotlin 时没有可直接合并的源码分支；按规则先逐个审阅：采用的 PR（32 个）在 Kotlin 版中实现（功能）或保留其修复逻辑，其余为 iOS 专属（编译器警告、弃用 API、包管理、视觉风格、示例），记为不适用。翻译完成后在本表补上对应的提交与测试。 | SVPullToRefresh is an iOS library; a Kotlin port for Android has no source branch to merge them into, so each pull request is reviewed first: the 32 taken ones are implemented in the Kotlin version (features) or keep their fix logic; the rest are iOS-only (compiler warnings, deprecated APIs, package managers, look, the demo) and do not apply. After the translation, this table gets the commits and tests. |

| PR | 内容 / Change | 处理 / Decision |
| --- | --- | --- |
| <https://github.com/samvermette/SVPullToRefresh/pull/107> | 自定义箭头视图 / custom arrow view | 采用（功能） / Taken (feature) |
| <https://github.com/samvermette/SVPullToRefresh/pull/126> | 打开 -Warc-repeated-use-of-weak 并修警告 / ARC weak-use warnings | 不适用 / N/A：Objective-C 编译器警告 / an Objective-C compiler warning |
| <https://github.com/samvermette/SVPullToRefresh/pull/140> | 空自定义视图不再用字符串占位 / empty custom views not stored as strings | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/146> | 加载更多可横向（左 / 右）及顶部修复 / horizontal infinite scrolling (left, right) and top fixes | 采用（功能） / Taken (feature) |
| <https://github.com/samvermette/SVPullToRefresh/pull/148> | 固定自定义视图的原点，支持高于 60 的视图 / fixed custom view origin for views taller than 60 | 采用（功能） / Taken (feature) |
| <https://github.com/samvermette/SVPullToRefresh/pull/151> | 下拉时不触发加载更多、停止惯性 / no infinite scrolling while pulling down; stop momentum | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/154> | 加载更多的灵敏度设置 / infinite scrolling sensitivity | 采用（功能） / Taken (feature) |
| <https://github.com/samvermette/SVPullToRefresh/pull/157> | 内容不足一屏时禁用加载更多 / no infinite scrolling when the content is shorter than the frame | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/158> | 顶部与底部的下拉刷新可同时存在 / pull to refresh at the top and the bottom together | 采用（功能） / Taken (feature) |
| <https://github.com/samvermette/SVPullToRefresh/pull/159> | 自定义子视图协议，接收状态变化 / a protocol for custom subviews to receive state changes | 采用（功能） / Taken (feature) |
| <https://github.com/samvermette/SVPullToRefresh/pull/163> | 下拉刷新不触发加载更多 / pull to refresh no longer triggers infinite scrolling | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/165> | 替换自定义视图时移除旧视图 / the old custom view is removed when replaced | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/168> | iOS 7 弃用警告 / iOS 7 deprecation warnings | 不适用 / N/A：iOS API / iOS APIs |
| <https://github.com/samvermette/SVPullToRefresh/pull/173> | 允许修改 contentInset / content inset can change | 采用（功能） / Taken (feature) |
| <https://github.com/samvermette/SVPullToRefresh/pull/175> | 代理方法 / delegate methods | 采用（功能） / Taken (feature) |
| <https://github.com/samvermette/SVPullToRefresh/pull/176> | 用户触发时修正偏移 / offset fix when triggered by the user | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/177> | 设置了 contentInset.top 时刷新视图不可见 / view hidden with contentInset.top set | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/180> | 加载更多支持横向滚动 / horizontal scrolling for infinite scrolling | 采用（功能） / Taken (feature)（与 #146、#203 合并 / merged with #146, #203） |
| <https://github.com/samvermette/SVPullToRefresh/pull/188> | 更细的 iOS 7 风格箭头 / thinner iOS 7 style arrow | 不适用 / N/A：iOS 视觉风格；Android 用 Material 图标 / iOS look; Android uses a Material icon |
| <https://github.com/samvermette/SVPullToRefresh/pull/190> | 自定义箭头视图 / custom arrow view | 采用（功能） / Taken (feature)（同 #107 / same as #107） |
| <https://github.com/samvermette/SVPullToRefresh/pull/193> | sizeWithFont 弃用警告 / sizeWithFont deprecation | 不适用 / N/A：iOS API / iOS API |
| <https://github.com/samvermette/SVPullToRefresh/pull/195> | 刷新视图拆成可继承的子类 / the refresh view as a subclassable class | 采用（功能） / Taken (feature) |
| <https://github.com/samvermette/SVPullToRefresh/pull/200> | triggerPullToRefresh 后状态总是 Loading / state stuck at Loading after triggerPullToRefresh | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/201> | 手动触发的顺序 / manual trigger order | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/203> | 加载更多横向支持 / horizontal infinite scrolling | 采用（功能） / Taken (feature)（与 #146、#180 合并 / merged with #146, #180） |
| <https://github.com/samvermette/SVPullToRefresh/pull/221> | 先设 showsPullToRefresh 再加回调时的观察者泄漏 / observer leak when shown before the handler is set | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/233> | contentSize 小时阈值为负导致误触发 / negative threshold triggers infinite scrolling wrongly | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/237> | 加载完成后未恢复 inset / inset not reset after loading more | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/240> | 修示例 / demo fix | 不适用 / N/A：示例另写 / the demo is rewritten |
| <https://github.com/samvermette/SVPullToRefresh/pull/254> | 下拉会触发加载更多 / pulling to refresh triggers infinite scrolling | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/257> | 状态枚举改为 NS_OPTIONS / state enum as NS_OPTIONS | 不适用 / N/A：Kotlin 用 enum class / Kotlin uses an enum class |
| <https://github.com/samvermette/SVPullToRefresh/pull/259> | UIFont 尺寸弃用 / UIFont size deprecations | 不适用 / N/A：iOS API / iOS API |
| <https://github.com/samvermette/SVPullToRefresh/pull/260> | 只在上拉时触发加载更多、只在下拉时触发刷新 / load more only on pull-up, refresh only on pull-down | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/264> | 内容不足一屏时加载更多误触发下拉刷新 / infinite scrolling triggers pull to refresh on short content | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/269> | pullThresholdFactor 属性 / pullThresholdFactor property | 采用（功能） / Taken (feature) |
| <https://github.com/samvermette/SVPullToRefresh/pull/277> | 内容不足一屏时加载更多视图仍显示 / infinite scrolling view shown on short content | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/283> | 内容未满一屏时下拉触发上推 / pull-down triggers load more on short content | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/286> | 枚举适配 Swift / enums for Swift | 不适用 / N/A：Swift 命名 / Swift naming |
| <https://github.com/samvermette/SVPullToRefresh/pull/292> | Carthage 支持 / Carthage support | 不适用 / N/A：iOS 包管理 / iOS package manager |
| <https://github.com/samvermette/SVPullToRefresh/pull/297> | 允许修改底部 inset / bottom inset can change | 采用（功能） / Taken (feature)（与 #173 合并 / merged with #173） |
| <https://github.com/samvermette/SVPullToRefresh/pull/303> | 删除弃用代码 / removed deprecated code | 不适用 / N/A：iOS API / iOS APIs |
| <https://github.com/samvermette/SVPullToRefresh/pull/306> | hidesWhenStopped 时菊花不显示 / spinner hidden with hidesWhenStopped | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/samvermette/SVPullToRefresh/pull/308> | Swift Package Manager 支持 / Swift Package Manager | 不适用 / N/A：iOS 包管理 / iOS package manager |

### SVPullToRefresh open issue（103 个，2026-11-13） / SVPullToRefresh open issues (103, 2026-11-13)

| 中文 | English |
| --- | --- |
| 评分：**77/100**（79/103 已处理：58 个不适用；21 个的修复在已采用的 PR 里，按用户 2026-11-13 的决定计入开工分数，翻译时实现并测试）。用户选择：“Count PR-covered issues (Recommended)”。规则已写入 `instructions.md`（“Cross-language ports”）。可以开始翻译；剩下 24 个在 Kotlin 版中修复，直到 100。 | Score: **77/100** (79 of 103 handled: 58 do not apply; 21 have their fix in a taken pull request and, by the owner's decision on 2026-11-13, count toward the start; they are implemented and tested in the translation). The owner chose "Count PR-covered issues (Recommended)"; the rule is in `instructions.md` ("Cross-language ports"). Translation can start; the other 24 are fixed in the Kotlin version until 100. |

| issue | 标题 / Title | 状态 / Status |
| --- | --- | --- |
| <https://github.com/samvermette/SVPullToRefresh/issues/70> | Support for prepending items on pull to refresh | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/73> | update example with custom title and subtitle | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/88> | Issues when multiple tables are on screen | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/93> | SVPullToRefreshView is too wide after device orientation changes from landscape to portrait | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/96> | A Big Bug?! | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/101> | Prevent infinite scrolling when the table view is not full of entries | 已处理（计入开工分数）：修复在已采用的 PR #157 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #157, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/103> | pull to refresh not working with custom view that has a height of 200 | 已处理（计入开工分数）：修复在已采用的 PR #148 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #148, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/108> | Pull to refresh header doesn't show up when triggerPullToRefresh is called. | 已处理（计入开工分数）：修复在已采用的 PR #201 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #201, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/117> | hide arrow or set an image instead | 已处理（计入开工分数）：修复在已采用的 PR #107/#190 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #107/#190, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/119> | Pull to Refresh activates Infinite Scrolling | 已处理（计入开工分数）：修复在已采用的 PR #163/#254/#260 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #163/#254/#260, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/120> | Feature Request: infinite scroll up | 已处理（计入开工分数）：修复在已采用的 PR #146/#180/#203 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #146/#180/#203, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/121> | Does not respect contentInset | 已处理（计入开工分数）：修复在已采用的 PR #173/#177 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #173/#177, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/124> | Can I invoke block handler after the PullToRefreshAnimating is done? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/128> | how to show the dateLabel? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/130> | Custom title | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/131> | Pull to refresh view doesn't always hide cleanly | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/138> | How to scroll to top ,when I trigger pulltorefresh programly? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/139> | PullToRefresh on top and bottom simultaneously | 已处理（计入开工分数）：修复在已采用的 PR #158 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #158, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/141> | cannot pull to refresh if contentSize is smaller than frame | 已处理（计入开工分数）：修复在已采用的 PR #157/#264 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #157/#264, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/142> | KVO bug when ScrollView is dealloced | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/147> | contentInset not suitable with iOS7 | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/150> | Ability To Use Built-In Pull To Refresh | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/153> | Sometimes, I get a white background on the refresh view | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/155> | Alignment | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/161> | ios7 sizeWithFont warning | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/162> | Add support for customizing fonts | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/167> | deprecated warnings in IOS7 | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/169> | custom view causes layoutIfNeeded go into infinite loop | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/174> | Resize Arrow | 已处理（计入开工分数）：修复在已采用的 PR #107 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #107, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/179> | Is this library still supported? | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/181> | BUG: TableView section headers hide behind the Navigation bar in iOS 7 | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/184> | In iOS6, pullToRefreshView.activityIndicatorViewColor unavailable | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/185> | BUG: using SVPullToRefresh in UINavigationController | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/186> | When using setCustomView, app freezes | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/187> | SVInfiniteScrolling  bug | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/191> | When contentsize < scrollview size infinite scroll gets triggered when doing pull to refresh | 已处理（计入开工分数）：修复在已采用的 PR #163/#254/#260 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #163/#254/#260, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/192> | [suggestion] declare the "pullToRefreshActionHandler" block property in .h file instead of .m to make it a public property | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/194> | update git tag & podspec | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/196> | Pull to refresh on UICollectionView not working | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/198> | last changes not updated in latest Pod version | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/199> | bug inside navigation view controller | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/205> | InfiniteScrollingView set custom view animation doesn't work. | 已处理（计入开工分数）：修复在已采用的 PR #140/#165 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #140/#165, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/206> | update pod please! | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/208> | Maybe, this is a worth modify code. | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/209> | Adding Horizontal Pull to Refresh | 已处理（计入开工分数）：修复在已采用的 PR #146 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #146, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/210> | I see the arrow when i run code. | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/211> | load more doesn't work good when using auto layout to adjust cell height | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/212> | How to use custom image for SVPullToRefresh library. | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/215> | How to custom subtitle to update dateLabel? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/217> | Configure at which row to initiate infinite scroll handler | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/219> | Pull to Refresh not working on UIScrollView with Auto Layout | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/220> | Stop activity indicator after receiving data from API | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/222> | observer leak | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/223> | Dragging callback for CustomView | 已处理（计入开工分数）：修复在已采用的 PR #159/#175 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #159/#175, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/225> | 当cell只有几条，没有充满一个屏幕的时候，下拉刷新，同时执行了刷新和加载方法 | 已处理（计入开工分数）：修复在已采用的 PR #264/#283 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #264/#283, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/230> | UITableView Top cell cut off my navigation bar | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/231> | How to show "refresh complete" text after refreshing it, and remain for a second, then disappear | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/232> | Disable show pull at first time the view has loaded. | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/234> | issues  when I deleted  the "-ObjC" configuration  in Other Linker Flags | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/235> | Have a navigation bar, refresh will make the first message is hidden under the navigation bar | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/238> | Changing the pullToRefresh action handler? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/243> | addInfiniteScrollingWithActionHandler not getting called | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/246> | In infinite Scrolling, how to add a "Load More" button in the bottom, and "No more data" to disable load again. | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/249> | App crash in KVO observing for frame | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/250> | showsInfiniteScrolling = NO causes jump stutter on UICollectionView | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/251> | Is SVPullToRefresh stopping development? | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/252> | ActivityIndicatorViewColor not available with cocoaPods | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/253> | 发错 | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/255> | Doesn't work well when the "pagingEnabled" attribute of scrollView is set YES | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/256> | fix cash on Observing | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/258> | Doesn't work for second time for Collection view | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/261> | Is there a way to remove infinite scrolling? | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/262> | In iOS7, the contentInsets of UISrollView can't be restored when using SVPullToRefresh in a UIViewController which is embedded in a UINavigationController | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/263> | Is the position method deprecated? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/265> | Loading animation going under NavigationBar | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/266> | Triggered pull to refresh and infinite scroll | 已处理（计入开工分数）：修复在已采用的 PR #260 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #260, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/267> | [Enhancement] Add a minimumHoldTimeBeforeTrigger property | 已处理（计入开工分数）：修复在已采用的 PR #269 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #269, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/268> | I have a question about  willMoveToSuperview | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/270> | how to push to loadmore? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/271> | This repo has been inactive for 2 years. | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/272> | I can't use the " refresh from bottom"  function | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/273> | Please support carthage | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/275> | Cut a new release. | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/276> | should chang "wasTriggeredByUser = YES" when you stop animation. | 已处理（计入开工分数）：修复在已采用的 PR #176 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #176, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/278> | Setting custom view on pull to refresh doesn't work? | 已处理（计入开工分数）：修复在已采用的 PR #165 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #165, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/279> | 能不能更新下呀 | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/280> | 到了一家新公司 他们用这个没人维护的刷新控件真是醉了 有一个kvo的闪退  | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/284> | I think there's a bug need to fix | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/287> | is there alternative for Swift | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/288> | Infinite Scrolling Issue | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/289> | 虽然很无情, 但是还是不要用了 | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/291> | SetTitle not work first pull | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/293> | Infinite Scroll Issue & Table Hide | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/294> | iOS10 - showsInfiniteScrolling = YES - Observers issue | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/295> | 我这里一直有更新，issue可以提到这里  | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/296> | For issues please go to my fork repo | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/298> | Why isn't this library ported to Swift? | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/300> | scrollOffsetThreshold needs consider originalBottomInset? | 已处理（计入开工分数）：修复在已采用的 PR #233/#297 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #233/#297, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/301> | State will be triggered all the time, and not to be loading | 已处理（计入开工分数）：修复在已采用的 PR #200 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #200, implemented and tested in the translation |
| <https://github.com/samvermette/SVPullToRefresh/issues/302> | addPullToRefresh for WKWebView | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/samvermette/SVPullToRefresh/issues/304> | Can I replace the image that is refreshed by the drop-down? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/305> | Mobile Development | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/307> | SFRefresh, written with swift, fixed the KVO crash bug, support Lottie animation. | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |

### TODO: HarmonyOS NEXT support for the Android and cross-platform (Flutter, then React Native) versions

- **Status:** not started (recorded 2026-11-12, while branch `feat/smartrefresh-parity` was in progress). It follows
  the Android task above; when work starts, create a new branch and open its pull request per "A pull request for
  every new branch".
- **The user's original prompt (verbatim):** "找到docs android相关文档写一个英文TODO：android 与跨端平台（REactNative flutter，先flutter，flutter测试通过后再适配 REactNative）支持适配 android 鸿蒙 NEXT系统。"
- **Requirements:**
  1. Make the Android version and the cross-platform versions support HarmonyOS NEXT.
  2. Cross-platform order: Flutter first; adapt React Native only after the Flutter version passes its tests.
  3. Write this entry in English.
- **Context:**
  - HarmonyOS NEXT does not run Android apps: it uses ArkTS/ArkUI and its own app model, so "support" means a native
    HarmonyOS implementation (or the community Flutter and React Native ports for OpenHarmony), not the Android build.
    To confirm when work starts: the SDK and DevEco Studio versions available on this Mac, and whether a HarmonyOS
    NEXT emulator or device is available for tests and screenshots.
  - Depends on the Android task above (`android/merged`, the iOS → Android API table) for the API to match.
  - CYLTabBarController keeps its cross-platform work in `CYLTabBarController/CrossPlatform/` (React Native and
    Flutter; JDK and Flutter paths in the memory "CYLTabBarController cross-platform components"); check there for an
    existing Flutter or React Native tab bar and any HarmonyOS work before starting.
  - Scope boundaries: change no iOS code (as in the Android task); record the API alignment and its score in this
    document.

### DONE: Android placeholder module for CYLSearchViewController's empty search results / 已完成：为 CYLSearchViewController 的搜索空结果提供 Android 占位图模块

- 日期 / Date: 2026-11-13; branch `feat/android-placeholder` (from `feat/smartrefresh-parity` `f38ce49`).
- Context: CYLSearchViewController integrates this project as a sub-repository (its `docs/sub-repositories.md`, rule
  "Sub-repositories" in its AGENTS.md): when a search has no results it shows this project's empty-content
  placeholder, on every platform. iOS is done there (`CYLPlaceholderStackView(scenario:)`,
  `CYLPlaceholderScenarioNoSearchResults`, pinned at `a049422`). This project has no Android code yet, so its
  Android placeholder is added here first, then pinned by CYLSearchViewController's `android/merged`.
- Requirements:
  1. An Android library module (`android/placeholder`, Kotlin, package `com.cyl.placeholder`) with the iOS names:
     `CYLPlaceholderScenario` and `CYLPlaceholderStackView(context, scenario)`.
  2. First increment: the "empty" category of `CYLPlaceholderScenarioCategoryEmpty`, with the iOS components (icon
     size, title, hint or "Go shopping" button) and texts: NoContent, NoSearchResults, EmptyCart, NoOrders,
     NoFavorites, NoMessages, NoNotifications. Images and strings imported from `CYLTableViewPlaceHolder.bundle`
     (all its languages), not retyped.
  3. Static icons (the bundle's PNG fallback styles) in this increment; the Lottie / PAG animations of those scenarios,
     and every other scenario category, stay `TODO` here.
  4. Change no iOS code; a unit test; the module builds standalone (`android/`).
- User prompt (verbatim, in CYLSearchViewController): "在instructions 相关文件，以及skills相关文件中找到 对CollectionViewClassifyMenu 作为子仓库的相关描述，全英文在后面追加以下内容，按照CollectionViewClassifyMenu 作为子仓库 的所有要求，集成CYLTableViewPlaceHolder 作为子仓库。对  CYLTableViewPlaceHolder 的要求是 搜索内容为空时展示 内容为空的 CYLTableViewPlaceHolder  样式。该要求同样适用于 所有平台包括iOS Android react native flutter 鸿蒙 小程序。 标注TODO continue"
- Status: DONE (2026-11-13, `8e23581`).
  - `android/placeholder`: `CYLPlaceholderScenario` (the seven empty scenarios with the iOS icon size, title, hint or
    button), `CYLPlaceholderButtonStyle`, `CYLPlaceholderAction.GoShopping`, `CYLPlaceholderStackView(context,
    scenario, actions)`, `localizedNameForScenario`; images and all strings from the iOS bundle in seven languages
    (`android/scripts/import-ios-resources.py`). 4 Robolectric tests pass. No iOS code changed.
  - Used by CYLSearchViewController (`android/merged`, commit `062a1a3`): a search with no results shows NoSearchResults
    under the search bar. Android 15 emulator (`CYL_API35_arm64`, API 35), macOS 27.3, 2026-11-13 00:4x NZDT:

    ![NoSearchResults in CYLSearchViewController's Android example](assets/android-placeholder-no-search-results.png)

  - Still `TODO`: the scenarios' Lottie / PAG animations on Android, and the other categories (load failed,
    permission, progress, success, HUD).
