# cyl-placeholder-miniprogram

CYLTableViewPlaceHolder for WeChat Mini Program: the `cyl-placeholder` custom component with the 35 scenarios of
`CYLPlaceholderScenarioCatalog` (load failed, empty, permission, progress and success states), translated from the
Android module `android/placeholder` (itself the Kotlin port of the iOS library). Texts in English, Simplified
Chinese, Traditional Chinese, Japanese, Korean, Russian and Ukrainian.

## Install with npm

```bash
npm install cyl-placeholder-miniprogram
```

Then run WeChat DevTools' 工具 → 构建 npm (Tools → Build npm). The components land in
`miniprogram_npm/cyl-placeholder-miniprogram`:

```json
{
  "usingComponents": {
    "cyl-placeholder": "cyl-placeholder-miniprogram/cyl-placeholder/index",
    "cyl-placeholder-hud": "cyl-placeholder-miniprogram/cyl-placeholder-hud/index",
    "cyl-placeholder-status": "cyl-placeholder-miniprogram/cyl-placeholder-status/index",
    "cyl-refresh": "cyl-placeholder-miniprogram/cyl-refresh/index",
    "cyl-refresh-trailer": "cyl-placeholder-miniprogram/cyl-refresh/trailer/index"
  }
}
```

Every refresh component lives in `cyl-refresh/` (the trailer in `cyl-refresh/trailer/`).

```js
const { CYLPlaceholderAction, CYLRefresh } = require('cyl-placeholder-miniprogram')
```

Verified with `npm pack` → `npm install <tarball>` → 构建 npm in WeChat DevTools 2.02.2609250 (base library 3.17.6):
all five components and the `require` entry load with no error.

## Usage (copied components)

```json
{ "usingComponents": { "cyl-placeholder": "/components/cyl-placeholder/index" } }
```

```html
<cyl-placeholder wx:if="{{!rows.length}}" scenario="RetryButton" bind:action="onPlaceholderAction" />
```

```js
const { CYLPlaceholderAction } = require('/components/cyl-placeholder/cyl_placeholder')

Page({
  onPlaceholderAction(e) {
    if (e.detail.action === CYLPlaceholderAction.Retry) this.reload()
  },
})
```

Installed from npm (`npm i cyl-placeholder-miniprogram`, then DevTools > Tools > Build npm), the components are
`cyl-placeholder-miniprogram/cyl-placeholder/index` (and `…/cyl-placeholder-hud/index`, `…/cyl-placeholder-status/index`,
`…/cyl-refresh/index`) and the same API is `require('cyl-placeholder-miniprogram')`.

| Property | Type | Default | Meaning |
| --- | --- | --- | --- |
| `scenario` | String | `''` | A scenario name (`RetryButton` or `CYLPlaceholderScenarioRetryButton`) |
| `components` | Array | `null` | Your own components; replaces the scenario's (same shape as `componentsForScenario`) |
| `language` | String | `''` | `en`, `zh-Hans`, `zh-Hant`, `ja`, `ko`, `ru`, `uk`; empty follows `CYLPlaceholderLocalization.setLanguage`, then the WeChat language |
| `interactive` | Boolean | `true` | `false` ignores every tap |
| `backgroundAction` | String | `''` | Action of a tap on the background; empty uses the scenario's own |
| `imageBase` | String | `'./images/'` | Folder of the icons |

Event `action`: `detail = { action, scenario, index }`, `index` is `-1` for a background tap. Actions are the
`CYLPlaceholderAction*` strings of iOS and Android (`CYLPlaceholderActionRetry`, `…ContactSupport`, `…OpenSettings`,
`…GoShopping`, `…Done`, `…ChooseManually`).

## Configuration files

`CYLPlaceholderConfiguration` builds a placeholder from a configuration object or JSON file, with the keys of iOS and
Android (see `docs/Placeholder-Scenarios.md`, "Configuration files"):

```js
const { CYLPlaceholderConfiguration } = require('/components/cyl-placeholder/cyl_placeholder')
this.setData({ configuration: CYLPlaceholderConfiguration.readConfigurationFile('/configurations/ctrip.json') })
```

```html
<cyl-placeholder configuration="{{configuration}}" bind:action="onAction" bind:configerror="onConfigError" />
```

```json
{
  "scenario": "RetryOrContactSupport",
  "overrides": [{ "index": 1, "highlightStyle": "shrink" }, { "index": 3, "interactionEnabled": false }]
}
```

Top-level keys: `scenario`, `components`, `overrides`, `backgroundAction` (`""` turns it off),
`accessibilityIdentifier`. Component keys: `type` (`icon`, `hint`, `button`, `separator`, `item`), `title` / `text`
or `titleKey` / `textKey`, `animation`, `style` (an icon name such as `WifiOff`), `size`, `buttonStyle`, `action`,
`interactionEnabled`, `highlightStyle` (`dim`, `shrink`, `none`), `repeatCount` (`"loop"`, `"once"`, N),
`spacingBefore`, `accessibilityIdentifier` (the element's `id`), `attributes` (`item`: title color, background
color, corner radius, content insets, minimum width). An invalid configuration renders nothing and sends
`configerror` with the reason; `CYLPlaceholderConfiguration.parse` throws it instead.

## Animations

31 scenarios have a Lottie file for their main icon (`CYLPlaceholderScenarioCatalog.lottieFileNameForScenario`),
shipped in `src/cyl-placeholder/animations`. The package has no player of its own; plug one in through the
`animation` generic, for example `cyl-lottie` from
[cyl-lottie-miniprogram](https://github.com/ChenYilong/CYLTabBarController/tree/master/CrossPlatform/lottie-miniprogram):

```json
{ "usingComponents": { "cyl-lottie": "cyl-lottie-miniprogram/cyl-lottie/index" } }
```

```html
<cyl-placeholder id="placeholder" scenario="EmptyCart" generic:animation="cyl-lottie"
                 animated loop="{{loop}}" speed="{{speed}}" />
```

`animated` switches between the animation and the static icon; `loop` and `speed` apply live;
`this.selectComponent('#placeholder').playAll()` restarts every animation from frame 0. Any player with `path`,
`loop`, `speed`, `autoplay` properties and a `cyl_playFromStart()` method works.

## HUD

`cyl-placeholder-hud` is `CYLPlaceholderHUD` (the SVProgressHUD-style loading box) for mini programs:

```html
<cyl-placeholder-hud id="hud" bind:action="onHUDAction" />
```

```js
onReady() {
  this.hud = this.selectComponent('#hud').hud
},
load() {
  this.hud.showWithStatus('Loading…')
  request().then(() => this.hud.dismiss(), () => this.hud.showErrorWithStatus("Couldn't load"))
},
```

Calls: `show`, `showWithStatus`, `showProgress(progress, status)` (negative = indeterminate), `setStatus`,
`showSuccessWithStatus` / `showErrorWithStatus` / `showInfoWithStatus` / `showImage(path, status)` (dismissed after
`displayDurationForString`), `showScenario(name)` / `showComponents(list)` (their buttons send the `action` event),
`popActivity`, `dismiss(completion)`, `dismissWithDelay(seconds, completion)`. Properties: `style` (`Automatic`,
`Light`, `Dark`), `maskType` (`None`, `Clear`, `Black`, `Gradient`; any but `None` blocks touches and sends `touch`
when tapped), `graceTimeInterval`, `minimumDismissTimeInterval`, `maximumDismissTimeInterval`,
`fadeInAnimationDuration`, `fadeOutAnimationDuration`; read-only `visible`, `state`, `status`, `progress`,
`activityCount`.

## Status bar

`cyl-placeholder-status` is `CYLPlaceholderStatusView`, the red "network unavailable" bar of CYLChatKit. Put it at
the top of the page, above the list:

```html
<cyl-placeholder-status visible="{{showsBar}}" shows-when-offline tappable bind:statustap="onStatusTap" />
<cyl-placeholder wx:if="{{showsPlaceholder}}" scenario="NetworkUnavailable" />
```

```js
const { CYLPlaceholderStatus, CYLPlaceholderStatusDisplay } = require('/components/cyl-placeholder/cyl_placeholder')
const display = CYLPlaceholderStatusDisplay.All // StatusBar, Placeholder, None
this.setData({ showsBar: CYLPlaceholderStatus.showsStatusBar(display), showsPlaceholder: CYLPlaceholderStatus.showsPlaceholder(display) })
```

Properties: `visible`, `showsWhenOffline` (watches `wx.onNetworkStatusChange`, sends `networkchange`), `tappable`
(sends `statustap`), `text`, `image`, `titleColor`, `backgroundColor`, `language`, `configuration` (a `statusBar`
dictionary). `CYLPlaceholderStatus.parseStatusConfiguration` reads `statusBar`, `display` and `showsWhenOffline` of a
configuration file. The bar's icon and design come from CYLChatKit (MIT, `LICENSE.CYLChatKit`).

## Example

Open this folder (`CrossPlatform/wechat-miniprogram-cylplaceholder`) in WeChat DevTools. `project.config.json`
points `miniprogramRoot` at `example/miniprogram/` and its `beforeCompile` hook runs `node scripts/sync-example.js`,
which copies both components into the example (a mini program cannot load files outside its root). Run
`npm run sync-example` yourself if the hook is disabled. The script also copies the example's Lottie player
from a CYLTabBarController checkout: `CYL_TABBAR_DIR`, else `../CYLTabBarController` next to this repository. DevTools refuses the committed `touristappid`: put your own
AppID in `project.private.config.json` (git-ignored), for example `{ "appid": "wx…" }`.

## Development

- `npm test`: unit tests (`node --test`), including a check that the scenario list matches the Kotlin enum.
- `npm run import-android`: re-imports the icons and strings from `android/placeholder` after they change.

## License

MIT, see `LICENSE`. The icons in `src/cyl-placeholder/images` are copied unchanged from `android/placeholder` (file names without the `cyl_placeholder_` prefix) and keep their licenses: the Material Design icons listed in `NOTICE.material-design-icons` are Apache 2.0 (`LICENSE.material-design-icons`); `LICENSE.placeholder-third-party` covers the images from KLTableViewAndCollectionViewPlaceholder (MIT). The Lottie
files in `src/cyl-placeholder/animations` come unchanged from the iOS bundle; `NOTICE.animations` there names each
file's source (lottie-ios, Apache 2.0, `LICENSE.lottie-ios`; react-useanimations, MIT, `LICENSE.useanimations`).
It also lists the PAG / Rive / GIF files of the iOS bundle, which this package does not ship.
