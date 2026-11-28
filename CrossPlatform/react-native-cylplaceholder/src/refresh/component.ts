import { CYLRefreshNotifier } from './notifier.ts';
import {
  CYLRefreshPhase,
  CYLRefreshScrollMode,
  CYLRefreshState,
  CYLRefreshTriggerMode,
} from './refreshTypes.ts';

/** Called when a component starts refreshing; the caller ends it with `CYLRefreshComponent.endRefreshing`. */
export type CYLRefreshHandler = () => void;

/** Called when a component's phase changes. */
export type CYLRefreshPhaseObserver = (
  component: CYLRefreshComponent,
  phase: CYLRefreshPhase,
  oldPhase: CYLRefreshPhase
) => void;

/** What a `CYLRefreshComponent` needs to know about the view that owns it. */
export interface CYLRefreshHost {
  /** Whether a component other than `component` is refreshing. */
  isOtherRefreshing(component: CYLRefreshComponent): boolean;
}

/** The arguments every header and footer takes; each one sets the property of the same name. */
export interface CYLRefreshComponentOptions {
  /** Called when the component starts refreshing. */
  refreshingHandler?: CYLRefreshHandler | null;
  /** Draws the indicator: returns a React node (the React layer calls it). */
  builder?: ((component: CYLRefreshComponent) => unknown) | null;
  /** False: the component never refreshes. */
  refreshEnabled?: boolean;
  /** The height the indicator holds while refreshing, in points. */
  expandHeight?: number;
  /** The pull needed to arm the refresh is `expandHeight` times this rate. */
  triggerRate?: number;
  /** How long the result stays visible after `endRefreshing`, in milliseconds. */
  finishDuration?: number;
  /** How the indicator moves with the pull. */
  scrollMode?: CYLRefreshScrollMode;
  /** Where a pull may start. */
  triggerMode?: CYLRefreshTriggerMode;
  /** True: refresh as soon as the trigger offset is reached, without waiting for the release. */
  triggersWhenReached?: boolean;
  /** The farthest the content may be pulled, 0 for no limit. */
  maxPullDistance?: number;
  /** Vibrate when the pull passes the trigger offset. */
  hapticFeedback?: boolean;
  /** True: notify the listeners on every scroll update, even while the indicator is hidden. */
  notifiesWhenHidden?: boolean;
  /** True: do not start while another component of the same `CYLRefresh` is refreshing. */
  exclusiveWithOtherRefresh?: boolean;
  /** The over-offset `beginRefreshing` uses when none is passed, in points. */
  defaultOverOffset?: number;
  /** The accent color of the indicator, or undefined for the default. */
  colorAccent?: string;
  /** The primary color of the indicator, or undefined for the default. */
  colorPrimary?: string;
}

/** The arguments of `CYLRefreshComponent.beginRefreshing`. */
export interface CYLRefreshBeginOptions {
  /** The opening animation's length in milliseconds. */
  duration?: number;
  /** How far the opening animation overshoots, in points (default `defaultOverOffset`). */
  overOffset?: number;
  /** Ignore `refreshEnabled`, a refresh under way and the exclusivity. */
  force?: boolean;
}

/**
 * The base of every header and footer: a long-lived object that holds the configuration and the state, like the iOS,
 * Android and Flutter components. Create it once (`useRef` or `useMemo`), pass it to `CYLRefresh` and call `dispose`.
 *
 * The caller always ends refreshing with `endRefreshing` (there is no switch for it, as on iOS); the component stays in
 * `CYLRefreshPhase.refreshing` until then.
 */
export abstract class CYLRefreshComponent extends CYLRefreshNotifier {
  /** Called to vibrate when a pull passes the trigger offset and `hapticFeedback` is on; the React layer sets it. */
  static hapticImpact: (() => void) | null = null;

  /** Called when the component starts refreshing; call `endRefreshing` when the work is done. */
  refreshingHandler: CYLRefreshHandler | null;
  /** Draws the indicator; subclasses override `buildIndicator` instead. */
  builder: ((component: CYLRefreshComponent) => unknown) | null;
  /** False: the component never refreshes. */
  refreshEnabled: boolean;
  /** The height the indicator holds while refreshing, in points. */
  expandHeight: number;
  /** The pull needed to arm the refresh is `expandHeight` times this rate. */
  triggerRate: number;
  /** How long the result stays visible after `endRefreshing`, in milliseconds. */
  finishDuration: number;
  /** How the indicator moves with the pull. */
  scrollMode: CYLRefreshScrollMode;
  /** Where a pull may start. */
  triggerMode: CYLRefreshTriggerMode;
  /** True: refresh as soon as the trigger offset is reached, without waiting for the release. */
  triggersWhenReached: boolean;
  /** The farthest the content may be pulled, 0 for no limit. */
  maxPullDistance: number;
  /** Vibrate when the pull passes the trigger offset. */
  hapticFeedback: boolean;
  /** True: notify the listeners on every scroll update, even while the indicator is hidden. */
  notifiesWhenHidden: boolean;
  /** True: do not start while another component of the same `CYLRefresh` is refreshing. */
  exclusiveWithOtherRefresh: boolean;
  /** The over-offset `beginRefreshing` uses when none is passed, in points. */
  defaultOverOffset: number;
  /** The accent color of the indicator, or undefined for the default. */
  colorAccent: string | undefined;
  /** The primary color of the indicator, or undefined for the default. */
  colorPrimary: string | undefined;
  /** The duration the next opening animation takes in milliseconds, or null for the default; read by `CYLRefresh`. */
  openDuration: number | null = null;
  /** The distance the next opening animation overshoots by; read by `CYLRefresh`. */
  openOverOffset: number = 0;

  private currentPhase: CYLRefreshPhase = CYLRefreshPhase.idle;
  private currentPullingPercent: number = 0;
  private currentDragOffset: number = 0;
  private currentLastRefreshSucceeded: boolean = true;
  private noMoreData: boolean = false;
  private disposed: boolean = false;
  private begins: boolean = false;
  private finishTimer: ReturnType<typeof setTimeout> | null = null;
  private host: CYLRefreshHost | null = null;
  private observers: CYLRefreshPhaseObserver[] = [];

  /** Creates a component; every option sets the property of the same name. */
  constructor(options: CYLRefreshComponentOptions = {}) {
    super();
    this.refreshingHandler = options.refreshingHandler ?? null;
    this.builder = options.builder ?? null;
    this.refreshEnabled = options.refreshEnabled ?? true;
    this.expandHeight = options.expandHeight ?? 60;
    this.triggerRate = options.triggerRate ?? 1;
    this.finishDuration = options.finishDuration ?? 600;
    this.scrollMode = options.scrollMode ?? CYLRefreshScrollMode.move;
    this.triggerMode = options.triggerMode ?? CYLRefreshTriggerMode.anywhere;
    this.triggersWhenReached = options.triggersWhenReached ?? false;
    this.maxPullDistance = options.maxPullDistance ?? 0;
    this.hapticFeedback = options.hapticFeedback ?? false;
    this.notifiesWhenHidden = options.notifiesWhenHidden ?? false;
    this.exclusiveWithOtherRefresh = options.exclusiveWithOtherRefresh ?? true;
    this.defaultOverOffset = options.defaultOverOffset ?? 20;
    this.colorAccent = options.colorAccent;
    this.colorPrimary = options.colorPrimary;
  }

  /** Whether this is the header (pulled down at the top); false for a footer (pulled up at the bottom). */
  abstract get isHeader(): boolean;

  /** The pull, in points, that arms the refresh: `expandHeight` times `triggerRate`. */
  get triggerOffset(): number {
    return this.expandHeight * this.triggerRate;
  }

  /** The detailed phase. */
  get phase(): CYLRefreshPhase {
    return this.currentPhase;
  }

  /** The coarse state. */
  get state(): CYLRefreshState {
    if (this.noMoreData) {
      return CYLRefreshState.noMoreData;
    }
    switch (this.currentPhase) {
      case CYLRefreshPhase.idle:
        return CYLRefreshState.idle;
      case CYLRefreshPhase.pullToRefresh:
      case CYLRefreshPhase.releaseToRefresh:
        return CYLRefreshState.pulling;
      default:
        return CYLRefreshState.refreshing;
    }
  }

  /** How far the pull is past the trigger offset: 1 means armed. */
  get pullingPercent(): number {
    return this.currentPullingPercent;
  }

  /** The current pull in points. */
  get dragOffset(): number {
    return this.currentDragOffset;
  }

  /** Whether the last refresh succeeded. */
  get lastRefreshSucceeded(): boolean {
    return this.currentLastRefreshSucceeded;
  }

  /** Whether a refresh is under way (released, or refreshing). */
  get isRefreshing(): boolean {
    return this.currentPhase === CYLRefreshPhase.releasing || this.currentPhase === CYLRefreshPhase.refreshing;
  }

  /** Whether the footer reported that there is no more data; always false for a header. */
  get isNoMoreData(): boolean {
    return this.noMoreData;
  }

  /** Whether the indicator keeps its `expandHeight` open: while refreshing, finishing, and (footer) with no more data. */
  get holdsSpace(): boolean {
    return this.isRefreshing || this.currentPhase === CYLRefreshPhase.finishing || this.noMoreData;
  }

  /** Whether a `beginRefreshing` is waiting for the component to be attached to a `CYLRefresh` (refresh on start). */
  get wantsBegin(): boolean {
    return this.begins;
  }

  /** Whether a `CYLRefresh` shows this component. */
  get attached(): boolean {
    return this.host !== null;
  }

  /** Connects the component to its owner; called by `CYLRefresh`. */
  attach(host: CYLRefreshHost): void {
    this.host = host;
    if (this.begins) {
      this.begins = false;
      this.beginRefreshing();
    }
  }

  /** Disconnects the component from its owner; called by `CYLRefresh`. */
  detach(host: CYLRefreshHost): void {
    if (this.host === host) {
      this.host = null;
    }
  }

  /** Calls `observer` on every phase change. */
  addPhaseObserver(observer: CYLRefreshPhaseObserver): void {
    this.observers.push(observer);
  }

  /** Stops calling `observer`. */
  removePhaseObserver(observer: CYLRefreshPhaseObserver): void {
    this.observers = this.observers.filter((o) => o !== observer);
  }

  /**
   * Starts refreshing as if the user had pulled and released. Before the component is attached, it starts once it is
   * (refresh on start). `duration` is the opening animation's length, `overOffset` how far it overshoots (default
   * `defaultOverOffset`); `force` ignores `refreshEnabled`, a refresh under way and the exclusivity.
   */
  beginRefreshing(options: CYLRefreshBeginOptions = {}): void {
    const force = options.force ?? false;
    if (this.disposed) {
      return;
    }
    if (!force && (!this.refreshEnabled || this.isRefreshing)) {
      return;
    }
    if (this.host === null) {
      this.begins = true;
      return;
    }
    if (!force && this.exclusiveWithOtherRefresh && this.host.isOtherRefreshing(this)) {
      return;
    }
    this.openDuration = options.duration ?? null;
    this.openOverOffset = options.overOffset ?? this.defaultOverOffset;
    this.start();
  }

  /** Ends refreshing; `success` picks the result shown for `finishDuration`. Does nothing unless refreshing. */
  endRefreshing(success: boolean = true): void {
    if (this.disposed || !this.isRefreshing) {
      return;
    }
    this.currentLastRefreshSucceeded = success;
    this.clearFinishTimer();
    this.setPhase(CYLRefreshPhase.finishing);
    this.didEndRefreshing(success);
    this.finishTimer = setTimeout(() => this.close(), this.finishDuration);
  }

  /** Called after `endRefreshing`; subclasses record the result. */
  protected didEndRefreshing(_success: boolean): void {}

  /** Starts refreshing and calls `refreshingHandler`. */
  protected startRefreshing(): void {
    this.start();
  }

  /** Called when a load starts after the footer had no more data. */
  protected willLeaveNoMoreData(): void {}

  /** Whether a pull may start a load after "no more data"; only a footer can say yes. */
  protected get canLoadAfterNoMore(): boolean {
    return false;
  }

  /** Sets "no more data" for subclasses; notifies the listeners. */
  protected setNoMoreData(value: boolean): void {
    if (this.noMoreData === value) {
      return;
    }
    this.noMoreData = value;
    this.notifyListeners();
  }

  /**
   * Called by `CYLRefresh` while the content is pulled by `offset` points past this component's edge. `dragging` says
   * whether a finger holds the content; `startedAtEdge` whether the drag began at the edge.
   */
  handlePull(offset: number, dragging: boolean, startedAtEdge: boolean = true): void {
    if (this.disposed) {
      return;
    }
    const visible = offset > 0 || this.currentDragOffset > 0;
    if (!visible && !this.notifiesWhenHidden) {
      return;
    }
    const changed = offset !== this.currentDragOffset;
    this.currentDragOffset = offset < 0 ? 0 : offset;
    this.currentPullingPercent = this.triggerOffset > 0 ? this.currentDragOffset / this.triggerOffset : 0;
    const armed =
      this.refreshEnabled &&
      !(this.noMoreData && !this.canLoadAfterNoMore) &&
      !(this.triggerMode === CYLRefreshTriggerMode.onEdge && !startedAtEdge);
    if (dragging && !this.isRefreshing && this.currentPhase !== CYLRefreshPhase.finishing) {
      if (!armed || this.currentDragOffset <= 0) {
        if (this.currentPhase !== CYLRefreshPhase.idle) {
          this.setPhase(CYLRefreshPhase.idle);
        }
      } else if (this.currentDragOffset >= this.triggerOffset) {
        if (this.currentPhase !== CYLRefreshPhase.releaseToRefresh) {
          this.setPhase(CYLRefreshPhase.releaseToRefresh);
          if (this.hapticFeedback) {
            CYLRefreshComponent.hapticImpact?.();
          }
        }
        if (this.triggersWhenReached && (!this.exclusiveWithOtherRefresh || !(this.host?.isOtherRefreshing(this) ?? false))) {
          this.start();
          return;
        }
      } else if (this.currentPhase !== CYLRefreshPhase.pullToRefresh) {
        this.setPhase(CYLRefreshPhase.pullToRefresh);
      }
    }
    if (changed || this.notifiesWhenHidden) {
      this.notifyListeners();
    }
  }

  /** Called by `CYLRefresh` when the finger lifts: an armed component starts refreshing. */
  handleRelease(): void {
    if (this.disposed) {
      return;
    }
    if (this.currentPhase === CYLRefreshPhase.releaseToRefresh) {
      if (this.exclusiveWithOtherRefresh && (this.host?.isOtherRefreshing(this) ?? false)) {
        this.setPhase(CYLRefreshPhase.idle);
        return;
      }
      this.openDuration = null;
      this.openOverOffset = 0;
      this.start();
    } else if (this.currentPhase === CYLRefreshPhase.pullToRefresh) {
      this.setPhase(CYLRefreshPhase.idle);
    }
  }

  /** Draws the indicator inside the space the pull opens: the default calls `builder` (a React node, or null). */
  buildIndicator(): unknown {
    return this.builder !== null ? this.builder(this) : null;
  }

  /** Stops the timer and drops the listeners and observers; the component does nothing afterwards. */
  override dispose(): void {
    this.disposed = true;
    this.clearFinishTimer();
    this.observers = [];
    super.dispose();
  }

  private clearFinishTimer(): void {
    if (this.finishTimer !== null) {
      clearTimeout(this.finishTimer);
      this.finishTimer = null;
    }
  }

  private close(): void {
    this.finishTimer = null;
    if (this.disposed) {
      return;
    }
    this.currentDragOffset = 0;
    this.currentPullingPercent = 0;
    this.setPhase(CYLRefreshPhase.idle);
  }

  private start(): void {
    this.clearFinishTimer();
    this.currentLastRefreshSucceeded = true;
    if (this.noMoreData) {
      this.noMoreData = false;
      this.willLeaveNoMoreData();
    }
    this.setPhase(CYLRefreshPhase.releasing);
    this.setPhase(CYLRefreshPhase.refreshing);
    this.refreshingHandler?.();
  }

  private setPhase(phase: CYLRefreshPhase): void {
    if (phase === this.currentPhase) {
      return;
    }
    const old = this.currentPhase;
    this.currentPhase = phase;
    for (const observer of [...this.observers]) {
      observer(this, phase, old);
    }
    this.notifyListeners();
  }
}

/** The header: pulled down at the top of the content; refreshes. */
export class CYLRefreshHeader extends CYLRefreshComponent {
  /** True: refreshing the header also resets the footer's "no more data" (`CYLRefreshPaging` does it for you). */
  resetsFooterAfterRefresh: boolean;
  /** When the last successful refresh ended, or null. */
  lastUpdatedTime: Date | null = null;

  /** Creates a header; see `CYLRefreshComponentOptions` for the shared arguments. */
  constructor(options: CYLRefreshComponentOptions & { resetsFooterAfterRefresh?: boolean } = {}) {
    super(options);
    this.resetsFooterAfterRefresh = options.resetsFooterAfterRefresh ?? false;
  }

  /** Always true. */
  get isHeader(): boolean {
    return true;
  }

  protected override didEndRefreshing(success: boolean): void {
    if (success) {
      this.lastUpdatedTime = new Date();
    }
  }
}

/** The footer: pulled up at the bottom of the content; loads more. */
export class CYLRefreshFooter extends CYLRefreshComponent {
  /** True: a pull may start another load after "no more data". */
  loadsAfterNoMoreData: boolean;

  /** Creates a footer; see `CYLRefreshComponentOptions` for the shared arguments. */
  constructor(options: CYLRefreshComponentOptions & { loadsAfterNoMoreData?: boolean } = {}) {
    super(options);
    this.loadsAfterNoMoreData = options.loadsAfterNoMoreData ?? false;
  }

  /** Always false. */
  get isHeader(): boolean {
    return false;
  }

  protected override get canLoadAfterNoMore(): boolean {
    return this.loadsAfterNoMoreData;
  }

  override beginRefreshing(options: CYLRefreshBeginOptions = {}): void {
    if (!(options.force ?? false) && this.isNoMoreData && !this.loadsAfterNoMoreData) {
      return;
    }
    super.beginRefreshing(options);
  }

  /** Ends the load and shows "no more data". Does nothing unless refreshing. */
  endRefreshingWithNoMoreData(): void {
    if (!this.isRefreshing) {
      return;
    }
    this.setNoMoreData(true);
    this.endRefreshing(true);
  }

  /** Shows "no more data" without a load (for example after the first page was the last one). */
  noticeNoMoreData(): void {
    this.setNoMoreData(true);
  }

  /** Clears "no more data". */
  resetNoMoreData(): void {
    if (!this.isNoMoreData) {
      return;
    }
    this.setNoMoreData(false);
  }
}

/** A footer that loads when the content scrolls near its end, without a pull. */
export class CYLRefreshAutoFooter extends CYLRefreshFooter {
  /** True: load automatically near the end. */
  automaticallyRefresh: boolean;
  /** How much of the footer must be visible to trigger: 1 loads as soon as it appears, 0 only at its far edge. */
  triggerAutomaticallyRefreshPercent: number;
  /** How many automatic loads may start before the user pulls once; 0 for no limit. */
  autoTriggerTimes: number;
  private autoTriggered: number = 0;

  /** Creates an auto footer; see `CYLRefreshComponentOptions` for the shared arguments. */
  constructor(
    options: CYLRefreshComponentOptions & {
      loadsAfterNoMoreData?: boolean;
      automaticallyRefresh?: boolean;
      triggerAutomaticallyRefreshPercent?: number;
      autoTriggerTimes?: number;
    } = {}
  ) {
    super(options);
    this.automaticallyRefresh = options.automaticallyRefresh ?? true;
    this.triggerAutomaticallyRefreshPercent = options.triggerAutomaticallyRefreshPercent ?? 1;
    this.autoTriggerTimes = options.autoTriggerTimes ?? 1;
  }

  /** How many automatic loads have started since the last pull or reset. */
  get autoTriggeredCount(): number {
    return this.autoTriggered;
  }

  /** Called by `CYLRefresh` with how far the content end is below the viewport's bottom edge, in points. */
  handleDistanceToEnd(distanceToEnd: number): void {
    if (!this.automaticallyRefresh || !this.refreshEnabled || this.isRefreshing || this.phase === CYLRefreshPhase.finishing) {
      return;
    }
    if (this.isNoMoreData && !this.loadsAfterNoMoreData) {
      return;
    }
    if (this.autoTriggerTimes > 0 && this.autoTriggered >= this.autoTriggerTimes) {
      return;
    }
    if (distanceToEnd > (1 - this.triggerAutomaticallyRefreshPercent) * this.expandHeight) {
      return;
    }
    const before = this.phase;
    this.beginRefreshing({ duration: 0, overOffset: 0 });
    if (before !== this.phase && this.isRefreshing) {
      this.autoTriggered += 1;
    }
  }

  override handleRelease(): void {
    const wasArmed = this.phase === CYLRefreshPhase.releaseToRefresh;
    super.handleRelease();
    if (wasArmed) {
      this.autoTriggered = 0;
    }
  }

  override resetNoMoreData(): void {
    super.resetNoMoreData();
    this.autoTriggered = 0;
  }
}

/** A footer that loads when the content is pulled up past its end, like the header. */
export class CYLRefreshBackFooter extends CYLRefreshFooter {}

/** A header without a drawing: `addPhaseObserver` and `refreshingHandler` only. */
export class CYLRefreshListenerHeader extends CYLRefreshHeader {
  /** Creates a drawing-free header. */
  constructor(options: Pick<CYLRefreshComponentOptions, 'refreshingHandler' | 'notifiesWhenHidden' | 'expandHeight' | 'scrollMode'> = {}) {
    super(options);
  }
}

/** A footer without a drawing: `addPhaseObserver` and `refreshingHandler` only. */
export class CYLRefreshListenerFooter extends CYLRefreshFooter {
  /** Creates a drawing-free footer. */
  constructor(options: Pick<CYLRefreshComponentOptions, 'refreshingHandler' | 'notifiesWhenHidden' | 'expandHeight' | 'scrollMode'> = {}) {
    super(options);
  }
}
