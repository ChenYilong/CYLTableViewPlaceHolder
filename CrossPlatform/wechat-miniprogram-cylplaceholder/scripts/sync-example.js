// Copies the package's components (src/cyl-placeholder, src/cyl-placeholder-hud, src/cyl-placeholder-status,
// src/cyl-refresh and the copied CYLTabBarController components they build on, src/cyl-animated-item and
// src/cyl-animation-placeholder) into the example (a mini program cannot load files outside its miniprogramRoot), plus
// the example's Lottie, SVGA, PAG and Rive players (PAG and Rive into the refresh-engines/ subpackage, with the PAG and
// Rive refresh icons). Runs from `npm run sync-example` and from the DevTools beforeCompile hook in
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
for (const name of ['cyl-placeholder', 'cyl-placeholder-hud', 'cyl-placeholder-status', 'cyl-refresh', 'cyl-animated-item', 'cyl-animation-placeholder', 'cyl-dealloc-block-executor']) {
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
const REFRESH_ENGINES_LIBS = 'example/miniprogram/refresh-engines/libs'
// The example's tab bar (cyl-tab-bar, as the iOS example uses CYLTabBarController) and Lottie player.
const libraries = [
  { name: 'cyl-lottie-miniprogram', from: 'CrossPlatform/lottie-miniprogram', dist: 'miniprogram_dist', check: 'cyl-lottie/index.js' },
  // The SVGA player (cyl-svga) the example passes as cyl-svga-view, as the Lottie one as cyl-lottie-view.
  { name: 'cyl-svga-miniprogram', from: 'CrossPlatform/svga-miniprogram', dist: 'miniprogram_dist', check: 'cyl-svga/index.js' },
  { name: 'cyl-tabbar-miniprogram', from: 'CrossPlatform/wechat-miniprogram-cyltabbar', dist: 'src', check: 'cyl-tab-bar/index.js' },
  // The PAG and Rive players (cyl-pag, cyl-rive) with their WebAssembly, about 1.7 MB together: they go into the
  // refresh-engines/ subpackage (2 MB main package limit), next to the page that passes them to cyl-refresh as
  // cyl-pag-view / cyl-rive-view with their wasm paths.
  { name: 'cyl-pag-miniprogram', from: 'CrossPlatform/pag-miniprogram', dist: 'miniprogram_dist', check: 'cyl-pag/index.js', into: REFRESH_ENGINES_LIBS },
  { name: 'cyl-rive-miniprogram', from: 'CrossPlatform/rive-miniprogram', dist: 'miniprogram_dist', check: 'cyl-rive/index.js', into: REFRESH_ENGINES_LIBS },
]
for (const library of libraries) {
  const root = path.join(tabBar, library.from)
  const to = path.join(pkg, library.into || 'example/miniprogram/libs', library.name)
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

// Every PAG and Rive file of the iOS core bundle and of the example bundle, for the refresh-engines/ subpackage (the
// refresh icon demo and the Animations tab play them). A code package leaves out .pag and .riv files, so the copies are
// named *.pag.bin and *.riv.bin, which cyl-animated-item reads by the extension before ".bin".
const engineAssets = path.join(pkg, 'example/miniprogram/refresh-engines/assets')
fs.rmSync(engineAssets, { recursive: true, force: true })
fs.mkdirSync(engineAssets, { recursive: true })
let engineFiles = 0
for (const folder of ['CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle/Animations',
  'Examples/Example-Scenarios/Sources/CYLScenarioExample.bundle/Animations']) {
  const from = path.resolve(pkg, '../..', folder)
  for (const name of fs.readdirSync(from).filter((n) => /\.(pag|riv)$/i.test(n))) {
    fs.copyFileSync(path.join(from, name), path.join(engineAssets, name + '.bin'))
    engineFiles++
  }
}
console.log('synced', engineFiles, 'PAG and Rive files into', path.relative(pkg, engineAssets))
