// The CYLRefresh style renderers, by style name (the page's method without the "style" prefix).
//
// Renderer contract (used by ../style-canvas):
//   height        open height in px (expandHeight of the iOS style); also cyl-refresh's header / footer height
//   triggerRate   optional, default 1 (percent = h / (height * triggerRate))
//   primary       default colorPrimary (CSS color, 'transparent' for clear); accent: default colorAccent
//   stretch       true for CYLRefreshScrollModeStretch styles: the canvas area above y = 0 is filled with primary
//   create()                  → the per-instance state object (mem)
//   layout(mem, width)        optional, once the canvas width is known (scrollView:attached:)
//   status(mem, old, now, v)  optional, status changes: 'Idle' | 'Pulling' | 'Release' | 'Releasing' |
//                             'Refreshing' | 'Finishing' (old only) | 'NoMoreData'
//   draw(ctx, v, mem)         v = { w, h, expand, percent, status, part, primary, accent, now (ms), dt (s) }
//   animating(mem, v)         optional, true to keep redrawing outside 'Refreshing'
//   touch(mem, {type,x,y})    optional, canvas touches (header canvases do not get touches: cyl-refresh's header
//                             ignores pointer events)

const names = [
  'Delivery', 'Classics', 'DropBox', 'Phoenix', 'Taurus', 'BezierRadar', 'BezierCircle', 'StoreHouse', 'WaveSwipe',
  'Original', 'Material', 'GameHitBlock', 'GameBattleCity', 'Fly',
]

const RENDERERS = {
  Delivery: require('./delivery'),
  DropBox: require('./dropbox'),
  Phoenix: require('./phoenix'),
  Taurus: require('./taurus'),
  BezierRadar: require('./bezier-radar'),
  BezierCircle: require('./bezier-circle'),
  StoreHouse: require('./store-house'),
  WaveSwipe: require('./wave-swipe'),
  Original: require('./original'),
  Material: require('./material'),
  GameHitBlock: require('./game-hit-block'),
  GameBattleCity: require('./game-battle-city'),
  Fly: require('./fly'),
}
// Rive packages: drawn stand-ins (no Rive runtime in mini programs).
const rive = require('./rive')
;['RiveBow', 'RiveBubbles', 'RiveHalloween', 'RiveSkating', 'RiveSpace', 'RiveSquats'].forEach((k) => { RENDERERS[k] = rive[k] })

module.exports = { RENDERERS, names }
