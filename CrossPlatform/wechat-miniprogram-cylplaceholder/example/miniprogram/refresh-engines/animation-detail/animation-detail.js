// CYLAnimationDetailViewController: one animation, 180 x 180, titled with its name; it replays every 4 seconds while
// visible and on "Replay". The animation and its title are one <cyl-animated-item> (Lottie, GIF; speed, loop and
// restart are its properties and restartAnimation()); SVGA plays through cyl-svga (cyl-svga-view), PAG and Rive
// through cyl-pag and cyl-rive (cyl-pag-view, cyl-rive-view), which live in this page's refresh-engines/ subpackage.
const { t, effectiveLanguage } = require('../../utils/l10n')
const { sections } = require('../../pages/animations/animation_list')

Page({
  data: { name: '', title: '', engine: '', path: '', dark: false, replayTitle: '', language: '', speed: 1, loop: false },
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
      // CYLScenarioExampleMoonlight.pag is white artwork made for a black composition background that libpag does not
      // draw: a black backdrop and a white title, as on iOS, Android and HarmonyOS (docs/Task-Log.md, "Moonlight.pag").
      dark: file.name === 'CYLScenarioExampleMoonlight.pag',
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
