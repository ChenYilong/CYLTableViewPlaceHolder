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

/**
 * [EN] How the header moves while it is pulled (CYLRefreshScrollMode on iOS): move (with the content, default), stretch
 *      (fills the whole pulled distance), front (slides in at the top, in front of the content), behind (pinned behind
 *      the content). [CN] 下拉时刷新头的移动方式（对应 iOS 的 CYLRefreshScrollMode）：move（随内容移动，默认）、stretch（拉伸铺满
 *      整个下拉距离）、front（从顶部滑入，位于内容前面）、behind（固定在内容后面）。
 */
const CYLRefreshScrollMode = Object.freeze({ Move: 'move', Stretch: 'stretch', Front: 'front', Behind: 'behind' })

/**
 * [EN] The scroll mode for the component's `scrollMode` and the older `behind` flag (`behind` wins); an unknown value is move.
 * [CN] 由组件的 `scrollMode` 与旧的 `behind` 开关得出的移动方式（`behind` 优先）；未知值按 move 处理。
 */
function scrollModeFor(scrollMode, behind) {
  if (behind) return CYLRefreshScrollMode.Behind
  return Object.values(CYLRefreshScrollMode).includes(scrollMode) ? scrollMode : CYLRefreshScrollMode.Move
}

/** The header's state for a pull distance while not refreshing. */
function headerStateForPull(distance, threshold = CYLRefreshHeaderHeight) {
  return distance >= threshold ? CYLRefreshState.Pulling : CYLRefreshState.Idle
}

/** Finger travel in px below which a touch is a tap, not a drag (the auto footer's drag rule). */
const CYLRefreshDragSlop = 10

/**
 * MJRefreshAutoFooter's drag rule (scrollViewPanStateDidChange): when a drag that moved up ends, the auto footer loads if
 * the content is no taller than the view (it cannot scroll, so its end never scrolls into view) or the view rests at the
 * end (scrolltolower fires only when the end comes into view, not on a second drag there). dragUp is how far the finger
 * moved up in px; scrollTop, scrollHeight and viewHeight are the scroll-view's.
 */
function autoFooterLoadsOnDragEnd({ dragUp, scrollTop, scrollHeight, viewHeight }) {
  if (!(dragUp > CYLRefreshDragSlop) || !(viewHeight > 0)) return false
  if (!(scrollHeight > viewHeight + 2)) return true
  return scrollTop >= scrollHeight - viewHeight - 2
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
  CYLRefreshScrollMode,
  CYLRefreshHeaderHeight,
  CYLRefreshFooterHeight,
  CYLRefreshCupertinoHeaderHeight,
  CYLRefresh: { setLanguageCode, onLanguageChange, reloadLanguage, registerStrings, finishText, refreshText, stateText, lastUpdatedText, headerStateForPull, scrollModeFor, autoFooterLoadsOnDragEnd, iconForState },
}
