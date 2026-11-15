// CYLScenarioListViewController: every scenario of CYLPlaceholderScenarioCatalog (README screenshots, missing
// permissions, business cases), then the configuration files. The language button sits at the top of this page.
const { t, LANGUAGES, chosenLanguage, effectiveLanguage, setLanguage } = require('../../utils/l10n')
const { showTab } = require('../../utils/page')
const {
  CYLPlaceholderScenarioCatalog: Catalog,
  CYLPlaceholderScenarioCategory,
  CYLPlaceholderPermission,
  CYLPlaceholderAction,
} = require('../../components/cyl-placeholder/cyl_placeholder')

/** The files of /configurations (CYLConfigurationFiles.urls(), sorted by name). */
const CONFIGURATION_FILES = [
  'animation-formats.json',
  'ctrip-retry-or-contact-support.json',
  'interaction-switches.json',
  'location-permission.json',
  'playback-policies.json',
  'raw-item-attributes.json',
  'smzdm-capsule.plist',
]

// Stand-ins for the iOS SF Symbols of the row icons (text glyphs keep the teal tint, emoji where none fits).
const SYMBOLS = {
  'location.slash': '📍',
  camera: '📷',
  'photo.on.rectangle': '🖼',
  'mic.slash': '🎙',
  'person.2': '👥',
  calendar: '📅',
  'antenna.radiowaves.left.and.right': '📡',
  'bell.slash': '🔕',
  'lock.shield': '🔒',
  headphones: '🎧',
  gearshape: '⚙',
  cart: '🛒',
  'checkmark.circle': '✓',
  'arrow.clockwise': '↻',
  'rectangle.dashed': '⬚',
  'doc.text': '📄',
}

const PERMISSION_SYMBOLS = {
  [CYLPlaceholderPermission.Location]: 'location.slash',
  [CYLPlaceholderPermission.Camera]: 'camera',
  [CYLPlaceholderPermission.PhotoLibrary]: 'photo.on.rectangle',
  [CYLPlaceholderPermission.Microphone]: 'mic.slash',
  [CYLPlaceholderPermission.Contacts]: 'person.2',
  [CYLPlaceholderPermission.Calendar]: 'calendar',
  [CYLPlaceholderPermission.Bluetooth]: 'antenna.radiowaves.left.and.right',
  [CYLPlaceholderPermission.Notifications]: 'bell.slash',
}

/** The permission, else the action a scenario offers, decides its list icon (symbol(for:)). */
function symbolForScenario(scenario) {
  const byPermission = PERMISSION_SYMBOLS[Catalog.permissionForScenario(scenario)]
  if (byPermission) return byPermission
  if (Catalog.categoryForScenario(scenario) === CYLPlaceholderScenarioCategory.Permission) return 'lock.shield'
  const actions = new Set(Catalog.componentsForScenario(scenario).map((c) => c.action).filter(Boolean))
  if (actions.has(CYLPlaceholderAction.ContactSupport)) return 'headphones'
  if (actions.has(CYLPlaceholderAction.OpenSettings)) return 'gearshape'
  if (actions.has(CYLPlaceholderAction.GoShopping)) return 'cart'
  if (actions.has(CYLPlaceholderAction.Done)) return 'checkmark.circle'
  if (actions.has(CYLPlaceholderAction.Retry) || Catalog.backgroundActionForScenario(scenario)) return 'arrow.clockwise'
  return 'rectangle.dashed'
}

/** "README #01, #02 · 3 components", or only the component count for a business case. */
function detailForScenario(scenario, language) {
  const components = t('CYLScenarioFormatComponents', Catalog.componentsForScenario(scenario, language).length)
  const numbers = Catalog.readmeScreenshotNumbersForScenario(scenario)
  if (!numbers.length) return components
  const list = numbers.map((n) => '#' + String(n).padStart(2, '0')).join(', ')
  return t('CYLScenarioFormatReadmeNumbers', list) + ' · ' + components
}

function buildSections(language) {
  const all = Catalog.allScenarios
  const isPermission = (s) => Catalog.categoryForScenario(s) === CYLPlaceholderScenarioCategory.Permission
  const hasScreenshots = (s) => Catalog.readmeScreenshotNumbersForScenario(s).length > 0
  const row = (scenario) => ({
    key: scenario,
    title: Catalog.localizedNameForScenario(scenario, language),
    subtitle: detailForScenario(scenario, language),
    icon: SYMBOLS[symbolForScenario(scenario)],
    url: '/pages/scenario-detail/scenario-detail?scenario=' + scenario,
  })
  // File names and initializer names are identifiers and are not translated.
  const files = CONFIGURATION_FILES.map((file) => ({
    key: file,
    title: file,
    subtitle: /\.plist$/.test(file)
      ? 'CYLPlaceholderStackView(contentsOf:actions:) · plist'
      : 'CYLPlaceholderStackView(contentsOf:) / (configuration:) · JSON',
    icon: SYMBOLS['doc.text'],
    url: '/pages/configuration/configuration?file=' + encodeURIComponent(file),
  }))
  return [
    { title: t('CYLScenarioSectionReadme'), rows: all.filter((s) => hasScreenshots(s) && !isPermission(s)).map(row) },
    { title: t('CYLScenarioSectionPermissions'), rows: all.filter(isPermission).map(row) },
    { title: t('CYLScenarioSectionBusiness'), rows: all.filter((s) => !hasScreenshots(s) && !isPermission(s)).map(row) },
    { title: t('CYLScenarioSectionConfigurations'), rows: files },
  ]
}

Page({
  data: { sections: [], languageTitle: '', menuTitle: '', menu: [], menuShown: false },

  onLoad() {
    const language = effectiveLanguage()
    const current = LANGUAGES.find((l) => l.code === language) || LANGUAGES[0]
    const chosen = chosenLanguage()
    // The pull-down menu of CYLScenarioLanguage: one item per language, then "Follow system".
    const menu = LANGUAGES.map((l) => ({ code: l.code, title: l.name, checked: chosen === l.code }))
    menu.push({ code: '', title: t('CYLScenarioFollowSystem'), checked: chosen === '', system: true })
    this.setData({
      sections: buildSections(language),
      languageTitle: '🌐 ' + current.flag + ' ' + current.name,
      menuTitle: t('CYLScenarioLanguage'),
      menu,
    })
  },

  onShow() {
    showTab(this, 'scenarios')
  },

  onRowTap(e) {
    wx.navigateTo({ url: e.currentTarget.dataset.url })
  },

  // wx.showActionSheet holds at most 6 items, so the 8-item language menu is a bottom sheet of this page.
  onLanguageTap() {
    this.setData({ menuShown: true })
  },

  onMenuClose() {
    this.setData({ menuShown: false })
  },

  /** Keeps taps inside the sheet from closing it. */
  noop() {},

  onMenuSelect(e) {
    this.setData({ menuShown: false })
    setLanguage(e.currentTarget.dataset.code)
  },
})
