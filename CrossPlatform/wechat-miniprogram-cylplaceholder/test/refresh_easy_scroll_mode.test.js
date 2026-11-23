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
  assert.strictEqual(rows.length, 4 + 30)
  assert.deepStrictEqual(rows.slice(0, 4).map((r) => r.tappable), [true, true, true, true])
  assert.deepStrictEqual(rows.slice(0, 4).map((r) => r.text.replace(/^✓ /, '')), ['Move', 'Stretch', 'Front', 'Behind'])
  assert.match(rows[0].text, /^✓ /, 'Move is the current mode')
  assert.deepStrictEqual(rows.slice(1, 4).map((r) => /^✓ /.test(r.text)), [false, false, false])
  assert.strictEqual(page.data.scrollMode, 'move')
})

test('a tap on a mode row switches the header to that mode', () => {
  const page = instance(loadPage())
  page.onLoad({ method: 'easyScrollMode' })
  for (const [index, mode] of [[1, 'stretch'], [2, 'front'], [3, 'behind'], [0, 'move']]) {
    page.onRow({ currentTarget: { dataset: { index } } })
    assert.strictEqual(page.data.scrollMode, mode)
    assert.deepStrictEqual(page.data.rows.slice(0, 4).map((r) => /^✓ /.test(r.text)), [0, 1, 2, 3].map((i) => i === index))
  }
  page.onRow({ currentTarget: { dataset: { index: 5 } } })
  assert.strictEqual(page.data.scrollMode, 'move', 'a test row changes nothing')
})

test('the template passes the mode to cyl-refresh as scroll-mode, and behind no longer overrides it', () => {
  const wxml = fs.readFileSync(path.join(EXAMPLE, 'refresh-demos/refresh-easy/refresh-easy.wxml'), 'utf8')
  assert.match(wxml, /scroll-mode="\{\{scrollMode\}\}"/)
  assert.match(wxml, /behind="\{\{setup\.behind \|\| false\}\}"/)
})

test('the strings exist in every language and the menu lists the page', () => {
  for (const language of LANGUAGES) {
    const text = fs.readFileSync(path.join(EXAMPLE, 'utils/strings', language + '.js'), 'utf8')
    for (const key of ['CYLScenarioEasyScrollMode', 'CYLScenarioEasyScrollMove', 'CYLScenarioEasyScrollStretch', 'CYLScenarioEasyScrollFront', 'CYLScenarioEasyScrollBehind', 'CYLScenarioEasyScrollSelected']) {
      assert.match(text, new RegExp('"' + key + '": "[^"]+"'), language + ' ' + key)
    }
  }
  const menu = fs.readFileSync(path.join(EXAMPLE, 'pages/refresh/menu.js'), 'utf8')
  assert.match(menu, /\['ScrollMode', 'easyScrollMode'\]/)
})
