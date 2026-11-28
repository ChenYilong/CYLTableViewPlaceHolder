// CYLRefreshWaveSwipeHeader (CYLRefresh styles's WaveSwipeHeader): a wave hangs down from the top while pulling,
// with a Material arrow under it; on release the wave springs back, a drop falls and bounces, and the arrow spins
// as Material's progress ring while refreshing.

const CIRCLE = 40 // kCircleSize
const ARROW_SIZE = 2 // kMaxArrowSize
const ARROW_RADIUS = 8 // kMaxArrowRadius
const MAX_ARC = 0.8 // MAX_PROGRESS_ARC / MAX_PROGRESS_ANGLE
const NUM_POINTS = 5
const FULL_ROTATION = 1080
const ANIMATION_DURATION = 1332 // ms
const WAVE_FIRST = 0.1
const WAVE_SECOND = 0.16 + WAVE_FIRST
const DROP_VERTEX = 500
const DROP_BOUNCE = 500
const DROP_CIRCLE = 500
const WAVE_DURATION = 1000
const MAX_WAVE_HEIGHT = 0.2
const DROP_RADIUS = ARROW_RADIUS // dropCircleRadius

const BEGIN = [[0.1655, 0], [0.4188, -0.0109], [0.4606, -0.0049], [0.4893, 0], [0.4893, 0], [0.5, 0]]
const APPEAR = [[0.1655, 0], [0.5237, 0.0553], [0.4557, 0.0936], [0.3908, 0.1302], [0.4303, 0.2173], [0.5, 0.2173]]
const EXPAND = [[0.1655, 0], [0.5909, 0], [0.4557, 0.1642], [0.3941, 0.2061], [0.4303, 0.2889], [0.5, 0.2889]]

/** cubic-bezier easing solver (x → y). */
function bezier(x1, y1, x2, y2) {
  const c = (t, a, b) => 3 * (1 - t) * (1 - t) * t * a + 3 * (1 - t) * t * t * b + t * t * t
  return (x) => {
    if (x <= 0) return 0
    if (x >= 1) return 1
    let lo = 0
    let hi = 1
    for (let i = 0; i < 24; i++) {
      const t = (lo + hi) / 2
      if (c(t, x1, x2) < x) lo = t
      else hi = t
    }
    return c((lo + hi) / 2, y1, y2)
  }
}
// FAST_OUT_SLOW_VALUES is Android's FastOutSlowInInterpolator table: cubic-bezier(0.4, 0, 0.2, 1).
const fastOutSlow = bezier(0.4, 0, 0.2, 1)
const accelDecel = (t) => Math.cos((t + 1) * Math.PI) / 2 + 0.5
const decelerate = (t) => 1 - (1 - t) * (1 - t)
function bounce(v) {
  const b = (x) => x * x * 8
  v *= 1.1226
  if (v < 0.3535) return b(v)
  if (v < 0.7408) return b(v - 0.54719) + 0.7
  if (v < 0.9644) return b(v - 0.8526) + 0.9
  return b(v - 1.0435) + 0.95
}
function dropBounce(v) {
  if (v < 0.25) return -38.4 * (v - 0.125) * (v - 0.125) + 0.6
  if (v >= 0.5 && v < 0.75) return -19.2 * (v - 0.625) * (v - 0.625) + 0.3
  return 0
}
const MIN_ARC = (ARROW_SIZE / (2 * Math.PI * ARROW_RADIUS)) * Math.PI / 180

/** The wave of the pull (the three phases of onScrollingWithOffset), as a list of cubic segments; sets mem.oy. */
function wavePull(w, first, mem) {
  const second = first - WAVE_FIRST
  const fin = (first - WAVE_SECOND) / 5
  const B = BEGIN
  const A = APPEAR
  const E = EXPAND
  const min = Math.min
  const max = Math.max
  if (first < WAVE_FIRST) {
    if (first <= 0.008) return null
    const m = first
    return [
      [w * B[0][0], B[0][1], w * B[1][0], w * (B[1][1] + m), w * B[2][0], w * (B[2][1] + m)],
      [w * B[3][0], w * (B[3][1] + m), w * B[4][0], w * (B[4][1] + m), w * B[5][0], w * (B[5][1] + m)],
      [w - w * B[4][0], w * (B[4][1] + m), w - w * B[3][0], w * (B[3][1] + m), w - w * B[2][0], w * (B[2][1] + m)],
      [w - w * B[1][0], w * (B[1][1] + m), w - w * B[0][0], B[0][1], w, 0],
    ]
  }
  const m1 = first
  const m2 = second
  const m3 = first < WAVE_SECOND ? null : fin
  // Phase 2 values, then clamped further by phase 3 when it applies.
  let p1x = min(B[1][0] + m2, A[1][0])
  let p1y = max(B[1][1] + m1 - m2, A[1][1])
  let p2x = max(B[2][0] - m2, A[2][0])
  let p2y = max(B[2][1] + m1 - m2, A[2][1])
  let p3x = max(B[3][0] - m2, A[3][0])
  let p3y = min(B[3][1] + m1 + m2, A[3][1])
  let p4x = max(B[4][0] - m2, A[4][0])
  let p4y = min(B[4][1] + m1 + m2, A[4][1])
  let p5y = min(B[0][1] + m1 + m2, A[5][1])
  let p0 = A[0]
  if (m3 != null) {
    p1x = min(p1x + m3, E[1][0])
    p1y = max(p1y - m3, E[1][1])
    p2x = max(B[2][0] - m2, E[2][0])
    p2y = min(p2y + m3, E[2][1])
    p3x = min(p3x + m3, E[3][0])
    p3y = min(p3y + m3, E[3][1])
    p4x = max(B[4][0] - m2, E[4][0])
    p4y = min(p4y + m3, E[4][1])
    p5y = min(p5y + m3, E[5][1])
    p0 = E[0]
  }
  mem.oy = w * p3y + DROP_RADIUS
  return [
    [w * p0[0], w * p0[1], w * p1x, w * p1y, w * p2x, w * p2y],
    [w * p3x, w * p3y, w * p4x, w * p4y, w * 0.5, w * p5y],
    [w - w * p4x, w * p4y, w - w * p3x, w * p3y, w - w * p2x, w * p2y],
    [w - w * p1x, w * p1y, w - w * p0[0], w * p0[1], w, 0],
  ]
}

/** buildArrowPath: the ring segment between the trims plus the arrow head, rotated about the origin. */
function arrowPath(ctx, ox, oy, begin, end, rotate, scale) {
  const big = ARROW_RADIUS + ARROW_SIZE / 2
  const small = ARROW_RADIUS - ARROW_SIZE / 2
  const aEnd = Math.max(begin, end)
  const aStart = Math.min(begin, end)
  const pct = Math.min(1, Math.max(0, aEnd - aStart))
  const adjust = (1 - pct) * 2 * Math.PI - Math.PI / 2
  ctx.save()
  ctx.translate(ox, oy)
  ctx.rotate(aEnd * 2 * Math.PI + rotate * 2 * Math.PI)
  ctx.translate(-ox, -oy)
  ctx.beginPath()
  ctx.arc(ox, oy, big, adjust, 3 * Math.PI / 2, false)
  if (scale > 0.3) {
    const cx = ox
    const cy = oy - big + ARROW_SIZE / 2
    ctx.save()
    ctx.translate(cx, cy)
    ctx.scale(scale, scale)
    ctx.translate(-cx, -cy)
    ctx.lineTo(ox, oy - big - ARROW_SIZE)
    ctx.lineTo(ox + 2 * ARROW_SIZE, oy - big + ARROW_SIZE / 2)
    ctx.lineTo(ox, oy - big + 2 * ARROW_SIZE)
    ctx.lineTo(ox, oy - big + ARROW_SIZE)
    ctx.restore()
  }
  ctx.arc(ox, oy, small, 3 * Math.PI / 2, adjust, true)
  ctx.closePath()
  ctx.restore()
}

function shadow(ctx, on) {
  ctx.shadowColor = on ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0)'
  ctx.shadowOffsetX = 0
  ctx.shadowOffsetY = on ? 1 : 0
  ctx.shadowBlur = on ? 3 : 0
}

module.exports = {
  height: CIRCLE * 3,
  primary: '#007aff', // systemBlue
  accent: '#ffffff',
  create() {
    return { oy: 0, startTrim: 0, endTrim: 0, rotation: 0, arrowScale: 0, release: 0, refresh: 0, dropTarget: 0 }
  },
  status(mem, old, now, v) {
    if (now === 'Releasing') {
      if (v.h === 0 || !mem.oy) mem.oy = (v.w * 500) / 1440
      mem.release = v.now
      mem.dropFrom = mem.oy
      mem.circleFrom = (v.w * 500) / 1440
      // The drop falls to maxDropHeight (the width) on iOS, over the list; here it stays inside the header canvas.
      mem.dropTarget = Math.min(v.w, v.expand - DROP_RADIUS * 3 - 6)
    } else if (now === 'Refreshing') {
      mem.refresh = v.now
      mem.beginStart = mem.startTrim
      mem.beginEnd = mem.endTrim
      mem.beginRotation = mem.rotation
      mem.finishing = mem.startTrim !== mem.endTrim
      mem.count = 0
      mem.cycleStart = v.now + (mem.finishing ? ANIMATION_DURATION / 2 : 0)
      if (!mem.finishing) { mem.startTrim = mem.endTrim = mem.rotation = 0; mem.beginStart = mem.beginEnd = mem.beginRotation = 0 }
    } else if (now === 'Idle' || now === 'Pulling') {
      mem.release = 0
      mem.refresh = 0
    }
  },
  draw(ctx, v, mem) {
    const w = v.w
    ctx.fillStyle = v.primary
    if (!mem.release) {
      // Pulling: the wave and the arrow follow the drag.
      const seed = v.h / w
      const first = (seed * (5 - 2 * seed)) / 3.5
      const segs = wavePull(w, first, mem)
      if (segs) {
        shadow(ctx, true)
        ctx.beginPath()
        ctx.moveTo(0, 0)
        segs.forEach((s) => ctx.bezierCurveTo(s[0], s[1], s[2], s[3], s[4], s[5]))
        ctx.fill()
        shadow(ctx, false)
      }
      const percent = v.percent
      const drag = Math.min(1, percent)
      const adjusted = Math.max(drag - 0.4, 0) * 5 / 3
      const sling = percent > 3 ? 2 : percent > 1 ? percent - 1 : 0
      const tension = ((4 - sling) * sling) / 8
      if (percent < 1) {
        mem.startTrim = 0
        mem.arrowScale = Math.min(1, adjusted)
        mem.endTrim = Math.min(adjusted * 0.8, MAX_ARC)
      }
      mem.rotation = (-0.25 + 0.4 * adjusted + tension * 2) * 0.5
      if (percent > 0 && segs && first >= WAVE_FIRST) {
        arrowPath(ctx, Math.floor(w / 2), mem.oy, mem.startTrim, mem.endTrim, mem.rotation, mem.arrowScale)
        ctx.fillStyle = v.accent
        ctx.fill()
        ctx.lineWidth = 0.5
        ctx.strokeStyle = 'rgba(85,85,85,0.5)'
        ctx.stroke()
      }
      return
    }
    const t = v.now - mem.release
    // Wave springing back from 0.1 (startAnimationWaveReverse), bounce interpolator.
    if (t < WAVE_DURATION) {
      const h = Math.min(0.1, MAX_WAVE_HEIGHT) * w * (1 - bounce(t / WAVE_DURATION))
      if (h > 0.008) {
        shadow(ctx, true)
        ctx.beginPath()
        ctx.moveTo(0, 0)
        ctx.quadraticCurveTo(w * 0.25, 0, w * 0.333, h * 0.5)
        ctx.quadraticCurveTo(w * 0.5, h * 1.4, w * 0.666, h * 0.5)
        ctx.quadraticCurveTo(w * 0.75, 0, w, 0)
        ctx.fill()
        shadow(ctx, false)
      }
    }
    // The drop: the circle center moves down, a tangent tail shrinks, then the ellipse bounces.
    const cf = Math.min(1, t / DROP_CIRCLE)
    mem.oy = mem.circleFrom + (mem.dropTarget - mem.circleFrom) * accelDecel(cf)
    const ox = Math.floor(w / 2)
    const oy = mem.oy
    const R = DROP_RADIUS * 3
    const vt = Math.min(1, t / DROP_VERTEX)
    const vertex = t < DROP_VERTEX ? mem.dropFrom * (1 - decelerate(vt)) : 0
    const bv = t > DROP_VERTEX ? dropBounce(Math.min(1, (t - DROP_VERTEX) / DROP_BOUNCE)) : 0
    const bhStart = DROP_VERTEX + DROP_BOUNCE * 0.25
    const bh = t > bhStart ? dropBounce(Math.min(1, (t - bhStart) / DROP_BOUNCE)) : 0
    ctx.fillStyle = v.primary
    shadow(ctx, true)
    ctx.beginPath()
    if (vertex > 0) {
      const arcos = Math.acos(R / (R + vertex))
      ctx.moveTo(ox, oy - R - vertex)
      ctx.arc(ox, oy, R, Math.PI + (Math.PI / 2 - arcos), arcos - Math.PI / 2, true)
      ctx.closePath()
    } else {
      const rw = R * (1 + bv)
      const rh = R * (1 + bh)
      ctx.ellipse(ox, oy, rw, rh, 0, 0, Math.PI * 2)
    }
    ctx.fill()
    shadow(ctx, false)
    // The arrow: the finishing sweep, then Material's progress ring.
    if (v.status === 'Refreshing' && mem.refresh) {
      const now = v.now
      if (mem.finishing && now < mem.cycleStart) {
        const it = (now - mem.refresh) / (ANIMATION_DURATION / 2)
        const target = Math.floor(mem.beginRotation / MAX_ARC) + 1
        mem.startTrim = mem.beginStart + (mem.beginEnd - MIN_ARC - mem.beginStart) * it
        mem.endTrim = mem.beginEnd
        mem.rotation = mem.beginRotation + (target - mem.beginRotation) * it
        arrowPath(ctx, ox, oy, mem.startTrim, mem.endTrim, mem.rotation, mem.arrowScale)
      } else {
        if (mem.finishing) {
          mem.finishing = false
          mem.beginStart = mem.endTrim
          mem.beginEnd = mem.endTrim
          mem.beginRotation = mem.rotation
          mem.startTrim = mem.endTrim
        }
        const elapsed = now - mem.cycleStart
        const cycle = Math.floor(elapsed / ANIMATION_DURATION)
        while (mem.count < cycle) {
          // onAnimationRepeat: keep the trims and rotation, advance the group rotation.
          mem.beginEnd = mem.endTrim
          mem.beginStart = mem.endTrim
          mem.beginRotation = mem.rotation
          mem.startTrim = mem.endTrim
          mem.rot5 = ((mem.rot5 || 0) + 1) % NUM_POINTS
          mem.count++
        }
        const it = (elapsed % ANIMATION_DURATION) / ANIMATION_DURATION
        if (it <= 0.5) mem.startTrim = mem.beginStart + (MAX_ARC - MIN_ARC) * fastOutSlow(it / 0.5)
        if (it > 0.5) mem.endTrim = mem.beginEnd + (MAX_ARC - MIN_ARC) * fastOutSlow((it - 0.5) / 0.5)
        const rotation = mem.beginRotation + 0.25 * it
        const group = (FULL_ROTATION / NUM_POINTS) * it + FULL_ROTATION * ((mem.rot5 || 0) / NUM_POINTS)
        mem.rotation = rotation + group / 360
        arrowPath(ctx, ox, oy, mem.startTrim, mem.endTrim, mem.rotation, 0)
      }
      ctx.fillStyle = v.accent
      ctx.fill()
      ctx.lineWidth = 0.5
      ctx.strokeStyle = 'rgba(85,85,85,0.5)'
      ctx.stroke()
    }
  },
  animating(mem, v) {
    return !!mem.release && v.now - mem.release < DROP_VERTEX + DROP_BOUNCE * 1.25 + 100
  },
}
