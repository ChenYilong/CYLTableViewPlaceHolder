// CYLRefreshIconDemoViewController: 15 rows; the header ends after 1.5 s; the footer adds 15 up to 45, then
// "No more data". The bar's Refresh button starts the header in code (beginRefreshing).
// Above the list, the playback controls of docs/Example-Animation-Playback.md drive the header and footer icons:
// Play all starts a refresh, which replays the icon from 0; the speed and the loop apply live.
import {
  CYLRefreshAnimationHeaderModel,
  CYLRefreshAutoAnimationFooterModel,
  CYLRefreshBackAnimationFooterModel,
  CYLRefreshContainer,
  CYLRefreshFooterModel,
  CYLRefreshFooterView,
  CYLRefreshHeaderModel,
  CYLRefreshIconViewModel,
  CYLRefreshScrollViewModel
} from 'cylplaceholder';
import { effectiveLanguage, t } from '../common/L10n';
import { PlaybackControls } from '../common/Playback';
import { RouteParam } from '../common/Routes';
import { UiColor, PAGE_LIST_END_INSET, NavTitle } from '../common/Ui';
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
  @State speed: number = 1;
  @State loop: boolean = true;

  aboutToAppear(): void {
    const row = refreshIconRowFor(this.param.value);
    const setup = row !== null ? row.setup : RefreshSetup.of('normal', 'auto', [], []);
    const controls = setup.make(this.getUIContext());
    const header = controls.header;
    const footer = controls.footer;
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

  /** The icon views of the header and footer (animated styles only). */
  private iconViews(): CYLRefreshIconViewModel[] {
    const views: CYLRefreshIconViewModel[] = [];
    if (this.header instanceof CYLRefreshAnimationHeaderModel) {
      views.push((this.header as CYLRefreshAnimationHeaderModel).iconView);
    }
    if (this.footer instanceof CYLRefreshAutoAnimationFooterModel) {
      views.push((this.footer as CYLRefreshAutoAnimationFooterModel).iconView);
    } else if (this.footer instanceof CYLRefreshBackAnimationFooterModel) {
      views.push((this.footer as CYLRefreshBackAnimationFooterModel).iconView);
    }
    return views;
  }

  private playAll(): void {
    if (this.header !== null && !this.header.refreshing) {
      this.header.beginRefreshing();
    }
    this.iconViews().forEach((v: CYLRefreshIconViewModel) => v.replayAnimation());
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
        .accessibilityText(t('CYLScenarioTabRefresh'))
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .onClick(() => {
          if (this.header !== null) {
            this.header.beginRefreshing();
          }
        })
    }
    .height('100%')
  }

  @Builder
  navTitle() {
    NavTitle(this.param.title)
  }

  build() {
    NavDestination() {
      Column() {
      PlaybackControls({
        language: effectiveLanguage(),
        speed: $speed,
        loop: $loop,
        onPlayAll: () => this.playAll(),
        onSpeed: (speed: number) => this.iconViews().forEach((v: CYLRefreshIconViewModel) => v.animationSpeed = speed),
        onLoop: (loop: boolean) => this.iconViews().forEach((v: CYLRefreshIconViewModel) => v.loopsWhilePlaying = loop)
      })
      Column() {
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
        .contentEndOffset(PAGE_LIST_END_INSET)
        .edgeEffect(EdgeEffect.None)
        .width('100%')
        .height('100%')
      }
      }
      .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .title(this.navTitle)
    .menus(this.barItems)
    .backgroundColor(Color.White)
  }
}
