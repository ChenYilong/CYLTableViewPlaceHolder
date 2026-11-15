// CYLAnimationDetailViewController: one animation as the reserved component of a CYLPlaceholderStackView (180 x 180,
// fallback style image), titled with its name without "CYLPlaceholder" / "CYLScenarioExample"; it replays every
// 4 seconds while visible and on "Replay".
import { CYLPlaceholderComponent, CYLPlaceholderStackView, CYLPlaceholderStackViewModel,
  CYLPlaceholderStyle } from 'cylplaceholder';
import { t } from '../common/L10n';
import { RouteParam } from '../common/Routes';
import { BarButton } from '../common/Ui';
import { AnimationFile, animationSections } from './AnimationsTab';

@Component
export struct AnimationDetailPage {
  param: RouteParam = new RouteParam();
  @State placeholder: CYLPlaceholderStackViewModel = new CYLPlaceholderStackViewModel();
  @State fileName: string = '';
  private timer: number = -1;

  aboutToAppear(): void {
    const sections = animationSections(this.getUIContext());
    if (this.param.section >= sections.length || this.param.row >= sections[this.param.section].files.length) {
      return;
    }
    const file: AnimationFile = sections[this.param.section].files[this.param.row];
    this.fileName = file.name;
    const dot = file.name.lastIndexOf('.');
    const title = (dot < 0 ? file.name : file.name.substring(0, dot))
      .replace('CYLPlaceholder', '').replace('CYLScenarioExample', '');
    // A core file plays by its bundled name (or its rawfile path when the library does not ship it); an example file
    // by its rawfile path.
    this.placeholder = CYLPlaceholderStackViewModel.initWithComponents([
      CYLPlaceholderComponent.componentWithBundledAnimation(file.path, CYLPlaceholderStyle.Image, title, 180, null),
    ]);
  }

  aboutToDisappear(): void {
    clearInterval(this.timer);
  }

  private replay(): void {
    if (this.placeholder.entries.length > 0) {
      this.placeholder.placeholderView.playPlaceholderAnimation();
    }
  }

  @Builder
  barItems() {
    Row() {
      BarButton(t('CYLScenarioActionReplay'), () => this.replay())
    }
    .height('100%')
  }

  build() {
    NavDestination() {
      CYLPlaceholderStackView({ model: this.placeholder })
    }
    .title(this.fileName)
    .menus(this.barItems)
    .backgroundColor(Color.White)
    .onShown(() => {
      // Placeholder animations play once when they appear; replay them so the demo keeps moving.
      clearInterval(this.timer);
      this.timer = setInterval(() => this.replay(), 4000);
    })
    .onHidden(() => clearInterval(this.timer))
  }
}
