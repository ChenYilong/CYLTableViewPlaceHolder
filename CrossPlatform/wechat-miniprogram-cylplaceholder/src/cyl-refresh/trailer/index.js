// cyl-refresh/trailer: CYLRefreshNormalTrailer (MJRefreshNormalTrailer) for WeChat Mini Program. A horizontal
// scroller; pulling left past its end by `trailerWidth` and letting go fires `trailer` (open the details), then the
// page calls endRefreshing (or the trailer folds by itself with autoEnd):
//
// <cyl-refresh-trailer id="trailer" height="200px" paging-enabled bind:trailer="onTrailer">…pages…</cyl-refresh-trailer>
'use strict'

const { CYLRefresh, CYLRefreshState } = require('../cyl_refresh')

const S = CYLRefreshState

Component({
  properties: {
    height: { type: String, value: '100%' },
    pagingEnabled: { type: Boolean, value: false },
    /** The pull that arms the trailer (MJRefreshTrailWidth). */
    trailerWidth: { type: Number, value: 60 },
    /** Folds back right after `trailer` fires; false waits for endRefreshing. */
    autoEnd: { type: Boolean, value: true },
    stateHidden: { type: Boolean, value: false },
    language: { type: String, value: '' },
    /** Custom texts { Idle, Pulling }. */
    titles: { type: null, value: null },
  },
  data: { pull: 0, state: S.Idle, text: '' },
  observers: {
    'state, language, titles': function () {
      this._render()
    },
  },
  lifetimes: {
    attached() {
      this._unsubscribe = CYLRefresh.onLanguageChange(() => this._render())
      this._render()
    },
    detached() {
      if (this._unsubscribe) this._unsubscribe()
    },
  },
  methods: {
    _render() {
      const state = this.data.state === S.Refreshing ? S.Pulling : this.data.state
      const own = this.data.titles && this.data.titles[state]
      this.setData({ text: own != null ? own : CYLRefresh.stateText('trailer', state, this.data.language || undefined) })
    },
    _atEnd() {
      if (this._scrollWidth == null || this._viewWidth == null) return true
      return this._scrollLeft >= this._scrollWidth - this._viewWidth - 2
    },
    onScroll(e) {
      this._scrollLeft = e.detail.scrollLeft
      this._scrollWidth = e.detail.scrollWidth
    },
    onTouchStart(e) {
      if (this.data.state === S.Refreshing) return
      this._tracking = true
      if (this._viewWidth == null) {
        this.createSelectorQuery().select('.cyl-trailer__scroll').boundingClientRect((r) => {
          if (r) this._viewWidth = r.width
        }).exec()
      }
      if (this._scrollLeft == null) this._scrollLeft = 0
      this._touchX = this._atEnd() ? e.touches[0].clientX : null
    },
    onTouchMove(e) {
      if (!this._tracking) return
      const x = e.touches[0].clientX
      // Not at the end when the touch began: the pull starts once the end is reached during the drag.
      if (this._touchX == null) {
        if (!this._atEnd()) return
        this._touchX = x
      }
      const pull = Math.max(0, this._touchX - x) * 0.5
      const state = pull >= this.data.trailerWidth ? S.Pulling : S.Idle
      this.setData(state !== this.data.state ? { pull, state } : { pull })
      this.triggerEvent('statechange', { state, percent: pull / this.data.trailerWidth })
    },
    onTouchEnd() {
      if (!this._tracking) return
      this._tracking = false
      if (this.data.state !== S.Pulling) return this.endRefreshing()
      this.setData({ state: S.Refreshing, pull: this.data.trailerWidth })
      this.triggerEvent('trailer', {})
      if (this.data.autoEnd) this.endRefreshing()
    },
    endRefreshing() {
      this.setData({ state: S.Idle, pull: 0 })
    },
  },
})
