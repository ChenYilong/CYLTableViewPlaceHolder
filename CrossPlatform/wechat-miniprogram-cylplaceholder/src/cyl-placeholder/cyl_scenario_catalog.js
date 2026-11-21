// cyl_scenario_catalog.js
// CYLPlaceholderScenarioCatalog for WeChat Mini Program, translated from android/placeholder's
// CYLPlaceholderScenario.kt (itself the Kotlin port of the iOS CYLPlaceholderScenario.h). A scenario is only a list of
// components plus an optional background tap action; the cyl-placeholder component renders it.
'use strict'

const { localizedString, currentLanguage } = require('./cyl_localization')

/** The 35 scenarios, in the order of the Objective-C enum (CYLPlaceholderScenario). */
const CYLPlaceholderScenario = Object.freeze({
  NetworkUnavailable: 'NetworkUnavailable',
  NoContent: 'NoContent',
  TapToReload: 'TapToReload',
  LoadFailedWithHint: 'LoadFailedWithHint',
  TapToReconnect: 'TapToReconnect',
  RetryButton: 'RetryButton',
  RetryOutlinedButton: 'RetryOutlinedButton',
  RetryWithHint: 'RetryWithHint',
  RetryOrContactSupport: 'RetryOrContactSupport',
  IllustrationRetry: 'IllustrationRetry',
  RefreshIcon: 'RefreshIcon',
  TitleAboveIllustration: 'TitleAboveIllustration',
  TextOnly: 'TextOnly',
  TapMeRetry: 'TapMeRetry',
  LocationPermissionDenied: 'LocationPermissionDenied',
  NoSearchResults: 'NoSearchResults',
  EmptyCart: 'EmptyCart',
  NoOrders: 'NoOrders',
  NoFavorites: 'NoFavorites',
  NoMessages: 'NoMessages',
  NoNotifications: 'NoNotifications',
  NoPermission: 'NoPermission',
  CameraPermissionDenied: 'CameraPermissionDenied',
  PhotoLibraryPermissionDenied: 'PhotoLibraryPermissionDenied',
  MicrophonePermissionDenied: 'MicrophonePermissionDenied',
  ContactsPermissionDenied: 'ContactsPermissionDenied',
  CalendarPermissionDenied: 'CalendarPermissionDenied',
  BluetoothPermissionDenied: 'BluetoothPermissionDenied',
  NotificationPermissionDenied: 'NotificationPermissionDenied',
  ServerError: 'ServerError',
  SyncFailed: 'SyncFailed',
  Loading: 'Loading',
  Uploading: 'Uploading',
  Success: 'Success',
  HUD: 'HUD',
})

const CYLPlaceholderScenarioCategory = Object.freeze({
  LoadFailed: 'LoadFailed',
  Empty: 'Empty',
  Permission: 'Permission',
  Progress: 'Progress',
  Success: 'Success',
})

const CYLPlaceholderPermission = Object.freeze({
  None: 'None',
  Location: 'Location',
  Camera: 'Camera',
  PhotoLibrary: 'PhotoLibrary',
  Microphone: 'Microphone',
  Contacts: 'Contacts',
  Calendar: 'Calendar',
  Bluetooth: 'Bluetooth',
  Notifications: 'Notifications',
})

const CYLPlaceholderButtonStyle = Object.freeze({ Filled: 'Filled', Outlined: 'Outlined', Capsule: 'Capsule' })

/** The built-in actions; an app may use its own strings as well. Same values as iOS and Android. */
const CYLPlaceholderAction = Object.freeze({
  Retry: 'CYLPlaceholderActionRetry',
  ContactSupport: 'CYLPlaceholderActionContactSupport',
  OpenSettings: 'CYLPlaceholderActionOpenSettings',
  GoShopping: 'CYLPlaceholderActionGoShopping',
  Done: 'CYLPlaceholderActionDone',
  ChooseManually: 'CYLPlaceholderActionChooseManually',
})

const ICON_SIDE = 96
const ILLUSTRATION_SIDE = 160
const ACCENT = '#007AFF'

const ALL_SCENARIOS = Object.freeze(Object.values(CYLPlaceholderScenario))

const PERMISSION_SCENARIOS = [
  CYLPlaceholderScenario.NoPermission,
  CYLPlaceholderScenario.LocationPermissionDenied,
  CYLPlaceholderScenario.CameraPermissionDenied,
  CYLPlaceholderScenario.PhotoLibraryPermissionDenied,
  CYLPlaceholderScenario.MicrophonePermissionDenied,
  CYLPlaceholderScenario.ContactsPermissionDenied,
  CYLPlaceholderScenario.CalendarPermissionDenied,
  CYLPlaceholderScenario.BluetoothPermissionDenied,
  CYLPlaceholderScenario.NotificationPermissionDenied,
]
const PERMISSIONS = Object.values(CYLPlaceholderPermission)

/** "NoContent" -> "no_content", "HUD" -> "h_u_d" (the Android resource names). */
function snake(name) {
  return name.replace(/(?!^)(?=[A-Z])/g, '_').toLowerCase()
}

/** The scenario for its name, with or without the "CYLPlaceholderScenario" prefix, case-insensitive. */
function scenarioNamed(name) {
  if (!name) return null
  const plain = String(name).toLowerCase().replace(/^cylplaceholderscenario/, '')
  return ALL_SCENARIOS.find((s) => s.toLowerCase() === plain) || null
}

/** The action for a short name ("retry", "CYLPlaceholderActionRetry"); unknown names are returned unchanged. */
function actionNamed(name) {
  const plain = String(name).toLowerCase().replace(/^cylplaceholderaction/, '')
  const found = Object.entries(CYLPlaceholderAction).find(([k]) => k.toLowerCase() === plain)
  return found ? found[1] : name
}

const ACTION_TITLE_KEYS = {
  [CYLPlaceholderAction.Retry]: 'action_retry_title',
  [CYLPlaceholderAction.ContactSupport]: 'action_contact_support_title',
  [CYLPlaceholderAction.OpenSettings]: 'action_open_settings_title',
  [CYLPlaceholderAction.GoShopping]: 'action_go_shopping_title',
  [CYLPlaceholderAction.Done]: 'action_done_title',
  [CYLPlaceholderAction.ChooseManually]: 'action_choose_manually_title',
}

/** The localized button title of a built-in action, or null for an app's own action. */
function localizedTitleForAction(action, language) {
  const key = ACTION_TITLE_KEYS[action]
  return key ? localizedString(key, language) : null
}

/** The localized display name of a scenario (the example's list). */
function localizedNameForScenario(scenario, language) {
  return localizedString('scenario_' + snake(scenario) + '_name', language)
}

/** The README screenshot numbers a scenario stands for (empty for scenarios without one). */
function readmeScreenshotNumbersForScenario(scenario) {
  return (
    {
      NetworkUnavailable: [4, 5, 6, 25, 36],
      NoContent: [7, 9, 10],
      TapToReload: [13, 14, 15, 24, 26, 28, 31, 32, 37, 42, 43],
      LoadFailedWithHint: [21, 22, 27, 29],
      TapToReconnect: [8],
      RetryButton: [1, 2, 11, 19],
      LocationPermissionDenied: [20],
      RetryOutlinedButton: [33, 38, 39],
      RetryWithHint: [16, 23, 40],
      RetryOrContactSupport: [3],
      IllustrationRetry: [18],
      RefreshIcon: [12],
      TitleAboveIllustration: [17],
      TextOnly: [30, 41],
      TapMeRetry: [34, 35],
    }[scenario] || []
  )
}

/** The action of a tap anywhere on the placeholder, or null. */
function backgroundActionForScenario(scenario) {
  return [
    CYLPlaceholderScenario.TapToReload,
    CYLPlaceholderScenario.TapToReconnect,
    CYLPlaceholderScenario.TitleAboveIllustration,
    CYLPlaceholderScenario.TextOnly,
  ].includes(scenario)
    ? CYLPlaceholderAction.Retry
    : null
}

// The animation files of each scenario, as in CYLPlaceholderScenario.kt: the main icon's own files, then variants.
const ICON_FILES = {
  NetworkUnavailable: ['CYLPlaceholderNoInternet.json'],
  NoContent: ['CYLPlaceholderEmpty.json'],
  TapToReload: ['CYLPlaceholderRefresh.json'],
  LoadFailedWithHint: ['CYLPlaceholderLoadFailed.json'],
  TapToReconnect: ['CYLPlaceholderNoInternet.json'],
  RetryButton: ['CYLPlaceholderSad.json'],
  RetryOutlinedButton: ['CYLPlaceholderLoadFailed.json'],
  RetryWithHint: ['CYLPlaceholderNoInternet.json'],
  RetryOrContactSupport: ['CYLPlaceholderServerError.json'],
  IllustrationRetry: ['CYLPlaceholderCloudOff.json'],
  RefreshIcon: ['CYLPlaceholderSad.json', 'CYLPlaceholderRefresh.json'],
  TitleAboveIllustration: ['CYLPlaceholderPullHint.pag'],
  TapMeRetry: ['CYLPlaceholderTapHint.json', 'CYLPlaceholderCloudOff.json'],
  NoSearchResults: ['CYLPlaceholderNoResults.json'],
  EmptyCart: ['CYLPlaceholderEmptyCart.json'],
  NoOrders: ['CYLPlaceholderNoOrders.json'],
  NoFavorites: ['CYLPlaceholderNoFavorites.pag'],
  NoMessages: ['CYLPlaceholderNoMessages.json'],
  NoNotifications: ['CYLPlaceholderNoNotifications.json'],
  NoPermission: ['CYLPlaceholderNoPermission.json'],
  LocationPermissionDenied: ['CYLPlaceholderLocationPermission.json'],
  CameraPermissionDenied: ['CYLPlaceholderCameraPermission.json'],
  PhotoLibraryPermissionDenied: ['CYLPlaceholderPhotoLibraryPermission.json'],
  MicrophonePermissionDenied: ['CYLPlaceholderMicrophonePermission.json'],
  ContactsPermissionDenied: ['CYLPlaceholderContactsPermission.json'],
  CalendarPermissionDenied: ['CYLPlaceholderCalendarPermission.json'],
  BluetoothPermissionDenied: ['CYLPlaceholderBluetoothPermission.json'],
  NotificationPermissionDenied: ['CYLPlaceholderNotificationPermission.json'],
  ServerError: ['CYLPlaceholderServerError.json'],
  SyncFailed: ['CYLPlaceholderCloudOff.json'],
  Loading: ['CYLPlaceholderLoading.json'],
  Uploading: ['CYLPlaceholderUploading.gif'],
  Success: ['CYLPlaceholderSuccess.riv'],
  HUD: ['CYLRefreshActivity.gif'],
}
const VARIANT_FILES = {
  NoContent: ['CYLPlaceholderNoDrafts.json'],
  TapToReload: ['CYLPlaceholderPullToRefresh.riv'],
  RetryOrContactSupport: ['CYLPlaceholderContactSupport.json'],
  RefreshIcon: ['CYLPlaceholderRefresh.json', 'CYLPlaceholderPullToRefresh.riv'],
  TitleAboveIllustration: ['CYLPlaceholderPullToRefresh.riv'],
  TapMeRetry: ['CYLPlaceholderNoInternet.json'],
  LocationPermissionDenied: ['CYLPlaceholderLocation.json'],
  NoFavorites: ['CYLPlaceholderNoFavorites.gif', 'CYLPlaceholderNoFavorites.json'],
  NoPermission: ['CYLPlaceholderSettings.json'],
  SyncFailed: ['CYLPlaceholderLoadingInfinity.json'],
  Loading: ['CYLPlaceholderLoading.pag', 'CYLPlaceholderLoading.riv', 'CYLPlaceholderLoadingInfinity.json', 'CYLPlaceholderProgress.pag'],
  Uploading: ['CYLPlaceholderProgress.pag'],
  Success: ['CYLPlaceholderSuccess.json', 'CYLPlaceholderCelebrate.json'],
  HUD: ['CYLRefreshMaterialSpinner.json', 'CYLRefreshGradientSpinner.json', 'CYLRefreshRing.gif', 'CYLPlaceholderProgress.pag', 'CYLRefreshIcon.riv'],
}

/** Every animation file of a scenario (Lottie / PAG / Rive / GIF), the main icon's first, as on iOS and Android. */
function animationFileNamesForScenario(scenario) {
  return [...new Set([...(ICON_FILES[scenario] || []), ...(VARIANT_FILES[scenario] || [])])]
}

/**
 * The Lottie file the mini program plays for the scenario's main icon: the first `CYLPlaceholder*.json` of
 * animationFileNamesForScenario (PAG, Rive and GIF need players the mini program package does not ship), or null.
 */
function lottieFileNameForScenario(scenario) {
  return animationFileNamesForScenario(scenario).find((f) => /^CYLPlaceholder.*\.json$/.test(f)) || null
}

function permissionForScenario(scenario) {
  const index = PERMISSION_SCENARIOS.indexOf(scenario)
  return index <= 0 ? CYLPlaceholderPermission.None : PERMISSIONS[index]
}

function scenarioForPermission(permission) {
  const index = PERMISSIONS.indexOf(permission)
  return PERMISSION_SCENARIOS[index < 0 ? 0 : index]
}

function categoryForScenario(scenario) {
  if (scenario === CYLPlaceholderScenario.NoPermission || permissionForScenario(scenario) !== CYLPlaceholderPermission.None) {
    return CYLPlaceholderScenarioCategory.Permission
  }
  if (['NoContent', 'NoSearchResults', 'EmptyCart', 'NoOrders', 'NoFavorites', 'NoMessages', 'NoNotifications'].includes(scenario)) {
    return CYLPlaceholderScenarioCategory.Empty
  }
  if (['Loading', 'Uploading', 'HUD'].includes(scenario)) return CYLPlaceholderScenarioCategory.Progress
  if (scenario === CYLPlaceholderScenario.Success) return CYLPlaceholderScenarioCategory.Success
  return CYLPlaceholderScenarioCategory.LoadFailed
}

/**
 * The components of a scenario, as plain objects the cyl-placeholder component renders:
 * { type: 'icon' | 'text' | 'hint' | 'button' | 'separator', image, side, tinted, title, text, style, action,
 *   spacingBefore, size, color }.
 */
function componentsForScenario(scenario, language) {
  const lang = language || currentLanguage()
  const t = (key) => localizedString(key, lang)
  const s = 'scenario_' + snake(scenario) + '_'
  const icon = (image, titleKey, side = ICON_SIDE, tinted = true, extra = {}) => ({
    type: 'icon',
    image,
    title: titleKey ? t(titleKey) : '',
    side,
    tinted,
    ...extra,
  })
  const own = (image, side) => icon(image, s + 'title', side)
  const hint = (key) => ({ type: 'hint', text: t(key) })
  const button = (action, style, extra = {}) => ({ type: 'button', title: localizedTitleForAction(action, lang) || '', style, action, ...extra })
  const titled = (titleKey, style, action, extra = {}) => ({ type: 'button', title: t(titleKey), style, action, ...extra })
  const text = (key, extra = {}) => ({ type: 'text', text: t(key), ...extra })
  const permission = (image) => [own(image), hint(s + 'hint'), button(CYLPlaceholderAction.OpenSettings, 'Filled')]
  const A = CYLPlaceholderAction

  const components = staticComponents()
  // The first icon is the scenario's main icon; it carries the Lottie file played when animations are on.
  const animation = lottieFileNameForScenario(scenario)
  const main = components.find((c) => c.type === 'icon')
  if (main && animation) main.animation = animation
  return components

  function staticComponents() {
  switch (scenario) {
    case 'NetworkUnavailable': return [own('wifi_off')]
    case 'NoContent': return [icon('empty', s + 'title', ILLUSTRATION_SIDE, false)]
    case 'TapToReload': return [own('refresh')]
    case 'LoadFailedWithHint': return [own('error_outline'), hint(s + 'hint')]
    case 'TapToReconnect': return [own('signal_wifi_off'), hint(s + 'hint')]
    case 'RetryButton': return [own('no_internet'), button(A.Retry, 'Filled')]
    case 'RetryOutlinedButton': return [own('report_problem'), button(A.Retry, 'Outlined')]
    case 'RetryWithHint': return [own('wifi_off'), hint(s + 'hint'), titled('scenario_reload_title', 'Outlined', A.Retry)]
    case 'RetryOrContactSupport': return [
      own('cloud_off'),
      button(A.Retry, 'Filled'),
      { type: 'separator', text: t('scenario_or_separator') },
      button(A.ContactSupport, 'Outlined', { spacingBefore: 14 }),
    ]
    case 'IllustrationRetry': return [icon('cloud_off', null, ILLUSTRATION_SIDE), titled('scenario_tap_to_retry_title', 'Capsule', A.Retry)]
    case 'RefreshIcon': return [own('help'), icon('refresh', null, 44, true, { action: A.Retry, spacingBefore: 28 })]
    case 'TitleAboveIllustration': return [text(s + 'title'), icon('refresh', null, ILLUSTRATION_SIDE)]
    case 'TextOnly': return [text(s + 'title', { size: 20 }), hint(s + 'hint')]
    case 'TapMeRetry': return [
      text('scenario_tap_me_title', { color: ACCENT }),
      icon('info', null, 36, true, { spacingBefore: 4 }),
      titled('scenario_reload_now_title', 'Filled', A.Retry, { spacingBefore: 4 }),
      icon('cloud_off', null, 96, true, { spacingBefore: 12 }),
    ]
    case 'NoSearchResults': return [own('search_off'), hint(s + 'hint')]
    case 'EmptyCart': return [own('empty_cart', ILLUSTRATION_SIDE), button(A.GoShopping, 'Outlined')]
    case 'NoOrders': return [own('archive'), button(A.GoShopping, 'Filled')]
    case 'NoFavorites': return [own('favorite', ILLUSTRATION_SIDE), hint(s + 'hint')]
    case 'NoMessages': return [own('inbox')]
    case 'NoNotifications': return [own('notifications_off'), hint(s + 'hint')]
    case 'NoPermission': return [own('locked'), hint(s + 'hint'), button(A.OpenSettings, 'Filled')]
    case 'LocationPermissionDenied': return [
      ...permission('location_off'),
      titled('scenario_choose_address_title', 'Outlined', A.ChooseManually, { spacingBefore: 12 }),
    ]
    case 'CameraPermissionDenied': return permission('video_off')
    case 'PhotoLibraryPermissionDenied': return permission('photo_library')
    case 'MicrophonePermissionDenied': return permission('music_off')
    case 'ContactsPermissionDenied': return permission('group_off')
    case 'CalendarPermissionDenied': return permission('event_busy')
    case 'BluetoothPermissionDenied': return permission('bluetooth_disabled')
    case 'NotificationPermissionDenied': return permission('notifications_off')
    case 'ServerError': return [own('cloud_off'), hint(s + 'hint'), button(A.Retry, 'Filled')]
    case 'SyncFailed': return [own('sync_problem'), button(A.Retry, 'Outlined')]
    case 'Loading': return [own('hourglass', ILLUSTRATION_SIDE)]
    case 'Uploading': return [own('upload_off', ILLUSTRATION_SIDE)]
    case 'Success': return [own('check_circle', ILLUSTRATION_SIDE), button(A.Done, 'Filled')]
    case 'HUD': return [own('hourglass', 56)]
    default: return []
  }
  }
}

/**
 * Whether a bundled animation is a spinner (loading, progress, activity…), which loops by default so a loading
 * indicator never freezes; every other one plays once and rests on its last frame (iOS
 * CYLScenarioAnimationLoopsByDefault, e8e9eb6, 2026-11-19; the examples' loopsByDefault list).
 */
const LOOPING_WORDS = ['Loading', 'Spinner', 'Progress', 'Throbber', 'Activity', 'Ring', 'Dots', 'Cycle', 'Arc',
  'Clockwise', 'Uploading', 'Infinity']
function animationLoopsByDefault(fileName) {
  return LOOPING_WORDS.some((word) => String(fileName).includes(word))
}

const CYLPlaceholderScenarioCatalog = {
  animationLoopsByDefault,
  animationFileNamesForScenario,
  lottieFileNameForScenario,
  allScenarios: ALL_SCENARIOS,
  scenarioNamed,
  actionNamed,
  localizedTitleForAction,
  localizedNameForScenario,
  readmeScreenshotNumbersForScenario,
  backgroundActionForScenario,
  permissionForScenario,
  scenarioForPermission,
  categoryForScenario,
  componentsForScenario,
}

module.exports = {
  CYLPlaceholderScenario,
  CYLPlaceholderScenarioCategory,
  CYLPlaceholderPermission,
  CYLPlaceholderButtonStyle,
  CYLPlaceholderAction,
  CYLPlaceholderScenarioCatalog,
  ICON_SIDE,
  ILLUSTRATION_SIDE,
  ACCENT,
}
