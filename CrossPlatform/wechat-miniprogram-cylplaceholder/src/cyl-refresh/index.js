// cyl-refresh: CYLRefresh (MJRefresh-compatible pull-to-refresh) for WeChat Mini Program. A scroll-view with a
// header (pull down to refresh) and a footer (load more) around the page's content:
//
// <cyl-refresh id="refresh" header="normal" footer="auto" bind:refresh="onRefresh" bind:loadmore="onLoadMore">
//   …rows…
// </cyl-refresh>
// const refresh = this.selectComponent('#refresh'); refresh.endRefreshing(); refresh.endRefreshingWithNoMoreData()
//
// Header: "normal" (arrow and texts, CYLRefreshNormalHeader), "animation" (an icon per state,
// CYLRefreshAnimationHeader; headerIcons), "none". Footer: "auto" (loads when the end comes into view or on tap,
// CYLRefreshAutoNormalFooter), "back" (CYLRefreshBackNormalFooter texts; loads at the end), "none".
'use strict'

const { CYLRefresh, CYLRefreshState, CYLRefreshHeaderHeight, CYLRefreshFooterHeight } = require('./cyl_refresh')

const S = CYLRefreshState

Component({
  options: { multipleSlots: true, pureDataPattern: /^_/ },
  properties: {
    header: { type: String, value: 'normal' },
    footer: { type: String, value: 'auto' },
    /** { Idle, Pulling, Refreshing }: '/path.json' or { path, size } per state (setIconAnimation…for:). */
    headerIcons: { type: Object, value: null },
    /** { Idle, Refreshing, NoMoreData } of the footer. */
    footerIcons: { type: Object, value: null },
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
    /** Custom header texts { Idle, Pulling, Refreshing } (setTitle:forState:). */
    headerTitles: { type: Object, value: null },
    /** Custom footer texts { Idle, Pulling, Refreshing, NoMoreData }. */
    footerTitles: { type: Object, value: null },
    /** Header state / time label styles: { stateColor, stateFontSize, timeColor, timeFontSize }. */
    headerStyle: { type: Object, value: null },
    /** Footer label style: { color, fontSize }. */
    footerStyle: { type: Object, value: null },
    /** Hides the footer's text while refreshing (refreshingTitleHidden). */
    refreshingTitleHidden: { type: Boolean, value: false },
    /** false: the auto footer loads only on tap (automaticallyRefresh). */
    automaticallyRefresh: { type: Boolean, value: true },
    /** How many times the auto footer loads by itself before it needs a tap; 0 is unlimited (autoTriggerTimes). */
    autoTriggerTimes: { type: Number, value: 0 },
    /** Header / footer height in px; 0 uses MJRefresh's 54 / 44. A "diy" header or footer renders its slot. */
    headerHeight: { type: Number, value: 0 },
    footerHeight: { type: Number, value: 0 },
  },
  data: {
    headerState: S.Idle,
    footerState: S.Idle,
    triggered: false,
    pull: 0,
    threshold: CYLRefreshHeaderHeight,
    footerSize: CYLRefreshFooterHeight,
    texts: {},
    headerIcon: null,
    footerIcon: null,
    headerLabelStyle: '',
    timeLabelStyle: '',
    footerLabelStyle: '',
  },
  observers: {
    'headerIcons, footerIcons, language, headerState, footerState, headerTitles, footerTitles, headerStyle, footerStyle': function () {
      this._render()
    },
    'headerHeight, footerHeight': function (h, f) {
      this.setData({ threshold: h || CYLRefreshHeaderHeight, footerSize: f || CYLRefreshFooterHeight })
    },
    'headerState, pull': function (state, pull) {
      // DIY headers draw themselves from the state and the pull percentage (MJRefreshHeader pullingPercent).
      this.triggerEvent('statechange', { part: 'header', state, percent: Math.min(1, pull / this.data.threshold) })
    },
    footerState(state) {
      this.triggerEvent('statechange', { part: 'footer', state, percent: state === S.Idle ? 0 : 1 })
    },
  },
  lifetimes: {
    attached() {
      this._render()
    },
  },
  methods: {
    _isBack() {
      return this.data.footer === 'back' || this.data.footer === 'diyBack'
    },
    _language() {
      return this.data.language || undefined
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
      const { headerState, footerState } = this.data
      const own = (titles, state) => (titles && titles[state] != null ? titles[state] : null)
      const hs = this.data.headerStyle || {}
      const fs = this.data.footerStyle || {}
      const css = (color, size) => (color ? 'color:' + color + ';' : '') + (size ? 'font-size:' + size + 'px;' : '')
      const footerOwn = own(this.data.footerTitles, footerState)
      let footer = footerOwn != null ? footerOwn : CYLRefresh.stateText(footerKind, footerState, language)
      if (this.data.refreshingTitleHidden && footerState === S.Refreshing) footer = ''
      this.setData({
        texts: {
          header: own(this.data.headerTitles, headerState) != null ? own(this.data.headerTitles, headerState) : CYLRefresh.stateText('header', headerState, language),
          lastUpdated: CYLRefresh.lastUpdatedText(this._lastUpdated(), null, language),
          footer,
        },
        headerIcon: this.data.header === 'animation' ? CYLRefresh.iconForState(this.data.headerIcons, headerState) : null,
        footerIcon: CYLRefresh.iconForState(this.data.footerIcons, footerState),
        headerLabelStyle: css(hs.stateColor, hs.stateFontSize),
        timeLabelStyle: css(hs.timeColor, hs.timeFontSize),
        footerLabelStyle: css(fs.color, fs.fontSize),
      })
    },

    // Header: scroll-view's native refresher drives the pull; the header view follows it.
    onPulling(e) {
      if (this.data.headerState === S.Refreshing) return
      const pull = Math.max(0, e.detail.dy)
      const state = CYLRefresh.headerStateForPull(pull, this.data.threshold)
      this.setData(state !== this.data.headerState ? { pull, headerState: state } : { pull })
    },
    onRefresherRefresh() {
      this._beginHeader()
    },
    onRefresherRestore() {
      this.setData({ pull: 0, headerState: S.Idle })
    },
    onRefresherAbort() {
      this.setData({ pull: 0, headerState: S.Idle })
    },
    _beginHeader() {
      if (this.data.headerState === S.Refreshing) return
      this.setData({ headerState: S.Refreshing, triggered: true, pull: this.data.threshold })
      this._autoTriggers = 0
      this.triggerEvent('refresh', {})
    },

    /** Starts the header in code (beginRefreshing). */
    beginRefreshing() {
      this._beginHeader()
    },
    /** Ends the header (endRefreshing) and records the time. */
    endRefreshing() {
      try {
        wx.setStorageSync(this.data.lastUpdatedTimeKey, Date.now())
      } catch (e) {}
      this.setData({ triggered: false, headerState: S.Idle, pull: 0 })
      if (this.data.footerState === S.Refreshing) this.setData({ footerState: S.Idle })
    },
    isRefreshing() {
      return this.data.headerState === S.Refreshing || this.data.footerState === S.Refreshing
    },

    // Footer.
    onScrollToLower() {
      if (this.data.footer === 'none' || this.data.footerHidden) return
      if (!this._isBack()) {
        if (!this.data.automaticallyRefresh) return
        // autoTriggerTimes: after that many automatic loads, the footer waits for a tap.
        const limit = this.data.autoTriggerTimes
        if (limit > 0 && (this._autoTriggers || 0) >= limit) return
        this._autoTriggers = (this._autoTriggers || 0) + 1
      }
      this._beginFooter()
    },
    onFooterTap() {
      if (!this._isBack()) this._beginFooter()
    },
    _beginFooter() {
      if (this.data.footerState !== S.Idle || this.data.headerState === S.Refreshing) return
      this.setData({ footerState: S.Refreshing })
      this.triggerEvent('loadmore', {})
    },
    /** Starts the footer in code. */
    beginFooterRefreshing() {
      this._beginFooter()
    },
    /** Ends the footer (footer endRefreshing). */
    endFooterRefreshing() {
      if (this.data.footerState === S.Refreshing) this.setData({ footerState: S.Idle })
    },
    /** Ends the footer with "No more data" (endRefreshingWithNoMoreData). */
    endRefreshingWithNoMoreData() {
      this.setData({ footerState: S.NoMoreData })
    },
    /** Back to idle after "No more data" (resetNoMoreData). */
    resetNoMoreData() {
      this.setData({ footerState: S.Idle })
    },
  },
})
