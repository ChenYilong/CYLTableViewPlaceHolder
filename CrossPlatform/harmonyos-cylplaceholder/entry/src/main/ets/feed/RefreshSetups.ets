// The setups of CYLRefreshIconListViewController (the mini program's pages/refresh-icons/setups.js): each row's
// header / footer and icons per state. Used by the list and by the demo page; also makes the controls.
import {
  CYLRefreshAnimationHeaderModel,
  CYLRefreshAutoAnimationFooterModel,
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshBackAnimationFooterModel,
  CYLRefreshBackNormalFooterModel,
  CYLRefreshFooterModel,
  CYLRefreshHeaderModel,
  CYLRefreshIconSize,
  CYLRefreshNormalHeaderModel,
  CYLRefreshState
} from 'cylplaceholder';

/** Where an animation file lives: the library's rawfile, else the example's copy of the core bundle. */
export function animationPath(file: string): string {
  if (file === 'CYLRefreshActivity.gif' || file === 'CYLRefreshDoneCircle.json' ||
    file === 'CYLPlaceholderRefresh.json' || file === 'CYLPlaceholderProgress.pag') {
    return 'cylplaceholder/animations/' + file;
  }
  return 'example/core-animations/' + file;
}

export class RefreshIcon {
  state: CYLRefreshState;
  file: string;
  width: number;
  height: number;

  constructor(state: CYLRefreshState, file: string, width: number, height: number = -1) {
    this.state = state;
    this.file = file;
    this.width = width;
    this.height = height < 0 ? width : height;
  }
}

export class RefreshSetup {
  header: string = 'normal'; // 'normal' | 'animation'
  footer: string = 'auto'; // 'auto' | 'back'
  headerIcons: RefreshIcon[] = [];
  footerIcons: RefreshIcon[] = [];

  static of(header: string, footer: string, headerIcons: RefreshIcon[], footerIcons: RefreshIcon[]): RefreshSetup {
    const s = new RefreshSetup();
    s.header = header;
    s.footer = footer;
    s.headerIcons = headerIcons;
    s.footerIcons = footerIcons;
    return s;
  }

  makeHeader(): CYLRefreshHeaderModel {
    if (this.header !== 'animation') {
      return new CYLRefreshNormalHeaderModel();
    }
    const h = new CYLRefreshAnimationHeaderModel();
    this.headerIcons.forEach((i: RefreshIcon) => h.setIconAnimationFilePath(animationPath(i.file),
      new CYLRefreshIconSize(i.width, i.height), i.state));
    return h;
  }

  makeFooter(): CYLRefreshFooterModel {
    if (this.footerIcons.length === 0) {
      return this.footer === 'back' ? new CYLRefreshBackNormalFooterModel() : new CYLRefreshAutoNormalFooterModel();
    }
    if (this.footer === 'back') {
      const f = new CYLRefreshBackAnimationFooterModel();
      this.footerIcons.forEach((i: RefreshIcon) => f.setIconAnimationFilePath(animationPath(i.file),
        new CYLRefreshIconSize(i.width, i.height), i.state));
      return f;
    }
    const f = new CYLRefreshAutoAnimationFooterModel();
    this.footerIcons.forEach((i: RefreshIcon) => f.setIconAnimationFilePath(animationPath(i.file),
      new CYLRefreshIconSize(i.width, i.height), i.state));
    return f;
  }
}

export class RefreshIconRow {
  id: string;
  title: string; // a literal file name, or an example string key when titleKey is true
  titleKey: boolean;
  subtitle: string;
  setup: RefreshSetup;

  constructor(id: string, title: string, titleKey: boolean, subtitle: string, setup: RefreshSetup) {
    this.id = id;
    this.title = title;
    this.titleKey = titleKey;
    this.subtitle = subtitle;
    this.setup = setup;
  }
}

export class RefreshIconSection {
  title: string;
  titleKey: boolean;
  rows: RefreshIconRow[];

  constructor(title: string, titleKey: boolean, rows: RefreshIconRow[]) {
    this.title = title;
    this.titleKey = titleKey;
    this.rows = rows;
  }
}

const I = CYLRefreshState.Idle;
const P = CYLRefreshState.Pulling;
const R = CYLRefreshState.Refreshing;
const N = CYLRefreshState.NoMoreData;
const BUNDLED: string = 'setIconAnimation(bundled:size:for:)';

const GIFS: string[] = ['CYLRefreshActivity', 'CYLRefreshArrows', 'CYLRefreshPetals', 'CYLRefreshRing',
  'CYLRefreshThrobber'];
const LOTTIES: string[] = ['CYLPlaceholderRefresh', 'CYLRefreshArc', 'CYLRefreshClockwise',
  'CYLRefreshCounterClockwise', 'CYLRefreshCycle', 'CYLRefreshDone', 'CYLRefreshDoneCircle', 'CYLRefreshDonePop',
  'CYLRefreshDots', 'CYLRefreshDotsPulse', 'CYLRefreshGradientSpinner', 'CYLRefreshLoadMore',
  'CYLRefreshMaterialSpinner', 'CYLRefreshMoreDots', 'CYLRefreshPullArrow', 'CYLRefreshPullCircle',
  'CYLRefreshSpinnerRing'];

/** One file for idle covers every state (setIconAnimation(bundled:size:for: .idle)); sizes of the iOS list. */
function one(file: string): RefreshSetup {
  let w = 32;
  let h = 32;
  if (/Dots|DotsPulse|MoreDots/.test(file)) {
    w = 40;
    h = 24;
  } else if (/Throbber/.test(file)) {
    w = 20;
    h = 20;
  } else if (/MaterialSpinner|DonePop|Progress/.test(file)) {
    w = 36;
    h = 36;
  }
  return RefreshSetup.of('animation', 'auto', [new RefreshIcon(I, file, w, h)],
    [new RefreshIcon(I, file, w, h), new RefreshIcon(R, file, w, h)]);
}

function fileRow(file: string): RefreshIconRow {
  return new RefreshIconRow(file.replace(/\.[^.]+$/, ''), file, false, BUNDLED, one(file));
}

/** Sections of the list, in the iOS order. */
export const REFRESH_ICON_SECTIONS: RefreshIconSection[] = [
  new RefreshIconSection('CYLScenarioSectionRefreshArrow', true, [
    new RefreshIconRow('arrowAuto', 'CYLScenarioRefreshArrowAuto', true,
      'CYLRefreshNormalHeader · CYLRefreshAutoNormalFooter', RefreshSetup.of('normal', 'auto', [], [])),
    new RefreshIconRow('arrowBack', 'CYLScenarioRefreshArrowBack', true,
      'CYLRefreshNormalHeader · CYLRefreshBackNormalFooter', RefreshSetup.of('normal', 'back', [], [])),
  ]),
  new RefreshIconSection('GIF · Core', false, GIFS.map((n: string) => fileRow(n + '.gif'))),
  new RefreshIconSection('Lottie · CYLTableViewPlaceHolder/LottieSwift', false,
    LOTTIES.map((n: string) => fileRow(n + '.json'))),
  new RefreshIconSection('PAG · CYLTableViewPlaceHolder/PAG', false, [fileRow('CYLPlaceholderProgress.pag')]),
  new RefreshIconSection('Rive · CYLTableViewPlaceHolder/Rive', false, [fileRow('CYLRefreshIcon.riv')]),
  new RefreshIconSection('CYLScenarioSectionRefreshInit', true, [
    new RefreshIconRow('byImages', 'CYLScenarioRefreshByImages', true, 'setAnimationImages(_:duration:for:)',
      RefreshSetup.of('animation', 'auto', [new RefreshIcon(I, 'CYLRefreshArrows.gif', 40),
        new RefreshIcon(P, 'CYLRefreshArrows.gif', 40), new RefreshIcon(R, 'CYLRefreshRing.gif', 40)],
        [new RefreshIcon(R, 'CYLRefreshRing.gif', 40)])),
    new RefreshIconRow('byStates', 'CYLScenarioRefreshByStates', true, BUNDLED,
      RefreshSetup.of('animation', 'auto', [new RefreshIcon(I, 'CYLRefreshPullCircle.json', 28),
        new RefreshIcon(P, 'CYLRefreshCounterClockwise.json', 28), new RefreshIcon(R, 'CYLPlaceholderProgress.pag', 32)],
        [new RefreshIcon(R, 'CYLRefreshActivity.gif', 28)])),
    new RefreshIconRow('backFooter', 'CYLScenarioRefreshBackFooter', true, 'CYLRefreshBackAnimationFooter',
      RefreshSetup.of('animation', 'back', [new RefreshIcon(I, 'CYLRefreshCycle.json', 28)],
        [new RefreshIcon(I, 'CYLRefreshLoadMore.json', 28), new RefreshIcon(P, 'CYLRefreshClockwise.json', 28),
          new RefreshIcon(R, 'CYLRefreshPetals.gif', 28)])),
    new RefreshIconRow('byFilePath', 'CYLScenarioRefreshByFilePath', true, 'setIconAnimation(filePath:size:for:)',
      RefreshSetup.of('animation', 'auto', [new RefreshIcon(I, 'CYLRefreshArrows.gif', 32),
        new RefreshIcon(R, 'CYLRefreshGradientSpinner.json', 36)],
        [new RefreshIcon(R, 'CYLRefreshGradientSpinner.json', 32)])),
    new RefreshIconRow('byAttributes', 'CYLScenarioRefreshByAttributes', true, 'setIconAnimation(attributes:for:)',
      RefreshSetup.of('animation', 'auto', [new RefreshIcon(I, 'CYLRefreshIcon.riv', 32)],
        [new RefreshIcon(R, 'CYLRefreshIcon.riv', 32)])),
    new RefreshIconRow('byConfiguration', 'CYLScenarioRefreshByConfiguration', true, 'RefreshIcons/refresh-icons.json',
      RefreshSetup.of('animation', 'auto', [new RefreshIcon(I, 'CYLRefreshPullArrow.json', 28),
        new RefreshIcon(P, 'CYLRefreshClockwise.json', 28), new RefreshIcon(R, 'CYLRefreshMaterialSpinner.json', 36)],
        [new RefreshIcon(I, 'CYLRefreshLoadMore.json', 28), new RefreshIcon(R, 'CYLRefreshIcon.riv', 32),
          new RefreshIcon(N, 'CYLRefreshDoneCircle.json', 28)])),
    new RefreshIconRow('gifNames', 'CYLScenarioRefreshGifNames', true, 'CYLRefreshGifHeader · setImages(_:for:)',
      RefreshSetup.of('animation', 'auto', [new RefreshIcon(I, 'CYLRefreshArrows.gif', 40),
        new RefreshIcon(R, 'CYLRefreshArrows.gif', 40)], [new RefreshIcon(R, 'CYLRefreshThrobber.gif', 20)])),
  ]),
];

export function refreshIconRowFor(id: string): RefreshIconRow | null {
  for (const s of REFRESH_ICON_SECTIONS) {
    for (const r of s.rows) {
      if (r.id === id) {
        return r;
      }
    }
  }
  return null;
}
