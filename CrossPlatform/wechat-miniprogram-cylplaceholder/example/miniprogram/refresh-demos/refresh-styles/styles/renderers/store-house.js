// CYLRefreshStoreHouseHeader (CYLRefresh styles's StoreHouseHeader): the default text "store house" drawn as
// line segments that fly in, rotate and scale into place while pulling, then flash one by one while refreshing.

// CYLRefreshStoreHousePath letter data (only the letters of "store house"), as x1,y1,x2,y2 per segment.
const { alpha } = require('../util')
const LETTERS = {
  e: [0, 0, 0, 72, 0, 0, 47, 0, 0, 36, 37, 36, 0, 72, 47, 72],
  h: [0, 0, 0, 72, 0, 36, 47, 36, 47, 0, 47, 72],
  o: [0, 0, 0, 72, 0, 72, 47, 72, 47, 72, 47, 0, 47, 0, 0, 0],
  r: [0, 0, 0, 72, 0, 0, 47, 0, 47, 0, 47, 36, 47, 36, 0, 36, 0, 37, 47, 72],
  s: [47, 0, 0, 0, 0, 0, 0, 36, 0, 36, 47, 36, 47, 36, 47, 72, 47, 72, 0, 72],
  t: [0, 0, 47, 0, 24, 0, 24, 72],
  u: [0, 0, 0, 72, 0, 72, 47, 72, 47, 72, 47, 0],
}
const TEXT = 'store house'
const SCALE = 0.25 // DEFAULT_SCALE (1) * 0.25 in linesFrom:
const SPACE = 10
const PADDING = 1.5 // DEFAULT_PADDING: times the text height
const DARK_ALPHA = 0.4
const FACTOR = 0.7 // internalAnimationFactor
const LINE_WIDTH = 2

function makeLines() {
  const lines = []
  let offsetX = 0
  for (const ch of TEXT) {
    const p = LETTERS[ch] || []
    for (let i = 0; i + 3 < p.length; i += 4) {
      const x1 = (offsetX + p[i]) * SCALE
      const y1 = p[i + 1] * SCALE
      const x2 = (offsetX + p[i + 2]) * SCALE
      const y2 = p[i + 3] * SCALE
      lines.push({ x1, y1, x2, y2, mx: (x1 + x2) / 2, my: (y1 + y2) / 2, offset: (Math.floor(Math.random() * 200) - 100) / 100, alpha: 0, p: 0 })
    }
    offsetX += 57 + SPACE
  }
  return lines
}

const LINES = makeLines()
let RECT_W = 0
let RECT_H = 0
LINES.forEach((l) => {
  RECT_W = Math.max(RECT_W, l.x1, l.x2)
  RECT_H = Math.max(RECT_H, l.y1, l.y2)
})
const PAD = PADDING > 5 ? PADDING : PADDING * RECT_H
const HEIGHT = PAD * 2 + RECT_H

/** updateLinesWithProgress: each segment's own progress (p: 0 off-screen .. 1 in place) and alpha. */
function update(mem, progress, refreshing) {
  const len = mem.lines.length
  mem.lines.forEach((line, i) => {
    const start = ((1 - FACTOR) / len) * i
    const end = 1 - FACTOR - start
    if (progress >= 1 || progress >= 1 - end) {
      if (!refreshing) line.alpha = DARK_ALPHA
      line.p = 1
    } else if (progress <= 0) {
      line.p = 0
    } else if (!refreshing) {
      const real = progress <= start ? 0 : Math.min(1, (progress - start) / FACTOR)
      line.p = real
      line.alpha = real * DARK_ALPHA
    }
  })
}

module.exports = {
  height: HEIGHT,
  primary: 'rgb(77,77,77)', // 0.3 gray
  accent: '#ffffff',
  stretch: true,
  create() {
    return { lines: LINES.map((l) => Object.assign({}, l)), index: 0, lastTick: 0, lastFade: 0 }
  },
  status(mem, old, now, v) {
    if (now === 'Releasing') {
      mem.index = 0
      mem.lastTick = v.now
      mem.lastFade = v.now
    }
  },
  draw(ctx, v, mem) {
    const refreshing = v.status === 'Refreshing'
    if (refreshing) {
      // NSTimer every 75 ms lights the next segment; the loading animator dims all by 0.01 per frame.
      while (v.now - mem.lastTick >= 75) {
        mem.lastTick += 75
        const n = mem.lines.length
        if (mem.index < n) mem.lines[mem.index++].alpha = 1
        else if (++mem.index - n === 2) mem.index = 0
      }
      const frames = Math.max(1, Math.round((v.now - mem.lastFade) / 16.7))
      mem.lastFade = v.now
      mem.lines.forEach((l) => { if (l.alpha > DARK_ALPHA) l.alpha = Math.max(DARK_ALPHA, l.alpha - 0.01 * frames) })
      update(mem, 1, true)
    } else {
      update(mem, v.percent, false)
    }
    ctx.fillStyle = v.primary
    ctx.fillRect(0, 0, v.w, v.h)
    ctx.lineWidth = LINE_WIDTH
    const ox = v.w / 2 - RECT_W / 2
    ctx.save()
    ctx.translate(ox, PAD)
    mem.lines.forEach((l) => {
      const r = l.p
      ctx.save()
      ctx.translate(l.offset * v.w * (1 - r), -v.expand * (1 - r))
      ctx.translate(l.mx, l.my)
      ctx.rotate(Math.PI * r)
      ctx.scale(r || 0.0001, r || 0.0001)
      ctx.translate(-l.mx, -l.my)
      ctx.beginPath()
      ctx.moveTo(l.x1, l.y1)
      ctx.lineTo(l.x2, l.y2)
      ctx.strokeStyle = alpha(v.accent, l.alpha)
      ctx.stroke()
      ctx.restore()
    })
    ctx.restore()
  },
}
