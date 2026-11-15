// CYLConfigurationViewController: one configuration file of /configurations (JSON or plist), turned into a placeholder
// by the core. A file that names the example's own texts ("exampleTitleKey") gets them resolved here, so the core
// never reads the example's strings.
const { t, effectiveLanguage, showFeedback } = require('../../utils/l10n')
const {
  CYLPlaceholderConfiguration,
  CYLPlaceholderScenarioCatalog: Catalog,
} = require('../../components/cyl-placeholder/cyl_placeholder')

/** Replaces each "exampleTitleKey" with a "title" read from the example's strings. */
function resolvingExampleTexts(value) {
  if (Array.isArray(value)) return value.map(resolvingExampleTexts)
  if (!value || typeof value !== 'object') return value
  const result = {}
  Object.keys(value).forEach((key) => {
    if (key !== 'exampleTitleKey') result[key] = resolvingExampleTexts(value[key])
  })
  if (typeof value.exampleTitleKey === 'string') result.title = t(value.exampleTitleKey)
  return result
}

Page({
  data: { file: '', language: '', configuration: null, error: '', replayTitle: '', fileTitle: '' },

  onLoad(query) {
    const file = decodeURIComponent(query.file || '')
    wx.setNavigationBarTitle({ title: file })
    this.setData({
      file,
      language: effectiveLanguage(),
      replayTitle: t('CYLScenarioActionReplay'),
      fileTitle: t('CYLScenarioActionShowFile'),
    })
    this.reload()
  },

  /** Builds the placeholder from the file again ("Replay"); a broken file shows its error instead. */
  reload() {
    let configuration
    try {
      // Property lists ship as <name>.plist.json (a mini program package keeps only known file types).
      const packaged = /\.plist$/.test(this.data.file) ? this.data.file + '.json' : this.data.file
      configuration = resolvingExampleTexts(CYLPlaceholderConfiguration.readConfigurationFile('/configurations/' + packaged))
    } catch (e) {
      this.setData({ configuration: null, error: e.message })
      return
    }
    this.setData({ configuration, error: '' }, () => {
      const placeholder = this.selectComponent('#placeholder')
      if (placeholder) placeholder.playAll()
    })
  },

  onConfigError(e) {
    this.setData({ configuration: null, error: e.detail.message })
  },

  /** Every action confirms the tap with its core title (a custom action shows its raw value). */
  onAction(e) {
    const action = e.detail.action
    const title = Catalog.localizedTitleForAction(action, this.data.language) || action
    showFeedback(t('CYLScenarioFormatActionTapped', title))
  },

  onShowFile() {
    wx.navigateTo({ url: '/pages/text-file/text-file?file=' + encodeURIComponent(this.data.file) })
  },
})
