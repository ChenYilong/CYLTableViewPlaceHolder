// CYLRefreshTestViewController: a blank page with "Close" (dismisses if presented, pops if pushed).
const { t } = require('../../utils/l10n')

Page({
  data: { close: '' },
  onLoad() {
    wx.setNavigationBarTitle({ title: t('CYLScenarioMJTestTitle') })
    this.setData({ close: t('CYLScenarioMJClose') })
  },
  onClose() {
    wx.navigateBack()
  },
})
