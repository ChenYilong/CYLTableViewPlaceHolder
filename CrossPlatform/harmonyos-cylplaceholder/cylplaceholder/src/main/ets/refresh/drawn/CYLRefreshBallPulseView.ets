// CYLRefreshBallPulseView: draws a CYLRefreshBallPulseFooterModel, three circles that scale in turn while it loads.
// Written, not built.
import { CYLRefreshScrollViewModel } from '../CYLRefreshComponent';
import {
  CYLRefreshBallPulseCenterX,
  CYLRefreshBallPulseFooterModel,
  CYLRefreshBallPulseRadius,
  CYLRefreshBallPulseScale
} from './CYLRefreshBallPulse';

/** The display frame period, in ms. */
const CYLRefreshBallPulseFrame: number = 16;

@Component
export struct CYLRefreshBallPulseView {
  scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  @State private tick: number = 0;
  @State private elapsed: number = 0;
  @State private viewW: number = 0;
  @State private viewH: number = 0;
  private timer: number = -1;
  private startedAt: number = 0;
  private listened: CYLRefreshBallPulseFooterModel | null = null;
  private onChange: () => void = () => {
    this.follow();
    this.tick++;
  };

  aboutToAppear(): void {
    this.scrollView.addChangeListener(this.onChange);
    this.follow();
  }

  aboutToDisappear(): void {
    this.scrollView.removeChangeListener(this.onChange);
    if (this.listened !== null) {
      this.listened.removeChangeListener(this.onChange);
      this.listened = null;
    }
    this.stopTimer();
  }

  private footer(): CYLRefreshBallPulseFooterModel | null {
    const f = this.tick >= 0 ? this.scrollView.cyl_footer : null;
    return f instanceof CYLRefreshBallPulseFooterModel ? f as CYLRefreshBallPulseFooterModel : null;
  }

  /** Follows the footer itself, and starts or stops the frame timer with its pulsing. */
  private follow(): void {
    const f = this.footer();
    if (f !== this.listened) {
      if (this.listened !== null) {
        this.listened.removeChangeListener(this.onChange);
      }
      if (f !== null) {
        f.addChangeListener(this.onChange);
      }
      this.listened = f;
    }
    if (f !== null && f.cyl_pulsing) {
      this.startTimer();
    } else {
      this.stopTimer();
    }
  }

  private startTimer(): void {
    if (this.timer >= 0) {
      return;
    }
    this.startedAt = Date.now();
    this.timer = setInterval(() => {
      this.elapsed = (Date.now() - this.startedAt) / 1000;
    }, CYLRefreshBallPulseFrame);
  }

  private stopTimer(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    this.elapsed = 0;
  }

  private radius(): number {
    return CYLRefreshBallPulseRadius(this.viewW, this.viewH);
  }

  private scaleOf(index: number): number {
    const f = this.footer();
    return f !== null && f.cyl_pulsing ? CYLRefreshBallPulseScale(this.elapsed, index) : 1;
  }

  private colorOf(): string {
    const f = this.footer();
    return f !== null ? f.cyl_ballColor : '#EEEEEE';
  }

  private labelOf(): string {
    const f = this.footer();
    const label = f !== null ? f.cyl_accessibilityLabel : null;
    return label !== null ? label : '';
  }

  private hidden(): boolean {
    const f = this.footer();
    return f === null || f.cyl_ballsHidden || this.viewW <= 0;
  }

  @Builder
  ball(index: number) {
    Circle()
      .width(this.radius() * 2)
      .height(this.radius() * 2)
      .fill(this.colorOf())
      .scale({ x: this.scaleOf(index), y: this.scaleOf(index), centerX: '50%', centerY: '50%' })
      .position({
        x: CYLRefreshBallPulseCenterX(this.viewW, this.radius(), index) - this.radius(),
        y: this.viewH / 2 - this.radius()
      })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (!this.hidden()) {
        this.ball(0)
        this.ball(1)
        this.ball(2)
      }
    }
    .width('100%')
    .height('100%')
    .accessibilityGroup(true)
    .accessibilityText(this.labelOf())
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.viewW = Number(newValue.width);
      this.viewH = Number(newValue.height);
    })
  }
}
