// iOS CYLLottiePlaceholderItemAnimator: plays Lottie JSON files with @ohos/lottie (lottie-ohos, drawn on a Canvas),
// looked up last (fallback priority), for ".json" and ".lottie" files. Kotlin: CYLLottiePlaceholderItemAnimator.
import lottie, { AnimationItem } from '@ohos/lottie';
import { util } from '@kit.ArkTS';
import {
  CYLPlaceholderAnimationColors,
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationReadFile,
  CYLPlaceholderItemAnimationBasePlayer,
  CYLPlaceholderItemAnimationPlayer,
  CYLPlaceholderItemAnimator,
  CYLPlaceholderItemAnimatorPriority,
  CYLPlaceholderItemAnimatorPriorityFallback,
  CYLPlaceholderAnimationExtensionOfURL,
  CYLPlaceholderAnimationOptionsOfURL,
  CYLPlaceholderPlayableContentView
} from './CYLPlaceholderAnimation';
import { CYLPlaceholderDrawingColor } from './CYLPlaceholderView';
import {
  CYLPlaceholderItemAnimationDarkColors,
  CYLPlaceholderItemAnimationDarkFilePath,
  CYLPlaceholderItemAnimationDarkURL,
  CYLPlaceholderItemAnimationFilePath,
  CYLPlaceholderItemAnimationSize,
  CYLPlaceholderItemAnimationURL,
  CYLPlaceholderItemLottieDarkColors,
  CYLPlaceholderItemLottieDarkFilePath,
  CYLPlaceholderItemLottieDarkURL,
  CYLPlaceholderItemLottieFilePath,
  CYLPlaceholderItemLottieSize,
  CYLPlaceholderItemLottieURL
} from './CYLPlaceholderViewTypes';

/** lottie's `loop` for a repeat count: 0 loops (true), 1 plays once (false), N plays N times (N - 1 more loops). */
export function CYLLottieLoopValue(repeatCount: number): boolean | number {
  if (repeatCount <= 0) {
    return true;
  }
  return repeatCount === 1 ? false : Math.floor(repeatCount) - 1;
}

/** lottie's contentMode for an ImageFit. */
export function CYLLottieContentMode(fit: ImageFit): string {
  if (fit === ImageFit.Cover) {
    return 'Cover';
  }
  if (fit === ImageFit.Fill) {
    return 'Fill';
  }
  return 'Contain';
}

let lottieNameCounter = 0;

/** A Lottie animation drawn on a Canvas. */
@Observed
export class CYLLottieAnimationContentView extends CYLPlaceholderPlayableContentView {
  readonly renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  readonly context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  readonly name: string;
  speed: number = 1;
  /** Seek requested before the load finished. */
  pendingProgress: number = -1;
  private item: AnimationItem | null = null;
  private data: Object | null = null;
  private canvasReady: boolean = false;
  private colors: CYLPlaceholderAnimationColors | null = null;

  constructor(fileURL: string, options: Record<string, string>, contentMode: ImageFit) {
    super();
    this.fileURL = fileURL;
    this.options = options;
    this.contentMode = contentMode;
    lottieNameCounter++;
    this.name = 'cylplaceholder.lottie.' + lottieNameCounter;
    this.builder = wrapBuilder(lottieContentBuilder);
  }

  cyl_attach(context: Context | null): void {
    if (this.data !== null || this.loading || this.failed) {
      return;
    }
    this.loading = true;
    CYLPlaceholderAnimationReadFile(this.fileURL, context).then((bytes: Uint8Array) => {
      const text = util.TextDecoder.create('utf-8').decodeToString(bytes);
      this.data = JSON.parse(text) as Object;
      this.loadIfPossible();
    }).catch((e: Error) => {
      this.didFail('Lottie', e);
    });
  }

  /** The Canvas is laid out. */
  onCanvasReady(): void {
    this.canvasReady = true;
    if (this.item !== null) {
      this.item.resize();
      return;
    }
    this.context2D.imageSmoothingEnabled = true;
    this.context2D.imageSmoothingQuality = 'medium';
    this.loadIfPossible();
  }

  cyl_detach(): void {
    this.canvasReady = false;
    this.destroyItem();
  }

  private destroyItem(): void {
    if (this.item !== null) {
      lottie.destroy(this.name);
      this.item = null;
    }
    this.cyl_isAnimationViewReady = false;
  }

  private loadIfPossible(): void {
    if (this.item !== null || this.data === null || !this.canvasReady) {
      return;
    }
    try {
      lottie.destroy(this.name);
      const item = lottie.loadAnimation({
        container: this.context2D,
        renderer: 'canvas',
        loop: CYLLottieLoopValue(this.repeatCount),
        autoplay: false,
        name: this.name,
        contentMode: CYLLottieContentMode(this.contentMode),
        animationData: this.data
      });
      this.item = item;
      item.addEventListener('DOMLoaded', () => {
        if (this.item !== item) {
          return;
        }
        item.setSpeed(this.speed);
        this.applyColorsToItem();
        if (this.pendingProgress >= 0) {
          this.seek(this.pendingProgress);
          this.pendingProgress = -1;
        } else {
          item.goToAndStop(0, true);
        }
        this.didLoad();
      });
      item.addEventListener('data_failed', () => {
        this.didFail('Lottie', null);
      });
    } catch (e) {
      this.didFail('Lottie', e as Error);
    }
  }

  private lastFrame(): number {
    return this.item !== null ? Math.max(0, this.item.totalFrames - 1) : 0;
  }

  seek(progress: number): void {
    if (this.item === null || !this.cyl_isAnimationViewReady) {
      this.pendingProgress = progress;
      return;
    }
    this.item.goToAndStop(progress * this.lastFrame(), true);
  }

  get currentProgress(): number {
    if (this.item === null || this.lastFrame() <= 0) {
      return 0;
    }
    return Math.min(1, Math.max(0, this.item.currentFrame / this.lastFrame()));
  }

  setSpeed(speed: number): void {
    this.speed = speed;
    if (this.item !== null) {
      this.item.setSpeed(speed);
    }
  }

  cyl_playAnimationView(): void {
    if (this.item === null || !this.cyl_isAnimationViewReady) {
      this.pendingCommand = 1;
      return;
    }
    this.item.loop = CYLLottieLoopValue(this.repeatCount);
    this.item.playCount = 0;
    this.item.goToAndPlay(0, true);
  }

  cyl_showAnimationViewLastFrame(): void {
    if (this.item === null || !this.cyl_isAnimationViewReady) {
      this.pendingCommand = 2;
      return;
    }
    this.item.goToAndStop(this.lastFrame(), true);
  }

  cyl_stopAnimationView(): void {
    this.pendingCommand = 0;
    if (this.item !== null && this.cyl_isAnimationViewReady) {
      this.item.goToAndStop(0, true);
    }
  }

  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    this.repeatCount = Math.max(0, Math.floor(repeatCount));
    if (this.item !== null) {
      this.item.loop = CYLLottieLoopValue(this.repeatCount);
    }
    return true;
  }

  /** lottie-ohos recolors whole layers, not key paths: the first color paints every layer (as Android does). */
  cyl_applyAnimationViewColors(colors: CYLPlaceholderAnimationColors | null): void {
    const hadColors = this.colors !== null;
    this.colors = colors !== null && Object.keys(colors).length > 0 ? colors : null;
    if (this.item === null) {
      return;
    }
    if (this.colors === null && hadColors) {
      // Restoring the file's colors: load the animation again.
      const playing = !this.item.isPaused;
      this.destroyItem();
      if (playing) {
        this.pendingCommand = 1;
      }
      this.loadIfPossible();
      return;
    }
    this.applyColorsToItem();
  }

  private applyColorsToItem(): void {
    const colors = this.colors;
    if (this.item === null || colors === null) {
      return;
    }
    const keys = Object.keys(colors);
    const color = CYLPlaceholderDrawingColor(colors[keys[0]]);
    if (color !== null) {
      this.item.changeColor([color.red, color.green, color.blue, color.alpha / 255]);
    }
  }
}

@Component
struct CYLLottieAnimationComponent {
  @ObjectLink view: CYLLottieAnimationContentView;

  build() {
    Canvas(this.view.context2D)
      .width(this.view.width)
      .height(this.view.height)
      .onReady(() => {
        this.view.onCanvasReady();
      })
  }
}

@Builder
function lottieContentBuilder(view: CYLPlaceholderAnimationContentView) {
  CYLLottieAnimationComponent({ view: view as CYLLottieAnimationContentView })
}

/** The Lottie player: play, last frame, stop, progress, speed, repeat counts and colors. */
class CYLLottiePlaceholderItemAnimationPlayer extends CYLPlaceholderItemAnimationBasePlayer {
  private lottieView: CYLLottieAnimationContentView;

  constructor(view: CYLLottieAnimationContentView) {
    super(view);
    this.lottieView = view;
  }

  play(): void {
    this.lottieView.cyl_playAnimationView();
  }

  showLastFrame(): void {
    this.lottieView.cyl_showAnimationViewLastFrame();
  }

  stop(): void {
    this.lottieView.cyl_stopAnimationView();
  }

  get progress(): number {
    return this.lottieView.currentProgress;
  }

  set progress(value: number) {
    this.lottieView.seek(Math.min(1, Math.max(0, value)));
  }

  get animationSpeed(): number {
    return this.lottieView.speed;
  }

  set animationSpeed(value: number) {
    this.lottieView.setSpeed(value);
  }

  get supportsProgress(): boolean {
    return true;
  }

  get supportsAnimationSpeed(): boolean {
    return true;
  }

  setAnimationRepeatCount(repeatCount: number): boolean {
    return this.lottieView.cyl_setAnimationViewRepeatCount(repeatCount);
  }

  applyColors(colors: CYLPlaceholderAnimationColors | null, dark: boolean): void {
    this.lottieView.cyl_applyAnimationViewColors(colors);
  }
}

function lottieAttributeKeys(): Record<string, string> {
  const keys: Record<string, string> = {};
  keys[CYLPlaceholderItemAnimationURL] = CYLPlaceholderItemLottieURL;
  keys[CYLPlaceholderItemAnimationFilePath] = CYLPlaceholderItemLottieFilePath;
  keys[CYLPlaceholderItemAnimationSize] = CYLPlaceholderItemLottieSize;
  keys[CYLPlaceholderItemAnimationDarkURL] = CYLPlaceholderItemLottieDarkURL;
  keys[CYLPlaceholderItemAnimationDarkFilePath] = CYLPlaceholderItemLottieDarkFilePath;
  keys[CYLPlaceholderItemAnimationDarkColors] = CYLPlaceholderItemLottieDarkColors;
  return keys;
}

/** Plays ".json" and ".lottie" files with @ohos/lottie; looked up last (iOS `CYLLottiePlaceholderItemAnimator`). */
export class CYLLottiePlaceholderItemAnimator implements CYLPlaceholderItemAnimator {
  readonly identifier: string = 'Lottie';
  readonly priority: CYLPlaceholderItemAnimatorPriority = CYLPlaceholderItemAnimatorPriorityFallback;
  readonly fileExtensions: string[] = ['json', 'lottie'];
  readonly attributeKeys: Record<string, string> = lottieAttributeKeys();

  canAnimateFileAtURL(URL: string): boolean {
    return this.fileExtensions.includes(CYLPlaceholderAnimationExtensionOfURL(URL));
  }

  animationViewWithURL(URL: string, width: number, height: number,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    // A zipped ".lottie" (dotLottie) needs unpacking that lottie-ohos does not do; it fails on load.
    if (!this.canAnimateFileAtURL(URL)) {
      return null;
    }
    const view = new CYLLottieAnimationContentView(URL, CYLPlaceholderAnimationOptionsOfURL(URL), contentMode);
    view.width = width;
    view.height = height;
    return view;
  }

  playerForAnimationView(view: CYLPlaceholderAnimationContentView): CYLPlaceholderItemAnimationPlayer | null {
    return view instanceof CYLLottieAnimationContentView ?
      new CYLLottiePlaceholderItemAnimationPlayer(view as CYLLottieAnimationContentView) : null;
  }
}
