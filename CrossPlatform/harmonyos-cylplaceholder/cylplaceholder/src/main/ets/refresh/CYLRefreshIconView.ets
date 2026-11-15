// CYLRefreshIconView: the HarmonyOS counterpart of iOS CYLRefreshIconView.h: an icon per refresh state (frame images
// or an animation file) shown by a control in place of its arrow / spinner, with an optional title. The UI
// (CYLRefreshView.ets) draws frame images and GIF / PNG files itself, and Lottie / PAG / Rive files (any file an
// animator of the library's registry plays) through `placeholderView`, a view of CYLPlaceholderItemAnimationFactory,
// played by the iOS policy (`CYLRefreshIconPlaybackFor`).
import { CYLRefreshState } from './CYLRefreshConst';
import {
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationURLWithOptions,
  CYLPlaceholderItemAnimationFactory,
  CYLPlaceholderItemAnimationPlayer,
  CYLPlaceholderItemAnimatorRegistering,
  CYLPlaceholderItemAnimatorRegistry
} from '../CYLPlaceholderAnimation';

/** The size of an icon, in vp (CGSize). */
export class CYLRefreshIconSize {
  width: number;
  height: number;

  constructor(width: number, height: number) {
    this.width = width;
    this.height = height;
  }
}

/** What draws an icon (iOS: CYLPlaceholderView picks the engine of the attributes). */
export enum CYLRefreshIconEngine {
  /** Nothing to draw. */
  None = 0,
  /** Frame images (`images`). */
  Frames = 1,
  /** An image file no animator plays, drawn by ArkUI Image: GIF, WebP, APNG, PNG. */
  Image = 2,
  /** A file played by an animator of the registry (GIF, Lottie, PAG, Rive): `placeholderView`. */
  Animator = 3
}

/** What the icon does now (the iOS playback policy of CYLRefreshIconView.h). */
export enum CYLRefreshIconPlayback {
  /** Stopped on its resting frame. */
  Stop = 0,
  /** Follows the pulling percent (engines that can seek). */
  Scrub = 1,
  /** Plays, looping. */
  Play = 2
}

/**
 * The iOS policy: idle and not pulled stops; idle and pulled scrubs when `scrubsWhilePulling` and the engine can
 * seek, else plays; pulling, refreshing and will refresh play, looping; no more data stops.
 */
export function CYLRefreshIconPlaybackFor(state: CYLRefreshState, pullingPercent: number, scrubsWhilePulling: boolean,
  canSeek: boolean): CYLRefreshIconPlayback {
  if (state === CYLRefreshState.Pulling || state === CYLRefreshState.Refreshing ||
    state === CYLRefreshState.WillRefresh) {
    return CYLRefreshIconPlayback.Play;
  }
  if (state !== CYLRefreshState.Idle || pullingPercent <= 0) {
    return CYLRefreshIconPlayback.Stop;
  }
  return scrubsWhilePulling && canSeek ? CYLRefreshIconPlayback.Scrub : CYLRefreshIconPlayback.Play;
}

/**
 * The animation of one state (the iOS attributes dictionary): an animation file path (`filePath`, rawfile path or
 * URI) with its engine `options`, or frame images played over `duration` seconds, at `size` (iOS keys
 * CYLPlaceholderItemAnimationFilePath, CYLPlaceholderItemAnimationOptions, CYLPlaceholderItemImages,
 * CYLPlaceholderItemAnimationDuration, CYLPlaceholderItemImageSize).
 */
export class CYLRefreshIconAttributes {
  filePath: string | null = null;
  images: ResourceStr[] = [];
  duration: number = 0;
  size: CYLRefreshIconSize = new CYLRefreshIconSize(40, 40);
  /** Engine options (CYLPlaceholderItemAnimationOptions), such as a Rive artboard or animation. */
  options: Record<string, string> = {};

  /** The file with its options, as the animators read it; null without a file. */
  get animationURL(): string | null {
    if (this.filePath === null) {
      return null;
    }
    return Object.keys(this.options).length > 0 ?
      CYLPlaceholderAnimationURLWithOptions(this.filePath as string, this.options) : this.filePath as string;
  }

  /** What draws these attributes, with the animators of `registry` (the shared one by default). */
  engine(registry: CYLPlaceholderItemAnimatorRegistering | null = null): CYLRefreshIconEngine {
    if (this.images.length > 0) {
      return CYLRefreshIconEngine.Frames;
    }
    if (this.filePath === null) {
      return CYLRefreshIconEngine.None;
    }
    // iOS draws every file through CYLPlaceholderView, so the registry comes first (GIF, Lottie, PAG, Rive).
    const source: CYLPlaceholderItemAnimatorRegistering = registry !== null ? registry :
      CYLPlaceholderItemAnimatorRegistry.sharedRegistry();
    if (source.animatorForURL(this.animationURL) !== null) {
      return CYLRefreshIconEngine.Animator;
    }
    const lower = (this.filePath as string).toLowerCase();
    if (lower.endsWith('.gif') || lower.endsWith('.webp') || lower.endsWith('.png') || lower.endsWith('.apng')) {
      return CYLRefreshIconEngine.Image;
    }
    return CYLRefreshIconEngine.None;
  }

  /** Whether the UI plays it: frame images, image files, or a file an animator of the shared registry plays. */
  get isPlayableNow(): boolean {
    return this.engine() !== CYLRefreshIconEngine.None;
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
  private views: Map<CYLRefreshIconAttributes, CYLPlaceholderAnimationContentView> = new Map();
  private state: CYLRefreshState = CYLRefreshState.Idle;
  private percent: number = 0;
  private applied: CYLRefreshIconPlayback | null = null;
  private appliedView: CYLPlaceholderAnimationContentView | null = null;
  private speedValue: number = 1;
  private loopsValue: boolean = true;

  /**
   * The playback rate of the icon's animation, 1 by default; applied live (HarmonyOS addition for the examples'
   * speed slider, docs/Example-Animation-Playback.md). Values that are not positive and finite are ignored.
   */
  get animationSpeed(): number {
    return this.speedValue;
  }

  set animationSpeed(value: number) {
    if (!isFinite(value) || value <= 0) {
      return;
    }
    this.speedValue = value;
    const player = this.currentPlayer();
    if (player !== null && player.supportsAnimationSpeed) {
      player.animationSpeed = value;
    }
  }

  /**
   * Whether the animation loops while it plays (refreshing), true by default; false plays it once and rests on its
   * last frame (the examples' loop switch). Applied live.
   */
  get loopsWhilePlaying(): boolean {
    return this.loopsValue;
  }

  set loopsWhilePlaying(value: boolean) {
    this.loopsValue = value;
    const player = this.currentPlayer();
    if (player !== null) {
      player.setAnimationRepeatCount(value ? 0 : 1);
    }
  }

  /** Restarts the current animation from progress 0 with the current speed and loop (the examples' Play all). */
  replayAnimation(): void {
    const player = this.currentPlayer();
    if (player === null) {
      return;
    }
    if (player.supportsAnimationSpeed) {
      player.animationSpeed = this.speedValue;
    }
    player.setAnimationRepeatCount(this.loopsValue ? 0 : 1);
    player.play();
  }

  private currentPlayer(): CYLPlaceholderItemAnimationPlayer | null {
    const view = this.placeholderView;
    return view !== null ? CYLPlaceholderItemAnimationFactory.playerForView(view) : null;
  }

  /**
   * The animation view showing the current state's file (iOS `placeholderView`): made by
   * CYLPlaceholderItemAnimationFactory for Lottie, PAG and Rive files; null for frames, image files and none.
   */
  get placeholderView(): CYLPlaceholderAnimationContentView | null {
    const current = this.current;
    if (current === null || current.engine() !== CYLRefreshIconEngine.Animator) {
      return null;
    }
    const made = this.views.get(current);
    if (made !== undefined) {
      return made;
    }
    const view = CYLPlaceholderItemAnimationFactory.animationViewWithURL(current.animationURL as string,
      current.size.width, current.size.height, ImageFit.Contain);
    if (view !== null) {
      this.views.set(current, view);
    }
    return view;
  }

  /** What the icon does now (`CYLRefreshIconPlaybackFor` with the engine of the current view). */
  get playback(): CYLRefreshIconPlayback {
    const view = this.placeholderView;
    const player = view !== null ? CYLPlaceholderItemAnimationFactory.playerForView(view) : null;
    return CYLRefreshIconPlaybackFor(this.state, this.percent, this.scrubsWhilePulling,
      player !== null && player.supportsProgress);
  }

  /** Drives the animation view by the policy; a command is sent again only when it changes (scrubbing seeks). */
  private applyPlayback(): void {
    const view = this.placeholderView;
    if (view === null) {
      this.applied = null;
      this.appliedView = null;
      return;
    }
    const player: CYLPlaceholderItemAnimationPlayer | null = CYLPlaceholderItemAnimationFactory.playerForView(view);
    if (player === null) {
      return;
    }
    const playback = this.playback;
    if (playback === CYLRefreshIconPlayback.Scrub) {
      player.progress = Math.min(1, Math.max(0, this.percent));
    } else if (playback !== this.applied || view !== this.appliedView) {
      if (playback === CYLRefreshIconPlayback.Play) {
        player.setAnimationRepeatCount(this.loopsValue ? 0 : 1);
        if (player.supportsAnimationSpeed) {
          player.animationSpeed = this.speedValue;
        }
        player.play();
      } else {
        player.stop();
      }
    }
    this.applied = playback;
    this.appliedView = view;
  }

  /** Sets (or with null removes) the animation of a state (`-setAnimationAttributes:forState:`). */
  setAnimationAttributes(attributes: CYLRefreshIconAttributes | null, state: CYLRefreshState): void {
    if (attributes === null) {
      this.attributes.delete(state);
    } else {
      this.attributes.set(state, attributes);
    }
    const kept = Array.from(this.attributes.values());
    Array.from(this.views.keys()).forEach((a: CYLRefreshIconAttributes) => {
      if (!kept.includes(a)) {
        this.views.delete(a);
      }
    });
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

  /** Shows the animation of `state` (the Idle one when it has none); plays it by the policy (`-updateForState:`). */
  updateForState(state: CYLRefreshState): void {
    const own = this.attributes.get(state);
    const idle = this.attributes.get(CYLRefreshState.Idle);
    this.current = own !== undefined ? own : (idle !== undefined ? idle : null);
    this.playing = state === CYLRefreshState.Refreshing || state === CYLRefreshState.WillRefresh ||
      !this.scrubsWhilePulling;
    this.state = state;
    this.applyPlayback();
  }

  /** Moves the frames, or seeks the animation, with the pull (`-updateForPullingPercent:`). */
  updateForPullingPercent(pullingPercent: number): void {
    this.percent = pullingPercent;
    this.applyPlayback();
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
