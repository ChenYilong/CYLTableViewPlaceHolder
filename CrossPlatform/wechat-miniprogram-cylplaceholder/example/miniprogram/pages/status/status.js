// The status bar page: CYLPlaceholderStatusView above an empty list with the NetworkUnavailable placeholder;
// cyl_statusDisplay, cyl_showsStatusViewWhenOffline, a tappable bar and a status configuration.
const { CYLPlaceholderStatus, CYLPlaceholderStatusDisplay } = require('../../components/cyl-placeholder/cyl_placeholder')

const DISPLAYS = Object.values(CYLPlaceholderStatusDisplay)
// A configuration as in the iOS / Android examples: a custom bar, both bar and placeholder, shown while offline.
const CONFIGURATION = {
  statusBar: { textKey: 'CYLPlaceholderStatusNetworkUnavailable', backgroundColor: '#FFE8A3', titleColor: '#5C4400', image: 'wifi_off' },
  display: 'statusAndPlaceholder',
  showsWhenOffline: true,
}

Page({
  data: {
    displays: DISPLAYS, displayIndex: 0, showsBar: true, showsPlaceholder: true, showsWhenOffline: false, tappable: true,
    barConfiguration: null, language: '', lastEvent: '', configurationText: JSON.stringify(CONFIGURATION, null, 2),
  },
  onLoad() {
    this.setData({ language: getApp().globalData.language || '' })
  },
  applyDisplay(display) {
    this.setData({
      displayIndex: DISPLAYS.indexOf(display),
      showsBar: CYLPlaceholderStatus.showsStatusBar(display),
      showsPlaceholder: CYLPlaceholderStatus.showsPlaceholder(display),
    })
  },
  onDisplay(e) {
    this.applyDisplay(DISPLAYS[Number(e.detail.value)])
  },
  onOffline(e) {
    this.setData({ showsWhenOffline: e.detail.value })
  },
  onTappable(e) {
    this.setData({ tappable: e.detail.value })
  },
  onApplyConfiguration() {
    try {
      const status = CYLPlaceholderStatus.parseStatusConfiguration(CONFIGURATION, this.data.language || undefined)
      this.applyDisplay(status.display)
      this.setData({ barConfiguration: CONFIGURATION.statusBar, lastEvent: 'configuration applied' })
      if (status.showsWhenOffline !== undefined) this.setData({ showsWhenOffline: status.showsWhenOffline })
    } catch (e) {
      this.setData({ lastEvent: e.message })
    }
  },
  onReset() {
    this.setData({ barConfiguration: null, lastEvent: 'default bar' })
    this.applyDisplay(CYLPlaceholderStatusDisplay.All)
  },
  onStatusTap() {
    this.setData({ lastEvent: 'status bar tapped' })
    wx.showToast({ title: 'Status bar tapped', icon: 'none' })
  },
  onNetworkChange(e) {
    this.setData({ lastEvent: 'network ' + (e.detail.offline ? 'offline' : 'online') })
  },
})
