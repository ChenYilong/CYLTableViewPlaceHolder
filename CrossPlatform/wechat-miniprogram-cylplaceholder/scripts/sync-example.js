// Copies the package's components (src/cyl-placeholder, src/cyl-placeholder-hud) into the example (a mini program
// cannot load files outside its miniprogramRoot), plus the example's Lottie player. Runs from `npm run sync-example`
// and from the DevTools beforeCompile hook in project.config.json.
'use strict'
const fs = require('fs')
const path = require('path')

// fs.cpSync crashes Node 22 on Windows (0xC0000409) for some source folders; a plain recursive copy does not.
function copyDir(from, to, filter = () => true) {
  fs.mkdirSync(to, { recursive: true })
  for (const entry of fs.readdirSync(from, { withFileTypes: true })) {
    const source = path.join(from, entry.name)
    const target = path.join(to, entry.name)
    if (!filter(source)) continue
    if (entry.isDirectory()) copyDir(source, target, filter)
    else fs.copyFileSync(source, target)
  }
}

const pkg = path.resolve(__dirname, '..')
const components = path.join(pkg, 'example/miniprogram/components')
for (const name of ['cyl-placeholder', 'cyl-placeholder-hud']) {
  const from = path.join(pkg, 'src', name)
  const to = path.join(components, name)
  fs.rmSync(to, { recursive: true, force: true })
  // The locale .json tables stay out: the code loads their generated .js twins.
  copyDir(from, to, (f) => !(f.endsWith('.json') && f.includes(path.sep + 'locales' + path.sep)))
  console.log('synced', path.relative(pkg, to))
}

// The example's Lottie player: cyl-lottie-miniprogram from a CYLTabBarController checkout (CYL_TABBAR_DIR, else the
// folder next to this repository, as the Android build's cylTabBarDir).
const tabBar = process.env.CYL_TABBAR_DIR || path.resolve(pkg, '../../../CYLTabBarController')
const lottie = path.join(tabBar, 'CrossPlatform/lottie-miniprogram')
const lottieTo = path.join(pkg, 'example/miniprogram/libs/cyl-lottie-miniprogram')
if (fs.existsSync(path.join(lottie, 'miniprogram_dist/cyl-lottie/index.js'))) {
  fs.rmSync(lottieTo, { recursive: true, force: true })
  copyDir(path.join(lottie, 'miniprogram_dist'), lottieTo)
  fs.copyFileSync(path.join(lottie, 'LICENSE'), path.join(lottieTo, 'LICENSE'))
  console.log('synced', path.relative(pkg, lottieTo), 'from', lottie)
} else if (!fs.existsSync(path.join(lottieTo, 'cyl-lottie/index.js'))) {
  console.error('cyl-lottie-miniprogram not found at ' + lottie + '; set CYL_TABBAR_DIR to a CYLTabBarController checkout.')
  process.exitCode = 1
}
