// Copies the package's components (src/cyl-placeholder, src/cyl-placeholder-hud) into the example (a mini program
// cannot load files outside its miniprogramRoot). Runs from `npm run sync-example` and from the DevTools
// beforeCompile hook in project.config.json.
'use strict'
const fs = require('fs')
const path = require('path')
const pkg = path.resolve(__dirname, '..')
const components = path.join(pkg, 'example/miniprogram/components')
for (const name of ['cyl-placeholder', 'cyl-placeholder-hud']) {
  const from = path.join(pkg, 'src', name)
  const to = path.join(components, name)
  fs.rmSync(to, { recursive: true, force: true })
  // The locale .json tables stay out: the code loads their generated .js twins.
  fs.cpSync(from, to, { recursive: true, filter: (f) => !(f.endsWith('.json') && f.includes(path.sep + 'locales' + path.sep)) })
  console.log('synced', path.relative(pkg, to))
}
