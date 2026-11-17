'use strict'
// The components build on CYLTabBarController's cyl-animated-item (copied unchanged into src/cyl-animated-item by
// scripts/sync-cyl-animated-item.js): the copy is the Cartfile's commit, the path and file-type helpers
// (src/cyl-placeholder/cyl_animated_icon.js), and every icon / animation of the components goes through it.
// upstream's own model tests are test/cyl_animated_item.test.js (copied unchanged).
const test = require('node:test')
const assert = require('node:assert')
const fs = require('fs')
const path = require('path')
const { execFileSync } = require('child_process')

const root = path.join(__dirname, '..')
const src = path.join(root, 'src')
const repository = path.resolve(root, '../..')
const { cylResolvePath, cylIconSource } = require('../src/cyl-placeholder/cyl_animated_icon')
const { cylAnimatedItemModel, CYL_ANIMATED_ITEM_PLACEHOLDER } = require('../src/cyl-animated-item/cyl_animated_item_model')

const read = (file) => fs.readFileSync(path.join(src, file), 'utf8')
const UPSTREAM = 'CrossPlatform/wechat-miniprogram-cyltabbar'
const GENERICS = ['cyl-lottie-view', 'cyl-pag-view', 'cyl-rive-view', 'cyl-svga-view']

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true })
    .flatMap((entry) => (entry.isDirectory() ? walk(path.join(dir, entry.name)) : [path.join(dir, entry.name)]))
}

test('the copy of cyl-animated-item records the commit the Cartfile pins, with its license and placeholder', () => {
  const pinned = fs.readFileSync(path.join(repository, 'Cartfile'), 'utf8').match(/"ChenYilong\/CYLTabBarController"\s+"([0-9a-f]{40})"/)[1]
  const record = read('cyl-animated-item/UPSTREAM_COMMIT')
  assert.match(record, new RegExp(`^commit: ${pinned}$`, 'm'))
  for (const folder of ['cyl-animated-item', 'cyl-animation-placeholder']) {
    assert.match(read(`${folder}/LICENSE.CYLTabBarController`), /MIT|Permission is hereby granted/, folder)
  }
  // Upstream ships the placeholder as a file name or, since its B7 fix, as an inline data URI.
  assert.ok(CYL_ANIMATED_ITEM_PLACEHOLDER.startsWith('data:image/') ||
    fs.existsSync(path.join(src, 'cyl-animated-item', CYL_ANIMATED_ITEM_PLACEHOLDER)), 'the placeholder image ships')
  assert.ok(fs.existsSync(path.join(root, 'test/cyl_animated_item.test.js')), "upstream's model tests are copied")
})

test('the copied files are unchanged from that commit (when the CYLTabBarController checkout is present)', (t) => {
  const pinned = read('cyl-animated-item/UPSTREAM_COMMIT').match(/^commit: ([0-9a-f]{40})$/m)[1]
  const checkout = process.env.CYL_TABBAR_DIR || path.join(repository, 'Carthage/Checkouts/CYLTabBarController')
  const git = (args, encoding) => execFileSync('git', ['-C', checkout, ...args], { encoding, stdio: ['ignore', 'pipe', 'ignore'] })
  try {
    git(['cat-file', '-e', `${pinned}^{commit}`])
  } catch (error) {
    t.skip(`no checkout with ${pinned} (bash scripts/cyltabbarcontroller-checkout.sh)`)
    return
  }
  for (const folder of ['cyl-animated-item', 'cyl-animation-placeholder']) {
    const files = git(['ls-tree', '-r', '--name-only', pinned, '--', `${UPSTREAM}/src/${folder}`], 'utf8').split('\n').filter(Boolean)
    const local = walk(path.join(src, folder)).map((file) => path.relative(path.join(src, folder), file)).sort()
    assert.deepStrictEqual(local, files.map((file) => path.basename(file)).concat(folder === 'cyl-animated-item'
      ? ['LICENSE.CYLTabBarController', 'UPSTREAM_COMMIT'] : ['LICENSE.CYLTabBarController']).sort(), folder)
    for (const file of files) {
      // A Windows checkout (core.autocrlf) has CRLF line endings; compare the text with LF.
      const lf = (buffer) => buffer.toString('latin1').replace(/\r\n/g, '\n')
      assert.strictEqual(lf(fs.readFileSync(path.join(src, folder, path.basename(file)))), lf(git(['show', `${pinned}:${file}`])), file)
    }
  }
  assert.strictEqual(fs.readFileSync(path.join(root, 'test/cyl_animated_item.test.js'), 'utf8').replace(/\r\n/g, '\n'),
    git(['show', `${pinned}:${UPSTREAM}/test/cyl_animated_item.test.js`], 'utf8').replace(/\r\n/g, '\n'))
})

test('paths become absolute for cyl-animated-item, which draws files from its own folder', () => {
  assert.strictEqual(cylResolvePath('./images/', 'components/cyl-placeholder/index'), '/components/cyl-placeholder/images/')
  assert.strictEqual(cylResolvePath('../cyl-placeholder/images/refresh_activity.gif', 'miniprogram_npm/cyl-placeholder-miniprogram/cyl-placeholder-hud/index'),
    '/miniprogram_npm/cyl-placeholder-miniprogram/cyl-placeholder/images/refresh_activity.gif')
  assert.strictEqual(cylResolvePath('images/a.png', 'components/cyl-placeholder/index'), '/components/cyl-placeholder/images/a.png')
  for (const kept of ['/assets/a.png', 'https://example.com/a.png', 'wxfile://tmp/a.png', 'data:image/png;base64,AA', '']) {
    assert.strictEqual(cylResolvePath(kept, 'components/cyl-placeholder/index'), kept)
  }
})

test('engine files become animationUrl, everything else image', () => {
  assert.deepStrictEqual(cylIconSource('/a/x.json'), { image: '', animationUrl: '/a/x.json', type: 'lottie' })
  assert.deepStrictEqual(['/a.pag', '/a.riv', '/a.svga', '/a.lottie'].map((file) => cylIconSource(file).type), ['pag', 'rive', 'svga', 'lottie'])
  assert.deepStrictEqual(cylIconSource('/a/x.gif'), { image: '/a/x.gif', animationUrl: '', type: 'gif' })
  assert.deepStrictEqual(cylIconSource('/a/x.png'), { image: '/a/x.png', animationUrl: '', type: 'image' })
})

test('the display priority the placeholder icons get: animation when ready, else the static icon, else the placeholder', () => {
  const icon = { image: '/components/cyl-placeholder/images/wifi_off.png', animationUrl: '/components/cyl-placeholder/animations/CYLPlaceholderNoInternet.json' }
  assert.strictEqual(cylAnimatedItemModel({ ...icon }).fallbackImage, icon.image, 'loading: the static icon')
  assert.strictEqual(cylAnimatedItemModel({ ...icon, animationLoaded: true }).fallbackHidden, true, 'ready: the animation')
  const failed = cylAnimatedItemModel({ ...icon, animationFailed: true })
  assert.deepStrictEqual([failed.usesEngine, failed.fallbackImage, failed.fallbackHidden], [false, icon.image, false], 'no engine: the static icon')
  assert.strictEqual(cylAnimatedItemModel({ animationUrl: icon.animationUrl, animationFailed: true }).fallbackImage, CYL_ANIMATED_ITEM_PLACEHOLDER)
})

test('every icon and animation of the components goes through cyl-animated-item', () => {
  for (const component of ['cyl-placeholder', 'cyl-placeholder-hud', 'cyl-placeholder-status', 'cyl-refresh']) {
    const json = JSON.parse(read(`${component}/index.json`))
    const wxml = read(`${component}/index.wxml`)
    assert.strictEqual(json.usingComponents['cyl-animated-item'], '../cyl-animated-item/index', component)
    assert.match(wxml, /<cyl-animated-item\b/, component)
    assert.doesNotMatch(wxml, /<animation\b/, `${component} plays no animation of its own`)
    assert.doesNotMatch(wxml, /<image\b/, `${component} draws no icon of its own`)
    // The outer element keeps the accessibility role and label; the item inside is hidden from screen readers.
    for (const match of wxml.matchAll(/<view[^>]*>\s*<cyl-animated-item\b/g)) assert.match(match[0], /aria-hidden="true"/, component)
    const forwards = [...wxml.matchAll(/generic:([\w-]+)="([\w-]+)"/g)].map((m) => m[2])
    for (const name of new Set(forwards)) assert.ok(json.componentGenerics && json.componentGenerics[name], `${component} declares ${name}`)
    for (const tag of wxml.match(/<cyl-animated-item\b[\s\S]*?\/>/g)) {
      if (/animation-url=/.test(tag)) for (const generic of GENERICS) assert.match(tag, new RegExp(`generic:${generic}=`), `${component}: ${generic}`)
    }
  }
})

test('the package depends on no animation library: every engine default is the copied empty view', () => {
  for (const file of walk(src).filter((name) => path.basename(name) === 'index.json')) {
    for (const generic of Object.values(JSON.parse(fs.readFileSync(file, 'utf8')).componentGenerics || {})) {
      assert.strictEqual(path.resolve(path.dirname(file), generic.default), path.join(src, 'cyl-animation-placeholder/index'), path.relative(root, file))
    }
  }
  const pkg = require('../package.json')
  assert.deepStrictEqual(Object.keys(pkg.dependencies || {}), [])
})

test('tinted template icons use the item tint, which spares the animation, not an opacity over the whole icon', () => {
  const wxml = read('cyl-placeholder/index.wxml')
  assert.match(wxml, /icon-tint="\{\{item\.tinted \? '#[0-9a-f]{6}' : ''\}\}"/, 'cyl-placeholder passes icon-tint for tinted items')
  assert.doesNotMatch(wxml + read('cyl-placeholder/index.wxss'), /icon--tinted/, 'no opacity class dims the animation')
})
