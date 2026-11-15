// A temporary example: every scenario of CYLPlaceholderScenarioCatalog; tapping one shows its CYLPlaceholderStackView.
// (A later step builds the 1:1 port of the iOS example.)
import {
  CYLPlaceholderAction,
  CYLPlaceholderActionHandler,
  CYLPlaceholderLocalization,
  CYLPlaceholderScenario,
  CYLPlaceholderScenarioCatalog,
  CYLPlaceholderStackView,
  CYLPlaceholderStackViewModel,
  CYLPlaceholderVersion
} from 'cylplaceholder';

@Entry
@Component
struct Index {
  @State scenarios: CYLPlaceholderScenario[] = CYLPlaceholderScenarioCatalog.allScenarios;
  @State showing: boolean = false;
  @State placeholder: CYLPlaceholderStackViewModel = new CYLPlaceholderStackViewModel();
  @State language: string = CYLPlaceholderLocalization.effectiveLanguage;

  private open(scenario: CYLPlaceholderScenario): void {
    const toast: CYLPlaceholderActionHandler = (p: CYLPlaceholderStackViewModel, action: CYLPlaceholderAction) => {
      this.getUIContext().getPromptAction().showToast({ message: action });
    };
    const actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> = new Map();
    ['CYLPlaceholderActionRetry', 'CYLPlaceholderActionContactSupport', 'CYLPlaceholderActionOpenSettings',
      'CYLPlaceholderActionGoShopping', 'CYLPlaceholderActionDone', 'CYLPlaceholderActionChooseManually']
      .forEach((a: string) => actions.set(a, toast));
    this.placeholder = CYLPlaceholderStackViewModel.initWithScenario(scenario, actions);
    this.showing = true;
  }

  private nextLanguage(): void {
    const all = CYLPlaceholderLocalization.supportedLanguages;
    CYLPlaceholderLocalization.language = all[(all.indexOf(this.language) + 1) % all.length];
    this.language = CYLPlaceholderLocalization.effectiveLanguage;
    this.scenarios = CYLPlaceholderScenarioCatalog.allScenarios;
  }

  build() {
    Column() {
      Row() {
        Text(this.showing ? '‹ Back' : 'CYLPlaceholder ' + CYLPlaceholderVersion)
          .fontSize(17)
          .fontColor(this.showing ? '#007AFF' : '#000000')
          .onClick(() => {
            this.showing = false;
          })
        Blank()
        Text(this.language).fontSize(15).fontColor('#007AFF').onClick(() => this.nextLanguage())
      }
      .width('100%')
      .padding(16)

      if (this.showing) {
        CYLPlaceholderStackView({ model: this.placeholder }).layoutWeight(1)
      } else {
        List() {
          ForEach(this.scenarios, (scenario: CYLPlaceholderScenario, index: number) => {
            ListItem() {
              Row() {
                Text((index + 1) + '. ' + CYLPlaceholderScenarioCatalog.localizedNameForScenario(scenario))
                  .fontSize(16)
                Blank()
                Text(CYLPlaceholderScenarioCatalog.nameForScenario(scenario)).fontSize(12).fontColor('#8E8E93')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .onClick(() => this.open(scenario))
            }
          }, (scenario: CYLPlaceholderScenario) => this.language + scenario.toString())
        }
        .divider({ strokeWidth: 0.5, color: '#E5E5EA', startMargin: 16 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
  }
}
