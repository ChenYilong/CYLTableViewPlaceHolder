// CYLRefreshDrawnShapes: the drawn styles made of plain shapes, the HarmonyOS counterparts of iOS
// CYLRefreshBezierCircleHeader, CYLRefreshBezierRadarHeader, CYLRefreshMaterialHeader, CYLRefreshOriginalHeader and
// CYLRefreshWaveSwipeHeader (CYLRefresh styles). Geometry, colors, durations and the animator chains are those of
// the iOS port; each CYLRefreshValueAnimator chain is stepped from the canvas frame clock (CYLRefreshDrawnTween).
import { CYLRefreshComponentAction, CYLRefreshPhase, CYLRefreshScrollMode } from '../CYLRefreshConst';
import { CYLRefreshDrawnColor, CYLRefreshDrawnEase, CYLRefreshDrawnTween, cylRefreshCubicBezier } from './CYLRefreshDrawnSupport';
import { CYLRefreshDrawnHeaderModel } from './CYLRefreshDrawnHeader';
import { CYLRefreshValueAnimator } from './CYLRefreshValueAnimator';

const easeLinear: CYLRefreshDrawnEase = (t: number): number => t;
const easeAccelerate: CYLRefreshDrawnEase = (t: number): number => CYLRefreshValueAnimator.accelerate(t);
const easeDecelerate: CYLRefreshDrawnEase = (t: number): number => CYLRefreshValueAnimator.decelerate(t);
const easeAccelDecel: CYLRefreshDrawnEase = (t: number): number => CYLRefreshValueAnimator.accelerateDecelerate(t);
const easeBounce: CYLRefreshDrawnEase = (t: number): number => CYLRefreshValueAnimator.bounce(t);
/** Android's FastOutSlowInInterpolator, the table the iOS Material spinner samples. */
const easeFastOutSlowIn: CYLRefreshDrawnEase = cylRefreshCubicBezier(0.4, 0, 0.2, 1);

/** CYLRefreshValueAnimator `setFromToPoints:`: piecewise linear over the eased time. */
function cylFromPoints(points: number[], t: number): number {
  const count = points.length;
  for (let i = 0; i < count - 1; i++) {
    const start = i / count;
    const end = (i + 1) / count;
    if (t >= start && t < end) {
      return points[i] + (points[i + 1] - points[i]) * ((t - start) / (end - start));
    }
  }
  return points[0];
}

function cylCircle(ctx: CanvasRenderingContext2D, x: number, y: number, r: number): void {
  ctx.beginPath();
  ctx.arc(x, y, Math.max(0, r), 0, Math.PI * 2);
  ctx.fill();
}

function cylShadow(ctx: CanvasRenderingContext2D, on: boolean, blur: number, alpha: number): void {
  ctx.shadowColor = on ? 'rgba(0,0,0,' + alpha + ')' : 'rgba(0,0,0,0)';
  ctx.shadowOffsetX = 0;
  ctx.shadowOffsetY = on ? 1 : 0;
  ctx.shadowBlur = on ? blur : 0;
}

// MARK: - BezierCircle

/** A ball that drops out of a bezier wave and spins while refreshing (iOS `CYLRefreshBezierCircleHeader`). */
export class CYLRefreshBezierCircleHeaderModel extends CYLRefreshDrawnHeaderModel {
  private waveHeight: number = 0;
  private wavePulling: boolean = false;
  private bollRadius: number = 0;
  private bollY: number = 0;
  private springRatio: number = 0;
  private animatorSpeed: number = 0;
  private animatorHeight: number = 0;
  private animatorSpringRatio: number = 0;
  private animatorSpringBollY: number = 0;
  private animatorStatus: number = 0;
  private showOuter: boolean = false;
  private showBoll: boolean = false;
  private showBollTail: boolean = false;
  private outerIsStart: boolean = true;
  private refreshStart: number = 90;
  private refreshStop: number = 90;
  private rebound: CYLRefreshDrawnTween | null = null;
  private points: number[] = [];
  private spinning: boolean = false;

  /** A Bezier circle header calling `block` when it refreshes. */
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshBezierCircleHeaderModel {
    const header = new CYLRefreshBezierCircleHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  setUpComponent(): void {
    super.setUpComponent();
    this.height = 100;
    this.finishDuration = 0.8;
    this.scrollMode = CYLRefreshScrollMode.Stretch;
    this.colorAccent = '#ffffff';
    this.colorPrimary = '#1199ff';
  }

  private reset(): void {
    this.waveHeight = 0;
    this.wavePulling = false;
    this.springRatio = 0;
    this.animatorStatus = 0;
    this.showOuter = false;
    this.showBoll = false;
    this.showBollTail = false;
    this.outerIsStart = true;
    this.refreshStart = 90;
    this.refreshStop = 90;
    this.rebound = null;
    this.spinning = false;
  }

  private startRefreshing(): void {
    this.showOuter = true;
    this.showBollTail = false;
    this.outerIsStart = true;
    this.refreshStart = 90;
    this.refreshStop = 90;
    this.spinning = true;
  }

  onScrollingWithOffset(offset: number, percent: number, isDragging: boolean): void {
    if (this.inStatus(CYLRefreshPhase.PullToRefresh, CYLRefreshPhase.ReleaseToRefresh) || (isDragging &&
      this.status === CYLRefreshPhase.Idle)) {
      this.wavePulling = true;
      this.waveHeight = 0.8 * Math.max(0, offset - this.expandHeight);
    }
  }

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if (status === CYLRefreshPhase.Idle || status === CYLRefreshPhase.PullToRefresh) {
      this.reset();
    }
  }

  onStartAnimationWhenRealeasing(): void {
    const expand = this.expandHeight;
    this.wavePulling = false;
    this.bollRadius = expand / 6;
    this.animatorSpeed = 0;
    this.animatorStatus = 0;
    this.animatorSpringRatio = 0;
    this.springRatio = 0;
    this.animatorHeight = Math.min(this.waveHeight * 0.8, expand / 2);
    if (this.animatorHeight <= 0) {
      this.showBoll = true;
      this.startRefreshing();
      this.bollY = expand / 2;
      this.waveHeight = 0;
      return;
    }
    const wh = this.waveHeight;
    this.points = [wh, 0, -this.animatorHeight, 0, -this.animatorHeight * 0.4, 0];
    this.rebound = new CYLRefreshDrawnTween(0, 1, this.durationNormal * 4, easeDecelerate, this.cyl_clock());
  }

  cyl_isAnimating(): boolean {
    return this.rebound !== null;
  }

  private step(now: number): void {
    const head = this.expandHeight;
    const rebound = this.rebound;
    if (rebound !== null) {
      const f = rebound.fraction(now);
      const done = rebound.done(now);
      const cur = done ? 0 : cylFromPoints(this.points, rebound.ease(f));
      if (this.animatorStatus === 0 && cur <= 0) {
        this.animatorStatus = 1;
        this.animatorSpeed = Math.abs(cur - this.waveHeight);
      }
      if (this.animatorStatus === 1) {
        this.animatorSpringRatio = -cur / this.animatorHeight;
        if (this.animatorSpringRatio >= this.springRatio) {
          this.springRatio = this.animatorSpringRatio;
          this.bollY = head + cur;
          this.animatorSpeed = Math.abs(cur - this.waveHeight);
        } else {
          this.animatorStatus = 2;
          this.springRatio = 0;
          this.showBoll = true;
          this.showBollTail = true;
          this.animatorSpringBollY = this.bollY;
        }
      }
      if (this.animatorStatus === 2 && this.bollY > head / 2) {
        this.bollY = Math.max(head / 2, this.bollY - this.animatorSpeed);
        const bally = f * (head / 2 - this.animatorSpringBollY) + this.animatorSpringBollY;
        if (this.bollY > bally) {
          this.bollY = bally;
        }
      }
      if (this.showBollTail && cur < this.waveHeight) {
        this.startRefreshing();
      }
      if (!this.wavePulling) {
        this.waveHeight = cur;
      }
      if (done) {
        this.rebound = null;
        if (!this.showBoll) {
          this.showBoll = true;
          this.bollY = head / 2;
          this.startRefreshing();
        }
      }
    }
    if (this.spinning) {
      const k = Math.max(1, Math.round(this.cyl_frameSeconds * 60));
      for (let i = 0; i < k; i++) {
        this.refreshStart = (this.refreshStart + (this.outerIsStart ? 3 : 10)) % 360;
        this.refreshStop = (this.refreshStop + (this.outerIsStart ? 10 : 3)) % 360;
        let swipe = this.refreshStop - this.refreshStart;
        if (swipe < 0) {
          swipe += 360;
        }
        if (swipe >= 270) {
          this.outerIsStart = false;
        } else if (swipe <= 10) {
          this.outerIsStart = true;
        }
      }
    }
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    const w = this.width;
    const h = this.dragOffset;
    const expand = this.expandHeight;
    const accent = this.cyl_accentColor;
    this.step(this.cyl_now);
    // drawWave
    ctx.fillStyle = this.cyl_primaryColor;
    const base = Math.min(expand, h);
    if (this.waveHeight !== 0) {
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(w, 0);
      ctx.lineTo(w, base);
      ctx.quadraticCurveTo(w / 2, base + this.waveHeight * 2, 0, base);
      ctx.closePath();
      ctx.fill();
    } else {
      ctx.fillRect(0, 0, w, base);
    }
    // drawSpringUp
    const r = this.bollRadius;
    if (this.springRatio > 0) {
      ctx.fillStyle = accent;
      const leftX = w / 2 - 4 * r + this.springRatio * 3 * r;
      if (this.springRatio < 0.9) {
        ctx.beginPath();
        ctx.moveTo(leftX, this.bollY);
        ctx.quadraticCurveTo(w / 2, this.bollY - r * this.springRatio * 2, w - leftX, this.bollY);
        ctx.closePath();
        ctx.fill();
      } else {
        cylCircle(ctx, w / 2, this.bollY, r);
      }
    }
    // drawBoll + drawBollTail
    if (this.showBoll) {
      ctx.fillStyle = accent;
      cylCircle(ctx, w / 2, this.bollY, r);
      if (this.showBollTail) {
        const fraction = (expand + this.waveHeight) / expand;
        const bottom = expand + this.waveHeight;
        const startY = this.bollY + r * fraction / 2;
        const startX = w / 2 + Math.sqrt(Math.max(0, r * r * (1 - fraction * fraction / 4)));
        const b1x = w / 2 + r * 3 / 4 * (1 - fraction);
        const b2x = b1x + r;
        ctx.beginPath();
        ctx.moveTo(startX, startY);
        ctx.quadraticCurveTo(b1x, bottom, b2x, bottom);
        ctx.lineTo(w - b2x, bottom);
        ctx.quadraticCurveTo(w - b1x, bottom, w - startX, startY);
        ctx.closePath();
        ctx.fill();
      }
    }
    // drawOuter
    if (this.showOuter) {
      ctx.strokeStyle = accent;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(w / 2, this.bollY, r + 4, this.refreshStart * Math.PI / 180, this.refreshStop * Math.PI / 180);
      ctx.stroke();
    }
  }
}

// MARK: - BezierRadar

/** A bezier wave that turns into a radar scan while refreshing (iOS `CYLRefreshBezierRadarHeader`). */
export class CYLRefreshBezierRadarHeaderModel extends CYLRefreshDrawnHeaderModel {
  private waveTop: number = 0;
  private waveHeight: number = 0;
  private wavePulling: boolean = false;
  private dotFraction: number = 0;
  private dotAlpha: number = 1;
  private radarScale: number = 0;
  private radarAngle: number = 0;
  private rippleRadius: number = 0;
  private aDot: CYLRefreshDrawnTween | null = null;
  private aScale: CYLRefreshDrawnTween | null = null;
  private aRadar: CYLRefreshDrawnTween | null = null;
  private aWave: CYLRefreshDrawnTween | null = null;
  private wavePoints: number[] = [];
  private aRipple: CYLRefreshDrawnTween | null = null;

  setUpComponent(): void {
    super.setUpComponent();
    this.height = 100;
    this.finishDuration = 0.3;
    this.scrollMode = CYLRefreshScrollMode.Stretch;
    this.colorAccent = '#ffffff';
    this.colorPrimary = '#1199ff';
  }

  private resetRadar(): void {
    this.dotAlpha = 1;
    this.radarScale = 0;
    this.waveHeight = 0;
    this.aDot = null;
    this.aScale = null;
    this.aRadar = null;
    this.aWave = null;
  }

  onScrollingWithOffset(offset: number, percent: number, isDragging: boolean): void {
    if (this.status === CYLRefreshPhase.Refreshing || this.status === CYLRefreshPhase.Releasing) {
      return;
    }
    if (isDragging || !this.cyl_driven) {
      this.wavePulling = true;
      this.waveTop = Math.min(this.expandHeight, offset);
      this.waveHeight = 1.9 * Math.max(0, offset - this.expandHeight);
      this.dotFraction = percent;
    }
  }

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if (status === CYLRefreshPhase.Finishing) {
      const w = this.width;
      const h = this.dragOffset;
      this.aRipple = new CYLRefreshDrawnTween(20, Math.sqrt(w * w + h * h), this.finishDuration, easeAccelerate,
        this.cyl_clock());
      this.resetRadar();
    } else if (status === CYLRefreshPhase.PullToRefresh || status === CYLRefreshPhase.Idle) {
      this.resetRadar();
      if (status === CYLRefreshPhase.Idle) {
        this.aRipple = null;
        this.rippleRadius = 0;
      }
    }
  }

  onStartAnimationWhenRealeasing(): void {
    const now = this.cyl_clock();
    this.wavePulling = false;
    this.waveTop = this.expandHeight;
    this.aDot = new CYLRefreshDrawnTween(1, 0, this.durationNormal, easeDecelerate, now);
    const wh = this.waveHeight;
    this.wavePoints = [wh, 0, wh * -0.5, 0, wh * -0.2, 0];
    this.aWave = new CYLRefreshDrawnTween(0, 1, this.durationNormal * 3.6, easeDecelerate, now);
  }

  cyl_isAnimating(): boolean {
    return this.aDot !== null || this.aScale !== null || this.aWave !== null || this.aRipple !== null;
  }

  private step(now: number): void {
    const aDot = this.aDot;
    if (aDot !== null) {
      this.dotAlpha = aDot.value(now);
      if (aDot.done(now)) {
        this.dotAlpha = 0;
        this.aDot = null;
        this.aScale = new CYLRefreshDrawnTween(0, 1, this.durationNormal, easeDecelerate, now);
      }
    }
    const aScale = this.aScale;
    if (aScale !== null) {
      this.radarScale = aScale.value(now);
      if (aScale.done(now)) {
        this.radarScale = 1;
        this.aScale = null;
        this.aRadar = CYLRefreshDrawnTween.repeating(0, 360, this.durationNormal * 3, easeAccelDecel, now, false);
      }
    }
    const aRadar = this.aRadar;
    if (aRadar !== null) {
      this.radarAngle = aRadar.value(now);
    }
    const aWave = this.aWave;
    if (aWave !== null) {
      if (this.wavePulling) {
        this.aWave = null;
      } else {
        const done = aWave.done(now);
        this.waveHeight = done ? 0 : cylFromPoints(this.wavePoints, aWave.ease(aWave.fraction(now)));
        if (done) {
          this.aWave = null;
        }
      }
    }
    const aRipple = this.aRipple;
    if (aRipple !== null) {
      this.rippleRadius = aRipple.value(now);
      if (aRipple.done(now)) {
        this.aRipple = null;
      }
    }
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    const w = this.width;
    const h = this.dragOffset;
    const accent = this.cyl_accentColor;
    const primary = this.cyl_primaryColor;
    if (this.cyl_driven && this.status === CYLRefreshPhase.Idle) {
      this.waveTop = this.expandHeight;
      this.dotFraction = 1;
    }
    this.step(this.cyl_now);
    // drawWave
    ctx.fillStyle = primary;
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(0, this.waveTop);
    ctx.quadraticCurveTo(w / 2, this.waveTop + this.waveHeight, w, this.waveTop);
    ctx.lineTo(w, 0);
    ctx.closePath();
    ctx.fill();
    // drawDot
    if (this.dotAlpha > 0) {
      const num = 7;
      const f = this.dotFraction;
      const wide = (w / num) * f - (f > 1 ? ((f - 1) * (w / num)) / f : 0);
      const high = h - (f > 1 ? ((f - 1) * h) / 2 / f : 0);
      for (let i = 0; i < num; i++) {
        const index = 1 + i - (1 + num) / 2;
        const alphaX = 255 * (1 - 2 * (Math.abs(index) / num));
        const alphaY = this.dotAlpha * alphaX * (1 - 1 / Math.pow(h / 800 + 1, 15));
        ctx.fillStyle = CYLRefreshDrawnColor.alpha(accent, alphaY / 255);
        const radius = 7 * (1 - 1 / (h / 10 + 1));
        cylCircle(ctx, w / 2 - radius / 2 + wide * index, high / 2, radius);
      }
    }
    // drawRadar
    if (this.status === CYLRefreshPhase.Refreshing) {
      const radius = 20 * this.radarScale;
      const circle = 7 * this.radarScale;
      const cx = w / 2;
      const cy = h / 2;
      ctx.fillStyle = accent;
      ctx.strokeStyle = accent;
      ctx.lineWidth = 3;
      cylCircle(ctx, cx, cy, radius);
      ctx.beginPath();
      ctx.arc(cx, cy, radius + circle, 0, Math.PI * 2);
      ctx.stroke();
      const end = this.radarAngle * Math.PI / 180;
      ctx.fillStyle = CYLRefreshDrawnColor.alpha(primary, 0.33);
      ctx.strokeStyle = CYLRefreshDrawnColor.alpha(primary, 0.33);
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.arc(cx, cy, radius, 3 * Math.PI / 2, end);
      ctx.closePath();
      ctx.fill();
      ctx.beginPath();
      ctx.arc(cx, cy, radius + circle, 3 * Math.PI / 2, end);
      ctx.stroke();
    }
    // drawRipple
    if (this.rippleRadius > 0) {
      ctx.fillStyle = accent;
      cylCircle(ctx, w / 2, h / 2, this.rippleRadius);
    }
  }
}

// MARK: - Material

const kCircleSize: number = 40;
const kMaxArrowSize: number = 2;
const kMaxArrowRadius: number = 8;
const MAX_PROGRESS_ARC: number = 0.8;
const NUM_POINTS: number = 5;
const FULL_ROTATION: number = 1080;
const SPINNER_DURATION: number = 1.332;
const MATERIAL_SCHEME: string[] = ['#0099cc', '#ff4444', '#669900', '#aa66cc', '#ff8800'];
const MIN_PROGRESS_ARC: number = (kMaxArrowSize / (2 * Math.PI * kMaxArrowRadius)) * Math.PI / 180;

/** The Material progress arc with its arrow head, as the current path (begin / end / rotate in turns). */
function cylArrowPath(ctx: CanvasRenderingContext2D, ox: number, oy: number, begin: number, end: number,
  rotate: number, scale: number): void {
  const size = kMaxArrowSize;
  const big = kMaxArrowRadius + size / 2;
  const small = kMaxArrowRadius - size / 2;
  const angleEnd = Math.max(begin, end);
  const angleStart = Math.min(begin, end);
  const pct = Math.min(1, Math.max(0, angleEnd - angleStart));
  const adjust = (1 - pct) * 2 * Math.PI - Math.PI / 2;
  ctx.save();
  ctx.translate(ox, oy);
  ctx.rotate(angleEnd * 2 * Math.PI + rotate * 2 * Math.PI);
  ctx.beginPath();
  ctx.arc(0, 0, big, adjust, 1.5 * Math.PI, false);
  if (scale > 0.3) {
    const cy = -big + size / 2;
    ctx.lineTo(0, cy + (-big - size - cy) * scale);
    ctx.lineTo(2 * size * scale, cy + (-big + size / 2 - cy) * scale);
    ctx.lineTo(0, cy + (-big + 2 * size - cy) * scale);
    ctx.lineTo(0, cy + (-big + size - cy) * scale);
  }
  ctx.arc(0, 0, small, 1.5 * Math.PI, adjust, true);
  ctx.closePath();
  ctx.restore();
}

/** The Material spinner's trims and rotation, shared by Material and WaveSwipe. */
class CYLMaterialSpinner {
  color: number = 0;
  finishing: boolean = false;
  start: number = 0;
  startTrim: number = 0;
  endTrim: number = 0;
  rotation: number = 0;
  arrowScale: number = 0;
  bStart: number = 0;
  bEnd: number = 0;
  bRot: number = 0;
  count: number = 0;

  /** onStartAnimationWhenRefreshing: trims the pulled arc first when there is one, then spins. */
  begin(now: number, nextColor: boolean): void {
    if (nextColor) {
      this.color = (this.color + 1) % MATERIAL_SCHEME.length;
    }
    this.count = 0;
    this.bStart = this.startTrim;
    this.bEnd = this.endTrim;
    this.bRot = this.rotation;
    this.start = now;
    if (this.startTrim !== this.endTrim) {
      this.finishing = true;
    } else {
      this.finishing = false;
      this.startTrim = 0;
      this.endTrim = 0;
      this.rotation = 0;
      this.bStart = 0;
      this.bEnd = 0;
      this.bRot = 0;
    }
  }

  reset(): void {
    this.finishing = false;
    this.color = 0;
    this.startTrim = 0;
    this.endTrim = 0;
    this.rotation = 0;
  }

  /** One frame of the refreshing spin; returns the arrow scale to draw with. */
  step(now: number, nextColor: boolean): number {
    if (this.finishing) {
      const t = Math.min(1, (now - this.start) / (SPINNER_DURATION * 500));
      const target = Math.floor(this.bRot / MAX_PROGRESS_ARC) + 1;
      this.startTrim = this.bStart + (this.bEnd - MIN_PROGRESS_ARC - this.bStart) * t;
      this.endTrim = this.bEnd;
      this.rotation = this.bRot + (target - this.bRot) * t;
      if (t >= 1) {
        if (nextColor) {
          this.color = (this.color + 1) % MATERIAL_SCHEME.length;
        }
        this.bStart = this.startTrim;
        this.bEnd = this.endTrim;
        this.bRot = this.rotation;
        this.startTrim = this.endTrim;
        this.finishing = false;
        this.start = now;
      }
      return this.arrowScale;
    }
    let t = (now - this.start) / (SPINNER_DURATION * 1000);
    while (t >= 1) {
      if (nextColor) {
        this.color = (this.color + 1) % MATERIAL_SCHEME.length;
      }
      this.bStart = this.startTrim;
      this.bEnd = this.endTrim;
      this.bRot = this.rotation;
      this.startTrim = this.endTrim;
      this.count = (this.count + 1) % NUM_POINTS;
      this.start += SPINNER_DURATION * 1000;
      t -= 1;
    }
    if (t <= 0.5) {
      this.startTrim = this.bStart + (MAX_PROGRESS_ARC - MIN_PROGRESS_ARC) * easeFastOutSlowIn(t / 0.5);
    }
    if (t > 0.5) {
      this.endTrim = this.bEnd + (MAX_PROGRESS_ARC - MIN_PROGRESS_ARC) * easeFastOutSlowIn((t - 0.5) / 0.5);
    }
    const group = (FULL_ROTATION / NUM_POINTS) * t + FULL_ROTATION * (this.count / NUM_POINTS);
    this.rotation = this.bRot + 0.25 * t + group / 360;
    return 0;
  }

  colorFor(accent: string): string {
    return CYLRefreshDrawnColor.isClear(accent) ? MATERIAL_SCHEME[this.color] : accent;
  }
}

function cylStrokeArrow(ctx: CanvasRenderingContext2D, color: string): void {
  ctx.fillStyle = color;
  ctx.fill();
  ctx.lineWidth = 0.5;
  ctx.strokeStyle = 'rgba(85,85,85,0.5)';
  ctx.stroke();
}

/** The Material Design swipe-refresh spinner, floating in front of the content (iOS `CYLRefreshMaterialHeader`). */
export class CYLRefreshMaterialHeaderModel extends CYLRefreshDrawnHeaderModel {
  private spinner: CYLMaterialSpinner = new CYLMaterialSpinner();

  setUpComponent(): void {
    super.setUpComponent();
    this.height = kCircleSize * 2;
    this.finishDuration = 0.2;
    this.scrollMode = CYLRefreshScrollMode.Front;
    this.colorAccent = 'transparent';
    this.colorPrimary = '#ffffff';
    this.cyl_passesTouches = true;
  }

  cyl_overflowHeight(): number {
    return kCircleSize * 4 + 10;
  }

  onStartAnimationWhenRefreshing(): void {
    this.spinner.begin(this.cyl_clock(), CYLRefreshDrawnColor.isClear(this.cyl_accentColor));
  }

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if ((status === CYLRefreshPhase.Idle || status === CYLRefreshPhase.PullToRefresh) &&
      (oldStatus === CYLRefreshPhase.Finishing || oldStatus === CYLRefreshPhase.Refreshing)) {
      this.spinner.reset();
    }
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    const radius = kCircleSize / 2;
    const s = this.spinner;
    const accent = this.cyl_accentColor;
    let ox = Math.floor(this.width / 2);
    let oy = this.expandHeight / 2;
    let scale = 0;
    let p = 1;
    if (this.inStatus(CYLRefreshPhase.Refreshing, CYLRefreshPhase.Finishing)) {
      ox = this.width / 2;
      scale = s.step(this.cyl_now, CYLRefreshDrawnColor.isClear(accent));
    } else {
      const offset = this.dragOffset;
      let distance = Math.max(0, (offset - kCircleSize) / 2);
      distance = kCircleSize * 3 * (1 - Math.pow(8, -distance / (kCircleSize * 6)));
      p = Math.min(distance / kCircleSize, 1);
      oy = distance === 0 ? offset - radius : radius + distance;
      const extra = Math.abs(offset) - this.expandHeight;
      const sling = Math.max(0, Math.min(extra, this.expandHeight * 2) / this.expandHeight);
      const tension = (sling / 4 - Math.pow(sling / 4, 2)) * 2;
      const strokeEnd = Math.min(0.8, p * 0.8);
      s.startTrim = 0;
      s.endTrim = strokeEnd;
      s.arrowScale = Math.min(1, p);
      s.rotation = (0.4 * p + tension * 2) * 0.5;
      scale = s.arrowScale;
    }
    ctx.fillStyle = this.cyl_primaryColor;
    cylShadow(ctx, true, 3, 0.3);
    cylCircle(ctx, ox, oy, radius);
    cylShadow(ctx, false, 0, 0);
    ctx.beginPath();
    ctx.arc(ox, oy, radius, 0, Math.PI, true);
    ctx.arc(ox, oy + 1.25, radius, Math.PI, 0, false);
    ctx.fillStyle = 'rgba(255,255,255,0.2)';
    ctx.fill();
    if (p > 0) {
      cylArrowPath(ctx, ox, oy, s.startTrim, s.endTrim, s.rotation, scale);
      cylStrokeArrow(ctx, s.colorFor(accent));
    }
  }
}

// MARK: - Original

const kMinTopPadding: number = 9;
const kMaxTopPadding: number = 5;
const kMinTopRadius: number = 12.5;
const kMaxTopRadius: number = 16;
const kMinBottomRadius: number = 3;
const kMaxBottomRadius: number = 16;
const kMinBottomPadding: number = 4;
const kMaxBottomPadding: number = 6;
const kMinArrowSize: number = 2;
const kMaxArrowSize3: number = 3;
const kMinArrowRadius: number = 5;
const kMaxArrowRadius7: number = 7;
const kMaxDistance: number = 53;

function lerp(a: number, b: number, p: number): number {
  return a + (b - a) * p;
}

/** The original iOS 6 rubber drop that snaps into a spinner (iOS `CYLRefreshOriginalHeader`). */
export class CYLRefreshOriginalHeaderModel extends CYLRefreshDrawnHeaderModel {
  /** Snaps and refreshes as soon as the drop is fully stretched, without waiting for the release (`enableAutoRefresh`). */
  enableAutoRefresh: boolean = true;
  private topX: number = 0;
  private topY: number = kMaxTopPadding + kMaxTopRadius;
  private releaseAt: number = 0;

  setUpComponent(): void {
    super.setUpComponent();
    this.height = kMaxTopRadius * 4;
    this.scrollMode = CYLRefreshScrollMode.Stretch;
    this.colorAccent = '#ffffff';
    this.colorPrimary = 'rgb(155,162,172)';
  }

  onScrollingWithOffset(offset: number, percent: number, isDragging: boolean): void {
    // The drop is fully stretched: it snaps and refreshes at once (enableAutoRefresh), as on iOS.
    const full = kMaxTopRadius + kMaxBottomRadius + kMaxTopPadding + kMaxBottomPadding + kMaxDistance;
    if (this.enableAutoRefresh && isDragging && offset >= full && this.status !== CYLRefreshPhase.Refreshing &&
      !this.cyl_driven) {
      this.beginRefreshing();
    }
  }

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if (status === CYLRefreshPhase.Releasing || (status === CYLRefreshPhase.Refreshing && this.releaseAt === 0)) {
      this.releaseAt = this.cyl_clock();
    } else if (status === CYLRefreshPhase.Idle) {
      this.releaseAt = 0;
    }
  }

  cyl_isAnimating(): boolean {
    return this.releaseAt > 0 && this.cyl_clock() - this.releaseAt < 300;
  }

  private drawActivity(ctx: CanvasRenderingContext2D, x: number, y: number, now: number): void {
    const step = Math.floor(now / 1000 * 12) % 12;
    ctx.save();
    ctx.translate(x, y);
    ctx.lineCap = 'round';
    ctx.lineWidth = 2;
    for (let i = 0; i < 12; i++) {
      const age = (step - i + 12) % 12;
      ctx.strokeStyle = CYLRefreshDrawnColor.alpha('#7f7f7f', 1 - age / 13);
      const a = i / 12 * Math.PI * 2 - Math.PI / 2;
      ctx.beginPath();
      ctx.moveTo(Math.cos(a) * 5, Math.sin(a) * 5);
      ctx.lineTo(Math.cos(a) * 9, Math.sin(a) * 9);
      ctx.stroke();
    }
    ctx.restore();
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    const primary = this.cyl_primaryColor;
    if (this.inStatus(CYLRefreshPhase.Refreshing, CYLRefreshPhase.Releasing, CYLRefreshPhase.Finishing)) {
      const t = this.releaseAt > 0 ? (this.cyl_now - this.releaseAt) / 1000 : 1;
      const tx = this.topX > 0 ? this.topX : Math.floor(this.width / 2);
      if (t < 0.2) {
        const e = Math.min(1, t / 0.15);
        const r = lerp(kMaxTopRadius, lerp(kMinBottomRadius, kMaxBottomRadius, 0.2), 1 - (1 - e) * (1 - e));
        ctx.globalAlpha = t < 0.1 ? 1 : Math.max(0, 1 - (t - 0.1) / 0.1);
        ctx.fillStyle = primary;
        cylShadow(ctx, true, 0.5, 0.4);
        cylCircle(ctx, tx, this.topY, r);
        cylShadow(ctx, false, 0, 0);
        ctx.globalAlpha = 1;
      }
      if (t >= 0.15) {
        this.drawActivity(ctx, this.width / 2, this.expandHeight / 2, this.cyl_now);
      }
      return;
    }
    const offset = this.dragOffset;
    const shift = Math.max(0, offset - (kMaxTopRadius + kMaxBottomRadius + kMaxTopPadding + kMaxBottomPadding));
    const distance = Math.min(kMaxDistance, Math.abs(shift));
    const p = 1 - distance / kMaxDistance;
    const topPad = lerp(kMinTopPadding, kMaxTopPadding, p);
    const rt = lerp(kMinTopRadius, kMaxTopRadius, p);
    const rb = lerp(kMinBottomRadius, kMaxBottomRadius, p);
    const bottomPad = lerp(kMinBottomPadding, kMaxBottomPadding, p);
    const x = Math.floor(this.width / 2);
    let bx = x;
    let by = offset - bottomPad - rb;
    let tyy = by;
    if (distance !== 0) {
      tyy = topPad + rt;
      by = tyy + distance;
    }
    this.topX = x;
    this.topY = tyy;
    // The drop.
    ctx.beginPath();
    ctx.arc(x, tyy, rt, 0, Math.PI, true);
    ctx.bezierCurveTo(lerp(x - rt, bx - rb, 0.1), lerp(tyy, by, 0.2), lerp(x - rt, bx - rb, 0.9), lerp(tyy, by, 0.2),
      bx - rb, by);
    ctx.arc(bx, by, rb, Math.PI, 0, true);
    ctx.bezierCurveTo(lerp(x + rt, bx + rb, 0.9), lerp(tyy, by, 0.2), lerp(x + rt, bx + rb, 0.1), lerp(tyy, by, 0.2),
      x + rt, tyy);
    ctx.closePath();
    ctx.fillStyle = primary;
    cylShadow(ctx, true, 0.5, 0.4);
    ctx.fill();
    cylShadow(ctx, false, 0, 0);
    ctx.lineWidth = 0.5;
    ctx.strokeStyle = 'rgba(85,85,85,0.5)';
    ctx.stroke();
    // The circular arrow and the highlight.
    const size = lerp(kMinArrowSize, kMaxArrowSize3, p);
    const radius = lerp(kMinArrowRadius, kMaxArrowRadius7, p);
    const big = radius + size / 2;
    const small = radius - size / 2;
    ctx.beginPath();
    ctx.arc(x, tyy, big, 0, 1.5 * Math.PI, false);
    ctx.lineTo(x, tyy - big - size);
    ctx.lineTo(x + 2 * size, tyy - big + size / 2);
    ctx.lineTo(x, tyy - big + 2 * size);
    ctx.lineTo(x, tyy - big + size);
    ctx.arc(x, tyy, small, 1.5 * Math.PI, 0, true);
    ctx.closePath();
    ctx.fillStyle = this.cyl_accentColor;
    ctx.fill('evenodd');
    ctx.lineWidth = 0.5;
    ctx.strokeStyle = 'rgba(85,85,85,0.5)';
    ctx.stroke();
    ctx.beginPath();
    ctx.arc(x, tyy, rt, 0, Math.PI, true);
    ctx.arc(x, tyy + 1.25, rt, Math.PI, 0, false);
    ctx.fillStyle = 'rgba(255,255,255,0.2)';
    ctx.fill();
  }
}

// MARK: - WaveSwipe

const WAVE_FIRST: number = 0.1;
const WAVE_SECOND: number = 0.16 + WAVE_FIRST;
const DROP_VERTEX: number = 500;
const DROP_BOUNCE: number = 500;
const DROP_CIRCLE: number = 500;
const WAVE_DURATION: number = 1000;
const DROP_RADIUS: number = kMaxArrowRadius;
const WAVE_BEGIN: number[][] = [[0.1655, 0], [0.4188, -0.0109], [0.4606, -0.0049], [0.4893, 0], [0.4893, 0], [0.5, 0]];
const WAVE_APPEAR: number[][] = [[0.1655, 0], [0.5237, 0.0553], [0.4557, 0.0936], [0.3908, 0.1302], [0.4303, 0.2173],
  [0.5, 0.2173]];
const WAVE_EXPAND: number[][] = [[0.1655, 0], [0.5909, 0], [0.4557, 0.1642], [0.3941, 0.2061], [0.4303, 0.2889],
  [0.5, 0.2889]];

function cylDropBounce(v: number): number {
  if (v < 0.25) {
    return -38.4 * (v - 0.125) * (v - 0.125) + 0.6;
  }
  if (v >= 0.5 && v < 0.75) {
    return -19.2 * (v - 0.625) * (v - 0.625) + 0.3;
  }
  return 0;
}

/** A wave pulled down from the top with a spinner in its drop, in front of the content (iOS `CYLRefreshWaveSwipeHeader`). */
export class CYLRefreshWaveSwipeHeaderModel extends CYLRefreshDrawnHeaderModel {
  private oy: number = 0;
  private release: number = 0;
  private dropFrom: number = 0;
  private circleFrom: number = 0;
  private dropTarget: number = 0;
  private spinner: CYLMaterialSpinner = new CYLMaterialSpinner();
  private refreshAt: number = 0;

  setUpComponent(): void {
    super.setUpComponent();
    this.height = kCircleSize * 3;
    this.finishDuration = 0.2;
    this.scrollMode = CYLRefreshScrollMode.Front;
    this.colorAccent = '#ffffff';
    this.colorPrimary = '#007aff';
    this.cyl_passesTouches = true;
  }

  cyl_overflowHeight(): number {
    return this.width * 0.3;
  }

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if (status === CYLRefreshPhase.Idle || status === CYLRefreshPhase.PullToRefresh) {
      this.release = 0;
      this.refreshAt = 0;
    }
  }

  onStartAnimationWhenRealeasing(): void {
    const w = this.width;
    if (this.dragOffset === 0 || this.oy === 0) {
      this.oy = w * 500 / 1440;
    }
    this.release = this.cyl_clock();
    this.dropFrom = this.oy;
    this.circleFrom = w * 500 / 1440;
    this.dropTarget = Math.min(w, this.expandHeight - DROP_RADIUS * 3 - 6);
  }

  onStartAnimationWhenRefreshing(): void {
    if (this.release === 0) {
      this.onStartAnimationWhenRealeasing();
    }
    this.refreshAt = this.cyl_clock();
    this.spinner.begin(this.refreshAt, false);
  }

  cyl_isAnimating(): boolean {
    return this.release > 0 && this.cyl_clock() - this.release < DROP_VERTEX + DROP_BOUNCE * 1.25 + 100;
  }

  /** The wave of the pull (the three phases of onScrollingWithOffset) as cubic segments; null when flat. */
  private wavePull(w: number, first: number): number[][] | null {
    const second = first - WAVE_FIRST;
    const fin = (first - WAVE_SECOND) / 5;
    const B = WAVE_BEGIN;
    const A = WAVE_APPEAR;
    const E = WAVE_EXPAND;
    if (first < WAVE_FIRST) {
      if (first <= 0.008) {
        return null;
      }
      const m = first;
      return [
        [w * B[0][0], B[0][1], w * B[1][0], w * (B[1][1] + m), w * B[2][0], w * (B[2][1] + m)],
        [w * B[3][0], w * (B[3][1] + m), w * B[4][0], w * (B[4][1] + m), w * B[5][0], w * (B[5][1] + m)],
        [w - w * B[4][0], w * (B[4][1] + m), w - w * B[3][0], w * (B[3][1] + m), w - w * B[2][0], w * (B[2][1] + m)],
        [w - w * B[1][0], w * (B[1][1] + m), w - w * B[0][0], B[0][1], w, 0]
      ];
    }
    const m1 = first;
    const m2 = second;
    let p1x = Math.min(B[1][0] + m2, A[1][0]);
    let p1y = Math.max(B[1][1] + m1 - m2, A[1][1]);
    let p2x = Math.max(B[2][0] - m2, A[2][0]);
    let p2y = Math.max(B[2][1] + m1 - m2, A[2][1]);
    let p3x = Math.max(B[3][0] - m2, A[3][0]);
    let p3y = Math.min(B[3][1] + m1 + m2, A[3][1]);
    let p4x = Math.max(B[4][0] - m2, A[4][0]);
    let p4y = Math.min(B[4][1] + m1 + m2, A[4][1]);
    let p5y = Math.min(B[0][1] + m1 + m2, A[5][1]);
    let p0 = A[0];
    if (first >= WAVE_SECOND) {
      const m3 = fin;
      p1x = Math.min(p1x + m3, E[1][0]);
      p1y = Math.max(p1y - m3, E[1][1]);
      p2x = Math.max(B[2][0] - m2, E[2][0]);
      p2y = Math.min(p2y + m3, E[2][1]);
      p3x = Math.min(p3x + m3, E[3][0]);
      p3y = Math.min(p3y + m3, E[3][1]);
      p4x = Math.max(B[4][0] - m2, E[4][0]);
      p4y = Math.min(p4y + m3, E[4][1]);
      p5y = Math.min(p5y + m3, E[5][1]);
      p0 = E[0];
    }
    this.oy = w * p3y + DROP_RADIUS;
    return [
      [w * p0[0], w * p0[1], w * p1x, w * p1y, w * p2x, w * p2y],
      [w * p3x, w * p3y, w * p4x, w * p4y, w * 0.5, w * p5y],
      [w - w * p4x, w * p4y, w - w * p3x, w * p3y, w - w * p2x, w * p2y],
      [w - w * p1x, w * p1y, w - w * p0[0], w * p0[1], w, 0]
    ];
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    const w = this.width;
    const primary = this.cyl_primaryColor;
    const accent = this.cyl_accentColor;
    const s = this.spinner;
    ctx.fillStyle = primary;
    if (this.release === 0) {
      const seed = this.dragOffset / Math.max(1, w);
      const first = seed * (5 - 2 * seed) / 3.5;
      const segs = this.wavePull(w, first);
      if (segs !== null) {
        cylShadow(ctx, true, 3, 0.3);
        ctx.beginPath();
        ctx.moveTo(0, 0);
        segs.forEach((g: number[]) => ctx.bezierCurveTo(g[0], g[1], g[2], g[3], g[4], g[5]));
        ctx.fill();
        cylShadow(ctx, false, 0, 0);
      }
      const percent = this.dragPercent;
      const drag = Math.min(1, percent);
      const adjusted = Math.max(drag - 0.4, 0) * 5 / 3;
      const sling = percent > 3 ? 2 : percent > 1 ? percent - 1 : 0;
      const tension = (4 - sling) * sling / 8;
      if (percent < 1) {
        s.startTrim = 0;
        s.arrowScale = Math.min(1, adjusted);
        s.endTrim = Math.min(adjusted * 0.8, MAX_PROGRESS_ARC);
      }
      s.rotation = (-0.25 + 0.4 * adjusted + tension * 2) * 0.5;
      if (percent > 0 && segs !== null && first >= WAVE_FIRST) {
        cylArrowPath(ctx, Math.floor(w / 2), this.oy, s.startTrim, s.endTrim, s.rotation, s.arrowScale);
        cylStrokeArrow(ctx, accent);
      }
      return;
    }
    const t = this.cyl_now - this.release;
    if (t < WAVE_DURATION) {
      const hh = Math.min(0.1, 0.2) * w * (1 - easeBounce(t / WAVE_DURATION));
      if (hh > 0.008) {
        cylShadow(ctx, true, 3, 0.3);
        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.quadraticCurveTo(w * 0.25, 0, w * 0.333, hh * 0.5);
        ctx.quadraticCurveTo(w * 0.5, hh * 1.4, w * 0.666, hh * 0.5);
        ctx.quadraticCurveTo(w * 0.75, 0, w, 0);
        ctx.fill();
        cylShadow(ctx, false, 0, 0);
      }
    }
    const cf = Math.min(1, t / DROP_CIRCLE);
    this.oy = this.circleFrom + (this.dropTarget - this.circleFrom) * easeAccelDecel(cf);
    const ox = Math.floor(w / 2);
    const oy = this.oy;
    const R = DROP_RADIUS * 3;
    const vertex = t < DROP_VERTEX ? this.dropFrom * (1 - easeDecelerate(Math.min(1, t / DROP_VERTEX))) : 0;
    const bv = t > DROP_VERTEX ? cylDropBounce(Math.min(1, (t - DROP_VERTEX) / DROP_BOUNCE)) : 0;
    const bhStart = DROP_VERTEX + DROP_BOUNCE * 0.25;
    const bh = t > bhStart ? cylDropBounce(Math.min(1, (t - bhStart) / DROP_BOUNCE)) : 0;
    ctx.fillStyle = primary;
    cylShadow(ctx, true, 3, 0.3);
    ctx.beginPath();
    if (vertex > 0) {
      const arcos = Math.acos(R / (R + vertex));
      ctx.moveTo(ox, oy - R - vertex);
      ctx.arc(ox, oy, R, Math.PI + (Math.PI / 2 - arcos), arcos - Math.PI / 2, true);
      ctx.closePath();
    } else {
      ctx.ellipse(ox, oy, R * (1 + bv), R * (1 + bh), 0, 0, Math.PI * 2);
    }
    ctx.fill();
    cylShadow(ctx, false, 0, 0);
    if (this.inStatus(CYLRefreshPhase.Refreshing, CYLRefreshPhase.Finishing) && this.refreshAt > 0) {
      const scale = s.step(this.cyl_now, false);
      cylArrowPath(ctx, ox, oy, s.startTrim, s.endTrim, s.rotation, scale);
      cylStrokeArrow(ctx, accent);
    }
  }
}

/** Keeps the linear ease referenced for styles that need a constant-speed tween. */
export const cylRefreshEaseLinear: CYLRefreshDrawnEase = easeLinear;
