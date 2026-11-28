'use strict'
// The package as a library, as WeChat DevTools' Build npm uses it: the built miniprogram_npm folder is src/ (the
// "miniprogram" field), and require('cyl-placeholder-miniprogram') loads its index.js.
const test = require('node:test')
const assert = require('node:assert')
const fs = require('fs')
const path = require('path')

const root = path.join(__dirname, '..')
const pkg = require('../package.json')
const src = path.join(root, pkg.miniprogram)

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true })
    .flatMap((entry) => (entry.isDirectory() ? walk(path.join(dir, entry.name)) : [path.join(dir, entry.name)]))
}

test('the entry is the index.js of the built folder and exports the API', () => {
  assert.strictEqual(pkg.miniprogram, 'src')
  assert.strictEqual(pkg.main, 'src/index.js')
  const api = require(path.join(root, pkg.main))
  for (const name of ['CYLPlaceholderScenario', 'CYLPlaceholderAction', 'CYLPlaceholderScenarioCatalog', 'CYLPlaceholderHUD',
    'CYLPlaceholderConfiguration', 'CYLPlaceholderStatus', 'CYLPlaceholderLocalization']) {
    assert.ok(api[name], name)
  }
})

test('every relative require names a file, as a plain statement', () => {
  for (const file of walk(src).filter((name) => name.endsWith('.js'))) {
    // Whole-line comments are not code: the vendored cyl-dealloc-block-executor explains the rule with `...require('./x')`.
    const text = fs.readFileSync(file, 'utf8').replace(/^\s*\/\/.*$/gm, '')
    // A mini program resolves no folder to its index.js (Node does).
    for (const match of text.matchAll(/require\((['"])(\.[^'"]+)\1\)/g)) {
      const target = path.join(path.dirname(file), match[2])
      const isFile = fs.existsSync(`${target}.js`) || (fs.existsSync(target) && fs.statSync(target).isFile())
      assert.ok(isFile, `${path.relative(root, file)} requires the folder ${match[2]}`)
    }
    // DevTools' "filter unused files" does not see a require inside an object spread and drops that file.
    assert.ok(!/\.\.\.\s*require\(/.test(text), `${path.relative(root, file)} spreads a require`)
  }
})

test('the components refer to each other by relative paths inside the package', () => {
  for (const file of walk(src).filter((name) => path.basename(name) === 'index.json')) {
    const json = JSON.parse(fs.readFileSync(file, 'utf8'))
    const used = Object.values(json.usingComponents || {}).concat(Object.values(json.componentGenerics || {}).map((g) => g.default))
    for (const target of used) {
      assert.ok(String(target).startsWith('.'), `${path.relative(root, file)} uses ${target}`)
      assert.ok(fs.existsSync(path.join(path.dirname(file), `${target}.json`)), `${path.relative(root, file)} -> ${target}`)
    }
  }
})

test('the published files exist', () => {
  for (const file of pkg.files) assert.ok(fs.existsSync(path.join(root, file)), file)
})
