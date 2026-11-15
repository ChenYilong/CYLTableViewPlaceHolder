// iOS RiveSwift/CYLPlaceholderRiveItemAnimationView.swift and CYLPlaceholderRiveLegacyItemAnimationView.swift: the
// public Rive views, thin classes over the library's Rive player (CYLRiveAnimationContentView on @ohos/rive).
// `CYLPlaceholderRiveItemAnimationView` plays through the bound view model (boolean `active` for `duration` seconds,
// or trigger `trigger`; `color` and applyAnimationColors write color properties); options that need the legacy API
// (`input`, `triggerInput`, `animation`, `legacy` = "1") go to `legacyViewProvider`, which makes a
// `CYLPlaceholderRiveLegacyItemAnimationView` (state machine inputs or a named linear animation).
// Both are CYLPlaceholderAnimationContentView: show one with `CYLPlaceholderAnimationContent({ view })`.
import { CYLRiveAnimationContentView } from './CYLRivePlaceholderItemAnimator';
import { CYLRiveUsesLegacyRuntime } from './CYLRiveOptions';
import {
  CYLPlaceholderAnimationColors,
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationErrorHandler,
  CYLPlaceholderAnimationFileExists,
  CYLPlaceholderAnimationFileOfURL,
  CYLPlaceholderAnimationOptionRiveLegacyRuntime,
  CYLPlaceholderItemAnimationViewProviding
} from './CYLPlaceholderAnimation';

/** Makes the legacy view (iOS `CYLPlaceholderRiveLegacyItemAnimationView` as a view provider class). */
export class CYLPlaceholderRiveLegacyViewProvider implements CYLPlaceholderItemAnimationViewProviding {
  cyl_animationViewWithFileURL(fileURL: string, options: Record<string, string>,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    return CYLPlaceholderRiveLegacyItemAnimationView.makeAnimationView(fileURL, options, contentMode);
  }
}

/**
 * Plays a Rive artboard through its view model (iOS `CYLPlaceholderRiveItemAnimationView`): the boolean `active`
 * property is set to true, then back to false after `duration` seconds, or the trigger `trigger` is fired.
 */
@Observed
export class CYLPlaceholderRiveItemAnimationView extends CYLRiveAnimationContentView {
  /**
   * The renderer for legacy options (iOS `legacyViewProvider`, injected by CYLRivePlaceholderItemAnimator): the
   * legacy view by default; null: legacy options show nothing (makeAnimationView returns null).
   */
  static legacyViewProvider: CYLPlaceholderItemAnimationViewProviding | null = new CYLPlaceholderRiveLegacyViewProvider();

  /**
   * A view for the file and options, scaled like contentMode (iOS `makeAnimationView(fileURL:options:contentMode:)`);
   * legacy options are passed to `legacyViewProvider`.
   */
  static makeAnimationView(fileURL: string, options: Record<string, string>,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    if (CYLRiveUsesLegacyRuntime(options)) {
      const provider = CYLPlaceholderRiveItemAnimationView.legacyViewProvider;
      return provider !== null ? provider.cyl_animationViewWithFileURL(fileURL, options, contentMode) : null;
    }
    return new CYLPlaceholderRiveItemAnimationView(CYLPlaceholderAnimationFileOfURL(fileURL), options, contentMode);
  }

  /** Called once the file is loaded (iOS `animationReadyHandler`). */
  get animationReadyHandler(): (() => void) | null {
    return this.cyl_animationViewReadyHandler;
  }

  set animationReadyHandler(handler: (() => void) | null) {
    this.cyl_animationViewReadyHandler = handler;
  }

  /** Called when the file cannot be loaded (iOS `animationErrorHandler`). */
  get animationErrorHandler(): CYLPlaceholderAnimationErrorHandler | null {
    return this.cyl_animationViewErrorHandler;
  }

  set animationErrorHandler(handler: CYLPlaceholderAnimationErrorHandler | null) {
    this.cyl_animationViewErrorHandler = handler;
  }

  /** Whether the file is loaded (iOS `isAnimationReady`). */
  get isAnimationReady(): boolean {
    return this.cyl_isAnimationViewReady;
  }

  /** Sets `active` (or fires `trigger`); before the load it plays once loaded. */
  playAnimation(): void {
    this.cyl_playAnimationView();
  }

  /** A state machine has no last frame: the view stays in its resting state. */
  showAnimationLastFrame(): void {
    this.cyl_showAnimationViewLastFrame();
  }

  /** Sets `active` back to false and pauses rendering. */
  stopAnimation(): void {
    this.cyl_stopAnimationView();
  }

  /** Color property path -> color; null restores the original colors. */
  applyAnimationColors(colors: CYLPlaceholderAnimationColors | null): void {
    this.cyl_applyAnimationViewColors(colors);
  }
}

/** The options with the legacy API forced, as the legacy view always uses it. */
export function CYLPlaceholderRiveLegacyOptions(options: Record<string, string>): Record<string, string> {
  const result: Record<string, string> = {};
  Object.keys(options).forEach((key: string) => {
    result[key] = options[key];
  });
  result[CYLPlaceholderAnimationOptionRiveLegacyRuntime] = '1';
  return result;
}

/**
 * Wraps Rive's legacy API for .riv files without a view model (iOS `CYLPlaceholderRiveLegacyItemAnimationView`,
 * deprecated there): plays the named linear animation `animation`, fires the trigger input `triggerInput`, or sets the
 * boolean input `input` true for `duration` seconds, on `artboard` / `stateMachine`.
 */
@Observed
export class CYLPlaceholderRiveLegacyItemAnimationView extends CYLRiveAnimationContentView {
  /**
   * A view for the file, or null when it cannot be read (checked synchronously, like iOS reading the file). An
   * artboard, animation, state machine or input missing from the file is reported by the error handler on load.
   */
  static makeAnimationView(fileURL: string, options: Record<string, string>,
    contentMode: ImageFit, context: Context | null = null): CYLPlaceholderRiveLegacyItemAnimationView | null {
    const file = CYLPlaceholderAnimationFileOfURL(fileURL);
    if (!CYLPlaceholderAnimationFileExists(file, context)) {
      return null;
    }
    return new CYLPlaceholderRiveLegacyItemAnimationView(file, CYLPlaceholderRiveLegacyOptions(options), contentMode);
  }

  /** Plays the animation, fires the trigger, or sets the input to true (back to false after the duration, unless 0). */
  playAnimation(): void {
    this.cyl_playAnimationView();
  }

  /** 0 loops and 1 plays once a named animation; other counts, and state machines, are not supported (false). */
  setAnimationRepeatCount(repeatCount: number): boolean {
    return this.cyl_setAnimationViewRepeatCount(repeatCount);
  }

  showAnimationLastFrame(): void {
    this.cyl_showAnimationViewLastFrame();
  }

  /** Stops the named animation, or sets the input false and pauses. */
  stopAnimation(): void {
    this.cyl_stopAnimationView();
  }
}
