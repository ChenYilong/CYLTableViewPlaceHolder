// cyl-refresh: CYLRefresh (MJRefresh-compatible pull-to-refresh) for WeChat Mini Program. A scroll-view with a
// header (pull down to refresh) and a footer (load more) around the page's content:
//
// <cyl-refresh id="refresh" header="normal" footer="auto" bind:refresh="onRefresh" bind:loadmore="onLoadMore">
//   …rows…
// </cyl-refresh>
// const refresh = this.selectComponent('#refresh'); refresh.endRefreshing(); refresh.endRefreshingWithNoMoreData()
//
// Header: "normal" (arrow and texts, CYLRefreshNormalHeader), "animation" (an icon per state,
// CYLRefreshAnimationHeader; headerIcons), "cupertino" (an activity indicator that fades and turns in with the pull,
// 60px, CYLRefreshCupertinoHeader), "listener" (draws nothing; read the `pull` event), "diy" (slot "header"), "none".
// Footer: "auto" (loads when the end comes into view or on tap, CYLRefreshAutoNormalFooter), "back"
// (CYLRefreshBackNormalFooter: "Pull up" / "Release to load more" from the drag past the end), "cupertino" (an auto
// footer with only a spinner), "diy" / "diyBack" (slot "footer"), "none".
//
// Also: headerTrigger / footerTrigger "anywhere" | "onEdge" (CYLRefreshTriggerMode); secondaryOffset (a release past
// it fires `secondary`, the second floor); behind (the header stays pinned under the content,
// CYLRefreshScrollModeBehind); finishDuration (endRefreshing({ success }) shows "Refresh complete" / "Refresh failed"
// first); the `pull` event ({ part, state, percent } with percent beyond 1); the scroll helpers measureContent /
// getScrollTop / setScrollTop / scrollToBottom (keep the offset when rows are prepended, a chat). Texts follow
// CYLRefresh.setLanguageCode and CYLRefresh.registerStrings live.
'use strict'

const {
  CYLRefresh,
  CYLRefreshState,
  CYLRefreshHeaderHeight,
  CYLRefreshFooterHeight,
  CYLRefreshCupertinoHeaderHeight,
} = require('./cyl_refresh')

const S = CYLRefreshState
const TICKS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

Component({
  options: { multipleSlots: true, pureDataPattern: /^_/ },
  properties: {
    header: { type: String, value: 'normal' },
    footer: { type: String, value: 'auto' },
    /** { Idle, Pulling, Refreshing }: '/path.json' or { path, size } per state (setIconAnimation…for:). */
    headerIcons: { type: null, value: null },
    /** { Idle, Refreshing, NoMoreData } of the footer. */
    footerIcons: { type: null, value: null },
    /** Fades the header in while pulling (isAutomaticallyChangeAlpha). */
    automaticallyChangeAlpha: { type: Boolean, value: false },
    /** Hides the "last updated" line (lastUpdatedTimeLabel.hidden). */
    lastUpdatedTimeHidden: { type: Boolean, value: false },
    /** Hides the state text (stateLabel.hidden). */
    stateHidden: { type: Boolean, value: false },
    /** Hides the footer (footer.hidden), for example while the placeholder shows. */
    footerHidden: { type: Boolean, value: false },
    /** Key under which the last refresh time is stored (lastUpdatedTimeKey). */
    lastUpdatedTimeKey: { type: String, value: 'CYLRefreshHeaderLastUpdatedTimeKey' },
    /** Language of the texts; empty follows CYLRefresh.setLanguageCode / CYLPlaceholderLocalization. */
    language: { type: String, value: '' },
    /** Custom header texts { Idle, Pulling, Refreshing, Finished, Failed } (setTitle:forState:). */
    headerTitles: { type: null, value: null },
    /** Custom footer texts { Idle, Pulling, Refreshing, NoMoreData, Finished, Failed }. */
    footerTitles: { type: null, value: null },
    /** Header state / time label styles: { stateColor, stateFontSize, timeColor, timeFontSize }. */
    headerStyle: { type: null, value: null },
    /** Footer label style: { color, fontSize }. */
    footerStyle: { type: null, value: null },
    /** Hides the footer's text while refreshing (refreshingTitleHidden). */
    refreshingTitleHidden: { type: Boolean, value: false },
    /** false: the auto footer loads only on tap (automaticallyRefresh). */
    automaticallyRefresh: { type: Boolean, value: true },
    /** How many times the auto footer loads by itself before it needs a tap; 0 is unlimited (autoTriggerTimes). */
    autoTriggerTimes: { type: Number, value: 0 },
    /** Header / footer height in px; 0 uses MJRefresh's 54 / 44 (60 for the Cupertino header). */
    headerHeight: { type: Number, value: 0 },
    footerHeight: { type: Number, value: 0 },
    /** "anywhere": a fling that bounces past the edge also triggers; "onEdge": only a drag that began at the edge. */
    headerTrigger: { type: String, value: 'anywhere' },
    footerTrigger: { type: String, value: 'anywhere' },
    /** A release past this pull distance fires `secondary` instead of `refresh` (the second floor); 0 is off. */
    secondaryOffset: { type: Number, value: 0 },
    /** The header stays pinned at the top under the content (CYLRefreshScrollModeBehind); give the rows a background. */
    behind: { type: Boolean, value: false },
    /** ms the finish text ("Refresh complete") shows after endRefreshing / endFooterRefreshing; 0 hides at once. */
    finishDuration: { type: Number, value: 0 },
  },
  data: {
    headerState: S.Idle,
    footerState: S.Idle,
    finishing: '',
    footerFinishing: '',
    triggered: false,
    pull: 0,
    percent: 0,
    footerPull: 0,
    threshold: CYLRefreshHeaderHeight,
    footerSize: CYLRefreshFooterHeight,
    scrollTarget: 0,
    ticks: TICKS,
    texts: {},
    headerIcon: null,
    footerIcon: null,
    headerLabelStyle: '',
    timeLabelStyle: '',
    footerLabelStyle: '',
  },
  observers: {
    'headerIcons, footerIcons, language, headerState, footerState, finishing, footerFinishing, headerTitles, footerTitles, headerStyle, footerStyle, footer': function () {
      this._render()
    },
    'header, headerHeight, footerHeight': function (header, h, f) {
      const base = header === 'cupertino' ? CYLRefreshCupertinoHeaderHeight : CYLRefreshHeaderHeight
      this.setData({ threshold: h || base, footerSize: f || CYLRefreshFooterHeight })
    },
    'headerState, pull': function (state, pull) {
      // DIY headers draw themselves from the state and the pull percentage (MJRefreshHeader pullingPercent).
      const raw = Math.max(0, pull / this.data.threshold)
      const percent = Math.min(1, raw)
      if (percent !== this.data.percent) this.setData({ percent })
      this.triggerEvent('statechange', { part: 'header', state, percent })
      this.triggerEvent('pull', { part: 'header', state, percent: raw })
    },
    'footerState, footerPull': function (state, footerPull) {
      const percent = state === S.Idle ? Math.max(0, footerPull / this.data.footerSize) : 1
      this.triggerEvent('statechange', { part: 'footer', state, percent: Math.min(1, percent) })
      this.triggerEvent('pull', { part: 'footer', state, percent })
    },
  },
  lifetimes: {
    attached() {
      this._scrollTop = 0
      this._scrollHeight = 0
      this._viewHeight = 0
      this._timers = []
      this._unsubscribe = CYLRefresh.onLanguageChange(() => this._render())
      this._render()
    },
    ready() {
      this.createSelectorQuery().select('.cyl-refresh__scroll').boundingClientRect((rect) => {
        if (rect) this._viewHeight = rect.height
      }).exec()
    },
    detached() {
      if (this._unsubscribe) this._unsubscribe()
      this._timers.forEach(clearTimeout)
    },
  },
  methods: {
    _isBack() {
      return this.data.footer === 'back' || this.data.footer === 'diyBack'
    },
    _language() {
      return this.data.language || undefined
    },
    _later(ms, fn) {
      this._timers.push(setTimeout(fn, ms))
    },
    _lastUpdated() {
      try {
        return wx.getStorageSync(this.data.lastUpdatedTimeKey) || null
      } catch (e) {
        return null
      }
    },
    _render() {
      const language = this._language()
      const footerKind = this._isBack() ? 'backFooter' : 'autoFooter'
      const { headerState, footerState, finishing, footerFinishing } = this.data
      const own = (titles, state) => (titles && titles[state] != null ? titles[state] : null)
      const pick = (titles, state, fallback) => (own(titles, state) != null ? own(titles, state) : fallback())
      const hs = this.data.headerStyle || {}
      const fs = this.data.footerStyle || {}
      const css = (color, size) => (color ? 'color:' + color + ';' : '') + (size ? 'font-size:' + size + 'px;' : '')
      const header = finishing
        ? pick(this.data.headerTitles, finishing, () => CYLRefresh.finishText('header', finishing !== 'Failed', language))
        : pick(this.data.headerTitles, headerState, () => CYLRefresh.stateText('header', headerState, language))
      let footer = footerFinishing
        ? pick(this.data.footerTitles, footerFinishing, () => CYLRefresh.finishText('footer', footerFinishing !== 'Failed', language))
        : pick(this.data.footerTitles, footerState, () => CYLRefresh.stateText(footerKind, footerState, language))
      const footerA11y = footer
      if (this.data.refreshingTitleHidden && footerState === S.Refreshing) footer = ''
      if (this.data.footer === 'cupertino' && !footerFinishing && footerState !== S.NoMoreData) footer = ''
      this.setData({
        texts: {
          header,
          lastUpdated: CYLRefresh.lastUpdatedText(this._lastUpdated(), null, language),
          footer,
          footerA11y,
        },
        headerIcon: this.data.header === 'animation' ? CYLRefresh.iconForState(this.data.headerIcons, headerState) : null,
        footerIcon: CYLRefresh.iconForState(this.data.footerIcons, footerState),
        headerLabelStyle: css(hs.stateColor, hs.stateFontSize),
        timeLabelStyle: css(hs.timeColor, hs.timeFontSize),
        footerLabelStyle: css(fs.color, fs.fontSize),
      })
    },

    // Drag tracking: trigger modes and the back footer's pull.
    _atBottom() {
      if (!this._viewHeight || !this._scrollHeight) return false
      return this._scrollTop >= this._scrollHeight - this._viewHeight - 2
    },
    _headerAllowed() {
      return this.data.headerTrigger !== 'onEdge' || this._startedAtTop !== false
    },
    _footerActive() {
      return this.data.footer !== 'none' && !this.data.footerHidden && this.data.footerState !== S.NoMoreData
    },
    onTouchStart(e) {
      this._dragging = true
      this._startedAtTop = this._scrollTop <= 0
      this._startedAtBottom = this._atBottom()
      this._touchY = e.touches && e.touches[0] ? e.touches[0].clientY : null
      this._footerTouchY = this._startedAtBottom ? this._touchY : null
    },
    onTouchMove(e) {
      if (!this._isBack() || !this._footerActive() || this.data.footerState === S.Refreshing) return
      const y = e.touches && e.touches[0] ? e.touches[0].clientY : null
      if (y == null) return
      if (this._footerTouchY == null) {
        // "anywhere": the pull starts when the end is reached during the drag.
        if (this.data.footerTrigger === 'onEdge' || !this._atBottom()) return
        this._footerTouchY = y
      }
      const footerPull = Math.max(0, this._footerTouchY - y) * 0.5
      const state = footerPull >= this.data.footerSize ? S.Pulling : S.Idle
      const update = { footerPull }
      if (state !== this.data.footerState) update.footerState = state
      this.setData(update)
    },
    onTouchEnd() {
      this._dragging = false
      if (!this._isBack()) return
      const armed = this.data.footerState === S.Pulling
      // onEdge: a drag that began at the end and lets go there loads, as does a release past the footer's height.
      const edge = this.data.footerTrigger === 'onEdge' && this._startedAtBottom && this._atBottom()
      if (this.data.footerState !== S.Refreshing && this.data.footerState !== S.NoMoreData) this.setData({ footerPull: 0, footerState: S.Idle })
      if (armed || edge) this._beginFooter()
    },
    onScroll(e) {
      const { scrollTop, scrollHeight } = e.detail
      this._scrollTop = scrollTop
      this._scrollHeight = scrollHeight
      this.triggerEvent('scroll', e.detail)
      // "anywhere": a fling that bounces past the top by the trigger distance also refreshes (iOS bounce).
      if (this.data.header !== 'none' && this.data.headerTrigger !== 'onEdge' && !this._dragging && scrollTop <= -this.data.threshold) {
        this._beginHeader()
      }
    },

    // Header: scroll-view's native refresher drives the pull; the header view follows it.
    onPulling(e) {
      if (this.data.headerState === S.Refreshing || this.data.finishing) return
      const pull = Math.max(0, e.detail.dy)
      this._lastPull = pull
      const state = this._headerAllowed() ? CYLRefresh.headerStateForPull(pull, this.data.threshold) : S.Idle
      this.setData(state !== this.data.headerState ? { pull, headerState: state } : { pull })
    },
    onRefresherRefresh() {
      if (this.data.headerState === S.Refreshing) return
      const pull = this._lastPull || 0
      this._lastPull = 0
      if (!this._headerAllowed() || this.data.finishing) return this._restore()
      if (this.data.secondaryOffset > 0 && pull >= this.data.secondaryOffset) {
        this._restore()
        this.triggerEvent('secondary', {})
        return
      }
      this._beginHeader()
    },
    onRefresherRestore() {
      if (this.data.headerState !== S.Refreshing && !this.data.finishing) this.setData({ pull: 0, headerState: S.Idle })
    },
    onRefresherAbort() {
      if (this.data.headerState !== S.Refreshing && !this.data.finishing) this.setData({ pull: 0, headerState: S.Idle })
    },
    // Folds the refresher back without refreshing (it needs a true -> false change of refresher-triggered).
    _restore() {
      this.setData({ triggered: true, pull: 0, headerState: S.Idle })
      wx.nextTick(() => this.setData({ triggered: false }))
    },
    _beginHeader() {
      if (this.data.headerState === S.Refreshing || this.data.header === 'none') return
      this.setData({ headerState: S.Refreshing, finishing: '', triggered: true, pull: this.data.threshold })
      this._autoTriggers = 0
      this.triggerEvent('refresh', {})
    },

    /** Starts the header in code (beginRefreshing). */
    beginRefreshing() {
      this._beginHeader()
    },
    /**
     * Ends the header (endRefreshing) and records the time. With finishDuration, { success: false } shows
     * "Refresh failed" and anything else "Refresh complete" before the header folds (the finish phase).
     */
    endRefreshing(options) {
      const success = !(options && options.success === false)
      if (success) {
        try {
          wx.setStorageSync(this.data.lastUpdatedTimeKey, Date.now())
        } catch (e) {}
      }
      if (this.data.footerState === S.Refreshing) this.setData({ footerState: S.Idle })
      // Already in the finish phase: its timer folds the header.
      if (this.data.finishing && this.data.headerState !== S.Refreshing) return
      if (this.data.headerState !== S.Refreshing || !(this.data.finishDuration > 0)) {
        this.setData({ triggered: false, headerState: S.Idle, finishing: '', pull: 0 })
        return
      }
      this.setData({ headerState: S.Idle, finishing: success ? 'Finished' : 'Failed' })
      this.triggerEvent('statechange', { part: 'header', state: this.data.finishing, percent: 1 })
      this._later(this.data.finishDuration, () => this.setData({ triggered: false, finishing: '', pull: 0 }))
    },
    isRefreshing() {
      return this.data.headerState === S.Refreshing || this.data.footerState === S.Refreshing
    },

    // Footer.
    onScrollToLower() {
      if (this.data.footer === 'none' || this.data.footerHidden) return
      if (this._isBack()) {
        // Back footers load from the drag (onTouchEnd); "anywhere" also loads on a fling to the end.
        if (this.data.footerTrigger === 'onEdge' || this._dragging) return
        return this._beginFooter()
      }
      if (!this.data.automaticallyRefresh) return
      // autoTriggerTimes: after that many automatic loads, the footer waits for a tap.
      const limit = this.data.autoTriggerTimes
      if (limit > 0 && (this._autoTriggers || 0) >= limit) return
      this._autoTriggers = (this._autoTriggers || 0) + 1
      this._beginFooter()
    },
    onFooterTap() {
      if (!this._isBack()) this._beginFooter()
    },
    _beginFooter() {
      if (this.data.footer === 'none' || this.data.footerHidden) return
      const s = this.data.footerState
      if ((s !== S.Idle && s !== S.Pulling) || this.data.headerState === S.Refreshing) return
      this.setData({ footerState: S.Refreshing, footerFinishing: '', footerPull: 0 })
      this.triggerEvent('loadmore', {})
    },
    /** Starts the footer in code. */
    beginFooterRefreshing() {
      this._beginFooter()
    },
    /** Ends the footer (footer endRefreshing); { success: false } shows "Load failed" in the finish phase. */
    endFooterRefreshing(options) {
      if (this.data.footerState !== S.Refreshing) return
      if (!(this.data.finishDuration > 0)) return this.setData({ footerState: S.Idle })
      const finishing = options && options.success === false ? 'Failed' : 'Finished'
      this.setData({ footerState: S.Idle, footerFinishing: finishing })
      this._later(this.data.finishDuration, () => this.setData({ footerFinishing: '' }))
    },
    /** Ends the footer with "No more data" (endRefreshingWithNoMoreData). */
    endRefreshingWithNoMoreData() {
      this.setData({ footerState: S.NoMoreData, footerFinishing: '', footerPull: 0 })
    },
    /** Back to idle after "No more data" (resetNoMoreData). */
    resetNoMoreData() {
      this.setData({ footerState: S.Idle })
    },

    // Scroll position (a chat keeps the visible rows in place when earlier ones are prepended).
    getScrollTop() {
      return this._scrollTop
    },
    /** Resolves with the height of the content (the page's rows). */
    measureContent() {
      return new Promise((resolve) => {
        this.createSelectorQuery().select('.cyl-refresh__content').boundingClientRect((rect) => resolve(rect ? rect.height : 0)).exec()
      })
    },
    setScrollTop(top) {
      // scroll-top only applies a changed value; a tiny offset makes a repeated target apply.
      const value = top === this.data.scrollTarget ? top + 0.01 : top
      this._scrollTop = top
      this.setData({ scrollTarget: value })
    },
    scrollToBottom() {
      this.setScrollTop(1000000)
    },
  },
})
