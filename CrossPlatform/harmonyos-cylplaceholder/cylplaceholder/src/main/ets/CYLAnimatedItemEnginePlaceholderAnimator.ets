// The bridge from CYLPlaceholderView's animators to CYLTabBarController's animated-item engines (cylanimateditem: GIF and
// SVGA; cylanimateditem_lottie, cylanimateditem_pag, cylanimateditemrive: Lottie, PAG and Rive). The engines play the
// files and carry every playback fix in one place, shared by every app that shows CYLAnimatedItemView; this animator only
// hosts the engine view an app registered (`CYLAnimatedItemLottie.register()`, ...) inside the placeholder's animation slot
// and maps the placeholder's player (play, last frame, stop, progress, speed, repeat counts, the end of the last pass,
// colors) onto the engine's player. The core still depends on no animation library: the app adds the engine modules.
//
//   CYLAnimatedItemLottie.register();                                     // the engine (the app's module)
//   CYLAnimatedItemEnginePlaceholderAnimator.registerForType('Lottie');   // its placeholder animator
import {
  CYLAnimatedItemEngineState, CYLAnimatedItemEngineViews, CYLAnimatedItemEngines, CYLAnimatedItemPlayer,
  CYLAnimatedItemSource
} from 'cylanimateditem';
import {
  CYLPlaceholderAnimationColors, CYLPlaceholderAnimationContentView, CYLPlaceholderAnimationExtensionOfURL,
  CYLPlaceholderAnimationOptionsOfURL, CYLPlaceholderItemAnimationBasePlayer, CYLPlaceholderItemAnimationPlayer,
  CYLPlaceholderItemAnimator, CYLPlaceholderItemAnimatorPriority, CYLPlaceholderItemAnimatorPriorityDefault,
  CYLPlaceholderItemAnimatorPriorityFallback, CYLPlaceholderItemAnimatorRegistering, CYLPlaceholderItemAnimatorRegistry,
  CYLPlaceholderPlayableContentView
} from './CYLPlaceholderAnimation';
import {
  CYLPlaceholderItemAnimationDarkColors, CYLPlaceholderItemAnimationDarkFilePath, CYLPlaceholderItemAnimationDarkURL,
  CYLPlaceholderItemAnimationFilePath, CYLPlaceholderItemAnimationSize, CYLPlaceholderItemAnimationURL,
  CYLPlaceholderItemGIFDarkFilePath, CYLPlaceholderItemGIFDarkURL, CYLPlaceholderItemGIFFilePath, CYLPlaceholderItemGIFSize,
  CYLPlaceholderItemGIFURL, CYLPlaceholderItemLottieDarkColors, CYLPlaceholderItemLottieDarkFilePath,
  CYLPlaceholderItemLottieDarkURL, CYLPlaceholderItemLottieFilePath, CYLPlaceholderItemLottieSize,
  CYLPlaceholderItemLottieURL, CYLPlaceholderItemPAGDarkFilePath, CYLPlaceholderItemPAGDarkURL,
  CYLPlaceholderItemPAGFilePath, CYLPlaceholderItemPAGSize, CYLPlaceholderItemPAGURL, CYLPlaceholderItemRiveDarkColors,
  CYLPlaceholderItemRiveDarkFilePath, CYLPlaceholderItemRiveDarkURL, CYLPlaceholderItemRiveFilePath,
  CYLPlaceholderItemRiveSize, CYLPlaceholderItemRiveURL
} from './CYLPlaceholderViewTypes';
import { CYLPlaceholderDrawingColor } from './CYLPlaceholderView';

/** "#AARRGGBB" of a color, or null when it cannot be read. */
function cylEngineHexColor(color: ResourceColor): string | null {
  const drawing = CYLPlaceholderDrawingColor(color);
  if (drawing === null) {
    return null;
  }
  const byte = (value: number): string => {
    const text = Math.max(0, Math.min(255, Math.round(value))).toString(16);
    return text.length < 2 ? '0' + text : text;
  };
  return '#' + byte(drawing.alpha) + byte(drawing.red) + byte(drawing.green) + byte(drawing.blue);
}

/**
 * The animation view of an engine file: holds the engine's state (the engine view reads it) and, once the engine view has
 * loaded the file, its player. The host drives the player (`drivesPlayback` false).
 */
@Observed
export class CYLAnimatedItemEngineContentView extends CYLPlaceholderPlayableContentView {
  readonly engineType: string;
  readonly engineState: CYLAnimatedItemEngineState = new CYLAnimatedItemEngineState();
  readonly engineView: WrappedBuilder<[CYLAnimatedItemEngineState]> | null;
  enginePlayer: CYLAnimatedItemPlayer | undefined = undefined;
  /** Passes played since the last play (repeat counts above 1 replay on each end). */
  private passes: number = 0;
  private playing: boolean = false;
  private engineColors: Map<string, string> | undefined = undefined;

  constructor(type: string, fileURL: string, contentMode: ImageFit, width: number, height: number) {
    super();
    this.engineType = type;
    this.fileURL = fileURL;
    this.options = CYLPlaceholderAnimationOptionsOfURL(fileURL);
    this.contentMode = contentMode;
    this.width = width;
    this.height = height;
    this.engineView = CYLAnimatedItemEngineViews.viewFor(type) ?? null;
    this.builder = wrapBuilder(cylEngineContentBuilder);
    const state = this.engineState;
    state.source = CYLAnimatedItemSource.parse(fileURL);
    state.width = width;
    state.height = height;
    state.drivesPlayback = false;
    state.onPlayer = (player: CYLAnimatedItemPlayer | undefined) => this.cylAdopt(player);
    state.onLoaded = () => {
      // A reload (colors restored) loads again: only the first load is the view's.
      if (!this.cyl_isAnimationViewReady) {
        this.didLoad();
      }
    };
    state.onFailed = () => this.didFail(type, null);
    state.onEnded = () => this.cylPassEnded();
  }

  /** The engine's new player: the speed, loop and colors carry over; a reload while playing plays on. */
  private cylAdopt(player: CYLAnimatedItemPlayer | undefined): void {
    const replaced = this.enginePlayer !== undefined;
    this.enginePlayer = player;
    if (player === undefined) {
      return;
    }
    player.speed = this.playbackSpeed;
    player.loops = this.repeatCount === 0;
    if (this.engineColors !== undefined) {
      player.applyColors(this.engineColors);
    }
    if (replaced && this.playing) {
      player.play();
    }
  }

  private cylPassEnded(): void {
    this.passes += 1;
    const player = this.enginePlayer;
    if (player !== undefined && this.repeatCount > 1 && this.passes < this.repeatCount) {
      player.play();
      return;
    }
    this.playing = false;
    this.didEnd();
  }

  get cyl_supportsAnimationViewSpeed(): boolean {
    return this.enginePlayer !== undefined ? this.enginePlayer.supportsSpeed : this.engineType !== 'Rive';
  }

  cyl_setAnimationViewSpeed(speed: number): boolean {
    if (!(speed > 0) || !this.cyl_supportsAnimationViewSpeed) {
      return false;
    }
    this.playbackSpeed = speed;
    if (this.enginePlayer !== undefined) {
      this.enginePlayer.speed = speed;
    }
    return true;
  }

  cyl_playAnimationView(): void {
    const player = this.enginePlayer;
    if (player === undefined || !this.cyl_isAnimationViewReady) {
      this.pendingCommand = 1;
      return;
    }
    this.passes = 0;
    this.playing = true;
    player.loops = this.repeatCount === 0;
    player.play();
  }

  cyl_showAnimationViewLastFrame(): void {
    const player = this.enginePlayer;
    if (player === undefined || !this.cyl_isAnimationViewReady) {
      this.pendingCommand = 2;
      return;
    }
    this.playing = false;
    player.stopAtProgress(1);
  }

  cyl_stopAnimationView(): void {
    this.pendingCommand = 0;
    this.playing = false;
    this.enginePlayer?.stopAtProgress(0);
  }

  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    if (!(repeatCount >= 0)) {
      return false;
    }
    this.repeatCount = Math.floor(repeatCount);
    if (this.enginePlayer !== undefined) {
      this.enginePlayer.loops = this.repeatCount === 0;
    }
    return true;
  }

  /** Lottie: the first color paints every layer; Rive: view model color properties. null restores the file's colors. */
  cyl_applyAnimationViewColors(colors: CYLPlaceholderAnimationColors | null): void {
    let map: Map<string, string> | undefined = undefined;
    if (colors !== null) {
      map = new Map<string, string>();
      const target = map;
      Object.keys(colors).forEach((key: string) => {
        const hex = cylEngineHexColor(colors[key]);
        if (hex !== null) {
          target.set(key, hex);
        }
      });
      if (target.size === 0) {
        map = undefined;
      }
    }
    this.engineColors = map;
    this.enginePlayer?.applyColors(map);
  }

  get progress(): number {
    return this.enginePlayer?.progress ?? 0;
  }

  setProgress(progress: number): void {
    this.playing = false;
    this.enginePlayer?.stopAtProgress(Math.min(1, Math.max(0, progress)));
  }
}

/** Hosts the engine view registered for the file's type. */
@Component
struct CYLAnimatedItemEngineContent {
  @ObjectLink view: CYLAnimatedItemEngineContentView;

  build() {
    Stack() {
      if (this.view.engineView !== null) {
        this.view.engineView.builder(this.view.engineState)
      }
    }
    .width(this.view.width)
    .height(this.view.height)
    .hitTestBehavior(HitTestMode.Transparent)
  }
}

@Builder
function cylEngineContentBuilder(view: CYLPlaceholderAnimationContentView) {
  CYLAnimatedItemEngineContent({ view: view as CYLAnimatedItemEngineContentView })
}

/** The placeholder player of an engine file: forwards to its content view. */
class CYLAnimatedItemEnginePlaceholderPlayer extends CYLPlaceholderItemAnimationBasePlayer {
  private view: CYLAnimatedItemEngineContentView;

  constructor(view: CYLAnimatedItemEngineContentView) {
    super(view);
    this.view = view;
  }

  play(): void {
    this.view.cyl_playAnimationView();
  }

  showLastFrame(): void {
    this.view.cyl_showAnimationViewLastFrame();
  }

  stop(): void {
    this.view.cyl_stopAnimationView();
  }

  get progress(): number {
    return this.view.progress;
  }

  set progress(value: number) {
    this.view.setProgress(value);
  }

  get supportsProgress(): boolean {
    return this.view.enginePlayer !== undefined && this.view.enginePlayer.supportsProgress;
  }

  get animationSpeed(): number {
    return this.view.playbackSpeed;
  }

  set animationSpeed(value: number) {
    this.view.cyl_setAnimationViewSpeed(value);
  }

  get supportsAnimationSpeed(): boolean {
    return this.view.cyl_supportsAnimationViewSpeed;
  }

  setAnimationRepeatCount(repeatCount: number): boolean {
    return this.view.cyl_setAnimationViewRepeatCount(repeatCount);
  }

  applyColors(colors: CYLPlaceholderAnimationColors | null, dark: boolean): void {
    this.view.cyl_applyAnimationViewColors(colors);
  }
}

/** The attribute keys of a known type (the iOS key names, CYLTabBarController's), or the generic ones. */
function cylEngineAttributeKeys(type: string): Record<string, string> {
  const keys: Record<string, string> = {};
  const set = (url: string, path: string, size: string, darkURL: string, darkPath: string, darkColors: string | null) => {
    keys[CYLPlaceholderItemAnimationURL] = url;
    keys[CYLPlaceholderItemAnimationFilePath] = path;
    keys[CYLPlaceholderItemAnimationSize] = size;
    keys[CYLPlaceholderItemAnimationDarkURL] = darkURL;
    keys[CYLPlaceholderItemAnimationDarkFilePath] = darkPath;
    if (darkColors !== null) {
      keys[CYLPlaceholderItemAnimationDarkColors] = darkColors;
    }
  };
  if (type === 'Lottie') {
    set(CYLPlaceholderItemLottieURL, CYLPlaceholderItemLottieFilePath, CYLPlaceholderItemLottieSize,
      CYLPlaceholderItemLottieDarkURL, CYLPlaceholderItemLottieDarkFilePath, CYLPlaceholderItemLottieDarkColors);
  } else if (type === 'PAG') {
    set(CYLPlaceholderItemPAGURL, CYLPlaceholderItemPAGFilePath, CYLPlaceholderItemPAGSize, CYLPlaceholderItemPAGDarkURL,
      CYLPlaceholderItemPAGDarkFilePath, null);
  } else if (type === 'Rive') {
    set(CYLPlaceholderItemRiveURL, CYLPlaceholderItemRiveFilePath, CYLPlaceholderItemRiveSize,
      CYLPlaceholderItemRiveDarkURL, CYLPlaceholderItemRiveDarkFilePath, CYLPlaceholderItemRiveDarkColors);
  } else if (type === 'GIF') {
    set(CYLPlaceholderItemGIFURL, CYLPlaceholderItemGIFFilePath, CYLPlaceholderItemGIFSize, CYLPlaceholderItemGIFDarkURL,
      CYLPlaceholderItemGIFDarkFilePath, null);
  } else {
    set(CYLPlaceholderItemAnimationURL, CYLPlaceholderItemAnimationFilePath, CYLPlaceholderItemAnimationSize,
      CYLPlaceholderItemAnimationDarkURL, CYLPlaceholderItemAnimationDarkFilePath, null);
  }
  return keys;
}

/** The file extensions of a known type. */
function cylEngineExtensions(type: string): string[] {
  switch (type) {
    case 'Lottie': return ['json', 'lottie'];
    case 'PAG': return ['pag'];
    case 'Rive': return ['riv'];
    case 'SVGA': return ['svga'];
    case 'GIF': return ['gif'];
    default: return [];
  }
}

/**
 * The placeholder animator of an engine type: it matches the type's files while the engine view is registered and its
 * native library runs on the device (Rive and PAG ship arm64-v8a only; elsewhere the item shows its static image).
 */
export class CYLAnimatedItemEnginePlaceholderAnimator implements CYLPlaceholderItemAnimator {
  readonly identifier: string;
  readonly priority: CYLPlaceholderItemAnimatorPriority;
  readonly fileExtensions: string[];
  readonly attributeKeys: Record<string, string>;

  constructor(type: string, fileExtensions?: string[], attributeKeys?: Record<string, string>,
    priority?: CYLPlaceholderItemAnimatorPriority) {
    this.identifier = type;
    this.fileExtensions = fileExtensions ?? cylEngineExtensions(type);
    this.attributeKeys = attributeKeys ?? cylEngineAttributeKeys(type);
    // Lottie also claims ".json": it stays the fallback, as before.
    this.priority = priority ?? (type === 'Lottie' ? CYLPlaceholderItemAnimatorPriorityFallback :
      CYLPlaceholderItemAnimatorPriorityDefault);
  }

  /** Registers the animator of `type` (Lottie, PAG, Rive, SVGA, GIF or an app's type) in `registry` (the shared one). */
  static registerForType(type: string, registry: CYLPlaceholderItemAnimatorRegistering | null = null): void {
    const target = registry !== null ? registry : CYLPlaceholderItemAnimatorRegistry.sharedRegistry();
    target.registerAnimator(new CYLAnimatedItemEnginePlaceholderAnimator(type));
  }

  canAnimateFileAtURL(URL: string): boolean {
    return this.fileExtensions.includes(CYLPlaceholderAnimationExtensionOfURL(URL)) &&
      CYLAnimatedItemEngineViews.hasView(this.identifier) && CYLAnimatedItemEngines.isSupportedOnDevice(this.identifier);
  }

  animationViewWithURL(URL: string, width: number, height: number,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    if (!this.canAnimateFileAtURL(URL)) {
      return null;
    }
    return new CYLAnimatedItemEngineContentView(this.identifier, URL, contentMode, width, height);
  }

  playerForAnimationView(view: CYLPlaceholderAnimationContentView): CYLPlaceholderItemAnimationPlayer | null {
    return view instanceof CYLAnimatedItemEngineContentView ?
      new CYLAnimatedItemEnginePlaceholderPlayer(view as CYLAnimatedItemEngineContentView) : null;
  }
}
