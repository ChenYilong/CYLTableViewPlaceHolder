// CYLRefreshIconDemoViewController: 15 rows; the header ends after 1.5 s; the footer adds 15 up to 45, then
// "No more data". The bar's Refresh button starts the header in code (beginRefreshing).
const { t, effectiveLanguage } = require('../../utils/l10n')
const { setupFor } = require('../refresh-icons/setups')

Page({
  // The default setup from the start: an empty one passed null header / footer to cyl-refresh's String properties.
  data: { setup: { header: 'normal', footer: 'auto' }, rows: [], hint: '', language: '', speed: 1, loop: true },
  onLoad(query) {
    const row = setupFor(query.setup)
    wx.setNavigationBarTitle({ title: decodeURIComponent(query.title || '') })
    this.setData({ setup: row ? row.setup : { header: 'normal', footer: 'auto' }, rows: this.rows(15), hint: t('CYLScenarioTextRefreshHint'), language: effectiveLanguage() })
  },
  // Playback controls (docs/Example-Animation-Playback.md): Play all restarts the state icons; speed and loop live.
  onPlayAll() {
    const refresh = this.selectComponent('#refresh')
    if (refresh) refresh.playIconsFromStart()
  },
  onSpeedChange(e) {
    this.setData({ speed: e.detail.speed })
  },
  onLoopChange(e) {
    this.setData({ loop: e.detail.loop })
  },
  onUnload() {
    clearTimeout(this.timer)
  },
  rows(n) {
    return Array.from({ length: n }, (_, i) => t('CYLScenarioFormatItem', i + 1))
  },
  refresh() {
    return this.selectComponent('#refresh')
  },
  onBegin() {
    this.refresh().beginRefreshing()
  },
  onRefresh() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this.setData({ rows: this.rows(15) })
      const refresh = this.refresh()
      refresh.endRefreshing()
      refresh.resetNoMoreData()
    }, 1500)
  },
  onLoadMore() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      const refresh = this.refresh()
      if (this.data.rows.length >= 45) return refresh.endRefreshingWithNoMoreData()
      this.setData({ rows: this.rows(this.data.rows.length + 15) })
      refresh.endFooterRefreshing()
    }, 1500)
  },
})
