// CYLAnimationDetailViewController: one animation, 180 x 180, titled with its name; it replays every 4 seconds while
// visible and on "Replay". The animation and its title are one <cyl-animated-item> (Lottie, GIF; speed, loop and
// restart are its properties and restartAnimation()); PAG and Rive have no player in this example, so the page says so.
const { t, effectiveLanguage } = require('../../utils/l10n')
const { sections } = require('../animations/animation_list')

const UNSUPPORTED_NOTE = {
  pag: 'PAG files play in the iOS example (CYLTableViewPlaceHolder/PAG). The mini program has no PAG player.',
  riv: 'Rive files play in the iOS example (CYLTableViewPlaceHolder/Rive). The mini program has no Rive player.',
}

Page({
  data: { name: '', title: '', engine: '', path: '', note: '', replayTitle: '', language: '', speed: 1, loop: false },
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
    this.setData({ replayTitle: t('CYLScenarioActionReplay'), language: effectiveLanguage() })
    // Placeholder animations play once when they appear; replay them so the demo keeps moving (the loop switch on
    // loops them instead).
    this.timer = setInterval(() => { if (!this.data.loop) this.replay() }, 4000)
  },
  onHide() {
    clearInterval(this.timer)
  },
  // Playback controls (docs/Example-Animation-Playback.md): Play all from 0, live speed and loop.
  onPlayAll() {
    this.replay()
  },
  onSpeedChange(e) {
    this.setData({ speed: e.detail.speed })
  },
  onLoopChange(e) {
    this.setData({ loop: e.detail.loop })
  },
  onUnload() {
    clearInterval(this.timer)
  },
  replay() {
    if (!this.data.path) return
    const item = this.selectComponent('#item')
    if (item) item.restartAnimation()
  },
})
