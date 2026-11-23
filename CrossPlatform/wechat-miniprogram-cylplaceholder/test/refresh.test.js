'use strict'
const test = require('node:test')
const assert = require('node:assert')
const { CYLRefresh: R, CYLRefreshState: S, CYLRefreshHeaderHeight } = require('../src/cyl-refresh/cyl_refresh')

test('state texts in 7 languages', () => {
  assert.strictEqual(R.stateText('header', S.Idle, 'en'), 'Pull down to refresh')
  assert.strictEqual(R.stateText('header', S.Pulling, 'en'), 'Release to refresh')
  assert.strictEqual(R.stateText('header', S.Refreshing, 'zh-Hans'), '正在刷新数据中...')
  assert.strictEqual(R.stateText('autoFooter', S.NoMoreData, 'zh-Hans'), '已经全部加载完毕')
  assert.strictEqual(R.stateText('backFooter', S.Pulling, 'en'), 'Release to load more')
  for (const l of ['en', 'zh-Hans', 'zh-Hant', 'ja', 'ko', 'ru', 'uk']) assert.notStrictEqual(R.refreshText('CYLRefreshHeaderIdleText', l), 'CYLRefreshHeaderIdleText')
})

test('setLanguageCode overrides the app language (CYLRefreshConfig.default.languageCode)', () => {
  R.setLanguageCode('ja')
  assert.strictEqual(R.stateText('header', S.Idle), R.refreshText('CYLRefreshHeaderIdleText', 'ja'))
  R.setLanguageCode('')
  assert.strictEqual(R.stateText('header', S.Idle), 'Pull down to refresh')
})

test('last updated time as MJRefreshStateHeader', () => {
  const now = new Date(2026, 10, 15, 13, 30)
  assert.strictEqual(R.lastUpdatedText(null, now, 'en'), 'Last update: No record')
  assert.strictEqual(R.lastUpdatedText(new Date(2026, 10, 15, 9, 41), now, 'en'), 'Last update: Today 09:41')
  assert.strictEqual(R.lastUpdatedText(new Date(2026, 10, 14, 9, 5), now, 'en'), 'Last update: 11-14 09:05')
  assert.strictEqual(R.lastUpdatedText(new Date(2025, 0, 2, 23, 0), now, 'en'), 'Last update: 2025-01-02 23:00')
})

test('pull distance and icons', () => {
  assert.strictEqual(CYLRefreshHeaderHeight, 54)
  assert.strictEqual(R.headerStateForPull(53), S.Idle)
  assert.strictEqual(R.headerStateForPull(54), S.Pulling)
  const icons = { Idle: '/a/CYLRefreshPullArrow.json', Refreshing: { path: '/a/CYLRefreshRing.gif', size: [40, 24] }, Pulling: { path: '/a/x.pag', size: 32 } }
  // cyl-animated-item draws the icons: engine files go to animationUrl, images (GIF included) to image.
  assert.deepStrictEqual(R.iconForState(icons, S.Idle),
    { path: '/a/CYLRefreshPullArrow.json', width: 28, height: 28, type: 'lottie', image: '', animationUrl: '/a/CYLRefreshPullArrow.json' })
  assert.deepStrictEqual(R.iconForState(icons, S.Refreshing),
    { path: '/a/CYLRefreshRing.gif', width: 40, height: 24, type: 'image', image: '/a/CYLRefreshRing.gif', animationUrl: '' })
  assert.deepStrictEqual(R.iconForState(icons, S.Pulling),
    { path: '/a/x.pag', width: 32, height: 32, type: 'pag', image: '', animationUrl: '/a/x.pag' })
  assert.strictEqual(R.iconForState({ Idle: '/a/x.riv' }, S.Idle).type, 'rive')
  assert.strictEqual(R.iconForState({ Idle: '/a/x.svga' }, S.Idle).type, 'svga')
  // Package copies of PAG and Rive files (*.pag.bin, *.riv.bin, the example's refresh-engines/ subpackage) play.
  assert.deepStrictEqual([R.iconForState({ Idle: '/e/x.pag.bin' }, S.Idle).type, R.iconForState({ Idle: '/e/x.pag.bin' }, S.Idle).animationUrl], ['pag', '/e/x.pag.bin'])
  assert.deepStrictEqual([R.iconForState({ Idle: '/e/x.riv.bin' }, S.Idle).type, R.iconForState({ Idle: '/e/x.riv.bin' }, S.Idle).animationUrl], ['rive', '/e/x.riv.bin'])
  assert.strictEqual(R.iconForState({ Idle: '/a/x.png' }, S.Idle).image, '/a/x.png')
  assert.deepStrictEqual([R.iconForState({ Idle: '/a/x.mp4' }, S.Idle).type, R.iconForState({ Idle: '/a/x.mp4' }, S.Idle).image], ['unsupported', ''])
  assert.strictEqual(R.iconForState({ Idle: '/a.json' }, S.Pulling).path, '/a.json') // Idle covers every state
  assert.strictEqual(R.iconForState({ Idle: '/a.json' }, S.NoMoreData), null) // no-more-data shows text only
  assert.strictEqual(R.iconForState(null, S.Idle), null)
})

test('auto footer drag rule (MJRefreshAutoFooter scrollViewPanStateDidChange)', () => {
  // Content shorter than the view (5 rows, the refresh-table examples): it cannot scroll, so a drag up loads.
  assert.strictEqual(R.autoFooterLoadsOnDragEnd({ dragUp: 40, scrollTop: 0, scrollHeight: 753, viewHeight: 753 }), true)
  // A tap (finger travel within the slop) or a drag down does not.
  assert.strictEqual(R.autoFooterLoadsOnDragEnd({ dragUp: 10, scrollTop: 0, scrollHeight: 753, viewHeight: 753 }), false)
  assert.strictEqual(R.autoFooterLoadsOnDragEnd({ dragUp: -40, scrollTop: 0, scrollHeight: 753, viewHeight: 753 }), false)
  // Long content: only a drag that ends at the end loads (scrolltolower does not fire again there).
  assert.strictEqual(R.autoFooterLoadsOnDragEnd({ dragUp: 40, scrollTop: 1000, scrollHeight: 1753, viewHeight: 753 }), true)
  assert.strictEqual(R.autoFooterLoadsOnDragEnd({ dragUp: 40, scrollTop: 400, scrollHeight: 1753, viewHeight: 753 }), false)
  // Not measured yet: no load.
  assert.strictEqual(R.autoFooterLoadsOnDragEnd({ dragUp: 40, scrollTop: 0, scrollHeight: 0, viewHeight: 0 }), false)
})

test('custom string tables and live language changes', () => {
  const seen = []
  const off = R.onLanguageChange((code) => seen.push(code))
  R.registerStrings({ CYLRefreshHeaderIdleText: 'Pull me' })
  assert.strictEqual(R.stateText('header', S.Idle, 'ja'), 'Pull me')
  R.registerStrings('ja', { CYLRefreshHeaderIdleText: '引いて' })
  assert.strictEqual(R.stateText('header', S.Idle, 'ja'), '引いて')
  assert.strictEqual(R.stateText('header', S.Idle, 'en'), 'Pull me')
  R.registerStrings('ja', null)
  R.registerStrings(null)
  assert.strictEqual(R.stateText('header', S.Idle, 'en'), 'Pull down to refresh')
  R.setLanguageCode('ko')
  R.setLanguageCode('ko')
  R.setLanguageCode('')
  off()
  R.setLanguageCode('ja')
  R.setLanguageCode('')
  assert.deepStrictEqual(seen.slice(-2), ['ko', ''])
  assert.strictEqual(seen.filter((c) => c === 'ko').length, 1)
})

test('finish phase and trailer texts', () => {
  assert.strictEqual(R.finishText('header', true, 'en'), 'Refresh complete')
  assert.strictEqual(R.finishText('header', false, 'en'), 'Refresh failed')
  assert.strictEqual(R.finishText('footer', true, 'en'), 'Load complete')
  assert.strictEqual(R.finishText('footer', false, 'en'), 'Load failed')
  assert.strictEqual(R.stateText('trailer', S.Pulling, 'en'), 'Release to see details')
})

test('cyl-refresh forwards the PAG and Rive wasm paths, and the example wires both engines', () => {
  const fs = require('node:fs')
  const path = require('node:path')
  const wxml = fs.readFileSync(path.join(__dirname, '../src/cyl-refresh/index.wxml'), 'utf8')
  assert.strictEqual((wxml.match(/pag-wasm-path="\{\{pagWasmPath\}\}" rive-wasm-path="\{\{riveWasmPath\}\}"/g) || []).length, 2)
  const demo = path.join(__dirname, '../example/miniprogram/refresh-engines/refresh-icon-demo/refresh-icon-demo')
  const page = fs.readFileSync(demo + '.wxml', 'utf8')
  assert.match(page, /generic:cyl-pag-view="cyl-pag" generic:cyl-rive-view="cyl-rive"/)
  assert.match(page, /pag-wasm-path="\/refresh-engines\/libs\/cyl-pag-miniprogram\/libpag\/libpag\.wasm\.br"/)
  assert.match(page, /rive-wasm-path="\/refresh-engines\/libs\/cyl-rive-miniprogram\/rive\/rive\.wasm\.br"/)
  const app = JSON.parse(fs.readFileSync(path.join(__dirname, '../example/miniprogram/app.json'), 'utf8'))
  assert.ok(app.subPackages.some((s) => s.root === 'refresh-engines/' && s.pages.includes('refresh-icon-demo/refresh-icon-demo')))
})

test('scroll modes as CYLRefreshScrollMode (move, stretch, front, behind)', () => {
  const { CYLRefreshScrollMode: M } = require('../src/cyl-refresh/cyl_refresh')
  assert.deepStrictEqual({ ...M }, { Move: 'move', Stretch: 'stretch', Front: 'front', Behind: 'behind' })
  assert.strictEqual(R.scrollModeFor(undefined, false), 'move', 'the default is move')
  for (const mode of ['move', 'stretch', 'front', 'behind']) assert.strictEqual(R.scrollModeFor(mode, false), mode)
  assert.strictEqual(R.scrollModeFor('stretch', true), 'behind', 'the older behind flag wins')
  assert.strictEqual(R.scrollModeFor('bogus', false), 'move', 'an unknown value is move')
})

test('cyl-refresh lays the header out per scroll mode', () => {
  const fs = require('node:fs')
  const path = require('node:path')
  const wxml = fs.readFileSync(path.join(__dirname, '../src/cyl-refresh/index.wxml'), 'utf8')
  const wxss = fs.readFileSync(path.join(__dirname, '../src/cyl-refresh/index.wxss'), 'utf8')
  assert.match(wxml, /cyl-refresh__header--\{\{mode\}\}/)
  assert.match(wxml, /height: \{\{mode === 'stretch' \? pull : threshold\}\}px/, 'stretch fills the pulled distance')
  assert.match(wxml, /mode === 'move' \|\| mode === 'front' \? 'transform: translateY/, 'only move and front slide in')
  assert.match(wxss, /\.cyl-refresh__header--front \{ z-index: 3; \}/, 'front is above the content')
  assert.match(wxss, /\.cyl-refresh__scroll--behind \{ z-index: 2; \}/, 'behind is under the content')
})
