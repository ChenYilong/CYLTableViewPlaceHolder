// CYLRefreshTableViewController: MJRefresh's table examples 01–06 (headers), 11–21 (footers) and 51–56 (animated
// icons). 5 random rows to start; loadNewData inserts 5 at the top, loadMoreData appends 1, loadLastData appends 5
// then "No more data", loadOnceData appends 5 then hides the footer; each takes CYLRefreshDuration (2 s).
const { t } = require('../../utils/l10n')

const DURATION = 2000
const A = '/assets/animations/'
const icon = (name, size) => ({ path: A + name, size })
// ExampleImagesHeader / Footer: the Arrows.gif frames for idle, the Ring.gif frames for pulling and refreshing.
const IMAGES_HEADER = { Idle: icon('CYLRefreshArrows.gif', 40), Pulling: icon('CYLRefreshRing.gif', 40), Refreshing: icon('CYLRefreshRing.gif', 40) }
const IMAGES_FOOTER = { Refreshing: icon('CYLRefreshRing.gif', 40) }
const IMAGES_BACK_FOOTER = { Idle: icon('CYLRefreshArrows.gif', 40), Pulling: icon('CYLRefreshRing.gif', 40), Refreshing: icon('CYLRefreshRing.gif', 40) }

/** Each example: header / footer setup and the footer's data function. */
function exampleSetup(method) {
  const base = { header: 'normal', footer: 'none', begins: true, more: 'loadMoreData' }
  const n = parseInt(method.replace('example', ''), 10)
  const withFooter = (extra) => Object.assign(base, { footer: 'auto' }, extra)
  switch (n) {
    case 1: return base
    case 2: return Object.assign(base, { header: 'animation', headerIcons: IMAGES_HEADER })
    case 3: return Object.assign(base, { automaticallyChangeAlpha: true, lastUpdatedTimeHidden: true })
    case 4: return Object.assign(base, { header: 'animation', headerIcons: IMAGES_HEADER, stateHidden: true, lastUpdatedTimeHidden: true })
    case 5: return Object.assign(base, {
      headerTitles: { Idle: t('CYLScenarioMJCustomIdle'), Pulling: t('CYLScenarioMJCustomPulling'), Refreshing: t('CYLScenarioMJCustomLoading') },
      headerStyle: { stateColor: '#ff0000', stateFontSize: 15, timeColor: '#0000ff', timeFontSize: 14 },
    })
    case 6: return Object.assign(base, { header: 'diy', headerHeight: 50 })
    case 11: return withFooter()
    case 12: return withFooter({ footerIcons: IMAGES_FOOTER })
    case 13: return withFooter({ footerIcons: IMAGES_FOOTER, refreshingTitleHidden: true })
    case 14: return withFooter({ more: 'loadLastData', resume: true })
    case 15: return withFooter({ automaticallyRefresh: false })
    case 16: return withFooter({
      footerTitles: { Idle: t('CYLScenarioMJFooterIdle'), Refreshing: t('CYLScenarioMJFooterLoading'), NoMoreData: t('CYLScenarioMJFooterNoMore') },
      footerStyle: { color: '#0000ff', fontSize: 17 },
    })
    case 17: return withFooter({ more: 'loadOnceData' })
    case 18: return withFooter({ footer: 'back', bottomInset: 30 })
    case 19: return withFooter({ footer: 'back', footerIcons: IMAGES_BACK_FOOTER, more: 'loadLastData', automaticallyChangeAlpha: true })
    case 20: return withFooter({ footer: 'diy', footerHeight: 50, autoTriggerTimes: 2 })
    case 21: return withFooter({ footer: 'diyBack', footerHeight: 50 })
    case 51: return withFooter({ header: 'animation', headerIcons: { Idle: icon('CYLRefreshArrows.gif', 32) }, footerIcons: { Refreshing: icon('CYLRefreshRing.gif', 28) } })
    case 52: return withFooter({
      header: 'animation', footer: 'back', more: 'loadLastData',
      headerIcons: { Idle: icon('CYLRefreshPullArrow.json', 28), Pulling: icon('CYLRefreshClockwise.json', 28), Refreshing: icon('CYLRefreshMaterialSpinner.json', 36) },
      footerIcons: { Idle: icon('CYLRefreshLoadMore.json', 28), Refreshing: icon('CYLRefreshMoreDots.json', [40, 24]) },
    })
    // 53: PAG and 54: Rive have no mini program player; cyl-refresh shows its spinner for those states.
    case 53: return withFooter({ header: 'animation', begins: false, headerIcons: { Idle: icon('CYLPlaceholderProgress.pag', 32) }, footerIcons: { Refreshing: icon('CYLPlaceholderProgress.pag', 28) } })
    case 54: return withFooter({ header: 'animation', headerIcons: { Idle: icon('CYLRefreshIcon.riv', 32) }, footerIcons: { Refreshing: icon('CYLRefreshIcon.riv', 32) } })
    case 55: return withFooter({ header: 'animation', headerIcons: { Idle: icon('CYLRefreshArrows.gif', 40), Refreshing: icon('CYLRefreshRing.gif', 40) }, footerIcons: IMAGES_FOOTER })
    case 56: return withFooter({
      header: 'animation',
      headerIcons: { Idle: icon('CYLRefreshPullCircle.json', 28), Pulling: icon('CYLRefreshArrows.gif', 30), Refreshing: icon('CYLPlaceholderProgress.pag', 32) },
      footerIcons: { Refreshing: icon('CYLRefreshIcon.riv', 30) },
    })
    default: return base
  }
}

const DIY_TEXTS = {
  header: { Idle: 'CYLScenarioMJDIYPullDown', Pulling: 'CYLScenarioMJDIYRelease', Refreshing: 'CYLScenarioMJDIYLoading' },
  footer: { Idle: 'CYLScenarioMJDIYPullUp', Pulling: 'CYLScenarioMJDIYRelease', Refreshing: 'CYLScenarioMJDIYLoading', NoMoreData: 'CYLScenarioMJDIYNoMore' },
}

/** The DIY label color follows the pull: rgb(1 − p·0.5, 0.5 − 0.5p, 0.5p), orange to purple. */
function diyColor(p) {
  const c = (v) => Math.round(Math.max(0, Math.min(1, v)) * 255)
  return `rgb(${c(1 - p * 0.5)}, ${c(0.5 - 0.5 * p)}, ${c(0.5 * p)})`
}

Page({
  data: { setup: {}, rows: [], footerHidden: false, resume: '', diy: { header: {}, footer: {} } },
  onLoad(query) {
    this.method = query.method || 'example01'
    const setup = exampleSetup(this.method)
    this.more = setup.more
    wx.setNavigationBarTitle({ title: decodeURIComponent(query.title || '') })
    this.setData({
      setup,
      rows: this.randomRows(5),
      resume: setup.resume ? t('CYLScenarioMJResumeLoading') : '',
      diy: { header: this.diyState('header', 'Idle', 0), footer: this.diyState('footer', 'Idle', 0) },
    })
  },
  onReady() {
    if (this.data.setup.begins) this.refresh().beginRefreshing()
  },
  onUnload() {
    clearTimeout(this.timer)
  },
  refresh() {
    return this.selectComponent('#refresh')
  },
  randomRow(index) {
    const kind = index % 2 === 0 ? t('CYLScenarioMJPush') : t('CYLScenarioMJModal')
    return { id: Math.random().toString(36).slice(2), text: kind + ' - ' + t('CYLScenarioMJRandomData', Math.floor(Math.random() * 1000000)) }
  },
  randomRows(n, offset = 0) {
    return Array.from({ length: n }, (_, i) => this.randomRow(offset + i))
  },
  diyState(part, state, percent) {
    const key = DIY_TEXTS[part][state] || DIY_TEXTS[part].Idle
    return { text: t(key), color: diyColor(percent), switchOn: state !== 'Idle', spinning: state === 'Refreshing' }
  },
  onStateChange(e) {
    const { part, state, percent } = e.detail
    const isDiy = part === 'header' ? this.data.setup.header === 'diy' : /^diy/.test(this.data.setup.footer || '')
    if (isDiy) this.setData({ ['diy.' + part]: this.diyState(part, state, percent) })
  },
  /** loadNewData: 5 new rows at the top at once; the header ends after 2 s. */
  onRefresh() {
    this.setData({ rows: this.randomRows(5).concat(this.data.rows) })
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.refresh().endRefreshing(), DURATION)
  },
  onLoadMore() {
    const rows = this.data.rows
    clearTimeout(this.timer)
    if (this.more === 'loadMoreData') {
      this.setData({ rows: rows.concat(this.randomRows(1, rows.length)) })
      this.timer = setTimeout(() => this.refresh().endFooterRefreshing(), DURATION)
    } else if (this.more === 'loadLastData') {
      this.setData({ rows: rows.concat(this.randomRows(5, rows.length)) })
      this.timer = setTimeout(() => this.refresh().endRefreshingWithNoMoreData(), DURATION)
    } else {
      this.setData({ rows: rows.concat(this.randomRows(5, rows.length)) })
      this.timer = setTimeout(() => this.setData({ footerHidden: true }), DURATION)
    }
  },
  /** Example 14's "Resume loading": the footer loads one row at a time again. */
  onResume() {
    this.more = 'loadMoreData'
    this.refresh().resetNoMoreData()
  },
  /** Odd rows push the test page, even rows present it (a mini program page either way). */
  onRow(e) {
    const modal = e.currentTarget.dataset.index % 2 === 1
    wx.navigateTo({ url: '/pages/refresh-test/refresh-test?modal=' + (modal ? 1 : 0) })
  },
})
