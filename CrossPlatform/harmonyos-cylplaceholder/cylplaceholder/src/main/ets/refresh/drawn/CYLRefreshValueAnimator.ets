// CYLRefreshValueAnimator: the HarmonyOS counterpart of iOS Support/CYLRefreshValueAnimator.h (CYLRefresh styles's
// ValueAnimator): a value going from `fromValue` to `toValue` (or through `setFromToPoints`) over `duration` seconds,
// stepped by a display timer, with interpolators, repeats and a delegate. The target-selector pair is a callback.
// No ArkUI dependency: the step is public (`cyl_step`) and the clock replaceable (`clock`), so it is host-tested.

/** How the time fraction is eased (iOS `CYLRefreshAnimatorInterpolator`). */
export enum CYLRefreshAnimatorInterpolator {
  AnimatorInterpolatorLinear = 0,
  AnimatorInterpolatorAccelerate = 1,
  AnimatorInterpolatorDecelerate = 2,
  AnimatorInterpolatorAccelerateDecelerate = 3,
  AnimatorInterpolatorBounce = 4
}

/** What a repeat does (iOS `CYLRefreshAnimatorRepeatMode`). */
export enum CYLRefreshAnimatorRepeatMode {
  AnimatorRepeatModeRestart = 0,
  AnimatorRepeatModeReverse = 1
}

/** A custom interpolator, time fraction → eased fraction (iOS `CYLRefreshAnimatorInterpolatorBlock`). */
export type CYLRefreshAnimatorInterpolatorBlock = (value: number) => number;

/** The action of `setTarget:selector:`, called with the animator on every step. */
export type CYLRefreshValueAnimatorAction = (animator: CYLRefreshValueAnimator) => void;

/** The animator's delegate; every member is optional (iOS `CYLRefreshValueAnimatorDelegate`). */
export interface CYLRefreshValueAnimatorDelegate {
  /** The animation started (`-onAnimationStart:`). */
  onAnimationStart?: (animator: CYLRefreshValueAnimator) => void;
  /** A cycle ended and the next begins (`-onAnimationRepeat:`). */
  onAnimationRepeat?: (animator: CYLRefreshValueAnimator) => void;
  /** The last cycle ended (`-onAnimationEnd:`). */
  onAnimationEnd?: (animator: CYLRefreshValueAnimator) => void;
}

/** The display link's period, in ms. */
const CYLRefreshValueAnimatorFrame: number = 16;

export class CYLRefreshValueAnimator {
  /** The clock, in seconds (CACurrentMediaTime); tests replace it. */
  static clock: () => number = () => Date.now() / 1000;
  /** The start value (`fromValue`). */
  fromValue: number = 0;
  /** The end value (`toValue`). */
  toValue: number = 1;
  /** Kept from iOS; the iOS animator does not read it either (`speed`). */
  speed: number = 1;
  /** Cycles left; Infinity for ever (`repeatCount`). */
  repeatCount: number = 1;
  /** Seconds to wait before starting (`beginTime`). */
  beginTime: number = 0;
  /** One cycle, in seconds (`duration`). */
  duration: number = 1;
  /** Restart or reverse on repeat (`repeatMode`). */
  repeatMode: CYLRefreshAnimatorRepeatMode = CYLRefreshAnimatorRepeatMode.AnimatorRepeatModeRestart;
  /** The easing (`interpolator`). */
  interpolator: CYLRefreshAnimatorInterpolator = CYLRefreshAnimatorInterpolator.AnimatorInterpolatorLinear;
  /** The delegate, or null (`delegate`). */
  delegate: CYLRefreshValueAnimatorDelegate | null = null;
  /** A custom easing that wins over `interpolator`, or null (`interpolatorBlock`). */
  interpolatorBlock: CYLRefreshAnimatorInterpolatorBlock | null = null;
  private target: Object | null = null;
  private action: CYLRefreshValueAnimatorAction | null = null;
  private points: number[] = [];
  private currentValue: number = 0;
  private timeOffset: number = 0;
  private timeStart: number = 0;
  private reversed: boolean = false;
  private link: number = -1;
  private linked: boolean = false;
  private pendingStart: number = -1;

  /** An animator from `from` to `to` (`+newWithFrom:to:`). */
  static newWithFrom(from: number, to: number): CYLRefreshValueAnimator {
    const animator = new CYLRefreshValueAnimator();
    animator.setFrom(from, to);
    return animator;
  }

  /** An animator calling `action` on every step (`+newWithTarget:selector:`). */
  static newWithTarget(target: Object, action: CYLRefreshValueAnimatorAction): CYLRefreshValueAnimator {
    const animator = new CYLRefreshValueAnimator();
    animator.setTarget(target, action);
    return animator;
  }

  /** Calls `action` on every step (`-setTarget:selector:`). */
  setTarget(target: Object, action: CYLRefreshValueAnimatorAction): void {
    this.target = target;
    this.action = action;
  }

  /** Sets the start and end values; the value jumps to `from` while stopped (`-setFrom:to:`). */
  setFrom(from: number, to: number): void {
    this.toValue = to;
    this.fromValue = from;
    if (!this.isRunning) {
      this.currentValue = from;
    }
  }

  /** Goes through `points` instead, piecewise linearly (`-setFromToPoints:`). */
  setFromToPoints(points: number[]): void {
    this.points = points.slice();
    if (!this.isRunning && points.length > 0) {
      this.currentValue = points[0];
    }
  }

  /** Whether the display link runs (`isRunning`). */
  get isRunning(): boolean {
    return this.linked;
  }

  /** The current value (`value`). */
  get value(): number {
    return this.currentValue;
  }

  /** The eased fraction of the current cycle (`percent`). */
  get percent(): number {
    return this.interpolation(this.timeOffset / this.duration);
  }

  /** Starts, after `beginTime` seconds when set (`-start`). */
  start(): void {
    if (this.linked || this.pendingStart >= 0) {
      return;
    }
    if (this.beginTime > 0) {
      this.pendingStart = setTimeout(() => {
        this.pendingStart = -1;
        this.startInternal();
      }, this.beginTime * 1000);
    } else {
      this.startInternal();
    }
  }

  /** Stops (`-stop`). */
  stop(): void {
    if (this.pendingStart >= 0) {
      clearTimeout(this.pendingStart);
      this.pendingStart = -1;
    }
    if (this.linked) {
      if (this.link >= 0) {
        clearInterval(this.link);
      }
      this.link = -1;
      this.linked = false;
    }
  }

  private startInternal(): void {
    this.timeOffset = 0;
    this.reversed = false;
    this.timeStart = CYLRefreshValueAnimator.clock();
    this.linked = true;
    this.link = setInterval(() => this.cyl_step(), CYLRefreshValueAnimatorFrame);
    const d = this.delegate;
    if (d !== null && d.onAnimationStart !== undefined) {
      d.onAnimationStart(this);
    }
  }

  private valueFromPoints(time: number, reversed: boolean): number {
    const points = reversed ? this.points.slice().reverse() : this.points;
    const count = points.length;
    for (let i = 0; i < count - 1 && count > 1; i++) {
      const start = i / count;
      const end = (i + 1) / count;
      if (time >= start && time < end) {
        return points[i] + (points[i + 1] - points[i]) * ((time - start) / (end - start));
      }
    }
    return this.points[0];
  }

  /** One display-link step (`-step:`); public so tests drive it with a fake clock. */
  cyl_step(): void {
    if (!this.linked) {
      return;
    }
    const thisStep = CYLRefreshValueAnimator.clock();
    this.timeOffset = Math.min(thisStep - this.timeStart, this.duration);
    const time = this.interpolation(this.timeOffset / this.duration);
    if (this.points.length > 0) {
      this.currentValue = this.valueFromPoints(time, this.reversed);
    } else {
      const from = this.reversed ? this.toValue : this.fromValue;
      const to = this.reversed ? this.fromValue : this.toValue;
      this.currentValue = from + (to - from) * time;
    }
    if (this.target !== null && this.action !== null) {
      this.action(this);
    }
    if (this.timeOffset >= this.duration) {
      if (this.repeatCount !== Infinity) {
        this.repeatCount = this.repeatCount - 1;
      }
      const d = this.delegate;
      if (this.repeatCount <= 0) {
        if (d !== null && d.onAnimationEnd !== undefined) {
          d.onAnimationEnd(this);
        }
        this.stop();
      } else {
        if (d !== null && d.onAnimationRepeat !== undefined) {
          d.onAnimationRepeat(this);
        }
        if (this.repeatMode === CYLRefreshAnimatorRepeatMode.AnimatorRepeatModeReverse) {
          this.reversed = !this.reversed;
        } else {
          this.currentValue = this.fromValue;
        }
      }
      this.timeStart = thisStep;
    }
  }

  /** The eased fraction (`-interpolation:`). */
  interpolation(value: number): number {
    if (this.interpolatorBlock !== null) {
      return this.interpolatorBlock(value);
    }
    return CYLRefreshValueAnimator.interpolate(this.interpolator, value);
  }

  /** The easing of an interpolator kind, shared with the drawn styles' frame tweens. */
  static interpolate(kind: CYLRefreshAnimatorInterpolator, value: number): number {
    switch (kind) {
      case CYLRefreshAnimatorInterpolator.AnimatorInterpolatorAccelerateDecelerate:
        return Math.cos((value + 1) * 3.1415926) / 2 + 0.5;
      case CYLRefreshAnimatorInterpolator.AnimatorInterpolatorAccelerate:
        return value * value;
      case CYLRefreshAnimatorInterpolator.AnimatorInterpolatorDecelerate:
        return 1.0 - (1.0 - value) * (1.0 - value);
      case CYLRefreshAnimatorInterpolator.AnimatorInterpolatorBounce: {
        const bounce = (v: number): number => v * v * 8;
        const v = value * 1.1226;
        if (v < 0.3535) {
          return bounce(v);
        } else if (v < 0.7408) {
          return bounce(v - 0.54719) + 0.7;
        } else if (v < 0.9644) {
          return bounce(v - 0.8526) + 0.9;
        }
        return bounce(v - 1.0435) + 0.95;
      }
      default:
        return value;
    }
  }

  static linear(t: number): number {
    return t;
  }

  static accelerate(t: number): number {
    return CYLRefreshValueAnimator.interpolate(CYLRefreshAnimatorInterpolator.AnimatorInterpolatorAccelerate, t);
  }

  static decelerate(t: number): number {
    return CYLRefreshValueAnimator.interpolate(CYLRefreshAnimatorInterpolator.AnimatorInterpolatorDecelerate, t);
  }

  static accelerateDecelerate(t: number): number {
    return CYLRefreshValueAnimator.interpolate(
      CYLRefreshAnimatorInterpolator.AnimatorInterpolatorAccelerateDecelerate, t);
  }

  static bounce(t: number): number {
    return CYLRefreshValueAnimator.interpolate(CYLRefreshAnimatorInterpolator.AnimatorInterpolatorBounce, t);
  }
}
