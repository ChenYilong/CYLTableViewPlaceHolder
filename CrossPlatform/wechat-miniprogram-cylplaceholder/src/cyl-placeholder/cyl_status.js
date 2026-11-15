// cyl_status.js
// CYLPlaceholderStatusDisplay and the status part of a configuration (statusBar, display, showsWhenOffline), from
// android/placeholder's CYLPlaceholderStatus.kt and cyl_applyStatusConfiguration (same keys and error messages).
'use strict'

const ICONS = require('./cyl_images')
const { localizedString } = require('./cyl_localization')

/** What a page shows: the red status bar, the placeholder, both or neither (cyl_statusDisplay). */
const CYLPlaceholderStatusDisplay = Object.freeze({ All: 'All', StatusBar: 'StatusBar', Placeholder: 'Placeholder', None: 'None' })

/** CYLPlaceholderStatusViewHeight. */
const CYLPlaceholderStatusViewHeight = 44

const showsStatusBar = (display) => display === CYLPlaceholderStatusDisplay.All || display === CYLPlaceholderStatusDisplay.StatusBar
const showsPlaceholder = (display) => display === CYLPlaceholderStatusDisplay.All || display === CYLPlaceholderStatusDisplay.Placeholder

const fail = (message) => {
  const error = new Error(message)
  error.name = 'CYLPlaceholderConfigurationError'
  throw error
}
const isColor = (v) => /^#([0-9a-f]{3}|[0-9a-f]{6}|[0-9a-f]{8})$/i.test(v)

/** The default bar: CYLChatKit's "network unavailable" message (networkUnavailableItemAttributes). */
function networkUnavailableStatusBar(language) {
  return { text: localizedString('status_network_unavailable', language), image: 'status_fail', titleColor: '', backgroundColor: '' }
}

/** A status bar from its dictionary (CYLPlaceholderStatusView fromConfiguration). */
function statusBarFromConfiguration(configuration, language) {
  if (!configuration || typeof configuration !== 'object' || Array.isArray(configuration)) fail('The status bar configuration must be a dictionary.')
  for (const key of ['text', 'textKey', 'image', 'titleColor', 'backgroundColor', 'accessibilityIdentifier']) {
    if (configuration[key] != null && typeof configuration[key] !== 'string') fail(`"${key}" must be a string.`)
  }
  const bar = networkUnavailableStatusBar(language)
  if (configuration.image != null) {
    if (configuration.image.startsWith('system:')) fail('An SF Symbol is an iOS image; name a drawable.')
    const name = configuration.image.replace(/^cyl_placeholder_/, '')
    if (!ICONS.includes(name)) fail(`The image ${configuration.image} was not found.`)
    bar.image = name
  }
  if (configuration.titleColor != null) {
    if (!isColor(configuration.titleColor)) fail('"titleColor" is not a color.')
    bar.titleColor = configuration.titleColor
  }
  if (configuration.backgroundColor != null) {
    if (!isColor(configuration.backgroundColor)) fail('"backgroundColor" is not a color.')
    bar.backgroundColor = configuration.backgroundColor
  }
  if (configuration.textKey) {
    const plain = configuration.textKey
      .replace(/([a-z0-9])([A-Z])/g, '$1_$2')
      .replace(/([A-Z])([A-Z][a-z])/g, '$1_$2')
      .toLowerCase()
      .replace(/^cyl_placeholder_/, '')
    const text = localizedString(plain, language)
    bar.text = text !== plain ? text : configuration.text != null ? configuration.text : configuration.textKey
  } else if (configuration.text != null) {
    bar.text = configuration.text
  }
  if (configuration.accessibilityIdentifier != null) bar.accessibilityIdentifier = configuration.accessibilityIdentifier
  return bar
}

/**
 * The status part of a configuration (cyl_applyStatusConfiguration): { display, statusBar (or null: keep the current
 * bar), resetStatusBar, showsWhenOffline (undefined: unchanged) }. Throws CYLPlaceholderConfigurationError.
 */
function parseStatusConfiguration(configuration, language) {
  if (!configuration || typeof configuration !== 'object' || Array.isArray(configuration)) fail('The configuration must be a dictionary.')
  const barValue = configuration.statusBar
  let statusBar = null
  if (barValue && typeof barValue === 'object' && !Array.isArray(barValue)) {
    statusBar = statusBarFromConfiguration(barValue, language)
  } else if (barValue != null && !(typeof barValue === 'boolean' || barValue === 'networkUnavailable')) {
    fail('"statusBar" must be true, "networkUnavailable" or a dictionary.')
  }
  const wantsBar = barValue != null && barValue !== false
  const displays = {
    statusAndPlaceholder: CYLPlaceholderStatusDisplay.All,
    status: CYLPlaceholderStatusDisplay.StatusBar,
    placeholder: CYLPlaceholderStatusDisplay.Placeholder,
    none: CYLPlaceholderStatusDisplay.None,
  }
  let display
  if (configuration.display != null) display = displays[configuration.display]
  else display = wantsBar ? CYLPlaceholderStatusDisplay.All : CYLPlaceholderStatusDisplay.Placeholder
  if (!display) fail('"display" must be "statusAndPlaceholder", "status", "placeholder" or "none".')
  const offline = configuration.showsWhenOffline
  if (offline != null && typeof offline !== 'boolean') fail('"showsWhenOffline" must be a boolean.')
  return {
    display,
    statusBar: statusBar || (wantsBar ? networkUnavailableStatusBar(language) : null),
    showsWhenOffline: offline == null ? undefined : offline,
  }
}

module.exports = {
  CYLPlaceholderStatusDisplay,
  CYLPlaceholderStatusViewHeight,
  CYLPlaceholderStatus: { showsStatusBar, showsPlaceholder, networkUnavailableStatusBar, statusBarFromConfiguration, parseStatusConfiguration },
}
