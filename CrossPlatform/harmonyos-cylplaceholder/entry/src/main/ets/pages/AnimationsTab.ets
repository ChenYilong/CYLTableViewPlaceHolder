// CYLAnimationListViewController: every animation of the core bundle grouped by engine (Lottie, PAG, Rive, GIF), then
// the example bundle's own files (rawfile/example/animations), in an insetGrouped table with each file's size. The
// right bar item "Sources" shows NOTICE.animations (source, commit, license, SHA-256 of each file).
// The core bundle's list is the iOS one (CYLPlaceholderView.bundledAnimationFileNames()); a core file the library's
// rawfile does not ship (the refresh icons) is played from rawfile/example/core-animations.
import { CYLPlaceholderStyle, CYLPlaceholderView, CYLPlaceholderViewModel } from 'cylplaceholder';
import { t } from '../common/L10n';
import { rawFileList, rawFileSize } from '../common/RawFile';
import { Route, RouteParam, push } from '../common/Routes';
import { InsetTable, LargeTitle, TableRow, TableSection, UiColor, formatBytes } from '../common/Ui';

const CORE_FILES: string[] = [
  'CYLPlaceholderBluetoothPermission.json', 'CYLPlaceholderCalendarPermission.json',
  'CYLPlaceholderCameraPermission.json', 'CYLPlaceholderCelebrate.json', 'CYLPlaceholderCloudOff.json',
  'CYLPlaceholderContactSupport.json', 'CYLPlaceholderContactsPermission.json', 'CYLPlaceholderEmpty.json',
  'CYLPlaceholderEmptyCart.json', 'CYLPlaceholderLoadFailed.json', 'CYLPlaceholderLoading.json',
  'CYLPlaceholderLoadingInfinity.json', 'CYLPlaceholderLocation.json', 'CYLPlaceholderLocationPermission.json',
  'CYLPlaceholderMicrophonePermission.json', 'CYLPlaceholderNoDrafts.json', 'CYLPlaceholderNoFavorites.json',
  'CYLPlaceholderNoInternet.json', 'CYLPlaceholderNoMessages.json', 'CYLPlaceholderNoNotifications.json',
  'CYLPlaceholderNoOrders.json', 'CYLPlaceholderNoPermission.json', 'CYLPlaceholderNoResults.json',
  'CYLPlaceholderNotificationPermission.json', 'CYLPlaceholderPhotoLibraryPermission.json',
  'CYLPlaceholderRefresh.json', 'CYLPlaceholderSad.json', 'CYLPlaceholderServerError.json',
  'CYLPlaceholderSettings.json', 'CYLPlaceholderSuccess.json', 'CYLPlaceholderTapHint.json', 'CYLRefreshArc.json',
  'CYLRefreshClockwise.json', 'CYLRefreshCounterClockwise.json', 'CYLRefreshCycle.json', 'CYLRefreshDone.json',
  'CYLRefreshDoneCircle.json', 'CYLRefreshDonePop.json', 'CYLRefreshDots.json', 'CYLRefreshDotsPulse.json',
  'CYLRefreshGradientSpinner.json', 'CYLRefreshLoadMore.json', 'CYLRefreshMaterialSpinner.json',
  'CYLRefreshMoreDots.json', 'CYLRefreshPullArrow.json', 'CYLRefreshPullCircle.json', 'CYLRefreshSpinnerRing.json',
  'CYLPlaceholderLoading.pag', 'CYLPlaceholderNoFavorites.pag', 'CYLPlaceholderProgress.pag',
  'CYLPlaceholderPullHint.pag', 'CYLPlaceholderLoading.riv', 'CYLPlaceholderPullToRefresh.riv',
  'CYLPlaceholderSuccess.riv', 'CYLRefreshIcon.riv', 'CYLPlaceholderNoFavorites.gif', 'CYLPlaceholderUploading.gif',
  'CYLRefreshActivity.gif', 'CYLRefreshArrows.gif', 'CYLRefreshPetals.gif', 'CYLRefreshRing.gif',
  'CYLRefreshThrobber.gif',
];

const ENGINES: string[][] = [
  ['json', 'Lottie · CYLTableViewPlaceHolder/LottieSwift'],
  ['pag', 'PAG · CYLTableViewPlaceHolder/PAG'],
  ['riv', 'Rive · CYLTableViewPlaceHolder/Rive'],
  ['gif', 'GIF · Core'],
];

export const LIBRARY_ANIMATIONS: string = 'cylplaceholder/animations/';
export const CORE_ANIMATIONS: string = 'example/core-animations/';
export const EXAMPLE_ANIMATIONS: string = 'example/animations/';
export const NOTICE_PATH: string = 'cylplaceholder/animations/NOTICE.animations';

/** One file of the list: its name, the rawfile path played and whether it is in the core bundle. */
export class AnimationFile {
  name: string;
  path: string;
  core: boolean;
  bytes: number;

  constructor(name: string, path: string, core: boolean, bytes: number) {
    this.name = name;
    this.path = path;
    this.core = core;
    this.bytes = bytes;
  }
}

export class AnimationSection {
  title: string;
  files: AnimationFile[];

  constructor(title: string, files: AnimationFile[]) {
    this.title = title;
    this.files = files;
  }
}

function extensionOf(name: string): string {
  const dot = name.lastIndexOf('.');
  return dot < 0 ? '' : name.substring(dot + 1);
}

/** The sections: the core bundle by engine, then the example bundle (empty sections are left out). */
export function animationSections(context: UIContext): AnimationSection[] {
  const sections: AnimationSection[] = [];
  ENGINES.forEach((engine: string[]) => {
    const files: AnimationFile[] = [];
    CORE_FILES.filter((name: string) => extensionOf(name) === engine[0]).sort().forEach((name: string) => {
      let bytes = rawFileSize(context, LIBRARY_ANIMATIONS + name);
      let path = name;
      if (bytes === 0) {
        path = CORE_ANIMATIONS + name;
        bytes = rawFileSize(context, path);
      }
      files.push(new AnimationFile(name, path, true, bytes));
    });
    if (files.length > 0) {
      sections.push(new AnimationSection(engine[1], files));
    }
  });
  // The example's own animations: no placeholder meaning (a mascot, a scene, widget demos), so they live in the
  // example bundle, not in the core bundle.
  const exampleFiles = rawFileList(context, 'example/animations')
    .filter((name: string) => ['json', 'pag', 'riv', 'svga', 'gif'].includes(extensionOf(name)))
    .map((name: string) => new AnimationFile(name, EXAMPLE_ANIMATIONS + name, false,
      rawFileSize(context, EXAMPLE_ANIMATIONS + name)));
  if (exampleFiles.length > 0) {
    sections.push(new AnimationSection('CYLScenarioExample.bundle/Animations', exampleFiles));
  }
  return sections;
}

@Component
export struct AnimationsTab {
  @State sections: TableSection[] = [];
  @State empty: CYLPlaceholderViewModel = new CYLPlaceholderViewModel();
  private files: AnimationSection[] = [];

  aboutToAppear(): void {
    this.files = animationSections(this.getUIContext());
    this.sections = this.files.map((s: AnimationSection) => new TableSection(s.title,
      s.files.map((f: AnimationFile) => new TableRow(f.name, f.name, formatBytes(f.bytes)))));
    // The empty state of this list, should the bundle be missing.
    this.empty = CYLPlaceholderViewModel.initWithStyleText(CYLPlaceholderStyle.FolderOff, t('CYLScenarioTextNoAnimations'));
  }

  @Builder
  header() {
    Column() {
      Row() {
        Text(t('CYLScenarioRiveInputsTitle'))
          .id('riveInputsButton')
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .fontSize(17)
          .fontColor(UiColor.teal)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .onClick(() => push(Route.RiveInputs))
        Blank()
        Text(t('CYLScenarioActionSources'))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .fontSize(17)
          .fontColor(UiColor.teal)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .onClick(() => push(Route.TextFile, RouteParam.of(NOTICE_PATH, 'NOTICE.animations')))
      }
      .width('100%')
      .padding({ left: 8, right: 8 })
      LargeTitle(t('CYLScenarioTabAnimations'))
    }
  }

  build() {
    Stack() {
      InsetTable({
        sections: this.sections,
        header: () => {
          this.header()
        },
        onRow: (section: number, row: number) => push(Route.AnimationDetail, RouteParam.at(section, row))
      })
      if (this.sections.length === 0) {
        CYLPlaceholderView({ model: this.empty })
      }
    }
    .width('100%')
    .height('100%')
  }
}
