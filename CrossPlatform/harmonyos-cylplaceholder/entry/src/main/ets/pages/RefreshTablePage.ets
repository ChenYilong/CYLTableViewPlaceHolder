// CYLRefreshTableViewController: MJRefresh's table examples 01–06 (pull down), 11–21 (pull up) and 51–56 (animated
// icons), one per method (param.value). 5 random rows to start; loadNewData puts 5 rows at the top, loadMoreData
// appends 1, loadLastData appends 5 then "no more data", loadOnceData appends 5 then hides the footer; the list
// reloads and the control ends after CYLRefreshDuration (2 s). A row opens the test page (odd rows push, even rows
// present). The custom controls of CYLRefreshDIYControls.swift (MJDIYHeader / MJDIYAutoFooter / MJDIYBackFooter) are
// CYLRefresh header / footer models (50 high) drawn by the container's custom slots (headerBuilder / footerBuilder, and
// CYLRefreshFooterView's footerBuilder) from their state and pull: label, switch, logo and spinner.
import {
  CYLRefreshAnimationHeaderModel,
  CYLRefreshAutoAnimationFooterModel,
  CYLRefreshAutoFooterModel,
  CYLRefreshAutoGifFooterModel,
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshBackAnimationFooterModel,
  CYLRefreshBackFooterModel,
  CYLRefreshBackNormalFooterModel,
  CYLRefreshComponentModel,
  CYLRefreshContainer,
  CYLRefreshFooterModel,
  CYLRefreshFooterView,
  CYLRefreshGifHeaderModel,
  CYLRefreshHeaderModel,
  CYLRefreshIconAttributes,
  CYLRefreshIconSize,
  CYLRefreshNormalHeaderModel,
  CYLRefreshScrollViewModel,
  CYLRefreshState
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { RouteParam } from '../common/Routes';
import { BarButton } from '../common/Ui';
import { animationPath } from '../feed/RefreshSetups';
import { showRefreshTest } from './RefreshTestPage';

/** MJRefresh's MJDuration: long enough to see the refreshing state. */
const CYLRefreshDuration: number = 2000;

/** CYLRefreshExampleImages: turning arrows while idle, a ring while refreshing (each GIF plays by itself). */
function idleImages(): ResourceStr[] {
  return [$rawfile('example/core-animations/CYLRefreshArrows.gif')];
}

function refreshingImages(): ResourceStr[] {
  return [$rawfile('example/core-animations/CYLRefreshRing.gif')];
}

/** MJChiBaoZiHeader: images for the idle, pulling and refreshing states. */
function exampleImagesHeader(): CYLRefreshAnimationHeaderModel {
  const header = new CYLRefreshAnimationHeaderModel();
  header.setAnimationImages(idleImages(), 0, CYLRefreshState.Idle);
  header.setAnimationImages(refreshingImages(), 0, CYLRefreshState.Pulling);
  header.setAnimationImages(refreshingImages(), 0, CYLRefreshState.Refreshing);
  return header;
}

/** MJChiBaoZiFooter: images for the refreshing state of an automatic footer. */
function exampleImagesFooter(): CYLRefreshAutoAnimationFooterModel {
  const footer = new CYLRefreshAutoAnimationFooterModel();
  footer.setAnimationImages(refreshingImages(), 0, CYLRefreshState.Refreshing);
  return footer;
}

/** MJChiBaoZiFooter2: images for the idle, pulling and refreshing states of a back footer. */
function exampleImagesBackFooter(): CYLRefreshBackAnimationFooterModel {
  const footer = new CYLRefreshBackAnimationFooterModel();
  footer.setAnimationImages(idleImages(), 0, CYLRefreshState.Idle);
  footer.setAnimationImages(refreshingImages(), 0, CYLRefreshState.Pulling);
  footer.setAnimationImages(refreshingImages(), 0, CYLRefreshState.Refreshing);
  return footer;
}

function size(w: number, h: number = -1): CYLRefreshIconSize {
  return new CYLRefreshIconSize(w, h < 0 ? w : h);
}

// MARK: - The custom controls (MJDIY…)

/** MJDIYHeader: 50 high; the page draws it and follows its state and pull. */
class CYLRefreshDIYHeader extends CYLRefreshHeaderModel {
  onChange: (() => void) | null = null;
  /** What the page's builder draws. */
  look: DIYLook = new DIYLook();

  prepare(): void {
    super.prepare();
    this.cyl_h = 50;
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.onChange !== undefined && this.onChange !== null) {
      this.onChange();
    }
  }

  cyl_pullingPercentDidChange(): void {
    super.cyl_pullingPercentDidChange();
    if (this.onChange !== undefined && this.onChange !== null) {
      this.onChange();
    }
  }
}

/** MJDIYAutoFooter: 50 high, the last item of the list. */
class CYLRefreshDIYAutoFooter extends CYLRefreshAutoFooterModel {
  onChange: (() => void) | null = null;
  /** What the page's builder draws. */
  look: DIYLook = new DIYLook();

  prepare(): void {
    super.prepare();
    this.cyl_h = 50;
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.onChange !== undefined && this.onChange !== null) {
      this.onChange();
    }
  }
}

/** MJDIYBackFooter: 50 high, below the content. */
class CYLRefreshDIYBackFooter extends CYLRefreshBackFooterModel {
  onChange: (() => void) | null = null;
  /** What the page's builder draws. */
  look: DIYLook = new DIYLook();

  prepare(): void {
    super.prepare();
    this.cyl_h = 50;
  }

  cyl_stateDidChange(oldState: CYLRefreshState, state: CYLRefreshState): void {
    super.cyl_stateDidChange(oldState, state);
    if (this.onChange !== undefined && this.onChange !== null) {
      this.onChange();
    }
  }

  cyl_pullingPercentDidChange(): void {
    super.cyl_pullingPercentDidChange();
    if (this.onChange !== undefined && this.onChange !== null) {
      this.onChange();
    }
  }
}

/** What a custom control shows. */
class DIYLook {
  text: string = '';
  color: string = 'rgb(255, 128, 0)';
  on: boolean = false;
  spinning: boolean = false;
}

/** MJDIYHeader's color: from orange to purple as the control is pulled out. */
function diyColor(pullingPercent: number): string {
  const c = (v: number): number => Math.round(Math.max(0, Math.min(1, v)) * 255);
  return 'rgb(' + c(1 - pullingPercent * 0.5) + ', ' + c(0.5 - 0.5 * pullingPercent) + ', ' +
    c(0.5 * pullingPercent) + ')';
}

/** The switch of a custom control: only for show. */
@Builder
function diySwitch(on: boolean) {
  Toggle({ type: ToggleType.Switch, isOn: on })
    .enabled(false)
    .hitTestBehavior(HitTestMode.None)
    .accessibilityLevel('no')
}

@Builder
function diySpinner(spinning: boolean) {
  LoadingProgress()
    .width(24)
    .height(24)
    .visibility(spinning ? Visibility.Visible : Visibility.Hidden)
}

/** MJDIYHeader / MJDIYBackFooter: switch at 40, label inset 72, spinner at w − 30; the logo above / below. */
@Builder
function diyControl(look: DIYLook, logoAbove: boolean) {
  Stack() {
    Image($rawfile('example/tab/refresh_selected.svg'))
      .width(40)
      .height(40)
      .fillColor('#30B0C7')
      .objectFit(ImageFit.Contain)
      .position({ x: '50%', y: logoAbove ? -60 : 80 })
      .translate({ x: -20 })
      .accessibilityLevel('no')
    Row() {
      Row() {
        diySwitch(look.on)
      }
      .width(72)
      .justifyContent(FlexAlign.Center)
      Text(look.text)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(look.color)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .minFontSize(9)
        .maxFontSize(16)
        .layoutWeight(1)
      Row() {
        diySpinner(look.spinning)
      }
      .width(60)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(50)
  }
  .width('100%')
  .height(50)
}

/** MJDIYAutoFooter: spinner at 30, label inset 72, switch at w − 40; orange label. */
@Builder
function diyAutoFooterLook(look: DIYLook) {
  Row() {
    Row() {
      diySpinner(look.spinning)
    }
    .width(60)
    .justifyContent(FlexAlign.Center)
    Text(look.text)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('rgb(255, 128, 0)')
      .textAlign(TextAlign.Center)
      .maxLines(1)
      .minFontSize(9)
      .maxFontSize(16)
      .layoutWeight(1)
    Row() {
      diySwitch(look.on)
    }
    .width(72)
    .justifyContent(FlexAlign.Center)
  }
  .width('100%')
  .height(50)
}

/** MJDIYHeader, drawn in the container's header area. */
@Builder
function diyHeaderControl(c: CYLRefreshComponentModel) {
  diyControl((c as CYLRefreshDIYHeader).look, true)
}

/** MJDIYBackFooter, drawn in the container's back footer area. */
@Builder
function diyBackFooterControl(c: CYLRefreshComponentModel) {
  diyControl((c as CYLRefreshDIYBackFooter).look, false)
}

/** MJDIYAutoFooter, drawn as the auto footer item. */
@Builder
function diyAutoFooterControl(c: CYLRefreshComponentModel) {
  diyAutoFooterLook((c as CYLRefreshDIYAutoFooter).look)
}
class Example {
  header: CYLRefreshHeaderModel;
  footer: CYLRefreshFooterModel | null;

  constructor(header: CYLRefreshHeaderModel, footer: CYLRefreshFooterModel | null) {
    this.header = header;
    this.footer = footer;
  }
}

@Component
export struct RefreshTablePage {
  param: RouteParam = new RouteParam();
  /** What the list shows (tableView.reloadData copies `data`). */
  @State rows: string[] = [];
  @State diyHeader: boolean = false;
  @State diyAutoFooter: boolean = false;
  @State diyBackFooter: boolean = false;
  /** The fake data. */
  private data: string[] = [];
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private method: string = 'example01';
  private more: string = 'loadMoreData';
  private timers: number[] = [];
  private bottomInset: number = 0;

  aboutToAppear(): void {
    this.method = this.param.value.length > 0 ? this.param.value : 'example01';
    for (let i = 0; i < 5; i++) {
      this.data.push(this.randomData());
    }
    this.rows = this.data.slice();
    this.scrollView.dataCountProvider = () => this.rows.length;
    const example = this.makeExample(this.method);
    example.header.refreshingBlock = () => this.loadNewData();
    if (example.footer !== null) {
      const footer = example.footer as CYLRefreshFooterModel;
      footer.refreshingBlock = () => this.loadFooterData();
    }
    this.scrollView.cyl_header = example.header;
    this.scrollView.cyl_footer = example.footer;
    example.header.beginRefreshing();
  }

  aboutToDisappear(): void {
    this.timers.forEach((id: number) => clearTimeout(id));
  }

  private later(ms: number, action: () => void): void {
    this.timers.push(setTimeout(action, ms));
  }

  private randomData(): string {
    return t('CYLScenarioMJRandomData', Math.floor(Math.random() * 1000000));
  }

  // MARK: - Examples

  private makeExample(method: string): Example {
    switch (method) {
      case 'example02':
        return new Example(exampleImagesHeader(), null);
      case 'example03': {
        const header = new CYLRefreshNormalHeaderModel();
        header.automaticallyChangeAlpha = true;
        header.lastUpdatedTimeLabel.hidden = true;
        return new Example(header, null);
      }
      case 'example04': {
        const header = exampleImagesHeader();
        header.lastUpdatedTimeLabel.hidden = true;
        header.stateLabel.hidden = true;
        return new Example(header, null);
      }
      case 'example05': {
        const header = new CYLRefreshNormalHeaderModel();
        header.setTitle(t('CYLScenarioMJCustomIdle'), CYLRefreshState.Idle);
        header.setTitle(t('CYLScenarioMJCustomPulling'), CYLRefreshState.Pulling);
        header.setTitle(t('CYLScenarioMJCustomLoading'), CYLRefreshState.Refreshing);
        header.stateLabel.fontSize = 15;
        header.stateLabel.fontWeight = 400;
        header.lastUpdatedTimeLabel.fontSize = 14;
        header.lastUpdatedTimeLabel.fontWeight = 400;
        header.stateLabel.textColor = '#FF3B30';
        header.lastUpdatedTimeLabel.textColor = '#007AFF';
        return new Example(header, null);
      }
      case 'example06':
        return new Example(this.diyHeaderModel(), null);
      case 'example11':
        return new Example(new CYLRefreshNormalHeaderModel(), new CYLRefreshAutoNormalFooterModel());
      case 'example12':
        return new Example(new CYLRefreshNormalHeaderModel(), exampleImagesFooter());
      case 'example13': {
        const footer = exampleImagesFooter();
        footer.refreshingTitleHidden = true;
        return new Example(new CYLRefreshNormalHeaderModel(), footer);
      }
      case 'example14':
        this.more = 'loadLastData';
        return new Example(new CYLRefreshNormalHeaderModel(), new CYLRefreshAutoNormalFooterModel());
      case 'example15': {
        const footer = new CYLRefreshAutoNormalFooterModel();
        footer.automaticallyRefresh = false;
        return new Example(new CYLRefreshNormalHeaderModel(), footer);
      }
      case 'example16': {
        const footer = new CYLRefreshAutoNormalFooterModel();
        footer.setTitle(t('CYLScenarioMJFooterIdle'), CYLRefreshState.Idle);
        footer.setTitle(t('CYLScenarioMJFooterLoading'), CYLRefreshState.Refreshing);
        footer.setTitle(t('CYLScenarioMJFooterNoMore'), CYLRefreshState.NoMoreData);
        footer.stateLabel.fontSize = 17;
        footer.stateLabel.textColor = '#0000FF';
        return new Example(new CYLRefreshNormalHeaderModel(), footer);
      }
      case 'example17':
        this.more = 'loadOnceData';
        return new Example(new CYLRefreshNormalHeaderModel(), new CYLRefreshAutoNormalFooterModel());
      case 'example18': {
        const footer = new CYLRefreshBackNormalFooterModel();
        // A bottom inset (contentEndOffset of the list)… that the footer ignores.
        this.bottomInset = 30;
        footer.ignoredScrollViewContentInsetBottom = 30;
        return new Example(new CYLRefreshNormalHeaderModel(), footer);
      }
      case 'example19': {
        this.more = 'loadLastData';
        const footer = exampleImagesBackFooter();
        footer.automaticallyChangeAlpha = true;
        return new Example(new CYLRefreshNormalHeaderModel(), footer);
      }
      case 'example20': {
        const footer = new CYLRefreshDIYAutoFooter();
        footer.autoTriggerTimes = 2;
        footer.onChange = () => this.followAutoFooter(footer);
        this.followAutoFooter(footer);
        this.diyAutoFooter = true;
        return new Example(new CYLRefreshNormalHeaderModel(), footer);
      }
      case 'example21': {
        const footer = new CYLRefreshDIYBackFooter();
        footer.onChange = () => this.followBackFooter(footer);
        this.followBackFooter(footer);
        this.diyBackFooter = true;
        return new Example(new CYLRefreshNormalHeaderModel(), footer);
      }
      case 'example51': {
        const header = new CYLRefreshAnimationHeaderModel();
        header.setIconAnimationFilePath(animationPath('CYLRefreshArrows.gif'), size(32), CYLRefreshState.Idle);
        const footer = new CYLRefreshAutoAnimationFooterModel();
        footer.setIconAnimationFilePath(animationPath('CYLRefreshRing.gif'), size(28), CYLRefreshState.Refreshing);
        return new Example(header, footer);
      }
      case 'example52': {
        this.more = 'loadLastData';
        const header = new CYLRefreshAnimationHeaderModel();
        header.setIconAnimationFilePath(animationPath('CYLRefreshPullArrow.json'), size(28), CYLRefreshState.Idle);
        header.setIconAnimationFilePath(animationPath('CYLRefreshClockwise.json'), size(28), CYLRefreshState.Pulling);
        header.setIconAnimationFilePath(animationPath('CYLRefreshMaterialSpinner.json'), size(36),
          CYLRefreshState.Refreshing);
        const footer = new CYLRefreshBackAnimationFooterModel();
        footer.setIconAnimationFilePath(animationPath('CYLRefreshLoadMore.json'), size(28), CYLRefreshState.Idle);
        footer.setIconAnimationFilePath(animationPath('CYLRefreshMoreDots.json'), size(40, 24),
          CYLRefreshState.Refreshing);
        return new Example(header, footer);
      }
      case 'example53': {
        const header = new CYLRefreshAnimationHeaderModel();
        header.setIconAnimationFilePath(animationPath('CYLPlaceholderProgress.pag'), size(32), CYLRefreshState.Idle);
        const footer = new CYLRefreshAutoAnimationFooterModel();
        footer.setIconAnimationFilePath(animationPath('CYLPlaceholderProgress.pag'), size(28),
          CYLRefreshState.Refreshing);
        return new Example(header, footer);
      }
      case 'example54': {
        const header = new CYLRefreshAnimationHeaderModel();
        const footer = new CYLRefreshAutoAnimationFooterModel();
        const resting = this.riveAttributes('idle');
        const turning = this.riveAttributes('active');
        header.setIconAnimationAttributes(resting, CYLRefreshState.Idle);
        header.setIconAnimationAttributes(turning, CYLRefreshState.Refreshing);
        footer.setIconAnimationAttributes(turning, CYLRefreshState.Refreshing);
        return new Example(header, footer);
      }
      case 'example55': {
        const header = new CYLRefreshGifHeaderModel();
        header.setImagesForState(idleImages(), CYLRefreshState.Idle);
        header.setImages(refreshingImages(), 0.8, CYLRefreshState.Refreshing);
        const footer = new CYLRefreshAutoGifFooterModel();
        footer.setImagesForState(refreshingImages(), CYLRefreshState.Refreshing);
        return new Example(header, footer);
      }
      case 'example56': {
        const header = new CYLRefreshAnimationHeaderModel();
        header.setIconAnimationFilePath(animationPath('CYLRefreshPullCircle.json'), size(28), CYLRefreshState.Idle);
        header.setIconAnimationFilePath(animationPath('CYLRefreshArrows.gif'), size(30), CYLRefreshState.Pulling);
        header.setIconAnimationFilePath(animationPath('CYLPlaceholderProgress.pag'), size(32),
          CYLRefreshState.Refreshing);
        const footer = new CYLRefreshAutoAnimationFooterModel();
        footer.setIconAnimationFilePath(animationPath('CYLRefreshIcon.riv'), size(30), CYLRefreshState.Refreshing);
        return new Example(header, footer);
      }
      default:
        return new Example(new CYLRefreshNormalHeaderModel(), null);
    }
  }

  /**
   * example54's Rive icon: the "refresh" artboard resting ("idle") or turning ("active"). CYLRefreshIconAttributes
   * has no options (artboard / animation) on HarmonyOS yet, so both states name the same file.
   */
  private riveAttributes(animation: string): CYLRefreshIconAttributes {
    const attributes = new CYLRefreshIconAttributes();
    attributes.filePath = animationPath('CYLRefreshIcon.riv');
    attributes.size = size(32);
    return attributes;
  }

  private diyHeaderModel(): CYLRefreshHeaderModel {
    const header = new CYLRefreshDIYHeader();
    header.onChange = () => this.followHeader(header);
    this.followHeader(header);
    this.diyHeader = true;
    return header;
  }

  private followHeader(header: CYLRefreshDIYHeader): void {
    const look = new DIYLook();
    const state = header.state;
    look.text = t(state === CYLRefreshState.Pulling ? 'CYLScenarioMJDIYRelease' :
      state === CYLRefreshState.Refreshing ? 'CYLScenarioMJDIYLoading' : 'CYLScenarioMJDIYPullDown');
    look.on = state === CYLRefreshState.Pulling || state === CYLRefreshState.Refreshing;
    look.spinning = state === CYLRefreshState.Refreshing;
    look.color = diyColor(header.pullingPercent);
    header.look = look;
    header.cyl_setNeedsLayout();
  }

  private followAutoFooter(footer: CYLRefreshDIYAutoFooter): void {
    const look = new DIYLook();
    const state = footer.state;
    look.text = t(state === CYLRefreshState.Refreshing ? 'CYLScenarioMJDIYLoading' :
      state === CYLRefreshState.NoMoreData ? 'CYLScenarioMJDIYNoMore' : 'CYLScenarioMJDIYPullUp');
    look.on = state === CYLRefreshState.Refreshing;
    look.spinning = state === CYLRefreshState.Refreshing;
    footer.look = look;
    footer.cyl_setNeedsLayout();
  }

  private followBackFooter(footer: CYLRefreshDIYBackFooter): void {
    const look = new DIYLook();
    const state = footer.state;
    look.text = t(state === CYLRefreshState.Pulling ? 'CYLScenarioMJDIYRelease' :
      state === CYLRefreshState.Refreshing ? 'CYLScenarioMJDIYLoading' :
        state === CYLRefreshState.NoMoreData ? 'CYLScenarioMJDIYNoMore' : 'CYLScenarioMJDIYPullUp');
    look.on = state === CYLRefreshState.Pulling || state === CYLRefreshState.Refreshing;
    look.spinning = state === CYLRefreshState.Refreshing;
    look.color = diyColor(footer.pullingPercent);
    footer.look = look;
    footer.cyl_setNeedsLayout();
  }

  // MARK: - Data

  /** New data for a pull down: 5 rows at the top; the list reloads and the header ends 2 s later. */
  private loadNewData(): void {
    for (let i = 0; i < 5; i++) {
      this.data.unshift(this.randomData());
    }
    this.later(CYLRefreshDuration, () => {
      this.rows = this.data.slice();
      const header = this.scrollView.cyl_header;
      if (header !== null) {
        header.endRefreshing();
      }
    });
  }

  private loadFooterData(): void {
    const count = this.more === 'loadMoreData' ? 1 : 5;
    for (let i = 0; i < count; i++) {
      this.data.push(this.randomData());
    }
    const more = this.more;
    this.later(CYLRefreshDuration, () => {
      this.rows = this.data.slice();
      const footer = this.scrollView.cyl_footer;
      if (footer === null) {
        return;
      }
      if (more === 'loadMoreData') {
        footer.endRefreshing();
      } else if (more === 'loadLastData') {
        footer.endRefreshingWithNoMoreData();
      } else {
        // loadOnceData: the footer hides afterwards.
        footer.endRefreshing();
        footer.hidden = true;
      }
    });
  }

  /** example14's "Resume loading": the footer loads one row at a time again. */
  private reset(): void {
    this.more = 'loadMoreData';
    const footer = this.scrollView.cyl_footer;
    if (footer !== null) {
      footer.resetNoMoreData();
    }
  }

  @Builder
  barItems() {
    Row() {
      if (this.method === 'example14') {
        BarButton(t('CYLScenarioMJResumeLoading'), () => this.reset())
      }
    }
    .height('100%')
  }

  build() {
    NavDestination() {
      Column() {
        CYLRefreshContainer({
          scrollView: this.scrollView,
          scroller: this.scroller,
          headerBuilder: this.diyHeader ? wrapBuilder(diyHeaderControl) : null,
          footerBuilder: this.diyBackFooter ? wrapBuilder(diyBackFooterControl) : null
        }) {
          List({ scroller: this.scroller }) {
            ForEach(this.rows, (row: string, index: number) => {
              ListItem() {
                Text(t(index % 2 === 1 ? 'CYLScenarioMJPush' : 'CYLScenarioMJModal') + ' - ' + row)
                  .fontSize(17)
                  .width('100%')
                  .height(44)
                  .padding({ left: 16, right: 16 })
              }
              .stateStyles({ pressed: { .backgroundColor('#D1D1D6') }, normal: { .backgroundColor(Color.White) } })
              .onClick(() => showRefreshTest(index))
            }, (row: string, index: number) => index + '-' + row)
            ListItem() {
              CYLRefreshFooterView({
                scrollView: this.scrollView,
                footerBuilder: this.diyAutoFooter ? wrapBuilder(diyAutoFooterControl) : null
              })
            }
          }
          .contentEndOffset(this.bottomInset)
          .edgeEffect(EdgeEffect.None)
          .width('100%')
          .height('100%')
      }
      }
      .width('100%')
      .height('100%')
      .clip(true)
    }
    .title(this.param.title)
    .menus(this.barItems)
    .backgroundColor(Color.White)
  }
}
