// CYLRefreshDrawnSupport: the small Core Graphics stand-ins the drawn CYLRefresh styles share on HarmonyOS
// (CGRect, CGAffineTransform, UIColor mixing) and a frame-time tween, the per-frame form of CYLRefreshValueAnimator
// the styles step from their canvas frame clock. No ArkUI dependency (host unit-tested).
import { CYLPoint } from '../CYLRefreshComponent';

/** A rectangle (CGRect). */
export class CYLRefreshRect {
  x: number;
  y: number;
  width: number;
  height: number;

  constructor(x: number, y: number, width: number, height: number) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  static zero(): CYLRefreshRect {
    return new CYLRefreshRect(0, 0, 0, 0);
  }

  /** CGRectEqualToRect(rect, CGRectZero). */
  isZero(): boolean {
    return this.x === 0 && this.y === 0 && this.width === 0 && this.height === 0;
  }

  /** CGRectUnion (CGRectZero is a real rectangle at the origin, as in Core Graphics). */
  union(other: CYLRefreshRect): CYLRefreshRect {
    const x0 = Math.min(this.x, other.x);
    const y0 = Math.min(this.y, other.y);
    const x1 = Math.max(this.x + this.width, other.x + other.width);
    const y1 = Math.max(this.y + this.height, other.y + other.height);
    return new CYLRefreshRect(x0, y0, x1 - x0, y1 - y0);
  }

  copy(): CYLRefreshRect {
    return new CYLRefreshRect(this.x, this.y, this.width, this.height);
  }
}

/** An affine transform (CGAffineTransform): x' = a x + c y + tx, y' = b x + d y + ty. */
export class CYLRefreshAffineTransform {
  a: number;
  b: number;
  c: number;
  d: number;
  tx: number;
  ty: number;

  constructor(a: number, b: number, c: number, d: number, tx: number, ty: number) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    this.tx = tx;
    this.ty = ty;
  }

  /** CGAffineTransformIdentity. */
  static identity(): CYLRefreshAffineTransform {
    return new CYLRefreshAffineTransform(1, 0, 0, 1, 0, 0);
  }

  /** CGAffineTransformMakeTranslation. */
  static makeTranslation(tx: number, ty: number): CYLRefreshAffineTransform {
    return new CYLRefreshAffineTransform(1, 0, 0, 1, tx, ty);
  }

  /** CGAffineTransformMakeScale. */
  static makeScale(sx: number, sy: number): CYLRefreshAffineTransform {
    return new CYLRefreshAffineTransform(sx, 0, 0, sy, 0, 0);
  }

  /** CGAffineTransformMakeRotation. */
  static makeRotation(angle: number): CYLRefreshAffineTransform {
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    return new CYLRefreshAffineTransform(cos, sin, -sin, cos, 0, 0);
  }

  /** CGAffineTransformConcat(this, t): this first, then t. */
  concat(t: CYLRefreshAffineTransform): CYLRefreshAffineTransform {
    return new CYLRefreshAffineTransform(
      this.a * t.a + this.b * t.c,
      this.a * t.b + this.b * t.d,
      this.c * t.a + this.d * t.c,
      this.c * t.b + this.d * t.d,
      this.tx * t.a + this.ty * t.c + t.tx,
      this.tx * t.b + this.ty * t.d + t.ty);
  }

  /** CGAffineTransformTranslate: translates first, then applies this. */
  translate(tx: number, ty: number): CYLRefreshAffineTransform {
    return CYLRefreshAffineTransform.makeTranslation(tx, ty).concat(this);
  }

  /** CGAffineTransformScale. */
  scale(sx: number, sy: number): CYLRefreshAffineTransform {
    return CYLRefreshAffineTransform.makeScale(sx, sy).concat(this);
  }

  /** CGAffineTransformRotate. */
  rotate(angle: number): CYLRefreshAffineTransform {
    return CYLRefreshAffineTransform.makeRotation(angle).concat(this);
  }

  /** CGPointApplyAffineTransform. */
  apply(x: number, y: number): CYLPoint {
    return new CYLPoint(this.a * x + this.c * y + this.tx, this.b * x + this.d * y + this.ty);
  }

  isIdentity(): boolean {
    return this.a === 1 && this.b === 0 && this.c === 0 && this.d === 1 && this.tx === 0 && this.ty === 0;
  }
}

/** Color helpers on CSS / ArkUI color strings: '#rgb', '#rrggbb', '#aarrggbb' (ArkUI), 'rgb()', 'rgba()'. */
export class CYLRefreshDrawnColor {
  /** [r, g, b, a] with r, g, b in 0..255 and a in 0..1; 'transparent' and 'clear' are [0, 0, 0, 0]. */
  static parse(color: string | null): number[] {
    if (color === null || color === '' || color === 'transparent' || color === 'clear') {
      return [0, 0, 0, 0];
    }
    if (color.charAt(0) === '#') {
      let h = color.substring(1);
      if (h.length === 3) {
        h = h.charAt(0) + h.charAt(0) + h.charAt(1) + h.charAt(1) + h.charAt(2) + h.charAt(2);
      }
      const n = (i: number): number => parseInt(h.substring(i, i + 2), 16);
      if (h.length === 8) {
        return [n(2), n(4), n(6), n(0) / 255];
      }
      return [n(0), n(2), n(4), 1];
    }
    const m = color.match(new RegExp('[\\d.]+', 'g'));
    const v = (i: number, d: number): number => m !== null && m.length > i ? Number(m[i]) : d;
    return [v(0, 0), v(1, 0), v(2, 0), v(3, 1)];
  }

  /** An 'rgba()' string. */
  static rgba(r: number, g: number, b: number, a: number): string {
    return 'rgba(' + Math.round(r) + ',' + Math.round(g) + ',' + Math.round(b) + ',' +
      Math.max(0, Math.min(1, a)) + ')';
  }

  /** The color with its alpha multiplied by `alpha` (colorWithAlphaComponent on an opaque color). */
  static alpha(color: string | null, alpha: number): string {
    const p = CYLRefreshDrawnColor.parse(color);
    return CYLRefreshDrawnColor.rgba(p[0], p[1], p[2], p[3] * alpha);
  }

  /** Linear mix of two colors, t in 0..1. */
  static mix(c1: string | null, c2: string | null, t: number): string {
    const a = CYLRefreshDrawnColor.parse(c1);
    const b = CYLRefreshDrawnColor.parse(c2);
    return CYLRefreshDrawnColor.rgba(a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t,
      a[3] + (b[3] - a[3]) * t);
  }

  /** CYLRefreshMountainView `mix:c2:`: color1 blended with an ARGB color by its alpha, opaque. */
  static mixArgb(color: string | null, argb: number): string {
    const a = CYLRefreshDrawnColor.parse(color);
    const ratio = Math.floor(argb / 0x1000000) / 255;
    const r = Math.floor(argb / 0x10000) % 256;
    const g = Math.floor(argb / 0x100) % 256;
    const b = argb % 256;
    return CYLRefreshDrawnColor.rgba(a[0] * (1 - ratio) + r * ratio, a[1] * (1 - ratio) + g * ratio,
      a[2] * (1 - ratio) + b * ratio, 1);
  }

  /** Whether the color is clear (UIColor.clearColor), or null. */
  static isClear(color: string | null): boolean {
    return CYLRefreshDrawnColor.parse(color)[3] === 0;
  }
}

/** The interpolators of CYLRefreshValueAnimator, by kind (see CYLRefreshAnimatorInterpolator). */
export type CYLRefreshDrawnEase = (t: number) => number;

/**
 * A value tween stepped by the frame clock (ms): from → to over `duration` seconds, repeated `repeat` times
 * (Infinity for ever), restarting or reversing. The drawn styles run their CYLRefreshValueAnimator chains with it,
 * so a frame computes the same value as the animator's display link would.
 */
export class CYLRefreshDrawnTween {
  from: number;
  to: number;
  duration: number;
  repeat: number = 0;
  reverse: boolean = false;
  ease: CYLRefreshDrawnEase;
  start: number;

  constructor(from: number, to: number, duration: number, ease: CYLRefreshDrawnEase, now: number) {
    this.from = from;
    this.to = to;
    this.duration = Math.max(0.001, duration) * 1000;
    this.ease = ease;
    this.start = now;
  }

  static repeating(from: number, to: number, duration: number, ease: CYLRefreshDrawnEase, now: number,
    reverse: boolean): CYLRefreshDrawnTween {
    const t = new CYLRefreshDrawnTween(from, to, duration, ease, now);
    t.repeat = Infinity;
    t.reverse = reverse;
    return t;
  }

  /** The raw time fraction of the current cycle (0..1), reversed on odd cycles in reverse mode. */
  fraction(now: number): number {
    const raw = (now - this.start) / this.duration;
    if (raw >= this.repeat + 1) {
      return this.reverse && this.repeat % 2 === 1 ? 0 : 1;
    }
    const k = Math.floor(Math.max(0, raw));
    let t = Math.max(0, raw) - k;
    if (this.reverse && k % 2 === 1) {
      t = 1 - t;
    }
    return t;
  }

  done(now: number): boolean {
    return (now - this.start) / this.duration >= this.repeat + 1;
  }

  value(now: number): number {
    return this.from + (this.to - this.from) * this.ease(this.fraction(now));
  }
}

/** A cubic-bezier timing curve (CAMediaTimingFunction / Android PathInterpolator), x → y. */
export function cylRefreshCubicBezier(x1: number, y1: number, x2: number, y2: number): CYLRefreshDrawnEase {
  const c = (t: number, a: number, b: number): number => 3 * (1 - t) * (1 - t) * t * a + 3 * (1 - t) * t * t * b +
    t * t * t;
  return (x: number): number => {
    if (x <= 0) {
      return 0;
    }
    if (x >= 1) {
      return 1;
    }
    let lo = 0;
    let hi = 1;
    for (let i = 0; i < 24; i++) {
      const t = (lo + hi) / 2;
      if (c(t, x1, x2) < x) {
        lo = t;
      } else {
        hi = t;
      }
    }
    return c((lo + hi) / 2, y1, y2);
  };
}
