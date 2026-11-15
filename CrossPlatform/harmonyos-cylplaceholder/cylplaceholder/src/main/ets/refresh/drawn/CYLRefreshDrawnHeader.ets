// CYLRefreshDrawnHeader: the HarmonyOS counterpart of iOS Custom/Drawn/CYLRefreshDrawnHeader.h and CYLRefreshDrawnFooter.h:
// a header whose look is drawn in code, with SmartRefreshControl's hooks (setUpComponent, onStatus:changed:,
// onScrollingWithOffset:percent:drag:, onStartAnimationWhenRealeasing, ...), and a back footer drawn by a hosted
// ("driven") header. CYLRefresh's phases are mapped onto `status` in SmartRefreshControl's order (releasing is
// always passed through before refreshing, finishing after it until the header has retracted).
//
// iOS drawRect: is `drawInContext(ctx)`: `CYLRefreshDrawnView` (CYLRefreshDrawnView.ets) hosts a header on an ArkUI
// Canvas inside `CYLRefreshComponentView`, sets `width` to the canvas width and calls `cyl_render` every display
// frame while there is something to draw; `cyl_now` / `cyl_frameSeconds` are the frame clock the styles step by.
// The model itself has no ArkUI dependency beyond the canvas type in drawInContext (host unit-tested).
import {
  CYLRefreshBackStateFooterModel
} from '../CYLRefreshClassics';
import {
  CYLRefreshHeaderModel,
  CYLRefreshOffsetChange,
  CYLRefreshScrollViewModel
} from '../CYLRefreshComponent';
import { CYLRefreshPhase, CYLRefreshScrollMode, CYLRefreshState } from '../CYLRefreshConst';

/** The touch phases the drawn view forwards to a header (`cyl_touch`). */
export enum CYLRefreshDrawnTouch {
  Down = 0,
  Move = 1,
  Up = 2
}

export class CYLRefreshDrawnHeaderModel extends CYLRefreshHeaderModel {
  /** Duration of the styles' short animations, in seconds (`durationFast`, 0.1). */
  durationFast: number = 0.1;
  /** Duration of the styles' normal animations, in seconds (`durationNormal`, 0.25). */
  durationNormal: number = 0.25;
  /** True when touches go to the content under the header (iOS `userInteractionEnabled = NO` on a style). */
  cyl_passesTouches: boolean = false;
  /** The frame time of the drawing in progress, in ms. */
  cyl_now: number = 0;
  /** Seconds since the previous frame (at most 0.1). */
  cyl_frameSeconds: number = 0;
  /** The height of the canvas being drawn. */
  cyl_canvasHeight: number = 0;
  /** True while a footer drives the header (iOS `cyl_driven`). */
  cyl_driven: boolean = false;
  /** The pulled distance a footer gave (iOS `cyl_drivenOffset`). */
  cyl_drivenOffset: number = 0;
  /** The result a footer gave (iOS `cyl_drivenSuccess`). */
  cyl_drivenSuccess: boolean = true;
  /** The frame height a footer gave (iOS `cyl_drivenFrame.size.height`). */
  cyl_drivenHeight: number = 0;
  private statusValue: CYLRefreshPhase = CYLRefreshPhase.Idle;
  private lastOffset: number = -1;
  private lastFrame: number = 0;
  private drewSomething: boolean = true;

  constructor() {
    super();
    this.colorAccent = '#555555';
    this.setUpComponent();
  }

  // MARK: - Size

  /** The frame width (`width`); the drawn view sets it to the canvas width. */
  get width(): number {
    return this.cyl_w;
  }

  set width(value: number) {
    this.cyl_w = value;
  }

  /** The open height; setting it calls `setExpandHeight` (`height`). */
  get height(): number {
    return this.cyl_driven && this.cyl_drivenHeight > 0 ? this.cyl_drivenHeight : this.cyl_h;
  }

  set height(value: number) {
    this.setExpandHeight(value);
  }

  /** Points pulled below the content's top, the open height included while refreshing (`dragOffset`). */
  get dragOffset(): number {
    if (this.cyl_driven) {
      return this.cyl_drivenOffset;
    }
    const sv = this.scrollView;
    if (sv === null) {
      return 0;
    }
    return Math.max(0, -(sv.cyl_offsetY + this.scrollViewOriginalInset.top));
  }

  /** dragOffset / (expandHeight × triggerRate) (`dragPercent`). */
  get dragPercent(): number {
    return this.dragOffset / Math.max(1, this.expandHeight * this.triggerRate);
  }

  /** Whether the last refresh succeeded (`isSuccess`). */
  get isSuccess(): boolean {
    return this.cyl_driven ? this.cyl_drivenSuccess : this.lastRefreshSucceeded;
  }

  /** Whether the header refreshes; a driven header follows its footer's status (iOS `isRefreshing`). */
  cyl_isRefreshing(): boolean {
    if (this.cyl_driven) {
      return this.statusValue === CYLRefreshPhase.Refreshing;
    }
    return this.refreshing;
  }

  // MARK: - Status

  /** The phase as SmartRefreshControl reports it (`status`). */
  get status(): CYLRefreshPhase {
    return this.statusValue;
  }

  protected cyl_setStatus(status: CYLRefreshPhase): void {
    const old = this.statusValue;
    if (old === status) {
      return;
    }
    this.statusValue = status;
    if (this.scrollView !== null || this.cyl_driven) {
      this.onStatus(old, status);
    }
  }

  /** Set-up hook, called once from the constructor; subclasses call super (`-setUpComponent`). */
  setUpComponent(): void {
  }

  /** `status` changed; the start hooks run on the next turn, as in SmartRefreshControl (`-onStatus:changed:`). */
  onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase): void {
    if (status === CYLRefreshPhase.Releasing) {
      setTimeout(() => this.onStartAnimationWhenRealeasing(), 0);
    } else if (status === CYLRefreshPhase.Refreshing) {
      setTimeout(() => this.onStartAnimationWhenRefreshing(), 0);
    }
  }

  phaseDidChangeFrom(oldPhase: CYLRefreshPhase, phase: CYLRefreshPhase): void {
    super.phaseDidChangeFrom(oldPhase, phase);
    switch (phase) {
      case CYLRefreshPhase.Refreshing:
        if (this.statusValue !== CYLRefreshPhase.Releasing) {
          this.cyl_setStatus(CYLRefreshPhase.Releasing);
        }
        this.cyl_setStatus(CYLRefreshPhase.Refreshing);
        break;
      case CYLRefreshPhase.Idle:
        if (this.statusValue === CYLRefreshPhase.Refreshing) {
          this.cyl_setStatus(CYLRefreshPhase.Finishing);
        }
        if (this.statusValue !== CYLRefreshPhase.Finishing || this.dragOffset <= 0.5) {
          this.cyl_setStatus(CYLRefreshPhase.Idle);
        }
        break;
      default:
        this.cyl_setStatus(phase);
        break;
    }
  }

  /** True when `status` is one of `statuses` (`-inStatus:`). */
  inStatus(...statuses: CYLRefreshPhase[]): boolean {
    return statuses.includes(this.statusValue);
  }

  // MARK: - Scrolling

  scrollViewContentOffsetDidChange(change: CYLRefreshOffsetChange): void {
    super.scrollViewContentOffsetDidChange(change);
    const offset = this.dragOffset;
    if (this.statusValue === CYLRefreshPhase.Finishing && this.state === CYLRefreshState.Idle && offset <= 0.5) {
      this.cyl_setStatus(CYLRefreshPhase.Idle);
    }
    if (offset === this.lastOffset) {
      return;
    }
    this.lastOffset = offset;
    const sv = this.scrollView;
    if (sv !== null) {
      this.scrollViewDidScroll(sv, offset, this.dragPercent, sv.isDragging);
    }
  }

  /** Every scroll; calls onScrollingWithOffset (`-scrollView:didScroll:percent:drag:`). */
  scrollViewDidScroll(scrollView: CYLRefreshScrollViewModel | null, offset: number, percent: number,
    isDragging: boolean): void {
    this.onScrollingWithOffset(offset, percent, isDragging);
  }

  /** Every scroll; follow the pull here (`-onScrollingWithOffset:percent:drag:`). */
  onScrollingWithOffset(offset: number, percent: number, isDragging: boolean): void {
  }

  /** Released past the trigger, or beginRefreshing (`-onStartAnimationWhenRealeasing`). */
  onStartAnimationWhenRealeasing(): void {
  }

  /** The refresh started (`-onStartAnimationWhenRefreshing`). */
  onStartAnimationWhenRefreshing(): void {
  }

  /** The refresh ended with `success` (`-onRefreshFinished:`). */
  onRefreshFinished(success: boolean): void {
  }

  /** Seconds to stay open after the refresh ends; finishDuration by default (`-onRefreshFinishing:`). */
  onRefreshFinishing(success: boolean): number {
    return this.finishDuration;
  }

  // MARK: - Attaching

  didAttachToScrollView(scrollView: CYLRefreshScrollViewModel): void {
    super.didAttachToScrollView(scrollView);
    this.scrollViewAttached(scrollView, true);
  }

  willDetachFromScrollView(scrollView: CYLRefreshScrollViewModel): void {
    this.scrollViewAttached(scrollView, false);
    super.willDetachFromScrollView(scrollView);
  }

  /** Attached to or detached from a scroll view (`-scrollView:attached:`). */
  scrollViewAttached(scrollView: CYLRefreshScrollViewModel | null, attach: boolean): void {
  }

  // MARK: - Refreshing

  /** beginRefreshing, under SmartRefreshControl's name (`-beginRefresh`). */
  beginRefresh(): void {
    this.beginRefreshing();
  }

  /** endRefreshing, under SmartRefreshControl's name (`-finishRefresh`). */
  finishRefresh(): void {
    this.finishRefreshWithSuccess(true);
  }

  /** Every end goes through finishRefreshWithSuccess, so styles overriding it see each end. */
  endRefreshingWithSuccess(success: boolean): void {
    this.finishRefreshWithSuccess(success);
  }

  /** endRefreshingWithSuccess, under SmartRefreshControl's name (`-finishRefreshWithSuccess:`). */
  finishRefreshWithSuccess(success: boolean): void {
    super.endRefreshingWithSuccess(success);
  }

  refreshDidFinishWithSuccess(success: boolean): void {
    super.refreshDidFinishWithSuccess(success);
    this.cyl_setStatus(CYLRefreshPhase.Finishing);
    this.onRefreshFinished(success);
  }

  finishingDurationWithSuccess(success: boolean): number {
    return this.onRefreshFinishing(success);
  }

  // MARK: - Driven by a footer

  /** A footer hosts the header (iOS `cyl_beginDriven`). */
  cyl_beginDriven(): void {
    this.cyl_driven = true;
    this.autoHideRefresh = false;
  }

  /** The footer's pulled distance (iOS `cyl_driveOffset:drag:`). */
  cyl_driveOffset(offset: number, isDragging: boolean): void {
    if (offset === this.cyl_drivenOffset && offset === this.lastOffset) {
      return;
    }
    this.cyl_drivenOffset = offset;
    this.lastOffset = offset;
    this.scrollViewDidScroll(this.scrollView, offset, this.dragPercent, isDragging);
  }

  /** The footer's status (iOS `cyl_driveStatus:`). */
  cyl_driveStatus(status: CYLRefreshPhase): void {
    this.cyl_setStatus(status);
  }

  /** The footer's refresh ended (iOS `cyl_driveFinished:`). */
  cyl_driveFinished(success: boolean): void {
    this.cyl_drivenSuccess = success;
    this.cyl_setStatus(CYLRefreshPhase.Finishing);
    this.onRefreshFinished(success);
  }

  // MARK: - Drawing

  /** colorPrimary, or clear. */
  get cyl_primaryColor(): string {
    return this.colorPrimary !== null ? this.colorPrimary : 'transparent';
  }

  /** colorAccent, or clear. */
  get cyl_accentColor(): string {
    return this.colorAccent !== null ? this.colorAccent : 'transparent';
  }

  /** The clock of the status hooks, in ms (the frame clock's time base). */
  cyl_clock(): number {
    return Date.now();
  }

  /** How far below its frame a style draws (Material's disc, the WaveSwipe drop), in vp; 0 for none. */
  cyl_overflowHeight(): number {
    return 0;
  }

  /** Draws the header in its frame, origin at the top of the view (iOS `drawRect:`); subclasses override. */
  drawInContext(ctx: CanvasRenderingContext2D): void {
  }

  /** True while a style animates by itself (outside the pull and the refresh). */
  cyl_isAnimating(): boolean {
    return false;
  }

  /** Whether a frame has anything to draw. */
  cyl_wantsFrame(): boolean {
    return this.dragOffset > 0 || this.statusValue !== CYLRefreshPhase.Idle || this.cyl_isAnimating() ||
      this.scrollMode === CYLRefreshScrollMode.Move || this.scrollMode === CYLRefreshScrollMode.Behind;
  }

  /** The width changed (iOS setFrame: / scrollView:attached: layouts); subclasses override. */
  cyl_layoutWidth(width: number): void {
  }

  /** Draws one frame on a `width` x `height` canvas at `now` ms; false when nothing needed drawing. */
  cyl_render(ctx: CanvasRenderingContext2D, width: number, height: number, now: number): boolean {
    const wants = this.cyl_wantsFrame();
    if (!wants && !this.drewSomething) {
      return false;
    }
    this.drewSomething = wants;
    if (width !== this.cyl_w) {
      this.cyl_w = width;
      this.cyl_layoutWidth(width);
    }
    this.cyl_canvasHeight = height;
    this.cyl_frameSeconds = this.lastFrame > 0 ? Math.min(0.1, Math.max(0, (now - this.lastFrame) / 1000)) : 0;
    this.lastFrame = now;
    this.cyl_now = now;
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, width, height);
    ctx.globalAlpha = 1;
    if (wants) {
      ctx.save();
      this.drawInContext(ctx);
      ctx.restore();
    }
    return true;
  }

  /** A touch on the header at (x, y) in its frame; the game headers play with it. */
  cyl_touch(touch: CYLRefreshDrawnTouch, x: number, y: number): void {
  }
}

/**
 * A pull-up footer drawn by a hosted drawn header (iOS `CYLRefreshDrawnFooter`): the header gets the distance
 * pulled past the content, the progress and the SmartRefreshControl status order. Only "no more data" is a label.
 * A subclass names its style by overriding `newStyle` (iOS `+styleClass`).
 */
export class CYLRefreshDrawnFooterModel extends CYLRefreshBackStateFooterModel {
  private styleModel: CYLRefreshDrawnHeaderModel | undefined = undefined;

  constructor() {
    super();
    const style = this.newStyle();
    if (style !== null) {
      this.cyl_installStyle(style);
    }
  }

  /** A footer drawn by `style`, at the style's open height (`-initWithStyle:`). */
  static initWithStyle(style: CYLRefreshDrawnHeaderModel): CYLRefreshDrawnFooterModel {
    const footer = new CYLRefreshDrawnFooterModel();
    footer.cyl_installStyle(style);
    return footer;
  }

  /** The header a subclass hosts, made fresh; null in the base class (iOS `+styleClass`). */
  newStyle(): CYLRefreshDrawnHeaderModel | null {
    return null;
  }

  /** The hosted header, or null (`style`). */
  get style(): CYLRefreshDrawnHeaderModel | null {
    return this.styleModel !== undefined ? this.styleModel : null;
  }

  private cyl_installStyle(style: CYLRefreshDrawnHeaderModel): void {
    this.styleModel = style;
    style.cyl_beginDriven();
    this.cyl_h = style.expandHeight;
    this.stateLabel.hidden = this.state !== CYLRefreshState.NoMoreData;
    style.hidden = this.state === CYLRefreshState.NoMoreData;
    this.cyl_setNeedsLayout();
  }

  /** The footer's colors, when set, go to the style (iOS setColorAccent: / setColorPrimary:). */
  cyl_syncStyleColors(): void {
    const style = this.style;
    if (style === null) {
      return;
    }
    if (this.colorAccent !== null) {
      style.colorAccent = this.colorAccent;
    }
    if (this.colorPrimary !== null) {
      style.colorPrimary = this.colorPrimary;
    }
  }

  /** Points pulled past the content's bottom, the open height included while loading. */
  cyl_pulled(): number {
    const sv = this.scrollView;
    if (sv === null) {
      return 0;
    }
    return Math.max(0, sv.cyl_offsetY - this.cyl_happenOffsetY());
  }

  private cyl_layoutStyle(): void {
    const style = this.style;
    if (style === null) {
      return;
    }
    let height = style.expandHeight;
    if (style.scrollMode === CYLRefreshScrollMode.Stretch) {
      height = Math.max(height, this.cyl_pulled());
    }
    style.cyl_drivenHeight = height;
  }

  placeSubviews(): void {
    super.placeSubviews();
    this.cyl_layoutStyle();
  }

  scrollViewContentOffsetDidChange(change: CYLRefreshOffsetChange): void {
    super.scrollViewContentOffsetDidChange(change);
    const style = this.style;
    if (style === null || this.state === CYLRefreshState.NoMoreData) {
      return;
    }
    const pulled = this.cyl_pulled();
    if (style.status === CYLRefreshPhase.Finishing && this.state === CYLRefreshState.Idle && pulled <= 0.5) {
      style.cyl_driveStatus(CYLRefreshPhase.Idle);
    }
    this.cyl_layoutStyle();
    const sv = this.scrollView;
    style.cyl_driveOffset(pulled, sv !== null && sv.isDragging);
  }

  didAttachToScrollView(scrollView: CYLRefreshScrollViewModel): void {
    super.didAttachToScrollView(scrollView);
    const style = this.style;
    if (style !== null) {
      style.scrollViewAttached(scrollView, true);
    }
  }

  willDetachFromScrollView(scrollView: CYLRefreshScrollViewModel): void {
    const style = this.style;
    if (style !== null) {
      style.scrollViewAttached(scrollView, false);
    }
    super.willDetachFromScrollView(scrollView);
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    const noMoreData = state === CYLRefreshState.NoMoreData;
    this.stateLabel.hidden = !noMoreData;
    const style = this.style;
    if (style !== null) {
      style.hidden = noMoreData;
    }
  }

  phaseDidChangeFrom(oldPhase: CYLRefreshPhase, phase: CYLRefreshPhase): void {
    super.phaseDidChangeFrom(oldPhase, phase);
    const style = this.style;
    if (style === null) {
      return;
    }
    switch (phase) {
      case CYLRefreshPhase.Refreshing:
        if (style.status !== CYLRefreshPhase.Releasing) {
          style.cyl_driveStatus(CYLRefreshPhase.Releasing);
        }
        style.cyl_driveStatus(CYLRefreshPhase.Refreshing);
        break;
      case CYLRefreshPhase.Idle:
        if (style.status === CYLRefreshPhase.Refreshing) {
          style.cyl_driveStatus(CYLRefreshPhase.Finishing);
        }
        if (style.status !== CYLRefreshPhase.Finishing || this.cyl_pulled() <= 0.5) {
          style.cyl_driveStatus(CYLRefreshPhase.Idle);
        }
        break;
      case CYLRefreshPhase.NoMoreData:
        style.cyl_driveStatus(CYLRefreshPhase.Idle);
        break;
      default:
        style.cyl_driveStatus(phase);
        break;
    }
  }

  refreshDidFinishWithSuccess(success: boolean): void {
    super.refreshDidFinishWithSuccess(success);
    const style = this.style;
    if (style !== null) {
      style.cyl_driveFinished(success);
    }
  }

  finishingDurationWithSuccess(success: boolean): number {
    const style = this.style;
    return style !== null ? style.onRefreshFinishing(success) : super.finishingDurationWithSuccess(success);
  }
}
