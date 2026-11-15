// CYLRefreshCollectionViewController.swift: MJRefresh's collection examples.
// - CYLRefreshCollectionViewController example31 (pull down and up) and example32 (the same with animated icons)
// - CYLRefreshPinHeaderCollectionViewController example31 (looks the same: pinning is a TODO in MJRefresh too)
// - CYLRefreshHorizontalCollectionViewController example42 (pull left: the trailer opens the test page)
// The variant comes from query.vc plus query.method.
const { t } = require('../../utils/l10n')
const { CYLRefresh } = require('../../components/cyl-refresh/cyl_refresh')

const DURATION = 2000
const A = '/assets/animations/'
/** MJRefreshTrailWidth: the pull distance that arms the trailer. */
const TRAILER_WIDTH = 60

/** CYLRefreshRandomColor. */
function randomColor() {
  const c = () => Math.floor(Math.random() * 256)
  return `rgb(${c()}, ${c()}, ${c()})`
}
function randomColors(n) {
  return Array.from({ length: n }, () => ({ id: Math.random().toString(36).slice(2), color: randomColor() }))
}

/** Header / footer setup of each grid example. */
function gridSetup(method) {
  if (method === 'example32') {
    return {
      header: 'animation',
      headerIcons: { Idle: { path: A + 'CYLRefreshCounterClockwise.json', size: 28 }, Refreshing: { path: A + 'CYLRefreshGradientSpinner.json', size: 32 } },
      footerIcons: { Idle: { path: A + 'CYLRefreshActivity.gif', size: 28 } },
    }
  }
  return { header: 'normal', headerIcons: null, footerIcons: null }
}

Page({
  data: {
    horizontal: false,
    setup: {},
    colors: [],
    pages: [],
    // Trailer (horizontal example).
    trailerPull: 0,
    trailerState: 'Idle',
    trailerText: '',
  },
  onLoad(query) {
    this.method = query.method || 'example31'
    this.vc = query.vc || 'CYLRefreshCollectionViewController'
    wx.setNavigationBarTitle({ title: decodeURIComponent(query.title || '') })
    const horizontal = this.vc === 'CYLRefreshHorizontalCollectionViewController'
    this.scrollLeft = 0
    this.scrollWidth = 0
    this.setData({
      horizontal,
      setup: gridSetup(this.method),
      pages: horizontal ? randomColors(5).map((p, i) => Object.assign(p, { label: this.itemLabel(i) })) : [],
      trailerText: CYLRefresh.refreshText('CYLRefreshTrailerIdleText'),
    })
  },
  onReady() {
    if (!this.data.horizontal) this.refresh().beginRefreshing()
  },
  onUnload() {
    clearTimeout(this.timer)
  },
  refresh() {
    return this.selectComponent('#refresh')
  },
  itemLabel(index) {
    return t(index % 2 === 1 ? 'CYLScenarioMJPush' : 'CYLScenarioMJModal')
  },
  withLabels(colors) {
    return colors.map((c, i) => Object.assign({}, c, { label: this.itemLabel(i) }))
  },

  // Grid (example31 / example32).

  /** Header: 10 random colors at the front; the grid reloads and the header ends 2 s later. */
  onRefresh() {
    const colors = randomColors(10).concat(this.data.colors)
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this.setData({ colors: this.withLabels(colors) })
      this.refresh().endRefreshing()
    }, DURATION)
  },
  /** Back footer: 5 colors at the end; the grid reloads and the footer ends 2 s later. */
  onLoadMore() {
    const colors = this.data.colors.concat(randomColors(5))
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this.setData({ colors: this.withLabels(colors) })
      this.refresh().endFooterRefreshing()
    }, DURATION)
  },
  /** CYLRefreshTestViewController.show(from:row:): odd items push, even items present. */
  onItem(e) {
    const modal = e.currentTarget.dataset.index % 2 === 0
    wx.navigateTo({ url: '/refresh-demos/refresh-test/refresh-test?modal=' + (modal ? 1 : 0) })
  },

  // Horizontal (example42): CYLRefreshNormalTrailer, emulated with touch tracking at the last page.

  onPagesScroll(e) {
    this.scrollLeft = e.detail.scrollLeft
    this.scrollWidth = e.detail.scrollWidth
  },
  atEnd() {
    const width = wx.getSystemInfoSync().windowWidth
    const total = this.scrollWidth || width * this.data.pages.length
    return this.scrollLeft >= total - width - 2
  },
  onTouchStart(e) {
    if (this.method !== 'example42' || this.data.trailerState === 'Refreshing') return
    this.tracking = true
    this.touchX = this.atEnd() ? e.touches[0].clientX : null
  },
  onTouchMove(e) {
    if (!this.tracking) return
    const x = e.touches[0].clientX
    // Not at the end when the touch began: the pull starts once the last page is reached during the drag.
    if (this.touchX == null) {
      if (!this.atEnd()) return
      this.touchX = x
    }
    const dx = this.touchX - x
    const pull = Math.max(0, dx) * 0.5
    const state = pull >= TRAILER_WIDTH ? 'Pulling' : 'Idle'
    const update = { trailerPull: pull }
    if (state !== this.data.trailerState) {
      update.trailerState = state
      update.trailerText = CYLRefresh.refreshText(state === 'Pulling' ? 'CYLRefreshTrailerPullingText' : 'CYLRefreshTrailerIdleText')
    }
    this.setData(update)
  },
  onTouchEnd() {
    if (!this.tracking) return
    this.tracking = false
    if (this.data.trailerState === 'Pulling') {
      // The trailer's block: push the test page, then endRefreshing.
      this.setData({ trailerState: 'Refreshing', trailerPull: TRAILER_WIDTH })
      wx.navigateTo({ url: '/refresh-demos/refresh-test/refresh-test?modal=0' })
      this.endTrailer()
    } else {
      this.endTrailer()
    }
  },
  endTrailer() {
    this.setData({ trailerState: 'Idle', trailerPull: 0, trailerText: CYLRefresh.refreshText('CYLRefreshTrailerIdleText') })
  },
})
