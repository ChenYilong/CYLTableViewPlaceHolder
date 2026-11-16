// CYLConfigurationViewController: one configuration file of the example bundle (rawfile/example/configurations, JSON
// or plist), turned into a placeholder by the library. A JSON file that names the example's own texts
// ("exampleTitleKey") gets them resolved here, so the library never reads the example's strings. The right bar items
// read "File | Replay"; every action confirms the tap with its title; a broken file shows its error in red.
import {
  CYLPlaceholderAction,
  CYLPlaceholderActionHandler,
  CYLPlaceholderActions,
  CYLPlaceholderConfiguration,
  CYLPlaceholderScenarioCatalog,
  CYLPlaceholderStackView,
  CYLPlaceholderStackViewModel
} from 'cylplaceholder';
import { showFeedback, t } from '../common/L10n';
import { readRawText } from '../common/RawFile';
import { Route, RouteParam, push } from '../common/Routes';
import { BarButton, UiColor, NavTitle } from '../common/Ui';

/** The files of the bundle's Configurations directory, sorted by name (CYLConfigurationFiles.urls()). */
export const CONFIGURATION_FILES: string[] = [
  'animation-formats.json',
  'ctrip-retry-or-contact-support.json',
  'interaction-switches.json',
  'location-permission.json',
  'playback-policies.json',
  'raw-item-attributes.json',
  'smzdm-capsule.plist',
];

export const CONFIGURATION_DIRECTORY: string = 'example/configurations/';

/** Replaces each "exampleTitleKey" with a "title" read from the example's strings. */
function resolvingExampleTexts(value: Object): Object {
  if (Array.isArray(value)) {
    return (value as Object[]).map((item: Object) => resolvingExampleTexts(item));
  }
  if (value === null || typeof value !== 'object') {
    return value;
  }
  const dictionary = value as Record<string, Object>;
  const result: Record<string, Object> = {};
  Object.keys(dictionary).forEach((key: string) => {
    if (key !== 'exampleTitleKey') {
      result[key] = resolvingExampleTexts(dictionary[key]);
    }
  });
  const titleKey: Object | undefined = dictionary['exampleTitleKey'];
  if (typeof titleKey === 'string') {
    result['title'] = t(titleKey as string);
  }
  return result;
}

@Component
export struct ConfigurationPage {
  param: RouteParam = new RouteParam();
  @State placeholder: CYLPlaceholderStackViewModel = new CYLPlaceholderStackViewModel();
  /** Whether the file made a placeholder (a broken file shows its error instead). */
  @State hasPlaceholder: boolean = false;
  @State error: string = '';
  @State generation: number = 0;

  aboutToAppear(): void {
    this.reload();
  }

  /** Every action a configuration can name, each confirming the tap. */
  private actions(): Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> {
    const context = this.getUIContext();
    const handlers: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> = new Map();
    [CYLPlaceholderActions.Retry, CYLPlaceholderActions.ContactSupport, CYLPlaceholderActions.OpenSettings,
      CYLPlaceholderActions.GoShopping, CYLPlaceholderActions.Done, CYLPlaceholderActions.ChooseManually]
      .forEach((action: CYLPlaceholderAction) => {
        handlers.set(action, (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) => {
          const title = CYLPlaceholderScenarioCatalog.localizedTitleForAction(a) ?? a;
          showFeedback(context, t('CYLScenarioFormatActionTapped', title));
        });
      });
    return handlers;
  }

  /** Builds the placeholder from the file again ("Replay"); a broken file shows its error instead. */
  private reload(): void {
    let message = '';
    const onError = (reason: string) => {
      message = reason;
    };
    const file = this.param.value;
    const text = readRawText(this.getUIContext(), CONFIGURATION_DIRECTORY + file);
    let configuration = CYLPlaceholderConfiguration.parseText(text, file, onError);
    if (configuration !== null && file.endsWith('.json') && text.includes('exampleTitleKey')) {
      configuration = resolvingExampleTexts(configuration) as Record<string, Object>;
    }
    const made = configuration === null ? null :
      CYLPlaceholderStackViewModel.initWithConfiguration(configuration, this.actions(), onError);
    if (made !== null) {
      this.placeholder = made;
    }
    this.hasPlaceholder = made !== null;
    this.error = made === null ? (message.length > 0 ? message : 'The file cannot be read.') : '';
    this.generation++;
  }

  @Builder
  barItems() {
    Row() {
      BarButton(t('CYLScenarioActionShowFile'),
        () => push(Route.TextFile, RouteParam.of(CONFIGURATION_DIRECTORY + this.param.value, this.param.value)))
      BarButton(t('CYLScenarioActionReplay'), () => this.reload())
    }
    .height('100%')
  }

  @Builder
  navTitle() {
    NavTitle(this.param.value)
  }

  build() {
    NavDestination() {
      Column() {
        if (this.hasPlaceholder) {
          // Keyed by the generation: "Replay" makes the views (and their animations) again.
          ForEach([this.generation], (generation: number) => {
            CYLPlaceholderStackView({ model: this.placeholder })
          }, (generation: number) => 'placeholder-' + generation)
        } else {
          Text(this.error)
            .fontSize(15)
            .fontColor(UiColor.destructive)
            .textAlign(TextAlign.Center)
            .padding({ left: 24, right: 24, top: 40 })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)
    }
    .title(this.navTitle)
    .menus(this.barItems)
    .backgroundColor(Color.White)
  }
}
