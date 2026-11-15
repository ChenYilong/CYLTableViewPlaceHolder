// CYLStatusBarViewController: CYLChatKit's red network bar (cyl-placeholder-status) and the placeholder as two
// independent parts of the page. One display value chooses what shows (the bottom toolbar's segmented control):
// bar + placeholder (All), bar only (StatusBar, empty list), placeholder only (Placeholder), bar + list (StatusBar
// with 12 rows). "Network" makes the bar follow the network (shows while offline); "File" applies StatusBar/*.json.
const { t, showFeedback } = require('../../utils/l10n')
const {
  CYLPlaceholderAction,
  CYLPlaceholderConfiguration,
  CYLPlaceholderStatus,
  CYLPlaceholderStatusDisplay,
} = require('../../components/cyl-placeholder/cyl_placeholder')

const D = CYLPlaceholderStatusDisplay
/** Mode: title key and display, in the order of the segmented control. */
const MODES = [
  { key: 'CYLScenarioStatusModeBoth', display: D.All },
  { key: 'CYLScenarioStatusModeBar', display: D.StatusBar },
  { key: 'CYLScenarioStatusModePlaceholder', display: D.Placeholder },
  { key: 'CYLScenarioStatusModeList', display: D.StatusBar },
]
const BAR_AND_LIST = 3
/** StatusBar/*.json of the example bundle, sorted by name. */
const FILES = ['status-bar-and-placeholder.json', 'status-bar-only.json', 'status-bar-when-offline.json']

/** CYLPlaceholderNetworkMonitor nameForStatus: (not translated on iOS) for a wx network type. */
function networkStatusName(type) {
  switch (type) {
    case 'none': return 'not reachable'
    case 'wifi': return 'Wi-Fi'
    case '2g': case '3g': case '4g': case '5g': return 'cellular'
    case 'unknown': return 'unknown'
    default: return type ? 'other' : 'unknown'
  }
}

Page({
  data: {
    modes: [],
    mode: 0,
    showsBar: true,
    showsPlaceholder: true,
    showsWhenOffline: false,
    networkTitle: '',
    fileTitle: '',
    barConfiguration: null,
    rows: [],
  },

  onLoad() {
    wx.setNavigationBarTitle({ title: t('CYLScenarioTitleStatusBar') })
    this.setData({
      modes: MODES.map((m) => t(m.key)),
      networkTitle: t('CYLScenarioStatusFollowNetwork'),
      fileTitle: t('CYLScenarioActionShowFile'),
    })
    this.apply(0)
  },

  /** cyl_setStatusDisplay plus the rows of the mode. */
  apply(mode) {
    const display = MODES[mode].display
    const rows = []
    if (mode === BAR_AND_LIST) for (let i = 1; i <= 12; i++) rows.push({ id: i, title: t('CYLScenarioFormatItem', i) })
    this.setData({
      mode,
      rows,
      showsBar: CYLPlaceholderStatus.showsStatusBar(display),
      // The placeholder is the list's: it shows only while the list is empty.
      showsPlaceholder: CYLPlaceholderStatus.showsPlaceholder(display) && rows.length === 0,
    })
  },

  onModeTap(e) {
    this.apply(Number(e.currentTarget.dataset.index))
  },

  /** The NetworkUnavailable placeholder's retry. */
  onPlaceholderAction(e) {
    if (e.detail.action === CYLPlaceholderAction.Retry) showFeedback(t('CYLScenarioFeedbackReconnect'))
  },

  /** CYLPlaceholderStatusViewDelegate statusViewClicked: (CYLChatKit reconnects here). */
  onStatusTap() {
    showFeedback(t('CYLScenarioFeedbackReconnect'))
  },

  /** Toggles cyl_showsStatusViewWhenOffline, then shows the current network status. */
  toggleNetwork() {
    const showsWhenOffline = !this.data.showsWhenOffline
    this.setData({
      showsWhenOffline,
      networkTitle: t(showsWhenOffline ? 'CYLScenarioStatusFollowingNetwork' : 'CYLScenarioStatusFollowNetwork'),
    })
    wx.getNetworkType({
      success: (res) => showFeedback(t('CYLScenarioFormatNetworkStatus', networkStatusName(res.networkType))),
      fail: () => showFeedback(t('CYLScenarioFormatNetworkStatus', networkStatusName('unknown'))),
    })
  },

  /**
   * The action sheet of StatusBar/*.json. Its Cancel item is WeChat's own (in the WeChat language), so
   * CYLScenarioActionCancel cannot be applied.
   */
  showFiles() {
    wx.showActionSheet({
      itemList: FILES,
      success: (res) => this.applyFile(FILES[res.tapIndex]),
    })
  },

  /** cyl_applyStatusConfiguration(contentsOf:), then the segment that matches the new display. */
  applyFile(name) {
    let parsed
    let configuration
    try {
      configuration = CYLPlaceholderConfiguration.readConfigurationFile('/pages/status/StatusBar/' + name)
      parsed = CYLPlaceholderStatus.parseStatusConfiguration(configuration)
    } catch (e) {
      showFeedback(e.message)
      return
    }
    const bar = configuration.statusBar
    const update = {}
    // A dictionary styles the bar; true / "networkUnavailable" is the default bar; no key keeps the current bar.
    if (bar && typeof bar === 'object') update.barConfiguration = bar
    else if (bar != null && bar !== false) update.barConfiguration = null
    // As on iOS, the file changes the network option but not the "Network" button title.
    if (parsed.showsWhenOffline !== undefined) update.showsWhenOffline = parsed.showsWhenOffline
    this.setData(update)
    const mode = parsed.display === D.All ? 0 : parsed.display === D.StatusBar ? 1 : 2
    const display = parsed.display
    this.setData({
      mode,
      rows: [],
      showsBar: CYLPlaceholderStatus.showsStatusBar(display),
      showsPlaceholder: CYLPlaceholderStatus.showsPlaceholder(display),
    })
  },

  onStatusConfigError(e) {
    showFeedback(e.detail.message)
  },
})
