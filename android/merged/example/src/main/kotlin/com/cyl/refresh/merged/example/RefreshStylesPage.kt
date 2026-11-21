package com.cyl.refresh.merged.example

import android.graphics.Color
import android.view.View
import android.widget.LinearLayout
import android.widget.ScrollView
import com.cyl.refresh.CYLRefreshBackNormalFooter
import com.cyl.refresh.CYLRefreshBezierCircleHeader
import com.cyl.refresh.CYLRefreshBezierRadarFooter
import com.cyl.refresh.CYLRefreshBezierRadarHeader
import com.cyl.refresh.CYLRefreshComponent
import com.cyl.refresh.CYLRefreshDeliveryFooter
import com.cyl.refresh.CYLRefreshDeliveryHeader
import com.cyl.refresh.CYLRefreshDropBoxHeader
import com.cyl.refresh.CYLRefreshDrawnFooter
import com.cyl.refresh.CYLRefreshFlyHeader
import com.cyl.refresh.rive.CYLRefreshRiveHeader
import com.cyl.refresh.rive.CYLRefreshRiveStyle
import com.cyl.refresh.CYLRefreshFooter
import com.cyl.refresh.CYLRefreshGameBattleCityHeader
import com.cyl.refresh.CYLRefreshGameHitBlockHeader
import com.cyl.refresh.CYLRefreshHeader
import com.cyl.refresh.CYLRefreshMaterialFooter
import com.cyl.refresh.CYLRefreshMaterialHeader
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.CYLRefreshOriginalHeader
import com.cyl.refresh.CYLRefreshPhoenixFooter
import com.cyl.refresh.CYLRefreshPhoenixHeader
import com.cyl.refresh.CYLRefreshStoreHouseHeader
import com.cyl.refresh.CYLRefreshTaurusFooter
import com.cyl.refresh.CYLRefreshTaurusHeader
import com.cyl.refresh.CYLRefreshWaveSwipeHeader
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import com.cyl.refresh.layout.CYLRefreshLayout

/*
 * The demo of CYLRefresh styles (the third-party refresh package (LICENSE.refresh-third-party.txt), CYLRefreshStylesDemo, MIT; by SCWANG),
 * translated from the iOS example's Swift (`CYLRefreshStylesDemoViewController.swift`) to Kotlin on this project's
 * Android API. The theme colors the page's own bar, as iOS colors the navigation bar.
 */

/**
 * The styles of the "CYLRefresh styles" section: title and method (iOS `styles`).
 */
internal val refreshStyles = listOf(
    R.string.merged_style_delivery to "styleDelivery", R.string.merged_style_classics to "styleClassics",
    R.string.merged_style_drop_box to "styleDropBox", R.string.merged_style_phoenix to "stylePhoenix",
    R.string.merged_style_taurus to "styleTaurus", R.string.merged_style_bezier_radar to "styleBezierRadar",
    R.string.merged_style_bezier_circle to "styleBezierCircle", R.string.merged_style_store_house to "styleStoreHouse",
    R.string.merged_style_wave_swipe to "styleWaveSwipe", R.string.merged_style_original to "styleOriginal",
    R.string.merged_style_material to "styleMaterial", R.string.merged_style_game_hit_block to "styleGameHitBlock",
    R.string.merged_style_game_battle_city to "styleGameBattleCity", R.string.merged_style_fly to "styleFly",
    R.string.merged_style_classics_footer to "styleClassicsFooter",
    R.string.merged_style_bezier_radar_footer to "styleBezierRadarFooter",
    R.string.merged_style_material_footer to "styleMaterialFooter",
    R.string.merged_style_delivery_footer to "styleDeliveryFooter",
    R.string.merged_style_phoenix_footer to "stylePhoenixFooter", R.string.merged_style_taurus_footer to "styleTaurusFooter",
    R.string.merged_style_rive_bow to "styleRiveBow", R.string.merged_style_rive_bubbles to "styleRiveBubbles",
    R.string.merged_style_rive_halloween to "styleRiveHalloween", R.string.merged_style_rive_skating to "styleRiveSkating",
    R.string.merged_style_rive_space to "styleRiveSpace", R.string.merged_style_rive_squats to "styleRiveSquats",
    R.string.merged_style_rive_space_footer to "styleRiveSpaceFooter",
    R.string.merged_style_svga_bow to "styleSvgaBow", R.string.merged_style_svga_bubbles to "styleSvgaBubbles",
    R.string.merged_style_svga_halloween to "styleSvgaHalloween", R.string.merged_style_svga_skating to "styleSvgaSkating",
    R.string.merged_style_svga_space to "styleSvgaSpace", R.string.merged_style_svga_squats to "styleSvgaSquats",
    R.string.merged_style_svga_space_footer to "styleSvgaSpaceFooter",
)

/**
 * The SVGA twins of the Rive styles (Task-Log "SVGA animations, every Rive demo copied 1:1"): this repository's own
 * scenes of the same subjects (scripts/make_svga_scenes.py), drawn by the CYLAnimatedItem engine in SVGASceneHeader,
 * which stretches like the Rive header; SVGA has no state machine, so the pull scrubs the scene and refreshing loops it.
 */
private fun svgaScene(method: String): String? = when (method) {
    "styleSvgaBow" -> "Bow"
    "styleSvgaBubbles" -> "Bubbles"
    "styleSvgaHalloween" -> "Halloween"
    "styleSvgaSkating" -> "Skating"
    "styleSvgaSpace", "styleSvgaSpaceFooter" -> "Space"
    "styleSvgaSquats" -> "Squats"
    else -> null
}?.let { "asset:Animations/CYLScenarioExampleRefresh$it.svga" }


/**
 * flutter_easy_refresh's Rive style packages: the file in this example's assets and the names each package's indicator
 * drives (each package's lib/src indicator at dcdbb81; iOS `riveStyle`).
 */
private fun riveStyle(method: String): CYLRefreshRiveStyle? {
    val file = when (method) {
        "styleRiveBow" -> "Bow"
        "styleRiveBubbles" -> "Bubbles"
        "styleRiveHalloween" -> "Halloween"
        "styleRiveSkating" -> "Skating"
        "styleRiveSpace", "styleRiveSpaceFooter" -> "Space"
        "styleRiveSquats" -> "Squats"
        else -> return null
    }
    return CYLRefreshRiveStyle("asset:Animations/CYLScenarioExampleRefresh$file.riv").apply {
        when (file) {
            "Bow" -> {
                stateMachineName = "numberSimulation"
                triggerOffset = 200f
                fitsWidth = true
                pullInput = "pull"
                pullInputMinimum = 10.0
                releaseTrigger = "advance"
                finishTrigger = "advance"
                restartTrigger = "restart"
            }
            "Bubbles" -> {
                stateMachineName = "Motion"
                pullInput = "numDrag"
                pullInputStart = 4.0 / 7.0
                pullInputMaximum = 99.0
                pullInputRefreshingValue = 100.0
                loadingNumber = "numLoad"
            }
            "Halloween" -> {
                triggerOffset = 200f
                pullAnimation = "Pull"
                triggerAnimation = "Trigger"
                loadingAnimation = "Loading"
            }
            "Skating" -> {
                stateMachineName = "Reload"
                minimumHeight = 140f
                pullInput = "pullAmount"
                releaseTrigger = "pullRelease"
                finishTrigger = "loadFinished"
            }
            "Space" -> {
                stateMachineName = "Reload"
                pullInput = "Pull Amount"
                loadingBoolean = "Start"
            }
            else -> {
                triggerOffset = 190f
                fitsWidth = true
                idleAnimation = "Idle"
                loadingAnimation = "Demo"
            }
        }
    }
}

/**
 * One style's page (iOS `CYLRefreshStylesDemoViewController`): theme rows and test data, with the style's header (it
 * refreshes on open) or footer (it doubles the rows, then has no more data past 16).
 */
internal fun RefreshExamplesPage.refreshStylePage(title: String, method: String): View {
    val context = requireContext()
    val layout = CYLRefreshLayout(context)
    val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL; tag = "refreshStylesDemo" }
    val bar = bar(context, title)
    var testRows = 8

    fun header(): CYLRefreshHeader = when (method) {
        "styleDelivery" -> CYLRefreshDeliveryHeader(context)
        "styleDropBox" -> CYLRefreshDropBoxHeader(context)
        "stylePhoenix" -> CYLRefreshPhoenixHeader(context)
        "styleTaurus" -> CYLRefreshTaurusHeader(context)
        "styleBezierRadar" -> CYLRefreshBezierRadarHeader(context)
        "styleBezierCircle" -> CYLRefreshBezierCircleHeader(context)
        "styleStoreHouse" -> CYLRefreshStoreHouseHeader(context)
        "styleWaveSwipe" -> CYLRefreshWaveSwipeHeader(context)
        "styleOriginal" -> CYLRefreshOriginalHeader(context)
        "styleMaterial" -> CYLRefreshMaterialHeader(context)
        "styleGameHitBlock" -> CYLRefreshGameHitBlockHeader(context)
        "styleGameBattleCity" -> CYLRefreshGameBattleCityHeader(context)
        "styleFly" -> CYLRefreshFlyHeader(context)
        else -> svgaScene(method)?.let { SVGASceneHeader(context, it) } ?: riveStyle(method)?.let { CYLRefreshRiveHeader.create(context, it) } ?: CYLRefreshNormalHeader(context)
    }

    fun footer(): CYLRefreshFooter? = when (method) {
        "styleClassicsFooter" -> CYLRefreshBackNormalFooter(context)
        "styleBezierRadarFooter" -> CYLRefreshBezierRadarFooter(context)
        "styleMaterialFooter" -> CYLRefreshMaterialFooter(context)
        "styleDeliveryFooter" -> CYLRefreshDeliveryFooter(context)
        "stylePhoenixFooter" -> CYLRefreshPhoenixFooter(context)
        "styleTaurusFooter" -> CYLRefreshTaurusFooter(context)
        "styleSvgaSpaceFooter" -> CYLRefreshDrawnFooter(SVGASceneHeader(context, svgaScene(method)!!))
        "styleRiveSpaceFooter" -> riveStyle(method)?.let { CYLRefreshRiveHeader.create(context, it) }?.let { CYLRefreshDrawnFooter(it) }
        else -> null
    }

    val testColumn = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
    fun fillTestRows() {
        testColumn.removeAllViews()
        for (i in 1..testRows) {
            testColumn.addView(row(context, context.t(R.string.merged_style_test_data_row, i), null, "style-row-$i") {})
        }
    }

    val loadMore = footer()
    val control: CYLRefreshComponent = loadMore ?: header()
    // UIDemoHeaderController.changeTheme: colors the control and the bar, and refreshes once.
    fun applyTheme(primary: Int, accent: Int) {
        control.colorPrimary = primary
        control.colorAccent = accent
        bar.setBackgroundColor(if (primary == 0) Color.TRANSPARENT else primary)
        if (loadMore == null) control.beginRefreshing()
    }

    if (method == "styleDelivery") {
        // UIDeliveryController: the header over a plain list of 20 rows.
        testRows = 20
        fillTestRows()
        column.addView(testColumn)
    } else {
        val restore = context.t(R.string.merged_style_tap_to_restore)
        val change = context.t(R.string.merged_style_tap_to_switch)
        column.addView(row(context, context.t(R.string.merged_style_theme_default), restore, "style-theme-default") { applyTheme(0, 0) })
        listOf(
            R.string.merged_style_theme_orange to 0xFFFF9500.toInt(), R.string.merged_style_theme_red to 0xFFFF3B30.toInt(),
            R.string.merged_style_theme_green to 0xFF34C759.toInt(), R.string.merged_style_theme_blue to 0xFF007AFF.toInt(),
        ).forEach { (name, color) ->
            column.addView(row(context, context.t(name), change, "style-theme-$color") { applyTheme(color, Color.WHITE) })
        }
        column.addView(header(context, context.t(R.string.merged_style_test_data)))
        fillTestRows()
        column.addView(testColumn)
    }
    layout.setRefreshContent(ScrollView(context).apply { addView(column) })

    if (loadMore != null) {
        // UIDemoFooterController.onLoadMore: doubles the rows, no more data past 16.
        loadMore.refreshingBlock = {
            later(2500) {
                testRows *= 2
                fillTestRows()
                if (testRows <= 16) loadMore.endRefreshing() else loadMore.endRefreshingWithNoMoreData()
            }
        }
        layout.cyl_header = null
        layout.cyl_footer = loadMore
    } else {
        control.refreshingBlock = { later(2500) { control.endRefreshing() } }
        layout.cyl_header = control as CYLRefreshHeader
        layout.cyl_footer = null
    }
    // UIFlyController and UIWaveSwipeController open in the style's own blue.
    when (method) {
        "styleFly" -> applyTheme(0xFF3399FF.toInt(), Color.WHITE)
        "styleWaveSwipe" -> applyTheme(0xFF007AFF.toInt(), Color.WHITE)
        else -> if (loadMore == null) control.beginRefreshing()
    }
    return page(context, bar, layout)
}
