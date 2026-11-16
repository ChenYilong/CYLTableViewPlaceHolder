// CYLHUDViewController: the HUD style of the placeholder (CYLPlaceholderHUD, SVProgressHUD's API). "Show" rows call
// one API each, "Look" rows cycle the style, mask, loading animation and haptics (then preview), the last row pushes
// the page life cycle. minimumDismissTimeInterval = 1.5; leaving the page stops the progress timer and dismisses.
import {
  CYLPlaceholderAction,
  CYLPlaceholderActionHandler,
  CYLPlaceholderButtonStyle,
  CYLPlaceholderComponent,
  CYLPlaceholderHUD,
  CYLPlaceholderHUDMaskType,
  CYLPlaceholderHUDStyle,
  CYLPlaceholderImageResource,
  CYLPlaceholderScenario,
  CYLPlaceholderScenarioCatalog,
  CYLPlaceholderStackViewModel
} from 'cylplaceholder';
import { t } from '../common/L10n';
import { Route, RouteParam, push } from '../common/Routes';
import { InsetTable, TableRow, TableSection, NavTitle } from '../common/Ui';

const STYLES: CYLPlaceholderHUDStyle[] = [CYLPlaceholderHUDStyle.Automatic, CYLPlaceholderHUDStyle.Light,
  CYLPlaceholderHUDStyle.Dark, CYLPlaceholderHUDStyle.Custom];
const STYLE_KEYS: string[] = ['CYLScenarioHUDStyleAutomatic', 'CYLScenarioHUDStyleLight', 'CYLScenarioHUDStyleDark',
  'CYLScenarioHUDStyleCustom'];
const MASKS: CYLPlaceholderHUDMaskType[] = [CYLPlaceholderHUDMaskType.None, CYLPlaceholderHUDMaskType.Clear,
  CYLPlaceholderHUDMaskType.Black, CYLPlaceholderHUDMaskType.Gradient, CYLPlaceholderHUDMaskType.Custom];
const MASK_KEYS: string[] = ['CYLScenarioHUDMaskNone', 'CYLScenarioHUDMaskClear', 'CYLScenarioHUDMaskBlack',
  'CYLScenarioHUDMaskGradient', 'CYLScenarioHUDStyleCustom'];
const CANCEL: CYLPlaceholderAction = 'cancel';

/** Row identifier, title key and section (0 Show, 1 Look, 2 Page life cycle). */
const ROW_IDS: string[][] = [
  ['show', 'showStatus', 'showProgress', 'success', 'error', 'info', 'image', 'components', 'scenario', 'popActivity',
    'dismiss'],
  ['style', 'mask', 'animation', 'haptics'],
  ['lifecycle'],
];
const ROW_KEYS: Record<string, string> = {
  'show': 'CYLScenarioHUDShow',
  'showStatus': 'CYLScenarioHUDShowStatus',
  'showProgress': 'CYLScenarioHUDShowProgress',
  'success': 'CYLScenarioHUDShowSuccess',
  'error': 'CYLScenarioHUDShowError',
  'info': 'CYLScenarioHUDShowInfo',
  'image': 'CYLScenarioHUDShowImage',
  'components': 'CYLScenarioHUDShowComponents',
  'scenario': 'CYLScenarioHUDShowScenario',
  'popActivity': 'CYLScenarioHUDPopActivity',
  'dismiss': 'CYLScenarioHUDDismiss',
  'style': 'CYLScenarioHUDStyle',
  'mask': 'CYLScenarioHUDMask',
  'animation': 'CYLScenarioHUDAnimation',
  'haptics': 'CYLScenarioHUDHaptics',
  'lifecycle': 'CYLScenarioHUDLifecycle',
};
const SECTION_KEYS: string[] = ['CYLScenarioHUDSectionShow', 'CYLScenarioHUDSectionLook',
  'CYLScenarioHUDSectionLifecycle'];

@Component
export struct HUDPage {
  param: RouteParam = new RouteParam();
  @State sections: TableSection[] = [];
  private styleIndex: number = 0;
  private maskIndex: number = 0;
  private animationIndex: number = 0;
  private hapticsEnabled: boolean = false;
  /** The loading animations that suit the HUD: the scenario's own GIF first, then Lottie, PAG and Rive. */
  private animations: string[] = CYLPlaceholderScenarioCatalog.animationFileNamesForScenario(CYLPlaceholderScenario.HUD);
  private progressTimer: number = -1;
  private timers: number[] = [];

  private get hud(): CYLPlaceholderHUD {
    return CYLPlaceholderHUD.sharedHUD;
  }

  aboutToAppear(): void {
    const hud = this.hud;
    hud.minimumDismissTimeInterval = 1.5;
    this.render();
  }

  /** viewWillDisappear: also when the life cycle page is pushed. */
  private leave(): void {
    this.stopProgress();
    this.hud.dismiss();
  }

  aboutToDisappear(): void {
    this.timers.forEach((id: number) => clearTimeout(id));
    this.leave();
  }

  private value(id: string): string {
    switch (id) {
      case 'style':
        return t(STYLE_KEYS[this.styleIndex]);
      case 'mask':
        return t(MASK_KEYS[this.maskIndex]);
      case 'animation':
        return this.animations.length > 0 ? this.animations[this.animationIndex] : '';
      case 'haptics':
        return this.hapticsEnabled ? '✓' : '–';
      default:
        return '';
    }
  }

  private render(): void {
    this.sections = SECTION_KEYS.map((key: string, section: number) => new TableSection(t(key),
      ROW_IDS[section].map((id: string) => {
        const row = new TableRow(id, t(ROW_KEYS[id]), '', '', id === 'lifecycle');
        row.detail = this.value(id);
        return row;
      })));
  }

  private onRow(section: number, row: number): void {
    const id = ROW_IDS[section][row];
    const hud = this.hud;
    this.stopProgress();
    switch (id) {
      case 'show':
        hud.show();
        hud.dismissWithDelay(2);
        break;
      case 'showStatus':
        hud.showWithStatus(t('CYLScenarioHUDStatusLoading'));
        hud.dismissWithDelay(2);
        break;
      case 'showProgress':
        this.showProgress();
        break;
      case 'success':
        hud.showSuccessWithStatus(t('CYLScenarioHUDStatusSaved'));
        break;
      case 'error':
        hud.showErrorWithStatus(t('CYLScenarioHUDStatusFailed'));
        break;
      case 'info':
        hud.showInfoWithStatus(t('CYLScenarioHUDStatusInfo'));
        break;
      case 'image':
        // The core's `.cloud` icon.
        hud.showImageStatus(CYLPlaceholderImageResource('cloud'), t('CYLScenarioHUDStatusImage'));
        break;
      case 'components':
        this.showComponents();
        break;
      case 'scenario':
        hud.showScenarioActions(CYLPlaceholderScenario.Uploading, null);
        hud.dismissWithDelay(2);
        break;
      case 'popActivity':
        // Three tasks start; the HUD stays until the last one ends.
        for (let i = 0; i < 3; i++) {
          hud.showWithStatus(t('CYLScenarioHUDStatusLoading'));
        }
        [1000, 2000, 3000].forEach((ms: number) => {
          this.timers.push(setTimeout(() => hud.popActivity(), ms));
        });
        break;
      case 'dismiss':
        hud.dismiss();
        break;
      case 'style':
        this.styleIndex = (this.styleIndex + 1) % STYLES.length;
        hud.style = STYLES[this.styleIndex];
        if (hud.style === CYLPlaceholderHUDStyle.Custom) {
          // The Custom style of the iOS page: white on systemTeal.
          hud.foregroundColor = '#FFFFFF';
          hud.hudBackgroundColor = '#30B0C7';
        }
        this.showPreview();
        break;
      case 'mask':
        this.maskIndex = (this.maskIndex + 1) % MASKS.length;
        if (MASKS[this.maskIndex] === CYLPlaceholderHUDMaskType.Custom) {
          // systemTeal at 0.3.
          hud.backgroundLayerColor = 'rgba(48, 176, 199, 0.3)';
        }
        hud.maskType = MASKS[this.maskIndex];
        this.showPreview();
        break;
      case 'animation':
        if (this.animations.length === 0) {
          return;
        }
        this.animationIndex = (this.animationIndex + 1) % this.animations.length;
        hud.loadingAnimationFileName = this.animations[this.animationIndex];
        this.showPreview();
        break;
      case 'haptics':
        this.hapticsEnabled = !this.hapticsEnabled;
        hud.hapticsEnabled = this.hapticsEnabled;
        hud.showSuccessWithStatus(t('CYLScenarioHUDStatusSaved'));
        break;
      case 'lifecycle':
        this.leave();
        push(Route.HUDLifecycle);
        break;
      default:
        break;
    }
    this.render();
  }

  /** Shows the loading HUD for a moment, so a changed look can be seen. */
  private showPreview(): void {
    this.hud.showWithStatus(t('CYLScenarioHUDStatusLoading'));
    this.hud.dismissWithDelay(1.5);
  }

  /** A progress from 0 to 1 in two seconds (+0.05 every 0.1 s), then success. */
  private showProgress(): void {
    let progress = 0;
    const status = t('CYLScenarioHUDStatusDownloading');
    this.hud.showProgressStatus(0, status);
    this.progressTimer = setInterval(() => {
      progress += 0.05;
      if (progress >= 1 - 1e-9) {
        this.stopProgress();
        this.hud.showSuccessWithStatus(t('CYLScenarioHUDStatusSaved'));
      } else {
        this.hud.showProgressStatus(progress, status);
      }
    }, 100);
  }

  private stopProgress(): void {
    if (this.progressTimer >= 0) {
      clearInterval(this.progressTimer);
    }
    this.progressTimer = -1;
  }

  /** The HUD scenario's components plus an outlined "Cancel" button with the action "cancel". */
  private showComponents(): void {
    const components = CYLPlaceholderScenarioCatalog.componentsForScenario(CYLPlaceholderScenario.HUD).concat([
      CYLPlaceholderComponent.buttonComponentWithTitle(t('CYLScenarioHUDCancel'), CYLPlaceholderButtonStyle.Outlined,
        CANCEL),
    ]);
    const actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> = new Map();
    actions.set(CANCEL, (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) =>
    this.hud.showInfoWithStatus(t('CYLScenarioHUDCancelled')));
    this.hud.showComponentsActions(components, actions);
  }

  @Builder
  navTitle() {
    NavTitle(t('CYLScenarioTitleHUD'))
  }

  build() {
    NavDestination() {
      InsetTable({
        sections: this.sections,
        onRow: (section: number, row: number) => this.onRow(section, row)
      })
    }
    .title(this.navTitle)
    .onHidden(() => this.leave())
  }
}
