// CYLRefreshBezierRadarHeader (SmartRefreshControl's UIRefreshBezierRadarHeader): a Bezier wave with seven dots
// while pulling; on release the wave springs back, the dots fade, a radar grows and sweeps until the end, then a
// ripple of colorAccent fills the header. Also drawn by CYLRefreshBezierRadarFooter.
const { alpha, Animator, ease } = require('../util')

const DURATION = 0.25 // durationNormal
const DOT_RADIUS = 7
const RADAR_RADIUS = 20
const RADAR_CIRCLE = 7
const FINISH_DURATION = 0.3

/** CYLRefreshValueAnimator's setFromToPoints: piecewise linear over the interpolated time. */
function fromPoints(points, t) {
  const count = points.length
  for (let i = 0; i < count - 1; i++) {
    const start = i / count
    const end = (i + 1) / count
    if (t >= start && t < end) return points[i] + (points[i + 1] - points[i]) * ((t - start) / (end - start))
  }
  return points[0]
}

function create() {
  return {
    waveTop: 0, waveHeight: 0, wavePulling: false, dotFraction: 0, dotAlpha: 1,
    radarScale: 0, radarAngle: 0, rippleRadius: 0,
    aDot: null, aScale: null, aRadar: null, aWave: null, wavePoints: null, aRipple: null,
  }
}

function status(mem, old, now, v) {
  if (now === 'Releasing') {
    mem.wavePulling = false
    mem.waveTop = v.expand
    // The mini program cannot pull past the open height, so give the spring back a wave of its own.
    if (old === 'Release' && mem.waveHeight <= 0) mem.waveHeight = 0.25 * v.expand
    mem.aDot = new Animator({ from: 1, to: 0, duration: DURATION, interpolator: ease.decelerate, now: v.now })
    const wh = mem.waveHeight
    mem.wavePoints = [wh, 0, wh * -0.5, 0, wh * -0.2, 0]
    mem.aWave = new Animator({ duration: DURATION * 3.6, interpolator: ease.decelerate, now: v.now })
  } else if (old === 'Finishing' || (old === 'Refreshing' && now !== 'Refreshing')) {
    const w = v.w
    const h = v.h
    mem.aRipple = new Animator({ from: RADAR_RADIUS, to: Math.sqrt(w * w + h * h), duration: FINISH_DURATION, interpolator: ease.accelerate, now: v.now })
    reset(mem)
  } else if (now === 'Pulling' || now === 'Idle') {
    reset(mem)
  }
}

function reset(mem) {
  mem.dotAlpha = 1
  mem.radarScale = 0
  mem.rippleRadius = 0
  mem.waveHeight = 0
  mem.aDot = mem.aScale = mem.aRadar = mem.aWave = null
}

/** The animators and their chain: dot alpha → radar scale → radar sweep (for ever). */
function step(mem, v) {
  const now = v.now
  if (mem.aDot) {
    mem.dotAlpha = mem.aDot.value(now)
    if (mem.aDot.done(now)) {
      mem.dotAlpha = 0
      mem.aDot = null
      mem.aScale = new Animator({ from: 0, to: 1, duration: DURATION, interpolator: ease.decelerate, now })
    }
  }
  if (mem.aScale) {
    mem.radarScale = mem.aScale.value(now)
    if (mem.aScale.done(now)) {
      mem.radarScale = 1
      mem.aScale = null
      mem.aRadar = new Animator({ from: 0, to: 360, duration: DURATION * 3, repeat: Infinity, interpolator: ease.accelerateDecelerate, now })
    }
  }
  if (mem.aRadar) mem.radarAngle = mem.aRadar.value(now)
  if (mem.aWave) {
    if (mem.wavePulling) mem.aWave = null
    else {
      const p = mem.aWave.progress(now)
      mem.waveHeight = p.done ? 0 : fromPoints(mem.wavePoints, mem.aWave.interpolator(p.t))
      if (p.done) mem.aWave = null
    }
  }
  if (mem.aRipple) {
    mem.rippleRadius = mem.aRipple.value(now)
    // Retracted after the ripple: back to the idle drawing (the status goes Idle on iOS).
    if (mem.aRipple.done(now)) { mem.aRipple = null; mem.rippleRadius = 0 }
  }
}

function drawWave(ctx, w, mem, primary) {
  ctx.fillStyle = primary
  ctx.beginPath()
  ctx.moveTo(0, 0)
  ctx.lineTo(0, mem.waveTop)
  ctx.quadraticCurveTo(w / 2, mem.waveTop + mem.waveHeight, w, mem.waveTop)
  ctx.lineTo(w, 0)
  ctx.closePath()
  ctx.fill()
}

function drawDot(ctx, w, h, mem, accent) {
  if (mem.dotAlpha <= 0) return
  const num = 7
  const x = h
  const f = mem.dotFraction
  const wide = (w / num) * f - (f > 1 ? ((f - 1) * (w / num)) / f : 0)
  const high = h - (f > 1 ? ((f - 1) * h) / 2 / f : 0)
  for (let i = 0; i < num; i++) {
    const index = 1 + i - (1 + num) / 2
    const alphaX = 255 * (1 - 2 * (Math.abs(index) / num))
    const alphaY = mem.dotAlpha * alphaX * (1 - 1 / Math.pow(x / 800 + 1, 15))
    ctx.fillStyle = alpha(accent, alphaY / 255)
    const radius = DOT_RADIUS * (1 - 1 / (x / 10 + 1))
    ctx.beginPath()
    ctx.arc(w / 2 - radius / 2 + wide * index, high / 2, Math.max(0, radius), 0, Math.PI * 2)
    ctx.fill()
  }
}

function drawRadar(ctx, w, h, mem, v) {
  if (v.status !== 'Refreshing') return
  const radius = RADAR_RADIUS * mem.radarScale
  const circle = RADAR_CIRCLE * mem.radarScale
  const cx = w / 2
  const cy = h / 2
  ctx.fillStyle = v.accent
  ctx.strokeStyle = v.accent
  ctx.lineWidth = 3
  ctx.beginPath()
  ctx.arc(cx, cy, radius, 0, Math.PI * 2)
  ctx.fill()
  ctx.beginPath()
  ctx.arc(cx, cy, radius + circle, 0, Math.PI * 2)
  ctx.stroke()
  // The sweep, from 12 o'clock clockwise to the radar angle (as CGContextAddArc with clockwise = 0 in UIKit).
  const end = (mem.radarAngle * Math.PI) / 180
  ctx.fillStyle = alpha(v.primary, 0.33)
  ctx.strokeStyle = alpha(v.primary, 0.33)
  ctx.beginPath()
  ctx.moveTo(cx, cy)
  ctx.arc(cx, cy, radius, (3 * Math.PI) / 2, end)
  ctx.closePath()
  ctx.fill()
  ctx.beginPath()
  ctx.arc(cx, cy, radius + circle, (3 * Math.PI) / 2, end)
  ctx.stroke()
}

function drawRipple(ctx, w, h, mem, accent) {
  if (mem.rippleRadius <= 0) return
  ctx.fillStyle = accent
  ctx.beginPath()
  ctx.arc(w / 2, h / 2, mem.rippleRadius, 0, Math.PI * 2)
  ctx.fill()
}

function draw(ctx, v, mem) {
  // scrollView:didScroll: while dragging.
  if (v.status === 'Pulling' || v.status === 'Release' || (v.status === 'Idle' && v.part === 'header')) {
    mem.wavePulling = true
    mem.waveTop = Math.min(v.expand, v.h)
    mem.waveHeight = 1.9 * Math.max(0, v.h - v.expand)
    mem.dotFraction = v.percent
  } else if (v.part === 'footer' && v.status === 'Idle') {
    mem.waveTop = v.expand
    mem.dotFraction = 1
  }
  step(mem, v)
  drawWave(ctx, v.w, mem, v.primary)
  drawDot(ctx, v.w, v.h, mem, v.accent)
  drawRadar(ctx, v.w, v.h, mem, v)
  drawRipple(ctx, v.w, v.h, mem, v.accent)
}

function animating(mem) {
  return !!(mem.aDot || mem.aScale || mem.aWave || mem.aRipple)
}

module.exports = {
  height: 100,
  primary: '#1199ff',
  accent: '#ffffff',
  stretch: true,
  create,
  status,
  draw,
  animating,
}
