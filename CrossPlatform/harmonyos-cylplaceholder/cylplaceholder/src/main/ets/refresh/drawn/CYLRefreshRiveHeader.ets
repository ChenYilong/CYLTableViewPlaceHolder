// CYLRefreshRiveHeader: the HarmonyOS counterpart of iOS RiveSwift/CYLRefreshRiveHeader.swift: a refresh header drawn
// by a Rive file, the counterpart of flutter_easy_refresh's Rive style packages (easy_refresh_bow, _bubbles,
// _halloween, _skating, _space, _squats; https://github.com/xuelongqy/flutter_easy_refresh, MIT). The packages drive
// their files in two ways, both covered by CYLRefreshRiveStyle: state machine inputs (a pull number, release / finish /
// restart triggers, a loading boolean or number) or linear animations (a pull animation scrubbed by time, a trigger
// animation, a loading loop, an idle loop). The .riv files belong to the example, not to the core.
// As a footer: CYLRefreshDrawnFooterModel.initWithStyle(new CYLRefreshRiveHeaderModel(style)).
//
// The model has no @ohos/rive dependency (host unit-tested): it drives a `CYLRefreshRiveDriver`, which
// `CYLRefreshRiveView` (CYLRefreshRiveView.ets) implements on a RiveAnimationView and attaches while it is shown.
import { CYLRefreshPhase, CYLRefreshScrollMode } from '../CYLRefreshConst';
import { CYLRefreshDrawnHeaderModel } from './CYLRefreshDrawnHeader';

/**
 * How a Rive file is driven by the pull, the refresh and its end (iOS `CYLRefreshRiveStyle`). Every name is
 * optional; unset (null) ones are skipped.
 */
export class CYLRefreshRiveStyle {
  /** The local .riv file: a rawfile path or a sandbox path (iOS `fileURL`). */
  readonly fileURL: string;
  /** The artboard; null uses the default artboard. */
  artboardName: string | null = null;
  /** The state machine that the inputs belong to. */
  stateMachineName: string | null = null;
  /** Pull distance (vp) that counts as fully pulled; also the header's open height. Default 180. */
  triggerOffset: number = 180;
  /** Smallest height the animation is laid out in while it grows with the pull; 0 uses `triggerOffset`. */
  minimumHeight: number = 0;
  /** true fits the artboard to the width (Rive fitWidth); false covers the area (Rive cover, default). */
  fitsWidth: boolean = false;
  /** Number input set from the pull. */
  pullInput: string | null = null;
  /** Value of `pullInput` just above no pull (flutter_easy_refresh bow: 10); no pull is always 0. Default 0. */
  pullInputMinimum: number = 0;
  /** Value of `pullInput` when fully pulled. Default 100. */
  pullInputMaximum: number = 100;
  /** Fraction of `triggerOffset` pulled before `pullInput` starts to rise (bubbles: 4/7). Default 0. */
  pullInputStart: number = 0;
  /** Value of `pullInput` while refreshing; a negative value (default) keeps `pullInputMaximum`. */
  pullInputRefreshingValue: number = -1;
  /** Trigger fired on release. */
  releaseTrigger: string | null = null;
  /** Trigger fired when the refresh ends. */
  finishTrigger: string | null = null;
  /** Trigger fired before the next pull, after the file was reset. */
  restartTrigger: string | null = null;
  /** Boolean input that is true from the release until the header is idle again. */
  loadingBoolean: string | null = null;
  /**
   * Number input that rises from 0 to `loadingNumberMaximum` over `loadingNumberDuration` while refreshing and is
   * set to `loadingNumberFinished` at the end.
   */
  loadingNumber: string | null = null;
  /** Top value of `loadingNumber` while refreshing. Default 99. */
  loadingNumberMaximum: number = 99;
  /** Value of `loadingNumber` when the refresh ends. Default 100. */
  loadingNumberFinished: number = 100;
  /** Seconds for `loadingNumber` to reach its top value. Default 2. */
  loadingNumberDuration: number = 2;
  /** Linear animation scrubbed by the pull: its time in seconds is the pulled fraction (0…1). */
  pullAnimation: string | null = null;
  /** Linear animation played once on release, before `loadingAnimation`. */
  triggerAnimation: string | null = null;
  /** Linear animation looped while refreshing. */
  loadingAnimation: string | null = null;
  /** Linear animation looped while pulling and idle. */
  idleAnimation: string | null = null;

  /** A style for the .riv file at `fileURL` (iOS `initWithFileURL:`). */
  constructor(fileURL: string) {
    this.fileURL = fileURL;
  }

  /** `pullInput` for a pull of `offset` vp. */
  pullValue(offset: number): number {
    const trigger = Math.max(1, this.triggerOffset);
    const start = trigger * Math.min(Math.max(this.pullInputStart, 0), 0.99);
    const progress = Math.min(Math.max((offset - start) / (trigger - start), 0), 1);
    if (progress === 0) {
      return 0;
    }
    return this.pullInputMinimum + progress * (this.pullInputMaximum - this.pullInputMinimum);
  }

  /** The time (seconds) `pullAnimation` shows for a pull of `offset` vp: the pulled fraction. */
  pullAnimationTime(offset: number): number {
    return Math.min(Math.max(offset / Math.max(1, this.triggerOffset), 0), 1);
  }

  /** `pullInput` while refreshing. */
  get refreshingPullValue(): number {
    return this.pullInputRefreshingValue >= 0 ? this.pullInputRefreshingValue : this.pullInputMaximum;
  }

  /** `loadingNumber` `seconds` after the release. */
  loadingNumberValue(seconds: number): number {
    const fraction = Math.min(Math.max(seconds, 0) / Math.max(0.01, this.loadingNumberDuration), 1);
    return fraction * this.loadingNumberMaximum;
  }

  /** The height the animation is laid out in for a header `height` high (bottom-aligned). */
  layoutHeight(height: number): number {
    const minimum = this.minimumHeight > 0 ? this.minimumHeight : this.triggerOffset;
    return Math.max(height, minimum);
  }
}

/** What plays a Rive file for a CYLRefreshRiveHeaderModel (iOS RiveViewModel calls). */
export interface CYLRefreshRiveDriver {
  /** setInput(_:value:) with a number. */
  setNumber(input: string, value: number): void;
  /** setInput(_:value:) with a boolean. */
  setBoolean(input: string, value: boolean): void;
  /** triggerInput(_:). */
  fire(trigger: string): void;
  /** play(animationName:loop:); null plays what is loaded. */
  play(animation: string | null, loop: boolean): void;
  /** Shows `animation` at `time` seconds without playing it. */
  scrub(animation: string, time: number): void;
  /** Seconds `animation` lasts (effectiveDurationInSeconds), or a negative value when unknown. */
  duration(animation: string): number;
  /** reset(): back to the file's first state. */
  reset(): void;
}

/**
 * A refresh header drawn by a Rive file (iOS `CYLRefreshRiveHeader`, flutter_easy_refresh's Rive styles). It grows
 * with the pull (stretch) and keeps the art laid out in at least `minimumHeight`, bottom-aligned.
 */
export class CYLRefreshRiveHeaderModel extends CYLRefreshDrawnHeaderModel {
  private styleValue: CYLRefreshRiveStyle | null = null;
  private driver: CYLRefreshRiveDriver | null = null;
  private loadingTimer: number = -1;
  private loadingStart: number = 0;
  private triggerTimer: number = -1;
  private rivePlaysRefresh: boolean = false;

  /** A header drawn by `style` (iOS `initWithStyle:`). */
  constructor(style: CYLRefreshRiveStyle | null = null) {
    super();
    if (style !== null) {
      this.install(style);
    }
  }

  /** A header drawn by `style` (iOS `initWithStyle:`). */
  static initWithStyle(style: CYLRefreshRiveStyle): CYLRefreshRiveHeaderModel {
    return new CYLRefreshRiveHeaderModel(style);
  }

  setUpComponent(): void {
    super.setUpComponent();
    this.scrollMode = CYLRefreshScrollMode.Stretch;
  }

  /** The style this header was made with (iOS `riveStyle`). */
  get riveStyle(): CYLRefreshRiveStyle | null {
    return this.styleValue;
  }

  /** Whether the release → idle part of the file is playing (no pull input meanwhile). */
  get cyl_rivePlaysRefresh(): boolean {
    return this.rivePlaysRefresh;
  }

  private install(style: CYLRefreshRiveStyle): void {
    this.styleValue = style;
    this.setExpandHeight(style.triggerOffset);
  }

  // MARK: - Driver

  /** The view's player is ready; a refresh that started before plays from its release. */
  cyl_attachDriver(driver: CYLRefreshRiveDriver): void {
    this.driver = driver;
    if (this.rivePlaysRefresh) {
      this.playRelease();
      if (this.status === CYLRefreshPhase.Finishing) {
        this.playFinish();
      }
    } else {
      this.onScrollingWithOffset(this.dragOffset, this.dragPercent, false);
    }
  }

  /** The view went away. */
  cyl_detachDriver(driver: CYLRefreshRiveDriver): void {
    if (this.driver === driver) {
      this.driver = null;
    }
  }

  // MARK: - Pull

  onScrollingWithOffset(offset: number, percent: number, isDragging: boolean): void {
    super.onScrollingWithOffset(offset, percent, isDragging);
    const style = this.styleValue;
    const driver = this.driver;
    if (style === null || driver === null || this.rivePlaysRefresh) {
      return;
    }
    if (style.pullInput !== null) {
      driver.setNumber(style.pullInput, style.pullValue(offset));
    }
    if (style.pullAnimation !== null && style.idleAnimation === null) {
      driver.scrub(style.pullAnimation, style.pullAnimationTime(offset));
    }
  }

  // MARK: - Status

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if (this.styleValue === null) {
      return;
    }
    switch (status) {
      case CYLRefreshPhase.Releasing:
        if (this.rivePlaysRefresh) {
          break;
        }
        this.rivePlaysRefresh = true;
        this.playRelease();
        break;
      case CYLRefreshPhase.Finishing:
        this.playFinish();
        break;
      case CYLRefreshPhase.Idle:
        if (!this.rivePlaysRefresh) {
          break;
        }
        this.rivePlaysRefresh = false;
        this.resetFile();
        break;
      default:
        break;
    }
  }

  private playRelease(): void {
    const style = this.styleValue;
    const driver = this.driver;
    if (style === null) {
      return;
    }
    if (style.loadingNumber !== null) {
      this.startLoadingNumber();
    }
    if (driver === null) {
      return;
    }
    if (style.pullInput !== null) {
      driver.setNumber(style.pullInput, style.refreshingPullValue);
    }
    if (style.releaseTrigger !== null) {
      driver.fire(style.releaseTrigger);
    }
    if (style.loadingBoolean !== null) {
      driver.setBoolean(style.loadingBoolean, true);
    }
    if (style.triggerAnimation !== null) {
      driver.play(style.triggerAnimation, false);
      const known = driver.duration(style.triggerAnimation);
      const duration = known >= 0 ? known : 0.5;
      this.cancelTrigger();
      this.triggerTimer = setTimeout(() => {
        this.triggerTimer = -1;
        const d = this.driver;
        if (this.rivePlaysRefresh && d !== null && style.loadingAnimation !== null) {
          d.play(style.loadingAnimation, true);
        }
      }, duration * 1000);
    } else if (style.loadingAnimation !== null) {
      driver.play(style.loadingAnimation, true);
    }
  }

  private playFinish(): void {
    const style = this.styleValue;
    if (style === null) {
      return;
    }
    this.stopLoadingNumber();
    const driver = this.driver;
    if (driver === null) {
      return;
    }
    if (style.loadingNumber !== null) {
      driver.setNumber(style.loadingNumber, style.loadingNumberFinished);
    }
    if (style.finishTrigger !== null) {
      driver.fire(style.finishTrigger);
    }
  }

  /** Back to the file's first state, as flutter_easy_refresh recreates the controller. */
  private resetFile(): void {
    this.stopLoadingNumber();
    this.cancelTrigger();
    const style = this.styleValue;
    const driver = this.driver;
    if (style === null || driver === null) {
      return;
    }
    driver.reset();
    if (style.loadingBoolean !== null) {
      driver.setBoolean(style.loadingBoolean, false);
    }
    if (style.pullInput !== null) {
      driver.setNumber(style.pullInput, 0);
    }
    if (style.loadingNumber !== null) {
      driver.setNumber(style.loadingNumber, 0);
    }
    if (style.restartTrigger !== null) {
      driver.fire(style.restartTrigger);
    }
    if (style.idleAnimation !== null) {
      driver.play(style.idleAnimation, true);
    } else if (style.pullAnimation !== null) {
      driver.scrub(style.pullAnimation, 0);
    } else {
      driver.play(null, false);
    }
  }

  private startLoadingNumber(): void {
    this.stopLoadingNumber();
    this.loadingStart = this.cyl_clock();
    this.loadingTimer = setInterval(() => {
      const style = this.styleValue;
      const driver = this.driver;
      if (style === null || style.loadingNumber === null || driver === null) {
        return;
      }
      driver.setNumber(style.loadingNumber, style.loadingNumberValue((this.cyl_clock() - this.loadingStart) / 1000));
    }, 1000 / 30);
  }

  private stopLoadingNumber(): void {
    if (this.loadingTimer >= 0) {
      clearInterval(this.loadingTimer);
      this.loadingTimer = -1;
    }
  }

  private cancelTrigger(): void {
    if (this.triggerTimer >= 0) {
      clearTimeout(this.triggerTimer);
      this.triggerTimer = -1;
    }
  }

  /** Decoration only: the drawn canvas is not used, the Rive view draws the header. */
  cyl_wantsFrame(): boolean {
    return false;
  }
}
