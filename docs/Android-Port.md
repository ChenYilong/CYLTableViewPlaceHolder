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

| 来源项目 / Source | 许可证 / License | 提交 / Commit | 规模 / Size | open PR | open issue |
| --- | --- | --- | --- | --- | --- |
| <https://github.com/samvermette/SVPullToRefresh>（iOS，Objective-C） | MIT | `a5f9dfe`（2013-09-26） | 库约 44 KB、10 个源文件 / library about 44 KB, 10 source files | 43 | 103 |
| <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh>（Java） | MIT | `46fdc86`（2016-05-04） | 库约 128 KB、示例约 109 KB / library about 128 KB, demo about 109 KB | 23 | 151 |
| <https://github.com/scwang90/SmartRefreshLayout>（Java） | Apache-2.0 | `224db48`（2024-11-26） | 库约 720 KB（kernel 276 KB、header 256 KB 等）、示例约 329 KB / library about 720 KB (kernel 276 KB, headers 256 KB, …), demo about 329 KB | 5 | 337 |
| 用户原始提示词：“将下面的任务，找一个合适的文档，标注关键词TODO：注意本任务仅仅修改android代码，不要改iOS代码。在本项目中新建文件夹命名为 android ，下面的代码 每一个仓库 创建一个文件夹，并创建第四个文件夹命名为merged     <https://github.com/scwang90/SmartRefreshLayout>    <https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh>   同样要求处理 <https://github.com/samvermette/SVPullToRefresh> 第二步骤：分别将这三个项目在各自文件夹中做代码转录，全部翻译为kotlin语言。第三步骤：将以上几个文件夹里的kotlin代码合并为一个项目，保留所有api接口，并将example合并为一个。使用CYLTabBarController 的android端tabbar 作为展示的功能划分，采用gradle或者maven指向CYLTabBarController 最新提交，找到gradle或者maven使用commit引用的方式集成，如果不行就采用本地路径引用。一个example一个tabbaritem区分。第四步骤：在docs在合适的文档或创建文档，列出iOS端所有的公开api，第二列 ，列出找到的在该merged文件夹下所有的公开api的对应项。第五步，将缺失merged文件夹缺失的API对齐。在该表格未对齐的地方标注TODO如果iOS端和android能完全对齐所有api就是满分，merged文件夹每次新增一个api就在该文档中打分，一直达到满分。第六步骤：将iOS端的example全部移植到merged文件夹，注意是翻译，不要改iOS代码。使用上面提到的表格中android的api实现。并截图更新文档，readme 在android章节。” | The user's original prompt (Chinese, verbatim on the left), summarized: record this task as a TODO in a fitting document. Change only Android code, never iOS code. Create an `android` folder in this project with one folder per repository below plus a fourth folder named `merged`: SmartRefreshLayout, android-Ultra-Pull-To-Refresh and SVPullToRefresh. Step 2: transcribe each project in its own folder, all translated to Kotlin. Step 3: merge the Kotlin code of those folders into one project, keeping every API, and merge the examples into one; use CYLTabBarController's Android tab bar to divide the demos, depend on CYLTabBarController's latest commit through Gradle or Maven by commit reference, or by local path if that fails; one example per tab item. Step 4: in docs, list every public iOS API, and in a second column the matching public API found in `merged`. Step 5: add the API `merged` lacks; mark unaligned rows TODO; full alignment is full marks; score in that document after every API added to `merged`, until full marks. Step 6: port every iOS example to `merged` by translation (without changing iOS code), using the Android API from the table; take screenshots and update the docs and the README's Android section. |
| 要求：①只改 Android 代码，不改 iOS 代码；②新建 `android/`，下分 `SmartRefreshLayout/`、`android-Ultra-Pull-To-Refresh/`、`SVPullToRefresh/` 与 `merged/` 四个文件夹；③三个项目分别转写为 Kotlin（SVPullToRefresh 原为 iOS Objective-C，同样转写为 Kotlin）；④合并为一个 Kotlin 项目，保留全部 API，示例合并为一个，用 CYLTabBarController 的 Android 端 tab bar 分区，每个示例一个 tab；⑤依赖 CYLTabBarController 最新提交：优先 Gradle/Maven 的 commit 引用（如 JitPack），不行就用本地路径；⑥docs 中列出 iOS 全部公开 API 与 `merged` 中的对应项，未对齐处标 TODO，每新增一个 API 更新评分，直到满分；⑦把 iOS 端全部示例翻译移植到 `merged`，使用表中的 Android API；⑧截图，更新文档与 README 的 Android 章节。 | Requirements: (1) change only Android code, never iOS code; (2) create `android/` with four folders: `SmartRefreshLayout/`, `android-Ultra-Pull-To-Refresh/`, `SVPullToRefresh/` and `merged/`; (3) transcribe each project to Kotlin (SVPullToRefresh is iOS Objective-C and is transcribed to Kotlin too); (4) merge into one Kotlin project keeping every API, with one merged example divided by CYLTabBarController's Android tab bar, one tab per example; (5) depend on CYLTabBarController's latest commit: a Gradle/Maven commit reference first (JitPack, for example), else a local path; (6) in docs, list every public iOS API with its `merged` counterpart, mark unaligned rows TODO, and update the score after every added API until full marks; (7) port every iOS example to `merged` by translation, using the Android API from the table; (8) take screenshots and update the docs and the README's Android section. |
| 上下文：本仓库目前只有 iOS（Objective-C 核心、Swift 示例）。CYLTabBarController 仓库在本机 vault 的 `CYLTabBarController/`，其 `CrossPlatform/` 中有 Android 相关内容（JDK/Flutter 路径见 memory “CYLTabBarController cross-platform components”），Android 端 tab bar 的具体模块名与 commit 引用方式待开工时核实。三个上游项目的许可证、提交号与规模待开工时记录。iOS 公开 API 的来源是 `CYLTableViewPlaceHolder/` 下的公开头文件（含 CYLRefresh）；同时进行的 `docs/Refresh-Library-Parity.md` 任务会继续增加 iOS API，表格需以开工时的头文件为准。 | Context: this repository is iOS only today (Objective-C core, Swift examples). The CYLTabBarController repository is in this vault at `CYLTabBarController/`; its `CrossPlatform/` holds Android-related work (JDK and Flutter paths in the memory "CYLTabBarController cross-platform components"); the Android tab bar's module name and how to reference a commit are to be checked when work starts. The three upstream projects' licenses, commits and sizes are to be recorded then. The iOS public API comes from the public headers under `CYLTableViewPlaceHolder/` (CYLRefresh included); the parallel task in `docs/Refresh-Library-Parity.md` keeps adding iOS API, so the table follows the headers as they are when work starts. |

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
