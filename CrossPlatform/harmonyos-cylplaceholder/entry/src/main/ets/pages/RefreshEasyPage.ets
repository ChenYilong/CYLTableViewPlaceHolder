// CYLEasyRefreshDemoViewController: the flutter_easy_refresh samples (example/lib/page), one per method
// (param.value): easyCupertino, easySecondary, easyTriggerMode, easyRefreshOnStart, easyPaging, easyScrollMode, easyListener,
// easyChat, easyUserProfile, on CYLRefresh's Cupertino controls, second floor, trigger modes, start header, paging,
// plain listener header and Behind scroll mode.
import {
  CYLRefreshBackNormalFooterModel,
  CYLRefreshContainer,
  CYLRefreshCupertinoFooterModel,
  CYLRefreshCupertinoHeaderModel,
  CYLRefreshFooterModel,
  CYLRefreshFooterView,
  CYLRefreshHeaderModel,
  CYLRefreshNormalHeaderModel,
  CYLRefreshNotFound,
  CYLRefreshPaging,
  CYLRefreshPagingCompletion,
  CYLRefreshScrollMode,
  CYLRefreshScrollViewModel,
  CYLRefreshTriggerMode
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { RouteParam } from '../common/Routes';
import { UiColor, PAGE_LIST_END_INSET, NavTitle } from '../common/Ui';

/** The header whose second floor is on screen (the floor's close button closes it). */
let floorHeader: CYLRefreshHeaderModel | null = null;

/** secondary_page.dart's second floor: a systemIndigo view, a title and a button that closes it. */
@Builder
function secondFloor() {
  Column({ space: 16 }) {
    Text(t('CYLScenarioEasySecondFloor'))
      .fontSize(28)
      .fontColor(Color.White)
    Text(t('CYLScenarioEasyCloseSecondFloor'))
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .fontSize(17)
      .fontColor(Color.White)
      .padding(8)
      .stateStyles({ pressed: { .opacity(0.5) }, normal: { .opacity(1) } })
      .onClick(() => {
        if (floorHeader !== null) {
          floorHeader.closeSecondary();
        }
      })
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .backgroundColor('#5856D6')
}

/** The scroll modes the "Scroll mode" page offers, in the order of the enum. */
const SCROLL_MODES: CYLRefreshScrollMode[] = [
  CYLRefreshScrollMode.Move, CYLRefreshScrollMode.Stretch, CYLRefreshScrollMode.Front, CYLRefreshScrollMode.Behind
];

/** The string keys of the scroll mode names, indexed by the enum value. */
const SCROLL_MODE_NAMES: string[] = [
  'CYLScenarioEasyScrollMove', 'CYLScenarioEasyScrollStretch', 'CYLScenarioEasyScrollFront', 'CYLScenarioEasyScrollBehind'
];

class EasyRow {
  id: string;
  text: string;

  constructor(id: string, text: string) {
    this.id = id;
    this.text = text;
  }
}

@Component
export struct RefreshEasyPage {
  param: RouteParam = new RouteParam();
  @State rows: EasyRow[] = [];
  @State progress: number = 0;
  @State floorShown: boolean = false;
  private method: string = 'easyUserProfile';
  private count: number = 10;
  private refreshCount: number = 0;
  private loadCount: number = 0;
  private header: CYLRefreshHeaderModel | null = null;
  private footer: CYLRefreshFooterModel | null = null;
  private paging: CYLRefreshPaging | null = null;
  private earliestMessage: number = 0;
  private firstVisible: number = 0;
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private timers: number[] = [];
  private onScroll: () => void = () => {
    // scrollViewDidScroll: the listener header's progress bar shows min(pullingPercent, 1).
    if (this.method === 'easyListener' && this.header !== null) {
      const p = Math.round(Math.min(this.header.pullingPercent, 1) * 100);
      if (p !== this.progress) {
        this.progress = p;
      }
    }
  };

  aboutToAppear(): void {
    this.method = this.param.value.length > 0 ? this.param.value : 'easyUserProfile';
    this.scrollView.dataCountProvider = () => this.rows.length;
    this.scrollView.addChangeListener(this.onScroll);
    switch (this.method) {
      case 'easyCupertino':
        this.setUpCupertino();
        break;
      case 'easySecondary':
        this.setUpSecondary();
        break;
      case 'easyTriggerMode':
        this.setUpTriggerMode();
        break;
      case 'easyRefreshOnStart':
        this.setUpRefreshOnStart();
        break;
      case 'easyPaging':
        this.setUpPaging();
        break;
      case 'easyScrollMode':
        this.setUpScrollMode();
        break;
      case 'easyListener':
        this.setUpListener();
        break;
      case 'easyChat':
        this.setUpChat();
        break;
      default:
        this.setUpUserProfile();
        break;
    }
  }

  aboutToDisappear(): void {
    this.timers.forEach((id: number) => clearTimeout(id));
    this.scrollView.removeChangeListener(this.onScroll);
    if (floorHeader === this.header) {
      floorHeader = null;
    }
  }

  private later(ms: number, action: () => void): void {
    this.timers.push(setTimeout(action, ms));
  }

  private attach(header: CYLRefreshHeaderModel, footer: CYLRefreshFooterModel | null): void {
    this.header = header;
    this.footer = footer;
    this.scrollView.cyl_header = header;
    this.scrollView.cyl_footer = footer;
  }

  private backFooter(load: () => void): CYLRefreshBackNormalFooterModel {
    const footer = new CYLRefreshBackNormalFooterModel();
    footer.refreshingBlock = load;
    return footer;
  }

  // MARK: - Pages

  private setUpCupertino(): void {
    const header = new CYLRefreshCupertinoHeaderModel();
    header.refreshingBlock = () => this.refreshCounted();
    const footer = new CYLRefreshCupertinoFooterModel();
    footer.refreshingBlock = () => this.loadCounted();
    this.attach(header, footer);
    this.reloadCounted();
  }

  private setUpSecondary(): void {
    const normal = new CYLRefreshNormalHeaderModel();
    normal.refreshingBlock = () => this.refreshCounted();
    normal.secondaryTriggerOffset = 120;
    // The floor itself is drawn by secondFloor (the container's secondaryHeaderBuilder).
    normal.secondaryView = new Object();
    floorHeader = normal;
    this.floorShown = true;
    this.attach(normal, this.backFooter(() => this.loadCounted()));
    this.reloadCounted();
  }

  private setUpTriggerMode(): void {
    const header = new CYLRefreshNormalHeaderModel();
    header.refreshingBlock = () => this.refreshTriggerMode();
    this.attach(header, this.backFooter(() => this.loadTriggerMode()));
    this.count = 30;
    this.reloadTriggerMode();
  }

  /** Scroll modes: the four CYLRefreshScrollMode values on one list; a tap on a mode row switches the header and the footer. */
  private setUpScrollMode(): void {
    const header = new CYLRefreshNormalHeaderModel();
    header.refreshingBlock = () => this.later(1500, () => header.endRefreshing());
    const footer = this.backFooter(() => this.later(1500, () => this.footer?.endRefreshing()));
    this.attach(header, footer);
    this.count = 30;
    this.reloadScrollMode();
  }

  private reloadScrollMode(): void {
    const current = this.header !== null ? this.header.scrollMode : CYLRefreshScrollMode.Move;
    const top: EasyRow[] = SCROLL_MODES.map((mode: CYLRefreshScrollMode) => {
      const name = t(SCROLL_MODE_NAMES[mode]);
      return new EasyRow('scrollMode' + mode, mode === current ? t('CYLScenarioEasyScrollSelected', name) : name);
    });
    this.rows = top.concat(this.testRows(this.count));
  }

  private setUpRefreshOnStart(): void {
    const header = new CYLRefreshNormalHeaderModel();
    header.refreshingBlock = () => this.refreshCounted();
    this.attach(header, this.backFooter(() => this.loadByTen()));
    this.count = 0;
    this.reloadCounted();
    this.scrollView.cyl_beginRefreshingWithStartHeader(new CYLRefreshCupertinoHeaderModel());
  }

  private setUpPaging(): void {
    const normal = new CYLRefreshNormalHeaderModel();
    const back = new CYLRefreshBackNormalFooterModel();
    this.attach(normal, back);
    const paging = new CYLRefreshPaging(normal, back, (page: number, done: CYLRefreshPagingCompletion) => {
      this.later(2000, () => {
        const total = 45;
        const size = 10;
        const start = (page - 1) * size;
        const items: Object[] = [];
        for (let i = start; i < Math.min(start + size, total); i++) {
          items.push(i + 1);
        }
        done(items, total, CYLRefreshNotFound, null);
      });
    });
    paging.itemsDidChange = (p: CYLRefreshPaging) => {
      const items = p.items !== null ? p.items : [];
      this.rows = items.map((o: Object): EasyRow => new EasyRow('p' + o, t('CYLScenarioRefreshStyleTestDataRow', o)));
    };
    this.paging = paging;
    paging.start();
  }

  private setUpListener(): void {
    const listener = new CYLRefreshHeaderModel();
    listener.refreshingBlock = () => this.refreshCounted();
    this.attach(listener, this.backFooter(() => this.loadCounted()));
    this.reloadCounted();
  }

  private setUpChat(): void {
    const header = new CYLRefreshNormalHeaderModel();
    header.refreshingBlock = () => this.loadEarlierMessages();
    this.attach(header, null);
    this.earliestMessage = 31;
    this.rows = this.messageRows(31, 50);
    // scrollToRow(last, at: .bottom).
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 50);
  }

  private setUpUserProfile(): void {
    const normal = new CYLRefreshNormalHeaderModel();
    normal.refreshingBlock = () => this.refreshCounted();
    normal.scrollMode = CYLRefreshScrollMode.Behind;
    this.attach(normal, null);
    this.reloadCounted();
  }

  // MARK: - Data

  private testRows(n: number): EasyRow[] {
    const rows: EasyRow[] = [];
    for (let i = 1; i <= n; i++) {
      rows.push(new EasyRow('r' + i, t('CYLScenarioRefreshStyleTestDataRow', i)));
    }
    return rows;
  }

  private messageRows(from: number, to: number): EasyRow[] {
    const rows: EasyRow[] = [];
    for (let i = from; i <= to; i++) {
      rows.push(new EasyRow('m' + i, t('CYLScenarioEasyMessageRow', i)));
    }
    return rows;
  }

  private reloadCounted(): void {
    this.rows = this.testRows(this.count);
  }

  private reloadTriggerMode(): void {
    const headerOnEdge = this.header !== null && this.header.triggerMode === CYLRefreshTriggerMode.OnEdge;
    const footerOnEdge = this.footer !== null && this.footer.triggerMode === CYLRefreshTriggerMode.OnEdge;
    const top: EasyRow[] = [
      new EasyRow('refreshCount', t('CYLScenarioEasyRefreshCount', this.refreshCount)),
      new EasyRow('loadCount', t('CYLScenarioEasyLoadCount', this.loadCount)),
      new EasyRow('headerMode', t(headerOnEdge ? 'CYLScenarioEasyHeaderOnEdge' : 'CYLScenarioEasyHeaderAnywhere')),
      new EasyRow('footerMode', t(footerOnEdge ? 'CYLScenarioEasyFooterOnEdge' : 'CYLScenarioEasyFooterAnywhere')),
    ];
    this.rows = top.concat(this.testRows(this.count));
  }

  /** Refresh: back to 10 rows after 2 s; the footer can load again. */
  private refreshCounted(): void {
    this.later(2000, () => {
      this.count = 10;
      this.reloadCounted();
      const header = this.scrollView.cyl_header;
      if (header !== null) {
        header.endRefreshing();
      }
      if (this.footer !== null) {
        this.footer.resetNoMoreData();
      }
    });
  }

  /** Load: 5 more rows after 2 s; no more data at 20. */
  private loadCounted(): void {
    this.later(2000, () => {
      this.count += 5;
      this.reloadCounted();
      if (this.footer === null) {
        return;
      }
      if (this.count >= 20) {
        this.footer.endRefreshingWithNoMoreData();
      } else {
        this.footer.endRefreshing();
      }
    });
  }

  /** refresh_on_start_page.dart's load: 10 more rows; no more data at 30. */
  private loadByTen(): void {
    this.later(2000, () => {
      this.count += 10;
      this.reloadCounted();
      if (this.footer === null) {
        return;
      }
      if (this.count >= 30) {
        this.footer.endRefreshingWithNoMoreData();
      } else {
        this.footer.endRefreshing();
      }
    });
  }

  private refreshTriggerMode(): void {
    this.later(500, () => {
      this.refreshCount += 1;
      this.reloadTriggerMode();
      const header = this.scrollView.cyl_header;
      if (header !== null) {
        header.endRefreshing();
      }
    });
  }

  private loadTriggerMode(): void {
    this.later(500, () => {
      this.loadCount += 1;
      this.reloadTriggerMode();
      if (this.footer !== null) {
        this.footer.endRefreshing();
      }
    });
  }

  /** chat_page.dart: 10 earlier messages at the top, keeping the visible messages in place; no header at message 1. */
  private loadEarlierMessages(): void {
    this.later(2000, () => {
      const first = Math.max(1, this.earliestMessage - 10);
      const added = first < this.earliestMessage ? this.messageRows(first, this.earliestMessage - 1) : [];
      this.earliestMessage = first;
      const visible = this.firstVisible;
      this.rows = added.concat(this.rows);
      const header = this.header;
      if (header !== null) {
        header.endRefreshing();
      }
      this.scroller.scrollToIndex(visible + added.length);
      if (first === 1 && header !== null) {
        header.hidden = true;
        header.cyl_setNeedsLayout();
      }
    });
  }

  private onRow(index: number): void {
    if (this.method === 'easyScrollMode') {
      if (index < SCROLL_MODES.length) {
        if (this.header !== null) {
          this.header.scrollMode = SCROLL_MODES[index];
        }
        if (this.footer !== null) {
          this.footer.scrollMode = SCROLL_MODES[index];
        }
        this.reloadScrollMode();
      }
      return;
    }
    if (this.method !== 'easyTriggerMode') {
      return;
    }
    const flip = (mode: CYLRefreshTriggerMode): CYLRefreshTriggerMode =>
    mode === CYLRefreshTriggerMode.OnEdge ? CYLRefreshTriggerMode.Anywhere : CYLRefreshTriggerMode.OnEdge;
    if (index === 2 && this.header !== null) {
      this.header.triggerMode = flip(this.header.triggerMode);
    } else if (index === 3 && this.footer !== null) {
      this.footer.triggerMode = flip(this.footer.triggerMode);
    } else {
      return;
    }
    this.reloadTriggerMode();
  }

  @Builder
  list() {
    List({ scroller: this.scroller }) {
      if (this.method === 'easyListener') {
        // The table header: a 4 high progress bar (UIProgressView, bar style).
        ListItem() {
          Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .height(4)
            .color('#007AFF')
            .backgroundColor(Color.Transparent)
            .style({ strokeWidth: 4, strokeRadius: 0 })
            .accessibilityText(t('CYLScenarioEasyPullProgress'))
        }
      }
      if (this.method === 'easyUserProfile') {
        // The table header: the 160 high systemTeal banner.
        ListItem() {
          Text(t('CYLScenarioEasyProfileBanner'))
            .fontSize(22)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .width('100%')
            .height(160)
            .backgroundColor(UiColor.teal)
        }
      }
      ForEach(this.rows, (row: EasyRow, index: number) => {
        ListItem() {
          Text(row.text)
            .fontSize(17)
            .width('100%')
            .height(44)
            .padding({ left: 16, right: 16 })
        }
        .backgroundColor(UiColor.background)
        // A row reads as one element (its title and detail) and acts as a button.
        .accessibilityGroup(true)
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .onClick(() => this.onRow(index))
      }, (row: EasyRow) => row.id)
      if (this.method === 'easyCupertino') {
        ListItem() {
          CYLRefreshFooterView({ scrollView: this.scrollView })
        }
      }
    }
    .divider({ strokeWidth: 0.5, color: UiColor.separator, startMargin: 16 })
    .onScrollIndex((start: number) => {
      this.firstVisible = start;
    })
    .contentEndOffset(PAGE_LIST_END_INSET)
    .edgeEffect(EdgeEffect.None)
    .width('100%')
    .height('100%')
  }


  @Builder
  navTitle() {
    NavTitle(this.param.title)
  }

  build() {
    NavDestination() {
      if (this.floorShown) {
        CYLRefreshContainer({
          scrollView: this.scrollView,
          scroller: this.scroller,
          secondaryHeaderBuilder: wrapBuilder(secondFloor)
        }) {
          this.list()
        }
      } else {
        CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
          this.list()
        }
      }
    }
    .title(this.navTitle)
    .backgroundColor(UiColor.background)
  }
}
