// CYLRefreshStylesDemoViewController: CYLRefresh styles's demo, one page with a method per style.
// - styleDelivery: the Delivery header over 20 rows, refreshing once on open.
// - Header styles: theme rows + 8 test rows; the header refreshes on open and ends after 2.5 s.
// - Footer styles (no header): load more after 2.5 s doubles the test rows, 8 → 16 → 32 (no more data).
// - Theme rows color the control (colorPrimary / colorAccent) and the navigation bar, and refresh once.
// Every drawn style is a canvas renderer in styles/renderers (style-canvas hosts it in cyl-refresh's DIY slots).
// - The SVGA styles (styleSvga…, Task-Log "SVGA animations"): the scenes of scripts/make_svga_scenes.py played by
//   cyl-svga in the same slots; the pull scrubs the scene and refreshing loops it (SVGA has no state machine).
const { t } = require('../../utils/l10n')
const { CYLRefresh } = require('../../components/cyl-refresh/cyl_refresh')
const { RENDERERS } = require('./styles/renderers/index')

const DURATION = 2500
// UIColor.systemOrange / systemRed / systemGreen / systemBlue (light).
const THEMES = [
  { key: 'CYLScenarioRefreshStyleThemeOrange', primary: '#ff9500' },
  { key: 'CYLScenarioRefreshStyleThemeRed', primary: '#ff3b30' },
  { key: 'CYLScenarioRefreshStyleThemeGreen', primary: '#34c759' },
  { key: 'CYLScenarioRefreshStyleThemeBlue', primary: '#007aff' },
]
const FOOTER_STYLES = {
  styleBezierRadarFooter: 'BezierRadar',
  styleMaterialFooter: 'Material',
  styleDeliveryFooter: 'Delivery',
  stylePhoenixFooter: 'Phoenix',
  styleTaurusFooter: 'Taurus',
  styleRiveSpaceFooter: 'RiveSpace',
}

// The SVGA scenes (assets/animations, as *.svga.bin) and the height they open to (the files are 375 × 150).
const SVGA_SCENES = {
  styleSvgaBow: 'Bow', styleSvgaBubbles: 'Bubbles', styleSvgaHalloween: 'Halloween', styleSvgaSkating: 'Skating',
  styleSvgaSpace: 'Space', styleSvgaSquats: 'Squats', styleSvgaSpaceFooter: 'Space',
}
const SVGA_HEIGHT = 130

/** makeHeader / makeFooter: what cyl-refresh shows for a method. */
function setupFor(method) {
  if (SVGA_SCENES[method]) {
    const svga = '/assets/animations/CYLScenarioExampleRefresh' + SVGA_SCENES[method] + '.svga.bin'
    if (method === 'styleSvgaSpaceFooter') return { header: 'none', footer: 'diyBack', kind: 'svga', svga, headerHeight: 0, footerHeight: SVGA_HEIGHT, isFooter: true }
    return { header: 'diy', footer: 'none', kind: 'svga', svga, headerHeight: SVGA_HEIGHT, footerHeight: 0 }
  }
  if (method === 'styleClassicsFooter') return { header: 'none', footer: 'back', headerHeight: 0, footerHeight: 0, isFooter: true }
  if (FOOTER_STYLES[method]) {
    const kind = FOOTER_STYLES[method]
    return { header: 'none', footer: 'diyBack', kind, headerHeight: 0, footerHeight: RENDERERS[kind].height, isFooter: true }
  }
  if (method === 'styleClassics') return { header: 'normal', footer: 'none', headerHeight: 0, footerHeight: 0 }
  let kind = method.replace(/^style/, '')
  if (!RENDERERS[kind]) kind = 'Classics'
  if (kind === 'Classics') return { header: 'normal', footer: 'none', headerHeight: 0, footerHeight: 0 }
  return { header: 'diy', footer: 'none', kind, headerHeight: RENDERERS[kind].height, footerHeight: 0 }
}

/** The app's navigation bar colors (app.json, Dark Mode included): the saved appearance. */
function defaultBar() {
  let dark = false
  try {
    dark = (wx.getAppBaseInfo ? wx.getAppBaseInfo() : wx.getSystemInfoSync()).theme === 'dark'
  } catch (e) {}
  return dark ? { frontColor: '#ffffff', backgroundColor: '#000000' } : { frontColor: '#000000', backgroundColor: '#f2f2f7' }
}

Page({
  data: {
    setup: {},
    sections: [],
    primary: '',
    accent: '',
    headerStyle: null,
    footerStyle: null,
    contentBackground: '',
    hs: { state: 'Idle', percent: 0 },
    fs: { state: 'Idle', percent: 0 },
    noMoreText: '',
  },
  onLoad(query) {
    this.method = query.method || 'styleClassics'
    wx.setNavigationBarTitle({ title: decodeURIComponent(query.title || '') })
    const setup = setupFor(this.method)
    this.defaultPrimary = ''
    this.defaultAccent = ''
    if (this.method === 'styleDelivery') {
      // UIDeliveryController: the header over a plain list of 20 rows.
      this.setData({ setup, sections: [{ id: 's0', title: '', rows: this.testRows(20) }] })
      return
    }
    const restore = t('CYLScenarioRefreshStyleTapToRestore')
    const change = t('CYLScenarioRefreshStyleTapToSwitch')
    const themeRows = [{ id: 'default', title: t('CYLScenarioRefreshStyleThemeDefault'), detail: restore, action: 'default' }]
      .concat(THEMES.map((th, i) => ({ id: 'theme' + i, title: t(th.key), detail: change, action: String(i) })))
    this.setData({
      setup,
      sections: [{ id: 's0', title: '', rows: themeRows }, { id: 's1', title: t('CYLScenarioRefreshStyleTestData'), rows: this.testRows(8) }],
      noMoreText: CYLRefresh.stateText('backFooter', 'NoMoreData'),
    })
  },
  onReady() {
    // UIFlyController and UIWaveSwipeController open in the style's own blue.
    if (this.method === 'styleFly') this.applyTheme('#3399ff', '#ffffff', false)
    else if (this.method === 'styleWaveSwipe') {
      this.defaultPrimary = 'transparent'
      this.applyTheme('#007aff', '#ffffff', false)
    }
    if (!this.data.setup.isFooter) this.refresh().beginRefreshing()
  },
  onShow() {
    if (this.bar) wx.setNavigationBarColor(Object.assign({ animation: { duration: 0 } }, this.bar))
  },
  onHide() {
    this.restoreBar()
  },
  onUnload() {
    clearTimeout(this.timer)
    clearTimeout(this.moreTimer)
    this.restoreBar()
  },
  refresh() {
    return this.selectComponent('#refresh')
  },
  testRows(count) {
    return Array.from({ length: count }, (_, i) => ({ id: 'r' + (i + 1), title: t('CYLScenarioRefreshStyleTestDataRow', i + 1) }))
  },
  restoreBar() {
    wx.setNavigationBarColor(Object.assign({ animation: { duration: 0 } }, defaultBar()))
  },

  /** UIDemoHeaderController.changeTheme: colors the control and the navigation bar, and refreshes once. */
  applyTheme(primary, accent, refreshes = true) {
    const { setup } = this.data
    const isDefault = primary === this.defaultPrimary && accent === this.defaultAccent
    const plain = setup.header === 'normal' || setup.footer === 'back'
    const themed = !isDefault && primary && primary !== 'transparent'
    this.setData({
      primary,
      accent,
      // The classic controls: colorPrimary is their background (shown behind the pulled list), colorAccent their
      // labels. A back footer's box cannot be colored, so its label takes the primary color instead.
      contentBackground: plain && setup.header === 'normal' && themed ? primary : '',
      headerStyle: plain && setup.header === 'normal' && themed ? { stateColor: accent, timeColor: accent } : null,
      footerStyle: plain && setup.footer === 'back' && themed ? { color: primary } : null,
    })
    if (refreshes && setup.header !== 'none') this.refresh().beginRefreshing()
    if (!themed) {
      this.bar = null
      this.restoreBar()
      return
    }
    this.bar = { frontColor: '#ffffff', backgroundColor: primary }
    wx.setNavigationBarColor(Object.assign({ animation: { duration: 0 } }, this.bar))
  },

  onRow(e) {
    const action = e.currentTarget.dataset.action
    if (!action) return
    if (action === 'default') this.applyTheme(this.defaultPrimary, this.defaultAccent)
    else this.applyTheme(THEMES[+action].primary, '#ffffff')
  },
  onStateChange(e) {
    const { part, state, percent } = e.detail
    const key = part === 'header' ? 'hs' : 'fs'
    const cur = this.data[key]
    if (cur.state !== state || cur.percent !== percent) this.setData({ [key]: { state, percent } })
    if (this.data.setup.kind === 'svga') this.driveScene(part, state, percent)
  },
  /** The SVGA scene of `part`: scrubbed by the pull at rest, looping from the release until the control is idle. */
  driveScene(part, state, percent) {
    const scene = this.selectComponent('#svga-' + part)
    if (!scene) return
    this.scenePlays = this.scenePlays || {}
    this.scenes = this.scenes || {}
    if (this.scenes[part] !== scene) {
      // cyl-refresh mounts the slot when the control appears: cyl-svga measures its canvas when it loads, which can be
      // before the slot is laid out (a 1 px canvas). Load it again once the layout settled, then go on as asked.
      this.scenes[part] = scene
      this.scenePlays[part] = false
      setTimeout(() => {
        if (this.scenes[part] !== scene || typeof scene.cyl_load !== 'function') return
        scene.cyl_load()
        if (this.scenePlays[part]) scene.cyl_playFromStart()
      }, 120)
    }
    if (state === 'Refreshing' || state === 'WillRefresh') {
      if (!this.scenePlays[part]) {
        this.scenePlays[part] = true
        scene.cyl_playFromStart()
      }
      return
    }
    if (this.scenePlays[part] && state === 'Idle') {
      this.scenePlays[part] = false
      scene.cyl_stop()
    }
    if (!this.scenePlays[part]) scene.cyl_setProgress(Math.max(0, Math.min(1, percent || 0)))
  },
  /** UIDemoHeaderController.onRefresh: ends 2.5 seconds later. */
  onRefresh() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.refresh().endRefreshing(), DURATION)
  },
  /** UIDemoFooterController.onLoadMore: doubles the test rows, then reports no more data past 16 rows. */
  onLoadMore() {
    clearTimeout(this.moreTimer)
    this.moreTimer = setTimeout(() => {
      const last = this.data.sections.length - 1
      const count = this.data.sections[last].rows.length * 2
      this.setData({ ['sections[' + last + '].rows']: this.testRows(count) })
      if (count <= 16) this.refresh().endFooterRefreshing()
      else this.refresh().endRefreshingWithNoMoreData()
    }, DURATION)
  },
})
