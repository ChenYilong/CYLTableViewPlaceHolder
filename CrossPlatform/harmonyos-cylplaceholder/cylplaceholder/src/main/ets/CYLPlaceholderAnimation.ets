// The HarmonyOS counterpart of iOS CYLPlaceholderAnimation/: the animator registry, the factory of animation views,
// players and CYLPlaceholderAnimationView. Internals follow android/placeholder CYLPlaceholderAnimation.kt.
//
// An iOS UIView is a CYLPlaceholderAnimationContentView here: an @Observed object that carries the WrappedBuilder
// drawing it, so any engine (and any app animator) can be drawn by CYLPlaceholderAnimationContent. Engines load when
// the content appears (rawfile or sandbox bytes), so readiness is asynchronous on every engine; until then the
// placeholder keeps its static icon, as iOS does while Rive loads.
//
// A file URL is a rawfile path ("cylplaceholder/animations/CYLPlaceholderEmpty.json"), a sandbox path ("/data/...")
// or a "file://" URI; options travel in the fragment ("CYLPlaceholderLoading.riv#artboard=Main&duration=1").
//
// The core depends on no animation library: an app registers its engines (CYLPlaceholderItemAnimatorRegistry for the
// player, CYLAnimatedItemEngines of CYLTabBarController's cylanimateditem for the type), and CYLPlaceholderView shows
// the result through CYLAnimatedItemView, which plays the animation only for a registered type.
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { CYLAnimatedItemEngines, cylAnimatedItemTypeOf } from 'cylanimateditem';

/** Lookup order of animators: higher first; equal priorities keep their registration order. */
export type CYLPlaceholderItemAnimatorPriority = number;
/** An animator that recognizes its own files (the default). */
export const CYLPlaceholderItemAnimatorPriorityDefault: CYLPlaceholderItemAnimatorPriority = 0;
/** Looked up after every other animator (Lottie). */
export const CYLPlaceholderItemAnimatorPriorityFallback: CYLPlaceholderItemAnimatorPriority = -1000;

/** Rive option names, carried in the file URL's fragment (iOS `CYLPlaceholderAnimationOption`). */
export type CYLPlaceholderAnimationOption = string;
export const CYLPlaceholderAnimationOptionRiveArtboard: CYLPlaceholderAnimationOption = 'artboard';
export const CYLPlaceholderAnimationOptionRiveStateMachine: CYLPlaceholderAnimationOption = 'stateMachine';
export const CYLPlaceholderAnimationOptionRiveActiveProperty: CYLPlaceholderAnimationOption = 'active';
export const CYLPlaceholderAnimationOptionRiveActiveDuration: CYLPlaceholderAnimationOption = 'duration';
export const CYLPlaceholderAnimationOptionRiveTriggerProperty: CYLPlaceholderAnimationOption = 'trigger';
export const CYLPlaceholderAnimationOptionRiveColor: CYLPlaceholderAnimationOption = 'color';
export const CYLPlaceholderAnimationOptionRiveInput: CYLPlaceholderAnimationOption = 'input';
export const CYLPlaceholderAnimationOptionRiveTriggerInput: CYLPlaceholderAnimationOption = 'triggerInput';
export const CYLPlaceholderAnimationOptionRiveAnimation: CYLPlaceholderAnimationOption = 'animation';
export const CYLPlaceholderAnimationOptionRiveLegacyRuntime: CYLPlaceholderAnimationOption = 'legacy';
/** A state machine number input set to the next of `values` on each play (house.riv: "Rooms"). */
export const CYLPlaceholderAnimationOptionRiveNumberInput: CYLPlaceholderAnimationOption = 'numberInput';
/** The values `numberInput` steps through, "3,4,5,6", cycling; without it, +1. */
export const CYLPlaceholderAnimationOptionRiveNumberValues: CYLPlaceholderAnimationOption = 'values';

/** The error domain of animation errors (iOS `CYLPlaceholderAnimationErrorDomain`). */
export const CYLPlaceholderAnimationErrorDomain: string = 'CYLPlaceholderAnimationErrorDomain';

/** iOS `CYLPlaceholderAnimationErrorCode`. */
export enum CYLPlaceholderAnimationErrorCode {
  InvalidURL = 1,
  InvalidSize = 2,
  UnsupportedFormat = 3,
  BackendUnavailable = 4,
  AssetLoadFailed = 5,
  InvalidOptions = 6
}

/** An NSError of CYLPlaceholderAnimationErrorDomain. */
export class CYLPlaceholderAnimationError extends Error {
  readonly domain: string = CYLPlaceholderAnimationErrorDomain;
  readonly code: CYLPlaceholderAnimationErrorCode;

  constructor(code: CYLPlaceholderAnimationErrorCode, message: string) {
    super(message);
    this.code = code;
  }
}

/** Reports failures that occur after creation (iOS `CYLPlaceholderAnimationErrorHandler`). */
export type CYLPlaceholderAnimationErrorHandler = (error: CYLPlaceholderAnimationError) => void;

/** Colors by key path (Lottie) or property path (Rive); ResourceColor values, "#RRGGBB" strings or 0xAARRGGBB. */
export type CYLPlaceholderAnimationColors = Record<string, ResourceColor>;

/**
 * The view an engine makes (the iOS UIView). Subclasses are @Observed and set `builder`, the global @Builder that
 * draws them; CYLPlaceholderAnimationContent calls it and `cyl_attach` once the view is on screen.
 */
@Observed
export class CYLPlaceholderAnimationContentView {
  /** The frame size, in vp. */
  width: number = 0;
  height: number = 0;
  /** How the animation fits its frame (UIViewContentMode). */
  contentMode: ImageFit = ImageFit.Contain;
  /** Draws the view; null draws nothing. */
  builder: WrappedBuilder<[CYLPlaceholderAnimationContentView]> | null = null;
  /** The identifier of the animator that made the view, set by CYLPlaceholderItemAnimationFactory. */
  cyl_animatorIdentifier: string | null = null;
  /** The player CYLPlaceholderItemAnimationFactory attached to the view. */
  cyl_player: CYLPlaceholderItemAnimationPlayer | null = null;

  /** The view as a self-playing view (CYLPlaceholderItemAnimationPlayableView), or null. */
  playableView(): CYLPlaceholderItemAnimationPlayableView | null {
    return null;
  }

  /** Called when the view appears, with the host's context: engines load their file here. */
  cyl_attach(context: Context | null): void {
  }

  /** Called when the view disappears: engines release their renderer here. */
  cyl_detach(): void {
  }
}

/** Draws a CYLPlaceholderAnimationContentView at its size. */
@Component
export struct CYLPlaceholderAnimationContent {
  @ObjectLink view: CYLPlaceholderAnimationContentView;

  aboutToAppear(): void {
    const host: Context | undefined = this.getUIContext().getHostContext();
    this.view.cyl_attach(host !== undefined ? host : null);
  }

  aboutToDisappear(): void {
    this.view.cyl_detach();
  }

  build() {
    Stack() {
      if (this.view.builder !== null) {
        (this.view.builder as WrappedBuilder<[CYLPlaceholderAnimationContentView]>).builder(this.view)
      }
    }
    .width(this.view.width)
    .height(this.view.height)
    .hitTestBehavior(HitTestMode.Transparent)
    .accessibilityLevel('no-hide-descendants')
  }
}

/**
 * A view that plays itself (iOS `CYLPlaceholderItemAnimationPlayableView`): the short path for adding an engine
 * through CYLPlaceholderItemViewAnimator.
 */
export interface CYLPlaceholderItemAnimationPlayableView {
  /** Plays once, from the start. */
  cyl_playAnimationView(): void;
  /** Shows the end state without playing. */
  cyl_showAnimationViewLastFrame(): void;
  /** Stops, back to the start. */
  cyl_stopAnimationView(): void;
  /** Colors by path; null restores the animation's own colors. */
  cyl_applyAnimationViewColors(colors: CYLPlaceholderAnimationColors | null): void;
  /** How many times cyl_playAnimationView plays: 0 loops until stopped, 1 plays once; false when unsupported. */
  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean;
  /** false while the file is loading. */
  readonly cyl_isAnimationViewReady: boolean;
  /** Called on the main thread when the load finishes. */
  cyl_animationViewReadyHandler: (() => void) | null;
  /** Called on the main thread when the load fails, so the host can fall back. */
  cyl_animationViewErrorHandler: CYLPlaceholderAnimationErrorHandler | null;
}

/** Makes playable views (iOS `CYLPlaceholderItemAnimationViewProviding`). */
export interface CYLPlaceholderItemAnimationViewProviding {
  /** A view for the file with the URL's options, scaled like contentMode; null when it cannot be made. */
  cyl_animationViewWithFileURL(fileURL: string, options: Record<string, string>,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null;
}

/** Plays one animation view (iOS `CYLPlaceholderItemAnimationPlayer`). */
export interface CYLPlaceholderItemAnimationPlayer {
  readonly animationView: CYLPlaceholderAnimationContentView | null;
  /** Plays from the first frame. */
  play(): void;
  /** Stops and shows the last frame (state-machine engines show their resting state). */
  showLastFrame(): void;
  /** Stops and shows the first frame. */
  stop(): void;
  /** 0...1; meaningful when supportsProgress. */
  progress: number;
  /** 1 is normal; meaningful when supportsAnimationSpeed. */
  animationSpeed: number;
  /** Whether `progress` seeks (the iOS optional property is implemented). */
  readonly supportsProgress: boolean;
  /** Whether `animationSpeed` changes the speed. */
  readonly supportsAnimationSpeed: boolean;
  /** How many times play plays: 0 loops until stopped, 1 plays once; false when unsupported. */
  setAnimationRepeatCount(repeatCount: number): boolean;
  /** Applies dark-only colors in dark mode and restores them in light mode (a dark flag for the trait collection). */
  applyDarkColors(darkColors: CYLPlaceholderAnimationColors, dark: boolean): void;
  /** Replaces every color override; null or empty restores the animation's own colors. */
  applyColors(colors: CYLPlaceholderAnimationColors | null, dark: boolean): void;
}

/** Holds the animation view weakly; players subclass it (iOS `CYLPlaceholderItemAnimationBasePlayer`). */
export class CYLPlaceholderItemAnimationBasePlayer implements CYLPlaceholderItemAnimationPlayer {
  private viewReference: WeakRef<CYLPlaceholderAnimationContentView>;
  private darkApplied: boolean | null = null;

  constructor(animationView: CYLPlaceholderAnimationContentView) {
    this.viewReference = new WeakRef<CYLPlaceholderAnimationContentView>(animationView);
  }

  /** iOS `-initWithAnimationView:`. */
  static initWithAnimationView(animationView: CYLPlaceholderAnimationContentView): CYLPlaceholderItemAnimationBasePlayer {
    return new CYLPlaceholderItemAnimationBasePlayer(animationView);
  }

  get animationView(): CYLPlaceholderAnimationContentView | null {
    const view = this.viewReference.deref();
    return view !== undefined ? view : null;
  }

  play(): void {
  }

  showLastFrame(): void {
  }

  stop(): void {
  }

  get progress(): number {
    return 0;
  }

  set progress(value: number) {
  }

  get animationSpeed(): number {
    return 1;
  }

  set animationSpeed(value: number) {
  }

  get supportsProgress(): boolean {
    return false;
  }

  get supportsAnimationSpeed(): boolean {
    return false;
  }

  setAnimationRepeatCount(repeatCount: number): boolean {
    return false;
  }

  applyDarkColors(darkColors: CYLPlaceholderAnimationColors, dark: boolean): void {
    // Only when the mode changes, as iOS applies CYLTabBarAnimationDarkColors.
    if (this.darkApplied === dark) {
      return;
    }
    this.darkApplied = dark;
    this.applyColors(dark ? darkColors : null, dark);
  }

  applyColors(colors: CYLPlaceholderAnimationColors | null, dark: boolean): void {
  }
}

/** Which files an animation library plays, and how it is looked up (iOS `CYLPlaceholderItemAnimationFileMatching`). */
export interface CYLPlaceholderItemAnimationFileMatching {
  /** Unique; registering the same identifier again replaces the animator. */
  readonly identifier: string;
  canAnimateFileAtURL(URL: string): boolean;
  readonly priority: CYLPlaceholderItemAnimatorPriority;
  /** Lowercase extensions without a dot. */
  readonly fileExtensions: string[];
  /** Generic item key (CYLPlaceholderItemAnimationFilePath) -> this library's key (CYLPlaceholderItemLottieFilePath). */
  readonly attributeKeys: Record<string, string>;
}

/** The views an animation library makes, and a player for each (iOS `CYLPlaceholderItemAnimationViewFactory`). */
export interface CYLPlaceholderItemAnimationViewFactory {
  /** null when the file cannot be played. The URL fragment may carry options. width/height in vp. */
  animationViewWithURL(URL: string, width: number, height: number,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null;
  /** null for a view this library did not make. */
  playerForAnimationView(view: CYLPlaceholderAnimationContentView): CYLPlaceholderItemAnimationPlayer | null;
}

/** An animation library (iOS `CYLPlaceholderItemAnimator`); register it with CYLPlaceholderItemAnimatorRegistry. */
export interface CYLPlaceholderItemAnimator extends CYLPlaceholderItemAnimationFileMatching,
  CYLPlaceholderItemAnimationViewFactory {
}

// URL helpers (internal, exported for the engines and tests).

/** The URL without its fragment and query: the animation file itself. */
export function CYLPlaceholderAnimationFileOfURL(URL: string): string {
  let file = URL;
  const hash = file.indexOf('#');
  if (hash >= 0) {
    file = file.substring(0, hash);
  }
  const query = file.indexOf('?');
  if (query >= 0) {
    file = file.substring(0, query);
  }
  return file;
}

/** The lowercase extension of the URL's file, without the dot; "" when it has none. */
export function CYLPlaceholderAnimationExtensionOfURL(URL: string): string {
  const file = CYLPlaceholderAnimationFileOfURL(URL);
  const slash = file.lastIndexOf('/');
  const dot = file.lastIndexOf('.');
  return dot > slash && dot >= 0 ? file.substring(dot + 1).toLowerCase() : '';
}

/** The options in the URL's fragment ("name=value&...", percent-encoded). */
export function CYLPlaceholderAnimationOptionsOfURL(URL: string): Record<string, string> {
  const options: Record<string, string> = {};
  const hash = URL.indexOf('#');
  if (hash < 0) {
    return options;
  }
  URL.substring(hash + 1).split('&').forEach((item: string) => {
    const equals = item.indexOf('=');
    if (equals <= 0) {
      return;
    }
    try {
      options[decodeURIComponent(item.substring(0, equals))] = decodeURIComponent(item.substring(equals + 1));
    } catch (e) {
      // A malformed escape is skipped.
    }
  });
  return options;
}

/** The URL with options written into its fragment, sorted by name (iOS `CYLPlaceholderAnimationURLWithOptions`). */
export function CYLPlaceholderAnimationURLWithOptions(URL: string, options: Record<string, string>): string {
  const names = Object.keys(options).sort();
  if (names.length === 0) {
    return URL;
  }
  const items: string[] = names.map((name: string) => encodeURIComponent(name) + '=' + encodeURIComponent(options[name]));
  return CYLPlaceholderAnimationFileOfURL(URL) + '#' + items.join('&');
}

/** Whether the URL names a sandbox file (an absolute path or "file://") rather than a rawfile path. */
export function CYLPlaceholderAnimationIsSandboxURL(URL: string): boolean {
  return URL.startsWith('/') || URL.startsWith('file://');
}

/**
 * Whether the URL's file exists and is readable, checked synchronously (iOS `Data(contentsOf:)` succeeding): a sandbox
 * file, or a rawfile through the context's resource manager. False for an empty URL or without a context.
 */
export function CYLPlaceholderAnimationFileExists(URL: string, context: Context | null = null): boolean {
  const file = CYLPlaceholderAnimationFileOfURL(URL);
  if (file.length === 0) {
    return false;
  }
  try {
    if (CYLPlaceholderAnimationIsSandboxURL(file)) {
      const path = file.startsWith('file://') ? file.substring('file://'.length) : file;
      return fileIo.accessSync(path) && fileIo.statSync(path).isFile();
    }
    const host: Context | null = context !== null ? context : CYLPlaceholderAnimationDefaultContext();
    if (host === null || host === undefined) {
      return false;
    }
    host.resourceManager.getRawFdSync(file);
    host.resourceManager.closeRawFdSync(file);
    return true;
  } catch (e) {
    return false;
  }
}

/** Reads the URL's file synchronously (iOS `Data(contentsOf:)`); null when it cannot be read. */
export function CYLPlaceholderAnimationReadFileSync(URL: string, context: Context | null = null): Uint8Array | null {
  const file = CYLPlaceholderAnimationFileOfURL(URL);
  if (file.length === 0) {
    return null;
  }
  try {
    if (CYLPlaceholderAnimationIsSandboxURL(file)) {
      const path = file.startsWith('file://') ? file.substring('file://'.length) : file;
      const handle = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
      try {
        const size = fileIo.statSync(handle.fd).size;
        const buffer = new ArrayBuffer(size);
        fileIo.readSync(handle.fd, buffer);
        return new Uint8Array(buffer);
      } finally {
        fileIo.closeSync(handle);
      }
    }
    const host: Context | null = context !== null ? context : CYLPlaceholderAnimationDefaultContext();
    if (host === null || host === undefined) {
      return null;
    }
    return host.resourceManager.getRawFileContentSync(file);
  } catch (e) {
    return null;
  }
}

let defaultContext: Context | null = null;

/**
 * The context rawfiles are read with when a caller passes none (HarmonyOS addition replacing the deprecated global
 * getContext): the app sets it once (EntryAbility), and every context passed to a read is remembered too.
 */
export function CYLPlaceholderAnimationSetDefaultContext(context: Context | null): void {
  defaultContext = context;
}

/** The context set by CYLPlaceholderAnimationSetDefaultContext (or the last one passed to a read), or null. */
export function CYLPlaceholderAnimationDefaultContext(): Context | null {
  return defaultContext;
}

/** Reads the URL's file: a sandbox file, or a rawfile through the context's resource manager. */
export async function CYLPlaceholderAnimationReadFile(URL: string, context: Context | null): Promise<Uint8Array> {
  const file = CYLPlaceholderAnimationFileOfURL(URL);
  if (context !== null && defaultContext === null) {
    defaultContext = context;
  }
  if (CYLPlaceholderAnimationIsSandboxURL(file)) {
    const path = file.startsWith('file://') ? file.substring('file://'.length) : file;
    try {
      const handle = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
      try {
        const size = fileIo.statSync(handle.fd).size;
        const buffer = new ArrayBuffer(size);
        fileIo.readSync(handle.fd, buffer);
        return new Uint8Array(buffer);
      } finally {
        fileIo.closeSync(handle);
      }
    } catch (e) {
      throw new CYLPlaceholderAnimationError(CYLPlaceholderAnimationErrorCode.AssetLoadFailed,
        'Cannot read ' + file + ': ' + (e as Error).message);
    }
  }
  const host: Context | null = context !== null ? context : defaultContext;
  if (host === null || host === undefined) {
    throw new CYLPlaceholderAnimationError(CYLPlaceholderAnimationErrorCode.AssetLoadFailed, 'No context to read ' + file);
  }
  try {
    return await host.resourceManager.getRawFileContent(file);
  } catch (e) {
    throw new CYLPlaceholderAnimationError(CYLPlaceholderAnimationErrorCode.AssetLoadFailed,
      'Cannot read ' + file + ': ' + (e as Error).message);
  }
}

/** The bytes as an ArrayBuffer of their own. */
export function CYLPlaceholderAnimationArrayBuffer(bytes: Uint8Array): ArrayBuffer {
  return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
}

/** The error of a failed load. */
export function CYLPlaceholderAnimationLoadError(identifier: string, URL: string, reason: Object | null): CYLPlaceholderAnimationError {
  const file = CYLPlaceholderAnimationFileOfURL(URL);
  const name = file.substring(file.lastIndexOf('/') + 1);
  let detail = '';
  if (reason !== null && reason !== undefined) {
    detail = ': ' + (reason instanceof Error ? (reason as Error).message : JSON.stringify(reason));
  }
  return new CYLPlaceholderAnimationError(CYLPlaceholderAnimationErrorCode.AssetLoadFailed,
    'The ' + identifier + ' animator could not load ' + name + detail);
}

/**
 * The common state of the engines' views: readiness, handlers and a play requested before the load finished.
 * Engines subclass it and implement the cyl_ methods.
 */
@Observed
export class CYLPlaceholderPlayableContentView extends CYLPlaceholderAnimationContentView
  implements CYLPlaceholderItemAnimationPlayableView {
  /** The file URL, fragment included. */
  fileURL: string = '';
  options: Record<string, string> = {};
  cyl_isAnimationViewReady: boolean = false;
  /** Set once loading failed. */
  failed: boolean = false;
  cyl_animationViewReadyHandler: (() => void) | null = null;
  cyl_animationViewErrorHandler: CYLPlaceholderAnimationErrorHandler | null = null;
  /** 0 loops, N plays N times. */
  repeatCount: number = 1;
  /** The playback rate, 1 is normal (HarmonyOS addition: iOS sets speed on the engine view itself). */
  playbackSpeed: number = 1;
  /** Requested before the load finished: 1 play, 2 last frame, 0 nothing. */
  pendingCommand: number = 0;
  protected loading: boolean = false;

  /** Whether cyl_setAnimationViewSpeed changes the speed; subclasses that can return true. */
  get cyl_supportsAnimationViewSpeed(): boolean {
    return false;
  }

  /** Sets the playback rate (above 0), live; false when the view cannot change it. */
  cyl_setAnimationViewSpeed(speed: number): boolean {
    return false;
  }

  playableView(): CYLPlaceholderItemAnimationPlayableView | null {
    return this;
  }

  /** Called by subclasses when the animation is ready to play. */
  protected didLoad(): void {
    this.loading = false;
    this.cyl_isAnimationViewReady = true;
    const handler = this.cyl_animationViewReadyHandler;
    if (handler !== null) {
      handler();
    }
    const command = this.pendingCommand;
    this.pendingCommand = 0;
    if (command === 1) {
      this.cyl_playAnimationView();
    } else if (command === 2) {
      this.cyl_showAnimationViewLastFrame();
    }
  }

  /** Called by subclasses when the load failed. */
  protected didFail(identifier: string, reason: Object | null): void {
    this.loading = false;
    this.failed = true;
    const handler = this.cyl_animationViewErrorHandler;
    if (handler !== null) {
      handler(CYLPlaceholderAnimationLoadError(identifier, this.fileURL, reason));
    }
  }

  cyl_playAnimationView(): void {
  }

  cyl_showAnimationViewLastFrame(): void {
  }

  cyl_stopAnimationView(): void {
  }

  cyl_applyAnimationViewColors(colors: CYLPlaceholderAnimationColors | null): void {
  }

  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    return false;
  }
}

/** The player of a playable view: forwards to its cyl_ methods (used by CYLPlaceholderItemViewAnimator). */
class CYLPlaceholderPlayableViewPlayer extends CYLPlaceholderItemAnimationBasePlayer {
  private playable: CYLPlaceholderItemAnimationPlayableView;
  private speedView: CYLPlaceholderPlayableContentView | null;

  constructor(view: CYLPlaceholderAnimationContentView, playable: CYLPlaceholderItemAnimationPlayableView) {
    super(view);
    this.playable = playable;
    this.speedView = view instanceof CYLPlaceholderPlayableContentView ? view as CYLPlaceholderPlayableContentView : null;
  }

  get animationSpeed(): number {
    return this.speedView !== null ? this.speedView.playbackSpeed : 1;
  }

  set animationSpeed(value: number) {
    if (this.speedView !== null) {
      this.speedView.cyl_setAnimationViewSpeed(value);
    }
  }

  get supportsAnimationSpeed(): boolean {
    return this.speedView !== null && this.speedView.cyl_supportsAnimationViewSpeed;
  }

  play(): void {
    this.playable.cyl_playAnimationView();
  }

  showLastFrame(): void {
    this.playable.cyl_showAnimationViewLastFrame();
  }

  stop(): void {
    this.playable.cyl_stopAnimationView();
  }

  setAnimationRepeatCount(repeatCount: number): boolean {
    return this.playable.cyl_setAnimationViewRepeatCount(repeatCount);
  }

  applyColors(colors: CYLPlaceholderAnimationColors | null, dark: boolean): void {
    this.playable.cyl_applyAnimationViewColors(colors);
  }
}

/**
 * A ready-made animator for libraries whose view plays itself (iOS `CYLPlaceholderItemViewAnimator`): matches files
 * by extension, splits the URL into the file and its options for the view provider, and plays through the view.
 */
export class CYLPlaceholderItemViewAnimator implements CYLPlaceholderItemAnimator {
  readonly identifier: string;
  readonly fileExtensions: string[];
  readonly attributeKeys: Record<string, string>;
  readonly priority: CYLPlaceholderItemAnimatorPriority = CYLPlaceholderItemAnimatorPriorityDefault;
  private defaultViewProvider: CYLPlaceholderItemAnimationViewProviding | null;
  private viewProviderValue: CYLPlaceholderItemAnimationViewProviding | null;

  constructor(identifier: string, fileExtensions: string[], attributeKeys: Record<string, string> | null,
    viewProvider: CYLPlaceholderItemAnimationViewProviding | null) {
    this.identifier = identifier;
    const extensions: string[] = [];
    fileExtensions.forEach((e: string) => {
      const lower = (e.startsWith('.') ? e.substring(1) : e).toLowerCase();
      if (lower.length > 0 && !extensions.includes(lower)) {
        extensions.push(lower);
      }
    });
    this.fileExtensions = extensions;
    this.attributeKeys = attributeKeys !== null ? attributeKeys : {};
    this.defaultViewProvider = viewProvider;
    this.viewProviderValue = viewProvider;
  }

  /** iOS `-initWithIdentifier:fileExtensions:attributeKeys:viewProvider:`. */
  static initWithIdentifier(identifier: string, fileExtensions: string[], attributeKeys: Record<string, string> | null,
    viewProvider: CYLPlaceholderItemAnimationViewProviding | null): CYLPlaceholderItemViewAnimator {
    return new CYLPlaceholderItemViewAnimator(identifier, fileExtensions, attributeKeys, viewProvider);
  }

  /** Where the views come from; null goes back to the provider given at initialization (null_resettable). */
  get viewProvider(): CYLPlaceholderItemAnimationViewProviding | null {
    return this.viewProviderValue;
  }

  set viewProvider(value: CYLPlaceholderItemAnimationViewProviding | null) {
    this.viewProviderValue = value !== null ? value : this.defaultViewProvider;
  }

  canAnimateFileAtURL(URL: string): boolean {
    return this.fileExtensions.includes(CYLPlaceholderAnimationExtensionOfURL(URL));
  }

  animationViewWithURL(URL: string, width: number, height: number,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    const provider = this.viewProviderValue;
    if (provider === null || !this.canAnimateFileAtURL(URL)) {
      return null;
    }
    const view = provider.cyl_animationViewWithFileURL(URL, CYLPlaceholderAnimationOptionsOfURL(URL), contentMode);
    if (view === null || view.playableView() === null) {
      return null;
    }
    view.width = width;
    view.height = height;
    view.contentMode = contentMode;
    return view;
  }

  playerForAnimationView(view: CYLPlaceholderAnimationContentView): CYLPlaceholderItemAnimationPlayer | null {
    const playable = view.playableView();
    return playable !== null ? new CYLPlaceholderPlayableViewPlayer(view, playable) : null;
  }
}

/** The registry interface, so a factory can be given another registry (iOS `CYLPlaceholderItemAnimatorRegistering`). */
export interface CYLPlaceholderItemAnimatorRegistering {
  registerAnimator(animator: CYLPlaceholderItemAnimator): void;
  unregisterAnimatorWithIdentifier(identifier: string): void;
  /** Sorted by priority, then registration order. */
  animators(): CYLPlaceholderItemAnimator[];
  animatorWithIdentifier(identifier: string): CYLPlaceholderItemAnimator | null;
  /** A bound animator first, then the first animator that can animate the URL. */
  animatorForURL(URL: string | null): CYLPlaceholderItemAnimator | null;
  /** The first animator whose library-specific keys have a value. */
  animatorForAttributes(attributes: Record<string, Object> | null): CYLPlaceholderItemAnimator | null;
  attributeKeyForGenericKey(genericKey: string, attributes: Record<string, Object> | null): string | null;
  /** Plays URL with animator whatever its extension; null removes the binding. */
  bindURL(URL: string, animator: CYLPlaceholderItemAnimator | null): void;
  attributeKeysForGenericKey(genericKey: string): string[];
  fileExtensions(): string[];
}

/** The animators of the app (iOS `CYLPlaceholderItemAnimatorRegistry`); the static methods use sharedRegistry. */
export class CYLPlaceholderItemAnimatorRegistry implements CYLPlaceholderItemAnimatorRegistering {
  private static shared: CYLPlaceholderItemAnimatorRegistry | null = null;
  private registered: CYLPlaceholderItemAnimator[] = [];
  private bound: Map<string, string> = new Map<string, string>();

  static sharedRegistry(): CYLPlaceholderItemAnimatorRegistry {
    if (CYLPlaceholderItemAnimatorRegistry.shared === null) {
      CYLPlaceholderItemAnimatorRegistry.shared = new CYLPlaceholderItemAnimatorRegistry();
    }
    return CYLPlaceholderItemAnimatorRegistry.shared as CYLPlaceholderItemAnimatorRegistry;
  }

  registerAnimator(animator: CYLPlaceholderItemAnimator): void {
    if (animator.identifier.length === 0) {
      return;
    }
    if (this === CYLPlaceholderItemAnimatorRegistry.shared) {
      // CYLAnimatedItemView plays only registered types: an animator of the shared registry registers its types.
      animator.fileExtensions.forEach((fileExtension: string) => {
        CYLPlaceholderRegisterAnimatedItemType(fileExtension);
      });
    }
    const index = this.registered.findIndex((a: CYLPlaceholderItemAnimator) => a.identifier === animator.identifier);
    if (index < 0) {
      this.registered.push(animator);
    } else {
      this.registered[index] = animator;
    }
  }

  unregisterAnimatorWithIdentifier(identifier: string): void {
    this.registered = this.registered.filter((a: CYLPlaceholderItemAnimator) => a.identifier !== identifier);
  }

  animators(): CYLPlaceholderItemAnimator[] {
    // Array.prototype.sort is stable: equal priorities keep their registration order.
    return this.registered.slice().sort((a: CYLPlaceholderItemAnimator, b: CYLPlaceholderItemAnimator) =>
      b.priority - a.priority);
  }

  animatorWithIdentifier(identifier: string): CYLPlaceholderItemAnimator | null {
    const found = this.registered.find((a: CYLPlaceholderItemAnimator) => a.identifier === identifier);
    return found !== undefined ? found : null;
  }

  animatorForURL(URL: string | null): CYLPlaceholderItemAnimator | null {
    if (URL === null || URL.length === 0) {
      return null;
    }
    const boundIdentifier = this.bound.get(URL);
    if (boundIdentifier !== undefined) {
      const boundAnimator = this.animatorWithIdentifier(boundIdentifier);
      if (boundAnimator !== null) {
        return boundAnimator;
      }
    }
    const animators = this.animators();
    for (let i = 0; i < animators.length; i++) {
      if (animators[i].canAnimateFileAtURL(URL)) {
        return animators[i];
      }
    }
    return null;
  }

  animatorForAttributes(attributes: Record<string, Object> | null): CYLPlaceholderItemAnimator | null {
    if (attributes === null || Object.keys(attributes).length === 0) {
      return null;
    }
    const animators = this.animators();
    for (let i = 0; i < animators.length; i++) {
      const keys = animators[i].attributeKeys;
      const libraryKeys = Object.keys(keys).map((generic: string) => keys[generic]);
      for (let j = 0; j < libraryKeys.length; j++) {
        const value: Object | undefined = attributes[libraryKeys[j]];
        if (value !== undefined && value !== null) {
          return animators[i];
        }
      }
    }
    return null;
  }

  attributeKeyForGenericKey(genericKey: string, attributes: Record<string, Object> | null): string | null {
    const animator = this.animatorForAttributes(attributes);
    if (genericKey.length === 0 || animator === null) {
      return null;
    }
    const key: string | undefined = animator.attributeKeys[genericKey];
    return key !== undefined && key.length > 0 ? key : null;
  }

  bindURL(URL: string, animator: CYLPlaceholderItemAnimator | null): void {
    if (URL.length === 0) {
      return;
    }
    if (animator === null || animator.identifier.length === 0) {
      this.bound.delete(URL);
    } else {
      this.bound.set(URL, animator.identifier);
    }
  }

  attributeKeysForGenericKey(genericKey: string): string[] {
    const keys: string[] = [];
    this.animators().forEach((animator: CYLPlaceholderItemAnimator) => {
      const key: string | undefined = animator.attributeKeys[genericKey];
      if (key !== undefined && key.length > 0 && !keys.includes(key)) {
        keys.push(key);
      }
    });
    return keys;
  }

  fileExtensions(): string[] {
    const extensions: string[] = [];
    this.animators().forEach((animator: CYLPlaceholderItemAnimator) => {
      animator.fileExtensions.forEach((e: string) => {
        const lower = e.toLowerCase();
        if (lower.length > 0 && !extensions.includes(lower)) {
          extensions.push(lower);
        }
      });
    });
    return extensions;
  }

  // Class methods on the shared registry (iOS +...).

  static registerAnimator(animator: CYLPlaceholderItemAnimator): void {
    CYLPlaceholderItemAnimatorRegistry.sharedRegistry().registerAnimator(animator);
  }

  static unregisterAnimatorWithIdentifier(identifier: string): void {
    CYLPlaceholderItemAnimatorRegistry.sharedRegistry().unregisterAnimatorWithIdentifier(identifier);
  }

  static animators(): CYLPlaceholderItemAnimator[] {
    return CYLPlaceholderItemAnimatorRegistry.sharedRegistry().animators();
  }

  static animatorWithIdentifier(identifier: string): CYLPlaceholderItemAnimator | null {
    return CYLPlaceholderItemAnimatorRegistry.sharedRegistry().animatorWithIdentifier(identifier);
  }

  static animatorForURL(URL: string | null): CYLPlaceholderItemAnimator | null {
    return CYLPlaceholderItemAnimatorRegistry.sharedRegistry().animatorForURL(URL);
  }

  static animatorForAttributes(attributes: Record<string, Object> | null): CYLPlaceholderItemAnimator | null {
    return CYLPlaceholderItemAnimatorRegistry.sharedRegistry().animatorForAttributes(attributes);
  }

  static attributeKeyForGenericKey(genericKey: string, attributes: Record<string, Object> | null): string | null {
    return CYLPlaceholderItemAnimatorRegistry.sharedRegistry().attributeKeyForGenericKey(genericKey, attributes);
  }

  static bindURL(URL: string, animator: CYLPlaceholderItemAnimator | null): void {
    CYLPlaceholderItemAnimatorRegistry.sharedRegistry().bindURL(URL, animator);
  }

  static attributeKeysForGenericKey(genericKey: string): string[] {
    return CYLPlaceholderItemAnimatorRegistry.sharedRegistry().attributeKeysForGenericKey(genericKey);
  }

  static fileExtensions(): string[] {
    return CYLPlaceholderItemAnimatorRegistry.sharedRegistry().fileExtensions();
  }
}

/** What the engine needs to make animation views and find their players (iOS `CYLPlaceholderItemAnimationViewMaking`). */
export interface CYLPlaceholderItemAnimationViewMaking {
  animationViewWithURL(URL: string, width: number, height: number,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null;
  playerForView(view: CYLPlaceholderAnimationContentView | null): CYLPlaceholderItemAnimationPlayer | null;
  isAnimationView(view: CYLPlaceholderAnimationContentView | null): boolean;
}

/**
 * Makes animation views, whatever their library (iOS `CYLPlaceholderItemAnimationFactory`): picks the animator from
 * the registry, asks it for the view, sizes it and attaches its player.
 */
export class CYLPlaceholderItemAnimationFactory implements CYLPlaceholderItemAnimationViewMaking {
  private static shared: CYLPlaceholderItemAnimationFactory | null = null;
  readonly registry: CYLPlaceholderItemAnimatorRegistering;

  /** A factory over registry; without one, over the shared registry (iOS `-init`). */
  constructor(registry: CYLPlaceholderItemAnimatorRegistering | null = null) {
    this.registry = registry !== null ? registry : CYLPlaceholderItemAnimatorRegistry.sharedRegistry();
  }

  /** iOS `-initWithRegistry:`. */
  static initWithRegistry(registry: CYLPlaceholderItemAnimatorRegistering): CYLPlaceholderItemAnimationFactory {
    return new CYLPlaceholderItemAnimationFactory(registry);
  }

  /** iOS `-init`: a factory over the shared registry. */
  static init(): CYLPlaceholderItemAnimationFactory {
    return new CYLPlaceholderItemAnimationFactory(null);
  }

  /** The factory over the shared registry; the static methods forward to it. */
  static sharedFactory(): CYLPlaceholderItemAnimationFactory {
    if (CYLPlaceholderItemAnimationFactory.shared === null) {
      CYLPlaceholderItemAnimationFactory.shared = new CYLPlaceholderItemAnimationFactory(null);
    }
    return CYLPlaceholderItemAnimationFactory.shared as CYLPlaceholderItemAnimationFactory;
  }

  animationViewWithURL(URL: string, width: number, height: number,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    const animator = this.registry.animatorForURL(URL);
    if (animator === null) {
      return null;
    }
    const view = animator.animationViewWithURL(URL, width, height, contentMode);
    if (view === null) {
      return null;
    }
    view.width = width;
    view.height = height;
    view.contentMode = contentMode;
    view.cyl_animatorIdentifier = animator.identifier;
    view.cyl_player = animator.playerForAnimationView(view);
    return view;
  }

  playerForView(view: CYLPlaceholderAnimationContentView | null): CYLPlaceholderItemAnimationPlayer | null {
    if (view === null || view.cyl_animatorIdentifier === null) {
      return null;
    }
    if (view.cyl_player !== null) {
      return view.cyl_player;
    }
    const animator = this.registry.animatorWithIdentifier(view.cyl_animatorIdentifier as string);
    if (animator === null) {
      return null;
    }
    view.cyl_player = animator.playerForAnimationView(view);
    return view.cyl_player;
  }

  isAnimationView(view: CYLPlaceholderAnimationContentView | null): boolean {
    return view !== null && view.cyl_animatorIdentifier !== null;
  }

  static animationViewWithURL(URL: string, width: number, height: number,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    return CYLPlaceholderItemAnimationFactory.sharedFactory().animationViewWithURL(URL, width, height, contentMode);
  }

  static playerForView(view: CYLPlaceholderAnimationContentView | null): CYLPlaceholderItemAnimationPlayer | null {
    return CYLPlaceholderItemAnimationFactory.sharedFactory().playerForView(view);
  }

  static isAnimationView(view: CYLPlaceholderAnimationContentView | null): boolean {
    return CYLPlaceholderItemAnimationFactory.sharedFactory().isAnimationView(view);
  }
}

/** The engine behind an animation view (iOS `CYLPlaceholderAnimationBackend`). */
export enum CYLPlaceholderAnimationBackend {
  Lottie = 0,
  PAG = 1,
  Rive = 2,
  GIF = 3,
  /** An animator registered by the app with CYLPlaceholderItemAnimatorRegistry. */
  Custom = 4
}

/**
 * Plays a placeholder animation (iOS protocol `CYLPlaceholderAnimationPlayer`): what a CYLPlaceholderView drives. A
 * factory registered with `CYLPlaceholderViewModel.registerAnimationFactory` returns one; `view` is what is drawn.
 * Handlers are called on the main thread.
 */
export interface CYLPlaceholderAnimationPlayer {
  /** The view drawn in place of the icon (the iOS player is the view itself). */
  readonly view: CYLPlaceholderAnimationContentView;
  readonly ready: boolean;
  errorHandler: CYLPlaceholderAnimationErrorHandler | null;
  readyHandler: (() => void) | null;
  play(): void;
  stop(): void;
  showLastFrame(): void;
  /** false for invalid values or when unsupported. */
  setAnimationProgress(progress: number): boolean;
  setAnimationSpeed(speed: number): boolean;
  /** 0 loops until stopped; N plays N times; false when unsupported (the animation then plays once). */
  setAnimationRepeatCount(repeatCount: number): boolean;
  /** Replaces all key-path color overrides; false when unsupported. */
  setAnimationColors(colors: CYLPlaceholderAnimationColors): boolean;
}

/**
 * Makes a player for a local animation file (iOS `CYLPlaceholderAnimationFactory`): fileURL, size in vp, content
 * mode and options; null when it cannot.
 */
export type CYLPlaceholderAnimationFactory = (fileURL: string, width: number, height: number, contentMode: ImageFit,
  options: Record<string, Object>) => CYLPlaceholderAnimationPlayer | null;

const KNOWN_ENGINES: Record<string, string> = {
  'json': 'Lottie', 'lottie': 'Lottie', 'pag': 'PAG', 'riv': 'Rive', 'gif': 'GIF'
};

/**
 * The state of iOS `CYLPlaceholderAnimationView`: hosts the view made by the animator the registry picks for a local
 * file and drives it through that view's player. Draw it with the @Component CYLPlaceholderAnimationView.
 */
@Observed
export class CYLPlaceholderAnimationViewModel implements CYLPlaceholderAnimationPlayer {
  readonly animationView: CYLPlaceholderAnimationContentView;
  readonly player: CYLPlaceholderItemAnimationPlayer;
  /** "Lottie", "PAG", "Rive", "GIF", or a custom identifier. */
  readonly animatorIdentifier: string;
  readonly backend: CYLPlaceholderAnimationBackend;
  /** The frame size, in vp. */
  readonly width: number;
  readonly height: number;
  playing: boolean = false;
  private errorHandlerValue: CYLPlaceholderAnimationErrorHandler | null = null;
  private readyHandlerValue: (() => void) | null = null;

  private constructor(animationView: CYLPlaceholderAnimationContentView, player: CYLPlaceholderItemAnimationPlayer,
    animatorIdentifier: string, width: number, height: number) {
    this.animationView = animationView;
    this.player = player;
    this.animatorIdentifier = animatorIdentifier;
    this.width = width;
    this.height = height;
    const backends: Record<string, CYLPlaceholderAnimationBackend> = {
      'Lottie': CYLPlaceholderAnimationBackend.Lottie,
      'PAG': CYLPlaceholderAnimationBackend.PAG,
      'Rive': CYLPlaceholderAnimationBackend.Rive,
      'GIF': CYLPlaceholderAnimationBackend.GIF
    };
    const backend: CYLPlaceholderAnimationBackend | undefined = backends[animatorIdentifier];
    this.backend = backend !== undefined ? backend : CYLPlaceholderAnimationBackend.Custom;
  }

  /** iOS `-initWithFileURL:size:contentMode:error:`. */
  static initWithFileURL(fileURL: string, width: number, height: number, contentMode: ImageFit = ImageFit.Contain,
    onError: CYLPlaceholderAnimationErrorHandler | null = null): CYLPlaceholderAnimationViewModel | null {
    return CYLPlaceholderAnimationViewModel.initWithFileURLOptions(fileURL, width, height, contentMode, {}, onError);
  }

  /**
   * iOS `-initWithFileURL:size:contentMode:options:error:`: null, with the error passed to onError, for an empty URL,
   * a size outside 0...1000 vp, option values that are not strings or numbers, a Rive duration outside 0...60, a file
   * no registered animator plays, or an animator that cannot make the view. Options reach the animator in the URL
   * fragment.
   */
  static initWithFileURLOptions(fileURL: string, width: number, height: number, contentMode: ImageFit,
    options: Record<string, Object>, onError: CYLPlaceholderAnimationErrorHandler | null = null)
    : CYLPlaceholderAnimationViewModel | null {
    const fail = (code: CYLPlaceholderAnimationErrorCode, message: string): CYLPlaceholderAnimationViewModel | null => {
      if (onError !== null) {
        onError(new CYLPlaceholderAnimationError(code, message));
      }
      return null;
    };
    const file = CYLPlaceholderAnimationFileOfURL(fileURL);
    if (file.length === 0 || file === 'file://') {
      return fail(CYLPlaceholderAnimationErrorCode.InvalidURL, 'Animation files must use a local file URL.');
    }
    if (!isFinite(width) || !isFinite(height) || width <= 0 || height <= 0 || width > 1000 || height > 1000) {
      return fail(CYLPlaceholderAnimationErrorCode.InvalidSize,
        'Animation size must be finite, positive, and no larger than 1000 points.');
    }
    const stringOptions: Record<string, string> = {};
    const names = Object.keys(options);
    for (let i = 0; i < names.length; i++) {
      const value: Object = options[names[i]];
      if (typeof value !== 'string' && typeof value !== 'number') {
        return fail(CYLPlaceholderAnimationErrorCode.InvalidOptions,
          'Animation option names must be strings and values strings or numbers.');
      }
      if (names[i] === 'contentMode') {
        continue;
      }
      stringOptions[names[i]] = typeof value === 'number' ? (value as number).toString() : value as string;
    }
    const extension = CYLPlaceholderAnimationExtensionOfURL(file);
    const duration: string | undefined = stringOptions[CYLPlaceholderAnimationOptionRiveActiveDuration];
    if (extension === 'riv' && duration !== undefined) {
      const seconds = duration.trim().length > 0 ? Number(duration) : NaN;
      if (!isFinite(seconds) || seconds < 0 || seconds > 60) {
        return fail(CYLPlaceholderAnimationErrorCode.InvalidOptions, 'Rive duration must be between 0 and 60 seconds.');
      }
    }
    const animator = CYLPlaceholderItemAnimatorRegistry.animatorForURL(file);
    if (animator === null) {
      const engine: string | undefined = KNOWN_ENGINES[extension];
      return engine !== undefined ?
        fail(CYLPlaceholderAnimationErrorCode.BackendUnavailable, engine + ' support is not registered.') :
        fail(CYLPlaceholderAnimationErrorCode.UnsupportedFormat, 'No registered animator plays this file type.');
    }
    const URL = CYLPlaceholderAnimationURLWithOptions(file, stringOptions);
    const factory = CYLPlaceholderItemAnimationFactory.sharedFactory();
    const view = factory.animationViewWithURL(URL, width, height, contentMode);
    const player = view !== null ? factory.playerForView(view) : null;
    if (view === null || player === null) {
      const name = file.substring(file.lastIndexOf('/') + 1);
      return fail(CYLPlaceholderAnimationErrorCode.AssetLoadFailed,
        'The ' + animator.identifier + ' animator could not load ' + name + '.');
    }
    return new CYLPlaceholderAnimationViewModel(view, player, animator.identifier, width, height);
  }

  get view(): CYLPlaceholderAnimationContentView {
    return this.animationView;
  }

  get ready(): boolean {
    const playable = this.animationView.playableView();
    return playable !== null ? playable.cyl_isAnimationViewReady : true;
  }

  get errorHandler(): CYLPlaceholderAnimationErrorHandler | null {
    return this.errorHandlerValue;
  }

  set errorHandler(value: CYLPlaceholderAnimationErrorHandler | null) {
    this.errorHandlerValue = value;
    const playable = this.animationView.playableView();
    if (playable !== null) {
      playable.cyl_animationViewErrorHandler = value;
    }
  }

  get readyHandler(): (() => void) | null {
    return this.readyHandlerValue;
  }

  set readyHandler(value: (() => void) | null) {
    this.readyHandlerValue = value;
    const playable = this.animationView.playableView();
    if (playable !== null) {
      playable.cyl_animationViewReadyHandler = value;
    }
  }

  /** Plays from the start. */
  play(): void {
    this.player.play();
    this.playing = true;
  }

  /** Stops and restores the resting frame/state. */
  stop(): void {
    this.player.stop();
    this.playing = false;
  }

  /** Stops and displays the last frame where the engine supports it. */
  showLastFrame(): void {
    this.player.showLastFrame();
    this.playing = false;
  }

  /** Stops and seeks; false for values outside 0...1 or when the engine cannot seek. */
  setAnimationProgress(progress: number): boolean {
    if (!isFinite(progress) || progress < 0 || progress > 1 || !this.player.supportsProgress) {
      return false;
    }
    this.player.stop();
    this.player.progress = progress;
    this.playing = false;
    return true;
  }

  /** A positive finite speed; false otherwise or when the engine cannot change it. */
  setAnimationSpeed(speed: number): boolean {
    if (!isFinite(speed) || speed <= 0 || !this.player.supportsAnimationSpeed) {
      return false;
    }
    this.player.animationSpeed = speed;
    return true;
  }

  /** 0 loops until stopped; 1 plays once (the default). */
  setAnimationRepeatCount(repeatCount: number): boolean {
    if (!isFinite(repeatCount) || repeatCount < 0) {
      return false;
    }
    return this.player.setAnimationRepeatCount(Math.floor(repeatCount));
  }

  /** Replaces the color overrides; an empty record restores the animation's own colors. */
  setAnimationColors(colors: CYLPlaceholderAnimationColors): boolean {
    this.player.applyColors(Object.keys(colors).length > 0 ? colors : null, false);
    return true;
  }
}

/** Draws a CYLPlaceholderAnimationViewModel (iOS `CYLPlaceholderAnimationView`). */
@Component
export struct CYLPlaceholderAnimationView {
  @ObjectLink model: CYLPlaceholderAnimationViewModel;

  build() {
    Stack() {
      CYLPlaceholderAnimationContent({ view: this.model.animationView })
    }
    .width(this.model.width)
    .height(this.model.height)
  }
}

// Factories registered per file extension (CYLPlaceholderView +registerAnimationFactory:forFileExtension:).

const FACTORIES: Map<string, CYLPlaceholderAnimationFactory> = new Map<string, CYLPlaceholderAnimationFactory>();

/** Registers or, with null, removes a factory for an extension; false for "gif" (the built-in decoder) or "". */
export function CYLPlaceholderRegisterAnimationFactory(factory: CYLPlaceholderAnimationFactory | null,
  fileExtension: string): boolean {
  const key = (fileExtension.startsWith('.') ? fileExtension.substring(1) : fileExtension).toLowerCase();
  if (key.length === 0 || key === 'gif') {
    return false;
  }
  if (factory === null) {
    FACTORIES.delete(key);
  } else {
    FACTORIES.set(key, factory);
    CYLPlaceholderRegisterAnimatedItemType(key);
  }
  return true;
}

/**
 * Registers with CYLAnimatedItemEngines the animation type of a file extension ("json" registers "Lottie"), so
 * CYLAnimatedItemView plays files of that type; false for an extension CYLAnimatedItemView does not know (its types
 * are Lottie, PAG, Rive, SVGA and GIF: a file of another extension shows the static image).
 */
export function CYLPlaceholderRegisterAnimatedItemType(fileExtension: string): boolean {
  const key = (fileExtension.startsWith('.') ? fileExtension.substring(1) : fileExtension).toLowerCase();
  const type = key.length > 0 ? cylAnimatedItemTypeOf('file.' + key) : '';
  if (type.length === 0) {
    return false;
  }
  CYLAnimatedItemEngines.register(type);
  return true;
}

/** The factory registered for the URL's extension, or null. */
export function CYLPlaceholderAnimationFactoryForURL(URL: string): CYLPlaceholderAnimationFactory | null {
  const factory = FACTORIES.get(CYLPlaceholderAnimationExtensionOfURL(URL));
  return factory !== undefined ? factory : null;
}
