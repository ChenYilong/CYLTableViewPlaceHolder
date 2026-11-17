// Rive state machine inputs as placeholders, one demo per input kind, like the iOS Rive Home page
// (CYLRiveRoomsViewController). Each demo is a CYLAnimatedItemView playing a Rive file through the example's
// CYLRivePlaceholderItemAnimator, with the Rive options in the animation URL:
// - Number: house.riv, "State Machine 1", numberInput=Rooms, values=3,4,5,6: each play sets the next value. The
//   picker and the slider set Rooms by hand (one play per step); Loop plays every 1.5 s and the label follows.
// - Boolean: Space Reload, "Reload", input=Start: each play sets Start false, then true 50 ms later.
// - Trigger: Skating, "Reload", triggerInput=pullRelease: each play resets the state machine and fires pullRelease
//   (Bow's advance needs its pull input first: alone it leaves the scene closed, 2026-11-18).
// "Play all" plays the selected demo once; Loop plays it again every 1.5 s.
import {
  CYLAnimatedItemAxis,
  CYLAnimatedItemView,
  CYLPlaceholderAnimatedItem,
  CYLPlaceholderAnimatedItemBuilder,
  CYLPlaceholderAnimationOptionRiveInput,
  CYLPlaceholderAnimationOptionRiveNumberInput,
  CYLPlaceholderAnimationOptionRiveNumberValues,
  CYLPlaceholderAnimationOptionRiveStateMachine,
  CYLPlaceholderAnimationOptionRiveTriggerInput,
  CYLPlaceholderAnimationURLWithOptions,
  CYLPlaceholderComponent,
  CYLPlaceholderStyle,
  CYLPlaceholderViewModel
} from 'cylplaceholder';
import { effectiveLanguage, t } from '../common/L10n';
import { playbackText } from '../common/Playback';
import { RouteParam } from '../common/Routes';
import { NavTitle, UiColor } from '../common/Ui';

const ANIMATIONS = 'example/animations/';
const ROOMS: number[] = [3, 4, 5, 6];
const LOOP_MS = 1500;

/** One input kind: its tab title, file, Rive options and hint. */
class CYLRiveInputDemo {
  key: string;
  titleKey: string;
  file: string;
  options: Record<string, string>;
  hintKey: string;

  constructor(key: string, titleKey: string, file: string, options: Record<string, string>, hintKey: string) {
    this.key = key;
    this.titleKey = titleKey;
    this.file = file;
    this.options = options;
    this.hintKey = hintKey;
  }
}

function numberOptions(): Record<string, string> {
  const o: Record<string, string> = {};
  o[CYLPlaceholderAnimationOptionRiveStateMachine] = 'State Machine 1';
  o[CYLPlaceholderAnimationOptionRiveNumberInput] = 'Rooms';
  o[CYLPlaceholderAnimationOptionRiveNumberValues] = ROOMS.join(',');
  return o;
}

function booleanOptions(): Record<string, string> {
  const o: Record<string, string> = {};
  o[CYLPlaceholderAnimationOptionRiveStateMachine] = 'Reload';
  o[CYLPlaceholderAnimationOptionRiveInput] = 'Start';
  return o;
}

function triggerOptions(): Record<string, string> {
  const o: Record<string, string> = {};
  o[CYLPlaceholderAnimationOptionRiveStateMachine] = 'Reload';
  o[CYLPlaceholderAnimationOptionRiveTriggerInput] = 'pullRelease';
  return o;
}

const DEMOS: CYLRiveInputDemo[] = [
  new CYLRiveInputDemo('number', 'CYLScenarioRiveInputsKindNumber', 'CYLScenarioExampleHouse.riv', numberOptions(),
    'CYLScenarioRiveRoomsHint'),
  new CYLRiveInputDemo('boolean', 'CYLScenarioRiveInputsKindBoolean', 'CYLScenarioExampleRefreshSpace.riv',
    booleanOptions(), 'CYLScenarioRiveInputsHintBoolean'),
  new CYLRiveInputDemo('trigger', 'CYLScenarioRiveInputsKindTrigger', 'CYLScenarioExampleRefreshSkating.riv',
    triggerOptions(), 'CYLScenarioRiveInputsHintTrigger')
];

@Component
export struct RiveInputsPage {
  param: RouteParam = new RouteParam();
  @State demoIndex: number = 0;
  @State item: CYLPlaceholderViewModel = new CYLPlaceholderViewModel();
  @State animationURL: string = '';
  @State itemTitle: string = '';
  /**
   * The number demo's Rooms as last set by a play; -1 before the first play: the file shows its own value, which is
   * none of 3, 4, 5, 6, so the first play sets 3 (CYLRiveNextNumber starts the list for an unknown value).
   */
  @State rooms: number = -1;
  @State loop: boolean = false;
  /** Plays of the selected demo since it was shown (the boolean and trigger demos show it). */
  @State plays: number = 0;
  private loopTimer: number = -1;

  aboutToAppear(): void {
    this.show(0);
  }

  aboutToDisappear(): void {
    this.stopLoop();
    CYLPlaceholderAnimatedItem.detach(this.item);
  }

  /** Shows a demo: a new model for its file and options, not played until asked (a play sets the next value). */
  private show(index: number): void {
    this.stopLoop();
    this.loop = false;
    CYLPlaceholderAnimatedItem.detach(this.item);
    const demo = DEMOS[index];
    this.demoIndex = index;
    this.rooms = -1;
    this.plays = 0;
    this.itemTitle = demo.key === 'number' ? t('CYLScenarioRiveRoomsPlaceholder') : t(demo.titleKey);
    const path = CYLPlaceholderAnimationURLWithOptions(ANIMATIONS + demo.file, demo.options);
    const model = CYLPlaceholderViewModel.initWithComponent(
      CYLPlaceholderComponent.componentWithBundledAnimation(path, CYLPlaceholderStyle.Image, this.itemTitle, 220, null));
    model.animationRepeatCount = 1;
    this.item = model;
    CYLPlaceholderAnimatedItem.attach(model);
    // No play on appearing: the file shows its own state until the first play.
    model.stopPlaceholderAnimation();
    this.animationURL = CYLPlaceholderAnimatedItem.animationURL(model);
  }

  /** One play: the number demo steps to the next Rooms, the others restart and drive their input. */
  private playOnce(): void {
    this.item.playPlaceholderAnimation();
    this.plays += 1;
    if (DEMOS[this.demoIndex].key === 'number') {
      const at = ROOMS.indexOf(this.rooms);
      this.rooms = at < 0 ? ROOMS[0] : ROOMS[(at + 1) % ROOMS.length];
    }
  }

  /** Sets Rooms by hand: one play per step, since each play sets the next of 3, 4, 5, 6 (as on iOS). */
  private setRooms(value: number): void {
    const from = ROOMS.indexOf(this.rooms);
    const to = ROOMS.indexOf(value);
    if (to < 0) {
      return;
    }
    // Before the first play the next play sets 3: index + 1 plays reach the value.
    const steps = from < 0 ? to + 1 : (to - from + ROOMS.length) % ROOMS.length;
    for (let i = 0; i < steps; i++) {
      this.playOnce();
    }
  }

  private applyLoop(on: boolean): void {
    this.loop = on;
    this.stopLoop();
    if (on) {
      this.playOnce();
      this.loopTimer = setInterval(() => this.playOnce(), LOOP_MS);
    }
  }

  private stopLoop(): void {
    if (this.loopTimer >= 0) {
      clearInterval(this.loopTimer);
      this.loopTimer = -1;
    }
  }

  @Builder
  navTitle() {
    NavTitle(t('CYLScenarioRiveInputsTitle'))
  }

  @Builder
  kindPicker() {
    Row() {
      ForEach(DEMOS, (demo: CYLRiveInputDemo, index: number) => {
        Text(t(demo.titleKey))
          .fontSize(13)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .minFontSize(9)
          .maxFontSize(13)
          .layoutWeight(1)
          .height(28)
          .borderRadius(7)
          .backgroundColor(index === this.demoIndex ? UiColor.segmentSelected : Color.Transparent)
          .accessibilityText(t(demo.titleKey))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .onClick(() => this.show(index))
      }, (demo: CYLRiveInputDemo) => demo.key)
    }
    .id('riveInputKind')
    .padding(2)
    .borderRadius(9)
    .backgroundColor(UiColor.segmentBackground)
    .width('100%')
  }

  @Builder
  roomsPicker() {
    Row() {
      ForEach(ROOMS, (value: number) => {
        Text(String(value))
          .fontSize(13)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(28)
          .borderRadius(7)
          .backgroundColor(value === this.rooms ? UiColor.segmentSelected : Color.Transparent)
          .onClick(() => this.setRooms(value))
      }, (value: number) => String(value))
    }
    .id('riveRoomsPicker')
    .accessibilityText(t('CYLScenarioRiveRoomsPicker'))
    .padding(2)
    .borderRadius(9)
    .backgroundColor(UiColor.segmentBackground)
    .width('100%')
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          this.kindPicker()
          Column() {
            CYLAnimatedItemView({
              itemTitle: this.itemTitle,
              image: this.item.currentImage !== null ? this.item.currentImage as ResourceStr : '',
              animationUrl: this.animationURL,
              axis: CYLAnimatedItemAxis.Vertical,
              iconSize: 220,
              spacing: 8,
              titleFontSize: this.item.currentTitleFont,
              titleColor: this.item.currentTitleColor,
              animationBuilder: CYLPlaceholderAnimatedItemBuilder
            })
          }
          .width('100%')
          .height(300)
          .justifyContent(FlexAlign.Center)
          if (DEMOS[this.demoIndex].key === 'number') {
            Text(t('CYLScenarioRiveRoomsValue', this.rooms < 0 ? '–' : String(this.rooms)))
              .id('riveRoomsValue')
              .fontSize(28)
              .textAlign(TextAlign.Center)
              .width('100%')
            this.roomsPicker()
            Slider({ value: this.rooms < 0 ? ROOMS[0] : this.rooms, min: ROOMS[0], max: ROOMS[ROOMS.length - 1], step: 1 })
              .id('riveRoomsSlider')
              .accessibilityText(t('CYLScenarioRiveRoomsSlider'))
              .width('100%')
              .onChange((value: number, mode: SliderChangeMode) => {
                if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
                  this.setRooms(Math.round(value));
                }
              })
          } else {
            Text(t('CYLScenarioRiveInputsPlays', String(this.plays)))
              .id('riveInputPlays')
              .fontSize(28)
              .textAlign(TextAlign.Center)
              .width('100%')
          }
          Row() {
            Button(playbackText('PlayAll', effectiveLanguage()))
              .id('riveInputPlay')
              .onClick(() => this.playOnce())
            Blank()
            Text(t('CYLScenarioRiveRoomsLoop'))
              .fontSize(17)
              .accessibilityLevel('no')
            Toggle({ type: ToggleType.Switch, isOn: this.loop })
              .id('riveInputLoop')
              .accessibilityText(t('CYLScenarioRiveRoomsLoop'))
              .onChange((on: boolean) => {
                if (on !== this.loop) {
                  this.applyLoop(on);
                }
              })
          }
          .width('100%')
          Text(t(DEMOS[this.demoIndex].hintKey))
            .fontSize(13)
            .fontColor(UiColor.gray)
            .width('100%')
        }
        .padding({ left: 20, right: 20, top: 8, bottom: 16 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
    }
    .title(this.navTitle)
    .backgroundColor(UiColor.background)
  }
}
