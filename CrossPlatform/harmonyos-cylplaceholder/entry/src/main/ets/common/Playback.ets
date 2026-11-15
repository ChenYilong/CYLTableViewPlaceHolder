// The animation playback controls every animation example has (docs/Example-Animation-Playback.md): "Play all"
// restarts every animation from progress 0, a speed slider (0.25x to 3x, steps of 0.25x) and a loop switch, all
// applied live and combinable. The texts are the example's own, in its seven languages.

/** The controls' texts by language (the example's languages: en, zh-Hans, zh-Hant, ja, ko, ru, uk). */
const PLAYBACK_STRINGS: Record<string, Record<string, string>> = {
  'en': { 'PlayAll': 'Play all', 'Speed': 'Speed', 'Loop': 'Loop' },
  'zh-Hans': { 'PlayAll': '全部播放', 'Speed': '倍速', 'Loop': '循环' },
  'zh-Hant': { 'PlayAll': '全部播放', 'Speed': '倍速', 'Loop': '循環' },
  'ja': { 'PlayAll': 'すべて再生', 'Speed': '速度', 'Loop': 'ループ' },
  'ko': { 'PlayAll': '모두 재생', 'Speed': '속도', 'Loop': '반복' },
  'ru': { 'PlayAll': 'Воспроизвести все', 'Speed': 'Скорость', 'Loop': 'Повтор' },
  'uk': { 'PlayAll': 'Відтворити все', 'Speed': 'Швидкість', 'Loop': 'Повтор' },
};

/** A playback text ("PlayAll", "Speed", "Loop") in a language, English when the language has none. */
export function playbackText(key: string, language: string): string {
  const table = PLAYBACK_STRINGS[language] !== undefined ? PLAYBACK_STRINGS[language] : PLAYBACK_STRINGS['en'];
  return table[key] !== undefined ? table[key] : PLAYBACK_STRINGS['en'][key];
}

/** "1x", "1.5x", "0.25x". */
export function speedLabel(speed: number): string {
  return `${Number(speed.toFixed(2))}x`;
}

/** The repeat count for the loop switch: 0 loops until stopped, 1 plays once and rests on the last frame. */
export function repeatCountForLoop(loop: boolean): number {
  return loop ? 0 : 1;
}

/** Whether a file is a spinner, which loops by default (one-shot demos do not). */
export function loopsByDefault(fileName: string): boolean {
  return /Loading|Spinner|Progress|Throbber|Activity|Ring|Dots|Cycle|Arc|Clockwise|Uploading|Infinity/.test(fileName);
}

@Component
export struct PlaybackControls {
  @Prop language: string = 'en';
  @Link speed: number;
  @Link loop: boolean;
  onPlayAll: () => void = () => {};
  onSpeed: (speed: number) => void = () => {};
  onLoop: (loop: boolean) => void = () => {};

  build() {
    Column({ space: 8 }) {
      Row({ space: 12 }) {
        Button(playbackText('PlayAll', this.language))
          .fontSize(15)
          .height(34)
          .backgroundColor('#0A84FF')
          .accessibilityText(playbackText('PlayAll', this.language))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .onClick(() => this.onPlayAll())
        Blank()
        Text(playbackText('Loop', this.language))
          .fontSize(15)
        Toggle({ type: ToggleType.Switch, isOn: this.loop })
          .accessibilityText(playbackText('Loop', this.language))
          .onChange((isOn: boolean) => {
            this.loop = isOn;
            this.onLoop(isOn);
          })
      }
      .width('100%')
      Row({ space: 8 }) {
        Text(playbackText('Speed', this.language))
          .fontSize(15)
        Slider({ value: this.speed, min: 0.25, max: 3, step: 0.25, style: SliderStyle.OutSet })
          .layoutWeight(1)
          .accessibilityText(playbackText('Speed', this.language))
          .accessibilityDescription(speedLabel(this.speed))
          .onChange((value: number) => {
            const rounded = Math.round(value * 4) / 4;
            if (rounded !== this.speed) {
              this.speed = rounded;
              this.onSpeed(rounded);
            }
          })
        Text(speedLabel(this.speed))
          .fontSize(15)
          .width(48)
          .textAlign(TextAlign.End)
      }
      .width('100%')
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .width('100%')
  }
}
