// CYLRefreshComponent: the HarmonyOS counterpart of iOS CYLRefreshComponent.h, CYLRefreshHeader.h, CYLRefreshFooter.h,
// CYLRefreshAutoFooter.h, CYLRefreshBackFooter.h, CYLRefreshTrailer.h, UIScrollView+CYLRefresh.h,
// UIScrollView+CYLExtension.h and UIView+CYLExtension.h: the state machine of the MJRefresh-compatible controls, with
// no ArkUI dependency (host unit-tested). The iOS logic is kept: a control reads the scroll view's contentOffset,
// contentInset and contentSize and the pan state, and moves Idle -> Pulling -> Refreshing -> Idle (or NoMoreData).
//
// On HarmonyOS the scroll view is a `CYLRefreshScrollViewModel` that the `CYLRefreshContainer` component (see
// CYLRefreshView.ets) drives from the List / Scroll / Grid it wraps: the real scroll offset of its Scroller plus the
// over-scroll pulled by a parallel PanGesture at the edges ("reveals"). contentOffset therefore has the iOS meaning:
// negative when the content is pulled down past its top, beyond the end when pulled up past its end.
import { vibrator } from '@kit.SensorServiceKit';
import { CYLEdgeInsets } from '../CYLPlaceholderViewTypes';
import {
  CYLRefreshComponentAction,
  CYLRefreshConfig,
  CYLRefreshFastAnimationDuration,
  CYLRefreshFooterHeight,
  CYLRefreshHeaderHeight,
  CYLRefreshHeaderLastUpdatedTimeKey,
  CYLRefreshLanguageObserver,
  CYLRefreshPhase,
  CYLRefreshScrollMode,
  CYLRefreshSlowAnimationDuration,
  CYLRefreshState,
  CYLRefreshTrailWidth,
  CYLRefreshTriggerMode,
  CYLScrollDirection
} from './CYLRefreshConst';
import { CYLRefreshIconAttributes, CYLRefreshIconSize, CYLRefreshIconViewModel } from './CYLRefreshIconView';

/** Runs `changes` animated over `duration` seconds, then `completion` (the container uses ArkUI animateTo). */
export type CYLRefreshAnimator = (duration: number, changes: () => void, completion: () => void) => void;
/** Called after a model changed; the components re-render. */
export type CYLRefreshChangeListener = () => void;
/** Called with the component when it starts refreshing (iOS `CYLRefreshComponentHandler`). */
export type CYLRefreshComponentHandler = (component: CYLRefreshComponentModel) => void;
/** The action of a target-action pair (iOS SEL); a bound function receiving the component. */
export type CYLRefreshTargetAction = (component: CYLRefreshComponentModel) => void;
/** Called with the component, the old and the new phase (iOS `addPhaseObserver:`). */
export type CYLRefreshPhaseObserver = (component: CYLRefreshComponentModel, oldPhase: CYLRefreshPhase,
  phase: CYLRefreshPhase) => void;
/** Counts the rows of the wrapped list (iOS `cyl_totalDataCount` reads the table's data source). */
export type CYLRefreshDataCountProvider = () => number;

/** The pan gesture's state (iOS UIGestureRecognizerState). */
export enum CYLRefreshPanState {
  Possible = 0,
  Began = 1,
  Changed = 2,
  Ended = 3,
  Cancelled = 4
}

/** A size in vp (CGSize). */
export class CYLSize {
  width: number;
  height: number;

  constructor(width: number, height: number) {
    this.width = width;
    this.height = height;
  }
}

/** A point in vp (CGPoint). */
export class CYLPoint {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

/** The old and new content offset of a scroll (the KVO change dictionary). */
export class CYLRefreshOffsetChange {
  oldX: number;
  oldY: number;
  newX: number;
  newY: number;

  constructor(oldX: number, oldY: number, newX: number, newY: number) {
    this.oldX = oldX;
    this.oldY = oldY;
    this.newX = newX;
    this.newY = newY;
  }
}

/**
 * A view's frame, alpha and visibility (iOS `UIView (CYLExtension)`): the base of the scroll view and of every
 * control model. `cyl_setNeedsLayout()` runs `placeSubviews()` and re-renders the component drawing the model.
 */
export class CYLRefreshViewModel {
  cyl_x: number = 0;
  cyl_y: number = 0;
  cyl_w: number = 0;
  cyl_h: number = 0;
  /** The view's opacity (UIView alpha). */
  alpha: number = 1;
  private hiddenValue: boolean = false;
  private changeListeners: CYLRefreshChangeListener[] = [];

  /** Whether the view is hidden (UIView hidden); a change re-renders the component drawing the model. */
  get hidden(): boolean {
    return this.hiddenValue;
  }

  set hidden(value: boolean) {
    if (value === this.hiddenValue) {
      return;
    }
    this.hiddenValue = value;
    this.changeListeners.slice().forEach((l: CYLRefreshChangeListener) => l());
  }

  get cyl_size(): CYLSize {
    return new CYLSize(this.cyl_w, this.cyl_h);
  }

  set cyl_size(size: CYLSize) {
    this.cyl_w = size.width;
    this.cyl_h = size.height;
  }

  get cyl_origin(): CYLPoint {
    return new CYLPoint(this.cyl_x, this.cyl_y);
  }

  set cyl_origin(origin: CYLPoint) {
    this.cyl_x = origin.x;
    this.cyl_y = origin.y;
  }

  addChangeListener(listener: CYLRefreshChangeListener): void {
    this.changeListeners.push(listener);
  }

  removeChangeListener(listener: CYLRefreshChangeListener): void {
    this.changeListeners = this.changeListeners.filter((l: CYLRefreshChangeListener) => l !== listener);
  }

  /** Lays the view out again (`placeSubviews`) and re-renders it. */
  cyl_setNeedsLayout(): void {
    this.placeSubviews();
    this.changeListeners.slice().forEach((l: CYLRefreshChangeListener) => l());
  }

  /** Lays the subviews out (iOS `placeSubviews`); subclasses override. */
  placeSubviews(): void {
  }
}

/** A text label of a control (iOS `UILabel (CYLRefresh)`). */
export class CYLRefreshLabel extends CYLRefreshViewModel {
  text: string = '';
  /** The font size in fp (CYLRefreshLabelFont: bold 14). */
  fontSize: number = 14;
  fontWeight: number = 700;
  /** CYLRefreshLabelTextColor: rgb(90, 90, 90). */
  textColor: string = '#5A5A5A';

  /** A label with the refresh font and color (`+cyl_label`). */
  static cyl_label(): CYLRefreshLabel {
    return new CYLRefreshLabel();
  }

  /** The width of the text in vp (`-cyl_textWidth`): a full width per CJK character, 0.6 of the font otherwise. */
  cyl_textWidth(): number {
    let width = 0;
    for (let i = 0; i < this.text.length; i++) {
      const c = this.text.charCodeAt(i);
      width += (c >= 0x2E80 ? 1.0 : (c >= 0x400 ? 0.62 : 0.56)) * this.fontSize;
    }
    return Math.ceil(width);
  }
}

/** An image view of a control (arrow, result, frames): the image, its rotation in degrees and visibility. */
export class CYLRefreshImageViewModel extends CYLRefreshViewModel {
  image: ResourceStr | null = null;
  rotation: number = 0;
}

/** A spinner (iOS UIActivityIndicatorView). */
export class CYLRefreshActivityIndicatorModel extends CYLRefreshViewModel {
  animating: boolean = false;
  /** The spoke color; gray by default. */
  color: string = '#8E8E93';
  /** 0..1, how much of the wheel shows while pulled (Cupertino). */
  progress: number = 0;
  hidesWhenStopped: boolean = true;

  startAnimating(): void {
    this.animating = true;
    this.hidden = false;
  }

  stopAnimating(): void {
    this.animating = false;
    if (this.hidesWhenStopped) {
      this.hidden = true;
    }
  }
}

class CYLTargetActionPair {
  target: Object;
  action: CYLRefreshTargetAction;

  constructor(target: Object, action: CYLRefreshTargetAction) {
    this.target = target;
    this.action = action;
  }
}

/**
 * The scroll view the controls attach to (iOS `UIScrollView` with its `CYLRefresh` and `CYLExtension` categories).
 * The `CYLRefreshContainer` reports the wrapped Scroller's offset, size and the pan gesture; tests drive it directly.
 */
export class CYLRefreshScrollViewModel extends CYLRefreshViewModel {
  /** Runs animated changes; synchronous by default, ArkUI animateTo once a container shows the model. */
  animator: CYLRefreshAnimator = (duration: number, changes: () => void, completion: () => void) => {
    changes();
    completion();
  };
  /** Counts the rows for `cyl_totalDataCount`. */
  dataCountProvider: CYLRefreshDataCountProvider | null = null;
  /** Scrolls the wrapped Scroller (set by the container) when a control moves the content offset. */
  scrollRequest: ((x: number, y: number) => void) | null = null;
  /** Whether the view is on screen (iOS `window != nil`); set by the container. */
  cyl_window: boolean = false;
  /** Whether a finger drags the content (iOS isDragging). */
  isDragging: boolean = false;
  /** The pan gesture's state. */
  panState: CYLRefreshPanState = CYLRefreshPanState.Possible;
  /** The release velocity in vp/s (positive: down / right). */
  panVelocityX: number = 0;
  panVelocityY: number = 0;
  /** iOS pagingEnabled (an auto footer settles to a page after loading). */
  pagingEnabled: boolean = false;
  /**
   * The collection layout's `flipsHorizontallyInOppositeLayoutDirection` (UICollectionViewLayout (CYLRefresh)): set it
   * when the content and its controls are drawn mirrored for a right-to-left layout (for example the container under
   * `.scale({ x: -1 })` while `direction` is Rtl); the controls then flip their texts, arrow and animation view back
   * so they read normally. Content size changes reach the footer through `cyl_contentW` / `cyl_contentH`, the iOS
   * `finalizeCollectionViewUpdates` hook.
   */
  flipsHorizontallyInOppositeLayoutDirection: boolean = false;
  /** The Scroller's own offset (no over-scroll). */
  scrollerX: number = 0;
  scrollerY: number = 0;
  /** The over-scroll shown past each edge, in vp: top (header), bottom (back footer), right (trailer). */
  revealTop: number = 0;
  revealBottom: number = 0;
  revealRight: number = 0;
  private insets: CYLEdgeInsets = new CYLEdgeInsets(0, 0, 0, 0);
  private baseInsets: CYLEdgeInsets = new CYLEdgeInsets(0, 0, 0, 0);
  private contentW: number = 0;
  private contentH: number = 0;
  private header: CYLRefreshHeaderModel | null = null;
  private footer: CYLRefreshFooterModel | null = null;
  private trailer: CYLRefreshTrailerModel | null = null;
  private autoHideHeader: boolean | null = null;
  private autoHideFooter: boolean | null = null;
  private dispatchDepth: number = 0;
  private sampleX: number = Number.NaN;
  private sampleY: number = Number.NaN;
  private distance: number = 0;
  private direction: CYLScrollDirection = CYLScrollDirection.None;

  // MARK: - UIScrollView (CYLExtension)

  get cyl_inset(): CYLEdgeInsets {
    return new CYLEdgeInsets(this.insets.top, this.insets.left, this.insets.bottom, this.insets.right);
  }

  get cyl_insetT(): number {
    return this.insets.top;
  }

  set cyl_insetT(value: number) {
    this.insets.top = value;
    this.cyl_insetsChanged();
  }

  get cyl_insetB(): number {
    return this.insets.bottom;
  }

  set cyl_insetB(value: number) {
    this.insets.bottom = value;
    this.cyl_insetsChanged();
  }

  get cyl_insetL(): number {
    return this.insets.left;
  }

  set cyl_insetL(value: number) {
    this.insets.left = value;
    this.cyl_insetsChanged();
  }

  get cyl_insetR(): number {
    return this.insets.right;
  }

  set cyl_insetR(value: number) {
    this.insets.right = value;
    this.cyl_insetsChanged();
  }

  /** The content offset (iOS meaning): the Scroller's offset plus the over-scroll past the end, minus the top's. */
  get cyl_offsetY(): number {
    return this.scrollerY - this.revealTop + this.revealBottom;
  }

  set cyl_offsetY(value: number) {
    const oldX = this.cyl_offsetX;
    const oldY = this.cyl_offsetY;
    const maxY = this.scrollerMaxY;
    this.revealTop = Math.max(0, -value);
    this.revealBottom = Math.max(0, value - maxY);
    const target = Math.min(Math.max(value, 0), maxY);
    if (target !== this.scrollerY) {
      this.scrollerY = target;
      if (this.scrollRequest !== null) {
        this.scrollRequest(this.scrollerX, target);
      }
    }
    this.cyl_dispatchOffset(oldX, oldY);
  }

  /** The farthest the Scroller itself scrolls down. */
  get scrollerMaxY(): number {
    return Math.max(0, this.contentH - this.cyl_h);
  }

  /** The farthest the Scroller itself scrolls right. */
  get scrollerMaxX(): number {
    return Math.max(0, this.contentW - this.cyl_w);
  }

  get cyl_offsetX(): number {
    return this.scrollerX + this.revealRight;
  }

  set cyl_offsetX(value: number) {
    const oldX = this.cyl_offsetX;
    const oldY = this.cyl_offsetY;
    const maxX = this.scrollerMaxX;
    this.revealRight = Math.max(0, value - maxX);
    const target = Math.min(Math.max(value, 0), maxX);
    if (target !== this.scrollerX) {
      this.scrollerX = target;
      if (this.scrollRequest !== null) {
        this.scrollRequest(target, this.scrollerY);
      }
    }
    this.cyl_dispatchOffset(oldX, oldY);
  }

  get cyl_contentW(): number {
    return this.contentW;
  }

  set cyl_contentW(value: number) {
    if (value === this.contentW) {
      return;
    }
    this.contentW = value;
    this.cyl_components().forEach((c: CYLRefreshComponentModel) => c.scrollViewContentSizeDidChange());
  }

  get cyl_contentH(): number {
    return this.contentH;
  }

  set cyl_contentH(value: number) {
    if (value === this.contentH) {
      return;
    }
    this.contentH = value;
    this.cyl_components().forEach((c: CYLRefreshComponentModel) => c.scrollViewContentSizeDidChange());
  }

  /** Samples the content offset (`-cyl_updateScrollMetrics`): the first sample has no distance nor direction. */
  cyl_updateScrollMetrics(): void {
    const x = this.cyl_offsetX;
    const y = this.cyl_offsetY;
    if (Number.isNaN(this.sampleX)) {
      this.distance = 0;
      this.direction = CYLScrollDirection.None;
    } else {
      const dx = x - this.sampleX;
      const dy = y - this.sampleY;
      if (Math.abs(dy) >= Math.abs(dx)) {
        this.distance = dy;
        this.direction = dy > 0 ? CYLScrollDirection.Down : (dy < 0 ? CYLScrollDirection.Up : CYLScrollDirection.None);
      } else {
        this.distance = dx;
        this.direction = dx > 0 ? CYLScrollDirection.Right : CYLScrollDirection.Left;
      }
    }
    this.sampleX = x;
    this.sampleY = y;
  }

  /** The signed change along the dominant axis at the last sample (`cyl_scrollDistance`). */
  get cyl_scrollDistance(): number {
    return this.distance;
  }

  /** The direction at the last sample (`cyl_scrollDirection`). */
  get cyl_scrollDirection(): CYLScrollDirection {
    return this.direction;
  }

  // MARK: - UIScrollView (CYLRefresh)

  /** The pull-down control (`cyl_header`); setting it attaches it and detaches the old one. */
  get cyl_header(): CYLRefreshHeaderModel | null {
    return this.header;
  }

  set cyl_header(value: CYLRefreshHeaderModel | null) {
    if (value === this.header) {
      return;
    }
    if (this.header !== null) {
      this.header.cyl_moveToScrollView(null);
    }
    this.header = value;
    if (value !== null) {
      if (this.autoHideHeader !== null) {
        value.autoHideRefresh = this.autoHideHeader;
      }
      value.cyl_moveToScrollView(this);
    }
    this.cyl_setNeedsLayout();
  }

  /** The pull-up control (`cyl_footer`). */
  get cyl_footer(): CYLRefreshFooterModel | null {
    return this.footer;
  }

  set cyl_footer(value: CYLRefreshFooterModel | null) {
    if (value === this.footer) {
      return;
    }
    if (this.footer !== null) {
      this.footer.cyl_moveToScrollView(null);
    }
    this.footer = value;
    if (value !== null) {
      if (this.autoHideFooter !== null) {
        value.autoHideRefresh = this.autoHideFooter;
      }
      value.cyl_moveToScrollView(this);
    }
    this.cyl_setNeedsLayout();
  }

  /** The swipe-left control of a horizontal list (`cyl_trailer`). */
  get cyl_trailer(): CYLRefreshTrailerModel | null {
    return this.trailer;
  }

  set cyl_trailer(value: CYLRefreshTrailerModel | null) {
    if (value === this.trailer) {
      return;
    }
    if (this.trailer !== null) {
      this.trailer.cyl_moveToScrollView(null);
    }
    this.trailer = value;
    if (value !== null) {
      value.cyl_moveToScrollView(this);
    }
    this.cyl_setNeedsLayout();
  }

  /** `autoHideRefresh` of the header and the footer at once (`cyl_autoHideRefresh`). */
  get cyl_autoHideRefresh(): boolean {
    return this.cyl_autoHideRefreshHeader && this.cyl_autoHideRefreshFooter;
  }

  set cyl_autoHideRefresh(value: boolean) {
    this.cyl_autoHideRefreshHeader = value;
    this.cyl_autoHideRefreshFooter = value;
  }

  /** `autoHideRefresh` of the header, also applied to a header attached later (`cyl_autoHideRefreshHeader`). */
  get cyl_autoHideRefreshHeader(): boolean {
    return this.header !== null ? this.header.autoHideRefresh : this.autoHideHeader === true;
  }

  set cyl_autoHideRefreshHeader(value: boolean) {
    this.autoHideHeader = value;
    if (this.header !== null) {
      this.header.autoHideRefresh = value;
    }
  }

  /** `autoHideRefresh` of the footer, also applied to a footer attached later (`cyl_autoHideRefreshFooter`). */
  get cyl_autoHideRefreshFooter(): boolean {
    return this.footer !== null ? this.footer.autoHideRefresh : this.autoHideFooter === true;
  }

  set cyl_autoHideRefreshFooter(value: boolean) {
    this.autoHideFooter = value;
    if (this.footer !== null) {
      this.footer.autoHideRefresh = value;
    }
  }

  /**
   * Refreshes once with `startHeader` in place of `cyl_header`, then puts `cyl_header` back
   * (`-cyl_beginRefreshingWithStartHeader:`); without callbacks of its own it uses the regular header's.
   */
  cyl_beginRefreshingWithStartHeader(startHeader: CYLRefreshHeaderModel): void {
    const regular = this.header;
    if (startHeader === regular) {
      startHeader.beginRefreshing();
      return;
    }
    if (regular !== null && !startHeader.cyl_hasCallbacks()) {
      startHeader.cyl_copyTargetActionsFrom(regular);
      startHeader.refreshingBlock = regular.refreshingBlock;
      if (regular.refreshingTarget !== null && regular.refreshingAction !== null) {
        startHeader.setRefreshingTarget(regular.refreshingTarget, regular.refreshingAction);
      }
      const handler = regular.refreshingHandler;
      if (handler !== null) {
        startHeader.refreshingHandler = (c: CYLRefreshComponentModel) => handler(regular);
      }
    }
    let refreshed = false;
    let token = 0;
    token = startHeader.addPhaseObserver((c: CYLRefreshComponentModel, o: CYLRefreshPhase, phase: CYLRefreshPhase) => {
      if (phase === CYLRefreshPhase.Refreshing || phase === CYLRefreshPhase.WillRefresh) {
        refreshed = true;
      }
      if (!refreshed || phase !== CYLRefreshPhase.Idle) {
        return;
      }
      c.removePhaseObserver(token);
      const restore = () => {
        if (this.header === startHeader) {
          this.cyl_header = regular;
        }
      };
      const delay = c.slowAnimationDuration + 0.05;
      if (delay <= 0.05 || !this.cyl_window) {
        restore();
      } else {
        setTimeout(restore, delay * 1000);
      }
    });
    this.cyl_header = startHeader;
    startHeader.beginRefreshing();
  }

  /** The number of rows of the list (`-cyl_totalDataCount`), from `dataCountProvider`; 0 without one. */
  cyl_totalDataCount(): number {
    return this.dataCountProvider !== null ? this.dataCountProvider() : 0;
  }

  // MARK: - Driven by the container (or by tests)

  /** The over-scroll at rest past the top: the refreshing inset added by a control. */
  get restTop(): number {
    return Math.max(0, this.insets.top - this.baseInsets.top);
  }

  /** The over-scroll at rest past the end: the refreshing inset, less the gap below a short content. */
  get restBottom(): number {
    return Math.max(0, this.contentH - this.cyl_h + this.insets.bottom - this.baseInsets.bottom - this.scrollerMaxY);
  }

  get restRight(): number {
    return Math.max(0, this.contentW - this.cyl_w + this.insets.right - this.baseInsets.right - this.scrollerMaxX);
  }

  /** Reports the Scroller's offset, the visible size and the content size. */
  cyl_reportScroll(x: number, y: number, width: number, height: number, contentW: number, contentH: number): void {
    this.cyl_w = width;
    this.cyl_h = height;
    this.cyl_contentW = contentW;
    this.cyl_contentH = contentH;
    if (x === this.scrollerX && y === this.scrollerY) {
      return;
    }
    const oldX = this.cyl_offsetX;
    const oldY = this.cyl_offsetY;
    this.scrollerX = x;
    this.scrollerY = y;
    this.cyl_dispatchOffset(oldX, oldY);
  }

  /** A finger went down (pan Began). */
  cyl_panBegan(): void {
    this.isDragging = true;
    this.panState = CYLRefreshPanState.Began;
    this.cyl_dispatchPan();
    this.panState = CYLRefreshPanState.Changed;
  }

  /** The finger pulls the content `top` vp down past its top, `bottom` up past its end, `right` left past its end. */
  cyl_panChanged(top: number, bottom: number, right: number): void {
    const oldX = this.cyl_offsetX;
    const oldY = this.cyl_offsetY;
    this.revealTop = Math.max(this.restTop, top);
    this.revealBottom = top > 0 ? this.restBottom : Math.max(this.restBottom, bottom);
    this.revealRight = Math.max(this.restRight, right);
    this.cyl_dispatchOffset(oldX, oldY);
  }

  /** The finger lifted (pan Ended, or Cancelled): the controls react, then the content springs back to rest. */
  cyl_panEnded(velocityX: number = 0, velocityY: number = 0, cancelled: boolean = false): void {
    this.isDragging = false;
    this.panVelocityX = velocityX;
    this.panVelocityY = velocityY;
    this.panState = cancelled ? CYLRefreshPanState.Cancelled : CYLRefreshPanState.Ended;
    this.cyl_dispatchPan();
    // The released content still shows the pull: the controls see the offset without a drag (MJRefresh's bounce).
    this.cyl_dispatchOffset(this.cyl_offsetX, this.cyl_offsetY);
    this.panState = CYLRefreshPanState.Possible;
    this.cyl_springBack();
  }

  /** Moves the over-scroll back to rest (animated). */
  cyl_springBack(): void {
    if (this.isDragging) {
      return;
    }
    const top = this.restTop;
    const bottom = this.restBottom;
    const right = this.restRight;
    if (this.revealTop === top && this.revealBottom === bottom && this.revealRight === right) {
      return;
    }
    this.animator(CYLRefreshFastAnimationDuration, () => {
      const oldX = this.cyl_offsetX;
      const oldY = this.cyl_offsetY;
      this.revealTop = top;
      this.revealBottom = bottom;
      this.revealRight = right;
      this.cyl_dispatchOffset(oldX, oldY);
    }, () => {
    });
  }

  /** The container appeared or disappeared (iOS didMoveToWindow): a WillRefresh control starts refreshing. */
  cyl_setWindow(onScreen: boolean): void {
    this.cyl_window = onScreen;
    if (onScreen) {
      this.cyl_components().forEach((c: CYLRefreshComponentModel) => c.cyl_didMoveToWindow());
    }
  }

  /** The attached controls. */
  cyl_components(): CYLRefreshComponentModel[] {
    const all: CYLRefreshComponentModel[] = [];
    if (this.header !== null) {
      all.push(this.header);
    }
    if (this.footer !== null) {
      all.push(this.footer);
    }
    if (this.trailer !== null) {
      all.push(this.trailer);
    }
    return all;
  }

  /** Sets the original insets the controls add their refreshing insets to. */
  cyl_setBaseInsets(insets: CYLEdgeInsets): void {
    this.baseInsets = new CYLEdgeInsets(insets.top, insets.left, insets.bottom, insets.right);
    this.insets = new CYLEdgeInsets(insets.top, insets.left, insets.bottom, insets.right);
    this.cyl_insetsChanged();
  }

  private cyl_insetsChanged(): void {
    if (!this.isDragging) {
      // UIScrollView keeps the offset inside the insets: a smaller inset pulls the over-scroll back.
      this.revealTop = Math.min(this.revealTop, this.restTop);
      this.revealBottom = Math.min(this.revealBottom, this.restBottom);
      this.revealRight = Math.min(this.revealRight, this.restRight);
    }
    this.cyl_components().forEach((c: CYLRefreshComponentModel) => c.scrollViewContentInsetDidChange());
    this.cyl_setNeedsLayout();
  }

  private cyl_dispatchPan(): void {
    this.cyl_components().forEach((c: CYLRefreshComponentModel) => c.scrollViewPanStateDidChange(this.panState));
  }

  private cyl_dispatchOffset(oldX: number, oldY: number): void {
    if (this.dispatchDepth > 4) {
      return;
    }
    this.dispatchDepth++;
    const change = new CYLRefreshOffsetChange(oldX, oldY, this.cyl_offsetX, this.cyl_offsetY);
    this.cyl_components().forEach((c: CYLRefreshComponentModel) => {
      if (c.hidden && !c.notifiesWhenHidden) {
        return;
      }
      c.scrollViewContentOffsetDidChange(change);
      c.didScrollWithOffset(c.dragOffset, c.pullingPercent, this.isDragging);
      c.cyl_reportPhase();
    });
    this.dispatchDepth--;
    this.cyl_setNeedsLayout();
  }
}

let phaseTokens: number = 0;

/**
 * The API every control shares (iOS `CYLRefreshComponent`). Subclass hooks keep the iOS names: `prepare`,
 * `placeSubviews`, `scrollViewContentOffsetDidChange`, `scrollViewContentSizeDidChange`, `scrollViewPanStateDidChange`,
 * `i18nDidChange`, `didAttachToScrollView`, `phaseDidChangeFrom`... The state setter calls `cyl_stateDidChange`
 * (iOS `setState:` after CYLRefreshCheckState).
 */
export class CYLRefreshComponentModel extends CYLRefreshViewModel {
  /** The fast animation's duration, in seconds (`fastAnimationDuration`). */
  fastAnimationDuration: number = CYLRefreshFastAnimationDuration;
  /** The slow animation's duration, in seconds (`slowAnimationDuration`). */
  slowAnimationDuration: number = CYLRefreshSlowAnimationDuration;
  /** Called when the control starts refreshing (`refreshingBlock`). */
  refreshingBlock: CYLRefreshComponentAction | null = null;
  /** Called with the control when it starts refreshing, after refreshingBlock (`refreshingHandler`). */
  refreshingHandler: CYLRefreshComponentHandler | null = null;
  /** The target of `setRefreshingTarget` (`refreshingTarget`). */
  refreshingTarget: Object | null = null;
  /** The action of `setRefreshingTarget` (`refreshingAction`). */
  refreshingAction: CYLRefreshTargetAction | null = null;
  /** Called once a refresh has begun (`beginRefreshingCompletionBlock`). */
  beginRefreshingCompletionBlock: CYLRefreshComponentAction | null = null;
  /** Called when the closing animation starts (`endRefreshingAnimationBeginAction`). */
  endRefreshingAnimationBeginAction: CYLRefreshComponentAction | null = null;
  /** Called once a refresh has ended and closed (`endRefreshingCompletionBlock`). */
  endRefreshingCompletionBlock: CYLRefreshComponentAction | null = null;
  /** Whether a refresh waits while another control of the scroll view refreshes (`exclusiveWithOtherRefresh`). */
  exclusiveWithOtherRefresh: boolean = true;
  /** Called when beginRefreshing is refused because another control refreshes (`blockedByOtherRefreshBlock`). */
  blockedByOtherRefreshBlock: CYLRefreshComponentAction | null = null;
  /** How long the control stays open after the refresh ends, in seconds (`finishDuration`, default 0). */
  finishDuration: number = 0;
  /** The accent color of texts, icons and spinners, or null (`colorAccent`). */
  colorAccent: string | null = null;
  /** The background color, or null (`colorPrimary`). */
  colorPrimary: string | null = null;
  /** Vibrates once when the pull passes the trigger (`hapticFeedback`). */
  hapticFeedback: boolean = false;
  /** The farthest the control can be pulled, in vp; 0 for no limit (`maxPullDistance`). */
  maxPullDistance: number = 0;
  /** Whether the control keeps following the scroll while hidden (`notifiesWhenHidden`). */
  notifiesWhenHidden: boolean = false;
  /** Whether reaching the trigger starts at once, without a release (`triggersWhenReached`). */
  triggersWhenReached: boolean = false;
  /** Where a pull may start (`triggerMode`). */
  triggerMode: CYLRefreshTriggerMode = CYLRefreshTriggerMode.Anywhere;
  /** Whether pulling can refresh (`refreshEnabled`). */
  refreshEnabled: boolean = true;
  /** How the control moves with the pull (`scrollMode`). */
  scrollMode: CYLRefreshScrollMode = CYLRefreshScrollMode.Move;
  /** True while the auto hide keeps the control invisible (the UI reads it). */
  cyl_autoHidden: boolean = false;
  /**
   * More views to flip back, added to `flipsHorizontallyInOppositeLayoutDirectionViews` (`additionalFlipsViews`,
   * empty by default; iOS subclasses override the getter, here it is assigned).
   */
  additionalFlipsViews: CYLRefreshViewModel[] = [];

  /**
   * The views flipped back when the scroll view's layout mirrors its content
   * (`flipsHorizontallyInOppositeLayoutDirectionViews`): the state and time labels, the arrow, the animation view,
   * per class as on iOS. Subclasses add theirs in `cyl_flipViews`.
   */
  get flipsHorizontallyInOppositeLayoutDirectionViews(): CYLRefreshViewModel[] {
    return this.cyl_flipViews();
  }

  /** The class's own views to flip back (the iOS getter overrides); none in the base class. */
  protected cyl_flipViews(): CYLRefreshViewModel[] {
    return [];
  }

  /**
   * Whether `view` is drawn flipped back (iOS `-layoutSubviews`: scale x -1 when the scroll view's layout has
   * `flipsHorizontallyInOppositeLayoutDirection`, for the views of both lists).
   */
  cyl_flipsView(view: CYLRefreshViewModel | null): boolean {
    const scrollView = this.cyl_scrollView;
    if (view === null || scrollView === null || !scrollView.flipsHorizontallyInOppositeLayoutDirection) {
      return false;
    }
    return this.flipsHorizontallyInOppositeLayoutDirectionViews.includes(view) || this.additionalFlipsViews.includes(view);
  }

  /** The x scale the UI draws `view` with: -1 when flipped back, else 1. */
  cyl_flipScaleX(view: CYLRefreshViewModel | null): number {
    return this.cyl_flipsView(view) ? -1 : 1;
  }
  protected cyl_scrollView: CYLRefreshScrollViewModel | null = null;
  protected cyl_originalInset: CYLEdgeInsets = new CYLEdgeInsets(0, 0, 0, 0);
  protected cyl_finishing: boolean = false;
  protected cyl_dragStartedAtEdge: boolean = true;
  private stateValue: CYLRefreshState = CYLRefreshState.Idle;
  private percent: number = 0;
  private alphaFollowsPull: boolean = false;
  private autoHide: boolean = false;
  private rate: number = 1;
  private succeeded: boolean = true;
  private reportedPhase: CYLRefreshPhase = CYLRefreshPhase.Idle;
  private phaseObservers: Map<number, CYLRefreshPhaseObserver> = new Map();
  private targetActions: CYLTargetActionPair[] = [];
  private icon: CYLRefreshIconViewModel | null = null;
  private languageObserver: CYLRefreshLanguageObserver = () => this.i18nDidChange();

  constructor() {
    super();
    this.prepare();
  }

  /** Sets up the control (iOS `prepare`); subclasses call super first. */
  prepare(): void {
  }

  // MARK: - Animation

  /** Sets both animation durations to 0 (`-setAnimationDisabled`). */
  setAnimationDisabled(): CYLRefreshComponentModel {
    this.fastAnimationDuration = 0;
    this.slowAnimationDuration = 0;
    return this;
  }

  // MARK: - Callbacks

  /** Sets the target and its action called on refresh (`-setRefreshingTarget:refreshingAction:`). */
  setRefreshingTarget(target: Object, action: CYLRefreshTargetAction): void {
    this.refreshingTarget = target;
    this.refreshingAction = action;
  }

  /** Adds a target-action called on refresh (`-addTarget:action:`). */
  addTarget(target: Object, action: CYLRefreshTargetAction): void {
    this.targetActions.push(new CYLTargetActionPair(target, action));
  }

  /** Removes the target's action, or all its actions when `action` is null (`-removeTarget:action:`). */
  removeTarget(target: Object, action: CYLRefreshTargetAction | null = null): void {
    this.targetActions = this.targetActions.filter((p: CYLTargetActionPair) =>
      !(p.target === target && (action === null || p.action === action)));
  }

  /** Calls refreshingBlock, refreshingHandler, the target-actions, the target, then beginRefreshingCompletionBlock. */
  executeRefreshingCallback(): void {
    if (this.refreshingBlock !== null) {
      this.refreshingBlock();
    }
    if (this.refreshingHandler !== null) {
      this.refreshingHandler(this);
    }
    this.targetActions.slice().forEach((p: CYLTargetActionPair) => p.action(this));
    if (this.refreshingTarget !== null && this.refreshingAction !== null) {
      this.refreshingAction(this);
    }
    if (this.beginRefreshingCompletionBlock !== null) {
      this.beginRefreshingCompletionBlock();
    }
  }

  /** Whether any refreshing callback is set. */
  cyl_hasCallbacks(): boolean {
    return this.refreshingBlock !== null || this.refreshingHandler !== null || this.refreshingTarget !== null ||
      this.targetActions.length > 0;
  }

  /** Adds `other`'s target-actions. */
  cyl_copyTargetActionsFrom(other: CYLRefreshComponentModel): void {
    other.targetActions.forEach((p: CYLTargetActionPair) => this.addTarget(p.target, p.action));
  }

  // MARK: - Refreshing

  /** Starts refreshing (`-beginRefreshing`); off screen the state is WillRefresh until the control shows. */
  beginRefreshing(): void {
    if (this.cyl_holdsBackStartForOtherRefresh()) {
      return;
    }
    this.alpha = 1;
    this.pullingPercent = 1;
    if (this.cyl_scrollView !== null && this.cyl_scrollView.cyl_window) {
      this.state = CYLRefreshState.Refreshing;
    } else if (this.state !== CYLRefreshState.Refreshing) {
      this.state = CYLRefreshState.WillRefresh;
    }
  }

  /** Starts refreshing and calls `completion` once it has begun (`-beginRefreshingWithCompletionBlock:`). */
  beginRefreshingWithCompletionBlock(completion: CYLRefreshComponentAction): void {
    this.beginRefreshingCompletionBlock = completion;
    this.beginRefreshing();
  }

  /**
   * Starts refreshing with an opening animation of `duration` seconds that overshoots by `overOffset` vp; `force`
   * starts even while another control refreshes (`-beginRefreshingWithDuration:overOffset:force:`).
   */
  beginRefreshingWithDuration(duration: number, overOffset: number, force: boolean): void {
    const savedDuration = this.fastAnimationDuration;
    const savedExclusive = this.exclusiveWithOtherRefresh;
    if (duration > 0) {
      this.fastAnimationDuration = duration;
    }
    if (force) {
      this.exclusiveWithOtherRefresh = false;
    }
    this.beginRefreshing();
    this.exclusiveWithOtherRefresh = savedExclusive;
    this.fastAnimationDuration = savedDuration;
    const scrollView = this.cyl_scrollView;
    if (overOffset <= 0 || scrollView === null || !scrollView.cyl_window) {
      return;
    }
    const down = this instanceof CYLRefreshHeaderModel;
    const rest = scrollView.cyl_offsetY;
    scrollView.animator(0.15, () => {
      scrollView.cyl_offsetY = rest + (down ? -overOffset : overOffset);
    }, () => {
      scrollView.animator(0.3, () => {
        scrollView.cyl_offsetY = rest;
      }, () => {
      });
    });
  }

  /** Ends refreshing (`-endRefreshing`). */
  endRefreshing(): void {
    this.endRefreshingWithSuccess(true);
  }

  /** Ends refreshing and calls `completion` once closed (`-endRefreshingWithCompletionBlock:`). */
  endRefreshingWithCompletionBlock(completion: CYLRefreshComponentAction): void {
    this.endRefreshingCompletionBlock = completion;
    this.endRefreshing();
  }

  /** Ends refreshing, recording whether it succeeded; holds `finishDuration` first (`-endRefreshingWithSuccess:`). */
  endRefreshingWithSuccess(success: boolean): void {
    if (this.cyl_finishing) {
      return;
    }
    if (!this.refreshing) {
      this.state = CYLRefreshState.Idle;
      return;
    }
    this.succeeded = success;
    this.refreshDidFinishWithSuccess(success);
    const duration = this.finishingDurationWithSuccess(success);
    if (!(duration > 0) || !Number.isFinite(duration)) {
      this.state = CYLRefreshState.Idle;
      return;
    }
    this.cyl_finishing = true;
    this.cyl_reportPhase();
    this.cyl_setNeedsLayout();
    setTimeout(() => {
      this.cyl_finishing = false;
      if (this.refreshing) {
        this.state = CYLRefreshState.Idle;
      }
      this.cyl_reportPhase();
      this.cyl_setNeedsLayout();
    }, duration * 1000);
  }

  /** Whether the last refresh succeeded (`lastRefreshSucceeded`). */
  get lastRefreshSucceeded(): boolean {
    return this.succeeded;
  }

  /** Whether the control refreshes or is about to (`refreshing`). */
  get refreshing(): boolean {
    return this.state === CYLRefreshState.Refreshing || this.state === CYLRefreshState.WillRefresh;
  }

  /** The state (`state`). */
  get state(): CYLRefreshState {
    return this.stateValue;
  }

  set state(value: CYLRefreshState) {
    if (value === this.stateValue) {
      return;
    }
    const old = this.stateValue;
    this.stateValue = value;
    this.cyl_stateDidChange(old, value);
  }

  /** The state changed (iOS setState: after CYLRefreshCheckState); subclasses call super first. */
  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    if (this.icon !== null) {
      this.icon.updateForState(state);
    }
    this.cyl_reportPhase();
    this.cyl_setNeedsLayout();
  }

  /** How far the control is pulled, as a share of the trigger distance (`pullingPercent`). */
  get pullingPercent(): number {
    return this.percent;
  }

  set pullingPercent(value: number) {
    this.percent = value;
    if (this.icon !== null) {
      this.icon.updateForPullingPercent(value);
    }
    this.cyl_reportPhase();
    if (!this.refreshing && this.alphaFollowsPull) {
      this.alpha = value;
    }
    this.cyl_pullingPercentDidChange();
  }

  /** Hook after pullingPercent changed. */
  cyl_pullingPercentDidChange(): void {
  }

  /** The control's alpha follows pullingPercent (`automaticallyChangeAlpha`). */
  get automaticallyChangeAlpha(): boolean {
    return this.alphaFollowsPull;
  }

  set automaticallyChangeAlpha(value: boolean) {
    this.alphaFollowsPull = value;
    if (this.refreshing) {
      return;
    }
    this.alpha = value ? this.percent : 1;
    this.cyl_setNeedsLayout();
  }

  /** Deprecated name of automaticallyChangeAlpha (iOS `autoChangeAlpha`). */
  get autoChangeAlpha(): boolean {
    return this.automaticallyChangeAlpha;
  }

  set autoChangeAlpha(value: boolean) {
    this.automaticallyChangeAlpha = value;
  }

  /** Deprecated name of endRefreshingAnimationBeginAction (iOS `endRefreshingAnimateCompletionBlock`). */
  get endRefreshingAnimateCompletionBlock(): CYLRefreshComponentAction | null {
    return this.endRefreshingAnimationBeginAction;
  }

  set endRefreshingAnimateCompletionBlock(value: CYLRefreshComponentAction | null) {
    this.endRefreshingAnimationBeginAction = value;
  }

  /** The share of the control's size to pull before releasing refreshes (`triggerRate`, default 1). */
  get triggerRate(): number {
    return this.rate;
  }

  set triggerRate(value: number) {
    this.rate = Number.isFinite(value) && value > 0 ? value : 1;
  }

  /** The scroll view's insets when the control attached (`scrollViewOriginalInset`). */
  get scrollViewOriginalInset(): CYLEdgeInsets {
    return this.cyl_originalInset;
  }

  /** The scroll view the control is attached to (`scrollView`). */
  get scrollView(): CYLRefreshScrollViewModel | null {
    return this.cyl_scrollView;
  }

  /** Whether the control is attached (`attached`). */
  get attached(): boolean {
    return this.cyl_scrollView !== null;
  }

  /** Whether the control holds its refreshing position (`expanded`). */
  get expanded(): boolean {
    return this.refreshing;
  }

  /** The control's open height (`expandHeight`). */
  get expandHeight(): number {
    return this.cyl_h;
  }

  /** How far the control is pulled, in vp (`dragOffset`). */
  get dragOffset(): number {
    return this.pullingPercent * this.expandHeight * this.triggerRate;
  }

  /** The detailed phase (`phase`). */
  get phase(): CYLRefreshPhase {
    return this.cyl_phase();
  }

  /** The phase; subclasses override (the header's and back footer's second floor). */
  cyl_phase(): CYLRefreshPhase {
    if (this.state === CYLRefreshState.NoMoreData) {
      return CYLRefreshPhase.NoMoreData;
    }
    if (this.cyl_finishing) {
      return CYLRefreshPhase.Finishing;
    }
    const dragging = this.cyl_scrollView !== null && this.cyl_scrollView.isDragging;
    switch (this.state) {
      case CYLRefreshState.Refreshing:
        return CYLRefreshPhase.Refreshing;
      case CYLRefreshState.WillRefresh:
        return CYLRefreshPhase.WillRefresh;
      case CYLRefreshState.Pulling:
        return dragging ? CYLRefreshPhase.ReleaseToRefresh : CYLRefreshPhase.Releasing;
      default:
        return this.pullingPercent > 0 && dragging ? CYLRefreshPhase.PullToRefresh : CYLRefreshPhase.Idle;
    }
  }

  /** True when the phase is one of `phases` (`-isInAnyPhase:`). */
  isInAnyPhase(phases: CYLRefreshPhase[]): boolean {
    return phases.includes(this.phase);
  }

  /** True when the phase is one of the arguments (`-isInPhases:`). */
  isInPhases(...phases: CYLRefreshPhase[]): boolean {
    return phases.includes(this.phase);
  }

  /** Calls `observer` on every phase change; returns the token for removePhaseObserver (`-addPhaseObserver:`). */
  addPhaseObserver(observer: CYLRefreshPhaseObserver): number {
    phaseTokens++;
    this.phaseObservers.set(phaseTokens, observer);
    return phaseTokens;
  }

  /** Stops the observer of `token` (`-removePhaseObserver:`). */
  removePhaseObserver(token: number): void {
    this.phaseObservers.delete(token);
  }

  /** Reports a phase change to phaseDidChangeFrom and the observers. */
  cyl_reportPhase(): void {
    const phase = this.phase;
    if (phase === this.reportedPhase) {
      return;
    }
    const old = this.reportedPhase;
    this.reportedPhase = phase;
    if (this.hapticFeedback && phase === CYLRefreshPhase.ReleaseToRefresh) {
      try {
        vibrator.startVibration({ type: 'time', duration: 10 }, { usage: 'touch' }).catch((e: Error) => {
        });
      } catch (e) {
        // No vibrator (or no permission).
      }
    }
    this.phaseDidChangeFrom(old, phase);
    Array.from(this.phaseObservers.values()).forEach((o: CYLRefreshPhaseObserver) => o(this, old, phase));
  }

  // MARK: - Auto hide

  /** Whether the control hides while it has nothing to show (`autoHideRefresh`). */
  get autoHideRefresh(): boolean {
    return this.autoHide;
  }

  set autoHideRefresh(value: boolean) {
    this.autoHide = value;
    this.updateAutoHideVisibility();
  }

  /** Whether the control is at rest and out of sight, so auto hide may hide it (`-isReadyToAutoHide`). */
  isReadyToAutoHide(): boolean {
    return false;
  }

  /** Applies autoHideRefresh now (`-updateAutoHideVisibility`). */
  updateAutoHideVisibility(): void {
    const hide = this.autoHide && this.isReadyToAutoHide();
    if (hide !== this.cyl_autoHidden) {
      this.cyl_autoHidden = hide;
      this.cyl_setNeedsLayout();
    }
  }

  // MARK: - Attaching

  /** A control of this kind attached to `scrollView` (`+attach:`); subclasses provide their own. */
  static attach(scrollView: CYLRefreshScrollViewModel): CYLRefreshComponentModel {
    const component = new CYLRefreshComponentModel();
    component.attach(scrollView);
    return component;
  }

  /** Same, with a target-action (`+attach:target:action:`). */
  static attachWithTarget(scrollView: CYLRefreshScrollViewModel, target: Object,
    action: CYLRefreshTargetAction): CYLRefreshComponentModel {
    const component = CYLRefreshComponentModel.attach(scrollView);
    component.addTarget(target, action);
    return component;
  }

  /** Attaches the control as the scroll view's header, footer or trailer (`-attach:`). */
  attach(scrollView: CYLRefreshScrollViewModel): void {
    if (this instanceof CYLRefreshHeaderModel) {
      scrollView.cyl_header = this as CYLRefreshHeaderModel;
    } else if (this instanceof CYLRefreshFooterModel) {
      scrollView.cyl_footer = this as CYLRefreshFooterModel;
    } else if (this instanceof CYLRefreshTrailerModel) {
      scrollView.cyl_trailer = this as CYLRefreshTrailerModel;
    } else {
      this.cyl_moveToScrollView(scrollView);
    }
  }

  /** Moves the control to `scrollView` (iOS willMoveToSuperview / didMoveToSuperview). */
  cyl_moveToScrollView(scrollView: CYLRefreshScrollViewModel | null): void {
    const old = this.cyl_scrollView;
    if (old !== null && old !== scrollView) {
      this.willDetachFromScrollView(old);
      this.removeObservers();
    }
    this.cyl_scrollView = scrollView;
    if (scrollView !== null) {
      this.cyl_w = scrollView.cyl_w;
      this.cyl_x = -scrollView.cyl_insetL;
      this.cyl_originalInset = scrollView.cyl_inset;
      this.cyl_willMoveToScrollView(scrollView);
      this.addObservers();
      this.didAttachToScrollView(scrollView);
      this.cyl_setNeedsLayout();
    }
  }

  /** Hook before attaching (header / footer place themselves). */
  cyl_willMoveToScrollView(scrollView: CYLRefreshScrollViewModel): void {
  }

  /** The control came on screen: a WillRefresh control starts refreshing. */
  cyl_didMoveToWindow(): void {
    if (this.state === CYLRefreshState.WillRefresh && this.cyl_scrollView !== null && this.cyl_scrollView.cyl_window) {
      this.state = CYLRefreshState.Refreshing;
    }
  }

  /** Starts following the language (iOS KVO + notification observers) (`-addObservers`). */
  addObservers(): void {
    CYLRefreshConfig.defaultConfig.addLanguageObserver(this.languageObserver);
  }

  /** Stops following (`-removeObservers`). */
  removeObservers(): void {
    CYLRefreshConfig.defaultConfig.removeLanguageObserver(this.languageObserver);
  }

  // MARK: - Subclass hooks (the iOS names)

  scrollViewContentOffsetDidChange(change: CYLRefreshOffsetChange): void {
  }

  scrollViewContentSizeDidChange(): void {
  }

  scrollViewPanStateDidChange(state: CYLRefreshPanState): void {
  }

  scrollViewContentInsetDidChange(): void {
  }

  /** The refresh language changed (`-i18nDidChange`). */
  i18nDidChange(): void {
    this.cyl_setNeedsLayout();
  }

  didAttachToScrollView(scrollView: CYLRefreshScrollViewModel): void {
  }

  willDetachFromScrollView(scrollView: CYLRefreshScrollViewModel): void {
  }

  didScrollWithOffset(offset: number, percent: number, dragging: boolean): void {
  }

  phaseDidChangeFrom(oldPhase: CYLRefreshPhase, phase: CYLRefreshPhase): void {
  }

  refreshDidFinishWithSuccess(success: boolean): void {
  }

  finishingDurationWithSuccess(success: boolean): number {
    return this.finishDuration;
  }

  // MARK: - Exclusivity

  protected cyl_otherComponentIsRefreshing(): boolean {
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return false;
    }
    return scrollView.cyl_components().some((c: CYLRefreshComponentModel) => c !== this && c.refreshing);
  }

  protected cyl_holdsBackStartForOtherRefresh(): boolean {
    if (!this.exclusiveWithOtherRefresh || this.refreshing || !this.cyl_otherComponentIsRefreshing()) {
      return false;
    }
    if (this.state === CYLRefreshState.Pulling) {
      this.state = CYLRefreshState.Idle;
    }
    if (this.blockedByOtherRefreshBlock !== null) {
      this.blockedByOtherRefreshBlock();
    }
    return true;
  }

  // MARK: - Icon layout (`CYLRefreshComponent (CYLRefreshIconLayout)`)

  /** The control's icon view, made on first use (`cyl_iconView`). */
  get cyl_iconView(): CYLRefreshIconViewModel {
    if (this.icon === null) {
      this.icon = new CYLRefreshIconViewModel();
      this.icon.updateForState(this.state);
    }
    return this.icon;
  }

  /** Whether the icon view has animations to show (`cyl_usesIconView`). */
  get cyl_usesIconView(): boolean {
    return this.icon !== null && this.icon.hasAnimations;
  }

  /** Sets the icon animation of a state (`-cyl_setIconAnimationAttributes:forState:`). */
  cyl_setIconAnimationAttributes(attributes: CYLRefreshIconAttributes | null, state: CYLRefreshState): void {
    this.cyl_iconView.setAnimationAttributes(attributes, state);
    this.cyl_iconView.updateForState(this.state);
    this.cyl_setNeedsLayout();
  }

  /** Centers the icon view at `center`, hiding `views` while it shows (`-cyl_placeIconViewAtCenter:visible:replacingViews:`). */
  cyl_placeIconViewAtCenter(center: CYLPoint, visible: boolean, views: CYLRefreshViewModel[]): void {
    const icon = this.cyl_iconView;
    const size = icon.fittingSize;
    icon.cyl_w = size.width;
    icon.cyl_h = size.height;
    icon.cyl_x = center.x - size.width / 2;
    icon.cyl_y = center.y - size.height / 2;
    this.cyl_updateIconViewVisible(visible, views);
  }

  /** Shows the icon view in place of `views` (`-cyl_updateIconViewVisible:replacingViews:`). */
  cyl_updateIconViewVisible(visible: boolean, views: CYLRefreshViewModel[]): void {
    const show = visible && this.cyl_usesIconView;
    const icon = this.cyl_iconView;
    icon.hidden = !show;
    if (show) {
      views.forEach((v: CYLRefreshViewModel) => {
        v.hidden = true;
      });
    }
  }

  /**
   * Shows the icon view with its title in place of `views`; the labels hide while the icon's title shows
   * (`-cyl_placeIconViewWithTitle:labels:visible:replacingViews:`).
   */
  cyl_placeIconViewWithTitle(title: string | null, labels: CYLRefreshLabel[], visible: boolean,
    views: CYLRefreshViewModel[]): void {
    const icon = this.cyl_iconView;
    icon.title = title;
    const show = visible && this.cyl_usesIconView;
    labels.forEach((l: CYLRefreshLabel) => {
      l.hidden = show && title !== null;
    });
    this.cyl_placeIconViewAtCenter(new CYLPoint(this.cyl_w / 2, this.cyl_h / 2), visible, views);
  }

  /** Frame images of a state, played over `duration` seconds (`-cyl_setIconImages:duration:forState:`). */
  cyl_setIconImages(images: ResourceStr[], duration: number, state: CYLRefreshState): void {
    const attributes = new CYLRefreshIconAttributes();
    attributes.images = images.slice();
    attributes.duration = duration;
    attributes.size = new CYLRefreshIconSize(40, 40);
    this.cyl_setIconAnimationAttributes(images.length > 0 ? attributes : null, state);
  }

  /** Shows the frame of `images` that matches the pull (`-cyl_showIconImageFrameOf:pullingPercent:`). */
  cyl_showIconImageFrameOf(images: ResourceStr[] | null, pullingPercent: number): void {
    if (images === null || images.length === 0) {
      return;
    }
    const p = Math.min(1, Math.max(0, pullingPercent));
    this.cyl_iconView.frameIndex = Math.floor((images.length - 1) * p);
    this.cyl_setNeedsLayout();
  }

  // MARK: - Chaining (`CYLRefreshComponent (ChainingGrammar)`)

  /** Sets automaticallyChangeAlpha (`-cyl_autoChangeTransparency:`). */
  cyl_autoChangeTransparency(enabled: boolean): CYLRefreshComponentModel {
    this.automaticallyChangeAlpha = enabled;
    return this;
  }

  /** Sets beginRefreshingCompletionBlock (`-cyl_afterBeginningAction:`). */
  cyl_afterBeginningAction(action: CYLRefreshComponentAction): CYLRefreshComponentModel {
    this.beginRefreshingCompletionBlock = action;
    return this;
  }

  /** Sets endRefreshingAnimationBeginAction (`-cyl_endingAnimationBeginningAction:`). */
  cyl_endingAnimationBeginningAction(action: CYLRefreshComponentAction): CYLRefreshComponentModel {
    this.endRefreshingAnimationBeginAction = action;
    return this;
  }

  /** Sets endRefreshingCompletionBlock (`-cyl_afterEndingAction:`). */
  cyl_afterEndingAction(action: CYLRefreshComponentAction): CYLRefreshComponentModel {
    this.endRefreshingCompletionBlock = action;
    return this;
  }

  /** Attaches the control (`-cyl_linkTo:`; a no-op on the base control, as on iOS). */
  cyl_linkTo(scrollView: CYLRefreshScrollViewModel): CYLRefreshComponentModel {
    if (this instanceof CYLRefreshHeaderModel || this instanceof CYLRefreshFooterModel ||
      this instanceof CYLRefreshTrailerModel) {
      this.attach(scrollView);
    }
    return this;
  }
}

/** The second floor of a header or a back footer (flutter_easy_refresh's secondary). */
class CYLRefreshSecondaryFloor {
  triggerOffset: number = 0;
  dimension: number = 0;
  closeTriggerOffset: number = 80;
  velocity: number = 0;
  view: Object | null = null;
  open: boolean = false;
  armed: boolean = false;
  closing: boolean = false;
  closePending: boolean = false;
  openedBlock: CYLRefreshComponentAction | null = null;
  closedBlock: CYLRefreshComponentAction | null = null;
}

/** Pull down to refresh (iOS `CYLRefreshHeader`). */
export class CYLRefreshHeaderModel extends CYLRefreshComponentModel {
  /** Whether the content moves down to keep the refreshing header in sight (`addsRefreshingInset`). */
  addsRefreshingInset: boolean = true;
  /** Whether a successful refresh resets the footer's "no more data" (`resetsFooterAfterRefresh`). */
  resetsFooterAfterRefresh: boolean = false;
  /** iOS `isCollectionViewAnimationBug`: kept; both inset animations are the same animateTo on HarmonyOS. */
  isCollectionViewAnimationBug: boolean = false;
  /** True while the header retracts after a refresh. */
  retracting: boolean = false;
  protected floor: CYLRefreshSecondaryFloor = new CYLRefreshSecondaryFloor();
  private timeKey: string = CYLRefreshHeaderLastUpdatedTimeKey;
  private ignoredTop: number = 0;
  private insetTDelta: number = 0;
  private addedRefreshingInset: boolean = false;
  private updatingRefreshInset: boolean = false;

  prepare(): void {
    super.prepare();
    this.cyl_h = CYLRefreshHeaderHeight;
  }

  /** A header calling `block` when it refreshes (`+headerWithRefreshingBlock:`). */
  static headerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshHeaderModel {
    const header = new CYLRefreshHeaderModel();
    header.refreshingBlock = block;
    return header;
  }

  /** A header calling the target's action (`+headerWithRefreshingTarget:refreshingAction:`). */
  static headerWithRefreshingTarget(target: Object, action: CYLRefreshTargetAction): CYLRefreshHeaderModel {
    const header = new CYLRefreshHeaderModel();
    header.setRefreshingTarget(target, action);
    return header;
  }

  /** The key the last update time is stored under (`lastUpdatedTimeKey`). */
  get lastUpdatedTimeKey(): string {
    return this.timeKey;
  }

  set lastUpdatedTimeKey(value: string) {
    this.timeKey = value;
    this.cyl_lastUpdatedTimeKeyDidChange();
  }

  /** Hook: the state header redraws its time. */
  cyl_lastUpdatedTimeKeyDidChange(): void {
  }

  /** When the header last finished refreshing, or null (`lastUpdatedTime`); kept by CYLRefreshConfig. */
  get lastUpdatedTime(): Date | null {
    const time = CYLRefreshConfig.defaultConfig.storedTime(this.timeKey);
    return time !== null ? new Date(time) : null;
  }

  set lastUpdatedTime(value: Date | null) {
    CYLRefreshConfig.defaultConfig.storeTime(this.timeKey, value !== null ? value.getTime() : null);
    this.lastUpdatedTimeKey = this.timeKey;
  }

  /** The top inset the header ignores, in vp (`ignoredScrollViewContentInsetTop`). */
  get ignoredScrollViewContentInsetTop(): number {
    return this.ignoredTop;
  }

  set ignoredScrollViewContentInsetTop(value: number) {
    this.ignoredTop = value;
    this.cyl_y = -this.cyl_h - value;
    this.cyl_setNeedsLayout();
  }

  /** The header's open height (`-setExpandHeight:`). */
  setExpandHeight(expandHeight: number): void {
    this.cyl_h = expandHeight;
    this.cyl_setNeedsLayout();
  }

  placeSubviews(): void {
    super.placeSubviews();
    this.cyl_y = -this.cyl_h - this.ignoredTop;
  }

  // MARK: - Second floor

  /** Pulling this far and releasing opens the second floor; 0 for never (`secondaryTriggerOffset`). */
  get secondaryTriggerOffset(): number {
    return this.floor.triggerOffset;
  }

  set secondaryTriggerOffset(v: number) {
    this.floor.triggerOffset = v;
  }

  /** The open second floor's height; 0 for the visible height (`secondaryDimension`). */
  get secondaryDimension(): number {
    return this.floor.dimension;
  }

  set secondaryDimension(v: number) {
    this.floor.dimension = v;
  }

  /** Pushing the open floor back this far and releasing closes it, default 80 (`secondaryCloseTriggerOffset`). */
  get secondaryCloseTriggerOffset(): number {
    return this.floor.closeTriggerOffset;
  }

  set secondaryCloseTriggerOffset(v: number) {
    this.floor.closeTriggerOffset = v;
  }

  /** A release at least this fast (vp/s) past the refresh trigger opens the floor; 0 off (`secondaryVelocity`). */
  get secondaryVelocity(): number {
    return this.floor.velocity;
  }

  set secondaryVelocity(v: number) {
    this.floor.velocity = v;
  }

  /** The floor's content: any token; the container draws its `secondaryHeaderBuilder` while it is set (`secondaryView`). */
  get secondaryView(): Object | null {
    return this.floor.view;
  }

  set secondaryView(v: Object | null) {
    this.floor.view = v;
    this.cyl_setNeedsLayout();
  }

  /** Whether the floor is open (`secondaryOpen`). */
  get secondaryOpen(): boolean {
    return this.floor.open;
  }

  /** Called after the floor opened (`secondaryOpenedBlock`). */
  get secondaryOpenedBlock(): CYLRefreshComponentAction | null {
    return this.floor.openedBlock;
  }

  set secondaryOpenedBlock(v: CYLRefreshComponentAction | null) {
    this.floor.openedBlock = v;
  }

  /** Called after the floor closed (`secondaryClosedBlock`). */
  get secondaryClosedBlock(): CYLRefreshComponentAction | null {
    return this.floor.closedBlock;
  }

  set secondaryClosedBlock(v: CYLRefreshComponentAction | null) {
    this.floor.closedBlock = v;
  }

  /** The open floor's height. */
  get cyl_secondaryHeight(): number {
    if (this.floor.dimension > 0) {
      return this.floor.dimension;
    }
    const scrollView = this.cyl_scrollView;
    const visible = scrollView !== null ?
      scrollView.cyl_h - this.cyl_originalInset.top - this.cyl_originalInset.bottom : 0;
    return Math.max(this.expandHeight, visible);
  }

  cyl_phase(): CYLRefreshPhase {
    if (this.floor.closing) {
      return CYLRefreshPhase.SecondaryClosing;
    }
    if (this.floor.open) {
      return CYLRefreshPhase.SecondaryOpen;
    }
    if (this.floor.armed) {
      return CYLRefreshPhase.SecondaryArmed;
    }
    return super.cyl_phase();
  }

  /** Opens the second floor (`-openSecondary`). */
  openSecondary(): void {
    const scrollView = this.cyl_scrollView;
    if (this.floor.open || scrollView === null || this.refreshing) {
      return;
    }
    this.floor.armed = false;
    if (this.state === CYLRefreshState.Pulling) {
      this.state = CYLRefreshState.Idle;
    }
    this.floor.open = true;
    this.cyl_reportPhase();
    const top = this.cyl_originalInset.top + this.cyl_secondaryHeight;
    scrollView.animator(this.slowAnimationDuration, () => {
      this.setRefreshingInsetTop(top);
      scrollView.cyl_offsetY = -top;
    }, () => {
      if (this.floor.openedBlock !== null) {
        this.floor.openedBlock();
      }
    });
    this.cyl_setNeedsLayout();
  }

  /** Closes the second floor (`-closeSecondary`). */
  closeSecondary(): void {
    const scrollView = this.cyl_scrollView;
    if (!this.floor.open || this.floor.closing || scrollView === null) {
      return;
    }
    this.floor.closing = true;
    this.floor.closePending = false;
    this.cyl_reportPhase();
    const top = this.cyl_originalInset.top;
    scrollView.animator(this.slowAnimationDuration, () => {
      this.setRefreshingInsetTop(top);
      scrollView.cyl_offsetY = -top;
    }, () => {
      this.floor.closing = false;
      this.floor.open = false;
      this.pullingPercent = 0;
      this.cyl_reportPhase();
      this.updateAutoHideVisibility();
      this.cyl_setNeedsLayout();
      if (this.floor.closedBlock !== null) {
        this.floor.closedBlock();
      }
    });
  }

  private cyl_followOpenSecondary(): void {
    const scrollView = this.cyl_scrollView;
    if (this.floor.closing || scrollView === null) {
      return;
    }
    const openOffsetY = -(this.cyl_originalInset.top + this.cyl_secondaryHeight);
    const pushed = scrollView.cyl_offsetY - openOffsetY;
    if (scrollView.isDragging) {
      this.floor.closePending = pushed >= this.floor.closeTriggerOffset;
    } else if (this.floor.closePending) {
      this.closeSecondary();
    }
  }

  // MARK: - Auto hide

  isReadyToAutoHide(): boolean {
    if (this.state !== CYLRefreshState.Idle || this.retracting) {
      return false;
    }
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return true;
    }
    return scrollView.cyl_offsetY >= -this.cyl_originalInset.top - 0.5;
  }

  cyl_pullingPercentDidChange(): void {
    this.updateAutoHideVisibility();
  }

  // MARK: - Scroll handling (MJRefreshHeader)

  scrollViewPanStateDidChange(state: CYLRefreshPanState): void {
    super.scrollViewPanStateDidChange(state);
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return;
    }
    if (state === CYLRefreshPanState.Ended && this.floor.velocity > 0 && this.floor.triggerOffset > 0 &&
      !this.floor.open && !this.refreshing) {
      const pulled = -(scrollView.cyl_offsetY + this.cyl_originalInset.top);
      if (scrollView.panVelocityY >= this.floor.velocity && pulled >= this.expandHeight * this.triggerRate) {
        this.openSecondary();
        return;
      }
    }
    if (state === CYLRefreshPanState.Began) {
      this.cyl_dragStartedAtEdge = scrollView.cyl_offsetY <= -this.cyl_originalInset.top + 0.5;
    }
  }

  /** Whether the content moves for the refreshing header (not Front, addsRefreshingInset). */
  get cyl_movesContentWhileRefreshing(): boolean {
    return this.addsRefreshingInset && this.scrollMode !== CYLRefreshScrollMode.Front;
  }

  protected setRefreshingInsetTop(insetTop: number): void {
    const scrollView = this.cyl_scrollView;
    if (this.updatingRefreshInset || scrollView === null) {
      return;
    }
    this.updatingRefreshInset = true;
    scrollView.cyl_insetT = insetTop;
    this.updatingRefreshInset = false;
  }

  private resetInset(): void {
    const scrollView = this.cyl_scrollView;
    if (this.updatingRefreshInset || scrollView === null) {
      return;
    }
    let insetT = -scrollView.cyl_offsetY > this.cyl_originalInset.top ? -scrollView.cyl_offsetY :
      this.cyl_originalInset.top;
    insetT = Math.min(insetT, this.expandHeight + this.cyl_originalInset.top);
    if (Math.abs(scrollView.cyl_insetT - insetT) > 0.0001) {
      this.setRefreshingInsetTop(insetT);
    }
    this.insetTDelta = this.cyl_originalInset.top - scrollView.cyl_insetT;
  }

  scrollViewContentOffsetDidChange(change: CYLRefreshOffsetChange): void {
    super.scrollViewContentOffsetDidChange(change);
    this.updateAutoHideVisibility();
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return;
    }
    if (this.state === CYLRefreshState.Refreshing) {
      if (this.addedRefreshingInset && this.scrollMode !== CYLRefreshScrollMode.Front) {
        this.resetInset();
      }
      return;
    }
    if (this.floor.open || this.floor.closing) {
      this.cyl_followOpenSecondary();
      return;
    }
    this.cyl_originalInset = scrollView.cyl_inset;
    let offsetY = scrollView.cyl_offsetY;
    const happenOffsetY = -this.cyl_originalInset.top;
    if (offsetY > happenOffsetY) {
      return;
    }
    const triggerDistance = this.expandHeight * this.triggerRate;
    const normal2pullingOffsetY = happenOffsetY - triggerDistance;
    let pullingPercent = (happenOffsetY - offsetY) / triggerDistance;
    if (this.floor.triggerOffset > 0) {
      const armed = scrollView.isDragging && happenOffsetY - offsetY >= this.floor.triggerOffset;
      if (scrollView.isDragging && armed !== this.floor.armed) {
        this.floor.armed = armed;
        this.cyl_reportPhase();
      } else if (!scrollView.isDragging && this.floor.armed) {
        this.openSecondary();
        return;
      }
    }
    if (scrollView.isDragging) {
      if (this.maxPullDistance > 0 && happenOffsetY - offsetY > this.maxPullDistance) {
        offsetY = happenOffsetY - this.maxPullDistance;
        pullingPercent = this.maxPullDistance / triggerDistance;
        scrollView.cyl_offsetY = offsetY;
      }
      this.pullingPercent = pullingPercent;
      const mayArm = this.triggerMode === CYLRefreshTriggerMode.Anywhere || this.cyl_dragStartedAtEdge;
      if (this.state === CYLRefreshState.Idle && this.refreshEnabled && mayArm && offsetY < normal2pullingOffsetY) {
        this.state = CYLRefreshState.Pulling;
        if (this.triggersWhenReached) {
          this.beginRefreshing();
        }
      } else if (this.state === CYLRefreshState.Pulling && offsetY >= normal2pullingOffsetY) {
        this.state = CYLRefreshState.Idle;
      }
    } else if (this.state === CYLRefreshState.Pulling) {
      this.beginRefreshing();
    } else if (pullingPercent < 1) {
      this.pullingPercent = pullingPercent;
    }
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (state === CYLRefreshState.Idle) {
      if (oldState !== CYLRefreshState.Refreshing) {
        this.updateAutoHideVisibility();
        return;
      }
      this.headerEndingAction();
    } else if (state === CYLRefreshState.Refreshing) {
      this.headerRefreshingAction();
    }
    this.updateAutoHideVisibility();
  }

  private headerEndingAction(): void {
    const scrollView = this.cyl_scrollView;
    const footer = scrollView !== null ? scrollView.cyl_footer : null;
    if (this.resetsFooterAfterRefresh && this.lastRefreshSucceeded && footer !== null && footer.noMoreData) {
      footer.resetNoMoreData();
    }
    CYLRefreshConfig.defaultConfig.storeTime(this.timeKey, Date.now());
    this.lastUpdatedTimeKey = this.timeKey;
    this.retracting = true;
    const addedInset = this.addedRefreshingInset;
    this.addedRefreshingInset = false;
    if (!addedInset || scrollView === null) {
      this.retracting = false;
      this.pullingPercent = 0;
      if (this.endRefreshingCompletionBlock !== null) {
        this.endRefreshingCompletionBlock();
      }
      return;
    }
    scrollView.animator(this.slowAnimationDuration, () => {
      this.setRefreshingInsetTop(scrollView.cyl_insetT + this.insetTDelta);
      if (this.endRefreshingAnimationBeginAction !== null) {
        this.endRefreshingAnimationBeginAction();
      }
      if (this.automaticallyChangeAlpha) {
        this.alpha = 0;
      }
    }, () => {
      this.retracting = false;
      this.pullingPercent = 0;
      this.updateAutoHideVisibility();
      if (this.endRefreshingCompletionBlock !== null) {
        this.endRefreshingCompletionBlock();
      }
    });
  }

  private headerRefreshingAction(): void {
    this.insetTDelta = 0;
    const scrollView = this.cyl_scrollView;
    if (!this.cyl_movesContentWhileRefreshing || scrollView === null) {
      this.addedRefreshingInset = false;
      this.executeRefreshingCallback();
      return;
    }
    this.addedRefreshingInset = true;
    scrollView.animator(this.fastAnimationDuration, () => {
      if (scrollView.panState !== CYLRefreshPanState.Cancelled) {
        const top = this.cyl_originalInset.top + this.expandHeight;
        this.insetTDelta = scrollView.cyl_insetT - top;
        this.setRefreshingInsetTop(top);
        if (!scrollView.isDragging) {
          scrollView.cyl_offsetY = -top;
        }
      }
    }, () => {
      this.executeRefreshingCallback();
    });
  }

  cyl_linkTo(scrollView: CYLRefreshScrollViewModel): CYLRefreshComponentModel {
    scrollView.cyl_header = this;
    return this;
  }
}

/** Pull up to load more (iOS `CYLRefreshFooter`). */
export class CYLRefreshFooterModel extends CYLRefreshComponentModel {
  /** Whether pulling past the end loads again after "no more data" (`loadsAfterNoMoreData`). */
  loadsAfterNoMoreData: boolean = false;
  /** The bottom inset the footer ignores, in vp (`ignoredScrollViewContentInsetBottom`). */
  ignoredScrollViewContentInsetBottom: number = 0;
  /** Deprecated (`automaticallyHidden`); kept, the app shows and hides the footer. */
  automaticallyHidden: boolean = false;

  prepare(): void {
    super.prepare();
    this.cyl_h = CYLRefreshFooterHeight;
  }

  /** A footer calling `block` when it loads (`+footerWithRefreshingBlock:`). */
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshFooterModel {
    const footer = new CYLRefreshFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  /** A footer calling the target's action (`+footerWithRefreshingTarget:refreshingAction:`). */
  static footerWithRefreshingTarget(target: Object, action: CYLRefreshTargetAction): CYLRefreshFooterModel {
    const footer = new CYLRefreshFooterModel();
    footer.setRefreshingTarget(target, action);
    return footer;
  }

  /** Ends loading and shows "no more data" (`-endRefreshingWithNoMoreData`). */
  endRefreshingWithNoMoreData(): void {
    this.state = CYLRefreshState.NoMoreData;
  }

  /** Deprecated name of endRefreshingWithNoMoreData (`-noticeNoMoreData`). */
  noticeNoMoreData(): void {
    this.endRefreshingWithNoMoreData();
  }

  /** Clears "no more data" (`-resetNoMoreData`). */
  resetNoMoreData(): void {
    this.state = CYLRefreshState.Idle;
  }

  /** Whether the footer shows that all data is loaded (`noMoreData`). */
  get noMoreData(): boolean {
    return this.state === CYLRefreshState.NoMoreData;
  }

  isReadyToAutoHide(): boolean {
    if (this.state !== CYLRefreshState.Idle && this.state !== CYLRefreshState.NoMoreData) {
      return false;
    }
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return true;
    }
    const visibleBottom = scrollView.cyl_offsetY + scrollView.cyl_h - this.cyl_originalInset.bottom;
    return this.cyl_y >= visibleBottom - 0.5;
  }

  scrollViewContentOffsetDidChange(change: CYLRefreshOffsetChange): void {
    super.scrollViewContentOffsetDidChange(change);
    this.updateAutoHideVisibility();
  }

  cyl_linkTo(scrollView: CYLRefreshScrollViewModel): CYLRefreshComponentModel {
    scrollView.cyl_footer = this;
    return this;
  }
}

/**
 * A footer inside the content that loads when it shows (iOS `CYLRefreshAutoFooter`). Put `CYLRefreshFooterView` as
 * the last item of the list: it reports how much of it is visible (`cyl_visibleRatio`), the share iOS computes from
 * the content offset.
 */
export class CYLRefreshAutoFooterModel extends CYLRefreshFooterModel {
  /** Whether the footer loads by itself when it shows (`automaticallyRefresh`, default true). */
  automaticallyRefresh: boolean = true;
  /** How much of the footer must show before it loads (`triggerAutomaticallyRefreshPercent`, default 1). */
  triggerAutomaticallyRefreshPercent: number = 1;
  /** The visible share of the footer (0..1), reported by the footer view. */
  cyl_visibleRatio: number = 0;
  protected triggerByDrag: boolean = false;
  protected leftTriggerTimes: number = 1;
  private triggerTimes: number = 1;

  /** A footer calling `block` when it loads (`+footerWithRefreshingBlock:`). */
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshAutoFooterModel {
    const footer = new CYLRefreshAutoFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  /** Automatic loads allowed per drag (default 1); -1 for unlimited (`autoTriggerTimes`). */
  get autoTriggerTimes(): number {
    return this.triggerTimes;
  }

  set autoTriggerTimes(value: number) {
    this.triggerTimes = value;
    this.leftTriggerTimes = value;
  }

  get unlimitedTrigger(): boolean {
    return this.leftTriggerTimes === -1;
  }

  /** The footer view's visible share changed (the auto footer's offset check). */
  cyl_visibleRatioDidChange(ratio: number): void {
    const grew = ratio > this.cyl_visibleRatio;
    this.cyl_visibleRatio = ratio;
    this.updateAutoHideVisibility();
    const scrollView = this.cyl_scrollView;
    if (scrollView === null || !grew) {
      return;
    }
    this.cyl_checkAutomaticRefresh(scrollView, true);
  }

  private cyl_contentFillsView(scrollView: CYLRefreshScrollViewModel): boolean {
    return scrollView.cyl_insetT + scrollView.cyl_contentH > scrollView.cyl_h;
  }

  private cyl_checkAutomaticRefresh(scrollView: CYLRefreshScrollViewModel, movingUp: boolean): void {
    const header = scrollView.cyl_header;
    if (this.state !== CYLRefreshState.Idle || !this.automaticallyRefresh || !this.refreshEnabled ||
      (header !== null && header.refreshing)) {
      return;
    }
    if (!this.cyl_contentFillsView(scrollView) || !movingUp) {
      return;
    }
    if (this.cyl_visibleRatio + 0.001 >= this.triggerAutomaticallyRefreshPercent) {
      if (scrollView.isDragging) {
        this.triggerByDrag = true;
      }
      this.beginRefreshing();
    }
  }

  scrollViewContentOffsetDidChange(change: CYLRefreshOffsetChange): void {
    super.scrollViewContentOffsetDidChange(change);
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return;
    }
    if (change.newY <= change.oldY || change.newY <= -scrollView.cyl_insetT) {
      return;
    }
    this.cyl_checkAutomaticRefresh(scrollView, true);
  }

  scrollViewPanStateDidChange(state: CYLRefreshPanState): void {
    super.scrollViewPanStateDidChange(state);
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return;
    }
    if (this.state === CYLRefreshState.NoMoreData && this.loadsAfterNoMoreData && state === CYLRefreshPanState.Ended) {
      this.resetNoMoreData();
    }
    const header = scrollView.cyl_header;
    if (this.state !== CYLRefreshState.Idle || !this.refreshEnabled || (header !== null && header.refreshing)) {
      return;
    }
    if (state === CYLRefreshPanState.Ended) {
      if (!this.cyl_contentFillsView(scrollView)) {
        if (scrollView.cyl_offsetY >= -scrollView.cyl_insetT) {
          this.triggerByDrag = true;
          this.beginRefreshing();
        }
      } else {
        const threshold = scrollView.cyl_contentH + scrollView.cyl_insetB - scrollView.cyl_h;
        if (scrollView.cyl_offsetY >= threshold - 0.0001) {
          this.triggerByDrag = true;
          this.beginRefreshing();
        }
      }
    } else if (state === CYLRefreshPanState.Began) {
      this.resetTriggerTimes();
    }
  }

  /** Refuses a drag-triggered load once the drag used its autoTriggerTimes. */
  beginRefreshing(): void {
    if (this.triggerByDrag && this.leftTriggerTimes <= 0 && !this.unlimitedTrigger) {
      return;
    }
    super.beginRefreshing();
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (state === CYLRefreshState.Refreshing) {
      this.executeRefreshingCallback();
    } else if (state === CYLRefreshState.NoMoreData || state === CYLRefreshState.Idle) {
      if (this.triggerByDrag) {
        if (!this.unlimitedTrigger) {
          this.leftTriggerTimes -= 1;
        }
        this.triggerByDrag = false;
      }
      if (oldState === CYLRefreshState.Refreshing) {
        if (this.endRefreshingAnimationBeginAction !== null) {
          this.endRefreshingAnimationBeginAction();
        }
        if (this.endRefreshingCompletionBlock !== null) {
          this.endRefreshingCompletionBlock();
        }
      }
    }
  }

  /** Allows autoTriggerTimes loads again (a new drag). */
  resetTriggerTimes(): void {
    this.leftTriggerTimes = this.triggerTimes;
  }

  /** Loads remaining for this drag (tests). */
  get cyl_leftTriggerTimes(): number {
    return this.leftTriggerTimes;
  }

  isReadyToAutoHide(): boolean {
    if (this.state !== CYLRefreshState.Idle && this.state !== CYLRefreshState.NoMoreData) {
      return false;
    }
    return this.cyl_visibleRatio <= 0;
  }
}

/** A footer below the content that loads when pulled up and released (iOS `CYLRefreshBackFooter`). */
export class CYLRefreshBackFooterModel extends CYLRefreshFooterModel {
  /** Seconds "no more data" stays visible, held open, after a load ending with it (`noMoreDataDisplayDuration`). */
  noMoreDataDisplayDuration: number = 0;
  protected floor: CYLRefreshSecondaryFloor = new CYLRefreshSecondaryFloor();
  private lastBottomDelta: number = 0;
  private holdingNoMoreData: boolean = false;
  private holdGeneration: number = 0;
  private lastRefreshCount: number = 0;

  /** A footer calling `block` when it loads (`+footerWithRefreshingBlock:`). */
  static footerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshBackFooterModel {
    const footer = new CYLRefreshBackFooterModel();
    footer.refreshingBlock = block;
    return footer;
  }

  cyl_willMoveToScrollView(scrollView: CYLRefreshScrollViewModel): void {
    this.scrollViewContentSizeDidChange();
  }

  scrollViewContentSizeDidChange(): void {
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return;
    }
    const contentHeight = scrollView.cyl_contentH + this.ignoredScrollViewContentInsetBottom;
    this.cyl_y = Math.max(contentHeight, scrollView.cyl_h);
  }

  private heightForContentBreakView(): number {
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return 0;
    }
    const h = scrollView.cyl_h - this.cyl_originalInset.bottom - this.cyl_originalInset.top;
    return scrollView.cyl_contentH - h;
  }

  /** The offset at which the footer starts to show. */
  cyl_happenOffsetY(): number {
    const deltaH = this.heightForContentBreakView();
    return deltaH > 0 ? deltaH - this.cyl_originalInset.top : -this.cyl_originalInset.top;
  }

  // MARK: - Second floor

  get secondaryTriggerOffset(): number {
    return this.floor.triggerOffset;
  }

  set secondaryTriggerOffset(v: number) {
    this.floor.triggerOffset = v;
  }

  get secondaryDimension(): number {
    return this.floor.dimension;
  }

  set secondaryDimension(v: number) {
    this.floor.dimension = v;
  }

  get secondaryCloseTriggerOffset(): number {
    return this.floor.closeTriggerOffset;
  }

  set secondaryCloseTriggerOffset(v: number) {
    this.floor.closeTriggerOffset = v;
  }

  get secondaryVelocity(): number {
    return this.floor.velocity;
  }

  set secondaryVelocity(v: number) {
    this.floor.velocity = v;
  }

  /** The floor's content token; the container draws its `secondaryFooterBuilder` below the list while set. */
  get secondaryView(): Object | null {
    return this.floor.view;
  }

  set secondaryView(v: Object | null) {
    this.floor.view = v;
    this.cyl_setNeedsLayout();
  }

  get secondaryOpen(): boolean {
    return this.floor.open;
  }

  get secondaryOpenedBlock(): CYLRefreshComponentAction | null {
    return this.floor.openedBlock;
  }

  set secondaryOpenedBlock(v: CYLRefreshComponentAction | null) {
    this.floor.openedBlock = v;
  }

  get secondaryClosedBlock(): CYLRefreshComponentAction | null {
    return this.floor.closedBlock;
  }

  set secondaryClosedBlock(v: CYLRefreshComponentAction | null) {
    this.floor.closedBlock = v;
  }

  get cyl_secondaryHeight(): number {
    if (this.floor.dimension > 0) {
      return this.floor.dimension;
    }
    const scrollView = this.cyl_scrollView;
    const visible = scrollView !== null ?
      scrollView.cyl_h - this.cyl_originalInset.top - this.cyl_originalInset.bottom : 0;
    return Math.max(this.cyl_h, visible);
  }

  cyl_phase(): CYLRefreshPhase {
    if (this.floor.closing) {
      return CYLRefreshPhase.SecondaryClosing;
    }
    if (this.floor.open) {
      return CYLRefreshPhase.SecondaryOpen;
    }
    if (this.floor.armed) {
      return CYLRefreshPhase.SecondaryArmed;
    }
    return super.cyl_phase();
  }

  /** Opens the footer's second floor below the list (`-openSecondary`). */
  openSecondary(): void {
    const scrollView = this.cyl_scrollView;
    if (this.floor.open || scrollView === null || this.refreshing || this.state === CYLRefreshState.NoMoreData) {
      return;
    }
    this.floor.armed = false;
    if (this.state === CYLRefreshState.Pulling) {
      this.state = CYLRefreshState.Idle;
    }
    this.floor.open = true;
    this.cyl_reportPhase();
    const height = this.cyl_secondaryHeight;
    const happen = this.cyl_happenOffsetY();
    scrollView.animator(this.slowAnimationDuration, () => {
      scrollView.cyl_insetB = this.cyl_originalInset.bottom + height;
      scrollView.cyl_offsetY = happen + height;
    }, () => {
      if (this.floor.openedBlock !== null) {
        this.floor.openedBlock();
      }
    });
    this.cyl_setNeedsLayout();
  }

  /** Closes the footer's second floor (`-closeSecondary`). */
  closeSecondary(): void {
    const scrollView = this.cyl_scrollView;
    if (!this.floor.open || this.floor.closing || scrollView === null) {
      return;
    }
    this.floor.closing = true;
    this.floor.closePending = false;
    this.cyl_reportPhase();
    scrollView.animator(this.slowAnimationDuration, () => {
      scrollView.cyl_insetB = this.cyl_originalInset.bottom;
    }, () => {
      this.floor.closing = false;
      this.floor.open = false;
      this.pullingPercent = 0;
      this.cyl_reportPhase();
      this.cyl_setNeedsLayout();
      if (this.floor.closedBlock !== null) {
        this.floor.closedBlock();
      }
    });
  }

  private cyl_followOpenSecondary(): void {
    const scrollView = this.cyl_scrollView;
    if (this.floor.closing || scrollView === null) {
      return;
    }
    const openOffsetY = this.cyl_happenOffsetY() + this.cyl_secondaryHeight;
    const pushed = openOffsetY - scrollView.cyl_offsetY;
    if (scrollView.isDragging) {
      this.floor.closePending = pushed >= this.floor.closeTriggerOffset;
    } else if (this.floor.closePending) {
      this.closeSecondary();
    }
  }

  scrollViewPanStateDidChange(state: CYLRefreshPanState): void {
    super.scrollViewPanStateDidChange(state);
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return;
    }
    if (state === CYLRefreshPanState.Ended && this.floor.velocity > 0 && this.floor.triggerOffset > 0 &&
      !this.floor.open && !this.refreshing && this.state !== CYLRefreshState.NoMoreData) {
      const pulled = scrollView.cyl_offsetY - this.cyl_happenOffsetY();
      if (-scrollView.panVelocityY >= this.floor.velocity && pulled >= this.cyl_h * this.triggerRate) {
        this.openSecondary();
        return;
      }
    }
    if (state === CYLRefreshPanState.Began) {
      this.cyl_dragStartedAtEdge = scrollView.cyl_offsetY >= this.cyl_happenOffsetY() - 0.5;
    }
  }

  scrollViewContentOffsetDidChange(change: CYLRefreshOffsetChange): void {
    super.scrollViewContentOffsetDidChange(change);
    const scrollView = this.cyl_scrollView;
    if (scrollView === null || this.state === CYLRefreshState.Refreshing || this.holdingNoMoreData) {
      return;
    }
    if (this.floor.open || this.floor.closing) {
      this.cyl_followOpenSecondary();
      return;
    }
    this.cyl_originalInset = scrollView.cyl_inset;
    let currentOffsetY = scrollView.cyl_offsetY;
    const happenOffsetY = this.cyl_happenOffsetY();
    if (currentOffsetY <= happenOffsetY) {
      return;
    }
    const trigger = this.cyl_h * this.triggerRate;
    let pullingPercent = (currentOffsetY - happenOffsetY) / trigger;
    const normal2pullingOffsetY = happenOffsetY + trigger;
    if (this.state === CYLRefreshState.NoMoreData) {
      if (this.loadsAfterNoMoreData && scrollView.isDragging && currentOffsetY > normal2pullingOffsetY) {
        this.resetNoMoreData();
      } else {
        this.pullingPercent = pullingPercent;
        return;
      }
    }
    if (this.floor.triggerOffset > 0) {
      const armed = scrollView.isDragging && currentOffsetY - happenOffsetY >= this.floor.triggerOffset;
      if (scrollView.isDragging && armed !== this.floor.armed) {
        this.floor.armed = armed;
        this.cyl_reportPhase();
      } else if (!scrollView.isDragging && this.floor.armed) {
        this.openSecondary();
        return;
      }
    }
    if (scrollView.isDragging) {
      if (this.maxPullDistance > 0 && currentOffsetY - happenOffsetY > this.maxPullDistance) {
        currentOffsetY = happenOffsetY + this.maxPullDistance;
        pullingPercent = this.maxPullDistance / trigger;
        scrollView.cyl_offsetY = currentOffsetY;
      }
      this.pullingPercent = pullingPercent;
      const mayArm = this.triggerMode === CYLRefreshTriggerMode.Anywhere || this.cyl_dragStartedAtEdge;
      if (this.state === CYLRefreshState.Idle && this.refreshEnabled && mayArm &&
        currentOffsetY > normal2pullingOffsetY) {
        this.state = CYLRefreshState.Pulling;
        if (this.triggersWhenReached) {
          this.beginRefreshing();
        }
      } else if (this.state === CYLRefreshState.Pulling && currentOffsetY <= normal2pullingOffsetY) {
        this.state = CYLRefreshState.Idle;
      }
    } else if (this.state === CYLRefreshState.Pulling) {
      this.beginRefreshing();
    } else if (pullingPercent < 1) {
      this.pullingPercent = pullingPercent;
    }
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    const scrollView = this.cyl_scrollView;
    if (state !== CYLRefreshState.NoMoreData) {
      this.cyl_endNoMoreDataHold();
    }
    if (scrollView === null) {
      if (state === CYLRefreshState.Refreshing) {
        this.executeRefreshingCallback();
      }
      return;
    }
    if (state === CYLRefreshState.NoMoreData || state === CYLRefreshState.Idle) {
      if (oldState === CYLRefreshState.Refreshing) {
        if (state === CYLRefreshState.NoMoreData && this.noMoreDataDisplayDuration > 0) {
          this.cyl_holdNoMoreDataForDuration(this.noMoreDataDisplayDuration);
        } else {
          this.cyl_restoreBottomInsetAfterRefresh();
        }
      }
    } else if (state === CYLRefreshState.Refreshing) {
      this.lastRefreshCount = scrollView.cyl_totalDataCount();
      scrollView.animator(this.fastAnimationDuration, () => {
        let bottom = this.cyl_h + this.cyl_originalInset.bottom;
        const deltaH = this.heightForContentBreakView();
        if (deltaH < 0) {
          bottom -= deltaH;
        }
        this.lastBottomDelta = bottom - scrollView.cyl_insetB;
        scrollView.cyl_insetB = bottom;
        if (!scrollView.isDragging) {
          scrollView.cyl_offsetY = this.cyl_happenOffsetY() + this.cyl_h;
        }
      }, () => {
        this.executeRefreshingCallback();
      });
    }
  }

  private cyl_restoreBottomInsetAfterRefresh(): void {
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return;
    }
    scrollView.animator(this.slowAnimationDuration, () => {
      scrollView.cyl_insetB -= this.lastBottomDelta;
      this.lastBottomDelta = 0;
      if (this.endRefreshingAnimationBeginAction !== null) {
        this.endRefreshingAnimationBeginAction();
      }
      if (this.automaticallyChangeAlpha) {
        this.alpha = 0;
      }
    }, () => {
      this.pullingPercent = 0;
      if (this.endRefreshingCompletionBlock !== null) {
        this.endRefreshingCompletionBlock();
      }
    });
  }

  private cyl_holdNoMoreDataForDuration(duration: number): void {
    this.holdingNoMoreData = true;
    const generation = ++this.holdGeneration;
    setTimeout(() => {
      if (generation === this.holdGeneration && this.holdingNoMoreData) {
        this.holdingNoMoreData = false;
        this.cyl_restoreBottomInsetAfterRefresh();
      }
    }, duration * 1000);
  }

  private cyl_endNoMoreDataHold(): void {
    if (!this.holdingNoMoreData) {
      return;
    }
    this.holdingNoMoreData = false;
    this.holdGeneration++;
    this.cyl_restoreBottomInsetAfterRefresh();
  }

  willDetachFromScrollView(scrollView: CYLRefreshScrollViewModel): void {
    this.cyl_endNoMoreDataHold();
    super.willDetachFromScrollView(scrollView);
  }

  /** The row count when the last load started (tests). */
  get cyl_lastRefreshCount(): number {
    return this.lastRefreshCount;
  }
}

/** Swipe left past the end of a horizontal list (iOS `CYLRefreshTrailer`). */
export class CYLRefreshTrailerModel extends CYLRefreshComponentModel {
  /** Whether scrolling to the end starts refreshing without a release (`automaticallyRefresh`, default false). */
  automaticallyRefresh: boolean = false;
  /** How much of the trailer must show before it refreshes automatically (`triggerAutomaticallyRefreshPercent`). */
  triggerAutomaticallyRefreshPercent: number = 1;
  protected triggerByDrag: boolean = false;
  protected leftTriggerTimes: number = 1;
  private triggerTimes: number = 1;
  private ignoredRight: number = 0;
  private lastRightDelta: number = 0;
  private refreshGeneration: number = 0;

  prepare(): void {
    super.prepare();
    this.cyl_w = CYLRefreshTrailWidth;
  }

  /** A trailer calling `block` when it refreshes (`+trailerWithRefreshingBlock:`). */
  static trailerWithRefreshingBlock(block: CYLRefreshComponentAction): CYLRefreshTrailerModel {
    const trailer = new CYLRefreshTrailerModel();
    trailer.refreshingBlock = block;
    return trailer;
  }

  /** A trailer calling the target's action (`+trailerWithRefreshingTarget:refreshingAction:`). */
  static trailerWithRefreshingTarget(target: Object, action: CYLRefreshTargetAction): CYLRefreshTrailerModel {
    const trailer = new CYLRefreshTrailerModel();
    trailer.setRefreshingTarget(target, action);
    return trailer;
  }

  /** The right inset the trailer ignores (`ignoredScrollViewContentInsetRight`). */
  get ignoredScrollViewContentInsetRight(): number {
    return this.ignoredRight;
  }

  set ignoredScrollViewContentInsetRight(value: number) {
    this.ignoredRight = value;
    this.scrollViewContentSizeDidChange();
  }

  /** Automatic refreshes allowed per drag (default 1); -1 unlimited (`autoTriggerTimes`). */
  get autoTriggerTimes(): number {
    return this.triggerTimes;
  }

  set autoTriggerTimes(value: number) {
    this.triggerTimes = value;
    this.leftTriggerTimes = value;
  }

  /** The trailer's open width. */
  get expandHeight(): number {
    return this.cyl_w;
  }

  cyl_moveToScrollView(scrollView: CYLRefreshScrollViewModel | null): void {
    const width = this.cyl_w;
    super.cyl_moveToScrollView(scrollView);
    this.cyl_w = width;
    if (scrollView !== null) {
      this.cyl_h = scrollView.cyl_h;
      this.scrollViewContentSizeDidChange();
    }
  }

  scrollViewContentSizeDidChange(): void {
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return;
    }
    this.cyl_x = Math.max(scrollView.cyl_contentW, scrollView.cyl_w) + this.ignoredRight;
  }

  private widthForContentBreakView(): number {
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      return 0;
    }
    const w = scrollView.cyl_w - this.cyl_originalInset.right - this.cyl_originalInset.left;
    return scrollView.cyl_contentW - w;
  }

  /** The offset at which the trailer starts to show. */
  cyl_happenOffsetX(): number {
    const deltaW = this.widthForContentBreakView();
    return deltaW > 0 ? deltaW - this.cyl_originalInset.left : -this.cyl_originalInset.left;
  }

  private shouldAutomaticallyRefresh(change: CYLRefreshOffsetChange, pullingPercent: number): boolean {
    if (!this.automaticallyRefresh || this.state !== CYLRefreshState.Idle || !this.refreshEnabled) {
      return false;
    }
    if (this.widthForContentBreakView() <= 0 || change.newX <= change.oldX) {
      return false;
    }
    const dragging = this.cyl_scrollView !== null && this.cyl_scrollView.isDragging;
    if (dragging && this.leftTriggerTimes === 0) {
      return false;
    }
    return pullingPercent >= this.triggerAutomaticallyRefreshPercent;
  }

  scrollViewContentOffsetDidChange(change: CYLRefreshOffsetChange): void {
    super.scrollViewContentOffsetDidChange(change);
    const scrollView = this.cyl_scrollView;
    if (scrollView === null || this.state === CYLRefreshState.Refreshing) {
      return;
    }
    this.cyl_originalInset = scrollView.cyl_inset;
    const currentOffsetX = scrollView.cyl_offsetX;
    const happenOffsetX = this.cyl_happenOffsetX();
    if (currentOffsetX <= happenOffsetX) {
      return;
    }
    const pullingPercent = (currentOffsetX - happenOffsetX) / (this.cyl_w * this.triggerRate);
    if (this.state === CYLRefreshState.NoMoreData) {
      this.pullingPercent = pullingPercent;
      return;
    }
    if (this.shouldAutomaticallyRefresh(change, pullingPercent)) {
      this.triggerByDrag = scrollView.isDragging;
      this.beginRefreshing();
      return;
    }
    if (scrollView.isDragging) {
      this.pullingPercent = pullingPercent;
      const normal2pullingOffsetX = happenOffsetX + this.cyl_w * this.triggerRate;
      if (this.state === CYLRefreshState.Idle && currentOffsetX > normal2pullingOffsetX) {
        this.state = CYLRefreshState.Pulling;
      } else if (this.state === CYLRefreshState.Pulling && currentOffsetX <= normal2pullingOffsetX) {
        this.state = CYLRefreshState.Idle;
      }
    } else if (this.state === CYLRefreshState.Pulling) {
      this.beginRefreshing();
    } else if (pullingPercent < 1) {
      this.pullingPercent = pullingPercent;
    }
  }

  scrollViewPanStateDidChange(state: CYLRefreshPanState): void {
    super.scrollViewPanStateDidChange(state);
    if (state === CYLRefreshPanState.Began) {
      this.leftTriggerTimes = this.triggerTimes;
    }
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if ((state === CYLRefreshState.NoMoreData || state === CYLRefreshState.Idle) && this.triggerByDrag) {
      if (this.leftTriggerTimes !== -1) {
        this.leftTriggerTimes -= 1;
      }
      this.triggerByDrag = false;
    }
    const scrollView = this.cyl_scrollView;
    if (scrollView === null) {
      if (state === CYLRefreshState.Refreshing) {
        this.executeRefreshingCallback();
      }
      return;
    }
    if (state === CYLRefreshState.NoMoreData || state === CYLRefreshState.Idle) {
      if (oldState === CYLRefreshState.Refreshing) {
        const generation = this.refreshGeneration;
        const completion = this.endRefreshingCompletionBlock;
        scrollView.animator(this.slowAnimationDuration, () => {
          if (this.endRefreshingAnimationBeginAction !== null) {
            this.endRefreshingAnimationBeginAction();
          }
          scrollView.cyl_insetR -= this.lastRightDelta;
          if (this.automaticallyChangeAlpha) {
            this.alpha = 0;
          }
        }, () => {
          if (this.refreshGeneration === generation && !this.refreshing) {
            this.pullingPercent = 0;
          }
          if (completion !== null) {
            completion();
          }
        });
      }
    } else if (state === CYLRefreshState.Refreshing) {
      const generation = ++this.refreshGeneration;
      scrollView.animator(this.fastAnimationDuration, () => {
        let right = this.cyl_w + this.cyl_originalInset.right;
        const deltaW = this.widthForContentBreakView();
        if (deltaW < 0) {
          right -= deltaW;
        }
        this.lastRightDelta = right - scrollView.cyl_insetR;
        scrollView.cyl_insetR = right;
        if (!scrollView.isDragging) {
          scrollView.cyl_offsetX = this.cyl_happenOffsetX() + this.cyl_w;
        }
      }, () => {
        if (this.refreshGeneration === generation && this.state === CYLRefreshState.Refreshing) {
          this.executeRefreshingCallback();
        }
      });
    }
  }

  /** Loads remaining for this drag (tests). */
  get cyl_leftTriggerTimes(): number {
    return this.leftTriggerTimes;
  }

  cyl_linkTo(scrollView: CYLRefreshScrollViewModel): CYLRefreshComponentModel {
    scrollView.cyl_trailer = this;
    return this;
  }
}

/**
 * Whether the auto footer item is laid out: a footer that is not hidden (iOS: a hidden auto footer takes no room).
 * `CYLRefreshFooterView` follows the footer, so setting `hidden` removes or restores the item.
 */
export function cylAutoFooterItemShown(footer: CYLRefreshAutoFooterModel | null): boolean {
  return footer !== null && !footer.hidden;
}
