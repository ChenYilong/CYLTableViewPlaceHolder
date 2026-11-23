// The setups of CYLRefreshIconListViewController (Examples/Example-Scenarios/Sources/CYLRefreshIconListViewController
// .swift): each row's header / footer and icons per state, with the same APIs as iOS. Used by the list, the demo page
// and the Feed tab. The icons are drawn by the library (CYLRefreshIconView.placeholderView: GIF, Lottie, PAG, Rive).
import {
  CYLRefreshAnimationHeaderModel,
  CYLRefreshAutoAnimationFooterModel,
  CYLRefreshAutoGifFooterModel,
  CYLRefreshAutoNormalFooterModel,
  CYLRefreshBackAnimationFooterModel,
  CYLRefreshBackNormalFooterModel,
  CYLRefreshFooterModel,
  CYLRefreshGifHeaderModel,
  CYLRefreshHeaderModel,
  CYLRefreshIconAnimating,
  CYLRefreshIconAttributes,
  CYLRefreshIconSize,
  CYLRefreshNormalHeaderModel,
  CYLRefreshState
} from 'cylplaceholder';
import { readRawText } from '../common/RawFile';

/** Where an animation file lives: the library's rawfile, else the example's copy of the core bundle. */
export function animationPath(file: string): string {
  // The example's SVGA files (CYLTabBarController's samples, rawfile example/animations, NOTICE.animations).
  if (file.endsWith('.svga')) {
    return 'example/animations/' + file;
  }
  if (file === 'CYLRefreshActivity.gif' || file === 'CYLRefreshDoneCircle.json' ||
    file === 'CYLPlaceholderRefresh.json' || file === 'CYLPlaceholderProgress.pag') {
    return 'cylplaceholder/animations/' + file;
  }
  return 'example/core-animations/' + file;
}

/**
 * The frames of a bundled refresh GIF for the image-sequence API (iOS `CYLRefreshFrames.images(ofBundledGIF:)`),
 * extracted to rawfile/example/refreshframes ($rawfile takes literals only).
 */
export class RefreshFrames {
  static arrows(): ResourceStr[] {
    return [
      $rawfile('example/refreshframes/CYLRefreshArrows_00.png'), $rawfile('example/refreshframes/CYLRefreshArrows_01.png'),
      $rawfile('example/refreshframes/CYLRefreshArrows_02.png'), $rawfile('example/refreshframes/CYLRefreshArrows_03.png'),
      $rawfile('example/refreshframes/CYLRefreshArrows_04.png'), $rawfile('example/refreshframes/CYLRefreshArrows_05.png'),
      $rawfile('example/refreshframes/CYLRefreshArrows_06.png'), $rawfile('example/refreshframes/CYLRefreshArrows_07.png')
    ];
  }

  static ring(): ResourceStr[] {
    return [
      $rawfile('example/refreshframes/CYLRefreshRing_00.png'), $rawfile('example/refreshframes/CYLRefreshRing_01.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_02.png'), $rawfile('example/refreshframes/CYLRefreshRing_03.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_04.png'), $rawfile('example/refreshframes/CYLRefreshRing_05.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_06.png'), $rawfile('example/refreshframes/CYLRefreshRing_07.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_08.png'), $rawfile('example/refreshframes/CYLRefreshRing_09.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_10.png'), $rawfile('example/refreshframes/CYLRefreshRing_11.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_12.png'), $rawfile('example/refreshframes/CYLRefreshRing_13.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_14.png'), $rawfile('example/refreshframes/CYLRefreshRing_15.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_16.png'), $rawfile('example/refreshframes/CYLRefreshRing_17.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_18.png'), $rawfile('example/refreshframes/CYLRefreshRing_19.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_20.png'), $rawfile('example/refreshframes/CYLRefreshRing_21.png'),
      $rawfile('example/refreshframes/CYLRefreshRing_22.png'), $rawfile('example/refreshframes/CYLRefreshRing_23.png')
    ];
  }
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

/** A header and footer pair (the iOS setup closure's result). */
export class RefreshControls {
  header: CYLRefreshHeaderModel;
  footer: CYLRefreshFooterModel;

  constructor(header: CYLRefreshHeaderModel, footer: CYLRefreshFooterModel) {
    this.header = header;
    this.footer = footer;
  }
}

/** `setIconAnimation(bundled:size:for:)` of the example: the file of the core bundle at its rawfile path. */
function setIcon(control: CYLRefreshIconAnimating, i: RefreshIcon): void {
  control.setIconAnimationFilePath(animationPath(i.file), new CYLRefreshIconSize(i.width, i.height), i.state);
}

/** `setIconAnimation(attributes:for:)`: a file with its size and engine options. */
function iconAttributes(file: string, width: number, height: number,
  options: Record<string, string>): CYLRefreshIconAttributes {
  const a = new CYLRefreshIconAttributes();
  a.filePath = animationPath(file);
  a.size = new CYLRefreshIconSize(width, height);
  a.options = options;
  return a;
}

export class RefreshSetup {
  header: string = 'normal'; // 'normal' | 'animation'
  footer: string = 'auto'; // 'auto' | 'back'
  headerIcons: RefreshIcon[] = [];
  footerIcons: RefreshIcon[] = [];
  /** A setup written out like the iOS closure; replaces the declarative icons when set. */
  builder: ((ui: UIContext) => RefreshControls) | null = null;

  static of(header: string, footer: string, headerIcons: RefreshIcon[], footerIcons: RefreshIcon[]): RefreshSetup {
    const s = new RefreshSetup();
    s.header = header;
    s.footer = footer;
    s.headerIcons = headerIcons;
    s.footerIcons = footerIcons;
    return s;
  }

  static custom(builder: (ui: UIContext) => RefreshControls): RefreshSetup {
    const s = new RefreshSetup();
    s.builder = builder;
    return s;
  }

  /** The header and footer of the row. */
  make(ui: UIContext): RefreshControls {
    if (this.builder !== null) {
      return this.builder(ui);
    }
    return new RefreshControls(this.makeHeader(), this.makeFooter());
  }

  makeHeader(): CYLRefreshHeaderModel {
    if (this.header !== 'animation') {
      return new CYLRefreshNormalHeaderModel();
    }
    const h = new CYLRefreshAnimationHeaderModel();
    this.headerIcons.forEach((i: RefreshIcon) => setIcon(h, i));
    return h;
  }

  makeFooter(): CYLRefreshFooterModel {
    if (this.footerIcons.length === 0) {
      return this.footer === 'back' ? new CYLRefreshBackNormalFooterModel() : new CYLRefreshAutoNormalFooterModel();
    }
    if (this.footer === 'back') {
      const f = new CYLRefreshBackAnimationFooterModel();
      this.footerIcons.forEach((i: RefreshIcon) => setIcon(f, i));
      return f;
    }
    const f = new CYLRefreshAutoAnimationFooterModel();
    this.footerIcons.forEach((i: RefreshIcon) => setIcon(f, i));
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
const BUNDLED: string = 'setIconAnimation(bundled:size:for:)';

const GIFS: string[] = ['CYLRefreshActivity', 'CYLRefreshArrows', 'CYLRefreshPetals', 'CYLRefreshRing',
  'CYLRefreshThrobber'];
const LOTTIES: string[] = ['CYLPlaceholderRefresh', 'CYLRefreshArc', 'CYLRefreshClockwise',
  'CYLRefreshCounterClockwise', 'CYLRefreshCycle', 'CYLRefreshDone', 'CYLRefreshDoneCircle', 'CYLRefreshDonePop',
  'CYLRefreshDots', 'CYLRefreshDotsPulse', 'CYLRefreshGradientSpinner', 'CYLRefreshLoadMore',
  'CYLRefreshMaterialSpinner', 'CYLRefreshMoreDots', 'CYLRefreshPullArrow', 'CYLRefreshPullCircle',
  'CYLRefreshSpinnerRing'];

/** iOS `iconSize(for:)`: line icons and spinners at about the arrow's height, dots need width. */
function iconSize(file: string): CYLRefreshIconSize {
  if (file === 'CYLRefreshDots.json' || file === 'CYLRefreshDotsPulse.json' || file === 'CYLRefreshMoreDots.json') {
    return new CYLRefreshIconSize(40, 24);
  }
  if (file === 'CYLRefreshThrobber.gif') {
    return new CYLRefreshIconSize(20, 20);
  }
  if (file === 'CYLRefreshMaterialSpinner.json' || file === 'CYLRefreshDonePop.json' ||
    file === 'CYLPlaceholderProgress.pag') {
    return new CYLRefreshIconSize(36, 36);
  }
  return new CYLRefreshIconSize(32, 32);
}

/** An engine row: the file for idle on the header and the footer (other states fall back to idle). */
function fileRow(file: string): RefreshIconRow {
  const size = iconSize(file);
  return new RefreshIconRow(file.replace(/\.[^.]+$/, ''), file, false, BUNDLED,
    RefreshSetup.of('animation', 'auto', [new RefreshIcon(I, file, size.width, size.height)],
      [new RefreshIcon(I, file, size.width, size.height)]));
}

/** iOS `CYLRefreshIconConfiguration`: the state names of refresh-icons.json. */
function configurationState(name: string): CYLRefreshState | null {
  switch (name) {
    case 'idle':
      return CYLRefreshState.Idle;
    case 'pulling':
      return CYLRefreshState.Pulling;
    case 'refreshing':
      return CYLRefreshState.Refreshing;
    case 'willRefresh':
      return CYLRefreshState.WillRefresh;
    case 'noMoreData':
      return CYLRefreshState.NoMoreData;
    default:
      return null;
  }
}

/**
 * iOS `CYLRefreshIconConfiguration.apply(fileNamed:header:footer:)`: reads rawfile/example/refreshicons/<name>; for
 * "header" and "footer" a state name maps to {"file", "size"} (setIconAnimation bundled) or adds "options"
 * (setIconAnimation attributes).
 */
export function applyRefreshIconConfiguration(ui: UIContext, name: string, header: CYLRefreshIconAnimating,
  footer: CYLRefreshIconAnimating): void {
  const text = readRawText(ui, 'example/refreshicons/' + name);
  let root: Record<string, Object> | null = null;
  try {
    root = text.length > 0 ? JSON.parse(text) as Record<string, Object> : null;
  } catch (e) {
    root = null;
  }
  if (root === null) {
    console.warn('Example-Scenarios: refresh icon configuration ' + name + ' is missing or invalid.');
    return;
  }
  const controls: CYLRefreshIconAnimating[] = [header, footer];
  const keys: string[] = ['header', 'footer'];
  for (let k = 0; k < keys.length; k++) {
    const entries = root[keys[k]] as Record<string, Record<string, Object>> | undefined;
    if (entries === undefined || entries === null) {
      continue;
    }
    Object.keys(entries).forEach((stateName: string) => {
      const entry = entries[stateName];
      const state = configurationState(stateName);
      const file = entry['file'];
      if (state === null || typeof file !== 'string') {
        console.warn('Example-Scenarios: skipped ' + keys[k] + '.' + stateName + ' in ' + name + '.');
        return;
      }
      const numbers = Array.isArray(entry['size']) ? entry['size'] as number[] : [32, 32];
      const w = numbers.length > 0 ? numbers[0] : 32;
      const h = numbers.length > 0 ? numbers[numbers.length - 1] : 32;
      const options = entry['options'] as Record<string, string> | undefined;
      if (options !== undefined && options !== null) {
        controls[k].setIconAnimationAttributes(iconAttributes(file as string, w, h, options), state);
      } else {
        setIcon(controls[k], new RefreshIcon(state, file as string, w, h));
      }
    });
  }
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
  // The SVGA twin of the Rive row (Task-Log "SVGA animations"): CYLTabBarController's SVGA engine (CYLAnimatedItemSVGA).
  new RefreshIconSection('SVGA · CYLTableViewPlaceHolder/SVGA', false,
    [fileRow('tab_activity.svga'), fileRow('tab_list.svga')]),
  new RefreshIconSection('CYLScenarioSectionRefreshInit', true, [
    // MJRefresh's "animated images": an image sequence per state, frames of bundled refresh GIFs.
    new RefreshIconRow('byImages', 'CYLScenarioRefreshByImages', true, 'setAnimationImages(_:duration:for:)',
      RefreshSetup.custom(() => {
        const arrows = RefreshFrames.arrows();
        const ring = RefreshFrames.ring();
        const header = new CYLRefreshAnimationHeaderModel();
        header.setAnimationImagesForState(arrows, I);
        header.setAnimationImages(arrows, 0.6, P);
        header.setAnimationImages(ring, 0.8, R);
        const footer = new CYLRefreshAutoAnimationFooterModel();
        footer.setAnimationImagesForState(ring, R);
        return new RefreshControls(header, footer);
      })),
    // A different bundled icon for each state, one engine per state.
    new RefreshIconRow('byStates', 'CYLScenarioRefreshByStates', true, BUNDLED,
      RefreshSetup.of('animation', 'auto', [new RefreshIcon(I, 'CYLRefreshPullCircle.json', 28),
        new RefreshIcon(P, 'CYLRefreshCounterClockwise.json', 28), new RefreshIcon(R, 'CYLPlaceholderProgress.pag', 32)],
        [new RefreshIcon(R, 'CYLRefreshActivity.gif', 28)])),
    // The back footer shows its icon while idle and pulling too; "no more data" shows the text only.
    new RefreshIconRow('backFooter', 'CYLScenarioRefreshBackFooter', true, 'CYLRefreshBackAnimationFooter',
      RefreshSetup.of('animation', 'back', [new RefreshIcon(I, 'CYLRefreshCycle.json', 28)],
        [new RefreshIcon(I, 'CYLRefreshLoadMore.json', 28), new RefreshIcon(P, 'CYLRefreshClockwise.json', 28),
          new RefreshIcon(R, 'CYLRefreshPetals.gif', 28)])),
    // Any file: here the paths of two bundled files, one for pulling and one for refreshing.
    new RefreshIconRow('byFilePath', 'CYLScenarioRefreshByFilePath', true, 'setIconAnimation(filePath:size:for:)',
      RefreshSetup.custom(() => {
        const header = new CYLRefreshAnimationHeaderModel();
        const footer = new CYLRefreshAutoAnimationFooterModel();
        const arrow = animationPath('CYLRefreshArrows.gif');
        const spinner = animationPath('CYLRefreshGradientSpinner.json');
        header.setIconAnimationFilePath(arrow, new CYLRefreshIconSize(32, 32), I);
        header.setIconAnimationFilePath(spinner, new CYLRefreshIconSize(36, 36), R);
        footer.setIconAnimationFilePath(spinner, new CYLRefreshIconSize(32, 32), R);
        return new RefreshControls(header, footer);
      })),
    // Raw item attributes: the "refresh" artboard of the Rive file rests on its "idle" animation and turns with its
    // "active" animation while refreshing.
    new RefreshIconRow('byAttributes', 'CYLScenarioRefreshByAttributes', true, 'setIconAnimation(attributes:for:)',
      RefreshSetup.custom(() => {
        const header = new CYLRefreshAnimationHeaderModel();
        const footer = new CYLRefreshAutoAnimationFooterModel();
        const resting: Record<string, string> = { 'legacy': '1', 'artboard': 'refresh', 'animation': 'idle' };
        const turning: Record<string, string> = { 'legacy': '1', 'artboard': 'refresh', 'animation': 'active' };
        header.setIconAnimationAttributes(iconAttributes('CYLRefreshIcon.riv', 32, 32, resting), I);
        header.setIconAnimationAttributes(iconAttributes('CYLRefreshIcon.riv', 32, 32, turning), R);
        footer.setIconAnimationAttributes(iconAttributes('CYLRefreshIcon.riv', 32, 32, turning), R);
        return new RefreshControls(header, footer);
      })),
    new RefreshIconRow('byConfiguration', 'CYLScenarioRefreshByConfiguration', true, 'RefreshIcons/refresh-icons.json',
      RefreshSetup.custom((ui: UIContext) => {
        const header = new CYLRefreshAnimationHeaderModel();
        const footer = new CYLRefreshAutoAnimationFooterModel();
        applyRefreshIconConfiguration(ui, 'refresh-icons.json', header, footer);
        return new RefreshControls(header, footer);
      })),
    // Code written for MJRefresh's names keeps working: the Gif classes' setImages call setAnimationImages.
    new RefreshIconRow('gifNames', 'CYLScenarioRefreshGifNames', true, 'CYLRefreshGifHeader · setImages(_:for:)',
      RefreshSetup.custom(() => {
        const arrows = RefreshFrames.arrows();
        const header = new CYLRefreshGifHeaderModel();
        header.setImagesForState(arrows, I);
        header.setImages(arrows, 0.6, R);
        const footer = new CYLRefreshAutoGifFooterModel();
        setIcon(footer, new RefreshIcon(R, 'CYLRefreshThrobber.gif', 20));
        return new RefreshControls(header, footer);
      })),
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
