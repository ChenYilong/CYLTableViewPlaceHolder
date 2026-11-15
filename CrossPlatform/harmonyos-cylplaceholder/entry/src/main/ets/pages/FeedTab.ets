// CYLFeedViewController: loading, then 15 posts; every other refresh fails and shows the RetryButton scenario; load
// more adds 15 up to 30, then "No more data". Header: an icon per state (idle PullArrow 28, pulling Clockwise 28,
// refreshing CYLPlaceholderProgress.pag 32); footer: an auto footer with Ring.gif 28. The bar button opens the
// refresh icons list.
import {
  CYLPlaceholderAction,
  CYLPlaceholderActionHandler,
  CYLPlaceholderActions,
  CYLPlaceholderScenario,
  CYLPlaceholderStackView,
  CYLPlaceholderStackViewModel,
  CYLRefreshContainer,
  CYLRefreshFooterModel,
  CYLRefreshFooterView,
  CYLRefreshHeaderModel,
  CYLRefreshScrollViewModel,
  CYLRefreshState
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { Route, RouteParam, push } from '../common/Routes';
import { LargeTitle, UiColor } from '../common/Ui';
import { RefreshIcon, RefreshSetup } from '../feed/RefreshSetups';

const FEED_SETUP: RefreshSetup = RefreshSetup.of('animation', 'auto', [
  new RefreshIcon(CYLRefreshState.Idle, 'CYLRefreshPullArrow.json', 28),
  new RefreshIcon(CYLRefreshState.Pulling, 'CYLRefreshClockwise.json', 28),
  new RefreshIcon(CYLRefreshState.Refreshing, 'CYLPlaceholderProgress.pag', 32),
], [new RefreshIcon(CYLRefreshState.Refreshing, 'CYLRefreshRing.gif', 28)]);

@Component
export struct FeedTab {
  @State rows: string[] = [];
  @State loading: boolean = true;
  @State retry: CYLPlaceholderStackViewModel = new CYLPlaceholderStackViewModel();
  @State loadingPlaceholder: CYLPlaceholderStackViewModel =
    CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.Loading);
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private header: CYLRefreshHeaderModel = FEED_SETUP.makeHeader();
  private footer: CYLRefreshFooterModel = FEED_SETUP.makeFooter();
  private refreshCount: number = 0;
  private timer: number = -1;

  aboutToAppear(): void {
    const actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> = new Map();
    actions.set(CYLPlaceholderActions.Retry, (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) =>
    this.loadFirstPage());
    this.retry = CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.RetryButton, actions);
    this.loadingPlaceholder.interactive = false;
    this.header.refreshingBlock = () => this.onRefresh();
    this.footer.refreshingBlock = () => this.onLoadMore();
    this.scrollView.cyl_header = this.header;
    this.scrollView.cyl_footer = this.footer;
    this.scrollView.dataCountProvider = () => this.rows.length;
    this.loadFirstPage();
  }

  aboutToDisappear(): void {
    clearTimeout(this.timer);
  }

  private posts(n: number): string[] {
    const rows: string[] = [];
    for (let i = 1; i <= n; i++) {
      rows.push(t('CYLScenarioFormatPost', i));
    }
    return rows;
  }

  private updateFooter(): void {
    this.footer.hidden = this.loading || this.rows.length === 0;
  }

  /** First load: the Loading scenario, then 15 rows after 2 s. */
  private loadFirstPage(): void {
    this.loading = true;
    this.rows = [];
    this.updateFooter();
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      this.loading = false;
      this.rows = this.posts(15);
      this.footer.resetNoMoreData();
      this.updateFooter();
    }, 2000);
  }

  /** Pull to refresh: after 1 s, odd refreshes fail (0 rows: RetryButton), even ones give 15 rows. */
  private onRefresh(): void {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      this.refreshCount += 1;
      this.loading = false;
      this.rows = this.refreshCount % 2 === 1 ? [] : this.posts(15);
      this.footer.resetNoMoreData();
      this.updateFooter();
      this.header.endRefreshing();
    }, 1000);
  }

  /** Load more: after 1 s, +15 until 30, then no more data. */
  private onLoadMore(): void {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      if (this.rows.length >= 30) {
        this.footer.endRefreshingWithNoMoreData();
        return;
      }
      this.rows = this.posts(this.rows.length + 15);
      this.footer.endRefreshing();
    }, 1000);
  }

  build() {
    Column() {
      Row() {
        Blank()
        Text('⟳')
          .fontSize(20)
          .fontColor(UiColor.teal)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .accessibilityText(t('CYLScenarioRefreshIcons'))
          .onClick(() => push(Route.RefreshIcons, new RouteParam()))
      }
      .width('100%')
      .padding({ left: 8, right: 8 })
      LargeTitle(t('CYLScenarioTabFeed'))
      Column() {
      CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
        List({ scroller: this.scroller }) {
          if (this.loading) {
            ListItem() {
              CYLPlaceholderStackView({ model: this.loadingPlaceholder })
            }
            .height(480)
          } else if (this.rows.length === 0) {
            ListItem() {
              CYLPlaceholderStackView({ model: this.retry })
            }
            .height(480)
          }
          ForEach(this.rows, (row: string) => {
            ListItem() {
              Row() {
                Text('👤').fontSize(18).width(26).margin({ right: 12 })
                Column() {
                  Text(row).fontSize(17)
                  Text(t('CYLScenarioTextFeedHint')).fontSize(12).fontColor(UiColor.gray).margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            }
          }, (row: string) => row)
          ListItem() {
            CYLRefreshFooterView({ scrollView: this.scrollView })
          }
        }
        .divider({ strokeWidth: 0.5, color: UiColor.separator, startMargin: 54 })
        .edgeEffect(EdgeEffect.None)
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
      }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiColor.groupedBackground)
  }
}
