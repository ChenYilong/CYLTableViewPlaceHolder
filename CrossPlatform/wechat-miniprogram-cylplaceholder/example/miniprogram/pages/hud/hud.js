// CYLHUDViewController: the HUD style of the placeholder (cyl-placeholder-hud, SVProgressHUD's API). "Show" rows call
// one API each, "Look" rows cycle the style, mask, loading animation and haptics (then preview), the last row pushes
// the page life cycle. minimumDismissTimeInterval = 1.5; leaving the page stops the progress timer and dismisses.
const { t } = require('../../utils/l10n')
const {
  CYLPlaceholderScenarioCatalog,
  CYLPlaceholderHUDStyle,
  CYLPlaceholderHUDMaskType,
} = require('../../components/cyl-placeholder/cyl_placeholder')

/** Styles and their value keys; Custom is a white foreground on a teal box, as iOS. */
const STYLES = [
  [CYLPlaceholderHUDStyle.Automatic, 'CYLScenarioHUDStyleAutomatic'],
  [CYLPlaceholderHUDStyle.Light, 'CYLScenarioHUDStyleLight'],
  [CYLPlaceholderHUDStyle.Dark, 'CYLScenarioHUDStyleDark'],
  [CYLPlaceholderHUDStyle.Custom, 'CYLScenarioHUDStyleCustom'],
]
/** Mask types; Custom is systemTeal at 0.3 (backgroundLayerColor), as iOS. */
const MASKS = [
  [CYLPlaceholderHUDMaskType.None, 'CYLScenarioHUDMaskNone'],
  [CYLPlaceholderHUDMaskType.Clear, 'CYLScenarioHUDMaskClear'],
  [CYLPlaceholderHUDMaskType.Black, 'CYLScenarioHUDMaskBlack'],
  [CYLPlaceholderHUDMaskType.Gradient, 'CYLScenarioHUDMaskGradient'],
  [CYLPlaceholderHUDMaskType.Custom, 'CYLScenarioHUDStyleCustom'],
]
/** The loading animations that suit the HUD: the scenario's own GIF first, then Lottie, PAG and Rive. */
const ANIMATIONS = CYLPlaceholderScenarioCatalog.animationFileNamesForScenario('HUD')
/** The package path of a Lottie loading animation, or '' (GIF: the HUD's own spinner GIF; PAG / Rive: no player). */
const lottiePath = (name) => (/\.json$/.test(name) ? '/assets/animations/' + name : '')

/** Row identifier, title key and section (0 Show, 1 Look, 2 Page life cycle). */
const ROWS = [
  ['show', 'CYLScenarioHUDShow', 0],
  ['showStatus', 'CYLScenarioHUDShowStatus', 0],
  ['showProgress', 'CYLScenarioHUDShowProgress', 0],
  ['success', 'CYLScenarioHUDShowSuccess', 0],
  ['error', 'CYLScenarioHUDShowError', 0],
  ['info', 'CYLScenarioHUDShowInfo', 0],
  ['image', 'CYLScenarioHUDShowImage', 0],
  ['components', 'CYLScenarioHUDShowComponents', 0],
  ['scenario', 'CYLScenarioHUDShowScenario', 0],
  ['popActivity', 'CYLScenarioHUDPopActivity', 0],
  ['dismiss', 'CYLScenarioHUDDismiss', 0],
  ['style', 'CYLScenarioHUDStyle', 1],
  ['mask', 'CYLScenarioHUDMask', 1],
  ['animation', 'CYLScenarioHUDAnimation', 1],
  ['haptics', 'CYLScenarioHUDHaptics', 1],
  ['lifecycle', 'CYLScenarioHUDLifecycle', 2],
]
const SECTION_KEYS = ['CYLScenarioHUDSectionShow', 'CYLScenarioHUDSectionLook', 'CYLScenarioHUDSectionLifecycle']
const CANCEL = 'cancel'

Page({
  data: { sections: [] },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('CYLScenarioTitleHUD') })
    this.styleIndex = 0
    this.maskIndex = 0
    this.animationIndex = 0
    this.hapticsEnabled = false
    this.timers = []
    this.render()
  },

  onReady() {
    this.hud = this.selectComponent('#hud').hud
    this.hud.minimumDismissTimeInterval = 1.5
    // The Custom style and mask colors of the iOS page: white on systemTeal, systemTeal at 0.3.
    this.hud.foregroundColor = '#ffffff'
    this.hud.hudBackgroundColor = '#30b0c7'
    this.hud.backgroundLayerColor = 'rgba(48, 176, 199, 0.3)'
  },

  /** viewWillDisappear: also when the life cycle page is pushed. */
  onHide() {
    this.stopProgress()
    if (this.hud) this.hud.dismiss()
  },

  onUnload() {
    this.stopProgress()
    this.timers.forEach(clearTimeout)
    if (this.hud) this.hud.dismiss()
  },

  value(id) {
    switch (id) {
      case 'style': return t(STYLES[this.styleIndex][1])
      case 'mask': return t(MASKS[this.maskIndex][1])
      case 'animation': return ANIMATIONS[this.animationIndex] || ''
      case 'haptics': return this.hapticsEnabled ? '✓' : '–'
      default: return ''
    }
  },

  render() {
    const sections = SECTION_KEYS.map((key, section) => ({
      header: t(key),
      rows: ROWS.filter((r) => r[2] === section).map(([id, titleKey]) => ({
        id,
        title: t(titleKey),
        value: this.value(id),
        disclosure: id === 'lifecycle',
      })),
    }))
    this.setData({ sections })
  },

  onRowTap(e) {
    const id = e.currentTarget.dataset.id
    const hud = this.hud
    if (!hud) return
    this.stopProgress()
    switch (id) {
      case 'show':
        hud.show()
        hud.dismissWithDelay(2)
        break
      case 'showStatus':
        hud.showWithStatus(t('CYLScenarioHUDStatusLoading'))
        hud.dismissWithDelay(2)
        break
      case 'showProgress':
        this.showProgress()
        break
      case 'success':
        this.showSuccess(t('CYLScenarioHUDStatusSaved'))
        break
      case 'error':
        hud.showErrorWithStatus(t('CYLScenarioHUDStatusFailed'))
        break
      case 'info':
        hud.showInfoWithStatus(t('CYLScenarioHUDStatusInfo'))
        break
      case 'image':
        // The core's `.cloud` icon.
        hud.showImage('/components/cyl-placeholder/images/cloud.png', t('CYLScenarioHUDStatusImage'))
        break
      case 'components':
        this.showComponents()
        break
      case 'scenario':
        hud.showScenario('Uploading')
        hud.dismissWithDelay(2)
        break
      case 'popActivity':
        // Three tasks start; the HUD stays until the last one ends.
        for (let i = 0; i < 3; i++) hud.showWithStatus(t('CYLScenarioHUDStatusLoading'))
        ;[1000, 2000, 3000].forEach((ms) => this.timers.push(setTimeout(() => hud.popActivity(), ms)))
        break
      case 'dismiss':
        hud.dismiss()
        break
      case 'style':
        this.styleIndex = (this.styleIndex + 1) % STYLES.length
        this.applyStyle()
        this.showPreview()
        break
      case 'mask':
        this.maskIndex = (this.maskIndex + 1) % MASKS.length
        this.applyMask()
        this.showPreview()
        break
      case 'animation':
        if (!ANIMATIONS.length) return
        this.animationIndex = (this.animationIndex + 1) % ANIMATIONS.length
        // loadingAnimationFileName: Lottie files play; the GIF is the HUD's own spinner; PAG / Rive have no player.
        hud.loadingAnimationFileName = lottiePath(ANIMATIONS[this.animationIndex])
        this.showPreview()
        break
      case 'haptics':
        this.hapticsEnabled = !this.hapticsEnabled
        hud.hapticsEnabled = this.hapticsEnabled
        this.showSuccess(t('CYLScenarioHUDStatusSaved'))
        break
      case 'lifecycle':
        wx.navigateTo({ url: '/pages/hud-lifecycle/hud-lifecycle' })
        break
    }
    this.render()
  },

  applyStyle() {
    this.hud.style = STYLES[this.styleIndex][0]
  },

  applyMask() {
    this.hud.maskType = MASKS[this.maskIndex][0]
  },

  showSuccess(status) {
    this.hud.showSuccessWithStatus(status)
  },

  /** Shows the loading HUD for a moment, so a changed look can be seen. */
  showPreview() {
    this.hud.showWithStatus(t('CYLScenarioHUDStatusLoading'))
    this.hud.dismissWithDelay(1.5)
  },

  /** A progress from 0 to 1 in two seconds (+0.05 every 0.1 s), then success. */
  showProgress() {
    let progress = 0
    const status = t('CYLScenarioHUDStatusDownloading')
    this.hud.showProgress(0, status)
    this.progressTimer = setInterval(() => {
      progress += 0.05
      if (progress >= 1 - 1e-9) {
        this.stopProgress()
        this.showSuccess(t('CYLScenarioHUDStatusSaved'))
      } else {
        this.hud.showProgress(progress, status)
      }
    }, 100)
  },

  stopProgress() {
    if (this.progressTimer) clearInterval(this.progressTimer)
    this.progressTimer = null
  },

  /** The HUD scenario's components plus an outlined "Cancel" button with the action "cancel". */
  showComponents() {
    const components = CYLPlaceholderScenarioCatalog.componentsForScenario('HUD').concat([
      { type: 'button', title: t('CYLScenarioHUDCancel'), style: 'Outlined', action: CANCEL },
    ])
    this.hud.showComponents(components)
  },

  onHUDAction(e) {
    if (e.detail.action === CANCEL) this.hud.showInfoWithStatus(t('CYLScenarioHUDCancelled'))
  },
})
