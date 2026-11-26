// Copies CYLTabBarController's cyl-animated-item component (CYLAnimatedItem for WeChat Mini Program) into this
// package, at the commit the repository's Cartfile pins, while the upstream package is unpublished (CYLTabBarController
// docs/Animated-Item.md allows a copy of src/cyl-animated-item). Copied unchanged:
//   src/cyl-animated-item/           the component and its render model (cyl_animated_item_model.js, placeholder image)
//   src/cyl-animation-placeholder/   the default of its abstract nodes (cyl-lottie-view, cyl-pag-view, …)
//   src/cyl-dealloc-block-executor/  upstream's vendored CYLDeallocBlockExecutor (MIT, its own LICENSE and VENDORED.md),
//                                    which cyl-animated-item requires from b0887513 on (lifecycle and animation events)
//   test/cyl_animated_item.test.js   upstream's node tests of the model (run by `npm test`)
// plus the upstream src/LICENSE as LICENSE.CYLTabBarController in both folders and src/cyl-animated-item/UPSTREAM_COMMIT.
// Never edit the copied files: adapt this package's components instead, and run this script again after the Cartfile
// moves (`npm run sync-animated-item`).
//
// Source: the git objects of a CYLTabBarController checkout (CYL_TABBAR_DIR, else the repository's
// Carthage/Checkouts/CYLTabBarController that `bash scripts/cyltabbarcontroller-checkout.sh` creates). Files are read
// with `git show <commit>:<path>`, so the copy is the Cartfile's commit whatever the checkout's HEAD is.
'use strict'
const fs = require('fs')
const path = require('path')
const { execFileSync } = require('child_process')

const pkg = path.resolve(__dirname, '..')
const repository = path.resolve(pkg, '../..')
const UPSTREAM = 'CrossPlatform/wechat-miniprogram-cyltabbar'
const COPIES = [
  { from: `${UPSTREAM}/src/cyl-animated-item`, to: 'src/cyl-animated-item' },
  { from: `${UPSTREAM}/src/cyl-animation-placeholder`, to: 'src/cyl-animation-placeholder' },
  { from: `${UPSTREAM}/src/cyl-dealloc-block-executor`, to: 'src/cyl-dealloc-block-executor' },
]
const TEST = { from: `${UPSTREAM}/test/cyl_animated_item.test.js`, to: 'test/cyl_animated_item.test.js' }
const LICENSE = { from: `${UPSTREAM}/src/LICENSE`, name: 'LICENSE.CYLTabBarController' }

/** The CYLTabBarController commit pinned by the repository's Cartfile. */
function cartfileCommit() {
  const cartfile = fs.readFileSync(path.join(repository, 'Cartfile'), 'utf8')
  const match = cartfile.match(/^github\s+"ChenYilong\/CYLTabBarController"\s+"([0-9a-f]{40})"/m)
  if (!match) throw new Error('Cartfile does not pin ChenYilong/CYLTabBarController to a 40-character commit.')
  return match[1]
}

function git(checkout, args, encoding = 'utf8') {
  return execFileSync('git', ['-C', checkout, ...args], { encoding, maxBuffer: 64 * 1024 * 1024 })
}

function main() {
  const commit = cartfileCommit()
  const checkout = process.env.CYL_TABBAR_DIR || path.join(repository, 'Carthage/Checkouts/CYLTabBarController')
  try {
    git(checkout, ['cat-file', '-e', `${commit}^{commit}`])
  } catch (error) {
    console.error(`CYLTabBarController commit ${commit} is not in ${checkout}. Run \`bash scripts/cyltabbarcontroller-checkout.sh\` ` +
      'in the repository root, or set CYL_TABBAR_DIR to a checkout that has it.')
    process.exit(1)
  }
  const show = (file) => git(checkout, ['show', `${commit}:${file}`], 'buffer')
  const license = show(LICENSE.from)
  for (const copy of COPIES) {
    const target = path.join(pkg, copy.to)
    fs.rmSync(target, { recursive: true, force: true })
    const files = git(checkout, ['ls-tree', '-r', '--name-only', commit, '--', copy.from]).split('\n').filter(Boolean)
    if (!files.length) throw new Error(`${copy.from} does not exist at ${commit}.`)
    for (const file of files) {
      const destination = path.join(target, path.relative(copy.from, file))
      fs.mkdirSync(path.dirname(destination), { recursive: true })
      fs.writeFileSync(destination, show(file))
    }
    fs.writeFileSync(path.join(target, LICENSE.name), license)
    console.log(`synced ${copy.to} (${files.length} files) from ${commit.slice(0, 8)}`)
  }
  fs.writeFileSync(path.join(pkg, TEST.to), show(TEST.from))
  console.log(`synced ${TEST.to}`)
  fs.writeFileSync(path.join(pkg, 'src/cyl-animated-item/UPSTREAM_COMMIT'), [
    'repository: https://github.com/ChenYilong/CYLTabBarController',
    `commit: ${commit}`,
    `paths: ${COPIES.map((copy) => copy.from).join(', ')}, ${TEST.from}`,
    `license: MIT, ${LICENSE.name} in each copied folder (the same commit's ${LICENSE.from})`,
    'copied unchanged by scripts/sync-cyl-animated-item.js (npm run sync-animated-item) at the commit of the repository Cartfile; do not edit',
    '',
  ].join('\n'))
}

main()
