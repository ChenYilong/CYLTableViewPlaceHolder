// CYLRefreshBallPulse: the HarmonyOS counterpart of iOS CYLRefreshBallPulseFooter (Custom/Drawn/CYLRefreshDrawnFooter):
// three balls that pulse in turn while loading more, an auto footer. The model holds the colors, the state and the
// geometry; CYLRefreshBallPulseView (CYLRefreshBallPulseView.ets) draws them. Written, not built.
import { CYLRefreshAutoFooterModel } from '../CYLRefreshComponent';
import {
  CYLRefreshAutoFooterRefreshingText,
  CYLRefreshComponentAction,
  CYLRefreshLocalizedString,
  CYLRefreshState
} from '../CYLRefreshConst';

/** The gap between two balls in vp (iOS `spacing`). */
export const CYLRefreshBallPulseSpacing: number = 4;
/** Seconds one ball's pulse takes (iOS 0.75). */
export const CYLRefreshBallPulsePeriod: number = 0.75;
/** Seconds each ball starts after the one before (iOS 0.12). */
export const CYLRefreshBallPulseDelay: number = 0.12;

/** The radius of a ball in a `width` x `height` footer (iOS `placeSubviews`). */
export function CYLRefreshBallPulseRadius(width: number, height: number): number {
  return (Math.min(width, height) - CYLRefreshBallPulseSpacing * 2) / 6;
}

/** The center x of ball `index` (0..2) in a `width` wide footer; the centers share y = height / 2. */
export function CYLRefreshBallPulseCenterX(width: number, radius: number, index: number): number {
  return width / 2 - (radius * 2 + CYLRefreshBallPulseSpacing) + index * (radius * 2 + CYLRefreshBallPulseSpacing);
}

/**
 * The scale of ball `index` (0..2) `elapsed` seconds after the pulsing began: an accelerate-decelerate cycle of 0.75 s,
 * each ball 0.12 s after the previous one (iOS `tick`, as Android's BallPulseFooter). 1 before the ball starts.
 */
export function CYLRefreshBallPulseScale(elapsed: number, index: number): number {
  const time = elapsed - CYLRefreshBallPulseDelay * (index + 1);
  const linear = time > 0 ? (time % CYLRefreshBallPulsePeriod) / CYLRefreshBallPulsePeriod : 0;
  const percent = Math.cos((linear + 1) * Math.PI) / 2 + 0.5;
  return percent < 0.5 ? 1 - percent * 2 * 0.7 : percent * 2 * 0.7 - 0.4;
}

/** Three balls that pulse in turn while loading more; an auto footer (iOS `CYLRefreshBallPulseFooter`). */
export class CYLRefreshBallPulseFooterModel extends CYLRefreshAutoFooterModel {
  private normal: string = '#EEEEEE';
  private animating: string = '#E75946';

  /** A BallPulse footer calling `block` when it loads. */
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshBallPulseFooterModel {
    const footer = new CYLRefreshBallPulseFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  /** A 60 vp footer with three balls (iOS `prepare`). */
  prepare(): void {
    super.prepare();
    this.cyl_h = 60;
  }

  /** The balls' color while idle, default #EEEEEE (`normalColor`). */
  get normalColor(): string {
    return this.normal;
  }

  set normalColor(value: string) {
    this.normal = value;
    this.cyl_setNeedsLayout();
  }

  /** The balls' color while loading, default #E75946 (`animatingColor`). */
  get animatingColor(): string {
    return this.animating;
  }

  set animatingColor(value: string) {
    this.animating = value;
    this.cyl_setNeedsLayout();
  }

  /** The color the balls are filled with now: `animatingColor` while loading, else `normalColor`. */
  get cyl_ballColor(): string {
    return this.state === CYLRefreshState.Refreshing ? this.animating : this.normal;
  }

  /** Whether the balls are hidden (no more data). */
  get cyl_ballsHidden(): boolean {
    return this.state === CYLRefreshState.NoMoreData;
  }

  /** Whether the balls pulse (while loading). */
  get cyl_pulsing(): boolean {
    return this.state === CYLRefreshState.Refreshing;
  }

  /** The localized text a screen reader says while loading; null otherwise (iOS `accessibilityLabel`). */
  get cyl_accessibilityLabel(): string | null {
    return this.cyl_pulsing ? CYLRefreshLocalizedString(CYLRefreshAutoFooterRefreshingText) : null;
  }
}
