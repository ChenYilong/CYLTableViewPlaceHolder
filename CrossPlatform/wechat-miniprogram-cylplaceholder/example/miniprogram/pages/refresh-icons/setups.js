// The setups of CYLRefreshIconListViewController: each row's header / footer and icons per state. Used by the list
// and by the demo page (refresh-icon-demo?setup=<id>). Paths are package paths; PAG and Rive files have no player in
// the mini program (cyl-refresh shows its spinner for them).
const A = '/assets/animations/'
const PLACEHOLDER = '/components/cyl-placeholder/animations/'

const GIFS = ['CYLRefreshActivity', 'CYLRefreshArrows', 'CYLRefreshPetals', 'CYLRefreshRing', 'CYLRefreshThrobber']
const LOTTIES = ['CYLRefreshArc', 'CYLRefreshClockwise', 'CYLRefreshCounterClockwise', 'CYLRefreshCycle', 'CYLRefreshDone',
  'CYLRefreshDoneCircle', 'CYLRefreshDonePop', 'CYLRefreshDots', 'CYLRefreshDotsPulse', 'CYLRefreshGradientSpinner',
  'CYLRefreshLoadMore', 'CYLRefreshMaterialSpinner', 'CYLRefreshMoreDots', 'CYLRefreshPullArrow', 'CYLRefreshPullCircle',
  'CYLRefreshSpinnerRing']

/** Sizes of the iOS list: dots 40×24, Throbber 20, MaterialSpinner / DonePop / Progress 36, else 32. */
function sizeFor(name) {
  if (/Dots|DotsPulse|MoreDots/.test(name)) return [40, 24]
  if (/Throbber/.test(name)) return 20
  if (/MaterialSpinner|DonePop|Progress/.test(name)) return 36
  return 32
}

const one = (path, name) => {
  const icon = { path, size: sizeFor(name) }
  // One file for idle covers every state (setIconAnimation(bundled:size:for: .idle)).
  return { header: 'animation', footer: 'auto', headerIcons: { Idle: icon }, footerIcons: { Idle: icon, Refreshing: icon } }
}

/** Sections of the list, in the iOS order. Titles are example keys or literal file names. */
const SECTIONS = [
  {
    titleKey: 'CYLScenarioSectionRefreshArrow',
    rows: [
      { id: 'arrowAuto', titleKey: 'CYLScenarioRefreshArrowAuto', subtitle: 'CYLRefreshNormalHeader · CYLRefreshAutoNormalFooter', setup: { header: 'normal', footer: 'auto' } },
      { id: 'arrowBack', titleKey: 'CYLScenarioRefreshArrowBack', subtitle: 'CYLRefreshNormalHeader · CYLRefreshBackNormalFooter', setup: { header: 'normal', footer: 'back' } },
    ],
  },
  { title: 'GIF · Core', rows: GIFS.map((n) => ({ id: n, title: n + '.gif', subtitle: 'setIconAnimation(bundled:size:for:)', setup: one(A + n + '.gif', n) })) },
  {
    title: 'Lottie · CYLTableViewPlaceHolder/LottieSwift',
    rows: [{ id: 'CYLPlaceholderRefresh', title: 'CYLPlaceholderRefresh.json', subtitle: 'setIconAnimation(bundled:size:for:)', setup: one(PLACEHOLDER + 'CYLPlaceholderRefresh.json', 'CYLPlaceholderRefresh') }]
      .concat(LOTTIES.map((n) => ({ id: n, title: n + '.json', subtitle: 'setIconAnimation(bundled:size:for:)', setup: one(A + n + '.json', n) }))),
  },
  { title: 'PAG · CYLTableViewPlaceHolder/PAG', rows: [{ id: 'CYLPlaceholderProgress', title: 'CYLPlaceholderProgress.pag', subtitle: 'setIconAnimation(bundled:size:for:)', setup: one(A + 'CYLPlaceholderProgress.pag', 'Progress') }] },
  { title: 'Rive · CYLTableViewPlaceHolder/Rive', rows: [{ id: 'CYLRefreshIcon', title: 'CYLRefreshIcon.riv', subtitle: 'setIconAnimation(bundled:size:for:)', setup: one(A + 'CYLRefreshIcon.riv', 'CYLRefreshIcon') }] },
  {
    titleKey: 'CYLScenarioSectionRefreshInit',
    rows: [
      // Image sequences: the mini program plays the GIFs the frames come from.
      { id: 'byImages', titleKey: 'CYLScenarioRefreshByImages', subtitle: 'setAnimationImages(_:duration:for:)', setup: {
        header: 'animation', footer: 'auto',
        headerIcons: { Idle: { path: A + 'CYLRefreshArrows.gif', size: 40 }, Pulling: { path: A + 'CYLRefreshArrows.gif', size: 40 }, Refreshing: { path: A + 'CYLRefreshRing.gif', size: 40 } },
        footerIcons: { Refreshing: { path: A + 'CYLRefreshRing.gif', size: 40 } } } },
      { id: 'byStates', titleKey: 'CYLScenarioRefreshByStates', subtitle: 'setIconAnimation(bundled:size:for:)', setup: {
        header: 'animation', footer: 'auto',
        headerIcons: { Idle: { path: A + 'CYLRefreshPullCircle.json', size: 28 }, Pulling: { path: A + 'CYLRefreshCounterClockwise.json', size: 28 }, Refreshing: { path: A + 'CYLPlaceholderProgress.pag', size: 32 } },
        footerIcons: { Refreshing: { path: A + 'CYLRefreshActivity.gif', size: 28 } } } },
      { id: 'backFooter', titleKey: 'CYLScenarioRefreshBackFooter', subtitle: 'CYLRefreshBackAnimationFooter', setup: {
        header: 'animation', footer: 'back',
        headerIcons: { Idle: { path: A + 'CYLRefreshCycle.json', size: 28 } },
        footerIcons: { Idle: { path: A + 'CYLRefreshLoadMore.json', size: 28 }, Pulling: { path: A + 'CYLRefreshClockwise.json', size: 28 }, Refreshing: { path: A + 'CYLRefreshPetals.gif', size: 28 } } } },
      { id: 'byFilePath', titleKey: 'CYLScenarioRefreshByFilePath', subtitle: 'setIconAnimation(filePath:size:for:)', setup: {
        header: 'animation', footer: 'auto',
        headerIcons: { Idle: { path: A + 'CYLRefreshArrows.gif', size: 32 }, Refreshing: { path: A + 'CYLRefreshGradientSpinner.json', size: 36 } },
        footerIcons: { Refreshing: { path: A + 'CYLRefreshGradientSpinner.json', size: 32 } } } },
      { id: 'byAttributes', titleKey: 'CYLScenarioRefreshByAttributes', subtitle: 'setIconAnimation(attributes:for:)', setup: {
        header: 'animation', footer: 'auto',
        headerIcons: { Idle: { path: A + 'CYLRefreshIcon.riv', size: 32 } }, footerIcons: { Refreshing: { path: A + 'CYLRefreshIcon.riv', size: 32 } } } },
      { id: 'byConfiguration', titleKey: 'CYLScenarioRefreshByConfiguration', subtitle: 'RefreshIcons/refresh-icons.json', setup: {
        header: 'animation', footer: 'auto',
        headerIcons: { Idle: { path: A + 'CYLRefreshPullArrow.json', size: 28 }, Pulling: { path: A + 'CYLRefreshClockwise.json', size: 28 }, Refreshing: { path: A + 'CYLRefreshMaterialSpinner.json', size: 36 } },
        footerIcons: { Idle: { path: A + 'CYLRefreshLoadMore.json', size: 28 }, Refreshing: { path: A + 'CYLRefreshIcon.riv', size: 32 }, NoMoreData: { path: A + 'CYLRefreshDoneCircle.json', size: 28 } } } },
      { id: 'gifNames', titleKey: 'CYLScenarioRefreshGifNames', subtitle: 'CYLRefreshGifHeader · setImages(_:for:)', setup: {
        header: 'animation', footer: 'auto',
        headerIcons: { Idle: { path: A + 'CYLRefreshArrows.gif', size: 40 }, Refreshing: { path: A + 'CYLRefreshArrows.gif', size: 40 } },
        footerIcons: { Refreshing: { path: A + 'CYLRefreshThrobber.gif', size: 20 } } } },
    ],
  },
]

function setupFor(id) {
  for (const section of SECTIONS) for (const row of section.rows) if (row.id === id) return row
  return null
}

module.exports = { SECTIONS, setupFor }
