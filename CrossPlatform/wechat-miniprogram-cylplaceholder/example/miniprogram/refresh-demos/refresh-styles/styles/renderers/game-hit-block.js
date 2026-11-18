// CYLRefreshGameHitBlockHeader (SmartRefreshControl's UIRefreshGameHitBlockHeader on CYLRefreshGameHeader): a
// 100 pt SpriteKit scene. While pulling: the start scene ("Pull to Break Out!" / "Scroll to move handle" on
// colorAccent, framed in colorPrimary). While refreshing: a breakout game on colorPrimary, 3 × 5 blocks on the
// left, the paddle near the right edge, "Refreshing..." in the middle.
// iOS moves the paddle with the extra pull distance; the mini program header gets no touches and no pull past the
// threshold, so the paddle follows the ball by itself. The SpriteKit physics is replaced by simple reflections.

const SCENE = 100
const FONT = 'bold 20px "AvenirNext-Bold", "Avenir Next", -apple-system, sans-serif'
const FONT_DETAIL = 'bold 17px "AvenirNext-Bold", "Avenir Next", -apple-system, sans-serif'

/** CYLRefreshGameStartScene, drawn with its top at y. */
function drawStart(ctx, v, y) {
  ctx.fillStyle = v.accent
  ctx.fillRect(0, y, v.w, SCENE)
  ctx.strokeStyle = v.primary
  ctx.lineWidth = 1
  ctx.strokeRect(0.5, y + 0.5, v.w - 1, SCENE - 1)
  ctx.fillStyle = v.primary
  ctx.textAlign = 'center'
  ctx.textBaseline = 'alphabetic'
  ctx.font = FONT
  ctx.fillText('Pull to Break Out!', v.w / 2, y + SCENE / 2 - 5)
  ctx.font = FONT_DETAIL
  ctx.fillText('Scroll to move handle', v.w / 2, y + SCENE / 2 + 15)
}

/** CYLRefreshGamePlayingScene background and centered title. */
function drawPlaying(ctx, v, title) {
  ctx.fillStyle = v.primary
  ctx.fillRect(0, 0, v.w, SCENE)
  ctx.fillStyle = v.accent
  ctx.textAlign = 'center'
  ctx.textBaseline = 'alphabetic'
  ctx.font = FONT
  ctx.fillText(title, v.w / 2, SCENE / 2)
}

/** SKTransition doors open (0.4 s): two halves of the start scene slide apart. */
function drawDoors(ctx, v, t) {
  const k = Math.min(1, t / 0.4)
  if (k >= 1) return
  const half = v.w / 2
  ctx.save()
  ctx.beginPath()
  ctx.rect(-half * k, 0, half, SCENE)
  ctx.rect(half + half * k, 0, half, SCENE)
  ctx.clip()
  ctx.save()
  ctx.beginPath(); ctx.rect(0, 0, half, SCENE); ctx.clip()
  ctx.translate(-half * k, 0)
  drawStart(ctx, v, 0)
  ctx.restore()
  ctx.save()
  ctx.beginPath(); ctx.rect(half, 0, half, SCENE); ctx.clip()
  ctx.translate(half * k, 0)
  drawStart(ctx, v, 0)
  ctx.restore()
  ctx.restore()
}

function reset(m, v) {
  const w = v.w
  m.w = w
  m.paddle = { x: w - 30, y: SCENE / 2, w: 5, h: 30 }
  m.ball = { x: w - 30 - 5, y: SCENE / 2, r: 4, vx: 0, vy: 0, hidden: false }
  const bh = (SCENE - 4) / 5
  m.blocks = []
  for (let i = 0; i < 3; i++) {
    for (let j = 0; j < 5; j++) {
      m.blocks.push({ x: 20 + i * 6, y: j * (bh + 1) + bh / 2, w: 5, h: bh, a: 1 - i * 0.2 })
    }
  }
  m.title = 'Refreshing...'
}

function start(m) {
  const y = (30 - Math.floor(Math.random() * 60)) / 100
  const speed = 220
  m.ball.vx = -speed
  m.ball.vy = (y / 0.5) * speed
}

function step(m, v, dt) {
  const b = m.ball
  if (b.hidden) return
  const p = m.paddle
  // The paddle follows the ball (iOS: the player's scroll).
  const target = Math.max(p.h / 2, Math.min(SCENE - p.h / 2, b.y))
  p.y += Math.max(-260 * dt, Math.min(260 * dt, target - p.y))
  b.x += b.vx * dt
  b.y += b.vy * dt
  if (b.y - b.r < 0) { b.y = b.r; b.vy = Math.abs(b.vy) }
  if (b.y + b.r > SCENE) { b.y = SCENE - b.r; b.vy = -Math.abs(b.vy) }
  if (b.x - b.r < 0) { b.x = b.r; b.vx = Math.abs(b.vx) }
  // The paddle.
  if (b.vx > 0 && b.x + b.r >= p.x - p.w / 2 && b.x < p.x && Math.abs(b.y - p.y) <= p.h / 2 + b.r) {
    b.x = p.x - p.w / 2 - b.r
    b.vx = -Math.abs(b.vx)
  }
  // Blocks: removed on contact.
  for (let i = 0; i < m.blocks.length; i++) {
    const k = m.blocks[i]
    if (Math.abs(b.x - k.x) <= k.w / 2 + b.r && Math.abs(b.y - k.y) <= k.h / 2 + b.r) {
      m.blocks.splice(i, 1)
      b.vx = -b.vx
      break
    }
  }
  // The end line at the right edge: game over; no block left: game win.
  if (b.x + b.r >= m.w - 1) { b.hidden = true; m.title = 'Game Over' }
  else if (!m.blocks.length) { b.hidden = true; m.title = 'Game Win' }
}

module.exports = {
  height: SCENE,
  primary: '#555555',
  accent: '#ffffff',
  stretch: false,
  create() {
    return { playing: false, startAt: 0, blocks: [] }
  },
  status(m, old, now, v) {
    if (now === 'Refreshing') {
      reset(m, v)
      start(m)
      m.playing = true
      m.startAt = v.now
    } else if (now === 'Idle') {
      m.playing = false
    }
  },
  draw(ctx, v, m) {
    if (!m.playing || v.status !== 'Refreshing') {
      // CYLRefreshScrollModeMove: the scene moves down with the list.
      drawStart(ctx, v, v.h - SCENE)
      return
    }
    if (m.w !== v.w) reset(m, v)
    step(m, v, v.dt)
    drawPlaying(ctx, v, m.title)
    m.blocks.forEach((k) => {
      ctx.globalAlpha = k.a
      ctx.fillStyle = v.accent
      ctx.fillRect(k.x - k.w / 2, k.y - k.h / 2, k.w, k.h)
    })
    ctx.globalAlpha = 1
    ctx.fillStyle = v.accent
    const p = m.paddle
    ctx.fillRect(p.x - p.w / 2, p.y - p.h / 2, p.w, p.h)
    if (!m.ball.hidden) {
      // An SKSpriteNode: a square sprite of the accent color.
      ctx.fillRect(m.ball.x - m.ball.r, m.ball.y - m.ball.r, m.ball.r * 2, m.ball.r * 2)
    }
    drawDoors(ctx, v, (v.now - m.startAt) / 1000)
  },
  // Shared with game-battle-city.js.
  SCENE, drawStart, drawPlaying, drawDoors,
}
