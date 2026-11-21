// The custom tab bar (app.json "tabBar": {"custom": true}): cyl-tab-bar from cyl-tabbar-miniprogram, as the iOS
// example uses CYLTabBarController. `select` switches tabs; the plus button opens the Publish page.
const { tabBarConfiguration, TAB_PAGES } = require('../utils/tabs')

Component({
  data: { configuration: {}, selected: 'scenarios' },
  lifetimes: {
    attached() {
      this.setData({ configuration: tabBarConfiguration() })
    },
  },
  methods: {
    /** Called by each tab page in onShow (getTabBar().cyl_select(identifier)). */
    cyl_select(identifier) {
      this.setData({ selected: identifier, configuration: tabBarConfiguration() })
    },
    onSelect(e) {
      const identifier = e.detail.identifier || e.detail.pageIdentifier
      if (TAB_PAGES[identifier]) wx.switchTab({ url: '/' + TAB_PAGES[identifier] })
    },
    onPlusTap() {
      wx.navigateTo({ url: '/pages/publish/publish' })
    },
  },
})
