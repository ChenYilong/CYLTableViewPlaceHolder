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

### TODO: WeChat Mini Program placeholder package (score 0 → in progress)

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
     the 36 scenarios of `CYLPlaceholderScenarioCatalog` (translated from `android/placeholder`'s
     `CYLPlaceholderScenario.kt`): icon / title / hint / button / separator components, background tap action,
     `action` event with the `CYLPlaceholderAction*` names, `interactive` switch.
  2. Localization from the Android strings (en, zh-Hans, zh-Hant, ja, ko, ru, uk) into `locales/*.json`.
  3. Example app (`example/miniprogram`): a scenario list page and a page showing each scenario on an empty list.
  4. `node --test` unit tests for the catalog and the localization.
  5. Open the example with the DevTools skill (`project_import`, `open_project_window`, `simulator_screenshot`),
     store the screenshot in `docs/`, update the README.
- **Blocked:** the DevTools CLI authorization (`wechatide auth -c Claude`) times out; `wechatidecli islogin` returns
  `{"login":false}`, so the DevTools login must be renewed first.

## 结构 / Structure

TODO: filled in when the package lands.

## API 对照 / API alignment

TODO: filled in when the package lands.

## 验证 / Verification

TODO: filled in when the package lands.
