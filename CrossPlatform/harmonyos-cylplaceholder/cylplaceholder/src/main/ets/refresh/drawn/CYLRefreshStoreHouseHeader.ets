// CYLRefreshStoreHouseHeader: the HarmonyOS counterpart of iOS Custom/Drawn/CYLRefreshStoreHouseHeader.h (after
// CRefreshLayout StoreHouse): text drawn as line segments that fly in while pulling, flash one by one while refreshing
// (a CYLRefreshValueAnimator dims them, a 75 ms timer lights the next) and fade out when the refresh ends.
import { CYLRefreshPhase, CYLRefreshScrollMode } from '../CYLRefreshConst';
import { CYLRefreshAffineTransform, CYLRefreshDrawnColor, CYLRefreshRect } from './CYLRefreshDrawnSupport';
import { CYLRefreshDrawnHeaderModel } from './CYLRefreshDrawnHeader';
import { CYLRefreshStoreHouseLine, CYLRefreshStoreHousePath } from './CYLRefreshStoreHouse';
import { CYLRefreshValueAnimator } from './CYLRefreshValueAnimator';

const darkAlpha: number = 0.4;
const internalAnimationFactor: number = 0.7;
const DEFAULT_SCALE: number = 1.0;
const DEFAULT_PADDING: number = 1.5;

export class CYLRefreshStoreHouseHeaderModel extends CYLRefreshDrawnHeaderModel {
  /** Width of the line segments, in vp (`lineWidth`). */
  lineWidth: number = 2;
  /** Flashes the segments in reverse order while refreshing (`enableReverseFlash`). */
  enableReverseFlash: boolean = false;
  /** The drawn segments. */
  lines: CYLRefreshStoreHouseLine[] = [];
  private fade: boolean = true;
  private padding: number = DEFAULT_PADDING;
  private linesRect: CYLRefreshRect = CYLRefreshRect.zero();
  private animatorLoading: CYLRefreshValueAnimator | null = null;
  private animatorFinishing: CYLRefreshValueAnimator | null = null;
  private timerLoading: number = -1;
  private flashIndex: number = 0;

  constructor() {
    super();
    this.enableFadeAnimation = true;
    this.initLinesWithString('store house');
  }

  /**
   * A header drawing `string`, scaled by `scale`, with `padding` (`+newWithString:`, `+newWithString:scale:`,
   * `+newWithString:scale:padding:`).
   */
  static newWithString(string: string, scale: number = DEFAULT_SCALE,
    padding: number = DEFAULT_PADDING): CYLRefreshStoreHouseHeaderModel {
    const header = new CYLRefreshStoreHouseHeaderModel();
    header.initLinesWithString(string, scale, padding);
    return header;
  }

  setUpComponent(): void {
    super.setUpComponent();
    this.scrollMode = CYLRefreshScrollMode.Stretch;
    this.colorAccent = '#ffffff';
    this.colorPrimary = 'rgb(77,77,77)';
  }

  /** Fades the segments out when the refresh ends; holds the header 0.5 s (`enableFadeAnimation`). */
  get enableFadeAnimation(): boolean {
    return this.fade;
  }

  set enableFadeAnimation(value: boolean) {
    this.fade = value;
    this.finishDuration = value ? 0.5 : 0;
  }

  /**
   * Replaces the text, scaled by `scale`, with `padding` (above 5: vp, else times the text height)
   * (`-initLinesWithString:`, `-initLinesWithString:scale:`, `-initLinesWithString:scale:padding:`).
   */
  initLinesWithString(string: string, scale: number = DEFAULT_SCALE, padding: number = DEFAULT_PADDING): void {
    this.lines = CYLRefreshStoreHousePath.linesFrom(string, scale, 10);
    this.padding = padding;
    this.updateLinesRect();
  }

  /** Draws custom segments from point strings, two per segment (`-initLinesWithArray:`, `-initLinesWithArray:padding:`). */
  initLinesWithArray(array: string[], padding: number = 0.5): void {
    this.lines = CYLRefreshStoreHousePath.linesFromArray(array);
    this.padding = padding;
    this.updateLinesRect();
  }

  private updateLinesRect(): void {
    let w = 0;
    let h = 0;
    this.lines.forEach((line: CYLRefreshStoreHouseLine) => {
      w = Math.max(w, line.end.x, line.start.x);
      h = Math.max(h, line.end.y, line.start.y);
    });
    const padding = this.padding > 5 ? this.padding : this.padding * h;
    this.linesRect = new CYLRefreshRect(this.width / 2 - w / 2, padding, w, h);
    this.height = padding * 2 + h;
  }

  cyl_layoutWidth(width: number): void {
    this.linesRect.x = width / 2 - this.linesRect.width / 2;
  }

  onScrollingWithOffset(offset: number, percent: number, isDragging: boolean): void {
    if (this.status !== CYLRefreshPhase.Finishing) {
      this.updateLinesWithProgress(percent);
    }
  }

  onStartAnimationWhenRealeasing(): void {
    super.onStartAnimationWhenRealeasing();
    const loading = CYLRefreshValueAnimator.newWithTarget(this, (a: CYLRefreshValueAnimator) => this.onAnimationLoading(a));
    loading.repeatCount = Infinity;
    loading.start();
    this.animatorLoading = loading;
    if (this.timerLoading >= 0) {
      clearInterval(this.timerLoading);
    }
    this.timerLoading = setInterval(() => this.onAnimationTimer(), 75);
  }

  onRefreshFinishing(success: boolean): number {
    if (!success) {
      return 0;
    }
    const finishing = CYLRefreshValueAnimator.newWithTarget(this,
      (a: CYLRefreshValueAnimator) => this.onAnimationFinishing(a));
    finishing.setFrom(1, 0);
    finishing.duration = this.finishDuration * 3;
    finishing.start();
    this.animatorFinishing = finishing;
    return this.finishDuration;
  }

  cyl_isAnimating(): boolean {
    return this.animatorFinishing !== null && this.animatorFinishing.isRunning;
  }

  private onAnimationTimer(): void {
    if (this.cyl_isRefreshing()) {
      const n = this.lines.length;
      if (this.flashIndex < n) {
        this.flashIndex++;
        this.lines[this.enableReverseFlash ? n - this.flashIndex : this.flashIndex - 1].alpha = 1;
      } else if (++this.flashIndex - n === 2) {
        this.flashIndex = 0;
      }
    } else {
      this.flashIndex = 0;
      clearInterval(this.timerLoading);
      this.timerLoading = -1;
    }
  }

  private onAnimationLoading(animator: CYLRefreshValueAnimator): void {
    if (this.cyl_isRefreshing()) {
      this.lines.forEach((line: CYLRefreshStoreHouseLine) => {
        if (line.alpha > darkAlpha) {
          line.alpha -= 0.01;
        }
      });
    } else {
      animator.stop();
    }
  }

  private onAnimationFinishing(animator: CYLRefreshValueAnimator): void {
    if (this.status === CYLRefreshPhase.Finishing) {
      this.updateLinesWithProgress(animator.value);
    } else {
      animator.stop();
    }
  }

  /** Each segment's transform and alpha for the pull progress (`-updateLinesWithProgress:`). */
  updateLinesWithProgress(progress: number): void {
    const len = this.lines.length;
    const refreshing = this.cyl_isRefreshing();
    for (let i = 0; i < len; i++) {
      const paddingStart = (1 - internalAnimationFactor) / len * i;
      const paddingEnd = 1 - internalAnimationFactor - paddingStart;
      const line = this.lines[i];
      if (progress === 1 || progress >= 1 - paddingEnd) {
        line.alpha = refreshing ? line.alpha : darkAlpha;
        line.transform = CYLRefreshAffineTransform.identity();
      } else if (progress === 0) {
        line.transform = CYLRefreshAffineTransform.makeTranslation(line.offset * this.width, -this.expandHeight);
      } else if (!refreshing) {
        const realProgress = progress <= paddingStart ? 0 : Math.min(1, (progress - paddingStart) /
          internalAnimationFactor);
        line.transform = CYLRefreshAffineTransform.makeTranslation(line.offset * this.width * (1 - realProgress),
          -this.expandHeight * (1 - realProgress))
          .translate(line.middle.x, line.middle.y)
          .rotate(Math.PI * realProgress)
          .scale(realProgress, realProgress)
          .translate(-line.middle.x, -line.middle.y);
        line.alpha = realProgress * darkAlpha;
      }
    }
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    const width = this.width;
    ctx.fillStyle = this.cyl_primaryColor;
    ctx.fillRect(0, 0, width, this.dragOffset);
    ctx.lineWidth = this.lineWidth;
    ctx.translate(this.linesRect.x, this.linesRect.y);
    const accent = this.cyl_accentColor;
    this.lines.forEach((line: CYLRefreshStoreHouseLine) => {
      const t = line.transform;
      ctx.strokeStyle = CYLRefreshDrawnColor.alpha(accent, line.alpha);
      ctx.save();
      ctx.transform(t.a, t.b, t.c, t.d, t.tx, t.ty);
      ctx.beginPath();
      ctx.moveTo(line.start.x, line.start.y);
      ctx.lineTo(line.end.x, line.end.y);
      ctx.stroke();
      ctx.restore();
    });
  }
}
