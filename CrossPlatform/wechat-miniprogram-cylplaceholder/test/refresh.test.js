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
  assert.deepStrictEqual(R.iconForState(icons, S.Idle), { path: '/a/CYLRefreshPullArrow.json', width: 28, height: 28, type: 'lottie' })
  assert.deepStrictEqual(R.iconForState(icons, S.Refreshing), { path: '/a/CYLRefreshRing.gif', width: 40, height: 24, type: 'image' })
  assert.strictEqual(R.iconForState(icons, S.Pulling).type, 'unsupported')
  assert.strictEqual(R.iconForState({ Idle: '/a.json' }, S.Pulling).path, '/a.json') // Idle covers every state
  assert.strictEqual(R.iconForState({ Idle: '/a.json' }, S.NoMoreData), null) // no-more-data shows text only
  assert.strictEqual(R.iconForState(null, S.Idle), null)
})
