// How this package's components feed CYLTabBarController's cyl-animated-item (src/cyl-animated-item, copied unchanged
// by scripts/sync-cyl-animated-item.js). cyl-placeholder, cyl-placeholder-hud, cyl-placeholder-status and cyl-refresh
// draw every icon and animation through cyl-animated-item, which shows the animation once its engine reports `ready`,
// else the static image, else its placeholder (the display priority of iOS CYLAnimatedItemView and Android). Pure
// functions without any wx API, tested in Node (test/animated_icon.test.js).
'use strict'

const { cylAnimatedItemType } = require('../cyl-animated-item/cyl_animated_item_model')

/**
 * The animation types that need an engine component (the abstract nodes of cyl-animated-item). GIF is not one:
 * `<image>` draws it.
 */
const CYL_ENGINE_TYPES = ['lottie', 'pag', 'rive', 'svga']

/**
 * An absolute package path for `path`, resolved against the folder of the component `componentIs` (a component's
 * `this.is`, such as "components/cyl-placeholder/index"). cyl-animated-item draws the files from its own folder, so a
 * path relative to the calling component ("./images/", "../cyl-placeholder/images/x.png") must become absolute first.
 * Absolute paths ("/…") and URLs ("https:", "wxfile:", "data:") stay as they are; a trailing "/" is kept.
 */
function cylResolvePath(path, componentIs) {
  const value = String(path || '')
  if (!value || value[0] === '/' || /^[a-z][a-z0-9+.-]*:/i.test(value)) return value
  const parts = String(componentIs || '').split('/').filter(Boolean)
  parts.pop()
  for (const segment of value.split('/')) {
    if (segment === '..') parts.pop()
    else if (segment && segment !== '.') parts.push(segment)
  }
  return '/' + parts.join('/') + (value.endsWith('/') && parts.length ? '/' : '')
}

/**
 * The cyl-animated-item properties for one file: `animationUrl` for a file an engine plays (Lottie `.json` /
 * `.lottie`, PAG, Rive, SVGA), `image` for everything else (PNG, JPEG, SVG, WebP and GIF, which `<image>` animates).
 */
function cylIconSource(path) {
  const value = String(path || '')
  const type = cylAnimatedItemType(value)
  return CYL_ENGINE_TYPES.includes(type) ? { image: '', animationUrl: value, type } : { image: value, animationUrl: '', type: type || 'image' }
}

module.exports = { cylResolvePath, cylIconSource, CYL_ENGINE_TYPES }
