// CYLRefreshGameBattleCityHeader (CYLRefresh styles's UIRefreshGameBattleCityHeader on CYLRefreshGameHeader):
// the same start scene as GameHitBlock; while refreshing, enemy tanks drive right along 3 rows and the player's
// tank on the right shoots round bullets to the left. A tank reaching the player ends the game ("Game Over").
// iOS moves the player with the extra pull; here the player tank aims at the leading enemy by itself. SpriteKit
// physics is replaced by box overlap tests.
const { SCENE, drawStart, drawPlaying, drawDoors } = require('./game-hit-block')

const ROWS = 3
const BARREL_RATIO = 1 / 3
const BULLET_SPACING = 200
const TANK_SPACING = 40
const TANK_SPEED = 120
const BULLET_SPEED = 260

function sizes() {
  const tank = SCENE / ROWS
  const barrel = tank * BARREL_RATIO
  return { tank, half: tank / 2, barrel, pad: (tank - barrel) / 2 }
}

function reset(m, v) {
  const s = sizes()
  m.w = v.w
  m.player = { x: v.w - s.half, y: s.half }
  m.enemies = []
  m.bullets = []
  m.lastEnemy = null
  m.lastBullet = null
  m.running = true
  m.title = 'Refreshing...'
}

/** Player: body square with the barrel on the left. */
function drawPlayer(ctx, x, y, s) {
  const { half, barrel, pad } = s
  ctx.beginPath()
  ctx.moveTo(x + half, y - half)
  ctx.lineTo(x + half, y + half)
  ctx.lineTo(x - half, y + half)
  ctx.lineTo(x - half, y + half - pad)
  ctx.lineTo(x - half - barrel, y + half - pad)
  ctx.lineTo(x - half - barrel, y + half - pad - barrel)
  ctx.lineTo(x - half, y + half - pad - barrel)
  ctx.lineTo(x - half, y - half)
  ctx.closePath()
  ctx.fill()
}

/** Enemy: body with the barrel on the right, inside the tank square. */
function drawEnemy(ctx, x, y, s) {
  const { half, pad } = s
  ctx.beginPath()
  ctx.moveTo(x - half, y - half)
  ctx.lineTo(x - half, y + half)
  ctx.lineTo(x + half - pad, y + half)
  ctx.lineTo(x + half - pad, y + half - pad)
  ctx.lineTo(x + half, y + half - pad)
  ctx.lineTo(x + half, y - half + pad)
  ctx.lineTo(x + half - pad, y - half + pad)
  ctx.lineTo(x + half - pad, y - half)
  ctx.closePath()
  ctx.fill()
}

function step(m, v, dt) {
  if (!m.running) return
  const s = sizes()
  // update: a new enemy once the last one left the spawn area, a new bullet once the last one is far enough.
  if (!m.lastEnemy || m.lastEnemy.x > TANK_SPACING + s.tank) {
    m.lastEnemy = { x: s.tank / 2 + 5, y: s.tank * (0.5 + Math.floor(Math.random() * ROWS)) }
    m.enemies.push(m.lastEnemy)
  }
  if (!m.lastBullet || m.lastBullet.x < v.w - s.tank - s.barrel - BULLET_SPACING) {
    m.lastBullet = { x: m.player.x - s.tank - s.barrel / 3, y: m.player.y }
    m.bullets.push(m.lastBullet)
  }
  // The player aims at the leading enemy (iOS: the player's scroll).
  const lead = m.enemies.reduce((a, e) => (!a || e.x > a.x ? e : a), null)
  if (lead) {
    const ty = Math.max(s.half, Math.min(SCENE - s.half, lead.y))
    m.player.y += Math.max(-150 * dt, Math.min(150 * dt, ty - m.player.y))
  }
  m.enemies.forEach((e) => { e.x += TANK_SPEED * dt })
  m.bullets.forEach((b) => { b.x -= BULLET_SPEED * dt })
  // Contacts: bullet × tank removes both; tank × player is game over; leaving the scene removes a node.
  m.bullets = m.bullets.filter((b) => {
    const hit = m.enemies.find((e) => Math.abs(b.x - e.x) <= s.half + s.barrel / 2 && Math.abs(b.y - e.y) <= s.half + s.barrel / 2)
    if (hit) {
      m.enemies.splice(m.enemies.indexOf(hit), 1)
      if (hit === m.lastEnemy) m.lastEnemy = null
      if (b === m.lastBullet) m.lastBullet = null
      return false
    }
    if (b.x < 0) { if (b === m.lastBullet) m.lastBullet = null; return false }
    return true
  })
  for (const e of m.enemies) {
    if (e.x + s.half >= m.player.x - s.half - s.barrel && Math.abs(e.y - m.player.y) < s.tank) {
      m.running = false
      m.title = 'Game Over'
      return
    }
  }
  m.enemies = m.enemies.filter((e) => {
    if (e.x - s.half > v.w) { if (e === m.lastEnemy) m.lastEnemy = null; return false }
    return true
  })
}

module.exports = {
  height: SCENE,
  primary: '#555555',
  accent: '#ffffff',
  stretch: false,
  create() {
    return { playing: false, startAt: 0, enemies: [], bullets: [] }
  },
  status(m, old, now, v) {
    if (now === 'Refreshing') {
      reset(m, v)
      m.playing = true
      m.startAt = v.now
    } else if (now === 'Idle') {
      m.playing = false
    }
  },
  draw(ctx, v, m) {
    if (!m.playing || v.status !== 'Refreshing') {
      drawStart(ctx, v, v.h - SCENE)
      return
    }
    if (m.w !== v.w) reset(m, v)
    step(m, v, v.dt)
    drawPlaying(ctx, v, m.title)
    const s = sizes()
    ctx.fillStyle = v.accent
    drawPlayer(ctx, m.player.x, m.player.y, s)
    m.enemies.forEach((e) => drawEnemy(ctx, e.x, e.y, s))
    m.bullets.forEach((b) => {
      ctx.beginPath()
      ctx.arc(b.x, b.y, s.barrel / 2, 0, Math.PI * 2)
      ctx.fill()
    })
    drawDoors(ctx, v, (v.now - m.startAt) / 1000)
  },
}
