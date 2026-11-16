// CYLSupportViewController: the page "Contact support" opens, a stack of the support animation (fallback icon: help,
// 120 x 120) titled "Contact support" and the example's hint text.
import { CYLPlaceholderComponent, CYLPlaceholderStackView, CYLPlaceholderStackViewModel,
  CYLPlaceholderStyle } from 'cylplaceholder';
import { t } from '../common/L10n';
import { NavTitle } from '../common/Ui';

@Component
export struct SupportPage {
  @State placeholder: CYLPlaceholderStackViewModel = SupportPage.make();

  static make(): CYLPlaceholderStackViewModel {
    const m = CYLPlaceholderStackViewModel.initWithComponents([
      CYLPlaceholderComponent.componentWithBundledAnimation('CYLPlaceholderContactSupport.json',
        CYLPlaceholderStyle.Help, t('CYLScenarioSupportTitle'), 120, null),
      CYLPlaceholderComponent.hintComponentWithText(t('CYLScenarioSupportText')),
    ]);
    m.accessibilityIdentifier = 'supportPage';
    return m;
  }

  @Builder
  navTitle() {
    NavTitle(t('CYLScenarioSupportTitle'))
  }

  build() {
    NavDestination() {
      CYLPlaceholderStackView({ model: this.placeholder })
    }
    .title(this.navTitle)
    .backgroundColor(Color.White)
  }
}
