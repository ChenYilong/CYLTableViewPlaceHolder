// CYLAnimationDetailViewController: one animation as the reserved component of a CYLPlaceholderStackView (180 x 180,
// fallback style image), titled with its name without "CYLPlaceholder" / "CYLScenarioExample". Under it, the
// playback controls of docs/Example-Animation-Playback.md: "Play all" (and the bar's "Replay") restart from
// progress 0, the speed slider and the loop switch apply live. Spinners loop by default, one-shot demos play once
// and rest on their last frame.
import { CYLPlaceholderComponent, CYLPlaceholderStackView, CYLPlaceholderStackViewModel,
  CYLPlaceholderStyle } from 'cylplaceholder';
import { effectiveLanguage, t } from '../common/L10n';
import { PlaybackControls, loopsByDefault, repeatCountForLoop } from '../common/Playback';
import { RouteParam } from '../common/Routes';
import { BarButton } from '../common/Ui';
import { AnimationFile, animationSections } from './AnimationsTab';

@Component
export struct AnimationDetailPage {
  param: RouteParam = new RouteParam();
  @State placeholder: CYLPlaceholderStackViewModel = new CYLPlaceholderStackViewModel();
  @State fileName: string = '';
  @State speed: number = 1;
  @State loop: boolean = false;

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
    this.loop = loopsByDefault(file.name);
    if (this.placeholder.entries.length > 0) {
      this.placeholder.placeholderView.animationRepeatCount = repeatCountForLoop(this.loop);
    }
  }

  /** "Play all" / "Replay": from progress 0 with the current speed and loop setting. */
  private playAll(): void {
    if (this.placeholder.entries.length > 0) {
      this.placeholder.placeholderView.playPlaceholderAnimation();
    }
  }

  private applySpeed(speed: number): void {
    if (this.placeholder.entries.length > 0) {
      this.placeholder.placeholderView.setPlaceholderAnimationSpeed(speed);
    }
  }

  private applyLoop(loop: boolean): void {
    if (this.placeholder.entries.length === 0) {
      return;
    }
    this.placeholder.placeholderView.animationRepeatCount = repeatCountForLoop(loop);
    if (loop) {
      // A one-shot animation that already finished starts again so the switch shows its effect at once.
      this.playAll();
    }
  }

  @Builder
  barItems() {
    Row() {
      BarButton(t('CYLScenarioActionReplay'), () => this.playAll())
    }
    .height('100%')
  }

  build() {
    NavDestination() {
      Column() {
        CYLPlaceholderStackView({ model: this.placeholder })
          .layoutWeight(1)
        PlaybackControls({
          language: effectiveLanguage(),
          speed: $speed,
          loop: $loop,
          onPlayAll: () => this.playAll(),
          onSpeed: (speed: number) => this.applySpeed(speed),
          onLoop: (loop: boolean) => this.applyLoop(loop)
        })
      }
      .width('100%')
      .height('100%')
    }
    .title(this.fileName)
    .menus(this.barItems)
    .backgroundColor(Color.White)
  }
}
