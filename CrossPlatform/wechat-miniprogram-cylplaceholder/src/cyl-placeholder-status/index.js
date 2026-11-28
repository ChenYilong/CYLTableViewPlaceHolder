// cyl-placeholder-status: CYLPlaceholderStatusView for WeChat Mini Program, the red "network unavailable" bar of
// CYLChatKit's LCCKStatusView. Put it at the top of a page, above the list and its cyl-placeholder:
//
// <cyl-placeholder-status visible="{{showsBar}}" shows-when-offline bind:statustap="onStatusTap" />
//
// Events: `statustap` (only while `tappable`; CYLPlaceholderStatusViewDelegate statusViewClicked:), `networkchange`
// with { offline } while `showsWhenOffline` watches the network. The icon is a cyl-animated-item (CYLTabBarController's
// CYLAnimatedItem, src/cyl-animated-item), so the bar shows its image, or the component placeholder without one.
'use strict'

const { CYLPlaceholderStatus, CYLPlaceholderStatusViewHeight } = require('../cyl-placeholder/cyl_status')
const { cylResolvePath } = require('../cyl-placeholder/cyl_animated_icon')

Component({
  properties: {
    /** Shows the bar (cyl_statusDisplay includes the status bar). */
    visible: { type: Boolean, value: false },
    /** Also shows the bar while the device is offline (cyl_showsStatusViewWhenOffline). */
    showsWhenOffline: { type: Boolean, value: false },
    /** The text; empty uses the localized "network unavailable" message. */
    text: { type: String, value: '' },
    /** An icon name of the package (default status_fail). */
    image: { type: String, value: '' },
    titleColor: { type: String, value: '' },
    backgroundColor: { type: String, value: '' },
    /** true makes the bar a button that sends `statustap` (a delegate or tapHandler on iOS / Android). */
    tappable: { type: Boolean, value: false },
    language: { type: String, value: '' },
    /** A status bar dictionary of a configuration file ({ text, textKey, image, titleColor, backgroundColor }). */
    configuration: { type: null, value: null },
  },
  data: { shown: false, offline: false, bar: {}, height: CYLPlaceholderStatusViewHeight, error: '', imageFolder: '' },
  observers: {
    'text, image, titleColor, backgroundColor, language, configuration': function () {
      this._build()
    },
    'visible, showsWhenOffline, offline': function (visible, showsWhenOffline, offline) {
      this.setData({ shown: visible || (showsWhenOffline && offline) })
    },
    showsWhenOffline(watch) {
      watch ? this._watch() : this._unwatch()
    },
  },
  lifetimes: {
    attached() {
      // The icon is drawn by cyl-animated-item, from its own folder: the package icons need an absolute path.
      this.setData({ imageFolder: cylResolvePath('../cyl-placeholder/images/', this.is) })
      this._build()
    },
    detached() {
      this._unwatch()
    },
  },
  methods: {
    _build() {
      const language = this.data.language || undefined
      let bar
      try {
        bar = this.data.configuration
          ? CYLPlaceholderStatus.statusBarFromConfiguration(this.data.configuration, language)
          : CYLPlaceholderStatus.networkUnavailableStatusBar(language)
      } catch (e) {
        this.setData({ error: e.message })
        this.triggerEvent('configerror', { message: e.message })
        bar = CYLPlaceholderStatus.networkUnavailableStatusBar(language)
      }
      if (this.data.text) bar.text = this.data.text
      if (this.data.image) bar.image = this.data.image
      if (this.data.titleColor) bar.titleColor = this.data.titleColor
      if (this.data.backgroundColor) bar.backgroundColor = this.data.backgroundColor
      this.setData({ bar })
    },
    _watch() {
      if (this._listener) return
      this._listener = (res) => {
        const offline = !res.isConnected || res.networkType === 'none'
        this.setData({ offline })
        this.triggerEvent('networkchange', { offline })
      }
      wx.onNetworkStatusChange(this._listener)
      wx.getNetworkType({ success: (res) => this._listener({ isConnected: res.networkType !== 'none', networkType: res.networkType }) })
    },
    _unwatch() {
      if (!this._listener) return
      if (wx.offNetworkStatusChange) wx.offNetworkStatusChange(this._listener)
      this._listener = null
      this.setData({ offline: false })
    },
    onTap() {
      if (this.data.tappable) this.triggerEvent('statustap', {})
    },
  },
})
