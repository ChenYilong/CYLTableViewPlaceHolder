// One scenario on an empty list, like CYLTableViewPlaceHolder: the placeholder shows while the list is empty; Retry
// "reloads" (a short loading state, then the empty state again, or rows when "Load data on retry" is on).
const { CYLPlaceholderScenarioCatalog, CYLPlaceholderAction } = require('../../components/cyl-placeholder/cyl_placeholder')

Page({
  data: { scenario: '', language: '', rows: [], loading: false, interactive: true, loadOnRetry: false, lastAction: '' },
  onLoad(query) {
    const scenario = CYLPlaceholderScenarioCatalog.scenarioNamed(query.scenario) || 'NoContent'
    const language = getApp().globalData.language || ''
    this.setData({ scenario, language })
    wx.setNavigationBarTitle({ title: CYLPlaceholderScenarioCatalog.localizedNameForScenario(scenario, language || undefined) })
  },
  onUnload() {
    clearTimeout(this.timer)
  },
  onPlaceholderAction(e) {
    const { action, index } = e.detail
    this.setData({ lastAction: action + (index < 0 ? ' (background)' : ' (component ' + index + ')') })
    if (action === CYLPlaceholderAction.Retry) return this.reload()
    if (action === CYLPlaceholderAction.OpenSettings) return wx.openSetting({ fail: () => {} })
    const language = this.data.language || undefined
    wx.showToast({ title: CYLPlaceholderScenarioCatalog.localizedTitleForAction(action, language) || action, icon: 'none' })
  },
  reload() {
    this.setData({ loading: true })
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      const rows = this.data.loadOnRetry ? Array.from({ length: 12 }, (_, i) => 'Row ' + (i + 1)) : []
      this.setData({ loading: false, rows })
    }, 800)
  },
  onClear() {
    this.setData({ rows: [] })
  },
  onInteractiveChange(e) {
    this.setData({ interactive: e.detail.value })
  },
  onLoadOnRetryChange(e) {
    this.setData({ loadOnRetry: e.detail.value })
  },
})
