# CYLAnimatedItem 接入进度 / CYLAnimatedItem migration status

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [用途](#用途--purpose) | [Purpose](#用途--purpose) |
| [总评分](#总评分--overall-score) | [Overall score](#总评分--overall-score) |
| [接入文档要求逐项对照](#接入文档要求逐项对照--the-guides-requirements-item-by-item) | [The guide's requirements, item by item](#接入文档要求逐项对照--the-guides-requirements-item-by-item) |
| [TODO](#todo) | [TODO](#todo) |
| [按 commit 引入](#按-commit-引入--taken-by-commit) | [Taken by commit](#按-commit-引入--taken-by-commit) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

## 用途 / Purpose

| 中文 | English |
| --- | --- |
| 本文档逐项记录本仓库按 CYLTabBarController 的动效组件接入文档（[docs/Animated-Item.md，分支 `feat/cross-platform-components`](https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md)）改造的进度：每个平台的完成情况、验证证据、评分与 TODO。图标 + 标题 + 动效的核心组件是 `CYLPlaceholderView`；改造后它基于上游的 `CYLAnimatedItemView`，核心不依赖任何动效引擎，只有应用（示例层）引入引擎时才播放动效。任务记录见 [Task-Log.md](Task-Log.md)。 | This document tracks, item by item, how this repository follows CYLTabBarController's integration guide for the animation component ([docs/Animated-Item.md, branch `feat/cross-platform-components`](https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md)): each platform's status, the verification evidence, a score and the TODOs. The icon + title + animation component of the core is `CYLPlaceholderView`; after the migration it builds on upstream's `CYLAnimatedItemView`, the core depends on no animation engine, and animations play only when the app (the example layer) adds an engine. Task records: [Task-Log.md](Task-Log.md). |
| 更新于 2026-11-17，分支 `feat/android-refresh-port-followup`（PR #31），上游固定在 `57a527ef`（`Cartfile`，按 commit 引入，组件尚未发布）。 | Updated 2026-11-17, branch `feat/android-refresh-port-followup` (pull request #31), upstream pinned at `57a527ef` (`Cartfile`, taken by commit since the component is not published yet). |

## 总评分 / Overall score

| 中文 | English |
| --- | --- |
| **总评分：85 / 100**（四个平台的平均分，按下表；评分只计入有实现与测试证据的部分，编译通过但未在设备上查看的视觉效果不算完成）。 | **Overall score: 85 / 100** (the average of the four platforms below; a score counts only what implementation and test evidence support; visual results that compiled but were not seen on a device are not counted as done). |

| 平台 / Platform | 评分 / Score | 中文 | English |
| --- | --- | --- | --- |
| iOS | 90 | 代码完成；CI：单元测试、iOS 12.0 部署构建、动画测试 11/12（剩余 1 个已修复）、无障碍 3/4（剩余 1 个已修复）通过；尚无一次完整的绿色运行（每次推送都取消了上一次运行） | Code done; CI: unit tests, the iOS 12.0 deployment build, animation tests 11 of 12 (the last one fixed since) and accessibility 3 of 4 (the last one fixed since) passed; no complete green run yet (each push cancelled the run before it) |
| Android | 95 | 代码完成；Android CI（单元测试 + 示例构建）通过（run #75，`0a32b21`）；视觉未在设备上查看 | Code done; Android CI (unit tests + the example build) green (run #75, `0a32b21`); visuals not seen on a device |
| 微信小程序 / WeChat Mini Program | 80 | 代码完成（`bfeb678`）；`npm test` 53/53；未在微信开发者工具中渲染 | Code done (`bfeb678`); `npm test` 53 of 53; not rendered in the WeChat DevTools |
| 鸿蒙 / HarmonyOS | 75 | 代码完成（`0847ffe`、`d54eef1`）；同步脚本 `--check` 与鸿蒙文档检查通过；未编译（容器中没有 DevEco Studio） | Code done (`0847ffe`, `d54eef1`); the sync script's `--check` and the HarmonyOS doc checks pass; not compiled (no DevEco Studio in the container) |

## 接入文档要求逐项对照 / The guide's requirements, item by item

| 要求 / Requirement | iOS | Android | 小程序 / Mini Program | 鸿蒙 / HarmonyOS |
| --- | --- | --- | --- | --- |
| 依赖上游组件，不依赖 CYLTabBarController 的 TabBar / Depend on the upstream component, not on the tab bar | ✅ `pod 'CYLAnimatedItem'`（`:git` + `:commit`）；Carthage 例外：链接 CYLTabBarController 的 framework（上游没有单独的 framework） / ✅ `pod 'CYLAnimatedItem'` (`:git` + `:commit`); Carthage exception: links CYLTabBarController's framework (no separate upstream framework) | ✅ `cyltabbarcontroller-animateditem`，按 commit 源码构建 / ✅ built from source at a commit | ✅ 按 commit 复制 `cyl-animated-item` / ✅ `cyl-animated-item` copied at a commit | ✅ 按 commit 复制 `cylanimateditem`（`file:` 依赖） / ✅ `cylanimateditem` copied at a commit (`file:` dependency) |
| 删除本仓库的引擎副本 / Delete this repository's engine copy | ✅ `CYLPlaceholderAnimation/`、`LottieSwift/`、`RiveSwift/` | ✅ 引擎副本与三个 animator 模块 / ✅ the engine copy and three animator modules | ✅ `no-animation/` 删除，引擎经抽象节点接入 / ✅ `no-animation/` deleted, engines through abstract nodes | ✅ Lottie / PAG / Rive animator 移到示例 / ✅ moved to the example |
| `CYLPlaceholderView` 基于 `CYLAnimatedItemView`，公开 API 不变 / builds on `CYLAnimatedItemView`, public API kept | ✅ 子类 / ✅ subclass | ✅ 子类 / ✅ subclass | ✅ 组合（小程序组件不能继承） / ✅ composition (components cannot inherit) | ✅ 组合（ArkTS 结构体不能继承）；部分引擎类不再由核心导出 / ✅ composition (ArkTS structs cannot inherit); some engine classes no longer exported by the core |
| 核心不依赖动效引擎；示例层引入引擎才播放 / Core with no engine; animations only with an engine in the example | ✅ | ✅ | ✅ | ✅ |
| 显示优先级：动画 → 静态图片 → 占位图（含异常与 URL 下载） / Display priority: animation → static image → placeholder (failures and URL downloads included) | ✅ 基类处理；Lottie 兜底只接收 Lottie 文档（上游 PR #814） / ✅ base class; the Lottie fallback takes only Lottie documents (upstream PR #814) | ✅ | ✅ | ✅ |
| 类型 key 缺引擎时可编译、仅警告 / Type keys compile without their engine, with a warning | ✅ 23 个 key 标注 `CYL_*_REQUIRED` / ✅ 23 keys carry `CYL_*_REQUIRED` | ✅ 上游处理 / ✅ upstream | — | — |
| 多引擎注册与报告 / Multi-engine registration and report | ✅ 测试 + Example-Scenarios 引擎状态与报告 / ✅ test + engine status and report in Example-Scenarios | ✅ 上游 / ✅ upstream | ✅ 引擎槽：Lottie、PAG、Rive、SVGA / ✅ engine slots | ✅ `CYLAnimatedItemEngines.register` |
| 角标与选中指示留在子类 / Badge and selection indicator stay in the subclass | ✅ | ✅ | ✅ | ✅ |
| 每个发布包带协议文件 / A license in every published package | ✅ `scripts/check_package_licenses.py`（含复制的上游包） / ✅ (copied upstream packages included) | ✅ | ✅ | ✅ |

## TODO

| 中文 | English |
| --- | --- |
| TODO 1（iOS）：完成一次完整的绿色 iOS CI 运行（pod lib lint、单元、动画、无障碍、framework、Carthage、五个 Demo 与截图），并把截图写入 README。 | TODO 1 (iOS): one complete green iOS CI run (pod lib lint, unit, animation, accessibility, framework, Carthage, the five demos with screenshots), and the screenshots in the README. |
| TODO 2（鸿蒙）：在 DevEco Studio 中编译并在模拟器上运行；风险最高的是以全局 `@Builder` 作为 `@BuilderParam`、`@ObjectLink @Watch`、`blendMode` 着色；核对 API 变化（移出核心的 animator 类）。 | TODO 2 (HarmonyOS): build in DevEco Studio and run on the emulator; riskiest: a global `@Builder` as `@BuilderParam`, `@ObjectLink @Watch`, `blendMode` tinting; review the API change (animator classes moved out of the core). |
| TODO 3（小程序）：在微信开发者工具中查看布局、重复次数（“3 次”）、“全部播放”、HUD、状态条与刷新图标、读屏输出。 | TODO 3 (Mini Program): check in the WeChat DevTools the layout, repeat counts ("3 times"), "Play all", the HUD, status bar and refresh icons, and screen-reader output. |
| TODO 4（视觉，全部平台）：布局、角标位置、状态条、HUD 的截图核对。 | TODO 4 (visual, every platform): screenshots of the layout, badge position, status bar and HUD. |
| TODO 5（功能差距）：重复次数大于 1 时 iOS 的 GIF / Rive / SVGA 按文件本身播放、Android 循环；Android 没有动效颜色 API；Rive 数据绑定测试已删除。 | TODO 5 (feature gaps): with a repeat count above 1, iOS GIF / Rive / SVGA play as the file defines and Android loops; Android has no animation color API; the Rive data-binding tests were dropped. |
| TODO 6（上游需求）：CocoaPods trunk 发布 `CYLAnimatedItem`（之后本仓库才能 `pod trunk push`）；单独的 CYLAnimatedItem framework（Carthage）；`carthage bootstrap` 不扫描其 Flutter 示例工程；`CYLBadgeTextDisplaying` 的 Swift interface 可编译；小程序组件转发 `ready` / `complete` / `error`、无障碍角色与标题样式属性；鸿蒙 `CYLAnimatedItemEngines` 支持自定义类型与注销。 | TODO 6 (upstream requests): a CocoaPods trunk release of `CYLAnimatedItem` (before this repository can `pod trunk push`); a separate CYLAnimatedItem framework (Carthage); `carthage bootstrap` not scanning its Flutter example project; a `CYLBadgeTextDisplaying` Swift interface that compiles; the mini program component forwarding `ready` / `complete` / `error`, an accessibility role and title style properties; HarmonyOS `CYLAnimatedItemEngines` with custom types and unregistering. |
| TODO 7（下游）：CYLSearchViewController 与 CollectionViewClassifyMenu 以源码构建本仓库 Android 模块时须加入 `:cylanimateditem`。 | TODO 7 (downstream): CYLSearchViewController and CollectionViewClassifyMenu must add `:cylanimateditem` when they build this repository's Android module from source. |

## 按 commit 引入 / Taken by commit

| 中文 | English |
| --- | --- |
| 上游组件尚未发布，统一使用 `Cartfile` 固定的 commit（`scripts/resolve-cyltabbarcontroller-commit.sh --write` 更新 Cartfile 与 Podfile）：iOS Podfile 的 `pod 'CYLAnimatedItem', :git, :commit`；Carthage / 测试的 `scripts/cyltabbarcontroller-xcframework.sh`；Android `settings.gradle.kts` 自动检出；小程序 `npm run sync-animated-item`；鸿蒙 `scripts/sync-harmonyos-cylanimateditem.sh`（`--check` 校验）。复制的上游文件不修改，保留上游 LICENSE 与 `UPSTREAM_COMMIT`。 | The upstream component is not published yet, so every platform uses the commit the `Cartfile` pins (`scripts/resolve-cyltabbarcontroller-commit.sh --write` updates the Cartfile and the Podfiles): `pod 'CYLAnimatedItem', :git, :commit` in the iOS Podfiles; `scripts/cyltabbarcontroller-xcframework.sh` for Carthage and the tests; an automatic checkout in Android's `settings.gradle.kts`; `npm run sync-animated-item` for the mini program; `scripts/sync-harmonyos-cylanimateditem.sh` for HarmonyOS (`--check` verifies it). Copied upstream files are not edited and keep the upstream LICENSE and `UPSTREAM_COMMIT`. |
