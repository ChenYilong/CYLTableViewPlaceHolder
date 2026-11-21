// The example's own texts (CYLScenarioLocalizedString of the iOS example): utils/strings/<lang>.js, imported from
// CYLScenarioExample.bundle by scripts/import-example-strings.js. Scenario texts come from the core
// (CYLPlaceholderLocalization); this file is only for the example's texts and the language switch.
const { CYLPlaceholderLocalization } = require('../components/cyl-placeholder/cyl_placeholder')

const TABLES = {
  en: require('./strings/en.js'),
  'zh-Hans': require('./strings/zh-Hans.js'),
  'zh-Hant': require('./strings/zh-Hant.js'),
  ja: require('./strings/ja.js'),
  ko: require('./strings/ko.js'),
  ru: require('./strings/ru.js'),
  uk: require('./strings/uk.js'),
}

/** Native names and flags of the language menu (CYLScenarioLanguage.swift). */
const LANGUAGES = [
  { code: 'en', name: 'English', flag: '🇺🇸' },
  { code: 'zh-Hans', name: '简体中文', flag: '🇨🇳' },
  { code: 'zh-Hant', name: '繁體中文', flag: '🇭🇰' },
  { code: 'ja', name: '日本語', flag: '🇯🇵' },
  { code: 'ko', name: '한국어', flag: '🇰🇷' },
  { code: 'ru', name: 'Русский', flag: '🇷🇺' },
  { code: 'uk', name: 'Українська', flag: '🇺🇦' },
]

const STORAGE_KEY = 'CYLScenarioLanguage'

/** The language the user chose, or '' to follow the system. */
function chosenLanguage() {
  try {
    return wx.getStorageSync(STORAGE_KEY) || ''
  } catch (e) {
    return ''
  }
}

/** The language in use: the chosen one, else the system's (resolved to a supported language). */
function effectiveLanguage() {
  return chosenLanguage() || CYLPlaceholderLocalization.currentLanguage()
}

/** Applies the stored choice to the core (call once at launch). */
function applyStoredLanguage() {
  CYLPlaceholderLocalization.setLanguage(chosenLanguage() || null)
}

/**
 * Chooses a language ('' follows the system) and rebuilds the whole interface, as the iOS example's
 * cyl_setRootViewControllerProvider does: back to the first tab.
 */
function setLanguage(code) {
  try {
    wx.setStorageSync(STORAGE_KEY, code || '')
  } catch (e) {}
  CYLPlaceholderLocalization.setLanguage(code || null)
  wx.reLaunch({ url: '/pages/scenarios/scenarios' })
}

/**
 * CYLScenarioLocalizedString: the example text for a key in the effective language, else English, else the key.
 * Extra arguments fill %@, %ld, %d and %1$@-style placeholders in order.
 */
function t(key, ...args) {
  const table = TABLES[effectiveLanguage()] || TABLES.en
  let text = table[key] != null ? table[key] : TABLES.en[key] != null ? TABLES.en[key] : key
  let i = 0
  text = text.replace(/%(\d+\$)?(@|ld|lu|d|s|\.\df|f)/g, (_, position, kind) => {
    const index = position ? parseInt(position, 10) - 1 : i++
    const value = args[index]
    if (value === undefined) return ''
    return /f$/.test(kind) && kind.length > 1 ? Number(value).toFixed(Number(kind[1])) : String(value)
  })
  return text
}

/** cyl_showFeedback: a message that closes itself after 1 s. */
function showFeedback(message) {
  wx.showToast({ title: message, icon: 'none', duration: 1000 })
}

module.exports = { t, LANGUAGES, chosenLanguage, effectiveLanguage, applyStoredLanguage, setLanguage, showFeedback }
