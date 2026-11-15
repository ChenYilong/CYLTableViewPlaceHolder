// CYLAnimationDetailViewController: one animation, 180 x 180, titled with its name; it replays every 4 seconds while
// visible and on "Replay". Lottie plays in <cyl-lottie>, GIF in <image>; PAG and Rive have no player in the mini
// program, so the page says so instead.
const { t } = require('../../utils/l10n')
const { sections } = require('../animations/animation_list')

const UNSUPPORTED_NOTE = {
  pag: 'PAG files play in the iOS example (CYLTableViewPlaceHolder/PAG). The mini program has no PAG player.',
  riv: 'Rive files play in the iOS example (CYLTableViewPlaceHolder/Rive). The mini program has no Rive player.',
}

Page({
  data: { name: '', title: '', engine: '', path: '', note: '', replayTitle: '', showGif: true },
  onLoad(query) {
    const section = sections[Number(query.section)]
    const file = section && section.files[Number(query.row)]
    if (!file) return
    // The component title: the file name without extension, "CYLPlaceholder" and "CYLScenarioExample".
    const title = file.name.replace(/\.[^.]+$/, '').replace('CYLPlaceholder', '').replace('CYLScenarioExample', '')
    this.setData({
      name: file.name,
      title,
      engine: file.engine,
      path: file.path,
      note: file.path ? '' : UNSUPPORTED_NOTE[file.engine] || '',
    })
    wx.setNavigationBarTitle({ title: file.name })
  },
  onShow() {
    this.setData({ replayTitle: t('CYLScenarioActionReplay') })
    // Placeholder animations play once when they appear; replay them so the demo keeps moving.
    this.timer = setInterval(() => this.replay(), 4000)
  },
  onHide() {
    clearInterval(this.timer)
  },
  onUnload() {
    clearInterval(this.timer)
  },
  replay() {
    if (!this.data.path) return
    if (this.data.engine === 'json') {
      const player = this.selectComponent('#animation')
      if (player) player.cyl_playFromStart()
    } else if (this.data.engine === 'gif') {
      // An <image> restarts a GIF when it is created again.
      this.setData({ showGif: false }, () => this.setData({ showGif: true }))
    }
  },
})
