// CYLRefreshIconView: the HarmonyOS counterpart of iOS CYLRefreshIconView.h: an icon per refresh state (frame images
// or an animation file) shown by a control in place of its arrow / spinner, with an optional title. The UI
// (CYLRefreshView.ets) draws frame images and GIF files; Lottie / PAG / Rive files are kept for the later animation
// player step (`isPlayableNow` is false for them).
import { CYLRefreshState } from './CYLRefreshConst';

/** The size of an icon, in vp (CGSize). */
export class CYLRefreshIconSize {
  width: number;
  height: number;

  constructor(width: number, height: number) {
    this.width = width;
    this.height = height;
  }
}

/**
 * The animation of one state (the iOS attributes dictionary): an animation file path (`filePath`, rawfile path or
 * URI), or frame images played over `duration` seconds, at `size` (iOS keys CYLPlaceholderItemAnimationFilePath,
 * CYLPlaceholderItemImages, CYLPlaceholderItemAnimationDuration, CYLPlaceholderItemImageSize).
 */
export class CYLRefreshIconAttributes {
  filePath: string | null = null;
  images: ResourceStr[] = [];
  duration: number = 0;
  size: CYLRefreshIconSize = new CYLRefreshIconSize(40, 40);

  /** Whether the HarmonyOS UI plays it today: frame images and GIF / WebP / PNG files. */
  get isPlayableNow(): boolean {
    if (this.images.length > 0) {
      return true;
    }
    if (this.filePath === null) {
      return false;
    }
    const lower = this.filePath.toLowerCase();
    return lower.endsWith('.gif') || lower.endsWith('.webp') || lower.endsWith('.png') || lower.endsWith('.apng');
  }
}

/** The bundled refresh animations (rawfile/cylplaceholder/refresh). */
const BUNDLED: string[] = ['CYLRefreshArrows.gif', 'CYLRefreshPullArrow.json'];

/** The icon of a control (iOS `CYLRefreshIconView`). */
export class CYLRefreshIconViewModel {
  cyl_x: number = 0;
  cyl_y: number = 0;
  cyl_w: number = 0;
  cyl_h: number = 0;
  hidden: boolean = true;
  /** The title shown below the icon, or null (`title`). */
  title: string | null = null;
  /** The title's font size in fp (`titleFont`). */
  titleFont: number = 12;
  /** The title's color (`titleColor`). */
  titleColor: string = '#5A5A5A';
  /** Whether the frames follow the pull while the control is pulled (`scrubsWhilePulling`, default true). */
  scrubsWhilePulling: boolean = true;
  /** The frame shown while pulled (frame images). */
  frameIndex: number = 0;
  /** Whether the current animation plays (refreshing) rather than following the pull. */
  playing: boolean = false;
  /** The attributes of the state shown, or null. */
  current: CYLRefreshIconAttributes | null = null;
  private attributes: Map<CYLRefreshState, CYLRefreshIconAttributes> = new Map();

  /** Sets (or with null removes) the animation of a state (`-setAnimationAttributes:forState:`). */
  setAnimationAttributes(attributes: CYLRefreshIconAttributes | null, state: CYLRefreshState): void {
    if (attributes === null) {
      this.attributes.delete(state);
    } else {
      this.attributes.set(state, attributes);
    }
  }

  /** The animation of a state, or null (`-animationAttributesForState:`). */
  animationAttributesForState(state: CYLRefreshState): CYLRefreshIconAttributes | null {
    const a = this.attributes.get(state);
    return a !== undefined ? a : null;
  }

  /** Whether any state has an animation (`hasAnimations`). */
  get hasAnimations(): boolean {
    return this.attributes.size > 0;
  }

  /** The size of the icon shown (`iconSize`); 0 x 0 without one. */
  get iconSize(): CYLRefreshIconSize {
    return this.current !== null ? this.current.size : new CYLRefreshIconSize(0, 0);
  }

  /** The icon plus its title (`fittingSize`). */
  get fittingSize(): CYLRefreshIconSize {
    const icon = this.iconSize;
    if (this.title === null || this.title.length === 0) {
      return icon;
    }
    const titleH = Math.ceil(this.titleFont * 1.3);
    const titleW = Math.ceil(this.title.length * this.titleFont * 0.6);
    return new CYLRefreshIconSize(Math.max(icon.width, titleW), icon.height + 4 + titleH);
  }

  /** Shows the animation of `state` (the Idle one when it has none); plays it while refreshing (`-updateForState:`). */
  updateForState(state: CYLRefreshState): void {
    const own = this.attributes.get(state);
    const idle = this.attributes.get(CYLRefreshState.Idle);
    this.current = own !== undefined ? own : (idle !== undefined ? idle : null);
    this.playing = state === CYLRefreshState.Refreshing || state === CYLRefreshState.WillRefresh ||
      !this.scrubsWhilePulling;
  }

  /** Moves the frames with the pull (`-updateForPullingPercent:`). */
  updateForPullingPercent(pullingPercent: number): void {
    const current = this.current;
    if (current === null || this.playing || !this.scrubsWhilePulling || current.images.length === 0) {
      return;
    }
    const p = Math.min(1, Math.max(0, pullingPercent));
    this.frameIndex = Math.floor((current.images.length - 1) * p);
  }

  /** Attributes for an animation file (`+attributesForAnimationFilePath:size:`). */
  static attributesForAnimationFilePath(filePath: string, size: CYLRefreshIconSize): CYLRefreshIconAttributes | null {
    if (filePath.length === 0) {
      return null;
    }
    const a = new CYLRefreshIconAttributes();
    a.filePath = filePath;
    a.size = size;
    return a;
  }

  /** Attributes for a bundled animation (`+attributesForBundledAnimation:size:`); null for an unknown name. */
  static attributesForBundledAnimation(fileName: string, size: CYLRefreshIconSize): CYLRefreshIconAttributes | null {
    if (!BUNDLED.includes(fileName)) {
      return null;
    }
    return CYLRefreshIconViewModel.attributesForAnimationFilePath('cylplaceholder/refresh/' + fileName, size);
  }

  /** The bundled refresh animations (`bundledAnimationFileNames`). */
  static get bundledAnimationFileNames(): string[] {
    return BUNDLED.slice();
  }
}
