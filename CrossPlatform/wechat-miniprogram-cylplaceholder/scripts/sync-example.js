// Copies the package's components (src/cyl-placeholder, src/cyl-placeholder-hud, src/cyl-placeholder-status,
// src/cyl-refresh and the copied CYLTabBarController components they build on, src/cyl-animated-item and
// src/cyl-animation-placeholder) into the example (a mini program cannot load files outside its miniprogramRoot), plus
// the example's Lottie player. Runs from `npm run sync-example` and from the DevTools beforeCompile hook in
// project.config.json.
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
for (const name of ['cyl-placeholder', 'cyl-placeholder-hud', 'cyl-placeholder-status', 'cyl-refresh', 'cyl-animated-item', 'cyl-animation-placeholder']) {
  const from = path.join(pkg, 'src', name)
  const to = path.join(components, name)
  fs.rmSync(to, { recursive: true, force: true })
  // The locale .json tables stay out: the code loads their generated .js twins.
  copyDir(from, to, (f) => !(f.endsWith('.json') && f.includes(path.sep + 'locales' + path.sep)))
  console.log('synced', path.relative(pkg, to))
}

// The example's Lottie player: cyl-lottie-miniprogram from a CYLTabBarController checkout (CYL_TABBAR_DIR, else the
// Cartfile checkout at the pinned commit that `bash scripts/cyltabbarcontroller-checkout.sh` creates in
// Carthage/Checkouts, else the folder next to this repository). The pinned checkout comes first so the example runs the
// commit the repository takes ("Depending on CYLTabBarController"), not whatever a neighbouring working tree holds.
const tabBar = process.env.CYL_TABBAR_DIR || [path.resolve(pkg, '../../Carthage/Checkouts/CYLTabBarController'), path.resolve(pkg, '../../../CYLTabBarController')]
  .find((folder) => fs.existsSync(path.join(folder, 'CrossPlatform'))) || path.resolve(pkg, '../../../CYLTabBarController')
// The example's tab bar (cyl-tab-bar, as the iOS example uses CYLTabBarController) and Lottie player.
const libraries = [
  { name: 'cyl-lottie-miniprogram', from: 'CrossPlatform/lottie-miniprogram', dist: 'miniprogram_dist', check: 'cyl-lottie/index.js' },
  // The SVGA player (cyl-svga) the example passes as cyl-svga-view, as the Lottie one as cyl-lottie-view.
  { name: 'cyl-svga-miniprogram', from: 'CrossPlatform/svga-miniprogram', dist: 'miniprogram_dist', check: 'cyl-svga/index.js' },
  { name: 'cyl-tabbar-miniprogram', from: 'CrossPlatform/wechat-miniprogram-cyltabbar', dist: 'src', check: 'cyl-tab-bar/index.js' },
]
for (const library of libraries) {
  const root = path.join(tabBar, library.from)
  const to = path.join(pkg, 'example/miniprogram/libs', library.name)
  if (fs.existsSync(path.join(root, library.dist, library.check))) {
    fs.rmSync(to, { recursive: true, force: true })
    copyDir(path.join(root, library.dist), to)
    fs.copyFileSync(path.join(root, 'LICENSE'), path.join(to, 'LICENSE'))
    // A package NOTICE (cyl-svga-miniprogram: fflate's license) goes with it.
    if (fs.existsSync(path.join(root, 'NOTICE'))) fs.copyFileSync(path.join(root, 'NOTICE'), path.join(to, 'NOTICE'))
    console.log('synced', path.relative(pkg, to), 'from', root)
  } else if (!fs.existsSync(path.join(to, library.check))) {
    console.error(library.name + ' not found at ' + root + '; set CYL_TABBAR_DIR to a CYLTabBarController checkout.')
    process.exitCode = 1
  }
}
