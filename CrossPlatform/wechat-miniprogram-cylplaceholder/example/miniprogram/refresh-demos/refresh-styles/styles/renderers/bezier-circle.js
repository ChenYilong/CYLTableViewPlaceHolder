// CYLRefreshBezierCircleHeader (CYLRefresh styles's UIRefreshBezierCircleHeader): a Bezier wave that springs
// back on release and throws up a ball; the ball settles in the middle with a tail, and an arc spins around it
// while refreshing.
const { Animator, ease } = require('../util')

const DURATION = 0.25 // durationNormal
const TARGET_DEGREE = 270
const STROKE = 2

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
    waveHeight: 0, wavePulling: false, bollRadius: 0, bollY: 0, springRatio: 0,
    animatorSpeed: 0, animatorHeight: 0, animatorSpringRatio: 0, animatorSpringBollY: 0, animatorStatus: 0,
    showOuter: false, showBoll: false, showBollTail: false, outerIsStart: true,
    refreshStart: 90, refreshStop: 90, rebound: null, points: null, spinning: false,
  }
}

function startRefreshing(mem) {
  mem.showOuter = true
  mem.showBollTail = false
  mem.outerIsStart = true
  mem.refreshStart = 90
  mem.refreshStop = 90
  mem.spinning = true
}

function status(mem, old, now, v) {
  const expand = v.expand
  if (now === 'Releasing') {
    // onStartAnimationWhenRealeasing.
    mem.wavePulling = false
    mem.bollRadius = expand / 6
    mem.animatorSpeed = 0
    mem.animatorStatus = 0
    mem.animatorSpringRatio = 0
    mem.springRatio = 0
    // The mini program cannot pull past the open height: a release after a pull gets a small wave to spring
    // back from; beginRefreshing in code goes straight to the refreshing ball, as on iOS (dragOffset == 0).
    if (old === 'Release' && mem.waveHeight <= 0) mem.waveHeight = 0.3 * expand
    mem.animatorHeight = Math.min(mem.waveHeight * 0.8, expand / 2)
    if (old !== 'Release' || mem.animatorHeight <= 0) {
      mem.showBoll = true
      startRefreshing(mem)
      mem.bollY = expand / 2
      mem.waveHeight = 0
      return
    }
    const wh = mem.waveHeight
    mem.points = [wh, 0, -mem.animatorHeight, 0, -mem.animatorHeight * 0.4, 0]
    mem.rebound = new Animator({ duration: DURATION * 4, interpolator: ease.decelerate, now: v.now })
  } else if (now === 'Idle' || now === 'Pulling') {
    // onRefreshFinished / back to idle (the finish animation is not visible: the header hides when it ends).
    Object.assign(mem, create())
  }
}

function step(mem, v) {
  const head = v.expand
  if (mem.rebound) {
    const p = mem.rebound.progress(v.now)
    const t = mem.rebound.interpolator(p.t)
    const cur = p.done ? 0 : fromPoints(mem.points, t)
    if (mem.animatorStatus === 0 && cur <= 0) {
      mem.animatorStatus = 1
      mem.animatorSpeed = Math.abs(cur - mem.waveHeight)
    }
    if (mem.animatorStatus === 1) {
      mem.animatorSpringRatio = -cur / mem.animatorHeight
      if (mem.animatorSpringRatio >= mem.springRatio) {
        mem.springRatio = mem.animatorSpringRatio
        mem.bollY = head + cur
        mem.animatorSpeed = Math.abs(cur - mem.waveHeight)
      } else {
        mem.animatorStatus = 2
        mem.springRatio = 0
        mem.showBoll = true
        mem.showBollTail = true
        mem.animatorSpringBollY = mem.bollY
      }
    }
    if (mem.animatorStatus === 2 && mem.bollY > head / 2) {
      mem.bollY = Math.max(head / 2, mem.bollY - mem.animatorSpeed)
      const bally = p.t * (head / 2 - mem.animatorSpringBollY) + mem.animatorSpringBollY
      if (mem.bollY > bally) mem.bollY = bally
    }
    if (mem.showBollTail && cur < mem.waveHeight) startRefreshing(mem)
    if (!mem.wavePulling) mem.waveHeight = cur
    if (p.done) {
      mem.rebound = null
      if (!mem.showBoll) { mem.showBoll = true; mem.bollY = head / 2; startRefreshing(mem) }
    }
  }
  if (mem.spinning) {
    // One onAnimation: per display frame on iOS: scale the steps by the frame time.
    const k = Math.max(1, Math.round(v.dt * 60))
    for (let i = 0; i < k; i++) {
      mem.refreshStart = (mem.refreshStart + (mem.outerIsStart ? 3 : 10)) % 360
      mem.refreshStop = (mem.refreshStop + (mem.outerIsStart ? 10 : 3)) % 360
      let swipe = mem.refreshStop - mem.refreshStart
      if (swipe < 0) swipe += 360
      if (swipe >= TARGET_DEGREE) mem.outerIsStart = false
      else if (swipe <= 10) mem.outerIsStart = true
    }
  }
}

function circle(ctx, x, y, r) {
  ctx.beginPath()
  ctx.arc(x, y, Math.max(0, r), 0, Math.PI * 2)
  ctx.fill()
}

function drawWave(ctx, w, h, mem, v) {
  ctx.fillStyle = v.primary
  const base = Math.min(v.expand, h)
  if (mem.waveHeight !== 0) {
    ctx.beginPath()
    ctx.moveTo(0, 0)
    ctx.lineTo(w, 0)
    ctx.lineTo(w, base)
    ctx.quadraticCurveTo(w / 2, base + mem.waveHeight * 2, 0, base)
    ctx.closePath()
    ctx.fill()
  } else {
    ctx.fillRect(0, 0, w, base)
  }
}

function drawSpringUp(ctx, w, mem, accent) {
  if (mem.springRatio <= 0) return
  ctx.fillStyle = accent
  const r = mem.bollRadius
  const leftX = w / 2 - 4 * r + mem.springRatio * 3 * r
  if (mem.springRatio < 0.9) {
    ctx.beginPath()
    ctx.moveTo(leftX, mem.bollY)
    ctx.quadraticCurveTo(w / 2, mem.bollY - r * mem.springRatio * 2, w - leftX, mem.bollY)
    ctx.closePath()
    ctx.fill()
  } else {
    circle(ctx, w / 2, mem.bollY, r)
  }
}

function drawBollTail(ctx, w, mem, v, fraction) {
  if (!mem.showBollTail) return
  const r = mem.bollRadius
  const bottom = v.expand + mem.waveHeight
  const startY = mem.bollY + (r * fraction) / 2
  const startX = w / 2 + Math.sqrt(Math.max(0, r * r * (1 - (fraction * fraction) / 4)))
  const b1x = w / 2 + ((r * 3) / 4) * (1 - fraction)
  const b2x = b1x + r
  ctx.fillStyle = v.accent
  ctx.beginPath()
  ctx.moveTo(startX, startY)
  ctx.quadraticCurveTo(b1x, bottom, b2x, bottom)
  ctx.lineTo(w - b2x, bottom)
  ctx.quadraticCurveTo(w - b1x, bottom, w - startX, startY)
  ctx.closePath()
  ctx.fill()
}

function drawBoll(ctx, w, mem, v) {
  if (!mem.showBoll) return
  ctx.fillStyle = v.accent
  circle(ctx, w / 2, mem.bollY, mem.bollRadius)
  drawBollTail(ctx, w, mem, v, (v.expand + mem.waveHeight) / v.expand)
}

function drawOuter(ctx, w, mem, accent) {
  if (!mem.showOuter) return
  ctx.strokeStyle = accent
  ctx.lineWidth = STROKE
  ctx.beginPath()
  ctx.arc(w / 2, mem.bollY, mem.bollRadius + STROKE * 2, (mem.refreshStart * Math.PI) / 180, (mem.refreshStop * Math.PI) / 180)
  ctx.stroke()
}

function draw(ctx, v, mem) {
  if (v.status === 'Pulling' || v.status === 'Release') {
    mem.wavePulling = true
    mem.waveHeight = 0.8 * Math.max(0, v.h - v.expand)
  }
  step(mem, v)
  drawWave(ctx, v.w, v.h, mem, v)
  drawSpringUp(ctx, v.w, mem, v.accent)
  drawBoll(ctx, v.w, mem, v)
  drawOuter(ctx, v.w, mem, v.accent)
}

function animating(mem) {
  return !!mem.rebound
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
