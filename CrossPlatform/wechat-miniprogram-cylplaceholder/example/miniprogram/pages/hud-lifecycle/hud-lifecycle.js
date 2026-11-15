// CYLHUDLifecycleViewController: a page's whole life cycle with the library's components: the HUD while the first
// page loads, the RetryButton placeholder when it fails (the first attempt fails, the next succeeds), then pull down
// to refresh (items 1…15) and pull up to load more (+10 each, no more data at 45).
const { t } = require('../../utils/l10n')
const { later } = require('../../utils/page')
const { CYLPlaceholderAction } = require('../../components/cyl-placeholder/cyl_placeholder')
const { cylRefreshData, CYLRefreshMethods } = require('../flow-detail/refresh_control')

function range(from, to) {
  const list = []
  for (let i = from; i <= to; i++) list.push(i)
  return list
}

Page({
  ...CYLRefreshMethods,

  data: { rows: [], ...cylRefreshData() },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('CYLScenarioHUDSectionLifecycle') })
    this.items = []
    this.attempts = 0
    this.cancels = []
  },

  onReady() {
    // A HUD local to the page, with a minimum dismiss interval of 1 s.
    this.hud = this.selectComponent('#hud').hud
    this.hud.minimumDismissTimeInterval = 1
    this.loadFirstPage()
  },

  onUnload() {
    this.cancels.forEach((cancel) => cancel())
  },

  setItems(items) {
    this.items = items
    this.setData({ rows: items.map((n) => ({ id: n, title: t('CYLScenarioHUDLifecycleRow', n) })) })
  },

  /** The first attempt fails, the next succeeds, so every state of the cycle shows once. */
  loadFirstPage() {
    this.attempts += 1
    this.hud.showWithStatus(t('CYLScenarioHUDStatusLoading'))
    this.cancels.push(later(1500, () => {
      if (this.attempts === 1) {
        this.hud.showErrorWithStatus(t('CYLScenarioHUDStatusFailed'))
        this.setItems([])
      } else {
        this.hud.dismiss()
        this.setItems(range(1, 15))
      }
    }))
  },

  /** The placeholder's Retry. */
  onPlaceholderAction(e) {
    if (e.detail.action === CYLPlaceholderAction.Retry) this.loadFirstPage()
  },

  /** CYLRefreshNormalHeader: after 1 s items 1…15, end, reset no-more-data. */
  onHeaderRefresh() {
    this.cancels.push(later(1000, () => {
      this.setItems(range(1, 15))
      this.endHeaderRefreshing()
      this.resetFooterNoMoreData()
    }))
  },

  footerEnabled() {
    return this.items.length > 0
  },

  /** CYLRefreshAutoNormalFooter: after 1 s ten more items; no more data from 45. */
  onFooterRefresh() {
    this.cancels.push(later(1000, () => {
      const next = this.items.length + 1
      this.setItems(this.items.concat(range(next, next + 9)))
      if (this.items.length >= 45) this.endFooterRefreshingWithNoMoreData()
      else this.endFooterRefreshing()
    }))
  },
})
