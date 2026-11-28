// CYLRefreshDrawnVectors: the drawn styles made of vector images, the HarmonyOS counterparts of iOS
// CYLRefreshDeliveryHeader, CYLRefreshDropBoxHeader, CYLRefreshPhoenixHeader and CYLRefreshTaurusHeader
// (CYLRefresh styles). Paths, colors, sizes and the per-frame steps are those of the iOS port.
import { CYLPoint, CYLSize } from '../CYLRefreshComponent';
import { CYLRefreshComponentAction, CYLRefreshPhase, CYLRefreshScrollMode } from '../CYLRefreshConst';
import { CYLRefreshDrawnColor, CYLRefreshDrawnEase, CYLRefreshDrawnTween } from './CYLRefreshDrawnSupport';
import { CYLRefreshDrawnHeaderModel } from './CYLRefreshDrawnHeader';
import { CYLRefreshValueAnimator } from './CYLRefreshValueAnimator';
import { CYLRefreshVectorImage } from './CYLRefreshVector';
import {
  DELIVERY_PATH_BOX_1,
  DELIVERY_PATH_BOX_2,
  DELIVERY_PATH_BOX_3,
  DELIVERY_PATH_BOX_4,
  DELIVERY_PATH_BOX_5,
  DELIVERY_PATH_CLOUD,
  DELIVERY_PATH_UMBRELLA_1,
  DELIVERY_PATH_UMBRELLA_2,
  DELIVERY_PATH_UMBRELLA_3,
  DELIVERY_PATH_UMBRELLA_4,
  DELIVERY_PATH_UMBRELLA_5,
  DELIVERY_PATH_UMBRELLA_6,
  DELIVERY_PATH_UMBRELLA_7,
  DELIVERY_PATH_UMBRELLA_8,
  DROPBOX_PATH_IMAGE_FILE,
  DROPBOX_PATH_IMAGE_MOIVE,
  DROPBOX_PATH_IMAGE_MUSIC,
  PHOENIX_PATH_SKY_1,
  PHOENIX_PATH_SKY_2,
  PHOENIX_PATH_SUN_1,
  PHOENIX_PATH_SUN_2,
  PHOENIX_PATH_TWON_1,
  PHOENIX_PATH_TWON_2,
  PHOENIX_PATH_TWON_3,
  PHOENIX_PATH_TWON_4,
  PHOENIX_PATH_TWON_5,
  PHOENIX_PATH_TWON_6,
  PHOENIX_PATH_TWON_7,
  PHOENIX_PATH_TWON_8,
  PHOENIX_PATH_TWON_9,
  PHOENIX_PATH_TWON_A,
  PHOENIX_PATH_TWON_B,
  PHOENIX_PATH_TWON_C,
  TAURUS_PATH_AIRPLANE,
  TAURUS_PATH_CLOUD_1,
  TAURUS_PATH_CLOUD_2,
  TAURUS_PATH_CLOUD_3
} from './CYLRefreshDrawnPaths';

const easeAccelerate: CYLRefreshDrawnEase = (t: number): number => CYLRefreshValueAnimator.accelerate(t);
const easeAccelDecel: CYLRefreshDrawnEase = (t: number): number => CYLRefreshValueAnimator.accelerateDecelerate(t);
const easeLinear: CYLRefreshDrawnEase = (t: number): number => t;

function cylMove(image: CYLRefreshVectorImage, x: number, y: number): void {
  image.moveTo(new CYLPoint(x, y));
}

// MARK: - Delivery

/** A parcel on an umbrella drifting over a town, delivered while refreshing (iOS `CYLRefreshDeliveryHeader`). */
export class CYLRefreshDeliveryHeaderModel extends CYLRefreshDrawnHeaderModel {
  private umbrella: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths([DELIVERY_PATH_UMBRELLA_1,
    DELIVERY_PATH_UMBRELLA_2, DELIVERY_PATH_UMBRELLA_3, DELIVERY_PATH_UMBRELLA_4, DELIVERY_PATH_UMBRELLA_5,
    DELIVERY_PATH_UMBRELLA_6, DELIVERY_PATH_UMBRELLA_7, DELIVERY_PATH_UMBRELLA_8],
    ['#92dfeb', '#6dd0e9', '#4fc3e7', '#2fb6e6', '#25a9de', '#11abe4', '#0e9bd8', '#40b7e1']);
  private box: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths([DELIVERY_PATH_BOX_1, DELIVERY_PATH_BOX_2,
    DELIVERY_PATH_BOX_3, DELIVERY_PATH_BOX_4, DELIVERY_PATH_BOX_5],
    ['#f8b147', '#f2973c', '#ed8030', '#fec051', '#f7ad49']);
  private cloud: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths(DELIVERY_PATH_CLOUD, ['#ffffff']);
  private cloud1x: number = 0;
  private cloud2x: number = 0;
  private cloud3x: number = 0;
  private appreciation: number = 0;

  constructor() {
    super();
    this.umbrella.setGeometricWidth(200);
    this.box.setGeometricWidth(50);
    this.cloud.setGeometricHeight(20);
    this.resetClouds();
  }

  /** A Delivery header calling `block` when it refreshes. */
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshDeliveryHeaderModel {
    const header = new CYLRefreshDeliveryHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  setUpComponent(): void {
    super.setUpComponent();
    this.height = 150;
    this.triggerRate = 0.7;
    this.colorAccent = '#6ea9ff';
    this.colorPrimary = '#f5f5f5';
    this.scrollMode = CYLRefreshScrollMode.Stretch;
  }

  private resetClouds(): void {
    const cw = this.cloud.size.width;
    this.cloud1x = -cw;
    this.cloud2x = -cw;
    this.cloud3x = -cw;
  }

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if (status === CYLRefreshPhase.Refreshing) {
      this.box.opacity = 1;
    } else if (status === CYLRefreshPhase.Idle) {
      this.appreciation = 0;
      this.resetClouds();
    }
  }

  /** calculateFrame: one step per 60 Hz frame on iOS, scaled by the frame time here. */
  private step(width: number): void {
    const k = this.cyl_frameSeconds * 60;
    const cw = this.cloud.size.width;
    this.cloud1x += 7 * k;
    this.cloud2x += 4 * k;
    this.cloud3x += 9 * k;
    if (this.cloud1x > width + cw) {
      this.cloud1x = -cw;
    }
    if (this.cloud2x > width + cw) {
      this.cloud2x = -cw;
    }
    if (this.cloud3x > width + cw) {
      this.cloud3x = -cw;
    }
    this.appreciation += 0.08 * k;
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    const width = this.width;
    const height = this.dragOffset;
    const expand = this.expandHeight;
    const active = this.inStatus(CYLRefreshPhase.Refreshing, CYLRefreshPhase.Finishing);
    if (active) {
      this.step(width);
    } else {
      this.box.opacity = Math.max(0.1, 1 - Math.max(0, this.dragPercent - 1));
    }
    const shake = expand / 13 * Math.cos(this.appreciation);
    ctx.fillStyle = this.cyl_primaryColor;
    ctx.fillRect(0, 0, width, height);
    if (active) {
      cylMove(this.cloud, this.cloud1x, expand / 3);
      this.cloud.renderInContext(ctx);
      cylMove(this.cloud, this.cloud2x, expand / 2);
      this.cloud.renderInContext(ctx);
      cylMove(this.cloud, this.cloud3x, expand * 2 / 3);
      this.cloud.renderInContext(ctx);
      ctx.translate(width / 2, expand / 2 - expand);
      ctx.rotate(Math.sin(this.appreciation) * Math.PI * 5 / 180);
      ctx.translate(-width / 2, expand - expand / 2);
    }
    const bw = this.box.size.width;
    const bh = this.box.size.height;
    const centerY = height - expand / 2 + shake;
    const centerYBox = centerY + (expand / 2 - bh) - Math.min(expand / 2 - bh, this.appreciation * 100);
    cylMove(this.box, width / 2 - bw / 2, centerYBox - bh / 4);
    this.box.renderInContext(ctx);
    if (active) {
      const uh = this.umbrella.size.height;
      const uw = this.umbrella.size.width;
      const cyU = centerY - expand + Math.min(expand, this.appreciation * 100);
      cylMove(this.umbrella, width / 2 - uw / 2, cyU - uh);
      this.umbrella.renderInContext(ctx);
    }
  }
}

// MARK: - DropBox

const DROPBOX_HEIGHT: number = 100;

/** The box geometry of a frame (iOS `measure:`). */
class CYLDropBoxBox {
  side: number = 0;
  centerX: number = 0;
  bottom: number = 0;
  top: number = 0;
  left: number = 0;
  centerTop: number = 0;
  centerBottom: number = 0;
  right: number = 0;
  centerY: number = 0;

  static measure(margin: number, width: number, height: number, sideLength: number): CYLDropBoxBox {
    const b = new CYLDropBoxBox();
    b.side = sideLength;
    b.centerX = Math.trunc(width / 2);
    b.bottom = Math.trunc(height - margin);
    b.top = b.bottom - 2 * sideLength;
    b.left = b.centerX - Math.trunc(sideLength * Math.sin(Math.PI / 3));
    b.centerTop = b.top + Math.trunc(sideLength / 2);
    b.centerBottom = b.bottom - Math.trunc(sideLength / 2);
    b.right = Math.trunc(width) - b.left;
    b.centerY = b.bottom - sideLength;
    return b;
  }
}

function cylQuad(ctx: CanvasRenderingContext2D, pts: number[]): void {
  ctx.beginPath();
  ctx.moveTo(pts[0], pts[1]);
  for (let i = 2; i < pts.length; i += 2) {
    ctx.lineTo(pts[i], pts[i + 1]);
  }
  ctx.closePath();
  ctx.fill();
}

/** A box whose lid opens and drops files while refreshing (iOS `CYLRefreshDropBoxHeader`). */
export class CYLRefreshDropBoxHeaderModel extends CYLRefreshDrawnHeaderModel {
  private movie: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths(DROPBOX_PATH_IMAGE_MOIVE,
    ['#ecf0f1', '#fc4108']);
  private file: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths(DROPBOX_PATH_IMAGE_FILE,
    ['#fed469', '#d5ae57']);
  private music: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths(DROPBOX_PATH_IMAGE_MUSIC, ['#98d761']);
  private percentRebound: number = 0;
  private percentDropOut: number = 0;
  private overflow: boolean = false;
  private animKind: number = 0;
  private anim: CYLRefreshDrawnTween | null = null;

  constructor() {
    super();
    const side = DROPBOX_HEIGHT / 5;
    this.movie.size = new CYLSize(side, side);
    this.file.size = new CYLSize(side, side);
    this.music.size = new CYLSize(side, side);
  }

  /** A DropBox header calling `block` when it refreshes. */
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshDropBoxHeaderModel {
    const header = new CYLRefreshDropBoxHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  setUpComponent(): void {
    super.setUpComponent();
    this.height = DROPBOX_HEIGHT;
    this.colorAccent = '#6ea9ff';
    this.colorPrimary = '#283645';
    this.scrollMode = CYLRefreshScrollMode.Stretch;
  }

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if (status === CYLRefreshPhase.Idle || status === CYLRefreshPhase.PullToRefresh) {
      this.overflow = false;
      this.anim = null;
      this.percentDropOut = 0;
      this.percentRebound = 0;
    } else if (status === CYLRefreshPhase.Refreshing) {
      this.startAnim(1, this.cyl_clock());
    }
  }

  private startAnim(kind: number, now: number): void {
    this.animKind = kind;
    this.anim = new CYLRefreshDrawnTween(0, 1, this.durationNormal, easeAccelerate, now);
  }

  /** The drop and rebound animators, chained: drop → rebound → drop … */
  private step(now: number): void {
    const a = this.anim;
    if (this.status !== CYLRefreshPhase.Refreshing || a === null) {
      return;
    }
    const value = a.value(now);
    const done = a.done(now);
    if (this.animKind === 2) {
      this.percentRebound = 1 - 2 * Math.abs(value - 0.5);
      if (done) {
        this.percentRebound = 0;
        this.startAnim(1, now);
      }
    } else {
      const p = this.percentDropOut;
      if (p < 1 || p >= 3) {
        this.percentDropOut = value;
      } else if (p < 2) {
        this.percentDropOut = 1 + value;
      } else {
        this.percentDropOut = 2 + value;
        if (this.percentDropOut >= 3) {
          this.overflow = true;
        }
      }
      if (done) {
        this.startAnim(2, now);
      }
    }
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    this.step(this.cyl_now);
    const w = this.width;
    const side = DROPBOX_HEIGHT / 5;
    const margin = side / 2;
    const b = CYLDropBoxBox.measure(margin, w, this.dragOffset, margin * 2);
    const accent = this.cyl_accentColor;
    const pr = this.percentRebound;
    ctx.fillStyle = this.cyl_primaryColor;
    ctx.fillRect(0, 0, w, this.dragOffset);
    // drawBoxBody
    ctx.fillStyle = CYLRefreshDrawnColor.alpha(accent, 150 / 255);
    ctx.beginPath();
    ctx.moveTo(b.left, b.centerBottom);
    ctx.lineTo(b.centerX, b.bottom);
    ctx.lineTo(b.right, b.centerBottom);
    ctx.quadraticCurveTo(b.right + b.side / 2 * pr, b.centerY, b.right, b.centerTop);
    ctx.lineTo(b.centerX, b.top);
    ctx.lineTo(b.left, b.centerTop);
    ctx.quadraticCurveTo(b.left - b.side / 2 * pr, b.centerY, b.left, b.centerBottom);
    ctx.closePath();
    ctx.fill();
    // drawBoxCover
    ctx.fillStyle = accent;
    const sideCover = Math.trunc((b.centerX - b.left) * 4 / 5);
    const off = pr * (Math.PI * 2 / 5);
    const mid = Math.trunc((b.bottom + b.top) / 2);
    const ltx = sideCover * Math.sin(Math.PI / 3 - off / 2);
    const lty = sideCover * Math.cos(Math.PI / 3 - off / 2);
    cylQuad(ctx, [b.left, b.centerTop, b.centerX, b.top, b.centerX - ltx, b.top - lty, b.left - ltx, b.centerTop - lty]);
    const lbx = sideCover * Math.sin(Math.PI / 3 + off);
    const lby = sideCover * Math.cos(Math.PI / 3 + off);
    cylQuad(ctx, [b.left, b.centerTop, b.centerX, mid, b.centerX - lbx, mid + lby, b.left - lbx, b.centerTop + lby]);
    cylQuad(ctx, [b.right, b.centerTop, b.centerX, b.top, b.centerX + ltx, b.top - lty, b.right + ltx,
      b.centerTop - lty]);
    cylQuad(ctx, [b.right, b.centerTop, b.centerX, mid, b.centerX + lbx, mid + lby, b.right + lbx, b.centerTop + lby]);
    // drawImages
    const p = this.percentDropOut;
    if (p <= 0) {
      return;
    }
    ctx.save();
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(0, b.centerTop);
    ctx.lineTo(b.left, b.centerTop);
    ctx.lineTo(b.centerX, b.centerY);
    ctx.lineTo(b.right, b.centerTop);
    ctx.lineTo(w, b.centerTop);
    ctx.lineTo(w, 0);
    ctx.closePath();
    ctx.clip();
    const x = w / 2 - side / 2;
    const images = [this.movie, this.file, this.music];
    for (let i = 0; i < images.length; i++) {
      const q = Math.min(Math.max(p - i, 0), 1);
      cylMove(images[i], x, (b.centerY - side / 2 + side) * q - side);
      images[i].renderInContext(ctx);
    }
    if (this.overflow) {
      images.forEach((img: CYLRefreshVectorImage) => {
        cylMove(img, x, b.centerY - side / 2);
        img.renderInContext(ctx);
      });
    }
    ctx.restore();
  }
}

// MARK: - Phoenix

const SUN_SIZE: number = 40;

/** A sun rising over a town (iOS `CYLRefreshPhoenixHeader`). */
export class CYLRefreshPhoenixHeaderModel extends CYLRefreshDrawnHeaderModel {
  private town: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths([PHOENIX_PATH_TWON_1, PHOENIX_PATH_TWON_2,
    PHOENIX_PATH_TWON_3, PHOENIX_PATH_TWON_4, PHOENIX_PATH_TWON_5, PHOENIX_PATH_TWON_6, PHOENIX_PATH_TWON_7,
    PHOENIX_PATH_TWON_8, PHOENIX_PATH_TWON_9, PHOENIX_PATH_TWON_A, PHOENIX_PATH_TWON_B, PHOENIX_PATH_TWON_C],
    ['#679893', '#98d2d0', '#69b3af', '#f2ebe0', '#847079', '#360000', '#b65649', '#afa68b', '#434343', '#2b4247',
      '#85acbe', '#000000']);
  private sky: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths([PHOENIX_PATH_SKY_1, PHOENIX_PATH_SKY_2],
    ['#38adc1', '#f3e59c']);
  private sun: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths([PHOENIX_PATH_SUN_1, PHOENIX_PATH_SUN_2],
    ['#fef9e8', '#f3e59c']);
  private animator: CYLRefreshDrawnTween | null = null;
  private skyColor: string = '';

  constructor() {
    super();
    this.sun.size = new CYLSize(SUN_SIZE, SUN_SIZE);
  }

  /** A Phoenix header calling `block` when it refreshes. */
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshPhoenixHeaderModel {
    const header = new CYLRefreshPhoenixHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  setUpComponent(): void {
    super.setUpComponent();
    this.height = 100;
    this.colorAccent = '#ffffff';
    this.colorPrimary = '#38adc1';
    this.scrollMode = CYLRefreshScrollMode.Stretch;
  }

  /** scrollView:attached: the sky and the town take the width. */
  cyl_layoutWidth(width: number): void {
    this.sky.size = new CYLSize(width, width * this.sky.viewport.height / this.sky.viewport.width);
    this.town.size = new CYLSize(width, width * this.town.viewport.height / this.town.viewport.width);
  }

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if (oldStatus === CYLRefreshPhase.Refreshing || oldStatus === CYLRefreshPhase.Finishing) {
      this.animator = null;
    } else if (status === CYLRefreshPhase.Refreshing) {
      this.animator = CYLRefreshDrawnTween.repeating(0, 1, 1, easeLinear, this.cyl_clock(), false);
    }
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    const width = this.width;
    const height = this.dragOffset;
    const percent = this.dragPercent;
    const expand = this.expandHeight;
    const animator = this.animator;
    const rotateValue = animator !== null ? animator.value(this.cyl_now) : percent;
    const primary = this.cyl_primaryColor;
    if (this.skyColor !== primary) {
      this.skyColor = primary;
      this.sky.parserColors([primary, '#f3e59c']);
    }
    ctx.fillStyle = primary;
    ctx.fillRect(0, 0, width, height);
    // drawSky
    const skyScale = width / Math.max(1, this.sky.size.width);
    ctx.save();
    ctx.translate(0, height / 2 - this.sky.size.height / 2);
    ctx.scale(skyScale, skyScale);
    cylMove(this.sky, 0, 0);
    this.sky.renderInContext(ctx);
    ctx.restore();
    // drawSun
    const sunRadius = SUN_SIZE / 2;
    const sunX = 0.3 * width + sunRadius;
    const sunY = expand * 0.1 + expand / 2 * (1 - Math.min(percent, 1));
    let scale = SUN_SIZE / this.sun.size.width;
    if (percent > 1) {
      scale = Math.max(scale * (1 - 0.5 * (percent - 1)), 0.45);
    }
    let rotate = rotateValue * 360;
    rotate = animator !== null ? -rotate : rotate * 1.2;
    ctx.save();
    ctx.translate(sunX, sunY);
    ctx.scale(scale, scale);
    ctx.translate(sunRadius, sunRadius);
    ctx.rotate(rotate * Math.PI / 180);
    ctx.translate(-sunRadius, -sunRadius);
    cylMove(this.sun, 0, 0);
    this.sun.renderInContext(ctx);
    ctx.restore();
    // drawTown
    const bh = this.town.size.height;
    const amplification = 0.3 * Math.max(percent - 1, 0) + 1;
    const townX = width / 2 - Math.floor(Math.floor(width * amplification) / 2);
    let townY = expand * 0.1 * percent;
    const townScale = amplification * (width / Math.max(1, this.town.size.width));
    if (townY + bh * townScale < height) {
      townY = height - bh * townScale;
    }
    ctx.save();
    ctx.translate(townX, townY);
    ctx.scale(townScale, townScale);
    cylMove(this.town, 0, 0);
    this.town.renderInContext(ctx);
    ctx.restore();
  }
}

// MARK: - Taurus

const SCALE_START_PERCENT: number = 0.5;
const LOADING_ANIMATION_COEFFICIENT: number = 80;
const SLOW_DOWN_ANIMATION_COEFFICIENT: number = 6;
const WIND_SET_AMOUNT: number = 10;
const RANDOM_Y_COEFFICIENT: number = 5;

function cylRandom(min: number, max: number): number {
  return min + Math.floor(Math.random() * (max - min + 1));
}

/** One wind line: its height and x offset. */
class CYLTaurusWind {
  y: number;
  x: number;

  constructor(y: number, x: number) {
    this.y = y;
    this.x = x;
  }
}

/** An airplane flying through clouds (iOS `CYLRefreshTaurusHeader`). */
export class CYLRefreshTaurusHeaderModel extends CYLRefreshDrawnHeaderModel {
  private cloud: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths([TAURUS_PATH_CLOUD_1, TAURUS_PATH_CLOUD_2,
    TAURUS_PATH_CLOUD_3], ['rgba(199,220,241,0.667)', 'rgba(232,243,253,0.867)', 'rgba(253,253,253,1)']);
  private airplane: CYLRefreshVectorImage = CYLRefreshVectorImage.newWithPaths([TAURUS_PATH_AIRPLANE], ['#ffffff']);
  private refreshingTween: CYLRefreshDrawnTween | null = null;
  private finish: CYLRefreshDrawnTween | null = null;
  private loading: number = 0;
  private finishTime: number = 0;
  private lastTime: number = 0;
  private windLineWidth: number = 0;
  private newWindSet: boolean = false;
  private inverse: boolean = false;
  private winds: CYLTaurusWind[] = [];

  constructor() {
    super();
    this.cloud.size = new CYLSize(260, 45);
    this.airplane.size = new CYLSize(65, 20);
  }

  /** A Taurus header calling `block` when it refreshes. */
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshTaurusHeaderModel {
    const header = new CYLRefreshTaurusHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  setUpComponent(): void {
    super.setUpComponent();
    this.height = 100;
    this.colorAccent = '#ffffff';
    this.colorPrimary = '#1199ff';
    this.scrollMode = CYLRefreshScrollMode.Stretch;
    this.finishDuration = 0.3;
  }

  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    super.onStatus(oldStatus, status);
    if (status === CYLRefreshPhase.Finishing) {
      this.finish = new CYLRefreshDrawnTween(0, 1, this.finishDuration, easeAccelDecel, this.cyl_clock());
    } else if (status === CYLRefreshPhase.Refreshing) {
      this.loading = 0;
      this.refreshingTween = CYLRefreshDrawnTween.repeating(0, 1, 1, easeAccelDecel, this.cyl_clock(), true);
    } else if (status === CYLRefreshPhase.Idle) {
      this.finish = null;
      this.finishTime = 0;
      this.refreshingTween = null;
    }
  }

  cyl_isAnimating(): boolean {
    return this.finish !== null;
  }

  private timePart(part: number): number {
    if (part === 2) {
      return LOADING_ANIMATION_COEFFICIENT / 2;
    }
    if (part === 4) {
      return LOADING_ANIMATION_COEFFICIENT / 4;
    }
    if (part === 3) {
      return 3 * (LOADING_ANIMATION_COEFFICIENT / 4);
    }
    return 0;
  }

  private partValue(part: number): number {
    const t = this.loading;
    if (part === 1) {
      return t;
    }
    if (part === 2) {
      return -t;
    }
    if (part === 3) {
      return t - this.timePart(2);
    }
    return this.timePart(3) - (t - this.timePart(4));
  }

  /** The loading part (1-4) of the airplane's motion, 0 while not refreshing. */
  private currentPart(): number {
    if (this.refreshingTween === null) {
      return 0;
    }
    const t = this.loading;
    if (t < this.timePart(4)) {
      return 1;
    }
    if (t < this.timePart(2)) {
      return 2;
    }
    if (t < this.timePart(3)) {
      return 3;
    }
    return t > this.timePart(3) ? 4 : 0;
  }

  private drawWind(ctx: CanvasRenderingContext2D, y: number, xOffset: number, width: number): void {
    const cof = (width + xOffset) / (LOADING_ANIMATION_COEFFICIENT / SLOW_DOWN_ANIMATION_COEFFICIENT);
    let time = this.loading;
    if (this.lastTime - this.loading > 0) {
      this.inverse = true;
      time = LOADING_ANIMATION_COEFFICIENT / SLOW_DOWN_ANIMATION_COEFFICIENT - this.loading;
    } else {
      this.newWindSet = true;
      this.inverse = false;
    }
    const x = width - time * cof + xOffset - this.windLineWidth;
    ctx.lineWidth = 3;
    ctx.strokeStyle = 'rgba(255,255,255,0.25)';
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x + this.windLineWidth, y);
    ctx.stroke();
  }

  private drawWinds(ctx: CanvasRenderingContext2D, width: number, h: number): void {
    if (this.status !== CYLRefreshPhase.Refreshing) {
      return;
    }
    const height = Math.max(h, this.expandHeight);
    let guard = 0;
    while (this.winds.length < WIND_SET_AMOUNT && guard++ < 50) {
      let y = height / (RANDOM_Y_COEFFICIENT * cylRandom(1, 100) / 100);
      const x = cylRandom(1000, 2000);
      if (this.winds.length > 1) {
        y = 0;
        for (let tries = 0; y === 0 && tries < 100; tries++) {
          const tmp = height / (RANDOM_Y_COEFFICIENT * cylRandom(1, 100) / 100);
          y = this.winds.every((w: CYLTaurusWind) => Math.abs(w.y - tmp) > height / RANDOM_Y_COEFFICIENT) ? tmp : 0;
        }
        if (y === 0) {
          continue;
        }
      }
      this.winds.push(new CYLTaurusWind(y, x));
      this.drawWind(ctx, y, x, width);
    }
    if (this.winds.length >= WIND_SET_AMOUNT || guard >= 50) {
      this.winds.forEach((w: CYLTaurusWind) => this.drawWind(ctx, w.y, w.x, width));
    }
    if (this.inverse && this.newWindSet) {
      this.winds = [];
      this.newWindSet = false;
      this.windLineWidth = cylRandom(50, 300);
    }
    this.lastTime = this.loading;
  }

  private drawAirplane(ctx: CanvasRenderingContext2D, width: number): void {
    const plane = this.airplane;
    const expand = this.expandHeight;
    let rotateAngle = 0;
    let dragPercent = this.dragPercent;
    if (dragPercent > 1) {
      rotateAngle = 20 * (1 - Math.pow(100, -(dragPercent - 1) / 2));
      dragPercent = 1;
    }
    let offsetX = width * dragPercent / 2 - plane.size.width / 2;
    let offsetY = expand * (1 - dragPercent / 2) - plane.size.height / 2;
    if (this.finish !== null) {
      offsetY -= (expand / 2 + plane.size.height / 2) * this.finishTime;
      offsetX += (width + plane.size.width - offsetX) * this.finishTime;
    }
    const part = this.currentPart();
    if (part === 1 || part === 2) {
      offsetY -= this.partValue(part);
    } else if (part !== 0) {
      offsetY += this.partValue(part);
    }
    ctx.save();
    ctx.translate(offsetX, offsetY);
    if (rotateAngle > 0) {
      ctx.translate(plane.size.width / 2, plane.size.height / 2);
      ctx.rotate(rotateAngle * Math.PI / 180);
      ctx.translate(-plane.size.width / 2, -plane.size.height / 2);
    }
    cylMove(plane, 0, 0);
    plane.renderInContext(ctx);
    ctx.restore();
  }

  private drawCloudSide(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    const cloud = this.cloud;
    const cw = cloud.size.width;
    const ch = cloud.size.height;
    const dragPercent = Math.min(1, Math.abs(this.dragPercent));
    const delta = dragPercent - SCALE_START_PERCENT;
    const scale = delta > 0 ? 0.6 + 0.4 * (delta / (1 - SCALE_START_PERCENT)) : 0.6;
    const dragYOffset = this.expandHeight * (1 - dragPercent);
    let leftX = -cw / 2;
    let leftY = dragYOffset;
    let rightX = width - cw / 2;
    let rightY = dragYOffset;
    const part = this.currentPart();
    if (part !== 0) {
      const pv = this.partValue(part);
      const early = part <= 2;
      leftX -= (early ? 2 : 1) * pv / 4;
      rightX += (early ? 1 : 2) * pv / 2;
    }
    if (leftY + scale * ch < height + 2) {
      leftY = height + 2 - scale * ch;
    }
    if (rightY + scale * ch < height + 2) {
      rightY = height + 2 - scale * ch;
    }
    cloud.opacity = 100 / 255;
    cylMove(cloud, 0, 0);
    ctx.save();
    ctx.translate(leftX, leftY);
    ctx.translate(cw * 3 / 4, ch);
    ctx.scale(scale, scale);
    ctx.translate(-cw * 3 / 4, -ch);
    cloud.renderInContext(ctx);
    ctx.restore();
    ctx.save();
    ctx.translate(rightX, rightY);
    ctx.translate(0, ch);
    ctx.scale(scale, scale);
    ctx.translate(0, -ch);
    cloud.renderInContext(ctx);
    ctx.restore();
    cloud.opacity = 1;
  }

  private drawCloudCenter(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    const cloud = this.cloud;
    const cw = cloud.size.width;
    const ch = cloud.size.height;
    const percent = this.dragPercent;
    const dragPercent = Math.min(1, Math.abs(percent));
    const overDrag = percent > 1;
    const overDragPercent = overDrag ? Math.abs(1 - percent) : 0;
    const delta = dragPercent - SCALE_START_PERCENT;
    const scale = delta > 0 ? 0.8 + 0.2 * (delta / (1 - SCALE_START_PERCENT)) : 0.8;
    const dragYOffset = this.expandHeight * dragPercent;
    const startParallax = Math.trunc(this.expandHeight - ch / 2);
    const parallax = dragYOffset > startParallax ? dragYOffset - startParallax : 0;
    const offsetX = width / 2 - cw / 2;
    let offsetY = dragYOffset - ch / 2 - parallax;
    let sx = overDrag ? scale + overDragPercent / 4 : scale;
    const part = this.currentPart();
    if (part !== 0 && !overDrag) {
      const pv = this.partValue(part);
      sx = part <= 2 ? scale - pv / LOADING_ANIMATION_COEFFICIENT / 8 : scale + pv / LOADING_ANIMATION_COEFFICIENT / 6;
    }
    if (offsetY + sx * ch < height + 2) {
      offsetY = height + 2 - sx * ch;
    }
    cylMove(cloud, 0, 0);
    ctx.save();
    ctx.translate(offsetX, offsetY);
    ctx.translate(cw / 2, 0);
    ctx.scale(sx, sx);
    ctx.translate(-cw / 2, 0);
    cloud.renderInContext(ctx);
    ctx.restore();
  }

  drawInContext(ctx: CanvasRenderingContext2D): void {
    const width = this.width;
    const height = this.dragOffset;
    const now = this.cyl_now;
    const rt = this.refreshingTween;
    if (rt !== null) {
      this.loading = LOADING_ANIMATION_COEFFICIENT * (rt.value(now) / SLOW_DOWN_ANIMATION_COEFFICIENT);
    }
    const finish = this.finish;
    if (finish !== null) {
      this.finishTime = finish.value(now);
      if (this.finishTime >= 0.95) {
        this.refreshingTween = null;
      }
      if (finish.done(now)) {
        this.finish = null;
        this.finishTime = 0;
        this.refreshingTween = null;
      }
    }
    ctx.fillStyle = this.cyl_primaryColor;
    ctx.fillRect(0, 0, width, height);
    this.drawWinds(ctx, width, height);
    this.drawAirplane(ctx, width);
    this.drawCloudSide(ctx, width, height);
    this.drawCloudCenter(ctx, width, height);
  }
}
