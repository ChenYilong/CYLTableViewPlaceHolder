# 微信小程序版 / WeChat Mini Program port

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [任务](#任务--tasks) | [Tasks](#任务--tasks) |
| [结构](#结构--structure) | [Structure](#结构--structure) |
| [API 对照](#api-对照--api-alignment) | [API alignment](#api-对照--api-alignment) |
| [验证](#验证--verification) | [Verification](#验证--verification) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

## 任务 / Tasks

### TODO: WeChat Mini Program placeholder package (score 95)

- **Date / branch:** 2026-11-15, `feat/android-refresh-port-followup` (based on `feat/android-refresh-port`; its pull
  request targets `feat/android-refresh-port`).
- **The user's original prompt (verbatim):** "基于新分支 开始下微信小程序开发。找到docs里面任何提及微信小程序的信息开始开发。找到crossplatorm 相关文件夹，没有就新建，新建或者更微信小程序开发。微信小程序开发者工具Skills ，根据文档"
- **Requirements:**
  1. Start WeChat Mini Program development on the new branch.
  2. Use every mention of mini programs in the docs as the spec.
  3. Find the cross-platform folder; there was none in this repository, so create `CrossPlatform/` (the same name
     and layout as CYLTabBarController's `CrossPlatform/wechat-miniprogram-cyltabbar`).
  4. Use the WeChat DevTools Skills (<https://developers.weixin.qq.com/miniprogram/dev/devtools/Skills.html>) to
     build, run and screenshot the example.
- **What the docs say about mini programs:**
  - `AGENTS.md` "SKILLS": install the WeChat DevTools Skills (done on this machine: `~/.claude/skills/wechatide-skill`,
    a junction to the DevTools' own `wechatide-skill` v0.3.11).
  - `instructions.md` rule 6: the porting rules apply to every platform, mini programs included.
  - `instructions.md` / `docs/Example-Animation-Playback.md`: every example page that shows animations gets "Play
    all" (restart from progress 0), a speed slider and a loop switch.
  - `instructions.md` screenshots: the README records the platform, the base library version, the commit and time.
  - `instructions.md` localization: one `locales/<locale>.json` per package (the Web / React Native rule; used here).
- **Plan:**
  1. `CrossPlatform/wechat-miniprogram-cylplaceholder/src/cyl-placeholder`: a custom component that renders one of
     the 35 scenarios of `CYLPlaceholderScenarioCatalog` (translated from `android/placeholder`'s
     `CYLPlaceholderScenario.kt`): icon / title / hint / button / separator components, background tap action,
     `action` event with the `CYLPlaceholderAction*` names, `interactive` switch.
  2. Localization from the Android strings (en, zh-Hans, zh-Hant, ja, ko, ru, uk) into `locales/*.json`.
  3. Example app (`example/miniprogram`): a scenario list page and a page showing each scenario on an empty list.
  4. `node --test` unit tests for the catalog and the localization.
  5. Open the example with the DevTools skill (`project_import`, `open_project_window`, `simulator_screenshot`),
     store the screenshot in `docs/`, update the README.
- **Score: 95 / 100.** Package, example and unit tests done; all 35 scenarios render and Retry works in the DevTools
  simulator; `cyl-placeholder-hud` (CYLPlaceholderHUD), Lottie animations for 31 scenarios with "Play all", speed
  and loop controls, `CYLPlaceholderConfiguration` (JSON configuration files) and `cyl-placeholder-status`
  (CYLPlaceholderStatusView) ported; all checked in the simulator; README section with screenshots added. Left:
  the real phone check (skipped), the differences listed in items 2–4.
- **Remaining work (TODO):**
  1. Check on a real phone (preview). Skipped for now at the owner's request (2026-11-15). The DevTools Skills client authorization (`wechatide auth -c Claude`) still
     times out with `connect_failed` even while logged in, so the simulator run used the classic CLI
     (`wechatidecli open` / `auto`) and miniprogram-automator instead of the skill tools. DevTools refuses
     `touristappid` ("There is no such AppID", code 10): set a real AppID in the git-ignored
     `project.private.config.json`.
  2. Animations (`f8089ef`): Lottie done for the 31 scenarios whose file list has a `CYLPlaceholder*.json`; the
     example has "Play all", a speed slider and a loop switch. Left: PAG / Rive / GIF variants (TitleAboveIllustration
     PAG, Uploading GIF, Success Rive; the mini program shows those scenarios' static icon or the first JSON variant),
     choosing a variant per scenario, Lottie on the HUD (`loadingAnimationFileName`), Dark Mode colors (`colors` of
     cyl-lottie). The example's player comes from a CYLTabBarController checkout (`CYL_TABBAR_DIR`, default: next to
     this repository); the package itself has no dependency (the `animation` generic defaults to no player).
  3. Ported with known differences (no further work planned unless asked). `CYLPlaceholderStatusView` (`2368eb0`):
     `cyl-placeholder-status` is placed by the page (a mini program has no view controller or
     `additionalSafeAreaInsets`; put it above the list), no Dynamic Type height, no
     `CYLPlaceholderItemContentAxis` item keys, no right-to-left mirroring.
     `CYLPlaceholderConfiguration` is ported (`3e164da`) except: `.plist` (refused with the Android message), the
     `item` type draws only the title attributes (title color, background color, corner radius, content insets,
     minimum width; other raw item attributes are ignored), a numeric `style` indexes the sorted icon list instead of
     the `CYLPlaceholderStyle` enum order, non-Lottie `animation` names validate but keep the static icon.
     `CYLPlaceholderHUD` is ported (`dfc0495`) except: the appear / disappear / touch notifications (one `touch`
     event instead), haptics, `offsetFromCenter`, `minimumSize`, colors / font / corner radius properties,
     `loading/progress/successAnimationFileName` (the loading animation is the iOS `CYLRefreshActivity.gif`; success /
     error / info use text glyphs instead of the iOS images), the Custom style and Custom mask type.
  4. Icon tinting: Android tints template icons; the mini program uses 45 % opacity (no `tintColor` on `<image>`).
  5. Done: branch pushed; pull request https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/31 targets
     `feat/android-refresh-port`.
- **Doc discrepancy found:** `docs/Placeholder-Scenarios.md` says "36 scenarios (including HUD)", but the iOS-derived
  Kotlin enum has 35 entries (HUD included). The unit test pins the mini program list to the Kotlin enum.

### TODO: The mini program example as a 1:1 copy of the iOS example (score 0 → in progress)

- **Date / branch:** 2026-11-15, `feat/android-refresh-port-followup` (pull request #31).
- **The user's original prompt (verbatim):** "跳过真机测试。继续小程序example层要一比一复刻"
- **Requirements:** skip the real phone test; rebuild the mini program example as a 1:1 copy of the iOS example
  `Examples/Example-Scenarios` (the Android `android/merged/example` is itself a port of it).
- **The iOS example:** a CYLTabBarController with five tabs, Scenarios, Animations, Flows, Feed and Refresh, and a
  teal plus button at index 3 that presents "Publish" (Uploading, then Success with Done); a 🌐 language switch that
  rebuilds the interface; the Scenarios tab lists the README cases, the business cases and the configuration files;
  HUD and status bar pages; the Refresh tab is a menu of CYLRefresh demos (table, collection, web view, SmartRefresh
  and EasyRefresh styles, refresh icons, DIY controls).
- **Plan:** the tab bar with the plus button from CYLTabBarController's mini program package
  (`wechat-miniprogram-cyltabbar`, its `cyl-tab-bar` custom tab bar), one page per iOS screen, the example's own
  texts from `CYLScenarioExample.bundle` (7 languages), the same rows, buttons and behaviors. The refresh demos need a
  pull-to-refresh for mini programs (CYLRefresh is not ported yet); the plan for them is recorded once the spec of
  the iOS pages is done.

## 结构 / Structure

| Path (under `CrossPlatform/wechat-miniprogram-cylplaceholder/`) | Role |
| --- | --- |
| `src/cyl-placeholder/index.{js,json,wxml,wxss}` | The `cyl-placeholder` component (CYLPlaceholderStackView): vertical, centered stack; background tap; `action` event; `interactive` |
| `src/cyl-placeholder/cyl_scenario_catalog.js` | `CYLPlaceholderScenarioCatalog`, scenarios, categories, permissions, actions, button styles |
| `src/cyl-placeholder/cyl_localization.js` | `CYLPlaceholderLocalization`: `setLanguage`, `resolveLanguage`, `localizedString` |
| `src/cyl-placeholder/cyl_placeholder_hud.js` | `CYLPlaceholderHUD`: state and timing of the HUD, no rendering (unit-tested with fake timers) |
| `src/cyl-placeholder-hud/index.{js,json,wxml,wxss}` | The `cyl-placeholder-hud` component: renders a `CYLPlaceholderHUD` (`selectComponent('#hud').hud`); `action` and `touch` events |
| `src/cyl-placeholder/cyl_configuration.js` | `CYLPlaceholderConfiguration`: parses configuration objects / JSON files |
| `src/cyl-placeholder/cyl_status.js` | `CYLPlaceholderStatusDisplay`, `CYLPlaceholderStatus` (status bar and status configuration) |
| `src/cyl-placeholder-status/index.{js,json,wxml,wxss}` | The `cyl-placeholder-status` component (the red network bar; `LICENSE.CYLChatKit` at the package root) |
| `src/cyl-placeholder/cyl_images.js` | Generated icon list (validates a configuration's `style`) |
| `src/cyl-placeholder/animations/` | The 31 placeholder Lottie files of the iOS bundle, `NOTICE.animations`, licenses |
| `src/cyl-placeholder/no-animation/` | Default `animation` generic (no player) |
| `src/cyl-placeholder/cyl_placeholder.js` | Package entry exporting the catalog, the HUD, the configuration and the localization |
| `src/cyl-placeholder/locales/<locale>.json` (+ generated `.js` twin) | Strings of `android/placeholder` (7 languages, 108 keys) |
| `src/cyl-placeholder/images/*.png` | Icons of `android/placeholder` (52), licenses copied alongside |
| `scripts/import-android-resources.js` | Re-imports strings and icons from Android |
| `scripts/sync-example.js` | Copies both components into the example (DevTools `beforeCompile` hook) |
| `example/miniprogram` | Scenario list (grouped by category, language picker), a scenario page on an empty list (Retry reloads, interactive switch, "Load data on retry") and a HUD page (every HUD call, mask type and style pickers) |
| `example/miniprogram/configurations/` | The six example configuration files (copied from `android/merged/example`) |
| `test/catalog.test.js`, `test/hud.test.js`, `test/configuration.test.js` | `node --test` unit tests |

## API 对照 / API alignment

| iOS / Android | Mini program | Notes |
| --- | --- | --- |
| `CYLPlaceholderScenario` (35) | `CYLPlaceholderScenario` (string values = Kotlin names) | Same order |
| `CYLPlaceholderScenarioCatalog.componentsForScenario` | same name, returns plain objects | `type`: icon / text / hint / button / separator |
| `scenarioNamed`, `actionNamed`, `backgroundActionForScenario`, `categoryForScenario`, `permissionForScenario`, `scenarioForPermission`, `readmeScreenshotNumbersForScenario`, `localizedNameForScenario`, `localizedTitleForAction` | same names | Same behavior; tested |
| `CYLPlaceholderAction*` | same string values | Apps may pass their own strings |
| `CYLPlaceholderStackView` + action handlers | `<cyl-placeholder>` + `bind:action` | Handlers become one event with `{ action, scenario, index }` |
| `CYLPlaceholderStackView.interactive` | `interactive` property | |
| `CYLPlaceholderLocalization.language` | `CYLPlaceholderLocalization.setLanguage` or the `language` property | Falls back to the WeChat client language |
| `CYLPlaceholderHUD` `show`, `showWithStatus`, `showProgress(:status:)`, `setStatus`, `showInfo/Success/ErrorWithStatus`, `showImage`, `showScenario`, `showComponents`, `popActivity`, `dismiss(WithDelay)(completion)`, `visible`, `displayDurationForString`, `state`, `status`, `progress`, `activityCount`, `style`, `maskType`, `graceTimeInterval`, `minimum/maximumDismissTimeInterval`, `fadeIn/OutAnimationDuration` | same names on `selectComponent('#hud').hud` | Actions of components in the box arrive as the `action` event instead of an `actions` map |
| `animationFileNamesForScenario` | same name, plus `lottieFileNameForScenario` | Same lists as Kotlin; tested |
| Animated placeholder icons (Lottie / PAG / Rive / GIF players) | `animated`, `speed`, `loop` properties, `playAll()`, `generic:animation="cyl-lottie"` | Lottie only |
| `CYLPlaceholderStackView initWithConfiguration:` / `initWithContentsOfURL:`, Kotlin `fromConfiguration` / `fromContentsOfURL` | `<cyl-placeholder configuration="{{object or JSON string}}">`, `CYLPlaceholderConfiguration.parse(configuration, language)`, `readConfigurationFile(path)` | Errors: `configerror` event / thrown `CYLPlaceholderConfigurationError` with the Android messages; tap handlers stay in the page (`action` event) |
| `CYLPlaceholderComponent componentWithDictionary` | `CYLPlaceholderConfiguration.componentWithDictionary` | |
| `CYLPlaceholderStatusView` (`delegate` / `tapHandler`, `text`, `CYLPlaceholderStatusViewHeight`) | `<cyl-placeholder-status>` (`tappable` + `statustap`, `text`, `image`, `titleColor`, `backgroundColor`), `CYLPlaceholderStatusViewHeight` | The page places the bar |
| `cyl_statusDisplay`, `CYLPlaceholderStatusDisplay` | `CYLPlaceholderStatusDisplay`, `CYLPlaceholderStatus.showsStatusBar` / `showsPlaceholder` | The page binds `visible` and `wx:if` |
| `cyl_showsStatusViewWhenOffline` | `shows-when-offline` property, `networkchange` event | `wx.onNetworkStatusChange` |
| `cyl_applyStatusConfiguration`, `CYLPlaceholderStatusView fromConfiguration` | `CYLPlaceholderStatus.parseStatusConfiguration`, `statusBarFromConfiguration`, the bar's `configuration` property | Same keys and messages |

## 验证 / Verification

- 2026-11-15, Windows 11, Node 22.23.5: `npm test` passes 8 / 8: the scenario list matches the Kotlin enum; every
  scenario has components in all 7 languages, with every icon file present and every text resolved; the locale `.js`
  twins equal the `.json` tables; names, actions, categories, permissions, language tags; the wxml binds only
  handlers defined in `index.js`.
- 2026-11-15 12:14 (+13:00), commit `83c8bd0`, WeChat DevTools 2.02.2609250 simulator, base library 3.17.6:
  miniprogram-automator opened all 35 scenario pages and found the expected number of components on each; tapping
  Retry on RetryButton sent `CYLPlaceholderActionRetry (component 1)`, showed the Loading placeholder and returned.
  The simulator showed a stray backslash before apostrophes in the English texts (the importer had lost its regex
  backslashes); fixed in `83c8bd0` with a unit test (9 / 9 passed then). Screenshot:
  `docs/assets/wechat-miniprogram-example.png` (README section "WeChat Mini Program").
- 2026-11-15 12:29 (+13:00), commit `dfc0495`, same simulator: `npm test` passes 16 / 16 (7 HUD tests on fake timers:
  timed dismiss durations, cancelled dismiss, progress clamping, popActivity, grace time, scenario / components,
  mask). Tapping the HUD page's rows: "Downloading…" then "Almost done…" then dismissed; progress "Uploading 20%"
  then "Uploaded" then dismissed; showScenario(RetryButton) with the black mask shows 2 components and its Retry
  button sends `CYLPlaceholderActionRetry` (the page dismisses the HUD); the dark error HUD shows "Couldn't load".
  The simulator showed the HUD scenario box empty at first (a mini program turns a `null` Array property into `[]`,
  which replaced the scenario's components); fixed in `dfc0495`. Screenshot: `docs/assets/wechat-miniprogram-hud.png`.
- 2026-11-15 12:37 (+13:00), commit `f8089ef`, same simulator: `npm test` passes 17 / 17 (new: the file lists match
  the Kotlin `iconFiles`, every main icon carries a shipped Lottie file, the default generic exists). All 31 animated
  scenario pages render a `cyl-lottie` player with no console errors; on NoContent, speed 2 and loop off reach the
  lottie instance (`playSpeed` 2, `loop` false) and "Play all" restarts it (frame 387 → 9). Screenshot:
  `docs/assets/wechat-miniprogram-animation.png`. `fs.cpSync` crashed Node 22 on Windows (0xC0000409) when copying
  from the CYLTabBarController checkout; the sync script now copies file by file.
- 2026-11-15 13:03 (+13:00), commit `3e164da`, same simulator: `npm test` passes 24 / 24 (7 configuration tests: the
  six Android example files, overrides, background actions, styles / sizes / animations / repeat counts /
  interaction, item attributes and `titleKey`, every error message, no regex lookbehind in the sources). The
  configuration page rendered all six files with the expected components and no console errors; the dim button
  sent `CYLPlaceholderActionRetry`, the "interaction off" button sent nothing; in playback-policies the looping
  animation kept playing, the "once" one stopped on its last frame and the "3 times" one stopped after its third
  play; the raw item (`#rawItem`) sent `CYLPlaceholderActionContactSupport`. Screenshot:
  `docs/assets/wechat-miniprogram-configuration.png`.
- 2026-11-15 13:07 (+13:00), commit `2368eb0`, same simulator: `npm test` passes 27 / 27 (3 status tests: display
  flags, the default bar's localized text, bar dictionaries, `cyl_applyStatusConfiguration` rules and messages). The
  status page: the bar shows for All and StatusBar, hides for Placeholder and None, and the placeholder follows; a
  tap sends `statustap` only while tappable; with "shows when offline" on and display None, a simulated offline
  network event shows the bar and an online one hides it; the configuration gives the yellow bar with the Wi-Fi icon.
  A unit test caught `textKey` "CYLPlaceholderStatusNetworkUnavailable" not resolving (a missing camel-case rule);
  fixed before the commit. Screenshot: `docs/assets/wechat-miniprogram-status.png`. Not checked: the real network
  switch (simulated through the component's listener) and Dark Mode colors.
- Not verified: a real phone.
