// A small port of CYLRefresh styles's vector support (CYLRefreshVectorImage / CYLRefreshVectorPathElement):
// SVG path data parsed once into absolute canvas commands, a bounding box (control points included, like
// CGPathGetBoundingBox), and an image of several filled paths that can be sized, moved and rendered.

const NUM = /-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?/g
const ARGS = { M: 2, L: 2, H: 1, V: 1, C: 6, S: 4, Q: 4, T: 2, A: 7, Z: 0 }

function tokenize(d) {
  const out = []
  const re = /([MmLlHhVvCcSsQqTtAaZz])|(-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?)/g
  let m
  while ((m = re.exec(d))) out.push(m[1] ? m[1] : parseFloat(m[2]))
  return out
}

/** Elliptical arc (endpoint form) to cubic Bezier segments, appended to `cmds`. */
function arcToCubics(cmds, x1, y1, rx, ry, phi, fa, fs, x2, y2) {
  if (rx === 0 || ry === 0) { cmds.push(['L', x2, y2]); return }
  rx = Math.abs(rx); ry = Math.abs(ry)
  const r = (phi * Math.PI) / 180
  const cos = Math.cos(r)
  const sin = Math.sin(r)
  const dx = (x1 - x2) / 2
  const dy = (y1 - y2) / 2
  const x1p = cos * dx + sin * dy
  const y1p = -sin * dx + cos * dy
  let lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry)
  if (lambda > 1) { lambda = Math.sqrt(lambda); rx *= lambda; ry *= lambda }
  const num = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p
  const den = rx * rx * y1p * y1p + ry * ry * x1p * x1p
  let coef = Math.sqrt(Math.max(0, num / den))
  if (fa === fs) coef = -coef
  const cxp = (coef * rx * y1p) / ry
  const cyp = (-coef * ry * x1p) / rx
  const cx = cos * cxp - sin * cyp + (x1 + x2) / 2
  const cy = sin * cxp + cos * cyp + (y1 + y2) / 2
  const angle = (ux, uy, vx, vy) => {
    const a = Math.atan2(ux * vy - uy * vx, ux * vx + uy * vy)
    return a
  }
  const t1 = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
  let dt = angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
  if (!fs && dt > 0) dt -= 2 * Math.PI
  else if (fs && dt < 0) dt += 2 * Math.PI
  const segments = Math.max(1, Math.ceil(Math.abs(dt) / (Math.PI / 2)))
  const delta = dt / segments
  const k = (4 / 3) * Math.tan(delta / 4)
  let t = t1
  const point = (a) => {
    const ex = rx * Math.cos(a)
    const ey = ry * Math.sin(a)
    return [cos * ex - sin * ey + cx, sin * ex + cos * ey + cy]
  }
  const deriv = (a) => {
    const ex = -rx * Math.sin(a)
    const ey = ry * Math.cos(a)
    return [cos * ex - sin * ey, sin * ex + cos * ey]
  }
  for (let i = 0; i < segments; i++) {
    const p0 = point(t)
    const d0 = deriv(t)
    const p3 = point(t + delta)
    const d3 = deriv(t + delta)
    cmds.push(['C', p0[0] + k * d0[0], p0[1] + k * d0[1], p3[0] - k * d3[0], p3[1] - k * d3[1], p3[0], p3[1]])
    t += delta
  }
}

/** Parses SVG path data into absolute commands: M, L, C, Q, Z. */
function parsePath(d) {
  const tokens = tokenize(d)
  const cmds = []
  let i = 0
  let cmd = ''
  let x = 0
  let y = 0
  let sx = 0
  let sy = 0
  let lastCtrl = null
  let lastQuad = null
  while (i < tokens.length) {
    if (typeof tokens[i] === 'string') cmd = tokens[i++]
    else if (!cmd) { i++; continue }
    const up = cmd.toUpperCase()
    const rel = cmd !== up
    const n = ARGS[up]
    if (up === 'Z') {
      cmds.push(['Z']); x = sx; y = sy; lastCtrl = lastQuad = null
      continue
    }
    if (i + n > tokens.length || tokens.slice(i, i + n).some((v) => typeof v === 'string')) { i++; continue }
    const a = tokens.slice(i, i + n)
    i += n
    const ox = rel ? x : 0
    const oy = rel ? y : 0
    let ctrl = null
    let quad = null
    switch (up) {
      case 'M':
        x = a[0] + ox; y = a[1] + oy; sx = x; sy = y
        cmds.push(['M', x, y])
        cmd = rel ? 'l' : 'L'
        break
      case 'L': x = a[0] + ox; y = a[1] + oy; cmds.push(['L', x, y]); break
      case 'H': x = a[0] + (rel ? x : 0); cmds.push(['L', x, y]); break
      case 'V': y = a[0] + (rel ? y : 0); cmds.push(['L', x, y]); break
      case 'C': {
        const c = ['C', a[0] + ox, a[1] + oy, a[2] + ox, a[3] + oy, a[4] + ox, a[5] + oy]
        cmds.push(c); ctrl = [c[3], c[4]]; x = c[5]; y = c[6]
        break
      }
      case 'S': {
        const c1 = lastCtrl ? [2 * x - lastCtrl[0], 2 * y - lastCtrl[1]] : [x, y]
        const c = ['C', c1[0], c1[1], a[0] + ox, a[1] + oy, a[2] + ox, a[3] + oy]
        cmds.push(c); ctrl = [c[3], c[4]]; x = c[5]; y = c[6]
        break
      }
      case 'Q': {
        const c = ['Q', a[0] + ox, a[1] + oy, a[2] + ox, a[3] + oy]
        cmds.push(c); quad = [c[1], c[2]]; x = c[3]; y = c[4]
        break
      }
      case 'T': {
        const q = lastQuad ? [2 * x - lastQuad[0], 2 * y - lastQuad[1]] : [x, y]
        const c = ['Q', q[0], q[1], a[0] + ox, a[1] + oy]
        cmds.push(c); quad = q; x = c[3]; y = c[4]
        break
      }
      case 'A': {
        const ex = a[5] + ox
        const ey = a[6] + oy
        arcToCubics(cmds, x, y, a[0], a[1], a[2], !!a[3], !!a[4], ex, ey)
        x = ex; y = ey
        break
      }
    }
    lastCtrl = ctrl
    lastQuad = quad
  }
  return cmds
}

/** Bounding box of commands, control points included (CGPathGetBoundingBox). */
function boundsOf(cmds) {
  let minX = Infinity
  let minY = Infinity
  let maxX = -Infinity
  let maxY = -Infinity
  cmds.forEach((c) => {
    for (let k = 1; k + 1 < c.length; k += 2) {
      minX = Math.min(minX, c[k]); maxX = Math.max(maxX, c[k])
      minY = Math.min(minY, c[k + 1]); maxY = Math.max(maxY, c[k + 1])
    }
  })
  if (minX === Infinity) return { x: 0, y: 0, w: 0, h: 0 }
  return { x: minX, y: minY, w: maxX - minX, h: maxY - minY }
}

/** Traces commands as the current canvas path (beginPath included). */
function tracePath(ctx, cmds) {
  ctx.beginPath()
  for (let i = 0; i < cmds.length; i++) {
    const c = cmds[i]
    switch (c[0]) {
      case 'M': ctx.moveTo(c[1], c[2]); break
      case 'L': ctx.lineTo(c[1], c[2]); break
      case 'C': ctx.bezierCurveTo(c[1], c[2], c[3], c[4], c[5], c[6]); break
      case 'Q': ctx.quadraticCurveTo(c[1], c[2], c[3], c[4]); break
      case 'Z': ctx.closePath(); break
    }
  }
}

const cache = {}
/** Parsed commands of path data, cached. */
function path(d) {
  if (!cache[d]) cache[d] = parsePath(d)
  return cache[d]
}

/** CYLRefreshVectorImage: several filled paths; size defaults to the union of their boxes (the viewport). */
class VectorImage {
  constructor(paths, colors) {
    this.elements = paths.map((d) => ({ cmds: path(d), fill: '#ffffff' }))
    let x0 = Infinity
    let y0 = Infinity
    let x1 = -Infinity
    let y1 = -Infinity
    this.elements.forEach((e) => {
      const b = boundsOf(e.cmds)
      x0 = Math.min(x0, b.x); y0 = Math.min(y0, b.y)
      x1 = Math.max(x1, b.x + b.w); y1 = Math.max(y1, b.y + b.h)
    })
    this.viewport = { x: x0, y: y0, w: x1 - x0, h: y1 - y0 }
    this.frame = null
    this.opacity = 1
    if (colors) this.setColors(colors)
  }
  setColors(colors) {
    let color = colors[0]
    this.elements.forEach((e, i) => {
      if (i < colors.length) color = colors[i]
      e.fill = color
    })
  }
  get size() {
    return this.frame ? { w: this.frame.w, h: this.frame.h } : { w: this.viewport.w, h: this.viewport.h }
  }
  setSize(w, h) {
    this.frame = { x: this.frame ? this.frame.x : 0, y: this.frame ? this.frame.y : 0, w, h }
  }
  setGeometricWidth(w) {
    const s = this.size
    if (s.w && s.h) this.setSize(w, (s.h * w) / s.w)
  }
  setGeometricHeight(h) {
    const s = this.size
    if (s.w && s.h) this.setSize((s.w * h) / s.h, h)
  }
  moveTo(x, y) {
    const s = this.size
    this.frame = { x, y, w: s.w, h: s.h }
  }
  render(ctx) {
    const vp = this.viewport
    if (!vp.w || !vp.h) return
    const s = this.size
    const f = this.frame || { x: 0, y: 0 }
    const sx = s.w / vp.w
    const sy = s.h / vp.h
    ctx.save()
    ctx.translate(f.x - sx * vp.x, f.y - sy * vp.y)
    ctx.scale(sx, sy)
    const alpha = ctx.globalAlpha
    ctx.globalAlpha = alpha * this.opacity
    this.elements.forEach((e) => {
      tracePath(ctx, e.cmds)
      ctx.fillStyle = e.fill
      ctx.fill()
    })
    ctx.globalAlpha = alpha
    ctx.restore()
  }
}

module.exports = { parsePath, boundsOf, tracePath, path, VectorImage, NUM }
