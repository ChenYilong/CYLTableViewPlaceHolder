// CYLRefreshWKWebViewController (example40 and example41): pull down to reload https://github.com/CoderMJLee/MJRefresh.
// The navigation bar is hidden; the animated-images header (fading automatically) refreshes on open, a pull reloads
// the page and the header ends when it finishes loading or fails (didFinish / didFail). A gray warning label and a red
// back button sit at the bottom right (200×50, at h − 160 and h − 100). 40 and 41 differ only in the order of chained
// calls on iOS, so they behave the same.
// ArkWeb scrolls inside itself, so the Web uses WebLayoutMode.FIT_CONTENT (as tall as its page) inside a Scroll that
// CYLRefreshContainer drives: the header then sits over the web page as it does over WKWebView's scroll view.
import { webview } from '@kit.ArkWeb';
import {
  CYLRefreshAnimationHeaderModel,
  CYLRefreshContainer,
  CYLRefreshScrollViewModel,
  CYLRefreshState
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { RouteParam, pop } from '../common/Routes';

const URL: string = 'https://github.com/CoderMJLee/MJRefresh';

@Component
export struct RefreshWebPage {
  param: RouteParam = new RouteParam();
  @State viewW: number = 0;
  @State viewH: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();
  private scroller: Scroller = new Scroller();
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private header: CYLRefreshAnimationHeaderModel = new CYLRefreshAnimationHeaderModel();
  private loadedOnce: boolean = false;

  aboutToAppear(): void {
    // CYLRefreshExampleImagesHeader: arrows while idle, a ring when pulled and while refreshing.
    const header = this.header;
    header.setAnimationImages([$rawfile('example/core-animations/CYLRefreshArrows.gif')], 0, CYLRefreshState.Idle);
    header.setAnimationImages([$rawfile('example/core-animations/CYLRefreshRing.gif')], 0, CYLRefreshState.Pulling);
    header.setAnimationImages([$rawfile('example/core-animations/CYLRefreshRing.gif')], 0,
      CYLRefreshState.Refreshing);
    header.automaticallyChangeAlpha = true;
    // webView.reload() (the first refresh is the page's first load).
    header.refreshingBlock = () => {
      if (!this.loadedOnce) {
        return;
      }
      try {
        this.controller.refresh();
      } catch (e) {
        header.endRefreshing();
      }
    };
    this.scrollView.cyl_header = header;
    header.beginRefreshing();
  }

  /** didFinish / didFail / didFailProvisionalNavigation. */
  private finished(): void {
    this.loadedOnce = true;
    this.header.endRefreshing();
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
          Scroll(this.scroller) {
            Web({ src: URL, controller: this.controller })
              .layoutMode(WebLayoutMode.FIT_CONTENT)
              .overScrollMode(OverScrollMode.NEVER)
              .javaScriptAccess(true)
              .domStorageAccess(true)
              .width('100%')
              .onPageEnd(() => this.finished())
              .onErrorReceive((event: OnErrorReceiveEvent) => {
                if (event.request.isMainFrame()) {
                  this.finished();
                }
              })
          }
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
          .width('100%')
          .height('100%')
        }

        Text(t('CYLScenarioMJWebWarning'))
          .fontSize(17)
          .minFontSize(9)
          .maxFontSize(17)
          .fontColor(Color.Black)
          .backgroundColor('rgba(142, 142, 147, 0.3)')
          .width(200)
          .height(50)
          .position({ x: this.viewW - 210, y: this.viewH - 160 })
          .zIndex(2)
        Button(t('CYLScenarioMJWebBack'), { type: ButtonType.Normal })
          .fontSize(17)
          .fontColor(Color.White)
          .backgroundColor('#FF3B30')
          .borderRadius(0)
          .width(200)
          .height(50)
          .position({ x: this.viewW - 210, y: this.viewH - 100 })
          .zIndex(2)
          .onClick(() => pop())
      }
      .width('100%')
      .height('100%')
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.viewW = Number(newValue.width);
        this.viewH = Number(newValue.height);
      })
    }
    .hideTitleBar(true)
    .backgroundColor(Color.White)
  }
}
