// The Refresh tab's menu (CYLRefreshExampleViewController): 8 sections, 66 rows. Each row names the iOS view
// controller and method (shown as the subtitle "<VC> - <method>") and the mini program page that plays it.
const T = 'CYLRefreshTableViewController'
const table = (key, method) => ({ key, vc: T, method, page: 'refresh-table' })
const smart = (key, method) => ({ key, vc: 'CYLSmartRefreshDemoViewController', method, page: 'refresh-smart' })
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
  { key: 'CYLScenarioSmartSection', rows: [
    ['Delivery', 'smartDelivery'], ['Classics', 'smartClassics'], ['DropBox', 'smartDropBox'], ['Phoenix', 'smartPhoenix'],
    ['Taurus', 'smartTaurus'], ['BezierRadar', 'smartBezierRadar'], ['BezierCircle', 'smartBezierCircle'],
    ['StoreHouse', 'smartStoreHouse'], ['WaveSwipe', 'smartWaveSwipe'], ['Original', 'smartOriginal'],
    ['Material', 'smartMaterial'], ['GameHitBlock', 'smartGameHitBlock'], ['GameBattleCity', 'smartGameBattleCity'],
    ['Fly', 'smartFly'], ['ClassicsFooter', 'smartClassicsFooter'], ['BezierRadarFooter', 'smartBezierRadarFooter'],
    ['MaterialFooter', 'smartMaterialFooter'], ['DeliveryFooter', 'smartDeliveryFooter'], ['PhoenixFooter', 'smartPhoenixFooter'],
    ['TaurusFooter', 'smartTaurusFooter'], ['RiveBow', 'smartRiveBow'], ['RiveBubbles', 'smartRiveBubbles'],
    ['RiveHalloween', 'smartRiveHalloween'], ['RiveSkating', 'smartRiveSkating'], ['RiveSpace', 'smartRiveSpace'],
    ['RiveSquats', 'smartRiveSquats'], ['RiveSpaceFooter', 'smartRiveSpaceFooter'],
    ['SVGABow', 'smartSvgaBow'], ['SVGABubbles', 'smartSvgaBubbles'], ['SVGAHalloween', 'smartSvgaHalloween'],
    ['SVGASkating', 'smartSvgaSkating'], ['SVGASpace', 'smartSvgaSpace'], ['SVGASquats', 'smartSvgaSquats'],
    ['SVGASpaceFooter', 'smartSvgaSpaceFooter'],
  ].map(([suffix, method]) => smart('CYLScenarioSmart' + suffix, method)) },
  { key: 'CYLScenarioEasySection', rows: [
    ['Cupertino', 'easyCupertino'], ['Secondary', 'easySecondary'], ['TriggerMode', 'easyTriggerMode'],
    ['RefreshOnStart', 'easyRefreshOnStart'], ['Paging', 'easyPaging'], ['Listener', 'easyListener'],
    ['Chat', 'easyChat'], ['UserProfile', 'easyUserProfile'],
  ].map(([suffix, method]) => easy('CYLScenarioEasy' + suffix, method)) },
]

module.exports = { SECTIONS }
