// CYLSupportViewController: the page "Contact support" opens, a stack of the support animation and the example's text.
const { t, effectiveLanguage } = require('../../utils/l10n')

Page({
  data: { components: [], language: '' },

  onLoad() {
    const title = t('CYLScenarioSupportTitle')
    wx.setNavigationBarTitle({ title })
    this.setData({
      language: effectiveLanguage(),
      components: [
        // CYLPlaceholderComponent(bundledAnimation: "CYLPlaceholderContactSupport.json", fallbackStyle: .help, 120×120)
        { type: 'icon', image: 'help', tinted: true, animation: 'CYLPlaceholderContactSupport.json', title, side: 120 },
        { type: 'hint', text: t('CYLScenarioSupportText') },
      ],
    })
  },
})
