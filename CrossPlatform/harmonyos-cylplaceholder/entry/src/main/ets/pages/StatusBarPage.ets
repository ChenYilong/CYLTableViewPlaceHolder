// CYLStatusBarViewController: CYLChatKit's red network bar and the placeholder as two independent parts of the page
// (CYLPlaceholderStatusController + CYLPlaceholderStatusPage). One display value chooses what shows (the bottom
// toolbar's segmented control): bar + placeholder (All), bar only (StatusBar, empty list), placeholder only
// (Placeholder), bar + list (StatusBar with 12 rows). "Network" makes the bar follow the network (shows while
// offline) and reports the current status; "File" applies one of StatusBar/*.json.
import {
  CYLPlaceholderAction,
  CYLPlaceholderActionHandler,
  CYLPlaceholderActions,
  CYLPlaceholderConfiguration,
  CYLPlaceholderList,
  CYLPlaceholderListController,
  CYLPlaceholderNetworkMonitor,
  CYLPlaceholderScenario,
  CYLPlaceholderStackViewModel,
  CYLPlaceholderStatusController,
  CYLPlaceholderStatusDisplay,
  CYLPlaceholderStatusPage,
  CYLPlaceholderStatusViewModel
} from 'cylplaceholder';
import { showFeedback, t } from '../common/L10n';
import { readRawText } from '../common/RawFile';
import { RouteParam } from '../common/Routes';
import { BarButton, UiColor } from '../common/Ui';

const MODE_KEYS: string[] = ['CYLScenarioStatusModeBoth', 'CYLScenarioStatusModeBar', 'CYLScenarioStatusModePlaceholder',
  'CYLScenarioStatusModeList'];
const MODE_DISPLAYS: number[] = [CYLPlaceholderStatusDisplay.All, CYLPlaceholderStatusDisplay.StatusBar,
  CYLPlaceholderStatusDisplay.Placeholder, CYLPlaceholderStatusDisplay.StatusBar];
const BAR_AND_LIST: number = 3;
/** StatusBar/*.json of the example bundle, sorted by name. */
const FILES: string[] = ['status-bar-and-placeholder.json', 'status-bar-only.json', 'status-bar-when-offline.json'];

@Component
export struct StatusBarPage {
  param: RouteParam = new RouteParam();
  @State mode: number = 0;
  @State rows: string[] = [];
  @State followsNetwork: boolean = false;
  @State status: CYLPlaceholderStatusController = new CYLPlaceholderStatusController();
  @State list: CYLPlaceholderListController = new CYLPlaceholderListController(() => this.rows.length);

  aboutToAppear(): void {
    const context = this.getUIContext();
    const actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> = new Map();
    actions.set(CYLPlaceholderActions.Retry, (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) =>
    showFeedback(context, t('CYLScenarioFeedbackReconnect')));
    this.list.cyl_placeholderViewBlock((l: CYLPlaceholderListController) =>
    CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.NetworkUnavailable, actions));
    this.status.cyl_placeholderScrollView = this.list;
    this.installBarTap();
    this.apply(0);
  }

  aboutToDisappear(): void {
    this.status.cyl_showsStatusViewWhenOffline = false;
  }

  /** CYLPlaceholderStatusViewDelegate statusViewClicked: (CYLChatKit reconnects here). */
  private installBarTap(): void {
    const context = this.getUIContext();
    this.status.cyl_statusView.tapHandler = (v: CYLPlaceholderStatusViewModel) =>
    showFeedback(context, t('CYLScenarioFeedbackReconnect'));
  }

  /** cyl_setStatusDisplay plus the rows of the mode. */
  private apply(mode: number): void {
    const rows: string[] = [];
    if (mode === BAR_AND_LIST) {
      for (let i = 1; i <= 12; i++) {
        rows.push(t('CYLScenarioFormatItem', i));
      }
    }
    this.mode = mode;
    this.rows = rows;
    this.list.reloadData();
    this.status.cyl_setStatusDisplay(MODE_DISPLAYS[mode], true);
  }

  /** Toggles cyl_showsStatusViewWhenOffline, then shows the current network status. */
  private toggleNetwork(): void {
    this.followsNetwork = !this.followsNetwork;
    this.status.cyl_showsStatusViewWhenOffline = this.followsNetwork;
    const monitor = CYLPlaceholderNetworkMonitor.sharedMonitor;
    monitor.startMonitoring();
    showFeedback(this.getUIContext(), t('CYLScenarioFormatNetworkStatus',
      CYLPlaceholderNetworkMonitor.nameForStatus(monitor.networkStatus)));
  }

  /** The action sheet of StatusBar/*.json, with Cancel. */
  private showFiles(): void {
    this.getUIContext().showActionSheet({
      title: t('CYLScenarioActionShowFile'),
      message: '',
      autoCancel: true,
      confirm: { value: t('CYLScenarioActionCancel'), action: () => {
      } },
      sheets: FILES.map((name: string) => {
        const sheet: SheetInfo = { title: name, action: () => this.applyFile(name) };
        return sheet;
      })
    });
  }

  /** cyl_applyStatusConfiguration(contentsOf:), then the segment that matches the new display. */
  private applyFile(name: string): void {
    const context = this.getUIContext();
    const onError = (message: string) => showFeedback(context, message);
    const configuration = CYLPlaceholderConfiguration.parseText(readRawText(context, 'example/statusbar/' + name), name,
      onError);
    if (configuration === null || !this.status.cyl_applyStatusConfiguration(configuration, onError)) {
      return;
    }
    // As on iOS, the file changes the network option but not the "Network" button title.
    this.installBarTap();
    const display = this.status.cyl_statusDisplay;
    this.mode = display === CYLPlaceholderStatusDisplay.All ? 0 :
      (display === CYLPlaceholderStatusDisplay.StatusBar ? 1 : 2);
    this.rows = [];
    this.list.reloadData();
  }

  @Builder
  barItems() {
    Row() {
      BarButton(t(this.followsNetwork ? 'CYLScenarioStatusFollowingNetwork' : 'CYLScenarioStatusFollowNetwork'),
        () => this.toggleNetwork())
      BarButton(t('CYLScenarioActionShowFile'), () => this.showFiles())
    }
    .height('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
        CYLPlaceholderStatusPage({ controller: this.status }) {
          CYLPlaceholderList({ controller: this.list }) {
            List() {
              ForEach(this.rows, (row: string) => {
                ListItem() {
                  Row() {
                    Text('💬').fontSize(18).width(26).margin({ right: 12 })
                    Text(row).fontSize(17)
                  }
                  .width('100%')
                  .height(44)
                  .padding({ left: 16, right: 16 })
                }
              }, (row: string) => row)
            }
            .divider({ strokeWidth: 0.5, color: UiColor.separator, startMargin: 54 })
            .width('100%')
            .height('100%')
            .id('statusBarDemo')
          }
        }
        }
        .layoutWeight(1)

        // The navigation controller's toolbar: a centered segmented control.
        Row() {
          ForEach(MODE_KEYS, (key: string, index: number) => {
            Text(t(key))
              .fontSize(13)
              .textAlign(TextAlign.Center)
              .layoutWeight(1)
              .height(28)
              .borderRadius(7)
              .maxLines(1)
              .backgroundColor(index === this.mode ? Color.White : Color.Transparent)
              .onClick(() => this.apply(index))
          }, (key: string) => key)
        }
        .id('statusBarMode')
        .padding(2)
        .borderRadius(9)
        .backgroundColor('#E3E3E8')
        .margin({ left: 16, right: 16, top: 8, bottom: 8 })
      }
      .width('100%')
      .height('100%')
    }
    .title(t('CYLScenarioTitleStatusBar'))
    .menus(this.barItems)
    .backgroundColor(Color.White)
  }
}
