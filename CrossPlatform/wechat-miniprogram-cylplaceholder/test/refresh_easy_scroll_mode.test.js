'use strict'
// The "Scroll mode" demo of the easy-refresh page (refresh-demos/refresh-easy): its rows, the tap that switches the
// mode, the strings in 7 languages and the menu entry. The page is loaded with a fake Page and wx.
const test = require('node:test')
const assert = require('node:assert')
const fs = require('node:fs')
const path = require('node:path')

const EXAMPLE = path.join(__dirname, '..', 'example', 'miniprogram')
const LANGUAGES = ['en', 'zh-Hans', 'zh-Hant', 'ja', 'ko', 'ru', 'uk']

function loadPage() {
  let definition
  global.Page = (options) => { definition = options }
  global.wx = { setNavigationBarTitle() {}, getStorageSync: () => '', getSystemInfoSync: () => ({ language: 'en' }), getAppBaseInfo: () => ({ language: 'en' }) }
  const file = path.join(EXAMPLE, 'refresh-demos/refresh-easy/refresh-easy.js')
  delete require.cache[require.resolve(file)]
  require(file)
  delete global.Page
  return definition
}

function instance(definition) {
  const page = Object.assign({}, definition, { data: JSON.parse(JSON.stringify(definition.data)) })
  page.setData = (patch) => Object.assign(page.data, patch)
  return page
}

test('the page shows one tappable row per scroll mode, the current one marked, then the test rows', () => {
  const definition = loadPage()
  const page = instance(definition)
  page.onLoad({ method: 'easyScrollMode', title: 'Scroll mode' })
  assert.strictEqual(page.data.setup.header, 'normal')
  assert.strictEqual(page.data.setup.footer, 'back')
  const rows = page.data.rows
  assert.strictEqual(rows.length, 2 + 30)
  assert.deepStrictEqual(rows.slice(0, 2).map((r) => r.tappable), [true, true])
  assert.match(rows[0].text, /^✓ /, 'Move is the current mode')
  assert.doesNotMatch(rows[1].text, /^✓ /)
  assert.strictEqual(page.data.scrollBehind, false)
})

test('a tap on a mode row switches the header to that mode', () => {
  const page = instance(loadPage())
  page.onLoad({ method: 'easyScrollMode' })
  page.onRow({ currentTarget: { dataset: { index: 1 } } })
  assert.strictEqual(page.data.scrollBehind, true)
  assert.match(page.data.rows[1].text, /^✓ /)
  assert.doesNotMatch(page.data.rows[0].text, /^✓ /)
  page.onRow({ currentTarget: { dataset: { index: 0 } } })
  assert.strictEqual(page.data.scrollBehind, false)
  page.onRow({ currentTarget: { dataset: { index: 5 } } })
  assert.strictEqual(page.data.scrollBehind, false, 'a test row changes nothing')
})

test('the template passes the mode to cyl-refresh as behind', () => {
  const wxml = fs.readFileSync(path.join(EXAMPLE, 'refresh-demos/refresh-easy/refresh-easy.wxml'), 'utf8')
  assert.match(wxml, /behind="\{\{setup\.behind \|\| scrollBehind\}\}"/)
})

test('the strings exist in every language and the menu lists the page', () => {
  for (const language of LANGUAGES) {
    const text = fs.readFileSync(path.join(EXAMPLE, 'utils/strings', language + '.js'), 'utf8')
    for (const key of ['CYLScenarioEasyScrollMode', 'CYLScenarioEasyScrollMove', 'CYLScenarioEasyScrollBehind', 'CYLScenarioEasyScrollSelected']) {
      assert.match(text, new RegExp('"' + key + '": "[^"]+"'), language + ' ' + key)
    }
  }
  const menu = fs.readFileSync(path.join(EXAMPLE, 'pages/refresh/menu.js'), 'utf8')
  assert.match(menu, /\['ScrollMode', 'easyScrollMode'\]/)
})
