// The example's SVGA engine (Task-Log "SVGA animations, every Rive demo copied 1:1"). The cylplaceholder core depends
// on no animation library, so, like PAG and Rive, the example registers it (ExampleAnimationEngines.ets). It plays
// ".svga" files on an ArkUI Canvas with CYLTabBarController's own SVGA 2.x decoder and renderer (engines/svga, copied
// from its HarmonyOS port, where CYLSVGAView draws the SVGA tab icons). There is no player library, so every option
// is drawn here: play from frame 0, last frame, stop, progress, speed (the frame interval) and repeat counts.
import { image } from '@kit.ImageKit';
import {
  CYLPlaceholderAnimationColors,
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationExtensionOfURL,
  CYLPlaceholderAnimationOptionsOfURL,
  CYLPlaceholderAnimationReadFile,
  CYLPlaceholderItemAnimationBasePlayer,
  CYLPlaceholderItemAnimationPlayer,
  CYLPlaceholderItemAnimator,
  CYLPlaceholderItemAnimatorPriority,
  CYLPlaceholderItemAnimatorPriorityDefault,
  CYLPlaceholderPlayableContentView,
  CYLPlaceholderItemAnimationDarkFilePath,
  CYLPlaceholderItemAnimationDarkURL,
  CYLPlaceholderItemAnimationFilePath,
  CYLPlaceholderItemAnimationSize,
  CYLPlaceholderItemAnimationURL
} from 'cylplaceholder';
import { CYLSVGAMovie, cylLoadSVGAMovie } from './svga/CYLSVGAMovie';
import { cylDrawSVGAFrame } from './svga/CYLSVGARenderer';

/** The PNG images of the movie as pixel maps; a broken image is left out (as CYLTabBarController's CYLSVGAView). */
async function cylDecodeSVGABitmaps(movie: CYLSVGAMovie): Promise<Map<string, image.PixelMap>> {
  const bitmaps = new Map<string, image.PixelMap>();
  const keys = Array.from(movie.images.keys());
  for (const key of keys) {
    const bytes = movie.images.get(key);
    if (bytes === undefined) {
      continue;
    }
    try {
      const source = image.createImageSource(bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength));
      bitmaps.set(key, await source.createPixelMap());
      await source.release();
    } catch (error) {
      // A broken image is skipped.
    }
  }
  return bitmaps;
}

/** An SVGA file drawn frame by frame on a Canvas. */
@Observed
export class CYLSVGAAnimationContentView extends CYLPlaceholderPlayableContentView {
  readonly canvas: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  private canvasReady: boolean = false;
  private movie: CYLSVGAMovie | undefined = undefined;
  private bitmaps: Map<string, image.PixelMap> = new Map<string, image.PixelMap>();
  private frame: number = 0;
  private plays: number = 0;
  private timer: number = -1;
  private pendingProgress: number = -1;

  constructor(fileURL: string, options: Record<string, string>, contentMode: ImageFit) {
    super();
    this.fileURL = fileURL;
    this.options = options;
    this.contentMode = contentMode;
    this.builder = wrapBuilder(svgaContentBuilder);
  }

  get cyl_supportsAnimationViewSpeed(): boolean {
    return true;
  }

  /** Live: a playing animation keeps its frame and goes on at the new frame interval. */
  cyl_setAnimationViewSpeed(speed: number): boolean {
    if (!isFinite(speed) || speed <= 0) {
      return false;
    }
    this.playbackSpeed = speed;
    if (this.timer >= 0) {
      this.startTimer();
    }
    return true;
  }

  /** Called by the Canvas once it can draw. */
  canvasDidBecomeReady(): void {
    this.canvasReady = true;
    this.draw();
  }

  cyl_attach(context: Context | null): void {
    if (this.cyl_isAnimationViewReady || this.loading || this.failed) {
      return;
    }
    this.loading = true;
    CYLPlaceholderAnimationReadFile(this.fileURL, context).then(async (bytes: Uint8Array) => {
      const movie = await cylLoadSVGAMovie(bytes);
      this.bitmaps = await cylDecodeSVGABitmaps(movie);
      this.movie = movie;
      this.frame = this.pendingProgress >= 0 ? this.frameAt(this.pendingProgress) : 0;
      this.pendingProgress = -1;
      this.draw();
      this.didLoad();
    }).catch((e: Error) => {
      this.didFail('SVGA', e);
    });
  }

  private get frameCount(): number {
    return this.movie !== undefined ? Math.max(1, this.movie.frames) : 1;
  }

  private frameAt(progress: number): number {
    return Math.round(Math.min(1, Math.max(0, progress)) * (this.frameCount - 1));
  }

  private draw(): void {
    if (this.canvasReady && this.movie !== undefined) {
      this.canvas.clearRect(0, 0, this.width, this.height);
      cylDrawSVGAFrame(this.canvas, this.movie, this.bitmaps, this.frame, this.width, this.height);
    }
  }

  private stopTimer(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  /** One frame per 1 / (fps × speed) s; at the end of a pass, loops (repeat count 0), plays again or rests. */
  private startTimer(): void {
    const movie = this.movie;
    if (movie === undefined) {
      return;
    }
    this.stopTimer();
    const fps = movie.fps > 0 ? movie.fps : 20;
    this.timer = setInterval(() => this.tick(), 1000 / (fps * this.playbackSpeed));
  }

  private tick(): void {
    if (this.frame < this.frameCount - 1) {
      this.frame += 1;
    } else {
      this.plays += 1;
      if (this.repeatCount === 0 || this.plays < this.repeatCount) {
        this.frame = 0;
      } else {
        this.stopTimer();
      }
    }
    this.draw();
  }

  seek(progress: number): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingProgress = progress;
      return;
    }
    this.stopTimer();
    this.frame = this.frameAt(progress);
    this.draw();
  }

  get currentProgress(): number {
    return this.frameCount > 1 ? this.frame / (this.frameCount - 1) : 0;
  }

  cyl_playAnimationView(): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingCommand = 1;
      return;
    }
    this.frame = 0;
    this.plays = 0;
    this.draw();
    this.startTimer();
  }

  cyl_showAnimationViewLastFrame(): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingCommand = 2;
      return;
    }
    this.stopTimer();
    this.frame = this.frameCount - 1;
    this.draw();
  }

  cyl_stopAnimationView(): void {
    this.pendingCommand = 0;
    this.stopTimer();
    if (!this.cyl_isAnimationViewReady) {
      return;
    }
    this.frame = 0;
    this.draw();
  }

  /** 0 loops, N plays N times (read at the end of each pass, so a change applies live). */
  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    this.repeatCount = Math.max(0, Math.floor(repeatCount));
    return true;
  }

  cyl_detach(): void {
    this.stopTimer();
  }
}

@Component
struct CYLSVGAAnimationComponent {
  @ObjectLink view: CYLSVGAAnimationContentView;

  aboutToDisappear(): void {
    this.view.cyl_detach();
  }

  build() {
    Canvas(this.view.canvas)
      .width(this.view.width)
      .height(this.view.height)
      .accessibilityLevel('no')
      .hitTestBehavior(HitTestMode.Transparent)
      .onReady(() => this.view.canvasDidBecomeReady())
  }
}

@Builder
function svgaContentBuilder(view: CYLPlaceholderAnimationContentView) {
  CYLSVGAAnimationComponent({ view: view as CYLSVGAAnimationContentView })
}

/** The SVGA player: play, last frame, stop, progress, speed and repeat counts (SVGA files have no color slots). */
class CYLSVGAPlaceholderItemAnimationPlayer extends CYLPlaceholderItemAnimationBasePlayer {
  private svgaView: CYLSVGAAnimationContentView;

  constructor(view: CYLSVGAAnimationContentView) {
    super(view);
    this.svgaView = view;
  }

  play(): void {
    this.svgaView.cyl_playAnimationView();
  }

  showLastFrame(): void {
    this.svgaView.cyl_showAnimationViewLastFrame();
  }

  stop(): void {
    this.svgaView.cyl_stopAnimationView();
  }

  get progress(): number {
    return this.svgaView.currentProgress;
  }

  set progress(value: number) {
    this.svgaView.seek(value);
  }

  get supportsProgress(): boolean {
    return true;
  }

  get animationSpeed(): number {
    return this.svgaView.playbackSpeed;
  }

  set animationSpeed(value: number) {
    this.svgaView.cyl_setAnimationViewSpeed(value);
  }

  get supportsAnimationSpeed(): boolean {
    return true;
  }

  setAnimationRepeatCount(repeatCount: number): boolean {
    return this.svgaView.cyl_setAnimationViewRepeatCount(repeatCount);
  }

  applyColors(colors: CYLPlaceholderAnimationColors | null, dark: boolean): void {
  }
}

function svgaAttributeKeys(): Record<string, string> {
  const keys: Record<string, string> = {};
  keys[CYLPlaceholderItemAnimationURL] = CYLPlaceholderItemAnimationURL;
  keys[CYLPlaceholderItemAnimationFilePath] = CYLPlaceholderItemAnimationFilePath;
  keys[CYLPlaceholderItemAnimationSize] = CYLPlaceholderItemAnimationSize;
  keys[CYLPlaceholderItemAnimationDarkURL] = CYLPlaceholderItemAnimationDarkURL;
  keys[CYLPlaceholderItemAnimationDarkFilePath] = CYLPlaceholderItemAnimationDarkFilePath;
  return keys;
}

/** Plays ".svga" files (CYLTabBarController's `CYLSVGATabBarItemAnimator` on iOS and Android). */
export class CYLSVGAPlaceholderItemAnimator implements CYLPlaceholderItemAnimator {
  readonly identifier: string = 'SVGA';
  readonly priority: CYLPlaceholderItemAnimatorPriority = CYLPlaceholderItemAnimatorPriorityDefault;
  readonly fileExtensions: string[] = ['svga'];
  readonly attributeKeys: Record<string, string> = svgaAttributeKeys();

  canAnimateFileAtURL(URL: string): boolean {
    return this.fileExtensions.includes(CYLPlaceholderAnimationExtensionOfURL(URL));
  }

  animationViewWithURL(URL: string, width: number, height: number,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    if (!this.canAnimateFileAtURL(URL)) {
      return null;
    }
    const view = new CYLSVGAAnimationContentView(URL, CYLPlaceholderAnimationOptionsOfURL(URL), contentMode);
    view.width = width;
    view.height = height;
    return view;
  }

  playerForAnimationView(view: CYLPlaceholderAnimationContentView): CYLPlaceholderItemAnimationPlayer | null {
    return view instanceof CYLSVGAAnimationContentView ?
      new CYLSVGAPlaceholderItemAnimationPlayer(view as CYLSVGAAnimationContentView) : null;
  }
}
