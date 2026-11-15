// CYLEasyRefreshDemoViewController: the flutter_easy_refresh samples (example/lib/page), one method per page:
// easyCupertino, easySecondary, easyTriggerMode, easyRefreshOnStart, easyPaging, easyListener, easyChat,
// easyUserProfile. Headers and footers are cyl-refresh's (Cupertino, listener, trigger modes, second floor, behind, scroll helpers).
const { t } = require('../../utils/l10n')

const METHODS = ['easyCupertino', 'easySecondary', 'easyTriggerMode', 'easyRefreshOnStart', 'easyPaging', 'easyListener', 'easyChat', 'easyUserProfile']

/** Header / footer options per page. */
function pageSetup(method) {
  switch (method) {
    case 'easyCupertino': return { header: 'cupertino', footer: 'cupertino', count: 10 }
    case 'easySecondary': return { header: 'normal', footer: 'back', secondaryOffset: 120, count: 10 }
    case 'easyTriggerMode': return { header: 'normal', footer: 'back', count: 30 }
    // The first refresh uses the Cupertino header (startHeader), later pulls the classic one.
    case 'easyRefreshOnStart': return { header: 'cupertino', footer: 'back', count: 0 }
    case 'easyPaging': return { header: 'normal', footer: 'back', count: 0 }
    case 'easyListener': return { header: 'listener', footer: 'back', count: 10 }
    case 'easyChat': return { header: 'normal', footer: 'none', count: 0 }
    default: return { header: 'normal', footer: 'none', behind: true, count: 10 }
  }
}

Page({
  data: {
    method: '',
    setup: {},
    rows: [],
    headerTrigger: 'anywhere',
    footerTrigger: 'anywhere',
    floorOpen: false,
    progress: 0,
    texts: {},
  },
  onLoad(query) {
    this.method = METHODS.indexOf(query.method) >= 0 ? query.method : 'easyUserProfile'
    wx.setNavigationBarTitle({ title: decodeURIComponent(query.title || '') })
    const setup = pageSetup(this.method)
    this.count = setup.count
    this.refreshCount = 0
    this.loadCount = 0
    this.timers = []
    this.setData({
      method: this.method,
      setup,
      texts: {
        secondFloor: t('CYLScenarioEasySecondFloor'),
        closeSecondFloor: t('CYLScenarioEasyCloseSecondFloor'),
        pullProgress: t('CYLScenarioEasyPullProgress'),
        banner: t('CYLScenarioEasyProfileBanner'),
      },
    })
    if (this.method === 'easyTriggerMode') this.reloadTriggerMode()
    else if (this.method === 'easyChat') this.setUpChat()
    else if (this.method !== 'easyPaging') this.reloadCounted()
  },
  onReady() {
    if (this.method === 'easyRefreshOnStart' || this.method === 'easyPaging') this.refresher().beginRefreshing()
    if (this.method === 'easyChat') setTimeout(() => this.refresher().scrollToBottom(), 50)
  },
  onUnload() {
    this.timers.forEach(clearTimeout)
  },
  later(ms, fn) {
    this.timers.push(setTimeout(fn, ms))
  },
  refresher() {
    return this.selectComponent('#refresh')
  },

  // Data.
  testRows(n) {
    return Array.from({ length: n }, (_, i) => ({ id: 'r' + (i + 1), text: t('CYLScenarioSmartTestDataRow', i + 1) }))
  },
  reloadCounted() {
    this.setData({ rows: this.testRows(this.count) })
  },
  reloadTriggerMode() {
    const { headerTrigger, footerTrigger } = this.data
    const top = [
      { id: 'refreshCount', text: t('CYLScenarioEasyRefreshCount', this.refreshCount) },
      { id: 'loadCount', text: t('CYLScenarioEasyLoadCount', this.loadCount) },
      { id: 'headerMode', text: t(headerTrigger === 'onEdge' ? 'CYLScenarioEasyHeaderOnEdge' : 'CYLScenarioEasyHeaderAnywhere'), tappable: true },
      { id: 'footerMode', text: t(footerTrigger === 'onEdge' ? 'CYLScenarioEasyFooterOnEdge' : 'CYLScenarioEasyFooterAnywhere'), tappable: true },
    ]
    this.setData({ rows: top.concat(this.testRows(this.count)) })
  },

  // Header and footer callbacks.
  onRefresh() {
    switch (this.method) {
      case 'easyTriggerMode': return this.refreshTriggerMode()
      case 'easyPaging': return this.loadPage(1)
      case 'easyChat': return this.loadEarlierMessages()
      default: return this.refreshCounted()
    }
  },
  onLoadMore() {
    switch (this.method) {
      case 'easyTriggerMode': return this.loadTriggerMode()
      case 'easyPaging': return this.loadPage(this.page + 1)
      case 'easyRefreshOnStart': return this.loadByTen()
      default: return this.loadCounted()
    }
  },
  /** Refresh: back to 10 rows after 2 s; the footer can load again. Refresh on start: later pulls use the classic header. */
  refreshCounted() {
    this.later(2000, () => {
      this.count = 10
      this.reloadCounted()
      const refresh = this.refresher()
      refresh.endRefreshing()
      refresh.resetNoMoreData()
      if (this.method === 'easyRefreshOnStart' && this.data.setup.header !== 'normal') this.setData({ 'setup.header': 'normal' })
    })
  },
  /** Load: 5 more rows after 2 s; no more data at 20. */
  loadCounted() {
    this.later(2000, () => {
      this.count += 5
      this.reloadCounted()
      const refresh = this.refresher()
      if (this.count >= 20) refresh.endRefreshingWithNoMoreData()
      else refresh.endFooterRefreshing()
    })
  },
  /** refresh_on_start_page.dart's load: 10 more rows; no more data at 30. */
  loadByTen() {
    this.later(2000, () => {
      this.count += 10
      this.reloadCounted()
      const refresh = this.refresher()
      if (this.count >= 30) refresh.endRefreshingWithNoMoreData()
      else refresh.endFooterRefreshing()
    })
  },
  refreshTriggerMode() {
    this.later(500, () => {
      this.refreshCount += 1
      this.reloadTriggerMode()
      this.refresher().endRefreshing()
    })
  },
  loadTriggerMode() {
    this.later(500, () => {
      this.loadCount += 1
      this.reloadTriggerMode()
      this.refresher().endFooterRefreshing()
    })
  },
  onRow(e) {
    if (this.method !== 'easyTriggerMode') return
    const index = e.currentTarget.dataset.index
    const flip = (mode) => (mode === 'onEdge' ? 'anywhere' : 'onEdge')
    if (index === 2) this.setData({ headerTrigger: flip(this.data.headerTrigger) })
    else if (index === 3) this.setData({ footerTrigger: flip(this.data.footerTrigger) })
    else return
    this.reloadTriggerMode()
  },

  // paging_page.dart (CYLRefreshPaging): a server of 45 items, 10 per page, 2 s per request; no more data once all
  // items are loaded, because the total is known.
  loadPage(page) {
    this.later(2000, () => {
      const total = 45
      const size = 10
      const start = (page - 1) * size
      const items = start >= total ? [] : Array.from({ length: Math.min(start + size, total) - start }, (_, i) => start + i + 1)
      this.page = page
      this.items = page === 1 ? items : (this.items || []).concat(items)
      this.setData({ rows: this.items.map((n) => ({ id: 'p' + n, text: t('CYLScenarioSmartTestDataRow', n) })) })
      const refresh = this.refresher()
      if (page === 1) refresh.endRefreshing()
      if (this.items.length >= total || items.length === 0) refresh.endRefreshingWithNoMoreData()
      else if (page === 1) refresh.resetNoMoreData()
      else refresh.endFooterRefreshing()
    })
  },

  // secondary_page.dart: a release past 120px opens the second floor; its button closes it.
  onSecondary() {
    this.setData({ floorOpen: true })
  },
  onCloseFloor() {
    this.setData({ floorOpen: false })
  },

  // listener_header_page.dart: the bar above the list shows min(pullingPercent, 1).
  onPull(e) {
    if (this.method !== 'easyListener' || e.detail.part !== 'header') return
    const progress = Math.round(Math.min(1, e.detail.percent) * 100)
    if (progress !== this.data.progress) this.setData({ progress })
  },

  // chat_page.dart: messages 31…50, newest at the bottom; a pull at the top loads 10 earlier ones and keeps the
  // visible messages in place; the header goes away at message 1.
  messageRows(from, to) {
    return Array.from({ length: to - from + 1 }, (_, i) => ({ id: 'm' + (from + i), text: t('CYLScenarioEasyMessageRow', from + i) }))
  },
  setUpChat() {
    this.earliestMessage = 31
    this.setData({ rows: this.messageRows(31, 50) })
  },
  loadEarlierMessages() {
    this.later(2000, () => {
      const refresh = this.refresher()
      const first = Math.max(1, this.earliestMessage - 10)
      const added = first < this.earliestMessage ? this.messageRows(first, this.earliestMessage - 1) : []
      this.earliestMessage = first
      refresh.measureContent().then((before) => {
        const offset = refresh.getScrollTop()
        this.setData({ rows: added.concat(this.data.rows) }, () => {
          refresh.measureContent().then((after) => {
            refresh.endRefreshing()
            refresh.setScrollTop(Math.max(0, offset) + after - before)
            if (first === 1) this.setData({ 'setup.header': 'none' })
          })
        })
      })
    })
  },
})
