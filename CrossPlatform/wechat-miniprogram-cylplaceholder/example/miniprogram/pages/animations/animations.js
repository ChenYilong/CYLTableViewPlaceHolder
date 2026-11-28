// CYLAnimationListViewController: every bundled animation grouped by engine, then the example bundle's own files.
// The list comes from animation_list.js (written by scripts/import-example-animations.js); "Sources" shows
// NOTICE.animations.
const { t } = require('../../utils/l10n')
const { showTab } = require('../../utils/page')
const { sections, noticePath } = require('./animation_list')

/** Like ByteCountFormatter (.file style): "981 bytes", "12 KB", "1.2 MB". */
function formatBytes(bytes) {
  if (bytes === 0) return 'Zero KB'
  if (bytes < 1000) return bytes === 1 ? '1 byte' : bytes + ' bytes'
  if (bytes < 1000 * 1000) return Math.round(bytes / 1000) + ' KB'
  return (bytes / 1000 / 1000).toFixed(1) + ' MB'
}

Page({
  data: { sections: [], sourcesTitle: '', emptyText: '' },
  onLoad() {
    this.setData({
      sections: sections.map((section) => ({
        title: section.title,
        files: section.files.map((file) => ({ name: file.name, size: formatBytes(file.bytes) })),
      })),
    })
  },
  onShow() {
    showTab(this, 'animations')
    // Texts again on every show: the language can change on another tab.
    this.setData({ sourcesTitle: t('CYLScenarioActionSources'), emptyText: t('CYLScenarioTextNoAnimations') })
  },
  showNotice() {
    wx.navigateTo({
      url: '/pages/text-file/text-file?path=' + encodeURIComponent(noticePath) +
        '&title=' + encodeURIComponent('NOTICE.animations'),
    })
  },
  openAnimation(e) {
    const { section, row } = e.currentTarget.dataset
    wx.navigateTo({ url: `/refresh-engines/animation-detail/animation-detail?section=${section}&row=${row}` })
  },
})
