// CYLFlowDetailViewController: one list, one placeholder, attached the way the flow (query `flow`) shows:
// - switchStates: a segmented control switches between empty, failed, offline and data (block API, issue #3)
// - keepTableHeader: the placeholder starts below a 56 pt search bar (delegate API frame, issue #17)
// - keepSectionHeaders: the placeholder starts below the last section header (delegate API frame, issue #16)
// - refreshControls: pull to refresh and load more stay usable above the placeholder (block API, issue #8)
// - scrollable: the empty list can still be pulled (enableScrollWhenPlaceHolderViewShowing)
const { t } = require('../../utils/l10n')
const { later } = require('../../utils/page')
const { CYLPlaceholderAction } = require('../../components/cyl-placeholder/cyl_placeholder')
const { cylRefreshData, CYLRefreshMethods } = require('./refresh_control')

/** CYLFlow: title key and the scenario shown while the list is empty. */
const FLOWS = {
  switchStates: { key: 'CYLScenarioTitleSwitchStates', scenario: 'NoContent' },
  keepTableHeader: { key: 'CYLScenarioTitleKeepTableHeader', scenario: 'NoSearchResults' },
  keepSectionHeaders: { key: 'CYLScenarioTitleKeepSectionHeaders', scenario: 'NoMessages' },
  refreshControls: { key: 'CYLScenarioTitleRefreshControls', scenario: 'NoNotifications' },
  scrollable: { key: 'CYLScenarioTitleScrollable', scenario: 'TextOnly' },
  collection: { key: 'CYLScenarioTitleCollection', scenario: 'NoFavorites' },
}
/** State, in the order of the segmented control. */
const STATES = ['empty', 'failed', 'offline', 'data']
const STATE_KEYS = ['CYLScenarioStateEmpty', 'CYLScenarioStateFailed', 'CYLScenarioStateOffline', 'CYLScenarioStateData']

Page({
  ...CYLRefreshMethods,

  data: {
    flow: 'switchStates',
    state: 'empty',
    stateIndex: 0,
    segments: [],
    rows: [],
    scenario: '',
    showsPlaceholder: true,
    placeholderHeight: 0,
    scrollY: true,
    hasHeader: false,
    hasFooter: false,
    searchPlaceholder: '',
    sectionHeaders: [],
    ...cylRefreshData(),
  },

  onLoad(query) {
    const flow = FLOWS[query.flow] ? query.flow : 'switchStates'
    this.cancels = []
    wx.setNavigationBarTitle({ title: t(FLOWS[flow].key) })
    this.setData({
      flow,
      segments: STATE_KEYS.map((k) => t(k)),
      hasHeader: flow === 'refreshControls' || flow === 'scrollable',
      hasFooter: flow === 'refreshControls',
      searchPlaceholder: t('CYLScenarioSearchPlaceholder'),
      sectionHeaders: [t('CYLScenarioSectionPinned'), t('CYLScenarioSectionAll')],
    })
    this.select('empty')
  },

  onReady() {
    // frameForPlaceHolderViewInTableView: the placeholder fills the list below the marker (the table header or the
    // last section header; the top of the list for the other flows).
    wx.createSelectorQuery()
      .in(this)
      .select('.flow-list').boundingClientRect()
      .select('#placeholder-top').boundingClientRect()
      .exec(([list, top]) => {
        if (!list) return
        const offset = top ? Math.max(0, top.top - list.top) : 0
        this.setData({ placeholderHeight: Math.max(0, list.height - offset) })
      })
  },

  onUnload() {
    this.cancels.forEach((cancel) => cancel())
  },

  /** select(_:): the state, its rows (12 for data) and the placeholder it shows when empty. */
  select(state) {
    const count = state === 'data' ? 12 : 0
    this.applyRows(count, state)
  },

  applyRows(count, state = this.data.state) {
    const { flow } = this.data
    let scenario = FLOWS[flow].scenario
    if (state === 'failed') scenario = 'RetryButton'
    else if (state === 'offline') scenario = 'NetworkUnavailable'
    const rows = []
    for (let i = 1; i <= count; i++) rows.push({ id: i, title: t('CYLScenarioFormatItem', i) })
    const empty = count === 0
    this.setData({
      state,
      stateIndex: STATES.indexOf(state),
      rows,
      scenario,
      showsPlaceholder: empty,
      // The delegate API stops scrolling while the placeholder shows, unless enableScrollWhenPlaceHolderViewShowing.
      scrollY: !(empty && (flow === 'keepTableHeader' || flow === 'keepSectionHeaders')),
    })
  },

  onSegmentTap(e) {
    this.select(STATES[Number(e.currentTarget.dataset.index)])
  },

  /** The retry handler of every placeholder: selects data. */
  onPlaceholderAction(e) {
    if (e.detail.action === CYLPlaceholderAction.Retry) this.select('data')
  },

  // MARK: Refresh controls (issue #8)

  /** CYLRefreshNormalHeader: after 1 s toggles 0 / 12 rows, resets no-more-data, then ends. */
  onHeaderRefresh() {
    this.cancels.push(later(1000, () => {
      this.applyRows(this.data.rows.length > 0 ? 0 : 12)
      this.resetFooterNoMoreData()
      this.endHeaderRefreshing()
    }))
  },

  footerEnabled() {
    return this.data.hasFooter && this.data.rows.length > 0
  },

  /** CYLRefreshAutoAnimationFooter: after 1 s always ends with no more data. */
  onFooterRefresh() {
    this.cancels.push(later(1000, () => this.endFooterRefreshingWithNoMoreData()))
  },
})
