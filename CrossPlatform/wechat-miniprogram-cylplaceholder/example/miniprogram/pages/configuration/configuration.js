// Configuration files (CYLPlaceholderConfiguration): the six files of the Android / iOS examples, each read from the
// package, shown as text and rendered. The example's own texts are marked "exampleTitleKey" in the files; the example
// resolves them here (the core never reads the example's strings).
const { CYLPlaceholderConfiguration, CYLPlaceholderScenarioCatalog } = require('../../components/cyl-placeholder/cyl_placeholder')

const FILES = [
  'ctrip-retry-or-contact-support.json',
  'interaction-switches.json',
  'playback-policies.json',
  'animation-formats.json',
  'location-permission.json',
  'raw-item-attributes.json',
]
// The English texts of CYLScenarioExample.bundle for the keys the files use.
const EXAMPLE_TEXTS = {
  CYLScenarioConfigTapEachButton: 'Tap each button',
  CYLScenarioConfigHighlightDim: 'Highlight: dim',
  CYLScenarioConfigHighlightShrink: 'Highlight: shrink',
  CYLScenarioConfigHighlightNone: 'Highlight: none',
  CYLScenarioConfigInteractionOff: 'Interaction off: no tap, no highlight',
  CYLScenarioConfigPlaybackLoop: 'Loops (default)',
  CYLScenarioConfigPlaybackOnce: 'Plays once',
  CYLScenarioConfigPlaybackThree: 'Plays 3 times',
}

function resolveExampleTexts(configuration) {
  for (const c of configuration.components || []) {
    if (c.exampleTitleKey) {
      if (EXAMPLE_TEXTS[c.exampleTitleKey]) c.title = EXAMPLE_TEXTS[c.exampleTitleKey]
      delete c.exampleTitleKey
    }
  }
  return configuration
}

Page({
  data: { files: FILES, index: 0, text: '', configuration: null, language: '', error: '', lastAction: '' },
  onLoad(query) {
    this.setData({ language: getApp().globalData.language || '' })
    this.open(Number(query.index) || 0)
  },
  open(index) {
    const file = FILES[index]
    let text = ''
    let configuration = null
    let error = ''
    try {
      text = wx.getFileSystemManager().readFileSync('configurations/' + file, 'utf8')
      configuration = resolveExampleTexts(CYLPlaceholderConfiguration.readConfigurationFile('/configurations/' + file))
    } catch (e) {
      error = e.message
    }
    this.setData({ index, text, configuration, error, lastAction: '' })
    wx.setNavigationBarTitle({ title: file })
  },
  onPick(e) {
    this.open(Number(e.detail.value))
  },
  onAction(e) {
    const title = CYLPlaceholderScenarioCatalog.localizedTitleForAction(e.detail.action, this.data.language || undefined)
    this.setData({ lastAction: e.detail.action + ' (component ' + e.detail.index + ')' })
    wx.showToast({ title: (title || e.detail.action) + ' tapped', icon: 'none' })
  },
  onConfigError(e) {
    this.setData({ error: e.detail.message })
  },
  onPlayAll() {
    this.selectComponent('#placeholder').playAll()
  },
})
