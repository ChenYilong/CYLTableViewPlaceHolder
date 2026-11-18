#!/usr/bin/env node
// Imports the animations the example's Animations tab (CYLAnimationListViewController) lists and the mini program can
// play, and writes the list data, since a mini program cannot list its package folders at run time.
//
// - Lists every json/pag/riv/gif of the iOS core bundle (grouped by engine) and of the example bundle, like iOS.
// - Copies into example/miniprogram/assets/animations/: the CYLRefresh*.json and the GIFs of the core bundle, the core
//   NOTICE.animations and the LICENSE files the copied files name in it. The CYLPlaceholder*.json are not copied
//   again: the package already ships them in components/cyl-placeholder/animations/ (2 MB main package limit).
// - PAG and Rive files are listed but not copied: the mini program has no player for them.
// - Writes example/miniprogram/pages/animations/animation_list.js.
//
// Usage: node scripts/import-example-animations.js
const fs = require('fs')
const path = require('path')

const PKG = path.resolve(__dirname, '..')
const REPO = path.resolve(PKG, '../..')
const MP = path.join(PKG, 'example/miniprogram')
const CORE = path.join(REPO, 'CYLTableViewPlaceHolder/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.bundle/Animations')
const EXAMPLE = path.join(REPO, 'Examples/Example-Scenarios/Sources/CYLScenarioExample.bundle/Animations')
const OUT = path.join(MP, 'assets/animations')
const COMPONENT_DIR = path.join(MP, 'components/cyl-placeholder/animations')
const LIST = path.join(MP, 'pages/animations/animation_list.js')

const EXTENSIONS = ['json', 'pag', 'riv', 'gif']
// Same order and (untranslated) titles as CYLAnimationListViewController.engines.
const ENGINES = [
  ['json', 'Lottie · CYLTableViewPlaceHolder/LottieSwift'],
  ['pag', 'PAG · CYLTableViewPlaceHolder/PAG'],
  ['riv', 'Rive · CYLTableViewPlaceHolder/Rive'],
  ['gif', 'GIF · Core'],
]
const ext = (name) => path.extname(name).slice(1).toLowerCase()
const list = (dir) => fs.readdirSync(dir).filter((n) => EXTENSIONS.includes(ext(n))).sort()

fs.rmSync(OUT, { recursive: true, force: true })
fs.mkdirSync(OUT, { recursive: true })
let copiedBytes = 0
// A mini program package keeps only known file types (not .txt or files without a suffix): text files ship as
// <name>.json holding the text as one JSON string (the text-file page unwraps it).
const copy = (from, name, asText = false) => {
  const target = path.join(OUT, name + (asText ? '.json' : ''))
  if (asText) fs.writeFileSync(target, JSON.stringify(fs.readFileSync(path.join(from, name), 'utf8')) + '\n')
  else fs.copyFileSync(path.join(from, name), target)
  copiedBytes += fs.statSync(target).size
}

// The package path the mini program plays a core file from, or '' when it cannot play it.
function corePath(name) {
  const e = ext(name)
  if (e === 'json' && fs.existsSync(path.join(COMPONENT_DIR, name))) return '/components/cyl-placeholder/animations/' + name
  if (e === 'json' || e === 'gif') {
    copy(CORE, name)
    return '/assets/animations/' + name
  }
  return ''
}

const entry = (name, dir, playPath) => ({
  name,
  engine: ext(name),
  bytes: fs.statSync(path.join(dir, name)).size,
  path: playPath,
  example: dir === EXAMPLE,
})

const coreNames = list(CORE)
const sections = []
for (const [e, title] of ENGINES) {
  const files = coreNames.filter((n) => ext(n) === e).map((n) => entry(n, CORE, corePath(n)))
  if (files.length) sections.push({ title, files })
}
// The example bundle's files: all Rive or PAG today; a Lottie or GIF one would be copied and played.
if (fs.existsSync(EXAMPLE)) {
  const files = list(EXAMPLE).map((n) => {
    const playable = ['json', 'gif'].includes(ext(n))
    if (playable) copy(EXAMPLE, n)
    return entry(n, EXAMPLE, playable ? '/assets/animations/' + n : '')
  })
  if (files.length) sections.push({ title: 'CYLScenarioExample.bundle/Animations', files })
}

// SVGA: CYLTabBarController's six SVGA sample files (Apache-2.0, their NOTICE.md), from the same checkout as
// scripts/sync-example.js (CYL_TABBAR_DIR, else the Cartfile checkout, else the folder next to this repository). A
// package cannot hold .svga files, so they ship as <name>.svga.bin, which cyl-animated-item reads as SVGA (bug B6).
const TAB_BAR = process.env.CYL_TABBAR_DIR || [path.join(REPO, 'Carthage/Checkouts/CYLTabBarController'), path.resolve(REPO, '../CYLTabBarController')]
  .find((folder) => fs.existsSync(path.join(folder, 'CrossPlatform'))) || path.resolve(REPO, '../CYLTabBarController')
const SVGA = path.join(TAB_BAR, 'Example-SwiftUI-Rive/AnimatedApp/SVGAAssets')
if (fs.existsSync(SVGA)) {
  const files = fs.readdirSync(SVGA).filter((n) => ext(n) === 'svga').sort().map((n) => {
    fs.copyFileSync(path.join(SVGA, n), path.join(OUT, n + '.bin'))
    copiedBytes += fs.statSync(path.join(OUT, n + '.bin')).size
    return { name: n, engine: 'svga', bytes: fs.statSync(path.join(SVGA, n)).size, path: '/assets/animations/' + n + '.bin', example: true }
  })
  copy(SVGA, 'NOTICE.md', true)
  // This repository's own SVGA scenes (scripts/make_svga_scenes.py, MIT), the twins of the SmartRefresh Rive styles,
  // generated once into the Android example's assets: the refresh-smart page's SVGA styles play them.
  const SCENES = path.join(REPO, 'android/merged/example/src/main/assets/Animations')
  fs.readdirSync(SCENES).filter((n) => /^CYLScenarioExampleRefresh\w+\.svga$/.test(n)).sort().forEach((n) => {
    fs.copyFileSync(path.join(SCENES, n), path.join(OUT, n + '.bin'))
    copiedBytes += fs.statSync(path.join(OUT, n + '.bin')).size
    files.push({ name: n, engine: 'svga', bytes: fs.statSync(path.join(SCENES, n)).size, path: '/assets/animations/' + n + '.bin', example: true })
  })
  if (files.length) sections.push({ title: 'SVGA · cyl-svga-miniprogram', files })
} else {
  console.error('SVGA samples not found at ' + SVGA + '; set CYL_TABBAR_DIR to a CYLTabBarController checkout.')
  process.exitCode = 1
}

// NOTICE.animations and the LICENSE files the copied animations name in it.
const notice = fs.readFileSync(path.join(CORE, 'NOTICE.animations'), 'utf8')
const copied = new Set(fs.readdirSync(OUT))
copy(CORE, 'NOTICE.animations', true)
const licenses = new Set()
let current = null
for (const line of notice.split(/\r?\n/)) {
  if (/^CYL\S+\.\w+$/.test(line.trim())) current = line.trim()
  const match = line.match(/\((LICENSE\.[^)/]+)\)/)
  if (match && current && copied.has(current)) licenses.add(match[1])
}
for (const license of licenses) {
  if (fs.existsSync(path.join(CORE, license))) copy(CORE, license, true)
}

fs.mkdirSync(path.dirname(LIST), { recursive: true })
fs.writeFileSync(
  LIST,
  '// Generated by scripts/import-example-animations.js; do not edit.\n' +
    '// The sections of CYLAnimationListViewController: the core bundle by engine, then the example bundle.\n' +
    '// path: the package file the mini program plays; empty for PAG and Rive (no player in the mini program).\n' +
    'module.exports = {\n' +
    "  noticePath: '/assets/animations/NOTICE.animations.json',\n" +
    '  sections: ' + JSON.stringify(sections, null, 2).replace(/\n/g, '\n  ') + ',\n' +
    '}\n',
)

const count = sections.reduce((n, s) => n + s.files.length, 0)
console.log(`${count} animations in ${sections.length} sections; copied ${fs.readdirSync(OUT).length} files, ` +
  `${(copiedBytes / 1024).toFixed(1)} KB, into ${path.relative(PKG, OUT)}`)
