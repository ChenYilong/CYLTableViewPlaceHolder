package com.cyl.refresh

import android.content.Context
import com.scwang.smart.refresh.header.BezierCircleHeader
import com.scwang.smart.refresh.header.BezierRadarHeader
import com.scwang.smart.refresh.header.ClassicsHeader
import com.scwang.smart.refresh.header.DeliveryHeader
import com.scwang.smart.refresh.header.DropBoxHeader
import com.scwang.smart.refresh.header.FlyRefreshHeader
import com.scwang.smart.refresh.header.FunGameBattleCityHeader
import com.scwang.smart.refresh.header.FunGameHitBlockHeader
import com.scwang.smart.refresh.header.MaterialHeader
import com.scwang.smart.refresh.header.PhoenixHeader
import com.scwang.smart.refresh.header.StoreHouseHeader
import com.scwang.smart.refresh.header.TaurusHeader
import com.scwang.smart.refresh.header.WaveSwipeHeader
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.api.RefreshHeader

/**
 * A header drawn in code, with the hooks its subclasses override (iOS `CYLRefreshDrawnHeader`). On Android the drawing
 * is done by the SmartRefreshLayout header given as [view]; the hooks tell a subclass what happens.
 */
open class CYLRefreshDrawnHeader(view: RefreshHeader) : CYLRefreshHeader(view) {

    /**
     * The header's width, in pixels (`width`).
     */
    val width: Int get() = view.view.width

    /**
     * The header's height, in pixels (`height`).
     */
    val height: Int get() = view.view.height

    /**
     * The fast animation's duration, in seconds (`durationFast`).
     */
    var durationFast: Double
        get() = fastAnimationDuration
        set(value) { fastAnimationDuration = value }

    /**
     * The normal animation's duration, in seconds (`durationNormal`).
     */
    var durationNormal: Double
        get() = slowAnimationDuration
        set(value) { slowAnimationDuration = value }

    /**
     * The phase (`status`).
     */
    val status: CYLRefreshPhase get() = phase

    /**
     * How far the header is pulled, as a share of its height (`dragPercent`).
     */
    val dragPercent: Float get() = pullingPercent

    /**
     * Whether the last refresh succeeded (`isSuccess`).
     */
    val isSuccess: Boolean get() = lastRefreshSucceeded

    /**
     * Called once the header is attached (`setUpComponent`).
     */
    protected open fun setUpComponent() {}

    /**
     * Called on every phase change (`onStatus:changed:`).
     */
    protected open fun onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase) {}

    /**
     * Called as the pull moves, with the layout (`scrollView:didScroll:percent:drag:`).
     */
    protected open fun scrollView(scrollView: SmartRefreshLayout, didScroll: Int, percent: Float, drag: Boolean) {}

    /**
     * Called as the pull moves (`onScrollingWithOffset:percent:drag:`).
     */
    protected open fun onScrollingWithOffset(offset: Int, percent: Float, drag: Boolean) {}

    /**
     * Called when the header is released and opens (`onStartAnimationWhenRealeasing`).
     */
    protected open fun onStartAnimationWhenRealeasing() {}

    /**
     * Called when refreshing starts (`onStartAnimationWhenRefreshing`).
     */
    protected open fun onStartAnimationWhenRefreshing() {}

    /**
     * Called when the refresh ends and the header starts closing; the seconds the finished state shows
     * (`onRefreshFinishing:`).
     */
    protected open fun onRefreshFinishing(success: Boolean): Double = finishDuration

    /**
     * Called once the header has closed (`onRefreshFinished:`).
     */
    protected open fun onRefreshFinished(success: Boolean) {}

    /**
     * Called when the header joins or leaves a layout (`scrollView:attached:`).
     */
    protected open fun scrollView(scrollView: SmartRefreshLayout, attached: Boolean) {}

    /**
     * Starts refreshing (`beginRefresh`).
     */
    fun beginRefresh() = beginRefreshing()

    /**
     * Ends refreshing (`finishRefresh`).
     */
    fun finishRefresh() = endRefreshing()

    /**
     * Ends refreshing with success or failure (`finishRefreshWithSuccess:`).
     */
    fun finishRefreshWithSuccess(success: Boolean) = endRefreshingWithSuccess(success)

    /**
     * True when the phase is one of [statuses] (`inStatus:`).
     */
    fun inStatus(vararg statuses: CYLRefreshPhase): Boolean = isInAnyPhase(*statuses)

    final override fun didAttachToScrollView(layout: SmartRefreshLayout) {
        setUpComponent()
        scrollView(layout, true)
    }

    final override fun willDetachFromScrollView(layout: SmartRefreshLayout) = scrollView(layout, false)

    final override fun didScrollWithOffset(offset: Int, percent: Float, dragging: Boolean) {
        refreshLayout?.let { scrollView(it, offset, percent, dragging) }
        onScrollingWithOffset(offset, percent, dragging)
    }

    final override fun phaseDidChangeFrom(old: CYLRefreshPhase, new: CYLRefreshPhase) {
        onStatus(old, new)
        when (new) {
            CYLRefreshPhase.Releasing -> onStartAnimationWhenRealeasing()
            CYLRefreshPhase.Refreshing -> onStartAnimationWhenRefreshing()
            CYLRefreshPhase.Finishing -> onRefreshFinishing(lastRefreshSucceeded)
            CYLRefreshPhase.Idle -> if (old == CYLRefreshPhase.Finishing) onRefreshFinished(lastRefreshSucceeded)
            else -> Unit
        }
    }
}

/**
 * The Material circle spinner (iOS `CYLRefreshMaterialHeader`).
 */
open class CYLRefreshMaterialHeader(context: Context) : CYLRefreshDrawnHeader(MaterialHeader(context))

/**
 * The Bezier circle (iOS `CYLRefreshBezierCircleHeader`).
 */
open class CYLRefreshBezierCircleHeader(context: Context) : CYLRefreshDrawnHeader(BezierCircleHeader(context))

/**
 * The Bezier radar (iOS `CYLRefreshBezierRadarHeader`).
 */
open class CYLRefreshBezierRadarHeader(context: Context) : CYLRefreshDrawnHeader(BezierRadarHeader(context))

/**
 * The delivery box and balloon (iOS `CYLRefreshDeliveryHeader`).
 */
open class CYLRefreshDeliveryHeader(context: Context) : CYLRefreshDrawnHeader(DeliveryHeader(context))

/**
 * The drop box (iOS `CYLRefreshDropBoxHeader`).
 */
open class CYLRefreshDropBoxHeader(context: Context) : CYLRefreshDrawnHeader(DropBoxHeader(context))

/**
 * The paper plane (iOS `CYLRefreshFlyHeader`).
 */
open class CYLRefreshFlyHeader(context: Context) : CYLRefreshDrawnHeader(FlyRefreshHeader(context))

/**
 * A header with a small game to play while refreshing (iOS `CYLRefreshGameHeader`).
 */
open class CYLRefreshGameHeader(view: RefreshHeader) : CYLRefreshDrawnHeader(view)

/**
 * The tank game (iOS `CYLRefreshGameBattleCityHeader`).
 */
open class CYLRefreshGameBattleCityHeader(context: Context) : CYLRefreshGameHeader(FunGameBattleCityHeader(context))

/**
 * The block-breaking game (iOS `CYLRefreshGameHitBlockHeader`).
 */
open class CYLRefreshGameHitBlockHeader(context: Context) : CYLRefreshGameHeader(FunGameHitBlockHeader(context))

/**
 * The sunrise over a town (iOS `CYLRefreshPhoenixHeader`).
 */
open class CYLRefreshPhoenixHeader(context: Context) : CYLRefreshDrawnHeader(PhoenixHeader(context))

/**
 * The plane among clouds (iOS `CYLRefreshTaurusHeader`).
 */
open class CYLRefreshTaurusHeader(context: Context) : CYLRefreshDrawnHeader(TaurusHeader(context))

/**
 * The wave and drop (iOS `CYLRefreshWaveSwipeHeader`).
 */
open class CYLRefreshWaveSwipeHeader(context: Context) : CYLRefreshDrawnHeader(WaveSwipeHeader(context))

/**
 * SmartRefreshLayout's original classic header (iOS `CYLRefreshOriginalHeader`).
 */
open class CYLRefreshOriginalHeader(context: Context) : CYLRefreshDrawnHeader(ClassicsHeader(context)) {
    /**
     * Whether the header refreshes by itself once attached (`enableAutoRefresh`).
     */
    var enableAutoRefresh: Boolean = false

    override fun setUpComponent() {
        if (enableAutoRefresh) beginRefreshing()
    }
}

/**
 * Text drawn as line segments that assemble as you pull (iOS `CYLRefreshStoreHouseHeader`).
 */
open class CYLRefreshStoreHouseHeader(context: Context) : CYLRefreshDrawnHeader(StoreHouseHeader(context)) {

    private val storeHouse: StoreHouseHeader get() = view as StoreHouseHeader

    /**
     * The lines' width, in pixels (`lineWidth`).
     */
    var lineWidth: Float = 2f
        set(value) {
            field = value
            storeHouse.setLineWidth(value.toInt())
        }

    /**
     * Whether the flash runs back and forth (`enableReverseFlash`); the Android header flashes one way.
     */
    var enableReverseFlash: Boolean = false

    /**
     * Whether the lines fade in as they assemble (`enableFadeAnimation`); the Android header always fades them.
     */
    var enableFadeAnimation: Boolean = true

    /**
     * Draws [string] at the default size (`initLinesWithString:`).
     */
    fun initLinesWithString(string: String) = initLinesWithString(string, 1f)

    /**
     * Draws [string] scaled by [scale] (`initLinesWithString:scale:`).
     */
    fun initLinesWithString(string: String, scale: Float) {
        storeHouse.initWithString(string, (25 * scale).toInt().coerceAtLeast(1))
    }

    /**
     * Draws [string] scaled by [scale]; [padding] is the drop height above the text, in pixels
     * (`initLinesWithString:scale:padding:`).
     */
    fun initLinesWithString(string: String, scale: Float, padding: Float) {
        storeHouse.setDropHeight(padding.toInt())
        initLinesWithString(string, scale)
    }

    /**
     * Draws lines given as "x1,y1,x2,y2" strings (`initLinesWithArray:`).
     */
    fun initLinesWithArray(array: List<String>) {
        val points = array.mapNotNull { line ->
            val numbers = line.split(',').mapNotNull { it.trim().toFloatOrNull() }
            if (numbers.size == 4) numbers.toFloatArray() else null
        }
        if (points.isNotEmpty()) storeHouse.initWithPointList(points)
    }

    /**
     * Draws lines given as "x1,y1,x2,y2" strings, with [padding] as the drop height (`initLinesWithArray:padding:`).
     */
    fun initLinesWithArray(array: List<String>, padding: Float) {
        storeHouse.setDropHeight(padding.toInt())
        initLinesWithArray(array)
    }

    /**
     * Makes headers with the iOS factory names.
     */
    companion object {
        /**
         * A header drawing [string] (`newWithString:`).
         */
        @JvmStatic
        fun newWithString(context: Context, string: String): CYLRefreshStoreHouseHeader = newWithString(context, string, 1f)

        /**
         * A header drawing [string] scaled by [scale] (`newWithString:scale:`).
         */
        @JvmStatic
        fun newWithString(context: Context, string: String, scale: Float): CYLRefreshStoreHouseHeader =
            CYLRefreshStoreHouseHeader(context).apply { initLinesWithString(string, scale) }

        /**
         * A header drawing [string] scaled by [scale], with [padding] (`newWithString:scale:padding:`).
         */
        @JvmStatic
        fun newWithString(context: Context, string: String, scale: Float, padding: Float): CYLRefreshStoreHouseHeader =
            CYLRefreshStoreHouseHeader(context).apply { initLinesWithString(string, scale, padding) }
    }
}
