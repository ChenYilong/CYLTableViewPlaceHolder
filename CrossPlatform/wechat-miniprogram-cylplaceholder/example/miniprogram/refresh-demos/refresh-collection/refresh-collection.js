// CYLRefreshCollectionViewController.swift: MJRefresh's collection examples.
// - CYLRefreshCollectionViewController example31 (pull down and up) and example32 (the same with animated icons)
// - CYLRefreshPinHeaderCollectionViewController example31 (looks the same: pinning is a TODO in MJRefresh too)
// - CYLRefreshHorizontalCollectionViewController example42 (pull left: the trailer opens the test page)
// The variant comes from query.vc plus query.method.
const { t } = require('../../utils/l10n')

const DURATION = 2000
const A = '/assets/animations/'

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

  // Horizontal (example42): CYLRefreshNormalTrailer (cyl-refresh-trailer); its block pushes the test page.
  onTrailer() {
    wx.navigateTo({ url: '/refresh-demos/refresh-test/refresh-test?modal=0' })
  },
})
