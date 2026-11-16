// CYLRefreshCollectionViewController.swift: MJRefresh's collection examples (param.value = "vc|method").
// - CYLRefreshCollectionViewController example31: 80×80 random colors (insets 20, spacing 20) under a purple 30 high
//   section header; a normal header puts 10 colors at the front, a back footer (no animation, fading) 5 at the end;
//   each reloads and ends after 2 s; the footer is hidden while there are no colors.
// - example32: the same with animated icons (Lottie header icons, GIF footer icon).
// - CYLRefreshPinHeaderCollectionViewController example31: the same grid (its pinning layout only re-creates the
//   header attributes, so it looks the same).
// - CYLRefreshHorizontalCollectionViewController example42: 5 full-width 200 high pages at y = 150, paging; pull
//   left past the last page and CYLRefreshNormalTrailer pushes the test page.
// An item opens the test page (odd items push, even items present).
import {
  CYLRefreshAnimationHeaderModel,
  CYLRefreshBackAnimationFooterModel,
  CYLRefreshBackNormalFooterModel,
  CYLRefreshContainer,
  CYLRefreshFooterModel,
  CYLRefreshHeaderModel,
  CYLRefreshIconSize,
  CYLRefreshNormalHeaderModel,
  CYLRefreshNormalTrailerModel,
  CYLRefreshScrollViewModel,
  CYLRefreshState
} from 'cylplaceholder';
import { LengthMetrics } from '@kit.ArkUI';
import { t } from '../common/L10n';
import { RouteParam } from '../common/Routes';
import { animationPath } from '../feed/RefreshSetups';
import { showRefreshTest } from './RefreshTestPage';
import { PAGE_LIST_END_INSET, NavTitle } from '../common/Ui';

const CYLRefreshCollectionDuration: number = 2000;

/** CYLRefreshRandomColor. */
function randomColor(): string {
  const c = (): number => Math.floor(Math.random() * 256);
  return 'rgb(' + c() + ', ' + c() + ', ' + c() + ')';
}

class ColorItem {
  id: string;
  color: string;

  constructor() {
    this.id = Math.random().toString(36).slice(2);
    this.color = randomColor();
  }
}

function randomColors(n: number): ColorItem[] {
  const items: ColorItem[] = [];
  for (let i = 0; i < n; i++) {
    items.push(new ColorItem());
  }
  return items;
}

@Component
export struct RefreshCollectionPage {
  param: RouteParam = new RouteParam();
  @State colors: ColorItem[] = [];
  @State pages: ColorItem[] = randomColors(5);
  @State horizontal: boolean = false;
  @State pageWidth: number = 360;
  private data: ColorItem[] = [];
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private timers: number[] = [];

  aboutToAppear(): void {
    const parts = this.param.value.split('|');
    const vc = parts[0];
    const method = parts.length > 1 ? parts[1] : 'example31';
    this.horizontal = vc === 'CYLRefreshHorizontalCollectionViewController';
    if (this.horizontal) {
      this.example42();
      return;
    }
    this.scrollView.dataCountProvider = () => this.colors.length;
    if (method === 'example32') {
      this.example32();
    } else {
      this.example31();
    }
  }

  aboutToDisappear(): void {
    this.timers.forEach((id: number) => clearTimeout(id));
  }

  private later(ms: number, action: () => void): void {
    this.timers.push(setTimeout(action, ms));
  }

  /** collectionView(_:numberOfItemsInSection:): the footer hides while there are no colors. */
  private reload(): void {
    this.colors = this.data.slice();
    const footer = this.scrollView.cyl_footer;
    if (footer !== null) {
      footer.hidden = this.colors.length === 0;
      footer.cyl_setNeedsLayout();
    }
  }

  private loadNew(header: CYLRefreshHeaderModel): void {
    this.data = randomColors(10).concat(this.data);
    this.later(CYLRefreshCollectionDuration, () => {
      this.reload();
      header.endRefreshing();
    });
  }

  private loadMore(footer: CYLRefreshFooterModel): void {
    this.data = this.data.concat(randomColors(5));
    this.later(CYLRefreshCollectionDuration, () => {
      this.reload();
      footer.endRefreshing();
    });
  }

  private example31(): void {
    const header = new CYLRefreshNormalHeaderModel();
    header.refreshingBlock = () => this.loadNew(header);
    header.isCollectionViewAnimationBug = true;
    const footer = new CYLRefreshBackNormalFooterModel();
    footer.refreshingBlock = () => this.loadMore(footer);
    footer.setAnimationDisabled();
    footer.automaticallyChangeAlpha = true;
    this.attach(header, footer);
  }

  private example32(): void {
    const header = new CYLRefreshAnimationHeaderModel();
    header.refreshingBlock = () => this.loadNew(header);
    header.setIconAnimationFilePath(animationPath('CYLRefreshCounterClockwise.json'), new CYLRefreshIconSize(28, 28),
      CYLRefreshState.Idle);
    header.setIconAnimationFilePath(animationPath('CYLRefreshGradientSpinner.json'), new CYLRefreshIconSize(32, 32),
      CYLRefreshState.Refreshing);
    header.isCollectionViewAnimationBug = true;
    const footer = new CYLRefreshBackAnimationFooterModel();
    footer.refreshingBlock = () => this.loadMore(footer);
    footer.setIconAnimationFilePath(animationPath('CYLRefreshActivity.gif'), new CYLRefreshIconSize(28, 28),
      CYLRefreshState.Idle);
    footer.automaticallyChangeAlpha = true;
    this.attach(header, footer);
  }

  private attach(header: CYLRefreshHeaderModel, footer: CYLRefreshFooterModel): void {
    this.scrollView.cyl_header = header;
    this.scrollView.cyl_footer = footer;
    footer.hidden = true;
    header.beginRefreshing();
  }

  private example42(): void {
    const trailer = new CYLRefreshNormalTrailerModel();
    trailer.refreshingBlock = () => {
      showRefreshTest(1);
      trailer.endRefreshing();
    };
    this.scrollView.pagingEnabled = true;
    this.scrollView.dataCountProvider = () => this.pages.length;
    this.scrollView.cyl_trailer = trailer;
  }

  @Builder
  grid() {
    CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
      List({ scroller: this.scroller }) {
        ListItem() {
          Column()
            .width('100%')
            .height(30)
            .backgroundColor('#AF52DE')
        }
        ListItem() {
          Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(20), cross: LengthMetrics.vp(20) } }) {
            ForEach(this.colors, (item: ColorItem, index: number) => {
              Column()
                .width(80)
                .height(80)
                .backgroundColor(item.color)
                .stateStyles({ pressed: { .opacity(0.6) }, normal: { .opacity(1) } })
                .accessibilityText(t(index % 2 === 1 ? 'CYLScenarioMJPush' : 'CYLScenarioMJModal'))
                .onClick(() => showRefreshTest(index))
            }, (item: ColorItem) => item.id)
          }
          .width('100%')
          .padding(20)
        }
      }
      .contentEndOffset(PAGE_LIST_END_INSET)
      .edgeEffect(EdgeEffect.None)
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  pager() {
    Column() {
      CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller, horizontal: true }) {
        List({ scroller: this.scroller }) {
          ForEach(this.pages, (item: ColorItem, index: number) => {
            ListItem() {
              Column()
                .width('100%')
                .height('100%')
                .backgroundColor(item.color)
                .accessibilityText(t(index % 2 === 1 ? 'CYLScenarioMJPush' : 'CYLScenarioMJModal'))
                .onClick(() => showRefreshTest(index))
            }
            .width(this.pageWidth)
            .height(200)
          }, (item: ColorItem) => item.id)
        }
        .listDirection(Axis.Horizontal)
        .scrollSnapAlign(ScrollSnapAlign.START)
        .scrollBar(BarState.Off)
        .contentEndOffset(PAGE_LIST_END_INSET)
        .edgeEffect(EdgeEffect.None)
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height(200)
    .margin({ top: 150 })
  }

  @Builder
  navTitle() {
    NavTitle(this.param.title)
  }

  build() {
    NavDestination() {
      Column() {
        if (this.horizontal) {
          this.pager()
        } else {
          this.grid()
        }
      }
      .width('100%')
      .height('100%')
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.pageWidth = Number(newValue.width);
      })
    }
    .title(this.navTitle)
    .backgroundColor(Color.White)
  }
}
