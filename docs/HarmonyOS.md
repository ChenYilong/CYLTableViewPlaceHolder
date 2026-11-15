# 鸿蒙 / HarmonyOS

CYLTableViewPlaceHolder 的鸿蒙端：ArkTS / ArkUI 的库与 example，对照 iOS 库（`CYLTableViewPlaceHolder/`）与 iOS
example（`Examples/Example-Scenarios`）。代码在 `CrossPlatform/harmonyos-cylplaceholder`。

The HarmonyOS port of CYLTableViewPlaceHolder: an ArkTS / ArkUI library and example, mirroring the iOS library
(`CYLTableViewPlaceHolder/`) and the iOS example (`Examples/Example-Scenarios`). Code:
`CrossPlatform/harmonyos-cylplaceholder`.

## 鸿蒙系统版本 / HarmonyOS version

| 项目 / Item | 版本 / Version |
|:---|:---|
| 目标系统 / Target OS | HarmonyOS 6.0.1 (API 21, Release) |
| SDK | HarmonyOS SDK 6.0.1.112 (`compileSdkVersion` / `targetSdkVersion` 6.0.1(21)) |
| 最低系统 / Minimum OS | HarmonyOS 6.0.1 (API 21) |
| 开发工具 / IDE | DevEco Studio 6.0.1.251 (hvigor, ohpm and the emulator bundled) |
| 语言与 UI / Language and UI | ArkTS, ArkUI (declarative), Stage model |

## 打分规则 / Scoring

| 中文 | English |
|:---|:---|
| 两张表一起打分：完成度 = 第二列没有 TODO 的行 ÷ 计入的行 × 100（向下取整）。第二列默认 TODO；每完成一个功能，就把它的 TODO 换成鸿蒙实现（API 名或页面路径），移除全部 TODO 即满分。只有 iOS 自己标为不可用（NS_UNAVAILABLE）的符号记 n/a，不计入。分数由 `node scripts/harmony-port-tables.js` 计算并写回本文件，开发过程中每完成一个功能就重跑一次。 | Both tables are scored together: score = rows whose second column has no TODO ÷ counted rows × 100 (rounded down). The second column starts as TODO; each finished feature replaces its TODO with the HarmonyOS implementation (API name or page path), and no TODO left is full marks. Only symbols iOS itself marks unavailable (NS_UNAVAILABLE) are n/a and not counted. `node scripts/harmony-port-tables.js` computes the score and writes it back here; it is re-run after every finished feature. |

## 任务 / Tasks

### TODO: HarmonyOS port, library and example (score 33)

- **Date / branch:** 2026-11-16, `feat/android-refresh-port-followup` (pull request #31).
- **The user's original prompt (verbatim):** "开始鸿蒙端开发，在新建跨端文档，标注鸿蒙系统版本，新建表格，列出iOS版本存在的API， 在新建表格列出iOS端example 层所有演示，每个表格的第二列为鸿蒙对应实现，默认填TODO 鸿蒙系统软件开发过程中需要实时打分，两个表格一起打分。移除所有todo为满分。每每完成一个功能移除一个todo，一直到满分为止。"
- **Requirements:** a new cross-platform document (this file) with the HarmonyOS version; table 1 lists every iOS
  public API, table 2 every iOS example demo; the second column of both is the HarmonyOS implementation, TODO by
  default; one live score for both tables; remove one TODO per finished feature until the score is 100.
- **Status 2026-11-16 (score 0 → 9):** placeholder core ported to the `cylplaceholder` HAR:
  `CYLPlaceholderLocalization`, `CYLPlaceholderScenario` (35 scenarios, category, permission, actions, button
  styles, `CYLPlaceholderComponent`, `CYLPlaceholderScenarioCatalog`), `CYLPlaceholderView` (styles, messages, badge,
  selected colors, tap highlight; `@Observed CYLPlaceholderViewModel` + `@Component CYLPlaceholderView`) and
  `CYLPlaceholderStackView` (`CYLPlaceholderStackViewModel` + `@Component`). The entry shows a temporary list of all
  35 scenarios. Verified by `scripts/build.sh` (entry HAP and HAR: BUILD SUCCESSFUL) and 5 host-run hypium local
  unit tests (`cylplaceholder/src/test`, `hvigorw test`: 5 pass). Still TODO in these headers: animation playback
  (players, factories, play/stop/progress/speed, repeat counts, `componentWithBundledAnimation` playback),
  `imageBundle`, and the configuration / file initializers (`initWithConfiguration`, `initWithContentsOfURL`,
  `initWithItemContentsOfURL`).
- **Status 2026-11-16 (score 9 → 21, branch `harmony/hud-status`):** HUD, network status bar, page status,
  list placeholder and configuration ported to the `cylplaceholder` HAR: `CYLPlaceholderHUD` (state, timing,
  instance and class methods; drawn by `CYLPlaceholderHUDView` in a global overlay, a `ComponentContent` on the
  `OverlayManager` of `CYLPlaceholderHUD.sharedHUD.containerView`, a `UIContext`), `CYLPlaceholderNetworkMonitor`
  (`@kit.NetworkKit` connection), `CYLPlaceholderStatusView` (+ `CYLPlaceholderStatusViewModel`),
  `CYLPlaceholderStatusController` + `CYLPlaceholderStatusPage` (UIViewController+CYLPlaceholderStatus),
  `CYLPlaceholderListController` + `CYLPlaceholderList` (UITableView / UICollectionView placeholder blocks,
  `cyl_reloadData`, `CYLTableViewPlaceHolderDelegate`, `cyl_placeholderHidden`) and `CYLPlaceholderConfiguration`
  (JSON and XML property lists; `initWithConfiguration`, `initWithContentsOfURL`, `initWithItemContentsOfURL`).
  Verified by `scripts/build.sh test` (entry HAP and HAR: BUILD SUCCESSFUL; 14 host-run hypium tests pass). The UI
  (overlay, bar, list) is verified by compiling only: no emulator. Still TODO in these headers: the HUD's
  `loadingAnimationFileName`, `progressAnimationFileName` and `successAnimationFileName` (animation playback).
- **Status 2026-11-16 (score 21 → 33, branch `harmony/animation`):** animation playback ported to the
  `cylplaceholder` HAR (`CYLPlaceholderAnimation.ets`, internals from `CYLPlaceholderAnimation.kt`):
  `CYLPlaceholderItemAnimatorRegistry` (priority, binding, attribute keys), `CYLPlaceholderItemAnimationFactory`,
  players, `CYLPlaceholderItemViewAnimator`, `CYLPlaceholderAnimationViewModel` + `@Component
  CYLPlaceholderAnimationView`, `CYLPlaceholderAnimationPlayer` / `CYLPlaceholderAnimationFactory` and
  `CYLPlaceholderViewModel.registerAnimationFactory`, play / stop / last frame / progress / speed / repeat counts.
  Engines, registered when the HAR is imported: GIF (`@kit.ImageKit` frames in ArkUI `ImageAnimator`), Lottie
  (`@ohos/lottie` 2.0.28, fallback priority), PAG (Tencent's `@tencent/libpag` 4.5.102) and Rive (`@ohos/rive`
  1.0.4, which needs `useNormalizedOHMUrl`). Placeholder views, stack views (scenario icons and
  `componentWithBundledAnimation` loop) and the HUD (loading / progress / success files, iOS defaults) play bundled
  animations with the static icon until they are ready and when they fail; the GIF, PAG and Rive files of the iOS
  bundle were added to `rawfile/cylplaceholder/animations` with their licenses. Verified by `scripts/build.sh test`
  (entry HAP and HAR: BUILD SUCCESSFUL; 22 host-run hypium tests pass); playback on screen is verified by compiling
  only: no emulator. Still TODO: the Rive options `active`, `trigger` and `color` (view-model properties, not yet
  wired to `@ohos/rive`'s view-model API) and `legacy` (one runtime only).

## 对照表 / Tables

<!-- harmony-tables:begin -->
<!-- Generated by scripts/harmony-port-tables.js; edit the second column by hand, then re-run it for the score. -->

| 中文 | English |
|:---|:---|
| **鸿蒙完成度：33 / 100**（两张表合计：没有 TODO 的行 357 / 计入的行 1064；n/a 20 行不计入）。API 表 357 / 884，演示表 0 / 180。 | **HarmonyOS score: 33 / 100** (both tables: rows without TODO 357 / counted rows 1064; 20 n/a rows not counted). API table 357 / 884, demo table 0 / 180. |

### 表 1：iOS 公开 API / Table 1: iOS public API

#### `CYLPlaceholderAnimation/CYLPlaceholderAnimationView.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderAnimationBackend` | `CYLPlaceholderAnimationBackend` |
| `CYLPlaceholderAnimationErrorHandler` | `CYLPlaceholderAnimationErrorHandler` (`CYLPlaceholderAnimationError`: domain + `CYLPlaceholderAnimationErrorCode`) |
| `CYLPlaceholderAnimationView` | `CYLPlaceholderAnimationViewModel` + `@Component CYLPlaceholderAnimationView` |
| `CYLPlaceholderAnimationView` `animationView` | `CYLPlaceholderAnimationViewModel.animationView` (a `CYLPlaceholderAnimationContentView`) |
| `CYLPlaceholderAnimationView` `player` | `CYLPlaceholderAnimationViewModel.player` |
| `CYLPlaceholderAnimationView` `animatorIdentifier` | `CYLPlaceholderAnimationViewModel.animatorIdentifier` |
| `CYLPlaceholderAnimationView` `backend` | `CYLPlaceholderAnimationViewModel.backend` |
| `CYLPlaceholderAnimationView` `playing` | `CYLPlaceholderAnimationViewModel.playing` |
| `CYLPlaceholderAnimationView` `ready` | `CYLPlaceholderAnimationViewModel.ready` |
| `CYLPlaceholderAnimationView` `errorHandler` | `CYLPlaceholderAnimationViewModel.errorHandler` |
| `CYLPlaceholderAnimationView` `readyHandler` | `CYLPlaceholderAnimationViewModel.readyHandler` |
| `CYLPlaceholderAnimationView` `-initWithFileURL:size:contentMode:error:` | `CYLPlaceholderAnimationViewModel.initWithFileURL(fileURL, width, height, contentMode, onError)` (rawfile or sandbox path) |
| `CYLPlaceholderAnimationView` `-initWithFileURL:size:contentMode:options:error:` | `CYLPlaceholderAnimationViewModel.initWithFileURLOptions(fileURL, width, height, contentMode, options, onError)` |
| `CYLPlaceholderAnimationView` `-initWithFrame:` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderAnimationView` `-initWithCoder:` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderAnimationView` `-play` | `CYLPlaceholderAnimationViewModel.play()` |
| `CYLPlaceholderAnimationView` `-stop` | `CYLPlaceholderAnimationViewModel.stop()` |
| `CYLPlaceholderAnimationView` `-showLastFrame` | `CYLPlaceholderAnimationViewModel.showLastFrame()` |
| `CYLPlaceholderAnimationView` `-setAnimationProgress:` | `CYLPlaceholderAnimationViewModel.setAnimationProgress(progress)` |
| `CYLPlaceholderAnimationView` `-setAnimationSpeed:` | `CYLPlaceholderAnimationViewModel.setAnimationSpeed(speed)` |
| `CYLPlaceholderAnimationView` `-setAnimationRepeatCount:` | `CYLPlaceholderAnimationViewModel.setAnimationRepeatCount(count)` |
| `CYLPlaceholderAnimationView` `-setAnimationColors:` | `CYLPlaceholderAnimationViewModel.setAnimationColors(colors)` |

#### `CYLPlaceholderAnimation/CYLPlaceholderItemAnimationFactory.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderItemAnimationViewMaking` | `CYLPlaceholderItemAnimationViewMaking` |
| `CYLPlaceholderItemAnimationViewMaking` `-animationViewWithURL:size:contentMode:` | `CYLPlaceholderItemAnimationViewMaking.animationViewWithURL(URL, width, height, contentMode)` |
| `CYLPlaceholderItemAnimationViewMaking` `-playerForView:` | `CYLPlaceholderItemAnimationViewMaking.playerForView(view)` |
| `CYLPlaceholderItemAnimationViewMaking` `-isAnimationView:` | `CYLPlaceholderItemAnimationViewMaking.isAnimationView(view)` |
| `CYLPlaceholderItemAnimationFactory` | `CYLPlaceholderItemAnimationFactory` |
| `CYLPlaceholderItemAnimationFactory` `registry` | `CYLPlaceholderItemAnimationFactory.registry` |
| `CYLPlaceholderItemAnimationFactory` `-initWithRegistry:` | `CYLPlaceholderItemAnimationFactory.initWithRegistry(registry)` |
| `CYLPlaceholderItemAnimationFactory` `-init` | `CYLPlaceholderItemAnimationFactory.init()` / `new CYLPlaceholderItemAnimationFactory()` |
| `CYLPlaceholderItemAnimationFactory` `+sharedFactory` | `CYLPlaceholderItemAnimationFactory.sharedFactory()` |
| `CYLPlaceholderItemAnimationFactory` `+animationViewWithURL:size:contentMode:` | `CYLPlaceholderItemAnimationFactory.animationViewWithURL(URL, width, height, contentMode)` (static) |
| `CYLPlaceholderItemAnimationFactory` `+playerForView:` | `CYLPlaceholderItemAnimationFactory.playerForView(view)` (static) |
| `CYLPlaceholderItemAnimationFactory` `+isAnimationView:` | `CYLPlaceholderItemAnimationFactory.isAnimationView(view)` (static) |

#### `CYLPlaceholderAnimation/CYLPlaceholderItemAnimationPlayableView.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderItemAnimationPlayableView` | `CYLPlaceholderItemAnimationPlayableView` (base: `CYLPlaceholderPlayableContentView`) |
| `CYLPlaceholderItemAnimationPlayableView` `-cyl_playAnimationView` | `CYLPlaceholderItemAnimationPlayableView.cyl_playAnimationView()` |
| `CYLPlaceholderItemAnimationPlayableView` `-cyl_showAnimationViewLastFrame` | `CYLPlaceholderItemAnimationPlayableView.cyl_showAnimationViewLastFrame()` |
| `CYLPlaceholderItemAnimationPlayableView` `-cyl_stopAnimationView` | `CYLPlaceholderItemAnimationPlayableView.cyl_stopAnimationView()` |
| `CYLPlaceholderItemAnimationPlayableView` `-cyl_applyAnimationViewColors:` | `CYLPlaceholderItemAnimationPlayableView.cyl_applyAnimationViewColors(colors)` |
| `CYLPlaceholderItemAnimationPlayableView` `-cyl_setAnimationViewRepeatCount:` | `CYLPlaceholderItemAnimationPlayableView.cyl_setAnimationViewRepeatCount(count)` |
| `CYLPlaceholderItemAnimationPlayableView` `cyl_isAnimationViewReady` | `CYLPlaceholderItemAnimationPlayableView.cyl_isAnimationViewReady` |
| `CYLPlaceholderItemAnimationPlayableView` `cyl_animationViewReadyHandler` | `CYLPlaceholderItemAnimationPlayableView.cyl_animationViewReadyHandler` |
| `CYLPlaceholderItemAnimationPlayableView` `cyl_animationViewErrorHandler` | `CYLPlaceholderItemAnimationPlayableView.cyl_animationViewErrorHandler` |
| `CYLPlaceholderItemAnimationViewProviding` | `CYLPlaceholderItemAnimationViewProviding` |
| `CYLPlaceholderItemAnimationViewProviding` `+cyl_animationViewWithFileURL:options:contentMode:` | `CYLPlaceholderItemAnimationViewProviding.cyl_animationViewWithFileURL(fileURL, options, contentMode)` |

#### `CYLPlaceholderAnimation/CYLPlaceholderItemAnimationPlayer.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderItemAnimationPlayer` | `CYLPlaceholderItemAnimationPlayer` |
| `CYLPlaceholderItemAnimationPlayer` `animationView` | `CYLPlaceholderItemAnimationPlayer.animationView` |
| `CYLPlaceholderItemAnimationPlayer` `-play` | `CYLPlaceholderItemAnimationPlayer.play()` |
| `CYLPlaceholderItemAnimationPlayer` `-showLastFrame` | `CYLPlaceholderItemAnimationPlayer.showLastFrame()` |
| `CYLPlaceholderItemAnimationPlayer` `-stop` | `CYLPlaceholderItemAnimationPlayer.stop()` |
| `CYLPlaceholderItemAnimationPlayer` `progress` | `CYLPlaceholderItemAnimationPlayer.progress` (optional on iOS: `supportsProgress`) |
| `CYLPlaceholderItemAnimationPlayer` `animationSpeed` | `CYLPlaceholderItemAnimationPlayer.animationSpeed` (optional on iOS: `supportsAnimationSpeed`) |
| `CYLPlaceholderItemAnimationPlayer` `-setAnimationRepeatCount:` | `CYLPlaceholderItemAnimationPlayer.setAnimationRepeatCount(count)` |
| `CYLPlaceholderItemAnimationPlayer` `-applyDarkColors:traitCollection:` | `CYLPlaceholderItemAnimationPlayer.applyDarkColors(darkColors, dark)` (a dark flag for the trait collection) |
| `CYLPlaceholderItemAnimationPlayer` `-applyColors:traitCollection:` | `CYLPlaceholderItemAnimationPlayer.applyColors(colors, dark)` |
| `CYLPlaceholderItemAnimationBasePlayer` | `CYLPlaceholderItemAnimationBasePlayer` |
| `CYLPlaceholderItemAnimationBasePlayer` `-initWithAnimationView:` | `CYLPlaceholderItemAnimationBasePlayer.initWithAnimationView(view)` / `new CYLPlaceholderItemAnimationBasePlayer(view)` (WeakRef) |
| `CYLPlaceholderItemAnimationBasePlayer` `-init` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderItemAnimationBasePlayer` `+new` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderItemAnimationBasePlayer` `animationView` | `CYLPlaceholderItemAnimationBasePlayer.animationView` |

#### `CYLPlaceholderAnimation/CYLPlaceholderItemAnimator.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderItemAnimatorPriority` | `CYLPlaceholderItemAnimatorPriority` (`...PriorityDefault` 0, `...PriorityFallback` -1000) |
| `CYLPlaceholderItemAnimationFileMatching` | `CYLPlaceholderItemAnimationFileMatching` |
| `CYLPlaceholderItemAnimationFileMatching` `identifier` | `CYLPlaceholderItemAnimationFileMatching.identifier` |
| `CYLPlaceholderItemAnimationFileMatching` `-canAnimateFileAtURL:` | `CYLPlaceholderItemAnimationFileMatching.canAnimateFileAtURL(URL)` |
| `CYLPlaceholderItemAnimationFileMatching` `priority` | `CYLPlaceholderItemAnimationFileMatching.priority` |
| `CYLPlaceholderItemAnimationFileMatching` `fileExtensions` | `CYLPlaceholderItemAnimationFileMatching.fileExtensions` |
| `CYLPlaceholderItemAnimationFileMatching` `attributeKeys` | `CYLPlaceholderItemAnimationFileMatching.attributeKeys` |
| `CYLPlaceholderItemAnimationViewFactory` | `CYLPlaceholderItemAnimationViewFactory` |
| `CYLPlaceholderItemAnimationViewFactory` `-animationViewWithURL:size:contentMode:` | `CYLPlaceholderItemAnimationViewFactory.animationViewWithURL(URL, width, height, contentMode)` |
| `CYLPlaceholderItemAnimationViewFactory` `-playerForAnimationView:` | `CYLPlaceholderItemAnimationViewFactory.playerForAnimationView(view)` |
| `CYLPlaceholderItemAnimator` | `CYLPlaceholderItemAnimator` |

#### `CYLPlaceholderAnimation/CYLPlaceholderItemAnimatorRegistry.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderItemAnimatorRegistering` | `CYLPlaceholderItemAnimatorRegistering` |
| `CYLPlaceholderItemAnimatorRegistering` `-registerAnimator:` | `CYLPlaceholderItemAnimatorRegistering.registerAnimator(animator)` |
| `CYLPlaceholderItemAnimatorRegistering` `-unregisterAnimatorWithIdentifier:` | `CYLPlaceholderItemAnimatorRegistering.unregisterAnimatorWithIdentifier(identifier)` |
| `CYLPlaceholderItemAnimatorRegistering` `-animators` | `CYLPlaceholderItemAnimatorRegistering.animators()` |
| `CYLPlaceholderItemAnimatorRegistering` `-animatorWithIdentifier:` | `CYLPlaceholderItemAnimatorRegistering.animatorWithIdentifier(identifier)` |
| `CYLPlaceholderItemAnimatorRegistering` `-animatorForURL:` | `CYLPlaceholderItemAnimatorRegistering.animatorForURL(URL)` |
| `CYLPlaceholderItemAnimatorRegistering` `-animatorForAttributes:` | `CYLPlaceholderItemAnimatorRegistering.animatorForAttributes(attributes)` |
| `CYLPlaceholderItemAnimatorRegistering` `-attributeKeyForGenericKey:inAttributes:` | `CYLPlaceholderItemAnimatorRegistering.attributeKeyForGenericKey(genericKey, attributes)` |
| `CYLPlaceholderItemAnimatorRegistering` `-bindURL:toAnimator:` | `CYLPlaceholderItemAnimatorRegistering.bindURL(URL, animator)` |
| `CYLPlaceholderItemAnimatorRegistering` `-attributeKeysForGenericKey:` | `CYLPlaceholderItemAnimatorRegistering.attributeKeysForGenericKey(genericKey)` |
| `CYLPlaceholderItemAnimatorRegistering` `-fileExtensions` | `CYLPlaceholderItemAnimatorRegistering.fileExtensions()` |
| `CYLPlaceholderItemAnimatorRegistry` | `CYLPlaceholderItemAnimatorRegistry` (GIF, Lottie, PAG, Rive registered by `CYLPlaceholderItemAnimationEngine` when the HAR is imported) |
| `CYLPlaceholderItemAnimatorRegistry` `+sharedRegistry` | `CYLPlaceholderItemAnimatorRegistry.sharedRegistry()` |
| `CYLPlaceholderItemAnimatorRegistry` `+registerAnimator:` | `CYLPlaceholderItemAnimatorRegistry.registerAnimator(animator)` (static, shared registry) |
| `CYLPlaceholderItemAnimatorRegistry` `+unregisterAnimatorWithIdentifier:` | `CYLPlaceholderItemAnimatorRegistry.unregisterAnimatorWithIdentifier(identifier)` (static, shared registry) |
| `CYLPlaceholderItemAnimatorRegistry` `+animators` | `CYLPlaceholderItemAnimatorRegistry.animators()` (static, shared registry) |
| `CYLPlaceholderItemAnimatorRegistry` `+animatorWithIdentifier:` | `CYLPlaceholderItemAnimatorRegistry.animatorWithIdentifier(identifier)` (static, shared registry) |
| `CYLPlaceholderItemAnimatorRegistry` `+animatorForURL:` | `CYLPlaceholderItemAnimatorRegistry.animatorForURL(URL)` (static, shared registry) |
| `CYLPlaceholderItemAnimatorRegistry` `+animatorForAttributes:` | `CYLPlaceholderItemAnimatorRegistry.animatorForAttributes(attributes)` (static, shared registry) |
| `CYLPlaceholderItemAnimatorRegistry` `+attributeKeyForGenericKey:inAttributes:` | `CYLPlaceholderItemAnimatorRegistry.attributeKeyForGenericKey(genericKey, attributes)` (static, shared registry) |
| `CYLPlaceholderItemAnimatorRegistry` `+bindURL:toAnimator:` | `CYLPlaceholderItemAnimatorRegistry.bindURL(URL, animator)` (static, shared registry) |
| `CYLPlaceholderItemAnimatorRegistry` `+attributeKeysForGenericKey:` | `CYLPlaceholderItemAnimatorRegistry.attributeKeysForGenericKey(genericKey)` (static, shared registry) |
| `CYLPlaceholderItemAnimatorRegistry` `+fileExtensions` | `CYLPlaceholderItemAnimatorRegistry.fileExtensions()` (static, shared registry) |

#### `CYLPlaceholderAnimation/CYLPlaceholderItemViewAnimator.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderItemViewAnimator` | `CYLPlaceholderItemViewAnimator` |
| `CYLPlaceholderItemViewAnimator` `-initWithIdentifier:fileExtensions:attributeKeys:viewProvider:` | `CYLPlaceholderItemViewAnimator.initWithIdentifier(identifier, fileExtensions, attributeKeys, viewProvider)` / `new CYLPlaceholderItemViewAnimator(...)` |
| `CYLPlaceholderItemViewAnimator` `-init` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderItemViewAnimator` `+new` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderItemViewAnimator` `viewProvider` | `CYLPlaceholderItemViewAnimator.viewProvider` (null resets it) |

#### `CYLPlaceholderAnimation/GIF/CYLGIFPlaceholderItemAnimator.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLGIFPlaceholderItemAnimator` | `CYLGIFPlaceholderItemAnimator` (@kit.ImageKit frames + ArkUI `ImageAnimator`) |
| `CYLGIFPlaceholderItemAnimator` `animator` | `CYLGIFPlaceholderItemAnimator.animator` |

#### `CYLPlaceholderAnimation/PAG/CYLPAGPlaceholderItemAnimator.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPAGPlaceholderItemAnimator` | `CYLPAGPlaceholderItemAnimator` (@tencent/libpag 4.5.102: `PAGFile`, `PAGViewController`, `PAGView`; no speed in libpag) |

#### `CYLPlaceholderAnimation/Rive/CYLRivePlaceholderItemAnimator.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderAnimationOption` | `CYLPlaceholderAnimationOption` |
| `CYLPlaceholderAnimationOptionRiveArtboard` | `CYLPlaceholderAnimationOptionRiveArtboard` |
| `CYLPlaceholderAnimationOptionRiveStateMachine` | `CYLPlaceholderAnimationOptionRiveStateMachine` |
| `CYLPlaceholderAnimationOptionRiveActiveProperty` | TODO |
| `CYLPlaceholderAnimationOptionRiveActiveDuration` | `CYLPlaceholderAnimationOptionRiveActiveDuration` (for the `input` option, as the iOS legacy runtime) |
| `CYLPlaceholderAnimationOptionRiveTriggerProperty` | TODO |
| `CYLPlaceholderAnimationOptionRiveColor` | TODO |
| `CYLPlaceholderAnimationOptionRiveInput` | `CYLPlaceholderAnimationOptionRiveInput` |
| `CYLPlaceholderAnimationOptionRiveTriggerInput` | `CYLPlaceholderAnimationOptionRiveTriggerInput` |
| `CYLPlaceholderAnimationOptionRiveAnimation` | `CYLPlaceholderAnimationOptionRiveAnimation` |
| `CYLPlaceholderAnimationOptionRiveLegacyRuntime` | TODO |
| `CYLRivePlaceholderItemAnimator` | `CYLRivePlaceholderItemAnimator` (@ohos/rive 1.0.4 `RiveAnimationView`) |
| `CYLRivePlaceholderItemAnimator` `animator` | `CYLRivePlaceholderItemAnimator.animator` |

#### `CYLRefresh/Base/CYLRefreshAutoFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshAutoFooter` | `CYLRefreshAutoFooterModel` + `CYLRefreshFooterView` |
| `CYLRefreshAutoFooter` `automaticallyRefresh` | `CYLRefreshAutoFooterModel.automaticallyRefresh` |
| `CYLRefreshAutoFooter` `triggerAutomaticallyRefreshPercent` | `CYLRefreshAutoFooterModel.triggerAutomaticallyRefreshPercent` |
| `CYLRefreshAutoFooter` `autoTriggerTimes` | `CYLRefreshAutoFooterModel.autoTriggerTimes` |

#### `CYLRefresh/Base/CYLRefreshBackFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshBackFooter` | `CYLRefreshBackFooterModel` |
| `CYLRefreshBackFooter` `noMoreDataDisplayDuration` | `CYLRefreshBackFooterModel.noMoreDataDisplayDuration` |
| `CYLRefreshBackFooter` `secondaryTriggerOffset` | `CYLRefreshBackFooterModel.secondaryTriggerOffset` |
| `CYLRefreshBackFooter` `secondaryDimension` | `CYLRefreshBackFooterModel.secondaryDimension` |
| `CYLRefreshBackFooter` `secondaryCloseTriggerOffset` | `CYLRefreshBackFooterModel.secondaryCloseTriggerOffset` |
| `CYLRefreshBackFooter` `secondaryView` | `CYLRefreshBackFooterModel.secondaryView` |
| `CYLRefreshBackFooter` `secondaryOpen` | `CYLRefreshBackFooterModel.secondaryOpen` |
| `CYLRefreshBackFooter` `secondaryOpenedBlock` | `CYLRefreshBackFooterModel.secondaryOpenedBlock` |
| `CYLRefreshBackFooter` `secondaryClosedBlock` | `CYLRefreshBackFooterModel.secondaryClosedBlock` |
| `CYLRefreshBackFooter` `secondaryVelocity` | `CYLRefreshBackFooterModel.secondaryVelocity` |
| `CYLRefreshBackFooter` `-openSecondary` | `CYLRefreshBackFooterModel.openSecondary()` |
| `CYLRefreshBackFooter` `-closeSecondary` | `CYLRefreshBackFooterModel.closeSecondary()` |

#### `CYLRefresh/Base/CYLRefreshComponent.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshState` | `CYLRefreshState` |
| `CYLRefreshScrollMode` | `CYLRefreshScrollMode` |
| `CYLRefreshTriggerMode` | `CYLRefreshTriggerMode` |
| `CYLRefreshPhase` | `CYLRefreshPhase` |
| `CYLRefreshComponentHandler` | `CYLRefreshComponentHandler` |
| `CYLRefreshComponentRefreshingBlock` | `CYLRefreshComponentRefreshingBlock` |
| `CYLRefreshComponentBeginRefreshingCompletionBlock` | `CYLRefreshComponentBeginRefreshingCompletionBlock` |
| `CYLRefreshComponentEndRefreshingCompletionBlock` | `CYLRefreshComponentEndRefreshingCompletionBlock` |
| `CYLRefreshComponentAction` | `CYLRefreshComponentAction` |
| `CYLRefreshComponent` | `CYLRefreshComponentModel` + `CYLRefreshComponentView` |
| `CYLRefreshComponent` `fastAnimationDuration` | `CYLRefreshComponentModel.fastAnimationDuration` |
| `CYLRefreshComponent` `slowAnimationDuration` | `CYLRefreshComponentModel.slowAnimationDuration` |
| `CYLRefreshComponent` `-setAnimationDisabled` | `CYLRefreshComponentModel.setAnimationDisabled()` |
| `CYLRefreshComponent` `refreshingBlock` | `CYLRefreshComponentModel.refreshingBlock` |
| `CYLRefreshComponent` `-setRefreshingTarget:refreshingAction:` | `CYLRefreshComponentModel.setRefreshingTarget(target, action)` |
| `CYLRefreshComponent` `refreshingTarget` | `CYLRefreshComponentModel.refreshingTarget` |
| `CYLRefreshComponent` `refreshingAction` | `CYLRefreshComponentModel.refreshingAction` |
| `CYLRefreshComponent` `-executeRefreshingCallback` | `CYLRefreshComponentModel.executeRefreshingCallback()` |
| `CYLRefreshComponent` `-beginRefreshing` | `CYLRefreshComponentModel.beginRefreshing()` |
| `CYLRefreshComponent` `-beginRefreshingWithCompletionBlock:` | `CYLRefreshComponentModel.beginRefreshingWithCompletionBlock(completion)` |
| `CYLRefreshComponent` `beginRefreshingCompletionBlock` | `CYLRefreshComponentModel.beginRefreshingCompletionBlock` |
| `CYLRefreshComponent` `CYLRefreshDeprecated` | `CYLRefreshComponentModel.autoChangeAlpha` |
| `CYLRefreshComponent` `endRefreshingAnimationBeginAction` | `CYLRefreshComponentModel.endRefreshingAnimationBeginAction` |
| `CYLRefreshComponent` `endRefreshingCompletionBlock` | `CYLRefreshComponentModel.endRefreshingCompletionBlock` |
| `CYLRefreshComponent` `-endRefreshing` | `CYLRefreshComponentModel.endRefreshing()` |
| `CYLRefreshComponent` `-endRefreshingWithCompletionBlock:` | `CYLRefreshComponentModel.endRefreshingWithCompletionBlock(completion)` |
| `CYLRefreshComponent` `refreshing` | `CYLRefreshComponentModel.refreshing` |
| `CYLRefreshComponent` `exclusiveWithOtherRefresh` | `CYLRefreshComponentModel.exclusiveWithOtherRefresh` |
| `CYLRefreshComponent` `blockedByOtherRefreshBlock` | `CYLRefreshComponentModel.blockedByOtherRefreshBlock` |
| `CYLRefreshComponent` `state` | `CYLRefreshComponentModel.state` |
| `CYLRefreshComponent` `scrollViewOriginalInset` | `CYLRefreshComponentModel.scrollViewOriginalInset` |
| `CYLRefreshComponent` `scrollView` | `CYLRefreshComponentModel.scrollView` |
| `CYLRefreshComponent` `flipsHorizontallyInOppositeLayoutDirectionViews` | TODO |
| `CYLRefreshComponent` `additionalFlipsViews` | TODO |
| `CYLRefreshComponent` `-prepare` | `CYLRefreshComponentModel.prepare()` |
| `CYLRefreshComponent` `-placeSubviews` | `CYLRefreshComponentModel.placeSubviews()` |
| `CYLRefreshComponent` `-scrollViewContentOffsetDidChange:` | `CYLRefreshComponentModel.scrollViewContentOffsetDidChange(change)` |
| `CYLRefreshComponent` `-scrollViewContentSizeDidChange:` | `CYLRefreshComponentModel.scrollViewContentSizeDidChange()` |
| `CYLRefreshComponent` `-scrollViewPanStateDidChange:` | `CYLRefreshComponentModel.scrollViewPanStateDidChange(state)` |
| `CYLRefreshComponent` `-i18nDidChange` | `CYLRefreshComponentModel.i18nDidChange()` |
| `CYLRefreshComponent` `pullingPercent` | `CYLRefreshComponentModel.pullingPercent` |
| `CYLRefreshComponent` `CYLRefreshDeprecated` | `CYLRefreshComponentModel.autoChangeAlpha` |
| `CYLRefreshComponent` `automaticallyChangeAlpha` | `CYLRefreshComponentModel.automaticallyChangeAlpha` |
| `CYLRefreshComponent` `+attach:` | `CYLRefreshComponentModel.attach(scrollView)` |
| `CYLRefreshComponent` `+attach:target:action:` | `CYLRefreshComponentModel.attachWithTarget(scrollView, target, action)` |
| `CYLRefreshComponent` `-attach:` | `CYLRefreshComponentModel.attach(scrollView)` |
| `CYLRefreshComponent` `-addTarget:action:` | `CYLRefreshComponentModel.addTarget(target, action)` |
| `CYLRefreshComponent` `-removeTarget:action:` | `CYLRefreshComponentModel.removeTarget(target, action)` |
| `CYLRefreshComponent` `refreshingHandler` | `CYLRefreshComponentModel.refreshingHandler` |
| `CYLRefreshComponent` `attached` | `CYLRefreshComponentModel.attached` |
| `CYLRefreshComponent` `triggerRate` | `CYLRefreshComponentModel.triggerRate` |
| `CYLRefreshComponent` `finishDuration` | `CYLRefreshComponentModel.finishDuration` |
| `CYLRefreshComponent` `scrollMode` | `CYLRefreshComponentModel.scrollMode` |
| `CYLRefreshComponent` `colorAccent` | `CYLRefreshComponentModel.colorAccent` |
| `CYLRefreshComponent` `colorPrimary` | `CYLRefreshComponentModel.colorPrimary` |
| `CYLRefreshComponent` `expanded` | `CYLRefreshComponentModel.expanded` |
| `CYLRefreshComponent` `expandHeight` | `CYLRefreshComponentModel.expandHeight` |
| `CYLRefreshComponent` `dragOffset` | `CYLRefreshComponentModel.dragOffset` |
| `CYLRefreshComponent` `phase` | `CYLRefreshComponentModel.phase` |
| `CYLRefreshComponent` `-isInAnyPhase:` | `CYLRefreshComponentModel.isInAnyPhase(phases)` |
| `CYLRefreshComponent` `-isInPhases:` | `CYLRefreshComponentModel.isInPhases(...phases)` |
| `CYLRefreshComponent` `-endRefreshingWithSuccess:` | `CYLRefreshComponentModel.endRefreshingWithSuccess(success)` |
| `CYLRefreshComponent` `-beginRefreshingWithDuration:overOffset:force:` | `CYLRefreshComponentModel.beginRefreshingWithDuration(duration, overOffset, force)` |
| `CYLRefreshComponent` `lastRefreshSucceeded` | `CYLRefreshComponentModel.lastRefreshSucceeded` |
| `CYLRefreshComponent` `autoHideRefresh` | `CYLRefreshComponentModel.autoHideRefresh` |
| `CYLRefreshComponent` `-isReadyToAutoHide` | `CYLRefreshComponentModel.isReadyToAutoHide()` |
| `CYLRefreshComponent` `-updateAutoHideVisibility` | `CYLRefreshComponentModel.updateAutoHideVisibility()` |
| `CYLRefreshComponent` `refreshEnabled` | `CYLRefreshComponentModel.refreshEnabled` |
| `CYLRefreshComponent` `triggersWhenReached` | `CYLRefreshComponentModel.triggersWhenReached` |
| `CYLRefreshComponent` `triggerMode` | `CYLRefreshComponentModel.triggerMode` |
| `CYLRefreshComponent` `hapticFeedback` | `CYLRefreshComponentModel.hapticFeedback` |
| `CYLRefreshComponent` `maxPullDistance` | `CYLRefreshComponentModel.maxPullDistance` |
| `CYLRefreshComponent` `notifiesWhenHidden` | `CYLRefreshComponentModel.notifiesWhenHidden` |
| `CYLRefreshComponent` `-addPhaseObserver:` | `CYLRefreshComponentModel.addPhaseObserver(observer)` |
| `CYLRefreshComponent` `-removePhaseObserver:` | `CYLRefreshComponentModel.removePhaseObserver(token)` |
| `CYLRefreshComponent` `-addObservers` | `CYLRefreshComponentModel.addObservers()` |
| `CYLRefreshComponent` `-removeObservers` | `CYLRefreshComponentModel.removeObservers()` |
| `CYLRefreshComponent` `-didAttachToScrollView:` | `CYLRefreshComponentModel.didAttachToScrollView(scrollView)` |
| `CYLRefreshComponent` `-willDetachFromScrollView:` | `CYLRefreshComponentModel.willDetachFromScrollView(scrollView)` |
| `CYLRefreshComponent` `-scrollViewContentInsetDidChange:` | `CYLRefreshComponentModel.scrollViewContentInsetDidChange()` |
| `CYLRefreshComponent` `-didScrollWithOffset:percent:dragging:` | `CYLRefreshComponentModel.didScrollWithOffset(offset, percent, dragging)` |
| `CYLRefreshComponent` `-phaseDidChangeFrom:to:` | `CYLRefreshComponentModel.phaseDidChangeFrom(oldPhase, phase)` |
| `CYLRefreshComponent` `-refreshDidFinishWithSuccess:` | `CYLRefreshComponentModel.refreshDidFinishWithSuccess(success)` |
| `CYLRefreshComponent` `-finishingDurationWithSuccess:` | `CYLRefreshComponentModel.finishingDurationWithSuccess(success)` |
| `UILabel(CYLRefresh)` | `CYLRefreshLabel` |
| `UILabel(CYLRefresh)` `+cyl_label` | `CYLRefreshLabel.cyl_label()` |
| `UILabel(CYLRefresh)` `-cyl_textWidth` | `CYLRefreshLabel.cyl_textWidth()` |
| `CYLRefreshComponent(ChainingGrammar)` | `CYLRefreshComponentModel` (chaining) |
| `CYLRefreshComponent(ChainingGrammar)` `-cyl_autoChangeTransparency:` | `CYLRefreshComponentModel.cyl_autoChangeTransparency(enabled)` |
| `CYLRefreshComponent(ChainingGrammar)` `-cyl_afterBeginningAction:` | `CYLRefreshComponentModel.cyl_afterBeginningAction(action)` |
| `CYLRefreshComponent(ChainingGrammar)` `-cyl_endingAnimationBeginningAction:` | `CYLRefreshComponentModel.cyl_endingAnimationBeginningAction(action)` |
| `CYLRefreshComponent(ChainingGrammar)` `-cyl_afterEndingAction:` | `CYLRefreshComponentModel.cyl_afterEndingAction(action)` |
| `CYLRefreshComponent(ChainingGrammar)` `-cyl_linkTo:` | `CYLRefreshComponentModel.cyl_linkTo(scrollView)` |

#### `CYLRefresh/Base/CYLRefreshFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshFooter` | `CYLRefreshFooterModel` |
| `CYLRefreshFooter` `+footerWithRefreshingBlock:` | `CYLRefreshFooterModel.footerWithRefreshingBlock(block)` |
| `CYLRefreshFooter` `+footerWithRefreshingTarget:refreshingAction:` | `CYLRefreshFooterModel.footerWithRefreshingTarget(target, action)` |
| `CYLRefreshFooter` `-endRefreshingWithNoMoreData` | `CYLRefreshFooterModel.endRefreshingWithNoMoreData()` |
| `CYLRefreshFooter` `-noticeNoMoreData` | `CYLRefreshFooterModel.noticeNoMoreData()` |
| `CYLRefreshFooter` `-resetNoMoreData` | `CYLRefreshFooterModel.resetNoMoreData()` |
| `CYLRefreshFooter` `noMoreData` | `CYLRefreshFooterModel.noMoreData` |
| `CYLRefreshFooter` `loadsAfterNoMoreData` | `CYLRefreshFooterModel.loadsAfterNoMoreData` |
| `CYLRefreshFooter` `ignoredScrollViewContentInsetBottom` | `CYLRefreshFooterModel.ignoredScrollViewContentInsetBottom` |
| `CYLRefreshFooter` `CYLRefreshDeprecated` | `CYLRefreshFooterModel.automaticallyHidden` |

#### `CYLRefresh/Base/CYLRefreshHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshHeader` | `CYLRefreshHeaderModel` |
| `CYLRefreshHeader` `+headerWithRefreshingBlock:` | `CYLRefreshHeaderModel.headerWithRefreshingBlock(block)` |
| `CYLRefreshHeader` `+headerWithRefreshingTarget:refreshingAction:` | `CYLRefreshHeaderModel.headerWithRefreshingTarget(target, action)` |
| `CYLRefreshHeader` `lastUpdatedTimeKey` | `CYLRefreshHeaderModel.lastUpdatedTimeKey` |
| `CYLRefreshHeader` `lastUpdatedTime` | `CYLRefreshHeaderModel.lastUpdatedTime` |
| `CYLRefreshHeader` `ignoredScrollViewContentInsetTop` | `CYLRefreshHeaderModel.ignoredScrollViewContentInsetTop` |
| `CYLRefreshHeader` `isCollectionViewAnimationBug` | `CYLRefreshHeaderModel.isCollectionViewAnimationBug` |
| `CYLRefreshHeader` `-setExpandHeight:` | `CYLRefreshHeaderModel.setExpandHeight(expandHeight)` |
| `CYLRefreshHeader` `addsRefreshingInset` | `CYLRefreshHeaderModel.addsRefreshingInset` |
| `CYLRefreshHeader` `resetsFooterAfterRefresh` | `CYLRefreshHeaderModel.resetsFooterAfterRefresh` |
| `CYLRefreshHeader` `secondaryTriggerOffset` | `CYLRefreshHeaderModel.secondaryTriggerOffset` |
| `CYLRefreshHeader` `secondaryDimension` | `CYLRefreshHeaderModel.secondaryDimension` |
| `CYLRefreshHeader` `secondaryCloseTriggerOffset` | `CYLRefreshHeaderModel.secondaryCloseTriggerOffset` |
| `CYLRefreshHeader` `secondaryVelocity` | `CYLRefreshHeaderModel.secondaryVelocity` |
| `CYLRefreshHeader` `secondaryView` | `CYLRefreshHeaderModel.secondaryView` |
| `CYLRefreshHeader` `secondaryOpen` | `CYLRefreshHeaderModel.secondaryOpen` |
| `CYLRefreshHeader` `secondaryOpenedBlock` | `CYLRefreshHeaderModel.secondaryOpenedBlock` |
| `CYLRefreshHeader` `secondaryClosedBlock` | `CYLRefreshHeaderModel.secondaryClosedBlock` |
| `CYLRefreshHeader` `-openSecondary` | `CYLRefreshHeaderModel.openSecondary()` |
| `CYLRefreshHeader` `-closeSecondary` | `CYLRefreshHeaderModel.closeSecondary()` |

#### `CYLRefresh/Base/CYLRefreshIconView.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshIconView` | `CYLRefreshIconViewModel` |
| `CYLRefreshIconView` `-setAnimationAttributes:forState:` | `CYLRefreshIconViewModel.setAnimationAttributes(attributes, state)` |
| `CYLRefreshIconView` `-animationAttributesForState:` | `CYLRefreshIconViewModel.animationAttributesForState(state)` |
| `CYLRefreshIconView` `hasAnimations` | `CYLRefreshIconViewModel.hasAnimations` |
| `CYLRefreshIconView` `placeholderView` | TODO |
| `CYLRefreshIconView` `iconSize` | `CYLRefreshIconViewModel.iconSize` |
| `CYLRefreshIconView` `title` | `CYLRefreshIconViewModel.title` |
| `CYLRefreshIconView` `titleFont` | `CYLRefreshIconViewModel.titleFont` |
| `CYLRefreshIconView` `titleColor` | `CYLRefreshIconViewModel.titleColor` |
| `CYLRefreshIconView` `fittingSize` | `CYLRefreshIconViewModel.fittingSize` |
| `CYLRefreshIconView` `scrubsWhilePulling` | `CYLRefreshIconViewModel.scrubsWhilePulling` |
| `CYLRefreshIconView` `-updateForState:` | `CYLRefreshIconViewModel.updateForState(state)` |
| `CYLRefreshIconView` `-updateForPullingPercent:` | `CYLRefreshIconViewModel.updateForPullingPercent(percent)` |
| `CYLRefreshIconAnimating` | `CYLRefreshIconAnimating` |
| `CYLRefreshIconAnimating` `iconView` | `CYLRefreshAnimationHeaderModel.iconView` |
| `CYLRefreshIconAnimating` `usesIconView` | `CYLRefreshAnimationHeaderModel.usesIconView` |
| `CYLRefreshIconAnimating` `-setIconAnimationAttributes:forState:` | `CYLRefreshAnimationHeaderModel.setIconAnimationAttributes(attributes, state)` |
| `CYLRefreshIconAnimating` `-setIconAnimationFilePath:size:forState:` | `CYLRefreshAnimationHeaderModel.setIconAnimationFilePath(filePath, size, state)` |
| `CYLRefreshIconAnimating` `-setBundledIconAnimation:size:forState:` | `CYLRefreshAnimationHeaderModel.setBundledIconAnimation(fileName, size, state)` |
| `CYLRefreshIconAnimating` `bundledIconAnimationFileNames` | `CYLRefreshAnimationHeaderModel.bundledIconAnimationFileNames` |
| `CYLRefreshIconView(CYLRefreshIconAttributes)` | `CYLRefreshIconViewModel` (static) |
| `CYLRefreshIconView(CYLRefreshIconAttributes)` `+attributesForAnimationFilePath:size:` | `CYLRefreshIconViewModel.attributesForAnimationFilePath(filePath, size)` |
| `CYLRefreshIconView(CYLRefreshIconAttributes)` `+attributesForBundledAnimation:size:` | `CYLRefreshIconViewModel.attributesForBundledAnimation(fileName, size)` |
| `CYLRefreshIconView(CYLRefreshIconAttributes)` `bundledAnimationFileNames` | `CYLRefreshIconViewModel.bundledAnimationFileNames` |
| `CYLRefreshComponent(CYLRefreshIconLayout)` | `CYLRefreshComponentModel` (icon layout) |
| `CYLRefreshComponent(CYLRefreshIconLayout)` `cyl_iconView` | `CYLRefreshComponentModel.cyl_iconView` |
| `CYLRefreshComponent(CYLRefreshIconLayout)` `cyl_usesIconView` | `CYLRefreshComponentModel.cyl_usesIconView` |
| `CYLRefreshComponent(CYLRefreshIconLayout)` `-cyl_setIconAnimationAttributes:forState:` | `CYLRefreshComponentModel.cyl_setIconAnimationAttributes(attributes, state)` |
| `CYLRefreshComponent(CYLRefreshIconLayout)` `-cyl_placeIconViewAtCenter:visible:replacingViews:` | `CYLRefreshComponentModel.cyl_placeIconViewAtCenter(center, visible, views)` |
| `CYLRefreshComponent(CYLRefreshIconLayout)` `-cyl_updateIconViewVisible:replacingViews:` | `CYLRefreshComponentModel.cyl_updateIconViewVisible(visible, views)` |
| `CYLRefreshComponent(CYLRefreshIconLayout)` `-cyl_placeIconViewWithTitle:labels:visible:replacingViews:` | `CYLRefreshComponentModel.cyl_placeIconViewWithTitle(title, labels, visible, views)` |
| `CYLRefreshComponent(CYLRefreshIconLayout)` `-cyl_setIconImages:duration:forState:` | `CYLRefreshComponentModel.cyl_setIconImages(images, duration, state)` |
| `CYLRefreshComponent(CYLRefreshIconLayout)` `-cyl_showIconImageFrameOf:pullingPercent:` | `CYLRefreshComponentModel.cyl_showIconImageFrameOf(images, pullingPercent)` |

#### `CYLRefresh/Base/CYLRefreshPaging.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshPagingCompletion` | `CYLRefreshPagingCompletion` |
| `CYLRefreshPagingLoader` | `CYLRefreshPagingLoader` |
| `CYLRefreshPaging` | `CYLRefreshPaging` |
| `CYLRefreshPaging` `-initWithHeader:footer:loader:` | `new CYLRefreshPaging(header, footer, loader)` |
| `CYLRefreshPaging` `-init` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLRefreshPaging` `header` | `CYLRefreshPaging.header` |
| `CYLRefreshPaging` `footer` | `CYLRefreshPaging.footer` |
| `CYLRefreshPaging` `firstPage` | `CYLRefreshPaging.firstPage` |
| `CYLRefreshPaging` `items` | `CYLRefreshPaging.items` |
| `CYLRefreshPaging` `count` | `CYLRefreshPaging.count` |
| `CYLRefreshPaging` `page` | `CYLRefreshPaging.page` |
| `CYLRefreshPaging` `total` | `CYLRefreshPaging.total` |
| `CYLRefreshPaging` `totalPage` | `CYLRefreshPaging.totalPage` |
| `CYLRefreshPaging` `isEmpty` | `CYLRefreshPaging.isEmpty` |
| `CYLRefreshPaging` `isNoMore` | `CYLRefreshPaging.isNoMore` |
| `CYLRefreshPaging` `resetsFooterAfterRefresh` | `CYLRefreshPaging.resetsFooterAfterRefresh` |
| `CYLRefreshPaging` `itemsDidChange` | `CYLRefreshPaging.itemsDidChange` |
| `CYLRefreshPaging` `-start` | `CYLRefreshPaging.start()` |
| `CYLRefreshPaging` `-refresh` | `CYLRefreshPaging.refresh()` |
| `CYLRefreshPaging` `-loadMore` | `CYLRefreshPaging.loadMore()` |

#### `CYLRefresh/Base/CYLRefreshTrailer.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshTrailer` | `CYLRefreshTrailerModel` |
| `CYLRefreshTrailer` `+trailerWithRefreshingBlock:` | `CYLRefreshTrailerModel.trailerWithRefreshingBlock(block)` |
| `CYLRefreshTrailer` `+trailerWithRefreshingTarget:refreshingAction:` | `CYLRefreshTrailerModel.trailerWithRefreshingTarget(target, action)` |
| `CYLRefreshTrailer` `ignoredScrollViewContentInsetRight` | `CYLRefreshTrailerModel.ignoredScrollViewContentInsetRight` |
| `CYLRefreshTrailer` `automaticallyRefresh` | `CYLRefreshTrailerModel.automaticallyRefresh` |
| `CYLRefreshTrailer` `triggerAutomaticallyRefreshPercent` | `CYLRefreshTrailerModel.triggerAutomaticallyRefreshPercent` |
| `CYLRefreshTrailer` `autoTriggerTimes` | `CYLRefreshTrailerModel.autoTriggerTimes` |

#### `CYLRefresh/CYLRefreshConfig.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshConfig` | `CYLRefreshConfig` |
| `CYLRefreshConfig` `languageCode` | `CYLRefreshConfig.defaultConfig.languageCode` |
| `CYLRefreshConfig` `i18nFilename` | `CYLRefreshConfig.defaultConfig.i18nFilename` |
| `CYLRefreshConfig` `i18nBundle` | `CYLRefreshConfig.defaultConfig.i18nBundle` |
| `CYLRefreshConfig` `defaultConfig` | `CYLRefreshConfig.defaultConfig` |
| `CYLRefreshConfig` `-init` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLRefreshConfig` `+new` | n/a (NS_UNAVAILABLE on iOS) |

#### `CYLRefresh/CYLRefreshConst.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshLabelLeftInset` | `CYLRefreshLabelLeftInset` |
| `CYLRefreshHeaderHeight` | `CYLRefreshHeaderHeight` |
| `CYLRefreshFooterHeight` | `CYLRefreshFooterHeight` |
| `CYLRefreshTrailWidth` | `CYLRefreshTrailWidth` |
| `CYLRefreshFastAnimationDuration` | `CYLRefreshFastAnimationDuration` |
| `CYLRefreshSlowAnimationDuration` | `CYLRefreshSlowAnimationDuration` |
| `CYLRefreshKeyPathContentOffset` | `CYLRefreshKeyPathContentOffset` |
| `CYLRefreshKeyPathContentSize` | `CYLRefreshKeyPathContentSize` |
| `CYLRefreshKeyPathContentInset` | `CYLRefreshKeyPathContentInset` |
| `CYLRefreshKeyPathPanState` | `CYLRefreshKeyPathPanState` |
| `CYLRefreshHeaderLastUpdatedTimeKey` | `CYLRefreshHeaderLastUpdatedTimeKey` |
| `CYLRefreshHeaderIdleText` | `CYLRefreshHeaderIdleText` |
| `CYLRefreshHeaderPullingText` | `CYLRefreshHeaderPullingText` |
| `CYLRefreshHeaderRefreshingText` | `CYLRefreshHeaderRefreshingText` |
| `CYLRefreshTrailerIdleText` | `CYLRefreshTrailerIdleText` |
| `CYLRefreshTrailerPullingText` | `CYLRefreshTrailerPullingText` |
| `CYLRefreshAutoFooterIdleText` | `CYLRefreshAutoFooterIdleText` |
| `CYLRefreshAutoFooterRefreshingText` | `CYLRefreshAutoFooterRefreshingText` |
| `CYLRefreshAutoFooterNoMoreDataText` | `CYLRefreshAutoFooterNoMoreDataText` |
| `CYLRefreshBackFooterIdleText` | `CYLRefreshBackFooterIdleText` |
| `CYLRefreshBackFooterPullingText` | `CYLRefreshBackFooterPullingText` |
| `CYLRefreshBackFooterRefreshingText` | `CYLRefreshBackFooterRefreshingText` |
| `CYLRefreshBackFooterNoMoreDataText` | `CYLRefreshBackFooterNoMoreDataText` |
| `CYLRefreshHeaderFinishedText` | `CYLRefreshHeaderFinishedText` |
| `CYLRefreshHeaderFailedText` | `CYLRefreshHeaderFailedText` |
| `CYLRefreshFooterFinishedText` | `CYLRefreshFooterFinishedText` |
| `CYLRefreshFooterFailedText` | `CYLRefreshFooterFailedText` |
| `CYLRefreshHeaderLastTimeText` | `CYLRefreshHeaderLastTimeText` |
| `CYLRefreshHeaderDateTodayText` | `CYLRefreshHeaderDateTodayText` |
| `CYLRefreshHeaderNoneLastDateText` | `CYLRefreshHeaderNoneLastDateText` |
| `CYLRefreshDidChangeLanguageNotification` | `CYLRefreshDidChangeLanguageNotification` |

#### `CYLRefresh/Custom/Cupertino/CYLRefreshCupertinoFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshCupertinoFooter` | `CYLRefreshCupertinoFooterModel` |
| `CYLRefreshCupertinoFooter` `activityIndicator` | `CYLRefreshCupertinoFooterModel.activityIndicator` |

#### `CYLRefresh/Custom/Cupertino/CYLRefreshCupertinoHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshCupertinoHeader` | `CYLRefreshCupertinoHeaderModel` |
| `CYLRefreshCupertinoHeader` `activityIndicator` | `CYLRefreshCupertinoHeaderModel.activityIndicator` |

#### `CYLRefresh/Custom/Drawn/CYLRefreshBezierCircleHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshBezierCircleHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshBezierRadarHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshBezierRadarHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshDeliveryHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshDeliveryHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshDrawnFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshDrawnFooter` | TODO |
| `CYLRefreshDrawnFooter` `styleClass` | TODO |
| `CYLRefreshDrawnFooter` `-initWithStyle:` | TODO |
| `CYLRefreshDrawnFooter` `style` | TODO |
| `CYLRefreshBezierRadarFooter` | TODO |
| `CYLRefreshMaterialFooter` | TODO |
| `CYLRefreshDeliveryFooter` | TODO |
| `CYLRefreshPhoenixFooter` | TODO |
| `CYLRefreshTaurusFooter` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshDrawnHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshDrawnHeader` | TODO |
| `CYLRefreshDrawnHeader` `width` | TODO |
| `CYLRefreshDrawnHeader` `height` | TODO |
| `CYLRefreshDrawnHeader` `durationFast` | TODO |
| `CYLRefreshDrawnHeader` `durationNormal` | TODO |
| `CYLRefreshDrawnHeader` `status` | TODO |
| `CYLRefreshDrawnHeader` `dragOffset` | TODO |
| `CYLRefreshDrawnHeader` `dragPercent` | TODO |
| `CYLRefreshDrawnHeader` `isSuccess` | TODO |
| `CYLRefreshDrawnHeader` `-setUpComponent` | TODO |
| `CYLRefreshDrawnHeader` `-onStatus:changed:` | TODO |
| `CYLRefreshDrawnHeader` `-scrollView:didScroll:percent:drag:` | TODO |
| `CYLRefreshDrawnHeader` `-onScrollingWithOffset:percent:drag:` | TODO |
| `CYLRefreshDrawnHeader` `-onStartAnimationWhenRealeasing` | TODO |
| `CYLRefreshDrawnHeader` `-onStartAnimationWhenRefreshing` | TODO |
| `CYLRefreshDrawnHeader` `-onRefreshFinished:` | TODO |
| `CYLRefreshDrawnHeader` `-onRefreshFinishing:` | TODO |
| `CYLRefreshDrawnHeader` `-scrollView:attached:` | TODO |
| `CYLRefreshDrawnHeader` `-beginRefresh` | TODO |
| `CYLRefreshDrawnHeader` `-finishRefresh` | TODO |
| `CYLRefreshDrawnHeader` `-finishRefreshWithSuccess:` | TODO |
| `CYLRefreshDrawnHeader` `-inStatus:` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshDropBoxHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshDropBoxHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshFlyHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshFlyHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshGameBattleCityHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshGameBattleCityHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshGameHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshGameHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshGameHitBlockHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshGameHitBlockHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshMaterialHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshMaterialHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshOriginalHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshOriginalHeader` | TODO |
| `CYLRefreshOriginalHeader` `enableAutoRefresh` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshPhoenixHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshPhoenixHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshStoreHouseHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshStoreHouseHeader` | TODO |
| `CYLRefreshStoreHouseHeader` `lineWidth` | TODO |
| `CYLRefreshStoreHouseHeader` `enableReverseFlash` | TODO |
| `CYLRefreshStoreHouseHeader` `enableFadeAnimation` | TODO |
| `CYLRefreshStoreHouseHeader` `+newWithString:` | TODO |
| `CYLRefreshStoreHouseHeader` `+newWithString:scale:` | TODO |
| `CYLRefreshStoreHouseHeader` `+newWithString:scale:padding:` | TODO |
| `CYLRefreshStoreHouseHeader` `-initLinesWithString:` | TODO |
| `CYLRefreshStoreHouseHeader` `-initLinesWithString:scale:` | TODO |
| `CYLRefreshStoreHouseHeader` `-initLinesWithString:scale:padding:` | TODO |
| `CYLRefreshStoreHouseHeader` `-initLinesWithArray:` | TODO |
| `CYLRefreshStoreHouseHeader` `-initLinesWithArray:padding:` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshTaurusHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshTaurusHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/CYLRefreshWaveSwipeHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshWaveSwipeHeader` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshFlyView.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshFlyView` | TODO |
| `CYLRefreshFlyView` `colorAccent` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshGamePlayingScene.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshGamePlayingScene` | TODO |
| `CYLRefreshGamePlayingScene` `title` | TODO |
| `CYLRefreshGamePlayingScene` `colorAccent` | TODO |
| `CYLRefreshGamePlayingScene` `colorPrimary` | TODO |
| `CYLRefreshGamePlayingScene` `-reset` | TODO |
| `CYLRefreshGamePlayingScene` `-start` | TODO |
| `CYLRefreshGamePlayingScene` `-gameWin` | TODO |
| `CYLRefreshGamePlayingScene` `-gameOver` | TODO |
| `CYLRefreshGamePlayingScene` `-moveHandle:` | TODO |
| `CYLRefreshGamePlayingScene` `-finishWithSuccess:` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshGameStartScene.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshGameStartScene` | TODO |
| `CYLRefreshGameStartScene` `colorAccent` | TODO |
| `CYLRefreshGameStartScene` `colorPrimary` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshMountainView.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshMountainView` | TODO |
| `CYLRefreshMountainView` `colorAccent` | TODO |
| `CYLRefreshMountainView` `colorPrimary` | TODO |
| `CYLRefreshMountainView` `-onScrollingWithOffset:percent:` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshStoreHouseLine.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshStoreHouseLine` | TODO |
| `CYLRefreshStoreHouseLine` `start` | TODO |
| `CYLRefreshStoreHouseLine` `end` | TODO |
| `CYLRefreshStoreHouseLine` `middle` | TODO |
| `CYLRefreshStoreHouseLine` `alpha` | TODO |
| `CYLRefreshStoreHouseLine` `offset` | TODO |
| `CYLRefreshStoreHouseLine` `index` | TODO |
| `CYLRefreshStoreHouseLine` `transform` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshStoreHousePath.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshStoreHousePath` | TODO |
| `CYLRefreshStoreHousePath` `+linesFromArray:` | TODO |
| `CYLRefreshStoreHousePath` `+linesFrom:scale:space:` | TODO |
| `CYLRefreshStoreHousePath` `+arrayAkta` | TODO |
| `CYLRefreshStoreHousePath` `+arrayStoreHouse` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshValueAnimator.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshAnimatorInterpolator` | TODO |
| `CYLRefreshAnimatorRepeatMode` | TODO |
| `CYLRefreshValueAnimatorDelegate` | TODO |
| `CYLRefreshValueAnimatorDelegate` `-onAnimationStart:` | TODO |
| `CYLRefreshValueAnimatorDelegate` `-onAnimationRepeat:` | TODO |
| `CYLRefreshValueAnimatorDelegate` `-onAnimationEnd:` | TODO |
| `CYLRefreshAnimatorInterpolatorBlock` | TODO |
| `CYLRefreshValueAnimator` | TODO |
| `CYLRefreshValueAnimator` `+newWithFrom:to:` | TODO |
| `CYLRefreshValueAnimator` `+newWithTarget:selector:` | TODO |
| `CYLRefreshValueAnimator` `-setTarget:selector:` | TODO |
| `CYLRefreshValueAnimator` `-setFrom:to:` | TODO |
| `CYLRefreshValueAnimator` `-setFromToPoints:` | TODO |
| `CYLRefreshValueAnimator` `fromValue` | TODO |
| `CYLRefreshValueAnimator` `toValue` | TODO |
| `CYLRefreshValueAnimator` `speed` | TODO |
| `CYLRefreshValueAnimator` `repeatCount` | TODO |
| `CYLRefreshValueAnimator` `beginTime` | TODO |
| `CYLRefreshValueAnimator` `duration` | TODO |
| `CYLRefreshValueAnimator` `repeatMode` | TODO |
| `CYLRefreshValueAnimator` `interpolator` | TODO |
| `CYLRefreshValueAnimator` `delegate` | TODO |
| `CYLRefreshValueAnimator` `interpolatorBlock` | TODO |
| `CYLRefreshValueAnimator` `isRunning` | TODO |
| `CYLRefreshValueAnimator` `value` | TODO |
| `CYLRefreshValueAnimator` `percent` | TODO |
| `CYLRefreshValueAnimator` `-start` | TODO |
| `CYLRefreshValueAnimator` `-stop` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshVectorElement.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshVectorElement` | TODO |
| `CYLRefreshVectorElement` `identifier` | TODO |
| `CYLRefreshVectorElement` `stroke` | TODO |
| `CYLRefreshVectorElement` `fill` | TODO |
| `CYLRefreshVectorElement` `opacity` | TODO |
| `CYLRefreshVectorElement` `strokeWidth` | TODO |
| `CYLRefreshVectorElement` `strokeOpacity` | TODO |
| `CYLRefreshVectorElement` `viewport` | TODO |
| `CYLRefreshVectorElement` `changed` | TODO |
| `CYLRefreshVectorElement` `layer` | TODO |
| `CYLRefreshVectorElement` `-newLayer` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshVectorImage.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshVectorImage` | TODO |
| `CYLRefreshVectorImage` `elements` | TODO |
| `CYLRefreshVectorImage` `size` | TODO |
| `CYLRefreshVectorImage` `frame` | TODO |
| `CYLRefreshVectorImage` `viewport` | TODO |
| `CYLRefreshVectorImage` `opacity` | TODO |
| `CYLRefreshVectorImage` `-addElement:` | TODO |
| `CYLRefreshVectorImage` `-parserPaths:` | TODO |
| `CYLRefreshVectorImage` `-parserColors:` | TODO |
| `CYLRefreshVectorImage` `-scaleToFitInside:` | TODO |
| `CYLRefreshVectorImage` `-renderInContext:` | TODO |
| `CYLRefreshVectorImage` `-setGeometricWidth:` | TODO |
| `CYLRefreshVectorImage` `-setGeometricHeight:` | TODO |
| `CYLRefreshVectorImage` `-moveTo:` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshVectorPathElement.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshVectorPathElement` | TODO |
| `CYLRefreshVectorPathElement` `+newWith:` | TODO |
| `CYLRefreshVectorPathElement` `pathForShape` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshVectorPathsParser.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshCurveType` | TODO |
| `CYLRefreshVectorPathsParser` | TODO |
| `CYLRefreshVectorPathsParser` `+startingCurve` | TODO |
| `CYLRefreshVectorPathsParser` `+readMovetoDrawToCmdGroups:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readMovetoDrawto:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readMoveto:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readMovetoArgumentSequence:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readLineToCmd:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readLinetoArgumentSequence:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readVerticalLineToCmd:path:relativeTo:` | TODO |
| `CYLRefreshVectorPathsParser` `+readVerticalLinetoArgumentSequence:path:relativeTo:` | TODO |
| `CYLRefreshVectorPathsParser` `+readHorizontalLinetoArgumentSequence:path:relativeTo:` | TODO |
| `CYLRefreshVectorPathsParser` `+readHorizontalLineToCmd:path:relativeTo:` | TODO |
| `CYLRefreshVectorPathsParser` `+readQuadraticCurveToCmd:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readQuadraticCurvetoArgumentSequence:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readQuadraticCurvetoArgument:path:relativeTo:` | TODO |
| `CYLRefreshVectorPathsParser` `+readSmoothQuadraticCurveToCmd:path:relativeTo:withPrevCurve:` | TODO |
| `CYLRefreshVectorPathsParser` `+readSmoothQuadraticCurvetoArgumentSequence:path:relativeTo:withPrevCurve:` | TODO |
| `CYLRefreshVectorPathsParser` `+readSmoothQuadraticCurvetoArgument:path:relativeTo:withPrevCurve:` | TODO |
| `CYLRefreshVectorPathsParser` `+readCurveToCmd:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readCurvetoArgumentSequence:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readCurvetoArgument:path:relativeTo:` | TODO |
| `CYLRefreshVectorPathsParser` `+readSmoothCurveToCmd:path:relativeTo:withPrevCurve:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readSmoothCurvetoArgumentSequence:path:relativeTo:withPrevCurve:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readSmoothCurvetoArgument:path:relativeTo:withPrevCurve:` | TODO |
| `CYLRefreshVectorPathsParser` `+readEllipticalArcArguments:path:relativeTo:isRelative:` | TODO |
| `CYLRefreshVectorPathsParser` `+readCloseCommand:path:relativeTo:` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshVectorUtilities.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshVectorUtilities` | TODO |
| `CYLRefreshVectorUtilities` `+newLayerForElement:withPath:` | TODO |

#### `CYLRefresh/Custom/Drawn/Support/CYLRefreshVectorView.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshVectorView` | TODO |
| `CYLRefreshVectorView` `image` | TODO |
| `CYLRefreshVectorView` `-parserPaths:` | TODO |
| `CYLRefreshVectorView` `-parserColors:` | TODO |

#### `CYLRefresh/Custom/Footer/Auto/CYLRefreshAutoAnimationFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshAutoAnimationFooter` | `CYLRefreshAutoAnimationFooterModel` |
| `CYLRefreshAutoAnimationFooter` `animationView` | `CYLRefreshAutoAnimationFooterModel.animationView` |
| `CYLRefreshAutoAnimationFooter` `-setAnimationImages:duration:forState:` | `CYLRefreshAutoAnimationFooterModel.setAnimationImages(images, duration, state)` |
| `CYLRefreshAutoAnimationFooter` `-setAnimationImages:forState:` | `CYLRefreshAutoAnimationFooterModel.setAnimationImagesForState(images, state)` |

#### `CYLRefresh/Custom/Footer/Auto/CYLRefreshAutoGifFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshAutoGifFooter` | `CYLRefreshAutoGifFooterModel` |
| `CYLRefreshAutoGifFooter` `gifView` | `CYLRefreshAutoGifFooterModel.gifView` |
| `CYLRefreshAutoGifFooter` `-setImages:duration:forState:` | `CYLRefreshAutoGifFooterModel.setImages(images, duration, state)` |
| `CYLRefreshAutoGifFooter` `-setImages:forState:` | `CYLRefreshAutoGifFooterModel.setImagesForState(images, state)` |

#### `CYLRefresh/Custom/Footer/Auto/CYLRefreshAutoNormalFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshAutoNormalFooter` | `CYLRefreshAutoNormalFooterModel` |
| `CYLRefreshAutoNormalFooter` `loadingView` | `CYLRefreshAutoNormalFooterModel.loadingView` |
| `CYLRefreshAutoNormalFooter` `noMoreDataImage` | `CYLRefreshAutoNormalFooterModel.noMoreDataImage` |
| `CYLRefreshAutoNormalFooter` `CYLRefreshDeprecated` | `CYLRefreshAutoNormalFooterModel.activityIndicatorViewStyle` |

#### `CYLRefresh/Custom/Footer/Auto/CYLRefreshAutoStateFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshAutoStateFooter` | `CYLRefreshAutoStateFooterModel` |
| `CYLRefreshAutoStateFooter` `labelLeftInset` | `CYLRefreshAutoStateFooterModel.labelLeftInset` |
| `CYLRefreshAutoStateFooter` `stateLabel` | `CYLRefreshAutoStateFooterModel.stateLabel` |
| `CYLRefreshAutoStateFooter` `-setTitle:forState:` | `CYLRefreshAutoStateFooterModel.setTitle(title, state)` |
| `CYLRefreshAutoStateFooter` `refreshingTitleHidden` | `CYLRefreshAutoStateFooterModel.refreshingTitleHidden` |

#### `CYLRefresh/Custom/Footer/Back/CYLRefreshBackAnimationFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshBackAnimationFooter` | `CYLRefreshBackAnimationFooterModel` |
| `CYLRefreshBackAnimationFooter` `animationView` | `CYLRefreshBackAnimationFooterModel.animationView` |
| `CYLRefreshBackAnimationFooter` `-setAnimationImages:duration:forState:` | `CYLRefreshBackAnimationFooterModel.setAnimationImages(images, duration, state)` |
| `CYLRefreshBackAnimationFooter` `-setAnimationImages:forState:` | `CYLRefreshBackAnimationFooterModel.setAnimationImagesForState(images, state)` |

#### `CYLRefresh/Custom/Footer/Back/CYLRefreshBackGifFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshBackGifFooter` | `CYLRefreshBackGifFooterModel` |
| `CYLRefreshBackGifFooter` `gifView` | `CYLRefreshBackGifFooterModel.gifView` |
| `CYLRefreshBackGifFooter` `-setImages:duration:forState:` | `CYLRefreshBackGifFooterModel.setImages(images, duration, state)` |
| `CYLRefreshBackGifFooter` `-setImages:forState:` | `CYLRefreshBackGifFooterModel.setImagesForState(images, state)` |

#### `CYLRefresh/Custom/Footer/Back/CYLRefreshBackNormalFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshBackNormalFooter` | `CYLRefreshBackNormalFooterModel` |
| `CYLRefreshBackNormalFooter` `arrowView` | `CYLRefreshBackNormalFooterModel.arrowView` |
| `CYLRefreshBackNormalFooter` `loadingView` | `CYLRefreshBackNormalFooterModel.loadingView` |
| `CYLRefreshBackNormalFooter` `noMoreDataImage` | `CYLRefreshBackNormalFooterModel.noMoreDataImage` |
| `CYLRefreshBackNormalFooter` `iconSize` | `CYLRefreshBackNormalFooterModel.iconSize` |
| `CYLRefreshBackNormalFooter` `CYLRefreshDeprecated` | `CYLRefreshBackNormalFooterModel.activityIndicatorViewStyle` |

#### `CYLRefresh/Custom/Footer/Back/CYLRefreshBackStateFooter.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshBackStateFooter` | `CYLRefreshBackStateFooterModel` |
| `CYLRefreshBackStateFooter` `labelLeftInset` | `CYLRefreshBackStateFooterModel.labelLeftInset` |
| `CYLRefreshBackStateFooter` `stateLabel` | `CYLRefreshBackStateFooterModel.stateLabel` |
| `CYLRefreshBackStateFooter` `-setTitle:forState:` | `CYLRefreshBackStateFooterModel.setTitle(title, state)` |
| `CYLRefreshBackStateFooter` `-titleForState:` | `CYLRefreshBackStateFooterModel.titleForState(state)` |

#### `CYLRefresh/Custom/Header/CYLRefreshAnimationHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshAnimationHeader` | `CYLRefreshAnimationHeaderModel` |
| `CYLRefreshAnimationHeader` `animationView` | `CYLRefreshAnimationHeaderModel.animationView` |
| `CYLRefreshAnimationHeader` `-setAnimationImages:duration:forState:` | `CYLRefreshAnimationHeaderModel.setAnimationImages(images, duration, state)` |
| `CYLRefreshAnimationHeader` `-setAnimationImages:forState:` | `CYLRefreshAnimationHeaderModel.setAnimationImagesForState(images, state)` |

#### `CYLRefresh/Custom/Header/CYLRefreshGifHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshGifHeader` | `CYLRefreshGifHeaderModel` |
| `CYLRefreshGifHeader` `gifView` | `CYLRefreshGifHeaderModel.gifView` |
| `CYLRefreshGifHeader` `-setImages:duration:forState:` | `CYLRefreshGifHeaderModel.setImages(images, duration, state)` |
| `CYLRefreshGifHeader` `-setImages:forState:` | `CYLRefreshGifHeaderModel.setImagesForState(images, state)` |

#### `CYLRefresh/Custom/Header/CYLRefreshNormalHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshNormalHeader` | `CYLRefreshNormalHeaderModel` |
| `CYLRefreshNormalHeader` `arrowView` | `CYLRefreshNormalHeaderModel.arrowView` |
| `CYLRefreshNormalHeader` `iconSize` | `CYLRefreshNormalHeaderModel.iconSize` |
| `CYLRefreshNormalHeader` `loadingView` | `CYLRefreshNormalHeaderModel.loadingView` |
| `CYLRefreshNormalHeader` `CYLRefreshDeprecated` | `CYLRefreshNormalHeaderModel.activityIndicatorViewStyle` |

#### `CYLRefresh/Custom/Header/CYLRefreshStateHeader.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshStateHeader` | `CYLRefreshStateHeaderModel` |
| `CYLRefreshStateHeader` `lastUpdatedTimeText` | `CYLRefreshStateHeaderModel.lastUpdatedTimeText` |
| `CYLRefreshStateHeader` `lastUpdatedTimeLabel` | `CYLRefreshStateHeaderModel.lastUpdatedTimeLabel` |
| `CYLRefreshStateHeader` `labelLeftInset` | `CYLRefreshStateHeaderModel.labelLeftInset` |
| `CYLRefreshStateHeader` `stateLabel` | `CYLRefreshStateHeaderModel.stateLabel` |
| `CYLRefreshStateHeader` `-setTitle:forState:` | `CYLRefreshStateHeaderModel.setTitle(title, state)` |
| `CYLRefreshStateHeader` `lastUpdatedTimeFormatter` | `CYLRefreshStateHeaderModel.lastUpdatedTimeFormatter` |
| `CYLRefreshStateHeader` `lastUpdatedTimeString` | `CYLRefreshStateHeaderModel.lastUpdatedTimeString` |
| `CYLRefreshStateHeader` `titleTimeSpacing` | `CYLRefreshStateHeaderModel.titleTimeSpacing` |
| `CYLRefreshStateHeader` `succeededImage` | `CYLRefreshStateHeaderModel.succeededImage` |
| `CYLRefreshStateHeader` `failedImage` | `CYLRefreshStateHeaderModel.failedImage` |
| `CYLRefreshStateHeader` `iconOnTrailingSide` | `CYLRefreshStateHeaderModel.iconOnTrailingSide` |
| `CYLRefreshStateHeader(ChainingGrammar)` | `CYLRefreshStateHeaderModel` |
| `CYLRefreshStateHeader(ChainingGrammar)` `-cyl_modifyLastUpdatedTimeText:` | `CYLRefreshStateHeaderModel.cyl_modifyLastUpdatedTimeText(handler)` |

#### `CYLRefresh/Custom/Trailer/CYLRefreshNormalTrailer.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshNormalTrailer` | `CYLRefreshNormalTrailerModel` |
| `CYLRefreshNormalTrailer` `arrowView` | `CYLRefreshNormalTrailerModel.arrowView` |

#### `CYLRefresh/Custom/Trailer/CYLRefreshStateTrailer.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLRefreshStateTrailer` | `CYLRefreshStateTrailerModel` |
| `CYLRefreshStateTrailer` `stateLabel` | `CYLRefreshStateTrailerModel.stateLabel` |
| `CYLRefreshStateTrailer` `-setTitle:forState:` | `CYLRefreshStateTrailerModel.setTitle(title, state)` |
| `CYLRefreshStateTrailer` `-cyl_placeStateLabelAtCenterX:` | `CYLRefreshStateTrailerModel.cyl_placeStateLabelAtCenterX(centerX)` |

#### `CYLRefresh/NSBundle+CYLRefresh.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `NSBundle(CYLRefresh)` | `CYLRefreshBundle` |
| `NSBundle(CYLRefresh)` `+cyl_refreshBundle` | `CYLRefreshBundle.cyl_refreshBundle()` |
| `NSBundle(CYLRefresh)` `+cyl_arrowImage` | `CYLRefreshBundle.cyl_arrowImage()` |
| `NSBundle(CYLRefresh)` `+cyl_trailArrowImage` | `CYLRefreshBundle.cyl_trailArrowImage()` |
| `NSBundle(CYLRefresh)` `+cyl_localizedStringForKey:value:` | `CYLRefreshBundle.cyl_localizedStringForKeyValue(key, value)` |
| `NSBundle(CYLRefresh)` `+cyl_localizedStringForKey:` | `CYLRefreshBundle.cyl_localizedStringForKey(key)` |

#### `CYLRefresh/UICollectionViewLayout+CYLRefresh.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `UICollectionViewLayout(CYLRefresh)` | TODO |

#### `CYLRefresh/UIScrollView+CYLExtension.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLScrollDirection` | `CYLScrollDirection` |
| `UIScrollView(CYLExtension)` | `CYLRefreshScrollViewModel` |
| `UIScrollView(CYLExtension)` `cyl_inset` | `CYLRefreshScrollViewModel.cyl_inset` |
| `UIScrollView(CYLExtension)` `cyl_insetT` | `CYLRefreshScrollViewModel.cyl_insetT` |
| `UIScrollView(CYLExtension)` `cyl_insetB` | `CYLRefreshScrollViewModel.cyl_insetB` |
| `UIScrollView(CYLExtension)` `cyl_insetL` | `CYLRefreshScrollViewModel.cyl_insetL` |
| `UIScrollView(CYLExtension)` `cyl_insetR` | `CYLRefreshScrollViewModel.cyl_insetR` |
| `UIScrollView(CYLExtension)` `cyl_offsetX` | `CYLRefreshScrollViewModel.cyl_offsetX` |
| `UIScrollView(CYLExtension)` `cyl_offsetY` | `CYLRefreshScrollViewModel.cyl_offsetY` |
| `UIScrollView(CYLExtension)` `cyl_contentW` | `CYLRefreshScrollViewModel.cyl_contentW` |
| `UIScrollView(CYLExtension)` `cyl_contentH` | `CYLRefreshScrollViewModel.cyl_contentH` |
| `UIScrollView(CYLExtension)` `-cyl_updateScrollMetrics` | `CYLRefreshScrollViewModel.cyl_updateScrollMetrics()` |
| `UIScrollView(CYLExtension)` `cyl_scrollDistance` | `CYLRefreshScrollViewModel.cyl_scrollDistance` |
| `UIScrollView(CYLExtension)` `cyl_scrollDirection` | `CYLRefreshScrollViewModel.cyl_scrollDirection` |

#### `CYLRefresh/UIScrollView+CYLRefresh.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `UIScrollView(CYLRefresh)` | `CYLRefreshScrollViewModel` + `CYLRefreshContainer` |
| `UIScrollView(CYLRefresh)` `cyl_header` | `CYLRefreshScrollViewModel.cyl_header` |
| `UIScrollView(CYLRefresh)` `cyl_footer` | `CYLRefreshScrollViewModel.cyl_footer` |
| `UIScrollView(CYLRefresh)` `cyl_trailer` | `CYLRefreshScrollViewModel.cyl_trailer` |
| `UIScrollView(CYLRefresh)` `cyl_autoHideRefresh` | `CYLRefreshScrollViewModel.cyl_autoHideRefresh` |
| `UIScrollView(CYLRefresh)` `cyl_autoHideRefreshHeader` | `CYLRefreshScrollViewModel.cyl_autoHideRefreshHeader` |
| `UIScrollView(CYLRefresh)` `cyl_autoHideRefreshFooter` | `CYLRefreshScrollViewModel.cyl_autoHideRefreshFooter` |
| `UIScrollView(CYLRefresh)` `-cyl_beginRefreshingWithStartHeader:` | `CYLRefreshScrollViewModel.cyl_beginRefreshingWithStartHeader(startHeader)` |
| `UIScrollView(CYLRefresh)` `-cyl_totalDataCount` | `CYLRefreshScrollViewModel.cyl_totalDataCount()` |

#### `CYLRefresh/UIView+CYLExtension.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `UIView(CYLExtension)` | `CYLRefreshViewModel` |
| `UIView(CYLExtension)` `cyl_x` | `CYLRefreshViewModel.cyl_x` |
| `UIView(CYLExtension)` `cyl_y` | `CYLRefreshViewModel.cyl_y` |
| `UIView(CYLExtension)` `cyl_w` | `CYLRefreshViewModel.cyl_w` |
| `UIView(CYLExtension)` `cyl_h` | `CYLRefreshViewModel.cyl_h` |
| `UIView(CYLExtension)` `cyl_size` | `CYLRefreshViewModel.cyl_size` |
| `UIView(CYLExtension)` `cyl_origin` | `CYLRefreshViewModel.cyl_origin` |

#### `CYLTableViewPlaceHolder/CYLPlaceholderHUD.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderHUDStyle` | `CYLPlaceholderHUDStyle` (enum) |
| `CYLPlaceholderHUDMaskType` | `CYLPlaceholderHUDMaskType` (enum) |
| `CYLPlaceholderHUDState` | `CYLPlaceholderHUDState` (enum) |
| `CYLPlaceholderHUDDismissCompletion` | `CYLPlaceholderHUDDismissCompletion` (`() => void`) |
| `CYLPlaceholderHUD` | `CYLPlaceholderHUD` (`@Observed` state) + `CYLPlaceholderHUDView` drawn in a global overlay (`ComponentContent` on the `OverlayManager`) |
| `CYLPlaceholderHUD` `sharedHUD` | `CYLPlaceholderHUD.sharedHUD` (set its `containerView` to the page's `UIContext` once) |
| `CYLPlaceholderHUD` `-initWithContainerView:` | `CYLPlaceholderHUD.initWithContainerView(uiContext)` / `new CYLPlaceholderHUD(uiContext)` |
| `CYLPlaceholderHUD` `-init` | `CYLPlaceholderHUD.init()` |
| `CYLPlaceholderHUD` `-initWithFrame:` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderHUD` `-initWithCoder:` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderHUD` `contentView` | `CYLPlaceholderHUD.contentView` (`CYLPlaceholderViewModel`) |
| `CYLPlaceholderHUD` `placeholderView` | `CYLPlaceholderHUD.placeholderView` (`CYLPlaceholderStackViewModel`) |
| `CYLPlaceholderHUD` `hudView` | `CYLPlaceholderHUD.hudView` (the overlay `ComponentContent` while shown) |
| `CYLPlaceholderHUD` `actions` | `CYLPlaceholderHUD.actions` |
| `CYLPlaceholderHUD` `state` | `CYLPlaceholderHUD.state` |
| `CYLPlaceholderHUD` `status` | `CYLPlaceholderHUD.status` |
| `CYLPlaceholderHUD` `progress` | `CYLPlaceholderHUD.progress` |
| `CYLPlaceholderHUD` `visible` | `CYLPlaceholderHUD.visible` |
| `CYLPlaceholderHUD` `activityCount` | `CYLPlaceholderHUD.activityCount` |
| `CYLPlaceholderHUD` `containerView` | `CYLPlaceholderHUD.containerView` (a `UIContext`) |
| `CYLPlaceholderHUD` `style` | `CYLPlaceholderHUD.style` |
| `CYLPlaceholderHUD` `maskType` | `CYLPlaceholderHUD.maskType` |
| `CYLPlaceholderHUD` `foregroundColor` | `CYLPlaceholderHUD.foregroundColor` |
| `CYLPlaceholderHUD` `hudBackgroundColor` | `CYLPlaceholderHUD.hudBackgroundColor` |
| `CYLPlaceholderHUD` `backgroundLayerColor` | `CYLPlaceholderHUD.backgroundLayerColor` |
| `CYLPlaceholderHUD` `font` | `CYLPlaceholderHUD.font` (fp; null resets) |
| `CYLPlaceholderHUD` `cornerRadius` | `CYLPlaceholderHUD.cornerRadius` |
| `CYLPlaceholderHUD` `minimumSize` | `CYLPlaceholderHUD.minimumSize` (`CYLPlaceholderHUDSize`) |
| `CYLPlaceholderHUD` `animationSize` | `CYLPlaceholderHUD.animationSize` (`CYLPlaceholderHUDSize`) |
| `CYLPlaceholderHUD` `offsetFromCenter` | `CYLPlaceholderHUD.offsetFromCenter` (`CYLPlaceholderHUDOffset`) |
| `CYLPlaceholderHUD` `loadingAnimationFileName` | `CYLPlaceholderHUD.loadingAnimationFileName` ("CYLRefreshActivity.gif" by default, null resets) |
| `CYLPlaceholderHUD` `progressAnimationFileName` | `CYLPlaceholderHUD.progressAnimationFileName` (scrubbed; null loops the loading animation with a percentage title) |
| `CYLPlaceholderHUD` `successAnimationFileName` | `CYLPlaceholderHUD.successAnimationFileName` ("CYLRefreshDoneCircle.json" by default) |
| `CYLPlaceholderHUD` `successImage` | `CYLPlaceholderHUD.successImage` |
| `CYLPlaceholderHUD` `errorImage` | `CYLPlaceholderHUD.errorImage` |
| `CYLPlaceholderHUD` `infoImage` | `CYLPlaceholderHUD.infoImage` |
| `CYLPlaceholderHUD` `graceTimeInterval` | `CYLPlaceholderHUD.graceTimeInterval` |
| `CYLPlaceholderHUD` `minimumDismissTimeInterval` | `CYLPlaceholderHUD.minimumDismissTimeInterval` |
| `CYLPlaceholderHUD` `maximumDismissTimeInterval` | `CYLPlaceholderHUD.maximumDismissTimeInterval` |
| `CYLPlaceholderHUD` `fadeInAnimationDuration` | `CYLPlaceholderHUD.fadeInAnimationDuration` |
| `CYLPlaceholderHUD` `fadeOutAnimationDuration` | `CYLPlaceholderHUD.fadeOutAnimationDuration` |
| `CYLPlaceholderHUD` `hapticsEnabled` | `CYLPlaceholderHUD.hapticsEnabled` (vibrator) |
| `CYLPlaceholderHUD` `-show` | `hud.show()` |
| `CYLPlaceholderHUD` `-showWithStatus:` | `hud.showWithStatus(status)` |
| `CYLPlaceholderHUD` `-showProgress:` | `hud.showProgress(progress)` |
| `CYLPlaceholderHUD` `-showProgress:status:` | `hud.showProgressStatus(progress, status)` |
| `CYLPlaceholderHUD` `-setStatus:` | `hud.setStatus(status)` |
| `CYLPlaceholderHUD` `-showInfoWithStatus:` | `hud.showInfoWithStatus(status)` |
| `CYLPlaceholderHUD` `-showSuccessWithStatus:` | `hud.showSuccessWithStatus(status)` |
| `CYLPlaceholderHUD` `-showErrorWithStatus:` | `hud.showErrorWithStatus(status)` |
| `CYLPlaceholderHUD` `-showImage:status:` | `hud.showImageStatus(image, status)` |
| `CYLPlaceholderHUD` `-showComponents:actions:` | `hud.showComponentsActions(components, actions)` |
| `CYLPlaceholderHUD` `-showScenario:actions:` | `hud.showScenarioActions(scenario, actions)` |
| `CYLPlaceholderHUD` `-popActivity` | `hud.popActivity()` |
| `CYLPlaceholderHUD` `-dismiss` | `hud.dismiss()` |
| `CYLPlaceholderHUD` `-dismissWithCompletion:` | `hud.dismissWithCompletion(completion)` |
| `CYLPlaceholderHUD` `-dismissWithDelay:` | `hud.dismissWithDelay(delay)` |
| `CYLPlaceholderHUD` `-dismissWithDelay:completion:` | `hud.dismissWithDelayCompletion(delay, completion)` |
| `CYLPlaceholderHUD` `-displayDurationForString:` | `hud.displayDurationForString(string)` |
| `CYLPlaceholderHUD` `+show` | `CYLPlaceholderHUD.show()` (static) |
| `CYLPlaceholderHUD` `+showWithStatus:` | `CYLPlaceholderHUD.showWithStatus(status)` (static) |
| `CYLPlaceholderHUD` `+showProgress:` | `CYLPlaceholderHUD.showProgress(progress)` (static) |
| `CYLPlaceholderHUD` `+showProgress:status:` | `CYLPlaceholderHUD.showProgressStatus(progress, status)` (static) |
| `CYLPlaceholderHUD` `+setStatus:` | `CYLPlaceholderHUD.setStatus(status)` (static) |
| `CYLPlaceholderHUD` `+showInfoWithStatus:` | `CYLPlaceholderHUD.showInfoWithStatus(status)` (static) |
| `CYLPlaceholderHUD` `+showSuccessWithStatus:` | `CYLPlaceholderHUD.showSuccessWithStatus(status)` (static) |
| `CYLPlaceholderHUD` `+showErrorWithStatus:` | `CYLPlaceholderHUD.showErrorWithStatus(status)` (static) |
| `CYLPlaceholderHUD` `+showImage:status:` | `CYLPlaceholderHUD.showImageStatus(image, status)` (static) |
| `CYLPlaceholderHUD` `+popActivity` | `CYLPlaceholderHUD.popActivity()` (static) |
| `CYLPlaceholderHUD` `+dismiss` | `CYLPlaceholderHUD.dismiss()` (static) |
| `CYLPlaceholderHUD` `+dismissWithCompletion:` | `CYLPlaceholderHUD.dismissWithCompletion(completion)` (static) |
| `CYLPlaceholderHUD` `+dismissWithDelay:` | `CYLPlaceholderHUD.dismissWithDelay(delay)` (static) |
| `CYLPlaceholderHUD` `+dismissWithDelay:completion:` | `CYLPlaceholderHUD.dismissWithDelayCompletion(delay, completion)` (static) |
| `CYLPlaceholderHUD` `+isVisible` | `CYLPlaceholderHUD.isVisible()` |
| `CYLPlaceholderHUD` `+displayDurationForString:` | `CYLPlaceholderHUD.displayDurationForString(string)` (static) |

#### `CYLTableViewPlaceHolder/CYLPlaceholderLocalization.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderLocalization` | `CYLPlaceholderLocalization` (class with static members) |
| `CYLPlaceholderLocalization` `supportedLanguages` | `CYLPlaceholderLocalization.supportedLanguages` |
| `CYLPlaceholderLocalization` `language` | `CYLPlaceholderLocalization.language` (get / set, null follows the app language) |
| `CYLPlaceholderLocalization` `effectiveLanguage` | `CYLPlaceholderLocalization.effectiveLanguage` |
| `CYLPlaceholderLocalization` `+localizedStringForKey:fallback:` | `CYLPlaceholderLocalization.localizedStringForKey(key, fallback)` |
| `CYLPlaceholderLocalization` `-init` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderLocalization` `+new` | n/a (NS_UNAVAILABLE on iOS) |

#### `CYLTableViewPlaceHolder/CYLPlaceholderNetworkMonitor.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderNetworkStatus` | `CYLPlaceholderNetworkStatus` (enum, same raw values) |
| `CYLPlaceholderNetworkStatusBlock` | `CYLPlaceholderNetworkStatusBlock` |
| `CYLPlaceholderNetworkMonitor` | `CYLPlaceholderNetworkMonitor` (`@kit.NetworkKit` connection) |
| `CYLPlaceholderNetworkMonitor` `sharedMonitor` | `CYLPlaceholderNetworkMonitor.sharedMonitor` |
| `CYLPlaceholderNetworkMonitor` `networkStatus` | `CYLPlaceholderNetworkMonitor.networkStatus` |
| `CYLPlaceholderNetworkMonitor` `reachable` | `CYLPlaceholderNetworkMonitor.reachable` |
| `CYLPlaceholderNetworkMonitor` `constrained` | `CYLPlaceholderNetworkMonitor.constrained` (always false: HarmonyOS reports no Low Data Mode) |
| `CYLPlaceholderNetworkMonitor` `expensive` | `CYLPlaceholderNetworkMonitor.expensive` (metered or cellular) |
| `CYLPlaceholderNetworkMonitor` `monitoring` | `CYLPlaceholderNetworkMonitor.monitoring` |
| `CYLPlaceholderNetworkMonitor` `-startMonitoring` | `CYLPlaceholderNetworkMonitor.startMonitoring()` |
| `CYLPlaceholderNetworkMonitor` `-stopMonitoring` | `CYLPlaceholderNetworkMonitor.stopMonitoring()` |
| `CYLPlaceholderNetworkMonitor` `-setNetworkStatusChangeBlock:` | `CYLPlaceholderNetworkMonitor.setNetworkStatusChangeBlock(block)` |
| `CYLPlaceholderNetworkMonitor` `+nameForStatus:` | `CYLPlaceholderNetworkMonitor.nameForStatus(status)` |

#### `CYLTableViewPlaceHolder/CYLPlaceholderScenario.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderScenario` | `CYLPlaceholderScenario` (enum) |
| `CYLPlaceholderScenarioCategory` | `CYLPlaceholderScenarioCategory` (enum) |
| `CYLPlaceholderPermission` | `CYLPlaceholderPermission` (enum) |
| `CYLPlaceholderAction` | `CYLPlaceholderAction` (string type) + `CYLPlaceholderActions.Retry` etc. |
| `CYLPlaceholderButtonStyle` | `CYLPlaceholderButtonStyle` (enum) |
| `CYLPlaceholderComponent` | `CYLPlaceholderComponent` (class) |
| `CYLPlaceholderComponent` `attributes` | `CYLPlaceholderComponent.attributes` |
| `CYLPlaceholderComponent` `action` | `CYLPlaceholderComponent.action` |
| `CYLPlaceholderComponent` `imageBundle` | TODO |
| `CYLPlaceholderComponent` `spacingBefore` | `CYLPlaceholderComponent.spacingBefore` |
| `CYLPlaceholderComponent` `interactionEnabled` | `CYLPlaceholderComponent.interactionEnabled` |
| `CYLPlaceholderComponent` `tapHighlightStyle` | `CYLPlaceholderComponent.tapHighlightStyle` |
| `CYLPlaceholderComponent` `animationRepeatCount` | `CYLPlaceholderComponent.animationRepeatCount` (1; 0 for bundled animations and scenario icons) |
| `CYLPlaceholderComponent` `+componentWithAttributes:action:` | `CYLPlaceholderComponent.componentWithAttributes(attributes, action)` |
| `CYLPlaceholderComponent` `+componentWithBundledAnimation:fallbackStyle:title:size:action:` | `CYLPlaceholderComponent.componentWithBundledAnimation(fileName, fallbackStyle, title, size, action)` (played by the stack view, fallback icon until ready) |
| `CYLPlaceholderComponent` `+hintComponentWithText:` | `CYLPlaceholderComponent.hintComponentWithText(text)` |
| `CYLPlaceholderComponent` `+buttonComponentWithTitle:style:action:` | `CYLPlaceholderComponent.buttonComponentWithTitle(title, style, action)` |
| `CYLPlaceholderComponent` `+separatorComponentWithText:` | `CYLPlaceholderComponent.separatorComponentWithText(text)` |
| `CYLPlaceholderComponent` `+componentWithDictionary:error:` | `CYLPlaceholderComponent.componentWithDictionary(dictionary, onError)` |
| `CYLPlaceholderComponent` `-init` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderComponent` `+new` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderScenarioCatalog` | `CYLPlaceholderScenarioCatalog` (class with static members) |
| `CYLPlaceholderScenarioCatalog` `allScenarios` | `CYLPlaceholderScenarioCatalog.allScenarios` |
| `CYLPlaceholderScenarioCatalog` `+componentsForScenario:` | `CYLPlaceholderScenarioCatalog.componentsForScenario(scenario)` |
| `CYLPlaceholderScenarioCatalog` `+backgroundActionForScenario:` | `CYLPlaceholderScenarioCatalog.backgroundActionForScenario(scenario)` |
| `CYLPlaceholderScenarioCatalog` `+localizedNameForScenario:` | `CYLPlaceholderScenarioCatalog.localizedNameForScenario(scenario)` |
| `CYLPlaceholderScenarioCatalog` `+readmeScreenshotNumbersForScenario:` | `CYLPlaceholderScenarioCatalog.readmeScreenshotNumbersForScenario(scenario)` |
| `CYLPlaceholderScenarioCatalog` `+animationFileNamesForScenario:` | `CYLPlaceholderScenarioCatalog.animationFileNamesForScenario(scenario)` |
| `CYLPlaceholderScenarioCatalog` `+categoryForScenario:` | `CYLPlaceholderScenarioCatalog.categoryForScenario(scenario)` |
| `CYLPlaceholderScenarioCatalog` `+permissionForScenario:` | `CYLPlaceholderScenarioCatalog.permissionForScenario(scenario)` |
| `CYLPlaceholderScenarioCatalog` `+scenarioForPermission:` | `CYLPlaceholderScenarioCatalog.scenarioForPermission(permission)` |
| `CYLPlaceholderScenarioCatalog` `+nameForScenario:` | `CYLPlaceholderScenarioCatalog.nameForScenario(scenario)` |
| `CYLPlaceholderScenarioCatalog` `+scenarioNamed:` | `CYLPlaceholderScenarioCatalog.scenarioNamed(name)` (null instead of -1) |
| `CYLPlaceholderScenarioCatalog` `+actionNamed:` | `CYLPlaceholderScenarioCatalog.actionNamed(name)` |
| `CYLPlaceholderScenarioCatalog` `+localizedTitleForAction:` | `CYLPlaceholderScenarioCatalog.localizedTitleForAction(action)` |
| `CYLPlaceholderScenarioCatalog` `-init` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderScenarioCatalog` `+new` | n/a (NS_UNAVAILABLE on iOS) |

#### `CYLTableViewPlaceHolder/CYLPlaceholderStackView.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderActionHandler` | `CYLPlaceholderActionHandler` (`(placeholder, action) => void`) |
| `CYLPlaceholderStackView` | `@Component CYLPlaceholderStackView({ model })` + `CYLPlaceholderStackViewModel` |
| `CYLPlaceholderStackView` `stackView` | `CYLPlaceholderStackViewModel.entries` (the stacked rows) |
| `CYLPlaceholderStackView` `placeholderView` | `CYLPlaceholderStackViewModel.placeholderView` |
| `CYLPlaceholderStackView` `componentViews` | `CYLPlaceholderStackViewModel.componentViews` |
| `CYLPlaceholderStackView` `scenario` | `CYLPlaceholderStackViewModel.scenario` (null for components) |
| `CYLPlaceholderStackView` `backgroundAction` | `CYLPlaceholderStackViewModel.backgroundAction` |
| `CYLPlaceholderStackView` `-initWithScenario:actions:` | `CYLPlaceholderStackViewModel.initWithScenario(scenario, actions)` |
| `CYLPlaceholderStackView` `-initWithComponents:actions:` | `CYLPlaceholderStackViewModel.initWithComponents(components, actions)` |
| `CYLPlaceholderStackView` `-initWithConfiguration:actions:error:` | `CYLPlaceholderStackViewModel.initWithConfiguration(configuration, actions, onError)` |
| `CYLPlaceholderStackView` `-initWithContentsOfURL:actions:error:` | `CYLPlaceholderStackViewModel.initWithContentsOfURL(path, actions, onError)` (.json / XML .plist) |
| `CYLPlaceholderStackView` `-initWithFrame:` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderStackView` `-initWithCoder:` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderStackView` `-appendComponent:` | `CYLPlaceholderStackViewModel.appendComponent(component)` |
| `CYLPlaceholderStackView` `-appendComponentView:action:spacingBefore:` | `CYLPlaceholderStackViewModel.appendComponentView(view, action, spacingBefore)` |
| `CYLPlaceholderStackView` `-setHandler:forAction:` | `CYLPlaceholderStackViewModel.setHandler(handler, action)` |
| `CYLPlaceholderStackView` `-componentViewForAction:` | `CYLPlaceholderStackViewModel.componentViewForAction(action)` |
| `CYLPlaceholderStackView` `-performAction:` | `CYLPlaceholderStackViewModel.performAction(action)` |

#### `CYLTableViewPlaceHolder/CYLPlaceholderStatusView.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderStatusViewDelegate` | `CYLPlaceholderStatusViewDelegate` (interface) |
| `CYLPlaceholderStatusViewDelegate` `-statusViewClicked:` | `CYLPlaceholderStatusViewDelegate.statusViewClicked?(sender)` |
| `CYLPlaceholderStatusViewTapHandler` | `CYLPlaceholderStatusViewTapHandler` |
| `CYLPlaceholderStatusView` | `@Component CYLPlaceholderStatusView({ model })` + `CYLPlaceholderStatusViewModel` |
| `CYLPlaceholderStatusView` `delegate` | `CYLPlaceholderStatusViewModel.delegate` |
| `CYLPlaceholderStatusView` `-initWithFrame:` | `CYLPlaceholderStatusViewModel.initWithFrame()` |
| `CYLPlaceholderStatusView` `-initWithItemAttributes:error:` | `CYLPlaceholderStatusViewModel.initWithItemAttributes(attributes, onError)` |
| `CYLPlaceholderStatusView` `networkUnavailableItemAttributes` | `CYLPlaceholderStatusViewModel.networkUnavailableItemAttributes` |
| `CYLPlaceholderStatusView` `-initWithConfiguration:error:` | `CYLPlaceholderStatusViewModel.initWithConfiguration(configuration, onError)` |
| `CYLPlaceholderStatusView` `-initWithCoder:` | n/a (NS_UNAVAILABLE on iOS) |
| `CYLPlaceholderStatusView` `placeholderView` | `CYLPlaceholderStatusViewModel.placeholderView` |
| `CYLPlaceholderStatusView` `text` | `CYLPlaceholderStatusViewModel.text` |
| `CYLPlaceholderStatusView` `tapHandler` | `CYLPlaceholderStatusViewModel.tapHandler` |

#### `CYLTableViewPlaceHolder/CYLPlaceholderView.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderStyle` | `CYLPlaceholderStyle` (enum, with `Count`) |
| `CYLPlaceholderMessage` | `CYLPlaceholderMessage` (enum, with `Count`) |
| `CYLPlaceholderTapHighlightStyle` | `CYLPlaceholderTapHighlightStyle` (enum) |
| `CYLPlaceholderBadgeStyle` | `CYLPlaceholderBadgeStyle` (enum) |
| `CYLPlaceholderBadgeAppearance` | `CYLPlaceholderBadgeAppearance` (class) |
| `CYLPlaceholderBadgeAppearance` `backgroundColor` | `CYLPlaceholderBadgeAppearance.sharedAppearance.backgroundColor` |
| `CYLPlaceholderBadgeAppearance` `textColor` | `CYLPlaceholderBadgeAppearance.sharedAppearance.textColor` |
| `CYLPlaceholderBadgeAppearance` `font` | `CYLPlaceholderBadgeAppearance.sharedAppearance.font` |
| `CYLPlaceholderBadgeAppearance` `cornerRadius` | `CYLPlaceholderBadgeAppearance.sharedAppearance.cornerRadius` |
| `CYLPlaceholderBadgeAppearance` `contentInsets` | `CYLPlaceholderBadgeAppearance.sharedAppearance.contentInsets` |
| `CYLPlaceholderBadgeAppearance` `animationDuration` | `CYLPlaceholderBadgeAppearance.sharedAppearance.animationDuration` |
| `CYLPlaceholderBadgeAppearance` `animatesChanges` | `CYLPlaceholderBadgeAppearance.sharedAppearance.animatesChanges` |
| `CYLPlaceholderBadgeAppearance` `+sharedAppearance` | `CYLPlaceholderBadgeAppearance.sharedAppearance` |
| `CYLPlaceholderAnimationPlayer` | `CYLPlaceholderAnimationPlayer` (`view` is what is drawn) |
| `CYLPlaceholderAnimationPlayer` `ready` | `CYLPlaceholderAnimationPlayer.ready` |
| `CYLPlaceholderAnimationPlayer` `errorHandler` | `CYLPlaceholderAnimationPlayer.errorHandler` |
| `CYLPlaceholderAnimationPlayer` `readyHandler` | `CYLPlaceholderAnimationPlayer.readyHandler` |
| `CYLPlaceholderAnimationPlayer` `-play` | `CYLPlaceholderAnimationPlayer.play()` |
| `CYLPlaceholderAnimationPlayer` `-stop` | `CYLPlaceholderAnimationPlayer.stop()` |
| `CYLPlaceholderAnimationPlayer` `-showLastFrame` | `CYLPlaceholderAnimationPlayer.showLastFrame()` |
| `CYLPlaceholderAnimationPlayer` `-setAnimationProgress:` | `CYLPlaceholderAnimationPlayer.setAnimationProgress(progress)` |
| `CYLPlaceholderAnimationPlayer` `-setAnimationSpeed:` | `CYLPlaceholderAnimationPlayer.setAnimationSpeed(speed)` |
| `CYLPlaceholderAnimationPlayer` `-setAnimationRepeatCount:` | `CYLPlaceholderAnimationPlayer.setAnimationRepeatCount(count)` |
| `CYLPlaceholderAnimationPlayer` `-setAnimationColors:` | `CYLPlaceholderAnimationPlayer.setAnimationColors(colors)` |
| `CYLPlaceholderAnimationFactory` | `CYLPlaceholderAnimationFactory` (fileURL, width, height, contentMode, options) => player | null |
| `CYLPlaceholderView` | `@Component CYLPlaceholderView({ model })` + `@Observed CYLPlaceholderViewModel` |
| `CYLPlaceholderView` `imageView` | `CYLPlaceholderViewModel.image` (drawn by an ArkUI `Image`) |
| `CYLPlaceholderView` `textLabel` | `CYLPlaceholderViewModel.text` (drawn by an ArkUI `Text`) |
| `CYLPlaceholderView` `badgeValue` | `CYLPlaceholderViewModel.badgeValue` |
| `CYLPlaceholderView` `badgeLabel` | `CYLPlaceholderViewModel.badgeText` / `badgeStyle` (drawn by an ArkUI `Text`) |
| `CYLPlaceholderView` `badgeCenterOffset` | `CYLPlaceholderViewModel.badgeCenterOffset` |
| `CYLPlaceholderView` `-showBadgeWithStyle:value:` | `CYLPlaceholderViewModel.showBadgeWithStyle(style, value)` |
| `CYLPlaceholderView` `selected` | `CYLPlaceholderViewModel.selected` |
| `CYLPlaceholderView` `selectionIndicatorImage` | `CYLPlaceholderViewModel.selectionIndicatorImage` |
| `CYLPlaceholderView` `selectionIndicatorTintColor` | `CYLPlaceholderViewModel.selectionIndicatorTintColor` |
| `CYLPlaceholderView` `defaultTitleColor` | `CYLPlaceholderViewModel.defaultTitleColor` |
| `CYLPlaceholderView` `defaultIconColor` | `CYLPlaceholderViewModel.defaultIconColor` |
| `CYLPlaceholderView` `defaultBackgroundColor` | `CYLPlaceholderViewModel.defaultBackgroundColor` |
| `CYLPlaceholderView` `defaultTitleFont` | `CYLPlaceholderViewModel.defaultTitleFont` |
| `CYLPlaceholderView` `defaultTitlePositionAdjustment` | `CYLPlaceholderViewModel.defaultTitlePositionAdjustment` |
| `CYLPlaceholderView` `defaultSelectedTitleColor` | `CYLPlaceholderViewModel.defaultSelectedTitleColor` |
| `CYLPlaceholderView` `defaultSelectedIconColor` | `CYLPlaceholderViewModel.defaultSelectedIconColor` |
| `CYLPlaceholderView` `defaultSelectedBackgroundColor` | `CYLPlaceholderViewModel.defaultSelectedBackgroundColor` |
| `CYLPlaceholderView` `defaultSelectedTitleFont` | `CYLPlaceholderViewModel.defaultSelectedTitleFont` |
| `CYLPlaceholderView` `defaultSelectionIndicatorImage` | `CYLPlaceholderViewModel.defaultSelectionIndicatorImage` |
| `CYLPlaceholderView` `defaultSelectionIndicatorTintColor` | `CYLPlaceholderViewModel.defaultSelectionIndicatorTintColor` |
| `CYLPlaceholderView` `itemAttributes` | `CYLPlaceholderViewModel.itemAttributes` |
| `CYLPlaceholderView` `reportsContentSize` | `CYLPlaceholderViewModel.reportsContentSize` |
| `CYLPlaceholderView` `preferredMaxLayoutWidth` | `CYLPlaceholderViewModel.preferredMaxLayoutWidth` |
| `CYLPlaceholderView` `contentMargin` | `CYLPlaceholderViewModel.contentMargin` |
| `CYLPlaceholderTapHandler` | `CYLPlaceholderTapHandler` (`(placeholderView) => void`) |
| `CYLPlaceholderView` `tapHandler` | `CYLPlaceholderViewModel.tapHandler` |
| `CYLPlaceholderView` `tapInteractionEnabled` | `CYLPlaceholderViewModel.tapInteractionEnabled` |
| `CYLPlaceholderView` `tapHighlightStyle` | `CYLPlaceholderViewModel.tapHighlightStyle` |
| `CYLPlaceholderView` `tapHighlighted` | `CYLPlaceholderViewModel.tapHighlighted` |
| `CYLPlaceholderView` `tapInteractive` | `CYLPlaceholderViewModel.tapInteractive` |
| `CYLPlaceholderView` `-performTap` | `CYLPlaceholderViewModel.performTap()` |
| `CYLPlaceholderView` `animationRepeatCount` | `CYLPlaceholderViewModel.animationRepeatCount` (1 by default) |
| `CYLPlaceholderView` `+registerAnimationFactory:forFileExtension:` | `CYLPlaceholderViewModel.registerAnimationFactory(factory, fileExtension)` |
| `CYLPlaceholderView` `-playPlaceholderAnimation` | `CYLPlaceholderViewModel.playPlaceholderAnimation()` |
| `CYLPlaceholderView` `-stopPlaceholderAnimation` | `CYLPlaceholderViewModel.stopPlaceholderAnimation()` |
| `CYLPlaceholderView` `-showPlaceholderAnimationLastFrame` | `CYLPlaceholderViewModel.showPlaceholderAnimationLastFrame()` |
| `CYLPlaceholderView` `-setPlaceholderAnimationProgress:` | `CYLPlaceholderViewModel.setPlaceholderAnimationProgress(progress)` |
| `CYLPlaceholderView` `-setPlaceholderAnimationSpeed:` | `CYLPlaceholderViewModel.setPlaceholderAnimationSpeed(speed)` |
| `CYLPlaceholderView` `-initWithItemAttributes:imageBundle:error:` | `CYLPlaceholderViewModel.initWithItemAttributes(attributes, imageBundle, onError)` (imageBundle ignored: images are bundled icon names, Resources or paths) |
| `CYLPlaceholderView` `-initWithItemContentsOfURL:imageBundle:error:` | `CYLPlaceholderViewModel.initWithItemContentsOfURL(path, imageBundle, onError)` (.json / XML .plist) |
| `CYLPlaceholderView` `-initWithStyle:message:` | `CYLPlaceholderViewModel.initWithStyleMessage(style, message)` |
| `CYLPlaceholderView` `-initWithStyle:text:` | `CYLPlaceholderViewModel.initWithStyleText(style, text)` |
| `CYLPlaceholderView` `-initWithImage:text:` | `CYLPlaceholderViewModel.initWithImageText(image, text)` |
| `CYLPlaceholderView` `+imageForStyle:` | `CYLPlaceholderViewModel.imageForStyle(style)` (a Resource) |
| `CYLPlaceholderView` `+imageNameForStyle:` | `CYLPlaceholderViewModel.imageNameForStyle(style)` |
| `CYLPlaceholderView` `+localizedTextForMessage:` | `CYLPlaceholderViewModel.localizedTextForMessage(message)` |
| `CYLPlaceholderView` `+bundledAnimationFileNames` | `CYLPlaceholderViewModel.bundledAnimationFileNames()` |
| `CYLPlaceholderView` `+pathForBundledAnimation:` | `CYLPlaceholderViewModel.pathForBundledAnimation(fileName)` (rawfile path) |

#### `CYLTableViewPlaceHolder/CYLTableViewPlaceHolderDelegate.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLTableViewPlaceHolderDelegate` | `CYLTableViewPlaceHolderDelegate` (interface, the `CYLPlaceholderListController.delegate`) |
| `CYLTableViewPlaceHolderDelegate` `-makePlaceHolderView` | `CYLTableViewPlaceHolderDelegate.makePlaceHolderView()` |
| `CYLTableViewPlaceHolderDelegate` `-enableScrollWhenPlaceHolderViewShowing` | `CYLTableViewPlaceHolderDelegate.enableScrollWhenPlaceHolderViewShowing?()` |
| `CYLTableViewPlaceHolderDelegate` `-frameForPlaceHolderViewInTableView:` | `CYLTableViewPlaceHolderDelegate.frameForPlaceHolderViewInTableView?(tableView)` (`CYLPlaceholderRect`) |

#### `CYLTableViewPlaceHolder/UICollectionView+CYLPlaceholder.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLCollectionPlaceholderViewBlock` | `CYLCollectionPlaceholderViewBlock` |
| `CYLCollectionPlaceholderNormalBlock` | `CYLCollectionPlaceholderNormalBlock` |
| `UICollectionView(CYLPlaceholder)` | `CYLPlaceholderListController` (alias `CYLPlaceholderCollectionController`) + `@Component CYLPlaceholderList` around the Grid |
| `UICollectionView(CYLPlaceholder)` `-cyl_placeholderViewBlock:` | `CYLPlaceholderListController.cyl_placeholderViewBlock(block)` |
| `UICollectionView(CYLPlaceholder)` `-cyl_placeholderViewBlock:backToNormalBlock:` | `CYLPlaceholderListController.cyl_placeholderViewBlockBackToNormalBlock(block, backToNormalBlock)` |

#### `CYLTableViewPlaceHolder/UITableView+CYLPlaceholder.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLTablePlaceholderViewBlock` | `CYLTablePlaceholderViewBlock` |
| `CYLTablePlaceholderNormalBlock` | `CYLTablePlaceholderNormalBlock` |
| `UITableView(CYLPlaceholder)` | `CYLPlaceholderListController` (alias `CYLPlaceholderTableController`) + `@Component CYLPlaceholderList` around the List |
| `UITableView(CYLPlaceholder)` `-cyl_placeholderViewBlock:` | `CYLPlaceholderListController.cyl_placeholderViewBlock(block)` |
| `UITableView(CYLPlaceholder)` `-cyl_placeholderViewBlock:backToNormalBlock:` | `CYLPlaceholderListController.cyl_placeholderViewBlockBackToNormalBlock(block, backToNormalBlock)` |

#### `CYLTableViewPlaceHolder/UITableView+CYLTableViewPlaceHolder.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `UITableView(CYLTableViewPlaceHolder)` | `CYLPlaceholderListController` (with a `CYLTableViewPlaceHolderDelegate`) |
| `UITableView(CYLTableViewPlaceHolder)` `-cyl_reloadData` | `CYLPlaceholderListController.cyl_reloadData()` |

#### `CYLTableViewPlaceHolder/UIViewController+CYLPlaceholderStatus.h`

| iOS API | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| `CYLPlaceholderStatusDisplay` | `CYLPlaceholderStatusDisplay` (None / StatusBar / Placeholder / All, combine with `|`) |
| `UIViewController(CYLPlaceholderStatus)` | `CYLPlaceholderStatusController` (the page's UIViewController) + `@Component CYLPlaceholderStatusPage` |
| `UIViewController(CYLPlaceholderStatus)` `cyl_statusView` | `CYLPlaceholderStatusController.cyl_statusView` |
| `UIViewController(CYLPlaceholderStatus)` `cyl_placeholderScrollView` | `CYLPlaceholderStatusController.cyl_placeholderScrollView` |
| `UIViewController(CYLPlaceholderStatus)` `cyl_statusDisplay` | `CYLPlaceholderStatusController.cyl_statusDisplay` |
| `UIViewController(CYLPlaceholderStatus)` `-cyl_setStatusDisplay:animated:` | `CYLPlaceholderStatusController.cyl_setStatusDisplay(display, animated)` |
| `UIViewController(CYLPlaceholderStatus)` `cyl_showsStatusViewWhenOffline` | `CYLPlaceholderStatusController.cyl_showsStatusViewWhenOffline` |
| `UIViewController(CYLPlaceholderStatus)` `-cyl_applyStatusConfiguration:error:` | `CYLPlaceholderStatusController.cyl_applyStatusConfiguration(configuration, onError)` |
| `UIViewController(CYLPlaceholderStatus)` `-cyl_applyStatusConfigurationWithContentsOfURL:error:` | `CYLPlaceholderStatusController.cyl_applyStatusConfigurationWithContentsOfURL(path, onError)` |
| `UIScrollView(CYLPlaceholderVisibility)` | `CYLPlaceholderListController` |
| `UIScrollView(CYLPlaceholderVisibility)` `cyl_placeholderHidden` | `CYLPlaceholderListController.cyl_placeholderHidden` |

### 表 2：iOS example 演示 / Table 2: iOS example demos

#### App shell (CYLScenarioAppDelegate, CYLTabBarController)

| iOS 演示 / iOS demo | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| Tab bar: Scenarios, Animations, Flows, Feed, Refresh and the raised teal plus button at index 3 | TODO |
| Publish (plus button): Uploading, then Success with Done | TODO |
| Language menu (🌐): 7 languages + follow system, rebuilds the interface | TODO |

#### Scenarios tab (CYLScenarioListViewController, CYLScenarioDetailViewController)

| iOS 演示 / iOS demo | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| Scenario `NetworkUnavailable`: Network unavailable | TODO |
| Scenario `NoContent`: No content | TODO |
| Scenario `TapToReload`: Tap to reload | TODO |
| Scenario `LoadFailedWithHint`: Load failed with a hint | TODO |
| Scenario `TapToReconnect`: Tap to reconnect | TODO |
| Scenario `RetryButton`: Retry button | TODO |
| Scenario `RetryOutlinedButton`: Outlined retry button | TODO |
| Scenario `RetryWithHint`: Hint and reload button | TODO |
| Scenario `RetryOrContactSupport`: Retry or contact support | TODO |
| Scenario `IllustrationRetry`: Illustration and capsule button | TODO |
| Scenario `RefreshIcon`: Refresh icon | TODO |
| Scenario `TitleAboveIllustration`: Title above the illustration | TODO |
| Scenario `TextOnly`: Text only | TODO |
| Scenario `TapMeRetry`: Tap me and reload | TODO |
| Scenario `LocationPermissionDenied`: Location permission denied | TODO |
| Scenario `NoSearchResults`: No search results | TODO |
| Scenario `EmptyCart`: Empty cart | TODO |
| Scenario `NoOrders`: No orders | TODO |
| Scenario `NoFavorites`: No favorites | TODO |
| Scenario `NoMessages`: No messages | TODO |
| Scenario `NoNotifications`: No notifications | TODO |
| Scenario `NoPermission`: No permission | TODO |
| Scenario `CameraPermissionDenied`: Camera permission denied | TODO |
| Scenario `PhotoLibraryPermissionDenied`: Photo permission denied | TODO |
| Scenario `MicrophonePermissionDenied`: Microphone permission denied | TODO |
| Scenario `ContactsPermissionDenied`: Contacts permission denied | TODO |
| Scenario `CalendarPermissionDenied`: Calendar permission denied | TODO |
| Scenario `BluetoothPermissionDenied`: Bluetooth permission denied | TODO |
| Scenario `NotificationPermissionDenied`: Notification permission denied | TODO |
| Scenario `ServerError`: Server error | TODO |
| Scenario `SyncFailed`: Sync failed | TODO |
| Scenario `Loading`: Loading | TODO |
| Scenario `Uploading`: Uploading | TODO |
| Scenario `Success`: Success | TODO |
| Scenario `HUD`: HUD | TODO |
| Contact support page (CYLSupportViewController) | TODO |
| Configuration file `animation-formats` (CYLConfigurationViewController) | TODO |
| Configuration file `ctrip-retry-or-contact-support` (CYLConfigurationViewController) | TODO |
| Configuration file `interaction-switches` (CYLConfigurationViewController) | TODO |
| Configuration file `location-permission` (CYLConfigurationViewController) | TODO |
| Configuration file `playback-policies` (CYLConfigurationViewController) | TODO |
| Configuration file `raw-item-attributes` (CYLConfigurationViewController) | TODO |
| Configuration file `smzdm-capsule.plist` (CYLConfigurationViewController) | TODO |
| Configuration file raw text (CYLTextFileViewController) | TODO |

#### Animations tab (CYLAnimationListViewController, CYLAnimationDetailViewController)

| iOS 演示 / iOS demo | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| Animation files: Lottie · CYLTableViewPlaceHolder/LottieSwift (47 files, detail replays every 4 s) | TODO |
| Animation files: PAG · CYLTableViewPlaceHolder/PAG (4 files, detail replays every 4 s) | TODO |
| Animation files: Rive · CYLTableViewPlaceHolder/Rive (4 files, detail replays every 4 s) | TODO |
| Animation files: GIF · Core (7 files, detail replays every 4 s) | TODO |
| Animation files: CYLScenarioExample.bundle/Animations (12 files, detail replays every 4 s) | TODO |
| Sources (NOTICE.animations) | TODO |

#### Flows tab (CYLFlowListViewController)

| iOS 演示 / iOS demo | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| Flow `switchStates`: Switch states (reloadData #3) | TODO |
| Flow `keepTableHeader`: Keep table header (frameForPlaceHolderViewInTableView: #17) | TODO |
| Flow `keepSectionHeaders`: Keep section headers (rectForHeaderInSection: #16) | TODO |
| Flow `refreshControls`: Refresh controls (cyl_header + cyl_footer #8) | TODO |
| Flow `scrollable`: Scrollable (enableScrollWhenPlaceHolderViewShowing) | TODO |
| Flow `collection`: Collection view (cyl_placeholderViewBlock: #11) | TODO |
| Network status bar (CYLStatusBarViewController): Bar + placeholder | TODO |
| Network status bar (CYLStatusBarViewController): Bar only | TODO |
| Network status bar (CYLStatusBarViewController): Placeholder only | TODO |
| Network status bar (CYLStatusBarViewController): Bar + list | TODO |
| Network status bar: follow the network, apply StatusBar/*.json files | TODO |
| HUD (CYLHUDViewController): Show | TODO |
| HUD (CYLHUDViewController): Show with a status | TODO |
| HUD (CYLHUDViewController): Show a progress | TODO |
| HUD (CYLHUDViewController): Success | TODO |
| HUD (CYLHUDViewController): Error | TODO |
| HUD (CYLHUDViewController): Info | TODO |
| HUD (CYLHUDViewController): Image | TODO |
| HUD (CYLHUDViewController): Components with a Cancel button | TODO |
| HUD (CYLHUDViewController): A scenario in the box (Uploading) | TODO |
| HUD (CYLHUDViewController): Three shows, three pops | TODO |
| HUD (CYLHUDViewController): Dismiss | TODO |
| HUD (CYLHUDViewController): Style | TODO |
| HUD (CYLHUDViewController): Mask | TODO |
| HUD (CYLHUDViewController): Loading animation | TODO |
| HUD (CYLHUDViewController): Haptics | TODO |
| HUD (CYLHUDViewController): Loading, failed, refresh, load more | TODO |
| HUD life cycle (CYLHUDLifecycleViewController) | TODO |

#### Feed tab (CYLFeedViewController)

| iOS 演示 / iOS demo | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| Feed: loading, 15 posts, every other refresh fails with RetryButton, load more to 30 then No more data | TODO |
| Refresh icons (CYLRefreshIconListViewController): Default arrow style (unchanged) · Arrow header, auto footer | TODO |
| Refresh icons (CYLRefreshIconListViewController): Default arrow style (unchanged) · Arrow header, back footer | TODO |
| Refresh icons (CYLRefreshIconListViewController): GIF · Core · CYLRefreshActivity.gif | TODO |
| Refresh icons (CYLRefreshIconListViewController): GIF · Core · CYLRefreshArrows.gif | TODO |
| Refresh icons (CYLRefreshIconListViewController): GIF · Core · CYLRefreshPetals.gif | TODO |
| Refresh icons (CYLRefreshIconListViewController): GIF · Core · CYLRefreshRing.gif | TODO |
| Refresh icons (CYLRefreshIconListViewController): GIF · Core · CYLRefreshThrobber.gif | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLPlaceholderRefresh.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshArc.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshClockwise.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshCounterClockwise.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshCycle.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshDone.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshDoneCircle.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshDonePop.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshDots.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshDotsPulse.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshGradientSpinner.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshLoadMore.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshMaterialSpinner.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshMoreDots.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshPullArrow.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshPullCircle.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): Lottie · CYLTableViewPlaceHolder/LottieSwift · CYLRefreshSpinnerRing.json | TODO |
| Refresh icons (CYLRefreshIconListViewController): PAG · CYLTableViewPlaceHolder/PAG · CYLPlaceholderProgress.pag | TODO |
| Refresh icons (CYLRefreshIconListViewController): Rive · CYLTableViewPlaceHolder/Rive · CYLRefreshIcon.riv | TODO |
| Refresh icons (CYLRefreshIconListViewController): Other ways to set an icon · Image sequence per state | TODO |
| Refresh icons (CYLRefreshIconListViewController): Other ways to set an icon · A different icon for each state | TODO |
| Refresh icons (CYLRefreshIconListViewController): Other ways to set an icon · Back footer, icon per state | TODO |
| Refresh icons (CYLRefreshIconListViewController): Other ways to set an icon · By file path | TODO |
| Refresh icons (CYLRefreshIconListViewController): Other ways to set an icon · By item attributes (Rive artboard) | TODO |
| Refresh icons (CYLRefreshIconListViewController): Other ways to set an icon · By configuration file | TODO |
| Refresh icons (CYLRefreshIconListViewController): Other ways to set an icon · MJRefresh Gif names (compatible) | TODO |

#### Refresh tab (CYLRefreshExampleViewController)

| iOS 演示 / iOS demo | 鸿蒙对应实现 / HarmonyOS |
|:---|:---|
| UITableView + pull-down refresh · Default (CYLRefreshTableViewController - example01) | TODO |
| UITableView + pull-down refresh · Animated images (CYLRefreshTableViewController - example02) | TODO |
| UITableView + pull-down refresh · Hide the time (CYLRefreshTableViewController - example03) | TODO |
| UITableView + pull-down refresh · Hide the state and time (CYLRefreshTableViewController - example04) | TODO |
| UITableView + pull-down refresh · Custom text (CYLRefreshTableViewController - example05) | TODO |
| UITableView + pull-down refresh · Custom refresh control (CYLRefreshTableViewController - example06) | TODO |
| UITableView + pull-up loading · Default (CYLRefreshTableViewController - example11) | TODO |
| UITableView + pull-up loading · Animated images (CYLRefreshTableViewController - example12) | TODO |
| UITableView + pull-up loading · Hide the refreshing text (CYLRefreshTableViewController - example13) | TODO |
| UITableView + pull-up loading · Everything loaded (CYLRefreshTableViewController - example14) | TODO |
| UITableView + pull-up loading · No automatic loading (CYLRefreshTableViewController - example15) | TODO |
| UITableView + pull-up loading · Custom text (CYLRefreshTableViewController - example16) | TODO |
| UITableView + pull-up loading · Hide after loading (CYLRefreshTableViewController - example17) | TODO |
| UITableView + pull-up loading · Springing-back footer 01 (CYLRefreshTableViewController - example18) | TODO |
| UITableView + pull-up loading · Springing-back footer 02 (CYLRefreshTableViewController - example19) | TODO |
| UITableView + pull-up loading · Custom control (loads automatically) (CYLRefreshTableViewController - example20) | TODO |
| UITableView + pull-up loading · Custom control (springs back) (CYLRefreshTableViewController - example21) | TODO |
| UICollectionView · Pull down and up (CYLRefreshCollectionViewController - example31) | TODO |
| UICollectionView · Pull down and up, pinned header (CYLRefreshPinHeaderCollectionViewController - example31) | TODO |
| UICollectionView · Pull left (CYLRefreshHorizontalCollectionViewController - example42) | TODO |
| WKWebView · Pull down (the former UIWebView sample) (CYLRefreshWKWebViewController - example40) | TODO |
| WKWebView · Pull down to reload (CYLRefreshWKWebViewController - example41) | TODO |
| Localization · Refresh text languages (CYLRefreshI18NExampleViewController - i18n) | TODO |
| Animated icons: GIF, Lottie, PAG, Rive · GIF icon in place of the images (CYLRefreshTableViewController - example51) | TODO |
| Animated icons: GIF, Lottie, PAG, Rive · Lottie icon for each state (CYLRefreshTableViewController - example52) | TODO |
| Animated icons: GIF, Lottie, PAG, Rive · PAG progress ring (CYLRefreshTableViewController - example53) | TODO |
| Animated icons: GIF, Lottie, PAG, Rive · Rive refresh icon (CYLRefreshTableViewController - example54) | TODO |
| Animated icons: GIF, Lottie, PAG, Rive · Animated images from GIF frames (CYLRefreshTableViewController - example55) | TODO |
| Animated icons: GIF, Lottie, PAG, Rive · A different engine for each state (CYLRefreshTableViewController - example56) | TODO |
| Animated icons: GIF, Lottie, PAG, Rive · UICollectionView with animated icons (CYLRefreshCollectionViewController - example32) | TODO |
| SmartRefreshControl styles · Delivery (CYLSmartRefreshDemoViewController - smartDelivery) | TODO |
| SmartRefreshControl styles · Classics (CYLSmartRefreshDemoViewController - smartClassics) | TODO |
| SmartRefreshControl styles · DropBox (CYLSmartRefreshDemoViewController - smartDropBox) | TODO |
| SmartRefreshControl styles · Phoenix (CYLSmartRefreshDemoViewController - smartPhoenix) | TODO |
| SmartRefreshControl styles · Taurus (CYLSmartRefreshDemoViewController - smartTaurus) | TODO |
| SmartRefreshControl styles · BezierRadar (CYLSmartRefreshDemoViewController - smartBezierRadar) | TODO |
| SmartRefreshControl styles · BezierCircle (CYLSmartRefreshDemoViewController - smartBezierCircle) | TODO |
| SmartRefreshControl styles · StoreHouse (CYLSmartRefreshDemoViewController - smartStoreHouse) | TODO |
| SmartRefreshControl styles · WaveSwipe (CYLSmartRefreshDemoViewController - smartWaveSwipe) | TODO |
| SmartRefreshControl styles · Original (CYLSmartRefreshDemoViewController - smartOriginal) | TODO |
| SmartRefreshControl styles · Material (CYLSmartRefreshDemoViewController - smartMaterial) | TODO |
| SmartRefreshControl styles · GameHitBlock (CYLSmartRefreshDemoViewController - smartGameHitBlock) | TODO |
| SmartRefreshControl styles · GameBattleCity (CYLSmartRefreshDemoViewController - smartGameBattleCity) | TODO |
| SmartRefreshControl styles · Fly (CYLSmartRefreshDemoViewController - smartFly) | TODO |
| SmartRefreshControl styles · Classics footer (CYLSmartRefreshDemoViewController - smartClassicsFooter) | TODO |
| SmartRefreshControl styles · BezierRadar footer (CYLSmartRefreshDemoViewController - smartBezierRadarFooter) | TODO |
| SmartRefreshControl styles · Material footer (CYLSmartRefreshDemoViewController - smartMaterialFooter) | TODO |
| SmartRefreshControl styles · Delivery footer (CYLSmartRefreshDemoViewController - smartDeliveryFooter) | TODO |
| SmartRefreshControl styles · Phoenix footer (CYLSmartRefreshDemoViewController - smartPhoenixFooter) | TODO |
| SmartRefreshControl styles · Taurus footer (CYLSmartRefreshDemoViewController - smartTaurusFooter) | TODO |
| SmartRefreshControl styles · Rive · Bow (CYLSmartRefreshDemoViewController - smartRiveBow) | TODO |
| SmartRefreshControl styles · Rive · Bubbles (CYLSmartRefreshDemoViewController - smartRiveBubbles) | TODO |
| SmartRefreshControl styles · Rive · Halloween (CYLSmartRefreshDemoViewController - smartRiveHalloween) | TODO |
| SmartRefreshControl styles · Rive · Skating (CYLSmartRefreshDemoViewController - smartRiveSkating) | TODO |
| SmartRefreshControl styles · Rive · Space (CYLSmartRefreshDemoViewController - smartRiveSpace) | TODO |
| SmartRefreshControl styles · Rive · Squats (CYLSmartRefreshDemoViewController - smartRiveSquats) | TODO |
| SmartRefreshControl styles · Rive · Space footer (CYLSmartRefreshDemoViewController - smartRiveSpaceFooter) | TODO |
| flutter_easy_refresh samples · Cupertino style (CYLEasyRefreshDemoViewController - easyCupertino) | TODO |
| flutter_easy_refresh samples · Second floor (CYLEasyRefreshDemoViewController - easySecondary) | TODO |
| flutter_easy_refresh samples · Trigger mode (CYLEasyRefreshDemoViewController - easyTriggerMode) | TODO |
| flutter_easy_refresh samples · Refresh on start (CYLEasyRefreshDemoViewController - easyRefreshOnStart) | TODO |
| flutter_easy_refresh samples · Paging (CYLEasyRefreshDemoViewController - easyPaging) | TODO |
| flutter_easy_refresh samples · Listener header (CYLEasyRefreshDemoViewController - easyListener) | TODO |
| flutter_easy_refresh samples · Chat (CYLEasyRefreshDemoViewController - easyChat) | TODO |
| flutter_easy_refresh samples · User profile (CYLEasyRefreshDemoViewController - easyUserProfile) | TODO |

<!-- harmony-tables:end -->
