// CYLRefreshIconListViewController: every refresh icon of the bundle by engine, then other ways to set an icon.
const { t } = require('../../utils/l10n')
const { SECTIONS } = require('./setups')

Page({
  data: { sections: [] },
  onLoad() {
    wx.setNavigationBarTitle({ title: t('CYLScenarioRefreshIcons') })
    this.setData({
      sections: SECTIONS.map((s) => ({
        title: s.titleKey ? t(s.titleKey) : s.title,
        rows: s.rows.map((r) => ({ id: r.id, title: r.titleKey ? t(r.titleKey) : r.title, subtitle: r.subtitle })),
      })),
    })
  },
  onOpen(e) {
    const { id, title } = e.currentTarget.dataset
    wx.navigateTo({ url: '/refresh-engines/refresh-icon-demo/refresh-icon-demo?setup=' + id + '&title=' + encodeURIComponent(title) })
  },
})
