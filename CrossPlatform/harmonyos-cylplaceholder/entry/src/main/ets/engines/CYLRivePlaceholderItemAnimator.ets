// The example's engine (moved out of the cylplaceholder core on 2026-11-17: the core depends on no animation library,
// as CYLTabBarController's CYLAnimatedItem requires). ExampleAnimationEngines.ets registers it; an app copies it.
// iOS CYLRivePlaceholderItemAnimator: a CYLPlaceholderItemViewAnimator for ".riv" files, played by the OpenHarmony
// Rive runtime (@ohos/rive, RiveAnimationView). Like the iOS legacy view (CYLPlaceholderRiveLegacyItemAnimationView)
// it plays a named linear animation ("animation"), fires a state machine trigger input ("triggerInput"), or sets a
// boolean input ("input") true for "duration" seconds (1 by default, 0 keeps it true until stopped), on the
// "artboard" and "stateMachine" given. Without those legacy options (and without `legacy` = "1") it plays like the iOS
// view-model view (CYLPlaceholderRiveItemAnimationView): the bound view model's boolean `active` (default "active")
// is true for "duration" seconds, or its trigger `trigger` fires, and `color` is written to its "color" property.
// @ohos/rive is one runtime with both APIs, so `legacy` only picks the input API (see CYLRiveOptions.ets).
// Every play starts from the beginning, as CYLTabBarController's CYLRiveIcon (6a9ede85, docs/Animated-Item.md, the Rive
// loop): a named animation restarts; a trigger input restarts the state machine, then fires 50 ms later; a boolean
// (input or view model `active`) goes false, then true 50 ms later; `numberInput` is set to the next of `values`; a
// state machine without a usable input restarts. A repeat count of 0 loops a state machine by playing it again after
// each pass.
import { Fit, Loop, RendererType, RiveAnimationView, SMINumber, ViewModelInstance, initializeRive } from '@ohos/rive';
import { deviceInfo } from '@kit.BasicServicesKit';
import { RiveFileController } from '@ohos/rive/src/main/ets/runtime/controllers/RiveFileController';
import {
  CYLRiveActivePropertyPath,
  CYLRiveColorPropertyPath,
  CYLRiveColorInteger,
  CYLRiveColorValue,
  CYLRiveNextNumber,
  CYLRiveTriggerPropertyPath,
  CYLRiveUsesLegacyRuntime
} from 'cylplaceholder';
import { CYLPlaceholderDrawingColor } from 'cylplaceholder';
import {
  CYLPlaceholderAnimationArrayBuffer,
  CYLPlaceholderAnimationColors,
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationOptionRiveActiveDuration,
  CYLPlaceholderAnimationOptionRiveAnimation,
  CYLPlaceholderAnimationOptionRiveArtboard,
  CYLPlaceholderAnimationOptionRiveInput,
  CYLPlaceholderAnimationOptionRiveNumberInput,
  CYLPlaceholderAnimationOptionRiveNumberValues,
  CYLPlaceholderAnimationOptionRiveStateMachine,
  CYLPlaceholderAnimationOptionRiveTriggerInput,
  CYLPlaceholderAnimationReadFile,
  CYLPlaceholderItemAnimationViewProviding,
  CYLPlaceholderItemViewAnimator,
  CYLPlaceholderPlayableContentView
} from 'cylplaceholder';
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
} from 'cylplaceholder';

/** How long the input stays true, in seconds: 1 by default, at most 60; 0 keeps it true until stopped. */
export function CYLRiveActiveDuration(options: Record<string, string>): number {
  const text: string | undefined = options[CYLPlaceholderAnimationOptionRiveActiveDuration];
  const value = text !== undefined && text.trim().length > 0 ? Number(text) : NaN;
  return isFinite(value) && value >= 0 ? Math.min(value, 60) : 1;
}

/** Seconds of a loop pass when the file gives none (CYLRiveIcon `CYL_RIVE_LOOP_SECONDS`). */
const CYL_RIVE_LOOP_SECONDS: number = 1.5;
/** The pause after a boolean goes back to false, before the next pass. */
const CYL_RIVE_LOOP_PAUSE_SECONDS: number = 0.4;
/** A frame later: the state machine sees the reset or the false first. */
const CYL_RIVE_NEXT_FRAME_MS: number = 50;

let riveInitialized = false;

/**
 * Whether @ohos/rive can run here. FIX: HarmonyOS issue E15 (docs/HarmonyOS.md): @ohos/rive 1.0.4 ships its native
 * library (libohos_rive.so) for arm64-v8a only, so on an x86_64 emulator a Rive view crashed the app later
 * ("Accessing released C++ object: RiveArtboardRenderer" in onSurfaceChanged). Without arm64-v8a the example does not
 * register Rive, and every Rive file shows its static image or the placeholder instead.
 */
export function cylRiveIsSupported(): boolean {
  const abis: string = deviceInfo.abiList ?? '';
  return abis.split(',').map((abi: string) => abi.trim()).indexOf('arm64-v8a') >= 0;
}

/** Initializes @ohos/rive once for the library (throws when the runtime cannot load or the device cannot run it). */
export function cylEnsureRiveInitialized(): void {
  if (!cylRiveIsSupported()) {
    throw new Error('@ohos/rive has no native library for this device (' + (deviceInfo.abiList ?? '') + ')');
  }
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
  /** A repeat count of 0 on a state machine: play again after each pass. */
  private loopsStateMachine: boolean = false;
  private loopTimer: number = -1;
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
    this.cancelLoop();
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

  /** Sets the boolean (state machine input in the legacy API, else the view model property); a missing one is skipped. */
  private setActive(view: RiveAnimationView, value: boolean): void {
    if (CYLRiveUsesLegacyRuntime(this.options)) {
      const input = this.option(CYLPlaceholderAnimationOptionRiveInput);
      const machine = this.stateMachineName(view);
      if (input !== undefined && machine !== undefined) {
        try {
          view.setBooleanState(machine, input, value);
        } catch (e) {
          // No such input: nothing to drive, as on iOS.
        }
      }
      return;
    }
    const instance = this.viewModelInstance(view);
    if (instance === null) {
      return;
    }
    try {
      instance.getBooleanProperty(CYLRiveActivePropertyPath(this.options)).value = value;
    } catch (e) {
      // No such property: nothing to drive, as on iOS.
    }
  }

  /** Whether the state machine has the input (an unknown answer counts as yes). */
  private hasInput(view: RiveAnimationView, machine: string, input: string): boolean {
    try {
      const found = view.getStateMachines().find((instance) => instance.name === machine);
      return found === undefined ? true : found.inputNames.includes(input);
    } catch (e) {
      return true;
    }
  }

  /** A number input's value, undefined when unknown. */
  private numberValue(view: RiveAnimationView, machine: string, input: string): number | undefined {
    try {
      const found = view.getStateMachines().find((instance) => instance.name === machine);
      const value = found?.inputByName(input);
      return value instanceof SMINumber ? value.value : undefined;
    } catch (e) {
      return undefined;
    }
  }

  cyl_playAnimationView(): void {
    const view = this.riveView;
    if (view === null || !this.cyl_isAnimationViewReady) {
      this.pendingCommand = 1;
      return;
    }
    this.play(view);
  }

  /** CYLRiveIcon.cylPlay: plays from the start (see the file comment). */
  private play(view: RiveAnimationView): void {
    this.cancelDeactivate();
    this.cancelLoop();
    const animation = this.option(CYLPlaceholderAnimationOptionRiveAnimation);
    if (animation !== undefined) {
      // The repeat count picks the loop mode (Loop.LOOP for 0): no loop timer.
      view.reset();
      view.play(animation, this.loop);
      return;
    }
    const legacy = CYLRiveUsesLegacyRuntime(this.options);
    const machine = this.stateMachineName(view);
    const triggerInput = legacy ? this.option(CYLPlaceholderAnimationOptionRiveTriggerInput) : undefined;
    const trigger = legacy ? null : CYLRiveTriggerPropertyPath(this.options);
    const instance = legacy ? null : this.viewModelInstance(view);
    const input = legacy ? this.option(CYLPlaceholderAnimationOptionRiveInput) : undefined;
    const numberInput = this.option(CYLPlaceholderAnimationOptionRiveNumberInput);
    if (triggerInput !== undefined && machine !== undefined && this.hasInput(view, machine, triggerInput)) {
      view.reset();
      view.play();
      this.deactivateTimer = setTimeout(() => {
        this.deactivateTimer = -1;
        if (this.riveView === view) {
          try {
            view.fireState(machine, triggerInput);
          } catch (e) {
            // No such trigger.
          }
        }
      }, CYL_RIVE_NEXT_FRAME_MS);
    } else if (numberInput !== undefined && machine !== undefined && this.hasInput(view, machine, numberInput)) {
      // The next value: house.riv moves only when Rooms changes.
      view.play();
      view.setNumberState(machine, numberInput, CYLRiveNextNumber(this.option(CYLPlaceholderAnimationOptionRiveNumberValues),
        this.numberValue(view, machine, numberInput)));
    } else if (trigger !== null && instance !== null) {
      view.play();
      try {
        instance.getTriggerProperty(trigger).trigger();
      } catch (e) {
        // No such trigger.
      }
    } else if (instance !== null || (input !== undefined && machine !== undefined && this.hasInput(view, machine, input))) {
      view.play();
      this.setActive(view, false);
      const duration = CYLRiveActiveDuration(this.options);
      this.deactivateTimer = setTimeout(() => {
        this.deactivateTimer = -1;
        if (this.riveView !== view) {
          return;
        }
        this.setActive(view, true);
        if (duration > 0) {
          this.deactivateTimer = setTimeout(() => {
            this.deactivateTimer = -1;
            if (this.riveView === view) {
              this.setActive(view, false);
            }
          }, duration * 1000);
        }
      }, CYL_RIVE_NEXT_FRAME_MS);
    } else {
      view.reset();
      view.play();
    }
    this.scheduleLoop(view, trigger !== null || triggerInput !== undefined);
  }

  /** Whether a play restarts the file (no usable input or trigger, no view model). */
  private restartsOnPlay(view: RiveAnimationView): boolean {
    const machine = this.stateMachineName(view);
    if (machine === undefined) {
      return true;
    }
    if (!CYLRiveUsesLegacyRuntime(this.options) && this.viewModelInstance(view) !== null) {
      return false;
    }
    const inputs = [CYLPlaceholderAnimationOptionRiveTriggerInput, CYLPlaceholderAnimationOptionRiveNumberInput,
      CYLPlaceholderAnimationOptionRiveInput].map((key: string) => this.option(key))
      .filter((name: string | undefined) => name !== undefined) as string[];
    return !inputs.some((name: string) => this.hasInput(view, machine, name));
  }

  /** The next pass while looping (CYLRiveIcon.cylScheduleLoop). */
  private scheduleLoop(view: RiveAnimationView, isTrigger: boolean): void {
    if (!this.loopsStateMachine) {
      return;
    }
    const duration = CYLRiveActiveDuration(this.options);
    const seconds = !isTrigger && duration > 0 ? duration + CYL_RIVE_LOOP_PAUSE_SECONDS : CYL_RIVE_LOOP_SECONDS;
    this.loopTimer = setTimeout(() => {
      this.loopTimer = -1;
      if (!this.loopsStateMachine || this.riveView !== view) {
        return;
      }
      // A file still moving on its own is not cut short: check again after another pass.
      if (this.restartsOnPlay(view) && view.isPlaying()) {
        this.scheduleLoop(view, isTrigger);
      } else {
        this.play(view);
      }
    }, seconds * 1000);
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
    this.cancelLoop();
    const view = this.riveView;
    if (view === null || !this.cyl_isAnimationViewReady) {
      return;
    }
    if (!CYLRiveUsesLegacyRuntime(this.options)) {
      if (CYLRiveTriggerPropertyPath(this.options) === null) {
        this.setActive(view, false);
      }
      view.pause();
      return;
    }
    if (this.option(CYLPlaceholderAnimationOptionRiveAnimation) !== undefined) {
      view.stop();
      return;
    }
    this.setActive(view, false);
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

  /**
   * 0 loops and 1 plays once: a named animation through its loop mode, a state machine by playing again after each pass
   * (CYLRiveIcon `loops`). Other counts are not supported.
   */
  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    if (repeatCount !== 0 && repeatCount !== 1) {
      return false;
    }
    this.repeatCount = repeatCount;
    if (this.option(CYLPlaceholderAnimationOptionRiveAnimation) !== undefined) {
      this.loop = repeatCount === 0 ? Loop.LOOP : Loop.ONESHOT;
      return true;
    }
    this.loopsStateMachine = repeatCount === 0;
    if (!this.loopsStateMachine) {
      this.cancelLoop();
    }
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

  private cancelLoop(): void {
    if (this.loopTimer >= 0) {
      clearTimeout(this.loopTimer);
      this.loopTimer = -1;
    }
  }

  private cancelDeactivate(): void {
    if (this.deactivateTimer >= 0) {
      clearTimeout(this.deactivateTimer);
      this.deactivateTimer = -1;
    }
  }
}

/**
 * The Rive renderer for this device. The HarmonyOS emulator's host GPU crashes the whole emulator when @ohos/rive draws
 * with its default GPU renderer (`RendererType.Rive`): the emulator log shows the GPU thread stalling, then a
 * minidump, whenever a .riv file is shown. On the emulator the Canvas renderer draws the same file without the GPU
 * path; real devices keep the default renderer.
 */
export function cylRiveRendererType(): RendererType {
  return deviceInfo.productModel === 'emulator' ? RendererType.Canvas : RendererType.Rive;
}

@Component
struct CYLRiveAnimationComponent {
  @ObjectLink view: CYLRiveAnimationContentView;

  build() {
    Stack() {
      RiveAnimationView({
        riveAutoPlay: false,
        // [EN] The placeholder's button and tap-to-reload keep the taps. [CN] 点击留给占位图的按钮与点击重试。
        touchPassThrough: true,
        rendererType: cylRiveRendererType(),
        onReady: (riveView: RiveAnimationView) => {
          this.view.onRiveReady(riveView);
        }
      })
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.None)
    }
    .width(this.view.width)
    .height(this.view.height)
    .hitTestBehavior(HitTestMode.Transparent)
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
