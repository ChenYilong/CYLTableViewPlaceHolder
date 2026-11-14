// cyl_placeholder_hud.js
// CYLPlaceholderHUD for WeChat Mini Program: the state and timing of android/placeholder's CYLPlaceholderHUD.kt (the
// SVProgressHUD-style API), with no rendering. The cyl-placeholder-hud component owns one and renders `viewState`.
'use strict'

const { CYLPlaceholderScenarioCatalog } = require('./cyl_scenario_catalog')

const CYLPlaceholderHUDState = Object.freeze({
  Hidden: 'Hidden',
  Loading: 'Loading',
  Progress: 'Progress',
  Success: 'Success',
  Error: 'Error',
  Info: 'Info',
  Image: 'Image',
  Custom: 'Custom',
})
const CYLPlaceholderHUDStyle = Object.freeze({ Automatic: 'Automatic', Light: 'Light', Dark: 'Dark' })
const CYLPlaceholderHUDMaskType = Object.freeze({ None: 'None', Clear: 'Clear', Black: 'Black', Gradient: 'Gradient' })

class CYLPlaceholderHUD {
  /**
   * @param {(viewState: object) => void} render called with the new view state on every change
   * @param {{ setTimeout?: Function, clearTimeout?: Function }} [timers] injectable timers (unit tests)
   */
  constructor(render, timers = {}) {
    this._render = render || (() => {})
    this._setTimeout = timers.setTimeout || setTimeout
    this._clearTimeout = timers.clearTimeout || clearTimeout
    this.state = CYLPlaceholderHUDState.Hidden
    this.status = ''
    this.progress = 0
    this.activityCount = 0
    this.components = null
    this.scenario = null
    this.image = ''
    this.style = CYLPlaceholderHUDStyle.Automatic
    this.maskType = CYLPlaceholderHUDMaskType.None
    /** Seconds a loading HUD waits before it shows, so a quick task shows none. */
    this.graceTimeInterval = 0
    this.minimumDismissTimeInterval = 1.5
    this.maximumDismissTimeInterval = 5
    this.fadeInAnimationDuration = 0.15
    this.fadeOutAnimationDuration = 0.15
    this._grace = null
    this._dismiss = null
  }

  get visible() {
    return this.state !== CYLPlaceholderHUDState.Hidden
  }

  /** How long a timed (success / error / info / image) HUD with this text stays, in seconds. */
  displayDurationForString(string) {
    const length = string ? String(string).length : 0
    return Math.min(Math.max(length * 0.06 + 0.5, this.minimumDismissTimeInterval), this.maximumDismissTimeInterval)
  }

  show() {
    this.showWithStatus(null)
  }

  showWithStatus(status) {
    this.activityCount++
    const start = () => {
      this._grace = null
      this._present(CYLPlaceholderHUDState.Loading, { status })
    }
    if (this.graceTimeInterval > 0 && !this.visible) {
      this._cancel('_grace')
      this._grace = this._setTimeout(start, this.graceTimeInterval * 1000)
    } else {
      start()
    }
  }

  /** Progress 0…1; a negative value is indeterminate (shown as loading with the status). */
  showProgress(progress, status) {
    if (progress < 0) return this._present(CYLPlaceholderHUDState.Loading, { status: status != null ? status : this.status })
    this.progress = Math.min(Math.max(progress, 0), 1)
    this._present(CYLPlaceholderHUDState.Progress, { status: status != null ? status : this.status })
  }

  /** Changes the text without restarting the animation. */
  setStatus(status) {
    this.status = status || ''
    this._emit()
  }

  showInfoWithStatus(status) {
    this._showTimed(CYLPlaceholderHUDState.Info, 'info', status)
  }

  showSuccessWithStatus(status) {
    this._showTimed(CYLPlaceholderHUDState.Success, 'success', status)
  }

  showErrorWithStatus(status) {
    this._showTimed(CYLPlaceholderHUDState.Error, 'error', status)
  }

  /** `image`: an image path, shown with the status, then dismissed after displayDurationForString. */
  showImage(image, status) {
    this._showTimed(CYLPlaceholderHUDState.Image, image, status)
  }

  /** Shows a scenario of CYLPlaceholderScenarioCatalog in the box; its components keep their tap actions. */
  showScenario(scenario) {
    const s = CYLPlaceholderScenarioCatalog.scenarioNamed(scenario)
    this._present(CYLPlaceholderHUDState.Custom, { status: '', scenario: s, components: null })
  }

  /** Shows the app's own components in the box. */
  showComponents(components) {
    this._present(CYLPlaceholderHUDState.Custom, { status: '', scenario: null, components: components || [] })
  }

  /** Ends one showWithStatus; the HUD goes when the last one ends. */
  popActivity() {
    if (this.activityCount > 0) this.activityCount--
    if (this.activityCount === 0) this.dismiss()
  }

  dismiss(completion) {
    this.dismissWithDelay(0, completion)
  }

  dismissWithDelay(delay, completion) {
    this._cancel('_dismiss')
    this._cancel('_grace')
    this._dismiss = this._setTimeout(() => {
      this._dismiss = null
      this.activityCount = 0
      this.state = CYLPlaceholderHUDState.Hidden
      this._emit()
      if (completion) completion()
    }, (delay || 0) * 1000)
  }

  /** The data the component renders. */
  get viewState() {
    return {
      visible: this.visible,
      state: this.state,
      status: this.status || '',
      progress: this.progress,
      percent: Math.round(this.progress * 100),
      image: this.image,
      scenario: this.scenario || '',
      components: this.components,
      style: this.style,
      maskType: this.maskType,
      blocksTouches: this.visible && this.maskType !== CYLPlaceholderHUDMaskType.None,
      fadeIn: this.fadeInAnimationDuration,
      fadeOut: this.fadeOutAnimationDuration,
    }
  }

  _showTimed(state, image, status) {
    this.activityCount = 0
    this._cancel('_grace')
    this._present(state, { status, image })
    this._dismiss = this._setTimeout(() => this.dismiss(), this.displayDurationForString(status) * 1000)
  }

  _present(state, { status, image = '', scenario = null, components = null }) {
    this._cancel('_dismiss')
    this.state = state
    this.status = status || ''
    this.image = image
    this.scenario = scenario
    this.components = components
    this._emit()
  }

  _cancel(key) {
    if (this[key]) {
      this._clearTimeout(this[key])
      this[key] = null
    }
  }

  _emit() {
    this._render(this.viewState)
  }
}

module.exports = { CYLPlaceholderHUD, CYLPlaceholderHUDState, CYLPlaceholderHUDStyle, CYLPlaceholderHUDMaskType }
