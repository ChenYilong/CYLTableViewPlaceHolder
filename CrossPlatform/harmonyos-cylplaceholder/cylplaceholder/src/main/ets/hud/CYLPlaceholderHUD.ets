// The HarmonyOS counterpart of iOS CYLPlaceholderHUD (the SVProgressHUD-style API), with the state and timing of
// android/placeholder's CYLPlaceholderHUD.kt: show, show with a status, show a progress, success / error / info / an
// image (dismissed after displayDurationForString), components and scenarios, popActivity, dismiss (now, after a delay,
// with a completion), styles, mask types, custom colors, grace and dismiss times, haptics and the appear / disappear
// notifications. This class keeps the state; CYLPlaceholderHUDView.ets draws it in a global overlay (a ComponentContent
// on the UIContext's OverlayManager), so it can be called from anywhere, like the iOS class methods. The shared HUD
// needs its container once, as on Android:
//
//   aboutToAppear() { CYLPlaceholderSharedHUD().containerView = this.getUIContext(); }
//   ...
//   CYLPlaceholderHUD.showWithStatus('Loading');
//   CYLPlaceholderHUD.showSuccessWithStatus('Saved');
import { UIContext } from '@kit.ArkUI';
import { CYLPlaceholderViewModel } from '../CYLPlaceholderView';
import { CYLPlaceholderActionHandler, CYLPlaceholderStackViewModel } from '../CYLPlaceholderStackView';
import { CYLPlaceholderAction, CYLPlaceholderComponent, CYLPlaceholderScenario } from '../CYLPlaceholderScenario';
import { CYLPlaceholderIconNameForStyle, CYLPlaceholderStyle } from '../CYLPlaceholderViewTypes';

/** The built-in loading animation (iOS default of `loadingAnimationFileName`). */
const DEFAULT_LOADING_ANIMATION = 'CYLRefreshActivity.gif';

/** Posted before the HUD fades in (iOS `CYLPlaceholderHUDWillAppearNotification`). */
export const CYLPlaceholderHUDWillAppearNotification: string = 'CYLPlaceholderHUDWillAppearNotification';
/** Posted once it has faded in (iOS `CYLPlaceholderHUDDidAppearNotification`). */
export const CYLPlaceholderHUDDidAppearNotification: string = 'CYLPlaceholderHUDDidAppearNotification';
/** Posted before it fades out (iOS `CYLPlaceholderHUDWillDisappearNotification`). */
export const CYLPlaceholderHUDWillDisappearNotification: string = 'CYLPlaceholderHUDWillDisappearNotification';
/** Posted once it is gone (iOS `CYLPlaceholderHUDDidDisappearNotification`). */
export const CYLPlaceholderHUDDidDisappearNotification: string = 'CYLPlaceholderHUDDidDisappearNotification';
/** Posted on a touch of the mask (iOS `CYLPlaceholderHUDDidReceiveTouchEventNotification`). */
export const CYLPlaceholderHUDDidReceiveTouchEventNotification: string =
  'CYLPlaceholderHUDDidReceiveTouchEventNotification';
/** Posted on a touch of the box (iOS `CYLPlaceholderHUDDidTouchDownInsideNotification`). */
export const CYLPlaceholderHUDDidTouchDownInsideNotification: string =
  'CYLPlaceholderHUDDidTouchDownInsideNotification';
/** The user-info key of the status in the notifications (iOS `CYLPlaceholderHUDStatusUserInfoKey`). */
export const CYLPlaceholderHUDStatusUserInfoKey: string = 'CYLPlaceholderHUDStatusUserInfoKey';

/** The HUD's colors (iOS `CYLPlaceholderHUDStyle`). */
export enum CYLPlaceholderHUDStyle {
  /** Follows the light or dark appearance (the default). */
  Automatic,
  /** A light box with dark content. */
  Light,
  /** A dark box with light content. */
  Dark,
  /** foregroundColor on hudBackgroundColor; setting either selects it. */
  Custom
}

/** What covers the screen behind the box (iOS `CYLPlaceholderHUDMaskType`). */
export enum CYLPlaceholderHUDMaskType {
  /** No mask: touches outside the box reach the page (the default). */
  None,
  /** A clear mask that blocks touches. */
  Clear,
  /** A dimming mask that blocks touches. */
  Black,
  /** A radial dimming gradient that blocks touches. */
  Gradient,
  /** backgroundLayerColor, blocking touches. */
  Custom
}

/** What the HUD shows (iOS `CYLPlaceholderHUDState`). */
export enum CYLPlaceholderHUDState {
  Hidden,
  Loading,
  Progress,
  Success,
  Error,
  Info,
  Image,
  Custom
}

/** Runs once the HUD has disappeared (iOS `CYLPlaceholderHUDDismissCompletion`). */
export type CYLPlaceholderHUDDismissCompletion = () => void;

/** Hears a HUD notification: its name, the HUD and the status (the CYLPlaceholderHUDStatusUserInfoKey value). */
export type CYLPlaceholderHUDObserver = (name: string, hud: CYLPlaceholderHUD, status: string | null) => void;

/** Draws a HUD (CYLPlaceholderHUDView.ets installs the overlay presenter). */
export interface CYLPlaceholderHUDPresenter {
  /** Puts the HUD on screen (once per appearance). */
  present: (hud: CYLPlaceholderHUD) => void;
  /** Takes it off screen. */
  remove: (hud: CYLPlaceholderHUD) => void;
  /** Plays the success / error haptic. */
  haptic: (hud: CYLPlaceholderHUD, state: CYLPlaceholderHUDState) => void;
}

/** The timers of a HUD (replaceable for tests). */
export interface CYLPlaceholderHUDScheduler {
  schedule: (callback: () => void, milliseconds: number) => number;
  cancel: (id: number) => void;
}

class SystemScheduler implements CYLPlaceholderHUDScheduler {
  schedule: (callback: () => void, milliseconds: number) => number = (callback: () => void, milliseconds: number) =>
  setTimeout(callback, milliseconds);
  cancel: (id: number) => void = (id: number) => clearTimeout(id);
}

/** A size in vp (CGSize). */
export class CYLPlaceholderHUDSize {
  width: number;
  height: number;

  constructor(width: number, height: number) {
    this.width = width;
    this.height = height;
  }
}

/** An offset in vp (UIOffset). */
export class CYLPlaceholderHUDOffset {
  horizontal: number;
  vertical: number;

  constructor(horizontal: number = 0, vertical: number = 0) {
    this.horizontal = horizontal;
    this.vertical = vertical;
  }
}

const DEFAULT_FONT = 15;
const DEFAULT_LIGHT_FOREGROUND = '#000000';
const DEFAULT_LIGHT_BOX = '#F2FFFFFF';
const DEFAULT_DARK_FOREGROUND = '#FFFFFF';
const DEFAULT_DARK_BOX = '#E61C1C1E';
const DEFAULT_BACKGROUND_LAYER = '#66000000';

function durationForString(text: string | null, minimum: number, maximum: number): number {
  const length = text !== null ? text.length : 0;
  return Math.min(Math.max(length * 0.06 + 0.5, minimum), maximum);
}

// The shared HUD, the presenter and the observers live at module level, not in static fields of the @Observed
// class: on the device the static getter `sharedHUD` returned undefined on the HUD page (TypeError "Cannot read
// property minimumDismissTimeInterval of undefined", emulator 2026-11-16, issue E5), so nothing reads static state
// of the decorated class any more. The static members below only forward to these.
let cylSharedHUD: CYLPlaceholderHUD | null = null;
let cylHUDPresenter: CYLPlaceholderHUDPresenter | null = null;
let cylHUDObservers: CYLPlaceholderHUDObserver[] = [];

/** The HUD the class methods use (iOS `+[CYLPlaceholderHUD sharedHUD]`); made on first use. */
export function CYLPlaceholderSharedHUD(): CYLPlaceholderHUD {
  if (cylSharedHUD === null) {
    cylSharedHUD = new CYLPlaceholderHUD(null);
  }
  return cylSharedHUD;
}

/** Sets the presenter that draws every HUD (CYLPlaceholderHUDView.ets installs the overlay presenter). */
export function CYLPlaceholderHUDSetPresenter(presenter: CYLPlaceholderHUDPresenter | null): void {
  cylHUDPresenter = presenter;
}

/** A heads-up display over a page (iOS `CYLPlaceholderHUD`). */
// No @Track here: with any @Track field, ArkUI forbids the UI from reading anything else, getters included, and the
// HUD view reads getters (blocksTouches, boxColor, status...): showing a HUD crashed with "Illegal usage of not
// @Track'ed property 'blocksTouches' on UI!" (emulator 2026-11-16). The page crash it was meant for (E5) was the
// static getter returning undefined, fixed by the module-level shared HUD below.
@Observed
export class CYLPlaceholderHUD {
  /** Draws every HUD; set by CYLPlaceholderHUDView.ets (null in unit tests: the state still changes). */
  static get presenter(): CYLPlaceholderHUDPresenter | null {
    return cylHUDPresenter;
  }

  static set presenter(value: CYLPlaceholderHUDPresenter | null) {
    cylHUDPresenter = value;
  }

  // Content.
  /** The icon and status of the built-in states, or null (iOS `contentView`). */
  contentView: CYLPlaceholderViewModel | null = null;
  /** The components or scenario of the Custom state, or null (iOS `placeholderView`). */
  placeholderView: CYLPlaceholderStackViewModel | null = null;
  /** The box on screen: the overlay's ComponentContent while shown, else null (iOS `hudView`). */
  hudView: Object | null = null;
  /** The handlers of the shown components' actions (iOS `actions`). */
  actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> | null = null;
  private stateValue: CYLPlaceholderHUDState = CYLPlaceholderHUDState.Hidden;
  private statusValue: string | null = null;
  private progressValue: number = 0;
  private activityCountValue: number = 0;

  // Customization.
  /** The UIContext of the window the HUD covers (iOS `containerView`). */
  containerView: UIContext | null = null;
  style: CYLPlaceholderHUDStyle = CYLPlaceholderHUDStyle.Automatic;
  maskType: CYLPlaceholderHUDMaskType = CYLPlaceholderHUDMaskType.None;
  private foregroundColorValue: ResourceColor | null = null;
  private hudBackgroundColorValue: ResourceColor | null = null;
  private backgroundLayerColorValue: ResourceColor | null = null;
  private fontValue: number = DEFAULT_FONT;
  /** The box's corner radius, in vp (iOS `cornerRadius`). */
  cornerRadius: number = 14;
  /** The box's smallest size, in vp (iOS `minimumSize`). */
  minimumSize: CYLPlaceholderHUDSize = new CYLPlaceholderHUDSize(100, 100);
  /** The icon's size, in vp (iOS `animationSize`). */
  animationSize: CYLPlaceholderHUDSize = new CYLPlaceholderHUDSize(40, 40);
  /** The box's offset from the center, in vp (iOS `offsetFromCenter`). */
  offsetFromCenter: CYLPlaceholderHUDOffset = new CYLPlaceholderHUDOffset();
  private loadingAnimationFileNameValue: string | null = null;
  /**
   * The bundled animation scrubbed to the progress in the Progress state (iOS `progressAnimationFileName`). null by
   * default: the icon keeps looping loadingAnimationFileName and the title shows the percentage.
   */
  progressAnimationFileName: string | null = null;
  /** The bundled animation of the Success state, played once (iOS `successAnimationFileName`); successImage before. */
  successAnimationFileName: string | null = 'CYLRefreshDoneCircle.json';
  private successImageValue: ResourceStr | null = null;
  private errorImageValue: ResourceStr | null = null;
  private infoImageValue: ResourceStr | null = null;
  /** Seconds a loading HUD waits before it shows, so a quick task shows none (iOS `graceTimeInterval`). */
  graceTimeInterval: number = 0;
  /** The shortest time a success / error / info / image HUD stays, in seconds (iOS `minimumDismissTimeInterval`). */
  minimumDismissTimeInterval: number = 1.5;
  /** The longest time it stays, in seconds (iOS `maximumDismissTimeInterval`). */
  maximumDismissTimeInterval: number = 5;
  /** The fade-in duration, in seconds (iOS `fadeInAnimationDuration`). */
  fadeInAnimationDuration: number = 0.15;
  /** The fade-out duration, in seconds (iOS `fadeOutAnimationDuration`). */
  fadeOutAnimationDuration: number = 0.15;
  /** Whether success and error vibrate (iOS `hapticsEnabled`). */
  hapticsEnabled: boolean = false;

  /**
   * Re-renders the HUD view (CYLPlaceholderHUDView). The overlay builds the view through a builder parameter, which
   * does not keep its @ObjectLink subscribed on the device, so the fade-in (opacity 0 -> 1) and status changes never
   * drew and the HUD stayed invisible (emulator 2026-11-16); the view listens here instead. Called after every change
   * the HUD makes to what the view draws.
   */
  cylChangeListener: (() => void) | null = null;

  cylNotifyChange(): void {
    const listener = this.cylChangeListener;
    if (listener !== null) {
      listener();
    }
  }

  // Drawing state (read by CYLPlaceholderHUDView).
  /** The box's opacity: 1 while shown, 0 while fading out. */
  opacity: number = 0;
  /** Whether the system appearance is dark (set by the presenter; used by the Automatic style). */
  systemDark: boolean = false;
  /** Timers; replace for tests. */
  scheduler: CYLPlaceholderHUDScheduler = new SystemScheduler();
  private presented: boolean = false;
  private dismissTimer: number = -1;
  private graceTimer: number = -1;
  private fadeTimer: number = -1;

  /** A HUD for a window's UIContext (iOS `-initWithContainerView:`); null for the shared HUD's way. */
  constructor(containerView: UIContext | null = null) {
    this.containerView = containerView;
  }

  /** A HUD covering containerView (iOS `-initWithContainerView:`). */
  static initWithContainerView(containerView: UIContext | null): CYLPlaceholderHUD {
    return new CYLPlaceholderHUD(containerView);
  }

  /** A HUD without a container yet (iOS `-init`). */
  static init(): CYLPlaceholderHUD {
    return new CYLPlaceholderHUD(null);
  }

  /** The HUD the class methods use; set its containerView once (iOS `sharedHUD`). */
  static get sharedHUD(): CYLPlaceholderHUD {
    return CYLPlaceholderSharedHUD();
  }

  // Read-only state.

  /** What is shown (iOS `state`). */
  get state(): CYLPlaceholderHUDState {
    return this.stateValue;
  }

  /** The status text (iOS `status`). */
  get status(): string | null {
    return this.statusValue;
  }

  /** The progress, 0 to 1 (iOS `progress`). */
  get progress(): number {
    return this.progressValue;
  }

  /** Whether the HUD is on screen (iOS `visible`). */
  get visible(): boolean {
    return this.presented && this.stateValue !== CYLPlaceholderHUDState.Hidden;
  }

  /** How many show calls wait for popActivity (iOS `activityCount`). */
  get activityCount(): number {
    return this.activityCountValue;
  }

  // Colors and fonts (null_resettable).

  /** The content color of the Custom style; setting it selects Custom, null resets it (iOS `foregroundColor`). */
  get foregroundColor(): ResourceColor {
    return this.foregroundColorValue !== null ? this.foregroundColorValue : this.isDark ? DEFAULT_DARK_FOREGROUND :
      DEFAULT_LIGHT_FOREGROUND;
  }

  set foregroundColor(value: ResourceColor | null) {
    this.foregroundColorValue = value;
    this.cylNotifyChange();
    if (value !== null) {
      this.style = CYLPlaceholderHUDStyle.Custom;
      this.cylNotifyChange();
    }
  }

  /** The box color of the Custom style; setting it selects Custom, null resets it (iOS `hudBackgroundColor`). */
  get hudBackgroundColor(): ResourceColor {
    return this.hudBackgroundColorValue !== null ? this.hudBackgroundColorValue : this.isDark ? DEFAULT_DARK_BOX :
      DEFAULT_LIGHT_BOX;
  }

  set hudBackgroundColor(value: ResourceColor | null) {
    this.hudBackgroundColorValue = value;
    this.cylNotifyChange();
    if (value !== null) {
      this.style = CYLPlaceholderHUDStyle.Custom;
      this.cylNotifyChange();
    }
  }

  /** The mask color of the Custom mask type; null resets it (iOS `backgroundLayerColor`). */
  get backgroundLayerColor(): ResourceColor {
    return this.backgroundLayerColorValue !== null ? this.backgroundLayerColorValue : DEFAULT_BACKGROUND_LAYER;
  }

  set backgroundLayerColor(value: ResourceColor | null) {
    this.backgroundLayerColorValue = value;
    this.cylNotifyChange();
  }

  /** The status font size in fp; null resets it to 15 (iOS `font`). */
  get font(): number {
    return this.fontValue;
  }

  set font(value: number | null) {
    this.fontValue = value !== null && value > 0 ? value : DEFAULT_FONT;
    this.cylNotifyChange();
  }

  /**
   * The bundled animation of the Loading state, looping (iOS `loadingAnimationFileName`, null_resettable):
   * "CYLRefreshActivity.gif" by default; the hourglass icon shows until it is ready.
   */
  get loadingAnimationFileName(): string {
    const name = this.loadingAnimationFileNameValue;
    return name !== null && name.length > 0 ? name : DEFAULT_LOADING_ANIMATION;
  }

  set loadingAnimationFileName(value: string | null) {
    this.loadingAnimationFileNameValue = value;
  }

  /** The success icon; null resets it to the built-in one (iOS `successImage`). */
  get successImage(): ResourceStr {
    return this.successImageValue !== null ? this.successImageValue : 'info';
  }

  set successImage(value: ResourceStr | null) {
    this.successImageValue = value;
  }

  /** The error icon; null resets it (iOS `errorImage`). */
  get errorImage(): ResourceStr {
    return this.errorImageValue !== null ? this.errorImageValue : 'error';
  }

  set errorImage(value: ResourceStr | null) {
    this.errorImageValue = value;
  }

  /** The info icon; null resets it (iOS `infoImage`). */
  get infoImage(): ResourceStr {
    return this.infoImageValue !== null ? this.infoImageValue : 'info';
  }

  set infoImage(value: ResourceStr | null) {
    this.infoImageValue = value;
  }

  /** Whether the box is dark now: the Dark style, or Automatic in the dark appearance. */
  get isDark(): boolean {
    return this.style === CYLPlaceholderHUDStyle.Dark ||
      (this.style === CYLPlaceholderHUDStyle.Automatic && this.systemDark);
  }

  /** The color of the content (text, icons, indicator) for the style. */
  get contentColor(): ResourceColor {
    if (this.style === CYLPlaceholderHUDStyle.Custom) {
      return this.foregroundColor;
    }
    return this.isDark ? DEFAULT_DARK_FOREGROUND : DEFAULT_LIGHT_FOREGROUND;
  }

  /** The color of the box for the style. */
  get boxColor(): ResourceColor {
    if (this.style === CYLPlaceholderHUDStyle.Custom) {
      return this.hudBackgroundColor;
    }
    return this.isDark ? DEFAULT_DARK_BOX : DEFAULT_LIGHT_BOX;
  }

  /** Whether the mask blocks touches (every mask type but None). */
  get blocksTouches(): boolean {
    return this.maskType !== CYLPlaceholderHUDMaskType.None;
  }

  // Showing.

  /** Shows the loading indicator; each call counts until popActivity (iOS `-show`). */
  show(): void {
    this.showWithStatus(null);
  }

  /** Shows the loading indicator with a status; each call counts until popActivity (iOS `-showWithStatus:`). */
  showWithStatus(status: string | null): void {
    this.activityCountValue++;
    const start = () => {
      this.graceTimer = -1;
      this.showContent(CYLPlaceholderHUDState.Loading, status, null, null);
    };
    if (this.graceTimeInterval > 0 && !this.visible) {
      this.cancelTimer(this.graceTimer);
      this.graceTimer = this.scheduler.schedule(start, this.graceTimeInterval * 1000);
    } else {
      this.cancelTimer(this.graceTimer);
      this.graceTimer = -1;
      start();
    }
  }

  /** Shows a progress, 0 to 1, keeping the status (iOS `-showProgress:`). */
  showProgress(progress: number): void {
    this.showProgressStatus(progress, this.statusValue);
  }

  /**
   * Shows a progress, 0 to 1, with a status; a negative progress is indeterminate (the loading indicator). The first
   * one counts as an activity for popActivity (iOS `-showProgress:status:`).
   */
  showProgressStatus(progress: number, status: string | null): void {
    const determinate = progress >= 0 && !isNaN(progress);
    if (!determinate || this.activityCountValue === 0) {
      this.activityCountValue++;
    }
    const state = determinate ? CYLPlaceholderHUDState.Progress : CYLPlaceholderHUDState.Loading;
    this.progressValue = determinate ? Math.min(Math.max(progress, 0), 1) : 0;
    this.cylNotifyChange();
    if (this.visible && this.stateValue === state && this.contentView !== null) {
      // The same kind of HUD: update in place so the animation does not restart.
      this.updateProgress();
      this.setStatus(status);
      return;
    }
    this.showContent(state, status, null, null);
  }

  /** Changes the status in place, without restarting the indicator (iOS `-setStatus:`). */
  setStatus(status: string | null): void {
    this.statusValue = status;
    this.cylNotifyChange();
    const content = this.contentView;
    if (content !== null) {
      content.text = this.titleForStatus(status, this.stateValue === CYLPlaceholderHUDState.Progress);
      content.accessibilityLabel = status;
    }
  }

  /** Shows the info icon with a status, then hides (iOS `-showInfoWithStatus:`). */
  showInfoWithStatus(status: string | null): void {
    this.showTimed(CYLPlaceholderHUDState.Info, this.infoImage, status);
  }

  /** Shows the success icon with a status, then hides (iOS `-showSuccessWithStatus:`). */
  showSuccessWithStatus(status: string | null): void {
    this.showTimed(CYLPlaceholderHUDState.Success, this.successImage, status);
  }

  /** Shows the error icon with a status, then hides (iOS `-showErrorWithStatus:`). */
  showErrorWithStatus(status: string | null): void {
    this.showTimed(CYLPlaceholderHUDState.Error, this.errorImage, status);
  }

  /** Shows an image (a bundled icon name, a Resource or a path) with a status, then hides (iOS `-showImage:status:`). */
  showImageStatus(image: ResourceStr | null, status: string | null): void {
    this.showTimed(CYLPlaceholderHUDState.Image, image, status);
  }

  /** Shows the app's components; actions handle their taps (iOS `-showComponents:actions:`). */
  showComponentsActions(components: CYLPlaceholderComponent[],
    actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> | null = null): void {
    this.actions = actions;
    this.showContent(CYLPlaceholderHUDState.Custom, null, null,
      CYLPlaceholderStackViewModel.initWithComponents(components, actions));
  }

  /** Shows a scenario; actions handle its taps (iOS `-showScenario:actions:`). */
  showScenarioActions(scenario: CYLPlaceholderScenario,
    actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> | null = null): void {
    this.actions = actions;
    this.showContent(CYLPlaceholderHUDState.Custom, null, null,
      CYLPlaceholderStackViewModel.initWithScenario(scenario, actions));
  }

  /** Ends one show; the HUD hides once every one has ended (iOS `-popActivity`). */
  popActivity(): void {
    if (this.activityCountValue > 0) {
      this.activityCountValue--;
    }
    if (this.activityCountValue === 0) {
      this.dismiss();
    }
  }

  /** Hides now (iOS `-dismiss`). */
  dismiss(): void {
    this.dismissWithDelayCompletion(0, null);
  }

  /** Hides, then runs completion (iOS `-dismissWithCompletion:`). */
  dismissWithCompletion(completion: CYLPlaceholderHUDDismissCompletion | null): void {
    this.dismissWithDelayCompletion(0, completion);
  }

  /** Hides after delay seconds (iOS `-dismissWithDelay:`). */
  dismissWithDelay(delay: number): void {
    this.dismissWithDelayCompletion(delay, null);
  }

  /** Hides after delay seconds, then runs completion (iOS `-dismissWithDelay:completion:`). */
  dismissWithDelayCompletion(delay: number, completion: CYLPlaceholderHUDDismissCompletion | null): void {
    this.cancelTimer(this.dismissTimer);
    this.cancelTimer(this.graceTimer);
    this.graceTimer = -1;
    const run = () => {
      this.dismissTimer = -1;
      this.activityCountValue = 0;
      if (!this.presented) {
        this.finish(completion, false);
        return;
      }
      this.post(CYLPlaceholderHUDWillDisappearNotification);
      this.opacity = 0;
      this.cylNotifyChange();
      this.cancelTimer(this.fadeTimer);
      this.fadeTimer = this.scheduler.schedule(() => {
        this.fadeTimer = -1;
        this.finish(completion, true);
      }, this.fadeOutAnimationDuration * 1000);
    };
    if (delay > 0) {
      this.dismissTimer = this.scheduler.schedule(run, delay * 1000);
    } else {
      run();
    }
  }

  /** How long a timed HUD with this text stays, in seconds: 0.06 s a character + 0.5, within the limits (iOS `-displayDurationForString:`). */
  displayDurationForString(text: string | null): number {
    return durationForString(text, this.minimumDismissTimeInterval, this.maximumDismissTimeInterval);
  }

  /** Posts a touch notification (called by the view). */
  receiveTouch(insideBox: boolean): void {
    this.post(insideBox ? CYLPlaceholderHUDDidTouchDownInsideNotification :
      CYLPlaceholderHUDDidReceiveTouchEventNotification);
  }

  // Notifications (iOS NSNotificationCenter).

  /** Adds an observer of the HUD notifications (every name; filter on the name it receives). */
  static addObserver(observer: CYLPlaceholderHUDObserver): void {
    if (cylHUDObservers.indexOf(observer) < 0) {
      cylHUDObservers.push(observer);
    }
  }

  /** Removes an observer added by addObserver. */
  static removeObserver(observer: CYLPlaceholderHUDObserver): void {
    cylHUDObservers = cylHUDObservers.filter((o: CYLPlaceholderHUDObserver) => o !== observer);
  }

  // Class methods: the shared HUD (iOS `+show` etc.).

  static show(): void {
    CYLPlaceholderSharedHUD().show();
  }

  static showWithStatus(status: string | null): void {
    CYLPlaceholderSharedHUD().showWithStatus(status);
  }

  static showProgress(progress: number): void {
    CYLPlaceholderSharedHUD().showProgress(progress);
  }

  static showProgressStatus(progress: number, status: string | null): void {
    CYLPlaceholderSharedHUD().showProgressStatus(progress, status);
  }

  static setStatus(status: string | null): void {
    CYLPlaceholderSharedHUD().setStatus(status);
  }

  static showInfoWithStatus(status: string | null): void {
    CYLPlaceholderSharedHUD().showInfoWithStatus(status);
  }

  static showSuccessWithStatus(status: string | null): void {
    CYLPlaceholderSharedHUD().showSuccessWithStatus(status);
  }

  static showErrorWithStatus(status: string | null): void {
    CYLPlaceholderSharedHUD().showErrorWithStatus(status);
  }

  static showImageStatus(image: ResourceStr | null, status: string | null): void {
    CYLPlaceholderSharedHUD().showImageStatus(image, status);
  }

  static showComponentsActions(components: CYLPlaceholderComponent[],
    actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> | null = null): void {
    CYLPlaceholderSharedHUD().showComponentsActions(components, actions);
  }

  static showScenarioActions(scenario: CYLPlaceholderScenario,
    actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> | null = null): void {
    CYLPlaceholderSharedHUD().showScenarioActions(scenario, actions);
  }

  static popActivity(): void {
    CYLPlaceholderSharedHUD().popActivity();
  }

  static dismiss(): void {
    CYLPlaceholderSharedHUD().dismiss();
  }

  static dismissWithCompletion(completion: CYLPlaceholderHUDDismissCompletion | null): void {
    CYLPlaceholderSharedHUD().dismissWithCompletion(completion);
  }

  static dismissWithDelay(delay: number): void {
    CYLPlaceholderSharedHUD().dismissWithDelay(delay);
  }

  static dismissWithDelayCompletion(delay: number, completion: CYLPlaceholderHUDDismissCompletion | null): void {
    CYLPlaceholderSharedHUD().dismissWithDelayCompletion(delay, completion);
  }

  /** Whether the shared HUD is on screen (iOS `+isVisible`). */
  static isVisible(): boolean {
    return cylSharedHUD !== null && cylSharedHUD.visible;
  }

  /** The shared HUD's display duration (iOS `+displayDurationForString:`). */
  static displayDurationForString(text: string | null): number {
    return CYLPlaceholderSharedHUD().displayDurationForString(text);
  }

  // Internals.

  /** The title: the status, followed in the Progress state by the percentage when no animation is scrubbed. */
  private titleForStatus(status: string | null, determinate: boolean): string | null {
    const progressFile = this.progressAnimationFileName;
    if (!determinate || (progressFile !== null && progressFile.length > 0)) {
      return status;
    }
    const percent = Math.round(this.progressValue * 100) + '%';
    return status !== null && status.length > 0 ? status + ' ' + percent : percent;
  }

  /** Scrubs progressAnimationFileName to the progress. */
  private updateProgress(): void {
    const view = this.contentView;
    const progressFile = this.progressAnimationFileName;
    if (this.stateValue !== CYLPlaceholderHUDState.Progress || view === null || progressFile === null ||
      progressFile.length === 0) {
      return;
    }
    view.stopPlaceholderAnimation();
    view.setPlaceholderAnimationProgress(this.progressValue);
  }

  private showTimed(state: CYLPlaceholderHUDState, image: ResourceStr | null, status: string | null): void {
    this.activityCountValue = 0;
    this.cancelTimer(this.graceTimer);
    this.graceTimer = -1;
    this.showContent(state, status, image, null);
    const presenter = cylHUDPresenter;
    if (this.hapticsEnabled && presenter !== null &&
      (state === CYLPlaceholderHUDState.Success || state === CYLPlaceholderHUDState.Error)) {
      presenter.haptic(this, state);
    }
    this.dismissTimer = this.scheduler.schedule(() => {
      this.dismissTimer = -1;
      this.dismiss();
    }, this.displayDurationForString(status) * 1000);
  }

  private showContent(state: CYLPlaceholderHUDState, status: string | null, image: ResourceStr | null,
    stack: CYLPlaceholderStackViewModel | null): void {
    this.cancelTimer(this.dismissTimer);
    this.dismissTimer = -1;
    this.cancelTimer(this.fadeTimer);
    this.fadeTimer = -1;
    this.stateValue = state;
    this.cylNotifyChange();
    this.statusValue = status;
    this.cylNotifyChange();
    if (stack !== null) {
      this.placeholderView = stack;
      this.cylNotifyChange();
      this.contentView = null;
      this.cylNotifyChange();
    } else {
      this.placeholderView = null;
      this.cylNotifyChange();
      // Loading loops loadingAnimationFileName, Progress scrubs progressAnimationFileName (or loops the loading one),
      // Success plays successAnimationFileName once; the image (the hourglass while loading) shows until it is ready.
      const loading = state === CYLPlaceholderHUDState.Loading || state === CYLPlaceholderHUDState.Progress;
      const progressFile = this.progressAnimationFileName;
      const scrubs = state === CYLPlaceholderHUDState.Progress && progressFile !== null && progressFile.length > 0;
      let animation: string | null = null;
      if (loading) {
        animation = scrubs ? progressFile : this.loadingAnimationFileName;
      } else if (state === CYLPlaceholderHUDState.Success) {
        animation = this.successAnimationFileName;
      }
      const icon: ResourceStr | null = loading && image === null ?
        CYLPlaceholderIconNameForStyle(CYLPlaceholderStyle.Hourglass) : image;
      const view = CYLPlaceholderViewModel.initWithImageText(icon,
        this.titleForStatus(status, state === CYLPlaceholderHUDState.Progress));
      view.accessibilityLabel = status;
      view.animationFileName = animation;
      view.animationRepeatCount = loading ? 0 : 1;
      view.reportsContentSize = true;
      view.contentMargin = 0;
      view.imageSide = Math.min(this.animationSize.width, this.animationSize.height);
      view.defaultTitleColor = this.contentColor;
      view.defaultIconColor = this.contentColor;
      view.defaultTitleFont = this.font;
      view.preferredMaxLayoutWidth = 240;
      this.contentView = view;
      this.cylNotifyChange();
      this.updateProgress();
    }
    this.present();
  }

  private present(): void {
    if (!this.presented) {
      this.presented = true;
      this.post(CYLPlaceholderHUDWillAppearNotification);
      const presenter = cylHUDPresenter;
      if (presenter !== null) {
        presenter.present(this);
      }
      this.opacity = 1;
      this.cylNotifyChange();
      this.fadeTimer = this.scheduler.schedule(() => {
        this.fadeTimer = -1;
        this.post(CYLPlaceholderHUDDidAppearNotification);
      }, this.fadeInAnimationDuration * 1000);
    } else {
      this.opacity = 1;
      this.cylNotifyChange();
    }
  }

  private finish(completion: CYLPlaceholderHUDDismissCompletion | null, wasPresented: boolean): void {
    if (wasPresented) {
      const presenter = cylHUDPresenter;
      if (presenter !== null) {
        presenter.remove(this);
      }
    }
    this.presented = false;
    this.stateValue = CYLPlaceholderHUDState.Hidden;
    this.cylNotifyChange();
    this.contentView = null;
    this.cylNotifyChange();
    this.placeholderView = null;
    this.cylNotifyChange();
    if (completion !== null) {
      completion();
    }
    if (wasPresented) {
      this.post(CYLPlaceholderHUDDidDisappearNotification);
    }
  }

  private cancelTimer(id: number): void {
    if (id >= 0) {
      this.scheduler.cancel(id);
    }
  }

  private post(name: string): void {
    cylHUDObservers.slice().forEach((o: CYLPlaceholderHUDObserver) => o(name, this, this.statusValue));
  }
}
