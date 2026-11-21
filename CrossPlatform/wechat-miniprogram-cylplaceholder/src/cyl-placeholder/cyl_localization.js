// cyl_localization.js
// CYLPlaceholderLocalization for WeChat Mini Program: the texts of android/placeholder's strings, one
// locales/<locale>.json per language (imported by scripts/import-android-resources.js).
'use strict'

const TABLES = {
  en: require('./locales/en.js'),
  'zh-Hans': require('./locales/zh-Hans.js'),
  'zh-Hant': require('./locales/zh-Hant.js'),
  ja: require('./locales/ja.js'),
  ko: require('./locales/ko.js'),
  ru: require('./locales/ru.js'),
  uk: require('./locales/uk.js'),
}

/** The languages that have a table, in the order of the iOS bundle. */
const SUPPORTED_LANGUAGES = Object.keys(TABLES)

let overrideLanguage = null

/**
 * Maps a system or user language tag ("zh_CN", "zh-TW", "zh-Hant-HK", "en-US", "ja") to a supported language.
 * Unknown languages fall back to English.
 */
function resolveLanguage(tag) {
  if (!tag) return 'en'
  const t = String(tag).replace(/_/g, '-').toLowerCase()
  if (t.startsWith('zh')) {
    if (t.includes('hant') || /-(tw|hk|mo)\b/.test(t)) return 'zh-Hant'
    return 'zh-Hans'
  }
  const base = t.split('-')[0]
  return SUPPORTED_LANGUAGES.includes(base) ? base : 'en'
}

/** The system language of the WeChat client, or English outside a mini program (unit tests). */
function systemLanguage() {
  try {
    // eslint-disable-next-line no-undef
    const info = typeof wx !== 'undefined' && (wx.getAppBaseInfo ? wx.getAppBaseInfo() : wx.getSystemInfoSync())
    return resolveLanguage(info && info.language)
  } catch (e) {
    return 'en'
  }
}

/**
 * Sets the language of every placeholder text (CYLPlaceholderLocalization.language); null follows the system.
 */
function setLanguage(language) {
  overrideLanguage = language ? resolveLanguage(language) : null
}

/** The language in use: the one set with setLanguage, else the system language. */
function currentLanguage() {
  return overrideLanguage || systemLanguage()
}

/**
 * The text for a key of the Android strings without its "cyl_placeholder_" prefix ("action_retry_title").
 * Missing keys fall back to English, then to the key itself.
 */
function localizedString(key, language) {
  const table = TABLES[language || currentLanguage()] || TABLES.en
  return table[key] != null ? table[key] : TABLES.en[key] != null ? TABLES.en[key] : key
}

module.exports = { SUPPORTED_LANGUAGES, resolveLanguage, setLanguage, currentLanguage, localizedString }
