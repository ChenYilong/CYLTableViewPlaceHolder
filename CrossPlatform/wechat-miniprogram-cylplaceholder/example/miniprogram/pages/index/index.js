// The scenario list: every CYLPlaceholderScenario grouped by CYLPlaceholderScenarioCategory, with a language switch.
const { CYLPlaceholderScenarioCatalog, CYLPlaceholderLocalization } = require('../../components/cyl-placeholder/cyl_placeholder')

const LANGUAGES = [''].concat(CYLPlaceholderLocalization.SUPPORTED_LANGUAGES)
const LANGUAGE_NAMES = ['System', 'English', '简体中文', '繁體中文', '日本語', '한국어', 'Русский', 'Українська']
const CATEGORIES = ['LoadFailed', 'Empty', 'Permission', 'Progress', 'Success']

Page({
  data: { sections: [], languageNames: LANGUAGE_NAMES, languageIndex: 0 },
  onLoad() {
    this.build()
  },
  build() {
    const language = LANGUAGES[this.data.languageIndex] || undefined
    const sections = CATEGORIES.map((category) => ({
      category,
      rows: CYLPlaceholderScenarioCatalog.allScenarios
        .filter((s) => CYLPlaceholderScenarioCatalog.categoryForScenario(s) === category)
        .map((s) => ({
          scenario: s,
          name: CYLPlaceholderScenarioCatalog.localizedNameForScenario(s, language),
          shots: CYLPlaceholderScenarioCatalog.readmeScreenshotNumbersForScenario(s).map((n) => '#' + n).join(' '),
        })),
    }))
    this.setData({ sections })
  },
  onLanguageChange(e) {
    const languageIndex = Number(e.detail.value)
    getApp().globalData.language = LANGUAGES[languageIndex]
    this.setData({ languageIndex })
    this.build()
  },
  onOpen(e) {
    wx.navigateTo({ url: '/pages/scenario/scenario?scenario=' + e.currentTarget.dataset.scenario })
  },
})
