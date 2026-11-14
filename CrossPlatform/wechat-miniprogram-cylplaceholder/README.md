# cyl-placeholder-miniprogram

CYLTableViewPlaceHolder for WeChat Mini Program: the `cyl-placeholder` custom component with the 35 scenarios of
`CYLPlaceholderScenarioCatalog` (load failed, empty, permission, progress and success states), translated from the
Android module `android/placeholder` (itself the Kotlin port of the iOS library). Texts in English, Simplified
Chinese, Traditional Chinese, Japanese, Korean, Russian and Ukrainian.

## Usage

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

## Example

Open this folder (`CrossPlatform/wechat-miniprogram-cylplaceholder`) in WeChat DevTools. `project.config.json`
points `miniprogramRoot` at `example/miniprogram/` and its `beforeCompile` hook runs `node scripts/sync-example.js`,
which copies `src/cyl-placeholder` into the example (a mini program cannot load files outside its root). Run
`npm run sync-example` yourself if the hook is disabled. The project uses `touristappid`; set your own AppID to
preview on a phone.

## Development

- `npm test`: unit tests (`node --test`), including a check that the scenario list matches the Kotlin enum.
- `npm run import-android`: re-imports the icons and strings from `android/placeholder` after they change.

## License

MIT, see `LICENSE`. The icons in `src/cyl-placeholder/images` are copied unchanged from `android/placeholder` (file names without the `cyl_placeholder_` prefix) and keep their licenses: the Material Design icons listed in `NOTICE.material-design-icons` are Apache 2.0 (`LICENSE.material-design-icons`); `LICENSE.placeholder-third-party` covers the images from KLTableViewAndCollectionViewPlaceholder (MIT).
