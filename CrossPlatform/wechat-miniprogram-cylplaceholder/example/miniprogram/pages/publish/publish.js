// CYLPublishViewController (the plus button's page): the Uploading scenario, then Success after 1.5 s; Done closes it.
// The iOS page is presented modally with a Close button; the mini program's back button closes it.
// `successStartedAt` (page data, Date.now() once Success is rendered) lets scripts/success-timing-screenshots.js label
// each screenshot with its exact seconds after Success started.
const { t } = require('../../utils/l10n')
const { CYLPlaceholderAction } = require('../../components/cyl-placeholder/cyl_placeholder')

Page({
  data: { done: false, successStartedAt: 0 },
  onLoad() {
    wx.setNavigationBarTitle({ title: t('CYLScenarioActionPublish') })
    this.timer = setTimeout(() => {
      this.setData({ done: true }, () => this.setData({ successStartedAt: Date.now() }))
    }, 1500)
  },
  onUnload() {
    clearTimeout(this.timer)
  },
  onAction(e) {
    if (e.detail.action === CYLPlaceholderAction.Done) wx.navigateBack()
  },
})
