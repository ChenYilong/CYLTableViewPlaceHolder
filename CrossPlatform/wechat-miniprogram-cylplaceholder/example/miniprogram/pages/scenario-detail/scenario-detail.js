// CYLScenarioDetailViewController: one scenario on an empty plain table. The example only handles the actions:
//
// - retry:          the Loading scenario, then data; "Clear" empties the table again
// - contactSupport: opens the support page
// - openSettings:   opens the mini program's settings page (iOS: the app's page in Settings)
// - goShopping:     a short confirmation
// - chooseManually: a short confirmation (the location permission scenario offers to pick an address by hand)
// - done:           goes back
const { t, effectiveLanguage, showFeedback } = require('../../utils/l10n')
const { later } = require('../../utils/page')
const { CYLPlaceholderScenarioCatalog: Catalog, CYLPlaceholderAction } = require('../../components/cyl-placeholder/cyl_placeholder')

Page({
  data: {
    scenario: '',
    language: '',
    isLoading: false,
    /** Every component's tap switch; off keeps the components visible but inert. */
    interactionEnabled: true,
    /** The scenario's components with taps off; empty while taps are on (the scenario's own components). */
    components: [],
    rows: [],
    clearTitle: '',
    interactionTitle: '',
  },

  onLoad(query) {
    const scenario = Catalog.scenarioNamed(query.scenario) || ''
    const language = effectiveLanguage()
    wx.setNavigationBarTitle({ title: scenario ? Catalog.localizedNameForScenario(scenario, language) : '' })
    this.setData({ scenario, language, clearTitle: t('CYLScenarioActionClear') })
    this.applyInteraction(true)
  },

  onUnload() {
    if (this.cancelRetry) this.cancelRetry()
  },

  /** Each component's own switch: off, a tap neither runs the action nor highlights. */
  applyInteraction(enabled) {
    const { scenario, language } = this.data
    const components = enabled
      ? []
      : Catalog.componentsForScenario(scenario, language).map((c) => ({ ...c, interactionEnabled: false }))
    this.setData({
      interactionEnabled: enabled,
      components,
      interactionTitle: t(enabled ? 'CYLScenarioInteractionOn' : 'CYLScenarioInteractionOff'),
    })
  },

  onToggleInteraction() {
    this.applyInteraction(!this.data.interactionEnabled)
  },

  onClear() {
    if (this.cancelRetry) this.cancelRetry()
    this.setData({ isLoading: false, rows: [] })
  },

  onAction(e) {
    switch (e.detail.action) {
      case CYLPlaceholderAction.Retry:
        this.retry()
        break
      case CYLPlaceholderAction.ContactSupport:
        wx.navigateTo({ url: '/pages/support/support' })
        break
      case CYLPlaceholderAction.OpenSettings:
        wx.openSetting()
        break
      case CYLPlaceholderAction.GoShopping:
        showFeedback(t('CYLScenarioFeedbackGoShopping'))
        break
      case CYLPlaceholderAction.ChooseManually:
        showFeedback(t('CYLScenarioFeedbackChooseManually'))
        break
      case CYLPlaceholderAction.Done:
        wx.navigateBack()
        break
    }
  },

  retry() {
    this.setData({ isLoading: true })
    this.cancelRetry = later(1200, () => {
      this.cancelRetry = null
      const rows = Array.from({ length: 12 }, (_, i) => t('CYLScenarioFormatItem', i + 1))
      this.setData({ isLoading: false, rows })
      showFeedback(t('CYLScenarioFeedbackRetry'))
    })
  },
})
