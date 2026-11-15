// CYLRefreshClassics: the HarmonyOS counterpart of the iOS controls under Custom/Header, Custom/Footer/Auto,
// Custom/Footer/Back, Custom/Trailer and Custom/Cupertino: state texts, the last update time, arrows, spinners and
// frame animations, as models drawn by CYLRefreshView.ets.
import {
  CYLRefreshAutoFooterIdleText,
  CYLRefreshAutoFooterNoMoreDataText,
  CYLRefreshAutoFooterRefreshingText,
  CYLRefreshBackFooterIdleText,
  CYLRefreshBackFooterNoMoreDataText,
  CYLRefreshBackFooterPullingText,
  CYLRefreshBackFooterRefreshingText,
  CYLRefreshComponentAction,
  CYLRefreshConfig,
  CYLRefreshDateFormatter,
  CYLRefreshHeaderIdleText,
  CYLRefreshHeaderLastUpdatedTimeKey,
  CYLRefreshHeaderPullingText,
  CYLRefreshHeaderRefreshingText,
  CYLRefreshLabelLeftInset,
  CYLRefreshLastUpdatedTimeText,
  CYLRefreshLocalizedString,
  CYLRefreshPhase,
  CYLRefreshState,
  CYLRefreshTrailerIdleText,
  CYLRefreshTrailerPullingText
} from './CYLRefreshConst';
import {
  CYLRefreshActivityIndicatorModel,
  CYLRefreshAutoFooterModel,
  CYLRefreshBackFooterModel,
  CYLRefreshComponentModel,
  CYLRefreshHeaderModel,
  CYLRefreshImageViewModel,
  CYLRefreshLabel,
  CYLRefreshScrollViewModel,
  CYLRefreshTargetAction,
  CYLRefreshTrailerModel,
  CYLRefreshViewModel,
  CYLSize
} from './CYLRefreshComponent';
import { CYLRefreshIconAttributes, CYLRefreshIconSize, CYLRefreshIconViewModel } from './CYLRefreshIconView';

/** Formats the last update line from the time (iOS `lastUpdatedTimeText` block). */
export type CYLRefreshLastUpdatedTimeTextBlock = (lastUpdatedTime: Date | null) => string;

/** A control showing an icon animation per state (iOS protocol `CYLRefreshIconAnimating`). */
export interface CYLRefreshIconAnimating {
  readonly iconView: CYLRefreshIconViewModel;
  readonly usesIconView: boolean;
  setIconAnimationAttributes(attributes: CYLRefreshIconAttributes | null, state: CYLRefreshState): CYLRefreshComponentModel;
  setIconAnimationFilePath(filePath: string, size: CYLRefreshIconSize, state: CYLRefreshState): CYLRefreshComponentModel;
  setBundledIconAnimation(fileName: string, size: CYLRefreshIconSize, state: CYLRefreshState): CYLRefreshComponentModel;
}

/** The frame images of an animation control, per state (the iOS stateImages / stateDurations). */
export class CYLRefreshFrames {
  /** The frames shown now, the frame index while pulled, and whether they play (refreshing). */
  images: ResourceStr[] = [];
  index: number = 0;
  animating: boolean = false;
  duration: number = 0;
  private stateImages: Map<CYLRefreshState, ResourceStr[]> = new Map();
  private stateDurations: Map<CYLRefreshState, number> = new Map();

  set(images: ResourceStr[], duration: number, state: CYLRefreshState): void {
    if (images.length === 0) {
      return;
    }
    this.stateImages.set(state, images.slice());
    this.stateDurations.set(state, duration);
  }

  imagesFor(state: CYLRefreshState): ResourceStr[] {
    const images = this.stateImages.get(state);
    return images !== undefined ? images : [];
  }

  /** The state changed: Pulling / Refreshing show their frames (playing when more than one). */
  update(state: CYLRefreshState): void {
    if (state === CYLRefreshState.Pulling || state === CYLRefreshState.Refreshing) {
      const images = this.imagesFor(state);
      if (images.length === 0) {
        return;
      }
      this.images = images;
      this.index = 0;
      const d = this.stateDurations.get(state);
      this.duration = d !== undefined ? d : images.length * 0.1;
      this.animating = images.length > 1;
    } else if (state === CYLRefreshState.Idle) {
      this.animating = false;
    }
  }

  /** The pull moved: at Idle the Idle frames follow it. */
  scrub(state: CYLRefreshState, pullingPercent: number): void {
    const images = this.imagesFor(CYLRefreshState.Idle);
    if (state !== CYLRefreshState.Idle || images.length === 0) {
      return;
    }
    this.images = images;
    this.animating = false;
    const p = Math.min(1, Math.max(0, pullingPercent));
    this.index = Math.min(images.length - 1, Math.floor(p * images.length));
  }
}

function titlesText(titles: Map<CYLRefreshState, string>, state: CYLRefreshState): string {
  const t = titles.get(state);
  return t !== undefined ? t : '';
}

// MARK: - Headers

/** A header with a state text and the last update time (iOS `CYLRefreshStateHeader`). */
export class CYLRefreshStateHeaderModel extends CYLRefreshHeaderModel {
  /** iOS `flipsHorizontallyInOppositeLayoutDirectionViews`: adds the state and time labels. */
  protected cyl_flipViews(): CYLRefreshViewModel[] {
    return [this.stateLabel, this.lastUpdatedTimeLabel];
  }

  /** The state text (`stateLabel`). */
  stateLabel: CYLRefreshLabel = CYLRefreshLabel.cyl_label();
  /** The last update line (`lastUpdatedTimeLabel`). */
  lastUpdatedTimeLabel: CYLRefreshLabel = CYLRefreshLabel.cyl_label();
  /** The gap between the text and the arrow / spinner (`labelLeftInset`). */
  labelLeftInset: number = CYLRefreshLabelLeftInset;
  /** The gap between the two lines; 0 splits the height in halves (`titleTimeSpacing`). */
  titleTimeSpacing: number = 0;
  /** Shown beside the text while a successful refresh holds `finishDuration` (`succeededImage`). */
  succeededImage: ResourceStr | null = null;
  /** Shown while a failed refresh holds (`failedImage`). */
  failedImage: ResourceStr | null = null;
  /** Puts the icon after the text instead of before (`iconOnTrailingSide`). */
  iconOnTrailingSide: boolean = false;
  protected stateTitles: Map<CYLRefreshState, string> = new Map();
  private timeTextBlock: CYLRefreshLastUpdatedTimeTextBlock | null = null;
  private timeFormatter: CYLRefreshDateFormatter | null = null;

  constructor() {
    super();
    this.textConfiguration();
  }

  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshStateHeaderModel {
    const header = new CYLRefreshStateHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  static headerWithRefreshingTarget(target: Object, action: CYLRefreshTargetAction): CYLRefreshStateHeaderModel {
    const header = new CYLRefreshStateHeaderModel();
    header.setRefreshingTarget(target, action);
    return header;
  }

  /** Builds the last update line from the time, replacing the built-in format (`lastUpdatedTimeText`). */
  get lastUpdatedTimeText(): CYLRefreshLastUpdatedTimeTextBlock | null {
    return this.timeTextBlock;
  }

  set lastUpdatedTimeText(block: CYLRefreshLastUpdatedTimeTextBlock | null) {
    this.timeTextBlock = block;
    this.lastUpdatedTimeKey = this.lastUpdatedTimeKey;
  }

  /** Formats the date part of the last update line (`lastUpdatedTimeFormatter`). */
  get lastUpdatedTimeFormatter(): CYLRefreshDateFormatter | null {
    return this.timeFormatter;
  }

  set lastUpdatedTimeFormatter(formatter: CYLRefreshDateFormatter | null) {
    this.timeFormatter = formatter;
    this.lastUpdatedTimeKey = this.lastUpdatedTimeKey;
  }

  /** The last update line shown, or null when hidden (`lastUpdatedTimeString`). */
  get lastUpdatedTimeString(): string | null {
    return this.lastUpdatedTimeLabel.hidden ? null : this.lastUpdatedTimeLabel.text;
  }

  /** Sets the text of a state (`-setTitle:forState:`). */
  setTitle(title: string, state: CYLRefreshState): CYLRefreshStateHeaderModel {
    this.stateTitles.set(state, title);
    this.stateLabel.text = titlesText(this.stateTitles, this.state);
    this.cyl_setNeedsLayout();
    return this;
  }

  /** Sets lastUpdatedTimeText (`-cyl_modifyLastUpdatedTimeText:`). */
  cyl_modifyLastUpdatedTimeText(handler: CYLRefreshLastUpdatedTimeTextBlock): CYLRefreshStateHeaderModel {
    this.lastUpdatedTimeText = handler;
    return this;
  }

  /** The result image while finishing, else null. */
  get cyl_resultImage(): ResourceStr | null {
    if (this.phase !== CYLRefreshPhase.Finishing) {
      return null;
    }
    return this.lastRefreshSucceeded ? this.succeededImage : this.failedImage;
  }

  cyl_lastUpdatedTimeKeyDidChange(): void {
    if (this.lastUpdatedTimeLabel === undefined || this.lastUpdatedTimeLabel.hidden) {
      return;
    }
    const time = this.lastUpdatedTime;
    this.lastUpdatedTimeLabel.text = this.timeTextBlock !== null ? this.timeTextBlock(time) :
      CYLRefreshLastUpdatedTimeText(time, new Date(), this.timeFormatter);
    this.cyl_setNeedsLayout();
  }

  protected textConfiguration(): void {
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshHeaderIdleText), CYLRefreshState.Idle);
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshHeaderPullingText), CYLRefreshState.Pulling);
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshHeaderRefreshingText), CYLRefreshState.Refreshing);
    this.lastUpdatedTimeKey = CYLRefreshHeaderLastUpdatedTimeKey;
  }

  i18nDidChange(): void {
    this.textConfiguration();
    super.i18nDidChange();
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    this.stateLabel.text = titlesText(this.stateTitles, state);
  }
}

/** A state header with an arrow and a spinner (iOS `CYLRefreshNormalHeader`). */
export class CYLRefreshNormalHeaderModel extends CYLRefreshStateHeaderModel {
  /** iOS `flipsHorizontallyInOppositeLayoutDirectionViews`: adds the arrow. */
  protected cyl_flipViews(): CYLRefreshViewModel[] {
    return super.cyl_flipViews().concat([this.arrowView]);
  }

  /** The arrow (`arrowView`); its image is the bundled arrow when null. */
  arrowView: CYLRefreshImageViewModel = new CYLRefreshImageViewModel();
  /** The arrow's size; 0 x 0 for the image's own (15 x 40) (`iconSize`). */
  iconSize: CYLSize = new CYLSize(0, 0);
  /** The spinner (`loadingView`). */
  loadingView: CYLRefreshActivityIndicatorModel = new CYLRefreshActivityIndicatorModel();
  /** Deprecated (`activityIndicatorViewStyle`); kept. */
  activityIndicatorViewStyle: number = 0;

  constructor() {
    super();
    this.loadingView.hidden = true;
  }

  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshNormalHeaderModel {
    const header = new CYLRefreshNormalHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  static headerWithRefreshingTarget(target: Object, action: CYLRefreshTargetAction): CYLRefreshNormalHeaderModel {
    const header = new CYLRefreshNormalHeaderModel();
    header.setRefreshingTarget(target, action);
    return header;
  }

  static attach(scrollView: CYLRefreshScrollViewModel): CYLRefreshNormalHeaderModel {
    const header = new CYLRefreshNormalHeaderModel();
    header.attach(scrollView);
    return header;
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.arrowView === undefined) {
      return;
    }
    if (state === CYLRefreshState.Idle) {
      this.loadingView.stopAnimating();
      this.arrowView.hidden = false;
      this.arrowView.rotation = 0;
    } else if (state === CYLRefreshState.Pulling) {
      this.loadingView.stopAnimating();
      this.arrowView.hidden = false;
      this.arrowView.rotation = 180;
    } else if (state === CYLRefreshState.Refreshing || state === CYLRefreshState.WillRefresh) {
      this.loadingView.startAnimating();
      this.arrowView.hidden = true;
    }
    this.cyl_updateIconViewVisible(true, [this.arrowView, this.loadingView]);
  }
}

/** A state header with frame images per state (iOS `CYLRefreshAnimationHeader`). */
export class CYLRefreshAnimationHeaderModel extends CYLRefreshStateHeaderModel implements CYLRefreshIconAnimating {
  /** iOS `flipsHorizontallyInOppositeLayoutDirectionViews`: adds the animation view. */
  protected cyl_flipViews(): CYLRefreshViewModel[] {
    return super.cyl_flipViews().concat([this.animationView]);
  }

  /** The frame view (`animationView`). */
  animationView: CYLRefreshImageViewModel = new CYLRefreshImageViewModel();
  /** The frames per state. */
  frames: CYLRefreshFrames = new CYLRefreshFrames();

  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshAnimationHeaderModel {
    const header = new CYLRefreshAnimationHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  /** Frames of a state played over `duration` seconds (`-setAnimationImages:duration:forState:`). */
  setAnimationImages(images: ResourceStr[], duration: number, state: CYLRefreshState): CYLRefreshAnimationHeaderModel {
    this.frames.set(images, duration, state);
    this.frames.update(this.state);
    this.cyl_setNeedsLayout();
    return this;
  }

  /** Frames of a state, 0.1 s each (`-setAnimationImages:forState:`). */
  setAnimationImagesForState(images: ResourceStr[], state: CYLRefreshState): CYLRefreshAnimationHeaderModel {
    return this.setAnimationImages(images, images.length * 0.1, state);
  }

  get iconView(): CYLRefreshIconViewModel {
    return this.cyl_iconView;
  }

  get usesIconView(): boolean {
    return this.cyl_usesIconView;
  }

  setIconAnimationAttributes(attributes: CYLRefreshIconAttributes | null, state: CYLRefreshState): CYLRefreshComponentModel {
    this.cyl_setIconAnimationAttributes(attributes, state);
    return this;
  }

  setIconAnimationFilePath(filePath: string, size: CYLRefreshIconSize, state: CYLRefreshState): CYLRefreshComponentModel {
    return this.setIconAnimationAttributes(CYLRefreshIconViewModel.attributesForAnimationFilePath(filePath, size), state);
  }

  setBundledIconAnimation(fileName: string, size: CYLRefreshIconSize, state: CYLRefreshState): CYLRefreshComponentModel {
    return this.setIconAnimationAttributes(CYLRefreshIconViewModel.attributesForBundledAnimation(fileName, size), state);
  }

  /** The bundled animations (`bundledIconAnimationFileNames`). */
  static get bundledIconAnimationFileNames(): string[] {
    return CYLRefreshIconViewModel.bundledAnimationFileNames;
  }

  cyl_pullingPercentDidChange(): void {
    super.cyl_pullingPercentDidChange();
    if (this.frames !== undefined) {
      this.frames.scrub(this.state, this.pullingPercent);
    }
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.frames !== undefined) {
      this.frames.update(state);
      this.cyl_updateIconViewVisible(true, [this.animationView]);
    }
  }
}

/** iOS `CYLRefreshGifHeader`: the animation header with the GIF names. */
export class CYLRefreshGifHeaderModel extends CYLRefreshAnimationHeaderModel {
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshGifHeaderModel {
    const header = new CYLRefreshGifHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  /** The frame view (`gifView`). */
  get gifView(): CYLRefreshImageViewModel {
    return this.animationView;
  }

  /** `-setImages:duration:forState:`. */
  setImages(images: ResourceStr[], duration: number, state: CYLRefreshState): CYLRefreshGifHeaderModel {
    this.setAnimationImages(images, duration, state);
    return this;
  }

  /** `-setImages:forState:`. */
  setImagesForState(images: ResourceStr[], state: CYLRefreshState): CYLRefreshGifHeaderModel {
    this.setAnimationImagesForState(images, state);
    return this;
  }
}

/** A header with an iOS-style spinner that fills as it is pulled (iOS `CYLRefreshCupertinoHeader`). */
export class CYLRefreshCupertinoHeaderModel extends CYLRefreshHeaderModel {
  /** The spinner (`activityIndicator`). */
  activityIndicator: CYLRefreshActivityIndicatorModel = new CYLRefreshActivityIndicatorModel();

  constructor() {
    super();
    this.cyl_h = 60;
    this.activityIndicator.hidesWhenStopped = false;
  }

  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshCupertinoHeaderModel {
    const header = new CYLRefreshCupertinoHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  cyl_pullingPercentDidChange(): void {
    super.cyl_pullingPercentDidChange();
    if (this.activityIndicator !== undefined && !this.activityIndicator.animating) {
      this.activityIndicator.progress = Math.min(1, Math.max(0, this.pullingPercent));
    }
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.activityIndicator === undefined) {
      return;
    }
    if (state === CYLRefreshState.Refreshing || state === CYLRefreshState.WillRefresh) {
      this.activityIndicator.startAnimating();
    } else {
      this.activityIndicator.stopAnimating();
    }
  }
}

// MARK: - Auto footers

/** An auto footer with a state text; tapping it loads (iOS `CYLRefreshAutoStateFooter`). */
export class CYLRefreshAutoStateFooterModel extends CYLRefreshAutoFooterModel {
  /** iOS `flipsHorizontallyInOppositeLayoutDirectionViews`: adds the state label. */
  protected cyl_flipViews(): CYLRefreshViewModel[] {
    return [this.stateLabel];
  }

  labelLeftInset: number = CYLRefreshLabelLeftInset;
  stateLabel: CYLRefreshLabel = CYLRefreshLabel.cyl_label();
  /** Hides the text while loading (`refreshingTitleHidden`). */
  refreshingTitleHidden: boolean = false;
  protected stateTitles: Map<CYLRefreshState, string> = new Map();

  constructor() {
    super();
    this.textConfiguration();
  }

  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshAutoStateFooterModel {
    const footer = new CYLRefreshAutoStateFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  /** `-setTitle:forState:`. */
  setTitle(title: string, state: CYLRefreshState): CYLRefreshAutoStateFooterModel {
    this.stateTitles.set(state, title);
    this.cyl_updateStateText();
    return this;
  }

  /** The text of a state. */
  titleForState(state: CYLRefreshState): string {
    return titlesText(this.stateTitles, state);
  }

  /** The state label was tapped: an idle footer loads. */
  stateLabelClick(): void {
    if (this.state === CYLRefreshState.Idle) {
      this.beginRefreshing();
    }
  }

  protected textConfiguration(): void {
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshAutoFooterIdleText), CYLRefreshState.Idle);
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshAutoFooterRefreshingText), CYLRefreshState.Refreshing);
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshAutoFooterNoMoreDataText), CYLRefreshState.NoMoreData);
  }

  private cyl_updateStateText(): void {
    this.stateLabel.text = this.refreshingTitleHidden && this.state === CYLRefreshState.Refreshing ? '' :
      titlesText(this.stateTitles, this.state);
    this.cyl_setNeedsLayout();
  }

  i18nDidChange(): void {
    this.textConfiguration();
    super.i18nDidChange();
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.stateTitles !== undefined) {
      this.cyl_updateStateText();
    }
  }
}

/** An auto footer with a spinner (iOS `CYLRefreshAutoNormalFooter`). */
export class CYLRefreshAutoNormalFooterModel extends CYLRefreshAutoStateFooterModel {
  loadingView: CYLRefreshActivityIndicatorModel = new CYLRefreshActivityIndicatorModel();
  /** Shown in place of the spinner with no more data (`noMoreDataImage`). */
  noMoreDataImage: ResourceStr | null = null;
  activityIndicatorViewStyle: number = 0;

  constructor() {
    super();
    this.loadingView.hidden = true;
  }

  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshAutoNormalFooterModel {
    const footer = new CYLRefreshAutoNormalFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  static attach(scrollView: CYLRefreshScrollViewModel): CYLRefreshAutoNormalFooterModel {
    const footer = new CYLRefreshAutoNormalFooterModel();
    footer.attach(scrollView);
    return footer;
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.loadingView === undefined) {
      return;
    }
    if (state === CYLRefreshState.Refreshing) {
      this.loadingView.startAnimating();
    } else {
      this.loadingView.stopAnimating();
    }
  }
}

/** An auto footer with frame images (iOS `CYLRefreshAutoAnimationFooter`). */
export class CYLRefreshAutoAnimationFooterModel extends CYLRefreshAutoStateFooterModel implements CYLRefreshIconAnimating {
  /** iOS `flipsHorizontallyInOppositeLayoutDirectionViews`: adds the animation view. */
  protected cyl_flipViews(): CYLRefreshViewModel[] {
    return super.cyl_flipViews().concat([this.animationView]);
  }

  animationView: CYLRefreshImageViewModel = new CYLRefreshImageViewModel();
  frames: CYLRefreshFrames = new CYLRefreshFrames();

  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshAutoAnimationFooterModel {
    const footer = new CYLRefreshAutoAnimationFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  setAnimationImages(images: ResourceStr[], duration: number, state: CYLRefreshState): CYLRefreshAutoAnimationFooterModel {
    this.frames.set(images, duration, state);
    this.frames.update(this.state);
    this.cyl_setNeedsLayout();
    return this;
  }

  setAnimationImagesForState(images: ResourceStr[], state: CYLRefreshState): CYLRefreshAutoAnimationFooterModel {
    return this.setAnimationImages(images, images.length * 0.1, state);
  }

  get iconView(): CYLRefreshIconViewModel {
    return this.cyl_iconView;
  }

  get usesIconView(): boolean {
    return this.cyl_usesIconView;
  }

  setIconAnimationAttributes(attributes: CYLRefreshIconAttributes | null, state: CYLRefreshState): CYLRefreshComponentModel {
    this.cyl_setIconAnimationAttributes(attributes, state);
    return this;
  }

  setIconAnimationFilePath(filePath: string, size: CYLRefreshIconSize, state: CYLRefreshState): CYLRefreshComponentModel {
    return this.setIconAnimationAttributes(CYLRefreshIconViewModel.attributesForAnimationFilePath(filePath, size), state);
  }

  setBundledIconAnimation(fileName: string, size: CYLRefreshIconSize, state: CYLRefreshState): CYLRefreshComponentModel {
    return this.setIconAnimationAttributes(CYLRefreshIconViewModel.attributesForBundledAnimation(fileName, size), state);
  }

  static get bundledIconAnimationFileNames(): string[] {
    return CYLRefreshIconViewModel.bundledAnimationFileNames;
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.frames !== undefined) {
      this.frames.update(state);
      this.cyl_updateIconViewVisible(true, [this.animationView]);
    }
  }
}

/** iOS `CYLRefreshAutoGifFooter`. */
export class CYLRefreshAutoGifFooterModel extends CYLRefreshAutoAnimationFooterModel {
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshAutoGifFooterModel {
    const footer = new CYLRefreshAutoGifFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  get gifView(): CYLRefreshImageViewModel {
    return this.animationView;
  }

  setImages(images: ResourceStr[], duration: number, state: CYLRefreshState): CYLRefreshAutoGifFooterModel {
    this.setAnimationImages(images, duration, state);
    return this;
  }

  setImagesForState(images: ResourceStr[], state: CYLRefreshState): CYLRefreshAutoGifFooterModel {
    this.setAnimationImagesForState(images, state);
    return this;
  }
}

/** An auto footer with an iOS-style spinner (iOS `CYLRefreshCupertinoFooter`). */
export class CYLRefreshCupertinoFooterModel extends CYLRefreshAutoFooterModel {
  activityIndicator: CYLRefreshActivityIndicatorModel = new CYLRefreshActivityIndicatorModel();

  constructor() {
    super();
    this.activityIndicator.hidden = true;
  }

  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshCupertinoFooterModel {
    const footer = new CYLRefreshCupertinoFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.activityIndicator === undefined) {
      return;
    }
    if (state === CYLRefreshState.Refreshing) {
      this.activityIndicator.startAnimating();
    } else {
      this.activityIndicator.stopAnimating();
    }
  }
}

// MARK: - Back footers

/** A back footer with a state text (iOS `CYLRefreshBackStateFooter`). */
export class CYLRefreshBackStateFooterModel extends CYLRefreshBackFooterModel {
  /** iOS `flipsHorizontallyInOppositeLayoutDirectionViews`: adds the state label. */
  protected cyl_flipViews(): CYLRefreshViewModel[] {
    return [this.stateLabel];
  }

  labelLeftInset: number = CYLRefreshLabelLeftInset;
  stateLabel: CYLRefreshLabel = CYLRefreshLabel.cyl_label();
  protected stateTitles: Map<CYLRefreshState, string> = new Map();

  constructor() {
    super();
    this.textConfiguration();
  }

  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshBackStateFooterModel {
    const footer = new CYLRefreshBackStateFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  setTitle(title: string, state: CYLRefreshState): CYLRefreshBackStateFooterModel {
    this.stateTitles.set(state, title);
    this.stateLabel.text = titlesText(this.stateTitles, this.state);
    this.cyl_setNeedsLayout();
    return this;
  }

  /** The text of a state (`-titleForState:`). */
  titleForState(state: CYLRefreshState): string {
    return titlesText(this.stateTitles, state);
  }

  protected textConfiguration(): void {
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshBackFooterIdleText), CYLRefreshState.Idle);
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshBackFooterPullingText), CYLRefreshState.Pulling);
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshBackFooterRefreshingText), CYLRefreshState.Refreshing);
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshBackFooterNoMoreDataText), CYLRefreshState.NoMoreData);
  }

  i18nDidChange(): void {
    this.textConfiguration();
    super.i18nDidChange();
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.stateTitles !== undefined) {
      this.stateLabel.text = titlesText(this.stateTitles, state);
    }
  }
}

/** A back footer with an arrow and a spinner (iOS `CYLRefreshBackNormalFooter`). */
export class CYLRefreshBackNormalFooterModel extends CYLRefreshBackStateFooterModel {
  /** iOS `flipsHorizontallyInOppositeLayoutDirectionViews`: adds the arrow. */
  protected cyl_flipViews(): CYLRefreshViewModel[] {
    return super.cyl_flipViews().concat([this.arrowView]);
  }

  arrowView: CYLRefreshImageViewModel = new CYLRefreshImageViewModel();
  loadingView: CYLRefreshActivityIndicatorModel = new CYLRefreshActivityIndicatorModel();
  noMoreDataImage: ResourceStr | null = null;
  iconSize: CYLSize = new CYLSize(0, 0);
  activityIndicatorViewStyle: number = 0;

  constructor() {
    super();
    this.loadingView.hidden = true;
    this.arrowView.rotation = 180;
  }

  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshBackNormalFooterModel {
    const footer = new CYLRefreshBackNormalFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  static attach(scrollView: CYLRefreshScrollViewModel): CYLRefreshBackNormalFooterModel {
    const footer = new CYLRefreshBackNormalFooterModel();
    footer.attach(scrollView);
    return footer;
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.arrowView === undefined) {
      return;
    }
    if (state === CYLRefreshState.Idle) {
      this.loadingView.stopAnimating();
      this.arrowView.hidden = false;
      this.arrowView.rotation = 180;
    } else if (state === CYLRefreshState.Pulling) {
      this.loadingView.stopAnimating();
      this.arrowView.hidden = false;
      this.arrowView.rotation = 0;
    } else if (state === CYLRefreshState.Refreshing) {
      this.loadingView.startAnimating();
      this.arrowView.hidden = true;
    } else if (state === CYLRefreshState.NoMoreData) {
      this.loadingView.stopAnimating();
      this.arrowView.hidden = true;
    }
    this.cyl_updateIconViewVisible(true, [this.arrowView, this.loadingView]);
  }
}

/** A back footer with frame images (iOS `CYLRefreshBackAnimationFooter`). */
export class CYLRefreshBackAnimationFooterModel extends CYLRefreshBackStateFooterModel implements CYLRefreshIconAnimating {
  /** iOS `flipsHorizontallyInOppositeLayoutDirectionViews`: adds the animation view. */
  protected cyl_flipViews(): CYLRefreshViewModel[] {
    return super.cyl_flipViews().concat([this.animationView]);
  }

  animationView: CYLRefreshImageViewModel = new CYLRefreshImageViewModel();
  frames: CYLRefreshFrames = new CYLRefreshFrames();

  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshBackAnimationFooterModel {
    const footer = new CYLRefreshBackAnimationFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  setAnimationImages(images: ResourceStr[], duration: number, state: CYLRefreshState): CYLRefreshBackAnimationFooterModel {
    this.frames.set(images, duration, state);
    this.frames.update(this.state);
    this.cyl_setNeedsLayout();
    return this;
  }

  setAnimationImagesForState(images: ResourceStr[], state: CYLRefreshState): CYLRefreshBackAnimationFooterModel {
    return this.setAnimationImages(images, images.length * 0.1, state);
  }

  get iconView(): CYLRefreshIconViewModel {
    return this.cyl_iconView;
  }

  get usesIconView(): boolean {
    return this.cyl_usesIconView;
  }

  setIconAnimationAttributes(attributes: CYLRefreshIconAttributes | null, state: CYLRefreshState): CYLRefreshComponentModel {
    this.cyl_setIconAnimationAttributes(attributes, state);
    return this;
  }

  setIconAnimationFilePath(filePath: string, size: CYLRefreshIconSize, state: CYLRefreshState): CYLRefreshComponentModel {
    return this.setIconAnimationAttributes(CYLRefreshIconViewModel.attributesForAnimationFilePath(filePath, size), state);
  }

  setBundledIconAnimation(fileName: string, size: CYLRefreshIconSize, state: CYLRefreshState): CYLRefreshComponentModel {
    return this.setIconAnimationAttributes(CYLRefreshIconViewModel.attributesForBundledAnimation(fileName, size), state);
  }

  static get bundledIconAnimationFileNames(): string[] {
    return CYLRefreshIconViewModel.bundledAnimationFileNames;
  }

  cyl_pullingPercentDidChange(): void {
    super.cyl_pullingPercentDidChange();
    if (this.frames !== undefined) {
      this.frames.scrub(this.state, this.pullingPercent);
    }
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.frames !== undefined) {
      this.frames.update(state);
      this.cyl_updateIconViewVisible(true, [this.animationView]);
    }
  }
}

/** iOS `CYLRefreshBackGifFooter`. */
export class CYLRefreshBackGifFooterModel extends CYLRefreshBackAnimationFooterModel {
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshBackGifFooterModel {
    const footer = new CYLRefreshBackGifFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  get gifView(): CYLRefreshImageViewModel {
    return this.animationView;
  }

  setImages(images: ResourceStr[], duration: number, state: CYLRefreshState): CYLRefreshBackGifFooterModel {
    this.setAnimationImages(images, duration, state);
    return this;
  }

  setImagesForState(images: ResourceStr[], state: CYLRefreshState): CYLRefreshBackGifFooterModel {
    this.setAnimationImagesForState(images, state);
    return this;
  }
}

// MARK: - Trailers

/** A trailer with a vertical state text (iOS `CYLRefreshStateTrailer`). */
export class CYLRefreshStateTrailerModel extends CYLRefreshTrailerModel {
  stateLabel: CYLRefreshLabel = CYLRefreshLabel.cyl_label();
  protected stateTitles: Map<CYLRefreshState, string> = new Map();

  constructor() {
    super();
    this.textConfiguration();
  }

  static trailerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshStateTrailerModel {
    const trailer = new CYLRefreshStateTrailerModel();
    trailer.refreshingBlock = block;
    return trailer;
  }

  setTitle(title: string, state: CYLRefreshState): CYLRefreshStateTrailerModel {
    this.stateTitles.set(state, title);
    this.stateLabel.text = titlesText(this.stateTitles, this.state);
    this.cyl_setNeedsLayout();
    return this;
  }

  /** Places the (vertical) state label centered at `centerX`; returns its width (`-cyl_placeStateLabelAtCenterX:`). */
  cyl_placeStateLabelAtCenterX(centerX: number): number {
    const width = Math.ceil(this.stateLabel.fontSize * 1.2);
    this.stateLabel.cyl_w = width;
    this.stateLabel.cyl_h = this.cyl_h;
    this.stateLabel.cyl_x = centerX - width / 2;
    this.stateLabel.cyl_y = 0;
    return width;
  }

  protected textConfiguration(): void {
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshTrailerIdleText), CYLRefreshState.Idle);
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshTrailerPullingText), CYLRefreshState.Pulling);
    this.setTitle(CYLRefreshLocalizedString(CYLRefreshTrailerPullingText), CYLRefreshState.Refreshing);
  }

  i18nDidChange(): void {
    this.textConfiguration();
    super.i18nDidChange();
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.stateTitles !== undefined) {
      this.stateLabel.text = titlesText(this.stateTitles, state);
    }
  }
}

/** A state trailer with an arrow (iOS `CYLRefreshNormalTrailer`). */
export class CYLRefreshNormalTrailerModel extends CYLRefreshStateTrailerModel {
  /** iOS `flipsHorizontallyInOppositeLayoutDirectionViews`: adds the arrow. */
  protected cyl_flipViews(): CYLRefreshViewModel[] {
    return super.cyl_flipViews().concat([this.arrowView]);
  }

  /** The arrow (`arrowView`); the bundled trail arrow when its image is null. */
  arrowView: CYLRefreshImageViewModel = new CYLRefreshImageViewModel();

  static trailerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshNormalTrailerModel {
    const trailer = new CYLRefreshNormalTrailerModel();
    trailer.refreshingBlock = block;
    return trailer;
  }

  static attach(scrollView: CYLRefreshScrollViewModel): CYLRefreshNormalTrailerModel {
    const trailer = new CYLRefreshNormalTrailerModel();
    trailer.attach(scrollView);
    return trailer;
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.arrowView === undefined) {
      return;
    }
    this.arrowView.rotation = state === CYLRefreshState.Pulling || state === CYLRefreshState.Refreshing ? 180 : 0;
  }
}

/** Keeps CYLRefreshConfig imported for the language observer side effect in apps importing only the classics. */
export const CYLRefreshClassicsConfig: CYLRefreshConfig = CYLRefreshConfig.defaultConfig;
