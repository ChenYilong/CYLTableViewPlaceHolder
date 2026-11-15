// iOS CYLPAGPlaceholderItemAnimator: plays ".pag" files with Tencent's official libpag for OpenHarmony
// (@tencent/libpag: PAGFile.LoadFromBytes + PAGViewController + PAGView). libpag has no playback speed.
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
    this.controller.pause();
    this.controller.setRepeatCount(this.repeatCount);
    this.controller.setProgress(0);
    this.controller.play();
  }

  cyl_showAnimationViewLastFrame(): void {
    if (!this.cyl_isAnimationViewReady) {
      this.pendingCommand = 2;
      return;
    }
    this.controller.pause();
    this.controller.setProgress(1);
    this.controller.flush();
  }

  cyl_stopAnimationView(): void {
    this.pendingCommand = 0;
    if (!this.cyl_isAnimationViewReady) {
      return;
    }
    this.controller.pause();
    this.controller.setProgress(0);
    this.controller.flush();
  }

  /** libpag's repeat count already means 0 loops and N plays N times. */
  cyl_setAnimationViewRepeatCount(repeatCount: number): boolean {
    this.repeatCount = Math.max(0, Math.floor(repeatCount));
    if (this.cyl_isAnimationViewReady) {
      this.controller.setRepeatCount(this.repeatCount);
    }
    return true;
  }

  cyl_detach(): void {
    if (this.cyl_isAnimationViewReady) {
      this.controller.pause();
    }
  }
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

/** The PAG player: play, last frame, stop, progress and repeat counts (no speed or colors in libpag). */
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
