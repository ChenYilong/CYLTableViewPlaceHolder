// iOS CYLPAGPlaceholderItemAnimator: plays ".pag" files with Tencent's official libpag for OpenHarmony
// (@tencent/libpag: PAGFile.LoadFromBytes + PAGViewController + PAGView). libpag has no playback speed, so a speed
// other than 1 drives the progress per frame (CYLPAGDrivenProgress).
import { PAGFile, PAGView, PAGViewController } from '@tencent/libpag';
import { PAGScaleMode } from '@tencent/libpag/src/main/ets/PAGScaleMode';
import {
  CYLPlaceholderAnimationArrayBuffer,
  CYLPlaceholderAnimationColors,
  CYLPlaceholderAnimationContentView,
  CYLPlaceholderAnimationExtensionOfURL,
  CYLPlaceholderAnimationFileOfURL,
  CYLPlaceholderAnimationOptionsOfURL,
  CYLPlaceholderAnimationReadFile,
  CYLPlaceholderItemAnimationBasePlayer,
  CYLPlaceholderItemAnimationPlayer,
  CYLPlaceholderItemAnimator,
  CYLPlaceholderItemAnimatorPriority,
  CYLPlaceholderItemAnimatorPriorityDefault,
  CYLPlaceholderPlayableContentView
} from './CYLPlaceholderAnimation';
import {
  CYLPlaceholderItemAnimationDarkFilePath,
  CYLPlaceholderItemAnimationDarkURL,
  CYLPlaceholderItemAnimationFilePath,
  CYLPlaceholderItemAnimationSize,
  CYLPlaceholderItemAnimationURL,
  CYLPlaceholderItemPAGDarkFilePath,
  CYLPlaceholderItemPAGDarkURL,
  CYLPlaceholderItemPAGFilePath,
  CYLPlaceholderItemPAGSize,
  CYLPlaceholderItemPAGURL
} from './CYLPlaceholderViewTypes';

/** libpag's scale mode for an ImageFit. */
function pagScaleMode(fit: ImageFit): PAGScaleMode {
  if (fit === ImageFit.Cover) {
    return PAGScaleMode.Zoom;
  }
  if (fit === ImageFit.Fill) {
    return PAGScaleMode.Stretch;
  }
  if (fit === ImageFit.None) {
    return PAGScaleMode.None;
  }
  return PAGScaleMode.LetterBox;
}

/** A PAG file drawn by libpag's PAGView. */
@Observed
export class CYLPAGAnimationContentView extends CYLPlaceholderPlayableContentView {
  readonly controller: PAGViewController = new PAGViewController();
  pendingProgress: number = -1;
  // libpag has no playback speed: at a speed other than 1 the view drives the progress itself, one tick per frame.
  private driveTimer: number = -1;
  private driveProgress: number = 0;
  private drivePlays: number = 0;
  private driveLastTick: number = 0;

  get cyl_supportsAnimationViewSpeed(): boolean {
    return true;
  }

  /** Live: a playing animation keeps its position and goes on at the new speed. */
  cyl_setAnimationViewSpeed(speed: number): boolean {
    if (!isFinite(speed) || speed <= 0) {
      return false;
    }
    this.playbackSpeed = speed;
    if (!this.cyl_isAnimationViewReady) {
      return true;
    }
    const playing = this.driveTimer >= 0 || this.controller.isPlaying();
    if (!playing) {
      return true;
    }
    const progress = this.driveTimer >= 0 ? this.driveProgress : this.controller.getProgress();
    const plays = this.drivePlays;
    this.stopDriving();
    this.controller.pause();
    this.playFrom(progress, plays);
    return true;
  }

  /** Plays from a progress with `plays` plays already finished: natively at speed 1, else driven. */
  private playFrom(progress: number, plays: number): void {
    if (this.playbackSpeed === 1) {
      this.controller.setRepeatCount(this.repeatCount === 0 ? 0 : Math.max(1, this.repeatCount - plays));
      this.controller.setProgress(progress);
      this.controller.play();
      return;
    }
    this.driveProgress = progress;
    this.drivePlays = plays;
    this.driveLastTick = Date.now();
    this.controller.setProgress(progress);
    this.controller.flush();
    this.driveTimer = setInterval(() => this.driveTick(), 16);
  }

  private driveTick(): void {
    const now = Date.now();
    const elapsed = now - this.driveLastTick;
    this.driveLastTick = now;
    const next = CYLPAGDrivenProgress(this.driveProgress, this.drivePlays, elapsed, this.controller.duration() / 1000,
      this.playbackSpeed, this.repeatCount);
    this.driveProgress = next.progress;
    this.drivePlays = next.plays;
    this.controller.setProgress(next.progress);
    this.controller.flush();
    if (next.finished) {
      this.stopDriving();
    }
  }

  private stopDriving(): void {
    if (this.driveTimer >= 0) {
      clearInterval(this.driveTimer);
      this.driveTimer = -1;
    }
  }

  constructor(fileURL: string, options: Record<string, string>, contentMode: ImageFit) {
    super();
    this.fileURL = fileURL;
    this.options = options;
    this.contentMode = contentMode;
    this.builder = wrapBuilder(pagContentBuilder);
  }

  cyl_attach(context: Context | null): void {
    if (this.cyl_isAnimationViewReady || this.loading || this.failed) {
      return;
    }
    this.loading = true;
    CYLPlaceholderAnimationReadFile(this.fileURL, context).then((bytes: Uint8Array) => {
      const file = PAGFile.LoadFromBytes(CYLPlaceholderAnimationArrayBuffer(bytes),
        CYLPlaceholderAnimationFileOfURL(this.fileURL));
      if (file === null) {
        this.didFail('PAG', null);
        return;
      }
      this.controller.setComposition(file);
      this.controller.setScaleMode(pagScaleMode(this.contentMode));
      this.controller.setRepeatCount(this.repeatCount);
      if (this.pendingProgress >= 0) {
        this.controller.setProgress(this.pendingProgress);
        this.pendingProgress = -1;
      } else {
        this.controller.setProgress(0);
      }
      this.controller.flush();
      this.didLoad();
    }).catch((e: Error) => {
      this.didFail('PAG', e);
    });
  }

  seek(progress: number): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingProgress = progress;
      return;
    }
    this.stopDriving();
    this.controller.setProgress(progress);
    this.controller.flush();
  }

  get currentProgress(): number {
    return this.cyl_isAnimationViewReady ? this.controller.getProgress() : 0;
  }

  cyl_playAnimationView(): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingCommand = 1;
      return;
    }
    this.stopDriving();
    this.controller.pause();
    this.playFrom(0, 0);
  }

  cyl_showAnimationViewLastFrame(): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingCommand = 2;
      return;
    }
    this.stopDriving();
    this.controller.pause();
    this.controller.setProgress(1);
    this.controller.flush();
  }

  cyl_stopAnimationView(): void {
    this.pendingCommand = 0;
    this.stopDriving();
    if (!this.cyl_isAnimationViewReady) {
      return;
    }
    this.controller.pause();
    this.controller.setProgress(0);
    this.controller.flush();
  }

  /** libpag's repeat count already means 0 loops and N plays N times (a driven play reads it every tick). */
  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    this.repeatCount = Math.max(0, Math.floor(repeatCount));
    if (this.cyl_isAnimationViewReady) {
      this.controller.setRepeatCount(this.repeatCount);
    }
    return true;
  }

  cyl_detach(): void {
    this.stopDriving();
    if (this.cyl_isAnimationViewReady) {
      this.controller.pause();
    }
  }
}

/** The next state of a driven PAG play. */
export interface CYLPAGDrivenStep {
  progress: number;
  plays: number;
  finished: boolean;
}

/**
 * Advances a driven play by `elapsed` ms at `speed` for a file of `duration` ms: past the end it wraps while plays
 * remain (repeatCount 0 loops forever, N plays N times), else it rests on the last frame and reports finished.
 */
export function CYLPAGDrivenProgress(progress: number, plays: number, elapsed: number, duration: number,
  speed: number, repeatCount: number): CYLPAGDrivenStep {
  if (!(duration > 0) || !(elapsed > 0)) {
    return { progress: progress, plays: plays, finished: false };
  }
  let next = progress + elapsed * speed / duration;
  let done = plays;
  while (next >= 1) {
    done += 1;
    if (repeatCount !== 0 && done >= repeatCount) {
      return { progress: 1, plays: done, finished: true };
    }
    next -= 1;
  }
  return { progress: next, plays: done, finished: false };
}

@Component
struct CYLPAGAnimationComponent {
  @ObjectLink view: CYLPAGAnimationContentView;

  build() {
    Stack() {
      PAGView({ controller: this.view.controller })
    }
    .width(this.view.width)
    .height(this.view.height)
  }
}

@Builder
function pagContentBuilder(view: CYLPlaceholderAnimationContentView) {
  CYLPAGAnimationComponent({ view: view as CYLPAGAnimationContentView })
}

/** The PAG player: play, last frame, stop, progress, speed (driven) and repeat counts (no colors in libpag). */
class CYLPAGPlaceholderItemAnimationPlayer extends CYLPlaceholderItemAnimationBasePlayer {
  private pagView: CYLPAGAnimationContentView;

  constructor(view: CYLPAGAnimationContentView) {
    super(view);
    this.pagView = view;
  }

  play(): void {
    this.pagView.cyl_playAnimationView();
  }

  showLastFrame(): void {
    this.pagView.cyl_showAnimationViewLastFrame();
  }

  stop(): void {
    this.pagView.cyl_stopAnimationView();
  }

  get progress(): number {
    return this.pagView.currentProgress;
  }

  set progress(value: number) {
    this.pagView.seek(Math.min(1, Math.max(0, value)));
  }

  get supportsProgress(): boolean {
    return true;
  }

  get animationSpeed(): number {
    return this.pagView.playbackSpeed;
  }

  set animationSpeed(value: number) {
    this.pagView.cyl_setAnimationViewSpeed(value);
  }

  get supportsAnimationSpeed(): boolean {
    return true;
  }

  setAnimationRepeatCount(repeatCount: number): boolean {
    return this.pagView.cyl_setAnimationViewRepeatCount(repeatCount);
  }

  applyColors(colors: CYLPlaceholderAnimationColors | null, dark: boolean): void {
  }
}

function pagAttributeKeys(): Record<string, string> {
  const keys: Record<string, string> = {};
  keys[CYLPlaceholderItemAnimationURL] = CYLPlaceholderItemPAGURL;
  keys[CYLPlaceholderItemAnimationFilePath] = CYLPlaceholderItemPAGFilePath;
  keys[CYLPlaceholderItemAnimationSize] = CYLPlaceholderItemPAGSize;
  keys[CYLPlaceholderItemAnimationDarkURL] = CYLPlaceholderItemPAGDarkURL;
  keys[CYLPlaceholderItemAnimationDarkFilePath] = CYLPlaceholderItemPAGDarkFilePath;
  return keys;
}

/** Plays ".pag" files with libpag (iOS `CYLPAGPlaceholderItemAnimator`). */
export class CYLPAGPlaceholderItemAnimator implements CYLPlaceholderItemAnimator {
  readonly identifier: string = 'PAG';
  readonly priority: CYLPlaceholderItemAnimatorPriority = CYLPlaceholderItemAnimatorPriorityDefault;
  readonly fileExtensions: string[] = ['pag'];
  readonly attributeKeys: Record<string, string> = pagAttributeKeys();

  canAnimateFileAtURL(URL: string): boolean {
    return this.fileExtensions.includes(CYLPlaceholderAnimationExtensionOfURL(URL));
  }

  animationViewWithURL(URL: string, width: number, height: number,
    contentMode: ImageFit): CYLPlaceholderAnimationContentView | null {
    if (!this.canAnimateFileAtURL(URL)) {
      return null;
    }
    const view = new CYLPAGAnimationContentView(URL, CYLPlaceholderAnimationOptionsOfURL(URL), contentMode);
    view.width = width;
    view.height = height;
    return view;
  }

  playerForAnimationView(view: CYLPlaceholderAnimationContentView): CYLPlaceholderItemAnimationPlayer | null {
    return view instanceof CYLPAGAnimationContentView ?
      new CYLPAGPlaceholderItemAnimationPlayer(view as CYLPAGAnimationContentView) : null;
  }
}
