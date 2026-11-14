// Copies src/cyl-placeholder into the example (a mini program cannot load files outside its miniprogramRoot).
// Runs from `npm run sync-example` and from the DevTools beforeCompile hook in project.config.json.
'use strict'
const fs = require('fs')
const path = require('path')
const pkg = path.resolve(__dirname, '..')
const from = path.join(pkg, 'src/cyl-placeholder')
const to = path.join(pkg, 'example/miniprogram/components/cyl-placeholder')
fs.rmSync(to, { recursive: true, force: true })
fs.cpSync(from, to, { recursive: true, filter: (f) => !f.endsWith('.json') || !f.includes(path.sep + 'locales' + path.sep) })
console.log('synced', path.relative(pkg, to))
