// CYLFeedViewController: loading, then 15 posts; every other refresh fails and shows the RetryButton scenario; load
// more adds 15 up to 30, then "No more data". Header: an icon per state; footer: an auto footer with a GIF.
const { t } = require('../../utils/l10n')
const { showTab } = require('../../utils/page')
const { CYLPlaceholderAction } = require('../../components/cyl-placeholder/cyl_placeholder')

const A = '/assets/animations/'
// CYLRefreshAnimationHeader: idle PullArrow 28, pulling Clockwise 28, refreshing CYLPlaceholderProgress.pag 32
// (no PAG player in the mini program: the header shows its spinner for that state).
const HEADER_ICONS = {
  Idle: { path: A + 'CYLRefreshPullArrow.json', size: 28 },
  Pulling: { path: A + 'CYLRefreshClockwise.json', size: 28 },
  Refreshing: { path: A + 'CYLPlaceholderProgress.pag', size: 32 },
}
// CYLRefreshAutoAnimationFooter: refreshing Ring.gif 28.
const FOOTER_ICONS = { Refreshing: { path: A + 'CYLRefreshRing.gif', size: 28 } }

Page({
  data: { rows: [], loading: true, headerIcons: HEADER_ICONS, footerIcons: FOOTER_ICONS, hint: '', refreshIconsLabel: '' },
  onLoad() {
    this.refreshCount = 0
    this.setData({ hint: t('CYLScenarioTextFeedHint'), refreshIconsLabel: t('CYLScenarioRefreshIcons') })
    this.loadFirstPage()
  },
  onShow() {
    showTab(this, 'feed')
  },
  onUnload() {
    clearTimeout(this.timer)
  },
  refresh() {
    return this.selectComponent('#refresh')
  },
  rows(n) {
    return Array.from({ length: n }, (_, i) => t('CYLScenarioFormatPost', i + 1))
  },
  /** First load: Loading scenario, then 15 rows after 2 s. */
  loadFirstPage() {
    this.setData({ loading: true, rows: [] })
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this.setData({ loading: false, rows: this.rows(15) })
      this.refresh().resetNoMoreData()
    }, 2000)
  },
  /** Pull to refresh: after 1 s, odd refreshes fail (0 rows → Retry), even ones give 15 rows. */
  onRefresh() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this.refreshCount += 1
      this.setData({ loading: false, rows: this.refreshCount % 2 === 1 ? [] : this.rows(15) })
      const refresh = this.refresh()
      refresh.resetNoMoreData()
      refresh.endRefreshing()
    }, 1000)
  },
  /** Load more: after 1 s, +15 until 30, then no more data. */
  onLoadMore() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      const refresh = this.refresh()
      if (this.data.rows.length >= 30) return refresh.endRefreshingWithNoMoreData()
      this.setData({ rows: this.rows(this.data.rows.length + 15) })
      refresh.endFooterRefreshing()
    }, 1000)
  },
  onPlaceholderAction(e) {
    if (e.detail.action === CYLPlaceholderAction.Retry) this.loadFirstPage()
  },
  onRefreshIcons() {
    wx.navigateTo({ url: '/pages/refresh-icons/refresh-icons' })
  },
})
