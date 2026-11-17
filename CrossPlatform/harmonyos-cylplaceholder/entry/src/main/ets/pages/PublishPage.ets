// CYLPublishViewController (the plus button's page, presented modally with a Close button on iOS): the Uploading
// scenario, then Success after 1.5 s; Done closes it. Here a NavDestination whose back button is the Close button.
import { CYLPlaceholderAction, CYLPlaceholderActionHandler, CYLPlaceholderActions, CYLPlaceholderScenario,
  CYLPlaceholderStackView, CYLPlaceholderStackViewModel } from 'cylplaceholder';
import { t } from '../common/L10n';
import { pop } from '../common/Routes';

import { NavTitle } from '../common/Ui';
import { UiColor } from '../common/Ui';

@Component
export struct PublishPage {
  @State placeholder: CYLPlaceholderStackViewModel =
    CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.Uploading);
  private timer: number = -1;

  aboutToAppear(): void {
    this.timer = setTimeout(() => {
      const actions: Map<CYLPlaceholderAction, CYLPlaceholderActionHandler> = new Map();
      actions.set(CYLPlaceholderActions.Done, (p: CYLPlaceholderStackViewModel, a: CYLPlaceholderAction) => pop());
      this.placeholder = CYLPlaceholderStackViewModel.initWithScenario(CYLPlaceholderScenario.Success, actions);
    }, 1500);
  }

  aboutToDisappear(): void {
    clearTimeout(this.timer);
  }


  @Builder
  navTitle() {
    NavTitle(t('CYLScenarioActionPublish'))
  }

  build() {
    NavDestination() {
      CYLPlaceholderStackView({ model: this.placeholder })
    }
    .title(this.navTitle)
    .backgroundColor(UiColor.background)
  }
}
