// cyl_refresh.js
// The state and texts of CYLRefresh (the library's MJRefresh-compatible pull-to-refresh) for WeChat Mini Program,
// with no rendering: the cyl-refresh component uses them. Texts: CYLRefresh.strings of the iOS bundle (7 languages).
'use strict'

const { CYLPlaceholderLocalization } = require('../cyl-placeholder/cyl_placeholder')
const { cylIconSource } = require('../cyl-placeholder/cyl_animated_icon')

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
/** The Cupertino header's height (CYLRefreshCupertinoHeader, as flutter_easy_refresh's CupertinoHeader). */
const CYLRefreshCupertinoHeaderHeight = 60

/** CYLRefreshConfig.default.languageCode: '' follows CYLPlaceholderLocalization (the app's language). */
let languageCode = ''

/** Called with the new code whenever setLanguageCode changes it; mounted cyl-refresh components re-render. */
const languageListeners = []

function setLanguageCode(code) {
  const next = code ? CYLPlaceholderLocalization.resolveLanguage(code) : ''
  const changed = next !== languageCode
  languageCode = next
  if (changed) languageListeners.slice().forEach((fn) => fn(next))
}

/** Subscribes to language changes; returns the unsubscribe function. */
function onLanguageChange(fn) {
  languageListeners.push(fn)
  return () => {
    const i = languageListeners.indexOf(fn)
    if (i >= 0) languageListeners.splice(i, 1)
  }
}

/** Notifies the components after the app changed its own language (CYLPlaceholderLocalization.setLanguage). */
function reloadLanguage() {
  languageListeners.slice().forEach((fn) => fn(languageCode))
}

/**
 * Custom string tables (a custom CYLRefresh.strings / bundle): registerStrings({ CYLRefreshHeaderIdleText: '…' })
 * overrides keys in every language, registerStrings('ja', {…}) in one. Pass null to drop the overrides.
 */
const customTables = {}
function registerStrings(language, table) {
  if (typeof language !== 'string') {
    table = language
    language = '*'
  }
  if (table) customTables[language] = Object.assign({}, customTables[language], table)
  else delete customTables[language]
  reloadLanguage()
}

/** A CYLRefresh text ("CYLRefreshHeaderIdleText") in the language in use, else English. */
function refreshText(key, language) {
  const lang = language || languageCode || CYLPlaceholderLocalization.currentLanguage()
  const own = customTables[lang] || {}
  if (own[key] != null) return own[key]
  if (customTables['*'] && customTables['*'][key] != null) return customTables['*'][key]
  const table = TABLES[language || languageCode || CYLPlaceholderLocalization.currentLanguage()] || TABLES.en
  return table[key] != null ? table[key] : TABLES.en[key] != null ? TABLES.en[key] : key
}

const KEYS = {
  header: { Idle: 'CYLRefreshHeaderIdleText', Pulling: 'CYLRefreshHeaderPullingText', Refreshing: 'CYLRefreshHeaderRefreshingText' },
  autoFooter: { Idle: 'CYLRefreshAutoFooterIdleText', Refreshing: 'CYLRefreshAutoFooterRefreshingText', NoMoreData: 'CYLRefreshAutoFooterNoMoreDataText' },
  trailer: { Idle: 'CYLRefreshTrailerIdleText', Pulling: 'CYLRefreshTrailerPullingText' },
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

/** The finish phase text: "Refresh complete" / "Refresh failed" (part 'header') or "Load complete" / "Load failed". */
function finishText(part, success, language) {
  const p = part === 'footer' ? 'Footer' : 'Header'
  return refreshText('CYLRefresh' + p + (success === false ? 'Failed' : 'Finished') + 'Text', language)
}

/** The header's state for a pull distance while not refreshing. */
function headerStateForPull(distance, threshold = CYLRefreshHeaderHeight) {
  return distance >= threshold ? CYLRefreshState.Pulling : CYLRefreshState.Idle
}

/**
 * An icon spec for a state: { path, size }. cyl-refresh draws it with cyl-animated-item (CYLTabBarController's
 * CYLAnimatedItem): Lottie (.json / .lottie), PAG, Rive (.riv) and SVGA files play through the engine the page passes in
 * the abstract nodes (`animation` for Lottie, `cyl-pag-view`, `cyl-rive-view`, `cyl-svga-view`) and show the component
 * placeholder until it is ready or after it fails; GIF, PNG, JPEG, WebP and SVG are images. Other files are
 * 'unsupported' and show the spinner.
 */
function iconForState(icons, state) {
  if (!icons) return null
  const icon = icons[state] || (state !== CYLRefreshState.NoMoreData ? icons.Idle : null)
  if (!icon) return null
  const spec = typeof icon === 'string' ? { path: icon } : icon
  const size = spec.size || 28
  const [width, height] = Array.isArray(size) ? size : [size, size]
  const source = cylIconSource(spec.path)
  const isImage = source.type === 'gif' || /\.(png|jpe?g|webp|svg)$/i.test(String(spec.path || '').split(/[?#]/)[0])
  const type = source.animationUrl ? source.type : isImage ? 'image' : 'unsupported'
  return { path: spec.path, width, height, type, image: type === 'image' ? spec.path : '', animationUrl: source.animationUrl }
}

module.exports = {
  CYLRefreshState,
  CYLRefreshHeaderHeight,
  CYLRefreshFooterHeight,
  CYLRefreshCupertinoHeaderHeight,
  CYLRefresh: { setLanguageCode, onLanguageChange, reloadLanguage, registerStrings, finishText, refreshText, stateText, lastUpdatedText, headerStateForPull, iconForState },
}
