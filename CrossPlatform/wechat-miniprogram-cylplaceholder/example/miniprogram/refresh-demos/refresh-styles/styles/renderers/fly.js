// CYLRefreshFlyHeader (SmartRefreshControl's FlyRefreshHeader): a mountain scene (CYLRefreshMountainView) with
// swaying trees, a paper plane (CYLRefreshFlyView) that tilts while pulling and flies out on release.
const { VectorImage } = require('../vector')
const { parseColor } = require('../util')

const FLOAT = 50 // FLOAT_VIEW_SIZE
const TREE_WIDTH = 30
const TREE_HEIGHT = 60
const PLANE = 'M2.01,21L23,12 2.01,3 2,10l15,2 -15,2z'

/** MountainView.mix: color1 blended with color2 by color2's alpha (opaque result). */
function mix(c1, argb) {
  const a = parseColor(c1)
  const ratio = ((argb >>> 24) & 0xff) / 255
  const b = [(argb >> 16) & 0xff, (argb >> 8) & 0xff, argb & 0xff]
  const v = (i) => Math.round(a[i] * (1 - ratio) + b[i] * ratio)
  return `rgb(${v(0)},${v(1)},${v(2)})`
}

function colorsFor(primary) {
  return {
    m1: mix(primary, 0x99ffffff), m2: mix(primary, 0x993c929c), m3: mix(primary, 0xcc3e5f73),
    branch: mix(primary, 0x551f7177), brink: mix(primary, 0xcc0c3e48),
  }
}

/** updateTreePath: the trunk ("brink") and the crown ("branch") bend with the pull. */
function treePaths(percent) {
  const brinkSize = TREE_WIDTH * 0.05
  const branchSize = TREE_WIDTH * 0.2
  const offset = percent * TREE_WIDTH * 0.3
  const branch = []
  const back = []
  const top = TREE_HEIGHT * 0.6
  branch.push(['M', offset + offset * 0.3, top])
  for (let y = top; y > 0; y -= 0.5) {
    const p = y / top
    const x = (1 - Math.pow(1 - p, 0.5)) * offset
    const xs = branchSize * (1 - p * p)
    branch.push(['L', x - xs + offset * 0.3, y])
    back.push([x + xs + offset * 0.3, y])
  }
  const s = offset * 0.3
  branch.push(['L', -branchSize + s, 0])
  branch.push(['C', -branchSize + s, -branchSize * 1.5, branchSize + s, -branchSize * 1.5, branchSize + s, 0])
  for (let i = back.length - 1; i >= 0; i--) branch.push(['L', back[i][0], back[i][1]])
  const brink = []
  const back2 = []
  const topB = TREE_HEIGHT * 0.7
  brink.push(['M', offset, topB])
  for (let y = topB; y > 0; y -= 0.5) {
    const p = (y / topB) * 0.7
    const x = (1 - Math.pow(1 - p, 0.5)) * offset
    const xs = p > 0.35 ? (brinkSize * (0.7 - p)) / 0.35 : brinkSize
    brink.push(['L', x - xs, y])
    back2.push([x + xs, y])
  }
  brink.push(['L', -brinkSize, 0])
  brink.push(['L', brinkSize, 0])
  for (let i = back2.length - 1; i >= 0; i--) brink.push(['L', back2[i][0], back2[i][1]])
  return { branch, brink }
}

function trace(ctx, cmds) {
  ctx.beginPath()
  cmds.forEach((c) => {
    if (c[0] === 'M') ctx.moveTo(c[1], c[2])
    else if (c[0] === 'L') ctx.lineTo(c[1], c[2])
    else ctx.bezierCurveTo(c[1], c[2], c[3], c[4], c[5], c[6])
  })
}

function drawTree(ctx, col, tree) {
  ctx.lineWidth = 6
  ctx.translate(0, TREE_HEIGHT / 2)
  trace(ctx, tree.branch)
  ctx.fillStyle = col.branch
  ctx.fill()
  ctx.strokeStyle = col.brink
  ctx.stroke()
  ctx.translate(0, -TREE_HEIGHT / 2)
  trace(ctx, tree.brink)
  ctx.fillStyle = col.brink
  ctx.fill()
}

function ridge(ctx, w, h, y0, pts, color) {
  ctx.beginPath()
  let y = y0
  ctx.moveTo(0, y)
  pts.forEach((p) => { y += p[1]; ctx.lineTo(p[0], y) })
  ctx.lineTo(w, h)
  ctx.lineTo(0, h)
  ctx.closePath()
  ctx.fillStyle = color
  ctx.fill()
}

function drawMountain(ctx, w, h, offset, col, tree) {
  const u = w / 29
  ridge(ctx, w, h, h - u * 4 - offset * 0.6, [[u * 6, -u * 4], [u * 17, u * 4.5], [u * 27, -u * 5.5], [w, u * 2]], col.m1)
  const t = (x, y, sx, sy) => { ctx.save(); ctx.translate(x, y); ctx.scale(sx, sy); drawTree(ctx, col, tree); ctx.restore() }
  t(u * 6.5, h - u * 5 - offset * 0.4, -0.7, -0.7)
  t(u * 4.5, h - u * 4.5 - offset * 0.4, -0.5, -0.5)
  ridge(ctx, w, h, h - u * 3 - offset * 0.4, [[u * 7, -u * 3], [u * 18, u * 4.5], [u * 26, -u * 4.5], [w, u * 2]], col.m2)
  t(u * 16, h - u * 3 - offset * 0.2, 0.85, -0.85)
  t(u * 19, h - u * 3 - offset * 0.2, 1, -1)
  t(u * 22, h - u * 3 - offset * 0.2, 0.7, -0.7)
  const y = h - u * 2 - offset * 0.2
  ctx.beginPath()
  ctx.moveTo(0, y)
  ctx.bezierCurveTo(u * 3.5, y - u, u * 21, y - u * 3, w, y - u)
  ctx.lineTo(w, h)
  ctx.lineTo(0, h)
  ctx.closePath()
  ctx.fillStyle = col.m3
  ctx.fill()
}

/** The fly-out path (a quadratic curve) sampled by arc length, for kCAAnimationPaced. */
function flyPath(w, startY) {
  const p0 = [FLOAT * 3 / 4, startY]
  const c = [0, 0]
  const p1 = [w + FLOAT / 2, FLOAT / 4]
  const pts = []
  let len = 0
  let prev = p0
  for (let i = 0; i <= 60; i++) {
    const t = i / 60
    const x = (1 - t) * (1 - t) * p0[0] + 2 * (1 - t) * t * c[0] + t * t * p1[0]
    const y = (1 - t) * (1 - t) * p0[1] + 2 * (1 - t) * t * c[1] + t * t * p1[1]
    len += Math.hypot(x - prev[0], y - prev[1])
    pts.push({ x, y, len })
    prev = [x, y]
  }
  return { pts, len }
}

function along(path, f) {
  const target = f * path.len
  const pts = path.pts
  let i = 1
  while (i < pts.length - 1 && pts[i].len < target) i++
  const a = pts[i - 1]
  const b = pts[i]
  const k = b.len > a.len ? (target - a.len) / (b.len - a.len) : 0
  return { x: a.x + (b.x - a.x) * k, y: a.y + (b.y - a.y) * k, angle: Math.atan2(b.y - a.y, b.x - a.x) }
}

/** CAMediaTimingFunction easeOut, cubic-bezier(0, 0, 0.58, 1). */
function easeOut(x) {
  let lo = 0
  let hi = 1
  for (let i = 0; i < 20; i++) {
    const t = (lo + hi) / 2
    const bx = 3 * (1 - t) * t * t * 0.58 + t * t * t
    if (bx < x) lo = t
    else hi = t
  }
  const t = (lo + hi) / 2
  return 3 * (1 - t) * t * t + t * t * t
}

const HEIGHT = 150

module.exports = {
  height: HEIGHT,
  triggerRate: 0.5,
  primary: '#33aaff',
  accent: '#ffffff',
  stretch: true,
  create() {
    const plane = new VectorImage([PLANE])
    // CYLRefreshFlyView: 30 x 30, the image scaled to fit inside.
    const s = plane.size
    const k = Math.min(30 / s.w, 30 / s.h)
    plane.setSize(s.w * k, s.h * k)
    return { plane, flyStart: 0, flying: false, path: null, colorsKey: '', colors: null }
  },
  status(mem, old, now, v) {
    if (now === 'Releasing') {
      mem.flying = true
      mem.flyStart = v.now
      mem.path = flyPath(v.w, HEIGHT)
    } else if (now === 'Idle' || now === 'Pulling') {
      mem.flying = false
    }
  },
  animating(mem, v) {
    return mem.flying && v.now - mem.flyStart < 1500
  },
  draw(ctx, v, mem) {
    if (mem.colorsKey !== v.primary) { mem.colorsKey = v.primary; mem.colors = colorsFor(v.primary) }
    const H = Math.max(v.h, HEIGHT)
    ctx.save()
    ctx.translate(0, v.h - H)
    ctx.fillStyle = v.primary
    ctx.fillRect(0, 0, v.w, H)
    // The mountain view's own pull offset is the drag past the always-open area, which a mini program header
    // does not have: 0 here, so only the trees sway with the percent.
    drawMountain(ctx, v.w, H, 0, mem.colors, treePaths(Math.min(v.percent, 2)))
    // Float view: a primary-colored circle behind the plane's resting place.
    ctx.beginPath()
    ctx.arc(FLOAT * 3 / 4, H, FLOAT / 2, 0, Math.PI * 2)
    ctx.fillStyle = v.primary
    ctx.fill()
    mem.plane.setColors([v.accent])
    const ps = mem.plane.size
    ctx.save()
    if (mem.flying && mem.path) {
      const f = Math.min(1, (v.now - mem.flyStart) / 1500)
      const e = easeOut(f)
      const p = along(mem.path, e)
      ctx.translate(p.x, p.y)
      ctx.rotate(p.angle)
      ctx.scale(1 - 0.5 * e, 1 - 0.8 * e)
    } else {
      ctx.translate(FLOAT * 3 / 4, H)
      ctx.rotate((-(v.h / HEIGHT) * Math.PI) / 4)
    }
    // The image is centered in the 30 x 30 view.
    mem.plane.moveTo(-15 + (30 - ps.w) / 2, -15 + (30 - ps.h) / 2)
    mem.plane.render(ctx)
    ctx.restore()
    ctx.restore()
  },
}
