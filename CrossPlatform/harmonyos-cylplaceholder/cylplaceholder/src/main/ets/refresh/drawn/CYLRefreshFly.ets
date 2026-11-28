// CYLRefreshFly: the HarmonyOS counterparts of iOS Custom/Drawn/CYLRefreshFlyHeader.h and Support/CYLRefreshFlyView.h,
// CYLRefreshMountainView.h (after FlyRefresh): a mountain scene with swaying trees and a paper plane that tilts while
// pulling, flies off on release and flies back when the refresh ends. The header is always open: attaching adds its
// open height to the scroll view's top inset, so the scene stays above the list and refreshing does not push it.
import { CYLPoint, CYLRefreshScrollViewModel, CYLSize } from '../CYLRefreshComponent';
import { CYLRefreshComponentAction, CYLRefreshPhase, CYLRefreshScrollMode } from '../CYLRefreshConst';
import { CYLRefreshDrawnColor, CYLRefreshDrawnEase, cylRefreshCubicBezier } from './CYLRefreshDrawnSupport';
import { CYLRefreshDrawnHeaderModel } from './CYLRefreshDrawnHeader';
import { FLY_PATH_PLANE } from './CYLRefreshDrawnPaths';
import { CYLRefreshVectorImage } from './CYLRefreshVector';

const FLOAT_VIEW_SIZE: number = 50;
const TREE_WIDTH: number = 30;
const TREE_HEIGHT: number = 60;
const FLY_DURATION: number = 1500;
/** kCAMediaTimingFunctionEaseOut. */
const easeOut: CYLRefreshDrawnEase = cylRefreshCubicBezier(0, 0, 0.58, 1);

/** The paper plane, a 30 x 30 vector view (iOS `CYLRefreshFlyView`). */
export class CYLRefreshFlyViewModel {
  /** The view's size. */
  size: CYLSize = new CYLSize(30, 30);
  private image: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths([FLY_PATH_PLANE], ['#ffffff']);
  private accent: string = '#ffffff';

  constructor() {
    this.image.scaleToFitInside(this.size);
  }

  /** The plane's color (`colorAccent`). */
  get colorAccent(): string {
    return this.accent;
  }

  set colorAccent(value: string) {
    this.accent = value;
    this.image.parserColors([value]);
  }

  /** Draws the plane centered on the origin. */
  drawInContext(ctx: CanvasRenderingContext2D): void {
    const s = this.image.size;
    this.image.moveTo(new CYLPoint(-this.size.width / 2 + (this.size.width - s.width) / 2,
      -this.size.height / 2 + (this.size.height - s.height) / 2));
    this.image.renderInContext(ctx);
  }
}

/** One command of a tree path: 'M' / 'L' (x, y) or 'C' (c1, c2, end). */
class CYLTreeCommand {
  op: string;
  v: number[];

  constructor(op: string, v: number[]) {
    this.op = op;
    this.v = v;
  }
}

/**
 * The round button under the plane (iOS `CYLRefreshFlyHeader.floatView`): a circle of the header's primary color at
 * the plane's resting place. Set `hidden`, `alpha` or `color` to change how it is drawn; a null `color` follows
 * `colorPrimary`.
 */
export class CYLRefreshFloatViewModel {
  /** The fill; null follows the header's `colorPrimary`. */
  color: string | null = null;
  /** Whether the button is hidden (UIView hidden). */
  hidden: boolean = false;
  /** The opacity, 0..1 (UIView alpha). */
  alpha: number = 1;
  /** The diameter in vp. */
  readonly size: number = FLOAT_VIEW_SIZE;

  /** The center's x: three quarters of the size from the left; its y is the bottom edge of the header's frame. */
  centerX(): number {
    return this.size * 3 / 4;
  }

  /** Draws the circle with its center on the bottom edge of a frame `height` high. */
  drawInContext(ctx: CanvasRenderingContext2D, height: number, primary: string): void {
    if (this.hidden || this.alpha <= 0) {
      return;
    }
    ctx.save();
    ctx.globalAlpha = this.alpha;
    ctx.beginPath();
    ctx.arc(this.centerX(), height, this.size / 2, 0, Math.PI * 2);
    ctx.fillStyle = this.color !== null ? this.color : primary;
    ctx.fill();
    ctx.restore();
  }
}

/** The mountains and trees behind the plane (iOS `CYLRefreshMountainView`). */
export class CYLRefreshMountainViewModel {
  private offset: number = 0;
  private branch: CYLTreeCommand[] = [];
  private brink: CYLTreeCommand[] = [];
  private primary: string = '#33aaff';
  private accent: string = '#ffffff';
  private colorMount1: string = '';
  private colorMount2: string = '';
  private colorMount3: string = '';
  private colorTreeBranch: string = '';
  private colorTreeBrink: string = '';

  constructor() {
    this.colorPrimary = this.primary;
    this.updateTreePath(0);
  }

  /** The accent color, kept from iOS (`colorAccent`). */
  get colorAccent(): string {
    return this.accent;
  }

  set colorAccent(value: string) {
    this.accent = value;
  }

  /** The background; the mountains and trees mix their colors with it (`colorPrimary`). */
  get colorPrimary(): string {
    return this.primary;
  }

  set colorPrimary(color: string) {
    this.primary = color;
    this.colorMount1 = CYLRefreshDrawnColor.mixArgb(color, 0x99ffffff);
    this.colorMount2 = CYLRefreshDrawnColor.mixArgb(color, 0x993C929C);
    this.colorMount3 = CYLRefreshDrawnColor.mixArgb(color, 0xCC3E5F73);
    this.colorTreeBranch = CYLRefreshDrawnColor.mixArgb(color, 0x551F7177);
    this.colorTreeBrink = CYLRefreshDrawnColor.mixArgb(color, 0xCC0C3E48);
  }

  /** The pull: the mountains rise by parts of `offset`, the trees bend by `percent` (`-onScrollingWithOffset:percent:`). */
  onScrollingWithOffset(offset: number, percent: number): void {
    this.offset = offset;
    this.updateTreePath(percent);
  }

  private updateTreePath(percent: number): void {
    const brinkSize = TREE_WIDTH * 0.05;
    const branchSize = TREE_WIDTH * 0.2;
    const offset = percent * TREE_WIDTH * 0.3;
    const branch: CYLTreeCommand[] = [];
    const back: number[] = [];
    const top = TREE_HEIGHT * 0.6;
    branch.push(new CYLTreeCommand('M', [offset + offset * 0.3, top]));
    for (let y = top; y > 0; y -= 0.5) {
      const p = y / top;
      const x = (1 - Math.pow(1 - p, 0.5)) * offset;
      const xs = branchSize * (1 - p * p);
      branch.push(new CYLTreeCommand('L', [x - xs + offset * 0.3, y]));
      back.push(x + xs + offset * 0.3, y);
    }
    const s = offset * 0.3;
    branch.push(new CYLTreeCommand('L', [-branchSize + s, 0]));
    branch.push(new CYLTreeCommand('C', [-branchSize + s, -branchSize * 1.5, branchSize + s, -branchSize * 1.5,
      branchSize + s, 0]));
    for (let i = back.length - 2; i >= 0; i -= 2) {
      branch.push(new CYLTreeCommand('L', [back[i], back[i + 1]]));
    }
    const brink: CYLTreeCommand[] = [];
    const back2: number[] = [];
    const topB = TREE_HEIGHT * 0.7;
    brink.push(new CYLTreeCommand('M', [offset, topB]));
    for (let y = topB; y > 0; y -= 0.5) {
      const p = y / topB * 0.7;
      const x = (1 - Math.pow(1 - p, 0.5)) * offset;
      const xs = p > 0.35 ? brinkSize * (0.7 - p) / 0.35 : brinkSize;
      brink.push(new CYLTreeCommand('L', [x - xs, y]));
      back2.push(x + xs, y);
    }
    brink.push(new CYLTreeCommand('L', [-brinkSize, 0]));
    brink.push(new CYLTreeCommand('L', [brinkSize, 0]));
    for (let i = back2.length - 2; i >= 0; i -= 2) {
      brink.push(new CYLTreeCommand('L', [back2[i], back2[i + 1]]));
    }
    this.branch = branch;
    this.brink = brink;
  }

  private trace(ctx: CanvasRenderingContext2D, cmds: CYLTreeCommand[]): void {
    ctx.beginPath();
    cmds.forEach((c: CYLTreeCommand) => {
      if (c.op === 'M') {
        ctx.moveTo(c.v[0], c.v[1]);
      } else if (c.op === 'L') {
        ctx.lineTo(c.v[0], c.v[1]);
      } else {
        ctx.bezierCurveTo(c.v[0], c.v[1], c.v[2], c.v[3], c.v[4], c.v[5]);
      }
    });
  }

  private drawTree(ctx: CanvasRenderingContext2D, x: number, y: number, sx: number, sy: number): void {
    ctx.save();
    ctx.translate(x, y);
    ctx.scale(sx, sy);
    ctx.lineWidth = 6;
    ctx.translate(0, TREE_HEIGHT / 2);
    this.trace(ctx, this.branch);
    ctx.fillStyle = this.colorTreeBranch;
    ctx.fill();
    ctx.strokeStyle = this.colorTreeBrink;
    ctx.stroke();
    ctx.translate(0, -TREE_HEIGHT / 2);
    this.trace(ctx, this.brink);
    ctx.fillStyle = this.colorTreeBrink;
    ctx.fill();
    ctx.restore();
  }

  private ridge(ctx: CanvasRenderingContext2D, w: number, h: number, y0: number, pts: number[], color: string): void {
    ctx.beginPath();
    let y = y0;
    ctx.moveTo(0, y);
    for (let i = 0; i < pts.length; i += 2) {
      y += pts[i + 1];
      ctx.lineTo(pts[i], y);
    }
    ctx.lineTo(w, h);
    ctx.lineTo(0, h);
    ctx.closePath();
    ctx.fillStyle = color;
    ctx.fill();
  }

  /** Draws the background, three ridges and five trees in a `w` x `h` frame (iOS `drawRect:`). */
  drawInContext(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    const u = w / 29;
    const o = this.offset;
    ctx.fillStyle = this.primary;
    ctx.fillRect(0, 0, w, h);
    this.ridge(ctx, w, h, h - u * 4 - o * 0.6, [u * 6, -u * 4, u * 17, u * 4.5, u * 27, -u * 5.5, w, u * 2],
      this.colorMount1);
    this.drawTree(ctx, u * 6.5, h - u * 5 - o * 0.4, -0.7, -0.7);
    this.drawTree(ctx, u * 4.5, h - u * 4.5 - o * 0.4, -0.5, -0.5);
    this.ridge(ctx, w, h, h - u * 3 - o * 0.4, [u * 7, -u * 3, u * 18, u * 4.5, u * 26, -u * 4.5, w, u * 2],
      this.colorMount2);
    this.drawTree(ctx, u * 16, h - u * 3 - o * 0.2, 0.85, -0.85);
    this.drawTree(ctx, u * 19, h - u * 3 - o * 0.2, 1, -1);
    this.drawTree(ctx, u * 22, h - u * 3 - o * 0.2, 0.7, -0.7);
    const y = h - u * 2 - o * 0.2;
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.bezierCurveTo(u * 3.5, y - u, u * 21, y - u * 3, w, y - u);
    ctx.lineTo(w, h);
    ctx.lineTo(0, h);
    ctx.closePath();
    ctx.fillStyle = this.colorMount3;
    ctx.fill();
  }
}

/** A point of a sampled flight path with its arc length. */
class CYLFlyPoint {
  x: number;
  y: number;
  len: number;

  constructor(x: number, y: number, len: number) {
    this.x = x;
    this.y = y;
    this.len = len;
  }
}

/** A flight: quadratic segments sampled by arc length (kCAAnimationPaced, kCAAnimationRotateAuto). */
class CYLFlyPath {
  pts: CYLFlyPoint[] = [];
  len: number = 0;
  start: number = 0;
  fromScaleX: number = 1;
  fromScaleY: number = 1;
  toScaleX: number = 1;
  toScaleY: number = 1;

  /** Adds a quadratic segment from the last point (or `x0`, `y0`) to (x2, y2) via (cx, cy). */
  addQuad(x0: number, y0: number, cx: number, cy: number, x2: number, y2: number): void {
    if (this.pts.length === 0) {
      this.pts.push(new CYLFlyPoint(x0, y0, 0));
    }
    const first = this.pts[this.pts.length - 1];
    let px = first.x;
    let py = first.y;
    for (let i = 1; i <= 60; i++) {
      const t = i / 60;
      const x = (1 - t) * (1 - t) * first.x + 2 * (1 - t) * t * cx + t * t * x2;
      const y = (1 - t) * (1 - t) * first.y + 2 * (1 - t) * t * cy + t * t * y2;
      this.len += Math.hypot(x - px, y - py);
      this.pts.push(new CYLFlyPoint(x, y, this.len));
      px = x;
      py = y;
    }
  }

  /** The point, heading and scale at time fraction f (eased out). */
  at(f: number): number[] {
    const e = easeOut(Math.min(1, Math.max(0, f)));
    const target = e * this.len;
    let i = 1;
    while (i < this.pts.length - 1 && this.pts[i].len < target) {
      i++;
    }
    const a = this.pts[i - 1];
    const b = this.pts[i];
    const k = b.len > a.len ? (target - a.len) / (b.len - a.len) : 0;
    return [a.x + (b.x - a.x) * k, a.y + (b.y - a.y) * k, Math.atan2(b.y - a.y, b.x - a.x),
      this.fromScaleX + (this.toScaleX - this.fromScaleX) * e, this.fromScaleY + (this.toScaleY - this.fromScaleY) * e];
  }
}

/** A paper plane over mountains that flies off while refreshing (iOS `CYLRefreshFlyHeader`). */
export class CYLRefreshFlyHeaderModel extends CYLRefreshDrawnHeaderModel {
  /** The scene (iOS `mountainView`). */
  mountainView: CYLRefreshMountainViewModel = new CYLRefreshMountainViewModel();
  /** The plane (iOS `flyView`). */
  flyView: CYLRefreshFlyViewModel = new CYLRefreshFlyViewModel();
  /** The round button under the plane (iOS `floatView`). */
  floatView: CYLRefreshFloatViewModel = new CYLRefreshFloatViewModel();
  private flight: CYLFlyPath | null = null;
  private flownAway: boolean = false;
  private addedInset: number = 0;
  private syncedPrimary: string = '';
  private syncedAccent: string = '';

  constructor() {
    super();
    this.addsRefreshingInset = false;
  }

  /** A Fly header calling `block` when it refreshes. */
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshFlyHeaderModel {
    const header = new CYLRefreshFlyHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  setUpComponent(): void {
    super.setUpComponent();
    this.height = 150;
    this.triggerRate = 0.5;
    this.colorPrimary = '#33aaff';
    this.colorAccent = '#ffffff';
    this.scrollMode = CYLRefreshScrollMode.Stretch;
  }

  /** Always open: attaching adds the open height to the top inset once, detaching removes it. */
  scrollViewAttached(scrollView: CYLRefreshScrollViewModel | null, attach: boolean): void {
    super.scrollViewAttached(scrollView, attach);
    if (scrollView === null) {
      return;
    }
    if (attach && this.addedInset <= 0) {
      this.addedInset = this.expandHeight;
      scrollView.cyl_insetT = scrollView.cyl_insetT + this.addedInset;
      scrollView.cyl_springBack();
    } else if (!attach && this.addedInset > 0) {
      scrollView.cyl_insetT = scrollView.cyl_insetT - this.addedInset;
      this.addedInset = 0;
    }
  }

  cyl_wantsFrame(): boolean {
    return true;
  }

  onScrollingWithOffset(offset: number, percent: number, isDragging: boolean): void {
    this.mountainView.onScrollingWithOffset(offset, percent);
  }

  onStartAnimationWhenRealeasing(): void {
    const f = new CYLFlyPath();
    f.addQuad(FLOAT_VIEW_SIZE * 3 / 4, this.expandHeight + this.dragOffset, 0, 0, this.width + FLOAT_VIEW_SIZE / 2,
      FLOAT_VIEW_SIZE / 4);
    f.toScaleX = 0.5;
    f.toScaleY = 0.2;
    f.start = this.cyl_clock();
    this.flight = f;
    this.flownAway = true;
  }

  finishRefreshWithSuccess(success: boolean): void {
    super.finishRefreshWithSuccess(success);
    if (!this.flownAway) {
      return;
    }
    const w = this.width;
    const h = this.expandHeight + this.dragOffset;
    const f = new CYLFlyPath();
    f.addQuad(w + FLOAT_VIEW_SIZE / 2, FLOAT_VIEW_SIZE / 4, w, h - FLOAT_VIEW_SIZE, -FLOAT_VIEW_SIZE, h -
      FLOAT_VIEW_SIZE);
    f.addQuad(0, 0, -FLOAT_VIEW_SIZE, h, FLOAT_VIEW_SIZE * 3 / 4, h);
    f.fromScaleX = 0.5;
    f.fromScaleY = 0.2;
    f.start = this.cyl_clock();
    this.flight = f;
    this.flownAway = false;
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    const w = this.width;
    const h = this.expandHeight + this.dragOffset;
    if (this.syncedPrimary !== this.cyl_primaryColor) {
      this.syncedPrimary = this.cyl_primaryColor;
      this.mountainView.colorPrimary = this.syncedPrimary;
    }
    if (this.syncedAccent !== this.cyl_accentColor) {
      this.syncedAccent = this.cyl_accentColor;
      this.flyView.colorAccent = this.syncedAccent;
    }
    this.mountainView.drawInContext(ctx, w, h);
    // The float view: a circle of colorPrimary under the plane's resting place.
    this.floatView.drawInContext(ctx, h, this.cyl_primaryColor);
    ctx.save();
    const flight = this.flight;
    if (flight !== null) {
      const f = (this.cyl_now - flight.start) / FLY_DURATION;
      const p = flight.at(f);
      ctx.translate(p[0], p[1]);
      ctx.rotate(p[2]);
      ctx.scale(p[3], p[4]);
      if (f >= 1 && !this.flownAway) {
        this.flight = null;
      }
    } else if (this.flownAway) {
      ctx.translate(w + FLOAT_VIEW_SIZE / 2, FLOAT_VIEW_SIZE / 4);
      ctx.scale(0.5, 0.2);
    } else {
      ctx.translate(FLOAT_VIEW_SIZE * 3 / 4, h);
      if (!this.inStatus(CYLRefreshPhase.Refreshing, CYLRefreshPhase.Releasing)) {
        ctx.rotate(-(this.dragOffset / this.expandHeight) * 3.1415926 / 4);
      }
    }
    this.flyView.drawInContext(ctx);
    ctx.restore();
  }
}
