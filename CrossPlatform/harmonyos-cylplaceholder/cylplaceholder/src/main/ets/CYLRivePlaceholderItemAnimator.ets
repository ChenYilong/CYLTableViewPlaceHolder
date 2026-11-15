// iOS CYLRivePlaceholderItemAnimator: a CYLPlaceholderItemViewAnimator for ".riv" files, played by the OpenHarmony
// Rive runtime (@ohos/rive, RiveAnimationView). Like the iOS legacy view (CYLPlaceholderRiveLegacyItemAnimationView)
// it plays a named linear animation ("animation"), fires a state machine trigger input ("triggerInput"), or sets a
// boolean input ("input") true for "duration" seconds (1 by default, 0 keeps it true until stopped), on the
// "artboard" and "stateMachine" given; without those options the default state machine plays and pauses.
import { Fit, Loop, RiveAnimationView, initializeRive } from '@ohos/rive';
import {
  CYLPlaceholderAnimationArrayBuffer,
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

/** A Rive file drawn by RiveAnimationView. */
@Observed
export class CYLRiveAnimationContentView extends CYLPlaceholderPlayableContentView {
  private riveView: RiveAnimationView | null = null;
  private bytes: ArrayBuffer | null = null;
  private loop: Loop = Loop.ONESHOT;
  private deactivateTimer: number = -1;

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
    if (!riveInitialized) {
      try {
        initializeRive();
        riveInitialized = true;
      } catch (e) {
        this.didFail('Rive', e as Error);
        return;
      }
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

  cyl_playAnimationView(): void {
    const view = this.riveView;
    if (view === null || !this.cyl_isAnimationViewReady) {
      this.pendingCommand = 1;
      return;
    }
    this.cancelDeactivate();
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

  /** 0 loops and 1 plays once a named animation; other counts, and state machines, are not supported. */
  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    if (this.option(CYLPlaceholderAnimationOptionRiveAnimation) === undefined || (repeatCount !== 0 && repeatCount !== 1)) {
      return false;
    }
    this.repeatCount = repeatCount;
    this.loop = repeatCount === 0 ? Loop.LOOP : Loop.ONESHOT;
    return true;
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
