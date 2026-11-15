// Helpers shared by the example pages.
const { t } = require('./l10n')
const { TAB_TITLE_KEYS } = require('./tabs')

/**
 * Call in a tab root page's onShow: selects its tab in the custom tab bar and sets the navigation title to the tab
 * title (the iOS example's root title is its tab title).
 */
function showTab(page, identifier) {
  wx.setNavigationBarTitle({ title: t(TAB_TITLE_KEYS[identifier]) })
  if (typeof page.getTabBar === 'function' && page.getTabBar()) page.getTabBar().cyl_select(identifier)
}

/** Runs `block` after `ms` like a network request; returns a cancel function (call it in onUnload). */
function later(ms, block) {
  const timer = setTimeout(block, ms)
  return () => clearTimeout(timer)
}

module.exports = { showTab, later }
