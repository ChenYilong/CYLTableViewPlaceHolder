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
import com.cyl.refresh.CYLRefreshFlyHeader
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
import com.scwang.smart.refresh.layout.SmartRefreshLayout

/*
 * The demo of SmartRefreshControl (https://github.com/scwang90/SmartRefreshControl, SmartRefreshDemo, MIT; by SCWANG),
 * translated from the iOS example's Swift (`CYLSmartRefreshDemoViewController.swift`) to Kotlin on this project's
 * Android API. The theme colors the page's own bar, as iOS colors the navigation bar.
 */

/**
 * The styles of the "SmartRefreshControl styles" section: title and method (iOS `styles`). The Rive styles wait for
 * a Rive header on Android.
 */
internal val smartStyles = listOf(
    R.string.merged_smart_delivery to "smartDelivery", R.string.merged_smart_classics to "smartClassics",
    R.string.merged_smart_drop_box to "smartDropBox", R.string.merged_smart_phoenix to "smartPhoenix",
    R.string.merged_smart_taurus to "smartTaurus", R.string.merged_smart_bezier_radar to "smartBezierRadar",
    R.string.merged_smart_bezier_circle to "smartBezierCircle", R.string.merged_smart_store_house to "smartStoreHouse",
    R.string.merged_smart_wave_swipe to "smartWaveSwipe", R.string.merged_smart_original to "smartOriginal",
    R.string.merged_smart_material to "smartMaterial", R.string.merged_smart_game_hit_block to "smartGameHitBlock",
    R.string.merged_smart_game_battle_city to "smartGameBattleCity", R.string.merged_smart_fly to "smartFly",
    R.string.merged_smart_classics_footer to "smartClassicsFooter",
    R.string.merged_smart_bezier_radar_footer to "smartBezierRadarFooter",
    R.string.merged_smart_material_footer to "smartMaterialFooter",
    R.string.merged_smart_delivery_footer to "smartDeliveryFooter",
    R.string.merged_smart_phoenix_footer to "smartPhoenixFooter", R.string.merged_smart_taurus_footer to "smartTaurusFooter",
)

/**
 * One style's page (iOS `CYLSmartRefreshDemoViewController`): theme rows and test data, with the style's header (it
 * refreshes on open) or footer (it doubles the rows, then has no more data past 16).
 */
internal fun RefreshExamplesPage.smartStylePage(title: String, method: String): View {
    val context = requireContext()
    val layout = SmartRefreshLayout(context)
    val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL; tag = "smartRefreshDemo" }
    val bar = bar(context, title)
    var testRows = 8

    fun header(): CYLRefreshHeader = when (method) {
        "smartDelivery" -> CYLRefreshDeliveryHeader(context)
        "smartDropBox" -> CYLRefreshDropBoxHeader(context)
        "smartPhoenix" -> CYLRefreshPhoenixHeader(context)
        "smartTaurus" -> CYLRefreshTaurusHeader(context)
        "smartBezierRadar" -> CYLRefreshBezierRadarHeader(context)
        "smartBezierCircle" -> CYLRefreshBezierCircleHeader(context)
        "smartStoreHouse" -> CYLRefreshStoreHouseHeader(context)
        "smartWaveSwipe" -> CYLRefreshWaveSwipeHeader(context)
        "smartOriginal" -> CYLRefreshOriginalHeader(context)
        "smartMaterial" -> CYLRefreshMaterialHeader(context)
        "smartGameHitBlock" -> CYLRefreshGameHitBlockHeader(context)
        "smartGameBattleCity" -> CYLRefreshGameBattleCityHeader(context)
        "smartFly" -> CYLRefreshFlyHeader(context)
        else -> CYLRefreshNormalHeader(context)
    }

    fun footer(): CYLRefreshFooter? = when (method) {
        "smartClassicsFooter" -> CYLRefreshBackNormalFooter(context)
        "smartBezierRadarFooter" -> CYLRefreshBezierRadarFooter(context)
        "smartMaterialFooter" -> CYLRefreshMaterialFooter(context)
        "smartDeliveryFooter" -> CYLRefreshDeliveryFooter(context)
        "smartPhoenixFooter" -> CYLRefreshPhoenixFooter(context)
        "smartTaurusFooter" -> CYLRefreshTaurusFooter(context)
        else -> null
    }

    val testColumn = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
    fun fillTestRows() {
        testColumn.removeAllViews()
        for (i in 1..testRows) {
            testColumn.addView(row(context, context.t(R.string.merged_smart_test_data_row, i), null, "smart-row-$i") {})
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

    if (method == "smartDelivery") {
        // UIDeliveryController: the header over a plain list of 20 rows.
        testRows = 20
        fillTestRows()
        column.addView(testColumn)
    } else {
        val restore = context.t(R.string.merged_smart_tap_to_restore)
        val change = context.t(R.string.merged_smart_tap_to_switch)
        column.addView(row(context, context.t(R.string.merged_smart_theme_default), restore, "smart-theme-default") { applyTheme(0, 0) })
        listOf(
            R.string.merged_smart_theme_orange to 0xFFFF9500.toInt(), R.string.merged_smart_theme_red to 0xFFFF3B30.toInt(),
            R.string.merged_smart_theme_green to 0xFF34C759.toInt(), R.string.merged_smart_theme_blue to 0xFF007AFF.toInt(),
        ).forEach { (name, color) ->
            column.addView(row(context, context.t(name), change, "smart-theme-$color") { applyTheme(color, Color.WHITE) })
        }
        column.addView(header(context, context.t(R.string.merged_smart_test_data)))
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
        layout.setEnableRefresh(false)
        layout.cyl_footer = loadMore
    } else {
        control.refreshingBlock = { later(2500) { control.endRefreshing() } }
        layout.cyl_header = control as CYLRefreshHeader
        layout.setEnableLoadMore(false)
    }
    // UIFlyController and UIWaveSwipeController open in the style's own blue.
    when (method) {
        "smartFly" -> applyTheme(0xFF3399FF.toInt(), Color.WHITE)
        "smartWaveSwipe" -> applyTheme(0xFF007AFF.toInt(), Color.WHITE)
        else -> if (loadMore == null) control.beginRefreshing()
    }
    return page(context, bar, layout)
}
