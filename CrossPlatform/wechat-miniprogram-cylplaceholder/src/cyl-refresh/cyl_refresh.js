// cyl_refresh.js
// The state and texts of CYLRefresh (the library's MJRefresh-compatible pull-to-refresh) for WeChat Mini Program,
// with no rendering: the cyl-refresh component uses them. Texts: CYLRefresh.strings of the iOS bundle (7 languages).
'use strict'

const { CYLPlaceholderLocalization } = require('../cyl-placeholder/cyl_placeholder')

const TABLES = {
  en: require('./locales/en.js'),
  'zh-Hans': require('./locales/zh-Hans.js'),
  'zh-Hant': require('./locales/zh-Hant.js'),
  ja: require('./locales/ja.js'),
  ko: require('./locales/ko.js'),
  ru: require('./locales/ru.js'),
  uk: require('./locales/uk.js'),
}

/** CYLRefreshState (MJRefreshState). */
const CYLRefreshState = Object.freeze({ Idle: 'Idle', Pulling: 'Pulling', Refreshing: 'Refreshing', NoMoreData: 'NoMoreData' })

/** The header's pull distance that arms a refresh (MJRefreshHeaderHeight). */
const CYLRefreshHeaderHeight = 54
/** The footer's height (MJRefreshFooterHeight). */
const CYLRefreshFooterHeight = 44

/** CYLRefreshConfig.default.languageCode: '' follows CYLPlaceholderLocalization (the app's language). */
let languageCode = ''

function setLanguageCode(code) {
  languageCode = code ? CYLPlaceholderLocalization.resolveLanguage(code) : ''
}

/** A CYLRefresh text ("CYLRefreshHeaderIdleText") in the language in use, else English. */
function refreshText(key, language) {
  const table = TABLES[language || languageCode || CYLPlaceholderLocalization.currentLanguage()] || TABLES.en
  return table[key] != null ? table[key] : TABLES.en[key] != null ? TABLES.en[key] : key
}

const KEYS = {
  header: { Idle: 'CYLRefreshHeaderIdleText', Pulling: 'CYLRefreshHeaderPullingText', Refreshing: 'CYLRefreshHeaderRefreshingText' },
  autoFooter: { Idle: 'CYLRefreshAutoFooterIdleText', Refreshing: 'CYLRefreshAutoFooterRefreshingText', NoMoreData: 'CYLRefreshAutoFooterNoMoreDataText' },
  backFooter: { Idle: 'CYLRefreshBackFooterIdleText', Pulling: 'CYLRefreshBackFooterPullingText', Refreshing: 'CYLRefreshBackFooterRefreshingText', NoMoreData: 'CYLRefreshBackFooterNoMoreDataText' },
}

/** The state text of a header ('header') or footer ('autoFooter' / 'backFooter'). */
function stateText(kind, state, language) {
  const key = (KEYS[kind] || {})[state] || (KEYS[kind] || {}).Idle
  return key ? refreshText(key, language) : ''
}

const pad = (n) => (n < 10 ? '0' : '') + n

/**
 * The header's "last updated" line, as MJRefreshStateHeader: "Last update: Today 09:41", "11-14 09:41" this year,
 * "2025-11-14 09:41" before, "No record" when there is none.
 */
function lastUpdatedText(date, now, language) {
  const prefix = refreshText('CYLRefreshHeaderLastTimeText', language)
  if (!date) return prefix + refreshText('CYLRefreshHeaderNoneLastDateText', language)
  const d = new Date(date)
  const n = now ? new Date(now) : new Date()
  const time = pad(d.getHours()) + ':' + pad(d.getMinutes())
  let day
  if (d.toDateString() === n.toDateString()) day = refreshText('CYLRefreshHeaderDateTodayText', language) + ' ' + time
  else if (d.getFullYear() === n.getFullYear()) day = pad(d.getMonth() + 1) + '-' + pad(d.getDate()) + ' ' + time
  else day = d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()) + ' ' + time
  return prefix + day
}

/** The header's state for a pull distance while not refreshing. */
function headerStateForPull(distance, threshold = CYLRefreshHeaderHeight) {
  return distance >= threshold ? CYLRefreshState.Pulling : CYLRefreshState.Idle
}

/** An icon spec for a state: { path, size } (Lottie .json plays with the animation generic, .gif in <image>). */
function iconForState(icons, state) {
  if (!icons) return null
  const icon = icons[state] || (state !== CYLRefreshState.NoMoreData ? icons.Idle : null)
  if (!icon) return null
  const spec = typeof icon === 'string' ? { path: icon } : icon
  const size = spec.size || 28
  const [width, height] = Array.isArray(size) ? size : [size, size]
  const type = /\.json$/i.test(spec.path) ? 'lottie' : /\.(gif|png|jpe?g|webp|svg)$/i.test(spec.path) ? 'image' : 'unsupported'
  return { path: spec.path, width, height, type }
}

module.exports = {
  CYLRefreshState,
  CYLRefreshHeaderHeight,
  CYLRefreshFooterHeight,
  CYLRefresh: { setLanguageCode, refreshText, stateText, lastUpdatedText, headerStateForPull, iconForState },
}
