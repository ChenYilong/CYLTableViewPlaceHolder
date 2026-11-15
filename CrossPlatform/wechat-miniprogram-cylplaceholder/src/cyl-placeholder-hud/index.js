// cyl-placeholder-hud: CYLPlaceholderHUD for WeChat Mini Program. Put one in a page and drive it like SVProgressHUD:
//
// <cyl-placeholder-hud id="hud" bind:action="onHUDAction" />
// const hud = this.selectComponent('#hud').hud
// hud.showWithStatus('Loading…'); … hud.showSuccessWithStatus('Done') / hud.dismiss()
//
// Events: `action` (a component in the box was tapped, detail as cyl-placeholder's), `touch` (the mask was tapped).
'use strict'

const { CYLPlaceholderHUD } = require('../cyl-placeholder/cyl_placeholder_hud')
const { localizedString } = require('../cyl-placeholder/cyl_localization')

Component({
  properties: {
    /** Language of the default "Loading…" text; empty follows CYLPlaceholderLocalization. */
    language: { type: String, value: '' },
  },
  data: { view: { visible: false }, shown: false, defaultStatus: '' },
  lifetimes: {
    created() {
      this.hud = new CYLPlaceholderHUD((view) => this._render(view), { vibrate: () => wx.vibrateShort({ type: 'medium' }) })
    },
    attached() {
      this.setData({ defaultStatus: localizedString('scenario_h_u_d_title', this.data.language || undefined) })
    },
    detached() {
      clearTimeout(this._fadeTimer)
      this.hud.dismiss()
    },
  },
  methods: {
    _render(view) {
      clearTimeout(this._fadeTimer)
      const wasVisible = !!this.data.view.visible
      if (view.visible) {
        this.setData({ view, shown: true })
        // CYLPlaceholderHUDDidAppearNotification / DidDisappearNotification as events.
        if (!wasVisible) this.triggerEvent('appear', { state: view.state })
      } else {
        // Keep the box while it fades out.
        this.setData({ 'view.visible': false })
        this._fadeTimer = setTimeout(() => {
          this.setData({ shown: false })
          if (wasVisible) this.triggerEvent('disappear', {})
        }, view.fadeOut * 1000)
      }
    },
    onAction(e) {
      this.triggerEvent('action', e.detail)
    },
    onMaskTap() {
      this.triggerEvent('touch', { state: this.hud.state })
    },
    noop() {},
  },
})
