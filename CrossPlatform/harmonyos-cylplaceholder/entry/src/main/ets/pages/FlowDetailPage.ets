// CYLFlowDetailViewController: one list, one placeholder, attached the way the flow (param.value) shows:
// - switchStates: a segmented control switches between empty, failed, offline and data (block API, issue #3)
// - keepTableHeader: the placeholder starts below a 56 pt search bar (delegate API frame, issue #17)
// - keepSectionHeaders: the placeholder starts below the last section header (delegate API frame, issue #16)
// - refreshControls: pull to refresh and load more stay usable above the placeholder (block API, issue #8)
// - scrollable: the empty list can still be pulled (enableScrollWhenPlaceHolderViewShowing)
// Every placeholder's Retry selects data. The delegate-API flows stop scrolling while the placeholder shows.
import {
  CYLPlaceholderAction,
  CYLPlaceholderActionHandler,
  CYLPlaceholderActions,
  CYLPlaceholderScenario,
  CYLPlaceholderStackView,
  CYLPlaceholderStackViewModel,
  CYLRefreshAutoAnimationFooterModel,
  CYLRefreshContainer,
  CYLRefreshFooterView,
  CYLRefreshIconSize,
  CYLRefreshNormalHeaderModel,
  CYLRefreshScrollViewModel,
  CYLRefreshState
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { RouteParam } from '../common/Routes';
import { UiColor, NavTitle } from '../common/Ui';

const STATES: string[] = ['empty', 'failed', 'offline', 'data'];
const STATE_KEYS: string[] = ['CYLScenarioStateEmpty', 'CYLScenarioStateFailed', 'CYLScenarioStateOffline',
  'CYLScenarioStateData'];

function titleKeyOf(flow: string): string {
  switch (flow) {
    case 'keepTableHeader':
      return 'CYLScenarioTitleKeepTableHeader';
    case 'keepSectionHeaders':
      return 'CYLScenarioTitleKeepSectionHeaders';
    case 'refreshControls':
      return 'CYLScenarioTitleRefreshControls';
    case 'scrollable':
      return 'CYLScenarioTitleScrollable';
    default:
      return 'CYLScenarioTitleSwitchStates';
  }
}

/** The scenario shown while the list is empty. */
function emptyScenarioOf(flow: string): CYLPlaceholderScenario {
  switch (flow) {
    case 'keepTableHeader':
      return CYLPlaceholderScenario.NoSearchResults;
    case 'keepSectionHeaders':
      return CYLPlaceholderScenario.NoMessages;
    case 'refreshControls':
      return CYLPlaceholderScenario.NoNotifications;
    case 'scrollable':
      return CYLPlaceholderScenario.TextOnly;
    default:
      return CYLPlaceholderScenario.NoContent;
  }
}

@Component
export struct FlowDetailPage {
  param: RouteParam = new RouteParam();
  @State flow: string = 'switchStates';
  @State stateIndex: number = 0;
  @State rows: string[] = [];
  @State placeholder: CYLPlaceholderStackViewModel = new CYLPlaceholderStackViewModel();
  @State listHeight: number = 0;
  @State headerHeight: number = 0;
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private header: CYLRefreshNormalHeaderModel | null = null;
  private footer: CYLRefreshAutoAnimationFooterModel | null = null;
  private timers: number[] = [];

  aboutToAppear(): void {
    const known = ['switchStates', 'keepTableHeader', 'keepSectionHeaders', 'refreshControls', 'scrollable'];
    this.flow = known.includes(this.param.value) ? this.param.value : 'switchStates';
    if (this.hasHeader()) {
      // CYLRefreshNormalHeader: after 1 s toggles 0 / 12 rows, resets no-more-data, then ends.
      const header = CYLRefreshNormalHeaderModel.headerWithRefreshingBlock(() => {
        this.timers.push(setTimeout(() => {
          this.applyRows(this.rows.length > 0 ? 0 : 12, STATES[this.stateIndex]);
          if (this.footer !== null) {
            this.footer.resetNoMoreData();
          }
          header.endRefreshing();
        }, 1000));
      }) as CYLRefreshNormalHeaderModel;
      this.header = header;
      this.scrollView.cyl_header = header;
    }
    if (this.flow === 'refreshControls') {
      // CYLRefreshAutoAnimationFooter: the 28 x 28 CYLRefreshActivity.gif while refreshing; after 1 s no more data.
      const footer = CYLRefreshAutoAnimationFooterModel.footerWithRefreshingBlock(() => {
        this.timers.push(setTimeout(() => footer.endRefreshingWithNoMoreData(), 1000));
      });
      footer.setIconAnimationFilePath('cylplaceholder/animations/CYLRefreshActivity.gif', new CYLRefreshIconSize(28, 28),
        CYLRefreshState.Refreshing);
      this.footer = footer;
      this.scrollView.cyl_footer = footer;
    }
    this.scrollView.dataCountProvider = () => this.rows.length;
    this.applyRows(0, 'empty');
  }

  aboutToDisappear(): void {
    this.timers.forEach((id: number) => clearTimeout(id));
  }

  private hasHeader(): boolean {
    return this.flow === 'refreshControls' || this.flow === 'scrollable';
  }

  /** Whether the delegate API stops scrolling while the placeholder shows. */
  private stopsScrolling(): boolean {
    return this.rows.length === 0 && (this.flow === 'keepTableHeader' || this.flow === 'keepSectionHeaders');
  }

  private applyRows(count: number, state: string): void {
    let scenario = emptyScenarioOf(this.flow);
    if (state === 'failed') {
      scenario = CYLPlaceholderScenario.RetryButton;
    } else if (state === 'offline') {
      scenario = CYLPlaceholderScenario.NetworkUnavailable;
    }
    const rows: string[] = [];
    for (let i = 1; i <= count; i++) {
      rows.push(t('CYLScenarioFormatItem', i));
    }
    this.stateIndex = STATES.indexOf(state);
    this.rows = rows;
    const actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> = new Map();
    actions.set(CYLPlaceholderActions.Retry,
      (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) => this.select('data'));
    this.placeholder = CYLPlaceholderStackViewModel.initWithScenario(scenario, actions);
    if (this.footer !== null) {
      this.footer.hidden = count === 0;
    }
  }

  /** select(_:): the state, its rows (12 for data) and the placeholder it shows when empty. */
  private select(state: string): void {
    this.applyRows(state === 'data' ? 12 : 0, state);
  }

  @Builder
  segmented() {
    Row() {
      ForEach(STATE_KEYS, (key: string, index: number) => {
        Text(t(key))
          .fontSize(13)
          .fontWeight(index === this.stateIndex ? FontWeight.Medium : FontWeight.Normal)
          .textAlign(TextAlign.Center)
          // One line in the 28 vp segment: long translations shrink instead of being clipped.
          .maxLines(1)
          .minFontSize(9)
          .maxFontSize(13)
          .layoutWeight(1)
          .height(28)
          .borderRadius(7)
          .backgroundColor(index === this.stateIndex ? UiColor.segmentSelected : Color.Transparent)
          .accessibilityText(t(key))
          .onClick(() => this.select(STATES[index]))
      }, (key: string) => key)
    }
    .id('stateSwitcher')
    .padding(2)
    .borderRadius(9)
    .backgroundColor(UiColor.segmentBackground)
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  @Builder
  row(title: string) {
    Row() {
      Text('▤').fontSize(18).fontColor(UiColor.teal).width(26).margin({ right: 12 })
      Text(title).fontSize(17)
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .backgroundColor(UiColor.cell)
  }

  /** keepTableHeader: the 56 pt search bar of the table header. */
  @Builder
  searchBar() {
    Row() {
      Search({ placeholder: t('CYLScenarioSearchPlaceholder') }).height(36)
    }
    .height(56)
    .padding({ left: 8, right: 8 })
    .width('100%')
  }

  @Builder
  sectionHeader(title: string) {
    Text(title.toUpperCase())
      .fontSize(13)
      .fontColor(UiColor.sectionHeader)
      .width('100%')
      .padding({ left: 32, right: 32, top: 18, bottom: 6 })
  }

  @Builder
  listContent() {
    List({ scroller: this.scroller }) {
      if (this.flow === 'keepTableHeader') {
        ListItem() {
          this.searchBar()
        }
      }
      if (this.flow === 'keepSectionHeaders') {
        ForEach([t('CYLScenarioSectionPinned'), t('CYLScenarioSectionAll')], (title: string, s: number) => {
          ListItem() {
            Column() {
              this.sectionHeader(title)
              if (this.rows.length > 0) {
                Column() {
                  ForEach(this.rows, (row: string, r: number) => {
                    if (r > 0) {
                      Divider().strokeWidth(0.5).color(UiColor.separator).margin({ left: 54 })
                    }
                    this.row(row)
                  }, (row: string) => s + row)
                }
                .borderRadius(10)
                .clip(true)
                .margin({ left: 16, right: 16 })
              }
            }
          }
        }, (title: string, s: number) => s + title)
      } else {
        ForEach(this.rows, (row: string) => {
          ListItem() {
            this.row(row)
          }
        }, (row: string) => row)
      }
      if (this.rows.length === 0) {
        // The placeholder frame starts below the header (frameForPlaceHolderViewInTableView:).
        ListItem() {
          CYLPlaceholderStackView({ model: this.placeholder })
        }
        .height(Math.max(0, this.listHeight - this.headerHeight))
      }
      if (this.footer !== null) {
        ListItem() {
          CYLRefreshFooterView({ scrollView: this.scrollView })
        }
      }
    }
    .divider(this.flow === 'keepSectionHeaders' ? null :
      { strokeWidth: 0.5, color: UiColor.separator, startMargin: 54 })
    .edgeEffect(this.hasHeader() ? EdgeEffect.None : EdgeEffect.Spring)
    .enableScrollInteraction(!this.stopsScrolling())
    .width('100%')
    .height('100%')
  }


  @Builder
  navTitle() {
    NavTitle(t(titleKeyOf(this.flow)))
  }

  build() {
    NavDestination() {
      Column() {
        if (this.flow === 'switchStates') {
          this.segmented()
        }
        Column() {
          if (this.hasHeader()) {
            CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
              this.listContent()
            }
          } else {
            this.listContent()
          }
        }
        .layoutWeight(1)
        .width('100%')
        .onAreaChange((o: Area, n: Area) => {
          this.listHeight = Number(n.height);
          this.headerHeight = this.flow === 'keepTableHeader' ? 56 : (this.flow === 'keepSectionHeaders' ? 84 : 0);
        })
      }
      .width('100%')
      .height('100%')
    }
    .title(this.navTitle)
    .backgroundColor(this.flow === 'keepSectionHeaders' ? UiColor.groupedBackground : UiColor.background)
  }
}
