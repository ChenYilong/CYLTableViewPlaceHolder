// iOS CYLRivePlaceholderItemAnimator: a CYLPlaceholderItemViewAnimator for ".riv" files, played by the OpenHarmony
// Rive runtime (@ohos/rive, RiveAnimationView). Like the iOS legacy view (CYLPlaceholderRiveLegacyItemAnimationView)
// it plays a named linear animation ("animation"), fires a state machine trigger input ("triggerInput"), or sets a
// boolean input ("input") true for "duration" seconds (1 by default, 0 keeps it true until stopped), on the
// "artboard" and "stateMachine" given. Without those legacy options (and without `legacy` = "1") it plays like the iOS
// view-model view (CYLPlaceholderRiveItemAnimationView): the bound view model's boolean `active` (default "active")
// is true for "duration" seconds, or its trigger `trigger` fires, and `color` is written to its "color" property.
// @ohos/rive is one runtime with both APIs, so `legacy` only picks the input API (see CYLRiveOptions.ets).
import { Fit, Loop, RiveAnimationView, ViewModelInstance, initializeRive } from '@ohos/rive';
import { RiveFileController } from '@ohos/rive/src/main/ets/runtime/controllers/RiveFileController';
import {
  CYLRiveActivePropertyPath,
  CYLRiveColorPropertyPath,
  CYLRiveColorInteger,
  CYLRiveColorValue,
  CYLRiveTriggerPropertyPath,
  CYLRiveUsesLegacyRuntime
} from './CYLRiveOptions';
import { CYLPlaceholderDrawingColor } from './CYLPlaceholderView';
import {
  CYLPlaceholderAnimationArrayBuffer,
  CYLPlaceholderAnimationColors,
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationOptionRiveActiveDuration,
  CYLPlaceholderAnimationOptionRiveAnimation,
  CYLPlaceholderAnimationOptionRiveArtboard,
  CYLPlaceholderAnimationOptionRiveInput,
  CYLPlaceholderAnimationOptionRiveStateMachine,
  CYLPlaceholderAnimationOptionRiveTriggerInput,
  CYLPlaceholderAnimationReadFile,
  CYLPlaceholderItemAnimationViewProviding,
  CYLPlaceholderItemViewAnimator,
  CYLPlaceholderPlayableContentView
} from './CYLPlaceholderAnimation';
import {
  CYLPlaceholderItemAnimationDarkColors,
  CYLPlaceholderItemAnimationDarkFilePath,
  CYLPlaceholderItemAnimationDarkURL,
  CYLPlaceholderItemAnimationFilePath,
  CYLPlaceholderItemAnimationSize,
  CYLPlaceholderItemAnimationURL,
  CYLPlaceholderItemRiveDarkColors,
  CYLPlaceholderItemRiveDarkFilePath,
  CYLPlaceholderItemRiveDarkURL,
  CYLPlaceholderItemRiveFilePath,
  CYLPlaceholderItemRiveSize,
  CYLPlaceholderItemRiveURL
} from './CYLPlaceholderViewTypes';

/** How long the input stays true, in seconds: 1 by default, at most 60; 0 keeps it true until stopped. */
export function CYLRiveActiveDuration(options: Record<string, string>): number {
  const text: string | undefined = options[CYLPlaceholderAnimationOptionRiveActiveDuration];
  const value = text !== undefined && text.trim().length > 0 ? Number(text) : NaN;
  return isFinite(value) && value >= 0 ? Math.min(value, 60) : 1;
}

let riveInitialized = false;

/** Initializes @ohos/rive once for the library (throws when the runtime cannot load). */
export function cylEnsureRiveInitialized(): void {
  if (!riveInitialized) {
    initializeRive();
    riveInitialized = true;
  }
}

function riveFit(fit: ImageFit): Fit {
  if (fit === ImageFit.Cover) {
    return Fit.COVER;
  }
  if (fit === ImageFit.Fill) {
    return Fit.FILL;
  }
  if (fit === ImageFit.None) {
    return Fit.NONE;
  }
  if (fit === ImageFit.ScaleDown) {
    return Fit.SCALE_DOWN;
  }
  return Fit.CONTAIN;
}

/**
 * @ohos/rive has no playback speed: this controller scales the time of every advance (the renderer calls advance with
 * the real elapsed time each frame), so animations and state machines run at `speed`.
 */
export class CYLRiveSpeedController extends RiveFileController {
  speed: number = 1;

  advance(elapsed: number): void {
    super.advance(elapsed * this.speed);
  }
}

/** A Rive file drawn by RiveAnimationView. */
@Observed
export class CYLRiveAnimationContentView extends CYLPlaceholderPlayableContentView {
  private riveView: RiveAnimationView | null = null;
  /** Given to RiveAnimationView so the speed applies (the view uses it when it keeps the controller it was given). */
  readonly speedController: CYLRiveSpeedController = new CYLRiveSpeedController();
  private bytes: ArrayBuffer | null = null;
  /** How a named animation plays: AUTO follows the file (iOS `.autoLoop`). */
  private loop: Loop = Loop.AUTO;
  private deactivateTimer: number = -1;
  /** The colors last asked for (iOS `requestedColors`); null restores the original colors. */
  private requestedColors: CYLPlaceholderAnimationColors | null = null;
  /** The file's colors before they were overridden, by property path. */
  private originalColors: Map<string, number> = new Map<string, number>();
  private overriddenColorPaths: Set<string> = new Set<string>();

  constructor(fileURL: string, options: Record<string, string>, contentMode: ImageFit) {
    super();
    this.fileURL = fileURL;
    this.options = options;
    this.contentMode = contentMode;
    this.builder = wrapBuilder(riveContentBuilder);
  }

  private option(name: string): string | undefined {
    const value: string | undefined = this.options[name];
    return value !== undefined && value.length > 0 ? value : undefined;
  }

  cyl_attach(context: Context | null): void {
    try {
      cylEnsureRiveInitialized();
    } catch (e) {
      this.didFail('Rive', e as Error);
      return;
    }
    if (this.bytes !== null || this.loading || this.failed) {
      return;
    }
    this.loading = true;
    CYLPlaceholderAnimationReadFile(this.fileURL, context).then((bytes: Uint8Array) => {
      this.bytes = CYLPlaceholderAnimationArrayBuffer(bytes);
      this.loadIfPossible();
    }).catch((e: Error) => {
      this.didFail('Rive', e);
    });
  }

  /** RiveAnimationView is set up. */
  onRiveReady(view: RiveAnimationView): void {
    this.riveView = view;
    this.loadIfPossible();
  }

  cyl_detach(): void {
    this.cancelDeactivate();
    this.riveView = null;
    this.cyl_isAnimationViewReady = false;
  }

  private loadIfPossible(): void {
    const view = this.riveView;
    if (view === null || this.bytes === null || this.cyl_isAnimationViewReady) {
      return;
    }
    try {
      view.setRiveBytes(this.bytes as ArrayBuffer, this.option(CYLPlaceholderAnimationOptionRiveArtboard),
        this.option(CYLPlaceholderAnimationOptionRiveAnimation), this.option(CYLPlaceholderAnimationOptionRiveStateMachine),
        false, true, riveFit(this.contentMode), undefined, this.loop);
      this.applyLightColor(view);
      if (this.requestedColors !== null) {
        this.applyRequestedColors(view);
      }
      this.didLoad();
    } catch (e) {
      this.didFail('Rive', e as Error);
    }
  }

  /** The state machine the inputs belong to: the option, or the file's first one. */
  private stateMachineName(view: RiveAnimationView): string | undefined {
    const named = this.option(CYLPlaceholderAnimationOptionRiveStateMachine);
    if (named !== undefined) {
      return named;
    }
    const machines = view.getStateMachines();
    return machines.length > 0 ? machines[0].name : undefined;
  }

  /** The view model bound to the state machine (autoBind), or null for a file without one. */
  private viewModelInstance(view: RiveAnimationView): ViewModelInstance | null {
    try {
      const machines = view.getStateMachines();
      return machines.length > 0 ? machines[0].viewModelInstance : null;
    } catch (e) {
      return null;
    }
  }

  private applyLightColor(view: RiveAnimationView): void {
    const color = CYLRiveColorValue(this.options);
    if (color === null || CYLRiveUsesLegacyRuntime(this.options)) {
      return;
    }
    const instance = this.viewModelInstance(view);
    if (instance === null) {
      return;
    }
    try {
      instance.getColorProperty(CYLRiveColorPropertyPath).value = color | 0;
      this.originalColors.set(CYLRiveColorPropertyPath, color | 0);
    } catch (e) {
      // No "color" property: the file keeps its colors, as on iOS.
    }
  }

  private setActive(instance: ViewModelInstance, value: boolean): void {
    try {
      instance.getBooleanProperty(CYLRiveActivePropertyPath(this.options)).value = value;
    } catch (e) {
      // No such property: nothing to drive, as on iOS.
    }
  }

  /** iOS CYLPlaceholderRiveItemAnimationView.playAnimation. */
  private playViewModel(view: RiveAnimationView): void {
    view.play();
    const instance = this.viewModelInstance(view);
    if (instance === null) {
      return;
    }
    const trigger = CYLRiveTriggerPropertyPath(this.options);
    if (trigger !== null) {
      try {
        instance.getTriggerProperty(trigger).trigger();
      } catch (e) {
        // No such trigger.
      }
      return;
    }
    this.setActive(instance, true);
    const duration = CYLRiveActiveDuration(this.options);
    if (duration > 0) {
      this.deactivateTimer = setTimeout(() => {
        this.deactivateTimer = -1;
        if (this.riveView === view) {
          this.setActive(instance, false);
        }
      }, duration * 1000);
    }
  }

  cyl_playAnimationView(): void {
    const view = this.riveView;
    if (view === null || !this.cyl_isAnimationViewReady) {
      this.pendingCommand = 1;
      return;
    }
    this.cancelDeactivate();
    if (!CYLRiveUsesLegacyRuntime(this.options)) {
      this.playViewModel(view);
      return;
    }
    const animation = this.option(CYLPlaceholderAnimationOptionRiveAnimation);
    if (animation !== undefined) {
      view.play(animation, this.loop);
      return;
    }
    view.play();
    const machine = this.stateMachineName(view);
    const trigger = this.option(CYLPlaceholderAnimationOptionRiveTriggerInput);
    if (trigger !== undefined && machine !== undefined) {
      view.fireState(machine, trigger);
      return;
    }
    const input = this.option(CYLPlaceholderAnimationOptionRiveInput);
    if (input === undefined || machine === undefined) {
      return;
    }
    view.setBooleanState(machine, input, true);
    const duration = CYLRiveActiveDuration(this.options);
    if (duration > 0) {
      this.deactivateTimer = setTimeout(() => {
        this.deactivateTimer = -1;
        if (this.riveView === view) {
          view.setBooleanState(machine, input, false);
        }
      }, duration * 1000);
    }
  }

  /** A state machine has no last frame: the view stays in its resting state. */
  cyl_showAnimationViewLastFrame(): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingCommand = 2;
      return;
    }
    this.cyl_stopAnimationView();
  }

  cyl_stopAnimationView(): void {
    this.pendingCommand = 0;
    this.cancelDeactivate();
    const view = this.riveView;
    if (view === null || !this.cyl_isAnimationViewReady) {
      return;
    }
    if (!CYLRiveUsesLegacyRuntime(this.options)) {
      const instance = this.viewModelInstance(view);
      if (instance !== null && CYLRiveTriggerPropertyPath(this.options) === null) {
        this.setActive(instance, false);
      }
      view.pause();
      return;
    }
    if (this.option(CYLPlaceholderAnimationOptionRiveAnimation) !== undefined) {
      view.stop();
      return;
    }
    const input = this.option(CYLPlaceholderAnimationOptionRiveInput);
    const machine = this.stateMachineName(view);
    if (input !== undefined && machine !== undefined) {
      view.setBooleanState(machine, input, false);
    }
    view.pause();
  }

  /**
   * @ohos/rive has no speed API, and handing RiveAnimationView a custom controller (CYLRiveSpeedController) was
   * followed by an emulator crash on a .riv detail page (2026-11-16), so the controller is no longer passed and the
   * speed is reported unsupported (docs/HarmonyOS.md Q7).
   */
  get cyl_supportsAnimationViewSpeed(): boolean {
    return false;
  }

  /** Live: the next frame advances by the elapsed time times the speed. */
  cyl_setAnimationViewSpeed(speed: number): boolean {
    if (!isFinite(speed) || speed <= 0) {
      return false;
    }
    this.playbackSpeed = speed;
    this.speedController.speed = speed;
    const view = this.riveView;
    if (view !== null && view.controller !== null && view.controller !== this.speedController) {
      // The view made its own controller: the speed cannot reach it.
      return false;
    }
    return true;
  }

  /** 0 loops and 1 plays once a named animation; other counts, and state machines, are not supported. */
  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    if (this.option(CYLPlaceholderAnimationOptionRiveAnimation) === undefined || (repeatCount !== 0 && repeatCount !== 1)) {
      return false;
    }
    this.repeatCount = repeatCount;
    this.loop = repeatCount === 0 ? Loop.LOOP : Loop.ONESHOT;
    return true;
  }

  /**
   * View-model color property path -> color; null restores the original colors (iOS
   * CYLPlaceholderRiveItemAnimationView.applyAnimationColors). Files without a view model keep their colors.
   */
  cyl_applyAnimationViewColors(colors: CYLPlaceholderAnimationColors | null): void {
    this.requestedColors = colors;
    const view = this.riveView;
    if (view !== null && this.cyl_isAnimationViewReady) {
      this.applyRequestedColors(view);
    }
  }

  private applyRequestedColors(view: RiveAnimationView): void {
    const instance = this.viewModelInstance(view);
    if (instance === null) {
      return;
    }
    const colors = this.requestedColors;
    if (colors !== null) {
      Object.keys(colors).forEach((path: string) => {
        const color = CYLPlaceholderDrawingColor(colors[path]);
        if (color === null) {
          return;
        }
        try {
          const property = instance.getColorProperty(path);
          if (!this.originalColors.has(path)) {
            this.originalColors.set(path, property.value);
          }
          property.value = CYLRiveColorInteger(color.red, color.green, color.blue, color.alpha);
          this.overriddenColorPaths.add(path);
        } catch (e) {
          // No such color property.
        }
      });
      return;
    }
    this.overriddenColorPaths.forEach((path: string) => {
      const original = this.originalColors.get(path);
      if (original !== undefined) {
        try {
          instance.getColorProperty(path).value = original;
        } catch (e) {
          // No such color property.
        }
      }
    });
    this.overriddenColorPaths.clear();
  }

  private cancelDeactivate(): void {
    if (this.deactivateTimer >= 0) {
      clearTimeout(this.deactivateTimer);
      this.deactivateTimer = -1;
    }
  }
}

@Component
struct CYLRiveAnimationComponent {
  @ObjectLink view: CYLRiveAnimationContentView;

  build() {
    Stack() {
      RiveAnimationView({
        riveAutoPlay: false,
        onReady: (riveView: RiveAnimationView) => {
          this.view.onRiveReady(riveView);
        }
      })
        .width('100%')
        .height('100%')
    }
    .width(this.view.width)
    .height(this.view.height)
  }
}

@Builder
function riveContentBuilder(view: CYLPlaceholderAnimationContentView) {
  CYLRiveAnimationComponent({ view: view as CYLRiveAnimationContentView })
}

class CYLRiveViewProvider implements CYLPlaceholderItemAnimationViewProviding {
  cyl_animationViewWithFileURL(fileURL: string, options: Record<string, string>,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    return new CYLRiveAnimationContentView(fileURL, options, contentMode);
  }
}

function riveAttributeKeys(): Record<string, string> {
  const keys: Record<string, string> = {};
  keys[CYLPlaceholderItemAnimationURL] = CYLPlaceholderItemRiveURL;
  keys[CYLPlaceholderItemAnimationFilePath] = CYLPlaceholderItemRiveFilePath;
  keys[CYLPlaceholderItemAnimationSize] = CYLPlaceholderItemRiveSize;
  keys[CYLPlaceholderItemAnimationDarkURL] = CYLPlaceholderItemRiveDarkURL;
  keys[CYLPlaceholderItemAnimationDarkFilePath] = CYLPlaceholderItemRiveDarkFilePath;
  keys[CYLPlaceholderItemAnimationDarkColors] = CYLPlaceholderItemRiveDarkColors;
  return keys;
}

/** Registers a CYLPlaceholderItemViewAnimator for ".riv" files (iOS `CYLRivePlaceholderItemAnimator`). */
export class CYLRivePlaceholderItemAnimator {
  private static shared: CYLPlaceholderItemViewAnimator | null = null;

  /** The Rive animator (iOS class property `animator`). */
  static get animator(): CYLPlaceholderItemViewAnimator {
    if (CYLRivePlaceholderItemAnimator.shared === null) {
      CYLRivePlaceholderItemAnimator.shared = new CYLPlaceholderItemViewAnimator('Rive', ['riv'], riveAttributeKeys(),
        new CYLRiveViewProvider());
    }
    return CYLRivePlaceholderItemAnimator.shared as CYLPlaceholderItemViewAnimator;
  }
}
