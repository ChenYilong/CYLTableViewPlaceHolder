// iOS CYLGIFPlaceholderItemAnimator: a CYLPlaceholderItemViewAnimator for ".gif" files. The frames are decoded with
// @kit.ImageKit (createPixelMapList / getDelayTimeList) and played by ArkUI's ImageAnimator, which gives play, stop,
// last frame and repeat counts; the speed divides each frame's duration. Kotlin: CYLGIFPlaceholderItemAnimator.
import { image } from '@kit.ImageKit';
import {
  CYLPlaceholderAnimationArrayBuffer,
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationReadFile,
  CYLPlaceholderItemAnimationViewProviding,
  CYLPlaceholderItemViewAnimator,
  CYLPlaceholderPlayableContentView
} from './CYLPlaceholderAnimation';
import {
  CYLPlaceholderItemAnimationDarkFilePath,
  CYLPlaceholderItemAnimationDarkURL,
  CYLPlaceholderItemAnimationFilePath,
  CYLPlaceholderItemAnimationSize,
  CYLPlaceholderItemAnimationURL,
  CYLPlaceholderItemGIFDarkFilePath,
  CYLPlaceholderItemGIFDarkURL,
  CYLPlaceholderItemGIFFilePath,
  CYLPlaceholderItemGIFSize,
  CYLPlaceholderItemGIFURL
} from './CYLPlaceholderViewTypes';

/** The delay browsers use for frames that declare none (or less than 20 ms). */
const DEFAULT_FRAME_DELAY = 100;

/** The duration of each frame in ms for a GIF's delay list, as browsers play it. */
export function CYLGIFFrameDurations(delays: number[], frameCount: number): number[] {
  const durations: number[] = [];
  for (let i = 0; i < frameCount; i++) {
    const delay = i < delays.length ? delays[i] : 0;
    durations.push(delay >= 20 ? delay : DEFAULT_FRAME_DELAY);
  }
  return durations;
}

/** ImageAnimator's iterations for a repeat count: 0 loops (-1), N plays N times. */
export function CYLGIFIterations(repeatCount: number): number {
  return repeatCount <= 0 ? -1 : Math.floor(repeatCount);
}

/** One frame's duration in ms at a playback speed (at least 1 ms). */
export function CYLGIFScaledDuration(duration: number, speed: number): number {
  const rate = isFinite(speed) && speed > 0 ? speed : 1;
  return Math.max(1, Math.round(duration / rate));
}

/** A GIF drawn by ImageAnimator. */
@Observed
export class CYLGIFAnimationContentView extends CYLPlaceholderPlayableContentView {
  frames: ImageFrameInfo[] = [];
  state: AnimationStatus = AnimationStatus.Initial;
  iterations: number = 1;
  private pixelMaps: image.PixelMap[] = [];
  private durations: number[] = [];
  private restartTimer: number = -1;
  /**
   * Re-renders the drawing component (CYLGIFAnimationComponent). The view reaches the component through a builder
   * parameter, which does not keep an @ObjectLink subscribed on the device, so the frames decoded later never drew
   * and the GIF detail page stayed blank (emulator 2026-11-16, issue E6); the component listens here instead.
   */
  cylChangeListener: (() => void) | null = null;

  cylNotifyChange(): void {
    const listener = this.cylChangeListener;
    if (listener !== null) {
      listener();
    }
  }

  constructor(fileURL: string, options: Record<string, string>, contentMode: ImageFit) {
    super();
    this.fileURL = fileURL;
    this.options = options;
    this.contentMode = contentMode;
    this.builder = wrapBuilder(gifContentBuilder);
  }

  cyl_attach(context: Context | null): void {
    if (this.cyl_isAnimationViewReady || this.loading || this.failed) {
      return;
    }
    this.loading = true;
    CYLPlaceholderAnimationReadFile(this.fileURL, context).then(async (bytes: Uint8Array) => {
      const source = image.createImageSource(CYLPlaceholderAnimationArrayBuffer(bytes));
      try {
        const maps = await source.createPixelMapList();
        let delays: number[] = [];
        try {
          delays = await source.getDelayTimeList();
        } catch (e) {
          delays = [];
        }
        if (maps.length === 0) {
          this.didFail('GIF', null);
          return;
        }
        this.pixelMaps = maps;
        this.durations = CYLGIFFrameDurations(delays, maps.length);
        this.updateFrames();
        this.iterations = CYLGIFIterations(this.repeatCount);
        this.cylNotifyChange();
        this.didLoad();
      } finally {
        source.release();
      }
    }).catch((e: Error) => {
      console.error('CYLGIFPlaceholderItemAnimator: ' + this.fileURL + ' failed to decode: ' + e.name + ': ' + e.message);
      this.didFail('GIF', e);
    });
  }

  get cyl_supportsAnimationViewSpeed(): boolean {
    return true;
  }

  /** Divides every frame's duration by the speed; ImageAnimator takes the new frames at once. */
  cyl_setAnimationViewSpeed(speed: number): boolean {
    if (!isFinite(speed) || speed <= 0) {
      return false;
    }
    if (speed === this.playbackSpeed) {
      return true;
    }
    this.playbackSpeed = speed;
    if (this.pixelMaps.length > 0) {
      const running = this.state === AnimationStatus.Running;
      this.updateFrames();
      // ImageAnimator can stop (and draw nothing) when its frames change while it runs: start it again with the new
      // durations (the GIF detail page was blank after a speed change, 2026-11-16).
      if (running) {
        this.cyl_playAnimationView();
      }
    }
    return true;
  }

  private updateFrames(): void {
    const frames: ImageFrameInfo[] = [];
    for (let i = 0; i < this.pixelMaps.length; i++) {
      const frame: ImageFrameInfo = {
        src: this.pixelMaps[i], duration: CYLGIFScaledDuration(this.durations[i], this.playbackSpeed)
      };
      frames.push(frame);
    }
    this.frames = frames;
    this.cylNotifyChange();
  }

  cyl_playAnimationView(): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingCommand = 1;
      return;
    }
    this.iterations = CYLGIFIterations(this.repeatCount);
    this.cylNotifyChange();
    if (this.restartTimer >= 0) {
      clearTimeout(this.restartTimer);
    }
    // From the first frame: back to Initial, then Running on the next frame.
    this.state = AnimationStatus.Initial;
    this.cylNotifyChange();
    this.restartTimer = setTimeout(() => {
      this.restartTimer = -1;
      this.state = AnimationStatus.Running;
      this.cylNotifyChange();
    }, 0);
  }

  cyl_showAnimationViewLastFrame(): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingCommand = 2;
      return;
    }
    this.cancelRestart();
    // fillMode Forwards: a stopped animator rests on its last frame.
    this.state = AnimationStatus.Stopped;
    this.cylNotifyChange();
  }

  cyl_stopAnimationView(): void {
    this.pendingCommand = 0;
    this.cancelRestart();
    this.state = AnimationStatus.Initial;
    this.cylNotifyChange();
  }

  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    this.repeatCount = Math.max(0, Math.floor(repeatCount));
    this.iterations = CYLGIFIterations(this.repeatCount);
    this.cylNotifyChange();
    return true;
  }

  cyl_detach(): void {
    this.cancelRestart();
  }

  private cancelRestart(): void {
    if (this.restartTimer >= 0) {
      clearTimeout(this.restartTimer);
      this.restartTimer = -1;
    }
  }
}

@Component
struct CYLGIFAnimationComponent {
  @ObjectLink view: CYLGIFAnimationContentView;
  @State private cylTick: number = 0;

  aboutToAppear(): void {
    this.view.cylChangeListener = () => {
      this.cylTick++;
    };
  }

  aboutToDisappear(): void {
    this.view.cylChangeListener = null;
  }

  build() {
    if (this.cylTick >= 0 && this.view.state === AnimationStatus.Initial && this.view.frames.length > 0) {
      // At rest (before the first play, or stopped) the first frame is drawn as an image: ImageAnimator may draw
      // nothing in its Initial state (the GIF detail page showed only the file name, 2026-11-16).
      Image(this.view.frames[0].src)
        .objectFit(ImageFit.Contain)
        .width(this.view.width)
        .height(this.view.height)
    } else {
      ImageAnimator()
        .images(this.view.frames)
        .state(this.view.state)
        .iterations(this.view.iterations)
        .fillMode(FillMode.Forwards)
        .fixedSize(true)
        .width(this.view.width)
        .height(this.view.height)
    }
  }
}

@Builder
function gifContentBuilder(view: CYLPlaceholderAnimationContentView) {
  CYLGIFAnimationComponent({ view: view as CYLGIFAnimationContentView })
}

class CYLGIFViewProvider implements CYLPlaceholderItemAnimationViewProviding {
  cyl_animationViewWithFileURL(fileURL: string, options: Record<string, string>,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    return new CYLGIFAnimationContentView(fileURL, options, contentMode);
  }
}

function gifAttributeKeys(): Record<string, string> {
  const keys: Record<string, string> = {};
  keys[CYLPlaceholderItemAnimationURL] = CYLPlaceholderItemGIFURL;
  keys[CYLPlaceholderItemAnimationFilePath] = CYLPlaceholderItemGIFFilePath;
  keys[CYLPlaceholderItemAnimationSize] = CYLPlaceholderItemGIFSize;
  keys[CYLPlaceholderItemAnimationDarkURL] = CYLPlaceholderItemGIFDarkURL;
  keys[CYLPlaceholderItemAnimationDarkFilePath] = CYLPlaceholderItemGIFDarkFilePath;
  return keys;
}

/** Registers a CYLPlaceholderItemViewAnimator for ".gif" files (iOS `CYLGIFPlaceholderItemAnimator`). */
export class CYLGIFPlaceholderItemAnimator {
  private static shared: CYLPlaceholderItemViewAnimator | null = null;

  /** The GIF animator (iOS class property `animator`). */
  static get animator(): CYLPlaceholderItemViewAnimator {
    if (CYLGIFPlaceholderItemAnimator.shared === null) {
      CYLGIFPlaceholderItemAnimator.shared = new CYLPlaceholderItemViewAnimator('GIF', ['gif'], gifAttributeKeys(),
        new CYLGIFViewProvider());
    }
    return CYLGIFPlaceholderItemAnimator.shared as CYLPlaceholderItemViewAnimator;
  }
}
