// CYLRefreshIconDemoViewController: 15 rows; the header ends after 1.5 s; the footer adds 15 up to 45, then
// "No more data". The bar's Refresh button starts the header in code (beginRefreshing).
import {
  CYLRefreshContainer,
  CYLRefreshFooterModel,
  CYLRefreshFooterView,
  CYLRefreshHeaderModel,
  CYLRefreshScrollViewModel
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { RouteParam } from '../common/Routes';
import { UiColor } from '../common/Ui';
import { RefreshSetup, refreshIconRowFor } from '../feed/RefreshSetups';

@Component
export struct RefreshIconDemoPage {
  param: RouteParam = new RouteParam();
  @State rows: string[] = [];
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private header: CYLRefreshHeaderModel | null = null;
  private footer: CYLRefreshFooterModel | null = null;
  private timer: number = -1;

  aboutToAppear(): void {
    const row = refreshIconRowFor(this.param.value);
    const setup = row !== null ? row.setup : RefreshSetup.of('normal', 'auto', [], []);
    const header = setup.makeHeader();
    const footer = setup.makeFooter();
    header.refreshingBlock = () => {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => {
        this.rows = this.items(15);
        header.endRefreshing();
        footer.resetNoMoreData();
      }, 1500);
    };
    footer.refreshingBlock = () => {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => {
        if (this.rows.length >= 45) {
          footer.endRefreshingWithNoMoreData();
          return;
        }
        this.rows = this.items(this.rows.length + 15);
        footer.endRefreshing();
      }, 1500);
    };
    this.header = header;
    this.footer = footer;
    this.scrollView.cyl_header = header;
    this.scrollView.cyl_footer = footer;
    this.scrollView.dataCountProvider = () => this.rows.length;
    this.rows = this.items(15);
  }

  aboutToDisappear(): void {
    clearTimeout(this.timer);
  }

  private items(n: number): string[] {
    const rows: string[] = [];
    for (let i = 1; i <= n; i++) {
      rows.push(t('CYLScenarioFormatItem', i));
    }
    return rows;
  }

  @Builder
  barItems() {
    Row() {
      Text('⟳')
        .fontSize(20)
        .fontColor(UiColor.teal)
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .accessibilityText('Refresh')
        .onClick(() => {
          if (this.header !== null) {
            this.header.beginRefreshing();
          }
        })
    }
    .height('100%')
  }

  build() {
    NavDestination() {
      CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
        List({ scroller: this.scroller }) {
          ForEach(this.rows, (row: string) => {
            ListItem() {
              Row() {
                Text('⇅').fontSize(18).fontColor(UiColor.teal).width(26).margin({ right: 12 })
                Column() {
                  Text(row).fontSize(17)
                  Text(t('CYLScenarioTextRefreshHint')).fontSize(12).fontColor(UiColor.gray).margin({ top: 2 })
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
      }
    }
    .title(this.param.title)
    .menus(this.barItems)
    .backgroundColor(Color.White)
  }
}
