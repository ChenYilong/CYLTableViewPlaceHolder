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

/** How long the component waits for an engine to load a file with a repeat count (40 tries, 250 ms apart). */
const CYL_REPEAT_HOOK_TRIES = 40
const CYL_REPEAT_HOOK_INTERVAL = 250

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
    /** Loops the animation (applied live). */
    loop: { type: Boolean, value: true },
    /** Animation speed, above 0 (applied live). */
    speed: { type: Number, value: 1 },
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
      this.setData({
        animationFolder: this.data.animationBase || cylResolvePath('./animations/', this.is),
        imageFolder: cylResolvePath(this.data.imageBase, this.is),
      })
    },
    detached() {
      clearTimeout(this._repeatTimer)
    },
  },
  observers: {
    'scenario, components, language, backgroundAction, configuration': function () {
      this.reload()
    },
    animationBase(base) {
      if (base) this.setData({ animationFolder: base })
    },
    imageBase(base) {
      if (this.is) this.setData({ imageFolder: cylResolvePath(base, this.is) })
    },
    animated() {
      this._hookRepeats()
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
     * The engine component inside the cyl-animated-item of item `index` (cyl-lottie, cyl-pag, … or the
     * cyl-animation-placeholder default), or null while it shows no animation.
     */
    _engineAt(index) {
      const item = this.selectComponent('#cyl-animated-' + index)
      return (item && item.selectComponent('.cyl-animated-item-animation')) || null
    },
    /**
     * repeatCount N (above 1) replays the animation until it has played N times. cyl-animated-item does not forward
     * the engine's `complete` event, so the component listens on the engine's animation object
     * (`cyl_animation()`, lottie-web's `addEventListener('complete')`) once the engine has loaded the file.
     */
    _hookRepeats() {
      clearTimeout(this._repeatTimer)
      if (!this.data.animated) return
      const pending = this.data.items.map((item, index) => ({ item, index })).filter(({ item }) => item.animation && item.repeatCount > 1)
      if (!pending.length) return
      let tries = 0
      const attempt = () => {
        let waiting = false
        for (const { index } of pending) {
          const engine = this._engineAt(index)
          const animation = engine && typeof engine.cyl_animation === 'function' ? engine.cyl_animation() : null
          if (!animation || typeof animation.addEventListener !== 'function') {
            waiting = true
          } else if (!animation.__cylPlaceholderRepeat) {
            animation.__cylPlaceholderRepeat = true
            animation.addEventListener('complete', () => this._onAnimationComplete(index))
          }
        }
        if (waiting && ++tries < CYL_REPEAT_HOOK_TRIES) this._repeatTimer = setTimeout(attempt, CYL_REPEAT_HOOK_INTERVAL)
      }
      this._repeatTimer = setTimeout(attempt, 0)
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
          // repeatCount: undefined follows the `loop` property; 0 loops; N plays N times (replayed on `complete`).
          ownLoop: c.repeatCount === undefined ? null : c.repeatCount === 0,
        }
      })
      this._plays = {}
      this.setData({ items, _background: background, _scenario: scenario, hasBackgroundAction: !!background }, () => this._hookRepeats())
    },
    /** Replays an animation with repeatCount N until it has played N times. */
    _onAnimationComplete(index) {
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
