// The HUD page: every CYLPlaceholderHUD call, a mask type and a style picker.
const { CYLPlaceholderHUDMaskType, CYLPlaceholderHUDStyle } = require('../../components/cyl-placeholder/cyl_placeholder')

const MASKS = Object.values(CYLPlaceholderHUDMaskType)
const STYLES = Object.values(CYLPlaceholderHUDStyle)

Page({
  data: { masks: MASKS, maskIndex: 0, styles: STYLES, styleIndex: 0, lastEvent: '' },
  onReady() {
    this.hud = this.selectComponent('#hud').hud
  },
  onUnload() {
    clearInterval(this.progressTimer)
  },
  apply() {
    this.hud.maskType = MASKS[this.data.maskIndex]
    this.hud.style = STYLES[this.data.styleIndex]
  },
  onMask(e) {
    this.setData({ maskIndex: Number(e.detail.value) })
  },
  onStyle(e) {
    this.setData({ styleIndex: Number(e.detail.value) })
  },
  onLoading() {
    this.apply()
    this.hud.show()
    setTimeout(() => this.hud.dismiss(), 2000)
  },
  onStatus() {
    this.apply()
    this.hud.showWithStatus('Downloading…')
    setTimeout(() => this.hud.setStatus('Almost done…'), 1200)
    setTimeout(() => this.hud.dismiss(), 2400)
  },
  onProgress() {
    this.apply()
    clearInterval(this.progressTimer)
    let p = 0
    this.hud.showProgress(0, 'Uploading')
    this.progressTimer = setInterval(() => {
      p += 0.1
      if (p >= 1) {
        clearInterval(this.progressTimer)
        this.hud.showSuccessWithStatus('Uploaded')
      } else {
        this.hud.showProgress(p)
      }
    }, 250)
  },
  onSuccess() {
    this.apply()
    this.hud.showSuccessWithStatus('Saved')
  },
  onError() {
    this.apply()
    this.hud.showErrorWithStatus("Couldn't load")
  },
  onInfo() {
    this.apply()
    this.hud.showInfoWithStatus('Pull down to refresh')
  },
  onScenario() {
    this.apply()
    this.hud.showScenario('RetryButton')
  },
  onActivities() {
    this.apply()
    this.hud.showWithStatus('Task 1 of 2')
    this.hud.showWithStatus('Task 2 of 2')
    setTimeout(() => this.hud.popActivity(), 1000)
    setTimeout(() => this.hud.popActivity(), 2000)
  },
  onHUDAction(e) {
    this.setData({ lastEvent: 'action ' + e.detail.action })
    this.hud.dismiss()
  },
  onHUDTouch(e) {
    this.setData({ lastEvent: 'mask tapped while ' + e.detail.state })
  },
})
