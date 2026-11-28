// CYLRefreshI18NExampleViewController: the language of the refresh texts, from the built-in strings or from the
// example's custom table (CYLRefreshCustom.strings, merged into utils/strings/<lang>.js; it overrides only the
// header texts). A NormalHeader (auto transparency) and an AutoNormalFooter, both ending after 2 s.
const { t, effectiveLanguage } = require('../../utils/l10n')
const { CYLRefresh } = require('../../components/cyl-refresh/cyl_refresh')

const LANGUAGE_CODES = ['zh-Hans', 'zh-Hant', 'en', 'ru', 'ko', 'uk', 'ja']

// The example's tables, which hold the CYLRefreshCustom.strings keys.
const EXAMPLE_TABLES = {
  en: require('../../utils/strings/en.js'),
  'zh-Hans': require('../../utils/strings/zh-Hans.js'),
  'zh-Hant': require('../../utils/strings/zh-Hant.js'),
  ja: require('../../utils/strings/ja.js'),
  ko: require('../../utils/strings/ko.js'),
  ru: require('../../utils/strings/ru.js'),
  uk: require('../../utils/strings/uk.js'),
}

// Locale.current.localizedString(forIdentifier:): each language's name in the language in use.
const LANGUAGE_NAMES = {
  en: { 'zh-Hans': 'Chinese, Simplified', 'zh-Hant': 'Chinese, Traditional', en: 'English', ru: 'Russian', ko: 'Korean', uk: 'Ukrainian', ja: 'Japanese' },
  'zh-Hans': { 'zh-Hans': '简体中文', 'zh-Hant': '繁体中文', en: '英语', ru: '俄语', ko: '韩语', uk: '乌克兰语', ja: '日语' },
  'zh-Hant': { 'zh-Hans': '簡體中文', 'zh-Hant': '繁體中文', en: '英文', ru: '俄文', ko: '韓文', uk: '烏克蘭文', ja: '日文' },
  ja: { 'zh-Hans': '中国語(簡体字)', 'zh-Hant': '中国語(繁体字)', en: '英語', ru: 'ロシア語', ko: '韓国語', uk: 'ウクライナ語', ja: '日本語' },
  ko: { 'zh-Hans': '중국어(간체)', 'zh-Hant': '중국어(번체)', en: '영어', ru: '러시아어', ko: '한국어', uk: '우크라이나어', ja: '일본어' },
  ru: { 'zh-Hans': 'китайский, упрощенное письмо', 'zh-Hant': 'китайский, традиционное письмо', en: 'английский', ru: 'русский', ko: 'корейский', uk: 'украинский', ja: 'японский' },
  uk: { 'zh-Hans': 'китайська (спрощена)', 'zh-Hant': 'китайська (традиційна)', en: 'англійська', ru: 'російська', ko: 'корейська', uk: 'українська', ja: 'японська' },
}

/** The custom table (i18nFilename "CYLRefreshCustom") of a language: its CYLRefresh keys; missing keys stay built in. */
function customTable(code) {
  const table = EXAMPLE_TABLES[code] || {}
  const own = {}
  Object.keys(table).forEach((key) => {
    if (key.indexOf('CYLRefresh') === 0) own[key] = table[key]
  })
  return own
}

Page({
  data: { sections: [] },
  onLoad(query) {
    wx.setNavigationBarTitle({ title: decodeURIComponent(query.title || '') })
    const names = LANGUAGE_NAMES[effectiveLanguage()] || LANGUAGE_NAMES.en
    const rows = LANGUAGE_CODES.map((code) => ({ code, name: names[code] }))
    this.setData({
      sections: [
        { header: t('CYLScenarioMJI18nBuiltIn'), custom: false, rows },
        { header: t('CYLScenarioMJI18nCustom'), custom: true, rows },
      ],
    })
  },
  onUnload() {
    clearTimeout(this.headerTimer)
    clearTimeout(this.footerTimer)
    // The configuration is shared by the whole app: give the other pages their default texts back.
    this.dropCustomTable()
    CYLRefresh.setLanguageCode('')
  },
  dropCustomTable() {
    if (this.customCode) CYLRefresh.registerStrings(this.customCode, null)
    this.customCode = ''
  },
  refresh() {
    return this.selectComponent('#refresh')
  },
  onRefresh() {
    clearTimeout(this.headerTimer)
    this.headerTimer = setTimeout(() => this.refresh().endRefreshing(), 2000)
  },
  onLoadMore() {
    clearTimeout(this.footerTimer)
    this.footerTimer = setTimeout(() => this.refresh().endFooterRefreshing(), 2000)
  },
  /** Built-in: clears the custom table and sets languageCode. Custom: uses CYLRefreshCustom plus languageCode. */
  onRow(e) {
    const { code, custom } = e.currentTarget.dataset
    this.dropCustomTable()
    if (custom) {
      CYLRefresh.registerStrings(code, customTable(code))
      this.customCode = code
    }
    // Every mounted cyl-refresh re-renders its texts at once (CYLRefresh.onLanguageChange).
    CYLRefresh.setLanguageCode(code)
    wx.showModal({ content: t('CYLScenarioMJLanguageChanged', code), showCancel: false, confirmText: t('CYLScenarioMJOK') })
  },
})
