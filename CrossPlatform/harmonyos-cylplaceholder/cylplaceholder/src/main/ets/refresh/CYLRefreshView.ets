// CYLRefreshView: the ArkUI half of CYLRefresh. `CYLRefreshContainer` wraps a List / Scroll / Grid (its `content`)
// and plays the iOS scroll view: it reports the content's Scroller offset to a CYLRefreshScrollViewModel and drives
// the pull from a parallel PanGesture at the edges (the content must use `.edgeEffect(EdgeEffect.None)`, so the
// container, not the spring effect, draws the over-scroll). The header is drawn above the content, a back footer
// below it, a trailer after a horizontal content; an auto footer is a list item: put `CYLRefreshFooterView` last.
//
//   CYLRefreshContainer({ scrollView: this.sv, scroller: this.scroller }) {
//     List({ scroller: this.scroller }) { ... ListItem() { CYLRefreshFooterView({ scrollView: this.sv }) } }
//       .edgeEffect(EdgeEffect.None)
//   }
import {
  CYLRefreshActivityIndicatorModel,
  CYLRefreshAutoFooterModel,
  CYLRefreshBackFooterModel,
  CYLRefreshComponentModel,
  CYLRefreshHeaderModel,
  CYLRefreshImageViewModel,
  CYLRefreshLabel,
  CYLRefreshScrollViewModel,
  CYLRefreshTrailerModel
} from './CYLRefreshComponent';
import {
  CYLRefreshAnimationHeaderModel,
  CYLRefreshAutoAnimationFooterModel,
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshAutoStateFooterModel,
  CYLRefreshBackAnimationFooterModel,
  CYLRefreshBackNormalFooterModel,
  CYLRefreshBackStateFooterModel,
  CYLRefreshCupertinoFooterModel,
  CYLRefreshCupertinoHeaderModel,
  CYLRefreshFrames,
  CYLRefreshNormalHeaderModel,
  CYLRefreshNormalTrailerModel,
  CYLRefreshStateHeaderModel,
  CYLRefreshStateTrailerModel
} from './CYLRefreshClassics';
import { CYLRefreshScrollMode, CYLRefreshState } from './CYLRefreshConst';
import { CYLRefreshBundle } from './CYLRefreshBundle';
import { CYLRefreshIconViewModel } from './CYLRefreshIconView';

/** The share of the finger's travel that moves the content past an edge (UIScrollView's rubber band). */
const CYLRefreshPullDamping: number = 0.5;

@Builder
function cylRefreshEmptyBuilder() {
}

// MARK: - What a control shows (read by the views)

function cylStateLabel(c: CYLRefreshComponentModel): CYLRefreshLabel | null {
  if (c instanceof CYLRefreshStateHeaderModel) {
    return (c as CYLRefreshStateHeaderModel).stateLabel;
  }
  if (c instanceof CYLRefreshAutoStateFooterModel) {
    return (c as CYLRefreshAutoStateFooterModel).stateLabel;
  }
  if (c instanceof CYLRefreshBackStateFooterModel) {
    return (c as CYLRefreshBackStateFooterModel).stateLabel;
  }
  if (c instanceof CYLRefreshStateTrailerModel) {
    return (c as CYLRefreshStateTrailerModel).stateLabel;
  }
  return null;
}

function cylTimeLabel(c: CYLRefreshComponentModel): CYLRefreshLabel | null {
  if (c instanceof CYLRefreshStateHeaderModel) {
    const label = (c as CYLRefreshStateHeaderModel).lastUpdatedTimeLabel;
    return label.hidden ? null : label;
  }
  return null;
}

function cylArrow(c: CYLRefreshComponentModel): CYLRefreshImageViewModel | null {
  if (c instanceof CYLRefreshNormalHeaderModel) {
    return (c as CYLRefreshNormalHeaderModel).arrowView;
  }
  if (c instanceof CYLRefreshBackNormalFooterModel) {
    return (c as CYLRefreshBackNormalFooterModel).arrowView;
  }
  if (c instanceof CYLRefreshNormalTrailerModel) {
    return (c as CYLRefreshNormalTrailerModel).arrowView;
  }
  return null;
}

function cylArrowSource(c: CYLRefreshComponentModel, arrow: CYLRefreshImageViewModel): ResourceStr {
  if (arrow.image !== null) {
    return arrow.image;
  }
  return c instanceof CYLRefreshTrailerModel ? CYLRefreshBundle.cyl_trailArrowImage() : CYLRefreshBundle.cyl_arrowImage();
}

function cylSpinner(c: CYLRefreshComponentModel): CYLRefreshActivityIndicatorModel | null {
  if (c instanceof CYLRefreshNormalHeaderModel) {
    return (c as CYLRefreshNormalHeaderModel).loadingView;
  }
  if (c instanceof CYLRefreshAutoNormalFooterModel) {
    return (c as CYLRefreshAutoNormalFooterModel).loadingView;
  }
  if (c instanceof CYLRefreshBackNormalFooterModel) {
    return (c as CYLRefreshBackNormalFooterModel).loadingView;
  }
  if (c instanceof CYLRefreshCupertinoHeaderModel) {
    return (c as CYLRefreshCupertinoHeaderModel).activityIndicator;
  }
  if (c instanceof CYLRefreshCupertinoFooterModel) {
    return (c as CYLRefreshCupertinoFooterModel).activityIndicator;
  }
  return null;
}

function cylFrames(c: CYLRefreshComponentModel): CYLRefreshFrames | null {
  if (c instanceof CYLRefreshAnimationHeaderModel) {
    return (c as CYLRefreshAnimationHeaderModel).frames;
  }
  if (c instanceof CYLRefreshAutoAnimationFooterModel) {
    return (c as CYLRefreshAutoAnimationFooterModel).frames;
  }
  if (c instanceof CYLRefreshBackAnimationFooterModel) {
    return (c as CYLRefreshBackAnimationFooterModel).frames;
  }
  return null;
}

function cylSideImage(c: CYLRefreshComponentModel): ResourceStr | null {
  if (c instanceof CYLRefreshStateHeaderModel) {
    return (c as CYLRefreshStateHeaderModel).cyl_resultImage;
  }
  if (c.state === CYLRefreshState.NoMoreData) {
    if (c instanceof CYLRefreshAutoNormalFooterModel) {
      return (c as CYLRefreshAutoNormalFooterModel).noMoreDataImage;
    }
    if (c instanceof CYLRefreshBackNormalFooterModel) {
      return (c as CYLRefreshBackNormalFooterModel).noMoreDataImage;
    }
  }
  return null;
}

function cylIconWidth(c: CYLRefreshComponentModel): number {
  if (c instanceof CYLRefreshNormalHeaderModel) {
    const w = (c as CYLRefreshNormalHeaderModel).iconSize.width;
    return w > 0 ? w : 15;
  }
  if (c instanceof CYLRefreshBackNormalFooterModel) {
    const w = (c as CYLRefreshBackNormalFooterModel).iconSize.width;
    return w > 0 ? w : 15;
  }
  return 15;
}

function cylIconHeight(c: CYLRefreshComponentModel): number {
  if (c instanceof CYLRefreshNormalHeaderModel) {
    const h = (c as CYLRefreshNormalHeaderModel).iconSize.height;
    return h > 0 ? h : 40;
  }
  if (c instanceof CYLRefreshBackNormalFooterModel) {
    const h = (c as CYLRefreshBackNormalFooterModel).iconSize.height;
    return h > 0 ? h : 40;
  }
  return 40;
}

function cylLabelInset(c: CYLRefreshComponentModel): number {
  if (c instanceof CYLRefreshStateHeaderModel) {
    return (c as CYLRefreshStateHeaderModel).labelLeftInset;
  }
  if (c instanceof CYLRefreshAutoStateFooterModel) {
    return (c as CYLRefreshAutoStateFooterModel).labelLeftInset;
  }
  if (c instanceof CYLRefreshBackStateFooterModel) {
    return (c as CYLRefreshBackStateFooterModel).labelLeftInset;
  }
  return 25;
}

function cylIconTrailing(c: CYLRefreshComponentModel): boolean {
  return c instanceof CYLRefreshStateHeaderModel && (c as CYLRefreshStateHeaderModel).iconOnTrailingSide;
}

function cylLabelColor(c: CYLRefreshComponentModel, label: CYLRefreshLabel): string {
  return c.colorAccent !== null ? c.colorAccent : label.textColor;
}

function cylFrameInfos(frames: CYLRefreshFrames): ImageFrameInfo[] {
  const each = frames.images.length > 0 ? Math.max(16, frames.duration * 1000 / frames.images.length) : 100;
  return frames.images.map((src: ResourceStr) => {
    const info: ImageFrameInfo = { src: src, duration: each };
    return info;
  });
}

function cylIconFrameInfos(icon: CYLRefreshIconViewModel): ImageFrameInfo[] {
  const current = icon.current;
  if (current === null || current.images.length === 0) {
    return [];
  }
  const each = Math.max(16, (current.duration > 0 ? current.duration : current.images.length * 0.1) * 1000 /
    current.images.length);
  return current.images.map((src: ResourceStr) => {
    const info: ImageFrameInfo = { src: src, duration: each };
    return info;
  });
}

function cylIconFrame(icon: CYLRefreshIconViewModel): ResourceStr {
  const current = icon.current;
  if (current === null || current.images.length === 0) {
    return '';
  }
  return current.images[Math.min(current.images.length - 1, Math.max(0, icon.frameIndex))];
}

// MARK: - One control

/**
 * Draws the header, footer or trailer of a scroll view model (`role`: 'header', 'footer' or 'trailer') with the
 * look of its class: state texts, last update time, arrow, spinner, frames or icon animation.
 */
@Component
export struct CYLRefreshComponentView {
  scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  role: string = 'header';
  @State private tick: number = 0;
  private listened: CYLRefreshComponentModel | null = null;
  private onChange: () => void = () => {
    this.follow();
    this.tick++;
  };

  aboutToAppear(): void {
    this.scrollView.addChangeListener(this.onChange);
    this.follow();
  }

  aboutToDisappear(): void {
    this.scrollView.removeChangeListener(this.onChange);
    if (this.listened !== null) {
      this.listened.removeChangeListener(this.onChange);
      this.listened = null;
    }
  }

  private current(): CYLRefreshComponentModel | null {
    if (this.role === 'footer') {
      return this.scrollView.cyl_footer;
    }
    if (this.role === 'trailer') {
      return this.scrollView.cyl_trailer;
    }
    return this.scrollView.cyl_header;
  }

  private follow(): void {
    const c = this.current();
    if (c === this.listened) {
      return;
    }
    if (this.listened !== null) {
      this.listened.removeChangeListener(this.onChange);
    }
    if (c !== null) {
      c.addChangeListener(this.onChange);
    }
    this.listened = c;
  }

  private model(): CYLRefreshComponentModel | null {
    return this.tick >= 0 ? this.current() : null;
  }

  @Builder
  sideIcon(c: CYLRefreshComponentModel) {
    if (cylSideImage(c) !== null) {
      Image(cylSideImage(c) as ResourceStr).width(20).height(20).objectFit(ImageFit.Contain)
    } else if (cylFrames(c) !== null && (cylFrames(c) as CYLRefreshFrames).images.length > 0) {
      if ((cylFrames(c) as CYLRefreshFrames).animating) {
        ImageAnimator()
          .images(cylFrameInfos(cylFrames(c) as CYLRefreshFrames))
          .state(AnimationStatus.Running)
          .iterations(-1)
          .width(40)
          .height(40)
      } else {
        Image((cylFrames(c) as CYLRefreshFrames).images[(cylFrames(c) as CYLRefreshFrames).index])
          .width(40)
          .height(40)
          .objectFit(ImageFit.Contain)
      }
    } else if (cylSpinner(c) !== null && !(cylSpinner(c) as CYLRefreshActivityIndicatorModel).hidden) {
      if ((cylSpinner(c) as CYLRefreshActivityIndicatorModel).animating) {
        LoadingProgress()
          .width(24)
          .height(24)
          .color(c.colorAccent !== null ? c.colorAccent : (cylSpinner(c) as CYLRefreshActivityIndicatorModel).color)
      } else {
        LoadingProgress()
          .width(24)
          .height(24)
          .enableLoading(false)
          .opacity((cylSpinner(c) as CYLRefreshActivityIndicatorModel).progress)
          .color(c.colorAccent !== null ? c.colorAccent : (cylSpinner(c) as CYLRefreshActivityIndicatorModel).color)
      }
    } else if (cylArrow(c) !== null && !(cylArrow(c) as CYLRefreshImageViewModel).hidden) {
      Image(cylArrowSource(c, cylArrow(c) as CYLRefreshImageViewModel))
        .width(cylIconWidth(c))
        .height(cylIconHeight(c))
        .objectFit(ImageFit.Contain)
        .fillColor(c.colorAccent !== null ? c.colorAccent : '#5A5A5A')
        .rotate({ angle: (cylArrow(c) as CYLRefreshImageViewModel).rotation })
        .animation({ duration: c.fastAnimationDuration * 1000 })
    }
  }

  @Builder
  iconView(c: CYLRefreshComponentModel) {
    Column({ space: 4 }) {
      if (cylIconFrameInfos(c.cyl_iconView).length > 0) {
        if (c.cyl_iconView.playing) {
          ImageAnimator()
            .images(cylIconFrameInfos(c.cyl_iconView))
            .state(AnimationStatus.Running)
            .iterations(-1)
            .width(c.cyl_iconView.iconSize.width)
            .height(c.cyl_iconView.iconSize.height)
        } else {
          Image(cylIconFrame(c.cyl_iconView))
            .width(c.cyl_iconView.iconSize.width)
            .height(c.cyl_iconView.iconSize.height)
            .objectFit(ImageFit.Contain)
        }
      } else if (c.cyl_iconView.current !== null && c.cyl_iconView.current.filePath !== null &&
        c.cyl_iconView.current.isPlayableNow) {
        Image(CYLRefreshBundle.animationSource(c.cyl_iconView.current.filePath as string))
          .width(c.cyl_iconView.iconSize.width)
          .height(c.cyl_iconView.iconSize.height)
          .objectFit(ImageFit.Contain)
      }
      if (c.cyl_iconView.title !== null) {
        Text(c.cyl_iconView.title).fontSize(c.cyl_iconView.titleFont).fontColor(c.cyl_iconView.titleColor)
      }
    }
  }

  build() {
    if (this.model() !== null) {
      Stack() {
        if (this.role === 'trailer') {
          Row({ space: 4 }) {
            if (cylArrow(this.model() as CYLRefreshComponentModel) !== null) {
              this.sideIcon(this.model() as CYLRefreshComponentModel)
            }
            if (cylStateLabel(this.model() as CYLRefreshComponentModel) !== null) {
              Text((cylStateLabel(this.model() as CYLRefreshComponentModel) as CYLRefreshLabel).text.split('').join('\n'))
                .fontSize((cylStateLabel(this.model() as CYLRefreshComponentModel) as CYLRefreshLabel).fontSize)
                .fontWeight(FontWeight.Bold)
                .fontColor(cylLabelColor(this.model() as CYLRefreshComponentModel,
                  cylStateLabel(this.model() as CYLRefreshComponentModel) as CYLRefreshLabel))
                .textAlign(TextAlign.Center)
            }
          }
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if ((this.model() as CYLRefreshComponentModel).cyl_usesIconView &&
          !(this.model() as CYLRefreshComponentModel).cyl_iconView.hidden) {
          this.iconView(this.model() as CYLRefreshComponentModel)
        } else {
          Row({ space: cylLabelInset(this.model() as CYLRefreshComponentModel) }) {
            if (!cylIconTrailing(this.model() as CYLRefreshComponentModel)) {
              this.sideIcon(this.model() as CYLRefreshComponentModel)
            }
            Column({ space: 2 }) {
              if (cylStateLabel(this.model() as CYLRefreshComponentModel) !== null &&
                !(cylStateLabel(this.model() as CYLRefreshComponentModel) as CYLRefreshLabel).hidden) {
                Text((cylStateLabel(this.model() as CYLRefreshComponentModel) as CYLRefreshLabel).text)
                  .fontSize((cylStateLabel(this.model() as CYLRefreshComponentModel) as CYLRefreshLabel).fontSize)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(cylLabelColor(this.model() as CYLRefreshComponentModel,
                    cylStateLabel(this.model() as CYLRefreshComponentModel) as CYLRefreshLabel))
                  .onClick(() => {
                    const m = this.current();
                    if (m instanceof CYLRefreshAutoStateFooterModel) {
                      (m as CYLRefreshAutoStateFooterModel).stateLabelClick();
                    }
                  })
              }
              if (cylTimeLabel(this.model() as CYLRefreshComponentModel) !== null) {
                Text((cylTimeLabel(this.model() as CYLRefreshComponentModel) as CYLRefreshLabel).text)
                  .fontSize((cylTimeLabel(this.model() as CYLRefreshComponentModel) as CYLRefreshLabel).fontSize)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(cylLabelColor(this.model() as CYLRefreshComponentModel,
                    cylTimeLabel(this.model() as CYLRefreshComponentModel) as CYLRefreshLabel))
                  .margin({ top: (this.model() as CYLRefreshStateHeaderModel).titleTimeSpacing })
              }
            }
            .alignItems(HorizontalAlign.Center)
            if (cylIconTrailing(this.model() as CYLRefreshComponentModel)) {
              this.sideIcon(this.model() as CYLRefreshComponentModel)
            }
          }
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .opacity((this.model() as CYLRefreshComponentModel).cyl_autoHidden ? 0 :
        (this.model() as CYLRefreshComponentModel).alpha)
      .visibility((this.model() as CYLRefreshComponentModel).hidden ? Visibility.Hidden : Visibility.Visible)
      .backgroundColor((this.model() as CYLRefreshComponentModel).colorPrimary !== null ?
        (this.model() as CYLRefreshComponentModel).colorPrimary as string : Color.Transparent)
    }
  }
}

// MARK: - The auto footer item

/**
 * The scroll view's auto footer as the last item of the list (iOS: the auto footer sits after the content). It
 * reports how much of it is visible, which starts the automatic load (triggerAutomaticallyRefreshPercent).
 */
@Component
export struct CYLRefreshFooterView {
  scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  @State private tick: number = 0;
  private onChange: () => void = () => {
    this.tick++;
  };

  aboutToAppear(): void {
    this.scrollView.addChangeListener(this.onChange);
  }

  aboutToDisappear(): void {
    this.scrollView.removeChangeListener(this.onChange);
  }

  private footer(): CYLRefreshAutoFooterModel | null {
    const f = this.tick >= 0 ? this.scrollView.cyl_footer : null;
    return f instanceof CYLRefreshAutoFooterModel ? f as CYLRefreshAutoFooterModel : null;
  }

  build() {
    if (this.footer() !== null && !(this.footer() as CYLRefreshAutoFooterModel).hidden) {
      CYLRefreshComponentView({ scrollView: this.scrollView, role: 'footer' })
        .width('100%')
        .height((this.footer() as CYLRefreshAutoFooterModel).cyl_h)
        .onVisibleAreaChange([0, 0.25, 0.5, 0.75, 1.0], (visible: boolean, ratio: number) => {
          const f = this.footer();
          if (f !== null) {
            f.cyl_visibleRatioDidChange(visible ? ratio : 0);
          }
        })
    }
  }
}

// MARK: - The container

/**
 * The refresh container (the iOS scroll view with `cyl_header` / `cyl_footer` / `cyl_trailer`): wraps the content
 * built by `content`, which scrolls with `scroller` and has `.edgeEffect(EdgeEffect.None)`. `horizontal` makes the
 * pull horizontal (trailer). `secondaryHeaderBuilder` / `secondaryFooterBuilder` (wrapBuilder) draw the second floors while the
 * header's / back footer's `secondaryView` is set.
 */
@Component
export struct CYLRefreshContainer {
  scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  scroller: Scroller = new Scroller();
  horizontal: boolean = false;
  @BuilderParam content: () => void = cylRefreshEmptyBuilder;
  /** Draws the header's second floor (wrapBuilder of a global @Builder), or null. */
  secondaryHeaderBuilder: WrappedBuilder<[]> | null = null;
  /** Draws the back footer's second floor, or null. */
  secondaryFooterBuilder: WrappedBuilder<[]> | null = null;
  @State private tick: number = 0;
  private viewW: number = 0;
  private viewH: number = 0;
  private contentW: number = 0;
  private contentH: number = 0;
  private baseTop: number = Number.NaN;
  private baseBottom: number = Number.NaN;
  private baseRight: number = Number.NaN;
  private fingerTop: number = 0;
  private fingerBottom: number = 0;
  private fingerRight: number = 0;
  private pollTimer: number = -1;
  private onChange: () => void = () => {
    this.tick++;
  };

  aboutToAppear(): void {
    const sv = this.scrollView;
    sv.addChangeListener(this.onChange);
    sv.animator = (duration: number, changes: () => void, completion: () => void) => {
      if (duration <= 0) {
        changes();
        completion();
        return;
      }
      this.getUIContext().animateTo({ duration: duration * 1000, curve: Curve.EaseInOut, onFinish: completion },
        changes);
    };
    sv.scrollRequest = (x: number, y: number) => {
      this.scroller.scrollTo({ xOffset: x, yOffset: y });
    };
    sv.dataCountProvider = sv.dataCountProvider;
    sv.cyl_setWindow(true);
  }

  aboutToDisappear(): void {
    this.scrollView.removeChangeListener(this.onChange);
    this.scrollView.cyl_setWindow(false);
    this.scrollView.scrollRequest = null;
    if (this.pollTimer >= 0) {
      clearInterval(this.pollTimer);
      this.pollTimer = -1;
    }
  }

  /** Reads the Scroller and reports it (estimating the content size: exact at the end). */
  private sample(): void {
    const offset = this.scroller.currentOffset();
    const atEnd = this.scroller.isAtEnd();
    const x = Math.max(0, offset.xOffset);
    const y = Math.max(0, offset.yOffset);
    if (this.horizontal) {
      this.contentW = atEnd ? x + this.viewW : Math.max(this.contentW, x + this.viewW + 1);
      this.contentH = this.viewH;
    } else {
      this.contentH = atEnd ? y + this.viewH : Math.max(this.contentH, y + this.viewH + 1);
      this.contentW = this.viewW;
    }
    this.scrollView.cyl_reportScroll(x, y, this.viewW, this.viewH, this.contentW, this.contentH);
  }

  /** Keeps sampling while a fling settles, so an auto footer sees the end. */
  private pollAfterRelease(): void {
    if (this.pollTimer >= 0) {
      clearInterval(this.pollTimer);
    }
    let left = 15;
    this.pollTimer = setInterval(() => {
      this.sample();
      left--;
      if (left <= 0 && this.pollTimer >= 0) {
        clearInterval(this.pollTimer);
        this.pollTimer = -1;
      }
    }, 100);
  }

  private panUpdate(event: GestureEvent): void {
    this.sample();
    const sv = this.scrollView;
    const atEnd = this.scroller.isAtEnd();
    if (this.horizontal) {
      const d = event.offsetX;
      if (sv.cyl_trailer !== null && atEnd && (d < 0 || this.fingerRight > 0)) {
        if (Number.isNaN(this.baseRight)) {
          this.baseRight = d;
        }
        this.fingerRight = Math.max(0, this.baseRight - d) * CYLRefreshPullDamping;
      } else {
        this.baseRight = Number.NaN;
        this.fingerRight = 0;
      }
      sv.cyl_panChanged(0, 0, this.fingerRight);
      return;
    }
    const d = event.offsetY;
    const atTop = sv.scrollerY <= 0.5;
    if (sv.cyl_header !== null && atTop && (d > 0 || this.fingerTop > 0)) {
      if (Number.isNaN(this.baseTop)) {
        this.baseTop = d;
      }
      this.fingerTop = Math.max(0, d - this.baseTop) * CYLRefreshPullDamping;
    } else {
      this.baseTop = Number.NaN;
      this.fingerTop = 0;
    }
    const back = sv.cyl_footer instanceof CYLRefreshBackFooterModel;
    if (back && this.fingerTop === 0 && atEnd && (d < 0 || this.fingerBottom > 0)) {
      if (Number.isNaN(this.baseBottom)) {
        this.baseBottom = d;
      }
      this.fingerBottom = Math.max(0, this.baseBottom - d) * CYLRefreshPullDamping;
    } else {
      this.baseBottom = Number.NaN;
      this.fingerBottom = 0;
    }
    sv.cyl_panChanged(this.fingerTop, this.fingerBottom, 0);
  }

  private panEnd(event: GestureEvent | null, cancelled: boolean): void {
    this.sample();
    this.baseTop = Number.NaN;
    this.baseBottom = Number.NaN;
    this.baseRight = Number.NaN;
    this.fingerTop = 0;
    this.fingerBottom = 0;
    this.fingerRight = 0;
    this.scrollView.cyl_panEnded(event !== null ? event.velocityX : 0, event !== null ? event.velocityY : 0, cancelled);
    this.pollAfterRelease();
  }

  private sv(): CYLRefreshScrollViewModel {
    return this.tick >= 0 ? this.scrollView : this.scrollView;
  }

  private headerHeight(h: CYLRefreshHeaderModel): number {
    return h.scrollMode === CYLRefreshScrollMode.Stretch ? Math.max(0, this.sv().revealTop) : h.cyl_h;
  }

  private headerY(h: CYLRefreshHeaderModel): number {
    if (h.scrollMode === CYLRefreshScrollMode.Move) {
      return this.sv().revealTop - h.cyl_h - h.ignoredScrollViewContentInsetTop;
    }
    return 0;
  }

  private headerSecondaryHeight(): number {
    const h = this.sv().cyl_header;
    return h !== null ? h.cyl_secondaryHeight : 0;
  }

  private footerSecondaryHeight(): number {
    const f = this.sv().cyl_footer;
    return f instanceof CYLRefreshBackFooterModel ? (f as CYLRefreshBackFooterModel).cyl_secondaryHeight : 0;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.sv().cyl_header !== null &&
        (this.sv().cyl_header as CYLRefreshHeaderModel).scrollMode === CYLRefreshScrollMode.Behind) {
        CYLRefreshComponentView({ scrollView: this.scrollView, role: 'header' })
          .width('100%')
          .height((this.sv().cyl_header as CYLRefreshHeaderModel).cyl_h)
          .position({ x: 0, y: 0 })
      }
      if (this.sv().cyl_header !== null && (this.sv().cyl_header as CYLRefreshHeaderModel).secondaryView !== null) {
        Column() {
          if (this.secondaryHeaderBuilder !== null) {
            (this.secondaryHeaderBuilder as WrappedBuilder<[]>).builder()
          }
        }
        .width('100%')
        .height(this.headerSecondaryHeight())
        .position({ x: 0, y: this.sv().revealTop - this.headerSecondaryHeight() })
        .zIndex((this.sv().cyl_header as CYLRefreshHeaderModel).secondaryOpen ? 3 : 0)
      }
      Column() {
        this.content()
      }
      .width('100%')
      .height('100%')
      .translate({ x: -this.sv().revealRight, y: this.sv().revealTop - this.sv().revealBottom })
      .zIndex(1)

      if (this.sv().cyl_header !== null &&
        (this.sv().cyl_header as CYLRefreshHeaderModel).scrollMode !== CYLRefreshScrollMode.Behind) {
        CYLRefreshComponentView({ scrollView: this.scrollView, role: 'header' })
          .width('100%')
          .height(this.headerHeight(this.sv().cyl_header as CYLRefreshHeaderModel))
          .position({ x: 0, y: this.headerY(this.sv().cyl_header as CYLRefreshHeaderModel) })
          .zIndex((this.sv().cyl_header as CYLRefreshHeaderModel).scrollMode === CYLRefreshScrollMode.Front ? 2 : 1)
      }
      if (this.sv().cyl_footer instanceof CYLRefreshBackFooterModel) {
        CYLRefreshComponentView({ scrollView: this.scrollView, role: 'footer' })
          .width('100%')
          .height((this.sv().cyl_footer as CYLRefreshBackFooterModel).cyl_h)
          .position({ x: 0, y: this.viewH - this.sv().revealBottom })
          .zIndex(1)
        if ((this.sv().cyl_footer as CYLRefreshBackFooterModel).secondaryView !== null) {
          Column() {
            if (this.secondaryFooterBuilder !== null) {
              (this.secondaryFooterBuilder as WrappedBuilder<[]>).builder()
            }
          }
          .width('100%')
          .height(this.footerSecondaryHeight())
          .position({ x: 0, y: this.viewH - this.sv().revealBottom })
          .zIndex((this.sv().cyl_footer as CYLRefreshBackFooterModel).secondaryOpen ? 3 : 0)
        }
      }
      if (this.sv().cyl_trailer !== null) {
        CYLRefreshComponentView({ scrollView: this.scrollView, role: 'trailer' })
          .width((this.sv().cyl_trailer as CYLRefreshTrailerModel).cyl_w)
          .height('100%')
          .position({ x: this.viewW - this.sv().revealRight, y: 0 })
          .zIndex(1)
      }
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.viewW = Number(newValue.width);
      this.viewH = Number(newValue.height);
      this.sample();
    })
    .parallelGesture(
      PanGesture({ direction: this.horizontal ? PanDirection.Horizontal : PanDirection.Vertical, distance: 2 })
        .onActionStart((event: GestureEvent) => {
          this.sample();
          this.scrollView.cyl_panBegan();
        })
        .onActionUpdate((event: GestureEvent) => {
          this.panUpdate(event);
        })
        .onActionEnd((event: GestureEvent) => {
          this.panEnd(event, false);
        })
        .onActionCancel(() => {
          this.panEnd(null, true);
        })
    )
  }
}
