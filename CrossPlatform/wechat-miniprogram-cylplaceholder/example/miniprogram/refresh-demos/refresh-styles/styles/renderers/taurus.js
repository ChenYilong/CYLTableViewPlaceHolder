// CYLRefreshTaurusHeader (CYLRefresh styles's UIRefreshTaurusHeader, MIT): an airplane flying between clouds,
// with wind lines while refreshing. Paths, colors, constants and the four-part loading motion from the iOS port.
const { VectorImage } = require('../vector')
const { Animator, ease } = require('../util')

const P = {
  "PATH_AIRPLANE": "m23 81c0 0 0 -1 0 -1 0 -0.5 0 -1 1.5 -1 2 -1 2.6 -2 2 -2.5 -0.5 -1 -2 -1 -11.6 -2.5 -5 -1 -10 -1 -11 -1.5l-1 0 1 -1c1 -1 1 -1 2 -1 0.6 0 6 0 13 1 6 0 12 1 12.6 0.6l1 0 -1 -2C30 67 16 42 15 40.6l-0.5 -1 4 -1c2 -0.6 4 -1 4 -1 0 0 6 4 13 8.5 14.6 10 17 11 20 12 4.6 2 6 1.6 13 -0.6 13 -5 25 -9 26 -9 0.6 0 3.6 1 -24 -14L51 23 47 16 43 10 43.6 9c1 -1 1 -1 1 -0.5 0 0 4 3 7.5 6 4 3 7 6 7.5 6 0 0 13.6 3 29.5 6 16 3 32 6 35 7l6 1 3 -1c41.6 -14.6 68 -23 85 -28 15 -4 24 -5 32 -2.5 7 2 10 5 8 8 -1.6 2.5 -4.6 4.6 -10.6 7.5 -6 3 -10 4 -25 9 -8 2.6 -16.6 6 -39 14 -67 25 -88 31 -121.6 36 -14.5 2 -24 3 -34 3 -5 0 -5.5 0 -6 -0.5z",
  "PATH_CLOUD_1": "M552 1A65 65 0 0 0 504 22A51 51 0 0 0 492 20A51 51 0 0 0 442 71A51 51 0 0 0 492 121A51 51 0 0 0 511 118A65 65 0 0 0 517 122L586 122A65 65 0 0 0 600 111A60 60 0 0 0 608 122L696 122A60 60 0 0 0 712 82A60 60 0 0 0 652 22A60 60 0 0 0 611 39A65 65 0 0 0 552 1zM246 2A55 55 0 0 0 195 37A47 47 0 0 0 168 28A47 47 0 0 0 121 75A47 47 0 0 0 168 121A47 47 0 0 0 209 97A55 55 0 0 0 246 111A55 55 0 0 0 269 107A39 39 0 0 0 281 122L328 122A39 39 0 0 0 343 91A39 39 0 0 0 304 52A39 39 0 0 0 301 52A55 55 0 0 0 246 2z",
  "PATH_CLOUD_2": "m507 31a53 53 0 0 0 -53 53 53 53 0 0 0 16 38h75a53 53 0 0 0 2 -2 28 28 0 0 0 1 2h213a97 97 0 0 0 -87 -54.8 97 97 0 0 0 -73 34 28 28 0 0 0 -27 -19 28 28 0 0 0 -13 3 53 53 0 0 0 0 -1 53 53 0 0 0 -53 -53zM206 32a54 54 0 0 0 -50 34 74.9 74.9 0 0 0 -47 -17 74.9 74.9 0 0 0 -74 61 31 31 0 0 0 -10 -2 31 31 0 0 0 -26 14L301 122a38 38 0 0 0 0 -4 38 38 0 0 0 -38 -38 38 38 0 0 0 -4 0 54 54 0 0 0 -54 -49z",
  "PATH_CLOUD_3": "m424 37a53 53 0 0 0 -41 19 53 53 0 0 0 -1 2 63 63 0 0 0 -5 0 63 63 0 0 0 -61 50 63 63 0 0 0 -1 4 16 16 0 0 0 -10 -4 16 16 0 0 0 -8 2 21 21 0 0 0 -18 -11 21 21 0 0 0 -19 13 22 22 0 0 0 -7 -1 22 22 0 0 0 -19 11L523 122a44 44 0 0 0 -43 -37 44 44 0 0 0 -3 0 53 53 0 0 0 -53 -48zM129 38a50 50 0 0 0 -50 50 50 50 0 0 0 2 15 15 16 0 0 0 -6 2 15 16 0 0 0 -1 1 17 16 0 0 0 -12 -5 17 16 0 0 0 -16 14 20 16 0 0 0 -15 7L224 122a43 43 0 0 0 1 -10 43 43 0 0 0 -43 -43 43 43 0 0 0 -7 1 50 50 0 0 0 -47 -32zM632 83a64 64 0 0 0 -45 18 27 27 0 0 0 -11 -2 27 27 0 0 0 -23 13 17 17 0 0 0 -7 -1 17 17 0 0 0 -16 12h160a64 64 0 0 0 -59 -39z"
}
const SCALE_START_PERCENT = 0.5
const ANIMATION_DURATION = 1000
const SIDE_CLOUDS_INITIAL_SCALE = 0.6
const SIDE_CLOUDS_FINAL_SCALE = 1
const CENTER_CLOUDS_INITIAL_SCALE = 0.8
const CENTER_CLOUDS_FINAL_SCALE = 1
const LOADING_ANIMATION_COEFFICIENT = 80
const SLOW_DOWN_ANIMATION_COEFFICIENT = 6
const WIND_SET_AMOUNT = 10
const Y_SIDE_CLOUDS_SLOW_DOWN_COF = 4
const X_SIDE_CLOUDS_SLOW_DOWN_COF = 2
const MIN_WIND_LINE_WIDTH = 50
const MAX_WIND_LINE_WIDTH = 300
const MIN_WIND_X_OFFSET = 1000
const MAX_WIND_X_OFFSET = 2000
const RANDOM_Y_COEFFICIENT = 5
const FINISH_DURATION = 0.3

const random = (min, max) => min + Math.floor(Math.random() * (max - min + 1))

function create() {
  const cloud = new VectorImage([P.PATH_CLOUD_1, P.PATH_CLOUD_2, P.PATH_CLOUD_3],
    ['rgba(199,220,241,0.667)', 'rgba(232,243,253,0.867)', 'rgba(253,253,253,1)'])
  cloud.setSize(260, 45)
  const airplane = new VectorImage([P.PATH_AIRPLANE], ['#ffffff'])
  airplane.setSize(65, 20)
  return {
    cloud, airplane, refreshing: null, finish: null, loading: 0, finishTime: 0, lastTime: 0,
    windLineWidth: 0, newWindSet: false, inverse: false, winds: [],
  }
}

function status(m, old, now, v) {
  if (old === 'Refreshing' || old === 'Finishing') {
    m.finish = new Animator({ duration: FINISH_DURATION, mode: 'reverse', interpolator: ease.accelerateDecelerate, now: v.now })
  } else if (now === 'Refreshing') {
    m.loading = 0
    m.refreshing = new Animator({ duration: ANIMATION_DURATION / 1000, repeat: Infinity, mode: 'reverse', interpolator: ease.accelerateDecelerate, now: v.now })
  }
}

// getAnimationTimePart / getAnimationPartValue / checkCurrentAnimationPart (parts 1–4).
const timePart = (part) => (part === 2 ? LOADING_ANIMATION_COEFFICIENT / 2 : part === 4 ? LOADING_ANIMATION_COEFFICIENT / 4 : part === 3 ? 3 * (LOADING_ANIMATION_COEFFICIENT / 4) : 0)
function partValue(m, part) {
  const t = m.loading
  if (part === 1) return t
  if (part === 2) return -t
  if (part === 3) return t - timePart(2)
  return timePart(3) - (t - timePart(4))
}
function isPart(m, part) {
  const t = m.loading
  if (part === 1) return t < timePart(4)
  if (part === 4) return t > timePart(3)
  return t < timePart(part)
}
/** The current loading part (1–4), 0 when the refreshing animator is not running. */
function currentPart(m) {
  if (!m.refreshing) return 0
  for (let p = 1; p <= 4; p++) if (isPart(m, p)) return p
  return 0
}

function drawWind(ctx, m, y, xOffset, width) {
  const cof = (width + xOffset) / (LOADING_ANIMATION_COEFFICIENT / SLOW_DOWN_ANIMATION_COEFFICIENT)
  let time = m.loading
  if (m.lastTime - m.loading > 0) {
    m.inverse = true
    time = LOADING_ANIMATION_COEFFICIENT / SLOW_DOWN_ANIMATION_COEFFICIENT - m.loading
  } else {
    m.newWindSet = true
    m.inverse = false
  }
  const x = width - time * cof + xOffset - m.windLineWidth
  ctx.lineWidth = 3
  ctx.strokeStyle = 'rgba(255,255,255,0.25)'
  ctx.beginPath()
  ctx.moveTo(x, y)
  ctx.lineTo(x + m.windLineWidth, y)
  ctx.stroke()
}

function drawWinds(ctx, v, m, width, height) {
  if (v.status !== 'Refreshing') return
  height = Math.max(height, v.expand)
  // A new set of wind lines, spaced more than a fifth of the height apart (bounded tries instead of iOS's loop).
  let guard = 0
  while (m.winds.length < WIND_SET_AMOUNT && guard++ < 50) {
    let y = height / ((RANDOM_Y_COEFFICIENT * random(1, 100)) / 100)
    const x = random(MIN_WIND_X_OFFSET, MAX_WIND_X_OFFSET)
    if (m.winds.length > 1) {
      y = 0
      for (let tries = 0; y === 0 && tries < 100; tries++) {
        const tmp = height / ((RANDOM_Y_COEFFICIENT * random(1, 100)) / 100)
        y = m.winds.every((w) => Math.abs(w.y - tmp) > height / RANDOM_Y_COEFFICIENT) ? tmp : 0
      }
      if (y === 0) continue
    }
    m.winds.push({ y, x })
    drawWind(ctx, m, y, x, width)
  }
  if (m.winds.length >= WIND_SET_AMOUNT || guard >= 50) m.winds.forEach((w) => drawWind(ctx, m, w.y, w.x, width))
  if (m.inverse && m.newWindSet) {
    m.winds = []
    m.newWindSet = false
    m.windLineWidth = random(MIN_WIND_LINE_WIDTH, MAX_WIND_LINE_WIDTH)
  }
  m.lastTime = m.loading
}

function drawAirplane(ctx, v, m, width) {
  const plane = m.airplane
  const expand = v.expand
  let rotateAngle = 0
  let dragPercent = v.percent
  if (dragPercent > 1) {
    rotateAngle = 20 * (1 - Math.pow(100, -(dragPercent - 1) / 2))
    dragPercent = 1
  }
  let offsetX = (width * dragPercent) / 2 - plane.size.w / 2
  let offsetY = expand * (1 - dragPercent / 2) - plane.size.h / 2
  if (m.finish) {
    offsetY -= (expand / 2 + plane.size.h / 2) * m.finishTime
    offsetX += (width + plane.size.w - offsetX) * m.finishTime
  }
  const part = currentPart(m)
  if (part === 1 || part === 2) offsetY -= partValue(m, part)
  else if (part) offsetY += partValue(m, part)
  ctx.save()
  ctx.translate(offsetX, offsetY)
  if (rotateAngle > 0) {
    ctx.translate(plane.size.w / 2, plane.size.h / 2)
    ctx.rotate((rotateAngle * Math.PI) / 180)
    ctx.translate(-plane.size.w / 2, -plane.size.h / 2)
  }
  plane.moveTo(0, 0)
  plane.render(ctx)
  ctx.restore()
}

function drawCloudSide(ctx, v, m, width, height) {
  const cloud = m.cloud
  const cw = cloud.size.w
  const ch = cloud.size.h
  const dragPercent = Math.min(1, Math.abs(v.percent))
  const delta = dragPercent - SCALE_START_PERCENT
  const scale = delta > 0
    ? SIDE_CLOUDS_INITIAL_SCALE + (SIDE_CLOUDS_FINAL_SCALE - SIDE_CLOUDS_INITIAL_SCALE) * (delta / (1 - SCALE_START_PERCENT))
    : SIDE_CLOUDS_INITIAL_SCALE
  const dragYOffset = v.expand * (1 - dragPercent)
  let leftX = -cw / 2
  let leftY = dragYOffset
  let rightX = width - cw / 2
  let rightY = dragYOffset
  const part = currentPart(m)
  if (part) {
    const pv = partValue(m, part)
    const early = part <= 2
    leftX -= ((early ? 2 : 1) * pv) / Y_SIDE_CLOUDS_SLOW_DOWN_COF
    rightX += ((early ? 1 : 2) * pv) / X_SIDE_CLOUDS_SLOW_DOWN_COF
  }
  if (leftY + scale * ch < height + 2) leftY = height + 2 - scale * ch
  if (rightY + scale * ch < height + 2) rightY = height + 2 - scale * ch
  cloud.opacity = 100 / 255
  cloud.moveTo(0, 0)
  ctx.save()
  ctx.translate(leftX, leftY)
  ctx.translate((cw * 3) / 4, ch)
  ctx.scale(scale, scale)
  ctx.translate((-cw * 3) / 4, -ch)
  cloud.render(ctx)
  ctx.restore()
  ctx.save()
  ctx.translate(rightX, rightY)
  ctx.translate(0, ch)
  ctx.scale(scale, scale)
  ctx.translate(0, -ch)
  cloud.render(ctx)
  ctx.restore()
  cloud.opacity = 1
}

function drawCloudCenter(ctx, v, m, width, height) {
  const cloud = m.cloud
  const cw = cloud.size.w
  const ch = cloud.size.h
  const percent = v.percent
  const dragPercent = Math.min(1, Math.abs(percent))
  const overDrag = percent > 1
  const overDragPercent = overDrag ? Math.abs(1 - percent) : 0
  const delta = dragPercent - SCALE_START_PERCENT
  const scale = delta > 0
    ? CENTER_CLOUDS_INITIAL_SCALE + (CENTER_CLOUDS_FINAL_SCALE - CENTER_CLOUDS_INITIAL_SCALE) * (delta / (1 - SCALE_START_PERCENT))
    : CENTER_CLOUDS_INITIAL_SCALE
  const dragYOffset = v.expand * dragPercent
  const startParallax = Math.trunc(v.expand - ch / 2)
  const parallax = dragYOffset > startParallax ? dragYOffset - startParallax : 0
  const offsetX = width / 2 - cw / 2
  let offsetY = dragYOffset - ch / 2 - parallax
  let sx = overDrag ? scale + overDragPercent / 4 : scale
  const part = currentPart(m)
  if (part && !overDrag) {
    const pv = partValue(m, part)
    sx = part <= 2 ? scale - pv / LOADING_ANIMATION_COEFFICIENT / 8 : scale + pv / LOADING_ANIMATION_COEFFICIENT / 6
  }
  const sy = sx
  if (offsetY + sy * ch < height + 2) offsetY = height + 2 - sy * ch
  cloud.moveTo(0, 0)
  ctx.save()
  ctx.translate(offsetX, offsetY)
  ctx.translate(cw / 2, 0)
  ctx.scale(sx, sy)
  ctx.translate(-cw / 2, 0)
  cloud.render(ctx)
  ctx.restore()
}

function draw(ctx, v, m) {
  const width = v.w
  const height = v.h
  if (m.refreshing) m.loading = LOADING_ANIMATION_COEFFICIENT * (m.refreshing.value(v.now) / SLOW_DOWN_ANIMATION_COEFFICIENT)
  if (m.finish) {
    m.finishTime = m.finish.value(v.now)
    // The finish animator goes there and back; the refreshing one stops near its peak (value >= 0.95).
    if (m.finishTime >= 0.95) m.refreshing = null
    if (m.finish.done(v.now)) { m.finish = null; m.finishTime = 0; m.refreshing = null }
  }
  ctx.fillStyle = v.primary
  ctx.fillRect(0, 0, width, height)
  drawWinds(ctx, v, m, width, height)
  drawAirplane(ctx, v, m, width)
  drawCloudSide(ctx, v, m, width, height)
  drawCloudCenter(ctx, v, m, width, height)
}

const animating = (m) => !!m.finish

module.exports = { height: 100, primary: '#1199ff', accent: '#ffffff', stretch: true, create, status, draw, animating }
