// CYLRefreshOriginalHeader (SmartRefreshControl's UIRefreshOriginalHeader): the classic iOS 6 "rubber drop" that
// stretches while pulling, shrinks into a dot on release and gives way to a gray activity indicator.
const { alpha } = require('../util')

const kMinTopPadding = 9
const kMaxTopPadding = 5
const kMinTopRadius = 12.5
const kMaxTopRadius = 16
const kMinBottomRadius = 3
const kMaxBottomRadius = 16
const kMinBottomPadding = 4
const kMaxBottomPadding = 6
const kMinArrowSize = 2
const kMaxArrowSize = 3
const kMinArrowRadius = 5
const kMaxArrowRadius = 7
const kMaxDistance = 53

const lerp = (a, b, p) => a + (b - a) * p
const easeOut = (t) => 1 - (1 - t) * (1 - t)

/** The drop: top half circle, curves down to the bottom half circle and back. */
function dropPath(ctx, top, rt, bottom, rb) {
  ctx.beginPath()
  ctx.arc(top.x, top.y, rt, 0, Math.PI, true)
  ctx.bezierCurveTo(
    lerp(top.x - rt, bottom.x - rb, 0.1), lerp(top.y, bottom.y, 0.2),
    lerp(top.x - rt, bottom.x - rb, 0.9), lerp(top.y, bottom.y, 0.2),
    bottom.x - rb, bottom.y)
  ctx.arc(bottom.x, bottom.y, rb, Math.PI, 0, true)
  ctx.bezierCurveTo(
    lerp(top.x + rt, bottom.x + rb, 0.9), lerp(top.y, bottom.y, 0.2),
    lerp(top.x + rt, bottom.x + rb, 0.1), lerp(top.y, bottom.y, 0.2),
    top.x + rt, top.y)
  ctx.closePath()
}

/** The circular arrow inside the top circle (even-odd fill) and the highlight. */
function drawArrow(ctx, top, rt, p, accent, a) {
  const size = lerp(kMinArrowSize, kMaxArrowSize, p)
  const radius = lerp(kMinArrowRadius, kMaxArrowRadius, p)
  const big = radius + size / 2
  const small = radius - size / 2
  ctx.globalAlpha = a
  ctx.beginPath()
  ctx.arc(top.x, top.y, big, 0, 1.5 * Math.PI, false)
  ctx.lineTo(top.x, top.y - big - size)
  ctx.lineTo(top.x + 2 * size, top.y - big + size / 2)
  ctx.lineTo(top.x, top.y - big + 2 * size)
  ctx.lineTo(top.x, top.y - big + size)
  ctx.arc(top.x, top.y, small, 1.5 * Math.PI, 0, true)
  ctx.closePath()
  ctx.fillStyle = accent
  ctx.fill('evenodd')
  ctx.lineWidth = 0.5
  ctx.strokeStyle = 'rgba(85,85,85,0.5)'
  ctx.stroke()
  ctx.beginPath()
  ctx.arc(top.x, top.y, rt, 0, Math.PI, true)
  ctx.arc(top.x, top.y + 1.25, rt, Math.PI, 0, false)
  ctx.fillStyle = 'rgba(255,255,255,0.2)'
  ctx.fill()
  ctx.globalAlpha = 1
}

/** UIActivityIndicatorViewStyleGray: 12 fading spokes, one turn per second. */
function drawActivity(ctx, x, y, now) {
  const step = Math.floor((now / 1000) * 12) % 12
  ctx.save()
  ctx.translate(x, y)
  ctx.lineCap = 'round'
  ctx.lineWidth = 2
  for (let i = 0; i < 12; i++) {
    const age = (step - i + 12) % 12
    ctx.strokeStyle = alpha('#7f7f7f', 1 - age / 13)
    const a = (i / 12) * Math.PI * 2 - Math.PI / 2
    ctx.beginPath()
    ctx.moveTo(Math.cos(a) * 5, Math.sin(a) * 5)
    ctx.lineTo(Math.cos(a) * 9, Math.sin(a) * 9)
    ctx.stroke()
  }
  ctx.restore()
}

module.exports = {
  height: kMaxTopRadius * 4,
  primary: 'rgb(155,162,172)',
  accent: '#ffffff',
  stretch: true,
  create() {
    return { top: null, releaseAt: 0 }
  },
  status(mem, old, now, v) {
    if (now === 'Releasing') mem.releaseAt = v.now
    if (now === 'Idle') mem.releaseAt = 0
  },
  animating(mem, v) {
    return mem.releaseAt > 0 && v.now - mem.releaseAt < 300
  },
  draw(ctx, v, mem) {
    const shadow = (on) => {
      ctx.shadowColor = on ? 'rgba(0,0,0,0.4)' : 'transparent'
      ctx.shadowOffsetX = 0
      ctx.shadowOffsetY = on ? 1 : 0
      ctx.shadowBlur = on ? 0.5 : 0
    }
    if (v.status === 'Refreshing') {
      // The drop shrinks into a dot (0.15 s, ease out) and fades; the indicator starts 0.15 s after release.
      const t = mem.releaseAt ? (v.now - mem.releaseAt) / 1000 : 1
      const top = mem.top || { x: Math.floor(v.w / 2), y: kMaxTopPadding + kMaxTopRadius }
      if (t < 0.2) {
        const r = lerp(kMaxTopRadius, lerp(kMinBottomRadius, kMaxBottomRadius, 0.2), easeOut(Math.min(1, t / 0.15)))
        ctx.globalAlpha = t < 0.1 ? 1 : Math.max(0, 1 - (t - 0.1) / 0.1)
        ctx.beginPath()
        ctx.arc(top.x, top.y, r, 0, Math.PI * 2)
        ctx.fillStyle = v.primary
        shadow(true)
        ctx.fill()
        shadow(false)
        ctx.globalAlpha = 1
      }
      if (t >= 0.15) drawActivity(ctx, v.w / 2, v.expand / 2, v.now)
      return
    }
    const offset = v.h
    const shift = Math.max(0, offset - (kMaxTopRadius + kMaxBottomRadius + kMaxTopPadding + kMaxBottomPadding))
    const distance = Math.min(kMaxDistance, Math.abs(shift))
    const p = 1 - distance / kMaxDistance
    const topPad = lerp(kMinTopPadding, kMaxTopPadding, p)
    const rt = lerp(kMinTopRadius, kMaxTopRadius, p)
    const rb = lerp(kMinBottomRadius, kMaxBottomRadius, p)
    const bottomPad = lerp(kMinBottomPadding, kMaxBottomPadding, p)
    const x = Math.floor(v.w / 2)
    let bottom = { x, y: offset - bottomPad - rb }
    let top
    if (distance === 0) {
      top = { x, y: bottom.y }
    } else {
      top = { x, y: topPad + rt }
      bottom = { x, y: top.y + distance }
    }
    mem.top = top
    dropPath(ctx, top, rt, bottom, rb)
    ctx.fillStyle = v.primary
    shadow(true)
    ctx.fill()
    shadow(false)
    ctx.lineWidth = 0.5
    ctx.strokeStyle = 'rgba(85,85,85,0.5)'
    ctx.stroke()
    drawArrow(ctx, top, rt, p, v.accent, 1)
  },
}
