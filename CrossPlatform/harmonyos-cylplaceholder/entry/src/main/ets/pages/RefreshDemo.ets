// A small CYLRefresh demo with a style picker. "Classic": a list with a normal header (pull down) and an auto footer
// (loads at the end), paged by CYLRefreshPaging (20 rows per page, 3 pages). The other entries are the drawn
// SmartRefreshControl styles: a header style refreshes on open and ends after 2.5 s; a footer style loads more after
// 2.5 s, doubling the rows (8 → 16 → 32, then no more data). Touch the game headers while they refresh to play.
import {
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshBezierCircleHeaderModel,
  CYLRefreshBezierRadarFooterModel,
  CYLRefreshBezierRadarHeaderModel,
  CYLRefreshContainer,
  CYLRefreshDeliveryFooterModel,
  CYLRefreshDeliveryHeaderModel,
  CYLRefreshDrawnFooterModel,
  CYLRefreshDrawnHeaderModel,
  CYLRefreshDropBoxHeaderModel,
  CYLRefreshFlyHeaderModel,
  CYLRefreshFooterView,
  CYLRefreshGameBattleCityHeaderModel,
  CYLRefreshGameHitBlockHeaderModel,
  CYLRefreshMaterialFooterModel,
  CYLRefreshMaterialHeaderModel,
  CYLRefreshNormalHeaderModel,
  CYLRefreshNotFound,
  CYLRefreshOriginalHeaderModel,
  CYLRefreshPaging,
  CYLRefreshPagingCompletion,
  CYLRefreshPhoenixFooterModel,
  CYLRefreshPhoenixHeaderModel,
  CYLRefreshScrollViewModel,
  CYLRefreshStoreHouseHeaderModel,
  CYLRefreshTaurusFooterModel,
  CYLRefreshTaurusHeaderModel,
  CYLRefreshWaveSwipeHeaderModel
} from 'cylplaceholder';

const REFRESH_STYLES: string[] = ['Classic', 'Delivery', 'DropBox', 'Phoenix', 'Taurus', 'BezierRadar', 'BezierCircle',
  'StoreHouse', 'WaveSwipe', 'Original', 'Material', 'GameHitBlock', 'GameBattleCity', 'Fly', 'BezierRadarFooter',
  'MaterialFooter', 'DeliveryFooter', 'PhoenixFooter', 'TaurusFooter'];

function makeDrawnHeader(style: string): CYLRefreshDrawnHeaderModel {
  switch (style) {
    case 'Delivery':
      return new CYLRefreshDeliveryHeaderModel();
    case 'DropBox':
      return new CYLRefreshDropBoxHeaderModel();
    case 'Phoenix':
      return new CYLRefreshPhoenixHeaderModel();
    case 'Taurus':
      return new CYLRefreshTaurusHeaderModel();
    case 'BezierRadar':
      return new CYLRefreshBezierRadarHeaderModel();
    case 'BezierCircle':
      return new CYLRefreshBezierCircleHeaderModel();
    case 'StoreHouse':
      return new CYLRefreshStoreHouseHeaderModel();
    case 'WaveSwipe':
      return new CYLRefreshWaveSwipeHeaderModel();
    case 'Original':
      return new CYLRefreshOriginalHeaderModel();
    case 'Material':
      return new CYLRefreshMaterialHeaderModel();
    case 'GameHitBlock':
      return new CYLRefreshGameHitBlockHeaderModel();
    case 'GameBattleCity':
      return new CYLRefreshGameBattleCityHeaderModel();
    default:
      return new CYLRefreshFlyHeaderModel();
  }
}

function makeDrawnFooter(style: string): CYLRefreshDrawnFooterModel {
  switch (style) {
    case 'BezierRadarFooter':
      return new CYLRefreshBezierRadarFooterModel();
    case 'MaterialFooter':
      return new CYLRefreshMaterialFooterModel();
    case 'DeliveryFooter':
      return new CYLRefreshDeliveryFooterModel();
    case 'PhoenixFooter':
      return new CYLRefreshPhoenixFooterModel();
    default:
      return new CYLRefreshTaurusFooterModel();
  }
}

function testRows(count: number): string[] {
  const rows: string[] = [];
  for (let i = 1; i <= count; i++) {
    rows.push('Row ' + i);
  }
  return rows;
}

@Component
export struct RefreshDemo {
  @State rows: string[] = [];
  @State style: string = 'Classic';
  @State generation: number = 0;
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private paging: CYLRefreshPaging | null = null;
  private timer: number = -1;

  aboutToAppear(): void {
    this.choose('Classic');
  }

  aboutToDisappear(): void {
    clearTimeout(this.timer);
  }

  private choose(style: string): void {
    clearTimeout(this.timer);
    this.style = style;
    this.paging = null;
    this.scrollView.cyl_header = null;
    this.scrollView.cyl_footer = null;
    // A fresh scroll view per style, so a style's insets (the always open Fly) do not outlive it.
    this.scrollView = new CYLRefreshScrollViewModel();
    this.scrollView.dataCountProvider = () => this.rows.length;
    this.generation++;
    if (style === 'Classic') {
      this.setUpClassic();
    } else if (style.endsWith('Footer')) {
      this.rows = testRows(8);
      const footer = makeDrawnFooter(style);
      footer.refreshingBlock = () => {
        this.timer = setTimeout(() => {
          const count = this.rows.length * 2;
          this.rows = testRows(count);
          if (count <= 16) {
            footer.endRefreshing();
          } else {
            footer.endRefreshingWithNoMoreData();
          }
        }, 2500);
      };
      this.scrollView.cyl_footer = footer;
    } else {
      this.rows = testRows(20);
      const header = makeDrawnHeader(style);
      header.refreshingBlock = () => {
        this.timer = setTimeout(() => header.endRefreshing(), 2500);
      };
      this.scrollView.cyl_header = header;
      setTimeout(() => header.beginRefreshing(), 300);
    }
  }

  private setUpClassic(): void {
    const header = new CYLRefreshNormalHeaderModel();
    const footer = new CYLRefreshAutoNormalFooterModel();
    this.scrollView.cyl_header = header;
    this.scrollView.cyl_footer = footer;
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

  @Builder
  list() {
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

  build() {
    Column() {
      Scroll() {
        Row({ space: 8 }) {
          ForEach(REFRESH_STYLES, (s: string) => {
            Text(s)
              .fontSize(14)
              .fontColor(s === this.style ? '#FFFFFF' : '#007AFF')
              .backgroundColor(s === this.style ? '#007AFF' : '#F2F2F7')
              .borderRadius(14)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .onClick(() => this.choose(s))
          }, (s: string) => s)
        }
        .padding({ left: 16, right: 16, top: 4, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      // Rebuilt per style (the container keeps the scroll view it was created with).
      ForEach([this.generation], (g: number) => {
        Column() {
          this.list()
        }
        .width('100%')
        .layoutWeight(1)
      }, (g: number) => 'refresh-' + g)
    }
    .width('100%')
    .height('100%')
  }
}
