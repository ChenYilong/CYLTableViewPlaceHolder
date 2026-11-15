// The tab bar of the iOS example (CYLScenarioTabBarController.swift): five tabs, the teal plus button at index 3
// (after the first three tabs, center Y −24, 84×84), as a CYLTabBarController configuration for cyl-tab-bar.
const { t } = require('./l10n')

const TEAL = '#30B0C7'

/** Tab identifier -> page path (also app.json's tabBar.list). */
const TAB_PAGES = {
  scenarios: 'pages/scenarios/scenarios',
  animations: 'pages/animations/animations',
  flows: 'pages/flows/flows',
  feed: 'pages/feed/feed',
  refresh: 'pages/refresh/refresh',
}

/** The tab titles (each root page's navigation title is the same string). */
const TAB_TITLE_KEYS = {
  scenarios: 'CYLScenarioTabScenarios',
  animations: 'CYLScenarioTabAnimations',
  flows: 'CYLScenarioSectionFlows',
  feed: 'CYLScenarioTabFeed',
  refresh: 'CYLScenarioTabRefresh',
}

const ICONS = { scenarios: 'stack', animations: 'sparkles', flows: 'branch', feed: 'bubbles', refresh: 'refresh' }

function tabBarConfiguration() {
  return {
    CYLTabBarControllerContext: 'CYLScenarioExample',
    CYLTabBarControllerStyleType: 'default',
    CYLTabBarControllerTitlePositionAdjustment: '{0, -2}',
    CYLTabBarControllerThemes: {
      default: { CYLTabBarItemSelectedTitleColor: TEAL, CYLTabBarItemSelectedIconColor: TEAL },
    },
    CYLTabBarControllerTabBarItemsAttributes: Object.keys(TAB_PAGES).map((identifier) => ({
      CYLTabBarItemIdentifier: identifier,
      CYLTabBarItemTitle: t(TAB_TITLE_KEYS[identifier]),
      CYLTabBarItemAccessibilityLabel: t(TAB_TITLE_KEYS[identifier]),
      CYLTabBarItemImage: '/assets/tab/' + ICONS[identifier] + '.svg',
      CYLTabBarItemSelectedImage: '/assets/tab/' + ICONS[identifier] + '_selected.svg',
    })),
    CYLTabBarControllerPlusButton: {
      CYLTabBarItemIdentifier: 'plus',
      CYLTabBarItemImage: '/assets/tab/plus.svg',
      CYLTabBarItemAccessibilityLabel: t('CYLScenarioActionPublish'),
      CYLPlusButtonIndexInTabBar: 3,
      CYLPlusButtonSize: '{84, 84}',
      CYLPlusButtonImageSize: '{66, 66}',
      CYLPlusButtonCenterYOffset: -24,
    },
  }
}

module.exports = { TAB_PAGES, TAB_TITLE_KEYS, tabBarConfiguration, TEAL }
