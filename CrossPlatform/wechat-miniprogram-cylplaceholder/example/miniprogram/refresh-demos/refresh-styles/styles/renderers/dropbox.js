// CYLRefreshDropBoxHeader (SmartRefreshControl's UIRefreshDropBoxHeader): an isometric box whose lids open while
// a movie, a file and a music icon drop into it in turn; between drops the box sides bulge (rebound).
const { VectorImage } = require('../vector')
const { alpha, Animator, ease } = require('../util')

const PATH_IMAGE_MOIVE = [
  "M3 2h18v20h-18z",
  "m4 1c-1 0 -2 1 -2 2v18c0 1 1 2 2 2h16c1 0 2 -1 2 -2v-18c0 -1 -1 -2 -2 -2h-16zM3.5 3h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 3h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 6h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 6h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 9h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 9h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 12h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 12h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 15h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 15h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 18h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 18h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5z",
]
const PATH_IMAGE_FILE = [
  "M49,16.5l-14,-14l-27,0l0,53l41,0z",
  "m16,23.5h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1L16,21.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1z",
  "m16,15.5h10c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1L16,13.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1z",
  "M41,29.5L16,29.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1z",
  "M41,37.5L16,37.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1z",
  "M41,45.5L16,45.5c-0.55,0 -1,0.45 -1,1 0,0.55 0.45,1 1,1h25c0.55,0 1,-0.45 1,-1 0,-0.55 -0.45,-1 -1,-1z",
  "M49,16.5l-14,-14l0,14z",
]
const PATH_IMAGE_MUSIC = [
  "M6,2.1L6,11.3C5.4,11.3 4.8,11.4 4.2,11.6C2.6,12.3 1.6,13.7 2.1,14.8C2.6,15.9 4.2,16.2 5.8,15.6C7.1,15.1 7.8,14.1 7.9,13.2L7.9,4.3L15,3L15,9.4C14.4,9.3 13.7,9.4 13,9.7C11.4,10.3 10.5,11.7 11,12.8C11.4,13.9 13.1,14.3 14.7,13.6C15.9,13.1 16.8,12.2 16.9,11.3L16.9,0L6,2.1L6,2.1Z",
]

const HEIGHT = 100
const DURATION = 0.25 // durationNormal
const SIDE = HEIGHT / 5 // sideLength and imageSize (setHeight:)

const trunc = Math.trunc

function measure(margin, width, height, sideLength) {
  const b = {}
  b.boxSideLength = sideLength
  b.boxCenterX = trunc(width / 2)
  b.boxBottom = trunc(height - margin)
  b.boxTop = b.boxBottom - 2 * sideLength
  b.boxLeft = b.boxCenterX - trunc(sideLength * Math.sin(Math.PI / 3))
  b.boxCenterTop = b.boxTop + trunc(sideLength / 2)
  b.boxCenterBottom = b.boxBottom - trunc(sideLength / 2)
  b.boxRight = trunc(width) - b.boxLeft
  b.boxCenterY = b.boxBottom - sideLength
  return b
}

function image(paths, colors) {
  const img = new VectorImage(paths, colors)
  img.setSize(SIDE, SIDE)
  return img
}

function create() {
  return {
    movie: image(PATH_IMAGE_MOIVE, ['#ecf0f1', '#fc4108']),
    file: image(PATH_IMAGE_FILE, ['#fed469', '#d5ae57']),
    music: image(PATH_IMAGE_MUSIC, ['#98d761']),
    percentRebound: 0,
    percentDropOut: 0,
    overflow: false,
    anim: null, // { kind: 'drop' | 'rebound', animator }
  }
}

function startAnim(mem, kind, now) {
  mem.anim = { kind, animator: new Animator({ duration: DURATION, interpolator: ease.accelerate, now }) }
}

function status(mem, old, now, v) {
  if (now === 'Idle' || now === 'Pulling') {
    mem.overflow = false
    mem.anim = null
    mem.percentDropOut = 0
    mem.percentRebound = 0
  } else if (now === 'Refreshing') {
    startAnim(mem, 'drop', v.now)
  }
}

/** onAnimation: / onAnimationEnd: of the two animators, chained: drop → rebound → drop … */
function step(mem, v) {
  if (v.status !== 'Refreshing' || !mem.anim) return
  const a = mem.anim.animator
  const value = a.value(v.now)
  const done = a.done(v.now)
  if (mem.anim.kind === 'rebound') {
    mem.percentRebound = 1 - 2 * Math.abs(value - 0.5)
    if (done) { mem.percentRebound = 0; startAnim(mem, 'drop', v.now) }
  } else {
    const p = mem.percentDropOut
    if (p < 1 || p >= 3) mem.percentDropOut = value
    else if (p < 2) mem.percentDropOut = 1 + value
    else {
      mem.percentDropOut = 2 + value
      if (mem.percentDropOut >= 3) mem.overflow = true
    }
    if (done) startAnim(mem, 'rebound', v.now)
  }
}

function drawBoxBody(ctx, b, accent, pr) {
  ctx.fillStyle = alpha(accent, 150 / 255)
  ctx.beginPath()
  ctx.moveTo(b.boxLeft, b.boxCenterBottom)
  ctx.lineTo(b.boxCenterX, b.boxBottom)
  ctx.lineTo(b.boxRight, b.boxCenterBottom)
  ctx.quadraticCurveTo(b.boxRight + (b.boxSideLength / 2) * pr, b.boxCenterY, b.boxRight, b.boxCenterTop)
  ctx.lineTo(b.boxCenterX, b.boxTop)
  ctx.lineTo(b.boxLeft, b.boxCenterTop)
  ctx.quadraticCurveTo(b.boxLeft - (b.boxSideLength / 2) * pr, b.boxCenterY, b.boxLeft, b.boxCenterBottom)
  ctx.closePath()
  ctx.fill()
}

function quad(ctx, pts) {
  ctx.beginPath()
  ctx.moveTo(pts[0], pts[1])
  for (let i = 2; i < pts.length; i += 2) ctx.lineTo(pts[i], pts[i + 1])
  ctx.closePath()
  ctx.fill()
}

function drawBoxCover(ctx, b, accent, pr) {
  ctx.fillStyle = accent
  const side = trunc(((b.boxCenterX - b.boxLeft) * 4) / 5)
  const off = pr * ((Math.PI * 2) / 5)
  const mid = trunc((b.boxBottom + b.boxTop) / 2)
  const ltx = side * Math.sin(Math.PI / 3 - off / 2)
  const lty = side * Math.cos(Math.PI / 3 - off / 2)
  quad(ctx, [b.boxLeft, b.boxCenterTop, b.boxCenterX, b.boxTop, b.boxCenterX - ltx, b.boxTop - lty, b.boxLeft - ltx, b.boxCenterTop - lty])
  const lbx = side * Math.sin(Math.PI / 3 + off)
  const lby = side * Math.cos(Math.PI / 3 + off)
  quad(ctx, [b.boxLeft, b.boxCenterTop, b.boxCenterX, mid, b.boxCenterX - lbx, mid + lby, b.boxLeft - lbx, b.boxCenterTop + lby])
  quad(ctx, [b.boxRight, b.boxCenterTop, b.boxCenterX, b.boxTop, b.boxCenterX + ltx, b.boxTop - lty, b.boxRight + ltx, b.boxCenterTop - lty])
  quad(ctx, [b.boxRight, b.boxCenterTop, b.boxCenterX, mid, b.boxCenterX + lbx, mid + lby, b.boxRight + lbx, b.boxCenterTop + lby])
}

function drawImages(ctx, b, w, mem) {
  const p = mem.percentDropOut
  if (p <= 0) return
  ctx.save()
  ctx.beginPath()
  ctx.moveTo(0, 0)
  ctx.lineTo(0, b.boxCenterTop)
  ctx.lineTo(b.boxLeft, b.boxCenterTop)
  ctx.lineTo(b.boxCenterX, b.boxCenterY)
  ctx.lineTo(b.boxRight, b.boxCenterTop)
  ctx.lineTo(w, b.boxCenterTop)
  ctx.lineTo(w, 0)
  ctx.closePath()
  ctx.clip()
  const x = w / 2 - SIDE / 2
  const yAt = (q) => (b.boxCenterY - SIDE / 2 + SIDE) * q - SIDE
  const imgs = [mem.movie, mem.file, mem.music]
  imgs.forEach((img, i) => {
    img.moveTo(x, yAt(Math.min(Math.max(p - i, 0), 1)))
    img.render(ctx)
  })
  if (mem.overflow) {
    imgs.forEach((img) => {
      img.moveTo(x, b.boxCenterY - SIDE / 2)
      img.render(ctx)
    })
  }
  ctx.restore()
}

function draw(ctx, v, mem) {
  step(mem, v)
  const margin = SIDE / 2
  const b = measure(margin, v.w, v.h, margin * 2)
  ctx.fillStyle = v.primary
  ctx.fillRect(0, 0, v.w, v.h)
  drawBoxBody(ctx, b, v.accent, mem.percentRebound)
  drawBoxCover(ctx, b, v.accent, mem.percentRebound)
  drawImages(ctx, b, v.w, mem)
}

module.exports = {
  height: HEIGHT,
  primary: '#283645',
  accent: '#6ea9ff',
  stretch: true,
  create,
  status,
  draw,
}
