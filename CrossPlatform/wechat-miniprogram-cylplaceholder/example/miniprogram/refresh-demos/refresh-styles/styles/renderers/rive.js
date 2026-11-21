// CYLRefreshRiveHeader stand-ins. The mini program has no Rive runtime, so each flutter_easy_refresh Rive package
// (Bow, Bubbles, Halloween, Skating, Space, Squats) is replaced by a small canvas scene with the same idea, the
// same open height (triggerOffset: 180 by default, Bow / Halloween 200, Squats 190) and the same phases: the art
// follows the pull, loops while refreshing.
const { alpha, clamp } = require('../util')

const TAU = Math.PI * 2

function circle(ctx, x, y, r, fill) {
  ctx.beginPath()
  ctx.arc(x, y, Math.max(0, r), 0, TAU)
  ctx.fillStyle = fill
  ctx.fill()
}

// Each scene draws in the bottom-aligned box (0..w, h - box .. h), box = max(h, minimum); p = pull 0..1,
// t = seconds since refreshing started (0 when not refreshing).
const SCENES = {
  // A bow drawn back with the pull; while refreshing, arrows fly to a target.
  Bow(ctx, w, h, p, t, refreshing) {
    ctx.fillStyle = '#fdf6e3'
    ctx.fillRect(0, 0, w, h)
    const cy = h - 70
    const bx = w * 0.3
    const draw = refreshing ? 18 + 18 * Math.abs(Math.sin(t * 2.5)) : 36 * p
    ctx.lineWidth = 4
    ctx.strokeStyle = '#8b5a2b'
    ctx.beginPath()
    ctx.arc(bx + 40, cy, 50, Math.PI * 0.62, Math.PI * 1.38)
    ctx.stroke()
    const top = { x: bx + 40 + 50 * Math.cos(Math.PI * 0.62), y: cy - 50 * Math.sin(Math.PI * 0.38) }
    const bottom = { x: top.x, y: cy + (cy - top.y) }
    ctx.lineWidth = 1.5
    ctx.strokeStyle = '#555'
    ctx.beginPath()
    ctx.moveTo(top.x, top.y)
    ctx.lineTo(top.x - draw, cy)
    ctx.lineTo(bottom.x, bottom.y)
    ctx.stroke()
    // Target.
    const tx = w * 0.82
    ;['#e74c3c', '#fff', '#e74c3c', '#fff', '#e74c3c'].forEach((c, i) => circle(ctx, tx, cy, 30 - i * 6, c))
    // Arrow: on the string, or flying.
    const fly = refreshing ? (t * 1.4) % 1 : 0
    const ax = refreshing ? top.x + (tx - top.x) * fly : top.x - draw
    ctx.strokeStyle = '#333'
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.moveTo(ax, cy)
    ctx.lineTo(ax + 60, cy)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(ax + 66, cy)
    ctx.lineTo(ax + 56, cy - 5)
    ctx.lineTo(ax + 56, cy + 5)
    ctx.closePath()
    ctx.fillStyle = '#333'
    ctx.fill()
  },
  // Bubbles that swell with the pull (from 4/7 of it), then rise while loading.
  Bubbles(ctx, w, h, p, t, refreshing) {
    ctx.fillStyle = '#e8f4ff'
    ctx.fillRect(0, 0, w, h)
    const k = refreshing ? 1 : clamp((p - 4 / 7) / (3 / 7), 0, 1)
    for (let i = 0; i < 7; i++) {
      const x = w * (0.15 + i * 0.12)
      const base = h - 30 - (i % 3) * 18
      const rise = refreshing ? ((t * 60 + i * 37) % (h + 40)) : 0
      const r = (8 + (i % 3) * 5) * (refreshing ? 1 : k)
      ctx.beginPath()
      ctx.arc(x, base - rise, Math.max(0, r), 0, TAU)
      ctx.fillStyle = alpha('#4aa8ff', 0.35)
      ctx.fill()
      ctx.lineWidth = 1.5
      ctx.strokeStyle = alpha('#2b7fd6', 0.7)
      ctx.stroke()
    }
  },
  // A night scene with a pumpkin that grows with the pull and glows while loading.
  Halloween(ctx, w, h, p, t, refreshing) {
    ctx.fillStyle = '#1d1135'
    ctx.fillRect(0, 0, w, h)
    circle(ctx, w * 0.8, h - 150, 22, '#f4e9b8')
    circle(ctx, w * 0.8 + 9, h - 156, 20, '#1d1135')
    const s = refreshing ? 1 + 0.05 * Math.sin(t * 6) : 0.4 + 0.6 * clamp(p, 0, 1)
    const cx = w / 2
    const cy = h - 55
    ctx.save()
    ctx.translate(cx, cy)
    ctx.scale(s, s)
    ;[-22, 22, 0].forEach((dx) => {
      ctx.beginPath()
      ctx.ellipse(dx, 0, 26, 36, 0, 0, TAU)
      ctx.fillStyle = '#f57c00'
      ctx.fill()
    })
    ctx.fillStyle = '#4e7d2a'
    ctx.fillRect(-4, -46, 8, 14)
    const glow = refreshing ? 0.6 + 0.4 * Math.abs(Math.sin(t * 4)) : 0.8
    ctx.fillStyle = alpha('#ffeb3b', glow)
    ;[-1, 1].forEach((d) => {
      ctx.beginPath()
      ctx.moveTo(d * 18, -12); ctx.lineTo(d * 8, 0); ctx.lineTo(d * 28, 0)
      ctx.closePath(); ctx.fill()
    })
    ctx.beginPath()
    ctx.moveTo(-22, 12); ctx.lineTo(22, 12); ctx.lineTo(12, 22); ctx.lineTo(0, 16); ctx.lineTo(-12, 22)
    ctx.closePath(); ctx.fill()
    ctx.restore()
  },
  // A skateboard rolling over a ramp: pulled back with the pull, rolling while loading (minimum height 140).
  Skating(ctx, w, h, p, t, refreshing) {
    ctx.fillStyle = '#ffe0b2'
    ctx.fillRect(0, 0, w, h)
    const ground = h - 30
    ctx.fillStyle = '#795548'
    ctx.fillRect(0, ground, w, 30)
    const x = refreshing ? ((t * 160) % (w + 120)) - 60 : w / 2 - 60 * (1 - clamp(p, 0, 1))
    const jump = refreshing ? Math.max(0, Math.sin(t * 5)) * 20 : 0
    const y = ground - 10 - jump
    ctx.fillStyle = '#e53935'
    ctx.fillRect(x - 30, y - 4, 60, 6)
    circle(ctx, x - 20, y + 6, 5, '#212121')
    circle(ctx, x + 20, y + 6, 5, '#212121')
    // Rider.
    ctx.strokeStyle = '#3949ab'
    ctx.lineWidth = 4
    ctx.beginPath()
    ctx.moveTo(x - 12, y - 4); ctx.lineTo(x, y - 30); ctx.lineTo(x + 12, y - 4)
    ctx.moveTo(x, y - 30); ctx.lineTo(x, y - 58)
    ctx.moveTo(x - 18, y - 48); ctx.lineTo(x + 18, y - 44)
    ctx.stroke()
    circle(ctx, x, y - 68, 9, '#ffcc80')
  },
  // A rocket among stars: rises with the pull, launches with a flame while loading.
  Space(ctx, w, h, p, t, refreshing) {
    ctx.fillStyle = '#0b1026'
    ctx.fillRect(0, 0, w, h)
    for (let i = 0; i < 40; i++) {
      const sx = (i * 97) % w
      const sy = (h - ((i * 53 + (refreshing ? t * 80 : 0)) % h))
      circle(ctx, sx, sy, (i % 3) * 0.6 + 0.6, alpha('#ffffff', 0.5 + (i % 2) * 0.4))
    }
    const cx = w / 2
    const cy = refreshing ? h - 70 + Math.sin(t * 20) * 1.5 : h - 30 - 40 * clamp(p, 0, 1)
    if (refreshing || p > 0.5) {
      const flame = 18 + 8 * Math.abs(Math.sin((t || p) * 18))
      ctx.beginPath()
      ctx.moveTo(cx - 8, cy + 22); ctx.lineTo(cx, cy + 22 + flame); ctx.lineTo(cx + 8, cy + 22)
      ctx.closePath(); ctx.fillStyle = '#ff9800'; ctx.fill()
    }
    ctx.beginPath()
    ctx.moveTo(cx, cy - 34)
    ctx.quadraticCurveTo(cx + 16, cy - 10, cx + 12, cy + 22)
    ctx.lineTo(cx - 12, cy + 22)
    ctx.quadraticCurveTo(cx - 16, cy - 10, cx, cy - 34)
    ctx.fillStyle = '#eceff1'
    ctx.fill()
    circle(ctx, cx, cy - 6, 6, '#29b6f6')
    ctx.fillStyle = '#e53935'
    ctx.beginPath(); ctx.moveTo(cx - 12, cy + 8); ctx.lineTo(cx - 22, cy + 24); ctx.lineTo(cx - 12, cy + 22); ctx.fill()
    ctx.beginPath(); ctx.moveTo(cx + 12, cy + 8); ctx.lineTo(cx + 22, cy + 24); ctx.lineTo(cx + 12, cy + 22); ctx.fill()
  },
  // A figure that idles, then does squats while loading.
  Squats(ctx, w, h, p, t, refreshing) {
    ctx.fillStyle = '#e8f5e9'
    ctx.fillRect(0, 0, w, h)
    const ground = h - 24
    ctx.fillStyle = '#a5d6a7'
    ctx.fillRect(0, ground, w, 24)
    const d = refreshing ? (1 - Math.cos(t * 4)) / 2 : 0.08 * (1 - Math.cos(Date.now() / 400))
    const cx = w / 2
    const hip = ground - 60 + 26 * d
    const knee = ground - 30
    ctx.strokeStyle = '#37474f'
    ctx.lineWidth = 5
    ctx.lineCap = 'round'
    ctx.beginPath()
    ctx.moveTo(cx - 10, ground); ctx.lineTo(cx - 10 - 18 * d, knee); ctx.lineTo(cx, hip)
    ctx.moveTo(cx + 10, ground); ctx.lineTo(cx + 10 + 18 * d, knee); ctx.lineTo(cx, hip)
    ctx.moveTo(cx, hip); ctx.lineTo(cx + 6 * d, hip - 46)
    ctx.moveTo(cx + 6 * d, hip - 38); ctx.lineTo(cx + 34, hip - 34 - 8 * d)
    ctx.stroke()
    circle(ctx, cx + 6 * d, hip - 58, 11, '#ffcc80')
  },
}

/** A renderer for one Rive package (the RiveSpaceFooter uses 'Space' as a footer). */
function forFile(name, height, minimum) {
  const scene = SCENES[name]
  return {
    height,
    primary: 'transparent',
    accent: '#ffffff',
    stretch: false,
    create() {
      return { start: 0 }
    },
    status(mem, old, now, v) {
      if (now === 'Refreshing') mem.start = v.now
    },
    draw(ctx, v, mem) {
      const box = Math.max(v.h, minimum || height)
      ctx.save()
      ctx.beginPath()
      ctx.rect(0, 0, v.w, v.h)
      ctx.clip()
      ctx.translate(0, v.h - box)
      const refreshing = v.status === 'Refreshing'
      scene(ctx, v.w, box, v.percent, refreshing ? (v.now - mem.start) / 1000 : 0, refreshing)
      ctx.restore()
    },
    animating(mem, v) {
      return name === 'Squats'
    },
  }
}

module.exports = {
  forFile,
  RiveBow: forFile('Bow', 200),
  RiveBubbles: forFile('Bubbles', 180),
  RiveHalloween: forFile('Halloween', 200),
  RiveSkating: forFile('Skating', 180, 140),
  RiveSpace: forFile('Space', 180),
  RiveSquats: forFile('Squats', 190),
}
