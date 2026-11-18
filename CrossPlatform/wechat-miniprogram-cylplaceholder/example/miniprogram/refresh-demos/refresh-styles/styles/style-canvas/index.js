// style-canvas: hosts one CYLRefresh styles style renderer (../renderers/*.js) on a <canvas type="2d">, the
// mini program counterpart of CYLRefreshDrawnHeader's drawRect: and of CYLRefreshDrawnFooter hosting a style.
//
// The page feeds it cyl-refresh's statechange event: `state` (Idle / Pulling / Refreshing / NoMoreData) and
// `percent` (0..1). Statuses given to the renderer follow CYLRefresh styles's order:
//   Idle → Pulling (percent < 1) → Release (percent >= 1, still dragging) → Refreshing (the Releasing hook
//   runs right before) → Idle.
// Renderer drawing space: x from 0 to v.w, y from 0 (top of the revealed area) to v.h (the drag offset, the
// "dragOffset" of iOS). Header canvases are twice the open height and anchored at the bottom of the header, so the
// area above y = 0 is still painted (stretch styles fill it with colorPrimary) when the list is pulled further.
const { RENDERERS } = require('../renderers/index')

Component({
  options: { styleIsolation: 'isolated' },
  properties: {
    kind: { type: String, value: '' },
    /** 'header' or 'footer'. */
    part: { type: String, value: 'header' },
    state: { type: String, value: 'Idle' },
    percent: { type: Number, value: 0 },
    /** Theme colors; '' keeps the style's own (colorPrimary / colorAccent). */
    primary: { type: String, value: '' },
    accent: { type: String, value: '' },
  },
  data: { visible: false, boxHeight: 0, canvasId: 'c' },
  lifetimes: {
    attached() {
      this._renderer = RENDERERS[this.data.kind] || RENDERERS.RiveSpace
      this._mem = this._renderer.create ? this._renderer.create() : {}
      this._status = 'Idle'
      this._sync()
    },
    detached() {
      this._stop()
      this._canvas = null
    },
  },
  observers: {
    kind(kind) {
      if (!this._renderer) return
      this._renderer = RENDERERS[kind] || RENDERERS.RiveSpace
      this._mem = this._renderer.create ? this._renderer.create() : {}
      this._sync()
    },
    'state, percent, primary, accent': function () {
      if (this._renderer) this._sync()
    },
  },
  methods: {
    /** The open height of the style (expandHeight). */
    expandHeight() {
      return (this._renderer && this._renderer.height) || 100
    },
    _colors() {
      const r = this._renderer
      return {
        primary: this.data.primary || r.primary || 'transparent',
        accent: this.data.accent || r.accent || '#555555',
      }
    },
    /** Maps the cyl-refresh state to the style status and (re)creates the canvas when shown. */
    _sync() {
      const { part, state, percent } = this.data
      const footer = part === 'footer'
      let status
      if (state === 'Refreshing') status = 'Refreshing'
      else if (state === 'NoMoreData') status = 'NoMoreData'
      else if (footer) status = 'Idle'
      else if (state === 'Pulling') status = 'Release'
      else status = percent > 0 ? 'Pulling' : 'Idle'
      const old = this._status
      if (old !== status) {
        this._status = status
        const r = this._renderer
        const v = this._view(Date.now())
        if (status === 'Refreshing' && r.status) r.status(this._mem, old, 'Releasing', v)
        if (r.status) r.status(this._mem, old === 'Refreshing' && status !== 'Refreshing' ? 'Finishing' : old, status, v)
      }
      const visible = footer ? status !== 'NoMoreData' : status !== 'Idle' || percent > 0
      const boxHeight = this.expandHeight() * (footer ? 1 : 2)
      if (visible !== this.data.visible || boxHeight !== this.data.boxHeight) {
        if (!visible) { this._stop(); this._canvas = null }
        this.setData({ visible, boxHeight }, () => { if (visible) this._acquire() })
      } else if (visible) {
        this._kick()
      }
    },
    _acquire() {
      if (this._canvas || this._acquiring) { this._kick(); return }
      this._acquiring = true
      this.createSelectorQuery().select('#c').fields({ node: true, size: true }).exec((res) => {
        this._acquiring = false
        const info = res && res[0]
        if (!info || !info.node || !this.data.visible) return
        const canvas = info.node
        let dpr = 2
        try { dpr = (wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync()).pixelRatio || 2 } catch (e) {}
        canvas.width = Math.max(1, Math.round(info.width * dpr))
        canvas.height = Math.max(1, Math.round(info.height * dpr))
        this._canvas = canvas
        this._ctx = canvas.getContext('2d')
        this._size = { w: info.width, h: info.height, dpr }
        if (this._renderer.layout) this._renderer.layout(this._mem, info.width)
        this._kick()
      })
    },
    _view(now) {
      const r = this._renderer
      const footer = this.data.part === 'footer'
      const expand = this.expandHeight()
      const status = this._status
      const h = footer || status === 'Refreshing' ? expand : this.data.percent * expand
      const c = this._colors()
      const last = this._lastFrame || now
      return {
        w: this._size ? this._size.w : 375,
        h,
        expand,
        percent: footer || status === 'Refreshing' ? 1 : h / (expand * (r.triggerRate || 1)),
        status,
        part: this.data.part,
        primary: c.primary,
        accent: c.accent,
        now,
        dt: Math.min(0.1, (now - last) / 1000),
      }
    },
    /** Draws now and keeps a frame loop while the renderer animates. */
    _kick() {
      if (!this._canvas) return
      if (this._raf) return
      this._frame()
    },
    _frame() {
      this._raf = null
      if (!this._canvas || !this.data.visible) return
      const now = Date.now()
      const v = this._view(now)
      this._lastFrame = now
      const ctx = this._ctx
      const { w, h, dpr } = this._size
      ctx.setTransform(1, 0, 0, 1, 0, 0)
      ctx.clearRect(0, 0, w * dpr, h * dpr)
      ctx.scale(dpr, dpr)
      const top = h - v.h
      const r = this._renderer
      if (r.stretch && top > 0 && v.part === 'header') {
        ctx.fillStyle = v.primary
        ctx.fillRect(0, 0, w, top + 1)
      }
      ctx.save()
      ctx.translate(0, top)
      if (r.draw) r.draw(ctx, v, this._mem)
      ctx.restore()
      const more = v.status === 'Refreshing' || (r.animating && r.animating(this._mem, v))
      if (more) this._raf = this._canvas.requestAnimationFrame(() => this._frame()) || true
    },
    _stop() {
      if (this._raf && this._canvas && this._canvas.cancelAnimationFrame) this._canvas.cancelAnimationFrame(this._raf)
      this._raf = null
    },
    /** Touches on the canvas (the games): forwarded to the renderer. */
    onTouch(e) {
      const r = this._renderer
      if (!r.touch || !e.touches || !e.touches[0]) return
      const t = e.touches[0]
      r.touch(this._mem, { type: e.type, x: t.x, y: t.y - (this._size ? this._size.h - this._view(Date.now()).h : 0) })
      this._kick()
    },
  },
})
