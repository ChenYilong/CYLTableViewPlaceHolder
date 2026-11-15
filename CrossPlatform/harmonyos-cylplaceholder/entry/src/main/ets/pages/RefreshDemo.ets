// A small CYLRefresh demo: a list with a normal header (pull down) and an auto footer (loads at the end), paged by
// CYLRefreshPaging (20 rows per page, 3 pages).
import {
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshContainer,
  CYLRefreshFooterView,
  CYLRefreshNormalHeaderModel,
  CYLRefreshNotFound,
  CYLRefreshPaging,
  CYLRefreshPagingCompletion,
  CYLRefreshScrollViewModel
} from 'cylplaceholder';

@Component
export struct RefreshDemo {
  @State rows: string[] = [];
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private paging: CYLRefreshPaging | null = null;

  aboutToAppear(): void {
    const header = new CYLRefreshNormalHeaderModel();
    const footer = new CYLRefreshAutoNormalFooterModel();
    this.scrollView.cyl_header = header;
    this.scrollView.cyl_footer = footer;
    this.scrollView.dataCountProvider = () => this.rows.length;
    const paging = new CYLRefreshPaging(header, footer, (page: number, completion: CYLRefreshPagingCompletion) => {
      setTimeout(() => {
        const items: Object[] = [];
        for (let i = 1; i <= 20; i++) {
          items.push('Page ' + page + ' · row ' + i);
        }
        completion(items, CYLRefreshNotFound, 3, null);
      }, 800);
    });
    paging.itemsDidChange = (p: CYLRefreshPaging) => {
      const items = p.items;
      this.rows = items !== null ? items.map((o: Object) => o as string) : [];
    };
    this.paging = paging;
    paging.start();
  }

  build() {
    CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
      List({ scroller: this.scroller }) {
        ForEach(this.rows, (row: string) => {
          ListItem() {
            Text(row).fontSize(16).width('100%').padding(16)
          }
        }, (row: string) => row)
        ListItem() {
          CYLRefreshFooterView({ scrollView: this.scrollView })
        }
      }
      .divider({ strokeWidth: 0.5, color: '#E5E5EA', startMargin: 16 })
      .edgeEffect(EdgeEffect.None)
      .width('100%')
      .height('100%')
    }
  }
}
