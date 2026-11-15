// The HarmonyOS counterpart of iOS UIViewController+CYLPlaceholderStatus (behavior from android/placeholder's
// CYLPlaceholderStatus.kt and CYLPlaceholderConfiguration.kt): the status bar and the placeholder as two independent
// parts of a page. ArkUI pages are not objects to extend, so a page keeps a CYLPlaceholderStatusController (it stands
// for the UIViewController, with the iOS `cyl_` names) and wraps its content in CYLPlaceholderStatusPage, which puts
// the bar at the top, above the content, and moves the content below it:
//
//   @State status: CYLPlaceholderStatusController = new CYLPlaceholderStatusController();
//   @State list: CYLPlaceholderListController = new CYLPlaceholderListController(() => this.items.length);
//   aboutToAppear() {
//     this.status.cyl_placeholderScrollView = this.list;
//     this.status.cyl_showsStatusViewWhenOffline = true;
//   }
//   ...
//   CYLPlaceholderStatusPage({ controller: this.status }) { CYLPlaceholderList({ controller: this.list }) { ... } }
import { CYLPlaceholderStatusView, CYLPlaceholderStatusViewModel } from './CYLPlaceholderStatusView';
import { CYLPlaceholderListController } from './CYLPlaceholderList';
import { CYLPlaceholderNetworkMonitor, CYLPlaceholderNetworkStatus } from './CYLPlaceholderNetworkMonitor';
import { CYLPlaceholderConfiguration, CYLPlaceholderConfigurationErrorHandler } from './CYLPlaceholderConfiguration';

/** What a page shows; the values combine with | (iOS `CYLPlaceholderStatusDisplay`, NS_OPTIONS). */
export class CYLPlaceholderStatusDisplay {
  /** Neither the bar nor the placeholder. */
  static readonly None: number = 0;
  /** The status bar at the top. */
  static readonly StatusBar: number = 1;
  /** The placeholder of cyl_placeholderScrollView when it is empty (the default). */
  static readonly Placeholder: number = 2;
  /** Both. */
  static readonly All: number = 3;
}

const DISPLAY_NAMES: string[] = ['statusAndPlaceholder', 'status', 'placeholder', 'none'];
const DISPLAY_VALUES: number[] = [CYLPlaceholderStatusDisplay.All, CYLPlaceholderStatusDisplay.StatusBar,
  CYLPlaceholderStatusDisplay.Placeholder, CYLPlaceholderStatusDisplay.None];

/** Stands for a UIViewController with the CYLPlaceholderStatus category (iOS `UIViewController (CYLPlaceholderStatus)`). */
@Observed
export class CYLPlaceholderStatusController {
  /** Whether the bar shows now (derived from cyl_statusDisplay). */
  statusBarVisible: boolean = false;
  /** Whether the bar fades in and out (the last cyl_setStatusDisplay's animated). */
  statusBarAnimated: boolean = false;
  private statusViewValue: CYLPlaceholderStatusViewModel = CYLPlaceholderStatusViewModel.initWithFrame();
  private displayValue: number = CYLPlaceholderStatusDisplay.Placeholder;
  private scrollView: CYLPlaceholderListController | null = null;
  private showsWhenOffline: boolean = false;
  private monitor: CYLPlaceholderNetworkMonitor | null = null;
  private networkObserver: (monitor: CYLPlaceholderNetworkMonitor) => void = (m: CYLPlaceholderNetworkMonitor) => {
    this.networkChanged(m);
  };

  /** The network monitor cyl_showsStatusViewWhenOffline follows; the shared one by default (tests set their own). */
  set networkMonitor(monitor: CYLPlaceholderNetworkMonitor) {
    this.monitor = monitor;
  }

  get networkMonitor(): CYLPlaceholderNetworkMonitor {
    return this.monitor !== null ? this.monitor : CYLPlaceholderNetworkMonitor.sharedMonitor;
  }

  /**
   * The bar: the network bar (CYLPlaceholderStatusViewModel.initWithFrame()) until another is assigned; null
   * restores it; assigning while it shows replaces it in place (iOS `cyl_statusView`).
   */
  get cyl_statusView(): CYLPlaceholderStatusViewModel {
    return this.statusViewValue;
  }

  set cyl_statusView(value: CYLPlaceholderStatusViewModel | null) {
    this.statusViewValue = value !== null ? value : CYLPlaceholderStatusViewModel.initWithFrame();
  }

  /** The list whose placeholder cyl_statusDisplay shows or hides (iOS `cyl_placeholderScrollView`). */
  get cyl_placeholderScrollView(): CYLPlaceholderListController | null {
    return this.scrollView;
  }

  set cyl_placeholderScrollView(value: CYLPlaceholderListController | null) {
    this.scrollView = value;
    this.applyPlaceholder();
  }

  /** What shows; Placeholder by default, so nothing changes until it is set (iOS `cyl_statusDisplay`). */
  get cyl_statusDisplay(): number {
    return this.displayValue;
  }

  set cyl_statusDisplay(value: number) {
    this.cyl_setStatusDisplay(value, false);
  }

  /** Sets cyl_statusDisplay, fading the bar in or out when animated (iOS `-cyl_setStatusDisplay:animated:`). */
  cyl_setStatusDisplay(display: number, animated: boolean): void {
    this.displayValue = display;
    this.statusBarAnimated = animated;
    this.statusBarVisible = (display & CYLPlaceholderStatusDisplay.StatusBar) !== 0;
    this.applyPlaceholder();
  }

  /**
   * true starts the network monitor and adds the bar while the network is not reachable, removing it when it comes
   * back; the placeholder option is kept (iOS `cyl_showsStatusViewWhenOffline`).
   */
  get cyl_showsStatusViewWhenOffline(): boolean {
    return this.showsWhenOffline;
  }

  set cyl_showsStatusViewWhenOffline(value: boolean) {
    if (value === this.showsWhenOffline) {
      return;
    }
    this.showsWhenOffline = value;
    const monitor = this.networkMonitor;
    if (value) {
      monitor.addObserver(this.networkObserver);
      monitor.startMonitoring();
      this.networkChanged(monitor);
    } else {
      monitor.removeObserver(this.networkObserver);
    }
  }

  /**
   * Applies a configuration dictionary (iOS `-cyl_applyStatusConfiguration:error:`): "statusBar" (true or
   * "networkUnavailable" for the network bar, or a dictionary for CYLPlaceholderStatusViewModel.initWithConfiguration),
   * "display" ("statusAndPlaceholder", "status", "placeholder" or "none"; by default "statusAndPlaceholder" with a
   * "statusBar", else "placeholder") and "showsWhenOffline" (a boolean). false, with the reason and nothing changed,
   * when a value is invalid.
   */
  cyl_applyStatusConfiguration(configuration: Record<string, Object> | null,
    onError: CYLPlaceholderConfigurationErrorHandler | null = null): boolean {
    if (configuration === null || !CYLPlaceholderConfiguration.isDictionary(configuration)) {
      CYLPlaceholderConfiguration.fail(onError, 'The configuration must be a dictionary.');
      return false;
    }
    const barValue: Object | undefined = configuration['statusBar'];
    let bar: CYLPlaceholderStatusViewModel | null = null;
    if (barValue !== undefined && barValue !== null && CYLPlaceholderConfiguration.isDictionary(barValue)) {
      bar = CYLPlaceholderStatusViewModel.initWithConfiguration(barValue as Record<string, Object>, onError);
      if (bar === null) {
        return false;
      }
    } else if (barValue !== undefined && barValue !== null && typeof barValue !== 'boolean' &&
      barValue !== 'networkUnavailable') {
      CYLPlaceholderConfiguration.fail(onError, '"statusBar" must be true, "networkUnavailable" or a dictionary.');
      return false;
    }
    const wantsBar = barValue !== undefined && barValue !== null && barValue !== false;
    const displayValue: Object | undefined = configuration['display'];
    let display = wantsBar ? CYLPlaceholderStatusDisplay.All : CYLPlaceholderStatusDisplay.Placeholder;
    if (displayValue !== undefined && displayValue !== null) {
      const index = typeof displayValue === 'string' ? DISPLAY_NAMES.indexOf(displayValue as string) : -1;
      if (index < 0) {
        CYLPlaceholderConfiguration.fail(onError,
          '"display" must be "statusAndPlaceholder", "status", "placeholder" or "none".');
        return false;
      }
      display = DISPLAY_VALUES[index];
    }
    const offline: Object | undefined = configuration['showsWhenOffline'];
    if (offline !== undefined && offline !== null && typeof offline !== 'boolean') {
      CYLPlaceholderConfiguration.fail(onError, '"showsWhenOffline" must be a boolean.');
      return false;
    }
    if (bar !== null) {
      this.cyl_statusView = bar;
    } else if (wantsBar) {
      this.cyl_statusView = null;
    }
    if (typeof offline === 'boolean') {
      this.cyl_showsStatusViewWhenOffline = offline as boolean;
    }
    this.cyl_statusDisplay = display;
    return true;
  }

  /** The same, from a local ".json" or ".plist" file (iOS `-cyl_applyStatusConfigurationWithContentsOfURL:error:`). */
  cyl_applyStatusConfigurationWithContentsOfURL(path: string,
    onError: CYLPlaceholderConfigurationErrorHandler | null = null): boolean {
    const configuration = CYLPlaceholderConfiguration.readFile(path, onError);
    return configuration !== null && this.cyl_applyStatusConfiguration(configuration, onError);
  }

  private applyPlaceholder(): void {
    const list = this.scrollView;
    if (list !== null) {
      list.cyl_placeholderHidden = (this.displayValue & CYLPlaceholderStatusDisplay.Placeholder) === 0;
    }
  }

  private networkChanged(monitor: CYLPlaceholderNetworkMonitor): void {
    if (!this.showsWhenOffline) {
      return;
    }
    const offline = monitor.networkStatus === CYLPlaceholderNetworkStatus.NotReachable;
    const display = offline ? (this.displayValue | CYLPlaceholderStatusDisplay.StatusBar) :
      (this.displayValue & ~CYLPlaceholderStatusDisplay.StatusBar);
    if (display !== this.displayValue) {
      this.cyl_setStatusDisplay(display, true);
    }
  }
}

/** A page's content with its status bar at the top (where iOS adds the bar to the controller's view). */
@Component
export struct CYLPlaceholderStatusPage {
  @ObjectLink controller: CYLPlaceholderStatusController;
  @BuilderParam content: () => void = emptyContent;

  build() {
    Column() {
      if (this.controller.statusBarVisible) {
        CYLPlaceholderStatusView({ model: this.controller.cyl_statusView })
          .transition(this.controller.statusBarAnimated ?
            TransitionEffect.OPACITY.animation({ duration: 200 }) : TransitionEffect.IDENTITY)
      }
      Column() {
        this.content()
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
function emptyContent() {
}
