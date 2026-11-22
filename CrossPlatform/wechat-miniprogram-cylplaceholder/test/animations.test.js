'use strict'
// The example's Animations tab plays PAG and Rive files from the refresh-engines/ subpackage (docs/Task-Log.md).
const test = require('node:test')
const assert = require('node:assert')
const fs = require('node:fs')
const path = require('node:path')

const MP = path.join(__dirname, '../example/miniprogram')

test('every PAG and Rive file of the Animations tab has a subpackage path', () => {
  const { sections } = require(path.join(MP, 'pages/animations/animation_list.js'))
  const files = sections.flatMap((s) => s.files).filter((f) => f.engine === 'pag' || f.engine === 'riv')
  assert.ok(files.length > 0)
  for (const f of files) assert.ok(f.path.startsWith('/refresh-engines/assets/' + f.name + '.bin'), f.name + ': ' + f.path)
  const icon = files.find((f) => f.name === 'CYLRefreshIcon.riv')
  assert.ok(icon.path.endsWith('#artboard=refresh&animation=active'))
  // Files whose state machine waits for input: Success fires its trigger, Bow plays its pulled-bow loop.
  assert.ok(files.find((f) => f.name === 'CYLPlaceholderSuccess.riv').path.endsWith('&triggerInput=Trigger%20explosion'))
  assert.ok(files.find((f) => f.name === 'CYLScenarioExampleRefreshBow.riv').path.endsWith('#animation=strainLoop'))
})

test('the animation detail page lives in the subpackage and passes both engines', () => {
  const app = JSON.parse(fs.readFileSync(path.join(MP, 'app.json'), 'utf8'))
  assert.ok(!app.pages.includes('pages/animation-detail/animation-detail'))
  assert.ok(app.subPackages.some((s) => s.root === 'refresh-engines/' && s.pages.includes('animation-detail/animation-detail')))
  const page = fs.readFileSync(path.join(MP, 'refresh-engines/animation-detail/animation-detail.wxml'), 'utf8')
  assert.match(page, /generic:cyl-pag-view="cyl-pag" generic:cyl-rive-view="cyl-rive"/)
  assert.match(page, /pag-wasm-path="\/refresh-engines\/libs\/cyl-pag-miniprogram\/libpag\/libpag\.wasm\.br"/)
  const list = fs.readFileSync(path.join(MP, 'pages/animations/animations.js'), 'utf8')
  assert.match(list, /\/refresh-engines\/animation-detail\/animation-detail\?section=/)
})
