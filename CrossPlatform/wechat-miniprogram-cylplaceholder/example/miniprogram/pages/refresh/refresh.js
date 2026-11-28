// CYLRefreshExampleViewController: the menu of CYLRefresh demos. The list itself has a normal header (alpha follows
// the pull) and a back footer, each ending after 2 s.
const { t } = require('../../utils/l10n')
const { showTab } = require('../../utils/page')
const { SECTIONS } = require('./menu')

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
    // The demos live in the refresh-demos subpackage (the main package is limited to 2 MB).
    wx.navigateTo({ url: '/refresh-demos/' + page + '/' + page + '?method=' + method + '&vc=' + vc + '&title=' + encodeURIComponent(title) })
  },
  onRefresh() {
    this.timer = setTimeout(() => this.selectComponent('#refresh').endRefreshing(), 2000)
  },
  onLoadMore() {
    this.timer = setTimeout(() => this.selectComponent('#refresh').endFooterRefreshing(), 2000)
  },
})
