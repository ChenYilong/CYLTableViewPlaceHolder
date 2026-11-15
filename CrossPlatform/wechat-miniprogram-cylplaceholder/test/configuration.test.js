'use strict'
const test = require('node:test')
const assert = require('node:assert')
const fs = require('fs')
const path = require('path')
const { CYLPlaceholderConfiguration: K, CYLPlaceholderAction: A } = require('../src/cyl-placeholder/cyl_placeholder')

const ANDROID = path.join(__dirname, '../../../android/merged/example/src/main/assets/Configurations')
const read = (name) => JSON.parse(fs.readFileSync(path.join(ANDROID, name), 'utf8'))
const throwsWith = (config, message) => assert.throws(() => K.parse(config, 'en'), (e) => e.name === 'CYLPlaceholderConfigurationError' && e.message === message)

test('every Android example configuration parses', () => {
  const files = fs.readdirSync(ANDROID).filter((f) => f.endsWith('.json'))
  assert.strictEqual(files.length, 6)
  for (const f of files) assert.ok(K.parse(read(f), 'en').components.length > 0, f)
})

test('scenario + overrides (Ctrip)', () => {
  const r = K.parse(read('ctrip-retry-or-contact-support.json'), 'zh-Hans')
  assert.strictEqual(r.scenario, 'RetryOrContactSupport')
  assert.deepStrictEqual(r.components.map((c) => c.type), ['icon', 'button', 'separator', 'button'])
  assert.strictEqual(r.components[0].repeatCount, 0)
  assert.strictEqual(r.components[1].highlightStyle, 'shrink')
  assert.strictEqual(r.components[3].highlightStyle, 'dim')
  assert.strictEqual(r.components[3].interactionEnabled, true)
  assert.strictEqual(r.backgroundAction, null)
})

test('backgroundAction "" turns the scenario\'s off; lowercase scenario names', () => {
  const r = K.parse(read('location-permission.json'), 'en')
  assert.strictEqual(r.scenario, 'LocationPermissionDenied')
  assert.strictEqual(r.backgroundAction, null)
  assert.strictEqual(K.parse({ scenario: 'tapToReload' }, 'en').backgroundAction, A.Retry)
  assert.strictEqual(K.parse({ scenario: 'tapToReload', backgroundAction: '' }, 'en').backgroundAction, null)
  assert.strictEqual(K.parse({ scenario: 'noContent', backgroundAction: 'retry' }, 'en').backgroundAction, A.Retry)
})

test('components: styles, sizes, animations, repeat counts, interaction', () => {
  const p = K.parse(read('playback-policies.json'), 'en').components
  assert.deepStrictEqual(p.map((c) => c.repeatCount), [0, 1, 3])
  assert.deepStrictEqual(p.map((c) => c.image), ['hourglass', 'refresh', 'wifi_off'])
  assert.deepStrictEqual(p.map((c) => c.side), [96, 72, 72])
  assert.strictEqual(p[0].animation, 'CYLPlaceholderLoading.json')
  const f = K.parse(read('animation-formats.json'), 'en').components
  assert.deepStrictEqual(f.map((c) => c.animation), [undefined, 'CYLPlaceholderLoading.json', undefined, undefined])
  const s = K.parse(read('interaction-switches.json'), 'en').components
  assert.deepStrictEqual(s.slice(1).map((c) => c.highlightStyle), ['dim', 'shrink', 'none', undefined])
  assert.strictEqual(s[4].interactionEnabled, false)
  assert.strictEqual(s[1].title, 'Retry')
})

test('item attributes and titleKey', () => {
  const r = K.parse(read('raw-item-attributes.json'), 'zh-Hans').components
  assert.strictEqual(r[0].title, '服务器开小差了')
  const item = r[1]
  assert.strictEqual(item.type, 'item')
  assert.strictEqual(item.title, '联系客服')
  assert.strictEqual(item.action, A.ContactSupport)
  assert.strictEqual(item.backgroundColor, '#34C759')
  assert.strictEqual(item.padding, '10px 28px 10px 28px')
  assert.strictEqual(item.accessibilityIdentifier, 'rawItem')
})

test('a JSON string works; errors carry the Android messages', () => {
  assert.strictEqual(K.parse('{"scenario":"NoContent"}', 'en').scenario, 'NoContent')
  throwsWith('[1', 'The configuration file is not a JSON object.')
  throwsWith([], 'The configuration must be a dictionary.')
  throwsWith({}, 'The configuration needs a "scenario" or "components".')
  throwsWith({ scenario: 'Nope' }, 'Unknown scenario Nope.')
  throwsWith({ components: [] }, '"components" must be a non-empty array.')
  throwsWith({ components: [{ type: 'wheel' }] }, 'Unknown component type wheel.')
  throwsWith({ components: [{ type: 'button' }] }, 'A button needs an action.')
  throwsWith({ components: [{ style: 'Unicorn' }] }, 'Unknown placeholder style.')
  throwsWith({ components: [{ size: [1] }] }, 'A component size must be [width, height] or a number.')
  throwsWith({ components: [{ animation: 'x.json' }] }, 'Bundled animation x.json was not found.')
  throwsWith({ components: [{ repeatCount: 'twice' }] }, 'repeatCount must be 0 (loop) or more, "loop" or "once".')
  throwsWith({ components: [{ highlightStyle: 'glow' }] }, 'highlightStyle must be dim, shrink or none.')
  throwsWith({ scenario: 'NoContent', overrides: [{ index: 5 }] }, 'Each override needs the "index" of an existing component.')
  throwsWith({ scenario: 'NoContent', backgroundAction: 3 }, '"backgroundAction" must be an action name.')
})

test('the parser source has no regex lookbehind (older iOS WeChat engines)', () => {
  for (const f of fs.readdirSync(path.join(__dirname, '../src/cyl-placeholder')).filter((x) => x.endsWith('.js'))) {
    assert.doesNotMatch(fs.readFileSync(path.join(__dirname, '../src/cyl-placeholder', f), 'utf8'), /\(\?<[=!]/, f)
  }
})
