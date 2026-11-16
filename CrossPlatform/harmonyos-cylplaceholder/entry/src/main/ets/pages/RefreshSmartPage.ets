// CYLSmartRefreshDemoViewController: SmartRefreshControl's demo, one grouped list per style (param.value = method).
// - smartDelivery: the Delivery header over 20 test rows, refreshing once on open.
// - Header styles: theme rows ("Default" restores, Orange / Red / Green / Blue switch) + "Test data" (8 rows); the
//   header refreshes on open and ends after 2.5 s. A theme colors the control (colorPrimary / colorAccent) and the
//   navigation bar, and refreshes once; Fly and WaveSwipe open in their own blue.
// - Footer styles (no header): load more after 2.5 s doubles the test rows, 8 → 16 → 32, then "no more data".
// - The Rive styles (smartRive…): CYLRefreshRiveHeaderModel with flutter_easy_refresh's names per file (riveStyle);
//   smartRiveSpaceFooter hosts the Space header in a drawn footer.
import {
  CYLRefreshBackNormalFooterModel,
  CYLRefreshBezierCircleHeaderModel,
  CYLRefreshBezierRadarFooterModel,
  CYLRefreshBezierRadarHeaderModel,
  CYLRefreshComponentModel,
  CYLRefreshContainer,
  CYLRefreshDeliveryFooterModel,
  CYLRefreshDrawnFooterModel,
  CYLRefreshDeliveryHeaderModel,
  CYLRefreshDropBoxHeaderModel,
  CYLRefreshFlyHeaderModel,
  CYLRefreshFooterModel,
  CYLRefreshGameBattleCityHeaderModel,
  CYLRefreshGameHitBlockHeaderModel,
  CYLRefreshHeaderModel,
  CYLRefreshMaterialFooterModel,
  CYLRefreshMaterialHeaderModel,
  CYLRefreshNormalHeaderModel,
  CYLRefreshOriginalHeaderModel,
  CYLRefreshPhoenixFooterModel,
  CYLRefreshPhoenixHeaderModel,
  CYLRefreshRiveHeaderModel,
  CYLRefreshRiveStyle,
  CYLRefreshScrollViewModel,
  CYLRefreshStoreHouseHeaderModel,
  CYLRefreshTaurusFooterModel,
  CYLRefreshTaurusHeaderModel,
  CYLRefreshWaveSwipeHeaderModel
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { RouteParam } from '../common/Routes';
import { SectionHeader, UiColor, PAGE_LIST_END_INSET } from '../common/Ui';

const DURATION: number = 2500;

class SmartRow {
  id: string;
  title: string;
  detail: string;
  /** '' (static), 'default' or a theme index. */
  action: string;

  constructor(id: string, title: string, detail: string = '', action: string = '') {
    this.id = id;
    this.title = title;
    this.detail = detail;
    this.action = action;
  }
}

class SmartSection {
  id: string;
  title: string;
  rows: SmartRow[];

  constructor(id: string, title: string, rows: SmartRow[]) {
    this.id = id;
    this.title = title;
    this.rows = rows;
  }
}

class Theme {
  key: string;
  primary: string;

  constructor(key: string, primary: string) {
    this.key = key;
    this.primary = primary;
  }
}

// UIColor.systemOrange / systemRed / systemGreen / systemBlue (light).
const THEMES: Theme[] = [
  new Theme('CYLScenarioSmartThemeOrange', '#FF9500'),
  new Theme('CYLScenarioSmartThemeRed', '#FF3B30'),
  new Theme('CYLScenarioSmartThemeGreen', '#34C759'),
  new Theme('CYLScenarioSmartThemeBlue', '#007AFF'),
];


/**
 * flutter_easy_refresh's Rive style packages: the file in this example's rawfiles and the names each package's
 * indicator drives (each package's lib/src indicator .dart at dcdbb81).
 */
function riveStyle(method: string): CYLRefreshRiveStyle | null {
  let file: string;
  switch (method) {
    case 'smartRiveBow':
      file = 'Bow';
      break;
    case 'smartRiveBubbles':
      file = 'Bubbles';
      break;
    case 'smartRiveHalloween':
      file = 'Halloween';
      break;
    case 'smartRiveSkating':
      file = 'Skating';
      break;
    case 'smartRiveSpace':
    case 'smartRiveSpaceFooter':
      file = 'Space';
      break;
    case 'smartRiveSquats':
      file = 'Squats';
      break;
    default:
      return null;
  }
  const style = new CYLRefreshRiveStyle('example/animations/CYLScenarioExampleRefresh' + file + '.riv');
  switch (file) {
    case 'Bow':
      style.stateMachineName = 'numberSimulation';
      style.triggerOffset = 200;
      style.fitsWidth = true;
      style.pullInput = 'pull';
      style.pullInputMinimum = 10;
      style.releaseTrigger = 'advance';
      style.finishTrigger = 'advance';
      style.restartTrigger = 'restart';
      break;
    case 'Bubbles':
      style.stateMachineName = 'Motion';
      style.pullInput = 'numDrag';
      style.pullInputStart = 4.0 / 7.0;
      style.pullInputMaximum = 99;
      style.pullInputRefreshingValue = 100;
      style.loadingNumber = 'numLoad';
      break;
    case 'Halloween':
      style.triggerOffset = 200;
      style.pullAnimation = 'Pull';
      style.triggerAnimation = 'Trigger';
      style.loadingAnimation = 'Loading';
      break;
    case 'Skating':
      style.stateMachineName = 'Reload';
      style.minimumHeight = 140;
      style.pullInput = 'pullAmount';
      style.releaseTrigger = 'pullRelease';
      style.finishTrigger = 'loadFinished';
      break;
    case 'Space':
      style.stateMachineName = 'Reload';
      style.pullInput = 'Pull Amount';
      style.loadingBoolean = 'Start';
      break;
    default:
      style.triggerOffset = 190;
      style.fitsWidth = true;
      style.idleAnimation = 'Idle';
      style.loadingAnimation = 'Demo';
      break;
  }
  return style;
}
function makeHeader(method: string): CYLRefreshHeaderModel {
  switch (method) {
    case 'smartDropBox':
      return new CYLRefreshDropBoxHeaderModel();
    case 'smartPhoenix':
      return new CYLRefreshPhoenixHeaderModel();
    case 'smartTaurus':
      return new CYLRefreshTaurusHeaderModel();
    case 'smartBezierRadar':
      return new CYLRefreshBezierRadarHeaderModel();
    case 'smartBezierCircle':
      return new CYLRefreshBezierCircleHeaderModel();
    case 'smartStoreHouse':
      return new CYLRefreshStoreHouseHeaderModel();
    case 'smartWaveSwipe':
      return new CYLRefreshWaveSwipeHeaderModel();
    case 'smartOriginal':
      return new CYLRefreshOriginalHeaderModel();
    case 'smartMaterial':
      return new CYLRefreshMaterialHeaderModel();
    case 'smartGameHitBlock':
      return new CYLRefreshGameHitBlockHeaderModel();
    case 'smartGameBattleCity':
      return new CYLRefreshGameBattleCityHeaderModel();
    case 'smartFly':
      return new CYLRefreshFlyHeaderModel();
    default: {
      // The Rive styles (iOS falls back to the normal header when the file cannot be read), and smartClassics.
      const style = method.startsWith('smartRive') ? riveStyle(method) : null;
      return style !== null ? new CYLRefreshRiveHeaderModel(style) : new CYLRefreshNormalHeaderModel();
    }
  }
}

function makeFooter(method: string): CYLRefreshFooterModel | null {
  switch (method) {
    case 'smartClassicsFooter':
      return new CYLRefreshBackNormalFooterModel();
    case 'smartBezierRadarFooter':
      return new CYLRefreshBezierRadarFooterModel();
    case 'smartMaterialFooter':
      return new CYLRefreshMaterialFooterModel();
    case 'smartDeliveryFooter':
      return new CYLRefreshDeliveryFooterModel();
    case 'smartPhoenixFooter':
      return new CYLRefreshPhoenixFooterModel();
    case 'smartTaurusFooter':
      return new CYLRefreshTaurusFooterModel();
    case 'smartRiveSpaceFooter': {
      const style = riveStyle(method);
      return style !== null ? CYLRefreshDrawnFooterModel.initWithStyle(new CYLRefreshRiveHeaderModel(style)) : null;
    }
    default:
      return null;
  }
}

function testRows(count: number): SmartRow[] {
  const rows: SmartRow[] = [];
  for (let i = 1; i <= count; i++) {
    rows.push(new SmartRow('r' + i, t('CYLScenarioSmartTestDataRow', i)));
  }
  return rows;
}

@Component
export struct RefreshSmartPage {
  param: RouteParam = new RouteParam();
  @State sections: SmartSection[] = [];
  /** The navigation bar's color while a theme is applied, or '' for the saved appearance. */
  @State barColor: string = '';
  /** The title's color while a theme is applied (iOS titleTextAttributes from the accent), or '' for the default. */
  @State titleColor: string = '';
  private method: string = 'smartClassics';
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private header: CYLRefreshHeaderModel | null = null;
  private footer: CYLRefreshFooterModel | null = null;
  private defaultAccent: string | null = null;
  private defaultPrimary: string | null = null;
  private timers: number[] = [];

  aboutToAppear(): void {
    this.method = this.param.value.length > 0 ? this.param.value : 'smartClassics';
    this.scrollView.dataCountProvider = () => {
      let n = 0;
      this.sections.forEach((s: SmartSection) => n += s.rows.length);
      return n;
    };
    if (this.method === 'smartDelivery') {
      this.sections = [new SmartSection('s0', '', testRows(20))];
      const delivery = new CYLRefreshDeliveryHeaderModel();
      delivery.refreshingBlock = () => this.onRefresh();
      this.header = delivery;
      this.scrollView.cyl_header = delivery;
      delivery.beginRefreshing();
      return;
    }
    this.sections = [new SmartSection('s0', '', this.themeRows()),
      new SmartSection('s1', t('CYLScenarioSmartTestData'), testRows(8))];
    const loadMore = makeFooter(this.method);
    if (loadMore !== null) {
      loadMore.refreshingBlock = () => this.onLoadMore();
      this.scrollView.cyl_footer = loadMore;
      this.footer = loadMore;
      this.defaultAccent = loadMore.colorAccent;
      this.defaultPrimary = loadMore.colorPrimary;
      return;
    }
    const control = makeHeader(this.method);
    control.refreshingBlock = () => this.onRefresh();
    this.scrollView.cyl_header = control;
    this.header = control;
    this.defaultAccent = control.colorAccent;
    this.defaultPrimary = control.colorPrimary;
    control.beginRefreshing();
    // viewWillAppear: UIFlyController and UIWaveSwipeController open in the style's own blue.
    if (this.method === 'smartFly') {
      this.applyTheme('rgb(51, 153, 255)', '#FFFFFF');
    } else if (this.method === 'smartWaveSwipe') {
      this.defaultPrimary = 'transparent';
      this.applyTheme('#007AFF', '#FFFFFF');
    }
  }

  aboutToDisappear(): void {
    this.timers.forEach((id: number) => clearTimeout(id));
  }

  private later(ms: number, action: () => void): void {
    this.timers.push(setTimeout(action, ms));
  }

  private themeRows(): SmartRow[] {
    const restore = t('CYLScenarioSmartTapToRestore');
    const change = t('CYLScenarioSmartTapToSwitch');
    const rows: SmartRow[] = [new SmartRow('default', t('CYLScenarioSmartThemeDefault'), restore, 'default')];
    THEMES.forEach((theme: Theme, i: number) => rows.push(new SmartRow('theme' + i, t(theme.key), change, String(i))));
    return rows;
  }

  /** applyTheme(primary:accent:): colors the control and the navigation bar, and refreshes once. */
  private applyTheme(primary: string | null, accent: string | null): void {
    const control: CYLRefreshComponentModel | null = this.header !== null ? this.header : this.footer;
    if (control !== null) {
      control.colorAccent = accent;
      control.colorPrimary = primary;
      control.cyl_setNeedsLayout();
    }
    if (this.header !== null) {
      this.header.beginRefreshing();
    }
    const isDefault = primary === this.defaultPrimary && accent === this.defaultAccent;
    if (isDefault || primary === null || primary === 'transparent') {
      this.barColor = '';
      this.titleColor = '';
      return;
    }
    this.barColor = primary;
    this.titleColor = accent !== null && accent !== 'transparent' ? accent : '';
  }

  /** The bar title, in the theme's accent color while a theme is applied. */
  @Builder
  titleView() {
    Text(this.param.title)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.titleColor.length > 0 ? this.titleColor : UiColor.label)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .height('100%')
  }

  private onRow(row: SmartRow): void {
    if (row.action === 'default') {
      this.applyTheme(this.defaultPrimary, this.defaultAccent);
    } else if (row.action.length > 0) {
      this.applyTheme(THEMES[Number(row.action)].primary, '#FFFFFF');
    }
  }

  /** UIDemoHeaderController.onRefresh: ends 2.5 seconds later. */
  private onRefresh(): void {
    this.later(DURATION, () => {
      if (this.header !== null) {
        this.header.endRefreshing();
      }
    });
  }

  /** UIDemoFooterController.onLoadMore: doubles the test rows, then reports no more data past 16 rows. */
  private onLoadMore(): void {
    this.later(DURATION, () => {
      const last = this.sections.length - 1;
      const count = this.sections[last].rows.length * 2;
      const sections = this.sections.slice();
      sections[last] = new SmartSection(sections[last].id, sections[last].title, testRows(count));
      this.sections = sections;
      if (this.footer === null) {
        return;
      }
      if (count <= 16) {
        this.footer.endRefreshing();
      } else {
        this.footer.endRefreshingWithNoMoreData();
      }
    });
  }

  build() {
    NavDestination() {
      CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
        List({ scroller: this.scroller }) {
          ForEach(this.sections, (section: SmartSection) => {
            ListItem() {
              Column() {
                if (section.title.length > 0) {
                  SectionHeader(section.title)
                } else {
                  Column().height(20)
                }
                Column() {
                  ForEach(section.rows, (row: SmartRow, r: number) => {
                    if (r > 0) {
                      Divider().strokeWidth(0.5).color(UiColor.separator).margin({ left: 16 })
                    }
                    Row() {
                      Text(row.title).fontSize(17).fontColor(UiColor.label).layoutWeight(1)
                      if (row.detail.length > 0) {
                        Text(row.detail).fontSize(17).fontColor(UiColor.gray)
                      }
                    }
                    .width('100%')
                    .height(44)
                    .padding({ left: 16, right: 16 })
                    .backgroundColor(UiColor.cell)
                    .stateStyles({
                      pressed: { .backgroundColor(UiColor.pressed) },
                      normal: { .backgroundColor(UiColor.cell) }
                    })
                    // A row reads as one element (its title and detail) and acts as a button.
                    .accessibilityGroup(true)
                    .accessibilityRole(AccessibilityRoleType.BUTTON)
                    .onClick(() => this.onRow(row))
                  }, (row: SmartRow) => row.id)
                }
              }
            }
          }, (section: SmartSection) => section.id + '-' + section.rows.length)
        }
        .contentEndOffset(PAGE_LIST_END_INSET)
        .edgeEffect(EdgeEffect.None)
        .width('100%')
        .height('100%')
      }
    }
    .title(this.titleView,
      { backgroundColor: this.barColor.length > 0 ? this.barColor : UiColor.groupedBackground })
    .backgroundColor(UiColor.groupedBackground)
  }
}
