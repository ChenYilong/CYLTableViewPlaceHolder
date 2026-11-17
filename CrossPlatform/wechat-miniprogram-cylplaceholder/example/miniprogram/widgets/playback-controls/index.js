// The animation playback controls every animation page of the example has (docs/Example-Animation-Playback.md,
// instructions.md "Animation playback controls in examples"), as HarmonyOS common/Playback.ets: "Play all" restarts
// every animation from progress 0, a speed slider (0.25x to 3x in steps of 0.25x, default 1x) and a loop switch, all
// applied live by the page. The texts are the example's own, in its seven languages.
// Events: playall, speedchange { speed }, loopchange { loop }.
const STRINGS = {
  'en': { playAll: 'Play all', speed: 'Speed', loop: 'Loop' },
  'zh-Hans': { playAll: '全部播放', speed: '倍速', loop: '循环' },
  'zh-Hant': { playAll: '全部播放', speed: '倍速', loop: '循環' },
  'ja': { playAll: 'すべて再生', speed: '速度', loop: 'ループ' },
  'ko': { playAll: '모두 재생', speed: '속도', loop: '반복' },
  'ru': { playAll: 'Воспроизвести все', speed: 'Скорость', loop: 'Повтор' },
  'uk': { playAll: 'Відтворити все', speed: 'Швидкість', loop: 'Повтор' },
}

/** "1x", "1.5x", "0.25x". */
function speedLabel(speed) {
  return `${Number(Number(speed).toFixed(2))}x`
}

Component({
  properties: {
    /** The example's language (utils/l10n effectiveLanguage()). */
    language: { type: String, value: 'en' },
    speed: { type: Number, value: 1 },
    loop: { type: Boolean, value: false },
  },
  data: { texts: STRINGS.en, speedText: '1x' },
  observers: {
    language(language) {
      this.setData({ texts: STRINGS[language] || STRINGS.en })
    },
    speed(speed) {
      this.setData({ speedText: speedLabel(speed) })
    },
  },
  methods: {
    onPlayAll() {
      this.triggerEvent('playall', {})
    },
    onSpeed(e) {
      const speed = Number(e.detail.value)
      this.setData({ speedText: speedLabel(speed) })
      this.triggerEvent('speedchange', { speed })
    },
    onLoop(e) {
      this.triggerEvent('loopchange', { loop: !!e.detail.value })
    },
  },
})

