// A small stand-in for CYLRefresh (the MJRefresh port) on a scroll-view, shared by the Flows pages that use
// CYLRefreshNormalHeader and an auto footer: the native refresher with a custom "arrow + state text" slot, and a
// footer driven by bindscrolltolower (auto load) or a tap ("Click or drag up to refresh").
//
// The core mini program package has no refresh texts, so the texts are the example strings that carry MJRefresh's
// English defaults (CYLScenarioMJCustomIdle / Pulling / Loading, CYLScenarioMJFooterIdle / Loading / NoMore).
//
// Usage: Page({ ...CYLRefreshMethods, data: { ...cylRefreshData() }, onHeaderRefresh() {}, onFooterRefresh() {},
// footerEnabled() {} }) and the templates of refresh.wxml.
const { t } = require('../../utils/l10n')

/** MJRefreshHeaderHeight: the pull distance that arms the header. */
const CYLRefreshHeaderHeight = 54

function headerText(state) {
  if (state === 'pulling') return t('CYLScenarioMJCustomPulling')
  if (state === 'refreshing') return t('CYLScenarioMJCustomLoading')
  return t('CYLScenarioMJCustomIdle')
}

function footerText(state) {
  if (state === 'refreshing') return t('CYLScenarioMJFooterLoading')
  if (state === 'noMoreData') return t('CYLScenarioMJFooterNoMore')
  return t('CYLScenarioMJFooterIdle')
}

/** The initial data of the header and footer. */
function cylRefreshData() {
  return {
    refreshThreshold: CYLRefreshHeaderHeight,
    refresherTriggered: false,
    header: { state: 'idle', text: headerText('idle') },
    footer: { state: 'idle', text: footerText('idle') },
  }
}

const CYLRefreshMethods = {
  // MARK: Header (scroll-view refresher)

  onRefresherPulling(e) {
    if (this.data.header.state === 'refreshing') return
    const state = e.detail.dy >= CYLRefreshHeaderHeight ? 'pulling' : 'idle'
    if (state !== this.data.header.state) this.setData({ header: { state, text: headerText(state) } })
  },
  onRefresherRefresh() {
    this.setData({ refresherTriggered: true, header: { state: 'refreshing', text: headerText('refreshing') } })
    if (this.onHeaderRefresh) this.onHeaderRefresh()
  },
  onRefresherRestore() {
    if (this.data.header.state !== 'refreshing') this.setData({ header: { state: 'idle', text: headerText('idle') } })
  },
  /** endRefreshing of the header. */
  endHeaderRefreshing() {
    this.setData({ refresherTriggered: false, header: { state: 'idle', text: headerText('idle') } })
  },

  // MARK: Footer (auto footer: loads when the end of the list shows, or on a tap)

  onScrollToLower() {
    this.beginFooterRefreshing()
  },
  onFooterTap() {
    this.beginFooterRefreshing()
  },
  beginFooterRefreshing() {
    if (this.data.footer.state !== 'idle') return
    if (this.footerEnabled && !this.footerEnabled()) return
    this._setFooter('refreshing')
    if (this.onFooterRefresh) this.onFooterRefresh()
  },
  endFooterRefreshing() {
    this._setFooter('idle')
  },
  endFooterRefreshingWithNoMoreData() {
    this._setFooter('noMoreData')
  },
  resetFooterNoMoreData() {
    if (this.data.footer.state === 'noMoreData') this._setFooter('idle')
  },
  _setFooter(state) {
    this.setData({ footer: { state, text: footerText(state) } })
  },
}

module.exports = { CYLRefreshHeaderHeight, cylRefreshData, CYLRefreshMethods }
