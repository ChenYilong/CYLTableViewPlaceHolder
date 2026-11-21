'use strict'
const test = require('node:test')
const assert = require('node:assert')
const { CYLPlaceholderStatus: S, CYLPlaceholderStatusDisplay: D, CYLPlaceholderStatusViewHeight } = require('../src/cyl-placeholder/cyl_placeholder')

const throwsWith = (fn, message) => assert.throws(fn, (e) => e.name === 'CYLPlaceholderConfigurationError' && e.message === message)

test('display flags and the default bar', () => {
  assert.strictEqual(CYLPlaceholderStatusViewHeight, 44)
  assert.deepStrictEqual([D.All, D.StatusBar, D.Placeholder, D.None].map(S.showsStatusBar), [true, true, false, false])
  assert.deepStrictEqual([D.All, D.StatusBar, D.Placeholder, D.None].map(S.showsPlaceholder), [true, false, true, false])
  const zh = S.networkUnavailableStatusBar('zh-Hans')
  assert.strictEqual(zh.text, '当前网络不可用，请检查你的网络设置')
  assert.strictEqual(zh.image, 'status_fail')
})

test('a status bar dictionary', () => {
  const bar = S.statusBarFromConfiguration({ text: 'Offline', image: 'wifi_off', titleColor: '#5C4400', backgroundColor: '#FFE8A3', accessibilityIdentifier: 'bar' }, 'en')
  assert.deepStrictEqual(bar, { text: 'Offline', image: 'wifi_off', titleColor: '#5C4400', backgroundColor: '#FFE8A3', accessibilityIdentifier: 'bar' })
  assert.strictEqual(S.statusBarFromConfiguration({ textKey: 'CYLPlaceholderStatusNetworkUnavailable' }, 'ja').text, S.networkUnavailableStatusBar('ja').text)
  assert.strictEqual(S.statusBarFromConfiguration({ image: 'cyl_placeholder_wifi_off' }, 'en').image, 'wifi_off')
  throwsWith(() => S.statusBarFromConfiguration([], 'en'), 'The status bar configuration must be a dictionary.')
  throwsWith(() => S.statusBarFromConfiguration({ text: 3 }, 'en'), '"text" must be a string.')
  throwsWith(() => S.statusBarFromConfiguration({ image: 'system:wifi' }, 'en'), 'An SF Symbol is an iOS image; name a drawable.')
  throwsWith(() => S.statusBarFromConfiguration({ image: 'nope' }, 'en'), 'The image nope was not found.')
  throwsWith(() => S.statusBarFromConfiguration({ titleColor: 'red' }, 'en'), '"titleColor" is not a color.')
  throwsWith(() => S.statusBarFromConfiguration({ backgroundColor: '#12' }, 'en'), '"backgroundColor" is not a color.')
})

test('cyl_applyStatusConfiguration rules', () => {
  assert.deepStrictEqual(S.parseStatusConfiguration({}, 'en'), { display: D.Placeholder, statusBar: null, showsWhenOffline: undefined })
  const on = S.parseStatusConfiguration({ statusBar: true }, 'en')
  assert.strictEqual(on.display, D.All)
  assert.strictEqual(on.statusBar.image, 'status_fail')
  assert.strictEqual(S.parseStatusConfiguration({ statusBar: 'networkUnavailable', display: 'status' }, 'en').display, D.StatusBar)
  assert.strictEqual(S.parseStatusConfiguration({ statusBar: false }, 'en').statusBar, null)
  assert.strictEqual(S.parseStatusConfiguration({ display: 'none', showsWhenOffline: true }, 'en').showsWhenOffline, true)
  assert.strictEqual(S.parseStatusConfiguration({ statusBar: { text: 'X' } }, 'en').statusBar.text, 'X')
  throwsWith(() => S.parseStatusConfiguration(null, 'en'), 'The configuration must be a dictionary.')
  throwsWith(() => S.parseStatusConfiguration({ statusBar: 3 }, 'en'), '"statusBar" must be true, "networkUnavailable" or a dictionary.')
  throwsWith(() => S.parseStatusConfiguration({ display: 'all' }, 'en'), '"display" must be "statusAndPlaceholder", "status", "placeholder" or "none".')
  throwsWith(() => S.parseStatusConfiguration({ showsWhenOffline: 'yes' }, 'en'), '"showsWhenOffline" must be a boolean.')
})
