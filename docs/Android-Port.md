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
| 已完成（2026-11-13）：模块 `:SVPullToRefresh`（包 `com.cyl.svpulltorefresh`，保留原库类名与 MIT 许可证 `LICENSE.txt`），文案七种语言。iOS 的 UIScrollView 分类在 Android 上没有可扩展的滚动视图，改为包住一个滚动视图的容器；RecyclerView、NestedScrollView 通过嵌套滚动传递拖动，其他视图（ScrollView、WebView）通过触摸拦截。第二步：#195 可继承（`open` 类、`viewFactory`）与 issue 表剩余 24 个全部修复，issue 评分 100/100；Robolectric 测试 29 个全部通过（`SVPullToRefreshLayoutTest` 11 个、`SVPullToRefreshIssuesTest` 18 个，在 `/tmp` 镜像里用 JDK 17 运行，因为 exFAT 卷上的 `._*` 文件会让 Gradle 失败）。剩余：示例与模拟器截图（放到 `android/merged` 的合并示例里）。 | Done (2026-11-13): module `:SVPullToRefresh` (package `com.cyl.svpulltorefresh`, the source's class names and its MIT `LICENSE.txt`), texts in seven languages. Android has no scroll view to extend with a category, so the UIScrollView categories become a container around one scrolling view; RecyclerView and NestedScrollView drag through nested scrolling, other views (ScrollView, WebView) through touch interception. Step two: #195 subclassing (`open` classes, `viewFactory`) and the other 24 issues of the table fixed, issue score 100/100; 29 Robolectric tests pass (`SVPullToRefreshLayoutTest` 11, `SVPullToRefreshIssuesTest` 18, run in a `/tmp` mirror with JDK 17, since `._*` files on the exFAT volume break Gradle). Left: the demo and emulator screenshots (in the merged example of `android/merged`). |

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
| 来自 issue 的新增 / added from issues | `open class SVPullToRefreshView` / `SVInfiniteScrollingView` 与 `addPullToRefresh(viewFactory = …)` / `addInfiniteScrolling(viewFactory = …)`、可覆写 `updateForState()` / `onPull()`（#195）、`contentGravity`（#155）、`completedTitle` / `completedDisplayMillis` / `isShowingCompleted`（#231）、`removePullToRefresh(position)` / `removeInfiniteScrolling()`（#261）、`automaticallyTriggersInfiniteScrolling`（#217/#246）、`SVInfiniteScrollingView.showsNoMoreData` / `titleLabel`（#246）；新文案 `sv_load_more` / `sv_no_more_data` / `sv_refresh_completed` / new strings |

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
| <https://github.com/samvermette/SVPullToRefresh/pull/195> | 刷新视图拆成可继承的子类 / the refresh view as a subclassable class | 采用（功能），已实现：`open` 类与 `viewFactory`；测试 `SVPullToRefreshIssuesTest.subclassedViewsComeFromFactories` / Taken (feature), implemented: `open` classes and `viewFactory`; test `SVPullToRefreshIssuesTest.subclassedViewsComeFromFactories` |
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
| 评分：**100/100**（103/103 已处理：59 个不适用；44 个在 Kotlin 版中修复，每个都有测试，见各行）。2026-11-13 先按用户的决定（“Count PR-covered issues (Recommended)”，规则见 `instructions.md` 的 “Cross-language ports”）以 77/100 开始翻译，之后把 PR 覆盖的 21 个与其余 24 个在 Kotlin 版中实现并测试。 | Score: **100/100** (103 of 103 handled: 59 do not apply; 44 fixed in the Kotlin version, each with a test, see the rows). Translation started at 77/100 on 2026-11-13 by the owner's decision ("Count PR-covered issues (Recommended)", the rule is in `instructions.md`, "Cross-language ports"); the 21 issues covered by pull requests and the other 24 were then implemented and tested in Kotlin. |

| issue | 标题 / Title | 状态 / Status |
| --- | --- | --- |
| <https://github.com/samvermette/SVPullToRefresh/issues/70> | Support for prepending items on pull to refresh | 已修复：stopAnimating 只收起视图，不动内容的滚动位置；测试 `SVPullToRefreshIssuesTest.stoppingKeepsTheContentWhereTheAppPutIt` / Fixed: stopAnimating only hides the view and keeps the content's scroll position; test `SVPullToRefreshIssuesTest.stoppingKeepsTheContentWhereTheAppPutIt` |
| <https://github.com/samvermette/SVPullToRefresh/issues/73> | update example with custom title and subtitle | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/88> | Issues when multiple tables are on screen | 已修复：每个容器只监听自己的目标视图，互不影响；测试 `SVPullToRefreshIssuesTest.severalLayoutsOnScreenAreIndependent` / Fixed: each layout only observes its own target; layouts do not affect each other; test `SVPullToRefreshIssuesTest.severalLayoutsOnScreenAreIndependent` |
| <https://github.com/samvermette/SVPullToRefresh/issues/93> | SVPullToRefreshView is too wide after device orientation changes from landscape to portrait | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/96> | A Big Bug?! | 已修复：短内容上的下拉不会触发加载更多；测试 `SVPullToRefreshIssuesTest.pullingShortContentDoesNotLoadMore` / Fixed: a pull on short content does not load more; test `SVPullToRefreshIssuesTest.pullingShortContentDoesNotLoadMore` |
| <https://github.com/samvermette/SVPullToRefresh/issues/101> | Prevent infinite scrolling when the table view is not full of entries | 已修复：已采用的 PR #157 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.noInfiniteScrollingOnShortContentOrWhileRefreshing` / Fixed: taken PR #157 implemented in Kotlin; test `SVPullToRefreshLayoutTest.noInfiniteScrollingOnShortContentOrWhileRefreshing` |
| <https://github.com/samvermette/SVPullToRefresh/issues/103> | pull to refresh not working with custom view that has a height of 200 | 已修复：已采用的 PR #148 在 Kotlin 版实现；测试 `SVPullToRefreshIssuesTest.customArrowOwnHeightAndInfiniteCustomView` / Fixed: taken PR #148 implemented in Kotlin; test `SVPullToRefreshIssuesTest.customArrowOwnHeightAndInfiniteCustomView` |
| <https://github.com/samvermette/SVPullToRefresh/issues/108> | Pull to refresh header doesn't show up when triggerPullToRefresh is called. | 已修复：已采用的 PR #201 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.triggerPullToRefreshLoadsAndShowsTheView` / Fixed: taken PR #201 implemented in Kotlin; test `SVPullToRefreshLayoutTest.triggerPullToRefreshLoadsAndShowsTheView` |
| <https://github.com/samvermette/SVPullToRefresh/issues/117> | hide arrow or set an image instead | 已修复：已采用的 PR #107/#190 在 Kotlin 版实现；测试 `SVPullToRefreshIssuesTest.customArrowOwnHeightAndInfiniteCustomView` / Fixed: taken PR #107/#190 implemented in Kotlin; test `SVPullToRefreshIssuesTest.customArrowOwnHeightAndInfiniteCustomView` |
| <https://github.com/samvermette/SVPullToRefresh/issues/119> | Pull to Refresh activates Infinite Scrolling | 已修复：已采用的 PR #163/#254/#260 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.noInfiniteScrollingOnShortContentOrWhileRefreshing` / Fixed: taken PR #163/#254/#260 implemented in Kotlin; test `SVPullToRefreshLayoutTest.noInfiniteScrollingOnShortContentOrWhileRefreshing` |
| <https://github.com/samvermette/SVPullToRefresh/issues/120> | Feature Request: infinite scroll up | 已修复：已采用的 PR #146/#180/#203 在 Kotlin 版实现；测试 `SVPullToRefreshIssuesTest.stoppingKeepsTheContentWhereTheAppPutIt, SVPullToRefreshIssuesTest.horizontalInfiniteScrolling` / Fixed: taken PR #146/#180/#203 implemented in Kotlin; test `SVPullToRefreshIssuesTest.stoppingKeepsTheContentWhereTheAppPutIt, SVPullToRefreshIssuesTest.horizontalInfiniteScrolling` |
| <https://github.com/samvermette/SVPullToRefresh/issues/121> | Does not respect contentInset | 已修复：已采用的 PR #173/#177 在 Kotlin 版实现；测试 `SVPullToRefreshIssuesTest.contentInsetsMoveTheTriggers` / Fixed: taken PR #173/#177 implemented in Kotlin; test `SVPullToRefreshIssuesTest.contentInsetsMoveTheTriggers` |
| <https://github.com/samvermette/SVPullToRefresh/issues/124> | Can I invoke block handler after the PullToRefreshAnimating is done? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/128> | how to show the dateLabel? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/130> | Custom title | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/131> | Pull to refresh view doesn't always hide cleanly | 已修复：停止后视图总是完全收起并隐藏，动画中途停止也一样；测试 `SVPullToRefreshIssuesTest.hiddenBeforeTheFirstPullAndAfterHiding` / Fixed: the view always hides fully after stopping, also when stopped mid-animation; test `SVPullToRefreshIssuesTest.hiddenBeforeTheFirstPullAndAfterHiding` |
| <https://github.com/samvermette/SVPullToRefresh/issues/138> | How to scroll to top ,when I trigger pulltorefresh programly? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/139> | PullToRefresh on top and bottom simultaneously | 已修复：已采用的 PR #158 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.topAndBottomTogether` / Fixed: taken PR #158 implemented in Kotlin; test `SVPullToRefreshLayoutTest.topAndBottomTogether` |
| <https://github.com/samvermette/SVPullToRefresh/issues/141> | cannot pull to refresh if contentSize is smaller than frame | 已修复：已采用的 PR #157/#264 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.topAndBottomTogether` / Fixed: taken PR #157/#264 implemented in Kotlin; test `SVPullToRefreshLayoutTest.topAndBottomTogether` |
| <https://github.com/samvermette/SVPullToRefresh/issues/142> | KVO bug when ScrollView is dealloced | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/147> | contentInset not suitable with iOS7 | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/150> | Ability To Use Built-In Pull To Refresh | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/153> | Sometimes, I get a white background on the refresh view | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/155> | Alignment | 已修复：新增 `contentGravity`，箭头与文字可靠左（或其他对齐）；测试 `SVPullToRefreshIssuesTest.contentGravityAndFonts` / Fixed: new `contentGravity` aligns the arrow and texts to the start (or elsewhere); test `SVPullToRefreshIssuesTest.contentGravityAndFonts` |
| <https://github.com/samvermette/SVPullToRefresh/issues/161> | ios7 sizeWithFont warning | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/162> | Add support for customizing fonts | 已修复：`titleLabel` / `subtitleLabel` 公开，字体与字号在标题变化后保留；测试 `SVPullToRefreshIssuesTest.contentGravityAndFonts` / Fixed: `titleLabel` / `subtitleLabel` are public; a font and size survive title changes; test `SVPullToRefreshIssuesTest.contentGravityAndFonts` |
| <https://github.com/samvermette/SVPullToRefresh/issues/167> | deprecated warnings in IOS7 | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/169> | custom view causes layoutIfNeeded go into infinite loop | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/174> | Resize Arrow | 已修复：已采用的 PR #107 在 Kotlin 版实现；测试 `SVPullToRefreshIssuesTest.customArrowOwnHeightAndInfiniteCustomView` / Fixed: taken PR #107 implemented in Kotlin; test `SVPullToRefreshIssuesTest.customArrowOwnHeightAndInfiniteCustomView` |
| <https://github.com/samvermette/SVPullToRefresh/issues/179> | Is this library still supported? | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/181> | BUG: TableView section headers hide behind the Navigation bar in iOS 7 | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/184> | In iOS6, pullToRefreshView.activityIndicatorViewColor unavailable | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/185> | BUG: using SVPullToRefresh in UINavigationController | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/186> | When using setCustomView, app freezes | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/187> | SVInfiniteScrolling  bug | 已修复：未到触发距离就松手时回弹到 0，不留空白；测试 `SVPullToRefreshLayoutTest.shortPullDoesNotLoad` / Fixed: releasing short of the trigger springs back to 0 and leaves no gap; test `SVPullToRefreshLayoutTest.shortPullDoesNotLoad` |
| <https://github.com/samvermette/SVPullToRefresh/issues/191> | When contentsize < scrollview size infinite scroll gets triggered when doing pull to refresh | 已修复：已采用的 PR #163/#254/#260 在 Kotlin 版实现；测试 `SVPullToRefreshIssuesTest.pullingShortContentDoesNotLoadMore` / Fixed: taken PR #163/#254/#260 implemented in Kotlin; test `SVPullToRefreshIssuesTest.pullingShortContentDoesNotLoadMore` |
| <https://github.com/samvermette/SVPullToRefresh/issues/192> | [suggestion] declare the "pullToRefreshActionHandler" block property in .h file instead of .m to make it a public property | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/194> | update git tag & podspec | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/196> | Pull to refresh on UICollectionView not working | 已修复：网格 RecyclerView 通过嵌套滚动下拉刷新；测试 `SVPullToRefreshIssuesTest.gridRecyclerViewRefreshesMoreThanOnce` / Fixed: a grid RecyclerView pulls to refresh through nested scrolling; test `SVPullToRefreshIssuesTest.gridRecyclerViewRefreshesMoreThanOnce` |
| <https://github.com/samvermette/SVPullToRefresh/issues/198> | last changes not updated in latest Pod version | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/199> | bug inside navigation view controller | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/205> | InfiniteScrollingView set custom view animation doesn't work. | 已修复：已采用的 PR #140/#165 在 Kotlin 版实现；测试 `SVPullToRefreshIssuesTest.customArrowOwnHeightAndInfiniteCustomView` / Fixed: taken PR #140/#165 implemented in Kotlin; test `SVPullToRefreshIssuesTest.customArrowOwnHeightAndInfiniteCustomView` |
| <https://github.com/samvermette/SVPullToRefresh/issues/206> | update pod please! | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/208> | Maybe, this is a worth modify code. | 已修复：triggerInfiniteScrolling 不移动内容，停止后恢复原 padding；测试 `SVPullToRefreshIssuesTest.triggerInfiniteScrollingThenStopRestores` / Fixed: triggerInfiniteScrolling does not move the content; stopping restores the padding; test `SVPullToRefreshIssuesTest.triggerInfiniteScrollingThenStopRestores` |
| <https://github.com/samvermette/SVPullToRefresh/issues/209> | Adding Horizontal Pull to Refresh | 已修复：已采用的 PR #146 在 Kotlin 版实现；测试 `SVPullToRefreshIssuesTest.horizontalInfiniteScrolling` / Fixed: taken PR #146 implemented in Kotlin; test `SVPullToRefreshIssuesTest.horizontalInfiniteScrolling` |
| <https://github.com/samvermette/SVPullToRefresh/issues/210> | I see the arrow when i run code. | 已修复：首次下拉前视图不可见（INVISIBLE），无障碍服务也跳过它；测试 `SVPullToRefreshIssuesTest.hiddenBeforeTheFirstPullAndAfterHiding` / Fixed: before the first pull the view is INVISIBLE, and accessibility services skip it; test `SVPullToRefreshIssuesTest.hiddenBeforeTheFirstPullAndAfterHiding` |
| <https://github.com/samvermette/SVPullToRefresh/issues/211> | load more doesn't work good when using auto layout to adjust cell height | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/212> | How to use custom image for SVPullToRefresh library. | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/215> | How to custom subtitle to update dateLabel? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/217> | Configure at which row to initiate infinite scroll handler | 已修复：`infiniteScrollingThreshold` 提前触发；新增 `automaticallyTriggersInfiniteScrolling = false` 只手动触发；测试 `SVPullToRefreshIssuesTest.loadMoreButtonAndNoMoreData` / Fixed: `infiniteScrollingThreshold` triggers earlier; new `automaticallyTriggersInfiniteScrolling = false` triggers manually only; test `SVPullToRefreshIssuesTest.loadMoreButtonAndNoMoreData` |
| <https://github.com/samvermette/SVPullToRefresh/issues/219> | Pull to Refresh not working on UIScrollView with Auto Layout | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/220> | Stop activity indicator after receiving data from API | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/222> | observer leak | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/223> | Dragging callback for CustomView | 已修复：已采用的 PR #159/#175 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.listenerSeesStatesAndProgress` / Fixed: taken PR #159/#175 implemented in Kotlin; test `SVPullToRefreshLayoutTest.listenerSeesStatesAndProgress` |
| <https://github.com/samvermette/SVPullToRefresh/issues/225> | 当cell只有几条，没有充满一个屏幕的时候，下拉刷新，同时执行了刷新和加载方法 | 已修复：已采用的 PR #264/#283 在 Kotlin 版实现；测试 `SVPullToRefreshIssuesTest.pullingShortContentDoesNotLoadMore` / Fixed: taken PR #264/#283 implemented in Kotlin; test `SVPullToRefreshIssuesTest.pullingShortContentDoesNotLoadMore` |
| <https://github.com/samvermette/SVPullToRefresh/issues/230> | UITableView Top cell cut off my navigation bar | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/231> | How to show "refresh complete" text after refreshing it, and remain for a second, then disappear | 已修复：新增 `completedTitle` / `completedDisplayMillis`，刷新完成文字停留后再收起；测试 `SVPullToRefreshIssuesTest.completedTitleStaysThenHides` / Fixed: new `completedTitle` / `completedDisplayMillis` keep a completed text before hiding; test `SVPullToRefreshIssuesTest.completedTitleStaysThenHides` |
| <https://github.com/samvermette/SVPullToRefresh/issues/232> | Disable show pull at first time the view has loaded. | 已修复：同 #210，首次加载前不显示下拉提示；测试 `SVPullToRefreshIssuesTest.hiddenBeforeTheFirstPullAndAfterHiding` / Fixed: as #210, no pull texts show before the first pull; test `SVPullToRefreshIssuesTest.hiddenBeforeTheFirstPullAndAfterHiding` |
| <https://github.com/samvermette/SVPullToRefresh/issues/234> | issues  when I deleted  the "-ObjC" configuration  in Other Linker Flags | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/235> | Have a navigation bar, refresh will make the first message is hidden under the navigation bar | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/238> | Changing the pullToRefresh action handler? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/243> | addInfiniteScrollingWithActionHandler not getting called | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/246> | In infinite Scrolling, how to add a "Load More" button in the bottom, and "No more data" to disable load again. | 已修复：手动模式下显示“加载更多”按钮（无障碍角色为按钮）；新增 `showsNoMoreData` 显示“没有更多数据了”并停止触发；测试 `SVPullToRefreshIssuesTest.loadMoreButtonAndNoMoreData` / Fixed: manual mode shows a "Load more" button (a button for accessibility); new `showsNoMoreData` shows "No more data" and stops triggering; test `SVPullToRefreshIssuesTest.loadMoreButtonAndNoMoreData` |
| <https://github.com/samvermette/SVPullToRefresh/issues/249> | App crash in KVO observing for frame | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/250> | showsInfiniteScrolling = NO causes jump stutter on UICollectionView | 已修复：隐藏加载更多只恢复 padding，不改滚动位置，不跳动；测试 `SVPullToRefreshIssuesTest.hidingInfiniteScrollingDoesNotJump` / Fixed: hiding infinite scrolling only restores the padding, never the scroll position, so it does not jump; test `SVPullToRefreshIssuesTest.hidingInfiniteScrollingDoesNotJump` |
| <https://github.com/samvermette/SVPullToRefresh/issues/251> | Is SVPullToRefresh stopping development? | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/252> | ActivityIndicatorViewColor not available with cocoaPods | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/253> | 发错 | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/255> | Doesn't work well when the "pagingEnabled" attribute of scrollView is set YES | 不适用：Android 的滚动视图没有 pagingEnabled；分页用 ViewPager2（RecyclerView），走嵌套滚动 / N/A: Android scroll views have no pagingEnabled; paging uses ViewPager2 (a RecyclerView), which goes through nested scrolling |
| <https://github.com/samvermette/SVPullToRefresh/issues/256> | fix cash on Observing | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/258> | Doesn't work for second time for Collection view | 已修复：网格 RecyclerView 第二次下拉同样可用；测试 `SVPullToRefreshIssuesTest.gridRecyclerViewRefreshesMoreThanOnce` / Fixed: a grid RecyclerView refreshes the second time too; test `SVPullToRefreshIssuesTest.gridRecyclerViewRefreshesMoreThanOnce` |
| <https://github.com/samvermette/SVPullToRefresh/issues/261> | Is there a way to remove infinite scrolling? | 已修复：新增 `removeInfiniteScrolling()` 与 `removePullToRefresh(position)`，并归还占用的 padding；测试 `SVPullToRefreshIssuesTest.removePullToRefreshAndInfiniteScrolling` / Fixed: new `removeInfiniteScrolling()` and `removePullToRefresh(position)` give the padding back; test `SVPullToRefreshIssuesTest.removePullToRefreshAndInfiniteScrolling` |
| <https://github.com/samvermette/SVPullToRefresh/issues/262> | In iOS7, the contentInsets of UISrollView can't be restored when using SVPullToRefresh in a UIViewController which is embedded in a UINavigationController | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/263> | Is the position method deprecated? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/265> | Loading animation going under NavigationBar | 不适用：iOS 专属（UIKit 布局、导航栏、弃用 API、编译警告） / N/A: iOS-only (UIKit layout, navigation bar, deprecated APIs, compiler warnings) |
| <https://github.com/samvermette/SVPullToRefresh/issues/266> | Triggered pull to refresh and infinite scroll | 已修复：已采用的 PR #260 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.noInfiniteScrollingOnShortContentOrWhileRefreshing` / Fixed: taken PR #260 implemented in Kotlin; test `SVPullToRefreshLayoutTest.noInfiniteScrollingOnShortContentOrWhileRefreshing` |
| <https://github.com/samvermette/SVPullToRefresh/issues/267> | [Enhancement] Add a minimumHoldTimeBeforeTrigger property | 已修复：已采用的 PR #269 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.pullThresholdFactorScalesTheTriggerDistance` / Fixed: taken PR #269 implemented in Kotlin; test `SVPullToRefreshLayoutTest.pullThresholdFactorScalesTheTriggerDistance` |
| <https://github.com/samvermette/SVPullToRefresh/issues/268> | I have a question about  willMoveToSuperview | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/270> | how to push to loadmore? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/271> | This repo has been inactive for 2 years. | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/272> | I can't use the " refresh from bottom"  function | 已修复：`addPullToRefresh(BOTTOM)` 底部上拉刷新；测试 `SVPullToRefreshLayoutTest.topAndBottomTogether` / Fixed: `addPullToRefresh(BOTTOM)` refreshes from the bottom; test `SVPullToRefreshLayoutTest.topAndBottomTogether` |
| <https://github.com/samvermette/SVPullToRefresh/issues/273> | Please support carthage | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/275> | Cut a new release. | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/276> | should chang "wasTriggeredByUser = YES" when you stop animation. | 已修复：已采用的 PR #176 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.triggerPullToRefreshLoadsAndShowsTheView` / Fixed: taken PR #176 implemented in Kotlin; test `SVPullToRefreshLayoutTest.triggerPullToRefreshLoadsAndShowsTheView` |
| <https://github.com/samvermette/SVPullToRefresh/issues/278> | Setting custom view on pull to refresh doesn't work? | 已修复：已采用的 PR #165 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.titlesSubtitlesAndCustomViews` / Fixed: taken PR #165 implemented in Kotlin; test `SVPullToRefreshLayoutTest.titlesSubtitlesAndCustomViews` |
| <https://github.com/samvermette/SVPullToRefresh/issues/279> | 能不能更新下呀 | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/280> | 到了一家新公司 他们用这个没人维护的刷新控件真是醉了 有一个kvo的闪退  | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/284> | I think there's a bug need to fix | 已修复：先加加载更多再加下拉刷新不崩溃，短内容下拉只刷新；测试 `SVPullToRefreshIssuesTest.pullingShortContentDoesNotLoadMore` / Fixed: adding infinite scrolling before pull to refresh does not crash; a pull on short content only refreshes; test `SVPullToRefreshIssuesTest.pullingShortContentDoesNotLoadMore` |
| <https://github.com/samvermette/SVPullToRefresh/issues/287> | is there alternative for Swift | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/288> | Infinite Scrolling Issue | 已修复：只有朝内容末尾滚动才触发加载更多，往回滚不触发；测试 `SVPullToRefreshIssuesTest.scrollingBackDoesNotLoadMore` / Fixed: only scrolling toward the end loads more; scrolling back does not; test `SVPullToRefreshIssuesTest.scrollingBackDoesNotLoadMore` |
| <https://github.com/samvermette/SVPullToRefresh/issues/289> | 虽然很无情, 但是还是不要用了 | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/291> | SetTitle not work first pull | 已修复：首次下拉前设置的标题在第一次下拉就显示；测试 `SVPullToRefreshIssuesTest.titleSetBeforeTheFirstPullShows` / Fixed: titles set before the first pull show on the first pull; test `SVPullToRefreshIssuesTest.titleSetBeforeTheFirstPullShows` |
| <https://github.com/samvermette/SVPullToRefresh/issues/293> | Infinite Scroll Issue & Table Hide | 已修复：加载更多可反复触发；加载视图跟随内容末尾，不盖住内容；测试 `SVPullToRefreshIssuesTest.scrollingBackDoesNotLoadMore` / Fixed: infinite scrolling triggers again and again; its view follows the content's end instead of covering it; test `SVPullToRefreshIssuesTest.scrollingBackDoesNotLoadMore` |
| <https://github.com/samvermette/SVPullToRefresh/issues/294> | iOS10 - showsInfiniteScrolling = YES - Observers issue | 不适用：iOS KVO 观察者崩溃；Kotlin 版用监听器并在移除时注销（翻译时写测试） / N/A: an iOS KVO observer crash; the Kotlin version uses listeners removed on detach (tested in the translation) |
| <https://github.com/samvermette/SVPullToRefresh/issues/295> | 我这里一直有更新，issue可以提到这里  | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/296> | For issues please go to my fork repo | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/298> | Why isn't this library ported to Swift? | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/300> | scrollOffsetThreshold needs consider originalBottomInset? | 已修复：已采用的 PR #233/#297 在 Kotlin 版实现；测试 `SVPullToRefreshIssuesTest.contentInsetsMoveTheTriggers` / Fixed: taken PR #233/#297 implemented in Kotlin; test `SVPullToRefreshIssuesTest.contentInsetsMoveTheTriggers` |
| <https://github.com/samvermette/SVPullToRefresh/issues/301> | State will be triggered all the time, and not to be loading | 已修复：已采用的 PR #200 在 Kotlin 版实现；测试 `SVPullToRefreshLayoutTest.pullDownPastTheTriggerLoadsAndStopAnimatingHides` / Fixed: taken PR #200 implemented in Kotlin; test `SVPullToRefreshLayoutTest.pullDownPastTheTriggerLoadsAndStopAnimatingHides` |
| <https://github.com/samvermette/SVPullToRefresh/issues/302> | addPullToRefresh for WKWebView | 已修复：WebView 等无嵌套滚动的视图也能下拉；忽略其 requestDisallowInterceptTouchEvent（同 SwipeRefreshLayout），没有子视图接收的触摸也能下拉；测试 `SVPullToRefreshIssuesTest.webViewPullsToRefresh` / Fixed: a WebView and other views without nested scrolling pull too: their requestDisallowInterceptTouchEvent is ignored (as SwipeRefreshLayout does), and a touch no child takes still pulls; test `SVPullToRefreshIssuesTest.webViewPullsToRefresh` |
| <https://github.com/samvermette/SVPullToRefresh/issues/304> | Can I replace the image that is refreshed by the drop-down? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/samvermette/SVPullToRefresh/issues/305> | Mobile Development | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |
| <https://github.com/samvermette/SVPullToRefresh/issues/307> | SFRefresh, written with swift, fixed the KVO crash bug, support Lottie animation. | 不适用：维护、发布或包管理请求 / N/A: maintenance, release or package-manager request |

### android-Ultra-Pull-To-Refresh open PR（23 个，2026-11-13） / android-Ultra-Pull-To-Refresh open pull requests (23, 2026-11-13)

| 中文 | English |
| --- | --- |
| 源码 `46fdc86`（Java，MIT）。翻译尚未开始，按规则先处理 open PR：Java 转写为 Kotlin 时逐个审阅，采用的 PR（20 个）在 Kotlin 版中实现，其余记为不适用或不采用并写明原因。翻译完成后在本表补上对应的测试。 | Source `46fdc86` (Java, MIT). Translation has not started, so the open pull requests come first: each is reviewed for the Java → Kotlin translation; the taken ones (20) are implemented in the Kotlin version, the others are marked N/A or not taken with the reason. The tests are added to this table after the translation. |

| PR | 内容 / Change | 处理 / Decision |
| --- | --- | --- |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/114> | RecyclerView 示例 / a RecyclerView demo | 采用（示例）：合并示例里有 RecyclerView 页 / Taken (demo): the merged example has a RecyclerView page |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/124> | 横向滑动交给子视图（ViewPager）/ horizontal moves go to the child (ViewPager) | 采用（修复逻辑） / Taken (fix logic)；由 #209/#270 的横向判断统一实现 / implemented with the horizontal checks of #209/#270 |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/144> | setHeaderView(null) 不再空指针 / setHeaderView(null) no longer crashes | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/157> | 上拉加载更多（PtrHandler2、底部视图）与 ViewPager 冲突 / pull up to load more (PtrHandler2, a footer) and the ViewPager conflict | 采用（功能） / Taken (feature) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/162> | 可覆写 layoutHeader / layoutContent / overridable layoutHeader / layoutContent | 采用（功能） / Taken (feature) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/175> | 核心库注释 / comments in the core library | 采用：Kotlin 版每个公开 API 都有 KDoc / Taken: every public API of the Kotlin version has KDoc |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/176> | 频繁 autoRefresh 时 enabledNextPtrAtOnce 失效 / enabledNextPtrAtOnce fails with frequent autoRefresh | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/177> | StoreHouse 头部重置后重绘 / the StoreHouse header redraws after a reset | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/178> | 嵌套 ViewPager：从按下点算距离、拖动阈值 / nested ViewPager: distances from the press point, a drag slop | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/184> | README 加作者文章链接 / a README link to the author's article | 不适用：原项目 README / N/A: the source's README |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/209> | 更好的横向判断（paging slop）与渐进阻尼 / better horizontal checks (paging slop) and progressive resistance | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/212> | 变量 offsetX 改名 offsetY / rename offsetX to offsetY | 采用（命名） / Taken (naming) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/236> | 固定头部 setPinHeader / setPinHeader keeps the header in place | 采用（功能） / Taken (feature) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/238> | 去掉横向判断的 slop / drop the slop from the horizontal check | 不采用：没有 slop 时轻微斜划也会挡住下拉；改用 #209/#270 / Not taken: without a slop a slightly diagonal move blocks the pull; #209/#270 instead |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/240> | 回弹结束时补到目标位置（#239）/ finish at the target position after the bounce (#239) | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/268> | onDetachedFromWindow 时头部收回 / the header retracts on onDetachedFromWindow | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/270> | 横向移动以按下点判断（#261）/ horizontal moves judged from the press point (#261) | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/273> | MaterialHeader 背景色 / the MaterialHeader background color | 采用（功能） / Taken (feature) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/280> | 升级 Gradle、打开调试日志、去掉多余计算 / Gradle upgrade, debug log, a redundant calculation | 部分：去掉多余计算；构建配置不适用 / Partly: the redundant calculation; the build changes do not apply |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/288> | 下拉死区 deadZone；叠放视图闪烁 / a pull dead zone; flicker of stacked views | 部分：采用 deadZone；不采用闪烁处理（快速拖动会被丢弃）/ Partly: deadZone taken; the flicker workaround not taken (it drops fast drags) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/319> | refreshComplete 的 long 转 int 溢出 / long-to-int overflow in refreshComplete | 采用（修复逻辑） / Taken (fix logic) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/336> | README 的 compile 改 implementation / README compile → implementation | 不适用：原项目 README / N/A: the source's README |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/pull/351> | 整理代码；onDetachedFromWindow 移除延迟任务 / cleanup; remove delayed tasks on onDetachedFromWindow | 采用（修复逻辑） / Taken (fix logic) |

### android-Ultra-Pull-To-Refresh open issue（151 个，2026-11-13） / android-Ultra-Pull-To-Refresh open issues (151, 2026-11-13)

| 中文 | English |
| --- | --- |
| 评分：**67/100**（101/151 已处理：56 个不适用（用法提问 26、维护构建 15、应用或系统问题 10、超出范围 5）；45 个的修复在已采用的 PR 里，按 `instructions.md` 的 “Cross-language ports” 计入开工分数，翻译时实现并测试）。已过 60，可以开始翻译；剩下 50 个在 Kotlin 版中修复，直到 100。 | Score: **67/100** (101 of 151 handled: 56 do not apply (26 usage questions, 15 maintenance or build, 10 app or system bugs, 5 out of scope); 45 have their fix in a taken pull request and count toward the start by `instructions.md`, "Cross-language ports", implemented and tested in the translation). Past 60, so translation can start; the other 50 are fixed in the Kotlin version until 100. |

| issue | 标题 / Title | 状态 / Status |
| --- | --- | --- |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/27> | it can't be compatible with RecyclerView | 已处理（计入开工分数）：修复在已采用的 PR #114 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #114, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/29> | 希望增加固定头部的配置 | 已处理（计入开工分数）：修复在已采用的 PR #236 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #236, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/41> | Multiple touch | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/42> | PtrDefaultHandler issue | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/48> | ScrollChecker.finish will be triggered twice. | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/77> | drop-down refresh bug | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/83> | onInterceptTouchEvent() not work when I pull down | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/91> | RentalsSunHeaderView与disableWhenHorizontalMove有冲突 | 已处理（计入开工分数）：修复在已采用的 PR #209/#270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #209/#270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/105> | RecyclerView demo | 已处理（计入开工分数）：修复在已采用的 PR #114 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #114, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/106> | ViewPager有触摸事件冲突 | 已处理（计入开工分数）：修复在已采用的 PR #178/#209/#270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #178/#209/#270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/108> | Drag or fling horizontally inside one item will trigger the item's click event | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/112> | java.lang.NullPointerException | 已处理（计入开工分数）：修复在已采用的 PR #144 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #144, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/115> | Use the Google Support Design 22.2.0 CoordinatorLayout and TabLayout event conflict. | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/118> | 能否把底部加载更多整合进来？ | 已处理（计入开工分数）：修复在已采用的 PR #157 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #157, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/119> | disable pull to refresh when item clicking or touching? | 已处理（计入开工分数）：修复在已采用的 PR #178 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #178, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/122> | 使用 autoRefresh方法头部没效果 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/123> | autoRefresh can not work with setEnabledNextPtrAtOnce(true) | 已处理（计入开工分数）：修复在已采用的 PR #176 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #176, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/125> | Give time strings an argument so that it can work with french translation | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/126> | we intensity want a load more and it must be fit all view,thanks very much | 已处理（计入开工分数）：修复在已采用的 PR #157 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #157, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/128> | Soft keyboard adjust issue | 不适用：用法提问（windowSoftInputMode 与应用布局） / N/A: a usage question (windowSoftInputMode and the app's layout) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/129> | 在Material Style 的下拉刷新里面加上频繁的下拉刷新，连续下拉会出现头部空白情况 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/132> | 在ViewPager中嵌套Ptr，水平滑动的时候很容易触发下拉 | 已处理（计入开工分数）：修复在已采用的 PR #209/#270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #209/#270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/133> | 解决android-Ultra-Pull-To-Refresh下拉刷新组件中嵌套ViewPager的一个bug | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/135> | 不知道有类似SwipeRefreshLayout setProgressViewOffset 这个接口吗 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/136> | Pull to refresh still activated when scrolling horizontally and disableWhenHorizontalMove is true | 已处理（计入开工分数）：修复在已采用的 PR #270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/137> | Allow "last updated" to accept a customized date instead of using duration period | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/139> | 下拉刷新完成后，可否让刷新完成的状态停留一段时间. | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/141> | PtrFramLayout配合StoreHouseHeader的时候调用autorefresh字符串显示异常 | 已处理（计入开工分数）：修复在已采用的 PR #176/#177 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #176/#177, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/150> | StoreHouseHeader doesn't work. | 不适用：用法提问（StoreHouseHeader 需先 initWithString） / N/A: a usage question (StoreHouseHeader needs initWithString first) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/151> | dispatchTouchEvent()函数内部操作困惑 | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/154> | setPinHeader to make header stick to the top | 已处理（计入开工分数）：修复在已采用的 PR #236 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #236, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/156> | Disable ptrClassicFrameLayout after first refresh complete | 不适用：用法提问（checkCanDoRefresh 返回 false 或 isEnabled = false） / N/A: a usage question (return false from checkCanDoRefresh or set isEnabled = false) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/164> | 支持嵌套ViewPager+RecyclerView吗? | 已处理（计入开工分数）：修复在已采用的 PR #114/#209/#270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #114/#209/#270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/165> | Header start poin | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/167> | 点击listview里面的item经常会出现下拉拖动整个view从而和item的点击事件冲突，有什么好的解决方法吗 | 已处理（计入开工分数）：修复在已采用的 PR #178 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #178, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/171> | 把上拉加载更多也加上吧 | 已处理（计入开工分数）：修复在已采用的 PR #157 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #157, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/183> | 对demo的一些看法 | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/186> | when PtrFrameLayout with MaterialHeader, method setEnabledNextPtrAtOnce(true) cannot work | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/189> | 很抱歉直接写中文。。。关于autoRefresh的 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/190> | 无法找到 "in.srain.cube:cube-sdk:1.0.44.39-SNAPSHOT@aar" | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/191> | 看到一个比较下拉刷新的开源项目，对作者项目默认下拉head有一个地方的性能进行测试，提出了意见，感觉蛮对的 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/192> | 【BUG】在material refresh中，下拉刷新状态，第一个圈转完后会有一个相对快速的圈，然后才会继续转 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/195> | QQ群已满，加不进去，另提点个人建议 | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/196> | Where I can find a documentation and more examples? | 不适用：用法提问（loadingMinTime 可配置） / N/A: a usage question (loadingMinTime is configurable) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/197> | 使用此控件，做出回弹效果 | 不适用：用法提问（keepHeaderWhenRefresh 与上拉） / N/A: a usage question (keepHeaderWhenRefresh and pulling up) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/199> | 刷新，头在顶部不动 | 已处理（计入开工分数）：修复在已采用的 PR #236 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #236, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/200> | 切换Fragment，Header不回弹的问题 | 已处理（计入开工分数）：修复在已采用的 PR #268 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #268, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/201> | cube-sdk-master 中的LoadMoreContainerBase 中setLoadMoreView(View view) 方法有问题 | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/202> | import in.srain.cube.mints.base.TitleBaseFragment; | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/204> | How I can user this with a CoordinatorLayout ? | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/205> | Error inflating class in.srain.cube.image.CubeImageView | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/206> | 下拉刷新时当遇到listview的第一个item高度特别高时bug | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/215> | ListView.addHeaderView(),滑动后header不见了 | 不适用：ListView 的 header 由应用管理 / N/A: the ListView header is the app's |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/216> | 关于adapter ViewType的处理 | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/217> | （系统问题，请忽略。）列表快速上滑后会自动滑到最下面 | 不适用：Android 系统问题，原作者已注明忽略 / N/A: an Android system bug the reporter asked to ignore |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/220> | viewpager 时候有滑动事件感觉不好 | 已处理（计入开工分数）：修复在已采用的 PR #209 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #209, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/223> | The onUIRefreshPrepare will called twice when I use setEnabledNextPtrAtOnce | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/224> | RecyclerView外面嵌套一层Framelayout，然后在给PtrFrameLayout包住，就不行了 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/227> | 请教一个问题 | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/228> | Array data for specific word? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/229> | Content为LinearLayout，而LinearLayout包裹着ViewPager和ListView时遇到了问题 | 不适用：用法提问（自定义 checkCanDoRefresh） / N/A: a usage question (a custom checkCanDoRefresh) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/230> | No recycle TypedArray in PtrClassicDefaultHeader after initview | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/231> | 没有适配recyclerview么? | 已处理（计入开工分数）：修复在已采用的 PR #114 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #114, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/232> | listview自动刷新，用viewpager加3个fragment 作为容器，但是在刷新事切换头部，永远有一个fragment没有停止刷新 | 不适用：应用的 Fragment 生命周期 / N/A: the app's fragment lifecycle |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/233> | contentview 中有其他拖动控件求解决 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/234> | 直接new对象没有作用，只能通过xml的方式添加 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/235> | 编译出错 | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/239> | 下拉松手后回弹有时无法回到初始位置，导致下拉动作没有完整完成，影响下一次下拉 | 已处理（计入开工分数）：修复在已采用的 PR #240 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #240, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/242> | 关闭头部回弹时间，不会立即回弹 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/245> | 把mDurationToClose和mDurationToCloseHeader设为0，为什么不能立即回弹？设为10也不行！！！ | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/246> | 内存泄漏 | 已处理（计入开工分数）：修复在已采用的 PR #319 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #319, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/247> | autoRefresh有时不会触发自动刷新，header显示一半又收回去了 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/248> | ViewPager嵌套在Fragment中TabPageIndicator不显示 | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/249> | ListView 不会回到顶部 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/250> | RentalsStyle下拉跳动问题 | 不适用：Rentals 头部只在原示例里，不移植 / N/A: the Rentals header is only in the source demo and is not ported |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/251> | 如何改变下拉刷新时的背景色？ | 不适用：用法提问（给 PtrFrameLayout 设背景色） / N/A: a usage question (set the PtrFrameLayout's background) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/252> | 对PtrFrameLayout为了解决与可横向滑动组件冲突的判断有些不明白 | 已处理（计入开工分数）：修复在已采用的 PR #270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/254> | PtrClassicDefaultHeader | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/255> | How can i cancel refreshing event? | 不适用：用法提问（refreshComplete() 收起头部） / N/A: a usage question (refreshComplete() hides the header) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/256> | Horizontal swipe in tablets? | 不适用：横向刷新不在本库范围 / N/A: horizontal refresh is outside this library |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/257> | 当列表第一条在屏幕顶部时，条目点击事件可能会触发下拉刷新，怎么解决呢？ | 已处理（计入开工分数）：修复在已采用的 PR #178 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #178, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/258> | How do i want only the animation? | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/260> | 头部动画会一直闪 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/261> | 和ViewPager一起使用，ViewPager还是不能很好的滑动 | 已处理（计入开工分数）：修复在已采用的 PR #270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/262> | 没有上拉加载吗? | 已处理（计入开工分数）：修复在已采用的 PR #157 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #157, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/264> | 在刷新过程中，禁止内容点击，如何做合理 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/265> | 上滑加载更多有这个功能吗 | 已处理（计入开工分数）：修复在已采用的 PR #157 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #157, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/266> | recyclerview item点击手势稍微偏移一点就触发了刷新 | 已处理（计入开工分数）：修复在已采用的 PR #178 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #178, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/267> | 这么多pr为什么都合并失败了？ | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/269> | 你好  目前只有下拉刷新，没有上拉加载吗？ | 已处理（计入开工分数）：修复在已采用的 PR #157 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #157, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/272> | 在onCreate中动态addView失败 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/274> | 上拉加载更多时快速下滑下拉刷新会出现list越界异常 | 不适用：应用适配器的越界 / N/A: an index error in the app's adapter |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/275> | 如何让下拉的距离固定？ | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/276> | Content为ScrollView下拉时有时不立即回弹 | 已处理（计入开工分数）：修复在已采用的 PR #240 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #240, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/278> | have any body meet this?? Error: more than one library with package name 'in.srain.cube.views.ptr' | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/279> | viewpager 广告图不好滑,想重写dispatchTouchEvent ,结果触摸事件被拦截了,disableWhenHorizontalMove()这个方法没用 | 已处理（计入开工分数）：修复在已采用的 PR #270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/282> | 需要支持右滑的同志，请看这里，有解决方案 | 已处理（计入开工分数）：修复在已采用的 PR #209/#270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #209/#270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/283> | CoordinatorLayout+AppBarLayout+CollapsingToolbarLayout+ViewPager问题 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/284> | 当在horizontalscrollview中包括ptrframelayout的时候基本无法滑动 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/285> | Error inflating #51 | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/286> | 谁知道有没支持垂直方向ViewPager的刷新控件啊 | 不适用：竖向 ViewPager 不在本库范围 / N/A: a vertical ViewPager is outside this library |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/287> | 套在 WebView外面，WebView  顶部有个 轮播控件， 会导致轮播控件左右滑动很不流畅 | 已处理（计入开工分数）：修复在已采用的 PR #270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/289> | how to get scrollY(content is recyclerView) | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/290> | 崩溃信息，全都跑到PtrFrameLayout里了，看不到原因啊 | 不适用：RecyclerView 数据不一致是应用的问题 / N/A: the RecyclerView inconsistency is the app's |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/291> | hi 刷新时间是默认显示的吗 为啥我的没显示 哪个方法控制的呢 | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/292> | addview 不显示。 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/294> | 为什么不提供加载更多了 | 已处理（计入开工分数）：修复在已采用的 PR #157 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #157, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/295> | 向下滑的事件处理不是很好，太敏感 | 已处理（计入开工分数）：修复在已采用的 PR #178/#209 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #178/#209, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/296> | 关于recyclerview。 | 已处理（计入开工分数）：修复在已采用的 PR #114 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #114, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/297> | 廖老师，什么时候能支持recycleView呀！！！期待 | 已处理（计入开工分数）：修复在已采用的 PR #114 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #114, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/299> | 解决（图片轮播和下拉刷新）出现的事件冲突问题 | 已处理（计入开工分数）：修复在已采用的 PR #270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/300> | 设置autoRefresh后出现两个还不正确的header | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/301> | 上拉加载更多完成之后，导致recyclerview最后的一项会被切掉 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/302> | 请问，我想在刷新完成后，下拉状态保持1-2s再回弹上去该怎么处理，谢谢 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/303> | 为什么吧不增加一个RecyclerView刷新呢 | 已处理（计入开工分数）：修复在已采用的 PR #114 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #114, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/304> | 期待考虑封装一个RN的版本？ | 不适用：React Native 版本不在本任务范围 / N/A: a React Native version is outside this task |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/305> | Error: app:transformClassesWithJarMergingForDebug | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/306> | 大神你好 请问StoreHouse风格的文字可以改变颜色吗？ | 不适用：用法提问（StoreHouseHeader.setTextColor） / N/A: a usage question (StoreHouseHeader.setTextColor) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/307> | 下拉与横向的RecycleView冲突 | 已处理（计入开工分数）：修复在已采用的 PR #270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/308> | 请教如何指定下拉距离啊？ | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/309> | IndexOutOfBoundsException Inconsistency detected | 不适用：RecyclerView 数据不一致是应用的问题 / N/A: the RecyclerView inconsistency is the app's |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/310> | PtrClassicDefaultHeader memory leak | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/311> | 添加了srcollView为其子组件，为什么上拉srcollview之后，srcollview被遮住不见了，求解 | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/312> | 跟viewpager的轮播图使用，手势冲突太严重了，无法解决。 | 已处理（计入开工分数）：修复在已采用的 PR #270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/313> | How to change the loading spinner image? | 不适用：用法提问（自定义 PtrUIHandler 头部） / N/A: a usage question (a custom PtrUIHandler header) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/314> | java.lang.IllegalStateException: FragmentManager is already executing transactions | 不适用：应用的 FragmentManager 用法 / N/A: the app's FragmentManager use |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/315> | 在里面嵌套CoordinatorLayout+AppBarLayout+TabLayout+ViewPager的问题 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/317> | 嵌套WebView的问题，WebView网页中使用了滑动控件 | 不适用：用法提问（网页内的滑动控件无法通知原生，需自定义 checkCanDoRefresh） / N/A: a usage question (a slider inside a web page cannot tell native code; use a custom checkCanDoRefresh) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/318> | 上拉加载更多之后怎么滑倒底部啊，一直不行啊，用recyclerview的smothto | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/320> | 刷新content是listview时，怎么监听listview滚动Y坐标呢 | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/321> | 请问这个库不再维护了嘛 | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/322> | Pull to left or right and show icon from left or right | 不适用：横向刷新不在本库范围 / N/A: horizontal refresh is outside this library |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/323> | 手指拖动刷新的bug | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/324> | PrtFrameLayout没有自带Scrollview的功能吗 | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/325> | 解决框架和横向滑动控件的滑动冲突的办法 | 已处理（计入开工分数）：修复在已采用的 PR #270 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #270, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/326> | 能不能实现模仿朋友圈下拉刷新 | 不适用：用法提问（自定义头部） / N/A: a usage question (a custom header) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/327> | coordinatorlayout 嵌套 android-Ultra-Pull-To-Refresh 下拉刷新不灵敏 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/328> | Minimum drag pixels | 已处理（计入开工分数）：修复在已采用的 PR #288 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #288, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/331> | ViewHolder中无法跳转界面 | 不适用：用法提问 / N/A: a usage question |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/332> | 运行您的代码，去掉一个参数报错.IllegalArgumentException: ViewHolderClass can not be initiated | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/333> | viewpager + fragment 的 自动刷新 各种问题  ，这个库没人维护了吗 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/334> | viewpager+fragment ，只用下拉刷新功能没问题，把上拉加载功能加上 就不能展示全部数据了 | 不适用：另一个库的加载更多 / N/A: another library's load more |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/335> | 能不能设置禁止下拉刷新 | 不适用：用法提问（isEnabled = false） / N/A: a usage question (isEnabled = false) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/337> | 上拉加载完成列表位置回退如何禁止 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/338> | Not working with recyclerview | 已处理（计入开工分数）：修复在已采用的 PR #114 中，翻译时实现并测试 / Handled (counted for the start): the fix is in taken PR #114, implemented and tested in the translation |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/339> | 类型转换异常，存在内存泄漏问题 | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/340> | NestedScrollingChild ,NestedScrollingParent | TODO：在 Kotlin 版中处理并写测试 / TODO: handled and tested in the Kotlin version |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/342> | 嵌套WebView的问题，WebView网页中使用了滑动控件,滑动webView 然后下拉webView 不能滑动到顶部，直接下拉刷新了，请问怎么解决？ | 不适用：用法提问（同 #317） / N/A: a usage question (as #317) |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/344> | PtrClassicFrameLayout 嵌套RelativeLayout头部被裁减了 | 不适用：应用布局裁剪 / N/A: the app's layout clipping |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/345> | 闪退啊 | 不适用：系统字体日志，非本库 / N/A: a system font log, not this library |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh/issues/352> | You're on the SigRank board — claim your profile or remove it | 不适用：维护、构建、示例依赖或包管理 / N/A: maintenance, build, demo dependency or packaging |

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
