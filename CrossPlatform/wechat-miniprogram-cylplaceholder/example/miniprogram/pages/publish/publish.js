// CYLPublishViewController (the plus button's page): the Uploading scenario, then Success after 1.5 s; Done closes it.
// The iOS page is presented modally with a Close button; the mini program's back button closes it.
const { t } = require('../../utils/l10n')
const { CYLPlaceholderAction } = require('../../components/cyl-placeholder/cyl_placeholder')

Page({
  data: { done: false },
  onLoad() {
    wx.setNavigationBarTitle({ title: t('CYLScenarioActionPublish') })
    this.timer = setTimeout(() => this.setData({ done: true }), 1500)
  },
  onUnload() {
    clearTimeout(this.timer)
  },
  onAction(e) {
    if (e.detail.action === CYLPlaceholderAction.Done) wx.navigateBack()
  },
})
