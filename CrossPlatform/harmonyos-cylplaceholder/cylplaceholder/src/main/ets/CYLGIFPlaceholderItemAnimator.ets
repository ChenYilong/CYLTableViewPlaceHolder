// iOS CYLGIFPlaceholderItemAnimator: a CYLPlaceholderItemViewAnimator for ".gif" files. The frames are decoded with
// @kit.ImageKit (createPixelMapList / getDelayTimeList) and played by ArkUI's ImageAnimator, which gives play, stop,
// last frame and repeat counts; the speed divides each frame's duration. Kotlin: CYLGIFPlaceholderItemAnimator.
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import {
  CYLPlaceholderAnimationArrayBuffer,
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationDefaultContext,
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

/**
 * How a GIF is drawn when its frames cannot all be decoded (TODO in docs/HarmonyOS.md, "GIF decode fallback"):
 * Frames (ImageAnimator, the normal way), FirstFrame (createPixelMapList failed or returned no frame, but the first
 * frame decodes: a still image), System (ImageKit cannot decode it at all: ArkUI's Image decodes and plays the file
 * from a cache copy), Failed (nothing works: the placeholder keeps its fallback image).
 */
export enum CYLGIFDrawMode {
  Frames = 0,
  FirstFrame = 1,
  System = 2,
  Failed = 3
}

/**
 * Whether the GIF ends with its trailer byte (0x3B). A file without it was cut short: its last frame, as ImageKit
 * decodes it, is incomplete (E12: CYLScenarioExampleTruncated.gif rested on a fragment of its second frame).
 */
export function CYLGIFHasTrailer(bytes: Uint8Array): boolean {
  return bytes.length > 0 && bytes[bytes.length - 1] === 0x3B;
}

/** The cache file of a GIF given to the system decoder: a stable name from the URL and the size. */
export function CYLGIFCacheFileName(fileURL: string, byteLength: number): string {
  let hash = 5381;
  for (let i = 0; i < fileURL.length; i++) {
    hash = ((hash * 33) ^ fileURL.charCodeAt(i)) >>> 0;
  }
  return 'cyl-gif-' + hash.toString(16) + '-' + byteLength + '.gif';
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
  /** How the GIF is drawn (CYLGIFDrawMode): frames, its first frame, or the system decoder. */
  drawMode: CYLGIFDrawMode = CYLGIFDrawMode.Frames;
  /** The "file://" cache copy drawn by ArkUI's Image in the System mode, else "". */
  systemImagePath: string = '';
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
      await this.decode(bytes, context);
    }).catch((e: Error) => {
      console.error('CYLGIFPlaceholderItemAnimator: ' + this.fileURL + ' cannot be read: ' + e.name + ': ' + e.message);
      this.didFail('GIF', e);
    });
  }

  /**
   * Decodes the GIF with fallbacks, so a file ImageKit only partly understands still shows: every frame first, then
   * the first frame as a still image, then ArkUI's own Image decoder on a cache copy; only when all three fail does the
   * view report the failure (the placeholder then keeps its fallback image).
   */
  private async decode(bytes: Uint8Array, context: Context | null): Promise<void> {
    const source = image.createImageSource(CYLPlaceholderAnimationArrayBuffer(bytes));
    try {
      // 1. Every frame (the normal way).
      try {
        const maps = await source.createPixelMapList();
        // A file cut short (no trailer) decodes its last frame only partly: drop that fragment.
        if (maps.length > 1 && !CYLGIFHasTrailer(bytes)) {
          const fragment = maps.pop();
          if (fragment !== undefined) {
            fragment.release();
          }
        }
        if (maps.length === 1 && !CYLGIFHasTrailer(bytes)) {
          this.useFrames(maps, [100], CYLGIFDrawMode.FirstFrame);
          return;
        }
        if (maps.length > 0) {
          let delays: number[] = [];
          try {
            delays = await source.getDelayTimeList();
          } catch (e) {
            delays = [];
          }
          this.useFrames(maps, CYLGIFFrameDurations(delays, maps.length), CYLGIFDrawMode.Frames);
          return;
        }
        console.error('CYLGIFPlaceholderItemAnimator: ' + this.fileURL + ' has no frame; trying its first frame');
      } catch (e) {
        console.error('CYLGIFPlaceholderItemAnimator: ' + this.fileURL + ' frames failed to decode (' + (e as Error).message +
          '); trying its first frame');
      }
      // 2. The first frame, as a still image.
      try {
        const first = await source.createPixelMap();
        this.useFrames([first], [100], CYLGIFDrawMode.FirstFrame);
        return;
      } catch (e) {
        console.error('CYLGIFPlaceholderItemAnimator: ' + this.fileURL + ' first frame failed to decode (' +
          (e as Error).message + '); trying the system decoder');
      }
    } finally {
      source.release();
    }
    // 3. ArkUI's Image decodes and plays the file itself, from a cache copy.
    const host: Context | null = context !== null ? context : CYLPlaceholderAnimationDefaultContext();
    if (host !== null) {
      try {
        const path = host.cacheDir + '/' + CYLGIFCacheFileName(this.fileURL, bytes.length);
        if (!fileIo.accessSync(path)) {
          const file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
          try {
            fileIo.writeSync(file.fd, CYLPlaceholderAnimationArrayBuffer(bytes));
          } finally {
            fileIo.closeSync(file);
          }
        }
        this.systemImagePath = 'file://' + path;
        this.drawMode = CYLGIFDrawMode.System;
        this.cylNotifyChange();
        this.didLoad();
        return;
      } catch (e) {
        console.error('CYLGIFPlaceholderItemAnimator: ' + this.fileURL + ' cache copy failed: ' + (e as Error).message);
      }
    }
    this.drawMode = CYLGIFDrawMode.Failed;
    this.didFail('GIF', null);
  }

  /**
   * ArkUI's Image could not decode the cache copy either (the System mode): the view fails now, so the placeholder
   * shows its fallback image. Before, the System mode reported a load as soon as the copy was written and drew nothing
   * for a file no decoder understands (E12: CYLScenarioExampleBroken.gif).
   */
  cyl_systemDecodeFailed(): void {
    if (this.drawMode !== CYLGIFDrawMode.System) {
      return;
    }
    console.error('CYLGIFPlaceholderItemAnimator: ' + this.fileURL + ' the system decoder failed too');
    this.drawMode = CYLGIFDrawMode.Failed;
    this.cylNotifyChange();
    this.didFail('GIF', null);
  }

  private useFrames(maps: image.PixelMap[], durations: number[], mode: CYLGIFDrawMode): void {
    this.pixelMaps = maps;
    this.durations = durations;
    this.drawMode = mode;
    this.updateFrames();
    this.iterations = CYLGIFIterations(this.repeatCount);
    this.cylNotifyChange();
    this.didLoad();
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

  /**
   * The model, read together with cylTick: ArkUI re-renders only the parts of build() that read the changed state,
   * so every read goes through here and every attribute updates when the model notifies (cylChangeListener).
   */
  private model(): CYLGIFAnimationContentView {
    return this.cylTick >= 0 ? this.view : this.view;
  }

  aboutToAppear(): void {
    this.view.cylChangeListener = () => {
      this.cylTick++;
    };
  }

  aboutToDisappear(): void {
    this.view.cylChangeListener = null;
  }

  build() {
    if (this.model().drawMode === CYLGIFDrawMode.System) {
      // ImageKit could not decode it: ArkUI's Image decodes and plays the cache copy (it ignores play / stop / speed).
      Image(this.model().systemImagePath)
        .objectFit(ImageFit.Contain)
        .width(this.model().width)
        .height(this.model().height)
        .onError(() => {
          this.view.cyl_systemDecodeFailed();
        })
    } else if ((this.model().state === AnimationStatus.Initial || this.model().drawMode === CYLGIFDrawMode.FirstFrame) &&
      this.model().frames.length > 0) {
      // At rest (before the first play, or stopped) the first frame is drawn as an image: ImageAnimator may draw
      // nothing in its Initial state (the GIF detail page showed only the file name, 2026-11-16). The FirstFrame mode
      // is always a still image: ImageAnimator with its single frame drew nothing once "playing" (E12, a tiny mark
      // instead of the star of CYLScenarioExampleTruncated.gif on the emulator, 2026-11-17).
      Image(this.model().frames[0].src)
        .objectFit(ImageFit.Contain)
        .width(this.model().width)
        .height(this.model().height)
    } else {
      ImageAnimator()
        .images(this.model().frames)
        .state(this.model().state)
        .iterations(this.model().iterations)
        .fillMode(FillMode.Forwards)
        .fixedSize(true)
        .width(this.model().width)
        .height(this.model().height)
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
