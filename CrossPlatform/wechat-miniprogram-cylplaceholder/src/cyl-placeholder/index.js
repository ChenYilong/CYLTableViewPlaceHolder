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
    /**
     * true plays the main icon's Lottie file (CYLPlaceholderScenarioCatalog.lottieFileNameForScenario) instead of the
     * static icon. Needs a player: generic:animation="cyl-lottie" (cyl-lottie-miniprogram).
     */
    animated: { type: Boolean, value: false },
    /** Loops the animation (applied live). */
    loop: { type: Boolean, value: true },
    /** Animation speed, above 0 (applied live). */
    speed: { type: Number, value: 1 },
    /** The package path of the animations; empty uses this component's own `animations/` folder. */
    animationBase: { type: String, value: '' },
  },
  data: { items: [], _background: null, _scenario: null, hasBackgroundAction: false, animationFolder: '' },
  lifetimes: {
    attached() {
      // `this.is` is the component's package path ("components/cyl-placeholder/index"); lottie needs absolute paths.
      this.setData({ animationFolder: this.data.animationBase || '/' + this.is.replace(/[^/]*$/, '') + 'animations/' })
    },
  },
  observers: {
    'scenario, components, language, backgroundAction': function () {
      this.reload()
    },
    animationBase(base) {
      if (base) this.setData({ animationFolder: base })
    },
  },
  methods: {
    /** "Play all": restarts every animation of the placeholder from progress 0. */
    playAll() {
      this.selectAllComponents('.cyl-placeholder__animation').forEach((a) => a.cyl_playFromStart && a.cyl_playFromStart())
    },
    /** Rebuilds the stack, for example after CYLPlaceholderLocalization.setLanguage. */
    reload() {
      const scenario = CYLPlaceholderScenarioCatalog.scenarioNamed(this.data.scenario)
      const language = this.data.language || undefined
      // An Array property turns null into [], so an empty list means "use the scenario".
      const own = this.data.components
      const source = own && own.length ? own : (scenario ? CYLPlaceholderScenarioCatalog.componentsForScenario(scenario, language) : [])
      const items = source.map((c, index) => ({ ...c, index, tappable: !!c.action }))
      const background = this.data.backgroundAction || (scenario ? CYLPlaceholderScenarioCatalog.backgroundActionForScenario(scenario) : null)
      this.setData({ items, _background: background, _scenario: scenario, hasBackgroundAction: !!background })
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
