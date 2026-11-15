// CYLRefreshDrawnView: the ArkUI half of the drawn styles. `CYLRefreshDrawnView` draws the drawn header (or the style
// hosted by a drawn footer) of a scroll view model on a Canvas, one frame per display tick while there is something
// to draw, and forwards touches to it (the games). `CYLRefreshComponentView` hosts it for drawn controls, so a drawn
// header or footer plugs into `CYLRefreshContainer` like any other. `CYLRefreshVectorViewComponent` draws a
// CYLRefreshVectorViewModel (iOS CYLRefreshVectorView).
import { CYLRefreshComponentModel, CYLRefreshScrollViewModel } from '../CYLRefreshComponent';
import { CYLRefreshDrawnFooterModel, CYLRefreshDrawnHeaderModel, CYLRefreshDrawnTouch } from './CYLRefreshDrawnHeader';
import { CYLRefreshVectorViewModel } from './CYLRefreshVector';

/** The drawn header a control shows: itself, or the style of a drawn footer; null for other controls. */
export function cylRefreshDrawnStyle(c: CYLRefreshComponentModel | null): CYLRefreshDrawnHeaderModel | null {
  if (c instanceof CYLRefreshDrawnHeaderModel) {
    return c as CYLRefreshDrawnHeaderModel;
  }
  if (c instanceof CYLRefreshDrawnFooterModel) {
    const footer = c as CYLRefreshDrawnFooterModel;
    footer.cyl_syncStyleColors();
    return footer.style;
  }
  return null;
}

/** The display frame period, in ms. */
const CYLRefreshDrawnFrame: number = 16;

@Component
export struct CYLRefreshDrawnView {
  scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  /** 'header' or 'footer'. */
  role: string = 'header';
  @State private overflow: number = 0;
  @State private passes: boolean = false;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;
  private viewW: number = 0;
  private viewH: number = 0;
  private timer: number = -1;

  aboutToAppear(): void {
    this.timer = setInterval(() => this.frame(), CYLRefreshDrawnFrame);
  }

  aboutToDisappear(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    this.ready = false;
  }

  private style(): CYLRefreshDrawnHeaderModel | null {
    return cylRefreshDrawnStyle(this.role === 'footer' ? this.scrollView.cyl_footer : this.scrollView.cyl_header);
  }

  private frame(): void {
    const style = this.style();
    if (!this.ready || style === null || this.viewW <= 0) {
      return;
    }
    const overflow = style.cyl_overflowHeight();
    if (overflow !== this.overflow) {
      this.overflow = overflow;
    }
    if (style.cyl_passesTouches !== this.passes) {
      this.passes = style.cyl_passesTouches;
    }
    style.cyl_render(this.ctx, this.viewW, Math.max(this.viewH, overflow), Date.now());
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Canvas(this.ctx)
        .width('100%')
        .height(this.overflow > 0 ? Math.max(this.viewH, this.overflow) : '100%')
        .hitTestBehavior(this.passes ? HitTestMode.None : HitTestMode.Default)
        .onReady(() => {
          this.ready = true;
          this.frame();
        })
        .onTouch((event: TouchEvent) => {
          const style = this.style();
          if (style === null || event.touches.length === 0) {
            return;
          }
          const t = event.touches[0];
          const kind = event.type === TouchType.Down ? CYLRefreshDrawnTouch.Down :
            event.type === TouchType.Move ? CYLRefreshDrawnTouch.Move : CYLRefreshDrawnTouch.Up;
          style.cyl_touch(kind, t.x, t.y);
        })
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(this.passes ? HitTestMode.Transparent : HitTestMode.Default)
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.viewW = Number(newValue.width);
      this.viewH = Number(newValue.height);
      this.frame();
    })
  }
}

/** Draws a vector view model's image, fitted and centered (iOS `CYLRefreshVectorView`). */
@Component
export struct CYLRefreshVectorViewComponent {
  model: CYLRefreshVectorViewModel = new CYLRefreshVectorViewModel();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private viewW: number = 0;
  private viewH: number = 0;

  private draw(): void {
    if (this.viewW <= 0 || this.viewH <= 0) {
      return;
    }
    this.ctx.clearRect(0, 0, this.viewW, this.viewH);
    this.model.drawInContext(this.ctx, this.viewW, this.viewH);
  }

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height('100%')
      .onReady(() => this.draw())
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.viewW = Number(newValue.width);
        this.viewH = Number(newValue.height);
        this.draw();
      })
  }
}
