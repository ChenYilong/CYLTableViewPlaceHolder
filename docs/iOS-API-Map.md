# iOS API 对照表（Android → iOS） / The iOS API map (Android → iOS)

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshCategories.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshcategorieskt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshCategories.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshcategorieskt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshClassics.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshclassicskt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshClassics.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshclassicskt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshComponent.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshcomponentkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshComponent.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshcomponentkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshConst.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshconstkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshConst.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshconstkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshCupertino.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshcupertinokt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshCupertino.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshcupertinokt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshDrawn.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshdrawnkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshDrawn.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshdrawnkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshDriven.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshdrivenkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshDriven.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshdrivenkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshIconView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshiconviewkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshIconView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshiconviewkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshPaging.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshpagingkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshPaging.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshpagingkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshRive.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshrivekt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshRive.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshrivekt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshStyle.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshstylekt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshStyle.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshstylekt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshTrailer.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshtrailerkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshTrailer.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshcylrefreshtrailerkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/classics/Classics.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshclassicsclassicskt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/classics/Classics.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshclassicsclassicskt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/PaintDrawables.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshdrawablepaintdrawableskt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/PaintDrawables.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshdrawablepaintdrawableskt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/PathsDrawable.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshdrawablepathsdrawablekt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/PathsDrawable.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshdrawablepathsdrawablekt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/path/PathParser.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshdrawablepathpathparserkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/path/PathParser.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshdrawablepathpathparserkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/view/PathsView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshdrawableviewpathsviewkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/view/PathsView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshdrawableviewpathsviewkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/footer/BallPulseFooter.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshfooterballpulsefooterkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/footer/BallPulseFooter.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshfooterballpulsefooterkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/footer/ClassicsFooter.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshfooterclassicsfooterkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/footer/ClassicsFooter.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshfooterclassicsfooterkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/BezierCircleHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderbeziercircleheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/BezierCircleHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderbeziercircleheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/BezierRadarHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderbezierradarheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/BezierRadarHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderbezierradarheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/ClassicsHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderclassicsheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/ClassicsHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderclassicsheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/DeliveryHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderdeliveryheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/DeliveryHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderdeliveryheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/DropBoxHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderdropboxheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/DropBoxHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderdropboxheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/Falsify.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfalsifykt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/Falsify.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfalsifykt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/FlyRefreshHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderflyrefreshheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/FlyRefreshHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderflyrefreshheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/FunGameBattleCityHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfungamebattlecityheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/FunGameBattleCityHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfungamebattlecityheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/FunGameHitBlockHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfungamehitblockheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/FunGameHitBlockHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfungamehitblockheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/MaterialHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheadermaterialheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/MaterialHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheadermaterialheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/PhoenixHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderphoenixheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/PhoenixHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderphoenixheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/StoreHouseHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderstorehouseheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/StoreHouseHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderstorehouseheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/TaurusHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheadertaurusheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/TaurusHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheadertaurusheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/TwoLevelHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheadertwolevelheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/TwoLevelHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheadertwolevelheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/WaterDropHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaterdropheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/WaterDropHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaterdropheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/WaveSwipeHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaveswipeheaderkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/WaveSwipeHeader.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaveswipeheaderkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/falsify/FalsifyAbstract.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfalsifyfalsifyabstractkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/falsify/FalsifyAbstract.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfalsifyfalsifyabstractkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/flyrefresh/FlyView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderflyrefreshflyviewkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/flyrefresh/FlyView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderflyrefreshflyviewkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/flyrefresh/MountainSceneView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderflyrefreshmountainsceneviewkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/flyrefresh/MountainSceneView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderflyrefreshmountainsceneviewkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/fungame/FunGameBase.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfungamefungamebasekt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/fungame/FunGameBase.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfungamefungamebasekt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/fungame/FunGameView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfungamefungameviewkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/fungame/FunGameView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderfungamefungameviewkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/listener/OnTwoLevelListener.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderlistenerontwolevellistenerkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/listener/OnTwoLevelListener.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderlistenerontwolevellistenerkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/material/MaterialDrawables.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheadermaterialmaterialdrawableskt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/material/MaterialDrawables.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheadermaterialmaterialdrawableskt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/storehouse/StoreHouseBarItem.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderstorehousestorehousebaritemkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/storehouse/StoreHouseBarItem.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderstorehousestorehousebaritemkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/storehouse/StoreHousePath.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderstorehousestorehousepathkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/storehouse/StoreHousePath.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderstorehousestorehousepathkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/waterdrop/Circle.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaterdropcirclekt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/waterdrop/Circle.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaterdropcirclekt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/waterdrop/WaterDropView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaterdropwaterdropviewkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/waterdrop/WaterDropView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaterdropwaterdropviewkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/waveswipe/DropBounceInterpolator.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaveswipedropbounceinterpolatorkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/waveswipe/DropBounceInterpolator.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaveswipedropbounceinterpolatorkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/waveswipe/WaveView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaveswipewaveviewkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/header/waveswipe/WaveView.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshheaderwaveswipewaveviewkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/CYLRefreshLayout.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutcylrefreshlayoutkt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/CYLRefreshLayout.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutcylrefreshlayoutkt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/api/Api.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutapiapikt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/api/Api.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutapiapikt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/constant/Constants.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutconstantconstantskt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/constant/Constants.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutconstantconstantskt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/listener/Listeners.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutlistenerlistenerskt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/listener/Listeners.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutlistenerlistenerskt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/simple/Simple.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutsimplesimplekt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/simple/Simple.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutsimplesimplekt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/util/Utils.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoututilutilskt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/util/Utils.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoututilutilskt) |
| [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/wrapper/Wrappers.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutwrapperwrapperskt) | [`android/merged/library/src/main/kotlin/com/cyl/refresh/layout/wrapper/Wrappers.kt`](#androidmergedlibrarysrcmainkotlincomcylrefreshlayoutwrapperwrapperskt) |
| [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderComponent.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholdercomponentkt) | [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderComponent.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholdercomponentkt) |
| [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderConfiguration.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderconfigurationkt) | [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderConfiguration.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderconfigurationkt) |
| [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderResourceMonitor.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderresourcemonitorkt) | [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderResourceMonitor.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderresourcemonitorkt) |
| [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderScenario.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderscenariokt) | [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderScenario.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderscenariokt) |
| [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderStackView.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderstackviewkt) | [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderStackView.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderstackviewkt) |
| [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderStatus.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderstatuskt) | [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderStatus.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderstatuskt) |
| [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderView.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderviewkt) | [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderView.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercylplaceholderviewkt) |
| [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLTableViewPlaceHolder.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercyltableviewplaceholderkt) | [`android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLTableViewPlaceHolder.kt`](#androidplaceholdersrcmainkotlincomcylplaceholdercyltableviewplaceholderkt) |
| [`android/placeholder/src/main/kotlin/com/cyl/placeholder/bridge/CYLPlaceholderBridge.kt`](#androidplaceholdersrcmainkotlincomcylplaceholderbridgecylplaceholderbridgekt) | [`android/placeholder/src/main/kotlin/com/cyl/placeholder/bridge/CYLPlaceholderBridge.kt`](#androidplaceholdersrcmainkotlincomcylplaceholderbridgecylplaceholderbridgekt) |
| [`android/placeholder/src/main/kotlin/com/cyl/placeholder/hud/CYLPlaceholderHUD.kt`](#androidplaceholdersrcmainkotlincomcylplaceholderhudcylplaceholderhudkt) | [`android/placeholder/src/main/kotlin/com/cyl/placeholder/hud/CYLPlaceholderHUD.kt`](#androidplaceholdersrcmainkotlincomcylplaceholderhudcylplaceholderhudkt) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

<!-- Generated by scripts/ios-api-map.py from the Android core and android/merged/ios-map.json; do not edit by hand. -->
<!-- 由 scripts/ios-api-map.py 根据 Android core 与 android/merged/ios-map.json 生成；请勿手动编辑。 -->

| 中文 | English |
|:---|:---|
| Android core（`android/placeholder` 及其 Lottie / PAG / Rive 动画器、`android/merged/library` 中的 CYLRefresh）的每个公开 API：第一列为 Android API，第二列为功能描述（KDoc 首句），第三列为 iOS 对应的 API 或功能，默认 TODO。iOS → Android 方向见 [Android-API-Map.md](Android-API-Map.md)。数据：`android/merged/ios-map.json`（手动对照）与 `android/merged/api-map.json` 的反向映射。 | Every public API of the Android core (`android/placeholder` with its Lottie / PAG / Rive animators, and CYLRefresh in `android/merged/library`): the Android API, a description (the first sentence of its KDoc), and the iOS API or feature, TODO by default. The iOS → Android direction is [Android-API-Map.md](Android-API-Map.md). Data: `android/merged/ios-map.json` (hand-written matches) and the reverse of `android/merged/api-map.json`. |
| **评分：99 / 100**（871 / 877 行已有 iOS 对应，TODO 6 行；n/a 为仅 Android 平台的细节，不计入）。第三列没有 TODO 为满分，全部 TODO 为 0 分。 | **Score: 99 / 100** (871 of 877 rows have an iOS counterpart, 6 TODO; n/a rows are Android platform details, counted out). No TODO in the third column is 100; all TODO is 0. |
| 流程：① 搜索现有 iOS 代码，为每个 TODO 找到对应的 API 或功能，写入 `android/merged/ios-map.json`；② 重新生成本表并打分；③ 逐个实现 iOS 缺少的 API 与功能（优先 core，再在 iOS example 中复刻 Android example 的用法），把 TODO 换成实现；④ 再次打分。循环直到满分。 | Process: (1) search the existing iOS code for each TODO and write the match into `android/merged/ios-map.json`; (2) regenerate this table and score it; (3) implement each API and feature iOS lacks, one by one (in the core first, then the iOS example reproduces the Android example that uses it) and replace its TODO with the implementation; (4) score again. Repeat until the score is 100. |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshCategories.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `cyl_setStateTitle` (fun) | The text of [state] (`cyl_setStateTitle:forState:`): shown by a control with a state text, kept by any other. | `cyl_setStateTitle:forState:` | matched by the iOS name its KDoc cites |
| `cyl_stateTitleForState` (fun) | The text of [state], or null (`cyl_stateTitleForState:`). | `cyl_stateTitleForState:` | matched by the iOS name its KDoc cites |
| `cyl_setAnimationImages` (fun) | Image frames as the icon of [state], [duration] seconds in all (`cyl_setAnimationImages:duration:forState:`). | `cyl_setAnimationImages:duration:forState:` | matched by the iOS name its KDoc cites |
| `cyl_setBundledIconAnimation` (fun) | One of the placeholder's bundled animation files, [name] in its `CYLPlaceholderAnimations` assets (the iOS CYLTableViewPlaceHolder.bundle), as the icon of [state], [width] × [height] dp (`cyl_setBundledIconAnimation:size | `cyl_setBundledIconAnimation:size:forState:` | matched by the iOS name its KDoc cites |
| `cyl_noMoreDataImage` (var) | Shown beside the text while there is no more data (`noMoreDataImage`): the normal footers show it, any other footer keeps it. | `noMoreDataImage` | matched by the iOS name its KDoc cites |
| `cyl_updateNoMoreDataImage` (fun) | Sets [cyl_noMoreDataImage] (`cyl_updateNoMoreDataImage:`). | `cyl_updateNoMoreDataImage:` | matched by the iOS name its KDoc cites |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshClassics.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshStateHeader` (class) | A header with a state text and a "last updated" line (iOS `CYLRefreshStateHeader`). | `CYLRefreshStateHeader`, `CYLRefreshStateHeader(ChainingGrammar)`, `CYLRefreshComponent(CYLRefreshStateTitles)` |  |
| `CYLRefreshStateHeader.stateLabel` (val) | The state text (`stateLabel`). | `CYLRefreshStateHeader` `stateLabel` |  |
| `CYLRefreshStateHeader.lastUpdatedTimeLabel` (val) | The "last updated" text (`lastUpdatedTimeLabel`). | `CYLRefreshStateHeader` `lastUpdatedTimeLabel` |  |
| `CYLRefreshStateHeader.labelLeftInset` (var) | The gap between the icon and the texts, in dp (`labelLeftInset`). | `CYLRefreshStateHeader` `labelLeftInset` |  |
| `CYLRefreshStateHeader.titleTimeSpacing` (var) | The gap between the state text and the "last updated" line, in dp (`titleTimeSpacing`). | `CYLRefreshStateHeader` `titleTimeSpacing` |  |
| `CYLRefreshStateHeader.lastUpdatedTimeFormatter` (var) | The date format of the "last updated" line (`lastUpdatedTimeFormatter`). | `CYLRefreshStateHeader` `lastUpdatedTimeFormatter` |  |
| `CYLRefreshStateHeader.lastUpdatedTimeText` (var) | Makes the "last updated" text from the last time, null for never (`lastUpdatedTimeText`). | `CYLRefreshStateHeader` `lastUpdatedTimeText` |  |
| `CYLRefreshStateHeader.succeededImage` (var) | Shown in place of the icon while the header holds after a successful refresh (`succeededImage`); needs a `finishDuration` above 0. | `CYLRefreshStateHeader` `succeededImage` |  |
| `CYLRefreshStateHeader.failedImage` (var) | Shown in place of the icon while the header holds after a failed refresh (`failedImage`). | `CYLRefreshStateHeader` `failedImage` |  |
| `CYLRefreshStateHeader.iconOnTrailingSide` (var) | Puts the icon after the text instead of before it (`iconOnTrailingSide`). | `CYLRefreshStateHeader` `iconOnTrailingSide` |  |
| `CYLRefreshStateHeader.lastUpdatedTimeString` (val) | The "last updated" text now shown (`lastUpdatedTimeString`). | `CYLRefreshStateHeader` `lastUpdatedTimeString` |  |
| `CYLRefreshStateHeader.setTitle` (fun) | The text of [state] (`setTitle:forState:`). | `CYLRefreshStateHeader` `-setTitle:forState:` |  |
| `CYLRefreshStateHeader.titleForState` (fun) | The text of [state] (`titleForState:`), as on the state footers. | `CYLRefreshStateHeader` `-titleForState:` |  |
| `CYLRefreshStateHeader.cyl_modifyLastUpdatedTimeText` (fun) | Sets [lastUpdatedTimeText] (`cyl_modifyLastUpdatedTimeText:`). | `CYLRefreshStateHeader(ChainingGrammar)` `-cyl_modifyLastUpdatedTimeText:` |  |
| `CYLRefreshNormalHeader` (class) | The state header with an arrow and a spinner (iOS `CYLRefreshNormalHeader`). | `CYLRefreshNormalHeader` |  |
| `CYLRefreshNormalHeader.arrowView` (val) | The arrow (`arrowView`). | `CYLRefreshNormalHeader` `arrowView` |  |
| `CYLRefreshNormalHeader.loadingView` (val) | The spinner (`loadingView`). | `CYLRefreshNormalHeader` `loadingView` |  |
| `CYLRefreshNormalHeader.iconSize` (var) | The arrow's and spinner's side, in dp (`iconSize`). | `CYLRefreshNormalHeader` `iconSize` |  |
| `CYLRefreshGifHeader` (class) | The state header with image frames per state (iOS `CYLRefreshGifHeader`). | `CYLRefreshGifHeader` |  |
| `CYLRefreshGifHeader.gifView` (val) | The view that shows the frames (`gifView`). | `CYLRefreshGifHeader` `gifView` |  |
| `CYLRefreshGifHeader.setImages` (fun) | The frames of [state], [duration] seconds in all (`setImages:duration:forState:`). | `CYLRefreshGifHeader` `-setImages:duration:forState:`, `CYLRefreshGifHeader` `-setImages:forState:` |  |
| `CYLRefreshGifHeader.setImages` (fun) | The frames of [state], 0.1 seconds each (`setImages:forState:`). | `CYLRefreshGifHeader` `-setImages:duration:forState:`, `CYLRefreshGifHeader` `-setImages:forState:` |  |
| `CYLRefreshGifHeader.setIconAnimationFilePath` (fun) | The animation file of [state], [width] by [height] dp, played by the player registered for its extension (GIF built in; Lottie, PAG and Rive with their modules) (`setIconAnimationFilePath:size:forState:`). | `CYLRefreshGifHeader` `setIconAnimationFilePath:size:forState:` | matched by the iOS name its KDoc cites |
| `CYLRefreshGifHeader.setIconAnimationAttributes` (fun) | The icon of [state] as attributes (`setIconAnimationAttributes:forState:`). | `CYLRefreshGifHeader` `setIconAnimationAttributes:forState:` | matched by the iOS name its KDoc cites |
| `CYLRefreshAnimationHeader` (class) | The state header with an animation per state (iOS `CYLRefreshAnimationHeader`). | `CYLRefreshAnimationHeader` |  |
| `CYLRefreshAnimationHeader.animationView` (val) | The view that shows the animation (`animationView`). | `CYLRefreshAnimationHeader` `animationView` |  |
| `CYLRefreshAnimationHeader.setAnimationImages` (fun) | The frames of [state], [duration] seconds in all (`setAnimationImages:duration:forState:`). | `CYLRefreshAnimationHeader` `-setAnimationImages:duration:forState:`, `CYLRefreshAnimationHeader` `-setAnimationImages:forState:` |  |
| `CYLRefreshAnimationHeader.setAnimationImages` (fun) | The frames of [state], 0.1 seconds each (`setAnimationImages:forState:`). | `CYLRefreshAnimationHeader` `-setAnimationImages:duration:forState:`, `CYLRefreshAnimationHeader` `-setAnimationImages:forState:` |  |
| `CYLRefreshAutoFooter` (class) | A footer that loads by itself when it comes into view (iOS `CYLRefreshAutoFooter`). | `CYLRefreshAutoFooter` |  |
| `CYLRefreshAutoFooter.automaticallyRefresh` (var) | Whether reaching the end loads by itself (`automaticallyRefresh`). | `CYLRefreshAutoFooter` `automaticallyRefresh` |  |
| `CYLRefreshAutoFooter.triggerAutomaticallyRefreshPercent` (var) | How much of the footer must show before it loads, 0 to 1 (`triggerAutomaticallyRefreshPercent`). | `CYLRefreshAutoFooter` `triggerAutomaticallyRefreshPercent` |  |
| `CYLRefreshAutoFooter.autoTriggerTimes` (var) | How many times one drag may load by itself, -1 for no limit (`autoTriggerTimes`), as on iOS: once the count is used up the footer stops loading by itself until the next drag begins. | `CYLRefreshAutoFooter` `autoTriggerTimes` |  |
| `CYLRefreshAutoStateFooter` (class) | The automatic footer with a state text (iOS `CYLRefreshAutoStateFooter`). | `CYLRefreshAutoStateFooter` |  |
| `CYLRefreshAutoStateFooter.stateLabel` (val) | The state text (`stateLabel`). | `CYLRefreshAutoStateFooter` `stateLabel` |  |
| `CYLRefreshAutoStateFooter.labelLeftInset` (var) | The gap between the icon and the text, in dp (`labelLeftInset`). | `CYLRefreshAutoStateFooter` `labelLeftInset` |  |
| `CYLRefreshAutoStateFooter.refreshingTitleHidden` (var) | Whether the text hides while loading (`refreshingTitleHidden`). | `CYLRefreshAutoStateFooter` `refreshingTitleHidden` |  |
| `CYLRefreshAutoStateFooter.setTitle` (fun) | The text of [state] (`setTitle:forState:`). | `CYLRefreshAutoStateFooter` `-setTitle:forState:` |  |
| `CYLRefreshAutoStateFooter.titleForState` (fun) | The text of [state] (`titleForState:`). | `CYLRefreshAutoStateFooter` `-titleForState:` |  |
| `CYLRefreshAutoNormalFooter` (class) | The automatic state footer with a spinner (iOS `CYLRefreshAutoNormalFooter`). | `CYLRefreshAutoNormalFooter` |  |
| `CYLRefreshAutoNormalFooter.noMoreDataImage` (var) | Shown beside the text while there is no more data (`noMoreDataImage`). | `CYLRefreshAutoNormalFooter` `noMoreDataImage` |  |
| `CYLRefreshAutoNormalFooter.loadingView` (val) | The spinner (`loadingView`). | `CYLRefreshAutoNormalFooter` `loadingView` |  |
| `CYLRefreshAutoGifFooter` (class) | The automatic state footer with image frames per state (iOS `CYLRefreshAutoGifFooter`). | `CYLRefreshAutoGifFooter` |  |
| `CYLRefreshAutoGifFooter.gifView` (val) | The view that shows the frames (`gifView`). | `CYLRefreshAutoGifFooter` `gifView` |  |
| `CYLRefreshAutoGifFooter.setImages` (fun) | The frames of [state], [duration] seconds in all (`setImages:duration:forState:`). | `CYLRefreshAutoGifFooter` `-setImages:duration:forState:`, `CYLRefreshAutoGifFooter` `-setImages:forState:` |  |
| `CYLRefreshAutoGifFooter.setImages` (fun) | The frames of [state], 0.1 seconds each (`setImages:forState:`). | `CYLRefreshAutoGifFooter` `-setImages:duration:forState:`, `CYLRefreshAutoGifFooter` `-setImages:forState:` |  |
| `CYLRefreshAutoGifFooter.setIconAnimationFilePath` (fun) | The animation file of [state], [width] by [height] dp, played by the player registered for its extension (GIF built in; Lottie, PAG and Rive with their modules) (`setIconAnimationFilePath:size:forState:`). | `CYLRefreshAutoGifFooter` `setIconAnimationFilePath:size:forState:` | matched by the iOS name its KDoc cites |
| `CYLRefreshAutoGifFooter.setIconAnimationAttributes` (fun) | The icon of [state] as attributes (`setIconAnimationAttributes:forState:`). | `CYLRefreshAutoGifFooter` `setIconAnimationAttributes:forState:` | matched by the iOS name its KDoc cites |
| `CYLRefreshAutoAnimationFooter` (class) | The automatic state footer with an animation per state (iOS `CYLRefreshAutoAnimationFooter`). | `CYLRefreshAutoAnimationFooter` |  |
| `CYLRefreshAutoAnimationFooter.animationView` (val) | The view that shows the animation (`animationView`). | `CYLRefreshAutoAnimationFooter` `animationView` |  |
| `CYLRefreshAutoAnimationFooter.setAnimationImages` (fun) | The frames of [state], [duration] seconds in all (`setAnimationImages:duration:forState:`). | `CYLRefreshAutoAnimationFooter` `-setAnimationImages:duration:forState:`, `CYLRefreshAutoAnimationFooter` `-setAnimationImages:forState:` |  |
| `CYLRefreshAutoAnimationFooter.setAnimationImages` (fun) | The frames of [state], 0.1 seconds each (`setAnimationImages:forState:`). | `CYLRefreshAutoAnimationFooter` `-setAnimationImages:duration:forState:`, `CYLRefreshAutoAnimationFooter` `-setAnimationImages:forState:` |  |
| `CYLRefreshBackFooter` (class) | A footer that loads when pulled up and released (iOS `CYLRefreshBackFooter`). | `CYLRefreshBackFooter` |  |
| `CYLRefreshBackFooter.noMoreDataDisplayDuration` (var) | Seconds "no more data" stays visible, with the footer held open, after a load ends with [endRefreshingWithNoMoreData] (`noMoreDataDisplayDuration`); 0 rebounds at once. | `CYLRefreshBackFooter` `noMoreDataDisplayDuration` |  |
| `CYLRefreshBackFooter.secondaryTriggerOffset` (var) | Pulling up this far and releasing opens the second floor below the list, in dp; 0 for never (`secondaryTriggerOffset`). | `CYLRefreshBackFooter` `secondaryTriggerOffset` |  |
| `CYLRefreshBackFooter.secondaryDimension` (var) | The open second floor's height, in dp; 0 for the layout's height (`secondaryDimension`). | `CYLRefreshBackFooter` `secondaryDimension` |  |
| `CYLRefreshBackFooter.secondaryCloseTriggerOffset` (var) | Pulling the open second floor down this far and releasing closes it, in dp (`secondaryCloseTriggerOffset`). | `CYLRefreshBackFooter` `secondaryCloseTriggerOffset` |  |
| `CYLRefreshBackFooter.secondaryVelocity` (var) | A release at least this fast (dp per second), past the refresh trigger, opens the second floor (`secondaryVelocity`), as on iOS. | `CYLRefreshBackFooter` `secondaryVelocity` |  |
| `CYLRefreshBackFooter.secondaryView` (var) | The second floor's content, placed over the layout's lower part and slid in by the pull (`secondaryView`). | `CYLRefreshBackFooter` `secondaryView` |  |
| `CYLRefreshBackFooter.secondaryOpen` (val) | Whether the second floor is open (`secondaryOpen`). | `CYLRefreshBackFooter` `secondaryOpen` |  |
| `CYLRefreshBackFooter.secondaryOpenedBlock` (var) | Called after the second floor has opened (`secondaryOpenedBlock`). | `CYLRefreshBackFooter` `secondaryOpenedBlock` |  |
| `CYLRefreshBackFooter.secondaryClosedBlock` (var) | Called after the second floor has closed (`secondaryClosedBlock`). | `CYLRefreshBackFooter` `secondaryClosedBlock` |  |
| `CYLRefreshBackFooter.openSecondary` (fun) | Opens the second floor (`openSecondary`). | `CYLRefreshBackFooter` `-openSecondary` |  |
| `CYLRefreshBackFooter.closeSecondary` (fun) | Closes the second floor (`closeSecondary`). | `CYLRefreshBackFooter` `-closeSecondary` |  |
| `CYLRefreshBackStateFooter` (class) | The back footer with a state text (iOS `CYLRefreshBackStateFooter`). | `CYLRefreshBackStateFooter` |  |
| `CYLRefreshBackStateFooter.stateLabel` (val) | The state text (`stateLabel`). | `CYLRefreshBackStateFooter` `stateLabel` |  |
| `CYLRefreshBackStateFooter.labelLeftInset` (var) | The gap between the icon and the text, in dp (`labelLeftInset`). | `CYLRefreshBackStateFooter` `labelLeftInset` |  |
| `CYLRefreshBackStateFooter.setTitle` (fun) | The text of [state] (`setTitle:forState:`). | `CYLRefreshBackStateFooter` `-setTitle:forState:` |  |
| `CYLRefreshBackStateFooter.titleForState` (fun) | The text of [state] (`titleForState:`). | `CYLRefreshBackStateFooter` `-titleForState:` |  |
| `CYLRefreshBackNormalFooter` (class) | The back state footer with an arrow and a spinner (iOS `CYLRefreshBackNormalFooter`). | `CYLRefreshBackNormalFooter` |  |
| `CYLRefreshBackNormalFooter.noMoreDataImage` (var) | Shown beside the text while there is no more data (`noMoreDataImage`). | `CYLRefreshBackNormalFooter` `noMoreDataImage` |  |
| `CYLRefreshBackNormalFooter.arrowView` (val) | The arrow (`arrowView`). | `CYLRefreshBackNormalFooter` `arrowView` |  |
| `CYLRefreshBackNormalFooter.loadingView` (val) | The spinner (`loadingView`). | `CYLRefreshBackNormalFooter` `loadingView` |  |
| `CYLRefreshBackNormalFooter.iconSize` (var) | The arrow's and spinner's side, in dp (`iconSize`). | `CYLRefreshBackNormalFooter` `iconSize` |  |
| `CYLRefreshBackGifFooter` (class) | The back state footer with image frames per state (iOS `CYLRefreshBackGifFooter`). | `CYLRefreshBackGifFooter` |  |
| `CYLRefreshBackGifFooter.gifView` (val) | The view that shows the frames (`gifView`). | `CYLRefreshBackGifFooter` `gifView` |  |
| `CYLRefreshBackGifFooter.setImages` (fun) | The frames of [state], [duration] seconds in all (`setImages:duration:forState:`). | `CYLRefreshBackGifFooter` `-setImages:duration:forState:`, `CYLRefreshBackGifFooter` `-setImages:forState:` |  |
| `CYLRefreshBackGifFooter.setImages` (fun) | The frames of [state], 0.1 seconds each (`setImages:forState:`). | `CYLRefreshBackGifFooter` `-setImages:duration:forState:`, `CYLRefreshBackGifFooter` `-setImages:forState:` |  |
| `CYLRefreshBackGifFooter.setIconAnimationFilePath` (fun) | The animation file of [state], [width] by [height] dp, played by the player registered for its extension (GIF built in; Lottie, PAG and Rive with their modules) (`setIconAnimationFilePath:size:forState:`). | `CYLRefreshBackGifFooter` `setIconAnimationFilePath:size:forState:` | matched by the iOS name its KDoc cites |
| `CYLRefreshBackGifFooter.setIconAnimationAttributes` (fun) | The icon of [state] as attributes (`setIconAnimationAttributes:forState:`). | `CYLRefreshBackGifFooter` `setIconAnimationAttributes:forState:` | matched by the iOS name its KDoc cites |
| `CYLRefreshBackAnimationFooter` (class) | The back state footer with an animation per state (iOS `CYLRefreshBackAnimationFooter`). | `CYLRefreshBackAnimationFooter` |  |
| `CYLRefreshBackAnimationFooter.animationView` (val) | The view that shows the animation (`animationView`). | `CYLRefreshBackAnimationFooter` `animationView` |  |
| `CYLRefreshBackAnimationFooter.setAnimationImages` (fun) | The frames of [state], [duration] seconds in all (`setAnimationImages:duration:forState:`). | `CYLRefreshBackAnimationFooter` `-setAnimationImages:duration:forState:`, `CYLRefreshBackAnimationFooter` `-setAnimationImages:forState:` |  |
| `CYLRefreshBackAnimationFooter.setAnimationImages` (fun) | The frames of [state], 0.1 seconds each (`setAnimationImages:forState:`). | `CYLRefreshBackAnimationFooter` `-setAnimationImages:duration:forState:`, `CYLRefreshBackAnimationFooter` `-setAnimationImages:forState:` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshComponent.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshComponent` (class) |  | `CYLRefreshComponent`, `CYLRefreshComponent(CYLRefreshIconLayout)`, `CYLRefreshComponent(ChainingGrammar)` |  |
| `CYLRefreshComponent.view` (val) | The CYLRefreshLayout header or footer this component shows. | n/a | the CYLRefreshLayout view the component wraps; on iOS the component is the UIView itself |
| `CYLRefreshComponent.refreshLayout` (var) | The layout the component is attached to (the iOS `scrollView`'s counterpart), or null. | `CYLRefreshComponent` `scrollView` | matched by the iOS name its KDoc cites |
| `CYLRefreshComponent.scrollView` (val) | The scrolling content of the layout the component is attached to (`scrollView`). | `CYLRefreshComponent` `scrollView` |  |
| `CYLRefreshComponent.attached` (val) | Whether the component is attached to a layout (`attached`). | `CYLRefreshComponent` `attached` |  |
| `CYLRefreshComponent.fastAnimationDuration` (var) | The fast animation's duration, in seconds (`fastAnimationDuration`). | `CYLRefreshComponent` `fastAnimationDuration` |  |
| `CYLRefreshComponent.slowAnimationDuration` (var) | The slow animation's duration, in seconds (`slowAnimationDuration`). | `CYLRefreshComponent` `slowAnimationDuration` |  |
| `CYLRefreshComponent.setAnimationDisabled` (fun) | Sets both animation durations to 0 (`setAnimationDisabled`). | `CYLRefreshComponent` `-setAnimationDisabled` |  |
| `CYLRefreshComponent.refreshingBlock` (var) | Called when the component starts refreshing (`refreshingBlock`). | `CYLRefreshComponent` `refreshingBlock` |  |
| `CYLRefreshComponent.refreshingHandler` (var) | Called with the component when it starts refreshing (`refreshingHandler`), after [refreshingBlock]. | `CYLRefreshComponent` `refreshingHandler` |  |
| `CYLRefreshComponent.beginRefreshingCompletionBlock` (var) | Called once a refresh has begun (`beginRefreshingCompletionBlock`). | `CYLRefreshComponent` `beginRefreshingCompletionBlock` |  |
| `CYLRefreshComponent.endRefreshingAnimationBeginAction` (var) | Called when the closing animation of a refresh starts (`endRefreshingAnimationBeginAction`). | `CYLRefreshComponent` `endRefreshingAnimationBeginAction` |  |
| `CYLRefreshComponent.endRefreshingCompletionBlock` (var) | Called once a refresh has ended and closed (`endRefreshingCompletionBlock`). | `CYLRefreshComponent` `endRefreshingCompletionBlock` |  |
| `CYLRefreshComponent.executeRefreshingCallback` (fun) | Calls [refreshingBlock], [refreshingHandler], then [beginRefreshingCompletionBlock], in the iOS order (`executeRefreshingCallback`). | `CYLRefreshComponent` `-executeRefreshingCallback` |  |
| `CYLRefreshComponent.beginRefreshing` (fun) | Starts refreshing (`beginRefreshing`); before the layout is on screen, the state is [CYLRefreshState.WillRefresh] until it shows. | `CYLRefreshComponent` `-beginRefreshing` |  |
| `CYLRefreshComponent.beginRefreshingWithCompletionBlock` (fun) | Starts refreshing and calls [completion] once it has begun (`beginRefreshingWithCompletionBlock:`). | `CYLRefreshComponent` `-beginRefreshingWithCompletionBlock:` |  |
| `CYLRefreshComponent.endRefreshing` (fun) | Ends refreshing (`endRefreshing`). | `CYLRefreshComponent` `-endRefreshing` |  |
| `CYLRefreshComponent.endRefreshingWithCompletionBlock` (fun) | Ends refreshing and calls [completion] once it has closed (`endRefreshingWithCompletionBlock:`). | `CYLRefreshComponent` `-endRefreshingWithCompletionBlock:` |  |
| `CYLRefreshComponent.endRefreshingWithSuccess` (fun) | Ends refreshing, showing success or failure (`endRefreshingWithSuccess:`). | `CYLRefreshComponent` `-endRefreshingWithSuccess:` |  |
| `CYLRefreshComponent.lastRefreshSucceeded` (var) | Whether the last refresh succeeded (`lastRefreshSucceeded`). | `CYLRefreshComponent` `lastRefreshSucceeded` |  |
| `CYLRefreshComponent.isRefreshing` (val) | Whether the component is refreshing or about to (`refreshing`). | `CYLRefreshComponent` `refreshing` |  |
| `CYLRefreshComponent.state` (val) | The state (`state`). | `CYLRefreshComponent` `state` |  |
| `CYLRefreshComponent.phase` (var) | The detailed phase (`phase`). | `CYLRefreshComponent` `phase` |  |
| `CYLRefreshComponent.isInAnyPhase` (fun) | True when [phase] is one of [phases] (`isInAnyPhase:`). | `CYLRefreshComponent` `-isInAnyPhase:` |  |
| `CYLRefreshComponent.isInPhases` (fun) | True when [phase] is one of [phases] (`isInPhases:`). | `CYLRefreshComponent` `-isInPhases:` |  |
| `CYLRefreshComponent.addPhaseObserver` (fun) | Calls [observer] with the old and new phase on every change (`addPhaseObserver:`). | `CYLRefreshComponent` `-addPhaseObserver:` |  |
| `CYLRefreshComponent.removePhaseObserver` (fun) | Stops calling [observer] (`removePhaseObserver:`). | `CYLRefreshComponent` `-removePhaseObserver:` |  |
| `CYLRefreshComponent.pullingPercent` (var) | How far the component is pulled, as a share of its height (`pullingPercent`). | `CYLRefreshComponent` `pullingPercent` |  |
| `CYLRefreshComponent.dragOffset` (var) | How far the component is pulled, in pixels (`dragOffset`). | `CYLRefreshComponent` `dragOffset` |  |
| `CYLRefreshComponent.automaticallyChangeAlpha` (var) | The component's alpha follows [pullingPercent] while it is pulled (`automaticallyChangeAlpha`). | `CYLRefreshComponent` `automaticallyChangeAlpha` |  |
| `CYLRefreshComponent.refreshEnabled` (var) | Whether pulling can refresh at all (`refreshEnabled`). | `CYLRefreshComponent` `refreshEnabled` |  |
| `CYLRefreshComponent.triggerRate` (var) | The share of the component's height to pull before releasing refreshes (`triggerRate`). | `CYLRefreshComponent` `triggerRate` |  |
| `CYLRefreshComponent.finishDuration` (var) | How long the finished text stays, in seconds (`finishDuration`); used by the classic header and footer. | `CYLRefreshComponent` `finishDuration` |  |
| `CYLRefreshComponent.scrollMode` (var) | How the component moves with the pull (`scrollMode`); the classic header and footer change their spinner style. | `CYLRefreshComponent` `scrollMode` |  |
| `CYLRefreshComponent.colorAccent` (var) | The accent color (text and icons), or 0 for the component's own (`colorAccent`). | `CYLRefreshComponent` `colorAccent` |  |
| `CYLRefreshComponent.colorPrimary` (var) | The primary color (background), or 0 for the component's own (`colorPrimary`). | `CYLRefreshComponent` `colorPrimary` |  |
| `CYLRefreshComponent.hapticFeedback` (var) | Vibrates once when the pull passes the trigger (`hapticFeedback`). | `CYLRefreshComponent` `hapticFeedback` |  |
| `CYLRefreshComponent.exclusiveWithOtherRefresh` (var) | Whether a refresh and a load exclude each other (`exclusiveWithOtherRefresh`). | `CYLRefreshComponent` `exclusiveWithOtherRefresh` | partial (see docs/Android-API-Map.md) |
| `CYLRefreshComponent.blockedByOtherRefreshBlock` (var) | Called when [beginRefreshing] is refused because the other component is busy (`blockedByOtherRefreshBlock`). | `CYLRefreshComponent` `blockedByOtherRefreshBlock` |  |
| `CYLRefreshComponent.expanded` (val) | Whether the component holds its refreshing position (`expanded`). | `CYLRefreshComponent` `expanded` |  |
| `CYLRefreshComponent.expandHeight` (val) | The component's height when open, in pixels (`expandHeight`). | `CYLRefreshComponent` `expandHeight` |  |
| `CYLRefreshComponent.maxPullDistance` (var) | The farthest the component can be pulled open, in dp; 0 for no limit of its own (`maxPullDistance`). | `CYLRefreshComponent` `maxPullDistance` |  |
| `CYLRefreshComponent.notifiesWhenHidden` (var) | Whether the component keeps reporting the pull while its view is hidden (`notifiesWhenHidden`). | `CYLRefreshComponent` `notifiesWhenHidden` |  |
| `CYLRefreshComponent.triggersWhenReached` (var) | Whether reaching the trigger starts at once, without a release (`triggersWhenReached`): a footer loads when reached (CYLRefreshLayout's auto load more); a header refreshes as soon as the pull arms it (iOS CYLRefreshHeade | `CYLRefreshComponent` `triggersWhenReached` |  |
| `CYLRefreshComponent.triggerMode` (var) | Where a pull may start (`triggerMode`): [CYLRefreshTriggerMode.Anywhere] (default) also lets a drag that started in the middle of the list carry on into the pull; [CYLRefreshTriggerMode.OnEdge] only a drag that started a | `CYLRefreshComponent` `triggerMode` |  |
| `CYLRefreshComponent.autoHideRefresh` (var) | Whether the component hides while it has nothing to show (`autoHideRefresh`). | `CYLRefreshComponent` `autoHideRefresh` |  |
| `CYLRefreshComponent.isReadyToAutoHide` (fun) | Whether the component is at rest and not pulled, so auto hide may hide it (`isReadyToAutoHide`). | `CYLRefreshComponent` `-isReadyToAutoHide` |  |
| `CYLRefreshComponent.updateAutoHideVisibility` (fun) | Applies [autoHideRefresh] now (`updateAutoHideVisibility`). | `CYLRefreshComponent` `-updateAutoHideVisibility` |  |
| `CYLRefreshComponent.beginRefreshingWithDuration` (fun) | Starts refreshing with an opening animation of [duration] seconds that overshoots by [overOffset] pixels; with [force], also when a pull is under way (`beginRefreshingWithDuration:overOffset:force:`). | `CYLRefreshComponent` `-beginRefreshingWithDuration:overOffset:force:` |  |
| `CYLRefreshComponent.attach` (fun) | Attaches the component to [layout] (`attach:`), replacing its header (or footer). | `CYLRefreshComponent` `+attach:`, `CYLRefreshComponent` `-attach:` |  |
| `CYLRefreshComponent.finishingDurationWithSuccess` (fun) | How long the finished state shows, in seconds (`finishingDurationWithSuccess:`). | `CYLRefreshComponent` `-finishingDurationWithSuccess:` |  |
| `CYLRefreshComponent.cyl_autoChangeTransparency` (fun) | Sets [automaticallyChangeAlpha] (`cyl_autoChangeTransparency:`). | `CYLRefreshComponent(ChainingGrammar)` `-cyl_autoChangeTransparency:` |  |
| `CYLRefreshComponent.cyl_afterBeginningAction` (fun) | Sets [beginRefreshingCompletionBlock] (`cyl_afterBeginningAction:`). | `CYLRefreshComponent(ChainingGrammar)` `-cyl_afterBeginningAction:` |  |
| `CYLRefreshComponent.cyl_endingAnimationBeginningAction` (fun) | Sets [endRefreshingAnimationBeginAction] (`cyl_endingAnimationBeginningAction:`). | `CYLRefreshComponent(ChainingGrammar)` `-cyl_endingAnimationBeginningAction:` |  |
| `CYLRefreshComponent.cyl_afterEndingAction` (fun) | Sets [endRefreshingCompletionBlock] (`cyl_afterEndingAction:`). | `CYLRefreshComponent(ChainingGrammar)` `-cyl_afterEndingAction:` |  |
| `CYLRefreshComponent.cyl_linkTo` (fun) | Attaches the component to [layout] (`cyl_linkTo:`). | `CYLRefreshComponent(ChainingGrammar)` `-cyl_linkTo:` |  |
| `CYLRefreshHeader` (class) | The iOS `CYLRefreshHeader` on Android: pull down to refresh. | `CYLRefreshHeader` |  |
| `CYLRefreshHeader.lastUpdatedTimeKey` (var) | The key the last update time is stored under (`lastUpdatedTimeKey`). | `CYLRefreshHeader` `lastUpdatedTimeKey` |  |
| `CYLRefreshHeader.lastUpdatedTime` (val) | When the header last finished refreshing, or null (`lastUpdatedTime`), kept across launches. | `CYLRefreshHeader` `lastUpdatedTime` |  |
| `CYLRefreshHeader.ignoredScrollViewContentInsetTop` (var) | The top inset the header ignores, in dp (`ignoredScrollViewContentInsetTop`): the layout's header inset start. | `CYLRefreshHeader` `ignoredScrollViewContentInsetTop` |  |
| `CYLRefreshHeader.addsRefreshingInset` (var) | Whether the content moves down to keep the refreshing header in sight (`addsRefreshingInset`). | `CYLRefreshHeader` `addsRefreshingInset` |  |
| `CYLRefreshHeader.resetsFooterAfterRefresh` (var) | Whether a finished refresh resets the footer's "no more data" (`resetsFooterAfterRefresh`). | `CYLRefreshHeader` `resetsFooterAfterRefresh` |  |
| `CYLRefreshHeader.secondaryTriggerOffset` (var) | Pulling this far and releasing opens the second floor instead of refreshing, in dp; 0 for never (`secondaryTriggerOffset`). | `CYLRefreshHeader` `secondaryTriggerOffset` |  |
| `CYLRefreshHeader.secondaryDimension` (var) | The open second floor's height, in dp; 0 for the layout's height (`secondaryDimension`). | `CYLRefreshHeader` `secondaryDimension` |  |
| `CYLRefreshHeader.secondaryCloseTriggerOffset` (var) | Pushing the open second floor up this far and releasing closes it, in dp (`secondaryCloseTriggerOffset`). | `CYLRefreshHeader` `secondaryCloseTriggerOffset` |  |
| `CYLRefreshHeader.secondaryVelocity` (var) | A release at least this fast (dp per second), past the refresh trigger, opens the second floor (`secondaryVelocity`), as on iOS. | `CYLRefreshHeader` `secondaryVelocity` |  |
| `CYLRefreshHeader.secondaryView` (var) | The second floor's content, placed over the layout and slid in by the pull (`secondaryView`); the layout's parent should be a FrameLayout. | `CYLRefreshHeader` `secondaryView` |  |
| `CYLRefreshHeader.secondaryOpen` (val) | Whether the second floor is open (`secondaryOpen`). | `CYLRefreshHeader` `secondaryOpen` |  |
| `CYLRefreshHeader.secondaryOpenedBlock` (var) | Called after the second floor has opened (`secondaryOpenedBlock`). | `CYLRefreshHeader` `secondaryOpenedBlock` |  |
| `CYLRefreshHeader.secondaryClosedBlock` (var) | Called after the second floor has closed (`secondaryClosedBlock`). | `CYLRefreshHeader` `secondaryClosedBlock` |  |
| `CYLRefreshHeader.openSecondary` (fun) | Opens the second floor (`openSecondary`). | `CYLRefreshHeader` `-openSecondary` |  |
| `CYLRefreshHeader.closeSecondary` (fun) | Closes the second floor (`closeSecondary`). | `CYLRefreshHeader` `-closeSecondary` |  |
| `CYLRefreshHeader.setExpandHeight` (fun) | The header's height, in dp (`setExpandHeight:`). | `CYLRefreshHeader` `-setExpandHeight:` |  |
| `CYLRefreshHeader.headerWithRefreshingBlock` (fun) | A classic header calling [block] when it refreshes (`headerWithRefreshingBlock:`). | `CYLRefreshHeader` `+headerWithRefreshingBlock:` |  |
| `CYLRefreshFooter` (class) | The iOS `CYLRefreshFooter` on Android: pull up to load more. | `CYLRefreshFooter` |  |
| `CYLRefreshFooter.noMoreData` (var) | Whether there is no more data (`noMoreData`). | `CYLRefreshFooter` `noMoreData` |  |
| `CYLRefreshFooter.ignoredScrollViewContentInsetBottom` (var) | The bottom inset the footer ignores, in dp (`ignoredScrollViewContentInsetBottom`): the layout's footer inset start. | `CYLRefreshFooter` `ignoredScrollViewContentInsetBottom` |  |
| `CYLRefreshFooter.loadsAfterNoMoreData` (var) | Whether a pull still loads after "no more data" (`loadsAfterNoMoreData`); when on, a pull clears "no more data" first. | `CYLRefreshFooter` `loadsAfterNoMoreData` |  |
| `CYLRefreshFooter.endRefreshingWithNoMoreData` (fun) | Ends loading and shows "no more data" (`endRefreshingWithNoMoreData`). | `CYLRefreshFooter` `-endRefreshingWithNoMoreData` |  |
| `CYLRefreshFooter.noticeNoMoreData` (fun) | Shows "no more data" (`noticeNoMoreData`). | `CYLRefreshFooter` `-noticeNoMoreData` |  |
| `CYLRefreshFooter.resetNoMoreData` (fun) | Clears "no more data" (`resetNoMoreData`). | `CYLRefreshFooter` `-resetNoMoreData` |  |
| `CYLRefreshFooter.footerWithRefreshingBlock` (fun) | A classic footer calling [block] when it loads (`footerWithRefreshingBlock:`). | `CYLRefreshFooter` `+footerWithRefreshingBlock:` |  |
| `cyl_header` (var) | The layout's header component (the iOS `UIScrollView.cyl_header`); setting it attaches it. | `cyl_header` | matched by the iOS name its KDoc cites |
| `cyl_footer` (var) | The layout's footer component (the iOS `UIScrollView.cyl_footer`); setting it attaches it. | `cyl_footer` | matched by the iOS name its KDoc cites |
| `cyl_autoHideRefresh` (var) | Hides both components while they have nothing to show (the iOS `UIScrollView.cyl_autoHideRefresh`). | `cyl_autoHideRefresh` | matched by the iOS name its KDoc cites |
| `cyl_autoHideRefreshHeader` (var) | Hides the header while it has nothing to show (`cyl_autoHideRefreshHeader`). | `cyl_autoHideRefreshHeader` | matched by the iOS name its KDoc cites |
| `cyl_autoHideRefreshFooter` (var) | Hides the footer while it has nothing to show (`cyl_autoHideRefreshFooter`). | `cyl_autoHideRefreshFooter` | matched by the iOS name its KDoc cites |
| `cyl_beginRefreshingWithStartHeader` (fun) | Attaches [startHeader] and starts refreshing with it (`cyl_beginRefreshingWithStartHeader:`). | `cyl_beginRefreshingWithStartHeader:` | matched by the iOS name its KDoc cites |
| `cyl_totalDataCount` (fun) | The number of rows of the list inside the layout, 0 when it holds no RecyclerView with an adapter (`cyl_totalDataCount`). | `cyl_totalDataCount` | matched by the iOS name its KDoc cites |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshConst.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshConst` (object) | The iOS constants of `CYLRefreshConst.h`, with the same names and values (docs/Android-API-Map.md). | `CYLRefreshConst.h` | matched by the iOS name its KDoc cites |
| `CYLRefreshConst.CYLRefreshLabelLeftInset` (val) | The gap between the state label and the arrow, in dp. | `CYLRefreshLabelLeftInset` |  |
| `CYLRefreshConst.CYLRefreshHeaderHeight` (val) | The header's height, in dp. | `CYLRefreshHeaderHeight` |  |
| `CYLRefreshConst.CYLRefreshFooterHeight` (val) | The footer's height, in dp. | `CYLRefreshFooterHeight` |  |
| `CYLRefreshConst.CYLRefreshTrailWidth` (val) | The trailer's width, in dp. | `CYLRefreshTrailWidth` |  |
| `CYLRefreshConst.CYLRefreshFastAnimationDuration` (val) | The fast animation's duration, in seconds. | `CYLRefreshFastAnimationDuration` |  |
| `CYLRefreshConst.CYLRefreshSlowAnimationDuration` (val) | The slow animation's duration, in seconds. | `CYLRefreshSlowAnimationDuration` |  |
| `CYLRefreshConst.CYLRefreshKeyPathContentOffset` (val) | The key path of a scroll view's content offset (an iOS key-value observing name, kept for portable code). | `CYLRefreshKeyPathContentOffset` |  |
| `CYLRefreshConst.CYLRefreshKeyPathContentInset` (val) | The key path of a scroll view's content inset. | `CYLRefreshKeyPathContentInset` |  |
| `CYLRefreshConst.CYLRefreshKeyPathContentSize` (val) | The key path of a scroll view's content size. | `CYLRefreshKeyPathContentSize` |  |
| `CYLRefreshConst.CYLRefreshKeyPathPanState` (val) | The key path of a pan gesture's state. | `CYLRefreshKeyPathPanState` |  |
| `CYLRefreshConst.CYLRefreshHeaderLastUpdatedTimeKey` (val) | The default key under which a header stores its last update time. | `CYLRefreshHeaderLastUpdatedTimeKey` |  |
| `CYLRefreshConst.CYLRefreshHeaderIdleText` (val) | Text key: the header at rest. | `CYLRefreshHeaderIdleText` |  |
| `CYLRefreshConst.CYLRefreshHeaderPullingText` (val) | Text key: the header pulled past the trigger. | `CYLRefreshHeaderPullingText` |  |
| `CYLRefreshConst.CYLRefreshHeaderRefreshingText` (val) | Text key: the header refreshing. | `CYLRefreshHeaderRefreshingText` |  |
| `CYLRefreshConst.CYLRefreshTrailerIdleText` (val) | Text key: the trailer at rest. | `CYLRefreshTrailerIdleText` |  |
| `CYLRefreshConst.CYLRefreshTrailerPullingText` (val) | Text key: the trailer pulled past the trigger. | `CYLRefreshTrailerPullingText` |  |
| `CYLRefreshConst.CYLRefreshAutoFooterIdleText` (val) | Text key: the automatic footer at rest. | `CYLRefreshAutoFooterIdleText` |  |
| `CYLRefreshConst.CYLRefreshAutoFooterRefreshingText` (val) | Text key: the automatic footer loading. | `CYLRefreshAutoFooterRefreshingText` |  |
| `CYLRefreshConst.CYLRefreshAutoFooterNoMoreDataText` (val) | Text key: the automatic footer with no more data. | `CYLRefreshAutoFooterNoMoreDataText` |  |
| `CYLRefreshConst.CYLRefreshBackFooterIdleText` (val) | Text key: the back footer at rest. | `CYLRefreshBackFooterIdleText` |  |
| `CYLRefreshConst.CYLRefreshBackFooterPullingText` (val) | Text key: the back footer pulled past the trigger. | `CYLRefreshBackFooterPullingText` |  |
| `CYLRefreshConst.CYLRefreshBackFooterRefreshingText` (val) | Text key: the back footer loading. | `CYLRefreshBackFooterRefreshingText` |  |
| `CYLRefreshConst.CYLRefreshBackFooterNoMoreDataText` (val) | Text key: the back footer with no more data. | `CYLRefreshBackFooterNoMoreDataText` |  |
| `CYLRefreshConst.CYLRefreshHeaderFinishedText` (val) | Text key: the header after a successful refresh. | `CYLRefreshHeaderFinishedText` |  |
| `CYLRefreshConst.CYLRefreshHeaderFailedText` (val) | Text key: the header after a failed refresh. | `CYLRefreshHeaderFailedText` |  |
| `CYLRefreshConst.CYLRefreshFooterFinishedText` (val) | Text key: the footer after a successful load. | `CYLRefreshFooterFinishedText` |  |
| `CYLRefreshConst.CYLRefreshFooterFailedText` (val) | Text key: the footer after a failed load. | `CYLRefreshFooterFailedText` |  |
| `CYLRefreshConst.CYLRefreshHeaderLastTimeText` (val) | Text key: the "last update" prefix. | `CYLRefreshHeaderLastTimeText` |  |
| `CYLRefreshConst.CYLRefreshHeaderDateTodayText` (val) | Text key: "today" in the last update time. | `CYLRefreshHeaderDateTodayText` |  |
| `CYLRefreshConst.CYLRefreshHeaderNoneLastDateText` (val) | Text key: no last update yet. | `CYLRefreshHeaderNoneLastDateText` |  |
| `CYLRefreshConst.CYLRefreshDidChangeLanguageNotification` (val) | The name of the notice sent when the refresh texts' language changes. | `CYLRefreshDidChangeLanguageNotification` |  |
| `CYLRefreshState` (enum) | A refresh component's state (`CYLRefreshState`). | `CYLRefreshState` |  |
| `CYLRefreshScrollMode` (enum) | How the component moves with the pull (`CYLRefreshScrollMode`); on Android, CYLRefreshLayout's spinner style. | `CYLRefreshScrollMode` |  |
| `CYLRefreshTriggerMode` (enum) | Where a pull may start (`CYLRefreshTriggerMode`). | `CYLRefreshTriggerMode` |  |
| `CYLRefreshPhase` (enum) | A refresh component's detailed phase (`CYLRefreshPhase`). | `CYLRefreshPhase` |  |
| `CYLRefreshComponentRefreshingBlock` (typealias) | Called when a component starts refreshing (`CYLRefreshComponentRefreshingBlock`). | `CYLRefreshComponentRefreshingBlock` |  |
| `CYLRefreshComponentBeginRefreshingCompletionBlock` (typealias) | Called once a refresh has begun (`CYLRefreshComponentBeginRefreshingCompletionBlock`). | `CYLRefreshComponentBeginRefreshingCompletionBlock` |  |
| `CYLRefreshComponentEndRefreshingCompletionBlock` (typealias) | Called once a refresh has ended and closed (`CYLRefreshComponentEndRefreshingCompletionBlock`). | `CYLRefreshComponentEndRefreshingCompletionBlock` |  |
| `CYLRefreshComponentAction` (typealias) | A plain action (`CYLRefreshComponentAction`). | `CYLRefreshComponentAction` |  |
| `CYLRefreshComponentHandler` (typealias) | A handler given the component (`CYLRefreshComponentHandler`). | `CYLRefreshComponentHandler` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshCupertino.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLActivityIndicatorView` (class) | The twelve-spoke spinner of the iOS system (`UIActivityIndicatorView`): spokes appear as you pull and one fading tail turns while it animates. | `UIActivityIndicatorView` | matched by the iOS name its KDoc cites |
| `CYLActivityIndicatorView.isAnimating` (var) | Whether the tail is turning (`isAnimating`). | `UIActivityIndicatorView` `isAnimating` (UIKit) | Android draws the iOS system spinner; iOS uses the system view |
| `CYLActivityIndicatorView.progress` (var) | How much of the spokes shows while pulling, 0 to 1 (`progress`). | `CYLActivityIndicatorView` `progress` | matched by the iOS name its KDoc cites |
| `CYLActivityIndicatorView.color` (var) | The spokes' color (`color`). | `CYLActivityIndicatorView` `color` | matched by the iOS name its KDoc cites |
| `CYLActivityIndicatorView.startAnimating` (fun) | Starts turning (`startAnimating`). | `UIActivityIndicatorView` `-startAnimating` (UIKit) |  |
| `CYLActivityIndicatorView.stopAnimating` (fun) | Stops turning (`stopAnimating`). | `UIActivityIndicatorView` `-stopAnimating` (UIKit) |  |
| `CYLRefreshCupertinoHeader` (class) | A header with the system spinner (iOS `CYLRefreshCupertinoHeader`). | `CYLRefreshCupertinoHeader` |  |
| `CYLRefreshCupertinoHeader.activityIndicator` (val) | The spinner (`activityIndicator`). | `CYLRefreshCupertinoHeader` `activityIndicator` |  |
| `CYLRefreshCupertinoFooter` (class) | A footer with the system spinner that loads when the end is reached (iOS `CYLRefreshCupertinoFooter`). | `CYLRefreshCupertinoFooter` |  |
| `CYLRefreshCupertinoFooter.activityIndicator` (val) | The spinner (`activityIndicator`). | `CYLRefreshCupertinoFooter` `activityIndicator` |  |
| `CYLRefreshDrawnFooter` (class) | A back footer drawn like a header style, upside down (iOS `CYLRefreshDrawnFooter`). | `CYLRefreshDrawnFooter`, `CYLRefreshDrawnFooter` `-initWithStyle:` |  |
| `CYLRefreshDrawnFooter.style` (val) | The header whose drawing the footer shows (`style`). | `CYLRefreshDrawnFooter` `style` |  |
| `CYLRefreshDrawnFooter.styleClass` (val) | The header class this footer draws (`styleClass`): CYLRefreshMaterialHeader for CYLRefreshMaterialFooter, and so on. | `CYLRefreshDrawnFooter` `styleClass` |  |
| `CYLRefreshBezierRadarFooter` (class) | The Bezier radar below the list (iOS `CYLRefreshBezierRadarFooter`). | `CYLRefreshBezierRadarFooter` |  |
| `CYLRefreshMaterialFooter` (class) | The Material spinner below the list (iOS `CYLRefreshMaterialFooter`). | `CYLRefreshMaterialFooter` |  |
| `CYLRefreshDeliveryFooter` (class) | The delivery box below the list (iOS `CYLRefreshDeliveryFooter`). | `CYLRefreshDeliveryFooter` |  |
| `CYLRefreshPhoenixFooter` (class) | The sunrise below the list (iOS `CYLRefreshPhoenixFooter`). | `CYLRefreshPhoenixFooter` |  |
| `CYLRefreshTaurusFooter` (class) | The plane among clouds below the list (iOS `CYLRefreshTaurusFooter`). | `CYLRefreshTaurusFooter` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshDrawn.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshDrawnHeader` (class) | A header drawn in code, with the hooks its subclasses override (iOS `CYLRefreshDrawnHeader`). | `CYLRefreshDrawnHeader` |  |
| `CYLRefreshDrawnHeader.width` (val) | The header's width, in pixels (`width`). | `CYLRefreshDrawnHeader` `width` |  |
| `CYLRefreshDrawnHeader.height` (val) | The header's height, in pixels (`height`). | `CYLRefreshDrawnHeader` `height` |  |
| `CYLRefreshDrawnHeader.durationFast` (var) | The fast animation's duration, in seconds (`durationFast`). | `CYLRefreshDrawnHeader` `durationFast` |  |
| `CYLRefreshDrawnHeader.durationNormal` (var) | The normal animation's duration, in seconds (`durationNormal`). | `CYLRefreshDrawnHeader` `durationNormal` |  |
| `CYLRefreshDrawnHeader.status` (val) | The phase (`status`). | `CYLRefreshDrawnHeader` `status` |  |
| `CYLRefreshDrawnHeader.dragPercent` (val) | How far the header is pulled, as a share of its height (`dragPercent`). | `CYLRefreshDrawnHeader` `dragPercent` |  |
| `CYLRefreshDrawnHeader.isSuccess` (val) | Whether the last refresh succeeded (`isSuccess`). | `CYLRefreshDrawnHeader` `isSuccess` |  |
| `CYLRefreshDrawnHeader.beginRefresh` (fun) | Starts refreshing (`beginRefresh`). | `CYLRefreshDrawnHeader` `-beginRefresh` |  |
| `CYLRefreshDrawnHeader.finishRefresh` (fun) | Ends refreshing (`finishRefresh`). | `CYLRefreshDrawnHeader` `-finishRefresh` |  |
| `CYLRefreshDrawnHeader.finishRefreshWithSuccess` (fun) | Ends refreshing with success or failure (`finishRefreshWithSuccess:`). | `CYLRefreshDrawnHeader` `-finishRefreshWithSuccess:` |  |
| `CYLRefreshDrawnHeader.inStatus` (fun) | True when the phase is one of [statuses] (`inStatus:`). | `CYLRefreshDrawnHeader` `-inStatus:` |  |
| `CYLRefreshMaterialHeader` (class) | The Material circle spinner (iOS `CYLRefreshMaterialHeader`). | `CYLRefreshMaterialHeader` |  |
| `CYLRefreshBezierCircleHeader` (class) | The Bezier circle (iOS `CYLRefreshBezierCircleHeader`). | `CYLRefreshBezierCircleHeader` |  |
| `CYLRefreshBezierRadarHeader` (class) | The Bezier radar (iOS `CYLRefreshBezierRadarHeader`). | `CYLRefreshBezierRadarHeader` |  |
| `CYLRefreshDeliveryHeader` (class) | The delivery box and balloon (iOS `CYLRefreshDeliveryHeader`). | `CYLRefreshDeliveryHeader` |  |
| `CYLRefreshDropBoxHeader` (class) | The drop box (iOS `CYLRefreshDropBoxHeader`). | `CYLRefreshDropBoxHeader` |  |
| `CYLRefreshFlyHeader` (class) | The paper plane (iOS `CYLRefreshFlyHeader`): like iOS, it brings its own scene. | `CYLRefreshFlyHeader` |  |
| `CYLRefreshFlyHeader.mountainView` (val) | The mountains above the content (`mountainView`). | `CYLRefreshFlyHeader` `mountainView` | added 2026-11-16 for Android parity |
| `CYLRefreshFlyHeader.flyView` (val) | The paper plane (`flyView`). | `CYLRefreshFlyHeader` `flyView` | added 2026-11-16 for Android parity |
| `CYLRefreshFlyHeader.floatView` (val) | The round button under the plane, in the primary color (`floatView`). | `CYLRefreshFlyHeader` `floatView` | added 2026-11-16 for Android parity |
| `CYLRefreshGameHeader` (class) | A header with a small game to play while refreshing (iOS `CYLRefreshGameHeader`). | `CYLRefreshGameHeader` |  |
| `CYLRefreshGameBattleCityHeader` (class) | The tank game (iOS `CYLRefreshGameBattleCityHeader`). | `CYLRefreshGameBattleCityHeader` |  |
| `CYLRefreshGameHitBlockHeader` (class) | The block-breaking game (iOS `CYLRefreshGameHitBlockHeader`). | `CYLRefreshGameHitBlockHeader` |  |
| `CYLRefreshPhoenixHeader` (class) | The sunrise over a town (iOS `CYLRefreshPhoenixHeader`). | `CYLRefreshPhoenixHeader` |  |
| `CYLRefreshTaurusHeader` (class) | The plane among clouds (iOS `CYLRefreshTaurusHeader`). | `CYLRefreshTaurusHeader` |  |
| `CYLRefreshWaveSwipeHeader` (class) | The wave and drop (iOS `CYLRefreshWaveSwipeHeader`). | `CYLRefreshWaveSwipeHeader` |  |
| `CYLRefreshOriginalHeader` (class) | CYLRefreshLayout's original classic header (iOS `CYLRefreshOriginalHeader`). | `CYLRefreshOriginalHeader` |  |
| `CYLRefreshOriginalHeader.enableAutoRefresh` (var) | Whether the header refreshes by itself once attached (`enableAutoRefresh`). | `CYLRefreshOriginalHeader` `enableAutoRefresh` |  |
| `CYLRefreshStoreHouseHeader` (class) | Text drawn as line segments that assemble as you pull (iOS `CYLRefreshStoreHouseHeader`). | `CYLRefreshStoreHouseHeader` |  |
| `CYLRefreshStoreHouseHeader.lineWidth` (var) | The lines' width, in pixels (`lineWidth`). | `CYLRefreshStoreHouseHeader` `lineWidth` |  |
| `CYLRefreshStoreHouseHeader.enableReverseFlash` (var) | Whether the loading flash runs back and forth (`enableReverseFlash`). | `CYLRefreshStoreHouseHeader` `enableReverseFlash` |  |
| `CYLRefreshStoreHouseHeader.enableFadeAnimation` (var) | Whether the lines fade in as they assemble with the pull (`enableFadeAnimation`); false shows them at full alpha. | `CYLRefreshStoreHouseHeader` `enableFadeAnimation` |  |
| `CYLRefreshStoreHouseHeader.initLinesWithString` (fun) | Draws [string] at the default size (`initLinesWithString:`). | `CYLRefreshStoreHouseHeader` `-initLinesWithString:`, `CYLRefreshStoreHouseHeader` `-initLinesWithString:scale:`, `CYLRefreshStoreHouseHeader` `-initLinesWithString:scale:padding:` |  |
| `CYLRefreshStoreHouseHeader.initLinesWithString` (fun) | Draws [string] scaled by [scale] (`initLinesWithString:scale:`). | `CYLRefreshStoreHouseHeader` `-initLinesWithString:`, `CYLRefreshStoreHouseHeader` `-initLinesWithString:scale:`, `CYLRefreshStoreHouseHeader` `-initLinesWithString:scale:padding:` |  |
| `CYLRefreshStoreHouseHeader.initLinesWithString` (fun) | Draws [string] scaled by [scale]; [padding] is the drop height above the text, in pixels (`initLinesWithString:scale:padding:`). | `CYLRefreshStoreHouseHeader` `-initLinesWithString:`, `CYLRefreshStoreHouseHeader` `-initLinesWithString:scale:`, `CYLRefreshStoreHouseHeader` `-initLinesWithString:scale:padding:` |  |
| `CYLRefreshStoreHouseHeader.initLinesWithArray` (fun) | Draws lines given as "x1,y1,x2,y2" strings (`initLinesWithArray:`). | `CYLRefreshStoreHouseHeader` `-initLinesWithArray:`, `CYLRefreshStoreHouseHeader` `-initLinesWithArray:padding:` |  |
| `CYLRefreshStoreHouseHeader.initLinesWithArray` (fun) | Draws lines given as "x1,y1,x2,y2" strings, with [padding] as the drop height (`initLinesWithArray:padding:`). | `CYLRefreshStoreHouseHeader` `-initLinesWithArray:`, `CYLRefreshStoreHouseHeader` `-initLinesWithArray:padding:` |  |
| `CYLRefreshStoreHouseHeader.newWithString` (fun) | A header drawing [string] (`newWithString:`). | `CYLRefreshStoreHouseHeader` `+newWithString:`, `CYLRefreshStoreHouseHeader` `+newWithString:scale:`, `CYLRefreshStoreHouseHeader` `+newWithString:scale:padding:` |  |
| `CYLRefreshStoreHouseHeader.newWithString` (fun) | A header drawing [string] scaled by [scale] (`newWithString:scale:`). | `CYLRefreshStoreHouseHeader` `+newWithString:`, `CYLRefreshStoreHouseHeader` `+newWithString:scale:`, `CYLRefreshStoreHouseHeader` `+newWithString:scale:padding:` |  |
| `CYLRefreshStoreHouseHeader.newWithString` (fun) | A header drawing [string] scaled by [scale], with [padding] (`newWithString:scale:padding:`). | `CYLRefreshStoreHouseHeader` `+newWithString:`, `CYLRefreshStoreHouseHeader` `+newWithString:scale:`, `CYLRefreshStoreHouseHeader` `+newWithString:scale:padding:` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshDriven.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshDrivenLayout` (class) | The driven mode of the refresh kernel (docs/Refresh-Library-Parity.md, native bridge map): a [CYLRefreshLayout] that is driven from outside. | `CYLRefreshDrivenLayout` | Swift UIView with an internal content-less scroll view whose isDragging is the driven flag; header only (a negative offset, the footer, is treated as rest) |
| `CYLRefreshDrivenLayout.drive` (fun) | Feeds the pull: [offset] pixels past the edge (positive pulls the header, negative the footer, 0 is rest); [dragging] says whether a finger holds the content; [startedAtEdge] whether the drag began at the edge, which a [ | `CYLRefreshDrivenLayout` `drive(offset:dragging:startedAtEdge:)` |  |
| `CYLRefreshDrivenLayout.release` (fun) | Feeds the lifted finger: an armed component starts refreshing, a short pull is canceled (`handleRelease`). | `CYLRefreshDrivenLayout` `release()` |  |
| `CYLRefreshDrivenLayout.shownPull` (val) | The pull the layout shows now, in pixels (>= 0): the spinner's size, or the footer's height while "no more data" holds it in. | n/a | read by the Android Flutter slot every frame (the spinner rebounds without a call); the iOS host anchors its own slot in CYLRefreshDrivenHost |
| `CYLRefreshDrivenLayout.indicatorExtent` (val) | The indicator's own (intrinsic) height in pixels: the footer's for a layout with a footer, else the header's. | n/a | the Android slot rule's header height (mHeaderHeight is protected there); iOS reads the header's frame |
| `CYLRefreshDrivenLayout.onBeforeDraw` (var) | Called before every frame this layout draws (the hook that holds the "no more data" footer): the host re-fits its slot. | n/a | Android re-fits the slot in the pre-draw hook; iOS lays out in layoutSubviews |
| `CYLRefreshDrivenLayout.slotHeight` (fun) | The height, in pixels, a driven layout takes in a slot that is [slotHeight] tall and shows only the pulled part of the indicator (the Flutter plugin's slot, anchored at the bottom edge for a header and the top edge for a | `CYLRefreshDrivenHost.updateSlot()` (the Flutter iOS plugin sizes the layout to the pull and anchors it at the slot edge: the Slot rule in docs/Refresh-Library-Parity.md) | iOS has no public property: the host owns the slot rule, `CYLRefreshDrivenLayout` itself is sized by its frame |
| `CYLRefreshDrivenLayout.anchorShift` (fun) | How far, in pixels, the host moves a layout of [height] pixels so an indicator that sits [shown] pixels into it ends at the slot's edge: down for a header, up (negative) for a [footer]. | n/a | Android moves the layout by translationY to keep the header at the slot edge; the iOS host anchors its view at the edge |
| `CYLRefreshDrivenLayout.behindShift` (fun) | The same for a slot whose indicator stays put while the content moves over it (Flutter's `behind` scroll mode): the layout is as tall as the whole slot and the indicator ends at the slot's FAR edge (top for a header, bot | `CYLRefreshDrivenLayout` `behind` | matched by the iOS name its KDoc cites |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshIconView.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshIconView` (class) | The icon of a refresh component: one animation (or image sequence) per state, with an optional title (iOS `CYLRefreshIconView`). | `CYLRefreshIconView`, `CYLRefreshIconView(CYLRefreshIconAttributes)` |  |
| `CYLRefreshIconView.placeholderView` (val) | The view that shows the icon and the title (`placeholderView`). | `CYLRefreshIconView` `placeholderView` |  |
| `CYLRefreshIconView.setAnimationAttributes` (fun) | The icon of [state] (`setAnimationAttributes:forState:`): [ANIMATION_FILE_PATH] (a file for a registered player), [IMAGES] (a list of drawables) with [DURATION] in seconds, and [SIZE] (width and height in dp); null remov | `CYLRefreshIconView` `-setAnimationAttributes:forState:` |  |
| `CYLRefreshIconView.animationAttributesForState` (fun) | The icon of [state], or null (`animationAttributesForState:`). | `CYLRefreshIconView` `-animationAttributesForState:` |  |
| `CYLRefreshIconView.hasAnimations` (val) | Whether any state has an icon (`hasAnimations`). | `CYLRefreshIconView` `hasAnimations` |  |
| `CYLRefreshIconView.iconSize` (val) | The icon's size in dp, width and height (`iconSize`): the shown state's, else the first one's, else 0. | `CYLRefreshIconView` `iconSize` |  |
| `CYLRefreshIconView.title` (var) | The title below the icon (`title`). | `CYLRefreshIconView` `title` |  |
| `CYLRefreshIconView.titleFont` (var) | The title's size in sp, or 0 for the default (`titleFont`). | `CYLRefreshIconView` `titleFont` |  |
| `CYLRefreshIconView.titleTypeface` (var) | The title's typeface, or null for the default (the family and weight of the iOS `titleFont`). | `CYLRefreshIconView` `titleFont` | matched by the iOS name its KDoc cites |
| `CYLRefreshIconView.fittingSize` (val) | The size the view needs, in pixels: width and height (`fittingSize`). | `CYLRefreshIconView` `fittingSize` |  |
| `CYLRefreshIconView.scrubsWhilePulling` (var) | Whether the pull scrubs the animation instead of playing it (`scrubsWhilePulling`). | `CYLRefreshIconView` `scrubsWhilePulling` |  |
| `CYLRefreshIconView.animationSpeed` (var) | The playback rate of the icon's animation, 1 by default, applied live (the examples' speed slider, docs/Example-Animation-Playback.md; HarmonyOS `CYLRefreshIconViewModel.animationSpeed`). | `CYLRefreshIconView` `animationSpeed` |  |
| `CYLRefreshIconView.loopsWhilePlaying` (var) | Whether the icon loops while it plays (refreshing), true by default; false plays it once and rests on its last frame (the examples' loop switch; HarmonyOS `loopsWhilePlaying`). | `CYLRefreshIconView` `loopsWhilePlaying` |  |
| `CYLRefreshIconView.replayAnimation` (fun) | Restarts the shown icon from its first frame with the current speed and loop (the examples' Play all; HarmonyOS `replayAnimation()`). | `CYLRefreshIconView` `-replayAnimation` |  |
| `CYLRefreshIconView.updateForState` (fun) | Shows and plays the icon of [state] (`updateForState:`); a state without one keeps the last icon. | `CYLRefreshIconView` `-updateForState:` |  |
| `CYLRefreshIconView.updateForPullingPercent` (fun) | Scrubs the icon to [pullingPercent], 0 to 1, while pulling (`updateForPullingPercent:`). | `CYLRefreshIconView` `-updateForPullingPercent:` |  |
| `CYLRefreshIconView.ANIMATION_FILE_PATH` (val) | The animation file the animation engine (or a registered factory) plays. | `CYLPlaceholderItemAnimationFilePath` |  |
| `CYLRefreshIconView.IMAGES` (val) | The image frames, a list of drawables. | `CYLPlaceholderItemImages` | added 2026-11-16 for Android parity |
| `CYLRefreshIconView.DURATION` (val) | The image frames' total duration, in seconds. | `CYLPlaceholderItemAnimationDuration` | added 2026-11-16 for Android parity |
| `CYLRefreshIconView.SIZE` (val) | The icon's size in dp, width and height. | `CYLPlaceholderItemAnimationSize` |  |
| `CYLRefreshIconView.attributesForAnimationFilePath` (fun) | The attributes of the animation at [filePath], [width] by [height] dp (`attributesForAnimationFilePath:size:`). | `CYLRefreshIconView(CYLRefreshIconAttributes)` `+attributesForAnimationFilePath:size:` |  |
| `CYLRefreshIconAnimating` (interface) | A refresh component with a per-state icon (iOS `CYLRefreshIconAnimating`); every [CYLRefreshComponent] is one through the `cyl_` extensions below. | `CYLRefreshIconAnimating` |  |
| `CYLRefreshIconAnimating.iconView` (val) | The icon view (`iconView`). | `CYLRefreshIconAnimating` `iconView` | matched by the iOS name its KDoc cites |
| `CYLRefreshIconAnimating.usesIconView` (val) | Whether any state has an icon (`usesIconView`). | `CYLRefreshIconAnimating` `usesIconView` | matched by the iOS name its KDoc cites |
| `CYLRefreshIconAnimating.setIconAnimationAttributes` (fun) | The icon of [state] (`setIconAnimationAttributes:forState:`). | `CYLRefreshIconAnimating` `setIconAnimationAttributes:forState:` | matched by the iOS name its KDoc cites |
| `CYLRefreshIconAnimating.setIconAnimationFilePath` (fun) | The animation file of [state] (`setIconAnimationFilePath:size:forState:`). | `CYLRefreshIconAnimating` `setIconAnimationFilePath:size:forState:` | matched by the iOS name its KDoc cites |
| `cyl_iconView` (val) | The component's icon view, made and added to the component's view on first use (`cyl_iconView`). | `cyl_iconView` | matched by the iOS name its KDoc cites |
| `cyl_usesIconView` (val) | Whether the component shows its icon view (`cyl_usesIconView`). | `cyl_usesIconView` | matched by the iOS name its KDoc cites |
| `cyl_setIconAnimationAttributes` (fun) | The icon of [state] (`cyl_setIconAnimationAttributes:forState:`). | `cyl_setIconAnimationAttributes:forState:` | matched by the iOS name its KDoc cites |
| `cyl_setIconImages` (fun) | Image frames as the icon of [state], [duration] seconds in all (`cyl_setIconImages:duration:forState:`). | `cyl_setIconImages:duration:forState:` | matched by the iOS name its KDoc cites |
| `cyl_showIconImageFrameOf` (fun) | Shows the frame of [images] at [pullingPercent], 0 to 1 (`cyl_showIconImageFrameOf:pullingPercent:`). | `cyl_showIconImageFrameOf:pullingPercent:` | matched by the iOS name its KDoc cites |
| `cyl_updateIconViewVisible` (fun) | Shows or hides the icon view, hiding [views] (the component's own arrow and spinner) while it shows (`cyl_updateIconViewVisible:replacingViews:`). | `cyl_updateIconViewVisible:replacingViews:` | matched by the iOS name its KDoc cites |
| `cyl_placeIconViewAtCenter` (fun) | Centers the icon view at ([centerX], [centerY]) pixels in the component and shows or hides it (`cyl_placeIconViewAtCenter:visible:replacingViews:`). | `cyl_placeIconViewAtCenter:visible:replacingViews:` | matched by the iOS name its KDoc cites |
| `cyl_placeIconViewWithTitle` (fun) | Shows the icon view with [title] in place of [labels] (`cyl_placeIconViewWithTitle:labels:visible:replacingViews:`). | `cyl_placeIconViewWithTitle:labels:visible:replacingViews:` | matched by the iOS name its KDoc cites |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshPaging.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshPagingCompletion` (typealias) | Hands a page's result back to a [CYLRefreshPaging] (iOS `CYLRefreshPagingCompletion`): the page's items, the total number of items and of pages when the server tells them (0 otherwise), and an error or null. | `CYLRefreshPagingCompletion` |  |
| `CYLRefreshPagingLoader` (typealias) | Loads one page for a [CYLRefreshPaging] (iOS `CYLRefreshPagingLoader`). | `CYLRefreshPagingLoader` |  |
| `CYLRefreshPaging` (class) | Pages a list through a header and a footer (iOS `CYLRefreshPaging`): the header reloads the first page, the footer loads the next one, and the footer shows "no more data" at the end. | `CYLRefreshPaging`, `CYLRefreshPaging` `-initWithHeader:footer:loader:` |  |
| `CYLRefreshPaging.header` (val) | The header that refreshes, or null (`header`). | `CYLRefreshPaging` `header` |  |
| `CYLRefreshPaging.footer` (val) | The footer that loads more, or null (`footer`). | `CYLRefreshPaging` `footer` |  |
| `CYLRefreshPaging.firstPage` (var) | The first page's number (`firstPage`). | `CYLRefreshPaging` `firstPage` |  |
| `CYLRefreshPaging.items` (var) | The items loaded so far, or null before the first page (`items`). | `CYLRefreshPaging` `items` |  |
| `CYLRefreshPaging.count` (val) | How many items are loaded (`count`). | `CYLRefreshPaging` `count` |  |
| `CYLRefreshPaging.page` (var) | The last page loaded (`page`). | `CYLRefreshPaging` `page` |  |
| `CYLRefreshPaging.total` (var) | The total number of items, 0 when unknown (`total`). | `CYLRefreshPaging` `total` |  |
| `CYLRefreshPaging.totalPage` (var) | The total number of pages, 0 when unknown (`totalPage`). | `CYLRefreshPaging` `totalPage` |  |
| `CYLRefreshPaging.isEmpty` (val) | Whether a page was loaded and there are no items (`isEmpty`). | `CYLRefreshPaging` `isEmpty` |  |
| `CYLRefreshPaging.isNoMore` (var) | Whether the last page is loaded (`isNoMore`). | `CYLRefreshPaging` `isNoMore` |  |
| `CYLRefreshPaging.resetsFooterAfterRefresh` (var) | Whether a refresh clears the footer's "no more data" (`resetsFooterAfterRefresh`). | `CYLRefreshPaging` `resetsFooterAfterRefresh` |  |
| `CYLRefreshPaging.itemsDidChange` (var) | Called after the items change (`itemsDidChange`). | `CYLRefreshPaging` `itemsDidChange` |  |
| `CYLRefreshPaging.start` (fun) | Loads the first page, through the header when there is one (`start`). | `CYLRefreshPaging` `-start` |  |
| `CYLRefreshPaging.refresh` (fun) | Reloads the first page (`refresh`). | `CYLRefreshPaging` `-refresh` |  |
| `CYLRefreshPaging.loadMore` (fun) | Loads the next page (`loadMore`); nothing after the last one. | `CYLRefreshPaging` `-loadMore` |  |
| `CYLRefreshConfig` (class) | The refresh components' settings (iOS `CYLRefreshConfig`). | `CYLRefreshConfig` |  |
| `CYLRefreshConfig.languageCode` (var) | The language of the built-in texts, or null for the system's (`languageCode`). | `CYLRefreshConfig` `languageCode` |  |
| `CYLRefreshConfig.defaultConfig` (val) | The shared settings (`defaultConfig`). | `CYLRefreshConfig` `defaultConfig` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshRive.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshRiveOptions` (class) | The `rive...` creation parameters of the `rive` refresh style, parsed (iOS `CYLRefreshRiveOptions`; docs/Refresh-Library-Parity.md, "The rive style: creation parameters"). | `CYLRefreshRiveOptions` | the parsed `rive...` keys; Kotlin properties are named without the `rive` prefix, as iOS |
| `CYLRefreshRiveOptions.file` (val) | `riveFile` (required by the style): an absolute path, or the name (with or without `.riv`) or relative path of an app asset; null when missing or empty. | `CYLRefreshRiveOptions` `riveFile` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.artboard` (val) | `riveArtboard`: null is the file's default artboard. | `CYLRefreshRiveOptions` `riveArtboard` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.stateMachine` (val) | `riveStateMachine`: the state machine the inputs belong to. | `CYLRefreshRiveOptions` `riveStateMachine` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.triggerOffset` (val) | `riveTriggerOffset` in dp: the pull that counts as fully pulled, also the open height (default 180; a value of 0 or less keeps it). | `CYLRefreshRiveOptions` `riveTriggerOffset` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.minimumHeight` (val) | `riveMinimumHeight` in dp: the smallest layout height of the art (default 0, the trigger offset). | `CYLRefreshRiveOptions` `riveMinimumHeight` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.fitsWidth` (val) | `riveFitsWidth`: true fits the artboard to the width, otherwise it covers. | `CYLRefreshRiveOptions` `riveFitsWidth` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.pullInput` (val) | `rivePullInput`: the number input set from the pull. | `CYLRefreshRiveOptions` `rivePullInput` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.pullInputMinimum` (val) | `rivePullInputMinimum` (default 0). | `CYLRefreshRiveOptions` `rivePullInputMinimum` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.pullInputMaximum` (val) | `rivePullInputMaximum` (default 100). | `CYLRefreshRiveOptions` `rivePullInputMaximum` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.pullInputStart` (val) | `rivePullInputStart`: the fraction of the trigger offset where the input starts to rise (default 0). | `CYLRefreshRiveOptions` `rivePullInputStart` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.pullInputRefreshingValue` (val) | `rivePullInputRefreshingValue`: the input's value while refreshing; a negative or missing value is -1 (keep the maximum). | `CYLRefreshRiveOptions` `rivePullInputRefreshingValue` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.releaseTrigger` (val) | `riveReleaseTrigger`. | `CYLRefreshRiveOptions` `riveReleaseTrigger` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.finishTrigger` (val) | `riveFinishTrigger`. | `CYLRefreshRiveOptions` `riveFinishTrigger` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.restartTrigger` (val) | `riveRestartTrigger`. | `CYLRefreshRiveOptions` `riveRestartTrigger` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.finishTimeout` (val) | `riveFinishTimeout` in seconds (the finish rule, docs/Refresh-Library-Parity.md): the longest the header stays at its refreshing height after the refresh ends so that the end of the animation (`riveFinishTrigger` or the  | `CYLRefreshRiveOptions` `riveFinishTimeout` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.loadingBoolean` (val) | `riveLoadingBoolean`. | `CYLRefreshRiveOptions` `riveLoadingBoolean` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.loadingNumber` (val) | `riveLoadingNumber`. | `CYLRefreshRiveOptions` `riveLoadingNumber` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.loadingNumberMaximum` (val) | `riveLoadingNumberMaximum` (default 99). | `CYLRefreshRiveOptions` `riveLoadingNumberMaximum` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.loadingNumberFinished` (val) | `riveLoadingNumberFinished` (default 100). | `CYLRefreshRiveOptions` `riveLoadingNumberFinished` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.loadingNumberDuration` (val) | `riveLoadingNumberDuration` in seconds (default 2; 0 or less keeps it). | `CYLRefreshRiveOptions` `riveLoadingNumberDuration` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.pullAnimation` (val) | `rivePullAnimation`. | `CYLRefreshRiveOptions` `rivePullAnimation` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.triggerAnimation` (val) | `riveTriggerAnimation`. | `CYLRefreshRiveOptions` `riveTriggerAnimation` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.loadingAnimation` (val) | `riveLoadingAnimation`. | `CYLRefreshRiveOptions` `riveLoadingAnimation` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.idleAnimation` (val) | `riveIdleAnimation`. | `CYLRefreshRiveOptions` `riveIdleAnimation` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.drawnTable` (val) | `riveDrawnTable`: a list of `[pullInput, drawnFraction]` pairs (see [CYLRefreshRiveDrawnTable]); empty (no clip) when missing or with no valid pair. | `CYLRefreshRiveOptions` `riveDrawnTable` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveOptions.fileIsPath` (val) | Whether [file] is a path (absolute, or a `file://` URL) rather than the name of an app asset. | n/a | Android resolves the file itself: a path, or an app asset (iOS `resolvedFileURL`) |
| `CYLRefreshRiveOptions.assetCandidates` (fun) | The asset names to try, in order, for an asset [file]: the name as given and with `.riv` added, each as is, inside `flutter_assets/` (a Flutter app's assets) and under `assets/animations/` (the Flutter example's folder), | `CYLRefreshRiveOptions` `resolvedFileURL(bundles:)` | the same name rules (name with or without `.riv`, relative path, Flutter asset folder); Android returns the asset names the Rive module tries |
| `CYLRefreshRiveOptions.from` (fun) | Options from a creation parameter map (a Flutter map, or a React Native `headerRive` / `footerRive` object); null is an empty map. | `CYLRefreshRiveOptions` `init(dictionary:)` | Android never returns null: a missing file is `file == null` |
| `CYLRefreshRiveDrawnTable` (class) | The Rive drawn-height table (`riveDrawnTable`, docs/Refresh-Library-Parity.md, "Rive drawn-height table"; the same contract on iOS): pairs of `[pullInput, drawnFraction]`, where pullInput is the value sent to the Rive st | `riveDrawnTable` | matched by the iOS name its KDoc cites |
| `CYLRefreshRiveDrawnTable.isEmpty` (val) | True when there is no valid pair: no clip. | TODO |  |
| `CYLRefreshRiveDrawnTable.pairs` (val) | The valid pairs, sorted by input, with the fractions clamped to 0..1. | TODO |  |
| `CYLRefreshRiveDrawnTable.fraction` (fun) | The drawn fraction (0..1) for [input]; null when the table is empty (no clip). | TODO |  |
| `CYLRefreshRiveDrawnTable.EMPTY` (val) | The table without pairs. | TODO |  |
| `CYLRefreshRiveDrawnTable.parse` (fun) | A table from [raw] (a list of two-number lists): a malformed element (not a list, fewer than two numbers, a non-number or non-finite value) is ignored, the rest is sorted by input and the fractions are clamped to 0..1. | TODO |  |
| `CYLRefreshRiveDrawnTable.of` (fun) | A table from typed [pairs] (a style set in code); validated as [parse]. | TODO |  |
| `CYLRefreshRiveBuilding` (interface) | What the optional module `:merged-rive` provides (iOS `CYLRefreshRiveBuilding`): the Rive header and footer for options. | `CYLRefreshRiveBuilding` |  |
| `CYLRefreshRiveBuilding.header` (fun) | The Rive header, or null when [options] name a file that cannot be read. | `CYLRefreshRiveBuilding` `riveHeader(options:)` |  |
| `CYLRefreshRiveBuilding.footer` (fun) | The Rive footer (the header drawn upside down by [CYLRefreshDrawnFooter]), or null as for [header]. | `CYLRefreshRiveBuilding` `riveFooter(options:)` |  |
| `CYLRefreshRiveSupport` (object) | The seam between the core and the optional Rive module (iOS `CYLRefreshStyleFactory.riveBuilder`): the core finds the builder `com.cyl.refresh.rive.CYLRefreshRiveBuilder` by name at run time, so it needs no Rive runtime. | `CYLRefreshStyleFactory` | the `rive` part of the factory: `header(style:options:onFallback:)` / `footer(...)` and `riveBuilder` |
| `CYLRefreshRiveSupport.BUILDER_CLASS` (val) | The class of the builder in the module `:merged-rive`. | n/a | iOS finds the class `CYLRefreshRiveBuilder` by `NSClassFromString`; Android by the class name of the `:merged-rive` module |
| `CYLRefreshRiveSupport.NOT_LINKED` (val) | The reason when no builder is found (the module or the Rive runtime is not on the class path). | n/a | the reason text; iOS says `rive runtime not linked (add the CYLTableViewPlaceHolder/Rive subspec)` |
| `CYLRefreshRiveSupport.NO_FILE` (val) | The reason when the creation parameters have no `riveFile`. | n/a | the reason text; iOS says `rive needs the creation parameter riveFile` |
| `CYLRefreshRiveSupport.builder` (var) | A builder set by the app or a test; null finds [BUILDER_CLASS] by name. | `CYLRefreshStyleFactory` `riveBuilder` |  |
| `CYLRefreshRiveSupport.unreadable` (fun) | The reason when [file] cannot be found or read. | n/a | the reason text; iOS says `rive file <riveFile> not found or unreadable` |
| `CYLRefreshRiveSupport.logFallback` (fun) | Writes the one log line of a fallback: `CYLRefresh: <reason>, using classic`. | n/a | the one `CYLRefresh: <reason>, using classic` log line; iOS passes it to `onFallback` and logs it |
| `CYLRefreshRiveSupport.header` (fun) | The Rive header for [parameters], or the classic header after one [onFallback] call. | `CYLRefreshStyleFactory` `header(style:options:onFallback:)` | for the `rive` style |
| `CYLRefreshRiveSupport.footer` (fun) | The Rive footer for [parameters], or the classic back footer after one [onFallback] call. | `CYLRefreshStyleFactory` `footer(style:options:onFallback:)` | for the `rive` style |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshStyle.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshStyle` (enum) | The refresh styles a cross-platform host (the Flutter plugin's native refresh view) names by one lower camel case string, the same nine values on Android and iOS: `classic`, `cupertino`, `material`, `bezierRadar`, `bezie | `CYLRefreshStyle` | Swift enum with the same nine keys (`rive` added 2026-11-24); the Objective-C hosts use `CYLRefreshStyleFactory` |
| `CYLRefreshStyle.newHeader` (fun) | A new header of this style. | `CYLRefreshStyle` `newHeader(riveOptions:)` | `riveOptions` is the `rive...` map; `onFallback` is the iOS `onFallback` of `CYLRefreshStyleFactory.header(style:options:onFallback:)` |
| `CYLRefreshStyle.newFooter` (fun) | A new footer of this style; the parameters are those of [newHeader]. | `CYLRefreshStyle` `newFooter(riveOptions:)` | as `newHeader` |
| `CYLRefreshStyle.fromKey` (fun) | The style named [key], or null for a missing or unknown name (the caller falls back to [Classic] and reports it). | `CYLRefreshStyle` `fromKey(_:)` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/CYLRefreshTrailer.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshTrailer` (class) | A control at the end of a horizontal list, pulled from the right (`CYLRefreshTrailer`). | `CYLRefreshTrailer` |  |
| `CYLRefreshTrailer.refreshingBlock` (var) | Called when a pull past the trigger is released (`refreshingBlock`). | `CYLRefreshTrailer` `refreshingBlock` | matched by the iOS name its KDoc cites |
| `CYLRefreshTrailer.endRefreshingCompletionBlock` (var) | Called once refreshing has ended and the trailer has slid away (`endRefreshingCompletionBlock`). | `CYLRefreshTrailer` `endRefreshingCompletionBlock` | matched by the iOS name its KDoc cites |
| `CYLRefreshTrailer.triggerRate` (var) | The share of the trailer's width to pull before release refreshes (`triggerRate`). | `CYLRefreshTrailer` `triggerRate` | matched by the iOS name its KDoc cites |
| `CYLRefreshTrailer.pullingPercent` (var) | How far the trailer is pulled, as a share of the trigger distance (`pullingPercent`). | `CYLRefreshTrailer` `pullingPercent` | matched by the iOS name its KDoc cites |
| `CYLRefreshTrailer.state` (var) | The current state (`state`). | `CYLRefreshTrailer` `state` | matched by the iOS name its KDoc cites |
| `CYLRefreshTrailer.automaticallyRefresh` (var) | Whether pulling the trailer into view refreshes without a release (`automaticallyRefresh`); false, the default, keeps the pull-and-release behavior. | `CYLRefreshTrailer` `automaticallyRefresh` |  |
| `CYLRefreshTrailer.triggerAutomaticallyRefreshPercent` (var) | How much of the trailer must be in view before it refreshes automatically, 1 for fully (`triggerAutomaticallyRefreshPercent`). | `CYLRefreshTrailer` `triggerAutomaticallyRefreshPercent` |  |
| `CYLRefreshTrailer.autoTriggerTimes` (var) | Automatic refreshes allowed per drag, 1 by default; -1 for no limit (`autoTriggerTimes`). | `CYLRefreshTrailer` `autoTriggerTimes` |  |
| `CYLRefreshTrailer.isRefreshing` (val) | True while refreshing (`isRefreshing`). | `CYLRefreshTrailer` `isRefreshing` | matched by the iOS name its KDoc cites |
| `CYLRefreshTrailer.scrollView` (var) | The list the trailer is attached to, or null (`scrollView`). | `CYLRefreshTrailer` `scrollView` | matched by the iOS name its KDoc cites |
| `CYLRefreshTrailer.trailerWidth` (val) | The trailer's width, in pixels (`CYLRefreshTrailWidth`). | `CYLRefreshTrailWidth` | matched by the iOS name its KDoc cites |
| `CYLRefreshTrailer.beginRefreshing` (fun) | Starts refreshing: the trailer stays shown and [refreshingBlock] runs (`beginRefreshing`). | `CYLRefreshTrailer` `beginRefreshing` | matched by the iOS name its KDoc cites |
| `CYLRefreshTrailer.endRefreshing` (fun) | Ends refreshing and slides the trailer away (`endRefreshing`). | `CYLRefreshTrailer` `endRefreshing` | matched by the iOS name its KDoc cites |
| `CYLRefreshStateTrailer` (class) | A trailer with a vertical state text (`CYLRefreshStateTrailer`). | `CYLRefreshStateTrailer` |  |
| `CYLRefreshStateTrailer.stateLabel` (val) | The state text (`stateLabel`). | `CYLRefreshStateTrailer` `stateLabel` |  |
| `CYLRefreshStateTrailer.setTitle` (fun) | Sets the text shown in [state] (`setTitle:forState:`). | `CYLRefreshStateTrailer` `-setTitle:forState:` |  |
| `CYLRefreshStateTrailer.titleForState` (fun) | The text shown in [state] (`titleForState:`), as on the state footers. | `CYLRefreshStateTrailer` `-titleForState:` |  |
| `CYLRefreshNormalTrailer` (class) | A trailer with an arrow that turns around past the trigger (`CYLRefreshNormalTrailer`). | `CYLRefreshNormalTrailer` |  |
| `CYLRefreshNormalTrailer.arrowView` (val) | The arrow, pointing left until the pull passes the trigger (`arrowView`). | `CYLRefreshNormalTrailer` `arrowView` |  |
| `CYLRefreshNormalTrailer.trailerWithRefreshingBlock` (fun) | A trailer that runs [refreshingBlock] when released past the trigger (`trailerWithRefreshingBlock:`). | `CYLRefreshTrailer` `+trailerWithRefreshingBlock:` |  |
| `cyl_trailer` (var) | The list's trailer (the iOS `UIScrollView.cyl_trailer`). | `cyl_trailer` | matched by the iOS name its KDoc cites |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/classics/Classics.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `ArrowDrawable` (class) | The classic arrow (`ArrowDrawable`). | `CYLRefreshNormalHeader` `arrowView` | iOS shows the bundled arrow image instead of drawing it |
| `ClassicsAbstract` (class) | The base of the classics header and footer: an arrow, a spinner and a title (`ClassicsAbstract`). | `CYLRefreshNormalHeader`, `CYLRefreshBackNormalFooter`, `CYLRefreshAutoNormalFooter` | no shared base class on iOS; each normal control has the arrow, spinner and title |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/PaintDrawables.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `PaintDrawable` (class) | A drawable that draws with one paint of one color (`PaintDrawable`). | n/a | Android Drawable/Paint plumbing |
| `PaintDrawable.setColor` (fun) | The color to draw with. | n/a | Android Drawable/Paint plumbing |
| `ProgressDrawable` (class) | The classic spinner: twelve bars turning in steps (`ProgressDrawable`). | `CYLRefreshNormalHeader` `loadingView` | the system UIActivityIndicatorView draws the same twelve-bar spinner |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/PathsDrawable.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `PathsDrawable` (class) | A drawable of SVG paths, one color per path, that scales to its bounds (`PathsDrawable`). | n/a | an internal drawing helper of the vector styles, which are ported; iOS draws them with its own classes (CYLRefreshVectorImage, CYLRefreshVectorElement), no API counterpart needed |
| `PathsDrawable.parserPaths` (fun) | Parses SVG path data; false when the paths are empty. | `CYLRefreshVectorImage` `-parserPaths:` |  |
| `PathsDrawable.declareOriginal` (fun) | Declares the paths' original box. | `CYLRefreshVectorImage` `viewport` |  |
| `PathsDrawable.parserColors` (fun) | The paths' colors, in order. | `CYLRefreshVectorImage` `-parserColors:` |  |
| `PathsDrawable.setGeometricWidth` (fun) | Scales the bounds to [width], keeping the aspect ratio. | `CYLRefreshVectorImage` `-setGeometricWidth:` |  |
| `PathsDrawable.setGeometricHeight` (fun) | Scales the bounds to [height], keeping the aspect ratio. | `CYLRefreshVectorImage` `-setGeometricHeight:` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/path/PathParser.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `PathParser` (class) | Parses SVG path data into [Path]s (`PathParser`). | n/a | an internal helper of the vector path parser, which is ported; iOS parses with its own classes (CYLRefreshVectorPathsParser), no API counterpart needed |
| `PathParser.PathDataNode` (class) | One command of the path data and its numbers (`PathParser.PathDataNode`). | n/a | intermediate node of Android's AOSP-derived parser; CYLRefreshVectorPathsParser writes straight into a CGMutablePath |
| `PathParser.PathDataNode.nodesToPath` (fun) | Adds [node] to [path]. | n/a | intermediate step of Android's AOSP-derived parser; CYLRefreshVectorPathsParser writes straight into a CGMutablePath |
| `PathParser.transformScale` (fun) | Scales [originPaths] by [ratioWidth] × [ratioHeight]. | n/a | android.graphics.Path/Matrix helper; iOS scales the whole vector image (`CYLRefreshVectorImage` `-scaleToFitInside:`) |
| `PathParser.createPathFromPathData` (fun) | The path of SVG [pathData], or null for null data. | `CYLRefreshVectorPathElement` `+newWith:` / `pathForShape` |  |
| `PathParser.createNodesFromPathData` (fun) | The nodes of SVG [pathData], or null for null data. | n/a | intermediate step of Android's AOSP-derived parser; CYLRefreshVectorPathsParser writes straight into a CGMutablePath |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/drawable/view/PathsView.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `PathsView` (class) | A view that draws SVG paths; a string tag is parsed as path data (`PathsView`). | n/a | an internal drawing helper of the vector styles, which are ported; iOS draws them with its own class (CYLRefreshVectorView), no API counterpart needed |
| `PathsView.parserPaths` (fun) | Parses SVG path data; false when the paths are empty. | `CYLRefreshVectorView` `-parserPaths:` |  |
| `PathsView.parserColors` (fun) | The paths' colors, in order. | `CYLRefreshVectorView` `-parserColors:` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/footer/BallPulseFooter.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `BallPulseFooter` (class) | The footer with three pulsing balls (`BallPulseFooter`). | `CYLRefreshBallPulseFooter` | added 2026-11-17 for Android parity |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/footer/ClassicsFooter.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `ClassicsFooter` (class) | The classic footer: an arrow, a spinner and a title for every state (`ClassicsFooter`). | `CYLRefreshBackNormalFooter`, `CYLRefreshAutoNormalFooter` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/BezierCircleHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `BezierCircleHeader` (class) | A wave that springs a ball up, which spins while refreshing, from CircleRefreshLayout (`BezierCircleHeader`). | `CYLRefreshBezierCircleHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/BezierRadarHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `BezierRadarHeader` (class) | The header with a Bezier wave, a row of dots and a radar while refreshing (`BezierRadarHeader`). | `CYLRefreshBezierRadarHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/ClassicsHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `ClassicsHeader` (class) | The classic header: an arrow, a spinner, a title for every state and the last update time (`ClassicsHeader`). | `CYLRefreshNormalHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/DeliveryHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `DeliveryHeader` (class) | A parcel floating down under an umbrella, after "Refresh your delivery" on Dribbble (`DeliveryHeader`). | `CYLRefreshDeliveryHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/DropBoxHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `DropBoxHeader` (class) | A box that opens and drops files in, after "DropBox Refresh" on Dribbble (`DropBoxHeader`). | `CYLRefreshDropBoxHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/Falsify.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `FalsifyHeader` (class) | An empty header: the content can be pulled down, nothing refreshes (`FalsifyHeader`). | `CYLRefreshHeader` with `refreshEnabled` = NO | a plain CYLRefreshHeader draws nothing; refreshEnabled NO keeps the bounce and never refreshes |
| `FalsifyFooter` (class) | An empty footer: the content can be pulled up, nothing loads (`FalsifyFooter`). | `CYLRefreshBackFooter` with `refreshEnabled` = NO | a plain CYLRefreshBackFooter draws nothing; refreshEnabled NO keeps the bounce and never loads |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/FlyRefreshHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `FlyRefreshHeader` (class) | A paper plane over hills, from FlyRefresh (`FlyRefreshHeader`). | `CYLRefreshFlyHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/FunGameBattleCityHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `FunGameBattleCityHeader` (class) | A tank game while refreshing, from FunGameRefresh (`FunGameBattleCityHeader`). | `CYLRefreshGameBattleCityHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/FunGameHitBlockHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `FunGameHitBlockHeader` (class) | A breakout game while refreshing, from FunGameRefresh (`FunGameHitBlockHeader`). | `CYLRefreshGameHitBlockHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/MaterialHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `MaterialHeader` (class) | The Material header: SwipeRefreshLayout's spinner in a circle, optionally over a Bezier wave (`MaterialHeader`). | `CYLRefreshMaterialHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/PhoenixHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `PhoenixHeader` (class) | A town under a rising, spinning sun, from Yalantis' Phoenix (`PhoenixHeader`). | `CYLRefreshPhoenixHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/StoreHouseHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `StoreHouseHeader` (class) | The header that draws a word from falling bars, from android-Ultra-Pull-To-Refresh (`StoreHouseHeader`). | `CYLRefreshStoreHouseHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/TaurusHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `TaurusHeader` (class) | A plane flying through clouds and wind, from Yalantis' Taurus (`TaurusHeader`). | `CYLRefreshTaurusHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/TwoLevelHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `TwoLevelHeader` (class) | The second-floor header: wraps a header and opens a second floor when pulled far enough (`TwoLevelHeader`). | `CYLRefreshHeader` `secondaryTriggerOffset` / `secondaryView` / `-openSecondary` | every iOS header has the second floor built in; no wrapper class |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/WaterDropHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `WaterDropHeader` (class) | The header with a stretching water drop, from WaterDropListView (`WaterDropHeader`). | `CYLRefreshOriginalHeader` | the same iOS 6 water drop; `enableAutoRefresh` = NO waits for the release as Android does |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/WaveSwipeHeader.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `WaveSwipeHeader` (class) | A full-screen wave that drops a spinning circle, from WaveSwipeRefreshLayout (`WaveSwipeHeader`). | `CYLRefreshWaveSwipeHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/falsify/FalsifyAbstract.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `FalsifyAbstract` (class) | The empty header and footer's base: draws nothing at run time and a dashed outline in the layout editor (`FalsifyAbstract`). | `CYLRefreshComponent` | the base draws nothing; the layout-editor outline is Android-only |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/flyrefresh/FlyView.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `FlyView` (class) | The paper plane (`FlyView`). | `FlyView` | matched by the iOS name its KDoc cites |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/flyrefresh/MountainSceneView.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `MountainSceneView` (class) | Hills and trees behind the paper plane, from FlyRefresh (`MountainSceneView`). | n/a | an internal drawing helper of the fly header, which is ported; iOS draws it with its own class (CYLRefreshMountainView), no API counterpart needed |
| `MountainSceneView.setPrimaryColor` (fun) | Tints the whole scene from [color], the sky's color. | `CYLRefreshMountainView` `colorPrimary` |  |
| `MountainSceneView.updatePercent` (fun) | Moves the hills and bends the trees for the pull [percent]. | `CYLRefreshMountainView` `-onScrollingWithOffset:percent:` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/fungame/FunGameBase.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `FunGameBase` (class) | The base of the game headers: while refreshing, a drag plays the game instead of moving the content (`FunGameBase`). | `CYLRefreshGameHeader` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/fungame/FunGameView.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `FunGameView` (class) | The game headers' curtain and arena, from FunGameRefresh (`FunGameView`). | n/a | an internal drawing helper of the game headers, which are ported; iOS draws them with its own classes (CYLRefreshGameStartScene, CYLRefreshGamePlayingScene), no API counterpart needed |
| `FunGameView.postStatus` (fun) | Sets the game's [status], one of the STATUS_GAME_ constants. | `CYLRefreshGamePlayingScene` `-reset` / `-start` / `-gameOver` / `-finishWithSuccess:` | one method per status |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/listener/OnTwoLevelListener.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `OnTwoLevelListener` (interface) | Called when the second floor opens; return false to keep it closed (`OnTwoLevelListener`). | `CYLRefreshHeader` `secondaryShouldOpenBlock` | added 2026-11-17 for Android parity |
| `OnTwoLevelListener.onTwoLevel` (fun) | True opens the second floor. | `CYLRefreshHeader` `secondaryShouldOpenBlock` | added 2026-11-17 for Android parity |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/material/MaterialDrawables.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CircleImageView` (class) | The MaterialHeader's circle: an oval background with the Material elevation (`CircleImageView`). | n/a | Android ImageView with an elevation shadow; CYLRefreshMaterialHeader draws its circle and shadow with layers |
| `CircleImageView.SHADOW_RADIUS` (val) | The shadow radius in dp. | n/a | Android elevation shadow constant |
| `CircleImageView.SHADOW_ELEVATION` (val) | The elevation in dp. | n/a | Android elevation constant |
| `MaterialProgressDrawable` (class) | The Material spinner with an arc, an arrow and color changes (`MaterialProgressDrawable`). | `CYLRefreshMaterialHeader` | the arc, arrow and color changes are drawn inside the header |
| `MaterialProgressDrawable.ProgressDrawableSize` (class) | The sizes of [updateSizes]. | `CYLRefreshMaterialSize` | added 2026-11-17 for Android parity |
| `MaterialProgressDrawable.updateSizes` (fun) | Sets the size: [LARGE] or [DEFAULT]. | `CYLRefreshMaterialHeader` `progressSize` | added 2026-11-17 for Android parity |
| `MaterialProgressDrawable.showArrow` (fun) | Shows the arrow at the arc's end. | n/a | internal drawing step of the Android drawable; CYLRefreshMaterialHeader draws the arrow privately |
| `MaterialProgressDrawable.setArrowScale` (fun) | The arrow's scale, 0 to 1. | n/a | internal drawing step of the Android drawable; CYLRefreshMaterialHeader animates it privately |
| `MaterialProgressDrawable.setStartEndTrim` (fun) | The arc's start and end, as fractions of a turn. | n/a | internal drawing step of the Android drawable; CYLRefreshMaterialHeader animates the trim privately |
| `MaterialProgressDrawable.setProgressRotation` (fun) | The arc's rotation, as a fraction of a turn. | n/a | internal drawing step of the Android drawable; CYLRefreshMaterialHeader animates the rotation privately |
| `MaterialProgressDrawable.setColorSchemeColors` (fun) | The arc's colors, in turn. | `CYLRefreshMaterialHeader` `colorSchemeColors` | added 2026-11-17 for Android parity |
| `MaterialProgressDrawable.LARGE` (val) | The large size. | `CYLRefreshMaterialSizeLarge` | added 2026-11-17 for Android parity |
| `MaterialProgressDrawable.DEFAULT` (val) | The default size. | `CYLRefreshMaterialSizeDefault` | added 2026-11-17 for Android parity |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/storehouse/StoreHouseBarItem.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `StoreHouseBarItem` (class) | One bar of the StoreHouse header, with its fade animation (`StoreHouseBarItem`). | n/a | an internal drawing helper of the StoreHouse header, which is ported; iOS draws it with its own class (CYLRefreshStoreHouseLine), no API counterpart needed |
| `StoreHouseBarItem.index` (var) | The bar's index. | `CYLRefreshStoreHouseLine` `index` |  |
| `StoreHouseBarItem.setLineWidth` (fun) | The bar's width. | `CYLRefreshStoreHouseHeader` `lineWidth` | one width for every bar |
| `StoreHouseBarItem.setColor` (fun) | The bar's color. | `CYLRefreshComponent` `colorAccent` (on `CYLRefreshStoreHouseHeader`) | one color for every bar |
| `StoreHouseBarItem.resetPosition` (fun) | Picks a new random horizontal offset, up to [horizontalRandomness]. | `CYLRefreshStoreHouseLine` `offset` | the random horizontal offset is assigned when `CYLRefreshStoreHousePath` builds the lines |
| `StoreHouseBarItem.start` (fun) | Fades the bar from [fromAlpha] to [toAlpha]. | n/a | Android AlphaAnimation on the bar; CYLRefreshStoreHouseHeader fades `CYLRefreshStoreHouseLine` `alpha` itself |
| `StoreHouseBarItem.setAlpha` (fun) | The bar's alpha, 0 to 1. | `CYLRefreshStoreHouseLine` `alpha` |  |
| `StoreHouseBarItem.draw` (fun) | Draws the bar around the canvas origin. | n/a | Android Canvas drawing; CYLRefreshStoreHouseHeader strokes the lines in drawRect: |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/storehouse/StoreHousePath.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `StoreHousePath` (object) | The StoreHouse header's letters, as line segments (`StoreHousePath`). | `StoreHousePath` | matched by the iOS name its KDoc cites |
| `StoreHousePath.getPath` (fun) | The line segments {x1, y1, x2, y2} of [str], scaled by [scale], with [gapBetweenLetter] between letters. | `CYLRefreshStoreHousePath` `+linesFrom:scale:space:` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/waterdrop/Circle.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `Circle` (class) | A filled circle (`Circle`). | n/a | geometry holder of the Android WaterDropView; CYLRefreshOriginalHeader keeps its circles privately |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/waterdrop/WaterDropView.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `WaterDropView` (class) | The water drop in the middle of the header, from WaterDropListView (`WaterDropView`). | `CYLRefreshOriginalHeader` | the drop is drawn inside the header; no separate view |
| `WaterDropView.maxCircleRadius` (val) | The circles' largest radius. | n/a | internal geometry of the Android view; CYLRefreshOriginalHeader uses private constants |
| `WaterDropView.createAnimator` (fun) | The bounce back: both radii grow back and the lower circle rises into the upper one. | n/a | internal animation of the Android view; CYLRefreshOriginalHeader animates the drop privately |
| `WaterDropView.updateCompleteState` (fun) | Does nothing; kept from the Java version. | n/a | internal drawing step of the Android view; CYLRefreshOriginalHeader stretches the drop privately from the pull |
| `WaterDropView.updateCompleteState` (fun) | Sets the drop's stretch from [percent], 0 to 1. | n/a | internal drawing step of the Android view; CYLRefreshOriginalHeader stretches the drop privately from the pull |
| `WaterDropView.updateCompleteState` (fun) | Sets the drop's stretch from the view's [height]. | n/a | internal drawing step of the Android view; CYLRefreshOriginalHeader stretches the drop privately from the pull |
| `WaterDropView.getTopCircle` (fun) | The upper circle. | n/a | internal geometry of the Android view |
| `WaterDropView.getBottomCircle` (fun) | The lower circle. | n/a | internal geometry of the Android view |
| `WaterDropView.setIndicatorColor` (fun) | The drop's color. | `CYLRefreshComponent` `colorPrimary` (on `CYLRefreshOriginalHeader`) |  |
| `WaterDropView.getIndicatorColor` (fun) | The drop's color. | `CYLRefreshComponent` `colorPrimary` (on `CYLRefreshOriginalHeader`) |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/waveswipe/DropBounceInterpolator.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `DropBounceInterpolator` (class) | The bounce of the wave's drop (`DropBounceInterpolator`, by amyu). | n/a | android.view.animation.Interpolator; CYLRefreshWaveSwipeHeader passes the same curve as a `CYLRefreshValueAnimator` `interpolatorBlock` |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/header/waveswipe/WaveView.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `WaveView` (class) | Draws the wave and the falling circle, by amyu (`WaveView`). | `CYLRefreshWaveSwipeHeader` | the wave and the drop are drawn inside the header; no separate view |
| `WaveView.manualRefresh` (fun) | Shows the circle fallen, for a refresh started from code. | `CYLRefreshComponent` `-beginRefreshing` (on `CYLRefreshWaveSwipeHeader`) |  |
| `WaveView.beginPhase` (fun) | Draws the wave bulging under the pull, before the drop appears. | n/a | internal drawing step of the Android view; CYLRefreshWaveSwipeHeader draws the phases privately |
| `WaveView.appearPhase` (fun) | Draws the wave as the drop appears. | n/a | internal drawing step of the Android view; CYLRefreshWaveSwipeHeader draws the phases privately |
| `WaveView.expandPhase` (fun) | Draws the wave as the drop grows. | n/a | internal drawing step of the Android view; CYLRefreshWaveSwipeHeader draws the phases privately |
| `WaveView.startDropAnimation` (fun) | Drops the circle and bounces it. | n/a | internal animation of the Android view; CYLRefreshWaveSwipeHeader runs it privately |
| `WaveView.startDisappearCircleAnimation` (fun) | Shrinks the fallen circle away. | n/a | internal animation of the Android view; CYLRefreshWaveSwipeHeader runs it privately |
| `WaveView.startWaveAnimation` (fun) | Lets the wave bounce back from [h], a share of the width. | n/a | internal animation of the Android view; CYLRefreshWaveSwipeHeader runs it privately |
| `WaveView.animationDropCircle` (fun) | Drops the circle with a small wave, unless the circle is still shrinking away. | n/a | internal animation of the Android view; CYLRefreshWaveSwipeHeader runs it privately |
| `WaveView.getCurrentCircleCenterY` (fun) | The circle's center y. | n/a | internal geometry of the Android view |
| `WaveView.setShadow` (fun) | The shadow's [radius] and [color]. | `CYLRefreshWaveSwipeHeader` `waveShadowRadius` / `waveShadowColor` | added 2026-11-17 for Android parity |
| `WaveView.setWaveColor` (fun) | The wave's color, alpha included. | `CYLRefreshComponent` `colorPrimary` (on `CYLRefreshWaveSwipeHeader`) |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/layout/CYLRefreshLayout.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLRefreshLayout` (class) | The refresh layout: a content of any kind with a header pulled down to refresh and a footer pulled up to load more (`CYLRefreshLayout`). | `UIScrollView(CYLRefresh)`, `UIScrollView(CYLRefresh)` `-cyl_installDefaultRefreshControls` |  |
| `CYLRefreshLayout.LayoutParams` (class) | The layout parameters of the layout's children: a background color and a spinner style for a header or footer. | n/a | ViewGroup.LayoutParams; per control iOS uses `colorPrimary` and `scrollMode` |
| `CYLRefreshLayout.setDefaultRefreshHeaderCreator` (fun) | Sets the header every layout gets when it has none. | `CYLRefreshConfig` `defaultHeaderCreator` with `UIScrollView` `-cyl_installDefaultRefreshControls` | added 2026-11-17 for Android parity |
| `CYLRefreshLayout.setDefaultRefreshFooterCreator` (fun) | Sets the footer every layout gets when it has none. | `CYLRefreshConfig` `defaultFooterCreator` with `UIScrollView` `-cyl_installDefaultRefreshControls` | added 2026-11-17 for Android parity |
| `CYLRefreshLayout.setDefaultRefreshInitializer` (fun) | Sets up every new layout. | `CYLRefreshConfig` `defaultInitializer` | added 2026-11-17 for Android parity |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/layout/api/Api.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `RefreshComponent` (interface) | A header or a footer of the refresh layout (`RefreshComponent`); the layout calls these methods. | `CYLRefreshComponent` |  |
| `RefreshComponent.view` (val) | The view shown for this component. | n/a | the Android View of the component; on iOS the component is the UIView itself |
| `RefreshComponent.spinnerStyle` (val) | How the component moves with the pull. | `CYLRefreshComponent` `scrollMode` |  |
| `RefreshComponent.setPrimaryColors` (fun) | The layout's primary colors (srlPrimaryColor, srlAccentColor). | `CYLRefreshComponent` `colorPrimary` / `colorAccent` |  |
| `RefreshComponent.onAutoRefresh` (fun) | True when autoRefresh / autoLoadMore starts, false when it ends (pull request #1095), so a component can tell an auto refresh from a drag (#1268). | `CYLRefreshComponent` `-autoRefreshDidChange:` | added 2026-11-17 for Android parity |
| `RefreshComponent.onInitialized` (fun) | The size is known; called once, and again when the height changes. | `CYLRefreshComponent` `-didAttachToScrollView:` / `-placeSubviews` |  |
| `RefreshComponent.onMoving` (fun) | The pull moved: [percent] of the trigger height, [offset] pixels. | `CYLRefreshComponent` `-didScrollWithOffset:percent:dragging:` |  |
| `RefreshComponent.onReleased` (fun) | Released past the trigger height. | `CYLRefreshComponent` `-phaseDidChangeFrom:to:` (`CYLRefreshPhaseReleasing`), `CYLRefreshDrawnHeader` `-onStartAnimationWhenRealeasing` |  |
| `RefreshComponent.onStartAnimator` (fun) | Refreshing (or loading) started; start the animation. | `CYLRefreshComponent` `-phaseDidChangeFrom:to:` (`CYLRefreshPhaseRefreshing`), `CYLRefreshDrawnHeader` `-onStartAnimationWhenRefreshing` |  |
| `RefreshComponent.onFinish` (fun) | Finished; returns the milliseconds to wait before closing (Int.MAX_VALUE: do not close). | `CYLRefreshComponent` `-refreshDidFinishWithSuccess:` / `-finishingDurationWithSuccess:` | seconds instead of milliseconds |
| `RefreshComponent.onHorizontalDrag` (fun) | A sideways move while pulled. | `CYLRefreshComponent` `-didDragHorizontallyWithOffset:percent:` | added 2026-11-17 for Android parity |
| `RefreshComponent.isSupportHorizontalDrag` (val) | True when the component follows sideways moves. | `CYLRefreshComponent` `supportsHorizontalDrag` | added 2026-11-17 for Android parity |
| `RefreshComponent.autoOpen` (fun) | Opens the component itself for an auto refresh; false lets the layout animate it. | `CYLRefreshComponent` `-openForAutoRefreshWithDuration:` | added 2026-11-17 for Android parity |
| `RefreshHeader` (interface) | A refresh header (`RefreshHeader`). | `CYLRefreshHeader` |  |
| `RefreshFooter` (interface) | A refresh footer (`RefreshFooter`). | `CYLRefreshFooter` |  |
| `RefreshFooter.setNoMoreData` (fun) | Shows or hides the no-more-data state; false when the footer does not support it. | `CYLRefreshFooter` `-endRefreshingWithNoMoreData` / `-resetNoMoreData` |  |
| `RefreshContent` (interface) | The content wrapper of the refresh layout (`RefreshContent`). | n/a | content-wrapper plumbing of the Android ViewGroup; iOS controls attach to the UIScrollView itself |
| `RefreshContent.view` (val) | The content view. | n/a | content-wrapper plumbing; iOS controls attach to the UIScrollView itself |
| `RefreshContent.scrollableView` (val) | The view that scrolls inside the content. | n/a | content-wrapper plumbing; iOS controls attach to the UIScrollView itself |
| `RefreshContent.onActionDown` (fun) | A finger went down, to find the scrolling view under it. | n/a | Android MotionEvent dispatch |
| `RefreshContent.setUpComponent` (fun) | Sets up the scrolling view and the fixed header and footer views. | n/a | content-wrapper plumbing |
| `RefreshContent.setScrollBoundaryDecider` (fun) | Decides when the content can refresh or load more. | n/a | content-wrapper plumbing; the feature is RefreshLayout.setScrollBoundaryDecider |
| `RefreshContent.setEnableLoadMoreWhenContentNotFull` (fun) | Allows loading more when the content does not fill the layout. | n/a | content-wrapper plumbing; the feature is RefreshLayout.setEnableLoadMoreWhenContentNotFull |
| `RefreshContent.moveSpinner` (fun) | Moves the content (or its translation views) by [spinner]. | n/a | content-wrapper plumbing; a UIScrollView moves its own content |
| `RefreshContent.canRefresh` (fun) | True when the content is at its top. | n/a | content-wrapper plumbing; iOS reads the scroll view contentOffset |
| `RefreshContent.canLoadMore` (fun) | True when the content is at its end. | n/a | content-wrapper plumbing; iOS reads the scroll view contentOffset |
| `RefreshContent.scrollContentWhenFinished` (fun) | A listener that scrolls the content while the layout closes, or null. | n/a | content-wrapper plumbing |
| `RefreshKernel` (interface) | The layout's interface for its components (`RefreshKernel`). | n/a | the Android layout bridge for components; iOS controls drive their `scrollView` directly |
| `RefreshKernel.refreshLayout` (val) | The layout. | `CYLRefreshComponent` `scrollView` |  |
| `RefreshKernel.refreshContent` (val) | The content. | n/a | content-wrapper plumbing; iOS controls attach to the UIScrollView itself |
| `RefreshKernel.setState` (fun) | Moves the layout to [state]. | `CYLRefreshComponent` `state` |  |
| `RefreshKernel.startTwoLevel` (fun) | Opens (or cancels) the second floor. | `CYLRefreshHeader` `-openSecondary` / `-closeSecondary` |  |
| `RefreshKernel.finishTwoLevel` (fun) | Closes the second floor. | `CYLRefreshHeader` `-closeSecondary` |  |
| `RefreshKernel.moveSpinner` (fun) | Moves the pull to [spinner]. | `UIScrollView` `contentOffset` (UIKit, through `CYLRefreshComponent` `scrollView`) | iOS controls move the pull by setting the content offset |
| `RefreshKernel.animSpinner` (fun) | Animates the pull to [endSpinner]; null when it is already there. | `UIScrollView` `-setContentOffset:animated:` (UIKit, through `CYLRefreshComponent` `scrollView`) | iOS controls animate the pull by setting the content offset |
| `RefreshKernel.requestDrawBackgroundFor` (fun) | Draws a background color behind [internal]. | `CYLRefreshComponent` `colorPrimary` |  |
| `RefreshKernel.requestNeedTouchEventFor` (fun) | Lets [internal] get touches while open. | n/a | Android touch dispatch; an iOS control is a UIView and gets touches itself |
| `RefreshKernel.requestDefaultTranslationContentFor` (fun) | The default for moving the content with [internal], unless the app set it. | each header class's default `scrollMode` (`CYLRefreshMaterialHeader` and `CYLRefreshWaveSwipeHeader` set `CYLRefreshScrollModeFront`) | added 2026-11-17 for Android parity |
| `RefreshKernel.requestRemeasureHeightFor` (fun) | Measures [internal]'s height again. | n/a | Android measure pass |
| `RefreshKernel.requestFloorDuration` (fun) | The second floor's open and close duration. | `CYLRefreshHeader` `secondaryAnimationDuration` | added 2026-11-17 for Android parity |
| `RefreshKernel.requestFloorBottomPullUpToCloseRate` (fun) | The bottom share of the second floor where a pull up closes it. | `CYLRefreshHeader` `secondaryCloseTriggerOffset` | points instead of a share of the floor |
| `RefreshKernel.onAutoRefreshAnimationEnd` (fun) | An auto refresh's open animation ended. | `CYLRefreshComponent` `autoRefresh` with `addPhaseObserver:` (the refreshing phase after an automatic start) | added 2026-11-17 for Android parity |
| `RefreshKernel.onAutoLoadMoreAnimationEnd` (fun) | An auto load more's open animation ended. | `CYLRefreshComponent` `autoRefresh` with `addPhaseObserver:` (the refreshing phase after an automatic start) | added 2026-11-17 for Android parity |
| `RefreshLayout` (interface) | The refresh layout's API (`RefreshLayout`). | `UIScrollView(CYLRefresh)` |  |
| `RefreshLayout.setFooterHeight` (fun) | The footer's height in dp. | `CYLRefreshFooter` frame height (`UIView(CYLExtension)` `cyl_h`) | points |
| `RefreshLayout.setFooterHeightPx` (fun) | The footer's height in pixels. | n/a | pixel variant; iOS uses points (see setFooterHeight) |
| `RefreshLayout.setHeaderHeight` (fun) | The header's height in dp. | `CYLRefreshHeader` `-setExpandHeight:` | points |
| `RefreshLayout.setHeaderHeightPx` (fun) | The header's height in pixels. | n/a | pixel variant; iOS uses points (see setHeaderHeight) |
| `RefreshLayout.setHeaderInsetStart` (fun) | The header's start inset in dp. | `CYLRefreshHeader` `insetStart` | added 2026-11-17 for Android parity |
| `RefreshLayout.setHeaderInsetStartPx` (fun) | The header's start inset in pixels. | n/a | pixel variant; iOS uses points (see setHeaderInsetStart) |
| `RefreshLayout.setFooterInsetStart` (fun) | The footer's start inset in dp. | `CYLRefreshBackFooter` `insetStart` | added 2026-11-17 for Android parity |
| `RefreshLayout.setFooterInsetStartPx` (fun) | The footer's start inset in pixels. | n/a | pixel variant; iOS uses points (see setFooterInsetStart) |
| `RefreshLayout.setDragRate` (fun) | Pull distance per finger distance (0 to 1). | `CYLRefreshComponent` `dragRate` | added 2026-11-17 for Android parity |
| `RefreshLayout.setHeaderMaxDragRate` (fun) | The longest header pull. | `CYLRefreshComponent` `maxPullDistance` (on the header) | points instead of a multiple of the height |
| `RefreshLayout.setFooterMaxDragRate` (fun) | The longest footer pull. | `CYLRefreshComponent` `maxPullDistance` (on a back footer) | points instead of a multiple of the height |
| `RefreshLayout.setHeaderTriggerRate` (fun) | The header pull that triggers a refresh. | `CYLRefreshComponent` `triggerRate` (on the header) |  |
| `RefreshLayout.setFooterTriggerRate` (fun) | The footer pull that triggers loading more. | `CYLRefreshComponent` `triggerRate` (on the footer) |  |
| `RefreshLayout.setReboundInterpolator` (fun) | The interpolator of the bounce back. | `CYLRefreshComponent` `reboundAnimationOptions` (a UIKit animation curve) | added 2026-11-17 for Android parity |
| `RefreshLayout.setReboundDuration` (fun) | The duration of the bounce back in milliseconds. | `CYLRefreshComponent` `fastAnimationDuration` / `slowAnimationDuration` | seconds, per control |
| `RefreshLayout.setRefreshFooter` (fun) | Sets the footer. | `UIScrollView` `cyl_footer` |  |
| `RefreshLayout.setRefreshFooter` (fun) | Sets the footer with its size. | `UIScrollView` `cyl_footer` |  |
| `RefreshLayout.setRefreshHeader` (fun) | Sets the header. | `UIScrollView` `cyl_header` |  |
| `RefreshLayout.setRefreshHeader` (fun) | Sets the header with its size. | `UIScrollView` `cyl_header` |  |
| `RefreshLayout.setRefreshContent` (fun) | Sets the content. | n/a | the content is the UIScrollView the controls are attached to |
| `RefreshLayout.setRefreshContent` (fun) | Sets the content with its size. | n/a | the content is the UIScrollView the controls are attached to |
| `RefreshLayout.setEnableRefresh` (fun) | Enables pull to refresh. | `CYLRefreshComponent` `refreshEnabled` (on `cyl_header`) |  |
| `RefreshLayout.setEnableLoadMore` (fun) | Enables load more. | `CYLRefreshComponent` `refreshEnabled` (on `cyl_footer`) |  |
| `RefreshLayout.setEnableAutoLoadMore` (fun) | Loads more by itself when the content's end is reached. | `CYLRefreshAutoFooter` `automaticallyRefresh` |  |
| `RefreshLayout.setEnableHeaderTranslationContent` (fun) | Moves the content with the header. | `CYLRefreshHeader` `scrollMode` (`CYLRefreshScrollModeFront`: the content does not move for the header) | added 2026-11-17 for Android parity |
| `RefreshLayout.setEnableFooterTranslationContent` (fun) | Moves the content with the footer. | n/a | iOS footers always sit right after the content and move with it (back footers) or load at the end without moving it (auto footers); there is no footer that slides over still content |
| `RefreshLayout.setEnableOverScrollBounce` (fun) | Bounces when a fling reaches the edge. | `UIScrollView` `bounces` (UIKit) | the system bounce |
| `RefreshLayout.setEnablePureScrollMode` (fun) | Pure scroll mode: pulls bounce both ways without refreshing (issues #1109, #1199). | `UIScrollView` `alwaysBounceVertical` (UIKit) | the system bounce with no header or footer attached |
| `RefreshLayout.setEnableScrollContentWhenLoaded` (fun) | Scrolls the content to show new data after loading more. | `CYLRefreshBackFooter` `scrollsContentAfterLoading` | added 2026-11-17 for Android parity |
| `RefreshLayout.setEnableScrollContentWhenRefreshed` (fun) | Scrolls the content after refreshing. | n/a | UIScrollView keeps the content where it is when the refreshing inset goes back; there is no content translation to keep or drop |
| `RefreshLayout.setEnableLoadMoreWhenContentNotFull` (fun) | Loads more when the content does not fill the layout. | `CYLRefreshAutoFooter` `loadsWhenContentNotFull` | added 2026-11-17 for Android parity |
| `RefreshLayout.setEnableOverScrollDrag` (fun) | Allows pulling past the edges without refreshing. | `UIScrollView` `bounces` (UIKit) | the system bounce |
| `RefreshLayout.setEnableFooterFollowWhenNoMoreData` (fun) | Keeps the footer after the content when there is no more data. | `CYLRefreshBackFooter` `followsContentWhenNoMoreData` | added 2026-11-17 for Android parity |
| `RefreshLayout.setEnableClipHeaderWhenFixedBehind` (fun) | Clips a FixedBehind header. | `CYLRefreshHeader` `clipsWhenBehind` | added 2026-11-17 for Android parity |
| `RefreshLayout.setEnableClipFooterWhenFixedBehind` (fun) | Clips a FixedBehind footer. | n/a | iOS footers have no fixed-behind mode (scrollMode is for headers), so there is nothing to clip |
| `RefreshLayout.setEnableNestedScroll` (fun) | Enables nested scrolling. | n/a | Android nested scrolling |
| `RefreshLayout.setFixedHeaderViewId` (fun) | A view inside the content that stays at the top. | `CYLRefreshHeader` `pinnedView` | added 2026-11-17 for Android parity |
| `RefreshLayout.setFixedFooterViewId` (fun) | A view inside the content that stays at the bottom. | `CYLRefreshFooter` `pinnedView` | added 2026-11-17 for Android parity |
| `RefreshLayout.setHeaderTranslationViewId` (fun) | The view that moves with the header instead of the content. | `CYLRefreshHeader` `translationView` | added 2026-11-17 for Android parity |
| `RefreshLayout.setFooterTranslationViewId` (fun) | The view that moves with the footer instead of the content. | `CYLRefreshFooter` `translationView` | added 2026-11-17 for Android parity |
| `RefreshLayout.setDisableContentWhenRefresh` (fun) | Ignores touches on the content while refreshing. | `CYLRefreshHeader` `disablesContentWhileRefreshing` | added 2026-11-17 for Android parity |
| `RefreshLayout.setDisableContentWhenLoading` (fun) | Ignores touches on the content while loading. | `CYLRefreshFooter` `disablesContentWhileRefreshing` | added 2026-11-17 for Android parity |
| `RefreshLayout.setOnRefreshListener` (fun) | Called to refresh. | `CYLRefreshComponent` `refreshingBlock` / `refreshingHandler` / `-setRefreshingTarget:refreshingAction:` (on `cyl_header`) |  |
| `RefreshLayout.setOnLoadMoreListener` (fun) | Called to load more. | `CYLRefreshComponent` `refreshingBlock` / `refreshingHandler` / `-setRefreshingTarget:refreshingAction:` (on `cyl_footer`) |  |
| `RefreshLayout.setOnRefreshLoadMoreListener` (fun) | Called to refresh and to load more. | `CYLRefreshComponent` `refreshingBlock` (on `cyl_header` and `cyl_footer`) | one callback per control |
| `RefreshLayout.setOnMultiListener` (fun) | Called for every step. | `CYLRefreshComponent` `-addScrollObserver:` / `-addPhaseObserver:` | added 2026-11-17 for Android parity |
| `RefreshLayout.setScrollBoundaryDecider` (fun) | Decides when the content can refresh or load more. | `CYLRefreshComponent` `canTriggerBlock` | added 2026-11-17 for Android parity |
| `RefreshLayout.setPrimaryColors` (fun) | The components' primary colors. | `CYLRefreshComponent` `colorPrimary` / `colorAccent` | per control |
| `RefreshLayout.setPrimaryColorsId` (fun) | The components' primary colors, as resources. | n/a | Android color resources |
| `RefreshLayout.finishRefresh` (fun) | Ends refreshing. | `CYLRefreshHeader` `-endRefreshing` / `-endRefreshingAfterDelay:success:` / `-endRefreshingWithSuccess:`; with no more data `UIScrollView` `-cyl_endRefreshingAfterDelay:success:noMoreData:` | added 2026-11-17 for Android parity |
| `RefreshLayout.finishRefresh` (fun) | Ends refreshing after [delayed] milliseconds. | `CYLRefreshHeader` `-endRefreshing` / `-endRefreshingAfterDelay:success:` / `-endRefreshingWithSuccess:`; with no more data `UIScrollView` `-cyl_endRefreshingAfterDelay:success:noMoreData:` | added 2026-11-17 for Android parity |
| `RefreshLayout.finishRefresh` (fun) | Ends refreshing, succeeded or failed. | `CYLRefreshHeader` `-endRefreshing` / `-endRefreshingAfterDelay:success:` / `-endRefreshingWithSuccess:`; with no more data `UIScrollView` `-cyl_endRefreshingAfterDelay:success:noMoreData:` | added 2026-11-17 for Android parity |
| `RefreshLayout.finishRefresh` (fun) | Ends refreshing; [noMoreData] null leaves it unchanged. | `CYLRefreshHeader` `-endRefreshing` / `-endRefreshingAfterDelay:success:` / `-endRefreshingWithSuccess:`; with no more data `UIScrollView` `-cyl_endRefreshingAfterDelay:success:noMoreData:` | added 2026-11-17 for Android parity |
| `RefreshLayout.finishRefreshWithNoMoreData` (fun) | Ends refreshing and marks no more data. | `CYLRefreshComponent` `-endRefreshing` (on `cyl_header`) + `CYLRefreshFooter` `-endRefreshingWithNoMoreData` | two calls |
| `RefreshLayout.finishLoadMore` (fun) | Ends loading more. | `CYLRefreshFooter` `-endRefreshing` / `-endRefreshingAfterDelay:success:`; `UIScrollView` `-cyl_endLoadingMoreAfterDelay:success:noMoreData:` | added 2026-11-17 for Android parity |
| `RefreshLayout.finishLoadMore` (fun) | Ends loading more after [delayed] milliseconds. | `CYLRefreshFooter` `-endRefreshing` / `-endRefreshingAfterDelay:success:`; `UIScrollView` `-cyl_endLoadingMoreAfterDelay:success:noMoreData:` | added 2026-11-17 for Android parity |
| `RefreshLayout.finishLoadMore` (fun) | Ends loading more, succeeded or failed. | `CYLRefreshFooter` `-endRefreshing` / `-endRefreshingAfterDelay:success:`; `UIScrollView` `-cyl_endLoadingMoreAfterDelay:success:noMoreData:` | added 2026-11-17 for Android parity |
| `RefreshLayout.finishLoadMore` (fun) | Ends loading more. | `CYLRefreshFooter` `-endRefreshing` / `-endRefreshingAfterDelay:success:`; `UIScrollView` `-cyl_endLoadingMoreAfterDelay:success:noMoreData:` | added 2026-11-17 for Android parity |
| `RefreshLayout.finishLoadMoreWithNoMoreData` (fun) | Ends loading more and marks no more data. | `CYLRefreshFooter` `-endRefreshingWithNoMoreData` |  |
| `RefreshLayout.closeHeaderOrFooter` (fun) | Closes the open header or footer. | `CYLRefreshComponent` `-endRefreshing` (on the open control) |  |
| `RefreshLayout.setNoMoreData` (fun) | Marks (or clears) no more data. | `CYLRefreshFooter` `-endRefreshingWithNoMoreData` / `-resetNoMoreData` |  |
| `RefreshLayout.resetNoMoreData` (fun) | Clears no more data. | `CYLRefreshFooter` `-resetNoMoreData` |  |
| `RefreshLayout.refreshHeader` (val) | The header, or null. | `UIScrollView` `cyl_header` |  |
| `RefreshLayout.refreshFooter` (val) | The footer, or null. | `UIScrollView` `cyl_footer` |  |
| `RefreshLayout.state` (val) | The state. | `CYLRefreshComponent` `phase` / `state` | per control |
| `RefreshLayout.layout` (val) | The layout's view. | n/a | the Android ViewGroup; on iOS the UIScrollView itself |
| `RefreshLayout.autoRefresh` (fun) | Refreshes as if pulled; false when it cannot now. | `CYLRefreshHeader` `-beginRefreshing` / `-beginRefreshingAfterDelay:` / `-beginRefreshingWithDuration:overOffset:force:` | added 2026-11-17 for Android parity |
| `RefreshLayout.autoRefresh` (fun) | Refreshes as if pulled, after [delayed] milliseconds. | `CYLRefreshHeader` `-beginRefreshing` / `-beginRefreshingAfterDelay:` / `-beginRefreshingWithDuration:overOffset:force:` | added 2026-11-17 for Android parity |
| `RefreshLayout.autoRefreshAnimationOnly` (fun) | Shows refreshing without calling the refresh listener. | `CYLRefreshHeader` `-beginRefreshingAnimationOnly` | added 2026-11-17 for Android parity |
| `RefreshLayout.autoRefresh` (fun) | Refreshes as if pulled, with the open duration and pull rate. | `CYLRefreshHeader` `-beginRefreshing` / `-beginRefreshingAfterDelay:` / `-beginRefreshingWithDuration:overOffset:force:` | added 2026-11-17 for Android parity |
| `RefreshLayout.autoLoadMore` (fun) | Loads more as if pulled up. | `CYLRefreshFooter` `-beginRefreshing` / `-beginRefreshingAfterDelay:` / `-beginRefreshingWithDuration:overOffset:force:` | added 2026-11-17 for Android parity |
| `RefreshLayout.autoLoadMore` (fun) | Loads more as if pulled up, after [delayed] milliseconds. | `CYLRefreshFooter` `-beginRefreshing` / `-beginRefreshingAfterDelay:` / `-beginRefreshingWithDuration:overOffset:force:` | added 2026-11-17 for Android parity |
| `RefreshLayout.autoLoadMoreAnimationOnly` (fun) | Shows loading more without calling the load-more listener. | `CYLRefreshFooter` `-beginRefreshingAnimationOnly` | added 2026-11-17 for Android parity |
| `RefreshLayout.autoLoadMore` (fun) | Loads more as if pulled up, with the open duration and pull rate. | `CYLRefreshFooter` `-beginRefreshing` / `-beginRefreshingAfterDelay:` / `-beginRefreshingWithDuration:overOffset:force:` | added 2026-11-17 for Android parity |
| `RefreshLayout.isRefreshing` (val) | True while refreshing. | `CYLRefreshComponent` `refreshing` (on `cyl_header`) |  |
| `RefreshLayout.isLoading` (val) | True while loading more. | `CYLRefreshComponent` `refreshing` (on `cyl_footer`) |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/layout/constant/Constants.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `DimensionStatus` (class) | Where a size came from and whether the component was told (`DimensionStatus`); a later source replaces an earlier one. | n/a | Android size-source bookkeeping for measurement |
| `DimensionStatus.ordinal` (val) | The rank of the source. | n/a | Android size-source bookkeeping |
| `DimensionStatus.notified` (val) | True once the component was told. | n/a | Android size-source bookkeeping |
| `DimensionStatus.unNotify` (fun) | The same source, not told yet. | n/a | Android size-source bookkeeping |
| `DimensionStatus.notified` (fun) | The same source, told. | n/a | Android size-source bookkeeping |
| `DimensionStatus.canReplaceWith` (fun) | True when [status] may replace this one. | n/a | Android size-source bookkeeping |
| `RefreshState` (enum) | The refresh layout's state (`RefreshState`). | `CYLRefreshPhase`, `CYLRefreshState` |  |
| `RefreshState.toFooter` (fun) | The footer's counterpart of a header state. | n/a | Android keeps separate header and footer states; iOS phases are per control |
| `RefreshState.toHeader` (fun) | The header's counterpart of a footer state. | n/a | Android keeps separate header and footer states; iOS phases are per control |
| `SpinnerStyle` (class) | How a header or footer moves with the pull (`SpinnerStyle`). | `CYLRefreshScrollMode` |  |
| `SpinnerStyle.ordinal` (val) | The style's index. | n/a | index of the Kotlin class-enum; iOS uses NS_ENUM values |
| `SpinnerStyle.front` (val) | In front of the content. | `CYLRefreshScrollMode` | every mode but `CYLRefreshScrollModeBehind` is in front |
| `SpinnerStyle.scale` (val) | Its height follows the pull. | `CYLRefreshScrollModeStretch` |  |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/layout/listener/Listeners.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CoordinatorLayoutListener` (interface) | Hears a CoordinatorLayout's app bar (`CoordinatorLayoutListener`). | n/a | Android CoordinatorLayout / AppBarLayout |
| `CoordinatorLayoutListener.onCoordinatorUpdate` (fun) | Whether refreshing and loading more are possible with the app bar's offset. | n/a | Android CoordinatorLayout / AppBarLayout |
| `DefaultRefreshFooterCreator` (interface) | Makes the default footer of every layout (`DefaultRefreshFooterCreator`). | `CYLRefreshConfig` `defaultFooterCreator` (a block) | added 2026-11-17 for Android parity |
| `DefaultRefreshFooterCreator.createRefreshFooter` (fun) | A new footer for [layout]. | `CYLRefreshConfig` `defaultFooterCreator` | added 2026-11-17 for Android parity |
| `DefaultRefreshHeaderCreator` (interface) | Makes the default header of every layout (`DefaultRefreshHeaderCreator`). | `CYLRefreshConfig` `defaultHeaderCreator` (a block) | added 2026-11-17 for Android parity |
| `DefaultRefreshHeaderCreator.createRefreshHeader` (fun) | A new header for [layout]. | `CYLRefreshConfig` `defaultHeaderCreator` | added 2026-11-17 for Android parity |
| `DefaultRefreshInitializer` (interface) | Sets up every new layout (`DefaultRefreshInitializer`). | `CYLRefreshConfig` `defaultInitializer` (a block) | added 2026-11-17 for Android parity |
| `DefaultRefreshInitializer.initialize` (fun) | Sets up [layout]. | `CYLRefreshConfig` `defaultInitializer` | added 2026-11-17 for Android parity |
| `OnLoadMoreListener` (interface) | Called to load more (`OnLoadMoreListener`). | `CYLRefreshComponentAction` / `CYLRefreshComponentHandler` (`refreshingBlock` / `refreshingHandler` on `cyl_footer`) |  |
| `OnLoadMoreListener.onLoadMore` (fun) | Load more, then call finishLoadMore. | `CYLRefreshComponent` `refreshingBlock` (on `cyl_footer`) |  |
| `OnRefreshListener` (interface) | Called to refresh (`OnRefreshListener`). | `CYLRefreshComponentAction` / `CYLRefreshComponentHandler` (`refreshingBlock` / `refreshingHandler` on `cyl_header`) |  |
| `OnRefreshListener.onRefresh` (fun) | Refresh, then call finishRefresh. | `CYLRefreshComponent` `refreshingBlock` (on `cyl_header`) |  |
| `OnRefreshLoadMoreListener` (interface) | Called to refresh and to load more (`OnRefreshLoadMoreListener`). | `CYLRefreshComponent` `refreshingBlock` (on `cyl_header` and `cyl_footer`) | one callback per control |
| `OnStateChangedListener` (interface) | Hears state changes (`OnStateChangedListener`). | `CYLRefreshComponent` `-addPhaseObserver:` |  |
| `OnStateChangedListener.onStateChanged` (fun) | The state changed from [oldState] to [newState]. | `CYLRefreshComponent` `-addPhaseObserver:` | the observer gets the old and the new phase |
| `OnMultiListener` (interface) | Hears every step of the header and footer (`OnMultiListener`). | `CYLRefreshComponent` `-addScrollObserver:` with `-addPhaseObserver:` | added 2026-11-17 for Android parity |
| `OnMultiListener.onHeaderMoving` (fun) | The header moved. | `CYLRefreshHeader` `-addScrollObserver:` | added 2026-11-17 for Android parity |
| `OnMultiListener.onHeaderReleased` (fun) | The header was released. | `CYLRefreshComponent` `-addPhaseObserver:` (`CYLRefreshPhaseReleasing`, on `cyl_header`) |  |
| `OnMultiListener.onHeaderStartAnimator` (fun) | The header started its animation. | `CYLRefreshComponent` `-addPhaseObserver:` (`CYLRefreshPhaseRefreshing`, on `cyl_header`) |  |
| `OnMultiListener.onHeaderFinish` (fun) | The header finished. | `CYLRefreshComponent` `-addPhaseObserver:` (`CYLRefreshPhaseFinishing`) + `lastRefreshSucceeded` (on `cyl_header`) |  |
| `OnMultiListener.onFooterMoving` (fun) | The footer moved. | `CYLRefreshFooter` `-addScrollObserver:` | added 2026-11-17 for Android parity |
| `OnMultiListener.onFooterReleased` (fun) | The footer was released. | `CYLRefreshComponent` `-addPhaseObserver:` (`CYLRefreshPhaseReleasing`, on `cyl_footer`) |  |
| `OnMultiListener.onFooterStartAnimator` (fun) | The footer started its animation. | `CYLRefreshComponent` `-addPhaseObserver:` (`CYLRefreshPhaseRefreshing`, on `cyl_footer`) |  |
| `OnMultiListener.onFooterFinish` (fun) | The footer finished. | `CYLRefreshComponent` `-addPhaseObserver:` (`CYLRefreshPhaseFinishing`) + `lastRefreshSucceeded` (on `cyl_footer`) |  |
| `ScrollBoundaryDecider` (interface) | Decides when the content is at its top or end (`ScrollBoundaryDecider`). | `CYLRefreshComponent` `canTriggerBlock` | added 2026-11-17 for Android parity |
| `ScrollBoundaryDecider.canRefresh` (fun) | True when [content] can refresh. | `CYLRefreshHeader` `canTriggerBlock` | added 2026-11-17 for Android parity |
| `ScrollBoundaryDecider.canLoadMore` (fun) | True when [content] can load more. | `CYLRefreshFooter` `canTriggerBlock` | added 2026-11-17 for Android parity |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/layout/simple/Simple.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `SimpleBoundaryDecider` (class) | The default boundary check: the content (or the scrolling view under the finger) cannot scroll further (`SimpleBoundaryDecider`). | `CYLRefreshComponent` `canTriggerBlock` = nil (the built-in edge check, `-canTrigger`) | added 2026-11-17 for Android parity |
| `SimpleComponent` (class) | A base for headers and footers, or a wrapper around any view (`SimpleComponent`). | `CYLRefreshComponent` | subclass it, or add any view to a plain `CYLRefreshHeader` / `CYLRefreshBackFooter` |
| `SimpleComponent.cylSpinnerStyle` (var) | Sets the spinner style from outside (CYLRefreshComponent.scrollMode), replacing the one worked out. | `CYLRefreshComponent` `scrollMode` | the Android styles take the spinner style CYLRefreshComponent.scrollMode works out; iOS sets scrollMode on the component itself |
| `SimpleComponent.isAutoRefresh` (val) | True while the current refresh was started by autoRefresh / autoLoadMore, false for a drag (pull request #1095, #1268). | `CYLRefreshComponent` `autoRefresh` (`isAutoRefresh`) | added 2026-11-17 for Android parity |
| `SimpleComponent.setNoMoreData` (fun) | Passes no-more-data to a wrapped footer; false when there is none. | `CYLRefreshFooter` `-endRefreshingWithNoMoreData` / `-resetNoMoreData` |  |
| `SimpleMultiListener` (class) | An [OnMultiListener] whose methods do nothing; override the ones needed (`SimpleMultiListener`). | `CYLRefreshComponent` `-addScrollObserver:` (one block: nothing to override) | added 2026-11-17 for Android parity |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/layout/util/Utils.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `DesignUtil` (object) | Hooks a CoordinatorLayout content to its app bar (`DesignUtil`); works only when the app has the Material library. | n/a | Android CoordinatorLayout / Material library hook |
| `DesignUtil.checkCoordinatorLayout` (fun) |  | n/a | Android CoordinatorLayout / Material library hook |
| `CYLRefreshUtil` (class) | Helpers and the layout's interpolators. | n/a | Android view helpers and interpolators |
| `CYLRefreshUtil.measureViewHeight` (fun) | Measures [view]'s height with its layout parameters. | n/a | Android measure pass |
| `CYLRefreshUtil.scrollListBy` (fun) | Scrolls [listView] by [y] pixels. | n/a | Android ListView helper |
| `CYLRefreshUtil.isScrollableView` (fun) | True for views that scroll by themselves (lists, scroll views, web views, nested scrolling children). | n/a | Android view-type check; iOS controls attach to a UIScrollView |
| `CYLRefreshUtil.isContentView` (fun) | True for views that can be the content: scrolling views, pagers, nested scrolling parents. | n/a | Android view-type check; iOS controls attach to a UIScrollView |
| `CYLRefreshUtil.isPager` (fun) | True for a ViewPager or a ViewPager2 (or a subclass), found by class name: the kernel does not link either class, so an app without viewpager2 (the layout around a plain list) does not crash with a NoClassDefFoundError t | n/a | Android ViewPager check |
| `CYLRefreshUtil.fling` (fun) | Flings [scrollableView] with [velocity]. | n/a | Android scroller fling; UIScrollView decelerates itself |
| `CYLRefreshUtil.canRefresh` (fun) | True when [targetView] (or the child under [touch]) is at its top. | n/a | Android view scroll check; iOS reads the scroll view contentOffset |
| `CYLRefreshUtil.canLoadMore` (fun) | True when [targetView] (or the child under [touch]) is at its end; [contentFull] false also needs content that scrolls. | n/a | Android view scroll check; iOS reads the scroll view contentOffset |
| `CYLRefreshUtil.isTransformedTouchPointInView` (fun) | True when ([x], [y]) in [group] is inside [child]; [outLocalPoint] gets the offset into the child. | n/a | Android touch hit-testing |
| `CYLRefreshUtil.dp2px` (fun) | [dpValue] in pixels. | n/a | dp to px; iOS uses points |
| `CYLRefreshUtil.px2dp` (fun) | [pxValue] in dp. | n/a | px to dp; iOS uses points |

## `android/merged/library/src/main/kotlin/com/cyl/refresh/layout/wrapper/Wrappers.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `RefreshContentWrapper` (class) | Wraps the content: finds its scrolling view, moves it with the pull and decides its boundaries (`RefreshContentWrapper`). | n/a | content-wrapper plumbing; iOS controls attach to the UIScrollView itself |
| `RefreshFooterWrapper` (class) | Any view used as a footer (`RefreshFooterWrapper`). | `CYLRefreshBackFooter` (add the view as a subview) | a plain footer draws nothing; any view can be its content |
| `RefreshHeaderWrapper` (class) | Any view used as a header (`RefreshHeaderWrapper`). | `CYLRefreshHeader` (add the view as a subview) | a plain header draws nothing; any view can be its content |

## `android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderComponent.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLPlaceholderComponent` (class) | One piece of a placeholder: an icon (with an optional title), a text, a hint, a button or a separator (iOS `CYLPlaceholderComponent`). | `CYLPlaceholderComponent` |  |
| `CYLPlaceholderComponent.image` (val) | The icon, or 0 for none. | `CYLPlaceholderComponent` `attributes[CYLPlaceholderItemImage]` / `CYLPlaceholderItemStyle` |  |
| `CYLPlaceholderComponent.tinted` (val) | Whether the icon takes the accent color. | `CYLPlaceholderComponent` `attributes[CYLPlaceholderItemIconColor]` |  |
| `CYLPlaceholderComponent.imageSide` (val) | The icon's side, in dp. | `CYLPlaceholderComponent` `attributes[CYLPlaceholderItemAnimationSize]` |  |
| `CYLPlaceholderComponent.title` (val) | The text, or null. | `CYLPlaceholderComponent` `attributes[CYLPlaceholderItemTitle]` |  |
| `CYLPlaceholderComponent.titleSizeSp` (val) | The text size in sp, or 0 for the kind's own. | `CYLPlaceholderComponent` `attributes[CYLPlaceholderItemTitleFont]` |  |
| `CYLPlaceholderComponent.titleColor` (val) | The text color, or 0 for the kind's own. | `CYLPlaceholderComponent` `attributes[CYLPlaceholderItemTitleColor]` |  |
| `CYLPlaceholderComponent.buttonStyle` (val) | The button's look (buttons only). | `CYLPlaceholderComponent` `+buttonComponentWithTitle:style:action:` (style) |  |
| `CYLPlaceholderComponent.action` (var) | The action a tap runs, or null (`action`). | `CYLPlaceholderComponent` `action` |  |
| `CYLPlaceholderComponent.tapHighlightStyle` (var) | How a finger on a component with an action is shown in the stack view (`tapHighlightStyle`): Dim (default), Shrink or None. | `CYLPlaceholderComponent` `tapHighlightStyle` |  |
| `CYLPlaceholderComponent.accessibilityIdentifier` (var) | The identifier tests find the component's view by (`accessibilityIdentifier`), or null. | `CYLPlaceholderComponent` `accessibilityIdentifier` | matched by the iOS name its KDoc cites |
| `CYLPlaceholderComponent.spacingBefore` (var) | The space above the component, in dp (`spacingBefore`). | `CYLPlaceholderComponent` `spacingBefore` |  |
| `CYLPlaceholderComponent.interactionEnabled` (var) | Whether the component reacts to taps (`interactionEnabled`); a button that does not is shown disabled. | `CYLPlaceholderComponent` `interactionEnabled` |  |
| `CYLPlaceholderComponent.animationRepeatCount` (var) | How often the item's animation repeats (`animationRepeatCount`), 0 for ever: the stack view's CYLPlaceholderView plays it. | `CYLPlaceholderComponent` `animationRepeatCount` |  |
| `CYLPlaceholderComponent.animationLoops` (var) | Whether the item's animation loops: the same as [animationRepeatCount] being 0 (true) or 1 (false), the name CYLTabBarController's `CYLAnimatedItemView` uses. | `CYLAnimatedItemView` | matched by the iOS name its KDoc cites |
| `CYLPlaceholderComponent.animationSpeed` (var) | The item animation's playback speed, 1 by default (`animationSpeed`); the stack view's CYLPlaceholderView applies it when it is not 1. | `CYLPlaceholderComponent` `animationSpeed` | matched by the iOS name its KDoc cites |
| `CYLPlaceholderComponent.showsImageWhenAnimationEnds` (var) | Whether the still image replaces the item's play-once animation when it ends (CYLAnimatedItemView `showsImageWhenAnimationEnds`, CYLTabBarController b13b88f1); off by default, so the last frame stays. | `CYLPlaceholderComponent` `showsImageWhenAnimationEnds` | forwarded to `CYLPlaceholderView.showsImageWhenAnimationEnds` by CYLPlaceholderStackView (iOS CYLAnimatedItemView has no such property, only onAnimationEnd); on for the Success icon |
| `CYLPlaceholderComponent.attributes` (val) | The component's description with the iOS keys (`attributes`): "CYLPlaceholderItemTitle", "CYLPlaceholderItemImage" (a drawable resource), "CYLPlaceholderItemTitleColor", "CYLPlaceholderItemTitleFontSize", and every other | `CYLPlaceholderComponent` `attributes` |  |
| `CYLPlaceholderComponent.componentWithAttributes` (fun) | A component from [attributes] with the iOS keys (see [CYLPlaceholderComponent.attributes]), running [action] when tapped (`componentWithAttributes:action:`). | `CYLPlaceholderComponent` `+componentWithAttributes:action:` |  |
| `CYLPlaceholderComponent.componentWithBundledAnimation` (fun) | A bundled animation, [fileName] in the placeholder's `CYLPlaceholderAnimations` assets (the iOS CYLTableViewPlaceHolder.bundle), [side] dp, over the image of [fallbackStyle], with an optional [title], running [action] wh | `CYLPlaceholderComponent` `+componentWithBundledAnimation:fallbackStyle:title:size:action:` |  |
| `CYLPlaceholderComponent.icon` (fun) | An icon of [side] dp with an optional [title] below it, running [action] when tapped. | `CYLPlaceholderComponent` `componentWithBundledAnimation:fallbackStyle:title:size:action:` | matched by the iOS name its KDoc cites |
| `CYLPlaceholderComponent.text` (fun) | A text of its own, [sizeSp] large and [color] colored (0 for the default). | `CYLPlaceholderComponent` `+textComponentWithText:fontSize:color:` | added 2026-11-16 for Android parity |
| `CYLPlaceholderComponent.hintComponentWithText` (fun) | A smaller, lighter line of text (`hintComponentWithText:`). | `CYLPlaceholderComponent` `+hintComponentWithText:` |  |
| `CYLPlaceholderComponent.buttonComponentWithTitle` (fun) | A button titled [title] in [style], running [action] (`buttonComponentWithTitle:style:action:`). | `CYLPlaceholderComponent` `+buttonComponentWithTitle:style:action:` |  |
| `CYLPlaceholderComponent.separatorComponentWithText` (fun) | "——— [text] ———"; accessibility services read only [text] (`separatorComponentWithText:`). | `CYLPlaceholderComponent` `+separatorComponentWithText:` |  |

## `android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderConfiguration.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLPlaceholderConfigurationError` (class) | Why a configuration was refused (iOS `CYLPlaceholderConfigurationError`). | `CYLPlaceholderConfigurationErrorDomain` (Swift `CYLPlaceholderConfigurationError`) | added 2026-11-16 for Android parity |
| `CYLPlaceholderConfigurationErrorHandler` (typealias) | Called with the reason when a configuration is refused (the iOS `error:` out parameter). | `error:` | matched by the iOS name its KDoc cites |
| `CYLPlaceholderConfiguration_fromJSON` (fun) | A JSON object as a map, an array as a list: the shapes a configuration has. | `NSJSONSerialization` (Foundation) | Android's JSON-to-map helper; iOS reads JSON with Foundation |
| `CYLPlaceholderConfiguration_fromPropertyList` (fun) | An XML property list (the iOS `.plist` format): dict, array, string, integer, real, true, false and date (as text); data is skipped. | `NSPropertyListSerialization` (Foundation) | iOS reads .plist item files with the system parser inside -initWithItemContentsOfURL:imageBundle:error: and the configuration-file initializers; Android has no system parser, so it brings its own |
| `componentWithDictionary` (fun) | A component from a configuration dictionary (iOS `+[CYLPlaceholderComponent componentWithDictionary:error:]`): "type" ("icon", "hint", "button", "separator" or "item"), "title" / "titleKey", "action", and the fields of " | `componentWithDictionary:error:` | matched by the iOS name its KDoc cites |
| `fromConfiguration` (fun) | A placeholder from a configuration dictionary (iOS `-[CYLPlaceholderStackView initWithConfiguration:actions:error:]`): "scenario" (a name), "components" (component dictionaries, replacing the scenario's), "overrides" (di | `initWithConfiguration:actions:error:` | matched by the iOS name its KDoc cites |
| `fromContentsOfURL` (fun) | The configuration in a local ".json" file, a path or "asset:name" (iOS `-initWithContentsOfURL:actions:error:`). | `initWithContentsOfURL:actions:error:` | matched by the iOS name its KDoc cites |
| `fromConfiguration` (fun) | A banner from a configuration dictionary (iOS `-[CYLPlaceholderStatusView initWithConfiguration:error:]`): "text", "textKey", "image" (a drawable name), "titleColor" and "backgroundColor" (color strings such as "#FFC7C7" | `initWithConfiguration:error:` | matched by the iOS name its KDoc cites |
| `fromItemAttributes` (fun) | A placeholder view from item keys (iOS `-[CYLPlaceholderView initWithItemAttributes:imageBundle:error:]`): "CYLPlaceholderItemTitle", "CYLPlaceholderItemImage" (a drawable resource, a Drawable or a drawable name), "CYLPl | `initWithItemAttributes:imageBundle:error:` | matched by the iOS name its KDoc cites |
| `fromItemContentsOfURL` (fun) | Reads the item keys from a local ".json" file (iOS `-initWithItemContentsOfURL:imageBundle:error:`). | `initWithItemContentsOfURL:imageBundle:error:` | matched by the iOS name its KDoc cites |
| `cyl_applyStatusConfiguration` (fun) | Applies a status configuration (iOS `-[UIViewController cyl_applyStatusConfiguration:error:`): "statusBar" (true or "networkUnavailable" for the network banner, or a dictionary for [CYLPlaceholderStatusView.Companion.fro | `cyl_applyStatusConfiguration:error:` | matched by the iOS name its KDoc cites |
| `cyl_applyStatusConfigurationWithContentsOfURL` (fun) | The same, from a local ".json" file (iOS `-cyl_applyStatusConfigurationWithContentsOfURL:error:`). | `cyl_applyStatusConfigurationWithContentsOfURL:error:` | matched by the iOS name its KDoc cites |

## `android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderResourceMonitor.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLPlaceholderResourceMonitor` (object) | Says which animation resource is missing in the status bar at the top of the page (iOS key `CYLPlaceholderResourceMissing`): "Missing resource: home.pag (file not found)", through the activity's [cyl_statusView] (the red | `CYLPlaceholderResourceReporter` | the per-page list of missing animation resources behind the status bar message (key `CYLPlaceholderResourceMissing`); iOS: Swift core `CYLPlaceholderResourceReporter` |
| `CYLPlaceholderResourceMonitor.report` (fun) | Lists [resource] (a file or asset name, "asset:Folder/home.pag" becomes "home.pag") as missing for [reason] ("file not found", "unreadable", "no runtime") and shows it in [activity]'s status bar; a resource already liste | `CYLPlaceholderResourceReporter` `report` |  |
| `CYLPlaceholderResourceMonitor.clear` (fun) | Takes [resource] off the list (it loaded, or is no longer wanted) and hides the bar when the list is empty. | `CYLPlaceholderResourceReporter` `resolve` / `reset` |  |
| `CYLPlaceholderResourceMonitor.missingResources` (fun) | The names now listed as missing for [activity], first reported first. | `CYLPlaceholderResourceReporter` `missingResourceNames` |  |
| `CYLPlaceholderResourceMonitor.installEngineListener` (fun) | Sets the engine's global `CYLAnimationEngines.resourceMissingListener` so every missing resource of the engine reaches [report], for the activity in front. | `CYLPlaceholderResourceReporter` `onResourceMissing` | Android installs the engine's global listener by reflection until the engine commit is in every resolvable commit; iOS detects missing files itself at the pin 12ed11ff |
| `CYLPlaceholderResourceMonitor.attach` (fun) | Sets `onResourceMissing` of [view] (a CYLAnimatedItemView, such as a CYLPlaceholderView) so what it reports is listed for the activity of its context. | `UIViewController` `cyl_showsMissingResources` | Android hooks one view's `onResourceMissing`; iOS turns the bar on per view controller |

## `android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderScenario.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLPlaceholderScenario` (enum) | The ready-made placeholder scenarios, in the iOS order (iOS `CYLPlaceholderScenario`); their components come from [CYLPlaceholderScenarioCatalog.componentsForScenario]. | `CYLPlaceholderScenario` |  |
| `CYLPlaceholderScenarioCategory` (enum) | The group a scenario belongs to (iOS `CYLPlaceholderScenarioCategory`). | `CYLPlaceholderScenarioCategory` |  |
| `CYLPlaceholderPermission` (enum) | The permission a scenario is about (iOS `CYLPlaceholderPermission`). | `CYLPlaceholderPermission` |  |
| `CYLPlaceholderButtonStyle` (enum) | The look of a button component (iOS `CYLPlaceholderButtonStyle`). | `CYLPlaceholderButtonStyle` |  |
| `CYLPlaceholderAction` (object) | The actions of the scenarios' buttons and taps (iOS `CYLPlaceholderAction`), with the iOS values. | `CYLPlaceholderAction` |  |
| `CYLPlaceholderAction.Retry` (val) | "Retry". | `CYLPlaceholderActionRetry` |  |
| `CYLPlaceholderAction.ContactSupport` (val) | "Contact support". | `CYLPlaceholderActionContactSupport` |  |
| `CYLPlaceholderAction.OpenSettings` (val) | "Open Settings". | `CYLPlaceholderActionOpenSettings` |  |
| `CYLPlaceholderAction.GoShopping` (val) | "Go shopping" (EmptyCart, NoOrders). | `CYLPlaceholderActionGoShopping` |  |
| `CYLPlaceholderAction.Done` (val) | "Done". | `CYLPlaceholderActionDone` |  |
| `CYLPlaceholderAction.ChooseManually` (val) | "Choose an address manually". | `CYLPlaceholderActionChooseManually` |  |
| `CYLPlaceholderActionHandler` (typealias) | Handles an action of a placeholder (iOS `CYLPlaceholderActionHandler`); it gets the action's name. | `CYLPlaceholderActionHandler` |  |
| `CYLPlaceholderScenarioCatalog` (object) | The scenarios' components, names, categories and permissions (iOS `CYLPlaceholderScenarioCatalog`). | `CYLPlaceholderScenarioCatalog` |  |
| `CYLPlaceholderScenarioCatalog.allScenarios` (val) | Every scenario, in order (`allScenarios`). | `CYLPlaceholderScenarioCatalog` `allScenarios` |  |
| `CYLPlaceholderScenarioCatalog.nameForScenario` (fun) | The scenario's name without the prefix ("RetryButton") (`nameForScenario:`). | `CYLPlaceholderScenarioCatalog` `+nameForScenario:` |  |
| `CYLPlaceholderScenarioCatalog.scenarioNamed` (fun) | The scenario called [name], with or without the "CYLPlaceholderScenario" prefix, in any case (`scenarioNamed:`); null when there is none. | `CYLPlaceholderScenarioCatalog` `+scenarioNamed:` |  |
| `CYLPlaceholderScenarioCatalog.actionNamed` (fun) | The action called [name] ("retry" or "CYLPlaceholderActionRetry", any case); an unknown name is returned as it is (`actionNamed:`). | `CYLPlaceholderScenarioCatalog` `+actionNamed:` |  |
| `CYLPlaceholderScenarioCatalog.localizedTitleForAction` (fun) | The localized title of an action's button, or null for an unknown action (`localizedTitleForAction:`). | `CYLPlaceholderScenarioCatalog` `+localizedTitleForAction:` |  |
| `CYLPlaceholderScenarioCatalog.localizedNameForScenario` (fun) | The scenario's localized name ("No search results"), for menus and accessibility (`localizedNameForScenario:`). | `CYLPlaceholderScenarioCatalog` `+localizedNameForScenario:` |  |
| `CYLPlaceholderScenarioCatalog.readmeScreenshotNumbersForScenario` (fun) | The README screenshot numbers the scenario stands for (`readmeScreenshotNumbersForScenario:`). | `CYLPlaceholderScenarioCatalog` `+readmeScreenshotNumbersForScenario:` |  |
| `CYLPlaceholderScenarioCatalog.backgroundActionForScenario` (fun) | The action a tap anywhere on the placeholder runs, or null (`backgroundActionForScenario:`). | `CYLPlaceholderScenarioCatalog` `+backgroundActionForScenario:` |  |
| `CYLPlaceholderScenarioCatalog.animationLoopsByDefault` (fun) | Whether a bundled animation is a spinner (loading, progress, activity…), which loops by default so a loading indicator never freezes; every other one plays once and rests on its last frame (iOS `CYLScenarioAnimationLoops | `CYLPlaceholderComponent` `+componentWithBundledAnimation:…` | iOS applies the same spinner check privately (private CYLScenarioAnimationLoopsByDefault in CYLPlaceholderScenario.swift) when it sets animationRepeatCount; no public iOS function |
| `CYLPlaceholderScenarioCatalog.animationFileNamesForScenario` (fun) | The animation files of the scenario, its own icon first (`animationFileNamesForScenario:`), in the assets folder [CYLPlaceholderStackView.ANIMATION_FOLDER]. | `CYLPlaceholderScenarioCatalog` `+animationFileNamesForScenario:` |  |
| `CYLPlaceholderScenarioCatalog.categoryForScenario` (fun) | The scenario's group (`categoryForScenario:`). | `CYLPlaceholderScenarioCatalog` `+categoryForScenario:` |  |
| `CYLPlaceholderScenarioCatalog.permissionForScenario` (fun) | The permission the scenario is about (`permissionForScenario:`). | `CYLPlaceholderScenarioCatalog` `+permissionForScenario:` |  |
| `CYLPlaceholderScenarioCatalog.scenarioForPermission` (fun) | The scenario of a missing [permission]; None gives the generic NoPermission (`scenarioForPermission:`). | `CYLPlaceholderScenarioCatalog` `+scenarioForPermission:` |  |
| `CYLPlaceholderScenarioCatalog.componentsForScenario` (fun) | The scenario's components, in order, with its localized texts (`componentsForScenario:`); each icon is the static fallback image of the iOS animation. | `CYLPlaceholderScenarioCatalog` `+componentsForScenario:` |  |

## `android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderStackView.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLPlaceholderStackView` (class) | Components stacked and centered (iOS `CYLPlaceholderStackView`): a scenario's components ([CYLPlaceholderScenarioCatalog.componentsForScenario]) or your own. | `CYLPlaceholderStackView`, `CYLPlaceholderStackView` `-initWithComponents:actions:`, `CYLPlaceholderStackView` `-initWithScenario:actions:` |  |
| `CYLPlaceholderStackView.scenario` (val) | The scenario shown, or null for a stack of your own components (`scenario`). | `CYLPlaceholderStackView` `scenario` |  |
| `CYLPlaceholderStackView.placeholderView` (val) | The reserved first component, the icon and title (`placeholderView`). | `CYLPlaceholderStackView` `placeholderView` |  |
| `CYLPlaceholderStackView.stackView` (val) | The stacked views (`stackView`). | `CYLPlaceholderStackView` `stackView` |  |
| `CYLPlaceholderStackView.componentViews` (val) | One view per component, in order (`componentViews`). | `CYLPlaceholderStackView` `componentViews` |  |
| `CYLPlaceholderStackView.restartAnimation` (fun) | Plays every item's animation again from progress 0 (the examples' "Play all"), as each item's `restartAnimation()` does (iOS `restartAnimation()`). | `CYLPlaceholderStackView.restartAnimation()` |  |
| `CYLPlaceholderStackView.imageView` (val) | The first icon (hidden and empty when there is none). | `CYLPlaceholderStackView` `imageView` | added 2026-11-16 for Android parity |
| `CYLPlaceholderStackView.titleLabel` (val) | The first title. | `CYLPlaceholderStackView` `titleLabel` | added 2026-11-16 for Android parity |
| `CYLPlaceholderStackView.hintLabel` (val) | The first hint, or null. | `CYLPlaceholderStackView` `hintLabel` | added 2026-11-16 for Android parity |
| `CYLPlaceholderStackView.button` (val) | The first button, or null. | `CYLPlaceholderStackView` `button` | added 2026-11-16 for Android parity |
| `CYLPlaceholderStackView.backgroundAction` (var) | The action a tap anywhere on the placeholder runs, or null (`backgroundAction`). | `CYLPlaceholderStackView` `backgroundAction` |  |
| `CYLPlaceholderStackView.animationView` (val) | The animation view playing in place of the first icon (made by CYLTabBarController's CYLAnimatedItem engine, the first item's inherited `animationView`), or null when no animator plays any of the scenario's files (the ap | `CYLPlaceholderStackView` `animationView` | matched by the iOS name its KDoc cites |
| `CYLPlaceholderStackView.appendComponent` (fun) | Adds [component] at the end (`appendComponent:`). | `CYLPlaceholderStackView` `-appendComponent:` |  |
| `CYLPlaceholderStackView.appendComponentView` (fun) | Adds your own [view] at the end, [spacingBefore] dp below the previous one; a tap runs [action] (`appendComponentView:action:spacingBefore:`). | `CYLPlaceholderStackView` `-appendComponentView:action:spacingBefore:` |  |
| `CYLPlaceholderStackView.setHandler` (fun) | Runs [handler] for [action], replacing its handler (`setHandler:forAction:`); null removes it. | `CYLPlaceholderStackView` `-setHandler:forAction:` |  |
| `CYLPlaceholderStackView.componentViewForAction` (fun) | The view of the first component that runs [action], or null (`componentViewForAction:`). | `CYLPlaceholderStackView` `-componentViewForAction:` |  |
| `CYLPlaceholderStackView.performAction` (fun) | Runs the handler of [action], as a tap would; false when it has none (`performAction:`). | `CYLPlaceholderStackView` `-performAction:` |  |
| `CYLPlaceholderStackView.ANIMATION_FOLDER` (val) | The assets folder of the bundled animations (iOS `CYLTableViewPlaceHolder.bundle/Animations`). | `CYLPlaceholderResourceURL(@"Animations")` | the Animations folder of CYLTableViewPlaceHolder.bundle |
| `CYLPlaceholderStackView.localizedNameForScenario` (fun) | The localized name of a scenario ("No search results"), for menus and accessibility. | `CYLPlaceholderScenarioCatalog` `+localizedNameForScenario:` |  |

## `android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderStatus.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLPlaceholderLocalization` (object) | The language of the built-in texts (iOS `CYLPlaceholderLocalization`): the system's by default, or one you set. | `CYLPlaceholderLocalization` |  |
| `CYLPlaceholderLocalization.supportedLanguages` (val) | The languages the built-in texts come in (`supportedLanguages`). | `CYLPlaceholderLocalization` `supportedLanguages` |  |
| `CYLPlaceholderLocalization.language` (var) | The language to use, or null for the system's (`language`). | `CYLPlaceholderLocalization` `language` |  |
| `CYLPlaceholderLocalization.effectiveLanguage` (val) | The language now used: [language], else the system's when supported, else "en" (`effectiveLanguage`). | `CYLPlaceholderLocalization` `effectiveLanguage` |  |
| `CYLPlaceholderLocalization.localizedContext` (fun) | [context] in [language] (itself when none is set); the built-in texts are read through it. | n/a | an Android Context in another language; iOS reads the language's .lproj directly |
| `CYLPlaceholderLocalization.localizedStringForKey` (fun) | The text of the iOS [key] ("CYLPlaceholderEmptyText"), or [fallback] (`localizedStringForKey:fallback:`). | `CYLPlaceholderLocalization` `+localizedStringForKey:fallback:` |  |
| `CYLPlaceholderNetworkStatus` (enum) | How the device reaches the network (iOS `CYLPlaceholderNetworkStatus`). | `CYLPlaceholderNetworkStatus` |  |
| `CYLPlaceholderNetworkStatusBlock` (typealias) | Called when the network status changes (iOS `CYLPlaceholderNetworkStatusBlock`). | `CYLPlaceholderNetworkStatusBlock` |  |
| `CYLPlaceholderNetworkMonitor` (class) | Watches the network (iOS `CYLPlaceholderNetworkMonitor`); the app needs the ACCESS_NETWORK_STATE permission, which this library's manifest declares. | `CYLPlaceholderNetworkMonitor` |  |
| `CYLPlaceholderNetworkMonitor.networkStatus` (var) | How the device reaches the network (`networkStatus`). | `CYLPlaceholderNetworkMonitor` `networkStatus` |  |
| `CYLPlaceholderNetworkMonitor.reachable` (val) | Whether there is a network (`reachable`). | `CYLPlaceholderNetworkMonitor` `reachable` |  |
| `CYLPlaceholderNetworkMonitor.constrained` (var) | Whether Data Saver restricts the network (`constrained`). | `CYLPlaceholderNetworkMonitor` `constrained` |  |
| `CYLPlaceholderNetworkMonitor.expensive` (var) | Whether the network is metered (`expensive`). | `CYLPlaceholderNetworkMonitor` `expensive` |  |
| `CYLPlaceholderNetworkMonitor.monitoring` (val) | Whether the monitor is watching (`monitoring`). | `CYLPlaceholderNetworkMonitor` `monitoring` |  |
| `CYLPlaceholderNetworkMonitor.startMonitoring` (fun) | Starts watching (`startMonitoring`). | `CYLPlaceholderNetworkMonitor` `-startMonitoring` |  |
| `CYLPlaceholderNetworkMonitor.stopMonitoring` (fun) | Stops watching (`stopMonitoring`). | `CYLPlaceholderNetworkMonitor` `-stopMonitoring` |  |
| `CYLPlaceholderNetworkMonitor.setNetworkStatusChangeBlock` (fun) | Calls [block] on the main thread when the status changes (`setNetworkStatusChangeBlock:`). | `CYLPlaceholderNetworkMonitor` `-setNetworkStatusChangeBlock:` |  |
| `CYLPlaceholderNetworkMonitor.sharedMonitor` (fun) | The shared monitor (`sharedMonitor`). | `CYLPlaceholderNetworkMonitor` `sharedMonitor` |  |
| `CYLPlaceholderNetworkMonitor.nameForStatus` (fun) | A status's name for logs, as on iOS (`nameForStatus:`). | `CYLPlaceholderNetworkMonitor` `+nameForStatus:` |  |
| `CYLPlaceholderStatusViewDelegate` (interface) | Hears taps on a status view (iOS `CYLPlaceholderStatusViewDelegate`). | `CYLPlaceholderStatusViewDelegate` |  |
| `CYLPlaceholderStatusViewDelegate.statusViewClicked` (fun) | The status view was tapped (`statusViewClicked:`). | `CYLPlaceholderStatusViewDelegate` `-statusViewClicked:` |  |
| `CYLPlaceholderStatusViewTapHandler` (typealias) | Called when a status view is tapped (iOS `CYLPlaceholderStatusViewTapHandler`). | `CYLPlaceholderStatusViewTapHandler` |  |
| `CYLPlaceholderStatusView` (class) | A banner with an icon and a text, by default "Network unavailable" (iOS `CYLPlaceholderStatusView`). | `CYLPlaceholderStatusView`, `CYLPlaceholderStatusView` `-initWithFrame:`, `CYLPlaceholderStatusView` `-initWithItemAttributes:error:` |  |
| `CYLPlaceholderStatusView.delegate` (var) | Hears taps (`delegate`). | `CYLPlaceholderStatusView` `delegate` |  |
| `CYLPlaceholderStatusView.placeholderView` (val) | The icon and text (`placeholderView`). | `CYLPlaceholderStatusView` `placeholderView` |  |
| `CYLPlaceholderStatusView.text` (var) | The text (`text`). | `CYLPlaceholderStatusView` `text` |  |
| `CYLPlaceholderStatusView.tapHandler` (var) | Called when the banner is tapped (`tapHandler`). | `CYLPlaceholderStatusView` `tapHandler` |  |
| `CYLPlaceholderStatusView.networkUnavailableItemAttributes` (fun) | The attributes of the "Network unavailable" banner, with the iOS keys (`networkUnavailableItemAttributes`). | `CYLPlaceholderStatusView` `networkUnavailableItemAttributes` |  |
| `CYLPlaceholderStatusDisplay` (object) | What an activity shows for its status (iOS `CYLPlaceholderStatusDisplay`); the values combine with `or`. | `CYLPlaceholderStatusDisplay` |  |
| `CYLPlaceholderStatusDisplay.None` (val) | Nothing. | `CYLPlaceholderStatusDisplayNone` |  |
| `CYLPlaceholderStatusDisplay.StatusBar` (val) | The banner at the top. | `CYLPlaceholderStatusDisplayStatusBar` |  |
| `CYLPlaceholderStatusDisplay.Placeholder` (val) | The placeholder over the content. | `CYLPlaceholderStatusDisplayPlaceholder` |  |
| `CYLPlaceholderStatusDisplay.All` (val) | Both. | `CYLPlaceholderStatusDisplayAll` |  |
| `cyl_statusView` (var) | The activity's status banner (iOS `UIViewController.cyl_statusView`); the default one is made on first use, and setting null goes back to it. | `cyl_statusView` | matched by the iOS name its KDoc cites |
| `cyl_placeholderScrollView` (var) | The scrolling view the placeholder covers, or null for the whole content (`cyl_placeholderScrollView`). | `cyl_placeholderScrollView` | matched by the iOS name its KDoc cites |
| `cyl_statusDisplay` (var) | What the activity shows now (`cyl_statusDisplay`). | `cyl_statusDisplay` | matched by the iOS name its KDoc cites |
| `cyl_setStatusDisplay` (fun) | Shows the banner and / or the placeholder (`cyl_setStatusDisplay:animated:`). | `cyl_setStatusDisplay:animated:` | matched by the iOS name its KDoc cites |
| `cyl_showsStatusViewWhenOffline` (var) | Whether the banner shows by itself while the device is offline (`cyl_showsStatusViewWhenOffline`); it starts the shared network monitor. | `cyl_showsStatusViewWhenOffline` | matched by the iOS name its KDoc cites |
| `cyl_placeholderHidden` (var) | Hides the activity's placeholder even while its display asks for it (`cyl_placeholderHidden`). | `cyl_placeholderHidden` | matched by the iOS name its KDoc cites |

## `android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLPlaceholderView.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLPlaceholderStyle` (enum) | The built-in icons (iOS `CYLPlaceholderStyle`), in the iOS order. | `CYLPlaceholderStyle` |  |
| `CYLPlaceholderMessage` (enum) | The built-in texts (iOS `CYLPlaceholderMessage`). | `CYLPlaceholderMessage` |  |
| `CYLPlaceholderTapHighlightStyle` (enum) | How a tappable placeholder answers a finger (iOS `CYLPlaceholderTapHighlightStyle`). | `CYLPlaceholderTapHighlightStyle` |  |
| `CYLPlaceholderBadgeStyle` (enum) | The badge of a placeholder (iOS `CYLPlaceholderBadgeStyle`). | `CYLPlaceholderBadgeStyle` |  |
| `CYLPlaceholderBadgeAppearance` (class) | The look of every badge (iOS `CYLPlaceholderBadgeAppearance`). | `CYLPlaceholderBadgeAppearance` |  |
| `CYLPlaceholderBadgeAppearance.font` (var) | The text's size, in sp (the size of the iOS `font`). | `CYLPlaceholderBadgeAppearance` `font` |  |
| `CYLPlaceholderBadgeAppearance.fontTypeface` (var) | The text's typeface, or null for the default (the family and weight of the iOS `font`). | `CYLPlaceholderBadgeAppearance` `font` | matched by the iOS name its KDoc cites |
| `CYLPlaceholderBadgeAppearance.cornerRadius` (var) | The corner radius, in dp; below 0 makes a capsule. | `CYLPlaceholderBadgeAppearance` `cornerRadius` |  |
| `CYLPlaceholderBadgeAppearance.contentInsets` (var) | The text's insets, in dp: top, left, bottom, right. | `CYLPlaceholderBadgeAppearance` `contentInsets` |  |
| `CYLPlaceholderBadgeAppearance.animationDuration` (var) | How long a badge change pops (scales from 0.6 to its size), in seconds (`animationDuration`). | `CYLPlaceholderBadgeAppearance` `animationDuration` |  |
| `CYLPlaceholderBadgeAppearance.animatesChanges` (var) | Whether a badge change pops; off when the device turns animations off (`animatesChanges`). | `CYLPlaceholderBadgeAppearance` `animatesChanges` |  |
| `CYLPlaceholderBadgeAppearance.sharedAppearance` (val) | The shared appearance (`sharedAppearance`). | `CYLPlaceholderBadgeAppearance` `+sharedAppearance` |  |
| `CYLPlaceholderAnimationPlayer` (interface) | Plays a placeholder animation (iOS `CYLPlaceholderAnimationPlayer`): what an app's own factory returns ([CYLPlaceholderView.registerAnimationFactory]). | `CYLPlaceholderAnimationPlayer` |  |
| `CYLPlaceholderAnimationPlayer.view` (val) | The view that shows the animation. | `CYLPlaceholderItemAnimationPlayer` `animationView` |  |
| `CYLPlaceholderAnimationPlayer.ready` (val) | Whether the animation is loaded (`ready`). | `CYLPlaceholderAnimationPlayer` `ready` |  |
| `CYLPlaceholderAnimationPlayer.errorHandler` (var) | Called when the animation cannot load (`errorHandler`). | `CYLPlaceholderAnimationPlayer` `errorHandler` |  |
| `CYLPlaceholderAnimationPlayer.readyHandler` (var) | Called once the animation is loaded (`readyHandler`). | `CYLPlaceholderAnimationPlayer` `readyHandler` |  |
| `CYLPlaceholderAnimationPlayer.play` (fun) | Plays from the start (`play`). | `CYLPlaceholderAnimationPlayer` `-play` |  |
| `CYLPlaceholderAnimationPlayer.stop` (fun) | Stops (`stop`). | `CYLPlaceholderAnimationPlayer` `-stop` |  |
| `CYLPlaceholderAnimationPlayer.showLastFrame` (fun) | Shows the last frame (`showLastFrame`). | `CYLPlaceholderAnimationPlayer` `-showLastFrame` |  |
| `CYLPlaceholderAnimationPlayer.setAnimationProgress` (fun) | Moves to [progress], 0 to 1 (`setAnimationProgress:`). | `CYLPlaceholderAnimationPlayer` `-setAnimationProgress:` |  |
| `CYLPlaceholderAnimationPlayer.setAnimationSpeed` (fun) | Plays at [speed] (`setAnimationSpeed:`). | `CYLPlaceholderAnimationPlayer` `-setAnimationSpeed:` |  |
| `CYLPlaceholderAnimationPlayer.setAnimationRepeatCount` (fun) | Repeats [count] times, 0 for ever (`setAnimationRepeatCount:`). | `CYLPlaceholderAnimationPlayer` `-setAnimationRepeatCount:` |  |
| `CYLPlaceholderAnimationPlayer.setAnimationColors` (fun) | Recolors the animation (`setAnimationColors:`). | `CYLPlaceholderAnimationPlayer` `-setAnimationColors:` |  |
| `CYLPlaceholderAnimationFactory` (typealias) | Makes a player for an animation file (iOS `CYLPlaceholderAnimationFactory`); null when it cannot. | `CYLPlaceholderAnimationFactory` |  |
| `CYLPlaceholderTapHandler` (typealias) | Called when a tappable placeholder is tapped (iOS `CYLPlaceholderTapHandler`). | `CYLPlaceholderTapHandler` |  |
| `CYLPlaceholderView` (class) | An icon (or an animation) above a text, with an optional badge and tap (iOS `CYLPlaceholderView`). | `CYLPlaceholderView`, `CYLPlaceholderView` `-initWithImage:text:`, `CYLPlaceholderView` `-initWithStyle:message:` |  |
| `CYLPlaceholderView.imageView` (val) | The icon (`imageView`): the inherited `iconView`. | `CYLPlaceholderView` `imageView` |  |
| `CYLPlaceholderView.textLabel` (val) | The text (`textLabel`): the inherited `titleView`; set it through `title`. | `CYLPlaceholderView` `textLabel` |  |
| `CYLPlaceholderView.badgeLabel` (val) | The badge's label (`badgeLabel`). | `CYLPlaceholderView` `badgeLabel` |  |
| `CYLPlaceholderView.autoPlaysAnimation` (var) | Whether the animation (a file or an image sequence) plays by itself while the view is on screen, true by default; a component that drives it, such as a refresh icon following the pull, sets false and calls [playPlacehold | -[CYLPlaceholderView stopPlaceholderAnimation] | iOS has no flag: a component that drives the animation stops it after creating the view (CYLRefreshIconView) and plays or scrubs it itself |
| `CYLPlaceholderView.defaultTitleFont` (var) | The text size in sp (`defaultTitleFont`, the size of the iOS UIFont). | `CYLPlaceholderView` `defaultTitleFont` |  |
| `CYLPlaceholderView.defaultTitleTypeface` (var) | The text's typeface, or null for the default (the family and weight of the iOS `defaultTitleFont`). | `CYLPlaceholderView` `defaultTitleFont` | matched by the iOS name its KDoc cites |
| `CYLPlaceholderView.defaultTitlePositionAdjustment` (var) | The text's offset in dp, x and y (`defaultTitlePositionAdjustment`). | `CYLPlaceholderView` `defaultTitlePositionAdjustment` |  |
| `CYLPlaceholderView.defaultSelectedTitleFont` (var) | The text size in sp when selected, or 0 for [defaultTitleFont] (`defaultSelectedTitleFont`). | `CYLPlaceholderView` `defaultSelectedTitleFont` |  |
| `CYLPlaceholderView.defaultSelectionIndicatorImage` (var) | The image drawn behind a selected placeholder by default (`defaultSelectionIndicatorImage`). | `CYLPlaceholderView` `defaultSelectionIndicatorImage` |  |
| `CYLPlaceholderView.selectionIndicatorImage` (var) | The image drawn behind a selected placeholder (`selectionIndicatorImage`). | `CYLPlaceholderView` `selectionIndicatorImage` |  |
| `CYLPlaceholderView.selectedState` (var) | Whether the placeholder is selected (`selected`); it also selects the view, which shows `selectedImage`. | `CYLPlaceholderView` `selected` |  |
| `CYLPlaceholderView.contentMargin` (var) | The margin around the content, in dp (`contentMargin`): the view's padding. | `CYLPlaceholderView` `contentMargin` |  |
| `CYLPlaceholderView.preferredMaxLayoutWidth` (var) | The widest the text lays out, in px, or 0 for no limit (`preferredMaxLayoutWidth`). | `CYLPlaceholderView` `preferredMaxLayoutWidth` |  |
| `CYLPlaceholderView.reportsContentSize` (var) | false (the default, as on iOS): the view fills the room it is given (a wrap-content size up to its limit) and centers its content. | `CYLPlaceholderView` `reportsContentSize` |  |
| `CYLPlaceholderView.badgeValue` (var) | The badge's value: null for none, "" for a dot, else the text (`badgeValue`). | `CYLPlaceholderView` `badgeValue` |  |
| `CYLPlaceholderView.badgeCenterOffset` (var) | The badge's offset from the icon's top right corner, in dp, x and y (`badgeCenterOffset`). | `CYLPlaceholderView` `badgeCenterOffset` |  |
| `CYLPlaceholderView.tapHandler` (var) | Called when the placeholder is tapped (`tapHandler`); setting it makes the placeholder a button. | `CYLPlaceholderView` `tapHandler` |  |
| `CYLPlaceholderView.tapInteractionEnabled` (var) | Whether taps reach [tapHandler] (`tapInteractionEnabled`). | `CYLPlaceholderView` `tapInteractionEnabled` |  |
| `CYLPlaceholderView.tapHighlightStyle` (var) | How the placeholder answers a finger (`tapHighlightStyle`). | `CYLPlaceholderView` `tapHighlightStyle` |  |
| `CYLPlaceholderView.tapHighlighted` (var) | Whether a finger is down on it (`tapHighlighted`). | `CYLPlaceholderView` `tapHighlighted` |  |
| `CYLPlaceholderView.tapInteractive` (val) | Whether a tap does something now (`tapInteractive`). | `CYLPlaceholderView` `tapInteractive` |  |
| `CYLPlaceholderView.animationRepeatCount` (var) | How often the animation repeats, 0 for ever (`animationRepeatCount`). | `CYLPlaceholderView` `animationRepeatCount` |  |
| `CYLPlaceholderView.accessibilityLabel` (var) | What accessibility services read for the placeholder (iOS `accessibilityLabel`); null reads the text and the badge. | `UIView` `accessibilityLabel` (UIKit, inherited by `CYLPlaceholderView`) | Android reads it into the view's contentDescription, which CYLAnimatedItemView rebuilds from the title |
| `CYLPlaceholderView.itemAttributes` (var) | The description the view was made from, with the iOS keys (`itemAttributes`). | `CYLPlaceholderView` `itemAttributes` |  |
| `CYLPlaceholderView.showBadgeWithStyle` (fun) | Shows a badge of [style] with [value] (`showBadgeWithStyle:value:`). | `CYLPlaceholderView` `-showBadgeWithStyle:value:` |  |
| `CYLPlaceholderView.performTap` (fun) | Calls [tapHandler] as a tap would; false when the placeholder is not interactive (`performTap`). | `CYLPlaceholderView` `-performTap` |  |
| `CYLPlaceholderView.setAnimationFile` (fun) | Shows the animation at [path] instead of the icon (the inherited `animationURL`), through the animator of the CYLAnimatedItem engine for it (an app's [registerAnimationFactory] first); false when no animator plays it (fo | `CYLPlaceholderView` `-setAnimationFile:` | added 2026-11-16 for Android parity |
| `CYLPlaceholderView.setAnimationImages` (fun) | Shows [images] as one animated icon of [duration] seconds (iOS `CYLPlaceholderItemImages` with `CYLPlaceholderItemAnimationDuration`): played, stopped and moved by the same calls as an animation file, and it replaces an  | `CYLPlaceholderItemImages` | matched by the iOS name its KDoc cites |
| `CYLPlaceholderView.playPlaceholderAnimation` (fun) | Plays the animation or the image sequence (`playPlaceholderAnimation`): the inherited `playAnimation()`. | `CYLPlaceholderView` `-playPlaceholderAnimation` |  |
| `CYLPlaceholderView.stopPlaceholderAnimation` (fun) | Stops the animation or the image sequence (`stopPlaceholderAnimation`): the inherited `stopAnimation()`. | `CYLPlaceholderView` `-stopPlaceholderAnimation` |  |
| `CYLPlaceholderView.showPlaceholderAnimationLastFrame` (fun) | Shows the animation's last frame (`showPlaceholderAnimationLastFrame`): the inherited `showAnimationLastFrame()`. | `CYLPlaceholderView` `-showPlaceholderAnimationLastFrame` |  |
| `CYLPlaceholderView.setPlaceholderAnimationProgress` (fun) | Moves the animation, or the image sequence while it is not playing, to [progress], 0 to 1 (`setPlaceholderAnimationProgress:`). | `CYLPlaceholderView` `-setPlaceholderAnimationProgress:` |  |
| `CYLPlaceholderView.setPlaceholderAnimationSpeed` (fun) | Plays the animation at [speed] (`setPlaceholderAnimationSpeed:`): the inherited `animationSpeed`. | `CYLPlaceholderView` `-setPlaceholderAnimationSpeed:` |  |
| `CYLPlaceholderView.registerAnimationFactory` (fun) | Plays files ending in [extension] ("json", "pag", "riv", "gif") with [factory] (`registerAnimationFactory:forFileExtension:`): the factory becomes an animator of the CYLAnimatedItem engine, looked up before the engine's  | `CYLPlaceholderView` `+registerAnimationFactory:forFileExtension:` |  |
| `CYLPlaceholderView.imageNameForStyle` (fun) | The resource name of [style]'s icon, "CYLPlaceholderWifiOff" as on iOS (`imageNameForStyle:`). | `CYLPlaceholderView` `+imageNameForStyle:` |  |
| `CYLPlaceholderView.imageForStyle` (fun) | [style]'s icon (`imageForStyle:`); every one but Empty is meant to be tinted. | `CYLPlaceholderView` `+imageForStyle:` |  |
| `CYLPlaceholderView.localizedTextForMessage` (fun) | [message]'s localized text (`localizedTextForMessage:`). | `CYLPlaceholderView` `+localizedTextForMessage:` |  |

## `android/placeholder/src/main/kotlin/com/cyl/placeholder/CYLTableViewPlaceHolder.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLTablePlaceholderViewBlock` (typealias) | Makes the placeholder of an empty list, or null for none (iOS `CYLTablePlaceholderViewBlock` and `CYLCollectionPlaceholderViewBlock`; on Android both a table and a collection are a RecyclerView). | `CYLTablePlaceholderViewBlock` |  |
| `CYLTablePlaceholderNormalBlock` (typealias) | Called when the list has data again (iOS `CYLTablePlaceholderNormalBlock`). | `CYLTablePlaceholderNormalBlock` |  |
| `CYLCollectionPlaceholderViewBlock` (typealias) | The same as [CYLTablePlaceholderViewBlock] (iOS `CYLCollectionPlaceholderViewBlock`). | `CYLCollectionPlaceholderViewBlock` |  |
| `CYLCollectionPlaceholderNormalBlock` (typealias) | The same as [CYLTablePlaceholderNormalBlock] (iOS `CYLCollectionPlaceholderNormalBlock`). | `CYLCollectionPlaceholderNormalBlock` |  |
| `CYLTableViewPlaceHolderDelegate` (interface) | Gives an empty list its placeholder (iOS `CYLTableViewPlaceHolderDelegate`); an adapter that implements it needs no block: [cyl_reloadData] asks it. | `CYLTableViewPlaceHolderDelegate` |  |
| `CYLTableViewPlaceHolderDelegate.makePlaceHolderView` (fun) | The placeholder to show while the list is empty (`makePlaceHolderView`). | `CYLTableViewPlaceHolderDelegate` `-makePlaceHolderView` |  |
| `CYLTableViewPlaceHolderDelegate.enableScrollWhenPlaceHolderViewShowing` (fun) | Whether the empty list still scrolls, so a pull to refresh works on it (`enableScrollWhenPlaceHolderViewShowing`). | `CYLTableViewPlaceHolderDelegate` `-enableScrollWhenPlaceHolderViewShowing` |  |
| `CYLTableViewPlaceHolderDelegate.frameForPlaceHolderViewInTableView` (fun) | The placeholder's frame inside the list's bounds, in pixels, or null for all of them (`frameForPlaceHolderViewInTableView:`). | `CYLTableViewPlaceHolderDelegate` `-frameForPlaceHolderViewInTableView:` |  |
| `cyl_placeholderViewBlock` (fun) | Shows the view [placeholderViewBlock] makes whenever the list is empty, from now on (iOS `cyl_placeholderViewBlock:`); null stops it. | `cyl_placeholderViewBlock:` | matched by the iOS name its KDoc cites |
| `cyl_placeholderViewBlock` (fun) | As [cyl_placeholderViewBlock], calling [backToNormalBlock] when the list has data again (iOS `cyl_placeholderViewBlock:backToNormalBlock:`). | `cyl_placeholderViewBlock:backToNormalBlock:` | matched by the iOS name its KDoc cites |
| `cyl_reloadData` (fun) | Reloads the list and shows or removes its placeholder (iOS `cyl_reloadData`); an adapter that is a [CYLTableViewPlaceHolderDelegate] gives the placeholder. | `cyl_reloadData` | matched by the iOS name its KDoc cites |
| `cyl_placeholderHidden` (var) | Hides the placeholder even while the list is empty (iOS `UIScrollView.cyl_placeholderHidden`). | `cyl_placeholderHidden` | matched by the iOS name its KDoc cites |
| `cyl_placeholderView` (val) | The placeholder now shown for the list, or null. | `UIScrollView` `cyl_placeholderView` | added 2026-11-16 for Android parity |

## `android/placeholder/src/main/kotlin/com/cyl/placeholder/bridge/CYLPlaceholderBridge.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLPlaceholderBridge` (object) | Builds and updates the placeholder views of a bridge from the item and configuration maps with the iOS keys. | `CYLPlaceholderBridge` (enum, `CYLPlaceholderBridge.swift`) |  |
| `CYLPlaceholderBridge.placeholderView` (fun) | A placeholder view from an item map (the `CYLPlaceholderItem*` keys of `docs/Placeholder-Scenarios.md`), or null when the map is invalid. | `CYLPlaceholderBridge.placeholderView(params:)` |  |
| `CYLPlaceholderBridge.updatePlaceholderView` (fun) | Applies one live update to a placeholder view: "animationLoops" (a boolean), "animationSpeed" (a number above 0) or "restartAnimation" (any value, plays again from the start). | `CYLPlaceholderBridge.updatePlaceholderView(_:name:value:)` |  |
| `CYLPlaceholderBridge.stackView` (fun) | A placeholder stack from a configuration map (the "scenario" or "components" of `docs/Placeholder-Scenarios.md`, whose components may carry "animationLoops" and "animationSpeed"), or null when it is invalid. | `CYLPlaceholderBridge.stackView(configuration:onAction:)` |  |
| `CYLPlaceholderBridge.updateStackView` (fun) | Applies one live update to a stack: "restartAnimation" plays every animation again from the start. | `CYLPlaceholderBridge.updateStackView(_:name:value:)` |  |
| `CYLPlaceholderHUDBridge` (class) | Drives a [CYLPlaceholderHUD] from method names and argument maps, the way a method channel or a React Native module delivers them. | `CYLPlaceholderHUDBridge` (class, `CYLPlaceholderBridge.swift`) |  |
| `CYLPlaceholderHUDBridge.hud` (val) | The HUD that is driven. | `CYLPlaceholderHUDBridge.hud` |  |
| `CYLPlaceholderHUDBridge.handle` (fun) | Runs [method] with [arguments]: "show", "showWithStatus" ("status"), "showProgress" ("progress", "status"), "setStatus", "showInfoWithStatus", "showSuccessWithStatus", "showErrorWithStatus" ("status"), "showComponents" ( | `CYLPlaceholderHUDBridge.handle(method:arguments:)` |  |

## `android/placeholder/src/main/kotlin/com/cyl/placeholder/hud/CYLPlaceholderHUD.kt`

| Android API | 描述 / Description | iOS API | 说明 / Note |
|:---|:---|:---|:---|
| `CYLPlaceholderHUDStyle` (enum) | The HUD's colors (iOS `CYLPlaceholderHUDStyle`). | `CYLPlaceholderHUDStyle` |  |
| `CYLPlaceholderHUDMaskType` (enum) | What covers the screen behind the HUD (iOS `CYLPlaceholderHUDMaskType`). | `CYLPlaceholderHUDMaskType` |  |
| `CYLPlaceholderHUDState` (enum) | What the HUD shows (iOS `CYLPlaceholderHUDState`). | `CYLPlaceholderHUDState` |  |
| `CYLPlaceholderHUDDismissCompletion` (typealias) | Called once the HUD has disappeared (iOS `CYLPlaceholderHUDDismissCompletion`). | `CYLPlaceholderHUDDismissCompletion` |  |
| `CYLPlaceholderHUD` (class) | A heads-up display over a container (iOS `CYLPlaceholderHUD`): a spinner, a progress bar, a success / error / info icon or a placeholder scenario, with a status text. | `CYLPlaceholderHUD`, `CYLPlaceholderHUD` `-initWithContainerView:` |  |
| `CYLPlaceholderHUD.containerView` (var) | The container the HUD covers (`containerView`). | `CYLPlaceholderHUD` `containerView` |  |
| `CYLPlaceholderHUD.hudView` (val) | The box (`hudView`). | `CYLPlaceholderHUD` `hudView` |  |
| `CYLPlaceholderHUD.contentView` (val) | The box's content area (`contentView`). | `CYLPlaceholderHUD` `contentView` |  |
| `CYLPlaceholderHUD.placeholderView` (var) | The icon and status (`placeholderView`). | `CYLPlaceholderHUD` `placeholderView` |  |
| `CYLPlaceholderHUD.actions` (var) | The handlers of the shown components' actions (`actions`). | `CYLPlaceholderHUD` `actions` |  |
| `CYLPlaceholderHUD.state` (var) | What is shown (`state`). | `CYLPlaceholderHUD` `state` |  |
| `CYLPlaceholderHUD.status` (var) | The status text (`status`). | `CYLPlaceholderHUD` `status` |  |
| `CYLPlaceholderHUD.progress` (var) | The progress, 0 to 1 (`progress`). | `CYLPlaceholderHUD` `progress` |  |
| `CYLPlaceholderHUD.visible` (val) | Whether the HUD is on screen (`visible`). | `CYLPlaceholderHUD` `visible` |  |
| `CYLPlaceholderHUD.activityCount` (var) | How many [show] calls wait for [popActivity] (`activityCount`). | `CYLPlaceholderHUD` `activityCount` |  |
| `CYLPlaceholderHUD.style` (var) | The colors (`style`). | `CYLPlaceholderHUD` `style` |  |
| `CYLPlaceholderHUD.maskType` (var) | What covers the screen (`maskType`). | `CYLPlaceholderHUD` `maskType` |  |
| `CYLPlaceholderHUD.font` (var) | The status text size, in sp (the size of the iOS `font`). | `CYLPlaceholderHUD` `font` |  |
| `CYLPlaceholderHUD.fontTypeface` (var) | The status text's typeface, or null for the default (the family and weight of the iOS `font`). | `CYLPlaceholderHUD` `font` | matched by the iOS name its KDoc cites |
| `CYLPlaceholderHUD.cornerRadius` (var) | The box's corner radius, in dp (`cornerRadius`). | `CYLPlaceholderHUD` `cornerRadius` |  |
| `CYLPlaceholderHUD.minimumSize` (var) | The box's smallest size, in dp: width and height (`minimumSize`). | `CYLPlaceholderHUD` `minimumSize` |  |
| `CYLPlaceholderHUD.animationSize` (var) | The icon's side, in dp (`animationSize`). | `CYLPlaceholderHUD` `animationSize` |  |
| `CYLPlaceholderHUD.offsetFromCenter` (var) | The box's offset from the container's center, in dp: x and y (`offsetFromCenter`). | `CYLPlaceholderHUD` `offsetFromCenter` |  |
| `CYLPlaceholderHUD.loadingAnimationFileName` (var) | The animation shown while loading, played by a registered factory (`loadingAnimationFileName`). | `CYLPlaceholderHUD` `loadingAnimationFileName` |  |
| `CYLPlaceholderHUD.progressAnimationFileName` (var) | The animation shown with progress (`progressAnimationFileName`). | `CYLPlaceholderHUD` `progressAnimationFileName` |  |
| `CYLPlaceholderHUD.successAnimationFileName` (var) | The animation shown on success (`successAnimationFileName`). | `CYLPlaceholderHUD` `successAnimationFileName` |  |
| `CYLPlaceholderHUD.successImage` (var) | The success icon, or null for the built-in one (`successImage`). | `CYLPlaceholderHUD` `successImage` |  |
| `CYLPlaceholderHUD.errorImage` (var) | The error icon, or null for the built-in one (`errorImage`). | `CYLPlaceholderHUD` `errorImage` |  |
| `CYLPlaceholderHUD.infoImage` (var) | The info icon, or null for the built-in one (`infoImage`). | `CYLPlaceholderHUD` `infoImage` |  |
| `CYLPlaceholderHUD.graceTimeInterval` (var) | Seconds a loading HUD waits before it shows, so a quick task shows none (`graceTimeInterval`). | `CYLPlaceholderHUD` `graceTimeInterval` |  |
| `CYLPlaceholderHUD.minimumDismissTimeInterval` (var) | The shortest time a success / error / info HUD stays, in seconds (`minimumDismissTimeInterval`). | `CYLPlaceholderHUD` `minimumDismissTimeInterval` |  |
| `CYLPlaceholderHUD.maximumDismissTimeInterval` (var) | The longest time it stays, in seconds (`maximumDismissTimeInterval`). | `CYLPlaceholderHUD` `maximumDismissTimeInterval` |  |
| `CYLPlaceholderHUD.fadeInAnimationDuration` (var) | The fade-in duration, in seconds (`fadeInAnimationDuration`). | `CYLPlaceholderHUD` `fadeInAnimationDuration` |  |
| `CYLPlaceholderHUD.fadeOutAnimationDuration` (var) | The fade-out duration, in seconds (`fadeOutAnimationDuration`). | `CYLPlaceholderHUD` `fadeOutAnimationDuration` |  |
| `CYLPlaceholderHUD.hapticsEnabled` (var) | Whether success and error vibrate (`hapticsEnabled`). | `CYLPlaceholderHUD` `hapticsEnabled` |  |
| `CYLPlaceholderHUD.show` (fun) | Shows a spinner (`show`); each call counts until [popActivity]. | `CYLPlaceholderHUD` `+show`, `CYLPlaceholderHUD` `-show` |  |
| `CYLPlaceholderHUD.showWithStatus` (fun) | Shows a spinner with [status] (`showWithStatus:`). | `CYLPlaceholderHUD` `+showWithStatus:`, `CYLPlaceholderHUD` `-showWithStatus:` |  |
| `CYLPlaceholderHUD.showProgress` (fun) | Shows a progress bar at [progress], 0 to 1 (`showProgress:`). | `CYLPlaceholderHUD` `+showProgress:`, `CYLPlaceholderHUD` `+showProgress:status:`, `CYLPlaceholderHUD` `-showProgress:` |  |
| `CYLPlaceholderHUD.showProgress` (fun) | Shows a progress bar at [progress] with [status] (`showProgress:status:`). | `CYLPlaceholderHUD` `+showProgress:`, `CYLPlaceholderHUD` `+showProgress:status:`, `CYLPlaceholderHUD` `-showProgress:` |  |
| `CYLPlaceholderHUD.setStatus` (fun) | Changes the status text in place (`setStatus:`). | `CYLPlaceholderHUD` `+setStatus:`, `CYLPlaceholderHUD` `-setStatus:` |  |
| `CYLPlaceholderHUD.showInfoWithStatus` (fun) | Shows the info icon with [status], then hides (`showInfoWithStatus:`). | `CYLPlaceholderHUD` `+showInfoWithStatus:`, `CYLPlaceholderHUD` `-showInfoWithStatus:` |  |
| `CYLPlaceholderHUD.showSuccessWithStatus` (fun) | Shows the success icon with [status], then hides (`showSuccessWithStatus:`). | `CYLPlaceholderHUD` `+showSuccessWithStatus:`, `CYLPlaceholderHUD` `-showSuccessWithStatus:` |  |
| `CYLPlaceholderHUD.showErrorWithStatus` (fun) | Shows the error icon with [status], then hides (`showErrorWithStatus:`). | `CYLPlaceholderHUD` `+showErrorWithStatus:`, `CYLPlaceholderHUD` `-showErrorWithStatus:` |  |
| `CYLPlaceholderHUD.showImage` (fun) | Shows [image] with [status], then hides (`showImage:status:`). | `CYLPlaceholderHUD` `+showImage:status:`, `CYLPlaceholderHUD` `-showImage:status:` |  |
| `CYLPlaceholderHUD.showComponents` (fun) | Shows your [components]; [actions] handle their buttons (`showComponents:actions:`). | `CYLPlaceholderHUD` `-showComponents:actions:` |  |
| `CYLPlaceholderHUD.showScenario` (fun) | Shows [scenario]; [actions] handle its buttons (`showScenario:actions:`). | `CYLPlaceholderHUD` `-showScenario:actions:` |  |
| `CYLPlaceholderHUD.popActivity` (fun) | Ends one [show]; the HUD hides once every one has ended (`popActivity`). | `CYLPlaceholderHUD` `+popActivity`, `CYLPlaceholderHUD` `-popActivity` |  |
| `CYLPlaceholderHUD.dismiss` (fun) | Hides at once (`dismiss`). | `CYLPlaceholderHUD` `+dismiss`, `CYLPlaceholderHUD` `-dismiss` |  |
| `CYLPlaceholderHUD.dismissWithCompletion` (fun) | Hides, then calls [completion] (`dismissWithCompletion:`). | `CYLPlaceholderHUD` `+dismissWithCompletion:`, `CYLPlaceholderHUD` `-dismissWithCompletion:` |  |
| `CYLPlaceholderHUD.dismissWithDelay` (fun) | Hides after [delay] seconds (`dismissWithDelay:`). | `CYLPlaceholderHUD` `+dismissWithDelay:`, `CYLPlaceholderHUD` `+dismissWithDelay:completion:`, `CYLPlaceholderHUD` `-dismissWithDelay:` |  |
| `CYLPlaceholderHUD.dismissWithDelay` (fun) | Hides after [delay] seconds, then calls [completion] (`dismissWithDelay:completion:`). | `CYLPlaceholderHUD` `+dismissWithDelay:`, `CYLPlaceholderHUD` `+dismissWithDelay:completion:`, `CYLPlaceholderHUD` `-dismissWithDelay:` |  |
| `CYLPlaceholderHUD.displayDurationForString` (fun) | How long a timed HUD with [string] stays, in seconds (`displayDurationForString:`). | `CYLPlaceholderHUD` `+displayDurationForString:`, `CYLPlaceholderHUD` `-displayDurationForString:` |  |
| `CYLPlaceholderHUD.MAXIMUM_WIDTH_DP` (val) | The box's widest size, in dp (iOS `CYLPlaceholderHUDMaximumWidth`, 260 pt). | `CYLPlaceholderHUD` | iOS keeps the same 260 pt limit as a private constant (private CYLPlaceholderHUDMaximumWidth in CYLPlaceholderHUD.swift); no public iOS constant |
| `CYLPlaceholderHUD.sharedHUD` (fun) | The shared HUD for [containerView]'s window; set its container once (`sharedHUD`). | `CYLPlaceholderHUD` `sharedHUD` |  |
| `CYLPlaceholderHUD.show` (fun) | [show] on the shared HUD. | `CYLPlaceholderHUD` `+show`, `CYLPlaceholderHUD` `-show` |  |
| `CYLPlaceholderHUD.showWithStatus` (fun) | [showWithStatus] on the shared HUD. | `CYLPlaceholderHUD` `+showWithStatus:`, `CYLPlaceholderHUD` `-showWithStatus:` |  |
| `CYLPlaceholderHUD.showProgress` (fun) | [showProgress] on the shared HUD. | `CYLPlaceholderHUD` `+showProgress:`, `CYLPlaceholderHUD` `+showProgress:status:`, `CYLPlaceholderHUD` `-showProgress:` |  |
| `CYLPlaceholderHUD.showProgress` (fun) | [showProgress] with a status on the shared HUD. | `CYLPlaceholderHUD` `+showProgress:`, `CYLPlaceholderHUD` `+showProgress:status:`, `CYLPlaceholderHUD` `-showProgress:` |  |
| `CYLPlaceholderHUD.setStatus` (fun) | [setStatus] on the shared HUD. | `CYLPlaceholderHUD` `+setStatus:`, `CYLPlaceholderHUD` `-setStatus:` |  |
| `CYLPlaceholderHUD.showInfoWithStatus` (fun) | [showInfoWithStatus] on the shared HUD. | `CYLPlaceholderHUD` `+showInfoWithStatus:`, `CYLPlaceholderHUD` `-showInfoWithStatus:` |  |
| `CYLPlaceholderHUD.showSuccessWithStatus` (fun) | [showSuccessWithStatus] on the shared HUD. | `CYLPlaceholderHUD` `+showSuccessWithStatus:`, `CYLPlaceholderHUD` `-showSuccessWithStatus:` |  |
| `CYLPlaceholderHUD.showErrorWithStatus` (fun) | [showErrorWithStatus] on the shared HUD. | `CYLPlaceholderHUD` `+showErrorWithStatus:`, `CYLPlaceholderHUD` `-showErrorWithStatus:` |  |
| `CYLPlaceholderHUD.showImage` (fun) | [showImage] on the shared HUD. | `CYLPlaceholderHUD` `+showImage:status:`, `CYLPlaceholderHUD` `-showImage:status:` |  |
| `CYLPlaceholderHUD.popActivity` (fun) | [popActivity] on the shared HUD. | `CYLPlaceholderHUD` `+popActivity`, `CYLPlaceholderHUD` `-popActivity` |  |
| `CYLPlaceholderHUD.dismiss` (fun) | [dismiss] on the shared HUD. | `CYLPlaceholderHUD` `+dismiss`, `CYLPlaceholderHUD` `-dismiss` |  |
| `CYLPlaceholderHUD.dismissWithCompletion` (fun) | [dismissWithCompletion] on the shared HUD. | `CYLPlaceholderHUD` `+dismissWithCompletion:`, `CYLPlaceholderHUD` `-dismissWithCompletion:` |  |
| `CYLPlaceholderHUD.dismissWithDelay` (fun) | [dismissWithDelay] on the shared HUD. | `CYLPlaceholderHUD` `+dismissWithDelay:`, `CYLPlaceholderHUD` `+dismissWithDelay:completion:`, `CYLPlaceholderHUD` `-dismissWithDelay:` |  |
| `CYLPlaceholderHUD.dismissWithDelay` (fun) | [dismissWithDelay] with a completion on the shared HUD. | `CYLPlaceholderHUD` `+dismissWithDelay:`, `CYLPlaceholderHUD` `+dismissWithDelay:completion:`, `CYLPlaceholderHUD` `-dismissWithDelay:` |  |
| `CYLPlaceholderHUD.displayDurationForString` (fun) | [displayDurationForString] of the shared HUD (default limits without one). | `CYLPlaceholderHUD` `+displayDurationForString:`, `CYLPlaceholderHUD` `-displayDurationForString:` |  |
