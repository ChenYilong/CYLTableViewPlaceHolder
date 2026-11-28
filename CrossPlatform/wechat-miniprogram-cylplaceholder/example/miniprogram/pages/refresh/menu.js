// The Refresh tab's menu (CYLRefreshExampleViewController): 8 sections, 66 rows. Each row names the iOS view
// controller and method (shown as the subtitle "<VC> - <method>") and the mini program page that plays it.
const T = 'CYLRefreshTableViewController'
const table = (key, method) => ({ key, vc: T, method, page: 'refresh-table' })
const style = (key, method) => ({ key, vc: 'CYLRefreshStylesDemoViewController', method, page: 'refresh-styles' })
const easy = (key, method) => ({ key, vc: 'CYLEasyRefreshDemoViewController', method, page: 'refresh-easy' })

const SECTIONS = [
  { key: 'CYLScenarioMJSectionHeader', rows: [
    table('CYLScenarioMJDefault', 'example01'), table('CYLScenarioMJAnimatedImages', 'example02'),
    table('CYLScenarioMJHideTime', 'example03'), table('CYLScenarioMJHideStateAndTime', 'example04'),
    table('CYLScenarioMJCustomText', 'example05'), table('CYLScenarioMJCustomControl', 'example06'),
  ] },
  { key: 'CYLScenarioMJSectionFooter', rows: [
    table('CYLScenarioMJDefault', 'example11'), table('CYLScenarioMJAnimatedImages', 'example12'),
    table('CYLScenarioMJHideRefreshingText', 'example13'), table('CYLScenarioMJAllLoaded', 'example14'),
    table('CYLScenarioMJNoAutoLoading', 'example15'), table('CYLScenarioMJCustomText', 'example16'),
    table('CYLScenarioMJHideAfterLoading', 'example17'), table('CYLScenarioMJAutoBack01', 'example18'),
    table('CYLScenarioMJAutoBack02', 'example19'), table('CYLScenarioMJCustomAutoControl', 'example20'),
    table('CYLScenarioMJCustomBackControl', 'example21'),
  ] },
  { key: 'CYLScenarioMJSectionCollection', rows: [
    { key: 'CYLScenarioMJPullUpAndDown', vc: 'CYLRefreshCollectionViewController', method: 'example31', page: 'refresh-collection' },
    { key: 'CYLScenarioMJPinHeader', vc: 'CYLRefreshPinHeaderCollectionViewController', method: 'example31', page: 'refresh-collection' },
    { key: 'CYLScenarioMJPullLeft', vc: 'CYLRefreshHorizontalCollectionViewController', method: 'example42', page: 'refresh-collection' },
  ] },
  { key: 'CYLScenarioMJSectionWeb', rows: [
    { key: 'CYLScenarioMJWebPullOld', vc: 'CYLRefreshWKWebViewController', method: 'example40', page: 'refresh-web' },
    { key: 'CYLScenarioMJWebPull', vc: 'CYLRefreshWKWebViewController', method: 'example41', page: 'refresh-web' },
  ] },
  { key: 'CYLScenarioMJSectionI18n', rows: [
    { key: 'CYLScenarioMJLanguages', vc: 'CYLRefreshI18NExampleViewController', method: 'i18n', page: 'refresh-i18n' },
  ] },
  { key: 'CYLScenarioMJSectionAnimations', rows: [
    table('CYLScenarioMJGifIcon', 'example51'), table('CYLScenarioMJLottieStates', 'example52'),
    table('CYLScenarioMJPagRing', 'example53'), table('CYLScenarioMJRiveIcon', 'example54'), table('CYLScenarioMJSVGAIcon', 'example57'),
    table('CYLScenarioMJGifFrames', 'example55'), table('CYLScenarioMJMixedEngines', 'example56'),
    { key: 'CYLScenarioMJCollectionIcons', vc: 'CYLRefreshCollectionViewController', method: 'example32', page: 'refresh-collection' },
  ] },
  { key: 'CYLScenarioRefreshStyleSection', rows: [
    ['Delivery', 'styleDelivery'], ['Classics', 'styleClassics'], ['DropBox', 'styleDropBox'], ['Phoenix', 'stylePhoenix'],
    ['Taurus', 'styleTaurus'], ['BezierRadar', 'styleBezierRadar'], ['BezierCircle', 'styleBezierCircle'],
    ['StoreHouse', 'styleStoreHouse'], ['WaveSwipe', 'styleWaveSwipe'], ['Original', 'styleOriginal'],
    ['Material', 'styleMaterial'], ['GameHitBlock', 'styleGameHitBlock'], ['GameBattleCity', 'styleGameBattleCity'],
    ['Fly', 'styleFly'], ['ClassicsFooter', 'styleClassicsFooter'], ['BezierRadarFooter', 'styleBezierRadarFooter'],
    ['MaterialFooter', 'styleMaterialFooter'], ['DeliveryFooter', 'styleDeliveryFooter'], ['PhoenixFooter', 'stylePhoenixFooter'],
    ['TaurusFooter', 'styleTaurusFooter'], ['RiveBow', 'styleRiveBow'], ['RiveBubbles', 'styleRiveBubbles'],
    ['RiveHalloween', 'styleRiveHalloween'], ['RiveSkating', 'styleRiveSkating'], ['RiveSpace', 'styleRiveSpace'],
    ['RiveSquats', 'styleRiveSquats'], ['RiveSpaceFooter', 'styleRiveSpaceFooter'],
    ['SVGABow', 'styleSvgaBow'], ['SVGABubbles', 'styleSvgaBubbles'], ['SVGAHalloween', 'styleSvgaHalloween'],
    ['SVGASkating', 'styleSvgaSkating'], ['SVGASpace', 'styleSvgaSpace'], ['SVGASquats', 'styleSvgaSquats'],
    ['SVGASpaceFooter', 'styleSvgaSpaceFooter'],
  ].map(([suffix, method]) => style('CYLScenarioRefreshStyle' + suffix, method)) },
  { key: 'CYLScenarioEasySection', rows: [
    ['Cupertino', 'easyCupertino'], ['Secondary', 'easySecondary'], ['TriggerMode', 'easyTriggerMode'],
    ['RefreshOnStart', 'easyRefreshOnStart'], ['Paging', 'easyPaging'], ['ScrollMode', 'easyScrollMode'], ['Listener', 'easyListener'],
    ['Chat', 'easyChat'], ['UserProfile', 'easyUserProfile'],
  ].map(([suffix, method]) => easy('CYLScenarioEasy' + suffix, method)) },
]

module.exports = { SECTIONS }
