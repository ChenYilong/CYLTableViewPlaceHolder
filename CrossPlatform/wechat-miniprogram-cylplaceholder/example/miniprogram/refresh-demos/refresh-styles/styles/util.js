// Shared drawing helpers of the CYLRefresh styles style renderers: colors, interpolators and a value animator
// (CYLRefreshValueAnimator) driven by the canvas frame time.

/** '#rgb', '#rrggbb', '#rrggbbaa', 'rgb()/rgba()' or 'transparent' to [r, g, b, a] (a in 0..1). */
function parseColor(c) {
  if (!c || c === 'transparent' || c === 'clear') return [0, 0, 0, 0]
  if (c[0] === '#') {
    let h = c.slice(1)
    if (h.length === 3) h = h.split('').map((x) => x + x).join('')
    const n = (i) => parseInt(h.slice(i, i + 2), 16)
    return [n(0), n(2), n(4), h.length >= 8 ? n(6) / 255 : 1]
  }
  const m = c.match(/[\d.]+/g) || []
  return [+m[0] || 0, +m[1] || 0, +m[2] || 0, m[3] != null ? +m[3] : 1]
}

/** The color with its alpha multiplied by `alpha`. */
function alpha(c, a) {
  const p = parseColor(c)
  return `rgba(${p[0]},${p[1]},${p[2]},${Math.max(0, Math.min(1, p[3] * a))})`
}

/** Linear mix of two colors, t in 0..1. */
function mix(c1, c2, t) {
  const a = parseColor(c1)
  const b = parseColor(c2)
  const v = (i) => a[i] + (b[i] - a[i]) * t
  return `rgba(${Math.round(v(0))},${Math.round(v(1))},${Math.round(v(2))},${v(3)})`
}

const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v))

/** Interpolators of CYLRefreshValueAnimator (t in 0..1). */
const ease = {
  linear: (t) => t,
  accelerate: (t) => t * t,
  decelerate: (t) => 1 - (1 - t) * (1 - t),
  accelerateDecelerate: (t) => (Math.cos((t + 1) * Math.PI) / 2) + 0.5,
}

/**
 * A value animator: value goes from `from` to `to` over `duration` seconds, repeating `repeat` times (Infinity
 * for ever), 'restart' or 'reverse'. Call `value(now)` each frame with the frame time in ms.
 */
class Animator {
  constructor(opts) {
    this.from = opts.from != null ? opts.from : 0
    this.to = opts.to != null ? opts.to : 1
    this.duration = (opts.duration || 0.25) * 1000
    this.repeat = opts.repeat || 0
    this.mode = opts.mode || 'restart'
    this.interpolator = opts.interpolator || ease.accelerateDecelerate
    this.start = opts.now != null ? opts.now : Date.now()
  }
  progress(now) {
    const raw = (now - this.start) / this.duration
    const cycles = this.repeat + 1
    if (raw >= cycles) return { t: this.mode === 'reverse' && this.repeat % 2 === 1 ? 0 : 1, done: true }
    const k = Math.floor(raw)
    let t = raw - k
    if (this.mode === 'reverse' && k % 2 === 1) t = 1 - t
    return { t, done: false }
  }
  value(now) {
    const p = this.progress(now)
    return this.from + (this.to - this.from) * this.interpolator(p.t)
  }
  done(now) {
    return this.progress(now).done
  }
}

module.exports = { parseColor, alpha, mix, clamp, ease, Animator }
