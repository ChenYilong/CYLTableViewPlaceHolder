// CYLRefreshWKWebViewController (example40 and example41): pull down to reload a web page.
//
// A mini program <web-view> covers the whole page, cannot host a pull-to-refresh header or overlays, and only loads
// the business domains configured for the AppID (github.com is not one). So this page is native: the navigation bar
// is hidden (navigationStyle "custom"), a cyl-refresh with the ExampleImagesHeader (GIF frames, auto transparency)
// wraps a scrollable rendering of the page iOS loads (https://github.com/CoderMJLee/MJRefresh), and a pull "reloads"
// it: the header ends when the simulated load finishes (didFinish). The warning label and the red back button sit at
// the bottom right as on iOS. 40 and 41 differ only in the order of chained calls on iOS, so they look the same.
const { t } = require('../../utils/l10n')

const A = '/assets/animations/'
const URL = 'https://github.com/CoderMJLee/MJRefresh'
/** How long the simulated page load takes. */
const LOAD_TIME = 1200
const icon = (name, size) => ({ path: A + name, size })
// CYLRefreshExampleImagesHeader: Arrows.gif frames for idle, Ring.gif frames for pulling and refreshing.
const IMAGES_HEADER = { Idle: icon('CYLRefreshArrows.gif', 40), Pulling: icon('CYLRefreshRing.gif', 40), Refreshing: icon('CYLRefreshRing.gif', 40) }

Page({
  data: {
    url: URL,
    headerIcons: IMAGES_HEADER,
    statusBarHeight: 20,
    loaded: false,
    loadedAt: '',
    warning: '',
    back: '',
  },
  onLoad(query) {
    this.method = query.method || 'example41'
    let statusBarHeight = 20
    try {
      statusBarHeight = wx.getSystemInfoSync().statusBarHeight || 20
    } catch (e) {}
    this.setData({ statusBarHeight, warning: t('CYLScenarioMJWebWarning'), back: t('CYLScenarioMJWebBack') })
  },
  onReady() {
    // Both examples begin refreshing on open (the page loads under the header).
    this.selectComponent('#refresh').beginRefreshing()
  },
  onUnload() {
    clearTimeout(this.timer)
  },
  /** webView.reload(); the header ends on didFinish. */
  onRefresh() {
    this.setData({ loaded: false })
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      const d = new Date()
      const pad = (n) => (n < 10 ? '0' : '') + n
      this.setData({ loaded: true, loadedAt: pad(d.getHours()) + ':' + pad(d.getMinutes()) + ':' + pad(d.getSeconds()) })
      this.selectComponent('#refresh').endRefreshing()
    }, LOAD_TIME)
  },
  /** The address cannot be opened here; copy it so it can be opened in a browser. */
  onCopyURL() {
    wx.setClipboardData({ data: URL })
  },
  onBack() {
    wx.navigateBack()
  },
})
