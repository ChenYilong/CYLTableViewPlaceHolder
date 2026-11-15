// easy-refresh: a small page-local pull-to-refresh scroller for the flutter_easy_refresh samples
// (CYLEasyRefreshDemoViewController). It covers what cyl-refresh does not have:
// - header "normal" (CYLRefreshNormalHeader), "cupertino" (CYLRefreshCupertinoHeader: an activity indicator that
//   fades and turns in with the pull, 60px), "listener" (a bare CYLRefreshHeader that draws nothing; the page reads
//   the `pull` event), "none";
// - footer "back" (CYLRefreshBackNormalFooter), "cupertino" (CYLRefreshCupertinoFooter: an auto footer that only
//   shows a spinner), "none";
// - headerTrigger / footerTrigger "anywhere" | "onEdge" (CYLRefreshTriggerMode, default anywhere);
// - secondaryOffset: a release past this pull distance fires `secondary` instead of `refresh` (the second floor);
// - behind: the indicator stays pinned at the top behind the content (CYLRefreshScrollModeBehind);
// - measureContent / getScrollTop / setScrollTop / scrollToBottom for the chat sample (keep the offset on prepend).
// Texts come from the core's CYLRefresh tables, so they follow the language like cyl-refresh.
'use strict'

const { CYLRefresh, CYLRefreshState, CYLRefreshHeaderHeight, CYLRefreshFooterHeight } = require('../../../../components/cyl-refresh/cyl_refresh')

const S = CYLRefreshState
const TIME_KEY = 'CYLRefreshHeaderLastUpdatedTimeKey'
const CUPERTINO_HEADER_HEIGHT = 60

Component({
  options: { pureDataPattern: /^_/ },
  properties: {
    header: { type: String, value: 'normal' },
    footer: { type: String, value: 'back' },
    headerTrigger: { type: String, value: 'anywhere' },
    footerTrigger: { type: String, value: 'anywhere' },
    secondaryOffset: { type: Number, value: 0 },
    behind: { type: Boolean, value: false },
    footerHidden: { type: Boolean, value: false },
  },
  data: {
    headerState: S.Idle,
    footerState: S.Idle,
    pull: 0,
    triggered: false,
    threshold: CYLRefreshHeaderHeight,
    footerSize: CYLRefreshFooterHeight,
    texts: {},
    percent: 0,
    scrollTarget: 0,
    ticks: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
  },
  observers: {
    header(kind) {
      this.setData({ threshold: kind === 'cupertino' ? CUPERTINO_HEADER_HEIGHT : CYLRefreshHeaderHeight })
    },
    'headerState, footerState, footer': function () {
      this._render()
    },
    'headerState, pull': function (state, pull) {
      const percent = Math.max(0, pull / this.data.threshold)
      this.setData({ percent: Math.min(1, percent) })
      this.triggerEvent('pull', { state, percent })
    },
  },
  lifetimes: {
    attached() {
      this._scrollTop = 0
      this._scrollHeight = 0
      this._viewHeight = 0
      this._render()
    },
    ready() {
      this.createSelectorQuery().select('.er__scroll').boundingClientRect((rect) => {
        if (rect) this._viewHeight = rect.height
      }).exec()
    },
  },
  methods: {
    _render() {
      const state = this.data.headerState
      const footerState = this.data.footerState
      let lastUpdated = null
      try {
        lastUpdated = wx.getStorageSync(TIME_KEY) || null
      } catch (e) {}
      this.setData({
        texts: {
          header: CYLRefresh.stateText('header', state),
          lastUpdated: CYLRefresh.lastUpdatedText(lastUpdated),
          footer: this.data.footer === 'cupertino' ? '' : CYLRefresh.stateText('backFooter', footerState),
          footerA11y: CYLRefresh.stateText(this.data.footer === 'cupertino' ? 'autoFooter' : 'backFooter', footerState),
        },
      })
    },

    // Whether the current drag may arm the header (CYLRefreshTriggerModeOnEdge: only a drag that started at the top).
    _headerAllowed() {
      return this.data.headerTrigger !== 'onEdge' || this._startedAtTop !== false
    },
    _atBottom() {
      if (!this._viewHeight || !this._scrollHeight) return false
      return this._scrollTop >= this._scrollHeight - this._viewHeight - 2
    },

    onTouchStart() {
      this._dragging = true
      this._startedAtTop = this._scrollTop <= 0
      this._startedAtBottom = this._atBottom()
    },
    onTouchEnd() {
      this._dragging = false
      // A back footer with onEdge loads when a drag that started at the end lets go there.
      if (this.data.footer === 'back' && this.data.footerTrigger === 'onEdge' && this._startedAtBottom && this._atBottom()) {
        this._beginFooter()
      }
    },
    onScroll(e) {
      const { scrollTop, scrollHeight } = e.detail
      this._scrollTop = scrollTop
      this._scrollHeight = scrollHeight
      // "anywhere": a fling that bounces past the top by the trigger distance also refreshes (iOS bounce only).
      if (this.data.header !== 'none' && this.data.headerTrigger !== 'onEdge' && !this._dragging &&
          scrollTop <= -this.data.threshold) {
        this._beginHeader()
      }
    },

    // Header, on scroll-view's native refresher.
    onPulling(e) {
      if (this.data.headerState === S.Refreshing) return
      const pull = Math.max(0, e.detail.dy)
      let state = S.Idle
      if (this._headerAllowed() && pull >= this.data.threshold) state = S.Pulling
      this._lastPull = pull
      this.setData(state !== this.data.headerState ? { pull, headerState: state } : { pull })
    },
    onRefresherRefresh() {
      if (this.data.headerState === S.Refreshing) return
      const pull = this._lastPull || 0
      this._lastPull = 0
      if (!this._headerAllowed()) return this._restore()
      if (this.data.secondaryOffset > 0 && pull >= this.data.secondaryOffset) {
        this._restore()
        this.triggerEvent('secondary', {})
        return
      }
      this._beginHeader()
    },
    onRefresherRestore() {
      if (this.data.headerState !== S.Refreshing) this.setData({ pull: 0, headerState: S.Idle })
    },
    onRefresherAbort() {
      if (this.data.headerState !== S.Refreshing) this.setData({ pull: 0, headerState: S.Idle })
    },
    // Lets the refresher fold back without refreshing (it needs a true -> false change of refresher-triggered).
    _restore() {
      this.setData({ triggered: true, pull: 0, headerState: S.Idle })
      wx.nextTick(() => this.setData({ triggered: false }))
    },
    _beginHeader() {
      if (this.data.headerState === S.Refreshing || this.data.header === 'none') return
      this.setData({ headerState: S.Refreshing, triggered: true, pull: this.data.threshold })
      this.triggerEvent('refresh', {})
    },
    /** beginRefreshing */
    beginRefreshing() {
      this._beginHeader()
    },
    /** endRefreshing: ends the header and records the time. */
    endRefreshing() {
      try {
        wx.setStorageSync(TIME_KEY, Date.now())
      } catch (e) {}
      this.setData({ triggered: false, headerState: S.Idle, pull: 0 })
    },

    // Footer.
    onScrollToLower() {
      const { footer, footerTrigger } = this.data
      if (footer === 'none' || this.data.footerHidden) return
      // "onEdge" back footers wait for the drag to end (onTouchEnd); "anywhere" also loads on a fling to the end.
      if (footer === 'back' && footerTrigger === 'onEdge') return
      this._beginFooter()
    },
    _beginFooter() {
      if (this.data.footer === 'none' || this.data.footerHidden) return
      if (this.data.footerState !== S.Idle || this.data.headerState === S.Refreshing) return
      this.setData({ footerState: S.Refreshing })
      this.triggerEvent('loadmore', {})
    },
    endFooterRefreshing() {
      if (this.data.footerState === S.Refreshing) this.setData({ footerState: S.Idle })
    },
    endRefreshingWithNoMoreData() {
      this.setData({ footerState: S.NoMoreData })
    },
    resetNoMoreData() {
      this.setData({ footerState: S.Idle })
    },

    // Scroll position, for the chat sample.
    getScrollTop() {
      return this._scrollTop
    },
    /** The height of the content (the page's rows). */
    measureContent() {
      return new Promise((resolve) => {
        this.createSelectorQuery().select('.er__content').boundingClientRect((rect) => resolve(rect ? rect.height : 0)).exec()
      })
    },
    setScrollTop(top) {
      // scroll-top only applies a changed value; a tiny offset makes repeated targets apply.
      const value = top === this.data.scrollTarget ? top + 0.01 : top
      this._scrollTop = top
      this.setData({ scrollTarget: value })
    },
    scrollToBottom() {
      this.setScrollTop(1000000)
    },
  },
})
