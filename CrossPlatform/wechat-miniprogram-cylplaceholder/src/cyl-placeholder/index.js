// cyl-placeholder: CYLPlaceholderStackView for WeChat Mini Program. Renders the components of a scenario of
// CYLPlaceholderScenarioCatalog (or an app's own `components`) in a vertical, centered stack.
//
// <cyl-placeholder scenario="RetryButton" bind:action="onPlaceholderAction" />
//
// Events: `action` with detail { action, scenario, index } (index is -1 for a tap on the background).
'use strict'

const { CYLPlaceholderScenarioCatalog } = require('./cyl_scenario_catalog')

Component({
  options: { pureDataPattern: /^_/ },
  properties: {
    /** A CYLPlaceholderScenario name ("RetryButton", "CYLPlaceholderScenarioRetryButton"). */
    scenario: { type: String, value: '' },
    /** The app's own components; a non-empty list replaces the scenario's components. */
    components: { type: Array, value: null },
    /** A language of CYLPlaceholderLocalization ("en", "zh-Hans", …); empty follows the system and setLanguage. */
    language: { type: String, value: '' },
    /** false ignores every tap (CYLPlaceholderStackView.interactive). */
    interactive: { type: Boolean, value: true },
    /** The action of a tap on the background; empty uses the scenario's own (backgroundActionForScenario). */
    backgroundAction: { type: String, value: '' },
    /** true drops the minimum height and padding (inside a HUD box or a small container). */
    compact: { type: Boolean, value: false },
    /** The folder of the icons, for icons an app ships elsewhere. */
    imageBase: { type: String, value: './images/' },
  },
  data: { items: [], _background: null, _scenario: null },
  observers: {
    'scenario, components, language, backgroundAction': function () {
      this.reload()
    },
  },
  methods: {
    /** Rebuilds the stack, for example after CYLPlaceholderLocalization.setLanguage. */
    reload() {
      const scenario = CYLPlaceholderScenarioCatalog.scenarioNamed(this.data.scenario)
      const language = this.data.language || undefined
      // An Array property turns null into [], so an empty list means "use the scenario".
      const own = this.data.components
      const source = own && own.length ? own : (scenario ? CYLPlaceholderScenarioCatalog.componentsForScenario(scenario, language) : [])
      const items = source.map((c, index) => ({ ...c, index, tappable: !!c.action }))
      const background = this.data.backgroundAction || (scenario ? CYLPlaceholderScenarioCatalog.backgroundActionForScenario(scenario) : null)
      this.setData({ items, _background: background, _scenario: scenario })
    },
    onItemTap(e) {
      const index = Number(e.currentTarget.dataset.index)
      const item = this.data.items[index]
      if (!this.data.interactive || !item || !item.action) return
      this.triggerEvent('action', { action: item.action, scenario: this.data._scenario, index })
    },
    onBackgroundTap() {
      if (!this.data.interactive || !this.data._background) return
      this.triggerEvent('action', { action: this.data._background, scenario: this.data._scenario, index: -1 })
    },
  },
})
