// CYLRefreshIconDemoViewController: 15 rows; the header ends after 1.5 s; the footer adds 15 up to 45, then
// "No more data". The bar's Refresh button starts the header in code (beginRefreshing).
const { t } = require('../../utils/l10n')
const { setupFor } = require('../refresh-icons/setups')

Page({
  data: { setup: {}, rows: [], hint: '' },
  onLoad(query) {
    const row = setupFor(query.setup)
    wx.setNavigationBarTitle({ title: decodeURIComponent(query.title || '') })
    this.setData({ setup: row ? row.setup : { header: 'normal', footer: 'auto' }, rows: this.rows(15), hint: t('CYLScenarioTextRefreshHint') })
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
