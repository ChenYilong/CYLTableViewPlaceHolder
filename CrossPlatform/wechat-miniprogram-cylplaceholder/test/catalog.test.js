'use strict'
const test = require('node:test')
const assert = require('node:assert')
const fs = require('fs')
const path = require('path')
const {
  CYLPlaceholderScenario,
  CYLPlaceholderAction,
  CYLPlaceholderPermission,
  CYLPlaceholderScenarioCatalog: C,
  CYLPlaceholderLocalization: L,
} = require('../src/cyl-placeholder/cyl_placeholder')

const SRC = path.join(__dirname, '../src/cyl-placeholder')

test('35 scenarios in the Objective-C / Kotlin order', () => {
  assert.strictEqual(C.allScenarios.length, 35)
  assert.strictEqual(C.allScenarios[0], 'NetworkUnavailable')
  assert.strictEqual(C.allScenarios[34], 'HUD')
  const kotlin = fs.readFileSync(path.join(__dirname, '../../../android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderScenario.kt'), 'utf8')
  const body = kotlin.slice(kotlin.indexOf('enum class CYLPlaceholderScenario {'), kotlin.indexOf('enum class CYLPlaceholderScenarioCategory'))
  const names = [...body.matchAll(/^\s{4}([A-Z][A-Za-z]+),$/gm)].map((m) => m[1])
  assert.deepStrictEqual(names, [...C.allScenarios])
})

test('every scenario has components, every icon exists, every text is localized', () => {
  for (const language of L.SUPPORTED_LANGUAGES) {
    for (const s of C.allScenarios) {
      const components = C.componentsForScenario(s, language)
      assert.ok(components.length > 0, s)
      for (const c of components) {
        if (c.type === 'icon') assert.ok(fs.existsSync(path.join(SRC, 'images', c.image + '.png')), c.image)
        for (const key of ['title', 'text']) {
          if (c[key]) assert.doesNotMatch(c[key], /^(scenario|action)_/, `${language} ${s} ${c[key]}`)
        }
        if (c.type === 'button') assert.ok(c.title && c.action, `${language} ${s} button`)
      }
      assert.doesNotMatch(C.localizedNameForScenario(s, language), /^scenario_/)
    }
  }
})

test('animations: the Kotlin file lists, a shipped Lottie file on the main icon, the default generic', () => {
  const kotlin = fs.readFileSync(path.join(__dirname, '../../../android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderScenario.kt'), 'utf8')
  const own = {}
  for (const m of kotlin.matchAll(/CYLPlaceholderScenario\.(\w+) to listOf\(([^)]*)\)/g)) own[m[1]] = [...m[2].matchAll(/"([^"]+)"/g)].map((x) => x[1])
  assert.strictEqual(Object.keys(own).length, 34) // TextOnly has no icon
  for (const s of C.allScenarios) {
    const files = own[s] || []
    assert.deepStrictEqual(C.animationFileNamesForScenario(s).slice(0, files.length), files, s)
    const lottie = C.lottieFileNameForScenario(s)
    const main = C.componentsForScenario(s, 'en').find((c) => c.type === 'icon')
    if (lottie) {
      assert.match(lottie, /^CYLPlaceholder.*\.json$/)
      assert.ok(fs.existsSync(path.join(SRC, 'animations', lottie)), lottie)
      assert.strictEqual(main.animation, lottie, s)
    } else if (main) {
      assert.strictEqual(main.animation, undefined, s)
    }
  }
  assert.strictEqual(C.lottieFileNameForScenario('NoFavorites'), 'CYLPlaceholderNoFavorites.json')
  const json = JSON.parse(fs.readFileSync(path.join(SRC, 'index.json'), 'utf8'))
  assert.ok(fs.existsSync(path.join(SRC, json.componentGenerics.animation.default + '.js')))
})

test('no Android escape sequences are left in the texts', () => {
  for (const language of L.SUPPORTED_LANGUAGES) {
    for (const [key, value] of Object.entries(require(path.join(SRC, 'locales', language + '.js')))) {
      assert.doesNotMatch(value, /\\['"n\\@?]|&(amp|lt|gt|apos|quot);/, `${language} ${key}: ${value}`)
    }
  }
})

test('the locale .js twins match the .json tables', () => {
  for (const language of L.SUPPORTED_LANGUAGES) {
    assert.deepStrictEqual(require(path.join(SRC, 'locales', language + '.js')), JSON.parse(fs.readFileSync(path.join(SRC, 'locales', language + '.json'), 'utf8')))
  }
})

test('names, actions and background taps', () => {
  assert.strictEqual(C.scenarioNamed('CYLPlaceholderScenarioRetryButton'), 'RetryButton')
  assert.strictEqual(C.scenarioNamed('retrybutton'), 'RetryButton')
  assert.strictEqual(C.scenarioNamed('nope'), null)
  assert.strictEqual(C.actionNamed('retry'), CYLPlaceholderAction.Retry)
  assert.strictEqual(C.actionNamed('MyAction'), 'MyAction')
  assert.strictEqual(C.backgroundActionForScenario('TapToReload'), CYLPlaceholderAction.Retry)
  assert.strictEqual(C.backgroundActionForScenario('RetryButton'), null)
  assert.deepStrictEqual(C.readmeScreenshotNumbersForScenario('RetryOrContactSupport'), [3])
})

test('categories and permissions', () => {
  assert.strictEqual(C.categoryForScenario('NoPermission'), 'Permission')
  assert.strictEqual(C.categoryForScenario('CameraPermissionDenied'), 'Permission')
  assert.strictEqual(C.categoryForScenario('EmptyCart'), 'Empty')
  assert.strictEqual(C.categoryForScenario('HUD'), 'Progress')
  assert.strictEqual(C.categoryForScenario('Success'), 'Success')
  assert.strictEqual(C.categoryForScenario('ServerError'), 'LoadFailed')
  assert.strictEqual(C.permissionForScenario('NoPermission'), CYLPlaceholderPermission.None)
  assert.strictEqual(C.permissionForScenario('BluetoothPermissionDenied'), CYLPlaceholderPermission.Bluetooth)
  assert.strictEqual(C.scenarioForPermission(CYLPlaceholderPermission.Location), CYLPlaceholderScenario.LocationPermissionDenied)
})

test('RetryOrContactSupport has two actions and an "or" separator', () => {
  const zh = C.componentsForScenario('RetryOrContactSupport', 'zh-Hans')
  assert.deepStrictEqual(zh.map((c) => c.type), ['icon', 'button', 'separator', 'button'])
  assert.deepStrictEqual(zh.filter((c) => c.action).map((c) => c.action), [CYLPlaceholderAction.Retry, CYLPlaceholderAction.ContactSupport])
  assert.strictEqual(zh[2].text, '或')
})

test('language tags resolve to the supported languages', () => {
  assert.strictEqual(L.resolveLanguage('zh_CN'), 'zh-Hans')
  assert.strictEqual(L.resolveLanguage('zh_TW'), 'zh-Hant')
  assert.strictEqual(L.resolveLanguage('zh-Hant-HK'), 'zh-Hant')
  assert.strictEqual(L.resolveLanguage('en-US'), 'en')
  assert.strictEqual(L.resolveLanguage('fr'), 'en')
  L.setLanguage('ja')
  assert.strictEqual(L.currentLanguage(), 'ja')
  L.setLanguage(null)
  assert.strictEqual(L.currentLanguage(), 'en')
})

test('component files are complete and the wxml binds only known handlers', () => {
  for (const f of ['index.js', 'index.json', 'index.wxml', 'index.wxss']) assert.ok(fs.existsSync(path.join(SRC, f)), f)
  const wxml = fs.readFileSync(path.join(SRC, 'index.wxml'), 'utf8')
  const js = fs.readFileSync(path.join(SRC, 'index.js'), 'utf8')
  for (const m of wxml.matchAll(/(?:bind|catch)tap="(?:\{\{[^}]*'(\w+)'[^}]*\}\}|(\w+))"/g)) {
    const handler = m[1] || m[2]
    assert.match(js, new RegExp(handler + '\\('), handler)
  }
})
