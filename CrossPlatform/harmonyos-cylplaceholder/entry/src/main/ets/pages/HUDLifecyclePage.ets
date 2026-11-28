// CYLHUDLifecycleViewController: a page's whole life cycle with the library's components: the HUD while the first
// page loads, the RetryButton placeholder when it fails (the first attempt fails, the next succeeds), then pull down
// to refresh (items 1...15) and pull up to load more (+10 each, no more data at 45). A HUD local to the page, with a
// minimum dismiss interval of 1 s.
import {
  CYLPlaceholderAction,
  CYLPlaceholderActionHandler,
  CYLPlaceholderActions,
  CYLPlaceholderHUD,
  CYLPlaceholderScenario,
  CYLPlaceholderStackView,
  CYLPlaceholderStackViewModel,
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshContainer,
  CYLRefreshFooterView,
  CYLRefreshNormalHeaderModel,
  CYLRefreshScrollViewModel
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { RouteParam } from '../common/Routes';
import { UiColor, PAGE_LIST_END_INSET, NavTitle } from '../common/Ui';

function range(from: number, to: number): number[] {
  const list: number[] = [];
  for (let i = from; i <= to; i++) {
    list.push(i);
  }
  return list;
}

@Component
export struct HUDLifecyclePage {
  param: RouteParam = new RouteParam();
  @State items: number[] = [];
  @State listHeight: number = 0;
  @State placeholder: CYLPlaceholderStackViewModel = new CYLPlaceholderStackViewModel();
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private footer: CYLRefreshAutoNormalFooterModel = new CYLRefreshAutoNormalFooterModel();
  private hud: CYLPlaceholderHUD | null = null;
  private attempts: number = 0;
  private timers: number[] = [];

  aboutToAppear(): void {
    const hud = CYLPlaceholderHUD.initWithContainerView(this.getUIContext());
    hud.minimumDismissTimeInterval = 1;
    this.hud = hud;
    const actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> = new Map();
    actions.set(CYLPlaceholderActions.Retry,
      (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) => this.loadFirstPage());
    this.placeholder = CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.RetryButton, actions);
    // CYLRefreshNormalHeader: after 1 s items 1...15, end, reset no-more-data.
    const header = CYLRefreshNormalHeaderModel.headerWithRefreshingBlock(() => {
      this.timers.push(setTimeout(() => {
        this.setItems(range(1, 15));
        header.endRefreshing();
        this.footer.resetNoMoreData();
      }, 1000));
    });
    // CYLRefreshAutoNormalFooter: after 1 s ten more items; no more data from 45.
    const footer = CYLRefreshAutoNormalFooterModel.footerWithRefreshingBlock(() => {
      this.timers.push(setTimeout(() => {
        const next = this.items.length + 1;
        this.setItems(this.items.concat(range(next, next + 9)));
        if (this.items.length >= 45) {
          footer.endRefreshingWithNoMoreData();
        } else {
          footer.endRefreshing();
        }
      }, 1000));
    }) as CYLRefreshAutoNormalFooterModel;
    this.footer = footer;
    this.scrollView.cyl_header = header;
    this.scrollView.cyl_footer = footer;
    this.scrollView.dataCountProvider = () => this.items.length;
    this.setItems([]);
    this.loadFirstPage();
  }

  aboutToDisappear(): void {
    this.timers.forEach((id: number) => clearTimeout(id));
    if (this.hud !== null) {
      this.hud.dismiss();
    }
  }

  private setItems(items: number[]): void {
    this.items = items;
    this.footer.hidden = items.length === 0;
  }

  /** The first attempt fails, the next succeeds, so every state of the cycle shows once. */
  private loadFirstPage(): void {
    const hud = this.hud!;
    this.attempts += 1;
    hud.showWithStatus(t('CYLScenarioHUDStatusLoading'));
    this.timers.push(setTimeout(() => {
      if (this.attempts === 1) {
        hud.showErrorWithStatus(t('CYLScenarioHUDStatusFailed'));
        this.setItems([]);
      } else {
        hud.dismiss();
        this.setItems(range(1, 15));
      }
    }, 1500));
  }


  @Builder
  navTitle() {
    NavTitle(t('CYLScenarioHUDSectionLifecycle'))
  }

  build() {
    NavDestination() {
      Column() {
        CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
          List({ scroller: this.scroller }) {
            ForEach(this.items, (n: number) => {
              ListItem() {
                Text(t('CYLScenarioHUDLifecycleRow', n)).fontSize(17).width('100%').height(44)
                  .padding({ left: 16, right: 16 })
              }
            }, (n: number) => n.toString())
            if (this.items.length === 0) {
              ListItem() {
                CYLPlaceholderStackView({ model: this.placeholder })
              }
              .height(this.listHeight)
            }
            ListItem() {
              CYLRefreshFooterView({ scrollView: this.scrollView })
            }
          }
          .divider({ strokeWidth: 0.5, color: UiColor.separator, startMargin: 16 })
          .contentEndOffset(PAGE_LIST_END_INSET)
          .edgeEffect(EdgeEffect.None)
          .width('100%')
          .height('100%')
          .id('hudLifecycle')
        }
      }
      .width('100%')
      .height('100%')
      .onAreaChange((o: Area, n: Area) => {
        this.listHeight = Number(n.height);
      })
    }
    .title(this.navTitle)
    .backgroundColor(UiColor.background)
  }
}
