// cyl-placeholder: CYLPlaceholderStackView for WeChat Mini Program. Renders the components of a scenario of
// CYLPlaceholderScenarioCatalog (or an app's own `components`) in a vertical, centered stack.
//
// <cyl-placeholder scenario="RetryButton" bind:action="onPlaceholderAction" />
//
// Events: `action` with detail { action, scenario, index } (index is -1 for a tap on the background).
//
// Every icon is a cyl-animated-item (CYLTabBarController's CYLAnimatedItem for mini programs, copied into
// src/cyl-animated-item): the animation once its engine is ready, else the static icon, else the placeholder. Engines
// come from the page through the abstract nodes `animation` (Lottie, e.g. generic:animation="cyl-lottie"),
// `cyl-pag-view`, `cyl-rive-view` and `cyl-svga-view`; without one the static icon stays.
'use strict'

const { CYLPlaceholderScenarioCatalog } = require('./cyl_scenario_catalog')
const { CYLPlaceholderConfiguration } = require('./cyl_configuration')
const { cylResolvePath } = require('./cyl_animated_icon')


Component({
  options: { pureDataPattern: /^_/ },
  // Inside a cyl-refresh, the refresh hides its load-more footer while this placeholder shows.
  relations: {
    '../cyl-refresh/index': { type: 'ancestor' },
  },
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
    /** The folder of the icons, for icons an app ships elsewhere (relative to this component, or absolute). */
    imageBase: { type: String, value: './images/' },
    /**
     * true plays the main icon's animation file (CYLPlaceholderScenarioCatalog.lottieFileNameForScenario, or a
     * component's `animation`) instead of the static icon, once its engine is ready. Needs an engine through the
     * abstract nodes: generic:animation="cyl-lottie" (cyl-lottie-miniprogram) for Lottie, generic:cyl-pag-view,
     * generic:cyl-rive-view, generic:cyl-svga-view for PAG / Rive / SVGA files; GIF needs none. Without one, or when the
     * file fails, the static icon stays.
     */
    animated: { type: Boolean, value: false },
    /**
     * Loops the animation (true) or plays it once (false), applied live. Unset (null): each bundled animation plays
     * once and rests on its last frame, and a spinner loops (iOS componentWithBundledAnimation:, e8e9eb6, 2026-11-19;
     * CYLPlaceholderScenarioCatalog.animationLoopsByDefault).
     */
    loop: { type: null, value: null },
    /** Animation speed, above 0 (applied live). */
    speed: { type: Number, value: 1 },
    /**
     * A number that plays every animation again from progress 0 each time it grows (the name of
     * CYLTabBarController's `animationRestartToken` / `restartToken`), next to `restartAnimation()`. The value at
     * creation is not a restart; a lower value is not one either.
     */
    restartToken: { type: Number, value: 0 },
    /** The package path of the animations; empty uses this component's own `animations/` folder. */
    animationBase: { type: String, value: '' },
    /**
     * A CYLPlaceholderConfiguration (object or JSON string); when set it replaces scenario / components /
     * backgroundAction. An invalid one renders nothing and sends `configerror` with { message }.
     */
    configuration: { type: null, value: null },
  },
  data: { items: [], _background: null, _scenario: null, hasBackgroundAction: false, animationFolder: '', imageFolder: '' },
  lifetimes: {
    attached() {
      // `this.is` is the component's package path ("components/cyl-placeholder/index"). cyl-animated-item draws the
      // files from its own folder and the engines need absolute paths, so both folders become absolute.
      this.cylRestartToken = this.data.restartToken
      this.setData({
        animationFolder: this.data.animationBase || cylResolvePath('./animations/', this.is),
        imageFolder: cylResolvePath(this.data.imageBase, this.is),
      })
    },
  },
  observers: {
    'scenario, components, language, backgroundAction, configuration': function () {
      this.reload()
    },
    animationBase(base) {
      if (base) this.setData({ animationFolder: base })
    },
    restartToken(token) {
      // [EN] The value at creation is the baseline (set in `attached`); only a larger one restarts. [CN] 创建时的值为基准（在 `attached` 中设置）；只有更大的值才重播。
      const last = this.cylRestartToken
      this.cylRestartToken = token
      if (last === undefined || !(Number(token) > Number(last))) return
      this.restartAnimation()
    },
    imageBase(base) {
      if (this.is) this.setData({ imageFolder: cylResolvePath(base, this.is) })
    },
  },
  methods: {
    /** "Play all": restarts every animation of the placeholder from progress 0. */
    playAll() {
      this._plays = {}
      this.data.items.forEach((item, index) => {
        const engine = this._engineAt(index)
        if (engine && engine.cyl_playFromStart) engine.cyl_playFromStart()
      })
    },
    /**
     * Plays every animation of the placeholder again from progress 0: the same as `playAll()`, under the name
     * CYLTabBarController's `CYLAnimatedItemView` and the iOS / Android placeholder stack views use.
     */
    restartAnimation() {
      this.playAll()
    },
    /**
     * The engine component inside the cyl-animated-item of item `index` (cyl-lottie, cyl-pag, … or the
     * cyl-animation-placeholder default), or null while it shows no animation.
     */
    _engineAt(index) {
      const item = this.selectComponent('#cyl-animated-' + index)
      return (item && item.selectComponent('.cyl-animated-item-animation')) || null
    },
    /** Rebuilds the stack, for example after CYLPlaceholderLocalization.setLanguage. */
    reload() {
      const language = this.data.language || undefined
      let scenario = CYLPlaceholderScenarioCatalog.scenarioNamed(this.data.scenario)
      let source
      let background
      if (this.data.configuration) {
        try {
          const parsed = CYLPlaceholderConfiguration.parse(this.data.configuration, language)
          scenario = parsed.scenario
          source = parsed.components
          background = parsed.backgroundAction
        } catch (e) {
          this.setData({ items: [], _background: null, _scenario: null, hasBackgroundAction: false })
          this.triggerEvent('configerror', { message: e.message })
          return
        }
      } else {
        // An Array property turns null into [], so an empty list means "use the scenario".
        const own = this.data.components
        source = own && own.length ? own : (scenario ? CYLPlaceholderScenarioCatalog.componentsForScenario(scenario, language) : [])
        background = this.data.backgroundAction || (scenario ? CYLPlaceholderScenarioCatalog.backgroundActionForScenario(scenario) : null)
      }
      const items = source.map((c, index) => {
        const enabled = c.interactionEnabled !== false
        const highlight = c.highlightStyle || 'dim'
        return {
          ...c,
          index,
          tappable: !!c.action && enabled,
          hoverClass: !enabled || highlight === 'none' ? 'none' : 'cyl-placeholder--pressed-' + highlight,
          // repeatCount: undefined follows the `loop` property (unset: once, spinners loop); 0 loops; N plays N times
          // (replayed on `complete`).
          ownLoop: c.repeatCount === undefined ? null : c.repeatCount === 0,
          defaultLoop: !!c.animation && CYLPlaceholderScenarioCatalog.animationLoopsByDefault(c.animation),
        }
      })
      this._plays = {}
      this.setData({ items, _background: background, _scenario: scenario, hasBackgroundAction: !!background })
    },
    /**
     * repeatCount N (above 1) replays the animation until it has played N times: such an item does not loop, so its
     * cyl-animated-item sends `animationcomplete` after every pass (CYLTabBarController 59a1cb0f).
     */
    onAnimationComplete(e) {
      const index = Number(e.currentTarget.dataset.index)
      const item = this.data.items[index]
      if (!item || !(item.repeatCount > 1)) return
      this._plays[index] = (this._plays[index] || 1) + 1
      const engine = this._engineAt(index)
      if (this._plays[index] <= item.repeatCount && engine && engine.cyl_playFromStart) engine.cyl_playFromStart()
    },
    onItemTap(e) {
      const index = Number(e.currentTarget.dataset.index)
      const item = this.data.items[index]
      if (!this.data.interactive || !item || !item.tappable) return
      this.triggerEvent('action', { action: item.action, scenario: this.data._scenario, index })
    },
    onBackgroundTap() {
      if (!this.data.interactive || !this.data._background) return
      this.triggerEvent('action', { action: this.data._background, scenario: this.data._scenario, index: -1 })
    },
  },
})
