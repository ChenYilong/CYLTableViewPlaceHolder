// CYLRefreshExampleViewController: the menu of CYLRefresh demos. The list itself has a normal header (alpha follows
// the pull) and a back footer, each ending after 2 s.
const { t } = require('../../utils/l10n')
const { showTab } = require('../../utils/page')
const { SECTIONS } = require('./menu')

// Leaf pages that exist so far; the others are being ported (docs/WeChat-MiniProgram.md).
const READY = ['refresh-table']

Page({
  data: { sections: [] },
  onLoad() {
    this.setData({
      sections: SECTIONS.map((s) => ({
        title: t(s.key),
        rows: s.rows.map((r) => ({ title: t(r.key), subtitle: r.vc + ' - ' + r.method, page: r.page, method: r.method, vc: r.vc })),
      })),
    })
  },
  onShow() {
    showTab(this, 'refresh')
  },
  onUnload() {
    clearTimeout(this.timer)
  },
  onOpen(e) {
    const { page, method, title, vc } = e.currentTarget.dataset
    if (READY.indexOf(page) < 0) {
      wx.showToast({ title: 'Not ported yet', icon: 'none' })
      return
    }
    wx.navigateTo({ url: '/pages/' + page + '/' + page + '?method=' + method + '&vc=' + vc + '&title=' + encodeURIComponent(title) })
  },
  onRefresh() {
    this.timer = setTimeout(() => this.selectComponent('#refresh').endRefreshing(), 2000)
  },
  onLoadMore() {
    this.timer = setTimeout(() => this.selectComponent('#refresh').endFooterRefreshing(), 2000)
  },
})
