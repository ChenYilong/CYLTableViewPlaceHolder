// CYLRefreshExampleViewController: the menu of CYLRefresh demos (8 sections, 65 rows, from the mini program's
// pages/refresh/menu.js); each subtitle names the iOS view controller and method. The list itself has a normal
// header and a back footer, each ending after 2 s.
// A row opens its demo page (routeFor): the table, collection, web, i18n, SmartRefresh and easy_refresh pages.
import {
  CYLRefreshBackNormalFooterModel,
  CYLRefreshContainer,
  CYLRefreshFooterView,
  CYLRefreshNormalHeaderModel,
  CYLRefreshScrollViewModel
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { Route, RouteParam, push } from '../common/Routes';
import { preloadRefreshFrames } from '../common/RefreshFrames';
import { LargeTitle, SectionHeader, TableCell, TableRow, UiColor, TAB_LIST_END_INSET } from '../common/Ui';

class MenuRow {
  key: string;
  vc: string;
  method: string;

  constructor(key: string, vc: string, method: string) {
    this.key = key;
    this.vc = vc;
    this.method = method;
  }
}

class MenuSection {
  key: string;
  rows: MenuRow[];

  constructor(key: string, rows: MenuRow[]) {
    this.key = key;
    this.rows = rows;
  }
}

const T = 'CYLRefreshTableViewController';
const table = (key: string, method: string) => new MenuRow(key, T, method);
const smart = (suffix: string, method: string) =>
new MenuRow('CYLScenarioSmart' + suffix, 'CYLSmartRefreshDemoViewController', method);
const easy = (suffix: string, method: string) =>
new MenuRow('CYLScenarioEasy' + suffix, 'CYLEasyRefreshDemoViewController', method);

const SECTIONS: MenuSection[] = [
  new MenuSection('CYLScenarioMJSectionHeader', [
    table('CYLScenarioMJDefault', 'example01'), table('CYLScenarioMJAnimatedImages', 'example02'),
    table('CYLScenarioMJHideTime', 'example03'), table('CYLScenarioMJHideStateAndTime', 'example04'),
    table('CYLScenarioMJCustomText', 'example05'), table('CYLScenarioMJCustomControl', 'example06'),
  ]),
  new MenuSection('CYLScenarioMJSectionFooter', [
    table('CYLScenarioMJDefault', 'example11'), table('CYLScenarioMJAnimatedImages', 'example12'),
    table('CYLScenarioMJHideRefreshingText', 'example13'), table('CYLScenarioMJAllLoaded', 'example14'),
    table('CYLScenarioMJNoAutoLoading', 'example15'), table('CYLScenarioMJCustomText', 'example16'),
    table('CYLScenarioMJHideAfterLoading', 'example17'), table('CYLScenarioMJAutoBack01', 'example18'),
    table('CYLScenarioMJAutoBack02', 'example19'), table('CYLScenarioMJCustomAutoControl', 'example20'),
    table('CYLScenarioMJCustomBackControl', 'example21'),
  ]),
  new MenuSection('CYLScenarioMJSectionCollection', [
    new MenuRow('CYLScenarioMJPullUpAndDown', 'CYLRefreshCollectionViewController', 'example31'),
    new MenuRow('CYLScenarioMJPinHeader', 'CYLRefreshPinHeaderCollectionViewController', 'example31'),
    new MenuRow('CYLScenarioMJPullLeft', 'CYLRefreshHorizontalCollectionViewController', 'example42'),
  ]),
  new MenuSection('CYLScenarioMJSectionWeb', [
    new MenuRow('CYLScenarioMJWebPullOld', 'CYLRefreshWKWebViewController', 'example40'),
    new MenuRow('CYLScenarioMJWebPull', 'CYLRefreshWKWebViewController', 'example41'),
  ]),
  new MenuSection('CYLScenarioMJSectionI18n', [
    new MenuRow('CYLScenarioMJLanguages', 'CYLRefreshI18NExampleViewController', 'i18n'),
  ]),
  new MenuSection('CYLScenarioMJSectionAnimations', [
    table('CYLScenarioMJGifIcon', 'example51'), table('CYLScenarioMJLottieStates', 'example52'),
    table('CYLScenarioMJPagRing', 'example53'), table('CYLScenarioMJRiveIcon', 'example54'), table('CYLScenarioMJSVGAIcon', 'example57'),
    table('CYLScenarioMJGifFrames', 'example55'), table('CYLScenarioMJMixedEngines', 'example56'),
    new MenuRow('CYLScenarioMJCollectionIcons', 'CYLRefreshCollectionViewController', 'example32'),
  ]),
  new MenuSection('CYLScenarioSmartSection', [
    smart('Delivery', 'smartDelivery'), smart('Classics', 'smartClassics'), smart('DropBox', 'smartDropBox'),
    smart('Phoenix', 'smartPhoenix'), smart('Taurus', 'smartTaurus'), smart('BezierRadar', 'smartBezierRadar'),
    smart('BezierCircle', 'smartBezierCircle'), smart('StoreHouse', 'smartStoreHouse'),
    smart('WaveSwipe', 'smartWaveSwipe'), smart('Original', 'smartOriginal'), smart('Material', 'smartMaterial'),
    smart('GameHitBlock', 'smartGameHitBlock'), smart('GameBattleCity', 'smartGameBattleCity'),
    smart('Fly', 'smartFly'), smart('ClassicsFooter', 'smartClassicsFooter'),
    smart('BezierRadarFooter', 'smartBezierRadarFooter'), smart('MaterialFooter', 'smartMaterialFooter'),
    smart('DeliveryFooter', 'smartDeliveryFooter'), smart('PhoenixFooter', 'smartPhoenixFooter'),
    smart('TaurusFooter', 'smartTaurusFooter'), smart('RiveBow', 'smartRiveBow'),
    smart('RiveBubbles', 'smartRiveBubbles'), smart('RiveHalloween', 'smartRiveHalloween'),
    smart('RiveSkating', 'smartRiveSkating'), smart('RiveSpace', 'smartRiveSpace'),
    smart('RiveSquats', 'smartRiveSquats'), smart('RiveSpaceFooter', 'smartRiveSpaceFooter'),
  ]),
  new MenuSection('CYLScenarioEasySection', [
    easy('Cupertino', 'easyCupertino'), easy('Secondary', 'easySecondary'), easy('TriggerMode', 'easyTriggerMode'),
    easy('RefreshOnStart', 'easyRefreshOnStart'), easy('Paging', 'easyPaging'), easy('Listener', 'easyListener'),
    easy('Chat', 'easyChat'), easy('UserProfile', 'easyUserProfile'),
  ]),
];

/** The page of a row (CYLRefreshExample's view controller). */
function routeFor(row: MenuRow): string {
  switch (row.vc) {
    case 'CYLRefreshCollectionViewController':
    case 'CYLRefreshPinHeaderCollectionViewController':
    case 'CYLRefreshHorizontalCollectionViewController':
      return Route.RefreshCollection;
    case 'CYLRefreshWKWebViewController':
      return Route.RefreshWeb;
    case 'CYLRefreshI18NExampleViewController':
      return Route.RefreshI18n;
    case 'CYLSmartRefreshDemoViewController':
      return Route.RefreshSmart;
    case 'CYLEasyRefreshDemoViewController':
      return Route.RefreshEasy;
    default:
      return Route.RefreshTable;
  }
}

/** The route value: the method, with the view controller first for the collection pages ("vc|method"). */
function routeValue(row: MenuRow): string {
  return routeFor(row) === Route.RefreshCollection ? row.vc + '|' + row.method : row.method;
}

@Component
export struct RefreshTab {
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private timer: number = -1;

  aboutToAppear(): void {
    preloadRefreshFrames(this.getUIContext().getHostContext() as Context);
    const header = new CYLRefreshNormalHeaderModel();
    header.automaticallyChangeAlpha = true;
    const footer = new CYLRefreshBackNormalFooterModel();
    header.refreshingBlock = () => {
      this.timer = setTimeout(() => header.endRefreshing(), 2000);
    };
    footer.refreshingBlock = () => {
      this.timer = setTimeout(() => footer.endRefreshing(), 2000);
    };
    this.scrollView.cyl_header = header;
    this.scrollView.cyl_footer = footer;
    this.scrollView.dataCountProvider = () => 65;
  }

  aboutToDisappear(): void {
    clearTimeout(this.timer);
  }

  build() {
    Column() {
      LargeTitle(t('CYLScenarioTabRefresh'))
      Column() {
      CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
        List({ scroller: this.scroller }) {
          ForEach(SECTIONS, (section: MenuSection, s: number) => {
            ListItem() {
              Column() {
                SectionHeader(t(section.key))
                Column() {
                  ForEach(section.rows, (row: MenuRow, r: number) => {
                    if (r > 0) {
                      Divider().strokeWidth(0.5).color(UiColor.separator).margin({ left: 16 })
                    }
                    TableCell(new TableRow(row.vc + row.method, t(row.key), row.vc + ' - ' + row.method),
                      () => push(routeFor(row), RouteParam.of(routeValue(row), t(row.key))))
                  }, (row: MenuRow, r: number) => s + '-' + r)
                }
                .borderRadius(10)
                .clip(true)
                .margin({ left: 16, right: 16 })
              }
            }
          }, (section: MenuSection, s: number) => 'section-' + s)
          ListItem() {
            CYLRefreshFooterView({ scrollView: this.scrollView })
          }
        }
        .contentEndOffset(TAB_LIST_END_INSET)
        .edgeEffect(EdgeEffect.None)
        .width('100%')
        .height('100%')
      }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiColor.groupedBackground)
  }
}
