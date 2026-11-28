// CYLFlowListViewController: how a placeholder is attached to a list (insetGrouped, 3 sections). Section 0 lists the
// CYLFlow cases, section 1 the network status bar, section 2 the HUD. Row icons stand in for the SF Symbols.
const { t } = require('../../utils/l10n')
const { showTab } = require('../../utils/page')

/** CYLFlow: title key, API detail (not translated), icon glyph standing in for the SF Symbol, page to push. */
const FLOWS = [
  { flow: 'switchStates', key: 'CYLScenarioTitleSwitchStates', detail: 'reloadData #3', icon: '⟲' },
  { flow: 'keepTableHeader', key: 'CYLScenarioTitleKeepTableHeader', detail: 'frameForPlaceHolderViewInTableView: #17', icon: '▤' },
  { flow: 'keepSectionHeaders', key: 'CYLScenarioTitleKeepSectionHeaders', detail: 'rectForHeaderInSection: #16', icon: '☰' },
  { flow: 'refreshControls', key: 'CYLScenarioTitleRefreshControls', detail: 'cyl_header + cyl_footer #8', icon: '⇩' },
  { flow: 'scrollable', key: 'CYLScenarioTitleScrollable', detail: 'enableScrollWhenPlaceHolderViewShowing', icon: '↕' },
  { flow: 'collection', key: 'CYLScenarioTitleCollection', detail: 'cyl_placeholderViewBlock: #11', icon: '⊞' },
]

Page({
  data: { sections: [] },
  onShow() {
    showTab(this, 'flows')
    // Rebuilt on every show so the texts follow a language change.
    const flowRows = FLOWS.map((f) => ({
      id: f.flow,
      title: t(f.key),
      subtitle: f.detail,
      icon: f.icon,
      url: f.flow === 'collection'
        ? '/pages/collection-flow/collection-flow?flow=collection'
        : '/pages/flow-detail/flow-detail?flow=' + f.flow,
    }))
    this.setData({
      sections: [
        { header: '', rows: flowRows },
        {
          header: t('CYLScenarioSectionStatusBar'),
          rows: [{ id: 'statusBarFlow', title: t('CYLScenarioTitleStatusBar'), subtitle: 'CYLPlaceholderStatusView · statusView', icon: '!', red: true, url: '/pages/status/status' }],
        },
        {
          header: t('CYLScenarioSectionHUD'),
          rows: [{ id: 'hudFlow', title: t('CYLScenarioTitleHUD'), subtitle: 'CYLPlaceholderHUD · .hud', icon: '⌛︎', url: '/pages/hud/hud' }],
        },
      ],
    })
  },
  onRowTap(e) {
    wx.navigateTo({ url: e.currentTarget.dataset.url })
  },
})
