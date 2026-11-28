// CYLRefreshMaterialHeader (CYLRefresh styles's UIRefreshMaterialHeader, Android SwipeRefreshLayout's
// MaterialProgressDrawable): a white disc (colorPrimary) slides down over the list with a progress arc + arrow
// that grows with the pull, then spins with trimming arcs, cycling the scheme colors when colorAccent is clear.
// Also the drawing of CYLRefreshMaterialFooter.

const kCircleSize = 40
const kMaxArrowSize = 2
const kMaxArrowRadius = 8
const MAX_PROGRESS_ANGLE = 0.8
const MAX_PROGRESS_ARC = 0.8
const NUM_POINTS = 5
const FULL_ROTATION = 1080
const ANIMATION_DURATION = 1.332
const END_TRIM_START_DELAY_OFFSET = 0.5
const START_TRIM_DURATION_OFFSET = 0.5
const SCHEME = ['#0099cc', '#ff4444', '#669900', '#aa66cc', '#ff8800']
const MIN_PROGRESS_ARC = (kMaxArrowSize / (2 * Math.PI * kMaxArrowRadius)) * Math.PI / 180

/** FAST_OUT_SLOW_IN (cubic-bezier 0.4, 0, 0.2, 1), the curve the iOS lookup table samples. */
function fastOutSlow(x) {
  if (x >= 1) return 1
  if (x <= 0) return 0
  const bx = (t) => 3 * (1 - t) * (1 - t) * t * 0.4 + 3 * (1 - t) * t * t * 0.2 + t * t * t
  const by = (t) => 3 * (1 - t) * t * t + t * t * t
  let lo = 0
  let hi = 1
  for (let i = 0; i < 20; i++) {
    const mid = (lo + hi) / 2
    if (bx(mid) < x) lo = mid
    else hi = mid
  }
  return by((lo + hi) / 2)
}

const isClear = (c) => !c || c === 'transparent' || c === 'clear' || /rgba\([^)]*,\s*0\)$/.test(c)

/** The progress arc with its arrow head (begin / end / rotate in turns; no head when scale <= 0.3). */
function arrowPath(ctx, o, begin, end, rotate, scale) {
  const size = kMaxArrowSize
  const big = kMaxArrowRadius + size / 2
  const small = kMaxArrowRadius - size / 2
  const angleEnd = Math.max(begin, end)
  const angleStart = Math.min(begin, end)
  const anglePercent = Math.min(1, Math.max(0, angleEnd - angleStart))
  const angleAdjust = (1 - anglePercent) * 2 * Math.PI - Math.PI / 2
  ctx.save()
  ctx.translate(o.x, o.y)
  ctx.rotate(angleEnd * 2 * Math.PI + rotate * 2 * Math.PI)
  ctx.beginPath()
  ctx.arc(0, 0, big, angleAdjust, 1.5 * Math.PI, false)
  if (scale > 0.3) {
    const cy = -big + size / 2
    const pt = (x, y) => ctx.lineTo(x * scale, cy + (y - cy) * scale)
    pt(0, -big - size)
    pt(2 * size, -big + size / 2)
    pt(0, -big + 2 * size)
    pt(0, -big + size)
  }
  ctx.arc(0, 0, small, 1.5 * Math.PI, angleAdjust, true)
  ctx.closePath()
  ctx.restore()
}

module.exports = {
  height: kCircleSize * 2,
  primary: '#ffffff',
  accent: 'transparent',
  stretch: false,
  create() {
    return { color: 0, phase: '', start: 0, startTrim: 0, endTrim: 0, rotation: 0, arrowScale: 0,
      bStart: 0, bEnd: 0, bRot: 0, count: 0 }
  },
  status(m, old, now, v) {
    if (now === 'Refreshing') {
      // onStartAnimationWhenRefreshing: next color, then trim the pulled arc (finishing) or spin directly.
      if (isClear(v.accent)) m.color = (m.color + 1) % SCHEME.length
      m.count = 0
      m.bStart = m.startTrim; m.bEnd = m.endTrim; m.bRot = m.rotation
      if (m.startTrim !== m.endTrim) { m.phase = 'finishing'; m.start = v.now }
      else { m.startTrim = m.endTrim = m.rotation = 0; m.bStart = m.bEnd = m.bRot = 0; m.phase = 'spin'; m.start = v.now }
    } else if (now === 'Idle' || now === 'Pulling' || now === 'Release') {
      if (old === 'Finishing' || old === 'Refreshing') {
        m.phase = ''; m.color = 0; m.startTrim = m.endTrim = m.rotation = 0
      }
    }
  },
  draw(ctx, v, m) {
    const radius = kCircleSize / 2
    let o
    let begin
    let end
    let rotate
    let scale
    let p = 1
    if (v.status === 'Refreshing') {
      o = { x: v.w / 2, y: v.expand / 2 }
      if (m.phase === 'finishing') {
        const t = Math.min(1, (v.now - m.start) / (ANIMATION_DURATION * 500))
        const target = Math.floor(m.bRot / MAX_PROGRESS_ARC) + 1
        m.startTrim = m.bStart + (m.bEnd - MIN_PROGRESS_ARC - m.bStart) * t
        m.endTrim = m.bEnd
        m.rotation = m.bRot + (target - m.bRot) * t
        begin = m.startTrim; end = m.bEnd; rotate = m.rotation; scale = m.arrowScale
        if (t >= 1) {
          if (isClear(v.accent)) m.color = (m.color + 1) % SCHEME.length
          m.bStart = m.startTrim; m.bEnd = m.endTrim; m.bRot = m.rotation
          m.startTrim = m.endTrim
          m.phase = 'spin'; m.start = v.now
        }
      } else {
        let t = (v.now - m.start) / (ANIMATION_DURATION * 1000)
        while (t >= 1) {
          // onAnimationRepeat: next color, keep the arc, next fifth of the rotation.
          if (isClear(v.accent)) m.color = (m.color + 1) % SCHEME.length
          m.bStart = m.startTrim; m.bEnd = m.endTrim; m.bRot = m.rotation
          m.startTrim = m.endTrim
          m.count = (m.count + 1) % NUM_POINTS
          m.start += ANIMATION_DURATION * 1000
          t -= 1
        }
        if (t <= START_TRIM_DURATION_OFFSET) {
          m.startTrim = m.bStart + (MAX_PROGRESS_ARC - MIN_PROGRESS_ARC) * fastOutSlow(t / (1 - START_TRIM_DURATION_OFFSET))
        }
        if (t > END_TRIM_START_DELAY_OFFSET) {
          m.endTrim = m.bEnd + (MAX_PROGRESS_ARC - MIN_PROGRESS_ARC) *
            fastOutSlow((t - START_TRIM_DURATION_OFFSET) / (1 - START_TRIM_DURATION_OFFSET))
        }
        const group = (FULL_ROTATION / NUM_POINTS) * t + FULL_ROTATION * (m.count / NUM_POINTS)
        m.rotation = m.bRot + 0.25 * t + group / 360
        begin = m.startTrim; end = m.endTrim; rotate = m.rotation; scale = 0
      }
    } else {
      const offset = v.h
      let distance = Math.max(0, (offset - kCircleSize) / 2)
      distance = kCircleSize * 3 * (1 - Math.pow(8, -distance / (kCircleSize * 6)))
      p = Math.min(distance / kCircleSize, 1)
      o = distance === 0 ? { x: Math.floor(v.w / 2), y: offset - radius } : { x: Math.floor(v.w / 2), y: radius + distance }
      const extra = Math.abs(offset) - v.expand
      const sling = Math.max(0, Math.min(extra, v.expand * 2) / v.expand)
      const tension = (sling / 4 - Math.pow(sling / 4, 2)) * 2
      const strokeEnd = Math.min(MAX_PROGRESS_ANGLE, p * 0.8)
      m.startTrim = 0; m.endTrim = strokeEnd; m.arrowScale = Math.min(1, p)
      m.rotation = (0.4 * p + tension * 2) * 0.5
      begin = 0; end = strokeEnd; rotate = m.rotation; scale = m.arrowScale
    }
    // Disc with its shadow, the highlight, then the arrow.
    ctx.beginPath()
    ctx.arc(o.x, o.y, radius, 0, Math.PI * 2)
    ctx.fillStyle = v.primary
    ctx.shadowColor = 'rgba(0,0,0,0.3)'
    ctx.shadowOffsetY = 1
    ctx.shadowBlur = 3
    ctx.fill()
    ctx.shadowColor = 'transparent'
    ctx.shadowOffsetY = 0
    ctx.shadowBlur = 0
    ctx.beginPath()
    ctx.arc(o.x, o.y, radius, 0, Math.PI, true)
    ctx.arc(o.x, o.y + 1.25, radius, Math.PI, 0, false)
    ctx.fillStyle = 'rgba(255,255,255,0.2)'
    ctx.fill()
    if (p > 0) {
      arrowPath(ctx, o, begin, end, rotate, scale)
      ctx.fillStyle = isClear(v.accent) ? SCHEME[m.color] : v.accent
      ctx.fill()
      ctx.lineWidth = 0.5
      ctx.strokeStyle = 'rgba(85,85,85,0.5)'
      ctx.stroke()
    }
  },
}
