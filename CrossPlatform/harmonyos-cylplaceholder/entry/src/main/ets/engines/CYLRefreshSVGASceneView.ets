// CYLRefreshSVGASceneView: the SVGA twin of CYLRefreshRiveView (Task-Log "SVGA animations, every Rive demo copied
// 1:1"). The CYLRefresh "SVGA · …" styles use the core's CYLRefreshRiveHeaderModel with an .svga file (a style
// with a pull animation and a loading animation): this view draws the file on a Canvas with CYLTabBarController's SVGA
// decoder and renderer (engines/svga) and is the header's CYLRefreshRiveDriver. SVGA has no state machine or named
// animations: scrubbing shows the frame at the pulled fraction, playing loops the whole file, inputs are ignored.
// cylRefreshSceneViewBuilder, registered in ExampleAnimationEngines.ets, draws this view for .svga styles and the
// Rive view for .riv ones.
import { image } from '@kit.ImageKit';
import {
  CYLPlaceholderAnimationReadFile,
  CYLRefreshRiveDriver,
  CYLRefreshRiveHeaderModel,
  CYLRefreshRiveStyle,
  CYLRefreshScrollViewModel,
  cylRefreshRiveHeader
} from 'cylplaceholder';
import { CYLSVGAMovie, cylLoadSVGAMovie } from './svga/CYLSVGAMovie';
import { cylDrawSVGAFrame } from './svga/CYLSVGARenderer';
import { CYLRefreshRiveView } from './CYLRefreshRiveView';

/** Whether a style plays an SVGA file. */
export function cylRefreshStyleIsSVGA(style: CYLRefreshRiveStyle | null): boolean {
  return style !== null && style.fileURL.toLowerCase().endsWith('.svga');
}

/** The movie drawn on a Canvas, as the header's driver. */
class CYLRefreshSVGASceneDriver implements CYLRefreshRiveDriver {
  private readonly canvas: CanvasRenderingContext2D;
  private readonly movie: CYLSVGAMovie;
  private readonly size: () => number[];
  private readonly bitmaps: Map<string, image.PixelMap> = new Map<string, image.PixelMap>();
  private frame: number = 0;
  private timer: number = -1;

  constructor(canvas: CanvasRenderingContext2D, movie: CYLSVGAMovie, size: () => number[]) {
    this.canvas = canvas;
    this.movie = movie;
    this.size = size;
  }

  private get frames(): number {
    return Math.max(1, this.movie.frames);
  }

  draw(): void {
    const size = this.size();
    if (size[0] <= 0 || size[1] <= 0) {
      return;
    }
    this.canvas.clearRect(0, 0, size[0], size[1]);
    cylDrawSVGAFrame(this.canvas, this.movie, this.bitmaps, this.frame, size[0], size[1]);
  }

  stop(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  setNumber(input: string, value: number): void {
  }

  setBoolean(input: string, value: boolean): void {
  }

  fire(trigger: string): void {
  }

  /** Plays the whole file from where it is; looping goes back to frame 0 at the end, else it rests on the last. */
  play(animation: string | null, loop: boolean): void {
    this.stop();
    const fps = this.movie.fps > 0 ? this.movie.fps : 20;
    this.timer = setInterval(() => {
      if (this.frame < this.frames - 1) {
        this.frame += 1;
      } else if (loop) {
        this.frame = 0;
      } else {
        this.stop();
      }
      this.draw();
    }, 1000 / fps);
  }

  /** The pull animation's time is the pulled fraction (CYLRefreshRiveStyle.pullAnimation): that share of the file. */
  scrub(animation: string, time: number): void {
    this.stop();
    this.frame = Math.round(Math.min(1, Math.max(0, time)) * (this.frames - 1));
    this.draw();
  }

  duration(animation: string): number {
    return this.movie.fps > 0 ? this.frames / this.movie.fps : -1;
  }

  reset(): void {
    this.stop();
    this.frame = 0;
    this.draw();
  }
}

/** Plays the SVGA header of a scroll view model's header or footer (`role`: 'header' or 'footer'). */
@Component
export struct CYLRefreshSVGASceneView {
  scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  role: string = 'header';
  @State private viewW: number = 0;
  @State private viewH: number = 0;
  private header: CYLRefreshRiveHeaderModel | null = null;
  private canvas: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  private canvasReady: boolean = false;
  private movie: CYLSVGAMovie | null = null;
  private driver: CYLRefreshSVGASceneDriver | null = null;

  aboutToAppear(): void {
    const c = this.role === 'footer' ? this.scrollView.cyl_footer : this.scrollView.cyl_header;
    this.header = cylRefreshRiveHeader(c);
    const header = this.header;
    if (header === null || header.riveStyle === null) {
      return;
    }
    const style = header.riveStyle as CYLRefreshRiveStyle;
    CYLPlaceholderAnimationReadFile(style.fileURL, this.getUIContext().getHostContext() as Context)
      .then(async (bytes: Uint8Array) => {
        this.movie = await cylLoadSVGAMovie(bytes);
        this.attachIfPossible();
      })
      .catch(() => {
        // An unreadable file: the header stays empty, as the Rive view.
      });
  }

  aboutToDisappear(): void {
    if (this.driver !== null) {
      this.driver.stop();
      if (this.header !== null) {
        this.header.cyl_detachDriver(this.driver);
      }
    }
    this.driver = null;
  }

  private layoutHeight(): number {
    const header = this.header;
    return header !== null && header.riveStyle !== null ?
      (header.riveStyle as CYLRefreshRiveStyle).layoutHeight(this.viewH) : this.viewH;
  }

  private attachIfPossible(): void {
    const header = this.header;
    const movie = this.movie;
    if (!this.canvasReady || movie === null || header === null || this.driver !== null) {
      return;
    }
    const driver = new CYLRefreshSVGASceneDriver(this.canvas, movie, () => [this.viewW, this.layoutHeight()]);
    this.driver = driver;
    driver.draw();
    header.cyl_attachDriver(driver);
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Canvas(this.canvas)
        .width('100%')
        .height(this.layoutHeight())
        .hitTestBehavior(HitTestMode.None)
        .onReady(() => {
          this.canvasReady = true;
          this.attachIfPossible();
        })
        .onAreaChange(() => {
          if (this.driver !== null) {
            this.driver.draw();
          }
        })
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .accessibilityLevel('no-hide-descendants')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.viewW = Number(newValue.width);
      this.viewH = Number(newValue.height);
    })
  }
}

/**
 * The builder the example registers for the core's Rive-style headers (CYLRefreshRiveRegisterViewBuilder): the SVGA
 * view for an .svga style, the @ohos/rive view for a .riv style where Rive runs (`riveSupported`).
 */
@Builder
export function cylRefreshSceneViewBuilder(scrollView: CYLRefreshScrollViewModel, role: string) {
  if (cylRefreshStyleIsSVGA(cylRefreshRiveHeaderStyle(scrollView, role))) {
    CYLRefreshSVGASceneView({ scrollView: scrollView, role: role })
  } else if (cylRefreshRiveRuns) {
    CYLRefreshRiveView({ scrollView: scrollView, role: role })
  }
}

/** Whether @ohos/rive runs here (set at launch by ExampleRegisterAnimationEngines). */
let cylRefreshRiveRuns: boolean = false;

export function cylRefreshSetRiveRuns(runs: boolean): void {
  cylRefreshRiveRuns = runs;
}

function cylRefreshRiveHeaderStyle(scrollView: CYLRefreshScrollViewModel, role: string): CYLRefreshRiveStyle | null {
  const header = cylRefreshRiveHeader(role === 'footer' ? scrollView.cyl_footer : scrollView.cyl_header);
  return header !== null ? header.riveStyle : null;
}
