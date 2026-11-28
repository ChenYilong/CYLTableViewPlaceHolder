'use strict'
const test = require('node:test')
const assert = require('node:assert')
const { CYLPlaceholderHUD, CYLPlaceholderHUDState: S, CYLPlaceholderHUDMaskType } = require('../src/cyl-placeholder/cyl_placeholder')

/** A HUD on fake timers; `tick(ms)` advances time and runs due callbacks in order. */
function makeHUD() {
  let now = 0
  let id = 0
  const timers = new Map()
  const views = []
  const hud = new CYLPlaceholderHUD((v) => views.push(v), {
    setTimeout: (fn, ms) => (timers.set(++id, { fn, at: now + ms }), id),
    clearTimeout: (t) => timers.delete(t),
  })
  const tick = (ms) => {
    const end = now + ms
    for (;;) {
      const due = [...timers.entries()].filter(([, t]) => t.at <= end).sort((a, b) => a[1].at - b[1].at)[0]
      if (!due) break
      timers.delete(due[0])
      now = due[1].at
      due[1].fn()
    }
    now = end
  }
  return { hud, views, tick }
}

test('show / setStatus / dismiss', () => {
  const { hud, views, tick } = makeHUD()
  hud.showWithStatus('Loading')
  assert.strictEqual(hud.state, S.Loading)
  assert.ok(hud.visible)
  hud.setStatus('Still loading')
  assert.strictEqual(views.at(-1).status, 'Still loading')
  assert.strictEqual(views.at(-1).state, S.Loading)
  let done = false
  hud.dismiss(() => (done = true))
  tick(0)
  assert.strictEqual(hud.state, S.Hidden)
  assert.ok(done)
})

test('success / error / info dismiss after displayDurationForString', () => {
  const { hud, tick } = makeHUD()
  assert.strictEqual(hud.displayDurationForString(''), 1.5)
  assert.strictEqual(hud.displayDurationForString('x'.repeat(200)), 5)
  assert.strictEqual(hud.displayDurationForString('x'.repeat(30)), 2.3)
  hud.showSuccessWithStatus('x'.repeat(30))
  assert.strictEqual(hud.state, S.Success)
  tick(2299)
  assert.strictEqual(hud.state, S.Success)
  tick(1)
  assert.strictEqual(hud.state, S.Hidden)
  hud.showErrorWithStatus('No')
  tick(1499)
  assert.strictEqual(hud.state, S.Error)
  tick(1)
  assert.strictEqual(hud.state, S.Hidden)
})

test('a new HUD cancels the pending timed dismiss', () => {
  const { hud, tick } = makeHUD()
  hud.showInfoWithStatus('Info')
  hud.showWithStatus('Loading')
  tick(10000)
  assert.strictEqual(hud.state, S.Loading)
})

test('progress is clamped and shown as a percentage; negative is indeterminate', () => {
  const { hud, views } = makeHUD()
  hud.showProgress(0.654, 'Uploading')
  assert.strictEqual(views.at(-1).percent, 65)
  hud.showProgress(2)
  assert.strictEqual(hud.progress, 1)
  assert.strictEqual(views.at(-1).status, 'Uploading')
  hud.showProgress(-1)
  assert.strictEqual(hud.state, S.Loading)
})

test('popActivity dismisses after the last activity', () => {
  const { hud, tick } = makeHUD()
  hud.showWithStatus('1')
  hud.showWithStatus('2')
  assert.strictEqual(hud.activityCount, 2)
  hud.popActivity()
  tick(0)
  assert.strictEqual(hud.state, S.Loading)
  hud.popActivity()
  tick(0)
  assert.strictEqual(hud.state, S.Hidden)
  assert.strictEqual(hud.activityCount, 0)
})

test('graceTimeInterval hides a quick task', () => {
  const { hud, views, tick } = makeHUD()
  hud.graceTimeInterval = 0.5
  hud.showWithStatus('Quick')
  tick(400)
  assert.strictEqual(views.length, 0)
  hud.dismiss()
  tick(1000)
  assert.ok(views.every((v) => !v.visible))
  hud.showWithStatus('Slow')
  tick(500)
  assert.strictEqual(hud.state, S.Loading)
})

test('custom colors, mask, metrics, loading animation and haptics reach the view', () => {
  let vibrations = 0
  const views = []
  const hud = new CYLPlaceholderHUD((v) => views.push(v), { setTimeout: () => 0, clearTimeout: () => {}, vibrate: () => vibrations++ })
  Object.assign(hud, { style: 'Custom', maskType: 'Custom', foregroundColor: '#fff', hudBackgroundColor: '#30b0c7', backgroundLayerColor: 'rgba(0,0,0,0.2)', cornerRadius: 8, minimumSize: 80, offsetFromCenter: [0, -40], loadingAnimationFileName: '/a/spin.json' })
  hud.show()
  const v = views.at(-1)
  assert.deepStrictEqual([v.style, v.maskType, v.foregroundColor, v.hudBackgroundColor, v.backgroundLayerColor, v.cornerRadius, v.minimumSize, v.offsetX, v.offsetY, v.loadingAnimation],
    ['Custom', 'Custom', '#fff', '#30b0c7', 'rgba(0,0,0,0.2)', 8, 80, 0, -40, '/a/spin.json'])
  assert.strictEqual(v.blocksTouches, true)
  hud.showSuccessWithStatus('ok')
  assert.strictEqual(vibrations, 0)
  hud.hapticsEnabled = true
  hud.showSuccessWithStatus('ok')
  hud.showErrorWithStatus('no')
  hud.showInfoWithStatus('i')
  assert.strictEqual(vibrations, 2)
})

test('scenario and components in the box; the mask blocks touches unless None', () => {
  const { hud, views } = makeHUD()
  hud.showScenario('CYLPlaceholderScenarioRetryButton')
  assert.strictEqual(views.at(-1).state, S.Custom)
  assert.strictEqual(views.at(-1).scenario, 'RetryButton')
  assert.strictEqual(views.at(-1).blocksTouches, false)
  hud.maskType = CYLPlaceholderHUDMaskType.Black
  hud.showComponents([{ type: 'text', text: 'Hi' }])
  assert.deepStrictEqual(views.at(-1).components, [{ type: 'text', text: 'Hi' }])
  assert.strictEqual(views.at(-1).blocksTouches, true)
})
