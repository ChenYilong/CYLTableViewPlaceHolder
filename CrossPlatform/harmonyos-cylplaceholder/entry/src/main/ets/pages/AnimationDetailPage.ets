// CYLAnimationDetailViewController: one animation in a CYLAnimatedItemView (180 x 180 icon above its title, the
// fallback style image until the animation is ready), titled with its name without "CYLPlaceholder" /
// "CYLScenarioExample". An icon and a title are all the page shows, so it uses the item view, not a
// CYLPlaceholderStackView (kept for what the item cannot draw: several components, buttons, long wrapping texts); the
// core's CYLPlaceholderAnimatedItem plays the model's animation in it. Under it, the
// playback controls of docs/Example-Animation-Playback.md: "Play all" (and the bar's "Replay") restart from
// progress 0, the speed slider and the loop switch apply live. Spinners loop by default, one-shot demos play once
// and rest on their last frame.
import { CYLAnimatedItemAxis, CYLAnimatedItemView, CYLPlaceholderAnimatedItem, CYLPlaceholderAnimatedItemBuilder,
  CYLPlaceholderComponent, CYLPlaceholderStyle, CYLPlaceholderViewModel } from 'cylplaceholder';
import { effectiveLanguage, t } from '../common/L10n';
import { PlaybackControls, loopsByDefault, repeatCountForLoop } from '../common/Playback';
import { RouteParam } from '../common/Routes';
import { BarButton } from '../common/Ui';
import { AnimationFile, animationSections } from './AnimationsTab';

@Component
export struct AnimationDetailPage {
  param: RouteParam = new RouteParam();
  /** The animation's model: its player, speed and repeat count; drawn by the CYLAnimatedItemView below. */
  @State item: CYLPlaceholderViewModel = new CYLPlaceholderViewModel();
  @State itemTitle: string = '';
  @State animationURL: string = '';
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
    this.item = CYLPlaceholderViewModel.initWithComponent(
      CYLPlaceholderComponent.componentWithBundledAnimation(file.path, CYLPlaceholderStyle.Image, title, 180, null));
    this.itemTitle = title;
    this.loop = loopsByDefault(file.name);
    this.item.animationRepeatCount = repeatCountForLoop(this.loop);
    CYLPlaceholderAnimatedItem.attach(this.item);
    this.animationURL = CYLPlaceholderAnimatedItem.animationURL(this.item);
  }

  aboutToDisappear(): void {
    CYLPlaceholderAnimatedItem.detach(this.item);
  }

  /** "Play all" / "Replay": from progress 0 with the current speed and loop setting. */
  private playAll(): void {
    this.item.playPlaceholderAnimation();
  }

  private applySpeed(speed: number): void {
    this.item.setPlaceholderAnimationSpeed(speed);
  }

  private applyLoop(loop: boolean): void {
    this.item.animationRepeatCount = repeatCountForLoop(loop);
    if (loop) {
      // A one-shot animation that already finished starts again so the switch shows its effect at once.
      this.playAll();
    }
  }

  /** The file name on one line, cut in the middle so the extension stays visible. */
  @Builder
  titleView() {
    Text(this.fileName)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .ellipsisMode(EllipsisMode.CENTER)
      .height('100%')
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
        Column() {
          CYLAnimatedItemView({
            itemTitle: this.itemTitle,
            image: this.item.currentImage !== null ? this.item.currentImage as ResourceStr : '',
            animationUrl: this.animationURL,
            axis: CYLAnimatedItemAxis.Vertical,
            iconSize: 180,
            spacing: 8,
            titleFontSize: this.item.currentTitleFont,
            titleColor: this.item.currentTitleColor,
            animationBuilder: CYLPlaceholderAnimatedItemBuilder
          })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
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
    .title(this.titleView)
    .menus(this.barItems)
    .backgroundColor(Color.White)
  }
}
