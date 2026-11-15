// cyl_configuration.js
// CYLPlaceholderConfiguration for WeChat Mini Program: builds a placeholder from a configuration object or JSON file,
// translated from android/placeholder's CYLPlaceholderConfiguration.kt (keys and error messages as there).
//
// Top-level keys: scenario, components, overrides ([{ index, … }]), backgroundAction ("" turns it off),
// accessibilityIdentifier. Component keys: type (icon, hint, button, separator, item), title / text or titleKey /
// textKey, animation, style, size, buttonStyle, action, interactionEnabled, highlightStyle (dim, shrink, none),
// repeatCount (0 / "loop", N, "once"), spacingBefore, accessibilityIdentifier, attributes (item).
'use strict'

const { CYLPlaceholderScenarioCatalog, ICON_SIDE } = require('./cyl_scenario_catalog')
const { localizedString } = require('./cyl_localization')
const ICONS = require('./cyl_images')

/** "WifiOff" -> "wifi_off", "CYLPlaceholderScenarioServerErrorTitle" -> "cyl_placeholder_scenario_server_error_title". */
function snake(name) {
  // No regex lookbehind: older iOS WeChat JavaScript engines lack it and the DevTools cannot transpile it.
  return name
    .replace(/([a-z0-9])([A-Z])/g, '$1_$2')
    .replace(/([A-Z])([A-Z][a-z])/g, '$1_$2')
    .toLowerCase()
}

const fail = (message) => {
  const error = new Error(message)
  error.name = 'CYLPlaceholderConfigurationError'
  throw error
}

const isNumber = (v) => typeof v === 'number' && Number.isFinite(v)

/** A literal text, or a core localized text for a key ("CYLPlaceholderScenarioServerErrorTitle"). */
function configuredText(map, literalName, keyName, language) {
  const literal = typeof map[literalName] === 'string' ? map[literalName] : null
  const key = typeof map[keyName] === 'string' ? map[keyName] : null
  if (key) {
    const plain = snake(key).replace(/^cyl_placeholder_/, '')
    const text = localizedString(plain, language)
    return text !== plain ? text : literal != null ? literal : key
  }
  return literal
}

/** All bundled animation names of every scenario (what a configuration's "animation" may name). */
function allAnimationFileNames() {
  return [...new Set(CYLPlaceholderScenarioCatalog.allScenarios.flatMap((s) => CYLPlaceholderScenarioCatalog.animationFileNamesForScenario(s)))]
}

function imageForStyle(value) {
  if (isNumber(value)) {
    if (!Number.isInteger(value) || value < 0 || value >= ICONS.length) return null
    return ICONS[value]
  }
  if (typeof value !== 'string' || !value) return null
  const name = snake(value.replace(/^CYLPlaceholder/i, ''))
  return ICONS.includes(name) ? name : null
}

function sideFromValue(value) {
  let side = null
  if (isNumber(value)) side = value
  else if (Array.isArray(value) && value.length === 2 && isNumber(value[0]) && isNumber(value[1])) side = value[0]
  return side != null && side > 0 && side <= 1000 ? side : null
}

/** The fields every component (and an override) may set. */
function applyConfiguration(component, map) {
  if ('interactionEnabled' in map) {
    if (typeof map.interactionEnabled !== 'boolean') fail('interactionEnabled must be a boolean.')
    component.interactionEnabled = map.interactionEnabled
  }
  if ('highlightStyle' in map) {
    const style = typeof map.highlightStyle === 'string' ? map.highlightStyle.toLowerCase() : ''
    if (!['dim', 'shrink', 'none'].includes(style)) fail('highlightStyle must be dim, shrink or none.')
    component.highlightStyle = style
  }
  if ('repeatCount' in map) {
    const v = map.repeatCount
    let count = -1
    if (typeof v === 'string' && v.toLowerCase() === 'loop') count = 0
    else if (typeof v === 'string' && v.toLowerCase() === 'once') count = 1
    else if (isNumber(v) && Number.isInteger(v)) count = v
    if (count < 0 || count > 10000) fail('repeatCount must be 0 (loop) or more, "loop" or "once".')
    component.repeatCount = count
  }
  if ('spacingBefore' in map) {
    if (!isNumber(map.spacingBefore) || map.spacingBefore < 0) fail('spacingBefore must be a number of points.')
    component.spacingBefore = map.spacingBefore
  }
  if ('accessibilityIdentifier' in map) {
    if (typeof map.accessibilityIdentifier !== 'string') fail('accessibilityIdentifier must be a string.')
    component.accessibilityIdentifier = map.accessibilityIdentifier
  }
  if ('action' in map && map.type == null) {
    const name = typeof map.action === 'string' ? map.action : ''
    if (name) component.action = CYLPlaceholderScenarioCatalog.actionNamed(name)
    else delete component.action
  }
}

/** One component from its dictionary (CYLPlaceholderComponent componentWithDictionary). */
function componentWithDictionary(dictionary, language) {
  if (!dictionary || typeof dictionary !== 'object' || Array.isArray(dictionary)) fail('A component must be a dictionary.')
  const type = typeof dictionary.type === 'string' ? dictionary.type : 'icon'
  const literalTitle = configuredText(dictionary, 'title', 'titleKey', language)
  const title = literalTitle != null ? literalTitle : configuredText(dictionary, 'text', 'textKey', language)
  let action = null
  if ('action' in dictionary) {
    if (typeof dictionary.action !== 'string' || !dictionary.action) fail('A component action must be a non-empty string.')
    action = CYLPlaceholderScenarioCatalog.actionNamed(dictionary.action)
  }
  let component
  switch (type) {
    case 'icon': {
      let image = 'empty'
      if ('style' in dictionary) image = imageForStyle(dictionary.style) || fail('Unknown placeholder style.')
      let side = ICON_SIDE
      if ('size' in dictionary) side = sideFromValue(dictionary.size) || fail('A component size must be [width, height] or a number.')
      const animation = typeof dictionary.animation === 'string' ? dictionary.animation : null
      if (animation && !allAnimationFileNames().includes(animation)) fail(`Bundled animation ${animation} was not found.`)
      component = { type: 'icon', image, title: title || '', side, tinted: image !== 'empty' }
      // Only Lottie files play in the mini program; other formats keep the static icon.
      if (animation && /\.json$/.test(animation)) component.animation = animation
      if (action) component.action = action
      break
    }
    case 'hint':
      component = { type: 'hint', text: title || '' }
      break
    case 'button': {
      let style = 'Filled'
      if ('buttonStyle' in dictionary) {
        const index = ['filled', 'outlined', 'capsule'].indexOf(String(dictionary.buttonStyle).toLowerCase())
        if (index < 0) fail('A button style must be filled, outlined or capsule.')
        style = ['Filled', 'Outlined', 'Capsule'][index]
      }
      if (!action) fail('A button needs an action.')
      component = { type: 'button', title: title != null ? title : CYLPlaceholderScenarioCatalog.localizedTitleForAction(action, language) || '', style, action }
      break
    }
    case 'separator':
      component = { type: 'separator', text: title != null ? title : localizedString('scenario_or_separator', language) }
      break
    case 'item': {
      const a = dictionary.attributes
      if (!a || typeof a !== 'object' || Array.isArray(a)) fail('An item component needs an "attributes" dictionary.')
      // The title attributes the mini program can draw; the rest of the raw item attributes are ignored.
      const insets = Array.isArray(a.CYLPlaceholderItemTitleContentInsets) ? a.CYLPlaceholderItemTitleContentInsets : null
      component = {
        type: 'item',
        title: title != null ? title : typeof a.CYLPlaceholderItemTitle === 'string' ? a.CYLPlaceholderItemTitle : '',
        color: a.CYLTabBarItemTitleColor || '',
        backgroundColor: a.CYLPlaceholderItemTitleBackgroundColor || '',
        cornerRadius: isNumber(a.CYLPlaceholderItemTitleCornerRadius) ? a.CYLPlaceholderItemTitleCornerRadius : 0,
        padding: insets && insets.length === 4 && insets.every(isNumber) ? insets.map((n) => n + 'px').join(' ') : '',
        minWidth: isNumber(a.CYLPlaceholderItemTitleMinimumWidth) ? a.CYLPlaceholderItemTitleMinimumWidth : 0,
      }
      if (action) component.action = action
      break
    }
    default:
      fail(`Unknown component type ${type}.`)
  }
  applyConfiguration(component, dictionary)
  return component
}

/**
 * Parses a configuration (an object, or a JSON string) into what cyl-placeholder renders:
 * { scenario, components, backgroundAction (undefined: the scenario's own, null: off), accessibilityIdentifier }.
 * Throws an Error named CYLPlaceholderConfigurationError with the reason when the configuration is invalid.
 */
function parse(configuration, language) {
  if (typeof configuration === 'string') configuration = parseJSON(configuration)
  if (!configuration || typeof configuration !== 'object' || Array.isArray(configuration)) fail('The configuration must be a dictionary.')
  let scenario = null
  if ('scenario' in configuration) {
    scenario = CYLPlaceholderScenarioCatalog.scenarioNamed(configuration.scenario) || fail(`Unknown scenario ${configuration.scenario}.`)
  }
  let components
  const list = configuration.components
  if (list != null) {
    if (!Array.isArray(list) || list.length === 0) fail('"components" must be a non-empty array.')
    components = list.map((entry) => componentWithDictionary(entry, language))
  } else if (scenario) {
    components = CYLPlaceholderScenarioCatalog.componentsForScenario(scenario, language)
  } else {
    fail('The configuration needs a "scenario" or "components".')
  }
  const overrides = configuration.overrides
  if (overrides != null && !Array.isArray(overrides)) fail('"overrides" must be an array.')
  for (const override of overrides || []) {
    const index = override && typeof override === 'object' ? override.index : undefined
    if (!Number.isInteger(index) || index < 0 || index >= components.length) fail('Each override needs the "index" of an existing component.')
    const { index: _, ...fields } = override
    applyConfiguration(components[index], fields)
  }
  const result = { scenario, components }
  if ('backgroundAction' in configuration) {
    const background = configuration.backgroundAction
    if (typeof background !== 'string') fail('"backgroundAction" must be an action name.')
    result.backgroundAction = background ? CYLPlaceholderScenarioCatalog.actionNamed(background) : null
  } else if (scenario) {
    result.backgroundAction = CYLPlaceholderScenarioCatalog.backgroundActionForScenario(scenario)
  } else {
    result.backgroundAction = null
  }
  if (typeof configuration.accessibilityIdentifier === 'string') result.accessibilityIdentifier = configuration.accessibilityIdentifier
  return result
}

/**
 * Parses an XML property list (as iOS initWithContentsOfURL: reads .plist files): dict, array, string, integer,
 * real, true, false, date (as a string). Binary property lists are refused.
 */
function parsePlist(text) {
  if (/^bplist/.test(text)) fail('A binary property list is not supported; save it as XML.')
  const tokens = text.replace(/<\?xml[^>]*\?>|<!DOCTYPE[^>]*>|<!--[\s\S]*?-->/g, '').match(/<[^>]+>|[^<]+/g) || []
  let i = 0
  const decode = (s) => s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&apos;/g, "'").replace(/&amp;/g, '&')
  const next = () => {
    while (i < tokens.length && !tokens[i].startsWith('<')) i++ // whitespace between elements
    return tokens[i++]
  }
  const textUntil = (close) => {
    let s = ''
    while (i < tokens.length && tokens[i] !== close) s += tokens[i++]
    i++
    return decode(s)
  }
  const value = (tag) => {
    if (!tag) fail('The property list is not complete.')
    if (/^<(\w+)\s*\/>$/.test(tag)) {
      const name = tag.match(/^<(\w+)/)[1]
      if (name === 'true') return true
      if (name === 'false') return false
      if (name === 'string') return ''
      if (name === 'dict') return {}
      if (name === 'array') return []
      fail(`Unsupported property list element <${name}/>.`)
    }
    const name = (tag.match(/^<(\w+)/) || [])[1]
    switch (name) {
      case 'string': case 'date': case 'data': return textUntil(`</${name}>`)
      case 'integer': return parseInt(textUntil('</integer>'), 10)
      case 'real': return parseFloat(textUntil('</real>'))
      case 'array': {
        const list = []
        for (let t = next(); t !== '</array>'; t = next()) list.push(value(t))
        return list
      }
      case 'dict': {
        const dict = {}
        for (let t = next(); t !== '</dict>'; t = next()) {
          if (t !== '<key>') fail('A property list dictionary needs <key> before each value.')
          const key = textUntil('</key>')
          dict[key] = value(next())
        }
        return dict
      }
      default: return fail(`Unsupported property list element ${tag}.`)
    }
  }
  let root = next()
  if (root && root.startsWith('<plist')) root = next()
  return value(root)
}

/** Reads a configuration file of the mini program package or user data ("/configurations/a.json", ".plist"). */
function readConfigurationFile(path) {
  let text
  try {
    // eslint-disable-next-line no-undef
    text = wx.getFileSystemManager().readFileSync(path.replace(/^\//, ''), 'utf8')
  } catch (e) {
    fail('The configuration file cannot be read: ' + (e && (e.errMsg || e.message)))
  }
  if (/\.plist$/i.test(path)) return parsePlist(text)
  // A mini program package keeps only known file types (not .plist or .txt), so a property list ships as
  // <name>.plist.json holding the XML as one JSON string.
  if (/\.plist\.json$/i.test(path)) {
    const xml = parseJSON(text)
    if (typeof xml !== 'string') fail('A .plist.json file must hold the property list as a JSON string.')
    return parsePlist(xml)
  }
  return parseJSON(text)
}

function parseJSON(text) {
  try {
    return JSON.parse(text)
  } catch (e) {
    return fail('The configuration file is not a JSON object.')
  }
}

module.exports = { CYLPlaceholderConfiguration: { parse, componentWithDictionary, readConfigurationFile, parsePlist, allAnimationFileNames } }
