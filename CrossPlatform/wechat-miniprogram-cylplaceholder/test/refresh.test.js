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
  assert.strictEqual(R.iconForState({ Idle: '/a/x.png' }, S.Idle).image, '/a/x.png')
  assert.deepStrictEqual([R.iconForState({ Idle: '/a/x.mp4' }, S.Idle).type, R.iconForState({ Idle: '/a/x.mp4' }, S.Idle).image], ['unsupported', ''])
  assert.strictEqual(R.iconForState({ Idle: '/a.json' }, S.Pulling).path, '/a.json') // Idle covers every state
  assert.strictEqual(R.iconForState({ Idle: '/a.json' }, S.NoMoreData), null) // no-more-data shows text only
  assert.strictEqual(R.iconForState(null, S.Idle), null)
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


test('cyl-refresh: no load more while a cyl-placeholder shows inside it (iOS hides footers over the placeholder)', () => {
  let definition = null
  global.Component = (options) => { definition = options }
  delete require.cache[require.resolve('../src/cyl-refresh/index.js')]
  require('../src/cyl-refresh/index.js')
  delete global.Component
  const relation = definition.relations['../cyl-placeholder/index']
  assert.strictEqual(relation.type, 'descendant')
  const props = {}
  for (const [key, value] of Object.entries(definition.properties)) props[key] = value && typeof value === 'object' && 'value' in value ? value.value : value
  const loads = []
  const refresh = Object.assign({
    data: Object.assign({}, props, definition.data),
    setData(data) { Object.assign(this.data, data) },
    triggerEvent(name) { if (name === 'loadmore') loads.push(name) },
  }, definition.methods)
  relation.linked.call(refresh)
  assert.strictEqual(refresh.data.placeholderShown, true, 'the footer is hidden while the placeholder shows')
  assert.strictEqual(refresh._footerActive(), false)
  refresh.onScrollToLower()
  refresh._beginFooter()
  assert.deepStrictEqual(loads, [], 'no load more over the placeholder')
  relation.unlinked.call(refresh)
  assert.strictEqual(refresh.data.placeholderShown, false, 'the footer returns with the data')
  refresh._beginFooter()
  assert.deepStrictEqual(loads, ['loadmore'])
  // Two placeholders (Loading, then RetryButton) swapped by wx:if/wx:elif: shown until both are gone.
  relation.linked.call(refresh)
  relation.linked.call(refresh)
  relation.unlinked.call(refresh)
  assert.strictEqual(refresh.data.placeholderShown, true)
  relation.unlinked.call(refresh)
  assert.strictEqual(refresh.data.placeholderShown, false)
})

test('cyl-placeholder declares the cyl-refresh ancestor relation', () => {
  let definition = null
  global.Component = (options) => { definition = options }
  delete require.cache[require.resolve('../src/cyl-placeholder/index.js')]
  require('../src/cyl-placeholder/index.js')
  delete global.Component
  assert.strictEqual(definition.relations['../cyl-refresh/index'].type, 'ancestor')
})
