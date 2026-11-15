// CYLScenarioDetailViewController: one scenario on an empty plain table; the right bar items read "Tap: on | Clear".
//
// - retry:          the Loading scenario for 1.2 s, then 12 rows and a feedback; "Clear" empties the table again
// - contactSupport: opens the support page
// - openSettings:   opens the app's page in Settings
// - goShopping:     a short confirmation
// - chooseManually: a short confirmation (the location permission scenario offers to pick an address by hand)
// - done:           goes back
// "Tap: on/off" switches every component's tap (off keeps the components visible but inert).
import { common, Want } from '@kit.AbilityKit';
import {
  CYLPlaceholderAction,
  CYLPlaceholderActionHandler,
  CYLPlaceholderActions,
  CYLPlaceholderScenario,
  CYLPlaceholderScenarioCatalog,
  CYLPlaceholderStackView,
  CYLPlaceholderStackViewModel,
  CYLPlaceholderViewModel
} from 'cylplaceholder';
import { showFeedback, t } from '../common/L10n';
import { Route, RouteParam, pop, push } from '../common/Routes';
import { BarButton, UiColor } from '../common/Ui';

/** Opens the app's page in the Settings app (UIApplication.openSettingsURLString). */
export function openAppSettings(context: UIContext): void {
  const host = context.getHostContext() as common.UIAbilityContext;
  const want: Want = {
    bundleName: 'com.huawei.hmos.settings',
    abilityName: 'com.huawei.hmos.settings.MainAbility',
    uri: 'application_info_entry',
    parameters: { 'pushParams': host.abilityInfo.bundleName }
  };
  host.startAbility(want).catch(() => {
  });
}

@Component
export struct ScenarioDetailPage {
  param: RouteParam = new RouteParam();
  @State placeholder: CYLPlaceholderStackViewModel = new CYLPlaceholderStackViewModel();
  @State rows: string[] = [];
  @State interactionEnabled: boolean = true;
  private isLoading: boolean = false;
  private scenario: CYLPlaceholderScenario = CYLPlaceholderScenario.NoContent;
  private timer: number = -1;

  aboutToAppear(): void {
    const scenario = CYLPlaceholderScenarioCatalog.scenarioNamed(this.param.value);
    if (scenario !== null) {
      this.scenario = scenario;
    }
    this.reloadData();
  }

  aboutToDisappear(): void {
    clearTimeout(this.timer);
  }

  /** tableView.reloadData(): the placeholder is made again (cyl_placeholderViewBlock). */
  private reloadData(): void {
    if (this.isLoading) {
      this.placeholder = CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.Loading);
      return;
    }
    const placeholder = this.makeScenarioPlaceholder();
    placeholder.componentViews.forEach((component: CYLPlaceholderViewModel) => {
      component.tapInteractionEnabled = this.interactionEnabled;
    });
    this.placeholder = placeholder;
  }

  private makeScenarioPlaceholder(): CYLPlaceholderStackViewModel {
    const context = this.getUIContext();
    const actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> = new Map();
    actions.set(CYLPlaceholderActions.Retry, (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) => this.retry());
    actions.set(CYLPlaceholderActions.ContactSupport,
      (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) => push(Route.Support));
    actions.set(CYLPlaceholderActions.OpenSettings,
      (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) => openAppSettings(context));
    actions.set(CYLPlaceholderActions.GoShopping, (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) =>
    showFeedback(context, t('CYLScenarioFeedbackGoShopping')));
    actions.set(CYLPlaceholderActions.ChooseManually, (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) =>
    showFeedback(context, t('CYLScenarioFeedbackChooseManually')));
    actions.set(CYLPlaceholderActions.Done, (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) => pop());
    return CYLPlaceholderStackViewModel.initWithScenario(this.scenario, actions);
  }

  private retry(): void {
    this.isLoading = true;
    this.reloadData();
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      this.isLoading = false;
      const rows: string[] = [];
      for (let i = 1; i <= 12; i++) {
        rows.push(t('CYLScenarioFormatItem', i));
      }
      this.rows = rows;
      this.reloadData();
      showFeedback(this.getUIContext(), t('CYLScenarioFeedbackRetry'));
    }, 1200);
  }

  private clear(): void {
    clearTimeout(this.timer);
    this.isLoading = false;
    this.rows = [];
    this.reloadData();
  }

  private toggleInteraction(): void {
    this.interactionEnabled = !this.interactionEnabled;
    this.reloadData();
  }

  @Builder
  barItems() {
    Row() {
      Text(t(this.interactionEnabled ? 'CYLScenarioInteractionOn' : 'CYLScenarioInteractionOff'))
        .fontSize(17)
        .fontColor(UiColor.teal)
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .id('interactionToggle')
        .onClick(() => this.toggleInteraction())
      BarButton(t('CYLScenarioActionClear'), () => this.clear())
    }
    .height('100%')
  }

  build() {
    NavDestination() {
      if (this.rows.length > 0) {
        List() {
          ForEach(this.rows, (row: string) => {
            ListItem() {
              Row() {
                Text('📄').fontSize(18).fontColor(UiColor.teal).width(26).margin({ right: 12 })
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
      } else {
        CYLPlaceholderStackView({ model: this.placeholder })
      }
    }
    .title(CYLPlaceholderScenarioCatalog.localizedNameForScenario(this.scenario))
    .menus(this.barItems)
    .backgroundColor(Color.White)
  }
}
