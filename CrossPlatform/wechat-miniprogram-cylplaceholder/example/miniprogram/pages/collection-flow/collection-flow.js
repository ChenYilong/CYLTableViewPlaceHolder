// CYLCollectionFlowViewController: a grid (104 x 104 items, spacing 8, insets 12) with the NoFavorites placeholder
// while it is empty (block API, issue #11). "Add" toggles 0 / 18 items and becomes "Clear".
const { t } = require('../../utils/l10n')

/** UIColor(hue:saturation:brightness:) as a #rrggbb string. */
function hsb(h, s, v) {
  const i = Math.floor(h * 6)
  const f = h * 6 - i
  const p = v * (1 - s)
  const q = v * (1 - f * s)
  const u = v * (1 - (1 - f) * s)
  const [r, g, b] = [[v, u, p], [q, v, p], [p, v, u], [p, q, v], [u, p, v], [v, p, q]][i % 6]
  return '#' + [r, g, b].map((c) => ('0' + Math.round(c * 255).toString(16)).slice(-2)).join('')
}

Page({
  data: { items: [], buttonTitle: '' },
  onLoad() {
    wx.setNavigationBarTitle({ title: t('CYLScenarioTitleCollection') })
    this.setData({ buttonTitle: t('CYLScenarioActionAdd') })
  },
  toggleItems() {
    const count = this.data.items.length > 0 ? 0 : 18
    const items = []
    for (let i = 0; i < count; i++) items.push({ id: i, color: hsb((i % 12) / 12, 0.35, 0.95) })
    this.setData({ items, buttonTitle: t(count > 0 ? 'CYLScenarioActionClear' : 'CYLScenarioActionAdd') })
  },
})
