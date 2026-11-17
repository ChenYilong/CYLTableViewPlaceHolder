// The example's engine (moved out of the cylplaceholder core on 2026-11-17: the core depends on no animation library,
// as CYLTabBarController's CYLAnimatedItem requires). ExampleAnimationEngines.ets registers it; an app copies it.
// iOS LottieSwift/CYLPlaceholderCompatibleLottie.swift: the lottie-ios 2 (LOTAnimationView) compatible API, played by
// @ohos/lottie (lottie-ohos, drawn on a Canvas). `CYLPlaceholderCompatibleLOTAnimation` reads and decodes the file
// synchronously like iOS `LottieAnimation.filepath`; `CYLPlaceholderCompatibleLOTAnimationView` is the observed model
// of the view, drawn by `CYLPlaceholderCompatibleLOTAnimationViewComponent({ view })`.
// Keypath colors: lottie-ohos recolors whole layers only, so `setColorValue` writes the color into the fills and
// strokes the keypath names (CYLPlaceholderCompatibleLottieSupport.ets) and reloads the animation at its frame.
import lottie, { AnimationItem } from '@ohos/lottie';
import { util } from '@kit.ArkTS';
import { CYLPlaceholderAnimationReadFileSync } from 'cylplaceholder';
import { CYLPlaceholderDrawingColor } from 'cylplaceholder';
import { CYLLottieContentMode } from './CYLLottiePlaceholderItemAnimator';
import {
  CYLCompatibleLOTCopyData,
  CYLCompatibleLOTDurationOfData,
  CYLCompatibleLOTLoopValue,
  CYLCompatibleLOTProgressOfFrame,
  CYLCompatibleLOTSetColor
} from 'cylplaceholder';

/** A Lottie animation read from a file (iOS `CYLPlaceholderCompatibleLOTAnimation`). */
export class CYLPlaceholderCompatibleLOTAnimation {
  /** The decoded JSON, or null. */
  readonly animationData: Object | null;
  readonly filepath: string;

  /** Reads and decodes the file at `filepath` (a sandbox path or a rawfile path) synchronously. */
  constructor(filepath: string, context: Context | null = null) {
    this.filepath = filepath;
    let data: Object | null = null;
    const bytes = CYLPlaceholderAnimationReadFileSync(filepath, context);
    if (bytes !== null) {
      try {
        const parsed = JSON.parse(util.TextDecoder.create('utf-8').decodeToString(bytes)) as Object;
        data = typeof parsed === 'object' && parsed !== null ? parsed : null;
      } catch (e) {
        data = null;
      }
    }
    this.animationData = data;
  }

  /** false when the file could not be read or decoded. */
  get isLoaded(): boolean {
    return this.animationData !== null;
  }
}

let compatibleNameCounter = 0;

/** A lottie-ios 2 style animation view (iOS `CYLPlaceholderCompatibleLOTAnimationView`); plays once by default. */
@Observed
export class CYLPlaceholderCompatibleLOTAnimationView {
  readonly renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  readonly context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  readonly name: string;
  private readonly originalData: Object | null;
  private item: AnimationItem | null = null;
  private canvasReady: boolean = false;
  private loopCount: number = 0;
  private contentModeValue: ImageFit = ImageFit.Contain;
  private speed: number = 1;
  /** The progress to show when the animation loads (or reloads), and whether it then plays. */
  private pendingProgress: number = 0;
  private pendingPlay: boolean = false;
  private appliedColors: Map<string, ResourceColor> = new Map<string, ResourceColor>();

  /** A view for the animation (iOS `init(compatibleAnimation:)`); an unloaded animation shows nothing. */
  constructor(compatibleAnimation: CYLPlaceholderCompatibleLOTAnimation) {
    this.originalData = compatibleAnimation.animationData;
    compatibleNameCounter++;
    this.name = 'cylplaceholder.compatibleLottie.' + compatibleNameCounter;
  }

  /** -1 loops forever, N plays N times; 0 (default) plays once. */
  get loopAnimationCount(): number {
    return this.loopCount;
  }

  set loopAnimationCount(value: number) {
    this.loopCount = value;
    if (this.item !== null) {
      this.item.loop = CYLCompatibleLOTLoopValue(value);
    }
  }

  /** How the animation fits the view; Contain (scale aspect fit) by default. */
  get contentMode(): ImageFit {
    return this.contentModeValue;
  }

  set contentMode(value: ImageFit) {
    this.contentModeValue = value;
    if (this.item !== null) {
      this.item.setContentMode(CYLLottieContentMode(value));
    }
  }

  /** The shown progress (0...1); setting it stops the animation at that progress. */
  get animationProgress(): number {
    return this.item !== null ? this.realtimeAnimationProgress : this.pendingProgress;
  }

  set animationProgress(value: number) {
    const progress = Math.min(1, Math.max(0, value));
    this.pendingPlay = false;
    if (this.item === null) {
      this.pendingProgress = progress;
      return;
    }
    this.item.goToAndStop(progress * this.lastFrame(), true);
  }

  /** Seconds the animation lasts, 0 without one. */
  get duration(): number {
    return CYLCompatibleLOTDurationOfData(this.originalData);
  }

  /** The progress being drawn now. */
  get realtimeAnimationProgress(): number {
    if (this.item === null) {
      return this.pendingProgress;
    }
    return CYLCompatibleLOTProgressOfFrame(this.item.currentFrame, this.item.totalFrames);
  }

  /** Playback speed, 1 by default. */
  get animationSpeed(): number {
    return this.speed;
  }

  set animationSpeed(value: number) {
    this.speed = value;
    if (this.item !== null) {
      this.item.setSpeed(value);
    }
  }

  get isAnimationPlaying(): boolean {
    return this.item !== null ? !this.item.isPaused : this.pendingPlay;
  }

  /** Plays from the current progress (from the start once it reached the end). */
  play(): void {
    if (this.item === null) {
      this.pendingPlay = this.originalData !== null;
      return;
    }
    this.item.loop = CYLCompatibleLOTLoopValue(this.loopCount);
    this.item.playCount = 0;
    if (this.item.currentFrame >= this.lastFrame()) {
      this.item.goToAndPlay(0, true);
    } else {
      this.item.play();
    }
  }

  /** Stops and goes back to the start. */
  stop(): void {
    this.pendingPlay = false;
    this.pendingProgress = 0;
    if (this.item !== null) {
      this.item.goToAndStop(0, true);
    }
  }

  /** Pauses at the current progress. */
  pause(): void {
    this.pendingPlay = false;
    if (this.item !== null) {
      this.pendingProgress = this.realtimeAnimationProgress;
      this.item.pause();
    }
  }

  /** Redraws the current frame. */
  forceDrawingUpdate(): void {
    if (this.item === null) {
      return;
    }
    if (this.item.isPaused) {
      this.item.goToAndStop(this.item.currentFrame, true);
    } else {
      this.item.resize();
    }
  }

  /** Sets a color for a keypath string, e.g. "Icon.**.Color" (fills and strokes the keypath names). */
  setColorValue(color: ResourceColor, keypath: string): void {
    this.appliedColors.set(keypath, color);
    this.reload();
  }

  /** Removes the color set for `keypath`, restoring the animation's own value. */
  removeValueProvider(keypath: string): void {
    if (this.appliedColors.delete(keypath)) {
      this.reload();
    }
  }

  /** The color overrides currently set, by keypath (test probe). */
  get cyl_appliedColors(): Map<string, ResourceColor> {
    return this.appliedColors;
  }

  /** The data drawn: the file's, with the keypath colors written in. */
  cyl_renderedData(): Object | null {
    if (this.originalData === null) {
      return null;
    }
    if (this.appliedColors.size === 0) {
      return this.originalData;
    }
    const data = CYLCompatibleLOTCopyData(this.originalData);
    this.appliedColors.forEach((color: ResourceColor, keypath: string) => {
      const c = CYLPlaceholderDrawingColor(color);
      if (c !== null) {
        CYLCompatibleLOTSetColor(data, keypath, c.red / 255, c.green / 255, c.blue / 255, c.alpha / 255);
      }
    });
    return data;
  }

  // MARK: Canvas

  /** The Canvas is laid out. */
  onCanvasReady(): void {
    this.canvasReady = true;
    if (this.item !== null) {
      this.item.resize();
      return;
    }
    this.context2D.imageSmoothingEnabled = true;
    this.context2D.imageSmoothingQuality = 'medium';
    this.load();
  }

  /** The Canvas went away. */
  onCanvasDisappear(): void {
    if (this.item !== null) {
      this.pendingPlay = !this.item.isPaused;
      this.pendingProgress = this.realtimeAnimationProgress;
    }
    this.canvasReady = false;
    this.destroyItem();
  }

  private lastFrame(): number {
    return this.item !== null ? Math.max(0, this.item.totalFrames - 1) : 0;
  }

  private destroyItem(): void {
    if (this.item !== null) {
      lottie.destroy(this.name);
      this.item = null;
    }
  }

  /** Loads the data again (new colors), keeping the progress and playback. */
  private reload(): void {
    if (this.item === null) {
      return;
    }
    this.pendingPlay = !this.item.isPaused;
    this.pendingProgress = this.realtimeAnimationProgress;
    this.destroyItem();
    this.load();
  }

  private load(): void {
    const data = this.cyl_renderedData();
    if (!this.canvasReady || data === null || this.item !== null) {
      return;
    }
    try {
      lottie.destroy(this.name);
      const item = lottie.loadAnimation({
        container: this.context2D,
        renderer: 'canvas',
        loop: CYLCompatibleLOTLoopValue(this.loopCount),
        autoplay: false,
        name: this.name,
        contentMode: CYLLottieContentMode(this.contentModeValue),
        animationData: data
      });
      this.item = item;
      item.addEventListener('DOMLoaded', () => {
        if (this.item !== item) {
          return;
        }
        item.setSpeed(this.speed);
        const frame = this.pendingProgress * this.lastFrame();
        if (this.pendingPlay) {
          this.pendingPlay = false;
          item.goToAndPlay(frame, true);
        } else {
          item.goToAndStop(frame, true);
        }
      });
    } catch (e) {
      this.item = null;
    }
  }
}

/** Draws a CYLPlaceholderCompatibleLOTAnimationView, filling its frame. */
@Component
export struct CYLPlaceholderCompatibleLOTAnimationViewComponent {
  @ObjectLink view: CYLPlaceholderCompatibleLOTAnimationView;

  aboutToDisappear(): void {
    this.view.onCanvasDisappear();
  }

  build() {
    Canvas(this.view.context2D)
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
      .onReady(() => {
        this.view.onCanvasReady();
      })
  }
}
